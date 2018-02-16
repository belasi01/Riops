#'
#'@title Pure water scattering coefficient spectrum
#'
#'
#'@description Compute spectral scattering coefficient for pure water Morel 1974 (as summarized by Mobley 1994)
#'
#' @param waves is the wavelenght (could be a vector)
#'
#'@author Simon Bélanger
#'
#'@export

spectral.bw <- function(waves)
{
	bw <- 16.06*4.72e-4*(400./waves)^4.32
	return(bw)
}

