#' Apply ECOVSF calibration
#' 
#' @param raw is a list of raw data from an ECO VSF, BB9 (or BB3 not implemented yet) with measurements
#' @param dev.file is the full path for the device file needed to convert the raw to calibrated data. 
#' This field is mandatory
#' @param ECO.type is a character string for the type of ECO meter: BB9, BB3, VSF3.
#' (Default is VSF3)
#' @param dark.file is the full path for file containing dark measurements. 
#' Must be consistent with the ECO.type VSF3, BB9 (or BB3 not implemented yet)  
#' @param ECO.bands must be provided if ECO.type == VSF3. It is a character string indicating the bands (BLUE, GREEN and RED), 
#' i.e. either "B", "G", "R" or "BG", or "BGR". 
#' 
#' @return It returns a list with raw data and calibrated VSF (uncorrected). 
#' 
#' @author Simon Bélanger
#' @export
#' 
apply.ECO.cal <- function(raw, 
                          dev.file=NA, 
                          dark.file=NA,
                          ECO.type="VSF3",
                          ECO.bands=NA) {
  
  if (is.na(dev.file)) {
    print("No device file provided")
    print("Abort processing")
    return(0)
  } 
  print(paste("Reading the device file", dev.file))
  cal <- read.ECO.dev.file(dev.file, ECO.type=ECO.type)
  print(cal)
  
  if (ECO.type=="VSF3") {
    if (is.na(ECO.bands)){
      print("No ECO.bands provided")
      print("Please add ECO.bands='B' or 'G' or 'R' or 'BG'")
      print("Abort processing")
      return(0)
    }
    else {
      if (ECO.bands == "B"){
        # prepare calibration 
        B.scaling.factor = matrix(cal$cal$ScalingFactor[1:3], nrow=raw$nrec, ncol=3, byrow=T)
        B.offset = matrix(cal$cal$Offset[1:3], nrow=raw$nrec, ncol=3, byrow=T)
        # read dark if provided and compute the inter-quantile mean
        if (!is.na(dark.file)) {
          print(paste("Reading dark file: ", dark.file))
          dark <- read.ECOVSF(dark.file, ECO.bands = ECO.bands)
          B.offset.dark = c(median(dark$raw$B100, na.rm=T),
                            median(dark$raw$B125, na.rm=T),
                            median(dark$raw$B150, na.rm=T))
          #### print dark off sets and compare to calibration
          print("Blue offset from calibration and dark")
          print(B.offset[1,])
          print(B.offset.dark)
          B.offset = matrix(B.offset.dark, nrow=raw$nrec, ncol=3, byrow=T)
          dark.offset = TRUE
        } 
        else {
          print("Use offsets from calibration")
          dark.offset = FALSE
        }
        ## Apply calibration to Blue  
        B.raw = cbind(raw$raw$B100,raw$raw$B125,raw$raw$B150)
        B.Betau = (B.raw - B.offset)*B.scaling.factor
        
        return(list(date=raw$date, time=raw$raw$time, raw=raw$raw, 
                    B.Betau=B.Betau,
                    nrec=raw$nrec,
                    dark.offset=dark.offset,
                    offset=B.offset[1,]))
      }
      
      
      if (ECO.bands == "G"){
        # prepare calibration 
        G.scaling.factor = matrix(cal$cal$ScalingFactor[4:6], nrow=raw$nrec, ncol=3, byrow=T)
        G.offset = matrix(cal$cal$Offset[4:6], nrow=raw$nrec, ncol=3, byrow=T)
        # read dark if provided and compute the inter-quantile mean
        if (!is.na(dark.file)) {
          print(paste("Reading dark file: ", dark.file))
          dark <- read.ECOVSF(dark.file, ECO.bands = ECO.bands)
          G.offset.dark = c(median(dark$raw$G100, na.rm = T),
                            median(dark$raw$G125, na.rm = T),
                            median(dark$raw$G150, na.rm = T))
          #### print dark off sets and compare to calibration
          print("Green offset from calibration and dark")
          print(G.offset[1,])
          print(G.offset.dark)
          G.offset = matrix(G.offset.dark, nrow=raw$nrec, ncol=3, byrow=T)
          dark.offset = TRUE
        } 
        else {
          print("Use offsets from calibration")
          dark.offset = FALSE
        }
        ## Apply calibration to Green  
        G.raw = cbind(raw$raw$G100,raw$raw$G125,raw$raw$G150)
        G.Betau = (G.raw - G.offset)*G.scaling.factor
        
        return(list(date=raw$date, time=raw$raw$time, raw=raw$raw, 
                    G.Betau=G.Betau,
                    nrec=raw$nrec,
                    dark.offset=dark.offset,
                    offset=G.offset[1,]))
      }
      
      
      if (ECO.bands == "R"){
        # prepare calibration 
        R.scaling.factor = matrix(cal$cal$ScalingFactor[7:9], nrow=raw$nrec, ncol=3, byrow=T)
        R.offset = matrix(cal$cal$Offset[7:9], nrow=raw$nrec, ncol=3, byrow=T)
        # read dark if provided and compute the inter-quantile mean
        if (!is.na(dark.file)) {
          print(paste("Reading dark file: ", dark.file))
          dark <- read.ECOVSF(dark.file, ECO.bands = ECO.bands)
         R.offset.dark = c(median(dark$raw$R100, na.rm=T),
                           median(dark$raw$R125, na.rm=T),
                           median(dark$raw$R150, na.rm=T))
          #### print dark off sets and compare to calibration
          print("Red offset from calibration and dark")
          print(R.offset[1,])
          print(R.offset.dark)
          R.offset = matrix(R.offset.dark, nrow=raw$nrec, ncol=3, byrow=T)
          dark.offset = TRUE
        } 
        else {
          print("Use offsets from calibration")
          dark.offset = FALSE
        }
        ## Apply calibration to Green  
        R.raw = cbind(raw$raw$R100,raw$raw$R125,raw$raw$R150)
        R.Betau = (R.raw - R.offset)*R.scaling.factor
        
        return(list(date=raw$date, time=raw$raw$time, raw=raw$raw, 
                    R.Betau=R.Betau,
                    nrec=raw$nrec,
                    dark.offset=dark.offset,
                    offset=R.offset[1,]))
      }
      
      
      
      if (ECO.bands == "BG") {
        # prepare calibration 
        B.scaling.factor = matrix(cal$cal$ScalingFactor[1:3], nrow=raw$nrec, ncol=3, byrow=T)
        B.offset = matrix(cal$cal$Offset[1:3], nrow=raw$nrec, ncol=3, byrow=T)
        G.scaling.factor = matrix(cal$cal$ScalingFactor[4:6], nrow=raw$nrec, ncol=3, byrow=T)
        G.offset = matrix(cal$cal$Offset[4:6], nrow=raw$nrec, ncol=3, byrow=T)
        
        # read dark if provided and compute the inter-quantile mean
        if (!is.na(dark.file)) {
          print(paste("Reading dark file: ", dark.file))
          dark <- read.ECOVSF(dark.file, ECO.bands = ECO.bands)
          B.offset.dark = c(median(dark$raw$B100,na.rm = T),
                            median(dark$raw$B125,na.rm = T),
                            median(dark$raw$B150,na.rm = T))
          G.offset.dark = c(median(dark$raw$G100,na.rm = T),
                            median(dark$raw$G125,na.rm = T),
                            median(dark$raw$G150,na.rm = T))
          #### print dark off sets and compare to calibration
          print("Blue offset from calibration and dark")
          print(B.offset[1,])
          print(B.offset.dark)
          B.offset = matrix(B.offset.dark, nrow=raw$nrec, ncol=3, byrow=T)
          dark.offset = TRUE
          print("Green offset from calibration and dark")
          print(G.offset[1,])
          print(G.offset.dark)
          G.offset = matrix(G.offset.dark, nrow=raw$nrec, ncol=3, byrow=T)
        } 
        else {
          print("Use offsets from calibration")
          dark.offset = FALSE
        }
        ## Apply calibration to Blue  
        B.raw = cbind(raw$raw$B100,raw$raw$B125,raw$raw$B150)
        B.Betau = (B.raw - B.offset)*B.scaling.factor
        ## Apply calibration to Green  
        G.raw = cbind(raw$raw$G100,raw$raw$G125,raw$raw$G150)
        G.Betau = (G.raw - G.offset)*G.scaling.factor
        
        return(list(date=raw$date, time=raw$raw$time, raw=raw$raw, 
                    B.Betau=B.Betau, G.Betau=G.Betau,
                    nrec=raw$nrec,
                    dark.offset=dark.offset,
                    offset=rbind(B.offset[1,],G.offset[1,])))
      }
      
      
    }
    
  }
  
  if (ECO.type=="BB9") {
    # prepare calibration 
    scaling.factor = matrix(cal$cal$ScalingFactor, nrow=raw$nrec, ncol=9, byrow=T)
    offset = matrix(cal$cal$Offset, nrow=raw$nrec, ncol=9, byrow=T)
    # read dark if provided and compute the inter-quantile mean
    if (!is.na(dark.file)) {
      print(paste("Reading dark file: ", dark.file))
      dark <- read.BB9(dark.file, raw=TRUE)
      dark.offset <- rep(NA,9)
      for (i in 1:9) {
        ix = which(dark$raw[,i] < quantile(dark$raw[,i], probs = 0.75, na.rm = T) &
                   dark$raw[,i] > quantile(dark$raw[,i], probs = 0.25, na.rm = T))
        dark.offset[i] <- mean(dark$raw[ix,i])
      }
      print("Offsets from calibration and dark")
      print(offset[1,])
      print(dark.offset)
      offset = matrix(dark.offset, nrow=raw$nrec, ncol=9, byrow=T)
      dark.offset = TRUE
    } else {
      print("Use offsets from calibration")
      dark.offset = FALSE
    }
    
    ## Apply calibration 
    Betau = (raw$raw - offset) * scaling.factor
    
    return(list(raw=raw$raw,
                time=raw$Timer,
                waves=raw$wl,
                Betau=Betau,
                nrec=raw$nrec,
                dark.offset=dark.offset,
                offset=offset[1,]))
    
  }
    
  if (ECO.type=="BB3") {
    print("Not available yet")
    return(NULL)
  }
    
}