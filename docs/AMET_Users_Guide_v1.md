<img src="media/image1.jpeg" width="304" height="72" />

***Atmospheric Model Evaluation Tool (AMET)  
User’s Guide***

**Contents**

1. Overview

   1.1 Overall Objective and Basic Structure

   1.2 Concept of an AMET “Project”

   1.3 Organization of This User’s Guide

2. Directory Structure

3. Configuration

   3.1 R Configuration File (amet-config.R)

4. Datasets

   4.1 Model Data

   4.2 Observational Data

5. Database Setup

   5.1 AMET Setup

   5.2 Basic MySQL Commands

6. Project Creation and Database Population

   6.1 The wrfExample Project

   6.2 The aqExample Project

   6.3 Creating a New MET Project

   6.4 Creating a New AQ Project
 
7. Analysis

   7.1 wrfExample

   7.2 aqExample

   7.3 Creating a New Analysis Project

8. CMAS Support for AMET

References

Appendix A: Overview Flow Diagram

**Appendix B: Configuration and Input Files**

  
Tables
======

Table 2‑1. Directories under $AMETBASE

Table 3‑1. Most common variables that need to be changed in
amet-config.R

Table 7‑1. MET analysis scripts

Table 7‑2. AQ analysis scripts

Table B‑1. amet-config.R 

Table B-2. MET setup\_project.input

Table B‑3. MET populate\_project.input 

Table B‑4. MET analysis input variables 

Table B‑5. AQ analysis input variables 

1.  Overview
    ========

    1.  Overall Objective and Basic Structure
        -------------------------------------

The Atmospheric Model Evaluation Tool (AMET) (Appel et al., 2011) is a
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
decision is based on the scope of the study. The two main software
components of AMETv1.3 are **MySQL** (an open-source database software
system) and **R** (a free software environment for statistical computing
and graphics). The previous versions of AMET also utilized **perl** (an 
open-source cross-platform programming language), but the **perl** requirement
has been removed from AMETv1.3.

Concept of an AMET “Project”
----------------------------

A central organizing structure for AMET applications is a *project*. A
project groups a particular model simulation (specific model,
physics-set, spatial domain, grid scale, etc.) with all of the AMET
database tables that correspond to that simulation, the scripts
necessary to populate that database, and the scripts required to analyze
that project. For example, you might have one project for a 2011 12-km
continental U.S. simulation, and another project for a 2011 4-km
Eastern U.S. simulation. A project can be for either MET or AQ, not for
both. It is essential that you uniquely name each project. It is
recommended that you follow the directory structure when creating new
projects, by copying one of the three example directories (aqExample,
mm5Example, wrfExample) provided with the installation and then renaming
it to the new project’s name.

Organization of This User’s Guide
---------------------------------

The Community Modeling and Analysis System (CMAS) Center has created
this user’s guide to assist you in applying the AMET system in your
work. CMAS obtained the MET and AQ portions of AMET separately from EPA,
then integrated the two to create a consistent and integrated AMET
package that uses the UNIX C-shell interface to perform both MET and AQ
model evaluation and analyses. After this integration, we tested the 
integrated AMET package on multiple environments.

Finally, we created this user’s guide. The contents of the remaining
sections are listed below.

-   Section 2 describes the overall directory structure of the AMET installation.

-   Section 3 gives instructions on how to configure the R configuration files.

-   In Section 4 is an overview of the various model outputs and observed data 
    provided with the AMET release.

-   Section 5 provides instructions on how to create the AMET MySQL database, with 
    specific instructions for each of the MET and AQ models. Sample MySQL commands 
    are also shown for illustrative SQL queries.

-   Section 6 gives instructions on how to populate the AMET MySQL database, with 
    specific instructions for each of the WRF and CMAQ models, and also on how to 
    create a new MET project and a new AQ project for subsequent analyses.

-   In Section 7 are instructions on how to perform model evaluation for each of the 
    WRF and CMAQ models, and includes an overview of the functionality of all the MET 
    and AQ evaluation scripts provided. 

***<span style="font-variant:small-caps;">Important note</span>:*** *The set of 
analyses/evaluation scripts provided in this release are strictly for illustration 
purposes on the functionality/design of AMET, and are not to be construed as a 
recommended suite of analyses scripts for model evaluation. We encourage the user 
community to use the scripts we have provided as examples as well as a basis to 
start developing other analyses scripts and contribute them to the modeling 
community to increase AMET functionality.*

-   Section 8 discusses how to obtain support for AMET from the Community Modeling 
    and Analysis System (CMAS) Center ([**http://www.cmascenter.org**](http://www.cmascenter.org)).

-   In Appendix A is an overall flow diagram for AMET and its various components.

-   Appendix B provides information on the various input files used in AMET. For each 
    input file, a table lists brief descriptions of all user-defined variables that can 
    be set by the user for a given evaluation.

Before using AMET and this user’s guide, you must first install the AMET package on your 
system. For information on the installation process, please see the separate *Atmospheric 
Model Evaluation Tool (AMET) Installation Guide* that can be downloaded from the CMAS web site.

2. Directory Structure
===================

In our discussions, we refer to the top of the AMET directory structure
as “AMETBASE”. This environment variable is actually set in many of the
scripts discussed below. For example, if you had untarred AMET’s tarball
in your home directory, then $AMETBASE would be ~/AMET.

Under $AMETBASE are the directories shown in Table 2-1.

<span id="_Toc190070890" class="anchor"><span id="_Toc199840991"
class="anchor"></span></span>Table 2‑1. Directories under $AMETBASE.

| **Directory**         | **Description**                                                       |
|-----------------------|-----------------------------------------------------------------------|
| **bin**               | External executables used by helper scripts.                          |
| **configure**         | Configuration files for R and php.                                    |
| **model\_data**       | Model output data (contains field-specific \[i.e., MET and AQ\] subdirectories). |
| **obs**               | Observational data (e.g., MADIS, discussed in Section 4.2) (contains field-specific \[i.e., MET and AQ\] subdirectories).         |
| **output**            | Output of database population and analysis (contains project-specific subdirectories). |
| **R\_analysis\_code** | R scripts used for statistical analysis.                              |
| **R\_db\_code**       | R scripts used for user and database setup.                           |
| **scripts\_analysis** | Project-specific wrapper scripts and inputs for analysis (contains project-specific subdirectories).|
| **scripts\_db**       | Project-specific wrapper scripts and inputs for database population (contains project-specific subdirectories). |
| **src**               | Source code for third-party software.                                 |

*Note:* For large model outputs and for MADIS observations that cover a
long period of time, it may be prudent to link these data within the
appropriate AMET directories rather than moving or copying them.

3. Configuration
=============

After untarring the AMET code and data and installing/building the
required two tiers of software components (as discussed in the AMET
installation guide referenced above), the next stage is to configure the
AMET system. In the $AMETBASE/configure directory, you will find three
files:

-   An R configuration file (amet-config.R)


3.1 R Configuration File (amet-config.R)
------------------------------------

The R configuration file is used by the underlying R programs to perform
AMET setup and statistical analysis on your model-obs pairs. Most users will 
need to modify only a few specific lines of this configuration file. The most
common variables to change are shown in Table 3-1.

<span id="_Toc199840993" class="anchor"></span>Table 3‑1. Most common
variables that need to be changed in amet-config.R.

| **Variable**   | **Description** |
|----------------|-----------------|
| **amet_base**           | The base directory where AMET is installed. By default this is read from the environment variable **AMETBASE** and therefore does not need to set explicitly here.|
| **mysql\_server**       | The MySQL server location. Examples are **localhost** if MySQL is installed on the same machine on which you have installed AMET, or **rama.cempd.unc.edu** if you have installed the MySQL server on a remote host called **rama**. |
| **amet\_login**         | Login for the AMET MySQL user. For the purposes of this tutorial, we assume **amet\_login** is set to **ametsecure**. This MySQL user will be created later when you are working through Section 5. To provide additional security, AMET is shipped with permissions that allow this file to be read only by the user. |
| **amet\_pass**          | Password for **ametsecure**, or your **login** (if you changed it from "**ametsecure**"). |
| **maxrec**              | Maximum records to retrieve for any MySQL query (-1 for no limit). Be default, **maxrec** is set to -1. |
| **EXEC_sitex**          | Full path to the **site_compare** executable. Only required if using the AQ side of AMET. |
| **EXEC_sitex_daily**    | Full path to the **site_compare_daily** executable. Only required if using the AQ side of AMET. |
| **bldoverlay\_exe**     | Full path to the **bldoverlay** executable. Only required if using the AQ side of AMET. |

A word about specifying the **amet_login** and **amet_pass**. Obviously these are MySQL credentials and are therefore sensitive. The MySQL credentials specified here are always used in the analysis scripts that come with AMET, which require only database read access to function. Therefore, the MySQL user specified here can be limited to read access only. However, these credentials can also be setup to be used by the aqProject.csh and metProject.csh scripts (and by default those scripts are setup to do so). For those scripts to work properly, the MySQL user specified must have permission to create databases and tables, in addition to read access. So, if the setting in the aqProject.csh and/or metProject.csh scripts is to read the **amet_login** and **amet_pass** variables for the amet-config.R file, those credentials must be for a user with full MySQL permissions.

For simplicity, it is suggested that the MySQL credentials specified in the amet-config.R file be for a user with full database permissions.

4. Datasets
========

The AMET release includes both model and observational datasets provided
as examples. You should have downloaded these into the proper
directories during the installation process.

4.1 Model Data
----------

For the model data, we have included both meteorological and air quality
data. We have organized the data into four example projects:
"metExample" and "aqExample". On the MET side, there is a 1-month WRF simulation 
(July 01 2011 00:00 UTC to July 31 2011 23:00 UTC). The WRF data file is

The WRF data consist of five WRF output files in netCDF format:

> $AMETBASE/model\_data/MET/**wrfExample**/
>
> wrfout\_d01\_2002-07-05\_00:00:00
>
> wrfout\_d01\_2002-07-06\_00:00:00
>
> wrfout\_d01\_2002-07-07\_00:00:00
>
> wrfout\_d01\_2002-07-08\_00:00:00
>
> wrfout\_d01\_2002-07-09\_00:00:00

Note that we have bolded “metExample” in the directory name above to
highlight the fact that we are using the project name to organize the
model output files into directories.

On the AQ side, we have included two CMAQ output files for the period
July 01 2011 0:00 UTC to July 31 2011 23:00 UTC. The two files:

> $AMETBASE/model\_data/AQ/**aqExample**/
>
> AMET_CMAQ_July_2011_Test_Data.aconc
>
> AMET_CMAQ_July_2011_Test_Data.dep

correspond to the concentration and wet deposition output files from
CMAQ, after they have been postprocessed with the combine utility.

All of the spatial domains cover the continental U.S. and have a 12-km
grid resolution.

4.2 Observational Data
------------------

As with the model data, the observations directory structure is divided
between MET and AQ fields. On the MET side, all of the observations come
from the Meteorological Assimilation Data Ingest System (MADIS),
provided by the National Oceanic and Atmospheric Administration (NOAA).
If you are going to use AMET for MET analysis, you must first contact
MADIS to obtain a MADIS account, login, and password (see
[**http://www-sdd.fsl.noaa.gov/MADIS**](http://www-sdd.fsl.noaa.gov/MADIS)
for details). You will use this login information in setting up the Perl
configuration file (discussed in Section 3.1).

In the AMET structure, all of the MADIS data are stored under
$AMETBASE/obs/MET. The file stations.csv is a metadata file that
describes the station ID and location of each of the MADIS monitoring
sites; this file is in comma-separated-value (.csv) format. The AMET
distribution from CMAS will not include any MET observations from MADIS.
When you run the database population scripts (Section 6), they will
automatically call the MADIS system to download the available monitoring
sites’ observations for the specified time period via ftp. For example,
the radiosonde data will be downloaded to

> $AMETBASE/obs/MET/point/raob/netcdf

Each of the observation files is a netCDF file representing one hour’s
worth of data from all available monitoring sites. The netCDF file can
be stored in a gzip compressed format to save space, and unzipped
automatically as needed. Note that the default settings for the MADIS
obs extraction are set in template files in $AMETBASE/bin/madis\_input.
You can modify these template files to extract mesonet data if desired.
Also, you can adjust the quality control level from its current highest
level. See the MADIS documentation available from their web site for
more information on how to customize these template files.

On the AQ side, we have included the observational data for the
following networks: Air Quality System (AQS) network, Clean Air Status
and Trends Network (CASTNET), Interagency Monitoring of PROtected Visual
Environments (IMPROVE) network, Mercury Deposition Network (MDN),
National Atmospheric Deposition Program (NADP) network, SouthEastern
Aerosol Research and Characterization Study (SEARCH) network, and the
Speciated Trends Network (STN). The observational datasets have been
preprocessed and reformatted (in some instances from their original
sources) for access by AMET. The temporal range is network dependent,
and ranges from 2001 to 2006. The monitoring station locations are
provided by a series of .csv files under the subdirectory
$AMETBASE/obs/AQ/site\_lists. A brief synopsis of each network, along
with the steps taken to create these data for AMET, is given below. Note
that in the species lists, each line is of the format “observed species
name; model species name (units)”.

### Clean Air Status and Trends Network (CASTNET) Weekly

*Source:* CASTNet data are obtained through the CASTNet web site:
[**http://www.epa.gov/castnet/**](http://www.epa.gov/castnet/). Weekly
CASTNet data can be obtained by downloading the “drychem” file under the
prepackaged datasets on the CASTNet web site. No postprocessing of the
downloaded data is necessary in order for them to be compatible with the
Site Compare (sitecmp) software packaged with the AMET system. Note that
the species **MG**, **CA**, **K**, **NA**, and **CL** are available when
using the CMAQ AERO6 module.

<span id="OLE_LINK1" class="anchor"><span id="OLE_LINK2"
class="anchor"></span></span>*Species used with AMET*:

> tso4; ASO4T (µg/m<sup>3</sup>)
>
> tno3; ANO3T (µg/m<sup>3</sup>)
>
> tnh4; ANH4T (µg/m<sup>3</sup>)
>
> tno3+nhno3; ANO3T+HNO3\_UGM3 (TNO3; µg/m<sup>3</sup>)
>
> nhno3; HNO3\_UGM3 (µg/m<sup>3</sup>)
>
> wso2; SO2\_UGM3 (µg/m<sup>3</sup>)
>
> MG; AMGJ (µg/m<sup>3</sup>)
>
> CA; ACAJ (µg/m<sup>3</sup>)
>
> K; AKJ (µg/m<sup>3</sup>)
>
> NA; ANAIJ (µg/m<sup>3</sup>)
>
> CL; ACLIJ (µg/m<sup>3</sup>)

### Clean Air Status and Trends Network (CASTNet) Hourly

*Source:* CASTNet data are obtained through the CASTNet web site:
[**http://www.epa.gov/castnet/**](http://www.epa.gov/castnet/). Hourly
CASTNet ozone data can be obtained by downloading the files labeled
“ozone\_yyyy” under the prepackaged datasets on the CASTNet web site.
Additionally, a “metdata\_yyyy” file is also available on the CASTNet
web site, which contains several meteorological variables in addition to
ozone. No postprocessing of the downloaded data is necessary in order
for them to be compatible with AMET’s sitecmp.

*Species used with AMET*:

> Ozone; ozone (ppb)

*Additional species that could be used with AMET:*

> Surface Temperature Precipitation
>
> Relative Humidity 10m Wind Speed
>
> Solar Radiation 10m Wind Direction

### Interagency Monitoring of PROtected Visual Environments (IMPROVE)

*Source:* IMPROVE data can be through the IMPROVE web site:
[**http://vista.cira.colostate.edu/improve/**](http://vista.cira.colostate.edu/improve/).
The IMPROVE web site links to the Visibility Information Exchange Web
System (VIEWS) web site, which is an interactive system for downloading
various air-quality-related data. IMPROVE data obtained through the
VIEWS system do not require any additional processing to work with
AMET’s sitecmp.

*Species used with AMET*:

> SO4f\_val; ASO4T (µg/m<sup>3</sup>)
>
> NO3f\_val; ANO3T (µg/m<sup>3</sup>)
>
> NH4f\_val; ANH4T (µg/m<sup>3</sup>)
>
> MF\_val; PM25 (µg/m<sup>3</sup>)
>
> OCf\_val; PM\_OC (µg/m<sup>3</sup>)
>
> ECf\_val; AECT (µg/m<sup>3</sup>)
>
> OCf\_val+ECf\_val; PM\_OC+AECT (TC; µg/m<sup>3</sup>)
>
> CHLf\_val; ACLIJ (µg/m<sup>3</sup>)
>
> MT\_val; PM10 (µg/m<sup>3</sup>)
>
> CM\_calculated\_val; PMC_TOT (µg/m<sup>3</sup>)
>
> NAf\_val; ANAIJ (µg/m<sup>3</sup>)
>
> NAf\_val+CHLf\_val; ANAIJ+ACLIJ (NaCl; µg/m<sup>3</sup>)
>
> FEf\_val; AFEJ (µg/m<sup>3</sup>)
>
> ALf\_val; AALJ (µg/m<sup>3</sup>)
>
> SIf\_val; ASIJ (µg/m<sup>3</sup>) 
>
> TIf\_val; ATIJ (µg/m<sup>3</sup>)
>
> CAf\_val; ACAJ (µg/m<sup>3</sup>)
>
> MGf\_val; AMGJ (µg/m<sup>3</sup>)
>
> Kf\_val; AKJ (µg/m<sup>3</sup>)
>
> MNf\_val; AMNJ (µg/m<sup>3</sup>)
>
> 2.20\*ALf\_val+2.49\*SIf\_val+1.63\*CAf\_val+2.42\*FEf\_val+1.94\*TIf\_val; ASOILJ (µg/m<sup>3</sup>)
>
> MF\_val-SO4f\_val-NO3f\_val-0.2903\*NO3f\_val-0.375\*SO4f\_val-OCf\_val-ECf\_val-NAf\_val-CHLf\_val-2.2*\ALf\_val-2.49\*SIf\_val-1.63\*CAf\_val-2.42\*FEf\_val-1.94\*TIf\_val; AUNSPEC1IJ (OTHER; µg/m<sup>3</sup>)
>
> ; ANCOMIJ (NCOM; µg/m<sup>3</sup>)
>
> ; AUNSPECIJ2 (OTHER_REM; µg/m<sup>3</sup>)

### Mercury Deposition Network (MDN)

*Source:* MDN data are obtained through the NADP/MDN network web site:
[**http://nadp.sws.uiuc.edu/mdn/**](http://nadp.sws.uiuc.edu/mdn/). Data
are available for download as a comma-delimited file for all sites. No
postprocessing of the downloaded data is necessary in order for them to
be used with AMET’s sitecmp.

*Species used with AMET* (from CMAQ deposition file):

> HGconc; TWDEP\_HG (ng/L)
>
> HGdep; TWDEP\_HG (µg/m<sup>2</sup>)

### National Atmospheric Deposition Program (NADP)

*Source:* NADP data are obtained through the NADP/NTN web site:
[**http://nadp.sws.uiuc.edu/**](http://nadp.sws.uiuc.edu/). Weekly wet
concentration data are downloaded in comma-delimited format directly
from the NADP web site. No postprocessing of the downloaded data is
necessary in order for them to be used with AMET’s sitecmp.

*Species used with AMET* (from CMAQ deposition file):

> Valcode
>
>Invalcode
>
> NH4; WDEP\_NHX (mg/L or kg/ha)
>
> NO3; WDEP\_TNO3 (mg/L or kg/ha)
>
> SO4; WDEP\_ASO4T (mg/L or kg/ha)
>
> Cl; WDEP\_TCL (mg/L or kg/ha)
>
> Na; WDEP\_ANAJK (mg/L or kg/ha)
>
> Ca; WDEP\_CAJK (mg/L or kg/ha)
>
> Mg; WDEP\_MGJK (mg/L or kg/ha)
>
> K; WDEP\_KJK (mg/L or kg/ha)
>
> precip; RT (mm)

### SouthEastern Aerosol Research and Characterization (SEARCH) Study

*Source:* SEARCH data are obtained through the SEARCH web site:
[**http://www.atmospheric-research.com/public/index.html**](http://www.atmospheric-research.com/public/index.html).
The SEARCH data can be downloaded as comma-delimited files for each
SEARCH site. In order to be used with sitecmp and AMET, the individual
site files must first be merged together into a single file. The example
SEARCH data file provided with AMET should serve as an example of how
the raw SEARCH data need to be combined and formatted in order to work
with sitecmp and AMET. The list of SEARCH species listed here is just an
example of the species available from SEARCH, as the exact species 
available varies depending on year and whether the data are hourly or 
daily. AMET formatted SEARCH data files are available for download from
the CMAS website.

*Species used with AMET*:

> o3; O3 (ppb)
>
> co; CO (ppb)
>
> so2; SO2 (ppb)
>
> no; NO (ppb)
>
> hno3; HNO3 (ppb)
>
> teom; PM25 (µg/m<sup>3</sup>)
>
> no3; ANO3T (µg/m<sup>3</sup>)
>
> so4; ASO4T (µg/m<sup>3</sup>)
>
> nh4; ANH4T (µg/m<sup>3</sup>)
>
> noy; NOY (ppb)

### Chemical Speciation Network (CSN)

*Source:* CSN data are obtained through the EPA’s Air Quality System
(AQS), located at
[**http://www.epa.gov/ttn/airs/airsaqs/**](http://www.epa.gov/ttn/airs/airsaqs/).
The data provided with AMET are a sample of the CSN data that can be
obtained through the AQS. Some postprocessing of the downloaded CSN data
is necessary in order for them to work with sitecmp and AMET. However, AMET
compatible CSN data files are available from the CMAS website.

*Species used with AMET*:

> m\_so4; ASO4T (µg/m<sup>3</sup>)
>
> m\_no3; ANO3T (µg/m<sup>3</sup>)
>
> m\_nh4; ANH4T (µg/m<sup>3</sup>)
>
> FRM PM<sub>2.5</sub> Mass; PM<sub>2.5</sub> (µg/m<sup>3</sup>)
>
> oc\_adj; PM\_OC (µg/m<sup>3</sup>)
>
> ec\_niosh; AECT (µg/m<sup>3</sup>)
>
> oc\_adj+ec\_niosh; PM\_OC+AECT (TC; µg/m<sup>3</sup>)

### Air Quality System (AQS)

*Source:* AQS data are obtained through the EPA’s Air Quality System
(AQS), located at
[**http://aqsdr1.epa.gov/aqsweb/aqstmp/airdata/download_files.html**](http://aqsdr1.epa.gov/aqsweb/aqstmp/airdata/download_files.html).
Various species of atmospheric gases are available for download through
the AQS. THe pre-generated files on this site need to be combined into a
single data file in order to work best with AMET. AMET compatible AQS data
files are available for download from the CMAS website.

*Hourly species used with AMET:*

> O3; O3 (ppb)
>
> NO; NO (ppb) 
>
> NOY; NOY (ppb)
>
> NO2; NO2 (ppb)
>
> NOX; NO+NO2 (NOX, ppb)
>
> CO; CO (ppb)
>
> SO2; SO2 (ppb)
>
> PM25; PMIJ (ug/m3) 
>
> PM10; PM10 (ug/m3)
>
> Isoprene; ISOP (ppb)
>
> Ethylene; ETH (ppb)
>
> Ethane; ETHA (ppb)
>
> Toluene; TOL (ppb)
>
> Temperature: SFC_TMP (C)
>
> RH; RH (%)
>
> Wind_Speed; WSPD10 (m/s)
>
> ; PBLH (m)
>
> ; SOL_RAD (watts/m2)
>
> ; 10*precip (mm/hr)

*Daily species used with AMET:*

>PM25; PMIJ (ug/m3)
>
> PM10; PM10 (ug/m3)
>
> Isoprene; ISOP (ppb)
>
> Ethylene;ETH (ppb)
>
> Ethane; ETHA (ppb)
>
> Toluene; TOL (ppb)
>
> Acetaldehyde; ALD2 (ppb)
>
> Formaldehyde; FORM (ppb)
>
> OC+OC_Blank; AOCIJ (ug/m3)
>
> EC,ug/m3; AECIJ (ug/m3)
>
> OC+OC_Blank+EC; AOCIJ+AECIJ (ug/m3)
>
> Na; ANAIJ (ug/m3)
>
> Cl; ACLIJ (ug/m3)
>
> Na+Cl; ACLIJ+ANAIJ (ug/m3)
>
> SO4; ASO4IJ (ug/m3)
>
> NO3; ANO3IJ (ug/m3)
>
> NH4; ANH4IJ (ug/m3)
>
> Fe; AFEJ (ug/m3)
>
> Al; AALJ(ug/m3)
>
> Si; SIJ (ug/m3)
>
> Ti; ATIJ (ug/m3)
>
> Ca; ACAJ (ug/m3)
>
> Mg; AMGJ (ug/m3)
>
> K; AKJ (ug/m3)
>
> Mg; AMNJ (ug/m3)
>
> 2.2\*Al+2.49\*Si+1.63\*Ca+2.42\*Fe+1.94\*Ti; ASOILJ (soil, ug/m3)
>
> PM25-SO4-NO3-NH4-OC-EC-[Na]-[Cl]-2.2\*Al-2.49\*Si-1.63\*Ca-2.42\*Fe-1.94\*Ti; AUNSPEC1IJ (OTHER, ug/m3)
>
> 0.8\*OC; ANCOMIJ (NCOM, ug/m3)
>
> PM25-SO4-NO3-NH4-OC-EC-[Na]-[Cl]-2.2\*Al-2.49\*Si-1.63\*Ca-2.42\*Fe-1.94\*Ti-0.8\*OC; UNSPEC2IJ (OTHER_REM, ug/m3)

5. Database Setup
==============

The next step in using AMET is to set up the MySQL database. Please
refer to the flow diagram in Appendix A to understand the overall flow
of data among the various modules within AMET. This section must be
completed before you populate the database with your project-specific
data (Section 6). This setup process is required only once for a given
AMET installation. There are separate setup procedures for the two
fields, MET and AQ. If you are using AMET for only one of those fields,
you need to run only the corresponding setup. If you are running AMET
for both fields, you will need to run both setups. In the following
discussion, we assume the default name of the AMET MySQL user is 
“ametsecure”. If you decide to change either of these, then you will 
need to update the appropriate variables in the R configuration files 
in the directory $AMETBASE/configure (see Section 3). Before you run 
the setup scripts, you will need to know the “root” password for the 
MySQL administrator. Note that this is not the same as the “ametsecure” 
password that will be created using the scripts discussed below.

5.1 AMET Setup
---------

Go to the setup directory

> $ cd $AMETBASE/scripts\_db/dbsetup

Here, you will see two C-shell scripts (.csh). 

To create an AMET user, you will need to edit and run the
create\_amet\_user.csh script. Specifically, you should make sure the
value of **AMETBASE** corresponds to your system. To execute the script,
type

> $ ./create\_amet\_user.csh

This will ask you for MySQL’s “root” password. The MySQL root user must 
have permission to create and modify user. It will then set up the AMET user, 
here assumed to be “ametsecure”. 

The setup directory also contains a script for removing the amet user and database. 
To delete a specific AMET database, edit and run the delete\_db.csh script,
specifically setting the $AMETBASE and $AMET_DATABASE (the database to be
removed).

> $./delete\_db.csh

This script will ask you for the MySQL “root” password before
proceeding. *Use this script with **EXTREME CAUTION** because this will
delete all of the data in the database corresponding to **all** of the
projects (**both MET and AQ**).*


5.2 Basic MySQL Commands
--------------------

As you begin to go through the amet database setup and the
project-specific database populate process, you may want to query the
database directly to see your progress. Here are a few commands to help
you interact directly with the MySQL amet database. For more specifics,
see one of the many MySQL books available, or look at the documentation
under

> [**http://dev.mysql.com/doc**](http://dev.mysql.com/doc)

To log onto the MySQL server from the command line, type

> $ mysql -u ametsecure -D amet –p

This will give you a MySQL prompt (“mysql&gt;“). Note that all MySQL
commands are case insensitive, and they must end with a semicolon (“;”).

To get a list of all the tables in your database, type

> mysql&gt; show tables;

After you have populated all of the example projects (end of Section 6),
that command will yield a table like this:

> +---------------------+
>
> | Tables\_in\_amet |
>
> +---------------------+
>
> | aqExample |
>
> | aq\_project\_log |
>
> | project\_log |
>
> | project\_units |
>
> | site\_metadata |
>
> | stations |
>
> | wrfExample\_profiler |
>
> | wrfExample\_raob |
>
> | wrfExample\_surface |
>
> +---------------------+

To select every column and row in your project\_log table:

> mysql&gt; select \* from project\_log;

To select the latitude, longitude, and common name columns from the
stations metadata table and limit the results to the first 20 rows:

> mysql&gt; select lat,lon,common\_name from stations limit 20;

To select all station metadata where the monitor is from the CASTNET
network:

> mysql&gt; select \* from site\_metadata where network=‘castnet’;

To determine which networks are included in the aqExample project:

> mysql&gt; select distinct network from aqExample;

6. Project Creation and Database Population
========================================

The database population phase of AMET must be performed for each new
project. As discussed in Section 1.2, the *project* is the organizing
structure that we use to group a particular model simulation with the
scripts and data used to populate the amet tables. If you go to the
database populate directory by typing

> $ cd $AMETBASE/scripts\_db

you will see two project directories and one input files directory in 
addition to the setup directories described earlier. The projects are

1.  a MET example for the WRF model (wrfExample),

2.  an AQ example for the CMAQ model (aqExample).

In the following subsections, we describe how to run each project.

6.1 The wrfExample Project
----------------------

Go to the project directory

> $ cd $AMETBASE/scripts\_db/wrfExample

Here, you will see two input files and two C-shell scripts. The
setup\_project.input file is the input file for initializing the
project’s database tables (discussed later in Section 6). The only thing
you should need to change in this file is the “$email” variable. Note
that you should use the backslash “escape” character, “\\”, to prevent
Perl from evaluating the “@” in your e-mail address. The
populate\_project.input file describes specific flags for the model
outputs and observations that you want to process. See Appendix B for
information on the specifics relating to each variable. You will likely
not need to change anything in this second input file.

The C-shell file metProject.csh is a wrapper script for calling the Perl
programs that actually populate the AMET database with the project data.
You will likely only need to verify that the variable AMETBASE has been
updated for this project. Run the script by typing

> $ ./metProject.csh &gt;& log.populate

This C-shell script will create three empty project tables in the AMET
database: wrfExample\_profiler, wrfExample\_raob, and
wrfExample\_surface. These tables correspond to the matches between the
model outputs and (1) the wind profiler observations, (2) the radiosonde
observations, and (3) the surface observations. After creating these
tables, the script then begins the matching process. This consists of
auto-ftp-ing data from the MADIS web site for the model’s temporal
period, unzipping the downloaded data, finding the geographic location
of each observation site on the model grid and interpolating to those
locations, populating the appropriate table with the model-obs pairs for
each variable, and optionally rezipping the data for compressed storage.
Finally, the script updates the project\_log with summary information
for the wrfExample project.

The second C-shell file, metFTP.csh, is a wrapper script for calling
Perl programs to download observational data from MADIS for a specific
period of time. This allows you to download observational data without
having the model output. Make sure the variable auto\_ftp is set to 1
when running this script. Please note that the MADIS data need to be
downloaded once for a given time period and will subsequently be
available to all projects.


6.2 The aqExample Project
---------------------

Go to the project directory:

> $ cd $AMETBASE/scripts\_db/aqExample

Here you will see one C-shell script and the combine subdirectory. 
The combine subdirectory is not used for this example; 
it is discussed later in Section 6.5, “Creating a New AQ Project”.

The C-shell file aqProject.csh is a wrapper script for calling the R
programs that actually create your project (and database if necessary)
and populate the AMET database with the project data. The variable that 
you will likely need to change for this project is “AMETBASE”. You can
specify the MySQL login and password in the script if desired. If you do not,
the script will prompt you for the MySQL login/password. If you submit
the script to queue, you'll need to spcecify the login and password on the
qsub command line. By default, the script is setup to prompt you for the 
MySQL login/password. Run the script by typing

> $ ./aqProject.csh &gt;& log.populate

This C-shell script will create the AMET database (if it doesn't already
exist), three required AQ database tables (i.e. project_units, site_metadata and
aq_project_log), and one empty project table in the AMET database: aqExample. 
After creating this table, the script then begins the matching process. This 
consists of calling a series of Fortran helper programs. The two Fortran helper 
programs are $AMETBASE/bin/sitex\_daily.exe and $AMETBASE/bin/sitex_daily_O3.exe; 
the first one matches the AQS network’s data to the nearest grid cell in the CMAQ 
model, and the second one does the same for the other networks. These programs need
to be downloaded and built (and the path to the excutable specified in the 
amet-config.R file before running the aqProject.csh script. After each network 
has been matched to the model, the aqExample table is populated with the model-obs 
pairs. In addition to creating and populating the aqExample table, the script 
updates the project\_units table with each network for that project. This table 
defines the physical units of the species variables for this network (e.g., ppb vs.
µg/m<sup>3</sup>). Finally, the script updates the aq\_project\_log with
summary information for the aqExample project.

6.3 Creating a New MET Project
--------------------------

When you create your own projects, we recommend that you utilize the
structure of naming your directories after your projects. If you choose
not to do this, you will have to modify the provided run scripts.

To create a new project, follow these basic steps:

1.  Copy the appropriate example project to a new directory.

2.  Rename it after your new project (use the *exact* project name, as
    many scripts use the project name to navigate directories).

3.  Create a new project directory under $AMETBASE/model\_data/MET for
    the input model data.

4.  Change the appropriate variables in the project C-shell script.

5.  Run your new populate script.

For example, if we were creating a new WRF project called “wrfNC2007”,
we would use

> $ cd $AMETBASE/scripts\_db
>
> $ cp -r wrfExample wrfNC2007
>
> $ cd wrfNC2007

Create a new model data directory and move or link your model data into
it, as follows:

> $ cd $AMETBASE/model\_data/MET
>
> $ mkdir wrfNC2007
>
> $ cd wrfNC2007
>
> $ ln -s &lt;model data&gt; .

Here, you would replace “&lt;model data&gt;” with the path to your model
data file(s). The metProject.csh script will perform the model-obs
matching on all model outputs in this new directory.

Next, edit the $AMETBASE/script\_db/wrfNC2007/metProject.csh variables
AMET\_PROJECT ("wrfNC2007") and AMET\_PROJ\_DESC (your description of
the project).

Finally, run the populate script:

> $ cd $AMETBASE/scripts\_db/wrfNC2007
>
> $ ./metProject.csh

This will create a new MET project in the amet database. Specifically,
it will create a new row in your project\_log table and three new
tables: wrfNC2007\_profiler, wrfNC2007\_raob, and wrfNC2007\_surface.

6.4 Creating a New AQ Project
-------------------------

Before describing the creation of a new AQ project, we need to clarify a
potentially confusing issue: the relationship between model species and
monitor species. In order for AQ database population to work, there must
be a mapping between the model species and the various network species.
This mapping is accomplished by postprocessing the CMAQ model data, and
through the AQ_species_list.input file located in the
$AMETBASE/scripts\_db/input_files directory. The model data used in the 
aqExample section (Section 6.3) were already postprocessed, so we did not 
need to go through that step when running the example project. In a new 
project, you will likely need to postprocess your CMAQ data before they 
are ingested into the amet database. This postprocessing is accomplished 
in the third step of creating a new AQ project (described below), using 
the combine Fortran program.

Also, when you create your own projects, we recommend that you utilize
the structure of naming your directories after your projects. If you
choose not to do this, you will have to modify the provided run scripts.

To create a new project, follow these basic steps:

1.  Copy the appropriate example project to a new directory.

2.  Rename it after your new project (use the *exact* project name).

3.  Postprocess the model data using the combine Fortran program.

4.  Create a new project directory under $AMETBASE/model\_data/AQ for
    the input model data.

5.  Change the appropriate variables in the project C-shell script.

6.  Run the new populate script.

For example, if we were creating a new AQ project called “aqNC2007”, we
would use

> $ cd $AMETBASE/scripts\_db
>
> $ cp -r aqExample aqNC2007

Next you will need to postprocess the raw CMAQ concentration and wet
deposition files to map the data to the appropriate species names. To do
this, you will use the combine Fortran program. Go to the combine
directory:

> $ cd aqNC2007/combine

Edit the combine\_conc.csh and combine\_dep.csh scripts for your model
data. For detailed instructions on combine, see
[**http://www.cmascenter.org/help/model\_docs/cmaq/4.6/EVALUATION\_TOOLS.txt**](http://www.cmascenter.org/help/model_docs/cmaq/4.6/EVALUATION_TOOLS.txt).
Run the two combine scripts:

> $ ./combine\_conc.csh
>
> $ ./combine\_dep.csh

Next, create a new model data directory and move or link your
postprocessed model data into it, as follows:

> $ cd $AMETBASE/model\_data/AQ
>
> $ mkdir aqNC2007
>
> $ cd aqNC2007
>
> $ ln -s &lt;model data&gt; .

Here, you would replace “&lt;model data&gt;” with the path to your
postprocessed model data file(s).

The next step is to edit the $AMETBASE/scripts\_db/aqNC2007/aqProject.csh
script for your particular project. This script does two things. It creates
your project table in the amet database and populates that project table
with your data (it will also create the database if it does not already exist). 
You'll specifiy a number of options in the aqProject.csh script which will then 
call several R scripts to run site compare and then poplulate the database with 
your data. This script will be reused for your various AMET-AQ projects, so while 
this script contains a number of options, you will likely only need to fully setup 
this script once and re-use it with little modification in the future.

First, you'll need to specify some basic amet information. You'll need to 
specify **AMETBASE** as done in the previous scripts. Next set the **AMET_DATABASE** 
to use (by default this is set to "amet"). If desired, you can specify the MySQL login
information using the **mysql_login** and **mysql_password** variables (commented out by
default). If you choose not to specify the login/password using these variables, the script
will prompt you for the MySQL login and password. 

The **AMET_PROJECT** should be the same name you called the directory and needs to be 
unique and contain no spaces. Continue by specifying the AQ **MODEL_TYPE** (e.g. "CMAQ");
the **RUN_DESCRIPTION**, which is a short description of your project; The **USER_NAME** 
will default to your system user ID, but you can change it if desired. The **USER_NAME** 
is only used to identify you in the amet database and is not used to as a login to the 
amet database (when executed, the script will prompt you for the amet login and password 
unless you specified it via the **mysql_login** and **mysql_password** variables). Finally,
you can specify an email address (**EMAIL_ADDR**) to associate with the project, however this
email address is not currenlty used for anything in AMET and is simply stored along with the
project information.

The table below describes the other options and file locations that need to be
specified in the aqProject.csh script.

| **Variable**   | **Description**                                                                                                                                                                                                                                                                                                                                                                  |
|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **AMET\_OBS**              | Top of the AQ observation data directory (defaults to **$AMETBASE/obs/AQ**) |
| **SITE\_META\_LIST**       | Input file containing the list of AQ site meta data files (default is **$AMETBASE/scripts\_db/input\_files/sites\_meta.input**) |
| **A\_SPECIES\_FILE**    | Full path the AMET_species_list.R file for mapping the CMAQ species to the observed species for each network. By default this is set to **$AMETBASE/scripts\_db/input\_files/AMET\_species\_list.input** |
| **AMET\_OUT**              | Output directory where post-processed data files will be written. Default is **$AMETBASE/output/$AMET\_PROJECT/sitex_output** |
| **WRITE\_SITEX**           | T/F; Write the individual site compare scripts for each network.  |
| **RUN\_SITEX**             | T/F; Execute the site compare scripts for each network. |
| **LOAD\_SITEX**            | T/F; Load the output from the site compare scripts into the amet database. |
| **UPDATE\_PROJECT**        | T/F; Flag to update project. Setting to T will re-write project info (i.e. description, user_name, email) but not affect any existing data in the database. |
| **REMAKE\_PROJECT**        | T/F; Flag to remake project table. Setting to T will re-create an existing project, deleting any data that has been previously loaded but retaining the project table for future use, so use with caution. |
| **DELETE\_PROJECT**        | T/F; Flag to delete project table. Setting to T will delete an existing project, deleting any data that has been previously loaded and the table entirely, so use with caution. |
| **INC\_AERO6\_SPECIES**    | T/F; Flag to indicated whether or not to include CMAQ AERO6 species (e.g. Fe, Si, Mg, etc.). Typically set to T for CMAQ simulations that utilized the AERO6 module. |
| **INC\_CUTOFF**            | T/F; Flag to process species using the sharp PM2.5 cutoff in addition to the stardard I and J mode calculation of PM2.5 (these species must be calculated using combine). By default this flag is set to F and is considered an advanced user option. |
| **TIME\_SHIFT**            | T/F; Flag to indicate by how much to time shift the data in site compare. Typically this flag will be set to 1 if the ACONC files have been time shifted. Otherwise, this flag is set to 0. For the example data, no timeshifting of the ACONC files was applied, therefore this flag is set to 0 by default for the example case. |
| **START\_DATE**            | Start date in YYYYJJJ to begin the processing. By default this is set to 2011182 (July 1, 2011) for the example case. |
| **END\_DATE**              | End date in YYYYJJJ to begin the processing. By default this is set to 2011213 (August 1, 2011) for the example case. |
| **CONC\_FILE\_\***         | Path to the CMAQ combined file containing the gas and aerosol species, where * is a number starting at 1. You can specify up to ten CONC files to include, numbered sequentially from 1 to 10. By default this is set to point to the example model data in **$AMETBASE/model_data/AQ/test.12km.conc**|
| **DEP\_FILE\_\***          | Path to the CMAQ combined file containing the wet and dry species, where * is a number starting at 1. You can specify up to ten CONC files to include, numbered sequentially from 1 to 10. By default this is set to point to the example model data in **$AMETBASE/model_data/AQ/test.12km.dep** |
| **CASTNET**                | T/F; Flag to include the CASTNET weekly data in the analysis |
| **CASTNET\_HOURLY**        | T/F; Flag to include the CASTNET hourly data in the analysis |
| **CASTNET\_DAILY\_O3**     | T/F; Flag to include the CASTNET daily O3 (e.g. MDA8 O3) data in the analysis |
| **IMPROVE**                | T/F; Flag to include the IMPROVE daily data in the analysis |
| **NADP**                   | T/F; Flag to include the NADP weekly deposition data in the analysis |
| **CSN**                    | T/F; Flag to include the CSN daily data in the analysis |
| **AQS\_HOURLY**            | T/F; Flag to include the AQS hourly data in the analysis |
| **AQS\_DAILY\_O3**         | T/F; Flag to include the AQS daily O3 (e.g. MDA8 O3) data in the analysis |
| **AQS\_DAILY**             | T/F; Flag to include the AQS daily data in the analysis |
| **SEARCH\_HOURLY**         | T/F; Flag to include the SEARCH hourly data in the analysis |
| **SEARCH\_DAILY**          | T/F; Flag to include the SEARCH daily data in the analysis |
| **NAPS\_HOURLY**           | T/F; Flag to include the NAPS hourly data in the analysis |
| **CASTNET\_DRYDEP**        | T/F; Flag to include the CASTNET dry deposition data in the analysis |
| **AIRMON**                 | T/F; Flag to include the AIRMON data in the analysis |
| **AMON**                   | T/F; Flag to include the AMON data in the analysis |
| **MDN**                    | T/F; Flag to include the MDN data in the analysis |
| **FLUXNET**                | T/F; Flag to include the FLUXNET data in the analysis |
| **AIRBASE\_HOURLY**        | T/F; Flag to include the AIRBASE hourly data in the analysis |
| **AIRBASE\_DAILY**         | T/F; Flag to include the AIRBASE daily data in the analysis |
| **AURN\_HOURLY**           | T/F; Flag to include the AURN hourly data in the analysis |
| **AURN\_DAILY**            | T/F; Flag to include the AURN daily data in the analysis |
| **EMEP\_HOURLY**           | T/F; Flag to include the EMEP hourly data in the analysis |
| **EMEP\_DAILY**            | T/F; Flag to include the EMEP daily data in the analysis |
| **AGANET**                 | T/F; Flag to include the AGANET data in the analysis |
| **ADMN**                   | T/F; Flag to include the ADMN data in the analysis |
| **NAMN**                   | T/F; Flag to include the NAMN data in the analysis |
| **O3\_OBS\_FACTOR**        | Factor to apply to ozone observations, typically used to convert units. By default this is set to 1. |
| **O3\_MOD\_FACTOR**        | Factor to apply to ozone model data, typically used to convert units. By default this is set to 1. |
| **O3\_UNITS**              | ppb/ppm; Ozone units used. By default this is set to ppb.
| **PRECIP\_UNITS**          | mm/cm; Precip units used. By default this is set to cm.

Finally, run the populate script:

> $ cd $AMETBASE/scripts\_db/aqNC2007
>
> $ ./aqProject.csh

This will create a new AQ project in the amet database. Specifically, it
will create a new row in your aq\_project\_log table, a series of new
rows (one for each network) in your project\_units table, and a new
project table: aqNC2007.

7. Analysis
========

The analysis phase of AMET consists of performing statistical analyses
on the model-obs pairs and creating plots of the resulting statistics.
The basic process is to query the project’s database table(s) using a
set of SQL criteria; to perform statistical analyses on the returned
data; and to create plots, tables, and text file outputs. The current
AMET package contains a series of preprogrammed statistical analysis and
plotting routines, based on the R language. These scripts are provided
strictly as a starting point and as illustrative examples. Because all
the model-obs pairs are stored in a MySQL database, an advanced user can
decide to access those data in any desired manner, including other
software packages. All that is required is a MySQL interface and some
exploration of the table structure. We encourage advanced users to
extend these R scripts to create more specific or advanced plotting
capabilities, to use other languages to expand AMET analysis
capabilities, and to contribute these updates to the CMAS community.

As with the database populate phase, the project is the organizing
structure that we use to group a particular model run (specific model,
physics or chemistry, spatial domain, scale, etc.) with the scripts used
to analyze the amet tables and with the output from this analysis (plots
and data).

A second organizing structure is the grouping of three files for each
type of analysis. In the project directories, you will see a C-shell
script and a subdirectory **input_files** containing an input file with 
similar names (e.g., run\_timeseries.csh and timeseries.input). These two 
files set up everything that is necessary to run an underlying R script in 
$AMETBASE/R and then they run that script. The use of the C-shell interface 
allows users who are not very familiar with R to perform these predefined 
analyses, shielding them from the actual R code.

7.1 wrfExample
----------

Go to the project directory:

> $ cd $AMETBASE/scripts\_analysis/wrfExample

Here, you will see a series of C-shell scripts and their accompanying
input files. We will go through an analysis script in detail as an
example for running each of the scripts in the project.

The run\_spatial\_surface.csh script creates a series of maps comparing
the surface monitors to the model for one or more days. Each plot
provides color-coded model performance metrics at each of the monitor
locations. In each map, it plots the particular value at the monitor
location.

First, edit the run\_spatial\_surface.csh file. Change the AMETBASE
variable to correspond with your setup. The corresponding input file,
spatial\_surface.input, will likely not need to be changed.

Run the script:

> $ ./run\_spatial\_surface.csh

This will run the script and print out the location of the plots. In
addition to the script outputs, a detailed log file is produced and
located in the directory $AMETBASE/scripts\_analysis/wrfExample. After
the script has completed, go to the output directory and view your maps:

> $ cd $AMETBASE/output/wrfExample/spatial\_surface

You should see a whole series of plots of the form:

> wrfExample.&lt;stats&gt;.&lt;variable&gt;.20020705.20020709.pdf

A brief summary of each of the C-shell scripts is given in Table 7-1.

<span id="_Toc199840994" class="anchor"></span>Table ‑. MET analysis
scripts.

| **C-shell Script**        | **Input**            | **Description** |
|---------------------------|----------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **run\_daily\_barplot.csh**       | **daily\_barplot.input**              | Creates a series of daily barplots for all sites within your domain. |
| **run\_met\_aq.csh**              | **met\_aq\_coupled.input**            | Compares AQ and MET data. Creates a spatial plot of correlation and a time series plot of bias. *Note*: You need to setup both MET and AQ models and define the MET variables and the AQ species and network of interest. |
| **run\_plot\_prof.csh**           | **plot\_prof.input**                  | Creates time-height maps of wind direction and speed profiles statistics. Also can create spatial plot of site locations and names to help identify sites in the domain. |
| **run\_plot\_raob.csh**           | **plot\_raob.input**                  | Creates plots of rawinsonde sites. It creates a series of maps of all sites and vertical profile for user-specified site. |
| **run\_spatial\_surface.csh**     | **spatial\_surface.input**            | Creates a series of maps comparing surface monitor and model values for one or more days. |
| **run\_summary.csh**              | **summary.input**                     | Creates a summary plot of a series of MET variables. This includes a time series plot and an “ametplot,” which includes a scatterplot, time series, boxplot, and for wind direction, a histo­gram and directional scatterplot. Note that you may want to change the variable **AMET\_RUNID** to change the file naming convention. Also, the **AMET\_CRITERIA** is an additional SQL command that further limits the data used. This can be customized by the user. |
| **run\_timeseries.csh**           | **timeseries.input**                  | Creates a time series plot for one or more monitoring stations. Creates a time series plot for temperature, mixing ratio, wind speed and direction. You control which monitors are plotted through the **AMET\_SITEID** variable. You can also control date ranges and provide additional SQL criteria to further limit the data. *Note*: Multiple sites can either be averaged or used to create separate plots.                                                   |
| **run\_wind\_prof.csh**           | **wind\_prof.input**                  | Creates wind arrow profiles for a set of specific monitoring sites. |

Under the $AMETBASE/scripts\_analysis directory, you will notice that
there is only a wrfExample project on the MET side. We did not include
the mm5Example project nor the mcipExample project because the different
inputs are basically treated the same in terms of analysis. You could
easily add a new project directory for mm5Example or mcipExample by
following the instructions in Section 7.3.

7.2 aqExample
---------

Go to the project directory:

> $ cd $AMETBASE/scripts\_analysis/aqExample

Here, you will see a series of C-shell scripts and their accompanying
input files in the subdirectory **input\_files**. We will go through an 
analysis script in detail as a example for running each of the scripts 
in the project.

The run\_scatterplot.csh script creates a scatterplot for one species
from one or more monitoring networks. It compares the observed values to
the corresponding model values. The AQ side has an added complication:
not all monitoring networks monitor all species. Therefore, the user
needs to know which network(s) has the species of interest; if that
species is not available in the network(s) specified, the analysis
scripts will likely fail. See Section 4.2 and Appendix B for more
details on the various species that are monitored (or available) from
each AQ network.

First, edit the run\_scatterplot.csh file. Below is a table describing
the option available in the run\_scatterplot.csh script. Note that the 
species selected is SO4 and you are plotting two networks: IMPROVE and 
CASTNET. The corresponding input file, scatterplot.input, will likely not 
need to be changed for this example. 

Note that while each script has its own individual corresponding input file, 
there is also an input file called **all_scripts.input**, which contains all 
the options available for all the analysis scripts. This input file can be 
used instead of script specific input files, thereby eliminating the need to 
edit each individual input file. This may be a preferred option for some users.

| **Variable**   | **Description** |
|----------------|-----------------|
| **AMETBASE**                     | Base directory where AMET is installed. |
| **AMET\_DATABASE**               | MySQL database containing your project. |
| **AMET\_PROJECT**                | Name of the AMET project to analyze. |
| **AMET\_OUT**                    | Location to which to write output files (e.g. plots). By default this is set to $AMETBASE/output/$AMET_PROJECT/$analysis_script_type. |
| **AMET\_SDATE**                  | Start date in the form YYYYMMDD from which to begin the analysis. |
| **AMET\_EDATE**                  | End date in the form YYYYMMDD to which to end the analysis.|
| **AMET\_PID**                    | Process ID. This can be set to anything. By default it is simply set to 1. The PID is important when using the when AMET web interface code included in the AMETv1.3 as beta code. |
| **AMET\_PTYPE**                  | pdf/png/both; Indicate whether the output should be in PDF format, PNG format, or both. |
| **AMET\AQSPECIES**               | AQ species to analyze (e.g. O3, PM25, SO4, etc.). The species choosen must be one that is measured by the specified network (or networks if multiple networks are choosen). 
| **AMET\_CASTNET**                | y/n; Flag to include the CASTNET weekly data in the analysis |
| **AMET\_CASTNET\_HOURLY**        | y/n; Flag to include the CASTNET hourly data in the analysis |
| **AMET\_CASTNET\_DAILY\_O3**     | y/n; Flag to include the CASTNET daily O3 (e.g. MDA8 O3) data in the analysis |
| **AMET\_IMPROVE**                | y/n; Flag to include the IMPROVE daily data in the analysis |
| **AMET\_NADP**                   | y/n; Flag to include the NADP weekly deposition data in the analysis |
| **AMET\_CSN**                    | y/n; Flag to include the CSN daily data in the analysis |
| **AMET\_AQS\_HOURLY**            | y/n; Flag to include the AQS hourly data in the analysis |
| **AMET\_AQS\_DAILY\_O3**         | y/n; Flag to include the AQS daily O3 (e.g. MDA8 O3) data in the analysis |
| **AMET\_AQS\_DAILY**             | y/n; Flag to include the AQS daily data in the analysis |
| **AMET\_SEARCH\_HOURLY**         | y/n; Flag to include the SEARCH hourly data in the analysis |
| **AMET\_SEARCH\_DAILY**          | y/n; Flag to include the SEARCH daily data in the analysis |
| **AMET\_NAPS\_HOURLY**           | y/n; Flag to include the NAPS hourly data in the analysis |
| **AMET\_CASTNET\_DRYDEP**        | y/n; Flag to include the CASTNET dry deposition data in the analysis |
| **AMET\_AIRMON**                 | y/n; Flag to include the AIRMON data in the analysis |
| **AMET\_AMON**                   | y/n; Flag to include the AMON data in the analysis |
| **AMET\_MDN**                    | y/n; Flag to include the MDN data in the analysis |
| **AMET\_FLUXNET**                | y/n; Flag to include the FLUXNET data in the analysis |
| **AMET\_AIRBASE\_HOURLY**        | y/n; Flag to include the AIRBASE hourly data in the analysis |
| **AMET\_AIRBASE\_DAILY**         | y/n; Flag to include the AIRBASE daily data in the analysis |
| **AMET\_AURN\_HOURLY**           | y/n; Flag to include the AURN hourly data in the analysis |
| **AMET\_AURN\_DAILY**            | y/n; Flag to include the AURN daily data in the analysis |
| **AMET\_EMEP\_HOURLY**           | y/n; Flag to include the EMEP hourly data in the analysis |
| **AMET\_EMEP\_DAILY**            | y/n; Flag to include the EMEP daily data in the analysis |
| **AMET\_AGANET**                 | y/n; Flag to include the AGANET data in the analysis |
| **AMET\_ADMN**                   | y/n; Flag to include the ADMN data in the analysis |
| **AMET\_NAMN**                   | y/n; Flag to include the NAMN data in the analysis |

Also note that all AQ analysis scripts make use of the Network.input
input file. This file contains information about each observational
network available to the project that is needed by the R scripts. More
information about this file can be found in Appendix B, Table B-13.

Run the script:

> $ ./run\_scatterplot.csh

This will run the script and print out the location of the plots. In
addition to the script outputs, a detailed log file is produced and
located in the directory $AMETBASE/scripts\_analysis/aqExample. After
the script has completed, go to the output directory and view your
plots:

> $ cd $AMETBASE/output/aqExample/scatterplot

You should see files of the form:

> aqExample\_SO4\_scatterplot.pdf

A brief summary of each of the C-shell scripts is given in Table 7-2.

<span id="_Toc199840995" class="anchor"></span>Table ‑. AQ analysis
scripts.


| **C-shell Script**           | **Input**               | **Description**           | **Scope**         |
| ---------------------------- | ----------------------- | ------------------------- | ----------------- |
| **run\_boxplot.csh**         | **boxplot.input**       | Creates a box plot of model-obs quartiles. | single network; single species; multi simulation              |
| **run\_boxplot\_DofW.csh**         | **boxplot.input**       | Creates a box plot of model-obs quartiles parsed by the day of the week. | single network; single species; single simulation              |
| **run\_boxplot\_hourly.csh** | **boxplot\_hourly.input**    | Creates side-by-side boxplots to create a diurnal average curve. Hourly data only. | single network; hourly species only; multi simulation              |
| **run\_boxplot\_MDA8.csh**         | **boxplot.input**       | Creates a box plot of model-obs quartiles based on MDA8 ozone. | single network; single species; single simulation              |
| **run\_boxplot\_roselle.csh**         | **boxplot.input**       | Creates a box plot of model-obs quartiles, with select statistics provided underneath the box plot. | single network; single species; multi simulation              |
| **run\_boxplot\_solrad.csh**         | **boxplot.input**       | Creates a box plot of model-obs quartiles designed specifically to plot solar radiation data. | single network; single species; multi simulation              |
| **run\_bugleplot.csh**       | **bugleplot.input**          | Model performance criteria are adjusted as a function of the average concentration of the observed value for that species. As the average concentration of the species decreases, the acceptable performance criteria increase. Creates a bias and error plot. | multiple networks; single species; single simulation              |
| **run\_histogram.csh**         | **histogram.input**       | Creates a histogram of model-obs quartiles. | single network; single species; multi simulation              |
| **run\_overlay\_file.csh**   | **overlay\_file.input**      | Creates a data file that can be used by the program **bldoverlay** to create an overlay file. This file can be used in PAVE/VERDI to overlay over CMAQ model output. Hourly data only. | single network; hourly species only; single simulation              |
| **run\_plot\_spatial.csh**   | **plot\_spatial.input**      | Plots the observed value, model value, and difference between the model and obs for each site. Multiple values for a site are averaged to a single value for plotting purposes. | multiple networks; single species; single simulation              |
| **run\_plot\_spatial\_diff.csh**   | **plot\_spatial.input**      | Plots the difference in bias and error between two model simulations each site. Multiple values for a site are averaged to a single value for plotting purposes. | multiple networks; single species; multi simulations required            |
| **run\_plot\_spatial\_mtom.csh**   | **plot\_spatial.input**      | Plots the absolute difference between two model simulations at observation sites, regardless if valid observations exist or not. Multiple values for a site are averaged to a single value for plotting purposes. | multiple networks; single species; multiple simulations required      |
| **run\_plot\_spatial\_ratio.csh**   | **plot\_spatial.input**      | Plots the model/obs ratio for each site. Multiple values for a site are averaged to a single value for plotting purposes. | multiple networks; single species; single simulation              |
| **run\_raw\_data.csh**         | **raw_data.input**       | Used to extract raw data from the database. Output is a csv file containing the data requested. | single network; single species; multi simulation              |
| **run\_scatterplot\_bins.csh**     | **scatterplot.input**        | Creates a multi-panel scatterplot of bias and RMSE, where the values are binned by the observed or modeled concentration. This script will plot a single species for a single network. | single networks; single species; multiple simulations           |
| **run\_scatterplot.csh**     | **scatterplot.input**        | Creates a single model vs. obs scatterplot. This script will plot a single species from up to three networks on a single plot. Summary statistics are also included on the plot. | multiple networks; single species; multiple simulations           |
| **run\_scatterplot\_density.csh**     | **scatterplot\_density.input**        | Creates a single model vs. obs scatterplot with shading to represent the density of points. | multiple networks; single species; single simulation        |
| **run\_scatterplot\_mtom.csh**   | **scatterplot\_mtom.input**    | Creates a single model-to-model scatterplot. *Note*: The model points correspond to network’s site locations only. | multiple networks; single species; multiple simulations           |
| **run\_scatterplot\_multi.csh**     | **scatterplot\_multi.input**        | Creates a single model vs. obs scatterplot, designed specifically for plotting many simulations on a single plot. This script will plot a single species from a single network for up to six different simulations. Summary statistics are also included on the plot. | single networks; single species; multiple simulations |
| **run\_scatterplot\_percentiles.csh**     | **scatterplot\_percentiles.input**        | Creates a single model vs. obs scatterplot, color coding the 5th, 25th, 50th, 75th and 95th percentiles. | single networks; single species; single simulation |
| **run\_scatterplot\_single.csh** | **scatterplot\_single.input**  | Creates a scatter plot for a single network that includes more specific statistics than run\_scatterplot.csh.| single network;single species;multiple simulations           |
| **run\_scatterplot\_skill.csh**  | **scatterplot\_skill.input**   | Creates a forecast skill scatter plot. The script is designed to work specifically with O<sub>3</sub>. | all AQS networks; O<sub>3</sub>; single simulation              |
| **run\_scatterplot\_soil.csh**     | **scatterplot\_soil.input**        | Creates a single model vs. obs scatterplot designed specifically for plotting soil species (e.g. Si, Fe, Al, etc.). This script will plot the soil species from a single network on a single plot. | single network; multiple soil species; single simulation           |
| **run\_soccerplot.csh**          | **soccerplot.input**           | Creates a soccerplot for one or more species over one or more networks. Criteria and goal lines are plotted in such a way as to form a “soccer goal” on the plot area. Two statistics are then plotted: Bias \[**NMB** (normalized mean), **FB** (fractional), or **NMdnB** (normalized median)\] on the x-axis and Error \[**NME** (normalized mean), **FE**(fractional), or **NMdnE**(normalized median)\] on the y-axis. The better the performance of the model, the closer the plotted points will fall within the “goal” lines. | multiple network; multiple species; multiple simulations           |
| **run\_spectral\_analysis.csh**          | **spectral\_analysis.input**           | Creates four plots: a CDF plot; a Q-Q plot; a Taylor diagram; and a periodogram | single network; single species; multiple simulations           |
| **run\_stacked\_barplot\_AE6.csh**    | **stacked\_barplot\_AE6.input**     | Data are averaged (mean or median) for SO<sub>4</sub>, NO<sub>3</sub>, NH<sub>4</sub>, EC, OC, soil, NCOM and PM<sub>2.5</sub> other for the model and observed values. Averages are then plotted on a stacked bar plot, along with the percent of the total PM<sub>2.5</sub> that each species constitutes.| CSN, IMPROVE or SEARCH; species predefined; multiple simulations |
| **run\_stacked\_barplot.csh**    | **stacked\_barplot.input**     | Data are averaged (mean or median) for SO<sub>4</sub>, NO<sub>3</sub>, NH<sub>4</sub>, EC, OC, and PM<sub>2.5</sub> other for the model and observed values. Averages are then plotted on a stacked bar plot, along with the percent of the total PM<sub>2.5</sub> that each species constitutes.| CSN, IMPROVE or SEARCH; species predefined; multiple simulations |
| **run\_stacked\_barplot\_panel\_AE6.csh**    | **stacked\_barplot\_panel\_AE6.input**     | Data are averaged (mean or median) for SO<sub>4</sub>, NO<sub>3</sub>, NH<sub>4</sub>, EC, OC, soil, NCOM and PM<sub>2.5</sub> other for the model and observed values. Averages are then plotted on a stacked bar plot, along with the percent of the total PM<sub>2.5</sub> that each species constitutes. Specifically designed to plot data for an entire year (separated by season) for four different geographic regions. | CSN, IMPROVE or SEARCH; species predefined; single simulation |
| **run\_stacked\_barplot\_panel\_AE6\_multi.csh**    | **stacked\_barplot\_panel\_AE6\_multi.input**     | Data are averaged (mean or median) for SO<sub>4</sub>, NO<sub>3</sub>, NH<sub>4</sub>, EC, OC, soil, NCOM and PM<sub>2.5</sub> other for the model and observed values. Averages are then plotted on a stacked bar plot. Specifically designed to plot data for an entire year (separated by season) for four different geographic regions for multiple simulations. | CSN, IMPROVE or SEARCH; species predefined; multiple simulations |
| **run\_stacked\_barplot\_panel\_AE6.csh**    | **stacked\_barplot\_panel\_AE6.input**     | Data are averaged (mean or median) for SO<sub>4</sub>, NO<sub>3</sub>, NH<sub>4</sub>, EC, OC and PM<sub>2.5</sub> other for the model and observed values. Averages are then plotted on a stacked bar plot, along with the percent of the total PM<sub>2.5</sub> that each species constitutes. Specifically designed to plot data for an entire year (separated by season) for four different geographic regions. | CSN, IMPROVE or SEARCH; species predefined; single simulation |
| **run\_stacked\_barplot\_soil.csh**    | **stacked\_barplot\_soil.input**     | Data are averaged (mean or median) for the soil species (e.g. Si, Fe, Ti, Mg, etc.) for the model and observed values. Averages are then plotted on a stacked bar plot, along with the percent of the total soil concentration that each species constitutes.| CSN and IMPROVE networks; species predefined; single simulation |
| **run\_stacked\_barplot\_soil\_multi.csh**    | **stacked\_barplot\_soil\_multi.input**     | Data are averaged (mean or median) for the soil species (e.g. Si, Fe, Ti, Mg, etc.) for the model and observed values. Averages are then plotted on a stacked bar plot, along with the percent of the total soil concentration that each species constitutes.| CSN and IMPROVE networks; species predefined; multiple simulations |
| **run\_stats\_plots.csh**     | **stats\_plots.input**            | Generates a series of spatial plots of **NMB, NME, FB, FE**, and **Correlation**. CSV files with additional domain- and site-specific statistics are also included. | multiple networks; single species; single simulation              |
| **run\_timeseries.csh**       | **timeseries.input**    | Creates a time series plot. With multiple sites; the sites are time averaged to create a single plot. Also plots the bias and error between the obs and model.| single network;single species; multiple simulations           |
| **run\_timeseries\_mtom.csh**       | **timeseries\_mtom.input**    | Creates a model to model time series plot. With multiple sites; the sites are time averaged to create a single plot. Also plots the bias between the and model.| single network;single species; multiple simulations           |
| **run\_timeseries\_multi.csh**       | **timeseries\_multi\_networks.input**    | Creates a time series plot for up to two networks. With multiple sites; the sites are time averaged to create a single plot. Also plots the bias between the obs and model.| multiple networks;single species; multiple simulations           |

7.3 Creating a New Analysis Project
-------------------------------

Creating a new analysis project requires the same basic steps for both
the MET and the AQ models. When you create your own analysis projects,
we recommend that you utilize the structure of naming your directories
after your projects (described earlier). To run analyses, you must
already have populated the database with the new project (see Sections
6.4 and 6.5). To create a new analysis project, follow these basic
steps:

1.  Copy the appropriate example project to a new directory.

2.  Rename it after your new project (use the *exact* project name, as
    > many scripts use the project name to navigate directories).

3.  Change the appropriate variables in the project C-shell scripts.

4.  Run the new analysis scripts.

For example, if we were creating a new WRF project called “wrfNC2007”,
we would use

> $ cd $AMETBASE/scripts\_analysis
>
> $ cp -r wrfExample wrfNC2007
>
> $ cd wrfNC2007

In each of the C-shell scripts you want to run, make sure to change the
AMET\_PROJECT to wrfNC2007. You will also likely change dates and custom
titles in many of the scripts.

Run the desired analysis scripts from your new project directory.

8. CMAS Support for AMET
=====================

We have added AMET to Bugzilla, the CMAS bug-tracking and support
request software system. You are encouraged to contact CMAS via bugzilla
if you have bugs to report, or if you would like assistance with a
specific component of AMET. The Bugzilla site for AMET is
[**http://bugz.unc.edu/enter\_bug.cgi?product=AMET**](http://bugz.unc.edu/enter_bug.cgi?product=AMET).
If you have never accessed this site before, a user account needs to be
created by sending an email request to the CMAS administrator. We have
created the following subsections on the Bugzilla AMET page:

-   AQ Analyses

-   AQ Database

-   Installation

-   Met Analyses

-   Met Database

-   Other

References
==========

Appel, K.W., Gilliam, R.C., Davis, N., Zubrow, A., and Howard, S.C.: Overview of the Atmospheric Model Evaluation Tool (AMET) v1.1 for evaluating meteorological and air quality models, Environ. Modell. Softw.,26, 4, 434-443, 2011.

  
==

**Appendix A:  
Overview Flow Diagram**

  
==

<img src="media/image2.png" width="624" height="856" />

**Appendix B:  
Configuration and Input Files**

1.  R Configuration File (amet-config.R)

This is the configuration file for all R scripts used in database
population—for example, $AMETBASE/configure/amet-config.R.

<span id="_Toc199840996" class="anchor"></span>Table B-1. amet-config.R

| **Variable**       | **Description**                                                                                                                                                                                                                                                              |
|--------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **amet\_base**      | Top of AMET directory tree. |
| **obs\_data\_dir**  | Path to AQ observation data files. Default is **$amet_base/obs/AQ**. |
| **mysql\_server** | MySQL server location. Examples are “**localhost**” for the same machine as AMET, or “**rama.cempd.unc.edu**” for a server on rama. |
| **amet\_login**     | MySQL user for adding data to the database and performing queries. “**ametsecure**” is recommended. This user will be created in the database setup. *Note:* To increase system security, users may want to restrict this configuration file to read and write only by user. |
| **amet\_pass**    | Password for “**ametsecure**”, or your **$amet\_login** (if changed from “**ametsecure**”). This user will be created in the database setup.     |
| **maxrec**     | Maximum number of records to extract from the database for any one query. No maximum = **-1**.    | 
| **EXEC\_sitex_daily**     | Full path to the site compare daily executable. |
| **EXEC\_sitex**           | Full path to site compare executable. |
| **$fslftp\_madis** | MADIS ftp site (needed only if using MET side). |
| **$login\_madis**  | MADIS-provided login (MET side only). |
| **$pass\_madis**   | MADIS-provided password (MET side only). |
| **$fslftp\_ncep**  | NCEP ftp site (needed only if using MET side). |
| **$login\_ncep**   | NCEP login; most likely “**anonymous**”. |
| **$pass\_ncep**    | Anonymous password for NCEP, usually your email address. Note the necessary “\\@” (MET side only). |
| **$amet\_verbose** | Verbose stdout. “**yes**” for more verbose, “**no**” for less verbose. |


2.  MET Project Setup Input File

This is the MET input file for all new projects, and sets up an empty
project—for example,
$AMETBASE/scripts\_db/wrfExample/setup\_project.input.

<span id="_Toc199840998" class="anchor"></span>Table B‑2. MET setup\_project.R

| **Variable**     | **Description**                                                                              |
|------------------|----------------------------------------------------------------------------------------------|
| **$run\_id**     | Project name. Must be unique across both MET and AQ project names.                           |
| **$model**       | MET model. Examples: “**mm5**”, “**wrf**”.                                                   |
| **$login**       | Your username. Identifier used to populate **user** column in **project\_log** table.        |
| **$email**       | Your email. Note: use the backslash character “**\\**” to escape the “@” character for Perl. |
| **$description** | Brief project description.                                                                   |


3.  MET Project Populate Input Files

This is the MET input file for populating new projects—for example,
$AMETBASE/scripts\_db/wrfExample/populate\_project.input.

<span id="_Toc199841000" class="anchor"></span>Table B‑3. MET
populate\_project.input

| **Variable**            | **Description** |
|-------------------------|-----------------|
| **$pid**                | Project name. Must be unique across both MET and AQ project names.  |
| **$model**              | MET model. Examples: “**mm5**”, “**wrf**”, “**mcip**”, or “**eta**”. |
| **$obs\_format**        | Observation format: “**madis**” – MADIS observations, “**tdl**” – preprocessed nonstandard obs |
| **$model\_data\_dir**   | Directory of model output. |
| **$mcip\_grid\_file**   | Path to MCIP GRIDCRO2D file. |
| **$obs\_dir**           | Top of observation directory. For MADIS, this is the equivalent of **$TOP** and **$MADIS\_DATA**. For typical setup, this will be **$AMETBASE/obs/MET**. |
| **$tmp\_dir**           | Output directory for temporary MADIS files and MM5 netCDF files.  |
| **$interp\_method**     | Interpolation technique from model grid to observation location:  **0** – bilinear, **1** – nearest neighbor |
| **$eval\_class**        | Observation types to include: “**surface**” – surface observations only, “**profiler**” – wind profiler, “**raob**” – rawinsonde only, “**acars**” – aircraft only, “**mesonet**” – mesonet only, “**all**” – all observation types |
| **$diagnose\_sfc**      | Diagnose surface model: **1** – MM5 with PX surface model, **0** – WRF or MM5 without PX surface model. Note that if you use **0** for MM5, you need to change **$match\_config** to non-PX configuration.  |
| **$output\_int**        | Model output time step in hours. |
| **$eval\_int**          | Observations time step in hours. |
| **$forecast**           | Model is a forecast, so observations may not be available for all hours: **1** – yes (forecast hour is set to time index in model output × output interval), **0** – no (forecast hour is set to zero) |
| **$auto\_ftp**          | Automatically ftp observations from MADIS: **1** – yes, **0** – no |
| **$auto\_unzip**        | Automatically unzip MADIS data stored in gzip format: **1** – yes, **0** – no |
| **$auto\_zip**          | Automatically zip MADIS data in gzip format for storage: **1** – yes, **0** – no |
| **$time\_index\_start** | Starting index of model output. This can be used to skip a spin-up period. The starting point is index + 1. Example values: **-1** – start at 0th hour, i.e., include all time steps, **0** – skip first time step, start at hour 1, **11** – start at hour 12 |
| **$process\_npa**       | Match model precip with National Precipitation Analysis (not supported at this time): **1** – yes, **0** – no |
| **$real\_time **        | Real-time run, use current system date as time range in scripts: **1** – yes, **0** – no |
| **$file\_date**         | For MM5 data, model data need to be in netCDF format or converted to netCDF. If they have been converted, they need to use the naming convention **mmout.YYYY.MM.DD-NHRS**. For example, **mmout.2001.04.01.00-48** is a model run starting at 4/1/2001 00 UTC and running for 48 hours. MM5 has already been converted to netCDF: **1** – yes, **0** – no |
| **$rm\_output\_file**   | Remove model output file after matching process: **1** – yes, **0** – no |
| **$match\_config**      | Full path to configuration file for matching MADIS variables to model variables. Note that if you are using MM5 with a non-PX surface model, you will have to use **MET\_matching\_nonPX.conf** and change the **$diagnose\_sfc** value to **0.** All MCIP output should use the MCIP configuration file. |


4.  MET Analysis Input Files

The analysis input files are found in
$AMET/scripts\_analysis/wrfExample. The following is a partial list of
variables. Not all of these variables are available in every input file.

<span id="_Toc199841002" class="anchor"></span>Table B‑4. MET analysis input variables

| **Variable**             | **Description** |
|--------------------------|-----------------|
| **acars.only**           | Either plot only ACARS airport sites on site location plot, or include all profile stations: **TRUE** – only ACARS sites, **FALSE** – All sites |
| **ametp**                | Flag to generate figures. |
| **aq\_database**         | Name of air quality database. This is typically the same as the meteorological database (e.g., "**amet**").                                                                                 |
| **aq\_network**          | Air quality network to be plotted. Default from **csh** script.                                                                                                                             |
| **aq\_project**          | Air quality project to be used. Default from **csh** script.                                                                                                                                |
| **aq\_site\_table**      | Table in AMET database that contains metadata of air quality sites.                                                                                                                         |
| **aq\_species\_col**     | Air quality variables to be included in analysis. Default value is from **csh** script.                                                                                                     |
| **checksave**            | Check to see if R datafile exists (i.e., if savefile is activated R datafile is saved, so there is no need to query database).                                                              |
| **colp**                 | Various color specifications for model evaluation metrics.                                                                                                                                  |
| **colpRH**               | Color specifications for model evaluation metrics involving relative humidity.                                                                                                              |
| **colpT**                | Color specifications for model evaluation metrics involving 2‑m temperature.                                                                                                                |
| **colpWS**               | Color specifications for model evaluation metrics involving 10‑m wind.                                                                                                                      |
| **convert**              | ImageMagick command. Used to crop margins of images. This variable has been deprecated.                                                                                                     |
| **date**                 | Either one date used as both starting and ending date (default from **csh** script), or a vector containing starting and ending dates. Format: YYYYMMDD |
| **datee**                | In **met\_aq\_coupled.input**, used to select ending date of analysis. Default uses value from **csh** script. In **summary.input**, used in the plot header to show the ending date used in the analysis. Does not change dates used in analysis. Format: YYYYMMDD |
| **dates**                | In **met\_aq\_coupled.input**, used to select starting date of analysis. Default uses value from **csh** script. In **summary.input**, used in the plot header to show the starting date used in the analysis. Does not change dates used in analysis. Format: YYYYMMDD |
| **Daydelay**             | Used in real-time mode to lag statistics by daydelay days.                                                                                                                                  |
| **De**                   | Ending day of time series analysis. Default uses value from **csh** script.                                                                                                                 |
| **Diurnal**              | Flag to partition and plot statistics as a function of time of day.                                                                                                                         |
| **Ds**                   | Starting day of time series analysis. Default uses value from **csh** script.                                                                                                               |
| **elev**                 | Elevation criterion.                                                                                                                                                                        |
| **extra**                | Additional SQL criterion to use in database query.                                                                                                                                          |
| **extra2**               | Additional SQL criterion to use in database query. This is for the second site in time series plot.                                                                                         |
| **fcasthr**              | Forecast hour criteria used to isolate a particular segment of forecast data.                                                                                                               |
| **figdir**               | Directory where figures will be output. Default value comes from the **csh** script.                                                                                                        |
| **figid\_sub**           | Secondary figure label.                                                                                                                                                                     |
| **figure**               | Full figure path and name.                                                                                                                                                                  |
| **fixed.legend**         | **FALSE** – Use default legend **TRUE** – Use custom legend from **legend.interval**  |
| **he**                   | Ending hour of analysis.                                                                                                                                                                    |
| **histplot**             | Flag to plot histogram of statistics.                                                                                                                                                       |
| **hs**                   | Starting hour of analysis.                                                                                                                                                                  |
| **imageplot**            | Include contours on profile plots: **TRUE** – Contour and shade plot, **FALSE** – Only shade plot |
| **landuse**              | Land use classification criteria for MySQL query.                                                                                                                                           |
| **lat**                  | Latitude specification for MySQL query.                                                                                                                                                     |
| **layer**                | Layer specification for profiler statistics.                                                                                                                                                |
| **layerlab**             | Label for specified layer.                                                                                                                                                                  |
| **layerunit**            | Units for layer statistics.                                                                                                                                                                 |
| **layervar**             | Variable for layer statistics.                                                                                                                                                              |
| **legend.div**           | Number of legend intervals.                                                                                                                                                                 |
| **legend.interval**      | Specific legend intervals.                                                                                                                                                                  |
| **legend.interval.bias** | Legend intervals for mean bias.                                                                                                                                                             |
| **level**                | Level description.                                                                                                                                                                          |
| **levsRH**               | Levels for relative humidity statistics.                                                                                                                                                    |
| **levsT**                | Levels for temperature statistics.                                                                                                                                                          |
| **levsWS**               | Levels for wind speed statistics.                                                                                                                                                           |
| **lon**                  | Longitude specification for query.                                                                                                                                                          |
| **LT.offset**            | Maximum and minimum UTC to local time offset in domain.                                                                                                                                     |
| **max.dist**             | Maximum distance allowed between AQ and MET sites in km.                                                                                                                                    |
| **maxrec**               | Maximum number of records to allow from database query (set to **-1** for unlimited).                                                                                                       |
| **me**                   | Ending month of analysis; default comes from **csh** run script.                                                                                                                            |
| **met\_database**        | MySQL database name that holds meteorological project.                                                                                                                                      |
| **met\_network**         | Meteorological network.                                                                                                                                                                     |
| **met\_project**         | Meteorological project name to be used in analysis. Default uses value from **csh** script.                                                                                                 |
| **met\_site\_table**     | Name of the table that contains meteorological site information.                                                                                                                            |
| **met\_variable\_col**   | Modeled and observational variables of interest. Should be column names from database.                                                                                                      |
| **model**                | AMET project name.                                                                                                                                                                          |
| **model1**               | Primary AMET project for time series plot.                                                                                                                                                  |
| **model2**               | Secondary AMET project for time series plot.                                                                                                                                                |
| **ms**                   | Starting month of analysis; default comes from **csh** run script.                                                                                                                          |
| **obnetwork**            | Network used in analysis. This value is used only in the plot header, and does not affect the analysis.                                                                                     |
| **obtime**               | Times used in analysis. This value is used only in the plot header, and does not affect the analysis.                                                                                       |
| **pheight**              | Plot height in pixels.                                                                                                                                                                      |
| **pid**                  | A separate identification that is attached to the output. Can be used to distinguish between different output subsets for the same project. Default value is input from the **csh** script. |
| **player**               | Logical to plot layer statistics.                                                                                                                                                           |
| **plotfmt**              | File type of output. Default is taken from the **csh** script. Acceptable Values: **png**, **pdf**, **jpg**, or **eps**  |
| **plotSingleProfile**    | Logical (T or F) for generating hourly model-obs wind vector and potential temperature profile plots                                                                                        |
| **plotSiteMap**          | Logical (T or F) for generating a site location plot that can aid in identifying site IDs and locations.                                                                                    |
| **plotsize**             | Scale factor to increase or decrease the size of plots. **1** = 541 x 700 pixel (**png**) or 8.5 x 11 inch (**pdf**)   |
| **processprof**          | Logical to generate profile comparisons.                                                                                                                                                    |
| **prof**                 | Logical (**T** or **F**) for plotting raob-model profile comparison.                                                                                                                        |
| **proflim**              | Lower and upper limit of profile plot.                                                                                                                                                      |
| **project**              | AMET project name to be used in analysis. Default value is taken from **csh** run script.                                                                                                   |
| **pwidth**               | Width of plot.                                                                                                                                                                              |
| **qcQ**                  | Quality control limits of moisture data. (*Note:* All data outside of this range are not considered.)                                                                                       |
| **qcT**                  | Quality control limits of temperature data.                                                                                                                                                 |
| **qcWS**                 | Quality control limits of wind speed data.                                                                                                                                                  |
| **query**                | MySQL query.                                                                                                                                                                                |
| **queryID**              | A separate identification that is attached to the output. Can be used to distinguish different output subsets for the same project. Default value is transferred from **pid**.              |
| **querystr**             | Additional SQL criteria that can be used to subset the data used by the analysis. Default value is transferred from the run script.                                                         |
| **realtime**             | Run script in real-time automated mode.                                                                                                                                                     |
| **savedir**              | Directory in which plots and other output will be saved. Default value is input from **csh** script.                                                                                        |
| **savefile**             | Logical to generate an R data file that contains the data used in the statistics plots.                                                                                                     |
| **saveid**               | Name of R data file.                                                                                                                                                                        |
| **scex**                 | Scale factor for statistics text size.                                                                                                                                                      |
| **shadeplot**            | Flag to plot shaded statistics plot in addition to point statistics plot.                                                                                                                   |
| **sres**                 | Resolution of shaded plot in degrees.                                                                                                                                                       |
| **statid**               | In **timeseries\_plot**, the site ID to be used in the analysis. Default value is taken from the **csh** script. In **summary\_plot**, the station label to be used in labeling the plot.  |
| **symb**                 | Symbol shape to be used in plots. See R documentation for shape numbers.                                                                                                                    |
| **symbo**                | Plot symbol.                                                                                                                                                                                |
| **symbsiz**              | Scale factor to adjust size of symbols on plots. **0.5** is very small while **1.5** is large.                                                                                                                                                |
| **syncond**              | This variable has been deprecated.                                                                                                                                                          |
| **t.test.flag**          | Logical to apply statistical significance test to the spatial statistics. If it is applied and the model and observation data are not different statistically, the values are not plotted.  |
| **textout**              | Logical to write text output of statistics and underlying data.                                                                                                                             |
| **textstats**            | Logical to write text file of statistics.                                                                                                                                                   |
| **thresh**               | Used in spatial surface to identify the minimum number of data points required at a particular site to compute the statistics.                                                              |
| **time.of.day.utc**      | Range of time (UTC) to isolate met and AQ data (e.g., compare average temperature and average PM for hours between 6 and 12 UTC).                                                           |
| **tserieslen**           | Length in days of time series if real-time mode is activated.                                                                                                                               |
| **uniquepnum**           | Unique plot number (random).                                                                                                                                                                |
| **wantfigs**             | Flag to generate figures.                                                                                                                                                                   |
| **wantsave**             | Flag to save station statistics data in R data file.                                                                                                                                        |
| **wdweightws**           | Logical to weight wind direction statistics by the wind speed (e.g., if wind speed falls below 3 m/s, the difference between model and observed wind direction is mitigated).               |
| **ye**                   | Ending year of analysis default; comes from the **csh** script.                                                                                                                             |
| **ys**                   | Starting year of analysis default; comes from the **csh** script.                                                                                                                           |
| **zlims**                | Specification of lower and upper vertical level of profile.                                                                                                                                 |

5.  AQ Analysis Input Files

The analysis input files are found in $AMET/scripts\_analysis/aqExample/input\_files.
The following is a partial list of variables in the AQ analysis input
files. Not all of these variables are available in every input file.

<span id="_Toc199841003" class="anchor"></span>Table B‑5. AQ analysis input variables

| **Variable**             | **Description** |
|--------------------------|-----------------|
| **abs\_error\_max**      | Specify the maximum value for the axis on the absolute error plot from the **run\_stats\_plots.csh** script. **NULL**” – script defined limit |
| **abs\_rang\_min**       | Specify the minimum value for the absolute value axis on spatial plots. **NULL**” – script defined limit |
| **abs\_range\_max**      | Specify the maximum value for the absolute value axis on spatial plots. **NULL**” – script defined limit |
| **add\_query**           | Additional query syntax to add to the MySQL query. |
| **aq\_database**         | AQ MySQL database. Most likely “**amet**”. |
| **aq\_network**          | AQ monitoring network. |
| **aq\_project**          | AQ project name. |
| **aq\_site\_table**      | AQ monitoring site MySQL table. Most likely “**site\_metadata**”.|
| **aq\_species\_col**     | AQ variables, column names, from AQ project table. |
| **avg\_func**            | Specify the type of averaging to use for the time series plot. Acceptable values are **mean**, **median** or **sum** |
| **averaging**            | Average across time: “**n**” – no averaging (default), “**s**” – seasonal averaging (DJF; MAM; JJA; SON), “**m**” – monthly averaging, “**h**” – hourly averaging, “**a**” – entire time period averaging |
| **axis\_max\_limit**     | Axis (x and y) max limit: “**NULL**” – script-defined limit |
| **axis\_min\_limit**     | Axis (x and y) min limit: “**NULL**” – script-defined limit |
| **bias\_range\_max**     | Bias range max limit: “**NULL**” – script-defined limit |
| **bias\_range\_min**     | Bias range min limit: “**NULL**” – script-defined limit |
| **bias\_y\_axis\_min**   | Specify the minimum value for the y-axis on a bias plot. **NULL**” – script defined limit |
| **bias\_y\_axis\_max**   | Specify the maximum value for the y-axis on a bias plot. **NULL**” – script defined limit |
| **Bldoverlay\_exe**      | The location of the **bldoverlay** Fortran executable. Most likely **$AMETBASE/bin/bldoverlay**. (AQ only) |
| **conf\_line**           | Add confidence lines to scatterplots: “**y**” or “**n**”. |
| **coverage\_limit**      | **%** necessary for data completeness (e.g., **75** means 75% data completeness). |
| **custom\_title**        | Custom title for plots: ““ – no custom title |
| **datee**                | End date of query, YYYYMMDD format (**met\_aq\_coupled.input** only). |
| **dates**                | Start date of query, YYYYMMDD format (**met\_aq\_coupled.input** only). |
| **diff\_range\_max**     | Difference range max limit: “**NULL**” – script defined limit |
| **diff\_range\_min**     | Difference range min limit: “**NULL**” – script defined limit |
| **end\_date**            | End date of query, YYYYMMDD format. |
| **end\_hour**            | End hour of query, HH format.|
| **error\_range\_max**    | Error range max limit: “**NULL**” – script defined limit  |
| **figdir**               | Output directory for plots.|
| **greyscale**            | Option to use greyscale for the spatial plots:  “**y**” or “**n**”. |
| **inc\_counties**        | Option to include county borders on spatial plots:  “**y**” or “**n**”. |
| **inc\_FRM\_adj**        | Include FRM adjustment on stacked bar plots. Most users will set this to  “**n**”. Advanced users that calculated the FRM adjusted values for the CSN network may set this to  “**y**”. Default is  “**n**”. |
| **inc\_legend**          | Include the legend on the time series plots: “**y**” or “**n**”. |
| **inc\_median\_lines**   | Include median lines on box plots: “**y**” or “**n**”. |
| **inc\_median\_points**  | Include median points on box plots: “**y**” or “**n**”. |
| **inc\_ranges**          | Include quartile ranges on box plots: “**y**” or “**n**”. |
| **inc\_points**          | Include point symbols on the time series plot: “**y**” or “**n**”. |
| **line\_width**          | Specify the line width for the time series plot (default is 1). Smaller number result is a thinner line, while larger numbers result in a thicker line. |
| **inc\_whiskers**        | Include whiskers on the box plots: “**y**” or “**n**”. |
| **map\_leg\_size**       | Map legend size factor. Default is 0.65. |
| **median**               | Statistical averaging method to use for stacked barplot: **TRUE** – median, **FALSE** – mean |
| **num\_ints**            | The number of color intervals to use for spatial plots. The script will ultimately determine the number of intervals, but **num\_ints** can be set to increase or decrease the number of intervals. |
| **num\_obs\_limit**      | Specifies the minimum number of model/obs pairs per unit time (e.g day) required to do any site calculation. This can be used to eliminate days when only a small number of sites are available. |
| **obs\_per\_day\_limit** | Specifies the minimum number of model/obs pairs per unit time (e.g day) required to do any site calculation for the time series plot. This can be used to eliminate days when only a small number of sites are available. |
| **overlay\_opt**         | PAVE/VERDI overlay times: **1** – hourly, **2** – daily, **3** – 1-hr daily max, **4** – 8-hr daily max |
| **perc_error_max**       | Specify the maximum value for the axis on the percent error plot from the run_stats.csh script. **NULL**” – script defined limit |
| **perc_range_min**       | Specify the minimum value for the axis on the percent bias plot from the run_stats.csh script. **NULL**” – script defined limit |
| **perc_range_max**       | Specify the maximum value for the axis on the percent bias plot from the run_stats.csh script. **NULL**” – script defined limit |
| **pid**                  | Project name; must be unique across both MET and AQ.|
| **plot\_colors**         | Scatter plot symbol colors for primary simulation. |
| **plot\_colors2**        | Scatter plot symbol colors for secondary simulation. |
| **plot\_symbols**        | Specify, by R symbol number, the order of plot symbols to use. 0-square; 1-circle; 2-triangle point up; 3-plus; 4-cross; 5-diamond; 6-triangle point down; 7-square cross; 8-star; 9-diamond plus; 10-circle plus; 11-triangles up and down; 12-square plus; 13-circle cross; 14-square and triangle down; 15-filled square; 16-filled circle; 17-filled triangle point-up; 18-filled diamond; 19-solid circle; 20-bullet (smaller circle); 21-filled circle blue; 22-filled square blue; 23-filled diamond blue; 24-filled triangle point-up blue; 25- filled triangle point down blue |
| **plotfmt**              | Plot format, output type: “**PDF**” – pdf format, “**PNG**” – png format, “**BOTH**” – both pdf and png formats
| **plotsize**             | Scale factor to increase or decrease the size of a 541 x 700 pixel (**png**) or 8.5 x 11 inch (**pdf**) plot. |
| **query**                | MySQL query to select data from database. In most cases, this is only part of the query. The complete query is constructed in the corresponding R script. |
| **remove\_mean**         | Remove the observation/model mean statistics calculation, thereby just calculating the difference from the mean value |
| **remove\_negatives**    | Remove negative values: “**y**” or “**n**”. default = “**y**”. |
| **remove\_other**        | Remove “PM other” category from stacked bar plot analysis. |
| **rmse\_range\_max**     | **RMS Error** range max limit: “**NULL**” – script defined limit |
| **run\_info\_text**      | Include model run info as additional text to plots: “**y**” or “**n**”  |
| **run\_name1**           | Project name; must be unique across AQ and MET.  |
| **run\_name2**           | Second project name (allowed only in some scripts).|
| **run\_name\***          | Additional project names (allowed only in some scripts). |
| **site**                 | Plot label for when you are including only certain sites. Note that you will need to use an additional query to actually subset the data to these sites. |
| **soccerplot\_opt**      | Flag for soccer and bugle plot options: **1** – normalized mean bias/error, **2** – fractional bias/error|
| **species**              | Chemical species to plot. |
| **start\_date**          | Start date of query, YYYYMMDD format. |
| **start\_hour**          | Start hour of query, HH format. |
| **state**                | Plot label for indicating certain states. Note that you will need to use an additional query to actually subset the data to these states.|
| **stat\_file**           | File containing specific list of stations to analyze. User-defined. |
| **stats\_flags**         | Flags to determine which statistics are included on the **run\_scatterplot.csh** script. Up to five statistics can be included, and are indicated by a ‘**y**’. Unused statistics are left blank. The order of the statistics flags is: **index of agreement (IA), correlation (r), RMSE, systematic RMSE, unsystematic RMSE, NMB, NME, Normalized Median Bias, Normalized Median Error, Mean Bias, Mean Error, Median Bias, Median Error, Fractional Bias, Fractional Error** |
| **symb**                 | Plot symbol: **15** – square, **19** – circle |
| **symbo**                | Plot symbol.|
| **symbsizfac**           | Plot symbol size: (**0.5** very small to **1.5** large). A value of **1** is recommended for most applications. |
| **textstats**            | Produce text statistics file: **TRUE** or **FALSE**.  |
| **use\_avg\_stats**      | Use time-averaged statistics: “**y**” or “**n**”. |
| **use\_median**          | Use median instead of mean for stacked bar plots: “**y**” or “**n**”. |
| **use\_var\_mean**       | Remove the observation/model mean value from the time series plots, thereby only plotting the variation from the mean: “**y**” or “**n**”. |
| **valid\_only**          | Flag to include only valid observations from the NADP network |
| **x\_axis\_min**         | Specify the minimum value for the x-axis on a plot. **NULL**” – script defined limit |
| **x\_axis\_max**         | Specify the maximum value for the x-axis on a plot. **NULL**” – script defined limit |
| **y\_axis\_min**         | Specify the minimum value for the y-axis on a plot. **NULL**” – script defined limit |
| **y\_axis\_max**         | Specify the maximum value for the y-axis on a plot. **NULL**” – script defined limit |
| **zeroprecip**           | Include zero-precipitation obs: “**y**” or “**n**” (typically set to “**n**”). |

6.  AQ Network Input File

In addition to the analysis input files which are script specific, AMET
makes use of the input file
**$AMET/scripts\_analysis/aqExample/input_files/Network.input**. This file allows
all of the network-specific processing to be handled in one location,
and allows for easier addition of new networks into the analysis
scripts. This file does not need to be modified unless adding new AQ networks to AMET.

7. AQ Species List Input File


