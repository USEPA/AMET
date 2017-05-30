##################### PLOT SPATIAL DIFF #########################
### AMET CODE: AQ_Plot_Spatial_Diff.R
###
### This code is part of the AMET-AQ system.  The Plot Spatial code
### takes a MYSQL database query for a single species from one or more
### networks and plots the minimum, maximum and average difference between
### two model simulations at each site location for each network.  
### Mutiple values for a site are averaged to a single value for 
### plotting purposes.  The map area plotted is dynamically generated 
### from the input data.   
###
### Last modified by Wyat Appel; December 6, 2012   
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
sinfo_bias_1		<- NULL						# Set list for obs values to NULL
sinfo_bias_2		<- NULL						# Set list for model values to NULL
sinfo_bias_diff		<- NULL						# Set list for difference values to NULL
sinfo_error_1		<- NULL                                         # Set list for obs values to NULL
sinfo_error_2		<- NULL                                         # Set list for model values to NULL
sinfo_error_diff	<- NULL                                         # Set list for difference values to NULL
sinfo_bias_1_data	<- NULL
sinfo_bias_2_data	<- NULL
sinfo_bias_diff_data	<- NULL
sinfo_error_1_data	<- NULL
sinfo_error_2_data	<- NULL
sinfo_error_diff_data	<- NULL
diff_min        <- NULL
all_lats        <- NULL
all_lons        <- NULL
all_bias	<- NULL
all_error	<- NULL
all_bias_diff	<- NULL
all_error_diff	<- NULL
bounds          <- NULL						# Set map bounds to NULL
sub_title       <- NULL						# Set sub title to NULL
lev_lab         <- NULL
spch<-c(16,17,15,18,16)
spch2<-c(1,2,0,5,1)
symbols<-c("CIRCLE","TRIANGLE","SQUARE","DIAMOND","CIRCLE")
########################################

for (j in 1:total_networks) {							# Loop through for each network
   sites          	<- NULL							# Set sites vector to NULL
   lats          	<- NULL							# Set lats vector to NULL
   lons          	<- NULL							# Set lons vector to NULL
   mod_bias_1_all	<- NULL							# Set obs average to NULL
   mod_bias_2_all	<- NULL							# Set model average to NULL
   bias_diff		<- NULL							# Set model/ob difference to NULL
   mod_error_1_all   	<- NULL                                                 # Set obs average to NULL
   mod_error_2_all   	<- NULL                                                 # Set model average to NULL
   error_diff    	<- NULL
   network_number 	<- j							# Set network number to loop value
   network        	<- network_names[[j]]					# Determine network name from loop value
   sub_title<-paste(sub_title,symbols[j],"=",network_label[j],"; ",sep="")	# Set subtitle based on network matched with the symbol name used for that network
   query <- paste(" and s.stat_id=d.stat_id and d.ob_dates BETWEEN",start_date,"and",end_date,"and d.ob_datee BETWEEN",start_date,"and",end_date,"and ob_hour between",start_hour,"and",end_hour,add_query,sep=" ") 
   criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
   qs1       <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,DATE_FORMAT(d.ob_dates,'%Y%m%d'),DATE_FORMAT(d.ob_datee,'%Y%m%d'),d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod,precip_ob,precip_mod from ",run_name1," as d, site_metadata as s",criteria," ORDER BY stat_id,ob_dates",sep="")	# Secord part of MYSQL query for run name 1
   qs2       <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,DATE_FORMAT(d.ob_dates,'%Y%m%d'),DATE_FORMAT(d.ob_datee,'%Y%m%d'),d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod,precip_ob,precip_mod from ",run_name2," as d, site_metadata as s",criteria," ORDER BY stat_id,ob_dates",sep="")	# Secord part of MYSQL query for run name 1

   aqdat1.df <- db_Query(qs1,mysql)     # query database for 1st run
   ## test that the query worked
   if (length(aqdat1.df) == 0){
     ## error the queried returned nothing
     writeLines("ERROR: Check species/network pairing and Obs start and end dates")
     stop(paste("ERROR querying db: \n",qs))
   }

   aqdat2.df <- db_Query(qs2,mysql)     # query database for 2nd run
   ## test that the query worked
   if (length(aqdat2.df) == 0){
     ## error the queried returned nothing
     writeLines("ERROR: Check species/network pairing and Obs start and end dates")
     stop(paste("ERROR querying db: \n",qs))
   }

   aqdat1.df$ob_dates <- aqdat1.df[,5]          # remove hour,minute,second values from start date (should always be 000000 anyway, but could change)
   aqdat2.df$ob_dates <- aqdat2.df[,5]          # remove hour,minute,second values from start date (should always be 000000 anyway, but could change)

   ### Match the points between each of the runs.  This is necessary if the data from each query do not match exactly ###
   aqdat1.df$statdate<-paste(aqdat1.df$stat_id,aqdat1.df$ob_dates,aqdat1.df$ob_hour,sep="")     # Create unique column that combines the site name with the ob start date for run 1
   aqdat2.df$statdate<-paste(aqdat2.df$stat_id,aqdat2.df$ob_dates,aqdat2.df$ob_hour,sep="")     # Create unique column that combines the site name with the ob start date for run 2
   if (length(aqdat1.df$statdate) <= length(aqdat2.df$statdate)) {                              # If more obs in run 1 than run 2
      match.ind<-match(aqdat1.df$statdate,aqdat2.df$statdate)                                   # Match the unique column (statdate) between the two runs
      aqdat.df<-data.frame(network=aqdat1.df$network, stat_id=aqdat1.df$stat_id, lat=aqdat1.df$lat, lon=aqdat1.df$lon, ob_dates=aqdat1.df$ob_dates, Mod_Value_1=aqdat1.df[,10], Mod_Value_2=aqdat2.df[match.ind,10], Ob_Value_1=aqdat1.df[,9], Ob_Value_2=aqdat2.df[match.ind,9], month=aqdat1.df$month, precip_ob=aqdat1.df$precip_ob, precip_mod=aqdat1.df$precip_mod)      # eliminate points that are not common between the two runs

   }
   else { match.ind<-match(aqdat2.df$statdate,aqdat1.df$statdate)                               # If more obs in run 2 than run 1
      aqdat.df<-data.frame(network=aqdat2.df$network, stat_id=aqdat2.df$stat_id, lat=aqdat2.df$lat, lon=aqdat2.df$lon, ob_dates=aqdat2.df$ob_dates, Mod_Value_1=aqdat1.df[match.ind,10], Mod_Value_2=aqdat2.df[,10], Ob_Value_1=aqdat1.df[match.ind,9], Ob_Value_2=aqdat2.df[,9], month=aqdat2.df$month, precip_ob=aqdat2.df$precip_ob, precip_mod=aqdat2.df$precip_mod)      # eliminate points that are not common between the two runs
   }
   #######################

   split_sites_all  <- split(aqdat.df, aqdat.df$stat_id)				# Split all data by site
   for (i in 1:length(split_sites_all)) {                     				# Run averaging for each site for each month
      sub_all.df  <- split_sites_all[[i]]						# Store current site i in sub_all.df dataframe
      num_total_obs <- length(sub_all.df[,9])					# Count the total number of obs available for the site
      num_good_obs <- 0								# Set number of good obs to 0
      for (k in 1:length(sub_all.df[,9])) { 						# Count the number of non-missing obs (good obs)
         if (sub_all.df[k,9] >= -90) {							# If ob value is >= 0, count as good
            num_good_obs <- num_good_obs+1						# Increment good ob count by one
         }
      }
      coverage <- (num_good_obs/num_total_obs)*100					# Compute coverage value for good_obs/total_obs
      if (coverage >= coverage_limit) {  						# determine if the number of non-missing obs is >= to the coverage limit
         indic.nonzero <- sub_all.df[,6] >= -90						# Identify good obs in dataframe
         sub_good.df <- sub_all.df[indic.nonzero,]					# Update dataframe to only include good obs (remove missing obs)
         indic.nonzero <- sub_good.df[,7] >= -90
         sub_good.df <- sub_good.df[indic.nonzero,]
         indic.nonzero <- sub_good.df[,8] >= -90
         sub_good.df <- sub_good.df[indic.nonzero,] 
         sites        <- c(sites, unique(sub_good.df$stat_id))					# Add current site to site list	
         lats         <- c(lats, unique(sub_good.df$lat))					# Add current lat to lat list
         lons         <- c(lons, unique(sub_good.df$lon))					# Add current lon to lon list
         mod_bias_1     <- mean(sub_good.df$Mod_Value_1-sub_good.df$Ob_Value_1)  		# Compute the site mean bias for simulation 1
         mod_bias_2     <- mean(sub_good.df$Mod_Value_2-sub_good.df$Ob_Value_2)  		# Compute the site mean bias for simulation 2
         mod_bias_1_all <- c(mod_bias_1_all, mod_bias_1)  					# Store site bias for simulation 1 in an array
         mod_bias_2_all <- c(mod_bias_2_all, mod_bias_2)  					# Store site bias for simulation 2 in an array
         bias_diff      <- c(bias_diff, (abs(mod_bias_1)-abs(mod_bias_2)))			# Compute difference in site mean bias between two simulations
         mod_error_1    <- mean(abs(sub_good.df$Mod_Value_1-sub_good.df$Ob_Value_1))		# Compute the site mean error for simulation 1
         mod_error_2    <- mean(abs(sub_good.df$Mod_Value_2-sub_good.df$Ob_Value_2))		# Compute the site mean error for simulation 2
         mod_error_1_all    <- c(mod_error_1_all, mod_error_1)					# Store site mean error for simulation 1 in an array
         mod_error_2_all    <- c(mod_error_2_all, mod_error_2)					# Store site mean error for simulation 2 in an array
         error_diff     <- c(error_diff, (mod_error_1-mod_error_2))				# Compute difference in site mean error between two simulations
      }
   }
   sites_avg.df <- data.frame(Network=network,Site_ID=sites,lat=lats,lon=lons,Bias_1=mod_bias_1_all,Bias_2=mod_bias_2_all,Bias_Diff=bias_diff,Error_1=mod_error_1_all,Error_2=mod_error_2_all,Error_Diff=error_diff)	# Create properly formatted dataframe for use with PlotSpatial function
   sinfo_bias_1_data[[j]]<-list(lat=sites_avg.df$lat,lon=sites_avg.df$lon,plotval=sites_avg.df$Bias_1)
   sinfo_bias_2_data[[j]]<-list(lat=sites_avg.df$lat,lon=sites_avg.df$lon,plotval=sites_avg.df$Bias_2)
   sinfo_bias_diff_data[[j]]<-list(lat=sites_avg.df$lat,lon=sites_avg.df$lon,plotval=sites_avg.df$Bias_Diff)
   sinfo_error_1_data[[j]]<-list(lat=sites_avg.df$lat,lon=sites_avg.df$lon,plotval=sites_avg.df$Error_1)
   sinfo_error_2_data[[j]]<-list(lat=sites_avg.df$lat,lon=sites_avg.df$lon,plotval=sites_avg.df$Error_2)
   sinfo_error_diff_data[[j]]<-list(lat=sites_avg.df$lat,lon=sites_avg.df$lon,plotval=sites_avg.df$Error_Diff)

   all_lats		<- c(all_lats,sites_avg.df$lat)
   all_lons		<- c(all_lons,sites_avg.df$lon)
   all_bias		<- c(all_bias,sites_avg.df$Bias_1)
   all_bias_diff	<- c(all_bias_diff,sites_avg.df$Bias_Diff)
   all_error		<- c(all_error,sites_avg.df$Error_1)
   all_error_diff	<- c(all_error_diff,sites_avg.df$Error_Diff)
}
#########################
## plot format options ##
bounds<-c(min(all_lats,bounds[1]),max(all_lats,bounds[2]),min(all_lons,bounds[3]),max(all_lons,bounds[4]))
plotsize<-1.50									# Set plot size
symb<-15										# Set symbol character
symbsiz<-0.9										# Set symbol size
if (length(sites) > 500) {	# make the symbol size smaller if there are a lot of points to plot
   symbsiz <- 0.7
}
if (length(sites) > 10000) {	# ditto
   symbsiz <- 0.5
}
#########################

### Determine intervals  to use for plotting ob and model values ###
levs <- NULL
if (length(num_ints) == 0) {
   num_ints <- 10 
}
intervals <- num_ints
{
   if ((length(abs_range_min) == 0) || (length(abs_range_max) == 0)) {
      levs <- pretty(c(0,all_bias,all_error),intervals,min.n=5)
   }
   else {
      levs <- pretty(c(abs_range_min,abs_range_max),intervals,min.n=5)
   }
}
##########################################################################
### Code to create color palette that will be used throughout the code ###
##########################################################################
hot_colors	<- colorRampPalette(c("yellow","orange","firebrick"))
cool_colors	<- colorRampPalette(c("darkorchid4","blue","green"))
all_colors	<- colorRampPalette(c("darkorchid4","blue","green","yellow","orange","firebrick"))

### Extended color scale w/ additional colors ###
#hot_colors      <- colorRampPalette(c("palegoldenrod","yellow","orange","firebrick","burlywood4"))
#cool_colors     <- colorRampPalette(c("darkmagenta","darkorchid4","blue","green","darkolivegreen1"))
#all_colors      <- colorRampPalette(c("darkorchid4","blue","green","palegoldenrod","yellow","orange","firebrick","burlywood4"))

##########################################################################

#####################################
### Create Bias levels and colors ###
#####################################
colors_bias 	 <- NULL
levs_bias	 <- NULL
length_levs_bias <- length(levs_bias)
intervals	 <- num_ints
{
   if ((length(diff_range_min) == 0) || (length(diff_range_max) == 0)) {
      bias_max <- quantile(all_bias,.95)
      bias_min <- quantile(all_bias,0.05)
      while ((length_levs_bias == 0) || (length_levs_bias > 15)) {	# Loop to cap number of intervals
         levs_bias <- pretty(c(bias_min,bias_max),intervals,min.n=5)
         length_levs_bias <- length(levs_bias)
         intervals <- intervals - 1
      }
      diff_range <- range(levs_bias)
      power <- abs(abs(levs_bias[1]) - abs(levs_bias[2]))
      if (abs(diff_range[1]) > diff_range[2]) {
         diff_range[2] <- abs(diff_range[1])
      }
      else {
         diff_range[1] <- -diff_range[2]
      }
   }
   else {
      levs_bias <- pretty(c(diff_range_min,diff_range_max),intervals,min.n=5)
      power <- abs(levs_bias[1]) - abs(levs_bias[2])
      diff_range <- range(levs_bias)
   }
   levs_bias <- signif(round(seq(diff_range[1],diff_range[2],power),5),2)
}
levs_interval                           <- (max(levs_bias)-min(levs_bias))/(length(levs_bias)-1)
length_levs_bias			<- length(levs_bias)
levs_legend_bias			<- c(min(levs_bias)-levs_interval,levs_bias,max(levs_bias)+levs_interval)
leg_labels_bias				<- levs_bias
levels_label_bias			<- levs_bias
leg_labels_bias[length_levs_bias]       <- paste(">",max(levs_bias))     # Label maximum level as greater than max defined value
leg_labels_bias                         <- c(leg_labels_bias,"")        # Label maximum level as greater than max defined value 
leg_labels_bias                         <- c("",leg_labels_bias)        # Label minimum level as less than max defined value
leg_labels_bias[2]                      <- paste("<",min(levs_bias))    # Label minimum level as less than max defined value
levs_bias 				<- c(levs_bias,10000)           # Set extreme absolute value to capture all values
levs_bias 				<- c(-10000,levs_bias)          # Set extreme miniumum value to capture all values
zero_place 				<- which(levs_bias==0)
levs_diff 				<- levs_bias[-zero_place]
levels_label_bias 			<- levels_label_bias[-zero_place]
low_range				<- cool_colors(trunc(length(levels_label_bias)/2))
high_range				<- hot_colors(trunc(length(levels_label_bias)/2))
colors_bias				<- c(low_range,"grey",high_range)
leg_colors_bias				<- c(low_range,"grey","grey",high_range)
###########################################

######################################
### Create Error levels and colors ###
######################################
levs    <- NULL 
colors_error  <- NULL 
intervals <- num_ints
{
   if ((length(abs_range_min) == 0) || (length(abs_range_max) == 0)) {
      levs <- pretty(c(0,all_error),intervals,min.n=5)
   }
   else {
      levs <- pretty(c(abs_range_min,abs_range_max),intervals,min.n=5)
   }
}
levs_interval				<- (max(levs)-min(levs))/(length(levs)-1)
length_levs_error			<- length(levs)
levs_legend_error			<- c(levs,max(levs)+levs_interval)
leg_labels_error			<- levs
levels_label_error			<- levs
leg_labels_error[length_levs_error]	<- paste("> ",max(levs),sep="")
leg_labels_error			<- c(leg_labels_error,"")
levels_max				<- length(levs)+1      # determine the final maximum number of levels
levs[levels_max]			<- 10000         # set the level maximum to 1000 in order to include all values
levels_error				<- levs
colors_error				<- all_colors(length_levs_error)
leg_colors_error			<- colors_error
###########################################

############################################
### Compute Bias Difference Range/Colors ###
############################################
colors_diff_bias <- NULL
intervals <- num_ints
{
   if ((length(diff_range_min) == 0) || (length(diff_range_max) == 0)) {
      diff_max <- max(abs(all_bias_diff))
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
   levs_diff_bias <- signif(round(seq(diff_range[1],diff_range[2],power),5),2)
}
levs_interval					<- (max(levs_diff_bias)-min(levs_diff_bias))/(length(levs_diff_bias)-1)
length_levs_diff_bias				<- length(levs_diff_bias)
levs_legend_diff_bias				<- c(min(levs_diff_bias)-levs_interval,levs_diff_bias,max(levs_diff_bias)+levs_interval)
leg_labels_diff_bias				<- levs_diff_bias
leg_labels_diff_bias[length_levs_diff_bias]	<- paste(">",max(levs_diff_bias))     # Label maximum level as greater than max defined value
leg_labels_diff_bias				<- c(leg_labels_diff_bias,"")        # Label maximum level as greater than max defined value 
leg_labels_diff_bias				<- c("",leg_labels_diff_bias)        # Label minimum level as less than max defined value
leg_labels_diff_bias[2]				<- paste("<",min(levs_diff_bias))    # Label minimum level as less than max defined value
levs_diff_bias					<- c(levs_diff_bias,10000)		# Set extreme absolute value to capture all values
levs_diff_bias					<- c(-10000,levs_diff_bias)		# Set extreme miniumum value to capture all values
zero_place 					<- which(levs_diff_bias==0) 
levs_diff_bias					<- levs_diff_bias[-zero_place]
levels_diff_bias				<- levs_diff_bias
low_range					<- cool_colors(trunc(length_levs_diff_bias/2))
high_range					<- hot_colors(trunc(length_levs_diff_bias/2))
colors_diff_bias				<- c(low_range,"grey",high_range)
leg_colors_diff_bias				<- c(low_range,"grey","grey",high_range)
#####################################################################

#############################################
### Compute Error Difference Range/Colors ###
#############################################
colors_diff_error <- NULL
intervals <- num_ints
{
   if ((length(diff_range_min) == 0) || (length(diff_range_max) == 0)) {
      diff_max <- max(abs(all_error_diff))
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
   levs_diff_error <- signif(round(seq(diff_range[1],diff_range[2],power),5),2)
}
levs_interval                                   <- (max(levs_diff_error)-min(levs_diff_error))/(length(levs_diff_error)-1)
length_levs_diff_error                          <- length(levs_diff_error)
levs_legend_diff_error                          <- c(min(levs_diff_error)-levs_interval,levs_diff_error,max(levs_diff_error)+levs_interval)
leg_labels_diff_error                           <- levs_diff_error
leg_labels_diff_error[length_levs_diff_error]   <- paste(">",max(levs_diff_error))     # Label maximum level as greater than max defined value
leg_labels_diff_error                           <- c(leg_labels_diff_error,"")        # Label maximum level as greater than max defined value 
leg_labels_diff_error                           <- c("",leg_labels_diff_error)        # Label minimum level as less than max defined value
leg_labels_diff_error[2]                        <- paste("<",min(levs_diff_error))    # Label minimum level as less than max defined value
levs_diff_error                                 <- c(levs_diff_error,10000)              # Set extreme absolute value to capture all values
levs_diff_error                                 <- c(-10000,levs_diff_error)             # Set extreme miniumum value to capture all values
zero_place                                      <- which(levs_diff_error==0)
levs_diff_error                                 <- levs_diff_error[-zero_place]
levels_diff_error                               <- levs_diff_error
low_range                                       <- cool_colors(trunc(length_levs_diff_error/2))
high_range                                      <- hot_colors(trunc(length_levs_diff_error/2))
colors_diff_error                               <- c(low_range,"grey",high_range)
leg_colors_diff_error                           <- c(low_range,"grey","grey",high_range)
#####################################################################

for (k in 1:j) {

   sinfo_bias_1[[k]]<-list(lat=sinfo_bias_1_data[[k]]$lat,lon=sinfo_bias_1_data[[k]]$lon,plotval=sinfo_bias_1_data[[k]]$plotval,levs=levs_bias,levcols=colors_bias,levs_legend=levs_legend_bias,cols_legend=leg_colors_bias,convFac=.01)			# Create list to be used with PlotSpatial function
   sinfo_bias_2[[k]]<-list(lat=sinfo_bias_2_data[[k]]$lat,lon=sinfo_bias_2_data[[k]]$lon,plotval=sinfo_bias_2_data[[k]]$plotval,levs=levs_bias,levcols=colors_bias,levs_legend=levs_legend_bias,cols_legend=leg_colors_bias,convFac=.01)			# Create model list to be used with PlotSpatial fuction
   sinfo_bias_diff[[k]]<-list(lat=sinfo_bias_diff_data[[k]]$lat,lon=sinfo_bias_diff_data[[k]]$lon,plotval=sinfo_bias_diff_data[[k]]$plotval,levs=levels_diff_bias,levcols=colors_diff_bias,levs_legend=levs_legend_diff_bias,cols_legend=leg_colors_diff_bias,convFac=.01)	# Create diff list to be used with PlotSpatial fuction
   sinfo_error_1[[k]]<-list(lat=sinfo_error_1_data[[k]]$lat,lon=sinfo_error_1_data[[k]]$lon,plotval=sinfo_error_1_data[[k]]$plotval,levs=levs,levcols=colors_error,levs_legend=levs_legend_error,cols_legend=leg_colors_error,convFac=.01)                    # Create list to be used with PlotSpatial function
   sinfo_error_2[[k]]<-list(lat=sinfo_error_2_data[[k]]$lat,lon=sinfo_error_2_data[[k]]$lon,plotval=sinfo_error_2_data[[k]]$plotval,levs=levs,levcols=colors_error,levs_legend=levs_legend_error,cols_legend=leg_colors_error,convFac=.01)                    # Create model list to be used with PlotSpatial fuction
   sinfo_error_diff[[k]]<-list(lat=sinfo_error_diff_data[[k]]$lat,lon=sinfo_error_diff_data[[k]]$lon,plotval=sinfo_error_diff_data[[k]]$plotval,levs=levels_diff_error,levcols=colors_diff_error,levs_legend=levs_legend_diff_error,cols_legend=leg_colors_diff_error,convFac=.01)      # Create diff list to be used with PlotSpatial fuction
}

###########################
### plot text options   ###
###########################
figure_bias1		<-paste(run_name1,species,"spatialplot_Bias_1",sep="_")	# Filename for obs spatial plot
figure_bias2		<-paste(run_name1,species,"spatialplot_Bias_2",sep="_")	# Filename for model spatial plot
figure_bias_diff	<-paste(run_name1,species,"spatialplot_Bias_Diff",sep="_")	# Filename for diff spatial plot
figure_error1		<-paste(run_name1,species,"spatialplot_Error_1",sep="_")     # Filename for obs spatial plot
figure_error2		<-paste(run_name1,species,"spatialplot_Error_2",sep="_")     # Filename for model spatial plot
figure_error_diff	<-paste(run_name1,species,"spatialplot_Error_Diff",sep="_")       # Filename for diff spatial plot
figure_bias1		<- paste(figdir,figure_bias1, sep="/")  ## make full path
figure_bias2		<- paste(figdir,figure_bias2, sep="/")  ## make full path
figure_bias_diff	<- paste(figdir,figure_bias_diff, sep="/")  ## make full path
figure_error1		<- paste(figdir,figure_error1, sep="/")  ## make full path
figure_error2		<- paste(figdir,figure_error2, sep="/")  ## make full path
figure_error_diff	<- paste(figdir,figure_error_diff, sep="/")  ## make full path
{
   if (custom_title == "") {
      title_bias1	<-paste(species, " Bias for Run ",run_name1," for ", start_date, "to",end_date, sep="")		# Title for obs spatial plot
      title_bias2	<-paste(species, " Bias for Run ",run_name2," for ", start_date, "to",end_date, sep="")		# Title for model spatial plot
      title_bias_diff	<-paste(run_name1,"-",run_name2,species,"bias difference for", start_date, "to",end_date, sep=" ")	# Title for diff spatial plot
      title_error1      <-paste(species, " Error for Run ",run_name1," for ", start_date, "to",end_date, sep="")              # Title for obs spatial plot
      title_error2      <-paste(species, " Error for Run ",run_name2," for ", start_date, "to",end_date, sep="")              # Title for model spatial plot
      title_error_diff   <-paste(run_name1,"-",run_name2,species,"Error Difference for", start_date, "to",end_date, sep=" ")      # Title for diff spatial plot
   }
   else {
      title_bias1	<- custom_title
      title_bias2	<- custom_title
      title_bias_diff	<- custom_title
      title_error1	<- custom_title
      title_error2	<- custom_title
      title_error_diff	<- custom_title
   }
}
###########################

###############################
## Create PNG and PDF plots ###
###############################

### Plot Run 1 Bias ###
unique_labels <- "y"												# Do not use unique labels
levLab  <- leg_labels_bias

if ((plot_format == "png") || (plot_format == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_bias_1,figure=figure_bias1,varlab=title_bias1,bounds=bounds,plotopts=plotopts,plot_units=units)	# Call PlotSpatial function for obs values
}

if ((plot_format == "pdf") || (plot_format == "both")) {
   plotfmt <- "pdf"												# Set plot format as pdf
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_bias_1,figure=figure_bias1,varlab=title_bias1,bounds=bounds,plotopts=plotopts,plot_units=units)	# Call PlotSpatial function for ob values
}
#########################

### Plot Run 2 Bias ###

if ((plot_format == "png") || (plot_format == "both")) {
   plotfmt <- "png"												# Set plot format as png
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_bias_2,figure=figure_bias2,varlab=title_bias2,bounds=bounds,plotopts=plotopts,plot_units=units)	# Call PlotSpatial function for model values
}

if ((plot_format == "pdf") || (plot_format == "both")) {
   plotfmt <- "pdf"												# Set plot format as pdf
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_bias_2,figure=figure_bias2,varlab=title_bias2,bounds=bounds,plotopts=plotopts,plot_units=units)   	# Call PlotSpatial function for model values
}
###########################

### Plot Bias Difference ###
unique_labels <- "y"												# Flag within Misc_Functions.R to use predefined labels
levLab <- leg_labels_diff_bias

if ((plot_format == "png") || (plot_format == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz) 					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_bias_diff,figure=figure_bias_diff,varlab=title_bias_diff,bounds=bounds,plotopts=plotopts,plot_units=units)	# Call PlotSpatial function for difference values
}

if ((plot_format == "pdf") || (plot_format == "both")) {
   plotfmt <- "pdf" 												# Set plot format as pdf
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_bias_diff,figure=figure_bias_diff,varlab=title_bias_diff,bounds=bounds,plotopts=plotopts,plot_units=units)	# Call PlotSpatial function for difference values
}
#########################################

### Plot Run 1 Error ###
unique_labels <- "y"                                                                                            # Do not use unique labels
levLab <- leg_labels_error

if ((plot_format == "png") || (plot_format == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_error_1,figure=figure_error1,varlab=title_error1,bounds=bounds,plotopts=plotopts,plot_units=units)     # Call PlotSpatial function for obs values
}

if ((plot_format == "pdf") || (plot_format == "both")) {
   plotfmt <- "pdf"                                                                                                # Set plot format as pdf
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_error_1,figure=figure_error1,varlab=title_error1,bounds=bounds,plotopts=plotopts,plot_units=units)     # Call PlotSpatial function for ob values
}
#########################

### Plot Run 2 Error ###
if ((plot_format == "png") || (plot_format == "both")) {
   plotfmt <- "png"                                                                                                # Set plot format as png
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_error_2,figure=figure_error2,varlab=title_error2,bounds=bounds,plotopts=plotopts,plot_units=units)     # Call PlotSpatial function for model values
}

if ((plot_format == "pdf") || (plot_format == "both")) {
   plotfmt <- "pdf"                                                                                                # Set plot format as pdf
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_error_2,figure=figure_error2,varlab=title_error2,bounds=bounds,plotopts=plotopts,plot_units=units)     # Call PlotSpatial function for model values
}
###########################

### Plot Error Difference ###
unique_labels <- "y"                                                                                            # Flag within Misc_Functions.R to use predefined labels
levLab <- leg_labels_diff_error

if ((plot_format == "png") || (plot_format == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_error_diff,figure=figure_error_diff,varlab=title_error_diff,bounds=bounds,plotopts=plotopts,plot_units=units)    # Call PlotSpatial function for difference values
}

if ((plot_format == "pdf") || (plot_format == "both")) {
   plotfmt <- "pdf"                                                                                                # Set plot format as pdf
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_error_diff,figure=figure_error_diff,varlab=title_error_diff,bounds=bounds,plotopts=plotopts,plot_units=units)    # Call PlotSpatial function for difference values
}
######################################### 
