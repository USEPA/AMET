# Frequently Asked Questions for Upgrading to the Latest AMET Version

## Table of Contents:
* [Do I need to update from v1.4 to v1.5?](#why_update_v14_v15)
* [What do I need to do to update from v1.4 to v1.5?](#update_v14_v15)
* [What differences should I expect with v1.5 compared to v1.4?](#diff_v14_v15)
* [Do I need to update from v1.4 to v1.5?](#why_update_v14_v15)
* [Technical support for AMET](#tech_support)

<a id=why_update_v14_v15></a>
## Do I need to update from v1.4 to v1.5?
AMETv1.5 is an incremental update from version 1.4. It includes important enhancements and new analysis scripts. **If a user intend to use the latest available AMET-AQ observation files, then upgrading to AMETv1.5 is required. Likelwise, if upgrading to AMETv1.5, a user must update to the latest version of the AMET-AQ observation files. Updating both the AMET version and AMET-AQ observation files together will insure all the AQ species matching between CMAQ and the obervations is done correctly.**

#### AMETv1.5 Updates

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

#### New Features v1.5

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

<a id=update_v14_v15></a>
## What do I need to do to update from v1.4 to v1.5?

<a id=diff_v14_v15></a>
## What differences should I expect with v1.5 compared to v1.4?

<a id=tech_support></a>
## Technical support for AMET
Technical support for AMET should be directed to the [CMAS Center User Forum](https://forum.cmascenter.org/). 
 [**Please read and follow these steps**](https://forum.cmascenter.org/t/please-read-before-posting/1321) prior to submitting new questions to the User Forum.
