program listetal
    args outcomes subgroupid treatment combo select

    if ("`combo'" != "pairwise" & "`combo'" != "treatmentcontrol"){
        display "INVALID combo choose either pairwise or treatmentcontrol"
        error
    }

    //Load in required functions
    clear mata
    quietly: do functions
    quietly: do listetal

    mata: Y = buildY("`outcomes'")
    mata: D = buildD("`treatment'")
    mata: sub = buildsub("`subgroupid'")
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
    function buildsub(string scalar subgroupids){
        sub = st_data(., (subgroupids))
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
    /*
    function buildparams(string scalar outcomes, string scalar treatment, string scalar subgroupid, string scalar strcombo, real scalar argselect){
    	Y = st_data(., tokens(outcomes))
    	D = st_data(., tokens(treatment))
    	sub = st_data(., (subgroupid))
    	numoc =  cols(Y)
    	numsub = colnonmissing(uniqrows(sub))
    	numg = rows(uniqrows(D)) - 1
    	if (strcombo == "pairwise"){
    		combo = nchoosek((0::numg), 2)
    	}else{
    		combo = (J(numg,1,0), (1::numg))
    	}
    	numpc = rows(combo)
    	if (argselect == 1) select = mdarray((numoc, numsub, numpc), 1)
    	else if (argselect == 2) select = mdarray((numoc, numsub, 1), 1)
        else if (argselect == 3) select = mdarray((numoc, numpc, 1), 1)
        else select = mdarray((numsub, numpc, 1), 1)

    }
    */
end
