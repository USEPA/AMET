#!/bin/csh -f
# --------------------------------
# MET-AQ coupled analysis
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# spatial statistical plots of model performance for a specified day
# -----------------------------------------------------------------------

  
  #--------------------------------------------------------------------------
  # These are the main controlling variables for the R daily spatial script
  
  #  Top of AMET directory
  setenv AMETBASE ~/AMET
  
  # AMET database
  setenv AMET_DATABASE amet

  #  AMET project id or simulation id for MET and AQ
  setenv AMET_MET_PROJECT	wrfExample				
  setenv AMET_AQ_PROJECT	aqExample				
  
  #  Directory where figures and text output will be directed
  setenv AMET_OUT       $AMETBASE/output/$AMET_MET_PROJECT/met_aq
  
  #  Start and End Dates of plot (YYYYMMDD)
  setenv AMET_SDATE "20020701"            
  setenv AMET_EDATE "20020701"            
 
  # AQ network and variables of interest (obs and model)
  setenv AQ_NETWORK "AQS"
  setenv AQ_VARS "O3_ob, O3_mod"

  # MET network and variables of interest (obs and model)
  setenv MET_NETWORK all
  setenv MET_VARS "T_ob, T_mod"

  #  Plot Type, options are "pdf" or "png"
  setenv AMET_PTYPE png             

  # Log File for R script
  setenv AMET_LOG $AMETBASE/scripts_analysis/$AMET_MET_PROJECT/met_aq.log
  
#-----------------------------------------------------------------------------------------------------------------------
# Most users will not need to modify anything below
#-----------------------------------------------------------------------------------------------------------------------

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_MET_PROJECT/met_aq_coupled.input  
  
  # Check for plot and text output directory, create if not present
  if (! -d $AMET_OUT) then
     mkdir -p $AMET_OUT
  endif

  # R-script execution command
  R CMD BATCH --no-save --slave $AMETBASE/R/MET_AQ_coupled.R $AMET_LOG
  setenv AMET_R_STATUS $status
  
  if($AMET_R_STATUS == 0) then
  echo
  echo "Statistics information"
  echo "-----------------------------------------------------------------------------------------"
  echo "Plots -- --------------------->" $AMET_OUT/met.aq.bias.comp.$AMET_PTYPE
  echo "Plots -- --------------------->" $AMET_OUT/met.aq.spatial.corr.$AMET_PTYPE
  echo "-----------------------------------------------------------------------------------------"
  else
     echo "The AMET R script did not produce any output, please check the LOGFILE $AMET_LOG for more details on the error."
     echo "Often, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  endif
exit(1)  

  
  
  
  
  
  
