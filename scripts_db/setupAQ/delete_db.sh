#!/bin/sh

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
AMETBASE=/project/amet_aq/AMET_Code/Release_Code_v13/AMET_v13; export AMETBASE

## Set AMET Database
AMET_DATABASE=Test_AMETv13; export AMET_DATABASE


##################################################################
###### Most users will not need to modify anything below #########


## R script deletes MYSQL db and user
echo "Running script for deleting AMET db and user"
echo "Enter the MYSQL root user, root: "
read mysql_root_login
echo "Enter the MYSQL root user password: "
read -s mysql_root_pass
echo "WARNING, WARNING!!"
echo "Deleting the database will destroy the data in all MET and AQ projects."
echo "Are you sure you want to delete the AMET database?" 
read delete_db
echo "WARNING, WARNING!!"
echo "Deleting the user will mean that you can't access data through this user"
echo "Are you sure you want to delete the AMET user?"
read delete_user
R --no-save --slave --args < $AMETBASE/R_db_code/delete_AMETdb_user.R $mysql_root_login $mysql_root_pass $delete_db $delete_user
#Rscript $AMETBASE/R_db_code/delete_AMETdb_user.R $mysql_root_login $mysql_root_pass $delete_db $delete_user
if [ $? -ne 0 ] ; then
   echo "Error creating/updating new AMET-AQ db"
   exit 1
fi 
