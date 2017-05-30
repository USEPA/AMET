#!/usr/bin/perl
##------------------------------------------------------
#       AMET Database Setup Script                      #
#                                                       #
#       PURPOSE: Deletes a MET project                  #
#                                                       #
#       Author:  Alexis Zubrow, IE UNC                  # 
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


## miscellaneous subroutines
require "$amet_base/perl/misc_AMET_subroutines.pl";

##---------------------------------------##


## Make a DB connection
my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass) 
    or die "Unable to connect to MySQL database $dbase.  Check server, user and/or passwords.\n";	

## Ask user which project
my $pid = &promptUser("Project to delete"); print "\n";

## Check if they want to delete the project
print "WARNING, WARNING!! \n";
print "\tDeleting the project will destroy all the data in the project\n"; 
$delete_proj = &promptUser("Delete from database, $dbase, the project: $pid (yes or no)? ","no");print "\n"; 
if ($delete_proj eq "yes" ){
    print "Removing $pid from project_log\n";
    $q="delete from project_log where proj_code = '$pid'";
    $table_query = $dbh->Query($q) or
	die "Failed to remove from project_log\n";
    print "Removing $pid tables\n";
    $q="drop table $pid\_surface";
    $table_query = $dbh->Query($q) or
	die "Failed to remove table\n";
    $q="drop table $pid\_profiler";
    $table_query = $dbh->Query($q) or
	die "Failed to remove table\n";
    $q="drop table $pid\_raob";
    $table_query = $dbh->Query($q) or
	die "Failed to remove table\n";

} else{
    print "Not deleting project: $pid \n";
}

    
exit
