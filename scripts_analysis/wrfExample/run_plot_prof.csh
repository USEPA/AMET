#!/bin/csh -f
# --------------------------------
# Time-Height Profiler statistics
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# time height model-obs wind speed and direction statistics plots.
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
  setenv AMET_OUT   $AMETBASE/output/$AMET_PROJECT/profiler
    
  #  Date range of timeseries where year (YY), month (MM), day (DD), hour (HH) are 
  #  the start and end values with one space between
  #  Below is the example for July 5-6 2002
  setenv AMET_YY "2002 2002"             
  setenv AMET_MM "07 07"             
  setenv AMET_DD "05 09"             

   #  Observation site ID for wind profiler(s) of interest. Note: Multiple sites will result in 
  #  an average of those data with ID set to GROUP_AVG. Below is an example of both single and multiple.
  set SITES=(PLTC2 AZCN5 EPSTX )
#  set SITES=(CHANC)

  # Minimum number of samples at each level for statistics to be significant; 
  # all levels and times with less samples are set to NA
  setenv AMET_MIN_SAMPLE 0            

  # Very important parameter! All model-obs pairs with abs wind speed difference 
  # greater than this value are ignored. UHF profilers have bad data, so this allows
  # some QC of these bad obs.
  setenv AMET_MIN_WS_ERROR 5            
   
  #  Additional plot options to generate hourly profile plots and a spatial map of all availiable sites with site id's
  setenv AMET_HOURLY_PROF T 		

  setenv AMET_PROF_SITES  T		

  # Shaded and countour plot option, otherwise only the shaded plot is generated
  setenv AMET_CONTOUR_PLOT  T 		

  # Histogram of RMSE error
  setenv AMET_HIST_PROF  T		
  		
  # Ditribution (boxplot) of various statistics in vertical
  setenv AMET_VDIST_PROF  T		
  
  # Lower and upper height of desired profile (e.g., below represents a profile between 200 m and 1500 m)                                
  setenv AMET_ZLIML 200            
  setenv AMET_ZLIMU 1500            

  # If model was a forecast simulations INITUTC is the initial start time of the model; Use -1 if user
  # does NOT want use intial time as a criteria (non-forecast simulations).
  # FCAST is a range of forecast hours to extract. This is necessary when more than one forecast spans a single day
  # If INITUTC is -1 (non-forecast) FCAST is not considered.
  setenv AMET_INITUTC  -1           
  setenv AMET_FCAST    "0 9999"             

  #  Plot Type, options are "pdf" or "png"
  setenv AMET_PTYPE pdf            

  # Log File for R script
  setenv AMET_LOG $AMETBASE/scripts_analysis/$AMET_PROJECT/plot_prof.log
  # NOTE: Do not modify; this statement is necessary if an array of sites is specified.
  setenv AMET_SITEID_ALL "$SITES[*]" 
  if( $#SITES > 1) then
    set PLOT_ID="GROUP_AVG"
  else
      set PLOT_ID=$SITES[1]
  endif
  
#-----------------------------------------------------------------------------------------------------------------------
# Most users will not need to modify anything below
#-----------------------------------------------------------------------------------------------------------------------

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/plot_prof.input  
  
  # Check for plot and text output directory, create if not present
  if (! -d $AMET_OUT) then
     mkdir -p $AMETBASE/output/$AMET_PROJECT
     mkdir -p $AMET_OUT
  endif

  # R-script execution command
	R CMD BATCH --no-save --slave $AMETBASE/R/MET_plot_prof.R $AMET_LOG

  if(-e $AMET_OUT/wind.profile.stats.$AMET_PROJECT.WS.mae.$PLOT_ID.$AMET_PTYPE) then
     echo
     echo "Name and location of some plots and the text output file"
     echo "statmetrics are: bias, count, mea, meanm, meano and rmse"
     echo "-----------------------------------------------------------------------------------------"
     echo $AMET_OUT/wind.profile.stats.$AMET_PROJECT.WS.statmetric.$PLOT_ID.$AMET_PTYPE
     echo $AMET_OUT/wind.profile.stats.$AMET_PROJECT.WD.statmetric.$PLOT_ID.$AMET_PTYPE
     echo $AMET_OUT/stats.wind.profile.$AMET_PROJECT.$PLOT_ID.csv
     echo "-----------------------------------------------------------------------------------------"
  else
     echo "Please check options above, the AMET R script did not produce any output."
     echo "Typically, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  endif
exit(1)  
  
