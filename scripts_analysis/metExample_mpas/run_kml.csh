#!/bin/csh -f
# -----------------------------------------------------------------------
# Google Earth KML file for Observation sites
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# spatial KML files for Google Earth or other interactive GIS programs.
# Built using the spatial surface script, the output KML file is put in
# that output directory. The KML is produced to facilitate analysis by providing 
# a method to explore sites used to evaluate the model.
# -----------------------------------------------------------------------
####################################################################################
####################################################################################
#                          USER CONFIGURATION OPTIONS

  # MySQL Server and AMET database configuration file.
  # For security make file only readable by you. With the following variables
  # These are the only required for meteorological analysis. AQ requires more.
  # mysqllogin   <- yourlogin
  # mysqlpasswrd <- yourpassword
  setenv MYSQL_CONFIG  $AMETBASE/configure/amet-config.R

  # MySQL database server connection and AMET databases. AMET_DATABASE1 is for
  # AMET_PROJECT1 below and the same for DATABASE2 and PROJECT2. This allows
  # comparison of runs that may reside in different databases
  setenv AMET_DATABASE  amet
  setenv MYSQL_SERVER   localhost
  setenv AMET_MODE      MET 
  #  AMET project id or simulation id. Note: Project2 allows comparsions of two model
  #  runs with obs including statistics. Project2 should be left blank for single project.
  setenv AMET_PROJECT metExample_mpas
 
  # Directory where figures and text output will be directed
  setenv AMET_OUT  $AMETBASE/output/$AMET_PROJECT/spatial_surface
  
  # Do you want a CVS files with spatial statistics?
  setenv AMET_TEXTSTATS T
  
  #  Date range of data for KML file observations.
  setenv AMET_DATES "20160701"
  setenv AMET_DATEE "20160801"

  #  And threshold of number of data points at a 
  #  single obs site, below which a sites statistics are NA.
  #  This excludes sites with limited obs. 
  #  24*NDAYS*0.5 would only do sites with 50% of data over
  #  number of days
  setenv THRESHOLD 120

  # Option to do daily statistics over the specified period above
  # Or statistics for the entire period.
  setenv DAILY F

  # lat-lon plot bounds. Note that all sites in a domain
  # will be considered when stats are calculated, but the
  # spatial plots will only cover the area below.
  setenv AMET_BOUNDS_LAT "23 55"
  setenv AMET_BOUNDS_LON "-125 -65"

  #  Plot Type, plot options are is "png" or "pdf" are only plot formats unless user modifies
  #  the main script in $AMET/R_analysis_code/MET_daily_barplot.R
  setenv AMET_PTYPE pdf             

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/run_info_MET.R  
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/spatial_surface.input
  setenv AMETRSTATIC $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/spatial_surface.static.input
  
  # Check for plot and text output directory, create if not present
  mkdir -p $AMETBASE/output/$AMET_PROJECT
  mkdir -p $AMET_OUT
  
  R --no-save --slave < $AMETBASE/R_analysis_code/MET_kml.R 

exit(1)  
  
  
  
  
  
  
