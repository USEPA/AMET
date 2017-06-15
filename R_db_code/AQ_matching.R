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
#                 AQ_species_list.R			 #
#                                                        #
#       PURPOSE: Run Site Compare and then put the       #
#                output into the MYSQL database for AMET #
#                                                        #
#                                                        #
##------------------------------------------------------##

require(RMySQL)

amet_base        <- Sys.getenv('AMETBASE')
base.command     <- paste(amet_base,"/configure/amet-config.R",sep="")

source(base.command)

args              <- commandArgs(2)
amet_login        <- args[1]
amet_pass         <- args[2]

dbase                  <- Sys.getenv('AMET_DATABASE')
obs_data_dir           <- Sys.getenv('AMET_OBS')
#if (obs_data_dir_in != "") {
#   obs_data_dir <- obs_data_dir_in
#}

use_AE6                <- Sys.getenv('INC_AERO6_SPECIES')
time_shift             <- Sys.getenv('TIME_SHIFT')
run_dir                <- Sys.getenv('AMET_OUT')
project_id             <- Sys.getenv('AMET_PROJECT')
cutoff                 <- Sys.getenv('INC_CUTOFF')
start_date             <- Sys.getenv('START_DATE')
end_date               <- Sys.getenv('END_DATE')
write_sitex            <- Sys.getenv('WRITE_SITEX')
run_sitex_flag         <- Sys.getenv('RUN_SITEX')
load_sitex             <- Sys.getenv('LOAD_SITEX')
AMET_species_list      <- Sys.getenv('AMET_SPECIES_FILE')

castnet_flag           <- Sys.getenv('CASTNET')               # Flag to include CASTNet data in the analysis
castnet_hourly_flag    <- Sys.getenv('CASTNET_HOURLY')
castnet_drydep_flag    <- Sys.getenv('CASTNET_DRYDEP')
castnet_daily_O3_flag  <- Sys.getenv('CASTNET_DAILY_O3')
improve_flag           <- Sys.getenv('IMPROVE')               # Flag to include IMPROVE data in the analysis
nadp_flag              <- Sys.getenv('NADP')                  # Flag to include NADP data in the analysis
mdn_flag	       <- Sys.getenv('MDN')		      # Flag to include MDN mercury deposition in the analysis
airmon_flag            <- Sys.getenv('AIRMON')                # Flag to include AIRMON data in the analysis
amon_flag	       <- Sys.getenv('AMON')		      # Flag to include NADP AMON data in the analysis
csn_flag               <- Sys.getenv('CSN')                   # Flag to include CSN data in the analysis
aqs_hourly_flag        <- Sys.getenv('AQS_HOURLY')            # Flag to include AQS hourly data in the analysis
aqs_daily_O3_flag      <- Sys.getenv('AQS_DAILY_O3')          # Flag to include AQS 1 and 8 hour max data in the analysis
aqs_daily_flag         <- Sys.getenv('AQS_DAILY')             # Flag to include AQS daily species (pm and gas species)
search_hourly_flag     <- Sys.getenv('SEARCH_HOURLY')         # Flag to include SEARCH data in the analysis
search_daily_flag      <- Sys.getenv('SEARCH_DAILY')          # Flag to include daily SEARCH data in the analysis
aeronet_flag	       <- Sys.getenv('AERONET')		      # Flag to include AERONET AOD data in the analysis
fluxnet_flag	       <- Sys.getenv('FLUXNET')		      # Flag to include FLUXNET data in the analysis
naps_hourly_flag       <- Sys.getenv('NAPS_HOURLY')           # Flag to include Canadians NAPS data (hourly) in analysis

emep_hourly_flag       <- Sys.getenv('EMEP_HOURLY')           # Flag to include Europe EMEP data (hourly) in analysis
emep_daily_flag        <- Sys.getenv('EMEP_DAILY')            # Flag to include Europe EMEP data (daily) in analysis
aurn_hourly_flag       <- Sys.getenv('AURN_HOURLY')	      # Flag to include Europe AURN data (hourly) in analysis
aurn_daily_flag	       <- Sys.getenv('AURN_DAILY')            # Flag to include Europe AURN data (daily) in analysis
airbase_hourly_flag    <- Sys.getenv('AIRBASE_HOURLY')	      # Flag to include Europe AIRBASE data (hourly) in analysis
airbase_daily_flag     <- Sys.getenv('AIRBASE_DAILY')	      # Flag to include Europe AIRBASE data (daily) in analysis
aganet_flag	       <- Sys.getenv('AGANET')		      # Flag to include Europe AGANET data in analysis
admn_flag	       <- Sys.getenv('ADMN')		      # Flag to include Europe ADMN data in analysis
namn_flag	       <- Sys.getenv('NAMN')		      # Flag to include Europe NAMN data in analysis

### Check if using old definition names in run script ###
if (castnet_daily_O3_flag == "") {
   castnet_daily_O3_flag <- Sys.getenv('CASTNET_DAILY')
}
if (aqs_daily_O3_flag == "") {
   aqs_daily_O3_flag <- Sys.getenv('AQS_DAILY_MAX')
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

if (time_shift == "") { time_shift <- 1 }     # Default to 1 (aconc) if time_shift value is not set in the environment

source(AMET_species_list)
###########################################################

###########################################################
### Function to create and execute site compare scripts ###
###########################################################

run_sitex <- function(network) {
   ### Start Generic Script Text ###

   header <- paste("#!/bin/csh

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

  ## Projection sphere type (use type #19 to match CMAQ)
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
  setenv OUT_TABLE ",run_dir,"/",network,"_",project_id,".csv

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
   if ((network == "NADP") || (network == "MDN") || (network == "CASTNET_Drydep")) {
      M3_FILE <- Sys.getenv('DEP_FILE_1')
   }
   else {
      M3_FILE <- Sys.getenv('CONC_FILE_1')
   }
   while (M3_FILE != "") {
      m3_files <- paste(m3_files,"  setenv M3_FILE_",j," ",M3_FILE,"
",sep="")

      j <- j+1
      if ((network == "NADP") || (network == "MDN") || (network == "CASTNET_Drydep")) {
         m3_file_name <- paste("DEP_FILE_",j,sep="")
         M3_FILE <- Sys.getenv(m3_file_name)
      }
      else {
         m3_file_name <- paste("CONC_FILE_",j,sep="")
         M3_FILE <- Sys.getenv(m3_file_name)
      }
   }
   dat <- paste(dat,time_settings,m3_files,final_wrapup,sep="")

   ### Open, write and close site compare script ###
   if ((write_sitex == "y") || (write_sitex == "Y") || (write_sitex == "t") || (write_sitex == "T")) {
      filename <- paste(run_dir,"/sitex_",network,"_",project_id,".csh",sep="")
      write.table(dat,file=filename,append=F,col.names=F,row.names=F,sep="",quote=F)
      cat(paste("\nWrote site compare script for network ",network,sep=" "))
   }
   #########################################

   ### Execute site compare script and load output into database ###
   if ((run_sitex_flag == "y") || (run_sitex_flag == "Y") || (run_sitex_flag == "t") || (run_sitex_flag == "T")) {
      chmod.command <- paste("chmod +x ",run_dir,"/sitex_",network,"_",project_id,".csh",sep="")
      system(chmod.command)
      cat(paste("Running site compare for network ",network,". Depending on length of time being extracted, this may take a while\n",sep=" "))
      run.command <- paste(run_dir,"/sitex_",network,"_",project_id,".csh",sep="")
      system(run.command)
      cat(paste("Finished running site compare for network ",network,"\n\n",sep=" "))
   }
   if ((load_sitex == "y") || (load_sitex == "Y") || (load_sitex == "t") || (load_sitex == "T")) {
      load.command <- paste("R --no-save --slave --args < ",amet_base,"/R_db_code/AQ_add_aq2dbase.R ",amet_login," ",amet_pass," ",project_id," ",network," ",run_dir,"/",network,"_",project_id,".csv",sep="")
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
cat('\nCASTNET Flag = ',castnet_flag)
cat('\nCASTNET DryDep Flag = ',castnet_drydep_flag)
cat('\nCASTNET Hourly Flag = ',castnet_hourly_flag)
cat('\nCASTNET Daily O3 (Max) Flag = ',castnet_daily_O3_flag)
cat('\nNADP Flag = ',nadp_flag)
cat('\nMDN Flag = ',mdn_flag)
cat('\nAQS Hourly Flag = ',aqs_hourly_flag)
cat('\nAQS Daily O3 (Max) Flag = ',aqs_daily_O3_flag)
cat('\nAQS Daily Flag = ',aqs_daily_flag)
cat('\nSEARCH Hourly Flag = ',search_hourly_flag)
cat('\nSEARCH Daily Flag = ',search_daily_flag)
cat('\nAIRMON Flag = ',airmon_flag)
cat('\nAMON Flag = ',amon_flag)
cat('\nAERONET Flag = ',aeronet_flag)
cat('\nFLUXNET Flag = ',fluxnet_flag)
cat('\nNAPS Flag = ',naps_hourly_flag)
cat('\nEMEP Hourly Flag = ',emep_hourly_flag)
cat('\nEMEP Daily Flag = ',emep_daily_flag)
cat('\nAURN Hourly Flag = ',aurn_hourly_flag)
cat('\nAURN Daily Flag = ',aurn_daily_flag)
cat('\nAIRBASE Hourly Flag = ',airbase_hourly_flag)
cat('\nAIRBASE Daily Flag = ',airbase_daily_flag)
cat('\nADMN Flag = ',admn_flag)
cat('\nNAMN Flag = ',namn_flag,'\n')

if ((improve_flag == "y") || (improve_flag == "Y") || (improve_flag == "t") || (improve_flag == "T")) {
   table_type    <- "IMPROVE"
   network       <- "IMPROVE"
   site_file     <- paste(obs_data_dir,"/site_files/IMPROVE_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/IMPROVE_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((csn_flag == 'y') || (csn_flag == 'Y') || (csn_flag == 't') || (csn_flag == 'T')) {
   table_type    <- "STN"
   network       <- "CSN"
   site_file     <- paste(obs_data_dir,"/site_files/AQS_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/CSN_data_",year,".csv",sep="")
   if (year > 2010) {
      ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/CSN_data_",year,"_VIEWS.csv",sep="")
   }
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((castnet_flag == "y") || (castnet_flag == "Y") || (castnet_flag == "t") || (castnet_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "CASTNET"
   site_file     <- paste(obs_data_dir,"/site_files/CASTNET_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/CASTNET_weekly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((castnet_hourly_flag == "y") || (castnet_hourly_flag == "Y") || (castnet_hourly_flag == "t") || (castnet_hourly_flag == "T")) {
   table_type    <- "MET"
   network       <- "CASTNET_Hourly"
   site_file     <- paste(obs_data_dir,"/site_files/CASTNET_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/CASTNET_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((castnet_daily_O3_flag == "y") || (castnet_daily_O3_flag == "Y") || (castnet_daily_O3_flag == "t") || (castnet_daily_O3_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "CASTNET_Daily"
   site_file     <- paste(obs_data_dir,"/site_files/CASTNET_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/CASTNET_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex_daily
   run_sitex(network)
}

if ((castnet_drydep_flag == "y") || (castnet_drydep_flag == "Y") || (castnet_drydep_flag == "t") || (castnet_drydep_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "CASTNET_Drydep"
   site_file     <- paste(obs_data_dir,"/site_files/CASTNET_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/CASTNET_weekly_drydep_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((nadp_flag == "y") || (nadp_flag == "Y") || (nadp_flag == "t") || (nadp_flag == "T")) {
   table_type    <- "NADP"
   network       <- "NADP"
   site_file     <- paste(obs_data_dir,"/site_files/NADP_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/NADP_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((mdn_flag == "y") || (mdn_flag == "Y") || (mdn_flag == "t") || (mdn_flag == "T")) {
   table_type    <- "NADP"
   network       <- "MDN"
   site_file     <- paste(obs_data_dir,"/site_files/MDN_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/All_Years/MDN_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((amon_flag == "y") || (amon_flag == "Y") || (amon_flag == "t") || (amon_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "AMON"
   site_file     <- paste(obs_data_dir,"/site_files/AMON_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/All_Years/AMON_data.csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((aqs_daily_O3_flag == "y") || (aqs_daily_O3_flag == "Y") || (aqs_daily_O3_flag == "t") || (aqs_daily_O3_flag == "T")) {
   table_type    <- ""
   network       <- "AQS_Daily_O3"
   site_file     <- paste(obs_data_dir,"/site_files/AQS_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/AQS_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex_daily
   run_sitex(network)
}

if ((aqs_daily_flag == "y") || (aqs_daily_flag == "Y") || (aqs_daily_flag == "t") || (aqs_daily_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "AQS_Daily"
   site_file     <- paste(obs_data_dir,"/site_files/AQS_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/AQS_daily_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}
if ((aqs_hourly_flag == "y") || (aqs_hourly_flag == "Y") || (aqs_hourly_flag == "t") || (aqs_hourly_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "AQS_Hourly"
   site_file     <- paste(obs_data_dir,"/site_files/AQS_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/AQS_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((search_daily_flag == "y") || (search_daily_flag == "Y") || (search_daily_flag == "t") || (search_daily_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "SEARCH_Daily"
   site_file     <- paste(obs_data_dir,"/site_files/SEARCH_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/SEARCH_daily_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((search_hourly_flag == "y") || (search_hourly_flag == "Y") || (search_hourly_flag == "t") || (search_hourly_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "SEARCH_Hourly"
   site_file     <- paste(obs_data_dir,"/site_files/SEARCH_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/SEARCH_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((aeronet_flag == "y") || (aeronet_flag == "Y") || (aeronet_flag == "t") || (aeronet_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "AERONET"
   site_file     <- paste(obs_data_dir,"/site_files/AERONET_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/AERONET_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((fluxnet_flag == "y") || (fluxnet_flag == "Y") || (fluxnet_flag == "t") || (fluxnet_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "FLUXNET"
   site_file     <- paste(obs_data_dir,"/site_files/FLUXNET_sites_us.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/FLUXNET_US_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((naps_hourly_flag == "y") || (naps_hourly_flag == "Y") || (naps_hourly_flag == "t") || (naps_hourly_flag == "T")) {
   table_type    <- "CASTNET"
   network       <- "NAPS"
   site_file     <- paste(obs_data_dir,"/site_files/NAPS_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/NA_Data/",year,"/NAPS_hourly_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((emep_hourly_flag == "y") || (emep_hourly_flag == "Y") || (emep_hourly_flag == "t") || (emep_hourly_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "EMEP_Hourly"
   site_file     <- paste(obs_data_dir,"/site_files/EMEP_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/EU_Data/",year,"/EMEP_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((emep_daily_flag == "y") || (emep_daily_flag == "Y") || (emep_daily_flag == "t") || (emep_daily_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "EMEP_Daily"
   site_file     <- paste(obs_data_dir,"/site_files/EMEP_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/EU_Data/",year,"/EMEP_daily_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((aurn_hourly_flag == "y") || (aurn_hourly_flag == "Y") || (aurn_hourly_flag == "t") || (aurn_hourly_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "AURN_Hourly"
   site_file     <- paste(obs_data_dir,"/site_files/AURN_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/EU_Data/",year,"/AURN_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((aurn_daily_flag == "y") || (aurn_daily_flag == "Y") || (aurn_daily_flag == "t") || (aurn_daily_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "AURN_Daily"
   site_file     <- paste(obs_data_dir,"/site_files/AURN_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/EU_Data/",year,"/AURN_daily_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((airbase_hourly_flag == "y") || (airbase_hourly_flag == "Y") || (airbase_hourly_flag == "t") || (airbase_hourly_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "AIRBASE"
   site_file     <- paste(obs_data_dir,"/site_files/AIRBASE_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/EU_Data/",year,"/AIRBASE_hourly_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((airbase_daily_flag == "y") || (airbase_daily_flag == "Y") || (airbase_daily_flag == "t") || (airbase_daily_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "AIRBASE_Daily"
   site_file     <- paste(obs_data_dir,"/site_files/AIRBASE_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/EU_Data/",year,"/AIRBASE_daily_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((aganet_flag == "y") || (aganet_flag == "Y") || (aganet_flag == "t") || (aganet_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "AGANET"
   site_file     <- paste(obs_data_dir,"/site_files/AGANET_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/EU_Data/",year,"/AGANET_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((admn_flag == "y") || (admn_flag == "Y") || (admn_flag == "t") || (admn_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "ADMN"
   site_file     <- paste(obs_data_dir,"/site_files/ADMN_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/EU_Data/",year,"/ADMN_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}

if ((namn_flag == "y") || (namn_flag == "Y") || (namn_flag == "t") || (namn_flag == "T")) {
   table_type    <- "SEARCH"
   network       <- "NAMN"
   site_file     <- paste(obs_data_dir,"/site_files/NAMN_sites.txt",sep="")
   ob_file       <- paste(obs_data_dir,"/EU_Data/",year,"/NAMN_data_",year,".csv",sep="")
   EXEC          <- EXEC_sitex
   run_sitex(network)
}
cat("\n")
