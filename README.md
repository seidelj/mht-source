#Multiple Hypothesis Testing
Source Stata code for procedure detailed in List, Shaikh, Xu 2015

Source code for the mata functions used in listetl Stata command.

From the source file, run the buildlib.do file and move the resulting llistetal.mlib file to the same dir as the .ado file.

The ado file is defined in seidelj/mht

####Summary of contents
The matlab directory contains the original matlab code for the procedure provided by Yang.  Anyone interested in using this should be warned that missing values in the "D" parameter of the functions need to be thought through carefully.  In the code provided, we exclude all values of D that are 0 as they would be considered missing based on how the group id were generated.

The data directory contains the data set used in the List et al 2015 paper.

stataoutput.csv are the tables that the stata procedure generates for the dataset in List et al 2015 
