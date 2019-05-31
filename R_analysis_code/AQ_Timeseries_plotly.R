################################################################
### AMET CODE: INTERACTIVE TIMESERIES PLOT
###
### This script is part of the AMET-AQ system.  It plots a timeseries 
### plot.  The script can accept multiple sites, as they will be
### time averaged to create the timeseries plot, and mutiple runs.  
### The script also plots the bias and RMSE between the obs and model.
### This particular version of the Timeseries plot uses the R dyngraphs
### package to create an interactive plot with zoom and mouse-over
### capabilities. A self-contained html file is created using the 
### saveWidget command from the R htmlwidgets package.
###
### Last updated by Wyat Appel: September 2018
################################################################
library(plotly)
library(xts)
library(htmlwidgets)
library(processx)

sessionInfo()

## get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

### Retrieve units label from database table ###
network <- network_names[1]
################################################

### Set file names and titles ###
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { 
      main.title 	<- paste(run_name1,species[1],"for",network_label[1],"for",dates,sep=" ") 
      main.title.bias 	<- paste(run_name1,species[1],"for",network_label[1],"for",dates,sep=" ")
   }
   else { 
     main.title   <- custom_title
     main.title.bias <- custom_title
  }
}
sub.title	<- ""

filename_html   <- paste(run_name1,species,pid,"timeseries.html",sep="_")              # Set output file name
filename_html   <- paste(figdir,filename_html,sep="/")
filename_png    <- paste(run_name1,species,pid,"timeseries.png",sep="_")              # Set output file name
filename_png    <- paste(figdir,filename_png,sep="/")
filename_txt	<- paste(run_name1,species,pid,"timeseries.csv",sep="_")
filename_txt	<- paste(figdir,filename_txt,sep="/")           # Filename for diff spatial plot

#######################
### Set NULL values ###
#######################
Obs_Mean	<- NULL
Mod_Mean	<- NULL
Obs_Period_Mean	<- NULL
Mod_Period_Mean	<- NULL
Bias_Mean	<- NULL
Corr_Mean	<- NULL
RMSE_Mean	<- NULL
Dates		<- NULL
All_Data	<- NULL
Num_Obs		<- NULL
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
   #############################################
   ### Read sitex file or query the database ###
   #############################################
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         outdir           <- "OUTDIR" 
         if (j >1) { outdir <- paste("OUTDIR",j,sep="") }
         sitex_info       <- read_sitex(Sys.getenv(outdir),network,run_name,species)
         aqdat_query.df   <- sitex_info$sitex_data
         data_exists	  <- sitex_info$data_exists
         if (data_exists == "y") { units <- as.character(sitex_info$units[[1]]) }
      }
      else {
         query_result    <- query_dbase(run_name,network,species,orderby=c("ob_dates","ob_hour"))
         aqdat_query.df  <- query_result[[1]]
         data_exists     <- query_result[[2]]
         if (data_exists == "y") { units <- query_result[[3]] }
         model_name      <- query_result[[4]]
      }
   }
   ob_col_name <- paste(species,"_ob",sep="")
   mod_col_name <- paste(species,"_mod",sep="")
   #############################################
   {
   if (data_exists == "n") {
      All_Data.df <- merge(All_Data.df,paste("No Data for ",run_name,sep=""))
      num_runs <- (num_runs-1)
      if (num_runs == 0) { stop("Stopping because num_runs is zero. Likely no data found for query.") }
   }
   else {
   aqdat.df <- data.frame(Network=aqdat_query.df$network,Stat_ID=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=aqdat_query.df[[ob_col_name]],Mod_Value=aqdat_query.df[[mod_col_name]],Hour=aqdat_query.df$ob_hour,Start_Date=I(aqdat_query.df[,5]),End_Date=I(aqdat_query.df[,6]),Month=aqdat_query.df$month)

   Date_Hour            <- paste(aqdat.df$Start_Date," ",aqdat.df$Hour,sep="") # Create unique Date/Hour field
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

   if (j == 1) { # Set number of sites based on first run loaded (applies if runs have different number of sites)
      num_sites    <- length(unique(aqdat.df$Stat_ID))
   }
   s <- 1
   if (avg_func == "sum") { s <- num_sites }

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
   Corr_Mean[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Date_Hour,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value)))
#   RMSE_Mean[[j]]       <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Date_Hour,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))
    RMSE_Mean[[j]]       <- by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Date_Hour,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2)))
#   Dates[[j]]		<- as.POSIXct(unique(aqdat.df$Date_Hour),origin="1970-01-01")
   Dates[[j]]		<- unique(aqdat.df$Date_Hour)
   if (averaging == "ym") {
      years                <- substr(aqdat.df$Start_Date,1,4)
      months               <- substr(aqdat.df$Start_Date,6,7)
      yearmonth            <- paste(years,months,sep="-")
      aqdat.df$Year	   <- years
      aqdat.df$YearMonth   <- yearmonth
      Obs_Mean[[j]]	   <- (tapply(aqdat.df$Obs_Value,aqdat.df$YearMonth,centre,type=avg_func))/s
      Mod_Mean[[j]]	   <- (tapply(aqdat.df$Mod_Value,aqdat.df$YearMonth,centre,type=avg_func))/s
      Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
      Corr_Mean[[j]]            <- by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$YearMonth,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value))
      RMSE_Mean[[j]]       <- (by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$YearMonth,function(dfrm)sqrt(mean((dfrm$Mod_Value - dfrm$Obs_Value)^2))))/s
      Dates[[j]]           <- as.POSIXct(paste(unique(aqdat.df$YearMonth),"-01",sep=""),origin="1970-01-01")
      x_label              <- "Month"
   }
   if (averaging == "s") {
      season <- rep("NA", length(aqdat.df$Month))
      season[aqdat.df$Month %in% c(12,1,2)] <- "winter"
      season[aqdat.df$Month %in% c(3,4,5)] <- "spring"
      season[aqdat.df$Month %in% c(6,7,8)] <- "summer"
      season[aqdat.df$Month %in% c(9,10,11)] <- "fall"
      year                 <- unique(substr(aqdat.df$Start_Date,1,4))
      aqdat.df$season <- season
      Obs_Mean[[j]]        <- (tapply(aqdat.df$Obs_Value,aqdat.df$season,centre,type=avg_func))/s
      Mod_Mean[[j]]        <- (tapply(aqdat.df$Mod_Value,aqdat.df$season,centre,type=avg_func))/s
      Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
      Corr_Mean[[j]]            <- by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$season,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value))
      RMSE_Mean[[j]]       <- (by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$season,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))/s
      Dates[[j]]	   <- as.POSIXct(paste(year,"-",c(02,05,08,11),"-01",sep=""),origin="1970-01-01")
#      Dates[[j]]           <- as.POSIXct(paste(c(02,05,08,11),"-01",sep=""),origin="1970-01-01")
      x_label              <- "season"
   }
   if (averaging == "m") {
      years                <- substr(aqdat.df$Start_Date,1,4)
      months               <- substr(aqdat.df$Start_Date,6,7)
      yearmonth            <- paste(years[1],months,sep="-")
      aqdat.df$Year        <- years 
      aqdat.df$YearMonth   <- yearmonth
      Obs_Mean[[j]]        <- (tapply(aqdat.df$Obs_Value,aqdat.df$Month,centre,type=avg_func))/s
      Mod_Mean[[j]]        <- (tapply(aqdat.df$Mod_Value,aqdat.df$Month,centre,type=avg_func))/s
      Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
      Corr_Mean[[j]]            <- by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Month,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value))
      RMSE_Mean[[j]]       <- (by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Month,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))/s
      Dates[[j]]           <- as.POSIXct(paste(unique(aqdat.df$YearMonth),"-01",sep=""),origin="1970-01-01")
      x_label		   <- "Month"
   }
   if (averaging == "d") {
      Obs_Mean[[j]]        <- (tapply(aqdat.df$Obs_Value,aqdat.df$Start_Date,centre,type=avg_func))/s
      Mod_Mean[[j]]        <- (tapply(aqdat.df$Mod_Value,aqdat.df$Start_Date,centre,type=avg_func))/s
      Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
      Corr_Mean[[j]]            <- by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Start_Date,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value))
      RMSE_Mean[[j]]       <- (by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Start_Date,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))/s
      Dates[[j]]           <- as.POSIXct(unique(aqdat.df$Start_Date),origin="1970-01-01")
   }
   if (averaging == "h") {
      years                <- substr(aqdat.df$Start_Date,1,4)
      months               <- substr(aqdat.df$Start_Date,6,7)
      days		   <- substr(aqdat.df$Start_Date,9,10)
      Obs_Mean[[j]]        <- (tapply(aqdat.df$Obs_Value,aqdat.df$Hour,centre,type=avg_func))/s
      Mod_Mean[[j]]        <- (tapply(aqdat.df$Mod_Value,aqdat.df$Hour,centre,type=avg_func))/s
      Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
      Corr_Mean[[j]]            <- by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Hour,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value))
      RMSE_Mean[[j]]       <- (by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Hour,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))/s
#      Dates[[j]]           <- unique(aqdat.df$Hour)
      Dates[[j]]           <- as.POSIXct(paste(years[1],"-",months[1],"-",days[1]," ",unique(aqdat.df$Hour),":00:00",sep=""),origin="1970-01-01")
      x_label		   <- "Hour (LST)"
   }
   if (averaging == "a") {
      years                <- substr(aqdat.df$Start_Date,1,4)
      aqdat.df$Year        <- years
      Obs_Mean[[j]]        <- (tapply(aqdat.df$Obs_Value,aqdat.df$Year,centre,type=avg_func))/s
      Mod_Mean[[j]]        <- (tapply(aqdat.df$Mod_Value,aqdat.df$Year,centre,type=avg_func))/s
      Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
      Corr_Mean[[j]]            <- by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Year,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value))
      RMSE_Mean[[j]]       <- (by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Year,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))/s
#      Dates[[j]]          <- unique(aqdat.df$Year)
      Dates[[j]]           <- as.POSIXct(paste(unique(aqdat.df$Year),"01-01",sep=""),origin="1970-01-01")
      
      x_label              <- "Year"
   }
   if (j == 1) { # Set number of sites based on first run loaded (applies if runs have different number of sites)
      num_sites    <- length(unique(aqdat.df$Stat_ID))
   }
   if (num_sites == 1) {	# If only one site, Corr_Mean is calculated as NA, and therefore must be replaced with zeros to keep the code working (hack)
      Corr_Mean[[j]][is.na(Corr_Mean[[j]])] <- 0
   }
   Num_Obs[[j]]		<- length(aqdat.df$Obs_Value)

   #####################################

   {
   col_name1               <- paste(run_names[j],"_Obs_Average",sep="")
   col_name2               <- paste(run_names[j],"_Model_Average",sep="")
   col_name3               <- paste(run_names[j],"_Bias_Average",sep="")
   col_name4               <- paste(run_names[j],"_RMSE_Average",sep="")
   col_name5               <- paste(run_names[j],"_Corr_Average",sep="")
   
      if (j == 1) {
         All_Data.df             <- data.frame(Date=Dates[[j]])
         All_Data.df[,col_name1] <- signif((Obs_Mean[[j]]),6)
         All_Data.df[,col_name2] <- signif((Mod_Mean[[j]]),6)
         All_Data.df[,col_name3] <- signif((Bias_Mean[[j]]),6)
         All_Data.df[,col_name4] <- signif((RMSE_Mean[[j]]),6)
         All_Data.df[,col_name5] <- signif((Corr_Mean[[j]]),3)
      }
      else {
         temp.df <- data.frame(Date=Dates[[j]])
         temp.df[,col_name1] <- signif((Obs_Mean[[j]]),6)
         temp.df[,col_name2] <- signif((Mod_Mean[[j]]),6)
         temp.df[,col_name3] <- signif((Bias_Mean[[j]]),6)
         temp.df[,col_name4] <- signif((RMSE_Mean[[j]]),6)
         temp.df[,col_name5] <- signif((Corr_Mean[[j]]),3)
         All_Data.df <- merge(All_Data.df,temp.df,by="Date",all.x=T)
      }
   }

} # Close else statement
} # Close if/else statement
} # End num_runs loop

### Stop script if no data available ###
if (length(Dates[[1]]) == 0) { stop("Stopping because length of dates was zero. Likely no data found for query.") }
########################################

### Write data to be plotted to file ###
write.table(All_Data.df,file=filename_txt,append=F,row.names=F,sep=",")      # Write raw data to csv file
########################################

#####################################
### Plot Model vs. Ob Time Series ###
#####################################

data.df <- data.frame(Dates=Dates[[1]],Obs=Obs_Mean[[1]])

xaxis <- list(title= x_label, automargin = TRUE,titlefont=list(size=30))
yaxis <- list(title=paste(species," (",units,")"),automargin=TRUE,titlefont=list(size=30))

p <- plot_ly(data.df, x=~Dates, y=~Obs, type="scatter", width=img_width, height=img_height, mode='lines', name=network, text=~paste("Name: ",network,"<br>Date: ",Dates,"<br>Obs value: ",round(Obs,3))) %>%
     layout(title=main.title,titlefont=list(size=25),xaxis=xaxis,yaxis=yaxis,margin=list(t=50,b=110))
   
for (j in 1:num_runs) {
   p <- add_trace(p, x=Dates[[j]], y=Mod_Mean[[j]], type="scatter", name=run_names[j],mode='lines', text=paste("Name: ",run_names[j],"<br>Date: ",Dates[[j]],"<br>Model value: ",round(Mod_Mean[[j]],3)))
   if (inc_bias == 'y') {
      p <- add_trace(p, x=Dates[[j]], y=Bias_Mean[[j]], type="scatter", name=paste(run_names[j]," (Bias)"), mode='lines', text=paste("Name: ",run_names[j],"<br>Date: ",Dates[[j]],"<br>Bias: ",round(Bias_Mean[[j]],3)))
   }
   if (inc_rmse == 'y') {
      p <- add_trace(p, x=Dates[[j]], y=RMSE_Mean[[j]], type="scatter", name=paste(run_names[j]," (RMSE)"), mode='lines', text=paste("Name: ",run_names[j],"<br>Date: ",Dates[[j]],"<br>RMSE value: ",round(RMSE_Mean[[j]],3)))
   }
   if (inc_corr == 'y') {
      p <- add_trace(p, x=Dates[[j]], y=Corr_Mean[[j]], type="scatter", name=paste(run_names[j]," (r)"), mode='lines', text=paste("Name: ",run_names[j],"<br>Date: ",Dates[[j]],"<br>Correlation value: ",round(Corr_Mean[[j]],3)))
   }
}

#api_create(p, filename = "r-timeseries")

saveWidget(p, file=filename_html,selfcontained=T)
