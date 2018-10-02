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

library(dygraphs)
library(xts)
library(htmlwidgets)

## get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

### Retrieve units label from database table ###
network <- network_names[1]
#units_qs <- paste("SELECT ",species[1]," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
#model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
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


filename_html   <- paste(run_name1,species,pid,"timeseries.html",sep="_")       # Set output filename
filename_html   <- paste(figdir,filename_html,sep="/")                          # Set output filename location
filename_txt	<- paste(run_name1,species,pid,"timeseries.csv",sep="_")
filename_txt 	<- paste(figdir,filename_txt,sep="/")           # Filename for diff spatial plot


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
         units            <- as.character(sitex_info$units[[1]])
      }
      else {
         query_result    <- query_dbase(run_name,network,species,orderby=c("ob_dates","ob_hour"))
         aqdat_query.df  <- query_result[[1]]
         data_exists     <- query_result[[2]]
         units	         <- query_result[[3]]
         model_name      <- query_result[[4]]
      }
   }
   #############################################
   {
   if (data_exists == "n") {
      All_Data.df <- merge(All_Data.df,paste("No Data for ",run_name,sep=""))
      num_runs <- (num_runs-1)
   }
   else {
   aqdat.df <- data.frame(Network=aqdat_query.df$network,Stat_ID=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=aqdat_query.df[,9],Mod_Value=aqdat_query.df[,10],Hour=aqdat_query.df$ob_hour,Start_Date=I(aqdat_query.df[,5]),End_Date=I(aqdat_query.df[,6]),Month=aqdat_query.df$month)

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

   #####################################

   {
      if (j == 1) {
         col_name1               <- paste(run_names[1],"_Obs_Average",sep="")
         col_name2               <- paste(run_names[1],"_Model_Average",sep="")
         col_name3               <- paste(run_names[1],"_Bias_Average",sep="")
         col_name4               <- paste(run_names[1],"_RMSE_Average",sep="")
         col_name5               <- paste(run_names[1],"_Corr_Average",sep="")
         All_Data.df             <- data.frame(Date=Dates[[j]])
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

} # Close else statement
} # Close if/else statement
ymin	<- 1.05*floor(min(ymin,Obs_Mean[[j]], Mod_Mean[[j]],Bias_Mean[[j]],RMSE[[j]]))
ymax	<- 1.05*ceiling(max(ymax,Obs_Mean[[j]], Mod_Mean[[j]],Bias_Mean[[j]],RMSE[[j]]))
} # End num_runs loop

### Write data to be plotted to file ###
write.table(All_Data.df,file=filename_txt,append=F,row.names=F,sep=",")      # Write raw data to csv file
########################################

#####################################
### Plot Model vs. Ob Time Series ###
#####################################

n.data <- length(Dates[[1]])
zero.ref <- rep(0,n.data)
start.date <- sort(Dates[[1]])[1]
end.date <- sort(Dates[[1]])[n.data]
#Turn data into an xts time series object.
obs.ts <- xts(Obs_Mean[[1]],order.by=Dates[[1]])
mod.ts <- xts(Mod_Mean[[1]],order.by=Dates[[1]])
bias.ts <- xts(Bias_Mean[[1]],order.by=Dates[[1]])
rmse.ts <- xts(RMSE[[1]],order.by=Dates[[1]])
zero.ref.ts <- xts(zero.ref,order.by=Dates[[1]])
ts.combine <- cbind(obs.ts,mod.ts,bias.ts,rmse.ts,zero.ref.ts)

if (j > 1) {
   mod2.ts <- xts(Mod_Mean[[2]],order.by=Dates[[2]])
   bias2.ts <- xts(Bias_Mean[[2]],order.by=Dates[[2]])
   rmse2.ts <- xts(RMSE[[2]],order.by=Dates[[2]])
   ts.combine <- cbind(obs.ts,mod.ts,bias.ts,rmse.ts,mod2.ts,bias2.ts,rmse2.ts,zero.ref.ts)
}

if (length(y_axis_max) > 0) { ymax <- y_axis_max }
if (length(y_axis_min) > 0) { ymin <- y_axis_min }

#Use dygraph to make interactive html plot. (https://rstudio.github.io/dygraphs/ has examples of other features to try out.)
if (j == 1) {
   plot.ts <- dygraph(ts.combine, main=main.title, ylab=paste(species[1]," (",units[[1]],")",sep="")) %>%
     dyAxis("y", valueRange = c(ymin,ymax)) %>%
     dySeries("..1",label=,network,strokeWidth=3) %>%
     dySeries("..2",label=,run_name1,strokeWidth=2) %>%
     dySeries("..3",label=,"Model - Obs Bias",strokeWidth=2) %>%
     dySeries("..4",label=,"RMSE",strokeWidth=2) %>%
     dySeries("..5",label=,"Reference",strokeWidth=3) %>%
     dyOptions(colors=c("blue","green","red","black","grey")) %>%
     dyRangeSelector(height=20,dateWindow = c(start.date, end.date))%>%
     dyLegend(width=800)
}

if (j != 1) {
   plot.ts <- dygraph(ts.combine, main=main.title, ylab=paste(species[1]," (",units[[1]],")",sep="")) %>%
     dyAxis("y", valueRange = c(ymin,ymax)) %>%
     dySeries("..1",label=,network,strokeWidth=3) %>%
     dySeries("..2",label=,run_name1,strokeWidth=2) %>%
     dySeries("..3",label=,"Model - Obs Bias (Sim1)",strokeWidth=2) %>%
     dySeries("..4",label=,"RMSE (Sim1)",strokeWidth=2) %>%
     dySeries("..5",label=,run_name2,strokeWidth=2,strokePattern="dashed") %>%
     dySeries("..6",label=,"Model - Obs Bias (Sim2)",strokeWidth=2,strokePattern="dashed") %>%
     dySeries("..7",label=,"RMSE (Sim2)",strokeWidth=2,strokePattern="dashed") %>%
     dySeries("..8",label=,"Reference",strokeWidth=3) %>%
     dyOptions(colors=c("blue","green","red","black","green","red","black","grey")) %>%
     dyRangeSelector(height=20,dateWindow = c(start.date, end.date))%>%
     dyLegend(width=800)
}
#On Newton:
#saveWidget(plot.ts, file="/home/kfoley/LINKS/tools/Rcode/dygraphs/sitecompare_time_series_example_on_newton.html",selfcontained=F)

saveWidget(plot.ts, file=filename_html,selfcontained=T)
#saveWidget(plot.ts, file=filename_html,selfcontained=T,title=main.title)	# Need to update to latest version of htmlwidgets to implement title option

#On windows:
#saveWidget(plot.ts, file="B:/LINKS/tools/Rcode/dygraphs/sitecompare_time_series_example_selfcontained.html",selfcontained=T)

#delete_command <- paste("sed -i '1,3d;12,13d' ",filename_html,sep="")

#system(delete_command)
