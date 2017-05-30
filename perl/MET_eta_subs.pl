#!/usr/bin/perl
#				eta_subs.pl
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
#_____________________________________________________________________________________________
#_______________________________________________________________________________
#								
#	Automated Meteorological Evaluation Tool		
#								
#	Perl Subroutine Collection, 
#	Eta Model specific subroutines 			
#
#	NOAA/ARL/ASMD and US EPA				
#								
#   Version 1.0 Initial development, Rob Gilliam (07-20-2003)	
#______________________________________________________________________________
#
# PURPOSE:	This is a collection of subroutines used by the AMET program. In this file are the subroutines listed
#		below which collectively provide and interface to incorperate the NCEP eta model as one of the models
#		that AMET can evaluate.
# SUBROUTINES: (See header of each subroutine for version info, changes and dates)
#		get_mod_dims_eta  --->	Runs wgrib on an Eta model file and extracts Eta specific domain characteristics 
#					including: different time, date, coordinate and projection information. 					
#	  				
#		get_eta_var_grid  --->  Extracts a specified variable from ETA grib data set, writes into a
# 					temporary ieee binary file, reads into a piddle
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
print "ETA model subroutines are loaded and ready to access.\n";	
#/asm1/asmd/ncep/northeast/20040518
#_____________________________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE get_mod_dims_eta   
# PURPOSE: Runs wgrib on an Eta model file and extracts different time, date, 					
#	   coordinate and projection information for use by evaluation program
# INPUTS: NONE, Get model file name which is a global variable	
# OUTPUT: all time, date, prjection and coordinate variables
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub get_eta_dims
{
	local($model_file)= @_;
	local($y,$m,$d,$h);
	open (GLIST, "$amet_bin/wgrib  -V -d 1 $model_file |");
		local($i)=0;
#		print "\n\n********** THE FOLLOWING ETA MODEL FILES WILL BE EVALUATED *****************\n";
		while (<GLIST>) {
			@word=split(/\s+/,$_);			# Split each line by white space
			$nw=@word;
			for (local($n)=0;$n<=$nw;$n++){	
#				print " $word[$n] eq $mod_ntime_var \n";
				if ($word[$n] eq $mod_ntime_var){$TIMEST =$word[$n+1];}
				if ($word[$n] eq $mod_lat_var){  $ALAT1  =$word[$n+1];}
				if ($word[$n] eq $mod_lon_var){  $ELON1  =$word[$n+1];}
				if ($word[$n] eq $mod_lat1_var){ $ALATAN1=$word[$n+1];}
				if ($word[$n] eq $mod_lat2_var){ $ALATAN2=$word[$n+1];}
				if ($word[$n] eq $mod_lonc_var){ $ELONV  =$word[$n+1];}
				if ($word[$n] eq $mod_dxdy_var){ $DX     =$word[$n+1]*1000;}
				if ($word[$n] eq "nx"){ $NX[0]     =$word[$n+1];}
				if ($word[$n] eq "ny"){ $NY[0]     =$word[$n+1];}
			  }					
		  }
		@tmp=split(//,$TIMEST);
		$y=$tmp[0].$tmp[1].$tmp[2].$tmp[3];
		$m=$tmp[4].$tmp[5];
		$d=$tmp[6].$tmp[7];
		$h=$tmp[8].$tmp[9];

		$mod_strt_time=$y."-".$m."-".$d."-".$h;	# Model start date, specified by the time stamp of the first/initial file
		
		$latmax=50;		# These are the min and max lat-lon values for setting up the GrADS plotting program	
		$latmin=$ALAT1-2;	# Currently for the eta model these are har-coded to set to cover Cont. US because			
		$lonmax=-65;		# The Eta grib files do no store lat-lon arrays like the wrf and mm5 do.
		$lonmin=$ELON1-1;		# An algorithm to calculate the lat-lon arrays and then to find min-max will need to be added

	return($mod_strt_time);
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE get_eta_var_grid   
# PURPOSE: Extracts a specified variable from ETA grib data set, writes into a 				
#		temporary ieee binary file, reads into a piddle
# INPUTS: 	Unique variable identifier of desired grid in Eta file	
# OUTPUT:	A piddle of desired variable
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub get_eta_var_grid  
{
	local($varx,$model_file)= @_;
	`$amet_bin/wgrib -s $model_file | grep "$varx" | $amet_bin/wgrib -i -s -bin -h -o $dump_wgrib $model_file`;
		$header = [{Type => 'float', NDims => 2, Dims => [$NX[0],$NY[0]] }];
		$var_array = readflex($dump_wgrib,$header);
		`rm $dump_wgrib`;

	return $var_array;
#	`rm dump`;
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
