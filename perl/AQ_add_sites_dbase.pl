#!/usr/bin/perl
##------------------------------------------------------
#	Surface Station Update Script 			#
#							#
#	PURPOSE: To update the surface station		#
#		database information (id,lat,lon,elev)	#
#							#
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

## Get a couple of environmental variables
$obs_data_dir = $ENV{'AMET_OBS'};
$amet_perl_input = $ENV{'AMETPERLINPUT'};


# LOAD Required Perl Modules
use lib $perl_lib;                                      # Add custom perl package path
use Mysql;
use CGI;
use DBI;


require $amet_perl_input;			        ## Perl input file, user defined variables


## db connection
my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass)
    or die "Could not connect to database, $dbase \n";	

## loop over each networks site data and populate the db
foreach $site_file  (@site_file) {							# For each network
   open (DAT,"< $site_file");@dat=<DAT>;$l=scalar(@dat);chomp(@dat);		# Open network site list
   close(DAT);
   print "Accessing site metadata from: $site_file\n";
   $i=0;
   foreach $dat (@dat) {
      if($i > 0){
         @wrd=split(/,/,$dat[$i]);
         print "Inserting metadata for station $wrd[0] for $wrd[3] network\n ";					# Update user on progress
         $q1="REPLACE INTO site_metadata";									# Set part of the MYSQL query
         $q2="         (stat_id, num_stat_id, stat_name, network, state, city, start_date, end_date, lat, lon, elevation)";	# Set part of the MYSQL query
         $q3=" VALUES  (\"$wrd[0]\", \"$wrd[1]\", \"$wrd[2]\", \"$wrd[3]\", \"$wrd[4]\", \"$wrd[5]\", \"$wrd[6]\", \"$wrd[7]\", ".sprintf("%3.5f",$wrd[8]).", ".sprintf("%3.5f",$wrd[9]).", ".sprintf("%10.0f",$wrd[10]).")";
         $query=$q1.$q2.$q3;											# Set the MYSQL query
         print "$query \n";
         $table_query = $dbh->Query($query);									# Add the site list to the database
      }	
      $i=$i+1;													# Move to the next site
   }
}

open (DAT,"< $aqs_site_file");@dat=<DAT>;$l=scalar(@dat);chomp(@dat);		# Use a slightly different method for the AQS site list
close(DAT);
print "Accessing site metadata from: $aqs_site_file\n";
$i=0;
foreach $dat (@dat) {
   if($i > 0){
      @wrd=split(/,/,$dat[$i]);
      $landuse = @wrd[11];
      #print "@wrd[11] \n";
      $stat_id=$wrd[1].$wrd[2].$wrd[3];
      print "Inserting metadata for station $stat_id for $wrd[5] network\n ";					# Update user on progress
      $q1="REPLACE INTO site_metadata";										# Set part of the MYSQL query
      $q2=" (stat_id, num_stat_id, network, state, city, landuse, lat, lon)";					# Set part of the MYSQL query
      $q3=" VALUES  (\"$stat_id\", \"$stat_id\", \"$wrd[5]\", \"$wrd[0]\", \"$wrd[11]\", \"$landuse\", ".sprintf("%3.5f",$wrd[9]).", ".sprintf("%3.5f",$wrd[10]).")";	# Set part of the MYSQL query
      $query=$q1.$q2.$q3;											# Set the MYSQL query
      print "$query \n";
      $table_query = $dbh->Query($query);									# Add the site list to the database
   }
   $i=$i+1;													# Move to the next site
}

exit(0);

