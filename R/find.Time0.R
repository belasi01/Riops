find.Time0.CTD <-function(path,cast){
  
  # This function returns the time (as POSIXct) of the begining 
  # of the CTD sampling 
  
  # Read ASPH to find the t0
  setwd(path)
  print("Read ASPH data")
  filen = list.files(pattern = "CST.*\\.txt")
  ASPH = read.ASPH(filen)
  
  # Read CTD
  print("Read CTD data")
  CTD = read.CTD.DH4(paste("archives_22_T_ASCII.",cast, sep=""))
  
  
   # Plot data versus time of CTD ans ASPH to identify the time 
  # when both instruments enter or exit the water column
  par(mar = c(2,2,1,1))
  layout(matrix(c(1,2), 2, 1))
  plot(CTD$Timer, CTD$Sal)
  plot(ASPH$time, ASPH$a[,100])
  layout(matrix(c(1), 1, 1))
  plot(CTD$Timer, CTD$Sal)
  print("Click for the CTD time stamp")
  ixCTD = identify(CTD$Timer, CTD$Sal)
  plot(ASPH$time, ASPH$a[,100])
  print("Click for the ASPH time stamp")
  ixASPH = identify(ASPH$time, ASPH$a[,100])
  
  Time0 = ASPH$time[ixASPH] - CTD$Timer[ixCTD]/1000
  
  return(Time0)
}


find.Time0.LISST <-function(path){
  
  # This function returns the time (as POSIXct) of the begining 
  # of the LISST sampling 
  
  # Read ASPH to find the t0
  setwd(path)
  print("Read ASPH data")
  filen = list.files(pattern = "CST.*\\.txt")
  ASPH = read.ASPH(filen)
  
  # Read LISST
  print("Read LISST data")
  filen = list.files(pattern = "L.*\\.asc")
  LISST = read.LISST(filen)
  
  # Plot data versus time of CTD ans ASPH to identify the time 
  # when both instruments enter or exit the water column
  par(mar = c(2,2,1,1))
  layout(matrix(c(1,2), 2, 1))
  plot(LISST$c670)
  plot(ASPH$time, ASPH$a[,100])
  layout(matrix(c(1), 1, 1))
  plot(LISST$c670)
  print("Click for the LISST time stamp")
  ixLISST = identify(LISST$c670)
  plot(ASPH$time, ASPH$a[,100])
  print("Click for the ASPH time stamp")
  ixASPH = identify(ASPH$time, ASPH$a[,100])
  
  Time0 = ASPH$time[ixASPH] - ixLISST
  
  return(Time0)
  
}