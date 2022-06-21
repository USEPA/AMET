#!/bin/csh -f
# -----------------------------------------------------------------------
# Timeseries plot for moisture: T, Q, RH and PS
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# timeseries plot of model and observed temperature, moisture, relative humidity 
# and sfc pressure over user specified period. Obs site is labels by ID and model 
# by project ID. User can specify two model runs as a means to compare sensitivities.
# User can also group all sites and do a site average obs-model plot.
# -----------------------------------------------------------------------
####################################################################################
###################################################################################
#                          USER CONFIGURATION OPTIONS

  # MySQL Server and AMET database configuration file.
  # For security make file only readable by you. With the following variables
  # mysqllogin   <- yourlogin
  # mysqlpasswrd <- yourpassword
  setenv MYSQL_CONFIG  $AMETBASE/configure/amet-config.R

  # MySQL database server connection and AMET database
  setenv AMET_DATABASE1  amet
  setenv AMET_DATABASE2  amet
  setenv MYSQL_SERVER   localhost
  
  #  AMET project id or simulation id. Note: Project2 allows comparsions of two model
  #  runs with obs including statistics. If left unset, it's ignored.
  setenv AMET_PROJECT    metExample_mpas
  setenv AMET_PROJECT1 metExample_mpas
  setenv AMET_PROJECT2 metExample_wrf 
  
  #  Directory where figures and text output will be directed
  setenv AMET_OUT   $AMETBASE/output/$AMET_PROJECT1/timeseries_rh
  
  #  Observation site for timeseries. If mulitple sites are specificed like example two below
  #  Sites and corresponding model values are either averaged into a timeseries if 
  # AMET_GROUPSITES=TRUE or a timeseries plot for each site is generated in a loop over sites
  set SITES=(KILM KORL KRDU KDCA KLAX)
  

  # these be grouped or averaged or should a separate timeseries be
  # generated for each site (TRUE - averaged; FALSE - separate)?
  setenv AMET_GROUPSITES FALSE 

  #  Date range of timeseries where year (YY), month (MM), day (DD) are the 
  #  start and end values with one space between. Use two digit MM and DD.
  #  Below is the example for July 1-Aug 1, 2011
  setenv AMET_YY "2016 2016"             
  setenv AMET_MM "07 08"             
  setenv AMET_DD "01 01"             

  #  Additional criteria to add to site query
  setenv AMET_EXTRA1              
  setenv AMET_EXTRA2              

  #  Plot Type, plot options are is "png" or "pdf" are only plot formats
  #  unless user modifies the main script in:
  #  $AMET/R_analysis_code/MET_timeseries.R
  #  For timeseries pdf is recommended.
  setenv AMET_PTYPE pdf            

  ######################################################################
  # End of user inputs
  ######################################################################

  ## Set the input file for this R script
  setenv AMETRINPUT  $AMETBASE/scripts_analysis/$AMET_PROJECT1/input_files/run_info_MET.R
  setenv AMETRINPUT  $AMETBASE/scripts_analysis/$AMET_PROJECT1/input_files/timeseries_rh.input
  setenv AMETRSTATIC $AMETBASE/scripts_analysis/$AMET_PROJECT1/input_files/timeseries.static.input
  
  # NOTE: Do not modify; this statement is necessary if an array of sites is specified.
  setenv AMET_SITEID "$SITES[*]"
  
  # Create output directories for project
  mkdir -p $AMETBASE/output/$AMET_PROJECT1
  mkdir -p $AMET_OUT

  # R-script execution command
  R --no-save --slave < $AMETBASE/R_analysis_code/MET_timeseries_rh.R 

  if( $AMET_GROUPSITES == "TRUE") then
    set PLOT_ID="GROUP_AVG"
  else
      set PLOT_ID=$SITES[1]
  endif

  if( $#SITES == 1) then
      set PLOT_ID=$SITES[1]
  endif

  ######################################################################
  # Do not alter. Date calcs so script can check for outputs
  set ys1=`echo $AMET_YY | awk '{split($0,a,""); print a[1]}'`
  set ys2=`echo $AMET_YY | awk '{split($0,a,""); print a[2]}'`
  set ys3=`echo $AMET_YY | awk '{split($0,a,""); print a[3]}'`
  set ys4=`echo $AMET_YY | awk '{split($0,a,""); print a[4]}'`
  set ye1=`echo $AMET_YY | awk '{split($0,a,""); print a[6]}'`
  set ye2=`echo $AMET_YY | awk '{split($0,a,""); print a[7]}'`
  set ye3=`echo $AMET_YY | awk '{split($0,a,""); print a[8]}'`
  set ye4=`echo $AMET_YY | awk '{split($0,a,""); print a[9]}'`

  set ms1=`echo $AMET_MM | awk '{split($0,a,""); print a[1]}'`
  set ms2=`echo $AMET_MM | awk '{split($0,a,""); print a[2]}'`
  set me1=`echo $AMET_MM | awk '{split($0,a,""); print a[4]}'`
  set me2=`echo $AMET_MM | awk '{split($0,a,""); print a[5]}'`

  set ds1=`echo $AMET_DD | awk '{split($0,a,""); print a[1]}'`
  set ds2=`echo $AMET_DD | awk '{split($0,a,""); print a[2]}'`
  set de1=`echo $AMET_DD | awk '{split($0,a,""); print a[4]}'`
  set de2=`echo $AMET_DD | awk '{split($0,a,""); print a[5]}'`
  set datestart = $ys1$ys2$ys3$ys4$ms1$ms2$ds1$ds2
  set dateend   = $ye1$ye2$ye3$ye4$me1$me2$de1$de2
  set outfile   = $AMET_OUT/$AMET_PROJECT1.$PLOT_ID.$datestart\-$dateend\.time_series_RH
  ######################################################################

  if(-e $outfile.$AMET_PTYPE) then
    echo
    echo "Examples of plots and data files that were produced:"
    echo "-----------------------------------------------------------------------------------------"
    echo "Timeseries plot is  ---------->" $outfile.$AMET_PTYPE
    echo
    echo "Text output if textout<-T:-->" $outfile.txt
    echo
    echo "R output if savefile <-T:-->" $outfile.Rdata
    echo "-----------------------------------------------------------------------------------------"
  else
     echo "Please check options above, the AMET R script did not produce any output."
     echo "Typically, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  endif

exit(1)  
  
  
  
  
