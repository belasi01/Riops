#' Convert raw LISST ASCII to raw binary file format (*.DAT)
#'
#'
#' Convert raw LISST ASCII, when connected to a DH4 for example, to a binary file format
#' readable by LISST-SOP software for processing
#'
#' @param filen is a LISST 100 file name
#'
#' @details
#' When operate using a DH4, the LISST output is stored as ASCII
#' strings that are unreadable by the LISST-SOP software for further
#' processing. This program reformat the ASCII output a creates a
#' binary file (*.DAT) readable by LISST-SOP software, which can be use to
#' calculate the Particles Size Distribution (PSD) and output a file
#' *.asc. The *.asc file can be read by \code{\link{read.LISST}}.
#'
#' @return It returns the matrix with 40 columns that have been
#' converted into binary.
#'
#' @author Simon Belanger
#' @export
#'
reformat.LISST100 <-function(filen) {

  df = read.table(filen)
  nrec = length(df$V1)/42
  m = t(matrix(df$V1, ncol=nrec, nrow=42))

  # remove the first and last columns
  m = m[,-c(1,42)]

  # convert to integer
  # LISST100 log format for further processing in Matlab
  v.num = as.integer(m)
  raw.data = matrix(v.num, ncol=40, nrow=nrec)

  write.table(raw.data, file=paste(filen,".log", sep=""),col.name=F,row.names=F,sep="\t")

  #write in binary
  raw.data[,1:32] = raw.data[,1:32] * 10
  v.num = as.integer(raw.data)
  raw.data = matrix(v.num, ncol=40, nrow=nrec)

  zz <- file(paste(filen,".DAT", sep=""), "wb")
  writeBin(as.vector(t(raw.data)),zz, endian = "big", size=2)
  close(zz)
  return(raw.data)
}
