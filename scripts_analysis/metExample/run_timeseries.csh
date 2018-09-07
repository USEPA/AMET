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
  setenv AMETBASE /home/xxxx/AMET_v13 

  # MySQL Server and AMET database configuration file.
  # For security make file only readable by you. With the following variables
  # mysqllogin   <- yourlogin
  # mysqlpasswrd <- yourpassword
  setenv MYSQL_CONFIG  $AMETBASE/configure/amet-config.R

  # MySQL database server connection and AMET database. You can choose projects from 
  # different databases to compare. If all in the same database just set DATABASE1&2 the same.
  setenv AMET_DATABASE1  amet_test1
  setenv AMET_DATABASE2  amet_test2
  setenv MYSQL_SERVER   xxxxxxx.epa.gov
  
  #  AMET project id or simulation id. Note: Project2 allows comparisons of two model
  #  runs with obs including statistics. If left unset, it's ignored.
  setenv AMET_PROJECT1  metExample
  setenv AMET_PROJECT2  metExample
  
  #  Directory where figures and text output will be directed
  setenv AMET_OUT   $AMETBASE/output/$AMET_PROJECT1/timeseries
  
  #  Observation site for timeseries. If multiple sites are specified like example two below
  #  Sites and corresponding model values are either averaged into a timeseries if 
  # AMET_GROUPSITES=TRUE or a timeseries plot for each site is generated in a loop over sites
  set SITES=(KILM KORL KRDU KDCA KLAX)
  

  # these be grouped or averaged or should a separate timeseries be
  # generated for each site (TRUE - averaged; FALSE - separate)?
  setenv AMET_GROUPSITES FALSE 

  #  Date range of timeseries where year (YY), month (MM), day (DD) are 
  #  the start and end values with one space between
  #  Below is the example for May 1-10, 2017
  setenv AMET_YY "2011 2011"             
  setenv AMET_MM "07 08"             
  setenv AMET_DD "01 01"             

  #  Additional criteria to add to site query
  setenv AMET_EXTRA1              
  setenv AMET_EXTRA2              

  #  Plot Type, plot options are "png" or "pdf" are only plot formats
  #  unless user modifies the main script in:
  #  $AMET/R_analysis_code/MET_timeseries.R
  #  For timeseries pdf is recommended.
  setenv AMET_PTYPE pdf            

#---------------------------------------------------------------------------------------
  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT1/input_files/timeseries.input  
  
  # NOTE: Do not modify; this statement is necessary if an array of sites is specified.
  setenv AMET_SITEID "$SITES[*]"
  
  # Create output directories for project
  mkdir -p $AMETBASE/output/$AMET_PROJECT1
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


  if(-e $AMET_OUT/$AMET_PROJECT1.$PLOT_ID.$AMET_PTYPE) then
    echo
    echo "Examples of plots and data files that were produced"
    echo "-----------------------------------------------------------------------------------------"
    echo "Timeseries plot is  ---------->" $AMET_OUT/$AMET_PROJECT1.$PLOT_ID.$AMET_PTYPE
    echo
    echo "Text statistics are in file:-->" $AMET_OUT/$AMET_PROJECT1.$PLOT_ID.txt
    echo "-----------------------------------------------------------------------------------------"
  else if(-e $AMET_OUT/$AMET_PROJECT1.$SITES[1].$AMET_PTYPE) then
    echo
    echo "Examples of plots and data files that were produced"
    echo "-----------------------------------------------------------------------------------------"
    echo "Timeseries plot is  ---------->" $AMET_OUT/$AMET_PROJECT1.$SITES[1].$AMET_PTYPE
    echo 
    echo "Text statistics are in file:-->" $AMET_OUT/$AMET_PROJECT1.$SITES[1].txt
    echo "-----------------------------------------------------------------------------------------"
  else
     echo "Please check options above, the AMET R script did not produce any output."
     echo "Typically, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  endif
exit(1)  
  
  
  
  
