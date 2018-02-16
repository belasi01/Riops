#' Read an ECO triplet for CDOM fluorescence (FLECO) file
#'
#' @param filen is a FLECO file name
#'
#' @return A list with FL, ex, em, TempIntrument
#'
#' @author Simon Bélanger
#' @export
#'

read.FLECO <- function(filen)
{

  FLECO=read.table(filen)
  Date=FLECO$V1
  Time=FLECO$V2
  Time = as.POSIXct(paste(Date, Time), "%m/%d/%y %H:%M:%S", tz="GMT")

  nb=nrow(FLECO)
  FL=matrix(NA,nb,3)

  FL[,1]=FLECO$V4
  FL[,2]=FLECO$V6
  FL[,3]=FLECO$V8
  TempIntrument=FLECO$V9*(-0.0056) + 70.0376
  data <- list(FL=FL, ex=370, em=c(420,460,510),TempIntrument=TempIntrument, Time=Time)

  return(data)

}


