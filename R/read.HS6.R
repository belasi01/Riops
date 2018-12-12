#' Read s Hydroscat-6 file
#'
#' @param filen is a Hydroscat-6 file name
#'
#' @return A list with Time, depth, wl,bb, bbu,beta,betau,
#' fluo,fluou,betafl
#'
#' @author Simon Belanger
#' @export
#'
read.HS6 <- function(filen)
{
	Head <- as.character(read.table(filen, nrow=1, skip=35, sep=",", as.is=TRUE))

	data <- as.matrix(read.csv(filen, skip=37, header=FALSE, colClasses="double"))

	dimnames(data) <- list(NULL, Head[1:35])

	data <- as.data.frame(data)

	bb <- matrix(nrow = nrow(data), ncol=6)
	bbuncor <- matrix(nrow = nrow(data), ncol=6)
	beta <- matrix(nrow = nrow(data), ncol=6)
	betauncor <- matrix(nrow = nrow(data), ncol=6)
	fluo <- matrix(nrow = nrow(data), ncol=2)
	fluouncor <- matrix(nrow = nrow(data), ncol=2)
	betafl <- matrix(nrow = nrow(data), ncol=2)

	bb[,1] <- data$bb394
	bb[,2] <- data$bb420
	bb[,3] <- data$bb470
	bb[,4] <- data$bb532
	bb[,5] <- data$bb620
	bb[,6] <- data$bb700

	bbuncor[,1] <- data$bb394uncorr
	bbuncor[,2] <- data$bb420uncorr
	bbuncor[,3] <- data$bb470uncorr
	bbuncor[,4] <- data$bb532uncorr
	bbuncor[,5] <- data$bb620uncorr
	bbuncor[,6] <- data$bb700uncorr

	beta[,1] <- data$betabb394
	beta[,2] <- data$betabb420
	beta[,3] <- data$betabb470
	beta[,4] <- data$betabb532
	beta[,5] <- data$betabb620
	beta[,6] <- data$betabb700

	betauncor[,1] <- data$betabb394uncorr
	betauncor[,2] <- data$betabb420uncorr
	betauncor[,3] <- data$betabb470uncorr
	betauncor[,4] <- data$betabb532uncorr
	betauncor[,5] <- data$betabb620uncorr
	betauncor[,6] <- data$betabb700uncorr

	fluo[,1] <- data$fl470
	fluo[,2] <- data$fl700

	fluouncor[,1] <- data$fl470uncorr
	fluouncor[,2] <- data$fl700uncorr

	betafl[,1] <- data$betafl470
	betafl[,2] <- data$betafl700

  HS6 = list(Time=as.POSIXct(data[,1]*3600*24, origin="1899-12-30", tz="GMT"),
             depth=data$Depth,
             wl=c(394,420,470,532,620,700),
             bb=bb,
             bbu=bbuncor,
             beta=beta,
             betau=betauncor,
             fluo=fluo,
             fluou=fluouncor,
             betafl=betafl )
  return(HS6)

}
