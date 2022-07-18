header <- "
##################### HOURLY BOX PLOT ##########################
### AMET CODE: AQ_Boxplot_hourly.R
###
### This script is part of the AMET-AQ system.  It plots a box plot
### using only hourly data. Individual observation/model pairs are 
### provided through a MYSQL query. The script then plots these values
### using the default R boxplot function as a box plot.
###
### Last updated by Wyat Appel: Nov 2020
################################################################
"

## get some environmental variables and setup some directories
ametbase	<- Sys.getenv("AMETBASE")			# base directory of AMET
ametR		<- paste(ametbase,"/R_analysis_code",sep="")	# R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

### Retrieve units label from database table ###
network  <- network_names[1]
#units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
################################################

### Set file names and titles ###
filename_pdf <- paste(run_name1,species,pid,"boxplot_hourly.pdf",sep="_")
filename_png <- paste(run_name1,species,pid,"boxplot_hourly.png",sep="_")
filename_txt <- paste(run_name1,species,pid,"boxplot_hourly_data.csv",sep="_")      # Set output file name

## Create a full path to file
filename_pdf <- paste(figdir,filename_pdf,sep="/")
filename_png <- paste(figdir,filename_png,sep="/")
filename_txt <- paste(figdir,filename_txt,sep="/")      # Set output file name

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
title <- get_title(run_names,species,network_names,dates,custom_title,clim_reg)

#################################
{
   if (Sys.getenv("AMET_DB") == 'F') {
      sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,species)
      data_exists      <- sitex_info$data_exists
      if (data_exists == "y") {
         aqdat_query.df   <- sitex_info$sitex_data
         aqdat_query.df   <- aqdat_query.df[with(aqdat_query.df,order(stat_id,ob_dates,ob_hour)),]
         units            <- as.character(sitex_info$units[[1]])
      }
   }
   else {
      query_result    <- query_dbase(run_name1,network,species)
      aqdat_query.df  <- query_result[[1]]
      data_exists     <- query_result[[2]]
      if (data_exists == "y") { units <- query_result[[3]] }
   }
}
if (data_exists == "n") {
   stop("Stopping because data_exists flag is false. Likely no data found for query.") 
}

ob_col_name <- paste(species,"_ob",sep="")
mod_col_name <- paste(species,"_mod",sep="")
aqdat.df <- aqdat_query.df
names(aqdat.df)[names(aqdat.df) == ob_col_name] <- "Obs_Value"
names(aqdat.df)[names(aqdat.df) == mod_col_name] <- "Mod_Value"
#names(aqdat.df)[9]  <-"Obs_Value"
#names(aqdat.df)[10] <-"Mod_Value"


if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info        <- read_sitex(Sys.getenv("OUTDIR"),network,run_name2,species)
         aqdat_query2.df   <- (sitex_info$sitex_data)
         aqdat_query2.df   <- aqdat_query2.df[with(aqdat_query2.df,order(stat_id,ob_dates,ob_hour)),]
         units             <- as.character(sitex_info$units[[1]])
      }
      else {
         query_result2    <- query_dbase(run_name2,network,species)
         aqdat_query2.df  <- query_result2[[1]]
      }
   }
   aqdat2.df <- aqdat_query2.df
   names(aqdat2.df)[names(aqdat2.df) == ob_col_name] <- "Obs_Value"
   names(aqdat2.df)[names(aqdat2.df) == mod_col_name] <- "Mod_Value"
#   names(aqdat2.df)[9]  <-"Obs_Value"
#   names(aqdat2.df)[10] <-"Mod_Value"
}

if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info        <- read_sitex(Sys.getenv("OUTDIR"),network,run_name3,species)
         aqdat_query3.df   <- (sitex_info$sitex_data)
         aqdat_query3.df   <- aqdat_query3.df[with(aqdat_query3.df,order(stat_id,ob_dates,ob_hour)),]
         units             <- as.character(sitex_info$units[[1]])
      }
      else {
         query_result3    <- query_dbase(run_name3,network,species)
         aqdat_query3.df  <- query_result3[[1]]
      }
   }
   aqdat3.df <- aqdat_query3.df
   names(aqdat3.df)[names(aqdat3.df) == ob_col_name] <- "Obs_Value"
   names(aqdat3.df)[names(aqdat3.df) == mod_col_name] <- "Mod_Value"
#   names(aqdat3.df)[9]  <-"Obs_Value"
#   names(aqdat3.df)[10] <-"Mod_Value"
}

#######################

#aqdat.df <- aqdat_query.df

### Remove mean if requested ###
if (remove_mean == 'y') {
   aqdat_new.df 	<- NULL
   split_sites		<- split(aqdat_query.df,aqdat_query.df$stat_id)
   for (h in 1:(length(split_sites))) {
      sub.df 		<- split_sites[[h]]
      mean_obs          <- mean(sub.df$Obs_Value)
      mean_mod1         <- mean(sub.df$Mod_Value)
      sub.df$Obs_Value	<- sub.df$Obs_Value-mean_obs
      sub.df$Mod_Value       <- sub.df$Mod_Value-mean_mod1
      aqdat_new.df	<- rbind(aqdat_new.df,sub.df)
   }
   aqdat.df <- aqdat_new.df
   if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
      aqdat_new2.df         <- NULL
      split_sites2          <- split(aqdat_query2.df,aqdat_query2.df$stat_id)
      for (h in 1:(length(split_sites2))) {
         sub.df            <- split_sites2[[h]]
         mean_obs          <- mean(sub2.df$Obs_Value)
         mean_mod2         <- mean(sub2.df$Mod_Value)
         sub.df$Obs_Value        <- sub2.df$Obs_Value-mean_obs
         sub.df$Mod_Value       <- sub2.df$Mod_Value-mean_mod2
         aqdat_new2.df      <- rbind(aqdat_new2.df,sub2.df)
      }
      aqdat2.df <- aqdat_new2.df
   }
   if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
      aqdat_new3.df         <- NULL
      split_sites3          <- split(aqdat_query3.df,aqdat_query3.df$stat_id)
      for (h in 1:(length(split_sites3))) {
         sub.df            <- split_sites3[[h]]
         mean_obs          <- mean(sub3.df$Obs_Value)
         mean_mod2         <- mean(sub3.df$Mod_Value)
         sub.df$Obs_Value        <- sub3.df$Obs_Value-mean_obs
         sub.df$Mod_Value       <- sub3.df$Mod_Value-mean_mod3
         aqdat_new3.df      <- rbind(aqdat_new3.df,sub3.df)
      }
      aqdat3.df <- aqdat_new3.df
   }
}
#################################

### Find q1, median, q2 for each group of both species ###
q1.spec1     <- tapply(aqdat.df$Obs_Value, aqdat.df$ob_hour, quantile, 0.25, na.rm=T)	# Compute ob 25% quartile
q1.spec2     <- tapply(aqdat.df$Mod_Value, aqdat.df$ob_hour, quantile, 0.25, na.rm=T)	# Compute model 25% quartile
median.spec1 <- tapply(aqdat.df$Obs_Value, aqdat.df$ob_hour, median, na.rm=T)		# Compute ob median value
median.spec2 <- tapply(aqdat.df$Mod_Value, aqdat.df$ob_hour, median, na.rm=T)	# Compute model median value
mean.spec1   <- tapply(aqdat.df$Obs_Value, aqdat.df$ob_hour, mean, na.rm=T)           # Compute ob median value
mean.spec2   <- tapply(aqdat.df$Mod_Value, aqdat.df$ob_hour, mean, na.rm=T)   # Compute model median value
q3.spec1     <- tapply(aqdat.df$Obs_Value, aqdat.df$ob_hour, quantile, 0.75, na.rm=T)	# Compute ob 75% quartile
q3.spec2     <- tapply(aqdat.df$Mod_Value, aqdat.df$ob_hour, quantile, 0.75, na.rm=T)	# Compute model 75% quartile
################################################

q1.spec3     <- NULL
median.spec3 <- NULL
q3.spec3     <- NULL
bar_colors   <- plot_colors
bar_width    <- c(0.8,0.4)

if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   q1.spec3     <- tapply(aqdat2.df$Mod_Value, aqdat2.df$ob_hour, quantile, 0.25, na.rm=T)	# Compute model 25% quartile
   median.spec3 <- tapply(aqdat2.df$Mod_Value, aqdat2.df$ob_hour, median, na.rm=T)		# Compute model median value
   q3.spec3     <- tapply(aqdat2.df$Mod_Value, aqdat2.df$ob_hour, quantile, 0.75, na.rm=T)	# Compute model 75% quartile
   bar_colors   <- plot_colors
   bar_width    <- c(0.8,0.5,0.2)
}

q1.spec4     <- NULL
median.spec4 <- NULL
q3.spec4     <- NULL

if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
   q1.spec4     <- tapply(aqdat3.df$Mod_Value, aqdat3.df$ob_hour, quantile, 0.25, na.rm=T)   # Compute model 25% quartile
   median.spec4 <- tapply(aqdat3.df$Mod_Value, aqdat3.df$ob_hour, median, na.rm=T)           # Compute model median value
   q3.spec4     <- tapply(aqdat3.df$Mod_Value, aqdat3.df$ob_hour, quantile, 0.75, na.rm=T)   # Compute model 75% quartile
   bar_width    <- c(0.8,0.6,0.3,0.1)
}

whisker_color <- "transparent"
if (inc_whiskers == 'y') {
   whisker_color <- plot_colors
}
box_ltype <- 0
bar_colors <- "transparent"
if (inc_ranges == 'y') {
   box_ltype <- 1
   bar_colors <- plot_colors
}

### Set up axes so that they will be big enough for both data species  that will be added ###
num.groups <- length(unique(aqdat.df$ob_hour))					# Count the number of sites used in each month
y.axis.min <- min(c(q1.spec1,q1.spec2,q1.spec3,q1.spec4))				# Set y-axis minimum values
y.axis.max.value <- max(c(q3.spec1,q3.spec2,q3.spec3,q3.spec4))			# Determine y-axis maximum value
if (inc_whiskers == 'y') {
   y.axis.min <- min(c(aqdat.df$Obs_Value,aqdat.df$Mod_Value))                              # Set y-axis minimum values
   y.axis.max.value <- max(c(aqdat.df$Obs_Value,aqdat.df$Mod_Value))                        # Determine y-axis maximum value
   if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
      y.axis.min <- min(c(y.axis.min,aqdat.df$Mod_Value,aqdat2.df$Mod_Value))                              # Set y-axis minimum values
      y.axis.max.value <- max(c(y.axis.max.value,aqdat2.df$Mod_Value))                        # Determine y-axis maximum value
   }
   if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
      y.axis.min <- min(c(y.axis.min,aqdat.df$Mod_Value,aqdat3.df$Mod_Value))                              # Set y-axis minimum values
      y.axis.max.value <- max(c(y.axis.max.value,aqdat3.df$Mod_Value))                        # Determine y-axis maximum value
   }
}
y.axis.max <- y.axis.max.value+(y.axis.max.value-y.axis.min)*.30
if (length(y_axis_max) > 0) {
      y.axis.max <- y_axis_max
}
if (length(y_axis_min) > 0) {
      y.axis.min <- y_axis_min
}
y.axis.min <- y.axis.min-.05*(y.axis.max-y.axis.min)	# pad the y-axis minimum slightly for obs count
#############################################################################################

########## MAKE PRIOR BOXPLOT ALL U.S. ##########
### To get a new graphics window (linux systems), use X11() ###
pdf(filename_pdf, width=8, height=8)						# Set output device with options

label 		<- paste(species,"(",units,")",sep=" ")
legend_names 	<- c(network_label[1], run_name1)
legend_fill 	<- c(bar_colors[1],bar_colors[2])
legend_colors 	<- c(plot_colors)
legend_type 	<- c(1,1)

par(mai=c(1,1,0.5,0.5))								# Set plot margins
boxplot(split(aqdat.df$Obs_Value, aqdat.df$ob_hour), range=0, border="black", whiskcol=whisker_color[1], staplecol=whisker_color[1], col=bar_colors[1], boxlty=box_ltype, boxwex=bar_width[1], ylim=c(y.axis.min, y.axis.max), xlab="Hour (LST)", ylab=label, cex.axis=1.3, cex.lab=1.3)	# Create boxplot

## Do the same thing for model values.  Use a different color for the background.
boxplot(split(aqdat.df$Mod_Value,aqdat.df$ob_hour), range=0, border="black", whiskcol=whisker_color[2], staplecol=whisker_color[2], col=bar_colors[2], boxlty=box_ltype, boxwex=bar_width[2], add=T, cex.axis=1.3, cex.lab=1.3)	# Plot model values on existing plot

if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   boxplot(split(aqdat2.df$Mod_Value,aqdat2.df$ob_hour), range=0, border="black", whiskcol=whisker_color[3], staplecol=whisker_color[3], col=bar_colors[3], boxlty=box_ltype, boxwex=bar_width[3], add=T, cex.axis=1.3, cex.lab=1.3)
   legend_names <- c(legend_names, run_name2)
   legend_fill <- c(legend_fill, bar_colors[3])
   legend_colors <- c(legend_colors,plot_colors[2])
   legend_type <- c(legend_type,1)
}

if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
   boxplot(split(aqdat3.df$Mod_Value,aqdat3.df$ob_hour), range=0, border="black", whiskcol=whisker_color[4], staplecol=whisker_color[4], col=bar_colors[4], boxlty=box_ltype, boxwex=bar_width[4], add=T, cex.axis=1.3, cex.lab=1.3)
   legend_names <- c(legend_names, run_name3)
   legend_fill <- c(legend_fill, bar_colors[4])
   legend_colors <- c(legend_colors,plot_colors[3])
   legend_type <- c(legend_type,1)
}

### Put title at top of boxplot ###
title(main=title)
###################################

### Place points, connected by lines, to denote where the medians are ###
x.loc <- 1:num.groups                                                                # Set number of median points to plot

if (inc_median_lines == 'y') {
   x.loc <- 1:num.groups								# Set number of median points to plot
   lines(x.loc, median.spec1)							# Connect median points with a line

   ### Run 1 Modeled Values ###								# As above, except for model values
   x.loc <- 1:num.groups
   lines(x.loc, median.spec2, lty=1, col=plot_colors[2])

   ### Run 2 Modeled Values ###
   if ((exists("run_name2")) && (nchar(run_name2) > 0)) {   
      x.loc <- 1:num.groups 
      lines(x.loc, median.spec3, lty=1, col=plot_colors[3])
   }

   ### Run 3 Modeled Values ###
   if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
      x.loc <- 1:num.groups
      lines(x.loc, median.spec4, lty=1, col=plot_colors[4])
   }
}
#########################################################################


raw_data.df <- data.frame(Hour_LST=seq(0,23,by=1),Obs_q1=q1.spec1,Obs_median=median.spec1,Obs_q3=q3.spec1,Mod_q1=q1.spec2,Mod_median=median.spec2,Mod_q3=q3.spec2)
if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   raw_data.df <- data.frame(Hour_LST=seq(0,23,by=1),Obs_q1=q1.spec1,Obs_median=median.spec1,Obs_q3=q3.spec1,Mod_q1=q1.spec2,Mod_median=median.spec2,Mod_q3=q3.spec2,Mod2_q1=q1.spec3,Mod2_median=median.spec3,Mod2_q3=q3.spec3)
}
if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
   raw_data.df <- data.frame(Hour_LST=seq(0,23,by=1),Obs_q1=q1.spec1,Obs_median=median.spec1,Obs_q3=q3.spec1,Mod_q1=q1.spec2,Mod_median=median.spec2,Mod_q3=q3.spec2,Mod2_q1=q1.spec3,Mod2_median=median.spec3,Mod2_q3=q3.spec3,Mod3_q1=q1.spec4,Mod3_median=median.spec4,Mod3_q3=q3.spec4)
}
write.table(raw_data.df,file=filename_txt,append=F,col.names=T,row.names=F,sep=",")                     # Write raw data to csv file

### Put legend on the plot ###
legend("topleft", legend_names, fill=legend_fill, lty=legend_type, col=legend_colors, merge=F, cex=.9, bty="n")
##############################

### Count number of samples per hour ###
nsamples.table <- table(aqdat.df$ob_hour)
#########################################

### Put text on plot ###
if (run_info_text == 'y') {
   if (rpo != 'None') {
      text(x=18,y=y.axis.max,paste("RPO: ",rpo,sep=""),cex=1.2,adj=c(0,0))
   }
   if (pca != 'None') {
      text(x=18,y=y.axis.max,paste("PCA: ",pca,sep=""),cex=1.2,adj=c(0,0))
   }
#   if (loc_setting != '') {
#      text(x=18,y=y.axis.max*0.95,paste("Loc_Setting: ",loc_setting,sep=""),cex=1.2,adj=c(0,0))
#   }
   text(x=18,y=y.axis.max*0.90,paste("Site: ",site,sep=""),cex=1.2,adj=c(0,0))
   if (state != "All") {
      text(x=18,y=y.axis.max*0.85,paste("State: ",state,sep=""),cex=1.2,adj=c(0,0))
   }
}

########################

### Put number of samples above each hour ###
text(x=1:24,y=y.axis.min,labels=nsamples.table,cex=1,srt=90)

### Convert pdf to png ###
dev.off()
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_pdf," png:",filename_png,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}
##########################
