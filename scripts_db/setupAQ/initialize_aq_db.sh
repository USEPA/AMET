#!/bin/sh

###############################################################
##
## Creates a new AMET-AQ database and populates some metadata
##
###############################################################

## setup:
## Top AMET directory tree
AMETBASE=/project/amet_aq/AMET_Code/Release_Code_v13/AMET_v13; export AMETBASE

## Set AMET Database
AMET_DATABASE=Test_AMETv13; export AMET_DATABASE

## top of AQ observation data directory
AMET_OBS=$AMETBASE/obs/AQ; export AMET_OBS

## Perl input -- defines which files to include in site-metadata
AMETRINPUT=$AMETBASE/scripts_db/setupAQ/sites_meta.input; export AMETRINPUT

## Create a new amet database and ametsecure user (Y or N)
## Should only be done 1 time for the whole AMET setup
## --- AQ and MET independent
new_db='Y'


##################################################################
###### Most users will not need to modify anything below #########
##################################################################

## R script creates a new MYSQL db and user or updates it
if [ $new_db == "Y" ] ; then
    echo "Creating new AMET db and user"
    echo "Enter the MYSQL root user, root: "
    read mysql_root_login
    echo "Enter the MYSQL root user password: "
    read -s mysql_root_pass
    R --no-save --slave --args < $AMETBASE/R_db_code/setup_AMETdb_user.R $mysql_root_login $mysql_root_pass
    if [ $? -ne 0 ] ; then
	echo "Error creating/updating new AMET-AQ db"
	exit 1
    fi 
fi

## setup metadata tables
echo "Creating AQ metadata tables"
R --no-save --slave < $AMETBASE/R_db_code/AQ_setup_metadata.R
if [ $? -ne 0 ] ; then
    echo "Error creating AMET-AQ metadata tables"
    exit 1
fi


## R script populates the new db w/ site metadata
echo "Populating new AQ db with site metadata"
R --no-save --slave < $AMETBASE/R_db_code/AQ_add_sites_dbase.R
if [ $? -ne 0 ] ; then
    echo "Error populating new db with site metadata"
    exit 1
fi



