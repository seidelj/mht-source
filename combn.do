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

end
