clear all
set seed 42
cd "C:\Users\justin holz\Desktop\Dropbox\MHT\data"
insheet using practice_data.csv, comma clear

*User Parameters
gl treatments "treatment"
gl outcomes "y1 y2 y3"
gl subgroups "g1 g2 g3"

*Create parameters from data
gl n = _N // the number of observations
gl B = 10 // the number of simulated samples
gl numoc = `: word count $outcomes' // the number of outcomes 

egen sub = group($subgroups) 
levelsof sub, loc(sub_levels)
gl numsub `: word count `sub_levels'' // the number of subgroups

egen D = group($treatments)
levelsof D, loc(D_levels)
gl numd =  `: word count `D_levels'' // the number of treatments (not including the control group)

gl nh = 24 //number of hypoth

*Create matrices of zeroes for each pairwise comparison to populate with studentized absolute differences in means
forv d = 1 / $numd { // Create empty matrices to hold the actual statistics
	forv j = 2 / $numd {
		if `d' < `j' {
			mata: statsact_`d'_`j' = J($numoc ,$numsub ,0)
		}
	}
}

*Compute the studentized absolute differences in means for all the hypotheses based on the actual data
forv y = 1 / $numoc {
	forv g = 1 / $numsub {
		forv d = 1 / $numd {
			forv j = 2 / $numd {
				if `d' < `j' {
					noi cap ttest `: word `y' of $outcomes' if sub == `g' & (D == `d' | D == `j'), by(D)
					noi cap mata: statsact_`d'_`j'[`y',`g'] = abs((`r(mu_1)' - `r(mu_2)') / sqrt(`r(sd_1)'^2 / `r(N_1)' + `r(sd_2)'^2 / `r(N_2)'))
				}
			}
		}
	}
}

*Construct bootstrap samples and compute the test statistics for each simulated sample
forv g = 1 / $numsub {
	forv d = 1 / $numd { // Create empty matrices to hold the bootstrapped statistics
		forv j = 2 / $numd {
			if `d' < `j' {
				mata: statsboot_`d'_`j'_`g' = J($B ,$numoc ,0)
			}
		}
	}
}

forv b = 1/$B {
	preserve
		mata: draw = ceil(runiform($n,1):*$n)
		mata: expander = J($n,1, 0)
		mata: for (i = 1 ; i <= $n; i++) expander[i] = sum(draw :== i) // Count the number of items per observation to generate.
		getmata expander = expander
		drop if expander == 0
		expand expander

		forv y = 1 / $numoc {
			forv g = 1 / $numsub {
				forv d = 1 / $numd {
					forv j = 2 / $numd {
						if `d' < `j' {
							noi cap ttest `: word `y' of $outcomes' if sub == `g' & (D == `d' | D == `j'), by(D)
							noi cap mata: statsboot_`d'_`j'_`g'[`b',`y'] = abs(`r(mu_1)' - `r(mu_2)') / sqrt(`r(sd_1)'^2 / `r(N_1)' + `r(sd_2)'^2 / `r(N_2)')
						}
					}
				}
			}
		}
	restore
}

*Convert the statistics to 1 - (p-values)
forv g = 1 / $numsub {
	forv d = 1 / $numd {
		forv j = 2 / $numd {
			if `d' < `j' {
				mata: pact_`d'_`j' = J($numoc ,$numsub ,0) // a matrix of 1-p values of the actual data
				mata: pboot_`d'_`j'_`g' = J($B ,$numoc ,0) // a matrix of 1-p values of all the simulated data
			}
		}
	}
}

forv y = 1/ $numoc {
	forv g = 1/ $numsub {
		forv d = 1 / $numd {
			forv j = 2 / $numd {
				if `d' < `j' {
					mata: pact_`d'_`j'[`y',`g'] = 1 - sum(statsboot_`d'_`j'_`g'[.,`y'] :>= statsact_`d'_`j'[`y',`g']) / $B
					forv l = 1/$B {
						mata: pboot_`d'_`j'_`g'[`l',`y'] = 1 - sum(statsboot_`d'_`j'_`g'[.,`y'] :>= statsboot_`d'_`j'_`g'[`l',`y']) / $B
					}
				}
			}
		}
	}
}

*Calculate p-values based on single hypothesis testing
forv d = 1 / $numd { // Create empty matrices to hold the actual statistics
	forv j = 2 / $numd {
		if `d' < `j' {
			mata: psin_`d'_`j' = J($numoc ,$numsub ,0)
		}
	}
}

forv y = 1/ $numoc {
	forv g = 1/$numsub {
		forv d = 1 / $numd {
			forv j = 2 / $numd {
				if `d' < `j' {
					mata: q = sum(pact_`d'_`j'[`y',`g'] :> sort(pboot_`d'_`j'_`g'[.,`y'],-1))  / $B
					mata: psin_`d'_`j'[`y',`g'] = q
				}
			}
		}
	}
}

*Calculate p-values based on multiple hypothesis testing
mata: statsall = J($nh, 8 + $B, 0) // columns 1-5 present the id's of the hypotheses, outcomes, subgroups, and treatment (control) groups
						           // column 6 shows the studentized difference in means for all hypotheses based on the actual data
								   // column 7 presents p-values based on single hypothesis testing
								   // column 8 presents 1- p values based on the actual data
								   // columns 9 through B+9 contain the corresponding 1-p values based on the simulated samples
																								   
mata: id = (1::$nh) //hypothesis id


