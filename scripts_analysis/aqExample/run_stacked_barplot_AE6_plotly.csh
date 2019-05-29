#!/bin/csh -f
# --------------------------------
# AERO6 stacked Bar plot using plotly
# -----------------------------------------------------------------------
# Purpose:
#
# The code is interactive with the AMET_AQ system developed by Wyat
# Appel.  Data are queried from the MYSQL database for the CSN or
# SEARCH networks.  Data are then averaged for SO4, NO3, NH4, EC, OC
# soil, NaCl, NCOM, other and PM2.5 for the model and ob values.  
# These averages are then plotted on a stacked bar plot. This script
# does not work with CMAQ aerosol modules before AERO6, as the required
# species soil, NaCl, and NCOM are not available before AERO6. The script
# will work for CMAQ aerosol modules 6 and beyond. This script produces an
# interactive html file.
#
# Initial version:  Wyat Appel - May, 2019
# -----------------------------------------------------------------------

  
  #--------------------------------------------------------------------------
  # These are the main controlling variables for the R script
  
  ###  Top of AMET directory
  setenv AMET_DATABASE  amet
  setenv AMET_PROJECT   aqExample
  setenv MYSQL_CONFIG   $AMETBASE/configure/amet-config.R

  ### T/F; Set to T if the model/obs pairs are loaded in the AMET database (i.e. by setting LOAD_SITEX = T)
  setenv AMET_DB  T

  ### IF AMET_DB = F, set location of site compare output files using the environment variable OUTDIR
  #setenv OUTDIR  $AMETBASE/output/$AMET_PROJECT/sitex_output

  ### Set the project name to be used for model-to-model comparisons ###
  setenv AMET_PROJECT2  aqExample

  ### IF AMET_DB = F, set location of site compare output files using the environment variable OUTDIR
  #setenv OUTDIR2  $AMETBASE/output/$AMET_PROJECT2/sitex_output
 
  ###  Directory where figures and text output will be directed
  setenv AMET_OUT       $AMETBASE/output/$AMET_PROJECT/stacked_barplot_AE6_plotly
  
  ###  Start and End Dates of plot (YYYY-MM-DD) -- must match available dates in db or site compare files
  setenv AMET_SDATE "2016-07-01"
  setenv AMET_EDATE "2016-07-31"

  ### Process ID. This can be set to anything. It will be added to the file output name. Default is 1.
  ### The PID is particularly important if using the AMET web interface and is determined there through
  ### a random number generator.
  setenv AMET_PID 1

  ###  Custom title (if not set will autogenerate title based on variables 
  ###  and plot type)
  #  setenv AMET_TITLE "CSN PM2.5 $AMET_PROJECT $AMET_SDATE - $AMET_EDATE"
  setenv AMET_TITLE ""

  ### Species to Plot ###
  ### Acceptable Species Names: PM_TOT,PM_FRM,PM25_TOT,PM25_FRM

  setenv AMET_AQSPECIES PM_TOT

  ### Observation Network to plot -- One only
  ### Uncomment to set to 'T' and process that nework,
  ### default is off (commented out)
  ### NOTE: species are not available in every network
  ### See AMET User's guide for details on each network

  ### North America Networks ###

  #  setenv AMET_CSN            T
    setenv AMET_IMPROVE        T
  #  setenv AMET_CASTNET        T
  #  setenv AMET_CASTNET_Hourly T
  #  setenv AMET_CASTNET_Drydep T
  #  setenv AMET_NADP           T
  #  setenv AMET_AIRMON         T
  #  setenv AMET_AQS_Hourly     T
  #  setenv AMET_AQS_Daily_O3   T
  #  setenv AMET_AQS_Daily      T
  #  setenv AMET_SEARCH         T
  #  setenv AMET_SEARCH_Daily   T
  #  setenv AMET_NAPS_Hourly    T
  #  setenv AMET_NAPS_Daily_O3  T

  ### Europe Networks ###

  #  setenv AMET_AirBase_Hourly T
  #  setenv AMET_AirBase_Daily  T
  #  setenv AMET_AURN_Hourly    T
  #  setenv AMET_AURN_Daily     T
  #  setenv AMET_EMEP_Hourly    T
  #  setenv AMET_EMEP_Daily     T
  #  setenv AMET_AGANET         T
  #  setenv AMET_ADMN           T
  #  setenv AMET_NAMN           T

  ### Gloabl Networks ###

  # setenv AMET_NOAA_ESRL_O3    T
  # setenv AMET_TOAR            T

  #  Plot Type, options are "html"
  setenv AMET_PTYPE html

  # Log File for R script
  setenv AMET_LOG stacked_barplot_AE6.log


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
  R CMD BATCH --no-save --slave $AMETBASE/R_analysis_code/AQ_Stacked_Barplot_AE6_plotly.R $AMET_LOG
  setenv AMET_R_STATUS $status
  
  if($AMET_R_STATUS == 0) then
		echo
		echo "Statistics information"
		echo "-----------------------------------------------------------------------------------------"
		echo "Plots -- --------------------->" $AMET_OUT/${AMET_PROJECT}_${AMET_PID}_stacked_barplot_AE6.$AMET_PTYPE
		echo "-----------------------------------------------------------------------------------------"
		exit 0
  else
     echo "The AMET R script did not produce any output, please check the LOGFILE $AMET_LOG for more details on the error."
     echo "Often, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  		exit 1  
  endif
