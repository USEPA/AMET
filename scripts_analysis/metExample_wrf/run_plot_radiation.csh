#!/bin/csh -f
# -----------------------------------------------------------------------
# Shortwave Radiation Evaluation using Baseline Surface Radiation Network
# or US-Based SURFRAD
# -----------------------------------------------------------------------
# Purpose:
# Evaluation of MPAS/WRF shortwave radiation using the global BSRN or  
# SURFRAD observations. Spatial, diurnal, timeseries and histogram plots
# are options along with text outputs.
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
  setenv AMET_OUT     $AMETBASE/output/$AMET_PROJECT/bsrn
  
  # Do you want a CVS files with spatial statistics?
  setenv AMET_TEXTSTATS T
  
  #  Date of spatial plot (YYYYMMDD)
  setenv AMET_DATES "20160701"             
  setenv AMET_DATEE "20160801"

  # Logicals for various plot types Spatial, Diurnal average and Timeseries
  setenv SRAD_SPATIAL    T 
  setenv SRAD_DIURNAL    T
  setenv SRAD_TIMESERIES T  
  setenv SRAD_HISTOGRAM  T  

  # Lat-lon plot bounds . Note that all sites in a domain
  # will be considered when stats are calculated, but the
  # spatial plots will only cover the area below.
  setenv AMET_BOUNDS_LAT "24 55"
  setenv AMET_BOUNDS_LON "-135 -60"
  setenv AMET_BOUNDS_LAT "-85 85"
  setenv AMET_BOUNDS_LON "-180 180"

  # **** PDF format only since there are so many utilities to convert PFD to other formats ***
  #-----------------------------------------------------------------------------------------------------------------------

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/run_info_MET.R
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/plot_radiation.input 
  setenv AMETRSTATIC $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/plot_radiation.static.input  
  # Create output directory for project and analysis subdirectory
  mkdir -p $AMETBASE/output/$AMET_PROJECT
  mkdir -p $AMET_OUT

  
  # R-script execution command
  R --no-save --slave < $AMETBASE/R_analysis_code/MET_plot_radiation.R 

exit(1)  
  
  
  
  
  
  
