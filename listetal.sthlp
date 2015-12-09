{smcl}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "listetal##syntax"}{...}
{viewerjumpto "Description" "listetal##description"}{...}
{viewerjumpto "Options" "listetal##options"}{...}
{viewerjumpto "Remarks" "listetlal##remarks"}{...}
{viewerjumpto "Examples" "listetal##examples"}{...}
{title:Title}

{phang}
{bf:listetal} {hline 2} Stata command for procedure detailed in List, Shaikh, Xu 2015


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:listetal}
{varlist}
{cmd:, } {it:treatment} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth treatment(varlist)}}treatment status variables {it:varlist}{p_end}
{synopt:{opth subgroup(varname)}}group identifier variable {it:varname}{p_end}
{synopt:{opth combo(string)}}compair "treatmentcontrol" or "pairwise"; default is
    {cmd:combo("treatmentcontrol")}{p_end}
{synopt:{opt select(#)}}the numoc*numsub*numpc hypothesis to be tested;
    default is all numoc*numsub*numpc {cmd:select(1)}{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:listetal} testing procedure for multiple hypothesis testing that asymptotically controls familywise error rate and is asymptotically balanced for outcomes specified via {varlist}{p_end}

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt treatment(varlist)} user provided variable containing treatment status of the observations; required.{p_end}

{phang}
{opt subgroup(varname)} user provided variable containing subgroup ids; optional.{p_end}

{phang}
{opt combo(string)} user provided string to specify the comparison between treatment and control.  {cmd:combo("pairwise")} will compare all pairwise comparisons across treatment and control. The default is {cmd:combo("treatmentcontrol")}, compares each treatment to the control; optional
{p_end}

{phang}
{opt select(#)} integer to specify which hypothesis to be tested.{p_end}
{phang2}
{cmd:. select(1)} jointly identifies treatment effects for outcomes, estimate heterogenous treatment effects through subgroups, hypothesis testing for multiple treatments{p_end}
{phang2}
{cmd:. select(2)} outcomes and subgroups{p_end}
{phang2}
{cmd:. select(3)} outcomes and treatment effects{p_end}
{phang2}
{cmd:. select(4)} subgroups and treatment effects{p_end}
{phang}
the default is {cmd:select(1)}; optional{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
For detailed information on the procedure, see URL Multiple Hypothesis Testing in Experimental Economics.{p_end}

{pstd}
If you are running the command for the first time and receive an error message claiming certain functions are not found, ie nchoosek(), make sure that llistetal.mlib exists in your current dir and enter the command{p_end}
{phang2}
{cmd:. mata: mata mlib index}{p_end}
{pstd}
Which tells Stata to look in llistetal.mlib for mata functions that are required to run the command{p_end}

{marker examples}{...}
{title:Examples}
{pstd}
Suppose a data set containing. You can access this dataset at github.com/seidelj/mht "data/data.csv"{p_end}

{phang} outcome variables {it:gave amount  amountchange}{p_end}
{phang} treatment variables {it: treatment ratio}{p_end}

{pstd}
Setup{p_end}
{phang} {cmd:. gen amountmat = amount * ratio }{p_end}
{phang} {cmd:. gen groupid = (redcty==1 & red0 == 1) + (redcty==0 & red0 == 1)*2 + (redcty==0 & red0 == 0)*3 + (redcty==1 & red0 == 0)*4}{p_end}
{phang} {cmd:. replace groupid = . if groupid == 0 }{p_end}

{pstd}
Hypothesis testing with multiple outcomes{p_end}
{phang}{cmd:. listetal gave amount amountmat amountchange, treatment(treatment) }{p_end}

{pstd}
Hypothesis testing with multiple subgroups{p_end}
{phang}{cmd:. listetal gave, treatment(treatment) subgroup(groupid) }{p_end}

{pstd}
Hypothesis testing with multiple treatments{p_end}
{phang}{cmd:. listetal amount, treatment(ratio) }

{pstd}
Hypothesis testing for all pairwise comparisons among the treatment and control groups{p_end}
{phang}{cmd:. listetal amount, treatment(ratio) combo("pairwise") }

{pstd}
Hypothesis testing with multiple outcomes, subgroups and treatments{p_end}
{phang}{cmd:. listetal gave amount amountmat amountchange, subgroup(groupid) treatment(ratio) }{p_end}
