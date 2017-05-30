#!/usr/bin/perl
#				grads_subs.pl
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
#_____________________________________________________________________________________________
#_______________________________________________________________________________
#								
#	Automated Meteorological Evaluation Tool		
#								
#	Perl Subroutine Collection, 
#	GrADS file generation and plotting subroutines			
#
#	NOAA/ARL/ASMD and US EPA				
#								
#   Version 1.0 Initial development, Rob Gilliam (07-20-2003)	
#______________________________________________________________________________
#
# PURPOSE:	This is a collection of subroutines used by the AMET program.
#		
# SUBROUTINES: (See header of each subroutine for version info, changes and dates)
#		genctl			 --->	Generates a GrADS ctl file for the extracted model fields using information
#						extracted from the model output files
#		make_grads_null_grid     --->   This subroutine makes an empty US GrADS dataset and ctl file for use by					
#					        various statistical plotting routines.
#						
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
print "GrADS subroutines are loaded and ready to access.\n";
#_____________________________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE genctl   
# PURPOSE: A generator and modifier of the GrADS control file for 
#          each archived variable. If not present then it creates a new 
#	   ctl file, if present it modifies with new information.					
#
# INPUTS:	None, just called then uses global variables to generate file
# OUTPUT:	GrADS control file that will allow graphical display of all variables	
#		being evaluated at all times.
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub genctl
{
print "\nGenerating or Modifing the GrADS control file for $varx\n";
$ctlfile=$grads_grids_dir."/".$model.".ctl";
if (-e $ctlfile){
	print "GrADS Control file for $varx DOES exist, will not re-create but will modify for new dataset.\n\n";
}
else{
	print "GrADS Control file for $varx DOES NOT exist, will create\n\n";


open (DAT,"> $ctlfile");

$ddeg=($DX/1000)*(1/111.1111);
$nxlon=ceil(abs($lonmax-$lonmin)/$ddeg);
$nylat=ceil(abs($latmax-$latmin)/$ddeg);


print DAT "dset $grads_grids_dir/data.bin \n";
print DAT "title $model data \n";
print DAT "options template yrev \n";
print DAT "undef -999.99 \n";
print DAT "pdef  $NX[0]  $NY[0] lcc   $ALAT1 $ELON1   1   1   $ALATAN1  $ALATAN2 $ELONV   $DX  $DX \n";
print DAT "xdef  $nxlon linear $lonmin  $ddeg \n";
print DAT "ydef  $nylat linear $latmin  $ddeg \n";
print DAT "zdef    1 linear 1 1 \n";
print DAT "tdef  ".$nt." linear ".$hS."Z".$dS.$mabrvS.$yS."   ".$mod_time_int."HR \n";
print DAT "VARS	$nvars \n";
for (local($n)=0;$n<$nvars;$n++){
print DAT "$obs_id[$n] 1 99 ".$description[$n]." \n";
}
print DAT "endvars \n";

close(DAT);
}

} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE make_grads_null_grid   
# PURPOSE: 	This subroutine makes an empty US GrADS dataset and ctl file for use by					
#		various statistical plotting routines.
# INPUTS:	None, just called and map file is created
# OUTPUT:	grads dataset (all missing values) and grads ctl file (US)
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub make_grads_null_grid
{
	local($null_grid)=zeroes($NX,$NY);
	$null_grid=$null_grid-9999.99;
	writefraw($null_grid,"$par_work/null_grid.bin");

	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
