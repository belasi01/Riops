#' Read an AC-s file
#'
#' @param filen is an ACs file name
#'
#' @return A list with Timer, c.wl, a.wl, c, a,
#' iTemp, Sal, Depth, XTemp, Cond
#'
#' @author Simon Belanger
#' @export



read.ACs <- function(filen){
  
  #Reads and store header
  id = file(filen, "r")
  nrec = 10
  for (i in 1:nrec){
    line = unlist(strsplit(readLines(con=id, n =1), "\t") )
    #print(line)
    if (length(line) > 3) {
      if (line[4] == "; output wavelengths") nwaves = as.numeric(line[1])
      if (line[4] == "; number of temperature bins") ntbins = as.numeric(line[1])
    }
  }
  line = unlist(strsplit(readLines(con=id, n =1), "\t") ) # Temperature bins
  tbins = as.numeric(line[6:(ntbins+5)])
  nrec = nrec + 1
  # Read temperature bins
  tbins.offset.c = matrix(NA, nrow=nwaves, ncol=ntbins)
  tbins.offset.a = matrix(NA, nrow=nwaves, ncol=ntbins)
  for (i in 1:nwaves) {
    line = unlist(strsplit(readLines(con=id, n =1), "\t") )
    tbins.offset.c[i,] = as.numeric(line[7:(ntbins+6)])
    tbins.offset.a[i,] = as.numeric(line[(ntbins+8):(ntbins+ntbins+7)])
    nrec = nrec + 1
  }
  # skip next 2 lines
  line = unlist(strsplit(readLines(con=id, n =1), "\t") )
  line = unlist(strsplit(readLines(con=id, n =1), "\t") )
  nrec = nrec + 2
  close(id)
  
  # Read data
  # Reopen file to store the header
  id = file(filen, "r")
  nrec = 13+nwaves
  Header = rep("NA", nrec)
  for (i in 1:nrec) {
    Header[i] = readLines(con=id, n =1)  
  }
  names = unlist(strsplit(readLines(con=id, n =1), "\t")  )
  close(id)
  
  df = read.table(filen, skip=nrec+1)
  Timer = df$V1
  
  #Timer = df$Time.ms.
  ix.c.end = 1+nwaves
  ix.a.end = ix.c.end+nwaves
  c = as.matrix(df[,2:ix.c.end])
  a = as.matrix(df[,(ix.c.end+1):ix.a.end])
  
  if (!is.null(df$iTemp.C.)) iTemp = df$iTemp.C. else iTemp = NA
  if (!is.null(df$Conduct)) Cond = df$Conduct else Cond = NA
  if (!is.null(df$Depth)) Depth = df$Depth  else Depth = NA
  if (!is.null(df$Temp)) XTemp = df$XTemp  else  XTemp = NA
  if (!is.null(df$Sal)) Sal = df$Salinity else   Sal = NA
  
  XLambda = names[2:ix.c.end]
  c.wl = as.numeric(str_sub(XLambda, 2,6))
  
  XLambda = names[(ix.c.end+1):ix.a.end]
  a.wl = as.numeric(str_sub(XLambda, 2,6))
  
  
  # Check whether the timer is increasing and fix it if not
  dt = rep(NA, length(Timer)-1)
  for (i in 1:(length(Timer)-1)) dt[i] = (Timer[i+1] - Timer[i])
  ix = which(dt < 0)
  while (length(ix >0)) {
    Timer[(ix[1]+1):length(Timer)] = Timer[ix[1]] + (Timer[(ix[1]+1):length(Timer)] - Timer[(ix[1]+1)])
    for (i in 1:(length(Timer)-1)) dt[i] = (Timer[i+1] - Timer[i])
    ix = which(dt < 0)
  }
  
  ACs = list(Timer=Timer, c.wl=c.wl, a.wl=a.wl, c=c, a=a,
             iTemp=iTemp, Sal=Sal, Depth=Depth, XTemp= XTemp, Cond=Cond)
  
  return(ACs)
}
