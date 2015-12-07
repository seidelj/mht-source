

mata:

function listetal(Y, sub, D, combo, select ){


//Parameters set by the function
n = rows(Y)
B = 3000
numoc = cols(Y)
numsub = colnonmissing(uniqrows(sub)) 
numg=rows(uniqrows(D)) - 1
numpc=rows(combo)

// comput the studentized difference in means
// for all the hypothises based on actual data

meanact = mdarray((numoc, numsub, numg+1), 0)
varact = mdarray((numoc, numsub, numg+1), 0)
Nact= mdarray((numoc, numsub, numg+1), 0)

for (i=1; i <= numoc; i++)
{
	for (j=1; j<=numsub; j++)
	{
		for (k=0; k<=numg; k++)
		{
			w = (sub :== j :& D :== k)
			put(mean(Y[.,i], w), meanact, (i,j,k+1))
			put(variance(Y[.,i], w), varact, (i, j, k+1))
			CP = quadcross(w,0, Y[.,i],1)
			put(CP[cols(CP)], Nact, (i, j, k+1))
		}
	}
}

diffact = mdarray((numoc, numsub, numpc), .)
abdiffact = mdarray((numoc, numsub, numpc), .)
statsact = mdarray((numoc, numsub, numpc), .)

// I have no idea what will happen when this ends up being a n-dimension matrix
for (i=1; i <=rows(combo); i++){
	diff = get(meanact, (.,.,combo[i,1]:+1)) - get(meanact, (.,.,combo[i,2]:+1))
	put(diff, diffact, (.,.,i))
	put(abs(diff), abdiffact, (.,.,i))
	stat = get(abdiffact, (.,.,i)) :/ sqrt(get(varact, (.,.,combo[i,1]:+1)) :/ get(Nact, (.,.,combo[i,1]:+1)) ///
		+ get(varact, (.,.,combo[i,2]:+1)) :/ get(Nact, (.,.,combo[i,2]:+1)))
	put(stat, statsact, (.,.,i))
}
/*
** Construct boostrap samples and computes the test
** stastics and the corresponding 1-p values for each
** simulated sample
*/

rseed(0)
idboot = runiformint(n, B, 1, n)
statsboot= mdarray((B, numoc, numsub, numpc), 0)
meanboot = mdarray((numoc, numsub, numg+1), 0)
varboot = mdarray((numoc, numsub, numg+1), 0)
Nboot = mdarray((numoc, numsub, numg+1), 0)
diffboot = mdarray((numoc, numsub, numpc),.)

for (i=1; i <= B; i++)
{
	Yboot = Y[idboot[.,i], .]
	subboot = sub[idboot[.,i], .]
	Dboot = D[idboot[.,i], .]
	for (j=1; j <= numoc; j++)
	{
		for (k=1; k <= numsub; k++)
		{
			for (l=0; l <= numg; l++)
			{
				w = (subboot :== k :& Dboot :== l)
				put(mean(Yboot[.,j], w), meanboot, (j, k, l+1))
				put(variance(Yboot[.,j], w), varboot, (j,k,l+1))
				CP = quadcross(w, 0, Yboot[.,j] , 1)
				put(CP[cols(CP)], Nboot, (j, k, l+1))
			}
		}
	}
	mdstatsarr = mdarray((numoc, numsub, rows(combo)), .)
	for (k = 1; k <= rows(combo); k++){
		diff = get(meanboot, (.,.,combo[k,1]:+1)) - get(meanboot, (.,.,combo[k,2]:+1))
		put(diff, diffboot, (.,.,k))
		statsarr = (abs(get(diffboot, (.,.,k)) - get(diffact, (.,.,k)))) :/ sqrt(get(varboot, (.,.,combo[k,1]:+1)) :/ get(Nboot, (.,.,combo[k,1]:+ 1)) ///
			+ get(varboot, (.,.,combo[k,2]:+1)) :/ get(Nboot, (.,.,combo[k,2]:+1)))
		put(statsarr, mdstatsarr, (.,., k))
	}
	for (ll=1; ll<=numpc; ll++){
		for (kk=1; kk<=numsub; kk++){
			(*(statsboot[kk,ll]))[i,.] = get(mdstatsarr, (.,.,ll))'[kk,.]
		}
	}
}

pact = mdarray((numoc,numsub, numpc), 0 ) // a matrix of 1-p values of the actual data
pboot = mdarray((B, numoc, numsub, numpc), 0) // a matrix of 1-p values of the simulated data

for (i=1; i<=numoc; i++)
{
	for (j=1; j<=numsub; j++)
	{
		for (k=1; k<=numpc; k++)
		{
			p = 1 - (sum(get(statsboot,(.,i,j,k)) :>= get(statsact, (i,j,k)) * J(B,1,1))) / B
			put(p, pact, (i,j,k))
			for (l=1; l<=B; l++)
			{
				sp = 1 - (sum(get(statsboot, (.,i,j,k)) :>= get(statsboot, (l,i,j,k)) * J(B,1,1))) / B;
				put(sp, pboot, (l,i,j,k))
			}
		}
	}
}


/* calculate p-values based on single hypothesis testing */

alphasin = mdarray((numoc, numsub, numpc), 0)

for (i=1; i<=numoc; i++)
{
	for (j=1; j<=numsub; j++)
	{
		for (k=1; k<=numpc; k++)
		{
			ptemp =  get(pboot, (.,i,j,k))
			sortp = sort(ptemp, -1)
			v = (get(pact, (i,j,k)) * J(B,1,1 )) :>= sortp
			indx = find(v)
			if (indx == NULL) {
			    q = 1
			}else{
			    q = indx/B
			}
			put(q, alphasin, (i,j,k))
		}
	}
}

psin = mdarray((numoc, numsub, numpc), 0) // p-values based on single hypothesis testing
for (k=1; k<=numpc; k++){
	put(get(alphasin, (.,.,k)), psin, (.,.,k))
}


/* Calculate p-values based on multiple hypothesis tesitng */

nh = 0
for (k=1; k <= numpc; k++)
{
	nh = nh + sum((*(select[k,.]))[.,.])
}
statsall = J(nh, 8+B, 0)

counter=1
for (i=1; i<=numoc; i++)
{
	for (j=1; j<=numsub; j++)
	{
		for (k=1; k<=numpc; k++)
		{
			if ( (*(select[k, .]))[i,j] == 1 ){
				rowvect = (i,j,k)
				statsall[counter, .] = (counter, i, j, combo[k, .], get(abdiffact, rowvect) , get(psin, rowvect), get(pact, rowvect), get(pboot, (., i, j, k))')
				counter = counter + 1
			}
		}
	}
}

statsrank = sort(statsall, 7) // rank the rows according to the p-values based on single hypothesis testin
alphamul = J(nh, 1, 0) // the smallest alpaha that reject the hypothesis based on Theorem 3.1
alphamulm = J(nh, 1, 0) // the smallest alpha's that reject the hypothesis based on Remark 3.7

for (i=1; i<=nh; i++)
{
	maxstats = colmax(statsrank[(i::rows(statsrank)), (9::cols(statsrank))])
	sortmaxstats = sort(maxstats', -1)'
	v = statsrank[i, 8] :>= sortmaxstats
	indx = find(v)
	if (indx == NULL){
	    q = 1
	}else{
	    q = indx/B
	}
	alphamul[i] = q
	if (i==1){
		alphamulm[i]=alphamul[i]
	}else{
		sortmaxstatsm=J(1,B,0)
		for (j=nh-i+1; j >= 1; j--)
		{
			subset = nchoosek(statsrank[(i::rows(statsrank)), 1], j)
			sumcont = 0
			for (k=1; k<=rows(subset); k++ ){
				cont = 0
				for (l=1; l <= i-1; l++)
				{
					tempA = statsall[(subset[k,.]), (2..3)]
					tempB = J(rows(tempA), 1, statsrank[l, (2..3)] )
					sameocsub = select(subset[k,.], (ismember(tempA, tempB,1)'))
					if (cols(sameocsub) >= 1){
						tran = mat2cell(statsall[(sameocsub), (4..5)], J(1, cols(sameocsub),1) , 2)
						trantemp=tran
					}
					if (cols(sameocsub) <= 1){
						cont = 0
						maxstatsm = colmax(statsall[(subset[k,.]), (9::cols(statsall))])
						sortmaxstatsm = colmax(sortmaxstatsm \ sort(maxstatsm', -1)')
						break
					}else{
						counter = 1
						while ( max(asarray_keys(tran)[.,1]) > max(asarray_keys(trantemp)[.,1]) || counter == 1 ){
							tran=trantemp
							trantemp = asarray_create("real", 2)
							asarray(trantemp, (1,1), asarray(tran, (1,1)))
							counter=counter + 1
							for (m=2; m<=max(asarray_keys(tran)[.,1]); m++){
								belong = 0
								for (n=1; n <= max(asarray_keys(trantemp)[.,1]); n++){
									trantempn = asarray(trantemp, (n,1))
									tranm = asarray(tran, (m,1))
									unq = uniqrows( (trantempn, tranm)' )'
									test = unq :< cols(trantempn) + cols(tranm)
									if (sum(test) == cols(unq)){
										asarray(trantemp, (n,1), unq)
										belong = belong+1
										if (n==max(asarray_keys(trantemp)[.,1]) && belong ==0){
											asarray(trantemp, (n+1,1), tranm)
										}
									}
								}
							}
						}
						for (p=1; p<=max(asarray_keys(tran)[.,1]); p++){
							if (sum(ismember(statsrank[l, (4..5)], asarray(tran, (p,1)), 2)) == 2){
								cont=1
								break
							}
						}
					}
					if (cont==1){
						break
					}
				}
				sumcont=sumcont+cont
				if (cont==0){
					maxstatsm = colmax(statsall[(subset[k,.]), (9::cols(statsall))])
					sortmaxstatsm = colmax(sortmaxstatsm \ sort(maxstatsm', -1)')
				}
			}
			if (sumcont==0){
				break;
			}
		}
		indx = find(statsrank[i,8] :>= sortmaxstatsm)
		if (indx == NULL){
			qm = 1
		}else{
			qm = indx/B
		}
		alphamulm[i] = qm
	}
}

bon = rowmin((statsrank[.,7]*nh, J(nh,1,1) ))
holm = rowmin((statsrank[.,7]:*(nh::1), J(nh,1,1)))

output = sort((statsrank[.,(1::7)], alphamul, alphamulm, bon, holm),1)
output = output[., (2::cols(output))]
headers = ("outcome","subgroup","treatment1","treatment2","diff_in_means","Remark3_1","Thm3_1", "Remark3_7", "Bonf","Holm")
blanks = J(cols(headers), 1, "")

headersmatrix = (blanks, headers')
output = output


return(output)
}

mata mosave listetal(), dir(functions) replace

end
