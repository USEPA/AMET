#!/bin/csh -f
# --------------------------------
# Raob Profile comparisons and statistics
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# raob statistical plots of model performance for a specified day
# -----------------------------------------------------------------------

  
  #--------------------------------------------------------------------------
  # These are the main controlling variables for the R daily spatial script
  
  #  Top of AMET directory
  setenv AMETBASE ~/AMET

  # AMET database
  setenv AMET_DATABASE amet
  
  #  AMET project id or simulation id
  setenv AMET_PROJECT	wrfExample
  
  #  Directory where figures and text output will be directed
  setenv AMET_OUT       $AMETBASE/output/$AMET_PROJECT/raob
    
  #  Date range of timeseries where year (YY), month (MM), day (DD),  
  #  and hour (HH) are the start and end values with one space between
  #  Below is the example for Apr 1-30 2013, 00 and 12 UTC soundins.
  setenv AMET_YY "2002 2002"             
  setenv AMET_MM "07 07"             
  setenv AMET_DD "05 09"             
  setenv AMET_HH "00 23"             

  #  Observation site for raob profile plots.  1 Specific site only.
  #  Note: p-layer plots show all sites.
  setenv AMET_SITEID "MBWW4"

  # Lower and upper height of desired layer average bias (e.g., below represents a layer average between 500 m and 2000 m)                                
  setenv AMET_LAYER "0 500"             


  # Lower and upper height of desired profile comparison plot(e.g., below represents a profile between 0 m and 10000 m)                                
  setenv AMET_ZLIM "0 5000"             


  #  Plot Type, options are "pdf" or "png"
  setenv AMET_PTYPE pdf            

  # Log File for R script
  setenv AMET_LOG $AMETBASE/scripts_analysis/$AMET_PROJECT/plot_raob.log

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/plot_raob.input  
  
  # Check for plot and text output directory, create if not present
  if (! -d $AMET_OUT) then
    mkdir -p $AMETBASE/output/$AMET_PROJECT
    mkdir $AMET_OUT
  endif

  # R-script execution command
 #  R BATCH --no-save < $AMETBASE/R/MET_plot_raob.R 
  R CMD BATCH --no-save --slave $AMETBASE/R/MET_plot_raob.R $AMET_LOG
 
  if(-e $AMET_OUT/raob_layer_stats.$AMET_PROJECT.$AMET_PTYPE) then
     echo
     echo "Statistics information"
     echo "-----------------------------------------------------------------------------------------"
     echo "RAOB plot           ---------->" $AMET_OUT/raob_layer_stats.$AMET_PROJECT.$AMET_PTYPE
     echo "                    ---------->" $AMET_OUT/raob_prof_comp.$AMET_PROJECT.$AMET_SITEID.$AMET_PTYPE
     echo "Statistics data     ---------->" $AMET_OUT/$AMET_PROJECT.raobstats.txt
     echo "-----------------------------------------------------------------------------------------"
  else
     echo "Please check options above, the AMET R script did not produce any output."
     echo "Typically, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  endif
exit(1)  
  
  
  
  
  
  
