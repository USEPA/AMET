##---------------------------------------------------------------
#	Surface Station Update Script 				#
#								#
#	Purpose: To update the surface station			#
#		 database information (id,lat,lon,elev,etc)	#
#								#
#       Last Update: 01/2022 by K. Wyat Appel			#
#----------------------------------------------------------------

obs_data_dir           <- Sys.getenv('AMET_OBS')
if (!exists("obs_data_dir")) {
   stop("Must set AMET_OBS environment variable")
}

dbase <-Sys.getenv('AMET_DATABASE')
if (!exists("dbase")) {
   stop("Must set AMET_DATABASE environment variable")
}

config_file     <- Sys.getenv("MYSQL_CONFIG")   # MySQL configuration file
if (!exists("config_file")) {
   stop("Must set MYSQL_CONFIG environment variable")
}
source(config_file)

# LOAD Required R Modules
suppressMessages(if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")})
require(stringr)

## Get a couple of environment variables
obs_data_dir   <- Sys.getenv('AMET_OBS')
site_meta_data <- Sys.getenv('SITES_META_LIST')

source(site_meta_data)

args              <- commandArgs(2)
mysql_login       <- args[1]
mysql_pass        <- args[2]

### Use MySQL login/password from config file if requested ###
if (mysql_login == 'config_file') { mysql_login <- amet_login }
if (mysql_pass == 'config_file')  { mysql_pass  <- amet_pass  }
##############################################################

con   <- dbConnect(MySQL(),user=mysql_login,password=mysql_pass,dbname=dbase,host=mysql_server)
if (!exists("con")) {
   stop("Your MySQL server was not found or login or passwords incorrect, please check to see if server is running or passwords are correct.")
}

for (j in 1:length(site_file)) {											# For each network
   file_in <- paste(obs_data_dir,"/site_metadata_files/",site_file[j],sep="")
   if (file.exists(file_in)) {
      site_data <- read.csv(file_in,stringsAsFactors=F,colClasses="character")
      col_names <- colnames(site_data)
      if(!"state" %in% col_names)		{ site_data$state <- "NULL" }
      if(!"city" %in% col_names) 		{ site_data$city  <- "NULL" }
      if(!"county" %in% col_names) 	{ site_data$county <- "NULL" }
      if(!"country" %in% col_names)        { site_data$country <- "NULL" }
      if(!"landuse" %in% col_names) 	{ site_data$landuse <- "NULL" }
      if(!"loc_setting" %in% col_names) 	{ site_data$loc_setting <- "NULL" }
      if(!"start_date" %in% col_names) 	{ site_data$start_date <- "NULL" }
      if(!"end_date" %in% col_names) 	{ site_data$end_date <- "NULL" }
      if(!"elevation" %in% col_names) 	{ site_data$elevation <- "NULL" }
      if(!"GMT_offset" %in% col_names) 	{ site_data$GMT_offset <- "NULL" }
      if(!"near_road" %in% col_names)     { site_data$near_road <- "NULL" }
      if(!"co_network" %in% col_names)     { site_data$co_network <- "NULL" }
      if(!"NLCD2011.ImperviousSurface" %in% col_names)     { site_data$NLCD2011.ImperviousSurface <- "NULL" }
      if(!"NLCD2011.ImperviousSurface.Location.Setting" %in% col_names)     { site_data$NLCD2011.ImperviousSurface.Location.Setting <- "NULL" }
      if(!"NLCD2006.ImperviousSurface" %in% col_names)     { site_data$NLCD2006.ImperviousSurface <- "NULL" }
      if(!"NLCD2006.ImperviousSurface.Location.Setting" %in% col_names)     { site_data$NLCD2006.ImperviousSurface.Location.Setting <- "NULL" }
      if(!"NLCD2001.ImperviousSurface" %in% col_names)     { site_data$NLCD2001.ImperviousSurface <- "NULL" }
      if(!"NLCD2001.ImperviousSurface.Location.Setting" %in% col_names)     { site_data$NLCD2001.ImperviousSurface.Location.Setting <- "NULL" }
      indic.na  <- is.na(site_data)                                                  # determine which obs are missing (less than 0); 
      site_data[indic.na] <- -999                                                    # replace any missing values (which are now NAs) with -999
      for (i in 1:length(site_data$stat_id)) {
         ###################################################
         ### Set completely missing Latitude/Longitude value
         ### to 0 to prevent MySQL command from failing
         ###################################################
         if(site_data$lat[i] == "") {
            site_data$lat[i] <- 0
         }
         if(site_data$lon[i] == "") {
            site_data$lon[i] <- 0
         }
         ###################################################
         cat(paste("Inserting metadata for station ",site_data$stat_id[i]," for ",site_data$network[i]," network\n ",sep=""))					# Update user on progress
         q1 <- "REPLACE INTO site_metadata"									# Set part of the MYSQL query
         q2 <- "         (stat_id, num_stat_id, stat_name, network, co_network, state, city, county, country, landuse, loc_setting, start_date, end_date, lat, lon, elevation, GMT_Offset,near_road,NLCD2011_Imperv_Surf_Frac,NLCD2011_Imperv_Surf_Loc_Setting,NLCD2006_Imperv_Surf_Frac,NLCD2006_Imperv_Surf_Loc_Setting,NLCD2001_Imperv_Surf_Frac,NLCD2001_Imperv_Surf_Loc_Setting)"	# Set part of the MYSQL query
         q3 <- paste(" VALUES  ('",site_data$stat_id[i],"', '",i,"', '",site_data$stat_name[i],"', '",site_data$network[i],"', '",site_data$co_network[i],"', '",site_data$state[i],"', '",site_data$city[i],"', '",site_data$county[i],"', '",site_data$country[i],"', '",site_data$landuse[i],"', '",site_data$loc_setting[i],"', '",site_data$start_date[i],"', '",site_data$end_date[i],"', ",site_data$lat[i],", ",site_data$lon[i],", ",site_data$elevation[i],", ",site_data$GMT_offset[i],", '",site_data$near_road[i],"',",site_data$NLCD2011.ImperviousSurface[i],",'",site_data$NLCD2011.ImperviousSurface.Location.Setting[i],"',",site_data$NLCD2006.ImperviousSurface[i],",'",site_data$NLCD2006.ImperviousSurface.Location.Setting[i],"',",site_data$NLCD2001.ImperviousSurface[i],",'",site_data$NLCD2001.ImperviousSurface.Location.Setting[i],"')",sep="")
         query <- paste(q1,q2,q3,sep="")											# Set the MYSQL query
         add_site_list_log <- try(dbSendQuery(con,query))									# Add the site list to the database
         if (class(add_site_list_log)=="try-error") {
            print(paste("Failed to add sites to database with the error: ",add_site_list_log,".",sep=""))
         }
      }	
   }
}
