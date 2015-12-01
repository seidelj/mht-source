
mata:

function mdarray( rowvec , fill)
{
	// rowvec = (i, j, k..[l])
	if (cols(rowvec) == 3) c_l = 1
	else c_l = rowvec[1,4]
	r_k = rowvec[1,3]


	a = J(r_k,c_l,NULL)
	for (k=1; k<=rows(a); k++)
	{
		for (l=1; l<=cols(a); l++)
		{
			a[k,l] = &J(rowvec[1,1],rowvec[1,2],fill)
		}
	}
	return(a)
}
mata mosave mdarray(), dir(functions) replace

function put(val,x, rowvec)
{
	/* Usage: value to put, matrix to put it in, i,j of dimension k, to put it at.*/

	//rowvec = (i,j,k, [l])
	if (cols(rowvec)== 3) c_l = 1
	else c_l = rowvec[1,4]
	r_k = rowvec[1,3]
	i = rowvec[1,1]
	j = rowvec[1,2]

	(*(x[r_k,c_l]))[i,j]=val
}
mata mosave put(), dir(functions) replace

function get(x, rowvec)
{
	/* Usage: matrix to get from, i,j of dimension k, of value to get. */

	//rowvec = (i,j,k, [l])
	if (cols(rowvec)== 3) c_l = 1
	else c_l = rowvec[1,4]
	r_k = rowvec[1,3]
	i = rowvec[1,1]
	j = rowvec[1,2]

	return((*(x[r_k,c_l]))[i,j])
}
mata mosave get(), dir(functions) replace


function nchoosek(V, K)
{
    A = J(comb(rows(V), K), K, .)
    com = J(100, 1, .)
    n = rows(V)
    for (i = 1; i <= K; i++)
    {
        com[i] = i
    }
    indx = 1
    while (com[K] <= n ){
        for (i = 1; i <= K; i++)
        {
            //printf("%f ", com[i])
            A[indx,i] = V[com[i]]
        }
        indx = indx+1
        //printf("\n")

        t = K
        while (t != 1 && com[t] == n - K + t)
        {
            t = t - 1
        }
        com[t] = com[t] + 1;
        for (i = t +1; i <= K; i++)
        {
            com[i] = com[i-1] + 1
        }
    }

    return(A)
}
mata mosave nchoosek(), dir(functions) replace


function find(V)
{
    // FInds the first nonzero index of a col vector V
    indx = NULL
    for (i=1; i <= rows(V); i++){
	if (V[i] != 0){
	    indx = i
	    break
	}
    }

    return(indx)
}
mata mosave find(), dir(functions) replace

real matrix function ismember(real matrix A, real matrix B, real scalar r){
    //For array and A and B of same number of cols
    //returns an array of the same size as
    // A where A is in B = 1 0 otherwise
    // r == 1 compares rows.  If r == 0 it will return (rows(A), cols(A))
    // where result[i,j] = 1 if A[i,j] == B[i,j] else 0
    // NOTE: r==1 is only supported when A and B are same size
    if (r == 1){
        res = J(rows(A), 1, .)
        for (i = 1; i <= rows(A); i++){
            if (sum(A[i,.] :== B[i,.]) == cols(A)) res[i] = 1
            else res[i] = 0
        }
    }else{
        res = A :== B[., (1..cols(A))]
    }
    return(res)
}
mata mosave ismember(), dir(functions) replace

end
