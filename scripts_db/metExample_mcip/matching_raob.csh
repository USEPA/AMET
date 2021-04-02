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

# Root directory of MADIS NetCDF obs. Note that this directory should
# contain subdirectories like this in the standard
# MADIS directory configuration: $AMETBASE/point/metar/netcdf
setenv MADISBASE $AMETBASE/obs/MET

# A unique AMETPROJECT name for the simulation to evaluated. 
# This will be used to organize all scripts/analyses and create the database tables
# that store all model-observation pairs of data for access by analysis scripts.
# NEW PROJECTS are automatically created in the database if not existing.
# RUN_DESCRIPTION: Short description of the model run to keep track its details.
setenv AMET_PROJECT    metExample_mcip 
setenv RUN_DESCRIPTION "MCIP release test dataset."

# Is this a model forecast where intial date/time and forecast hour should be tracked?
setenv FORECAST F

# Meteorological model output file location and control. 
# MCIP output requires slightly different controls as mutiple files for each
# batch (e.g., daily MCIP) of MCIP are needed. GRIDCRO2D, METCRO3D and METDOT3D files.
# The AMET script looks for generic file names for each of these files in an effort to
# reduce more significant mods to existing functions. Below is one example.
# A temporary directory is created. The MCIP files are linked into this temp directory
# using these generic names using extra RAOB specific scripting towards the end of this
# csh wrapper. This works for one set of MCIP. If one has mutiple sets of MCIP a wrapper
# looping script is provided as an example in this same directory where you can loop over
# days for example and pass those specs into this script and run within this loop.
setenv METTMPDIR $AMETBASE/model_data/MET/$AMET_PROJECT/TMP
setenv GRIDCRO   $AMETBASE/model_data/MET/$AMET_PROJECT/GRIDCRO2D_20160701.nc4
setenv METCRO    $AMETBASE/model_data/MET/$AMET_PROJECT/METCRO3D_20160701.nc4
setenv METDOT    $AMETBASE/model_data/MET/$AMET_PROJECT/METDOT3D_20160701.nc4

# Matching Mode options.
# Native level matching   : Store full Rawindsonde profile and model profile on their native levels.
# Mandatory level matching: Interoplate model to ~22 standard pressure levels of the Rawindsonde.
# Native level matching is more time consuming and will not allow direct statistics since the model
# and obs are on different levels. This is more for plotting.
# Mandantory level matching is quick and allows spatial statistics at a specific level or layer over a 
# defined period. Also allows statistics and barplots for one or more sites displayed as a profile.
setenv NATIVE    T
setenv MANDATORY T

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

# Automatic MADIS Obs FTP Option. This requires the FTP server where MADIS observations are location.
# Warning cira 2017: MADIS obs access has changed over the years, so it's recommended the users check
# the servers below to make sure they are still active. Also, make sure the FTP server address contains
# the path to the archive directory (i.e., ftp://FTPadress/archive).
# Also, users must have MADIS directory structure in place and MADISBASE pointing to that directory.
# Two current servers are defined below.
setenv AUTOFTP T
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
# Extra scripting for MCIP RAOB only where R model reading function looks for generic
# MCIP file names: GRIDCRO2D, METCRO3D and METDOT3D
# Users will have to write more customized wrappers for large batches of data
# A bit difficult to do here because naming of files can be quite different.
mkdir -p ${METTMPDIR}
rm -f ${METTMPDIR}/*
ln -sf ${GRIDCRO} ${METTMPDIR}/GRIDCRO2D
ln -sf ${METCRO}  ${METTMPDIR}/METCRO3D
ln -sf ${METDOT}  ${METTMPDIR}/METDOT3D
setenv METOUTPUT ${METTMPDIR}/METCRO3D
echo ${METOUTPUT}

####################################################################################
####################################################################
# R run command of main model-obs matching script
cd $AMETBASE/scripts_db/$AMET_PROJECT
echo 'Date/Time START'
date
 R --no-save --slave --args < $AMETBASE/R_db_code/MET_matching_raob.R "$amet_pass"
echo 'Date/Time END'
date
exit (1)
####################################################################
####################################################################################

