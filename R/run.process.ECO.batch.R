#'
#' Run batch processing to convert ECO meter data in raw format to backscattering coefficients. 
#' 
#'  The processing includes the application of the calibration coefficients to convert the raw numerical counts into VSF. 
#'  The dark offsets may be taken from the calibration file (device file) or from the dark measurements taken on the field. 
#'  Next, if absorption coefficients are provided, the VSF is corrected for loss of photons 
#'  due to attenuation along the pathlength. 
#'  The VSF is finaly converted in to total backscattering and particles backscattering. 
#' 
#' @param log.file is the name of the ASCII file in .csv (comma separated value) containing the
#' list of samples to process (see details below).
#' @param data.path is the full path where the ECO data are stored 
#' 
#' @details The most important thing to do before runing this programm is to prepare
#' the log.file. This file contains fields (comma delimiter) : 
#' ECO.filename; dev.file; ECO.type; ECO.bands; Station; Date; UTCTime; 
#' Depth; Salinity; dark.file; start; end; process; Anw1;..;AnwX
#' The ASCII files are:
#'\itemize{
#'  \item{ECO.filename: }{is the file name of an ECO file without the path. It must be put in a sub-folder named raw/ in the data.path;}
#'  \item{dev.file: }{is the full path and name of the device file (i.e. the calibration file) of the actual instrument;}
#'  \item{ECO.type: }{is a character string for the type of ECO meter: BB9, BB3, VSF3.}
#'  \item{ECO.bands: }{is a character string indicating the bands of the VSF3 meter. 
#'  It could take one of these character: "B", "G", "R" or "BG", or "BGR". 
#'  It is ignore when the ECO type is a BB meter}
#'  \item{Station: }{is the station ID. It will be store in the RData output;}
#'  \item{Date: }{is the date in format YYYYMMDD}
#'  \item{UTCTime: }{is the is the time and minute in HH:MM format}
#'  \item{Salinity: }{is the salinity of the sample.}
#'  \item{dark.file: }{is the name of the file containing raw dark measurements made 
#'  on the field using black tape places on the LED. 
#'  It must be put in a sub-folder named dark/ in the data.path and be consistent with the ECO.type}
#'  \item{start: }{is the begining of the cast in seconds after the instrument warming period.  
#' If 999 then the user is prompt to click on the plot of 
#' VSF versus Time to choose the start and the end of the cast interactively.}
#'  \item{end: }{is the end of the cast in second. If 999 then it takes
#' the end of the cast.}
#'  \item{process: }{is a boolean value indicating if the file has to be process (1) or not (0)  }
#'  \item{Anw1..AnwX: }{is the non-water absorption for each wavelength of the ECO meter. 
#'  For a BB9, for example, nine columns are expected}
#'  }
#'  
#'  The code will process each file one by one and will output a RData file for each raw file processed. 
#'  
#'  @author  Simon Belanger
#'  @export
#'  
run.process.ECO.batch <- function(log.file="log.txt", data.path="./"){
      if (file.exists(data.path)) {
        print("Data path exists")
        print(data.path)
      } else {
        stop("data.path: ",data.path,"/n does not exist!")
      }
       
  # Check the output directories and Create them if they are not available.
  path.png = file.path(data.path,"png/") #paste(data.path,"/png/", sep="")
  path.out = file.path(data.path,"RData/") #paste(data.path,"/RData/", sep="")
  path.dark = file.path(data.path,"dark")
  path.raw = file.path(data.path,"raw")
  
  if (!file.exists(path.dark)) {
    print("No folder named dark found")
    print("STOP processing")
    print("Create a folder:")
    print(path.dark)
    print("and put your dark files in it")
    stop()
  } else print(paste("Dark in :",path.dark))
  
  if (!file.exists(path.raw)) {
    print("No folder named raw found")
    print("STOP processing")
    print("Create a folder:")
    print(path.raw)
    print("and put your data files in it")
    stop()
  } else print(paste("Raw data in :",path.raw))
  
  if (!file.exists(path.png)) dir.create(path.png)
  if (!file.exists(path.out)) dir.create(path.out)

  
  if (!file.exists(log.file)) {
    default.log.file =  file.path(Sys.getenv("Riop_DATA_DIR"), "log.ECO.txt")
    
    file.copy(from = default.log.file, to = log.file)
    stop("EDIT file", log.file, "and CUSTOMIZE IT\n")
  }
  
  print("Read Log with comma delimiter" )
  log = read.table(file=log.file, header=T, sep=",")


  nfiles = length(log$ECO.filename)
  print(paste(nfiles, "files to process."))
  for (i in 1:nfiles) {
    
    if (log$process[i] == 1) {
      
      raw.file <- file.path(path.raw,paste0(log$ECO.filename[i],".raw"))
      if (file.exists(raw.file)) {
        message("Processing ", raw.file)
        if (log$ECO.type[i] == "VSF3") raw <- read.ECOVSF(raw.file, ECO.bands=log$ECO.bands[i])
        if (log$ECO.type[i] == "BB9") raw <- read.BB9(raw.file, raw=TRUE)
        if (log$ECO.type[i] == "BB3") raw <- read.BB3(raw.file, raw=TRUE)
      } else {
        stop("no raw file: ",raw.file)
      }
      
      if (file.exists(as.character(log$dev.file[i]))) {
        cal <- read.ECO.dev.file(as.character(log$dev.file[i]), ECO.type = log$ECO.type[i])
      } else {
        stop("No device file found: ", log$dev.file[i])
      }
      
      dark.file <- file.path(path.dark,log$dark.file[i])
      if (file.exists(dark.file)) {
        eco <- apply.ECO.cal(raw, 
                             dev.file = as.character(log$dev.file[i]), 
                             dark.file = as.character(dark.file),
                             ECO.type = log$ECO.type[i],
                             ECO.bands =log$ECO.bands[i])
      } else {
        warning("no dark data file or dark file not found")
        eco <- apply.ECO.cal(raw, 
                            dev.file = as.character(log$dev.file[i]), 
                            dark.file = NA,
                            ECO.type = log$ECO.type[i],
                            ECO.bands =log$ECO.bands[i])
      }
      
      DateTime = as.POSIXct(paste(as.character(log$Date[i]),
                                  as.character(log$UTCTime[i])), 
                            "%Y%m%d %H:%M", 
                            tz="UTC")
      Anw <- as.numeric(log[i,grep("Anw",names(log))])
      bb=compute.bb.discrete.from.ECO(eco,
                                      ECO.type = log$ECO.type[i],
                                      ECO.bands = log$ECO.bands[i],
                                      Station = log$Station[i],
                                      DateTime = DateTime, 
                                      Depth = log$Depth[i],
                                      Anw = Anw,
                                      Salinity = log$Salinity[i],
                                      start = log$start[i], 
                                      end = log$end[i])
      
      # update log
      log$start[i] <- bb$start
      log$end[i]   <- bb$end
      
      # plot data
      time <- paste(unlist(str_split(log$UTCTime[i],":"))[1], unlist(str_split(log$UTCTime[i],":"))[2],sep="")
 
      if (as.character(log$ECO.type[i]) == "VSF3") {
        print("Plot VSF3 data")
        if (log$ECO.bands[i] == "BG") {
          minVSF =  min(bb$Betau.mean - bb$Betau.sd)
          maxVSF =  max(bb$Betau.mean + bb$Betau.sd)
          
          png(file=paste(path.png,"/",log$ECO.filename[i], ".png", sep=""),
              width=6, height=8, units="in", res=300)
          
          par(mfrow=c(3,1))
          par(mar=c(4,5,1,1))
          plot(bb$scattering.angle, eco$offset[1,], 
               xlab="Scattering Angle", 
               ylab="Offset",
               ylim=c(min(c(eco$offset,cal$cal$Offset)),
                      max(c(eco$offset,cal$cal$Offset))), 
               xlim=c(90,180), col=4, pch=19)
          points(bb$scattering.angle, eco$offset[2,], 
                 col=3, pch=19)
          lines(bb$scattering.angle, eco$offset[2,], 
                col=3)
          lines(bb$scattering.angle, eco$offset[1,], 
                col=4)
          
          lines(bb$scattering.angle, cal$cal$Offset[4:6], 
                col=3,lwd=3, lty=2)
          lines(bb$scattering.angle, cal$cal$Offset[1:3], 
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
        } else {
          minVSF =  min(bb$Betau.mean - bb$Betau.sd)
          maxVSF =  max(bb$Betau.mean + bb$Betau.sd)
          
          png(file=paste(path.png,"/",log$ECO.filename[i], ".png", sep=""),
              width=6, height=8, units="in", res=300)
          
          par(mfrow=c(3,1))
          par(mar=c(4,5,1,1))
          plot(bb$scattering.angle, eco$offset, 
               xlab="Scattering Angle", 
               ylab="Offset",
               ylim=c(min(c(eco$offset,cal$cal$Offset)),
                      max(c(eco$offset,cal$cal$Offset))), 
               xlim=c(90,180),  pch=19)
          lines(bb$scattering.angle, eco$offset)
          if (log$ECO.bands[i] =="B") lines(bb$scattering.angle, cal$cal$Offset[1:3],lwd=3, lty=2)
          if (log$ECO.bands[i] =="G") lines(bb$scattering.angle, cal$cal$Offset[4:6],lwd=3, lty=2)
          if (log$ECO.bands[i] =="R") lines(bb$scattering.angle, cal$cal$Offset[7:9],lwd=3, lty=2)
          
          legend("topright", c("Darks", "Calibration"), lwd=c(1,3), lty=c(1,2))
          
          
          plot(bb$scattering.angle, bb$Betau.mean, 
               xlim=c(90,180), pch=19, col=4,
               ylim=c(minVSF, maxVSF),
               xlab="Scattering Angle", 
               ylab=expression(paste(beta,"(",m^-1 ,sr^-1,")")),
               main=paste(log$Station[i], log$DateTime[i]))
          if (eco$dark.offset) title(sub="Dark offset applied")
          errorbars(bb$scattering.angle, bb$Betau.mean,xe=c(0,0,0),ye=bb$Betau.sd)
          lines(bb$scattering.angle, bb$Betau.mean)
          points(bb$scattering.angle, bb$Beta,pch=25)
          legend("topright", c("uncor.", "corrected"), pch=c(19,25))
          legend("bottomright", as.character(bb$waves),pch=c(19,25))
          
          plot(bb$waves, bb$bb, 
               xlab="Wavelength", pch=19,
               ylab=expression(b[b](m^-1)))

          dev.off()
        }
        
      }
      if (as.character(log$ECO.type[i]) == "BB9") {
        print("Plot BB9 data")
        minVSF =  min(bb$Betau.mean - bb$Betau.sd)
        maxVSF =  max(bb$Betau.mean + bb$Betau.sd)
        
        png(file=paste(path.png,"/",log$ECO.filename[i], ".png", sep=""),
            width=6, height=8, units="in", res=300)
        
        par(mfrow=c(3,1))
        par(mar=c(4,5,1,1))
        
        ##### Plot the Offsets
        plot(bb$waves, eco$offset, 
             xlab=expression(lambda), 
             ylab="Offset",
             ylim=c(min(c(eco$offset,cal$cal$Offset)),
                    max(c(eco$offset,cal$cal$Offset))),
             pch=19)
        lines(bb$waves, eco$offset)
        lines(bb$waves, cal$cal$Offset,lwd=3, lty=2)
        legend("topright", c("Darks", "Calibration"), lwd=c(1,3), lty=c(1,2))
        
        
        ##### Plot the VSF
        plot(bb$waves, bb$Betau.mean, 
             pch=19, col=4,
             ylim=c(minVSF, maxVSF),
             xlab=expression(lambda), 
             ylab=expression(paste(beta,"(",m^-1 ,sr^-1,")")),
             main=paste(log$Station[i], log$DateTime[i]))
        if (eco$dark.offset) title(sub="Dark offset applied")
        errorbars(bb$waves, bb$Betau.mean,xe=rep(0,9),ye=bb$Betau.sd)
        lines(bb$waves, bb$Betau.mean)
        points(bb$waves, bb$Beta,pch=25)
        legend("topright", c("uncor.", "corrected"), pch=c(19,25))
        
        plot(bb$waves, bb$bbP, 
             xlab="Wavelength", pch=19,
             ylab=expression(b[bp](m^-1)))
        lines(bb$waves, bb$bbP)
        dev.off()
      } 
      
      # Save data in RData file format
      save(bb, file=file.path(path.out,paste0(log$ECO.filename[i], ".RData")))
      
      # update log file 
      write.table(log, file=log.file, quote = F, row.names = F, sep=",")
      
    } else print(paste("Skipping file:", log$ECO.filename[i]))
    
  } 
}
  
  
  