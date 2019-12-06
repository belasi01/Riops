read.cast.info <- function(cast.file) {
    cast = read.table(file=cast.file, header = T, sep= ",",
                      colClasses = c("numeric", "numeric",
                                     "character", "character",
                                     "character", "numeric",
                                     "numeric", "numeric",
                                   "numeric","numeric","numeric", "numeric"),
                      na.strings = c("NA" , " NA", " NA " ))
    if (!is.na(cast$Time0.CTD)) {
      cast$Time0.CTD = as.POSIXct(cast$Time0.CTD, tz="GMT")
    } else cast$Time0.CTD = NA
    if (!is.na(cast$Time0.LISST)) {
      cast$Time0.LISST = as.POSIXct(cast$Time0.LISST, tz="GMT")
    } else cast$Time0.LISST = NA
    if (!("timeseries" %in% names(cast))) {
      cast$timeseries = 0
    }
    
    return(cast)
}
