#!/usr/bin/perl
#______________________________________________________________________________________________
# TITLE: 	Update Amet Project Table
# PURPOSE:	Updates start and end dates of realtime projects
#		
# BY: Rob Gilliam, NOAA/ARL/ASMD
#
#   Reorganized to work in combined MET/AQ mode, Alexis Zubrow (IE UNC-CH), Oct 2007
#
#   Version 1.2 Update. Only code reformatting, Rob Gilliam (05-01-2013)
#
#______________________________________________________________________________________________

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


#-----------------------------------------------------------------------------------------------------------------
my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass)
           or die "Unable to connect to MySQL database $dbase.  Check server, user and/or passwords.\n";	
$query="select proj_code from project_log";
$rv1 = $dbh->Query($query)
         or die "Unable to get project IDs from MYSQL project_log\n";
	
$i=0;
while(@row = $rv1->fetchrow_array) {
   $proj_code=$row[0];

   ## Get min and max date/time for each projects surface data
   $qcheck="select min(ob_date),max(ob_date) from ".$proj_code."_surface";
   $rv2 = $dbh->Query($qcheck);
   while(@row= $rv2->fetchrow_array) {
     $min=$row[0];
     $max=$row[1];
     print "Updating the project_log's date range for project $proj_code min= ".$min."    max= ".$max."  \n";
   }
   ## add min and max to project_log for this project
   $qinsert= "UPDATE project_log SET max_date='".$max."' where proj_code='".$proj_code."' ";
   $rv3 = $dbh->Query($qinsert);
   $qinsert= "UPDATE project_log SET min_date='".$min."' where proj_code='".$proj_code."' ";
   $rv3 = $dbh->Query($qinsert);	
}
#-----------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------

