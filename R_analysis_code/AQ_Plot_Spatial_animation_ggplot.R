header <- "
###################################### SPATIAL PLOT ######################################
### AMET CODE: AQ_Plot_Spatial_animation.R 
###
### This code is part of the AMET-AQ system.  The Plot Spatial code takes a MYSQL database
### query for a single species from one or more networks and plots the observation value, 
### model value, and difference between the model and ob for each site for each corresponding
### network.  Mutiple values for a site are averaged to a single value for static plotting 
### purposes, while the temporal data are retained and used to create an html plot with a
### time slider bar. This script outputs static PDF files and non-static HTML files.
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
if(!require(maps))		{ stop("Required Package maps was not loaded")		}
if(!require(mapdata))		{ stop("Required Package mapdata was not loaded")	}
if(!require(ggplot2))           { stop("Required Package ggplot2 was not loaded") 	}
if(!require(plotly))            { stop("Required Package plotly was not loaded") 	}
if(!require(grid))              { stop("Required Package grid was not loaded") 		}
if(!require(gridExtra))         { stop("Required Package gridExtra was not loaded") 	}

if(!exists("quantile_min")) 	{ quantile_min 	  <- 0.001 }
if(!exists("quantile_max")) 	{ quantile_max 	  <- 0.950 }
if(!exists("near_zero_color")) 	{ near_zero_color <- "grey50" }

## Set some defaults 
network		<- network_names[1] # When using mutiple networks, units from network 1 will be used
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
title <- get_title(run_names,species,network_label,dates,custom_title,site=site,state=state,rpo=rpo,pca=pca,clim_reg=clim_reg)
################################################

## Set file names and titles
filename_obs_png		<- paste(run_name1,species,pid,"spatialplot_obs.png",sep="_")           # Filename for obs spatial plot
filename_mod_png		<- paste(run_name1,species,pid,"spatialplot_mod.png",sep="_")           # Filename for model spatial plot
filename_diff_png		<- paste(run_name1,species,pid,"spatialplot_diff.png",sep="_")          # Filename for diff spatial plot
filename_diff_max_png		<- paste(run_name1,species,pid,"spatialplot_diff_max.png",sep="_")          # Filename for diff spatial plot
filename_diff_abs_max_png	<- paste(run_name1,species,pid,"spatialplot_diff_abs_max.png",sep="_")          # Filename for diff spatial plot

filename_obs_pdf		<- paste(run_name1,species,pid,"spatialplot_obs.pdf",sep="_")           # Filename for obs spatial plot
filename_mod_pdf    		<- paste(run_name1,species,pid,"spatialplot_mod.pdf",sep="_")           # Filename for model spatial plot
filename_diff_pdf   		<- paste(run_name1,species,pid,"spatialplot_diff.pdf",sep="_")          # Filename for diff spatial plot
filename_diff_max_pdf		<- paste(run_name1,species,pid,"spatialplot_diff_max.pdf",sep="_")          # Filename for diff spatial plot
filename_diff_abs_max_pdf	<- paste(run_name1,species,pid,"spatialplot_diff_abs_max.pdf",sep="_")          # Filename for diff spatial plot

filename_obs_html               <- paste(run_name1,species,pid,"spatialplot_obs.html",sep="_")           # Filename for obs spatial plot
filename_mod_html               <- paste(run_name1,species,pid,"spatialplot_mod.html",sep="_")           # Filename for model spatial plot
filename_diff_html              <- paste(run_name1,species,pid,"spatialplot_diff.html",sep="_")          # Filename for diff spatial plot
filename_diff_max_html          <- paste(run_name1,species,pid,"spatialplot_diff_max.html",sep="_")          # Filename for diff spatial plot
filename_diff_abs_max_html      <- paste(run_name1,species,pid,"spatialplot_diff_abs_max.html",sep="_")          # Filename for diff spatial plot
filename_obs_anim    		<- paste(run_name1,species,pid,"spatialplot_anim_obs.html",sep="_")           # Filename for obs spatial plot
filename_mod_anim    		<- paste(run_name1,species,pid,"spatialplot_anim_mod.html",sep="_")           # Filename for model spatial plot
filename_diff_anim   		<- paste(run_name1,species,pid,"spatialplot_anim_diff.html",sep="_")          # Filename for diff spatial plot

filename_tile_pdf       	<- paste(run_name1,species,pid,"spatialplot_tile.pdf",sep="_")
filename_tile_png               <- paste(run_name1,species,pid,"spatialplot_tile.png",sep="_")
filename_tile_html		<- paste(run_name1,species,pid,"spatialplot_tile.html",sep="_")          # Filename for diff spatial plot

## Create a full path to file
filename_obs_png      		<- paste(figdir,filename_obs_png,sep="/")           # Filename for obs spatial plot
filename_mod_png      		<- paste(figdir,filename_mod_png,sep="/")           # Filename for model spatial plot
filename_diff_png     		<- paste(figdir,filename_diff_png,sep="/")          # Filename for diff spatial plot
filename_diff_max_png		<- paste(figdir,filename_diff_max_png,sep="/")          # Filename for diff spatial plot
filename_diff_abs_max_png 	<- paste(figdir,filename_diff_abs_max_png,sep="/")          # Filename for diff spatial plot

filename_obs_pdf      		<- paste(figdir,filename_obs_pdf,sep="/")           # Filename for obs spatial plot
filename_mod_pdf      		<- paste(figdir,filename_mod_pdf,sep="/")           # Filename for model spatial plot
filename_diff_pdf     		<- paste(figdir,filename_diff_pdf,sep="/")          # Filename for diff spatial plot
filename_diff_max_pdf 		<- paste(figdir,filename_diff_max_pdf,sep="/")          # Filename for diff spatial plot
filename_diff_abs_max_pdf	<- paste(figdir,filename_diff_abs_max_pdf,sep="/")          # Filename for diff spatial plot

filename_obs_html      		<- paste(figdir,filename_obs_html,sep="/")           # Filename for obs spatial plot
filename_mod_html 	     	<- paste(figdir,filename_mod_html,sep="/")           # Filename for model spatial plot
filename_diff_html	     	<- paste(figdir,filename_diff_html,sep="/")          # Filename for diff spatial plot
filename_diff_max_html          <- paste(figdir,filename_diff_max_html,sep="/")          # Filename for diff spatial plot
filename_diff_abs_max_html      <- paste(figdir,filename_diff_abs_max_html,sep="/")          # Filename for diff spatial plot

filename_obs_anim      <- paste(figdir,filename_obs_anim,sep="/")           # Filename for obs spatial plot
filename_mod_anim      <- paste(figdir,filename_mod_anim,sep="/")           # Filename for model spatial plot
filename_diff_anim     <- paste(figdir,filename_diff_anim,sep="/")          # Filename for diff spatial plot

filename_tile_pdf      <- paste(figdir,filename_tile_pdf,sep="/")          # Filename for diff spatial plot
filename_tile_png      <- paste(figdir,filename_tile_png,sep="/")          # Filename for diff spatial plot
filename_tile_html     <- paste(figdir,filename_tile_html,sep="/")          # Filename for diff spatial plot

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
sub_title       	<- NULL						# Set sub title to NULL
lev_lab         	<- NULL
legend_names    	<- NULL
legend_chars    	<- NULL
sub_title		<- NULL
tile_out		<- NULL
grid_out		<- NULL
grob_out		<- NULL
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
   { 
      if (data_exists == "n") {
         total_networks <- (total_networks-1)
         network_names <- network_names[-j]
         sub_title<-paste(sub_title,network_label[j],"=No Data; ",sep="")      # Set subtitle based on network matched with the appropriate symbol
         if (total_networks == 0) { stop("Stopping because total_networks is zero. Likely no data found for query.") }
      }
      else {
         ####################################
         ## Compute Averages for Each Site ##
         ####################################
         legend_names <<- c(legend_names,network_label[j])
         legend_chars <<- c(legend_chars,spch[k])
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
         sinfo_obs[[k]]<-list(lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Obs_Value,date=aqdat.df$Start_Date,network=network)
         sinfo_mod[[k]]<-list(lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Value,date=aqdat.df$Start_Date,network=network)
         sinfo_diff[[k]]<-list(lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Obs_Diff,date=aqdat.df$Start_Date,network=network)
         sinfo_diff_max[[k]]<-list(lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Obs_Diff_Max,date=aqdat.df$Start_Date,network=network)
	 sinfo_diff_abs_max[[k]]<-list(lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Obs_Diff_Abs_Max,date=aqdat.df$Start_Date,network=network)
	 sinfo_rat[[k]]<-list(lat=aqdat.df$lat,lon=aqdat.df$lon,plotval=aqdat.df$Mod_Obs_Rat,date=aqdat.df$Start_Date,network=network)

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
      levs <- pretty(c(0,quantile(all_data,quantile_max)),intervals,min.n=5)
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
plot_names <- c("Obs","Model","Avg Diff","Max Diff","Abs Max Diff")
for (i in 1:5) {
   sub_title <- NULL
   if (i == 1) { 
      sinfo 		<- sinfo_obs
      sinfo_anim 	<- sinfo_obs_anim
      plot_range_min 	<- min(levs)
      plot_range_max 	<- max(levs)
      filename_pdf 	<- filename_obs_pdf
      filename_png	<- filename_obs_png
      filename_html	<- filename_obs_html
      filename_anim	<- filename_obs_anim
      color_palette 	<- c("purple","violet","blue","green","yellow","orange","red","dark red")
      color_direction 	<- 1
   }
   if (i == 2) { 
      sinfo 		<- sinfo_mod
      sinfo_anim 	<- sinfo_mod_anim
      plot_range_min 	<- min(levs)
      plot_range_max 	<- max(levs)
      filename_pdf      <- filename_mod_pdf
      filename_png      <- filename_mod_png
      filename_html     <- filename_mod_html
      filename_anim	<- filename_mod_anim
      color_palette 	<- c("purple","violet","blue","green","yellow","orange","red","dark red")
      color_direction 	<- 1
   }
   if (i == 3) {
      sinfo             <- sinfo_diff
      sinfo_anim        <- sinfo_diff_anim
      plot_range_min    <- diff_min
      plot_range_max    <- diff_max
      filename_pdf      <- filename_diff_pdf
      filename_png      <- filename_diff_png
      filename_html	<- filename_diff_html
      filename_anim     <- filename_diff_anim
      color_palette     <- c("purple","violet","blue","green","white","yellow","orange","red","dark red")
      color_direction   <- 1
   }
   if (i == 4) {
      sinfo             <- sinfo_diff_max
      sinfo_anim        <- sinfo_diff_anim
      plot_range_min    <- diff_max_min
      plot_range_max    <- diff_max_max
      filename_pdf      <- filename_diff_max_pdf
      filename_png      <- filename_diff_max_png
      filename_html     <- filename_diff_max_html
      filename_anim     <- filename_diff_anim
      color_palette     <- c("purple","violet","blue","green","white","yellow","orange","red","dark red")
      color_direction   <- 1
   }
   if (i == 5) {
      sinfo             <- sinfo_diff_abs_max
      sinfo_anim        <- sinfo_diff_anim
      plot_range_min    <- diff_abs_max_min
      plot_range_max    <- diff_abs_max_max
      filename_pdf      <- filename_diff_abs_max_pdf
      filename_png      <- filename_diff_abs_max_png
      filename_html	<- filename_diff_abs_max_html
      filename_anim     <- filename_diff_anim
      color_palette     <- c("purple","violet","blue","green","yellow","orange","red","dark red")
      color_direction   <- 1
   }
   for (k in 1:total_networks) {
      library(sf)
      us_state 	<- map_data("state")
      us_county <- map_data("county") 
      canada 	<- map_data("worldHires", "Canada")
      mexico 	<- map_data("worldHires", "Mexico")
      world_map	<- map_data("world")
      world	<- st_as_sf(world_map,coords=c("long","lat"))
      plot_data <- data.frame(lat=sinfo[[k]]$lat,lon=sinfo[[k]]$lon,plotval=sinfo[[k]]$plotval)
      if (k == 1) {
         sub_title <- paste(network_names[k],": ",symbols[k],sep="")
	 network_symbols <- spch[k]
         sp <- ggplot(data=world) + geom_polygon(data=world_map, aes(x=long, y=lat, group=group), color="darkblue", fill="white", linewidth = .1 ) + theme(panel.background=element_rect(fill="dodgerblue",color="dodgerblue"),panel.grid.major=element_line(color="dodgerblue"),panel.grid.minor=element_line(color="dodgerblue")) 
         if (inc_counties == 'y') {
            sp <- sp + geom_polygon(data=us_county, aes(x=long, y=lat, group=group), fill=NA, color="lightblue", linewidth = .075 ) +
	    geom_polygon(data=us_state, aes(x=long, y=lat, group=group), color="darkblue", fill=NA, linewidth = .1 )
         }
	 else {
	    sp <- sp + geom_polygon(data=us_state, aes(x=long, y=lat, group=group), color="darkblue", fill=NA, linewidth = .1 ) 
	 }
	 sp <- sp + coord_fixed(xlim = c(bounds[3], bounds[4]),  ylim = c(bounds[1], bounds[2]), ratio = 1.3, clip="on") +
         geom_point(data = plot_data, shape=spch[k], aes(x=lon, y=lat, col = plotval),size=4) +
         geom_point(data = plot_data, shape=spch2[k] ,size=4,color="black",aes(x=lon,y=lat)) + 
         theme(plot.title=element_text(hjust=0.5,vjust=0.98,size=12),plot.subtitle=element_text(hjust=0.5),axis.text=element_text(size=10), legend.text=element_text(size=12), legend.key.size = unit(1.1,"cm")) 
         sp <- sp + scale_color_gradientn(colors=color_palette,limits=c(plot_range_min,plot_range_max))
      }
      else {
	  sub_title <- paste(sub_title,"; ",network_names[k],": ",symbols[k],sep="")
	  network_symbols <- c(network_symbols,spch[k])
          sp <- sp +
          geom_point(data = plot_data, shape=spch[k], aes(lon, lat, col = plotval),size=4) +
          geom_point(data = plot_data, shape=spch2[k], size=4,color="black",aes(x=lon,y=lat))
      }
      sp <- sp + xlab('Longitude') + ylab('Latitude') + labs(title=title,subtitle=sub_title,color=paste0(species," (",units,")\n",plot_names[i]))
   }
   grob_out[[i]] <- sp
   grid_out[[i]] <- ggplotly(sp,tooltip=c("lat","lon","date","plotval")) %>% layout(title=list(text=paste0(title,'<br>',sub_title),y=0.98),showlegend=T)
   saveWidget(grid_out[[i]], file=filename_html,selfcontained=T)
   ggsave(sp,filename=filename_pdf,width=16,height=9)
   ggsave(sp,filename=filename_png,width=16,height=9)
   if (i < 4) {
      for (k in 1:total_networks) {
         plot_data_anim <- data.frame(stat_id=sinfo_anim[[k]]$stat_id,lat=sinfo_anim[[k]]$lat,lon=sinfo_anim[[k]]$lon,plotval=sinfo_anim[[k]]$plotval,date=sinfo_anim[[k]]$date)
         if (k == 1) {
            sp_anim <- ggplot(data=world) + geom_polygon(data=world_map, aes(x=long, y=lat, group=group), color="darkblue", fill="white", linewidth = .1 ) + theme(panel.background=element_rect(fill="dodgerblue",color="dodgerblue"),panel.grid.major=element_line(color="dodgerblue"),panel.grid.minor=element_line(color="dodgerblue"))
            if (inc_counties == 'y') {
               sp_anim <- sp_anim + geom_polygon(data=us_county, aes(x=long, y=lat, group=group), fill=NA, color="lightblue", linewidth = .075 ) +
               geom_polygon(data=us_state, aes(x=long, y=lat, group=group), color="darkblue", fill=NA, linewidth = .1 )
            }
            else {
               sp_anim <- sp_anim + geom_polygon(data=us_state, aes(x=long, y=lat, group=group), color="darkblue", fill=NA, linewidth = .1 )
            }
            sp_anim <- sp_anim + coord_fixed(xlim = c(bounds[3], bounds[4]),  ylim = c(bounds[1], bounds[2]), ratio = 1.3) +
   	    geom_point(data = plot_data_anim, shape=spch[k], aes(x=lon, y=lat, col = plotval, frame=(date), group=date), size=5) +
            geom_point(data = plot_data_anim, shape=spch2[k] ,size=5,color="black",aes(x=lon,y=lat,frame=(date), group=date)) +
            scale_color_gradientn(colors=color_palette,limits=c(plot_range_min,plot_range_max)) +
            theme(plot.title=element_text(hjust=0.5),plot.subtitle=element_text(hjust=0.5),axis.text=element_text(size=10), legend.text=element_text(size=15), legend.key.size = unit(1.3,"cm")) +
            xlab('Longitude') + ylab('Latitude') + labs(color=paste0(species,"(",units,")\n",plot_names[i]))
         }
         else {
            sp_anim <- sp_anim +
            geom_point(data = plot_data_anim, shape=spch[k], aes(x=lon, y=lat, col = plotval, frame=(date), group=date), size=5) +
            geom_point(data = plot_data_anim, shape=spch2[k] ,size=5,color="black",aes(x=lon,y=lat,frame=(date), group=date))
         }
      }
      fig <- ggplotly(sp_anim,tooltip=c("lat","lon","date","plotval")) %>% animation_opts(transition=0,easing="elastic",redraw=FALSE) %>% layout(title=list(text=paste0(title,'<br>',sub_title),y=0.98)) 
      tile_out[[i]] <- fig
      saveWidget(fig, file=filename_anim,selfcontained=T)
   }
}
plot_out <- arrangeGrob(grob_out[[1]],grob_out[[2]],grob_out[[3]],grob_out[[4]],nrow = 2)
ggsave(file=filename_tile_pdf,plot_out,width=18,height=10)
ggsave(file=filename_tile_png,plot_out,width=18,height=10)
num_rows <- c(2)
fig_out <- subplot(grid_out[[1]],grid_out[[2]],nrows=1,titleY=T,titleX=T,shareY=F)
saveWidget(fig_out, file=filename_tile_html,selfcontained=T)
#########################################   
