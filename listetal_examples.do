clear all
cd "data"
insheet using data.csv, comma names
//Creating outcome variable
gen amountmat = amount * ratio
gen groupid = (redcty==1 & red0 == 1) + (redcty==0 & red0 == 1)*2 + (redcty==0 & red0 == 0)*3 + (redcty==1 & red0 == 0)*4
replace groupid = . if groupid == 0
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

// example 1
listetal gave amount amountmat amountchange, treatment(treatment)

//example 2
listetal gave, treatment(treatment) subgroup(groupid)

//example 3

listetal amount, treatment(ratio)

//example 4
listetal amount, treatment(ratio) combo("pairwise")

//example 5
listetal gave amount amountmat amountchange, subgroup(groupid) treatment(ratio)
