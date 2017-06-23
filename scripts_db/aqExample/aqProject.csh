#!/bin/csh

#PBS -N AMET_Preprocess.csh
#PBS -l walltime=10:00:00
#PBS -l nodes=1:ppn=1
#PBS -q batch
#PBS -V
#PBS -m n
#PBS -j oe
#PBS -o ./AMET_preprocess.log

##########################################################
##
## Creates and/or populates a new AMET-AQ project. Will create
## the database and the required database tables if they do not 
## exist.
##
## This script can be used to both setup an AMET project 
## and populate the AMET project table. If the database and/or project
## do not exist, they will be created. If the project has already 
## been created, it will not be altered unless specified by the user.  
## There are also separate flags indicated whether or not to create the 
## site compare scripts, run the site compare scripts, and/or load
## the site compare data into the database.
##
## Two input files required by this script are:
## - sites_meta.input (required when first setting up the database)
## - AQ_species_list.input (likely does not need to be altered)
##
## Last modified by K. Wyat Appel: June, 2017
##
##########################################################

## setup:
### AMET base directory and database 
setenv AMETBASE 	/project/amet_aq/AMET_Code/Release_Code_v13/AMET_v13 
setenv AMET_DATABASE 	amet
setenv MYSQL_CONFIG     $AMETBASE/configure/amet-config.R

## AMET login info. Uncomment to specify AMET login/pass via script instead of via prompt/qsub command line. ###
### Entering 'config_file' will obtain the login/pass from the amet-config.R file instead. ###
set    mysql_login="config_file"
set    mysql_password="config_file"

### Project name and details. Project will be created if it does not already exist ###
setenv AMET_PROJECT 	"aqExample"
setenv MODEL_TYPE 	"CMAQ"
setenv RUN_DESCRIPTION 	"AQ example project; July 2011"
setenv USER_NAME 	`whoami`
setenv EMAIL_ADDR 	"appel.wyat@epa.gov"

### AQ observation data directory and input files ###
setenv AMET_OBS 	$AMETBASE/obs/AQ
setenv SITES_META_LIST	$AMETBASE/scripts_db/input_files/sites_meta.input
setenv AQ_SPECIES_LIST 	$AMETBASE/scripts_db/input_files/AQ_species_list.input

### Output directory -- post-processed data will be written here ###
setenv AMET_OUT 	$AMETBASE/output/$AMET_PROJECT

### Options to write, run and load sitex files (T/F) ###
setenv WRITE_SITEX      T
setenv RUN_SITEX        T
setenv LOAD_SITEX       T

### Flags for project creation, updating and removal ###
setenv UPDATE_PROJECT 		F
setenv REMAKE_PROJECT 		F
setenv DELETE_PROJECT 		F

### Site compare post-processing options ###
setenv INC_AERO6_SPECIES	T 
setenv INC_CUTOFF 		F
setenv TIME_SHIFT 		0

### Set start and end date for analysis (Year and Julian day) ###
### Jan 001-032; Feb 032-060; Mar 060-091; Apr 091-121; May 121-152; Jun 152-182; Jul 182-213; Aug 213-244; Sep 244-274; Oct 274-305; Nov 305-335; Dec 355-365 ###
setenv START_DATE       2011182
setenv END_DATE         2011213

### Set path to concentration files (up to 10 files, sequentially numbered) ###
setenv CONC_FILE_1 	$AMETBASE/model_data/AQ/aqExample/CCTM_CMAQv52_Sep15_cb6_Hemi_New_LTGNO_combine.aconc.07
setenv DEP_FILE_1	$AMETBASE/model_data/AQ/aqExample/CCTM_CMAQv52_Sep15_cb6_Hemi_New_LTGNO_combine.dep.07

### Flag (Y/T or N/F) set by user to include data in the analysis ###
### Standard North America networks (should all be set to T for complete analysis) ###
setenv CASTNET          F
setenv CASTNET_HOURLY   F
setenv CASTNET_DAILY_O3 F
setenv IMPROVE          F 
setenv NADP             F
setenv CSN              F
setenv AQS_HOURLY       F
setenv AQS_DAILY_O3     F
setenv AQS_DAILY        T
setenv SEARCH_HOURLY    F
setenv SEARCH_DAILY     F

### Non-standard North America networks (should be set to F unless specifically required) ###
setenv NAPS_HOURLY      F
setenv CASTNET_DRYDEP   F
setenv AIRMON           F
setenv AMON		F
setenv MDN              F
setenv FLUXNET		F

### Europe networks (should be set to F unless specifically required) ###
setenv AIRBASE_HOURLY	F
setenv AIRBASE_DAILY	F
setenv AURN_HOURLY	F
setenv AURN_DAILY	F
setenv EMEP_HOURLY	F
setenv EMEP_DAILY	F
setenv AGANET		F
setenv ADMN		F
setenv NAMN		F

### Flags to set ozone and precipitation units (do not change if using standard SPEC_DEF file) ###
setenv O3_OBS_FACTOR    1
setenv O3_MOD_FACTOR    1
setenv O3_UNITS         ppb

### Flags to set precipitation units (do not change if using standard SPEC_DEF file) ###
setenv PRECIP_UNITS     cm

##################################################################
###### Most users will not need to modify anything below #########
##################################################################

if (! "$?mysql_login" ) then
   echo "Enter the AMET user name: "
   set amet_login = "$<"
endif
if (! "$?mysql_password" ) then
   echo "Enter the AMET user password: "
   stty -echo
   set amet_pass = "$<"
   stty echo
endif

if (! "$?amet_login" ) then
   if (! $?mysql_login ) then
       echo "No login provided via qsub argument"
   else
      if ("$mysql_login" == "")  then
         echo "qsub login is empty"
      else
         set amet_login = "$mysql_login"
         echo "Qsub -v login was accepted and will be passed to the script."
      endif
   endif
endif

if (! "$?amet_pass" ) then
   if (! $?mysql_password ) then
      echo "No password provided via qsub argument"
   else
      if ("$mysql_password" == "")  then
         echo "qsub password is empty"
      else
         set amet_pass = "$mysql_password"
         echo "Qsub -v password was accepted and will be passed to the script."
     endif
   endif
endif

if (! $?amet_login ) then
    echo "No login provided. Either specify via script, terminal or qsub -v login=amet_login"
    exit(0)
endif

if (! $?amet_pass ) then
    echo "No password provided. Either specify via script, terminal or qsub -v password=amet_pass"
    exit(0)
endif

## Check for output directory, create if not present
if (! -d $AMET_OUT) then
    mkdir $AMET_OUT
endif

## setup metadata tables
echo "\n**Setting up AMET database if needed**"
R --no-save --slave --args < $AMETBASE/R_db_code/AQ_setup_dbase.R "$amet_login" "$amet_pass"
if ( $status != 0 ) then
    echo "Error setting up AMET database"
    exit (1)
endif

## If new project, create MySQL project tables
## R script sets up a new project: 
## creates a new empty project table in the AMET db
echo "\n**Checking to see if AQ project table exists, if not create it**"
R --no-save --slave --args < $AMETBASE/R_db_code/AQ_create_project.R "$amet_login" "$amet_pass"
if ( $status != 0 ) then
   echo "Error creating new project OR user decided not to overwrite old project"
   exit (1)
endif
echo "Done with project table creation."

## R script populates the new project table in the db:
## matches observations and model data
if (($WRITE_SITEX == "T") || ($RUN_SITEX == "T") || ($LOAD_SITEX == "T")) then
   echo "Populating new AQ project.  This may take some time...."
   R --no-save --slave --args < $AMETBASE/R_db_code/AQ_matching.R "$amet_login" "$amet_pass"
   if ( $status != 0 ) then
       echo "Error populating new project with data"
       exit (1)
   endif
endif
