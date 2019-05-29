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
#units_qs <- paste("SELECT ",species[1]," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")	# Create MYSQL query from units table

figure_diff	<- paste(run_name1,pid,"spatialplot_mtom_species_diff_avg",sep="_")           # Filename for diff spatial plot
figure_max	<- paste(run_name1,pid,"spatialplot_mtom_species_diff_max",sep="_")               # Filename for diff spatial plot
figure_min	<- paste(run_name1,pid,"spatialplot_mtom_species_diff_min",sep="_")               # Filename for diff spatial plot
figure_perc     <- paste(run_name1,pid,"spatialplot_mtom_species_diff_perc",sep="_")               # Filename for diff spatial plot

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(run_name1,species[1],"-",species[2],"for",dates,sep=" ") }
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
sinfo_perc	<- NULL
sinfo_diff_data <- NULL
sinfo_max_data  <- NULL
sinfo_min_data  <- NULL
sinfo_perc_data <- NULL
diff_min        <- NULL
all_lats        <- NULL
all_lons        <- NULL
all_diff        <- NULL
all_perc	<- NULL
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

remove_negatives <- "n"
total_network    <- length(network_names)
ob_col_name1     <- paste(species[1],"_ob",sep="")
mod_col_name1    <- paste(species[1],"_mod",sep="")
ob_col_name2     <- paste(species[2],"_ob",sep="")
mod_col_name2    <- paste(species[2],"_mod",sep="")
for (j in 1:total_networks) {                                            # Loop through for each network
   sites	<- NULL
   lats		<- NULL
   lons		<- NULL
   avg_diff	<- NULL
   max_diff	<- NULL
   min_diff	<- NULL
   perc_diff	<- NULL
   network   	<- network_names[[j]]                                              # Set network name
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,species[1])
         aqdat_query.df   <- sitex_info$sitex_data
         aqdat_query.df	  <- aqdat_query.df[with(aqdat_query.df,order(network,stat_id)),]
         data_exists	  <- sitex_info$data_exists
         sitex_info2      <- read_sitex(Sys.getenv("OUTDIR2"),network,run_name1,species[2])
         aqdat_query2.df  <- sitex_info2$sitex_data
         aqdat_query2.df  <- aqdat_query2.df[with(aqdat_query2.df,order(network,stat_id)),]
         data_exists2     <- sitex_info2$data_exists
         units            <- as.character(sitex_info$units[[1]])
      }
      else {
         query_result     <- query_dbase(run_name1,network,species[1])
         aqdat_query.df   <- query_result[[1]]
         data_exists      <- query_result[[2]]
         query_result2    <- query_dbase(run_name1,network,species[2])
         aqdat_query2.df  <- query_result2[[1]]
         data_exists2     <- query_result2[[2]]
         if (data_exists == "y") { units <- query_result[[3]] }
      }
   }
   aqdat1.df        <- aqdat_query.df
   aqdat2.df        <- aqdat_query2.df
   {
      if ((data_exists == "n") || (data_exists2 == "n")) {
         All_Data       <- "No stats available.  Perhaps you choose a species for a network that does not observe that species."
         total_networks <- (total_networks-1)
         sub_title      <- paste(sub_title,network,"=No Data; ",sep="")
         if (total_networks == 0) { stop("Stopping because total_networks is zero. Likely no data found for query.") }
      }
      else {
         ### Match the points between each of the runs.  This is necessary if the data from each query do not match exactly ###
         aqdat1.df$statdate<-paste(aqdat1.df$stat_id,aqdat1.df$ob_dates,aqdat1.df$ob_hour,sep="")     # Create unique column that combines the site name with the ob start date for run 1
         aqdat2.df$statdate<-paste(aqdat2.df$stat_id,aqdat2.df$ob_dates,aqdat2.df$ob_hour,sep="")     # Create unique column that combines the site name with the ob start date for run 2
         if (length(aqdat1.df$statdate) <= length(aqdat2.df$statdate)) {                              # If more obs in run 1 than run 2
            match.ind<-match(aqdat1.df$statdate,aqdat2.df$statdate)                                   # Match the unique column (statdate) between the two runs
            aqdat_temp.df<-data.frame(network=aqdat1.df$network, stat_id=aqdat1.df$stat_id, lat=aqdat1.df$lat, lon=aqdat1.df$lon, dates=aqdat1.df$ob_dates, aqdat1.df[[mod_col_name1]], aqdat2.df[match.ind,mod_col_name2], aqdat1.df[[ob_col_name1]], aqdat2.df[match.ind,ob_col_name2], month=aqdat1.df$month)      # eliminate points that are not common between the two runs
         }
         else { match.ind<-match(aqdat2.df$statdate,aqdat1.df$statdate)                               # If more obs in run 2 than run 1
            aqdat_temp.df<-data.frame(network=aqdat2.df$network, stat_id=aqdat2.df$stat_id, lat=aqdat2.df$lat, lon=aqdat2.df$lon, ob_dates=aqdat2.df$ob_dates, aqdat1.df[match.ind,mod_col_name1], aqdat2.df[[mod_col_name2]], aqdat1.df[match.ind,ob_col_name1], aqdat2.df[[ob_col_name2]], month=aqdat2.df$month)      # eliminate points that are not common between the two runs
         }
         aqdat.df <- data.frame(Network=aqdat_temp.df$network,Stat_ID=aqdat_temp.df$stat_id,lat=aqdat_temp.df$lat,lon=aqdat_temp.df$lon,Mod_Value1=aqdat_temp.df[,7],Mod_Value2=aqdat_temp.df[,6])

         ### Remove NAs ###
         indic.na <- is.na(aqdat.df$Mod_Value1)
         aqdat.df <- aqdat.df[!indic.na,]
         indic.na <- is.na(aqdat.df$Mod_Value2)
         aqdat.df <- aqdat.df[!indic.na,]
         ##################

         split_sites_all  <- split(aqdat.df, aqdat.df$Stat_ID)
         for (i in 1:length(split_sites_all)) {                                               # Run averaging for each site for each month
            sub_all.df  <- split_sites_all[[i]]                                               # Store current site i in sub_all.df dataframe
            if (length(sub_all.df$Stat_ID) > 0) {						# Check that site has data available
               sites        <- c(sites, unique(sub_all.df$Stat_ID))                          	# Add current site to site list 
               lats         <- c(lats, unique(sub_all.df$lat))                               	# Add current lat to lat list
               lons         <- c(lons, unique(sub_all.df$lon))                               	# Add current lon to lon list
               if ((network == 'NADP') || (species[1] == "precip")) {
                  avg_diff <- c(avg_diff, (sum(sub_all.df$Mod_Value2)-sum(sub_all.df$Mod_Value1)))       # Compute model/ob difference
               }
               else {                                                                         # use averaging for all other networks
                  avg_diff <- c(avg_diff, (mean(sub_all.df$Mod_Value2)-mean(sub_all.df$Mod_Value1)))     # Compute model/ob difference
               }
               max_diff <- c(max_diff, max(sub_all.df$Mod_Value2-sub_all.df$Mod_Value1))
               min_diff <- c(min_diff, min(sub_all.df$Mod_Value2-sub_all.df$Mod_Value1))
               perc_diff <- c(perc_diff, ((mean(sub_all.df$Mod_Value2)-mean(sub_all.df$Mod_Value1)))/mean(sub_all.df$Mod_Value1)*100)
            }
         }
         sinfo_max_data[[j]]<-list(lat=lats,lon=lons,plotval=max_diff)
         sinfo_min_data[[j]]<-list(lat=lats,lon=lons,plotval=min_diff)
         sinfo_diff_data[[j]]<-list(lat=lats,lon=lons,plotval=avg_diff)
         sinfo_perc_data[[j]]<-list(lat=lats,lon=lons,plotval=perc_diff)
    
         all_lats <- c(all_lats,lats)
         all_lons <- c(all_lons,lons)
         all_diff <- c(all_diff,avg_diff)
         all_max  <- c(all_max,max_diff)
         all_min  <- c(all_min,min_diff)
         all_perc <- c(all_perc,perc_diff)
         sub_title    <- paste(sub_title,symbols[j],"=",network_label[j],"; ",sep="")      # Set subtitle based on network matched w/ the appropriate symbol
      }
   }
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
   num_ints <- 20
}
intervals <- num_ints
####################################################################

############################################
### Determine levels for difference plot ###
############################################
intervals <- num_ints
{
   if ((length(diff_range_min) == 0) || (length(diff_range_max) == 0)) {
      diff_max <- max(quantile(abs(all_diff)),quantile_max)
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

#########################
### Create NMB Scales ###
#########################
if ((length(perc_range_min) == 0) || (length(perc_range_max) == 0)) {
   perc_range_max <- quantile(abs(perc_diff),quantile_max,na.rm=T)
   perc_range_min <- -perc_range_max
}
bias_range <- c(perc_range_min,perc_range_max)
intervals <- num_ints
max_levs <- 24
levs_nmb <- NULL
while (max_levs > 23) {
   levs_nmb <- pretty(bias_range,intervals,min.n=5)
   max_levs <- length(levs_nmb)
   intervals <- intervals-1
}
levs_interval                   <- (max(levs_nmb)-min(levs_nmb))/(length(levs_nmb)-1)
length_levs_nmb                 <- length(levs_nmb)
levs_legend_nmb                 <- c(min(levs_nmb)-levs_interval,levs_nmb,max(levs_nmb)+levs_interval)
leg_labels_nmb                  <- levs_nmb
levs_nmb_max                    <- length(levs_nmb)
leg_labels_nmb[levs_nmb_max]    <- paste(">",max(levs_nmb))     # Label maximum level as greater than max defined value
leg_labels_nmb                  <- c(leg_labels_nmb,"")         # Label maximum level as greater than max defined value
leg_labels_nmb                  <- c("",leg_labels_nmb)       # Label minimum level as less than max defined value
leg_labels_nmb[2]               <- paste("<",min(levs_nmb))     # Label minimum level as less than max defined value
levs_nmb                        <- c(levs_nmb,100000)           # Set extreme absolute value to capture all values
levs_nmb                        <- c(-100000,levs_nmb)          # Set extreme miniumum value to capture all values
zero_place                      <- which(levs_nmb==0)
levs_nmb                        <- levs_nmb[-zero_place]
cols_nmb                        <- NULL
low_range                       <- cool_colors(trunc(length_levs_nmb/2))
high_range                      <- hot_colors(trunc(length_levs_nmb/2))
cols_nmb                        <- c(low_range,"grey50",high_range)
leg_colors_nmb                  <- c(low_range,"grey50","grey50",high_range)
############################################


#####################################
### Determine levels for max plot ###
#####################################
intervals <- num_ints
{
   if ((length(abs_range_min) == 0) || (length(abs_range_max) == 0)) {
      max_max <- max(c(quantile(abs(all_max),quantile_max),quantile(abs(all_min),quantile_max)))
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

for (l in 1:total_networks) {

   sinfo_diff[[l]]<-list(lat=sinfo_diff_data[[l]]$lat,lon=sinfo_diff_data[[l]]$lon,plotval=sinfo_diff_data[[l]]$plotval,levs=levs_diff,levcols=cols_diff,levs_legend=levs_legend_diff,cols_legend=leg_colors_diff,convFac=.01)	# Create diff list to be used with PlotSpatial fuction
   sinfo_max[[l]]<-list(lat=sinfo_max_data[[l]]$lat,lon=sinfo_max_data[[l]]$lon,plotval=sinfo_max_data[[l]]$plotval,levs=levs_max,levcols=cols_max,levs_legend=levs_legend_max,cols_legend=leg_colors_max,convFac=.01)   # Create diff list to be used with PlotSpatial fuction
   sinfo_min[[l]]<-list(lat=sinfo_min_data[[l]]$lat,lon=sinfo_min_data[[l]]$lon,plotval=sinfo_min_data[[l]]$plotval,levs=levs_max,levcols=cols_max,levs_legend=levs_legend_max,cols_legend=leg_colors_max,convFac=.01)   # Create diff list to be used with PlotSpatial fuction
   sinfo_perc[[l]]<-list(lat=sinfo_min_data[[l]]$lat,lon=sinfo_min_data[[l]]$lon,plotval=sinfo_perc_data[[l]]$plotval,levs=levs_nmb,levcols=cols_nmb,levs_legend=levs_legend_nmb,cols_legend=leg_colors_nmb,convFac=.01)   # Create diff list to be used with PlotSpatial fuction
}


###########################
### plot text options   ###
###########################
{
   if (custom_title == "") {
      title_diff<-paste("Average Difference of",run_name1,species[1],"-",species[2],"for",dates,sep=" ")	# Title for diff spatial plot
      title_max<-paste("Maximum Difference of",run_name1,species[1],"-",species[2],"for",dates,sep=" ")         # Title for diff spatial plot
      title_min<-paste("Minimum Difference of",run_name1,species[1],"-",species[2],"for",dates,sep=" ")         # Title for diff spatial plot
      title_perc<-paste("Percent Difference of",run_name1,species[1],"-",species[2],"for",dates,sep=" ")         # Title for diff spatial plot
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

#######################################
### Plot Model/Model Min Difference ###
#######################################
unique_labels <- "y"                                                                                            # Flag within Misc_Functions.R to use predefined labels
levLab <- leg_labels_nmb
if ((ametptype == "png") || (ametptype == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_perc,figure=figure_perc,varlab=title_perc,bounds=bounds,plotopts=plotopts,plot_units=units)   # Call PlotSpatial function for difference values
}
if ((ametptype == "pdf") || (ametptype == "both")) {
   plotfmt <- "pdf"                                                                                                # Set plot format as pdf
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_perc,figure=figure_perc,varlab=title_perc,bounds=bounds,plotopts=plotopts,plot_units=units)   # Call PlotSpatial function for difference values
}
#########################################
   
