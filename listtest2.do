clear all
set seed 42
cd "/home/joseph/mht/data"
insheet using data.csv, comma names

//Creating outcome variable
gen amountmat = amount * ratio

mata:
function mdarray(r, c, n, fill)
{
	a = J(n,1,NULL)
	for (i=1; i<=rows(a); i++)
	{
		for (j=1; j<=cols(a); j++)
		{
			a[i,j] = &J(r,c,fill)
		}
	}
	return(a)
}

function n3darray( rowvec, fill )
{
 	dim = cols(rowvec)
	A = asarray_create("real", dim)
	for (k = 1; k <= rowvec[1,3]; k++)
	{
		asarray(A, (.,., k), J(rowvec[1,1], rowvec[1,2], fill))
	}
	return(A)
}

function n4darray( rowvec, fill )
{
 	dim = cols(rowvec)
	A = asarray_create("real", dim)
	for (k = 1; k <= rowvec[1,3]; k++)
	{
		for (l = 1; l <= rowvec[1,4]; l++)
		{
			asarray(A, (.,., k, l), J(rowvec[1,1], rowvec[1,2], fill))
		}
	}

	return(A)
}

function put(val,x,i,j,k)
{
	/* Usage: value to put, matrix to put it in, i,j of dimension k, to put it at.*/
	(*(x[k,1]))[i,j]=val
}

function get(x,i,j,k)
{
	/* Usage: matrix to get from, i,j of dimension k, of value to get. */
	return((*(x[k,1]))[i,j])
}

// Parameters for the listetal. ex.1

// USER SHOULD ULTIMATELY SPECIFY THE STATA DATA COLUMNS TO USE
Y = st_data(.,("gave", "amount", "amountmat", "amountchange"))
D = st_data(.,("treatment"))
sub = J(rows(D), 1,1) // If multiple it should created egen groupid = group(group1, group2, group3, etc)
numoc = cols(Y)
numsub = rows(uniqrows(sub))
numg=rows(uniqrows(D)) -1
combo = (J(numg,1,0), (1::numg))
numpc=rows(combo)
select = mdarray(numoc, numsub, numpc, 1)


//Parameters set by the function
n = rows(Y)
B = 3000

// comput the studentized difference in means
// for all the hypothises based on actual data

meanact = mdarray(numoc, numsub, numg+1, 0)
varact = mdarray(numoc, numsub, numg+1, 0)
Nact=mdarray(numoc, numsub, numg+1, 0)

for (i=1; i <= numoc; i++)
{
	for (j=1; j<=numsub; j++)
	{
		for (k=0; k<=numg; k++)
		{
			w = (sub :== j :& D :== k)
			put(mean(Y[.,i], w), meanact, i,j,k+1)
			put(variance(Y[.,i], w), varact, i, j, k+1)
			CP = quadcross(w,0, Y[.,i],1)
			put(CP[cols(CP)], Nact, i, j, k+1)
		}
	}
}

// I have no idea what will happen when this ends up being a n-dimension matrix
diffact = *meanact[combo[.,1]+J(numpc,1,1),1] - *meanact[combo[.,2]+J(numpc,1,1),1]
abdiffact = abs(diffact)
ones = J(numpc,1,1)
statsact = abdiffact :/ sqrt(*varact[combo[.,1]+ones,1] :/ *Nact[combo[.,1]+ones,1] ///
	+ *varact[combo[.,2]+ones,1] :/ *Nact[combo[.,2]+ones,1])

/*
** Construct boostrap samples and computes the test
** stastics and the corresponding 1-p values for each
** simulated sample
*/

rseed(0)
idboot =  floor(runiform(n,  B, 1, n))

end
