#!/usr/bin/perl
#				protocol.pl
#__________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________
#_____________________________________________________________________________________________
#_______________________________________________________________________________
#								
#	Automated Meteorological Evaluation Tool		
#								
#	Model Evaluation Protocol Script
#			
#
#	NOAA/ARL/ASMD and US EPA				
#								
#   Version 1.0 Initial development, Rob Gilliam (02-28-2004)	
#______________________________________________________________________________
#
# PURPOSE: To execute R model evaluation protocol script for various data subsets.
#		
#		
# SUBROUTINES: (See header of each subroutine for version info, changes and dates)

#__________________________________________________________________________________________________________________________
$config=	$ARGV[0];		## Configuration File

   use lib "$ENV{AMET_PERL_LIB}";   
   use Mail::Sendmail; 
   use Date::Calc qw(:all);
 
####################################################################################
#	System Specific Config (Manual change is  required for difference systems)
#-----------------------------------------------------------------------------------
     # Environmental AMET Variables
   	$amet_base		=$ENV{AMETBASE};
        $dbase			=$ENV{AMET_DATABASE};
   	$template_dir		=$amet_base."/input/protocol";
	$proto_dir		=$amet_base."/www/amet/protocol";	#  Main directory to store eval. protocol output
        require($amet_base."/configure/amet-www-config.pl");
     # -----------------------------------------------------
     # Environmental Variables for executing R scripts
	$ENV{R_HOME}		= $R_dir;
	$ENV{R_LIBS} 		= $R_lib;
	$ENV{LD_LIBRARY_PATH}	= $R_proj_lib;
     # -----------------------------------------------------
     ($project_id,$model,$date_start,$date_end,$users_email,$send_mail)=&parse_initconfig($config);
     $ns=scalar(@evals)-1;

     ##  Make tmp dir for R execution
     $tmprand="tmp.".int(rand(1000));
     print "Generating a temporary run directory..... $tmprand \n";
     `mkdir $tmprand`;
     chdir($tmprand);
     $ENV{AMETCFGS}		= "./";


     if(-e "$proto_dir/$project_id") {}
     else {
     	`mkdir $proto_dir/$project_id`;
     	`mkdir $proto_dir/$project_id/figures`;
     	`mkdir $proto_dir/$project_id/save`;    	
     }
     
#-----------------------------------------------------------
# SURFACE EVALUTATION
 for($ss=0;$ss<=$ns;$ss++){

      ($doanal,$subhead,$sdates,$sdatee,$maxr)=&parse_subconfig($config,$evals[$ss]);
     
      if($doanal eq 1){
           print "Parsing evaluation subset $evals[$ss]:  $tmprand\n\n"; 
      	   $date1=&curr_system_date();
           &run_sfc_eval($evals[$ss],$subhead,$sdates,$sdatee,$maxr); 
      	   $date2=&curr_system_date();
	   if($send_mail eq 1){	&email_user($users_email,$evals[$ss],$date1,$date2);       }    
      }	
 }

#-----------------------------------------------------------
# PRECIP EVALUTATION
      ($doanal)=&parse_npa($config);
      print "Parsing the NPA Analysis Configuration:\n Perform analysis: $doanal Flags (h,d,w,m): @npa_flags\n\n";
      if($doanal eq 1){
      	   $date1=&curr_system_date();
           &npa_eval($project_id,$amet_base,$date_start,$date_end,$model);
      	   $date2=&curr_system_date();
	   if($send_mail eq 1){	&email_user($users_email,"NPA Precipitation Analysis",$date1,$date2);       }    
      }	
 
#-----------------------------------------------------------
# Spatial EVALUTATION
      ($doanal)=&parse_spatial($config);
      print "Parsing the Spatial Analysis Configuration:\n Perform analysis: $doanal Flags (h,d,w,m): @spatial_flags\n\n";
      if($doanal eq 1){
      	   $date1=&curr_system_date();
           &spatial_eval($project_id,$date_start,$date_end);
      	   $date2=&curr_system_date();
	   if($send_mail eq 1){	&email_user($users_email,"Daily Spatial Analysis",$date1,$date2);       }    
      }	
#-----------------------------------------------------------
  chdir("../");
  `rm -rf $tmprand*`;
 
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE parse_initconfig
# PURPOSE: Reads the initial or general section of the protocol configuration file and initializes				
#	   various important variables.
# INPUTS: configuration file	
# OUTPUT: query configuration arrays	
#_____________________________________________________________________________________________________
#				Change Documentaion
#   Version 1.0 Initial development, Rob Gilliam (06-05-2003)
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub parse_initconfig
{
	local($config_file) = @_;
	local($i,@dat,$l,@query_info, @line);

	open (CONF,"< $config_file");@dat=<CONF>;$l=scalar(@dat);chomp(@dat);close(CONF);
	
	for ($i=0;$i<=$l;$i++){
		
		$dat[$i]=trimwhitespace($dat[$i]);
		@line=split(/\s+/,$dat[$i]);
	        
		if( $line[0] eq "project_id")	{	$project_id	=$line[1];	}
		if( $line[0] eq "model")	{	$model		=$line[1];	}

		if( $line[0] eq "evaluations")	{	
			@evals	=split(/,/,$line[1]);
		}
		if( $line[0] eq "date_start")	{	$date_start	=$line[1];	}
		if( $line[0] eq "date_end")	{	$date_end	=$line[1];	}
		if( $line[0] eq "extra_specs")	{	
			@tmp	=split(/\"/,$dat[$i]);
			$extra	=$tmp[1];	
		}
		if( $line[0] eq "users_email")	{	$users_email	=$line[1];	}
		if( $line[0] eq "send_mail")	{	$send_mail	=$line[1];	}
		
	}
	
	print "\n\n********************************************************************\n";
	print "                                                                        \n";
	print " 		   Model Evaluation Protocal Tool			\n";
	print "                                                                        \n";
	print " 		   NOAA/EPA, Version 1.1 (Mar 26, 2005)		\n";
	print "                                                                        \n";
	print "********************************************************************\n\n\n";
	print "         Project Id: $project_id					        \n";
	print " Protocol Directory: $proto_dir		    			        \n";
	print "        Evaluations: @evals		    			        \n";
	print "********************************************************************\n\n\n";

	return($project_id,$model,$date_start,$date_end,$users_email,$send_mail);
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________

#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE parse_subconfig
# PURPOSE: Reads the surface evaluation portion of configuration file				
#	   
# INPUTS: configuration file, subsection	
# OUTPUT: query configuration arrays, dbase specs	
#_____________________________________________________________________________________________________
#				Change Documentaion
#   Version 1.0 Initial development, Rob Gilliam (06-05-2003)
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub parse_subconfig
{
	local($config_file,$subsection) = @_;
	local($i,@dat,$l,@line);

 	open (CONF,"< $config_file");@dat=<CONF>;$l=scalar(@dat);chomp(@dat);close(CONF);
	
	for ($i=0;$i<=$l;$i++){
		$dat[$i]=trimwhitespace($dat[$i]);
		@line=split(/\s+/,$dat[$i]);
		if( $line[0] eq $subsection)	{	
			$doanal	=$line[1];
			@tmp	=split(/\s+/,$dat[$i+1]);
			$subhead =$tmp[1];	
			if($subhead eq "NA"){ $subhead="";  }

			@tmp	=split(/\s+/,$dat[$i+5]);
			$maxr   =$tmp[1]*1;	

			
			if($subsection ne "seasonal" &	$subsection ne "monthly") {
				@tmp	=split(/\s+/,$dat[$i+7]);
				$sdates =$tmp[1];			
				@tmp	=split(/\s+/,$dat[$i+8]);
				$sdatee =$tmp[1];			
			}
			else {
				$sdates=$date_start;
				$sdatee=$date_end;
			}
			if($sdates eq -999){
				$sdates=$date_start;
				$sdatee=$date_end;
			}
		}
		

		
	}
	
	return($doanal,$subhead,$sdates,$sdatee,$maxr);
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE parse_npa
# PURPOSE: Reads the NPA section of the input file and extracts configuration information				
#	   
# INPUTS: Configuration file	
# OUTPUT: Users NPA configuration 	
#_____________________________________________________________________________________________________
#				Change Documentaion
#   Version 1.0 Initial development, Rob Gilliam (06-05-2003)
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub parse_npa
{
	local($config_file,$subsection) = @_;
	local($i,@dat,$l,@line,$hourly,$daily,$weekly,$monthly);

	open (CONF,"< $config_file");@dat=<CONF>;$l=scalar(@dat);chomp(@dat);close(CONF);
	
	for ($i=0;$i<=$l;$i++){
		$dat[$i]=trimwhitespace($dat[$i]);
		@line=split(/\s+/,$dat[$i]);
	        
		if( $line[0] eq "NPA_PRECIP")	{	$doanal	=$line[1];	}

		if( $line[0] eq "hourlyp")	{	
			$hourly	=$line[1];
			$hthresh=$line[2];	
		}
		if( $line[0] eq "dailyp")	{	
			$daily	=$line[1];	
			$dthresh=$line[2];	
		}
		if( $line[0] eq "weeklyp")	{	
			$weekly	=$line[1];	
			$wthresh=$line[2];
		}
		if( $line[0] eq "monthlyp")	{	
			$monthly=$line[1];	
			$mthresh=$line[2];
		}
		if( $line[0] eq "forecast")	{	
			$forecast=$line[1];	
			$init_utc=$line[2];
			$fcast1=$line[3];
			$fcast2=$line[4];
		}
		@npa_flags=($hourly,$daily,$weekly,$monthly);	
	}

	return($doanal);
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________

#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE parse_spatial
# PURPOSE: Reads the initial or general section of the protocol configuration file and initializes				
#	   various important variables.
# INPUTS: configuration file	
# OUTPUT: query configuration arrays, dbase specs	
#_____________________________________________________________________________________________________
#				Change Documentaion
#   Version 1.0 Initial development, Rob Gilliam (06-05-2003)
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub parse_spatial
{
	local($config_file) = @_;
	local($i,@dat,$l,@line,$hourly,$daily,$weekly,$monthly);
        @spatial_flags=(0,0,0,0);
	open (CONF,"< $config_file");@dat=<CONF>;$l=scalar(@dat);chomp(@dat);close(CONF);
	
	for ($i=0;$i<=$l;$i++){
		$dat[$i]=trimwhitespace($dat[$i]);
		@line=split(/\s+/,$dat[$i]);
	        
		if( $line[0] eq "DAILY_SPATIAL")	{	$doanal	=$line[1];	}

		if( $line[0] eq "hourlys")	{	
			$hourly	=$line[1];
		}
		if( $line[0] eq "dailys")	{	
			$daily	=$line[1];	
		}
		if( $line[0] eq "weeklys")	{	
			$weekly	=$line[1];	
		}
		if( $line[0] eq "monthlys")	{	
			$monthly=$line[1];	
		}
		if( $line[0] eq "checksave")	{	
			$spatial_checksave=$line[1];	
		}
		@spatial_flags=($hourly,$daily,$weekly,$monthly);	
	}

	return($doanal);
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________

#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE parse_initconfig
# PURPOSE: Reads the initial or general section of the protocol configuration file and initializes				
#	   various important variables.
# INPUTS: configuration file	
# OUTPUT: query configuration arrays, dbase specs	
#_____________________________________________________________________________________________________
#				Change Documentaion
#   Version 1.0 Initial development, Rob Gilliam (06-05-2003)
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub run_sfc_eval
{
	local($evalid,$subhead,$sdates,$sdatee,$maxr) = @_;
	local($template,@dat,$l,@line,$year);

	$template=$template_dir."/web_query.".$evalid.".input";
	$year    =substr($date_start,0,4);
        print "$template \n";
	open (CONF,"< $template");@dat=<CONF>;$l=scalar(@dat);chomp(@dat);close(CONF);
        if($l < 2) {print $template." $l\n";return();}
	for ($i=0;$i<=$l;$i++){		
		@line=split(/\s+/,trimwhitespace($dat[$i]));
		if( $line[0] eq "model")	{	
			$dat[$i]	=" model		<-\"$project_id\"   ";	}
		if( $line[0] eq "date")		{	
			$dat[$i]	=" date		<-c(\"$sdates\",\"$sdatee\")    ";	}
		if( $line[0] eq "year")		{	
			$dat[$i]	=" year		<-$year		    ";	}
		if( $line[0] eq "protocoldir")	{	
			$dat[$i]	=" protocoldir	<-paste(\"$proto_dir/\",model,sep=\"\") ";	}
		if( $line[0] eq "subid")	{	
			$dat[$i]	="subid	<-\"$subhead\" ";	}
		if( $line[0] eq "extra")	{	
			$dat[$i]	="extra	<-\"$extra\" ";	}
		if( $line[0] eq "maxrec" & $maxr > 0 )	{	
			$dat[$i]	="maxrec        <-$maxr ";	}
		
	}
	open (DAT,"> web_query.input");
	for ($i=0;$i<=$l;$i++){
		print DAT "$dat[$i]\n";
	}
	close(DAT);
	if($ENV{AMETVERBOSE} eq "yes")	{	print "$R_exe --no-save --vanilla < $amet_base/R/web_query.R \n\n";	}
	eval { system("$R_exe --no-save --vanilla < $amet_base/R/web_query.R"); };
	return();
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE npa_eval
# PURPOSE: Takes npa configuration information and controls the execution process				
#	   of the precipiation evaluation. Performs hourly, daily, weekly and monthly evaluations
# INPUTS: project identification, start and end date	
# OUTPUT: NPA evaluations plots	
#_____________________________________________________________________________________________________
#				Change Documentaion
#   Version 1.0 Initial development, Rob Gilliam (06-05-2003)
#_____________________________________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub npa_eval
{
     local($project_id,$amet_base,$date_start,$date_end,$model)=@_;
	if($npa_flags[0] eq 1){
		&calc_date_vectors("hourly",$date_start,$date_end,$project_id,$model,$hthresh);	
	}
	if($npa_flags[1] eq 1){
		&calc_date_vectors("daily",$date_start,$date_end,$project_id,$model,$dthresh);
	}
	if($npa_flags[2] eq 1){
		&calc_date_vectors("weekly",$date_start,$date_end,$project_id,$model,$wthresh);
	}
	if($npa_flags[3] eq 1){
		&calc_date_vectors("monthly",$date_start,$date_end,$project_id,$model,$mthresh);
	}
     return();
	
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________

# Remove whitespace from the start and end of the string
sub trimwhitespace($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_____________________________________________________________________________________________________
#_____________________________________________________________________________________________________
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
  local($email,$subset,$date1,$date2)=@_;
  open (MAIL, "/bin/date |");
  @dat=<MAIL>;
  $date=$dat[0];

 $body[0]="----------- Automated Model Evaluation Tool (AMET) --------------------		\n";
 $body[1]="									   		\n";
 $body[2]=" This is a progress report on the Model Evaluation Protocol request you submitted	\n";
 $body[3]="__________________________________________________________________________		\n\n";
 $body[4]="\n";
 $body[5]="The protocol subset \"$subset\" is complete.\n\n";
 $body[6]="The job began $date1 \n ended $date2\n";
 $body[7]="__________________________________________________________________________\n";
 $body[8]="\nUse the following web interface to examine the results.\nhttp://$http_server/protocol.php\n";


  %mail = (
         from => 'robert.gilliam@noaa.gov',
         to => "$email",
         subject => 'AMET Protocol Auto-emailer: Your protocol status \n\n',
         Message => "@body"

  );
  sendmail(%mail) || print "Error: $Mail::Sendmail::error\n";
  return();
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE Run NPA Precipitation Evaluation
# PURPOSE: 	Execute a R program that evaluates and plots NPA precipiation
#		comparision with a specified model
#
# INPUTS:	run identification, date start and end, and model type
#
# OUTPUT:	Comparison plots
#
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub run_npa
{
  local($date_start,$date_end,$atype,$runid,$model,$thresh)=@_;
         

        $figid="npa.$runid.$atype.$date_start";
        $template=$template_dir."/cumm_npa.input";
        print "$template  $model\n";
	open (CONF,"< $template");@dat=<CONF>;$l=scalar(@dat);chomp(@dat);close(CONF);
	if($atype eq "hourly")	{$date_end=$date_start;	}
	for ($i=0;$i<=$l;$i++){		
		@line=split(/\s+/,trimwhitespace($dat[$i]));
		if( $line[0] eq "ys")	{	$dat[$i]	=" ys		<-".substr($date_start,0,4);	}
		if( $line[0] eq "ye")	{	$dat[$i]	=" ye		<-".substr($date_end,0,4);	}
		if( $line[0] eq "ms")	{	$dat[$i]	=" ms		<-".substr($date_start,4,2);	}
		if( $line[0] eq "me")	{	$dat[$i]	=" me		<-".substr($date_end,4,2);	}
		if( $line[0] eq "ds")	{	$dat[$i]	=" ds		<-".substr($date_start,6,2);	}
		if( $line[0] eq "de")	{	$dat[$i]	=" de		<-".substr($date_end,6,2);	}
		if( $line[0] eq "hs")	{	$dat[$i]	=" hs		<-".substr($date_start,8,2);	}
		if( $line[0] eq "he")	{	$dat[$i]	=" he		<-".substr($date_end,8,2);	}

		if( $line[0] eq "fcast")	{	$dat[$i]	=" fcast		<- $forecast";	}
		if( $line[0] eq "initutc")	{	$dat[$i]	=" initutc		<- $init_utc";	}
		if( $line[0] eq "fcasthrlim")	{	$dat[$i]	=" fcasthrlim		<- c($fcast1,$fcast2)";	}

		if( $line[0] eq "runid")	{	
			$dat[$i]	=" runid		<-\"$project_id\"   ";	}

		if( $line[0] eq "figdir")	{	
			$dat[$i]	=" figdir		<-\"$proto_dir/$project_id/figures\"   ";	}

		if( $line[0] eq "threshx")		{	
			$dat[$i]	="   threshx	<-c($thresh)    ";	}
		
	}
	open (DAT,"> cumm_npa.input");
	for ($i=0;$i<=$l;$i++){
		print DAT "$dat[$i]\n";
	}
	close(DAT);
	eval { system("$R_exe --no-save --vanilla < $amet_base/R/cumm_npa.R"); };
	$tmp_figure="$proto_dir/$project_id/figures/npa-model.comp.$project_id.png";
	if(-e "$tmp_figure") { `mv $tmp_figure $proto_dir/$project_id/figures/$figid.png`;	}
	
  return();
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE Run NPA Precipitation Evaluation
# PURPOSE: 	Execute a R program that evaluates and plots NPA precipiation
#		comparision with a specified model
#
# INPUTS:	run identification, date start and end, and model type
#
# OUTPUT:	Comparison plots
#
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub spatial_eval
{
  local($runid,$date_start,$date_end)=@_;
         

        $figid="$runid.$atype.$date_start";
        $template=$template_dir."/daily_spatial.input";
	open (CONF,"< $template");@dat=<CONF>;$l=scalar(@dat);chomp(@dat);close(CONF);
	if($atype eq "hourly")	{$date_end=$date_start;	}
	for ($i=0;$i<=$l;$i++){		
		@line=split(/\s+/,trimwhitespace($dat[$i]));
		if( $line[0] eq "model")	{	
			$dat[$i]	=" model		<-\"$runid\"   ";	}
		if( $line[0] eq "figid_sub")	{	
			$dat[$i]	=" figid_sub		<-\"$atype\"   ";	}
		if( $line[0] eq "date")		{	
			$dat[$i]	=" date		<-c(\"".substr($date_start,0,10)."\",\"".substr($date_end,0,10)."\")    ";	}
		if( $line[0] eq "checksave")	{	
			$dat[$i]	=" checksave		<-$spatial_checksave   ";	}
		if( $line[0] eq "extra")	{	
			$dat[$i]	="extra	<-\"$extra\" ";	}
		
	}
	open (DAT,"> daily_spatial.input");
	for ($i=0;$i<=$l;$i++){
		print DAT "$dat[$i]\n";
	}
	close(DAT);

	eval { system("$R_exe --no-save --vanilla < $amet_base/R/daily_spatial.R"); } ;
  return();
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________

#_______________________________________________________________________________
#_______________________________________________________________________________
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
#  			SUBROUTINE calc_date_vectors
# PURPOSE: 	To give start and end date vecotrs for different classes of time 
#		periods (e.g., daily, weekly, etc.)
#
# INPUTS:	time period class (hourly, daily, weekly, monthly), start and end
#		dates of model run
# OUTPUT:	Vector of start and end times.
#
#)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
sub calc_date_vectors
{
  local($timeid,$date_start,$date_end,$proj_id,$model,$thresh)=@_;
  local($date,$i,$yr,$mo,$da,$hr,$se,$mi);

  $yr=substr($date_start,0,4);
  $mo=substr($date_start,4,2);
  $da=substr($date_start,6,2);

  $dateo=$dso;
  $date=$date_start;
  $date_end=$date_end;
  $i=0;
  while($date le $date_end){
     
     $hr=0;
     if( $timeid eq "hourly"){	($yr,$mo,$da,$hr,$mi,$se) = Add_Delta_YMDHMS($yr,$mo,$da,$hr,0,0,0,0,0,1,0,0);	 }
     if( $timeid eq "daily"){	($yr,$mo,$da,$hr,$mi,$se) = Add_Delta_YMDHMS($yr,$mo,$da,$hr,0,0,0,0,1,0,0,0);	 }
     if( $timeid eq "weekly"){	($yr,$mo,$da,$hr,$mi,$se) = Add_Delta_YMDHMS($yr,$mo,$da,$hr,0,0,0,0,7,0,0,0);	 }
     if( $timeid eq "monthly"){	($yr,$mo,$da,$hr,$mi,$se) = Add_Delta_YMDHMS($yr,$mo,$da,$hr,0,0,0,1,0,0,0,0);	 }

     $date2=sprintf('%04d',$yr).sprintf('%02d',$mo).sprintf('%02d',$da);
     &run_npa($date.sprintf('%02d',$hr),$date2.sprintf('%02d',$hr),$timeid,$proj_id,$model,$thresh);
     $date=sprintf('%04d',$yr).sprintf('%02d',$mo).sprintf('%02d',$da);
     
     $i=$i+1;	
  }
   
  return();
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
#_______________________________________________________________________________
#_______________________________________________________________________________

# Remove whitespace from the start and end of the string
sub trimwhitespace($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))


# Remove whitespace from the start and end of the string
sub curr_system_date
{
  system("date> tmp.date");
  open (FILE,"< tmp.date");@f=<FILE>;close(FILE);
  
  return($f[0]);
  
} #)))))))))))))))))))))    END SUB END SUB    )))))))))))))))))))))))))))))))))
