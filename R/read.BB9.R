#' Read s BB-9 file
#'
#' @param filen is a BB-9 file name
#'
#' @return A list with Timer, Beta, BetaP, bbP, bb, wl
#'
#' @author Simon Bélanger
#' @export
#'


read.BB9 <- function(filen){

  df = read.table(filen, header=T)

  Timer = df[,1]
  Beta =as.matrix(df[,c(2,6,10,14,18,22,26,30,34)])
  BetaP = as.matrix(df[,c(3,7,11,15,19,23,27,31,35)])
  bbP = as.matrix(df[,c(4,8,12,16,20,24,28,32,36)])
  bb = as.matrix(df[,c(5,9,13,17,21,25,29,33,37)])
  x=names(df)[c(2,6,10,14,18,22,26,30,34)]
  wl = as.numeric(str_sub(x,6,8))


  # Check whether the timer is increasing and fix it if not
  dt = rep(NA, length(Timer)-1)
  for (i in 1:(length(Timer)-1)) dt[i] = (Timer[i+1] - Timer[i])
  ix = which(dt < 0)
  while (length(ix >0)) {
    Timer[(ix[1]+1):length(Timer)] = Timer[ix[1]] + (Timer[(ix[1]+1):length(Timer)] - Timer[(ix[1]+1)])
    for (i in 1:(length(Timer)-1)) dt[i] = (Timer[i+1] - Timer[i])
    ix = which(dt < 0)
  }

  BB9 = list(Timer=Timer, Beta=Beta, BetaP=BetaP, bbP=bbP, bb=bb, wl=wl)

  return(BB9)
}
