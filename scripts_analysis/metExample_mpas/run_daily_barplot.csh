#!/bin/csh -f
# -----------------------------------------------------------------------
# DAILY Bar Plot of Model Statistics
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# statistical plots and text output of model performance. User can 
# provided some criteria that identifies what data to include. Plots
# include T, Q, WS, WD and WNDVEC for wind vector error.
# -----------------------------------------------------------------------
####################################################################################
#                          USER CONFIGURATION OPTIONS
  

  # MySQL Server and AMET database configuration file.
  # For security make file only readable by you. With the following variables
  # mysqllogin   <- yourlogin
  # mysqlpasswrd <- yourpassword
  setenv MYSQL_CONFIG  $AMETBASE/configure/amet-config.R

  # MySQL database server connection and AMET database
  setenv AMET_DATABASE  user_database
  setenv MYSQL_SERVER   mysql.server.gov
  
  #  AMET project id or simulation id
  setenv AMET_PROJECT metExample_mpas
  
  #  Directory where figures and text output will be directed. This spec
  #  sets up a subdirectory in the main project output directory specifically
  #  for daily bar plots. User can change daily_barplots to barplots_aug2015
  #  or any desired name to organize their statistics in project output dir.
  setenv AMET_OUT   $AMETBASE/output/$AMET_PROJECT/daily_barplot
  
  #  A seperate identification to be attached to figure/text output
  #  This is used to distiguish different subset output for the same project
  setenv AMET_RUNID    "JUL2016"
                                
  #-----------------------------------------------------------------------------------------------------------------------
  # This variable (AMET_CRITERIA) controls what data you want to evaluate. It is necessary to understand how to build
  # MySQL queries to develop your own custom queries of data. Below are some examples along with what criteria can be used.
  # Any of the fields in the stations table or project table can be used as query criteria. These are just a few examples.
  # IMPORTANT NOTE: End date should be + 1 days from what user wants in order to be compatible with both old and new versions
  #                 of AMET anad MySQL datatime spec. Notice data is extract for dates less than the end date.
  
  # 1. Dates between Jul 1-31, 2011 and only sites *WITHIN* the lat-lon box 23-55 deg and -125-65 deg
  setenv AMET_CRITERIA  "AND d.ob_date >=  20160701 AND d.ob_date < 20160801  AND s.lat BETWEEN 23 AND 55 AND \
                         s.lon BETWEEN -125 AND -65 ORDER BY d.ob_date"
  # 2. Dates between Jul 1-31, 2011 and only sites *OUTSIDE* the lat-lon box 23-55 deg and -125-65 deg.
  #    This is a nice way to look at MPAS global output outside of the fine mesh over the US as an example.
  setenv AMET_CRITERIA  "AND d.ob_date >=  20160701 AND d.ob_date < 20160801  AND s.lat NOT BETWEEN 23 AND 55 AND \
                         s.lon NOT BETWEEN -125 AND -65 ORDER BY d.ob_date"
  # 3. Use all sites in the entire domain and data from Jul 1-31, 2011
  setenv AMET_CRITERIA  "AND d.ob_date >=  20160701 AND d.ob_date < 20160801  ORDER BY d.ob_date"
  #-----------------------------------------------------------------------------------------------------------------------

  #  Plot Type, plot options are is "png" or "pdf" are only plot formats unless user modifies
  #  the main script in $AMET/R_analysis_code/MET_daily_barplot.R
  setenv AMET_PTYPE pdf            

  # Log File for R script
  setenv AMET_LOG $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/daily_barplot.log
  
#----------------------------------------------------------------------------------------
# Most users will not need to modify anything below
#----------------------------------------------------------------------------------------

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/daily_barplot.input  
  
  # Create output directory for project and analysis subdirectory
  mkdir -p $AMETBASE/output/$AMET_PROJECT
  mkdir -p $AMET_OUT

  # R-script execution command

  R --no-save --slave < $AMETBASE/R_analysis_code/MET_daily_barplot.R 
  
  setenv AMET_R_STATUS $status
  
  if($AMET_R_STATUS == 0) then
    echo
    echo "Statistics information"
    echo "-----------------------------------------------------------------------------------------"
    echo "Daily barplot is  ----------> $AMET_OUT/$AMET_PROJECT.$AMET_RUNID.<VARIABLE>.daily_barplot_<STATISTIC>.$AMET_PTYPE"
    echo "STATISTIC is either cor, RMSE or bias"
    echo "VARIABLE is either T, Q, WS or WD"
    echo "-----------------------------------------------------------------------------------------"
  else
     echo "The AMET R script did not produce any output, please check the LOGFILE $AMET_LOG for more details on the error."
     echo "Often, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  endif
