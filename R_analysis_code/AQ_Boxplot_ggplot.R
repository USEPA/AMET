################################################################
### AMET CODE: BOX PLOT GGPlot
###
### This script is part of the AMET-AQ system.  It plots a box plot
### using ggplot2. Individual observation/model pairs are provided 
### through a MYSQL query. The script then plots these values as a box plot.
###
### Last updated by Wyat Appel: March, 2019
################################################################

## get some environmental variables and setup some directories
ametbase	<- Sys.getenv("AMETBASE")			# base directory of AMET
ametR		<- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

library(plotly)
library(htmlwidgets)

### Retrieve units label from database table ###
#units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
#units <- db_Query(units_qs,mysql) 
################################################

### Set file names and titles ###
network<-network_names[[1]]
level_names_bias <- NULL

filename_pdf		<- paste(run_name1,species,pid,"boxplot_ggplot.pdf",sep="_")
filename_bias_pdf	<- paste(run_name1,species,pid,"boxplot_bias_ggplot.pdf",sep="_")
filename_png            <- paste(run_name1,species,pid,"boxplot_ggplot.png",sep="_")
filename_bias_png       <- paste(run_name1,species,pid,"boxplot_bias_ggplot.png",sep="_")
filename_txt            <- paste(run_name1,species,pid,"boxplot_ggplot.csv",sep="_")

## Create a full path to file
filename_pdf            <- paste(figdir,filename_pdf,sep="/")
filename_pdf_bias       <- paste(figdir,filename_bias_pdf,sep="/")
filename_png            <- paste(figdir,filename_png,sep="/")
filename_png_bias       <- paste(figdir,filename_bias_png,sep="/")
filename_txt             <- paste(figdir,filename_txt,sep="/")

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
         data_exists      <- sitex_info$data_exists
         if (data_exists == "y") {
            aqdat_query.df   <- (sitex_info$sitex_data)
            aqdat_query.df   <- aqdat_query.df[with(aqdat_query.df,order(stat_id,ob_dates,ob_hour)),]
            units            <- as.character(sitex_info$units[[1]])
         }
      }
      else {
         query_result    <- query_dbase(run_name,network,species)
         aqdat_query.df  <- query_result[[1]]
         data_exists     <- query_result[[2]]
         if (data_exists == "y") { units <- query_result[[3]] }
      }
   }
   {
      if (data_exists == "n") {
         num_runs <- (num_runs-1)
         if (num_runs == 0) { stop("Stopping because num_runs is zero. Likely no data found for query.") }
      }
      else {
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
               data_to_write         <- cbind(aqdat.df,bias)
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
   }
}
aqdat_out.df$Sim <- factor(aqdat_out.df$Sim, levels = level_names)
aqdat_out_bias.df$Sim <- factor(aqdat_out_bias.df$Sim, levels=level_names_bias)

main.title <- title
bias.title <- title_bias

pdf(file=filename_pdf,width=9,height=9)
#sp<-ggplot(aqdat_out.df,aes(x=bin,y=Value,fill=Sim)) + geom_boxplot(position=position_dodge(0.8)) + theme(legend.position="top",plot.title=element_text(hjust=0.5)) + labs(title=title,x=date_title,y=paste(species,"(",units,")")) + scale_fill_manual(values=plot_colors) + scale_y_continuous(breaks = pretty(aqdat_out.df$Value, n = 10)) + guides(fill=guide_legend(nrow=2,byrow=TRUE))
sp<-ggplot(aqdat_out.df,aes(x=bin,y=Value,fill=Sim)) + geom_boxplot(position=position_dodge(0.8)) + theme(legend.justification=c(0,1), legend.position=c(0.02,0.98), legend.background=element_blank(), legend.key=element_blank(), plot.title=element_text(hjust=0.5)) + labs(title=title,x=date_title,y=paste(species,"(",units,")")) + scale_fill_manual(values=plot_colors) + scale_y_continuous(breaks = pretty(aqdat_out.df$Value, n = 10))
sp
dev.off()

if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_pdf," png:",filename_png,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}


pdf(file=filename_pdf_bias,width=9,height=9)
sp<-ggplot(aqdat_out_bias.df,aes(x=bin,y=Value,fill=Sim)) + geom_boxplot(position=position_dodge(0.8)) + theme(legend.justification=c(0,1), legend.position=c(0.02,0.98), legend.background=element_blank(), legend.key=element_blank(), plot.title=element_text(hjust=0.5)) + labs(title=bias.title,x=date_title,y=paste(species,"Bias (",units,")")) + geom_hline(yintercept=0,color="black") + scale_fill_manual(values=plot_colors[-1]) + scale_y_continuous(breaks = pretty(aqdat_out_bias.df$Value, n = 10))
sp
dev.off()

if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_pdf_bias," png:",filename_png_bias,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf_bias,sep="")
      system(remove_command)
   }
}
