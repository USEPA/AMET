#!/bin/csh -f
# --------------------------------
# Spatial Surface statistics
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# spatial statistical plots of model performance for a specified day
# or range of days.
# -----------------------------------------------------------------------

  
  #--------------------------------------------------------------------------
  # These are the main controlling variables for the R daily spatial script
  
  #  Top of AMET directory
  setenv AMETBASE ~/AMET

  #  AMET database
  setenv AMET_DATABASE  amet
  
  #  AMET project id or simulation id
  setenv AMET_PROJECT	wrfExample
  
  #  Directory where figures and text output will be directed
  setenv AMET_OUT  $AMETBASE/output/$AMET_PROJECT/spatial_surface
  
  # Do you want a CVS files with spatial statistics?
  setenv AMET_TEXTSTATS T
  
  #  Date range of Spatial statistics YYYYMMDD
  #  Below would be for the WRF test case in 2002
  setenv AMET_DATES "20020705"             
  setenv AMET_DATEE "20020709"

  #  Plot Type, options are "pdf" or "png"
  setenv AMET_PTYPE pdf             

  # Log File for R script
  setenv AMET_LOG $AMETBASE/scripts_analysis/$AMET_PROJECT/spatial_surface.log

  # Manual lat-lon plot bounds
  setenv AMET_BOUNDS_LAT "24 55"
  setenv AMET_BOUNDS_LON "-135 -60"

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/spatial_surface.input  
  
  # Check for plot and text output directory, create if not present
  if (! -d $AMET_OUT) then
     mkdir -p $AMETBASE/output/$AMET_PROJECT
     mkdir $AMET_OUT
  endif
  
  # R-script execution command
#  R BATCH --no-save < $AMETBASE/R/MET_spatial_surface.R 
  R CMD BATCH --no-save --slave $AMETBASE/R/MET_spatial_surface.R $AMET_LOG
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
  
  
  
  
  
  
