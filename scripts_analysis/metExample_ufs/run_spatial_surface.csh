#!/bin/csh -f
# -----------------------------------------------------------------------
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

  # MySQL Server and AMET database configuration file.
  # For security make file only readable by you. With the following variables
  # These are the only required for meteorological analysis. AQ requires more.
  # mysqllogin   <- yourlogin
  # mysqlpasswrd <- yourpassword
  setenv MYSQL_CONFIG  $AMETBASE/configure/amet-config.R

  # MySQL database server connection and AMET database
  setenv AMET_DATABASE  amet
  setenv MYSQL_SERVER   localhost

  # AMET project id or simulation id
  setenv AMET_PROJECT metExample_ufs
  
  # Directory where figures and text output will be directed
  setenv AMET_OUT  $AMETBASE/output/$AMET_PROJECT/spatial_surface
  
  # Do you want a CVS files with spatial statistics?
  setenv AMET_TEXTSTATS T
  
  #  Date range of Spatial statistics YYYYMMDD. Note that newer MySQL versions may see
  #  an ending date of 20130731 as ending at 00 UTC that day. Users should test this
  #  by doing spatial plots for one day (20110701 to 20110701) and set threshold to 1
  #  then look at the text output to see the number of samples. If 1, then you'd have
  #  to account for this in specifying the end date (i.e.; set to 20110702 for Jul 1 eval).
  #  One method is to specify the day after your desired end day, but if data is present,
  #  the statistics will include the first hour of that next day.
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
  
  R --no-save --slave < $AMETBASE/R_analysis_code/MET_spatial_surface.R 

  if(-e $AMET_OUT/$AMET_PROJECT.rmse.T.$AMET_DATES-$AMET_DATEE.$AMET_PTYPE) then
    echo
    echo "Examples of Spatial plots and data files that were produced"
    echo "-----------------------------------------------------------------------------------------"
    echo "Spatial RMSE of Temperature  ---------->" $AMET_OUT/$AMET_PROJECT.rmse.T.$AMET_DATES-$AMET_DATEE.$AMET_PTYPE
    echo
    echo "If histplot <- TRUE:"
    echo "Histogram RMSE of Temperature  ---------->" $AMET_PROJECT.rmse.T.$AMET_DATES-$AMET_DATEE.hist.$AMET_PTYPE
    echo
    echo "If shadeplot <- TRUE:"
    echo "Shaded using interpolation RMSE of Temperature  ---------->" $AMET_PROJECT.rmse.T.$AMET_DATES-$AMET_DATEE.shade.$AMET_PTYPE
    echo
    echo "Text statistics for temperature are in file:-->" $AMET_OUT/$AMET_PROJECT.spatial.temp2m.stats.$AMET_DATES-$AMET_DATEE.csv
    echo "-----------------------------------------------------------------------------------------"
  else
     echo "Please check options above, the AMET R script did not produce any output."
     echo "Typically, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  endif

exit(1)  
  
  
  
  
  
  
