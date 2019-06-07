run_CMAQ_eval_AMET
========

## Contents

[1. Overview](#Overview)<br>
[2. Running on Atmos](#atmos)<br>
[3. Setting environment variables](#EnvVar)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[3.1 Selection of analysis steps](#picksteps)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[3.2 Simulation information, Input/Output directories](#sim_info)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[3.3 System configuration, location of observations and code repositories](#config)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[3.4 Combine configuration options](#combine)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[3.5 Site compare configuration options](#sitecmp)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[3.6 AMET configuration options](#amet)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[3.7 Evaluation plotting configuration options](#plots)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[3.8 Execution of all post-processing steps](#execute)<br>

<a id="Overview"></a>1. Overview
===========
This run script controls execution of multiple post-processing and evaluation steps including running combine, sitecmp, sitecmp_dailyo3, loading matched model/obs data (i.e. sitecmp files) into the AMET database and creating AMET "batch" evaluation plots.

Location of run script on atmos: 
```
/work/MOD3EVAL/cmaq_exp/post_scripts/run_CMAQ_eval_AMET.csh
```

Sample output is available here:  
```
/work/MOD3EVAL/cmaq_exp/post_scripts/ref_output/SE52BENCH_AMET
```

<a id="atmos"></a>2. Running on atmos
===========
The Simple Linux Utility for Resource Managment System (SLURM) header at the top of the shell script is used to control execution of the run script on the atmos cluster.
* User should change lines with *--gid* and *--output* to reflect their account on atmos.
* User should **not** change the *--partition=singlepe* if they wish to access the AMET database.  

<a id="EnvVar"></a>3. Setting environment variables
===========
The setting of environment variables in the run script is divided into 8 different numbered sections.  Details on the environment variables within each section are provided below. Section 8 is the portion of the script that loops through the simulations days to create the various post-processing outputs. The user will typically only need to make edits to sections 1-7.   

<a id="picksteps"></a>Section 1: Select which analysis steps you want to execute
-------------------------------------
```
 RUN_COMBINE       Run combine on CCTM output? Choices are T,F.
 WRITE_SITEX       Write scripts for running site compare for each selected network? Choices are T,F.
 RUN_SITEX         Run site compare scripts for each selected network? Choices are T,F.
 CREATE_PROJECT    Create AMET project? Choices are T,F.
 LOAD_SITEX        Load site compare output for each selected network into AMET database? Choices are T,F.
 UPDATE_PROJECT    Update the AMET project info for an existing project (all data are retained)? Choices are T,F.
 REMAKE_PROJECT    Remake an existing AMET project. Note that all existing data will be deleted. Choices are T,F.
 DELETE_PROJECT    Delete an existing AMET project. This will delete all data in the existing
                   AMET table and remove the table from the database. Choices are T,F. 
 AMET_DB           Use the AMET database for evaluation plotting? Choices are T,F.
 spatial_plots     Create maps of bias and error from site compare output? Choices are T,F. 
 stacked_barplots  Create stacked bar plots of PM2.5 species from site compare output? Choices are T,F.
 time_plots        Create time series plots from site compare output? Choices are T,F.
 scatter_plots     Create scatter plots from site compare output? Choices are T,F.
 misc_plots        Create bugle plots and soccer goal plots from site compare output? Choices are T,F.
```
All 14 environment variables in this section are T/F flags.  Flags can be set to T or F depending on what post-processing files are needed and which steps have already been completed. While the flags can be set in many different permutations, the post-processing must take place in a specific order:
1. Run the combine utility on CCTM output to create COMBINE_ACONC and COMBINE_DEP files. 
2. Create "sitex" run scripts for controlling the execution of the sitecmp and sitecmp_dailyo3 utilities.
3. Run the sitex scripts to create comma separated files with matched model/obs pairs for different observation networks. 
4. [Optional] Load model/obs pairs into the AMET database.
5. Create evaluation plots based on matched model/obs data using the batch plotting code in AMET.

A user can choose to do all of the steps at once or run the script multiple times.  For example, the script can be set to only run combine by setting the first flag to T and the remaining flags to F.  The user can then rerun the script at a later time to create the sitecmp files and evaluation plots.  In this case the first flag can be set to F since the combine files already exist.

*Notes*
* A user has the option to create an AMET project and load the model/obs data into the AMET MYSQL database. Loading the data into the database allows users who have access to the RTP campus Intranet to access the data online through the [AMET web interface](http://newton.rtpnc.epa.gov/wyat/AMET_AMAD/querygen_aq.php).  The web interface allows for more refined control over the evaluation plots.  Loading the data into the AMET database also allows the users to evaluate the model output across all of the model/obs data in the simulation period rather than the default mode which produces monthly summaries.  This option is set in section 7. 
* AMET_DB should only be set to T if LOAD_SITEX=T (or if LOAD_SITEX has been set to T previously).
* An AMET project does not have to be created in order to use the AMET batch plotting scripts.  If the user chooses not to load the data into the AMET database, they should set the AMET_DB flag to F.  In this case the batch plotting scripts will read the data directly from the .csv sitecmp and sitecmp_dailyo3 files. 

<a id="sim_info"></a>Section 2: Simulation information, Input/Output directories
-------------------------------------
```
 START_DATE_H           Start day. Should be in format "YYYY-MM-DD".
 END_DATE_H             End day. Should be in format "YYYY-MM-DD".
 VRSN                   Model version, e.g. v52
 MECH                   Mechanism ID (should match file name of species definition files, e.g. cb6r3_ae6_aq
 APPL                   Application Name (e.g. Code version, compiler, gridname, emissions, etc.)
 METDIR                 Location of MET output.
 METCRO2D_NAME          METCRO2D file name (without date and file extension).
 METCRO3D_NAME          METCRO3D file name (without date and file extension).
 CCTMOUTDIR             Location of CCTM output.
 CCTM_ACONC_NAME        ACONC file name (without date and file extension).
 CCTM_APMDIAG_NAME      APMDIAG file name (without date and file extension).
 CCTM_WETDEP1_NAME      WETDEP1 file name (without date and file extension).
 CCTM_DRYDEP_NAME       DRYDEP file name (without date and file extension).
 POSTDIR                Location to write combine files. (Or location of existing combine files).
 COMBINE_ACONC_NAME     Name of combine ACONC file (without date and file extension).
 COMBINE_DEP_NAME       Name of combine DEP file (without date and file extension).
 EVALDIR                Location where sitecmp files will be saved (or location of existing sitecmp files).
 PLOTDIR                Location where evaluation plots will be saved.
```
__Required Met and CCTM files__
1. **METCRO2D** - needed for instantaneous hourly surface temperature (TEMP2), planetary boundary height (PBL), solar radiation (RGRND), 10m wind speed (WSDP10), 10m wind direction (WDIR10), precipitation (RN+RC). 
2. **METCRO3D** - needed for instantaneous hourly air density (DENS) which is used in unit conversions of gas and aerosol species
3. **CCTM_ACONC** - needed for hourly average gas and aerosol modeled species time stamped at the top of the hour
4. **CCTM_APMDIAG** - needed for hourly average relative humidity (RH) and modeled aerosol mode parameters time stamped at the top of the hour
5. **CCTM_WETDEP1** - needed for hourly summed gas and aerosol wet deposition species time stamped at the top of the hour
6. **CCTM_DRYDEP** - needed for hourly summed gas and aerosol dry deposition species time stamped at the top of the hour

*Notes*
* PM2.5 modeled size distributions from the CCTM_APMDIAG file are used to calculate PM2.5 species with a cut-off diameter of 2.5μm or less.  These species begin with "PM" in the species definition files provided in the CMAQ code base for version 5.2 or later. For example, PM25_NA is all sodium that falls below 2.5μm diameter.  These 'PM' variables are used for comparisons at IMPROVE and CSN sites.
* Prior to CMAQv5.2, aerosol modeled size distributions were contained in the AERODIAM file which contained instantaneous hourly model variables starting with hour 1.  In CMAQv5.2 the CCTM_APMDIAG output was created to produce hourly average model variables starting with hour 0 which is analogous to the structure of the CCTM_ACONC output file.  This script is structured to *only* work with the CCTM_APMDIAG file for extracting model size distributions.  If the CCTM_APMDIAG file was not produced by the model simulation (by setting CTM_APMDIAG flag to F in the run_cctm.csh run script) then this evaluation script can be modified to remove the dependency on the CCTM_APMDIAG file.  See section 4 for more details.
* Surface temperature and relative humidity are used to calculate an "FRM equivalent" PM2.5 total estimate that accounts for loss of particle nitrate, sulfate and ammonium from the FRM sampling filters. These species are labeled with "\_FRM" in the concentration species definition files provided in the CMAQ code base for versions 5.2 and later, i.e. PMIJ_FRM and PM25_FRM.

__Naming Conventions for Input/Output Files__
Consistent naming conventions are used throughout the script to facilitate looping over dates. 
+ This script assumes MET files are dated with the following naming convention: 
   ```
   ${METCRO2D_NAME}_${YY}${MM}${DD}.nc   
   ${METCRO3D_NAME}_${YY}${MM}${DD}.nc
   ``` 
+ This script assumes daily CCTM output files are dated with the following naming convention: 
    ```
    ${CCTM_Name}_${YYYY}${MM}${DD}.nc
    ```
  For example: *CCTM_ACONC_v52_intel17.0_SE52BENCH_20110701.nc*    
+ This script will create monthly combine files that are dated with the following naming convention: 
  ```
  ${COMBINE_ACONC_NAME}_${YYYY}${MM}.nc  
  ${COMBINE_DEP_NAME}_${YYYY}${MM}.nc
  ```

File names can be adjusted but may require changes to the script below section 7. 

__Organization of post-processing output__
Output files are organized into three directories: 
+ $POSTDIR - location to write combine files, or the location of existing combine files
+ $EVALDIR - location to save sitecmp and sitecmp_dailyo3 .csv files for each network
+ $PLOTDIR - location to save evaluation plots 

These directories can be set to the same path.  This run script is set up to organize the various post-processing steps into monthly files.  For example, if a user has an annual simulation and uses the script to go through all of the post-processing steps the end result will include:
1.  12 monthly COMBINE_ACONC and 12 monthly COMBINE_DEP files with hourly model output, all written to the $POSTDIR directory. 
2.  12 .csv files with matched model/obs data for EACH network selected in Section 5.  These files will be organized into 12 directories labeled $EVALDIR/$YYYY$MM.
3.  Evaluation plots for each month of model/obs pairs, organized into 12 directories labeled $PLOTDIR/$YYYY$MM.

For a 2-week simulation that spans two months, e.g. 6/15/2011 - 7/15/2011, evaluation plots will still be divided into monthly summaries, using the available model data from each month. If the user would prefer the evaluation plots be based on ALL available data from the simulation time period, rather than monthly summaries, there is an option for this in section 7. 

<a id="config"></a>Section 3: System configuration, location of observations and code repositories
-------------------------------------
```
 compiler         Compiler used to compile combine, sitecmp, sitecmp_dailyo3 (e.g. intel, gcc, pgi)
 compilerVrsn     Compiler version (e.g. 17.0.3)
 CMAQ_HOME        Location of CMAQ project directory (see Notes below)
 OBS_DATA_DIR     Location of the sitecmp-ready observation data 
 AMETBASE         Location of AMETv1.3 code base
 ```
*Notes*

Prior to running this post-processing run script, the user is encouraged to build their own executables for the combine, sitecmp and sitecmp_dailyo3 executables using the following steps:
1. Clone the 5.2 branch of the USEPA CMAQ GitHub repository: 
  ```
  gitclone -b 5.2 https://github.com/USEPA/CMAQ.git CMAQ52_repo
  ```
2. Edit and run bldit_project.csh to create a CMAQ “Project” space:
   ```
   Ln 18: set CMAQ_HOME = /home/username/cmaq_project
   Ln 24-40: Select which tools you need (e.g. COMBINE, SITECMP, HR2DAY)
   ./bldit_project.csh epa
   ```
3. Create executables for the Fortran utilities:
   ```
   cd $CMAQ_HOME/POST/combine/scripts
   ./bldit_combine.csh [compiler] [version]
   cd $CMAQ_HOME/POST/sitecmp/scripts
   ./bldit_sitecmp.csh [compiler] [version]
   cd $CMAQ_HOME/POST/sitecmp_dailyo3/scripts
   ./bldit_sitecmp_dailyo3.csh [compiler] [version]
   ```    
   Compiler options are intel, gcc, pgi  
   If you don’t choose a version number, the default for the system you’re on will be used (e.g. on atmos: intel 17.0)  

* CMAQ_HOME should be set to the project directory used in the bldit_project.csh script in step 2.  If you are not using a CMAQ5.2 repository you can comment out the line for CMAQ_HOME in section 3 and modify the location of the executables and the spec_def files in sections 4 and 5.
* OBS_DATA_DIR should be set to the location of the observation data from the different routine networks of interest.  These observation files need to be formatted to be compatible with the sitecmp and sitecmp_dailyo3 utilities.  The pre-formatted files are already available on atmos under the directory /work/MOD3EVAL/aq_obs/routine, but can also be downloaded from the  [CMAS Center Data Clearinghouse](https://www.cmascenter.org/download/data.cfm) under the heading "2000-2015 North American Air Quality Observation Data".
* AMETBASE should be set to the location of the AMETv1.3 code base.  These files are already available on atmos under the directory /work/MOD3EVAL/amet.  They can also be cloned directly from GitHub using the command  `gitclone -b 1.3 https://github.com/USEPA/AMET.git AMET13_repo` 

<a id="combine"></a>Section 4: Combine configuration options
-------------------------------------
```
 EXEC_combine     Full path of combine executable
 SPEC_CONC        Location of species definition files for concentration species 
 SPEC_DEP         Location of species definition files for deposition species
```
This section sets the location of the combine executable and the species definition files for concentration and deposition species.  If ${CMAQ_HOME}, ${compiler}, and ${compilerVrsn} have been set in section 3 then these paths are automatically set and no additional changes are needed in this section.  

The combine Fortran utility combines fields from a set of IOAPI or wrfout files into a single output file. The SPEC_CONC and SPEC_DEP species definition files are used to specify how the concentrations of raw output species from CMAQ should be aggregated or transformed into variables of interest. For example, the concentrations of NO and NO2 from CMAQ can be added together to yield the concentration of NOx. Examples of possible post-processing expressions are shown in the sample species definition files released with CMAQv5.2 under the [CCTM/src/MECHS](https://github.com/USEPA/CMAQ/tree/5.2/CCTM/src/MECHS) folder. Because each chemical mechanism being used in CMAQ differs in the number and kind of species it treats, the sample species definition files provided have been labeled according to the mechanism each corresponds to, i.e. "SpecDef\_${MECH}.txt" for concentration species and "SpecDef\_Dep\_${MECH}.txt" for deposition species.

*Notes*
* All the species listed in the species definition files need to be output when CMAQ is being run. One option is to set the ACONC output to be all species.  
* By default this script is set up to extract the full set of model species that can be paired to observations from a set of standard networks (e.g. AERONET, AMON, AQS, CASTNET, CSN, IMPROVE, NADP, SEARCH). See section 5 for further details on the different chemical species available from each network.  
* A user can create a more targeted evaluation for a specific subset of species by making these modifications to the run script.
1. Create a new species definition file to be used with the combine utility.  For example, here is a sample file for extracting O3, NOx and PM2.5.  In this example the user is not interested in extracting deposition species from the DRYDEP or WETDEP output files or meteorological variables from teh METCRO2D file.
```
 #layer         1
/ File [1]: CMAQ conc/aconc file
/ File [2]: APMDIAG file
/new species    ,units     ,expression

O3              ,ppbV      ,1000.0\*O3[1]
NOX             ,ppbV      ,1000.0\*(NO[1] + NO2[1])
ATOTI           ,ug/m3     ,ASO4I[1]+ANO3I[1]+ANH4I[1]+ANAI[1]+ACLI[1] \
                           +AECI[1]+AOMI[0]+AOTHRI[1] 
ATOTJ           ,ug/m3     ,ASO4J[1]+ANO3J[1]+ANH4J[1]+ANAJ[1]+ACLJ[1] \
                           +AECJ[1]+AOMJ[0]+AOTHRJ[1]+AFEJ[1]+ASIJ[1]  \
                           +ATIJ[1]+ACAJ[1]+AMGJ[1]+AMNJ[1]+AALJ[1]+AKJ[1]
ATOTK           ,ug/m3     ,ASOIL[1]+ACORS[1]+ASEACAT[1]+ACLK[1]+ASO4K[1] \
                           +ANO3K[1]+ANH4K[1]
PM25_TOT        ,ug/m3     ,ATOTI[0]*PM25AT[2]+ATOTJ[0]*PM25AC[2]+ATOTK[0]*PM25CO[2]
```
2. In section 5 only select networks that have observation data for O3, NOx or PM2.5.
3. In section 8a set INFILE1 to the CCTM_ACONC file and INFILE2 to the CCMT_APMDIAG file. Comment out lines for INFILE3 and INFILE4.
4. Since there are no deposition species listed in the species definition file, remove or comment out section 8b which is used to create combine files of deposition species.

<a id="sitecmp"></a>Section 5: Site compare configuration options
-------------------------------------
```
 EXEC_sitecmp              Full path of sitecmp executable
 EXEC_sitecmp_dailyo3      Full path of sitecmp_dailyo3 executable
 IOAPI_ISPH                Projection sphere type for sitecmp and combine (use type 20 to match WRF/CMAQ)
 TIME_SHIFT                Set time shift flag in site compare. This should always be set to 0 unless using ACONC 
                           files that have been time shifted.  
 AQ_SPECIES_LIST           Species list for matching model species names to names in observation data files.
 INC_AERO6_SPECIES         Include specific species from the AERO6 chemical mechanism in the species list.  
                           Choices are T,F.
 INC_CUTOFF                Include PM2.5 species in which a size cut was applied based on modeled aerosol 
                           mode parameters. Choices are T,F.
#> The following flags (T/F or Y/N) are used to select which standard network should be used in the analysis.  
 AERONET               
 AMON                    
 AQS_HOURLY               
 AQS_DAILY_O3             
 AQS_DAILY               
 CASTNET                  
 CASTNET_HOURLY          
 CASTNET_DAILY_O3        
 CASTNET_DRYDEP           
 CSN                      
 IMPROVE                  
 NADP                     
 SEARCH_HOURLY            
 SEARCH_DAILY             
 EMEP_HOURLY             
 EMEP_DAILY               
 FLUXNET                  
 MDN                      
 NAPS_HOURLY             
 NOAA_ESRL_O3             
 #> The following flags are used to set ozone factors and units. Defaults should be used if using 
 #> standard species definition files.
 O3_OBS_FACTOR             Ozone factor to apply to obs values (1 by default)
 O3_MOD_FACTOR             Ozone factor to apply to model values (1 by default)
 O3_UNITS                  Ozone units to use in output (ppb by default)
 PRECIP_UNITS              Precipitation units used in WDEP file (cm by default)  
```
The following table provides the list of available observations from each network.  Additional information on these routine network observational datasets is available in [Section 4.2 of the the AMETv1.3 User's Guide on GitHub](https://github.com/USEPA/AMET/blob/1.3/docs/AMET_Users_Guide_v1.md#Observational_Data)

| Network       | Available Species                                     | Notes |
| ------------- |-------------------------------------------------------| -------|
| AERONET       | AOD_340, AOD_380, AOD_440, AOD_500, AOD_555, AOD_675, AOD_870, AOD_1020, AOD_1640| Data available for 2000 - 2015|          
| AMON          | NH3             |      Data available for 2009 - 2014   |
| AQS_HOURLY    | O3, NO, NOY, NO2, NOX, CO, SO2, PM2.5, PM10, Isoprene, Ethylene, Ethane, Toluene |  Data available for 2000 - 2016|
| AQS_DAILY_O3  | O3_1hrmax, O3_1hrmax_9cell, O3_1hrmax_time, O3_8rhmax, O3_8hrmax_9cell, O3_8hrmax_time, W126, SUM06|Data available for 2000 - 2016 |                
| AQS_DAILY    | PM2.5, PM10, Isoprene, Ethylene, Ethane, Toluene, Acetaldehyde, Formaldehyde, OC, EC, TC, Na, Cl, NaCl, SO4, NO3, NH4, Fe, Al, Si, Ti, Ca, Mg, K, Mn, soil, OTHER, NCOM|Data available for 2000 - 2016  |                
| CASTNET      | SO4, NO3, NH4, TNO3, Mg, Ca, K, Na, Cl, HNO3, SO2|  Data available for 2000 - 2016     |           
| CASTNET_HOURLY|  O3, surface temp, RH, solar radiation, precip, WSPD | Data available for 2000 - 2016  |             
| CASTNET_DAILY_O3| O3_1hrmax, O3_1hrmax_9cell, O3_1hrmax_time, O3_8rhmax, O3_8hrmax_9cell, O3_8hrmax_time, W126, SUM06|Data available for 2000 - 2016 |
| CASTNET_DRYDEP| SO2, HNO3, TNO3, SO4, NO3, NH4 | Data available for 2000 - 2016 |
| CSN           | SO4, NO3, NH4, PM2.5, OC, EC, TC, Na, Cl, Fe, Al, Si, Ti, Ca, Mg, K, Mn, soil, NaCl, OTHER, NCOM| Data available for 2000 - 2016 |                 
| IMPROVE       | SO4, NO3, NH4, PM2.5, OC, EC, TC, Cl, PM10, PM Coarse, Na, NaCl, Fe, Al, Si, Ti, Ca, Mg, K, Mn, soil, OTHER, NCOM|Data available for 2000 - 2016 |
| NADP          | NH4 wet dep, NO3 wet dep, SO4 wet dep, Cl wet dep, Na wet dep, Ca wet dep, Ca wet dep, Mg wet dep, K wet dep, Precip| Data available for 2000 - 2016 | 
| SEARCH_HOURLY | O3, CO, SO2, NO, NO2, NOY, HNO3, NH3, EC, OC, TC, PM2.5, NH4, SO4, WSPD, RH, SFC_TMP, precip, solar radiation |Data available for 2002 - 2013  |      
| SEARCH_DAILY  | SO4, NO3, NH4, TNO3, Na, OC, EC, PM2.5, Al, Si, K, Ca, Ti, Mn, Fe| Data available for 2002 - 2013  |             
| EMEP_HOURLY   | O3, PM2.5, PM10, CO, NO, NO2, NOX, SO2 | Data not currently available from CMAS; Must obtain individually |
| EMEP_DAILY    | O3, PM2.5, PM10, CO, NO, NO2, NOX, SO2 | Data not currently available from CMAS; Must obtain individually |        
| FLUXNET       | USTAR, Soil Heat Flux, Sensible Heat Flux, Latent Heat Flux, Soil H2O Concentration, Soil Temp., Surface Temp., 10-m Wind Speed | Currently limited data available |       
| MDN           | Mercury wet deposition    | Data available for 2000-2014|   
| NAPS_HOURLY   | O3, PM2.5, PM10, CO, NO, NO2, NOX, SO2 | Data currently available for only 2011 |       
| NOAA_ESRL_O3  | O3 | Data available for 2000 - 2016 |   

<a id="amet"></a> Section 6: AMET configuration options
-------------------------------------
```
 AMET_DATABASE             AMET database name, e.g. amad_CMAQ_v52_Dev. Model to model 
                           comparisons are possible for all projects loaded within the same database. If you're unsure
                           which AMET database to use, amad_AMAD_AQ is a "catch-all" database for miscellaneous projects.
 AMET_PROJECT              AMET project name, e.g. v52_intel17_0_SE52BENCH.  Character string 
                           cannot include ".", and should avoid special characters. Project will be created if it does not 
                           already exist.
 MODEL_TYPE                Type of model being evaluated, e.g. "CMAQ"
 RUN_DESCRIPTION           Meta data for the simulation, e.g. "CMAQv5.2 benchmark test case."
 USER_NAME                 User name, e.g. "myuserid" , or can be set to `whoami`
 EMAIL_ADDR                User email address, e.g. "user.name@epa.gov". Currently not used for anything in AMET.
```
This section sets up meta data information that will be loaded into the AMET database along with the model/obs data produced from running sitecmp and sitecmp_dailyo3. This meta data will appear in the [AMET web interface](http://newton.rtpnc.epa.gov/wyat/AMET_AMAD/querygen_aq.php) for users who have access to the RTP campus Intranet.

<a id="plots"></a> Section 7: Evaluation plotting configuration options
-------------------------------------
```
 AMETRINPUT                Set the location of the configuration file for the batch plotting.  
 AMET_PTYPE                Plot type. Options are "pdf","png","both"
 EVAL_BY_MONTH             T/F Flag. When set to T (default) evaluation plots will be organized 
                           into monthly summaries. 
 AMET_PROJECT2             Specify a second simulation (already post-processed) to compare to using 
                           model-to-model evaluation plots, e.g. "CMAQv52_Benchmark_Test" 
 OUTDIR2                   Specify the location of the sitecmp files from the second simulation
```
*Notes*
* An example configuration file for ${AMETINPUT} can be found on atmos: /work/MOD3EVAL/cmaq_exp/post_scripts/config_CMAQ_eval_AMET.R 
  The options set in the configuration file are applied to all batch run scripts.  
* When EVAL_BY_MONTH is set to F evaluation plots will be based on all available data between START_DATE_H and END_DATE_H. This option is only available when AMET_DB is set to T in Section 1.
* Model-to-model evaluation plots, controlled through setting AMET_PROJECT2 and OUTDIR2, are currently supported in a limited fashion. If the user is not using the AMET database (e.g. AMET_DB set to F in Section 1), OUTDIR2 must be set to specify the location of the site compare files for the second simulation.  These sitecmp files should be labeled with the character string specified in the AMET\_PROJECT2 environment variable. AMET will attempt to read the site compare files in the specified directory using the naming structure $Network\_${AMET_PROJECT2}.csv (e.g. AQS_Hourly\_AMET\_PROJECT2\_NAME.csv)

<a id="execute"></a> Section 8: Execution of all post-processing steps
-------------------------------------
The user will typically not need to edit this portion of the run script.  Section 8 is divided into 6 subsections:
* 8a -Loop through simulation days to create ACONC combine files for every month
* 8b - Loop through simulation days to create DEP combine files for every month
* 8c - Advanced AMET configuration options
* 8d - Create AMET project
* 8e - Create and run sitecmp run scripts. Load sitecmp data into AMET database.  Make plots for each month of model/obs data.
* 8f - Create evaluation plots for the entire simulation period.

Looping across simulation days is controlled using the Linux *date* command which can be used for both Gregorian and Julian date formats.  A user can make change to sections 8a, 8b and/or 8e to change the looping structure or to modify the default file naming conventions described in section 2. Below are a few examples of *date* commands that a user may find helpful in customizing their script.
* Retrieve calendar month from date using format MM
```
date -ud "2018-06-30" +%m
06
```
* Retrieve calendar year from date using format YYYY
```
date -ud "2018-06-30" +%Y
2018
```

* Convert Gregorian date YYYY-MM-DD to Julian date YYYYJJJJ
```
date -ud "2018-06-30" +%Y%j
2018181
```
* Increment Gregorian date by one day
```
date -ud "2018-06-30+1days" +%Y-%m-%d
2018-07-01
```
