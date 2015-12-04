clear all
cd "/home/joseph/mht/data"
insheet using data.csv, comma names

//Creating outcome variable
gen amountmat = amount * ratio
egen groupids = group(redcty red0)
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
numsub = rows(uniqrows(sub))
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

headers = ("outcome","subgroup","treatment1","treatment2","diff_in_means","single_testing","Thm2_2", "Remark2_1", "Bonf","Holm")
blanks = J(cols(headers), 1, "")

headersmatrix = (blanks, headers')
st_matrix("example3", example3)
st_matrixcolstripe("example3", headersmatrix)
*/
/* example 4 */
Y = st_data(.,("amount"))
D = st_data(.,("ratio"))
sub = J(rows(D), 1,1)
numoc = cols(Y)
numsub = rows(uniqrows(sub))
numg = rows(uniqrows(D)) -1
combo = nchoosek((0::numg), 2)
numpc=rows(combo)
select = mdarray((numoc, numsub, numpc), 1)

example4 = listetal(Y, sub, D, combo, select)

headers = ("outcome","subgroup","treatment1","treatment2","diff_in_means","single_testing","Thm2_2", "Remark2_1", "Bonf","Holm")
blanks = J(cols(headers), 1, "")

headersmatrix = (blanks, headers')
st_matrix("example4", example4)
st_matrixcolstripe("example4", headersmatrix)


/*
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

headers = ("outcome","subgroup","treatment1","treatment2","diff_in_means","single_testing","Thm2_2", "Remark2_1", "Bonf","Holm")
blanks = J(cols(headers), 1, "")

headersmatrix = (blanks, headers')
st_matrix("example5", example5)
st_matrixcolstripe("example5", headersmatrix)
end
