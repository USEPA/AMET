#!/bin/csh -f
# --------------------------------
# Daily Model-Obs Wind Vector Plots
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# time height wind vector plots that include model and observed vectors
# -----------------------------------------------------------------------

  #-----------------------------------------------------------------------------------------------------------------------
  # These are the main controlling variables for the R subset script, referred to as script-specific environmental variables
  
  #  Top of AMET directory
  setenv AMETBASE ~/AMET
  
  #  AMET database
  setenv AMET_DATABASE  amet

  #  AMET project id or simulation id
  setenv AMET_PROJECT	wrfExample
  
  #  Directory where figures and text output will be directed
  setenv AMET_OUT       $AMETBASE/output/$AMET_PROJECT/wind_prof
  
  #  Observation site for timeseries
  setenv AMET_SITEID "CHANC"

  #  Date where year (YY), month (MM), day (DD) 
  #  Below is the example for July 6 2002
  setenv AMET_YY 2002            
  setenv AMET_MM 07             
  setenv AMET_DD 06             

  # Lower and upper height of desired profile (e.g., below represents a profile between 0 m and 1000 m)                                
  setenv AMET_ZLIM "0 3000"             

  # If model was a forecast simulations INITUTC is the initial start time of the model; Use -1 if user
  # does NOT want use intial time as a criteria (non-forecast simulations).
  # FCAST is a range of forecast hours to extract. This is necessary when more than one forecast spans a single day
  # If INITUTC is -1 (non-forecast) FCAST is not considered.
  setenv AMET_INITUTC  -1           
  setenv AMET_FCAST    "0 9999"             

  # Log File for R script
  setenv AMET_LOG $AMETBASE/scripts_analysis/$AMET_PROJECT/wind_prof.log

  #  Plot Type, options are "pdf" or "png"
  setenv AMET_PTYPE pdf             
  #-----------------------------------------------------------------------------------------------------------------------
  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/wind_prof.input  

  # Check for plot and text output directory, create if not present
  if (! -d $AMET_OUT) then
     mkdir -p $AMETBASE/output/$AMET_PROJECT
     mkdir $AMET_OUT
  endif

  # R-script execution command
#  R BATCH --no-save < $AMETBASE/R/MET_wind_prof.R 
   R CMD BATCH --no-save --slave $AMETBASE/R/MET_wind_prof.R $AMET_LOG
 
  if(-e $AMET_OUT/$AMET_PROJECT.wind_vector_profile.$AMET_YY$AMET_MM$AMET_DD.$AMET_SITEID.$AMET_PTYPE) then
     echo
     echo "Wind Profile plot"
     echo "-----------------------------------------------------------------------------------------"
     echo "Wind Vector plot ---------->" $AMET_OUT/$AMET_PROJECT.wind_vector_profile.$AMET_YY$AMET_MM$AMET_DD.$AMET_SITEID.$AMET_PTYPE
     echo "-----------------------------------------------------------------------------------------"
  else
     echo "Please check options above, the AMET R script did not produce any output."
     echo "Typically, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  endif
exit(1)  
  
  
  
  
  
  
