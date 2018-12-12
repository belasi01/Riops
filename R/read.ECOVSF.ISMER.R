#' Read the ISMER ECO-VSF data 
#'
#' @param eco.file is the file name of the ECO-VSF data 
#'
#' @return A dataframe with the calibrated data 
#'
#' @author Simon Belanger
#' @export
#' 
read.ECOVSF.ISMER <- function(eco.file){
  
  id  <- file(eco.file, "r")
  line<- unlist(strsplit(readLines(con=id, n =1), " ") )
  if (line[1] == "Created") 
    {
    print("Data recorded using ECOHost")
    date<- as.POSIXct(line[3], format="%m-%d-%Y")
    line<- unlist(strsplit(readLines(con=id, n =1), " ") )
    line<- unlist(strsplit(readLines(con=id, n =1), " ") )
    
    # Start counting the number of record
    nrec=0
    while (line[1] != "EOF") {
      line<- unlist(strsplit(readLines(con=id, n =1), " ") )
      nrec=nrec+1
    }
    nrec = nrec - 1
    print(nrec)
    close(id)
    raw = read.table(file=eco.file, skip=3, nrows = nrec)
    names(raw) <- c("SN", "time", "B100",   "B125",   "B150", "Bref",  
                    "G100",   "G125",   "G150", "Gref", "Vin")
  }
  else 
  {
    print("Data recorded using ECOview")
    date<-NA
    raw = read.table(file=eco.file)
    names(raw) <- c("SN", "time", "B100",   "B125",   "B150", "Bref",  
                    "G100",   "G125",   "G150", "Gref", "Vin")
    nrec = length(raw$time)
    }
  
    return(list(date=date, time=raw$time, raw=raw,
                nrec=nrec))
  
}