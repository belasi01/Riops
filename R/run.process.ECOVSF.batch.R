#'
#' Run batch processing for ECO-VSF 
#' 
#' @param log.file is the name of the ASCII file (CSV or space-delimated text) containing the
#' list of samples to process (see details below).
#' @param data.path is the full path where the ECO data are stored 
#' @param dev.file is the Wetlabs device file
#' 
#' @details The most important thing to do before runing this programm is to prepare
#' the log.file. This file contains 11 fields : 
#' Eco.filename Station Date Depth B.Anw G.Anw Salinity dark.file start end process
#' 
#'
run.process.ECOVSF.batch <- function(log.file="log.txt", data.path="./", 
                                     dev.file="VSF30025.DEV"){
      if (file.exists(data.path)) {
        print("Data path exists")
        print(data.path)
      } else {
        print("data.path does not exist!")
        print("STOP processing")
        return(0)
      }
       
  # Check the output directories and Create them if they are not available.
  path.png = file.path(data.path,"png/") #paste(data.path,"/png/", sep="")
  path.out = file.path(data.path,"RData/") #paste(data.path,"/RData/", sep="")
  path.dark = file.path(data.path,"dark/")
  path.raw = file.path(data.path,"raw/")
  
  if (!file.exists(path.dark)) {
    print("No folder named dark found")
    print("STOP processing")
    print("Create a folder:")
    print(path.dark)
    print("and put your dark files in it")
    return(0)
  } else print(paste("Dark in :",path.dark))
  
  if (!file.exists(path.raw)) {
    print("No folder named raw found")
    print("STOP processing")
    print("Create a folder:")
    print(path.raw)
    print("and put your data files in it")
    return(0)
  } else print(paste("Raw data in :",path.raw))
  
  if (!file.exists(path.png)) dir.create(path.png)
  if (!file.exists(path.out)) dir.create(path.out)

  
  if (!file.exists(log.file)) {
    default.log.file =  file.path(Sys.getenv("Riop_DATA_DIR"), "log.ECOVSF.txt")
    
    file.copy(from = default.log.file, to = log.file)
    cat("EDIT file", log.file, "and CUSTOMIZE IT\n")
    return(0)
  }
  
  # Lecture des informations dans un fichier texte
  ext = unlist(strsplit(log.file, "[.]"))[2]
  if (ext == "csv") {
    log = read.table(file=log.file, header=T, sep=",")
  } else {
    log = read.table(file=log.file, header=T)    
  }

  nfiles = length(log$ECO.filename)
  print(paste(nfiles, "files to process."))
  for (i in 1:nfiles) {
    
    if (log$process[i] == 1) {
      
      raw.file <- paste(path.raw,log$ECO.filename[i], sep="/")
      if (file.exists(raw.file)) {
        print(paste("Processing ", raw.file))
        raw <- read.ECOVSF.ISMER(raw.file)
      } else {
        print("WARNING no data file")
        print(raw.file)
        print("Abort processing!")
        return(0)
      }
      
      if (file.exists(dev.file)) {
        cal <- read.vsf3.dev.file(dev.file)
      } else {
        print("No device file found")
        print("Abort processing")
        return(0)
      }
      
      dark.file <- paste(path.dark,log$dark.file[i], sep="/")
      if (file.exists(dark.file)) {
        eco <- apply.ECOVSF.cal(raw, 
                                dev.file = dev.file, 
                                dark.file = dark.file)
      } else {
        print("WARNING no dark data file or dark file not found")
        eco <- apply.ECOVSF.cal(raw, 
                                dev.file = dev.file, 
                                dark.file = NA)
      }
      
      DateTime = as.POSIXct(paste(as.character(log$Date[i]),
                                  as.character(log$UTCTime[i])), 
                            "%Y%m%d %H:%M", 
                            tz="UTC")
      
      bb=process.ECOVSF(eco,
                        station = log$Station[i],
                        DateTime = DateTime, 
                        Depth = log$Depth[i],
                        B.Anw = log$B.Anw[i],
                        G.Anw = log$G.Anw[i],
                        Salinity = log$Salinity[i],
                        start = log$start[i], 
                        end = log$end[i])
      
      # update log
      log$start[i] <- bb$start
      log$end[i]   <- bb$end
      
      # plot data
      
      minVSF =  min(bb$Betau.mean - bb$Betau.sd)
      maxVSF =  max(bb$Betau.mean + bb$Betau.sd)
      
      time <- paste(unlist(str_split(log$UTCTime[i],":"))[1], unlist(str_split(log$UTCTime[i],":"))[2],sep="")
      png(file=paste(path.png,log$Station[i],"_",log$Date[i],"_",time,".png", sep=""),
          width=6, height=8, units="in", res=300)
      
      par(mfrow=c(3,1))
      par(mar=c(4,5,1,1))
      
      
      plot(bb$scattering.angle, eco$offset[1,], 
           xlab="Scattering Angle", 
           ylab="Offset",
           ylim=c(min(c(eco$offset,cal$Offset)),
                  max(c(eco$offset,cal$Offset))), 
           xlim=c(90,180), col=4, pch=19)
      points(bb$scattering.angle, eco$offset[2,], 
             col=3, pch=19)
      lines(bb$scattering.angle, eco$offset[2,], 
            col=3)
      lines(bb$scattering.angle, eco$offset[1,], 
            col=4)
      
      lines(bb$scattering.angle, cal$Offset[4:6], 
            col=3,lwd=3, lty=2)
      lines(bb$scattering.angle, cal$Offset[1:3], 
            col=4,lwd=3, lty=2)
      legend("topright", c("Darks", "Calibration"), lwd=c(1,3), lty=c(1,2))
      
      
      plot(bb$scattering.angle, bb$Betau.mean[,1], 
           xlim=c(90,180), pch=19, col=4,
           ylim=c(minVSF, maxVSF),
           xlab="Scattering Angle", 
           ylab=expression(paste(beta,"(",m^-1 ,sr^-1,")")),
           main=paste(log$Station[i], log$DateTime[i]))
      if (eco$dark.offset) title(sub="Dark offset applied")
      errorbars(bb$scattering.angle, bb$Betau.mean[,1],xe=c(0,0,0),ye=bb$Betau.sd[,1], col=4)
      points(bb$scattering.angle, bb$Betau.mean[,2], 
             pch=19, col=3)
      lines(bb$scattering.angle, bb$Betau.mean[,1], 
            col=4)
      lines(bb$scattering.angle, bb$Betau.mean[,2], 
            col=3)
      errorbars(bb$scattering.angle,bb$Betau.mean[,2],xe=c(0,0,0),ye=bb$Betau.sd[,2], col=3)
      
      points(bb$scattering.angle, bb$Beta[,1], 
             pch=25, col=4)
      points(bb$scattering.angle, bb$Beta[,2], 
             pch=25, col=3)
      
      legend("topright", c("uncor.", "corrected"), pch=c(19,25))
      legend("bottomright", c("470", "532"), pch=c(19,19), col=c(4,3))
      
      
      plot(bb$waves, bb$bb, 
           xlab="Wavelength", pch=19,
           ylab=expression(b[b](m^-1)))
      lines(bb$waves, bb$bb)
      
      dev.off()
      
      # Save data in RData file format
      save(bb, file=paste(path.out,"/",log$Station[i],"_", log$Date[i], "_",time, ".RData", sep=""))
      
      # update log file 
      write.table(log, file=log.file, quote = F, row.names = F)
      
    } else print(paste("Skipping file:", log$ECO.filename[i]))
    
  } 
}
  
  
  