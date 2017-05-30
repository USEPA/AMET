#!/usr/bin/perl
#				profile_util.pl
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
#_____________________________________________________________________________________________
#_______________________________________________________________________________
#								
#	Automated Meteorological Evaluation Tool		
#								
#	Perl Subroutine Collection, 
#	Extract and Match RAOB/Upper-Air Data with Model Output		
#
#	NOAA/ARL/ASMD and US EPA				
#								
#   Version 1.0 Initial development, Rob Gilliam (08-03-2005)	
#   Version 1.2 Update and bug fix, Rob Gilliam (05-01-2013)
#             - match_profiler subroutine was re-engineered for higher efficiency. Older version was much slower. 
#               Extensive QC checking to ensure bad data in to not put in database.
#
#             - match_vad subroutine was added for comparing model wind profiles to VAD wind observations.
#
#             - match_acars was modified to use MADIS computed i,j grid point instead of AMET internal values. 
#           
#______________________________________________________________________________
#
# PURPOSE:	This is a collection of subroutines used by the AMET program.
#		
# SUBROUTINES: (See header of each subroutine for version info, changes and dates)
#
#		match_raob:	    Read in Upper Air observations from the MADIS utility raobdump.exe
#                   and matches with model
#
#		match_profiler:	Read in MAP and NPN profiler data from the MADIS utility mapdump.exe and npndump.exe
#                   and matches with model
#
#   match_vad:      Read VAD wind obs files in MADIS-like text format ($AMETBASE/obs/MET/vadwind) and match with model
#
#   match_acars:    Read ACARs aircraft profile MADIS files and match with model profile.
#
#		prof_interp:    Interpolates observed profile to model sigma levels
#
#		zcoord_calcs:   Caculates physical height of model sigma layers
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
print "Observation-Model profile matching subroutines are loaded and ready to access.\n";

#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE match_raob
# PURPOSE: Read in Upper Air observations from the MADIS utility raobdump.exe

#		
# INPUTS:	ascii raobdump.txt file, model time index
# OUTPUT:	Observed/Model Pairs (U-V wind components, T and RH on Model Sigma levels)	
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub match_raob
{
	local($obs_file,$tcomp,$net) = @_;
	local(@l,@si,$i,$s,$v,$j,$h);
	local($nstat,$nvar,$nlev);
	my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass)
	    or die "Unable to connect to MySQL database $dbase.  Check server, user and/or passwords.\n";	
	
	# Set up model variable id's that are model dependent
	if($model eq "wrf"){
		$uid="U";$vid="V";$tid="T";$qid="QVAPOR";
	}
	elsif ($model eq "mm5") {
		$uid="u";$vid="v";$tid="t";$qid="q";
	}
	
	open (PROF,"< $obs_file");
	@l=<PROF>;$ln=scalar(@l);chomp(@l);close(PROF);
	if($ln <=100) {return($tcomp);}				# Return if the file is empty

	$sindex=0;
	@si=();
	$stat_exists=0;

	for($ii=0;$ii<$ln;$ii++){
		if ($l[$ii] =~ /Station/){
			$stat_exists=0;
			($x,$stat_id,$x,$elevx,$latx,$lonx,$i_locx,$j_locx,$nlevx,$ob_datex)=split(/\s+/,$l[$ii+1]);
			$prof_pdl= zeroes($nlevx,4);
			($x,$x,$vid1,$x,$x,$x,$vid2,$x,$x,$x,$vid3,$x,$x,$x,$vid4)=split(/\s+/,$l[$ii+3]);
			if($amet_verbose eq "yes")	{ 
				print "Station : $stat_id Lat/Lon: $latx   $lonx  Elevation: $elevx  NLevs: $nlevx Date: $ob_datex   Variables: $vid3  $vid4\n";
			}	
			$is=$ii+4;$gli=0;
			for ($ip=0;$ip<$nlevx;$ip++){
				($x,$x,$v1,$x,$x,$x,$v2,$x,$x,$x,$v3,$x,$x,$x,$v4)=split(/\s+/,$l[$is+$ip]);
				$v1=$v1/100;
				if($ip eq 0){ $h0=$v2;}
				$v2=$v2-$elevx;

				@posi=($gli,0);set $prof_pdl, @posi, $v1;
				@posi=($gli,1);set $prof_pdl, @posi, $v2;
				@posi=($gli,2);set $prof_pdl, @posi, $v3;
				@posi=($gli,3);set $prof_pdl, @posi, $v4;
				$gli=$gli+1;	
			}
                
		$ii=$ii+4+$nlevx;			
		
		#($iob,$job)=&latlon_to_ij($latx, $lonx, $ALAT1, $ELON1, $DX, $ELONV, $ALATAN1, $ALATAN2);
    #($iob,$job)=&latlon2ij($latx, $lonx);
    ($iob,$job)=&compute_site_ij($stat_id, $latx, $lonx);
                
		if (	($iob < 0 || $iob >= $NX[0]-5) || ($job < 0 || $job >= $NY[0]-5 ) ){ next; } #  Skip Observation if off model grid

		$nz=$NZ[7]-1;
    # Hard coded to just match the first 34 levels...
	  $nz= 34;
		($h_sigma,$sigma)=&zcoord_calcs($tcomp,$iob,$job,$nz);

		$pressure	=( $prof_pdl->dice(X,[0]) );
		$height		=  $prof_pdl->dice(X,[1]);
		@profh		= list $height;
		$profh_max	= max($height);
		@h_sigma	=list $h_sigma;
		@sigma		=list $sigma;
		(@p_ob)=&prof_interp($tid,$tcomp,$iob,$job,$nz,$height,$pressure,$h_sigma);			# Linear Interpolation
		$p_sigma= pdl @p_ob ;

		if($vid3 eq "T" & $vid4 eq "RH") {			# If Profile is temperature and mosture
      $profh_min	= @profh[0];
      if($profh_min < 0 ) {   print " **************   Profiler height is lower than elevation \n"; next; }
      # Get temperature and RH from profile piddle
      $T_ob		=  $prof_pdl->dice(X,[2]);
      $RH_ob		=  $prof_pdl->dice(X,[3]);
			# Use interpolation function to interpolate observed temperature profile to model sigma coordinates
      (@t_ob)=&prof_interp($tid,$tcomp,$iob,$job,$nz,$height,$T_ob,$h_sigma);
      $pt_ob=(pdl @t_ob)/(( (pdl @p_ob)/1000)**(0.286));
      @pt_ob=list $pt_ob;
      $t_mod_prof=$modelvp;		# Define model temp profile from modelvp variable that is a global byproduct of the interp funtion
			 if($model eq "wrf") {
	      	 	 	$pt_mod_prof = ($t_mod_prof+ 300);
			        $t_mod_prof= $pt_mod_prof*(( ($p_sigma)/1000)**(0.286));
       }
			 if($model eq "mm5") {
			 	$pt_mod_prof=$t_mod_prof/(( ($p_sigma)/1000)**(0.286));
			 }
       @pt_mod= list $pt_mod_prof;	# This just changes temp profile piddle to a perl array

       # Caculate the model saturation vapor pressure of model temperature profile
       ## Stull (1995) "Met. Today Tech. Companion Book", Chapt. 5, pages 85-86
			 # ------------------------------------------------------------------
       local($T1)	=273.14;	
       local($b)	=17.2694;
       local($T2)	=35.86;
       local($eo)	=0.611;
       local($es)	=$eo*exp( $b*($t_mod_prof-$T1)/($t_mod_prof-$T2) );
       local($rs)	=0.622*$es/(($p_sigma/10)-$es);
			 # ------------------------------------------------------------------
			# Use interpolation function to interpolate observed RH profile to model sigma coordinates			
      (@rh_ob)=&prof_interp($qid,$tcomp,$iob,$job,$nz,$height,$RH_ob,$h_sigma);
      $r_mod_prof=$modelvp;		# Mixing ratio from model 
      $rh_mod=100*$r_mod_prof/$rs;	# Model RH from mixing ratio and saturation mixing ratio (Stull above)	
      @rh_mod=list $rh_mod;
      $count = 0; #table row counter
      foreach $pt_ob(@pt_ob) {
			     if($h_sigma[$count] >= $profh_min & $h_sigma[$count] <= $profh_max){
			       if($amet_verbose eq "yes" )	{	print "$stat_id  $mysql_time $latx $lonx $iob,$job ".sprintf("%8.0f",$h_sigma[$count])." ".sprintf("%8.4f",$sigma[$count])."	 ".sprintf("%8.0f",$p_ob[$count])." : $vid3 ".sprintf("%8.2f",$pt_ob[$count])."  ".sprintf("%8.2f",$pt_mod[$count])." ---- $vid4 ".sprintf("%8.2f",$rh_ob[$count])."  ".sprintf("%8.2f",$rh_mod[$count])." \n";	}
			       $q1="REPLACE INTO ".$pid."_raob ";
			       $q2="(stat_id, lat, lon, elev, landuse, ob_date, ob_time, fcast_hr, init_utc, plevel, slevel, hlevel, v1_id, v2_id, v1_ob, v1_mod, v2_ob, v2_mod)";
			       $q3=" VALUES ('$stat_id',$latx,$lonx,$elevx,$lu[0],'$mysql_time','$hour',$fcast_hr, $init_utc, ".sprintf("%8.0f",$p_ob[$count]).", ".sprintf("%8.3f",$sigma[$count]).", ".sprintf("%8.0f",$h_sigma[$count]).", '$vid3', '$vid4', ".sprintf("%8.2f",$pt_ob[$count]).", ".sprintf("%8.2f",$pt_mod[$count]).", ".sprintf("%8.2f",$rh_ob[$count]).", ".sprintf("%8.2f",$rh_mod[$count])." )";
			       $query=$q1.$q2.$q3;
			       $table_query = $dbh->Query($query);
			      }
			     $count++;
			}
		}
		elsif($vid3 eq "UMAN" & $vid4 eq "VMAN"){		# If Profile is the wind part
			$profh_min	= @profh[0];
			if($profh_min < 0 ) {   print " **************   Profiler height is lower than elevation \n"; next; }
        #print "Minumim height $profh_min \n";
        $U_ob = $prof_pdl->dice(X,[2]);
        $V_ob = $prof_pdl->dice(X,[3]);

        (@u_ob)=&prof_interp($uid,$tcomp,$iob,$job,$nz,$height,$U_ob,$h_sigma);	# Linear Interpolation of Observed U (U_ob) to models vertical coordinate system
        @u_mod=@modelv;
        (@v_ob)=&prof_interp($vid,$tcomp,$iob,$job,$nz,$height,$V_ob,$h_sigma);	# Linear Interpolation of Observed V (V_ob) to models vertical coordinate system
        @v_mod=@modelv;
        $count = 0; #table row counter
        foreach $u_ob(@u_ob) {
			     if($h_sigma[$count] >= $profh_min & $h_sigma[$count] <= $profh_max){
			       if($amet_verbose eq "yes" )	{	print "$stat_id  $mysql_time $latx $lonx $iob,$job ".sprintf("%8.0f",$h_sigma[$count])." ".sprintf("%8.4f",$sigma[$count])."	 ".sprintf("%8.0f",$p_ob[$count])." : $vid3 ".sprintf("%8.2f",$u_ob[$count])."  ".sprintf("%8.2f",$u_mod[$count])." ---- $vid4 ".sprintf("%8.2f",$v_ob[$count])."  ".sprintf("%8.2f",$v_mod[$count])." \n";	}
			       $q1="REPLACE INTO ".$pid."_raob ";
			       $q2="(stat_id, lat, lon, elev, landuse, ob_date, ob_time, fcast_hr, init_utc, plevel, slevel, hlevel, v1_id, v2_id, v1_ob, v1_mod, v2_ob, v2_mod)";
			       $q3=" VALUES ('$stat_id',$latx,$lonx,$elevx,$lu[0],'$mysql_time','$hour',$fcast_hr, $init_utc, ".sprintf("%8.0f",$p_ob[$count]).", ".sprintf("%8.3f",$sigma[$count]).", ".sprintf("%8.0f",$h_sigma[$count]).", '$vid3', '$vid4', ".sprintf("%8.2f",$u_ob[$count]).", ".sprintf("%8.2f",$u_mod[$count]).", ".sprintf("%8.2f",$v_ob[$count]).", ".sprintf("%8.2f",$v_mod[$count])." )";
			       $query=$q1.$q2.$q3;
			       $table_query = $dbh->Query($query);
			     }
			     $count++;
        }
			}
	  }	# END OF LOOP THROUGH STATION RECORDS
	}	# LOOP THROUGH RAOB FILE
	print "RAOB successfully completed \n";
	return();
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________

#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE match_profiler
# PURPOSE: Read in surface observations and match with model value for a particular time
#		Additional tasks are opportunistically completed: 1) GrADS file is built
#		as each variable is compared. 2) Dump file with obs-model values is created
#		3) Simple stats are caculated and printed on screen for each variable at each
#		time.
#		
# INPUTS:	ascii surface_obs from sfcdump.exe utility	
# OUTPUT:	ascii  obs-model record dump file "obs-model_dump.dat"
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub match_profiler
{
	local($obs_file,$tcomp,$net) = @_;
	local(@l,@si,$i,$s,$v,$j,$h);
	local($nstat,$nvar,$nlev);
	local(@si,@elev,@lat,@lon,@nlev,@ob_date,@itmp,@jtmp);
	my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass)
	    or die "Unable to connect to MySQL database $dbase.  Check server, user and/or passwords.\n";	

	open (PROF,"< $obs_file");
	@l=<PROF>;$ln=scalar(@l);chomp(@l);close(PROF);

	for($ii=0;$ii<$ln;$ii++){
		@wrd=split(/\s+/,$l[$ii]);
		if ($wrd[1] eq "Station") {
			
			($junk,$stat_id,$network,$elevx,$latx,$lonx,$i_locx,$j_locx,$nlevx,$ob_datex) = split(/\s+/,$l[$ii+1]);
			if(!$ob_datex) {  # This was added May2007 becuase some older MAP and NPN datasets had headers with missing network id.
			  ($junk,$stat_id,$elevx,$latx,$lonx,$i_locx,$j_locx,$nlevx,$ob_datex) = split(/\s+/,$l[$ii+1]);
			  #print "\n\n $junk,$stat_id,$elevx,$latx,$lonx,$i_locx,$j_locx,$nlevx,$ob_datex \n";
			}

			@match = grep (/$stat_id/i, @si);
			if(@match){
			    # Do nothing as site has been logged
			}
			else {
			    #print "New site $stat_id --->";print @match; print "\n";
			    push(@si,$stat_id);
			    push(@elev,$elevx);
			    push(@lat,$latx);
			    push(@lon,$lonx);
			    push(@itmp,$i_locx);
			    push(@jtmp,$j_locx);
			    push(@nlev,$nlevx);
			    push(@ob_date,$ob_datex);
			    #print " >>>>> $stat_id,$network,$elevx,$latx,$lonx,$i_locx,$j_locx,$nlevx,$ob_datex  \n";
			}				
		}
		
	}

	$nstat=@si;

	if ($net eq "map"){
		@pvar=("P","HT","U","V") ;	
	}
	elsif($net eq "npn"){
		@pvar=("P","HT","U","V") ;	
	}
	elsif($net eq "npn" & $obs_format eq "exp"){
		@pvar=("P","HT","U","V") ;	
	}
        $nlevmax=max(pdl @nlev);
	$nvar=@pvar;
	$obs_pdl= zeroes($nlevmax,$nvar,$nstat);
	$obs_pdl=$obs_pdl+999999;
   for($s=0;$s<$nstat;$s++){
		@rec=("");
	  for($v=0;$v<=$nvar;$v++){
                
		for($i=0;$i<$ln;$i++){
			@wrd1=split(/\s+/,$l[$i]);
			@wrd2=split(/\s+/,$l[$i+2]);
			$cur_station	=$wrd1[1];
			$cur_var	=$wrd2[2];
			if ($cur_station eq $si[$s] & $cur_var eq $pvar[$v]) {
				$nint=$nlev[$s]+3;
				$j=3;$jj=0;
				while ($j<$nint) {
					@posi=($jj,$v,$s);	
					@w=split(/\s+/,$l[$i+$j]);$value=$w[2];
					set $obs_pdl, @posi, $value;
					$j=$j+1;$jj=$jj+1;
				}
					
				
			}
		
		}
	
	  }
###########################################################
#---		Extract vertical profiles from main pdl
	$pressure=($obs_pdl->dice(X,[0],[$s]))/100;
	$height=$obs_pdl->dice(X,[1],[$s]);
	$uw=$obs_pdl->dice(X,[2],[$s]);
	$vw=$obs_pdl->dice(X,[3],[$s]);
	#$ww=$obs_pdl->dice(X,[4],[$s]);
	
	$height=$height-$elev[$s];
###########################################################

	$uid="u";$vid="v";$wid="w";
	$tid="t";$pblh="pbl_hgt";
	if($model eq "wrf"){
		$uid="U";$vid="V";$wid="W";
		$tid="T";$pblh="PBLH";
	}

	$minh = min($height);
	$minu = min($uw);
	if($minh > 99999 || $minu > 99999 ) { 
		print "Min height of profiler indicates all obs were mising for site:  site:$si[$s] $s $nstat; will skip \n";
		next; 
	}

	$heightx= $height->where($height <25000);
	@max_h=list max($heightx);$max_h=$max_h[0];
	
	$min_h=min($height);
	@max_h=list max($height);
	@min_h=list $min_h;$min_h=$min_h[0];

  # Changed by Rob Gilliam 2/28/2009 Use the MADIS computed i,j
  #$iob=$itmp[$s];
  #$job=$jtmp[$s]; 
	#($iob,$job)=&compute_site_ij($si[$s], $lat[$s], $lon[$s]);
  ($iob,$job)=&latlon_to_ij($ALAT1, $ELON1, 0, 0, $ALATAN1, $ALATAN2, $ELONV, $DX, $DX, $lat[$s], $lon[$s]);

	if($iob < 0 || $iob >= ($NX[0]-3) || $job < 0 || $job >= ($NY[0]-3)) {	print "NOT in domain, will skip stations $s of $nstat ID: $si[$s] \n";next;}
	#  Nearest Neighbor interpolation
	$dxx=$iob- int($iob);
	$dyx=$job- int($job);
	if ($dxx >= 0.5){$iob=int($iob)+1;}
	else{$iob=int($iob);}
	if ($dyy >= 0.5){$job=int($job)+1;}
	else{$job=int($job);}

	$nz=$NZ[7]-1;
  # Hard coded to just match the first 34 levels...
	$nz= 34;

	($h_sigma,$sigma)=&zcoord_calcs($tcomp,$iob,$job,$nz);
	($pbl_mod)=&get_netcdf_grid($pblh,$tcomp,$iob,$job,$nz,3); @pbl_mod=list $pbl_mod;
	$p_sigma2=($p_sigma)/100;

	@h_ob=list $h_sigma;
	@s_ob=list $sigma;
	
  # Note this set pressure to U wind just to fill out array. Pressure is not used in AMET eval, so this is placeholder set to -99999.99 below.
  $pressure=$uw;  

	(@p_ob)=&prof_interp($uid,$tcomp,$iob,$job,$nz,$height,$pressure,$h_sigma);			# Linear Interpolation

	(@u_ob)=&prof_interp($uid,$tcomp,$iob,$job,$nz,$height,$uw,$h_sigma);			# Linear Interpolation
	@u_mod=@modelv;

	(@v_ob)=&prof_interp($vid,$tcomp,$iob,$job,$nz,$height,$vw,$h_sigma);			# Linear Interpolation
	@v_mod=@modelv;

  $height_ob_min = min($height) ;
	print " site:$si[$s] elev: $elev[$s] min profile level: $height_ob_min **** model grid: $iob , $job (AMET) $itmp[$s], $jtmp[$s] (MADIS)\n";
	#######################################################################################################################################
  $site_missing_qc=0;
	for($h=0;$h<($nz-2);$h++){
    $p_ob[$h]=-9999;
		$q1="REPLACE INTO ".$pid."_profiler ";
		$q2="(proj_code, stat_id, i, j, landuse, ob_date, ob_time, fcast_hr, init_utc, plevel, slevel, hlevel, U_ob, U_mod, V_ob, V_mod, PBL_ob, PBL_mod)";
		$q3=" VALUES ('$pid','$si[$s]',$iob,$job,$lu[0],'$mysql_time','$hour',$fcast_hr, $init_utc, $p_ob[$h], $s_ob[$h], $h_ob[$h], $u_ob[$h], $u_mod[$h], $v_ob[$h], $v_mod[$h], -99.99, $pbl_mod[0])";
		$qc_check= abs($u_ob[$h] + $v_ob[$h]);
		$query=$q1.$q2.$q3;
		if ($u_ob[$h] < 200 & $v_ob[$h] < 200 &  $h_ob[$h] <= $max_h  &  $h_ob[$h] > $height_ob_min & $qc_check > 0.0){
			if($amet_verbose eq "yes")	{print "$si[$s] ".sprintf("%12.0f",$h_ob[$h])."   ".sprintf("%5.4f",$s_ob[$h])."  ".sprintf("%8.3f",$u_ob[$h]).sprintf("%8.3f",$u_mod[$h])."  ".sprintf("%8.3f",$v_ob[$h]).sprintf("%8.3f",$v_mod[$h]).sprintf("%8.3f",$tv_ob[$h]).sprintf("%8.3f",$tv_mod[$h]).sprintf("%8.3f",$snr_ob[$h])."\n";}
			$table_query = $dbh->Query($query);
			$site_missing_qc=$site_missing_qc +1;
		}
		else {
			if($amet_verbose eq "yes")	{print "Missing data for $si[$s] at level: ".sprintf("%12.0f",$h_ob[$h])."   ".sprintf("%5.4f",$s_ob[$h])."   ".sprintf("%8.3f",$u_ob[$h])."   ".sprintf("%8.3f",$v_ob[$h])."\n";}
	  }	
	}
	print "***  Data found for stations $s of $nstat ID: $si[$s]  $iob    $job **********************************\n";
	print "------------------------------------------------------------------------------------------------\n";
  }

} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE match_profiler
# PURPOSE: Read in surface observations and match with model value for a particular time
#		Additional tasks are opportunistically completed: 1) GrADS file is built
#		as each variable is compared. 2) Dump file with obs-model values is created
#		3) Simple stats are caculated and printed on screen for each variable at each
#		time.
#		
# INPUTS:	ascii surface_obs from sfcdump.exe utility	
# OUTPUT:	ascii  obs-model record dump file "obs-model_dump.dat"
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub match_vad
{
	local($obs_file,$tcomp,$net) = @_;
	local(@l,@si,$i,$s,$v,$j,$h);
	local($nstat,$nvar,$nlev);
	local(@si,@elev,@lat,@lon,@nlev,@ob_date,@itmp,@jtmp);
	my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass)
	    or die "Unable to connect to MySQL database $dbase.  Check server, user and/or passwords.\n";	

	open (PROF,"< $obs_file");
	@l=<PROF>;$ln=scalar(@l);chomp(@l);close(PROF);

	if( $ln < 100){ next;} # Tempoaray Limitation on file size 

	for($ii=0;$ii<$ln;$ii++){
		@wrd=split(/\s+/,$l[$ii]);
		if ($wrd[1] eq "Station") {
			
			($junk,$stat_id,$network,$elevx,$latx,$lonx,$i_locx,$j_locx,$nlevx,$ob_datex) = split(/\s+/,$l[$ii+1]);
			if(!$ob_datex) {  # This was added May2007 becuase some older MAP and NPN datasets had headers with missing network id.
			  ($junk,$stat_id,$elevx,$latx,$lonx,$i_locx,$j_locx,$nlevx,$ob_datex) = split(/\s+/,$l[$ii+1]);
			  #print "\n\n $junk,$stat_id,$elevx,$latx,$lonx,$i_locx,$j_locx,$nlevx,$ob_datex \n";
			}

			@match = grep (/$stat_id/i, @si);
			if(@match){
			    # Do nothing as site has been logged
			}
			else {
			    #print "New site $stat_id --->";print @match; print "\n";
			    push(@si,$stat_id);
			    push(@elev,$elevx);
			    push(@lat,$latx);
			    push(@lon,$lonx);
			    push(@itmp,$i_locx);
			    push(@jtmp,$j_locx);
			    push(@nlev,$nlevx);
			    push(@ob_date,$ob_datex);
			    #print " >>>>> $stat_id,$network,$elevx,$latx,$lonx,$i_locx,$j_locx,$nlevx,$ob_datex  \n";
			}				
		}
		
	}

	$nstat=@si;

	@pvar=("P","HT","U","V","W") ;	

  $nlevmax=max(pdl @nlev);
	$nvar=@pvar;
	$obs_pdl= zeroes($nlevmax,$nvar,$nstat);
	$obs_pdl=$obs_pdl+999999;
   for($s=0;$s<$nstat;$s++){
		@rec=("");
	  for($v=0;$v<=$nvar;$v++){
                
		for($i=0;$i<$ln;$i++){
			@wrd1=split(/\s+/,$l[$i]);
			@wrd2=split(/\s+/,$l[$i+2]);
			$cur_station	=$wrd1[1];
			$cur_var	=$wrd2[2];
			if ($cur_station eq $si[$s] & $cur_var eq $pvar[$v]) {
				$nint=$nlev[$s]+3;
				$j=3;$jj=0;
				while ($j<$nint) {
					@posi=($jj,$v,$s);	
					@w=split(/\s+/,$l[$i+$j]);$value=$w[2];
					set $obs_pdl, @posi, $value;
					$j=$j+1;$jj=$jj+1;
				}
					
				
			}
		
		 }
	
	  }
  ###########################################################
  #---		Extract vertical profiles from main pdl
	$pressure=($obs_pdl->dice(X,[0],[$s]))/100;
	$height=$obs_pdl->dice(X,[1],[$s]);
	$uw=$obs_pdl->dice(X,[2],[$s]);
	$vw=$obs_pdl->dice(X,[3],[$s]);
	$ww=$obs_pdl->dice(X,[4],[$s]);	
	$height=$height-$elev[$s];
  ###########################################################

	$uid="u";$vid="v";$wid="w";
	$tid="t";$pblh="pbl_hgt";
	if($model eq "wrf"){
		$uid="U";$vid="V";$wid="W";
		$tid="T";$pblh="PBLH";
	}

	@max_h=list $height;
	$heightx= $height->where($height <25000);
	@max_h=list max($heightx);$max_h=$max_h[0];
		
	$min_h=min($height);
	@max_h=list max($height);
	@min_h=list $min_h;$min_h=$min_h[0];
	
	#($iob,$job)=&compute_site_ij($si[$s], $lat[$s], $lon[$s]);
  ($iob,$job)=&latlon_to_ij($ALAT1, $ELON1, 0, 0, $ALATAN1, $ALATAN2, $ELONV, $DX, $DX, $lat[$s], $lon[$s]);

	if($iob < 0 || $iob >= ($NX[0]-3) || $job < 0 || $job >= ($NY[0]-3)) {	print "NOT in domain, will skip stations $s of $nstat ID: $si[$s] \n";next;}
			#  Nearest Neighbor interpolation
			$dxx=$iob- int($iob);
			$dyx=$job- int($job);
			if ($dxx >= 0.5){$iob=int($iob)+1;}
			else{$iob=int($iob);}
			if ($dyy >= 0.5){$job=int($job)+1;}
			else{$job=int($job);}

	$nz=$NZ[7]-1;
  # Hard coded to just match the first 34 levels...
	$nz= 34;

  @tmph =list $height;
  $height_ob_min =  $tmph[0];
      
	($h_sigma,$sigma)=&zcoord_calcs($tcomp,$iob,$job,$nz);
	($pbl_mod)=&get_netcdf_grid($pblh,$tcomp,$iob,$job,$nz,3); @pbl_mod=list $pbl_mod;
	$p_sigma2=($p_sigma)/100;

	@h_ob=list $h_sigma;
	@s_ob=list $sigma;
	
	(@u_ob)=&prof_interp($uid,$tcomp,$iob,$job,$nz,$height,$uw,$h_sigma);			# Linear Interpolation
	@u_mod=@modelv;

	(@v_ob)=&prof_interp($vid,$tcomp,$iob,$job,$nz,$height,$vw,$h_sigma);			# Linear Interpolation
	@v_mod=@modelv;

   @tmph = @v_ob;

	(@w_ob)=&prof_interp($wid,$tcomp,$iob,$job,$nz,$height,$ww,$h_sigma);			# Linear Interpolation
	@w_mod=@modelv;

  # Quick fix for missing pressure values. Pressure at certain heights or sigma levels is not a variable we evaluate or use right now, so set observed pressure to that of the model.
	#(@p_ob)=&prof_interp($uid,$tcomp,$iob,$job,$nz,$height,$pressure,$h_sigma);			# Linear Interpolation
   @p_ob = list $pressure;


	print " site:$si[$s] elev: $elev[$s] min profile level: $height_ob_min **** model grid: $iob , $job  $nz \n";
	#######################################################################################################################################
	for($h=0;$h<($nz-2);$h++){
    $p_ob[$h]=-9999;
		$q1="REPLACE INTO ".$pid."_profiler ";
		$q2="(proj_code, stat_id, i, j, landuse, ob_date, ob_time, fcast_hr, init_utc, plevel, slevel, hlevel, U_ob, U_mod, V_ob, V_mod, PBL_ob, PBL_mod)";
		$q3=" VALUES ('$pid','$si[$s]',$iob,$job,$lu[0],'$mysql_time','$hour',$fcast_hr, $init_utc, $p_ob[$h], $s_ob[$h], $h_ob[$h], $u_ob[$h], $u_mod[$h], $v_ob[$h], $v_mod[$h], -99.99, $pbl_mod[0])";

		$query=$q1.$q2.$q3;
		$qc_check= $u_ob[$h] + $v_ob[$h];
		if ($u_ob[$h] < 200 & $v_ob[$h] < 200 &  $h_ob[$h] <= $max_h  &  $h_ob[$h] > $height_ob_min & $qc_check > 0.0){
			if($amet_verbose eq "yes")	{print "$si[$s] ".sprintf("%12.0f",$h_ob[$h])."   ".sprintf("%5.4f",$s_ob[$h])."  ".sprintf("%8.3f",$u_ob[$h]).sprintf("%8.3f",$u_mod[$h])."  ".sprintf("%8.3f",$v_ob[$h]).sprintf("%8.3f",$v_mod[$h]).sprintf("%8.3f",$tv_ob[$h]).sprintf("%8.3f",$tv_mod[$h]).sprintf("%8.3f",$snr_ob[$h])."\n";}
			$table_query = $dbh->Query($query);
		}
		else {
			if($amet_verbose eq "yes")	{print "Missing data for $si[$s] at level: ".sprintf("%12.0f",$h_ob[$h])."   ".sprintf("%5.4f",$s_ob[$h])."   ".sprintf("%8.3f",$u_ob[$h])."   ".sprintf("%8.3f",$v_ob[$h])."\n";}
	  }	
	}
	print "***  Finished stations $s of $nstat ID: $si[$s]  $iob    $job **********************************\n";
	print "------------------------------------------------------------------------------------------------\n";

  }

} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE match_acars
# PURPOSE: Read in surface observations and match with model value for a particular time
#		Additional tasks are opportunistically completed: 1) GrADS file is built
#		as each variable is compared. 2) Dump file with obs-model values is created
#		3) Simple stats are caculated and printed on screen for each variable at each
#		time.
#		
# INPUTS:	ascii acars profile observations from acarspdump.exe utility	
# OUTPUT:	model-obs matched profiles inserted into the AMET database
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub match_acars
{
	local($obs_file,$tcomp) = @_;
	local(@l,@si,$i,$s,$v,$j,$h);
	local($nstat,$nvar,$nlev);
	local(@si,@elev,@lat,@lon,@nlev,@ob_date,@itmp,@jtmp);
	my $dbh = Mysql->Connect($mysql_server,$dbase,$root_login,$root_pass)
	    or die "Unable to connect to MySQL database $dbase.  Check server, user and/or passwords.\n";	
	
	open (PROF,"< $obs_file");
	@l=<PROF>;$ln=scalar(@l);chomp(@l);close(PROF);

	if( $ln < 100){ next;} # Tempoaray Limitation on file size 

	for($ii=0;$ii<$ln;$ii++){
		@wrd=split(/\s+/,$l[$ii]);
		if ($wrd[1] eq "Station") {
			
			($junk,$stat_id,$network,$elevx,$latx,$lonx,$i_locx,$j_locx,$nlevx,$ob_datex) = split(/\s+/,$l[$ii+1]);
			if(!$ob_datex) {  # This was added May2007 becuase some older MAP and NPN datasets had headers with missing network id.
			  ($junk,$stat_id,$elevx,$latx,$lonx,$i_locx,$j_locx,$nlevx,$ob_datex) = split(/\s+/,$l[$ii+1]);
			   #print "\n\n $junk,$stat_id,$elevx,$latx,$lonx,$i_locx,$j_locx,$nlevx,$ob_datex \n";
			}

			@match = grep (/$stat_id/i, @si);
			if(@match){
			    # Do nothing as site has been logged
			}
			else {
			    #print "New site $stat_id --->";print @match; print "\n";
			    push(@si,$stat_id);
			    push(@elev,$elevx);
			    push(@lat,$latx);
			    push(@lon,$lonx);
			    push(@itmp,$i_locx);
			    push(@jtmp,$j_locx);
			    push(@nlev,$nlevx);
			    push(@ob_date,$ob_datex);
			   print " >>>>> $stat_id,$network,$elevx,$latx,$lonx,$i_locx,$j_locx,$nlevx,$ob_datex  \n";
			}				
		}
		
	}
	$nstat=@si;
	@pvar=("HT","P","U","V","T","LAT","LON") ;	


        $nlevmax=max(pdl @nlev);
	$nvar=@pvar;
	$obs_pdl= zeroes($nlevmax,$nvar,$nstat);
	$obs_pdl=$obs_pdl+999999;
   for($s=0;$s<$nstat;$s++){
		@rec=("");
	  for($v=0;$v<=$nvar;$v++){
                
		for($i=0;$i<$ln;$i++){
			@wrd1=split(/\s+/,$l[$i]);
			@wrd2=split(/\s+/,$l[$i+2]);
			$cur_station	=$wrd1[1];
			$cur_var	=$wrd2[2];
			if ($cur_station eq $si[$s] & $cur_var eq $pvar[$v]) {
				$nint=$nlev[$s]+3;
				$j=3;$jj=0;
				while ($j<$nint) {
					@posi=($jj,$v,$s);	
					@w=split(/\s+/,$l[$i+$j]);$value=$w[2];
					set $obs_pdl, @posi, $value;
	                                #print "$si[$s] -- $pvar[$v] >>>>> $value  \n";
					$j=$j+1;$jj=$jj+1;
				}
					
				
			}
		
		}
	
	  }
###########################################################
#---		Extract vertical profiles from main pdl
	$pressure=($obs_pdl->dice(X,[1],[$s]));
	$height  =$obs_pdl->dice(X,[0],[$s]);
	$uw      =$obs_pdl->dice(X,[2],[$s]);
	$vw      =$obs_pdl->dice(X,[3],[$s]);
	$tw      =$obs_pdl->dice(X,[4],[$s]);
	$latw    =$obs_pdl->dice(X,[5],[$s]);
	$lonw    =$obs_pdl->dice(X,[6],[$s]);

	$height=$height-$elev[$s];
###########################################################
	if($model eq "mm5"){
		$uid="u";$vid="v";$tid="t";
	}
	if($model eq "wrf"){
		$uid="U";$vid="V";$tid="T";	
	}

	@max_h=list $height;
	$heightx= $height->where($height <25000);
	@max_h=list max($heightx);$max_h=$max_h[0];
	
	
	
	$min_h=min($height);
	@max_h=list max($height);
	@min_h=list $min_h;$min_h=$min_h[0];
	
	#($iob,$job)=&compute_site_ij($si[$s], $lat[$s], $lon[$s]);
  #($iob,$job)=&latlon_to_ij($ALAT1, $ELON1, 0, 0, $ALATAN1, $ALATAN2, $ELONV, $DX, $DX, $lat[$s], $lon[$s]);
  # Changed by Rob Gilliam 2/28/2009 Use the MADIS computed i,j
  $iob=$itmp[$s];
  $job=$jtmp[$s]; 
         #print "$si[$s] $lat[$s], $lon[$s] $iob $job || $itmp[$s] $jtmp[$s] \n";
	if($iob < 0 || $iob >= ($NX[0]-3) || $job < 0 || $job >= ($NY[0]-3)) {	print "NOT in domain, will skip stations $s of $nstat ID: $si[$s] \n";next;}
			#  Nearest Neighbor interpolation
			$dxx=$iob- int($iob);
			$dyx=$job- int($job);
			if ($dxx >= 0.5){$iob=int($iob)+1;}
			else{$iob=int($iob);}
			if ($dyy >= 0.5){$job=int($job)+1;}
			else{$job=int($job);}

	$nz=$NZ[7]-1;
	$nz= 33;
	($h_sigma,$sigma)=&zcoord_calcs($tcomp,$iob,$job,$nz);

	$p_sigma2=($p_sigma)/100;

	@h_ob=list $h_sigma;
	@s_ob=list $sigma;

	(@p_ob)=&prof_interp($uid,$tcomp,$iob,$job,$nz,$height,$pressure,$h_sigma);			# Linear Interpolation
     
	(@u_ob)=&prof_interp($uid,$tcomp,$iob,$job,$nz,$height,$uw,$h_sigma);			# Linear Interpolation
	@u_mod=@modelv;

	(@v_ob)=&prof_interp($vid,$tcomp,$iob,$job,$nz,$height,$vw,$h_sigma);			# Linear Interpolation
	@v_mod=@modelv;
         
	(@t_ob)=&prof_interp($tid,$tcomp,$iob,$job,$nz,$height,$tw,$h_sigma);			# Linear Interpolation
	@t_mod=@modelv;
        
	# Use interpolation function to interpolate observed temperature profile to model sigma coordinates
	$pt_ob=(pdl @t_ob)/(( (pdl @p_ob)/100000)**(0.286));
	@pt_ob=list $pt_ob;
	
	$t_mod_prof=$modelvp ;		# Define model temp profile from modelvp variable that is a global byproduct of the interp funtion
	if($model eq "wrf") {
	      	$pt_mod_prof = ($t_mod_prof+ 300);
		$t_mod_prof= $pt_mod_prof*(( ($p_sigma)/1000)**(0.286));
	}
	if($model eq "mm5") {
	      	$pt_mod_prof=$t_mod_prof/(( ($p_sigma)/100000)**(0.286));
	}
	@pt_mod= list $pt_mod_prof;	# This just changes temp profile piddle to a perl array

        $height_ob_min = min($height) ;

	for($h=0;$h<($nz-2);$h++){
                $p_ob[$h] = $p_ob[$h]/100;
                
		$q1="REPLACE INTO ".$pid."_profiler ";
		$q2="(proj_code, stat_id, i, j, landuse, ob_date, ob_time, fcast_hr, init_utc, plevel, slevel, hlevel, U_ob, U_mod, V_ob, V_mod, T_ob, T_mod)";
		$q3=" VALUES ('$pid','$si[$s]',$iob,$job,$lu[0],'$mysql_time','$hour',$fcast_hr, $init_utc, $p_ob[$h], $s_ob[$h], $h_ob[$h], $u_ob[$h], $u_mod[$h], $v_ob[$h], $v_mod[$h], $pt_ob[$h], $pt_mod[$h] )";
		
		$query=$q1.$q2.$q3;
		if ($p_ob[$h] > 100 & $p_ob[$h] != 999999 &  $h_ob[$h] <= $max_h  &  $h_ob[$h] > $height_ob_min){
			if($amet_verbose eq "yes")	{
				print "$si[$s] $iob,$job ".sprintf("%12.0f",$p_ob[$h]).sprintf("%12.0f",$h_ob[$h])."   ".sprintf("%5.4f",$s_ob[$h]).sprintf("%8.3f",$u_ob[$h]).sprintf("%8.3f",$u_mod[$h]).sprintf("%8.3f",$v_ob[$h]).sprintf("%8.3f",$v_mod[$h]).sprintf("%8.3f",$pt_ob[$h]).sprintf("%8.3f",$pt_mod[$h])."\n";
			}
			$table_query = $dbh->Query($query);
		}
	}
	print "***  Finished stations $s of $nstat ID: $si[$s]  $iob    $job **********************************\n";
	print "------------------------------------------------------------------------------------------------\n";
 }

} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________-----------------------------
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE prof_interp 
# PURPOSE: 	Interpolates observed profile to model sigma levels
#		used by roab and profiler modes
#		
#
# INPUTS:	model variable id, model time index, x index of profile(x)
#		y index of profile (y), obs profile height (prof_h),
#		obs profile (prof_ob), height of sigma level (h_sigmax) 
#		
# OUTPUT:	interpolated observed profile and model profile
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub prof_interp 
{
	local($var,$tt,$x,$y,$nz,$prof_h,$prof_ob,$h_sigmax) = @_;

	local($z,$tern,$c,$i);
      if ($model eq "mm5"){
	($modelvp)=&get_netcdf_grid($var,$tt,$x,$y,$nz,4);		#	Variable to interpolate
	($tern)=&get_netcdf_grid("terrain",$tt,$x,$y,$nz,2);
	($landuse)=&get_netcdf_grid("land_use",$tt,$x,$y,$nz,2);
      }
      elsif ($model eq "wrf"){
	($modelvp)=&get_netcdf_grid($var,$tt,$x,$y,$nz,4);		#	Variable to interpolate
	($tern)=&get_netcdf_grid("HGT",$tt,$x,$y,$nz,3);
	($landuse)=&get_netcdf_grid("LU_INDEX",$tt,$x,$y,$nz,3);
      }
      elsif ($model eq "eta"){
	($modelvp)=&get_netcdf_grid($var,$tt,$x,$y,$nz,4);		#	Variable to interpolate
	($tern)=&get_netcdf_grid("terrain",$tt,$x,$y,$nz,2);
	($landuse)=&get_netcdf_grid("land_use",$tt,$x,$y,$nz,2);
      }
	@tmp4=list $tern;
	@lu=list $landuse;

	@modelv=list $modelvp;
	
	@prof_h=list $prof_h;
	@prof_ob=list $prof_ob;

	$c=0;
	$len=scalar(@prof_ob);
	@prof_ob1=(1);
	@prof_h1=(1);
	$ob_prof_height_min=0;
	for($v=0;$v<$len;$v++){
		if($prof_ob[$v] > 999000 || $prof_h[$v] > 999000){	
		}	
		else {
			if($c == 0 ) {  $ob_prof_height_min= $prof_h[$v]; }
			$prof_ob1[$c]=$prof_ob[$v];
			$prof_h1[$c]=$prof_h[$v];
			#print "$v $c $prof_ob1[$c]  $prof_h1[$c]  \n";
			$c=$c+1;
		}
	}
#        print "-----------------------------------------------------------------------------\n";
	$len=scalar(@prof_ob1);if($len < 2){@prof_ob1=(999999,999999);@prof_h1=(0,15000);}

	$prof_h = pdl @prof_h1;
	$prof_ob= pdl @prof_ob1;

	#( $err, $interped_ob ) = interpolate($h_sigmax, $prof_h, $prof_ob);
	($interped_ob,$err)= interpolate($h_sigmax, $prof_h, $prof_ob);

	@interped_ob =list $interped_ob;
	@h_sigmax    =list $h_sigmax;
	
	$len=scalar(@interped_ob);
	for($v=0;$v<$len;$v++){
		if($h_sigmax[$v] <= $ob_prof_height_min){
		    $interped_ob[$v] = 0.0;	
		}	
	}

	return(@interped_ob);
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE zcoord_cals
# PURPOSE: 	Caculates the physical hieght of model sigma layers.
#		
#
# INPUTS:	Time index, x direction index, y direction index of profile and
#		number of levels in model.
#		
# OUTPUT:	Physical height and sigma levels
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub zcoord_calcs {
	
	local($tt,$x,$y,$nz)= @_;
	local($pp,$ptms,$z1,$z2,@tmp,$t,$a,$b,$hgt_mod);
	
	if ($model eq "mm5"){
		($ptop)=&get_netcdf_grid("ptop",$tt,$x,$y,$nz,0);
		($tlp)=&get_netcdf_grid("base_lr",$tt,$x,$y,$nz,0);
		($ts0)=&get_netcdf_grid("base_slt",$tt,$x,$y,$nz,0);

		($ptms)=&get_netcdf_grid("pstarcrs",$tt,$x,$y,$nz,3);
		($ptms)=&get_netcdf_grid("pstarcrs",$tt,$x,$y,$nz,2);
		($sig)=&get_netcdf_grid("sigma_level",$tt,$x,$y,$nz,1);
		($pp)=&get_netcdf_grid("pp",$tt,$x,$y,$nz,4);		#	Pressure profile

		$p0s=$ptms+$ptop;

		$p_sigma=(($sig*$ptms))+$ptop+pp;
		$z1=  ($rd * $tlp) /(2.0 * $g) * pow((log($p_sigma/$p0s)),2); 
		$z2= ($rd * $ts0 /$g )* log($p_sigma/$p0s);
        	$z_sigma=-1*($z1+$z2);
	}          

	if ($model eq "wrf"){
		$ph=&get_netcdf_grid("PH",$tt,$x,$y,$nz,4);
		$phb=&get_netcdf_grid("PHB",$tt,$x,$y,$nz,4);
		$sig=&get_netcdf_grid("ZNU",$tt,$x,$y,$nz,0);
		$hgt_mod=&get_netcdf_grid("HGT",$tt,$x,$y,$nz,3);
		@hgt_mod= list $hgt_mod;
		$ph=(($ph+$phb)/9.81) - $hgt_mod[0] ;
		@ph=list $ph;

		for($zz=0;$zz<$nz;$zz++){
		  $z[$zz]= 0.50* ($ph[$zz] + $ph[$zz + 1]);
		}
		$z_sigma=pdl @z;
	}	

	if ($model eq "eta"){			# Not Developed for Eta model yet

	}	

   return ($z_sigma,$sig);
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
