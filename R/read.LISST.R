#' Read s LISST file in format *.asc
#'
#' @param filen is a LISST file name
#'
#' @return A list with time, Depth, PSD, lower_size_bins, upper_size_bins,
#' median_bins,temperature, transsmision, c670
#'
#' @author Simon Bélanger
#' @export
#'

read.LISST <- function(filen){

 df = read.table(filen, header=FALSE)

 # Get the upper and lower limits of the 32 size classes

 rho <- round(200^(1/32), 3)

 lower_size_bins <- vector()
 upper_size_bins <- vector()

 lower_limit <- 1.25
 upper_limit <- 1.47

 lower_size_bins[1] <- lower_limit
 upper_size_bins[1] <- upper_limit

 for (index in 2:32) {

  lower_size_bins[index] <- round(lower_limit * rho, 2)
  lower_limit <- lower_size_bins[index]

  upper_size_bins[index] <- round(upper_limit * rho, 2)
  upper_limit <- upper_size_bins[index]

 }

 #Bins data-frame
 bins <- as.data.frame(cbind(lower_size_bins, upper_size_bins))
 bins["bins_median"] <- apply(bins[1:2], 1, median)
 bins["bins_range"] <- apply(bins[1:2], 1 , paste , collapse = "-" )


 PSD = as.data.frame(df[,1:32])
 names(PSD) = as.character(bins$bins_range)

 press = df[,37]
 temp = df[,38]

# The transmission is a number between 0 and 1
# If transmission values generally are in the 0.98-0.995 range, measurements are taken in very clear water.
# Disregard data if transmission is > 0.995
# Disregard data if transmission is < 0.10

 transmission = df[,41]
 c670 = df[,42]

 # Extracting time
 day = (str_sub(as.character(df[,39]),1,3))
 hour = (str_sub(as.character(df[,39]),4,5))
 minute = as.character(floor(df[,40]/100))
 sec = as.character(100*((df[,40]/100) - floor(df[,40]/100)))
 time = as.POSIXct(paste("2015-",day," ",hour,":",minute,":",sec, sep=""), format="%Y-%j %H:%M:%S",tz="GMT")



 return(list(PSD = PSD, lower_size_bins =bins$lower_size_bins, upper_size_bins=bins$upper_size_bins,
             median_bins=bins$bins_median, time=time, Depth=press, temperature=temp, transsmision=transmission, c670=c670))

}
