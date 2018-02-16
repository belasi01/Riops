#### NOT FINISHED
# We don't have the algorithm to invert the list raw signal.

process.raw.LISST <- function(raw.lisst.file, background.file, RingArea.file){

  raw.lisst= reformat.LISST100(raw.lisst.file) # these are allready divided by 10
  background=read.table(background.file)
  RingArea = read.table(RingArea.file)

  # Compute transmission t
  r = background$V1[33]/background$V1[36]
  tau = raw.lisst[,33]/(r*raw.lisst[,36])

  data = raw.lisst[,1:32]

  # create matrix to avoid the use of a for loop
  background.m = matrix(background$V1[1:32], ncol=32, nrow = length(data[,1]), byrow = T)
  tau.m = matrix(tau, ncol=32, nrow = length(data[,1]))
  RingArea.m = matrix(t(RingArea), ncol=32, nrow = length(data[,1]), byrow = T)

  scat = data/tau.m - (background.m*raw.lisst[,36]/background$V1[36])
  cscat = scat * RingArea.m

  return(cscat)

}
