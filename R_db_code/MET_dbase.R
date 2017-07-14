#######################################################################################################
#####################################################################################################
#                                                                 ################################
#     AMET Database Functions Library for Meteorology             ###############################
#                                                                 ###############################
#       Version 1.3                                               ###############################
#       Date: April 18, 2017                                      ###############################
#       Contributors:Robert Gilliam                               ###############################
#                                                                 ###############################
#     Developed by the US Environmental Protection Agency         ###############################
#                                                                 ################################
#####################################################################################################
#######################################################################################################
#
#  V1.3, 2017Apr18, Robert Gilliam: Initial Development
#
#######################################################################################################
#######################################################################################################
#     This script contains the following functions
#
#     ametQuery          -->  Simple wrapper function for MySQL queries to allow for cleaner code
#
#   new_dbase_tables     -->  AMET database 
#                             existing. Also updates main project_log with new project information
#                             for better tracking of model runs. 
#
# new_surface_met_table  -->  AMET surface meteorology table generation for a new project if not 
#                             existing. Also updates main project_log with new project information
#                             for better tracking of model runs. 
#
#######################################################################################################
#######################################################################################################

###############################################################
#- - - - - - - - -   START OF AMETQUERY FUNCTION  -  - - - - ##
###############################################################
###  MySQL ametQuery  Function 
#
# Input: query   - either a single or multiple queries, although single queries are most common (Required)
#        mysql   - list that details MySQL details for connection: server, dbase, login and passwrd (Required)
#        get     - whether data is being retrieved from query or not. (Optional)
#        verbose - write query to screen or log file for diagnostics. (Optional)
#   
# Output: A data frames with all data from query.
#   
###
 ametQuery <-function(query,mysql,get=1,verbose=F) {

  # MySQL Database
  db<-dbDriver("MySQL")

  # Database connect
  con <-dbConnect(db,user=mysql$login,pass=mysql$passwd,host=mysql$server,dbname=mysql$dbase)

  for (q in 1:length(query)){
      rs<-dbSendQuery(con,query[q])
      if(verbose) { writeLines(query[q]) }
  }

  if(get == 1) {
    df<-fetch(rs,n=mysql$maxrec)
  }
  
  dbClearResult(rs)

  # Database disconnect
  dbDisconnect(con)
  
  return(df)

 }
##############################################################################################################
#------------------------------- END OF AMETQUERY FUNCTION  ------------------------------------------------##
##############################################################################################################


##########################################################################################################
#####-----------------  START OF FUNCTION: NEW_SURFACE_MET_TABLES    ---------------------------------####
#
# Function to create new surface meteorology table and update project log to reflect new runs
#
# Input:
#       mysql        -- MySQL list that includes all connection requirements like server, login, etc.
#       ametproject  -- AMET project id
#       metmodel     -- Meteorological model (mpas or wrf)
#       userid       -- Users computer id to keep track of who created various projects
#       projectdesc  -- Project/model run description to maintain details of model runs
#       projectdate  -- Date that the new project was created
#
# Output: None

 new_dbase_tables <-function(mysql) {

   dbaseq<-paste("CREATE DATABASE IF NOT EXISTS ",mysql$dbase,";")
   writeLines(paste("Creating new database if it does not exist:",dbaseq))
   db   <-dbDriver("MySQL")
   con  <-dbConnect(db,user=mysql$login,pass=mysql$passwd,host=mysql$server)
   rs   <-dbSendQuery(con,dbaseq)
   dbClearResult(rs)
   dbDisconnect(con)

   # Check to see if stations table exist. If not create a new stations table in new database
   check_table<-paste("SHOW TABLES FROM `",mysql$dbase,"` LIKE 'stations'",sep="")
   qout  <-ametQuery(check_table,mysql)

   if(is.na(qout[1,1]) || is.null(qout[1, 1])) {
     stationsq <-paste("CREATE TABLE IF NOT EXISTS stations  (stat_id VARCHAR(10) UNIQUE KEY, ob_network VARCHAR(20),  
                        lat FLOAT(8,4), lon FLOAT(8,4), i INTEGER(4), j INTEGER(4), elev FLOAT(8,2), 
                        landuse  INTEGER(2), common_name VARCHAR(80), state VARCHAR(2), country VARCHAR(30))")
     ametQuery(stationsq,mysql,get=0)
     
   } else if(qout[1,1] == "stations") {
       writeLines(paste("Database Action: An AMET ** stations ** table exists in database",mysql$dbase,
                         ". Will use this existing table."))
   }

   # Check to see if project_log table exist. If not create a new table in the database
   check_table<-paste("SHOW TABLES FROM `",mysql$dbase,"` LIKE 'project_log'",sep="")
   qout  <-ametQuery(check_table,mysql)

   if(is.na(qout[1,1]) || is.null(qout[1, 1])) {
     projectq  <-paste("CREATE TABLE IF NOT EXISTS project_log (proj_code VARCHAR(30), model VARCHAR(10), 
                        user_id VARCHAR(20), passwd VARCHAR(20), email VARCHAR(30), description TEXT, 
                        proj_date TIMESTAMP, proj_time time, min_date DATETIME, max_date DATETIME)")
     writeLines(projectq)
     ametQuery(projectq,mysql,get=0)
     
   } else if(qout[1,1] == "project_log") {
       writeLines(paste("Database Action: An AMET ** project_log ** table exists in database",mysql$dbase,
                         ". Will not re-create this existing table."))
   }
     
   return()
 }

#####--------------------------	  END OF FUNCTION: NEW_SURFACE_MET_TABLES   --------------------------####
##########################################################################################################

##########################################################################################################
#####-----------------  START OF FUNCTION: NEW_SURFACE_MET_TABLES    ---------------------------------####
#
# Function to create new surface meteorology table and update project log to reflect new runs
#
# Input:
#       mysql        -- MySQL list that includes all connection requirements like server, login, etc.
#       ametproject  -- AMET project id
#       metmodel     -- Meteorological model (mpas or wrf)
#       userid       -- Users computer id to keep track of who created various projects
#       projectdesc  -- Project/model run description to maintain details of model runs
#       projectdate  -- Date that the new project was created
#
# Output: None

 new_surface_met_table <-function(mysql,ametproject,metmodel,userid,projectdesc,projectdate) {

   ametproject_table<-paste(ametproject,"_surface",sep="")

   query1<-paste("REPLACE into project_log VALUES('",ametproject,"','",metmodel,"','",userid,"',","NULL",
                    ",","NULL",",'",projectdesc,"','",projectdate,"',NULL,NULL,NULL)",sep="")
   ametQuery(query1,mysql,get=0)

   check_table<-paste("SHOW TABLES FROM `",mysql$dbase,"` LIKE '",ametproject,"_surface'",sep="")
   qout  <-ametQuery(check_table,mysql)

   if(is.na(qout[1,1]) || is.null(qout[1, 1])) {
     query2<-paste("create table ",ametproject_table," (proj_code VARCHAR(40), model VARCHAR(10), 
                    ob_network VARCHAR(20), stat_id VARCHAR(10), i FLOAT(8,3), j FLOAT(8,3), landuse  INTEGER(2), 
                    ob_date TIMESTAMP, ob_time  time, fcast_hr  INTEGER(4), init_utc INTEGER(2), var_id VARCHAR(10), 
                    level FLOAT(8,2), T_ob FLOAT(10,3), T_mod FLOAT(10,3), Q_ob FLOAT(10,6), WVMR_ob FLOAT(10,6), 
                    Q_mod FLOAT(10,6) , U_ob FLOAT(10,3), U_mod FLOAT(10,3), V_ob FLOAT(10,3), V_mod FLOAT(10,3), 
                    PCP1H_ob FLOAT(10,6), PCP1H_mod FLOAT(10,6), SRAD_ob FLOAT(10,3), SRAD_mod FLOAT(10,3), 
                    pblh FLOAT(10,5), monin FLOAT(10,5), ustar FLOAT(10,5))",sep="")
     writeLines(query2)
     ametQuery(query2,mysql,get=0)
     
     unique_key_query<-paste("alter table ",ametproject_table," add UNIQUE(ob_date,ob_time,stat_id,fcast_hr,init_utc)",sep="") 
     ametQuery(unique_key_query,mysql,get=0)
     
     writeLines(paste("AMET Project table ",ametproject_table," added to or updated in the AMET database project table:",
                       mysql$server,ametproject))

   } else if(qout[1,1] == ametproject_table) {
       writeLines(paste("Database Action: ",ametproject_table," AMET table exists. Will add new model-obs pairs to this existing table."))
   }
   
   return()
 }

#####--------------------------	  END OF FUNCTION: NEW_SURFACE_MET_TABLES   --------------------------####
##########################################################################################################

