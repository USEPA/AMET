#!/bin/csh -f	

### Location of the R executable ###
setenv R_EXEC_LOC /share/linux86_64/bin

### Set the location of the base AMET installation, database name and project name ###
setenv AMETBASE 	/project/amet_aq/AMET_Code/Release_Code_v13/AMET_v13
setenv AMET_DATABASE 	amet 
setenv AMET_PROJECT	aqExample
setenv MYSQL_CONFIG	$AMETBASE/configure/amet-config.R

### Set the project name to be used for model-to-model comparisons ###
setenv AMET_PROJECT2 aqExample 

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
