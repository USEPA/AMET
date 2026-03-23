# Atmospheric Model Evaluation Tool (AMET) v1.6  
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

*Note that in AMETv1.3, **perl** was deprecated and is no longer used.*

This installation guide describes the steps
involved in the AMET software installation process. This guide describes how to (1) download the AMET scripts and test data, (2) install the AMET source code and scripts, (3) configure AMET, and  (4) install pre-packaged data for testing the AMET installation. Notes are
provided wherever appropriate pertaining to the installation on a Linux server.

Refer to the AMET User Guide for instructions on adding new data to the system, and configuring/creating plots.

<a id=Install2></a>
## 2.  Download AMET Software and Test Case Data

Download the AMET software from GitHub and test case data from
the CMAS Center [http://www.cmascenter.org](http://www.cmascenter.org/) as follows:

#### Download AMET source code and scripts

Go to http://github.com/USEPA/AMET

To download a zip archive of the software, click the "Clone or Download" button and select "Download ZIP".

To clone the AMET installation directory to a Linux server, use the following command:

``git clone -b 1.6 https://github.com/USEPA/AMET.git AMET_v16``

Note that this command assumes that git is installed on the Linux system.

#### Download AMET test data

* Go to http://www.cmascenter.org and log in using your existing CMAS account. If you do not already have an account, you will need to create one.
* Navigate to the CMAS Software Clearinghouse by selected Download -> Software from the drop-down menu at the top of the CMAS Center home page.
* Use the Select Software to Download box, select AMET, and click on the “**Submit”** button.
* Choose “AMET 1.6” as the product, “Linux PC” as the operating system, and “GNU compilers” as the choice of compiler, and then click on the “**Submit”** button.
* The following items are available for download:
 * a link to the AMET 1.6 Installation Guide (this document)
 * a link to the AMET 1.6 User’s Guide
 * a link to the AMET 1.6 Quick Start Guide
 * Download the CMAQ model test data and air quality observation from the Google Drive. Note, the example CMAQ output files contain all of the species needed by AMET-AQ, but are a subset of the full CMAQ output files. The files contain hourly data for the entire month of July 2017. They contain only the species that AMET needs, and only layer one.
 * Download the WRF and MPAS model test data and meteorology observations from the Google drive. There are 31 files for each set of data, one for each day in July 2018. The example meteorology output files from WRF and MPAS contain all of the species needed by AMET-MET, but are a subset of the full WRF or MPAS output files.


<a id=Install3></a>
## 3. Install AMET and Related Software

The AMET distribution package consists primarily of Linux c-shell and R scripts. To work as expected for creating model performance evaluation products, the AMET scripts require a series of 3rd-party software packages to be installed on the AMET host Linux system.

Many of these 3rd-party packages are available through standard Linux package management systems, such as yum (RHEL-based) and apt (Debian-based). Users are encouraged to install as much of the 3rd-party AMET software as possible through these package management systems.

### AMET Tier 1 Software

Tier 1 software are used by the AMET Tier 2 and Tier 3 components and must be present on a Linux system to run AMET. Confirm that all of the Tier 1 software are installed on your system before proceeding with the AMET installation. Refer to the documentation for each package for instructions on how to download and install the software.

The versions of these packages that were used by the CMAS Center in their installation and testing are included in parentheses:

* **gzip** (1.3.9)

* **gfortran** (4.1.2) or other F90 compiler

* **ImageMagick** (6.2.4.5); *Note*: You need only the **convert** utility from this package.

### AMET Tier 2 Software

Tier 2 software includes scientific software utilities for accessing and storing data, calculating statistics, and creating graphics. Web links are provided here to the download the software. Refer to the documentation provided by the software distributors for installation instructions. Notes specific to the installation of these packages for use with AMET are provided here.

#### [Network Common Data Form (netCDF)](http://www.unidata.ucar.edu/downloads/netcdf/index.jsp)

*Notes*:
* Installation needs to include a static library and include files.
* You will need the **ncdump** utility.
* By default, netCDF is installed in **/usr/local**. To install it in a different directory, see the installation notes.
* When using the **gcc** compilers, make sure **g++** is set up to use **gcc,** as the **c++** compiler will not work correctly.
* For netCDF versions later than 4.1, the C and Fortran versions of the library are distributed and built separately.

#### [Input/Output Applications Programming Interface (I/O API)](http://www.cmascenter.org/ioapi)

 *Notes*:
 * If I/O API and netCDF are already installed on your system, use those packages for AMET.
 * Build the nocpl version of the I/O API for the data formats used with AMET.

#### [MySQL/MariaDB](http://dev.mysql.com/downloads)

*Notes*:
* Install both the MySQL/MariaDB server and client. At a minimum, the MySQL/MariaDB client must be on the same machine that will host the AMET scripts. The MySQL/MariaDB server can either be installed on the AMET host or an a remote host.
* MySQL/MariaDB development files (include files and libraries), such as **mysql.h** and **libmysqlclient.so**, are needed on the system that will run AMET.
* If MySQL/MariaDB server is installed on a remote host, the server permissions will need to be granted to support accessing the database from the AMET local host.
* There are different ways to configure MySQL for use with AMET. In the example below, a single database user, **ametsecure**, is created with root access to the database. This user is given full privileges to read-write to the database. This user would then be able to load data into the database and create plots. As write access to the database is only needed to load data into the system and not to create plots, additional users with only read access could be created, if needed.

### Installation of MariaDB from tarball

-	**Download the most recent MariaDB binary distribution from this URL to any directory as non-root user

    - https://mariadb.org/download/

    - ** Select latest stable version, example MariaDB Server 11.4.5
-	**[Follow these instructions to install as non-root user to any directory](https://mariadb.com/kb/en/installing-mariadb-binary-tarballs/#installing-mariadb-as-not-root-in-any-directory)
    -  ** edit the ~/.my.cnf file to specify the basedir and  to your install directory

Example: (note the mysql directory was linked to the mariadb-VERSION-OS directory name that was obtained when following the above instructions.
edit /path-to/ to specify the path to your install directory.

cat ~/.my.cnf

```
[mysqld]
[server]
basedir=/path-to/mysql
datadir=/path-to/mysql/data
socket=/path-to/mysql/mysql.sock
port=3307
lc_messages_dir=/path-to/mysql/share/english
lc_messages = en_US
[client]
socket=/path-to/mysql/mysql.sock
port=3307
```

Note, if you are using a server, you will want to run the mysql database and client on a compute node, rather than a login node.
Request an interactive queue for 2 hours, and then do the following steps:

    **Run the mysql_install_db script to instantiate a directory to hold the MariaDB database files**

    `./scripts/mariadb-install-db --defaults-file=~/.my.cnf`

    
-	**Start MariaDB**

    `/proj/ie/proj/CMAS/AMET/MariaDB/mysql/bin/mariadbd-safe --defaults-file=~/.my.cnf --datadir='/proj/ie/proj/CMAS/AMET/MariaDB/mysql/data'` 

-	**Use the mariadbd command to connect to the server**

    ` /path-to/mysql/bin/mariadbd --defaults-file=~/.my.cnf `


-        ** Use mysql command to login to the database **
  

      mysql -u $USER 


-     ** Create AMET user     **
       CREATE USER 'ametsecure'@localhost IDENTIFIED BY 'some password';

    
-	**Grant that user access **

-        ** Use mysql command to login to the database **


      mysql -u $USER 


-     ** Create AMET user     **
       CREATE USER 'ametsecure'@localhost IDENTIFIED BY 'some password';


-	**Grant that user access **

    `grant all privileges on *.* to 'ametsecure'@'localhost' with grant option;`

Output:

Query OK, 0 rows affected (0.002 sec)


Verify that the user has been created

      `SELECT user FROM mysql.user;`

-	**Once done, you can shutdown the running database safely by running**

    `/path-to/mysql/bin/mariadb-admin shutdown`

The instructions above create an AMET superuser of sorts, in that the ametsecure user has been granted all priviledges. AMET only requires database users to have SELECT, INSERT, UPDATE, DELETE, ALTER, and DROP ON priviledges to function fully. So, additional AMET users could be created with just those select priviledges. More information on how to create and configure MySQL/MariaDB users can be found on the MySQL/MariaDB websites.

#### [R](http://cran.us.r-project.org/index.html)

After you have installed the basic R software, AMET also requires the following additional R packages:

* akima
* data.table
* date
* dplyr
* dygraphs
* fields
* ggplot2
* grid
* gridExtra
* hexbin
* htmltools
* htmlwidgets
* lattice
* latticeExtra
* leaflet (optional for some analysis scripts)
* leaflet.extras (optional for some analysis scripts)
* leafpop
* lubridate
* maps
* mapdata
* prism
* plotly
* plotrix
* processx
* reshape2
* RColorBrewer
* RMySQL

* RMariaDB (preferred over RMySQL, which is being phased out in R)
* stats
* webshot
* xts
* pandoc

The easiest way to install R packages, is through the R package manager.  Once R is installed, use the following commands to install these packages (note that the ">" denotes the Linux command prompt):

```
> sudo R

> install.packages(c("akima","data.table","date","dplyr","dygraphs","fields","ggplot2","grid","gridExtra","hexbin","htmltools","htmlwidgets","lattice","latticeExtra","leaflet","leaflet.extras","leafpop","lubridate","maps","mapdata","prism","plotly","plotrix","processx","reshape2","RColorBrewer","RMySQL","RMariaDB","stats","webshot","xts","pandoc"),repos="http://cran.r-project.org")

```

If you do not have root access or are runnning on a shared system, you can load the packages as follows:

Create a directory for your R packages

` mkdir ~/Rlibs`

Load the R modulefile

`module load r`

Load the gcc compiler

`module load gcc`

Set the R library environment variable (R_LIBS) to include your R package directory

`setenv R_LIBS ~/Rlibs`

Use the install.packages function to install your packages

`Rscript -e "install.packages('RMySQL', '~/Rlibs', 'http://ftp.ussg.iu.edu/CRAN')"`

Note, you can likely use a cran location nearest to you. (is there a place to search for cran sites nearest a location?)

The R_LIBS environment variable will need to be set every time when logging in to the Campus Cluster if the user’s R package location is to be visible to an R session. The following:

```
if (! $?R_LIBS) then
  setenv R_LIBS  ~/Rlibs
  else
  echo "R_LIBS variable contains $R_LIBS, please verify this is correct"
endif
```

Install additional packages using the same method.

`Rscript -e "install.packages('date', '~/Rlibs', 'http://ftp.ussg.iu.edu/CRAN')"`

`Rscript -e "install.packages('maps', '~/Rlibs', 'http://ftp.ussg.iu.edu/CRAN')"`

`Rscript -e "install.packages('mapdata', '~/Rlibs', 'http://ftp.ussg.iu.edu/CRAN')"`

`Rscript -e "install.packages('stats', '~/Rlibs', 'http://ftp.ussg.iu.edu/CRAN')"`

Received the following warning
Warning message:
package ‘stats’ is a base package, and should not be updated 
(likely need to take this out)

`Rscript -e "install.packages('plotrix', '~/Rlibs', 'http://ftp.ussg.iu.edu/CRAN')"`

`Rscript -e "install.packages('fields', '~/Rlibs', 'http://ftp.ussg.iu.edu/CRAN')"`

`Rscript -e "install.packages('akima', '~/Rlibs', 'http://ftp.ussg.iu.edu/CRAN')"`

`Rscript -e "install.packages('leaflet', '~/Rlibs', 'http://ftp.ussg.iu.edu/CRAN')"`

`Rscript -e "install.packages('prism', '~/Rlibs', 'http://ftp.ussg.iu.edu/CRAN')"`

`Rscript -e "install.packages('rgdal', '~/Rlibs', 'http://ftp.ussg.iu.edu/CRAN')"`

`Rscript -e "install.packages('dygraphs', '~/Rlibs', 'http://ftp.ussg.iu.edu/CRAN')"`


Additional instructions for [installing R packages on a campus cluster](https://campuscluster.illinois.edu/resources/docs/user-guide/r/)

Install Wgrib
[Follow these instructions to install wgrib](https://rda.ucar.edu/datasets/ds083.2/software/wgrib_install_guide.txt)
#### [WGRIB](http://www.cpc.ncep.noaa.gov/products/wesley/wgrib.html)

*Note:* The tarball from the above link does not contain its own directory, so we recommend that you create a **wgrib** directory before untarring.

`mkdir /to_path/WGRIB`

Download the wgrib.tar file

`wget ftp://ftp.cpc.ncep.noaa.gov/wd51we/wgrib/wgrib.tar`

Untar

`tar -cvf wgrib.tar`

Then make sure the gcc compiler is loaded

`module load gcc`

Then run make

`make`

You will have a wget executable

Add the path to this directory to your .csrhc

Example:

set path = ( $path /to_path/WGRIB )


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
* **tools_src** - source code for AMET Tier 3 software
* **AMETJavaGUI** - templates for a Java web interface to AMET
* **docs** - AMET User Guide and Install Guide

In the **tools_src** directory there are four Fortran programs for extracting and pairing model and observed data. Before using the AMET database and analysis scripts, these programs must be compiled using Fortran Makefiles that are included in the source code directories. The executables for these programs must be available for the AMET database scripts (scripts_db), as they are used to pair the model and observations before the data are loaded into the AMET database.

* **combine** - combine utility relies on a mechanism-specific "Species Definition" file that prescribes how model output variables should be combined to become comparable to different measured or observed gas, particle and deposition species.
* **bldoverlay** - creates a PAVE overlay file for creating observation overlay plots
* **sitecmp** - pairs hourly and daily observation and model data for many of the networks compatible with AMET
* **sitecmp_dailyo3** - calculates daily maximum 1-hour and 8-hour ozone pairs for analysis with AMET

To compile these programs, edit the makefile file that is located in each tool **tools_src** directory.  Specify the compiler and the location of the local I/O API and netCDF installation directories.  Use the following commands to apply the settings in the config.amet script before running `make` to build the Tier 3 programs.

```
> cd $AMETBASE/tools_src
cd combine/src
edit the combine Makefile
> make |& tee make.log
> cd bldoverlay/src
edit the bldoverlay Makefile
> make |& tee make.log
> cd ../sitecmp/scr
edit the sitecmp Makefile
> make |& make.log
> cd ../sitecmp_dailyo3/scr
edit the sitecmp_dailyo3 Makefile
> make |& tee make.log
```

Note, the combine script directory contains a script called linkem that needs to be edited to point to your CMAQ REPO directory to obtain the species definition files.

```
cd $AMETBASE/tools_src/combine/scripts/spec_def_files
vi linkem.csh
```

Modify the set src = line to point to the CMAQv6.0 Repository.

```
set src = /path_to/CMAQ/CMAQv6.0/build/CMAQ_REPO_v6.0/CCTM/src/MECHS

modify to the path for your CMAQ installation directory

set src = /path_to/CMAQ_REPO/CCTM/src/MECHS
```

Then run the linkem.csh script to create links to the species definition files.

```
./linkem.csh
```

Verify that the links are all valid, and point to the correct files.


<a id=Install4></a>
## 4. Configure AMET

AMET uses a centralized R script to set up the AMET environment for loading data into the database and for producing plots.  The AMET configuration script is located in the `configure` directory under the base AMET installation area. The following environment variables in the **amet-config.R** script must be set before using any of the other AMET scripts.

* `amet_base` - base AMET installation directory path
* `EXEC_sitex_daily_config` - sitecmp_dailyo3 executable directory path
* `EXEC_sitex_config` - sitecmp executable directory path
* `mysql_server` - IP Address or name of MySQL/MariaDB server used for AMET
* `amet_login` - login ID to the AMET MySQL/MariaDB database server
* `amet_pass`- password for the AMET MySQL/MariaDB database server
* `maxrec` - the maximum number of records allowed in a single MySQL query (optional)
* `Bldoverlay_exe_config` - bldoverlay executable directory path

*Note: the amet_login and amet_pass settings in the amet-config.R script must be for a MySQL/MariaDB user that has read-write access to the database.*

Following from the example above, if you created a user called *ametsecure* with the password *some_pass*, set **amet_login** and **amet_pass** in amet-config.R to use these settings. Otherwise, set these variable to login and password that you selected when setting up MySQL/MariaDB.

Additional AMET configuration is handled in the database loading and plot creation scripts. See the AMET 1.6 User’s Guide on configuring AMET for additional details.

<a id=Install5></a>
## 5. Install Test Case Data

The final step in the installation process is to install the test case data sets. These include sample model output data and observational
data.

### Install sample data

In this step, you will review the previously downloaded model outputs and observational data downloaded from Section 2 in the corresponding directories indicated below.

#### Meteorological data
(25 GB uncompressed, 16 GB compressed)

The $AMETBASE/MET/metExample_wrf contains 31 days’ worth of **WRF**, $AMETBASE/MET/metExample_mcip contains 31 days worth of **MCIP**, and the $AMETBASE/MET/metExample_mpas contians **MPAS** outputs in netCDF format, hourly point METAR data from MADIS, and example AMET analysis plots. The temporal range is July 1 2016 0:00 UTC to July 31 2016 23:00 UTC for WRF and July 1 2016 0:00 UTC to July 31 2016 23:00 UTC for MPAS. The spatial domain covers the continental U.S. at 12-km resolution.

The directory **$AMETBASE/model\_data/MET/metExample_wrf** will contain the following files.

```
wrfout_subset_2016-07-01_00:00:00
wrfout_subset_2016-07-02_00:00:00
wrfout_subset_2016-07-03_00:00:00
wrfout_subset_2016-07-04_00:00:00
wrfout_subset_2016-07-05_00:00:00
wrfout_subset_2016-07-06_00:00:00
wrfout_subset_2016-07-07_00:00:00
wrfout_subset_2016-07-08_00:00:00
wrfout_subset_2016-07-09_00:00:00
wrfout_subset_2016-07-10_00:00:00
wrfout_subset_2016-07-11_00:00:00
wrfout_subset_2016-07-12_00:00:00
..
..
wrfout_subset_2016-07-31_00:00:00

```

The directory **$AMETBASE/model\_data/MET/metExample_mcip** will contain the following files.

```
list of files

```

The $AMETBASE/MET/metExample_mpas directory contains the following files.

```
history.subset.2016-07-01.nc
..
..
history.subset.2016-07-27.nc
history.subset.2016-07-28.nc
history.subset.2016-07-29.nc
history.subset.2016-07-30.nc
history.subset.2016-07-31.nc
```

Meteorology observational data are installed under **$AMETBASE/obs/MET**.

#### Air quality data
(35 GB uncompressed; 30 GB compressed)

Download the Air Quality Data from the Google Drive > CMAS Data Warehouse > AMET > v1.6_example. For CMAQ, we have provided an **ACONC** and a **WETDEP** output file from a CMAQ simulation to demonstrate analysis capabilities involving the AERO6 suite of species. The model output files are netCDF outputs from the **combine** postprocessing step. The  temporal range is from July 1 2018 00:00 UTC to July 31 2018 00:00 UTC  with a spatial domain covering the continental U.S at 12-km resolution. This archive also contains surface air quality observations for 2018 and sample AMET analysis plots.

After you download the files, the directory **$AMETBASE/model\_data/AQ/aqExample** will contain the following files.

`ls -lht`

```
 51G Nov 20  2018 COMBINE_ACONC_aqExample_201807.nc
 40G Nov 20  2018 COMBINE_DEP_aqExample_201807.nc

```
Download the Air Quality Observational data from the Google Drive CMAS Data Warehouse > AMET > v1.6_example > 2000_2024_NAmerican_AQ_Obs_Data
for 2018, download the AMET_obsdata_2018.tar.gz file and extract to the $AMETBASE/obs/AQ/All_Years directory.

Air quality observational data for the following networks are available in **$AMETBASE/obs/AQ/All_Years :

*North America*
* Air Quality System (AQS) network
* Aerosol Robotic Network (AERONET)
* Ambient Monitoring Archive for HAPs (AMTIC)
* Ammonia Monitoring Network (AMON)
* Clean Air Status and Trends Network (CASTNET)
* Interagency Monitoring of Protected Visual Environments (IMPROVE)
* Chemical Speciation Network (CSN)
* National Air Pollution Surveillance (NAPS) program
* National Atmospheric Deposition Program National Trends Network (NADP-NTN)
* SouthEastern Aerosol Research and Characterization Study (SEARCH)

*Global/Europe*
* Aerosol Robotic Network (AERONET)
* Regional and global analysis of CO2, water vapor and energy (FLUXNET)
* Tropospheric Ozone Assessment Report (TOAR)
* Tropospheric Ozone Assessment Report 2 (TOAR2)

A brief description of data from each of these networks is provided in the AMET User’s Guide included in this release. Refer to the respective web sites for additional information on these datasets, monitoring protocols, updates, etc. The observational datasets have been preprocessed and reformatted (in some instances from their original sources) for access by AMET. We have also provided the monitoring station locations in a set of .csv files in the subdirectory **$AMETBASE/obs/AQ/site\_files**. The site lists are an important set of metadata files that allow AMET to match modeled and observed data at the available locations from each network, and is critical to the database loading.

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
