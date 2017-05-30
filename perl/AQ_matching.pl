#!/usr/bin/perl
##------------------------------------------------------##
#   PROGRAM NAME: AQ_matching.pl			 #
#							 #
#     This is essentially a wrapper script for AMET.     #
#  This Perl program runs Site Compare for user selected #
#  networks and then runs AQ_add_aq2dbase.pl to add the	 #
#  data to the MYSQL database.  This program is part of	 #
#  the AMET-AQ system, and is intended to be used with   #
#  the php interface included with AMET.		 #
#							 #
#       REQUIRED: amet-config.pl	 		 #
#                 AQ_species_list.pl
#	                                                 #
#       PURPOSE: Run Site Compare and then put the       #
#                output into the MYSQL database for AMET #
#               					 #
#                                                        #
##------------------------------------------------------##

$amet_base		= $ENV{'AMETBASE'}; 
$use_AE6		= $ENV{'INC_AERO6_SPECIES'};
$time_shift		= $ENV{'TIME_SHIFT'};
$run_dir		= $ENV{'AMET_OUT'};
$project_id		= $ENV{'AMET_PROJECT'};
$ARCH			= $ENV{'ARCH_VERSION'};
$cutoff			= $ENV{'INC_CUTOFF'};
$start_date		= $ENV{'START_DATE'};
$end_date		= $ENV{'END_DATE'};
$write_sitex		= $ENV{'WRITE_SITEX'};
$run_sitex		= $ENV{'RUN_SITEX'};
$load_sitex		= $ENV{'LOAD_SITEX'};
$AMET_species_list	= $ENV{'AMET_SPECIES_FILE'};

$castnet_flag		= $ENV{'CASTNET'};		# Flag to include CASTNet data in the analysis
$castnet_hourly_flag	= $ENV{'CASTNET_HOURLY'};
$castnet_drydep_flag	= $ENV{'CASTNET_DRYDEP'};
$castnet_daily_flag	= $ENV{'CASTNET_DAILY'};
$improve_flag		= $ENV{'IMPROVE'};		# Flag to include IMPROVE data in the analysis
$nadp_flag		= $ENV{'NADP'};			# Flag to include NADP data in the analysis
$airmon_flag		= $ENV{'AIRMON'};		# Flag to include AIRMON data in the analysis
$csn_flag		= $ENV{'CSN'};                  # Flag to include CSN data in the analysis
$aqs_hourly_flag	= $ENV{'AQS_HOURLY'};		# Flag to include AQS hourly data in the analysis
$aqs_daily_o3_flag	= $ENV{'AQS_DAILY_O3'};		# Flag to include AQS 1hr and 8hr hour max data, W126, etc. (daily)
$aqs_daily_pm_flag	= $ENV{'AQS_DAILY_PM'};		# Flag to include AQS daily PM (2.5 and 10) data
$search_hourly_flag	= $ENV{'SEARCH_HOURLY'};	# Flag to include SEARCH data in the analysis
$search_daily_flag	= $ENV{'SEARCH_DAILY'};		# Flag to include daily SEARCH data in the analysis
$naps_hourly_flag	= $ENV{'NAPS_HOURLY'};		# Flag to include Canadians NAPS data (hourly) in analysis

### Europe Networks ###
$airbase_hourly_flag	= $ENV{'AIRBASE_HOURLY'};
$airbase_daily_flag	= $ENV{'AIRBASE_DAILY'};
$aurn_hourly_flag	= $ENV{'AURN_HOURLY'};
$aurn_daily_flag	= $ENV{'AURN_DAILY'};
$emep_hourly_flag	= $ENV{'EMEP_HOURLY'};
$emep_daily_flag	= $ENV{'EMEP_DAILY'};
$aganet_flag		= $ENV{'AGANET'};
$admn_flag		= $ENV{'ADMN'};
$namn_flag		= $ENV{'NAMN'};
#######################

$O3_units		= $ENV{'O3_UNITS'};
$precip_units		= $ENV{'PRECIP_UNITS'};

$gas_convert = 1;       # Assume gas units are in ppb by default
if (($O3_units eq "ppb") || ($O3_units eq "PPB") || ($O3_units eq "ppbv") || ($O3_units eq "ppbV")) { # If model O3 units are in ppb, convert observed O3 from ppm to ppb 
   $gas_convert = 1000;
}

$precip_convert = 1;
if ($precip_units eq "cm") {
   $precip_convert = 10;
}

require "$amet_base/configure/amet-config.pl";          # Get MYSQL config options from file
#require $amet_perl_input;                               ## Perl input file, user defined variables
require "$AMET_species_list";				# Load AMET species list from separate file

$year=int($start_date/1000);				# Determine the year from start date

#if ($version eq "") { $version = "new"; }	# Default to "new" if spec_def version is not set in the environment
if ($time_shift eq "") { $time_shift = 1; }	# Default to 1 (aconc) if time_shift value is not set in the environment

###########################################################


###############################################
### Create and Execute Site Compare Scripts ###
###############################################

$dep = "";
if (($improve_flag eq "y") || ($improve_flag eq "Y") || ($improve_flag eq "t") || ($improve_flag eq "T")) {
   $table_type    = "IMPROVE";
   $network       = "IMPROVE";
   $site_file     = "$obs_data_dir/improve_sites.txt";
   $ob_file       = "$obs_data_dir/improve_data_$year.csv";
   $EXEC	  = $EXEC_all;
   run_sitex();
}

if (($csn_flag eq "y") || ($csn_flag eq "Y") || ($csn_flag eq "t") || ($csn_flag eq "T")){
   $table_type    = "STN";
   $network	  = "CSN";
   $site_file     = "$obs_data_dir/csn_sites.txt";
   $ob_file       = "$obs_data_dir/csn_data_$year.csv";
   $EXEC	  = $EXEC_all;
   run_sitex();
}

if (($castnet_flag eq "y") || ($castnet_flag eq "Y") || ($castnet_flag eq "t") || ($castnet_flag eq "T")) {
   $table_type    = "CASTNET";
   $network	  = "CASTNET";
   $site_file     = "$obs_data_dir/castnet_sites.txt";
   $ob_file       = "$obs_data_dir/castnet_weekly_data.csv";
   $EXEC	  = $EXEC_all;
   run_sitex();
}

if (($castnet_hourly_flag eq "y") || ($castnet_hourly_flag eq "Y") || ($castnet_hourly_flag eq "t") || ($castnet_hourly_flag eq "T")) {
   $table_type    = "MET";
   $network	  = "CASTNET_Hourly";
   $site_file     = "$obs_data_dir/castnet_sites.txt";
   $ob_file       = "$obs_data_dir/castnet_hourly_${year}_data.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}

if (($castnet_daily_flag eq "y") || ($castnet_daily_flag eq "Y") || ($castnet_daily_flag eq "t") || ($castnet_daily_flag eq "T")) {
   $table_type    = "";
   $network       = "CASTNET_Daily";
   $site_file     = "$obs_data_dir/castnet_sites.txt";
   $ob_file       = "$obs_data_dir/castnet_hourly_${year}_data.csv";
   $EXEC          = $EXEC_cmp_cast;
   run_sitex();
}

if (($castnet_drydep_flag eq "y") || ($castnet_drydep_flag eq "Y") || ($castnet_drydep_flag eq "t") || ($castnet_drydep_flag eq "T")) {
   $table_type    = "CASTNET";
   $network	  = "CASTNET_Drydep";
   $site_file     = "$obs_data_dir/castnet_sites.txt";
   $ob_file       = "$obs_data_dir/castnet_weekly_drydep.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}

if (($nadp_flag eq "y") || ($nadp_flag eq "Y") || ($nadp_flag eq "t") || ($nadp_flag eq "T")) {
   $table_type    = "NADP";
   $network	  = "NADP";
   $site_file     = "$obs_data_dir/nadp_sites.txt";
   $ob_file       = "$obs_data_dir/nadp_data_${year}.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}

if (($aqs_daily_o3_flag eq "y") || ($aqs_daily_o3_flag eq "Y") || ($aqs_daily_o3_flag eq "t") || ($aqs_daily_o3_flag eq "T")) {
   $table_type    = "";
   $network	  = "AQS_Daily_O3";
   $site_file	  = "$obs_data_dir/aqs_sites.txt";
   $ob_file	  = "$obs_data_dir/aqs_${year}_O3_data.txt";
   $EXEC          = $EXEC_aqs;
   run_sitex();
}

if (($aqs_daily_pm_flag eq "y") || ($aqs_daily_pm_flag eq "Y") || ($aqs_daily_pm_flag eq "t") || ($aqs_daily_pm_flag eq "T")) {
   $table_type    = "CASTNET";
   $network	  = "AQS_Daily_PM";
   $site_file     = "$obs_data_dir/aqs_sites.txt";
   $ob_file       = "$obs_data_dir/aqs_daily_pm_${year}_data.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}

if (($aqs_hourly_flag eq "y") || ($aqs_hourly_flag eq "Y") || ($aqs_hourly_flag eq "t") || ($aqs_hourly_flag eq "T")) {
   $table_type    = "CASTNET";
   $network	  = "AQS_Hourly";
   $site_file     = "$obs_data_dir/aqs_sites.txt";
   $ob_file       = "$obs_data_dir/aqs_${year}_data.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}

if (($search_daily_flag eq "y") || ($search_daily_flag eq "Y") || ($search_daily_flag eq "t") || ($search_daily_flag eq "T")) {
   $table_type    = "CASTNET";
   $network	  = "SEARCH_Daily";
   $site_file     = "$obs_data_dir/search_sites.txt";
   if ($year < 2005) {
      $ob_file       = "$obs_data_dir/search_daily_pre_2005.csv";
   }
   else {
      $ob_file       = "$obs_data_dir/search_daily_${year}.csv";
   }
   $EXEC          = $EXEC_all;
   run_sitex();
}

if (($search_hourly_flag eq "y") || ($search_hourly_flag eq "Y") || ($search_hourly_flag eq "t") || ($search_hourly_flag eq "T")) {
   $table_type    = "CASTNET";
   $network	  = "SEARCH_Hourly";
   $site_file     = "$obs_data_dir/search_sites.txt";
   $ob_file       = "$obs_data_dir/search_hourly_${year}.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}

if (($naps_hourly_flag eq "y") || ($naps_hourly_flag eq "Y") || ($naps_hourly_flag eq "t") || ($naps_hourly_flag eq "T")) {
   $table_type    = "CASTNET";
   $network       = "NAPS";
   $site_file     = "$obs_data_dir/naps_sites.txt";
   $ob_file       = "$obs_data_dir/NAPS_hourly_${year}.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}

#######################
### Europe Networks ###
#######################

if (($airbase_hourly_flag eq "y") || ($airbase_hourly_flag eq "Y") || ($airbase_hourly_flag eq "t") || ($airbase_hourly_flag eq "T")) {
   $table_type    = "SEARCH";
   $network       = "AIRBASE";
   $site_file     = "$obs_data_dir/airbase_sites.txt";
   $ob_file       = "$obs_data_dir/airbase_hourly_${year}_data.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}
if (($airbase_daily_flag eq "y") || ($airbase_daily_flag eq "Y") || ($airbase_daily_flag eq "t") || ($airbase_daily_flag eq "T")) {
   $table_type    = "SEARCH";
   $network       = "AIRBASE";
   $site_file     = "$obs_data_dir/airbase_sites.txt";
   $ob_file       = "$obs_data_dir/airbase_daily_${year}_data.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}
if (($aurn_hourly_flag eq "y") || ($aurn_hourly_flag eq "Y") || ($aurn_hourly_flag eq "t") || ($aurn_hourly_flag eq "T")) {
   $table_type    = "SEARCH";
   $network       = "AURN";
   $site_file     = "$obs_data_dir/aurn_sites.txt";
   $ob_file       = "$obs_data_dir/aurn_hourly_${year}_data.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}
if (($aurn_daily_flag eq "y") || ($aurn_daily_flag eq "Y") || ($aurn_daily_flag eq "t") || ($aurn_daily_flag eq "T")) {
   $table_type    = "SEARCH";
   $network       = "AURN";
   $site_file     = "$obs_data_dir/aurn_sites.txt";
   $ob_file       = "$obs_data_dir/aurn_daily_${year}_data.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}
if (($emep_hourly_flag eq "y") || ($emep_hourly_flag eq "Y") || ($emep_hourly_flag eq "t") || ($emep_hourly_flag eq "T")) {
   $table_type    = "SEARCH";
   $network       = "EMEP";
   $site_file     = "$obs_data_dir/emep_sites.txt";
   $ob_file       = "$obs_data_dir/emep_hourly_${year}_data.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}
if (($emep_daily_flag eq "y") || ($emep_daily_flag eq "Y") || ($emep_daily_flag eq "t") || ($emep_daily_flag eq "T")) {
   $table_type    = "SEARCH";
   $network       = "EMEP";
   $site_file     = "$obs_data_dir/emep_sites.txt";
   $ob_file       = "$obs_data_dir/emep_daily_${year}_data.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}
if (($aganet_flag eq "y") || ($aganet_flag eq "Y") || ($aganet_flag eq "t") || ($aganet_flag eq "T")) {
   $table_type    = "SEARCH";
   $network       = "AGANET";
   $site_file     = "$obs_data_dir/aganet_sites.txt";
   $ob_file       = "$obs_data_dir/aganet_${year}_data.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}
if (($admn_flag eq "y") || ($admn_flag eq "Y") || ($admn_flag eq "t") || ($admn_flag eq "T")) {
   $table_type    = "SEARCH";
   $network       = "ADMN";
   $site_file     = "$obs_data_dir/admn_sites.txt";
   $ob_file       = "$obs_data_dir/admn_${year}_data.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}
if (($namn_flag eq "y") || ($namn_flag eq "Y") || ($namn_flag eq "t") || ($namn_flag eq "T")) {
   $table_type    = "SEARCH";
   $network       = "NAMN";
   $site_file     = "$obs_data_dir/namn_sites.txt";
   $ob_file       = "$obs_data_dir/namn_${year}_data.csv";
   $EXEC          = $EXEC_all;
   run_sitex();
}
###########################################################
### Function to create and execute site compare scripts ###
###########################################################

sub run_sitex {

### Start Generic Script Text ###

   $header =
"  #!/bin/sh

  # Set TABLE TYPE
  TABLE_TYPE=$table_type; export TABLE_TYPE
   
  # Specify the variable names used in your observation inputs
  # and model output files for each of the species you are analyzing below.
  #  
  # variable format:
  #    Obs_expression, Obs_units, [Mod_expression], [Mod_unit], [Variable_name]
  #  
  # The expression is in the form:
  #       [factor1]*Obs_name1 [+][-] [factor2]*Obs_name2 ...";

  $time_settings = "  ### End Species List ###

  ## define time window
  START_DATE=$start_date;  export START_DATE
  END_DATE=$end_date;    export END_DATE
  START_TIME=0;        export START_TIME
  END_TIME=230000;     export END_TIME

  ## define the PRECIP variable
  PRECIP=RT; export PRECIP

  ## adjust for daylight savings 
  APPLY_DLS=N; export APPLY_DLS

  ## set missing value string
  MISSING=\"-999\"; export MISSING

  ## Projection sphere type (use type #19 to match CMAQ)
  IOAPI_ISPH=20; export IOAPI_ISPH

  ## Time Shift for dealing with aconc files ## 
  TIME_SHIFT=$time_shift; export TIME_SHIFT

  #############################################################
  #  Input files
  #############################################################
  # ioapi input files containing VNAMES (max of 10)
";

   $final_wrapup =
"
  #  SITE FILE containing site-id, longitude, latitude (tab delimited)
  SITE_FILE=$site_file; export SITE_FILE

  # : input table (exported file from Excel) 
  #   containing site-id, time-period, and data fields
  IN_TABLE=$ob_file; export IN_TABLE

  #############################################################
  #  Output files
  #############################################################

  #  output table (tab delimited text file importable to Excel)
  OUT_TABLE=$run_dir/${network}_${project_id}.csv; export OUT_TABLE

  $EXEC
";

### End Generic Script Text ###

### Start Creation of Script Text ###

   $dat = $header.${species_."$network"};
   if (($cutoff eq "y") || ($cutoff eq "Y") || ($cutoff eq "t") || ($cutoff eq "T")) {
      $dat = $dat.${species_cutoff_."$network"};
   }
   if (($use_AE6 eq "y") || ($use_AE6 eq "Y") || ($use_AE6 eq "t") || ($use_AE6 eq "T")) {
      $dat = $dat.${species_AE6_."$network"};
   }
   $m3_files="";
   if (($network eq "NADP") || ($network eq "CASTNET_Drydep")) { 
      $M3_FILE = $ENV{DEP_FILE_1};
   }
   else { 
      $M3_FILE = $ENV{CONC_FILE_1};
   }
   $j=1;
   while ($M3_FILE) {
      $m3_files = $m3_files."  M3_FILE_$j=$M3_FILE;   export M3_FILE_$j
";
      $j++;
      if (($network eq "NADP") || ($network eq "CASTNET_Drydep")) { 
         $M3_FILE = $ENV{DEP_FILE_."$j"};
      }
      else { 
         $M3_FILE = $ENV{CONC_FILE_."$j"}; 
      }
   }
   $dat = $dat.$time_settings.$m3_files.$final_wrapup;

   ### Open, write and close site compare script ###
   if (($write_sitex eq "y") || ($write_sitex eq "Y") || ($write_sitex eq "t") || ($write_sitex eq "T")) {
      open (DAT, ">$run_dir/sitex_${network}_$project_id.sh");
      print DAT "$dat\n";
      close(DAT);
      print "Wrote site compare script for $network network.\n\n";
   }
   #########################################

   ### Execute site compare script and load output into database ###
   if (($run_sitex eq "y") || ($run_sitex eq "Y") || ($run_sitex eq "t") || ($run_sitex eq "T")) {
      system "chmod +x $run_dir/sitex_${network}_$project_id.sh";
      print "Running site compare for $network Network.  Depending on length of time being extracted, this may take a while.\n";
      system "$run_dir/sitex_${network}_$project_id.sh";
      print "Finished runing site compare for $network network.\n\n";
   }
   if (($load_sitex eq "y") || ($load_sitex eq "Y") || ($load_sitex eq "t") || ($load_sitex eq "T")) {
      print "Populating database with site compare data for $network Network.\n";
      system "/usr/bin/perl $amet_base/perl/AQ_add_aq2dbase.pl $project_id $network $run_dir/${network}_$project_id.csv";
      print "Finished populating database for $network Network.\n";
   }
   #################################################################
}

### End Creation of Script Text ###

##############################
### End function run_sitex ###
##############################
