#!/bin/csh

###############################################################
##
## Creates a new AMET-MET database and populates some metadata
##
###############################################################

## setup:
## Top AMET directory tree
setenv AMETBASE ~/AMET

## Set AMET Database
setenv AMET_DATABASE amet

## Perl input -- defines which files to include in site-metadata
setenv AMETPERLINPUT $AMETBASE/scripts_db/setupMET/sites_meta.input

## Create a new amet database and ametsecure user (Y or N)
## Should only be done 1 time for the whole AMET setup
## --- AQ and MET independent
set new_db='Y'


##################################################################
###### Most users will not need to modify anything below #########


## Perl script creates a new MYSQL db and user or updates it
if ( $new_db == 'Y' ) then
    echo "Creating new AMET db and user"
    $AMETBASE/perl/setup_AMETdb_user.pl
    if ( $status != 0 ) then
	echo "Error creating/updating new AMET-MET db"
	exit (1)
    endif
endif

## setup metadata tables
echo "Creating MET metadata tables"
$AMETBASE/perl/MET_setup_metadata.pl
if ( $status != 0 ) then
    echo "Error creating AMET-MET metadata tables"
    exit (1)
endif





