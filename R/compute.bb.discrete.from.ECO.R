#'
#' Backscattering processing from ECO sensor at discrete depth
#' 
#' @param eco is a list containing calibrated VSF data returned by 
#' \code{\link{apply.ECO.cal}}
#' @param ECO.type is a character string for the type of ECO meter: BB9, BB3, VSF3.
#' (Default is VSF3)
#' @param ECO.bands must be provided if ECO.type == VSF3. It is a character string indicating the bands (BLUE, GREEN and RED), 
#' i.e. either "B", "G", "R" or "BG", or "BGR". 
#' @param Station is the station ID
#' @param DateTime is a Date and Time stamp in POSIXct format
#' @param Depth of sampling if data collected in discrete mode
#' @param Anw Non-water absorption for the corresponding bands of the ECO meter. 
#' @param Salinity Salinity (Default = 0)
#' @param start is the begining of the cast in seconds after the instrument warming period.  
#' If 999 then the user is prompt to click on the plot of 
#' VSF versus Time to choose the start and the end of the cast interactively.
#' (Default = 1)
#' @param end is the end of the cast in second. If 999 then it takes
#' the end of the cast. (Default = 999)     
#'
#' @author Simon Belanger
#' @export 

compute.bb.discrete.from.ECO <- function(eco,
                                         ECO.type="VFS3",
                                         ECO.bands=NA,
                                         Station=NA,
                                         DateTime,
                                         Depth=NA,
                                         Anw=NA,
                                         Salinity=0,
                                         start=999,
                                         end=999){
   
  if (ECO.type == "VSF3") {
    if (is.na(ECO.bands)) {
      print("No ECO.bands provided")
      print("Please add ECO.bands='B' or 'G' or 'R' or 'BG'")
      print("Abort processing")
      return(0)
    } 
    if (ECO.bands =="B") {
      plot(eco$time, eco$B.Betau[,2], 
           ylim=c(min(eco$B.Betau, na.rm = T), max(eco$B.Betau,  na.rm = T)), 
           pch=19, cex=0.5, 
           main="VSF for the blue",
           sub=paste(Station, DateTime),
           xlab="time (s)", ylab="uncorrected VSF (/m /sr)")
      points(eco$time, eco$B.Betau[,1], col=2,pch=19,cex=0.5)
      points(eco$time, eco$B.Betau[,3], col=3,pch=19,cex=0.5)
      legend("topleft", c('100',"125","150"), pch=c(19,19,19), col=c(2,1,3))
      
      if (start == 999) {
        print("Click for the begining of the cast and then ESC")
        start <- identify(eco$time, eco$B.Betau[,2])
        print("Click for the end of the cast and then ESC")
        end <- identify(eco$time, eco$B.Betau[,2])
      }
      if (end == 999) {
        end <- length(eco$time)
      }
      
      B.Betau.mean = apply(eco$B.Betau[start:end,],2,mean,na.rm=T)
      B.Betau.sd = apply(eco$B.Betau[start:end,],2,sd,na.rm=T)
      
      ###### Apply absorption correction
      pathlengh.ECO = c(0.0314, 0.0441, 0.0804) # From Boss et al, JGR 2004
      if (is.na(Anw[1])) {
        print("Non-water absorption for Blue band not provided")
        print("No absorption correction applied")
        ABS.COR = FALSE
        B.Beta = B.Betau.mean
      } else {
        B.Beta = B.Betau.mean*exp(Anw[1]*pathlengh.ECO)
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
    
      # correct for salinity
      if (!is.na(Salinity)) {
        bbs = 8.03*((1.41*1.08)*Salinity/37)*1e-4
        B.bb = B.bb.prime - bbs
        SAL.COR <- TRUE 
      } else {
        bbs <- 0 
        B.bb = B.bb.prime - bbs
        SAL.COR <- FALSE 
      }
      
      bbW = (0.0029308*(470/500)^-4.24)/2
      B.bbP <- B.bb - bbW
      
      return(list(eco.raw=eco,
                  waves=470,
                  scattering.angle=c(100,125,150),
                  bb=B.bb,
                  bbP=B.bbP,
                  bbs=bbs,
                  Betau.mean=B.Betau.mean,
                  Betau.sd=B.Betau.sd,
                  Beta=B.Beta,
                  Station=Station,
                  DateTime=DateTime,
                  Depth=Depth,
                  Anw=Anw,
                  ABS.COR=ABS.COR,
                  SAL.COR=SAL.COR,
                  Salinity=Salinity,
                  start=start,
                  end=end))
    }
    if (ECO.bands =="G") {
      plot(eco$time, eco$G.Betau[,2], 
           ylim=c(min(eco$G.Betau, na.rm = T), max(eco$G.Betau,  na.rm = T)), 
           pch=19, cex=0.5, 
           main="VSF for the green",
           sub=paste(Station, DateTime),
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
      
      G.Betau.mean = apply(eco$G.Betau[start:end,],2,mean,na.rm=T)
    
      G.Betau.sd = apply(eco$G.Betau[start:end,],2,sd,na.rm=T)
      
      ###### Apply absorption correction
      pathlengh.ECO = c(0.0314, 0.0441, 0.0804) # From Boss et al, JGR 2004
      if (is.na(Anw[1])) {
        print("Non-water absorption for Green band not provided")
        print("No absorption correction applied")
        ABS.COR = FALSE
        G.Beta = G.Betau.mean
      } else {
        G.Beta = G.Betau.mean*exp(Anw[1]*pathlengh.ECO)
        ABS.COR = TRUE
      }
      
      ###### Integrate the VSF
      # bb= 2pi * integrate(beta*sin(angle))
      rad.angle = c(100,125,150,180)*pi/180
      scatangle=seq(pi/2,pi, 0.01)
          
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
        G.bb = G.bb.prime - bbs
        SAL.COR <- TRUE 
      } else {
        bbs <- 0 
        G.bb = G.bb.prime - bbs
        SAL.COR <- FALSE 
      }
      
      bbW = (0.0029308*(532/500)^-4.24)/2
      G.bbP <- G.bb - bbW
      
      return(list(eco.raw=eco,
                  waves=532,
                  scattering.angle=c(100,125,150),
                  bb=G.bb,
                  bbP=G.bbP,
                  bbs=bbs,
                  Betau.mean=G.Betau.mean,
                  Betau.sd=G.Betau.sd,
                  Beta=G.Beta,
                  Station=Station,
                  DateTime=DateTime,
                  Depth=Depth,
                  Anw=Anw,
                  ABS.COR=ABS.COR,
                  SAL.COR=SAL.COR,
                  Salinity=Salinity,
                  start=start,
                  end=end))
    }
    if (ECO.bands =="R") {
      plot(eco$time, eco$R.Betau[,2], 
           ylim=c(min(eco$R.Betau, na.rm = T), max(eco$R.Betau,  na.rm = T)), 
           pch=19, cex=0.5, 
           main="VSF for the green",
           sub=paste(Station, DateTime),
           xlab="time (s)", ylab="uncorrected VSF (/m /sr)")
      points(eco$time, eco$R.Betau[,1], col=2,pch=19,cex=0.5)
      points(eco$time, eco$R.Betau[,3], col=3,pch=19,cex=0.5)
      legend("topleft", c('100',"125","150"), pch=c(19,19,19), col=c(2,1,3))
      
      if (start == 999) {
        print("Click for the begining of the cast and then ESC")
        start <- identify(eco$time, eco$R.Betau[,2])
        print("Click for the end of the cast and then ESC")
        end <- identify(eco$time, eco$R.Betau[,2])
      }
      if (end == 999) {
        end <- length(eco$time)
      }
      
      R.Betau.mean = apply(eco$R.Betau[start:end,],2,mean,na.rm=T)
      
      R.Betau.sd = apply(eco$R.Betau[start:end,],2,sd,na.rm=T)
      
      ###### Apply absorption correction
      pathlengh.ECO = c(0.0314, 0.0441, 0.0804) # From Boss et al, JGR 2004
      if (is.na(Anw[1])) {
        print("Non-water absorption for Red band not provided")
        print("No absorption correction applied")
        ABS.COR = FALSE
        R.Beta = R.Betau.mean
      } else {
        R.Beta = R.Betau.mean*exp(Anw[1]*pathlengh.ECO)
        ABS.COR = TRUE
      }
      
      ###### Integrate the VSF
      # bb= 2pi * integrate(beta*sin(angle))
      rad.angle = c(100,125,150,180)*pi/180
      scatangle=seq(pi/2,pi, 0.01)
      
      # same for the Red
      R.Beta.mean2=c(R.Beta,0)
      df = data.frame(rad.angle, R.Beta.mean2*sin(rad.angle))
      names(df) <-c("scatangle", "betasin")
      model <- lm(betasin ~ poly(scatangle, 3), data=df)
      yhat=predict(model,data.frame(scatangle))
      fx.linear <- approxfun(scatangle, yhat)
      R.bb.prime = 2*pi*integrate(fx.linear, pi/2, pi, subdivisions=180, stop.on.error = FALSE)[1]$value
      
      # correct for salinity
      if (!is.na(Salinity)) {
        bbs = 8.03*((1.41*1.08)*Salinity/37)*1e-4
        R.bb = R.bb.prime - bbs
        SAL.COR <- TRUE 
      } else {
        bbs <- 0 
        R.bb = R.bb.prime - bbs
        SAL.COR <- FALSE 
      }
      
      bbW = (0.0029308*(660/500)^-4.24)/2
      R.bbP <- R.bb - bbW
      
      return(list(eco.raw=eco,
                  waves=660,
                  scattering.angle=c(100,125,150),
                  bb=R.bb,
                  bbP=R.bbP, 
                  bbs=bbs,
                  Betau.mean=R.Betau.mean,
                  Betau.sd=R.Betau.sd,
                  Beta=R.Beta,
                  Station=Station,
                  DateTime=DateTime,
                  Depth=Depth,
                  Anw=Anw,
                  ABS.COR=ABS.COR,
                  SAL.COR=SAL.COR,
                  Salinity=Salinity,
                  start=start,
                  end=end))
    }
    if (ECO.bands =="BG") {
      plot(eco$time, eco$G.Betau[,2], 
           ylim=c(min(eco$G.Betau, na.rm = T), max(eco$G.Betau,  na.rm = T)), 
           pch=19, cex=0.5, 
           main="VSF for the green",
           sub=paste(Station, DateTime),
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
      if (is.na(Anw[1]) | is.na(Anw[2]) | length(Anw) != 2) {
        print("Non-water absorption for Blue and Green bands not provided")
        print("No absorption correction applied")
        ABS.COR = FALSE
        B.Beta = B.Betau.mean
        G.Beta = G.Betau.mean
      } else {
        B.Beta = B.Betau.mean*exp(Anw[1]*pathlengh.ECO)
        G.Beta = G.Betau.mean*exp(Anw[2]*pathlengh.ECO)
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
        SAL.COR <- TRUE 
      } else {
        bbs <- 0 
        SAL.COR <- FALSE 
      }
      B.bb = B.bb.prime - bbs
      G.bb = G.bb.prime - bbs
      
      # remove water
      bbW = (0.0029308*(c(470,532)/500)^-4.24)/2
      B.bbP <- B.bb - bbW[1]
      G.bbP <- G.bb - bbW[1]
      
      return(list(eco.raw=eco,
                  waves=c(470,532),
                  scattering.angle=c(100,125,150),
                  bb=c(B.bb, G.bb),
                  bbP=c(B.bbP, G.bbP),
                  bbs=bbs,
                  Betau.mean=cbind(B.Betau.mean, G.Betau.mean),
                  Betau.sd=cbind(B.Betau.sd, G.Betau.sd),
                  Beta=cbind(B.Beta, G.Beta),
                  Station=Station,
                  DateTime=DateTime,
                  Depth=Depth,
                  Anw=Anw,
                  ABS.COR=ABS.COR,
                  SAL.COR=SAL.COR,
                  Salinity=Salinity,
                  start=start,
                  end=end))
    }
  }
  if (ECO.type == "BB9") {
    plot(eco$time, eco$Betau[,2], col=4,
         ylim=c(min(eco$Betau, na.rm = T), max(eco$Betau,  na.rm = T)), 
         pch=19, cex=0.5, 
         main="VSF vs time. Click to select the start and end",
         sub=paste(Station, DateTime),
         xlab="time (s)", ylab="uncorrected VSF (/m /sr)")
    points(eco$time, eco$Betau[,5], col=3,pch=19,cex=0.5)
    points(eco$time, eco$Betau[,9], col=2,pch=19,cex=0.5)
    legend("topleft", c('440',"532","715"), pch=c(19,19,19), col=c(4,3,2))
    
    if (start == 999) {
      print("Click for the begining of the cast and then ESC")
      start <- identify(eco$time, eco$Betau[,5])
      print("Click for the end of the cast and then ESC")
      end <- identify(eco$time, eco$Betau[,5])
    }
    if (end == 999) {
      end <- length(eco$time)
    }
  
    Betau.mean = apply(eco$Betau[start:end,],2,mean,na.rm=T)
    Betau.sd = apply(eco$Betau[start:end,],2,sd,na.rm=T)
    
    ###### Apply absorption correction
    if (anyNA(Anw) | length(Anw) != 9) {
      print("Non-water absorption not provided or does not have 9 wavelengths ")
      print("No absorption correction applied")
      ABS.COR = FALSE
      Beta = Betau.mean
    } else {
      Beta = Betau.mean*exp(Anw*0.01635) # The pathlenght is from Doxaran et al 2016
      ABS.COR = TRUE
    }

    # Compute Pure Water beta
    wl.fac = 1.38*(eco$waves/500)^-4.32
    bbW = (0.0029308*(eco$waves/500)^-4.24)/2
   
    Beta2bb <- 2*pi*1.1    
  
    # correct for salinity
    if (!is.na(Salinity)) {
      S.fac  <- (1+(0.3*Salinity/37))*1e-4 * (1+ cos(117/180*pi)*cos(117/180*pi)*((1-0.09)/(1+0.09)))
      SAL.COR <- TRUE 
    } else {
      Salinity <- 0
      S.fac  <- (1+(0.3*Salinity/37))*1e-4 * (1+ cos(117/180*pi)*cos(117/180*pi)*((1-0.09)/(1+0.09)))
      SAL.COR <- FALSE 
      Salinity <- NA
    }
    BetaW  <- S.fac * wl.fac
    BetaP  <- Beta - BetaW
    bbP    <- Beta2bb * BetaP
    bb     <- bbP + bbW
    
    return(list(eco.raw=eco,
                waves=eco$waves,
                bb=bb,
                bbP=bbP, 
                Betau.mean=Betau.mean,
                Betau.sd=Betau.sd,
                Beta=Beta,
                Station=Station,
                DateTime=DateTime,
                Depth=Depth,
                Anw=Anw,
                ABS.COR=ABS.COR,
                SAL.COR=SAL.COR,
                Salinity=Salinity,
                start=start,
                end=end))
  }
  if (ECO.type == "BB3") {
    plot(eco$time, eco$Betau[,2], 
         ylim=c(min(eco$Betau, na.rm = T), max(eco$Betau,  na.rm = T)), 
         pch=19, cex=0.5, 
         main="VSF for the green",
         sub=paste(Station, DateTime),
         xlab="time (s)", ylab="uncorrected VSF (/m /sr)")
    points(eco$time, eco$Betau[,1], col=2,pch=19,cex=0.5)
    points(eco$time, eco$Betau[,3], col=3,pch=19,cex=0.5)
    #legend("topleft", c('440',"532","715"), pch=c(19,19,19), col=c(2,1,3))
    
    if (start == 999) {
      print("Click for the begining of the cast and then ESC")
      start <- identify(eco$time, eco$Betau[,2])
      print("Click for the end of the cast and then ESC")
      end <- identify(eco$time, eco$Betau[,2])
    }
    if (end == 999) {
      end <- length(eco$time)
    }
    
    Betau.mean = apply(eco$Betau[start:end,],2,mean,na.rm=T)
    Betau.sd = apply(eco$Betau[start:end,],2,sd,na.rm=T)
    
    ###### Apply absorption correction
    if (is.na(Anw[1]) | length(Anw) != 3) {
      print("Non-water absorption not provided or does not have 3 wavelengths ")
      print("No absorption correction applied")
      ABS.COR = FALSE
      Beta = Betau.mean
    } else {
      Beta = Betau.mean*exp(Anw*0.01635) # The pathlenght is from Doxaran et al 2016
      ABS.COR = TRUE
    }
    
    # Compute Pure Water beta
    wl.fac = 1.38*(eco$waves/500)^-4.32
    bbW = (0.0029308*(eco$waves/500)^-4.24)/2
    
    Beta2bb <- 2*pi*1.1    
    
    # correct for salinity
    if (!is.na(Salinity)) {
      S.fac  <- (1+(0.3*Salinity/37))*1e-4 * (1+ cos(117/180*pi)*cos(117/180*pi)*((1-0.09)/(1+0.09)))
      SAL.COR <- TRUE 
    } else {
      Salinity <- 0
      S.fac  <- (1+(0.3*Salinity/37))*1e-4 * (1+ cos(117/180*pi)*cos(117/180*pi)*((1-0.09)/(1+0.09)))
      SAL.COR <- FALSE 
      Salinity <- NA
    }
    BetaW  <- S.fac * wl.fac
    BetaP  <- Beta - BetaW
    bbP    <- Beta2bb * BetaP
    bb     <- bbP + bbW
    
    return(list(eco.raw=eco,
                waves=eco$waves,
                bb=bb,
                bbP=bbP, 
                Betau.mean=Betau.mean,
                Betau.sd=Betau.sd,
                Beta=Beta,
                Station=Station,
                DateTime=DateTime,
                Depth=Depth,
                Anw=Anw,
                ABS.COR=ABS.COR,
                SAL.COR=SAL.COR,
                Salinity=Salinity,
                start=start,
                end=end))
    
  }
  
 }