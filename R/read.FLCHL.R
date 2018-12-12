#' Read a chlorophyll fluorescence (FLCHL) file
#'
#' @param filen is a FLCHL file name
#'
#' @return A list with Timer and FCHL
#'
#' @author Simon Belanger
#' @export
#'

read.FLCHL <- function(filen){

  df = read.table(filen, header=T)

  Timer = df[,1]
  FCHL = df[,2]

  # Check whether the timer is increasing and fix it if not
  dt = rep(NA, length(Timer)-1)
  for (i in 1:(length(Timer)-1)) dt[i] = (Timer[i+1] - Timer[i])
  ix = which(dt < 0)
  while (length(ix >0)) {
    Timer[(ix[1]+1):length(Timer)] = Timer[ix[1]] + (Timer[(ix[1]+1):length(Timer)] - Timer[(ix[1]+1)])
    for (i in 1:(length(Timer)-1)) dt[i] = (Timer[i+1] - Timer[i])
    ix = which(dt < 0)
  }

  FLECOCHL = list(Timer=Timer, FCHL=FCHL)

  return(FLECOCHL)
}
