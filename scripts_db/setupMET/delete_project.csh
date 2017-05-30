#!/bin/csh

###############################################################
##
## Deletes AMET-MET project
##
## NOTE:  This will destroy all data in an AQ project
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


## Perl script deletes MYSQL MET project
echo "Deleting MET project"
$AMETBASE/perl/MET_delete_project.pl
if ( $status != 0 ) then
    echo "Error deleting project"
    exit (1)
endif



