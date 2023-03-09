read.cal.info <- function(cal.info.file) {
  cal.info = read.table(file = cal.info.file, sep=",", header = T,colClasses = "character")
  if (!is.null(cal.info$Tref.ASPH)) cal.info$Tref.ASPH = as.numeric(cal.info$Tref.ASPH)
  if (!is.null(cal.info$Tref.ACS)) cal.info$Tref.ACS = as.numeric(cal.info$Tref.ACS)
  if (!is.null(cal.info$HS6.CALYEAR)) cal.info$HS6.CALYEAR = as.numeric(cal.info$HS6.CALYEAR)
  if (!is.null(cal.info$scat.correction)) cal.info$scat.correction = str_trim(cal.info$scat.correction)
  if (!is.null(cal.info$ASPH.biascor)) cal.info$ASPH.biascor = str_trim(cal.info$ASPH.biascor)
  if (!is.null(cal.info$mckee.rw)) cal.info$mckee.rw = as.numeric(cal.info$mckee.rw)
  if (!is.null(cal.info$blank.ASPH)) cal.info$blank.ASPH = str_trim(cal.info$blank.ASPH)
  if (!is.null(cal.info$blank.ACS)) cal.info$blank.ACS = str_trim(cal.info$blank.ACS)
  if (!is.null(cal.info$blank.BB9)) cal.info$blank.BB9 = str_trim(cal.info$blank.BB9)
  if (!is.null(cal.info$blank.BB3)) cal.info$blank.BB3 = str_trim(cal.info$blank.BB3)
  return(cal.info)
}
