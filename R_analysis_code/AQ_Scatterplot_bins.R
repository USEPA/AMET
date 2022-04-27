header <- "
#################### MODEL TO OBS BINNED SCATTERPLOT ######################
### AMET CODE: R_Scatterplot_bins.r 
###
### This script is part of the AMET-AQ system.  This script creates a binned
### bias/RMSE plot. This script will create a binned bias/RMSE plot for a single
### species from a single network but for multiple simulations. Output format
### in png, pdf or both.
###
### Last Updated by Wyat Appel: Mar 2021
###########################################################################
"

## get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

### Retrieve units label from database table ###
network <- network_names[1]
#units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
################################################

### Set file names and titles ###
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }

filename_pdf <- paste(run_name1,species,pid,"scatterplot_bins.pdf",sep="_")                          # Set PDF filename
filename_png <- paste(run_name1,species,pid,"scatterplot_bins.png",sep="_")                          # Set PNG filenam
filename_txt <- paste(run_name1,species,pid,"scatterplot_bins.csv",sep="_")     # Set output file name

## Create a full path to file
filename_pdf <- paste(figdir,filename_pdf,sep="/")                          # Set PDF filename
filename_png <- paste(figdir,filename_png,sep="/")                          # Set PNG filenam
filename_txt <- paste(figdir,filename_txt,sep="/")     # Set output file name

pca <- NULL

pca[1] <-" and (s.state='ME' or s.state='NH' or s.state='VT' or s.state='MA' or s.state='NY' or s.state='NJ' or s.state='MD' or s.state='DE' or s.state='CT' or s.state='RI' or s.state='PA' or s.state='DC') "
############################################

### Query for Aerosol/Ozone Great Lakes PCA region ###
pca[2] <-" and (s.state='OH' or s.state='MI' or s.state='IN' or s.state='IL' or s.state='WI') "
############################################

### Query for Ozone Atlantic PCA region ###
pca[3] <-" and (s.state='WV' or s.state='KY' or s.state='TN' or s.state='VA' or s.state='NC' or s.state='SC' or s.state='GA' or s.state='AL') "
############################################

### Query for Ozone Southwest PCA region ###
pca[4] <-" and (s.state='LA' or s.state='MS' or s.state='MO' or s.state='TX' or s.state='OK') "
############################################

pca_names <- c("Northeast","Great Lakes","Atlantic","South")

axis.max     <- NULL
num_obs      <- NULL
sinfo        <- NULL
avg_text     <- ""
legend_names <- NULL
point_char   <- NULL
point_color  <- NULL

################################################

run_names    <- run_name1		# Set default to just one run being plotted
legend_names <- NULL			# Set default for legend

if (pca_flag == 'y') {
   run_names <- c(run_name1,run_name1,run_name1,run_name1)
   legend_names <- pca_names
}

{
if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
      run_names <- c(run_names,run_name2)
      pca_flag <- "n"
   }
   if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
      run_names <- c(run_names,run_name3)
   }
   if ((exists("run_name4")) && (nchar(run_name4) > 0)) {
      run_names <- c(run_names,run_name4)
   }
   if ((exists("run_name5")) && (nchar(run_name5) > 0)) {
      run_names <- c(run_names,run_name5)
   }
   if ((exists("run_name6")) && (nchar(run_name6) > 0)) {
      run_names <- c(run_names,run_name6)
   }
}

num_obs      <- NULL
mb_max       <- NULL
mb_min	     <- NULL
rmse_max     <- NULL
num_runs     <- length(run_names)
for (j in 1:num_runs) {
   {
      if (pca_flag == "y") {
         criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",pca[j],query,sep="") # Set part of the MYSQL query
      }
      else {
         criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="") # Set part of the MYSQL query
      }
   }
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_names[j],species)
         aqdat_query.df   <- sitex_info$sitex_data
         data_exists	  <- sitex_info$data_exists
         if (data_exists == "y") { units <- as.character(sitex_info$units[[1]]) }
      }
      else {
         query_result   <- query_dbase(run_names[j],network,species,criteria)
         aqdat_query.df <- query_result[[1]]
         data_exists    <- query_result[[2]]
         if (data_exists == "y") { units <- query_result[[3]] }
      }
   }
   ob_col_name <- paste(species,"_ob",sep="")
   mod_col_name <- paste(species,"_mod",sep="")
   {
      if (data_exists == "n") {
         num_runs <- (num_runs-1)
         sinfo[[j]] <- "No Data"
         if (num_runs == 0) { stop("Stopping because num_runs is zero. Likely no data found for query.") }
      }
      else {
         if (pca_flag != "y") { legend_names <- c(legend_names,run_names[j]) }
         if (averaging != "n") {
            aqdat.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=round(aqdat_query.df[[ob_col_name]],5),Mod_Value=round(aqdat_query.df[[mod_col_name]],5),Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month)
            {
               if (use_avg_stats == "y") {
                  aqdat.df <- Average(aqdat.df)
                  aqdat_stats.df <- aqdat.df                               # Call Monthly_Average function in Misc_Functions.R
               }
               else {
                  aqdat_stats.df <- aqdat.df
                  aqdat.df <- Average(aqdat.df)
               }
            }
         }
         else { 
            aqdat.df <- aqdat_query.df
            aqdat.df <- data.frame(Network=aqdat.df$network,Stat_ID=aqdat.df$stat_id,lat=aqdat.df$lat,lon=aqdat.df$lon,Obs_Value=round(aqdat.df[[ob_col_name]],5),Mod_Value=round(aqdat.df[[mod_col_name]],5),Month=aqdat.df$month)      # Create dataframe of network values to be used to create a list
            aqdat_stats.df <- aqdat.df
         }
         aqdat.df$Bin_Value <- aqdat.df$Obs_Value
         Mod_Obs_label <- "Observed"
         if (bin_by_mod == 'y') {
            aqdat.df$Bin_Value <- aqdat.df$Mod_Value
            Mod_Obs_label <- "Modeled"
         } 
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
            indic.value <- aqdat.df$Bin_Value < x_axis_max
            aqdat.df <- aqdat.df[indic.value,]
         }
         if (j == 1) {						# Only do this for first query
            bin_range_all <- pretty(c(0,aqdat.df$Bin_Value),n=10)	# Determine a nice range to fit the obs
            interval <- bin_range_all[2]-bin_range_all[1]		# Determine the interval based on the range
            bin_range <- bin_range_all		
            if (length(bin_range_all) > 11) {
               bin_range <- bin_range_all[1:11]				# constrain plot to 11 intervals
            }
           num_intervals <- length(bin_range)
         }
         ##########################################
         for (n in 1:length(bin_range)) {
            site_rmse <- NULL
            site_mb   <- NULL
            bias      <- NULL
            rmse      <- NULL
            indic.bin <- aqdat.df$Bin_Value > bin_range[n]
            bin.df <- as.vector(aqdat.df[indic.bin,])
            if (n != max(length(bin_range))) {
               indic.bin <- bin.df$Bin_Value <= bin_range[(n+1)]
               bin.df <- bin.df[indic.bin,]
            }
            if (length(bin.df$Stat_ID) >= 5) {	# IMPORTANT: This sets the miniumum number of pairs to 5 
               bias 		<- bin.df$Mod_Value-bin.df$Obs_Value
               rmse 		<- sqrt((bin.df$Mod_Value-bin.df$Obs_Value)^2)
               mod.stats1 	<- boxplot(bias, plot=F)
               mb_q1_mod[n] 	<- mod.stats1$stats[2,]
               mb_q3_mod[n] 	<- mod.stats1$stats[4,]
               mb_median[n] 	<- mod.stats1$stats[3,]
               mb_mean[n] 	<- mean(bias)
               mb_min_mod[n] 	<- mod.stats1$stats[1,]
               mb_max_mod[n] 	<- mod.stats1$stats[5,]
               num_obs[n] 	<- length(bin.df$Stat_ID)
               mod.stats2 	<- boxplot(rmse, plot=F)
               rmse_q1_mod[n] <- mod.stats2$stats[2,]
               rmse_q3_mod[n] <- mod.stats2$stats[4,]
               rmse_median[n] <- mod.stats2$stats[3,]
               rmse_mean[n]   <- mean(rmse)
               rmse_min_mod[n] <- mod.stats2$stats[1,]
               rmse_max_mod[n] <- mod.stats2$stats[5,]
               mb_max 	<- max(mb_max,mb_q1_mod,mb_q3_mod,na.rm=T)
               mb_min 	<- min(mb_min,mb_q1_mod,mb_q3_mod,na.rm=T)
               rmse_max 	<- max(rmse_max,rmse_q3_mod,na.rm=T)
            }
         }
         sinfo[[j]] <- list(num_obs=num_obs,plotval_mb_q1=mb_q1_mod,plotval_mb_q3=mb_q3_mod,plotval_mb_median=mb_median,plotval_mb_mean=mb_mean,plotval_rmse_q1=rmse_q1_mod,plotval_rmse_q3=rmse_q3_mod,plotval_rmse_median=rmse_median,plotval_rmse_mean=rmse_mean)
      }	# End no data if/else statement
   }	# End enclosure of if/else statement
   ##############################
   ### Write Data to CSV File ###
   ##############################
   aqdat_out.df <- aqdat.df
   if (j == 1) {
      write.table(run_names[j],file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
      write.table(dates,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(sinfo[[j]],file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
   }
   else {
      write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(run_names[j],file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(sinfo[[j]],file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
   }
   ###############################
}	# End num_runs/pca loop

count <- sum(is.na(aqdat.df$Obs_Value))	# count number of NAs in column
len   <- length(aqdat.df$Obs_Value)
if (count != len) {	# test to see if data is available, if so, compute axis.max
   y.axis.rmse.max <- rmse_max*1.1
   y.axis.rmse.min <- y.axis.rmse.max * .033
   y.axis.rmse.min <- y.axis.rmse.min - 0.1*y.axis.rmse.max*num_runs/2
   x.axis.rmse.min <- y.axis.rmse.max * .033	# set axis minimum to look like 0 (weird R thing)
   
   y.axis.mb.max <- mb_max+((mb_max-mb_min)*0.20)
   y.axis.mb.min <- mb_min-((mb_max-mb_min)*0.10)*num_runs/2
   x.axis.max <- 1.07*max(bin_range)
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
pdf(file=filename_pdf,width=11,height=6)
my.layout <- layout(matrix(c(1, 2),nrow=1,ncol=2,byrow=T),widths=c(1,1),heights=c(.8,1))
par(mgp=c(2,0.6,0))
par(mai=c(0.7,0.6,0.4,0.1),las=1,lab=c(12,12,7))

plot(1,1,type="n", pch=3, col="red", ylim=c(y.axis.mb.min, y.axis.mb.max), xlim=c(min(bin_range),x.axis.max), xlab=paste("Binned Range of ",Mod_Obs_label," Concentrations (",units,")",sep=""), ylab=paste("Mean Bias (",units,")",sep=""), cex.axis=.9, cex.lab=1,col.axis="white")       # create plot axis and labels, but do not plot any points
abline(h=0)
###################################################
### This section fixes the plotting of the x axis
### so that the greater than sign is included 
### and so the tick marks match the intervals used
### to create the bins.  Pretty much a hack, but
### it seems to work.
###################################################
x.axis_labels <- bin_range						# set x-axis labels to match bin ranges
x.axis_labels[length(bin_range)] <- paste(">",max(bin_range),sep="")	# add greater than sign to last bin, since it includes all values greater
bin_range <- c(bin_range,(x.axis.max+interval))				# set ob_range one interval greater than what was plotted
x.axis_labels<-c(x.axis_labels,(x.axis.max+interval))			# add one additional interval to x.axis.labels 
axis(side=1,col.axis="white",col="white",lwd=1.5)			# cover default x axis tick marks and labels with white text 
axis(side=1,labels=x.axis_labels,at=bin_range,cex.axis=0.8)		# add x axis tick marks and labels at previously specified intervals
axis(2,cex.axis=0.8)							# add y-axis text back, since it was changed to white in plot command
###################################################
abline(v=bin_range,col="grey40",lty=3)
legend("topright", legend_names, pch=plot_chars, col=plot_cols, merge=F, cex=0.9, bty="n",pt.bg=plot_cols)
title_all <- paste(species," Site Mean Bias for ",dates,sep="")	# Set plot title
title(main=title_all,cex.main=0.8)
font_size <- 0.8
if (num_runs > 4) {
   font_size <- 0.6
}
for (k in 1:num_runs) {
   offset <- seq(0,interval,by=(interval/(num_runs+1)))
   font_size <- 0.6
   x <- 0+offset[k+1]
   for (n in 1:num_intervals) {
      points(x,sinfo[[k]]$plotval_mb_median[n],col=plot_cols[k],cex=font_size,pch=plot_chars[k],bg=plot_cols[k])
      points(x,sinfo[[k]]$plotval_mb_mean[n],col=plot_cols[k],cex=font_size,pch=8,bg=plot_cols[k])
      lines(c(x,x),c((sinfo[[k]]$plotval_mb_q1[n]),(sinfo[[k]]$plotval_mb_q3[n])),col=plot_cols[k],cex=font_size)
      points(c(x,x),c((sinfo[[k]]$plotval_mb_q1[n]),(sinfo[[k]]$plotval_mb_q3[n])),col=plot_cols[k],pch="-",cex=font_size)
      x <- x+interval
   }
}
x4 <- .5*interval
y_range <- y.axis.mb.max-y.axis.mb.min
for (n in 1:num_intervals) {
   for (j in 1:num_runs) {
      text(x4,(y.axis.mb.min+(y_range*(0.03*(j-1)))),sinfo[[j]]$num_obs[n],cex=.8,col=plot_cols[j])
   }   
   x4 <- x4+interval
}
####################################

############################
### Create Plot for RMSE ###
############################
plot(1,1,type="n", pch=3, col="red", ylim=c(y.axis.rmse.min,y.axis.rmse.max), xlim=c(min(bin_range),x.axis.max), xlab=paste("Binned Range of ",Mod_Obs_label," Concentrations (",units,")",sep=""), ylab=paste("RMSE (",units,")",sep=""), cex.axis=0.9, cex.lab=1, col.axis="white") # create plot axis and labels, but do not plot any points
axis(side=1,col.axis="white",col="white",lwd=1.5)                       # cover default x axis tick marks and labels with white text 
axis(side=1,labels=x.axis_labels,at=bin_range,cex.axis=0.8)		# add x axis tick marks and labels at previously specified intervals
axis(2,cex.axis=0.8)                                                    # add y-axis text back, since it was changed to white in plot command
abline(v=bin_range,col="grey40",lty=3)
legend("topleft", legend_names, pch=plot_chars, col=plot_cols, merge=F, cex=0.9, bty="n",pt.bg=plot_cols)
title_all <- paste(species," Site RMSE for ",dates,sep="")	# Set plot title
title(main=title_all,cex.main=0.8)
font_size <- 0.8
if (num_runs > 4) {
   font_size <- 0.6
}
for (k in 1:num_runs) {
   offset <- seq(0,interval,by=(interval/(num_runs+1)))
   x <- 0+offset[k+1]
   for (n in 1:num_intervals) {
      points(x,sinfo[[k]]$plotval_rmse_median[n],col=plot_cols[k],cex=font_size,pch=plot_chars[k],bg=plot_cols[k])
      points(x,sinfo[[k]]$plotval_rmse_mean[n],col=plot_cols[k],cex=font_size,pch=8,bg=plot_cols[k])
      lines(c(x,x),c((sinfo[[k]]$plotval_rmse_q1[n]),(sinfo[[k]]$plotval_rmse_q3[n])),col=plot_cols[k],cex=font_size)
      points(c(x,x),c((sinfo[[k]]$plotval_rmse_q1[n]),(sinfo[[k]]$plotval_rmse_q3[n])),col=plot_cols[k],pch="-",cex=font_size)
      x <- x+interval
   }
}
x4 <- 0.5*interval
y_range <- y.axis.rmse.max-y.axis.rmse.min
for (n in 1:num_intervals) {
   for (j in 1:num_runs) {
      text(x4,(y.axis.rmse.min+(y_range*(0.03*(j-1)))),sinfo[[j]]$num_obs[n],cex=.8,col=plot_cols[j])
   }
   x4 <- x4+interval
}

abline(h=0,col="black")

### Convert file to png ###
dev.off()
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_pdf," png:",filename_png,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}

#################################
