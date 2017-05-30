#!/usr/bin/perl
##------------------------------------------------------
#	Surface Station Update Script                        #
#                                                      #
#	PURPOSE: To update the surface station               #
#          database information (id,lat,lon,elev)      #
#                                                      #
#       Oct, 2007 Alexis Zubrow, modified for AQ/MET   #
#                                                      #
#-------------------------------------------------------
#   Version 1.2 No Updates other than code reformatting, Rob Gilliam (05-01-2013)


## test # of arguments
if ($#ARGV != 0) {
  die "Must pass a station csv file.\n";
}

$stations_csv=$ARGV[0];		## stations CSV file, from command line

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

print "Updating AMET stations MYSQL table\n";
#-------------------------------------------------------
## Connect to db
my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass)  
    or die "Your MySQL server was not found or login or passwords incorrect, please check to see if server is running or passwords are correct.\n";

## Populate the stations table from the csv file
print "Populating stations table from csv file: $stations_csv\n";
$q = "LOAD DATA LOCAL INFILE '$stations_csv' INTO TABLE stations FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'";
$table_query = $dbh->Query($q) 
    or die "Unable to populate stations metadata table with station specific data\n";
exit(0);
