################## MODEL TO OBS SCATTERPLOT #################### 
### AMET CODE: R_Scatterplot_bins.r 
###
### This script is part of the AMET-AQ system.  This script in a 
### variation of a scatter plot.  The script plots the mean bias 
### and RMSE of the data by bins based on the range of the observed
### concentration.  The script accepts multiple simulations, but
### only a single network and species. This script is new to AMETv1.2.
###
### Last Updated by Wyat Appel; December 6, 2012
###
################################################################

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

### Set file names and titles ###
outname_pdf <- paste(run_name1,species,"scatterplot_bins.pdf",sep="_")                               # Set PDF filename
outname_png <- paste(run_name1,species,"scatterplot_bins.png",sep="_")                               # Set PNG filename
{
   if (custom_title == "") { title <- paste(run_name1," ",species," for ",start_date,end_date,sep=" ") }
   else { title <- custom_title }
}

## Create a full path to file
outname_pdf <- paste(figdir,outname_pdf,sep="/")
outname_png <- paste(figdir,outname_png,sep="/")

####################################################

axis.max     <- NULL
num_obs      <- NULL
sinfo        <- NULL
avg_text     <- ""
legend_names <- NULL
point_char   <- NULL
point_color  <- NULL

### Retrieve units label from database table ###
network <- network_names[1]
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql)
################################################

run_names <- run_name1		# Set default to just one run being plotted
legend_names <- run_names	# Set default for legend

{
   if (run_name2 != "empty") {
      run_names <- c(run_names,run_name2)
      legend_names <- run_names
   }
   if (run_name3 != "empty") {
      run_names <- c(run_names,run_name3)
      legend_names <- run_names
   }
   if (run_name4 != "empty") {
      run_names <- c(run_names,run_name4)
      legend_names <- run_names
   }
   if (run_name5 != "empty") {
      run_names <- c(run_names,run_name5)
      legend_names <- run_names
   }
   if (run_name6 != "empty") {
      run_names <- c(run_names,run_name6)
      legend_names <- run_names
   }
}

num_obs  <- NULL
mb_max   <- NULL
mb_min	 <- NULL
rmse_max <- NULL
max_runs <- length(run_names)
for (j in 1:max_runs) {
   query <- paste(" and s.stat_id=d.stat_id and d.ob_dates BETWEEN", start_date, "and", end_date, "and d.ob_datee BETWEEN", start_date, "and", end_date, "and ob_hour between", start_hour, "and", end_hour, add_query,sep=" ")
   criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="") # Set part of the MYSQL query
   qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_names[j]," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")      # Set the rest of the MYSQL query
   aqdat.df<-db_Query(qs,mysql)							# Query the database and store in aqdat.df dataframe     

   ## test that the query worked
   if (length(aqdat.df) == 0){
     ## error the queried returned nothing
     writeLines("ERROR: Check species/network pairing and Obs start and end dates")
     stop(paste("ERROR querying db: \n",qs))
   }

 
   ### if plotting all obs, remove missing obs and zero precip obs if requested ###
   #######################
   if (remove_negatives == "y") {
      indic.nonzero <- aqdat.df[,9] >= 0							# determine which obs are missing (less than 0); 
      aqdat.df <- aqdat.df[indic.nonzero,]							# remove missing obs from dataframe
   }
   indic.nonzero <- aqdat.df[,10] >= 0                                                        # determine which obs are missing (less than 0); 
   aqdat.df <- aqdat.df[indic.nonzero,]                                                      # remove missing obs from dataframe

   if ((network ==  "NADP_dep") || (network == "NADP_conc") && (zeroprecip == 'n')) {	# determine if using NADP data and removing 0 precip obs
      if (zeroprecip == 'n') {
         indic.noprecip <- aqdat.df$precip_ob > 0						# determine where precipitation obs are 0
         aqdat.df <- aqdat.df[indic.noprecip,]						# remove 0 precip pairs from dataframe
      }
   }
   aqdat.df <- data.frame(Network=aqdat.df$network,Stat_ID=aqdat.df$stat_id,lat=aqdat.df$lat,lon=aqdat.df$lon,Obs_Value=round(aqdat.df[,9],5),Mod_Value=round(aqdat.df[,10],5),Month=aqdat.df$month)	# Create dataframe of network values to be used to create a list

   mb_q1_mod       <- NULL
   mb_q3_mod       <- NULL
   mb_min_mod      <- NULL
   mb_max_mod      <- NULL
   mb_median       <- NULL
   mb_mean	   <- NULL
   mb_median_obs   <- NULL
   rmse_q1_mod     <- NULL
   rmse_q3_mod     <- NULL
   rmse_min_mod    <- NULL
   rmse_max_mod    <- NULL
   rmse_median     <- NULL
   rmse_mean       <- NULL
   rmse_median_obs <- NULL
   num_obs         <- NULL

###########################################
### Determine the interval range values ###
###########################################
   if (length(x_axis_max) > 0) {
      indic.value <- aqdat.df$Obs_Value < x_axis_max
      aqdat.df <- aqdat.df[indic.value,]
   }
   if (j == 1) {						# Only do this for first query
      ob_range_all <- pretty(c(0,aqdat.df$Obs_Value),n=10)	# Determine a nice range to fit the obs
      interval <- ob_range_all[2]-ob_range_all[1]		# Determine the interval based on the range
      ob_range <- ob_range_all		
      if (length(ob_range_all) > 11) {
         ob_range <- ob_range_all[1:11]				# constrain plot to 11 intervals
      }
      num_intervals <- length(ob_range)
   }
##########################################
   for (i in 1:length(ob_range)) {
      site_rmse <- NULL
      site_mb   <- NULL
      bias      <- NULL
      rmse      <- NULL
      indic.bin <- aqdat.df$Obs_Value > ob_range[i]
      bin.df <- as.vector(aqdat.df[indic.bin,])
      if (i != max(length(ob_range))) {
         indic.bin <- bin.df$Obs_Value <= ob_range[(i+1)]
         bin.df <- bin.df[indic.bin,]
      }
      if (length(bin.df$Stat_ID) >= 5) {	# IMPORTANT: This sets the miniumum number of pairs to 5 
         bias <- bin.df$Mod_Value-bin.df$Obs_Value
         rmse <- sqrt((bin.df$Mod_Value-bin.df$Obs_Value)^2)
         mod.stats1 <- boxplot(bias, plot=F)
         mb_q1_mod[i] <- mod.stats1$stats[2,]
         mb_q3_mod[i] <- mod.stats1$stats[4,]
         mb_median[i] <- mod.stats1$stats[3,]
         mb_mean[i] <- mean(bias)
         mb_min_mod[i] <- mod.stats1$stats[1,]
         mb_max_mod[i] <- mod.stats1$stats[5,]
         num_obs[i] <- length(bin.df$Stat_ID)
         mod.stats2 <- boxplot(rmse, plot=F)
         rmse_q1_mod[i] <- mod.stats2$stats[2,]
         rmse_q3_mod[i] <- mod.stats2$stats[4,]
         rmse_median[i] <- mod.stats2$stats[3,]
         rmse_mean[i]   <- mean(rmse)
         rmse_min_mod[i] <- mod.stats2$stats[1,]
         rmse_max_mod[i] <- mod.stats2$stats[5,]
         mb_max <- max(mb_max,mb_q1_mod,mb_q3_mod,na.rm=T)
         mb_min <- min(mb_min,mb_q1_mod,mb_q3_mod,na.rm=T)
         rmse_max <- max(rmse_max,rmse_q3_mod,na.rm=T)
      }
   }
   sinfo[[j]] <- list(num_obs=num_obs,plotval_mb_q1=mb_q1_mod,plotval_mb_q3=mb_q3_mod,plotval_mb_median=mb_median,plotval_mb_mean=mb_mean,plotval_rmse_q1=rmse_q1_mod,plotval_rmse_q3=rmse_q3_mod,plotval_rmse_median=rmse_median,plotval_rmse_mean=rmse_mean)
}

##############################
### Write Data to CSV File ###
##############################

filename_txt <- paste(run_name1,species,"scatterplot_bins.csv",sep="_")     # Set output file name
filename_txt <- paste(figdir,filename_txt, sep="/")  ## make full path
write.table(run_name1,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
write.table(t(c(start_date,end_date)),file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(aqdat.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
###############################
count <- sum(is.na(aqdat.df$Obs_Value))	# count number of NAs in column
len   <- length(aqdat.df$Obs_Value)
if (count != len) {	# test to see if data is available, if so, compute axis.max
   y.axis.rmse.max <- rmse_max*1.1
   y.axis.rmse.min <- y.axis.rmse.max * .033
   y.axis.rmse.min <- y.axis.rmse.min - 0.1*y.axis.rmse.max
   x.axis.rmse.min <- y.axis.rmse.max * .033	# set axis minimum to look like 0 (weird R thing)
   
   y.axis.mb.max <- mb_max+((mb_max-mb_min)*0.20)
   y.axis.mb.min <- mb_min-((mb_max-mb_min)*0.10)
   x.axis.max <- 1.07*max(ob_range)
}
if (length(y_axis_max) > 0) {
   y.axis.mb.max <- y_axis_max
}
if (length(y_axis_min) > 0) {
   y.axis.mb.min <- y_axis_min
}
################################

##############################################
########## MAKE SCATTERPLOT: ALL US ##########
##############################################
### Preset values for plot characters and colors (these can be changed to user preference) ###
plot_chars <- c(24,21,25,22,23,19)
plot_cols <- plot_colors
##############################################
   
#################################
### Create Plot for Mean Bias ###
#################################
pdf(file=outname_pdf,width=11,height=6)
my.layout <- layout(matrix(c(1, 2),nrow=1,ncol=2,byrow=T),widths=c(1,1),heights=c(.8,1))
par(mgp=c(2,0.6,0))
par(mai=c(0.7,0.6,0.4,0.1),las=1,lab=c(12,12,7))

plot(1,1,type="n", pch=3, col="red", ylim=c(y.axis.mb.min, y.axis.mb.max), xlim=c(min(ob_range),x.axis.max), xlab=paste("Binned Range of Observed Concentrations (",units,")",sep=""), ylab=paste("Mean Bias (",units,")",sep=""), cex.axis=.9, cex.lab=1,col.axis="white")       # create plot axis and labels, but do not plot any points
abline(h=0)
###################################################
### This section fixes the plotting of the x axis
### so that the greater than sign is included 
### and so the tick marks match the intervals used
### to create the bins.  Pretty much a hack, but
### it works.
###################################################
x.axis_labels <- ob_range						# set x-axis labels to match bin ranges
x.axis_labels[length(ob_range)] <- paste(">",max(ob_range),sep="")	# add greater than sign to last bin, since it includes all values greater
ob_range <- c(ob_range,(x.axis.max+interval))				# set ob_range one interval greater than what was plotted
x.axis_labels<-c(x.axis_labels,(x.axis.max+interval))			# add one additional interval to x.axis.labels 
axis(side=1,col.axis="white",col="white",lwd=1.5)			# cover default x axis tick marks and labels with white text 
axis(side=1,labels=x.axis_labels,at=ob_range,cex.axis=0.8)		# add x axis tick marks and labels at previously specified intervals
axis(2,cex.axis=0.8)							# add y-axis text back, since it was changed to white in plot command
###################################################
abline(v=ob_range,col="grey40",lty=3)
legend("topright", legend_names, pch=plot_chars, col=plot_cols, merge=F, cex=0.9, bty="n",pt.bg=plot_cols)
title_all <- paste(species," Site Mean Bias for",start_date, "to", end_date, sep=" ")	# Set plot title
title(main=title_all,cex.main=0.8)
font_size <- 0.8
if (max_runs > 4) {
   font_size <- 0.6
}
for (k in 1:max_runs) {
   offset <- seq(0,interval,by=(interval/(max_runs+1)))
   font_size <- 0.6
   x <- 0+offset[k+1]
   for (i in 1:num_intervals) {
      points(x,sinfo[[k]]$plotval_mb_median[i],col=plot_cols[k],cex=font_size,pch=plot_chars[k],bg=plot_cols[k])
      points(x,sinfo[[k]]$plotval_mb_mean[i],col=plot_cols[k],cex=font_size,pch=8,bg=plot_cols[k])
      lines(c(x,x),c((sinfo[[k]]$plotval_mb_q1[i]),(sinfo[[k]]$plotval_mb_q3[i])),col=plot_cols[k],cex=font_size)
      points(c(x,x),c((sinfo[[k]]$plotval_mb_q1[i]),(sinfo[[k]]$plotval_mb_q3[i])),col=plot_cols[k],pch="-",cex=font_size)
      x <- x+interval
   }
}
x4 <- .5*interval
for (i in 1:num_intervals) {
   if (sum(sinfo[[1]]$num_obs,na.rm=T)-sum(sinfo[[max_runs]]$num_obs,na.rm=T) == 0) {
      text(x4,y.axis.mb.min,num_obs[i],cex=.8)
   }
   x4 <- x4+interval
}
####################################

############################
### Create Plot for RMSE ###
############################
plot(1,1,type="n", pch=3, col="red", ylim=c(y.axis.rmse.min,y.axis.rmse.max), xlim=c(min(ob_range),x.axis.max), xlab=paste("Binned Range of Observed Concentrations (",units,")",sep=""), ylab=paste("RMSE (",units,")",sep=""), cex.axis=0.9, cex.lab=1, col.axis="white") # create plot axis and labels, but do not plot any points
axis(side=1,col.axis="white",col="white",lwd=1.5)                       # cover default x axis tick marks and labels with white text 
axis(side=1,labels=x.axis_labels,at=ob_range,cex.axis=0.8)		# add x axis tick marks and labels at previously specified intervals
axis(2,cex.axis=0.8)                                                    # add y-axis text back, since it was changed to white in plot command
abline(v=ob_range,col="grey40",lty=3)
legend("topleft", legend_names, pch=plot_chars, col=plot_cols, merge=F, cex=0.9, bty="n",pt.bg=plot_cols)
title_all <- paste(run_name1," ",species," Site RMSE for",start_date, "to", end_date, sep=" ")	# Set plot title
title(main=title_all,cex.main=0.8)
font_size <- 0.8
if (max_runs > 4) {
   font_size <- 0.6
}
for (k in 1:max_runs) {
   offset <- seq(0,interval,by=(interval/(max_runs+1)))
   x <- 0+offset[k+1]
   for (i in 1:num_intervals) {
      points(x,sinfo[[k]]$plotval_rmse_median[i],col=plot_cols[k],cex=font_size,pch=plot_chars[k],bg=plot_cols[k])
      points(x,sinfo[[k]]$plotval_rmse_mean[i],col=plot_cols[k],cex=font_size,pch=8,bg=plot_cols[k])
      lines(c(x,x),c((sinfo[[k]]$plotval_rmse_q1[i]),(sinfo[[k]]$plotval_rmse_q3[i])),col=plot_cols[k],cex=font_size)
      points(c(x,x),c((sinfo[[k]]$plotval_rmse_q1[i]),(sinfo[[k]]$plotval_rmse_q3[i])),col=plot_cols[k],pch="-",cex=font_size)
      x <- x+interval
   }
}
x4 <- 0.5*interval
for (i in 1:num_intervals) {
   if (sum(sinfo[[1]]$num_obs,na.rm=T)-sum(sinfo[[max_runs]]$num_obs,na.rm=T) == 0) {
      text(x4,y.axis.rmse.min,num_obs[i],cex=.8)
   }
   x4 <- x4+interval
}

abline(h=0,col="black")
#################################

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
