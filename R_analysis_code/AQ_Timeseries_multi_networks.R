###############################################################
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
ametbase        <- Sys.getenv("AMETBASE") 	    	        # base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

### Retrieve units label from database table ###
network <- network_names[1]
#units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
#model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
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

filename_pdf <- paste(run_name1,species,pid,"timeseries.pdf",sep="_")
filename_png <- paste(run_name1,species,pid,"timeseries.png",sep="_")
filename_txt <- paste(run_name1,species,pid,"timeseries.csv",sep="_")

## Create a full path to file
filename_pdf    <- paste(figdir,filename_pdf,sep="/")           # Filename for timeseries pdf plot
filename_png    <- paste(figdir,filename_png,sep="/")           # Filename for timeseries png plot
filename_txt    <- paste(figdir,filename_txt,sep="/")           # Filename for csv data file

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
num_sites	<- NULL

run_name <- run_name1
labels <- c(network,run_name)

write.table("Time Series Data",file=filename_txt,append=F,row.names=F,sep=",")                       # Write header for raw data file

for (j in 1:total_networks) {	# For each simulation being plotted
   network <- network_names[j]
   #############################################
   ### Read sitex file or query the database ###
   #############################################
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name,species)
         aqdat_query.df   <- sitex_info$sitex_data
         data_exists      <- sitex_info$data_exists
         if (data_exists == "y") { units <- as.character(sitex_info$units[[1]]) }
      }
      else {
         query_result    <- query_dbase(run_name,network,species,orderby=c("ob_dates","ob_hour"))
         aqdat_query.df  <- query_result[[1]]
         aqdat_query.df  <- query_result[[2]]
         if (data_exists == "y") { units <- query_result[[3]] }
         model_name      <- query_result[[4]]
      }
   }
   ob_col_name <- paste(species,"_ob",sep="")
   mod_col_name <- paste(species,"_mod",sep="")
   #############################################

#   aqdat_query.df <- query_dbase(run_name,network,species,orderby=c("ob_dates","ob_hour"))
   aqdat.df <- data.frame(Network=aqdat_query.df$network,Stat_ID=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=aqdat_query.df[[ob_col_name]],Mod_Value=aqdat_query.df[[mod_col_name]],Hour=aqdat_query.df$ob_hour,Start_Date=I(aqdat_query.df[,5]),End_Date=I(aqdat_query.df[,6]),Month=aqdat_query.df$month)

   Date_Hour            <- paste(aqdat.df$Start_Date," ",aqdat.df$Hour,":00:00",sep="") # Create unique Date/Hour field
   Date_Hour_Factor     <- factor(Date_Hour,levels=unique(Date_Hour))                   # Create unique levels so tapply maintains correct time order 
   aqdat.df$Date_Hour   <- Date_Hour                                                    # Add Date_Hour field to dataframe

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
   if (use_var_mean == "y") {
      Obs_Mean[[j]]	<- Obs_Mean[[j]] - Obs_Period_Mean[[j]]
      Mod_Mean[[j]]	<- Mod_Mean[[j]] - Mod_Period_Mean[[j]]
   }
   Bias_Mean[[j]]	<- Mod_Mean[[j]]-Obs_Mean[[j]]
   Dates[[j]]		<- as.POSIXct(unique(aqdat.df$Date_Hour))
   if (averaging == "d") {
      Obs_Mean[[j]]        <- tapply(aqdat.df$Obs_Value,aqdat.df$Start_Date,centre,type=avg_func)
      Mod_Mean[[j]]        <- tapply(aqdat.df$Mod_Value,aqdat.df$Start_Date,centre,type=avg_func)
      Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
      Dates[[j]]           <- as.POSIXct(unique(aqdat.df$Start_Date))
   }
   if (averaging == "h") {
      Obs_Mean[[j]]        <- tapply(aqdat.df$Obs_Value,aqdat.df$Hour,centre,type=avg_func)
      Mod_Mean[[j]]        <- tapply(aqdat.df$Mod_Value,aqdat.df$Hour,centre,type=avg_func)
      Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
      Dates[[j]]           <- unique(aqdat.df$Hour)
      x_label		   <- "Hour (LST)"
   }
   Num_Obs[[j]]		<- length(aqdat.df$Obs_Value)
   num_sites[[j]]    <- length(unique(aqdat.df$Stat_ID))
   ymin			<- min(ymin,Obs_Mean[[j]], Mod_Mean[[j]])
   ymax			<- max(ymax,Obs_Mean[[j]], Mod_Mean[[j]])
   bias_min		<- min(bias_min,Bias_Mean[[j]])
   bias_max		<- max(bias_max,Bias_Mean[[j]])
   All_Data.df		<- data.frame(Date=Dates[[j]],Obs_Average=Obs_Mean[[j]],Model_Average=Mod_Mean[[j]],Bias_Average=Bias_Mean[[j]])
   #####################################

   ### Write data to be plotted to file ###
   write.table(network,file=filename_txt,append=T,row.names=F,sep=",")	# Write header for raw data file
   write.table(All_Data.df,file=filename_txt,append=T,row.names=F,sep=",")	# Write raw data to csv file
   ########################################
}	# End For Loop

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
par(cex.axis=1,las=1,mfg=c(1,1))
plot(Dates[[1]],Mod_Mean[[1]], axes=TRUE, ylim=c(ymin,ymax),type='l',ylab=paste(species,"(",units,")",sep=" "),xlab=x_label,lty=1,col=plot_colors[1],cex=.7, xaxt="n")  # Plot model data
if (length(Mod_Mean[[1]]) < 124) {
   points(Dates[[1]],Mod_Mean[[1]],col=plot_colors[[1]])
}
{
   if (averaging == "h") {
      axis(side=1, at=Dates[[1]])
   }
   else {
      axis.POSIXct(side=1, at=Dates[[1]],format="%b %d")
   }
}
lines(Dates[[1]],Obs_Mean[[1]],col="black",lty=1)
if (length(Mod_Mean[[1]]) < 124) {
   points(Dates[[1]],Obs_Mean[[1]],col="black")
}
legend_names	<- c(network_label[1],paste(run_name," (",network_label[1],")",sep=""))
legend_colors	<- c("black",plot_colors[1])
legend_linetype <- 1

if (total_networks > 1) {
   for (k in 2:total_networks) {
      lines(Dates[[k]],Obs_Mean[[k]],col="green3",lty=1)
      lines(Dates[[k]],Mod_Mean[[k]],col=plot_colors[k],lty=1)
      if (length(Mod_Mean[[1]]) < 124) {
         points(Dates[[k]],Obs_Mean[[k]],col="green3")
         points(Dates[[k]],Mod_Mean[[k]],col=plot_colors[k],lty=1)
      }
      legend_names	<- c(legend_names,network_label[k],paste(run_name," (",network_label[k],")",sep=""))
      legend_colors	<- c(legend_colors,"green",plot_colors[k])
      legend_linetype	<- c(1,1)
      if (Num_Obs[[k]] != Num_Obs[[1]]) {
         num_diff <- abs(Num_Obs[[k]]-Num_Obs[[1]])
         sub.title <- paste("Warning: Number of observations differ by",num_diff,"between simulations",sep=" ")
      }
   }   
}

text(max(Dates[[1]]),ymax,paste("# of ",network_names[1]," Sites: ",num_sites[1],sep=""),cex=1,adj=c(1,1))
if (total_networks > 1) {
   text(max(Dates[[1]]),(ymax-(0.10*(ymax-ymin))),paste("# of ",network_names[2]," Sites: ",num_sites[2],sep=""),cex=1,adj=c(1,1))
}
legend("topleft",legend=legend_names,col=legend_colors,lty=c(1,1,1,1), merge=TRUE,cex=1, bty='n')  # Add legend
title(main=main.title, sub=sub.title, cex.sub = 0.75, col.sub = "red")
######################################

if (run_info_text == "y") {
   if (rpo != "None") {
      text(max(Dates[[1]]),ymax*.90,paste("RPO: ",rpo,sep=""),pos=2,cex=.8)
   }
   if (pca != "None") {
      text(max(Dates[[1]]),ymax*.83,paste("PCA: ",pca,sep=""),pos=2,cex=.8)
   }
   if (state != "All") {
      text(max(Dates[[1]]),ymax*.76,paste("State: ",state,sep=""),pos=2,cex=.8)
   }
   if (site != "All") {
      text(max(Dates[[1]]),ymax*.90,paste("Site: ",site,sep=""),pos=2,cex=.8)
   }
}

###################################
### Plot Model Bias Time Series ###
###################################
par(new=T)
par(mfg=c(2,1))
plot(Dates[[1]],Bias_Mean[[1]], axes=TRUE, ylim=c(bias_min,bias_max),type='l',ylab=paste(species,"(",units,")",sep=" "),xlab=x_label,lty=1,col=plot_colors[1],cex=.7, xaxt="n")  # Plot model data
if (length(Bias_Mean[[1]]) < 124) {
   points(Dates[[1]],Bias_Mean[[1]],col=plot_colors[1])
}
{
   if (averaging == "h") {
      axis(side=1, at=Dates[[1]])
   }
   else {
      axis.POSIXct(side=1, at=Dates[[1]],format="%b %d")
   }
}
legend_names <- paste(run_name," (",network_names[1],")",sep="")
legend_colors <- plot_colors[1]

if (total_networks > 1) {
   for (k in 2:total_networks) {
      lines(Dates[[k]],Bias_Mean[[k]],col=plot_colors[k],lty=1)
      if (length(Bias_Mean[[1]]) < 124) {
         points(Dates[[k]],Bias_Mean[[k]],col=plot_colors[k])
      }
      legend_names <- c(legend_names,paste(run_name," (",network_names[k],")",sep=""))
      legend_colors <- c(legend_colors,plot_colors[k])
   }
}

abline(h=0,col="black")
usr <- par("usr")
text(max(Dates[[1]]),bias_max,paste("# of ",network_names[1]," Sites: ",num_sites[1],sep=""),cex=1,adj=c(1,1))
if (total_networks > 1) {
   text(max(Dates[[1]]),(bias_max-(0.10*(bias_max-bias_min))),paste("# of ",network_names[2]," Sites: ",num_sites[2],sep=""),cex=1,adj=c(1,1))
}
legend("topleft",legend=legend_names,col=legend_colors,lty=c(1,1,1), merge=TRUE,cex=1, bty='n')  # Add legend
title(main=main.title.bias, sub=sub.title, cex.sub = 0.75, col.sub = "red")
###################################

if (run_info_text == "y") {
   if (rpo != "None") {
      text(max(Dates[[1]]),bias_max*.90,paste("RPO: ",rpo,sep=""),pos=2,cex=.8)
   }
   if (pca != "None") {
      text(max(Dates[[1]]),bias_max*.83,paste("PCA: ",pca,sep=""),pos=2,cex=.8)
   }
   if (state != "All") {
      text(max(Dates[[1]]),bias_max*.76,paste("State: ",state,sep=""),pos=2,cex=.8)
   }
   if (site != "All") {
      text(max(Dates[[1]]),bias_max*.90,paste("Site: ",site,sep=""),pos=2,cex=.8)
   } 
}

### Create PNG Plot ###
dev.off()
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_pdf," png:",filename_png,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}
#######################

