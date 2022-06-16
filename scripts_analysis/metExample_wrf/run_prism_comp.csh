#!/bin/csh -f	
# -----------------------------------------------------------------------
# Precipitation evaluation using PRISM observations
# -----------------------------------------------------------------------
# Purpose:
# Evaluation of MPAS/WRF rainfal using daily or monthly PRISM grid files. 
# Produces a NetCDF file in the same format as MPAS or WRF with model
# and PRISM precip totals on the model grid.
# -----------------------------------------------------------------------
####################################################################################
#                          USER CONFIGURATION OPTIONS

 ##########################################################################
 # External executables (NCO and R) required for precip evaluation
 # NCO programs to create NetCDF file with model and prism precip.
 # See: http://nco.sourceforge.net/
 set ncks     = /usr/local/apps/nco-4.6.6/intel-17.0/bin/ncks
 set ncrename = /usr/local/apps/nco-4.6.6/intel-17.0/bin/ncrename
 set ncatted  = /usr/local/apps/nco-4.6.6/intel-17.0/bin/ncatted

 # Set Main R directories, function library and R script
 setenv R_LIBS   /usr/local/apps/R-3.4.0/intel-17.0/lib64/R/library
 setenv R_HOME   /usr/local/apps/R-3.4.0/intel-17.0/lib64/R
 setenv R_SCRIPT $AMETBASE/R_analysis_code/MET_prism_precip.R
 ##########################################################################

 # Project/Model ID name

 setenv AMET_PROJECT metExample_wrf

 # New NetCDF file that will contain model (MODEL_PRECIP_MM) and prism precip (PRISM_PRECIP_MM).
 # This file is created using NCO (NetCDF Operator executables) ncks, ncatted and ncrename.
 # Default setting in this script is for this file to be created in:
 # $AMETBASE/output/$AMET_PROJECT/prism/
 # The NetCDF file is easily viewed and plotted in almost all NetCDF capable vis software
 # For MPAS Verdi is suggested since its grid is unstructured.
 setenv OUTFILE metExample_wrf.precip.jul2016.nc

 # PRISM data information. Prefix examples from a 2013 and 2016 download are below.
 # There are near-real time provisional and later released final/stable versions of the
 # datasets. Also monthly (M3) and daily (D2) grids. Users must pick the datasets that properly
 # match the model output files and time increments in those files.
 # Data: http://prism.oregonstate.edu/recent/
 # Data   FTP: ftp://prism.oregonstate.edu/
 # Users can choose the daily or monthly data for a year or month. Choose the .asc (ASCII) files.
 # Download and extract to a PRISM archive directory. Specify that below via PRISM_DIR and correct
 # PRISM_PREFIX setting. Here is an example file: PRISM_ppt_stable_4kmM3_201610_asc.asc
 # Note that PREFIX are all characters up to the date stamp.
 # Bulk FTP for daily can be found here: ftp://prism.nacse.org/daily/ppt/
 # Bulk FTP for daily can be found here: ftp://prism.nacse.org/monthly/ppt/
 setenv PRISM_PREFIX PRISM_ppt_stable_4kmD2_
 setenv PRISM_PREFIX PRISM_ppt_provisional_4kmD2_
 setenv PRISM_PREFIX PRISM_ppt_stable_4kmM3_

 setenv PRISM_DIR   $AMETBASE/obs/MET/prism_daily
 setenv PRISM_DIR   $AMETBASE/obs/MET/prism

 # Note that this script only works for continous simulations where rainc and rainnc are the accumulated
 # precip over the month and not reset each day. Users have to match the model start and end day with time
 # time index to the daily or monthly PRISM dataset above as there is no internal verification that the
 # start and end model dates reflect the PRISM dataset period. The PRISM dataset is keyed off the model 
 # start files date stamp with formats of wrfout_d01_2016-12-01_00:00:00 (WRF) and history.2016-12-01.nc(MPAS).
 # Model settings are either wrf or mpas and used only for the output file generation
 set model    = wrf
 setenv MODEL_START     $AMETBASE/model_data/MET/$AMET_PROJECT/wrfout_subset_2016-07-01_00:00:00
 setenv MODEL_END       $AMETBASE/model_data/MET/$AMET_PROJECT/wrfout_subset_2016-07-31_00:00:00

 setenv START_TINDEX    1
 setenv END_TINDEX      24

 # Is this a daily precip evaluation? Otherwise it's assumed monthly. This is only needed
 # to choose the correct prism dataset name that is date dependent.
 # PRISM_ppt_stable_4kmM3_201604_asc.asc (monthly) vs. PRISM_ppt_provisional_4kmD2_20160609_asc.asc
 setenv DAILY  F

 #######################################################################################
 # Do not alter unless you want to change the output NetCDF file structure.
 # These NCO commands create a WRF/MPAS like output file with variables 
 # MODEL_PRECIP_MM and PRISM_PRECIP_MM that are populated by the R script
 mkdir -p $AMETBASE/output/$AMET_PROJECT
 mkdir -p $AMETBASE/output/$AMET_PROJECT/prism
 setenv OUTFILE $AMETBASE/output/$AMET_PROJECT/prism/$OUTFILE
 if($model == 'wrf') then
   $ncks -O -v Times -d Time,0,0   $MODEL_START $OUTFILE
   $ncks -A -v RAINC -d Time,0,0   $MODEL_START $OUTFILE
   $ncks -A -v RAINNC -d Time,0,0  $MODEL_START $OUTFILE

   $ncrename -v RAINC,PRISM_PRECIP_MM $OUTFILE
   $ncrename -v RAINNC,MODEL_PRECIP_MM $OUTFILE
   $ncatted  -a units,'PRISM_PRECIP_MM',m,c,'mm' $OUTFILE
   $ncatted  -a units,'MODEL_PRECIP_MM',m,c,'mm' $OUTFILE
   $ncatted  -a description,'PRISM_PRECIP_MM',m,c,'Total PRISM precipitation' $OUTFILE
   $ncatted  -a description,'MODEL_PRECIP_MM',m,c,'Total WRF precipitation' $OUTFILE
 endif

 if($model == 'mpas') then
   $ncks -O -v verticesOnCell,nEdgesOnCell,latVertex,lonVertex,indexToVertexID,indexToCellID,latCell,lonCell,zgrid \
               $MODEL_START $OUTFILE
   $ncks -A -v q2  -d Time,0,0   $MODEL_START $OUTFILE
   $ncks -A -v t2m -d Time,0,0   $MODEL_START $OUTFILE
   $ncrename -v q2,PRISM_PRECIP_MM  $OUTFILE
   $ncrename -v t2m,MODEL_PRECIP_MM $OUTFILE
   $ncatted  -a units,'PRISM_PRECIP_MM',m,c,'mm' $OUTFILE
   $ncatted  -a units,'MODEL_PRECIP_MM',m,c,'mm' $OUTFILE
   $ncatted  -a long_name,'PRISM_PRECIP_MM',m,c,'Total PRISM precipitation' $OUTFILE
   $ncatted  -a long_name,'MODEL_PRECIP_MM',m,c,'Total MPAS precipitation' $OUTFILE
 endif
 #######################################################################################

 $R_HOME/bin/R --no-save --slave  < $R_SCRIPT

 exit(0)

##########################################################################################################
