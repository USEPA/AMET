#!/usr/bin/perl
#				obs_to_model.pl
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
#_____________________________________________________________________________________________
#_______________________________________________________________________________
#								
#	Automated Meteorological Evaluation Tool		
#								
#	Perl Subroutine Collection, 
#	Match model forecast/analysis to observation database.			
#
#	NOAA/ARL/ASMD and US EPA				
#								
#   Version 1.0 Initial development, Rob Gilliam (07-20-2003)	
#   Version 1.1 Secondary development, Rob Gilliam (08-25-2005)	
#   Version 1.2 Updates and new functionality, Rob Gilliam (05-01-2013)
#               - VAD wind capability. A new eval_class vadwind was added to match WRF only model outputs with VAD wind observations. 
#                 This option is in the new code, but not fully supported as it requires a utility that converts VAD profiles in  
#                 NCEP PREPBUFR obs files to a MADIS-like text format.
#
#               - SurfRAD SW radiation obs matching. In previous versions, SurfRAD matching was done within the match_sfcobs subroutine. 
#                 This was pulled out of match_sfcobs and made a new eval_class via a new match_surfrad subroutine. Since it's not used 
#                 as frequently, it not only makes code cleaner, but gives users more control over the model-obs matching.
#
#               - get_surfrad subroutine updated: Previous version has some errors. It was commented out, so unless a user is
#                 wise enough to enable, this should not impact previous versions. The new version compares model shortwave radiation 
#                 at grid closest to SurfRad site. SurRAD data is at 1 min intervals, so a 20 min aveerage shorwave rad is computed for
#                 comparison to the model.
#
#______________________________________________________________________________
#
# PURPOSE:	This is a collection of subroutines used by the AMET program.
#		
# SUBROUTINES: (See header of each subroutine for version info, changes and dates)
#		loop_mod_time:  Starts at the intial model time and loops through each hour of model					
#                   run. During each loop, the correct date stamp is generated, then the 
#                   observations for the date/time is extracted, then the model data is matched
#                   with the observation and stored in the the obs-model dump file
#
#		match_sfcobs:   Reads surface observation file and matches with model output in time and space				
#
#   match_surfrad:  Added in version 1.3. Similar to match_sfcobs, but matches shortwave radiation only.
#
#		latlon_to_ij:   Finds the closest i,j gridpoint to a given lat-lon coordinate. This only works right now
#                   with a Lambert Conformal projection which is configured according to the attributes of the model output.
#
#	get_model_grids:  Extracts the model grid array for matching with the observations.
#
# get_regular_grid: Extracts the model grid at a single time step.
#
#		get_tdiff_grid: Extracts the model grid difference between two times, mostly used for model output that contains total precipitation.
#                   In these cases, it is required to subtract successive time steps to get hourly precip for example.
#
#		interp_2d:      This routine computes the i,j index that corresponds to a lat, lon value
#/netscr/ushankar/AMET_v12/output/mm5Example/spatial_surface/mm5Example.rmse.T.20020705.20020709.pdf
#		interp_2dv2:    This routine computes the i,j index that corresponds to a lat, lon value. Version 2 not used right now.
#
#		get_surfrad:    This module is used to extract NOAA SurfRad data
#
#		cal_diag_vars:  Caculates surface related variables that are not in raw model output. Specfically designed for EPA MM5 output that does not contain 10 m wind or mixing ratio
#
#		dot_to_cross:   Interpolates variabile from dot to cross points
#
# dot_to_cross_10wind: Interpolates wind from dot to cross points and caculates 10 m wind via similarity relationships
#
#		sfclayer:       Wind speed interpolation from model level to 10 m using Similarity-based caculations
#
#		distance:       Caculates distance between two pairs of lat-lon values (not used yet)
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

# LOAD Required Perl Modules
use lib $perl_lib;                                      # Add custom perl package path
use Mysql;                                              # Use MYSQL perl package
use DBI;                                                # Use DBI perl package

print "Model forecast/analysis to observation matching subroutines are loaded and ready to access.\n";

#_____________________________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE loop_mod_time   
# PURPOSE: Starts at the intial model time and loops through each hour of model					
#	output. At each iteration of the loop, the correct date stamp is generated, then the 
#	observations for the date/time are extracted, then the matching subroutine is called
#	for the specified observation type (surface, profile, raob, etc.)
# INPUTS:	Initial date stamp of model simulation, Number of times in model
# OUTPUT:	obs-model dump file for each observation type
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub loop_mod_time
{	
	local($mod_strt_time, $nt, $output_int, $eval_int) = @_;
	local($yC, $mC, $dC, $hC)=split(/-/,$time_of_comp);			# Model-Obs comparison time breakdown
	($yS, $mS, $dS, $hS)=split(/-/,$mod_strt_time);				# Model start time
	@nd=("31","28","31","30","31","30","31","31","30","31","30","31");	#Array that provides the number of days for each month (used in some date calculations)

	local($y)=$yS;local($m)=$mS;local($d)=$dS;local($h)=$hS;
	$tcomp=0;$fcast_hr=0;$last_time=0;
	local($t)=0;
	while ($tcomp < $nt){

    $timeget=sprintf("%04d",$y).sprintf("%02d",$m).sprintf("%02d",$d)."_".sprintf("%02d",$h)."00";
    $mysql_time=sprintf("%04d",$y).sprintf("%02d",$m).sprintf("%02d",$d);
    $hour=sprintf("%02d",$h).":00:00";
    print "\n****************************************************************\n";
    print "Processing the model time.... $eval_class $timeget Time Index: $tcomp Fcast Hour:  $fcast_hr \n ";
    ####	Set up observation file for the various observation formats
	  #### use time index_start to skip certain # of initial time steps 
	  #### (see populate_project.input)
    if( $tcomp > $time_index_start ){

     if(($eval_class eq "surface" | $eval_class eq "all") & $obs_format eq "madis"){
			$obs_file_sfc=&madis_util($timeget,0);

			if(-s "$obs_file_sfc"){
				print "Matching Surface observations and model output: $obs_file_sfc\n"; 
				eval{  &match_sfcobs($obs_file_sfc,$tcomp);  };
			}
			else { print "Observations were not found for $timeget \n"; }
		 }
		 if(($eval_class eq "profiler" | $eval_class eq "all") & $obs_format eq "madis"){
			$obs_file_map=&madis_util($timeget,2);
			$obs_file_npn=&madis_util($timeget,4);
			if(-s "$obs_file_npn"){
				print "Matching NPN Profiler observations and model output: $obs_file_npn\n";
				eval {&match_profiler($obs_file_npn,$tcomp,"npn");};
				$good=1;
      }
			else { print "Observations were not found for $timeget \n"; }
			 if(-s "$obs_file_map"){
				print "Matching MAP Profiler observations and model output: $obs_file_map\n";
				eval {&match_profiler($obs_file_map,$tcomp,"map");};
				$good=1;
			 }
      else { print "Observations were not found for $timeget \n"; }
		 }
		 if(($eval_class eq "raob" | $eval_class eq "all") & $obs_format eq "madis"){
			$obs_file_raob=&madis_util($timeget,1);
			if(-s "$obs_file_raob"){
				print "Matching RAOB observations and model output: $obs_file_raob\n"; 
				eval{&match_raob($obs_file_raob,$tcomp); };
				$good=1;
			}
			else { print "Observations were not found for $timeget \n"; }
		 }
		 if(($eval_class eq "acars" | $eval_class eq "all") & $obs_format eq "madis"){
			$obs_file_acars=&madis_util($timeget,3);
			print "Obs file $obs_file_acars \n"; 
			if(-s "$obs_file_acars"){
				print "Matching ACARS observations and model output: $obs_file_raob\n"; 
				eval{&match_acars($obs_file_acars,$tcomp); };
				$good=1;
			}
			else { print "Observations were not found for $timeget \n"; }
		 }
		 if($eval_class eq "profiler" & $obs_format eq "exp"){
			$obs_file1="$tmp_dir/$timeget";
			$obs_file2="$obs_dir/tdl/$timeget";
			$filesiz=2000;
			if(-s "$obs_file1"){$filesiz1=2000;}
			if(-s "$obs_file2"){$filesiz2=2000;}
		 }
		 if( $eval_class eq "vadwind"  ){
			$obs_file_vad=$obs_dir."/vadwind/".sprintf("%04d",$y).sprintf("%02d",$m).sprintf("%02d",$d)."_".sprintf("%02d",$h)."00";
			if(-s "$obs_file_vad"){
				print "Matching VAD Profiler observations and model output: $obs_file_vad\n";
				eval {&match_vad($obs_file_vad,$tcomp,"vad");};
				$good=1;
			}
			else { print "Observations were not found for $timeget \n"; }
		 }
		 if($eval_class eq "surfrad"){
			$surfrad_file_date="castnet.".sprintf("%04d",$y).".".sprintf("%02d",$m).".".sprintf("%02d",$d).".".sprintf("%02d",$h);
			$obs_file_srad="$obs_dir/surfrad";
      print "Matching SURFRAD observations and model output.\n";
			&match_surfrad($obs_file_srad,$tcomp);
		 }
		 if($obs_format eq "castnet" & $eval_class eq "surface"){
			$castnet_file_date="castnet.".sprintf("%04d",$y).".".sprintf("%02d",$m).".".sprintf("%02d",$d).".".sprintf("%02d",$h);
			$obs_file_sfc="$obs_dir/castnet/$castnet_file_date";
			&match_sfcobs($obs_file_sfc,$tcomp);
		 }
		 if($obs_format eq "npa" | $eval_class eq "none"){
			#  NPA Precip processing only option allows user to use amet_matching 
			#  to automatically process NPA data only. Do nothing, skip time period
			print "Skip time, processing NPA....\n";
		 }
		$good=1;

    }
    else {
     print "ABORTED matching for this hour !!!   (Either obs file  or model data missing)\n";
     $good=0;
    }
    ################   Advance Date/time to next hour
    local($ndm)=$nd[$m-1]+0;
    $h=$h+$eval_int;
    if ($h>23)	{$h=0;$d=$d+1;}
    if ($d>$ndm)	{$d=1;$m=$m+1;}
    if ($m>12)	{$m=1;$y=$y+1;}
    #################################	
    #### Saftey check to prevent an infinite loop that periodically occurs
    if($last_time eq $timeget)	{    print "Abort becuase of infininte loop\n";  exit(0);	}
    $last_time=$timeget;		
    ####  Advance forecast hour (fcast_hr) and model time index (tcomp) to next time interval
    $fcast_hr=($fcast_hr+$eval_int)*$forecast;		# Update Forecast Hour
    $tcomp=$tcomp+ int($eval_int/$output_int);			# Update time index of model output
    $t=$t+1;						# Advance to next iteration
	}
	if($rm_output_file eq 1 & $good eq 1) {	`rm -f $original_model_file`;		}
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE match_sfcobs  
# PURPOSE: Read in surface observations and match with model output in space in time					
#		Additional tasks are opportunistically completed.
#		
# INPUTS:	ascii surface_obs from sfcdump.exe utility, time index of model output
#		that corresponds to observations.	
# OUTPUT:	records are inserted into the model evaluation database
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub match_sfcobs
{
	local($obs_file,$tcomp) = @_;	# Define local variables
	local($i, $l, $v);		# Define local variables
	my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass)
	    or die "Unable to connect to MySQL database $dbase.  Check server, user and/or passwords.\n";	
	$table_name	=$pid."_surface";								
        ##########################################################################################################
	# 	Open surface observation file and put in an array
	#$obs_file="/project/amet/obs/tdl/ncarob.2001.06.19.12";
	open (DAT,"< $obs_file");@lin=<DAT>;$l=scalar(@lin);chomp(@lin);close(DAT);
        if ($l<10){print "No data in observation file $obs_file, will skip this time period\n";return;}
	if($obs_format eq "madis"){
		@lin=fieldsort [2],@lin;
		@lin=fieldsort [3],@lin;
	}
	# Extracts Regular 2-D (x-y) grid (e.g. temperature, mix ratio, wind, insolation, precip) into memory
	# in preperation of next step
	&get_model_grids($model,$tcomp,$model_file[$tcomp]);
        ##########################################################################################################
	# 	LOOP through surface observation file and match surface obs with model in space and time
	#	1. Match SURFRAD insolation obs to model if present
	#	2. Loop through each line in the obs file, if line contains and observations, find all other obs for that location/station
	#	   and generate the observation portion of the query string. Once all observations for the site have been found. 
	#	3. Find i,j index of model grid that corresponds geographically to obs site, then extract model values at the grid point.
	# 	4. Generate model value portion of query string, and then create entire query string that will put obs-model pairs in database
	#	5. Insert data in evaluation database
        ##########################################################################################################
	# STEP 1
  $count=1;$ov=0;							
	for (local($i)=0;$i<=$l;$i++){					# STEP 2
		@str=split(/\s+/,$lin[$i]);				
		@str_next=split(/\s+/,$lin[$i+1]);
		@var_str=split(/-/,$str[1]);
		# Determine the observation type of the current line
		$latob=$str[4];$lonob=$str[5];
    $landwater_flag=1;
		$ob_platform=$str[9];
		$ob_elev=$str[3];
		$stat_id=$str[2];
		$stat_id_next=$str_next[2];
		
		if ($stat_id eq $stat_id_next & $var_str[0] eq "V"){
			$tmp_num=$str[10]*$conversion_fac[$v];
			$mysql_obs_str="$mysql_obs_str $var_str[1]_ob, ";
			$mysql_obs_num="$mysql_obs_num $str[10], ";			
			$ov=$ov+1;
			$new_stat=0;					
		}
		elsif($var_str[0] eq "V") {
			$tmp_num=$str[10]*$conversion_fac[$v];
			$mysql_obs_str="$mysql_obs_str $var_str[1]_ob ";
			$mysql_obs_num="$mysql_obs_num $str[10] ";
			if($model eq "eta"){$iob=$str[6];$job=$str[7];}
			else {			
         ($iob,$job)=&latlon_to_ij($ALAT1, $ELON1, 0, 0, $ALATAN1, $ALATAN2, $ELONV, $DX, $DX, $latob, $lonob);
			 }
			 if (	($iob < 0 || $iob >= $NX[$v]-5) || ($job < 0 || $job >= $NY[$v]-5 ) ){	@obs_var=();$mysql_obs_str="";$mysql_obs_num=""; next;	}			#  Skip Observation if off model grid
                        
                        # Determine closeness of observation site to land/water interface.
                        # If obs site is land-based, but grid cell is mostly water, then skip matching
                        # If obs site is water-based, but grid cell is mostly land, then skip matching
                        # If obs site is land (water)-based and grid cell is mostly land (water) then test is passed.
                         
                        $mod_landf=&interp_2d($land,$iob,$job,$latob,$lonob,$interp_method);

                        if($mod_landf == -99.99) {  @obs_var=(); $mysql_obs_str=""; $mysql_obs_num=""; next; }
                        $mod_elev=&interp_2d($mod_elevg,$iob,$job,$latob,$lonob,$interp_method);
                        ($mod_lu,$iob,$job)=&interp_2d($lu,$iob,$job,$latob,$lonob,1);
                        
                        if($model eq "mm5"){ 
                	        if($mod_lu eq 16) { $mod_landf = 0; }
                	        else { $mod_landf = 1; }
                	      }	
                        
                        #if($model eq "wrf" & $ob_platform ne "MARITIME" & $mod_landf < 0.75) { $landwater_flag=0;; }
                        #if($model eq "wrf" & $ob_platform eq "MARITIME" & $mod_landf > 0.25) { $landwater_flag=0;; }
                        if( $ob_platform ne "MARITIME" & $mod_landf < 0.75) { $landwater_flag=0;; }
                        if( $ob_platform eq "MARITIME" & $mod_landf > 0.25) { $landwater_flag=0;; }
                        $elev_diff= abs $ob_elev-$mod_elev;
                        if( $elev_diff > 200.0 )              { $landwater_flag=0; }

			# STEP 3
			$mod_t		  =&interp_2d($temp_2m,$iob,$job,$latob,$lonob,$interp_method);
			$mod_u		  =&interp_2d($u_10m,$iob,$job,$latob,$lonob,$interp_method);
		  $mod_v		  =&interp_2d($v_10m,$iob,$job,$latob,$lonob,$interp_method);	
			$mod_q		  =&interp_2d($mixr_2m,$iob,$job,$latob,$lonob,$interp_method);
			$mod_swrad	=&interp_2d($srad,$iob,$job,$latob,$lonob,$interp_method);

	    $mod_p = 0;
	    if($tcomp != 0) { 
			 $mod_p=&interp_2d($pcp1h,$iob,$job,$latob,$lonob,$interp_method);	
      }
			if ($model eq "eta"){
				$landuse=10;
			}
			#else {
			#	 ($mod_lu,$iob,$job)=&interp_2d($lu,$iob,$job,$latob,$lonob,1);		# Nearest Neighbor Interpolation
			# }
                        #print "$stat_id,  ($iob , $job) ($latob, $lonob)   $mod_lu    $mod_landf   $mod_elev   <<<<<  $landwater_flag  >>>>>>\n";
                         
			# STEP 4
			if($model ne "mcip"){
				$mysql_mod_str="T_mod, Q_mod, U_mod, V_mod, PCP1H_mod, SRAD_mod";
				$mysql_mod_num=sprintf("%12.5f",$mod_t).", ".sprintf("%12.5f",$mod_q).", ".sprintf("%12.5f",$mod_u).", ".sprintf("%12.5f",$mod_v).", ".sprintf("%12.5f",$mod_p).", ".sprintf("%12.5f",$mod_swrad);
			}
			else{ # MCIP does not have Q or SRAD
				$mysql_mod_str="T_mod, U_mod, V_mod, PCP1H_mod";
				$mysql_mod_num=sprintf("%12.5f",$mod_t).", ".sprintf("%12.5f",$mod_u).", ".sprintf("%12.5f",$mod_v).", ".sprintf("%12.5f",$mod_p);
			}

			if($obs_format eq "castnet"){	$ob_net="castnet";		}
			else {				$ob_net="$str[9]";		}
			
			# STEP 4
			$q1="REPLACE INTO $table_name ";
			$q2="(proj_code, stat_id, i, j, landuse, ob_date, ob_time, fcast_hr, init_utc, level, $mysql_obs_str, $mysql_mod_str)";
			$q3="VALUES ('$project_name','$stat_id',$iob,$job,$mod_lu,'$mysql_time','$hour',$fcast_hr,$init_utc,$level[$v], $mysql_obs_num, $mysql_mod_num)";		
			$query=$q1.$q2.$q3;
			@obs_var=();$mysql_obs_str="";$mysql_obs_num="";
			$count=$count+1;
			$ov=$ov+1;
			$new_stat=$new_stat+1;					      
			if($amet_verbose eq "yes")	{ print "$count --> Adding $stat_id to table $table_name\n";	}

			  if(landwater_flag gt 0) {
			      unless ($table_query = $dbh->Query($query)) {
				  ## If there is an error adding this data, don't fail
				  ## just print the query to stdout
				    print "ERROR in replace for stat_id = $stat_id\n";
				    print "query: $query \n";
				}
			  }	
		}
		else {
			@obs_var=();
			$mysql_obs_str="";
			$mysql_obs_num="";
		}
		
	}	# End of LOOP THROUGH SFCDUMP.TXT	
	print "Successfully Completed !\n"; 
	print "****************************************************************\n";
	return();
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))

#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE match_surfrad  
# PURPOSE: Read in surfrad observation file and extract model shortwave down and 				
#		       match in time and space
# INPUTS:	ascii daily SURFRAD file, time index of model output
#		      that corresponds to observations.	
# OUTPUT:	records are inserted into the model evaluation database
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub match_surfrad
{
	local($surfrad_dir,$tcomp) = @_;	# Define local variables

	# Extracts Regular 2-D (x-y) grid (e.g. temperature, mix ratio, wind, insolation, precip) into memory
	# in preperation of next step
	&get_model_grids($model,$tcomp,$model_file[$tcomp]);
  ##########################################################################################################
  ##########################################################################################################
	# STEP 1
	&get_surfrad($srad,$surfrad_dir,$y,$m,$d,$h);
	print "Successfully Completed SURFRAD matching!\n"; 
	print "****************************************************************\n";
	return();
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#/*  Subroutine to convert from lat-lon to lambert conformal i,j.
#    Provided by NRL Monterey; converted to C 6/15/94.
#
#c          SUBROUTINE: ll2lc
#c
#c          PURPOSE: To compute i- and j-coordinates of a specified
#c                   grid given the latitude and longitude points.
#c                   All latitudes in this routine start
#c                   with -90.0 at the south pole and increase
#c                   northward to +90.0 at the north pole.  The
#                   longitudes start with 0.0 at the Greenwich
#                   meridian and increase to the east, so that
#                   90.0 refers to 90.0E, 180.0 is the inter-
#                   national dateline and 270.0 is 90.0W.
#c
#          INPUT VARIABLES:
#c
#  vals+0    reflat: latitude at reference point (iref,jref)
#c
#  vals+1    reflon: longitude at reference point (iref,jref)
#c
#  vals+2    iref:   i-coordinate value of reference point
#c
#  vals+3    jref:   j-coordinate value of reference point
#c
#  vals+4    stdlt1: standard latitude of grid
#c
#  vals+5    stdlt2: second standard latitude of grid (only required
#                    if igrid = 2, lambert conformal)
#c
#  vals+6    stdlon: standard longitude of grid (longitude that
#                     points to the north)
#c
#  vals+7    delx:   grid spacing of grid in x-direction
#                    for igrid = 1,2,3 or 4, delx must be in meters
#                    for igrid = 5, delx must be in degrees
#c
#  vals+8    dely:   grid spacing (in meters) of grid in y-direction
#                    for igrid = 1,2,3 or 4, delx must be in meters
#                    for igrid = 5, dely must be in degrees
#c
#            grdlat: latitude of point (grdi,grdj)
#c
#            grdlon: longitude of point (grdi,grdj)
#c
#            grdi:   i-coordinate(s) that this routine will generate
#                    information for
#c
#            grdj:   j-coordinate(s) that this routine will generate
#                    information for
#c
#*/
sub latlon_to_ij 
{

	local($reflat, $reflon, $iref, $jref, $stdlt1, $stdlt2, $stdlon, $delx, $dely,
	       $grdlat, $grdlon ) = @_;

  
  $pi = 4.0*atan(1.0);
  $pi2 = $pi/2.0;
  $pi4 = $pi/4.0;
  $d2r = $pi/180.0;
  $r2d = 180.0/$pi;
  $radius = 6371229.0;
  $omega4 = 4.0*$pi/86400.0;

  #/*mf -------------- mf*/
  #/*case where standard lats are the same */

  #/* corrected by Dan Geiszler of NRL; fabs of the 
  # lats was required for shem cases */


  if($stdlt1 == $stdlt2) {
    $gcon = sin( abs($stdlt1) * $d2r);
  } 
  else {
    $gcon = (log(sin((90.0- abs($stdlt1))* $d2r))
	    -log(sin((90.0- abs($stdlt2))* $d2r)))
      /(log(tan((90.0- abs($stdlt1))*0.5* $d2r))
	-log(tan((90.0- abs($stdlt2))*0.5* $d2r)));
  }
  #/*mf -------------- mf*/
  $ogcon = 1.0/$gcon;
  $ahem = abs( $stdlt1 / $stdlt1 );
  $deg = (90.0- abs($stdlt1)) * $d2r;
  $cn1 = sin($deg);
  $cn2 = $radius * $cn1 * $ogcon;
  $deg = $deg * 0.5;
  $cn3 = tan($deg);
  $deg = (90.0- abs($reflat)) * 0.5 * $d2r;
  $cn4 = tan($deg);
  $rih = $cn2 * pow($cn4 / $cn3, $gcon);
  $deg = ($reflon-$stdlon) * $d2r * $gcon;
  $xih = $rih * sin($deg);
  $yih = -1 * $rih * cos($deg) * $ahem;

  $deg = ($90.0 - ($grdlat * $ahem) ) * 0.5 * $d2r;
  $deg = (90.0- $grdlat * $ahem) * 0.5 * $d2r;
  $cn4 = tan($deg);
  
  $rrih = $cn2 *  ($cn4/$cn3)**$gcon;
  $check = 180.0-$stdlon;
  $alnfix = $stdlon + $check;
  $alon = $grdlon + $check;
  if ($alon<0.0)  { $alon = $alon+360.0; }
  if ($alon>360.0){ $alon = $alon-360.0; }
  $deg = ($alon-$alnfix) * $gcon * $d2r;
  $XI = $rrih * sin($deg);
  $XJ = -1* $rrih * cos($deg) * $ahem;


  $grdi = $iref+($XI-$xih)/($delx);
  $grdj = $jref+($XJ-$yih)/($dely);

  return($grdi,$grdj);

} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))

#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE get_regular_grid
# PURPOSE: 	Extracts the model grid array for matching with the observations. 					
#		This only works with regular, single time period array
# INPUTS:	variable array number and model type
#		
# OUTPUT:	A 2-D grid array of the specified variable at the specified time
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub get_model_grids
{
	local($model,$tcomp,$model_file)=@_;
#	        local($t)=$tcomp-1;

#print "^^^^^^^^^^^^^^^ $mod_id[$v] $ndims[$v]  ^^^^^^^^^^^^^^^\n";
		if ( $model eq "mm5" ) {
      if ($diagnose_sfc eq 1 ){
			$temp_2m=&cal_diag_vars(0,$model,$tcomp);
			$mixr_2m=&cal_diag_vars(1,$model,$tcomp);
			$u_10m=&cal_diag_vaget_regular_gridrs(2,$model,$tcomp);
			$v_10m=&cal_diag_vars(3,$model,$tcomp);
			$srad=&cal_diag_vars(4,$model,$tcomp);
		  $pcp1h=&get_tdiff_grid(5,$tcomp,1,$model);
		  $land=&get_regular_grid(99,$model,$tcomp); 
		  }
		  else {
		  	$temp_2m=&get_regular_grid(0,$model,$tcomp);
			  $mixr_2m=&get_regular_grid(1,$model,$tcomp);
		  	$u_10m=&get_regular_grid(2,$model,$tcomp);
		  	$v_10m=&get_regular_grid(3,$model,$tcomp);
		  	$srad=&get_regular_grid(4,$model,$tcomp); 
		  	$pcp1h=&get_tdiff_grid(5,$tcomp,1,$model);
		  	$land=&get_regular_grid(99,$model,$tcomp); 
		  }
		}
		elsif ( $model eq "wrf" ) {
      $lonc=$ELONV;
      $cfac=0;
      $temp_2m=&get_regular_grid(0,$model,$tcomp);
      $mixr_2m=&get_regular_grid(1,$model,$tcomp);
      $u_10m=&get_regular_grid(2,$model,$tcomp);
      $v_10m=&get_regular_grid(3,$model,$tcomp);
      $srad=&get_regular_grid(4,$model,$tcomp); 
      $land=&get_regular_grid(99,$model,$tcomp); 
      $pcp1h=&get_tdiff_grid(5,$tcomp,1,$model);
      $ws10=sqrt( $u_10m*$u_10m + $v_10m*$v_10m );
      $dir = 180+(360/(2*$pi))*atan2($u_10m,$v_10m);	       		

      $lonp -> reshape;	  	
      $diff = ($lonc - $lonp) * $cfac;
      #$dir =$dir-$diff;
			$u_10m=(-1)*$ws10*sin($dir*$pi/180);
			$v_10m=(-1)*$ws10*cos($dir*$pi/180);
		}
		elsif ( $model eq "mcip" ) {
      $lonc=$ELONV;
      $cfac=0;
      $temp_2m=&get_regular_grid(0,$model,$tcomp);
      $mixr_2m=&get_regular_grid(0,$model,$tcomp);
      $ws10   =&get_regular_grid(1,$model,$tcomp);
      $dir    =&get_regular_grid(2,$model,$tcomp);
      $srad   =&get_regular_grid(0,$model,$tcomp); 
      $land   =&get_regular_grid(99,$model,$tcomp); 
      $pcp1h  =&get_tdiff_grid(3,$tcomp,1,$model);
		  			  	
      #$diff = ($lonc - $lonp) * $cfac;   			
      #$mid= min($diff);
      #$mad= max($diff);
      #$dir =$dir-$diff;
      
      $f1= at($dir,(5,5));
			$u_10m=(-1)*$ws10*sin($dir*$pi/180);
			$v_10m=(-1)*$ws10*cos($dir*$pi/180);
			
		}
		elsif ($model eq "eta") {
			$temp_2m=&get_eta_var_grid($mod_id[0],$model_file);
			$mixr_2m=&get_eta_var_grid($mod_id[1],$model_file);
			$u_10m=&get_eta_var_grid($mod_id[2],$model_file);
			$v_10m=&get_eta_var_grid($mod_id[3],$model_file);
			$srad=&get_eta_var_grid($mod_id[4],$model_file);
			$pcp1h=&get_eta_var_grid($mod_id[5],$model_file);
			$strloc1		=":,:";		# Current array dimensions (x,y,t)
		}
		
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE get_regular_grid
# PURPOSE: 	Extracts the model grid array for matching with the observations.
#		This only works with regular, single time period array
# INPUTS:	variable array number and model type
#
# OUTPUT:	A 2-D grid array of the specified variable at the specified time
#
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub get_regular_grid
{
	local($v,$model,$tcomp)=@_;
#	        local($t)=$tcomp-1;
	local($var_array);
		if ($model eq "wrf" ) {
			if ($ndims[$v] eq 3 & $v != 99){$var_array=$mod->get($mod_id[$v],[$tcomp,0,0],[1,$NY[$v],$NX[$v]]);	}# Extract entire grid from file for current variable
			if ($ndims[$v] eq 4 & $v != 99){$var_array=$mod->get($mod_id[$v],[$tcomp,0,0,0],[1,$NZ[$v],$NY[$v],$NX[$v]]);	}# Extract entire grid from file for current variable
			if ( $v eq 99){
				$var_array=$mod->get("LANDMASK",[$tcomp,0,0],[1,$NY[0],$NX[0]]);
				$lu       =$mod->get("LU_INDEX",[$tcomp,0,0],[1,$NY[0],$NX[0]]);
				$mod_elevg=$mod->get("HGT",[$tcomp,0,0],[1,$NY[0],$NX[0]]);
				return($var_array);
			}
		}
		if ($model eq "mm5" ) {
			if ($ndims[$v] eq 3){$var_array=$mod->get($mod_id[$v],[$tcomp,0,0],[1,$NY[$v],$NX[$v]]);	}# Extract entire grid from file for current variable
			if ($ndims[$v] eq 4){$var_array=$mod->get($mod_id[$v],[$tcomp,0,0,0],[1,$NZ[$v],$NY[$v],$NX[$v]]);	}# Extract entire grid from file for current variable
			if ( $v eq 99){
				$var_array=$mod->get("land_use",[0,0],[$NY[0],$NX[0]]);
				$lu       =$mod->get("land_use",[0,0],[$NY[0],$NX[0]]);
				$mod_elevg=$mod->get("terrain",[0,0],[$NY[0],$NX[0]]);
				return($var_array);
			}
		}
		if ($model eq "mcip" ) {
			
			if ($ndims[$v] eq 3 & $v != 99){$var_array=$mod->get($mod_id[$v],[$tcomp,0,0],[1,$NY[$v],$NX[$v]]);	}# Extract entire grid from file for current variable
			if ($ndims[$v] eq 4 & $v != 99){$var_array=$mod->get($mod_id[$v],[$tcomp,0,0,0],[1,$NZ[$v],$NY[$v],$NX[$v]]);	}# Extract entire grid from file for current variable
			if ( $v eq 99){
				$var_array =$mod_grid->get("LWMASK",[0,0,0,0],[1,$NZ[0],$NY[0],$NX[0]]);
				$lu =$mod_grid->get("DLUSE",[0,0,0,0],[1,$NZ[0],$NY[0],$NX[0]]);
				$mod_elevg =$mod_grid->get("HT",[0,0,0,0],[1,$NZ[0],$NY[0],$NX[0]]);
				$ntmpdim   = $mod_elevg->getndims;
				return($var_array);
			}

		}


		if ($model eq "eta") {
			$var_array=&get_eta_var_grid($mod_id[$v],$tcomp);
			$strloc1		=":,:";		# Current array dimensions (x,y,t)
		}
			($meandt,$rmsdt,$mediandt,$mindt,$maxdt) = stats($var_array);
	
return($var_array);

} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE get_tdiff_grid
# PURPOSE: 	Extracts the model grid array for matching with the observations 					
#
# INPUTS:	variable array number and model type
#		
# OUTPUT:	A 2-D grid array of the specified variable at the specified time
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub get_tdiff_grid
{
	local($o,$t,$dt,$model)=@_;

		if ($model eq "wrf" || $model eq "mm5" ) {
		        local($var_array,$strloc1,$var1a,$var1b,$var1,$var2a,$var2b,$var2);
		        local($t1)=$t-$dt;	
			if ($t eq 0){
				$var1b=$mod->get($mod_id[$o],[$t,0,0],[1,$NY[$v],$NX[$v]]);	# Extract entire grid from file for current variable
				$var2b=$mod->get($mod_id[$o+1],[$t,0,0],[1,$NY[$v],$NX[$v]]);	# Extract entire grid from file for current variable
				$var_array=$var1b+$var2b+0.0001;
			}
			else {
				$var1a=$mod->get($mod_id[$o],[$t1,0,0],[1,$NY[$v],$NX[$v]]);	# Extract entire grid from file for current variable
				$var1b=$mod->get($mod_id[$o],[$t,0,0],[1,$NY[$v],$NX[$v]]);	# Extract entire grid from file for current variable
				$var1=$var1b-$var1a;
				$var2a=$mod->get($mod_id[$o+1],[$t1,0,0],[1,$NY[$v],$NX[$v]]);	# Extract entire grid from file for current variable
				$var2b=$mod->get($mod_id[$o+1],[$t,0,0],[1,$NY[$v],$NX[$v]]);	# Extract entire grid from file for current variable
				$var2=$var1b-$var1a;
				$var_array=$var1+$var2+0.0001;
 				return($var_array);
			}
			########################    Variable Specific Hardcode ###############################
			
		}
		elsif ($model eq "mcip") {
		        local($var_array,$strloc1,$var1a,$var1b,$var1,$var2a,$var2b,$var2);
		        local($t1)=$t-$dt;	
			if ($t eq 0){
				$var1b=$mod->get($mod_id[$o],[$t,0,0,0],[1,1,$NY[$v],$NX[$v]]);	# Extract entire grid from file for current variable
				$var2b=$mod->get($mod_id[$o],[$t,0,0,0],[1,1,$NY[$v],$NX[$v]]);	# Extract entire grid from file for current variable
				$var_array=$var1b+$var2b+0.0001;
			}
			else {
				$var1a=$mod->get($mod_id[$o],[$t1,0,0,0],[1,1,$NY[$v],$NX[$v]]);	# Extract entire grid from file for current variable
				$var1b=$mod->get($mod_id[$o],[$t,0,0,0],[1,1,$NY[$v],$NX[$v]]);	# Extract entire grid from file for current variable
				$var1=$var1b-$var1a;
				$var2a=$mod->get($mod_id[$o+1],[$t1,0,0,0],[1,1,$NY[$v],$NX[$v]]);	# Extract entire grid from file for current variable
				$var2b=$mod->get($mod_id[$o+1],[$t,0,0,0],[1,1,$NY[$v],$NX[$v]]);	# Extract entire grid from file for current variable
				$var2=$var1b-$var1a;
				$var_array=$var1+$var2+0.0001;
 				return($var_array);
			}
		}
		elsif ($model eq "eta") {
			local($t)=$t-1;
			$var_array=&get_eta_var_grid($mod_id[$o],$t);
			$strloc1		=":,:";		# Current array dimensions (x,y,t)
		}

	return($var_array);


} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE round
# PURPOSE: 	Round number
#		
#						
#
# INPUTS:	real number
#		
# OUTPUT:	rounded value
#				  
sub round {
    my($number) = shift;
    return int($number + .5);
}
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE interp_2d
# PURPOSE: 	This routine computes the i,j index that corresponds to a lat, lon value				
#
# INPUTS:	Grid piddle, Grid coordinates in decimal form, interpolation type
#		
# OUTPUT:	interpolated value
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub interp_2d 
{
	local($grid,$i,$j,$lat,$lon,$interp_type)=@_;
	local($x1,$x2,$y1,$y2,$value);
	local($tmpa,$min,$count,$grid_space_km);

  if ($interp_type eq 0 ){ 
	  $dx=$i- int($i);
	  $dy=$j- int($j);
	  $x1= int($i);$x2=$x1+1;
	  $y1= int($j);$y2=$y1+1;

	   @c11=($x1,$y1);
	   @c21=($x2,$y1);
	   @c12=($x1,$y2);
	   @c22=($x2,$y2);

	   $f1= at($grid,@c11)+ ( $dx * (at($grid,@c21)-at($grid,@c11)) );
	   $f2= at($grid,@c12)+ ( $dx * (at($grid,@c22)-at($grid,@c12)) );
	   $value_mod=$f1 + ($dy* ($f2-$f1) );
     return ($value_mod);     	                         
  }
  elsif ($interp_type eq 1) {	# Nearest neighboor interpolation
	  $i_mod=$i;
	  $j_mod=$j;
	  $dx=$i- int($i);
	  $dy=$j- int($j);
	  if ($dx > 0.5){$i=int($i)+1;}
	  else{$i=int($i);}
		
	  if ($dy > 0.5){$j=int($j)+1;}
	  else{$j=int($j);}
	  @c=($i,$j);
	  if ($model eq "wrf"){
	   @c=($i,$j,0);
	  }
	  $value_mod=at($grid,@c);
    $i_mod=sprintf("%6.2f",$i_mod);
    $j_mod=sprintf("%6.2f",$j_mod);
	  @value_mod=(($value_mod, $i_mod, $j_mod));
    return (@value_mod);
  }
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))

#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE interp_2d
# PURPOSE: 	This routine computes the i,j index that corresponds to a lat, lon value
#		This is version 2 which has proven to be cleaner code, but less efficient. 
#		This routine has been left in the subroutine list in case further enhancements					
#
# INPUTS:	Grid piddle, Grid coordinates in decimal form, interpolation type
#		
# OUTPUT:	interpolated value
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub latlon2ij 
{
	local($lat,$lon)=@_;
	local($x1,$x2,$y1,$y2,$value);
	local($tmpa,$tmp1,$tmp2,$min, $ii, $jj);
        
        $tmp1 = $lonp - pdl $lon ;
        $tmp2 =$latp - pdl $lat ;
        $tmpa = pow((pow($tmp1,2) + pow($tmp2,2)),0.50);
	($mean,$rms,$median,$min,$max) = stats($tmpa);
	$indx=which $tmpa <=$min;		# Find which index values are associated with the minimum grid value
	@coordsMin=one2nd($tmpa, $indx);	# Put index values into array (i,j,k,t)-->(x-dir,y-dir,z-dir,time)
	local($ii)=list $coordsMin[0];
	local($jj)=list $coordsMin[1];

        if (	($ii < 0 || $ii >= $NX[0]-5) || ($jj < 0 || $jj >= $NY[0]-5 ) ) {
                  return((0,0));	
        }
        #print "$ii  $jj \n";
	if($model eq "mm5"){
	  $latMin=sprintf("%8.3f",$latp->at($ii,$jj));
	  $lonMin=sprintf("%8.3f",$lonp->at($ii,$jj));	
	}
	elsif($model eq "wrf"){
	  $latMin=sprintf("%8.3f",$latp->at($ii,$jj,1));
	  $lonMin=sprintf("%8.3f",$lonp->at($ii,$jj,1));	
	}
        return (($ii,$jj));
						#  (e.g. Model gridpoint i=1,j=1 eq i=0,j=0 in perl because arrays start at zero not 1)
    
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________

#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE get_surf_rad   
# PURPOSE: 	This module is used to extract NOAA SurfRad data from a specific				
#		formatted text file. The format contains a lat-lon header followed
#		by records of various radiation parameters. 
# INPUTS:	Date, time, Time increment relative to met file
#		
# OUTPUT:	Net solar radiation observation
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub get_surfrad 
{
	local($var_array,$surfrad_dir,$y,$m,$d,$h)=@_;
	local($value,$jd,$y2,@surfrad_id,$nsurfrad,$i,$hr,$min,$lat,$lon,$o,$k,$mod);
	my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass)
	    or die "Unable to connect to MySQL database $dbase.  Check server, user and/or passwords.\n";	
  $table_name=$pid."_surface";
	$jd=&julianDate($y,$m,$d);
	$jd=sprintf("%03d",$jd);
	@y2=split(//,$y);$y2=$y2[2].$y2[3];

	@surfrad_id=("psu","bon","gwn","dra","fpk","tbl","sxf");
	#@surfrad_id=("gwn");
	$nsurfrad=scalar(@surfrad_id);
  $mintoaverage = 10;
  
  ########  SITE LOOP  ######
	for($stat_num=0;$stat_num<$nsurfrad;$stat_num++){
    $surfrad_file=$surfrad_id[$stat_num].$y2.$jd.".dat";
    print "$surfrad_dir/$y/$surfrad_file\n";
    @line=();
		open (SURF,"< $surfrad_dir/$y/$surfrad_file");@line=<SURF>;$l_surf=scalar(@line);chomp(@line);close(SURF);
		$o=0;
   
		$surfrad_full_name=$line[0];
		@words=split(/\s+/,$line[1]);
		$latob=$words[1];
    $lonob=$words[2];
		for($o=2;$o<$l_surf;$o++){
			@words=split(/\s+/,$line[$o]);
			#if ($jd > 90 & $jd <301){
			#  $hr=sprintf("%02d",$words[5]+1);	
      #}	# Daylight savings time adjustment by Julian Day. This is set for 2001 so may need to be modified for other years
			#else {
      #}
      #$hr=sprintf("%02d",$words[5]);		
			#$min=sprintf("%02d",$words[6]);
      $hr_obs=$words[5] * 1;
      $min_obs=$words[6] *1;
      $hr_model=$h * 1;
      #print "Hour and min from surfrad file $hr $min from Model $h \n";

			if($hr_obs == $hr_model & $hr_obs > 0 & $min_obs == 0){
        #print "Hour and min from surfrad file $hr $min from Model $h \n";
				$val=0;
				for(local($k)=(-1*$mintoaverage);$k<=($mintoaverage-1);$k++){
				  @v1=split(/\s+/,$line[$o+$k]);
				  #print @vl."	$k	$v1[9]\n";
				  $val=$val+$v1[9];
				  #print "value--> $vl[8] $vl[9] $vl[10]\n";
				  #print "value > 00Z --> $val + $vl[9]  full lines:   $v1[0] $v1[1] $v1[2] $v1[3] $v1[4] $v1[5] $v1[6] $v1[7] $v1[8] $v1[9]  \n";
				}
				$value=$val/(2*$mintoaverage);
	      #print "mean hourly --> $value\n";
				if ($value lt 0 & $value != -9999.9){$value=0;}
				last;
      }
			if($hr_obs == $hr_model & $hr_obs == 0 ){
        #print "Hour and min from surfrad file $hr $min from Model $h \n";
				$val=0;
				for(local($k)=0;$k<=($mintoaverage-1);$k++){
				  @v1=split(/\s+/,$line[$o+$k]);
				  #print @vl."	$k	$v1[9]\n";
				  $val=$val+$v1[9];
				  #print "value--> $vl[8] $vl[9] $vl[10]\n";
				  #print "value 00 Z $o $k --> $val $v1[9]   full lines:    $v1[1] - $v1[2] - $v1[3] - $v1[4] - $v1[5] - $v1[6] - $v1[7] - $v1[8] - $v1[9] : \n";
				}
				$value=$val/$mintoaverage;
	      #print "mean hourly --> $value\n";
				if ($value lt 0 & $value != -9999.9){$value=0;}
				last;
      }

      $o=$o+1;	
	  }
    ($iob,$job)=&latlon_to_ij($ALAT1, $ELON1, 0, 0, $ALATAN1, $ALATAN2, $ELONV, $DX, $DX, $latob, $lonob);	
	  
	  if (	($iob < 0 || $iob >= $NX[0]-3) || ($job < 0 || $job >= $NY[0]-3 ) ){next;}
	  
	  $mod=&interp_2d($srad,$iob,$job,$latob,$lonob,$interp_method);		# Linear Interpolation

    if ($ob eq "-9999.9"){
	    $q3="VALUES ('$pid','$surfrad_id[$stat_num]',".sprintf("%4.0f",$iob).",".sprintf("%4.0f",$job).",'$mysql_time','$hour',$fcast_hr,$init_utc,NULL,".sprintf("%10.3f",$mod).")";
	  } 
	  else {
	    $q3="VALUES ('$pid','$surfrad_id[$stat_num]',".sprintf("%4.0f",$iob).",".sprintf("%4.0f",$job).",'$mysql_time','$hour',$fcast_hr,$init_utc,".sprintf("%10.3f",$value).",".sprintf("%10.3f",$mod).")";
	  }
	
    $q1="REPLACE INTO $table_name ";
	  $q2="(proj_code, stat_id, i, j, ob_date, ob_time, fcast_hr, init_utc, SRAD_ob, SRAD_mod)";
	  $query=$q1.$q2.$q3;
	  $table_query = $dbh->Query($query);
	  #print "$query \n";
	  if($amet_verbose eq "yes")	{ print "SurfRAD site $surfrad_id[$stat_num] $iob $job ".sprintf("%10.3f",$value).",".sprintf("%10.3f",$mod)."\n";	}

  }
  ########  SITE LOOP  ######
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE cal_diag_vars   
# PURPOSE: 	This module was specifically designed to use with the MM5 model				
#		output that was generated for the 2001 Year-Long simulation. Main
#		reason is that the original output did not have 2 m specific humidity
#		or 10 m winds. The module uses similarity theory for the 10 m wind
#		and output of 2 m RH and 2 m temperature to caculate specific humidity.
# INPUTS:	variable index number
#		
# OUTPUT:	diagnosed variable grid
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub cal_diag_vars
{
	local($o,$model,$t)=@_;
	local($var);
	if ($obs_id[$o] eq "T"){
		$var_array=$mod->get("t2", [$t,0,0], [1,$NY[$var_num_sub]  ,$NX[$var_num_sub]] );
	}
	
	if ($obs_id[$o] eq "Q"){
		local($zlev)=$NZ[$o]-1;
		$var_array=$mod->get("q", [$t,$zlev,0,0], [1,1,$NY[$var_num_sub]  ,$NX[$var_num_sub]] );
	}

	if ($obs_id[$o] eq "WVMR"){
		local($zlev)=$NZ[$o]-1;
		$var_array=$mod->get("q", [$t,$zlev,0,0], [1,1,$NY[$var_num_sub]  ,$NX[$var_num_sub]] );
	}

	if ($obs_id[$o] eq "U"){
		local($z)	=10;
		local($pi)	=3.14159265358979;				
		local($karman)	=0.40;
		local($ny)	=$NY[$o]-1;
		local($nx)	=$NX[$o]-1;
		local($zlev)	=$NZ[$o]-1;
		
		# Extract the first level wind components
		$u_wind=$mod->get("u", [$t,$zlev,0,0], [1,1,$NY[$var_num_sub]  ,$NX[$var_num_sub]] );
		$v_wind=$mod->get("v", [$t,$zlev,0,0], [1,1,$NY[$var_num_sub]  ,$NX[$var_num_sub]] );

		# Extract variables to caculate height of first level where u and v are solved
		$ptop	=$mod->get("ptop", [1],[1]);@ptop=list $ptop;$ptop=$ptop[0];		
		$psmpt	=$mod->get("pstarcrs");
		$sig	=$mod->get("sigma_level",   [  $zlev ]  , [1] );@sig=list $sig;$sig=$sig[0];
		$rho=1.27;
		$grav=9.8;
		$part1=($sig*$psmpt)+$ptop;
		$part2=$psmpt+$ptop;
		$part3=-1*$rho*$grav;
		
		$sigma_first_layer_height=($part1-$part2)/$part3;

		# Extract micromet variables use to caculate 10 m winds via similarity theory
		$pblh	=$mod->get("pbl_hgt", [$t,0,0], [1,$ny  ,$nx] );
		$mo	=$mod->get("m-o_leng", [$t,0,0], [1,$ny  ,$nx] );
		$ust	=$mod->get("ust",     [$t,0,0], [1,$ny  ,$nx] );
		$znt	=$mod->get("znt",     [0,0]   , [  $ny  ,$nx] );
		$cfac	=$mod->get("conefac");
		$lonc	=$mod->get("coarse_cenlon");
		
		# Call dot to cross point interpolation and 10 m wind caculation subroutine. THis is only used for AMD MM5 runs which do not contain 2 m wind and 2 m mixing ratio
		($u10_array,$v10_array)=&dot_to_cross_10wind($u_wind,$v_wind,$ust,$mo,$znt,$sigma_first_layer_height,$cfac,$lonc);
		$var_array=$u10_array;
		
	}
	if ($obs_id[$o] eq "V"){
		$var_array=$v10_array;
	}
	if ($obs_id[$o] eq "PCP1H"){
		$var_array=&get_tdiff_grid($mod_id[$o],$t,1,$model);		# Extracts Time difference field such as in MM5 where total precip is stored and you have to subtract time periods to get the amount.
		$v=$v+1;
	}
	if ($obs_id[$o] eq "SRAD"){
		$var_array=$mod->get($mod_id[$o], [$t,0,0], [1,$NY[$var_num_sub]  ,$NX[$var_num_sub]] );
	}

	return($var_array);

} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE dot_to_cross   
# PURPOSE: Interpolates (Linear) a variable grid from dot points (u,v,w) to cross points					
#
# INPUTS:	A variable array on dot points
# OUTPUT:	A variable array on cross points
#_____________________________________________________________________________________________________
#				Change Documentaion
#   Version 1.0 Initial development, Rob Gilliam (09-23-2003)
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub dot_to_cross
{
	local($var) = @_;
	local($nx,$ny,$nz,$i,$j,$k,$interp_val,$ndims,@dims);
	@dims=$var->dims;
	$ndims = $var->getndims;
	$nx=$dims[0]-1;
	$ny=$dims[1]-1;
	$nz=$dims[2];

	local($new_var)=zeroes($nx,$ny,$nz);
	if ($ndims eq 4){
		$slc=':,:,:,(-1)';
		$var=$var->slice($slc);
	}
	if ($ndims eq 3 ){
		local($new_var)=zeroes($nx,$ny,$nz);
	}
	elsif($ndims eq 2){
		local($new_var)=zeroes($nx,$ny);
	}
	@dims=$new_var->dims;
	$ndims = $new_var->getndims;
	$nx=$dims[0];
	$ny=$dims[1];
	$nz=$dims[2];


	for ($j=0;$j<$ny;$j++){
		for ($i=0;$i<$nx;$i++){
			

			if ($ndims eq 3 ){
				for ($k=0;$k<$nz;$k++){
					@interp_loc	=($i,$j,$k); 
					@p1=($i,$j,$k);@p2=($i+1,$j,$k);@p3=($i,$j+1,$k);@p4=($i+1,$j+1,$k);	
					$interp_val=( (at($var,@p1)) +(at($var,@p1)) +(at($var,@p1)) +(at($var,@p1)) )/4;
					set $new_var, @interp_loc, $interp_val;
				}	
			}
			
			elsif($ndims eq 2){
				@interp_loc	=($i,$j); 
				@p1=($i,$j);@p2=($i+1,$j);@p3=($i,$j+1);@p4=($i+1,$j+1);	
				$interp_val=( (at($var,@p1)) +(at($var,@p1)) +(at($var,@p1)) +(at($var,@p1)) )/4;
				set $new_var, @interp_loc, $interp_val;
			}

		}
	}
	

	return($new_var);	
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE dot_to_cross_10wind   
# PURPOSE: 	Interpolates (Linear) a variable grid from dot points (u,v) to cross points					
#		Then interpolate to a certain model level.
# INPUTS:	A variable array on dot points
# OUTPUT:	A variable array on cross points
#_____________________________________________________________________________________________________
#				Change Documentaion
#   Version 1.0 Initial development, Rob Gilliam (09-23-2003)
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub dot_to_cross_10wind
{
	local($u_wind_var,$v_wind_var,$ustar,$amol,$z0,$sigma_first_layer_height,$cfac,$lonc) = @_;
	local($nx,$ny,$nz,$i,$j,$k,$interp_val,$ndims,@dims);
	local($u1, $z1, $z2, $ustar, $amol, $z0);
	$var=$u_wind_var;
	$z1=10;
	
	@dims=$var->dims;
	$ndims = $var->getndims;
	$nx=$dims[0]-1;
	$ny=$dims[1]-1;
	$nz=$dims[2];
	
	$DX[$v]=$nx;
	$DY[$v]=$ny;

	local($new_var1)=zeroes($nx,$ny);
	local($new_var2)=zeroes($nx,$ny);

	if ($ndims eq 4){
		$slc=':,:,:,(-1)';
		$var=$var->slice($slc);
	}
	if ($ndims eq 3 ){
		local($new_var1)=zeroes($nx,$ny,$nz);
	}
	elsif($ndims eq 2){
		local($new_var1)=zeroes($nx,$ny);
	}
	@dims=$new_var1->dims;
	$ndims = $new_var1->getndims;
	$nx=$dims[0];
	$ny=$dims[1];
	$nz=$dims[2];


	for ($j=0;$j<$ny;$j++){
		for ($i=0;$i<$nx;$i++){
			
				@interp_loc	=($i,$j);
												 
			######	Move Wind from Dot to Cross points and calculate wind speed 
				@p1=($i,$j);@p2=($i+1,$j);@p3=($i,$j+1);@p4=($i+1,$j+1);	
				$u_interp_val=( (at($u_wind_var,@p1)) +(at($u_wind_var,@p1)) +(at($u_wind_var,@p1)) +(at($u_wind_var,@p1)) )/4;
				$v_interp_val=( (at($v_wind_var,@p1)) +(at($v_wind_var,@p1)) +(at($v_wind_var,@p1)) +(at($v_wind_var,@p1)) )/4;
				$ws=pow( (($u_interp_val*$u_interp_val)+($v_interp_val*$v_interp_val) ),0.5);

			######	Set Micro-Met Variables for current grid-point 
				$zlev1	=at($sigma_first_layer_height,@interp_loc);	# Height (m) of first-level gridpoint
				$ustar	=at($ust,@interp_loc);				# Friction Velocity
				$amol	=at($mo,@interp_loc);				# Monin-Obukhov Length
				$z0	=at($znt,@interp_loc);				# Roughness Length
				$lonpt	=at($lonp,@interp_loc);
				($ws10,$ws10_exp)=&sfclayer($ws, $zlev1, 10, $ustar, $amol, $z0);

				if ($ws10 < 0.10){		# if wind speed is very low set to minimum value 0.10 m/s
					$ws10=0.10;
				}
				
			######	Calculate Wind Direction, then U10, V10 from interpolated Wind Speed and  Wind Direction first model level
			######		NOTE: Need to add algorithm to calculate wind direction, not just assume its the same as the first model level
    				$dir = 180+(360/(2*$pi))*atan2($u_interp_val,$v_interp_val);
   				$diff = ($lonc - $lonpt) * $cfac;
#   				print "$j $diff\n";
    				$dir =$dir-$diff;
				$u_10=(-1)*$ws10*sin($dir*$pi/180);
				$v_10=(-1)*$ws10*cos($dir*$pi/180);

			######	Populate new U10,V10 arrays 
				set $new_var1, @interp_loc, $u_10;
				set $new_var2, @interp_loc, $v_10;
			
#	DEBUG			print sprintf("%8.2f",$ws10)."	".sprintf("%8.2f",$dir)."	".sprintf("%8.2f",$u_10)."	".sprintf("%8.2f",$v_10)." \n";
#	DEBUG			print "Similarity Wind interp from $zlev m to $z1 m : $u1 to $ws10 m/s\n";
		}
	}
	
				return($new_var1,$new_var2);
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE loop_mod_time   
#!-------------------------------------------------------------------------------
#! Name:     Surface Layer (Copied and convert to perl from MCIP)
#! Purpose:  Interpolate wind to a given height using surface layer
#!           similarity based on Hogstrom (1988).
#! Revised:  13 Oct 1998  Original version.  (J. Pleim)
#!           20 Sep 2001  Converted to free-form f90.  (T. Otte)
#!           25 Jan 2002  Corrected error in calculation of PSIM.  (T. Otte)
#!           21 Jan 2004  Converted code to perl subroutine  (R. Gilliam)
#!-------------------------------------------------------------------------------
sub sfclayer {
	
   local($u1, $z1, $z2, $ustar, $amol, $z0)= @_;
   
   # $u1	= Wind Speed at first model level
   # $z1	= Height (m) of first model level
   # $z2	= Height (m) to interpolate wind too (e.g., 10 m)
   # $ustar	= Friction velocity (m/s)
   # $amol	= Monin-Obukhov Length (m)
   # $z0	= Surface roughness length (m)
   local($u2);

 # Similarity constants from Hogstrom (1988).
   $vkar  =  0.40;
   $betam =  6.00;
   $betah =  8.21;
   $gamam = 19.30;
   $gamah = 11.60;
   $pro   =  0.95;
   $pi	=3.141518;

 # Compute Wind Speed at specified level given micrometeorological parameters

  $z1ol = $z1 / $amol;
  $z2ol = $z2 / $amol;

  $alogz1z2 = log($z1/$z2);
  $alogz1z0 = log($z1/$z0);

  
  if ( $z1ol >= 0.0 ) {				# Condition that z over L is postitive or stable
	
#       $psim_exp=4.7*$z2/$amol;
       if ( $z1ol > 1.0 ) {			# Condition that z1/L is large (very stable)
            $psih0 = 1.0 - $betah - $z1ol;
            $psim0 = 1.0 - $betam - $z1ol;
	}
   	else {					# Condition that z1/L is small (weakly stable)
            $psih0 = - $betah * $z1ol;
            $psim0 = - $betam * $z1ol;
      	}

    	if ( $z2ol > 1.0 ) {			# Condition that z2/L is large (very stable)
       		$psih = $psih0 - (1.0 - $betah - $z2ol);
       		$psim = $psim0 - (1.0 - $betam - $z2ol);
	}
	else {					# Condition that z2/L is small (weakly stable)
       		$psih = $psih0 + $betah * $z2ol;
       		$psim = $psim0 + $betam * $z2ol;
 	 }
  }

  else {				# Condition that z over L is negative or unstable
    $x_exp=pow((1- (15*$z2/$amol)),0.25);
#    $psim_exp=  ( -2*log( (1+$x_exp)/2 ) ) - ( log( (1+$x_exp)^2/2 ) ) + ( 2*atan($x_exp) ) - ( $pi/2 ) ;

    $psih = 2.0 * log( (1.0 + sqrt(1.0 - $gamah*$z1ol)) /  (1.0 + sqrt(1.0 - $gamah*$z2ol)) );                       
    $x1   = (1.0 - $gamam * $z1ol)**0.25;
    $x2   = (1.0 - $gamam * $z2ol)**0.25;
    $psim = 2.0 * log( (1.0+$x1) / (1.0+$x2) ) +  log( (1.0+$x1*$x1) / (1.0+$x2*$x2)) -  2.0 * atan($x1) + 2.0 * atan($x2);
  }
      
#  $theta2 = $theta1 - $pro*$hfx / ($vkar*$ustar) * ($alogz1z2-$psih)
#   print "$u1     - $ustar/$vkar * ($alogz1z2-$psim)\n";
#  print "*** ($ustar/$vkar)* ( log($z2/$z0) + $psim_exp) ***   4.7*$z2/$amol  \n";
#  $u2_exp=($ustar/$vkar)* ( log($z2/$z0) + $psim_exp);
  $u2     = $u1     - $ustar/$vkar * ($alogz1z2-$psim);
  return($u2);    
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
# 			SUBROUTINE get_netcdf_grid 					 	 
# PURPOSE: Retrieves a specified grid from netcdf fil
#
# INPUTS:	$nc		file path/name, 
# OUTPUT:	$dim[:]		Array of all dimensions specified in NetCDF file
#				(e.g. XDIM,YDIM,ZDIM,TDIM)         
#_____________________________________________________________________________________________________
#				Change Documentaion
#   Version 1.0 Initial development, Rob Gilliam (06-05-2003)
#   Version 1.1 Replaced commented-out print statements with new "DEBUG" style comment.Rob Gilliam (07-29-2003)
#		
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub get_netcdf_grid
{
	local($var,$ttt,$x,$y,$nzz,$ndim) = @_;
	local($ts,$var_prof);

	if($ndim eq 4){
		$var_prof  =$mod->  get($var,       [$ttt,0,$y,$x], [1,$nzz,1,1] );
	}
	elsif ($ndim eq 3){
		$var_prof  =$mod->  get($var,       [$ttt,$y,$x], [1,1,1] );
	}
	elsif ($ndim eq 2){
		$var_prof  =$mod->  get($var,       [$y,$x], [1,1] );
	}
	elsif ($ndim eq 1){
		$var_prof  =$mod->  get($var,       [0], [$nzz] );
	}
	elsif ($ndim eq 0){
		$var_prof  =$mod->  get($var);
	}
	return($var_prof);
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_____________________________________________________________________________________________________
#-----------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------
#	FREE SCRIPT FOUND TO CALCULATE DISTANCE BETWEEEN LAT LON PAIRS
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::                                                                         :::
#:::  This routine calculates the distance between two points (given the     :::
#:::  latitude/longitude of those points). It is being used to calculate     :::
#:::  the distance between two ZIP Codes or Postal Codes using our           :::
#:::  ZIPCodeWorld(TM) and PostalCodeWorld(TM) products.                     :::
#:::                                                                         :::
#:::  Definitions:                                                           :::
#:::    South latitudes are negative, east longitudes are positive           :::
#:::                                                                         :::
#:::  Passed to function:                                                    :::
#:::    lat1, lon1 = Latitude and Longitude of point 1 (in decimal degrees)  :::
#:::    lat2, lon2 = Latitude and Longitude of point 2 (in decimal degrees)  :::
#:::    unit = the unit you desire for results                               :::
#:::           where: 'M' is statute miles                                   :::
#:::                  'K' is kilometers (default)                            :::
#:::                  'N' is nautical miles                                  :::
#:::                                                                         :::
#:::  United States ZIP Code/ Canadian Postal Code databases with latitude   :::
#:::  & longitude are available at http://www.zipcodeworld.com               :::
#:::                                                                         :::
#:::  For enquiries, please contact sales@zipcodeworld.com                   :::
#:::                                                                         :::
#:::  Hexa Software Development Center © All Rights Reserved 2003            :::
#:::                                                                         :::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


sub distance {
	my ($lat1, $lon1, $lat2, $lon2, $unit) = @_;
	my $theta = $lon1 - $lon2;
	my $dist = sin(deg2rad($lat1)) * sin(deg2rad($lat2)) + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($theta));

  $dist  = acos($dist);
  $dist = rad2deg($dist);
  $dist = $dist * 60 * 1.1515;
  if ($unit eq "K") {
  	$dist = $dist * 1.609344;
  } elsif ($unit eq "N") {
  	$dist = $dist * 0.8684;
		}
	return ($dist);
}

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::  This function get the arccos function using arctan function   :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
sub acos {
	my ($rad) = @_;
	my $ret = atan2(sqrt(1 - $rad**2), $rad);
	return $ret;
}

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::  This function converts decimal degrees to radians             :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
sub deg2rad {
	my ($deg) = @_;
	return ($deg * $pi / 180);
}
#
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::  This function converts radians to decimal degrees             :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
sub rad2deg {
	my ($rad) = @_;
	return ($rad * 180 / ($pi+0.001));
}

#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
# 			SUBROUTINE compute_site_ij					 	 
# PURPOSE: Computes the ij values corresponding to a site lat-lon
#
# INPUTS:	$site, $t, $s	Site id, time step index, site location in site i-j array
# OUTPUT:	$i, $j		I and J grid component corresponding to site
#				      
#_____________________________________________________________________________________________________
#				Change Documentaion
#   Version 1.0 Initial development, Rob Gilliam (05-02-2007)
#		
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub compute_site_ij
{
	local($site,$lat,$lon) = @_;
        local($i,$j,$count,@match);

        @match = grep (/$site/i, @siteid_array);
        if(@match){				#  Case where site has been evaluated before, thus no need to compute i-j, read from array
	   $count=0;
           while( $siteid_array[$count] ne $site){
             $count=$count+1;
           }
           $i=$i_site[$count];
           $j=$j_site[$count];
           #print "Site exist, double check that $siteid_array[$count] matches $site at location $count $i $j\n";
        }
        else {    				# Case where site has not been matched, thus the need to compute i-j   	
           ($i,$j)=&latlon2ij($lat, $lon);
           push(@i_site,$i);
           push(@j_site,$j);
           push(@siteid_array,$site);
           #print "Site $site was added to site array with coordinates $i $j\n";
        }		

	return(($i,$j));
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
# 			SUBROUTINE get_netcdf_grid 					 	 
# PURPOSE: Retrieves a specified grid from netcdf fil
#
# INPUTS:	$nc		file path/name, 
# OUTPUT:	$dim[:]		Array of all dimensions specified in NetCDF file
#				(e.g. XDIM,YDIM,ZDIM,TDIM)         
#_____________________________________________________________________________________________________
#				Change Documentaion
#   Version 1.0 Initial development, Rob Gilliam (06-05-2003)
#   Version 1.1 Replaced commented-out print statements with new "DEBUG" style comment.Rob Gilliam (07-29-2003)
#		
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub nothing
{
	local($var,$ttt,$x,$y,$nzz,$ndim) = @_;


	return($var_prof);
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_____________________________________________________________________________________________________
