#' Analyse A-sphere blank (Pure Water) data
#'
#' @param filen is the ASPH file name of the pure water measurement
#' @param Twater is the pure water temperature during the calibration
#' experiment on the field
#' @param  Tref is the pure water temperature reported by Hobilabs during
#' the ASPH calibration.
#'
#' @details  The user will be prompted to select the files and to click on a plot to
#' select a portion of the file (start and end) where the "a" values were stable
#' and minimum. The program will average and smooth the spectral a values
#' for the selected portion and stored them in a RData file (i.e. ASPH.blank list).
#'
#' The RData file could be used in the data processing for ASPH blank correction
#' in \code{\link{correct.merge.IOP.profile}}. The path of the file need to be
#' included in the cal.info.dat (see \code{\link{correct.merge.IOP.profile}}).
#'
#' NOTE: In September 2015, Hobi Service issued a new method to perform a pure water calibration
#' using RadSoft. This method allows the user to change the calibration files directly.
#'
#' @return It returns a list with mean, smooth, sd
#'
#' @author Simon Belanger
#' @export

analyse.ASPH.blank <- function(filen, Twater=13.2, Tref=19) {
  ASPH = read.ASPH(filen)

  ############################### Apply correction for Temperature ##############################
  # create a matrix of coefficients for ASPH
  PsiT = spline(Tdf$wavelength, Tdf$PsiT, xout=ASPH$wl,method="natural")$y


  PsiTm = matrix(PsiT, nrow=length(ASPH$depth), ncol=length(ASPH$wl), byrow=T)
  delta_T = (Twater-Tref)
  delta_Tm = matrix(delta_T, nrow=length(ASPH$depth), ncol=length(ASPH$wl), byrow=F)

  Tcor_factor = PsiTm * delta_Tm

  ASPH$a.Tcor = ASPH$a - Tcor_factor

  plot(ASPH$time, ASPH$a.Tcor[,10], type = "l", ylim=c(-0.05, 0.05))
  lines(ASPH$time, ASPH$a.Tcor[,30], col=2)
  lines(ASPH$time, ASPH$a.Tcor[,50], col=3)
  lines(ASPH$time, ASPH$a.Tcor[,80], col=4)
  lines(ASPH$time, ASPH$a.Tcor[,100], col=5)
  lines(ASPH$time, ASPH$a.Tcor[,150], col=6)
  lines(ASPH$time, ASPH$a.Tcor[,200], col=7)
  lines(ASPH$time, ASPH$a.Tcor[,250], col=8)


  print("Click for Start on black line")
  ixmin = identify(ASPH$time, ASPH$a.Tcor[,10])
  print("Click for End")
  ixmax = identify(ASPH$time, ASPH$a.Tcor[,10])

  blank.mean = apply(ASPH$a.Tcor[ixmin:ixmax,],2,mean, na.rm=T)
  blank.sd   = apply(ASPH$a.Tcor[ixmin:ixmax,],2,sd, na.rm=T)
  plot(ASPH$wl, blank.mean, pch=20)

  df = as.data.frame(cbind(ASPH$wl, blank.mean))
  names(df) = c("wl","a")
  mod = loess(a ~ wl, data=df, span=0.05)
  blank.mean.smooth = predict(mod, ASPH$wl)
  lines(ASPH$wl, blank.mean.smooth, col=3)
  #blank.mean.smooth[ASPH$wl > 720] = -0.008

  lines(ASPH$wl, blank.mean.smooth, col=2)

  ASPH.blank = list(mean=blank.mean, smooth=blank.mean.smooth, sd=blank.sd)

  basename = unlist(str_split(filen, ".txt"))[1]
  save(file=paste(basename, ".RData", sep=""), ASPH.blank)

  return(ASPH.blank)

}
