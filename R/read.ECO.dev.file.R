#' Read a WetLabs Device file for ECO meter (VSF3, BB9, BB3)
#'
#' @param filen is device file name
#' @param ECO.type is a character string for the type of ECO meter: BB9, BB3, VSF3.
#' (Default is VSF3)
#' 
#' @return A list including a dataframe for the calibration coefficients, 
#' the ECO serial number and the data of the calibration.
#'
#' @author Simon Belanger
#' @export

read.ECO.dev.file <- function (filen, ECO.type="VSF3") {
  
  if (ECO.type=="VSF3") {
    
    id  <- file(filen, "r")
    line  <- unlist(strsplit(readLines(con=id, n =1), "\t") )
    ECO.SN <- line[1]
    line  <- unlist(strsplit(readLines(con=id, n =1), ":") )
    Cal.Date <- as.POSIXct(line[2], format="%m/%d/%y")
    close(id)
    
    df = read.table(file=filen, skip=5)
    names(df) <- c("Angle", "ScalingFactor", "Offset")
    
    return(list(cal=df, 
                Cal.Date=Cal.Date,
                ECO.SN=ECO.SN))
  }
  if (ECO.type=="BB9") {
    
    ScalingFactor = rep(NA, 9)
    Offset         = rep(NA, 9)
    waves          = rep(NA, 9)
    
    id  <- file(filen, "r")
    line  <- unlist(strsplit(readLines(con=id, n =1), "\t") )
    ECO.SN <- line[1]
    line  <- unlist(strsplit(readLines(con=id, n =1), ":") )
    Cal.Date <- as.POSIXct(line[2], format="%m/%d/%y")
    w <- 1
    for (i in 1:26) {
      line  <- unlist(strsplit(readLines(con=id, n =1), "\t") )
      if (length(line) > 3) {
        ScalingFactor[w] <- as.numeric(line[2])
        Offset[w]         <- as.numeric(line[3])
        waves[w]          <- as.numeric(line[4])
        w <- w +1
      }
    }
    close(id)
    df <- data.frame(waves, ScalingFactor, Offset)
    return(list(cal=df, 
                Cal.Date=Cal.Date,
                ECO.SN=ECO.SN))
  }
  if (ECO.type=="BB3") {
    
    ScalingFactor = rep(NA, 3)
    Offset         = rep(NA, 3)
    waves          = rep(NA, 3)
    
    id  <- file(filen, "r")
    line  <- unlist(strsplit(readLines(con=id, n =1), "\t") )
    ECO.SN <- line[1]
    line  <- unlist(strsplit(readLines(con=id, n =1), ":") )
    Cal.Date <- as.POSIXct(line[2], format="%m/%d/%y")
    w <- 1
    for (i in 1:10) {
      line  <- unlist(strsplit(readLines(con=id, n =1), "\t") )
      print(line)
      if (length(line) > 3) {
        ScalingFactor[w] <- as.numeric(line[2])
        Offset[w]         <- as.numeric(line[3])
        waves[w]          <- as.numeric(line[4])
        w <- w +1
      }
    }
    close(id)
    df <- data.frame(waves, ScalingFactor, Offset)
    return(list(cal=df, 
                Cal.Date=Cal.Date,
                ECO.SN=ECO.SN))
  }

}
