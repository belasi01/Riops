#'
#'@title IOPs data processing launcher
#'
#'@description This function launches the IOPs data processing,
#'which constists in applying various corrections and calibration
#'to measured inherent optical properties (IOPs) of seawater
#'constituents using various commercial instruments (see Details).
#'
#' @param report is a logical parameter indicating whether or not a
#'PDF report is produced using knitr.  Default is FALSE.
#' @param output.aTOT.COPS is a logical parameter indicating whether or not
#' the spectral absorption is needed for COPS processing. IMPORTANT: a COPS
#' folder with files preliminarly processed using the \pkg{Cops} package must
#' be present in the folder YYYYMMDD_StationXXX (see Details). The \pkg{Cops}
#' processing creates a file named absorption.cops.dat that will be automatically
#' edited if output.aTOT.COPS=TRUE. The default is FALSE.
#' @param cast If output.aTOT.COPS=TRUE, cast will indicate whether the down cast
#' or the up cast will be used to average the non-water absorption.
#' The default is "down"
#' @param depth.interval If output.aTOT.COPS=TRUE, this parameter will indicates
#' the depth interval for which the non-water absorption will be avaraged.
#' The default is c(0.75,2.1)
#' @param a.instrument If output.aTOT.COPS=TRUE, this parameter will indicate
#' whether the non-water absorption will be taken from the a-sphere (ASPH) or
#' the ac-s (ACS). The default is ASPH.
#
#'@details  \code{IOPs.go} processes data files found in each directories specify in the file
#'named directories.for.IOPs.dat. NOTE: it is important to create one folder
#'per cast following this convention:
#'\itemize{
#'  \item{../YYYYMMDD_StationXXX/PACKAGENAME/}
#'  }
#'  where XXX is the station ID (with out "_" because it creates problems
#'  with the LaTex report) and PACKAGENAME is the name of the package.
#'  It could be anything.
#'
#'For each directory specifyed in directories.for.IOPs.dat, four ASCII
#'files will be necessary in addtion to the files coming from the instruments
#'located in the directory. The ASCII files are:
#'\itemize{
#'  \item{cast.info.dat:}{ This file contains information relative to
#'  the current IOP profile;}
#'  \item{cal.info.dat:}{ This file contains information relative to
#'   the instrument calibration;}
#'  \item{instruments.dat:} { This is a list of instruments currently
#'  supported by \pkg{Riops}. User should put 1 when the instrument
#'  present on the optical package. The instruments supported are the
#'  following (as on June 1st 2016):
#'       \itemize{
#'       \item{HS6: } { A Hydroscat-6 from Hobilabs}
#'       \item{ASPH: } { An a-sphere from Hobilabs}
#'       \item{FLECO: } { An ECO triplet from Wet Labs. This was costumized
#'       for CDOM fluoresece with ex 379 and emission 420, 460 and 500nm}
#'       \item{CTD.UQAR: } { A SBE19+ CTD from Seabird }
#'       \item{CTD.DH4: } { A microCAT CTD from SeaBird }
#'       \item{ACs: } { An AC-s from Wet Labs}
#'       \item{BB9: } { A BB9 from Wet Labs}
#'       \item{BB3: } { A BB3 from Wet Labs}
#'       \item{FLBBCD: } { An ECO triplet from Wet Labs with
#'       chlorophyll fluorescence, bacskattering and CDOM fluorescence}
#'       \item{FLCHL: } { A chlorophyll fluorescence meter from Wet Labs}
#'       \item{LISST: } { A LISST from Sequoia;}
#'       }}
#'  \item{DH4.ports.dat:} { This file indicate on which port each instrument
#'  were attach to the DH4. It is therfore not necessary if the package does
#'  not include a DH4 to log the data}
#'}
#'
#'If \code{IOPs.go} is run without these files, they will be created automatically
#' by the program and the user will be prompted to edit them.
#'
#' Please read \code{\link{correct.merge.IOP.profile}} for a detailed
#' description of the content of cast.info.dat, cal.info.dat
#' and DH4.ports.dat.
#'
#'@seealso \code{\link{correct.merge.IOP.profile}}, \code{\link{process.IOPs}}
#'
#'@author Simon Belanger
#'
#'@export


IOPs.go <- function(report=FALSE, output.aTOT.COPS=FALSE, cast="down",
                    depth.interval=c(0.75,2.1), a.instrument="ASPH") {
  data("Tdf")
  data("Sdf")
  data("TS4.cor.df")
  if(!file.exists("directories.for.IOPs.dat")) {
      cat("CREATE a file named directories.for.IOPs.dat in current directory (where R is launched)\n")
      cat("  and put in it the names of the directories where data files can be found (one by line)\n")
      stop()
    } else {
      dirdats <- scan(file = "directories.for.IOPs.dat", "", sep = "\n", comment.char = "#")
      for(dirdat in dirdats) {
        if(!file.exists(dirdat)) {
          cat(dirdat, "does not exist")
          stop()
        }
        if (exists("IOP")) rm(IOP)
        mymessage(paste("PROCESSING DIRECTORY", dirdat), head = "@", tail = "@")
        IOP = process.IOPs(dirdat)
        if (report) {
          if (is.list(IOP)) {
            create.report(dirdat)
          } else print("No IOP to report!")

        } else print("No report requested; Add report=TRUE to generate one")

        if (output.aTOT.COPS) {
          data("KDTable_MM01")
          data("AWTable")
          a.tot = compute.aTOT.for.COPS(dirdat, cast, depth.interval, a.instrument)
        } else print("No output for COPS")
      }
    }
}

