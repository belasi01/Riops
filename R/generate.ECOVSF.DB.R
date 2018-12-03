generate.ECOVSF.DB <- function(log.file="ECOVSF_log.txt", data.path="./",
                           MISSION="YYY") {
  
  # Lecture des informations dans un fichier texte
  #path = paste(data.path, "/RData/", sep="")
  if (file.exists(data.path)){
    path =paste(data.path,"/RData/", sep="")
    if (file.exists(path)) {
      print("Data path exists")
    } else {
      print("The data path does not exists!")
      print("Check the path:")
      print(path)
      print("STOP processing")
      return(0)
    }
  } else {
    print("The data.path does not exits.")
    print("Put the data in data.path/RData/")
    print("STOP processing")
    return(0)
  }
  
  if (!file.exists(log.file)) {
    print("The log.file does not exits.")
    print("STOP processing")
    return(0)
  }
  
  log = read.table(file=log.file, header=T)
  nStation = length(log$Station)
  bb.m   = matrix(NA, ncol = 2, nrow=nStation)
  Station= rep("ID", nStation)
  DateTime=rep(Sys.time(), nStation)
  Depth=rep(NA, nStation)
  B.Anw=rep(NA, nStation)
  G.Anw=rep(NA, nStation)
  Salinity=rep(NA, nStation)
  
  
  for (i in 1:nStation) {
    time <- paste(unlist(str_split(log$UTCTime[i],":"))[1], unlist(str_split(log$UTCTime[i],":"))[2],sep="")
    filen <- paste(path,"/",log$Station[i],"_", log$Date[i], "_",time, ".RData", sep="")
    print(paste("Reading ", filen))
    load(filen)
    bb.m[i,]       <- bb$bb
    Station[i]   <- as.character(bb$Station)
    DateTime[i]  <- bb$DateTime
    Depth[i]     <- bb$Depth
    B.Anw[i]     <- bb$B.Anw
    G.Anw[i]     <- bb$G.Anw
    Salinity[i]  <- bb$Salinity
  }
  bb.m<-as.data.frame(bb.m)
  names(bb.m) <- paste("bb_",c(470,532), sep="")
  ECOVSF.DB <- data.frame(cbind(Station, DateTime, Depth, bb.m, B.Anw, G.Anw, Salinity))
  
  # Save data
  filen = paste(data.path,"/",MISSION,".ECOVSF.RData",sep="")
  save(ECOVSF.DB, file=filen)
  
  # Save output in ASCII format
  filen = paste(data.path,"/",MISSION,".ECOVSF.dat",sep="")
  write.table(ECOVSF.DB, file=filen, quote=F, row.names = F, sep=";")
  
  return(ECOVSF.DB)
  
  
  
}
  