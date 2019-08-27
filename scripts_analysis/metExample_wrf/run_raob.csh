#!/bin/csh 
# -----------------------------------------------------------------------
# Raob vertical statistics
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# raob statistical plots of model performance for a specified day, period,
# site or group of sites. See raob.input file for extra settings including
# sample size thresholds and plotting options. Analysis includes T, RH, WS and WD.
# -----------------------------------------------------------------------
####################################################################################
#                          USER CONFIGURATION OPTIONS


  # MySQL Server and AMET database configuration file.
  # For security make file only readable by you. With the following variables
  # These are the only required for meteorological analysis. AQ requires more.
  # mysqllogin   <- yourlogin
  # mysqlpasswrd <- yourpassword
  setenv MYSQL_CONFIG  $AMETBASE/configure/amet-config.R

  # MySQL database server connection and AMET database
  setenv AMET_DATABASE  user_database
  setenv MYSQL_SERVER   mysql.server.gov

  #  AMET project id or simulation id
  setenv AMET_PROJECT metExample_wrf 
  
  #  Directory where figures and text output will be directed
  setenv AMET_OUT  $AMETBASE/output/$AMET_PROJECT/raob
  
  # MANDATORY PRESSURE LEVEL ANALYSIS OPTIONS
  # AMET_BOUNDS_LAT and AMET_BOUNDS_LON are used to choose sites to include.
  # spatial.setSITES.all.txt file is produced in output directory. This file
  # has set SITES string that can be used below.
  setenv RAOB_SPATIAL   T 
  # Sounding timeseries statistics for defined pressure layer (AMET_PLAYER below T/F)
  # AMET_BOUNDS_LAT and AMET_BOUNDS_LON are used to choose sites for timeseries stats.
  setenv RAOB_TSERIES   F 
  # Profile statistics for all mandatory levels (T/F). 
  # NOTE: Site grouping is allowed. Done for all availiable pressure levels.
  setenv RAOB_PROFILEM  F 
  # Curtain plot of model, raob and difference on mandatory pressure levels (T/F).
  # NOTE: No site grouping allowed. Script ignores this setting and plots each site.
  setenv RAOB_CURTAINM  F 

  # NATIVE PRESSURE LEVEL ANALYSIS OPTIONS
  # Profiles of model and obs on their native levels for sites below (T/F).
  # NOTE: only done for start time below. Can be ran through loop for mutiple times.
  # NOTE: No site grouping allowed. Script ignores this setting and plots each site.
  # NOTE: Pressure level range defined by AMET_PLIM below.
  setenv RAOB_PROFILEN  F 
  # Curtain plot of model with obs profile overlaid using dots (T/F).
  # NOTE: No site grouping allowed. Script ignores this setting and plots each site.
  # NOTE: Pressure level range defined by AMET_PLIM below.
  setenv RAOB_CURTAINN  F 

  #  Date range of timeseries where year (YY), month (MM), day (DD) are
  #  the start and end values with one space between. Use two digit MM and DD.
  #  Below is the example for May 1-10, 2017
  setenv AMET_YY "2016 2016"
  setenv AMET_MM "07 08"
  setenv AMET_DD "01 01"
  setenv AMET_HH "00 00"

  #  Observation site ID array. 
  #  "ALL" will get data for all sites, but only applicable for RAOB_PROFILEM option
  #  AMET_GROUPSITES allows grouping (or not) of defined site IDs for RAOB_PROFILEM option
  set SITES=(ALL)
  set SITES=(KGSO KMFL KPIT KSLC KDNR KOUN KOAK KBIS)

  # Should SITES be grouped or averaged (T/F). Grouped sites only work for 
  # profile statistics on mandatory pressure levels via RAOB_PROFILEM T
  setenv AMET_GROUPSITES F

  # Lower and upper pressure of desired layer average statistics.
  # Used for layer average spatial statistics via RAOB_SPATIAL option. 
  setenv AMET_PLAYER "1000 100"             

  # Lower and upper pressure of desired native level profiles and 
  # curtain plots when RAOB_CURTAINN and/or setenv RAOB_PROFILEN is true
  setenv AMET_PLIM "1000 600"             

  # Lat-lon plot bounds for spatial analysis. 
  # This is also used for bounds of spatial plots.
  setenv AMET_BOUNDS_LAT "23 55"
  setenv AMET_BOUNDS_LON "-135 -60"

  # Do you want a CVS files with Spatial and Daily Statistics?
  setenv AMET_TEXTSTATS T

  #  Plot Type, plot options are is "png" or "pdf" are only plot formats unless user modifies
  #  the main script in $AMET/R_analysis_code/MET_daily_barplot.R
  setenv AMET_PTYPE pdf             

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/raob.input  
  
  # Check for plot and text output directory, create if not present
  mkdir -p $AMETBASE/output/$AMET_PROJECT
  mkdir -p $AMET_OUT
  
  # NOTE: Do not modify; this statement is necessary if an array of sites is specified.
  setenv AMET_SITEID "$SITES[*]"


  R --slave --no-save < $AMETBASE/R_analysis_code/MET_raob.R 


exit(1)  

