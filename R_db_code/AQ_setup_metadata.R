#!/usr/bin/perl
##------------------------------------------------------
#       AMET-AQ Database Setup Script                   #
#                                                       #
#       PURPOSE: To input site compare output into      #
#               the AMET-AQ MYSQL database              #
#                                                       #
#       Last Update: 04/10/2017 by Wyat Appel           #
#--------------------------------------------------------

require(RMySQL)                                              # Use MYSQL perl package
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

con   <- dbConnect(MySQL(),user=root_login,password=root_pass,dbname=dbase,host=mysql_server)
if (!exists("con")) {
   stop("Your MySQL server was not found or login or passwords incorrect, please check to see if server is running or passwords are correct.")
}

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Create new project log, units and site metadata tables if running AMET for the first time
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
aq_new_1 <- "create table project_units (proj_code varchar(100), network varchar(25))"
aq_new_2 <- "alter table project_units add UNIQUE(proj_code, network)"
aq_new_3 <- "create table aq_project_log (proj_code varchar(100), model varchar(20), user_id varchar(40), passwd varchar(25), email varchar(100), description text, proj_date timestamp, proj_time time, min_date timestamp, max_date timestamp)"
aq_new_4 <- "alter table aq_project_log add UNIQUE(proj_code)"
aq_new_5 <- "create table site_metadata (stat_id varchar(25), num_stat_id int(10), stat_name varchar(100), network varchar(15), state varchar(4), city varchar(50), start_date varchar(20), end_date varchar(20), lat double, lon double, elevation int(10), landuse varchar(50), loc_setting varchar(50), county varchar(100), timezone varchar(20), GMT_Offset double)"
aq_new_6 <- "alter table site_metadata add UNIQUE(stat_id)"
cat("Creating project units table \n")
create_units_table_log <- try(dbSendQuery(con,aq_new_1),silent=T)
if (class(create_units_table_log)=="try-error") {
   print(paste("Failed to create units table with error: ",create_units_table_log,".",sep=""))
}
dbSendQuery(con,aq_new_2)
cat("Creating project log table \n")
create_project_table_log <- try(dbSendQuery(con,aq_new_3),silent=T)
if (class(create_project_table_log)=="try-error") {
   print(paste("Failed to project log table with error: ",create_project_table_log,".",sep=""))
}
dbSendQuery(con,aq_new_4)
cat("Creating site metadata table \n")
create_site_metadata_table_log <- try(dbSendQuery(con,aq_new_5),silent=T)
if (class(create_site_metadata_table_log)=="try-error") {
   print(paste("Failed to site metadata table with error: ",create_site_metadata_table_log,".",sep=""))
}
dbSendQuery(con,aq_new_6)
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

