#!/bin/csh -f
# --------------------------------
# AMET Batch Plots
# -----------------------------------------------------------------------
# Purpose:
#
# This script is used to run the AMET batch processing of plots, which allows
# the user to run the various AMET-AQ plots in a hands-off batch mode. The
# script will attempt to run the various AMET-AQ scripts available, with user
# able to control the scripts being run using the AMET_batch.input file. The
# AMET_batch.input file also allows the user to control the normal options
# available for each script. The batch plotting is intended to be a quick, 
# first run option to analyze an air quality simulation. After which, the user
# can modify the individual plot run scripts to fully customize any plot.
#
# Initial version:  Wyat Appel - Jul, 2017
#
# Revised version:  Wyat Appel - Sep, 2018
# -----------------------------------------------------------------------
#

### Location of the R executable ###
setenv R_EXEC_LOC /share/linux86_64/bin

### T/F; Set to T if the model/obs pairs are loaded in the AMET database (i.e. by setting LOAD_SITEX = T)
setenv AMET_DB	T

### IF AMET_DB = F, set location of site compare output files using the environment variable OUTDIR
#setenv OUTDIR	$AMETBASE/output/$AMET_PROJECT/sitex_output

### Set the location of the base AMET installation, database name and project name ###
setenv AMETBASE		/home/AMETv15
setenv AMET_DATABASE 	amet 
setenv AMET_PROJECT	aqExample
setenv MYSQL_CONFIG	$AMETBASE/configure/amet-config.R

###  Start and End Dates of plot (YYYY-MM-DD) -- must match available dates in db or site compare files
setenv AMET_SDATE "2016-07-01"
setenv AMET_EDATE "2016-07-31"

### Set the project name to be used for model-to-model comparisons ###
setenv AMET_PROJECT2 aqExample 

### IF AMET_DB = F, set location of site compare output files using the environment variable OUTDIR2
#setenv OUTDIR2	$AMETBASE/output/$AMET_PROJECT2/

### Set the run directory (where the batch scripts are located) ###
setenv AMET_RUN_DIR $AMETBASE/R_analysis_code/batch_scripts

### Set the output directory (where to write output plots and files) ###
setenv AMET_OUT $AMETBASE/output/$AMET_PROJECT/batch_plots 

### Set the input files to use (full path and file name) ###
setenv AMETRINPUT 	$AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/AMET_batch.input
#setenv AMET_NET_INPUT 	$AMETBASE/scripts_analysis/$AMET_PROJECT/input_files/Network.input

### Plot Type, options are "pdf","png","both" ###
setenv AMET_PTYPE both

##################################################################################################
### Run AMET batch scripts to create stats and plots.  Output to /project/amet_aq/Unit_Testing ###
##################################################################################################
$R_EXEC_LOC/R CMD BATCH $AMET_RUN_DIR/Run_Spatial_Plots_All_Batch.R
$R_EXEC_LOC/R CMD BATCH $AMET_RUN_DIR/Run_Stacked_Barplot_All_Batch.R
$R_EXEC_LOC/R CMD BATCH $AMET_RUN_DIR/Run_Time_Plots_All_Batch.R
$R_EXEC_LOC/R CMD BATCH $AMET_RUN_DIR/Run_Scatter_Plots_All_Batch.R
$R_EXEC_LOC/R CMD BATCH $AMET_RUN_DIR/Run_Misc_Plots_Batch.R

exit()
