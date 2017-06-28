#!/bin/csh -f
# --------------------------------
# Timeseries plots
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# timeseries plot of model and observed temperature, wind and moisture 
# over user specified period. Obs site is labels by ID and model by project
# ID. User can specify two model runs as a means to compare sensitivities.
# User can also group all sites and do a site average obs-model plot.
# -----------------------------------------------------------------------
####################################################################################
###################################################################################
#                          USER CONFIGURATION OPTIONS
  #  Top of AMET directory
  setenv AMETBASE /home/grc/AMET_v13 

  # MySQL Server and AMET database configuration file. Default AMET config dir.
  # For security make file only readable by you. With the following variables
  # mysqllogin   <- yourlogin
  # mysqlpasswrd <- yourpassword
  setenv MYSQL_CONFIG  $AMETBASE/configure/amet-config.R

  # MySQL database server connection and AMET database
  setenv AMET_DATABASE  amad_nrt
  setenv MYSQL_SERVER   darwin.rtpnc.epa.gov
  
  #  AMET project id or simulation id. Note: Project2 allows comparsions of two model
  #  runs with obs including statistics. If left unset, it's ignored.
  setenv AMET_PROJECT wrf_conus_12km
  setenv AMET_PROJECT2
  
  #  Directory where figures and text output will be directed
  setenv AMET_OUT   $AMETBASE/output/$AMET_PROJECT/timeseries
  
  #  Observation site for timeseries. If mulitple sites are specificed like example two below
  #  Sites and corresponding model values are either averaged into a timeseries if 
  # AMET_GROUPSITES=TRUE or a timeseries plot for each site is generated in a loop over sites
  set SITES=(KILM KORL KRDU KDCA KLAX)
  

  # these be grouped or averaged or should a separate timeseries be
  # generated for each site (TRUE - averaged; FALSE - separate)?
  setenv AMET_GROUPSITES FALSE 

  #  Date range of timeseries where year (YY), month (MM), day (DD) are 
  #  the start and end values with one space between
  #  Below is the example for May 1-10, 2017
  setenv AMET_YY "2017 2017"             
  setenv AMET_MM "05 05"             
  setenv AMET_DD "01 10"             

  #  Additional criteria to add to site query
  setenv AMET_EXTRA1              
  setenv AMET_EXTRA2              

  #  Plot Type, plot options are is "png" or "pdf" are only plot formats
  #  unless user modifies the main script in:
  #  $AMET/R_analysis_code/MET_timeseries.R
  #  For timeseries pdf is recommended.
  setenv AMET_PTYPE pdf            

#---------------------------------------------------------------------------------------
  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/timeseries.input  
  
  # NOTE: Do not modify; this statement is necessary if an array of sites is specified.
  setenv AMET_SITEID "$SITES[*]"
  
  # Create output directories for project
  mkdir -p $AMETBASE/output/$AMET_PROJECT
  mkdir -p $AMET_OUT

  # R-script execution command
  R BATCH --no-save < $AMETBASE/R_analysis_code/MET_timeseries.R 

  if( $AMET_GROUPSITES == "TRUE") then
    set PLOT_ID="GROUP_AVG"
  else
      set PLOT_ID=$SITES[1]
  endif

  if( $#SITES == 1) then
      set PLOT_ID=$SITES[1]
  endif


  if(-e $AMET_OUT/$AMET_PROJECT.$PLOT_ID.$AMET_PTYPE) then
    echo
    echo "Examples of plots and data files that were produced"
    echo "-----------------------------------------------------------------------------------------"
    echo "Timeseries plot is  ---------->" $AMET_OUT/$AMET_PROJECT.$PLOT_ID.$AMET_PTYPE
    echo
    echo "Text statistics are in file:-->" $AMET_OUT/$AMET_PROJECT.$PLOT_ID.txt
    echo "-----------------------------------------------------------------------------------------"
  else if(-e $AMET_OUT/$AMET_PROJECT.$SITES[1].$AMET_PTYPE) then
    echo
    echo "Examples of plots and data files that were produced"
    echo "-----------------------------------------------------------------------------------------"
    echo "Timeseries plot is  ---------->" $AMET_OUT/$AMET_PROJECT.$SITES[1].$AMET_PTYPE
    echo 
    echo "Text statistics are in file:-->" $AMET_OUT/$AMET_PROJECT.$SITES[1].txt
    echo "-----------------------------------------------------------------------------------------"
  else
     echo "Please check options above, the AMET R script did not produce any output."
     echo "Typically, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  endif
exit(1)  
  
  
  
  
