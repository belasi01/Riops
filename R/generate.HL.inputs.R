#'  Produce Hydrolight-compatible input files for RTE simulations using measured IOPs
#'
#'@param IOP is a list returned by the function \code{\link{correct.merge.IOP.profile}}.
#'@param Absorption.meter is the instrument acronyme for the absorption meter (i.e. "ASPH", "AC9", "ACS").
#' Default is Absorption.meter="ASPH"
#'@param Attenuation.meter is the instrument acronyme for the attenuation meter (i.e. "AC9", "ACS", "BB9", "HS6").
#'Note that if a backscattering meter is put for attenuation, c is computed using a and bbp. In this case,
#'the user need to provide the bacskatteting ratio (bbp.tilde) to estimate bp (bp = bbp/bbp.tilde)
#' Default is Attenuation.meter="HS6"
#'@param Backscattering.meter is the instrument acronyme for the backscattering meter (i.e. BB9, BB3, HS6).
#'If NA, then no bbp file is output.
#'Default is Backscattering.meter="HS6"
#'@param bbp.tilde is the backscattering ratio need to compute the beam attenuation if only bbp is measured.
#'Default is bbp.tilde=0.018  (i.e. from Petzold VSF)
#'@param waves is a vector of wavelengths to include in the output file
#'@param Zmax is the maximum depth to include in the output file
#'@param delta.Z is the depth interval
#'@param Station is the station ID
#'@author Simon Belanger
#'@export

generate.HL.inputs <- function(IOP, Absorption.meter="ASPH", Attenuation.meter="HS6", Backscattering.meter="HS6",
                               bbp.tilde=0.018, waves=seq(400,700,5), Zmin=1, Zmax=50, delta.Z=1, 
                               Station="ST", homogeneous="FALSE", use.real.Bb=FALSE) {
  
  ##### Check the coherence of the inputs
  #####
  #use.bbp.tilde <- FALSE
  if (Absorption.meter == "ASPH") {
    if (length(IOP$ASPH) > 0) {
      print("A-sphere data will be use for absorption coefficient")
    } else {
      print("No A-sphere data available in the IOP")
      print("Exiting the function")
      return(0)
    }
  }
  if (Absorption.meter == "AC9") {
    if (length(IOP$AC9) > 0) {
      print("AC9 data will be use for absorption coefficient")
    } else {
      print("No AC9 data available in the IOP")
      print("Exiting the function")
      return(0)
    }
  }
  if (Absorption.meter == "ACS") {
    if (length(IOP$ACS) > 0) {
      print("ACS data will be use for absorption coefficient")
    } else {
      print("No ACS data available in the IOP")
      print("Exiting the function")
      return(0)
    }
  }
  #####
  if (Attenuation.meter == "ACS") {
    if (length(IOP$ACS) > 0) {
      print("ACS data will be use for attenuation coefficient")
      use.bbp.tilde <- FALSE
    } else {
      print("No ACS data available in the IOP")
      print("Exiting the function")
      return(0)
    }
  }
  if (Attenuation.meter == "AC9") {
    if (length(IOP$AC9) > 0) {
      print("AC9 data will be use for attenuation coefficient")
    } else {
      print("No AC9 data available in the IOP")
      print("Exiting the function")
      return(0)
    }
  }
  if (Attenuation.meter == "BB9") {
    if (length(IOP$BB9) > 0) {
      print("BB9 data will be use to compute attenuation coefficient")
      print(paste("Particles backscattering fraction will be used: ", bbp.tilde))
      use.bbp.tilde <- TRUE
    } else {
      print("No BB9 data available in the IOP")
      print("Exiting the function")
      return(0)
    }
  }
  if (Attenuation.meter == "BB3") {
    if (length(IOP$BB3) > 0) {
      print("BB3 data will be use to compute attenuation coefficient")
      print(paste("Particles backscattering fraction will be used: ", bbp.tilde))
      use.bbp.tilde <- TRUE
    } else {
      print("No BB3 data available in the IOP")
      print("Exiting the function")
      return(0)
    }
  }
  if (Attenuation.meter == "HS6") {
    if (length(IOP$HS6) > 0) {
      print("HS6 data will be use to compute attenuation coefficient")
      print(paste("Particles backscattering fraction will be used: ", bbp.tilde))
      use.bbp.tilde <- TRUE
    } else {
      print("No HS6 data available in the IOP")
      print("Exiting the function")
      return(0)
    }
  }
  #####
  if (Backscattering.meter == "BB9") {
    if (length(IOP$BB9) > 0) {
      print("BB9 data will be use to compute backscattering coefficient")
    } else {
      print("No BB9 data available in the IOP")
      print("Exiting the function")
      return(0)
    }
  }
  if (Backscattering.meter == "BB3") {
    if (length(IOP$BB3) > 0) {
      print("BB3 data will be use to compute backscattering coefficient")
    } else {
      print("No BB3 data available in the IOP")
      print("Exiting the function")
      return(0)
    }
  }
  if (Backscattering.meter == "HS6") {
    if (length(IOP$HS6) > 0) {
      print("HS6 data will be use to compute backscattering coefficient")
    } else {
      print("No HS6 data available in the IOP")
      print("Exiting the function")
      return(0)
    }
  }
  #####
  
  ##### Define common parameters
  #####
  Depth = seq(Zmin,Zmax,delta.Z)
  
  ##### Start with absorption interpolation
  #####
  if (Absorption.meter == "ASPH") {
    ixZ <- IOP$ASPH$ixmin:IOP$ASPH$ix.z.max
    
    a.wl = matrix(nrow=length(Depth), ncol=length(IOP$ASPH$wl))
    for (i in 1:length(IOP$ASPH$wl)) {
      tempdf <- data.frame("IOPdepth" = IOP$ASPH$depth[ixZ],"IOPdata" = IOP$ASPH$a.corrected[ixZ,i])
      foo <- with(tempdf[!is.na(tempdf$IOPdata),],smooth.spline(IOPdepth,IOPdata))
      result <- with(tempdf,predict(foo,IOPdepth[is.na(IOPdata)]))
      tempdf[is.na(tempdf$IOPdata),] <- result
      IOP$ASPH$a.corrected[ixZ,i] <- tempdf$IOPdata
      s     <- smooth.spline(IOP$ASPH$depth[ixZ], IOP$ASPH$a.corrected[ixZ,i])
      a.wl[,i] <- predict(s,Depth)$y
    }
    
    a = matrix(nrow=length(Depth), ncol=length(waves))
    for (i in 1:length(Depth)) {
      s     <- smooth.spline(IOP$ASPH$wl, a.wl[i,])
      a[i,] <- predict(s,waves)$y
    }
  }
  
  
  if (Absorption.meter == "ACS") {
    ixZ <- IOP$ACS$ixmin:IOP$ACS$ix.z.max
    
    a.wl = matrix(nrow=length(Depth), ncol=length(IOP$ACS$a.wl))
    for (i in 1:length(IOP$ACS$a.wl)) {
      tempdf <- data.frame("IOPdepth" = IOP$ACS$Depth[ixZ],"IOPdata" = IOP$ACS$a.corrected[ixZ,i])
      foo <- with(tempdf[!is.na(tempdf$IOPdata),],smooth.spline(IOPdepth,IOPdata))
      result <- with(tempdf,predict(foo,IOPdepth[is.na(IOPdata)]))
      tempdf[is.na(tempdf$IOPdata),] <- result
      IOP$ACS$a.corrected[ixZ,i] <- tempdf$IOPdata
      s     <- smooth.spline(IOP$ACS$Depth[ixZ], IOP$ACS$a.corrected[ixZ,i])
      a.wl[,i] <- predict(s,Depth)$y
    }
    
    a = matrix(nrow=length(Depth), ncol=length(waves))
    for (i in 1:length(Depth)) {
      s     <- smooth.spline(IOP$ACS$a.wl, a.wl[i,])
      a[i,] <- predict(s,waves)$y
    }
  }
  
  if (homogeneous == TRUE) {
    a.zero.minus <- a[1,]
    for (j in 2:length(a[,1])) {
      a[j,] <- a.zero.minus
    }
    print("Absorption data homogeneous profile prepared")
  }
  print("Absorption data rectified, binned and prepared")
  
  ###### Compute the attenuation
  
  if (Attenuation.meter == "HS6") {
    ixZ <- IOP$HS6$ixmin:IOP$HS6$ix.z.max
    
    bb.wl = matrix(nrow=length(Depth), ncol=length(IOP$HS6$wl))
    for (i in 1:length(IOP$HS6$wl)) {
      tempdf <- data.frame("IOPdepth" = IOP$HS6$depth[ixZ],"IOPdata" = IOP$HS6$bbP.corrected[ixZ,i])
      foo <- with(tempdf[!is.na(tempdf$IOPdata),],smooth.spline(IOPdepth,IOPdata))
      result <- with(tempdf,predict(foo,IOPdepth[is.na(IOPdata)]))
      tempdf[is.na(tempdf$IOPdata),] <- result
      IOP$HS6$bbP.corrected[ixZ,i] <- tempdf$IOPdata
      s     <- smooth.spline(IOP$HS6$depth[ixZ], IOP$HS6$bbP.corrected[ixZ,i])
      bb.wl[,i] <- predict(s,Depth)$y
    }
    
    bb = matrix(nrow=length(Depth), ncol=length(waves))
    for (i in 1:length(Depth)) {
      s     <- smooth.spline(IOP$HS6$wl, bb.wl[i,])
      bb[i,] <- predict(s,waves)$y
    }
    
    #### Estimate c using constant Bb value
    c = a + bb/bbp.tilde
    
    #### Estimate c using spectrally varying Bb value
    if (use.real.Bb == T) {
      Bb.val <- c(0.015604722, 0.014004062, 0.013361485, 0.013045015, 0.011135065, #Change values here 
                  #if you have real BB
                  0.011637792, 0.008846920, 0.009269832, 0.008352442)
      Bb.wave <- c(412, 440, 488, 510, 532, 595, 650, 676, 715)
      Bb.val.interp <- Hmisc::approxExtrap(Bb.wave, Bb.val, xout = seq(400,800,5), method = "linear" )$y
      temp=bb
      for (i in length(dim(bb)[1])) {
        temp[i,] <- bb[i,]/Bb.val.interp
      }
      c = a + temp
      
    }
  }
  
  if (Attenuation.meter == "ACS") {
    ixZ <- IOP$ACS$ixmin:IOP$ACS$ix.z.max
    
    c.wl = matrix(nrow=length(Depth), ncol=length(IOP$ACS$c.wl))
    for (i in 1:length(IOP$ACS$c.wl)) {
      
      tempdf <- data.frame("IOPdepth" = IOP$ACS$Depth[ixZ],"IOPdata" = IOP$ACS$c.corrected[ixZ,i])
      foo <- with(tempdf[!is.na(tempdf$IOPdata),],smooth.spline(IOPdepth,IOPdata))
      result <- with(tempdf,predict(foo,IOPdepth[is.na(IOPdata)]))
      tempdf[is.na(tempdf$IOPdata),] <- result
      IOP$ACS$c.corrected[ixZ,i] <- tempdf$IOPdata
      s     <- smooth.spline(IOP$ACS$Depth[ixZ], IOP$ACS$c.corrected[ixZ,i])
      c.wl[,i] <- predict(s,Depth)$y
    }
    
    c = matrix(nrow=length(Depth), ncol=length(waves))
    for (i in 1:length(Depth)) {
      s     <- smooth.spline(IOP$ACS$c.wl, c.wl[i,])
      c[i,] <- predict(s,waves)$y
    }
  }
  if (homogeneous == TRUE) {
    c.zero.minus <- c[1,]
    for (j in 2:length(c[,1])) {
      c[j,] <- c.zero.minus
    }
    print("Attenuation data homogeneous profile prepared")
  }
  print("Absorption data rectified, binned and prepared")
  print("Attenuation data rectified, binned and prepared")
  
  ###### Compute the backscattering
  #####
  if (Backscattering.meter == "HS6") {
    
    if (Attenuation.meter == "HS6") {
      ### bb already computed!!
    } else {
      ixZ <- IOP$HS6$ixmin:IOP$HS6$ix.z.max
      
      bb.wl = matrix(nrow=length(Depth), ncol=length(IOP$HS6$wl))
      for (i in 1:length(IOP$HS6$wl)) {
        s     <- smooth.spline(IOP$HS6$depth[ixZ], IOP$HS6$bbP.corrected[ixZ,i])
        bb.wl[,i] <- predict(s,Depth)$y
      }
      
      bb = matrix(nrow=length(Depth), ncol=length(waves))
      for (i in 1:length(Depth)) {
        s     <- smooth.spline(IOP$HS6$wl, bb.wl[i,])
        bb[i,] <- predict(s,waves)$y
      }
    }
  }
  
  
  if (Backscattering.meter == "BB9") {
    
    ixZ <- IOP$BB9$ixmin:IOP$BB9$ix.z.max
    
    bb.wl = matrix(nrow=length(Depth), ncol=length(IOP$BB9$waves))
    for (i in 1:length(IOP$BB9$waves)) {
      s     <- smooth.spline(IOP$BB9$Depth[ixZ], IOP$BB9$bbP.corrected[ixZ,i])
      bb.wl[,i] <- predict(s,Depth)$y
    }
    
    bb = matrix(nrow=length(Depth), ncol=length(waves))
    for (i in 1:length(Depth)) {
      s     <- smooth.spline(IOP$BB9$waves, bb.wl[i,])
      bb[i,] <- predict(s,waves)$y
    }
  }
  
  if (homogeneous == TRUE) {
    bb.zero.minus <- bb[1,]
    for (j in 2:length(bb[,1])) {
      bb[j,] <- bb.zero.minus
    }
    print("Backscatter data homogeneous profile prepared")
  }
  print("Backscatter data rectified, binned and prepared")
  
  #Fail-Safe
  a[a < 0]<- 0
  c[c < 0] <- 0
  bb[bb < 0] <- 0
  
  ##############Write the ouputs
  print("File writing initiated")
  if (Absorption.meter == "ACS"){
    caldata <- read.table("cal.info.dat", header = T)
    if(caldata$Tref.ACS. == "zaneveld")
    {
      # filenames
      if (use.bbp.tilde) {
        if (use.real.Bb == FALSE) {
          file.name.ac = paste("HL_a_",Absorption.meter,"_c_",Attenuation.meter,"_bbptilde_",
                               signif(bbp.tilde,4),"_", format(IOP$time.window[1], "%Y%m%d") ,
                               "_Station",Station, ".txt", sep="")  
        } else {
          file.name.ac = paste("HL_a_",Absorption.meter,"_c_",Attenuation.meter,"_bbptilde_REAL",
                               "_", format(IOP$time.window[1], "%Y%m%d") ,
                               "_Station",Station, ".txt", sep="")
        }
        
      } else {
        file.name.ac = paste("HL_a_",Absorption.meter,"_c_",Attenuation.meter,
                             "_", format(IOP$time.window[1], "%Y%m%d") ,
                             "_Station",Station, "_zaneveld.txt", sep="")
      }
    } else {
      # filenames
      if (use.bbp.tilde) {
        if (use.real.Bb == FALSE) {
          file.name.ac = paste("HL_a_",Absorption.meter,"_c_",Attenuation.meter,"_bbptilde_",
                               signif(bbp.tilde,4),"_", format(IOP$time.window[1], "%Y%m%d") ,
                               "_Station",Station, ".txt", sep="")
        } else {
          file.name.ac = paste("HL_a_",Absorption.meter,"_c_",Attenuation.meter,"_bbptilde_REAL",
                               "_", format(IOP$time.window[1], "%Y%m%d") ,
                               "_Station",Station, ".txt", sep="")
        }
        
      } else {
        file.name.ac = paste("HL_a_",Absorption.meter,"_c_",Attenuation.meter,
                             "_", format(IOP$time.window[1], "%Y%m%d") ,
                             "_Station",Station, "_mckee.txt", sep="")
      }
    }
    
  } else {
    # filenames
    if (use.bbp.tilde) {
      if (use.real.Bb == FALSE) {
        file.name.ac = paste("HL_a_",Absorption.meter,"_c_",Attenuation.meter,"_bbptilde_",
                             signif(bbp.tilde,4),"_", format(IOP$time.window[1], "%Y%m%d") ,
                             "_Station",Station, ".txt", sep="")
      } else {
        file.name.ac = paste("HL_a_",Absorption.meter,"_c_",Attenuation.meter,"_bbptilde_REAL",
                             format(IOP$time.window[1], "%Y%m%d") ,
                             "_Station",Station, ".txt", sep="")
      }
      
    } else {
      file.name.ac = paste("HL_a_",Absorption.meter,"_c_",Attenuation.meter,
                           "_", format(IOP$time.window[1], "%Y%m%d") ,
                           "_Station",Station, "_zaneveld.txt", sep="")
    }
  }
  
  
  # Start with writing the header of AC file
  cat(paste("# Creation date UTC: ", Sys.time()  ,sep=""),"\n",file=file.name.ac) #1
  cat(paste("# Data acquisition date UTC: ", IOP$time.window[1] ,sep=""),"\n",file=file.name.ac, append = TRUE) #2
  cat(paste("# Absorption meter: ", Absorption.meter,sep=""),"\n",file=file.name.ac, append = TRUE) #3
  cat(paste("# Attenuation meter: ", Attenuation.meter,sep=""),"\n",file=file.name.ac, append = TRUE) #4
  cat(paste("# If c is estimated from bb, bbp fraction is : ", bbp.tilde,sep=""),"\n",file=file.name.ac, append = TRUE) #5
  cat(paste("# ",sep=""),"\n",file=file.name.ac, append = TRUE) #6
  cat(paste("# ",sep=""),"\n",file=file.name.ac, append = TRUE) #7
  cat(paste("# ",sep=""),"\n",file=file.name.ac, append = TRUE) #8
  cat(paste("# ",sep=""),"\n",file=file.name.ac, append = TRUE) #9
  cat(paste("# ",sep=""),"\n",file=file.name.ac, append = TRUE) #10
  cat(c(length(waves), waves),"\n",file=file.name.ac, append = TRUE) # Number of wavelengths and the waves
  # ctemp <- rbind(data.frame(c=c),0)
  ctemp <- rbind(c,-1); atemp <- rbind(a,-1); Depthtemp<- rbind(Depth,-1)
  write.table(data.frame(Depth=c(Depth,-1),a=atemp,c=ctemp), file=file.name.ac, quote = F, row.names = F, col.names = F, append = TRUE)
  
  print("a & c written to disk")
  
  #Write bb
  if (!is.na(Backscattering.meter)) {
    if (Absorption.meter == "ACS"){
      if(caldata$Tref.ACS. == "zaneveld") {
        file.name.bb = paste("HL_bb_",Backscattering.meter,"_", format(IOP$time.window[1], "%Y%m%d") ,
                             "_Station",Station, "_zaneveld.txt", sep="")
      } else {
        file.name.bb = paste("HL_bb_",Backscattering.meter,"_", format(IOP$time.window[1], "%Y%m%d") ,
                             "_Station",Station, "_mckee.txt", sep="")
      }
    } else {
      file.name.bb = paste("HL_bb_",Backscattering.meter,"_", format(IOP$time.window[1], "%Y%m%d") ,
                           "_Station",Station, ".txt", sep="")
    }
    
    cat(paste("# Creation date UTC: ", Sys.time()  ,sep=""),"\n",file=file.name.bb) #1
    cat(paste("# Data acquisition date UTC: ", IOP$time.window[1] ,sep=""),"\n",file=file.name.bb, append = TRUE) #2
    cat(paste("# Backscattering meter: ", Backscattering.meter,sep=""),"\n",file=file.name.bb, append = TRUE) #3
    cat(paste("# ",sep=""),"\n",file=file.name.bb, append = TRUE) #4
    cat(paste("# ",sep=""),"\n",file=file.name.bb, append = TRUE) #5
    cat(paste("# ",sep=""),"\n",file=file.name.bb, append = TRUE) #6
    cat(paste("# ",sep=""),"\n",file=file.name.bb, append = TRUE) #7
    cat(paste("# ",sep=""),"\n",file=file.name.bb, append = TRUE) #8
    cat(paste("# ",sep=""),"\n",file=file.name.bb, append = TRUE) #9
    cat(paste("# ",sep=""),"\n",file=file.name.bb, append = TRUE) #10
    cat(c(length(waves), waves),"\n",file=file.name.bb, append = TRUE) # Number of wavelengths and the waves
    bbtemp <- rbind(bb,-1) 
    write.table(data.frame(Depth=c(Depth,-1),bb=bbtemp), file=file.name.bb, quote = F, row.names = F, col.names = F, append = TRUE)
    
  }
  print("bb written to disk")
  print(paste0("HL input generation for station ", Station, " is finished"))
  
}
