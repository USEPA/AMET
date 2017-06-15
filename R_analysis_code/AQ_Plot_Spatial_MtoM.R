################################################################
### AMET CODE: PLOT SPATIAL
###
### This code is part of the AMET-AQ system.  The Plot Spatial code
### takes a MYSQL database query for a single species from one or more
### networks and plots the observation value, model value, and 
### difference between the model and ob for each site for each 
### corresponding network.  Mutiple values for a site are averaged
### to a single value for plotting purposes.  The map area plotted
### is dynamically generated from the input data.   
###
### Last modified by Wyat Appel; April, 2017
################################################################

## get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")        # base directory of AMET
dbase           <- Sys.getenv("AMET_DATABASE")      # AMET database
ametR           <- paste(ametbase,"/R_analysis_code",sep="")      # R directory
ametRinput      <- Sys.getenv("AMETRINPUT")  # input file for this script
ametptype       <- Sys.getenv("AMET_PTYPE")   # Prefered output type
## Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
## and not specified via AMET_OUT, then set figdir to the current directory
if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")       }
if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"                 }

## source some configuration files, AMET libs, and input
source(paste(ametbase,"/configure/amet-config.R",sep=""))
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file
source(ametRinput)                                     # Anaysis configuration/input file

## Load Required Libraries 
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}
if(!require(maps)){stop("Required Package maps was not loaded")}
if(!require(mapdata)){stop("Required Package mapdata was not loaded")}

mysql <- list(login=amet_login, passwd=amet_pass, server=mysql_server, dbase=dbase, maxrec=maxrec)

### Retrieve units label from database table ###
network <- network_names[1]														# When using mutiple networks, units from network 1 will be used
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")	# Create MYSQL query from units table
units <- db_Query(units_qs,mysql)													# Query the database for units name

figure_diff	<- paste(run_name1,species,pid,"spatialplot_MtoM_Diff_Avg",sep="_")           # Filename for diff spatial plot
figure_max	<- paste(run_name1,species,pid,"spatialplot_MtoM_Diff_Max",sep="_")               # Filename for diff spatial plot
figure_min	<- paste(run_name1,species,pid,"spatialplot_MtoM_Diff_Min",sep="_")               # Filename for diff spatial plot

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(run_name1,species,"for",network_label[1],"for",dates,sep=" ") }
   else { title <- custom_title }
}

## Create a full path to file
figure_diff	<-paste(figdir,figure_diff,sep="/")           # Filename for diff spatial plot
figure_max	<-paste(figdir,figure_max,sep="/")               # Filename for diff spatial plot
figure_min	<-paste(figdir,figure_min,sep="/")               # Filename for diff spatial plot

################################################

### Set NULL values and plot symbols ###
sinfo_diff      <- NULL						# Set list for difference values to NULL
sinfo_max	<- NULL
sinfo_min	<- NULL
sinfo_diff_data <- NULL
sinfo_max_data  <- NULL
sinfo_min_data  <- NULL
diff_min        <- NULL
all_lats        <- NULL
all_lons        <- NULL
all_diff        <- NULL
all_max		<- NULL
all_min		<- NULL
bounds          <- NULL						# Set map bounds to NULL
sub_title       <- NULL						# Set sub title to NULL
lev_lab         <- NULL
plot.symbols<-as.integer(plot_symbols)
pick.symbol.name.fun<-function(x){
   master.symbol.df<-data.frame(plot.symbols=c(16,17,15,18,8,11,4),names=c("CIRCLE","TRIANGLE","SQUARE","DIAMOND","BURST","STAR","X"))
   as.character(master.symbol.df$names[x==master.symbol.df$plot.symbols])
}
pick.symbol2.fun<-function(x){
   master.symbol2.df<-data.frame(plot.symbols=c(16,17,15,18,8,11,4),plot.symbols2=c(1,2,0,5,8,11,4))
   as.integer(master.symbol2.df$plot.symbols2[x==master.symbol2.df$plot.symbols])
}
symbols<-apply(matrix(plot.symbols),1,pick.symbol.name.fun)
spch2 <- apply(matrix(plot.symbols),1,pick.symbol2.fun)
spch<-plot.symbols
########################################

for (j in 1:length(network_names)) {                                            # Loop through for each network
   sites <- NULL
   lats <- NULL
   lons <- NULL
   avg_diff <- NULL
   max_diff <- NULL
   min_diff <- NULL
   network   <- network_names[[j]]                                              # Set network name
   sub_title<-paste(sub_title,symbols[j],"=",network_label[j],"; ",sep="")      # Set subtitle based on network matched with the symbol name used for that network
   criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
   check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name1,"' and COLUMN_NAME = 'POCode';",sep="")
   query_table_info.df <-db_Query(check_POCode,mysql)
   {
      if (length(query_table_info.df$COLUMN_NAME)==0) {   # Check to see if individual project tables exist
         qs1       <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,DATE_FORMAT(d.ob_dates,'%Y%m%d'),DATE_FORMAT(d.ob_datee,'%Y%m%d'),d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod,precip_ob,precip_mod from ",run_name1," as d, site_metadata as s",criteria," ORDER BY stat_id,ob_dates",sep="")                                           # Secord part of MYSQL query for run name 1
         aqdat1.df        <- db_Query(qs1,mysql)
         aqdat1.df$POCode <- 1
      }
      else {
         qs1       <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,DATE_FORMAT(d.ob_dates,'%Y%m%d'),DATE_FORMAT(d.ob_datee,'%Y%m%d'),d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod,precip_ob,precip_mod,d.POCode from ",run_name1," as d, site_metadata as s",criteria," ORDER BY stat_id,ob_dates",sep="")                                           # Secord part of MYSQL query for run name 1
         aqdat1.df <- db_Query(qs1,mysql)
      }
   }
   check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name2,"' and COLUMN_NAME = 'POCode';",sep="")
   query_table_info.df <-db_Query(check_POCode,mysql)
   {
      if (length(query_table_info.df$COLUMN_NAME)==0) {   # Check to see if individual project tables exist
         qs2       <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,DATE_FORMAT(d.ob_dates,'%Y%m%d'),DATE_FORMAT(d.ob_datee,'%Y%m%d'),d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod,precip_ob,precip_mod from ",run_name2," as d, site_metadata as s",criteria," ORDER BY stat_id,ob_dates",sep="")                                           # Secord part of MYSQL query for run name 1
         aqdat2.df        <- db_Query(qs2,mysql)
         aqdat2.df$POCode <- 1
      }
      else {
         qs2       <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,DATE_FORMAT(d.ob_dates,'%Y%m%d'),DATE_FORMAT(d.ob_datee,'%Y%m%d'),d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod,precip_ob,precip_mod,d.POCode from ",run_name2," as d, site_metadata as s",criteria," ORDER BY stat_id,ob_dates",sep="")                                           # Secord part of MYSQL query for run name 1
         aqdat2.df        <- db_Query(qs2,mysql)
      }
   }
   aqdat1.df$stat_id <- paste(aqdat1.df$stat_id,aqdat1.df$POCode,sep="")
   aqdat2.df$stat_id <- paste(aqdat2.df$stat_id,aqdat2.df$POCode,sep="")
   aqdat1.df$ob_dates <- aqdat1.df[,5]          # remove hour,minute,second values from start date (should always be 000000 anyway, but could change)
   aqdat2.df$ob_dates <- aqdat2.df[,5]          # remove hour,minute,second values from start date (should always be 000000 anyway, but could change)
   

   ### Match the points between each of the runs.  This is necessary if the data from each query do not match exactly ###
   aqdat1.df$statdate<-paste(aqdat1.df$stat_id,aqdat1.df$ob_dates,aqdat1.df$ob_hour,sep="")     # Create unique column that combines the site name with the ob start date for run 1
   aqdat2.df$statdate<-paste(aqdat2.df$stat_id,aqdat2.df$ob_dates,aqdat2.df$ob_hour,sep="")     # Create unique column that combines the site name with the ob start date for run 2
   if (length(aqdat1.df$statdate) <= length(aqdat2.df$statdate)) {                              # If more obs in run 1 than run 2
      match.ind<-match(aqdat1.df$statdate,aqdat2.df$statdate)                                   # Match the unique column (statdate) between the two runs
      aqdat.df<-data.frame(network=aqdat1.df$network, stat_id=aqdat1.df$stat_id, lat=aqdat1.df$lat, lon=aqdat1.df$lon, dates=aqdat1.df$ob_dates, aqdat1.df[,10], aqdat2.df[match.ind,10], aqdat1.df[,9], aqdat2.df[match.ind,9], month=aqdat1.df$month, precip_ob=aqdat1.df$precip_ob, precip_mod=aqdat1.df$precip_mod)      # eliminate points that are not common between the two runs

   }
   else { match.ind<-match(aqdat2.df$statdate,aqdat1.df$statdate)                               # If more obs in run 2 than run 1
      aqdat.df<-data.frame(network=aqdat2.df$network, stat_id=aqdat2.df$stat_id, lat=aqdat2.df$lat, lon=aqdat2.df$lon, ob_dates=aqdat2.df$ob_dates, aqdat1.df[match.ind,10], aqdat2.df[,10], aqdat1.df[match.ind,9], aqdat2.df[,9], month=aqdat2.df$month, precip_ob=aqdat2.df$precip_ob, precip_mod=aqdat2.df$precip_mod)      # eliminate points that are not common between the two runs
   }
   aqdat.df <- data.frame(Network=aqdat.df$network,Stat_ID=aqdat.df$stat_id,lat=aqdat.df$lat,lon=aqdat.df$lon,Mod_Value1=aqdat.df[,7],Mod_Value2=aqdat.df[,6])

   ### Remove NAs ###
   indic.na <- is.na(aqdat.df$Mod_Value1)
   aqdat.df <- aqdat.df[!indic.na,]
   indic.na <- is.na(aqdat.df$Mod_Value2)
   aqdat.df <- aqdat.df[!indic.na,]
   ##################

   if (remove_negatives == "y") {
      indic.nonzero <- aqdat.df$Mod_Value1 >= 0 # determine which model values are missing (less than 0); 
      aqdat.df <- aqdat.df[indic.nonzero,]      # remove missing model values from dataframe
      indic.nonzero <- aqdat.df$Mod_Value2 >= 0 # determine which model values are missing (less than 0); 
      aqdat.df <- aqdat.df[indic.nonzero,]      # remove missing model values from dataframe
   }

   split_sites_all  <- split(aqdat.df, aqdat.df$Stat_ID)
   for (i in 1:length(split_sites_all)) {                                               # Run averaging for each site for each month
      sub_all.df  <- split_sites_all[[i]]                                               # Store current site i in sub_all.df dataframe
      if (length(sub_all.df$Stat_ID) > 0) {						# Check that site has data available
         sites        <- c(sites, unique(sub_all.df$Stat_ID))                          	# Add current site to site list 
         lats         <- c(lats, unique(sub_all.df$lat))                               	# Add current lat to lat list
         lons         <- c(lons, unique(sub_all.df$lon))                               	# Add current lon to lon list
         if ((species == "SO4_dep") || (species == "NO3_dep") || (species == "NH4_dep") || (species == "precip") || (species == "HGdep") || (species == "Ca_dep") || (species == "Mg_dep") || (species == "K_dep") || (species == "Na_dep") || (species == "Cl_dep")) {
            avg_diff <- c(avg_diff, (sum(sub_all.df$Mod_Value2)-sum(sub_all.df$Mod_Value1)))       # Compute model/ob difference
         }
         else {                                                                         # use averaging for all other networks
            avg_diff <- c(avg_diff, (mean(sub_all.df$Mod_Value2)-mean(sub_all.df$Mod_Value1)))     # Compute model/ob difference
         }
         max_diff <- c(max_diff, max(sub_all.df$Mod_Value2-sub_all.df$Mod_Value1))
         min_diff <- c(min_diff, min(sub_all.df$Mod_Value2-sub_all.df$Mod_Value1))
      }
   }
   sinfo_max_data[[j]]<-list(lat=lats,lon=lons,plotval=max_diff)
   sinfo_min_data[[j]]<-list(lat=lats,lon=lons,plotval=min_diff)
   sinfo_diff_data[[j]]<-list(lat=lats,lon=lons,plotval=avg_diff)
   
   all_lats <- c(all_lats,lats)
   all_lons <- c(all_lons,lons)
   all_diff <- c(all_diff,avg_diff)
   all_max  <- c(all_max,max_diff)
   all_min  <- c(all_min,min_diff)
}
#########################
## plot format options ##
bounds<-c(min(all_lats,bounds[1]),max(all_lats,bounds[2]),min(all_lons,bounds[3]),max(all_lons,bounds[4]))
plotsize<-1.50									# Set plot size
symb<-15										# Set symbol character
symbsiz<-0.9										# Set symbol size
if (length(sites) > 500) {
   symbsiz <- 0.7
}
if (length(sites) > 10000) {
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
####################################################################

############################################
### Determine levels for difference plot ###
############################################
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
      diff_range <- range(levs_diff)
      power <- abs(levs_diff[1]) - abs(levs_diff[2])
   }
   levs_diff <- signif(round(seq(diff_range[1],diff_range[2],power),5),2)
}
levs_interval                           <- (max(levs_diff)-min(levs_diff))/(length(levs_diff)-1)
length_levs_diff                        <- length(levs_diff)
levs_legend_diff                        <- c(min(levs_diff)-levs_interval,levs_diff,max(levs_diff)+levs_interval)
leg_labels_diff                         <- levs_diff
levels_label_diff                       <- levs_diff
leg_labels_diff[length_levs_diff]       <- paste(">",max(levs_diff))     # Label maximum level as greater than max defined value
leg_labels_diff                         <- c("",leg_labels_diff,"")        # Label maximum level as greater than max defined value 
leg_labels_diff[2]                      <- paste("<",min(levs_diff))    # Label minimum level as less than max defined value
levs_diff                               <- c(-10000,levs_diff,10000)           # Set extreme absolute value to capture all values
zero_place                              <- which(levs_diff==0)
levs_diff                               <- levs_diff[-zero_place]
levels_label_diff                       <- levels_label_diff[-zero_place]
cols_diff                               <- NULL
leg_colors_diff				<- NULL
low_range                               <- cool_colors(trunc(length_levs_diff/2))
high_range                              <- hot_colors(trunc(length_levs_diff/2))
cols_diff                               <- c(low_range,"grey50",high_range)
leg_colors_diff                         <- c(low_range,"grey50","grey50",high_range)
#####################################################################

#####################################
### Determine levels for max plot ###
#####################################
intervals <- num_ints
{
   if ((length(abs_range_min) == 0) || (length(abs_range_max) == 0)) {
      max_max <- max(c(abs(all_max),abs(all_min)))
      levs_max <- pretty(c(-max_max,max_max),intervals,min.n=5)
      max_range <- range(levs_max)
      power <- abs(levs_max[1]) - abs(levs_max[2])
      if (abs(max_range[1]) > max_range[2]) {
         max_range[2] <- abs(max_range[1])
      }
      else {
         max_range[1] <- -max_range[2]
      }
   }
   else {
      levs_max <- pretty(c(abs_range_min,abs_range_max),intervals,min.n=5)
      max_range <- range(levs_max)
      power <- abs(levs_max[1]) - abs(levs_max[2])
   }
   levs_max <- signif(round(seq(max_range[1],max_range[2],power),5),2)
}
levs_interval                           <- (max(levs_max)-min(levs_max))/(length(levs_max)-1)
length_levs_max                         <- length(levs_max)
levs_legend_max                         <- c(min(levs_max)-levs_interval,levs_max,max(levs_max)+levs_interval)
leg_labels_max                          <- levs_max
leg_labels_max[length_levs_max]         <- paste(">",max(levs_max))     # Label maximum level as greater than max defined value
leg_labels_max                          <- c("",leg_labels_max,"")        # Label maximum level as greater than max defined value 
leg_labels_max[2]                       <- paste("<",min(levs_max))    # Label minimum level as less than max defined value
levs_max                                <- c(-10000,levs_max,10000)           # Set extreme absolute value to capture all values
zero_place                              <- which(levs_max==0)
levs_max                                <- levs_max[-zero_place]
cols_max                                <- NULL
leg_colors_max				<- NULL
low_range                               <- cool_colors(trunc(length_levs_max/2))
high_range                              <- hot_colors(trunc(length_levs_max/2))
cols_max                                <- c(low_range,"grey50",high_range)
leg_colors_max                          <- c(low_range,"grey50","grey50",high_range)
#####################################################################

for (l in 1:j) {

   sinfo_diff[[l]]<-list(lat=sinfo_diff_data[[l]]$lat,lon=sinfo_diff_data[[l]]$lon,plotval=sinfo_diff_data[[l]]$plotval,levs=levs_diff,levcols=cols_diff,levs_legend=levs_legend_diff,cols_legend=leg_colors_diff,convFac=.01)	# Create diff list to be used with PlotSpatial fuction
   sinfo_max[[l]]<-list(lat=sinfo_max_data[[l]]$lat,lon=sinfo_max_data[[l]]$lon,plotval=sinfo_max_data[[l]]$plotval,levs=levs_max,levcols=cols_max,levs_legend=levs_legend_max,cols_legend=leg_colors_max,convFac=.01)   # Create diff list to be used with PlotSpatial fuction
   sinfo_min[[l]]<-list(lat=sinfo_min_data[[l]]$lat,lon=sinfo_min_data[[l]]$lon,plotval=sinfo_min_data[[l]]$plotval,levs=levs_max,levcols=cols_max,levs_legend=levs_legend_max,cols_legend=leg_colors_max,convFac=.01)   # Create diff list to be used with PlotSpatial fuction
}
   

###########################
### plot text options   ###
###########################
{
   if (custom_title == "") {
      title_diff<-paste("Average Difference of",run_name1,"-",run_name2,species,"for",dates,sep=" ")		# Title for diff spatial plot
      title_max<-paste("Maximum Difference of",run_name1,"-",run_name2,species,"for",dates,sep=" ")            # Title for diff spatial plot
      title_min<-paste("Minimum Difference of",run_name1,"-",run_name2,species,"for",dates,sep=" ")            # Title for diff spatial plot
   }
   else {
      title_diff <- custom_title
      title_max <- custom_title
      title_min <- custom_title
   }
}
###########################

##############################################
## Create PNG and PDF plots for NMB and NME ##
##############################################

###########################################
### Plot Model/Model Average Difference ###
###########################################
unique_labels <- "y"												# Flag within Misc_Functions.R to use predefined labels
levLab <- leg_labels_diff
if ((ametptype == "png") || (ametptype == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz) 					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_diff,figure=figure_diff,varlab=title_diff,bounds=bounds,plotopts=plotopts,plot_units=units)	# Call PlotSpatial function for difference values
}
if ((ametptype == "pdf") || (ametptype == "both")) {
   plotfmt <- "pdf" 												# Set plot format as pdf
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_diff,figure=figure_diff,varlab=title_diff,bounds=bounds,plotopts=plotopts,plot_units=units)	# Call PlotSpatial function for difference values
}
#########################################

#######################################
### Plot Model/Model Max Difference ###
#######################################
unique_labels <- "y"                                                                                            # Flag within Misc_Functions.R to use predefined labels 
levLab <- leg_labels_max
if ((ametptype == "png") || (ametptype == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_max,figure=figure_max,varlab=title_max,bounds=bounds,plotopts=plotopts,plot_units=units)   # Call PlotSpatial function for difference values
}
if ((ametptype == "png") || (ametptype == "both")) {
   plotfmt <- "pdf"                                                                                                # Set plot format as pdf
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_max,figure=figure_max,varlab=title_max,bounds=bounds,plotopts=plotopts,plot_units=units)   # Call PlotSpatial function for difference values
}
#########################################

#######################################
### Plot Model/Model Min Difference ###
#######################################
unique_labels <- "y"                                                                                            # Flag within Misc_Functions.R to use predefined labels 
levLab <- leg_labels_max
if ((ametptype == "png") || (ametptype == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_min,figure=figure_min,varlab=title_min,bounds=bounds,plotopts=plotopts,plot_units=units)   # Call PlotSpatial function for difference values
}
if ((ametptype == "pdf") || (ametptype == "both")) {
   plotfmt <- "pdf"                                                                                                # Set plot format as pdf
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_min,figure=figure_min,varlab=title_min,bounds=bounds,plotopts=plotopts,plot_units=units)   # Call PlotSpatial function for difference values
}
#########################################
   
