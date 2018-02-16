# TODO: Add comment
#
# Author: Simon
###############################################################################



spectral.bw <- function(WL)
{
	bw <- 16.06*4.72e-4*(400./WL)^4.32
	return(bw)
}

