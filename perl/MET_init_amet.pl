#!/usr/bin/perl
#	MET_init_amet.pl
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
#_____________________________________________________________________________________________
#_______________________________________________________________________________
#								
#	Automated Meteorological Evaluation Tool		
#								
#	Perl Subroutine Collection, 
#	Initialize AMET 			
#
#	NOAA/ARL/ASMD and US EPA				
#								
#   Version 1.0 Initial development, Rob Gilliam (07-20-2003)	
#
#   Version 1.2 Update and bug fix, Rob Gilliam (05-01-2013)
#
#lines 391,392: Bug fix: V1.2 used index 1 of lat-lon array to find SW corner coordinates. 
#               It should be index 0 since Perl starts indexing at 0 rather than 1. 
#               This has a small, but likely meaningful impact on determination of i/j index of 
#               observations sites relative to model grid.
# ~ line 696:   Update: Model start and end date calculation from ncdump for single time step output files as well 
#               as the number of time periods in file. Also and update to allow sub-hourly model output.
#
# code clean  :   All code was examined and formatted for more conformity
#______________________________________________________________________________
#
# PURPOSE:	This is a collection of subroutines used by the AMET program.
#		
# SUBROUTINES: (See header of each subroutine for version info, changes and dates)
#		set_model_files: Initializes main evaluation probram by gathering information like
#                    the model files to evaluate, directories, variables, etc. The main initialization subroutine...
#
#		define_program_directories: Define all global directories that will be used in the various subroutines and programs.
#						
#		listdims: Prints all dimensions names that are defined the NetCDF file.
#             Mostly used for diagnotics, development or debugging.
#
#		parse_lookup: This routine reads the lookup/input file that controls the model type,					
#                 variables to be evaluated and other properties of the evaluation procedure.
#
#		parse_ncdump_v: This subroutine uses the NCDUMP netCDF utility to extract a specified					
#                   variable from the file. Used only for scalar values like map 
#                   projection information or different types of flags
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
print "Initialization subroutines are loaded and ready to access.\n";
#_____________________________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE set_model_files
# PURPOSE: Specifies the model output file that will be evaluated. This is a fairly simple					
#		step with wrf and mm5 models because the file name is just read from
#		the lookup file. In the case of Eta model evaluation, the associated
#		grib files only contain one time period so a list of files is generated
# 		so the evaluation program can work on all availiabl eta files.
# INPUTS:	model type (wrf, mm5, eta)	
# OUTPUT:	For netcdf-based files, the file handler is inialized. For Eta files
#		an array list of filenames is generated along with date, nt and other info		  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub set_model_files
{
	local($model,$model_file) = @_;
	
	if ($model eq "wrf" || $model eq "mm5") {
		&listdims($mod);			#  Query the NetCDF model file to get dimension information
		&read_mod_latlon($model);		#  Query the NetCDF model file to get coordinate, projection type information

	}
	elsif ($model eq "mcip")			{
		&listdims($mod);			#  Query the NetCDF model file to get dimension information
		&read_mod_latlon($model);		#  Query the NetCDF model file to get coordinate, projection type information
	}
	elsif ($model eq "eta")			{

	}
	print "***********************************************************\n";
	print "  Projection definition extracted from $model model output file	          \n";
	print "SW latitude................................. $ALAT1\n";
	print "SW Longitude................................ $ELON1\n";
	print "Tangent Lambert latitude 1 ................. $ALATAN2\n";
	print "Tangent Lambert latitude 2 ................. $ALATAN1\n";
	print "Center longitude of lambert projection ..... $ELONV\n";
	print "Grid spacing (m) .......................... $DX\n";
	print "***********************************************************\n";
	print "Start time of Evaluation ................... $date_start $hs Z\n";
	print "Number of hours to run eval ................ $nt\n";
	print "***********************************************************\n";
	
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE define_program_directories   
# PURPOSE: Define all global directories that will be used in the various 					
#		subroutines and programs
# INPUTS:	NONE	
# OUTPUT:	directory definitions	
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub define_program_directories
{

## NOTE: amet_base, amet_bin, and amet_out are defined in MET_matching, obs_dir is from AMETPERLINPUT
#	$amet_dir		="/project/amet";			# Base MADIS directory
#	$amet_bin		=$amet_dir."/bin";			# MADIS' utility location
	$par_work		=$amet_out."/tmp";			# Work directory where various temporary files are stored
	$par_temp		=$amet_bin."/madis_input";     		# Directory where MADIS Utility input files are stored, these are templated (read-only)
	$plot_dir		=$amet_out."/plots";			# Directory for statistical plots
	$grads_grids_dir	=$par_work."/gradsout";
	
	$surfrad_dir		=$obs_dir."/point/surfrad";
 
	$grads_grids_dir	=$model_data_dir."/gradsout";	
	
	#-------------------------------#
	#	Define Constants 	#
	#-------------------------------#
	$mu	=0.000001;
	$pi	=3.14159265 ;
	$r2d	=180/$pi;
	$d2r	=1/$r2d;
	$rd	=287.04;
	$g	=9.8;

} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
# 			SUBROUTINE LISTDIMS  					 	 
# PURPOSE: Prints all dimensions names that are defined the NetCDF file
#
# INPUTS:	$nc		NetCDF file handler
# OUTPUT:	$dim[:]		Array of all dimensions specified in NetCDF file
#				(e.g. XDIM,YDIM,ZDIM,TDIM) 
#	
# Revisions:	1.0	May   25, 2003, Initial version (Rob Gilliam)
#		1.1	July   8, 2003, 1) Cleaned up code look (no techincal update) 
#					and 2) added a version update section in the 
#					subroutine header 3) elminated screen print statements 
#					4) added more comments	(Rob Gilliam)          
#))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub listdims
{
	local($nc) = @_;					# Read-in the NetCDF file handle 

	local($varlist) = $nc->getdimensionnames();		# Query NetCDF file for dimension names
	local($k)=0;

  	foreach(@$varlist){					# Loop through dimension name array and query the length of each
  		$dim[$k]=$_;
  		eval {$diml[$k]=$nc->dimsize($dim[$k]);};	# Specific statement that queries dimension length/size
## DEBUG	print "$dim[$k] --> $diml[$k]    $mod_ntime_var\n";
		
		if ($dim[$k] eq $mod_ntime_var){  $nt=$diml[$k];}

    		$k=$k+1;
  	}							# END of LOOP through dimension names
	$ldim=$k+1;

} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE parse_lookup   
# PURPOSE: This routine reads the lookup/input file that controls the model type,					
#	   variables to be evaluated and other properties of the evaluation procedure
# INPUTS:	NO EXPLICIT INPUT but does read var_look_sfc.tab input file
# OUTPUT:	Variable name array, projection variables definition, model type and data location
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub parse_lookup
{
	local($config_file) = @_;
	open (FILE,"< $config_file");
	@dat=<FILE>;
	local($l)=scalar(@dat);
	chomp(@dat);
	close(FILE);
  $varn=0;
  for (local($i)=0;$i<=$l;$i++){
  	@str=split(/\s+/,$dat[$i]);

  	#-----------------------------------------------------
  	## Break up the Grid variable specs in look up file
  	#-----------------------------------------------------
  	if ($str[0] eq "grid"){					# Parse Grid related variables
  		for ($j=0;$j<=4;$j++){
  			if ($str[$j] eq $model){$mod_loc=$j;}
  		}
  		@str1=split(/\s+/,$dat[$i+1]);
  		@str2=split(/\s+/,$dat[$i+2]);
  		@str3=split(/\s+/,$dat[$i+3]);
  		@str4=split(/\s+/,$dat[$i+4]);
  		@str5=split(/\s+/,$dat[$i+5]);
  		@str6=split(/\s+/,$dat[$i+6]);
  		@str7=split(/\s+/,$dat[$i+7]);
  		@str8=split(/\s+/,$dat[$i+8]);
  		@str9=split(/\s+/,$dat[$i+9]);
  		
  		$mod_lat_var   =$str1[$mod_loc];
  		$mod_lon_var   =$str2[$mod_loc];
  		$mod_lat1_var  =$str3[$mod_loc];
  		$mod_lat2_var  =$str4[$mod_loc];
  		$mod_lonc_var  =$str5[$mod_loc];
  		$mod_dxdy_var  =$str6[$mod_loc];
  		$mod_ntime_var =$str7[$mod_loc];
  		$mod_lu_var    =$str8[$mod_loc];
  		$mod_start_var =$str9[$mod_loc];
  	}
  	elsif ($str[0] eq "sfcobs"){				# Parse Surface Related Variables to Compare
		
		$nvars_sfc=$str[1];
  		@models=split(/,/,$str[2]);
  		for (local($k)=0;$k<=2;$k++){
  			if ($models[$k] eq $model){$mod_loc=$k;}
  		}
		
		for ($j=0;$j<=$nvars_sfc;$j++){		# Split out important specifications for each variable
  			@lin_split_space	=split(/\s+/,$dat[$i+$j+1]);		# Splits line by space to seperate groups of specs
  			@split_mod_var		=split(/,/,$lin_split_space[1]);
  			@conversion_split	=split(/,/,$lin_split_space[2]);
  			@unknow_split		=split(/,/,$lin_split_space[4]);

  			$obs_id[$varn] 	=$lin_split_space[0];
  			$mod_id[$varn] 	=$split_mod_var[$mod_loc];
  			$conversion_fac[$varn]	=$conversion_split[$mod_loc];
 			$level[$varn]		=$lin_split_space[3];
  			$description[$varn]	=$lin_split_space[5];
			$eval_type[$varn]		="sfc";
			print "Variable $description[$varn] id-> $obs_id[$varn]   will be evaluated \n";
			$varn=$varn+1;
  		}
  		
  	}
  	elsif ($str[0] eq "hydro"){							# Parse Surface Related Variables to Compare
		$nvars_hydro=$str[1];
  		@models=split(/,/,$str[2]);
  		for (local($k)=0;$k<=2;$k++){
  			if ($models[$k] eq $model){$mod_loc=$k;}
  		}
		
		for ($j=0;$j<$nvars_hydro;$j++){				# Split out important specifications for each variable
  			@lin_split_space	=split(/\s+/,$dat[$i+$j+1]);		# Splits line by space to seperate groups of specs
  			@split_mod_var	=split(/,/,$lin_split_space[1]);
  			@conversion_split	=split(/,/,$lin_split_space[2]);
  			@unknow_split		=split(/,/,$lin_split_space[4]);

  			$obs_id[$varn] 	=$lin_split_space[0];
  			$mod_id[$varn] 	=$split_mod_var[$mod_loc];
  			$conversion_fac[$varn]	=$conversion_split[$mod_loc];
 			$level[$varn]		=$lin_split_space[3];
  			$description[$varn]	=$lin_split_space[5];
			$eval_type[$varn]		="precip";
#			print "Variable $description[$varn] id-> $obs_id[$varn]   will be evaluated \n";
			$varn=$varn+1;

  		}
  		
  	}
  	
}
	#	Surface Related Variables to Examine
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE parse_ncdump_v  
# PURPOSE: This subroutine uses the NCDUMP netCDF utility to extract a specified					
#		variable from the file. Used only for scalar values like map 
#		projection information or different types of flags
# INPUTS: dummy output file from ncdump, variable name to search	
# OUTPUT: value of variable	
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub parse_ncdump_v
{
	local($var) = @_;
	if ($model eq "mm5"){$varfind="-v $var";$dxfactor=1000;}
	elsif ($model eq "wrf" || $model eq "mcip"){$varfind=" -h ";$var=":".$var;$dxfactor=1;}

	if ($model eq "mm5"){
	# Search contents of file for variable
		open (MMOUT2, "$amet_bin/ncdump $varfind $model_file |");		# list contents of MCIP output directory
		while (<MMOUT2>) {			# LOOP THROUGH THE INDIVIDUAL FILES IN MAIN MM5 Dump directory

			@str=split(/\s+/,$_);
#		print "$_";
  	#-----------------------------------------------------
  	## Break up the Grid variable specs in look up file
  	#-----------------------------------------------------
  			if ($str[1] eq $var){
  				$varvalue=$str[3];
  			}
  		}
	}	# END OF MM5 Parse
	
	elsif($model eq "wrf"  || $model eq "mcip"){
		open (MMOUT2, "$amet_bin/ncdump $varfind $model_file |");		# list contents of MCIP output directory
		while (<MMOUT2>) {			# LOOP THROUGH THE INDIVIDUAL FILES IN MAIN MM5 Dump directory

			@str=split(/\s+/,$_);

  	#-----------------------------------------------------
  	## Break up the Grid variable specs in look up file
  	#-----------------------------------------------------
  			if ($str[1] eq $var){
   				if ($var ne ":".$mod_start_var){
   					@tmp=split(/f/,$str[3]);
  					$varvalue=$tmp[0];
  				}
  				else{
  					@tmp=split(/\"/,$str[3]);
  					$varvalue=$tmp[1];
   				}
  			}
  		}		
	}	# END of WRF Parse

	return $varvalue;
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE JulianDate   
# PURPOSE: Computes the Julian day from the provided time in seconds					
#
# INPUTS:	Date in aboslute terms (seconds)	
# OUTPUT:	Julian day
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub julianDate
{
    my($year,$mon,$mday) = @_;
    @theJulianDate = ( 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 );
    $mon=$mon-1;
    $days=$theJulianDate[$mon];
    $jd=$days + $mday + &leapDay($year,$mon,$mday);
#    print "$mon $mday $days $jd\n";
     return($jd);
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE leapDay   
# PURPOSE: 	Determines if the provided date is a leap year or not, Called by
#		Subroutine Julian Day					
#
# INPUTS: Year, Month and Day	
# OUTPUT: Leap year flag
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub leapDay {

    my($year,$month,$day) = @_;
$year=$year-1900;
    if (year % 4) {
        return(0);
    }

	  if (!(year % 100)) {             # years that are multiples of 100
          if (year % 400) {            # unless they are multiples of 400
            return(0);
            }
            }

    if (month < 2) {
        return(0);
        } 
    elsif ((month == 2) && (day < 29)) {
    	return(0);
    	} 
    else {
    	return(1);
    	}	
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE read_mod_latlon
# PURPOSE: Reads model NetCDF file and stores lat lon grids in memory 					
#
# INPUTS:	Nothing, it gets lat-lon variable from lookup file and reads arrays from NetCDF output
#		Does not apply to Eta model, those are aquired from wgrib
# OUTPUT:	
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub read_mod_latlon
{
	local($model) = @_;
	
	if ($model eq "mm5" || $model eq "wrf") {				# WRF and MM5 netcdf-based Coordinate System Information Extractor				
	  print "*************  $mod_lat_var $mod_lon_var $mod_lat2_var $mod_lat1_var *************************\n";
	  $lonp=$mod->get($mod_lon_var);
	  $latp=$mod->get($mod_lat_var);
	  $lu=$mod->get($mod_lu_var);
	  $ndims = $latp->getndims;
	
	  if ($ndims eq "2"){@o=(0,0);}		# @o is the coordinate of the southwest corner of the grid
	  if ($ndims eq "3"){@o=(0,0,0);}		# This conditional determines if the lat-lon grid is 2 or 3-D
		
	  $latmax=max($latp);
	  $latmin=min($latp);
	  $lonmax=max($lonp);
	  $lonmin=min($lonp);
	  print "Min/Max Longitude of $model dataset....  $lonmin   $lonmax\n";
	  print "Min/Max Latitude of $model dataset ....  $latmin   $latmax\n";
	  print "Landuse variable is $mod_lu_var $ndims --- $mod_lon_var $mod_lat_var @o\n";

	  $ALAT1=at($latp,@o);
	  $ELON1=at($lonp,@o);

	  $ALATAN1=&parse_ncdump_v($mod_lat2_var);
	  $ALATAN2=&parse_ncdump_v($mod_lat1_var);
	  $ELONV  =&parse_ncdump_v($mod_lonc_var);
	  $DX     =&parse_ncdump_v($mod_dxdy_var)*$dxfactor;
	
	  ##### Start Time Determination
	  $tm_str=&parse_ncdump_v($mod_start_var);
	  @tmp=split(/_/,$tm_str);
	  @date_start=split(/-/,$tmp[0]);$yS=$date_start[0];$mS=$date_start[1];$dS=$date_start[2];
	  @time_start=split(/:/,$tmp[1]);$hrS=$time_start[0];$mnS=$time_start[1];$seS=$time_start[2];
	  $mod_strt_time=$yS."-".$mS."-".$dS."-".$hrS;	
	}		# END of WRF/MM5 coordinate information
	
	elsif ($model eq "mcip" ){
		
	  $mod_grid  = PDL::NetCDF->new ($mcip_grid_file);
	  $lonp= $mod_grid ->get($mod_lon_var);
	  $latp= $mod_grid ->get($mod_lat_var);
	  $lu  = $mod_grid ->get($mod_lu_var);
	  $ndims = $latp->getndims;

	  $latmax=max($latp);
	  $latmin=min($latp);
	  $lonmax=max($lonp);
	  $lonmin=min($lonp);
	  print "Min/Max Longitude of $model dataset....  $lonmin   $lonmax\n";
	  print "Min/Max Latitude of $model dataset ....  $latmin   $latmax\n";
        $ALAT1=at($latp,0,0,0,0);
        $ELON1=at($lonp,0,0,0,0);
        
        
	  $ALATAN1=&parse_ncdump_v($mod_lat2_var);
	  $ALATAN2=&parse_ncdump_v($mod_lat1_var);
	  $ELONV  =&parse_ncdump_v($mod_lonc_var);
	  $DX     =&parse_ncdump_v($mod_dxdy_var)*$dxfactor;
	  #print "$mod_start_var	$ALAT1 $ELON1 $ALATAN1 $ALATAN2 $ELONV $DX  ,  $mod_lat2_var,$mod_lat1_var, $mod_lonc_var, $mod_dxdy_var \n";

	}


} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE get_var_dims   
# PURPOSE: 	Reads each variable into an array and queries the number of dimensions, then
#		stores these dimensions into an array for future use. This step will keep
#		the program from having to read the entire array each timestep. 					
#
# INPUTS:	Number of variables
#		
# OUTPUT:	arrays NX, NY, NT, NZ 
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub get_var_dims 
{
	local(@varlist)=@_;
	local($v);
	
	
	$nvars=@varlist;
		print "____________________________________________________________________________________________\n";
		print "				Model Variables to be evaluated					   \n";
		print "____________________________________________________________________________________________\n";
		
		 my $varlist = $mod->getdimensionnames();

	for ($v=0;$v<$nvars;$v++){					#	Main LOOP through each variable
		$var_array=$mod->get($varlist[$v]);
		$ndims[$v] = $var_array->getndims;
		@dims = dims($var_array);

		if ($ndims[$v] eq 3){
			$NX[$v]=$dims[0];
			$NY[$v]=$dims[1];
			$NT[$v]=$dims[2];
			$NZ[$v]="";
		}
		elsif($ndims[$v] eq 4){
			$NX[$v]=$dims[0];
			$NY[$v]=$dims[1];
			$NZ[$v]=$dims[2];
			$NT[$v]=$dims[3];
		}
#		print "@varlist\n";
		print "$v $mod_id[$v] $varlist[$v] has $ndims[$v] dims---> NX:$NX[$v]   NY:$NY[$v]   NT:$NT[$v]   NZ:$NZ[$v]   \n";
		
		
	}
	

} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE file_attrib
# PURPOSE: 	Retrieves the Attributes of a file or list of files in specified
#		directory
#
#
# INPUTS:	Directory and file
#
# OUTPUT:	arrays NX, NY, NT, NZ
#
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub file_size
{
	local($dir,$file,$attrib_loc)=@_;

chdir $dir;

foreach (<$file>){#loops through each filename
$filesize{$_} = (stat $_)[$attrib_loc];#pulls the 9th item from the array created by the stat function, which is the date of last modification in seconds.
}

for(sort {$filesize{$a} <=> $filesize{$b}} keys %filesize){#sorts the hash by value
$attrib=$filesize{$_};
}
return($attrib);
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE mm5_date
# PURPOSE: 	Uses fortran program subheader to extract date information
#		from specified MMOUT file for use by AMET
#
# INPUTS:	MMOUT file (absolute path)
#
# OUTPUT:	Initial date, number of time periods and the initial forecast hour
#
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub model_date
{
 local($model_file,$model,$file_date)=@_;
 local($i,$t,@wrd,@dat);
 	 print " ******************************* AMET_BIN $amet_bin \n";
	
 local($Second, $Minute, $Hour, $Day, $Month, $Year)=gmtime(time);
 $Month=$Month+1;
 $Year=$Year+1900;

 if($model eq "mm5") {
  	if($file_date){
 		print "$model_file,$model,$file_date \n";
		local(@tmp2)		=split(/\//,$model_file);		# Split file path by / to get file name
		local($path_length)	=scalar(@tmp2)-1;
		$mmout_file		=$tmp2[$path_length];			# Define next MM5 file name
		@file_parts=split(/\./,$mmout_file);
		($pre,$y,$m,$d,$hour_part)=split(/\./,$mmout_file);
		($hs,$num_hours)=split(/-/,$hour_part);
		$date_start=$y."-".$m."-".$d."-".$hs;
		$fcast_hr=0;
		$init_utc=$hs;
		print "-----------------------------------------------\nMM5 Output Time Characteristics   \n";
		print "File Name: $model_file \n";
		print "Start date: $y,$m,$d,$hs \n";
		print "Number of time step: $num_hours\n";
		print "Time step: $output_int hr\n";
		print "Forecast Hour: $fcast_hr \n";
		print "Forecast Cycle: $hs UTC	\n";
		print "------------------------------------------------\n\n";
		return($model_file,$date_start,$num_hours,$fcast_hr,$init_utc);
	
 	}
 	else {
 		print "-------------------------------------------\nChecking MM5 output for date/time characteristics\n";
		system("$amet_bin/examiner $model_file >sub.out");
		print "$amet_bin/examiner $model_file >sub.out";
		@maa=("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
		open(INFO, "sub.out"); @array=<INFO>; close (INFO);

		### SEARCH 1 in MM5 Description File (Start Date). This code segment 
		#   finds the start date and parses the line to get Year, Month, Day, and Hour Start.
		#-------------------------------------------------------------------------------------
		$search1="Start date is";
		foreach $line (@array){ if ($line =~ /$search1/){ ($j1,$j2,$j3,$j4,$dow,$ma,$d,$timehms,$year)=split(/\s+/,$line);} }
		($hr,$min,$sec)=split(/\:/,$timehms);
		for($i=0;$i<=11;$i++){
  			if($ma eq $maa[$i]){
  				$m=$i+1;
  			}	
		}	
		if($min > 30) {
			($y1,$m1,$d1, $h1,$min,$sec) = Add_Delta_DHMS($year,$m,$d, $hr,$min,$sec,0,1,0,0);
		}
		else {
			($y1,$m1,$d1, $h1,$min,$sec) = Add_Delta_DHMS($year,$m,$d, $hr,$min,$sec,0,0,0,0);
		}
		############################################################
		### SEARCH 2 in MM5 Description File (Start Date). This code segment finds 
		#   Number of time steps.
		#-------------------------------------------------------------------------------------
		$search2="Total number of timesteps is";
		foreach $line (@array){ if ($line =~ /$search2/){ ($j1,$j2,$j3,$j4,$j5,$nt)=split(/\s+/,$line); } }

		############################################################
		### SEARCH 3 in MM5 Description File (Start Date). This code segment finds 
		#   the time step information in seconds and converts to hours
		#-----------------------------------------------------------------------------------
		$search3="Time increment is";
		foreach $line (@array){
		if ($line =~ /$search3/){ ($j1,$j2,$j3,$j4,$dts)=split(/\s+/,$line); }
		}
		$dth=$dts/3600;
		$output_int=$dth;
		############################################################
		############################################################
		### SEARCH 4 in MM5 Description File (Start Date). This code segment finds 
		#   the end date of the model run
		#-----------------------------------------------------------------------------------
		$search4="Found timestep for";
		foreach $line (@array){ if ($line =~ /$search4/){ ($j1,$j2,$j3,$dow,$ma,$d,$timehms,$year)=split(/\s+/,$line); } }
		($hr,$min,$sec)=split(/\:/,$timehms);
		for($i=0;$i<=11;$i++){
  			if($ma eq $maa[$i]){
  				$m=$i+1;
  			}	
		}	
		if($min > 30) {
			($ye,$me,$de,$he,$mine,$sece) = Add_Delta_DHMS($year,$m,$d, $hr,$min,$sec,0,1,0,0);
		}
		else {
			($ye,$me,$de,$he,$mine,$sece) = Add_Delta_DHMS($year,$m,$d, $hr,$min,$sec,0,0,0,0);
		}
		#-------------------------------------------------------------------------------------
		############################################################
   		$hminus=(-1*$dth*$nt)+1;
   		($ys,$ms,$ds,$hs,$min,$sec) = Add_Delta_DHMS($ye,$me,$de,$he,$mine,$sece,0,$hminus,0,0);
   		$fcast_hr = Delta_Days($ys,$ms,$ds,$y1,$m1,$d1);
		$date_start=$ys."-".$ms."-".$ds."-".$hs;
		$init_utc=$hs;
		print "-----------------------------------------------\nMM5 Output Time Characteristics\n";
		print "File Name: $model_file \n";
		print "Start date: $ys,$ms,$ds,$hs \n";
		print "End Date date: $ye,$me,$de,$he \n";
		print "Number of time step: $nt\n";
		print "Time step: $dth hr\n";
		print "Forecast Hour: $fcast_hr \n";
		print "Forecast Cycle: $hs UTC	\n";
		print "------------------------------------------------\nNow converting Raw MM5 to NetCDF format using archiver\n";
		`rm sub.out`;
		if(-e "$tmp_dir/mmout.nc"){ `rm $tmp_dir/mmout.nc`; }
		print "$amet_bin/archiver $model_file 0 $nt $tmp_dir/mmout.nc\n------------------------------------------------\n\n";

		$diff_cur_mod = Delta_Days($ye,$me,$de,$Year,$Month,$Day);
		if($diff_cur_mod >= 0){
		   `$amet_bin/archiver $model_file 0 $nt $tmp_dir/mmout.nc`; #or die "An error occured when converting MM5 to netCDF format\n\n";
	 	   $original_model_file="$model_file";
	 	   $model_file="$tmp_dir/mmout.nc";
	 	   return($model_file,$date_start,$nt,$fcast_hr,$init_utc);
		}
		else {
	   	 exit(0);
		}
	
    	 } # END of CONDITION THAT FILE NAME DATE METHOD IS NOT TO BE USED
   }   # END OF CONDTION THAT MODEL IS MM5
 if($model eq "wrf") {
        if(-e "sub.out"){`rm sub.out`;}
 	`$amet_bin/ncdump -v Times $model_file >sub.out`;
  	open (FILE,"< sub.out");@dat=<FILE>;local($l)=scalar(@dat);chomp(@dat);close(FILE);
  	$search1=" Times =";$search2="}";
	local($i)=0;
	foreach $line (@dat){
	   if ($line =~ /$search1/){
	      $pos1=$i+1;
	      ($junk1,$dates,$junk2)=split(/\"/,$dat[$pos1]);
	      ($junk1,$date2,$junk2)=split(/\"/,$dat[$pos1+1]);
	   }
	   if ($line =~ /$search2/){
	      $pos2=$i-1;
	      ($junk1,$datee,$junk2)=split(/\"/,$dat[$pos2]);
	   }
	   $i=$i+1;
	}
	if(!$date2) {  $date2=$dates;	}
	
	($ys,$ms,$ds,$hs,$mins,$secs)=split(/[-_:]/,$dates);
	($ye,$me,$de,$he,$mine,$sece)=split(/[-_:]/,$datee);
	($y2,$m2,$d2,$h2,$min2,$sec2)=split(/[-_:]/,$date2);
	($Dd,$Dh,$Dm,$Ds) = Delta_DHMS($ye,$me,$de,$he,$mine,$sece, $ys,$ms,$ds,$hs,$mins,$secs);
	($Dd1,$dth,$Dm1,$Ds1) = Delta_DHMS($ys,$ms,$ds,$hs,$mins,$secs,$y2,$m2,$d2,$h2,$min2,$sec2);
	
	# Added to work with sub hourly output.
	$dth=$dth + $Dm1/60;
	
	if($dates eq $datee) {	$dth =24; }
	
	if($Dh < 0) { $Dh=$Dh*(-1); }
	if($Dd < 0) { $Dd=$Dd*(-1); }
	$nt= 1.0*($Dd*24/$dth)+($Dh/$dth)+1;
	
        $date_start=$ys."-".$ms."-".$ds."-".$hs;
  	if(-e "sub.out"){`rm sub.out`;}
        local($fcast_hr)=0;
        $init_utc=$hs;
	print "-----------------------------------------------\nWRF Output Time Characteristics\n";
	print "File Name: $model_dir/$model_file \n";
	print "Start date: $ys,$ms,$ds,$hs \n";
	print "End Date date: $ye,$me,$de,$he \n";
	print "Number of time step: $nt\n";
	print "Time step: $dth hr\n";
	print "Forecast Hour: $fcast_hr \n";
	print "Forecast Cycle: $init_utc UTC	\n";
	print "------------------------------------------------\n\n";
	$diff_cur_mod = Delta_Days($ye,$me,$de,$Year,$Month,$Day);
	if($diff_cur_mod >= 0){
	   $original_model_file="$model_file";
	   return($model_file,$date_start,$nt,$fcast_hr,$init_utc);
	}
	else {
	    exit(0);
	}

 }
 if($model eq "mcip") {
        if(-e "sub.out"){`rm sub.out`;}
	`$amet_bin/ncdump -v TFLAG $model_file >sub.out`;
 	open(INFO, "sub.out"); @array=<INFO>; close (INFO);

	############################################################
	### SEARCH 1 Find Date start in NetCDF file
	#-----------------------------------------------------------------------------------
	$search1=":SDATE";
	foreach $line (@array){
	if ($line =~ /$search1/){ ($j1,$j2,$j3,$dates)=split(/\s+/,$line); }
	}
	@j1=split(//,$dates);
	
	$ys=$j1[0].$j1[1].$j1[2].$j1[3]; $ys=$ys*1;
	$jds=$j1[4].$j1[5].$j1[6]; $jds=$jds*1;
	
	($ys,$ms,$ds) = Add_Delta_Days($ys,1,1, $jds - 1);
	############################################################
	### SEARCH 2 Find Date start in NetCDF file
	#-----------------------------------------------------------------------------------
	$search2="TSTEP = UNLIMITED";
	foreach $line (@array){
#	if ($line =~ /$search1/){ ($j1,$j2,$j3)=split(/[-_:]/,$line); }
	if ($line =~ /$search2/){ ($j1,$j2,$j3)=split(/[-_:()]/,$line); }
	}
	@j1=split(//,$j2);
	$nt=$j1[0].$j1[1]; $nt=$nt*1;
	############################################################
  	$search1=" TFLAG =";
	local($i)=0;
	foreach $line (@array){
	   if ($line =~ /$search1/){
	      $pos1=$i+1;
	      ($junk1,$hs,$junk2)=split(/\,/,$array[$pos1]);
	   }
	   $i=$i+1;
	}
	($ye,$me,$de,$he,$mine,$sece) = Add_Delta_YMDHMS($ys,$ms,$ds,$hs,0,0, 0,0,0,$nt-1,0,0);
	############################################################
        # Misc other variables
        $dth=$output_int;
        $date_start=$ys."-".$ms."-".$ds."-".$hs;
  	if(-e "sub.out"){`rm sub.out`;}
        local($fcast_hr)=0;
        $init_utc=$hs;
	print "-----------------------------------------------\nWRF Output Time Characteristics\n";
	print "File Name: $model_dir/$model_file \n";
	print "Start date: $ys,$ms,$ds,$hs \n";
	print "End Date date: $ye,$me,$de,$he \n";
	print "Number of time step: $nt\n";
	print "Time step: $dth hr\n";
	print "Forecast Hour: $fcast_hr \n";
	print "Forecast Cycle: $init_utc UTC	\n";
	print "------------------------------------------------\n\n";
	$diff_cur_mod = Delta_Days($ye,$me,$de,$Year,$Month,$Day);
	if($diff_cur_mod >= 0){
	   $original_model_file="$model_file";
	   return($model_file,$date_start,$nt,$fcast_hr,$init_utc);
	}
	else {
	    exit(0);
	}

 }

} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________

#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE email_user
# PURPOSE: 	Uses fortran program subheader to extract date information
#		from specified MMOUT file for use by AMET
#
# INPUTS:	MMOUT file (absolute path)
#
# OUTPUT:	Initial date, number of time periods and the initial forecast hour
#
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub email_user
{
	local($email,$login,$pid,$mmout,$model)=@_;

  open (MAIL, "/bin/date |");
  @dat=<MAIL>;
  $date=$dat[0];

  print "$email,$login,$pid,$mmout,$model\n";
  $body[0]="----------- Atmospheric Model Evaluation Tool (AMET) --------------------\n";
  $body[1]="									   \n";
  $body[2]=" This is a progress report of the AMET observation-model matching module\n";
  $body[3]="__________________________________________________________________________\n\n";
  $body[4]="User name:    $login\n";
  $body[5]="Project name: $pid\n";
  $body[6]="Model file:   $mmout\n";
  $body[7]="_____________________________________________________________________________\n";
  $body[8]="\nYour model output file has been matched with all availiable $obs_format $eval_class observations.\n";
  $body[9]="\nAll resulting obs-model pairs have been placed in the database and are ready for evaluation.\n";
  $body[10]="\nUse the evaluation web interface to examine the results.\n http://$server/amet\n";

  %mail = (
         from => 'gilliam.robert@epa.gov',
         to => "$email",
         subject => 'AMET Observation-Model Matching Auto-emailer',
         Message => "@body"
  );

  sendmail(%mail) || print "Error: $Mail::Sendmail::error\n";


} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________

#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE trimwhitespace
sub trimwhitespace($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________

