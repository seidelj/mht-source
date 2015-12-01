mata:

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
