header <- "
################################# STATS #####################################
### AMET CODE: AQ_Stats.R
###
### This code produces a simple table (csv file) of summary stats. This code works
### with multiple networks and species. The output from the script is a CSV file
### containing numberous summary statistics for the requested species. Species that
### are not available are ignored.
###
### Last modified by Wyat Appel, June 2019
##############################################################################
"

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")		        # base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Load Required Libraries 
#if(!require(maps)){stop("Required Package maps was not loaded")}
#if(!require(mapdata)){stop("Required Package mapdata was not loaded")}

################################################
## Set output names and remove existing files ##
################################################
filename_zip    <- paste(run_name1,pid,"stats.zip",sep="_")

## Create a full path to file
filename_zip    <- paste(figdir,filename_zip,sep="/")
#################################################

### Retrieve units label from database table ###
network <- network_names[1]
species_in <- species
#units_qs <- paste("SELECT ",species_in[1]," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
#model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
################################################

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

n <- 1
total_networks <- length(network_names)
total_species <- length(species_in)
k <- 1
for (k in 1:total_networks) {
   network <- network_names[k]
   ################################################
   ## Set output names and remove existing files ##
   ################################################
   filename_all    <- paste(run_name1,network,pid,"stats.csv",sep="_")
   filename_sites  <- paste(run_name1,network,pid,"sites_stats.csv",sep="_")
   filename_txt    <- paste(run_name1,network,pid,"stats_data.csv",sep="_")      # Set output file name

   ## Create a full path to file
   filename_all    <- paste(figdir,filename_all,sep="/")
   filename_sites  <- paste(figdir,filename_sites,sep="/")
   filename_txt    <- paste(figdir,filename_txt,sep="/")
   #################################################

   for (j in 1:total_species) {
      total_obs 		<- NULL
      species_number	<- j							# Set network number (used as a flag later in the code)
      species		<- species_in[j]						# Set network name
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
            data_exists	   <- query_result[[2]]
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
            total_species <- (total_species-1)
         }
         ##################################################################

         ### If there are data, continue ###
         else {
            aqdat.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=aqdat_query.df[[ob_col_name]],Mod_Value=aqdat_query.df[[mod_col_name]],State=aqdat_query.df$state)
            if (use_avg_stats == "y") {
               aqdat.df <- Average(aqdat.df)
            }
   
            ### Create properly formated dataframe to be used with DomainStats function and compute stats for entire domain ###
            data_all.df <- data.frame(network=I(aqdat.df$Network),stat_id=I(aqdat.df$Stat_ID),lat=aqdat.df$lat,lon=aqdat.df$lon,ob_val=aqdat.df$Obs_Value,mod_val=aqdat.df$Mod_Value)
            stats_all.df <-try(DomainStats(data_all.df))	# Compute stats using DomainStats function for entire domain
            ##################################

            ### Write output to comma delimited file ###
            header <- c(paste("Run Name = ",run_name1,sep=""),paste("Evaluation Dates = ",dates,sep=""),paste("State = ",state,sep=""),paste("Site Name = ",site,sep=""))

            ### Compute site stats using SitesStats function ###
            sites_stats.df <- try(SitesStats(data_all.df))

            sinfo_data[[k]]<-list(lat=sites_stats.df$lat,lon=sites_stats.df$lon,NMB=sites_stats.df$NMB,NME=sites_stats.df$NME,MB=sites_stats.df$MB,ME=sites_stats.df$ME,FB=sites_stats.df$FB,FE=sites_stats.df$FE,RMSE=sites_stats.df$RMSE,COR=sites_stats.df$COR)
            k <- k+1
  
            all_nmb	<- c(all_nmb,sites_stats.df$NMB)
            all_nme	<- c(all_nme,sites_stats.df$NME)
            all_mb	<- c(all_mb,sites_stats.df$MB)
            all_me	<- c(all_me,sites_stats.df$ME)
            all_fb	<- c(all_fb,sites_stats.df$FB)
            all_fe	<- c(all_fe,sites_stats.df$FE)
            all_rmse	<- c(all_rmse,sites_stats.df$RMSE)
            all_corr	<- c(all_corr,sites_stats.df$COR)
            all_lat   	<- c(all_lat,sites_stats.df$lat)
            all_lon   	<- c(all_lon,sites_stats.df$lon)
         }
      }
      ##########################################
      ## Write output to comma delimited file ##
      ##########################################
      header <- c(paste("Run Name = ",run_name1,sep=""),paste("Evaluation Dates = ",dates,sep=""),paste("RPO = ",rpo,sep=""),paste("State = ",state,sep=""),paste("Site Name = ",site,sep=""))     # Set header information

      if (species_number==1) {                                                                                        # Determine if this is the first network
         write.table(header, file=filename_all, append=F, sep="," ,col.names=F, row.names=F)                   # Create domain stats file if first network
         write.table(header, file=filename_sites, append=F, sep="," ,col.names=F, row.names=F)                 # Create site stats file if first network
      }
      write.table("",file=filename_all,append=T,sep=",",col.names=F,row.names=F)                                    # Add blank line between networks (domain stats)
      write.table("",file=filename_sites,append=T,sep=",",col.names=F,row.names=F)                                  # Add blank line between networks (sites stats)

      write.table(species, file=filename_all, append=T ,sep=",",col.names=F,row.names=F)                            # Write network name (domain stats)
      write.table(species, file=filename_sites, append=T ,sep=",",col.names=F,row.names=F)                          # Write network name (sites stats)

      write.table(stats_all.df, file=filename_all, append=T, sep=",",col.names=T,row.names=F)           # Write domain stats
      write.table(sites_stats.df, file=filename_sites, append=T, sep=",",col.names=T,row.names=F)                   # Write sites stats

      ###########################################
   }	# End species data query loop
}
zip_files <- paste(run_name1,"*",pid,"*",sep="_")
zip_command<-paste("zip",filename_zip,zip_files,sep=" ")
system(zip_command)

