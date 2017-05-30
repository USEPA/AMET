#!/bin/csh

##########################################################
##
## Downloads madis observations for a given time period
##
##########################################################

## setup:
## Top AMET directory tree
setenv AMETBASE ~/AMET

## Set AMET database
setenv AMET_DATABASE amet

## New project name (should be unique and 1 word) and description
setenv AMET_PROJECT "mm5Example"
setenv AMET_PROJ_DESC "MM5 example project"

## top of MET (MADIS) observation data directory
setenv AMET_OBS $AMETBASE/obs/MET

# Starting Date should be in form of YYYY-MM-DD-HH
setenv AMET_DATE_START 2002-07-05-00

# Number of days to download
setenv AMET_NUM_DAYS 1

##################################################################
###### Most users will not need to modify anything below #########

## INPUT to perl script -- 
## User defined variables for creating specific project
setenv AMETPERLINPUT $AMETBASE/scripts_db/$AMET_PROJECT/setup_project.input

## INPUT to perl script -- 
## User defined variables for populating project
setenv AMETPERLINPUT $AMETBASE/scripts_db/$AMET_PROJECT/populate_project.input

## Perl script populates the new project table in the db:
## extracts all data from the model and the observations
echo "Downloading observational data from MADIS.  This will take some time...."
$AMETBASE/perl/MET_ftp.pl
if ( $status != 0 ) then
    echo "Error downloading new observational data"
    exit (1)
else
	echo "-----------------------------------------------------------------------------------------"
	echo "Data sucessfully downloaded for "${AMET_NUM_DAYS}" day(s) starting at "${AMET_DATE_START}
	echo "-----------------------------------------------------------------------------------------"
	exit (0)
endif


