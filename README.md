
Atmospheric Model Evaluation Tool (AMET) version 1.3
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
* **bin:** 
* **configure:** 
* **docs:** 
* **obs:**
* **output:**
* **R_db_code:**
* **R_analysis_code:**
* **scripts_analysis:** 
* **scripts_db:** 
* **src:** 

## Documentation
Code documentation are included within this repository (they are version-controlled along with the code itself).  

[AMETv1.3 User Guide](docs/AMET_Users_Guide_v1.md)   
[AMETv1.3 Installation Guide](docs/AMET_Install_Guide_v1.md )   
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
   - The MySQL creditial management has been made more robust. Users can now opt to either enter the MySQL login/pass information manually, provide the login/pass in the run script or through the queue (e.g. qsub), or point a configure file that contains the MySQL user creditials (default option). This allows the user more options for handling the MySQL login/password information.

AQ-side updates:
   - A number of new analysis scripts have been added to AMETv1.3
   - Several new options have been introduced to control the production and look of many of the scripts.
   - A new batch processing script has been added to AMETv1.3. This allows for the execution of all the analysis scripts through a single "batch" script. The user can specifiy which set of analysis scripts they wish to run (e.g. scatter plots, time series plots, box plots, etc.) and minimally control the settings for those plots. The user will execute a single script which will then run all the specified analysis scripts and write the output to an organized directory tree
   - Support for two new AQ networks, AMON and FLUXNET
   

## EPA Disclaimer
The United States Environmental Protection Agency (EPA) GitHub project code is provided on an "as is" basis and the user assumes responsibility for its use. EPA has relinquished control of the information and no longer has responsibility to protect the integrity , confidentiality, or availability of the information. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by EPA. The EPA seal and logo shall not be used in any manner to imply endorsement of any commercial product or activity by EPA or the United States Government.    [<img src="https://licensebuttons.net/p/mark/1.0/88x31.png" width="50" height="15">](https://creativecommons.org/publicdomain/zero/1.0/)
