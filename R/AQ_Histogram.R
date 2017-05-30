################################################################
### THIS FILE CONTAINS CODE TO DRAW A CUSTOMIZED HISTOGRAM PLOT. 
################################################################
### AMET Code: AQ_Histogram.R
### 
### This script creates two histogram plots, one containing the 
### modeled and observed data and the other containing the bias
### distribution. The script can only accept a single network,
### but does accept up to two different simulations. This script
### is part of the AMETv1.2 code.
###
### Last modified by Wyat Appel: December 6, 2012
###
#################################################################


## get some environmental variables and setup some directories
ametbase<-Sys.getenv("AMETBASE")	# base directory of AMET
dbase<-Sys.getenv("AMET_DATABASE")	# AMET database
ametR<-paste(ametbase,"/R",sep="")	# R directory
ametRinput <- Sys.getenv("AMETRINPUT")	# input file for this script
ametptype <- Sys.getenv("AMET_PTYPE")	# Prefered output type

## Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
## and not specified via AMET_OUT, then set figdir to the current directory
if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")       }
if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"                 }

## source some configuration files, AMET libs, and input
source(paste(ametbase,"/configure/amet-config.R",sep=""))
source (paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file
source (ametRinput)                                     # Anaysis configuration/input file
source (ametNetworkInput) # Network related input

## Load Required Libraries
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}

mysql <- list(login=login, passwd=passwd, server=server, dbase=dbase, maxrec=maxrec)           # Set MYSQL login and query options

### Retrieve units label from database table ###
network <- network_names[1]
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql)
################################################

network <- network_names[[1]]                                             # Set network
### Set file names and titles ###
outname_pdf 		<- paste(run_name1,species,"histogram.pdf",sep="_")			# Set PDF filename
outname_png 		<- paste(run_name1,species,"histogram.png",sep="_")			# Set PNG filename
outname_bias_pdf 	<- paste(run_name1,species,"histogram_bias.pdf",sep="_")                  # Set PDF filename
outname_bias_png 	<- paste(run_name1,species,"histogram_bias.png",sep="_")                  # Set PNG filename
## Create a full path to file
outname_pdf		<- paste(figdir,outname_pdf,sep="/")
outname_png 		<- paste(figdir,outname_png,sep="/")
outname_bias_pdf 	<- paste(figdir,outname_bias_pdf,sep="/")
outname_bias_png 	<- paste(figdir,outname_bias_png,sep="/")

{  
   if (custom_title == "") { 
      title_all		<- paste(run_name1,species,"for",start_date,"to",end_date,sep=" ") 
      title_bias 	<- paste(run_name1,species,"bias for",start_date,"to",end_date,sep=" ") 
   }
   else { title <- custom_title }
}
#####################################################   

query <- paste(" and s.stat_id=d.stat_id and d.ob_dates BETWEEN", start_date, "and", end_date, "and d.ob_datee BETWEEN", start_date, "and", end_date, "and ob_hour between", start_hour, "and", end_hour, add_query,sep=" ")
criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")                # Set part of the MYSQL query
qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")      # Set the rest of the MYSQL query
aqdat.df<-db_Query(qs,mysql)                                                      # Query the database and store in aqdat.df dataframe     

## test that the query worked
if (length(aqdat.df) == 0){
   ## error the queried returned nothing
   writeLines("ERROR: Check species/network pairing and Obs start and end dates")
   stop(paste("ERROR querying db: \n",qs))
}

### If plotting another simulation ###
if (run_name2 != "empty") {
   qs2 <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name2," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")      # Set the rest of the MYSQL query
   aqdat2.df<-db_Query(qs2,mysql)
   ## test that the query worked
   if (length(aqdat2.df) == 0){
      ## error the queried returned nothing
      writeLines("ERROR: Check species/network pairing and Obs start and end dates")
      stop(paste("ERROR querying db: \n",qs))
   }
}
######################################

#########################################################
#### Calculate statistics for each requested network ####
#########################################################
## Calculate stats using all pairs, regardless of averaging
indic.nonzero <- aqdat.df[,9] > 0
aqdat_stats.df <- aqdat.df[indic.nonzero,]
#if ((network ==  "NADP_dep") || (network == "NADP_conc")) {	# For the old definition of NADP deposition and concentration
if ((network ==  "NADP") && (zeroprecip == "n")) {		# If NADP and remove 0 precip obs selected
   indic.noprecip <- aqdat_stats.df$precip_ob > 0		# determine where precipitation obs are 0
   aqdat_stats.df <- aqdat_stats.df[indic.noprecip,]		# remove 0 precip pairs from dataframe
}
aqdat_stats.df <- data.frame(network=aqdat_stats.df$network,stat_id=aqdat_stats.df$stat_id,lat=aqdat_stats.df$lat,lon=aqdat_stats.df$lon,Obs=aqdat_stats.df[,9],Mod=aqdat_stats.df[,10],month=aqdat_stats.df$month)
   
n <- length(aqdat_stats.df$Obs)
obs.mean <- mean(aqdat_stats.df$Obs)
obs.sd   <- sqrt(var(aqdat_stats.df$Obs) * ((n-1)/n))
mod.mean <- mean(aqdat_stats.df$Mod)
mod.sd   <- sqrt(var(aqdat_stats.df$Mod) * ((n-1)/n))
bias     <- aqdat_stats.df$Mod-aqdat_stats.df$Obs
x.seq.ob <- seq(min(aqdat_stats.df$Obs), max(aqdat_stats.df$Obs), length=100)
x.seq.mod <- seq(min(aqdat_stats.df$Mod), max(aqdat_stats.df$Mod), length=100)
obs.mean.log <- mean(log(aqdat_stats.df$Obs))
mod.mean.log <- mean(log(aqdat_stats.df$Mod))
obs.sd.log <- sqrt(var(log(aqdat_stats.df$Obs)) * ((n-1)/n))
mod.sd.log <- sqrt(var(log(aqdat_stats.df$Mod)) * ((n-1)/n))

######################################
### If plotting another simulation ###
######################################
if (run_name2 != "empty") {
   indic.nonzero <- aqdat2.df[,9] > 0
   aqdat_stats2.df <- aqdat2.df[indic.nonzero,]
#   if ((network ==  "NADP_dep") || (network == "NADP_conc")) {		# For the old definition of NADP deposition and concentration
   if ((network ==  "NADP") && (zeroprecip == "n")) {			# If NADP and remove 0 precip obs selected
      indic.noprecip <- aqdat_stats2.df$precip_ob > 0			# determine where precipitation obs are 0
      aqdat_stats2.df <- aqdat_stats2.df[indic.noprecip,]		# remove 0 precip pairs from dataframe
   }

   aqdat_stats2.df <- data.frame(network=aqdat_stats2.df$network,stat_id=aqdat_stats2.df$stat_id,lat=aqdat_stats2.df$lat,lon=aqdat_stats2.df$lon,Obs=aqdat_stats2.df[,9],Mod=aqdat_stats2.df[,10],month=aqdat_stats2.df$month)

   n <- length(aqdat_stats2.df$Mod)
   mod.mean <- mean(aqdat_stats2.df$Mod)
   mod.sd   <- sqrt(var(aqdat_stats2.df$Mod) * ((n-1)/n))
   bias     <- aqdat_stats2.df$Mod-aqdat_stats2.df$Obs
   x.seq.mod <- seq(min(aqdat_stats2.df$Mod), max(aqdat_stats2.df$Mod), length=100)
   mod.mean.log <- mean(log(aqdat_stats2.df$Mod))
   mod.sd.log <- sqrt(var(log(aqdat_stats2.df$Mod)) * ((n-1)/n))
}
#######################################

x.axis.max <- max(aqdat_stats.df$Obs,aqdat_stats.df$Mod)*.95

pdf(file=outname_pdf,width=8,height=8)
plot_hist_obs <- hist(aqdat_stats.df$Obs, plot=F)
plot_hist_mod <- hist(aqdat_stats.df$Mod, plot=F)
xmax <- max(plot_hist_obs$breaks,plot_hist_mod$breaks)
ymax <- max(plot_hist_obs$density,plot_hist_mod$density)*1.05
hist_breaks <- seq(0,xmax,length.out=10)
hist(aqdat_stats.df$Obs, col=NULL, border='red', breaks=hist_breaks, ylim=c(0,ymax), xlim=c(0,xmax), prob=T, main=title_all, xlab=paste("Concentration (",units,")"),cex.main=.9)
hist(aqdat_stats.df$Mod, col=NULL, border='blue', breaks=hist_breaks, cex=1, prob=T, axes=F, main="", xlab="", ylab="", add=T)
lines(x.seq.ob, dnorm(x.seq.ob, mean=obs.mean, sd=obs.sd), col="blue")
lines(x.seq.ob, dnorm(x.seq.mod, mean=mod.mean, sd=mod.sd), col="red")
legend("topright", c(network,'CMAQ'), lty=c(1,1), col=c("red","blue"), merge=F, cex=1.2, bty="n")

if (run_info_text == "y") {
   if (rpo != "None") {
      text(x=x.axis.max,y=0.030, paste("RPO = ",rpo,sep=""),cex=1,adj=c(1,.5))           # add RPO region to plot
   }
   if (state != "All") {
      text(x=x.axis.max,y=0.024, paste("State = ",state,sep=""),cex=1,adj=c(1,.5))       # add State abbreviation to plot
   }
   if (site != "All") {
      text(x=x.axis.max,y=0.026, paste("Site = ",site,sep=""),cex=1,adj=c(1,.5))                     # add Site name to plot
   }
}

### Process if PNG output requested ###
if (ametptype == "png") {
   ### Convert pdf format file to png format ###
   convert_command<-paste("convert -density 150x150 ",outname_pdf," ",outname_png,sep="")
   dev.off()
   system(convert_command)

#   ### Remove PDF ###
#   remove_command <- paste("rm ",outname_pdf,sep="")
#   system(remove_command)
}
####################################

##################################
### Create histogram bias plot ###
##################################
pdf(file=outname_bias_pdf,width=8,height=8)
bias_hist <- hist(bias,plot=F)
bias_max <- max(abs(bias_hist$breaks))
hist(bias, col=NULL, border='black', breaks=25, prob=F, xlim=c(-bias_max,bias_max), main=title_bias, xlab=paste("Concentration (",units,")"),cex.main=.9)

### Process if PNG output requested ###
if (ametptype == "png") {
   ### Convert pdf format file to png format ###
   convert_command<-paste("convert -density 150x150 ",outname_bias_pdf," ",outname_bias_png,sep="")
   dev.off()
   system(convert_command)

#   ### Remove PDF ###
#   remove_command <- paste("rm ",outname_pdf,sep="")
#   system(remove_command)
}
####################################
