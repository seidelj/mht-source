
headers = ("outcome","subgroup","treatment1","treatment2","diff_in_means","Thm2_2", "Remark2_1", "single_testing","Bonf","Holm")
blanks = J(cols(headers), 1, "")

headersmatrix = (blanks, headers')

st_matrix("mht", mht)
st_matrixcolstripe("mht", headersmatrix)
