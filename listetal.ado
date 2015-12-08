program listetal
    syntax varlist [if] [in], treatment(varlist) [ subgroup(varname) combo(string) select(integer 1) ]
    //args outcomes subgroupid treatment combo select

    if ("`combo'" != "" & "`combo'" != "pairwise" & "`combo'" != "treatmentcontrol"){
        display "INVALID combo choose either pairwise or treatmentcontrol"
        error
    }

    //Load in required functions
    clear mata
    quietly: do functions
    quietly: do listetal

    mata: Y = buildY("`varlist'")
    mata: D = buildD("`treatment'")
    mata: sub = buildsub("`subgroup'", D)
    mata: sizes = buildsizes(Y, D, sub)
    mata: combo = buildcombo("`combo'", sizes[3])
    mata: numpc = buildnumpc(combo)
    mata: select = buildselect(`select', sizes[1], sizes[2], sizes[3])
    mata: results = listetal(Y, sub, D, combo, select)
    mata: buildoutput("results", results)

    matlist results
end

mata:

    function buildY(string scalar outcomes){
        Y = st_data(., tokens(outcomes))
        return(Y)
    }
    function buildD(string scalar treatment){
        D = st_data(., tokens(treatment))
        return(D)
    }
    function buildsub(string scalar subgroup, real matrix D){
        if (subgroup == ""){
            sub = J(rows(D), 1,1)
        }else{
            sub = st_data(., (subgroup))
        }
        return(sub)
    }
    function buildsizes(real matrix Y, real matrix D, real matrix sub){
        numoc = cols(Y)
        numsub = colnonmissing(uniqrows(sub))
        numg = rows(uniqrows(D)) - 1

        return((numoc, numsub, numg))
    }
    function buildcombo(string scalar strcombo, real scalar numg){
        if (strcombo == "pairwise"){
    		combo = nchoosek((0::numg), 2)
    	}else{
    		combo = (J(numg,1,0), (1::numg))
    	}
        return(combo)
    }
    function buildnumpc(real matrix combo){
        return(rows(combo))
    }
    function buildselect(real scalar argselect, real scalar numoc, real scalar numsub, real scalar numpc){
        if (argselect == 1) select = mdarray((numoc, numsub, numpc), 1)
        else if (argselect == 2) select = mdarray((numoc, numsub, 1), 1)
        else if (argselect == 3) select = mdarray((numoc, numpc, 1), 1)
        else select = mdarray((numsub, numpc, 1), 1)

        return(select)
    }

end
