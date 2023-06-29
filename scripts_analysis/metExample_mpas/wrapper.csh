#!/bin/csh -f

  # WRAPPER for running mutiple detailed analysises using a single highly configurable script.

  # -  WRAPPER_RUNID has two, two character IDs with period dividing (e.g., SP.MN) to control
  #    the analysis script (e.g., spatial surface) and a predefined mode of that script (e.g., monthly).

  # -  Analysis Script IDs:   SP=spatial surface  DB= daily bar stats  SM=summary stats
  #                           SW=sw radiation     UA=upper-air/raob    PR=PRISM analysis

  # -  MODE ID:               MN= montly                     SE=seasonal          
  #                           RM=climate regions monthly     RS= climate regions seasonal      
  #                           DA=daily                       AN=annual

  # -  These are highly flexible evaluation methods that users can build full analysis 
  #    packages for model simulations by using this as an example. Some notes:

  # -  Config inputs below are required just like other scripts for base information and need
  #    to match the expected analysis.

  # -  The wrapper script loads these R config settings first to set the R environment.
  #    Then writes a small temporary config file that is read by main R script so specific
  #    settings like date, region, state, etc can be altered in a loop of the main script.

  # -  Best examples provided here are a loop over months of a year or seasons where only the date
  #    needs a change. Regional example is also coded for easy loop of the analyses over months/seasons
  #    and Climate Regions defined by a collection of states.

  # MySQL Server and AMET database configuration file.
  # For security make file only readable by you. With the following variables
  # These are the only required for meteorological analysis. AQ requires more.
  # mysqllogin   <- yourlogin
  # mysqlpasswrd <- yourpassword
  setenv MYSQL_CONFIG  $AMETBASE/configure/amet-config.R

  # MySQL database server connection and AMET database
  setenv AMET_DATABASE  amad_nrt
  setenv MYSQL_SERVER   amet.ib

  #  AMET project id or simulation id
  setenv AMET_PROJECT   metExample_wrf 

  # lat-lon plot bounds. Note that all sites in a domain
  # will be considered when stats are calculated, but the
  # spatial plots will only cover the area below.
  # In Wrapper run this is also used for Daily Stats, 
  # Summary stats and RAOB Spatial/TimesSeries/Profile stats
  setenv AMET_BOUNDS_LAT "23 55"
  setenv AMET_BOUNDS_LON "-125 -65"
  
  # PRISM VARS
  setenv AMET_GUI   FALSE
  
  #  Directory where figures and text output will be directed
  setenv AMET_OUT  $AMETBASE/output/$AMET_PROJECT/wrapper
  mkdir -p ${AMET_OUT}

  #  Plot type definition
  setenv AMET_PTYPE pdf

  ## Below are R config input files (base & static) required for each analysis script option.
  ## Above each in comments are the possible WRAPPER_RUNID combinations. 
  ## Uncomment R exe line to enable various analyses and/or add more by copy and mod of WRAPPER_RUNID.

  # If set correctly, this master run config file can be used for all scripts.
  setenv AMETRINPUT  $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/run_info_MET.R

  # Daily (PR.DA), Monthly (PR.MN) & Annual (PR.AN) Precip Analysis
  # Annual for AMET_YEAR below. Monthly for AMET_YEAR below
  # Daily starts/ends on ms, me, ds & de definitions in input_files/run_info_MET.R config file.
  setenv AMET_YEAR  2016
  setenv WRAPPER_RUNID PR.MN
  #R --no-save --slave < ${AMETBASE}/R_analysis_code/MET_wrapper.R 

  # Daily surface-base statistics
  # WRAPPER_RUNID as coded in $AMETBASE/R_analysis_code/MET_wrapper.R can be: 
  # DB.MN, DB.SE, DB.RM or DB.RS
  setenv AMET_YEAR 2016
  setenv THRESHOLD 120
  setenv WRAPPER_RUNID DB.AN
  #R --no-save --slave < ${AMETBASE}/R_analysis_code/MET_wrapper.R 

  # Summary (all & diurnal) of surface-base statistics
  # WRAPPER_RUNID as coded in $AMETBASE/R_analysis_code/MET_wrapper.R can be: 
  # SM.MN, SM.SE, SM.RM or SM.RS
  setenv WRAPPER_RUNID SM.RM
  #R --no-save --slave < ${AMETBASE}/R_analysis_code/MET_wrapper.R 

  # Site-specific statistic provided in spatial maps of domain & text output
  # WRAPPER_RUNID as coded in $AMETBASE/R_analysis_code/MET_wrapper.R can be: 
  # SP.MN, SP.SE
  setenv WRAPPER_RUNID SP.MN
  setenv AMETRSTATIC $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/spatial_surface.static.input  
  #R --no-save --slave < ${AMETBASE}/R_analysis_code/MET_wrapper.R 

  # Upper-air analysis including spatial stats (only monthly and seasonal), time series stats and profile stats
  # See master run_info_MET.R config file (find RAOB) for more detailed settings like layers, etc.
  # WRAPPER_RUNID as coded in $AMETBASE/R_analysis_code/MET_wrapper.R can be: 
  # UA.MN, UA.SE, UA.RM and UA.RS
  setenv WRAPPER_RUNID UA.RS
  setenv AMETRSTATIC $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/raob.static.input
  #R --no-save --slave < ${AMETBASE}/R_analysis_code/MET_wrapper.R 

  # Shortwave radiation analysis (seasonal and monthly only)
  # WRAPPER_RUNID as coded in $AMETBASE/R_analysis_code/MET_wrapper.R can be: 
  # SW.MN, SW.SE
  setenv WRAPPER_RUNID SW.MN
  setenv AMETRSTATIC $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/plot_radiation.static.input  
  #R --no-save --slave < ${AMETBASE}/R_analysis_code/MET_wrapper.R 


exit(1)  
  
  
  
  
  
  
