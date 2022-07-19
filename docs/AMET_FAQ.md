# Frequently Asked Questions for Upgrading to the Latest AMET Version

## Table of Contents:
* [Do I need to update from v1.4 to v1.5?](#why_update_v14_v15)
* [What do I need to do to update from v1.4 to v1.5?](#update_v14_v15)
* [What differences should I expect with v1.5 compared to v1.4?](#diff_v14_v15)
* [Technical support for AMET](#tech_support)

<a id=why_update_v14_v15></a>
## What changed and should I update to AMET v1.5?
AMETv1.5 is an incremental update from version 1.4. It includes important enhancements and new analysis scripts. **If a user intend to use the latest available AMET-AQ observation files, then upgrading to AMETv1.5 is required. Likewise, if upgrading to AMETv1.5, a user must update to the latest version of the AMET-AQ observation files. Updating both the AMET version and AMET-AQ observation files together will insure all the AQ species matching between CMAQ and the observations is done correctly.**

**AMET-MET is backward compatible. No changes have been made to the underlying database structure.** New R_db_scripts and R_analysis_scripts will operate using old cshell wrappers (scripts_db and scripts_analysis). New scripts_db and scripts_analysis may not work with the old R_db_scripts and R_analysis_scripts, but that scenario is not likely or sensible. A users should look through the following MET updates/bug fixes and new features below to see if they are relevant, but an **update should be seamless and not interfere with prior AMET-MET work or operation.**

#### AQ Updates v1.5

-	Support added for CAPMON 
-	Updated batch scripts to incorporate new analysis scripts
-	Updated AQ_species_list.input file:
       - to properly map species in the updated AMET observation files (specifically related to EC/OC)
       - to include additional species
       - to include CAPMON
-	Added option to rename an existing project
-	Updated AMET-AQ observation files (see notes in [AMET_Release_Observation_Files_Readme.txt](https://github.com/USEPA/AMET/files/8655699/AMET_Release_Observation_Files_Readme.txt))
-	Numerous minor bug fixes
-	Some improvements made to error checking and reporting

#### New AQ Features v1.5

-	New analysis scripts
       - AQ_Kellyplot_region.R
       - AQ_Kellyplot_season.R
       - AQ_Kellyplot_multisim.R (removed)
       - AQ_Plot_Spatial_MtoM_leaflet.R
       - AQ_Scatterplot_mtom_density.R
       - AQ_Timeseries_multi_species_plotly.R
       - AQ_Timeseries_species_plotly.R
-	New analysis script options
       - Increased number of individual projects that can be specified (currently 18)
       - Kelly plots have been updated better chose plot ranges
       - Added ability to further customize Kelly plots through input options
       - Added function to only use common sites between multiple projects (useful for comparing two different sized domains)

#### MET Updates v1.5

-	Added forecast and model initialization hours as database fields for the case of WRF or MPAS model forecast evaluations
-	Fix of U.S. State meta data information for observation sites that was removed from most sites description in MADIS files post-2014
-	Ability to run multiple AMET-MET matching scripts at the same time from the same directory
-	Sub-hourly observational and model output considerations work for both retrospective and forecast model simulations
-	Improve handling of cases where model may not have a variable like relative humidity or other key variables
-	Option to use Qv and T in MPAS RH calculations (if Qv is available) instead of direct RH (matches WRF method for more direct comparisons)
-	AutoFTP expanded for new SURFRAD radiation option and will check the MADIS real-time observation directory if file is not present in the archive directory for near-real-time or forecast modeling cases
-	General update of checks for more robust operation in the case of odd inputs or missing data
-	QC settings of allowable observed variable range and maximum model-observation difference configurable via R input files
-	Latitude/Longitude bounds of spatial analysis set to observation site range if not specified
-	Additional text ouput options for analysis scripts

#### New MET Features v1.5

-	Compatibility with limited area MPAS grids
-	All WRF projections work in model-to-observation matching routine (e.g.; lambert, polar stereo., mercator and lat-lon)
-	NOAA SURface RADition (SURFRAD) Network option for real or near-real-time modeling (BSRN has a curation delay of months)
-	Meteorology and Chemistry Interface Processor (MCIP) compatibility
       - R functions were added to read MCIP METCRO2D and METCRO3D files and match with surface, upper-air and radiation measurements
-	Added new master site metadata file to map dynamically with MADIS observations that includes state, country and full site description
       - This allows more complex query options (i.e.; climate regions of the US or world, island nations and Continents)       
-	PRISM precipitation evaluation updated to leverage R "prism" package to automatically aquire daily, monthly and annual raster data as text data is no longer distributed. Precipitaton statistics are output in text file and HTML-based Leaflet visulization of precipitation is produced.
-	Wind vector statistics are added to wind speed and direction statistics for daily surface, spatial surface and upper-air analyses. 
 


<a id=update_v14_v15></a>
## What do I need to do to update from v1.4 to v1.5?
Obtain and install the AMETv1.5 code from the AMET repository. If intending to use the AMET-AQ side of AMET, also obtain the latest versions of the AMET observation files.

<a id=diff_v14_v15></a>
## What differences should I expect with v1.5 compared to v1.4?
On the air quality side of AMET, there should be no differences in the analysis scripts between AMET 1.4 and 1.5. There are several new analysis scripts avaiable, and these new scripts have been added to the batch scripting capability in AMET-AQ, so users can expect several new analysis plots when using the AMET-AQ batch scripts.  

The air quality species processed through AMET have changed between 1.4 and 1.5, with several additional species processed through AMET in 1.5. There is also improved consistency in the specification of EC/OC from AQS/CSN over time in the AMET processing, the result of updates to both the AMET code and the air quality observation files provided for use with AMET. See the release notes on the main Github page for more details on the updates made to the specification of EC/OC in AMETv1.5.

<a id=tech_support></a>
## Technical support for AMET
Technical support for AMET should be directed to the [CMAS Center User Forum](https://forum.cmascenter.org/). 
 [**Please read and follow these steps**](https://forum.cmascenter.org/t/please-read-before-posting/1321) prior to submitting new questions to the User Forum.
