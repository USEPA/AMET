################################################################
### AMET CODE: BOX PLOT (plotly)
###
### This script is part of the AMET-AQ system.  This script uses
### the plotly package to create an interactive box plot. 
### Individual observation/model pairs are obtained through a
### MySQL query. Averaging is done based on the user-specified
### averaging flag. These flags include:
### hourly (h), day of month (d), daily (d), monthly (m), 
### seasonal (s), annual (a), year/month (ym), entire period (e),
### and day of week (dow).
###
### Last updated by Wyat Appel: February, 2019
################################################################

## get some environmental variables and setup some directories
ametbase	<- Sys.getenv("AMETBASE")			# base directory of AMET
ametR		<- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

library(plotly)
library(htmlwidgets)

### Set file names and titles ###
network<-network_names[[1]]
level_names_bias <- NULL

filename_html		<- paste(run_name1,species,pid,"boxplot.html",sep="_")
filename_bias_html	<- paste(run_name1,species,pid,"boxplot_bias.html",sep="_")
filename_txt		<- paste(run_name1,species,pid,"boxplot.csv",sep="_")

## Create a full path to file
filename_html            <- paste(figdir,filename_html,sep="/")
filename_html_bias       <- paste(figdir,filename_bias_html,sep="/")
filename_txt		 <- paste(figdir,file_name_txt,sep="/")

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { 
      title <- paste(run_name1,species,"for",network_label[1],"for",dates,sep=" ") 
      title_bias <- paste(run_name1,species," bias for",network_label[1],"for",dates,sep=" ")
   }
   else { title <- custom_title }
}

for (j in 1:length(run_names)) {
   run_name <- run_names[j]
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name,species)
         aqdat_query.df   <- (sitex_info$sitex_data)
         aqdat_query.df   <- aqdat_query.df[with(aqdat_query.df,order(stat_id,ob_dates,ob_hour)),]
         units            <- as.character(sitex_info$units[[1]])
      }
      else {
         query_result    <- query_dbase(run_name,network,species)
         aqdat_query.df  <- query_result[[1]]
         units	      <- query_result[[3]]
      }
   }
   years     <- substr(aqdat_query.df$ob_dates,1,4)
   months    <- substr(aqdat_query.df$ob_dates,6,7)
   days      <- substr(aqdat_query.df$ob_dates,9,10)
   monthday  <- paste(months,days,sep="_")
   yearmonth <- paste(years,months,sep="_")
   aqdat_query.df$Year      <- years
   aqdat_query.df$YearMonth <- yearmonth
   aqdat_query.df$MonthDay  <- monthday

   total_days <- as.numeric(max(as.Date(aqdat_query.df$ob_datee))-min(as.Date(aqdat_query.df$ob_dates)))	# Calculate the total length, in days, of the period being plotted
   x.axis.min <- min(aqdat_query.df$month)	# Find the first month available from the query
   ob_col_name <- paste(species,"_ob",sep="")
   mod_col_name <- paste(species,"_mod",sep="")
   

   aqdat.df <- data.frame(network=aqdat_query.df$network,stat_id=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,ob_dates=aqdat_query.df$ob_dates,ob_day=days,ob_hour=aqdat_query.df$ob_hour,Obs_Value=aqdat_query.df[[ob_col_name]],Mod_Value=aqdat_query.df[[mod_col_name]],Month=sprintf("%02d",aqdat_query.df$month))
   {
      if (averaging == "n") {
         aqdat.df$Split_On <- aqdat_query.df$ob_dates
         date_title <- "Date (all times)"
      }
      if (averaging == "h") {
         aqdat.df$Split_On <- aqdat_query.df$ob_hour
         date_title <- "Hour of Day (LST)"
      }
      if (averaging == "md") {
         aqdat.df$Split_On <- aqdat_query.df$ob_day
         date_title <- "Day of Month"
      }
      if (averaging == "d") {
         aqdat.df$Split_On <- aqdat_query.df$MonthDay
         date_title <- "Month/Day"
      }
      if (averaging == "m") {
         aqdat.df$Split_On <- as.character(aqdat.df$Month)
         date_title <- "Month of Year"
      }
      if (averaging == "ym") {
         aqdat.df$Split_On <- aqdat_query.df$YearMonth
         date_title <- "Year/Month"
      }
      if (averaging == "a") {
         aqdat.df$Split_On <- aqdat_query.df$Year
         date_title <- "Annual"
      }
      if (averaging == "e") {
         aqdat.df$All      <- "All Data Points"
         aqdat.df$Split_On <- aqdat.df$All
         date_title <- "Entire Period"
      }
      if (averaging == "dow") {
         week_days               <- weekdays(as.Date(aqdat.df$ob_dates))
         aqdat.df$DayOfWeek      <- week_days
         aqdat.df$DayOfWeek      <- ordered(aqdat.df$DayOfWeek, levels=c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"))     
         aqdat.df$Split_On       <- aqdat.df$DayOfWeek
         date_title <- "Day of Week" 
      }
   }

   {
      if (j == 1) {
         aqdat_out.df          <- data.frame(Value=aqdat.df$Obs_Value,bin=aqdat.df$Split_On)
         aqdat_out.df$Sim      <- network
         data                  <- split(aqdat_out.df$Value,aqdat.df$Split_On)
         num_obs               <- lapply(data,length) 
         aqdat_temp            <- data.frame(Value=aqdat.df$Mod_Value,bin=aqdat.df$Split_On)
         aqdat_temp$Sim        <- run_names[1]
         aqdat_out.df          <- rbind(aqdat_temp,aqdat_out.df)
         bias                  <- aqdat.df$Mod_Value-aqdat.df$Obs_Value
         aqdat_out_bias.df     <- data.frame(Value=bias,bin=aqdat.df$Split_On)
         aqdat_out_bias.df$Sim <- run_name
         level_names           <- network
         data_to_write	       <- cbind(aqdat.df,bias)
         write.table(run_names[j],file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
         write.table(dates,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
         write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
         write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
         write.table(data_to_write,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
      }
      else {
         aqdat_temp          <- data.frame(Value=aqdat.df$Mod_Value,bin=aqdat.df$Split_On)
         aqdat_temp$Sim      <- run_names[j]
         bias                <- aqdat.df$Mod_Value-aqdat.df$Obs_Value
         aqdat_temp_bias     <- data.frame(Value=bias,bin=aqdat.df$Split_On)
         aqdat_temp_bias$Sim <- run_name
         aqdat_out.df        <- rbind(aqdat_temp,aqdat_out.df)
         aqdat_out_bias.df   <- rbind(aqdat_temp_bias,aqdat_out_bias.df)
         data_to_write       <- cbind(aqdat.df,bias)
         write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
         write.table(run_names[j],file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
         write.table(data_to_write,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
      }
   }
   level_names <- c(level_names,run_name)
   level_names_bias <- c(level_names_bias,run_name)
}

aqdat_out.df$Sim <- factor(aqdat_out.df$Sim, levels = level_names)
aqdat_out_bias.df$Sim <- factor(aqdat_out_bias.df$Sim, levels=level_names_bias)

main.title <- title
bias.title <- title_bias

bin_names <- as.character(names(split(aqdat_out.df$Value,aqdat.df$Split_On)))

xform <- list(title=date_title, categoryorder = "array", categoryarray = bin_names)


p <- plot_ly(aqdat_out.df, x=~bin, y = ~Value, height=img_height, width=img_width, color=~Sim, type="box", boxpoints=FALSE, boxmean="sd", colors=c("yellow3","green4","blue","darkorchid4")) %>% 
layout(boxmode = "group", title=main.title, yaxis=list(title=paste(species,"(",units,")")), xaxis=xform, showlegend=TRUE, annotations=list(x=bin_names,y=-1, text=num_obs, yshift=-15, align="center", valign="bottom", showarrow=FALSE))
saveWidget(p, file=filename_html,selfcontained=T)


p <- plot_ly(aqdat_out_bias.df, x=~bin, y = ~Value, height=img_height, width=img_width, color=~Sim, type="box", boxpoints=FALSE, boxmean="sd", colors=c("yellow3","green4","blue","darkorchid4")) %>%
layout(boxmode = "group", title=bias.title, yaxis=list(title=paste(species,"Bias (",units,")")), xaxis=xform, showlegend=TRUE, annotations=list(x=bin_names,y=-1, text=num_obs, yshift=-15, align="center", valign="bottom", showarrow=FALSE))
saveWidget(p, file=filename_bias_html,selfcontained=T)

