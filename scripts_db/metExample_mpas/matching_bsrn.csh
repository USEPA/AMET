#!/bin/csh
####################################################################################
####################################################################################
#                          USER CONFIGURATION

# Main directories of AMET and MADIS data
setenv AMETBASE  /home/user/AMET_v13

# Define Database and Password from argument input
setenv MYSQL_LOGIN   xxxxxxx
setenv AMET_DATABASE user_database
setenv MYSQL_SERVER  mysql.server.gov
setenv MYSQL_CONFIG  $AMETBASE/configure/amet-config.R

# Root directory of BSRN obs (same as MADIS). Note that this directory should
# contain a subdirectory "bsrn" where this radiation obs dataset (unzipped)
# BSRN directory configuration: $MADISBASE/bsrn 
setenv MADISBASE $AMETBASE/obs/MET

# A unique AMETPROJECT name for the simulation to evaluated. 
# This will be used to organize all scripts/analyses and create the database tables
# that store all model-observation pairs of data for access by analysis scripts.
# NEW PROJECTS are automatically created in the database if not existing.
# RUN_DESCRIPTION: Short description of the model run to keep track its details.
setenv AMET_PROJECT    metExample_mpas 
setenv RUN_DESCRIPTION "MPAS release test dataset."

# Meteorological model output file location and control. The files that can be listed with
# location below. A wildcard (*) is added in the script to get list of outputs.
setenv METOUTPUT $AMETBASE/model_data/MET/$AMET_PROJECT/history.subset.2016

# Radiation dataset to match with MPAS or WRF
# Options:bsrn or text for non-BSRN obs input
# Note: user must have these files downloaded MADISBASE/bsrn directory.
setenv RADIATION_DSET bsrn 

# Interpolation Method for WRF Model: 1 - Nearest Neighbor, 2 - Bi-Linear
# For MPAS, a built in barycentric interpolation is the only option, so this setting
# does not apply.
setenv INTERP_METHOD 2

# Time +/- window averaging of 1 min solar radiation BSRN measurments. 5 would be +/-
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

# Automatic BSRN Obs FTP Option. This requires log/pass to FTP server where BSRN observations are location.
# Also, users must have MADIS directory structure in place and MADISBASE pointing to that directory.
# Current BSRN server is defined below. Note: only observation within the domain are downloaded.

setenv AUTOFTP T
setenv BSRN_SERVER ftp://ftp.bsrn.awi.de
setenv BSRN_LOGIN  bsrnftp
setenv BSRN_PASS   bsrn1

# Write hourly site insert statements and reject statement to screen or logfile
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
R --no-save --slave --args < $AMETBASE/R_db_code/MET_matching_bsrn.R "$amet_pass"
echo 'Date/Time END'
date
exit (1)
####################################################################
####################################################################################

