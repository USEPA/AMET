################################################################
### AMET CODE: INTERACTIVE PLOT SPATIAL DIFF
###
### This code is part of the AMET-AQ system.  The Plot Spatial Diff code
### takes a MYSQL database query for a single species from one or more
### networks and two simulations and plots the bias and error for each
### simulation, and the difference in bias and error between each simulation.
### This particular code utilizes the leaflet package to create an inter-
### active plot with zoom capability. PANDOC is used to create a self-
### contained HTML file. Cool colors indicate lower bias/error in simulation 
### 1 versus simulation 2, while warm colors indicate higher bias/error in 
### simulation 1 versus simulation 2. 
###
### Last modified by Wyat Appel, Septempber 2018
################################################################

## get some environmental variables and setup some directories
ametbase	<- Sys.getenv("AMETBASE")			# base directory of AMET
ametR		<- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Load Required Libraries
if(!require(maps))		{stop("Required Package maps was not loaded")}
if(!require(mapdata))		{stop("Required Package mapdata was not loaded")}
if(!require(leaflet))		{stop("Required package leaflet was not loaded")}
if(!require(htmlwidgets))	{stop("Required package htmlwidgets was not loaded")}

### Retrieve units label from database table ###
network <- network_names[1]	# When using mutiple networks, units from network 1 will be used
################################################

filename <- NULL

### Set file names and titles ###
filename_bias_1		 <- paste(run_name1,species,pid,"spatialplot_bias_1.html",sep="_")       # Filename for obs spatial plot
filename_bias_2		 <- paste(run_name1,species,pid,"spatialplot_bias_2.html",sep="_")       # Filename for model spatial plot
filename_bias_diff	 <- paste(run_name1,species,pid,"spatialplot_bias_diff.html",sep="_") # Filename for diff spatial plot
filename_error_1	 <- paste(run_name1,species,pid,"spatialplot_error_1.html",sep="_")     # Filename for obs spatial plot
filename_error_2	 <- paste(run_name1,species,pid,"spatialplot_error_2.html",sep="_")     # Filename for model spatial plot
filename_error_diff	 <- paste(run_name1,species,pid,"spatialplot_error_diff.html",sep="_")       # Filename for diff spatial plot
filename_csv  		 <- paste(run_name1,species,pid,"spatialplot_diff.csv",sep="_")

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(run_name1,species,"for",network_label[1],"for",dates,sep=" ") }
   else { title <- custom_title }
}

## Create a full path to file
filename[1]          <- paste(figdir,filename_bias_1,sep="/")		# Filename for obs spatial plot
filename[2]          <- paste(figdir,filename_bias_2,sep="/")       	# Filename for model spatial plot
filename[3]          <- paste(figdir,filename_bias_diff,sep="/") 		# Filename for diff spatial plot
filename[4]          <- paste(figdir,filename_error_1,sep="/")     	# Filename for obs spatial plot
filename[5]          <- paste(figdir,filename_error_2,sep="/")     	# Filename for model spatial plot
filename[6]          <- paste(figdir,filename_error_diff,sep="/")     	# Filename for diff spatial plot
filename_csv	     <- paste(figdir,filename_csv,sep="/")

#################################

### Set NULL values and plot symbols ###
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
all_sites	<- NULL
all_lats        <- NULL
all_lons        <- NULL
all_bias	<- NULL
all_bias2	<- NULL
all_error	<- NULL
all_error2	<- NULL
all_bias_diff	<- NULL
all_error_diff	<- NULL
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

remove_negatives <- 'n'      # Set remove negatives to false. Negatives are needed in the coverage calculation and will be removed automatically by Average
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
         units            <- query_result[[3]]
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
         sub_title      <- paste(sub_title,network,"=No Data; ",sep="")
      }

      ### If there are data, continue ###
      else {
#         aqdat1.df$ob_dates <- aqdat1.df[,5]          # remove hour,minute,second values from start date (should always be 000000 anyway, but could change)
#         aqdat2.df$ob_dates <- aqdat2.df[,5]          # remove hour,minute,second values from start date (should always be 000000 anyway, but could change)
#         aqdat1.df$ob_datee <- aqdat1.df[,6]          # remove hour,minute,second values from start date (should always be 000000 anyway, but could change)
#         aqdat2.df$ob_datee <- aqdat2.df[,6]          # remove hour,minute,second values from start date (should always be 000000 anyway, but could change)

### Match the points between each of the runs.  This is necessary if the data from each query do not match exactly ###
         aqdat1.df$statdate<-paste(aqdat1.df$stat_id,aqdat1.df$ob_dates,aqdat1.df$ob_datee,aqdat1.df$ob_hour,sep="")     # Create unique column that combines the site name with the ob start date for run 1
         aqdat2.df$statdate<-paste(aqdat2.df$stat_id,aqdat2.df$ob_dates,aqdat2.df$ob_datee,aqdat2.df$ob_hour,sep="")     # Create unique column that combines the site name with the ob start date for run 2
         if (length(aqdat1.df$statdate) <= length(aqdat2.df$statdate)) {                              # If more obs in run 1 than run 2
            match.ind<-match(aqdat1.df$statdate,aqdat2.df$statdate)                                   # Match the unique column (statdate) between the two runs
            aqdat.df<-data.frame(network=aqdat1.df$network, stat_id=I(aqdat1.df$stat_id), lat=aqdat1.df$lat, lon=aqdat1.df$lon, ob_dates=aqdat1.df$ob_dates, Mod_Value_1=aqdat1.df[[mod_col_name]], Mod_Value_2=aqdat2.df[match.ind,mod_col_name], Ob_Value_1=aqdat1.df[[ob_col_name]], Ob_Value_2=aqdat2.df[match.ind,ob_col_name], month=aqdat1.df$month)      # eliminate points that are not common between the two runs
         }
         else { match.ind<-match(aqdat2.df$statdate,aqdat1.df$statdate)                               # If more obs in run 2 than run 1
            aqdat.df<-data.frame(network=aqdat2.df$network, stat_id=I(aqdat2.df$stat_id), lat=aqdat2.df$lat, lon=aqdat2.df$lon, ob_dates=aqdat2.df$ob_dates, Mod_Value_1=aqdat1.df[match.ind,mod_col_name], Mod_Value_2=aqdat2.df[[mod_col_name]], Ob_Value_1=aqdat1.df[match.ind,ob_col_name], Ob_Value_2=aqdat2.df[[ob_col_name]], month=aqdat2.df$month)      # eliminate points that are not common between the two runs
         }
         remove(aqdat1.df,aqdat2.df)

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
            num_total_obs <- length(sub_all.df$Ob_Value_1)      # Count the total number of obs available for the site
            num_good_obs <- 0                           # Set number of good obs to 0
            for (k in 1:length(sub_all.df$Ob_Value_1)) {        # Count the number of non-missing obs (good obs)
               if (sub_all.df[k,Ob_Value_1] >= -90) {           # If ob value is >= 0, count as good
                  num_good_obs <- num_good_obs+1        # Increment good ob count by one
               }
            }
            coverage <- (num_good_obs/num_total_obs)*100        # Compute coverage value for good_obs/total_obs
            if (coverage >= coverage_limit) {                   # determine if the number of non-missing obs is >= to the coverage limit
               indic.nonzero <- sub_all.df$Mod_Value_1 >= -90           # Identify good obs in dataframe
               sub_good.df <- sub_all.df[indic.nonzero,]        # Update dataframe to only include good obs (remove missing obs)
               indic.nonzero <- sub_good.df$Mod_Value_2 >= -90
               sub_good.df <- sub_good.df[indic.nonzero,]
               indic.nonzero <- sub_good.dfOb_Value_1 >= -90
               sub_good.df <- sub_good.df[indic.nonzero,]
               sites        <- c(sites, unique(sub_good.df$stat_id))			# Add current site to site list	
               lats         <- c(lats, unique(sub_good.df$lat))				# Add current lat to lat list
               lons         <- c(lons, unique(sub_good.df$lon))				# Add current lon to lon list
               mod_bias_1     <- mean(sub_good.df$Mod_Value_1-sub_good.df$Ob_Value_1)  	# Compute the site mean bias for simulation 1
               mod_bias_2     <- mean(sub_good.df$Mod_Value_2-sub_good.df$Ob_Value_2)  	# Compute the site mean bias for simulation 2
               mod_bias_1_all <- c(mod_bias_1_all, mod_bias_1)  			# Store site bias for simulation 1 in an array
               mod_bias_2_all <- c(mod_bias_2_all, mod_bias_2)  			# Store site bias for simulation 2 in an array
               bias_diff      <- c(bias_diff, (abs(mod_bias_1)-abs(mod_bias_2)))	# Compute diff in site mean bias between two simulations
               mod_error_1    <- mean(abs(sub_good.df$Mod_Value_1-sub_good.df$Ob_Value_1))	# Compute the site mean error for simulation 1
               mod_error_2    <- mean(abs(sub_good.df$Mod_Value_2-sub_good.df$Ob_Value_2))	# Compute the site mean error for simulation 2
               mod_error_1_all    <- c(mod_error_1_all, mod_error_1)				# Store site mean error for simulation 1 in an array
               mod_error_2_all    <- c(mod_error_2_all, mod_error_2)				# Store site mean error for simulation 2 in an array
               error_diff     <- c(error_diff, (mod_error_1-mod_error_2))	# Compute difference in site mean error between two simulations
            }
         }

         sites_avg.df 			<- data.frame(Network=network,Site_ID=I(sites),lat=lats,lon=lons,Bias_1=mod_bias_1_all,Bias_2=mod_bias_2_all,Bias_Diff=bias_diff,Error_1=mod_error_1_all,Error_2=mod_error_2_all,Error_Diff=error_diff)	# Create properly formatted dataframe for use with PlotSpatial function
         sinfo_bias_1_data[[j]]		<-list(lat=sites_avg.df$lat,lon=sites_avg.df$lon,plotval=sites_avg.df$Bias_1)
         sinfo_bias_2_data[[j]]		<-list(lat=sites_avg.df$lat,lon=sites_avg.df$lon,plotval=sites_avg.df$Bias_2)
         sinfo_bias_diff_data[[j]]	<-list(lat=sites_avg.df$lat,lon=sites_avg.df$lon,plotval=sites_avg.df$Bias_Diff)
         sinfo_error_1_data[[j]]	<-list(lat=sites_avg.df$lat,lon=sites_avg.df$lon,plotval=sites_avg.df$Error_1)
         sinfo_error_2_data[[j]]	<-list(lat=sites_avg.df$lat,lon=sites_avg.df$lon,plotval=sites_avg.df$Error_2)
         sinfo_error_diff_data[[j]]	<-list(lat=sites_avg.df$lat,lon=sites_avg.df$lon,plotval=sites_avg.df$Error_Diff)

         all_sites		<- c(all_sites,sites_avg.df$Site_ID)
         all_lats		<- c(all_lats,sites_avg.df$lat)
         all_lons		<- c(all_lons,sites_avg.df$lon)
         all_bias		<- c(all_bias,sites_avg.df$Bias_1)
         all_bias2              <- c(all_bias2,sites_avg.df$Bias_2)
         all_bias_diff  	<- c(all_bias_diff,sites_avg.df$Bias_Diff)
         all_error	 	<- c(all_error,sites_avg.df$Error_1)
         all_error2             <- c(all_error2,sites_avg.df$Error_2)
         all_error_diff 	<- c(all_error_diff,sites_avg.df$Error_Diff)
   
         All_Data <- data.frame(Site=all_sites,Lat=all_lats,Lon=all_lons,Bias1=all_bias,Bias2=all_bias2,Bias_Diff=all_bias_diff,Error1=all_error,Error2=all_error2,Error_Diff=all_error_diff)
         sub_title<-paste(sub_title,symbols[j],"=",network_label[j],"; ",sep="")      # Set subtitle based on network matched with the symbol name used for that network
      }
      write.table(c(paste("Run1 = ",run_name1,sep=""),paste("Run2 = ",run_name2,sep="")),file=filename_csv,append=F,col.names=F,row.names=F,sep=",")
      write.table(All_Data,file=filename_csv,append=T,row.names=F,sep=",")     # Write header for raw data file
   }
}

library(leaflet)
library(maps)
library(htmlwidgets)

mapStates <- map("state",fill=T,plot=F)
my.diff.colors <- colorRampPalette(c("darkorchid4","purple", "#002FFF", "deepskyblue", "lightblue", "palegoldenrod", "yellow", "orange", "red", "brown"))
my.colors <- colorRampPalette(c(grey(.8),"mediumpurple","darkorchid4", "#002FFF", "green", "yellow", "orange", "red", "brown"))

plot_data <- NULL
plot_data[[1]] <- all_bias
plot_data[[2]] <- all_bias2
plot_data[[3]] <- all_bias_diff
plot_data[[4]] <- all_error
plot_data[[5]] <- all_error2
plot_data[[6]] <- all_error_diff
#plot_data[[3]] <- all_diff

{
   if (custom_title == "") { title <- paste(species," (",units,")",sep="") }
   else { title <- custom_title }
}

for (i in 1:6) {
#  aqs.dat <- subset(o3.obs.df,date==pick.days[i])
#  xyz <- data.frame(x=expand.grid(x.proj.12,y.proj.12)[,1]*1000,y=expand.grid(x.proj.12,y.proj.12)[,2]*1000,z=matrix(o3.mod.array[,,i]))
#  o3.mod.raster <- rasterFromXYZ(xyz,crs="+proj=lcc +lat_1=33 +lat_2=45 +lat_0=40 +lon_0=-97 +a=6370000 +b=6370000")


  data.df <- data.frame(site.id=all_sites,latitude=all_lats,longitude=all_lons,o3.obs=plot_data[[i]])

  range_max <- max(abs(min(quantile(plot_data[[i]],probs=0.999),na.rm=T)),max(quantile(plot_data[[i]],probs=0.999),na.rm=T))
#range_max <- max(abs(min(plot_data[[i]],na.rm=T)),max(plot_data[[i]],na.rm=T))

#  data.seq <- pretty(seq(min(plot_data[[i]]),max(plot_data[[i]],na.rm=T)),n=20)
#  data.seq <- pretty(seq(range_max,-range_max),n=20)
   data.seq <- pretty(c(-range_max,range_max),n=20)

  if ((length(diff_range_min) != 0) || (length(diff_range_max) != 0)) {
     data.seq <- pretty(c(diff_range_min,diff_range_max),n=20)
  }
  if (i < 4) { name <- "Bias" }
  if (i > 3) { name <- "Error" }
  min.data <- min(data.seq)
  max.data <- max(data.seq)
  n.bins <- length(data.seq)
  binpal2 <- colorBin(my.colors(10), c(min.data,max.data), n.bins-1 , pretty = FALSE)

  contents <- paste("Site: ", all_sites,
                  "<br/>",
                  "Bias1: ", round(plot_data[[1]], 2),units,
                  "<br/>",
                  "Bias2: ", round(plot_data[[2]], 2),units,
                  "<br/>",
                  "Bias Diff:", round(plot_data[[3]], 2),units,
                  "<br/>",
                  "Error1: ", round(plot_data[[4]], 2),units,
                  "<br/>",
                  "Error2: ", round(plot_data[[5]], 2),units,
                  "<br/>",
                  "Error Diff:", round(plot_data[[6]], 2),units, sep=" ")

  contents2 <- paste("Site:",all_sites,name,"Value:",round(plot_data[[i]],2),units,sep=" ")

leaflet_map <- c("OpenStreetMap.Mapnik","OpenStreetMap.BlackAndWhite","OpenTopoMap","Esri.WorldImagery","HERE.hybridDay")

#  Other available maps: http://leaflet-extras.github.io/leaflet-providers/preview/index.html
#my.leaf <- leaflet(data=mapStates)  %>% addProviderTiles("MapQuestOpen.Aerial")  %>%
#my.leaf <- leaflet(data=mapStates) %>% addProviderTiles("OpenStreetMap.BlackAndWhite")  %>%
#my.leaf <- leaflet(data=mapStates) %>% addProviderTiles("OpenStreetMap.Mapnik")  %>%
#my.leaf <- leaflet(data=mapStates) %>% addProviderTiles("OpenTopoMap")  %>%
my.leaf <- leaflet(data=mapStates) %>% addProviderTiles(leaflet_map[map_type])  %>%

#        addRasterImage(o3.mod.raster,colors=binpal2,opacity=.5) %>%
#        addCircles(all_lons,all_lats,color=~binpal2(plot_data[[i]]),radius=60,data=data.df,opacity=1,fillOpacity=1,popup=contents)%>%
        addCircleMarkers(all_lons,all_lats,color=~binpal2(plot_data[[i]]),radius=6,data=data.df,opacity=1,fillOpacity=1,popup=contents,label=contents2)%>%
    addLegend("bottomright", pal = binpal2, values = c(min.data,max.data),
    title = title,
    opacity = 2)


saveWidget(my.leaf, file=filename[i],selfcontained=T)
}

