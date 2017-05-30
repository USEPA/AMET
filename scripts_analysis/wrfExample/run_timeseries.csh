#!/bin/csh -f
# --------------------------------
# Timeseries plots
# -----------------------------------------------------------------------
# Purpose:
# This is an example c-shell script to run the R-script that generates
# timeseries plot of model and observed temperature, wind and moisture 
# -----------------------------------------------------------------------
  
  #-----------------------------------------------------------------------
  # These are the main controlling variables for the R timeseries script
  
  #  Top of AMET directory
  setenv AMETBASE ~/AMET

  #  AMET database
  setenv AMET_DATABASE  amet
    
  #  AMET project id or simulation id. Note: Project2 allows comparsions of two model
  #  runs with obs including statistics. If left unset, it's ignored.
  setenv AMET_PROJECT	wrfExample
  setenv AMET_PROJECT2  
  
  #  Directory where figures and text output will be directed
  setenv AMET_OUT   $AMETBASE/output/$AMET_PROJECT/timeseries
  
  #  Observation site for timeseries. If mulitple sites are specificed like example two below
  #  Sites and corresponding model values are either averaged into a timeseries if 
  # AMET_GROUPSITES=TRUE or a timeseries plot for each site is generated in a loop over sites
#  set SITES=(AVAN4)
  set SITES=( KACY KBWI KCHO) 

  # In the case that multiple site id's are defined above, should
  # these be grouped or averaged or should a separate timeseries be
  # generated for each site (TRUE - averaged; FALSE - separate)?
  setenv AMET_GROUPSITES FALSE 

  #  Date range of timeseries where year (YY), month (MM), day (DD) are 
  #  the start and end values with one space between
  #  Below is the example for Jul 15-31, 2006
  setenv AMET_YY "2002 2002"             
  setenv AMET_MM "07 07"             
  setenv AMET_DD "05 06"             

  #  Additional criteria to add to site query
  setenv AMET_EXTRA1              
  setenv AMET_EXTRA2              

  # Log File for R script
  setenv AMET_LOG $AMETBASE/scripts_analysis/$AMET_PROJECT/timeseries.log

  #  Plot Type, options are "pdf" or "png"
  setenv AMET_PTYPE png             
#---------------------------------------------------------------------------------------
  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/timeseries.input  
  
  # NOTE: Do not modify; this statement is necessary if an array of sites is specified.
  setenv AMET_SITEID "$SITES[*]"
  
  # Check for plot and text output directory, create if not present
  if (! -d $AMET_OUT) then
     mkdir -p $AMETBASE/output/$AMET_PROJECT
     mkdir $AMET_OUT
  endif


  # R-script execution command
  R CMD BATCH --no-save --slave $AMETBASE/R/MET_timeseries.R $AMET_LOG
#  R BATCH --no-save < $AMETBASE/R/MET_timeseries.R 

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
  
  
  
  
