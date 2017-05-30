#!/bin/csh -f
# --------------------------------
# Model Summary Statistics
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# statistical plots and text output of model performance, provided some 
# criteria that identifies what data to include in the evaluation
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
  setenv AMET_OUT       $AMETBASE/output/$AMET_PROJECT/summary
  
  #  A seperate identification to be attached to figure/text output
  #  This is used to distiguish different subset output for the same project
  setenv AMET_RUNID test

  # This variable (AMET_CRITERIA) controls what data you want to evaluate. It is necessary to understand how to build
  # MySQL queries to develop your own custom queries of data. Below are some examples along with what criteria can be used.
  
  # Below is the MySQL query that defines the data to be extracted for analysis.
  # Note: 3 sample queries, by day range only, date range and state, date range and observation network.
  # There are unlimted number of combinations not shown like query by Temperature, wind speed ranges, lat-lon bounds, etc
#  setenv AMET_CRITERIA  "AND d.ob_date BETWEEN 20060601 AND 20060831 and (s.ob_network='OTHER-MTR' or s.ob_network='SAO' or s.ob_network='ASOS' or s.ob_network='MARITIME')"
 # setenv AMET_CRITERIA  "AND d.ob_date BETWEEN 20060601 AND 20060831 AND d.ob_time AND (s.state='FL' OR s.state='SC' OR s.state='GA' OR s.state='LA' OR s.state='MS' OR s.state='AL' OR s.state='NC') "
  
  setenv AMET_CRITERIA  "AND d.ob_date BETWEEN 20020705 AND 20020709"

  
  #  Plot Type, options are "pdf" or "png"
  # Note: with large datasets PDF files can be very large, PNG is suggested
  setenv AMET_PTYPE png            

  # Log File for R script
  setenv AMET_LOG $AMETBASE/scripts_analysis/$AMET_PROJECT/summary.log

  #-----------------------------------------------------------------------------------------------------------------------

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/summary.input  
  
  # Check for plot and text output directory, create if not present
  if (! -d $AMET_OUT) then
     mkdir -p $AMETBASE/output/$AMET_PROJECT
     mkdir $AMET_OUT
  endif
  
  # R-script execution command
#   R BATCH --no-save < $AMETBASE/R/MET_summary.R 
  R CMD BATCH --no-save --slave $AMETBASE/R/MET_summary.R $AMET_LOG
  
  if(-e $AMET_OUT/$AMET_PROJECT.$AMET_RUNID.T.ametplot.$AMET_PTYPE) then
    echo
    echo "Statistics information"
    echo "-----------------------------------------------------------------------------------------"
    echo "Performance plot will have the name convention ---------->" $AMET_OUT/$AMET_PROJECT.$AMET_RUNID.VARIABLE.ametplot.$AMET_PTYPE
    echo "Diurnal performance plot will have the name convention -->" $AMET_OUT/$AMET_PROJECT.$AMET_RUNID.VARIABLE.diurnal.$AMET_PTYPE
    echo 
    echo "Text statistics are in file: ---------------------------->" $AMET_OUT/stats.$AMET_PROJECT.$AMET_RUNID.dat
    echo "-----------------------------------------------------------------------------------------"
  else
     echo "Please check options above, the AMET R script did not produce any output."
     echo "Typically, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  endif  
exit(1)  
  
  
  
  
  
