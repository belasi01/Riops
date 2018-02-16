#' Read an ECO triplet for chlrophyll, bb700 and cdom (FLBBCD) file
#'
#' @param filen is a FLBBCD file name
#'
#' @return A list with Timer, Beta700, BetaP700,
#' bbP700, bb700, FCHL, FDOM
#'
#' @author Simon Bélanger
#' @export
#'


read.FLBBCD <- function(filen){

  df = read.table(filen, header=T)

  Timer = df[,1]
  FCHL = df[,2]
  Beta700 = df[,3]
  BetaP700 = df[,4]
  bbP700 = df[,5]
  bb700 = df[,6]
  FDOM = df[,7]

  # Check whether the timer is increasing and fix it if not
  dt = rep(NA, length(Timer)-1)
  for (i in 1:(length(Timer)-1)) dt[i] = (Timer[i+1] - Timer[i])
  ix = which(dt < 0)
  while (length(ix >0)) {
    Timer[(ix[1]+1):length(Timer)] = Timer[ix[1]] + (Timer[(ix[1]+1):length(Timer)] - Timer[(ix[1]+1)])
    for (i in 1:(length(Timer)-1)) dt[i] = (Timer[i+1] - Timer[i])
    ix = which(dt < 0)
  }

  FLBBCD = list(Timer=Timer, Beta700=Beta700, BetaP700=BetaP700,
             bbP700=bbP700, bb700=bb700, FCHL=FCHL, FDOM=FDOM)

  return(FLBBCD)
}
