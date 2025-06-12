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
### Last modified by Wyat Appel: Feb 2022
##################################################################################
"

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")		        # base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Load Required Libraries 
if(!require(webshot))		{ stop("Required Package webshot was not loaded")	 }
if(!require(lattice))           { stop("Required Package lattice was not loaded") 	 }
if(!require(latticeExtra))      { stop("Required Package latticeExtra was not loaded") 	 }
if(!require(leafpop))         	{ stop("Required Package leafpop was not loaded") 	 }
if(!require(leaflet.extras))    { stop("Required Package leaflet.extras was not loaded") }

if(!exists("quantile_min")) { quantile_min <- 0.001 }
if(!exists("quantile_max")) { quantile_max <- 0.950 }
if(!exists("png_from_html")) { png_from_html <- "n" }

## Set some defaults
network 	 <- network_names[1]
n 		 <- 1
total_networks 	 <- length(network_names)
remove_negatives <- 'n'      # Set remove negatives to false. Negatives are needed in the coverage calculation and will be removed automatically by Average
k 		 <- 1
if (length(num_ints) == 0) { num_ints <- 20 }

## Set output filenames 
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
filename_zip    <- paste(run_name1,species,pid,"stats_plots.zip",sep="_")

## Create a full path to output files
filename_all 	<- paste(figdir,filename_all,sep="/")
filename_sites 	<- paste(figdir,filename_sites,sep="/")
filename	<- NULL
filename_png	<- NULL
filename[1]	<- paste(figdir,"/",filename_nmb,".html",sep="")
filename[2]	<- paste(figdir,"/",filename_nme,".html",sep="")
filename[3]	<- paste(figdir,"/",filename_fb,".html",sep="")
filename[4]	<- paste(figdir,"/",filename_fe,".html",sep="")
filename[5]	<- paste(figdir,"/",filename_rmse,".html",sep="")
filename[6]	<- paste(figdir,"/",filename_mb,".html",sep="")
filename[7]	<- paste(figdir,"/",filename_me,".html",sep="")
filename[8]	<- paste(figdir,"/",filename_corr,".html",sep="")
filename_png[1] <- paste(figdir,"/",filename_nmb,".png",sep="")
filename_png[2] <- paste(figdir,"/",filename_nme,".png",sep="")
filename_png[3] <- paste(figdir,"/",filename_fb,".png",sep="")
filename_png[4] <- paste(figdir,"/",filename_fe,".png",sep="")
filename_png[5] <- paste(figdir,"/",filename_rmse,".png",sep="")
filename_png[6] <- paste(figdir,"/",filename_mb,".png",sep="")
filename_png[7] <- paste(figdir,"/",filename_me,".png",sep="")
filename_png[8] <- paste(figdir,"/",filename_corr,".png",sep="")
filename_txt 	<- paste(figdir,filename_txt,sep="/")
filename_zip    <- paste(figdir,filename_zip,sep="/")
#################################################

###################################
### Set variable initial values ###
###################################
sinfo_data 		<- NULL
all_site   		<- NULL
all_lats   		<- NULL
all_lons   		<- NULL
all_nmb	   		<- NULL
all_nme    		<- NULL
all_fb     		<- NULL
all_fe     		<- NULL
all_rmse   		<- NULL
all_mb     		<- NULL
all_me     		<- NULL
all_corr   		<- NULL
bounds     		<- NULL
available_networks 	<- NULL
aqdat_out.df 		<- NULL
###################################

### Set plot characters ###
plot.symbols	<- as.integer(plot_symbols)
pick.symbol.name.fun <- function(x){
   master.symbol.df <- data.frame(plot.symbols=c(16,17,15,18,8,11,4),names=c("CIRCLE","TRIANGLE","SQUARE","DIAMOND","BURST","STAR","X"))
   as.character(master.symbol.df$names[x==master.symbol.df$plot.symbols])
}
pick.symbol2.fun <- function(x){
   master.symbol2.df <- data.frame(plot.symbols=c(16,17,15,18,8,11,4),plot.symbols2=c(1,2,0,5,8,11,4))
   as.integer(master.symbol2.df$plot.symbols2[x==master.symbol2.df$plot.symbols])
}
symbols	<- apply(matrix(plot.symbols),1,pick.symbol.name.fun)
spch2 	<- apply(matrix(plot.symbols),1,pick.symbol2.fun)
spch	<- plot.symbols
################################################

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
	 aqdat_query.df$stat_id_noPOC <- aqdat_query.df$stat_id
         aqdat_query.df$stat_id       <- paste(aqdat_query.df$stat_id,aqdat_query.df$POCode,sep="")
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
         aqdat_in.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),Stat_ID_NoPOC=I(aqdat_query.df$stat_id_noPOC),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=aqdat_query.df[[ob_col_name]],Mod_Value=aqdat_query.df[[mod_col_name]],Start_Date=aqdat_query.df$ob_dates)
         if (use_avg_stats == "y") {
            aqdat_in.df <- Average(aqdat_in.df)
         }
         aqdat_out.df <- rbind(aqdat_out.df,aqdat_in.df)  
         ### Create properly formated dataframe to be used with DomainStats function and compute stats for entire domain ###
         data_all.df <- data.frame(network=I(aqdat_in.df$Network),stat_id=I(aqdat_in.df$Stat_ID),stat_id_noPOC=I(aqdat_in.df$Stat_ID_NoPOC),lat=aqdat_in.df$lat,lon=aqdat_in.df$lon,ob_val=aqdat_in.df$Obs_Value,mod_val=aqdat_in.df$Mod_Value)
         stats_all.df <-try(DomainStats(data_all.df,rm_negs="T"))	# Compute stats using DomainStats function for entire domain
         ##################################

         ### Write output to comma delimited file ###
         header <- c(paste("Run Name = ",run_name1,sep=""),paste("Evaluation Dates = ",dates,sep=""),paste("Species = ",species,sep=""),paste("State = ",state,sep=""),paste("Site Name = ",site,sep=""))

         ### Compute site stats using SitesStats function ###
         sites_stats_all.df <- try(SitesStats(data_all.df))
         sites_stats.df <- subset(sites_stats_all.df, Coverage >= coverage_limit & Num_Obs >= num_obs_limit)
	 sinfo_data[[k]] <-list(network=network,stat_id=sites_stats.df$Site_ID,lat=sites_stats.df$lat,lon=sites_stats.df$lon,NMB=sites_stats.df$NMB, NME=sites_stats.df$NME, MB=sites_stats.df$MB, ME=sites_stats.df$ME, FB=sites_stats.df$FB, FE=sites_stats.df$FE, RMSE=sites_stats.df$RMSE, CORR=sites_stats.df$COR)
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
   write.table(sites_stats_all.df, file=filename_sites, append=T, sep=",",col.names=T,row.names=F)                   # Write sites stats

   ###########################################
}	# End network data query loop


#########################
## plot text options   ##
#########################
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
stat_names      <- c("NMB (%)","NME (%)"," FB (%)", " FE (%)", paste(" RMSE (",units,")",sep=""), paste(" MB (",units,")",sep=""), paste(" ME (",units,")",sep=""), "Correlation")
units_all       <- c("%","%","%","%",units,units,units,"none")
#########################

plot_data_all	<- c("all_nmb","all_nme","all_fb","all_fe","all_rmse","all_mb","all_me","all_corr")

run_name_elements <-unlist(strsplit(run_name1,"_"))
run_name_title <- run_name_elements[1]
for (l in 2:length(run_name_elements)) { run_name_title <- paste(run_name_title,run_name_elements[l],sep="<br>") }
for (i in 1:8) {
  plot_data <- get(plot_data_all[i])
  plot_title <- stat_names[i]
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
#        my.colors <- colorRampPalette(c("darkorchid4","purple", "#002FFF", "deepskyblue", "lightblue", "palegoldenrod", "yellow", "orange", "red", "brown"))
        min.data <- min(data.seq)
        max.data <- max(data.seq)
        n.bins <- length(data.seq)
	colors_cool_n <- abs(min.data)
        colors_warm_n <- abs(max.data)
        if ((abs(min.data) < 5) || (abs(max.data) < 5)) {
           colors_cool_n <- 10*(abs(min.data))
           colors_warm_n <- 10*(abs(max.data))
        }
        colors_cool <- colorRampPalette(colors=c("darkorchid4","purple", "#002FFF", "deepskyblue", "lightblue","grey80"))(colors_cool_n)
        colors_warm <- colorRampPalette(colors=c("gray80","palegoldenrod", "yellow", "orange", "red", "brown"))(colors_warm_n)
        my.colors <- c(colors_cool,colors_warm)
        binpal2 <- colorBin(palette=my.colors, c(min.data,max.data), n.bins-1 , pretty = FALSE)
     }
     if ((plot_data_all[i] == "all_nme") || (plot_data_all[i] == "all_fe")) {
        if (length(perc_error_max) != 0) {
           data.seq <- pretty(seq(0,perc_error_max,na.rm=T),n=num_ints)
        }
        min.data <- min(data.seq)
        max.data <- max(data.seq)
        n.bins <- length(data.seq)
	binpal2 <- colorBin(my.colors(10), c(min.data,max.data), n.bins-1 , pretty = FALSE)
     }
     if (plot_data_all[i] == "all_mb") {
        range_max <- max(quantile(abs(plot_data),probs=quantile_max,na.rm=T))
        data.seq <- pretty(c(-range_max,range_max),n=num_ints)
        if ((length(diff_range_min) != 0) || (length(diff_range_max) != 0)) {
#           data.seq <- pretty(seq(diff_range_min,diff_range_max,na.rm=T),n=num_ints) 
            data.seq <- pretty(c(diff_range_min,diff_range_max),n=num_ints) # Changed from the line above to this, as having the seq made ranges less than 1 came out asymetrical. Not sure why.
        }
        my.colors <- colorRampPalette(c("darkorchid4","purple", "#002FFF", "deepskyblue", "lightblue", "palegoldenrod", "yellow", "orange", "red", "brown"))
        min.data <- min(data.seq)
        max.data <- max(data.seq)
        n.bins <- length(data.seq)
        colors_cool_n <- abs(min.data)
        colors_warm_n <- abs(max.data)
        if ((abs(min.data) < 5) || (abs(max.data) < 5)) {
           colors_cool_n <- 10*(abs(min.data))
           colors_warm_n <- 10*(abs(max.data))
        }
        colors_cool <- colorRampPalette(colors=c("darkorchid4","purple", "#002FFF", "deepskyblue", "lightblue","white"))(colors_cool_n)
        colors_warm <- colorRampPalette(colors=c("white","palegoldenrod", "yellow", "orange", "red", "brown"))(colors_warm_n)
        my.colors <- c(colors_cool,colors_warm)
        binpal2 <- colorBin(palette=my.colors, c(min.data,max.data), n.bins-1 , pretty = FALSE)
     }
     if (plot_data_all[i] == "all_rmse") {
        if (length(rmse_range_max) != 0) {
           data.seq <- pretty(seq(0,rmse_range_max,na.rm=T),n=num_ints)
        }
        min.data <- min(data.seq)
        max.data <- max(data.seq)
        n.bins <- length(data.seq)
        binpal2 <- colorBin(my.colors(10), c(min.data,max.data), n.bins-1 , pretty = FALSE)
     }
     if (plot_data_all[i] == "all_me") {
        if (length(abs_error_max) != 0) {
           data.seq <- pretty(seq(0,abs_error_max,na.rm=T),n=num_ints)
        }
        min.data <- min(data.seq)
        max.data <- max(data.seq)
        n.bins <- length(data.seq)
        binpal2 <- colorBin(my.colors(10), c(min.data,max.data), n.bins-1 , pretty = FALSE)
     }
     if (plot_data_all[i] == "all_corr") {
        data.seq <- pretty(seq(0,1),n=num_ints)
        min.data <- min(data.seq)
        max.data <- max(data.seq)
        n.bins <- length(data.seq)
        binpal2 <- colorBin(my.colors(10), c(min.data,max.data), n.bins-1 , pretty = FALSE)
     }
  }
#  min.data <- min(data.seq)
#  max.data <- max(data.seq)

#  n.bins <- length(data.seq)
#  binpal2 <- colorBin(my.colors(10), c(min.data,max.data), n.bins-1 , pretty = FALSE)

  my.leaf <- my.leaf.base
  for (j in 1:length(available_networks)) {
    if(i == 1) {
        plot_val <- sinfo_data[[j]]$NMB
        name <- "NMB"
        val_units <- "%"
        ecdf_data <- all_nmb
     }
     if(i == 2) {
        plot_val <- sinfo_data[[j]]$NME
        name <- "NME"
        val_units <- "%"
        ecdf_data <- all_nme
     }
     if(i == 3) {
        plot_val <- sinfo_data[[j]]$FB
        name <- "FB"
        val_units <- "%"
        ecdf_data <- all_fb
     }
     if(i == 4) {
        plot_val <- sinfo_data[[j]]$FE
        name <- "FE"
        val_units <- "%"
        ecdf_data <- all_fe
     }
     if(i == 5) {
        plot_val <- sinfo_data[[j]]$RMSE
        name <- "RMSE"
        val_units <- units
        ecdf_data <- all_rmse
     }
     if(i == 6) {
        plot_val <- sinfo_data[[j]]$MB
        name <- "MB"
        val_units <- units
        ecdf_data <- all_mb
     }    
     if(i == 7) {
        plot_val <- sinfo_data[[j]]$ME
        name <- "ME"
        val_units <- units
        ecdf_data <- all_me
     }
     if(i == 8) {
        plot_val <- sinfo_data[[j]]$COR
        name <- "Correlation"
        val_units <- "none"
        ecdf_data <- all_corr
     }
#    tag.map.title.png <- tag_map_title_png_func(30)
    main_title <- tags$div(tag.map.title.html, HTML(paste(run_name1,species,name,dates,sep=" ")))
    main_title_png <- tags$div(tag.map.title.png, HTML(paste(run_name1,species,name,dates,sep=" ")))
    data.df <- data.frame(network=sinfo_data[[j]]$network,site.id=sinfo_data[[j]]$stat_id,latitude=sinfo_data[[j]]$lat,longitude=sinfo_data[[j]]$lon,data.obs=plot_val)
    contents <- paste("Network: ",sinfo_data[[j]]$network,
                  "<br/>",
                  "Site: ", sinfo_data[[j]]$stat_id,
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

    contents2 <- paste("Network: ",sinfo_data[[j]]$network,"; Site: ", sinfo_data[[j]]$stat_id,"; ",name,": ", round(plot_val, 2), val_units, sep=" ")
    aqdat_out.df$Date_Hour <- (paste(aqdat_out.df$Start_Date," ",aqdat_out.df$Hour,":00:00",sep=""))
    stations <- unique(data.df$site.id)    
    if ((i == 1) && (length(stations) <= 100) && (popup_ts == 'y')) {
       plist <- lapply(stations,
                         function(m) {
			    obj1 <-	 
                            xyplot((Mod_Value-Obs_Value) ~ as.POSIXct(Date_Hour), data = aqdat_out.df,
#				    xyplot(Obs_Value + Mod_Value + (Mod_Value-Obs_Value) ~ as.POSIXct(Date_Hour), data = aqdat_in.df,
  				    subset = (Stat_ID == m),
                                    superpose=T,
                                    col=c("black"),
                                    lwd=2,
                                    scales=list(tck=c(1,1),x=list(cex=1.2),y=list(cex=1.2)),
                                    lty=c(1),
                                    key=list(cex.title=2,
                                       text = list(c("MB"),cex=1.5),
                                       lines = list(lwd=2, lty=c(1), col=c("black"))
                                    ),
                                    type = c("l","g"),
                                    xlab = list(label='Date',cex=1.5),
                                    ylab = list(label=paste(species," (",units,")",sep=""),cex=1.5)
                             )
			     obj2 <- xyplot(((Mod_Value-Obs_Value)/(Mod_Value+Obs_Value)) ~ as.POSIXct(Date_Hour), data = aqdat_out.df,
                                    subset = (Stat_ID == m),
                                    superpose=T,
                                    col=c("red"),
                                    lwd=2,
                                    scales=list(tck=c(1,1),x=list(cex=1.2),y=list(cex=1.2)),
                                    lty=c(1),
                                    key=list(cex.title=2,
                                       text = list(c("MB","NMB","ME"),cex=1.5),
                                       lines = list(lwd=2, lty=c(1), col=c("red"))
                                    ),
                                    type = c("l","g"),
                                    xlab = list(label='Date',cex=1.5),
                                    ylab = list(label=paste(species," (",units,")",sep=""),cex=1.5)
                             )
			     doubleYScale(obj1,obj2,add.ylab2 = TRUE, use.style=FALSE)
			 }
                       )
    } 
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
    if ((length(stations) <= 100) && (popup_ts == 'y')) {
       my.leaf <- my.leaf %>% addCircleMarkers(sinfo_data[[j]]$lon,sinfo_data[[j]]$lat,color="black",fillColor=~binpal2(plot_val),group=available_networks[[j]],radius=plot_rad*symbsizfac,data=data.df,opacity=1,fillOpacity=fill_opacity,stroke=TRUE,weight=1,popup=popupGraph(plist,width=1000,height=1000),label=contents2, labelOptions = labelOptions(noHide = F, textsize = "15px"))
    }
    else {
       my.leaf <- my.leaf %>% addCircleMarkers(sinfo_data[[j]]$lon,sinfo_data[[j]]$lat,color="black",fillColor=~binpal2(plot_val),group=available_networks[[j]],radius=plot_rad*symbsizfac,stroke=TRUE,weight=1,data=data.df,opacity=1,fillOpacity=fill_opacity,popup=contents,label=contents2, labelOptions = labelOptions(noHide = F, textsize = "15px"))
    }
    }

  my.leaf <- my.leaf %>% addLegend("bottomright", pal = binpal2, values = c(min.data,max.data), title = plot_title, opacity = 2) 
  my.leaf2 <- my.leaf %>% addProviderTiles(leaflet_map[1],group="Street Map") %>% setView(center_lon,center_lat,zoom=zoom_level)
  my.leaf <- my.leaf %>% addControl(main_title,position="topright",className="map-title")
  my.leaf2 <- my.leaf2 %>% addControl(main_title_png,position="topright",className="map-title")
  my.leaf <- my.leaf %>%
  addLayersControl(baseGroups = base_Groups,overlayGroups = c(available_networks),options =  layersControlOptions(collapsed = FALSE,position="topleft"))
  saveWidget(my.leaf, file=filename[i],selfcontained=T)	# Use if PANDOC is available
  saveWidget(my.leaf2, file="Rplot.html",selfcontained=T)
  if (png_from_html == "y") {
     webshot("Rplot.html", file = filename_png[i],cliprect = "viewport",zoom=2,vwidth=max(lon_diff*24.5,1600),vheight=max(lat_diff*36.5,800))
  }
}
zip_files <- paste(run_name1,species,pid,"*.html",sep="_")
zip_command<-paste("zip",filename_zip,zip_files,sep=" ")
system(zip_command)
