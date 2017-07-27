#!/bin/csh -f
# --------------------------------
# Spatial Surface statistics
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# spatial statistical plots of model performance for a specified day
# or range of days. Plots include RMSE, MAE, Bias and Cor for T, Q, WS, WD.
# Note: see spatial_surface.input for additional options including the 
#       ability to provide extra query specs. Some key settings are
#       checksave (will not redo statistics, only plot), symb (symbol type),
#       symbsize (size of symbol), and daily (will do stats for each day
#       instead of whole period).
# -----------------------------------------------------------------------
####################################################################################
####################################################################################
#                          USER CONFIGURATION OPTIONS

  #  Top of AMET directory
  setenv AMETBASE /home/xxx/AMET_v13 

  # MySQL Server and AMET database configuration file.
  # For security make file only readable by you. With the following variables
  # These are the only required for meteorological analysis. AQ requires more.
  # mysqllogin   <- yourlogin
  # mysqlpasswrd <- yourpassword
  setenv MYSQL_CONFIG  $AMETBASE/configure/amet-config.R

  # MySQL database server connection and AMET database
  setenv AMET_DATABASE  amet_test
  setenv MYSQL_SERVER   xxxxxxx.epa.gov

  #  AMET project id or simulation id
  setenv AMET_PROJECT metExample
  
  #  Directory where figures and text output will be directed
  setenv AMET_OUT  $AMETBASE/output/$AMET_PROJECT/spatial_surface
  
  # Do you want a CVS files with spatial statistics?
  setenv AMET_TEXTSTATS T
  
  #  Date range of Spatial statistics YYYYMMDD
  #  And threshold of number of data points at a 
  #  single obs site, below which a sites statistics are NA.
  #  This excludes sites with limited obs. 
  #  24*NDAYS*0.5 would only do sites with 50% of data over
  #  number of days
  setenv AMET_DATES "20130701 00"
  setenv AMET_DATEE "20130731 23"
  setenv THRESHOLD 558

  # Option to do daily statistics over the specified period above
  # Or statistics for the entire period.
  setenv DAILY F
  
  # lat-lon plot bounds. Note that all sites in a domain
  # will be considered when stats are calculated, but the
  # spatial plots will only cover the area below.
  setenv AMET_BOUNDS_LAT "24 55"
  setenv AMET_BOUNDS_LON "-135 -60"

  #  Plot Type, plot options are "png" or "pdf" are only plot formats unless user modifies
  #  the main script in $AMET/R_analysis_code/MET_daily_barplot.R
  setenv AMET_PTYPE pdf             

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/spatial_surface.input  
  
  # Check for plot and text output directory, create if not present
  mkdir -p $AMETBASE/output/$AMET_PROJECT
  mkdir -p $AMET_OUT
  
  R BATCH --no-save < $AMETBASE/R_analysis_code/MET_spatial_surface.R 

  if(-e $AMET_OUT/$AMET_PROJECT.rmse.T.$AMET_DATES.$AMET_DATEE.$AMET_PTYPE) then
    echo
    echo "Examples of Spatial plots and data files that were produced"
    echo "-----------------------------------------------------------------------------------------"
    echo "Spatial RMSE of Temperature  ---------->" $AMET_OUT/$AMET_PROJECT.rmse.T.$AMET_DATES.$AMET_DATEE.$AMET_PTYPE
    echo 
    echo "Text statistics for temperature are in file:-->" $AMET_OUT/$AMET_PROJECT.spatial.temp.stats.csv
    echo "-----------------------------------------------------------------------------------------"
  else
     echo "Please check options above, the AMET R script did not produce any output."
     echo "Typically, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  endif

exit(1)  
  
  
  
  
  
  
