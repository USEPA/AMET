header <- "
################## MODEL TO OBS BINNED SCATTERPLOT #################### 
### AMET CODE: R_Scatterplot_bins.r 
###
### This script is part of the AMET-AQ system.  This script creates
### a binned bias/RMSE plot. This script will create a binned bias/RMSE
### plot for a single species from a single network but for multiple   
### model runs. 
###
### Last Updated by Wyat Appel: June, 2017
########################################################################
"

## get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

library(plotly)
library(htmlwidgets)

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

### Retrieve units label from database table ###
network <- network_names[1]
#units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
################################################

### Set file names and titles ###
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") {
      main.title        <- paste(run_name1,species,"for",network_label[1],"for",dates,sep=" ")
      main.title.bias   <- paste(run_name1,species,"for",network_label[1],"for",dates,sep=" ")
   }
   else {
     main.title   <- custom_title
     main.title.bias <- custom_title
  }
}
sub.title       <- ""

filename_html <- paste(run_name1,species,pid,"scatterplot_bins.html",sep="_")                          # Set PDF filename
filename_png <- paste(run_name1,species,pid,"scatterplot_bins.png",sep="_")                          # Set PNG filenam
filename_txt <- paste(run_name1,species,pid,"scatterplot_bins.csv",sep="_")     # Set output file name

## Create a full path to file
filename_html <- paste(figdir,filename_html,sep="/")                          # Set PDF filename
filename_png <- paste(figdir,filename_png,sep="/")                          # Set PNG filenam
filename_txt <- paste(figdir,filename_txt,sep="/")     # Set output file name

axis.max     <- NULL
num_obs      <- NULL
sinfo        <- NULL
avg_text     <- ""
legend_names <- NULL
point_char   <- NULL
point_color  <- NULL
data_count   <- NULL
bin_names    <- NULL
################################################

run_names    <- run_name1		# Set default to just one run being plotted
legend_names <- NULL			# Set default for legend


{
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
}

num_obs      <- NULL
num_runs     <- length(run_names)
if ((network ==  "NADP_dep") || (network == "NADP_conc")) {
   species <- c(species,"precip")
}
for (j in 1:num_runs) {
   criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="") # Set part of the MYSQL query
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
         aqdat.df$Bias <- aqdat.df$Mod_Value - aqdat.df$Obs_Value
         aqdat.df$Err <- abs(aqdat.df$Mod_Value - aqdat.df$Obs_Value)
#         aqdat.df$RMSE <- aqdat.df$Mod_Value - aqdat.df$Obs_Value
         aqdat.df$Bin_Value <- aqdat.df$Obs_Value
         Mod_Obs_label <- "by Observed Value"
         if (bin_by_mod == 'y') {
            aqdat.df$Bin_Value <- aqdat.df$Mod_Value
            Mod_Obs_label <- "by Modeled Value"
         } 
         num_obs         <- NULL

         ###########################################
         ### Determine the interval range values ###
         ###########################################
         aqdat_temp.df <- aqdat.df
         if (length(x_axis_max) > 0) {
            indic.value <- aqdat.df$Bin_Value < x_axis_max
            aqdat_temp.df <- aqdat.df[indic.value,]
         }
         if (j == 1) {						# Only do this for first query
            bin_range_all <- pretty(c(0,quantile(aqdat_temp.df$Bin_Value,probs=0.999)),n=10)	# Determine a nice range to fit the obs
            interval <- bin_range_all[2]-bin_range_all[1]		# Determine the interval based on the range
            bin_range <- bin_range_all		
            if (length(bin_range_all) > 11) {
               bin_range <- bin_range_all[1:11]				# constrain plot to 11 intervals
            }
           num_intervals <- length(bin_range)
         }
         ##########################################
         for (n in 1:length(bin_range)) {            
            if (n != max(length(bin_range))) {
               if (j == 1) {
                  bin_names <- c(bin_names,paste(sprintf("%.02f",bin_range[n]),"to",sprintf("%.02f",bin_range[n+1])))
               }
               aqdat.df$bin[aqdat.df$Bin_Value >= bin_range[n] & aqdat.df$Bin_Value < bin_range[n+1]] <- paste(sprintf("%.02f",bin_range[n]),"to",sprintf("%.02f",bin_range[n+1]))
            }
            if (n == max(length(bin_range))) {
               if (j == 1) {
                  bin_names <- c(bin_names,paste(sprintf("%.02f",bin_range[n]),"+",sep=""))
               }
               aqdat.df$bin[aqdat.df$Bin_Value > bin_range[n]] <- paste(sprintf("%.02f",bin_range[n]),"+",sep="")
            }
         }
         data_count[[j]] <- table(factor(aqdat.df$bin, levels=bin_names))        
#         print(data_count[[j]]) 
#         sinfo[[j]] <- list(num_obs=num_obs,plotval_mb_q1=mb_q1_mod,plotval_mb_q3=mb_q3_mod,plotval_mb_median=mb_median,plotval_mb_mean=mb_mean,plotval_rmse_q1=rmse_q1_mod,plotval_rmse_q3=rmse_q3_mod,plotval_rmse_median=rmse_median,plotval_rmse_mean=rmse_mean)
      }	# End no data if/else statement
   }	# End enclosure of if/else statement
   ##############################
   ### Write Data to CSV File ###
   ##############################
#   aqdat_out.df <- aqdat.df
#   inc_error <- "n"
   if (j == 1) {
      aqdat_out.df     <- data.frame(Value=aqdat.df$Bias,bin=aqdat.df$bin)
      aqdat_out.df$Sim <- paste(run_names[j],"(Bias)")
      if (inc_error == "y") {
         aqdat_temp     <- data.frame(Value=aqdat.df$Err,bin=aqdat.df$bin)
         aqdat_temp$Sim <- paste(run_names[j],"(Error)")
         aqdat_out.df <- rbind(aqdat_temp,aqdat_out.df)
      }
      write.table(run_names[j],file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
      write.table(dates,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(sinfo[[j]],file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
   }
   else {
      aqdat_temp     <- data.frame(Value=aqdat.df$Bias,bin=aqdat.df$bin)
      aqdat_temp$Sim <- paste(run_names[j],"(Bias)")
      aqdat_out.df <- rbind(aqdat_temp,aqdat_out.df)
      if (inc_error == "y") {
         aqdat_temp     <- data.frame(Value=aqdat.df$Err,bin=aqdat.df$bin)
         aqdat_temp$Sim <- paste(run_names[j],"(Error)")
         aqdat_out.df <- rbind(aqdat_temp,aqdat_out.df)
      }
      write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(run_names[j],file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(sinfo[[j]],file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
   }
   ###############################
}	# End num_runs loop

xform <- list(title=paste("Bin Range (",units,") ",Mod_Obs_label,sep=""), categoryorder = "array", categoryarray = bin_names)

p <- plot_ly(aqdat_out.df, x=~bin, y = ~Value, height=img_height, width=img_width, color=~Sim, type = "box", colors=c("yellow3","green4","blue","darkorchid4")) %>%
     layout(boxmode = "group", title=main.title, yaxis=list(title=paste(species,"(",units,")")),xaxis=xform, showlegend=TRUE, annotations=list(x=0:(length(bin_range)-1),y=min(aqdat_out.df$Value), text=data_count[[1]], yshift=-15, align="center", valign="bottom", showarrow=FALSE))

saveWidget(p, file=filename_html,selfcontained=T)
