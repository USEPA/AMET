#!/bin/csh -f	

#PBS -N run_extract_all.csh 
#PBS -l walltime=10:00:00
#PBS -l nodes=inode35.amad.gov:ppn=1
##PBS -W group_list=mod3eval
#PBS -q batch
#PBS -V
#PBS -m n
#PBS -j oe
#PBS -o /project/inf1w/appel/AMET_Code/AMAD_Code/Test/AMET_batch_scripts.log

### Location of the R executable on HPCC (rain,snow) ###
setenv R_EXEC_LOC /share/linux86_64/bin

### Location of the R executable on the infinity (x64) machine ###
#setenv R_EXEC_LOC /share/linux86_64/R-2.11.1/bin

### Set the location of the base AMET installation.  For applications on HPCC, this should be set to /project/amet_aq/AMET_Code/AMAD_Code for OAQPS. ###
setenv AMETBASE /project/amet_aq/AMET_Code/Release_Code_v13/AMET_v13

### Set the database to be used.  For CMAQ v5.0 development, this should be set to 'CMAQ_v50_Dev'. ###
setenv AMET_DATABASE Test_AMETv13 

### Set the project name to be used.  This should be the same name as used with the run_create_AMET_project script ###
setenv AMET_PROJECT aqExample

### Set the project name to be used for model-to-model comparisons ###
setenv AMET_PROJECT2 aqExample 

### Set the run directory (where the batch scripts are located) ###
setenv AMET_RUN_DIR $AMETBASE/R_analysis_code/batch_scripts

### Set the output directory (where to write output plots and files) ###
setenv AMET_OUT $AMETBASE/output/$AMET_PROJECT/batch_plots 

### Set the run_info file to use (full path and file name) ###
setenv AMETRINPUT $AMETBASE/scripts_analysis/aqExample/input_files/AMET_batch.R
setenv AMET_NET_INPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/Network.input

### Plot Type, options are "pdf","png","both" ###
setenv AMET_PTYPE both

##################################################################################################
### Run AMET batch scripts to create stats and plots.  Output to /project/amet_aq/Unit_Testing ###
##################################################################################################
#$R_EXEC_LOC/R CMD BATCH $AMET_RUN_DIR/Run_Spatial_Plots_All_Batch.R
#$R_EXEC_LOC/R CMD BATCH $AMET_RUN_DIR/Run_Stacked_Barplot_All_Batch.R
#$R_EXEC_LOC/R CMD BATCH $AMET_RUN_DIR/Run_Time_Plots_All_Batch.R
$R_EXEC_LOC/R CMD BATCH $AMET_RUN_DIR/Run_Scatter_Plots_All_Batch.R
#$R_EXEC_LOC/R CMD BATCH $AMET_RUN_DIR/Run_Misc_Plots_Batch.R

exit()
