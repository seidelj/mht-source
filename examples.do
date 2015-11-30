clear all
cd "/home/joseph/mht/data"
insheet using data.csv, comma names

//Creating outcome variable
gen amountmat = amount * ratio
egen groupids = group(redcty red0)
cd
cd mht

do listtest2



mata

/* example 1 */
Y = st_data(.,("gave", "amount", "amountmat", "amountchange"))
D = st_data(.,("treatment"))
sub = J(rows(D), 1,1) // If multiple it should created egen groupid = group(group1, group2, group3, etc)
numoc = cols(Y)
numsub = rows(uniqrows(sub))
numg=rows(uniqrows(D)) -1
combo = (J(numg,1,0), (1::numg))
numpc=rows(combo)
select = mdarray((numoc, numsub, numpc), 1)

example1 = listetal(Y,sub, D, combo, select)

/* example 2 */
Y = st_data(.,("gave"))
D = st_data(., ("treatment"))
sub = st_data(., ("groupids"))
numoc = cols(Y)
numsub = rows(uniqrows(sub)) - 1 // exclude missing
numg=rows(uniqrows(D)) - 1
combo = (J(numg,1,0), (1::numg))
numpc=rows(combo)
select = mdarray((numoc, numsub, numpc), 1)


example2 = listetal(Y, sub, D, combo, select)

/* example 3 */
Y = st_data(.,("amount"))
D = st_data(.,("ratio"))
sub = J(rows(D), 1,1)
numoc = cols(Y)
numsub = rows(uniqrows(sub))
numg = rows(uniqrows(D)) -1
combo = (J(numg,1,0), (1::numg))
numpc=rows(combo)
select = mdarray((numoc, numsub, numpc), 1)

example3 = listetal(Y, sub, D, combo, select)


/* example 4 */
Y = st_data(.,("amount"))
D = st_data(.,("ratio"))
sub = J(rows(D), 1,1)
numoc = cols(Y)
numsub = rows(uniqrows(sub))
numg = rows(uniqrows(D)) -1
combo = nchoosek((0..numg), 2)
numpc=rows(combo)
select = mdarray((numoc, numsub, numpc), 1)

example4 = listetal(Y, sub, D, combo, select)

/* example 5 */
Y = st_data(.,("gave", "amount", "amountmat", "amountchange"))
D = st_data(.,("ratio"))
sub = st_data(., ("groupids"))
numoc = cols(Y)
numsub = rows(uniqrows(sub))
numg=rows(uniqrows(D)) -1
combo = (J(numg,1,0), (1::numg))
numpc=rows(combo)
select = mdarray((numoc, numsub, numpc), 1)

example5 = listetal(Y, sub, D, combo, select)
end
*/
