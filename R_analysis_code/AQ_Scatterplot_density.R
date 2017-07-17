################## MODEL TO OBS SCATTERPLOT #################### 
### AMET CODE: R_Scatterplot_density.r 
###
### This script is part of the AMET-AQ system.  This script creates
### a single model-to-obs scatterplot. This script will plot a
### single species from up to three networks on a single plot.  
### Additionally, summary statistics are also included on the plot.  
### The script will also allow a second run to plotted on top of the
### first run. 
###
### Last Updated by Wyat Appel: June, 2017
################################################################

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

### Set file names and titles ###
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(run_name1," ",species," for ",dates,sep="") }
   else { title <- custom_title }
}

filename_pdf <- paste(run_name1,species,pid,"scatterplot_density.pdf",sep="_")             # Set PDF filename
filename_png <- paste(run_name1,species,pid,"scatterplot_density.png",sep="_")             # Set PNG filename
filename_txt <- paste(run_name1,species,pid,"scatterplot_density.csv",sep="_")       # Set output file name

## Create a full path to file
filename_pdf <- paste(figdir,filename_pdf,sep="/")      # Set PDF filename
filename_png <- paste(figdir,filename_png,sep="/")      # Set PNG filenam
filename_txt <- paste(figdir,filename_txt,sep="/")      # Set output file name

#################################

axis.max      <- NULL
axis.min      <- NULL
number_bins   <- NULL
dens_zlim     <- NULL

### Retrieve units and model labels from database table ###
network <- network_names[1]
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql)
model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
model_name <- db_Query(model_name_qs,mysql)
model_name <- model_name[[1]]
units_convert <- 1
#if (units == "ppm") {
#   units_convert <- 1000
#   units <- "ppb"
#}
################################################

run_name <- run_name1
network <- network_names[[1]]						# Set network
criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")             # Set part of the MYSQL query
check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name1,"' and COLUMN_NAME = 'POCode';",sep="")
query_table_info.df <-db_Query(check_POCode,mysql)
{
   if (length(query_table_info.df$COLUMN_NAME)==0) {
      qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")      # Set the rest of the MYSQL query
      aqdat_query.df<-db_Query(qs,mysql)
      aqdat_query.df$POCode <- 1
   }
   else {      
      qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod,d.POCode from ",run_name," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")	# Set the rest of the MYSQL query
      aqdat_query.df<-db_Query(qs,mysql)
   }
}
aqdat_query.df[,9] <- aqdat_query.df[,9]*units_convert
aqdat_query.df[,10] <- aqdat_query.df[,10]*units_convert

################################################################################
### if plotting all obs, remove missing obs and zero precip obs if requested ###
################################################################################
if (remove_negatives == "y") {
   indic.nonzero <- aqdat_query.df[,9] >= 0                                                  # determine which obs are missing (less than 0); 
   aqdat_query.df <- aqdat_query.df[indic.nonzero,]                                                        # remove missing obs from dataframe
   indic.nonzero <- aqdat_query.df[,10] >= 0
   aqdat_query.df <- aqdat_query.df[indic.nonzero,]
}
#################################################################################

aqdat.df <- aqdat_query.df
aqdat.df <- data.frame(Network=aqdat.df$network,Stat_ID=aqdat.df$stat_id,lat=aqdat.df$lat,lon=aqdat.df$lon,Obs_Value=round(aqdat.df[,9],5),Mod_Value=round(aqdat.df[,10],5),Month=aqdat.df$month,precip_ob=aqdat.df$precip_ob)      # Create dataframe of network values to be used to create a list
         aqdat_stats.df <- aqdat.df

##############################
### Write Data to CSV File ###
##############################
write.table(run_name1,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
write.table(dates,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(aqdat_query.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
###############################

#######################################################
### If user sets axis maximum, compute axis minimum ###
#######################################################
axis.max <- max(c(axis.max,aqdat.df$Obs_Value,aqdat.df$Mod_Value))
axis.min <- axis.max * .033
if ((length(y_axis_max) > 0) || (length(x_axis_max) > 0)) {
   axis.max <- max(y_axis_max,x_axis_max)
   axis.min <- axis.max * 0.033
}
if ((length(y_axis_min) > 0) || (length(x_axis_min) > 0)) {
   axis.min <- min(y_axis_min,x_axis_min)
}
{
   if (length(num_dens_bins) > 0) {
      number_bins <- num_dens_bins
   }
   else { 
      number_bins <- 50 
   }
}
{  
   if (length(density_zlim) > 0) {
      dens_zlim <- c(0,density_zlim)
   }
   else { 
      dens_zlim <- NULL
   }
}
#######################################################

##############################################
########## MAKE SCATTERPLOT: ALL US ##########
##############################################
plot_chars <- c(1,2,3,4)                                 	# set vector of plot characters
pdf(file=filename_pdf,width=8,height=8)
plot.density.scatter.plot(x=aqdat.df$Obs_Value,y=aqdat.df$Mod_Value,xlim=c(axis.min,axis.max),ylim=c(axis.min,axis.max),zlim=dens_zlim,main=title,num.bins=number_bins)

### Convert pdf file to png file ###
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density 150x150 ",filename_pdf," png:",filename_png,sep="")
   dev.off()
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}
####################################
