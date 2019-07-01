header <- "
############################ INTERACTIVE STATS PLOTS #############################
### AMET CODE: AQ_Stats_Plots_leaflet.R
###
### This code takes a MYSQL database query for a single species from one or more 
### networks and a single simulation and calculates summary statistics for each site
### and the entire domain by network. Interactive spatial plots using the leaflet and
### the htmlwidgets R libraries are produced for select statistics, specifically MB, ME,
### FB, FE, NMB, NME, RMSE and Correlation. Images are output as html files and can be
### self-contained using PANDOC. If PANDOC is unavailable, the selfcontained options at
### the end of this code should be set to false.
###
### Last modified by Wyat Appel; March 2019
##################################################################################
"

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")		        # base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Load Required Libraries 
if(!require(leaflet)){stop("Required Package leaflet was not loaded")}
if(!require(htmlwidgets)){stop("Required Package htmlwidgets was not loaded")}
if(!require(maps)){stop("Required Package maps was not loaded")}
if(!require(mapdata)){stop("Required Package mapdata was not loaded")}

if(!exists("quantile_min")) { quantile_min <- 0.001 }
if(!exists("quantile_max")) { quantile_max <- 0.950 }

################################################
## Set output names and remove existing files ##
################################################
filename_all 	<- paste(run_name1,species,pid,"stats.csv",sep="_")
filename_sites 	<- paste(run_name1,species,pid,"sites_stats.csv",sep="_")
filename_nmb	<- paste(run_name1,species,pid,"stats_plot_NMB.html",sep="_")
filename_nme	<- paste(run_name1,species,pid,"stats_plot_NME.html",sep="_")
filename_fb	<- paste(run_name1,species,pid,"stats_plot_FB.html",sep="_")
filename_fe	<- paste(run_name1,species,pid,"stats_plot_FE.html",sep="_")
filename_rmse	<- paste(run_name1,species,pid,"stats_plot_RMSE.html",sep="_")
filename_mb	<- paste(run_name1,species,pid,"stats_plot_MB.html",sep="_")
filename_me	<- paste(run_name1,species,pid,"stats_plot_ME.html",sep="_")
filename_corr	<- paste(run_name1,species,pid,"stats_plot_Corr.html",sep="_")
filename_txt 	<- paste(run_name1,species,pid,"stats_data.csv",sep="_")      # Set output file name
filename_zip    <- paste(run_name1,species,pid,"stats_plots.zip",sep="_")

## Create a full path to file
filename_all 	<- paste(figdir,filename_all,sep="/")
filename_sites 	<- paste(figdir,filename_sites,sep="/")
filename	<- NULL
filename[1]	<- paste(figdir,filename_nmb,sep="/")
filename[2]	<- paste(figdir,filename_nme,sep="/")
filename[3]	<- paste(figdir,filename_fb,sep="/")
filename[4]	<- paste(figdir,filename_fe,sep="/")
filename[5]	<- paste(figdir,filename_rmse,sep="/")
filename[6]	<- paste(figdir,filename_mb,sep="/")
filename[7]	<- paste(figdir,filename_me,sep="/")
filename[8]	<- paste(figdir,filename_corr,sep="/")
filename_txt 	<- paste(figdir,filename_txt,sep="/")
filename_zip    <- paste(figdir,filename_zip,sep="/")
#################################################

###########################
### Retrieve units label from database table ###
network <- network_names[1]
#units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
#model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
################################################

if (length(num_ints) == 0) {
   num_ints <- 20 
}

sinfo_data <-NULL
all_site   <-NULL
all_lats   <-NULL
all_lons   <-NULL
all_nmb	   <-NULL
all_nme    <-NULL
all_fb     <-NULL
all_fe     <-NULL
all_rmse   <-NULL
all_mb     <-NULL
all_me     <-NULL
all_corr   <-NULL
bounds     <-NULL
available_networks <- NULL

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
remove_negatives <- 'n'      # Set remove negatives to false. Negatives are needed in the coverage calculation and will be removed automatically by Average
k <- 1
for (j in 1:total_networks) {
   total_obs 		<- NULL
   network_number	<- j							# Set network number (used as a flag later in the code)
   network		<- network_names[j]						# Set network name
   #############################################
   ### Read sitex file or query the database ###
   #############################################
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,species)
         data_exists      <- sitex_info$data_exists
         if (data_exists == "y") {
            aqdat_query.df   <- sitex_info$sitex_data
            units            <- as.character(sitex_info$units[[1]])
         }
      }
      else {
         query_result   <- query_dbase(run_name1,network,species)
         aqdat_query.df <- query_result[[1]]
         data_exists	<- query_result[[2]]
         if (data_exists == "y") { units <- query_result[[3]] }
         model_name     <- query_result[[4]]
      }
   }
   ob_col_name <- paste(species,"_ob",sep="")
   mod_col_name <- paste(species,"_mod",sep="")
   #############################################
   if (j == 1) {
      write.table(run_name1,file=filename_txt,append=F,row.names=F,sep=",")                       # Write header for raw data file
      write.table(network,file=filename_txt,append=T,row.names=F,sep=",")
      write.table(aqdat_query.df,file=filename_txt,append=T,row.names=F,sep=",")
   }
   if (j > 1) {
      write.table("",file=filename_txt,append=T,row.names=F,sep=",")
      write.table(network,file=filename_txt,append=T,row.names=F,sep=",")                       # Write header for raw data file
      write.table(aqdat_query.df,file=filename_txt,append=T,row.names=F,sep=",")
   } 
   #######################
   #################################################################
   ### Check to see if there is any data from the database query ###
   #################################################################
   {
      if (data_exists == "n") {
         stats_all.df <- "No stats available.  Perhaps you choose a species for a network that does not observe that species."
         sites_stats.df <- "No site stats available.  Perhaps you choose a species for a network that does not observe that species."
         total_networks <- (total_networks-1)
         if (total_networks == 0) { stop("Stopping because total_neworks is zero. Likely no data found for query.") }
      }
      ##################################################################

      ### If there are data, continue ###
      else {
         available_networks <- c(available_networks,network_label[j])
         aqdat.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=aqdat_query.df[[ob_col_name]],Mod_Value=aqdat_query.df[[mod_col_name]])
         if (use_avg_stats == "y") {
            aqdat.df <- Average(aqdat.df)
         }
   
         ### Create properly formated dataframe to be used with DomainStats function and compute stats for entire domain ###
         data_all.df <- data.frame(network=I(aqdat.df$Network),stat_id=I(aqdat.df$Stat_ID),lat=aqdat.df$lat,lon=aqdat.df$lon,ob_val=aqdat.df$Obs_Value,mod_val=aqdat.df$Mod_Value)
         stats_all.df <-try(DomainStats(data_all.df,rm_negs="T"))	# Compute stats using DomainStats function for entire domain
         ##################################

         ### Write output to comma delimited file ###
         header <- c(paste("Run Name = ",run_name1,sep=""),paste("Evaluation Dates = ",dates,sep=""),paste("Species = ",species,sep=""),paste("State = ",state,sep=""),paste("Site Name = ",site,sep=""))

         ### Compute site stats using SitesStats function ###
         sites_stats.df <- try(SitesStats(data_all.df))
         sinfo_data[[k]] <-list(stat_id=sites_stats.df$Site_ID,lat=sites_stats.df$lat,lon=sites_stats.df$lon,NMB=sites_stats.df$NMB, NME=sites_stats.df$NME, MB=sites_stats.df$MB, ME=sites_stats.df$ME, FB=sites_stats.df$FB, FE=sites_stats.df$FE, RMSE=sites_stats.df$RMSE, CORR=sites_stats.df$COR)
         k <- k+1

         all_nmb	<- c(all_nmb,sites_stats.df$NMB)
         all_nme	<- c(all_nme,sites_stats.df$NME)
         all_mb		<- c(all_mb,sites_stats.df$MB)
         all_me		<- c(all_me,sites_stats.df$ME)
         all_fb		<- c(all_fb,sites_stats.df$FB)
         all_fe		<- c(all_fe,sites_stats.df$FE)
         all_rmse	<- c(all_rmse,sites_stats.df$RMSE)
         all_corr	<- c(all_corr,sites_stats.df$COR)
         all_lats   	<- c(all_lats,sites_stats.df$lat)
         all_lons   	<- c(all_lons,sites_stats.df$lon)
         all_site	<- c(all_site,sites_stats.df$Site_ID)
      }
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


#########################
## plot text options   ##
#########################
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
stat_names      <- c("NMB (%)","NME (%)"," FB (%)", " FE (%)", paste(" RMSE (",units,")",sep=""), paste(" MB (",units,")",sep=""), paste(" ME (",units,")",sep=""), "Correlation")
units_all       <- c("%","%","%","%",units,units,units,"none")
#########################

mapStates <- map("state",fill=T,plot=F)

plot_data_all	<- c("all_nmb","all_nme","all_fb","all_fe","all_rmse","all_mb","all_me","all_corr")

for (i in 1:8) {
  plot_data <- get(plot_data_all[i])
  plot_title <- paste(species,stat_names[i],"<br>",run_name1,"<br>", dates,sep=" ")
  if (custom_title != "") { plot_title <- custom_title }
  my.colors <- colorRampPalette(c(grey(.8),"mediumpurple","darkorchid4", "#002FFF", "green", "yellow", "orange", "red", "brown"))
  data.df <- data.frame(site.id=all_site,latitude=all_lats,longitude=all_lons,data.obs=plot_data)
  data.seq <- pretty(seq(min(quantile(plot_data,probs=quantile_min,na.rm=T)),max(quantile(plot_data,probs=quantile_max,na.rm=T),na.rm=T)),n=20)
  {
     if ((plot_data_all[i] == "all_nmb") || (plot_data_all[i] == "all_fb")) {
        range_max <- max(quantile(abs(plot_data),probs=quantile_max,na.rm=T))
        data.seq <- pretty(c(-range_max,range_max),n=num_ints)
        if ((length(perc_range_min) != 0) || (length(perc_range_max) != 0)) {
           data.seq <- pretty(seq(perc_range_min,perc_range_max,na.rm=T),n=num_ints)
        }
        my.colors <- colorRampPalette(c("darkorchid4","purple", "#002FFF", "deepskyblue", "lightblue", "palegoldenrod", "yellow", "orange", "red", "brown"))
     }
     if ((plot_data_all[i] == "all_nme") || (plot_data_all[i] == "all_fe")) {
        if (length(perc_error_max) != 0) {
           data.seq <- pretty(seq(0,perc_error_max,na.rm=T),n=num_ints)
        }
     }
     if (plot_data_all[i] == "all_mb") {
        range_max <- max(quantile(abs(plot_data),probs=quantile_max,na.rm=T))
        data.seq <- pretty(c(-range_max,range_max),n=num_ints)
        if ((length(abs_range_min) != 0) || (length(abs_range_max) != 0)) {
           data.seq <- pretty(seq(abs_range_min,abs_range_max,na.rm=T),n=num_ints)
        }
        my.colors <- colorRampPalette(c("darkorchid4","purple", "#002FFF", "deepskyblue", "lightblue", "palegoldenrod", "yellow", "orange", "red", "brown"))
     }
     if (plot_data_all[i] == "all_rmse") {
        if (length(rmse_range_max) != 0) {
           data.seq <- pretty(seq(0,rmse_range_max,na.rm=T),n=num_ints)
        }
     }
     if (plot_data_all[i] == "all_me") {
        if (length(abs_error_max) != 0) {
           data.seq <- pretty(seq(0,abs_error_max,na.rm=T),n=num_ints)
        }
     }
     if (plot_data_all[i] == "all_corr") {
        data.seq <- pretty(seq(0,1),n=num_ints)
     }
  }
  min.data <- min(data.seq)
  max.data <- max(data.seq)

  n.bins <- length(data.seq)
  binpal2 <- colorBin(my.colors(10), c(min.data,max.data), n.bins-1 , pretty = FALSE)

  leaflet_map <- c("OpenStreetMap.Mapnik","OpenStreetMap.BlackAndWhite","OpenTopoMap","Esri.WorldImagery","Esri.WorldStreetMap")
  my.leaf <- leaflet(data=mapStates) %>% addProviderTiles(leaflet_map[1],group="Street Map")  %>%
                                       addProviderTiles(leaflet_map[2],group="B&W Street Map")  %>%
                                       addProviderTiles(leaflet_map[3],group="Topo Map") %>%
                                       addProviderTiles(leaflet_map[4],group="ESRI World Imagery") %>%
                                       addProviderTiles(leaflet_map[5],group="ESRI Street Map")

  for (j in 1:length(available_networks)) {
    if(i == 1) {
        plot_val <- sinfo_data[[j]]$NMB
        name <- "NMB"
        val_units <- "%"
     }
     if(i == 2) {
        plot_val <- sinfo_data[[j]]$NME
        name <- "NME"
        val_units <- "%"
     }
     if(i == 3) {
        plot_val <- sinfo_data[[j]]$FB
        name <- "FB"
        val_units <- "%"
     }
     if(i == 4) {
        plot_val <- sinfo_data[[j]]$FE
        name <- "FE"
        val_units <- "%"
     }
     if(i == 5) {
        plot_val <- sinfo_data[[j]]$RMSE
        name <- "RMSE"
        val_units <- units
     }
     if(i == 6) {
        plot_val <- sinfo_data[[j]]$MB
        name <- "MB"
        val_units <- units
     }    
     if(i == 7) {
        plot_val <- sinfo_data[[j]]$ME
        name <- "ME"
        val_units <- units
     }
     if(i == 8) {
        plot_val <- sinfo_data[[j]]$COR
        name <- "Correlation"
        val_units <- "none"
     }
    data.df <- data.frame(site.id=sinfo_data[[j]]$stat_id,latitude=sinfo_data[[j]]$lat,longitude=sinfo_data[[j]]$lon,data.obs=plot_val)
    contents <- paste("Site: ", sinfo_data[[j]]$stat_id,
                  "<br/>",
                  "NMB: ", round(sinfo_data[[j]]$NMB, 2),"%",
                  "<br/>",
                  "NME: ", round(sinfo_data[[j]]$NME, 2),"%",
                  "<br/>",
                  "FB:", round(sinfo_data[[j]]$FB, 2),"%",
                  "<br/>",
                  "FE: ", round(sinfo_data[[j]]$FE, 2),"%",
                  "<br/>",
                  "MB:", round(sinfo_data[[j]]$MB, 2),units,
                  "<br/>",
                  "ME: ", round(sinfo_data[[j]]$ME, 2),units,
                  "<br/>",
                  "RMSE: ", round(sinfo_data[[j]]$RMSE, 2),units,
                  "<br/>",
                  "Correlation:", round(sinfo_data[[j]]$COR, 2), sep=" ")

    contents2 <- paste("Site: ", sinfo_data[[j]]$stat_id,"   ",name,": ", round(plot_val, 2), val_units, sep=" ")

      my.leaf <- my.leaf %>% addCircleMarkers(sinfo_data[[j]]$lon,sinfo_data[[j]]$lat,color=~binpal2(plot_val),group=available_networks[[j]],radius=5,data=data.df,opacity=1,fillOpacity=1,popup=contents,label=contents2)
    }

  my.leaf <- my.leaf %>% addLegend("bottomright", pal = binpal2, values = c(min.data,max.data), title = plot_title, opacity = 2) %>%
  addLayersControl(
          baseGroups = c("Street Map","B&W Street Map","Topo Map","ESRI World Imagery","ESRI Street Map"),
          overlayGroups = c(available_networks),
          options =  layersControlOptions(collapsed = FALSE,position="topleft")
  )
  saveWidget(my.leaf, file=filename[i],selfcontained=T)	# Use if PANDOC is available
#  saveWidget(my.leaf, file=filename[i],selfcontained=F) # Use if PANDOC is not available
}

zip_files <- paste(run_name1,species,pid,"*",sep="_")
zip_command<-paste("zip",filename_zip,zip_files,sep=" ")
system(zip_command)
