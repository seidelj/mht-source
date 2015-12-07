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

transmorphic scalar function find(transmorphic vector V)
{
    // FInds the first nonzero index of a col vector V
    indx = NULL
	if (rows(V) <= 1){
		counter = cols(V)
	}else{
		counter = rows(V)
	}
    for (i=1; i <= counter; i++){
	if (V[i] != 0){
	    indx = i
	    break
	}
    }

    return(indx)
}

real matrix function ismember(real matrix A, real matrix B, real scalar r){
    //For array and A and B of same number of cols
    //returns an array of the same size as
    // A where A is in B = 1 0 otherwise
    // r == 1 compares rows.  If r == 0, then A and B should be rowvectors and it will return
	// it will return (1 x cols(A)) or cols(B)) whichever is smaller
    // where result[i,j] = 1 if A[i,j] == B[i,j] else 0
    // NOTE: r==1 is only supported when A and B are same size
    if (r == 1){
        res = J(rows(A), 1, .)
        for (i = 1; i <= rows(A); i++){
            if (sum(A[i,.] :== B[i,.]) == cols(A)) res[i] = 1
            else res[i] = 0
        }
    }else{
		if (cols(A) < cols(B)){
			small = A
			large = B
		}else{
			small = B
			large = A
		}
		res = J(cols(small), 1, .)
		for (i = 1; i <= cols(small); i++){
			test = small[i] :== large
			if (sum(test) >= 1 ){
				res[i] = 1
			}else{
				res[i] = 0
			}
		}
    }
    return(res)
}

function mat2cell(A, rowD, colD){
	/// the sum of rowD must equal the cols(A)
	/// the sum of colD must equal rows(A)
	rowcount = 1
	colcount = 1
	matcell = asarray_create("real", 2)
	for (i = 1; i <= cols(rowD); i++){
		for (j = 1; j <= cols(colD); j++){
			cell = A[rowcount::rowcount + rowD[i]-1, colcount..colcount + colD[j] -1]
			asarray(matcell, (i,j), cell)
			colcount = cols(cell) + 1
		}
		colcount = 1
		rowcount = rowcount + rows(cell)
	}

	return(matcell)
}

void function buildoutput(string scalar name, real matrix output){
    headers = ("outcome","subgroup","treatment1","treatment2","diff_in_means","Remark3_1","Thm3_1", "Remark3_7", "Bonf","Holm")
    blanks = J(cols(headers), 1, "")

    headersmatrix = (blanks, headers')
    st_matrix(name, output)
    st_matrixcolstripe(name, headersmatrix)
}

end
