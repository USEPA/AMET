################## DENSITY SCATTERPLOT #################### 
### AMET CODE: R_Scatterplot_density.r 
###
### This script is part of the AMET-AQ system.  This script in a 
### variation of a scatter plot.  The script plots the points of a 
### scatter plot as different colors dependent on the denisty
### of the data at that x/y location.  The greater the density of
### points, the brigher the color.  This is useful when plotting
### a large number of points, as it makes it easy to identify
### where the largest number of points on the plot occur.  This
### script is new to the AMETv1.2 code and should be considered
### as a beta script, as it has not been fully tested.
###
### Last Updated by Wyat Appel; December 6, 2012
###
################################################################

## get some environmental variables and setup some directories
ametbase<-Sys.getenv("AMETBASE")	# base directory of AMET
dbase<-Sys.getenv("AMET_DATABASE")	# AMET database
ametR<-paste(ametbase,"/R",sep="")	# R directory
ametRinput <- Sys.getenv("AMETRINPUT")	# input file for this script
ametptype <- Sys.getenv("AMET_PTYPE")	# Prefered output type
   
## Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
## and not specified via AMET_OUT, then set figdir to the current directory
if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")       }
if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"                 }

## source some configuration files, AMET libs, and input
source(paste(ametbase,"/configure/amet-config.R",sep=""))
source (paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file
source (ametRinput)                                     # Anaysis configuration/input file
source (ametNetworkInput) 				# Network related input
   
## Load Required Libraries
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}
   
mysql <- list(login=login, passwd=passwd, server=server, dbase=dbase, maxrec=maxrec)           # Set MYSQL login and query options

### Set file names and titles ###
outname_pdf <- paste(run_name1,species,"scatterplot_density.pdf",sep="_")                               # Set PDF filename
outname_png <- paste(run_name1,species,"scatterplot_density.png",sep="_")                               # Set PNG filename
{
   if (custom_title == "") { title <- paste(run_name1," ",species," for ",start_date,end_date,sep=" ") }
   else { title <- custom_title }
}

## Create a full path to file
outname_pdf <- paste(figdir,outname_pdf,sep="/")
outname_png <- paste(figdir,outname_png,sep="/")

####################################################
#################################

axis.max      <- NULL
axis.min      <- NULL
num_bins      <- NULL
dens_zlim     <- NULL

### Retrieve units and model labels from database table ###
network <- network_names[1]
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql)
model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
model_name <- db_Query(model_name_qs,mysql)
model_name <- model_name[[1]]
################################################

run_name <- run_name1
network <- network_names[[1]]						# Set network
query <- paste(" and s.stat_id=d.stat_id and d.ob_dates BETWEEN", start_date, "and", end_date, "and d.ob_datee BETWEEN", start_date, "and", end_date, "and ob_hour between", start_hour, "and", end_hour, add_query,sep=" ")
criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")             # Set part of the MYSQL query
qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")      # Set the rest of the MYSQL query
aqdat_query.df<-db_Query(qs,mysql)							# Query the database and store in aqdat.df dataframe     

## test that the query worked
if (length(aqdat_query.df) == 0){
## error the queried returned nothing
   writeLines("ERROR: Check species/network pairing and Obs start and end dates")
   stop(paste("ERROR querying db: \n",qs))
}

################################################################################
### if plotting all obs, remove missing obs and zero precip obs if requested ###
################################################################################
if (remove_negatives == "y") {
   indic.nonzero <- aqdat_query.df[,9] >= 0                                                  # determine which obs are missing (less than 0); 
   aqdat_query.df <- aqdat_query.df[indic.nonzero,]                                                        # remove missing obs from dataframe
   indic.nonzero <- aqdat_query.df[,10] >= 0
   aqdat_query.df <- aqdat_query.df[indic.nonzero,]
}

#if ((network ==  "NADP_dep") || (network == "NADP_conc") && (zeroprecip == 'n')) {   # determine if using NADP data and removing 0 precip obs
if ((network ==  "NADP") && (zeroprecip == 'n')) {   # determine if using NADP data and removing 0 precip obs
   indic.noprecip <- aqdat.df$precip_ob > 0                                               # determine where precipitation obs are 0
   aqdat.df <- aqdat.df[indic.noprecip,]                                          # remove 0 precip pairs from dataframe
}
#################################################################################

aqdat.df <- aqdat_query.df
aqdat.df <- data.frame(Network=aqdat.df$network,Stat_ID=aqdat.df$stat_id,lat=aqdat.df$lat,lon=aqdat.df$lon,Obs_Value=round(aqdat.df[,9],5),Mod_Value=round(aqdat.df[,10],5),Month=aqdat.df$month,precip_ob=aqdat.df$precip_ob)      # Create dataframe of network values to be used to create a list
         aqdat_stats.df <- aqdat.df

##############################
### Write Data to CSV File ###
##############################
filename_txt <- paste(run_name1,species,"scatterplot_density.csv",sep="_")     # Set output file name
filename_txt <- paste(figdir,filename_txt, sep="/")  ## make full path
write.table(run_name1,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
write.table(t(c(start_date,end_date)),file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(aqdat_query.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
###############################

#######################################################
### If user sets axis maximum, compute axis minimum ###
#######################################################
if ((length(y_axis_max) > 0) || (length(x_axis_max) > 0)) {
   axis.max <- max(y_axis_max,x_axis_max)
   axis.min <- axis.max * 0.033
}
if ((length(y_axis_min) > 0) || (length(x_axis_min) > 0)) {
   axis.min <- min(y_axis_min,x_axis_min)
}
{
   if (length(num_density_bins) > 0) {
      num_bins <- num_density_bins
   }
   else { 
      num_bins <- 50 
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
pdf(file=outname_pdf,width=8,height=8)
plot.density.scatter.plot(x=aqdat.df$Obs_Value,y=aqdat.df$Mod_Value,xlim=c(axis.min,axis.max),ylim=c(axis.min,axis.max),zlim=dens_zlim,main=title,num.bins=num_bins)

####################################

### Process if PNG output requested ###
if (ametptype == "png") {
   ### Convert pdf format file to png format ###
   convert_command<-paste("convert -density 150x150 ",outname_pdf," ",outname_png,sep="")
   dev.off()
   system(convert_command)
   
#   ### Remove PDF ###
#   remove_command <- paste("rm ",outname_pdf,sep="")
#   system(remove_command)
}  
####################################
