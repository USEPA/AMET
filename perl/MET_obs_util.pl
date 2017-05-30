#!/usr/bin/perl
#				obs_util.pl
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
#_____________________________________________________________________________________________
#_______________________________________________________________________________
#								
#	Automated Meteorological Evaluation Tool		
#								
#	Perl Subroutine Collection, 
#	Utilities to gather observational data from remote MADIS database 			
#
#	NOAA/ARL/ASMD and US EPA				
#								
#   Version 1.0 Initial development, Rob Gilliam (10-03-2004)	
#
#   Version 1.2 No Updates other than code reformatting, Rob Gilliam (05-01-2013)
#______________________________________________________________________________
#
# PURPOSE:	This is a collection of subroutines used by the AMET program.
#		
# SUBROUTINES: (See header of each subroutine for version info, changes and dates)
#              ftp_madis: subroutine that takes a date (YYYYMMDD) and grabs MADIS data given
#                         a class of observations (surface, profiler, raob, acars, mesonet or all)
#
#              auto_ftp: driver of ftp_madis subroutine above where start date of model run and number
#                        of hours is provided to grab range of dates that cover modeling period
#
#              ftp_npa: old subroutine that has been preserved but not used for some time. National Precipitation
#                       analysis data may not be availaible, so users could have to modify to suite current
#                       access to this data.
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
print "Observation gathering utilities are loaded and ready to access.\n";
  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE FTPMADIS   
# PURPOSE: Finds and ftp's user specified or amet_matching.pl specified MADIS 					
#	   observation files.
#
# INPUTS:	Observations class ($class), Date to get ($date), Local MADIS	
#		observation directory ($main_ldir)
# OUTPUT:	
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub ftp_madis
{
  local($class,$date,$main_ldir,$action)= @_;

#--------------------------------------------------------------------------------------------->>
  # Define MADIS Obs Classes along with main directory name and sub-directory
  #        |----------    Surface-Based   -----------| |-------------  Upper-Air -----------------|
  @dtyp=  ("sao"   , "metar"  , "maritime", "mesonet", "raob"  , "acarsProfiles"  , "profiler", "profiler", "hydro" );
  @ddir=  ("point" , "point"  , "point"   , "LDAD"   , "point" , "point"          ,  "point"  , "LDAD"    , "LDAD");
  @netcdf=("netcdf", "netcdf" , "netcdf"  , "netCDF" , "netcdf", "netcdf"         ,  "netcdf" , "netCDF"  , "netCDF");
  
  if($class eq "surface")		{	@obs_ind	=(0,1,2,3)		}
  elsif($class eq "profiler")		{	@obs_ind	=(6,7)			}
  elsif($class eq "raob")		{	@obs_ind	=(4)			}
  elsif($class eq "acars")		{	@obs_ind	=(5)			}
  elsif($class eq "all")		{	@obs_ind	=(0,1,2,3,4,5,6,7)	}
  elsif(class eq "mesonet")     {   @obs_ind    =(3) }
  $ntypes=scalar(@obs_ind);
#--------------------------------------------------------------------------------------------->>

  # Splits the specified date string, format YYYYMMDD_HH, where YYYY,MM,DD is year, month and day
  # and HH is the hour. However, if HH is specified as "*" (e.g., 20040404_*) then all hours will be ftp'ed
  @x = split(//,$date);
  local($y)=$x[0].$x[1].$x[2].$x[3];
  local($m)=$x[4].$x[5];
  local($d)=$x[6].$x[7];
  local($h)=$x[9].$x[10];

  # Get current date and time
  local($cy,$cm,$cd,$chour,$cmin,$csec) = Today_and_Now([$gmt]);

        #-------------------------------------------------------------------------------------------------
        # Compute the difference in days, of the specified time and current time. This is used to determine
        # if the archive or real-time MADIS directory should be searched. The if-then statments define the 
        # remote directory depending on if archive or real-time is determined.
        #-------------------------------------------------------------------------------------------------
        $Dd = Delta_Days($cy,$cm,$cd, $y*1,$m*1,$d*1);
        if($Dd < -3) {
        	print "MADIS archive directory will be used...\n";
        	$main_rdir="/archive/".$y."/".$m."/".$d;
        }
        elsif ($Dd <= 0 ) {
        	print "MADIS real-time directory will be used...\n";
        	$main_rdir="";
        }
        else {
        	print "The specified date is not availiable yet, aborting MADIS ftp script\n";
        	exit(0);
        }
        #-------------------------------------------------------------------------------------------------
  
  #-------------------------------------------------------------------------------------------------
  if($action eq "ftp") {
    #-------------------------------------------------------------------------------------------------
    # (1) Open FTP connection, (2) Loop through the specified obs classes, and (3) GET data
    #--------------------------------------------------------->>
  
    open(FTP, "|ftp -np") or die "Can't fork ftp: $!\n";
    print "Connecting to the NOAA FSL data server......\n";
    print FTP "open $fslftp_madis\n";
    print FTP "user $login_madis $pass_madis\n";
    print FTP "bin\n";
    print FTP "prompt\n";
  
    for (local($i)=0;$i<=$ntypes;$i++){
	
	$lobsdir=$main_ldir."/".$ddir[$obs_ind[$i]]."/".$dtyp[$obs_ind[$i]]."/".$netcdf[$obs_ind[$i]];
	$robsdir=$main_rdir."/".$ddir[$obs_ind[$i]]."/".$dtyp[$obs_ind[$i]]."/".$netcdf[$obs_ind[$i]];
	## test that there are at least 24 files for this day
	@test_file=glob($lobsdir."/$y$m$d\_*00");
        $num_files = $#test_file + 1;  
    @test_gzfile = glob($lobsdir."/$y$m$d\_*00.gz");
    	$num_gzfiles = $#test_gzfile + 1;
	if($num_files >= 24 || $num_gzfiles >= 24) {
        	print "Skipping ftp because files are present...\n";
        }
        else {
        	print "Remote MADIS data directory is set to $robsdir/$date* \n";
        	print FTP "lcd  $lobsdir \n";
        	print FTP "cd  $robsdir \n";
        	print FTP "mget  $date*\n";
        }
    }
    print FTP "quit\n";
    close(FTP);	
 } # END Condition that action is to ftp new MADIS obs files 
 elsif($action eq "unzip"){
    for (local($i)=0;$i<$ntypes;$i++){	
	    $lobsdir=$main_ldir."/".$ddir[$obs_ind[$i]]."/".$dtyp[$obs_ind[$i]]."/".$netcdf[$obs_ind[$i]];
        print "Unzipping MADIS observational data $lobsdir/$date* \n";
	    `gunzip -f $lobsdir/$date*.gz`;
    }

 } # END Condition that action is to unzip MADIS obs files
 elsif($action eq "zip"){
    for (local($i)=0;$i<$ntypes;$i++){
        $lobsdir=$main_ldir."/".$ddir[$obs_ind[$i]]."/".$dtyp[$obs_ind[$i]]."/".$netcdf[$obs_ind[$i]];
        print "Zipping MADIS observational data $lobsdir/$date* \n";
	    `gzip -f $lobsdir/$date*`;
    }
 } # END Condition that action is to zip MADIS obs files
 #-------------------------------------------------------------------------------------------------
 
 # If action is remove (rm) then cycle through obs directory and remove the used
 # MADIS observations files
 #-------------------------------------------------------------------------------------------------
 if($action eq "rm") {
  for (local($i)=0;$i<$ntypes;$i++){
	
	$lobsdir=$main_ldir."/".$ddir[$obs_ind[$i]]."/".$dtyp[$obs_ind[$i]]."/".$netcdf[$obs_ind[$i]];
        print "Removing MADIS observational data $lobsdir/$date* \n";
	`rm -f $lobsdir/$date*`;
  }
 } # END Condition that action is to remove old files
  return();

 #-------------------------------------------------------------------------------------------------
 	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________

#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE AUTO_FTP   
# PURPOSE: LOOP through days of model run and download MADIS observations 					
#
# INPUTS:	Observations class ($class), Date start to get ($date), number of	
#		hours in model run, Local MADIS observation directory ($main_ldir)
# OUTPUT:	
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub auto_ftp
{
  local($class,$dates,$num_hours,$main_ldir,$action)= @_;


  local($ndays)=($num_hours/24);		
  local($y,$m,$d,$h,$file_full_path)=split(/-/,$dates);

  local($year,$month,$day,$hour,$min,$sec) = Add_Delta_DHMS($y,$m,$d,$h,0,0,0,$ndays,0,0);
   
  for(local($i)=0;$i< $ndays;$i++){  	
  	($year,$month,$day)=Add_Delta_Days($y,$m,$d,$i);
  	local($date)=sprintf("%04d",$year).sprintf("%02d",$month).sprintf("%02d",$day)."_*";
  	print "Observations will be gathered for $year,$month,$day: day ".($i+1)." of $ndays  $date\n";
        &ftp_madis($class,$date,$main_ldir,$action);
  }
  return();

} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________




#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE get_npa   
# PURPOSE: FTP NPA/MPE Precipitation files from NCEP					
#
# INPUTS: 	
# OUTPUT:	
#
# NOTE: For precipitation data older than 3 days needs to be manually downloaded from
#       http://www.joss.ucar.edu/cgi-bin/codiac/fgr_form/id=21.049 (pre 2002)
#	http://www.joss.ucar.edu/cgi-bin/codiac/fgr_form/id=21.089 (post 2001) and placed
#	in the /MADIS_OB_DIR/npa directory and uncompressed. The automated real-time
#	download script can be intiated to archive this data on a users local machine 
#	for future applications (/ametbase/bin/get_realtime_obs.pl).				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub ftp_npa
{
	local($date,$lbobsdir) = @_;

  # Splits the specified date string, format YYYYMMDD_HH, where YYYY,MM,DD is year, month and day
  # and HH is the hour. However, if HH is specified as "*" (e.g., 20040404_*) then all hours will be ftp'ed
  @x = split(//,$date);
  local($y)=$x[0].$x[1].$x[2].$x[3];
  local($m)=$x[4].$x[5];
  local($d)=$x[6].$x[7];
  local($h)=$x[9].$x[10];

  # Get current date and time
  local($cy,$cm,$cd,$chour,$cmin,$csec) = Today_and_Now([$gmt]);

        #-------------------------------------------------------------------------------------------------
        # Compute the difference in days, of the specified time and current time. This is used to determine
        # if the archive or real-time MADIS directory should be searched. The if-then statments define the 
        # remote directory depending on if archive or real-time is determined.
        #-------------------------------------------------------------------------------------------------
        $Dd = Delta_Days($cy,$cm,$cd, $y*1,$m*1,$d*1);
        if($Dd > -3 & $Dd <= 0 ) {
        	print "NPA directory will be used...\n";
  		$rdir="pub/data/nccf/com/hourly/prod/nam_pcpn_anal.".$y.$m.$d;
        }
        else {
        	print "The specified date is not availiable yet, aborting NPA ftp script\n";
        	exit(0);
        }
        #-------------------------------------------------------------------------------------------------


  #--------------------------------------------------------->>
  # 			Ftp Specs
  $ldir		=$lbobsdir."/npa";
  $cur_file	="multi15.".$y.$m.$d.$h.".Z";
  #--------------------------------------------------------->>

  print "Getting NPA from NCEP server, remote directory $rdir\n";
  print "Placing data in local directory $ldir\n";
  #--------------------------------------------------------->>
  open(FTP, "|ftp -n") or die "Can't fork ftp: $!\n";
  print FTP "open $fslftp_ncep\n";
  print FTP "user $login_ncep $pass_ncep\n";
  print FTP "bin\n";
  print FTP "prompt\n";
  print FTP "pas\n";

  print FTP "cd $rdir\n";
  print FTP "lcd $ldir\n";
  print FTP "mget $cur_file\n";
  print FTP "quit\n";
  close(FTP);
   
  `gunzip $ldir/$cur_file`;

} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
