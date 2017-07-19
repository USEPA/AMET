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

## get some environmental variables and setup some directories
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
      main.title 	<- paste(run_name1,species,"for",network_label[1],"for",dates,sep=" ") 
      main.title.bias 	<- paste(run_name1,species,"for",network_label[1],"for",dates,sep=" ")
   }
   else { 
     main.title   <- custom_title
     main.title.bias <- custom_title
  }
}
sub.title	<- ""


filename_txt <- paste(run_name1,species,pid,"timeseries.csv",sep="_")

## Create a full path to file
filename_txt	<- paste(figdir,filename_txt,sep="/")           # Filename for diff spatial plot


#######################
### Set NULL values ###
#######################
Obs_Mean	<- NULL
Mod_Mean	<- NULL
Obs_Period_Mean	<- NULL
Mod_Period_Mean	<- NULL
Bias_Mean	<- NULL
CORR		<- NULL
RMSE		<- NULL
Dates		<- NULL
All_Data	<- NULL
Num_Obs		<- NULL
ymin		<- NULL
ymax		<- NULL
bias_min        <- NULL
bias_max        <- NULL
corr_min	<- NULL
corr_max	<- NULL
rmse_max	<- NULL
rmse_min	<- NULL
x_label		<- "Date"
#######################

{
   run_names       <- run_name1  
   if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
      run_names <- c(run_names,run_name2)
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
   if ((exists("run_name7")) && (nchar(run_name7) > 0)) {
      run_names <- c(run_names,run_name7)
   }
}

labels <- c(network,run_names)
num_runs <- length(run_names)

for (j in 1:num_runs) {	# For each simulation being plotted
   run_name <- run_names[j]

   criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query

   check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name1,"' and COLUMN_NAME = 'POCode';",sep="")
   query_table_info.df <-db_Query(check_POCode,mysql)
   {
      if (length(query_table_info.df$COLUMN_NAME) == 0) {        # Check to see if POCode column exists or not
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, d.precip_ob, s.state from ",run_name," as d, site_metadata as s",criteria," ORDER BY ob_dates,ob_hour",sep="")
         aqdat_query.df<-db_Query(qs,mysql)
         aqdat_query.df$POCode <- 1
      }
      else {
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, d.precip_ob, d.POCode, s.state from ",run_name," as d, site_metadata as s",criteria," ORDER BY ob_dates,ob_hour",sep="")
         aqdat_query.df<-db_Query(qs,mysql)
      }
   }
   aqdat_query.df$stat_id <- paste(aqdat_query.df$stat_id,aqdat_query.df$POCode,sep="")
   aqdat.df <- data.frame(Network=aqdat_query.df$network,Stat_ID=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=aqdat_query.df[,9],Mod_Value=aqdat_query.df[,10],Hour=aqdat_query.df$ob_hour,Start_Date=I(aqdat_query.df[,5]),End_Date=I(aqdat_query.df[,6]),Month=aqdat_query.df$month,precip_ob=aqdat_query.df$precip_ob)

   ### Remove Missing Data ###
   indic.nonzero        <- aqdat.df$Obs_Value >= 0      # determine which obs are missing (less than 0); 
   aqdat.df             <- aqdat.df[indic.nonzero,]     # remove missing obs from dataframe
   indic.nonzero        <- aqdat.df$Mod_Value >= 0      # determine which obs are missing (less than 0); 
   aqdat.df             <- aqdat.df[indic.nonzero,]     # remove missing obs from dataframe
   ###########################

   Date_Hour            <- paste(aqdat.df$Start_Date," ",aqdat.df$Hour,":00:00",sep="") # Create unique Date/Hour field
   aqdat.df$Date_Hour   <- Date_Hour                                                    # Add Date_Hour field to dataframe
   if (obs_per_day_limit > 0) {
      num_obs_value <- tapply(aqdat.df$Obs_Value,aqdat.df$Date_Hour,function(x)sum(!is.na(x)))
      drop_days <- names(num_obs_value)[num_obs_value < obs_per_day_limit]
      aqdat_new.df <- subset(aqdat.df,!(Date_Hour%in%drop_days))
      aqdat.df <- aqdat_new.df
   }

   if ((site != "All") && (custom_title == "")) {
      main.title      <- paste(run_name1,species,"for",network,"Site:",site,"in",aqdat_query.df$state[1],sep=" ")
      main.title.bias <- paste("Bias for",run_name1,species,"for",network,"Site:",site,"in",aqdat_query.df$state[1],sep=" ")
   }

   Date_Hour_Factor     <- factor(aqdat.df$Date_Hour,levels=unique(aqdat.df$Date_Hour))                   # Create unique levels so tapply maintains correct time order

   centre <- function(x, type) {
       switch(type,
          mean = mean(x,na.rm=T),
          median = median(x,na.rm=T),
          sum = sum(x,na.rm=T))
   }

   ### Calculate Obs and Model Means ###
   Obs_Period_Mean[[j]]	<- mean(aqdat.df$Obs_Value)
   Mod_Period_Mean[[j]]	<- mean(aqdat.df$Mod_Value)
   Obs_Mean[[j]]	<- tapply(aqdat.df$Obs_Value,Date_Hour_Factor,centre,type=avg_func)
   Mod_Mean[[j]]	<- tapply(aqdat.df$Mod_Value,Date_Hour_Factor,centre,type=avg_func)
   Num_Obs[[j]]         <- length(aqdat.df$Obs_Value)

   if ((units == "kg/ha") || (units == "mm")){	# Accumulate values if using precip/dep species
      Obs_Period_Mean[[j]] <- median(aqdat.df$Obs_Value)
      Mod_Period_Mean[[j]] <- median(aqdat.df$Mod_Value)
   }
   if (use_var_mean == "y") {
      Obs_Mean[[j]]	<- Obs_Mean[[j]] - Obs_Period_Mean[[j]]
      Mod_Mean[[j]]	<- Mod_Mean[[j]] - Mod_Period_Mean[[j]]
   }
   Bias_Mean[[j]]	<- Mod_Mean[[j]]-Obs_Mean[[j]]
   CORR[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Date_Hour,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value)))
   RMSE[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Date_Hour,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))
   Dates[[j]]		<- as.POSIXct(unique(aqdat.df$Date_Hour),origin="1970-01-01")
   if (averaging == "ym") {
      years                     <- substr(aqdat.df$Start_Date,1,4)
      months                    <- substr(aqdat.df$Start_Date,6,7)
      yearmonth                 <- paste(years,months,sep="-")
      aqdat.df$Year		<- years
      aqdat.df$YearMonth	<- yearmonth
      Obs_Mean[[j]]		<- tapply(aqdat.df$Obs_Value,aqdat.df$YearMonth,centre,type=avg_func)
      Mod_Mean[[j]]		<- tapply(aqdat.df$Mod_Value,aqdat.df$YearMonth,centre,type=avg_func)
      Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
      CORR[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$YearMonth,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value)))
      RMSE[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$YearMonth,function(dfrm)sqrt(mean((dfrm$Mod_Value - dfrm$Obs_Value)^2))))
      Dates[[j]]           <- as.POSIXct(paste(unique(aqdat.df$YearMonth),"-01",sep=""),origin="1970-01-01")
      x_label              <- "Month"
   }
   if (averaging == "m") {
      Obs_Mean[[j]]        <- tapply(aqdat.df$Obs_Value,aqdat.df$Month,centre,type=avg_func)
      Mod_Mean[[j]]        <- tapply(aqdat.df$Mod_Value,aqdat.df$Month,centre,type=avg_func)
      Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
      CORR[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Month,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value)))
      RMSE[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Month,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))
      Dates[[j]]            <- unique(aqdat.df$Month)
      x_label		   <- "Month"
   }
   if (averaging == "d") {
      Obs_Mean[[j]]        <- tapply(aqdat.df$Obs_Value,aqdat.df$Start_Date,centre,type=avg_func)
      Mod_Mean[[j]]        <- tapply(aqdat.df$Mod_Value,aqdat.df$Start_Date,centre,type=avg_func)
      Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
      CORR[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Start_Date,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value)))
      RMSE[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Start_Date,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))
      Dates[[j]]           <- as.POSIXct(unique(aqdat.df$Start_Date),origin="1970-01-01")
   }
   if (averaging == "h") {
      Obs_Mean[[j]]        <- tapply(aqdat.df$Obs_Value,aqdat.df$Hour,centre,type=avg_func)
      Mod_Mean[[j]]        <- tapply(aqdat.df$Mod_Value,aqdat.df$Hour,centre,type=avg_func)
      Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
      CORR[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Hour,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value)))
      RMSE[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Hour,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))
      Dates[[j]]           <- unique(aqdat.df$Hour)
      x_label		   <- "Hour (LST)"
   }
   if (averaging == "a") {
      years                <- substr(aqdat.df$Start_Date,1,4)
      aqdat.df$Year        <- years
      Obs_Mean[[j]]        <- tapply(aqdat.df$Obs_Value,aqdat.df$Year,centre,type=avg_func)
      Mod_Mean[[j]]        <- tapply(aqdat.df$Mod_Value,aqdat.df$Year,centre,type=avg_func)
      Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
      CORR[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Year,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value)))
      RMSE[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Year,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))
      Dates[[j]]           <- unique(aqdat.df$Year)
      x_label              <- "Year"
   }
   if (j == 1) { # Set number of sites based on first run loaded (applies if runs have different number of sites)
      num_sites    <- length(unique(aqdat.df$Stat_ID))
   }
   if (num_sites == 1) {	# If only one site, CORR is calculated as NA, and therefore must be replaced with zeros to keep the code working (hack)
      CORR[[j]][is.na(CORR[[j]])] <- 0
   }
   Num_Obs[[j]]		<- length(aqdat.df$Obs_Value)
   ymin			<- min(ymin,Obs_Mean[[j]], Mod_Mean[[j]])
   ymax			<- max(ymax,Obs_Mean[[j]], Mod_Mean[[j]])
   bias_min		<- min(bias_min,Bias_Mean[[j]])
   bias_max		<- max(bias_max,Bias_Mean[[j]])
   corr_min             <- min(corr_min,CORR[[j]],na.rm=T)
   if (corr_min == "Inf") {
      corr_min <- 0
   }
   corr_max             <- max(corr_max,CORR[[j]],na.rm=T)
   if (corr_max == "-Inf") {
      corr_max <- 1
   }
   rmse_max		<- max(rmse_max,RMSE[[j]])
   rmse_min		<- min(rmse_min,RMSE[[j]])
   {
   if (j == 1) {
      col_name1		      <- paste(run_names[1],"_Obs_Average",sep="")
      col_name2               <- paste(run_names[1],"_Model_Average",sep="")
      col_name3               <- paste(run_names[1],"_Bias_Average",sep="")
      col_name4               <- paste(run_names[1],"_RMSE_Average",sep="")
      col_name5               <- paste(run_names[1],"_Corr_Average",sep="")
      All_Data.df	      <- data.frame(Date=Dates[[j]])
      All_Data.df[,col_name1] <- signif((Obs_Mean[[j]]),6)
      All_Data.df[,col_name2] <- signif((Mod_Mean[[j]]),6)
      All_Data.df[,col_name3] <- signif((Bias_Mean[[j]]),6)
      All_Data.df[,col_name4] <- signif((RMSE[[j]]),6)
      All_Data.df[,col_name5] <- signif((CORR[[j]]),3)
   }
   else {
      col_name1 <- paste(run_names[j],"_Obs_Average",sep="")
      col_name2 <- paste(run_names[j],"_Model_Average",sep="")
      col_name3 <- paste(run_names[j],"_Bias_Average",sep="")
      col_name4 <- paste(run_names[j],"_RMSE_Average",sep="")
      col_name5 <- paste(run_names[j],"_Corr_Average",sep="")
      temp.df <- data.frame(Date=Dates[[j]])
      temp.df[,col_name1] <- signif((Obs_Mean[[j]]),6)
      temp.df[,col_name2] <- signif((Mod_Mean[[j]]),6)
      temp.df[,col_name3] <- signif((Bias_Mean[[j]]),6)
      temp.df[,col_name4] <- signif((RMSE[[j]]),6)      
      temp.df[,col_name5] <- signif((CORR[[j]]),3)
      All_Data.df <- merge(All_Data.df,temp.df,by="Date",all.x=T)
   }
   }
   #####################################

}	# End For Loop

### Write data to be plotted to file ###
write.table(All_Data.df,file=filename_txt,append=F,row.names=F,sep=",")      # Write raw data to csv file
########################################

### Calculate some values for plot formatting ###
range		<- ymax-ymin
ymax		<- ymax+(0.3*range)
bias_range	<- bias_max-bias_min
bias_max	<- bias_max+(0.3*bias_range)
corr_range      <- corr_max-corr_min
corr_max        <- corr_max+(0.3*corr_range)
rmse_range	<- rmse_max-rmse_min
rmse_max	<- rmse_max+(0.3*rmse_range)

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

for (f in 1:3) {	# Loop for plotting Bias, RMSE and Correlation
   if (f == 1) {
      stat_func <- 'corr'
      main.title.bias <- paste("Correlation for",run_name1,species,"for",network,"for",dates,sep=" ")
      y_stat_max <- corr_max
      y_stat_min <- max(0,corr_min)
   }
   if (f == 2) {
      stat_func <- 'rmse'
      main.title.bias <- paste("RMSE for",run_name1,species,"for",network,"for",dates,sep=" ")
      y_stat_max <- rmse_max
      y_stat_min <- max(0,rmse_min)

   }
   if (f == 3) {
      stat_func <- 'bias'
      main.title.bias <- paste("Bias for",run_name1,species,"for",network,"for",dates,sep=" ")
      y_stat_max <- bias_max
      y_stat_min <- bias_min 
   }

   filename_pdf         <- paste(run_name1,species,pid,stat_func,"timeseries.pdf",sep="_")              # Set output file name
   filename_png         <- paste(run_name1,species,pid,stat_func,"timeseries.png",sep="_")

   filename_pdf         <- paste(figdir,filename_pdf,sep="/")           # Filename for obs spatial plot
   filename_png         <- paste(figdir,filename_png,sep="/")           # Filename for model spatial plot

   if (custom_title != "") {
      main.title.bias <- custom_title
   }
   #####################################
   ### Plot Model vs. Ob Time Series ###
   #####################################
   pdf(file=filename_pdf,width=11,height=8.5)
   par(mfrow = c(2,1),mai=c(1,1,.5,1))
   par(cex.axis=1,las=1,mfg=c(1,1),lab=c(5,10,7))
   plot(Dates[[1]],Mod_Mean[[1]], axes=TRUE, ylim=c(ymin,ymax),type='l',ylab=paste(species,"(",units,")",sep=" "),xlab=x_label,lty=1,col=plot_colors[2],cex=.7, xaxt="n",lwd=line_width)  # Plot model data
   if (inc_points == 'y') {
      points(Dates[[1]],Mod_Mean[[1]],col=plot_colors[[2]])
   }
   {
      if ((averaging == "h") || (averaging == "m") || (averaging == "a")) {
         axis(side=1, at=Dates[[1]])
      }
      else if (averaging == "ym") {
         axis.POSIXct(side=1, at=Dates[[1]],format="%b %Y")
      }
      else {
         axis.POSIXct(side=1, at=Dates[[1]],format="%b %d")
      }
   }
   lines(Dates[[1]],Obs_Mean[[1]],col=plot_colors[1],lty=1,lwd=line_width)
   if (inc_points == 'y') {
      points(Dates[[1]],Obs_Mean[[1]],col=plot_colors[1])
   }
   legend_names <- c(network_label[1],run_names[1])
   legend_colors <- c(plot_colors[1],plot_colors[2])
   if (num_runs > 1) {
      for (k in 2:num_runs) {
         lines(Dates[[k]],Mod_Mean[[k]],col=plot_colors[k+1],lty=1,lwd=line_width)
         if (inc_points == 'y') {
            points(Dates[[k]],Mod_Mean[[k]],col=plot_colors[k+1])
         }
         legend_names <- c(legend_names,run_names[k])
         legend_colors <- c(legend_colors,plot_colors[k+1])
         if (Num_Obs[[k]] != Num_Obs[[1]]) {
            num_diff <- abs(Num_Obs[[k]]-Num_Obs[[1]])
            sub.title <- paste("Warning: Number of observations differ by",num_diff,"between simulations",sep=" ")
         }
      }   
   }
   usr <- par("usr")
   text(usr[2],usr[4],paste("# of Sites: ",num_sites,sep=""),adj=c(1.1,1.1),cex=1)
   if (inc_legend == 'y') {
      legend("topleft",legend=legend_names,col=legend_colors,lty=c(1,1,1), merge=TRUE,cex=1, bty='n')  # Add legend
   }

   title(main=main.title, cex.main = 0.9, sub=sub.title, cex.sub = 0.75, col.sub = "red")
   ######################################

   if (run_info_text == "y") {
      if (rpo != "None") {
         text(max(Dates[[1]]),ymax-((ymax-ymin)*.25),paste("RPO: ",rpo,sep=""),pos=2,cex=.8)
      }
      if (pca != "None") {
         text(max(Dates[[1]]),ymax-((ymax-ymin)*.20),paste("PCA: ",pca,sep=""),pos=2,cex=.8)
      }
      if (state != "All") {
         text(max(Dates[[1]]),ymax-((ymax-ymin)*.15),paste("State: ",state,sep=""),pos=2,cex=.8)
      }
      if (site != "All") {
         text(max(Dates[[1]]),ymax-((ymax-ymin)*.10),paste("Site: ",site,sep=""),pos=2,cex=.8)
      }
   }

   ###################################
   ### Plot Model Bias Time Series ###
   ###################################
   par(new=T)
   par(mfg=c(2,1))

   {
      if (stat_func == 'corr') { # If plotting correlation instead of bias
         plot(Dates[[1]],CORR[[1]], axes=TRUE, ylim=c(y_stat_min,y_stat_max),type='l',ylab="Correlation",xlab=x_label,lty=1,col=plot_colors[2],cex=.7, xaxt="n",lwd=line_width)
         if (inc_points == 'y') {
            points(Dates[[1]],CORR[[1]],col=plot_colors[2])
         }
      }
      else if (stat_func == 'rmse') {
         plot(Dates[[1]],RMSE[[1]], axes=TRUE, ylim=c(y_stat_min,y_stat_max),type='l',ylab=paste("Root Mean Square Error (",units,")",sep=""),xlab=x_label,lty=1,col=plot_colors[2],cex=.7, xaxt="n",lwd=line_width)
         if (inc_points == 'y') {
            points(Dates[[1]],RMSE[[1]],col=plot_colors[2])
         }
      }
      else {
         plot(Dates[[1]],Bias_Mean[[1]], axes=TRUE, ylim=c(y_stat_min,y_stat_max),type='l',ylab=paste(species,"(",units,")",sep=" "),xlab=x_label,lty=1,col=plot_colors[2],cex=.7, xaxt="n",lwd=line_width)  # Plot model data
         if (inc_points == 'y') {
            points(Dates[[1]],Bias_Mean[[1]],col=plot_colors[2])
         }
      }
   }

   {
      if ((averaging == "h") || (averaging == "m") || (averaging == "a")) {
         axis(side=1, at=Dates[[1]])
      }
      else if (averaging == "ym") {
         axis.POSIXct(side=1, at=Dates[[1]],format="%b %Y")
      }
      else {
         axis.POSIXct(side=1, at=Dates[[1]],format="%b %d")
      }
   } 
   legend_names <- run_names[1]
   legend_colors <- plot_colors[2]

   if (num_runs > 1) {
      for (k in 2:num_runs) {
         {
            if (stat_func == 'corr') {
               lines(Dates[[k]],CORR[[k]],col=plot_colors[k+1],lty=1,lwd=line_width) 
               if (inc_points == 'y') {
                  points(Dates[[k]],CORR[[k]],col=plot_colors[k+1])
               }
            }
            else if (stat_func == 'rmse') {
               lines(Dates[[k]],RMSE[[k]],col=plot_colors[k+1],lty=1,lwd=line_width)
               if (inc_points == 'y') {
                  points(Dates[[k]],RMSE[[k]],col=plot_colors[k+1])
               }
            }
            else {
               lines(Dates[[k]],Bias_Mean[[k]],col=plot_colors[k+1],lty=1,lwd=line_width) 
               if (inc_points == 'y') {
                  points(Dates[[k]],Bias_Mean[[k]],col=plot_colors[k+1])
               }
            } 
         }
         legend_names <- c(legend_names,run_names[k])
         legend_colors <- c(legend_colors,plot_colors[k+1])
      } 
   }
   abline(h=0,col="black")
   usr <- par("usr")
   text(usr[2],usr[4],paste("# of Sites: ",num_sites,sep=""),adj=c(1.1,1.1),cex=1)
   if (inc_legend == 'y') {
      legend("topleft",legend=legend_names,col=legend_colors,lty=c(1,1,1), merge=TRUE,cex=1, bty='n')  # Add legend
   }
   title(main=main.title.bias, cex.main=0.9, sub=sub.title, cex.sub = 0.75, col.sub = "red")
   ###################################

   if (run_info_text == "y") {
      if (rpo != "None") {
         text(max(Dates[[1]]),y_stat_max-((bias_max-bias_min)*.25),paste("RPO: ",rpo,sep=""),pos=2,cex=.8)
      }
      if (pca != "None") {
         text(max(Dates[[1]]),y_stat_max-((bias_max-bias_min)*.20),paste("PCA: ",pca,sep=""),pos=2,cex=.8)
      }
      if (state != "All") {
         text(max(Dates[[1]]),y_stat_max-((bias_max-bias_min)*.15),paste("State: ",state,sep=""),pos=2,cex=.8)
      }
      if (site != "All") {
         text(max(Dates[[1]]),y_stat_max-((bias_max-bias_min)*.10),paste("Site: ",site,sep=""),pos=2,cex=.8)
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
}	# End loop for plotting Bias, RMSE and Correlation
