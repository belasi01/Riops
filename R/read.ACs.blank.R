# This function read AC-s data and return a list. 


read.ACs.blank <- function(fn){
  
  # Find the number of waves
  id = file(fn, "r")
  line = readLines(con=id, n =1)
  n=1
  while (!str_detect(line, "output wavelengths")) {
    line = readLines(con=id, n =1)
    print(line)
    n=n+1
  }
  nwaves <- as.numeric(unlist(strsplit(line, "\t"))[1]) 
  close(id)
  
  
  # Reopen file to store the header
  id = file(fn, "r")
  nrec = 13+nwaves
  Header = rep("NA", nrec)
  for (i in 1:nrec) {
    Header[i] = readLines(con=id, n =1)  
  }
  names = unlist(strsplit(readLines(con=id, n =1), "\t")  )
  
  close(id)
  
  df = read.table(fn, skip=nrec+1)
  Timer = df$V1
  ix.c.end = 1+nwaves
  ix.a.end = ix.c.end+nwaves
  c = as.matrix(df[,2:ix.c.end])
  a = as.matrix(df[,(ix.c.end+1):ix.a.end])

  XLambda = names[2:ix.c.end]
  c.wl = as.numeric(str_sub(XLambda, 2,6))
  
  XLambda = names[(ix.c.end+1):ix.a.end]
  a.wl = as.numeric(str_sub(XLambda, 2,6))
  
 
  ACs = list(Header=Header, Timer=Timer, c=c, a=a, c.wl=c.wl, a.wl=a.wl)
  
  return(ACs)
}