#!/usr/bin/perl
##---------------------------------------------------------------
#	Surface Station Update Script 				#
#								#
#	PURPOSE: To update the surface station			#
#		database information (id,lat,lon,elev,etc)	#
#								#
#----------------------------------------------------------------

amet_base <- Sys.getenv('AMETBASE')
if (!exists("amet_base")) {
   stop("Must set AMETBASE environment variable")
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
   site_data <- read.csv(paste(amet_base,"/obs/AQ/site_files/",site_file[j],sep=""),stringsAsFactors=F,colClasses="character")
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
      q2 <- "         (stat_id, num_stat_id, stat_name, network, state, city, county, landuse, loc_setting, start_date, end_date, lat, lon, elevation, GMT_Offset)"	# Set part of the MYSQL query
      q3 <- paste(" VALUES  ('",site_data$stat_id[i],"', '",site_data$num_stat_id[i],"', '",site_data$stat_name[i],"', '",site_data$network[i],"', '",site_data$state_abbr[i],"', '",site_data$city[i],"', '",site_data$county[i],"', '",site_data$landuse[i],"', '",site_data$loc_setting[i],"', '",site_data$start_date[i],"', '",site_data$end_date[i],"', ",site_data$lat[i],", ",site_data$lon[i],", ",site_data$elevation[i],", ",site_data$GMT_offset[i],")",sep="")
      query <- paste(q1,q2,q3,sep="")											# Set the MYSQL query
#     print(query)
      add_site_list_log <- try(dbSendQuery(con,query))									# Add the site list to the database
      if (class(add_site_list_log)=="try-error") {
         print(paste("Failed to add sites to database with the error: ",add_site_list_log,".",sep=""))
      }
   }	
}

#for (j in 11:16) {                                                                                       # For each network
#   site_data <- read.csv(paste(amet_base,"/obs/site_metadata_files/",site_file[j],sep=""))
#   indic.na  <- is.na(site_data)                                                  # determine which obs are missing (less than 0); 
#   site_data[indic.na] <- -999                                                    # replace any missing values (which are now NAs) with -999
#   for (i in 1:length(site_data$stat_id)) { 
#      cat(paste("Inserting metadata for station ",site_data$stat_id[i]," for ",site_data$network[i]," network\n ",sep=""))                                      # Update user on progress
#      q1<- "REPLACE INTO site_metadata"                                                                      # Set part of the MYSQL query
#      q2<-"         (stat_id, num_stat_id, stat_name, network, state, city, start_date, end_date, lat, lon, elevation,landuse)";     # Set part of the MYSQL query
#      q3 <- paste(" VALUES  ('",site_data$stat_id[i],"', '",site_data$num_stat_id[i],"', '",site_data$stat_name[i],"', '",site_data$network[i],"', '",site_data$state[i],"', '",site_data$city[i],"', '",site_data$start_date[i],"', '",site_data$end_date[i],"', ",site_data$lat[i],", ",site_data$lon[i],", ",site_data$elevation[i],", '",site_data$landuse[i],"')",sep="")
#      query <- paste(q1,q2,q3,sep="")                                                                                   # Set the MYSQL query
#      add_site_list_log2 <- try(dbSendQuery(con,query))                                                                  # Add the site list to the database
#      if (class(add_site_list_log2)=="try-error") {
#         print(paste("Failed to add sites to database with the error: ",add_site_list_log2,".",sep=""))
#      }
#   }
#}

##########################
### Load AQS Site Data ###
##########################

#site_data             <- read.csv(paste(amet_base,"/obs/site_metadata_files/",aqs_site_file,sep=""),stringsAsFactors=F)
#indic.na              <- is.na(site_data)                                        # determine which fields are missing 
#site_data[indic.na]   <- -999                                                    # replace any missing values (which are now NAs) with -999

#for (i in 1:length(site_data$stat_id)) {
   ###################################################
   ### Set completely missing Latitude/Longitude value
   ### to 0 to prevent MySQL command from failing
   ###################################################
#   if(site_data$lat[i] == "") {
#      site_data$lat[i] <- 0
#   }
#   if(site_data$lon[i] == "") {
#      site_data$lon[i] <- 0
#   }
   ###################################################
#   cat(paste("Inserting metadata for station ",site_data$stat_id[i]," for ",site_data$network[i]," network\n ",sep=""))                                      # Update user on progress
#   q1 <-"REPLACE INTO site_metadata"	# Set part of the MYSQL query
#   q2 <-" (stat_id, num_stat_id, network, state, city, county, landuse, loc_setting, GMT_Offset, lat, lon)"	# Set part of the MYSQL query
#   q3 <- paste(" VALUES  ('",site_data$stat_id[i],"', '",i,"', '",site_data$network[i],"', '",site_data$state[i],"', '",site_data$city[i],"', '",site_data$county[i],"','",site_data$landuse[i],"','",site_data$loc_setting[i],"',",site_data$GMT_offset[i],", ",site_data$lat[i],", ",site_data$lon[i],")",sep="")
#   query <- paste(q1,q2,q3,sep="")                                                                                   # Set the MYSQL query
#   add_site_list_log3 <- try(dbSendQuery(con,query))                                                                  # Add the site list to the database
#   if (class(add_site_list_log3)=="try-error") {
#      print(paste("Failed to add sites to database with the error: ",add_site_list_log3,".",sep=""))
#   }
#}
