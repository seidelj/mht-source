In stata make sure your cd contains
-listetal.ado
-functions.do //functions required for listetal.do
-listetal.do  // the actual program that performs the mht computation

See examples.do for how to uses

listetal

sytnax:
    cmd varlist, treatment(varlist) [ subgroup(varname) combo(string "pairwise"|"treatmentcontrol"(default)) select(integer default=1) ] 

*** where  select = integer [1-4]
***     1:      numoc*numsub*numpc
***     2:      numoc*numsub
***     3:      numoc*numpc
***     4:      numsub * numpc
