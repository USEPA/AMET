#!/bin/csh -f
# -----------------------------------------------------------------------
# DAILY Bar Plot of Model Statistics
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# statistical plots and text output of model performance. User can 
# provided some criteria that identifies what data to include
# -----------------------------------------------------------------------
####################################################################################
#                          USER CONFIGURATION OPTIONS
  
  #  Top of AMET directory
  setenv AMETBASE /home/grc/AMET2.0 

  # MySQL Server and AMET database configuration file.
  # For security make file only readable by you. With the following variables
  # mysqllogin   <- yourlogin
  # mysqlpasswrd <- yourpassword
  setenv MYSQL_CONFIG  /home/gilliam/.ametconfig
  # MySQL database server connection and AMET database
  setenv AMET_DATABASE  amad_nrt
  setenv MYSQL_SERVER   darwin.rtpnc.epa.gov
  
  #  AMET project id or simulation id
  setenv AMET_PROJECT wrf_conus_12km
  
  #  Directory where figures and text output will be directed. This spec
  #  sets up a subdirectory in the main project output directory specifically
  #  for daily bar plots. User can change daily_barplots to barplots_aug2015
  #  or any desired name to organize their statistics in project output dir.
  setenv AMET_OUT   $AMETBASE/output/$AMET_PROJECT/daily_barplot
  
  #  A seperate identification to be attached to figure/text output
  #  This is used to distiguish different subset output for the same project
  setenv AMET_RUNID    "CONUS"
                                
  #-----------------------------------------------------------------------------------------------------------------------
  # This variable (AMET_CRITERIA) controls what data you want to evaluate. It is necessary to understand how to build
  # MySQL queries to develop your own custom queries of data. Below are some examples along with what criteria can be used.
  # Any of the fields in the stations table or project table can be used as query criteria. These are just a few examples.
  
  # 1. Dates between Jan 1-31, 2013 and only sites *WITHIN* the lat-lon box 23-55 deg and -125-65 deg
  setenv AMET_CRITERIA  "AND d.ob_date BETWEEN 20130101 AND 20130131 AND s.lat BETWEEN 23 AND 55 AND \
                         s.lon BETWEEN -125 AND -65 ORDER BY d.ob_date"
  # 2. Dates between Jan 1-31, 2013 and only sites *OUTSIDE* the lat-lon box 23-55 deg and -125-65 deg.
  #    This is a nice way to look at MPAS global output outside of the fine mesh over the US as an example.
  setenv AMET_CRITERIA  "AND d.ob_date BETWEEN 20130101 AND 20130131 AND s.lat NOT BETWEEN 23 AND 55 AND \
                         s.lon NOT BETWEEN -125 AND -65 ORDER BY d.ob_date"
  # 3. Use all sites in the entire domain and data from May 2-10, 2017                       
  setenv AMET_CRITERIA  "AND d.ob_date BETWEEN 20170502 AND 20170510 ORDER BY d.ob_date"
  #-----------------------------------------------------------------------------------------------------------------------

  #  Plot Type, plot options are is "png" or "pdf" are only plot formats unless user modifies
  #  the main script in $AMET/R_analysis_code/MET_daily_barplot.R
  setenv AMET_PTYPE pdf            

  # Log File for R script
  setenv AMET_LOG $AMETBASE/scripts_analysis/$AMET_PROJECT/daily_barplot.log
  
#----------------------------------------------------------------------------------------
# Most users will not need to modify anything below
#----------------------------------------------------------------------------------------

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/daily_barplot.input  
  
  # Create output directory for project and analysis subdirectory
  mkdir -p $AMETBASE/output/$AMET_PROJECT
  mkdir -p $AMET_OUT

  # R-script execution command

  R BATCH --no-save < $AMETBASE/R_analysis_code/MET_daily_barplot.R 
  
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
