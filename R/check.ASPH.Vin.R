#' Check A-sphere batteries voltage input (Vin)
#'
#' It produces a diagnostic plot to evaluate if the
#' batteries need to be changed.
#'
#' Note that only the a-sphere file processed using the IGOR
#' template version "a-Sphere Processing Template 201.pxt"
#' or higher (>201) include the Vin
#'
#' @param filen is the file name of the ASPH file.
#'
#' @return A plot showing Vin as a function of time.
#'
#' @author Simon Bélanger
#' @export

check.ASPH.Vin <- function(filen) {

  ASPH = read.ASPH(filen)

  plot(ASPH$time, ASPH$Vin, xlab="ASPH Time", ylab="Vin", ylim=c(0,max(max(ASPH$Vin))))
  text(ASPH$time[floor(length(ASPH$time)/2)], max(ASPH$Vin)*0.8,
       paste("Lowest Vin : ", min(ASPH$Vin), "V"), main=filen)
  lines(ASPH$time, rep(8,length(ASPH$time)), col=2)

  if (min(ASPH$Vin) < 8) {
    text(ASPH$time[floor(length(ASPH$time)/2)],
         max(ASPH$Vin)*0.6, "Change batteries ASAP!!!", col=2)
  }



}
