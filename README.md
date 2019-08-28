Atmospheric Model Evaluation Tool
======

## AMETv1.4

Atmospheric Model Evaluation Tool (AMET) website: (https://www.epa.gov/cmaq/atmospheric-model-evaluation-tool)

The Atmospheric Model Evaluation Tool (AMET) is a suite of software designed to facilitate the analysis and evaluation of predictions from meteorological and air quality models. AMET matches the model output for particular locations to the corresponding observed values from one or more networks of monitors. These pairings of values (model and observation) are then used to statistically and graphically analyze the model’s performance.

## AMETv1.4
New features in AMET version 1.4 include:
* Streamlined database query function for AMET-AQ
* Improved error handling for missing data
* Simplified process for adding new AQ networks/species
* New interactive HTML R plots using the leaflet and dyGraphs R packages
* Added support for global TOAR and NOAA ESRL networks
* Ability to process and analyze AQ data without the database present
* Improved batch scripting for AQ analysis
* New WRF/MPAS upper-air rawinsonde analysis
* New WRF/MPAS surface shortwave radiation analysis
* New WRF/MPAS PRISM rainfall analysis
* New 2-m moisture time series comparison with RH
* Fixed MADIS download when file is not on FTP server
* Site metadata improved to include state and elevation
* Improve speed of database population

## Getting the AMET Repository
This AMET Git archive is organized with each official public release stored as a branch on the main USEPA/AMET repository.
To clone code from the AMET Git archive, specify the branch (i.e. version number) and issue the following command from within
a working directory on your server:
```
git clone -b master https://github.com/USEPA/AMET.git AMET_v14
```

The release versions of CMAQ that are currently available on Git Hub include:

* [v1.2 (July 2013)](https://github.com/USEPA/AMET/tree/1.2)
* [v1.3 (July 2017)](https://github.com/USEPA/AMET/tree/1.3)
* [v1.4 (August 2018)](https://github.com/USEPA/AMET)

## EPA Disclaimer
The United States Environmental Protection Agency (EPA) GitHub project code is provided on an "as is" basis and the user assumes responsibility for its use. EPA has relinquished control of the information and no longer has responsibility to protect the integrity , confidentiality, or availability of the information. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by EPA. The EPA seal and logo shall not be used in any manner to imply endorsement of any commercial product or activity by EPA or the United States Government.    [<img src="https://licensebuttons.net/p/mark/1.0/88x31.png" width="50" height="15">](https://creativecommons.org/publicdomain/zero/1.0/)
 
