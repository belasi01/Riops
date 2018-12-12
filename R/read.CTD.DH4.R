#' Read a CTD (MicroCAT) file
#'
#' Read a CTD file in ASCII format as recorded
#' in the DH4
#'
#' @param filen is a CTD file name
#'
#' @return A list with Timer, Temp, Cond, Depth, Sal
#'
#' @author Simon Belanger
#' @export
#'

read.CTD.DH4 <- function(filen){
  df = read.table(filen, header = T)

  if (names(df)[1] == "Time.ms.") { # CTD from Takuvik DH4
    Timer = df[,1]
    Depth = df[,2]
    Temp = df[,3]
    Cond = df[,4]
    Sal = df[,5]
  } else { # CTD from IML DH4
    Timer = df[,1]
    Temp = as.numeric(str_sub(as.character(df[,2]),1,5))
    Cond = as.numeric(str_sub(as.character(df[,3]),1,5))
    Depth = as.numeric(str_sub(as.character(df[,4]),1,5))
    Sal = df[,5]
  }

  # Check whether the timer is increasing and fix it if not
  dt = rep(NA, length(Timer)-1)
  for (i in 1:(length(Timer)-1)) dt[i] = (Timer[i+1] - Timer[i])
  ix = which(dt < 0)
  while (length(ix >0)) {
    Timer[(ix[1]+1):length(Timer)] = Timer[ix[1]] + (Timer[(ix[1]+1):length(Timer)] - Timer[(ix[1]+1)])
    for (i in 1:(length(Timer)-1)) dt[i] = (Timer[i+1] - Timer[i])
    ix = which(dt < 0)
  }

  CTD = list(Timer=Timer, Temp=Temp, Cond=Cond, Depth=Depth, Sal=Sal)
  return(CTD)
}
