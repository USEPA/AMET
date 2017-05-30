#!/bin/csh

###############################################################
##
## Creates a new AMET-AQ database and populates some metadata
##
###############################################################

## setup:
## Top AMET directory tree
setenv AMETBASE ~/AMET

## Set AMET Database
setenv AMET_DATABASE amet

## top of AQ observation data directory
setenv AMET_OBS $AMETBASE/obs/AQ

## Perl input -- defines which files to include in site-metadata
setenv AMETPERLINPUT $AMETBASE/scripts_db/setupAQ/sites_meta.input

## Create a new amet database and ametsecure user (Y or N)
## Should only be done 1 time for the whole AMET setup
## --- AQ and MET independent
set new_db='N'


##################################################################
###### Most users will not need to modify anything below #########


## Perl script creates a new MYSQL db and user or updates it
if ( $new_db == 'Y' ) then
    echo "Creating new AMET db and user"
    $AMETBASE/perl/setup_AMETdb_user.pl
    if ( $status != 0 ) then
	echo "Error creating/updating new AMET-AQ db"
	exit (1)
    endif
endif

## setup metadata tables
echo "Creating AQ metadata tables"
$AMETBASE/perl/AQ_setup_metadata.pl
if ( $status != 0 ) then
    echo "Error creating AMET-AQ metadata tables"
    exit (1)
endif


## Perl script populates the new db w/ site metadata
echo "Populating new AQ db with site metadata"
$AMETBASE/perl/AQ_add_sites_dbase.pl
if ( $status != 0 ) then
    echo "Error populating new db with site metadata"
    exit (1)
endif



