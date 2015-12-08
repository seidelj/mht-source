#Multiple Hypothesis Testing
Stata code for procedure detailed in List, Shaikh, Xu 2015

##In stata 
Make sure your current directory contains
* listetal.ado -- this initializes the stata comand "listetal" for usage from the command line or do file
* functions.do -- functions required for listetal.do
* listetal.do -- the actual program that performs computation

See listetal_examples.do for usage example OR from stata termanal type 'help listetal'


####Summary of contents
The matlab directory contains the original matlab code for the procedure provided by Yang.  Anyone interested in using this should be warned that missing values in the "D" parameter of the functions need to be thought through carefully

The data directory contains the data set used in the List et al 2015 paper.

stataoutput.csv are the tables that the stata procedure generates for the dataset in List et al 2015 
