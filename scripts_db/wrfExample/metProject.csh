#!/bin/csh

##########################################################
##
## Creates a new AMET project - MET
##
##########################################################

## setup:
## Top AMET directory tree
setenv AMETBASE ~/AMET

## AMET Database
setenv AMET_DATABASE amet

## New project name (should be unique and 1 word) and description
setenv AMET_PROJECT "wrfExample"
setenv AMET_PROJ_DESC "WRF example project"
setenv AMET_NEW_PROJECT "yes"

## some systems may require the user to add pathnames for where the mySQL and netCDF libraries are installed to the LD_LIBRARY_PATH env variable

setenv LD_LIBRARY_PATH "/usr/local/pkgs/mysql-5.1.37/lib/mysql:/usr/local/pkgs/netcdf/netcdf-4.1.2/lib/:${LD_LIBRARY_PATH}"

## top of MET (MADIS) observation data directory
setenv AMET_OBS $AMETBASE/obs/MET

## MET model data for this project
setenv AMET_MODEL $AMETBASE/model_data/MET/$AMET_PROJECT

## Output directory -- extracted data will be written here
setenv AMET_OUT $AMETBASE/output/$AMET_PROJECT

##  MADIS Observation Variables
setenv MADIS_STATIC     $AMETBASE/bin/madis_static
setenv MADIS_DATA       $AMET_OBS

##################################################################
###### Most users will not need to modify anything below #########


## INPUT to perl script -- 
## User defined variables for creating specific project
setenv AMETPERLINPUT $AMETBASE/scripts_db/$AMET_PROJECT/setup_project.input

## Check for output directory, create if not present
if (! -d $AMET_OUT) then
    mkdir $AMET_OUT
endif

## If new project, create MySQL project tables
if ($AMET_NEW_PROJECT == 'yes') then
  ## Perl script sets up a new project: 
  ## creates a new empty project table in the AMET db
  $AMETBASE/perl/MET_create_project.pl
  if ( $status != 0 ) then
      echo "Error creating new project OR user decided not to overwrite old project"
      exit (1)
  endif
endif

## INPUT to perl script -- 
## User defined variables for populating project
setenv AMETPERLINPUT $AMETBASE/scripts_db/$AMET_PROJECT/populate_project.input

## Perl script populates the new project table in the db:
## extracts all data from the model and the observations
echo "Populating new AQ project.  This will take some time...."
$AMETBASE/perl/MET_matching.pl
if ( $status != 0 ) then
    echo "Error populating new project with data"
    exit (1)
endif



