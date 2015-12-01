mata:

function nchoosek(V, K)
{
    // Creates a N!/K!(N-K)! by K array where N = length of colvector b
    // of all unique combinatons of length K found on V.
    A = NULL
    for (i=1; i<=cols(V); i++){
        for (j = i+1; j <= cols(V); j++){
            if (A == NULL) A = (V[1,i], V[1,j])
            else A = A \ (V[1,i], V[1,j])
        }
    }
    return(A)
}

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
            printf("%f ", com[i])
            A[indx,i] = com[i]
        }
        indx = indx+1
        printf("\n")

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


V = (0, 0, 1, 0, 0)'

result = find(V)

end
