#!/usr/bin/R
##------------------------------------------------------##
#   PROGRAM NAME: AQ_matching.R                          #
#                                                        #
#     This is essentially a wrapper script for AMET.     #
#  This R program runs Site Compare for user selected    #
#  networks and then runs AQ_add_aq2dbase.R to add the   #
#  data to the MYSQL database.  This program is part of  #
#  the AMET-AQ system, and is intended to be used with   #
#  the php interface included with AMET.                 #
#                                                        #
#       REQUIRED: amet-config.R                          #
#                 AQ_species_list.input			 #
#                                                        #
#       PURPOSE: Run Site Compare and then put the       #
#                output into the MYSQL database for AMET #
#                                                        #
#       LAST UPDATE: 06/2022 by K. Wyat Appel		 #
#                                                        #
##------------------------------------------------------##

amet_base <- Sys.getenv('AMETBASE')
if (!exists("amet_base")) {
   stop("Must set AMETBASE environment variable")
}

config_file     <- Sys.getenv("MYSQL_CONFIG")   # MySQL configuration file
if (!exists("config_file")) {
   stop("Must set MYSQL_CONFIG environment variable")
}
source(config_file)

AMET_DB <- Sys.getenv('AMET_DB')
if (!exists("AMET_DB")) {
   print("AMET_DB flag not set. Defaulting to T. Set AMET_DB flag in run script.")
   AMET_DB <- "T"
}
if ((AMET_DB == "y") || (AMET_DB == "Y") || (AMET_DB == "t") || (AMET_DB == "T")) {
   dbase <-Sys.getenv('AMET_DATABASE')
   if (!exists("dbase")) {
      stop("Must set AMET_DATABASE environment variable")
   }
}
EXEC_sitex	 <- Sys.getenv('EXEC_sitecmp')
if ((!exists("EXEC_sitex")) || (EXEC_sitex == "")) { 
   stop("Path to site compare executable (EXEC_sitecmp) not set! This path must be set in the run script if running site compare to do the model-obs matching.")
}

EXEC_sitex_daily <- Sys.getenv('EXEC_sitecmp_dailyo3')
if ((!exists("EXEC_sitex_daily")) || (EXEC_sitex_daily == "")) { 
   stop("Path to site compare daily executable (EXEC_sitecmp_dailyo3) not set! This path must be set in the run script if running site compare daily to do the model-obs matching.")
}

num_avg_hours <- Sys.getenv('HOURS_8HRMAX')
if (!exists("num_avg_hours")) {
   print("Number of 8hr max averaging hours not set. Defaulting to 17. To set the averaging hours, specify HOURS_8HRMAX (setenv HOURS_8HRMAX) as either 17 or 24 in the AMET run script.")
   num_avg_hours <- 17 
}

args              <- commandArgs(2)
mysql_login        <- args[1]
mysql_pass         <- args[2]

site_file_name 		<- "_sites.txt"
site_file_directory 	<- "/site_files"
site_file_format 	<- Sys.getenv('SITE_FILE_FORMAT')

if (site_file_format == "csv") { 
   site_file_name <- "_full_site_list.csv" 
   site_file_directory <- "/site_metadata_files"
}

### Use MySQL login/password from config file if requested ###
if (mysql_pass == 'config_file')  { mysql_pass  <- amet_pass  }
##############################################################

obs_data_dir           <- Sys.getenv('AMET_OBS')
use_AE6                <- Sys.getenv('INC_AERO6_SPECIES')
time_shift             <- Sys.getenv('TIME_SHIFT')
data_dir               <- Sys.getenv('AMET_OUT')
project_id             <- Sys.getenv('AMET_PROJECT')
cutoff                 <- Sys.getenv('INC_CUTOFF')
start_date             <- Sys.getenv('START_DATE')
end_date               <- Sys.getenv('END_DATE')
write_sitex            <- Sys.getenv('WRITE_SITEX')
run_sitex_flag         <- Sys.getenv('RUN_SITEX')
load_sitex             <- Sys.getenv('LOAD_SITEX')
AMET_species_list      <- Sys.getenv('AMET_SPEC_FILE')

castnet_weekly_flag    <- Sys.getenv('CASTNET_WEEKLY')        # Flag to include CASTNet data in the analysis
castnet_hourly_flag    <- Sys.getenv('CASTNET_HOURLY')
castnet_drydep_flag    <- Sys.getenv('CASTNET_DRYDEP')
castnet_o3_drydep_flag <- Sys.getenv('CASTNET_DRYDEP_O3')
castnet_daily_o3_flag  <- Sys.getenv('CASTNET_DAILY_O3')
improve_flag           <- Sys.getenv('IMPROVE')               # Flag to include IMPROVE data in the analysis
nadp_flag              <- Sys.getenv('NADP')                  # Flag to include NADP data in the analysis
mdn_flag	       <- Sys.getenv('MDN')		      # Flag to include MDN mercury deposition in the analysis
airmon_flag            <- Sys.getenv('AIRMON')                # Flag to include AIRMON data in the analysis
amon_flag	       <- Sys.getenv('AMON')		      # Flag to include NADP AMON data in the analysis
csn_flag               <- Sys.getenv('CSN')                   # Flag to include CSN data in the analysis
aqs_hourly_flag        <- Sys.getenv('AQS_HOURLY')            # Flag to include AQS hourly data in the analysis
aqs_daily_o3_flag      <- Sys.getenv('AQS_DAILY_O3')          # Flag to include AQS 1 and 8 hour max data in the analysis
aqs_daily_flag         <- Sys.getenv('AQS_DAILY')             # Flag to include AQS daily species (pm and gas species)
search_hourly_flag     <- Sys.getenv('SEARCH_HOURLY')         # Flag to include SEARCH data in the analysis
search_daily_flag      <- Sys.getenv('SEARCH_DAILY')          # Flag to include daily SEARCH data in the analysis
aeronet_flag	       <- Sys.getenv('AERONET')		      # Flag to include AERONET AOD data in the analysis
fluxnet_flag	       <- Sys.getenv('FLUXNET')		      # Flag to include FLUXNET data in the analysis
naps_hourly_flag       <- Sys.getenv('NAPS_HOURLY')           # Flag to include Canadians NAPS data (hourly) in analysis
naps_daily_o3_flag     <- Sys.getenv('NAPS_DAILY_O3')
capmon_flag	       <- Sys.getenv('CAPMoN')
noaa_esrl_o3_flag      <- Sys.getenv('NOAA_ESRL_O3')	      # Flag to include NOAA ESRL surface O3 observations in the analysis

emep_hourly_flag       <- Sys.getenv('EMEP_HOURLY')           # Flag to include Europe EMEP data (hourly) in analysis
emep_daily_o3_flag     <- Sys.getenv('EMEP_DAILY_O3')	      # Flag to include Europe EMEP daily O3 data in analysis
emep_daily_flag        <- Sys.getenv('EMEP_DAILY')            # Flag to include Europe EMEP data (daily) in analysis
emep_dep_flag	       <- Sys.getenv('EMEP_DEP')
aurn_hourly_flag       <- Sys.getenv('AURN_HOURLY')	      # Flag to include Europe AURN data (hourly) in analysis
aurn_daily_flag	       <- Sys.getenv('AURN_DAILY')            # Flag to include Europe AURN data (daily) in analysis
airbase_hourly_flag    <- Sys.getenv('AIRBASE_HOURLY')	      # Flag to include Europe AIRBASE data (hourly) in analysis
airbase_daily_flag     <- Sys.getenv('AIRBASE_DAILY')	      # Flag to include Europe AIRBASE data (daily) in analysis
aganet_flag	       <- Sys.getenv('AGANET')		      # Flag to include Europe AGANET data in analysis
admn_flag	       <- Sys.getenv('ADMN')		      # Flag to include Europe ADMN data in analysis
namn_flag	       <- Sys.getenv('NAMN')		      # Flag to include Europe NAMN data in analysis
toar_flag	       <- Sys.getenv('TOAR')

#project_id <- gsub("[.]","_",project_id)

### Check if using old definition names in run script ###
if (castnet_daily_o3_flag == "") {
   castnet_daily_o3_flag <- Sys.getenv('CASTNET_DAILY')
}
if (aqs_daily_o3_flag == "") {
   aqs_daily_o3_flag <- Sys.getenv('AQS_DAILY_MAX')
}
if (castnet_weekly_flag == "") {
   castnet_weekly_flag <- Sys.getenv('CASTNET')
}
#########################################################

O3_obs_factor          <- Sys.getenv('O3_OBS_FACTOR')
O3_mod_factor	       <- Sys.getenv('O3_MOD_FACTOR')
O3_units	       <- Sys.getenv('O3_UNITS')
precip_units           <- Sys.getenv('PRECIP_UNITS')

year <- substr(start_date,1,4)                            # Determine the year from start date

precip_convert <- 1
if (precip_units == "cm") {
   precip_convert <- 10
}

aqs_daily_pm_flag <- Sys.getenv('AQS_DAILY_PM')            # Old flag name to include AQS PM2.5 and PM10 data (daily)
if ((aqs_daily_pm_flag == "y") || (aqs_daily_pm_flag == "Y") || (aqs_daily_pm_flag == "t") || (aqs_daily_pm_flag == "T")) {
   aqs_daily_flag <- 'y'
}

###########################################################

########################################################
### Check which PM names being used in combine file. ###
### Ignored if ncdf4 R library is not installed.     ###
########################################################
PM_MOD_SPEC     <- "ATOTIJ"
PM_FRM_MOD_SPEC <- "ATOTIJ_FRM"
PM10_MOD_SPEC   <- "ATOTIJK"

if(require(ncdf4)) {
   if (Sys.getenv("WRITE_SITEX") == "T") {
      M3_FILE <- Sys.getenv("CONC_FILE_1")
      if (file.exists(M3_FILE)) {
         m3_file_in <- nc_open(M3_FILE)
         var_list <- ncatt_get(m3_file_in,0,"VAR-LIST")
         var_list <- var_list$value
         if(var_list != 0 ) {
            vars <- strsplit(var_list," +")
            if ("PMIJ" %in% vars[[1]]) {
               PM_MOD_SPEC <- "PMIJ"
               PM_FRM_MOD_SPEC <- "PMIJ_FRM"
               PM10_MOD_SPEC <- "PM10"
            }
         }
      }
   }
}
##########################################################

amet_species_list <- Sys.getenv("AQ_SPECIES_LIST")
if (!exists("amet_species_list")) {
   stop("Must set AQ_SPECIES_LIST environment variable")
}
source(amet_species_list)

source_configs <- Sys.getenv("Source_Configs")
if (!exists("Source_Configs")) {
   source_configs <- 'F'
}

if (source_configs == "T") {
   cmaq_home <- Sys.getenv("CMAQ_HOME")
   compiler <- Sys.getenv("compiler")
   source_command_configs <- paste(CMAQ_HOME,"config_cmaq.csh ",compiler,sep="")
}

###########################################################
### Function to create and execute site compare scripts ###
###########################################################

run_sitex <- function(network) {
   ### Start Generic Script Text ###

  header <- paste("#!/bin/csh")
  
  if (source_configs == "T") {
     header <- paste(header,"

     source(",source_command_configs,sep="") 
  }

  header <- paste(header,"

  # Set TABLE TYPE
  setenv TABLE_TYPE ",table_type,"

  # Specify the variable names used in your observation inputs
  # and model output files for each of the species you are analyzing below.
  #
  # variable format:
  #    Obs_expression, Obs_units, [Mod_expression], [Mod_unit], [Variable_name]
  #
  # The expression is in the form:
  #       [factor1]*Obs_name1 [+][-] [factor2]*Obs_name2 ...",sep="")

  time_settings <- paste("  ### End Species List ###

  ## define time window
  setenv START_DATE ",start_date,"
  setenv END_DATE ",end_date,"
  setenv START_TIME 0
  setenv END_TIME 230000

  ## define the PRECIP variable
  setenv PRECIP RT

  ## adjust for daylight savings
  setenv APPLY_DLS N

  ## set missing value string
  setenv MISSING '-999'

  ## Projection sphere type (use type #20 to match CMAQ)
  setenv IOAPI_ISPH 20

  ## Time Shift for dealing with aconc files ##
  setenv TIME_SHIFT ",time_shift,"

  #############################################################
  #  Input files
  #############################################################
  # ioapi input files containing VNAMES (max of 10)
",sep="")

   final_wrapup <- paste("

  #  SITE FILE containing site-id, longitude, latitude (tab delimited)
  setenv SITE_FILE ",site_file,"

  # : input table (exported file from Excel)
  #   containing site-id, time-period, and data fields
  setenv IN_TABLE ",ob_file,"

  #############################################################
  #  Output files
  #############################################################

  #  output table (tab delimited text file importable to Excel)
  setenv OUT_TABLE ",data_dir,"/",network,"_",project_id,".csv

  ",EXEC,sep="")

### End Generic Script Text ###

### Start Creation of Script Text ###

   dat <- paste(header,species_list[network],sep="")
   if ((cutoff == "y") || (cutoff == "Y") || (cutoff == "t") || (cutoff == "T")) {
      dat <-paste(dat,species_list_cutoff[network],sep="")
   }
   if ((use_AE6 == "y") || (use_AE6 == "Y") || (use_AE6 == "t") || (use_AE6 == "T")) {
      dat <- paste(dat,species_list_AE6[network],sep="")
   }
   j <- 1
   m3_files=""
   M3_FILE <- Sys.getenv('CONC_FILE_1')
   if ((network == "NADP") || (network == "CAPMoN") || (network == "MDN") || (network == "CASTNET_Drydep") || (network == "CASTNET_Drydep_O3") || (network == "EMEP_Dep")) {
      M3_FILE <- Sys.getenv('DEP_FILE_1')
   }
   if (network == "TOAR") {
      M3_FILE <- Sys.getenv('HR2DAY_FILE_1')
   }
   if (network == "AERONET") {
      M3_FILE <-Sys.getenv('COLUMN_FILE_1')
   }
   while (M3_FILE != "") {
      m3_files <- paste(m3_files,"  setenv M3_FILE_",j," ",M3_FILE,"
",sep="")

      j <- j+1
       
      if ((network == "NADP") || (network == "CAPMoN") || (network == "MDN") || (network == "CASTNET_Drydep") || (network == "CASTNET_Drydep_O3") || (network == "EMEP_Dep")) {
         m3_file_name <- paste("DEP_FILE_",j,sep="")
         M3_FILE <- Sys.getenv(m3_file_name)
      }
      else {
         m3_file_name <- paste("CONC_FILE_",j,sep="")
         M3_FILE <- Sys.getenv(m3_file_name)
      }
#      if ((network == "TOAR") && (M3_FILE != "")) {
      if (network == "TOAR") {
         m3_file_name <- paste("HR2DAY_FILE_",j,sep="")
         M3_FILE <- Sys.getenv(m3_file_name)
#         M3_FILE <- paste(M3_FILE,".hr2day",sep="")
      }
      if (network == "AERONET") {
         m3_file_name <- paste("COLUMN_FILE_",j,sep="")
         M3_FILE <- Sys.getenv(m3_file_name)
      }
   }
   dat <- paste(dat,time_settings,m3_files,final_wrapup,sep="")

   ### Open, write and close site compare script ###
   if ((write_sitex == "y") || (write_sitex == "Y") || (write_sitex == "t") || (write_sitex == "T")) {
      filename <- paste(data_dir,"/sitex_",network,"_",project_id,".csh",sep="")
      write.table(dat,file=filename,append=F,col.names=F,row.names=F,sep="",quote=F)
      cat(paste("\nWrote site compare script for network ",network,".\n\n",sep=" "))
   }
   #########################################

   ### Execute site compare script and load output into database ###
   if ((run_sitex_flag == "y") || (run_sitex_flag == "Y") || (run_sitex_flag == "t") || (run_sitex_flag == "T")) {
      chmod.command <- paste("chmod +x ",data_dir,"/sitex_",network,"_",project_id,".csh",sep="")
      system(chmod.command)
      cat(paste(" Running site compare for network ",network,".Depending on length of time being extracted, this may take a while.\n\n",sep=" "))
      run.command <- paste(data_dir,"/sitex_",network,"_",project_id,".csh",sep="")
      system(run.command)
      cat(paste("Finished running site compare for network ",network,".\n\n",sep=" "))
   }
   if ((load_sitex == "y") || (load_sitex == "Y") || (load_sitex == "t") || (load_sitex == "T")) {
      load.command <- paste("R --no-save --slave --args < ",amet_base,"/R_db_code/AQ_add_aq2dbase.R ",mysql_login," ",mysql_pass," ",project_id," ",network," ",data_dir,"/",network,"_",project_id,".csv",sep="")
      system(load.command)
      cat(paste("Finshed populating database for network ",network,"\n",sep=" "))
   }
   #################################################################
}
### End Creation of Script Text ###

##############################
### End function run_sitex ###
##############################


###############################################
### Create and Execute Site Compare Scripts ###
###############################################

cat('IMPROVE Flag = ',improve_flag)
cat('\nCSN Flag = ',csn_flag)
cat('\nCASTNET Weekly Flag = ',castnet_weekly_flag)
cat('\nCASTNET DryDep Flag = ',castnet_drydep_flag)
cat('\nCASTNET O3 DryDep Flag = ',castnet_o3_drydep_flag)
cat('\nCASTNET Hourly Flag = ',castnet_hourly_flag)
cat('\nCASTNET Daily O3 (Max) Flag = ',castnet_daily_o3_flag)
cat('\nNADP Flag = ',nadp_flag)
cat('\nMDN Flag = ',mdn_flag)
cat('\nAQS Hourly Flag = ',aqs_hourly_flag)
cat('\nAQS Daily O3 (Max) Flag = ',aqs_daily_o3_flag)
cat('\nAQS Daily Flag = ',aqs_daily_flag)
cat('\nSEARCH Hourly Flag = ',search_hourly_flag)
cat('\nSEARCH Daily Flag = ',search_daily_flag)
cat('\nAIRMON Flag = ',airmon_flag)
cat('\nAMON Flag = ',amon_flag)
cat('\nAERONET Flag = ',aeronet_flag)
cat('\nFLUXNET Flag = ',fluxnet_flag)
cat('\nNAPS Flag = ',naps_hourly_flag)
cat('\nNAPS Daily O3 Flag = ',naps_daily_o3_flag)
cat('\nNOAA ESRL O3 Flag = ',noaa_esrl_o3_flag)
cat('\nEMEP Hourly Flag = ',emep_hourly_flag)
cat('\nEMEP Daily O3 Flag = ',emep_daily_o3_flag)
cat('\nEMEP Daily Flag = ',emep_daily_flag)
cat('\nEMEP Dep Flag = ',emep_dep_flag)
cat('\nAURN Hourly Flag = ',aurn_hourly_flag)
cat('\nAURN Daily Flag = ',aurn_daily_flag)
cat('\nAIRBASE Hourly Flag = ',airbase_hourly_flag)
cat('\nAIRBASE Daily Flag = ',airbase_daily_flag)
cat('\nADMN Flag = ',admn_flag)
cat('\nNAMN Flag = ',namn_flag)
cat('\nTOAR Flag = ',toar_flag,'\n')

if ((improve_flag == "y") || (improve_flag == "Y") || (improve_flag == "t") || (improve_flag == "T")) {
   table_type    <- "IMPROVE"
   network       <- "IMPROVE"
   site_file     <- paste(obs_data_dir,site_file_directory,"/IMPROVE",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/IMPROVE_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((csn_flag == 'y') || (csn_flag == 'Y') || (csn_flag == 't') || (csn_flag == 'T')) {
   table_type    <- "CASTNET"
   network       <- "CSN"
   site_file     <- paste(obs_data_dir,site_file_directory,"/AQS",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/AQS_CSN_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((castnet_weekly_flag == "y") || (castnet_weekly_flag == "Y") || (castnet_weekly_flag == "t") || (castnet_weekly_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "CASTNET"
   site_file     <- paste(obs_data_dir,site_file_directory,"/CASTNET",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/CASTNET_weekly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((castnet_hourly_flag == "y") || (castnet_hourly_flag == "Y") || (castnet_hourly_flag == "t") || (castnet_hourly_flag == "T")) {
   table_type    <- "MET"
   network       <- "CASTNET_Hourly"
   site_file     <- paste(obs_data_dir,site_file_directory,"/CASTNET",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/CASTNET_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((castnet_daily_o3_flag == "y") || (castnet_daily_o3_flag == "Y") || (castnet_daily_o3_flag == "t") || (castnet_daily_o3_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "CASTNET_Daily"
   site_file     <- paste(obs_data_dir,site_file_directory,"/CASTNET",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/CASTNET_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex_daily
   run_sitex(network)
}

if ((castnet_drydep_flag == "y") || (castnet_drydep_flag == "Y") || (castnet_drydep_flag == "t") || (castnet_drydep_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "CASTNET_Drydep"
   site_file     <- paste(obs_data_dir,site_file_directory,"/CASTNET",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/CASTNET_weekly_drydep_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((castnet_o3_drydep_flag == "y") || (castnet_o3_drydep_flag == "Y") || (castnet_o3_drydep_flag == "t") || (castnet_o3_drydep_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "CASTNET_Drydep_O3"
   site_file     <- paste(obs_data_dir,site_file_directory,"/CASTNET",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/CASTNET_hourly_drydep_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((nadp_flag == "y") || (nadp_flag == "Y") || (nadp_flag == "t") || (nadp_flag == "T")) {
   table_type    <- "NADP"
   network       <- "NADP"
   site_file     <- paste(obs_data_dir,site_file_directory,"/NADP",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/NADP_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((capmon_flag == "y") || (capmon_flag == "Y") || (capmon_flag == "t") || (capmon_flag == "T")) {
   table_type    <- "NADP"
   network       <- "CAPMoN"
   site_file     <- paste(obs_data_dir,site_file_directory,"/CAPMoN",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/CAPMoN_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((mdn_flag == "y") || (mdn_flag == "Y") || (mdn_flag == "t") || (mdn_flag == "T")) {
   table_type    <- "NADP"
   network       <- "MDN"
   site_file     <- paste(obs_data_dir,site_file_directory,"/MDN",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/MDN_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((amon_flag == "y") || (amon_flag == "Y") || (amon_flag == "t") || (amon_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "AMON"
   site_file     <- paste(obs_data_dir,site_file_directory,"/AMON",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/AMON_data.csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((aqs_daily_o3_flag == "y") || (aqs_daily_o3_flag == "Y") || (aqs_daily_o3_flag == "t") || (aqs_daily_o3_flag == "T")) {
   table_type    <- ""
   network       <- "AQS_Daily_O3"
   site_file     <- paste(obs_data_dir,site_file_directory,"/AQS",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/AQS_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex_daily
   run_sitex(network)
}

if ((aqs_daily_flag == "y") || (aqs_daily_flag == "Y") || (aqs_daily_flag == "t") || (aqs_daily_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "AQS_Daily"
   site_file     <- paste(obs_data_dir,site_file_directory,"/AQS",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/AQS_daily_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}
if ((aqs_hourly_flag == "y") || (aqs_hourly_flag == "Y") || (aqs_hourly_flag == "t") || (aqs_hourly_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "AQS_Hourly"
   site_file     <- paste(obs_data_dir,site_file_directory,"/AQS",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/AQS_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((search_daily_flag == "y") || (search_daily_flag == "Y") || (search_daily_flag == "t") || (search_daily_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "SEARCH_Daily"
   site_file     <- paste(obs_data_dir,site_file_directory,"/SEARCH",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/SEARCH_daily_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((search_hourly_flag == "y") || (search_hourly_flag == "Y") || (search_hourly_flag == "t") || (search_hourly_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "SEARCH_Hourly"
   site_file     <- paste(obs_data_dir,site_file_directory,"/SEARCH",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/SEARCH_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((aeronet_flag == "y") || (aeronet_flag == "Y") || (aeronet_flag == "t") || (aeronet_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "AERONET"
   site_file     <- paste(obs_data_dir,site_file_directory,"/AERONET",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/AERONET_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((fluxnet_flag == "y") || (fluxnet_flag == "Y") || (fluxnet_flag == "t") || (fluxnet_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "FLUXNET"
   site_file     <- paste(obs_data_dir,site_file_directory,"/FLUXNET",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/FLUXNET_US_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((naps_hourly_flag == "y") || (naps_hourly_flag == "Y") || (naps_hourly_flag == "t") || (naps_hourly_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "NAPS"
   site_file     <- paste(obs_data_dir,site_file_directory,"/NAPS",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/NAPS_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((naps_daily_o3_flag == "y") || (naps_daily_o3_flag == "Y") || (naps_daily_o3_flag == "t") || (naps_daily_o3_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "NAPS_Daily_O3"
   site_file     <- paste(obs_data_dir,site_file_directory,"/NAPS",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/NAPS_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex_daily
   run_sitex(network)
}

if ((noaa_esrl_o3_flag == "y") || (noaa_esrl_o3_flag == "Y") || (noaa_esrl_o3_flag == "t") || (noaa_esrl_o3_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "NOAA_ESRL_O3"
   site_file     <- paste(obs_data_dir,site_file_directory,"/NOAA_ESRL",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/NOAA_ESRL_surfaceo3_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((emep_hourly_flag == "y") || (emep_hourly_flag == "Y") || (emep_hourly_flag == "t") || (emep_hourly_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "EMEP_Hourly"
   site_file     <- paste(obs_data_dir,site_file_directory,"/EMEP",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/EMEP_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((emep_daily_o3_flag == "y") || (emep_daily_o3_flag == "Y") || (emep_daily_o3_flag == "t") || (emep_daily_o3_flag == "T")) {
   table_type    <- ""
   network       <- "EMEP_Daily_O3"
   site_file     <- paste(obs_data_dir,site_file_directory,"/EMEP",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/EMEP_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex_daily
   run_sitex(network)
}

if ((emep_daily_flag == "y") || (emep_daily_flag == "Y") || (emep_daily_flag == "t") || (emep_daily_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "EMEP_Daily"
   site_file     <- paste(obs_data_dir,site_file_directory,"/EMEP_Daily",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/EMEP_daily_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((emep_dep_flag == "y") || (emep_dep_flag == "Y") || (emep_dep_flag == "t") || (emep_dep_flag == "T")) {
   table_type    <- "NADP"
   network       <- "EMEP_Dep"
   site_file     <- paste(obs_data_dir,site_file_directory,"/EMEP_Dep",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/EMEP_daily_dep_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((aurn_hourly_flag == "y") || (aurn_hourly_flag == "Y") || (aurn_hourly_flag == "t") || (aurn_hourly_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "AURN_Hourly"
   site_file     <- paste(obs_data_dir,site_file_directory,"/AURN",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/AURN_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((aurn_daily_flag == "y") || (aurn_daily_flag == "Y") || (aurn_daily_flag == "t") || (aurn_daily_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "AURN_Daily"
   site_file     <- paste(obs_data_dir,site_file_directory,"/AURN",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/AURN_daily_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((airbase_hourly_flag == "y") || (airbase_hourly_flag == "Y") || (airbase_hourly_flag == "t") || (airbase_hourly_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "AIRBASE"
   site_file     <- paste(obs_data_dir,site_file_directory,"/AIRBASE",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/AIRBASE_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((airbase_daily_flag == "y") || (airbase_daily_flag == "Y") || (airbase_daily_flag == "t") || (airbase_daily_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "AIRBASE_Daily"
   site_file     <- paste(obs_data_dir,site_file_directory,"/AIRBASE",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/AIRBASE_daily_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((aganet_flag == "y") || (aganet_flag == "Y") || (aganet_flag == "t") || (aganet_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "AGANET"
   site_file     <- paste(obs_data_dir,site_file_directory,"/AGANET",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/AGANET_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((admn_flag == "y") || (admn_flag == "Y") || (admn_flag == "t") || (admn_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "ADMN"
   site_file     <- paste(obs_data_dir,site_file_directory,"/ADMN",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/ADMN_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((namn_flag == "y") || (namn_flag == "Y") || (namn_flag == "t") || (namn_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "NAMN"
   site_file     <- paste(obs_data_dir,site_file_directory,"/NAMN",site_file_name,sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/NAMN_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}
if ((toar_flag == "y") || (toar_flag == "Y") || (toar_flag == "t") || (toar_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "TOAR"
   site_file     <- paste(obs_data_dir,site_file_directory,"/TOAR_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/",year,"/TOAR_daily_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}
cat("\n")
