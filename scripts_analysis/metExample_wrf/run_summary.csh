#!/bin/csh -f
# -----------------------------------------------------------------------
# Model Summary Statistics
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# statistical plots and text output of model performance, provided some 
# criteria that identifies what data to include in the evaluation.
# Plots include diurnal statistics and what is called an AMET plot that
# includes panels: scatter plot, table stats, stats vs. obs range and a
# model-obs box plot. These are done for T, Q, WS and WD.
# -----------------------------------------------------------------------
####################################################################################
####################################################################################
#                          USER CONFIGURATION OPTIONS
  #  Top of AMET directory
  setenv AMETBASE /home/user/AMET_v13

  # MySQL Server and AMET database configuration file.
  # For security make file only readable by you. With the following variables
  # These are the only required for meteorological analysis. AQ requires more.
  # mysqllogin   <- yourlogin
  # mysqlpasswrd <- yourpassword
  setenv MYSQL_CONFIG  $AMETBASE/configure/amet-config.R

  # MySQL database server connection and AMET database
  setenv AMET_DATABASE  user_database
  setenv MYSQL_SERVER   mysql.server.gov
  
  #  AMET project id or simulation id
  setenv AMET_PROJECT metExample_wrf
  
  #  Directory where figures and text output will be directed
  setenv AMET_OUT   $AMETBASE/output/$AMET_PROJECT/summary
  
  #  A seperate identification to be attached to figure/text output
  #  This is used to distiguish different subset output for the same project
  setenv AMET_RUNID JULY2016

  # This variable (AMET_CRITERIA) controls what data you want to evaluate. It is necessary to understand how to build
  # MySQL queries to develop your own custom queries of data. Below are some examples along with what criteria can be used.
  # Below is the MySQL query that defines the data to be extracted for analysis.
  # Note:   sample queries: 1) By day range only 2) date range and state 
  #                         3) date range and observation network and 4) Date range full domain
  # There are unlimted number of combinations not shown like query by Temperature, wind speed ranges, lat-lon bounds, etc
  setenv AMET_CRITERIA  "AND d.ob_date BETWEEN 20160701 AND 20160801 and (s.ob_network='OTHER-MTR' \
                         or s.ob_network='SAO' or s.ob_network='ASOS' or s.ob_network='MARITIME')"
  setenv AMET_CRITERIA  "AND d.ob_date BETWEEN 20160701 AND 20160801 AND d.ob_time AND (s.state='FL' \
                         OR s.state='SC' OR s.state='GA' OR s.state='LA' OR s.state='MS' OR s.state='AL' OR s.state='NC') "
  setenv AMET_CRITERIA  "AND d.ob_date BETWEEN 20160701 AND 20160801 AND (s.lat BETWEEN \
                         38 and 40 AND s.lon BETWEEN -77.8 and -75.0)"
  setenv AMET_CRITERIA  "AND d.ob_date BETWEEN 20160701 AND 20160801"

  #  Plot Type, plot options are "png" or "pdf" are only plot formats unless user modifies
  #  the main script in $AMET/R_analysis_code/MET_summary.R
  setenv AMET_PTYPE png           

  #-----------------------------------------------------------------------------------------------------------------------

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/summary.input  
  
  # Create output directory for project and analysis subdirectory
  mkdir -p $AMETBASE/output/$AMET_PROJECT
  mkdir -p $AMET_OUT
  
  # R-script execution command
  R --no-save --slave < $AMETBASE/R_analysis_code/MET_summary.R 

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
  
  
  
  
  
