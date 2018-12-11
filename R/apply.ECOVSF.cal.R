#' Apply ECOVSF calibration
#' 
#' 
#' 
apply.ECOVSF.cal <- function(eco, 
                             dev.file=NA, 
                             dark.file=NA) {
  
  if (is.na(dev.file)) {
    print("No device file provided")
    print("Abort processing")
    return(0)
  } 
  else {
    print(paste("Reading the device file", dev.file))
    cal <- read.vsf3.dev.file(dev.file)
    print(cal)
    B.scaling.factor = matrix(cal$ScalingFactor[1:3], nrow=eco$nrec, ncol=3, byrow=T)
    B.offset = matrix(cal$Offset[1:3], nrow=eco$nrec, ncol=3, byrow=T)
    G.scaling.factor = matrix(cal$ScalingFactor[4:6], nrow=eco$nrec, ncol=3, byrow=T)
    G.offset = matrix(cal$Offset[4:6], nrow=eco$nrec, ncol=3, byrow=T)
  }
  if (!is.na(dark.file)) {
    print(paste("Reading dark file: ", dark.file))
    dark <- read.ECOVSF.ISMER(dark.file)
    B.offset.dark = c(mean(dark$raw$B100),mean(dark$raw$B125),mean(dark$raw$B150))
    G.offset.dark = c(mean(dark$raw$G100),mean(dark$raw$G125),mean(dark$raw$G150))
    
    #### print dark off sets and compare to calibration
    print("Blue offset from calibration and dark")
    print(B.offset[1,])
    print(B.offset.dark)
    print("Green offset from calibration and dark")
    print(G.offset[1,])
    print(G.offset.dark)
    
    B.offset = matrix(B.offset.dark, nrow=eco$nrec, ncol=3, byrow=T)
    G.offset = matrix(G.offset.dark, nrow=eco$nrec, ncol=3, byrow=T)
    
    dark.offset = TRUE
  } 
  else {
    print("Use offsets from calibration")
    dark.offset = FALSE
  }

    nrec = eco$nrec
    
    ## Apply calibration to Blue  
    B.raw = cbind(eco$raw$B100,eco$raw$B125,eco$raw$B150)
    B.Betau = (B.raw - B.offset)*B.scaling.factor
    
    ## Apply calibration to Green  
    G.raw = cbind(eco$raw$G100,eco$raw$G125,eco$raw$G150)
    G.Betau = (G.raw - G.offset)*G.scaling.factor
    
    return(list(date=eco$date, time=eco$raw$time, raw=eco$raw, 
                B.Betau=B.Betau, G.Betau=G.Betau,
                nrec=nrec,
                dark.offset=dark.offset,
                offset=rbind(B.offset[1,],G.offset[1,])
                ))
    
}