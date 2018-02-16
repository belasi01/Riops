#' 
#' Return CDOM spectra using exponential model
#' 
#' 
spectral.cdom <- function(wl, a.ref, wl.ref=440, S=0.018, K=0.0) {
  CDOM = a.ref * exp(-S*(wl-wl.ref)) + K
  return(CDOM)
}