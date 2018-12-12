#' Case-1 waters absorption coefficient for Particles and Phyotoplankton
#'
#'@description Compute spectral absorption coefficients for particles and phytoplankton
#' using Bricaud et al (1995, 1998) statistics established for case 1 waters
#'
#' @param waves is the wavelenght (could be a vector)
#' @param chl is the chlorophyll-a concentration
#' @param PHYTO is a logical to compute either phytoplankton
#' or total particles coefficient. Default is PHYTO=TRUE to return the phytoplankton
#' pigments spectrum.
#'
#'
#'@author Simon Belanger
#'
#'@export

spectral.aph.bricaud <- function(waves,chl, PHYTO=TRUE) {
  A_phy <-  spline(AphyTable$V1, AphyTable$V2,  xout=waves, method="natural")
  A_p <-  spline(AphyTable$V1, AphyTable$V4,  xout=waves, method="natural")
  E_phy <-  spline(AphyTable$V1, AphyTable$V3,  xout=waves, method="natural")
  if (PHYTO) return(A_phy$y * chl ^ E_phy$y) else return(A_p$y * chl ^ E_phy$y)
}
