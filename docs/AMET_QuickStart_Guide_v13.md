# Atmospheric Model Evaluation Tool (AMET) v1.3  
## Quick Start Guide
-----
This guide provides a quick start to getting AMET version 1.3 installed and running on a Linux system.
Additional details of the steps outlined here are available in the AMET [Installation Guide](https://github.com/USEPA/AMET/blob/1.3/docs/AMET_Install_Guide_v13.md) and [User's Guide](https://github.com/USEPA/AMET/blob/1.3/docs/AMET_Users_Guide_v1.md).

## 1.  Install AMET source code and scripts using Git

To clone the AMET installation directory to a Linux server, use the following command:

``git clone -b 1.3 https://github.com/USEPA/AMET.git AMET_v13``

## 2.  Download AMET Test Case Data

1) Download CMAQ test input data by navigating to https://www.cmascenter.org/ and logging into the site using the "Log In" shortcut on the top horizontal menu.

2) Click the Software pulldown menu on the horizontal menu bar and choose CMAQ.

3) Click DOWNLOAD on the right-hand side of the page and choose CMAQv5.2, platform, and compiler for your machine and click submit.

4) Click "Download Datasets" for the CMAQ benchmark input data and CMAQ benchmark output data.


## 3. Check/Install Related Software

The AMET distribution package consists primarily of Linux c-shell and R scripts. To work as expected for creating model performance evaluation products, the AMET scripts require a series of 3rd-party software packages to be installed on the AMET host Linux system.

Many of these 3rd-party packages are available through standard Linux package management systems, such as yum (RHEL-based) and apt (Debian-based). Users are encouraged to install as much of the 3rd-party AMET software as possible through these package management systems.

### AMET Tier 1 Software

Tier 1 software are used by the AMET Tier 2 and Tier 3 components and must be present on a Linux system to run AMET. Confirm that all of the Tier 1 software are installed on your system before proceeding with the AMET installation. Refer to the documentation for each package for instructions on how to download and install the software.

The versions of these packages that were used by the CMAS Center in their installation and testing are included in parentheses:

* **gzip** (1.3.9)
* **gfortran** (4.1.2) or other F90 compiler
* **ImageMagick** (6.2.4.5); *Note*: You need only the **convert** utility from this package.

### AMET Tier 2 Software

Tier 2 software includes scientific software utilities for accessing and storing data, calculating statistics, and creating graphics. Web links are provided here to the download the software. Refer to the documentation provided by the software distributors for installation instructions.

* **[Network Common Data Form (netCDF)](http://www.unidata.ucar.edu/downloads/netcdf/index.jsp)**
* **[Input/Output Applications Programming Interface (I/O API)](http://www.cmascenter.org/ioapi)**
* **[MySQL](http://dev.mysql.com/downloads)**
* **[R](http://cran.us.r-project.org/index.html)**
* **[WGRIB](http://www.cpc.ncep.noaa.gov/products/wesley/wgrib.html)**

After installing MySQL, [initialize a data directory for AMET](https://dev.mysql.com/doc/refman/5.7/en/data-directory-initialization.html) and then [start the server](https://dev.mysql.com/doc/refman/5.7/en/starting-server.html), and [connect to the server](https://dev.mysql.com/doc/mysql-getting-started/en/#mysql-getting-started-connecting), per the MySQL instructions.

Once connected to the server, use the following commands to set up a single AMET user called
**ametsecure** with full access to the database. In this example replace, "some_pass" with a password of your choice.  You'll use this password in the AMET configuration script to provide access to the database.

```
mysql> create user 'ametsecure'@'localhost' identified by 'some_pass';
mysql> grant all privileges on \*.\* to 'ametsecure'@'localhost' with grant option;
mysql> \q
```

AMET also requires the following additional R packages:

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

### Install AMET Source Code and Tier 3 Software

In the AMET **src** directory there are three Fortran programs for pairing model and observed data. Before using the AMET database and analysis scripts, these programs must be compiled using Fortran Makefiles that are included in the source code directories.

* **bldoverlay** - creates a PAVE overlay file for creating observation overlay plots
* **sitecmp** - pairs hourly and daily observation and model data for many of the networks compatible with AMET
* **sitecmp_dailyo3** - calculates daily maximum 1-hour and 8-hour ozone pairs for analysis with AMET

To compile these programs, edit the **config.amet** file that is located in the **src** directory.  Point this script to the location of the local I/O API (IOAPI_DR) and netCDF (NETCDF_DIR) installation directories.  Use the following command to apply the settings in the config.amet script before running `make` to build the Tier 3 programs.

```
cd $AMETBASE/src
source config.amet
cd bldoverlay; make
cd ../sitecmp; make
cd ../sitecmp_dailyo3; make
```

*Note: AMETBASE is the root AMET installation directory on your system*

<a id=Install4></a>
## 4. Configure AMET

AMET uses a centralized R script to set up the AMET environment for loading data into the database and for producing plots.  The AMET configuration script is located in the `configure` directory under the base AMET installation area. The following environment variables in the **amet-config.R** script must be set before using any of the other AMET scripts.

* `amet_base` - base AMET installation directory path
* `EXEC_sitex_daily` - sitecmp_dailyo3 executable directory path
* `EXEC_sitex` - sitecmp executable directory path
* `mysql_server` - IP Address or name of MySQL server used for AMET
* `amet_login` - login ID to the AMET MySQL database server
* `amet_pass`- password for the AMET MySQL database server
* `maxrec` - the maximum number of records allowed in a single MySQL query
* `Bldoverlay_exe` - bldoverlay executable directory path

*Note: the amet_login and amet_pass settings in the amet-config.R script must be for a MySQL user that has read-write access to the database.*

## 5. Database Setup

Go to the AMET database setup directory

```
cd $AMETBASE/scripts_db/dbSetup
```
Change the setting of AMETBASE in create_amet_user.csh and run the script:

```
./create_amet_user.csh
```

## 6. Create AQ and MET projects

```
cd $AMETBASE/scripts_db/metExample
```
Change the setting of AMETBASE in matching_surface.csh and run the script:

```
./matching_surface.csh >& log.populate
```
```
cd $AMETBASE/scripts_db/aqExample
```
Change the setting of AMETBASE in aqProject.csh and run the script:

```
./aqProject.csh >& log.populate
```

## Run Example AQ and MET analyses
Use the following command to navigate to the met analysis example project directory:

```
cd $AMETBASE/scripts_analysis/metExample
```
Change the setting of AMETBASE in run_spatial_surface.csh, save and run the script:

```
./run_spatial_surface.csh |& tee spatial_surface.log
```

Go to the output directory to view the plots:

```
cd $AMETBASE/output/metExample/spatial_surface
```

Use the following command to navigate to the air quality analysis example project directory:

```
cd $AMETBASE/scripts_analysis/aqExample
```
Edit the AMETBASE and AMET_DATABASE variables to be consistent with the AMET installation on your system. Save and run the script:

```
./run_scatterplot.csh |& tee scatterplot.log
```

Go to the output directory and view the
plots:

```
cd $AMETBASE/output/aqExample/scatterplot
```
