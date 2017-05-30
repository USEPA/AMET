#!/usr/bin/perl
##------------------------------------------------------
#       AMET    Database Setup Script                   #
#                                                       #
#       PURPOSE: sets up the metadata tables for AQ     #
#                                                       #
#       05/02/2006 Wyat Appel, initial version          #
#       Sept, 2007 Alexis Zubrow, modified for AQ/MET   #
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




########################################################################################################################################################
### REQUIRED AMET metadata TABLES

                          

my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass)  
    or die "Your MySQL server was not found or login or passwords incorrect, please check to see if server is running or passwords are correct.\n";

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Create new project log, units and site metadata tables if running AMET for the first time
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
print "\nCreating the required tables (aq_project_log, site_metadata, and project_units)\n";

## queries
## project units
$aq_new_1="create table project_units (proj_code varchar(50), network varchar(25), SO4 varchar(10), NO3 varchar(10), NH4 varchar(10), SO4_dep varchar(10), NO3_dep varchar(10), NH4_dep varchar(10), Cl_dep varchar(10), SO4_conc varchar(10), NO3_conc varchar(10), NH4_conc varchar(10), Cl_conc varchar(10), Ca_conc varchar(10), Ca_dep varchar(10), Mg_conc varchar(10), Mg_dep varchar(10), K_conc varchar(10), K_dep varchar(10), SO4_ddep varchar(10), NO3_ddep varchar(10), NH4_ddep varchar(10), HNO3_ddep varchar(10), TNO3_ddep varchar(10), O3_ddep varchar(10), SO2_ddep varchar(10), PM25 varchar(10), EC varchar(10), OC varchar(10), TC varchar(10), HNO3 varchar(10), TNO3 varchar(10), NO varchar(10), SO2 varchar(10), SO2_adj varchar(10), O3 varchar(10), O3_1hrmax varchar(10), O3_8hrmax varchar(10), O3_1hrmax_9cell varchar(10), O3_8hrmax_9cell varchar(10), O3_1hrmax_time varchar(10), O3_8hrmax_time varchar(10), W126 varchar(10), CO varchar(10), HG varchar(10), HGconc varchar(10), HGdep varchar(10), precip varchar(10), RH varchar(10), SFC_TMP varchar(10), Solar_Rad varchar(10), WSPD10 varchar(10), WDIR10 varchar(10), EXT varchar(10), AORGAT varchar(10), AORGPAT varchar(10), AORGBT varchar(10), H2O2 varchar(10), HOx varchar(10), CL varchar(10), NA varchar(10), PM25_SOC varchar(10), PM25_POC varchar(10), ASOCT varchar(10), PM25_SO4 varchar(10), PM25_NO3 varchar(10), PM25_NH4 varchar(10), PM25_TNO3 varchar(10), PM25_TC varchar(10), PM25_EC varchar(10), PM25_OC varchar(10), PM25_TOT varchar(10), PM25_Cl varchar(10), PM25_Na varchar(10), PMC_SO4 varchar(10), PMC_NO3 varchar(10), PMC_NH4 varchar(10), PMC_TOT varchar(10), PMC_Cl varchar(10), PMC_Na varchar(10), PM_TOT varchar(10), Acrolein varchar(10), ALD2 varchar(10), Benzene varchar(10), FORM varchar(10), Lead_PM10 varchar(10), Lead_PM25 varchar(10), Manganese_PM10 varchar(10), Manganese_PM25 varchar(10), Nickel_PM10 varchar(10), Nickel_PM25 varchar(10), TOLU varchar(10), PM_FRM varchar(10), PM25_FRM varchar(10), NO2 varchar(10), NOY varchar(10), NOX varchar(10), Crustal varchar(10), Fe varchar(10), Al varchar(10), Si varchar(10), Ti varchar(10), Ca varchar(10), Mg varchar(10), K varchar(10), Mn varchar(10), soil varchar(10), OTHER varchar(10), NCOM varchar(10), OTHER_REM varchar(10), NaCl varchar(10), PM10 varchar(10), Valcode varchar(10) )";
$aq_new_2="alter table project_units add UNIQUE(proj_code, network)";

## project log
$aq_new_3="create table aq_project_log (proj_code varchar(30), model varchar(10), user_id varchar(20), passwd varchar(25), email varchar(100), description text, proj_date timestamp(8), proj_time time, min_date timestamp(8), max_date timestamp(8))";
$aq_new_4="alter table aq_project_log add UNIQUE(proj_code)";

## site metadata
$aq_new_5="create table site_metadata (stat_id varchar(25), num_stat_id int(10), stat_name varchar(100), network varchar(15), state varchar(4), city varchar(50), start_date varchar(20), end_date varchar(20), lat double, lon double, elevation int(10), landuse varchar(25))";
$aq_new_6="alter table site_metadata add UNIQUE(stat_id)";

## actually calling the db
## project units
print "Creating the project units table\n";
$table_query = $dbh->Query($aq_new_1) or
    die "Failed to create new project units table\n"; 
$table_query = $dbh->Query($aq_new_2);

## project log
print "Creating the project log table \n";
$table_query = $dbh->Query($aq_new_3) or
    die "Failed to create new project log table\n"; ;
$table_query = $dbh->Query($aq_new_4);

## site metadata
print "Creating the site metadata table \n";
$table_query = $dbh->Query($aq_new_5) or
    die "Failed to create new site metadata table\n"; ;
$table_query = $dbh->Query($aq_new_6);
exit
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

