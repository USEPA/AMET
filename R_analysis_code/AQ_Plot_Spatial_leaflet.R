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
ametbase	<- Sys.getenv("AMETBASE")			# base directory of AMET
ametR		<- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Load Required Libraries 
if(!require(maps)){stop("Required Package maps was not loaded")}
if(!require(mapdata)){stop("Required Package mapdata was not loaded")}

if(!exists("quantile_min")) { quantile_min <- 0.001 }
if(!exists("quantile_max")) { quantile_max <- 0.950 }

### Retrieve units label from database table ###
network		<- network_names[1] # When using mutiple networks, units from network 1 will be used
#units_qs	<- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="") # Create MYSQL query from units table
################################################

filename <- NULL
plot_data <- NULL

### Set file names and titles ###
filename[1]	<- paste(run_name1,species,pid,"spatialplot_obs.html",sep="_")           # Filename for obs spatial plot
filename[2]	<- paste(run_name1,species,pid,"spatialplot_mod.html",sep="_")           # Filename for model spatial plot
filename[3]	<- paste(run_name1,species,pid,"spatialplot_diff.html",sep="_")          # Filename for diff spatial plot
filename_rat	<- paste(run_name1,species,pid,"spatialplot_ratio",sep="_")         # Filename for diff spatial plot

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }

## Create a full path to file
filename[1]      <- paste(figdir,filename[1],sep="/")           # Filename for obs spatial plot
filename[2]      <- paste(figdir,filename[2],sep="/")           # Filename for model spatial plot
filename[3]      <- paste(figdir,filename[3],sep="/")          # Filename for diff spatial plot
filename_rat      <- paste(figdir,filename_rat,sep="/")           # Filename for diff spatial plot
########################################
### Set NULL values and plot symbols ###
########################################
sinfo_obs       <- NULL						# Set list for obs values to NULL
sinfo_mod       <- NULL						# Set list for model values to NULL
sinfo_diff      <- NULL						# Set list for difference values to NULL
sinfo_rat	<- NULL
sinfo_data      <- NULL
diff_min        <- NULL
all_site	<- NULL
all_lats        <- NULL
all_lons        <- NULL
all_obs         <- NULL
all_mod         <- NULL
all_diff        <- NULL
all_rat	   	<- NULL
all_network	<- NULL
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

#   count <- sum(is.na(aqdat_query.df[,9]))
#   len   <- length(aqdat_query.df[,9])

#   if (count != len) {	# Continue if query returned non-missing data

   ob_col_name <- paste(species,"_ob",sep="")
   mod_col_name <- paste(species,"_mod",sep="")
   { 
      if (data_exists == "n") {
         total_networks <- (total_networks-1)
         sub_title<-paste(sub_title,network_label[j],"=No Data; ",sep="")      # Set subtitle based on network matched with the appropriate symbol
         if (total_networks == 0) { stop("Stopping because total_networks is zero. Likely no data found for query.") }
      }
      else {
         ####################################
         ## Compute Averages for Each Site ##
         ####################################
         averaging <- "a"
         aqdat_in.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=round(aqdat_query.df[[ob_col_name]],5),Mod_Value=round(aqdat_query.df[[mod_col_name]],5),Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month)
         aqdat.df <- Average(aqdat_in.df)
         Mod_Obs_Diff <- aqdat.df$Mod_Value-aqdat.df$Obs_Value
         Mod_Obs_Rat  <- aqdat.df$Mod_Value/aqdat.df$Obs_Value
         aqdat.df$Mod_Obs_Diff <- Mod_Obs_Diff
         aqdat.df$Mod_Obs_Rat  <- Mod_Obs_Rat
         ####################################

         ##################################################
         ## Store values for each network in array lists ##
         ##################################################
         sinfo_data[[k]]<-list(stat_id=aqdat.df$Stat_ID,lat=aqdat.df$lat,lon=aqdat.df$lon,Obs_Val=aqdat.df$Obs_Value,Mod_Val=aqdat.df$Mod_Value,Diff_Val=aqdat.df$Mod_Obs_Diff,Network=network)
#         sinfo_mod_data[[k]]<-list(stat_id=aqdat.df$Stat_ID,lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Value,network=network)
#         sinfo_diff_data[[k]]<-list(stat_id=aqdat.df$Stat_ID,lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Obs_Diff,network=network)
#         sinfo_rat_data[[k]]<-list(lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Obs_Rat,network=network)


         all_site <- c(all_site,aqdat.df$Stat_ID)
         all_lats <- c(all_lats,aqdat.df$lat)
         all_lons <- c(all_lons,aqdat.df$lon)
         all_obs  <- c(all_obs,aqdat.df$Obs_Value)
         all_mod  <- c(all_mod,aqdat.df$Mod_Value)
         all_diff <- c(all_diff,aqdat.df$Mod_Obs_Diff)
         all_rat  <- c(all_rat,aqdat.df$Mod_Obs_Rat)
         all_network  <- c(all_network,network)
         ##################################################
         sub_title<-paste(sub_title,symbols[k],"=",network_label[j],"; ",sep="")      # Set subtitle based on network matched with the appropriate symbol
         k <- k+1
      }
   }
}

{
   if (custom_title == "") { 
      title <- paste(run_name1, "<br>", dates, "<br>", species," (",units,")",sep="") 
      title_bias <- paste(run_name1, "<br>", dates, "<br>", species," (",units,") Bias",sep="")
}
   else { 
      title <- custom_title 
      title_bias <- custom_title
   }
}

library(leaflet)
library(maps)
library(htmlwidgets)
#require(raster)
#require(rgdal)

mapStates <- map("state",fill=T,plot=F)
my.diff.colors <- colorRampPalette(c("darkorchid4","purple", "#002FFF", "deepskyblue", "lightblue", "palegoldenrod", "yellow", "orange", "red", "brown"))
my.colors <- colorRampPalette(c(grey(.8),"mediumpurple","darkorchid4", "#002FFF", "green", "yellow", "orange", "red", "brown"))

if (length(num_ints) == 0) {
   num_ints <- 20
}

plot_data[[1]] <- all_obs
plot_data[[2]] <- all_mod
plot_data[[3]] <- all_diff

for (i in 1:3) {
   if (i == 3) { title <- title_bias }
#  aqs.dat <- subset(o3.obs.df,date==pick.days[i])
#  xyz <- data.frame(x=expand.grid(x.proj.12,y.proj.12)[,1]*1000,y=expand.grid(x.proj.12,y.proj.12)[,2]*1000,z=matrix(o3.mod.array[,,i]))
#  o3.mod.raster <- rasterFromXYZ(xyz,crs="+proj=lcc +lat_1=33 +lat_2=45 +lat_0=40 +lon_0=-97 +a=6370000 +b=6370000")

  data.df <- data.frame(site.id=all_site,latitude=all_lats,longitude=all_lons,data.obs=plot_data[[i]])
  
  data.seq <- pretty(seq(min(quantile(plot_data[[i]],probs=quantile_min)),max(quantile(plot_data[[i]],probs=quantile_max),na.rm=T)),n=20)
  if ((length(abs_range_min) != 0) || (length(abs_range_max) != 0)) {
     data.seq <- pretty(seq(abs_range_min,abs_range_max,na.rm=T),n=num_ints)
  }
  min.data <- min(data.seq)
  max.data <- max(data.seq)

  n.bins <- length(data.seq)
  binpal2 <- colorBin(my.colors(10), c(min.data,max.data), n.bins-1 , pretty = FALSE)

  if (i == 3) {
     range_max <- max(abs(min(quantile(plot_data[[i]],probs=quantile_min),na.rm=T)),max(quantile(plot_data[[i]],probs=quantile_max),na.rm=T))
     data.seq <- pretty(c(-range_max,range_max),n=num_ints)
     min.data <- min(data.seq)
     max.data <- max(data.seq)
     if ((length(diff_range_min) != 0) || (length(diff_range_max) != 0)) {
        data.seq <- pretty(seq(diff_range_min,diff_range_max,na.rm=T),n=num_ints)
     }
     n.bins <- length(data.seq)
     binpal2 <- colorBin(my.diff.colors(10), c(min.data,max.data), n.bins-1 , pretty = FALSE)
      
  }

   leaflet_map <- c("OpenStreetMap.Mapnik","OpenStreetMap.BlackAndWhite","OpenTopoMap","Esri.WorldImagery","Esri.WorldStreetMap")

#  Other available maps: http://leaflet-extras.github.io/leaflet-providers/preview/index.html
#my.leaf <- leaflet(data=mapStates)  %>% addProviderTiles("MapQuestOpen.Aerial")  %>%
#my.leaf <- leaflet(data=mapStates) %>% addProviderTiles("OpenStreetMap.BlackAndWhite")  %>%
#my.leaf <- leaflet(data=mapStates) %>% addProviderTiles("OpenStreetMap.Mapnik")  %>%
#my.leaf <- leaflet(data=mapStates) %>% addProviderTiles("OpenTopoMap")  %>%
   my.leaf <- leaflet(data=mapStates) %>% addProviderTiles(leaflet_map[1],group="Street Map")  %>% 
                                       addProviderTiles(leaflet_map[2],group="B&W Street Map")  %>%
                                       addProviderTiles(leaflet_map[3],group="Topo Map") %>%
                                       addProviderTiles(leaflet_map[4],group="ESRI World Imagery") %>%
                                       addProviderTiles(leaflet_map[5],group="ESRI Street Map")

#        addRasterImage(o3.mod.raster,colors=binpal2,opacity=.5) %>%
#        addCircles(all_lons,all_lats,color=~binpal2(plot_data[[i]]),radius=100,data=data.df,opacity=1,fillOpacity=1,popup=contents)%>%
        for (j in 1:length(network_names)) {
           if(i == 1) { plot_val <- sinfo_data[[j]]$Obs_Val }
           if(i == 2) { plot_val <- sinfo_data[[j]]$Mod_Val }
           if(i == 3) { plot_val <- sinfo_data[[j]]$Diff_Val }
           data.df <- data.frame(site.id=sinfo_data[[j]]$stat_id,latitude=sinfo_data[[j]]$lat,longitude=sinfo_data[[j]]$lon,data.obs=plot_val)
           contents <- paste("Site: ", sinfo_data[[j]]$stat_id,
                  "<br/>",
                  "Network: ", network_names[[j]], 
                  "<br/>",
                  "Obs: ", round(sinfo_data[[j]]$Obs_Val, 2),units,
                  "<br/>",
                  "Mod: ", round(sinfo_data[[j]]$Mod_Val, 2),units,
                  "<br/>",
                  "Diff:", round(sinfo_data[[j]]$Diff_Val, 2),units, sep=" ")

           contents2 <- paste("Site: ", sinfo_data[[j]]$stat_id,
                              "  Network: ", network_names[[j]],
                              "  Value: ", round(plot_val, 2), units, sep=" ")
        
           my.leaf <- my.leaf %>% addCircleMarkers(sinfo_data[[j]]$lon,sinfo_data[[j]]$lat,color=~binpal2(plot_val),group=network_names[[j]],radius=5,data=data.df,opacity=1,fillOpacity=1,popup=contents,label=contents2)
         }
        my.leaf <- my.leaf %>% addLegend("bottomright", pal = binpal2, values = c(min.data,max.data), title = title, opacity = 2) %>%

        addLayersControl(
          baseGroups = c("Street Map","B&W Street Map","Topo Map","ESRI World Imagery","ESRI Street Map"),
          overlayGroups = c(network_names),
          options =  layersControlOptions(collapsed = FALSE,position="topleft")
        )

saveWidget(my.leaf, file=filename[i],selfcontained=T)
}

