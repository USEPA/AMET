#!/bin/csh 
# -----------------------------------------------------------------------
# Raob vertical statistics
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# raob statistical plots of model performance for a specified day, period,
# site or group of sites. See raob.input file for extra settings including
# sample size thresholds and plotting options. Analysis includes T, RH, WS and WD.
# WNDVEC in AMET1.5+ that provided wind vector error
#
# Apr 2022: Added a loop for single time native profiles. The script now
#           runs this script for each 00/12 UTC time over date range provided
# May 2022: Added extra option for Timeseries and Profile stats options for 
#           additional criteria like state and country.
# -----------------------------------------------------------------------
####################################################################################
#                          USER CONFIGURATION OPTIONS


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
  setenv AMET_OUT  $AMETBASE/output/$AMET_PROJECT/raob
  
  # MANDATORY PRESSURE LEVEL ANALYSIS OPTIONS
  # AMET_BOUNDS_LAT and AMET_BOUNDS_LON are used to choose sites to include.
  # spatial.setSITES.all.txt file is produced in output directory. This file
  # has set SITES string that can be used below.
  setenv RAOB_SPATIAL   T 
  # Sounding timeseries statistics for defined pressure layer (AMET_PLAYER below T/F)
  # AMET_BOUNDS_LAT and AMET_BOUNDS_LON are used to choose sites for timeseries stats.
  setenv RAOB_TSERIES   T 
  # Profile statistics for all mandatory levels (T/F). 
  # NOTE: Site grouping is allowed. Done for all availiable pressure levels.
  setenv RAOB_PROFILEM  T 
  # Curtain plot of model, raob and difference on mandatory pressure levels (T/F).
  # NOTE: No site grouping allowed. Script ignores this setting and plots each site.
  setenv RAOB_CURTAINM  F 

  # NATIVE PRESSURE LEVEL ANALYSIS OPTIONS
  # Profiles of model and obs on their native levels for sites below (T/F).
  # NOTE: only done for start time below. Can be ran through loop for mutiple times.
  # NOTE: No site grouping allowed. Script ignores this setting and plots each site.
  # NOTE: Pressure level range defined by AMET_PLIM below.
  setenv RAOB_PROFILEN  F 
  # Curtain plot of model with obs profile overlaid using dots (T/F).
  # NOTE: No site grouping allowed. Script ignores this setting and plots each site.
  # NOTE: Pressure level range defined by AMET_PLIM below.
  setenv RAOB_CURTAINN  F 

  #  Date range of timeseries where year (YY), month (MM), day (DD) are
  #  the start and end values with one space between. Use two digit MM and DD.
  #  Below is the example for May 1-10, 2017
  setenv AMET_YY "2016 2016"
  setenv AMET_MM "07 07"
  setenv AMET_DD "01 31"
  setenv AMET_HH "00 00"

  #  Observation site ID array. 
  #  "ALL" will get data for all sites, but only applicable for RAOB_PROFILEM option
  #  AMET_GROUPSITES allows grouping (or not) of defined site IDs for RAOB_PROFILEM option
  set SITES=(KGSO KMHX)
  set SITES=(ALL)

  # Should SITES be grouped or averaged (T/F). Grouped sites only work for 
  # profile statistics on mandatory pressure levels via RAOB_PROFILEM T
  setenv AMET_GROUPSITES F

  # Lower and upper pressure of desired layer average statistics.
  # Used for layer average spatial statistics via RAOB_SPATIAL option. 
  setenv AMET_PLAYER "1000 100"             

  # Lower and upper pressure of desired native level profiles and 
  # curtain plots when RAOB_CURTAINN and/or setenv RAOB_PROFILEN is true
  setenv AMET_PLIM "1000 600"             

  # lat-lon plot bounds. Note that all sites in a domain
  # will be considered when stats are calculated, but the
  # spatial plots will only cover the area below.
  setenv AMET_BOUNDS_LAT "23 55"
  setenv AMET_BOUNDS_LON "-135 -60"

  # Note Extra is for custom extra specs added to query. Must know MySQL. Below are
  # examples of using US States and Countries (ref: $AMETBASE/obs/MET/metar_codes_country.txt)
  # usage of LIKE searches country names in database for string enclosed %Country%
  # WARNING: IF State or Country Criteria are set for RAOB_PROFILEM, User should set SITES=(ALL) 
  # WARNING: Can result in no data if done incorrectly. Examine query for sensibility 
  setenv AMET_EXTRA "AND (s.state='NC' OR s.state='GA' OR s.state='FL' OR s.state='VA' OR s.state='SC')"
  setenv AMET_EXTRA "AND (s.state!='UT' AND s.state!='NV' AND s.state!='CO' AND s.state!='NM' AND s.state!='AZ')"
  setenv AMET_EXTRA "AND (s.country LIKE '%Mexico%' OR s.country LIKE '%Canada%')"
  setenv AMET_EXTRA "AND (s.country NOT LIKE '%United States%')"

  # Do you want a CVS files with Spatial and Daily Statistics?
  setenv AMET_TEXTSTATS T

  #  Plot Type, plot options are is "png" or "pdf" are only plot formats unless user modifies
  #  the main script in $AMET/R_analysis_code/MET_daily_barplot.R
  setenv AMET_PTYPE pdf             

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/run_info_MET.R
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/raob.input  
  setenv AMETRSTATIC $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/raob.static.input
  
  # Check for plot and text output directory, create if not present
  mkdir -p $AMETBASE/output/$AMET_PROJECT
  mkdir -p $AMET_OUT
  
  # NOTE: Do not modify; this statement is necessary if an array of sites is specified.
  setenv AMET_SITEID "$SITES[*]"

  ################################################################################
  # New 2022 update for single time native profile plotting. This is added cshell scripting
  # to facilitate ease of use. Prior version required running the script for each single
  # profile time. This new functionality take existing date range for other scripts and
  # first turns off RAOB_PROFILEN and runs script for other analyses. Then reruns the script
  # in a loop for the RAOB_PROFILEN only by turning off all other options.
  set profilen_loop=0
  if(${RAOB_PROFILEN} == "T") then
    echo "Single time native profile plots of RAOB and model soundings = .True."

    set envstr="${AMET_YY}"
    set split_y = ($envstr:as/ / /)
    set envstr="${AMET_MM}"
    set split_m = ($envstr:as/ / /)
    set envstr="${AMET_DD}"
    set split_d = ($envstr:as/ / /)
    set begday=${split_y[1]}${split_m[1]}${split_d[1]}
    set endday=${split_y[2]}${split_m[2]}${split_d[2]}

    set profilen_loop=1
    setenv RAOB_PROFILEN  F
  endif
  ################################################################################

  # Run script for all options other than PROFILEN
  R --slave --no-save < $AMETBASE/R_analysis_code/MET_raob.R 

  ################################################################################
  # Run PROFILEN only in loop over defined period for single profile comparisons
  if(${profilen_loop} == 1) then
    setenv RAOB_PROFILEN  T
    setenv RAOB_SPATIAL   F 
    setenv RAOB_TSERIES   F 
    setenv RAOB_PROFILEM  F 
    setenv RAOB_CURTAINM  F
    setenv RAOB_CURTAINN  F

    set date = $begday
    echo $begday
    @ count = 1
    #-- Main LOOP Over Days defined above.
    while ( $date <= $endday )
      setenv YYYYS `echo $date |cut -b1-4`
      setenv YYS   `echo $date |cut -b3-4`
      setenv MMS   `echo $date |cut -b5-6`
      setenv DDS   `echo $date |cut -b7-8`
      echo 'Looping single profile comparison for date:' $YYYYS $MMS $DDS
      setenv AMET_YY "${YYYYS} ${YYYYS}"
      setenv AMET_MM "${MMS} ${MMS}"
      setenv AMET_DD "${DDS} ${DDS}"
      setenv AMET_HH "00 00"
      R --slave --no-save < $AMETBASE/R_analysis_code/MET_raob.R 
      setenv AMET_HH "12 12"
      R --slave --no-save < $AMETBASE/R_analysis_code/MET_raob.R 
      set date = `date -d "$date 1 days" '+%Y%m%d' `
      @ count ++
    end
  endif
  ################################################################################


exit(1)  

