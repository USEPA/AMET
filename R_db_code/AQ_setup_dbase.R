#!/usr/bin/R
##------------------------------------------------------
#       AMET-AQ Database Setup Script                   #
#                                                       #
#       PURPOSE: To create the AMET database and        #
#                database table, and populate the       #
#                metadata table with the site info      #
#                                                       # 
#       Last Update: 06/07/2017 by Wyat Appel           #
#--------------------------------------------------------

suppressMessages(require(RMySQL))                                              # Use MYSQL R package

amet_base <- Sys.getenv('AMETBASE')
if (!exists("amet_base")) {
   stop("Must set AMETBASE environment variable")
}

config_file     <- Sys.getenv("MYSQL_CONFIG")   # MySQL configuration file
if (!exists("config_file")) {
   stop("Must set MYSQL_CONFIG environment variable")
}
source(config_file)

dbase <-Sys.getenv('AMET_DATABASE')
if (!exists("dbase")) {
   stop("Must set AMET_DATABASE environment variable")
}

args              <- commandArgs(2)
mysql_login        <- args[1]
mysql_pass         <- args[2]

### Use MySQL login/password from config file if requested ###
if (mysql_login == 'config_file') { mysql_login <- amet_login }
if (mysql_pass == 'config_file')  { mysql_pass  <- amet_pass  }
##############################################################

con   <- dbConnect(MySQL(),user=mysql_login,password=mysql_pass,host=mysql_server)
if (!exists("con")) {
   stop("Your MySQL server was not found or login or passwords incorrect, please check to see if server is running or passwords are correct.")
}

## Create a new database
cat(paste("\nChecking to see if the database",dbase,"already exists, creating it if it does not..."))
q <- paste("create DATABASE IF NOT EXISTS",dbase)
create_database_log <- try(dbSendQuery(con,q),silent=T)
if (class(create_database_log)=="try-error") {
   print(paste("**Failed to create new database with the error: ",create_database_log," \n",sep=""))
   stop()
}
cat("done. \n")
con   <- dbConnect(MySQL(),user=mysql_login,password=mysql_pass,dbname=dbase,host=mysql_server)

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Create new project log, units and site metadata tables if running AMET for the first time
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

MYSQL_tables    <- dbListTables(con)
cat("\nCreating required AQ tables if they don't already exist: \n")
aq_new_1  <- "create table project_units (proj_code varchar(100), network varchar(25))"
aq_new_1b <- "alter table project_units add UNIQUE(proj_code, network)"
aq_new_2  <- "create table aq_project_log (proj_code varchar(100) UNIQUE KEY, model varchar(20), user_id varchar(40), passwd varchar(25), email varchar(100), description text, proj_date timestamp, proj_time time, min_date datetime, max_date datetime)"
aq_new_3  <- "create table site_metadata (stat_id varchar(25) UNIQUE KEY, num_stat_id int(10), stat_name varchar(100), network varchar(15), co_network varchar(200), state varchar(4), city varchar(50), start_date varchar(20), end_date varchar(20), lat double, lon double, elevation int(10), landuse varchar(50), loc_setting varchar(50), county varchar(100), country varchar(100), near_road varchar(10), timezone varchar(20), GMT_Offset double, NLCD2011_Imperv_Surf_Frac double,NLCD2011_Imperv_Surf_Loc_Setting varchar(100),NLCD2006_Imperv_Surf_Frac double, NLCD2006_Imperv_Surf_Loc_Setting varchar(100), NLCD2001_Imperv_Surf_Frac double, NLCD2001_Imperv_Surf_Loc_Setting varchar(100))"

{
   if (!("project_units" %in% MYSQL_tables)) {
      cat("Table project_units does not exist, creating...")
      create_units_table_log <- try(dbSendQuery(con,aq_new_1),silent=T)
      alter_units_table_log <- try(dbSendQuery(con,aq_new_1b),silent=T)
      if (class(create_units_table_log)=="try-error") {
         print(paste("\n Did not create units table because: ",create_units_table_log,".",sep=""))
      }
      cat("done. \n")
   }
   else {
      cat("Table project_units exists, doing nothing. \n")
   }
}

{
   if (!("aq_project_log" %in% MYSQL_tables)) {
      cat("Table aq_project_log does not exist, creating...")
      create_project_table_log <- try(dbSendQuery(con,aq_new_2),silent=T)
      if (class(create_project_table_log)=="try-error") {
         print(paste("\n Did not create project log table because: ",create_project_table_log,".",sep=""))
      }
      cat("done. \n")
   }
   else {
      cat("Table aq_project_log exists, doing nothing. \n")
   }
}

reload_meta <- 'F'
reload_meta <- Sys.getenv('RELOAD_METADATA')

{
   if (!("site_metadata" %in% MYSQL_tables)) {
      cat("Table site_metadata does not exist, creating...")
      create_site_metadata_table_log <- try(dbSendQuery(con,aq_new_3),silent=T)
      if (class(create_site_metadata_table_log)=="try-error") {
         print(paste("Did not create site metadata table because: ",create_site_metadata_table_log,".",sep=""))
      }
      cat("done. \n")
      if (class(create_site_metadata_table_log)!="try-error") {
         cat("Populating new AQ db with site metadata...")
         populate.command <- paste("R --no-save --slave --args < ",amet_base,"/R_db_code/AQ_add_sitemeta_dbase.R ",mysql_login," ",mysql_pass," ",sep="")
         system(populate.command)
         cat("done. \n")
      }
   }
   else {
      {
         if (reload_meta != 'F') {
            cat("Re-populating AQ db with site metadata...")
            populate.command <- paste("R --no-save --slave --args < ",amet_base,"/R_db_code/AQ_add_sitemeta_dbase.R ",mysql_login," ",mysql_pass," ",sep="")
            system(populate.command)
            cat("done. \n")
         }
         else {
            cat("Table site_metadata exists, doing nothing. \n")
         }
      }
   }
}
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

