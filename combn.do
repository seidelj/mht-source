mata:

function nchoosek(V, K)
{
    A = NULL
    iterations = comb(cols(V), K)
    for (i=1; i<=iterations; i++){
        for (j = i+1; j <= iterations; j++){
            if (A == NULL) A = (i, j)
            else A = A \ (i, j)
        }
    }
    return(A)
}

A = nchoosek((1,2,3), 2)

end
