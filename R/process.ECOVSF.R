#'
#' ECO-VSF processing for discrete depth (or profile sampling not implemented yet) 
#' 
#' @param eco is a list containing calibrated VSF data returned by 
#' \code{\link{apply.ECOVSF.cal}}
#' @param station is the station ID
#' @param DateTime is a Date and Time stamp in POSIXct format
#' @param Depth of sampling if data collected in discrete mode
#' @param B.Anw Non-water absorption for the 470 nm band
#' (Default = NA; no correction applied)
#' @param G.Anw Non-water absorption for the 532 nm band
#' (Default = NA; no correction applied)
#' @param Salinity Salinity (Default = 0)
#' @param start is the begining of the cast in seconds. 
#' If 999 then the user is prompt to click on the plot of 
#' VSF versus Time to choose the start and the end of the cast interactively.
#' (Default = 1)
#' @param end is the end of the cast in second. If 999 then it takes
#' the end of the cast. (Default = 999)     
#'
#' @author Simon Belanger
#' @export
#'

process.ECOVSF <- function(eco,
                           station=NA,
                           DateTime,
                           Depth=NA,
                           B.Anw=NA,
                           G.Anw=NA,
                           Salinity=0,
                           start=1,
                           end=999) {

  plot(eco$time, eco$G.Betau[,2], 
       ylim=c(min(eco$G.Betau, na.rm = T), max(eco$G.Betau,  na.rm = T)), 
       pch=19, cex=0.5, 
       main="VSF for the green",
       sub=paste(station, DateTime),
       xlab="time (s)", ylab="uncorrected VSF (/m /sr)")
  points(eco$time, eco$G.Betau[,1], col=2,pch=19,cex=0.5)
  points(eco$time, eco$G.Betau[,3], col=3,pch=19,cex=0.5)
  legend("topleft", c('100',"125","150"), pch=c(19,19,19), col=c(2,1,3))
  
  if (start == 999) {
    print("Click for the begining of the cast and then ESC")
    start <- identify(eco$time, eco$G.Betau[,2])
    print("Click for the end of the cast and then ESC")
    end <- identify(eco$time, eco$G.Betau[,2])
  }
  if (end == 999) {
    end <- length(eco$time)
  }

  
  B.Betau.mean = apply(eco$B.Betau[start:end,],2,mean,na.rm=T)
  G.Betau.mean = apply(eco$G.Betau[start:end,],2,mean,na.rm=T)
  
  B.Betau.sd = apply(eco$B.Betau[start:end,],2,sd,na.rm=T)
  G.Betau.sd = apply(eco$G.Betau[start:end,],2,sd,na.rm=T)
  
   ###### Apply absorption correction
  pathlengh.ECO = c(0.0314, 0.0441, 0.0804) # From Boss et al, JGR 2004
  if (is.na(B.Anw)) {
    print("No absorption correction applied")
    ABS.COR = FALSE
    B.Beta = B.Betau.mean
    G.Beta = G.Betau.mean
  } else {
    B.Beta = B.Betau.mean*exp(B.Anw*pathlengh.ECO)
    G.Beta = G.Betau.mean*exp(G.Anw*pathlengh.ECO)
    ABS.COR = TRUE
  }

  ###### Integrate the VSF
  # bb= 2pi * integrate(beta*sin(angle))
  rad.angle = c(100,125,150,180)*pi/180
  scatangle=seq(pi/2,pi, 0.01)
  B.Beta.mean2=c(B.Beta,0)
  df = data.frame(rad.angle, B.Beta.mean2*sin(rad.angle))
  names(df) <-c("scatangle", "betasin")
  model <- lm(betasin ~ poly(scatangle, 3), data=df)
  yhat=predict(model,data.frame(scatangle))
  fx.linear <- approxfun(scatangle, yhat)
  B.bb.prime = 2*pi*integrate(fx.linear, pi/2, pi, subdivisions=180, stop.on.error = FALSE)[1]$value
  
  # same for the Green
  G.Beta.mean2=c(G.Beta,0)
  df = data.frame(rad.angle, G.Beta.mean2*sin(rad.angle))
  names(df) <-c("scatangle", "betasin")
  model <- lm(betasin ~ poly(scatangle, 3), data=df)
  yhat=predict(model,data.frame(scatangle))
  fx.linear <- approxfun(scatangle, yhat)
  G.bb.prime = 2*pi*integrate(fx.linear, pi/2, pi, subdivisions=180, stop.on.error = FALSE)[1]$value
  
  # correct for salinity
  if (!is.na(Salinity)) {
    bbs = 8.03*((1.41*1.08)*Salinity/37)*1e-4
    B.bb = B.bb.prime - bbs
    G.bb = G.bb.prime - bbs
    SAL.COR <- TRUE 
  } else {
    bbs <- 0 
    B.bb = B.bb.prime - bbs
    G.bb = G.bb.prime - bbs
    SAL.COR <- FALSE 
  }
  
  

  
  return(list(eco.raw=eco,
              waves=c(470,532),
              scattering.angle=c(100,125,150),
              bb=c(B.bb, G.bb),
              bbs=bbs,
              Betau.mean=cbind(B.Betau.mean, G.Betau.mean),
              Betau.sd=cbind(B.Betau.sd, G.Betau.sd),
              Beta=cbind(B.Beta, G.Beta),
              Station=station,
              DateTime=DateTime,
              Depth=Depth,
              B.Anw=B.Anw,
              G.Anw=G.Anw,
              ABS.COR=ABS.COR,
              SAL.COR=SAL.COR,
              Salinity=Salinity,
              start=start,
              end=end))
}