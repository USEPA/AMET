header <- "
########################### HISTOGRAM PLOT (PLOTLY) #############################
### AMET CODE: R_Histogram_plotly.R
###
### This script is part of the AMET-AQ system.  This script uses the plotly R package
### to create an interactive histogram plot. This script will plot a single
### species from a single network and multiple simulations on a single plot.
###
### Last Updated by Wyat Appel: June 2025 
##################################################################################
"

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")	# R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Create file names
filename_html 		<- paste(run_name1,species,pid,"histogram.html",sep="_")             # Set PDF filename
filename_txt  		<- paste(run_name1,species,pid,"histogram.csv",sep="_")       # Set output file name

## Create a full path to file
filename_html 		<- paste(figdir,filename_html,sep="/")      # Set PDF filename
filename_txt  		<- paste(figdir,filename_txt,sep="/")      # Set output file name
#################################

## Load Required R Libraries
if(!require(plotly))            { stop("Required Package plotly was not loaded") 	}
if(!require(htmlwidgets))       { stop("Required Package htmlwidgets was not loaded") 	} 

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
main.title <- get_title(run_names,species,network_label,dates,custom_title,site=site,state=state,rpo=rpo,pca=pca,clim_reg=clim_reg)

run_count 	<- 1
num_runs        <- 1
run_names       <- run_name1               # Set default to just one run being plotted

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

network <- network_names[[1]]
num_runs <- length(run_names)
for (j in 1:num_runs) {
   run_name <- run_names[j]
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
         num_runs <- (num_runs-1)
         aqdat_query.df <- "No data from file or database query."
         if (num_runs == 0) { stop("Stopping because num_runs is zero. Likely no data found for query.") }
      }
      else {
         if (averaging != "n") {
            aqdat.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,State=aqdat_query.df$state,Obs_Value=round(aqdat_query.df[[ob_col_name]],5),Mod_Value=round(aqdat_query.df[[mod_col_name]],5),Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month)
            {
               if (use_avg_stats == "y") {
                  aqdat.df <- Average(aqdat.df)
#                  aqdat_stats.df <- aqdat.df                               # Call Monthly_Average function in Misc_Functions.R
               }
               else {
#                  aqdat_stats.df <- aqdat.df
                  aqdat.df <- Average(aqdat.df)
               }
            }
         }
         else {
            aqdat.df <- aqdat_query.df
            aqdat.df <- data.frame(Network=aqdat.df$network,Stat_ID=aqdat.df$stat_id,lat=aqdat.df$lat,lon=aqdat.df$lon,State=aqdat.df$state,Obs_Value=round(aqdat.df[[ob_col_name]],5),Mod_Value=round(aqdat.df[[mod_col_name]],5),Month=aqdat.df$month)      # Create dataframe of network values to be used to create a list
         }
         aqdat.df$Simulation <- run_name
         #########################################################
      }  # End no data if/else statement
   }
   ##############################
   ### Write Data to CSV File ###
   ##############################
   if ((j == 1) && (run_count == 1)){
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
         p <- plot_ly(data = aqdat.df, x=~Obs_Value,type='histogram',alpha=0.6,name=network)
	 p <- p %>% add_histogram(data=aqdat.df,x=~Mod_Value,name=run_name)
	 p <- p %>% add_histogram(data=aqdat.df,x=~(Mod_Value-Obs_Value),name=paste(run_name,"Bias"))
      }
      else {
         aqdat_out.df <- rbind(aqdat_out.df, aqdat.df)
         p <- p %>% add_histogram(data=aqdat.df,x=~Mod_Value,name=run_name)
	 p <- p %>% add_histogram(data=aqdat.df,x=~(Mod_Value-Obs_Value),name=paste(run_name,"Bias"))
      }
   }
}    # End for loop for simulations 

### Error check for no data ###
if (length(aqdat_out.df$Stat_ID) == 0) {
   stop("No data were returned from either files or database queries. Perhaps you have a error in your query setup.")
}
###############################

  p <- p %>% layout(title=list(text=main.title,font=list(size=25),y=0.97),barmode="overlay",xaxis=list(title=paste(species," (",units,")",sep=""),titlefont=list(size=20),tickfont=list(size=15)),yaxis=list(title="Frequency",titlefont=list(size=25),tickfont=list(size=15)),legend=list(font=list(size=20)))
#saveWidget(p, file=filename_html,selfcontained=T)

vline <- function(x = 0, color = "black") {
  list(
    type = "line",
    y0 = 0,
    y1 = 0.95,
    yref = "paper",
    x0 = x,
    x1 = x,
    line = list(color = color)
  )
}

  p <- p %>% layout(shapes=list(vline(0)),title=list(text=main.title,font=list(size=25),y=0.97),barmode="overlay",xaxis=list(title=paste(species," (",units,")",sep=""),titlefont=list(size=20),tickfont=list(size=15)),yaxis=list(title="Frequency",titlefont=list(size=25),tickfont=list(size=15)),legend=list(font=list(size=20)))
saveWidget(p, file=filename_html,selfcontained=T)

