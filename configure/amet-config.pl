##################################################################
## Filename: amet-config.pl                                     ##
##                                                              ##
## This file is required by the Perl scripts                    ##
##                                                              ##
## This file provides necessary MYSQL information to the file   ##
## above so that data from Site Compare can be added to the     ##
## system's MYSQL database.                                     ## 
##################################################################

##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## Top of AMET directory tree
##   - this could be hard coded, but we're assuming that 
##     you've set an environmental variable in the scripts
$amet_base = $ENV{'AMETBASE'}; 

##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## MySQL Configuration
$mysql_server="localhost"; # MYSQL server name
$root_login="ametsecure";  # AMET MYSQL login
$root_pass='xxxxxx';       # AMET MYSQL login password
$dbase=$ENV{'AMET_DATABASE'};	# User defined database to be used for AMET
##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## Perl configuration
$perl_lib = "/usr/local/lib/perl"; ## additional location of perl libaries

##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## R executable path
$R_dir = "/usr";         # Base directory where R is installed
$R_exe = "$R_dir/bin/R"; # Location of the main R executable
$R_lib = "/usr/local/pkgs/Rpackages:$R_dir/lib/R/site-library"; # Location of the R library
##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

## AQ Site Compare Configuration
$EXEC_aqs       = "/project/model_eval/bin/cmp_airs.exe";                    # full path to 32 bit version of compare airs executable
$EXEC_all       = "/project/model_evalb/extract_util/bin/sitecmp.exe";       # full path to 32 bit version of site compare executable
$EXEC_cmp_cast	= "$amet_base/bin/cmp_castnet.exe";	# full path to compare castnet exectuable
$obs_data_dir	= "$amet_base/obs/AQ/NA_Data";	 # full path location of AQ obs data

##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## FTP Configuration
## MADIS
$fslftp_madis="pftp.madis-fsl.org"; # Remote FSL server
$login_madis="xxxxxx";   # login - user must get from MADIS 
$pass_madis="xxxxx";     # Passwd - user must get from MADIS

##NCEP
$fslftp_ncep ="ftpprd.ncep.noaa.gov"; # Remote NCEP Server that stores 4 days of NPA data
$login_ncep ="anonymous";             # anonymous login
$pass_ncep  ="xxxx\@xxxxx";           # anonymous email (your email)

##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## Debugging (yes,no)
$amet_verbose = "yes";

