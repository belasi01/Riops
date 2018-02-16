#'
#' Return non-algal particles (NAP) spectra using exponential model
#'
#'
spectral.nap <- function(wl, a.ref, wl.ref=440, S=0.018, K=0.0) {
  NAP = a.ref * exp(-S*(wl-wl.ref)) + K
  return(NAP)
}
