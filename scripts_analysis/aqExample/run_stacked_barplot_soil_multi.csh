#!/bin/csh -f
# --------------------------------
# Bar plot - Soil (Multiple networks)
# -----------------------------------------------------------------------
# Purpose:
#
# The code is interactive with the AMET_AQ system developed by Wyat
# Appel.  Data are queried from the MYSQL database for the CSN or
# IMPROVE networks. The code creates a stacked barplot of the 
# major soil species available in CMAQv5.0 w/ AERO6 for both IMPROVE
# and CSN networks together, but only accepts a single simulation. 
# The plot is similar in design to the standard stacked barplot.
#
# Initial version:  Wyat Appel - Dec, 2012
# Revised version:  Wyat Appel - Jun, 2017
# -----------------------------------------------------------------------

  
  #--------------------------------------------------------------------------
  # These are the main controlling variables for the R script
  
  #  Top of AMET directory
  setenv AMETBASE       ~/AMET
  setenv AMET_DATABASE  amet
  setenv AMET_PROJECT   aqExample
  setenv MYSQL_CONFIG   $AMETBASE/configure/amet-config.R
 
  #  Directory where figures and text output will be directed
  setenv AMET_OUT       $AMETBASE/output/$AMET_PROJECT/stacked_barplot_soil_multi
  
  #  Start and End Dates of plot (YYYYMMDD)- must match available dates in db 
  setenv AMET_SDATE "20110701"             
  setenv AMET_EDATE "20110731"             

  # Process ID. This can be set to anything. It will be added to the file output name. Default is 1.
  # The PID is particularly important if using the AMET web interface and is determined there through
  # a random number generator.
  setenv AMET_PID 1

  #  Custom title (if not set will autogenerate title based on variables 
  #  and plot type)
#  setenv AMET_TITLE "Traces Metals for $AMET_PROJECT $AMET_SDATE - $AMET_EDATE"

### Species to Plot ###
  ### Acceptable Species Names: Soil

  setenv AMET_AQSPECIES Soil

### Observation Network to plot
  ###  set to 'y' to turn on, default is off
  ###  NOTE: species are not available in every network
  setenv AMET_CSN y
  setenv AMET_IMPROVE y

  #  Plot Type, options are "pdf" or "png"
  setenv AMET_PTYPE png 

  # Log File for R script
  setenv AMET_LOG stacked_barplot_soil_multi.log


##--------------------------------------------------------------------------##
##                Most users will not need to change below here
##--------------------------------------------------------------------------##

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/stacked_barplot_soil_multi.input  
  setenv AMET_NET_INPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/Network.input
  
  # Check for plot and text output directory, create if not present
  if (! -d $AMET_OUT) then
     mkdir -p $AMET_OUT
  endif

  # R-script execution command
  R CMD BATCH --no-save --slave $AMETBASE/R_analysis_code/AQ_Stacked_Barplot_soil_multi.R $AMET_LOG
  setenv AMET_R_STATUS $status
  
  if($AMET_R_STATUS == 0) then
		echo
		echo "Statistics information"
		echo "-----------------------------------------------------------------------------------------"
		echo "Plots -- --------------------->" $AMET_OUT/${AMET_PROJECT}_${AMET_PID}_PM2.5_stacked_barplot_soil_multi.$AMET_PTYPE
		echo "-----------------------------------------------------------------------------------------"
		exit 0
  else
     echo "The AMET R script did not produce any output, please check the LOGFILE $AMET_LOG for more details on the error."
     echo "Often, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  		exit 1  
  endif
