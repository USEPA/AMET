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
$amet_perl_input = $ENV{'AMETPERLINPUT'};

require $amet_perl_input;        ## Perl input file, user defined variables

## Make a DB connection
my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass) 
    or die "Unable to connect to MySQL database $dbase.  Check server, user and/or passwords.\n";	

my $sth=$dbh->Query("SELECT proj_code from aq_project_log ");


## New project query
$data_table_query_1="create table $run_id (proj_code varchar(50), network varchar(25), stat_id varchar(25), lat double, 
 lon double, i integer(4), j integer(4), ob_dates date, ob_datee date, ob_hour integer(2), month integer(2), 
 SO4_ob double, SO4_mod double, NO3_ob double, NO3_mod double, NH4_ob double, NH4_mod double, OC_ob double, 
 OC_mod double, EC_ob double, EC_mod double, TC_ob double, TC_mod double, PM_TOT_ob double, PM_TOT_mod double,
 PM_FRM_ob double, PM_FRM_mod double, Crustal_ob double, Crustal_mod double, ASOCT_ob double, ASOCT_mod double, 
 PM25_SO4_ob double, PM25_SO4_mod double, PM25_NO3_ob double, PM25_NO3_mod  double, PM25_NH4_ob double, PM25_NH4_mod double, 
 PM25_OC_ob double, PM25_OC_mod double, PM25_EC_ob double, PM25_EC_mod double, PM25_TC_ob double, PM25_TC_mod double, 
 PM25_TOT_ob double, PM25_TOT_mod double, PM25_FRM_ob double, PM25_FRM_mod double, PM10_ob double, PM10_mod double, 
 Cl_ob double, Cl_mod double, Na_ob double, Na_mod double, PM25_Cl_ob double, PM25_Cl_mod double, PM25_Na_ob double, 
 PM25_Na_mod double, HNO3_ob double, HNO3_mod double, TNO3_ob double, TNO3_mod double, PM25_TNO3_ob double, 
 PM25_TNO3_mod double, SO2_ob double, SO2_mod double, SO2_adj_ob double, SO2_adj_mod double, O3_ob double, O3_mod double, 
 SFC_TMP_ob double, SFC_TMP_mod double,  RH_ob double, RH_mod double, Solar_Rad_ob double, Solar_Rad_mod double, 
 WSPD10_ob double, WSPD10_mod double, WDIR10_ob double, WDIR10_mod double, precip_ob double, precip_mod double, 
 O3_1hrmax_ob double, O3_1hrmax_mod double, O3_1hrmax_time_ob double, O3_1hrmax_time_mod double,  O3_8hrmax_ob double, 
 O3_8hrmax_mod double, O3_8hrmax_time_ob double, O3_8hrmax_time_mod double, O3_1hrmax_9cell_ob double, O3_1hrmax_9cell_mod double, 
 O3_8hrmax_9cell_ob double, O3_8hrmax_9cell_mod double, W126_ob double, W126_mod double, SO4_ddep_ob double, SO4_ddep_mod double, 
 NO3_ddep_ob double, NO3_ddep_mod double, NH4_ddep_ob double, NH4_ddep_mod double, HNO3_ddep_ob double, HNO3_ddep_mod double, 
 TNO3_ddep_ob double, TNO3_ddep_mod double, O3_ddep_ob double, O3_ddep_mod double, SO2_ddep_ob double, SO2_ddep_mod double, 
 NO_ob double, NO_mod double, NO2_ob double, NO2_mod double, NOX_ob double,  NOX_mod double, CO_ob double,  CO_mod double, 
 NOY_ob double, NOY_mod double, PMC_SO4_ob double,  PMC_SO4_mod double, PMC_NO3_ob double,  PMC_NO3_mod double, PMC_NH4_ob double, 
 PMC_NH4_mod double, PMC_TOT_ob double, PMC_TOT_mod double, PMC_CL_ob double, PMC_CL_mod double, PMC_NA_ob double, 
 PMC_NA_mod double,  SO4_conc_ob double, SO4_conc_mod double, SO4_dep_ob double, SO4_dep_mod double, NO3_conc_ob double,  
 NO3_conc_mod double,  NO3_dep_ob double, NO3_dep_mod double, NH4_conc_ob double, NH4_conc_mod double, NH4_dep_ob double, 
 NH4_dep_mod double, Cl_conc_ob double, Cl_conc_mod double, Cl_dep_ob double,  Cl_dep_mod double, Ca_conc_ob double, 
 Ca_conc_mod double, Ca_dep_ob double, Ca_dep_mod double, Mg_conc_ob double, Mg_conc_mod double, Mg_dep_ob double, 
 Mg_dep_mod double, K_conc_ob double, K_conc_mod double, K_dep_ob double, K_dep_mod double, valid_code varchar(10), 
 invalid_code varchar(10), HG_ob double, HG_mod double, HGconc_ob double, HGconc_mod double, HGdep_ob double, HGdep_mod double, 
 FORM_ob double, FORM_mod double, Lead_PM10_ob double, Lead_PM10_mod double, Lead_PM25_ob double, Lead_PM25_mod double, 
 Manganese_PM10_ob double, Manganese_PM10_mod double, Manganese_PM25_ob double, Manganese_PM25_mod double, Nickel_PM10_ob double, 
 Nickel_PM10_mod double, Nickel_PM25_ob double, Nickel_PM25_mod double, TOLU_ob double, TOLU_mod double, NaCl_ob double, 
 NaCl_mod double, Fe_ob double, Fe_mod double, Al_ob double, Al_mod double, Si_ob double, Si_mod double, Ti_ob double, Ti_mod double, 
 Ca_ob double, Ca_mod double, Mg_ob double, Mg_mod double, Mn_ob double, Mn_mod double, K_ob double, K_mod double, 
 other_ob double, other_mod double, ncom_ob double, ncom_mod double, other_rem_ob double, other_rem_mod double, 
 soil_ob double, soil_mod double)";

###################################################################
### Use this table setup if processing a CMAQ toxics simulation ###
###################################################################
$data_table_query_2="create table $run_id (proj_code varchar(50), network varchar(25), stat_id varchar(25), lat double, 
 lon double, i integer(4), j integer(4), ob_dates date, ob_datee date, ob_hour integer(2), month integer(2), 
 SO4_ob double, SO4_mod double, NO3_ob double, NO3_mod double, NH4_ob double, NH4_mod double, OC_ob double, 
 OC_mod double, EC_ob double, EC_mod double, TC_ob double, TC_mod double, PM_TOT_ob double, PM_TOT_mod double,
 PM_FRM_ob double, PM_FRM_mod double, Crustal_ob double, Crustal_mod double, ASOCT_ob double, ASOCT_mod double, 
 PM25_SO4_ob double, PM25_SO4_mod double, PM25_NO3_ob double, PM25_NO3_mod  double, PM25_NH4_ob double, PM25_NH4_mod double, 
 PM25_OC_ob double, PM25_OC_mod double, PM25_EC_ob double, PM25_EC_mod double, PM25_TC_ob double, PM25_TC_mod double, 
 PM25_TOT_ob double, PM25_TOT_mod double, PM25_FRM_ob double, PM25_FRM_mod double, PM10_ob double, PM10_mod double, 
 AORGPAT_ob double, AORGPAT_mod double, Cl_ob double, Cl_mod double, Na_ob double, Na_mod double, PM25_Cl_ob double, 
 PM25_Cl_mod double, PM25_Na_ob double, PM25_Na_mod double, HNO3_ob double, HNO3_mod double, TNO3_ob double, TNO3_mod double, 
 PM25_TNO3_ob double, PM25_TNO3_mod double, SO2_ob double, SO2_mod double, SO2_adj_ob double, SO2_adj_mod double, 
 O3_ob double, O3_mod double, SFC_TMP_ob double, SFC_TMP_mod double,  RH_ob double, RH_mod double, Solar_Rad_ob double, 
 Solar_Rad_mod double, WSPD10_ob double, WSPD10_mod double, WDIR10_ob double, WDIR10_mod double, precip_ob double, 
 precip_mod double, O3_1hrmax_ob double, O3_1hrmax_mod double, O3_1hrmax_time_ob double, O3_1hrmax_time_mod double, 
 O3_8hrmax_ob double, O3_8hrmax_mod double, O3_8hrmax_time_ob double, O3_8hrmax_time_mod double, O3_1hrmax_9cell_ob double, 
 O3_1hrmax_9cell_mod double, O3_8hrmax_9cell_ob double, O3_8hrmax_9cell_mod double, W126_ob double, W126_mod double,
 SO4_ddep_ob double, SO4_ddep_mod double, NO3_ddep_ob double, NO3_ddep_mod double, NH4_ddep_ob double, 
 NH4_ddep_mod double, HNO3_ddep_ob double, HNO3_ddep_mod double, TNO3_ddep_ob double, TNO3_ddep_mod double, 
 O3_ddep_ob double, O3_ddep_mod double, SO2_ddep_ob double, SO2_ddep_mod double, NO_ob double, NO_mod double, 
 NO2_ob double, NO2_mod double, NOX_ob double,  NOX_mod double, CO_ob double,  CO_mod double, NOY_ob double, 
 NOY_mod double, PMC_SO4_ob double,  PMC_SO4_mod double, PMC_NO3_ob double,  PMC_NO3_mod double, PMC_NH4_ob double, 
 PMC_NH4_mod double, PMC_TOT_ob double, PMC_TOT_mod double, PMC_CL_ob double, PMC_CL_mod double, PMC_NA_ob double, 
 PMC_NA_mod double,  SO4_conc_ob double, SO4_conc_mod double, SO4_dep_ob double, SO4_dep_mod double, 
 NO3_conc_ob double,  NO3_conc_mod double,  NO3_dep_ob double, NO3_dep_mod double, NH4_conc_ob double, NH4_conc_mod double, 
 NH4_dep_ob double, NH4_dep_mod double, Cl_conc_ob double, Cl_conc_mod double, Cl_dep_ob double,  Cl_dep_mod double,
 Ca_conc_ob double, Ca_conc_mod double, Ca_dep_ob double, Ca_dep_mod double, Mg_conc_ob double, Mg_conc_mod double,
 Mg_dep_ob double, Mg_dep_mod double, K_conc_ob double, K_conc_mod double, K_dep_ob double, K_dep_mod double,
 valid_code varchar(10), invalid_code varchar(10), HG_ob double, HG_mod double, HGconc_ob double, HGconc_mod double, 
 HGdep_ob double, HGdep_mod double, HOx_ob double, HOx_mod double, Acrolein_ob double, Acrolein_mod double, 
 Acrylonitrile_ob double,  Acrylonitrile_mod double, ALD2_ob double,ALD2_mod double, Benzene_ob double, Benzene_mod double, 
 BR2_C2_12_ob double, BR2_C2_12_mod double, Butadiene13_ob double, Butadiene13_mod double,Cadmium_PM10_ob double, 
 Cadmium_PM10_mod double, Cadmium_PM25_ob double, Cadmium_PM25_mod double, Carbontet_ob double, Carbontet_mod double, 
 Chromium_PM10_ob double, Chromium_PM10_mod double, Chromium_PM25_ob double, Chromium_PM25_mod double, CHCL3_ob double, 
 CHCL3_mod double, CL_ETHE_ob double,CL_ETHE_mod double, CL2_ob double, CL2_mod double, CL2_C2_12_ob double, 
 CL2_C2_12_mod double, CL2_ME_ob double, CL2_ME_mod double, CL3_ETHE_ob double, CL3_ETHE_mod double, CL4_ETHE_ob double, 
 CL4_ETHE_mod double, CL4_Ethane1122_ob double, CL4_Ethane1122_mod double, CR_III_PM10_ob double, 
 CR_III_PM10_mod double, CR_III_PM25_ob double, CR_III_PM25_mod double, CR_VI_PM10_ob double, 
 CR_VI_PM10_mod double, CR_VI_PM25_ob double, CR_VI_PM25_mod double, Dichlorobenzene_ob double, 
 Dichlorobenzene_mod double, FORM_ob double, FORM_mod double, Lead_PM10_ob double, Lead_PM10_mod double, 
 Lead_PM25_ob double, Lead_PM25_mod double, Manganese_PM10_ob double, Manganese_PM10_mod double, 
 Manganese_PM25_ob double, Manganese_PM25_mod double, MEOH_ob double, MEOH_mod double, MXYL_ob double, 
 MXYL_mod double, Nickel_PM10_ob double, Nickel_PM10_mod double, Nickel_PM25_ob double, Nickel_PM25_mod double, 
 OXYL_ob double, OXYL_mod double, Propdichloride_ob double, Propdichloride_mod double, PXYL_ob double, 
 PXYL_mod double, TOLU_ob double, TOLU_mod double, NaCl_ob double, NaCl_mod double, Fe_ob double, Fe_mod double,
 Al_ob double, Al_mod double, Si_ob double, Si_mod double, Ti_ob double, Ti_mod double, Ca_ob double, Ca_mod double,
 Mg_ob double, Mg_mod double, Mn_ob double, Mn_mod double, K_ob double, K_mod double, other_ob double, other_mod double,
 ncom_ob double, ncom_mod double, other_rem_ob double, other_rem_mod double, soil_ob double, soil_mod double)";

$data_table_query_3="alter table $run_id add UNIQUE(network,stat_id,ob_dates,ob_datee,ob_hour)";

## Check for projects w/ same run_id
while(@row=$sth->fetchrow_array()) {
   my @record = @row;
   push(@fields, \@record);
}
$sth->finish();
$proj_exists = 0;  ## whether or not project exists
if (@fields != 0) {
    print "Checking current projects: \n";
   foreach $pc (@fields) {
      print "\t found project - @$pc[0] \n";
      
      if (@$pc[0] eq $run_id) {
	  ## found a project w/ same project id
	  if ($delete_id eq 'y') {
            print "Are you sure you want to delete project id $run_id from the database (y/n)? \n";
	    print "WARNING: This will delete all data associated with the old project\n";
            chomp($delete_id2 = <STDIN>);
            if ($delete_id2 eq "y") {
	       ## Drop old table
               $drop="delete from aq_project_log where proj_code = '$run_id'";
               $table_query = $dbh->Query($drop);
               $drop2="drop table $run_id";
               $table_query = $dbh->Query($drop2);
               print ("The following MySQL database tables have been successfully removed from the database: $run_id \n");
	   } else {
	       print ("Not deleting project ($run_id).  Bye.\n");
	       exit $exit_exists;   
	   }
	    
         }
         else {
	     ## Not dropping old table
	     print "The project ($run_id) already exists !\n";
	     print "If you want to replace it, change \"delete_id\" to yes in the\n";
	     print "input file ($amet_perl_input) and rerun.\n";
	     exit $exit_exists;
	 }
         $proj_exists = 1;  
      }
   }
}

if ($proj_exists == 0) {
   print "\nNo existing project named $run_id found.\n";
}
## Creating the new project
print "Creating new project $run_id \n";

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

## Update the AQ log
$table_query=$dbh->Query("REPLACE INTO aq_project_log (proj_code, model, user_id, passwd, email, description, proj_date, proj_time) VALUES ('$run_id','$model','$login',PASSWORD('$passwd'),'$email','$description',$proj_date,'$proj_time')");

## Create the project table
$aq_all_1=$dbh->Query($data_table_query_1);
#$aq_all_1=$dbh->Query($data_table_query_2);	# Use instead of above for toxics CMAQ simulation
$aq_all_2=$dbh->Query($data_table_query_3);
print "The following database tables have been successfully generated.  Please review the following for accuracy: \n";

## Test that the data has been successfuly stored in DB
$query_min="SELECT * from aq_project_log where proj_code='$run_id' ";   # set query for project log table for all information regarding current project
my $sth = $dbh->query($query_min);                                      # setup query
@row=$sth->fetchrow_array();                                            # excute query
print "model       = $row[1]\n";
print "user        = $row[2]\n";
print "email       = $row[4]\n";
print "description = $row[5]\n";
print "proj_date (creation date) = $row[6]\n";
print "proj_time (creation time) = $row[7]\n";

## Success
exit;

