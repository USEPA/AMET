################################################################
### AMET CODE: PLOT SPATIAL
###
### This code is part of the AMET-AQ system.  The Plot Spatial code
### takes a MYSQL database query for a single specie from one or more
### networks and plots the observation value, model value, and 
### difference between the model and ob for each site for each 
### corresponding network.  Mutiple values for a site are averaged
### to a single value for plotting purposes.  The map area plotted
### is dynamicall generated from the input data.   
###
### Last modified by Wyat Appel; December 6, 2012
###
### Modified to work with combined MET/AQ mode, Alexis Zubrow (IE UNC) Nov, 2007
###
################################################################

## get some environmental variables and setup some directories
ametbase<-Sys.getenv("AMETBASE")	# base directory of AMET
dbase<-Sys.getenv("AMET_DATABASE")      # AMET database
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
source (ametNetworkInput) # Network related input

## Load Required Libraries
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}
if(!require(maps)){stop("Required Package maps was not loaded")}
if(!require(mapdata)){stop("Required Package mapdata was not loaded")}

mysql <- list(login=login, passwd=passwd, server=server, dbase=dbase, maxrec=maxrec)           # Set MYSQL login and query options

### Retrieve units label from database table ###
network <- network_names[1]                                                                                                             # When using mutiple networks, units from network 1 will be used
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")        # Create MYSQL query from units table
units <- db_Query(units_qs,mysql)                                                                                                       # Query the database for units name
################################################

########################################
### Set NULL values and plot symbols ###
########################################
sinfo_obs       <- NULL						# Set list for obs values to NULL
sinfo_mod       <- NULL						# Set list for model values to NULL
sinfo_diff      <- NULL						# Set list for difference values to NULL
sinfo_rat	<- NULL
sinfo_obs_data  <- NULL
sinfo_mod_data  <- NULL
sinfo_diff_data <- NULL
sinfo_rat_data  <- NULL
diff_min        <- NULL
all_lats        <- NULL
all_lons        <- NULL
all_obs         <- NULL
all_mod         <- NULL
all_diff        <- NULL
all_rat	   	<- NULL
bounds          <- NULL						# Set map bounds to NULL
sub_title       <- NULL						# Set sub title to NULL
lev_lab         <- NULL
spch<-c(16,17,15,18,16)
spch2<-c(1,2,0,5,1)
symbols<-c("CIRCLE","TRIANGLE","SQUARE","DIAMOND","CIRCLE")
########################################

for (j in 1:total_networks) {							# Loop through for each network
   Mod_Obs_Diff   <- NULL							# Set model/ob difference to NULL
   network        <- network_names[[j]]						# Determine network name from loop value
   sub_title<-paste(sub_title,symbols[j],"=",network_label[j],"; ",sep="")	# Set subtitle based on network matched with the symbol name used for that network
   #########################
   ## Query the database ###
   #########################
   query <- paste(" and s.stat_id=d.stat_id and d.ob_dates BETWEEN",start_date,"and",end_date,"and d.ob_datee BETWEEN",start_date,"and",end_date,"and ob_hour between",start_hour,"and",end_hour,add_query,sep=" ")
   criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
   qs <- paste("SELECT d.network,d.stat_id,s.lat,s.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")                             # Set the rest of the MYSQL query
   aqdat_query.df<-db_Query(qs,mysql)							# Query the database
   #######################

   ## test that the query worked
   if (length(aqdat_query.df) == 0){
     ## error the queried returned nothing
     writeLines("ERROR: Check species/network pairing and Obs start and end dates")
     stop(paste("ERROR querying db: \n",qs))
   }

   ####################################
   ## Compute Averages for Each Site ##
   ####################################
   averaging <- "a"
   aqdat_in.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=round(aqdat_query.df[,9],5),Mod_Value=round(aqdat_query.df[,10],5),Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month,precip_ob=aqdat_query.df$precip_ob,precip_mod=aqdat_query.df$precip_mod)
   if (remove_negatives == "y") {
      indic.nonzero	<- aqdat_in.df$Mod_Value >= 0	# determine which obs are missing (less than 0); 
      aqdat_in.df	<- aqdat_in.df[indic.nonzero,]	# remove missing model values from dataframe (happens rarely)  
   }
   aqdat.df <- Average(aqdat_in.df)

   Mod_Obs_Diff <- aqdat.df$Mod_Value-aqdat.df$Obs_Value
   Mod_Obs_Rat  <- aqdat.df$Mod_Value/aqdat.df$Obs_Value
   aqdat.df$Mod_Obs_Diff <- Mod_Obs_Diff
   aqdat.df$Mod_Obs_Rat  <- Mod_Obs_Rat
   ####################################

   ##################################################
   ## Store values for each network in array lists ##
   ##################################################
   sinfo_obs_data[[j]]<-list(lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Obs_Value)
   sinfo_mod_data[[j]]<-list(lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Value)
   sinfo_diff_data[[j]]<-list(lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Obs_Diff)
   sinfo_rat_data[[j]]<-list(lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Obs_Rat)

   all_lats <- c(all_lats,aqdat.df$lat)
   all_lons <- c(all_lons,aqdat.df$lon)
   all_obs  <- c(all_obs,aqdat.df$Obs_Value)
   all_mod  <- c(all_mod,aqdat.df$Mod_Value)
   all_diff <- c(all_diff,aqdat.df$Mod_Obs_Diff)
   all_rat  <- c(all_rat,aqdat.df$Mod_Obs_Rat)
   ##################################################
   
}
#########################
## plot format options ##
#########################
bounds<-c(min(all_lats,bounds[1]),max(all_lats,bounds[2]),min(all_lons,bounds[3]),max(all_lons,bounds[4]))
plotsize<-1.50									# Set plot size
symb<-15										# Set symbol character
symbsiz<-0.9										# Set symbol size
if (length(unique(aqdat.df$stat_id)) > 500) {
   symbsiz <- 0.7
}
if (length(unique(aqdat.df$stat_id)) > 10000) {
   symbsiz <- 0.5
}
#########################

####################################################################
### Determine intervals  to use for plotting ob and model values ###
####################################################################
levs <- NULL
if (length(num_ints) == 0) {
   num_ints <- 10
}
intervals <- num_ints
{
   if ((length(abs_range_min) == 0) || (length(abs_range_max) == 0)) {
      levs <- pretty(c(0,all_obs,all_mod),intervals,min.n=5)
   }
   else {
      levs <- pretty(c(abs_range_min,abs_range_max),intervals,min.n=5)
   }
}
##########################################################################
### Code to create color palette that will be used throughout the code ###
##########################################################################
hot_colors      <- colorRampPalette(c("yellow","orange","firebrick"))
cool_colors     <- colorRampPalette(c("darkorchid4","blue","green"))
all_colors      <- colorRampPalette(c("darkorchid4","blue","green","yellow","orange","firebrick"))

### Extended color scale w/ additional colors ###
#hot_colors      <- colorRampPalette(c("palegoldenrod","yellow","orange","firebrick","burlywood4"))
#cool_colors     <- colorRampPalette(c("darkmagenta","darkorchid4","blue","green","darkolivegreen1"))
#all_colors      <- colorRampPalette(c("darkorchid4","blue","green","palegoldenrod","yellow","orange","firebrick","burlywood4"))

##########################################################################

#############################
### Create ob/model scale ###
#############################
levs_interval		<- (max(levs)-min(levs))/(length(levs)-1)
length_levs		<- length(levs)
levs_legend		<- c(levs,max(levs)+levs_interval)
leg_labels		<- levs
lev_lab 		<- levs
levs_max		<- length(levs)
leg_labels[levs_max]	<- paste("> ",max(levs),sep="")
leg_labels		<- c(leg_labels,"")
#levs_max <- length(levs)+1	# determine the final maximum number of levels
levs[levs_max+1] 	<- 10000		# set the level maximum to 1000 in order to include all values
colors 			<- NULL
colors			<- all_colors(levs_max)
leg_colors		<- colors
##############################


##########################
### Create Ratio Scale ###
##########################
levs_low <- seq(0,0.9,by=.1)	# Fix the scale from 0 to 1
cols_low <- cool_colors(10)	# Fix the colors from 0 to 1
if (length(perc_error_max) == 0) {	# Check to see if user defined max value
   perc_error_max <- quantile(abs(aqdat.df$Mod_Obs_Rat),0.95,na.rm=T)
}
high_range <- c(1,perc_error_max)	# Set hot color range from 1 to whatever
intervals <- num_ints
max_levs <- 21	# Set max levs to 21; this is done to prevent number overlap, but any number could be used here
while (max_levs > 20) {
   levs_high <- pretty(high_range,intervals,min.n=5)
   max_levs <- length(levs_high)
   intervals <- intervals-1
}
levs_interval                     <- max(levs_high)/(length(levs_high)-1)
length_levs_high                  <- length(levs_high)
levs_legend_high                  <- c(levs_high,max(levs_high)+levs_interval)
lev_lab_high                      <- levs_high
leg_labels_high                   <- levs_high
levs_high_max                     <- length(levs_high)
leg_labels_high[levs_high_max]    <- paste(">",max(levs_high))
leg_labels_high                   <- c(leg_labels_high,"")         # Label maximum level as greater than max defined value
levs_high[levs_high_max+1]        <- 100000                        # Set extreme absolute value to capture values > than defined max
levcols_high                      <- NULL
levcols_high                      <- hot_colors(length_levs_high)
leg_colors_high                   <- levcols_high
levcols_rat		          <- c(cols_low,leg_colors_high)
levs_legend_rat			  <- c(levs_low,leg_labels_high)
levs_rat			  <- c(levs_low,levs_legend_high)
leg_colors_rat			  <- levcols_rat
leg_labels_rat			  <- levs_legend_rat
############################################


#################################################
### Determine Color Scale for Difference Plot ###
#################################################
intervals <- num_ints
{
   if ((length(diff_range_min) == 0) || (length(diff_range_max) == 0)) {
      diff_max <- max(abs(all_diff))
      levs_diff <- pretty(c(-diff_max,diff_max),intervals,min.n=5)
      diff_range <- range(levs_diff)
      power <- abs(levs_diff[1]) - abs(levs_diff[2])
      if (abs(diff_range[1]) > diff_range[2]) {
         diff_range[2] <- abs(diff_range[1])
      }
      else {
         diff_range[1] <- -diff_range[2]
      }
   }
   else {
      levs_diff <- pretty(c(diff_range_min,diff_range_max),intervals,min.n=5)
      power <- abs(levs_diff[1]) - abs(levs_diff[2])
      diff_range <- range(levs_diff)
   }
   levs_diff <- signif(round(seq(diff_range[1],diff_range[2],power),5),2)
}
levs_interval				<- (max(levs_diff)-min(levs_diff))/(length(levs_diff)-1)
length_levs_diff			<- length(levs_diff)
levs_legend_diff			<- c(min(levs_diff)-levs_interval,levs_diff,max(levs_diff)+levs_interval)
leg_labels_diff				<- levs_diff
levels_label_diff			<- levs_diff
#levs_diff_max 				<- length(levs_diff)
leg_labels_diff[length_levs_diff]	<- paste(">",max(levs_diff))     # Label maximum level as greater than max defined value
leg_labels_diff				<- c(leg_labels_diff,"")        # Label maximum level as greater than max defined value 
leg_labels_diff				<- c("",leg_labels_diff)        # Label minimum level as less than max defined value
leg_labels_diff[2]			<- paste("<",min(levs_diff))	# Label minimum level as less than max defined value
levs_diff 				<- c(levs_diff,10000)		# Set extreme absolute value to capture all values
levs_diff 				<- c(-10000,levs_diff)		# Set extreme miniumum value to capture all values
zero_place 				<- which(levs_diff==0) 
levs_diff 				<- levs_diff[-zero_place]
levels_label_diff 			<- levels_label_diff[-zero_place]
levcols_diff 				<- NULL
low_range				<- cool_colors(trunc(length(levels_label_diff)/2))
high_range				<- hot_colors(trunc(length(levels_label_diff)/2))
levcols_diff 				<- c(low_range,"grey",high_range)
leg_colors_diff				<- c(low_range,"grey","grey",high_range)
#####################################################################

for (k in 1:j) {

   sinfo_obs[[k]]<-list(lat=sinfo_obs_data[[k]]$lat,lon=sinfo_obs_data[[k]]$lon,plotval=sinfo_obs_data[[k]]$plotval,levs=levs,levcols=colors,levs_legend=levs_legend,cols_legend=leg_colors,convFac=.01)			# Create list to be used with PlotSpatial function
   sinfo_mod[[k]]<-list(lat=sinfo_mod_data[[k]]$lat,lon=sinfo_mod_data[[k]]$lon,plotval=sinfo_mod_data[[k]]$plotval,levs=levs,levcols=colors,levs_legend=levs_legend,cols_legend=leg_colors,convFac=.01)			# Create model list to be used with PlotSpatial fuction
   sinfo_diff[[k]]<-list(lat=sinfo_diff_data[[k]]$lat,lon=sinfo_diff_data[[k]]$lon,plotval=sinfo_diff_data[[k]]$plotval,levs=levs_diff,levcols=levcols_diff,levs_legend=levs_legend_diff,cols_legend=leg_colors_diff,convFac=.01)	# Create diff list to be used with PlotSpatial fuction
   sinfo_rat[[k]]<-list(lat=sinfo_rat_data[[k]]$lat,lon=sinfo_rat_data[[k]]$lon,plotval=sinfo_rat_data[[k]]$plotval,levs=levs_rat,levcols=levcols_rat,levs_legend=levs_legend_rat,cols_legend=leg_colors_rat,convFac=.01)  # Create ratio list to be used with PlotSpatial fuction
}

###########################
### plot text options   ###
###########################
figure_obs	<-paste(run_name1,species,state,site,"spatialplot_OBS",sep="_")		# Filename for obs spatial plot
figure_mod	<-paste(run_name1,species,state,site,"spatialplot_MOD",sep="_")		# Filename for model spatial plot
figure_diff	<-paste(run_name1,species,state,site,"spatialplot_DIFF",sep="_")		# Filename for diff spatial plot
figure_rat	<-paste(run_name1,species,state,site,"spatialplot_RATIO",sep="_")         # Filename for diff spatial plot
figure_obs	<- paste(figdir,figure_obs, sep="/")  ## make full path
figure_mod	<- paste(figdir,figure_mod, sep="/")  ## make full path
figure_diff	<- paste(figdir,figure_diff, sep="/")  ## make full path
figure_rat	<- paste(figdir,figure_rat, sep="/")  ## make full path
{
   if (custom_title == "") {
      title_obs<-paste("Observed ",species, " for run ",run_name1," for ", start_date, "to",end_date, sep="")			# Title for obs spatial plot
      title_mod<-paste("Modeled ",species, " for run ",run_name1," for ", start_date, "to",end_date, sep="")				# Title for model spatial plot
      title_diff<-paste("Modeled - Observed ",species, " for run ",run_name1," for ", start_date, "to",end_date, sep="")		# Title for diff spatial plot
      title_rat<-paste("Modeled / Observed ",species, " for run ",run_name1," for ", start_date, "to",end_date, sep="")             # Title for diff spatial plot
   }
   else {
      title_obs  <- custom_title
      title_mod  <- custom_title
      title_diff <- custom_title
      title_rat <- custom_title
   }
}
###########################

##############################################
## Create PNG and PDF plots for NMB and NME ##
##############################################

### Plot Observations ###
unique_labels <- "y"												# Do not use unique labels
levLab <- leg_labels												# Unique label array to use
if ((plot_format == "png") || (plot_format == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_obs,figure=figure_obs,varlab=title_obs,bounds=bounds,plotopts=plotopts,plot_units=units)	# Call PlotSpatial function for obs values
}

if ((plot_format == "pdf") || (plot_format == "both")) {
   plotfmt <- "pdf"												# Set plot format as pdf
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_obs,figure=figure_obs,varlab=title_obs,bounds=bounds,plotopts=plotopts,plot_units=units)	# Call PlotSpatial function for ob values
}
#########################
### Plot Modeled Values ###
if ((plot_format == "png") || (plot_format == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_mod,figure=figure_mod,varlab=title_mod,bounds=bounds,plotopts=plotopts,plot_units=units)	# Call PlotSpatial function for model values
}

if ((plot_format == "pdf") || (plot_format == "both")) {
   plotfmt <- "pdf"												# Set plot format as pdf
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_mod,figure=figure_mod,varlab=title_mod,bounds=bounds,plotopts=plotopts,plot_units=units)   	# Call PlotSpatial function for model values
}
###########################
### Plot Model/Observation Difference ###
unique_labels <- "y"												# Flag within Misc_Functions.R to use predefined labels
levLab <- leg_labels_diff											# Set lables to be ones defined above by levels_label_diff

if ((plot_format == "png") || (plot_format == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz) 					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_diff,figure=figure_diff,varlab=title_diff,bounds=bounds,plotopts=plotopts,plot_units=units)	# Call PlotSpatial function for difference values
}

if ((plot_format == "pdf") || (plot_format == "both")) {
   plotfmt <- "pdf" 												# Set plot format as pdf
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_diff,figure=figure_diff,varlab=title_diff,bounds=bounds,plotopts=plotopts,plot_units=units)	# Call PlotSpatial function for difference values
}
#########################################
### Plot Model/Observation Ratio ###
unique_labels <- "y"                                                                                            # Flag within Misc_Functions.R to use predefined labels
levLab <- leg_labels_rat                                                                                       # Set lables to be ones defined above by levels_label_diff

if ((plot_format == "png") || (plot_format == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_rat,figure=figure_rat,varlab=title_rat,bounds=bounds,plotopts=plotopts,plot_units=units)   # Call PlotSpatial function for difference values
}

if ((plot_format == "pdf") || (plot_format == "both")) {
   plotfmt <- "pdf"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_rat,figure=figure_rat,varlab=title_rat,bounds=bounds,plotopts=plotopts,plot_units="None")   # Call PlotSpatial function for difference values
}
#########################################   
