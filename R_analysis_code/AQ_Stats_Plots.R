################################################################
### THIS FILE CONTAINS CODE TO DRAW A CUSTOMIZED BOXPLOT DISPLAY.  It
### draws side-by-side boxplots for the various groups, without median
### lines or whiskers.  This means that to see the boxplot, we have to
### give it a colored background.  We also draw points at the medians
### of the boxplots, and connect these with lines.
### NOTE: The user should make sure the data is sorted by group before
### using this code.
###
### Last modified by Wyat Appel: June, 2017
################################################################

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")		        # base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Load Required Libraries 
if(!require(maps)){stop("Required Package maps was not loaded")}
if(!require(mapdata)){stop("Required Package mapdata was not loaded")}

################################################
## Set output names and remove existing files ##
################################################
filename_all 	<- paste(run_name1,species,pid,"stats.csv",sep="_")
filename_sites 	<- paste(run_name1,species,pid,"sites_stats.csv",sep="_")
filename_nmb	<- paste(run_name1,species,pid,"stats_plot_NMB",sep="_")
filename_nme	<- paste(run_name1,species,pid,"stats_plot_NME",sep="_")
filename_fb	<- paste(run_name1,species,pid,"stats_plot_FB",sep="_")
filename_fe	<- paste(run_name1,species,pid,"stats_plot_FE",sep="_")
filename_rmse	<- paste(run_name1,species,pid,"stats_plot_RMSE",sep="_")
filename_mb	<- paste(run_name1,species,pid,"stats_plot_MB",sep="_")
filename_me	<- paste(run_name1,species,pid,"stats_plot_ME",sep="_")
filename_corr	<- paste(run_name1,species,pid,"stats_plot_Corr",sep="_")
filename_txt 	<- paste(run_name1,species,pid,"stats_data.csv",sep="_")      # Set output file name

## Create a full path to file
filename_all 	<- paste(figdir,filename_all,sep="/")
filename_sites 	<- paste(figdir,filename_sites,sep="/")
filename_nmb	<- paste(figdir,filename_nmb,sep="/")
filename_nme	<- paste(figdir,filename_nme,sep="/")
filename_fb	<- paste(figdir,filename_fb,sep="/")
filename_fe	<- paste(figdir,filename_fe,sep="/")
filename_rmse	<- paste(figdir,filename_rmse,sep="/")
filename_mb	<- paste(figdir,filename_mb,sep="/")
filename_me	<- paste(figdir,filename_me,sep="/")
filename_corr	<- paste(figdir,filename_corr,sep="/")
filename_txt 	<- paste(figdir,filename_txt,sep="/")

#################################################

###########################
### Retrieve units label from database table ###
network <- network_names[1]
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql)
################################################

#########################
## plot text options   ##
#########################
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
title_nmb	<- paste(species, " NMB (%) for run ",run_name1," for ", dates,sep="")
title_fb	<- paste(species, " FB (%) for run ",run_name1," for ", dates,sep="")
title_nme	<- paste(species, " NME (%) for run ",run_name1," for ", dates,sep="")
title_fe	<- paste(species, " FE (%) for run ",run_name1," for ", dates,sep="")
title_rmse	<- paste(species, " RMSE for run ",run_name1," for ", dates,sep="")
title_mb	<- paste(species, " MB (",units,") for run",run_name1," for ",dates,sep="")
title_me	<- paste(species, " ME (",units,") for run",run_name1," for ",dates,sep="")
title_corr	<- paste(species, " Correlation for run ",run_name1," for ", dates,sep="")
#########################


if (length(num_ints) == 0) {
   num_ints <- 20 
}

sinfo_data <-NULL
sinfo_nmb  <-NULL
sinfo_nme  <-NULL
sinfo_fb   <-NULL
sinfo_fe   <-NULL
sinfo_rmse <-NULL
sinfo_mb   <-NULL
sinfo_me   <-NULL
sinfo_corr <-NULL
all_lat	   <-NULL
all_lon    <-NULL
all_nmb	   <-NULL
all_nme    <-NULL
all_fb     <-NULL
all_fe     <-NULL
all_rmse   <-NULL
all_mb     <-NULL
all_me     <-NULL
all_corr   <-NULL
bounds     <-NULL
sub_title  <-NULL

### Set plot characters ###
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
################################################

n <- 1
total_networks <- length(network_names)
for (j in 1:total_networks) {
   total_obs <- NULL
   network_number<-j							# Set network number (used as a flag later in the code)
   network<-network_names[[j]]						# Set network name
   criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")                # Set part of the MYSQL query
   check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name1,"' and COLUMN_NAME = 'POCode';",sep="")
   query_table_info.df <-db_Query(check_POCode,mysql)
   {
      if (length(query_table_info.df$COLUMN_NAME)==0) {
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")	# Set rest of the MYSQL criteria
         aqdat_query.df        <- db_Query(qs,mysql)
         aqdat_query.df$POCode <- 1
      }
      else {
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob,d.POCode from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")      # Set rest of the MYSQL criteria
         aqdat_query.df <- db_Query(qs,mysql)
      }
   }
   aqdat_query.df$stat_id  <- paste(aqdat_query.df$stat_id,aqdat_query.df$POCode,sep='')      # Create unique site using site ID and PO Code
   aqdat.df <- aqdat_query.df

   if (j == 1) {
      write.table(run_name1,file=filename_txt,append=F,row.names=F,sep=",")                       # Write header for raw data file
      write.table(network,file=filename_txt,append=T,row.names=F,sep=",")
      write.table(aqdat.df,file=filename_txt,append=T,row.names=F,sep=",")
   }
   if (j > 1) {
      write.table("",file=filename_txt,append=T,row.names=F,sep=",")
      write.table(network,file=filename_txt,append=T,row.names=F,sep=",")                       # Write header for raw data file
      write.table(aqdat.df,file=filename_txt,append=T,row.names=F,sep=",")
   } 

   #######################

   ### Check to see if there is any data from the database query ###
   count <- sum(is.na(aqdat.df[,9]))
   len   <- length(aqdat.df[,9])

   if (count == len) {
      stats_all.df <- "No stats available.  Perhaps you choose a species for a network that does not observe that species."
      sites_stats.df <- "No site stats available.  Perhaps you choose a species for a network that does not observe that species."
      total_networks <- (total_networks-1)
   }
   ##################################################################

   ### If there is data, continue ###
   else {
      if (use_avg_stats == "y") {
         aqdat.df <- Average(aqdat.df)
         aqdat.df <- data.frame(Network=I(aqdat.df$Network),Stat_ID=I(aqdat.df$Stat_ID),lat=aqdat.df$lat,lon=aqdat.df$lon,Obs_Value=aqdat.df$Obs_Value,Mod_Value=aqdat.df$Mod_Value,precip_ob=aqdat.df$precip_ob)
      }
      else {
         aqdat.df <- data.frame(Network=I(aqdat.df$network),Stat_ID=I(aqdat.df$stat_id),lat=aqdat.df$lat,lon=aqdat.df$lon,Obs_Value=aqdat.df[,9],Mod_Value=aqdat.df[,10],precip_ob=aqdat.df$precip_ob)
      }
      sub_title<-paste(sub_title,symbols[j],"=",network,"; ",sep="")
   
      ### Create properly formated dataframe to be used with DomainStats function and compute stats for entire domain ###
      data_all.df <- data.frame(network=I(aqdat.df$Network),stat_id=I(aqdat.df$Stat_ID),lat=aqdat.df$lat,lon=aqdat.df$lon,ob_val=aqdat.df$Obs_Value,mod_val=aqdat.df$Mod_Value,precip_val=aqdat.df$precip_ob)
      stats_all.df <-try(DomainStats(data_all.df))	# Compute stats using DomainStats function for entire domain
      ##################################

      ### Write output to comma delimited file ###
      header <- c(paste("Run Name = ",run_name1,sep=""),paste("Evaluation Dates = ",dates,sep=""),paste("Species = ",species,sep=""),paste("State = ",state,sep=""),paste("Site Name = ",site,sep=""))

      ### Compute site stats using SitesStats function ###
      sites_stats.df <- try(SitesStats(data_all.df))

      sinfo_data[[j]]<-list(lat=sites_stats.df$lat,lon=sites_stats.df$lon,NMB=sites_stats.df$NMB,NME=sites_stats.df$NME,MB=sites_stats.df$MB,ME=sites_stats.df$ME,FB=sites_stats.df$FB,FE=sites_stats.df$FE,RMSE=sites_stats.df$RMSE,COR=sites_stats.df$COR)

      all_nmb	<- c(all_nmb,sites_stats.df$NMB)
      all_nme	<- c(all_nme,sites_stats.df$NME)
      all_mb	<- c(all_mb,sites_stats.df$MB)
      all_me	<- c(all_me,sites_stats.df$ME)
      all_fb	<- c(all_fb,sites_stats.df$FB)
      all_fe	<- c(all_fe,sites_stats.df$FE)
      all_rmse	<- c(all_rmse,sites_stats.df$RMSE)
      all_corr	<- c(all_corr,sites_stats.df$COR)
      all_lat   <- c(all_lat,sites_stats.df$lat)
      all_lon   <- c(all_lon,sites_stats.df$lon)
   }

   ##########################################
   ## Write output to comma delimited file ##
   ##########################################
   header <- c(paste("Run Name = ",run_name1,sep=""),paste("Evaluation Dates = ",dates,sep=""),paste("Species = ",species,sep=""),paste("RPO = ",rpo,sep=""),paste("State = ",state,sep=""),paste("Site Name = ",site,sep=""))     # Set header information

   if (network_number==1) {                                                                                        # Determine if this is the first network
      write.table(header, file=filename_all, append=F, sep="," ,col.names=F, row.names=F)                   # Create domain stats file if first network
      write.table(header, file=filename_sites, append=F, sep="," ,col.names=F, row.names=F)                 # Create site stats file if first network
   }
   write.table("",file=filename_all,append=T,sep=",",col.names=F,row.names=F)                                    # Add blank line between networks (domain stats)
   write.table("",file=filename_sites,append=T,sep=",",col.names=F,row.names=F)                                  # Add blank line between networks (sites stats)

   write.table(network, file=filename_all, append=T ,sep=",",col.names=F,row.names=F)                            # Write network name (domain stats)
   write.table(network, file=filename_sites, append=T ,sep=",",col.names=F,row.names=F)                          # Write network name (sites stats)

   write.table(stats_all.df, file=filename_all, append=T, sep=",",col.names=T,row.names=F)           # Write domain stats
   write.table(sites_stats.df, file=filename_sites, append=T, sep=",",col.names=T,row.names=F)                   # Write sites stats

   ###########################################
}	# End network data query loop

##########################################################################
### Code to create color palette that will be used throughout the code ###
##########################################################################
hot_colors      <- colorRampPalette(c("yellow","orange","firebrick"))
cool_colors     <- colorRampPalette(c("darkorchid4","blue","green"))
all_colors      <- colorRampPalette(c("darkorchid4","blue","green","yellow","orange","firebrick"))
#all_colors      <- colorRampPalette(c("darkorchid4","blue","green4","green","yellow","yellow3","orange","firebrick"))
#all_colors      <- colorRampPalette(c("darkorchid4","blue","green4","green","yellow","orange","firebrick"))
       
### Create greyscale colors palette ###
if (greyscale == "y") {
   hot_colors     <- colorRampPalette(c("grey60","grey80","grey90"))
   cool_colors    <- colorRampPalette(c("grey0","grey20","grey40"))
   all_colors     <- colorRampPalette(c("grey95","grey80","grey60","grey40","grey20","grey0"))
}
#########################################################################

#########################
### Create NMB Scales ###
#########################
if ((length(perc_range_min) == 0) || (length(perc_range_max) == 0)) {
   perc_range_max <- quantile(abs(all_nmb),.95,na.rm=T)
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
levs_interval			<- (max(levs_nmb)-min(levs_nmb))/(length(levs_nmb)-1)
length_levs_nmb			<- length(levs_nmb)
levs_legend_nmb			<- c(min(levs_nmb)-levs_interval,levs_nmb,max(levs_nmb)+levs_interval)
leg_labels_nmb			<- levs_nmb
levs_nmb_max			<- length(levs_nmb)
leg_labels_nmb[levs_nmb_max]	<- paste(">",max(levs_nmb))	# Label maximum level as greater than max defined value
leg_labels_nmb			<- c(leg_labels_nmb,"")     	# Label maximum level as greater than max defined value 
leg_labels_nmb                    <- c("",leg_labels_nmb)   	# Label minimum level as less than max defined value
leg_labels_nmb[2]			<- paste("<",min(levs_nmb))	# Label minimum level as less than max defined value
levs_nmb				<- c(levs_nmb,100000)		# Set extreme absolute value to capture all values
levs_nmb				<- c(-100000,levs_nmb)		# Set extreme miniumum value to capture all values
zero_place			<- which(levs_nmb==0) 
levs_nmb				<- levs_nmb[-zero_place]
levcols_nmb			<- NULL
low_range				<- cool_colors(trunc(length_levs_nmb/2))
high_range			<- hot_colors(trunc(length_levs_nmb/2))
levcols_nmb			<- c(low_range,"grey50",high_range)
leg_colors_nmb			<- c(low_range,"grey50","grey50",high_range)
############################################
      
#########################
### Create NME Scales ###
#########################
if (length(perc_error_max) == 0) {
   perc_error_max <- quantile(abs(all_nme),0.95,na.rm=T)
}
error_range <- c(0,perc_error_max)
intervals <- num_ints
max_levs <- 21
while (max_levs > 20) {
   levs_nme <- pretty(error_range,intervals,min.n=5)
   max_levs <- length(levs_nme)
   intervals <- intervals-1
}
levs_interval                     <- max(levs_nme)/(length(levs_nme)-1)
length_levs_nme                   <- length(levs_nme)
levs_legend_nme                   <- c(levs_nme,max(levs_nme)+levs_interval)
lev_lab_nme 			<- levs_nme
leg_labels_nme			<- levs_nme
levs_nme_max			<- length(levs_nme)
leg_labels_nme[levs_nme_max]	<- paste(">",max(levs_nme))
leg_labels_nme                    <- c(leg_labels_nme,"")         # Label maximum level as greater than max defined value
levs_nme[levs_nme_max+1] 		<- 100000                        # Set extreme absolute value to capture values > than defined max
levcols_nme			<- NULL
levcols_nme			<- all_colors(length_levs_nme)
leg_colors_nme			<- levcols_nme
############################################

########################
### Create MB Scales ###
########################
if ((length(abs_range_min) == 0) || (length(abs_range_max) == 0)) {
   abs_range_max <- quantile(abs(all_mb),.95,na.rm=T)
   abs_range_min <- -abs_range_max
}
mb_range <- c(abs_range_min,abs_range_max)
intervals <- num_ints
max_levs <- 22
levs_mb <- NULL
while (max_levs > 21) {
   levs_mb <- pretty(mb_range,intervals,min.n=5)
   max_levs <- length(levs_mb)
   intervals <- intervals-1
}
levs_interval                     <- (max(levs_mb)-min(levs_mb))/(length(levs_mb)-1)
length_levs_mb                   <- length(levs_mb)
levs_legend_mb                   <- c(min(levs_mb)-levs_interval,levs_mb,max(levs_mb)+levs_interval)
leg_labels_mb                    <- levs_mb
levs_mb_max                      <- length(levs_mb)
leg_labels_mb[levs_mb_max]      <- paste(">",max(levs_mb))     # Label maximum level as greater than max defined value
leg_labels_mb                    <- c(leg_labels_mb,"")         # Label maximum level as greater than max defined value 
leg_labels_mb                    <- c("",leg_labels_mb)         # Label minimum level as less than max defined value
leg_labels_mb[2]                 <- paste("<",min(levs_mb))     # Label minimum level as less than max defined value
levs_mb                          <- c(levs_mb,100000)           # Set extreme absolute value to capture all values
levs_mb                          <- c(-100000,levs_mb)          # Set extreme miniumum value to capture all values
zero_place                        <- which(levs_mb==0)
levs_mb                          <- levs_mb[-zero_place]
levcols_mb                       <- NULL
low_range                         <- cool_colors(trunc(length_levs_mb/2))
high_range                        <- hot_colors(trunc(length_levs_mb/2))
levcols_mb                       <- c(low_range,"grey50",high_range)
leg_colors_mb                    <- c(low_range,"grey50","grey50",high_range)
############################################

########################
### Create ME Scales ###
########################
if (length(abs_error_max) == 0) {
   abs_error_max <- quantile(abs(all_me),0.95,na.rm=T)
}
me_range <- c(0,abs_error_max)
intervals <- num_ints
max_levs <- 21
while (max_levs > 20) {
   levs_me <- pretty(me_range,intervals,min.n=5)
   max_levs <- length(levs_me)
   intervals <- intervals-1
}
levs_interval                     <- max(levs_me)/(length(levs_me)-1)
length_levs_me                   <- length(levs_me)
levs_legend_me                   <- c(levs_me,max(levs_me)+levs_interval)
lev_lab_me                       <- levs_me
leg_labels_me                    <- levs_me
levs_me_max                      <- length(levs_me)
leg_labels_me[levs_me_max]      <- paste(">",max(levs_me))
leg_labels_me                    <- c(leg_labels_me,"")         # Label maximum level as greater than max defined value
levs_me[levs_me_max+1]          <- 100000                        # Set extreme absolute value to capture values > than defined max
levcols_me                       <- NULL
levcols_me                       <- all_colors(length_levs_me)
leg_colors_me                    <- levcols_me
############################################

######################### 
### Create RMSE Scale ###
#########################
if (length(rmse_range_max) == 0) {
   rmse_range_max <- quantile(all_rmse,.95,na.rm=T)
}
intervals <- num_ints
max_levs <- 23
while (max_levs > 22) {
   levs_rmse <- pretty(c(0,rmse_range_max),intervals)              # Create "pretty" ranges for the RMSE
   max_levs <- length(levs_rmse)
   intervals <- intervals-1
}
levs_interval                     <- max(levs_rmse)/(length(levs_rmse)-1)
length_levs_rmse                  <- length(levs_rmse)
levs_legend_rmse                  <- c(levs_rmse,max(levs_rmse)+levs_interval) 
lev_lab_rmse			<- levs_rmse
leg_labels_rmse			<- levs_rmse
levs_rmse_max 			<- length(levs_rmse)
leg_labels_rmse[levs_rmse_max]	<- paste(">",max(levs_rmse))     # Label maximum level for NME as greater than max defined value
leg_labels_rmse			<- c(leg_labels_rmse,"")
levs_rmse[levs_rmse_max+1] 	<- 100000
levcols_rmse 			<- NULL
levcols_rmse			<- all_colors(length_levs_rmse)
leg_colors_rmse			<- levcols_rmse
#############################################

#############################
### Set Correlation Scale ###
#############################
levs_corr 	<- c(-1.0,0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0)
levcols_corr	<- NULL
levcols_corr	<- all_colors(length(levs_corr)-1)
#############################

####################################################
### Set lat/lon max and min to set plotting area ###
####################################################
lat_min<-min(all_lat)
lat_max<-max(all_lat)
lon_min<-min(all_lon)
lon_max<-max(all_lon)
####################################################

#####################################
### Set bounds for the plot (map) ###
#####################################
bounds<-c(min(lat_min,bounds[1]),max(lat_max,bounds[2]),min(lon_min,bounds[3]),max(lon_max,bounds[4]))		# Set lat/lon bounds
plotsize<-1.50													# Set plot size
symb<-15														# Set symbol to use
symbsiz<-0.9                                                                         # Set symbol size
if (length(unique(aqdat.df$stat_id)) > 500) {
   symbsiz <- 0.6
}
if (length(unique(aqdat.df$stat_id)) > 10000) {
   symbsiz <- 0.3
}
##################################### 
      
###################################################################################################### 
### Create lists for each statistic that is properly formatted to use with the PlotSpaial function ###
######################################################################################################
for (n in 1:total_networks) {
   sinfo_nmb[[n]]<-list(lat=sinfo_data[[n]]$lat,lon=sinfo_data[[n]]$lon,plotval=sinfo_data[[n]]$NMB,levs=levs_nmb,levcols=levcols_nmb,levs_legend=levs_legend_nmb,cols_legend=leg_colors_nmb,convFac=.01)
   sinfo_nme[[n]]<-list(lat=sinfo_data[[n]]$lat,lon=sinfo_data[[n]]$lon,plotval=sinfo_data[[n]]$NME,levs=levs_nme,levcols=levcols_nme,levs_legend=levs_legend_nme,cols_legend=leg_colors_nme,convFac=.01)
   sinfo_fb[[n]]<-list(lat=sinfo_data[[n]]$lat,lon=sinfo_data[[n]]$lon,plotval=sinfo_data[[n]]$FB,levs=levs_nmb,levcols=levcols_nmb,levs_legend=levs_legend_nmb,cols_legend=leg_colors_nmb,convFac=.01)
   sinfo_fe[[n]]<-list(lat=sinfo_data[[n]]$lat,lon=sinfo_data[[n]]$lon,plotval=sinfo_data[[n]]$FE,levs=levs_nme,levcols=levcols_nme,levs_legend=levs_legend_nme,cols_legend=leg_colors_nme,convFac=.01)
   sinfo_rmse[[n]]<-list(lat=sinfo_data[[n]]$lat,lon=sinfo_data[[n]]$lon,plotval=sinfo_data[[n]]$RMSE,levs=levs_rmse,levcols=levcols_rmse,levs_legend=levs_legend_rmse,cols_legend=leg_colors_rmse,convFac=.01)
   sinfo_mb[[n]]<-list(lat=sinfo_data[[n]]$lat,lon=sinfo_data[[n]]$lon,plotval=sinfo_data[[n]]$MB,levs=levs_mb,levcols=levcols_mb,levs_legend=levs_legend_mb,cols_legend=leg_colors_mb,convFac=.01)
   sinfo_me[[n]]<-list(lat=sinfo_data[[n]]$lat,lon=sinfo_data[[n]]$lon,plotval=sinfo_data[[n]]$ME,levs=levs_me,levcols=levcols_me,levs_legend=levs_legend_me,cols_legend=leg_colors_me,convFac=.01)
   sinfo_corr[[n]]<-list(lat=sinfo_data[[n]]$lat,lon=sinfo_data[[n]]$lon,plotval=sinfo_data[[n]]$COR,levs=levs_corr,levcols=levcols_corr,levs_legend=levs_corr,cols_legend=levcols_corr,convFac=.01)
#n <- n+1
}
######################################################################################################

##############################################
## Create PNG and PDF plots for NMB and NME ##
##############################################

### Create Normalized Mean Bias (NMB) plots ###
unique_labels <- "y"												# Set use of unique labels as true
levLab <- leg_labels_nmb												# Set labels to use on the plot
if ((ametptype == "png") || (ametptype == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)					# Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_nmb,figure=filename_nmb,varlab=title_nmb,bounds=bounds,plotopts=plotopts,plot_units="%")	# Create plot (map) for nmb in png format
   plotSpatial(sinfo_fb,figure=filename_fb,varlab=title_fb,bounds=bounds,plotopts=plotopts,plot_units="%")		# Create plot (map) for fb in png format
}
if ((ametptype == "pdf") || (ametptype == "both")) {
   plotfmt <- "pdf"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)
   plotSpatial(sinfo_nmb,figure=filename_nmb,varlab=title_nmb,bounds=bounds,plotopts=plotopts,plot_units="%")	# Create plot (map) for nmb in pdf format
   plotSpatial(sinfo_fb,figure=filename_fb,varlab=title_fb,bounds=bounds,plotopts=plotopts,plot_units="%")		# Create plot (map) for fb in pdf format
}
###############################################

### Create Normalized Mean Error (NME) plots ###
levLab <- leg_labels_nme
if ((ametptype == "png") || (ametptype == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)
   plotSpatial(sinfo_nme,figure=filename_nme,varlab=title_nme,bounds=bounds,plotopts=plotopts,plot_units="%")
   plotSpatial(sinfo_fe,figure=filename_fe,varlab=title_fe,bounds=bounds,plotopts=plotopts,plot_units="%")
}
if ((ametptype == "pdf") || (ametptype == "both")) {
   plotfmt <- "pdf"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)
   plotSpatial(sinfo_nme,figure=filename_nme,varlab=title_nme,bounds=bounds,plotopts=plotopts,plot_units="%")   
   plotSpatial(sinfo_fe,figure=filename_fe,varlab=title_fe,bounds=bounds,plotopts=plotopts,plot_units="%")
}
################################################

### Create Mean Bias plot ###
levLab <- leg_labels_mb                                                                                         # Set labels to use on the plot
if ((ametptype == "png") || (ametptype == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_mb,figure=filename_mb,varlab=title_mb,bounds=bounds,plotopts=plotopts,plot_units=units)        # Create plot (map) for nmb in png format
}
if ((ametptype == "pdf") || (ametptype == "both")) {
   plotfmt <-"pdf"                                                                                                 # Set plot format as png
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_mb,figure=filename_mb,varlab=title_mb,bounds=bounds,plotopts=plotopts,plot_units=units)        # Create plot (map) for nmb in png format
}
#################################################

### Create Mean Error plot ###
levLab <- leg_labels_me                                                                                         # Set labels to use on the plot
if ((ametptype == "png") || (ametptype == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_me,figure=filename_me,varlab=title_me,bounds=bounds,plotopts=plotopts,plot_units=units)        # Create plot (map) for nmb in png format
}
if ((ametptype == "pdf") || (ametptype == "both")) {
   plotfmt <-"pdf"                                                                                                 # Set plot format as png
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)                                     # Set plot options list to use with PlotSpatial function
   plotSpatial(sinfo_me,figure=filename_me,varlab=title_me,bounds=bounds,plotopts=plotopts,plot_units=units)        # Create plot (map) for nmb in png format
}
#################################################

### Create Root Mean Square Error (RMSE) plots ###
levLab <- leg_labels_rmse
if ((ametptype == "png") || (ametptype == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz) 
   plotSpatial(sinfo_rmse,figure=filename_rmse,varlab=title_rmse,bounds=bounds,plotopts=plotopts,plot_units=units)
}
if ((ametptype == "pdf") || (ametptype == "both")) {
   plotfmt <- "pdf" 
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz) 
   plotSpatial(sinfo_rmse,figure=filename_rmse,varlab=title_rmse,bounds=bounds,plotopts=plotopts,plot_units=units)
}
###############################################

### Create Correlation (Corr) plots ###
levLab <- levs_corr
if ((ametptype == "png") || (ametptype == "both")) {
   plotfmt <- "png"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)
   plotSpatial(sinfo_corr,figure=filename_corr,varlab=title_corr,bounds=bounds,plotopts=plotopts,plot_units="None")
}
if ((ametptype == "pdf") || (ametptype == "both")) {
   plotfmt <- "pdf"
   plotopts<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)
   plotSpatial(sinfo_corr,figure=filename_corr,varlab=title_corr,bounds=bounds,plotopts=plotopts,plot_units="None")
}
########################################
