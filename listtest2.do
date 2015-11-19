clear all
set seed 42
cd "/home/joseph/mht/data"
insheet using data.csv, comma names

//Creating outcome variable
gen amountmat = amount * ratio

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
select = mdarray((numoc, numsub, numpc), 1)


//Parameters set by the function
n = rows(Y)
B = 100000

// comput the studentized difference in means
// for all the hypothises based on actual data

meanact = mdarray((numoc, numsub, numg+1), 0)
varact = mdarray((numoc, numsub, numg+1), 0)
Nact= mdarray((numoc, numsub, numg+1), 0)

for (i=1; i <= numoc; i++)
{
	for (j=1; j<=numsub; j++)
	{
		for (k=0; k<=numg; k++)
		{
			w = (sub :== j :& D :== k)
			put(mean(Y[.,i], w), meanact, (i,j,k+1))
			put(variance(Y[.,i], w), varact, (i, j, k+1))
			CP = quadcross(w,0, Y[.,i],1)
			put(CP[cols(CP)], Nact, (i, j, k+1))
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
statsboot= mdarray((B, numoc, numsub, numpc), 0)
meanboot = mdarray((numoc, numsub, numg+1), 0)
varboot = mdarray((numoc, numsub, numg+1), 0)
Nboot = mdarray((numoc, numsub, numg+1), 0)

for (i=1; i <= B; i++)
{
	Yboot = Y[idboot[.,i], .]
	subboot = sub[idboot[.,i], .]
	Dboot = D[idboot[.,i], .]
	for (j=1; j <= numoc; j++)
	{
		for (k=1; k <= numsub; k++)
		{
			for (l=0; l <= numg; l++)
			{
				w = (subboot :==k :& Dboot :== l)
				put(mean(Yboot[.,j], w), meanboot, (j, k, l+1))
				put(variance(Yboot[.,j], w), varboot, (j,k,l+1))
				CP = quadcross(w, 0, Yboot[.,j] , 1)
				put(CP[cols(CP)], Nboot, (j, k, l+1))
			}
		}
	}
}

end
