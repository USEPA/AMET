# Atmospheric Model Evaluation Tool (AMET) v1.3  
## Installation Guide
-----
**Contents**

[1. Introduction](#Install1)<br>
[2. Download AMET Software and Test Case Data](#Install2)<br>
[3. Install AMET and Related Software](#Install3)<br>
[4. Configure AMET](#Install4)<br>
[5. Install Test Case Data](#Install5)<br>
[References](#InstallRef)<br>

<a id=Install1></a>
## 1.  Introduction

The Atmospheric Model Evaluation Tool (AMET) (Appel et al., 2011; Gilliam et al., 2005) is a
suite of software designed to facilitate the analysis and evaluation of
results from meteorological and air quality models. AMET matches the model output for
particular locations to the corresponding observed values from one or
more networks of monitors. These pairings of values (model and
observation) are then used to statistically and graphically analyze
model performance.

More specifically, AMET can analyze outputs from
the PSU/NCAR Mesoscale Model (MM5), the Weather Research and Forecasting
(WRF) model, the Model for Prediction Across Scales (MPAS), the Community Multiscale Air Quality (CMAQ) model,
the Comprehensive Air Quality Model with Extensions (CAMx), and Meteorology-Chemistry Interface Processor (MCIP)-postprocessed
meteorological data (surface only). The basic structure of AMET consists
of two *fields* and two *processes*.

* The two fields (scientific topics) are **MET** and **AQ**,
    corresponding to meteorology and air quality data.

* The two processes (actions) are **database population** and
    **analysis**. Database population refers to the underlying structure
    of AMET; after the observations and model data are paired in space
    and time, the pairs are inserted into a MySQL database. Analysis
    refers to the statistical evaluation of these pairings and their
    subsequent plotting.

Practically, a user may be interested in using only one of the fields
(either MET or AQ), or may be interested in using both fields. That
decision is based on the scope of the study. The main software
components of AMET are **MySQL** (an open-source database software
system) and **R** (a free software environment for statistical computing
and graphics).

*Note that in AMETv1.3, **perl** was deprecated and is not longer used.*

This installation guide describes the steps
involved in the AMET software installation process. This guide describes how to (1) download the AMET scripts and test data, (2) install the AMET source code and scripts, (3) configure AMET, and  (4) install pre-packaged data for testing the AMET installation. Notes are
provided wherever appropriate pertaining to the installation on a Linux server.

Refer to the AMET User's Guide for instructions on adding new data to the system, and configuring/creating plots.

<a id=Install2></a>
## 2.  Download AMET Software and Test Case Data

Download the AMET software from GitHub and test case data from
the CMAS Center [http://www.cmascenter.org](http://www.cmascenter.org/) as follows:

#### Download AMET source code and scripts

Go to http://github.com/USEPA/AMET

To download a zip archive of the software, click the "Clone or Download" button and select "Download ZIP".

To clone the AMET installation directory to a Linux server, use the following command:

``git clone -b 1.3 https://github.com/USEPA/AMET.git AMET_v13``

Note that this command assumes that git is installed on the Linux system.

#### Download AMET test data

* Go to http://www.cmascenter.org and log in using your existing CMAS account. If you do not already have an account, you will need to create one.
* Navigate to the CMAS Software Clearinghouse by selected Download -> Software from the drop-down menu at the top of the CMAS Center home page.
* Use the Select Software to Download box, select AMET, and click on the “**Submit”** button.
* Choose “AMET 1.3” as the product, “Linux PC” as the operating system, and “GNU compilers” as the choice of compiler, and then click on the “**Submit”** button.
* In the table that appears, follow the links to download:
 * a PDF version of the installation guide (this document)
 * a PDF version of the the AMET 1.3 User’s Guide
 * a tarball of CMAQ model test data (**aqExample.tar.gz**)
 * a tarball of WRF model test data (**wrfExample.tar.gz**).


<a id=Install3></a>
## 3. Install AMET and Related Software

The AMET distribution package consists primarily of Linux c-shell and R scripts. To work as expected for creating model performance evaluation products, the AMET scripts require a series of 3rd-party software packages to be installed on the AMET host Linux system.

Many of these 3rd-party packages are available through standard Linux package management systems, such as yum (RHEL-based) and apt (Debian-based). Users are encouraged to install as much of the 3rd-party AMET software as possible through these package management systems.

### AMET Tier 1 Software

Tier 1 software are used by the AMET Tier 2 and Tier 3 components and must be present on a Linux system to run AMET. Confirm that all of the Tier 1 software are installed on your system before proceeding with the AMET installation. Refer to the documentation for each package for instructions on how to download and install the software.

The versions of these packages that were used by the CMAS Center in their installation and testing are included in parentheses. In
almost all cases these are already on User's Unix system and any contemporary versions will work.

* **gzip** (1.3.9)

* **gfortran** (4.1.2) or other F90 compiler

* **ImageMagick** (6.2.4.5); *Note*: You need only the **convert** utility from this package.

### AMET Tier 2 Software

Tier 2 software includes scientific software utilities for accessing and storing data, calculating statistics, and creating graphics. Web links are provided here to the download the software. Refer to the documentation provided by the software distributors for installation instructions. Notes specific to the installation of these packages for use with AMET are provided here.

#### Network Common Data Form (netCDF)
 [**http://www.unidata.ucar.edu/downloads/netcdf/index.jsp**](http://www.unidata.ucar.edu/downloads/netcdf/index.jsp)

*Notes*:
* Installation needs to include a static library and include files.
* You will need the **ncdump** utility.
* By default, netCDF is installed in **/usr/local**. To install it in a different directory, see the installation notes.
* When using the **gcc** compilers, make sure **g++** is set up to use **gcc,** as the **c++** compiler will not work correctly.
* For netCDF versions later than 4.1, the C and Fortran versions of the library are distributed and built separately.

#### Input/Output Applications Programming Interface (I/O API)
[**http://www.cmascenter.org/ioapi**](http://www.cmascenter.org/ioapi)

 *Notes*:
 * If I/O API and netCDF are already installed on your system, use those packages for AMET.
 * Build the nocpl version of the I/O API for the data formats used with AMET.

#### MySQL
[**http://dev.mysql.com/downloads**](http://dev.mysql.com/downloads)

*Notes*:
* Install both the MySQL server and client. At a minimum, the MySQL client must be on the same machine that will host the AMET scripts. The MySQL server can either be installed on the AMET host or an a remote host.
* MySQL development files (include files and libraries), such as **mysql.h** and **libmysqlclient.so.15**, are needed on the system that will run AMET.
* If MySQL server is installed on a remote host, the server permissions will need to be granted to support accessing the database from the AMET local host.
* There are different ways to configure MySQL for use with AMET. In the example below, a single database user, **ametsecure**, is created with root access to the database. This user is given full privileges to read-write to the database. This user would then be able to load data into the database and create plots. As write access to the database is only needed to load data into the system and not to create plots, additional users with only read access could be created, if needed.

**Example for configuring MySQL on a remote host with a user that has full access privileges.**

After installing MySQL, [initialize a data directory for AMET](https://dev.mysql.com/doc/refman/5.7/en/data-directory-initialization.html) and then [start the server](https://dev.mysql.com/doc/refman/5.7/en/starting-server.html), and [connect to the server](https://dev.mysql.com/doc/mysql-getting-started/en/#mysql-getting-started-connecting), per the MySQL instructions.

Once connected to the server, use the following commands to set up a single AMET user called
**ametsecure** with full access to the database. In this example replace, "some_pass" with a password of your choice.  You'll use this password in the AMET configuration script to provide access to the database.

```
mysql> create user 'ametsecure'@'localhost' identified by 'some_pass';
mysql> grant all privileges on \*.\* to 'ametsecure'@'localhost' with grant option;
mysql> \q
```

#### R
[***http://cran.us.r-project.org/index.html***](http://cran.us.r-project.org/index.html).

After you have installed the basic R software, AMET also requires the following additional R packages:

* RMySQL
* date
* maps
* mapdata
* stats
* plotrix
* Fields

The easiest way to install R packages, is through the R package manager.  Once R is installed, use the following commands to install these packages (note that the ">" denotes the Linux command prompt):

```
> sudo R
> install.packages(c("RMySQL", "date", "maps", "mapdata","stats","plotrix", "Fields"))
```

#### MADIS
[***https://madis.ncep.noaa.gov/madis_api.shtml***](https://madis.ncep.noaa.gov/madis_api.shtml)

Follow the installation instructions for the MADIS API. The AMET scripts will need to be configured to point to the compiled binaries for this utility.  

#### WGRIB
[**http://www.cpc.ncep.noaa.gov/products/wesley/wgrib.html**](http://www.cpc.ncep.noaa.gov/products/wesley/wgrib.html)

*Note:* The tarball from the above link does not contain its own directory, so we recommend that you create a **wgrib** directory before untarring.

### Install AMET Source Code and Tier 3 Software

The AMET Tier 3 software includes utilities for pairing model and observation data. Unlike the Tier 1 and Tier 2 software, the Tier 3 software is included in the AMET software distribution package. After either unzipping the AMET zip file from GitHub or using the git clone command provided above, the AMET source code and Tier 3 software will be installed on your Linux system.

The AMET top-level installation directory will include the following subdirectories (with brief descriptions):

* **bin** - 3rd party binaries used by the AMET scripts
* **configure** - configuration settings for the local AMET installation
* **model_data** - model output data for comparison with observations
* **obs** - ambient air quality and meteorology observations
* **output** - output of AMET scripts, including plots
* **R_analysis_code** - R scripts for all AMET analyses
* **R_db_code** - R scripts for loading data into the MySQL database
* **scripts_analysis** - AMET analysis scripts
* **scripts_db** - scripts for populating the AMET database
* **src** - source code for AMET Tier 3 software
* **web_interface** - templates for a PHP web interface to AMET

In the **src** directory there are three Fortran programs for pairing model and observed data. Before using the AMET database and analysis scripts, these programs must be compiled using Fortran Makefiles that are included in the source code directories. The executables for these programs must be available for the AMET database scripts (scripts_db), as they are used to pair the model and observations before the data are loaded into the AMET database.

* **bldoverlay** - creates a PAVE overlay file for creating observation overlay plots
* **sitecmp** - pairs hourly and daily observation and model data for many of the networks compatible with AMET
* **sitecmp_dailyo3** - calculates daily maximum 1-hour and 8-hour ozone pairs for analysis with AMET

For the AMET scripts, there is nothing further to do during
installation. Below are instructions to complete the
installation of Tier 3 software, and directions for linking the Tier 2
and Tier 3 executables into the AMET **bin** directory.

#### Meteorological model utility: mm5tonetcdf

*Notes:*

* If NetCDF was installed in a nonstandard directory (i.e., not under
 **/usr/local)**, see **$AMETBASE/src/mm5tonetcdf\_1.2/README** for
 instructions on how to set corresponding paths to the include files
 and libraries.
* The default install location of **mm5tonetcdf** in **/usr/local**
 can be changed by the same process as for NetCDF; see the above
 **README** file.
* Make sure that you compile **mm5tonetcdf** with the appropriate LFS
 (large file support) flags. The flags for the **gcc** compiler are:

 **-D\_FILE\_OFFSET\_BITS=64**

 **-D\_LARGEFILE64\_SOURCE**

#### Air quality model utilities

The following three AMET Tier 3 software components must be compiled before using the AMET database and analyis scripts. The source code and Fortran Makefiles for these programs are located in the AMET **src** directory.

* **bldoverlay**
* **sitecmp**
* **sitecmp_dailyo3**

To compile these programs, edit the **config.amet** file that is located in the **src** directory.  Point this script to the location of the local I/O API (IOAPI_DR) and netCDF (NETCDF_DIR) installation directories.  Use the following command to apply the settings in the config.amet script before running `make` to build the Tier 3 programs.

```
source config.amet
```

<a id=Install4></a>
## 4. Configure AMET

AMET uses a centralized R script to set up the AMET environment for loading data into the database and for producing plots.  The AMET configuration script is located in the `configure` directory under the base AMET installation area. The following environment variables in the **amet-config.R** script must be set before using any of the other AMET scripts.

* `amet_base` - base AMET installation directory path
* `EXEC_sitex_daily` - sitecmp_dailyo3 executable directory path
* `EXEC_sitex` - sitecmp executable directory path
* `obs_data_dir` - observational data directory path; typically $amet_base/obs
* `mysql_server` - IP Address or name of MySQL server used for AMET
* `root_login` - login ID to the AMET MySQL database server
* `root_pass`- password for the AMET MySQL database server
* `maxrec` - the maximum number of records allowed in a single MySQL query
* `Bldoverlay_exe` - bldoverlay executable directory path
* `R_dir` - main R installation directory path
* `R_exe` - R executable directory path
* `R_script` - Rscript executable directory path
* `R_lib` - R library directory path
* `R_proj_lib` - Proj.4 executable directory path

*Note: the root_login and root_pass settings in the amet-config.R script must be for a MySQL user that has read-write access to the database.*

Following from the example above, if you created a user called *ametsecure* with the password *some_pass*, set **root_login** and **root_pass** in amet-config.R to use these settings. Otherwise, set these variable to login and password that you selected when setting up MySQL.

Additional AMET configuration is handled in the database loading and plot creation scripts. See the AMET 1.3 User’s Guide on configuring AMET for additional details.

<a id=Install5></a>
## 5. Install Test Case Data

The final step in the installation process is to install the test case
data sets. These include sample model output data and observational
data.

### Install sample model output data

In this step, you will untar the previously downloaded model outputs
from Section 2 in the corresponding directories indicated below.

#### Meteorological output data
**WRF** (4.6 GB uncompressed, 2.4 GB compressed) - Untar the file **wrfExample.tar.gz** in the directory **$AMETBASE/model\_data/MET**. This tarball contains five days’ worth of **WRF** outputs in netCDF format. The temporal range is July 5 2002 0:00 UTC to July 8 2002 23:00 UTC with a spatial domain covering the continental U.S. at 36-km resolution. The spatial domain of the

 **MCIP** (455 MB uncompressed, 340 MB compressed) - Untar the file **mcipExample.tar.gz** in the directory **$AMETBASE/model\_data/MET.** This tarball contains five days’ worth of **MCIP** outputs in netCDF format. The temporal range is July 5 2002 0:00 UTC to July 9 2002 23:00 UTC with a spatial domain covering the continental U.S. at 36-km resolution. Additionally, there is a **GRIDCRO2D** file for July 6 that is also used by AMET.

After you untar the tarfiles above, the directory **$AMETBASE/model\_data/MET** will contain the following files.

```
Add file list
```

#### Air quality output data

 **CMAQ** (7.9 GB uncompressed; 6.3 GB compressed) - Untar the **aqExample.tar.gz** file in the directory **$AMETBASE/model\_data/AQ**. For CMAQ, we have provided an **ACONC** and a **WETDEP** output file from a CMAQ simulation to demonstrate new analysis capabilities involving the AERO6 suite of species. These two files are netCDF outputs from the **combine** postprocessing step. The  temporal range is from July 1 2011 00:00 UTC to July 31 2011 00:00 UTC  with a spatial domain covering the continental U.S at 12-km resolution. To demonstrate the analysis of statistical correlations of meteorological and air quality model data we have also provided a **CONC** and **WETDEP** output file from a 2002 CMAQ simulation with the temporal range from July 1 2002 00:00 UTC to July 11 2002 00:00 UTC and a spatial domain covering the continental U.S at 36-km resolution; these data were included in the previous AMET release.

After you untar the tarfiles above, the directory **$AMETBASE/model\_data/AQ/aqExample** will contain the following files.

```
-rw-r----- 1 user user 67800289168 Mar 15 11:34 CCTM_CMAQv52_Sep15_cb6_Hemi_New_LTGNO_combine.aconc.07
-rw-r----- 1 user user 46561648232 Mar 15 11:48 CCTM_CMAQv52_Sep15_cb6_Hemi_New_LTGNO_combine.dep.07

```

#### Observational data

 Change directory to **$AMETBASE/obs**, and untar the contents of the file **AMET\_obs\_data.tar.gz** that you downloaded in Section 1. This will populate the air quality observations as well as provide the necessary directory structure for storing meteorological data.

 **Meteorological observational data**: These data are not included as part of this distribution, because AMET dynamically downloads them as needed from the Meteorological Assimilation Data Ingest System (MADIS) web site to **$AMETBASE/obs/MET**. The contents of this directory should now look like the following:

 ```
 Add file list
 ```

If the directory where AMET is installed has limited space, we suggest that you move the entire directory structure under **$AMETBASE/obs/MET** (point and LDAD) to another directory with larger capacity, and then create symbolic links from the location that contains the AMET installation to the new location. For the model datasets we have provided, the MADIS observational data that will be dynamically downloaded is on the order of about `1.0 GB` uncompressed. AMET does allow the data to be stored in compressed format, which reduces the size to 109 MB, but the data need to b decompressed before they can be used in AMET.

**Air quality observational data** (32 KB uncompressed; 0.2KB compressed):  We provided data from several networks to use for testing the AMET installation:

*North America*
* Air Quality System (AQS) network
* Clean Air Status and Trends Network (CASTNET)
* Interagency Monitoring of Protected Visual Environments (IMPROVE)
* Chemical Speciation Network (CSN)
* Mercury Deposition Network (MDN)
* National Atmospheric Deposition Program (NADP) network
* SouthEastern Aerosol Research and Characterization Study (SEARCH)
* Ammonia Monitoring Network (AMON)
* Atmospheric Integrated Research Monitoring Network (AIRMON)
* National Air Pollution Surveillance Program (NAPS) (speciated measurements from Canada)
* Canadian Air and Precipitation Monitoring Network (CAPMON)

*Global/Europe*
* Aerosol Robotic Network (AERONET)
* Regional and global analysis of CO2, water vapor and energy (FLUXNET)
* TOXICS


A brief description of data from each of these networks is provided in the AMET User’s Guide included in this release. Refer to the respective web sites for additional information on these datasets, monitoring protocols, updates, etc. The observational datasets have been preprocessed and reformatted (in some instances from their original sources) for access by AMET. We have also provided the monitoring station locations in a set of .csv files in the subdirectory **$AMETBASE/obs/AQ/site\_lists**. The site lists are an important set of metadata files that allow AMET to match modeled and observed data at the available locations from each network, and is critical to the database loading.

 Please see the *Atmospheric Model Evaluation Tool (AMET) User’s Guide*  for instructions on how to
 load new data, configure and create plots.


----
<a id=InstallRef></a>
## References

Appel, K. Wyat, et al. "Overview of the atmospheric model evaluation tool (AMET) v1. 1 for evaluating meteorological and air quality models." Environmental Modelling & Software 26.4 (2011): 434-443.

Gilliam, R. C., W. Appel, and S. Phillips. [The Atmospheric Model
Evaluation (AMET): Meteorology
Module](http://cfpub.epa.gov/si/si_public_record_report.cfm?dirEntryId=139233&fed_org_id=770&SIType=PR&TIMSType=&showCriteria=0&address=nerl/pubs.html&view=citation&personID=48900&role=Author&sortBy=pubDateYear&count=100&dateBeginPublishedPresented=).
Presented at 4th Annual CMAS Models-3 Users Conference, Chapel Hill, NC,
September 26 - 28, 2005.
