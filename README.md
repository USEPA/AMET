
Atmospheric Model Evaluation Tool (AMET) version 1.4 Beta
=======


## AMET Overview

The Atmospheric Model Evaluation Tool (AMET) is a suite of software designed to facilitate the analysis and evaluation of predictions from meteorological and air quality models. AMET matches the model output for particular locations to the corresponding observed values from one or more networks of monitors. These pairings of values (model and observation) are then used to statistically and graphically analyze the model’s performance.

## Getting the AMET Repository
This AMET Git archive is organized with each official public release stored as a branch on the main USEPA/AMET repository.
To clone code from the AMET Git archive, specify the branch (i.e. version number) and issue the following command from within
a working directory on your server:
```
git clone -b 1.4b https://github.com/USEPA/AMET.git AMET_v14b
```


## AMET 1.4 Repository Guide
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

[AMETv1.4b Quick Start Guide](docs/AMET_QuickStart_Guide_v14b.md)   
[AMETv1.4b User Guide](docs/AMET_Users_Guide_v14b.md)   
[AMETv1.4b Installation Guide](docs/AMET_Install_Guide_v14b.md )   
=======

The release versions of CMAQ that are currently available on Git Hub include:

* [v1.2 (July 2013)](https://github.com/USEPA/AMET/tree/1.2)
* [v1.3 (July 2017)](https://github.com/USEPA/AMET/tree/1.3)
* [v1.4b (November 2018)](https://github.com/USEPA/AMET/tree/1.4b)

- Surface meteorology evaluation is currently the only driver released, but it will be followed in quick succession with a model-obs driver for SurfRAD (surface radiation), wind profiler, raob, ACARS, VAD wind profiler and PRISM precipitation.
   
   
## EPA Disclaimer
The United States Environmental Protection Agency (EPA) GitHub project code is provided on an "as is" basis and the user assumes responsibility for its use. EPA has relinquished control of the information and no longer has responsibility to protect the integrity, confidentiality, or availability of the information. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by EPA. The EPA seal and logo shall not be used in any manner to imply endorsement of any commercial product or activity by EPA or the United States Government.    [<img src="https://licensebuttons.net/p/mark/1.0/88x31.png" width="50" height="15">](https://creativecommons.org/publicdomain/zero/1.0/)
