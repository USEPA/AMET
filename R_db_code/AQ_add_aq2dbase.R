#!/usr/bin/R
##------------------------------------------------------
#       AMET AQ Database Query Input (R format)         #
#                                                       #
#       PURPOSE: To input site compare output into      #
#               the AMET-AQ MYSQL database              #
#                                                       #
#   Last Update: 06/2017 by Wyat Appel                  #
#                                                       #
#   Note that is program assumes a consistent           #
#   configuration of the input files, mainly from       #
#   the site compare and site compare daily O3          #
#   programs. Alteration of the those files may         # 
#   result in this program not working properly.        #
#--------------------------------------------------------

## Load Required Libraries
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}

run_dir          <- Sys.getenv('AMET_OUT')
dbase            <- Sys.getenv('AMET_DATABASE')
base_dir         <- Sys.getenv('AMETBASE')
config_file      <- Sys.getenv('MYSQL_CONFIG')

source(config_file)

args              <- commandArgs(5)
mysql_login       <- args[1]
mysql_pass        <- args[2]
project_id        <- args[3]
dtype             <- args[4]
sitex_file        <- args[5]

project_id        <- gsub("[.]","_",project_id)

cat(paste("\nProject_ID: ",project_id,"\n",sep=""))
cat(paste("Network: ",dtype,"\n",sep=""))
cat(paste("Sitex File: ",sitex_file,"\n",sep=""))
cat(paste("MySQL Server: ",mysql_server,"\n",sep=""))

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
db_Query<-function(query,mysql,get=1,verbose=FALSE)
 {
  db<-dbDriver("MySQL")                         # MySQL Database type
  con <-dbConnect(db,user=mysql$login,pass=mysql$passwd,host=mysql$server,dbname=mysql$dbase)           # Database connect

  for (q in 1:length(query)){
    rs<-dbSendQuery(con,query[q])       # Send query and place results in data frame
    if(verbose){ print(query[q]) }
  }
  if(get == 1){df<-fetch(rs,n=mysql$maxrec)}

  dbClearResult(rs)
  dbDisconnect(con)             # Database disconnect

  return(df)

 }
################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
reformat <- function(a) paste(a,collapse=",")
###############################################################

### Use MySQL login/password from config file if requested ###
if (mysql_login == 'config_file') { mysql_login <- amet_login }
if (mysql_pass == 'config_file')  { mysql_pass  <- amet_pass  }
##############################################################

mysql	<- list(login=mysql_login, passwd=mysql_pass, server=mysql_server, dbase=dbase, maxrec=maxrec)	# Set MYSQL login and query options
con	<- dbConnect(MySQL(),user=mysql_login,password=mysql_pass,dbname=dbase,host=mysql_server)

sitex_in    <- read.csv(sitex_file,skip=5,colClasses = "character") # Read sitex file with header
sitex_in2   <- read.csv(sitex_file,skip=3,header=F,colClasses="character",nrows=3)  # Read sitex file w/o header
sitex_names <- as.character(sitex_in2[3,])   # Store species names
sitex_units <- as.character(sitex_in2[1,])   # Store species units
sitex_modob <- as.character(sitex_in2[2,])   # Store mod/ob designation
col_offset <- which(sitex_names=="Emm")
#col_offset <- 18
if ((dtype == 'AQS_Daily_O3') || (dtype == 'CASTNET_Daily') || (dtype == 'EMEP_Daily_O3') || (dtype == 'NAPS_Daily_O3')) {
   col_offset <- which(sitex_names=="EYYYY" )
#   col_offset <- 14
}
if (dtype == 'NADP') {
  col_offset <- which(sitex_names=="Invalcode_ob")
#  col_offset <- 20
}
if (dtype == 'AMON') {
  if ("QR_ob" %in% sitex_names) {
     col_offset <- which(sitex_names=="QR_ob")
  }
}
cat(paste("Successfully read ",sitex_file,"\n",sep=""))
num_cols    <- ncol(sitex_in)
start_month <- as.numeric(substr(sitex_in$Time.On,1,2))
end_month   <- as.numeric(substr(sitex_in$Time.Off,1,2))
start_day   <- as.numeric(substr(sitex_in$Time.On,4,5))
end_day     <- as.numeric(substr(sitex_in$Time.Off,4,5))
start_year  <- as.numeric(substr(sitex_in$Time.On,7,10))
end_year    <- as.numeric(substr(sitex_in$Time.Off,7,10))
hour        <- as.numeric(substr(sitex_in$Time.On,12,13))
start_time  <- paste(start_year,sprintf("%02d",start_month),sprintf("%02d",start_day),sep="")
end_time    <- paste(end_year,sprintf("%02d",end_month),sprintf("%02d",end_day),sep="")
{
   if ("POCode"%in% sitex_names) {
      POCode <- sitex_in$POCode
   }
   else {
      sitex_in$POCode <- 1
   }      
}
######################################################
### Check for missing POCode in Site Compare Input ###
######################################################
cat("Checking for missing POCode column in project table...")
check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_SCHEMA = '",dbase,"' and TABLE_NAME = '",project_id,"' and COLUMN_NAME = 'POCode';",sep="")
query_table_info.df <- suppressMessages(db_Query(check_POCode,mysql))
cat("done. \n")
if (length(query_table_info.df$COLUMN_NAME) == 0) {
   create_POCode_Column <- paste("alter table ",project_id," add column POCode integer",sep="")
   make_POCode_unique   <- paste("alter table ",project_id," add UNIQUE(network,stat_id,POCode,ob_dates,ob_datee,ob_hour)",sep="")
   cat("\nPOCode column missing (must be an old table). Adding POCode column to project table...")
   mysql_result <- dbSendQuery(con,create_POCode_Column)
   mysql_result <- dbSendQuery(con,make_POCode_unique)
   cat("done. \n")
}
check_stat_id_POCode 		<- paste("select * from information_schema.COLUMNS where TABLE_SCHEMA = '",dbase,"' and TABLE_NAME = '",project_id,"' and COLUMN_NAME = 'stat_id_POCode';",sep="")
query_table_info.df <- suppressMessages(db_Query(check_stat_id_POCode,mysql))
if (length(query_table_info.df$COLUMN_NAME) == 0) {
   create_stat_id_POCode_Column <- paste("alter table ",project_id," add column stat_id_POCode character(100)",sep="")
   cat("stat_id_POCode column missing (must be an old table). Adding stat_id_POCode column to project table...")
   mysql_result <- dbSendQuery(con,create_stat_id_POCode_Column)
   cat("...done. \n")
}
#####################################################

###########################################################
### Determine which month to associate with each record ###
###########################################################
cat("Determining month for each observation...")
Month_diff <- end_month - start_month
choose.end.month <- 1*(Month_diff!=0&end_day>=4)
sitex_in$Month <- end_month*choose.end.month+start_month*(1-choose.end.month)
cat("done. \n")
#####################################################

sitex_in$dtype     <- dtype
sitex_in$project_id    <- project_id
sitex_in$hour      <- hour
sitex_names        <- sitex_names[-c(1:col_offset)]
unit_names_tmp     <- unlist(strsplit(sitex_names,"_ob"))
unit_species_names <- unlist(strsplit(unit_names_tmp,"_mod"))
unit_species_vals  <- sitex_units[-c(1:col_offset)]
duplicate_names	   <- duplicated(unit_species_names)   # Determine duplicated species names for units

########################################################
### Check for missing species in project units table ###
########################################################
unit_query_names  <- unit_species_names[!duplicate_names]   # Remove duplicated names from name list
unit_query_vals   <- unit_species_vals[!duplicate_names]  # Remove duplicated names from units list
q1_units          <- "REPLACE INTO project_units"
q2_units          <- " (proj_code,network"

cat("Checking for missing species in project_units table...") 
check_unit_names        <- paste("select COLUMN_NAME from information_schema.COLUMNS where TABLE_SCHEMA = '",dbase,"' and TABLE_NAME = 'project_units'",sep="")
query_table_info.df 	<- suppressMessages(db_Query(check_unit_names,mysql))
units_to_add    	<- unit_query_names[!toupper(unit_query_names)%in%toupper(query_table_info.df$COLUMN_NAME)]
cat("done. \n")
if (length(units_to_add) > 0) {
   cat("Units table column will be added for species: \n")
   for (i in 1:length(units_to_add)) {
      cat(paste(units_to_add[i],"\n"))
      create_units_column <- paste("alter table project_units add column ",units_to_add[i]," varchar(10);",sep="")
      mysql_result <- dbSendQuery(con,create_units_column)
   }
   cat("Done adding missing units species. \n\n")
}
########################################################

###########################################
### Load units into project units table ###
###########################################
cat("Loading units into project units table...")

for (i in 1:length(unit_query_names)) {
   q2_units <- paste(q2_units,unit_query_names[i],sep=",")
}
q2_units <- paste(q2_units,")")
q3_units <- paste(" VALUES ('",project_id,"','",dtype,"'",sep="")
for (i in 1:length(unit_query_vals)) {
   q3_units <- paste(q3_units,",'",unit_query_vals[i],"'",sep="")
}
q3_units <- paste(q3_units,")")
qs_units <- paste(q1_units,q2_units,q3_units,sep = " ")
mysql_result <- suppressMessages(dbSendQuery(con,qs_units))
cat("done. \n")
###########################################

#################################################
### Check for missing sites in metadata table ###
#################################################
q1_sites          <- "REPLACE INTO site_metadata"
q2_sites          <- " (stat_id,num_stat_id,network"

cat("Checking for missing sites in the site_metadata table...")
existing_sites_query    <- paste("select stat_id,num_stat_id from ",dbase,".site_metadata;",sep="")
query_table_info.df     <- db_Query(existing_sites_query,mysql)
existing_sites		<- query_table_info.df[,1]
missing_sites           <- sitex_in$SiteId[!(sitex_in$SiteId %in% existing_sites)]
max_num_stat_id		<- max(query_table_info.df[,2])
#cat(missing_sites)
#query_table_info.df     <- suppressMessages(db_Query(check_unit_names,mysql))
#units_to_add            <- unit_query_names[!toupper(unit_query_names)%in%toupper(query_table_info.df$COLUMN_NAME)]
cat("done. \n")
{
   if (length(missing_sites) > 0) {
      cat("the following sites will be added to the site_metadata table: \n")
      for (i in 1:length(missing_sites)) {
         num_stat_id <- max_num_stat_id+i
         cat(paste(missing_sites[i],"\n"))
         latitude       <- sitex_in$Latitude[sitex_in$SiteId==missing_sites[i]]
         longitude      <- sitex_in$Longitude[sitex_in$SiteId==missing_sites[i]]
         add_site_query <- paste("REPLACE INTO ",dbase,".site_metadata (stat_id, num_stat_id, network, lat, lon) values ('",missing_sites[i],"','",num_stat_id,"','",sitex_in$dtype[i],"',",latitude,",",longitude,");",sep="")
         mysql_result   <- dbSendQuery(con,add_site_query)
      }
      cat("Done adding missing sites. Consider updating the network site list to include these missing sites with additional metadata.\n\n")
   }
   else {
         cat("No missing sites found in the site_metadata table. \n")
   }
}

########################################################

##################################################
### Check for missing species in project table ###
##################################################
database_species_names <- sitex_names
cat("Checking for missing species in project table...")
check_species           <- paste("select COLUMN_NAME from information_schema.COLUMNS where TABLE_SCHEMA = '",dbase,"' and TABLE_NAME = '",project_id,"';",sep="")
query_table_info.df     <- db_Query(check_species,mysql)
species_to_add          <- database_species_names[!toupper(database_species_names)%in%toupper(query_table_info.df$COLUMN_NAME)]
cat("done. \n")
{
   if (length(species_to_add) > 0) {
      cat("Table column will be added for species: \n")
      cat(paste(species_to_add[1],"\n"))
      create_species_column <- paste("alter table ",project_id," add column ",species_to_add[1]," double",sep="")
      for (i in 2:length(species_to_add)) {
         cat(paste(species_to_add[i],"\n"))
         create_species_column <- paste(create_species_column,", add column ",species_to_add[i]," double",sep="")
      }
      create_species_column <- paste(create_species_column,";",sep="")
      cat(paste("\nCreating table columns for all missing species...",sep=""))
      dbSendQuery(con,create_species_column)
      cat("done. \n")
   }
   else {
      cat("No missing species found in the project table. \n")
   }
}
###################################################

q1_main <- paste("REPLACE INTO",project_id,sep=" ")
q2_main <- " (proj_code, network, stat_id, POCode, stat_id_POCode, lat, lon, i, j, ob_dates, ob_datee, ob_hour, month"
if (dtype == 'NADP') {
   q2_main <- " (proj_code, network, stat_id, POCode, stat_id_POCode, lat, lon, i, j, ob_dates, ob_datee, ob_hour, month, valid_code, invalid_code"
}
if (dtype == 'AMON') {
   q2_main <- " (proj_code, network, stat_id, POCode, stat_id_POCode, lat, lon, i, j, ob_dates, ob_datee, ob_hour, month, valid_code"
}
for (i in 1:length(database_species_names)) {
   q2_main <- paste(q2_main,database_species_names[i],sep=", ")
}

q3_main <- data.frame(project_id=paste("'",sitex_in$project_id,"'",sep=""),dtype=paste("'",sitex_in$dtype,"'",sep=""),SiteId=paste("'",sitex_in$SiteId,"'",sep=""),sitex_in$POCode,stat_id_POCode=paste("'",sitex_in$SiteId,sitex_in$POCode,"'",sep=""),sitex_in$Latitude,sitex_in$Longitude,sitex_in$Column,sitex_in$Row,start_time,end_time,sitex_in$hour,sitex_in$Month,sitex_in[(col_offset+1):num_cols])
if (dtype == 'NADP') {
   q3_main <- data.frame(project_id=paste("'",sitex_in$project_id,"'",sep=""),dtype=paste("'",sitex_in$dtype,"'",sep=""),SiteId=paste("'",sitex_in$SiteId,"'",sep=""),sitex_in$POCode,stat_id_POCode=paste("'",sitex_in$SiteId,sitex_in$POCode,"'",sep=""),sitex_in$Latitude,sitex_in$Longitude,sitex_in$Column,sitex_in$Row,start_time,end_time,sitex_in$hour,sitex_in$Month,valid_code=paste("'",sitex_in$Valcode,"'",sep=""),invalid_code=paste("'",sitex_in$Invalcode,"'",sep=""),sitex_in[(col_offset+1):num_cols])
}
if (dtype == 'AMON') {
   q3_main <- data.frame(project_id=paste("'",sitex_in$project_id,"'",sep=""),dtype=paste("'",sitex_in$dtype,"'",sep=""),SiteId=paste("'",sitex_in$SiteId,"'",sep=""),sitex_in$POCode,stat_id_POCode=paste("'",sitex_in$SiteId,sitex_in$POCode,"'",sep=""),sitex_in$Latitude,sitex_in$Longitude,sitex_in$Column,sitex_in$Row,start_time,end_time,sitex_in$hour,sitex_in$Month,valid_code=paste("'",sitex_in$QR,"'",sep=""),sitex_in[(col_offset+1):num_cols])
}
q3_main2 <- apply(q3_main,1,reformat)
query <- paste("REPLACE INTO ",project_id,q2_main,") VALUES (",q3_main2,"); ",sep="")
mysql_query_file <- paste(run_dir,"/MySQL_query.txt",sep="")
cat("Writing temporary MySQL query file...")
cat(paste("use ",dbase,";",sep=""),file=mysql_query_file,append=F,sep="\n")
cat(query,file=mysql_query_file,append=T,sep="\n")
cat("done. \n")
cat("Loading data into MySQL database using temporary file (may take some time)...")
mysql_command <- paste("mysql --host=",mysql$server," --user=",mysql$login," --password=",mysql$passwd," --database=",mysql$dbase," < ",mysql_query_file,sep="")
system(mysql_command)
delete_command <- paste("rm ",mysql_query_file,sep="")
system(delete_command)
cat("done. \n")

#####################################################################################################################################
### This section automatically updates the min and max dates in the project_log table each time the add_aq2dbase.R script is run  ###
#####################################################################################################################################


min_date <- min(start_time)
max_date <- max(end_time)

cat("Updating project log...")
query_all <- paste("SELECT proj_code,model,user_id,passwd,email,description,DATE_FORMAT(proj_date,'%Y%m%d'),proj_time,DATE_FORMAT(min_date,'%Y%m%d'),DATE_FORMAT(max_date,'%Y%m%d') from aq_project_log where proj_code='",project_id,"' ",sep="")    # set query for project log table for all information regarding current project
info_all <- dbGetQuery(con,query_all)
model        <- info_all[,2] 
user_id      <- info_all[,3]
password     <- info_all[,4]
email        <- info_all[,5]
description  <- info_all[,6]
proj_date    <- info_all[,7]
proj_time    <- info_all[,8]
min_date_old <- info_all[,9]
max_date_old <- info_all[,10]

if ((is.na(min_date_old)) || (min_date_old == '00000000')) {        # override the initial value of 0 for the earliest date record
   min_date_old <- min_date
}
if ((is.na(max_date_old)) || (max_date_old == '00000000')) {        # override the initial value of 0 for the earliest date record
   max_date_old <- min_date
}
if (min_date > min_date_old)  {
   min_date <- min_date_old
}
if (max_date < max_date_old) {
   max_date <- max_date_old
}
query_dates <- paste("REPLACE INTO aq_project_log (proj_code,model,user_id,passwd,email,description,proj_date,proj_time,min_date,max_date) values ('",project_id,"','",model,"','",user_id,"','",password,"','",email,"','",description,"','",proj_date,"','",proj_time,"','",min_date,"','",max_date,"')",sep="")                    # put first and last dates into project log
mysql_result <- dbSendQuery(con,query_dates)
cat("done.\n\n")
#######################################################################################################################################
mysql_result <- dbDisconnect(con)
