header <- "
########################### MODEL TO MODEL SPATIAL PLOT ##############################
### AMET CODE: AQ_Plot_Spatial_MtoM.R 
###
### This code is part of the AMET-AQ system.  The Plot Spatial code takes a MYSQL database
### query for a single species from one or more networks and plots the observation value,
### model value, and difference between the model and ob for each site for each corresponding
### network.  Mutiple values for a site are averaged to a single value for plotting purposes.
### The map area plotted is dynamically generated from the input data.   
###
### Last modified by Wyat Appel: Dec 2021
########################################################################################
"

## get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Load Required Libraries 
if(!require(maps)){stop("Required Package maps was not loaded")}
if(!require(mapdata)){stop("Required Package mapdata was not loaded")}
if(!require(webshot)){stop("Required Package mapdata was not loaded")}

if(!exists("quantile_min")) { quantile_min <- 0.001 }
if(!exists("quantile_max")) { quantile_max <- 0.950 }

### Retrieve units label from database table ###
network <- network_names[1]														# When using mutiple networks, units from network 1 will be used
#units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")	# Create MYSQL query from units table

### Set file names and titles ###
filename 	<- NULL
filename[1]     <- paste(run_name1,species,pid,"spatialplot_mtom_diff_max.html",sep="_")           # Filename for obs spatial plot
filename[2]     <- paste(run_name1,species,pid,"spatialplot_mtom_diff_min.html",sep="_")           # Filename for model spatial plot
filename[3]     <- paste(run_name1,species,pid,"spatialplot_mtom_diff_avg.html",sep="_")           # Filename for diff spatial plot
filename[4]     <- paste(run_name1,species,pid,"spatialplot_mtom_ratio.html",sep="_")              # Filename for ratio plot

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }

## Create a full path to file
filename[1]      <- paste(figdir,filename[1],sep="/")           # Filename for obs spatial plot
filename[2]      <- paste(figdir,filename[2],sep="/")           # Filename for model spatial plot
filename[3]      <- paste(figdir,filename[3],sep="/")          # Filename for diff spatial plot
filename[4]      <- paste(figdir,filename[4],sep="/")          # Filename for ratio plot
################################################

### Set NULL values and plot symbols ###
sinfo_diff       <- NULL						# Set list for difference values to NULL
sinfo_max	 <- NULL
sinfo_min	 <- NULL
sinfo_diff_data  <- NULL
sinfo_max_data   <- NULL
sinfo_min_data   <- NULL
sinfo_data	 <- NULL
sinfo_ratio_data <- NULL
plot_data	 <- NULL
diff_min         <- NULL
all_lats         <- NULL
all_lons         <- NULL
all_diff         <- NULL
all_max		 <- NULL
all_min		 <- NULL
all_ratio	 <- NULL
########################################

remove_negatives <- "n"
total_networks <- length(network_names)
k <- 1
for (j in 1:total_networks) {                                            # Loop through for each network
   sites	<- NULL
   lats		<- NULL
   lons		<- NULL
   avg_diff	<- NULL
   max_diff	<- NULL
   min_diff	<- NULL
   avg_ratio	<- NULL
   network   	<- network_names[[j]]                                              # Set network name
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,species)
         aqdat_query.df   <- sitex_info$sitex_data
         aqdat_query.df	  <- aqdat_query.df[with(aqdat_query.df,order(network,stat_id)),]
         data_exists	  <- sitex_info$data_exists
         sitex_info2      <- read_sitex(Sys.getenv("OUTDIR2"),network,run_name2,species)
         aqdat_query2.df  <- sitex_info2$sitex_data
         aqdat_query2.df  <- aqdat_query2.df[with(aqdat_query2.df,order(network,stat_id)),]
         data_exists2     <- sitex_info2$data_exists
         units            <- as.character(sitex_info$units[[1]])
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
   aqdat1.df        <- aqdat_query.df
   aqdat2.df        <- aqdat_query2.df
   ob_col_name <- paste(species,"_ob",sep="")
   mod_col_name <- paste(species,"_mod",sep="")

   {
      if ((data_exists == "n") || (data_exists2 == "n")) {
         All_Data       <- "No stats available.  Perhaps you choose a species for a network that does not observe that species."
         total_networks <- (total_networks-1)
#         sub_title      <- paste(sub_title,network,"=No Data; ",sep="")
         if (total_networks == 0) { stop("Stopping because total_networks is zero. Likely no data found for query.") }
      }
      else {
         ### Match the points between each of the runs.  This is necessary if the data from each query do not match exactly ###
         aqdat1.df$statdate<-paste(aqdat1.df$stat_id,aqdat1.df$ob_dates,aqdat1.df$ob_hour,sep="")     # Create unique column that combines the site name with the ob start date for run 1
         aqdat2.df$statdate<-paste(aqdat2.df$stat_id,aqdat2.df$ob_dates,aqdat2.df$ob_hour,sep="")     # Create unique column that combines the site name with the ob start date for run 2
         if (length(aqdat1.df$statdate) <= length(aqdat2.df$statdate)) {                              # If more obs in run 1 than run 2
            match.ind<-match(aqdat1.df$statdate,aqdat2.df$statdate)                                   # Match the unique column (statdate) between the two runs
            aqdat.df<-data.frame(network=aqdat1.df$network, stat_id=aqdat1.df$stat_id, lat=aqdat1.df$lat, lon=aqdat1.df$lon, dates=aqdat1.df$ob_dates, aqdat1.df[[mod_col_name]], aqdat2.df[match.ind,mod_col_name], aqdat1.df[,ob_col_name], aqdat2.df[match.ind,ob_col_name], month=aqdat1.df$month)      # eliminate points that are not common between the two runs
         }
         else { match.ind<-match(aqdat2.df$statdate,aqdat1.df$statdate)                               # If more obs in run 2 than run 1
            aqdat.df<-data.frame(network=aqdat2.df$network, stat_id=aqdat2.df$stat_id, lat=aqdat2.df$lat, lon=aqdat2.df$lon, ob_dates=aqdat2.df$ob_dates, aqdat1.df[match.ind,mod_col_name], aqdat2.df[[mod_col_name]], aqdat1.df[match.ind,ob_col_name], aqdat2.df[[ob_col_name]], month=aqdat2.df$month)      # eliminate points that are not common between the two runs
         }
         aqdat.df <- data.frame(Network=aqdat.df$network,Stat_ID=aqdat.df$stat_id,lat=aqdat.df$lat,lon=aqdat.df$lon,Mod_Value1=aqdat.df[,7],Mod_Value2=aqdat.df[,6])
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
               sites        <- c(sites, as.character(unique(sub_all.df$Stat_ID)))
#               sites        <- c(sites, unique(sub_all.df$Stat_ID))                          	# Add current site to site list 
               lats         <- c(lats, unique(sub_all.df$lat))                               	# Add current lat to lat list
               lons         <- c(lons, unique(sub_all.df$lon))                               	# Add current lon to lon list
               if ((network == 'NADP') || (species == "precip")) {
                  avg_diff <- c(avg_diff, (sum(sub_all.df$Mod_Value2)-sum(sub_all.df$Mod_Value1)))       # Compute model/ob difference
               }
               else {                                                                         # use averaging for all other networks
                  avg_diff <- c(avg_diff, (mean(sub_all.df$Mod_Value2)-mean(sub_all.df$Mod_Value1)))     # Compute model/ob difference
               }
               max_diff   <- c(max_diff, max(sub_all.df$Mod_Value2-sub_all.df$Mod_Value1))
               min_diff   <- c(min_diff, min(sub_all.df$Mod_Value2-sub_all.df$Mod_Value1))
               avg_ratio <- c(avg_ratio, mean(sub_all.df$Mod_Value2/sub_all.df$Mod_Value1))	# Note that Mod_Value1 is Sim2 and Mod_Value2 is Sim1
            }
         }
         sinfo_max_data[[k]]<-list(lat=lats,lon=lons,plotval=max_diff)
         sinfo_min_data[[k]]<-list(lat=lats,lon=lons,plotval=min_diff)
         sinfo_diff_data[[k]]<-list(lat=lats,lon=lons,plotval=avg_diff)
         sinfo_ratio_data[[k]]<-list(lat=lats,lon=lons,plotval=avg_ratio)
         sinfo_data[[k]]<-list(stat_id=sites,lat=lats,lon=lons,max_diff=max_diff,min_diff=min_diff,avg_diff=avg_diff,avg_ratio=avg_ratio)

         all_lats <- c(all_lats,lats)
         all_lons <- c(all_lons,lons)
         all_diff <- c(all_diff,avg_diff)
         all_max  <- c(all_max,max_diff)
         all_min  <- c(all_min,min_diff)
         all_ratio <- c(all_ratio,avg_ratio)
         #sub_title    <- paste(sub_title,symbols[j],"=",network_label[j],"; ",sep="")      # Set subtitle based on network matched w/ the appropriate symbol
         k<-k+1
      }
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
if (lat_diff*lon_diff < 500) { zoom_level <- 6 }

{
   if (custom_title == "") {
      run_name_elements <-unlist(strsplit(run_name1,"_"))
      run_name_title <- run_name_elements[1]
      for (l in 2:length(run_name_elements)) { run_name_title <- paste(run_name_title,run_name_elements[l],sep="<br>") }
      title <- paste(run_name1,"-",run_name2,species,dates,sep=" ")
      title2 <- paste(run_name1,"/",run_name2,species,dates,sep=" ") 
}
   else {
      title <- custom_title
      title2 <- custom_title2
      title_bias <- custom_title
   }
}

my.diff.colors <- colorRampPalette(c("darkorchid4","purple", "#002FFF", "deepskyblue", "lightblue", "palegoldenrod", "yellow", "orange", "red", "brown"))
my.colors <- colorRampPalette(c(grey(.8),"mediumpurple","darkorchid4", "#002FFF", "green", "yellow", "orange", "red", "brown"))

if (length(num_ints) == 0) {
   num_ints <- 20
}

plot_data[[1]] <- all_max
plot_data[[2]] <- all_min
plot_data[[3]] <- all_diff
plot_data[[4]] <- all_ratio
   
for (i in 1:4) {

   plot_title <- title
   if (i == 1) { plot_title <- paste(title,": Max Pos Diff",sep="") }
   if (i == 2) { plot_title <- paste(title,": Max Neg Diff",sep="") }
   if (i == 3) { plot_title <- paste(title,": Avg Diff",sep="") }
   if (i == 4) { plot_title <- paste(title2,": Avg Ratio of Sim1/Sim2",sep="") }
   main_title_html <- tags$div(tag.map.title.html, HTML(plot_title))
   main_title_png  <- tags$div(tag.map.title.png, HTML(plot_title))
   range_max <- max(abs(min(quantile(plot_data[[i]],probs=quantile_min),na.rm=T)),max(quantile(plot_data[[i]],probs=quantile_max),na.rm=T))
   data.seq <- pretty(c(-range_max,range_max),n=num_ints)
   if ((length(diff_range_min) != 0) || (length(diff_range_max) != 0)) {
      data.seq <- pretty(seq(diff_range_min,diff_range_max,na.rm=T),n=num_ints)
   }
   min.data <- min(data.seq)
   max.data <- max(data.seq)
   n.bins <- length(data.seq)
   binpal2 <- colorBin(my.diff.colors(10), c(min.data,max.data), n.bins-1 , pretty = FALSE)
   if (i == 4) {
      range_max <- max(quantile(plot_data[[i]],probs=quantile_max),na.rm=T)
      range_min <- min(quantile(plot_data[[i]],probs=quantile_min),na.rm=T)
      data.seq <- pretty(c(range_min,range_max),n=num_ints)
      min.data <- min(data.seq)
      max.data <- max(data.seq)
      n.bins <- length(data.seq)
      binpal2 <- colorBin(my.colors(10), c(min.data,max.data), n.bins-1 , pretty = FALSE)
   }
 
   for (j in 1:total_networks) {
      if(i == 1) { plot_val <- sinfo_data[[j]]$max_diff }
      if(i == 2) { plot_val <- sinfo_data[[j]]$min_diff }
      if(i == 3) { plot_val <- sinfo_data[[j]]$avg_diff }
      if(i == 4) { 
         plot_val <- sinfo_data[[j]]$avg_ratio 
         units <- "none"
         title <- title2
      }
      data.df <- data.frame(site.id=sinfo_data[[j]]$stat_id,latitude=sinfo_data[[j]]$lat,longitude=sinfo_data[[j]]$lon,data.obs=plot_val)
      contents <- paste("Site: ", sinfo_data[[j]]$stat_id,
             "<br/>",
             "Network: ", network_names[[j]],
             "<br/>",
             "Max: ", round(sinfo_data[[j]]$max_diff, 2),units,
             "<br/>",
             "Min: ", round(sinfo_data[[j]]$min_diff, 2),units,
             "<br/>",
             "Avg:", round(sinfo_data[[j]]$avg_diff, 2),units, 
             "<br/>",
             "Avg:", round(sinfo_data[[j]]$avg_ratio,2),units,sep=" ")

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
         if (i == 1) { ecdf_data <- all_max }
         if (i == 2) { ecdf_data <- all_min }
         if (i == 3) { ecdf_data <- all_diff }
         if (i == 4) { ecdf_data <- all_ratio }
         plot_rad <- ecdf(abs(ecdf_data))(abs(plot_val))*max.radius
         plot_rad[plot_rad < min.radius] <- min.radius
         plot_rad[abs(plot_val) > max.data] <- outlier_radius
      }
      my.leaf <- my.leaf.base
      my.leaf <- my.leaf %>% addCircleMarkers(sinfo_data[[j]]$lon,sinfo_data[[j]]$lat,color="black",fillColor=~binpal2(plot_val),group=network_names[[j]],radius=plot_rad*symbsizfac,data=data.df,opacity=1,fillOpacity=fill_opacity,stroke=TRUE,weight=1,popup=contents,label=contents2, labelOptions = labelOptions(noHide = F, textsize = "15px"))
   }
   my.leaf <- my.leaf %>% addLegend("bottomright", pal = binpal2, values = c(min.data,max.data), title = paste(species," (",units,")",sep=""), opacity = 2)
   my.leaf2 <- my.leaf %>% addProviderTiles(leaflet_map[1],group="Street Map") %>% setView(center_lon,center_lat,zoom=zoom_level)
   my.leaf <- my.leaf %>% addControl(main_title_html,position="topright",className="map-title")
   my.leaf2 <- my.leaf2 %>% addControl(main_title_png,position="topright",className="map-title") 
#         my.leaf2 <- my.leaf2 %>% leafletOptions(zoomControl = FALSE)
   my.leaf <- my.leaf %>%
   addLayersControl(baseGroups = base_Groups,overlayGroups = c(network_names),options =  layersControlOptions(collapsed = FALSE,position="topleft"))
   saveWidget(my.leaf, file=filename[i],selfcontained=T)
   saveWidget(my.leaf2, file="Rplot.html",selfcontained=T)
   webshot("Rplot.html", file = "Rplot.png",cliprect = "viewport",zoom=2,vwidth=max(lon_diff*24.5,1200),vheight=max(lat_diff*36.5,800))
}
 
