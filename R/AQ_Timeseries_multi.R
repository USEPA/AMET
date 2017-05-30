################################################################
### AMET CODE: TIMESERIES PLOT
###
### This script is part of the AMET-AQ system.  It plots a timeseries 
### plot.  The script can accept multiple sites, as they will be
### time averaged to create the timeseries plot. However, unlike the
### standard AMET timeseries plotting script, this script accepts
### multiple networks but only a single simulation. For example,
### both IMPROVE and CSN sulfate data can be plotted on a single plot
### using this script. The script also plots the bias between the 
### obs and model.
###
### Last updated by Wyat Appel; December 6, 2012
###
################################################################


## get some environmental variables and setup some directories
ametbase<-Sys.getenv("AMETBASE")        # base directory of AMET
dbase<-Sys.getenv("AMET_DATABASE")      # AMET database
ametR<-paste(ametbase,"/R",sep="")      # R directory
ametRinput <- Sys.getenv("AMETRINPUT")  # input file for this script
ametptype <- Sys.getenv("AMET_PTYPE")   # Prefered output type

## Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
## and not specified via AMET_OUT, then set figdir to the current directory
if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")       }
if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"                 }

## source some configuration files, AMET libs, and input
source(paste(ametbase,"/configure/amet-config.R",sep=""))
source (paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file
source (ametRinput)                                     # Anaysis configuration/input file
source (ametNetworkInput) # Network related input

## Load Required Libraries
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}

mysql <- list(login=login, passwd=passwd, server=server, dbase=dbase, maxrec=maxrec)

### Retrieve units label from database table ###
network <- network_names[1]
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql)
################################################

main.title      <- paste(run_name1,species,"for",network,"Site:",site,sep=" ")
main.title.bias <- paste("Bias for",run_name1,species,"for",network,"Site:",site,sep=" ")
sub.title       <- ""

filename_pdf <- paste(run_name1,network,species,site,"timeseries_multi.pdf",sep="_")              # Set output file name
filename_png <- paste(run_name1,network,species,site,"timeseries_multi.png",sep="_")
filename_txt <- paste(run_name1,network,species,site,"timeseries_multi.csv",sep="_")
filename_pdf <- paste(figdir, filename_pdf, sep="/") ## make full path
filename_png <- paste(figdir, filename_png, sep="/") ## make full path
filename_txt <- paste(figdir, filename_txt, sep="/") ## make full path

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
   query <- paste(" and s.stat_id=d.stat_id and d.ob_dates BETWEEN",start_date,"and",end_date,"and d.ob_datee BETWEEN",start_date,"and",end_date,"and ob_hour between",start_hour,"and",end_hour,add_query,sep=" ")
   criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
   qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob from ",run_name," as d, site_metadata as s",criteria," ORDER BY ob_dates,ob_hour",sep="")
   aqdat_query.df<-db_Query(qs,mysql)							# Query the database
   aqdat.df <- data.frame(Network=aqdat_query.df$network,Stat_ID=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=aqdat_query.df[,9],Mod_Value=aqdat_query.df[,10],Hour=aqdat_query.df$ob_hour,Start_Date=I(aqdat_query.df[,5]),End_Date=I(aqdat_query.df[,6]),Month=aqdat_query.df$month,precip_ob=aqdat_query.df$precip_ob)
   ## test that the query worked
   if (length(aqdat_query.df) == 0){
     ## error the queried returned nothing
     writeLines("ERROR: Check species/network pairing and Obs start and end dates")
     stop(paste("ERROR querying db: \n",qs))
   }

   if (obs_per_day_limit > 0) {
      num_obs_value <- tapply(aqdat.df$Obs_Value,aqdat.df$Start_Date,function(x)sum(!is.na(x)))
      drop_days <- names(num_obs_value)[num_obs_value < obs_per_day_limit]
      aqdat_new.df <- subset(aqdat.df,!(Start_Date%in%drop_days))
      aqdat.df <- aqdat_new.df
   }

   ### Remove Missing Data ###
   indic.nonzero        <- aqdat.df$Obs_Value >= 0      # determine which obs are missing (less than 0); 
   aqdat.df             <- aqdat.df[indic.nonzero,]     # remove missing obs from dataframe
   indic.nonzero        <- aqdat.df$Mod_Value >= 0      # determine which obs are missing (less than 0); 
   aqdat.df             <- aqdat.df[indic.nonzero,]     # remove missing obs from dataframe
   ###########################

   Date_Hour            <- paste(aqdat.df$Start_Date," ",aqdat.df$Hour,":00:00",sep="") # Create unique Date/Hour field
   Date_Hour_Factor     <- factor(Date_Hour,levels=unique(Date_Hour))                   # Create unique levels so tapply maintains correct time order 
   aqdat.df$Date_Hour   <- Date_Hour                                                    # Add Date_Hour field to dataframe

   ### Calculate Obs and Model Means ###
   Obs_Period_Mean[[j]]	<- mean(aqdat.df$Obs_Value)
   Mod_Period_Mean[[j]]	<- mean(aqdat.df$Mod_Value)
   Obs_Mean[[j]]	<- tapply(aqdat.df$Obs_Value,Date_Hour_Factor,mean,na.rm=T)
   Mod_Mean[[j]]	<- tapply(aqdat.df$Mod_Value,Date_Hour_Factor,mean,na.rm=T)
   if (use_var_mean == "y") {
      Obs_Mean[[j]]	<- Obs_Mean[[j]] - Obs_Period_Mean[[j]]
      Mod_Mean[[j]]	<- Mod_Mean[[j]] - Mod_Period_Mean[[j]]
   }
   Bias_Mean[[j]]	<- Mod_Mean[[j]]-Obs_Mean[[j]]
   Dates[[j]]		<- as.POSIXct(unique(aqdat.df$Date_Hour))
   if (averaging == "d") {
      Obs_Mean[[j]]        <- tapply(aqdat.df$Obs_Value,aqdat.df$Start_Date,mean,na.rm=T)
      Mod_Mean[[j]]        <- tapply(aqdat.df$Mod_Value,aqdat.df$Start_Date,mean,na.rm=T)
      Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
      Dates[[j]]           <- as.POSIXct(unique(aqdat.df$Start_Date))
   }
   if (averaging == "h") {
      Obs_Mean[[j]]        <- tapply(aqdat.df$Obs_Value,aqdat.df$Hour,mean,na.rm=T)
      Mod_Mean[[j]]        <- tapply(aqdat.df$Mod_Value,aqdat.df$Hour,mean,na.rm=T)
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
   write.table(run_name1,file=filename_txt,append=T,row.names=F,sep=",")	# Write header for raw data file
   write.table(All_Data.df,file=filename_txt,append=T,row.names=F,sep=",")	# Write raw data to csv file
   ########################################
}	# End For Loop

### Calculate some values for plot formatting ###
#num_sites[j]	<- length(unique(aqdat.df$Stat_ID))
range		<- ymax-ymin
ymax		<- ymax+(0.3*range)
bias_range	<- bias_max-bias_min
bias_max	<- bias_max+(0.3*bias_range)

if (length(y_axis_max) > 0) {
   ymax		<- y_axis_max
   bias_max	<- y_axis_max
#   bias_max	<- 25
}
if (length(y_axis_min) > 0) {
   ymin		<- y_axis_min
   bias_min	<- y_axis_min
#   bias_min	<- -5
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
   if (state != "All") {
      text(max(Dates[[1]]),bias_max*.76,paste("State: ",state,sep=""),pos=2,cex=.8)
   }
   if (site != "All") {
      text(max(Dates[[1]]),bias_max*.90,paste("Site: ",site,sep=""),pos=2,cex=.8)
   } 
}

### Process if PNG output requested ###
if (ametptype == "png") {
   ### Convert pdf format file to png format ###
   convert_command<-paste("convert -density 150x150 ",filename_pdf," ",filename_png,sep="")
   dev.off()
   system(convert_command)

#   ### Remove PDF ###
#   remove_command <- paste("rm ",outname_pdf,sep="")
#   system(remove_command)
}
####################################
