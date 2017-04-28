#!/bin/csh -f
# --------------------------------
# Bar plot - CMAQv5.0 AERO6
# -----------------------------------------------------------------------
# Purpose:
#
# The code is interactive with the AMET_AQ system developed by Wyat
# Appel.  Data are queried from the MYSQL database for the CSN or
# SEARCH networks.  Data are then averaged for SO4, NO3, NH4, EC, OC
# soil, NaCl, NCOM, other and PM2.5 for the model and ob values.  
# These averages are then plotted on a stacked bar plot, along with 
# the percent of the total PM2.5 that each species comprises.
#
# Initial version:  Wyat Appel - Dec, 2012
# -----------------------------------------------------------------------

  
  #--------------------------------------------------------------------------
  # These are the main controlling variables for the R script
  
  #  Top of AMET directory
  setenv AMETBASE  /project/amet_aq/AMET_Code/Release_Code_v13/AMET_v13

  #  AMET database
  setenv AMET_DATABASE CMAQ_v51_Dev

  #  AMET project id or simulation id
#  setenv AMET_PROJECT   aqExample
  setenv AMET_PROJECT CMAQ_v502_Base_New
 
  #  Directory where figures and text output will be directed
  setenv AMET_OUT       $AMETBASE/output/$AMET_PROJECT/stacked_barplot_panel
  
  #  Start and End Dates of plot (YYYYMMDD)
  setenv AMET_SDATE "20110701"             
  setenv AMET_EDATE "20110731"             

  setenv AMET_PID 1

  #  Custom title (if not set will autogenerate title based on variables 
  #  and plot type)
#  setenv AMET_TITLE "CSN PM2.5 $AMET_PROJECT $AMET_SDATE - $AMET_EDATE"
  setenv AMET_TITLE ""

### Species to Plot ###
  ### Acceptable Species Names: PM_TOT,PM_FRM,PM25_TOT,PM25_FRM

  setenv AMET_AQSPECIES PM_TOT

  ### Observation Network to plot
  ###  set to 'y' to turn on, default is off
  ###  NOTE: species are not available in every network
#  setenv AMET_CSN y
  setenv AMET_IMPROVE y
#  setenv AMET_SEARCH y

  #  Plot Type, options are "pdf" or "png"
  setenv AMET_PTYPE png 

  # Log File for R script
  setenv AMET_LOG stacked_barplot_panel.log


##--------------------------------------------------------------------------##
##                Most users will not need to change below here
##--------------------------------------------------------------------------##

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/stacked_barplot_panel.input  
  setenv AMET_NET_INPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/Network.input
  
  # Check for plot and text output directory, create if not present
  if (! -d $AMET_OUT) then
     mkdir -p $AMET_OUT
  endif

  # R-script execution command
  R CMD BATCH --no-save --slave $AMETBASE/R_analysis_code/AQ_Stacked_Barplot_panel.R $AMET_LOG
  setenv AMET_R_STATUS $status
  
  if($AMET_R_STATUS == 0) then
		echo
		echo "Statistics information"
		echo "-----------------------------------------------------------------------------------------"
		echo "Plots -- --------------------->" $AMET_OUT/${AMET_PROJECT}_${AMET_PID}_PM2.5_stacked_barplot_panel.$AMET_PTYPE
		echo "-----------------------------------------------------------------------------------------"
		exit 0
  else
     echo "The AMET R script did not produce any output, please check the LOGFILE $AMET_LOG for more details on the error."
     echo "Often, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  		exit 1  
  endif
