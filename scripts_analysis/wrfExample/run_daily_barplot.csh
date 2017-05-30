#!/bin/csh -f
# --------------------------------
# Model Evaluation Subsetter
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# statistical plots and text output of model performance, provided some 
# criteria that identifies what data to include in the evaluation
# -----------------------------------------------------------------------

# Step 1: Set environmental variables to control which project/simulation to evaluate, 
#         output directory, run identification, and subset criteria
  
  #-----------------------------------------------------------------------------------------------------------------------
  # These are the main controlling variables for the R subset script, referred to as script-specific environmental variables
  
  #  Top of AMET directory
  setenv AMETBASE ~/AMET

  # AMET database
  setenv AMET_DATABASE amet
  
  #  AMET project id or simulation id
  setenv AMET_PROJECT	wrfExample
  
  #  Directory where figures and text output will be directed
  setenv AMET_OUT       $AMETBASE/output/$AMET_PROJECT/daily_barplot
  
    #  A seperate identification to be attached to figure/text output
  #  This is used to distiguish different subset output for the same project
  setenv AMET_RUNID    "test"
                                
  #-----------------------------------------------------------------------------------------------------------------------
  # This variable (AMET_CRITERIA) controls what data you want to evaluate. It is necessary to understand how to build
  # MySQL queries to develop your own custom queries of data. Below are some examples along with what criteria can be used.
  
  # This is a simple query to extract all data from the project defined above between June 5-9, 2002
  setenv AMET_CRITERIA  "AND d.ob_date BETWEEN 20020705 AND 20020709 ORDER BY d.ob_date"
  
  #  Plot Type, plot options are is "png" or "pdf"
  setenv AMET_PTYPE pdf            

  # Log File for R script
  setenv AMET_LOG $AMETBASE/scripts_analysis/$AMET_PROJECT/daily_barplot.log
  
#-----------------------------------------------------------------------------------------------------------------------
# Most users will not need to modify anything below
#-----------------------------------------------------------------------------------------------------------------------

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/daily_barplot.input  
  
  # Check for plot and text output directory, create if not present
  if (! -d $AMET_OUT) then
     mkdir -p $AMETBASE/output/$AMET_PROJECT
     mkdir -p $AMET_OUT
  endif

  # R-script execution command
  R CMD BATCH --no-save --slave $AMETBASE/R/MET_daily_barplot.R $AMET_LOG
  setenv AMET_R_STATUS $status
  
  if($AMET_R_STATUS == 0) then
    echo
    echo "Statistics information"
    echo "-----------------------------------------------------------------------------------------"
    echo "Timeseries plot is  ----------> $AMET_OUT/$AMET_PROJECT.<VARIABLE>.daily_barplot_<STATISTIC>.$AMET_PTYPE"
    echo "STATISTIC is either cor, RMSE or bias"
    echo "VARIABLE is either T, Q, WS or WD"
    echo "-----------------------------------------------------------------------------------------"
  else
     echo "The AMET R script did not produce any output, please check the LOGFILE $AMET_LOG for more details on the error."
     echo "Often, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  endif
