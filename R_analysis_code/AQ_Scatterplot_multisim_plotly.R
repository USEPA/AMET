header <- "
########################### MODEL TO OBS SCATTERPLOT ############################# 
### AMET CODE: R_Scatterplot_multisim_plotly.r 
###
### This script is part of the AMET-AQ system.  This script uses the plotly R package
### to create an interactive model-to-obs scatterplot. This script will plot a single 
### species from a single network and multiple simulations on a single plot.
###
### Last Updated by Wyat Appel: June 2025 
##################################################################################
"

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")	# R directory

## Load Required R Libraries
if(!require(plotly))              { stop("Required Package plotly was not loaded") 	}
if(!require(htmlwidgets))         { stop("Required Package htmlwidgets was not loaded") }

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Set output file names
filename_html <- paste(run_name1,species,pid,"scatterplot.html",sep="_")             # Set PDF filename
filename_txt  <- paste(run_name1,species,pid,"scatterplot.csv",sep="_")       # Set output file name

## Create a full path to output files
filename_html <- paste(figdir,filename_html,sep="/")      # Set PDF filename
filename_txt  <- paste(figdir,filename_txt,sep="/")      # Set output file name
#################################

## Set some defaults
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
main.title <- get_title(run_names,species,network_names,dates,custom_title,site=site,state=state,rpo=rpo,pca=pca,clim_reg=clim_reg)

###################################
### Set variable initial values ###
###################################
sinfo 		<- NULL
axis.max 	<- NULL
axis.min 	<- NULL
run_count 	<- 1
num_runs        <- 1
scatter_colors  <- NULL                                                                   # Set number of runs to 1
scatter_symbols <- NULL
run_names       <- run_name1               # Set default to just one run being plotted
legend_names    <- NULL                    # Set default for legend
###################################
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
         axis.max <- max(c(axis.max,aqdat.df$Obs_Value,aqdat.df$Mod_Value))
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
      }
      else {
         aqdat_out.df <- rbind(aqdat_out.df, aqdat.df)
      }
   }
   scatter_colors[j]  <- plot_colors[j]
   scatter_symbols[j] <- plot_symbols[j]
}    # End for loop for simulations

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

if (is.null(img_height)) { img_height <- 1250 }
if (is.null(img_width)) { img_width <- 1800 }
p <- plot_ly(data = aqdat_out.df, x=~Obs_Value,y=~Mod_Value,height=img_height,width=img_width,type='scatter',mode='markers',symbol=~Simulation,symbols=scatter_symbols,colors=scatter_colors,marker=list(size=10),text= ~paste("Site:",Stat_ID,"<br>Lat/Lon:",lat,"/",lon,"<br>State:",State,"<br>Obs:", round(Obs_Value,3), '<br>Mod:', round(Mod_Value,3))) %>%
   add_segments(x=0,xend=axis.max,y=0,yend=axis.max,size=I(0.5),line=list(color="black"))
p <- p %>% layout(plot_bgcolor='#e5ecf6',title=list(text=main.title,font=list(size=20),y=0.95,x=0.42),xaxis=list(title=network,titlefont=list(size=20),tickfont=list(size=15)),yaxis=list(title="Model Value",titlefont=list(size=20),tickfont=list(size=15)),legend=list(font=list(size=20))) 
saveWidget(p, file=filename_html,selfcontained=T)


