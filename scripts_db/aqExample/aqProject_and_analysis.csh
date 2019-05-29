#!/bin/csh -f

#> Simple Linux Utility for Resource Management System 
#> (SLURM) - The following specifications are recommended 
#> for executing the runscript on the atmos cluster at the 
#> National Computing Center used primarily by EPA.
#SBATCH --partition=singlepe
#SBATCH --time 20:00:00
#SBATCH --job-name=CMAQ_eval
#SBATCH --gid=mod3eval
#SBATCH --output=/work/MOD3EVAL/wtt/CMAQ_v53_Dev/data/output_CCTM_v521_mpi_intel17.0_2016_12US1/PostProcess/CMAQ_eval_%j.txt

#> The following commands output information from the SLURM
#> scheduler to the log files for traceability.
   if ( $SLURM_JOB_ID ) then
      echo Job ID is $SLURM_JOB_ID
      echo Host is $SLURM_SUBMIT_HOST
      echo Nodefile is $SLURM_JOB_NODELIST
      cat $SLURM_JOB_NODELIST | pr -o5 -4 -t
      #> Switch to the working directory. By default,
      #>   SLURM launches processes from your home directory.
      echo Working directory is $SLURM_SUBMIT_DIR
      cd $SLURM_SUBMIT_DIR
   endif
   echo '>>>>>> start model run at ' `date`config

#> Configure the system environment and set up the module 
#> capability
   limit stacksize unlimited

# ==================================================================
#> Script Sections
# ==================================================================
  #> 1. Select which analysis steps you want to execute
  #> 2. Simulation information, input/output directories
  #> 3. System configuration, location of observations and code repositories
  #> 4. Combine Configuration Options   
  #> 5. Hour to Day Configuration Options
  #> 6. Site Compare and Site Compare Daily O3 Configuration Options  
  #> 7. AMET Configuration Options (Ignore if not using AMET)
  #> 8. Evaluation Plotting Configuration Options  


# ==================================================================
#> 1. Select which analysis steps you want to execute
# ==================================================================

#> Combine and sitecmp options
 setenv RUN_COMBINE	  T	#> T/F; Run combine on CCTM output?
 setenv RUN_HR2DAY	  F	#> T/F: Run hr2day to create daily metrics (e.g. 24hr average, MDA8). Need to run hr2day if using TOAR network data or if creating model/obs overlay animations.
 setenv WRITE_SITEX	  T     #> T/F; Write scripts for running site compare for each selected network?
 setenv RUN_SITEX	  T     #> T/F; Run site compare scripts for each selected network?
 
#> AMET options
 setenv CREATE_PROJECT    F	#> T/F; Create AMET project?
 setenv LOAD_SITEX        T	#> T/F; Load site compare output for each selected network into AMET?
 setenv UPDATE_PROJECT	  F	#> T/F; Update the project info for an existing project (all data are retained)
 setenv REMAKE_PROJECT	  F	#> T/F; Remake an existing AMET project. Note that all existing data will be deleted
 setenv DELETE_PROJECT	  F	#> T/F; Delete an existing AMET project. This will delete all data in the existing 
				#>      AMET table and remove the table from the database

#> Plotting options
 setenv AMET_DB 	  T	#> T/F; Set to T if the model/obs pairs are loaded in the AMET database (i.e. by setting LOAD_SITEX = T)
				#>      When set to F, plotting scripts will read the sitecmp .csv files directly
 setenv spatial_plots	  F	#> T/F; Create maps of biase and error from site compare output? 
 setenv stacked_barplots  F	#> T/F; Create stacked bar plots of PM2.5 species from site compare output? 
 setenv time_plots	  F	#> T/F; Create time series plots from site compare output? 
 setenv scatter_plots	  F	#> T/F; Create scatter plots from site compare output? 
 setenv misc_plots	  F	#> T/F; Create bugle plots and soccer goal plots from site compare output? 

# ==================================================================
#> 2. Simulation information, input/output directories
# ==================================================================

#> Start and end dates of simulation to be evaluated.
 setenv START_DATE_H  "2016-05-01"		#> Start day. Should be in format "YYYY-MM-DD".	
 setenv END_DATE_H    "2016-05-31"	#-30"	#> End day. Should be in format "YYYY-MM-DD".
#> Set general parameters for labeling the simulation
 set VRSN = v521				#> Set the model version
 set MECH = cb6r3_ae7_aq        		#> Mechanism ID (should match file name of species defintion files)
 set APPL = v521_mpi_intel17.0_2016_12US1            #> Application Name (e.g. Code version, compiler, gridname, emissions, etc.)

#> Name and location of daily MET output. Required files = METCRO2D, METCRO3D
#> This script assumes MET files are dated with the following naming convention: 
#> ${METCRO2D_NAME}_${YY}${MM}${DD}.nc, ${METCRO3D_NAME}_${YY}${MM}${DD}.nc
 setenv METDIR	/work/MOD3DATA/2016_12US1/met/mcip_v43_wrf_v381_ltng #> Location of MET ouput.
 set METCRO2D_NAME = METCRO2D.12US1.35L		  #> METCRO2D file name (without date and file extension).
 set METCRO3D_NAME = METCRO3D.12US1.35L		  #> METCRO3D file name (without date and file extension).
	
#> Name and location of daily CCTM output. Required files = ACONC, APMDIAG, WETDEP1, DRYDEP.	
#> This script assumes daily CCTM output files are dated with the following naming convention: 
#> [File Name]_${YYYY}${MM}${DD}.nc where [File Name] typically = [File Type]_[Application ID].
#> for example: CCTM_ACONC_v52_intel17.0_SE52BENCH_${YYYY}${MM}${DD}.nc
 setenv CCTMOUTDIR  /work/MOD3EVAL/wtt/CMAQ_v53_Dev/data/output_CCTM_v521_mpi_intel17.0_2016_12US1 #> Location of CCTM ouput.
# setenv CCTMOUTDIR	/asm/MOD3EVAL/CMAQ_v53_Dev/CMAQv521_2016_12US1_Eval_Base/02

 set CCTM_ACONC_NAME    = CCTM_ACONC_${APPL} 	#> ACONC file name (without date and file extension).
 set CCTM_APMDIAG_NAME  = CCTM_APMDIAG_${APPL}	#> APMDIAG file name (without date and file extension).
 set CCTM_WETDEP1_NAME  = CCTM_WETDEP1_${APPL}  #> WETDEP1 file name (without date and file extension). 
 set CCTM_DRYDEP_NAME   = CCTM_DRYDEP_${APPL} 	#> DRYDEP file name (without date and file extension).
                                                
#> Names and locations of output files created with this script. 
#> This script assumes monthly combine files containing hourly data are dated with the following naming convention:
#> ${COMBINE_ACONC_NAME}_${YYYY}${MM}.nc,${COMBINE_DEP_NAME}_${YYYY}${MM}.nc
#> Monthly hr2day files with daily metrics have the following naming convention:
#> ${HR2DAY_ACONC_NAME}_${YYYY}${MM}.nc
 setenv POSTDIR	/work/MOD3EVAL/wtt/CMAQ_v53_Dev/data/output_CCTM_v521_mpi_intel17.0_2016_12US1/PostProcess	#> Location to write combine files. (Or location of existing combine files). 
 set COMBINE_ACONC_NAME = COMBINE_ACONC_${APPL}				#> Name of combine ACONC file (without date and file extension).
 set COMBINE_DEP_NAME   = COMBINE_DEP_${APPL}				#> Name of combine DEP file (without date and file extension).
 set HR2DAY_ACONC_NAME  = HR2DAY_LST_ACONC_${APPL}			#> Name of HR2DAY ACONC file (without date and file extension).
          
#> Names and locations of output files created with this script.
 setenv EVALDIR	/work/MOD3EVAL/wtt/CMAQ_v53_Dev/data/output_CCTM_v521_mpi_intel17.0_2016_12US1/PostProcess	#> Location where sitecmp files will be saved.
 setenv PLOTDIR	/work/MOD3EVAL/wtt/CMAQ_v53_Dev/data/output_CCTM_v521_mpi_intel17.0_2016_12US1/PostProcess	#> Location where evaluaiton plots will be saved. 
 
# ==================================================================================
#> 3. System configuration, location of observations and code repositories
# ==================================================================================

#> Configure the system environment
 setenv compiler     intel     			#> Compiler used to compile combine, sitecmp, sitecmp_dailyo3
 setenv compilerVrsn 17.0    			#> Compiler version
# source /work/MOD3DEV/cmaq_common/cmaq_env.csh  #> Set up compilation and runtime environments on atmos
# source /work/MOD3DEV/cmaq_common/R_env.csh  	#> Set up R environment on atmos

#> Set the location of the $CMAQ_HOME project directory used in
#> the bldit_project.csh script of the CMAQ5.2 git repository. 
#> This directory contains executables for combine, sitecmp and 
#> sitecmp_daily and the species definition files needed
#> for combine.  If you are not using a CMAQ5.2 reposiotry you can 
#> modify the location of the executables and spec_def files later 
#> in the script.
 set CMAQ_HOME = /home/kfoley/projects/cmaq_dev

#> Set the location of the observation data (probably do not have to change this).
# setenv OBS_DATA_DIR  /work/MOD3EVAL/aq_obs/routine	
 setenv OBS_DATA_DIR /work/MOD3EVAL/wtt/obs_data/Release_Obs_Dev
 setenv RELOAD_METADATA  T

#> Set the format of the site files needed for sitecmp and sitecmp_dailyo3.  
#> Options: txt or csv   The .csv files include metadata about the monitoring site (e.g. county, elevation).
 setenv SITE_FILE_FORMAT csv

#> Base directory where AMET code resides (probably do not have to change this).
# setenv AMETBASE      /work/MOD3EVAL/amet 		
 setenv AMETBASE /home/kappel/AMET_Code/AMET_Public_Dev

# =====================================================================
#> 4. Combine Configuration Options
# =====================================================================

#> Set the full path of combine executable.
# setenv EXEC_combine ${CMAQ_HOME}/POST/combine/scripts/BLD_combine_${VRSN}_${compiler}${compilerVrsn}/combine_${VRSN}.exe
 setenv EXEC_combine /home/kappel/CMAQ_Code/CMAQ521/POST/combine/scripts/BLD_combine_v521_intel17.0/combine_v521.exe

#> Set location of species definition files for concentration and deposition species needed to run combine.
# setenv SPEC_CONC  ${CMAQ_HOME}/POST/combine/scripts/spec_def_files/SpecDef_${MECH}.txt
# setenv SPEC_DEP   ${CMAQ_HOME}/POST/combine/scripts/spec_def_files/SpecDef_Dep_${MECH}.txt
# setenv SPEC_CONC /work/MOD3EVAL/fib/unit_test/CMAQv5.3/aero_sprint/SpecDef_${MECH}.txt
# setenv SPEC_DEP /work/MOD3EVAL/fib/unit_test/CMAQv5.3/aero_sprint/SpecDef_Dep_${MECH}.txt
 setenv SPEC_CONC /work/MOD3EVAL/wtt/CMAQ_v53_Dev/data/output_CCTM_v521_mpi_intel17.0_2016_12US1/PostProcess/SpecDef_cb6r3_ae6_aq_O3_tracers.txt 
 setenv SPEC_DEP /home/kappel/CMAQ_Code/PROJECTS/CMAQv521/POST/combine/scripts/spec_def_files/SpecDef_Dep_cb6r3_ae6_aq.txt

#> Projection sphere type for combine, hr2day, sitecmp (use type 20 to match WRF/CMAQ).
 setenv IOAPI_ISPH 	20

# =====================================================================
#> 5. Hour to Day Configuration Options
# =====================================================================

#> Set the full path of hr2day executable.
# setenv EXEC_hr2day ${CMAQ_HOME}/POST/hr2day/scripts/BLD_hr2day_${VRSN}_${compiler}${compilerVrsn}/hr2day_${VRSN}.exe
# Use this path until model changes have been merged into CMAQ_Dev repo.
 setenv EXEC_hr2day /work/MOD3EVAL/css/git_builds/CMAQ_v52_CHOGREFE_20180725/POST/hr2day/scripts/BLD_hr2day_v53_intel17.0/hr2day_v53.exe

#> Set to use local time for evaluation against observational data (default is GMT)
 setenv USELOCAL Y

#> Location of time zone data file, tz.csv (this is a required input file
#> when using USELOCAL Y to shift from GMT to local time)
 setenv TZFILE /home/kfoley/CMAQ52_repo/POST/bldoverlay/inputs/tz.csv

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
# setenv EXEC_sitecmp 		${CMAQ_HOME}/POST/sitecmp/scripts/BLD_sitecmp_${VRSN}_${compiler}${compilerVrsn}/sitecmp_${VRSN}.exe
# setenv EXEC_sitecmp_dailyo3 	${CMAQ_HOME}/POST/sitecmp_dailyo3/scripts/BLD_sitecmp_dailyo3_${VRSN}_${compiler}${compilerVrsn}/sitecmp_dailyo3_${VRSN}.exe
# Use this path until model changes have been merged into CMAQ_Dev repo.
 setenv EXEC_sitecmp 		/work/MOD3EVAL/css/git_builds/CMAQ_v52_CHOGREFE_20180725/POST/sitecmp/scripts/BLD_sitecmp_v53_intel17.0/sitecmp_v53.exe
 setenv EXEC_sitecmp_dailyo3	/work/MOD3EVAL/css/git_builds/CMAQ_v52_CHOGREFE_20180725/POST/sitecmp_dailyo3/scripts/BLD_sitecmp_dailyo3_v53_intel17.0/sitecmp_dailyo3_v53.exe

#> Include x/y projection values for each site in OUT_TABLE (default N)
 setenv LAMBXY         

#> Number of 8hr values to use when computing daily maximum 8hr ozone (using sitecmp_dailyo3).
#> Allowed values are 24 (use all 8-hr averages with starting hours 
#> from 0 - 23 hr local time) and 17 (use only the 17 8-hr averages
#> with starting hours from 7 - 23 hr local time)
 setenv HOURS_8HRMAX 24
# setenv HOURS_8HRMAX 17
		
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

#> Non-standard networks (should be set to F unless specifically required). 
 setenv EMEP_HOURLY       F
 setenv EMEP_DAILY        F
 setenv EMEP_DAILY_O3	  F
 setenv EMEP_DEP	  F
 setenv FLUXNET           T
 setenv MDN               F
 setenv NAPS_HOURLY       T 
 setenv NAPS_DAILY_O3	  T
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
 setenv AMET_DATABASE   amad_CMAQ_v53_Dev	
 setenv AMET_PROJECT    CMAQv521_2016_12US1_Eval_Base
 setenv MODEL_TYPE      "CMAQ"
 setenv RUN_DESCRIPTION "Base CMAQv5.2.1 simulatuion for v5.3b testing. 12US1 2016 simulation with lightning NO, but no WBD or bidi. Post-processing performed by Wyat Appel. Annual 2016."
 setenv USER_NAME       "kappel"
 setenv EMAIL_ADDR      "appel.wyat@epa.gov"

# =====================================================================
#> 8. Evaluation Plotting Configuration Options
# =====================================================================

#> Set the location of the configuration file for the batch plotting.
 setenv AMETRINPUT      /work/MOD3EVAL/cmaq_exp/post_scripts/config_CMAQ_eval_AMET.R

#> Plot Type, options are "pdf","png","both"
 setenv AMET_PTYPE 	png

#> T/F When set to T (default) evalatuion plots will be organized into monthly summaries.  
#>     When set to F evalution plots will be based on all available data between START_DATE_H and END_DATE_H.
#>     Note that the option of setting this flag to F is only available when AMET_DB is set to T.
 setenv EVAL_BY_MONTH 	T

#> Specify a second simulation (already post-processed) to compare to 
#> using model-to-model evaluation plots. This option currently supported 
#> in limited fashion. If not using the AMET database, need to specify the
#> location of the site compare files for the second simulation.
# setenv AMET_PROJECT2 	"v521_mpi_intel17.0_4CALIF1_20180717"
# setenv OUTDIR2         ${POSTDIR}/201107



#######################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#> User will usually not need to edit beyond this point.

# =====================================================================
#> 8a. Begin Loop Through Simulation Days to Create ACONC Combine File
# =====================================================================

if (${RUN_COMBINE} == 'T') then

#> Create $POSTDIR if it does not already exist.
  if(! -d ${POSTDIR}) then
     mkdir ${POSTDIR}
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
   setenv INFILE2 ${METDIR}/${METCRO3D_NAME}.${YY}${MM}${DD}
   setenv INFILE3 ${CCTMOUTDIR}/${CCTM_APMDIAG_NAME}_${YYYY}${MM}${DD}.nc
   setenv INFILE4 ${METDIR}/${METCRO2D_NAME}.${YY}${MM}${DD}

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
   setenv INFILE3 ${METDIR}/${METCRO2D_NAME}.${YY}${MM}${DD}
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
 setenv AMET_OBS	$OBS_DATA_DIR


# =====================================================================
#> 8e. Create AMET project
# =====================================================================

 if ((${CREATE_PROJECT} == 'T') || (${UPDATE_PROJECT} == 'T') || (${REMAKE_PROJECT} == 'T') || (${DELETE_PROJECT} == 'T')) then
   R --no-save --slave --args < ${AMETBASE}/R_db_code/AQ_create_project.R "$amet_login" "$amet_pass" >&! ${EVALDIR}/create_AMET_project_${AMET_PROJECT}.log
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
     mkdir ${EVALDIR}
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
       mkdir ${OUTDIR}
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
 
  endif #End $RUN_SITEX OR $WRITE_SITEX or $LOAD_SITEX flags


  #> Create evaluation plots.
  if (${make_plots} == 'T' && ${EVAL_BY_MONTH} == 'T') then
   
    #> Create $PLOTDIR if it does not exist.
    if(! -d ${PLOTDIR}) then
       mkdir ${PLOTDIR}
     endif

    #> Sitecmp output are in folders organized by year and month.
    setenv OUTDIR  ${EVALDIR}/${YYYY}${MM}
   
    #> Save batch plotting output in folders organized by year and month.
    setenv AMET_OUT  ${PLOTDIR}/${YYYY}${MM}
    if(! -d ${AMET_OUT}) then
       mkdir ${AMET_OUT}
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
   
  #> Save batch plotting output in folders organized by year and month of start date.
  setenv AMET_OUT  ${PLOTDIR}
  if(! -d ${AMET_OUT}) then
     mkdir ${AMET_OUT}
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

exit ()
