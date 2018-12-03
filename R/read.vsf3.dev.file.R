#' Read a WetLabs Device file for ECO-VSF3
#'
#' @param filen is DEV file name
#'
#' @return A dataframe
#'
#' @author Simon Bélanger
#' @export

read.vsf3.dev.file <- function (filen) {
  
  df = read.table(file=filen, skip=5)
  
  names(df) <- c("Angle", "ScalingFactor", "Offset")

  return(df)
}
