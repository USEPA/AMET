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
#  V1.4, 2018Sep30, Robert Gilliam: 
#        - Added functions for upper-air meteorology. These include table
#          creation functions for rawindsonde and wind profilers. Also,
#          functions to write out profile queries to query file connection.
#  V1.5, 2020Feb21, Robert Gilliam: 
#        - Fixed level bug in raob_query functions that in some cases produced Inf values. Skips now.
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
# new_raob_met_table     -->  AMET rawindsone meteorology table generation for a new project if not 
#                             existing. Also updates main project_log with new project information
#                             for better tracking of model runs. 
#
# new_profiler_met_table -->  AMET wind profiler table generation for a new project if not 
#                             existing. Also updates main project_log with new project information
#                             for better tracking of model runs.
#
# raob_query_native      -->  Query function for raob profiles on native vertical levels of dataset.
#                             This takes an obs or model profile of two variables (T&RH and U&V) and
#                             writes query lines to query file connection.
#
# raob_query_mandatory   -->  Query function for raob profiles on mandatory pressure levels of rawindsonde.
#                             This takes an obs or model profile of two variables (T&RH and U&V) and interpolates
#                             the model to stand. pres. levs then writes query lines to query file connection.
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
#####-----------------      START OF FUNCTION: NEW_DBASE_TABLES      ---------------------------------####
#
# Function to create new surface meteorology table and update project log to reflect new runs
#
# Input:
#       mysql        -- MySQL list that includes all connection requirements like server, login, etc.
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
     projectq  <-paste("CREATE TABLE IF NOT EXISTS project_log (proj_code VARCHAR(30) UNIQUE KEY, model VARCHAR(10), 
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

#####--------------------------	      END OF FUNCTION: NEW_DBASE_TABLES     --------------------------####
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
                    PSFC_ob FLOAT(10,3), PSFC_mod FLOAT(10,3), SNOW_ob FLOAT(10,3), SNOW_mod FLOAT(10,3), 
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

##########################################################################################################
#####-----------------  START OF FUNCTION: NEW_RAOB_MET_TABLES       ---------------------------------####
#
# Function to create new rawindsonde meteorology table and update project log to reflect new runs
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

 new_raob_met_table <-function(mysql,ametproject,metmodel,userid,projectdesc,projectdate) {

   ametproject_table<-paste(ametproject,"_raob",sep="")

   query1<-paste("REPLACE into project_log VALUES('",ametproject,"','",metmodel,"','",userid,"',","NULL",
                    ",","NULL",",'",projectdesc,"','",projectdate,"',NULL,NULL,NULL)",sep="")
   ametQuery(query1,mysql,get=0)

   check_table<-paste("SHOW TABLES FROM `",mysql$dbase,"` LIKE '",ametproject,"_raob'",sep="")
   qout  <-ametQuery(check_table,mysql)

   if(is.na(qout[1,1]) || is.null(qout[1, 1])) {

    table_fmt <- "(stat_id VARCHAR(10), ob_date TIMESTAMP, ob_time  time, fcast_hr  INTEGER(4), init_utc INTEGER(2), \
                   plevel FLOAT(8,0), hlevel FLOAT(8,0), v1_id VARCHAR(10), v2_id VARCHAR(10), \
                   v1_val FLOAT(10,5)  , v2_val FLOAT(10,5) )"

     query2   <-paste("create table ", ametproject_table, table_fmt,sep="")
     writeLines(query2)
     ametQuery(query2,mysql,get=0)
     
     #unique_key_query <-paste("alter table ",ametproject_table," add UNIQUE(ob_date, stat_id, plevel, fcast_hr, init_utc)",sep="") 
     unique_key_query <-paste("alter table ",ametproject_table," add UNIQUE(ob_date, stat_id, plevel, v1_id, v2_id, fcast_hr, init_utc)",sep="") 
     writeLines(unique_key_query)
     ametQuery(unique_key_query,mysql,get=0)
     
     writeLines(paste("AMET Project table ",ametproject_table," added to or updated in the AMET database project table:",
                       mysql$server,ametproject))

   } else if(qout[1,1] == ametproject_table) {
       writeLines(paste("Database Action: ",ametproject_table," AMET table exists. Will add new model-obs pairs to this existing table."))
   }
   
   return()
 }

#####--------------------------	  END OF FUNCTION: NEW_RAOB_MET_TABLES      --------------------------####
##########################################################################################################

##########################################################################################################
#####-----------------  START OF FUNCTION: NEW_PROFILER_MET_TABLES       -----------------------------####
#
# Function to create new wind profiler meteorology table and update project log to reflect new runs
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

 new_profiler_met_table <-function(mysql,ametproject,metmodel,userid,projectdesc,projectdate) {

   ametproject_table<-paste(ametproject,"_profiler",sep="")

   query1<-paste("REPLACE into project_log VALUES('",ametproject,"','",metmodel,"','",userid,"',","NULL",
                    ",","NULL",",'",projectdesc,"','",projectdate,"',NULL,NULL,NULL)",sep="")
   ametQuery(query1,mysql,get=0)

   check_table<-paste("SHOW TABLES FROM `",mysql$dbase,"` LIKE '",ametproject,"_profiler'",sep="")
   qout  <-ametQuery(check_table,mysql)

   if(is.na(qout[1,1]) || is.null(qout[1, 1])) {
 
    table_fmt <- "(proj_code VARCHAR(40), stat_id VARCHAR(10), i FLOAT(8,3), j FLOAT(8,3), landuse  INTEGER(2), \
                   ob_date TIMESTAMP, ob_time  time, fcast_hr  INTEGER(4), init_utc INTEGER(2), plevel FLOAT(8,2), \
                   slevel FLOAT(8,3), hlevel FLOAT(8,3), T_ob FLOAT(10,3)  , T_mod FLOAT(10,3),  U_ob FLOAT(10,3), \
                   U_mod FLOAT(10,3), V_ob FLOAT(10,3), V_mod FLOAT(10,3), W_ob FLOAT(10,3), W_mod FLOAT(10,3), \
                   usd FLOAT(10,5), vsd FLOAT(10,5), wsd FLOAT(10,5), PBL_mod FLOAT(10,5), PBL_ob FLOAT(10,5), SNR FLOAT(8,2) )"

     query2   <-paste("create table ", ametproject_table, table_fmt,sep="")
     writeLines(query2)
     ametQuery(query2,mysql,get=0)
     
     unique_key_query <-paste("alter table ",ametproject_table," add UNIQUE(ob_date,stat_id, plevel, fcast_hr, init_utc)",sep="") 
     ametQuery(unique_key_query,mysql,get=0)
     
     writeLines(paste("AMET Project table ",ametproject_table," added to or updated in the AMET database project table:",
                       mysql$server,ametproject))

   } else if(qout[1,1] == ametproject_table) {
       writeLines(paste("Database Action: ",ametproject_table," AMET table exists. Will add new model-obs pairs to this existing table."))
   }
   
   return()
 }

#####--------------------------	  END OF FUNCTION: NEW_PROFILER_MET_TABLES      ----------------------####
##########################################################################################################

##########################################################################################################
#####-----------------        START OF FUNCTION: RAOB_QUERY_NATIVE       -----------------------------####
#
# Function to write query strings for RAOB obs or model on native levels (no interp from one to the other)
#
# Input:
#       con_file     -- temp query file connection for writing queries
#       ametproject  -- AMET project id
#       stat_id      -- obs site identification string
#       ob_date      -- ob date
#       ob_time      -- ob_time
#       varid_str    -- Column name in MySQL table for the variable (i.e.; v1_id, v2_id)
#       var_str      -- Column name in MySQL table for data (i.e.; v1_val, v2_val)
#       varid_vals   -- Values for the variable string (T_OBS_N, RH_OBS_N, U_OBS_N, etc)
#       profiles     -- Profiles (data.frame) of the variables defined by varid_vals. 
#       levels       -- Level values for the profiles.
#       level_id     -- ID of column for the levels: plevel, hlevel, slevel (press, height,sigma).
#       fcast_hr     -- optional, if forecast model a forecast hour can be provided.
#       init_utc     -- Initialization time if a forecast model is being evaluated.  
#
# Output: Queries are written to connection provided, but no explicity output information is returned.

   raob_query_native <-function(con_file, ametproject, stat_id, ob_date, ob_time, varid_str, var_str, 
                                varid_vals, profiles, levels, level_id="plevel", fcast_hr=0,init_utc=0) {
                                
   mysql_table <- paste(ametproject,"_raob",sep="")
   nl          <- length(levels)

   header    <-paste("(stat_id, ob_date, ob_time, fcast_hr, init_utc, ",
                     level_id,",",varid_str,",",var_str,")")

   for(l in 1:nl) {
    if(is.infinite(levels[l]) || is.na(levels[l]) || is.na(profiles[l,1]) || is.na(profiles[l,2]) ) { next }
    val1<-ifelse(is.na(profiles[l,1]),'NULL',profiles[l,1])
    val2<-ifelse(is.na(profiles[l,2]),'NULL',profiles[l,2])
    values_str<-paste(val1,",",val2,sep="")
    data_str <-paste("('",stat_id,"','",ob_date,"',","'",ob_time,"',",fcast_hr,",",init_utc,",","",
                     levels[l],",",varid_vals,",",values_str,");",sep="")
    query <-paste("REPLACE INTO", mysql_table, header,"VALUES",data_str)
    writeLines(query, con=con_file)
   }

 }
  
#####--------------------------	      END OF FUNCTION: RAOB_QUERY_NATIVE        ----------------------####
##########################################################################################################

##########################################################################################################
#####-----------------        START OF FUNCTION: RAOB_QUERY_MANDATORY       -----------------------------####
#
# Function to write query strings for RAOB obs and model on mandantory/standard pressure levels.
# Unlike the native level function, this interpolates the model profile to observed pressure levels
# so statistics can be computed via the analysis scripts.
#
# Input:
#       con_file     -- temp query file connection for writing queries
#       ametproject  -- AMET project id
#       stat_id      -- obs site identification string
#       ob_date      -- ob date
#       ob_time      -- ob_time
#       varid_str    -- Column name in MySQL table for the variable (i.e.; v1_id, v2_id)
#       var_str      -- Column name in MySQL table for data (i.e.; v1_val, v2_val)
#       varid_vals   -- Values for the variable string (T_OBS_N, RH_OBS_N, U_OBS_N, etc)
#       obs          -- Profile of obs as data.frame. First column is vert. coord, second is the data.
#       mod          -- Profile of mod as data.frame. First column is vert. coord, second is the data.
#       level_id     -- ID of column for the levels: plevel, hlevel, slevel (press, height,sigma).
#       fcast_hr     -- optional, if forecast model a forecast hour can be provided.
#       init_utc     -- Initialization time if a forecast model is being evaluated.  
#
# Output: Queries are written to connection provided, but no explicity output information is returned.

   raob_query_mandatory <-function(con_file, ametproject, stat_id, ob_date, ob_time, varid_str, var_str, 
                                   varid_vals, obs, mod, level_id="plevel", fcast_hr=0,init_utc=0) {
                                
   levels      <- obs[,1]
   mysql_table <- paste(ametproject,"_raob",sep="")
   nl          <- length(levels)
 
   # Determine mod and obs level range and mask out levels outside of model range
   obs.lrange   <- rev(range(obs[,1],na.rm=T))
   mod.lrange   <- rev(range(mod[,1],na.rm=T))
   levels       <- ifelse(levels < mod.lrange[2], NA, levels)
   levels       <- ifelse(levels > mod.lrange[1], NA, levels)
   levels       <- ifelse(is.infinite(levels), NA, levels)
   
   # Interpolate model to obs levels using spline interpolation function
   func        = splinefun(x=mod[,1], y=mod[,2], method="fmm",  ties = mean)
   mod_on_obs  <-func(levels)

   # Masks out model values on levels where obs are missing
   mod_on_obs  <-ifelse(is.na(obs[,2]),NA,mod_on_obs)

   # Double check for bad interpolated values. If RH, T, U/V
   # difference between model and obs are > 100
   diff        <- abs(obs[,2] - mod_on_obs)
   mod_on_obs  <-ifelse(diff > 100, NA, mod_on_obs)

   header      <-paste("(stat_id, ob_date, ob_time, fcast_hr, init_utc, ",
                     level_id,",",varid_str,",",var_str,")")

   for(l in 1:nl) {
    #writeLines(paste(stat_id,l,levels[l],obs[l,2],mod_on_obs[l], diff[l]))
    if(is.na(levels[l]) || is.na(obs[l,2]) || is.na(mod_on_obs[l]) ) { next }
    val1       <-ifelse(is.na(obs[l,2]),'NULL',obs[l,2])
    val2       <-ifelse(is.na(mod_on_obs[l]),'NULL',mod_on_obs[l])
    values_str <-paste(val1,",",val2,sep="")
    data_str   <-paste("('",stat_id,"','",ob_date,"',","'",ob_time,"',",fcast_hr,",",init_utc,",",
                     "",levels[l],",",varid_vals,",",values_str,");",sep="")
    query      <-paste("REPLACE INTO", mysql_table, header,"VALUES",data_str)
    writeLines(query, con=con_file)
   }

 }
  
#####--------------------------	   END OF FUNCTION: RAOB_QUERY_MANDATORY        ----------------------####
##########################################################################################################

