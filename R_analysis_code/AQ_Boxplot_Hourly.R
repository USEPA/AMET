################################################################
### THIS FILE CONTAINS CODE TO DRAW A CUSTOMIZED HOURLY BOXPLOT DISPLAY.  It
### draws side-by-side boxplots for the various groups, without median value.
### This particular code uses hourly data to create a diurnal average curve 
### showing the data trend throughout the course of a 24-hr period.  The
### code is designed to use AQS ozone data, but can be used with any hourly
### data (SEARCH, TEOM, etc).  
###
### Last updated by Wyat Appel on April, 2017
################################################################

## get some environmental variables and setup some directories
ametbase<-Sys.getenv("AMETBASE")                        # base directory of AMET
dbase<-Sys.getenv("AMET_DATABASE")      # AMET database
ametR<-paste(ametbase,"/R_analysis_code",sep="")                    # R directory
ametRinput <- Sys.getenv("AMETRINPUT")                # input file for this script
ametptype <- Sys.getenv("AMET_PTYPE")    # Prefered output type

## Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
## and not specified via AMET_OUT, then set figdir to the current directory
if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")       }
if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"                 }

## source some configuration files, AMET libs, and input
source(paste(ametbase,"/configure/amet-config.R",sep=""))
source (paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file
source (ametRinput)                                     # Anaysis configuration/input file

## Load Required Libraries
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}

mysql           <- list(login=amet_login, passwd=amet_pass, server=mysql_server, dbase=dbase, maxrec=maxrec)             # Set MYSQL login and query options
con             <- dbConnect(MySQL(),user=amet_login,password=amet_pass,dbname=dbase,host=mysql_server)
MYSQL_tables    <- dbListTables(con)
dbDisconnect(con)

### Retrieve units label from database table ###
network <- network_names[1]
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql)
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
{
   if (custom_title == "") { title <- paste(run_name1,species,"for",dates,sep=" ") }
   else { title <- custom_title }
}
label <- paste(species,"(",units,")",sep=" ") 

#################################

criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name1,"' and COLUMN_NAME = 'POCode';",sep="")
query_table_info.df <-db_Query(check_POCode,mysql)
{
   if (length(query_table_info.df$COLUMN_NAME) == 0) {        # Check to see if POCode column exists or not 
      qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod from ",run_name1," as d, site_metadata as s",criteria," ORDER BY stat_id,ob_dates,ob_hour",sep="")      # Set the rest of the MYSQL query
      aqdat_query.df<-db_Query(qs,mysql)
      aqdat_query.df$POCode <- 1
   }
   else {
      qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, POCode from ",run_name1," as d, site_metadata as s",criteria," ORDER BY stat_id,ob_dates,ob_hour",sep="")      # Set the rest of the MYSQL query
      aqdat_query.df<-db_Query(qs,mysql)      # Query the database and store in aqdat.df dataframe
   }
}
aqdat_query.df$stat_id <- paste(aqdat_query.df$stat_id,aqdat_query.df$POCode,sep='')      # Create unique site using site ID and PO Code
if (remove_negatives == "y") {
   indic.nonzero <- aqdat_query.df[,9] >= 0          # determine which obs are missing (less than 0); 
   aqdat_query.df <- aqdat_query.df[indic.nonzero,]        # remove missing obs from dataframe
   indic.nonzero <- aqdat_query.df[,10] >= 0          # determine which obs are missing (less than 0); 
   aqdat_query.df <- aqdat_query.df[indic.nonzero,]        # remove missing obs from dataframe
}

check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name2,"' and COLUMN_NAME = 'POCode';",sep="")
query_table_info.df <-db_Query(check_POCode,mysql)
if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   {
      if (length(query_table_info.df$COLUMN_NAME) == 0) {        # Check to see if POCode column exists or not
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod from ",run_name2," as d, site_metadata as s",criteria," ORDER BY stat_id,ob_dates,ob_hour",sep="")      # Set the rest of the MYSQL query
         aqdat_query2.df<-db_Query(qs,mysql)
         aqdat_query2.df$POCode <- 1
      }
      else {
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, POCode from ",run_name2," as d, site_metadata as s",criteria," ORDER BY stat_id,ob_dates,ob_hour",sep="")      # Set the rest of the MYSQL query
         aqdat_query2.df<-db_Query(qs,mysql)      # Query the database and store in aqdat.df dataframe
      }
   }
   if (remove_negatives == "y") {
      indic.nonzero <- aqdat_query2.df[,9] >= 0			# determine which obs are missing (less than 0); 
      aqdat_query2.df <- aqdat_query2.df[indic.nonzero,]        # remove missing obs from dataframe
      indic.nonzero <- aqdat_query2.df[,10] >= 0		# determine which obs are missing (less than 0); 
      aqdat_query2.df <- aqdat_query2.df[indic.nonzero,]        # remove missing obs from dataframe
   }
   aqdat2.df <- aqdat_query2.df
}

check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name3,"' and COLUMN_NAME = 'POCode';",sep="")
query_table_info.df <-db_Query(check_POCode,mysql)

if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
   {
      if (length(query_table_info.df$COLUMN_NAME) == 0) {        # Check to see if POCode column exists or not
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod from ",run_name3," as d, site_metadata as s",criteria," ORDER BY stat_id,ob_dates,ob_hour",sep="")      # Set the rest of the MYSQL query
         aqdat_query3.df<-db_Query(qs,mysql)
         aqdat_query3.df$POCode <- 1
      }
      else {
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, POCode from ",network," as d, site_metadata as s",criteria," and proj_code = '",run_name3,"' ORDER BY stat_id,ob_dates,ob_hour",sep="")      # Set the rest of the MYSQL query
         aqdat_query3.df<-db_Query(qs,mysql)      # Query the database and store in aqdat.df dataframe
      }
   }
   if (remove_negatives == "y") {
      indic.nonzero <- aqdat_query3.df[,9] >= 0                 # determine which obs are missing (less than 0); 
      aqdat_query3.df <- aqdat_query3.df[indic.nonzero,]        # remove missing obs from dataframe
      indic.nonzero <- aqdat_query3.df[,10] >= 0                # determine which obs are missing (less than 0); 
      aqdat_query3.df <- aqdat_query3.df[indic.nonzero,]        # remove missing obs from dataframe
   }
   aqdat3.df <- aqdat_query3.df
}

#######################

aqdat.df <- aqdat_query.df

### Remove mean if requested ###
if (remove_mean == 'y') {
   aqdat_new.df 	<- NULL
   split_sites		<- split(aqdat_query.df,aqdat_query.df$stat_id)
   for (h in 1:(length(split_sites))) {
      sub.df 		<- split_sites[[h]]
      mean_obs          <- mean(sub.df[,9])
      mean_mod1         <- mean(sub.df[,10])
      sub.df[,9]	<- sub.df[,9]-mean_obs
      sub.df[,10]       <- sub.df[,10]-mean_mod1
      aqdat_new.df	<- rbind(aqdat_new.df,sub.df)
   }
   aqdat.df <- aqdat_new.df
   if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
      aqdat_new2.df         <- NULL
      split_sites2          <- split(aqdat_query2.df,aqdat_query2.df$stat_id)
      for (h in 1:(length(split_sites2))) {
         sub.df            <- split_sites2[[h]]
         mean_obs          <- mean(sub2.df[,9])
         mean_mod2         <- mean(sub2.df[,10])
         sub.df[,9]        <- sub2.df[,9]-mean_obs
         sub.df[,10]       <- sub2.df[,10]-mean_mod2
         aqdat_new2.df      <- rbind(aqdat_new2.df,sub2.df)
      }
      aqdat2.df <- aqdat_new2.df
   }
   if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
      aqdat_new3.df         <- NULL
      split_sites3          <- split(aqdat_query3.df,aqdat_query3.df$stat_id)
      for (h in 1:(length(split_sites3))) {
         sub.df            <- split_sites3[[h]]
         mean_obs          <- mean(sub3.df[,9])
         mean_mod2         <- mean(sub3.df[,10])
         sub.df[,9]        <- sub3.df[,9]-mean_obs
         sub.df[,10]       <- sub3.df[,10]-mean_mod3
         aqdat_new3.df      <- rbind(aqdat_new3.df,sub3.df)
      }
      aqdat3.df <- aqdat_new3.df
   }
}
#################################

### Find q1, median, q2 for each group of both species ###
q1.spec1 <- tapply(aqdat.df[,9], aqdat.df$ob_hour, quantile, 0.25, na.rm=T)	# Compute ob 25% quartile
q1.spec2 <- tapply(aqdat.df[,10], aqdat.df$ob_hour, quantile, 0.25, na.rm=T)	# Compute model 25% quartile
median.spec1 <- tapply(aqdat.df[,9], aqdat.df$ob_hour, median, na.rm=T)		# Compute ob median value
median.spec2 <- tapply(aqdat.df[,10], aqdat.df$ob_hour, median, na.rm=T)	# Compute model median value
q3.spec1 <- tapply(aqdat.df[,9], aqdat.df$ob_hour, quantile, 0.75, na.rm=T)	# Compute ob 75% quartile
q3.spec2 <- tapply(aqdat.df[,10], aqdat.df$ob_hour, quantile, 0.75, na.rm=T)	# Compute model 75% quartile
################################################

q1.spec3     <- NULL
median.spec3 <- NULL
q3.spec3     <- NULL
bar_colors   <- plot_colors
bar_width    <- c(0.8,0.4)

if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   q1.spec3     <- tapply(aqdat2.df[,10], aqdat2.df$ob_hour, quantile, 0.25, na.rm=T)	# Compute model 25% quartile
   median.spec3 <- tapply(aqdat2.df[,10], aqdat2.df$ob_hour, median, na.rm=T)		# Compute model median value
   q3.spec3     <- tapply(aqdat2.df[,10], aqdat2.df$ob_hour, quantile, 0.75, na.rm=T)	# Compute model 75% quartile
   bar_colors   <- plot_colors
   bar_width    <- c(0.8,0.5,0.2)
}

if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
   q1.spec4     <- tapply(aqdat3.df[,10], aqdat3.df$ob_hour, quantile, 0.25, na.rm=T)   # Compute model 25% quartile
   median.spec4 <- tapply(aqdat3.df[,10], aqdat3.df$ob_hour, median, na.rm=T)           # Compute model median value
   q3.spec4     <- tapply(aqdat3.df[,10], aqdat3.df$ob_hour, quantile, 0.75, na.rm=T)   # Compute model 75% quartile
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
y.axis.min <- min(c(q1.spec1, q1.spec2, q1.spec3))				# Set y-axis minimum values
y.axis.max.value <- max(c(q3.spec1, q3.spec2, q3.spec3))			# Determine y-axis maximum value
if (inc_whiskers == 'y') {
   y.axis.min <- min(c(aqdat.df[,9],aqdat.df[,10],aqdat2.df[,10],aqdat3.df[,10]))                              # Set y-axis minimum values
   y.axis.max.value <- max(c(aqdat.df[,9],aqdat.df[,10],aqdat2.df[,10],aqdat3.df[,10]))                        # Determine y-axis maximum value
}
y.axis.max <- c(sum((y.axis.max.value * 0.3),y.axis.max.value))			# Add 30% of the y-axis maximum value to the y-axis maximum value
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

legend_names <- c(network_label[1], run_name1)
legend_fill <- c(bar_colors[1],bar_colors[2])
legend_colors <- c(plot_colors)
legend_type <- c(1,1)

par(mai=c(1,1,0.5,0.5))								# Set plot margins
boxplot(split(aqdat.df[,9], aqdat.df$ob_hour), range=0, border="black", whiskcol=whisker_color[1], staplecol=whisker_color[1], col=bar_colors[1], boxlty=box_ltype, boxwex=bar_width[1], ylim=c(y.axis.min, y.axis.max), xlab="Hour (LST)", ylab=label, cex.axis=1.3, cex.lab=1.3)	# Create boxplot

## Do the same thing for model values.  Use a different color for the background.
boxplot(split(aqdat.df[,10],aqdat.df$ob_hour), range=0, border="black", whiskcol=whisker_color[2], staplecol=whisker_color[2], col=bar_colors[2], boxlty=box_ltype, boxwex=bar_width[2], add=T, cex.axis=1.3, cex.lab=1.3)	# Plot model values on existing plot

if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   boxplot(split(aqdat2.df[,10],aqdat2.df$ob_hour), range=0, border="black", whiskcol=whisker_color[3], staplecol=whisker_color[3], col=bar_colors[3], boxlty=box_ltype, boxwex=bar_width[3], add=T, cex.axis=1.3, cex.lab=1.3)
   legend_names <- c(legend_names, run_name2)
   legend_fill <- c(legend_fill, bar_colors[3])
   legend_colors <- c(legend_colors,plot_colors[2])
   legend_type <- c(legend_type,1)
}

if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
   boxplot(split(aqdat3.df[,10],aqdat3.df$ob_hour), range=0, border="black", whiskcol=whisker_color[4], staplecol=whisker_color[4], col=bar_colors[4], boxlty=box_ltype, boxwex=bar_width[4], add=T, cex.axis=1.3, cex.lab=1.3)
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

{
   if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
      raw_data.df <- data.frame(Median_Obs=median.spec1,Median_Mod=median.spec2,Median_Mod2=median.spec3)
   }
   if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
      raw_data.df <- data.frame(Median_Obs=median.spec1,Median_Mod=median.spec2,Median_Mod2=median.spec3,Median_Mod3=median.spec4)
   }
   else {
      raw_data.df <- data.frame(Median_Obs=median.spec1,Median_Mod=median.spec2)
   }
}
write.table(raw_data.df,file=filename_txt,append=T,row.names=F,sep=",")                     # Write raw data to csv file

### Put legend on the plot ###
legend(x=1.0, y=y.axis.max, legend_names, fill=legend_fill, lty=legend_type, col=legend_colors, merge=F, cex=1)
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
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density 150x150 ",filename_pdf," png:",filename_png,sep="")
   dev.off()
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}
##########################
