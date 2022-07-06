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
 # External executables, netCDF Operators (NCO) are required + R packages
 # NCO programs are used to create NetCDF file with model and prism precip.
 # See: http://nco.sourceforge.net/
 # R modules needed for Leaflet HTML: prism, raster, leaflet and htmlwidget
 set ncks     = ncks
 set ncrename = ncrename
 set ncatted  = ncatted
 ##########################################################################

 # AMETBASE directory and AMET Project ID
 # setenv AMETBASE     /home/user/AMET

  setenv AMET_PROJECT metExample_wrf

  # Model output directory path
  setenv METOUT_DIR   $AMETBASE/model_data/MET/$AMET_PROJECT
  
  # Prefix of model output file names with trailing _ or .
  # common examples below.
  setenv METOUT_PRE   wrfout_d01_
  setenv METOUT_PRE   wrfout_subset_

  # Period begin and end day. 
  # Daily:       Daily analysis done for each day of the period
  # Monthly:     Start day needs to be first day of the month. Loop ends the month of end date.
  # Annual:      Start day needs to be first day of the year. Loop ends the year of the end date.
  # Single Anal: For single daily, monthly or annual analysis set begin = end day and anal period.
  set begday    =     20160701
  set endday    =     20160701

 # Note that this script only works for continous simulations where rainc and rainnc are the accumulated
 # precip over the period not reset each day. Users have to match the model start and end day with time
 # time index to the daily or monthly PRISM dataset above as there is no internal verification that the
 # start and end model dates reflect the PRISM dataset period. The PRISM dataset is keyed off the model 
 # start files date stamp with formats like 2016-12-01_00:00:00.
 # Model settings are either wrf or mpas and used only for the output file generation
 set model    = wrf

 # PRISM ASCII file information. Prefix examples are below for old ASCII format PRISM data.
 # Data: http://prism.oregonstate.edu/recent/
 # Users can choose the daily or monthly data for a year or month. Choose the .asc (ASCII) files.
 # Download and extract to a PRISM archive directory. Specify that below via PRISM_DIR and correct
 # PRISM_PREFIX setting. Here is an example file: PRISM_ppt_stable_4kmM3_201610_asc.asc
 # Note that PREFIX are all characters up to the date stamp.
 setenv PRISM_PREFIX PRISM_ppt_stable_4kmM3_
 setenv PRISM_DIR   $AMETBASE/obs/MET/prism

 # New major update in AMET1.5 that leverages the prism package in R that automatically downloads
 # raster data (.bil files) from PRISM servers. This is the suggested method now necause ASCII 
 # data has been discontinued. ASCII method is still allowed if users have the old data. 
 # BIL data usage is simpler and allows the new annual option. ASCII method only allows monthly.
 setenv PRISM_BIL   T

 # Is this a daily precip evaluation?
 # Daily only works with BIL option now. If daily is TRUE, BIL will be automatically used.
 setenv DAILY F

 # Is this an annual precip evaluation?
 # Montly assumed if daily=F and annual=F.
 setenv ANNUAL F

 # Leaflet lat-lon grid spacing in kilometers (km). 
 # -99 will result in lat-lon grid spacing of the model grid
 setenv LEAF_DXDYKM -99

 # Leaflet plot levels, and color scales
 # LEAF_DXDYKM -99 will use model grid spacing. Positive value (km) will override model DX specification.
 # NOTE: LEAF_DXDYKM >> Model DX produces unstable interpolation results.
 # NOTE: LEAF_DXDYKM << Model DX is more time consuming
 # Plots include Model, PRISM, Diff and % Diff. 
 # Two color scales: Total precip (COLOR) and Differences (DCOLOR)
 # Two level specifications: Total precip (LEVELS) & Difference (DLEVELS)
 # Good color scale codes: https://colorbrewer2.org/#type=sequential&scheme=BuGn&n=3
 # These examples are just a guide.
 set   COLOR=('#ffffe5' '#f7fcb9' '#d9f0a3' '#addd8e' '#78c679' '#41ab5d' '#238443' '#006837' '#004529' '#e7e1ef' '#c994c7' '#dd1c77')
 set   COLOR=('#ffffe5' '#f7fcb9' '#d9f0a3' '#addd8e' '#78c679' '#41ab5d' '#238443' '#006837' '#004529')
 set   COLOR=('#ffffe5' '#f7fcb9' '#d9f0a3' '#addd8e' '#78c679' '#41ab5d' '#238443' '#006837' '#004529' '#2171b5' '#6baed6' '#bdd7e7' '#eff3ff') 
 set  DCOLOR=('#543005' '#8c510a' '#bf812d' '#dfc27d' '#f6e8c3' '#f5f5f5' '#c7eae5' '#80cdc1' '#35978f' '#01665e' '#003c30')

 # Good settings for Daily precipitation
 set  LEVELS=(0 1 5 10 15 20 25 50 75 100 150 300)
 set DLEVELS=(-100 -75 -50 -25 0 25 50 75 100)

 # Good settings for Monthly precipitation
 set  LEVELS=(0 25 50 75 100 125 150 175 200 250)
 set DLEVELS=(-250 -100 -50 -25 -15 -5 0 5 15 25 50 100 250)


 ## MAIN LOOP for looping over days or months of a year. No real need to loop over years although users
 ## can alter if needed for long-term simulations.
set year  = `echo begday |cut -b1-4`
set date = $begday
#-- Main LOOP Over Days defined above.
while ( $date <= $endday )

  setenv YYYYS `echo $date |cut -b1-4`
  setenv YYS   `echo $date |cut -b3-4`
  setenv MMS   `echo $date |cut -b5-6`
  setenv DDS   `echo $date |cut -b7-8`

 if($YYYYS == "2016" || $YYYYS == "2020" || $YYYYS == "2024" || $YYYYS == "2028" || $YYYYS == "2032") then
   set NUM_DAYS_MON=(31 29 31 30 31 30 31 31 30 31 30 31)
   set dty=366
 else
   set NUM_DAYS_MON=(31 28 31 30 31 30 31 31 30 31 30 31)
   set dty=365
 endif

 if($ANNUAL == "T") then
    setenv MODEL_START    ${METOUT_DIR}/${METOUT_PRE}${YYYYS}-01-01_00:00:00
    if($model == "mpas") then
      setenv MODEL_START    ${METOUT_DIR}/${METOUT_PRE}${YYYYS}-01-01.nc
    endif
    setenv START_TINDEX    1
    setenv END_TINDEX      1 
    setenv PRISM_BIL   T
    setenv OUTFILE ${AMET_PROJECT}.prism-${model}.annual.${YYYYS}.nc
    set date = `date -d "$date $dty days" '+%Y%m%d' `
 endif
 if($DAILY == "T") then
    set dt=1
    setenv MODEL_START    ${METOUT_DIR}/${METOUT_PRE}${YYYYS}-${MMS}-${DDS}_00:00:00
    if($model == "mpas") then
      setenv MODEL_START    ${METOUT_DIR}/${METOUT_PRE}${YYYYS}-${MMS}-${DDS}.nc
    endif
    setenv START_TINDEX    1
    setenv END_TINDEX      1 
    setenv PRISM_BIL   T
    setenv OUTFILE ${AMET_PROJECT}.prism-${model}.daily.${YYYYS}${MMS}${DDS}.nc
    set date = `date -d "$date $dt days" '+%Y%m%d' `
 endif
 if($DAILY == "F" & $ANNUAL == "F") then
    set dt=$NUM_DAYS_MON[$MMS]
    setenv MODEL_START    ${METOUT_DIR}/${METOUT_PRE}${YYYYS}-${MMS}-01_00:00:00
    if($model == "mpas") then
      setenv MODEL_START    ${METOUT_DIR}/${METOUT_PRE}${YYYYS}-${MMS}-01.nc
    endif
    setenv START_TINDEX    1
    setenv END_TINDEX      1 
    setenv OUTFILE ${AMET_PROJECT}.prism-${model}.monthly.${YYYYS}${MMS}.nc
    set date = `date -d "$date $dt days" '+%Y%m%d' `
 endif

  setenv YYYYE `echo $date |cut -b1-4`
  setenv YYE   `echo $date |cut -b3-4`
  setenv MME   `echo $date |cut -b5-6`
  setenv DDE   `echo $date |cut -b7-8`

  setenv MODEL_END      ${METOUT_DIR}/${METOUT_PRE}${YYYYE}-${MME}-${DDE}_00:00:00 
  if($model == "mpas") then
    setenv MODEL_END      ${METOUT_DIR}/${METOUT_PRE}${YYYYE}-${MME}-${DDE}.nc
  endif

 # New NetCDF file that will contain model (MODEL_PRECIP_MM) and prism precip (PRISM_PRECIP_MM).
 # This file is created using NCO (NetCDF Operator executables) ncks, ncatted and ncrename.
 # Default setting in this script is for this file to be created in:
 # $AMETBASE/output/$AMET_PROJECT/prism/
 # The NetCDF file is easily viewed and plotted in almost all NetCDF capable vis software
 # For MPAS Verdi is suggested since its grid is unstructured.

 #######################################################################################
 # Do not alter unless you want to change the output NetCDF file structure.
 # These NCO commands create a WRF/MPAS like output file with variables 
 # MODEL_PRECIP_MM and PRISM_PRECIP_MM that are populated by the R script
 mkdir -p $AMETBASE/output/$AMET_PROJECT
 mkdir -p $AMETBASE/output/$AMET_PROJECT/prism
 setenv OUTFILE $AMETBASE/output/$AMET_PROJECT/prism/$OUTFILE
 setenv LEAF_COLOR    "$COLOR[*]"
 setenv LEAF_DCOLOR   "$DCOLOR[*]"
 setenv LEAF_LEVELS   "$LEVELS[*]"
 setenv LEAF_DLEVELS  "$DLEVELS[*]"

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

 R --no-save --slave  < $AMETBASE/R_analysis_code/MET_prism_precip.R

 ###########################################################

end

##########################################################################################################
