//Creates a library of the functions required for the listetal command.  Move the create file
// to the current working directory.  Either restart stata or index the file
// mata: mata mlib index

clear all

do functions.mata
do seidelxu.mata

mata:

mata mlib create llistetal, replace
mata mlib add llistetal *()
//mata mlib index

end
