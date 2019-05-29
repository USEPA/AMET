################## MODEL TO OBS SCATTERPLOT #################### 
### AMET CODE: R_Scatterplot.r 
###
### This script is part of the AMET-AQ system.  This script creates
### a single model-to-obs scatterplot. This script will plot a
### single species from up to three networks on a single plot.  
### Additionally, summary statistics are also included on the plot.  
### The script will also allow a second run to plotted on top of the
### first run. 
###
### Last Updated by Wyat Appel: June, 2018
################################################################

# get some environmental variables and setup some directories
library(plotly)
library(htmlwidgets)
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")	# R directory

#Sys.setenv("plotly_username"="kwappel")
#Sys.setenv("plotly_api_key"="wD4Ys6si30CVxyNfkl3N")

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

filename_html <- paste(run_name1,species,pid,"scatterplot.html",sep="_")             # Set PDF filename
filename_txt  <- paste(run_name1,species,pid,"scatterplot.csv",sep="_")       # Set output file name


## Create a full path to file
filename_html <- paste(figdir,filename_html,sep="/")      # Set PDF filename
filename_txt  <- paste(figdir,filename_txt,sep="/")      # Set output file name

#################################

sinfo 		<- NULL
axis.max 	<- NULL
axis.min 	<- NULL
run_count 	<- 1
num_runs        <- 1
scatter_colors  <- NULL                                                                   # Set number of runs to 1
scatter_symbols <- NULL
if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   num_runs <- 2                                                                # If so, set number of runs to 2
}
run_name <- run_name1
while (run_count <= num_runs) {
   source(ametRinput)
   total_networks <- length(network_names)
   for (j in 1:total_networks) {
      network <- network_names[[j]]                                             # Set network
      {
         if (Sys.getenv("AMET_DB") == 'F') {
            sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name,species)
            aqdat_query.df   <- sitex_info$sitex_data
            data_exists      <- sitex_info$data_exists
            if (data_exists == "y") { units <- as.character(sitex_info$units[[1]]) }
         }
         else {
            query_result   <- query_dbase(run_name,network,species)
            aqdat_query.df <- query_result[[1]]
            data_exists    <- query_result[[2]]
            if (data_exists == "y") { units <- query_result[[3]] }
            model_name     <- query_result[[4]]
         }
      }
      ob_col_name <- paste(species,"_ob",sep="")
      mod_col_name <- paste(species,"_mod",sep="")
      {
         if (data_exists == "n") {
            total_networks <- (total_networks-1)
            aqdat_query.df <- "No data from file or database query."
            if (total_networks == 0) { stop("Stopping because total_networks is zero. Likely no data found for query.") }
         }
         else {
            if (averaging != "n") {
               aqdat.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,State=aqdat_query.df$state,Obs_Value=round(aqdat_query.df[[ob_col_name]],5),Mod_Value=round(aqdat_query.df[[mod_col_name]],5),Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month)
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
               aqdat.df <- data.frame(Network=aqdat.df$network,Stat_ID=aqdat.df$stat_id,lat=aqdat.df$lat,lon=aqdat.df$lon,State=aqdat.df$state,Obs_Value=round(aqdat.df[[ob_col_name]],5),Mod_Value=round(aqdat.df[[mod_col_name]],5),Month=aqdat.df$month)      # Create dataframe of network values to be used to create a list
               aqdat_stats.df <- aqdat.df
            }
            axis.max <- max(c(axis.max,aqdat.df$Obs_Value,aqdat.df$Mod_Value))
            #########################################################
         }      # End no data if/else statement
      }
      ##############################
      ### Write Data to CSV File ###
      ##############################
      if (!file.exists(filename_txt)) {
         write.table(run_name,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
      }
      else {
         write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
         write.table(run_name,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      }
      write.table(dates,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(aqdat_query.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
      ###############################
      {
         if (j == 1) {
            aqdat_out.df <- aqdat.df
         }
         else {
            aqdat_out.df <- rbind(aqdat_out.df, aqdat.df)
         }
      }
      scatter_colors[j]  <- plot_colors[j]
      scatter_symbols[j] <- plot_symbols[j]
   }    # End for loop for networks
   run_count <- run_count+1
   run_name <- run_name2
}       # End while loop multiple runs

### Error check for no data ###
if (length(aqdat_out.df$Stat_ID) == 0) {
   stop("No data were returned from either files or database queries. Perhaps you have a error in your query setup.")
}
###############################

axis.min <- axis.max * .033

### If user sets axis maximum, compute axis minimum ###
if ((length(y_axis_max) > 0) || (length(x_axis_max) > 0)) {
   axis.max <- max(y_axis_max,x_axis_max)
   axis.min <- axis.max * 0.033

}
if ((length(y_axis_min) > 0) || (length(x_axis_min) > 0)) {
   axis.min <- min(y_axis_min,x_axis_min)
}
#######################################################


p <- plot_ly(data = aqdat_out.df, x=~Obs_Value,y=~Mod_Value,height=img_height,width=img_width,type='scatter',mode='markers',symbol=~Network,symbols=scatter_symbols,colors=scatter_colors,marker=list(size=10),text= ~paste("Site:",Stat_ID,"<br>Lat/Lon:",lat,"/",lon,"<br>State:",State,"<br>Obs:", round(Obs_Value,3), '<br>Mod:', round(Mod_Value,3))) %>%
   add_segments(x=0,xend=axis.max,y=0,yend=axis.max,size=I(0.5),line=list(color="black"))
  
#htmlwidgets::saveWidget(as_widget(p), filename_html)
saveWidget(p, file=filename_html,selfcontained=T)
#chart_link = api_create(p, filename="scatter-basic")
#chart_link


