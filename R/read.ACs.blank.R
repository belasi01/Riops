# This function read AC-s data and return a list. 


read.ACs.blank <- function(fn){
  
  #Reads and store header
  
  
  # Reopen file to store the header
  id = file(fn, "r")
  nrec = 99
  Header = rep("NA", nrec)
  for (i in 1:nrec) {
    Header[i] = readLines(con=id, n =1)  
  }
  names = unlist(strsplit(readLines(con=id, n =1), "\t")  )
  
  close(id)
  
  df = read.table(fn, skip=nrec+1)
  Timer = df$V1
  c = as.matrix(df[,2:87])
  a = as.matrix(df[,88:173])

  XLambda = names[2:87]
  c.wl = as.numeric(str_sub(XLambda, 2,6))
  
  XLambda = names[88:173]
  a.wl = as.numeric(str_sub(XLambda, 2,6))
  
 
  ACs = list(Header=Header, Timer=Timer, c=c, a=a, c.wl=c.wl, a.wl=a.wl)
  
  return(ACs)
}