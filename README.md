Atmospheric Model Evaluation Tool
======

## AMETv1.5

Atmospheric Model Evaluation Tool (AMET) website: (https://www.epa.gov/cmaq/atmospheric-model-evaluation-tool)

The Atmospheric Model Evaluation Tool (AMET) is a suite of software designed to facilitate the analysis and evaluation of predictions from meteorological and air quality models. AMET matches the model output for particular locations to the corresponding observed values from one or more networks of monitors. These pairings of values (model and observation) are then used to statistically and graphically analyze the model’s performance.

[Frequently asked questions for upgrading to the latest AMET version](docs/AMET_FAQ.md) - Updated for v1.5 release.

## AMETv1.5

-	Support added for CAPMON 
-	New AQ analysis scripts [(See the AMET User Guide for more details.)](docs/AMET_User_Guide_v15.md#aq-analysis-input-files)
       - New version of Kellyplot to plot multiple simulations by NOAA climate region (AQ_Kellyplot_region.R)
       - New version of Kellyplot to plot multiple simulations by season (AQ_Kellyplot_season.R)
       - Removed one of the existing version of the Kellyplot as it was reduntant with the new Kellyplots that were added (AQ_Kellyplot_multisim.R) 
       - New leaflet (interactive) version of the model-to-model AQ spatial plot (AQ_Plot_Spatial_MtoM_leaflet.R)
       - New model-to-model desity scatter plot (AQ_Scatterplot_mtom_density.R)
       - New species plotly (interactive) time series plot (AQ_Timeseries_species_plotly.R)
       - New multi-species plotly (interactive) time series plot (AQ_Timeseries_multi_species_plotly.R)
-	New AQ analysis script options (docs/AMET_User_Guide_v15.md#aq-analysis-input-files)
       - Increased number of individual projects that can be specified from 10 to 20
       - Kelly plots have been updated better choose default plot ranges
       - Added ability to further customize Kelly plots through input options (min, max, interval)
       - Added function to only use common sites between multiple projects (useful for comparing data from two different sized domains)
-	Updated AQ batch scripts to incorporate new analysis scripts
-	Updated AQ_species_list.input file to:
       - properly map species in the updated AMET observation files (specifically related to EC/OC)
       - include additional species
       - include CAPMON
-	Added option to rename an existing AQ project while retaining existing data
-	Updated AQ observation files (see notes in [AMET_Release_Observation_Files_Readme.txt](https://github.com/USEPA/AMET/files/8655699/AMET_Release_Observation_Files_Readme.txt))
-	See [AMETv5.1 FAQ](docs/AMET_FAQ.md) for all MET bug fixes and updates. Key updates are listed below.
       - Added forecast and model initialization hours as database fields for the case of WRF or MPAS model forecast evaluations
       - NOAA SURface RADition (SURFRAD) Network option for real or near-real-time modeling (BSRN has a curation delay of months) + autoFTP of those data
       - QC settings of allowable observed variable range and maximum model-observation difference configurable via R input files
       - Compatibility with limited area MPAS grids
       - All WRF projections work in model-to-observation matching routine (e.g.; lambert, polar stereo., mercator and lat-lon)
       - Meteorology and Chemistry Interface Processor (MCIP) compatibility
       - Added new master site metadata file to map dynamically with MADIS observations that includes state, country and full site description
       - PRISM precipitation evaluation updated to leverage R "prism" package to automatically aquire daily, monthly and annual raster data because old text data distribtuion is no longer provided. A HTML-based Leaflet visulization of precipitation is produced. Precipitaton statistics are computed and output in a text file.
       - "Wrapper" analysis script developed that can drive spatial, summary, daily, upper-air and radiation analysis for monthly, seasonal, annual, regional subsets of data. Allows users to run any or all of these detailed analysises using a single highly configurable script (e.g., for model evaluation protocol)
       - Wind vector statistics are added to wind speed and direction statistics for daily surface, spatial surface and upper-air analyses
-	Numerous minor bug fixes and error checks in both AQ and MET codes for more robust operation


## Getting the AMET Repository
This AMET Git archive is organized with each official public release stored as a branch on the main USEPA/AMET repository.
To clone code from the AMET Git archive, specify the branch (i.e. version number) and issue the following command from within
a working directory on your server:
```
git clone -b master https://github.com/USEPA/AMET.git AMET_v15
```

Earlier release versions of CMAQ that are currently available on Git Hub include:

* [v1.2 (July 2013)](https://github.com/USEPA/AMET/tree/1.2)
* [v1.3 (July 2017)](https://github.com/USEPA/AMET/tree/1.3)
* [v1.4 (August 2018)](https://github.com/USEPA/AMET/tree/1.4)

## EPA Disclaimer
The United States Environmental Protection Agency (EPA) GitHub project code is provided on an "as is" basis and the user assumes responsibility for its use. EPA has relinquished control of the information and no longer has responsibility to protect the integrity , confidentiality, or availability of the information. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by EPA. The EPA seal and logo shall not be used in any manner to imply endorsement of any commercial product or activity by EPA or the United States Government.    [<img src="https://licensebuttons.net/p/mark/1.0/88x31.png" width="50" height="15">](https://creativecommons.org/publicdomain/zero/1.0/)
 

