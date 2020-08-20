#' Read s BB-9 file
#'
#' @param filen is a BB-9 file name
#' @param raw if a logical parameter indicating whether the file is in raw count
#' 
#' @return If calibration already apply, it returns a list with Timer, Beta, BetaP, bbP, bb, waves
#'
#' @author Simon Belanger
#' @export
#'


read.BB9 <- function(filen, raw=FALSE){

  if (raw) {
    df = read.table(filen, header=F, skip=5)
    Timer = df[,4]
    raw <- as.matrix(df[,c(6,8,10,12,14,16,18,20,22)])
    waves <- as.numeric(df[1,c(5,7,9,11,13,15,17,19,21)])
    
    return(list(Timer=Timer, raw=raw, waves=waves, nrec = length(Timer)))
    
  } else {
    df = read.table(filen, header=T)
    
    Timer = df[,1]
    Betau =as.matrix(df[,c(2,6,10,14,18,22,26,30,34)])
    BetaPu = as.matrix(df[,c(3,7,11,15,19,23,27,31,35)])
    bbPu = as.matrix(df[,c(4,8,12,16,20,24,28,32,36)])
    bbu = as.matrix(df[,c(5,9,13,17,21,25,29,33,37)])
    x=names(df)[c(2,6,10,14,18,22,26,30,34)]
    waves = as.numeric(str_sub(x,6,8))
    
    
    # Check whether the timer is increasing and fix it if not
    dt = rep(NA, length(Timer)-1)
    for (i in 1:(length(Timer)-1)) dt[i] = (Timer[i+1] - Timer[i])
    ix = which(dt < 0)
    while (length(ix >0)) {
      Timer[(ix[1]+1):length(Timer)] = Timer[ix[1]] + (Timer[(ix[1]+1):length(Timer)] - Timer[(ix[1]+1)])
      for (i in 1:(length(Timer)-1)) dt[i] = (Timer[i+1] - Timer[i])
      ix = which(dt < 0)
    }
    
    BB9 = list(Timer=Timer, Betau=Betau, BetaPu=BetaPu, bbPu=bbPu, bbu=bbu, waves=waves)
    
    return(BB9)
  }

}
