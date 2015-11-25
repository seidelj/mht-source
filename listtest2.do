clear all
cd "/home/joseph/mht/data"
insheet using data.csv, comma names

//Creating outcome variable
gen amountmat = amount * ratio
egen groupids = group(redcty red0)
cd
cd mht
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


//function listetal(Y, sub, D, combo, select ){
// Parameters for the listetal. ex.5
Y = st_data(.,("gave", "amount", "amountmat", "amountchange"))
D = st_data(.,("ratio"))
sub = st_data(., ("groupids"))
numoc = cols(Y)
numsub = rows(uniqrows(sub))
numg=rows(uniqrows(D)) - 1
combo = (J(numg,1,0), (1::numg))
numpc=rows(combo)
select = mdarray((numoc, numsub, numpc), 1)



//Parameters set by the function
n = rows(Y)
B = 3000
numoc = cols(Y)
numsub = rows(uniqrows(sub))
numg=rows(uniqrows(D)) - 1
numpc=rows(combo)

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

diffact = mdarray((numoc, numsub, numpc), .)
abdiffact = mdarray((numoc, numsub, numpc), .)
statsact = mdarray((numoc, numsub, numpc), .)

// I have no idea what will happen when this ends up being a n-dimension matrix
for (i=1; i <=rows(combo); i++){
	diff = get(meanact, (.,.,combo[i,1]:+1)) - get(meanact, (.,.,combo[i,2]:+1))
	put(diff, diffact, (.,.,i))
	put(abs(diff), abdiffact, (.,.,i))
	stat = get(abdiffact, (.,.,i)) :/ sqrt(get(varact, (.,.,combo[i,1]:+1)) :/ get(Nact, (.,.,combo[i,1]:+1)) ///
		+ get(varact, (.,.,combo[i,2]:+1)) :/ get(Nact, (.,.,combo[i,2]:+1)))
	put(stat, statsact, (.,.,i))
}
/*
** Construct boostrap samples and computes the test
** stastics and the corresponding 1-p values for each
** simulated sample
*/

rseed(0)
idboot =  floor(runiform(n,  B, 1, n+1))
statsboot= mdarray((B, numoc, numsub, numpc), 0)
meanboot = mdarray((numoc, numsub, numg+1), 0)
varboot = mdarray((numoc, numsub, numg+1), 0)
Nboot = mdarray((numoc, numsub, numg+1), 0)
diffboot = mdarray((numoc, numsub, numpc),.)

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
				w = (subboot :== k :& Dboot :== l)
				put(mean(Yboot[.,j], w), meanboot, (j, k, l+1))
				put(variance(Yboot[.,j], w), varboot, (j,k,l+1))
				CP = quadcross(w, 0, Yboot[.,j] , 1)
				put(CP[cols(CP)], Nboot, (j, k, l+1))
			}
		}
		mdstatsarr = mdarray((numoc, numsub, rows(combo)), .)
		for (k = 1; k <= rows(combo); k++){
			diff = get(meanboot, (.,.,combo[k,1]:+1)) - get(meanboot, (.,.,combo[k,2]:+1))
			put(diff, diffboot, (.,.,k))
			//(*(diffboot[.,.]))[.,.] = *meanboot[combo[.,1]+J(numpc,1,1),.] - *meanboot[combo[.,2]+J(numpc,1,1),.]

			statsarr = (abs(get(diffboot, (.,.,k)) - get(diffact, (.,.,k))) :/ sqrt(get(varboot, (.,.,combo[k,1]:+1)) :/ get(Nboot, (.,.,combo[k,1]:+ 1)) ///
				+ get(varboot, (.,.,combo[k,2]:+1)) :/ get(Nboot, (.,.,combo[k,2]:+1))))
			//statsarr = (abs((*(diffboot[.,.]))[.,.]-(*(diffact[.,.]))[.,.]) :/ sqrt(*varboot[combo[.,1] + ones, .] :/ *Nboot[combo[.,1]+ ones,.] ///
			//	+ *varboot[combo[.,2] + ones,.] :/ *Nboot[combo[.,2] + ones,.]))'
			put(statsarr, mdstatsarr, (.,., k))
		}
		for (kk=1; kk<=numsub; kk++){
			for (ll=1; ll<=numpc; ll++){
				(*(statsboot[kk,ll]))[i,.] = get(mdstatsarr, (.,.,ll))'[kk,.]
			}
		}
	}
}

pact = mdarray((numoc,numsub, numpc), 0 ) // a matrix of 1-p values of the actual data
pboot = mdarray((B, numoc, numsub, numpc), 0) // a matrix of 1-p values of the simulated data

for (i=1; i<=numoc; i++)
{
	for (j=1; j<=numsub; j++)
	{
		for (k=1; k<=numpc; k++)
		{
			p =	1 - sum(get(statsboot,(.,i,j,k)) :>= get(statsact, (i,j,k)) * J(B,1,1)) / B
			put(p, pact, (i,j,k))
			for (l=1; l<=B; l++)
			{
				sp = 1 - sum(get(statsboot, (.,i,j,k)) :>= get(statsboot, (l,i,j,k)) * J(B,1,1)) / B;
				put(sp, pboot, (l,i,j,k))
			}
		}
	}
}


/* calculate p-values based on single hypothesis testing */

alphasin = mdarray((numoc, numsub, numpc), 0)

for (i=1; i<=numoc; i++)
{
	for (j=1; j<=numsub; j++)
	{
		for (k=1; k<=numpc; k++)
		{
			ptemp =  get(pboot, (.,i,j,k))
			sortp = sort(ptemp, -1)
			v = (get(pact, (i,j,k)) * J(B,1,1 )) :>= sortp
			indx=NULL; where=NULL;
			minindex(v, 1, indx, where)
			q = indx[rows(indx),1]/B
			put(q, alphasin, (i,j,k))
		}
	}
}

psin = mdarray((numoc, numsub, numpc), 0) // p-values based on single hypothesis testing
for (k=1; k<=numpc; k++){
	put(get(alphasin, (.,.,k)), psin, (.,.,k))
}


/* Calculate p-values based on multiple hypothesis tesitng */

nh = 0
for (k=1; k <= numpc; k++)
{
	nh = nh + sum((*(select[k,.]))[.,.])
}
statsall = J(nh, 8+B, 0)

counter=1
for (i=1; i<=numoc; i++)
{
	for (j=1; j<=numsub; j++)
	{
		for (k=1; k<=numpc; k++)
		{
			if ( (*(select[k, .]))[i,j] == 1 ){
				rowvect = (i,j,k)
				statsall[counter, .] = (counter, i, j, combo[k, .], get(abdiffact, rowvect) , get(psin, rowvect), get(pact, rowvect), get(pboot, (., i, j, k))')
				counter = counter + 1
			}
		}
	}
}

statsrank = sort(statsall, 7) // rank the rows according to the p-values based on single hypothesis testin
alphamul = J(nh, 1, 0) // the smallest alpaha that reject the hypothesis based on Theorem 3.1
alphamulm = J(nh, 1, 0) // the smallest alpha's that reject the hypothesis based on Remark 3.7

for (i=1; i<=nh; i++)
{
	maxstats = colmax(statsrank[(i::rows(statsrank)), (9::cols(statsrank))]) // the maxiums of the 1-p values among all the remaining hypotheses for all the simulated samples
	sortmaxstats = sort(maxstats', -1)'
	indx=NULL; where=NULL;
	v = statsrank[i, 8] :>= sortmaxstats
	minindex(v, 1, indx, where)
	q = indx[rows(indx),1]/B
	alphamul[i] = q
	if (i==1) alphamulm=alphamul[i]
	else sortmaxstatsm=J(1,B,0)

/*
Lines 151-215 in lismtetal.m that calculate alpahmu
	for (j=nh-i+1; j >= 1; j--)
		{
			//subset = nchoosek(statsrank[(i::rows(statsrank)), 1], j)
		}
*/

}

bon = rowmin((statsrank[.,7]*nh, J(nh,1,1) ))
holm = rowmin((statsrank[.,7]:*(nh::1), J(nh,1,1)))

output = sort((statsrank[.,(1::7)], bon, holm),1)
output = output[., (2::cols(output))]
headers = ("outcome","subgroup","treatment1","treatment2","diff_in_means","single_testing","Bonf","Holm")



end

cd
cd mht
