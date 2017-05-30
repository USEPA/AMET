#!/usr/bin/perl
##------------------------------------------------------
#       AMET    Database Setup Script                   #
#                                                       #
#       PURPOSE: sets up the metadata tables for MET    #
#                                                       #
#       Rob Gilliam, initial version                    #
#       Oct, 2007 Alexis Zubrow, modified for AQ/MET    #
#                                                       #
#--------------------------------------------------------

## Before anything else, get the AMETBASE variable and source
## the file containing MYSQL login and location information
## Note: need perl_lib before add other packages
BEGIN{
    $amet_base = $ENV{'AMETBASE'} 
       or die "Must set AMETBASE environmental variable\n";
    require "$amet_base/configure/amet-config.pl";      

    $dbase = $ENV{'AMET_DATABASE'}
       or die "Must set AMET_DATABASE environmental variable\n"; 
}

# LOAD Required Perl Modules
use lib $perl_lib;                                      # Add custom perl package path
use Mysql;                                              # Use MYSQL perl package
use CGI;                                                # Use CGI perl package
use DBI;                                                # Use DBI perl package



## Get a couple of environmental variables
$amet_perl_input = $ENV{'AMETPERLINPUT'}
    or die "Must set AMETPERLINPUT environmental variable\n";

## load site file info
require $amet_perl_input;

########################################################################################################################################################
### REQUIRED AMET metadata TABLES

                          

my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass)  
    or die "Your MySQL server was not found or login or passwords incorrect, please check to see if server is running or passwords are correct.\n";

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Create new project log and site metadata tables if running AMET for the first time
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
print "\nCreating the required tables (project_log and stations metadata)\n";

## stations
$q="create table stations  (stat_id VARCHAR(10) UNIQUE KEY, ob_network VARCHAR(20),  lat FLOAT(8,4), lon FLOAT(8,4), i INTEGER(4), j INTEGER(4), elev FLOAT(8,2), landuse  INTEGER(2), common_name VARCHAR(80), state VARCHAR(2), country VARCHAR(30))";
print "Creating AMET MET stations table. \n\n";
$table_query	= $dbh->Query($q) or print "The AMET stations tables already exists, so it will not be regenerated\n";

## project log
$q="create table project_log (proj_code VARCHAR(30), model VARCHAR(10), user_id VARCHAR(20), passwd VARCHAR(20), email VARCHAR(30), description TEXT, proj_date TIMESTAMP(8), proj_time time, min_date TIMESTAMP(8), max_date TIMESTAMP(8))";
print "Creating AMET MET project log table. \n\n";
$table_query	= $dbh->Query($q) or print "The AMET project_log tables already exists, so it will not be regenerated\n";
$q="alter table project_log add UNIQUE(proj_code)";
$table_query	= $dbh->Query($q) or print "The AMET stations tables already exists, so it will not be modified\n";
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

## Populate the stations table from the csv file
print "Populating stations table with information from $site_file \n";
$q = "LOAD DATA LOCAL INFILE '$site_file' INTO TABLE stations FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'";
$table_query = $dbh->Query($q) 
    or die "Unable to populate stations metadata table with station specific data\n";



exit(0);

