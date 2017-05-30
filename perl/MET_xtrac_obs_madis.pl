#!/usr/bin/perl
#				xtrac_obs_madis.pl
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
#_____________________________________________________________________________________________
#_______________________________________________________________________________
#								
#	Automated Meteorological Evaluation Tool		
#								
#	Perl Subroutine Collection, 
#	Extract Obsevations from Madis database 			
#
#	NOAA/ARL/ASMD and US EPA				
#								
#   Version 1.0 Initial development, Rob Gilliam (07-22-2003)	
#______________________________________________________________________________
#
# PURPOSE:	This is a collection of subroutines used by the AMET program.
#		
# SUBROUTINES: (See header of each subroutine for version info, changes and dates)
#		madis_util: Provided a date in (YYYYMMDD_HHHH) format, this subroutine extracts 
#						    all observations (sfc, upper-air, profiler, precip) from MADIS database
#						    All database files must be downloaded before execution.
#
#		08-04-2005:	New version of this subroutine was developed. The main changes are a more efficient
#               string match-replace method to change the parameters of the template (.par in amet_base/input dir)
#               file. This change reduces the number of lines of code and many confusing aspects of the subroutine.
#               Also, the changes will work for all MADIS .par files
#
#   Version 1.2 No change to code except some code reformatting, Rob Gilliam (05-01-2013)
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
print "Extract Obsevations from Madis database subroutines are loaded and ready to access.\n";
#_____________________________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE madis_util  
# PURPOSE: MADIS Utility Programs to Extract Observations from MADIS datafiles					
#--------------------------------------------------------
# UTILITIES that are executed	
#  sfcdump, raobdump, mapdump, acarsdump, npndump, hydrodump
#
# INPUTS: Date/Time to extract (time_get) and the index corresponding to the madis program to use	
# OUTPUT: MADIS  observation records in the text file format
#				  
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub madis_util
{

local($time_get,$i)= @_;
print "Extracting MADIS data for time $time_get \n";
#--------------------------------------------------------------------------------
#	Define the madis utilites for each observation type
@madis_exes=("sfcdump","raobdump","mapdump","acarspdump","npndump","hydrodump");
#--------------------------------------------------------------------------------


#------------------------------------------------------------------------
#	Define template file for the particular utility, the dynamically 
#	generated .par file and utilities executable
$filei =$par_temp."/$madis_exes[$i].par";
$fileo ="$madis_exes[$i].par";
$exe   ="$madis_utils/$madis_exes[$i].exe";
#--------------------------------------------------------------------------------
if(-e "$madis_exes[$i].par") { `rm *.par *.txt`;}
#--------------------------------------------------------------------------------
#	Open and read template file into @lin array
open (DAT,"< $filei");@lin=<DAT>;
  $l=scalar(@lin);
close(DAT);
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
#	Write out new file and in the process replace codes in template file
#	with the correct value that is determined from model output
open (DAT,"> $fileo");
  for ($j=0;$j<=$l;$j++){
	
	  $lin[$j]=~ s/R-DX/$DX/; 	
	  $lin[$j]=~ s/R-LAT1/$ALAT1/;
	  $lin[$j]=~ s/R-LON1/$ELON1/;
	  $lin[$j]=~ s/R-CLON/$ELONV/;
	  $lin[$j]=~ s/R-TAN1/$ALATAN1/;
	  $lin[$j]=~ s/R-TAN2/$ALATAN2/;
	  $lin[$j]=~ s/R-NX/$NX[0]/;
	  $lin[$j]=~ s/R-NY/$NY[0]/;
	  $lin[$j]=~ s/R-DATE/$time_get/;
	  print DAT "$lin[$j]";
  }
close(DAT);
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
#	Execute the MADIS utility and move output text file to temporary run dir
	`$exe`;
#--------------------------------------------------------------------------------
	return("$tmp_dir/$madis_exes[$i].txt");

} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
