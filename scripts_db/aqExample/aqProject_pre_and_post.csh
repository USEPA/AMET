#!/bin/csh -f

##########################################################
##
## Creates and/or populates a new AMET-AQ project. Will create
## the database and the required database tables if they do not
## exist. As opposed to the aqExample_post_only.csh script, this
## script will take the raw daily CMAQ output files and create
## monthly files using the combine program. It can also be used
## to run the hr2day program to create IOAQP files of daily average 
## values, including MDA8 ozone. Finally, this script can also be
## used to invoke the batch scripting capability of AMET-AQ. This
## requires an additional input file. It is more compreshensive version
## of the aqExample_post_only.csh script, with all the same 
## capabilities with additional functionality.
## 
##
## This script can be used to both setup an AMET project
## and populate the AMET project table. If the database and/or project
## do not exist, they will be created. If the project has already
## been created, it will not be altered unless specified by the user.
## There are also separate flags indicated whether or not to create the
## site compare scripts, run the site compare scripts, and/or load
## the site compare data into the database.
##
## Three input files required by this script are:
## - sites_meta.input (required when first setting up the database)
## - AQ_species_list.input (likely does not need to be altered)
## - AMET_batch.input (likely will be altered by user)
##
## Last modified by K. Wyat Appel: Jun, 2019
##
##########################################################

#
## ==================================================================
#> 1. Select which analysis steps you want to execute
# ==================================================================

#> Combine and sitecmp options
 setenv RUN_COMBINE       F     #> T/F; Run combine on CCTM output?
 setenv RUN_HR2DAY        F     #> T/F; Run hr2day program (needed for analyzing TOAR network data)
 setenv WRITE_SITEX       T     #> T/F; Write scripts for running site compare for each selected network?
 setenv RUN_SITEX         T     #> T/F; Run site compare scripts for each selected network?

#> AMET options
 setenv CREATE_PROJECT    T     #> T/F; Create AMET project?
 setenv LOAD_SITEX        T     #> T/F; Load site compare output for each selected network into AMET?
 setenv UPDATE_PROJECT    F     #> T/F; Update the project info for an existing project (all data are retained)
 setenv REMAKE_PROJECT    F     #> T/F; Remake an existing AMET project. Note that all existing data will be deleted
 setenv DELETE_PROJECT    F     #> T/F; Delete an existing AMET project. This will delete all data in the existing
                                #>      AMET table and remove the table from the database
  setenv RENAME_PROJECT    F    #> T/F; Rename an existing AMET project. This will retain all existing data
                                #>      Must also specify new project name using the environment variable NEW_AMET_PROJECT_NAME
# setenv NEW_AMET_PROJECT_NAME  "Your_New_Project_Name"

#> Plotting options
 setenv AMET_DB           T     #> T/F; Set to T if the model/obs pairs are loaded in the AMET database (i.e. by setting LOAD_SITEX = T)
                                #>      When set to F, plotting scripts will read the sitecmp .csv files directly
 setenv spatial_plots     T     #> T/F; Create maps of biase and error from site compare output?
 setenv stacked_barplots  T     #> T/F; Create stacked bar plots of PM2.5 species from site compare output?
 setenv time_plots        T     #> T/F; Create time series plots from site compare output?
 setenv scatter_plots     T     #> T/F; Create scatter plots from site compare output?
 setenv misc_plots        T     #> T/F; Create bugle plots and soccer goal plots from site compare output?

#> Other options
 setenv Source_Configs	  F     #> T/F; Set to true if using environment settings from CMAQ config files in CMAQ_Home instead of .cshrc environment

# ==================================================================================
#> 2. System configuration, location of observations and code repositories
# ==================================================================================

#> Configure the system environment
  setenv compiler     intel                      #> Compiler used to compile combine, sitecmp, sitecmp_dailyo3
  setenv compilerVrsn 18.0.1                     #> Compiler version
 # source /work/MOD3DEV/cmaq_common/cmaq_env.csh  #> Set up compilation and runtime environments on EPA system
 # source /work/MOD3DEV/cmaq_common/R_env.csh     #> Set up R environment on EPA system

#> Set the location of the $CMAQ_HOME project directory used in
#> the bldit_project.csh script of the CMAQ5.3 git repository.
#> This directory contains executables for combine, sitecmp and
#> sitecmp_daily and the species definition files needed
#> for combine.  If you are not using a CMAQ5.3 reposiotry you can
#> modify the location of the executables and spec_def files later
#> in the script.
 set CMAQ_HOME = /path/CMAQv53_repo

#> Base directory where AMET code resides
 setenv AMETBASE	/home/AMETv15

#> Source CMAQ config files to setup environment
 if (${Source_Configs} == 'T') then
    cd $CMAQ_HOME
    source config_cmaq.csh $compiler
    source R_env.csh
 endif

#> Set the location of the observation data.
#> Observation data in the format needed for sitecmp are available 
#> from the CMAS Center Data clearinghouse under the heading "2000-2015 North American Air Quality Observation Data":
#> https://www.cmascenter.org/download/data.cfm
 setenv OBS_DATA_DIR	$AMETBASE/obs/AQ

#> Set the format of the site files needed for sitecmp and sitecmp_dailyo3.
#> Options: txt or csv   The .csv files include metadata about the monitoring site (e.g. county, elevation).
 setenv SITE_FILE_FORMAT csv

# ==================================================================
#> 3. Simulation information, input/output directories
# ==================================================================

#> Start and end dates of simulation to be evaluated.
 setenv START_DATE_H  "2016-07-01"              #> Start day. Should be in format "YYYY-MM-DD".
 setenv END_DATE_H    "2016-07-31"              #> End day. Should be in format "YYYY-MM-DD".

#> Set General Parameters for Configuring the Simulation
 set VRSN      = v53               #> Code Version
 set PROC      = mpi               #> serial or mpi
 set MECH      = cb6r3_ae7_aq      #> Mechanism ID
 set APPL      = SE53BENCH         #> Application Name (e.g. Gridname)
                                                      
#> Define RUNID as any combination of parameters above or others. By default,
#> this information will be collected into this one string, $RUNID, for easy
#> referencing in output binaries and log files as well as in other scripts.
 setenv RUNID  ${VRSN}_${compilerString}_${APPL}

#> Name and location of daily MET output. Required files = METCRO2D, METCRO3D
#> This script assumes MET files are dated with the following naming convention:
#> ${METCRO2D_NAME}_${YY}${MM}${DD}.nc, ${METCRO3D_NAME}_${YY}${MM}${DD}.nc
 setenv METDIR  /path/SE53BENCH/multi_day/cctm_input/met/mcip  #> Location of MET ouput.
 set METCRO2D_NAME = METCRO2D                   #> METCRO2D file name (without date and file extension).
 set METCRO3D_NAME = METCRO3D                   #> METCRO3D file name (without date and file extension).

#> Name and location of daily CCTM output. Required files = ACONC, APMDIAG, WETDEP1, DRYDEP.
#> This script assumes daily CCTM output files are dated with the following naming convention:
#> [File Name]_${YYYY}${MM}${DD}.nc where [File Name] typically = [File Type]_[Application ID].
#> for example: CCTM_ACONC_v52_intel17.0_SE52BENCH_${YYYY}${MM}${DD}.nc
 setenv CCTMOUTDIR  /path/SE53BENCH/multi_day/ref_output/cctm    #> Location of CCTM output.
 set CCTM_ACONC_NAME    = CCTM_ACONC_${RUNID}    #> ACONC file name (without date and file extension).
 set CCTM_APMDIAG_NAME  = CCTM_APMDIAG_${RUNID}  #> APMDIAG file name (without date and file extension).
 set CCTM_WETDEP1_NAME  = CCTM_WETDEP1_${RUNID}  #> WETDEP1 file name (without date and file extension).
 set CCTM_DRYDEP_NAME   = CCTM_DRYDEP_${RUNID}   #> DRYDEP file name (without date and file extension).

#> Names and locations of output files created with this script.
#> This script assumes monthly combine files are dated with the following naming convention:
#> ${COMBINE_ACONC_NAME}_${YYYY}${MM}.nc,${COMBINE_DEP_NAME}_${YYYY}${MM}.nc
 setenv POSTDIR   $AMETBASE/output/${RUNID}	 #> Location to write combine files. (Or location of existing combine files).

 set COMBINE_ACONC_NAME  = COMBINE_ACONC_${RUNID} #> Name of combine ACONC file (without date and file extension).
 set COMBINE_DEP_NAME    = COMBINE_DEP_${RUNID}   #> Name of combine DEP file (without date and file extension).
 set HR2DAY_ACONC_NAME   = HR2DAY_ACONC_${RUNID}  #> Name of hr2day file (without date and file extension).

#> If data for January of the following year exists, set paths and files names here
 # set APPL2 = v532_cb6r3_ae7_aq_WR413_MYR_STAGE_2018_12US1
 # setenv POSTDIR2 /work/MOD3EVAL/wtt/EQUATES/data/output_v532_cb6r3_ae7_aq_WR413_MYR_STAGE_2017_12US1/PostProcess
 # set COMBINE_ACONC_NAME2 = COMBINE_ACONC_${APPL2}                         #> Name of combine ACONC file (without date and file extension)
 # set COMBINE_DEP_NAME2   = COMBINE_DEP_${APPL2}                           #> Name of combine DEP file (without date and file extension).
 # set HR2DAY_ACONC_NAME2  = HR2DAY_LST_ACONC_${APPL2}                      #> Name of HR2DAY ACONC file (without date and file extension).


#> Names and locations of output files created with this script.
 setenv EVALDIR $AMETBASE/output/${RUNID}/sitex_output #> Location where sitecmp files will be saved (or location of existing sitecmp files).
 setenv PLOTDIR $AMETBASE/output/${RUNID}/plots  #> Location where evaluaiton plots will be saved.

# =====================================================================
#> 4. Combine Configuration Options
# =====================================================================

#> Set the full path of combine executable.
 setenv EXEC_combine ${CMAQ_HOME}/POST/combine/scripts/BLD_combine_${VRSN}_${compiler}${compilerVrsn}/combine_${VRSN}.exe

#> Set location of species definition files for concentration and deposition species needed to run combine.
 setenv SPEC_CONC  ${CMAQ_HOME}/POST/combine/scripts/spec_def_files/SpecDef_${MECH}.txt
 setenv SPEC_DEP   ${CMAQ_HOME}/POST/combine/scripts/spec_def_files/SpecDef_Dep_${MECH}.txt

# =====================================================================
#> 5. Hour to Day Configuration Options
# =====================================================================

#> Set the full path of hr2day executable.
 setenv EXEC_hr2day ${CMAQ_HOME}/POST/hr2day/scripts/BLD_hr2day_${VRSN}_${compiler}${compilerVrsn}/hr2day_${VRSN}.exe

#> Set to use local time for evaluation against observational data (default is GMT)
 setenv USELOCAL Y

#> Location of time zone data file, tz.csv (this is a required input file
#> when using USELOCAL Y to shift from GMT to local time)
 setenv TZFILE ${CMAQ_HOME}/POST/hr2day/inputs/tz.csv

#> Set to use daylight savings time (default is N)
 setenv USEDST N

#> Partial day calculation (computes value for last day even 
#> if there are not 24 hours for that day after shift to LST)
 setenv PARTIAL_DAY Y

#> Number of 8hr values to use when computing daily maximum 8hr ozone.
#> Allowed values are 24 (use all 8-hr averages with starting hours 
#> from 0 - 23 hr local time) and 17 (use only the 17 8-hr averages
#> with starting hours from 7 - 23 hr local time)
 setenv HOURS_8HRMAX 24
# setenv HOURS_8HRMAX 17

#> define species (format: "Name, units, From_species, Operation")
#>  operations : {SUM, AVG, MIN, MAX, @MAXT, MAXDIF, 8HRMAX, SUM06}
 setenv SPECIES_1 "O3_MDA8,ppbV,O3,8HRMAX"
 setenv SPECIES_2 "O3_DAILYAV,ppbV,O3,AVG"
 setenv SPECIES_3 "O3_MAX,ppbV,O3,MAX"
 setenv SPECIES_4 "PM25_TOT_AVG,ug/m3,PM25_TOT,AVG" 
 setenv SPECIES_5 "PM25_SO4_AVG,ug/m3,PM25_SO4,AVG"
 setenv SPECIES_6 "PM25_NO3_AVG,ug/m3,PM25_NO3,AVG"
 setenv SPECIES_7 "PM25_NH4_AVG,ug/m3,PM25_NH4,AVG"
 setenv SPECIES_8 "PM25_OC_AVG,ug/m3,PM25_OC,AVG"
 setenv SPECIES_9 "PM25_EC_AVG,ug/m3,PM25_EC,AVG"
	
# =====================================================================
#> 6. Site Compare and Site Compare Daily O3 Configuration Options
# =====================================================================

#> Set the full path of sitecmp and sitecmp_daily executables.
 setenv EXEC_sitecmp            ${CMAQ_HOME}/POST/sitecmp/scripts/BLD_sitecmp_${VRSN}_${compiler}${compilerVrsn}/sitecmp_${VRSN}.exe
 setenv EXEC_sitecmp_dailyo3    ${CMAQ_HOME}/POST/sitecmp_dailyo3/scripts/BLD_sitecmp_dailyo3_${VRSN}_${compiler}${compilerVrsn}/sitecmp_dailyo3_${VRSN}.exe

#> Projection sphere type for sitecmp and combine (use type 20 to match WRF/CMAQ).
 setenv IOAPI_ISPH      20

#> Include x/y projection values for each site in OUT_TABLE (default N)
 setenv LAMBXY         

#> Number of 8hr values to use when computing daily maximum 8hr ozone (using sitecmp_dailyo3).
#> Allowed values are 24 (use all 8-hr averages with starting hours 
#> from 0 - 23 hr local time) and 17 (use only the 17 8-hr averages
#> with starting hours from 7 - 23 hr local time)
 setenv HOURS_8HRMAX 24
# setenv HOURS_8HRMAX 17

#> Set time shift value for time shifted files. This was done in past for ACONC files, but is no longer necessary using new CMAQ runtime options.
#> Default is now 0.
 setenv TIME_SHIFT 0
		
#> Species list for matching model species names to names in observation data files. 
 setenv AQ_SPECIES_LIST	${AMETBASE}/scripts_db/input_files/AQ_species_list.input
 
#> Include specific species from the AERO6 chemical mechanism in the species list.
 setenv INC_AERO6_SPECIES T
	
#> Include PM2.5 species in which a size cut was applied based on modeled aerosol mode parameters.
#> These species begin with 'PM". For example, PM25_NA is all sodium that falls below 2.5 um diameter. 
#> These 'PM' variables are used for comparisons at IMPROVE and CSN sites.
 setenv INC_CUTOFF T		

#> Flag (Y/T or N/F) set by user to include data in the analysis. 
#> Standard networks (should all be set to T for complete analysis). 
 setenv AERONET           T
 setenv AMON              T
 setenv AQS_HOURLY        T
 setenv AQS_DAILY_O3      T 
 setenv AQS_DAILY         T
 setenv CASTNET_WEEKLY    T
 setenv CASTNET_HOURLY    T
 setenv CASTNET_DAILY_O3  T
 setenv CASTNET_DRYDEP    T
 setenv CASTNET_DRYDEP_O3 T 
 setenv CSN               T
 setenv IMPROVE           T
 setenv NADP              T
 setenv SEARCH_HOURLY     T
 setenv SEARCH_DAILY      T
 setenv NAPS_HOURLY       T
 setenv NAPS_DAILY_O3     T

#> Non-standard networks (should be set to F unless specifically required). 
 setenv EMEP_HOURLY       F
 setenv EMEP_DAILY        F
 setenv EMEP_DAILY_O3	  F
 setenv EMEP_DEP	  F
 setenv FLUXNET           F
 setenv MDN               F
 setenv NOAA_ESRL_O3	  F
 setenv TOAR		  F

#> Flags to set ozone factors and units (do not change if using standard SPEC_DEF file) 
 setenv O3_OBS_FACTOR    1	# Ozone factor to apply to obs values (1 by default)
 setenv O3_MOD_FACTOR    1	# Ozone factor to apply to model values (1 by default)
 setenv O3_UNITS         ppb	# Ozone units to use in output (ppb by default)
 setenv PRECIP_UNITS     cm	# Precipitation units used in WDEP file (do not change if using standard SPEC_DEF file)


# =====================================================================
#> 7. AMET Configuration Options (Ignore if not using AMET)
# =====================================================================

#> Project name and details. Project will be created if it does not already exist.
 setenv AMET_DATABASE   amet 
 setenv AMET_PROJECT    ${RUNID}               
 setenv MODEL_TYPE      "CMAQ"
 setenv RUN_DESCRIPTION "CMAQv5.3 AMET aqExample test case. July 2016."
 setenv USER_NAME       `whoami`
 setenv EMAIL_ADDR      "my.email@user.com"

# =====================================================================
#> 8. Evaluation Plotting Configuration Options
# =====================================================================

#> Set the location of the configuration file for the batch plotting.
 setenv AMETRINPUT      $AMETBASE/script_analysis/aqExample/input_files/AMET_batch.input

#> Plot Type, options are "pdf","png","both"
 setenv AMET_PTYPE 	both

#> T/F When set to T (default) evalatuion plots will be organized into monthly summaries.  
#>     When set to F evalution plots will be based on all available data between START_DATE_H and END_DATE_H.
#>     Note that the option of setting this flag to F is only available when AMET_DB is set to T.
 setenv EVAL_BY_MONTH 	F

#> Specify a second simulation (already post-processed) to compare to 
#> using model-to-model evaluation plots. This option currently supported 
#> in limited fashion. If not using the AMET database, need to specify the
#> location of the site compare files for the second simulation.
# setenv AMET_PROJECT2     
# setenv OUTDIR2         

#######################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#> User will usually not need to edit beyond this point.

# =====================================================================
#> 8a. Begin Loop Through Simulation Days to Create ACONC Combine File
# =====================================================================

if (${RUN_COMBINE} == 'T') then

#> Create $POSTDIR if it does not already exist.
  if(! -d ${POSTDIR}) then
     mkdir -p ${POSTDIR}
  endif

#> Set the species definition file for concentration species.
 setenv SPECIES_DEF ${SPEC_CONC}
 
#> Loop through all days between START_DAY and END_DAY
 set TODAYG = ${START_DATE_H}
 set TODAYJ = `date -ud "${START_DATE_H}" +%Y%j` #> Convert YYYY-MM-DD to YYYYJJJ
 set STOP_DAY = `date -ud "${END_DATE_H}" +%Y%j` #> Convert YYYY-MM-DD to YYYYJJJ

 while ($TODAYJ <= $STOP_DAY )  #>Compare dates in terms of YYYYJJJ
 
  #> Retrieve Calendar day information
   set YYYY = `date -ud "${TODAYG}" +%Y`
   set YY = `date -ud "${TODAYG}" +%y`
   set MM = `date -ud "${TODAYG}" +%m`
   set DD = `date -ud "${TODAYG}" +%d`
  #> for files that are indexed with Julian day:
  #set YYYYJJJ = `date -ud "${TODAYG}" +%Y%j` 

  #> Define name of combine output file to save hourly average concentration.
  #> A new file will be created for each month/year.
   setenv OUTFILE ${POSTDIR}/${COMBINE_ACONC_NAME}_${YYYY}${MM}.nc

  #> Define name of input files needed for combine program.
  #> File [1]: CMAQ conc/aconc file
  #> File [2]: MCIP METCRO3D file
  #> File [3]: CMAQ APMDIAG file
  #> File [4]: MCIP METCRO2D file
   setenv INFILE1 ${CCTMOUTDIR}/${CCTM_ACONC_NAME}_${YYYY}${MM}${DD}.nc
   setenv INFILE2 ${METDIR}/${METCRO3D_NAME}_${YY}${MM}${DD}.nc
   setenv INFILE3 ${CCTMOUTDIR}/${CCTM_APMDIAG_NAME}_${YYYY}${MM}${DD}.nc
   setenv INFILE4 ${METDIR}/${METCRO2D_NAME}_${YY}${MM}${DD}.nc

  #> Executable call:
   ${EXEC_combine}

  #> Increment both Gregorian and Julian Days
   set TODAYG = `date -ud "${TODAYG}+1days" +%Y-%m-%d` #> Add a day for tomorrow
   set TODAYJ = `date -ud "${TODAYG}" +%Y%j` #> Convert YYYY-MM-DD to YYYYJJJ

 end #Loop to the next Simulation Day


# =====================================================================
#> 8b. Begin Loop Through Simulation Days to Create DEP File
# =====================================================================

#> Set the species definition file for concentration species.
 setenv SPECIES_DEF ${SPEC_DEP}
 
#> Loop through all days between START_DAY and END_DAY
 set TODAYG = ${START_DATE_H}
 set TODAYJ = `date -ud "${START_DATE_H}" +%Y%j` #> Convert YYYY-MM-DD to YYYYJJJ
 set STOP_DAY = `date -ud "${END_DATE_H}" +%Y%j` #> Convert YYYY-MM-DD to YYYYJJJ

 while ($TODAYJ <= $STOP_DAY )  #>Compare dates in terms of YYYYJJJ
 
  #> Retrieve Calendar day information
   set YYYY = `date -ud "${TODAYG}" +%Y`
   set YY = `date -ud "${TODAYG}" +%y`
   set MM = `date -ud "${TODAYG}" +%m`
   set DD = `date -ud "${TODAYG}" +%d`
  #> for files that are indexed with Julian day:
  #set YYYYJJJ = `date -ud "${TODAYG}" +%Y%j` 

  #> Define name of combine output file to save hourly total deposition.
  #> A new file will be created for each month/year.
   setenv OUTFILE ${POSTDIR}/${COMBINE_DEP_NAME}_${YYYY}${MM}.nc

  #> Define name of input files needed for combine program.
  #> File [1]: CMAQ DRYDEP file
  #> File [2]: CMAQ WETDEP file
  #> File [3]: MCIP METCRO2D
  #> File [4]: {empty}
   setenv INFILE1 ${CCTMOUTDIR}/${CCTM_DRYDEP_NAME}_${YYYY}${MM}${DD}.nc
   setenv INFILE2 ${CCTMOUTDIR}/${CCTM_WETDEP1_NAME}_${YYYY}${MM}${DD}.nc
   setenv INFILE3 ${METDIR}/${METCRO2D_NAME}_${YY}${MM}${DD}.nc
   setenv INFILE4

  #> Executable call:
   ${EXEC_combine}

  #> Increment both Gregorian and Julian Days
   set TODAYG = `date -ud "${TODAYG}+1days" +%Y-%m-%d` #> Add a day for tomorrow
   set TODAYJ = `date -ud "${TODAYG}" +%Y%j` #> Convert YYYY-MM-DD to YYYYJJJ

 end #Loop to the next Simulation Day

endif #End $RUN_COMBINE flag


# ===========================================================================
# #> 8c. Begin Loop Through Simulation Days to Create Daily File using HR2DAY
# # =========================================================================

if ($RUN_HR2DAY == 'T') then 

##> Loop through all months between START_DAY and END_DAY
 set TODAYG = ${START_DATE_H}
 set TODAYJ = `date -ud "${START_DATE_H}" +%Y%j` #> Convert YYYY-MM-DD to YYYYJJJ
 set STOP_DAY = `date -ud "${END_DATE_H}" +%Y%j` #> Convert YYYY-MM-DD to YYYYJJJ

 while ($TODAYJ <= $STOP_DAY )  #>Compare dates in terms of YYYYJJJ
 
  #> Retrieve Calendar day information
   set YYYY = `date -ud "${TODAYG}" +%Y`
   set MM = `date -ud "${TODAYG}" +%m`

   setenv M3_FILE_1 ${POSTDIR}/${COMBINE_ACONC_NAME}_${YYYY}${MM}.nc
   setenv OUTFILE ${POSTDIR}/${HR2DAY_ACONC_NAME}_${YYYY}${MM}.nc

  #> Calculate the next month.  Also account for the fact that the next month 
  #> may fall in another calendar year.
   set next_month_date = `date -ud "${TODAYG}+1months" +%Y-%m-%d`
   set MMnext = `date -ud "${next_month_date}" +%m`
   set YYYYnext = `date -ud "${next_month_date}" +%Y`
   #> Find the first day of the next month and format as YYYYJJJ.
   set NEXT_MONTH_J = `date -ud "${YYYYnext}-${MMnext}-01" +%Y%j`

  #> Check to see if the HR2DAY ACONC file for the next month exists.
  #> If it does the first day of the next month will be used to caluclate 
  #> the daily metrics for the last day of the current month 
  #> after the time zone shift to LST.
   if(-e ${POSTDIR}/${COMBINE_ACONC_NAME}_${YYYYnext}${MMnext}.nc) then
     setenv M3_FILE_2 ${POSTDIR}/${COMBINE_ACONC_NAME}_${YYYYnext}${MMnext}.nc
     setenv START_DATE ${TODAYJ}
     setenv END_DATE  ${NEXT_MONTH_J}
   endif 

  #> Executable call:
   ${EXEC_hr2day}

#> Increment both Gregorian and Julian Days by 1 month
   set TODAYG = `date -ud "${TODAYG}+1months" +%Y-%m-%d` #> Add one month
   set TODAYJ = `date -ud "${TODAYG}" +%Y%j`             #> Convert YYYY-MM-DD to YYYYJJJ

 end #Loop to the next Simulation Month

endif #End RUN_HR2DAY  
# =====================================================================
#> 8d. Advanced AMET config options
# =====================================================================

#> Set the run directory (where the batch scripts are located).
 setenv AMET_RUN_DIR 	$AMETBASE/R_analysis_code/batch_scripts
 
#> Base directory where AMET code resides (likely do not need to change any of this)
 setenv MYSQL_CONFIG    ${AMETBASE}/configure/amet-config.R
 set amet_login = "config_file"
 set amet_pass = "config_file"

#> No need to change this.
 setenv AMET_OBS	 $OBS_DATA_DIR
 setenv SITES_META_LIST  $AMETBASE/scripts_db/input_files/sites_meta.input
 setenv AQ_SPECIES_LIST  $AMETBASE/scripts_db/input_files/AQ_species_list.input
 setenv RELOAD_METADATA  F


# =====================================================================
#> 8e. Create AMET database (if needed) and project table
# =====================================================================

 ## setup metadata tables
 echo "**Setting up AMET database if needed**"
 R --no-save --slave --args < $AMETBASE/R_db_code/AQ_setup_dbase.R "$amet_login" "$amet_pass"
 if ( $status != 0 ) then
    echo "Error setting up AMET database"
    exit (1)
 endif

 if ((${CREATE_PROJECT} == 'T') || (${UPDATE_PROJECT} == 'T') || (${REMAKE_PROJECT} == 'T') || (${DELETE_PROJECT} == 'T')) then
   echo "**Checking to see if AQ project table exists, if not create it. Will update existing table if requested.**"
   #> Create $EVALDIR if it does not exist.
   if(! -d ${EVALDIR}) then
     mkdir -p ${EVALDIR}
   endif
   R --no-save --slave --args < ${AMETBASE}/R_db_code/AQ_create_project.R "$amet_login" "$amet_pass" >&! ${EVALDIR}/create_AMET_project_${AMET_PROJECT}.log
   if ( $status != 0 ) then
     echo "Error creating new project OR user decided not to overwrite old project."
     exit (1)
   endif
   echo "Done with project table creation."
 endif


# ============================================================================================
#> 8f. Create and run sitecmp scripts. Load into AMET database. Make plots for each month of data.
# ============================================================================================

#> If any of the plotting flags have been set to T, set make_plots to T to kick off the R batch plotting code. 
 set make_plots = F
 if ((${spatial_plots} == 'T') || (${stacked_barplots} == 'T') || (${time_plots} == 'T') || (${scatter_plots} == 'T') || (${misc_plots} == 'T')) then
   set make_plots = T 
 endif 

if ((${RUN_SITEX} == 'T') || (${WRITE_SITEX} == 'T') || (${LOAD_SITEX} == 'T') || (${make_plots} == 'T')) then
 echo "**Populating new AQ project.  This may take some time...."

#> Run sitecmp one month at a time.
#> Loop through all months between START_DAY and END_DAY one month at a time.

#> Retrieve calendar month and year information for START_DATE.
 set startg = ${START_DATE_H}
 set MM = `date -ud "${startg}" +%m`
 set YYYY = `date -ud "${startg}" +%Y`
  
#> Find the last day of the month of the START_DATE.
 set endg = `date -ud "${YYYY}-${MM}-01 +1months - 1days" +%Y-%m-%d`

#> Convert startg, endg and END_DATE from YYYY-MM-DD to YYYYJJJ
 set startj = `date -ud "${startg}" +%Y%j` 
 set endj   = `date -ud "${endg}" +%Y%j` 
 set stopj  = `date -ud "${END_DATE_H}" +%Y%j` 

 while (${startj} <= ${stopj} )  #>Compare dates in terms of YYYYJJJ

  #In case END_DATE is before the end of the month.
  if(${endj} > ${stopj}) then 
    set endg = ${END_DATE_H}
    set endj = ${stopj}
  endif

  #> Retrieve Calendar month and year information
   set MM = `date -ud "${startg}" +%m`
   set YYYY = `date -ud "${startg}" +%Y`

  if ((${RUN_SITEX} == 'T') || (${WRITE_SITEX} == 'T') || (${LOAD_SITEX} == 'T'))  then

  #> Create $EVALDIR if it does not exist.
   if(! -d ${EVALDIR}) then
     mkdir -p ${EVALDIR}
   endif

  #> ACONC and DEP combine files for this month and the following month.
   setenv CONC_FILE_1 ${POSTDIR}/${COMBINE_ACONC_NAME}_${YYYY}${MM}.nc
   setenv DEP_FILE_1 ${POSTDIR}/${COMBINE_DEP_NAME}_${YYYY}${MM}.nc
   setenv HR2DAY_FILE_1 ${POSTDIR}/${HR2DAY_ACONC_NAME}_${YYYY}${MM}.nc

  #> Calculate the next month.  Also account for the fact that the next month 
  #> may fall in another calendar year.
   set next_month_date = `date -ud "${startg}+1months" +%Y-%m-%d`
   set MMnext = `date -ud "${next_month_date}" +%m`
   set YYYYnext = `date -ud "${next_month_date}" +%Y`

  
  #> Check to see if the combine files for the January of the next year exist and POSTDIR2 is set.
  #>
   if ((${YYYYnext} > ${YYYY}) && ($?POSTDIR2)) then
     setenv POSTDIR ${POSTDIR2}
     set COMBINE_ACONC_NAME = ${COMBINE_ACONC_NAME2}
     set COMBINE_DEP_NAME = ${COMBINE_DEP_NAME2}
     set HR2DAY_ACONC_NAME = ${HR2DAY_ACONC_NAME2}
   endif

  #> Check to see if the combine ACONC file for the next month exists.
  #> 
   if(-e ${POSTDIR}/${COMBINE_ACONC_NAME}_${YYYYnext}${MMnext}.nc) then
     setenv CONC_FILE_2 ${POSTDIR}/${COMBINE_ACONC_NAME}_${YYYYnext}${MMnext}.nc
   endif

#  #> Check to see if the combine DEP file for the next month exists.
   if(-e ${POSTDIR}/${COMBINE_DEP_NAME}_${YYYYnext}${MMnext}.nc) then
     setenv DEP_FILE_2 ${POSTDIR}/${COMBINE_DEP_NAME}_${YYYYnext}${MMnext}.nc 
   endif


#  #> Check to see if the combine DEP file for the next month exists.
   if(-e ${POSTDIR}/${HR2DAY_ACONC_NAME}_${YYYYnext}${MMnext}.nc) then
     setenv HR2DAY_FILE_2 ${POSTDIR}/${HR2DAY_ACONC_NAME}_${YYYYnext}${MMnext}.nc 
   endif


  #> Save sitecmp output in folders organized by year and month.
   setenv OUTDIR  ${EVALDIR}/${YYYY}${MM}
    if(! -d ${OUTDIR}) then
       mkdir -p ${OUTDIR}
    endif
   cd ${OUTDIR}
   
  #> Set environment variables STARTJ and ENDJ needed for AQ_matching.R script (an AMET script).
   setenv STARTJ 	${startj}
   setenv ENDJ   	${endj}
   setenv AMET_OUT 	${OUTDIR}
   setenv START_DATE	${STARTJ}
   setenv END_DATE	${ENDJ}


  #> Run R code amet_extract_all.R to write and execute sitecmp and sitecmp_dailyo3 scripts.
   R --no-save --slave --args < $AMETBASE/R_db_code/AQ_matching.R "$amet_login" "$amet_pass" >&! amet_extract_all_${AMET_PROJECT}.log
   if ( $status != 0 ) then
       echo "Error populating new project with data"
       exit (1)
   endif 
  endif #End $RUN_SITEX OR $WRITE_SITEX or $LOAD_SITEX flags


  #> Create evaluation plots.
  if (${make_plots} == 'T' && ${EVAL_BY_MONTH} == 'T') then
    echo "**Creating AMET batch plots.  This may take some time...."  
    #> Create $PLOTDIR if it does not exist.
    if(! -d ${PLOTDIR}) then
       mkdir -p ${PLOTDIR}
     endif

    #> Sitecmp output are in folders organized by year and month.
    setenv OUTDIR  ${EVALDIR}/${YYYY}${MM}
   
    #> Save batch plotting output in folders organized by year and month.
    setenv AMET_OUT  ${PLOTDIR}/${YYYY}${MM}
    if(! -d ${AMET_OUT}) then
       mkdir -p ${AMET_OUT}
    endif
    cd ${AMET_OUT}

     #> Set environment variables START_DATE_H and END_DATA_H needed for config_CMAQ_eval_AMET.R
    setenv START_DATE_H ${startg}
    setenv END_DATE_H   ${endg}
  
    if ($spatial_plots == 'T') then
      R CMD BATCH $AMET_RUN_DIR/Run_Spatial_Plots_All_Batch.R
    endif

    if ($stacked_barplots == 'T') then
      R CMD BATCH $AMET_RUN_DIR/Run_Stacked_Barplot_All_Batch.R
    endif

    if ($time_plots == 'T') then
      R CMD BATCH $AMET_RUN_DIR/Run_Time_Plots_All_Batch.R
    endif

    if ($scatter_plots == 'T') then
      R CMD BATCH $AMET_RUN_DIR/Run_Scatter_Plots_All_Batch.R
    endif

    if ($misc_plots == 'T') then
      R CMD BATCH $AMET_RUN_DIR/Run_Misc_Plots_Batch.R
    endif

  endif #End $make_plots flag

  #> Increment both Gregorian and Julian dates by one month.
  #> Add one day to the end day of the previous month to start the next month.
   set startg = `date -ud "${endg}+1days" +%Y-%m-%d` 
  #> Find the last day of the month of the new startg. 
   set MMnew = `date -ud "${startg}" +%m`
   set YYYYnew = `date -ud "${startg}" +%Y`
   set endg = `date -ud "${YYYYnew}-${MMnew}-01 +1months - 1days" +%Y-%m-%d`
  #> Convert startg and endg from YYYY-MM-DD to YYYYJJJ
   set startj = `date -ud "${startg}" +%Y%j` 
   set endj   = `date -ud "${endg}" +%Y%j` 

 end #Loop to the next simulation month

endif #End $RUN_SITEX OR $WRITE_SITEX OR LOAD_SITEX OR $make_plots flag


# ============================================================================================
#> 8g. Create evaluation plots for the entire simulation period.
#> This option is only available when the model/obs data have been loaded into the 
#> AMET MYSQL database.
# ============================================================================================

if (${make_plots} == 'T' && ${EVAL_BY_MONTH} == 'F' && ${AMET_DB} == 'T') then
  echo "**Creating AMET batch plots.  This may take some time...."
  #> Save batch plotting output in folders organized by year and month of start date.
  setenv AMET_OUT  ${PLOTDIR}
  if(! -d ${AMET_OUT}) then
     mkdir -p ${AMET_OUT}
  endif
  cd ${AMET_OUT}
  
  if ($spatial_plots == 'T') then
    R CMD BATCH $AMET_RUN_DIR/Run_Spatial_Plots_All_Batch.R
  endif

  if ($stacked_barplots == 'T') then
    R CMD BATCH $AMET_RUN_DIR/Run_Stacked_Barplot_All_Batch.R
  endif

  if ($time_plots == 'T') then
    R CMD BATCH $AMET_RUN_DIR/Run_Time_Plots_All_Batch.R
  endif

  if ($scatter_plots == 'T') then
    R CMD BATCH $AMET_RUN_DIR/Run_Scatter_Plots_All_Batch.R
  endif

  if ($misc_plots == 'T') then
    R CMD BATCH $AMET_RUN_DIR/Run_Misc_Plots_Batch.R
  endif
  
endif #End $make_plots AND $EVAL_ALL AND $AMET_DB flag

if (${make_plots} == 'T' && ${EVAL_BY_MONTH} == 'F' && ${AMET_DB} == 'F') then

  echo 'Please set EVAL_BY_MONTH flag to T when AMET_DB is set to F to make plots. Evaluation by the full time period is only available when AMET_DB is set to T.'

endif


exit ()
