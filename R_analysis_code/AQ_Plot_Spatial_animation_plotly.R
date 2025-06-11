header <- "
###################### SPATIAL PLOT W/ ANIMATION (PLOTLY VERSION) ########################
### AMET CODE: AQ_Plot_Spatial_animation_plotly.R 
###
### This code is part of the AMET-AQ system.  The Plot Spatial code takes a MYSQL database
### query for a single species from one or more networks and plots the observation value, 
### model value, and difference between the model and ob for each site for each corresponding
### network.  Mutiple values for a site are averaged to a single value for static plotting 
### purposes, while the temporal data are retained and used to create an html plot with a
### time slider bar. This script outputs HTML files.
###
### The map area plotted is dynamically generated from the input data.   
###
### Create by Wyat Appel: June 2025
##########################################################################################
"
## get some environmental variables and setup some directories
ametbase	<- Sys.getenv("AMETBASE")			# base directory of AMET
ametR		<- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Load Required Libraries 
if(!require(maps))	{ stop("Required Package maps was not loaded") 		}
if(!require(mapdata))	{ stop("Required Package mapdata was not loaded") 	}
if(!require(ggplot2))	{ stop("Required Package ggplot2 was not loaded") 	}
if(!require(plotly))   	{ stop("Required Package plotly was not loaded") 	}
if(!require(sf))   	{ stop("Required Package sf was not loaded") 		}

## Set some defaults  
network		<- network_names[1] # When using mutiple networks, units from network 1 will be used
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
title <- get_title(run_names,species,network_label,dates,custom_title,site=site,state=state,rpo=rpo,pca=pca,clim_reg=clim_reg)

## Set file names and titles
filename_obs_html               <- paste(run_name1,species,pid,"spatialplot_obs.html",sep="_")           # Filename for obs spatial plot
filename_mod_html               <- paste(run_name1,species,pid,"spatialplot_mod.html",sep="_")           # Filename for model spatial plot
filename_diff_html              <- paste(run_name1,species,pid,"spatialplot_diff.html",sep="_")          # Filename for diff spatial plot
filename_diff_max_html          <- paste(run_name1,species,pid,"spatialplot_diff_max.html",sep="_")          # Filename for diff spatial plot
filename_diff_abs_max_html      <- paste(run_name1,species,pid,"spatialplot_diff_abs_max.html",sep="_")          # Filename for diff spatial plot
filename_obs_anim    		<- paste(run_name1,species,pid,"spatialplot_anim_obs.html",sep="_")           # Filename for obs spatial plot
filename_mod_anim    		<- paste(run_name1,species,pid,"spatialplot_anim_mod.html",sep="_")           # Filename for model spatial plot
filename_diff_anim   		<- paste(run_name1,species,pid,"spatialplot_anim_diff.html",sep="_")          # Filename for diff spatial plot
filename_html_tile		<- paste(run_name1,species,pid,"spatialplot_tile.html",sep="_")
filename_html_tile_anim         <- paste(run_name1,species,pid,"spatialplot_tile_anim.html",sep="_")

## Create a full path to file
filename_obs_html      		<- paste(figdir,filename_obs_html,sep="/")           # Filename for obs spatial plot
filename_mod_html 	     	<- paste(figdir,filename_mod_html,sep="/")           # Filename for model spatial plot
filename_diff_html	     	<- paste(figdir,filename_diff_html,sep="/")          # Filename for diff spatial plot
filename_diff_max_html          <- paste(figdir,filename_diff_max_html,sep="/")          # Filename for diff spatial plot
filename_diff_abs_max_html      <- paste(figdir,filename_diff_abs_max_html,sep="/")          # Filename for diff spatial plot
filename_html_tile		<- paste(figdir,filename_html_tile,sep="/")

filename_obs_anim      	<- paste(figdir,filename_obs_anim,sep="/")           # Filename for obs spatial plot
filename_mod_anim      	<- paste(figdir,filename_mod_anim,sep="/")           # Filename for model spatial plot
filename_diff_anim     	<- paste(figdir,filename_diff_anim,sep="/")          # Filename for diff spatial plot
filename_html_tile_anim	<- paste(figdir,filename_html_tile_anim,sep="/")

########################################
### Set NULL values and plot symbols ###
########################################
sinfo_obs       	<- NULL						# Set list for obs values to NULL
sinfo_mod       	<- NULL						# Set list for model values to NULL
sinfo_diff      	<- NULL						# Set list for difference values to NULL
sinfo_rat		<- NULL
sinfo_obs_data  	<- NULL
sinfo_mod_data 		<- NULL
sinfo_diff_data 	<- NULL
sinfo_diff_max  	<- NULL
sinfo_diff_abs_max	<- NULL
sinfo_rat_data  	<- NULL
sinfo_obs_anim  	<- NULL                                         # Set list for obs values to NULL
sinfo_mod_anim  	<- NULL                                         # Set list for model values to NULL
sinfo_diff_anim 	<- NULL                                         # Set list for difference values to NULL
sinfo_obs_data_anim  	<- NULL
sinfo_mod_data_anim  	<- NULL
sinfo_diff_data_anim 	<- NULL
diff_min        	<- NULL
all_lats        	<- NULL
all_lons        	<- NULL
all_obs         	<- NULL
all_mod         	<- NULL
all_diff        	<- NULL
all_diff_max		<- NULL
all_diff_abs_max	<- NULL
all_rat	   		<- NULL
bounds          	<- NULL						# Set map bounds to NULL
sp_tile			<- NULL
sp_anim_tile		<- NULL
plot.symbols<-as.integer(plot_symbols)
pick.symbol.name.fun<-function(x){
   master.symbol.df<-data.frame(plot.symbols=c(16,17,15,18,8,11,4),names=c("CIRCLE","TRIANGLE","SQUARE","DIAMOND","BURST","STAR","X"))
   as.character(master.symbol.df$names[x==master.symbol.df$plot.symbols])
}
plot_symbols2 <- c("circle","triangle","square")
pick.symbol2.fun<-function(x){
   master.symbol2.df<-data.frame(plot.symbols=c(16,17,15,18,8,11,4),plot.symbols2=c(1,2,0,5,8,11,4))
   as.integer(master.symbol2.df$plot.symbols2[x==master.symbol2.df$plot.symbols])
}
symbols<-apply(matrix(plot.symbols),1,pick.symbol.name.fun)
spch2 <- apply(matrix(plot.symbols),1,pick.symbol2.fun)
spch<-plot.symbols
########################################

rm_negs <- remove_negatives
remove_negatives <- 'n'      # Set remove negatives to false. Negatives are needed in the coverage calculation and will be removed automatically by Average
total_networks <- length(network_names)
network_names_in <- network_names
k <- 1
for (j in 1:total_networks) {							# Loop through for each network
   Mod_Obs_Diff   <- NULL							# Set model/ob difference to NULL
   network        <- network_names_in[[j]]						# Determine network name from loop value
   network_number <- k 
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

   { 
      if (data_exists == "n") {
         total_networks <- (total_networks-1)
         network_names <- network_names[-j]
#         sub_title<-paste(sub_title,network_label[j],"=No Data; ",sep="")      # Set subtitle based on network matched with the appropriate symbol
         if (total_networks == 0) { stop("Stopping because total_networks is zero. Likely no data found for query.") }
      }
      else {
         ####################################
         ## Compute Averages for Each Site ##
         ####################################
         if (averaging == "n") { averaging <- "e" }
         ob_col_name <- paste(species,"_ob",sep="")
         mod_col_name <- paste(species,"_mod",sep="")
         aqdat_in.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=round(aqdat_query.df[[ob_col_name]],5),Mod_Value=round(aqdat_query.df[[mod_col_name]],5),Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month)
         if ((network == "NADP") || (network == "AMON")) {
            aqdat_in.df$precip_ob <- aqdat_query.df$precip_ob
            aqdat_in.df$precip_mod <- aqdat_query.df$precip_mod
         }
         aqdat_anim.df <- aqdat_in.df
	 Mod_Obs_Diff_Max <- abs(max(aqdat_in.df$Mod_Value-aqdat_in.df$Obs_Value))
	 aqdat.df <- Average(aqdat_in.df,avg_func="mean")
	 aqdat_max.df <- Average(aqdat_in.df,avg_func="max")
         ## Remove missing and zero concentration observations from dataset ##
         if ((rm_negs == "T") || (rm_negs == "t") || (rm_negs == "Y") || (rm_negs == "y")) {
            indic.nonzero <- aqdat_anim.df$Obs_Value >= 0
            aqdat_anim.df <- aqdat_anim.df[indic.nonzero,]
            indic.nonzero <- aqdat_anim.df$Mod_Value >= 0
            aqdat_anim.df <- aqdat_anim.df[indic.nonzero,]
         }
         ##############################################

	 Mod_Obs_Diff 			<- aqdat.df$Mod_Value-aqdat.df$Obs_Value
         Mod_Obs_Rat  			<- aqdat.df$Mod_Value/aqdat.df$Obs_Value
         Mod_Obs_Diff_Max 		<- aqdat_max.df$Mod_Value-aqdat_max.df$Obs_Value 
	 Mod_Obs_Diff_Abs_Max           <- abs(aqdat_max.df$Mod_Value-aqdat_max.df$Obs_Value)
	 aqdat.df$Mod_Obs_Diff 		<- Mod_Obs_Diff
         aqdat.df$Mod_Obs_Rat  		<- Mod_Obs_Rat
	 aqdat.df$Mod_Obs_Diff_Max 	<- Mod_Obs_Diff_Max
	 aqdat.df$Mod_Obs_Diff_Abs_Max	<- Mod_Obs_Diff_Abs_Max
         ####################################

         ##################################################
         ## Store values for each network in array lists ##
         ##################################################
         sinfo_obs[[k]]<-list(stat_id=aqdat.df$Stat_ID,lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Obs_Value,date=aqdat.df$Start_Date,network=network)
         sinfo_mod[[k]]<-list(stat_id=aqdat.df$Stat_ID,lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Value,date=aqdat.df$Start_Date,network=network)
         sinfo_diff[[k]]<-list(stat_id=aqdat.df$Stat_ID,lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Obs_Diff,date=aqdat.df$Start_Date,network=network)
         sinfo_diff_max[[k]]<-list(stat_id=aqdat.df$Stat_ID,lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Obs_Diff_Max,date=aqdat.df$Start_Date,network=network)
	 sinfo_diff_abs_max[[k]]<-list(stat_id=aqdat.df$Stat_ID,lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Obs_Diff_Abs_Max,date=aqdat.df$Start_Date,network=network)
	 sinfo_rat[[k]]<-list(stat_id=aqdat.df$Stat_ID,lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Obs_Rat,date=aqdat.df$Start_Date,network=network)

	 Mod_Obs_Diff <- aqdat_anim.df$Mod_Value-aqdat_anim.df$Obs_Value
         aqdat_anim.df$Mod_Obs_Diff <- Mod_Obs_Diff
         ####################################

         ##################################################
         ## Store values for each network in array lists ##
         ##################################################
         sinfo_obs_anim[[k]]	<-list(stat_id=aqdat_anim.df$Stat_ID,lat=aqdat_anim.df$lat,lon=aqdat_anim.df$lon,plotval=aqdat_anim.df$Obs_Value,date=paste(aqdat_anim.df$Start_Date,aqdat_anim.df$Hour),network=network)
         sinfo_mod_anim[[k]]	<-list(stat_id=aqdat_anim.df$Stat_ID,lat=aqdat_anim.df$lat,lon=aqdat_anim.df$lon,plotval=aqdat_anim.df$Mod_Value,date=paste(aqdat_anim.df$Start_Date,aqdat_anim.df$Hour),network=network)
         sinfo_diff_anim[[k]]	<-list(stat_id=aqdat_anim.df$Stat_ID,lat=aqdat_anim.df$lat,lon=aqdat_anim.df$lon,plotval=aqdat_anim.df$Mod_Obs_Diff,date=paste(aqdat_anim.df$Start_Date,aqdat_anim.df$Hour),network=network)
         all_lats 		<- c(all_lats,aqdat.df$lat)
         all_lons 		<- c(all_lons,aqdat.df$lon)
         all_obs  		<- c(all_obs,aqdat.df$Obs_Value)
         all_mod  		<- c(all_mod,aqdat.df$Mod_Value)
         all_diff 		<- c(all_diff,aqdat.df$Mod_Obs_Diff)
	 all_diff_max 		<- c(all_diff_max,aqdat.df$Mod_Obs_Diff_Max)
         all_diff_abs_max	<- c(all_diff_abs_max,aqdat.df$Mod_Obs_Diff_Abs_Max)
 	 all_rat  		<- c(all_rat,aqdat.df$Mod_Obs_Rat)
         ##################################################
	 k <- k+1
      }
   }
}
#########################
## plot format options ##
#########################
bounds<-c(min(all_lats,bounds[1]),max(all_lats,bounds[2]),min(all_lons,bounds[3]),max(all_lons,bounds[4]))
xrange <- abs(bounds[4])-abs(bounds[3])
x1 <- bounds[3]-0.85*xrange
x2 <- bounds[3]-0.82*xrange
x3 <- bounds[3]-0.85*xrange
x4 <- bounds[3]-0.78*xrange
lat_mid <- mean(range(all_lats))
lon_mid <- mean(range(all_lons))
plotsize<-1.50									# Set plot size
symb<-15										# Set symbol character
symbsiz<-1.1										# Set symbol size
if (length(unique(aqdat_in.df$Stat_ID)) > 3000) {
   symbsiz <- 0.9
}
if (length(unique(aqdat_in.df$Stat_ID)) > 10000) {
   symbsiz <- 0.7
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
{
   if ((length(abs_range_min) == 0) || (length(abs_range_max) == 0)) {
      all_data <- c(all_obs,all_mod)
      levs <- pretty(c(quantile(all_data,quantile_min),quantile(all_data,quantile_max)),intervals,min.n=5)
   }
   else {
      levs <- pretty(c(abs_range_min,abs_range_max),intervals,min.n=5)
   }
}
###########################################################################



#################################################
{
   if ((length(diff_range_min) == 0) || (length(diff_range_max) == 0)) {
      diff_max <- max(quantile(abs(all_diff),quantile_max))
      diff_min <- -diff_max
      diff_max_max <- max(quantile(abs(all_diff_max),0.990))
      diff_max_min <- -diff_max_max
      diff_abs_max_max <- max(quantile(abs(all_diff_abs_max),0.990))
      diff_abs_max_min <- floor(min(quantile(abs(all_diff_abs_max),0.005)))
   }
   else {
      diff_max <- diff_range_max
      diff_min <- diff_range_min
      diff_max_max <- diff_range_max
      diff_max_min <- diff_range_min
   }
}
#####################################################################

##############################################
## Create PNG and PDF plots for NMB and NME ##
##############################################
plot_names 	<- c("Obs","Model","Diff","Max Diff","Abs(Max Diff)")
plot_names_anim	<- c("Obs","Model","Mod-Obs")
subplot_names	<- c("mapbox","mapbox2","mapbox3","mapbox4","mapbox5")
for (i in 1:5) {
   if (i == 1) { 
      sinfo		<- sinfo_obs
      sinfo_anim        <- sinfo_obs_anim
      plot_range_min 	<- min(levs)
      plot_range_max 	<- max(levs)
      filename_html	<- filename_obs_html
      filename_anim	<- filename_obs_anim
      color_palette     <- list(c(0, "#8B008B"), list(0.15, "violet"),c(0.15, "violet"), list(0.35, "blue"),c(0.35, "blue"), list(0.5, "green"),c(0.5, "green"), list(0.65, "yellow"),c(0.65, "yellow"), list(0.75, "orange"),c(0.75, "orange"), list(0.85, "red"),c(0.85, "red"), list(1, "#8B0000"))
   }
   if (i == 2) { 
      sinfo		<- sinfo_mod
      sinfo_anim	<- sinfo_mod_anim
      plot_range_min 	<- min(levs)
      plot_range_max 	<- max(levs)
      filename_html     <- filename_mod_html
      filename_anim	<- filename_mod_anim
      color_palette	<- "Jet"
      color_palette     <- list(c(0, "#8B008B"), list(0.15, "violet"),c(0.15, "violet"), list(0.35, "blue"),c(0.35, "blue"), list(0.5, "green"),c(0.5, "green"), list(0.65, "yellow"),c(0.65, "yellow"), list(0.75, "orange"),c(0.75, "orange"), list(0.85, "red"),c(0.85, "red"), list(1, "#8B0000"))
   }
   if (i == 3) {
      sinfo             <- sinfo_diff
      sinfo_anim        <- sinfo_diff_anim
      plot_range_min    <- diff_min
      plot_range_max    <- diff_max
      filename_html	<- filename_diff_html
      filename_anim     <- filename_diff_anim
      color_palette     <- list(c(0, "violet"), list(0.15, "blue"),c(0.15, "blue"), list(0.35, "green"),c(0.35, "green"), list(0.5, "white"),c(0.5, "white"), list(0.65, "yellow"),c(0.65, "yellow"), list(0.75, "orange"),c(0.75, "orange"), list(0.85, "red"),c(0.85, "red"), list(1, "#8B0000"))
   }
   if (i == 4) {
      sinfo             <- sinfo_diff_max
      plot_range_min    <- diff_max_min
      plot_range_max    <- diff_max_max
      filename_html     <- filename_diff_max_html
      filename_anim     <- filename_diff_anim
      color_palette     <- list(c(0, "violet"), list(0.15, "blue"),c(0.15, "blue"), list(0.35, "green"),c(0.35, "green"), list(0.5, "white"),c(0.5, "white"), list(0.65, "yellow"),c(0.65, "yellow"), list(0.75, "orange"),c(0.75, "orange"), list(0.85, "red"),c(0.85, "red"), list(1, "#8B0000"))
   }
   if (i == 5) {
      sinfo		<- sinfo_diff_abs_max
      plot_range_min    <- diff_abs_max_min
      plot_range_max    <- diff_abs_max_max
      filename_html	<- filename_diff_abs_max_html
      filename_anim     <- filename_diff_anim
      color_palette     <- list(c(0, "#8B008B"), list(0.15, "violet"),c(0.15, "violet"), list(0.35, "blue"),c(0.35, "blue"), list(0.5, "green"),c(0.5, "green"), list(0.65, "yellow"),c(0.65, "yellow"), list(0.75, "orange"),c(0.75, "orange"), list(0.85, "red"),c(0.85, "red"), list(1, "#8B0000"))
   }
   for (k in 1:total_networks) {
      us_state 	<- map_data("state")
      us_county <- map_data("county") 
      canada 	<- map_data("worldHires", "Canada")
      mexico 	<- map_data("worldHires", "Mexico")
      world_map	<- map_data("world")
      world	<- st_as_sf(world_map,coords=c("long","lat"))
      data_in    <- data.frame(stat_id=sinfo[[k]]$stat_id,lat=sinfo[[k]]$lat,lon=sinfo[[k]]$lon,plotval=sinfo[[k]]$plotval)
      data_in$Network <- network_label[k]
      if (k == 1) {
       	 sp 	<- plot_ly(data=data_in,lat = ~lat, lon=~lon, marker = list(color = 'black',showscale=FALSE,size=22),mode='markers',type='scattermapbox',name=paste0('BG (',plot_names[i],")"))
         spTile <- plot_ly(data=data_in,lat = ~lat, lon=~lon, marker = list(color = 'black',showscale=FALSE,size=22),mode='markers',type='scattermapbox',name=paste0('BG (',plot_names[i],")"),subplot=subplot_names[i])
         if (i == 1) {
    	    sp <- sp %>% add_trace(data=data_in,lat = ~lat, lon=~lon, marker = list(color = ~plotval,colorbar=list(title=paste0(plot_names[i],"<br>",species,"<br>",units)),colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=TRUE,size=20),mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>Value: ",signif(plotval,4)),hoverinfo='text',name=paste0(network_label[k],"(",plot_names[i],")"))
	    spTile <- spTile %>% add_trace(data=data_in,lat = ~lat, lon=~lon, marker = list(color = ~plotval,colorbar=list(title=paste0(plot_names[i],"<br>",units),len=0.5,lenmode="fraction",x=0.48,y=0.76),colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=TRUE,size=20),mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>Value: ",signif(plotval,4)),hoverinfo='text',name=paste0(network_label[k],"(",plot_names[i],")"))
	 }
	 if (i == 2) {
            sp <- sp %>% add_trace(data=data_in,lat = ~lat, lon=~lon, marker = list(color = ~plotval,colorbar=list(title=paste0(plot_names[i],"<br>",species,"<br>",units)),colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=TRUE,size=20),mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>Value: ",signif(plotval,4)),hoverinfo='text',name=paste0(network_label[k],"(",plot_names[i],")"))
            spTile <- spTile %>% add_trace(data=data_in,lat = ~lat, lon=~lon, marker = list(color = ~plotval,colorbar=list(title=paste0(plot_names[i],"<br>",units),len=0.5,lenmode="fraction",x=1,y=0.76),colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=TRUE,size=20),mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>Value: ",signif(plotval,4)),hoverinfo='text',name=paste0(network_label[k],"(",plot_names[i],")"))
         }
	 if (i == 3 ) {
            sp <- sp %>% add_trace(data=data_in,lat = ~lat, lon=~lon, marker = list(color = ~plotval,colorbar=list(title=paste0(plot_names[i],"<br>",species,"<br>",units)),colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=TRUE,size=20),mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>Value: ",signif(plotval,4)),hoverinfo='text',name=paste0(network_label[k],"(",plot_names[i],")"))
	    spTile <- spTile %>% add_trace(data=data_in,lat = ~lat, lon=~lon, marker = list(color = ~plotval,colorbar=list(title=paste0(plot_names[i],"<br>",units),len=0.5,lenmode="fraction",x=0.48,y=0.24),colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=TRUE,size=20),mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>Value: ",signif(plotval,4)),hoverinfo='text',name=paste0(network_label[k],"(",plot_names[i],")"))
         }
	 if (i == 4) {
            sp <- sp %>% add_trace(data=data_in,lat = ~lat, lon=~lon, marker = list(color = ~plotval,colorbar=list(title=paste0(plot_names[i],"<br>",species,"<br>",units)),colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=TRUE,size=20),mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>Value: ",signif(plotval,4)),hoverinfo='text',name=paste0(network_label[k],"(",plot_names[i],")"))
            spTile <- spTile %>% add_trace(data=data_in,lat = ~lat, lon=~lon, marker = list(color = ~plotval,colorbar=list(title=paste0(plot_names[i],"<br>",units),len=0.5,lenmode="fraction",x=1,y=0.24),colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=TRUE,size=20),mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>Value: ",signif(plotval,4)),hoverinfo='text',name=paste0(network_label[k],"(",plot_names[i],")"))
         }
	 if (i ==  5) {
            sp <- sp %>% add_trace(data=data_in,lat = ~lat, lon=~lon, marker = list(color = ~plotval,colorbar=list(title=paste0(plot_names[i],"<br>",species,"<br>",units)),colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=TRUE,size=20),mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>Value: ",signif(plotval,4)),hoverinfo='text',name=paste0(network_label[k],"(",plot_names[i],")"))
	 }
         sp 	<- sp %>% layout(mapbox = list(style='open-street-map', zoom=4, subplot=subplot_names[i],domain=list(x = c(0, 1), y = c(0, 1)),center=list(lon=lon_mid,lat=lat_mid)),showlegend=TRUE,legend=list(x=0.01,y=0.99))
	 sp 	<- sp %>% layout(title=list(text=title,y=0.98,font=list(size=20)))
	 spTile <- spTile %>% layout(mapbox = list(style='open-street-map', zoom=4, subplot=subplot_names[i],domain=list(x = c(0, 1), y = c(0, 1)),center=list(lon=lon_mid,lat=lat_mid)),showlegend=TRUE,legend=list(x=0.01,y=0.99))
         spTile <- spTile %>% layout(title=list(text=title,y=1,font=list(size=20)))
      }
      else {
         sp 	<- sp %>% add_trace(data=data_in,lat = ~lat, lon=~lon, marker = list(color = 'black',showscale=FALSE,size=22),mode='markers',type='scattermapbox',name=paste0('BG (',plot_names[i],")"))
         sp 	<- sp %>% add_trace(data=data_in,lat = ~lat, lon=~lon, marker = list(color = ~plotval,colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=FALSE,size=20),mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>Value: ",signif(plotval,4)),hoverinfo='text',name=paste0(network_label[k],"(",plot_names[i],")"))
	 spTile <- spTile %>% add_trace(data=data_in,lat = ~lat, lon=~lon, marker = list(color = 'black',showscale=FALSE,size=22),mode='markers',type='scattermapbox',name=paste0('BG (',plot_names[i],")"))
         spTile <- spTile %>% add_trace(data=data_in,lat = ~lat, lon=~lon, marker = list(color = ~plotval,colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=FALSE,size=20),mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>Value: ",signif(plotval,4)),hoverinfo='text',name=paste0(network_label[k],"(",plot_names[i],")"))
      }
      if (i < 4) {
         anim_data_in    <- data.frame(stat_id=sinfo_anim[[k]]$stat_id,lat=sinfo_anim[[k]]$lat,lon=sinfo_anim[[k]]$lon,plotval=sinfo_anim[[k]]$plotval,date=sinfo_anim[[k]]$date)
         anim_data_in$Network <- network_label[k]
         anim_data_in	<- anim_data_in[order(anim_data_in$date),] # Data need to be in order of ascending data for the frame to work properly
         {
         if (k == 1) {
            sp_anim <- plot_ly(data=anim_data_in,lat = ~lat, lon=~lon, marker = list(color = 'black',showscale=FALSE,size=22),frame=~date,mode='markers',type='scattermapbox',name=paste0('BG (',plot_names_anim[i],")"))
	    if (i < 3) {
     	       sp_anim <- sp_anim %>% add_trace(data=anim_data_in,lat = ~lat, lon=~lon,marker = list(color = ~plotval,colorbar=list(title=paste0("Abs<br>",species,"<br>",units)),colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=TRUE,size=20),frame=~date,mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>Value: ",signif(plotval,4)),hoverinfo='text',name=paste0(network_label[k]," (",plot_names_anim[i],")"))
	    }
	    if (i > 2) {
	       sp_anim <- sp_anim %>% add_trace(data=anim_data_in,lat = ~lat, lon=~lon,marker = list(color = ~plotval,colorbar=list(title=paste0("Diff<br>",species,"<br>",units)),colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=TRUE,size=20),frame=~date,mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>Value: ",signif(plotval,4)),hoverinfo='text',name=paste0(network_label[k]," (",plot_names_anim[i],")"))
	    }
            sp_anim <- sp_anim %>% layout(mapbox = list(style='open-street-map', subplot=subplot_names[i],domain=list(x=c(0,1),y=c(0,1)),zoom=4,center=list(lon=lon_mid,lat=lat_mid)),showlegend=TRUE,legend=list(x=0.02,y=0.98)) 
            sp_anim <- sp_anim %>% layout(title=list(text=title,y=0.98,font=list(size=20)))
         }
         else {
            sp_anim <- sp_anim %>% add_trace(data=anim_data_in,lat = ~lat, lon=~lon, marker = list(color = 'black',showscale=FALSE,size=22),frame=~date,mode='markers',type='scattermapbox',name=paste0('BG (',plot_names_anim[i],")"))
            sp_anim <- sp_anim %>% add_trace(data=anim_data_in,lat = ~lat, lon=~lon,marker = list(color = ~plotval,colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=FALSE,size=20),frame=~date,mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>Value: ",signif(plotval,4)),hoverinfo='text',name=paste0(network_label[k]," (",plot_names_anim[i],")"))
         }
         }
	 sp_anim_tile[i] <- sp_anim
      }
   }
   if (i == 1) { 
      spTile 		<- spTile %>% layout(mapbox = list(style='open-street-map', zoom=3.1, subplot="mapbox",domain=list(x = c(0, 1), y = c(0, 1)),center=list(lon=lon_mid,lat=lat_mid)),showlegend=TRUE,legend=list(x=0.01,y=0.99,font=list(size=10)))
      spTile_anim 	<- sp_anim %>% layout(mapbox = list(style='open-street-map', zoom=3.1, subplot="mapbox",domain=list(x = c(0, 1), y = c(0, 1)),center=list(lon=lon_mid,lat=lat_mid)),showlegend=TRUE,legend=list(x=0.01,y=0.99,font=list(size=10))) 
   }
   if (i == 2) { 
      spTile 		<- spTile %>% layout(mapbox2 = list(style='open-street-map', zoom=3.1, subplot="mapbox2",domain=list(x = c(0, 1), y = c(0, 1)),center=list(lon=lon_mid,lat=lat_mid)),showlegend=TRUE) 
      spTile_anim 	<- sp_anim %>% layout(mapbox2 = list(style='open-street-map', zoom=3.1, subplot="mapbox2",domain=list(x = c(0, 1), y = c(0, 1)),center=list(lon=lon_mid,lat=lat_mid)),showlegend=TRUE) 
   }
   if (i == 3) { 
      spTile 		<- spTile %>% layout(mapbox3 = list(style='open-street-map', zoom=3.1, subplot="mapbox3",domain=list(x = c(0, 1), y = c(0, 1)),center=list(lon=lon_mid,lat=lat_mid)),showlegend=TRUE)
      spTile_anim 	<- sp_anim %>% layout(mapbox3 = list(style='open-street-map', zoom=3.1, subplot="mapbox3",domain=list(x = c(0, 1), y = c(0, 1)),center=list(lon=lon_mid,lat=lat_mid)),showlegend=TRUE) 
   }
   if (i == 4) { 
      spTile 		<- spTile %>% layout(mapbox4 = list(style='open-street-map', zoom=3.1, subplot="mapbox4",domain=list(x = c(0, 1), y = c(0, 1)),center=list(lon=lon_mid,lat=lat_mid)),showlegend=TRUE) 
      spTile_anim 	<- sp_anim %>% layout(mapbox4 = list(style='open-street-map', zoom=3.1, subplot="mapbox4",domain=list(x = c(0, 1), y = c(0, 1)),center=list(lon=lon_mid,lat=lat_mid)),showlegend=TRUE)
   }

   spTile <- spTile %>% layout(title=list(text=title,y=0.98,font=list(size=20)))
   spTile_anim <- spTile_anim %>% layout(title=list(text=title,y=0.98,font=list(size=20)))
   sp_tile[i] <- spTile
   sp_anim_tile[i] <- sp_anim
   saveWidget(sp, file=filename_html,selfcontained=T)
   saveWidget(sp_anim, file=filename_anim,selfcontained=T)
}
#######################################
### Create and save multipanel plot ###
#######################################
fig <- subplot(sp_tile[[1]],sp_tile[[2]],sp_tile[[3]],sp_tile[[4]],nrows=2,shareX=F,shareY=F,titleY=F,titleX=F)
fig <- layout(fig,title=list(text=title,y=0.995,font=list(size=20)),annotations=list(list(x=0.445,y=0.532,text="Obs",showarrow=F,xref="paper",yref="paper",font=list(size=25)),list(x=0.98,y=0.532,text="Model",xref="paper",yref="paper",showarrow=F,font=list(size=25)),list(x=0.41,y=0.00,text="Mean(Model-Obs)",xref="paper",yref="paper",showarrow=F,font=list(size=25)),list(x=0.98,y=0.0,text="Max(Model-Obs)",xref="paper",yref="paper",showarrow=F,font=list(size=25))))
saveWidget(fig, file=filename_html_tile,selfcontained=T)
#######################################

#########################################################
### Create and save multipanel plot (not working yet) ###
#########################################################
#fig_anim <- subplot(sp_anim_tile[[1]],sp_anim_tile[[2]],sp_anim_tile[[3]],sp_anim_tile[[4]],nrows=2,shareX=F,shareY=F,titleY=T,titleX=T)
#fig_anim <- layout(fig_anim,annotations=list(list(x=0.43,y=0.6,text="Obs",showarrow=F,xref="paper",yref="paper",font=list(size=25)),list(x=0.95,y=0.6,text="Model",xref="paper",yref="paper",showarrow=F,font=list(size=25)),list(x=0.4,y=0.06,text="Mean(Model-Obs)",xref="paper",yref="paper",showarrow=F,font=list(size=25)),list(x=0.98,y=0.06,text="Max(Model-Obs)",xref="paper",yref="paper",showarrow=F,font=list(size=25))))
#saveWidget(fig_anim, file=filename_html_tile_anim,selfcontained=T)
#######################################

