#!/bin/csh -f
# --------------------------------
# Bar plot - Soil species
# -----------------------------------------------------------------------
# Purpose:
#
# THIS FILE CONTAINS CODE TO DRAW A CUSTOMIZED "STACKED BAR PLOT".
# The code is interactive with the AMET_AQ system developed by Wyat
# Appel.  Data are queried from the MYSQL database for the CSN or
# IMPROVE networks. The code creates a stacked barplot of the 
# major soil species available in CMAQv5.0 w/ AERO6. The script
# will accept a single network (either IMPROVE or CSN) and one or
# two model simulations. The plot is similar in design to the standard 
# stacked barplot.
#
# Initial version:  Wyat Appel - Dec, 2012
#
# Revised version:  Wyat Appel - Sep, 2018
# -----------------------------------------------------------------------

  
  #--------------------------------------------------------------------------
  # These are the main controlling variables for the R script
  
  ###  Top of AMET directory
  setenv AMETBASE       ~/AMET
  setenv AMET_DATABASE  amet
  setenv AMET_PROJECT   aqExample
  setenv MYSQL_CONFIG   $AMETBASE/configure/amet-config.R

  ### T/F; Set to T if the model/obs pairs are loaded in the AMET database (i.e. by setting LOAD_SITEX = T)
  setenv AMET_DB  T

  ### IF AMET_DB = F, set location of site compare output files using the environment variable OUTDIR
  #setenv OUTDIR  $AMETBASE/output/$AMET_PROJECT/

  ###  Directory where figures and text output will be directed
  setenv AMET_OUT       $AMETBASE/output/$AMET_PROJECT/stacked_barplot_soil
  
  ###  Start and End Dates of plot (YYYY-MM-DD) -- must match available dates in db or site compare files
  setenv AMET_SDATE "2016-05-01"
  setenv AMET_EDATE "2016-05-11"

  ### Process ID. This can be set to anything. It will be added to the file output name. Default is 1.
  ### The PID is particularly important if using the AMET web interface and is determined there through
  ### a random number generator.
  setenv AMET_PID 1

  ###  Custom title (if not set will autogenerate title based on variables 
  ###  and plot type)
  #  setenv AMET_TITLE "Traces Metals for $AMET_PROJECT $AMET_SDATE - $AMET_EDATE"

  ### Species to Plot ###
  ### Acceptable Species Names: Soil

  setenv AMET_AQSPECIES Soil

### Observation Network to plot
  ###  set to 'y' to turn on, default is off
  ###  NOTE: species are not available in every network
#  setenv AMET_CSN y
  setenv AMET_IMPROVE y

  ###  Plot Type, options are "pdf", "png", or "both"
  setenv AMET_PTYPE png 

  ### Log File for R script
  setenv AMET_LOG stacked_barplot_soil.log


##--------------------------------------------------------------------------##
##                Most users will not need to change below here
##--------------------------------------------------------------------------##

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/all_scripts.input  
  setenv AMET_NET_INPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/Network.input
  
  # Check for plot and text output directory, create if not present
  if (! -d $AMET_OUT) then
     mkdir -p $AMET_OUT
  endif

  # R-script execution command
  R CMD BATCH --no-save --slave $AMETBASE/R_analysis_code/AQ_Stacked_Barplot_soil.R $AMET_LOG
  setenv AMET_R_STATUS $status
  
  if($AMET_R_STATUS == 0) then
		echo
		echo "Statistics information"
		echo "-----------------------------------------------------------------------------------------"
		echo "Plots -- --------------------->" $AMET_OUT/${AMET_PROJECT}_${AMET_PID}_stacked_barplot_soil.$AMET_PTYPE
		echo "-----------------------------------------------------------------------------------------"
		exit 0
  else
     echo "The AMET R script did not produce any output, please check the LOGFILE $AMET_LOG for more details on the error."
     echo "Often, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  		exit 1  
  endif
