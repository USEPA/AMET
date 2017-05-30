#!/usr/bin/perl
##------------------------------------------------------
#       AMET Database Setup Script                      #
#                                                       #
#       PURPOSE: Deletes a database and an amet         #
#                user for both MET and AQ               #
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
}

$dbase        = $ENV{'AMET_DATABASE'};

# LOAD Required Perl Modules
use lib $perl_lib;                                      # Add custom perl package path
use Mysql;                                              # Use MYSQL perl package
use CGI;                                                # Use CGI perl package
use DBI;                                                # Use DBI perl package


## miscellaneous subroutines
require "$amet_base/perl/misc_AMET_subroutines.pl";

##---------------------------------------##


## mysql root info
$mysql_root_login	=&promptUser("Enter the MYSQL root user ","root");print "\n";
$mysql_root_pass	=&promptUser("Enter the MYSQL root user password ");print "\n";

# Connect to MySQL database and Set AMET Passwords ametsecure (for read and write ability to database)
my $dbh = Mysql->Connect($mysql_server,"mysql",$mysql_root_login,$mysql_root_pass)
                          or die "Your MySQL server was not found or login or passwords incorrect, please check to see if server is running or passwords are correct.\n";

## Check if they want to delete the database
print "WARNING, WARNING!! \n";
print "\tDeleting the database will destroy the data in all MET and AQ projects\n"; 
$delete_db = &promptUser("Delete the database: $dbase (yes or no)? ","no");print "\n"; 
if ($delete_db eq "yes" ){
    print "Deleting database: $dbase \n";
    $q="drop DATABASE $dbase";
    $table_query    = $dbh->Query($q) or 
	die "Failed to delete database\n";
} else{
    print "Not deleting database: $dbase \n";
}


## Check if they want to delete the user
print "WARNING, WARNING!! \n";
print "\tDeleting the user will mean that you can't access data through this user\n";
$delete_user = &promptUser("Delete the user: $root_login (yes or no)? ","no");print "\n"; 
if ($delete_user eq "yes" ){
    print "Deleting $root_login \n";
    $q = "delete from mysql.user where user='$root_login'";
    $table_query    = $dbh->Query($q) or 
	print "Failed to delete user\n";
    $q="FLUSH PRIVILEGES";
    $table_query    = $dbh->Query($q);
} else{
    print "Not deleting user: $root_login\n";
}
    
exit
