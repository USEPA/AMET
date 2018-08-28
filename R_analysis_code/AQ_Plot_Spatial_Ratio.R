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
### Last modified by Wyat Appel: June, 2017
################################################################

## get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Load Required Libraries 
if(!require(maps)){stop("Required Package maps was not loaded")}
if(!require(mapdata)){stop("Required Package mapdata was not loaded")}

### Retrieve units label from database table ###
network <- network_names[1]														# When using mutiple networks, units from network 1 will be used
#units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")	# Create MYSQL query from units table

### Set file names and titles ###
figure_obs<-paste(run_name1,species,pid,"spatialplot_ratio_obs",sep="_")             # Filename for obs spatial plot
figure_mod<-paste(run_name1,species,pid,"spatialplot_ratio_mod",sep="_")             # Filename for model spatial plot
figure_diff<-paste(run_name1,species,pid,"spatialplot_ratio_diff",sep="_")           # Filename for diff spatial plot

figure_obs<-paste(figdir,figure_obs,sep="/")             # Filename for obs spatial plot
figure_mod<-paste(figdir,figure_mod,sep="/")             # Filename for model spatial plot
figure_diff<-paste(figdir,figure_diff,sep="/")           # Filename for diff spatial plot

################################################

########################################
### Set NULL values and plot symbols ###
########################################
sinfo_obs       <- NULL						# Set list for obs values to NULL
sinfo_mod       <- NULL						# Set list for model values to NULL
sinfo_diff      <- NULL						# Set list for difference values to NULL
sinfo_obs_data  <- NULL
sinfo_mod_data  <- NULL
sinfo_diff_data <- NULL
diff_min        <- NULL
all_lats        <- NULL
all_lons        <- NULL
all_obs         <- NULL
all_mod         <- NULL
all_diff        <- NULL
bounds          <- NULL						# Set map bounds to NULL
sub_title       <- NULL						# Set sub title to NULL
lev_lab         <- NULL
spch<-c(16,17,15,18)
spch2<-c(1,2,0,5)
symbols<-c("CIRCLE","TRIANGLE","SQUARE","DIAMOND")
########################################

remove_negatives <- 'n'      # Set remove negatives to false. Negatives are needed in the coverage calculation and will be removed automatically by Average
total_networks <- length(network_names)
for (j in 1:total_networks) {							# Loop through for each network
   Mod_Obs_Diff   <- NULL							# Set model/ob difference to NULL
   network        <- network_names[[j]]						# Determine network name from loop value
   #########################
   ## Query the database ###
   #########################
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info                     <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,species)
         data_exists                    <- sitex_info$data_exists
         if (data_exists == "y") {
            aqdat_query.df                 <- sitex_info$sitex_data
            aqdat_query.df                 <- aqdat_query.df[with(aqdat_query.df,order(network,stat_id)),]
            aqdat_query.df$PM_TOT_ob       <- aqdat_query.df[,9]
            aqdat_query.df$PM_TOT_mod      <- aqdat_query.df[,10]
            units                          <- as.character(sitex_info$units[[1]])
         }
         sitex_info2                    <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,"PM_TOT")
         data_exists2                   <- sitex_info2$data_exists
         if (data_exists2 == "y") {
            aqdat_query2.df                <- sitex_info2$sitex_data
            aqdat_query2.df                 <- aqdat_query2.df[with(aqdat_query2.df,order(network,stat_id)),]
         }
      }
      else {
         query_result   <- query_dbase(run_name1,network,c(species,"PM_TOT"))
         aqdat_query.df <- query_result[[1]]
         data_exists    <- query_result[[2]]
         data_exists2   <- "y"
         units 	        <- query_result[[3]]
      }
   }
   #######################

   {
      if ((data_exists == "n") || (data_exists2 == "n")) {
#            stats_all.df <- "No stats available.  Perhaps you choose a species for a network that does not observe that species."
#            sites_stats.df <- "No site stats available.  Perhaps you choose a species for a network that does not observe that species."
            total_networks <- (total_networks-1)
            sub_title<-paste(sub_title,network_label[j],"=No Data; ",sep="")      # Set subtitle based on network matched with the appropriate symbol
      }
      else {
         ####################################
         ## Compute Averages for Each Site ##
         ####################################
         averaging <- "a"
         aqdat_in.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=round(aqdat_query.df[,9],5),Mod_Value=round(aqdat_query.df[,10],5),Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month)
         aqdat.df <- Average(aqdat_in.df)

         aqdat_in2.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=aqdat_query.df$PM_TOT_ob,Mod_Value=aqdat_query.df$PM_TOT_mod,Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month)
         aqdat_PM.df <- Average(aqdat_in2.df)

         aqdat_merged.df <- merge(aqdat.df,aqdat_PM.df,by="Stat_ID")
         Mod_Obs_Diff <- ((aqdat_merged.df$Mod_Value.x/aqdat_merged.df$Mod_Value.y)*100)-((aqdat_merged.df$Obs_Value.x/aqdat_merged.df$Obs_Value.y)*100)
         aqdat_merged.df$Mod_Obs_Diff <- Mod_Obs_Diff
         units <- "percent"
         ####################################

         ##################################################
         ## Store values for each network in array lists ##
         ##################################################
         sinfo_obs_data[[j]]<-list(lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=(aqdat_merged.df$Obs_Value.x/aqdat_merged.df$Obs_Value.y)*100)
         sinfo_mod_data[[j]]<-list(lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=(aqdat_merged.df$Mod_Value.x/aqdat_merged.df$Mod_Value.y)*100)
         sinfo_diff_data[[j]]<-list(lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat_merged.df$Mod_Obs_Diff)

         all_lats <- c(all_lats,aqdat_merged.df$lat.x)
         all_lons <- c(all_lons,aqdat_merged.df$lon.x)
         all_obs  <- c(all_obs,(aqdat_merged.df$Obs_Value.x/aqdat_merged.df$Obs_Value.y)*100)
         all_mod  <- c(all_mod,(aqdat_merged.df$Mod_Value.x/aqdat_merged.df$Mod_Value.y)*100)
         all_diff <- c(all_diff,aqdat_merged.df$Mod_Obs_Diff)
         ##################################################
         sub_title<-paste(sub_title,symbols[j],"=",network_label[j],"; ",sep="")      # Set subtitle based on network matched with the symbol name used for that network
      }
   }
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
levs_interval		<- (max(levs)-min(levs))/(length(levs)-1)
length_levs		<- length(levs)
levs_legend		<- c(levs,max(levs)+levs_interval)
leg_labels		<- levs
lev_lab 		<- levs
levs_max		<- length(levs)
leg_labels[levs_max]	<- paste("> ",max(levs),sep="")
leg_labels		<- c(leg_labels,"")
levs[levs_max+1] 	<- 10000		# set the level maximum to 1000 in order to include all values
colors 			<- NULL
colors			<- all_colors(levs_max)
leg_colors		<- colors

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
leg_labels_diff[length_levs_diff]	<- paste(">",max(levs_diff))     # Label maximum level as greater than max defined value
leg_labels_diff				<- c(leg_labels_diff,"")        # Label maximum level as greater than max defined value 
leg_labels_diff				<- c("",leg_labels_diff)        # Label minimum level as less than max defined value
leg_labels_diff[2]			<- paste("<",min(levs_diff))	# Label minimum level as less than max defined value
levs_diff 				<- c(levs_diff,10000)		# Set extreme absolute value to capture all values
levs_diff 				<- c(-10000,levs_diff)		# Set extreme miniumum value to capture all values
zero_place 				<- which(levs_diff==0) 
levs_diff 				<- levs_diff[-zero_place]
levels_label_diff 			<- levels_label_diff[-zero_place]
cols_diff 				<- NULL
low_range				<- cool_colors(trunc(length(levels_label_diff)/2))
high_range				<- hot_colors(trunc(length(levels_label_diff)/2))
cols_diff 				<- c(low_range,"grey",high_range)
leg_colors_diff				<- c(low_range,"grey","grey",high_range)
#####################################################################

for (k in 1:total_networks) {

   sinfo_obs[[k]]<-list(lat=sinfo_obs_data[[k]]$lat,lon=sinfo_obs_data[[k]]$lon,plotval=sinfo_obs_data[[k]]$plotval,levs=levs,levcols=colors,levs_legend=levs_legend,cols_legend=leg_colors,convFac=.01)			# Create list to be used with PlotSpatial function
   sinfo_mod[[k]]<-list(lat=sinfo_mod_data[[k]]$lat,lon=sinfo_mod_data[[k]]$lon,plotval=sinfo_mod_data[[k]]$plotval,levs=levs,levcols=colors,levs_legend=levs_legend,cols_legend=leg_colors,convFac=.01)			# Create model list to be used with PlotSpatial fuction
   sinfo_diff[[k]]<-list(lat=sinfo_diff_data[[k]]$lat,lon=sinfo_diff_data[[k]]$lon,plotval=sinfo_diff_data[[k]]$plotval,levs=levs_diff,levcols=cols_diff,levs_legend=levs_legend_diff,cols_legend=leg_colors_diff,convFac=.01)	# Create diff list to be used with PlotSpatial fuction
}

###########################
### plot text options   ###
###########################
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") {
      title_obs<-paste("Observed Percent Contribution of ",species, " to Total PM2.5 for Run ",run_name1," for ", dates,sep="")			# Title for obs spatial plot
      title_mod<-paste("Modeled Percent Contribution of ",species, " to Total PM2.5 for Run ",run_name1," for ", dates,sep="")				# Title for model spatial plot
      title_diff<-paste("Modeled - Observed Percent Difference in the Contribution of ",species, " to Total PM2.5 for Run ",run_name1," for ", dates,sep="")		# Title for diff spatial plot
   }
   else {
      title_obs  <- custom_title
      title_mod  <- custom_title
      title_diff <- custom_title
   }
}
###########################

##############################################
## Create PNG and PDF plots for NMB and NME ##
##############################################

### Plot Observations ###
unique_labels <- "y"												# Do not use unique labels
levLab <- leg_labels												# Unique label array to use
if ((ametptype == "png") || (ametptype == "both")) { 
   plotfmt <-"png"  
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_obs,figure=figure_obs,varlab=title_obs,bounds=bounds,plotopts=plotopts,plot_units=units)	# Call PlotSpatial function for obs values
}
if ((ametptype == "pdf") || (ametptype == "both")) { 
   plotfmt <- "pdf"												# Set plot format as pdf
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_obs,figure=figure_obs,varlab=title_obs,bounds=bounds,plotopts=plotopts,plot_units=units)	# Call PlotSpatial function for ob values
}
#########################
### Plot Modeled Values ###
if ((ametptype == "png") || (ametptype == "both")) { 
   plotfmt <- "png"												# Set plot format as png
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_mod,figure=figure_mod,varlab=title_mod,bounds=bounds,plotopts=plotopts,plot_units=units)	# Call PlotSpatial function for model values
}
if ((ametptype == "pdf") || (ametptype == "both")) { 
   plotfmt <- "pdf"												# Set plot format as pdf
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_mod,figure=figure_mod,varlab=title_mod,bounds=bounds,plotopts=plotopts,plot_units=units)   	# Call PlotSpatial function for model values
}
###########################
### Plot Model/Observation Difference ###
unique_labels <- "y"												# Flag within Misc_Functions.R to use predefined labels
levLab <- leg_labels_diff			
if ((ametptype == "png") || (ametptype == "both")) { 								# Set lables to be ones defined above by levels_label_diff
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
   
