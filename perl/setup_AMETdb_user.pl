#!/usr/bin/perl
##------------------------------------------------------
#       AMET Database Setup Script                      #
#                                                       #
#       PURPOSE: Sets up a database and an amet         #
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



## mysql root info
$mysql_root_login	=&promptUser("Enter the MYSQL root user ","root");print "\n";
$mysql_root_pass	=&promptUser("Enter the MYSQL root user password ");print "\n";

# Connect to MySQL database and Set AMET Passwords ametsecure (for read and write ability to database)
my $dbh = Mysql->Connect($mysql_server,"mysql",$mysql_root_login,$mysql_root_pass)
                          or die "Your MySQL server was not found or login or passwords incorrect, please check to see if server is running or passwords are correct.\n";

## Add the ametsecure user w/ full privileges, assumes MYSQL v4.0 or greater
print "Creating or modifying user ($root_login)\n";

$q="REPLACE INTO mysql.user (Host,User,Password,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv,Grant_priv,Alter_priv) VALUES('%','$root_login',PASSWORD('$root_pass'), 'Y','Y','Y','Y','Y','Y','Y','Y')";
$table_query    = $dbh->Query($q) or 
    print "Failed to create new user\n";
$q="FLUSH PRIVILEGES";
$table_query    = $dbh->Query($q);

## Create a new database
print "Creating new database ($dbase)\n";
$q="create DATABASE $dbase";
$table_query    = $dbh->Query($q) or 
    print "The AMET database already exists, so it will not be regenerated\n";

