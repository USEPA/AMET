Atmospheric Model Evaluation Tool
======

## AMETv1.6

Atmospheric Model Evaluation Tool (AMET) website: (https://www.epa.gov/cmaq/atmospheric-model-evaluation-tool)

The Atmospheric Model Evaluation Tool (AMET) is a suite of software designed to facilitate the analysis and evaluation of predictions from meteorological (e.g., WRF) and air quality (e.g., CMAQ) models. AMET matches the model output for particular locations to the corresponding observed values from one or more networks of monitors. These pairings of values (model and observation) are used to statistically and graphically analyze the model’s performance using analysis scripts provided as part of the AMET code. AMET leverages open source applications and software packages, specifically Cshell, R, and MariaDB, and to a lesser extent Fortran. 

[Frequently asked questions for upgrading to the latest AMET version](docs/AMET_FAQ.md) - Updated for v1.6 release.

## AMETv1.6

- General Updates for v1.6
    - Moved from using RMySQL to RMariaDB, as R is moving away from RMySQL
    - Provided beta code of an AMET website interface for producing analysis plots. This beta code comes with little documentation at this point in time

- AQ Updates v1.6
    - Support added for AirNow ozone and PM2.5 data 
    - Support added for AMTIC HAPS data
    - Support added for PurpleAir PM2.5 data
    - Support added for numerous additional AQS VOC species
    - Updated batch scripts to incorporate new analysis scripts
    - Updated AQ_species_list.input file:
       - to include AirNow
       - to include AMTIC
       - to include PurpleAir
       - to include AQS VOC species
   - Updated AMET-AQ observation files (see notes in AMET_Release_Observation_Files_Readme.txt)
   - Numerous minor bug fixes
   - Updated processing for AMON data to properly adjust for travel blank (when available) or use a fixed value for the blank correction (value depends on year). Also updated the AMON input data file to include a POCode based on the replicate value to avoid records being overwritten when loaded into the database
   - Added ability to the batch processing to use user-defined regions based on an input file with site ID and region name
- New AQ Features v1.6
  - New analysis scripts:
    - AQ_Summary_Panel_Plot.R
    - AQ_Plot_Spatial_animation_ggplot.R
    - AQ_Plot_Spatial_animation_plotly.R
    - AQ_Histogram_plotly.R
    - AQ_Kellyplot_region_plotly.R
    - AQ_Kellyplot_season_plotly.R
    - AQ_Kellyplot_plotly.R
    - AQ_Scatterplot_density_ggplot.R (enhanced)
    - AQ_Scatterplot_density_plotly.R
    - AQ_Timeseries_bysite.R
    - AQ_Timeseries_bysite_plotly.R
  - New analysis script options
    - Added popup time series option to AQ_Plot_Spatial_leaflet.R script. Combined the multiple plots into a single plot with selectable metrics
    - Added option to aggregate sites by parameter occruence code (POC) and common grid cell
- MET Updates v1.6

- New MET Features v1.6
  - Added support and example scripts to use a number of traditionally AQ only scripts with MET data. These scripts include:
    - run_AMET_batch_scripts_met.csh
    - run_boxplot_ggplot.csh
    - run_boxplot_plotly.csh
    - run_histogram_plotly.csh
    - run_kellyplot_plotly.csh
    - run_kellyplot_region_plotly.csh
    - run_kellyplot_season_plotly.csh
    - run_plot_spatial_animation_ggplot.csh
    - run_plot_spatial_animation_plotly.csh
    - run_plot_spatial_diff_leaflet.csh
    - run_plot_spatial_leaflet.csh
    - run_scatterplot_density_ggplot.csh
    - run_spatial_surface.csh
    - run_stats_plots.csh
    - run_stats_plots_leaflet.csh
    - run_summary_panel_plot.csh
    - run_timeseries_plotly.csh


## Getting the AMET Repository
This AMET Git archive is organized with each official public release stored as a branch on the main USEPA/AMET repository.
To clone code from the AMET Git archive, specify the branch (i.e. version number) and issue the following command from within
a working directory on your server:
```
git clone -b 1.6 https://github.com/USEPA/AMET.git AMET_v16
```

Earlier release versions of AMET that are currently available on Git Hub include:

* [v1.2 (July 2013)](https://github.com/USEPA/AMET/tree/1.2)
* [v1.3 (July 2017)](https://github.com/USEPA/AMET/tree/1.3)
* [v1.4 (August 2018)](https://github.com/USEPA/AMET/tree/1.4)
* [v1.5 (August 2022)](https://github.com/USEPA/AMET/tree/1.5)
* [v1.6 (September 2026)](https://github.com/USEPA/AMET/tree/1.6)

## EPA Disclaimer
The United States Environmental Protection Agency (EPA) GitHub project code is provided on an "as is" basis and the user assumes responsibility for its use. EPA has relinquished control of the information and no longer has responsibility to protect the integrity , confidentiality, or availability of the information. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by EPA. The EPA seal and logo shall not be used in any manner to imply endorsement of any commercial product or activity by EPA or the United States Government.    [<img src="https://licensebuttons.net/p/mark/1.0/88x31.png" width="50" height="15">](https://creativecommons.org/publicdomain/zero/1.0/)
 

