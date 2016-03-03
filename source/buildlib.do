//Creates a library of the functions required for the listetal command.  Move the create file
// to the current working directory.  Either restart stata or index the file
// mata: mata mlib index

clear all

// If you are compiling this file yourself
// change the line below to reflect your version of stata
// ie, version 12 users would set "version 12"
version 14

do functions.mata
do seidelxu.mata

mata:

mata mlib create lmhtexp, replace
mata mlib add lmhtexp *()


//mata mlib index

end
