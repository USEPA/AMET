#!/bin/csh

###############################################################
##
## Creates a new AMET user 
##
###############################################################

## setup:
## Top AMET directory tree
#setenv AMETBASE /proj/ie/proj/CMAS/AMET/AMET_v14b

## AMET login info. Uncomment to specify AMET login/pass via script instead of via prompt/qsub command line. ###
### Entering 'config_file' will obtain the login/pass from the amet-config.R file instead. ###
set    mysql_login="config_file"
set    mysql_password="config_file"

##################################################################
###### Most users will not need to modify anything below #########
##################################################################

## R script creates a new MYSQL db and user or updates it
echo "Creating new AMET user"
echo -n "Enter the MYSQL root user, root: "
set mysql_root_login = "$<"
echo -n "Enter the MYSQL root user password (no terminal echo): "
stty -echo
set mysql_root_pass = "$<"
stty echo
echo -n "\nEnter the AMET username to create: "
set amet_login = "$<"
echo -n "Enter the AMET user password (no terminal echo): "
stty -echo
set amet_pass = "$<"
echo -n "\nRe-enter the AMET user password (no terminal echo): "
stty -echo
set amet_pass2 = "$<"
stty echo
if ($amet_pass == $amet_pass2) then
   R --no-save --slave --args < $AMETBASE/R_db_code/setup_AMETdb_user.R "$mysql_root_login" "$mysql_root_pass" "$amet_login" "$amet_pass"
else
  echo "Error. Passwords do not match."
endif
if ( $status != 0 ) then
   echo "Error creating/updating new AMET-AQ db"
   exit (1)
endif 
