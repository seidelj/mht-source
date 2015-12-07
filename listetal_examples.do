clear all
cd "/home/joseph/mht/data"
insheet using data.csv, comma names

//Creating outcome variable
gen amountmat = amount * ratio
//Creating group variable for sub
gen groupids = (redcty==1 & red0 == 1) + (redcty==0 & red0 == 1)*2 + (redcty==0 & red0 == 0)*3 + (redcty==1 & red0 == 0)*4
replace groupids = . if groupids == 0

cd
cd mht

do functions
do listetal

mata:
/*
/* example 1 */
Y = st_data(.,("gave", "amount", "amountmat", "amountchange"))
D = st_data(.,("treatment"))
sub = J(rows(D), 1,1) // If multiple it should created egen groupid = group(group1, group2, group3, etc)
numoc = cols(Y)
numsub = colnonmissing(uniqrows(sub))
numg=rows(uniqrows(D)) -1
combo = (J(numg,1,0), (1::numg))
numpc=rows(combo)
select = mdarray((numoc, numsub, numpc), 1)

example1 = listetal(Y,sub, D, combo, select)
buildoutput("example1", example1)


/* example 2 */

Y = st_data(.,("gave"))
D = st_data(., ("treatment"))
sub = st_data(., ("groupids"))
numoc = cols(Y)
numsub = colnonmissing(uniqrows(sub))
numg=rows(uniqrows(D)) - 1
combo = (J(numg,1,0), (1::numg))
numpc=rows(combo)
select = mdarray((numoc, numsub, numpc), 1)

example2 = listetal(Y, sub, D, combo, select)
buildoutput("example2", example2)

/* example 3 */
Y = st_data(.,("amount"))
D = st_data(.,("ratio"))
sub = J(rows(D), 1,1)
numoc = cols(Y)
numsub = colnonmissing(uniqrows(sub))
numg = rows(uniqrows(D)) -1
combo = (J(numg,1,0), (1::numg))
numpc=rows(combo)
select = mdarray((numoc, numsub, numpc), 1)

example3 = listetal(Y, sub, D, combo, select)
buildoutput("example3", example3)

/* example 4 */
Y = st_data(.,("amount"))
D = st_data(.,("ratio"))
sub = J(rows(D), 1,1)
numoc = cols(Y)
numsub = colnonmissing(uniqrows(sub))
numg = rows(uniqrows(D)) -1
combo = nchoosek((0::numg), 2)
numpc=rows(combo)
select = mdarray((numoc, numsub, numpc), 1)

example4 = listetal(Y, sub, D, combo, select)
buildoutput("example4", example4)

*/
/* example 5 */
Y = st_data(.,("gave", "amount", "amountmat", "amountchange"))
D = st_data(.,("ratio"))
sub = st_data(., ("groupids"))
numoc = cols(Y)
numsub = colnonmissing(uniqrows(sub))
numg=rows(uniqrows(D)) -1
combo = (J(numg,1,0), (1::numg))
numpc=rows(combo)
select = mdarray((numoc, numsub, numpc), 1)

example5 = listetal(Y, sub, D, combo, select)
buildoutput("example5", example5)
end
