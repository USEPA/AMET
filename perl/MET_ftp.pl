#!/usr/bin/perl
#				amet_matching.pl
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
#_____________________________________________________________________________________________
#_______________________________________________________________________________
#								
#	Automated Meteorological Evaluation Tool		
#								
#	FTP Downloading script
#
#	NOAA/ARL/ASMD and US EPA				
#								
#   Version 1.0 Initial development, Neil Davis (IE UNC-CH), Feb 2008
#
#______________________________________________________________________________
#
# PURPOSE:	Download madis data from FTP site
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________


## Before anything else, get the AMETBASE variable and source
## the file containing MYSQL login and location information
## Note: need perl_lib before add other packages
BEGIN{
    $amet_base = $ENV{'AMETBASE'} 
       or die "Must set AMETBASE environmental variable\n";
    require "$amet_base/configure/amet-config.pl";       
}

## get some environmental variables
# PERL INPUT FILE - same as for matching script
$amet_perl_input = $ENV{'AMETPERLINPUT'} 
	or die "Must set AMETPERLINPUT environmental variable\n";
# Starting date for download
$date_start = $ENV{'AMET_DATE_START'}
	or die "Must set AMET_DATE_START environmental variable\n";
# Number of days to download
$num_days = $ENV{'AMET_NUM_DAYS'}
	or die "Must set AMET_NUM_DAYS environmental variable\n";

## Path to perl code
$amet_perl = "$amet_base/perl";

## Get user defined variables from perl input
require $amet_perl_input;

# LOAD Required Perl Modules
use lib $perl_lib;
use Date::Calc qw(:all);

# LOAD required subroutines from AMET 
require "$amet_perl/MET_init_amet.pl";
require "$amet_perl/MET_obs_util.pl";

# If a real-time run, make sure the output file is not accidentally deleted
if($real_time eq 1) {   $rm_output_file=0;	}

# Print executing messages
print "\n\n ************************  Starting the Execution of AMET  ********************************\n\n";

####################################################################################################################
# Automatically ftp observations from MADIS archive
####################################################################################################################

# convert number of days to number of hours used by script
$num_hours = ($num_days * 24);
print "Getting MADIS data via ftp... \n";

# Call auto_ftp subroutine from MET_obs_util.pl
&auto_ftp($eval_class,$date_start,$num_hours,$obs_dir,"ftp");

## Option to Process NPA Precipitation (e.g. interpolate observed precipitation to model grid and produce grid files)
if($process_npa){
	&gen_npa($model_file);
}
        ####################################################################################################################

exit(0);
##############################################################################
##############################################################################
