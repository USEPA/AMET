################################################################
### AMET CODE: BOX PLOT
###
### This script is part of the AMET-AQ system.  It plots a box plots
### without whiskers.  The script is designed to create three box plot,
### one for the raw data, one for bias, and one for normalizaed bias.
### Individual observation/model pairs are provided through a MYSQL query, 
### from which the script computes the 25% and 75% quartiles, as well \
### as the median values for both obs and model values.  The script 
### then plots these values as a box plot.
###
### Last updated by Wyat Appel; December 6, 2012
###
### Modified to work with combined MET/AQ mode, Alexis Zubrow (IE UNC) Nov, 2007
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
if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")	}
if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"			}

## source some configuration files, AMET libs, and input
source(paste(ametbase,"/configure/amet-config.R",sep=""))
source (paste(ametR,"/AQ_Misc_Functions.R",sep=""))  	# Miscellanous AMET R-functions file
source (ametRinput)	                                # Anaysis configuration/input file
source (ametNetworkInput) # Network related input

## Load Required Libraries
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}

mysql <- list(login=login, passwd=passwd, server=server, dbase=dbase, maxrec=maxrec)		# Set MYSQL login and query options


### Retrieve units label from database table ###
network <- network_names[1] 
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql) 
################################################

### Set file names and titles ###
label <- paste(species," (",units,")",sep="")
network<-network_names[[1]]
outname_pdf  <- paste(run_name1,species,"boxplot.pdf",sep="_")
outname_png  <- paste(run_name1,species,"boxplot.png",sep="_")
outname_bias_pdf  <- paste(run_name1,species,"boxplot_bias.pdf",sep="_")
outname_bias_png  <- paste(run_name1,species,"boxplot_bias.png",sep="_")
outname_norm_bias_pdf  <- paste(run_name1,species,"boxplot_norm_bias.pdf",sep="_")
outname_norm_bias_png  <- paste(run_name1,species,"boxplot_norm_bias.png",sep="_")

{
   if (custom_title == "") { title <- paste(run_name1,species,"for",network_label[1],"for",start_date,end_date,sep=" ") }
   else { title <- custom_title }
}

## Create a full path to file
outname_pdf 		<- paste(figdir,outname_pdf,sep="/")
outname_png 		<- paste(figdir,outname_png,sep="/")
outname_bias_pdf 	<- paste(figdir,outname_bias_pdf,sep="/")
outname_bias_png 	<- paste(figdir,outname_bias_png,sep="/")
outname_norm_bias_pdf 	<- paste(figdir,outname_norm_bias_pdf,sep="/")
outname_norm_bias_png 	<- paste(figdir,outname_norm_bias_png,sep="/")

#################################

query <- paste(" and s.stat_id=d.stat_id and d.ob_dates BETWEEN",start_date,"and",end_date,"and d.ob_datee BETWEEN",start_date,"and",end_date,"and ob_hour between",start_hour,"and",end_hour,add_query,sep=" ")
criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"'",query,sep="")			# Set first part of the MYSQL query

qs <- paste("SELECT d.network,d.stat_id,s.lat,s.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name1," as d, site_metadata as s",criteria," ORDER BY stat_id,ob_dates,ob_hour",sep="")      # Set the rest of the MYSQL query

aqdat_query.df<-db_Query(qs,mysql)
years   <- substr(aqdat_query.df$ob_dates,1,4)
months  <- substr(aqdat_query.df$ob_dates,6,7)
yearmonth <- paste(years,months,sep="_")
aqdat_query.df$Year <- years 
aqdat_query.df$YearMonth <- yearmonth

if (run_name2 != "empty") {
   qs2 <- paste("SELECT d.network,d.stat_id,s.lat,s.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name2," as d, site_metadata as s",criteria," ORDER BY stat_id,ob_dates,ob_hour",sep="")      # Set the rest of the MYSQL query
   aqdat_query2.df<-db_Query(qs2,mysql)
   years2   <- substr(aqdat_query2.df$ob_dates,1,4)
   months2  <- substr(aqdat_query2.df$ob_dates,6,7)
   yearmonth2 <- paste(years2,months2,sep="_") 
   aqdat_query2.df$Year <- years2
   aqdat_query2.df$YearMonth <- yearmonth2
}
   
if (run_name3 != "empty") {
   qs3 <- paste("SELECT d.network,d.stat_id,s.lat,s.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name3," as d, site_metadata as s",criteria," ORDER BY stat_id,ob_dates,ob_hour",sep="")      # Set the rest of the MYSQL query
   aqdat_query3.df<-db_Query(qs3,mysql)
   years3   <- substr(aqdat_query3.df$ob_dates,1,4)
   months3  <- substr(aqdat_query3.df$ob_dates,6,7)
   yearmonth3 <- paste(years3,months3,sep="_")
   aqdat_query3.df$Year <- years3
   aqdat_query3.df$YearMonth <- yearmonth3
}

total_days <- as.numeric(max(as.Date(aqdat_query.df$ob_datee))-min(as.Date(aqdat_query.df$ob_dates)))   # Calculate the total length, in days, of the period being plotted
x.axis.min <- min(aqdat_query.df$month) # Find the first month available from the query

{
if (averaging == "m") { averaging <- "ym" }
if (averaging == "ym") {
   aqdat_in.df <- data.frame(Network=aqdat_query.df$network,Stat_ID=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=round(aqdat_query.df[,9],5),Mod_Value=round(aqdat_query.df[,10],5),Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month,precip_ob=aqdat_query.df$precip_ob,precip_mod=aqdat_query.df$precip_mod,Split_On=aqdat_query.df$YearMonth)
   aqdat.df <- Average(aqdat_in.df)
   if (run_name2 != "empty") {
      aqdat_in2.df <- data.frame(Network=aqdat_query2.df$network,Stat_ID=aqdat_query2.df$stat_id,lat=aqdat_query2.df$lat,lon=aqdat_query2.df$lon,Obs_Value=round(aqdat_query2.df[,9],5),Mod_Value=round(aqdat_query2.df[,10],5),Hour=aqdat_query2.df$ob_hour,Start_Date=aqdat_query2.df$ob_dates,Month=aqdat_query2.df$month,precip_ob=aqdat_query2.df$precip_ob,precip_mod=aqdat_query2.df$precip_mod,Split_On=aqdat_query2.df$YearMonth)
   aqdat2.df <- Average(aqdat_in2.df)
   }
   if (run_name3 != "empty") {
      aqdat_in3.df <- data.frame(Network=aqdat_query3.df$network,Stat_ID=aqdat_query3.df$stat_id,lat=aqdat_query3.df$lat,lon=aqdat_query3.df$lon,Obs_Value=round(aqdat_query3.df[,9],5),Mod_Value=round(aqdat_query3.df[,10],5),Hour=aqdat_query3.df$ob_hour,Start_Date=aqdat_query3.df$ob_dates,Month=aqdat_query3.df$month,precip_ob=aqdat_query3.df$precip_ob,precip_mod=aqdat_query3.df$precip_mod,Split_On=aqdat_query3.df$YearMonth)
   aqdat3.df <- Average(aqdat_in3.df)
   }
}
else if (total_days <= 31) {    # If only plotting one month, plot all times instead of averaging to a single month
   indic.nonzero <- aqdat_query.df[,9] >= 0
   aqdat_query.df   <- aqdat_query.df[indic.nonzero,]
   indic.nonzero <- aqdat_query.df[,10] >= 0
   aqdat_query.df   <- aqdat_query.df[indic.nonzero,]
   aqdat.df <- data.frame(network=aqdat_query.df$network,stat_id=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,ob_dates=aqdat_query.df$ob_dates,Obs_Value=aqdat_query.df[,9],Mod_Value=aqdat_query.df[,10],Month=aqdat_query.df$month,Split_On=aqdat_query.df$ob_dates)
   if (run_name2 != "empty") {
      indic.nonzero <- aqdat_query2.df[,9] >= 0
      aqdat_query2.df   <- aqdat_query2.df[indic.nonzero,]
      indic.nonzero <- aqdat_query2.df[,10] >= 0
      aqdat_query2.df   <- aqdat_query2.df[indic.nonzero,]
      aqdat2.df <- data.frame(network=aqdat_query2.df$network,stat_id=aqdat_query2.df$stat_id,lat=aqdat_query2.df$lat,lon=aqdat_query2.df$lon,ob_dates=aqdat_query2.df$ob_dates,Obs_Value=aqdat_query2.df[,9],Mod_Value=aqdat_query2.df[,10],Month=aqdat_query2.df$month,Split_On=aqdat_query2.df$ob_dates)
   }
   if (run_name3 != "empty") {
      indic.nonzero <- aqdat_query3.df[,9] >= 0
      aqdat_query3.df   <- aqdat_query3.df[indic.nonzero,]
      indic.nonzero <- aqdat_query3.df[,10] >= 0
      aqdat_query3.df   <- aqdat_query3.df[indic.nonzero,]
      aqdat3.df <- data.frame(network=aqdat_query3.df$network,stat_id=aqdat_query3.df$stat_id,lat=aqdat_query3.df$lat,lon=aqdat_query3.df$lon,ob_dates=aqdat_query3.df$ob_dates,Obs_Value=aqdat_query3.df[,9],Mod_Value=aqdat_query3.df[,10],Month=aqdat_query3.df$month,Split_On=aqdat_query3.df$ob_dates)
   }
}
else {
   indic.nonzero <- aqdat_query.df[,9] >= 0
   aqdat_query.df   <- aqdat_query.df[indic.nonzero,]
   indic.nonzero <- aqdat_query.df[,10] >= 0
   aqdat_query.df   <- aqdat_query.df[indic.nonzero,]
   aqdat.df <- data.frame(network=aqdat_query.df$network,stat_id=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,ob_dates=aqdat_query.df$ob_dates,Obs_Value=aqdat_query.df[,9],Mod_Value=aqdat_query.df[,10],Month=aqdat_query.df$month,Split_On=aqdat_query.df$YearMonth)
   if (run_name2 != "empty") {
      indic.nonzero <- aqdat_query2.df[,9] >= 0
      aqdat_query2.df   <- aqdat_query2.df[indic.nonzero,]
      indic.nonzero <- aqdat_query2.df[,10] >= 0
      aqdat_query2.df   <- aqdat_query2.df[indic.nonzero,]
      aqdat2.df <- data.frame(network=aqdat_query2.df$network,stat_id=aqdat_query2.df$stat_id,lat=aqdat_query2.df$lat,lon=aqdat_query2.df$lon,ob_dates=aqdat_query2.df$ob_dates,Obs_Value=aqdat_query2.df[,9],Mod_Value=aqdat_query2.df[,10],Month=aqdat_query2.df$month,Split_On=aqdat_query2.df$YearMonth)
   }
   if (run_name3 != "empty") {
      indic.nonzero <- aqdat_query3.df[,9] >= 0
      aqdat_query3.df   <- aqdat_query3.df[indic.nonzero,]
      indic.nonzero <- aqdat_query3.df[,10] >= 0
      aqdat_query3.df   <- aqdat_query3.df[indic.nonzero,]
      aqdat3.df <- data.frame(network=aqdat_query3.df$network,stat_id=aqdat_query3.df$stat_id,lat=aqdat_query3.df$lat,lon=aqdat_query3.df$lon,ob_dates=aqdat_query3.df$ob_dates,Obs_Value=aqdat_query3.df[,9],Mod_Value=aqdat_query3.df[,10],Month=aqdat_query3.df$month,Split_On=aqdat_query3.df$YearMonth)
   }
}
}
Bias                    <- aqdat.df$Mod_Value-aqdat.df$Obs_Value
Norm_Bias               <- ((aqdat.df$Mod_Value-aqdat.df$Obs_Value)/aqdat.df$Obs_Value)*100
aqdat.df$Bias           <- Bias
aqdat.df$Norm_Bias      <- Norm_Bias

if (run_name2 != "empty") {
   Bias2                    <- aqdat2.df$Mod_Value-aqdat2.df$Obs_Value
   Norm_Bias2               <- ((aqdat2.df$Mod_Value-aqdat2.df$Obs_Value)/aqdat2.df$Obs_Value)*100
   aqdat2.df$Bias           <- Bias2
   aqdat2.df$Norm_Bias      <- Norm_Bias2
}
if (run_name3 != "empty") {
   Bias3                    <- aqdat3.df$Mod_Value-aqdat3.df$Obs_Value
   Norm_Bias3               <- ((aqdat3.df$Mod_Value-aqdat3.df$Obs_Value)/aqdat3.df$Obs_Value)*100
   aqdat3.df$Bias           <- Bias3
   aqdat3.df$Norm_Bias      <- Norm_Bias3
}

## test that the query worked
if (length(aqdat.df) == 0){
  ## error the queried returned nothing
  writeLines("ERROR: Check species/network pairing and Obs start and end dates")
  stop(paste("ERROR querying db: \n",qs))
}

### Find q1, median, q2 for each group of both species ###
obs.stats       <- boxplot(split(aqdat.df$Obs_Value, aqdat.df$Split_On), plot=F)
mod.stats       <- boxplot(split(aqdat.df$Mod_Value, aqdat.df$Split_On), plot=F)
bias.stats      <- boxplot(split(aqdat.df$Bias, aqdat.df$Split_On), plot=F)
norm_bias.stats <- boxplot(split(aqdat.df$Norm_Bias, aqdat.df$Split_On), plot=F)

### Isolate the medians from the boxplot stats.
median.spec1            <- obs.stats$stats[3,]
median.spec2            <- mod.stats$stats[3,]
median.bias             <- bias.stats$stats[3,]
median.norm_bias        <- norm_bias.stats$stats[3,]

### Isolate the 3rd quartile (top of the boxplot's box).
q3.spec1        <- obs.stats$stats[4,]
q3.spec2        <- mod.stats$stats[4,]
q3.bias         <- bias.stats$stats[4,]
q1.bias         <- bias.stats$stats[2,]
q3.norm_bias    <- norm_bias.stats$stats[4,]
q1.norm_bias    <- norm_bias.stats$stats[2,]

bar_width	<- c(0.8,0.5)

if (run_name2 != "empty") {
   ### Find q1, median, q2 for each group of both species ###
   obs.stats2       <- boxplot(split(aqdat2.df$Obs_Value, aqdat2.df$Split_On), plot=F)
   mod.stats2       <- boxplot(split(aqdat2.df$Mod_Value, aqdat2.df$Split_On), plot=F)
   bias.stats2      <- boxplot(split(aqdat2.df$Bias, aqdat2.df$Split_On), plot=F)
   norm_bias.stats2 <- boxplot(split(aqdat2.df$Norm_Bias, aqdat2.df$Split_On), plot=F)

   ### Isolate the medians from the boxplot stats.
   median.spec1_2           <- obs.stats2$stats[3,]
   median.spec2_2           <- mod.stats2$stats[3,]
   median.bias2             <- bias.stats2$stats[3,]
   median.norm_bias2        <- norm_bias.stats2$stats[3,]

   ### Isolate the 3rd quartile (top of the boxplot's box).
   q3.spec1_2       <- obs.stats2$stats[4,]
   q3.spec2_2       <- mod.stats2$stats[4,]
   q3.bias2         <- bias.stats2$stats[4,]
   q1.bias2         <- bias.stats2$stats[2,]
   q3.norm_bias2    <- norm_bias.stats2$stats[4,]
   q1.norm_bias2    <- norm_bias.stats2$stats[2,]

   bar_width		<- c(0.8,0.5,0.2)
}

if (run_name3 != "empty") {
   ### Find q1, median, q2 for each group of both species ###
   obs.stats3       <- boxplot(split(aqdat3.df$Obs_Value, aqdat3.df$Split_On), plot=F)
   mod.stats3       <- boxplot(split(aqdat3.df$Mod_Value, aqdat3.df$Split_On), plot=F)
   bias.stats3      <- boxplot(split(aqdat3.df$Bias, aqdat3.df$Split_On), plot=F)
   norm_bias.stats3 <- boxplot(split(aqdat3.df$Norm_Bias, aqdat3.df$Split_On), plot=F)

   ### Isolate the medians from the boxplot stats.
   median.spec1_3           <- obs.stats3$stats[3,]
   median.spec2_3           <- mod.stats3$stats[3,]
   median.bias3             <- bias.stats3$stats[3,]
   median.norm_bias3        <- norm_bias.stats3$stats[3,]

   ### Isolate the 3rd quartile (top of the boxplot's box).
   q3.spec1_3       <- obs.stats3$stats[4,]
   q3.spec2_3       <- mod.stats3$stats[4,]
   q3.bias3         <- bias.stats3$stats[4,]
   q1.bias3         <- bias.stats3$stats[2,]
   q3.norm_bias3    <- norm_bias.stats3$stats[4,]
   q1.norm_bias3    <- norm_bias.stats3$stats[2,]

   bar_width    	<- c(0.8,0.6,0.3,0.1)
}

###################
### Set up axes ###
###################
num.groups <- length(unique(aqdat.df$Split_On))
#num.groups <- length(unique(aqdat.df$ob_dates))

y.axis.min <- min(c(0,0))                                               # Set y-axis minimum
if (length(y_axis_min) > 0) {
   y.axis.min <- y_axis_min
}
y.axis.max.value <- max(c(q3.spec1, q3.spec2))                          # Determine y-axis maximum
y.axis.max <- c(sum((y.axis.max.value * 0.3),y.axis.max.value))         # Set y-axis maximum based on value above (adjusted by 30%)
if (inc_whiskers == "y") {
   y.axis.max.value <- max(aqdat.df$Obs_Value,aqdat.df$Mod_Value)
   y.axis.max <- c(sum((y.axis.max.value * 0.15),y.axis.max.value))         # Set y-axis maximum based on value above (adjusted by 30%)
}
if (length(y_axis_max) > 0) {                                   # Set user defined y axis limit
   y.axis.max <- y_axis_max                                             # Set y-axis max based on user input
}
bias.y.axis.min <- min(q1.bias)
bias.y.axis.max.value <- max(q3.bias)
bias.y.axis.max <- c(sum((bias.y.axis.max.value * 0.3),bias.y.axis.max.value))
if (inc_whiskers == "y") {
   bias.y.axis.min <- min(aqdat.df$Bias)
   bias.y.axis.max.value <- max(aqdat.df$Bias)
   bias.y.axis.max <- c(sum((bias.y.axis.max.value * 0.15),bias.y.axis.max.value))
}

norm_bias.y.axis.min <- min(q1.norm_bias)
norm_bias.y.axis.max.value <- max(q3.norm_bias)
norm_bias.y.axis.max <- c(sum((norm_bias.y.axis.max.value * 0.3),norm_bias.y.axis.max.value))
if (inc_whiskers == "y") {
   norm_bias.y.axis.min <- min(aqdat.df$Norm_Bias)
   norm_bias.y.axis.max.value <- max(aqdat.df$Norm_Bias)
   norm_bias.y.axis.max <- c(sum((norm_bias.y.axis.max.value * 0.15),norm_bias.y.axis.max.value))
}
###################

##########################################
####### MAKE BOXPLOT: Entire Domain ######
##########################################

pdf(file=outname_pdf, width=8, height=8)
par(mai=c(1,1,0.5,0.5),las=1)

legend_names <- c(network_label[1], run_name1)
legend_fill <- c(bar_colors[1],bar_colors[2])
legend_colors <- c(line_colors[1],line_colors[2])
legend_type <- c(1,2,3,4)
if (inc_whiskers == "n") {
   whisker_colors <- c("transparent","transparent","transparent","transparent")
}
### User option to remove boxes and only plot median lines ###
if (inc_ranges == "y") {
   boxplot(split(aqdat.df$Obs_Value, aqdat.df$Split_On), range=0, border=whisker_colors[1], col=bar_colors[1], boxwex=bar_width[1], ylim=c(y.axis.min, y.axis.max), xlab="Months", ylab=label, cex.axis=1.0, cex.lab=1.3)
   boxplot(split(aqdat.df$Mod_Value,aqdat.df$Split_On), range=0, border=whisker_colors[2], col=bar_colors[2], boxwex=bar_width[2], add=T, cex.axis=1.0, cex.lab=1.3)
}
if (run_name2 != "empty") {
    boxplot(split(aqdat2.df$Mod_Value,aqdat2.df$Split_On), range=0, border=whisker_colors[3], col=bar_colors[3], boxwex=bar_width[3], add=T, cex.axis=1.0, cex.lab=1.3)
   legend_names <- c(legend_names, run_name2)
   legend_fill <- c(legend_fill, bar_colors[3])
   legend_colors <- c(legend_colors,line_colors[2])
   legend_type <- c(legend_type,3)
}
if (run_name3 != "empty") {
    boxplot(split(aqdat3.df$Mod_Value,aqdat3.df$Split_On), range=0, border=whisker_colors[4], col=bar_colors[4], boxwex=bar_width[4], add=T, cex.axis=1.0, cex.lab=1.3)
   legend_names <- c(legend_names, run_name2)
   legend_fill <- c(legend_fill, bar_colors[4])
   legend_colors <- c(legend_colors,line_colors[3])
   legend_type <- c(legend_type,4)
}
###############################################################

### Put title at top of boxplot ###
title(main=title)

### Count number of samples per month ###
nsamples.table <- obs.stats$n

num_months <- length(nsamples.table)

### Put number of samples above each month ###
{
   if ((inc_ranges == "y") && (total_days <= 731)) {  # If plotting multiple years, add vertical lines and year name to denote each year
      text(x=1:num_months,y=(y.axis.min-((y.axis.max-y.axis.min)*.02)),labels=nsamples.table,cex=0.75)
   }
   else {
      year_mark<-seq(13,num_months,by=12)       # Do not plot number of obs if plotting more than a year
      text(x=seq(7,num_months,by=12),y=y.axis.min,labels=unique(years))
      abline(v=year_mark,col="gray40",lty=1)
   }
}
###################################

### Place points, connected by lines, to denote where the medians are ###
x.loc <- 1:num.groups
points(x.loc, pch=0, median.spec1, col=line_colors[1])                                              # Add points for obs median values
lines(x.loc, median.spec1, col=line_colors[1])                                                      # Connect median points with a line
x.loc <- 1:num.groups
points(x.loc, median.spec2, pch=2, col=line_colors[2])                                  # Add points for model median values
lines(x.loc, median.spec2, lty=2, col=line_colors[2])                                   # Connect median points with a line

if (run_name2 != "empty") {
   x.loc <- 1:num.groups
   points(x.loc, median.spec2_2, pch=3, col=line_colors[3])                                  # Add points for model median values
   lines(x.loc, median.spec2_2, lty=3, col=line_colors[3])                                   # Connect median points with a line
}
if (run_name3 != "empty") {
   x.loc <- 1:num.groups
   points(x.loc, median.spec2_3, pch=4, col=line_colors[4])                                  # Add points for model median values
   lines(x.loc, median.spec2_3, lty=4, col=line_colors[4])                                   # Connect median points with a line
}


### Put legend on the plot ###
legend("topleft", legend_names, fill=legend_fill, lty=legend_type, col=legend_colors, merge=F, cex=1)
##############################

### Put text stating coverage limit used ###
if (averaging == "m") {
   text(x.axis.min,y.axis.max*.96,paste("Coverage Limit = ",coverage_limit,"%",sep=""),cex=0.75,adj=c(0,.5))
}
if (run_info_text == "y") {
   if (rpo != "None") {
      text(0,y.axis.max*.93,paste("RPO = ",rpo,sep=""),adj=c(0,.5),cex=.9)
   }
   if (site != "All") {
      text(0,y.axis.max*.87,paste("Site = ",site,sep=""),adj=c(0,.5),cex=.9)
   }
   if (state != "All") {
      text(0,y.axis.max*.84,paste("State = ",state,sep=""),adj=c(0,.5),cex=.9)
   }
}
############################################


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
#############################################

###############################################
####### MAKE Bias BOXPLOT: Entire Domain ######
###############################################

legend_names <- c(run_name1)
legend_fill <- c(bar_colors[1])
legend_colors <- c("black")
legend_type <- c(1)

pdf(file=outname_bias_pdf, width=8, height=8)
par(mai=c(1,1,0.5,0.5),las=1)
label <- paste("Bias (",units,")",sep="")
### User option to remove boxes and only plot median lines ###
{
   if (inc_ranges == "y") {
      boxplot(split(aqdat.df$Bias, aqdat.df$Split_On), range=0, border=whisker_colors[1], col=bar_colors[1], boxwex=bar_width[1], ylim=c(bias.y.axis.min, bias.y.axis.max), xlab="Date", ylab=label, cex.axis=1.0, cex.lab=1.3)
      if (run_name2 != "empty") {
         boxplot(split(aqdat2.df$Bias, aqdat2.df$Split_On), range=0, border=whisker_colors[2], col=bar_colors[2], boxwex=bar_width[2], ylim=c(bias.y.axis.min, bias.y.axis.max), xlab="Date", ylab=label, cex.axis=1.0, cex.lab=1.3, add=T)
         legend_names <- c(legend_names, run_name2)
         legend_fill <- c(bar_colors[1],bar_colors[2])
         legend_colors <- c(legend_colors,line_colors[1])
         legend_type <- c(1,2)
      }
      if (run_name3 != "empty") {
         boxplot(split(aqdat3.df$Bias, aqdat3.df$Split_On), range=0, border=whisker_colors[3], col=bar_colors[3], boxwex=bar_width[3], ylim=c(bias.y.axis.min, bias.y.axis.max), xlab="Date", ylab=label, cex.axis=1.0, cex.lab=1.3, add=T)
         legend_names <- c(legend_names, run_name3)
         legend_fill <- c(legend_fill, bar_colors[3])
         legend_colors <- c(legend_colors ,line_colors[2])
         legend_type <- c(1,2,3)
      }
   }
   else {
      boxplot(split(aqdat.df$Bias, aqdat.df$Split_On), range=0, border=whisker_colors[1], col=bar_colors[1], boxwex=bar_width[1], ylim=c(bias.y.axis.min, bias.y.axis.max), xlab="Date", ylab=label, cex.axis=1.0, cex.lab=1.3)
      if (run_name2 != "empty") {
         boxplot(split(aqdat2.df$Bias, aqdat2.df$Split_On), range=0, border=whisker_colors[2], col=bar_colors[2], boxwex=bar_width[2], ylim=c(bias.y.axis.min, bias.y.axis.max), xlab="Date", ylab=label, cex.axis=1.0, cex.lab=1.3, add=T)
         legend_names <- c(run_name1, run_name2)
         legend_fill <- c(bar_colors[1],bar_colors[2])
         legend_colors <- c(legend_colors,line_colors[1])
         legend_type <- c(1,2)
      }
      if (run_name3 != "empty") {
         boxplot(split(aqdat3.df$Bias, aqdat3.df$Split_On), range=0, border=whisker_colors[3], col=bar_colors[3], boxwex=bar_width[3], ylim=c(bias.y.axis.min, bias.y.axis.max), xlab="Date", ylab=label, cex.axis=1.0, cex.lab=1.3, add=T)
         legend_names <- c(legend_names, run_name3)
         legend_fill <- c(legend_fill, bar_colors[3])
         legend_colors <- c(legend_colors ,line_colors[2])
         legend_type <- c(1,2,3)
      }
   }
}
###############################################################

### Put title at top of boxplot ###
title(main=title)
###################################

### Place points, connected by lines, to denote where the medians are ###
x.loc <- 1:num.groups
points(x.loc, pch=0, median.bias,col="black")                                              # Add points for obs median values
lines(x.loc, median.bias, col="black", lty=1)                                                      # Connect median points with a line
abline(h=0)

if (run_name2 != "empty") {
   points(x.loc, pch=0, median.bias2, col=line_colors[1])                                              # Add points for obs median values
   lines(x.loc, median.bias2, col=line_colors[1], lty=2)
}
if (run_name3 != "empty") {
   points(x.loc, pch=0, median.bias3, col=line_colors[2])                                              # Add points for obs median values
   lines(x.loc, median.bias3, col=line_colors[2], lty=3)
}


### Put legend on the plot ###
legend("topleft",legend_names,fill=legend_fill,lty=legend_type,col=legend_colors,merge=F,cex=1,bty="n")
##############################

### Put text stating coverage limit used ###
if (averaging == "m") {
   text(x.axis.min,y.axis.max*.96,paste("Coverage Limit = ",coverage_limit,"%",sep=""),cex=0.75,adj=c(0,.5))
}
if (run_info_text == "y") {
   if (rpo != "None") {
      text(x.axis.min,y.axis.max*.93,paste("RPO = ",rpo,sep=""),adj=c(0,.5),cex=.75)
   }
   if (site != "All") {
      text(x.axis.min,y.axis.max*.87,paste("Site = ",site,sep=""),adj=c(0,.5),cex=.75)
   }
   if (state != "All") {
      text(x.axis.min,y.axis.max*.84,paste("State = ",state,sep=""),adj=c(0,.5),cex=.75)
   }
}
############################################

### Count number of samples per month ###
nsamples.table <- obs.stats$n
#########################################

num_months <- length(nsamples.table)
### Put number of samples above each month ###
{
   if ((inc_ranges == "y") && (total_days <= 731)) {
      text(x=1:num_months,y=(bias.y.axis.min-((bias.y.axis.max-bias.y.axis.min)*.02)),labels=nsamples.table,cex=0.75)      
   }
   else {
      year_mark<-seq(13,num_months,by=12)       # Do not plot number of obs if plotting more than a year
      abline(v=year_mark,col="gray40",lty=1)
   }
}
##############################################

### Process if PNG output requested ###
if (ametptype == "png") {
   ### Convert pdf format file to png format ###
   convert_command<-paste("convert -density 150x150 ",outname_bias_pdf," ",outname_bias_png,sep="")
   dev.off()
   system(convert_command)

#   ### Remove PDF ###
#   remove_command <- paste("rm ",outname_bias_pdf,sep="")
#   system(remove_command)
}
#############################################

##########################################################
####### MAKE Normalized Bias BOXPLOT: Entire Domain ######
##########################################################

pdf(file=outname_norm_bias_pdf, width=8, height=8)
par(mai=c(1,1,0.5,0.5),las=1)
label <- "Normalized Bias (%)"
### User option to remove boxes and only plot median lines ###
{
   if (inc_ranges == "y") {
      boxplot(split(aqdat.df$Norm_Bias, aqdat.df$Split_On), range=0, border=whisker_colors[1], col=bar_colors[1], boxwex=bar_width[1], ylim=c(norm_bias.y.axis.min, norm_bias.y.axis.max), xlab="Date", ylab=label, cex.axis=1.0, cex.lab=1.3)
      if (run_name2 != "empty") {
         boxplot(split(aqdat2.df$Norm_Bias, aqdat2.df$Split_On), range=0, border=whisker_colors[2], col=bar_colors[2], boxwex=bar_width[2], ylim=c(norm_bias.y.axis.min, norm_bias.y.axis.max), xlab="Date", ylab=label, cex.axis=1.0, cex.lab=1.3, add=T)
      }
      if (run_name3 != "empty") {
         boxplot(split(aqdat3.df$Norm_Bias, aqdat3.df$Split_On), range=0, border=whisker_colors[3], col=bar_colors[3], boxwex=bar_width[3], ylim=c(norm_bias.y.axis.min, norm_bias.y.axis.max), xlab="Date", ylab=label, cex.axis=1.0, cex.lab=1.3, add=T)
      }
   }
   else {
      boxplot(split(aqdat.df$Norm_Bias, aqdat.df$Split_On), range=0, border="transparent", col=bar_color[1], boxwex=bar_width[1], ylim=c(norm_bias.y.axis.min, norm_bias.y.axis.max), xlab="Date", ylab=label, cex.axis=1.0, cex.lab=1.3)
      if (run_name2 != "empty") {
         boxplot(split(aqdat2.df$Norm_Bias, aqdat2.df$Split_On), range=0, border="transparent", col=bar_colors[2], boxwex=bar_width[2], ylim=c(norm_bias.y.axis.min, norm_bias.y.axis.max), xlab="Date", ylab=label, cex.axis=1.0, cex.lab=1.3, add=T)
      }
      if (run_name3 != "empty") {
         boxplot(split(aqdat3.df$Norm_Bias, aqdat3.df$Split_On), range=0, border="transparent", col=bar_colors[3], boxwex=bar_width[3], ylim=c(norm_bias.y.axis.min, norm_bias.y.axis.max), xlab="Date", ylab=label, cex.axis=1.0, cex.lab=1.3, add=T)
      }
   }
}
###############################################################

### Put title at top of boxplot ###
title(main=title)
###################################

### Place points, connected by lines, to denote where the medians are ###
x.loc <- 1:num.groups
points(x.loc, pch=0, col="black", median.norm_bias)                                              # Add points for obs median values
lines(x.loc, col="black", median.norm_bias)                                                      # Connect median points with a line
abline(h=0)

if (run_name2 != "empty") {
   points(x.loc, pch=0, median.norm_bias2, col=line_colors[1])                                              # Add points for obs median values
   lines(x.loc, median.norm_bias2, col=line_colors[1], lty=2)
}

if (run_name3 != "empty") {
   points(x.loc, pch=0, median.norm_bias3, col=line_colors[2])                                              # Add points for obs median values
   lines(x.loc, median.norm_bias3, col=line_colors[2], lty=3)
}

### Put legend on the plot ###
legend("topleft",legend_names,fill=legend_fill,lty=legend_type,col=legend_colors,merge=F,cex=1,bty="n")
##############################

### Put text stating coverage limit used ###
if (averaging == "m") {
   text(x.axis.min,y.axis.max*.96,paste("Coverage Limit = ",coverage_limit,"%",sep=""),cex=0.75,adj=c(0,.5))
}
if (run_info_text == "y") {
   if (rpo != "None") {
      text(x.axis.min,y.axis.max*.93,paste("RPO = ",rpo,sep=""),adj=c(0,.5),cex=.75)
   }
   if (site != "All") {
      text(x.axis.min,y.axis.max*.87,paste("Site = ",site,sep=""),adj=c(0,.5),cex=.75)
   }
   if (state != "All") {
      text(x.axis.min,y.axis.max*.84,paste("State = ",state,sep=""),adj=c(0,.5),cex=.75)
   }
}
############################################

### Count number of samples per month ###
nsamples.table <- obs.stats$n
#########################################

num_months <- length(nsamples.table)
### Put number of samples above each month ###
{
   if ((inc_ranges == "y") && (total_days <= 731)) {
      text(x=1:num_months,y=(norm_bias.y.axis.min-((norm_bias.y.axis.max-norm_bias.y.axis.min)*.02)),labels=nsamples.table,cex=0.75)
   }
   else {
      year_mark<-seq(13,num_months,by=12)       # Do not plot number of obs if plotting more than a year
      abline(v=year_mark,col="gray40",lty=1)
   }
}
##############################################

### Process if PNG output requested ###
if (ametptype == "png") {
   ### Convert pdf format file to png format ###
   convert_command<-paste("convert -density 150x150 ",outname_norm_bias_pdf," ",outname_norm_bias_png,sep="")
   dev.off()
   system(convert_command)

#   ### Remove PDF ###
#   remove_command <- paste("rm ",outname_norm_bias_pdf,sep="")
#   system(remove_command)
}
#############################################
