#!/usr/bin/perl
##------------------------------------------------------
#       AMET AQ Database Table Creation                 #
#                                                       #
#       PURPOSE: To create a MYSQL table usable for     #
#               the AMET-AQ system                      #
#							#
#       Last Update: 08/20/2007 by Wyat Appel           #
#--------------------------------------------------------

## Before anything else, get the AMETBASE variable and source
## the file containing MYSQL login and location information
## Note: need perl_lib before add other packages

## Updated May 1, 2013: Changed lines 61, 69 and 77. TIMESTAMP(8) to TIMESTAMP because
## R. Gilliam           new version of MySQL eliminated the specific 8 digit option. 

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

## get some environmental variables
$amet_perl_input = $ENV{'AMETPERLINPUT'}
    or die "Must set AMETPERLINPUT environmental variable\n";

require $amet_perl_input;        ## Perl input file, user defined variables

## Make a DB connection
my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass) 
    or die "Unable to connect to MySQL database $dbase.  Check server, user and/or passwords.\n";	


## New project query

## Get date for project creation timestamp
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
$year = $year+1900;
$mday = sprintf("%02d",$mday);
$mon  = sprintf("%02d",$mon+1);
$hour = sprintf("%02d",$hour);
$min  = sprintf("%02d",$min);
$sec  = sprintf("%02d",$sec);
$proj_date = "$year$mon$mday";
$proj_time = "$hour:$min:$sec";


## update project log
$q="REPLACE into project_log VALUES('$run_id','$model','$login','pass','$email','$description','$proj_date','$proj_time',0,0)";
print "Inserting new project information into project_log table...\n";
$table_query	= $dbh->Query($q) 
    or die "Unable to update the project_log table for project: $run_id\n";

## Create 3 tables for the project id: surface, raob, profiler
print "Creating project specific tables...\n";
print "    Generating $run_id surface table\n";
$q="create table $run_id\_surface (proj_code VARCHAR(40), model VARCHAR(10), ob_network VARCHAR(20), stat_id VARCHAR(10), i FLOAT(8,3), j FLOAT(8,3), landuse  INTEGER(2), ob_date TIMESTAMP, ob_time  time, fcast_hr  INTEGER(4), init_utc INTEGER(2), var_id VARCHAR(10), level FLOAT(8,2), T_ob FLOAT(10,3)  , T_mod FLOAT(10,3)  , Q_ob FLOAT(10,6)  , WVMR_ob FLOAT(10,6)  , Q_mod FLOAT(10,6) , U_ob FLOAT(10,3), U_mod FLOAT(10,3), V_ob FLOAT(10,3), V_mod FLOAT(10,3), PCP1H_ob FLOAT(10,6), PCP1H_mod FLOAT(10,6), SRAD_ob FLOAT(10,3), SRAD_mod FLOAT(10,3), pblh FLOAT(10,5), monin FLOAT(10,5), ustar FLOAT(10,5)) ";
print "$q \n";
$table_query	= $dbh->Query($q);
$q="alter table $run_id\_surface add UNIQUE(ob_date,ob_time,stat_id,fcast_hr,init_utc) ";
$table_query	= $dbh->Query($q)
    or die "Failed to create project table $run_id\_surface \n";

print "    Generating $run_id raob table\n";
$q="create table $run_id\_raob ( stat_id VARCHAR(10), lat FLOAT(8,4), lon FLOAT(8,4), elev FLOAT(8,2), landuse  INTEGER(2), ob_date TIMESTAMP, ob_time  time, fcast_hr  INTEGER(4), init_utc INTEGER(2), plevel FLOAT(8,2), slevel FLOAT(8,3), hlevel FLOAT(8,3), v1_id VARCHAR(5), v2_id VARCHAR(5), v1_ob FLOAT(10,3)  , v1_mod FLOAT(10,3),  v2_ob FLOAT(10,3), v2_mod FLOAT(10,3) ) ";
$table_query	= $dbh->Query($q);
$q="alter table $run_id\_raob add UNIQUE(ob_date,ob_time,stat_id, slevel, fcast_hr, init_utc, v1_id) ";
$table_query	= $dbh->Query($q)
    or die "Failed to create project table $run_id\_raob \n";


print "    Generating $run_id profiler table\n";
$q="create table $run_id\_profiler (proj_code VARCHAR(40), stat_id VARCHAR(10), i FLOAT(8,3), j FLOAT(8,3), landuse  INTEGER(2), ob_date TIMESTAMP, ob_time  time, fcast_hr  INTEGER(4), init_utc INTEGER(2), plevel FLOAT(8,2), slevel FLOAT(8,3), hlevel FLOAT(8,3), T_ob FLOAT(10,3)  , T_mod FLOAT(10,3),  U_ob FLOAT(10,3), U_mod FLOAT(10,3), V_ob FLOAT(10,3), V_mod FLOAT(10,3), W_ob FLOAT(10,3), W_mod FLOAT(10,3), usd FLOAT(10,5), vsd FLOAT(10,5), wsd FLOAT(10,5), PBL_mod FLOAT(10,5), PBL_ob FLOAT(10,5), SNR FLOAT(8,2)  ) ";
$table_query	= $dbh->Query($q);
$q="alter table $run_id\_profiler add UNIQUE(ob_date,ob_time,stat_id, slevel, fcast_hr, init_utc)";
$table_query	= $dbh->Query($q)
    or die "Failed to create project table $run_id\_profiler \n";


## Success
exit;

