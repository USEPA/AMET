#!/bin/csh
####################################################################################
#                          USER CONFIGURATION

# Main AMET directory location. Can be defined explicity here or in user setenv for universal use.
setenv AMETBASE   /home/user/AMET

# Define Database and Password from argument input
setenv MYSQL_LOGIN   my_login_id
setenv AMET_DATABASE user_database
setenv MYSQL_SERVER  mysql.server.gov
setenv MYSQL_CONFIG  $AMETBASE/configure/amet-config.R

# Root directory of BSRN/SURFRAD obs (same as MADIS). Note that this directory should
# contain a subdirectory "bsrn" where this radiation obs dataset (unzipped)
# BSRN/SURFRAD directory configuration: $MADISBASE/bsrn 
setenv MADISBASE $AMETBASE/obs/MET

# A unique AMETPROJECT name for the simulation to evaluated. 
# This will be used to organize all scripts/analyses and create the database tables
# that store all model-observation pairs of data for access by analysis scripts.
# NEW PROJECTS are automatically created in the database if not existing.
# RUN_DESCRIPTION: Short description of the model run to keep track its details.
setenv AMET_PROJECT    metExample_wrf 
setenv RUN_DESCRIPTION "WRF release test dataset."

# Is this a model forecast where intial date/time and forecast hour should be tracked?
setenv FORECAST F

# Meteorological model output file location and control. The files that can be listed with
# location below. A wildcard (*) is added in the script to get list of outputs.
setenv METOUTPUT $AMETBASE/model_data/MET/$AMET_PROJECT/wrfout_subset

# Radiation dataset to match with MPAS, WRF or MCIP -- Only shortwave radiation enabled
# Options: "bsrn" or "srad"
# BSRN is a global dataset with a lantency of months
# SURFRAD is the US-based only SURFRAD Network that is real-time
# Note: both datasets are downloaded into the $MADISBASE/bsrn directory (different naming)
setenv RADIATION_DSET bsrn 

# Interpolation Method for WRF Model: 1 - Nearest Neighbor, 2 - Bi-Linear
# For MPAS, a built in barycentric interpolation is the only option, so this setting
# does not apply.
setenv INTERP_METHOD 2

# Time +/- window averaging of 1 min solar radiation measurments. 5 would be +/-
# 5 min (11 min average) from the closest observation to model time.
setenv OBS_AVG_WINDOW_MIN 5

# Skip Index specification. The first number is for the first model output, the second for all following.
# This index is where AMET skips to in order to jump over an initial time period, or past model
# output that may have already been matched. Typical values are 2 and 1, so initial time is skipped
# in the first model output, but not for all the following outputs.
setenv SKIPIND "1 1"

# If T, the master stations table in database will be updated with any new observation site metadata. May be wise to 
# turn on from time to time as new sites around the world are added to the MADIS database. 
# It is not neccessary to use frequently. It is mandantory to use for a new database if you want
# the ability to plot spatial statistics or use any windowing of a domain in statistics specs.
setenv UPDATE_SITES T 

# This control can dramatically improve speed, especially smaller domains where mesonet sites are matched.
# It is the max number of model times the site list update is done. Typically all obs sites within the
# domain exist in the first few hours of MADIS obs files. When, for example, you have a small domain that
# may have 100 obs sites, it slows down the matching to wade through 25,000 records for any new sites. If
# one does it only for the first 6 hours to build a site list, the script speeds up considerably because
# it is the most time consuming part of AMET and that step is bypassed.
setenv MAX_TIMES_SITE_CHECK 1

# Automatic BSRN and SURFRAD Obs FTP Option. BSRN requires log/pass to access the FTP server.
# SURFRAD is anonymous with user's work email for their tracking statistics.
# Also, users must have MADIS directory structure in place and MADISBASE pointing to that directory.
# Current BSRN server is defined below. Note: only observation within the domain are downloaded.
# Current NOAA SurfRad server defined in the case of srad option.
# Both observation dataset are downloaded into MADISBASE/bsrn directory for consolidation.
setenv AUTOFTP T

if (${RADIATION_DSET} == "bsrn")  then
  setenv RAD_SERVER ftp://ftp.bsrn.awi.de
  setenv RAD_LOGIN  bsrnftp
  setenv RAD_PASS   bsrn1
endif

if (${RADIATION_DSET} == "srad")  then
  setenv RAD_SERVER https://gml.noaa.gov/aftp/data/radiation/surfrad
  setenv RAD_LOGIN  anonymous
  setenv RAD_PASS   myemail@mydomain.com
endif

# Write hourly site insert statements and redirect statement to screen or logfile
setenv VERBOSE T

####################################################################################
###                       DO NOT MODIFY. MYSQL PASSWORD INPUT
### AMET 2.0 requires that MySQL password is provided either via csh argument
### when running interactively, or via qsub argument password if queued.
### This eliminates plain text file password in amet-config.R file and improves
### security.
### Method 1: ./matching_surface.csh (Will prompt for password) 
### Method 2: qsub -v password='mysqlpassword' matching_surface.csh
if (! "$?password" ) then
   echo "Enter the AMET user password: "
   stty -echo
   set amet_pass = "$<"
   stty echo
endif

if (! "$?amet_pass" ) then
   if (! $?password ) then
      echo "No password provided via qsub argument"
   else
      if ("$password" == "")  then
         echo "qsub password is empty"
      else
         set amet_pass = "$password"
         echo "Qsub -v password was accepted and will be passed to the script."
     endif
   endif
endif

if (! $?amet_pass ) then
    echo "No password provided. Either specify via terminal or qsub -v password=amet_pass"
    exit(0)
endif
####################################################################################

####################################################################################
####################################################################
# R run command of main model-obs matching script
cd $AMETBASE/scripts_db/$AMET_PROJECT
echo 'Date/Time START'
date
R --no-save --slave --args < $AMETBASE/R_db_code/MET_matching_radiation.R "$amet_pass"
echo 'Date/Time END'
date
exit (1)
####################################################################
####################################################################################

