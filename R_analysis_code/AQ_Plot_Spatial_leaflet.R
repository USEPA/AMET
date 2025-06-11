header <- "
############################ INTERACTIVE SPATIAL PLOT ###############################
### AMET CODE: AQ_Plot_Spatial_leaflet.R 
###
### This code is part of the AMET-AQ system.  The Plot Spatial code takes a MYSQL database
### query for a single species from one or more networks and plots the observation value,
### model value, and difference between the model and ob for each site for each corresponding
### network.  Mutiple values for a site are averaged to a single value for plotting purposes.
### The map area plotted is dynamically generated from the input data.   
###
### Last modified by Wyat Appel: June 2025 
######################################################################################
"
## get some environmental variables and setup some directories
ametbase	<- Sys.getenv("AMETBASE")			# base directory of AMET
ametR		<- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Load Required Libraries 
if(!require(maps))		{ stop("Required Package maps was not loaded") 		 }
if(!require(mapdata))		{ stop("Required Package mapdata was not loaded") 	 }
if(!require(webshot))		{ stop("Required Package webshot was not loaded") 	 }
if(!require(lattice))		{ stop("Required Package lattice was not loaded") 	 }
if(!require(leafpop))      	{ stop("Required Package leafpop was not loaded") 	 }
if(!require(leaflet.extras))    { stop("Required Package leaflet.extras was not loaded") }

### The current release of leaflet.extras does not contain the groupedLayerControlOptions function.
### Hopefully it will be added a a future release of the leaflet.extras library. In the interim, the
### function can be loaded using the instructions here:https://rdrr.io/github/bhaskarvk/leaflet.extras/.

if(!exists("quantile_min")) { quantile_min <- 0.001 }
if(!exists("quantile_max")) { quantile_max <- 0.999 }
if(!exists("png_from_html")) { png_from_html <- "n" }
if(!exists("popup_ts")) { popup_ts <- "n" }

## Set some defaults
network		<- network_names[1] # When using mutiple networks, units from network 1 will be used
filename     	<- NULL
filename_png 	<- NULL
plot_data    	<- NULL
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }

### Set file names and titles ###
filename[1]	<- paste(run_name1,species,pid,"spatialplot.html",sep="_")           # Filename for obs spatial plot
filename_png[1] <- paste(run_name1,species,pid,"spatialplot.png",sep="_")           # Filename for obs spatial plot

## Create a full path to file
filename[1]      <- paste(figdir,filename[1],sep="/")           # Filename for obs spatial plot
filename_png[1]  <- paste(figdir,filename_png[1],sep="/")           # Filename for obs spatial plot
#################################

########################################
### Set NULL values and plot symbols ###
########################################
sinfo_data      <- NULL
sinfo_data_tmp	<- NULL
diff_min        <- NULL
all_site	<- NULL
all_lats        <- NULL
all_lons        <- NULL
all_state	<- NULL
all_obs         <- NULL
all_mod         <- NULL
all_diff        <- NULL
all_rat	   	<- NULL
all_network	<- NULL
aqdat_out.df	<- NULL
########################################

remove_negatives_in <- remove_negatives	# Store option to remove negatives (applied later in the code)
remove_negatives <- 'n'      # Set remove negatives to false. Negatives are needed in the coverage calculation and will be removed automatically by Average
total_networks <- length(network_names)
k <- 1
for (j in 1:total_networks) {							# Loop through for each network
   Mod_Obs_Diff   <- NULL							# Set model/ob difference to NULL
   network        <- network_names[[j]]						# Determine network name from loop value
   #########################
   ## Query the database ###
   #########################
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,species)
         data_exists      <- sitex_info$data_exists
         if (data_exists == "y") {
            aqdat_query.df   <- sitex_info$sitex_data
            aqdat_query.df   <- aqdat_query.df[with(aqdat_query.df,order(network,stat_id)),]
            units            <- as.character(sitex_info$units[[1]])
         }
      }
      else {
         query_result   <- query_dbase(run_name1,network,species)
         aqdat_query.df <- query_result[[1]]
         data_exists    <- query_result[[2]]
         if (data_exists == "y") { units <- query_result[[3]] }
      }
   }
   #######################

   ob_col_name <- paste(species,"_ob",sep="")
   mod_col_name <- paste(species,"_mod",sep="")
   { 
      if (data_exists == "n") {
         total_networks <- (total_networks-1)
         if (total_networks == 0) { stop("Stopping because total_networks is zero. Likely no data found for query.") }
      }
      else {
         ####################################
         ## Compute Averages for Each Site ##
         ####################################
         averaging <- "e"	# For data to be averaged across all data for each site
         aqdat_in.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,State=aqdat_query.df$state,Obs_Value=round(aqdat_query.df[[ob_col_name]],5),Mod_Value=round(aqdat_query.df[[mod_col_name]],5),Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month)
         if ((network == "NADP") || (network == "AMON")) {
            aqdat_in.df$precip_ob <- aqdat_query.df$precip_ob
            aqdat_in.df$precip_mod <- aqdat_query.df$precip_mod
         }
         aqdat.df <- Average(aqdat_in.df)
         aqdat_out.df <- rbind(aqdat_out.df,aqdat_in.df)
	 Mod_Obs_Diff <- aqdat.df$Mod_Value-aqdat.df$Obs_Value
         Mod_Obs_Rat  <- aqdat.df$Mod_Value/aqdat.df$Obs_Value
         aqdat.df$Mod_Obs_Diff <- Mod_Obs_Diff
         aqdat.df$Mod_Obs_Rat  <- Mod_Obs_Rat
         ####################################

         ##################################################
         ## Store values for each network in array lists ##
         ##################################################
         sinfo_data_tmp<-data.frame(stat_id=aqdat.df$Stat_ID,lat=aqdat.df$lat,lon=aqdat.df$lon,State=aqdat.df$State,Obs_Val=aqdat.df$Obs_Value,Mod_Val=aqdat.df$Mod_Value,Diff_Val=aqdat.df$Mod_Obs_Diff,Network=network,Network_Number=k)

         all_site     <- c(all_site,aqdat.df$Stat_ID)
	 all_state    <- c(all_state,aqdat.df$State)
         all_lats     <- c(all_lats,aqdat.df$lat)
         all_lons     <- c(all_lons,aqdat.df$lon)
         all_obs      <- c(all_obs,aqdat.df$Obs_Value)
         all_mod      <- c(all_mod,aqdat.df$Mod_Value)
         all_diff     <- c(all_diff,aqdat.df$Mod_Obs_Diff)
         all_rat      <- c(all_rat,aqdat.df$Mod_Obs_Rat)
         all_network  <- c(all_network,network)
         ##################################################
         sinfo_data <- rbind(sinfo_data,sinfo_data_tmp)
	 k <- k+1
      }
   }
}
if ((remove_negatives_in == 'y') || (remove_negatives_in == 'Y') || (remove_negatives_in == 't') || (remove_negatives_in == 'T')) {
   indic.nonzero       	<- aqdat_out.df$Obs_Value >= 0
   aqdat_out.df		<- aqdat_out.df[indic.nonzero,]
   indic.nonzero       	<- aqdat_out.df$Mod_Value >= 0
   aqdat_out.df       	<- aqdat_out.df[indic.nonzero,]
}
if (custom_title != "") { 
   plot_title <- custom_title 
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

if (length(num_ints) == 0) {
   num_ints <- 20
}

plot_data[[1]] <- all_obs
plot_data[[2]] <- all_mod
plot_data[[3]] <- all_diff

data_all <- c(all_obs,all_mod)

{
   if (max(quantile(data_all,probs=quantile_max)) < 1) {
      data.seq <- pretty(seq(floor(min(quantile(data_all,probs=quantile_min))),ceiling(max(quantile(data_all,probs=quantile_max),na.rm=T))),n=20)
   }
   else {
      data.seq <- pretty(seq(min(quantile(data_all,probs=quantile_min)),max(quantile(data_all,probs=quantile_max),na.rm=T)),n=20)
   }
}
   if ((length(abs_range_min) != 0) || (length(abs_range_max) != 0)) {
      data.seq <- pretty(seq(abs_range_min,abs_range_max,by=(abs_range_max-abs_range_min)/10),n=num_ints)
   }
min.data <- min(data.seq)
max.data <- max(data.seq)

n.bins <- length(data.seq)
binpal2 <- colorBin(my.colors(10), c(min.data,max.data), n.bins-1 , pretty = FALSE)

plot_names <- c("OBS","MODEL","DIFF")
my.leaf <- my.leaf.base
Markers_Obs <- NULL
Markers_Mod <- NULL
Markers_Diff <- NULL
sinfo_data_in <- sinfo_data
for (i in 1:3) {
   if (custom_title == "") {
      plot_title <- paste(run_name1,species,dates,sep=" ") 
   }
   main_title_html <- tags$div(tag.map.title.html, HTML(plot_title))
   main_title_png  <- tags$div(tag.map.title.png, HTML(plot_title))

   if (i == 3) {
      range_max <- max(abs(min(quantile(plot_data[[i]],probs=quantile_min),na.rm=T)),max(quantile(plot_data[[i]],probs=quantile_max),na.rm=T))
      data.seq <- pretty(c(-range_max,range_max),n=num_ints)
      if ((length(diff_range_min) != 0) || (length(diff_range_max) != 0)) {
      	  data.seq <- pretty(c(diff_range_min,diff_range_max),n=num_ints)	#Changed from the line above to this, as having the seq made ranges less than 1 came out asymetrical. Not sure why.
      }

      min.data <- min(data.seq)
      max.data <- max(data.seq)
      n.bins <- length(data.seq)
      colors_cool_n <- abs(min.data)
      colors_warm_n <- abs(max.data)
      if ((abs(min.data) < 5) || (abs(max.data) < 5)) {
         colors_cool_n <- 10*(abs(min.data))
         colors_warm_n <- 10*(abs(max.data))
      }
      colors_cool <- colorRampPalette(colors=c("darkorchid4","purple", "#002FFF", "deepskyblue", "lightblue","gray80"))(colors_cool_n)
      colors_warm <- colorRampPalette(colors=c("gray80","palegoldenrod", "yellow", "orange", "red", "brown"))(colors_warm_n)
      rampcols <- c(colors_cool,colors_warm)
      binpal2 <- colorBin(palette=rampcols, c(min.data,max.data), n.bins-1 , pretty = FALSE)
   }

   for (j in 1:length(network_names)) {
      sinfo_data <- subset(sinfo_data_in,Network==network_names[j])
      Marker <- c(paste(network_names[j],plot_names[i],sep="_"))
      if(i == 1) { 
         plot_val <- sinfo_data$Obs_Val 
         Markers_Obs <-  c(Markers_Obs,Marker)
         min.data.obs <- min.data
         max.data.obs <- max.data
         binpal_obs <- binpal2
      }
      if(i == 2) { 
         plot_val <- sinfo_data$Mod_Val 
         Markers_Mod <-  c(Markers_Mod,Marker)
         min.data.mod <- min.data
         max.data.mod <- max.data
         binpal_mod <- binpal2
      }
      if(i == 3) { 
         plot_val <- sinfo_data$Diff_Val 
         Markers_Diff <-  c(Markers_Diff,Marker)
         min.data.diff <- min.data
         max.data.diff <- max.data
         binpal_diff <- binpal2
      }
      data.df <- data.frame(network=sinfo_data$Network,site.id=sinfo_data$stat_id,latitude=sinfo_data$lat,longitude=sinfo_data$lon,data.obs=plot_val)
      contents <- paste("Site: ", sinfo_data$stat_id,
                  "<br/>",
                  "Network: ", sinfo_data$Network, 
                  "<br/>",
		  "Latitude: ",sinfo_data$lat,
                  "<br/>",
		  "Longitude: ",sinfo_data$lon,
                  "<br/>",
		  "State: ",sinfo_data$State,
                  "<br/>",
                  "Obs: ", round(sinfo_data$Obs_Val, 2),units,
                  "<br/>",
                  "Mod: ", round(sinfo_data$Mod_Val, 2),units,
                  "<br/>",
                  "Diff:", round(sinfo_data$Diff_Val, 2),units, sep=" ")

      contents2 <- paste("Site: ", sinfo_data$stat_id,
                  "  Network: ", sinfo_data$Network,
                  "  Value: ", round(plot_val, 2), units, sep=" ")
      stations <- unique(data.df$site.id)
      aqdat_out.df$Date_Hour <- (paste(aqdat_out.df$Start_Date," ",aqdat_out.df$Hour,":00:00",sep=""))
      if ((i == 1) && (length(stations) <= 100) && (popup_ts == 'y')) {
         plist <- lapply(stations,
                         function(m)
				xyplot(Obs_Value + Mod_Value + (Mod_Value-Obs_Value) ~ as.POSIXct(Date_Hour), data = aqdat_out.df,
                                       subset = (Stat_ID == m),
				       superpose=T,
				       col=c("black","red","blue"),
				       lwd=2,
				       scales=list(tck=c(1,1),x=list(cex=1.2),y=list(cex=1.2)),
				       lty=c(1,1,2),
				       key=list(cex.title=2,
					  text = list(c("Obs","Model","Diff"),cex=1.5),
					  lines = list(lwd=2, lty=c(1,1,2), col=c("black","red","blue"))
				       ),
				       type = c("l","g"),
				       xlab = list(label='Date',cex=1.5), 
				       ylab = list(label=paste(species," (",units,")",sep=""),cex=1.5) 
				)
		          )
      }
      if(!exists("plot_radius")) { plot_radius <- 0 }
      if(!exists("outlier_radius")) { outlier_radius <- 40 }
      if(!exists("fill_opacity")) { fill_opacity <- 0.8 }
      plot_rad <- plot_radius
      if (plot_rad == 0) {
         max.radius <- 20
         min.radius <- 4
         ecdf_data <- c(all_obs,all_mod)
         if (i == 3) { ecdf_data <- all_diff }
            plot_rad <- ecdf(abs(ecdf_data))(abs(plot_val))*max.radius
            plot_rad[plot_rad < min.radius] <- min.radius
         if (quantile_max != 1 || quantile_min != 0) {
            plot_rad[abs(plot_val) > max.data] <- outlier_radius
         }
	 my_icons2 <- iconList(
              	  circle = makeIcon(iconUrl = "https://www.freeiconspng.com/uploads/black-circle-icon-23.png",
                          iconWidth = 18, iconHeight = 18),
		  square = makeIcon(iconUrl = "https://www.freeiconspng.com/uploads/black-square-frame-23.png",
                          iconWidth = 18, iconHeight = 18),
		  triangle = makeIcon(iconUrl = "https://www.freeiconspng.com/uploads/triangle-png-28.png",
                            iconWidth = 18, iconHeight = 18)
	 )
	 if ((length(stations) <= 100) && (popup_ts == 'y')) {
            my.leaf <- my.leaf %>% addCircleMarkers(sinfo_data$lon,sinfo_data$lat,color="black",fillColor=~binpal2(plot_val),group=Marker,radius=plot_rad*symbsizfac,data=data.df,opacity=1,fillOpacity=fill_opacity,stroke=TRUE,weight=1,popup=popupGraph(plist,width=1000,height=1000),label=contents2, labelOptions = labelOptions(noHide = F, textsize = "15px")) 
	 }
	 else {
	    my.leaf <- my.leaf %>% addCircleMarkers(sinfo_data$lon,sinfo_data$lat,color="black",fillColor=~binpal2(plot_val),group=Marker,radius=plot_rad*symbsizfac,data=data.df,opacity=1,fillOpacity=fill_opacity,stroke=TRUE,weight=1,popup=contents, label=contents2, labelOptions = labelOptions(noHide = F, textsize = "15px"))
         }
      }
   } # End network loop
} # End plot val loop

my.leaf <- my.leaf %>% addLegend("bottomright", pal = binpal_obs, values = c(min.data.obs,max.data.obs), group=Markers_Obs, title = paste(species,"<br/>Ob / Mod <br/> (",units,")",sep=""), opacity = 2)
my.leaf <- my.leaf %>% addLegend("bottomleft", pal = binpal_diff, values = c(min.data.diff,max.data.diff), group=Markers_Diff, title = paste(species,"<br/>Diff <br/> (",units,")",sep=""), opacity = 2)
my.leaf <- my.leaf %>% addControl(main_title_html,position="topright",className="map-title")
my.leaf <- my.leaf %>%
        addLayersControl(
          baseGroups = base_Groups, overlayGroups = c(network_names), options =  layersControlOptions(collapsed = FALSE,position="topleft")
        )
#my.leaf <- my.leaf %>%
#  addGroupedLayersControl(
#    baseGroups = base_Groups, overlayGroups = list("OBS" = Markers_Obs,"MODEL"=Markers_Mod,"DIFF"=Markers_Diff),position="topleft",
#       options = groupedLayersControlOptions(groupCheckboxes = TRUE,collapsed = FALSE,groupsCollapsable = FALSE,sortLayers = FALSE,sortGroups = FALSE,sortBaseLayers = FALSE)
#  )
saveWidget(my.leaf, file=filename,selfcontained=T)
