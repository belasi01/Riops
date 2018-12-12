#' Reads the parameters and instrument files and launch processing
#'
#' It call the reading functions for cast.info.dat and cal.info.dat,
#' instruments.dat. If they are not present in the directory, it
#' creates a copy of the templates proveded with the package.
#' Finaly it calls \code{\link{correct.merge.IOP.profile}}.
#'
#' @param dirdat is the directory where the instrument files are stored.
#'
#' @seealso \code{\link{correct.merge.IOP.profile}} and
#' \code{\link{IOPs.go}}
#'
#' @author Simon B\elanger
#' @export

process.IOPs <- function(dirdat) {
  # Cast info file
  default.cast.info.file <- paste( Sys.getenv("R_IOPs_DATA_DIR"), "cast.info.dat", sep = "/")

  cast.info.file <- paste(dirdat, "cast.info.dat", sep = "/")
  if(!file.exists(cast.info.file)) {
    file.copy(from = default.cast.info.file, to = cast.info.file)
    cat("EDIT file", cast.info.file, "and CUSTOMIZE IT\n")
  }


  # List of instrument to process for the profile
  default.instrument.file <- paste( Sys.getenv("R_IOPs_DATA_DIR"), "instrument.dat", sep = "/")

  instrument.file <- paste(dirdat, "instrument.dat", sep = "/")
  if(!file.exists(instrument.file)) {
    file.copy(from = default.instrument.file, to = instrument.file)
    cat("EDIT file", instrument.file, "and CUSTOMIZE IT\n")
    stop()
  }

  cast.info <- read.cast.info(cast.info.file)
  instrument <- read.instrument(instrument.file)


  # Span parameters for calibration and blank correction
  default.cal.info.file <- paste( Sys.getenv("R_IOPs_DATA_DIR"), "cal.info.dat", sep = "/")

  cal.info.file <- paste(dirdat, "cal.info.dat", sep = "/")
  if(!file.exists(cal.info.file)) {
    file.copy(from = default.cal.info.file, to = cal.info.file)
    cat("USING DEFAULT CALIBRATION PARAMETERS\n")
    cat("File", cal.info.file, "CAN BE EDITED\n")
    cal.info <- read.cal.info(cal.info.file)
  }
  cal.info <- read.cal.info(cal.info.file)

  parameters = c(list(path=dirdat), cast.info,cal.info)
  str(parameters)
  str(instrument)

  # Launch the processing
  print("BEGIN PROCESSING")
  IOP = correct.merge.IOP.profile(instrument, parameters)

  return(IOP)

}
