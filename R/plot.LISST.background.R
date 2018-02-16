plot.LISST.background <-function(files, factory.file, file.mean) {

  nf = length(files)

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


  bck = read.table(factory.file)

  plot(bins$bins_median, bck$V1[1:32], xlab="median bin size",
       ylab="Raw counts", type="l", lwd=3, ylim=c(0,100), col=8)

  bcks = matrix(NA,ncol=nf, nrow=40)
  for (i in 1:nf) {
    tmp=read.table(files[i])
    bcks[,i] = tmp$V1
    lines(bins$bins_median, bcks[1:32,i], col=i+1, lwd=3)
  }

  mean.bck = apply(bcks, 1, mean, na.rm=T)
  write.table(mean.bck,file=file.mean,quote=F, row.names = F,col.names = F)
  lines(bins$bins_median,mean.bck[1:32], col=1, lwd=3)
  legend("topright", c("Factory",files,"Mean"), lwd=rep(3,nf+1), col=c(8,seq(nf)+1,1))


  print(paste("r ratio from measured background: ",  mean.bck[33]/mean.bck[36]))
  print(paste("r ratio from factory: ",  bck$V1[33]/bck$V1[36]))

}
