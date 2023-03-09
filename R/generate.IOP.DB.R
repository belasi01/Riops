
generate.IOP.dbase <- function(rootpath="./", IOP="a", depth.keep=TRUE, diag.plot=TRUE, all.station=TRUE) {
  setwd(rootpath)
  
  #List the IOP file paths
  downcast.filelist <- list.files(pattern = "IOP.fitted.down.RData$", recursive = TRUE)
  total.filelist <- list.files(pattern = "IOP.RData$", recursive = TRUE)
  
  # down.remove <- grep("EXP", downcast.filelist); downcast.filelist <- downcast.filelist[-down.remove]
  # total.remove <- grep("EXP", total.filelist); total.filelist <- total.filelist[-total.remove]
  # down.remove <- grep("hmg", downcast.filelist); downcast.filelist <- downcast.filelist[-down.remove]
  # total.remove <- grep("hmg", total.filelist); total.filelist <- total.filelist[-total.remove]
  
  downcast.filelist.check <- vector(); total.filelist.check <- vector()
  for (i in 1:length(downcast.filelist)) {
    boat <- unlist(strsplit(downcast.filelist[i], "/"))
    boat <- boat[-length(boat)]
    downcast.filelist.check[i] <- paste(boat, collapse = "/")
    
  }
  
  for (i in 1:length(total.filelist)) {
    boat <- unlist(strsplit(total.filelist[i], "/"))
    boat <- boat[-length(boat)]
    total.filelist.check[i] <- paste(boat, collapse = "/")
    
  }
  
  station.mismatch <- unique(total.filelist.check[! downcast.filelist.check %in% total.filelist.check])
  if (isTRUE(station.mismatch) == FALSE) {
    print("Castlist Generated Succesfully")
  }
  
  if (all.station == TRUE) {
    if (IOP == "a") {
      
      #Export Ap data as station-wise CSV format
      for(i in 1:length(downcast.filelist))
      {
        boat <- unlist(strsplit(downcast.filelist[i], "/"))
        fname <- boat[1]
        if (boat[2] == "IOP") {
          print(paste0(downcast.filelist[i], "is read from ASPH data"))
          load(downcast.filelist[[i]])
          load(total.filelist[[i]])
          if (is.null(dim(IOP.fitted.down$ASPH$a))) {
            print(paste0("No downcast data found for ", downcast.filelist[[i]]))
            next()
          }
          rownames(IOP.fitted.down$ASPH$a)<-as.character(IOP.fitted.down$Depth)
          colnames(IOP.fitted.down$ASPH$a)<-as.character(IOP$ASPH$wl)
          write.csv(t(IOP.fitted.down$ASPH$a[complete.cases(IOP.fitted.down$ASPH$a[,c(2:5)]),]), file = paste0(getwd(), "/absorption/", fname, "_ASPH", '.csv'))
        } else {
          print(paste0(downcast.filelist[i]," is read from AC-S Data"))
          load(downcast.filelist[[i]])
          load(total.filelist[[i]])
          if (is.null(dim(IOP.fitted.down$ACS$a))) {
            print(paste0("No downcast data found for ", downcast.filelist[[i]]))
            next()
          }
          if (is.null(dim(IOP$ACS$a))) {
            print(paste0("No cast data found for ", total.filelist[[i]]))
            next()
          }
          
          rownames(IOP.fitted.down$ACS$a)<-as.character(IOP.fitted.down$Depth)
          colnames(IOP.fitted.down$ACS$a)<-as.character(IOP$ACS$a.wl)
          write.csv(t(IOP.fitted.down$ACS$a[complete.cases(IOP.fitted.down$ACS$a[,c(2:5)]),]), file = paste0(getwd(), "/absorption/", fname, "_ACS", '.csv'))
        }
        
      }
      print("Station specific absorption data DB generation: DONE")
      
      #Create a single CSV for all station acquired absorption
      kildir_csvfiles <- normalizePath(list.files(pattern="*ASPH.csv", path = "./absorption/", full.names = T))
      saucier_csvfiles <- normalizePath(list.files(pattern = "*ACS.csv", path = "./absorption/", full.names = T))
      if (depth.keep == TRUE) {
        # For all the depths of Kildir
        idata <- list()
        for (f in 1:length(kildir_csvfiles)) {
          
          idata[[f]]<-read.csv(kildir_csvfiles[f])
          depth <- substr(colnames(idata[[f]]),2,30)
          station <- substr(kildir_csvfiles[[f]],17,23)
          station <- rep(station,length(depth)-1)
          if (f==1)
          { station <- c("",station)
          idata[[f]]<-rbind(station,depth,idata[[f]])
          }
          else
            idata[[f]]<-rbind(station,depth[2:length(depth)],idata[[f]][c(2:length(depth))])
        }
        rm(depth,f,station)
        
        mergeddata <- idata[[1]]
        
        for (d in 2:length(idata))
          mergeddata <- cbind(mergeddata,idata[[d]])
        
        write.csv(mergeddata, file = paste0("../absorption_final/At-w.All_ASPH_depth.csv"))
        print("Unified full z profiles of ASPH absorption data DB generation: DONE")
        ###########################################################
        
        #For all depths for Saucier
        idata <- list()
        for (f in 1:length(saucier_csvfiles)) {
          
          idata[[f]]<-read.csv(saucier_csvfiles[f])
          depth <- substr(colnames(idata[[f]]),2,30)
          #depth <- depth[1:2]
          station <- unlist(strsplit(saucier_csvfiles[[f]], "_"))
          station <- substr(station[2],8,14)
          station <- rep(station,length(depth)-1)
          if (f==1)
          { station <- c("wavelength",station)
          idata[[f]]<-rbind(station,depth,idata[[f]])
          } else {
            idata[[f]]<-rbind(station,depth[2:length(depth)],idata[[f]][c(2:length(depth))])
          }
        }
        rm(depth,f,station)
        
        mergeddata <- idata[[1]]
        
        for (d in 2:length(idata))
          mergeddata <- cbind(mergeddata,idata[[d]])
        
        write.csv(mergeddata, file = paste0("../absorption_final/At-w.All_ACS_depth.csv"))
        print("Unified full z profiles of ASPH absorption data DB generation: DONE")
        ###########################################################################
      } else {
        #For only surface values of Kildir
        idata <- list()
        for (f in 1:length(kildir_csvfiles)) {
          
          idata[[f]]<-read.csv(kildir_csvfiles[f])[ ,1:2]
          depth <- substr(colnames(idata[[f]]),2,30)
          #depth <- depth[1:2]
          station <- unlist(strsplit(kildir_csvfiles[[f]], "_"))
          station <- station[2]
          #station <- rep(station,length(depth)-1)
          if (f==1)
          { station <- c("wavelength",station)
          idata[[f]]<-rbind(station,idata[[f]])
          } else {
            idata[[f]]<-rbind(station,idata[[f]][c(2:length(depth))])
          }
        }
        rm(depth,f,station)
        
        mergeddata <- idata[[1]]
        
        for (d in 2:length(idata))
          mergeddata <- cbind(mergeddata,idata[[d]])
        
        write.csv(mergeddata, file = paste0("../absorption_final/At-w.All_ASPH_surf.csv"))
        print("Surface ASPH absorption data DB generation: DONE")
        ###########################################################
        
        #For only surface values of Saucier
        idata <- list()
        for (f in 1:length(saucier_csvfiles)) {
          
          idata[[f]]<-read.csv(saucier_csvfiles[f])[ ,1:2]
          depth <- substr(colnames(idata[[f]]),2,30)
          #depth <- depth[1:2]
          station <- unlist(strsplit(saucier_csvfiles[[f]], "_"))
          station <- station[2]
          #station <- rep(station,length(depth)-1)
          if (f==1)
          { station <- c("wavelength",station)
          idata[[f]]<-rbind(station,idata[[f]])
          } else {
            idata[[f]]<-rbind(station,idata[[f]][c(2:length(depth))])
          }
        }
        rm(depth,f,station)
        
        mergeddata <- idata[[1]]
        
        for (d in 2:length(idata))
          mergeddata <- cbind(mergeddata,idata[[d]])
        
        write.csv(mergeddata, file = paste0("../absorption_final/At-w.All_ACS_surf.csv"))
        print("Surface ACS absorption data DB generation: DONE")
        ###########################################################################
      }
      
      if (depth.keep == FALSE && diag.plot == TRUE) {
        #Read the unified surface absoprtion and plot as per stations
        plotlist <- list.files(path = "./absorption_final/", pattern = "*_surf.csv")
        sensor.name <- unlist(strsplit(plotlist, "_"))[2]
        if (sensor.name == "Kildir") {
          sensor.name <- "ASPH"
        } else {
          sensor.name <- "ACS"
        }
        
        g <- list()
        for (i in 1:length(plotlist)) {
          mergeddata <- read.csv(paste0("./absorption_final/", plotlist[i]), skip = 1, header = TRUE)
          mergeddata <- mergeddata[-3]
          station <-  substr(colnames(mergeddata),1,30)
          station <- station[3:length(station)]
          ap <- mergeddata[1:dim(mergeddata)[1],2:dim(mergeddata)[2]]
          z <- c(1:length(station))
          colnames(ap) <- c("wavelength",station)
          
          library(reshape2)
          pdata <- reshape2::melt(ap, id.vars="wavelength")
          pdata$value <- as.numeric(pdata$value)
          pdata$wavelength <- as.numeric(pdata$wavelength)
          zdata <- pdata
          zdata$value[zdata$value <0 ] <- 0
          
          library(ggplot2)
          xmin <- 360; xmax <- 760;  xstp <- 50; xlbl <- 'Wavelength [nm]'
          ymin <- 0; ymax <- 3.5; ystp <- ymax/5; ylbl <- expression(paste("Non-water absorption (  ",a[t-w],"  ) ( ", m^-1," )"))
          asp_rat <-  (xmax-xmin)/(ymax-ymin)
          g[[i]] <- ggplot(data=zdata,aes(x = wavelength)) +
            geom_line(aes( y=value, color=as.factor(variable)), show.legend = FALSE, size = 1.5) +
            coord_fixed(ratio = asp_rat, xlim = c(xmin, xmax),
                        ylim = c(ymin, ymax), expand = FALSE, clip = "on") +
            scale_x_continuous(name = xlbl, limits = c(xmin, xmax),
                               breaks = seq(xmin, xmax, xstp))  +
            scale_y_continuous(name = ylbl, limits = c(ymin, ymax),
                               breaks = seq(ymin, ymax, ystp))  +
            ggtitle(paste0(sensor.name))+
            theme(plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
                  axis.text.x = element_text(size = 15, color = 'black', angle = 0),
                  axis.text.y = element_text(size = 15, color = 'black', angle = 0),
                  axis.title.x = element_text(size = 20),
                  axis.title.y = element_text(size = 20),
                  axis.ticks.length = unit(.25, "cm"),
                  #legend.position = legend_position,
                  legend.direction = "vertical",
                  legend.title=element_blank(),
                  legend.text = element_text(colour = "black", size = 15, face = "plain"),
                  legend.background = element_rect(fill = NA, size = 0.5,
                                                   linetype = "solid", colour = 0),
                  legend.key = element_blank(),
                  legend.justification = c("left", "top"),
                  panel.background = element_blank(),
                  panel.grid.major = element_line(colour = "grey",
                                                  size = 0.5, linetype = "dotted"),
                  panel.grid.minor = element_blank(),
                  panel.border = element_rect(colour = "black", fill = NA, size = 1.5))
          
          ggsave(paste0("./absorption_final/at-w_", sensor.name,".png" ), 
                 plot = g[[i]],scale = 1.7, width = 4.5, height = 4.5, units = "in",dpi = 300)
          
        }
        print("Absorption spectral Plot(s) generation: DONE")
      }
    }
    if (IOP == "bb") {
      
      #Export bbP data as station-wise CSV format
      for(i in 1:length(downcast.filelist))
      {
        boat <- unlist(strsplit(downcast.filelist[i], "/"))
        fname <- boat[1]
        if (boat[2] == "IOP") {
          print(paste0(downcast.filelist[i], "is read from HS6 data"))
          load(downcast.filelist[[i]])
          load(total.filelist[[i]])
          if (is.null(dim(IOP.fitted.down$HS6$bbP))) {
            print(paste0("No downcast data found for ", downcast.filelist[[i]]))
            next()
          }
          if (is.null(dim(IOP$HS6$bbP.corrected))) {
            print(paste0("No cast data found for ", total.filelist[[i]]))
            next()
          }
          rownames(IOP.fitted.down$HS6$bbP)<-as.character(IOP.fitted.down$Depth)
          colnames(IOP.fitted.down$HS6$bbP)<-as.character(IOP$HS6$wl)
          write.csv(t(IOP.fitted.down$HS6$bbP[complete.cases(IOP.fitted.down$HS6$bbP[,c(2:5)]),]), file = paste0(getwd(), "/backscatter/", fname, "_HS6", '.csv'))
        } else {
          print(paste0(downcast.filelist[i]," is read from BB9 Data"))
          load(downcast.filelist[[i]])
          load(total.filelist[[i]])
          if (is.null(dim(IOP.fitted.down$BB9$bbP))) {
            print(paste0("No downcast data found for ", downcast.filelist[[i]]))
            next()
          }
          if (is.null(dim(IOP$BB9$bbP.corrected))) {
            print(paste0("No cast data found for ", total.filelist[[i]]))
            next()
          }
          
          rownames(IOP.fitted.down$BB9$bbP)<-as.character(IOP.fitted.down$Depth)
          colnames(IOP.fitted.down$BB9$bbP)<-as.character(IOP$BB9$waves)
          write.csv(t(IOP.fitted.down$BB9$bbP[complete.cases(IOP.fitted.down$BB9$bbP[,c(2:5)]),]), file = paste0(getwd(), "/backscatter/", fname, "_BB9", '.csv'))
        }
        
      }
      print("Station specific absorption data DB generation: DONE")
      
      #Create a single CSV for all station acquired absorption
      kildir_csvfiles <- normalizePath(list.files(pattern="*HS6.csv", path = "./backscatter/", full.names = T))
      saucier_csvfiles <- normalizePath(list.files(pattern = "*BB9.csv", path = "./backscatter/", full.names = T))
      if (depth.keep == TRUE) {
        # For all the depths of Kildir
        idata <- list()
        for (f in 1:length(kildir_csvfiles)) {
          
          idata[[f]]<-read.csv(kildir_csvfiles[f])
          depth <- substr(colnames(idata[[f]]),2,30)
          station <- substr(kildir_csvfiles[[f]],17,23)
          station <- rep(station,length(depth)-1)
          if (f==1)
          { station <- c("",station)
          idata[[f]]<-rbind(station,depth,idata[[f]])
          }
          else
            idata[[f]]<-rbind(station,depth[2:length(depth)],idata[[f]][c(2:length(depth))])
        }
        rm(depth,f,station)
        
        mergeddata <- idata[[1]]
        
        for (d in 2:length(idata))
          mergeddata <- cbind(mergeddata,idata[[d]])
        
        write.csv(mergeddata, file = paste0("../backscatter_final/Bbp.All_HS6_depth.csv"))
        print("Unified full z profiles of HS6 backscatter data DB generation: DONE")
        #####################################################################################
        #For all depths for Saucier
        idata <- list()
        for (f in 1:length(saucier_csvfiles)) {
          
          idata[[f]]<-read.csv(saucier_csvfiles[f])
          depth <- substr(colnames(idata[[f]]),2,30)
          #depth <- depth[1:2]
          station <- unlist(strsplit(saucier_csvfiles[[f]], "_"))
          station <- substr(station[2],8,14)
          station <- rep(station,length(depth)-1)
          if (f==1)
          { station <- c("wavelength",station)
          idata[[f]]<-rbind(station,depth,idata[[f]])
          } else {
            idata[[f]]<-rbind(station,depth[2:length(depth)],idata[[f]][c(2:length(depth))])
          }
        }
        rm(depth,f,station)
        
        mergeddata <- idata[[1]]
        
        for (d in 2:length(idata))
          mergeddata <- cbind(mergeddata,idata[[d]])
        
        write.csv(mergeddata, file = paste0("../backscatter_final/Bbp.All_BB9_depth.csv"))
        print("Unified full z profiles of BB9 backscatter data DB generation: DONE")
        ######################################################################################
      } else {
        #For only surface values of Kildir
        idata <- list()
        for (f in 1:length(kildir_csvfiles)) {
          
          idata[[f]]<-read.csv(kildir_csvfiles[f])[ ,1:2]
          depth <- substr(colnames(idata[[f]]),2,30)
          #depth <- depth[1:2]
          station <- unlist(strsplit(kildir_csvfiles[[f]], "_"))
          station <- station[2]
          #station <- rep(station,length(depth)-1)
          if (f==1)
          { station <- c("wavelength",station)
          idata[[f]]<-rbind(station,idata[[f]])
          } else {
            idata[[f]]<-rbind(station,idata[[f]][c(2:length(depth))])
          }
        }
        rm(depth,f,station)
        
        mergeddata <- idata[[1]]
        
        for (d in 2:length(idata))
          mergeddata <- cbind(mergeddata,idata[[d]])
        
        write.csv(mergeddata, file = paste0("../backscatter_final/Bbp.All_HS6_surf.csv"))
        print("Surface HS6 backscatter DB generation: DONE")
        ###########################################################################
        
        #For only surface values of Saucier
        idata <- list()
        for (f in 1:length(saucier_csvfiles)) {
          
          idata[[f]]<-read.csv(saucier_csvfiles[f])[ ,1:2]
          depth <- substr(colnames(idata[[f]]),2,30)
          #depth <- depth[1:2]
          station <- unlist(strsplit(saucier_csvfiles[[f]], "_"))
          station <- station[2]
          #station <- rep(station,length(depth)-1)
          if (f==1)
          { station <- c("wavelength",station)
          idata[[f]]<-rbind(station,idata[[f]])
          } else {
            idata[[f]]<-rbind(station,idata[[f]][c(2:length(depth))])
          }
        }
        rm(depth,f,station)
        
        mergeddata <- idata[[1]]
        
        for (d in 2:length(idata))
          mergeddata <- cbind(mergeddata,idata[[d]])
        
        write.csv(mergeddata, file = paste0("../backscatter_final/Bbp.All_BB9_surf.csv"))
        print("Surface BB9 backscatter DB generation: DONE")
        ###########################################################################
      }
      
      if (depth.keep == FALSE && diag.plot == TRUE) {
        #Read the unified surface absoprtion and plot as per stations
        plotlist <- list.files(path = "./backscatter_final/", pattern = "*_surf.csv")
        sensor.name <- unlist(strsplit(plotlist, "_"))[2]
        if (sensor.name == "Kildir") {
          sensor.name <- "ASPH"
        } else {
          sensor.name <- "ACS"
        }
        
        g <- list()
        for (i in 1:length(plotlist)) {
          mergeddata <- read.csv(paste0("./backscatter_final/", plotlist[i]), skip = 1, header = TRUE)
          mergeddata <- mergeddata[-3]
          station <-  substr(colnames(mergeddata),8,30)
          station <- station[3:length(station)]
          ap <- mergeddata[1:dim(mergeddata)[1],2:dim(mergeddata)[2]]
          z <- c(1:length(station))
          colnames(ap) <- c("wavelength",station)
          #ap <- ap[-18]
          library(reshape2)
          pdata <- reshape2::melt(ap, id.vars="wavelength")
          pdata$value <- as.numeric(pdata$value)
          pdata$wavelength <- as.numeric(pdata$wavelength)
          zdata <- pdata
          zdata$value[zdata$value <0 ] <- 0
          
          library(ggplot2)
          xmin <- 400; xmax <- 720;  xstp <- 50; xlbl <- 'Wavelength [nm]'
          ymin <- 0; ymax <- 0.03; ystp <- ymax/5; ylbl <- expression(paste("particulate backscatter (  ",b[bp],"  ) ( ", m^-1," )"))
          asp_rat <-  (xmax-xmin)/(ymax-ymin)
          g1 <- ggplot(data=zdata,aes(x = wavelength)) +
            geom_line(aes( y=value, color=as.factor(variable)), show.legend = FALSE, size = 1.5) +
            coord_fixed(ratio = asp_rat, xlim = c(xmin, xmax),
                        ylim = c(ymin, ymax), expand = FALSE, clip = "on") +
            scale_x_continuous(name = xlbl, limits = c(xmin, xmax),
                               breaks = seq(xmin, xmax, xstp))  +
            scale_y_continuous(name = ylbl, limits = c(ymin, ymax),
                               breaks = seq(ymin, ymax, ystp))  +
            ggtitle(paste0(sensor.name))+
            theme(plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
                  axis.text.x = element_text(size = 15, color = 'black', angle = 0),
                  axis.text.y = element_text(size = 15, color = 'black', angle = 0),
                  axis.title.x = element_text(size = 20),
                  axis.title.y = element_text(size = 20),
                  axis.ticks.length = unit(.25, "cm"),
                  #legend.position = legend_position,
                  legend.direction = "vertical",
                  legend.title=element_blank(),
                  legend.text = element_text(colour = "black", size = 15, face = "plain"),
                  legend.background = element_rect(fill = NA, size = 0.5,
                                                   linetype = "solid", colour = 0),
                  legend.key = element_blank(),
                  legend.justification = c("left", "top"),
                  panel.background = element_blank(),
                  panel.grid.major = element_line(colour = "grey",
                                                  size = 0.5, linetype = "dotted"),
                  panel.grid.minor = element_blank(),
                  panel.border = element_rect(colour = "black", fill = NA, size = 1.5))
          
          ggsave(paste0("./backscatter_final/bbp_", sensor.name,".png" ), 
                 plot = g[[i]],scale = 1.7, width = 4.5, height = 4.5, units = "in",dpi = 300)
          
        }
        print("Backscatter spectral Plot(s) generation: DONE")
      }
    }
    if (IOP == "c") {
      #Export C data as station-wise CSV format
      for(i in 1:length(downcast.filelist))
      {
        boat <- unlist(strsplit(downcast.filelist[i], "/"))
        fname <- boat[1]
        if (boat[2] == "IOP") {
          print(paste0(downcast.filelist[i], "is from ASPH data; thus station skipped"))
          load(downcast.filelist[[i]])
          if (is.null(dim(IOP.fitted.down$ASPH$a))) {
            print(paste0("No downcast data found for ", downcast.filelist[[i]]))
            next()
          }
          #rownames(IOP.fitted.down$ASPH$a)<-as.character(IOP.fitted.down$Depth)
          #colnames(IOP.fitted.down$ASPH$a)<-as.character(IOP$ASPH$wl)
          #write.csv(t(IOP.fitted.down$ASPH$a[complete.cases(IOP.fitted.down$ASPH$a[,c(2:5)]),]), file = paste0(getwd(), "/absorption/", fname, "_Kildir", '.csv'))
        } else {
          print(paste0(downcast.filelist[i]," attenuation is read from ACS Data"))
          load(downcast.filelist[[i]])
          load(total.filelist[[i]])
          if (is.null(dim(IOP.fitted.down$ACS$a))) {
            print(paste0("No downcast data found for ", downcast.filelist[[i]]))
            next()
          }
          if (is.null(dim(IOP$ACS$a))) {
            print(paste0("No cast data found for ", total.filelist[[i]]))
            next()
          }
          
          rownames(IOP.fitted.down$ACS$c)<-as.character(IOP.fitted.down$Depth)
          colnames(IOP.fitted.down$ACS$c)<-as.character(IOP$ACS$a.wl)
          write.csv(t(IOP.fitted.down$ACS$c[complete.cases(IOP.fitted.down$ACS$c[,c(2:5)]),]), file = paste0(getwd(), "/attenuation/", fname, "_ACS", '.csv'))
        }
        
      }
      print("Station specific attenuation data DB generation: DONE")
      
      #Create a single CSV for all station acquired attenuation
      saucier_csvfiles <- normalizePath(list.files(pattern = "*ACS.csv", path = "./attenuation/", full.names = T))
      if (depth.keep == TRUE) {
        #For all depths for Saucier
        idata <- list()
        for (f in 1:length(saucier_csvfiles)) {
          
          idata[[f]]<-read.csv(saucier_csvfiles[f])
          depth <- substr(colnames(idata[[f]]),2,30)
          #depth <- depth[1:2]
          station <- unlist(strsplit(saucier_csvfiles[[f]], "_"))
          station <- substr(station[2],8,14)
          station <- rep(station,length(depth)-1)
          if (f==1)
          { station <- c("wavelength",station)
          idata[[f]]<-rbind(station,depth,idata[[f]])
          } else {
            idata[[f]]<-rbind(station,depth[2:length(depth)],idata[[f]][c(2:length(depth))])
          }
        }
        rm(depth,f,station)
        
        mergeddata <- idata[[1]]
        
        for (d in 2:length(idata))
          mergeddata <- cbind(mergeddata,idata[[d]])
        
        write.csv(mergeddata, file = paste0("../attenuation_final/Ct-w.All_ACS_depth.csv"))
        ###########################################################################
      } else {
        #For only surface values of Saucier
        idata <- list()
        for (f in 1:length(saucier_csvfiles)) {
          
          idata[[f]]<-read.csv(saucier_csvfiles[f])[ ,1:2]
          depth <- substr(colnames(idata[[f]]),2,30)
          #depth <- depth[1:2]
          station <- unlist(strsplit(saucier_csvfiles[[f]], "_"))
          station <- station[2]
          #station <- rep(station,length(depth)-1)
          if (f==1)
          { station <- c("wavelength",station)
          idata[[f]]<-rbind(station,idata[[f]])
          } else {
            idata[[f]]<-rbind(station,idata[[f]][c(2:length(depth))])
          }
        }
        rm(depth,f,station)
        
        mergeddata <- idata[[1]]
        
        for (d in 2:length(idata))
          mergeddata <- cbind(mergeddata,idata[[d]])
        
        write.csv(mergeddata, file = paste0("../attenuation_final/Ct-w.All_ACS_surf.csv"))
        ###########################################################################
      }
    }
    if (depth.keep == FALSE && diag.plot == TRUE) {
      #Read the unified surface absoprtion and plot as per stations
      plotlist <- list.files(path = "./attenuation_final/", pattern = "*_surf.csv")
      sensor.name <- unlist(strsplit(plotlist, "_"))[2]
      if (sensor.name == "Kildir") {
        sensor.name <- "ASPH"
      } else {
        sensor.name <- "ACS"
      }
      
      g <- list()
      for (i in 1:length(plotlist)) {
        mergeddata <- read.csv(paste0("./attenuation_final/", plotlist[i]), skip = 1, header = TRUE)
        mergeddata <- mergeddata[-3]
        station <-  substr(colnames(mergeddata),1,30)
        station <- station[3:length(station)]
        ap <- mergeddata[1:dim(mergeddata)[1],2:dim(mergeddata)[2]]
        z <- c(1:length(station))
        colnames(ap) <- c("wavelength",station)
        ap <- ap[-c(2,3,4,18)]
        library(reshape2)
        pdata <- reshape2::melt(ap, id.vars="wavelength")
        pdata$value <- as.numeric(pdata$value)
        pdata$wavelength <- as.numeric(pdata$wavelength)
        zdata <- pdata
        zdata$value[zdata$value <0 ] <- 0
        
        library(ggplot2)
        xmin <- 360; xmax <- 760;  xstp <- 50; xlbl <- 'Wavelength [nm]'
        ymin <- 0; ymax <- 5; ystp <- ymax/5; ylbl <- expression(paste("Non-water attenuation (  ",c[t-w],"  ) ( ", m^-1," )"))
        asp_rat <-  (xmax-xmin)/(ymax-ymin)
        g[[i]] <- ggplot(data=zdata,aes(x = wavelength)) +
          ggtitle("Saucier")+
          geom_line(aes( y=value, color=as.factor(variable)), size = 1.5, show.legend = FALSE) +
          coord_fixed(ratio = asp_rat, xlim = c(xmin, xmax),
                      ylim = c(ymin, ymax), expand = FALSE, clip = "on") +
          scale_x_continuous(name = xlbl, limits = c(xmin, xmax),
                             breaks = seq(xmin, xmax, xstp))  +
          scale_y_continuous(name = ylbl, limits = c(ymin, ymax),
                             breaks = seq(ymin, ymax, ystp))  +
          theme(plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
                axis.text.x = element_text(size = 15, color = 'black', angle = 0),
                axis.text.y = element_text(size = 15, color = 'black', angle = 0),
                axis.title.x = element_text(size = 20),
                axis.title.y = element_text(size = 20),
                axis.ticks.length = unit(.25, "cm"),
                #legend.position = legend_position,
                legend.direction = "vertical",
                legend.title=element_blank(),
                legend.text = element_text(colour = "black", size = 15, face = "plain"),
                legend.background = element_rect(fill = NA, size = 0.5,
                                                 linetype = "solid", colour = 0),
                legend.key = element_blank(),
                legend.justification = c("left", "top"),
                panel.background = element_blank(),
                panel.grid.major = element_line(colour = "grey",
                                                size = 0.5, linetype = "dotted"),
                panel.grid.minor = element_blank(),
                panel.border = element_rect(colour = "black", fill = NA, size = 1.5))
        
        ggsave(paste0("./attenuation_final/ct-w_", sensor.name,".png" ), 
               plot = g[[i]],scale = 1.7, width = 4.5, height = 4.5, units = "in",dpi = 300)
        
      }
      print("Backscatter spectral Plot(s) generation: DONE")
    }
  }
}
  