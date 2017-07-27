
Unofficial Atmospheric Model Evaluation Tool (AMET) version 1.3
=======


## AMET Overview

## Getting the AMET Repository
This AMET Git archive is organized with each official public release stored as a branch on the main USEPA/AMET repository.
To clone code from the AMET Git archive, specify the branch (i.e. version number) and issue the following command from within
a working directory on your server:
```
git clone -b 1.3 https://github.com/USEPA/AMET.git AMET_v13
```


## AMET 1.3 Repository Guide
Source code and scripts are organized as follows:
* **configure:** AMET configuration scripts
* **docs:** AMET documentation
* **obs:** air quality and meteorology observational data
* **output:** output from AMET analysis scripts
* **R_db_code:** R code for loading data to the AMET MySQL database
* **R_analysis_code:** R codes for generating AMET analysis plots
* **scripts_analysis:** scripts for running AMET analyses
* **scripts_db:** scripts for loading the AMET database
* **src:** source code of the AMET model->obs utility programs

## Documentation
Code documentation are included within this repository (they are version-controlled along with the code itself).  

[AMETv1.3 Quick Start Guide](docs/AMET_QuickStart_Guide_v13.md)   
[AMETv1.3 User Guide](docs/AMET_Users_Guide_v1.md)   
[AMETv1.3 Installation Guide](docs/AMET_Install_Guide_v13.md )   
=======

The release versions of CMAQ that are currently available on Git Hub include:

* [v1.2 (July 2013)](https://github.com/USEPA/AMET/tree/1.2)
* [v1.3 (June 2017)](https://github.com/USEPA/AMET/tree/1.3)

## Release Notes
There are a number of changes made to AMETv1.3 from the previous version. Some updates apply to the entire AMETv1.3 system, while other updates are specific to the MET or AQ sides of AMET.

AMET-wide updates:
   - All PERL code has been removed from AMETv1.3 and has either been deprecated or replaced with R scripts. This removes the requirement to have PERL installed in order to use AMETv1.3, which should greatly simplify the installation process for AMET.
   - The database setup and project creation has been simplified. There is now just one script to create an AMET database user, which is not required to run if using an existing database user. The creation and setup of the AMET MySQL database and projects is done using a single script (the MET and AQ sides each have their own script to do this). Therefore, a user only has to edit a single script in order to create and populate a new project (both the database and project will automatically be created if needed).
   - The overall number of required input files has been reduced. 
   - The MySQL credential management has been made more robust. Users can now opt to either enter the MySQL login/pass information manually, provide the login/pass in the run script or through the queue (e.g. qsub), or point a configure file that contains the MySQL user credentials (default option). This allows the user more options for handling the MySQL login/password information.
   
   - Speed improvements by sending MySQL a temporary query file for each model time period instead of thousands of rapid-fire single site queries. Cuts the model-obs matching time in half or more (some test were 4 x faster for the meteorology matching).




AQ-side updates:
   - A number of new analysis scripts have been added to AMETv1.3
   - Several new options have been introduced to control the production and look of many of the scripts.
   - A new batch processing script has been added to AMETv1.3. This allows for the execution of all the analysis scripts through a single "batch" script. The user can specify which set of analysis scripts they wish to run (e.g. scatter plots, time series plots, box plots, etc.) and minimally control the settings for those plots. The user will execute a single script which will then run all the specified analysis scripts and write the output to an organized directory tree
   - Support for two new AQ networks, AMON and FLUXNET

MET-side updates:

- MPAS compatibility using barycentric interpolation of model output to observation location. Note: MM5, MCIP and Eta have been deprecated.

- R centric model-obs matching instead of Perl. Code is simplified as a result using main model-obs driver, which calls functions that extract model data, obs data, map obs sites to model domain and perform date operations. Code is much better documented and organized for users who want to modify or contribute to AMET.

- Simplified user configuration. Model type is automatically determined by a NetCDF read of model output. It will skip initialization time step where diagnostic meteorological parameters are zero automatically (MPAS). New databases, project ID, stations table, etc are automatically created if they do not exist.

- Stations table can be dynamically updated during every MADIS obs file read with new sites, while existing obs sites are ignore. This ensures users can keep up-to-date on new sites (many global sites have been added in recent years).

- Direct read of NetCDF MADIS obs files. Alleviates the need of the MADIS API and utilities like sfcdump.exe, etc. Only R, a few R modules and MySQL are needed in terms of external software.

- Better automatic FTP option of the MADIS observation data within the R observation function. Several MADIS server options are provided and it checks users MADIS database to see if file exists, so no repeat downloads.

- Ability to provide non-MADIS observations via simple text format. Hourly text files (need to follow naming convention of MADIS: YYYYMMDD_HHMMSS) and in the MADIS base directory in directory named "surface_text".

- General update of existing evaluation scripts and plots in terms of better comments, formatting, text outputs and plots.

- Surface meteorology evaluation is currently the only driver released, but it will be followed in quick succession with a model-obs driver for SurfRAD (surface radiation), wind profiler, raob, ACARS, VAD wind profiler and PRISM precipitation.
   
   
## EPA Disclaimer
The United States Environmental Protection Agency (EPA) GitHub project code is provided on an "as is" basis and the user assumes responsibility for its use. EPA has relinquished control of the information and no longer has responsibility to protect the integrity, confidentiality, or availability of the information. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by EPA. The EPA seal and logo shall not be used in any manner to imply endorsement of any commercial product or activity by EPA or the United States Government.    [<img src="https://licensebuttons.net/p/mark/1.0/88x31.png" width="50" height="15">](https://creativecommons.org/publicdomain/zero/1.0/)
