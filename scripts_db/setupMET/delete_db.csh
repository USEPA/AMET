#!/bin/csh

###############################################################
##
## Deletes AMET database and user
##
## NOTE:  This will destroy all data from MET and AQ projects
##        Be VERY CAREFUL !!!
##
###############################################################

## setup:
## Top AMET directory tree
setenv AMETBASE ~/AMET

## Set AMET Database
setenv AMET_DATABASE amet

##################################################################
###### Most users will not need to modify anything below #########


## Perl script deletes MYSQL db and user
echo "Deleting AMET db and user"
$AMETBASE/perl/delete_AMETdb_user.pl
if ( $status != 0 ) then
    echo "Error deleting AMET db"
    exit (1)
endif



