***Atmospheric Model Evaluation Tool (AMET) v1.3 
Installation Guide***

Initially Prepared under Work Assignment 3-01 of U.S. EPA Contract EP-W-09-023,
“Operation of the Center for Community Air Quality Modeling and Analysis
(CMAS)”; Updated by US EPA for significant changes made in AMET v1.3

Prepared for: Bill Benjey

U.S. EPA, ORD/NERL/AMD/APMB

E243-04

USEPA Mailroom

Research Triangle Park, NC 27711

Prepared by: Zac Adelman, Uma Shankar, Wyat Appel and Robert Gilliam

US EPA and the Institute for the Environment

The University of North Carolina at Chapel Hill

137 E. Franklin St., CB 6116

Chapel Hill, NC 27599-6116

Date Updated: July 3, 2017

**Contents**

1. Introduction 1

2. Download AMET Software and Test Case Data 1

3. Verify the Availability of Tier 1 Software 2

4. Install Tier 2 Software 3

4.1 Input/Output Applications Programming Interface (I/O API) (3.0) 3

4.2 MySQL (5.0.38) 4

4.3 R (2.14.0) 6

5. Install AMET Source Code and Tier 3 Software 7

5.1 Meteorological model utility 8

5.2 Air quality model utilities 8

5.3 Binary linking 9

5.4 Configure AMETBASE variable 9

5.5 Modify header for perl scripts 9

6. Install Test Case Data 9

6.1 Sample model output data 9

6.2 Observational data 11

Reference 14

1.  

2.  Introduction
    ============

The Atmospheric Model Evaluation Tool (AMET) (Gilliam et al., 2005) is a
suite of software designed to facilitate the analysis and evaluation of
meteorological and air quality models. AMET matches the model output for
particular locations to the corresponding observed values from one or
more networks of monitors. These pairings of values (model and
observation) are then used to statistically and graphically analyze the
model’s performance.

More specifically, AMET is currently designed to analyze outputs from
the PSU/NCAR Mesoscale Model (MM5), the Weather Research and Forecasting
(WRF) model, and the Community Multiscale Air Quality (CMAQ) model, as
well as Meteorology-Chemistry Interface Processor (MCIP)-postprocessed
meteorological data (surface only). The basic structure of AMET consists
of two *fields* and two *processes*.

-   The two fields (scientific topics) are **MET** and **AQ**,
    corresponding to meteorology and air quality data.

-   The two processes (actions) are **database population** and
    **analysis**. Database population refers to the underlying structure
    of AMET; after the observations and model data are paired in space
    and time, the pairs are inserted into a database (MySQL). Analysis
    refers to the statistical evaluation of these pairings and their
    subsequent plotting.

Practically, a user may be interested in using only one of the fields
(either MET or AQ), or may be interested in using both fields. That
decision is based on the scope of the study. The three main software
components of AMET are **MySQL** (an open-source database software
system), **R** (a free software environment for statistical computing
and graphics), and **perl** (an open-sourcecross-platform programming
language).

The Community Modeling and Analysis System (CMAS) Center obtained the
MET and AQ portions of AMET separately from EPA, then integrated the two
to create a consistent and integrated AMET package that uses the UNIX
C-shell interface to perform both MET and AQ model evaluation and
analyses. After this integration, we tested the integrated AMET package
in multiple environments.

Finally, we created this installation guide, which describes the steps
involved in the AMET software installation procedure. During this
process you will install (1) the AMET source code and scripts, (2) three
tiers of related software, and (3) test case model data. Notes are
provided wherever appropriate pertaining to the installation on a clean
Ubuntu 10.04 Linux server, based on CMAS Center’s experience with the
installation and testing of the AMET 1.1 version. The most important
thing about getting AMET to work in a new installation is to maintain
consistency with the version numbers of the Tier 2 software and
libraries listed in this installation guide.

Download AMET Software and Test Case Data
=========================================

> You can download the AMET software and some of the test case data from
> the web site of the
>
> CMAS Center, [**http://www.cmascenter.org**,
> ](http://www.cmascenter.org/)as follows:
>
> 1. In the “**Download Center**” panel on the left-hand side of the web
> site, click on “MODELS”.
>
> 2. Log in using your existing CMAS account. If you do not already have
> an account, you will need to create one.
>
> 3. AMET download Step 1: Select a model family to download by choosing
> “AMET” from the pull-down list, and click on the “**Submit”** button.
>
> 4. AMET download Step 2: Choose “AMET 1.2” as the product, “Linux PC”
> as the operating system, and “GNU compilers” as the choice of
> compiler, and then click on the “**Submit”** button.
>
> 5. In the table that appears, follow the links to:
>
> a) the installation guide (this document);
>
> b) the AMET 1.2 User’s Guide;
>
> c) a tarball that includes the AMET source and scripts, and Tier 3
> software (**AMET\_v1.2.tar.gz**);
>
> d) a tarball that contains CMAQ model data (**aqExample.tar.gz**);
>
> e) a tarball that contains MM5 model data (**mm5Example.tar.gz**), and
>
> f) a tarball that contains WRF model data (**wrfExample.tar.gz**).

Download all of these files to a temporary directory.

The rest of the sections in this guide explain the remaining steps in
the installation process, as follows:

-   Section 3: Verifying the availability of Tier 1 software, or having
    > it installed if necessary.

-   Section 4: Installing Tier 2 software utilities that need to be
    > downloaded from other web sites.

-   Section 5: Installing the AMET and Tier 3 software (from the
    > **AMET\_v1.2.tar.gz** tarball). Tier 3 software is a set of custom
    > software utilities that have been developed alongside AMET.

-   Section 6: Installing test case datasets for both observational and
    model data.

Verify the Availability of Tier 1 Software
==========================================

Tier 1 software includes utilities that are normally part of a
“standard” installation of the UNIX/Linux operating system. Please check
to make sure all of the utilities below are available to you. If some of
them are not present, you should ask your system administrator to
install them.

The versions used by CMAS staff in their integration and testing are
included in parentheses:

1.  **zlib (libz.a)** (1.2.3)

2.  **libg2c.a** (3.4.6)

3.  **gzip** (1.3.9)

4.  **g++** (4.1.2)

5.  **gfortran** (4.1.2) or other F90 compiler

6.  **ImageMagick** (6.2.4.5)

> *Note*: You need only the **convert** utility from this package.

1.  **sed** (4.1.5)

> *Note*: **sed** is only needed for subs automatic renaming scripts.

Install Tier 2 Software
=======================

> Tier 2 includes scientific software utilities that you need to
> download and install from other web sites. Given below are web links
> to the software and installation documentation provided by the
> software distributors, along with basic notes discussing what we have
> found beneficial in our testing. Many of these utilities are available
> through standard Linux package management systems; you and/or your
> system administrator are encouraged to install them through these
> package management systems.

Input/Output Applications Programming Interface (I/O API) (3.0)
---------------------------------------------------------------

> Download from
> [**http://www.baronams.com/products/ioapi**](http://www.baronams.com/products/ioapi)
>
> Installation instructions:
> [***http://www.baronams.com/products/ioapi/AVAIL.html***](http://www.baronams.com/products/ioapi/AVAIL.html)
>
> *Note*: If I/O API and netCDF are already installed on your system, we
> recommend using those packages for AMET. Otherwise, we recommend
> compiling both with the same compilers and flags.

MySQL (5.0.38)
--------------

> Download from
> [**http://dev.mysql.com/downloads**](http://dev.mysql.com/downloads)
>
> Installation instructions: [***http://dev.mysql.com/doc/*
> **](http://dev.mysql.com/doc/)
>
> *Notes*:
>
> • Install MySQL server and client. This can be installed on the
> machine that will run AMET, as well as on a remote host.
>
> • You will also need development files (include files and libraries)
> such as **mysql.h** and **libmysqlclient.so.15** on the system that
> will run AMET.
>
> • If MySQL server is installed on a remote host, you will encounter
> permissions issues in accessing the database from AMET. In that event,
> we recommend that you run the following commands on the MySQL server
> via the MySQL client to provide mysql root access from outside the
> local host:
>
> **mysql&gt; grant reload, process on \*.\* to 'root'@'hostname';**
>
> **mysql&gt; grant all privileges on \*.\* to 'root'@'hostname'
> identified by 'rootpass' with grant option;**
>
> *Notes:* On Ubuntu we recommend installing MySQL from apt-get:
>
> **sudo apt-get install mysql-client-5.1 mysql-server-5.1
> python-mysqldb**
>
> Once you have MySQL and the accompanying libraries installed you need
> to start the server and create the **ametsecure** user/password. Start
> the server as follows:
>
> **mysqld\_safe & **
>
> Log into the MySQL server and create the user **ametsecure**; assign a
> password to **ametsecure** and give the user full privileges to the
> database as follows:
>
> **mysql**
>
> On the server prompt:
>
> **mysql&gt; create user 'ametsecure'@'localhost' identified by
> 'some\_pass';**
>
> **mysql&gt; grant all privileges on \*.\* to 'ametsecure'@'localhost'
> with grant option;**
>
> **mysql&gt; \\q**
>
> After you create this user, edit the **amet-config.pl** and
> **amet-conf.R** scripts under **$AMETBASE/configure** and add the
> password you created. You will need to set **$root\_pass** in the
> \*.pl script and **passwd** in the \*.R script to the **ametsecure**
> password that you have created. See the AMET 1.2 User’s Guide for
> additional details.

R (2.14.0)
----------

> Download and installation instructions:
> [***http://cran.us.r-project.org/index.html***](http://cran.us.r-project.org/index.html).
> After you have installed the basic R software, AMET also requires the
> following additional R packages:
>
> Download and installation instructions:
>
> [**http://cran.us.r-project.org/src/contrib/PACKAGES.html**](http://cran.us.r-project.org/src/contrib/PACKAGES.html)
>
> **RMySQL**
>
> **DBI**
>
> **date**
>
> **maps**
>
> **mapdata**
>
> **akima**
>
> **ncdf4** (to install this R package, it is essential that the
> **netCDF** software should be installed first.)
>
> **chron**
>
> **Hmisc**
>
> **Fields**
>
> *Notes:* On Ubuntu 10 we recommend installing R from apt-get as
> follows:
>
> **sudo apt-get install r-base-core**
>
> The default version of R, namely 2.15.0 does not allow some AMET R
> scripts to function correctly, and so the user needs to downgrade to R
> 2.14.0:
>
> **cd /home;mkdir R; cd R**
>
> **wget**
> [**http://cran.r-project.org/src/base/R-2/R-2.14.0.tar.gz**](http://cran.r-project.org/src/base/R-2/R-2.14.0.tar.gz)
>
> **tar xvzf R-2.14.0.tar.gz**
>
> **cd R-2.14.0**
>
> **./configure --prefix=/home/R --with-X=no**
>
> **make**
>
> **make test**
>
> **make install**
>
> Install R libraries from source.
>
> **sudo R **
>
> **&gt; install.packages(c("RMySQL", "maps",
> "mapdata","date","reshape", "rgdal", "sp", "maptools", "xtable",
> "yaml", "ggplot"))**

Install AMET Source Code and Tier 3 Software
============================================

Untar the tarball **AMET\_v1.0.tar.gz** (which you downloaded earlier
from the CMAS web site into a temporary directory) into a new directory
where you would like to have AMET installed. You do not need to make a
directory called AMET prior to untarring because the tarball includes
that directory. The AMET top-level directory now looks like the
following:

> **drwxr-x--- 12 user cmas 4096 2008-02-08 18:25 .**
>
> **drwxrwxr-x 4 user cmas 4096 2008-02-09 14:55 ..**
>
> **drwxr-x--- 4 user cmas 4096 2008-02-08 18:25 bin**
>
> **drwxr-x--- 2 user cmas 4096 2008-02-08 18:25 configure**
>
> **drwxr-x--- 4 user cmas 4096 2008-02-08 18:25 model\_data**
>
> **drwxr-x--- 4 user cmas 4096 2008-02-11 23:00 obs**
>
> **drwxr-x--- 5 user cmas 4096 2008-02-08 18:25 output**
>
> **drwxr-x--- 2 user cmas 4096 2008-02-08 18:25 perl**
>
> **drwxr-x--- 2 user cmas 4096 2008-02-08 18:25 R**
>
> **drwxr-x--- 4 user cmas 4096 2008-02-08 18:25 scripts\_analysis**
>
> **drwxr-x--- 7 user cmas 4096 2008-02-08 18:25 scripts\_db**
>
> **drwxr-x--- 7 user cmas 4096 2008-02-08 18:25 src**

During untarring, the AMET source code is installed in the
**$AMETBASE/R** and **$AMETBASE/perl** directories, and the AMET scripts
are located in the **$AMETBASE/script\_analysis** and
**$AMETBASE/script\_db** directories. The Tier 3 software source code is
located in the **$AMETBASE/src** directory. As noted earlier, Tier 3
software is a set of custom software utilities that have been developed
alongside AMET and are included in the AMET package.

For the AMET source and scripts, there is nothing further to do during
installation. Given below are some instructions to complete the
installation of Tier 3 software, and directions for linking the Tier 2
and Tier 3 executables to the **$AMETBASE/bin** directory.

Meteorological model utility
----------------------------

> **mm5tonetcdf**
>
> *Notes:*
>
> • If NetCDF was installed in a nonstandard directory (i.e., not under
> **/usr/local)**, see **$AMETBASE/src/mm5tonetcdf\_1.2/README** for
> instructions on how to set corresponding paths to the include files
> and libraries.
>
> • The default install location of **mm5tonetcdf** in **/usr/local**
> can be changed by the same process as for NetCDF; see the above
> **README** file.
>
> • Make sure that you compile **mm5tonetcdf** with the appropriate LFS
> (large file support) flags. The flags for the **gcc** compiler are:
>
> -**D\_FILE\_OFFSET\_BITS=64**
>
> **-D\_LARGEFILE64\_SOURCE**

Air quality model utilities
---------------------------

> **bld\_overlay**
>
> **combine**
>
> **sitecmp**
>
> **cmp\_airs**
>
> *Notes:*
>
> • For all of these utilities, please be sure to edit the **Makefile**
> to reflect where your **I/O API** and **netCDF** libraries are
> located, and build each of these utilities to create the executables.
>
> • We have provided three **I/O API** includes files—**FDESC3.EXT,
> IODECL3.EXT** and **PARMS3.EXT**—in the directory
> **$AMETBASE/src/ioapi\_incl**. However, if you have made any changes
> to these files in an existing installation of **I/O API**, make sure
> to use those instead. Make sure that they are from the **I/O API**
> **fixed\_src** directory.

Binary linking
--------------

> **bin\_linker.csh**
>
> *Note*: The required Tier 2 and Tier 3 executables must be linked to
> the **$AMETBASE/bin** directory. The **bin\_linker.csh** script has
> been provided in the **$AMETBASE/bin** directory for this purpose. It
> includes all the executables that need to be linked. Just edit the
> script with paths to your executables, and then execute it.

Configure AMETBASE variable
---------------------------

> **subs\_ametbase.sh**
>
> *Note:* The **AMETBASE** variable in all the scripts is currently set
> to “**~/AMET**”. If that is not where you untarred the AMET tarball,
> modify the script **$AMETBASE/bin/subs\_ametbase.sh** to reflect the
> top-level directory where you have AMET installed, and then execute
> it. The subs script has been updated to use the standard UNIX utility
> **sed.** If you do not have **sed**, you can modify the variable
> **AMETBASE** manually in the appropriate scripts (see the AMET user's
> guide for specifics). This d

Modify header for perl scripts
------------------------------

> **subs\_perl.csh**
>
> *Note:* All the **\*.pl** scripts under **$AMETBASE/perl** have a
> default location of the base **perl** as **/usr/local/perl**. If you
> have **perl** installed in a different location on your machine,
> change the setting for the variable **MYPERLDIR** in
> **$AMETBASE/bin/subs\_perl.csh** and execute it. This script makes use
> of the standard UNIX utility **sed.** If you do not have **sed**, you
> can manually edit the first line of each of the **perl** scripts to
> your **perl** path.

Install Test Case Data
======================

The final step in the installation process is to install the test case
data sets. These include sample model output data and observational
data.

Sample model output data
------------------------

In this step, you will untar the previously downloaded model outputs
from Section 1 in the corresponding directories indicated below.

> **Meteorological output data**
>
> • **MM5** (5.2 GB uncompressed, 3.1 GB compressed):
>
> Untar the file **mm5Example.tar.gz** in the directory
> **$AMETBASE/model\_data/MET.** This tarball contains a single **MM5**
> output file **MMOUT\_DOMAIN1\_02Jul04** that includes data from July
> 04 2002 12:00 UTC to July 10 2002 00:00 UTC, with a spatial domain
> covering the continental U.S. at 36- km resolution.
>
> • **WRF** (4.6 GB uncompressed, 2.4 GB compressed):
>
> Untar the file **wrfExample.tar.gz** in the directory
> **$AMETBASE/model\_data/MET**. This tarball contains five days’ worth
> of **WRF** outputs in netCDF format. The temporal range is July 5 2002
> 0:00 UTC to July 8 2002 23:00 UTC with a spatial domain covering the
> continental U.S. at 36-km resolution. The spatial domain of the
> **WRF** output is identical to the **MM5** domain above.
>
> • **MCIP** (455 MB uncompressed, 340 MB compressed):
>
> Untar the file **mcipExample.tar.gz** in the directory
> **$AMETBASE/model\_data/MET.** This tarball contains five days’ worth
> of **MCIP** outputs in netCDF format. The temporal range is July 5
> 2002 0:00 UTC to July 9 2002 23:00 UTC with a spatial domain covering
> the continental U.S. at 36-km resolution. Additionally, there is a
> **GRIDCRO2D** file for July 6 that is also used by AMET. The **MCIP**
> files were created using the **MMOUT\_DOMAIN1\_02Jul04** file provided
> in the **mm5Example.tar.gz** file.

After you untar the tarfiles above, the **$AMETBASE/model\_data/MET**
will contain the following files.

> **total 32**
>
> **drwxr-x--- 4 user cmas 4096 2008-02-14 20:35 .**
>
> **drwxr-x--- 4 user cmas 4096 2008-02-14 20:34 ..**
>
> **drwxr-x--- 2 user cmas 4096 2008-02-14 20:35 mm5Example**
>
> **drwxr-x--- 2 user cmas 4096 2008-02-14 20:35 mcipExample**
>
> **drwxr-x--- 2 user cmas 4096 2008-02-14 20:35 wrfExample**
>
> **./mm5Example:**
>
> **total 10807080**
>
> **drwxr-x--- 2 user cmas 4096 2008-02-14 20:35 .**
>
> **drwxr-x--- 4 user cmas 4096 2008-02-14 20:35 ..**
>
> **-rw-r----- 1 user cmas 5527809888 2008-02-11 12:15
> MMOUT\_DOMAIN1\_02Jul04**
>
> **./wrfExample:**
>
> **total 12007696**
>
> **drwxr-x--- 2 user cmas 4096 2008-02-14 20:35 .**
>
> **drwxr-x--- 4 user cmas 4096 2008-02-14 20:35 ..**
>
> **-rw-r----- 1 user cmas 1228378440 2007-08-20 17:26
> wrfout\_d01\_2002-07-05\_00:00:00**
>
> **-rw-r----- 1 user cmas 1228378440 2007-08-20 18:17
> wrfout\_d01\_2002-07-06\_00:00:00**
>
> **-rw-r----- 1 user cmas 1228378440 2007-08-20 19:03
> wrfout\_d01\_2002-07-07\_00:00:00**
>
> **-rw-r----- 1 user cmas 1228378440 2007-08-20 19:37
> wrfout\_d01\_2002-07-08\_00:00:00**
>
> **./mcipExample:**
>
> **total 579634**
>
> **drwxr-x--- 2 user cmas 4096 2008-02-14 20:35 .**
>
> **drwxr-x--- 4 user cmas 4096 2008-02-14 20:35 ..**
>
> **-rw-r----- 1 user cmas 502332 2008-05-19 12:55 GRIDCRO2D\_2002187**
>
> **-rw-r----- 1 user cmas 118426248 2008-05-12 11:21
> METCRO2D\_2002187**
>
> **-rw-r----- 1 user cmas 118426248 2008-05-12 11:25
> METCRO2D\_2002188**
>
> **-rw-r----- 1 user cmas 118426248 2008-05-12 11:29
> METCRO2D\_2002189**
>
> **-rw-r----- 1 user cmas 118426248 2008-05-12 11:33
> METCRO2D\_2002190**
>
> **Air quality output data** (7.9 GB uncompressed; 6.3 GB compressed)
>
> • **CMAQ:**
>
> Untar the **aqExample.tar.gz** file in the directory
> **$AMETBASE/model\_data/AQ**. For CMAQ, we have provided an A**CONC**
> and a **WETDEP** output file from a CMAQ simulation to demonstrate new
> analysis capabilities involving the AERO6 suite of species. These two
> files are netCDF outputs from the **combine** postprocessing step. The
> temporal range is from July 1 2006 00:00 UTC to July 11 2006 00:00 UTC
> with a spatial domain covering the continental U.S at 12-km
> resolution. To demonstrate the analysis of statistical correlations of
> meteorological and air quality model data we have also provided a
> **conc** and **WETDEP** output file from a 2002 CMAQ simulation with
> the temporal range from July 1 2002 00:00 UTC to July 11 2002 00:00
> UTC and a spatial domain covering the continental U.S at 36-km
> resolution; these data were included in the previous AMET release.

The directory **$AMETBASE/model\_data/AQ/aqExample** will contain the
following files.

> **-rw-r----- 1 user cmas 6851191364 Jan 4 14:04
> test.12km.AERO6.aconc**
>
> **-rw-r----- 1 user cmas 1264844424 Jan 4 14:05 test.12km.AERO6.dep**
>
> **-rw-r----- 1 user cmas 287676752 Feb 7 2008 test.36km.conc**
>
> **-rw-r----- 1 user cmas 63671444 Aug 24 2007 test.36km.dep**

Observational data
------------------

> Change directory to **$AMETBASE/obs**, and untar the contents of the
> file **AMET\_obs\_data.tar.gz** that you downloaded in Section
> 1**.**This will populate the air quality observations as well as
> provide the necessary directory structure for storing meteorological
> data.
>
> **Meteorological observational data**

-   These data are not included as part of this distribution, because
    > AMET dynamically downloads them as needed from the Meteorological
    > Assimilation Data Ingest System (MADIS) web site to
    > **$AMETBASE/obs/MET**. The contents of this directory should now
    > look like the following:

> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 LDAD/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 LDAD/mesonet/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 LDAD/mesonet/netCDF/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 LDAD/profiler/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 LDAD/profiler/netCDF/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 point/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 point/acarsProfiles/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59
> point/acarsProfiles/netCDF/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 point/coop/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 point/coop/netCDF/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 point/metar/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 point/metar/netcdf/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 point/maritime/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 point/maritime/netcdf/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 point/profiler/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 point/profiler/netcdf/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 point/sao/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 point/sao/netcdf/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 point/raob/**
>
> **drwxr-xr-x user/cmas 0 2007-11-18 21:40:59 point/raob/netcdf/**
>
> **-rw-r----- user/cmas 324001 2007-10-08 14:12:00 stations.csv**
>
> If the directory where AMET is installed has limited space, we suggest
> that you move the entire directory structure under
> **$AMETBASE/obs/MET** (point and LDAD) to another directory with
> larger capacity, and then create soft links from the location that
> contains the AMET installation to the new location. For the 5-day-long
> model datasets we have provided, the MADIS observational data that
> will be dynamically downloaded is on the order of about 1.0 GB
> uncompressed. AMET does allow the data to be stored in compressed
> format, which reduces the size to 109 MB, but the data need to be
> decompressed before they can be used in AMET.
>
> **Air quality observational data** (32 KB uncompressed; 0.2KB
> compressed)

-   We have provided links in the User’s Guide accompanying this
    > document to several air quality monitoring networks as part of
    > this release. The networks from which we have provided data links
    > are:

> *North America *

-   Air Quality System (AQS) network

-   Clean Air Status and Trends Network (CASTNET)

-   Interagency Monitoring of Protected Visual Environments (IMPROVE)
    > network

-   Mercury Deposition Network (MDN)

-   National Atmospheric Deposition Program (NADP) network

-   SouthEastern Aerosol Research and Characterization Study (SEARCH)
    > network

-   Speciated Trends Network (STN)

-   National Air Pollution Surveillance Program (NAPS) (speciated
    > measurements from Canada).

> *Europe*

-   AirBase (Europe)

-   Acid Gas and Aerosol Network (AGANET \[UK\])

-   Acid Deposition Monitoring Network (ADMN \[UK\])

-   Automatic Urban and Rural Network (AURN \[UK\])

-   European Monitoring and Evaluation Programme (EMEP) network

-   National Ammonia Monitoring Network (NAMN \[UK\])

> A brief description of data from each of these networks is provided in
> the AMET User’s Guide included in this release. We suggest that you
> refer to the respective web sites for additional information on these
> datasets, monitoring protocols, updates, etc. The temporal range of
> the data is network-dependent, and ranges from 2001 to 2006. The
> observational datasets have been preprocessed and reformatted (in some
> instances from their original sources) for access by AMET. We have
> also provided the monitoring station locations in a set of .csv files
> in the subdirectory **$AMETBASE/obs/AQ/site\_lists**. This is a very
> important set of metadata files that allows AMET to match modeled and
> observed data at the available locations from each network, and is
> critical to the database loading.

The air quality observational data will now be located in the directory
**$AMETBASE/obs/AQ,** and contain the following files.

> **total 2159520**
>
> **drwxr-xr-x 3 user cmas 4096 2007-11-18 21:45 .**
>
> **drwxr-x--- 4 user cmas 4096 2008-02-13 23:30 ..**
>
> **-rw-r----- 1 user cmas 60860821 2007-08-27 11:13
> aqs\_2001\_data.txt**
>
> **-rw-r----- 1 user cmas 63191870 2007-08-27 11:13
> aqs\_2002\_data.txt**
>
> **-rw-r----- 1 user cmas 64528385 2007-08-27 11:14
> aqs\_2003\_data.txt**
>
> **-rw-r----- 1 user cmas 64868353 2007-08-27 11:14
> aqs\_2004\_data.txt**
>
> **-rw-r----- 1 user cmas 63021553 2007-08-27 11:14
> aqs\_2005\_data.txt**
>
> **-rw-r----- 1 user cmas 66682252 2007-08-27 11:14
> aqs\_2006\_data.txt**
>
> **-rw-r----- 1 user cmas 224623 2007-08-21 12:07 aqs\_sites.csv**
>
> **-rw-r----- 1 user cmas 258524 2007-08-21 12:07 aqs\_sites.txt**
>
> **-rw-r----- 1 user cmas 18988626 2007-08-21 12:07 castnet\_data.csv**
>
> **-rw-r----- 1 user cmas 43635358 2007-08-21 12:06
> castnet\_hourly\_2001\_data.csv**
>
> **-rw-r----- 1 user cmas 45803909 2007-08-21 12:06
> castnet\_hourly\_2002\_data.csv**
>
> **-rw-r----- 1 user cmas 46366374 2007-08-21 12:06
> castnet\_hourly\_2003\_data.csv**
>
> **-rw-r----- 1 user cmas 46503727 2007-08-21 12:06
> castnet\_hourly\_2004\_data.csv**
>
> **-rw-r----- 1 user cmas 107215969 2007-08-21 12:06
> castnet\_hourly\_formatted.csv**
>
> **-rw-r----- 1 user cmas 3392 2007-08-21 12:07 castnet\_sites.txt**
>
> **-rw-r----- 1 user cmas 235507688 2007-08-21 12:06
> improve\_data.csv**
>
> **-rw-r----- 1 user cmas 5156 2007-08-21 12:06 improve\_sites.txt**
>
> **-rwxr----- 1 user cmas 1802127 2007-08-21 12:05 mdn\_data.csv**
>
> **-rw-r----- 1 user cmas 2330 2007-08-21 12:05 mdn\_sites.txt**
>
> **-rw-r----- 1 user cmas 10780221 2007-08-21 12:05 nadp\_data.csv**
>
> **-rw-r----- 1 user cmas 7672 2007-08-21 12:05 nadp\_sites.txt**
>
> **-rw-r----- 1 user cmas 125383938 2007-08-21 12:04
> search\_hourly\_all.csv**
>
> **-rw-r----- 1 user cmas 168 2007-08-21 12:04 search\_sites.txt**
>
> **drwxr-xr-x 2 user cmas 4096 2007-11-30 15:13 site\_lists**
>
> **-rw-r----- 1 user cmas 38273764 2007-08-21 12:03 stn\_data.csv**
>
> **-rw-r----- 1 user cmas 554239 2007-08-21 12:04 stn\_sites.txt**
>
> **Congratulations**! You have successfully installed the AMET package
> on your system and are ready to begin using it. Please see the
> *Atmospheric Model Evaluation Tool (AMET) User’s Guide,* which you
> downloaded earlier from the CMAS web site, for instructions on how to
> perform the example analyses.

<span id="_Toc359584111" class="anchor"><span id="_Toc359811821" class="anchor"></span></span>Reference
=======================================================================================================

Gilliam, R. C., W. Appel, and S. Phillips. [The Atmospheric Model
Evaluation (AMET): Meteorology
Module](http://cfpub.epa.gov/si/si_public_record_report.cfm?dirEntryId=139233&fed_org_id=770&SIType=PR&TIMSType=&showCriteria=0&address=nerl/pubs.html&view=citation&personID=48900&role=Author&sortBy=pubDateYear&count=100&dateBeginPublishedPresented=).
Presented at 4th Annual CMAS Models-3 Users Conference, Chapel Hill, NC,
September 26 - 28, 2005.
