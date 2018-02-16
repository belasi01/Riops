read.instrument <- function (instrument.file) {
  instrument <- read.table(file=instrument.file, sep=",", header = T)

  if (is.null(instrument$INSTRUMENT)) {
    return(instrument)
  } else {
  # convert to a dataframe
  ninst = length(instrument$INSTRUMENT)
  df=as.data.frame(matrix(ncol=ninst, nrow=1))
  names(df) <-instrument$INSTRUMENT
  df[1,] <- instrument[,2]
  instrument <-df
  return(instrument)
  }


}
