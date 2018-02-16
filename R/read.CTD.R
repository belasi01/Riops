#' Read a CTD SBE19+ file
#'
#' Read a CTD SBE19+ file in ASCII format as recorded in the MiniDAS
#'
#' @param filen is a CTD file name
#'
#' @return A list with Time, Temp, Depth, Sal,
#' Density, Voltage, Tpot
#'
#' @author Simon Bélanger
#' @export
#'

read.CTD <- function(filen){
  nrec = length(readLines(filen))
  df = read.table(filen, skip=6, sep=",", nrows = nrec-10)
  names(df) <- c("Temp", "Tpot","Depth", "Sal", "Time","Density", "Voltage")

  # Change the system time format
  Sys.setlocale("LC_TIME","en_IE.UTF-8")
  df$Time = as.POSIXct(as.character(df$Time),format="%d %B %Y %T", tz="GMT" )

  CTD = list(Time=df$Time, Temp=df$Temp, Depth=df$Depth, Sal=df$Sal,
             Density=df$Density, Voltage=df$Voltage, Tpot=df$Tpot)
  return(CTD)

  return(df)

}
