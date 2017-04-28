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
## Creates and/or populates a new AMET project - AQ
##
## This script can be used to both setup create an AMET project 
## and populate the AMET database. If the project has already
## been created, simply set AMET_NEW_PROJECT to "no". There
## are also separate options available to create the site
## compare scripts, run the site compare scripts, and/or load
## the site compare data into the database.
##
## The populate_project.input file from AMETv1.1 is not longer 
## required, as the options specified in that file have been
## incorporated into this file.
##
## Last modified by K. Wyat Appel: March 14, 2017
##
##########################################################

## setup:
## Top AMET directory tree
#setenv AMETBASE ~/AMET 
setenv AMETBASE /project/amet_aq/AMET_Code/Release_Code_v13/AMET_v13 

## Set user name (default is to use system user name)
setenv AMET_LOGIN  `whoami`

## New project name (should be unique and 1 word)
setenv AMET_PROJECT "aqExample"
setenv AMET_NEW_PROJECT "no"

### Set the database to be used.  For CMAQ v5.0 development, this should be set to 'CMAQ_v50_Dev'. ###
#setenv AMET_DATABASE AMET
setenv AMET_DATABASE Test_AMETv13

## top of AQ observation data directory
setenv AMET_OBS $AMETBASE/obs/AQ

## Output directory -- extracted data will be written here
setenv AMET_OUT $AMETBASE/output/$AMET_PROJECT

### Options to write, run and load sitex files (T/F) ###
setenv WRITE_SITEX      T
setenv RUN_SITEX        T
setenv LOAD_SITEX       T

### AMET species list (use default; you can make a copy and use your own if necessary) ###
setenv AMET_SPECIES_FILE $AMETBASE/R_db_code/AQ_species_list.R

### Include AERO6 soil species (T/F) ###
setenv INC_AERO6_SPECIES T # T to include soil-related species 

### Include PM2.5 sharp cutoff species (T/F) ###
setenv INC_CUTOFF F

### Set timeshift flag in site compare.  This should be set to 1 for files that have been timeshifted (sometimes done to ACONC files).  Not applicable to deposition files. ###
setenv TIME_SHIFT 0

### Set start and end date for analysis (Year and Julian day) ###
### Jan 001-032; Feb 032-060; Mar 060-091; Apr 091-121; May 121-152; Jun 152-182; Jul 182-213; Aug 213-244; Sep 244-274; Oct 274-305; Nov 305-335; Dec 355-365
setenv START_DATE       2011182
setenv END_DATE         2011213

### Set path to concentration files (up to 10 files, sequentially numbered) ###
setenv CONC_FILE_1 $AMETBASE/model_data/AQ/aqExample/CCTM_CMAQv52_Sep15_cb6_Hemi_New_LTGNO_combine.aconc.07
#setenv CONC_FILE_2 $AMETBASE/model_data/AQ/

### Set path to deposition files (up to 10 files, sequentially numbered) ###
setenv DEP_FILE_1 $AMETBASE/model_data/AQ/aqExample/CCTM_CMAQv52_Sep15_cb6_Hemi_New_LTGNO_combine.dep.07
#setenv DEP_FILE_2 $AMETBASE/model_data/AQ/

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

### Europe networks ###
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

## INPUT to perl script -- 
## User defined variables for creating specific project
 setenv AMETRINPUT $AMETBASE/scripts_db/$AMET_PROJECT/setup_project.input

## Check for output directory, create if not present
if (! -d $AMET_OUT) then
    mkdir $AMET_OUT
endif

## If new project, create MySQL project tables
if ($AMET_NEW_PROJECT == 'yes') then
    ## R script sets up a new project: 
    ## creates a new empty project table in the AMET db
    R --no-save --slave < $AMETBASE/R_db_code/AQ_create_project.R
    if ( $status != 0 ) then
	echo "Error creating new project OR user decided not to overwrite old project"
    exit (1)
    endif
endif

## INPUT to R script -- 
## User defined variables for populating project
# setenv AMETRINPUT $AMETBASE/scripts_db/$AMET_PROJECT/populate_project.input

## R script populates the new project table in the db:
## matches observations and model data
if (($WRITE_SITEX == "T") || ($RUN_SITEX == "T") || ($LOAD_SITEX == "T")) then
   echo "Populating new AQ project.  This may take some time...."
   R --no-save --slave < $AMETBASE/R_db_code/AQ_matching.R
   if ( $status != 0 ) then
       echo "Error populating new project with data"
       exit (1)
   endif
endif
