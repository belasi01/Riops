
attenuation.correction.HS6 <- function(HS6, 
                                       HS6.CALYEAR = 2016, 
                                       Salinity=0, 
                                       df.absorption){

  print("Apply attenuation correction to HS6")
  
  # FROM CALIBRATION FILE
  if (HS6.CALYEAR == 2010) Sigmaexp <- c(0.139, 0.142, 0.146, 0.143, 0.146, 0.146)
  if (HS6.CALYEAR == 2013) Sigmaexp <- c(0.135, 0.141, 0.143, 0.14, 0.142, 0.144)
  if (HS6.CALYEAR == 2014) Sigmaexp <- c(0.137, 0.139, 0.144, 0.141, 0.141, 0.143)
  if (HS6.CALYEAR == 2016) Sigmaexp <- c(0.137, 0.141, 0.145, 0.14, 0.144, 0.144)
  if (HS6.CALYEAR == 2018) Sigmaexp <- c(0.137, 0.142, 0.144, 0.141, 0.143, 0.145)
  
  Sigmaexp.m = matrix(Sigmaexp, nrow=length(HS6$depth), ncol=length(HS6$wl), byrow=T)
  
  Beta2bb <- 6.79
  
  # Compute Pure Water beta
  S <- rep(Sanility, length(HS6$depth))
  S.fac = (1+(0.3*S/37))*1e-4 * (1+ cos(140/180*pi)*cos(140/180*pi)*((1-0.09)/(1+0.09)))
  wl.fac = 1.38*(HS6$wl/500)^-4.32
  S.fac.m = matrix(S.fac, nrow=length(HS6$depth), ncol=length(HS6$wl), byrow=F)
  wl.fac.m = matrix(wl.fac, nrow=length(HS6$depth), ncol=length(HS6$wl),byrow=T)
  
  BetaW = S.fac.m * wl.fac.m
  bbW = (0.0029308*(HS6$wl/500)^-4.24)/2
  bbW.m = matrix(bbW, nrow=length(HS6$depth), ncol=length(HS6$wl), byrow=T)
  
  
  ix.HS6.wl = rep(NA,6)
  
  for (j in 1:6){
      ix.HS6.wl[j] = which(df.absorption$wl == HS6$wl[j])
  }
  
  a.HS6 = df.absorption$a[ix.HS6.wl]
  a.HS6.m = matrix(a.HS6, nrow=length(HS6$depth), ncol=length(HS6$wl),byrow=T)
  
  

  # New correction from Doxaran et al, Opt. Express 2016
  Beta.measured  <- HS6$betau
  Beta.corrected <- Beta.measured
  for (k in 1:5) {
      Kbb <-  a.HS6.m + 4.34 * Beta2bb * (Beta.corrected - BetaW)
      sigmaKbb <- exp(Sigmaexp.m*Kbb)
      Beta.corrected <- sigmaKbb * Beta.measured
  }
    
    HS6$Beta.corrected  <- Beta.corrected
    HS6$BetaP.corrected <- Beta.corrected - BetaW
    HS6$bbP.corrected   <- Beta2bb * HS6$BetaP.corrected
    HS6$bb.corrected    <- HS6$bbP.corrected + bbW.m
    HS6$a <- a.HS6
    HS6$sigma.correction = TRUE
    
}

  