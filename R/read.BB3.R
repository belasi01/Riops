#' Read s BB-3 file
#'
#' @param filen is a BB-3 file name
#'
#' @return A list with Timer, Beta, BetaP, bbP, bb, wl
#'
#' @author Simon Belanger
#' @export
#'

#
#   NOTE: I am not sure about the time format in this file.
#


read.BB3 <- function(filen, raw = F) {
  
  if (raw) {
    df = read.table(filen, header=F, skip=5)
    Timer = df[,2]
    raw <- as.matrix(df[,c(4,6,8)])
    waves <- as.numeric(df[1,c(3,5,7)])
    
    return(list(Timer=Timer, raw=raw, waves=waves, nrec = length(Timer)))
    
  } else {

    df = read.table(filen, header=T)
  
    Timer = df[,1]
    Date = as.character(df[,2])
    Heure = as.character(df[,3])
    if (str_length(Date[1]) == 5) Date = paste("0", Date, sep="")
    if (str_length(Heure[1]) == 5) Heure = paste("0", Heure, sep="")
    Time = as.POSIXct(paste(Date,Heure), format="%d%m%y %H%M%S")
    Beta = as.matrix(df[,c(4,8,12)])
    BetaP = as.matrix(df[,c(5,9,13)])
    bbP = as.matrix(df[,c(6,10,14)])
    bb = as.matrix(df[,c(7,11,15)])
    x=names(df)[c(4,8,12)]
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
  
    BB3 = list(Timer=Timer, Time=Time, Beta=Beta, BetaP=BetaP, bbP=bbP, bb=bb, wl=wl)
  
    return(BB3)

  }
}