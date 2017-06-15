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
setenv AMETBASE /project/amet_aq/AMET_Code/Release_Code_v13/AMET_v13

## Set AMET Database
setenv AMET_DATABASE Test_AMETv13


##################################################################
###### Most users will not need to modify anything below #########

## R script deletes MYSQL db and user
echo "Running script for deleting AMET db and user"
echo -n "Enter the MYSQL root user, root: "
set mysql_root_login = $<
echo -n "Enter the MYSQL root user password: "
stty -echo
set mysql_root_pass = $<
stty echo
echo "\nWARNING, WARNING!!"
echo "Deleting the database will destroy the data in all MET and AQ projects."
echo "Are you sure you want to delete the AMET database?" 
set delete_db = $<
echo "WARNING, WARNING!!"
echo "Deleting the user will mean that you can't access data through this user"
echo "Are you sure you want to delete the AMET user?"
set delete_user = $<
R --no-save --slave --args < $AMETBASE/R_db_code/delete_AMETdb_user.R $mysql_root_login $mysql_root_pass $delete_db $delete_user
if ( $status != 0 ) then
   echo "Error creating/updating new AMET-AQ db"
   exit (1)
endif
