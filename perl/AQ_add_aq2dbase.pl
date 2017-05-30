#!/usr/bin/perl
##------------------------------------------------------
#	AMET AQ Database Query Input 			#
#							#
#	PURPOSE: To input site compare output into	#
#		the AMET-AQ MYSQL database		#
#							#
#	Last Update: 11/06/2012 by Wyat Appel		#
#     							#
#   Note that is program assumes a consistent		#
#   configuration of the input files, mainly from	#
#   the site compare and compare airs programs.		#
#   Any alteration of the those files may result in	#
#   this program not working properly.			#
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
$O3_units     = $ENV{'O3_UNITS'};

$run_id		=$ARGV[0];				# The run id (project name) used
$dtype		=$ARGV[1];				# The observation network being added to the database
$sitex_file	=$ARGV[2]; 				# The name and location of the Site Compare file containing the data

# LOAD Required Perl Modules
use lib $perl_lib;                                      # Add custom perl package path
use Mysql;                                              # Use MYSQL perl package
use CGI;                                                # Use CGI perl package
use DBI;                                                # Use DBI perl package

my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass)
    or die "Unable to connect to MySQL database $dbase.  Check server, user and/or passwords.\n";

open (DAT,"< $sitex_file");@dat=<DAT>;$l=scalar(@dat);chomp(@dat);		# Open Site Compare file and read data into DAT

$gas_convert = 1;       # Assume gas units are in ppb by default
if ($O3_units eq "ppm") { $gas_convert = 1000; }        # If gas units are ppm, add conversion factor of 1000

#######################################################################
## Add AQS/CASTNET daily  data (1hrmax, 8hrmax, etc) to the database ##
#######################################################################
if (($dtype eq "AQS") || ($dtype eq "AQS_Daily_O3") || ($dtype eq "CASTNET_Daily")) {			# If using Compare Airs, Compare CASTNET or old AQS format data
   $spec_count = 1;
   @wrd_vars=split(/,/,$dat[7]);                                                                        # Split fourth line (variables) of the Site Compare file
   @wrd_units=split(/,/,$dat[8]);                                                                       # Split fifth line (units) of the Site Compare file
   @wrd_modob=split(/,/,$dat[9]);                                                                       # Split sixth line (model or ob value) of the Site Compare file
   $g=scalar @wrd_vars;
   if ($dtype eq "AQS") {
      $g=9;
      $h=9;
      $offset=2;
      $date_col=7;
      $skip_line=10;
      $dtype = 'AQS_Hourly';
   }
   elsif ($dtype eq "CASTNET_Daily") {
      $g=6;
      $h=6;
      $offset=0;
      $skip_line=10;
      $date_col = 5;
   }
   else {
      $g=8;
      $h=8;
      $offset=2;
      $date_col=7;
      $skip_line=10;
   }

   #################################
   ### Start units query section ###
   #################################

   $q1_units="REPLACE INTO project_units";                                                              # Set first part of units table query
   $q2_units=" (proj_code, network";                                                                     # Set beginning of second part of units table query
   $q3_units=" VALUES ('$run_id', '$dtype'";                                                            # Set beginning of third part of units table query 
   $t=scalar @wrd_vars-1;
   @wrd_vars2=@wrd_vars[$h..$t];
   @wrd_units2=@wrd_units[$h..$t];
   $t=scalar @wrd_vars2;
   $q=0;
   while($wrd_vars2[$q]) {                                                                               # While still reading species information form the Site Compare file
      for ($s=$q;$s<$t;$s++) {
         if ($wrd_vars2[$q] eq $wrd_vars2[$s+1]) {
            splice(@wrd_vars2,$q,1);
            splice(@wrd_units2,$q,1);
         }
      }
      $q++;
      $t=scalar @wrd_vars2-1;
   }
   $t=scalar @wrd_vars2;
   for ($s=0;$s<$t;$s++) {
      $q2_units="$q2_units, $wrd_vars2[$s]";                                                         # Add species to units query
      $q3_units="$q3_units, '$wrd_units2[$s]'";
   }
   $query_units=$q1_units.$q2_units.")".$q3_units.")";
#   print "$query_units \n";
   $table_query = $dbh->Query($query_units);
   
   ###############################
   ### End units query section ###
   ###############################

   $t=1;
   $q2_main=" (proj_code, network, stat_id, lat, lon, i, j, ob_dates, ob_datee, ob_hour, month";	# Set beginning of second part of main table query
   while($wrd_vars[$g]) {                                                                               # While still reading species information form the sitex file
      $vars[$t]=$wrd_vars[$g];                                                                          # Store variable name in array
      $wrd_vars[$g]=~s/\s+$//;                                                                          # Strip any white space at end of variable
      $mod_ob=$wrd_modob[$g];                                                                           # Determine if value is ob value or model value
      $mod_ob=~s/\s+$//;                                                                                # Strip any white space at end of observation/model line
      if ($mod_ob eq "observed") {                                                                      # If ob value, append "_ob" to species name
         $var[$t]="$wrd_vars[$g]_ob";                                                                   # Store ob name for each variable
      }
      if ($mod_ob eq "modeled") {                                                                       # If model value, append "_mod" to species name 
         $var[$t]="$wrd_vars[$g]_mod";                                                                  # Store model name for each variable
      }
      $q2_main="$q2_main, $var[$t]";                                                                    # Build query by adding ob and model names
#      print "$q2_main \n";
      $g=$g+1;                                                                                          # move to next variable in sitex file
      $t=$t+1;
   }
 
   foreach $dat (@dat) {
      if($i >= $skip_line){
         @wrd=split(/,/,$dat[$i]);
         @d1=split(/\s+/,$wrd[$date_col]);
         @w=split(/\//,$d1[0]);
         $dates=sprintf("%04d",$w[2]).sprintf("%02d",$w[0]).sprintf("%02d",$w[1]);
         @d2=split(/\s+/,$wrd[$date_col]);
         @w2=split(/\//,$d2[0]);
         $datee=sprintf("%04d",$w2[2]).sprintf("%02d",$w2[0]).sprintf("%02d",$w2[1]);

         ##########################################################################
         # Crude method to determine the month from the start and end dates 
         ##########################################################################

         if (($w2[0]-$w[0]) == 0) {
            $month = $w[0];  
         }
         elsif (($w2[0]-$w[0]) == 2) {
            $month = $w[0]+1;  
         }
         elsif (($w2[0]-$w[0]) == 1) {
            if (($w[0] == 1) || ($w[0] == 3) || ($w[0] == 5) || ($w[0] == 7) || ($w[0] == 8) || ($w[0] == 10) || ($w[0] == 12)) {
               $day_diff1 = 31 - $w[1];
               $day_diff2 = $w2[1];
               if ($day_diff1 >= $day_diff2) { $month = $w[0]; }
               else { $month = $w2[0]; }
            }  
            elsif ($w[0] == 2) { 
               $day_diff1 = 28 - $w[1];
               $day_diff2 = $w2[1];
               if ($day_diff1 >= $day_diff2) { $month = $w[0]; }
               else { $month = $w2[0]; }
            }
            else {
               $day_diff1 = 30 - $w[1];
               $day_diff2 = $w2[1]; 
               if ($day_diff1 >= $day_diff2) { $month = $w[0]; }
               else { $month = $w2[0]; }
            }
         }
         ########################################################################### 
      
         @w2=split(/:/,$wrd[8]);
         if ($dtype eq "AQS_Hourly") {
     	    $hour=(@w2[0]-1);
         }
         else { 
            $hour = 0;
         }
          if ($dtype eq "CASTNET_Daily") {
            $stat_id=$wrd[0];
         }
         else {
            $stat_id=$wrd[0].$wrd[1].$wrd[2];
         }
         $q3_main=" VALUES  ('$run_id','$dtype','$stat_id',$wrd[2+$offset],$wrd[1+$offset], $wrd[3+$offset], $wrd[4+$offset], $dates, $datee, $hour, $month";
         for ($j=$h;$j<$g;$j++) {                                                                        # For each value column in the Site Compare file
            $q3_main="$q3_main, ".sprintf("%8.10f",$gas_convert*$wrd[$j])."";                                                # Add value to MYSQL query (q3_main)
         } 
         print "Inserting data for site $stat_id on $d1[0] \n ";	# Print to the screen the progress of the script
         $q1_main="REPLACE INTO $run_id";
         $query=$q1_main.$q2_main.")".$q3_main.")";			# Create the entire query to insert the data into the database
#         print"$query \n";
         $table_query = $dbh->Query($query);				# Insert the data into the database (query)
      }
      $i=$i+1;
   }
}
######################################

########################################
### Add Network data to the database ###
########################################
else {	# If using Site Compare output
   $i=0;	# Start with the first line in the sitex file
   @wrd_vars=split(/,/,$dat[3]);                                                                        # Split fourth line (variables) of the Site Compare file
   @wrd_units=split(/,/,$dat[4]);                                                                       # Split fifth line (units) of the Site Compare file
   @wrd_modob=split(/,/,$dat[5]);                                                                       # Split sixth line (model or ob value) of the Site Compare file
   if ($dtype eq "NADP") {	# If using NADP without validity codes included, alter the query to exclude the codes
      $dtype2 = $dtype;
      $q2_main=" (proj_code, network, stat_id, lat, lon, i, j, ob_dates, ob_datee, ob_hour, month, valid_code, invalid_code";	# Set beginning of second part of main table query
      $g=9;
      $h=9;
   }
   else {
      $dtype2=$dtype;
      $q2_main=" (proj_code, network, stat_id, lat, lon, i, j, ob_dates, ob_datee, ob_hour, month";     # Set beginning of second part of main table query
      $g=7;
      $h=7;
   }
   if ($dtype eq "NADP_nc") { $dtype eq "NADP" };
   if ($dtype eq "STN") { $dtype eq "CSN";
   }
   #################################
   ### Start units query section ###
   #################################

   $q1_units="REPLACE INTO project_units";		# Set first part of units table query
   $q2_units=" (proj_code,network";			# Set beginning of second part of units table query
   $q3_units=" VALUES ('$run_id', '$dtype'";		# Set beginning of third part of units table query
   $t=scalar @wrd_vars-1;				# Determine the number of columns
   @wrd_vars2=@wrd_vars[$h..$t];			# Set another array to be just the names of species
   @wrd_units2=@wrd_units[$h..$t];			# Set another array to be just the units of the species
   $t=scalar @wrd_vars2;				# Determine the number of species
   $h=0;						# Start h at 0
   while($wrd_vars2[$h]) {				# While still reading species information form the Site Compare file
      for ($s=$h;$s<$t;$s++) {				# Loop to remove duplicate species names for the project_units query
         if ($wrd_vars2[$h] eq $wrd_vars2[$s+1]) {	# Check to see current array element matches any other element of the array
            splice(@wrd_vars2,$h,1);			# If so, remove that element from the species name array
            splice(@wrd_units2,$h,1);			# If so, remove that unit from the units array
         }
      }
      $h++;						# Increment to the next species name
      $t=scalar @wrd_vars2-1;				# reassess the lenght of the array since an element could have been removed
   }
   $t=scalar @wrd_vars2;				# redetermine the lenght of the species name array
   for ($s=0;$s<$t;$s++) {				# build the units query
      $q2_units="$q2_units, $wrd_vars2[$s]";		# Add species to units query
      $q3_units="$q3_units, '$wrd_units2[$s]'";		# Add units to units query
   }
   $query_units=$q1_units.$q2_units.")".$q3_units.")";	# Build complete query for the units table
   print"$query_units\n";
   $table_query = $dbh->Query($query_units);		# Adds units to units table

   ###############################
   ### End units query section ###
   ###############################

   ######################################
   ### Start build main query section ###
   ######################################

   $t=1;
   while($wrd_vars[$g]) {						# While still reading species information form the sitex file
      $vars[$t]=$wrd_vars[$g];						# Store variable name in array
      $wrd_vars[$g]=~s/\s+$//;						# Strip any white space at end of variable
      $mod_ob=$wrd_modob[$g];						# Determine if value is ob value or model value
      $mod_ob=~s/\s+$//;						# Strip any white space at end of observation/model line
      if (($mod_ob eq "Observed") || ($mod_ob eq "observed")) {		# If ob value, append "_ob" to species name
         $var[$t]="$wrd_vars[$g]_ob";					# Store ob name for each variable
      }
      if (($mod_ob eq "Modeled") || ($mod_ob eq "modeled")) {		# If model value, append "_mod" to species name 
         $var[$t]="$wrd_vars[$g]_mod";					# Store model name for each variable
      }
      $q2_main="$q2_main, $var[$t]";					# Build query by adding ob and model names
      $g=$g+1;								# Move to next variable in sitex file
      $t=$t+1;
   }

   ####################################
   ### End build main query section ###
   ####################################
   

   ##################################################
   ### Start main section to add data to database ###
   ##################################################

   $stat_id_previous = "null";
   $dates_previous = 0;
   $datee_previous = 0;
   $hour_previous = 30;
   foreach $dat (@dat) {									# While there is data in the file
      if($i >= 6){										# Skip header lines, go to end of file
         @wrd=split(/,/,$dat[$i]);								# Split line by ","
	 @d1=split(/\s+/,$wrd[5]);								# Split the fifth element (start date) by white space
	 @w=split(/\//,$d1[0]);									# Split time by "/"
	 @h=split(/:/,$d1[1]);                  						# split the hour and minutes
         $hour=$h[0];                           						# set the hour
         $year=$w[2];
	 $dates=sprintf("%04d",$w[2]).sprintf("%02d",$w[0]).sprintf("%02d",$w[1]);		# Create date date in proper format to input into database
 	 @d2=split(/\s+/,$wrd[6]);								# Split the sixth element (end date) by white space
	 @w2=split(/\//,$d2[0]);								# Split time by "/"
	 $datee=sprintf("%04d",$w2[2]).sprintf("%02d",$w2[0]).sprintf("%02d",$w2[1]);		# Create end date in proper format to input into database
         #print"$year \n";
         if ($dtype2 eq "NADP") {
            $valid_code=$wrd[7];
            $invalid_code=$wrd[8];
         }
 	 ##########################################################################
         # Crude method to determine the month from the start and end dates
         ##########################################################################
         if (($w2[0]-$w[0]) == 0) {									# Check to see if start month and end month are the same
            $month = $w[0];  										# If so, set month equal to start month
            }
         elsif (($w2[0]-$w[0]) == 2) {	# Check to see if the difference between the months is 2
            $month = $w[0]+1; 		# If so, that means we need to use the month inbetween the two (start month + 1) 
         }
         elsif (($w2[0]-$w[0]) == 1) {	# If the offset in months is 1, we need to look at the days to see which month we are dealing with
            if (($w[0] == 1) || ($w[0] == 3) || ($w[0] == 5) || ($w[0] == 7) || ($w[0] == 8) || 
               ($w[0] == 10) || ($w[0] == 12)) {							# If start month has 31 days
               $day_diff1 = 31 - $w[1];									# Compute how many days are in the start month
               $day_diff2 = $w2[1];									# Number of days in end month is just the day number
               if ($day_diff1 >= $day_diff2) { $month = $w[0]; }					# If more days in start month, set that as the month
               else { $month = $w2[0]; }								# If more days in end month, set that as the month
            }  
            elsif ($w[0] == 2) {	# If start month is February
               $feb_days = 28;
               if (($year==2000) || ($year == 2004) || ($year == 2008) || ($year == 2012)) {		# Check to see if it is a leap year
                  $feb_days = 29;
               }
               $day_diff1 = $feb_days - $w[1];								# Compute how many days are in the start month
               $day_diff2 = $w2[1];									# Number of days in end month is just the day number
               if ($day_diff1 >= $day_diff2) { $month = $w[0]; }					# If more days in start month, set that as the month
               else { $month = $w2[0]; }								# If more days in end month, set that as the month
            }
            else {											# I guess the month has 30 days
               $day_diff1 = 30 - $w[1];									# Compute how many days are in the start month
               $day_diff2 = $w2[1]; 									# Number of days in end month is just the day number
               if ($day_diff1 >= $day_diff2) { $month = $w[0]; }					# If more days in start month, set that as the month
               else { $month = $w2[0]; }								# If more days in end month, set that as the month
            }
         }
	 ########################################################################### 
         $stat_id=$wrd[0];										# Set station id name to first element in Site Compare file
         if ($hour eq "") {	#If no hour is available, just set hour to 0
            $hour=0;
         }
         if ($month eq "") {	#If no month can be calculated, set month to NULL
            $month='NULL';
         }
	 if ($dtype eq "CASTNET") { 									# If network is CASTNet
            $hour=0;											# Set ob_hour for CASTNet equal to 0
         }
         if ($dtype eq "AIRMON") {									# If AIRMON 
            $hour=0;											# Set ob_hour equal to 0
         }
         if ($dtype2 eq "NADP") {
   	    $q3_main=" VALUES  ('$run_id','$dtype','$stat_id',$wrd[1],$wrd[2], $wrd[3], $wrd[4], $dates, $datee, $hour, $month, '$valid_code', '$invalid_code'";
            for ($j=9;$j<$g;$j++) {                                                                        # For each value column in the Site Compare file
               $q3_main="$q3_main, ".sprintf("%8.10f",$wrd[$j])."";                                                # Add value to MYSQL query (q3_main)
            }
         }
         else {
            if (($stat_id eq $stat_id_previous) && ($dates eq $dates_previous) && ($datee eq $datee_previous) && ($hour eq $hour_previous)) {}	# This checks to see if the previous record entered matches the current record (stat_id, time and date); if so, entering of the record into the database is skipped
            else { 
               $q3_main=" VALUES  ('$run_id','$dtype','$stat_id',$wrd[1],$wrd[2], $wrd[3], $wrd[4], $dates, $datee, $hour, $month";
               for ($j=7;$j<$g;$j++) {                                                                        # For each value column in the Site Compare file
                  $q3_main="$q3_main, ".sprintf("%8.10f",$wrd[$j])."";                                                # Add value to MYSQL query (q3_main)
               } 
            } 
         } 
	 print "Inserting data for site $stat_id on $d1[0] \n ";	# Print to the screen the progress of the script
#         $q1_main="REPLACE INTO $dtype";	# Set part of the query used to insert the data into the database
         $q1_main="REPLACE INTO $run_id";       # Set part of the query used to insert the data into the database
	 $query=$q1_main.$q2_main.")".$q3_main.")";	# Create the entire query to insert the data into the database
#         print"$query \n";
	 $table_query = $dbh->Query($query);	# Insert the data into the database (query)
      }	# End if
      $stat_id_previous = $stat_id;
      $dates_previous = $dates;
      $datee_previous = $datee;
      $hour_previous = $hour;
      $i=$i+1;	# Move to the next line in the Site Compare file
   } # End foreach loop
} # End if

################################################
### End main section to add data to database ###
################################################

#####################################################################################################


######################################################################################################################################
### This section automatically updates the min and max dates in the project_log table each time the add_aq2dbase.pl script is run  ###
######################################################################################################################################

print "\n### Updating project log, please wait...  \n";
$query_min="SELECT proj_code,model,user_id,passwd,email,description,DATE_FORMAT(proj_date,'%Y%m%d'),proj_time,DATE_FORMAT(min_date,'%Y%m%d'),DATE_FORMAT(max_date,'%Y%m%d') from aq_project_log where proj_code='$run_id' ";	# set query for project log table for all information regarding current project
my $sth = $dbh->query($query_min);					# setup query
@row=$sth->fetchrow_array();						# excute query
$model=$row[1];								# Store query results for each field in the project log table
$user_id=$row[2];
$password=$row[3];
$email=$row[4];
$description=$row[5];
$description=~s/'//g;
$proj_date=$row[6];
$proj_time=$row[7];
$min_date_old=$row[8];
$max_date_old=$row[9];

$query_min="SELECT DATE_FORMAT(min(ob_dates),'%Y%m%d') from $run_id where network = \'$dtype\';";                    # find first date from all records in table
my $sth = $dbh->query($query_min);
@row=$sth->fetchrow_array();
$min_date=$row[0];
if ($min_date_old == 00000000) {	# override the initial value of 0 for the earliest date record
   $min_date_old = $min_date;
}
if ($min_date > $min_date_old)  {
   $min_date = $min_date_old;
}
$query_max="SELECT DATE_FORMAT(max(ob_datee),'%Y%m%d') from $run_id where network = \'$dtype\';";                    # find last date from all records in table
my $sth = $dbh->query($query_max);
@row=$sth->fetchrow_array();
$max_date=$row[0];
if ($max_date < $max_date_old) {
   $max_date = $max_date_old;
}
$query_dates="REPLACE INTO aq_project_log (proj_code,model,user_id,passwd,email,description,proj_date,proj_time,min_date,max_date) values ('$run_id','$model','$user_id','$password','$email','$description',$proj_date,'$proj_time',$min_date, $max_date)";			# put first and last dates into project log
$table_query=$dbh->Query($query_dates);					# query project log, putting in all necessary information
print "finished updating database. ###\n";
#######################################################################################################################################

exit(0);

