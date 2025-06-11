header <- "
############################### INTERACTIVE PLOT SPATIAL DIFF #################################
### AMET CODE: AQ_Plot_Spatial_Diff_leaflet.R 
###
### This code is part of the AMET-AQ system.  The Plot Spatial Diff code takes a MYSQL database 
### query for a single species from one or more networks and two simulations and plots the bias 
### and error for each simulation, and the difference in bias and error between each simulation.
### This particular code utilizes the leaflet package to create an interactive plot with zoom 
### capability. PANDOC is used to create a self-contained HTML file. Cool colors indicate lower 
### bias/error in simulation 1 versus simulation 2, while warm colors indicate higher bias/error
### in simulation 1 versus simulation 2. 
###
### Last modified by Wyat Appel: June 2025
################################################################################################
"

## get some environmental variables and setup some directories
ametbase	<- Sys.getenv("AMETBASE")			# base directory of AMET
ametR		<- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Load Required Libraries
if(!require(maps))		{ stop("Required Package maps was not loaded") 		}
if(!require(mapdata))		{ stop("Required Package mapdata was not loaded") 	}
if(!require(leaflet))		{ stop("Required package leaflet was not loaded") 	}
if(!require(htmlwidgets))	{ stop("Required package htmlwidgets was not loaded") 	}
if(!require(webshot))		{ stop("Required Package webshot was not loaded") 	}
if(!require(plotly))		{ stop("Required Package plotly was not loaded") 	}

if(!exists("quantile_min")) { quantile_min <- 0.001 }
if(!exists("quantile_max")) { quantile_max <- 0.950 }
if(!exists("png_from_html")) { png_from_html <- "n" }

## Set some defaults
network 	<- network_names[1]	# When using mutiple networks, units from network 1 will be used
filename 	<- NULL
filename_png 	<- NULL

### Set file names and titles ###
filename_bias_1		 <- paste(run_name1,species,pid,"spatialplot_bias_1",sep="_")       # Filename for obs spatial plot
filename_bias_2		 <- paste(run_name1,species,pid,"spatialplot_bias_2",sep="_")       # Filename for model spatial plot
filename_bias_diff	 <- paste(run_name1,species,pid,"spatialplot_bias_diff",sep="_") # Filename for diff spatial plot
filename_error_1	 <- paste(run_name1,species,pid,"spatialplot_error_1",sep="_")     # Filename for obs spatial plot
filename_error_2	 <- paste(run_name1,species,pid,"spatialplot_error_2",sep="_")     # Filename for model spatial plot
filename_error_diff	 <- paste(run_name1,species,pid,"spatialplot_error_diff",sep="_")       # Filename for diff spatial plot
filename_corr_1          <- paste(run_name1,species,pid,"spatialplot_corr_1",sep="_")     # Filename for obs spatial plot
filename_corr_2          <- paste(run_name1,species,pid,"spatialplot_corr_2",sep="_")     # Filename for model spatial plot
filename_corr_diff       <- paste(run_name1,species,pid,"spatialplot_corr_diff",sep="_") # Filename for diff spatial plot
filename_csv  		 <- paste(run_name1,species,pid,"spatialplot_diff.csv",sep="_")
filename_bias_hist       <- paste(run_name1,species,pid,"histogram_bias_diff",sep="_") # Filename for diff spatial plot
filename_error_hist      <- paste(run_name1,species,pid,"histogram_error_diff",sep="_") # Filename for diff spatial plot
filename_corr_hist       <- paste(run_name1,species,pid,"histogram_corr_diff",sep="_") # Filename for diff spatial plot

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(run_name1,species,"for",network_label[1],"for",dates,sep=" ") }
   else { title <- custom_title }
}

## Create a full path to file
filename[1]          <- paste(figdir,"/",filename_bias_1,".html",sep="")		# Filename for obs spatial plot
filename[2]          <- paste(figdir,"/",filename_bias_2,".html",sep="")       	# Filename for model spatial plot
filename[7]          <- paste(figdir,"/",filename_bias_diff,".html",sep="") 		# Filename for diff spatial plot
filename[3]          <- paste(figdir,"/",filename_error_1,".html",sep="")     	# Filename for obs spatial plot
filename[4]          <- paste(figdir,"/",filename_error_2,".html",sep="")     	# Filename for model spatial plot
filename[8]          <- paste(figdir,"/",filename_error_diff,".html",sep="")     	# Filename for diff spatial plot
filename[5]          <- paste(figdir,"/",filename_corr_1,".html",sep="")       # Filename for obs spatial plot
filename[6]          <- paste(figdir,"/",filename_corr_2,".html",sep="")       # Filename for model spatial plot
filename[9]          <- paste(figdir,"/",filename_corr_diff,".html",sep="")            # Filename for diff spatial plot
filename_png[1]      <- paste(figdir,"/",filename_bias_1,".png",sep="")           # Filename for obs spatial plot
filename_png[2]      <- paste(figdir,"/",filename_bias_2,".png",sep="")           # Filename for model spatial plot
filename_png[7]      <- paste(figdir,"/",filename_bias_diff,".png",sep="")                # Filename for diff spatial plot
filename_png[3]      <- paste(figdir,"/",filename_error_1,".png",sep="")          # Filename for obs spatial plot
filename_png[4]      <- paste(figdir,"/",filename_error_2,".png",sep="")          # Filename for model spatial plot
filename_png[8]      <- paste(figdir,"/",filename_error_diff,".png",sep="")       # Filename for diff spatial plot
filename_png[5]      <- paste(figdir,"/",filename_corr_1,".png",sep="")          # Filename for obs spatial plot
filename_png[6]      <- paste(figdir,"/",filename_corr_2,".png",sep="")          # Filename for model spatial plot
filename_png[9]      <- paste(figdir,"/",filename_corr_diff,".png",sep="")       # Filename for diff spatial plot
filename_bias_hist_html   <- paste(figdir,"/",filename_bias_hist,".html",sep="")
filename_error_hist_html  <- paste(figdir,"/",filename_error_hist,".html",sep="")
filename_corr_hist_html   <- paste(figdir,"/",filename_corr_hist,".html",sep="")
filename_bias_hist_png    <- paste(figdir,"/",filename_bias_hist,".png",sep="")
filename_error_hist_png   <- paste(figdir,"/",filename_error_hist,".png",sep="")
filename_corr_hist_png    <- paste(figdir,"/",filename_corr_hist,".png",sep="")
filename_csv	          <- paste(figdir,filename_csv,sep="/")

#################################

### Set NULL values and plot symbols ###
sinfo_data		<- NULL
diff_min        <- NULL
all_sites	<- NULL
all_lats        <- NULL
all_lons        <- NULL
all_states	<- NULL
all_bias	<- NULL
all_bias2	<- NULL
all_error	<- NULL
all_error2	<- NULL
all_bias_diff	<- NULL
all_error_diff	<- NULL
all_corr	<- NULL
all_corr2	<- NULL
all_corr_diff	<- NULL
map_title	<- NULL
########################################

remove_negatives <- 'n'      # Set remove negatives to false. Negatives are needed in the coverage calculation and will be removed automatically by Average
for (j in 1:total_networks) {							# Loop through for each network
   sites          	<- NULL							# Set sites vector to NULL
   lats          	<- NULL							# Set lats vector to NULL
   lons          	<- NULL							# Set lons vector to NULL
   states		<- NULL
   mod_bias_1_all	<- NULL							# Set obs average to NULL
   mod_bias_2_all	<- NULL							# Set model average to NULL
   bias_diff		<- NULL							# Set model/ob difference to NULL
   mod_error_1_all   	<- NULL                                                 # Set obs average to NULL
   mod_error_2_all   	<- NULL                                                 # Set model average to NULL
   error_diff    	<- NULL
   mod_corr_1_all	<- NULL
   mod_corr_2_all	<- NULL
   corr_diff		<- NULL
   network_number 	<- j							# Set network number to loop value
   network        	<- network_names[[j]]					# Determine network name from loop value
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info        <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,species)
         data_exists       <- sitex_info$data_exists
         if (data_exists == 'y') {
            aqdat_query.df <- sitex_info$sitex_data
            aqdat_query.df <- aqdat_query.df[with(aqdat_query.df,order(network,stat_id)),]
         }
         sitex_info2        <- read_sitex(Sys.getenv("OUTDIR2"),network,run_name2,species)
         data_exists2       <- sitex_info2$data_exists
         if (data_exists2 == 'y') {
            aqdat_query2.df <- sitex_info2$sitex_data
            aqdat_query2.df <- aqdat_query2.df[with(aqdat_query2.df,order(network,stat_id)),]
         }
         units              <- as.character(sitex_info$units[[1]])
      }
      else {
         query_result     <- query_dbase(run_name1,network,species)
         aqdat_query.df   <- query_result[[1]]
         data_exists      <- query_result[[2]]
         query_result2    <- query_dbase(run_name2,network,species)
         aqdat_query2.df  <- query_result2[[1]]
         data_exists2     <- query_result2[[2]]
         if (data_exists == "y") { units <- query_result[[3]] }
      }
   }
   aqdat1.df <- aqdat_query.df
   aqdat2.df <- aqdat_query2.df
   ob_col_name <- paste(species,"_ob",sep="")
   mod_col_name <- paste(species,"_mod",sep="")
   {
      if ((data_exists == "n") || (data_exists2 == "n")) {
         All_Data       <- "No stats available.  Perhaps you choose a species for a network that does not observe that species."
         total_networks <- (total_networks-1)
         if (total_networks == 0) { stop("Stopping because total_networks is zero. Likely no data found for query.") }
      }

      ### If there are data, continue ###
      else {
	 ### Match the points between each of the runs.  This is necessary if the data from each query do not match exactly ###
         aqdat1.df$statdate<-paste(aqdat1.df$stat_id,aqdat1.df$ob_dates,aqdat1.df$ob_datee,aqdat1.df$ob_hour,sep="")     # Create unique column that combines the site name with the ob start date for run 1
         aqdat2.df$statdate<-paste(aqdat2.df$stat_id,aqdat2.df$ob_dates,aqdat2.df$ob_datee,aqdat2.df$ob_hour,sep="")     # Create unique column that combines the site name with the ob start date for run 2
         {
            if (length(aqdat1.df$statdate) <= length(aqdat2.df$statdate)) {                              # If more obs in run 1 than run 2
               match.ind<-match(aqdat1.df$statdate,aqdat2.df$statdate)                                   # Match the unique column (statdate) between the two runs
               aqdat.df<-data.frame(network=aqdat1.df$network, stat_id=I(aqdat1.df$stat_id), lat=aqdat1.df$lat, lon=aqdat1.df$lon, state=aqdat1.df$state, ob_dates=aqdat1.df$ob_dates, Mod_Value_1=aqdat1.df[[mod_col_name]], Mod_Value_2=aqdat2.df[match.ind,mod_col_name], Ob_Value_1=aqdat1.df[[ob_col_name]], Ob_Value_2=aqdat2.df[match.ind,ob_col_name], month=aqdat1.df$month)      # eliminate points that are not common between the two runs
            }
            else { match.ind<-match(aqdat2.df$statdate,aqdat1.df$statdate)                               # If more obs in run 2 than run 1
               aqdat.df<-data.frame(network=aqdat2.df$network, stat_id=I(aqdat2.df$stat_id), lat=aqdat2.df$lat, lon=aqdat2.df$lon, state=aqdat2.df$state, ob_dates=aqdat2.df$ob_dates, Mod_Value_1=aqdat1.df[match.ind,mod_col_name], Mod_Value_2=aqdat2.df[[mod_col_name]], Ob_Value_1=aqdat1.df[match.ind,ob_col_name], Ob_Value_2=aqdat2.df[[ob_col_name]], month=aqdat2.df$month)      # eliminate points that are not common between the two runs
            }
         }
         ### Remove NAs from paired dataset ###
         indic.na <- !is.na(aqdat.df$Mod_Value_1)
         aqdat.df <- aqdat.df[indic.na,]
         indic.na <- !is.na(aqdat.df$Mod_Value_2)
         aqdat.df <- aqdat.df[indic.na,]
         indic.na <- !is.na(aqdat.df$Ob_Value_1)
         aqdat.df <- aqdat.df[indic.na,]
         ######################################

         split_sites_all  <- split(aqdat.df, aqdat.df$stat_id)  # Split all data by site
         for (i in 1:length(split_sites_all)) { # Run averaging for each site for each month
            sub_all.df  <- split_sites_all[[i]] # Store current site i in sub_all.df dataframe
            if (length(sub_all.df$stat_id) > 0) {
               num_total_obs <- length(sub_all.df$Ob_Value_1)      # Count the total number of obs available for the site
               num_good_obs <- 0                           # Set number of good obs to 0
               for (k in 1:length(sub_all.df$Ob_Value_1)) {        # Count the number of non-missing obs (good obs)
                  if (sub_all.df[k,9] >= -90) {           # If ob value is >= 0, count as good
                     num_good_obs <- num_good_obs+1        # Increment good ob count by one
                  }
               }
               coverage <- (num_good_obs/num_total_obs)*100        # Compute coverage value for good_obs/total_obs
               if (coverage >= coverage_limit) {                   # determine if the number of non-missing obs is >= to the coverage limit
                  indic.nonzero <- sub_all.df$Mod_Value_1 >= -90           # Identify good obs in dataframe
                  sub_good.df <- sub_all.df[indic.nonzero,]        # Update dataframe to only include good obs (remove missing obs)
                  indic.nonzero <- sub_good.df$Mod_Value_2 >= -90
                  sub_good.df <- sub_good.df[indic.nonzero,]
                  indic.nonzero <- sub_good.df$Ob_Value_1 >= -90
                  sub_good.df <- sub_good.df[indic.nonzero,]
                  sites        <- c(sites, unique(sub_good.df$stat_id))			# Add current site to site list	
                  lats         <- c(lats, unique(sub_good.df$lat))				# Add current lat to lat list
                  lons         <- c(lons, unique(sub_good.df$lon))				# Add current lon to lon list
		  states       <- c(states, unique(sub_good.df$state))
                  mod_mean1    <- avg_func(sub_good.df$Mod_Value_1)
                  ob_mean1     <- avg_func(sub_good.df$Ob_Value_1)
                  mod_mean2    <- avg_func(sub_good.df$Mod_Value_2)
                  ob_mean2     <- avg_func(sub_good.df$Ob_Value_2)
                  mod_bias_1   <- mod_mean1-ob_mean1
                  mod_bias_2   <- mod_mean2-ob_mean2
                  mod_bias_1_all <- c(mod_bias_1_all, mod_bias_1)  			# Store site bias for simulation 1 in an array
                  mod_bias_2_all <- c(mod_bias_2_all, mod_bias_2)  			# Store site bias for simulation 2 in an array
                  bias_diff      <- c(bias_diff, (abs(mod_bias_1)-abs(mod_bias_2)))	# Compute diff in site mean bias between two simulations
                  mod_error_1   <- abs(mod_mean1-ob_mean1)
                  mod_error_2   <- abs(mod_mean2-ob_mean2)
                  mod_error_1_all <- c(mod_error_1_all, mod_error_1)                       # Store site bias for simulation 1 in an array
                  mod_error_2_all <- c(mod_error_2_all, mod_error_2)                       # Store site bias for simulation 2 in an array
                  error_diff      <- c(error_diff, (abs(mod_error_1)-abs(mod_error_2)))     # Compute diff in site mean bias between two simulations
                  mod_corr_1	 <- cor(sub_good.df$Mod_Value_1, sub_good.df$Ob_Value_1)
                  mod_corr_2	 <- cor(sub_good.df$Mod_Value_2, sub_good.df$Ob_Value_2)
                  mod_corr_1_all <- c(mod_corr_1_all, mod_corr_1)
                  mod_corr_2_all <- c(mod_corr_2_all, mod_corr_2)
                  corr_diff	 <- c(corr_diff, (abs(mod_corr_1)-abs(mod_corr_2)))
               }
            }
         }
         sites_avg.df 			<- data.frame(Network=network,Site_ID=I(sites),lat=lats,lon=lons,state=states,Bias_1=mod_bias_1_all,Bias_2=mod_bias_2_all,Bias_Diff=bias_diff,Error_1=mod_error_1_all,Error_2=mod_error_2_all,Error_Diff=error_diff,Corr_1=mod_corr_1_all,Corr_2=mod_corr_2_all,Corr_Diff=corr_diff)	# Create properly formatted dataframe for use with PlotSpatial function
         sinfo_data[[j]]		<-list(stat_id=sites,lat=sites_avg.df$lat,lon=sites_avg.df$lon,state=sites_avg.df$state,Bias_1=sites_avg.df$Bias_1, Bias_2=sites_avg.df$Bias_2, Bias_Diff=sites_avg.df$Bias_Diff, Error_1=sites_avg.df$Error_1, Error_2=sites_avg.df$Error_2, Error_Diff=sites_avg.df$Error_Diff,Corr_1=sites_avg.df$Corr_1,Corr_2=sites_avg.df$Corr_2,Corr_Diff=sites_avg.df$Corr_Diff)

         all_sites		<- c(all_sites,sites_avg.df$Site_ID)
         all_lats		<- c(all_lats,sites_avg.df$lat)
         all_lons		<- c(all_lons,sites_avg.df$lon)
         all_states		<- c(all_states,sites_avg.df$state)
	 all_bias		<- c(all_bias,sites_avg.df$Bias_1)
         all_bias2              <- c(all_bias2,sites_avg.df$Bias_2)
         all_bias_diff  	<- c(all_bias_diff,sites_avg.df$Bias_Diff)
         all_error	 	<- c(all_error,sites_avg.df$Error_1)
         all_error2             <- c(all_error2,sites_avg.df$Error_2)
         all_error_diff 	<- c(all_error_diff,sites_avg.df$Error_Diff)
         all_corr		<- c(all_corr,sites_avg.df$Corr_1)
         all_corr2		<- c(all_corr2,sites_avg.df$Corr_2)
         all_corr_diff		<- c(all_corr_diff,sites_avg.df$Corr_Diff)
         All_Data <- data.frame(Site=all_sites,Lat=all_lats,Lon=all_lons,state=all_states,Bias1=all_bias,Bias2=all_bias2,Bias_Diff=all_bias_diff,Error1=all_error,Error2=all_error2,Error_Diff=all_error_diff,Corr_Diff=all_corr_diff)
      }
      write.table(c(paste("Run1 = ",run_name1,sep=""),paste("Run2 = ",run_name2,sep="")),file=filename_csv,append=F,col.names=F,row.names=F,sep=",")
      write.table(All_Data,file=filename_csv,append=T,row.names=F,sep=",")     # Write header for raw data file
   }
}

lat_max <- max(all_lats)
lat_min <- min(all_lats)
lon_max <- max(all_lons)
lon_min <- min(all_lons)
lat_diff <- abs(lat_max) - abs(lat_min)
lon_diff <- abs(lon_max - lon_min)
center_lat <- lat_max - (abs(lat_max) - abs(lat_min))/2
center_lon <- lon_max - abs(lon_max - lon_min)/2
zoom_level <- 5
### Terrible hack to adjust zoom for webshot pngs ###
if ((lat_diff < 16) && (lon_diff < 32)) { zoom_level <- 6 }
if ((lat_diff < 9) && (lon_diff < 18)) { zoom_level <- 7 }
#####################################################


my.diff.colors <- colorRampPalette(c("darkorchid4","purple", "#002FFF", "deepskyblue", "lightblue", "palegoldenrod", "yellow", "orange", "red", "brown"))
my.colors <- colorRampPalette(c(grey(.8),"mediumpurple","darkorchid4", "#002FFF", "green", "yellow", "orange", "red", "brown"))

plot_data <- NULL
plot_data[[1]] <- all_bias
plot_data[[2]] <- all_bias2
plot_data[[3]] <- all_error
plot_data[[4]] <- all_error2
plot_data[[5]] <- all_corr
plot_data[[6]] <- all_corr2
plot_data[[7]] <- all_bias_diff
plot_data[[8]] <- all_error_diff
plot_data[[9]] <- all_corr_diff

title <- NULL
{
   if (custom_title == "") { 
      run_name_elements <-unlist(strsplit(run_name1,"_"))
      run_name_title1 <- run_name_elements[1]
      for (l in 2:length(run_name_elements)) { run_name_title1 <- paste(run_name_title1,run_name_elements[l],sep="<br>") }
      run_name_elements <-unlist(strsplit(run_name2,"_"))
      run_name_title2 <- run_name_elements[1]
      for (l in 2:length(run_name_elements)) { run_name_title2 <- paste(run_name_title2,run_name_elements[l],sep="<br>") }
      title[1] <- paste(species," (",units,") <br> Bias (",avg_func_name,")",sep="") 
      map_title[1] <- paste(run_name1,species,"Bias",dates,sep=" ")
      title[2] <- paste(species," (",units,") <br> Bias (",avg_func_name,")",sep="")
      map_title[2] <- paste(run_name2,species,"Bias",dates,sep=" ")
      title[7] <- paste(species," (",units,") <br> Bias Diff (",avg_func_name,")",sep="")
      map_title[7] <- paste(run_name1,"-",run_name2,species,"Bias Diff",dates,sep=" ")
      title[3] <- paste(species," (",units,") <br> Error (",avg_func_name,")",sep="")
      map_title[3] <- paste(run_name1,species,"Error",dates,sep=" ")
      title[4] <- paste(species," (",units,") <br> Error (",avg_func_name,")",sep="")
      map_title[4] <- paste(run_name2,species,"Error",dates,sep=" ")
      title[8] <- paste(species," (",units,") <br> Error Diff (",avg_func_name,")",sep="")
      map_title[8] <- paste(run_name1,"-",run_name2,species,"Error Diff",dates,sep=" ")
      title[5] <- paste(species," (none) <br> Corr (",avg_func_name,")",sep="")
      map_title[5] <- paste(run_name1,species,"Corr",dates,sep=" ")
      title[6] <- paste(species," (none) <br> Corr (",avg_func_name,")",sep="")
      map_title[6] <- paste(run_name2,species,"Corr",dates,sep=" ")
      title[9] <- paste(species," (none) <br> Corr Diff (",avg_func_name,")",sep="")
      map_title[9] <- paste(run_name1,"-",run_name2,species,"Corr Diff",dates,sep=" ")
   }
   else { 
      title[1] <- custom_title 
      title[2] <- custom_title
      title[3] <- custom_title
      title[4] <- custom_title
      title[5] <- custom_title
      title[6] <- custom_title
      title[7] <- custom_title
      title[8] <- custom_title
      title[9] <- custom_title
   }
}

num_bins <- NULL
for (i in 1:9) {
   left_adj <- 30
   if (i > 6) { left_adj <- 10 }
   main_title 		<- tags$div(tag.map.title.html, HTML(map_title[i]))
   main_title_png 	<- tags$div(tag.map.title.png, HTML(map_title[i]))
   data.df 		<- data.frame(site.id=all_sites,latitude=all_lats,longitude=all_lons,o3.obs=plot_data[[i]])
   range_max 		<- max(quantile(abs(plot_data[[i]]),probs=quantile_max,na.rm=T))
   data.seq 		<- pretty(c(-range_max,range_max),n=20)
   if ((length(diff_range_min) != 0) || (length(diff_range_max) != 0)) {
      data.seq <- pretty(c(diff_range_min,diff_range_max),n=20)
   }
   min.data 	<- min(data.seq)
   max.data 	<- max(data.seq)
   n.bins 	<- length(data.seq)
   num_bins[i] 	<- n.bins
   binpal2 	<- colorBin(my.diff.colors(10), c(min.data,max.data), n.bins-1 , pretty = FALSE)
 
   if ((i == 3) || (i == 4) || (i == 5) || (i == 6)) {
     data.df 	<- data.frame(site.id=all_sites,latitude=all_lats,longitude=all_lons,o3.obs=plot_data[[i]])
     range_min 	<- min(quantile((plot_data[[i]]),probs=quantile_min,na.rm=T))	# Removed abs function on 8/30/2022
     range_max 	<- max(quantile((plot_data[[i]]),probs=quantile_max,na.rm=T))	# Removed abs function on 8/30/2022
     data.seq 	<- pretty(c(range_min,range_max),n=20)
     if ((length(diff_range_min) != 0) || (length(diff_range_max) != 0)) {
      data.seq 	<- pretty(c(diff_range_min,diff_range_max),n=20)
     }
     min.data 	<- min(data.seq)
     max.data 	<- max(data.seq)
     n.bins 	<- length(data.seq)
     binpal2 	<- colorBin(my.colors(10), c(min.data,max.data), n.bins-1 , pretty = FALSE)
   }

  my.leaf <- my.leaf.base   
  for (j in 1:length(network_names)) {
     if(i == 1) { 
        plot_val <- sinfo_data[[j]]$Bias_1
        name <- "Bias Sim 1"
        ecdf_data <- c(all_bias,all_bias2) 
     }
     if(i == 2) { 
        plot_val <- sinfo_data[[j]]$Bias_2
        name <- "Bias Sim 2" 
        ecdf_data <- c(all_bias,all_bias2)
     }
     if(i == 3) { 
        plot_val <- sinfo_data[[j]]$Error_1 
        name <- "Error Sim 1"
        ecdf_data <- c(all_error,all_error2)
     }
     if(i == 4) { 
        plot_val <- sinfo_data[[j]]$Error_2 
        name <- "Error Sim 2"
        ecdf_data <- c(all_error,all_error2)
     }
     if(i == 5) {
        plot_val <- sinfo_data[[j]]$Corr_1
        name <- "Corr Sim 1"
        ecdf_data <- c(all_corr,all_corr2)
     }
     if(i == 6) {
        plot_val <- sinfo_data[[j]]$Corr_2
        name <- "Corr Sim 2"
        ecdf_data <- c(all_corr,all_corr2)
     }
     if(i == 7) { 
        plot_val <- sinfo_data[[j]]$Bias_Diff
        name <- "Bias Diff" 
        ecdf_data <- all_bias_diff
     }
     if(i == 8) { 
        plot_val <- sinfo_data[[j]]$Error_Diff 
        name <- "Error Diff"
        ecdf_data <- all_error_diff
     }
     if(i == 9) {
        plot_val <- sinfo_data[[j]]$Corr_Diff
        name <- "Corr Diff"
        ecdf_data <- all_corr_diff
     }
     data.df <- data.frame(site.id=sinfo_data[[j]]$stat_id,latitude=sinfo_data[[j]]$lat,longitude=sinfo_data[[j]]$lon,state=sinfo_data[[j]]$state,data.obs=plot_val)
     contents <- paste("Site: ", all_sites,
                  "<br/>",
		   "Latitude: ",sinfo_data[[j]]$lat,
                  "<br/>",
                  "Longitude: ",sinfo_data[[j]]$lon,
                  "<br/>",
                  "State: ",sinfo_data[[j]]$state,
                  "<br/>",
                  "Bias1: ", round(sinfo_data[[j]]$Bias_1, 2),units,
                  "<br/>",
                  "Bias2: ", round(sinfo_data[[j]]$Bias_2, 2),units,
                  "<br/>",
                  "Bias Diff:", round(sinfo_data[[j]]$Bias_Diff, 2),units,
                  "<br/>",
                  "Error1: ", round(sinfo_data[[j]]$Error_1, 2),units,
                  "<br/>",
                  "Error2: ", round(sinfo_data[[j]]$Error_2, 2),units,
                  "<br/>",
                  "Error Diff:", round(sinfo_data[[j]]$Error_Diff, 2),units,
                  "<br/>",
                  "Corr1: ", round(sinfo_data[[j]]$Corr_1, 2),units,
                  "<br/>",
                  "Corr2: ", round(sinfo_data[[j]]$Corr_2, 2),units,
                  "<br/>",
                  "Corr Diff:", round(sinfo_data[[j]]$Corr_Diff, 2),units, sep=" ")

     contents2 <- paste("Site: ", sinfo_data[[j]]$stat_id,
                              "  Network: ", network_names[[j]],
                              "  Value: ", round(plot_val, 2), units, sep=" ") 

   
     if(!exists("plot_radius")) { plot_radius <- 0 }
     if(!exists("outlier_radius")) { outlier_radius <- 40 }
     if(!exists("fill_opacity")) { fill_opacity <- 0.8 }
     plot_rad <- plot_radius
     if (plot_rad == 0) {
        max.radius <- 20
        min.radius <- 4
        plot_rad <- ecdf(abs(ecdf_data))(abs(plot_val))*max.radius
        plot_rad[plot_rad < min.radius] <- min.radius
        plot_rad[abs(plot_val) > max.data] <- outlier_radius
     }
     my.leaf <- my.leaf %>% addCircleMarkers(sinfo_data[[j]]$lon,sinfo_data[[j]]$lat,color="black",fillColor=~binpal2(plot_val),group=network_names[[j]],radius=plot_rad*symbsizfac,data=data.df,opacity=1,fillOpacity=fill_opacity,stroke=TRUE,weight=1,popup=contents,label=contents2, labelOptions = labelOptions(noHide = F, textsize = "15px"))
#     addCircleMarkers(all_lons,all_lats,color=~binpal2(plot_data[[i]]),radius=6,data=data.df,opacity=1,fillOpacity=1,popup=contents,label=contents2)%>%
  }
    
  my.leaf <- my.leaf %>% addLegend("bottomright", pal = binpal2, values = c(min.data,max.data), title = title[i], opacity = 2) 
  my.leaf2 <- my.leaf %>% addProviderTiles(leaflet_map[1],group="Street Map") %>% setView(center_lon,center_lat,zoom=zoom_level)
  my.leaf <- my.leaf %>% addControl(main_title,position="topright",className="map-title")
  my.leaf2 <- my.leaf2 %>% addControl(main_title_png,position="topright",className="map-title")
  my.leaf <- my.leaf %>%
  addLayersControl(baseGroups = base_Groups,overlayGroups = c(network_names),options =  layersControlOptions(collapsed = FALSE,position="topleft"))

  saveWidget(my.leaf, file=filename[i],selfcontained=T)
  saveWidget(my.leaf2, file="Rplot.html",selfcontained=T)
  if (png_from_html == "y") {
     webshot("Rplot.html", file = filename_png[i],cliprect = "viewport",zoom=2,vwidth=max(lon_diff*24.5,1600),vheight=max(lat_diff*36.5,800))
  }
}
total_sites 	 <- length(all_bias_diff[!is.na(all_bias_diff)])
bias_neg_vals    <- sum(all_bias_diff<0)
bias_pos_vals    <- sum(all_bias_diff>0)
bias_hist	 <- hist(all_bias_diff,breaks=(num_bins[7]+1))
bias_hist_breaks <- bias_hist$breaks
bias_diff_colors <- c(cool_colors(sum(bias_hist_breaks<0)),hot_colors(sum(bias_hist_breaks>=0)))
p <- plot_ly(x=all_bias_diff, type="histogram",nbinsx=length(bias_hist_breaks),marker = list(color=bias_diff_colors),nbinsx=(num_bins[7]+1))%>%
 add_segments(x=0,y=0,xend=0,yend=max(bias_hist$counts),line=list(color="black",width=4))%>%
 layout(title=map_title[7],yaxis=list(title="Bin Count (# of Sites)",titlefont=list(size=27)),xaxis=list(title=paste("Absolute Difference in Bias; # of Sites with Reduced Bias = ",bias_neg_vals," (",round(100*(bias_neg_vals/total_sites),1),"%)",sep=""),titlefont=list(size=27)))
saveWidget(p, file=filename_bias_hist_html,selfcontained=T)
if (png_from_html == "y") { webshot(filename_bias_hist_html,file=filename_bias_hist_png,zoom=2,vwidth=max(lon_diff*24.5,1600),vheight=max(lat_diff*36.5,800)) }

total_sites	  <- length(all_error_diff[!is.na(all_error_diff)])
error_neg_vals    <- sum(all_error_diff<0)
error_pos_vals    <- sum(all_error_diff>0)
error_hist<-hist(all_error_diff,breaks=(num_bins[7]+1))
error_hist_breaks <- error_hist$breaks
error_diff_colors <- c(cool_colors(sum(error_hist_breaks<0)),hot_colors(sum(error_hist_breaks>=0)))
p <- plot_ly(x=all_error_diff, type="histogram",nbinsx=length(error_hist_breaks),marker = list(color=error_diff_colors),nbinsx=(num_bins[8]+1))%>%
 add_segments(x=0,y=0,xend=0,yend=max(error_hist$counts),line=list(color="black",width=4))%>%
 layout(title=map_title[8],yaxis=list(title="Bin Count (# of Sites)",titlefont=list(size=27)),xaxis=list(title=paste("Absolute Difference in Error; # of Sites with Reduced Error = ",error_neg_vals," (",round(100*(error_neg_vals/total_sites),1),"%)",sep=""),titlefont=list(size=27)))
saveWidget(p, file=filename_error_hist_html,selfcontained=T)
if (png_from_html == "y") { webshot(filename_error_hist_html,file=filename_error_hist_png,zoom=2,vwidth=max(lon_diff*24.5,1600),vheight=max(lat_diff*36.5,800)) }

total_sites	 <- length(all_corr_diff[!is.na(all_corr_diff)])
corr_neg_vals 	 <- sum(all_corr_diff<0,na.rm=T)
corr_pos_vals	 <- sum(all_corr_diff>0,na.rm=T)
corr_hist	 <- hist(all_corr_diff,breaks=(num_bins[9]+1))
corr_hist_breaks <- corr_hist$breaks
corr_diff_colors <- c(cool_colors(sum(corr_hist_breaks<0)),hot_colors(sum(corr_hist_breaks>=0)))
p <- plot_ly(x=all_corr_diff, type="histogram",nbinsx=length(corr_hist_breaks),marker = list(color=corr_diff_colors))%>%
 add_segments(x=0,y=0,xend=0,yend=max(corr_hist$counts),line=list(color="black",width=4))%>%
 layout(title=map_title[9],yaxis=list(title="Bin Count (# of Sites)",titlefont=list(size=27)),xaxis=list(title=paste("Absolute Difference in Correlation; # of sites with higher Correlation = ",corr_pos_vals," (",round(100*(corr_pos_vals/total_sites),1),"%)",sep=""),titlefont=list(size=27)))
saveWidget(p, file=filename_corr_hist_html,selfcontained=T)
if (png_from_html == "y") { webshot(filename_corr_hist_html,file=filename_corr_hist_png,zoom=2,vwidth=max(lon_diff*24.5,1600),vheight=max(lat_diff*36.5,800)) }
