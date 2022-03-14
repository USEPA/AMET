header <- "
############################ MODEL TO OBS SPECTRAL ANALYSIS ############################
### AMET CODE: R_Spectrum.R 
###
### This script is part of the AMET-AQ system.  This script creates creates average and site
### specific spectrum plots using hourly data.  This code is based on code provided by 
### Christian Hogrefe.
###
### Last Updated by Wyat Appel: Nov 2020
########################################################################################
"

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

plot_all <- 'y'

filename1_pdf <- paste(run_name1,species,pid,"spectrum.pdf",sep="_")                                # Set PDF filename
filename1_png <- paste(run_name1,species,pid,"spectrum.png",sep="_")                                # Set PNG filename
filename2_png <- paste(run_name1,species,pid,"spectrum_all.png",sep="_")
filename2_pdf <- paste(run_name1,species,pid,"spectrum_all.pdf",sep="_")                                # Set PDF filename

## Create a full path to file
filename1_pdf <- paste(figdir,filename1_pdf,sep="/")                                # Set PDF filename
filename1_png <- paste(figdir,filename1_png,sep="/")                                # Set PNG filename
filename2_png <- paste(figdir,filename2_png,sep="/")                                # Set PNG filename
filename2_pdf <- paste(figdir,filename2_pdf,sep="/")                                # Set PDF filename

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste("Spectral analysis for",run_name1,species,"for",dates,sep=" ") }
   else { title <- custom_title }
}

#################################

network <- network_names[1]
run_name <- run_name1
j <- 1

network <- network_names[[j]]                                             # Set network

#############################################
### Read sitex file or query the database ###
#############################################
{
   if (Sys.getenv("AMET_DB") == 'F') {
      sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name,species)
      aqdat_query.df   <- sitex_info$sitex_data
      data_exists      <- sitex_info$data_exists
      if (data_exists == "y") { units <- as.character(sitex_info$units[[1]]) }
   }
   else {
      query_result    <- query_dbase(run_name,network,species)
      aqdat_query.df  <- query_result[[1]]
      data_exists     <- query_result[[2]]
      if (data_exists == "y") { units <- query_result[[3]] }
      model_name      <- query_result[[4]]
   }
}
ob_col_name <- paste(species,"_ob",sep="")
mod_col_name <- paste(species,"_mod",sep="")
#############################################

aqdat.df 	<- data.frame(Network=aqdat_query.df$network,Stat_ID=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=round(aqdat_query.df[[ob_col_name]],5),Mod_Value=round(aqdat_query.df[[mod_col_name]],5),Month=aqdat_query.df$month)      # Create dataframe of network values to be used to create a list
aqdat_stats.df <- aqdat.df

#########################################################
#### Calculate statistics for each requested network ####
#########################################################
data_all.df <- data.frame(network=I(aqdat_stats.df$Network),stat_id=I(aqdat_stats.df$Stat_ID),lat=aqdat_stats.df$lat,lon=aqdat_stats.df$lon,ob_val=aqdat_stats.df$Obs_Value,mod_val=aqdat_stats.df$Mod_Value)
data_all.df$ob_val[data_all.df$ob_val<0] <- NA		# Set missing observations to NA so that they may be removed
data_all.df$mod_val[data_all.df$mod_val<0] <- NA	# Set missing modeled values to NA so that they may be removed

site_data_all.df <- split(data_all.df,data_all.df$stat_id)
num_sites <- length(unique(data_all.df$stat_id))

obs_m <- data_all.df$ob_val	# Store obs values in a vector
mod_m <- data_all.df$mod_val 	# Store modeled values in a vector

stid <- unique(data_all.df$stat_id)	# Store unique station names in a vector
 
# these arrays will hold the spectral densities and frequencies
# FFT "pads" the time series, so 2*67500 > 131400
# the exact value of 67500 is trial and error and depends on the 
# length of the data record. First run FFT for just one site and see
# what the length of the output record is, recognizing that the output
# is symmetric and only half of the total length contains unique 
# information
#

num_rows <- ((max(aqdat.df$Month)-min(aqdat.df$Month)+1)*31*24)/2


obs_spec_freq_m <- matrix(nrow=2592,ncol=num_sites)
obs_spec_dens_m <- matrix(nrow=2592,ncol=num_sites)
#obs_spec_freq_m <- matrix(nrow=num_rows,ncol=num_sites)
#obs_spec_dens_m <- matrix(nrow=num_rows,ncol=num_sites)
#obs_spec_freq_m <- NULL
#obs_spec_dens_m <- NULL
obs_av_spec <- numeric()

mod_spec_freq_m <- matrix(nrow=2592,ncol=num_sites)
mod_spec_dens_m <- matrix(nrow=2592,ncol=num_sites)
#mod_spec_freq_m <- matrix(nrow=num_rows,ncol=num_sites)
#mod_spec_dens_m <- matrix(nrow=num_rows,ncol=num_sites)
#mod_spec_freq_m <- NULL
#mod_spec_dens_m <- NULL
mod_av_spec <- numeric()

 
#
# calculate the spectra at each site. Need to remove missing data first
# via interpolation because "spectrum" doesn't handle missing data
#

i <- 1

while (i <= num_sites) {

 temp_data.df <- (site_data_all.df[[i]])
 obs_m <- temp_data.df$ob_val
 obs_int <- approx(obs_m, n=5136)
 obs_ts <- as.ts(obs_int$y)
 obs_spec_m <- spectrum(obs_ts,plot=FALSE,fast=TRUE)
 obs_spec_freq_m[,i]  <- as.numeric(obs_spec_m$freq)
 obs_spec_dens_m[,i]  <- as.numeric(obs_spec_m$spec)
# obs_spec_freq_m  <- as.numeric(obs_spec_m$freq)
# obs_spec_dens_m  <- as.numeric(obs_spec_m$spec)

 mod_m <- temp_data.df$mod_val
# mod_int <- approx(mod_m, n=2*num_rows)
 mod_int <- approx(mod_m, n=5136)
 mod_ts <- as.ts(mod_int$y)
 mod_spec_m <- spectrum(mod_ts,plot=FALSE,fast=TRUE)
 mod_spec_freq_m[,i]  <- as.numeric(mod_spec_m$freq)
 mod_spec_dens_m[,i]  <- as.numeric(mod_spec_m$spec)
# mod_spec_freq_m  <- as.numeric(mod_spec_m$freq)
# mod_spec_dens_m  <- as.numeric(mod_spec_m$spec)

 i <- i+1

}

#
# calculate the "average spectral density" for each frequency across
# the 25 sites.
#

i <- 1

#while (i <= num_rows) {
while (i <= 2592) {

obs_av_spec[i] <- mean(obs_spec_dens_m[i,])
mod_av_spec[i] <- mean(mod_spec_dens_m[i,])
#obs_av_spec[i] <- mean(obs_spec_dens_m[i])
#mod_av_spec[i] <- mean(mod_spec_dens_m[i])

i <- i+1

}

obs_spec_freq_m_avg <- apply(obs_spec_freq_m,1,mean)
obs_spec_dens_m_avg <- apply(obs_spec_dens_m,1,mean)
mod_spec_freq_m_avg <- apply(mod_spec_freq_m,1,mean)
mod_spec_dens_m_avg <- apply(mod_spec_dens_m,1,mean)

#
# plot the "average" spectrum, i.e. the spectral densities for each frequency were averaged over
# all sites
#

ymin <- 0.1*min(obs_av_spec,mod_av_spec)
ymax <- max(obs_av_spec,mod_av_spec)

pdf(file=filename1_pdf)


plot((1./obs_spec_freq_m_avg)/24.,obs_av_spec, col=plot_colors[1],type="l",log="xy",lwd=2., xlab="Period(Days)",main="",ylab="Spectral Density",sub="", ylim=c(0.1*min(obs_av_spec,mod_av_spec), max(obs_av_spec,mod_av_spec)))
a1 <- par('usr')
lines(x=c(0.45,0.45),y=c(10^a1[3],10^a1[4]))
lines(x=c(2.,2.),y=c(10^a1[3],10^a1[4]))
lines(x=c(21.,21.),y=c(10^a1[3],10^a1[4]))
lines(x=c(730.,730.),y=c(10^a1[3],10^a1[4]))

#lines((1./obs_spec_freq_m[,10])/24.,obs_av_spec[,i],col="red",lwd=2.)
#lines((1./obs_spec_freq_m[,10])/24.,mod_av_spec[,i],col="blue")
lines((1./obs_spec_freq_m_avg)/24.,obs_av_spec,col=plot_colors[1],lwd=2.)
lines((1./obs_spec_freq_m_avg)/24.,mod_av_spec,col=plot_colors[2])

legend(18.5,20.,c(network, run_name), bty="n", cex=0.8, col=c(plot_colors[1],plot_colors[2]), lty=c("solid","solid"), lwd=c(2,1))
text(0.1,ymin,"Intra-Day",pos=4)
text(0.5,ymin,"Diurnal",pos=4)
text(2.5,ymin,"Synoptic",pos=4)
text(30.,ymin,"Seasonal",pos=4)
text(800.,ymin,"Longterm",pos=4)
text(0.08,ymax,paste("# of Sites = ",num_sites,sep=""),pos=4,cex=0.8)

### Put title at top of boxplot ###
title(main=title,cex.main=1.1)
###################################


### Convert pdf to png ###
dev.off()
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename1_pdf," png:",filename1_png,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename1_pdf,sep="")
      system(remove_command)
   }
}
##########################

#
# plot site-by-site
#

if (plot_all == 'y') {

   pdf(file=filename2_pdf)

   i <- 1

   while (i <= num_sites) {

      plot((1./obs_spec_freq_m_avg)/24.,obs_spec_dens_m[,i], col=plot_colors[1],type="l",log="xy",lwd=2., xlab="Period(Days)", main=paste("Spectral analysis for site",stid[i],"for",dates,sep=" "), ylab="Spectral Density",sub="", ylim=c(0.1*min(obs_spec_dens_m[,i],mod_spec_dens_m[,i]), max(obs_spec_dens_m[,i],mod_spec_dens_m[,i])))

      ymin <-min(obs_spec_dens_m[,i],mod_spec_dens_m[,i]) 

      lines((1./obs_spec_freq_m_avg)/24.,obs_spec_dens_m[,i],col=plot_colors[1],lwd=2.)
      lines((1./obs_spec_freq_m_avg)/24.,mod_spec_dens_m[,i],col=plot_colors[2])

      legend(18.5,20.,c(network, run_name), bty="n", cex=0.8, col=c(plot_colors[1],plot_colors[2]), lty=c("solid","solid"), lwd=c(2,1))

      abline(v=.45)
      abline(v=2)
      abline(v=21)
      abline(v=730)
      text(0.1,ymin,"Intra-Day",pos=4)
      text(0.5,ymin,"Diurnal",pos=4)
      text(2.5,ymin,"Synoptic",pos=4)
      text(30.,ymin,"Seasonal",pos=4)
      text(800.,ymin,"Longterm",pos=4)

      i <- i + 1
   }

   ### Convert pdf to png ###
   dev.off()
#   if ((ametptype == "png") || (ametptype == "both")) {
#      convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename2_pdf," png:",filename2_png,sep="")
#      system(convert_command)
#      if (ametptype == "png") {
#         remove_command <- paste("rm ",filename2_pdf,sep="")
#         system(remove_command)
#      }
#   }
##########################
 
}


