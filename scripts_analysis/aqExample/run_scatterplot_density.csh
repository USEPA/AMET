#!/bin/csh -f
# --------------------------------
# Density Scatterplot
# -----------------------------------------------------------------------
# Purpose:
#
# This script is part of the AMET-AQ system.  This script in a 
# variation of a scatter plot.  The script plots the points of a 
# scatter plot as different colors dependent on the denisty
# of the data at that x/y location.  The greater the density of
# points, the brigher the color.  This is useful when plotting
# a large number of points, as it makes it easy to identify
# where the largest number of points on the plot occur.  This
# script is new to the AMETv1.2 code and should be considered
# as a beta script, as it has not been fully tested.
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
 
  ###  Directory where figures and text output will be directed
  setenv AMET_OUT       $AMETBASE/output/$AMET_PROJECT/scatterplot_density

  ### T/F; Set to T if the model/obs pairs are loaded in the AMET database (i.e. by setting LOAD_SITEX = T)
  setenv AMET_DB  T

  ### IF AMET_DB = F, set location of site compare output files using the environment variable OUTDIR
  #setenv OUTDIR  $AMETBASE/output/$AMET_PROJECT/

  ###  Start and End Dates of plot (YYYY-MM-DD) -- must match available dates in db or site compare files
  setenv AMET_SDATE "2016-05-01"
  setenv AMET_EDATE "2016-05-11"

  ### Process ID. This can be set to anything. It will be added to the file output name. Default is 1.
  ### The PID is particularly important if using the AMET web interface and is determined there through
  ### a random number generator.
  setenv AMET_PID 1

  ###  Custom title (if not set will autogenerate title based on variables 
  ###  and plot type)
  #  setenv AMET_TITLE "Scatterplot $AMET_PROJECT $AMET_SDATE - $AMET_EDATE"


  ###  Plot Type, options are "pdf", "png" or "both"
  setenv AMET_PTYPE both


  ### Species to Plot ###
  ### Acceptable Species Names: SO4,NO3,NH4,HNO3,TNO3,PM_TOT,PM25_TOT,PM_FRM,PM25_FRM,EC,OC,TC,O3,O3_1hrmax,O3_8hrmax
  ### SO2,CO,NO,SO4_dep,SO4_conc,NO3_dep,NO3_conc,NH4_dep,NH4_conc,precip,NOy 
  ### AE6 (CMAQv5.0) Species
  ### Na,Cl,Al,Si,Ti,Ca,Mg,K,Mn,Soil,Other,Ca_dep,Ca_conc,Mg_dep,Mg_conc,K_dep,K_conc

  setenv AMET_AQSPECIES O3_8hrmax

  ### Observation Network to plot -- One only
  ###  set to 'y' to turn on, default is off
  ###  NOTE: species are not available in every network
#  setenv AMET_CSN y
#  setenv AMET_IMPROVE y
#  setenv AMET_CASTNET y
#  setenv AMET_CASTNET_Hourly y
#  setenv AMET_CASTNET_Drydep y 
#  setenv AMET_NADP y 
#  setenv AMET_AIRMON y 
#  setenv AMET_AQS_Hourly y
  setenv AMET_AQS_Daily_O3 y
#  setenv AMET_AQS_Daily_PM y
#  setenv AMET_SEARCH y 
#  setenv AMET_SEARCH_Daily y
#  setenv AMET_CAPMON y
#  setenv AMET_NAPS_Hourly y

### Europe Networks ###

#  setenv AMET_AirBase_Hourly y
#  setenv AMET_AirBase_Daily y
#  setenv AMET_AURN_Hourly y
#  setenv AMET_AURN_Daily y
#  setenv AMET_EMEP_Hourly y
#  setenv AMET_EMEP_Daily y
#  setenv AMET_AGANET y
#  setenv AMET_ADMN y
#  setenv AMET_NAMN y

  # Log File for R script
  setenv AMET_LOG scatterplot_density.log

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
  R CMD BATCH --no-save --slave $AMETBASE/R_analysis_code/AQ_Scatterplot_density.R $AMET_LOG
  setenv AMET_R_STATUS $status
  
  if($AMET_R_STATUS == 0) then
		echo
		echo "Statistics information"
		echo "-----------------------------------------------------------------------------------------"
		echo "Plots -----------------------> $AMET_OUT/${AMET_PROJECT}_${AMET_AQSPECIES}_SITE_${AMET_PID}_scatterplot_density.$AMET_PTYPE"
		echo "Text  -----------------------> $AMET_OUT/${AMET_PROJECT}_${AMET_AQSPECIES}_SITE_${AMET_PID}_scatterplot_density.csv"
		echo "-----------------------------------------------------------------------------------------"
		exit 0
  else
     echo "The AMET R script did not produce any output, please check the LOGFILE $AMET_LOG for more details on the error."
     echo "Often, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  		exit 1  
  endif

