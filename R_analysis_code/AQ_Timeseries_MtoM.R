################################################################
### AMET CODE: TIMESERIES PLOT
###
### This script is part of the AMET-AQ system.  It plots a timeseries 
### plot.  The script can accept multiple sites, as they will be
### time averaged to create the timeseries plot, and mutiple runs.  
### The script also plots the bias between the obs and model.
###
### Last updated by Wyat Appel: June, 2017
################################################################

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

### Retrieve units label from database table ###
network <- network_names[1]
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql)
if (is.na(units)) {
   units <- 'missing'
}
################################################

### Set file names and titles ###
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") {
      main.title      <- paste(run_name1,species,"for",network,"for",dates,sep=" ")
      main.title.bias <- paste("Bias for",run_name1,species,"for",network,"for",dates,sep=" ")
   }
   else {
     main.title   <- custom_title
     main.title.bias <- custom_title
  }
}
sub.title       <- ""

filename_pdf <- paste(run_name1,species,pid,"timeseries_mtom.pdf",sep="_")              # Set output file name
filename_png <- paste(run_name1,species,pid,"timeseries_mtom.png",sep="_")
filename_txt <- paste(run_name1,species,pid,"timeseries_mtom.csv",sep="_")

## Create a full path to file
filename_pdf    <- paste(figdir,filename_pdf,sep="/")           # Filename for diff spatial plot
filename_png    <- paste(figdir,filename_png,sep="/")           # Filename for diff spatial plot
filename_txt    <- paste(figdir,filename_txt,sep="/")           # Filename for diff spatial plot

Obs_Mean	<- NULL
Mod_Mean	<- NULL
Obs_Period_Mean	<- NULL
Mod_Period_Mean	<- NULL
Bias_Mean	<- NULL
Dates		<- NULL
All_Data	<- NULL
Num_Obs		<- NULL
ymin		<- NULL
ymax		<- NULL
bias_min        <- NULL
bias_max        <- NULL
x_label		<- "Date"

criteria <- paste(" WHERE d.",species,"_mod is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name1,"' and COLUMN_NAME = 'POCode';",sep="")
query_table_info.df <-db_Query(check_POCode,mysql)
{
   if (length(query_table_info.df$COLUMN_NAME)==0) {  # Check to see if individual project tables exist
      qs1    <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_mod,precip_ob,precip_mod,s.state from ",run_name1," as d, site_metadata as s",criteria," ORDER BY ob_dates",sep="")                                           # Secord part of MYSQL query for run name 1
      aqdat1.df        <- db_Query(qs1,mysql)     # query database for 1st run
      aqdat1.df$POCode <- 1
   }
   else {
      qs1    <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_mod,precip_ob,precip_mod,s.state,d.POCode from ",run_name1," as d, site_metadata as s",criteria," ORDER BY ob_dates",sep="")                                           # Secord part of MYSQL query for run name 1
      aqdat1.df        <- db_Query(qs1,mysql)     # query database for 1st run
   }
}
{
   check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name2,"' and COLUMN_NAME = 'POCode';",sep="")
   query_table_info.df <-db_Query(check_POCode,mysql)
   if (length(query_table_info.df$COLUMN_NAME)==0) {      # Check to see if individual project tables exist
      qs2       <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_mod,precip_ob,precip_mod,s.state from ",run_name2," as d, site_metadata as s",criteria," ORDER BY ob_dates",sep="")                                           # Second par of MYSQL query for run name 2
      aqdat2.df        <- db_Query(qs2,mysql)     # query database for 2nd run
      aqdat2.df$POCode <- 1
   }
   else {
      qs2       <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_mod,precip_ob,precip_mod,s.state,d.POCode from ",run_name2," as d, site_metadata as s",criteria," ORDER BY ob_dates",sep="")                                                 # Second par of MYSQL query for run name 2
      aqdat2.df <- db_Query(qs2,mysql)	# query database for 2nd run
   }
}

if ((site != "All") && (custom_title == "")) {
   main.title      <- paste(run_name1,species,"for",network,"Site:",site,"in",aqdat1.df$state[1],sep=" ")
   main.title.bias <- paste("Bias for",run_name1,species,"for",network,"Site:",site,"in",aqdat1.df$state[1],sep=" ")
}

aqdat1.df$ob_dates <- aqdat1.df[,5]          # remove hour,minute,second values from start date (should always be 000000 anyway, but could change)
aqdat2.df$ob_dates <- aqdat2.df[,5]          # remove hour,minute,second values from start date (should always be 000000 anyway, but could change)

### Match the points between each of the runs.  This is necessary if the data from each query do not match exactly ###
aqdat1.df$statdate<-paste(aqdat1.df$stat_id,aqdat1.df$ob_dates,aqdat1.df$ob_hour,sep="")     # Create unique column that combines the site name with the ob start date for run 1
aqdat2.df$statdate<-paste(aqdat2.df$stat_id,aqdat2.df$ob_dates,aqdat2.df$ob_hour,sep="")     # Create unique column that combines the site name with the ob start date for run 2
{
   if (length(aqdat1.df$statdate) <= length(aqdat2.df$statdate)) {                              # If more obs in run 1 than run 2
      match.ind<-match(aqdat1.df$statdate,aqdat2.df$statdate)                                   # Match the unique column (statdate) between the two runs
      aqdat.df<-data.frame(network=aqdat1.df$network, stat_id=aqdat1.df$stat_id, lat=aqdat1.df$lat, lon=aqdat1.df$lon, ob_dates=aqdat1.df$ob_dates, Hour=aqdat1.df$ob_hour, Mod1_Value=aqdat1.df[,9], Mod2_Value=aqdat2.df[match.ind,9], month=aqdat1.df$month, precip_ob=aqdat1.df$precip_ob, precip_mod=aqdat1.df$precip_mod)       # eliminate points that are not common between the two runs
   }
   else { match.ind<-match(aqdat2.df$statdate,aqdat1.df$statdate)                               # If more obs in run 2 than run 1
      aqdat.df<-data.frame(network=aqdat2.df$network, stat_id=aqdat2.df$stat_id, lat=aqdat2.df$lat, lon=aqdat2.df$lon, ob_dates=aqdat2.df$ob_dates, Hour=aqdat2.df$ob_hour, Mod1_Value=aqdat1.df[match.ind,9], Mod2_Value=aqdat2.df[,9], month=aqdat2.df$month, precip_ob=aqdat2.df$precip_ob, precip_mod=aqdat2.df$precip_mod)       # eliminate points that are not common between the two runs
   }
}
   #######################################################################################################################

aqdat.df <- data.frame(Network=aqdat.df$network,Stat_ID=aqdat.df$stat_id,lat=aqdat.df$lat,lon=aqdat.df$lon,Mod_Value1=aqdat.df$Mod1_Value,Mod_Value2=aqdat.df$Mod2_Value,Start_Date=aqdat.df$ob_dates,Hour=aqdat.df$Hour,Month=aqdat.df$month,precip_ob=aqdat.df$precip_ob,precip_mod=aqdat.df$precip_mod)

indic.na <- is.na(aqdat.df$Mod_Value1)        # Indentify NA records
aqdat.df <- aqdat.df[!indic.na,]             # Remove NA records
indic.na <- is.na(aqdat.df$Mod_Value2)        # Indentify NA records
aqdat.df <- aqdat.df[!indic.na,]             # Remove NA records

### Remove Negative (missing) Data ###
indic.nonzero        <- aqdat.df$Mod_Value1 >= 0      # determine which obs are missing (less than 0); 
aqdat.df             <- aqdat.df[indic.nonzero,]     # remove missing obs from dataframe
indic.nonzero        <- aqdat.df$Mod_Value2 >= 0      # determine which obs are missing (less than 0); 
aqdat.df             <- aqdat.df[indic.nonzero,]     # remove missing obs from dataframe
######################################

Date_Hour 		<- paste(aqdat.df$Start_Date," ",aqdat.df$Hour,":00:00",sep="")	# Create unique Date/Hour field
Date_Hour_Factor	<- factor(Date_Hour,levels=unique(Date_Hour))  			# Create unique levels so tapply maintains correct time order 
aqdat.df$Date_Hour 	<- Date_Hour							# Add Date_Hour field to dataframe

centre <- function(x, type) {
   switch(type,
      mean = mean(x,na.rm=T),
      median = median(x,na.rm=T),
      sum = sum(x,na.rm=T))
}

### Calculate Obs and Model Means ###
Mod_Period_Mean1	<- mean(aqdat.df$Mod_Value1)
Mod_Period_Mean2	<- mean(aqdat.df$Mod_Value2)
Mod_Mean1		<- tapply(aqdat.df$Mod_Value1,Date_Hour_Factor,centre,type=avg_func)
Mod_Mean2		<- tapply(aqdat.df$Mod_Value2,Date_Hour_Factor,centre,type=avg_func)

if ((units == "kg/ha") || (units == "mm")){	# Accumulate values if using precip/dep species
   Mod_Period_Mean1 <- median(aqdat.df$Mod_Value1)
   Mod_Period_Mean2 <- median(aqdat.df$Mod_Value2)
}
if (use_var_mean == "y") {
   Mod_Mean1	 <- Mod_Mean1[[j]] - Mod_Period_Mean1[[j]]
   Mod_Mean2     <- Mod_Mean1[[j]] - Mod_Period_Mean2[[j]]
}
Bias_Mean	<- Mod_Mean1-Mod_Mean2
Dates		<- as.POSIXct(unique(aqdat.df$Date_Hour))
if (averaging == "ym") {
   years                <- substr(aqdat.df$Start_Date,1,4)
   months               <- substr(aqdat.df$Start_Date,6,7)
   yearmonth            <- paste(years,months,sep="-")
   aqdat.df$Year	<- years
   aqdat.df$YearMonth	<- yearmonth
   Mod_Mean1		<- tapply(aqdat.df$Mod_Value1,aqdat.df$YearMonth,centre,type=avg_func)
   Mod_Mean2		<- tapply(aqdat.df$Mod_Value2,aqdat.df$YearMonth,centre,type=avg_func)
   Bias_Mean            <- Mod_Mean1[[j]]-Mod_Mean2
   Dates                <- as.POSIXct(paste(unique(aqdat.df$YearMonth),"-01",sep=""))
   x_label              <- "Month"
}
if (averaging == "m") {
   Mod_Mean1       <- tapply(aqdat.df$Mod_Value1,aqdat.df$Month,centre,type=avg_func)
   Mod_Mean2       <- tapply(aqdat.df$Mod_Value2,aqdat.df$Month,centre,type=avg_func)
   Bias_Mean       <- Mod_Mean1-Mod_Mean2
   Dates           <- unique(aqdat.df$Month)
   x_label         <- "Month"
}
if (averaging == "d") {
   Mod_Mean1       <- tapply(aqdat.df$Mod_Value1,aqdat.df$Start_Date,centre,type=avg_func)
   Mod_Mean2       <- tapply(aqdat.df$Mod_Value2,aqdat.df$Start_Date,centre,type=avg_func)
   Bias_Mean       <- Mod_Mean1-Mod_Mean2
   Dates           <- as.POSIXct(unique(aqdat.df$Start_Date))
}
if (averaging == "h") {
   Mod_Mean1       <- tapply(aqdat.df$Mod_Value1,aqdat.df$Hour,centre,type=avg_func)
   Mod_Mean2       <- tapply(aqdat.df$Mod_Value2,aqdat.df$Hour,centre,type=avg_func)
   Bias_Mean       <- Mod_Mean1-Mod_Mean2
   Dates           <- unique(aqdat.df$Hour)
   x_label         <- "Hour (LST)"
}
Num_Obs              <- length(aqdat.df$Mod_Value1)
#   ymin                 <- min(ymin,(Obs_Mean[[j]]-Obs_Period_Mean), (Mod_Mean[[j]]-Mod_Period_Mean))
#   ymax                 <- max(ymax,(Obs_Mean[[j]]-Obs_Period_Mean), (Mod_Mean[[j]]-Mod_Period_Mean))
ymin			<- min(ymin,Mod_Mean1, Mod_Mean2)
ymax			<- max(ymax,Mod_Mean1, Mod_Mean2)
bias_min		<- min(bias_min,Bias_Mean)
bias_max		<- max(bias_max,Bias_Mean)
col_name1		<- paste(run_name1,"_Average",sep="")
col_name2               <- paste(run_name2,"_Average",sep="")
col_name3               <- "Bias_Average"
All_Data.df	        <- data.frame(Date=Dates)
All_Data.df[,col_name1] <- signif((Mod_Mean1),6)
All_Data.df[,col_name2] <- signif((Mod_Mean2),6)
All_Data.df[,col_name3] <- signif((Bias_Mean),6)
#####################################

num_sites    <- length(unique(aqdat.df$Stat_ID))

### Write data to be plotted to file ###
write.table(All_Data.df,file=filename_txt,append=F,row.names=F,sep=",")      # Write raw data to csv file
########################################

### Calculate some values for plot formatting ###
range		<- ymax-ymin
ymax		<- ymax+(0.3*range)
bias_range	<- bias_max-bias_min
bias_max	<- bias_max+(0.3*bias_range)

if (length(y_axis_max) > 0) {
   ymax		<- y_axis_max
}
if (length(y_axis_min) > 0) {
   ymin		<- y_axis_min
}
if (length(bias_y_axis_max) > 0) { 
    bias_max   <- bias_y_axis_max
}
if (length(bias_y_axis_min) > 0) {
    bias_min   <- bias_y_axis_min
}

#################################################

#####################################
### Plot Model vs. Ob Time Series ###
#####################################
pdf(file=filename_pdf,width=11,height=8.5)
par(mfrow = c(2,1),mai=c(1,1,.5,1))
par(cex.axis=1,las=1,mfg=c(1,1),lab=c(5,10,7))
#plot(Dates[[1]],(Mod_Mean[[1]]-Mod_Period_Mean), axes=TRUE, ylim=c(ymin,ymax),type='l',ylab=paste(species,"(",units,")",sep=" "),xlab="Date",lty=1,col=plot_colors[1],cex=.7, xaxt="n")  # Plot model data
plot(Dates,Mod_Mean2, axes=TRUE, ylim=c(ymin,ymax),type='l',ylab=paste(species,"(",units,")",sep=" "),xlab=x_label,lty=1,col=plot_colors[2],cex=.7, xaxt="n")  # Plot model data
if (inc_points == 'y') {
#   points(Dates,(Mod_Mean-Mod_Period_Mean),col=plot_colors[[1]])
   points(Dates,Mod_Mean2,col=plot_colors[[2]])
}
{
   if ((averaging == "h") || (averaging == "m")) {
      axis(side=1, at=Dates)
   }
   else if (averaging == "ym") {
      axis.POSIXct(side=1, at=Dates,format="%b %Y")
   }
   else {
      axis.POSIXct(side=1, at=Dates,format="%b %d")
   }
}
#lines(Dates,(Obs_Mean-Obs_Period_Mean),col="black",lty=1)
lines(Dates,Mod_Mean1,col=plot_colors[1],lty=1)
if (inc_points == 'y') {
   points(Dates,Mod_Mean1,col=plot_colors[1])
#   points(Dates,(Obs_Mean-Obs_Period_Mean),col="black")
}
legend_names <- c(run_name1,run_name2)
legend_colors <- c(plot_colors[1],plot_colors[2])
usr <- par("usr")
text(usr[2],usr[4],paste("# of Sites: ",num_sites,sep=""),adj=c(1.1,1.1),cex=1)
legend("topleft",legend=legend_names,col=legend_colors,lty=c(1,1,1), merge=TRUE,cex=1, bty='n')  # Add legend
title(main=main.title, cex.main = 0.9, sub=sub.title, cex.sub = 0.75, col.sub = "red")
#title(main="Domain-wide Daily Average PM2.5 for Europe",sub=sub.title,cex.sub = 0.75, col.sub = "red")
######################################

if (run_info_text == "y") {
   if (rpo != "None") {
      text(max(Dates),ymax*.90,paste("RPO: ",rpo,sep=""),pos=2,cex=.8)
   }
   if (pca != "None") {
      text(max(Dates),ymax*.83,paste("PCA: ",pca,sep=""),pos=2,cex=.8)
   }
   if (state != "All") {
      text(max(Dates),ymax*.76,paste("State: ",state,sep=""),pos=2,cex=.8)
   }
   if (site != "All") {
      text(max(Dates),ymax-((ymax-ymin)*.10),paste("Site: ",site,sep=""),pos=2,cex=.8)
   }
}

###################################
### Plot Model Bias Time Series ###
###################################
par(new=T)
par(mfg=c(2,1))
plot(Dates,Bias_Mean, axes=TRUE, ylim=c(bias_min,bias_max),type='l',ylab=paste(species,"(",units,")",sep=" "),xlab=x_label,lty=1,col=plot_colors[2],cex=.7, xaxt="n")  # Plot model data
if (inc_points == 'y') {
   points(Dates,Bias_Mean,col=plot_colors[2])
}
{
   if ((averaging == "h") || (averaging == "m")) {
      axis(side=1, at=Dates)
   }
   else if (averaging == "ym") {
      axis.POSIXct(side=1, at=Dates,format="%b %Y")
   }
   else {
      axis.POSIXct(side=1, at=Dates,format="%b %d")
#      axis.POSIXct(side=1, at=Dates)
   }
}
legend_names <- paste(run_name1,"-",run_name2,sep=" ")
legend_colors <- plot_colors[2]
abline(h=0,col="black")
usr <- par("usr")
text(usr[2],usr[4],paste("# of Sites: ",num_sites,sep=""),adj=c(1.1,1.1),cex=1)
legend("topleft",legend=legend_names,col=legend_colors,lty=c(1,1,1), merge=TRUE,cex=1, bty='n')  # Add legend
title(main=main.title.bias, cex.main=0.9, sub=sub.title, cex.sub = 0.75, col.sub = "red")
###################################

if (run_info_text == "y") {
   if (rpo != "None") {
      text(max(Dates),bias_max*.90,paste("RPO: ",rpo,sep=""),pos=2,cex=.8)
   }
   if (pca != "None") {
      text(max(Dates),bias_max*.83,paste("PCA: ",pca,sep=""),pos=2,cex=.8)
   }
   if (state != "All") {
      text(max(Dates),bias_max*.76,paste("State: ",state,sep=""),pos=2,cex=.8)
   }
   if (site != "All") {
      text(max(Dates),bias_max-((bias_max-bias_min)*.10),paste("Site: ",site,sep=""),pos=2,cex=.8)
   } 
}

### Create PNG Plot ###
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density 150x150 ",filename_pdf," png:",filename_png,sep="")
   dev.off()
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}
#######################

