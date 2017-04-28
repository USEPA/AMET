#!/usr/bin/perl
##---------------------------------------------------------------
#	Surface Station Update Script 				#
#								#
#	PURPOSE: To update the surface station			#
#		database information (id,lat,lon,elev,etc)	#
#								#
#----------------------------------------------------------------


require(RMySQL)                                              # Use RMYSQL package
amet_base <- Sys.getenv('AMETBASE')
if (!exists("amet_base")) {
   stop("Must set AMETBASE environment variable")
}
source.command <- paste(amet_base,"/configure/amet-config.R",sep="")
source(source.command)

dbase <-Sys.getenv('AMET_DATABASE')
if (!exists("dbase")) {
   stop("Must set AMET_DATABASE environment variable")
}

## Get a couple of environment variables
obs_data_dir <- Sys.getenv('AMET_OBS')
amet_R_input <- Sys.getenv('AMETRINPUT')

source(amet_R_input)

con   <- dbConnect(MySQL(),user=root_login,password=root_pass,dbname=dbase,host=mysql_server)
if (!exists("con")) {
   stop("Your MySQL server was not found or login or passwords incorrect, please check to see if server is running or passwords are correct.")
}

for (j in 1:10) {											# For each network
   site_data <- read.csv(paste(amet_base,"/R_Proc_Scripts/site_lists/",site_file[j],sep=""))
   indic.na  <- is.na(site_data)                                                  # determine which obs are missing (less than 0); 
   site_data[indic.na] <- -999                                                    # replace any missing values (which are now NAs) with -999
   for (i in 1:length(site_data$stat_id)) {
      cat(paste("Inserting metadata for station ",site_data$stat_id[i]," for ",site_data$network[i]," network\n ",sep=""))					# Update user on progress
      q1 <- "REPLACE INTO site_metadata"									# Set part of the MYSQL query
      q2 <- "         (stat_id, num_stat_id, stat_name, network, state, city, start_date, end_date, lat, lon, elevation)"	# Set part of the MYSQL query
      q3 <- paste(" VALUES  ('",site_data$stat_id[i],"', '",site_data$num_stat_id[i],"', '",site_data$stat_name[i],"', '",site_data$network[i],"', '",site_data$state[i],"', '",site_data$city[i],"', '",site_data$start_date[i],"', '",site_data$end_date[i],"', ",site_data$lat[i],", ",site_data$lon[i],", ",site_data$elevation[i],")",sep="")
      query <- paste(q1,q2,q3,sep="")											# Set the MYSQL query
      add_site_list_log <- try(dbSendQuery(con,query))									# Add the site list to the database
      if (class(add_site_list_log)=="try-error") {
         print(paste("Failed to add sites to database with the error: ",add_site_list_log,".",sep=""))
      }
   }	
}

for (j in 11:16) {                                                                                       # For each network
   site_data <- read.csv(paste(amet_base,"/R_Proc_Scripts/site_lists/",site_file[j],sep=""))
   indic.na  <- is.na(site_data)                                                  # determine which obs are missing (less than 0); 
   site_data[indic.na] <- -999                                                    # replace any missing values (which are now NAs) with -999
   for (i in 1:length(site_data$stat_id)) { 
      cat(paste("Inserting metadata for station ",site_data$stat_id[i]," for ",site_data$network[i]," network\n ",sep=""))                                      # Update user on progress
      q1<- "REPLACE INTO site_metadata"                                                                      # Set part of the MYSQL query
      q2<-"         (stat_id, num_stat_id, stat_name, network, state, city, start_date, end_date, lat, lon, elevation,landuse)";     # Set part of the MYSQL query
      q3 <- paste(" VALUES  ('",site_data$stat_id[i],"', '",site_data$num_stat_id[i],"', '",site_data$stat_name[i],"', '",site_data$network[i],"', '",site_data$state[i],"', '",site_data$city[i],"', '",site_data$start_date[i],"', '",site_data$end_date[i],"', ",site_data$lat[i],", ",site_data$lon[i],", ",site_data$elevation[i],", '",site_data$landuse[i],"')",sep="")
      query <- paste(q1,q2,q3,sep="")                                                                                   # Set the MYSQL query
      add_site_list_log2 <- try(dbSendQuery(con,query))                                                                  # Add the site list to the database
      if (class(add_site_list_log2)=="try-error") {
         print(paste("Failed to add sites to database with the error: ",add_site_list_log2,".",sep=""))
      }
   }
}

site_data             <- read.csv(paste(amet_base,"/R_Proc_Scripts/site_lists/",aqs_site_file,sep=""))
indic.na              <- is.na(site_data)                                                  # determine which obs are missing (less than 0); 
site_data[indic.na]   <- -999                                                    # replace any missing values (which are now NAs) with -999
site_data$stat_id     <- paste(as.character(site_data$State.Code),sprintf("%03d",site_data$County.Code),sprintf("%04d",site_data$Site.Number),sep="")
site_data$network     <- "AQS"
my.state.name         <- c(state.name,"Guam","Puerto Rico","Virgin Islands","Country Of Mexico","Canada")
my.state.abb          <- c(state.abb,"GU","PR","VI","MX","CA")
site_data$State_Abbr  <- my.state.abb[match(site_data$State.Name,my.state.name)]
site_data$County.Name <- gsub("'","",site_data$County.Name)

for (i in 1:length(site_data$stat_id)) {
   ###################################################
   ### Set completely missing Latitude/Longitude value
   ### to 0 to prevent MySQL command from failing
   ###################################################
   if(site_data$Latitude[i] == "") {
      site_data$Latitude[i] <- 0
   }
   if(site_data$Longitude[i] == "") {
      site_data$Longitude[i] <- 0
   }
   ###################################################
   cat(paste("Inserting metadata for station ",site_data$stat_id[i]," for ",site_data$network[i]," network\n ",sep=""))                                      # Update user on progress
   q1 <-"REPLACE INTO site_metadata"	# Set part of the MYSQL query
   q2 <-" (stat_id, num_stat_id, network, state, city, county, landuse, loc_setting, GMT_Offset, lat, lon)"	# Set part of the MYSQL query
   q3 <- paste(" VALUES  ('",site_data$stat_id[i],"', '",site_data$stat_id[i],"', '",site_data$network[i],"', '",site_data$State_Abbr[i],"', '",site_data$Street_Address[i],"', '",site_data$County.Name[i],"','",site_data$Land.Use[i],"','",site_data$Location.Setting[i],"',",site_data$GMT.Offset[i],", ",site_data$Latitude[i],", ",site_data$Longitude[i],")",sep="")
   query <- paste(q1,q2,q3,sep="")                                                                                   # Set the MYSQL query
   add_site_list_log3 <- try(dbSendQuery(con,query))                                                                  # Add the site list to the database
   if (class(add_site_list_log3)=="try-error") {
      print(paste("Failed to add sites to database with the error: ",add_site_list_log3,".",sep=""))
   }
}
