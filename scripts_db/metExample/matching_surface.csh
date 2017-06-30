#!/bin/csh
####################################################################################
#                          USER CONFIGURATION

# Main directories of AMET and MADIS data
setenv AMETBASE  /home/xxx/AMET_v13

# Define Database and Password from argument input
setenv MYSQL_LOGIN   xxxxxxxx
setenv AMET_DATABASE amet_test
setenv MYSQL_SERVER  xxxxxxx.epa.gov
setenv MYSQL_CONFIG  $AMETBASE/configure/amet-config.R

# Root directory of MADIS NetCDF obs. Note that this directory should
# contain subdirectories like this in the standard
# MADIS directory configuration: $AMETBASE/point/metar/netcdf
setenv MADISBASE $AMETBASE/obs/MET

# A unique AMETPROJECT name for the simulation to evaluated. 
# This will be used to organize all scripts/analyses and create the database tables
# that store all model-observation pairs of data for access by analysis scripts.
# NEW PROJECTS are automatically created in the database if not existing.
# RUN_DESCRIPTION: Short description of the model run to keep track its details.
setenv AMET_PROJECT    metExample
setenv RUN_DESCRIPTION "Main base WRF 12 km CONUS run with standard US EPA configuration. Example case for the release."

# Meteorological model output file location and control. The files that can be listed with
# location below. A wildcard (*) is added in the script to get list of outputs.
setenv METOUTPUT $AMETBASE/model_data/MET/metExample

# MADIS dataset to match with MPAS or WRF
# Options: metar, maritime, sao, mesonet, or text for non-MADIS obs input
# Note: user must have these files downloaded in a MADIS defined directory structure.
setenv MADISDSET metar 

# Interpolation Method for WRF Model: 1 - Nearest Neighbor, 2 - Bi-Linear
# For MPAS, a built in barycentric interpolation is the only option
setenv INTERP_METHOD 2

# Max allowable +/- time window of observations relative to top of the hour. 15 min matches all observations 15 min before
# the top of the hour to 15 min after the hour.
setenv MAXDTMIN 15

# If T, the master stations table in database will be updated with any new observation site metadata. May be wise to 
# turn on from time to time as new sites around the world are added to the MADIS database. 
# It is not neccessary to use frequently. It is mandantory to use for a new database if you want
# the ability to plot spatial statistics or use any windowing of a domain in statistics specs.
setenv UPDATE_SITES F 

# Automatic MADIS Obs FTP Option. This requires the FTP server where MADIS observations are location.
# Warning cira 2017: MADIS obs access has changed over the years, so it's recommended the users check
# the servers below to make sure they are still active. Also, make sure the FTP server address contains
# the path to the archive directory (i.e., ftp://FTPadress/archive).
# Also, users must have MADIS directory structure in place and MADISBASE pointing to that directory.
# Two current servers are defined below.
setenv AUTOFTP F
setenv MADIS_SERVER ftp://madis-data.cprk.ncep.noaa.gov/archive
setenv MADIS_SERVER ftp://madis-data.ncep.noaa.gov/archive

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
 R --no-save --slave --args < $AMETBASE/R_db_code/MET_matching_surface.R "$amet_pass"
echo 'Date/Time END'
date
exit (1)
####################################################################
####################################################################################

