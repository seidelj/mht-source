#Multiple Hypothesis Testing

Source code for procedure detailed in List, Shaikh, Xu 2015.

This repository is intended for those who wish the modify the procedure.  The command for general use can be found [here](https://www.github.com/seidelj/mht).

####To compile mata functions
From the source file, run the buildlib.do file and move the resulting lmhtexp.mlib file to the same dir as the mhtexp.ado file.

####Summary of contents
* seidelxu.mata: primary function for the mht adjustment
* functions.mata: custom mata functions required for seidelxu
* buildlib.do: compiles seidelxu.mata and function.mata to mlib (mata library file), lmhtexp.mlib
* buildlib11.do: Stata11 version 
* data.csv contains the data set used in the List et al 2015 paper.

The matlab directory contains the original matlab code for the procedure provided by Yang.  Anyone interested in using this should be warned that missing values in the "D" parameter of the functions need to be thought through carefully.  In the code provided, we exclude all values of D that are 0 as they would be considered missing based on how the group id were generated.

The data directory contains the data set used in the List et al 2015 paper-- data.csv

stataoutput.csv are the tables that the stata procedure generates for the dataset in List et al 2015 
