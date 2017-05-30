#!/usr/bin/perl
#				amet_matching.pl
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
#_____________________________________________________________________________________________
#_______________________________________________________________________________
#								
#	Automated Meteorological Evaluation Tool		
#								
#	Main Model-Matching Program
#
#	NOAA/ARL/ASMD and US EPA				
#								
#   Version 1.0 Initial development, Rob Gilliam (07-20-2003)	
#
#   Version 1.1 Refine, make more efficient and clean code (08-15-2005)	
#
#   Reorganized to work in combined MET/AQ mode, Alexis Zubrow (IE UNC-CH), Oct 2007
#______________________________________________________________________________
#
# PURPOSE:	Cycle through model output and match with availiable observations
#		
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________


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

## get some environmental variables
$amet_perl_input = $ENV{'AMETPERLINPUT'} 
    or die "Must set AMETPERLINPUT environmental variable\n";
$amet_out = $ENV{'AMET_OUT'} 
    or die "Must set AMET_OUT environmental variable\n";

## setup some paths
$amet_bin = "$amet_base/bin";
$amet_perl = "$amet_base/perl";

# directory of mm5tonetcdf utilities archiver and examiner
$mm5tonetcdf_utils=$amet_bin;

# directory of madis software
$madis_utils=$amet_bin;

## Get user defined variables from perl input
require $amet_perl_input;

# LOAD Required Perl Modules
use lib $perl_lib;
use Sort::Fields;
use DBI;
use Mysql;
use PDL;
use PDL::NetCDF;
use PDL::Char;
use Date::Calc qw(:all);

# LOAD required subroutines from AMET 
require "$amet_perl/MET_init_amet.pl";
require "$amet_perl/MET_xtrac_obs_madis.pl";
require "$amet_perl/MET_model_to_obs.pl";
require "$amet_perl/MET_profile_util.pl";
require "$amet_perl/MET_obs_util.pl";
#require "$amet_perl/MET_R_util.pl";
require "$amet_perl/MET_eta_subs.pl";
#require "$amet_base/configure/MET_amet-www-config.pl";

# If a real-time run, make sure the output file is not accidentally deleted
if($real_time eq 1) {   $rm_output_file=0;	}

## test that amet_out and tmp_dir exist
unless ( -d $amet_out){
    print "$amet_out doesn't exist, creating it.\n";
    mkdir $amet_out;
}
unless ( -d $tmp_dir ){
    print "$tmp_dir doesn't exist, creating it.\n";
    mkdir $tmp_dir;
}

#####################################################
# Parse AMET matching configuration file
&parse_lookup($match_config);
## move to tmp_dir so that all the MADIS output is written there
chdir($tmp_dir);
#####################################################
# Print executing messages
print "\n\n ************************  Starting the Execution of AMET  ********************************\n\n";
#--------------------------------------------------------
@nd=("31","28","31","30","31","30","31","31","30","31","30","31");	#Array that provides the number of days for each month (used in some date calculations)
@months=("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec");	# Standard abbriviation for each month
$mabrvS=$months[$mS-1];
##:::::::::::::::::::::::::::::::::::::::::::::::::##
&define_program_directories;
$num=sprintf("%02d",rand(9));
## Unique number for the program execution
$unique_run_num=$num;	

$dump_file="surfdump".$unique_run_num;
$file_num=1;


##:::::::::::::::::::::::::::::::::::::::::::::::::##
#
#	1. Input date/time of comparison
#	2. Open files in Model NetCDF dump directory 
#	3. Sort through model files to find the file that corresponds to the observations time
#	4. Find grid point that corresponds to observation
#	5. Extract data at gripoint and time interval that corresponds to observation
#
my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass)
    or die "Unable to connect to MySQL database $dbase.  Check server, user and/or passwords.\n";	
##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::##
if ($model eq "mm5" | $model eq "wrf" | $model eq "mcip"){
	if($model eq "mcip"){
		@model_files = glob("$model_data_dir/METCRO2D*"); # List METCRO2D files
	}
	else{
    	@model_files = glob("$model_data_dir/*");             # list contents of MM5 output directory
    }

    foreach $file_full_path (@model_files){               # LOOP THROUGH THE INDIVIDUAL FILES IN MAIN MM5 Dump directory
	
	###  This subroutine takes the MM5 or WRF output and queries for date time information.
	###  It also converts MM5 output to NetCDF if the flag $file_date exists (e.g. $file_date=1)
	($model_file,$date_start,$num_hours, $fcast_hr,$init_utc)=&model_date($file_full_path,$model,$file_date);
	## Load model output file and intialize model output dependent variables
	$mod  = PDL::NetCDF->new ($model_file); 
	if($file_num == 1){
	    &set_model_files($model,$model_file);
	    &get_var_dims(@mod_id);
	    $site_pdl  = zeroes(5000,2);  			# generate universal observation site array with i-j location and site id
	    @j_site=();
	    @i_site=();
	    @siteid_array=();
	    #my $pchar = PDL::Char->new( [['abc', 'def', 'ghi'],['jkl', 'mno', 'pqr']] );
   	}
        ####################################################################################################################
	#	Supplementary "Ease of Use" Options
        ####################################################################################################################
        ### Option via AMET configuration file to automatically ftp observations from MADIS archive
        if($auto_ftp eq 1){
	    print "Getting MADIS data via ftp... \n";
	    &auto_ftp($eval_class,$date_start,$num_hours,$obs_dir,"ftp");
        }
        if($auto_unzip eq 1){
        	print "Unzipping MADIS data... \n";
        	&auto_ftp($eval_class,$date_start,$num_hours,$obs_dir,"unzip");
        }
        ## Option to Process NPA Precipitation (e.g. interpolate observed precipitation to model grid and produce grid files)
        if($process_npa){
	    &gen_npa($model_file);
        }
        ####################################################################################################################
	
	## Loop through model file and match with observations
	eval{
	    &loop_mod_time($date_start,$nt,$output_int,$eval_int);
	};

        if( ($file_date eq 0 & $model eq "mm5") || $rm_output_file eq 1 ){
        	print "Removing temporary mm5 netcdf file $model_file \n";
        	system("rm $model_file");
	}

    ### Option to zip observational files after matching to save disk space
    if($auto_zip eq 1){
        	print "Zipping MADIS data... \n";
        	&auto_ftp($eval_class,$date_start,$num_hours,$obs_dir,"zip");
    }

	$file_num=$file_num+1;

	
    }  # END of LOOP THROUGH MODEL OUTPUT FILES	
}   # END OF MM5 OR WRF OPTION

elsif($model eq "eta"){
    $dump_wgrib="$obs_dir/$dump_file";
    $init_utc=12;
    open (LIST, "ls -l $model_data_dir/aqm* |");
    local($i)=0;
    print "\n\n********** THE FOLLOWING ETA MODEL FILES WILL BE EVALUATED *****************\n";
    while (<LIST>) {
	@tmp1=split(/\s+/,$_);			# Split each line by white space, get file path
	@tmp2=split(/\//,$tmp1[8]);		# Split file path by / to get file name
	$path_length=scalar(@tmp2)-1;
	$eta_file_full_path=$tmp1[8];
	$date_start=&get_eta_dims($eta_file_full_path);	### Get the dimensions, grid specs and date info from model output
	
	$model_file[$i]=$eta_file_full_path;			# Define next MM5 file name
	print "File $i : $eta_file_full_path \n";
	$i=$i+1;
    }
    $nt=$i;$v=0;
    print "$date_start $i\n";
    &set_model_files($model,$model_file[0]);
    &loop_mod_time($date_start,$nt,1); 
    
}   # END OF ETA OPTION
else {
    ## unkown model type
    die "Model type ($model) unrecognized.\n";
}

## update the min and max dates for all projects
system "$amet_base/perl/MET_update_project_log.pl";

exit(0);
##############################################################################
##############################################################################
