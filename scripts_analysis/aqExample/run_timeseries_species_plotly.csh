#!/bin/csh -f
 #--------------------------------
 # Multi Species Timeseries (plotly version)
 # -----------------------------------------------------------------------
 # Purpose:
 # This is an example c-shell script to run the R-script that generates
 # a timeseries plot. This version of the timeseries plot multiple species
 # from the same simulation and network. The script can accept multiple sites,
 # as they will be time averaged to create the timeseries plot.  The script
 # also plots the bias, RMSE and correlation between the obs and model. This
 # version of the script utilizes the plotly R package to create an interactive
 # html plot.
 #
 # Initial version:  Wyat Appel - Apr, 2022
 # -----------------------------------------------------------------------

  
  #--------------------------------------------------------------------------
  # These are the main controlling variables for the R script
  
  ###  Top of AMET directory
  setenv AMETBASE       /home/AMETv14
  setenv AMET_DATABASE  amet
  setenv AMET_PROJECT   aqExample
  setenv MYSQL_CONFIG   $AMETBASE/configure/amet-config.R

  ### T/F; Set to T if the model/obs pairs are loaded in the AMET database (i.e. by setting LOAD_SITEX = T)
  setenv AMET_DB  T

  ### IF AMET_DB = F, set location of site compare output files using the environment variable OUTDIR
  #setenv OUTDIR  $AMETBASE/output/$AMET_PROJECT/sitex_output

  ### IF AMET_DB = F, set location of site compare output files using the environment variable OUTDIR
  #setenv OUTDIR2  $AMETBASE/output/$AMET_PROJECT2/sitex_output

  ###  Directory where figures and text output will be directed
  setenv AMET_OUT       $AMETBASE/output/$AMET_PROJECT/timeseries_multi_species

  ###  Start and End Dates of plot (YYYY-MM-DD) -- must match available dates in db or site compare files
  setenv AMET_SDATE "2016-07-01"
  setenv AMET_EDATE "2016-07-11"

  ### Process ID. This can be set to anything. It will be added to the file output name. Default is 1.
  ### The PID is particularly important if using the AMET web interface and is determined there through
  ### a random number generator.
  setenv AMET_PID 1

  ###  Custom title (if not set will autogenerate title based on variables 
  ###  and plot type)
  setenv AMET_TITLE ""
  #  setenv AMET_TITLE "Time Series Plot $AMET_PROJECT $AMET_SDATE - $AMET_EDATE"

  ###  Plot Type, options are "html"
  setenv AMET_PTYPE html

  # Additional query to subset the data.
  # Averages over all monitors that meet this additional criteria
  # Note: This is added to the sql query. If commented out, it will
  # automatically get all monitors for the above network.
  # Select by Monitor ID: 
  # Note: the monitor must correspond to the network and species
#  setenv AMET_ADD_QUERY "and s.stat_id='170310064'"

  # Select by state(s)
#  setenv AMET_ADD_QUERY "and (s.state='NY' or s.state='MA')"

  # label for plot - indicates state 
  # if "All", will not label plot w/ state
  setenv AMET_STATELABEL "All"
#  setenv AMET_STATELABEL "NY & MA"


  ### Species to Plot ###
  ### Acceptable Species Names: SO4,NO3,NH4,HNO3,TNO3,PM_TOT,PM25_TOT,PM_FRM,PM25_FRM,EC,OC,TC,O3,O3_1hrmax,O3_8hrmax
  ### SO2,CO,NO,SO4_dep,SO4_conc,NO3_dep,NO3_conc,NH4_dep,NH4_conc,precip,NOy 
  ### AE6 (CMAQv5.0) Species
  ### Na,Cl,Al,Si,Ti,Ca,Mg,K,Mn,Soil,Other,Ca_dep,Ca_conc,Mg_dep,Mg_conc,K_dep,K_conc

  setenv AMET_AQSPECIES PM_TOT,SO4
#  setenv AMET_AQSPECIES SO4

  ### Observation Network to plot -- One only
  ###  set to 'y' to turn on, default is off
  ###  NOTE: species are not available in every network
  setenv AMET_CSN y
#  setenv AMET_IMPROVE y
#  setenv AMET_CASTNET y
#  setenv AMET_CASTNET_Hourly y
#  setenv AMET_CASTNET_Daily_O3 y
#  setenv AMET_CASTNET_Drydep y
#  setenv AMET_NADP y
#  setenv AMET_AIRMON y
#  setenv AMET_AQS_Hourly y
#  setenv AMET_AQS_Daily_O3 y
#  setenv AMET_AQS_Daily y
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
  setenv AMET_LOG timeseries_multi_species.log
  
##--------------------------------------------------------------------------##
##                Most users will not need to change below here
##--------------------------------------------------------------------------##

  ## Set the input file for this R script
#  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/timeseries.input  
setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/all_scripts.input
  setenv AMET_NET_INPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/Network.input
  
  # Check for plot and text output directory, create if not present
  if (! -d $AMET_OUT) then
     mkdir -p $AMET_OUT
  endif

  # R-script execution command
  R CMD BATCH --no-save --slave $AMETBASE/R_analysis_code/AQ_Timeseries_multi_species.R $AMET_LOG
  setenv AMET_R_STATUS $status
  
  if($AMET_R_STATUS == 0) then
		echo
		echo "Statistics information"
		echo "-----------------------------------------------------------------------------------------"
		echo "Plots ----------------------->" $AMET_OUT/${AMET_PROJECT}_multispec_${AMET_PID}_timeseries.$AMET_PTYPE
		echo "-----------------------------------------------------------------------------------------"
		exit 0
  else
     echo "The AMET R script did not produce any output, please check the LOGFILE $AMET_LOG for more details on the error."
     echo "Often, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  		exit 1  
  endif
