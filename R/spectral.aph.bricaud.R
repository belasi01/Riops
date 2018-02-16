#' Compute spectral phyotplankton absorption
#' using Bricaud et al (1995, 1998) statistics
#' for case 1 waters


spectral.aph.bricaud <- function(wl,chl) {


  A_phy <-  spline(AphyTable$V1, AphyTable$V2,  xout=wl, method="natural")

  E_phy <-  spline(AphyTable$V1, AphyTable$V3,  xout=wl, method="natural")

  aPHY <- A_phy$y * chl ^ E_phy$y

  return(aPHY)
}
