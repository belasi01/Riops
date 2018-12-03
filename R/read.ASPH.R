#' Read A-Sphere ASCII file as exported by IGOR software.
#'
#' @param filen is the ASPH file name
#' @param skip is the number of lines to skip at the begining of the file.
#' This was added to deal with files containing several casts.
#'
#'  @return A list with time, depth, Vin and wl vector and a matrix
#'   a containing the spectral absorption.
#'
#' @author Simon Bélanger
#' @export

read.ASPH <- function(filen, skip=0){

	id = file(filen, "r")
	line = unlist(strsplit(readLines(con=id, n =1), "\t")) # Reads the first header line
	nrec = 0
	if (length(line) == 2) {
	  Header <- matrix(nrow=10000, ncol=2)
	  while (line != "character(0)"){
	    line = strsplit(readLines(con=id, n =1), "\t") # reads the time and depth for each records
	    nrec <- nrec+1
	    #print(line)
	    if (line != "character(0)"){
	      Header[nrec,] <- as.numeric(unlist(line))
	    }
	  }
	}

	if (length(line) == 3) {
	  Header <- matrix(nrow=10000, ncol=3)
	  while (line != "character(0)"){
	    line = strsplit(readLines(con=id, n =1), "\t") # reads the time, depth and Vin for each records
	    nrec <- nrec+1
	    #print(line)
	    if (line != "character(0)"){
	      Header[nrec,] <- as.numeric(unlist(line))
	    }
	  }
	}



	#print(TimeDepth)
	nrec = nrec -1
	print(paste("Number of record in file:  ", as.character(nrec)))
	line = strsplit(readLines(con=id, n =1), "\t") # Reads a code
	wl = as.numeric(unlist(strsplit(readLines(con=id, n =1), "\t"))) # Reads the wavelength
	nwl <- length(wl)
	a <- matrix(nrow=nrec, ncol=nwl)
  badlines=NA
	for (i in 1:nrec){
		line = strsplit(readLines(con=id, n =1), "\t") # Reads a code
		#print(line)
    if (length(unlist(line)) == nwl) {
      a[i,] <- as.numeric(unlist(line))
    } else {
      #print(paste("Bad line number: ", i))
      if (is.na(badlines)) {
        badlines = i
      } else {
        badlines = c(badlines,i)
      }
    }

	}
	close(id)

	time = as.POSIXct(Header[1:nrec,1], origin="1904-01-01", tz="GMT")
	depth = Header[1:nrec,2]
	if (ncol(Header)==3) Vin = Header[1:nrec,3]

  if (!is.na(badlines)) {
    print("Bad line numbers: ")
    print(badlines)
    print("Trimming the data")
    time = time[-badlines]
    depth = depth[-badlines]
    a = a[-badlines,]
    if (ncol(Header)==3) Vin = Vin[-badlines]
	}

  ### this was added to skip the first X records from the file
  ### This is because sometime the data are concatenated in an
  ### existing file on the MiniDAS.
  if (skip != 0) {
    print(paste("The number of record skipped is:", skip))
    time = time[(skip+1):nrec]
    depth = depth[(skip+1):nrec]
    a = a[(skip+1):nrec,]
    if (ncol(Header)==3) Vin = Vin[(skip+1):nrec]
  }


	if (ncol(Header)==3) {
	  data <- list(time= time, depth = depth, a=a, wl=wl, Vin=Vin)
	} else data <- list(time= time, depth = depth, a=a, wl=wl)

	return(data)

}

