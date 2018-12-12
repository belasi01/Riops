#' Analyse AC-s blank (Pure Water) data
#'
#' @param Twater is the pure water temperature during the calibration
#' experiment on the field
#' @param  Tref is the pure water temperature reported by Wet Labs during
#' the ACs calibration.
#' @param  AC is a logical parameter indicating whether or not the a-beam
#' and c-beam were calibrated at the same time on the field. If TRUE, it will
#' assumes that both beams were calibrated at the same time and the user
#' will be prompted to select only one file. If FALSE, each beam was calibrated
#' separately and the user will be prompted to select one file for a-beam calibration
#' and one file for c-beam calibration.
#'
#' @details  The user will be prompted to select the files and to click on a plot to
#' select a portion of the file (start and end) where a or c values were stable
#' and minimum. The program will average and smooth the spectral a and c values
#' for the selected portion and stored them in a RData file (i.e. ACS.blank list).
#'
#' The RData file could be used in the data processing for ACs blank correction
#' in \code{\link{correct.merge.IOP.profile}}. The path of the file need to be
#' included in the cal.info.dat (see \code{\link{correct.merge.IOP.profile}})
#'
#' @return It returns a list with a.mean, a.smooth, a.sd,
#' c.mean, c.smooth, c.sd, c.wl, a.wl
#'
#' @author Simon Belanger
#' @export
#' 

analyse.ACs.blank <- function (Twater = 19, 
                               Tref = 20.3, 
                               AC=TRUE) {


  delta_T = (Twater-Tref)


  if (AC) {

    print("Select an ACs file of pure water calibration")
    filename = file.choose()
    ACS = read.ACs.blank(filename)

    # create a matrix of coefficients for ACS
    PsiT = spline(TS4.cor.df$wavelength, TS4.cor.df$PsiT, xout=ACS$a.wl,method="natural")$y
    PsiTm = matrix(PsiT, nrow=length(ACS$Timer), ncol=length(ACS$a.wl), byrow=T)
    delta_Tm = matrix(delta_T, nrow=length(ACS$Timer), ncol=length(ACS$a.wl), byrow=F)
    Tcor_factor = PsiTm * delta_Tm

    ACS$a.Tcor = ACS$a - Tcor_factor

    PsiT = spline(TS4.cor.df$wavelength, TS4.cor.df$PsiT, xout=ACS$c.wl,method="natural")$y
    PsiTm = matrix(PsiT, nrow=length(ACS$Timer), ncol=length(ACS$c.wl), byrow=T)
    Tcor_factor = PsiTm * delta_Tm

    ACS$c.Tcor = ACS$c - Tcor_factor

    plot(ACS$Timer, ACS$a.Tcor[,1], type = "l", ylim=c(-0.2, 0.2))
    lines(ACS$Timer, ACS$a.Tcor[,10], col=2)
    lines(ACS$Timer, ACS$a.Tcor[,20], col=3)
    lines(ACS$Timer, ACS$a.Tcor[,30], col=4)
    lines(ACS$Timer, ACS$a.Tcor[,40], col=5)
    lines(ACS$Timer, ACS$a.Tcor[,50], col=6)
    lines(ACS$Timer, ACS$a.Tcor[,60], col=7)
    lines(ACS$Timer, ACS$a.Tcor[,70], col=8)

    lines(ACS$Timer, ACS$c.Tcor[,10], col=2, lty=2)
    lines(ACS$Timer, ACS$c.Tcor[,20], col=3, lty=2)
    lines(ACS$Timer, ACS$c.Tcor[,30], col=4, lty=2)
    lines(ACS$Timer, ACS$c.Tcor[,40], col=5, lty=2)
    lines(ACS$Timer, ACS$c.Tcor[,50], col=6, lty=2)
    lines(ACS$Timer, ACS$c.Tcor[,60], col=7, lty=2)
    lines(ACS$Timer, ACS$c.Tcor[,70], col=8, lty=2)


    print("Click for Start")
    ixmin = identify(ACS$Timer, ACS$a.Tcor[,1])
    print("Click for End")
    ixmax = identify(ACS$Timer, ACS$a.Tcor[,1])

    a.blank.mean = apply(ACS$a.Tcor[ixmin:ixmax,],2,mean, na.rm=T)
    a.blank.sd   = apply(ACS$a.Tcor[ixmin:ixmax,],2,sd, na.rm=T)


    c.blank.mean = apply(ACS$c.Tcor[ixmin:ixmax,],2,mean, na.rm=T)
    c.blank.sd   = apply(ACS$c.Tcor[ixmin:ixmax,],2,sd, na.rm=T)

    c.wl = ACS$c.wl
    a.wl = ACS$a.wl

  } else {

    print ("Select the file for beam-c calibration")
    filename = file.choose()
    CS = read.ACs.blank(filename)

    # create a matrix of coefficients for correction
    PsiT = spline(TS4.cor.df$wavelength, TS4.cor.df$PsiT, xout=CS$c.wl,method="natural")$y
    PsiTm = matrix(PsiT, nrow=length(CS$Timer), ncol=length(CS$c.wl), byrow=T)
    delta_Tm = matrix(delta_T, nrow=length(CS$Timer), ncol=length(CS$c.wl), byrow=F)
    Tcor_factor = PsiTm * delta_Tm

    CS$c.Tcor = CS$c - Tcor_factor

    plot(CS$Timer, CS$c.Tcor[,1], type = "l", ylim=c(-0.2,0.2))
    lines(CS$Timer, CS$c.Tcor[,10], col=2, lty=2)
    lines(CS$Timer, CS$c.Tcor[,20], col=3, lty=2)
    lines(CS$Timer, CS$c.Tcor[,30], col=4, lty=2)
    lines(CS$Timer, CS$c.Tcor[,40], col=5, lty=2)
    lines(CS$Timer, CS$c.Tcor[,50], col=6, lty=2)
    lines(CS$Timer, CS$c.Tcor[,60], col=7, lty=2)
    lines(CS$Timer, CS$c.Tcor[,70], col=8, lty=2)


    print("Click for Start")
    ixmin = identify(CS$Timer, CS$c.Tcor[,1])
    print("Click for End")
    ixmax = identify(CS$Timer, CS$c.Tcor[,1])

    c.blank.mean = apply(CS$c.Tcor[ixmin:ixmax,],2,mean, na.rm=T)
    c.blank.sd   = apply(CS$c.Tcor[ixmin:ixmax,],2,sd, na.rm=T)


    print ("Select the file for beam-a calibration")
    filename = file.choose()
    AS = read.ACs.blank(filename)

    # create a matrix of coefficients for correction
    PsiT = spline(TS4.cor.df$wavelength, TS4.cor.df$PsiT, xout=AS$a.wl,method="natural")$y
    PsiTm = matrix(PsiT, nrow=length(AS$Timer), ncol=length(AS$a.wl), byrow=T)
    delta_Tm = matrix(delta_T, nrow=length(AS$Timer), ncol=length(AS$a.wl), byrow=F)
    Tcor_factor = PsiTm * delta_Tm

    AS$a.Tcor = AS$a - Tcor_factor

    plot(AS$Timer, AS$a.Tcor[,1], type = "l", ylim=c(-0.2,0.2))
    lines(AS$Timer, AS$a.Tcor[,10], col=2, lty=2)
    lines(AS$Timer, AS$a.Tcor[,20], col=3, lty=2)
    lines(AS$Timer, AS$a.Tcor[,30], col=4, lty=2)
    lines(AS$Timer, AS$a.Tcor[,40], col=5, lty=2)
    lines(AS$Timer, AS$a.Tcor[,50], col=6, lty=2)
    lines(AS$Timer, AS$a.Tcor[,60], col=7, lty=2)
    lines(AS$Timer, AS$a.Tcor[,70], col=8, lty=2)


    print("Click for Start")
    ixmin = identify(AS$Timer, AS$a.Tcor[,1])
    print("Click for End")
    ixmax = identify(AS$Timer, AS$a.Tcor[,1])

    a.blank.mean = apply(AS$a.Tcor[ixmin:ixmax,],2,mean, na.rm=T)
    a.blank.sd   = apply(AS$a.Tcor[ixmin:ixmax,],2,sd, na.rm=T)

    c.wl = CS$c.wl
    a.wl = AS$a.wl

  }



  plot(c.wl, c.blank.mean, pch=20,
       ylim=c(min(c(c.blank.mean,a.blank.mean)), max(c(c.blank.mean,a.blank.mean))))
  points(a.wl, a.blank.mean, pch=20, col=2)


  df = as.data.frame(cbind(a.wl, a.blank.mean))
  names(df) = c("wl","a")
  mod = loess(a ~ wl, data=df, span=0.1)
  a.blank.mean.smooth = predict(mod, a.wl)
  lines(a.wl, a.blank.mean.smooth, col=2)

  df = as.data.frame(cbind(c.wl, c.blank.mean))
  names(df) = c("wl","c")
  mod = loess(c ~ wl, data=df, span=0.1)
  c.blank.mean.smooth = predict(mod, c.wl)
  lines(CS$c.wl, c.blank.mean.smooth, col=1)

  ACS.blank = list(a.mean=a.blank.mean, a.smooth=a.blank.mean.smooth, a.sd=a.blank.sd,
                   c.mean=c.blank.mean, c.smooth=c.blank.mean.smooth, c.sd=c.blank.sd,
                   c.wl = c.wl, a.wl = a.wl)

  save(file=paste(filename, ".RData", sep=""), ACS.blank)


  return(ACS.blank)
}




