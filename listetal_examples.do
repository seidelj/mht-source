clear all
cd "/home/joseph/mht/data"
insheet using data.csv, comma names
//Creating outcome variable
gen amountmat = amount * ratio

cd
cd mht

/// syntax
/// listetal outcomes subgroup treatment combo select
/// where
/// outcomes = a string of variable names
/// subgroup = variable name containg group id
/// treatment = a string of treatment variable names"
/// combo = treatmentcontrol or pairwise
/// select = integer [1-4]
***     1: all  numoc*numsub*numpc
***     2:      numoc*numsub
***     3:      numoc*numpc
***     4:      numsub * numpc

/*
// example 1
//Creating group variable
listetal gave amount amountmat amountchange, treatment(treatment)


//example 2
//create group variable of id's according
gen groupid = (redcty==1 & red0 == 1) + (redcty==0 & red0 == 1)*2 + (redcty==0 & red0 == 0)*3 + (redcty==1 & red0 == 0)*4
replace groupid = . if groupid == 0
listetal gave, treatment(treatment) subgroup(groupid)

*/
//example 3
listetal amount, treatment(ratio) 

/*
//example 4
listetal "amount" groupid "ratio" "pairwise" 1

//example 5
drop groupid
gen groupid = (redcty==1 & red0 == 1) + (redcty==0 & red0 == 1)*2 + (redcty==0 & red0 == 0)*3 + (redcty==1 & red0 == 0)*4
replace groupid = . if groupid == 0
listetal "gave amount amountmat amountchange" groupid "treatment" "treatmentcontrol" 1

/* THE CODE BELOW CAN BE INGORED.  IT WILL BE REMOVED IN THE FUTRE
** IT IS CURRENTLY JUST FOR MY REFERENCE AS I TRANSITION TO A FUNCTIONAL
** ADO file
*/

/*
do functions
do listetal
/*
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
