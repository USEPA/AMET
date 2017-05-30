#!/bin/csh -f
# --------------------------------
# Bar plot
# -----------------------------------------------------------------------
# Purpose:
#
# This is an example c-shell script to run the R-script that generates
# a stacked bar plot. Data are queried from the MYSQL database for the
# STN or SEARCH networks.  Data are then averaged for SO4, NO3, NH4,
# EC, OC and PM2.5 for the model and ob values.  These averages are
# then plotted on a stacked bar plot, along with the percent of the
# total PM2.5 that each species comprises.
#
#
# Initial version:  Alexis Zubrow IE UNC - Nov, 2007
#
# Revised version:  Wyat Appel - Dec, 2012
# -----------------------------------------------------------------------

  
  #--------------------------------------------------------------------------
  # These are the main controlling variables for the R script
  
    #  Top of AMET directory
  setenv AMETBASE ~/AMET
  
  #  AMET database
  setenv AMET_DATABASE  amet

  #  AMET project id or simulation id
  setenv AMET_PROJECT   aqExample
 
  #  Directory where figures and text output will be directed
  setenv AMET_OUT       $AMETBASE/output/$AMET_PROJECT/stacked_barplot
  
  #  Start and End Dates of plot (YYYYMMDD) - must match available dates in db
  setenv AMET_SDATE "20060701"             
  setenv AMET_EDATE "20060711"             

  #  Custom title (if not set will autogenerate title based on variables 
  #  and plot type)
  setenv AMET_TITLE "CSN PM2.5 $AMET_PROJECT $AMET_SDATE - $AMET_EDATE"

  ### Species to Plot ###
  ### Acceptable Species Names: PM_TOT,PM_FRM,PM25_TOT,PM25_FRM

  setenv AMET_AQSPECIES PM_TOT

  ### Observation Network to plot
  ###  set to 'y' to turn on, default is off
  ###  NOTE: species are not available in every network
  setenv AMET_CSN y
#  setenv AMET_SEARCH y

  #  Plot Type, options are "pdf" or "png"
  setenv AMET_PTYPE png 

  # Log File for R script
  setenv AMET_LOG stacked_barplot.log


##--------------------------------------------------------------------------##
##                Most users will not need to change below here
##--------------------------------------------------------------------------##

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/stacked_barplot.input  
  setenv AMET_NET_INPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/Network.input
  
  # Check for plot and text output directory, create if not present
  if (! -d $AMET_OUT) then
     mkdir -p $AMET_OUT
  endif

  # R-script execution command
  R CMD BATCH --no-save --slave $AMETBASE/R/AQ_Stacked_Barplot.R $AMET_LOG
  setenv AMET_R_STATUS $status
  
  if($AMET_R_STATUS == 0) then
		echo
		echo "Statistics information"
		echo "-----------------------------------------------------------------------------------------"
		echo "Plots -- --------------------->" $AMET_OUT/${AMET_PROJECT}_PM2.5_stacked_barplot.$AMET_PTYPE
		echo "-----------------------------------------------------------------------------------------"
		exit 0
  else
     echo "The AMET R script did not produce any output, please check the LOGFILE $AMET_LOG for more details on the error."
     echo "Often, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  		exit 1  
  endif
