#' Spectral backscattering coefficient
#'
#'
spectral.bbp <- function(wl, bbp.ref=0.004, wl.ref=550, nu=1.0) {
  bbp <- bbp.ref*(wl/wl.ref)^-nu
  return(bbp)
}
