#!/bin/csh -f
# --------------------------------
# Monthly Statistics Plot 
# -----------------------------------------------------------------------
# Purpose:
#
# THIS FILE CONTAINS CODE TO DRAW A CUSTOMIZED PLOTS OF
# NMB, NME, CORRELATION, and FB, FE and RMSE.
# The script is ideally used with a long time period, specifically
# a year.  Average monthly domain-wide statistics are calculated 
# and plotted.  
#
# Plot1: Model and Ob Means (sum for precip and deposition species)
# Plot2: NMB, NME and CORRELATION
# Plot3: Median Bias, Median Error and RMSE 
#
# Any one of the computed statistics can be plotted with a small
# change to the script.  The script works with multiple years as
# well. This script is new to the AMETv1.2 code and has been updated
# for AMETv1.3 and AMET_v14b.
#
# Initial version:  Wyat Appel - Dec, 2012
#
# Revised version:  Wyat Appel - Sep, 2018
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

  ###  Directory where figures and text output will be directed
  setenv AMET_OUT       $AMETBASE/output/$AMET_PROJECT/monthly_stat_plot
  
  ###  Start and End Dates of plot (YYYY-MM-DD) -- must match available dates in db or site compare files
  setenv AMET_SDATE "2016-07-01"
  setenv AMET_EDATE "2016-07-31"
 
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
  ### Acceptable Species Names: SO4,NO3,NH4,HNO3,TNO3,PM25,EC,OC,TC,O3,O3_1hrmax,O3_8hrmax
  ### SO2,CO,NO,SO4_dep,SO4_conc,NO3_dep,NO3_conc,NH4_dep,NH4_conc,precip,NOy 
  ### AE6 (CMAQv5.0) Species
  ### Na,Cl,Al,Si,Ti,Ca,Mg,K,Mn,Soil,Other,Ca_dep,Ca_conc,Mg_dep,Mg_conc,K_dep,K_conc

  setenv AMET_AQSPECIES SO4

  ### Observation Network to plot -- One only
  ### Uncomment to set to 'T' and process that nework,
  ### default is off (commented out)
  ### NOTE: species are not available in every network
  ### See AMET User's guide for details on each network

  ### North America Networks ###

  #  setenv AMET_CSN            T
  #  setenv AMET_IMPROVE        T
  #  setenv AMET_CASTNET        T
  #  setenv AMET_CASTNET_Hourly T
  #  setenv AMET_CASTNET_Drydep T
  #  setenv AMET_NADP           T
  #  setenv AMET_AIRMON         T
  #  setenv AMET_AQS_Hourly     T
  #  setenv AMET_AQS_Daily_O3   T
    setenv AMET_AQS_Daily       T
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

  # Log File for R script
  setenv AMET_LOG monthly_stat_plot.log

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
  R CMD BATCH --no-save --slave $AMETBASE/R_analysis_code/AQ_Monthly_Stat_Plot.R $AMET_LOG
  setenv AMET_R_STATUS $status
  
  if($AMET_R_STATUS == 0) then
		echo
		echo "Statistics information"
		echo "-----------------------------------------------------------------------------------------"
		echo "Plots -----------------------> $AMET_OUT/${AMET_PROJECT}_${AMET_AQSPECIES}_${AMET_PID}_plot1.$AMET_PTYPE"
                echo "Plots -----------------------> $AMET_OUT/${AMET_PROJECT}_${AMET_AQSPECIES}_${AMET_PID}_stat_plot1.$AMET_PTYPE"
                echo "Plots -----------------------> $AMET_OUT/${AMET_PROJECT}_${AMET_AQSPECIES}_${AMET_PID}_stat_plot2.$AMET_PTYPE"
		echo "Text  -----------------------> $AMET_OUT/${AMET_PROJECT}_${AMET_AQSPECIES}_${AMET_PID}_stats.csv"
		echo "-----------------------------------------------------------------------------------------"
		exit 0
  else
     echo "The AMET R script did not produce any output, please check the LOGFILE $AMET_LOG for more details on the error."
     echo "Often, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  		exit 1  
  endif

