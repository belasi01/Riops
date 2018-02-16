# TODO: Add comment
#
# Author: Simon
###############################################################################

spectral.aw  <- function(WL, MOREL=FALSE)
{

  if (MOREL) {
    Kw <- spline(KDTable_MM01$V1, KDTable_MM01$V2,  xout=WL, method="natural")
    aw <-  Kw$y - spectral.bw(WL)*0.5
    return(aw)
  } else {
    aw <- spline(AWTable$V1, AWTable$V2,  xout=WL, method="natural")$y
    return(aw)
  }

}

