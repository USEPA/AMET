<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><!-- InstanceBegin template="/Templates/amet3.dwt" codeOutsideHTMLIsLocked="false" -->
<style type="text/css">
<!--
.style2 {font-size: medium}
.style3 {font-size: large}
-->
</style>

<style type="text/css">
<!--
.style3 {font-weight: bold}
.style4 {font-size: medium}
.style5 {font-size: 14px}
.style6 {
	font-size: 14px;
	font-weight: bold;
}
.style7 {font-size: 12px}
-->
</style>

<style type="text/css">
<!--
.style2 {font-size: 12px}
.style3 {font-size: 14px}
.style4 {font-size: 14}
.style5 {font-size: medium}
.style7 {font-size: x-small}
.style8 {font-size: small}
-->
</style>

<style type="text/css">
<!--
.style2 {font-style: italic}
-->
</style>

<style type="text/css">
<!--
.style2 {font-size: 12px}
.style3 {font-size: 14px}
-->
</style>

<HEAD>
<!-- #BeginEditable "doctitle" --> 
<TITLE>Atmospheric Model Evaluation Tool</TITLE>
<style type="text/css">
<!--
.style3 {color: #FF0000}
-->
</style>
<style type="text/css">
<!--
.style4 {font-size: large}
-->
</style>
<style type="text/css">
<!--
.style5 {font-size: medium}
-->
</style>
<style type="text/css">
<!--
.style7 {font-family: Arial, Helvetica, sans-serif}
-->
</style>
<style type="text/css">
<!--
.style8 {font-size: 13px}
-->
</style>
t
<style type="text/css">
<!--
.style9 {font-size: 16px}
-->
</style>
<!-- #EndEditable --> 
<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<LINK rel="stylesheet" href="general.css" type="text/css">
<style type="text/css">
<!--
@import url("generalie.css");
.style1 {font-family: Broadway, "Brush Script"}
-->
</style>
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_jumpMenu(targ,selObj,restore){ //v3.0
  eval(targ+".location='"+selObj.options[selObj.selectedIndex].value+"'");
  if (restore) selObj.selectedIndex=0;
}//-->
</script>
</HEAD>
<BODY bgcolor="#000000" text="#000000">
<TABLE width="100%" border="0" cellspacing="0" cellpadding="0">
  <TR> 
    <TD background="images/images_03.jpg" valign="TOP"> <TABLE border="0" cellspacing="0" cellpadding="0" width="647">
        <TR> 
          <TD width="594" height="53" background="images/header_02.jpg" class="companyname">&nbsp;</TD>
          <TD background="images/images_03.jpg" width="53"><IMG src="images/images_03.jpg" alt="" name="spacer" width="53" height="53" id="spacer"></TD>
        </TR>
      </TABLE></TD>
  </TR>
  <TR> 
    <TD valign="TOP"> <TABLE width="100%" border="0" cellspacing="0" cellpadding="0">
        <TR> 
          <TD valign="top" bgcolor="#FFFFFF">&nbsp; </TD>
          <TD valign="top" bgcolor="#FFFFFF"> <table width="717" border="0" cellspacing="2" cellpadding="5">
              <tr> 
                <td width="703" valign="TOP"><!-- InstanceBeginEditable name="Text" --> 
	<?php
	//	echo "POST/GET Variables: <br>";
	//	foreach ($_POST as $key => $val)
	//	echo "$key =$val<br>";
	//	echo "POST/GET Variables: <br>";
	//	foreach ($_GET as $key => $val)
	//	echo "$key =$val<br>";
	?>
				<h1 class="generic"><font face="Arial, Helvetica, sans-serif">Air Quality Analysis and Statistics Module</font></h1>
            <?php
	  /////////////////////////////////////////////// 
	 include ( '../configure/amet-www-config.php'); 
	 include ( '../configure/amet-lib.php'); 	 
	 ///////////////////////////////////////////////
//		$database_id=			$_POST['database_id'];
		$project_id=			$_POST['project_id'];
		$ametplot =        		$_POST['ametplot'];
		$data_format = 			$_POST['data_format']; 
    	        $state=				$_POST['state']; 
		$stat_id=			$_POST['stat_id']; 
		$ob_network_g=			$_POST['ob_network_g']; 
		$ob_network_s=			$_POST['ob_network_s']; 
		$ys=				$_POST['ys']; 
		$ms=				$_POST['ms']; 
		$ds=				$_POST['ds']; 
		$ye=				$_POST['ye']; 
		$me=				$_POST['me']; 
		$de=				$_POST['de']; 
		$ob_time=			$_POST['ob_time']; 
		$fcast_cond=			$_POST['fcast_cond']; 
		$fcast_hr=			$_POST['fcast_hr']; 
		$init_utc=			$_POST['init_utc']; 
		$elev_cond=			$_POST['elev_cond']; 
		$elev=				$_POST['elev'];  
		$lat1=				$_POST['lat1']; 
		$lat2=				$_POST['lat2']; 
		$lon1=				$_POST['lon1']; 
		$lon2=				$_POST['lon2']; 
		$t1=				$_POST['t1']; 
		$t2=				$_POST['t2']; 
		$ws1=				$_POST['ws1']; 
		$ws2=				$_POST['ws2']; 
		$wd1=				$_POST['wd1']; 
		$wd2=				$_POST['wd2']; 
		$q1=				$_POST['q1']; 
		$q2=				$_POST['q2']; 
		$start_hour=			$_POST['start_hour'];
		$end_hour=			$_POST['end_hour'];
		$ind_month=			$_POST['ind_month'];
                $POCode=			$_POST['POCode'];
		$custom_query=			$_POST['custom_query'];
		
		
 //:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::://
//	Query Generator Script, Executed when submit is pressed
if ($_POST['submit'] == "Run Program"){
	//$dbase="test_avgAQ";

// Set some values to NULL if no value input by user.  Must be done to avoid errors
        if (($_POST['x_axis_min']) || ($_POST['x_axis_min'] == '0')) {$x_axis_min = $_POST['x_axis_min'];}
        else { $x_axis_min = "NULL";}
        if (($_POST['x_axis_max']) || ($_POST['x_axis_max'] == '0')) {$x_axis_max = $_POST['x_axis_max'];}
        else { $x_axis_max = "NULL";}
        if (($_POST['y_axis_min']) || ($_POST['y_axis_min'] == '0')) {$y_axis_min = $_POST['y_axis_min'];}
        else { $y_axis_min = "NULL";}
        if (($_POST['y_axis_max']) || ($_POST['y_axis_max'] == '0')) {$y_axis_max = $_POST['y_axis_max'];}
        else { $y_axis_max = "NULL";}
        if (($_POST['bias_y_axis_min']) || ($_POST['bias_y_axis_min'] == '0')) {$bias_y_axis_min = $_POST['bias_y_axis_min'];}
        else { $bias_y_axis_min = "NULL";}
        if (($_POST['bias_y_axis_max']) || ($_POST['bias_y_axis_max'] == '0')) {$bias_y_axis_max = $_POST['bias_y_axis_max'];}
        else { $bias_y_axis_max = "NULL";}
        if (($_POST['density_zlim']) || ($_POST['density_zlim'] == '0')) {$density_zlim = $_POST['density_zlim'];}
        else { $density_zlim = "NULL";}
	if (($_POST['num_dens_bins']) || ($_POST['num_dens_bins'] == '0')) {$num_dens_bins = $_POST['num_dens_bins'];}
	else { $num_dens_bins = "NULL";}
	if ($_POST['num_ints']) {$num_ints = $_POST['num_ints'];}
	else { $num_ints = "NULL";}
	if ($_POST['perc_error_max']) {$perc_error_max = $_POST['perc_error_max'];}
	else { $perc_error_max = "NULL";}
	if ($_POST['abs_error_max']) {$abs_error_max = $_POST['abs_error_max'];}
	else { $abs_error_max = "NULL";}
    if (($_POST['perc_range_min']) || ($_POST['perc_range_min'] == "0")) {$perc_range_min = $_POST['perc_range_min'];}
	else { $perc_range_min = "NULL";}
	if ($_POST['perc_range_max']) {$perc_range_max = $_POST['perc_range_max'];}
	else { $perc_range_max = "NULL";}
	if (($_POST['abs_range_min']) || ($_POST['abs_range_min'] == "0")) {$abs_range_min = $_POST['abs_range_min'];}
	else { $abs_range_min = "NULL";}
	if ($_POST['abs_range_max']) {$abs_range_max = $_POST['abs_range_max'];}
	else { $abs_range_max = "NULL";}
	if (($_POST['diff_range_min']) || ($_POST['diff_range_min'] == "0")) {$diff_range_min = $_POST['diff_range_min'];}
	else { $diff_range_min = "NULL";}
	if ($_POST['diff_range_max']) {$diff_range_max = $_POST['diff_range_max'];}
	else { $diff_range_max = "NULL";}
	if ($_POST['rmse_range_max']) {$rmse_range_max = $_POST['rmse_range_max'];}
	else {$rmse_range_max = "NULL";}
        if ($_POST['symbsizfac']) {$symbsizfac = $_POST['symbsizfac'];}
        else {$symbsizfac = "1";}
	if ($_POST['gas_species']) {
	   $species_ri = "\"".$_POST['gas_species']."\"";
	   $species = $_POST['gas_species'];
	}
	elseif ($_POST['part_species']) {
	   $species_ri = "\"".$_POST['part_species']."\"";	// species name used in run_info.r file (includes parenthesis)
	   $species = $_POST['part_species'];				// species name used file names
	}
	elseif ($_POST['dep_species']) {
	   $species_ri = "\"".$_POST['dep_species']."\"";	// species name used in run_info.r file (includes parenthesis)
	   $species = $_POST['dep_species'];				// species name used file names
	}
	elseif ($_POST['tox_species']) {
	   $species_ri = "\"".$_POST['tox_species']."\"";	// species name used in run_info.r file (includes parenthesis)
	   $species = $_POST['tox_species'];				// species name used file names
	}
	else {$species_ri = "c(".$_POST['custom_species'].")";} // If regular species not set, then use custom_species
//	elseif ($_POST['tox_species']) {$species = $_POST['tox_species'];}	
//	else {$species = $_POST['custom_species'];} // If regular species not set, then use tox_species
////////////////////////////////////////////////////////////////////////////////////////

	$str=" and s.stat_id=d.stat_id";
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//::	Station Criterion, Query Strings   SELECT d.obs,d.mod from surface d, station s where ...
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	if ($state) {	// BY State	
		$str=$str." and s.state='$state'";
	}	
	else {
	   $state='All';
	}
/////////////////////////////////////////////////////////////////////////////////////////////////

//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:: Remove zero precipitation observations
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

	if ($_POST['zeroprecip'] == "n") {
		$str=$str." and d.precip_ob > 0";
	}
	if ($_POST['inc_valid'] == "y") {
		$str=$str." and d.valid_code != ' '";
	}
/////////////////////////////////////////////////////////////////////////////

//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:: Regional Planning Organization -- VISTAS, CENRAP, MANE-VU, LADCO, WRAP
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
	   if ($_POST['rpo'] == "VISTAS") {
	      $str=$str." and (s.state='AL' or s.state='FL' or s.state='GA' or s.state='KY' or s.state='MS' or s.state='NC' or s.state='SC' or s.state='TN' or s.state='VA' or s.state='WV')";
       }	
	   if ($_POST['rpo'] == "CENRAP") {
	      $str=$str." and (s.state='NE' or s.state='KS' or s.state='OK' or s.state='TX' or s.state='MN' or s.state='IA' or s.state='MO' or s.state='AR' or s.state='LA')";
	   }
	   if ($_POST['rpo'] == "MANE-VU") {
	      $str=$str." and (s.state='CT' or s.state='DE' or s.state='DC' or s.state='ME' or s.state='MD' or s.state='MA' or s.state='NH' or s.state='NJ' or s.state='NY' or s.state='PA' or s.state='RI' or s.state='VT')";
	   }
	   if ($_POST['rpo'] == "LADCO") {
	      $str=$str." and (s.state='IL' or s.state='IN' or s.state='MI' or s.state='OH' or s.state='WI')";
	   }
	   if ($_POST['rpo'] == "WRAP") {
	      $str=$str." and (s.state='AK' or s.state='CA' or s.state='OR' or s.state='WA' or s.state='AZ' or s.state='NM' or s.state='CO' or s.state='UT' or s.state='WY' or s.state='SD' or s.state='ND' or s.state='MT' or s.state='ID' or s.state='NV')";
	   }
  
//	else {
//	      $rpo="None";
//	}   
/////////////////////////////////////////////////////////////////////////////

//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:: Principal Component Analysis Regions -- Northeast, Great Lakes, Mid-Atlantic, Southwest
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	if ($_POST['pca']) {
	   if ($_POST['pca'] == "Northeast") {
	      $str=$str." and (s.state='ME' or s.state='NH' or s.state='VT' or s.state='MA' or s.state='NY' or s.state='NJ' or s.state='MD' or s.state='DE' or s.state='CT' or s.state='RI' or s.state='PA' or s.state='DC')";
       }	
	   if ($_POST['pca'] == "Great_Lakes") {
	      $str=$str." and (s.state='MI' or s.state='IL' or s.state='OH' or s.state='IN' or s.state='WI')";
              $pca = "Great Lakes";
	   }
	   if ($_POST['pca'] == "Atlantic") {
	      $str=$str." and (s.state='WV' or s.state='KY' or s.state='TN' or s.state='VA' or s.state='NC' or s.state='SC' or s.state='GA' or s.state='AL')";
	   }
	   if ($_POST['pca'] == "Southwest") {
	      $str=$str." and (s.state='LA' or s.state='MS' or s.state='MO' or s.state='TX' or s.state='OK')";
              $pca = "South";
	   }
	   if ($_POST['pca'] == "Northeast2") {
	      $str=$str." and (s.state='ME' or s.state='NH' or s.state='VT' or s.state='MA' or s.state='NY' or s.state='NJ' or s.state='MD' or s.state='DE' or s.state='CT' or s.state='RI' or s.state='PA' or s.state='DC' or s.state='VA' or s.state='WV')";
		  $pca = "Northeast";
	   }
       if ($_POST['pca'] == "Great_Lakes2") {
	      $str=$str." and (s.state='OH' or s.state='MI' or s.state='IN' or s.state='IL' or s.state='WI')";
		  $pca = "Great Lakes";
	   }
	   if ($_POST['pca'] == "Southeast") {
	      $str=$str." and (s.state='NC' or s.state='SC' or s.state='GA' or s.state='FL')";
	   }
	   if ($_POST['pca'] == "Lower_Midwest") {
	      $str=$str." and (s.state='KY' or s.state='TN' or s.state='MS' or s.state='AL' or s.state='LA' or s.state='MO' or s.state='OK' or s.state='AR')";
		  $pca = "L. Midwest";
	   }
	}   
//	else {
//	      $pca="None";
//	}   
/////////////////////////////////////////////////////////////////////////////

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:: Climate Regions -- Central, East North Central, Northeast, Northwest, South, Southwest, Southwest, West, West North Central
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        if ($_POST['clim_reg']) {
           if ($_POST['clim_reg'] == "Central") {
              $str=$str." and (s.state='IL' or s.state='IN' or s.state='KY' or s.state='MO' or s.state='OH' or s.state='TN' or s.state='WV')";
              $clim_reg = "Central";
       }
           if ($_POST['clim_reg'] == "ENCentral") {
              $str=$str." and (s.state='IA' or s.state='MI' or s.state='MN' or s.state='WI')";
              $clim_reg = "East-North Central";
           }
           if ($_POST['clim_reg'] == "Northeast") {
              $str=$str." and (s.state='CT' or s.state='DE' or s.state='ME' or s.state='MD' or s.state='MA' or s.state='NH' or s.state='NJ' or s.state='NY' or s.state='PA' or s.state='RI' or s.state='VT')";
              $clim_reg = "Northeast";
           }
           if ($_POST['clim_reg'] == "Northwest") {
              $str=$str." and (s.state='ID' or s.state='OR' or s.state='WA')";
              $clim_reg = "Northwest";
           }
           if ($_POST['clim_reg'] == "South") {
              $str=$str." and (s.state='AR' or s.state='KS' or s.state='LA' or s.state='MS' or s.state='OK' or s.state='TX')";
              $clim_reg = "South";
           }
           if ($_POST['clim_reg'] == "Southeast") {
              $str=$str." and (s.state='AL' or s.state='FL' or s.state='GA' or s.state='SC' or s.state='NC' or s.state='VA')";
              $clim_reg = "Southeast";
           }
           if ($_POST['clim_reg'] == "Southwest") {
              $str=$str." and (s.state='AZ' or s.state='CO' or s.state='NM' or s.state='UT')";
              $clim_reg = "Southwest";
           }
           if ($_POST['clim_reg'] == "West") {
              $str=$str." and (s.state='CA' or s.state='NV')";
              $clim_reg = "West";
           }
           if ($_POST['clim_reg'] == "WNCentral") {
              $str=$str." and (s.state='MT' or s.state='NE' or s.state='ND' or s.state='SD' or s.state='WY')";
              $clim_reg = "West-North Central";
           }
        }
//      else {
//            $clim_reg="None";
//      }   
/////////////////////////////////////////////////////////////////////////////

//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:: DISCOVER-AQ Regions -- 4km Baltimore, 1km Baltimore, 2km SJV
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	if ($_POST['discovaq']) {
	   if ($_POST['discovaq'] == "DISCOVERAQ_4km") {
	      $str=$str." and (d.stat_id='Appalac005' or d.stat_id='Billeri011' or d.stat_id='Brookha017' or d.stat_id='CCNY032' or d.stat_id='COVE_SE041' or d.stat_id='Dayton043' or d.stat_id='DRAGON_044' or d.stat_id='DRAGON_045' or d.stat_id='DRAGON_046' or d.stat_id='DRAGON_047' or d.stat_id='DRAGON_048' or d.stat_id='DRAGON_050' or d.stat_id='DRAGON_051' or d.stat_id='DRAGON_052' or d.stat_id='DRAGON_053' or d.stat_id='DRAGON_054' or d.stat_id='DRAGON_055' or d.stat_id='DRAGON_057' or d.stat_id='DRAGON_058' or d.stat_id='DRAGON_059' or d.stat_id='DRAGON_061' or d.stat_id='DRAGON_063' or d.stat_id='DRAGON_065' or d.stat_id='DRAGON_068' or d.stat_id='DRAGON_069' or d.stat_id='DRAGON_070' or d.stat_id='DRAGON_071' or d.stat_id='DRAGON_072' or d.stat_id='DRAGON_073' or d.stat_id='DRAGON_074' or d.stat_id='DRAGON_078' or d.stat_id='DRAGON_080' or d.stat_id='DRAGON_082' or d.stat_id='DRAGON_083' or d.stat_id='DRAGON_084' or d.stat_id='DRAGON_086' or d.stat_id='DRAGON_087' or d.stat_id='DRAGON_088' or d.stat_id='DRAGON_090' or d.stat_id='DRAGON_093' or d.stat_id='DRAGON_096' or d.stat_id='DRAGON_097' or d.stat_id='DRAGON_098' or d.stat_id='DRAGON_099' or d.stat_id='Easton_101' or d.stat_id='Egbert102' or d.stat_id='Georgia115' or d.stat_id='GSFC118' or d.stat_id='Harvard122' or d.stat_id='LISCO140' or d.stat_id='SERC187' or d.stat_id='Toronto207' or d.stat_id='UMBC215' or d.stat_id='Wallops223' or d.stat_id='090010017' or d.stat_id='090011123' or d.stat_id='090013007' or d.stat_id='090019003' or d.stat_id='090031003' or d.stat_id='090050005' or d.stat_id='090070007' or d.stat_id='090090027' or d.stat_id='090093002' or d.stat_id='090110124' or d.stat_id='090131001' or d.stat_id='100010002' or d.stat_id='100031007' or d.stat_id='100031010' or d.stat_id='100031013' or d.stat_id='100032004' or d.stat_id='100051002' or d.stat_id='100051003' or d.stat_id='110010041' or d.stat_id='110010043' or d.stat_id='130550001' or d.stat_id='130590002' or d.stat_id='130670003' or d.stat_id='130730001' or d.stat_id='130850001' or d.stat_id='130890002' or d.stat_id='130970004' or d.stat_id='131210055' or d.stat_id='131350002' or d.stat_id='132130003' or d.stat_id='132230003' or d.stat_id='132450091' or d.stat_id='132470001' or d.stat_id='210130002' or d.stat_id='210131002' or d.stat_id='210190017' or d.stat_id='210373002' or d.stat_id='210430500' or d.stat_id='210670012' or d.stat_id='210890007' or d.stat_id='211130001' or d.stat_id='211930003' or d.stat_id='211950002' or d.stat_id='211990003' or d.stat_id='240030014' or d.stat_id='240051007' or d.stat_id='240053001' or d.stat_id='240090011' or d.stat_id='240130001' or d.stat_id='240150003' or d.stat_id='240170010' or d.stat_id='240210037' or d.stat_id='240230002' or d.stat_id='240251001' or d.stat_id='240259001' or d.stat_id='240290002' or d.stat_id='240313001' or d.stat_id='240330030' or d.stat_id='240338003' or d.stat_id='240430009' or d.stat_id='245100054' or d.stat_id='250010002' or d.stat_id='250034002' or d.stat_id='250051002' or d.stat_id='250070001' or d.stat_id='250092006' or d.stat_id='250095005' or d.stat_id='250130008' or d.stat_id='250150103' or d.stat_id='250154002' or d.stat_id='250170009' or d.stat_id='250171102' or d.stat_id='250213003' or d.stat_id='250250041' or d.stat_id='250250042' or d.stat_id='250270015' or d.stat_id='250270024' or d.stat_id='260490021' or d.stat_id='260492001' or d.stat_id='260630007' or d.stat_id='260910007' or d.stat_id='260990009' or d.stat_id='260991003' or d.stat_id='261250001' or d.stat_id='261470005' or d.stat_id='261610008' or d.stat_id='261630001' or d.stat_id='261630019' or d.stat_id='330050007' or d.stat_id='330111011' or d.stat_id='330115001' or d.stat_id='340010006' or d.stat_id='340030006' or d.stat_id='340071001' or d.stat_id='340110007' or d.stat_id='340130003' or d.stat_id='340150002' or d.stat_id='340170006' or d.stat_id='340190001' or d.stat_id='340210005' or d.stat_id='340230011' or d.stat_id='340250005' or d.stat_id='340273001' or d.stat_id='340290006' or d.stat_id='340315001' or d.stat_id='360010012' or d.stat_id='360050133' or d.stat_id='360130006' or d.stat_id='360130011' or d.stat_id='360150003' or d.stat_id='360270007' or d.stat_id='360290002' or d.stat_id='360410005' or d.stat_id='360430005' or d.stat_id='360530006' or d.stat_id='360551007' or d.stat_id='360610135' or d.stat_id='360631006' or d.stat_id='360650004' or d.stat_id='360671015' or d.stat_id='360715001' or d.stat_id='360750003' or d.stat_id='360790005' or d.stat_id='360810124' or d.stat_id='360830004' or d.stat_id='360850067' or d.stat_id='360870005' or d.stat_id='360910004' or d.stat_id='361010003' or d.stat_id='361030002' or d.stat_id='361030004' or d.stat_id='361030009' or d.stat_id='361111005' or d.stat_id='361173001' or d.stat_id='361192004' or d.stat_id='370030004' or d.stat_id='370110002' or d.stat_id='370210030' or d.stat_id='370270003' or d.stat_id='370330001' or d.stat_id='370370004' or d.stat_id='370510008' or d.stat_id='370511003' or d.stat_id='370590003' or d.stat_id='370630015' or d.stat_id='370650099' or d.stat_id='370670022' or d.stat_id='370670028' or d.stat_id='370670030' or d.stat_id='370671008' or d.stat_id='370690001' or d.stat_id='370750001' or d.stat_id='370770001' or d.stat_id='370810013' or d.stat_id='370870035' or d.stat_id='370870036' or d.stat_id='370990005' or d.stat_id='371010002' or d.stat_id='371070004' or d.stat_id='371090004' or d.stat_id='371170001' or d.stat_id='371190041' or d.stat_id='371191005' or d.stat_id='371191009' or d.stat_id='371290002' or d.stat_id='371450003' or d.stat_id='371470006' or d.stat_id='371570099' or d.stat_id='371590021' or d.stat_id='371590022' or d.stat_id='371730002' or d.stat_id='371790003' or d.stat_id='371830014' or d.stat_id='371830016' or d.stat_id='371990004' or d.stat_id='390030009' or d.stat_id='390071001' or d.stat_id='390090004' or d.stat_id='390170004' or d.stat_id='390170018' or d.stat_id='390230001' or d.stat_id='390230003' or d.stat_id='390250022' or d.stat_id='390271002' or d.stat_id='390350034' or d.stat_id='390350060' or d.stat_id='390350064' or d.stat_id='390355002' or d.stat_id='390410002' or d.stat_id='390490029' or d.stat_id='390490037' or d.stat_id='390490081' or d.stat_id='390550004' or d.stat_id='390570006' or d.stat_id='390610006' or d.stat_id='390610040' or d.stat_id='390810017' or d.stat_id='390830002' or d.stat_id='390850003' or d.stat_id='390850007' or d.stat_id='390870011' or d.stat_id='390870012' or d.stat_id='390890005' or d.stat_id='390930018' or d.stat_id='390950024' or d.stat_id='390950027' or d.stat_id='390950034' or d.stat_id='390970007' or d.stat_id='390990013' or d.stat_id='391030004' or d.stat_id='391090005' or d.stat_id='391130037' or d.stat_id='391331001' or d.stat_id='391510016' or d.stat_id='391510022' or d.stat_id='391514005' or d.stat_id='391530020' or d.stat_id='391550009' or d.stat_id='391550011' or d.stat_id='391650007' or d.stat_id='391670004' or d.stat_id='391730003' or d.stat_id='420010002' or d.stat_id='420030008' or d.stat_id='420030010' or d.stat_id='420030067' or d.stat_id='420031005' or d.stat_id='420050001' or d.stat_id='420070002' or d.stat_id='420070005' or d.stat_id='420070014' or d.stat_id='420110006' or d.stat_id='420110011' or d.stat_id='420130801' or d.stat_id='420170012' or d.stat_id='420210011' or d.stat_id='420270100' or d.stat_id='420290100' or d.stat_id='420334000' or d.stat_id='420430401' or d.stat_id='420431100' or d.stat_id='420450002' or d.stat_id='420490003' or d.stat_id='420550001' or d.stat_id='420590002' or d.stat_id='420630004' or d.stat_id='420690101' or d.stat_id='420692006' or d.stat_id='420710007' or d.stat_id='420710012' or d.stat_id='420730015' or d.stat_id='420770004' or d.stat_id='420791100' or d.stat_id='420791101' or d.stat_id='420810100' or d.stat_id='420850100' or d.stat_id='420890002' or d.stat_id='420910013' or d.stat_id='420950025' or d.stat_id='420958000' or d.stat_id='420990301' or d.stat_id='421010004' or d.stat_id='421010024' or d.stat_id='421174000' or d.stat_id='421250005' or d.stat_id='421250200' or d.stat_id='421255001' or d.stat_id='421290006' or d.stat_id='421290008' or d.stat_id='421330008' or d.stat_id='421330011' or d.stat_id='440030002' or d.stat_id='440071010' or d.stat_id='440090007' or d.stat_id='450010001' or d.stat_id='450030003' or d.stat_id='450070005' or d.stat_id='450150002' or d.stat_id='450190046' or d.stat_id='450210002' or d.stat_id='450250001' or d.stat_id='450310003' or d.stat_id='450370001' or d.stat_id='450450016' or d.stat_id='450451003' or d.stat_id='450730001' or d.stat_id='450770002' or d.stat_id='450790007' or d.stat_id='450790021' or d.stat_id='450791001' or d.stat_id='450830009' or d.stat_id='450910006' or d.stat_id='470010101' or d.stat_id='470090101' or d.stat_id='470090102' or d.stat_id='470651011' or d.stat_id='470654003' or d.stat_id='470890002' or d.stat_id='470930021' or d.stat_id='470931020' or d.stat_id='471050109' or d.stat_id='471210104' or d.stat_id='471550101' or d.stat_id='471550102' or d.stat_id='471632002' or d.stat_id='471632003' or d.stat_id='500030004' or d.stat_id='510030001' or d.stat_id='510130020' or d.stat_id='510330001' or d.stat_id='510360002' or d.stat_id='510410004' or d.stat_id='510590030' or d.stat_id='510610002' or d.stat_id='510690010' or d.stat_id='510850003' or d.stat_id='510870014' or d.stat_id='511071005' or d.stat_id='511130003' or d.stat_id='511390004' or d.stat_id='511530009' or d.stat_id='511611004' or d.stat_id='511630003' or d.stat_id='511650003' or d.stat_id='511790001' or d.stat_id='511970002' or d.stat_id='515100009' or d.stat_id='518000004' or d.stat_id='518000005' or d.stat_id='540030003' or d.stat_id='540110006' or d.stat_id='540250003' or d.stat_id='540291004' or d.stat_id='540390010' or d.stat_id='540610003' or d.stat_id='540690010' or d.stat_id='541071002' or d.stat_id='090010010' or d.stat_id='090013005' or d.stat_id='090032006' or d.stat_id='090091123' or d.stat_id='090092123' or d.stat_id='090113002' or d.stat_id='100010003' or d.stat_id='100031003' or d.stat_id='100031012' or d.stat_id='110010042' or d.stat_id='130630091' or d.stat_id='130670004' or d.stat_id='130892001' or d.stat_id='131150003' or d.stat_id='131210032' or d.stat_id='131210039' or d.stat_id='131390003' or d.stat_id='132450005' or d.stat_id='132950002' or d.stat_id='210190002' or d.stat_id='210670014' or d.stat_id='211510003' or d.stat_id='240031003' or d.stat_id='240330025' or d.stat_id='245100006' or d.stat_id='245100007' or d.stat_id='245100008' or d.stat_id='245100040' or d.stat_id='250035001' or d.stat_id='250051004' or d.stat_id='250096001' or d.stat_id='250130016' or d.stat_id='250132009' or d.stat_id='250230004' or d.stat_id='250250002' or d.stat_id='250250027' or d.stat_id='250250043' or d.stat_id='250270016' or d.stat_id='250270023' or d.stat_id='261150005' or d.stat_id='261630005' or d.stat_id='261630015' or d.stat_id='261630016' or d.stat_id='261630025' or d.stat_id='261630033' or d.stat_id='261630036' or d.stat_id='261630038' or d.stat_id='261630039' or d.stat_id='330111015' or d.stat_id='330150018' or d.stat_id='340011006' or d.stat_id='340030003' or d.stat_id='340070009' or d.stat_id='340071007' or d.stat_id='340150004' or d.stat_id='340171003' or d.stat_id='340172002' or d.stat_id='340210008' or d.stat_id='340218001' or d.stat_id='340230006' or d.stat_id='340270004' or d.stat_id='340292002' or d.stat_id='340310005' or d.stat_id='340390004' or d.stat_id='340390006' or d.stat_id='340392003' or d.stat_id='340410006' or d.stat_id='340410007' or d.stat_id='360010005' or d.stat_id='360050080' or d.stat_id='360290005' or d.stat_id='360470122' or d.stat_id='360590008' or d.stat_id='360610079' or d.stat_id='360610128' or d.stat_id='360610134' or d.stat_id='360632008' or d.stat_id='360710002' or d.stat_id='360850055' or d.stat_id='361191002' or d.stat_id='370010002' or d.stat_id='370210034' or d.stat_id='370350004' or d.stat_id='370510009' or d.stat_id='370570002' or d.stat_id='370610002' or d.stat_id='370650004' or d.stat_id='370710016' or d.stat_id='370810014' or d.stat_id='370870012' or d.stat_id='370990006' or d.stat_id='371110004' or d.stat_id='371190003' or d.stat_id='371190042' or d.stat_id='371190043' or d.stat_id='371210001' or d.stat_id='371230001' or d.stat_id='371550005' or d.stat_id='371830020' or d.stat_id='371890003' or d.stat_id='371910005' or d.stat_id='390090003' or d.stat_id='390170003' or d.stat_id='390170015' or d.stat_id='390170016' or d.stat_id='390230005' or d.stat_id='390290020' or d.stat_id='390290022' or d.stat_id='390350038' or d.stat_id='390350045' or d.stat_id='390350065' or d.stat_id='390351002' or d.stat_id='390490024' or d.stat_id='390490025' or d.stat_id='390570005' or d.stat_id='390610014' or d.stat_id='390610042' or d.stat_id='390615001' or d.stat_id='390810001' or d.stat_id='390811001' or d.stat_id='390851001' or d.stat_id='390933002' or d.stat_id='390950026' or d.stat_id='390950028' or d.stat_id='390990005' or d.stat_id='390990006' or d.stat_id='390990014' or d.stat_id='391130032' or d.stat_id='391137001' or d.stat_id='391330002' or d.stat_id='391450013' or d.stat_id='391450019' or d.stat_id='391510017' or d.stat_id='391510020' or d.stat_id='391530017' or d.stat_id='391530023' or d.stat_id='391550005' or d.stat_id='391550006' or d.stat_id='420030002' or d.stat_id='420030064' or d.stat_id='420030092' or d.stat_id='420030093' or d.stat_id='420031008' or d.stat_id='420031301' or d.stat_id='420033007' or d.stat_id='420410101' or d.stat_id='420950027' or d.stat_id='421010047' or d.stat_id='421010055' or d.stat_id='421010057' or d.stat_id='421010449' or d.stat_id='421010649' or d.stat_id='421011002' or d.stat_id='440070022' or d.stat_id='440070026' or d.stat_id='440070027' or d.stat_id='440070028' or d.stat_id='450190048' or d.stat_id='450410003' or d.stat_id='450450009' or d.stat_id='450450015' or d.stat_id='450630008' or d.stat_id='450790019' or d.stat_id='470090011' or d.stat_id='470110103' or d.stat_id='470111002' or d.stat_id='470650006' or d.stat_id='470650031' or d.stat_id='470654002' or d.stat_id='470930028' or d.stat_id='470931013' or d.stat_id='470931017' or d.stat_id='471050108' or d.stat_id='471070101' or d.stat_id='471071002' or d.stat_id='471450004' or d.stat_id='471450103' or d.stat_id='471451001' or d.stat_id='471631007' or d.stat_id='471730105' or d.stat_id='510350001' or d.stat_id='510410003' or d.stat_id='510470002' or d.stat_id='510870015' or d.stat_id='511010003' or d.stat_id='511870004' or d.stat_id='515100020' or d.stat_id='515200006' or d.stat_id='516300004' or d.stat_id='516500008' or d.stat_id='516700010' or d.stat_id='516800015' or d.stat_id='517100024' or d.stat_id='517700011' or d.stat_id='517700015' or d.stat_id='517750011' or d.stat_id='518100008' or d.stat_id='518400002' or d.stat_id='540090005' or d.stat_id='540391005' or d.stat_id='540490006' or d.stat_id='540511002' or d.stat_id='540810002' or d.stat_id='090010012' or d.stat_id='100031008' or d.stat_id='110010023' or d.stat_id='131210048' or d.stat_id='250094005' or d.stat_id='250250040' or d.stat_id='330110020' or d.stat_id='340131003' or d.stat_id='340171002' or d.stat_id='340390003' or d.stat_id='360050112' or d.stat_id='360050113' or d.stat_id='360291013' or d.stat_id='360291014' or d.stat_id='360470052' or d.stat_id='360470118' or d.stat_id='360470121' or d.stat_id='360590005' or d.stat_id='360652001' or d.stat_id='360670017' or d.stat_id='360810120' or d.stat_id='360850111' or d.stat_id='370130151' or d.stat_id='370670023' or d.stat_id='371290006' or d.stat_id='390010001' or d.stat_id='390133002' or d.stat_id='390350051' or d.stat_id='390350053' or d.stat_id='390490005' or d.stat_id='390490034' or d.stat_id='390610021' or d.stat_id='390810018' or d.stat_id='390810020' or d.stat_id='390850006' or d.stat_id='390951003' or d.stat_id='391051001' or d.stat_id='391130028' or d.stat_id='391130034' or d.stat_id='391150004' or d.stat_id='391450020' or d.stat_id='391450021' or d.stat_id='391450022' or d.stat_id='391530022' or d.stat_id='391570006' or d.stat_id='420010001' or d.stat_id='420030003' or d.stat_id='420030031' or d.stat_id='420030038' or d.stat_id='420033006' or d.stat_id='420037004' or d.stat_id='420951000' or d.stat_id='421230004' or d.stat_id='440070012' or d.stat_id='450430011' or d.stat_id='450430012' or d.stat_id='450630009' or d.stat_id='450630010' or d.stat_id='450770003' or d.stat_id='470110102' or d.stat_id='471450104' or d.stat_id='471453009' or d.stat_id='471630007' or d.stat_id='471730107' or d.stat_id='517600024' or d.stat_id='540090007' or d.stat_id='540090011' or d.stat_id='540290005' or d.stat_id='540290007' or d.stat_id='540290008' or d.stat_id='540290009' or d.stat_id='540290015' or d.stat_id='540990004' or d.stat_id='540990005' or d.stat_id='ABT147' or d.stat_id='ANA115' or d.stat_id='ARE128' or d.stat_id='BEL116' or d.stat_id='BFT142' or d.stat_id='BWR139' or d.stat_id='CAT175' or d.stat_id='CDR119' or d.stat_id='CKT136' or d.stat_id='CND125' or d.stat_id='COW137' or d.stat_id='CTH110' or d.stat_id='DCP114' or d.stat_id='EGB181' or d.stat_id='GRS420' or d.stat_id='KEF112' or d.stat_id='LRL117' or d.stat_id='MKG113' or d.stat_id='PAR107' or d.stat_id='PED108' or d.stat_id='PNF126' or d.stat_id='PSU106' or d.stat_id='QAK172' or d.stat_id='SHN418' or d.stat_id='SPD111' or d.stat_id='UVL124' or d.stat_id='VPI120' or d.stat_id='WSP144' or d.stat_id='130590001' or d.stat_id='540390011' or d.stat_id='BRIG1' or d.stat_id='CACO1' or d.stat_id='COHU1' or d.stat_id='DOSO1' or d.stat_id='EGBE1' or d.stat_id='FRRE1' or d.stat_id='GRSM1' or d.stat_id='JARI1' or d.stat_id='LIGO1' or d.stat_id='LYBR1' or d.stat_id='MAVI1' or d.stat_id='MOMO1' or d.stat_id='PACK1' or d.stat_id='QUCI1' or d.stat_id='QURE1' or d.stat_id='ROMA1' or d.stat_id='SHEN1' or d.stat_id='SHRO1' or d.stat_id='SWAN1' or d.stat_id='WASH1' or d.stat_id='CT15' or d.stat_id='KY22' or d.stat_id='KY35' or d.stat_id='MA01' or d.stat_id='MA08' or d.stat_id='MD07' or d.stat_id='MD08' or d.stat_id='MD13' or d.stat_id='MD15' or d.stat_id='MD18' or d.stat_id='MD99' or d.stat_id='MI51' or d.stat_id='MI52' or d.stat_id='NC03' or d.stat_id='NC06' or d.stat_id='NC25' or d.stat_id='NC29' or d.stat_id='NC34' or d.stat_id='NC35' or d.stat_id='NC36' or d.stat_id='NC41' or d.stat_id='NC45' or d.stat_id='NJ00' or d.stat_id='NJ99' or d.stat_id='NY01' or d.stat_id='NY08' or d.stat_id='NY10' or d.stat_id='NY52' or d.stat_id='NY68' or d.stat_id='NY96' or d.stat_id='NY99' or d.stat_id='OH17' or d.stat_id='OH49' or d.stat_id='OH54' or d.stat_id='OH71' or d.stat_id='PA00' or d.stat_id='PA15' or d.stat_id='PA18' or d.stat_id='PA29' or d.stat_id='PA42' or d.stat_id='PA47' or d.stat_id='PA72' or d.stat_id='SC05' or d.stat_id='SC06' or d.stat_id='TN00' or d.stat_id='TN04' or d.stat_id='TN11' or d.stat_id='VA00' or d.stat_id='VA13' or d.stat_id='VA24' or d.stat_id='VA28' or d.stat_id='VA98' or d.stat_id='VA99' or d.stat_id='VT01' or d.stat_id='WV04' or d.stat_id='WV05' or d.stat_id='WV18')  ";
		  $discovaq = "4-km Window";
       }	
       if ($_POST['discovaq'] == "DISCOVERAQ_1km") {
              $str=$str." and (d.stat_id='DRAGON_164' or d.stat_id='DRAGON_165' or d.stat_id='DRAGON_167'or d.stat_id='DRAGON_168' or d.stat_id='DRAGON_169' or d.stat_id='DRAGON_171' or d.stat_id='DRAGON_172' or d.stat_id='DRAGON_173' or d.stat_id='DRAGON_174' or d.stat_id='DRAGON_175' or d.stat_id='DRAGON_176' or d.stat_id='DRAGON_178' or d.stat_id='DRAGON_180' or d.stat_id='DRAGON_181' or d.stat_id='DRAGON_183' or d.stat_id='DRAGON_185' or d.stat_id='DRAGON_187' or d.stat_id='DRAGON_190' or d.stat_id='DRAGON_191' or d.stat_id='DRAGON_192' or d.stat_id='DRAGON_193' or d.stat_id='DRAGON_194' or d.stat_id='DRAGON_195' or d.stat_id='DRAGON_196' or d.stat_id='DRAGON_207' or d.stat_id='DRAGON_216' or d.stat_id='DRAGON_219' or d.stat_id='DRAGON_224' or d.stat_id='DRAGON_225' or d.stat_id='DRAGON_230' or d.stat_id='DRAGON_231' or d.stat_id='DRAGON_234' or d.stat_id='DRAGON_237' or d.stat_id='DRAGON_243' or d.stat_id='DRAGON_250' or d.stat_id='DRAGON_252' or d.stat_id='DRAGON_253' or d.stat_id='Easton_260' or d.stat_id='GSFC303' or d.stat_id='SERC592' or d.stat_id='UMBC680' or d.stat_id='Wallops696' or d.stat_id='100010002' or d.stat_id='100010003' or d.stat_id='100031003' or d.stat_id='100031007' or d.stat_id='100031008' or d.stat_id='100031012' or d.stat_id='100032004' or d.stat_id='100051002' or d.stat_id='110010041' or d.stat_id='110010042' or d.stat_id='110010043' or d.stat_id='240031003' or d.stat_id='240051007' or d.stat_id='240053001' or d.stat_id='240150003' or d.stat_id='240251001' or d.stat_id='240290002' or d.stat_id='240313001' or d.stat_id='240330025' or d.stat_id='240330030' or d.stat_id='240338003' or d.stat_id='240430009' or d.stat_id='245100006' or d.stat_id='245100007' or d.stat_id='245100008' or d.stat_id='245100040' or d.stat_id='340070009' or d.stat_id='340071007' or d.stat_id='340110007' or d.stat_id='340150004' or d.stat_id='420010001' or d.stat_id='420290100' or d.stat_id='420410101' or d.stat_id='420430401' or d.stat_id='420450002' or d.stat_id='420710007' or d.stat_id='420750100' or d.stat_id='420910013' or d.stat_id='421010004' or d.stat_id='421010014' or d.stat_id='421010047' or d.stat_id='421010055' or d.stat_id='421010057' or d.stat_id='421010063' or d.stat_id='421010449' or d.stat_id='421010649' or d.stat_id='421011002' or d.stat_id='421330008' or d.stat_id='510030001' or d.stat_id='510130020' or d.stat_id='510330001' or d.stat_id='510470002' or d.stat_id='510590030' or d.stat_id='510690010' or d.stat_id='510870014' or d.stat_id='510870015' or d.stat_id='511010003' or d.stat_id='511071005' or d.stat_id='511130003' or d.stat_id='511870004' or d.stat_id='515100009' or d.stat_id='515100020' or d.stat_id='516300004' or d.stat_id='518400002' or d.stat_id='540030003' or d.stat_id='100031010' or d.stat_id='100031013' or d.stat_id='100051003' or d.stat_id='240030014' or d.stat_id='240090011' or d.stat_id='240130001' or d.stat_id='240170010' or d.stat_id='240199991' or d.stat_id='240210037' or d.stat_id='240259001' or d.stat_id='240339991' or d.stat_id='245100054' or d.stat_id='340071001' or d.stat_id='340150002' or d.stat_id='420010002' or d.stat_id='420019991' or d.stat_id='420431100' or d.stat_id='420550001' or d.stat_id='420710012' or d.stat_id='420990301' or d.stat_id='421010024' or d.stat_id='421330011' or d.stat_id='510610002' or d.stat_id='510850003' or d.stat_id='511530009' or d.stat_id='511790001' or d.stat_id='110010023' or d.stat_id='517600024' or d.stat_id='ARE128' or d.stat_id='BEL116' or d.stat_id='BWR139' or d.stat_id='SHN418' or d.stat_id='SHEN1' or d.stat_id='WASH1' or d.stat_id='MD07' or d.stat_id='MD13' or d.stat_id='MD15' or d.stat_id='MD18' or d.stat_id='MD99' or d.stat_id='PA00' or d.stat_id='PA47' or d.stat_id='VA00' or d.stat_id='VA28' or d.stat_id='VA98' ) ";
              $discovaq = "1-km Window";
	   }
	}  
        if ($_POST['discovaq'] == "DISCOVERAQ_2km_SJV") {
           $str=$str." and (d.stat_id = '060010007' or d.stat_id = '060010009' or d.stat_id = '060010011' or d.stat_id = '060050002' or d.stat_id = '060070007' or d.stat_id = '060070008' or d.stat_id = '060090001' or d.stat_id = '060111002' or d.stat_id = '060130002' or d.stat_id = '060131002' or d.stat_id = '060131004' or d.stat_id = '060170010' or d.stat_id = '060190007' or d.stat_id = '060190011' or d.stat_id = '060190242' or d.stat_id = '060192009' or d.stat_id = '060194001' or d.stat_id = '060195001' or d.stat_id = '060210003' or d.stat_id = '060290007' or d.stat_id = '060290008' or d.stat_id = '060290011' or d.stat_id = '060290014' or d.stat_id = '060290232' or d.stat_id = '060292012' or d.stat_id = '060295002' or d.stat_id = '060296001' or d.stat_id = '060310500' or d.stat_id = '060311004' or d.stat_id = '060333001' or d.stat_id = '060370002' or d.stat_id = '060370016' or d.stat_id = '060370113' or d.stat_id = '060371002' or d.stat_id = '060371103' or d.stat_id = '060371201' or d.stat_id = '060371302' or d.stat_id = '060371602' or d.stat_id = '060371701' or d.stat_id = '060374002' or d.stat_id = '060374006' or d.stat_id = '060375005' or d.stat_id = '060376012' or d.stat_id = '060379033' or d.stat_id = '060390004' or d.stat_id = '060390500' or d.stat_id = '060392010' or d.stat_id = '060410001' or d.stat_id = '060430003' or d.stat_id = '060470003' or d.stat_id = '060530002' or d.stat_id = '060530008' or d.stat_id = '060531003' or d.stat_id = '060550003' or d.stat_id = '060570005' or d.stat_id = '060590007' or d.stat_id = '060591003' or d.stat_id = '060592022' or d.stat_id = '060595001' or d.stat_id = '060610003' or d.stat_id = '060610004' or d.stat_id = '060610006' or d.stat_id = '060612002' or d.stat_id = '060658001' or d.stat_id = '060658005' or d.stat_id = '060659001' or d.stat_id = '060670002' or d.stat_id = '060670006' or d.stat_id = '060670010' or d.stat_id = '060670011' or d.stat_id = '060670012' or d.stat_id = '060670014' or d.stat_id = '060675003' or d.stat_id = '060690002' or d.stat_id = '060690003' or d.stat_id = '060710012' or d.stat_id = '060711004' or d.stat_id = '060712002' or d.stat_id = '060750005' or d.stat_id = '060771002' or d.stat_id = '060773005' or d.stat_id = '060790005' or d.stat_id = '060792006' or d.stat_id = '060793001' or d.stat_id = '060794002' or d.stat_id = '060798001' or d.stat_id = '060798005' or d.stat_id = '060798006' or d.stat_id = '060811001' or d.stat_id = '060830008' or d.stat_id = '060830011' or d.stat_id = '060831008' or d.stat_id = '060831013' or d.stat_id = '060831014' or d.stat_id = '060831018' or d.stat_id = '060831021' or d.stat_id = '060831025' or d.stat_id = '060832004' or d.stat_id = '060832011' or d.stat_id = '060833001' or d.stat_id = '060834003' or d.stat_id = '060850005' or d.stat_id = '060852009' or d.stat_id = '060870007' or d.stat_id = '060871003' or d.stat_id = '060890004' or d.stat_id = '060890007' or d.stat_id = '060890009' or d.stat_id = '060893003' or d.stat_id = '060950004' or d.stat_id = '060953003' or d.stat_id = '060970003' or d.stat_id = '060971003' or d.stat_id = '060990005' or d.stat_id = '060990006' or d.stat_id = '061010003' or d.stat_id = '061030005' or d.stat_id = '061070006' or d.stat_id = '061070009' or d.stat_id = '061072002' or d.stat_id = '061072010' or d.stat_id = '061090005' or d.stat_id = '061110007' or d.stat_id = '061110009' or d.stat_id = '061111004' or d.stat_id = '061112002' or d.stat_id = '061113001' or d.stat_id = '061130004' or d.stat_id = '061131003' or d.stat_id = '320310016' or d.stat_id = '320310020' or d.stat_id = '320310025' or d.stat_id = '320311005' or d.stat_id = '320312002' or d.stat_id = '320312009' or d.stat_id = '060130006' or d.stat_id = '060131001' or d.stat_id = '060132001' or d.stat_id = '060195025' or d.stat_id = '060290016' or d.stat_id = '060290017' or d.stat_id = '060310004' or d.stat_id = '060374004' or d.stat_id = '060410004' or d.stat_id = '060431001' or d.stat_id = '060472510' or d.stat_id = '060510001' or d.stat_id = '060510005' or d.stat_id = '060510011' or d.stat_id = '060571001' or d.stat_id = '060610002' or d.stat_id = '060631006' or d.stat_id = '060631009' or d.stat_id = '060650003' or d.stat_id = '060651003' or d.stat_id = '060670284' or d.stat_id = '060674001' or d.stat_id = '060710025' or d.stat_id = '060773010' or d.stat_id = '060890008' or d.stat_id = '060953001' or d.stat_id = '060970001' or d.stat_id = '060970002' or d.stat_id = '060973002' or d.stat_id = '061030002' or d.stat_id = '061050002' or d.stat_id = '061132001' or d.stat_id = '060012005' or d.stat_id = '060072002' or d.stat_id = '060074001' or d.stat_id = '060110007' or d.stat_id = '060132007' or d.stat_id = '060170011' or d.stat_id = '060192008' or d.stat_id = '060271023' or d.stat_id = '060271028' or d.stat_id = '060292009' or d.stat_id = '060333010' or d.stat_id = '060333011' or d.stat_id = '060333012' or d.stat_id = '060410003' or d.stat_id = '060631007' or d.stat_id = '060670007' or d.stat_id = '060772010' or d.stat_id = '060792004' or d.stat_id = '060792007' or d.stat_id = '060831020' or d.stat_id = '060831022' or d.stat_id = '060831033' or d.stat_id = '060831037' or d.stat_id = '060850002' or d.stat_id = '061030006'or d.stat_id = '061073000' or d.stat_id = '061110008' or d.stat_id = '320310022' or d.stat_id = '320310030' or d.stat_id = '320311026' or d.stat_id = '320312010' or d.stat_id = 'LAV410' or d.stat_id = 'PIN414' or d.stat_id = 'SEK430' or d.stat_id = 'YOS204' or d.stat_id = 'YOS404' or d.stat_id = 'BLIS1' or d.stat_id = 'DOME1' or d.stat_id = 'FRES1' or d.stat_id = 'HOOV1' or d.stat_id = 'KAIS1' or d.stat_id = 'LAVO1' or d.stat_id = 'PINN1' or d.stat_id = 'PORE1' or d.stat_id = 'RAFA1' or d.stat_id = 'SAGA1' or d.stat_id = 'SEQU1' or d.stat_id = 'TRIN1' or d.stat_id = 'YOSE1' ) ";
              $discoveraq = "2-km Window";
        }
//	else {
//	      $pca="None";
//	}   
/////////////////////////////////////////////////////////////////////////////

//  if ($stat_id) {
//		$str=$str." and d.stat_id='$stat_id'";
//}
//	else {
//		$stat_id="All";
//	}
    
	if ($stat_id) {
		$stat_id_str=" ";
		echo "$stat_id_file";
		
		if (($stat_id == "Selected_Sites") || ($stat_id == "Load_File")){
			if ($stat_id == "Selected_Sites") {
			   $file="./cache/".$_POST['stat_file']."";
			}
			else {
			   echo "Station file being used: ".$_POST['stat_id_file']."";
			   $file=$_POST['stat_id_file'];
			}
			$arrayL = get_csv($file);
			$len=count($arrayL);
			for ($i=0;$i<$len;$i++){
				
				if ($i==0){
					$stat_id_str=" and (d.stat_id='".$arrayL[$i][0]."' ";
				}
				else{
				$stat_id_str=$stat_id_str." or d.stat_id='".$arrayL[$i][0]."' ";
				}
			}
			$str=$str." $stat_id_str )";
			
		}
		else {		
			$str=$str." and d.stat_id='$stat_id'";
		}
    }
	else {
	   $stat_id="All";
	}
	
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//::	Date-Time Criterion
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	if ($ys){
	    $date_start=sprintf("%04d",$ys).sprintf("%02d",$ms).sprintf("%02d",$ds);		// start date format for plot titles
	    $date_end=sprintf("%04d",$ye).sprintf("%02d",$me).sprintf("%02d",$de);			// end date format for plot titles
	    $date_start_q=sprintf("%04d",$ys).sprintf("%02d",$ms).sprintf("%02d",$ds);		// start date format for MYSQL query
	    $date_end_q=sprintf("%04d",$ye).sprintf("%02d",$me).sprintf("%02d",$de);		// end date format for MYSQL query
		$str=$str." and d.ob_dates BETWEEN $date_start_q and $date_end_q and d.ob_datee BETWEEN $date_start_q and $date_end_q";		// date query string
		$date_title = "$date_start to $date_end";		// date plot title format
	}
	if ($ob_time){
		$str=$str." and d.ob_time='$ob_time'";
	}
	if ($fcast_hr){
		$str=$str." and d.fcast_hr $fcast_cond $fcast_hr";
	}
	if ($init_utc) {
		$str=$str." and d.init_utc=$init_utc";
	}

	// Set start and end dates for 4 panel plot
	$date_start1=sprintf("%04d",$ys).sprintf("%02d",$ms1)."01";
	$date_start2=sprintf("%04d",$ys).sprintf("%02d",$ms2)."01";
	$date_start3=sprintf("%04d",$ys).sprintf("%02d",$ms3)."01";
	$date_start4=sprintf("%04d",$ys).sprintf("%02d",$ms4)."01";
	
	$date_end1=sprintf("%04d",$ye).sprintf("%02d",$me1)."31";
	$date_end2=sprintf("%04d",$ye).sprintf("%02d",$me2)."31";
	$date_end3=sprintf("%04d",$ye).sprintf("%02d",$me3)."31";
	$date_end4=sprintf("%04d",$ye).sprintf("%02d",$me4)."31";
/////////////////////////////////////////////////////////////////////////////

//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//::	Hour Criterion
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    if ($start_hour < $end_hour) {
       $str=$str." and (d.ob_hour >= ".$start_hour." and d.ob_hour <= ".$end_hour.")";
	}
	else {
	   $str=$str." and (d.ob_hour >= ".$start_hour." or d.ob_hour <= ".$end_hour.")";
	}
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//::	Season Criterion
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	if ($_POST['season']){
	    if($_POST['season'] == "winter") {
		   $str=$str." and (month = 12 or month = 1 or month = 2)";
//                 $str=$str." and (month(d.ob_dates) = 12 or month(d.ob_dates) = 1 or month(d.ob_dates = 2))";
		   $date_title = "December to February $ys";
		}
		if ($_POST['season'] == "spring") {
		   $str=$str." and (month = 3 or month = 4 or month = 5)";
//                 $str=$str." and (month(d.ob_dates) = 3 or month(d.ob_dates) = 4 or month(d.ob_dates = 5))";
		   $date_title = "March to May $ys";
		}
		if ($_POST['season'] == "summer") {
		   $str=$str." and (month = 6 or month = 7 or month = 8)";
//                 $str=$str." and (month(d.ob_dates) = 6 or month(d.ob_dates) = 7 or month(d.ob_dates = 8))";
		   $date_title = "June to August $ys";
		}
		if ($_POST['season'] == "fall") {
		   $str=$str." and (month = 9 or month = 10 or month = 11)";
//                 $str=$str." and (month(d.ob_dates) = 9 or month(d.ob_dates) = 10 or month(d.ob_dates = 11))";
		   $date_title = "September to November $ys";
		}
	}
//////////////////////////////////////////////////////////////////////////////

//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//::	Individual Month Criterion
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	if ($ind_month) {
	    $str=$str." and month = ".$ind_month;
		if ($ind_month == "01") { $date_title= "January $ys"; }
		if ($ind_month == "02") { $date_title= "February $ys"; }
		if ($ind_month == "03") { $date_title= "March $ys"; }
		if ($ind_month == "04") { $date_title= "April $ys"; }
		if ($ind_month == "05") { $date_title= "May $ys"; }
		if ($ind_month == "06") { $date_title= "June $ys"; }
		if ($ind_month == "07") { $date_title= "July $ys"; }
		if ($ind_month == "08") { $date_title= "August $ys"; }
		if ($ind_month == "09") { $date_title= "September $ys"; }
		if ($ind_month == "10") { $date_title= "October $ys"; }
		if ($ind_month == "11") { $date_title= "November $ys"; }
		if ($ind_month == "12") { $date_title= "December $ys"; }
	}
//////////////////////////////////////////////////////////////////////////////

//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//::    Parameter Occurrence Code Criterion
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        if ($POCode) {
            if ($POCode != "All") {
                $str=$str." and POCode = ".$POCode;
            }
        }
//////////////////////////////////////////////////////////////////////////////


//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//::	Geographic-Based Criterion (not used in AQ module)
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	if ($elev){
		$str=$str." and s.elev $elev_cond $elev";
	}
	if ($lat1 & $lat2) {
		$str=$str." and d.lat BETWEEN $lat1 and $lat2";
    }
    if ($lon1 & lon2) {
		$str=$str." and d.lon BETWEEN $lon1 and $lon2";
	}
	if ($_POST['loc_setting']){
		$str=$str." and s.loc_setting=\'".$_POST['loc_setting']."\'";;
	}
//////////////////////////////////////////////////////////////////////////////

	$query=$str." ".$custom_query;
	$pid = (rand()%1000000);
	 
////////////////////////////////////////////////////////////////

	$doplot="FALSE";
	$savefile="FALSE";
	if($_POST['data_format1'] == 1){ $savefile="TRUE";}
	 
	 /// Determine Plot Types
	if($_POST['ametplot'] == 1) {$doplot1="TRUE";}
	if($_POST['diurnal'] == 1) {$doplot2="TRUE";}
	if($_POST['textstats'] == 1) {$doplot3="TRUE";}
	 
	 ///  Determine Plot Format
	if($_POST['png']){	$plotfmt="png";	}
	if($_POST['pdf']){	$plotfmt="pdf";	}
	if($_POST['jpeg']){	$plotfmt="jpeg";	}
	 
	// 			Open web_query.R template file
	$f = fopen("./run_info.template", "r");
		$i=0;
		while (!feof($f)) {
   			$l[$i] = fgets($f,1000);
			list($var, $threst) = split("<-", $l[$i]);
			$var=trim($var);
			if( $var == "query"){$l[$i]="query<-\"$query\"\n";}
			if( $var == "pid"){$l[$i]="pid<-\"$pid\"\n";}
			if( $var == "dbase"){$l[$i]="dbase<-\"".$_POST['database_id']."\"\n";}
			if( $var == "run_name1"){$l[$i]="run_name1<-\"$project_id\"\n";}	
			if( $var == "run_name2"){$l[$i]="run_name2<-\"".$_POST['project_id2']."\"\n";}
			if( $var == "run_name3"){$l[$i]="run_name3<-\"".$_POST['project_id3']."\"\n";}
			if( $var == "run_name4"){$l[$i]="run_name4<-\"".$_POST['project_id4']."\"\n";}
			if( $var == "run_name5"){$l[$i]="run_name5<-\"".$_POST['project_id5']."\"\n";}
			if( $var == "run_name6"){$l[$i]="run_name6<-\"".$_POST['project_id6']."\"\n";}
                        if( $var == "run_name7"){$l[$i]="run_name7<-\"".$_POST['project_id7']."\"\n";}
//			if( $var == "species"){$l[$i]=	"species<-\"$species\"\n";}
			if( $var == "species"){$l[$i]=	"species<-$species_ri\n";}
                        if( $var == "custom_species"){$l[$i]=  "costum_species<-$costum_species_ri\n";}
			if( $var == "inc_csn"){$l[$i]= "inc_csn<-\"".$_POST['inc_csn']."\"\n"; }
			if( $var == "inc_improve"){$l[$i]= "inc_improve<-\"".$_POST['inc_improve']."\"\n"; }
			if( $var == "inc_castnet"){$l[$i]= "inc_castnet<-\"".$_POST['inc_castnet']."\"\n"; }
			if( $var == "inc_castnet_hr"){$l[$i]= "inc_castnet_hr<-\"".$_POST['inc_castnet_hr']."\"\n"; }
			if( $var == "inc_castnet_daily"){$l[$i]= "inc_castnet_daily<-\"".$_POST['inc_castnet_daily']."\"\n"; }
			if( $var == "inc_castnet_drydep"){$l[$i]= "inc_castnet_drydep<-\"".$_POST['inc_castnet_drydep']."\"\n"; }
			if( $var == "inc_capmon"){$l[$i]= "inc_capmon<-\"".$_POST['inc_capmon']."\"\n"; }
			if( $var == "inc_naps"){$l[$i]= "inc_naps<-\"".$_POST['inc_naps']."\"\n"; }
			if( $var == "inc_naps_teom"){$l[$i]= "inc_naps_teom<-\"".$_POST['inc_naps_teom']."\"\n"; }
			if( $var == "inc_nadp"){$l[$i]= "inc_nadp<-\"".$_POST['inc_nadp']."\"\n"; }
			if( $var == "inc_airmon_dep"){$l[$i]= "inc_airmon_dep<-\"".$_POST['inc_airmon_dep']."\"\n"; }
			if( $var == "inc_amon"){$l[$i]= "inc_amon<-\"".$_POST['inc_amon']."\"\n"; }
			if( $var == "inc_aqs_hourly"){$l[$i]= "inc_aqs_hourly<-\"".$_POST['inc_aqs_hourly']."\"\n"; }
			if( $var == "inc_aqs_daily_O3"){$l[$i]= "inc_aqs_daily_O3<-\"".$_POST['inc_aqs_daily_O3']."\"\n"; }
			if( $var == "inc_aqs_daily"){$l[$i]= "inc_aqs_daily<-\"".$_POST['inc_aqs_daily']."\"\n"; }
                        if( $var == "inc_aqs_daily_pm"){$l[$i]= "inc_aqs_daily_pm<-\"".$_POST['inc_aqs_daily_pm']."\"\n"; }
			if( $var == "inc_search"){$l[$i]= "inc_search<-\"".$_POST['inc_search']."\"\n"; }
			if( $var == "inc_search_daily"){$l[$i]= "inc_search_daily<-\"".$_POST['inc_search_daily']."\"\n"; }
			if( $var == "inc_aeronet"){$l[$i]= "inc_aeronet<-\"".$_POST['inc_aeronet']."\"\n"; }
                        if( $var == "inc_fluxnet"){$l[$i]= "inc_fluxnet<-\"".$_POST['inc_fluxnet']."\"\n"; }
			if( $var == "inc_mdn"){$l[$i]= "inc_mdn<-\"".$_POST['inc_mdn']."\"\n"; }
			if( $var == "inc_tox"){$l[$i]= "inc_tox<-\"".$_POST['inc_tox']."\"\n"; }
			if( $var == "inc_mod"){$l[$i]= "inc_mod<-\"".$_POST['inc_mod']."\"\n"; }
			if( $var == "inc_admn"){$l[$i]= "inc_admn<-\"".$_POST['inc_admn']."\"\n"; }
			if( $var == "inc_aganet"){$l[$i]= "inc_aganet<-\"".$_POST['inc_aganet']."\"\n"; }
			if( $var == "inc_airbase_hourly"){$l[$i]= "inc_airbase_hourly<-\"".$_POST['inc_airbase_hourly']."\"\n"; }
			if( $var == "inc_airbase_daily"){$l[$i]= "inc_airbase_daily<-\"".$_POST['inc_airbase_daily']."\"\n"; }
			if( $var == "inc_aurn_hourly"){$l[$i]= "inc_aurn_hourly<-\"".$_POST['inc_aurn_hourly']."\"\n"; }
			if( $var == "inc_aurn_daily"){$l[$i]= "inc_aurn_daily<-\"".$_POST['inc_aurn_daily']."\"\n"; }
			if( $var == "inc_emep_hourly"){$l[$i]= "inc_emep_hourly<-\"".$_POST['inc_emep_hourly']."\"\n"; }
			if( $var == "inc_emep_daily"){$l[$i]= "inc_emep_daily<-\"".$_POST['inc_emep_daily']."\"\n"; }
                        if( $var == "inc_calnex"){$l[$i]= "inc_calnex<-\"".$_POST['inc_calnex']."\"\n"; }
                        if( $var == "inc_soas"){$l[$i]= "inc_soas<-\"".$_POST['inc_soas']."\"\n"; }
                        if( $var == "inc_special"){$l[$i]= "inc_special<-\"".$_POST['inc_special']."\"\n"; }
			if( $var == "dates"){$l[$i]="dates<-\"$date_title\"\n";					}
			if( $var == "averaging"){$l[$i]="averaging<-\"".$_POST['data_averaging']."\"\n";	}
			if( $var == "site"){$l[$i]="site<-\"$stat_id\"\n";}
			if( $var == "state"){$l[$i]="state<-\"$state\"\n";				}
			if( $var == "rpo"){$l[$i]="rpo<-\"".$_POST['rpo']."\"\n";	}
			if( $var == "pca"){$l[$i]="pca<-\"".$_POST['pca']."\"\n";	}
                        if( $var == "clim_reg"){$l[$i]="clim_reg<-\"".$_POST['clim_reg']."\"\n";       }
                        if( $var == "loc_setting"){$l[$i]="loc_setting<-\"".$_POST['loc_setting']."\"\n";       }
			if( $var == "conf_line"){$l[$i]="conf_line<-\"".$_POST['conf_line']."\"\n";}
			if( $var == "pca_flag"){$l[$i]="pca_flag<-\"".$_POST['pca_flag']."\"\n";}
                        if( $var == "bin_by_mod"){$l[$i]="bin_by_mod<-\"".$_POST['bin_by_mod']."\"\n";}
			if( $var == "coverage_limit"){$l[$i]="coverage_limit<-".$_POST['coverage']."\n";}
			if( $var == "valid_only"){$l[$i]="valid_only<-\"".$_POST['inc_valid']."\"\n";}
			if( $var == "num_obs_limit"){$l[$i]="num_obs_limit<-".$_POST['num_obs_limit']."\n";}
			if( $var == "soccerplot_opt"){$l[$i]="soccerplot_opt<-".$_POST['soccerplot_opt']."\n";}
			if( $var == "overlay_opt"){$l[$i]="overlay_opt<-".$_POST['overlay_opt']."\n";}
            if( $var == "x_axis_min"){$l[$i]="x_axis_min<-$x_axis_min\n";}
			if( $var == "x_axis_max"){$l[$i]="x_axis_max<-$x_axis_max\n";}
			if( $var == "y_axis_min"){$l[$i]="y_axis_min<-$y_axis_min\n";}
			if( $var == "y_axis_max"){$l[$i]="y_axis_max<-$y_axis_max\n";}
		        if( $var == "bias_y_axis_min"){$l[$i]="bias_y_axis_min<-$bias_y_axis_min\n";}
                        if( $var == "bias_y_axis_max"){$l[$i]="bias_y_axis_max<-$bias_y_axis_max\n";}
			if( $var == "density_zlim"){$l[$i]="density_zlim<-$density_zlim\n";}
			if( $var == "num_dens_bins"){$l[$i]="num_dens_bins<-$num_dens_bins\n";}
                        if( $var == "max_limit"){$l[$i]="max_limit<-".$_POST['max_limit']."\n";}
			if( $var == "inc_ranges"){$l[$i]="inc_ranges<-\"".$_POST['inc_ranges']."\"\n";}
		        if( $var == "inc_whiskers"){$l[$i]="inc_whiskers<-\"".$_POST['inc_whiskers']."\"\n";}
		        if( $var == "inc_median_lines"){$l[$i]="inc_median_lines<-\"".$_POST['inc_median_lines']."\"\n";}
			if( $var == "remove_mean"){$l[$i]="remove_mean<-\"".$_POST['remove_mean']."\"\n";}
                        if( $var == "avg_func"){$l[$i]="avg_func<-\"".$_POST['avg_func_opt']."\"\n";}
                        if( $var == "stat_func"){$l[$i]="stat_func<-\"".$_POST['stat_func_opt']."\"\n";}
                        if( $var == "line_width"){$l[$i]="line_width<-\"".$_POST['line_width_val']."\"\n";}
			if( $var == "custom_title"){$l[$i]="custom_title<-\"".$_POST['custom_title']."\"\n";}
//			if( $var == "map_leg_size"){$l[$i]="map_leg_size<-$map_leg_size\n";}
			if( $var == "stat_file"){$l[$i]="stat_file<-\"".$_POST['stat_file']."\"\n";}
			if( $var == "num_ints"){$l[$i]="num_ints<-$num_ints\n";}
			if( $var == "perc_error_max"){$l[$i]="perc_error_max<-$perc_error_max\n";}
			if( $var == "abs_error_max"){$l[$i]="abs_error_max<-$abs_error_max\n";}
			if( $var == "perc_range_min"){$l[$i]="perc_range_min<-$perc_range_min\n";}
			if( $var == "perc_range_max"){$l[$i]="perc_range_max<-$perc_range_max\n";}
			if( $var == "abs_range_min"){$l[$i]="abs_range_min<-$abs_range_min\n";}
			if( $var == "abs_range_max"){$l[$i]="abs_range_max<-$abs_range_max\n";}
			if( $var == "diff_range_min"){$l[$i]="diff_range_min<-$diff_range_min\n";}
			if( $var == "diff_range_max"){$l[$i]="diff_range_max<-$diff_range_max\n";}
			if( $var == "rmse_range_max"){$l[$i]="rmse_range_max<-$rmse_range_max\n";}
                        if( $var == "symbsizfac"){$l[$i]="symbsizfac<-$symbsizfac\n";}
			if( $var == "remove_negatives"){$l[$i]="remove_negatives<- \"".$_POST['remove_negatives']."\"\n";}
			if( $var == "use_avg_stats"){$l[$i]="use_avg_stats<- \"".$_POST['use_avg_stats']."\"\n";}
                        if( $var == "inc_legend"){$l[$i]="inc_legend<- \"".$_POST['inc_legend']."\"\n";}
                        if( $var == "inc_points"){$l[$i]="inc_points<- \"".$_POST['inc_points']."\"\n";}
			if( $var == "use_var_mean"){$l[$i]="use_var_mean<- \"".$_POST['use_var_mean']."\"\n";}
                        if( $var == "plot_cor"){$l[$i]="plot_cor<- \"".$_POST['plot_cor']."\"\n";}
			if( $var == "inc_FRM_adj"){$l[$i]="inc_FRM_adj<- \"".$_POST['inc_FRM_adj']."\"\n";}
			if( $var == "use_median"){$l[$i]="use_median<- \"".$_POST['use_median']."\"\n";}
			if( $var == "stats_flags"){$l[$i]= "stats_flags<-c(\"".$_POST['stat1']."\",\"".$_POST['stat2']."\",\"".$_POST['stat3']."\",\"".$_POST['stat4']."\",\"".$_POST['stat5']."\",\"".$_POST['stat6']."\",\"".$_POST['stat7']."\",\"".$_POST['stat8']."\",\"".$_POST['stat9']."\",\"".$_POST['stat10']."\",\"".$_POST['stat11']."\",\"".$_POST['stat12']."\",\"".$_POST['stat13']."\",\"".$_POST['stat14']."\",\"".$_POST['stat15']."\",\"".$_POST['stat16']."\",\"".$_POST['stat17']."\",\"".$_POST['stat18']."\",\"".$_POST['stat19']."\")\n"; }
			if( $var == "run_info_text"){$l[$i]="run_info_text<- \"".$_POST['run_info_text']."\"\n";}
			if( $var == "plot_colors"){$l[$i]="plot_colors<- c(\"".$_POST['network1_color']."\",\"".$_POST['network2_color']."\",\"".$_POST['network3_color']."\",\"".$_POST['network4_color']."\",\"".$_POST['network5_color']."\",\"".$_POST['network6_color']."\",\"".$_POST['network7_color']."\",\"".$_POST['network8_color']."\")\n";}
			if( $var == "plot_colors2"){$l[$i]="plot_colors2<- c(\"".$_POST['network1_color2']."\",\"".$_POST['network2_color2']."\",\"".$_POST['network3_color2']."\",\"".$_POST['network4_color2']."\",\"".$_POST['network5_color2']."\",\"".$_POST['network6_color2']."\",\"".$_POST['network7_color2']."\",\"".$_POST['network8_color2']."\")\n";}
                        if( $var == "plot_symbols"){$l[$i]="plot_symbols<- c(".$_POST['network1_symbol'].",".$_POST['network2_symbol'].",".$_POST['network3_symbol'].",".$_POST['network4_symbol'].",".$_POST['network5_symbol'].",".$_POST['network6_symbol'].",".$_POST['network7_symbol'].")\n";}
	                if( $var == "year_start"){$l[$i]="year_start<-$ys\n";}
			if( $var == "year_end"){$l[$i]="year_end<-$ye\n";}
                        if( $var == "month_start"){$l[$i]="month_start<-$ms\n";}
                        if( $var == "month_end"){$l[$i]="month_end<-$me\n";}
			if( $var == "greyscale"){$l[$i]="greyscale<- \"".$_POST['greyscale']."\"\n";}
			if( $var == "inc_counties"){$l[$i]="inc_counties<- \"".$_POST['inc_counties']."\"\n";}
			if( $var == "obs_per_day_limit"){$l[$i]="obs_per_day_limit<-".$_POST['obs_per_day_limit']."\n";}
			$i=$i+1;
         }
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Write a temporary R script for dynamic execution
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	$f = fopen("./cache/run_info.r", "w+");
	$nl=$i;
	$i=0;
	while ($i<$nl) {
		fwrite($f, $l[$i]);
		$i=$i+1;
	}
	fclose($f);
/////////////////////////////////////////////////////////////////

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Write a temporary shell script for dynamic execution
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
$l[0]="#!/bin/csh -f\n";
$l[1]="cd $cache_amet \n";
$l[2]="setenv AMETBASE $amet_base \n";
$l[3]="setenv AMETRINPUT $cache_amet/run_info.r \n";
$l[4]="setenv AMET_OUT $cache_amet \n"; 
$l[5]="$R_exe --no-save < ../../R_analysis_code/".$_POST['run_program']." \n";
if ($_POST['run_program'] == "AQ_Overlay_File.R") {		// need to include command to run the script generated by the R code
   $l[6]="./runOBS.sh \n";		// include in run script command to execute the script generated by the R code
   $nl=7;
}
else {
   $nl=6;
}
$f = fopen("./cache/run_script.csh", "w+");
$i=0;
while ($i<$nl) {
   fwrite($f, $l[$i]);
   $i=$i+1;
}
fclose($f); 
/////////////////////////////////////////////////////////////////

//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//	Execute Shell Script
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	`chmod +x ./cache/run_script.csh`;
	`./cache/run_script.csh !&> ./cache/web_query.txt`;
/////////////////////////////////////////////////////////////////

   echo "        <p align=\"left\"><font color=\"#FF0000\" size=\"6\">Your MySQL query:";
   echo "          </font><br>$query <br></p>";
   echo "       ";

   if ($_POST['run_program'] == "R_Stats_Plots.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_stats.csv"))	{
         echo " <p align=\"center\"><a href=\"./cache/${project_id}_${species}_${pid}_stats.csv\" >LINK to CSV Domain Wide Statistics File </a>" ;
         echo " <p align=\"center\"><a href=\"./cache/${project_id}_${species}_${pid}_sites_stats.csv\" >LINK to CSV Site Specific Statistics File </a><p>" ;
 		 echo " <p align=\"center\"><a href=\"./cache/${project_id}_${species}_${pid}_hourly_stats.csv\" >LINK to CSV Hourly Specific Statistics File </a><p>" ;
		 echo " <p align=\"center\"><a href=\"./cache/${project_id}_${species}_${pid}_stats_data.csv\" >LINK to Raw Query Data (CSV)</a><p>" ;

      }
   }

   echo "<table width=\"650\" border=\"0\">";// align=\"center\">";
   echo "          <td> ";
   if ($_POST['run_program'] == "R_Stats_Plots.R") {
	if(file_exists("./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_NMB.png"))	{
		echo "        <tr align=\"center\">  ";
		echo " <p align=\"center\">";
		echo "	<a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_NMB.png\">NMB (PNG)</a> ";
        	echo "&nbsp;&nbsp;";
		echo "	<a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_NME.png\">NME (PNG)</a> ";
         	echo "&nbsp;&nbsp;";
  		echo "	<a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_MB.png\">MB (PNG)</a> ";
         	echo "&nbsp;&nbsp;";
		echo "	<a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_ME.png\">ME (PNG)</a> ";
         	echo "&nbsp;&nbsp;";
		echo "	<a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_FB.png\">FB (PNG)</a> ";
          	echo "&nbsp;&nbsp;";
		echo "	<a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_FE.png\">FE (PNG)</a> ";
          	echo "&nbsp;&nbsp;";
		echo "	<a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_RMSE.png\">RMSE (PNG)</a>";
   			echo "&nbsp;&nbsp;";
		echo "	<a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_Corr.png\">Corr (PNG)</a>";
	    echo "	<p align=\"center\"><a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_NMB.pdf\">NMB (PDF)</a> ";
          	echo "&nbsp;&nbsp;";
		echo "	<a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_NME.pdf\">NME (PDF)</a> ";
          	echo "&nbsp;&nbsp;";
		echo "	<a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_MB.pdf\">MB (PDF)</a> ";
          	echo "&nbsp;&nbsp;";
		echo "	<a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_ME.pdf\">ME (PDF)</a> ";
          	echo "&nbsp;&nbsp;";
		echo "	<a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_FB.pdf\">FB (PDF)</a> ";
	        echo "&nbsp;&nbsp;";
		echo "	<a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_FE.pdf\">FE (PDF)</a> ";
	        echo "&nbsp;&nbsp;";
		echo "	<a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_RMSE.pdf\">RMSE (PDF)</a> ";
			echo "&nbsp;&nbsp;";
		echo "	<a href=\"./cache/${project_id}_${species}_${state}_${stat_id}_${pid}_statsplot_Corr.pdf\">Corr (PDF)</a> ";
	        echo "        </tr>";
	}
		else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting stats plots.";  
	}
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Raw_Data.R") {
//      if(file_exists("./cache/${project_id}_${pid}_rawdata.csv"))	{
      if(glob("./cache/${project_id}_${pid}_rawdata.csv"))	{
	     echo " <p align=\"center\">";
		 echo "	<a href=\"./cache/${project_id}_${pid}_rawdata.csv\">Raw Network Data (CSV)</a> ";
	  }   
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered creating raw data file."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Scatterplot.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_scatterplot.pdf"))	{
	     echo " <p align=\"center\">";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_scatterplot.pdf\">Mod/Ob Scatterplot (PDF)</a> ";
//         echo "         </td>";
//        echo "          <td> ";
		 echo "&nbsp;";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot.png\">Mod/Ob Scatterplot (PNG)</a> ";
//		 echo "         </td>";
//         echo "          <td> ";
		 echo "&nbsp;";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot.csv\">Scatterplot Data (CSV)</a> ";
	  }   
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting Scatter Plot"; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Scatterplot_single.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_scatterplot_single.pdf"))	{
	     echo " <p align=\"center\">";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_single.pdf\">Mod/Ob Scatterplot (PDF)</a> ";
//         echo "         </td>";
//         echo "          <td> ";
         echo "&nbsp;";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_single.png\">Mod/Ob Scatterplot (PNG)</a> ";
//		 echo "         </td>";
//         echo "          <td> ";
         echo "&nbsp;";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_single.csv\">Scatterplot Data (CSV)</a> ";
	  }   
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting Scatter Plot"; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Scatterplot_density.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_scatterplot_density.pdf"))	{
	     echo " <p align=\"center\">";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_density.pdf\">Mod/Ob Scatterplot (PDF)</a> ";
//         echo "         </td>";
//        echo "          <td> ";
		 echo "&nbsp;";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_density.png\">Mod/Ob Scatterplot (PNG)</a> ";
//		 echo "         </td>";
//         echo "          <td> ";
		 echo "&nbsp;";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_density.csv\">Scatterplot Data (CSV)</a> ";
	  }   
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting Density Scatter Plot"; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Scatterplot_log.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_scatterplot_log.pdf"))	{
	     echo " <p align=\"center\">";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_log.pdf\">Model/Ob Log-Log Scatterplot (PDF)</a> ";
         echo "         </td>";
         echo "          <td> ";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_log.png\">Model/Ob Log-Log Scatterplot (PNG)</a> ";
		 echo "         </td>";
         echo "          <td> ";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_log.csv\">Scatterplot Data (CSV File)</a> ";
	  }   
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting Log-Log Scatter Plot"; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Scatterplot_mtom.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_scatterplot_mtom.pdf"))	{
	     echo "	<a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_mtom.pdf\">Model/Model Scatterplot (PDF)</a> ";
		 echo "         </td>";
         echo "          <td> ";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_mtom.png\">Model/Model Scatterplot (PNG)</a> ";
      }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting Model-Model Scatter Plot";   }
   }
   echo "         </td>";
   echo "         <td>";  
   if ($_POST['run_program'] == "AQ_Scatterplot_percentiles.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_scatterplot_percentiles.pdf"))	{
	     echo "	<a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_percentiles.pdf\">Percentile Scatterplot (PDF)</a> ";
		 echo "         </td>";
         echo "          <td> ";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_percentiles.png\">Percentile Scatterplot (PNG)</a> ";
      }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting percentile scatter plot"; }
   }
   echo "         </td>";
   echo "         <td>"; 
   if ($_POST['run_program'] == "AQ_Scatterplot_soil.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_scatterplot_soil.pdf")) {
             echo "     <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_soil.pdf\">Model/Ob Soil Scatterplot (PDF)</a> ";
                 echo "         </td>";
         echo "          <td> ";
                 echo " <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_soil.png\">Model/Ob Soil Scatterplot (PNG)</a> ";
      }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting soil scatter plot"; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Scatterplot_skill.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_scatterplot_skill.pdf"))  {
                 echo " <p align=\"left\"><a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_skill.pdf\">Skill Plot (PDF)</a> ";
                 echo "&nbsp;&nbsp;";
                 echo " <a align=\"left\"><a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_skill.png\">Skill Plot (PNG)</a> ";
                 echo "&nbsp;&nbsp;";
                 echo " <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_skill.csv\">Skill Plot Data (CSV)</a> ";
          }   
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting skill scatter plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Scatterplot_bins.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_scatterplot_bins.pdf"))   {
         echo "     <p align=\"left\"><a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_bins.png\">Mean Bias Plot (PNG)</a> ";
         echo "&nbsp;&nbsp;";
         echo " <a align=\"left\"><a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_bins.pdf\">Mean Bias Plot (PDF)</a> ";
         echo "&nbsp;&nbsp;";
         echo "     <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot_bins.csv\">Raw Data File (CSV)</a> ";
      }   
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting binned scatter plots."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Scatterplot_multi.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_scatterplot.pdf"))    {
         echo " <p align=\"left\"><a href=\"./cache/${project_id}_${species}_${pid}_scatterplot.pdf\">Scatterplot (PDF)</a> ";
         echo "&nbsp;&nbsp;";
         echo " <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot.png\">Scatterplot (PNG)</a> ";
         echo "&nbsp;&nbsp;";
         echo " <a href=\"./cache/${project_id}_${species}_${pid}_scatterplot.csv\">Scatterplot Data (CSV)</a> ";
      }   
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting multi scatter plot."; }
   }
   echo "         </td>";
   echo "         <td>"; 
   if ($_POST['run_program'] == "AQ_Soccerplot.R") {
      if(file_exists("./cache/${project_id}_${pid}_soccerplot.pdf"))	{
	     echo "	<a href=\"./cache/${project_id}_${pid}_soccerplot.png\">Soccergoal Plot (PNG)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo " <a href=\"./cache/${project_id}_${pid}_soccerplot.pdf\">Soccergoal Plot (PDF)</a> ";
      }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting Soccergoal Plot"; }
   }
   echo "         </td>";
   echo "         <td>";  
   if ($_POST['run_program'] == "AQ_Bugleplot.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_bugleplot_error.pdf"))	{
	     echo "	<a href=\"./cache/${project_id}_${species}_${pid}_bugleplot_bias.png\">Bugle Plot Bias (PNG)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_bugleplot_error.png\">Bugle Plot Error (PNG)</a> ";
		 echo " <p><a href=\"./cache/${project_id}_${species}_${pid}_bugleplot_bias.pdf\">Bugle Plot Bias(PDF)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_bugleplot_error.pdf\">Bugle Plot Error (PDF)</a> ";
      }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting bulge plot."; }
   }
   echo "         </td>";
   echo "         <td>";  
   if ($_POST['run_program'] == "AQ_Timeseries.R") {
      echo "<center><strong>AMET Timeseries Plots</strong></center><p>";
      echo "<center>";
      if(file_exists("./cache/${project_id}_${species}_${pid}_bias_timeseries.png"))	{
      echo "Time Series Plot (PDF):";
      echo "&nbsp;&nbsp;";
      echo "	<a href=\"./cache/${project_id}_${species}_${pid}_bias_timeseries.pdf\"> (Bias)</a> ";
      echo "&nbsp;&nbsp;";
      echo "    <a href=\"./cache/${project_id}_${species}_${pid}_rmse_timeseries.pdf\">(RMSE)</a> ";
      echo "&nbsp;&nbsp;";
      echo "    <a href=\"./cache/${project_id}_${species}_${pid}_corr_timeseries.pdf\">(Corr)</a> ";
      echo "<p> Time Series Plot (PNG):";
      echo "&nbsp;&nbsp;";
      echo "	<a href=\"./cache/${project_id}_${species}_${pid}_bias_timeseries.png\">(Bias)</a> ";
      echo "&nbsp;&nbsp;";
      echo "    <a href=\"./cache/${project_id}_${species}_${pid}_rmse_timeseries.png\">(RMSE)</a> ";
      echo "&nbsp;&nbsp;";
      echo "    <a href=\"./cache/${project_id}_${species}_${pid}_corr_timeseries.png\">(Corr)</a> ";
      echo "<p>";
      echo "	<a href=\"./cache/${project_id}_${species}_${pid}_timeseries.csv\">Timeseries Data (CSV)</a> ";
      }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting timeseries plot"; }
   }
   echo "         </td>";
   echo "</center>";
   echo "         <td>";  
   if ($_POST['run_program'] == "AQ_Timeseries_multi_networks.R") {
      echo "<center><strong>AMET Timeseries Plots</strong></center><p>";
	  echo "<center>";
	  if(file_exists("./cache/${project_id}_${species}_${pid}_timeseries.png"))	{
         echo "	<a href=\"./cache/${project_id}_${species}_${pid}_timeseries.pdf\">Timeseries Plot (PDF)</a> ";
		 echo "&nbsp;&nbsp;";
	     echo "	<a href=\"./cache/${project_id}_${species}_${pid}_timeseries.png\">Timeseries Plot (PNG)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_timeseries.csv\">Timeseries Data (CSV)</a> ";
      }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting timeseries plot"; }
   }
   echo "         </td>";
   echo "</center>";
   echo "         <td>"; 
   if ($_POST['run_program'] == "AQ_Timeseries_MtoM.R") {
      echo "<center><strong>AMET Timeseries Plots</strong></center><p>";
          echo "<center>";
          if(file_exists("./cache/${project_id}_${species}_${pid}_timeseries_mtom.png"))  {
         echo " <a href=\"./cache/${project_id}_${species}_${pid}_timeseries_mtom.pdf\">Timeseries Plot (PDF)</a> ";
                 echo "&nbsp;&nbsp;";
             echo "     <a href=\"./cache/${project_id}_${species}_${pid}_timeseries_mtom.png\">Timeseries Plot (PNG)</a> ";
                 echo "&nbsp;&nbsp;";
                 echo " <a href=\"./cache/${project_id}_${species}_${pid}_timeseries_mtom.csv\">Timeseries Data (CSV)</a> ";
      }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting timeseries model to model plot"; }
   }
   echo "         </td>";
   echo "</center>";
   echo "         <td>"; 
   if ($_POST['run_program'] == "AQ_Boxplot_Hourly.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_boxplot_hourly.pdf"))	{
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_boxplot_hourly.pdf\">Boxplot (PDF format)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_boxplot_hourly.png\">Boxplot (PNG format)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${pid}_boxplot_data.csv\">Median Data (CSV format)</a> ";
	  }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting hourly box plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Boxplot_MDA8.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_boxplot_MDA8.pdf"))	{
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_boxplot_MDA8.pdf\">MDA8 Boxplot (PDF)</a> ";
		 echo "         </td>";
         echo "          <td> ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_boxplot_MDA8.png\">MDA8 Boxplot (PNG)</a> ";
	  }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting MDA8 boxplot."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Boxplot.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_boxplot_all.pdf"))	{
	     echo "	<a href=\"./cache/${project_id}_${species}_${pid}_boxplot_all.png\">Boxplot (PNG)</a> ";
         echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_boxplot_all.pdf\">Boxplot (PDF)</a> ";
		 echo "	<p align=\"left\"><a href=\"./cache/${project_id}_${species}_${pid}_boxplot_bias.png\">Bias Boxplot (PNG)</a> ";
         echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_boxplot_bias.pdf\">Bias Boxplot (PDF)</a> ";
		 echo "	<p align=\"left\"><a href=\"./cache/${project_id}_${species}_${pid}_boxplot_norm_bias.png\">Normalized Bias Boxplot (PNG)</a> ";
         echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_boxplot_norm_bias.pdf\">Normalized Bias Boxplot (PDF)</a> ";
	  }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting box plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Boxplot_DofW.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_boxplot_dow.pdf"))	{
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_boxplot_dow.pdf\">Day of Week Boxplot (PDF)</a> ";
		 echo "         </td>";
         echo "          <td> ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_boxplot_dow.png\">Day of Week Boxplot (PNG)</a> ";
	  }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting day of week boxplot."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Boxplot_Roselle.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_boxplot_roselle.pdf"))	{
	     echo "<a href=\"./cache/${project_id}_${species}_${pid}_boxplot_roselle.png\">Roselle Boxplot (PNG)</a> ";
             echo "&nbsp;&nbsp;";
             echo "<a href=\"./cache/${project_id}_${species}_${pid}_boxplot_bias_roselle.png\">Roselle Boxplot Bias (PNG)</a> ";
             echo "<p><a href=\"./cache/${project_id}_${species}_${pid}_boxplot_roselle.pdf\">Roselle Boxplot (PDF)</a> ";
             echo "&nbsp;&nbsp;";
             echo "<a href=\"./cache/${project_id}_${species}_${pid}_boxplot_bias_roselle.pdf\">Roselle Boxplot Bias (PDF)</a> ";
	  }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting Roselle box plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Stacked_Barplot.R") {
      if(file_exists("./cache/${project_id}_${pid}_stacked_barplot.pdf"))	{
	     echo "	<p align=\"center\"><a href=\"./cache/${project_id}_${pid}_stacked_barplot.png\">Stacked Barplot (PNG)</a> ";
         echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${pid}_stacked_barplot.pdf\">Stacked Barplot (PDF)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${pid}_stacked_barplot.csv\">Barplot Data (CSV)</a> ";
	  }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting bar plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Stacked_Barplot_panel.R") {
      if(file_exists("./cache/${project_id}_${pid}_stacked_barplot_panel.pdf"))       {
             echo "     <p align=\"center\"><a href=\"./cache/${project_id}_${pid}_stacked_barplot_panel.png\">Stacked Barplot (PNG)</a> ";
         echo "&nbsp;&nbsp;";
                 echo " <a href=\"./cache/${project_id}_${pid}_stacked_barplot_panel.pdf\">Stacked Barplot (PDF)</a> ";
                 echo "&nbsp;&nbsp;";
                 echo " <a href=\"./cache/${project_id}_${pid}_stacked_barplot_panel.csv\">Barplot Data (CSV)</a> ";
          }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting bar plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Stacked_Barplot_panel_AE6.R") {
      if(file_exists("./cache/${project_id}_${pid}_stacked_barplot_panel_AE6.pdf"))       {
             echo "     <p align=\"center\"><a href=\"./cache/${project_id}_${pid}_stacked_barplot_panel_AE6.png\">Stacked Barplot (PNG)</a> ";
         echo "&nbsp;&nbsp;";
                 echo " <a href=\"./cache/${project_id}_${pid}_stacked_barplot_panel_AE6.pdf\">Stacked Barplot (PDF)</a> ";
                 echo "&nbsp;&nbsp;";
                 echo " <a href=\"./cache/${project_id}_${pid}_stacked_barplot_panel_AE6.csv\">Barplot Data (CSV)</a> ";
          }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting bar plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Stacked_Barplot_AE6.R") {
      if(file_exists("./cache/${project_id}_${pid}_stacked_barplot_AE6.pdf"))       {
             echo "     <p align=\"center\"><a href=\"./cache/${project_id}_${pid}_stacked_barplot_AE6.png\">Stacked Barplot (PNG)</a> ";
         echo "&nbsp;&nbsp;";
                 echo " <a href=\"./cache/${project_id}_${pid}_stacked_barplot_AE6.pdf\">Stacked Barplot (PDF)</a> ";
                 echo "&nbsp;&nbsp;";
                 echo " <a href=\"./cache/${project_id}_${pid}_stacked_barplot_AE6.csv\">Barplot Data (CSV)</a> ";
          }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting bar plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Stacked_Barplot_panel_AE6_multi.R") {
      if(file_exists("./cache/${project_id}_${pid}_stacked_barplot_panel_AE6.pdf"))       {
             echo "     <p align=\"center\"><a href=\"./cache/${project_id}_${pid}_stacked_barplot_panel_AE6.png\">Stacked Barplot (PNG)</a> ";
         echo "&nbsp;&nbsp;";
                 echo " <a href=\"./cache/${project_id}_${pid}_stacked_barplot_panel_AE6.pdf\">Stacked Barplot (PDF)</a> ";
                 echo "&nbsp;&nbsp;";
                 echo " <a href=\"./cache/${project_id}_${pid}_stacked_barplot_panel_AE6.csv\">Barplot Data (CSV)</a> ";
          }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting bar plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
      if ($_POST['run_program'] == "AQ_Stacked_Barplot_soil.R") {
      if(file_exists("./cache/${project_id}_${pid}_stacked_barplot_soil.pdf"))       {
             echo "     <p align=\"center\"><a href=\"./cache/${project_id}_${pid}_stacked_barplot_soil.png\">Stacked Barplot (PNG)</a> ";
         echo "&nbsp;&nbsp;";
                 echo " <a href=\"./cache/${project_id}_${pid}_stacked_barplot_soil.pdf\">Stacked Barplot (PDF)</a> ";
                 echo "&nbsp;&nbsp;";
                 echo " <a href=\"./cache/${project_id}_${pid}_stacked_barplot_soil.csv\">Barplot Data (CSV)</a> ";
          }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting bar plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
if ($_POST['run_program'] == "AQ_Stacked_Barplot_soil_multi.R") {
      if(file_exists("./cache/${project_id}_${pid}_stacked_barplot_soil.pdf"))       {
             echo "     <p align=\"center\"><a href=\"./cache/${project_id}_${pid}_stacked_barplot_soil.png\">Stacked Barplot (PNG)</a> ";
         echo "&nbsp;&nbsp;";
                 echo " <a href=\"./cache/${project_id}_${pid}_stacked_barplot_soil.pdf\">Stacked Barplot (PDF)</a> ";
                 echo "&nbsp;&nbsp;";
                 echo " <a href=\"./cache/${project_id}_${pid}_stacked_barplot_soil.csv\">Barplot Data (CSV)</a> ";
          }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting soil bar plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Overlay_File.R") {
      if(file_exists("./cache/${project_id}_${pid}_overlay.ncf"))	{
	     echo "	<a href=\"./cache/${project_id}_${pid}_overlay.ncf\">PAVE Obs Overlay File (IOAPI file)</a> ";
	  }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered creating overlay file."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Monthly_Stat_Plot.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_plot1.pdf"))	{
	     echo "	<p align=\"left\"><a href=\"./cache/${project_id}_${species}_${pid}_plot1.pdf\">Obs/Mod Plot (PDF)</a> ";
         echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_plot1.png\">Obs/Mod Plot (PNG)</a> ";
		 echo "&nbsp;&nbsp;";
	     echo "	<a href=\"./cache/${project_id}_${species}_${pid}_stats.csv\">Monthly Stat File (CSV)</a> ";
 	     echo "&nbsp;&nbsp;";
		 echo "	<p align=\"left\"><a href=\"./cache/${project_id}_${species}_${pid}_statsplot1.pdf\">NMB/NME/Corr Plot (PDF)</a> ";
	     echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_statsplot1.png\">NMB/NME/Corr Plot (PNG)</a> ";
 	     echo "&nbsp;&nbsp;";
		 echo "	<p align=\"left\"><a href=\"./cache/${project_id}_${species}_${pid}_statsplot2.pdf\">MdnB/MdnE/RMSE Plot (PDF)</a> ";
	     echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_statsplot2.png\">MdnB/MdnE/RMSE Plot (PNG)</a> ";  
	  }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting yearly stat plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Plot_Spatial.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_spatialplot_obs.png"))	{
	     echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_obs.png\">Obs (PNG)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_mod.png\">Model (PNG)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_diff.png\">Difference (PNG)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_ratio.png\">Ratio (PNG)</a> ";
         echo "<p><a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_obs.pdf\">Obs (PDF)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_mod.pdf\">Model (PDF)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_diff.pdf\">Difference (PDF)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_ratio.pdf\">Ratio (PDF)</a> ";
	  }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting model/ob spatial plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
      if ($_POST['run_program'] == "AQ_Plot_Spatial_Ratio.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_spatialplot_ratio_obs.png"))	{
	     echo "	<p align=\"left\"><a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_ratio_obs.png\">Obs Spatial Plot (PNG)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_ratio_mod.png\">Model Spatial Plot (PNG)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_ratio_diff.png\">Difference Plot (PNG)</a> ";
         echo "<p><a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_ratio_obs.pdf\">Obs Spatial Plot (PDF)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_ratio_mod.pdf\">Model Spatial Plot (PDF)</a> ";
		 echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_ratio_diff.pdf\">Difference Plot (PDF)</a> ";
	  }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting model/ob spatial ratio plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Plot_Spatial_MtoM.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_spatialplot_MtoM_Diff_Avg.png"))	{
	     echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_MtoM_Diff_Avg.png\">MtoM Diff Avg Plot (PNG)</a> ";
		 echo "&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_MtoM_Diff_Max.png\">MtoM Diff Max Plot (PNG)</a> ";
		 echo "&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_MtoM_Diff_Min.png\">MtoM Diff Min Plot (PNG)</a> ";
         echo "<p><a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_MtoM_Diff_Avg.pdf\">MtoM Diff Avg Plot (PDF)</a> ";
		 echo "&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_MtoM_Diff_Max.pdf\">MtoM Diff Max Plot (PDF)</a> ";
		 echo "&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatialplot_MtoM_Diff_Min.pdf\">MtoM Diff Min Plot (PDF)</a> ";
	  }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting model/model spatial diff plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Plot_Spatial_Diff.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_spatial_plot_Bias_1.png"))	{
	     echo "Run 1 Bias Plot ";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Bias_1.png\">(PNG)</a>";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Bias_1.pdf\"> (PDF)</a>";
         echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
		 echo "Run 1 Error Plot ";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Error_1.png\">(PNG)</a>";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Error_1.pdf\"> (PDF)</a>";
         echo "<p>Run 2 Bias Plot ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Bias_2.png\">(PNG)</a> ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Bias_2.pdf\"> (PDF)</a> ";
         echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
		 echo "Run 2 Error Plot ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Error_2.png\">(PNG)</a> ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Error_2.pdf\"> (PDF)</a> ";
		 echo "<p>Bias Difference Plot ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Bias_Diff.png\">(PNG)</a> ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Bias_Diff.pdf\"> (PDF)</a> ";
         echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
		 echo "Error Difference Plot ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Error_Diff.png\">(PNG)</a> ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Error_Diff.pdf\"> (PDF)</a> ";
                 echo "<p>Bias Diff Hist Plot ";
                 echo " <a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Bias_Diff_Hist.png\">(PNG)</a> ";
                 echo " <a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Bias_Diff_Hist.pdf\"> (PDF)</a> ";
         echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
                 echo "Error Diff Hist Plot";
                 echo " <a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Error_Diff_Hist.png\">(PNG)</a> ";
                 echo " <a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_Error_Diff_Hist.pdf\"> (PDF)</a> ";
                 echo "<p>Plot Data File";
                 echo " <a href=\"./cache/${project_id}_${species}_${pid}_spatial_plot_diff.csv\">(CSV)</a> ";
	  }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting model/ob spatial diff plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Histogram.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_histogram.pdf"))	{
	     echo "	<p align=\"left\"><a href=\"./cache/${project_id}_${species}_${pid}_histogram.png\">Histogram Plot(PNG)</a> ";
		    echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_histogram_bias.png\">Histogram Bias Plot (PNG)</a> ";
		 echo "	<p align=\"left\"><a href=\"./cache/${project_id}_${species}_${pid}_histogram.pdf\">Histogram Plot(PDF)</a> ";
		    echo "&nbsp;&nbsp;";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_histogram_bias.pdf\">Histogram Bias Plot (PDF)</a> ";
	  }
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting histogram plot."; }
   }
   echo "         </td>";
   echo "          <td> ";
      if ($_POST['run_program'] == "AQ_Temporal_Plots.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_ecdf.pdf"))	{
	     echo "ECDF Plot ";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_ecdf.png\">(PNG)</a>";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_ecdf.pdf\"> (PDF)</a>";
		 echo "<p>Q-Q Plot ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_qq.png\">(PNG)</a> ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_qq.pdf\"> (PDF)</a> ";
		 echo "<p>Taylor Plot ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_taylor.png\">(PNG)</a> ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_taylor.pdf\"> (PDF)</a> ";
		 echo "<p>Periodogram Plot ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_periodogram.png\">(PNG)</a> ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_periodogram.pdf\"> (PDF)</a> ";	     
	  }   
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting temporal plots."; }
   }
   echo "         </td>";
   echo "          <td> ";
   if ($_POST['run_program'] == "AQ_Spectal_Analysis.R") {
      if(file_exists("./cache/${project_id}_${species}_${pid}_spectrum.pdf"))	{
	     echo "Spectrum Plot ";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_spectrum.png\">(PNG)</a>";
		 echo " <a href=\"./cache/${project_id}_${species}_${pid}_spectrum.pdf\"> (PDF)</a>";
		 echo "<p>Individual Site Spectrum Plots ";
		 echo "	<a href=\"./cache/${project_id}_${species}_${pid}_spectrum_all.pdf\"> (PDF)</a> ";	     
	  }   
      else {echo "<a href=\"./cache/web_query.txt\">query_output.txt</a> An error was encountered plotting spectrum plots."; }
   }
   echo "         </td>";
   
   echo "        </tr>";
   echo "      </table>";
//}
   echo "  <p>&nbsp;</p>";
   echo "  <p>&nbsp;</p>";
   echo "   <hr>";
}	
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::://
?>     
</p>
            <p align="left"><font color="#333333" face="Arial, Helvetica, sans-serif">This 
                web-based utility queries the AMET database for sub-sets of data, 
                then performs a variety of statistics and generates user-defined 
                plots.</a> </font>            </p>
            <h4><font color="#333333" face="Arial, Helvetica, sans-serif">Data 
              Subset Specification</font></h4>
            <p><font color="#333333" face="Arial, Helvetica, sans-serif">Currently 
              there several categories with multiple criteria that allow the user 
              to isolate a particular set of data. Please ignore criteria that do not apply 
              to your particular need, as those criteria will not 
              be considered in the data selection.</font></p>
			  <div align="center">
            <h2><br>
            <?php 
	  		/////////////////////////////////////////////// 
			 include ( '../configure/amet-www-config.php'); 
	 		///////////////////////////////////////////////

       		echo " <form name=shell method=post action=querygen_aq.php > ";
         	?>
                
                    <div align="center">
                      <h2>Database Specification</h2>
                        <a name="station"></a>
                        <?php 
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::://
//	Connect to Database via user supplied login and pass
	 /////////////////////////////////////////////// 
	 include ( '../configure/amet-www-config.php'); 
	 ///////////////////////////////////////////////
		//$dbase="test_avgAQ";
		$link = mysql_connect($mysql_server,$root_login,$root_pass) or die("Connect Error: ".mysql_error());
		if (! $link)
		die("Couldn't connect to MySQL");
        $result = mysql_list_dbs($link)
		or die("Select DB Error: ".mysql_error());
		//echo '<ul>'.NL;
//		while($row = mysql_fetch_assoc($result)):
//		   echo $row['Database'];
//		endwhile;
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::://
// Check database logs for the existance of the requested project id
		$i=0;
		echo "<select name=database_id id=database_id onChange=\"MM_jumpMenu('parent',this,0)\"> ";
        echo " <option value= > Choose a Database  </option> ";
		
			
		if ($row = mysql_fetch_array($result)) {
		do {
			$did=$row['Database'];
	         echo $row['Database'];
				$select="";
    		if ($did == $_GET['database_id']) {
			   $select="SELECTED";
			}
		    $data_str[$i]="Database ID: ".$row["Database"];
             echo " <option value=querygen_aq.php?database_id=".$row["Database"]."&stat_id=".$_GET['stat_id']."&stat_file=".$_GET['stat_file']."  $select> $data_str[$i]  </option> ";
//			 $proj_str[$i]="Project ID: ".$row["proj_code"].", User ID: ".$row["user_id"].", Setup Date: ".$row[5];
//            echo " <option value=querygen_aq.php?project_id=".$row["proj_code"]."&stat_id=".$_GET['stat_id']."&stat_file=".$_GET['stat_file']."  $select> $proj_str[$i]  </option> ";
	   	}
		while($row = mysql_fetch_assoc($result));

		}
		echo "</select> "; 
		//else{
		
		//	print "this is a test<br>";
		//	die("No project were found in the database, this is likely a connection error. Contact AMET system adminsitrator <br>".mysql_error());
		//}
         echo " <option value= ></option> </select> ";
//	    $_SESSION['database_id']=$_GET['database_id'];
//        $statid		=$_GET['stat_id'];
//		$stat_file	=$_GET['stat_file'];
		$database_id	=$_GET['database_id'];
		
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::://			
//if($_SESSION['database_id']){

//}
?>
                      
                      <h2>Project/Model Run Specification <br></h2>
                        <a name="station"></a>
                        <?php 
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::://
//	Connect to Database via user supplied login and pass
	 /////////////////////////////////////////////// 
	 include ( '../configure/amet-www-config.php'); 
	 ///////////////////////////////////////////////
		//$dbase="test_avgAQ";
		$link = mysql_connect($mysql_server,$root_login,$root_pass) or die("Connect Error: ".mysql_error());
		if (! $link)
		die("Couldn't connect to MySQL");
        mysql_select_db($database_id , $link)
		or die("Select DB Error: ".mysql_error());
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::://
// Check database logs for the existance of the requested project id
		$result=mysql_query("SELECT proj_code,user_id,model,email,description,DATE_FORMAT(proj_date,'%m/%d/%Y'),proj_time,DATE_FORMAT(min_date,'%m/%d/%Y'),DATE_FORMAT(max_date,'%m/%d/%Y') from aq_project_log ORDER BY proj_code")or die("There was an error accessing the database ".mysql_error());
		$i=0;
		    echo "<select name=project_id id=project_id onChange=\"MM_jumpMenu('parent',this,0)\"> ";
            
			echo " <option value= > Choose a Project </option> ";
		if ($row = mysql_fetch_array($result)) {
		do {
			$pid=$row["proj_code"];
	
				$select="";
			if ($pid == $_GET['project_id']) {
				$a1=$row["proj_code"];
				$a2=$row["user_id"];
				$a3=$row["model"];
				$a4=$row["email"];
				$a5=$row["description"];
				$a6=$row[5];
				$a7=$row["proj_time"];
				$a8=$row[7];
				$a9=$row[8];
				$select="SELECTED";
				//<!-- The method below to retrieve the min and max dates is not being used because it is too slow. -->
				// Determine start and end dates of the data by querying the appropriate database		  
				//   $result2=mysql_query("SELECT min(ob_dates),max(ob_datee) from ".$a1."");
				//   $row2=mysql_fetch_array($result2);
				//   $a8=$row2["min(ob_dates)"];
				//   $a9=$row2["max(ob_datee)"];
			}	
			$proj_str[$i]="Project ID: ".$row["proj_code"].", User ID: ".$row["user_id"].", Setup Date: ".$row[5];
             echo " <option value=querygen_aq.php?database_id=$database_id&project_id=".$row["proj_code"]."&stat_id=".$_GET['stat_id']."&stat_file=".$_GET['stat_file']."  $select> $proj_str[$i]  </option> ";

		}
		while($row = mysql_fetch_array($result));

		} 
		else{
		
			print "this is a test<br>";
			die("No project were found in the database, this is likely a connection error. Contact AMET system adminsitrator <br>".mysql_error());
		}
         echo " <option value= ></option> </select> ";
	    $_SESSION['project_id']=$_GET['project_id'];
        $statid		=$_GET['stat_id'];
		$stat_file	=$_GET['stat_file'];
		$project_id	=$_GET['project_id'];
		$database_id=$_GET['database_id'];
		
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::://			
if($_SESSION['project_id']){
print <<<TEST
          <p>
		  <table width="500" border="0" align="center" cellpadding="2" cellspacing="2">                           
                            <tr bgcolor="#CCFFCC">
                              <th colspan="2" scope="col"><h2>Project Details </h2></th>
                            </tr>
                            <tr>
                              <td width="152" align="right">Project ID: </td>
                              <td width="328" align="left">$project_id </td>
                            </tr>
                            <tr>
                              <td align="right">Owner: </td>
                              <td align="left">$a2</td>
                            </tr>
                            <tr>
                              <td align="right">Model: </td>
                              <td align="left">$a3</td>
                            </tr>
                            <tr>
                              <td align="right">Email: </td>
                              <td align="left">$a4</td>
                            </tr>
                            <tr>
                              <td align="right">Description: </td>
                              <td align="left">$a5</td>
                            </tr>
                            <tr>
                              <td align="right">Project Creation Date:  </td>
                              <td align="left">$a6 $a7 </td>
                            </tr>
                            <tr>
                              <td align="right">Earliest Record: </td>
                              <td align="left">$a8</td>
                            </tr>
                            <tr>
                              <td height="23" align="right">Latest Record: </td>
                              <td align="left">$a9</td>
                            </tr>
                          </table>
 		  <input name="project_id" type="hidden" value="$a1" > 
		  <input name="stat_id" type="hidden" value="$statid" > 
		  <input name="stat_file" type="hidden" value="$stat_file" > 
		  <input name="min_date" type="hidden" value=$a8 > 
		  <input name="max_date" type="hidden" value=$a9 > 
		  <input name="database_id" type="hidden" value="$database_id">
TEST;
}
else {
print <<<TEST
      <option value="" ></option> 
	  </select> 
      <p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p><p align="left">&nbsp;</p>
TEST;
}
?>

                        </font>
                        </p>
                    </h2>
                      <p align="left"><font face="Arial, Helvetica, sans-serif"><strong>Additional Project IDs:</strong><br>
            Select additional projects to use for model to model comparisons.<br>
            <br>
              <?php 
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//	Connect to Database via user supplied login and pass
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	 include ( '../configure/amet-www-config.php'); 
		//$dbase="test_avgAQ";
		$link = mysql_connect($mysql_server,$root_login,$root_pass)or die("Connect Error: ".mysql_error());
		if (! $link)
		die("Couldn't connect to MySQL");
        mysql_select_db($database_id , $link)
		or die("Select DB Error: ".mysql_error());
//////////////////////////////////////////////////////////////////////////////////////////////////

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Check database logs for the existance of the requested project id
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		$result=mysql_query("SELECT proj_code, user_id, DATE_FORMAT(proj_date,'%m/%d/%Y'), proj_time, description from aq_project_log ORDER BY proj_code")or die("There was an error accessing the database ".mysql_error());
		$i=0;
		    echo "<select name=\"project_id2\" id=\"project_id2\"> ";
			echo " <option value=\"\" selected> Choose a Project  </option> ";
		if ($row = mysql_fetch_array($result)) {
		do {
			$pid=$row["proj_code"];
			$proj_str[$i]="Project ID: ".$row["proj_code"].", User ID: ".$row["user_id"].", Setup Date: ".$row[2];
             echo " <option value=\"$pid\"> $proj_str[$i]  </option> ";

		}
		while($row = mysql_fetch_array($result));

		} 
		else{
		   die("No project were found in the database, this is likely a connection error. Contact AMET system adminsitrator <br>".mysql_error());
		}
	        echo "</select> ";		
//////////////////////////////////////////////////////////////////////////////////////////////////

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Monitor / Network and Species Criteria - State, Site ID, RPO Regions, AQ Networks, Species to Plot
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
?>
            </p>

<p align="left"><?php 
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//	Connect to Database via user supplied login and pass
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	 include ( '../configure/amet-www-config.php'); 
		//$dbase="test_avgAQ";
		$link = mysql_connect($mysql_server,$root_login,$root_pass)or die("Connect Error: ".mysql_error());
		if (! $link)
		die("Couldn't connect to MySQL");
        mysql_select_db($database_id , $link)
		or die("Select DB Error: ".mysql_error());
//////////////////////////////////////////////////////////////////////////////////////////////////

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Check database logs for the existance of the requested project id
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		$result=mysql_query("SELECT proj_code, user_id, DATE_FORMAT(proj_date,'%m/%d/%Y'), proj_time, description from aq_project_log ORDER BY proj_code")or die("There was an error accessing the database ".mysql_error());
		$i=0;
	        echo "<select name=\"project_id3\" id=\"project_id3\"> ";
		echo " <option value=\"\" selected> Choose a Project  </option> ";
		if ($row = mysql_fetch_array($result)) {
		do {
			$pid=$row["proj_code"];
			$proj_str[$i]="Project ID: ".$row["proj_code"].", User ID: ".$row["user_id"].", Setup Date: ".$row[2];
             echo " <option value=\"$pid\"> $proj_str[$i]  </option> ";

		}
		while($row = mysql_fetch_array($result));

		} 
		else{
		
			
			die("No project were found in the database, this is likely a connection error. Contact AMET system adminsitrator <br>".mysql_error());
		}
		  echo "</select> ";		
//////////////////////////////////////////////////////////////////////////////////////////////////

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Monitor / Network and Species Criteria - State, Site ID, RPO Regions, AQ Networks, Species to Plot
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
?>
            </p>
            <p align="left"><?php 
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//	Connect to Database via user supplied login and pass
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	 include ( '../configure/amet-www-config.php'); 
		//$dbase="test_avgAQ";
		$link = mysql_connect($mysql_server,$root_login,$root_pass)or die("Connect Error: ".mysql_error());
		if (! $link)
		die("Couldn't connect to MySQL");
        mysql_select_db($database_id , $link)
		or die("Select DB Error: ".mysql_error());
//////////////////////////////////////////////////////////////////////////////////////////////////

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Check database logs for the existance of the requested project id
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		$result=mysql_query("SELECT proj_code, user_id, DATE_FORMAT(proj_date,'%m/%d/%Y'), proj_time, description from aq_project_log ORDER BY proj_code")or die("There was an error accessing the database ".mysql_error());
		$i=0;
		    echo "<select name=\"project_id4\" id=\"project_id4\"> ";
			echo " <option value=\"\" selected> Choose a Project  </option> ";
		if ($row = mysql_fetch_array($result)) {
		do {
			$pid=$row["proj_code"];
			$proj_str[$i]="Project ID: ".$row["proj_code"].", User ID: ".$row["user_id"].", Setup Date: ".$row[2];
             echo " <option value=\"$pid\"> $proj_str[$i]  </option> ";

		}
		while($row = mysql_fetch_array($result));

		} 
		else{
		
			
			die("No project were found in the database, this is likely a connection error. Contact AMET system adminsitrator <br>".mysql_error());
		}
		  echo "</select> ";		
//////////////////////////////////////////////////////////////////////////////////////////////////

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Monitor / Network and Species Criteria - State, Site ID, RPO Regions, AQ Networks, Species to Plot
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
?>
            </p>
            <p align="left"><?php 
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//	Connect to Database via user supplied login and pass
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	 include ( '../configure/amet-www-config.php'); 
		//$dbase="test_avgAQ";
		$link = mysql_connect($mysql_server,$root_login,$root_pass)or die("Connect Error: ".mysql_error());
		if (! $link)
		die("Couldn't connect to MySQL");
        mysql_select_db($database_id , $link)
		or die("Select DB Error: ".mysql_error());
//////////////////////////////////////////////////////////////////////////////////////////////////

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Check database logs for the existance of the requested project id
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		$result=mysql_query("SELECT proj_code, user_id, DATE_FORMAT(proj_date,'%m/%d/%Y'), proj_time, description from aq_project_log ORDER BY proj_code")or die("There was an error accessing the database ".mysql_error());
		$i=0;
		    echo "<select name=\"project_id5\" id=\"project_id5\"> ";
			echo " <option value=\"\" selected> Choose a Project  </option> ";
		if ($row = mysql_fetch_array($result)) {
		do {
			$pid=$row["proj_code"];
			$proj_str[$i]="Project ID: ".$row["proj_code"].", User ID: ".$row["user_id"].", Setup Date: ".$row[2];
             echo " <option value=\"$pid\"> $proj_str[$i]  </option> ";

		}
		while($row = mysql_fetch_array($result));

		} 
		else{
		
			
			die("No project were found in the database, this is likely a connection error. Contact AMET system adminsitrator <br>".mysql_error());
		}
		  echo "</select> ";		
//////////////////////////////////////////////////////////////////////////////////////////////////

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Monitor / Network and Species Criteria - State, Site ID, RPO Regions, AQ Networks, Species to Plot
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
?>
            </p>
            <p align="left"><?php 
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//	Connect to Database via user supplied login and pass
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	 include ( '../configure/amet-www-config.php'); 
		//$dbase="test_avgAQ";
		$link = mysql_connect($mysql_server,$root_login,$root_pass)or die("Connect Error: ".mysql_error());
		if (! $link)
		die("Couldn't connect to MySQL");
        mysql_select_db($database_id , $link)
		or die("Select DB Error: ".mysql_error());
//////////////////////////////////////////////////////////////////////////////////////////////////

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Check database logs for the existance of the requested project id
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		$result=mysql_query("SELECT proj_code, user_id, DATE_FORMAT(proj_date,'%m/%d/%Y'), proj_time, description from aq_project_log ORDER BY proj_code")or die("There was an error accessing the database ".mysql_error());
		$i=0;
		    echo "<select name=\"project_id6\" id=\"project_id6\"> ";
			echo " <option value=\"\" selected> Choose a Project  </option> ";
		if ($row = mysql_fetch_array($result)) {
		do {
			$pid=$row["proj_code"];
			$proj_str[$i]="Project ID: ".$row["proj_code"].", User ID: ".$row["user_id"].", Setup Date: ".$row[2];
             echo " <option value=\"$pid\"> $proj_str[$i]  </option> ";

		}
		while($row = mysql_fetch_array($result));

		} 
		else{
		
			
			die("No project were found in the database, this is likely a connection error. Contact AMET system adminsitrator <br>".mysql_error());
		}
		  echo "</select> ";		
//////////////////////////////////////////////////////////////////////////////////////////////////


?>

            </p>
            <p align="left"><?php
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//      Connect to Database via user supplied login and pass
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
         include ( '../configure/amet-www-config.php');
                //$dbase="test_avgAQ";
                $link = mysql_connect($mysql_server,$root_login,$root_pass)or die("Connect Error: ".mysql_error());
                if (! $link)
                die("Couldn't connect to MySQL");
        mysql_select_db($database_id , $link)
                or die("Select DB Error: ".mysql_error());
//////////////////////////////////////////////////////////////////////////////////////////////////

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Check database logs for the existance of the requested project id
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                $result=mysql_query("SELECT proj_code, user_id, DATE_FORMAT(proj_date,'%m/%d/%Y'), proj_time, description from aq_project_log ORDER BY proj_code")or die("There was an error accessing the database ".mysql_error());
                $i=0;
                    echo "<select name=\"project_id7\" id=\"project_id7\"> ";
                        echo " <option value=\"\" selected> Choose a Project  </option> ";
                if ($row = mysql_fetch_array($result)) {
                do {
                        $pid=$row["proj_code"];
                        $proj_str[$i]="Project ID: ".$row["proj_code"].", User ID: ".$row["user_id"].", Setup Date: ".$row[2];
             echo " <option value=\"$pid\"> $proj_str[$i]  </option> ";

                }
                while($row = mysql_fetch_array($result));

                }
                else{


                        die("No project were found in the database, this is likely a connection error. Contact AMET system adminsitrator <br>".mysql_error());
                }
                  echo "</select> ";
//////////////////////////////////////////////////////////////////////////////////////////////////

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Monitor / Network and Species Criteria - State, Site ID, RPO Regions, AQ Networks, Species to Plot
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
?>
            </p>
            <table width="800" border="0">
              <tr>
                <td><table width="800" border="1" align="left" cellpadding="10" cellspacing="5">
                    <tr align="center" valign="middle"> 
                      <td colspan="2"> <div align="center" class="style4 style3"><strong><font face="Arial, Helvetica, sans-serif">Monitor / Network and Species 
                            Criteria </font></strong></div></td>
                    </tr>
                    <tr align="center" valign="top" bgcolor="#CCCCCC"> 
                      <td width="396"> <div align="center"> 
                          <p align="left"><span class="style5"><strong><font face="Arial, Helvetica, sans-serif">State</font></strong></span><br>
                            <br>
                            <select name="state">
                              <option value="" selected>Include all states</option>
                              <option value="AL">Alabama</option>
                              <option value="AK">Alaska</option>
                              <option value="AB">Alberta</option>
                              <option value="AS">American Samoa</option>
                              <option value="AZ">Arizona</option>
                              <option value="AR">Arkansas</option>
                              <option value="AA">Armed Forces Americas</option>
                              <option value="AE">Armed Forces Europe</option>
                              <option value="AP">Armed Forces Pacific</option>
                              <option value="BC">British Columbia</option>
                              <option value="CA">California</option>
                              <option value="CO">Colorado</option>
                              <option value="CT">Connecticut</option>
                              <option value="DE">Delaware</option>
                              <option value="DC">District of Columbia</option>
                              <option value="FL">Florida</option>
                              <option value="GA">Georgia</option>
                              <option value="GU">Guam</option>
                              <option value="HI">Hawaii</option>
                              <option value="ID">Idaho</option>
                              <option value="IL">Illinois</option>
                              <option value="IN">Indiana</option>
                              <option value="IA">Iowa</option>
                              <option value="KS">Kansas</option>
                              <option value="KY">Kentucky</option>
                              <option value="LA">Louisiana</option>
                              <option value="ME">Maine</option>
                              <option value="MB">Manitoba</option>
                              <option value="MH">Marshall Islands</option>
                              <option value="MD">Maryland</option>
                              <option value="MA">Massachusetts</option>
							  <option value="MX">Mexico</option>
                              <option value="MI">Michigan</option>
                              <option value="FM">Micronesia</option>
                              <option value="MN">Minnesota</option>
                              <option value="MS">Mississippi</option>
                              <option value="MO">Missouri</option>
                              <option value="MT">Montana</option>
                              <option value="NE">Nebraska</option>
                              <option value="NV">Nevada</option>
                              <option value="NB">New Brunswick</option>
                              <option value="NH">New Hampshire</option>
                              <option value="NJ">New Jersey</option>
                              <option value="NM">New Mexico</option>
                              <option value="NY">New York</option>
                              <option value="NF">Newfoundland</option>
                              <option value="NC">North Carolina</option>
                              <option value="ND">North Dakota</option>
                              <option value="MP">Northern Mariana Islands</option>
                              <option value="NT">Northwest Territory</option>
                              <option value="NS">Nova Scotia</option>
                              <option value="NU">Nunavut</option>
                              <option value="OH">Ohio</option>
                              <option value="OK">Oklahoma</option>
                              <option value="ON">Ontario</option>
                              <option value="OR">Oregon</option>
                              <option value="PW">Palau</option>
                              <option value="PA">Pennsylvania</option>
                              <option value="PE">Prince Edward Island</option>
                              <option value="PR">Puerto Rico</option>
                              <option value="QC">Quebec</option>
                              <option value="RI">Rhode Island</option>
                              <option value="SK">Saskatchewan</option>
                              <option value="SC">South Carolina</option>
                              <option value="SD">South Dakota</option>
                              <option value="TN">Tennessee</option>
                              <option value="TX">Texas</option>
                              <option value="VI">U.S. Virgin Islands</option>
                              <option value="UT">Utah</option>
                              <option value="VT">Vermont</option>
                              <option value="VA">Virginia</option>
                              <option value="WA">Washington</option>
                              <option value="WV">West Virginia</option>
                              <option value="WS">Western Samoa</option>
                              <option value="WI">Wisconsin</option>
                              <option value="WY">Wyoming</option>
                              <option value="YT">Yukon</option>
                            </select>
                            <br>
                            <font face="Arial, Helvetica, sans-serif">Isolate 
                          an evaluation dataset by state<br>
                            <br>
                            </font><strong class="style5 style7">Regional Planning Organization (RPO) Regions</strong> <br>
                            <br>
                            <select name="rpo">
                              <option value="None" selected>None</option>
                              <option value="VISTAS">VISTAS</option>
                              <option value="CENRAP">CENRAP</option>
                              <option value="MANE-VU">MANE-VU</option>
                              <option value="LADCO">LADCO</option>
                              <option value="WRAP">WRAP</option>
                            </select>
                            <br>
                            <font face="Arial, Helvetica, sans-serif">Isolate an evaluation dataset by a regional planning organization</font><br>
</p>
                          </div>
                        <div align="center">
                          <p align="left"><strong class="style5 style7">Principal Component Analysis  (PCA) Regions</strong> <br>
                              <br>
                              <select name="pca">
                                <option value="None" selected>None</option>
                                <option value="Northeast">Northeast (Ozone)</option>
                                <option value="Great_Lakes">Great Lakes (Ozone)</option>
                                <option value="Atlantic">Mid-Atlantic (Ozone)</option>
                                <option value="Southwest">Southwest (Ozone)</option>
								<option value="Northeast2">Northeast (Aerosols)</option>
                                <option value="Great_Lakes2">Great Lakes (Aerosols)</option>
                                <option value="Southeast">Southeast (Aerosols)</option>
                                <option value="Lower_Midwest">Lower Midwest (Aerosols)</option>
                              </select>
                              <br>
                              <font face="Arial, Helvetica, sans-serif">Isolate an evaluation dataset by a regional planning organization</font><br>
                              <br>
                              <a href="images/Ozone_PCA_Regions.PNG">Map of ozone PCA Regions</a><br>
                              <a href="images/Aerosol_PCA_Regions.PNG">Map of aerosol PCA Regions</a></p>
                          <p align="left"><strong class="style5 style7">Climate Regions</strong> <br>
                              <br>
                              <select name="clim_reg">
                                <option value="None" selected>None</option>
                                <option value="Central">Central</option>
                                <option value="ENCentral">East-North Central</option>
                                <option value="Northeast">Northeast</option>
                                <option value="Northwest">Northwest</option>
                                <option value="South">South</option>
                                <option value="Southeast">Southeast</option>
                                <option value="Southwest">Southwest</option>
                                <option value="West">West</option>
                                <option value="WNCentral">West-North Central</option>
                              </select>
                              <br>
                              <font face="Arial, Helvetica, sans-serif">Isolate an evaluation dataset by a climate region</font><br>
                              <br>
                          <p align="left"><strong class="style5 style7">DISCOVER-AQ 4-km and 1-km Windows </strong> <br>
                            <br>
                            <select name="discovaq">
                              <option value="None" selected>None</option>
                              <option value="DISCOVERAQ_4km">4-km Window</option>
                              <option value="DISCOVERAQ_1km">1-km Window</option>
                              <option value="DISCOVERAQ_2km_SJV">2-km Window SJV</option>
                            </select>
                            <br>
                            <br>
                          </p>
                        </div></td>
                      <td width="242"> <div align="left">
                        <p><font face="Arial, Helvetica, sans-serif" class="style5"><strong>Site 
                            ID</strong></font> 
                            <input name="stat_file" type="hidden" <?php echo "value=\"".$_GET['stat_file']."\" ";?>>
                            <br>
                            <br>
                            <input name="stat_id" type="text" id="stat_id2" <?php echo "value=\"".$_GET['stat_id']."\" ";?>>                          
                            <br>
			    <font face="Arial, Helvetica, sans-serif">
                            <?php
                               echo "<a href='./stat_id_find.php?script=querygen_aq&database_id=". $database_id . "'>Go here</a>"; 
                            ?> 
                            to interactively choose a single observations 
                            station or manually enter an id (e.g. WASH1).  Interactive choosing currently does not work for AQ sites.  For time series plot, if Site ID is left blank, all stations for each network will be used.</font></p>
                        <p>
                          <input name="stat_id_file" type="text" id="stat_id_file" value="">
                          <br>
                          <span class="style2">To load a custom site file, enter the location and name of the file above.  The format should be the same as this <a href=./example_stat_file.txt>example</a>. You must also enter &quot;Load_File&quot; as the site name in the top box. </span></p>
                        </div></td>
                    </tr>
                    <tr align="center" valign="top" bgcolor="#CCCCCC">
                      <td width="396" height="748"><div align="left">
                        <span class="style5"><font face="Arial, Helvetica, sans-serif"><strong>AQ Observation Networks</strong></font></span><font face="Arial, Helvetica, sans-serif"><strong><br>
                        </strong>Choose air quality monitoring networks to use.                        </font></p>
                        </div>
                        <div align="left">
                          <p><font face="Arial, Helvetica, sans-serif">
                            <input name="inc_improve" type="checkbox" id="inc_improve" value="y" unchecked>
                            <span class="style8"><strong>IMPROVE</strong> (e.g. SO<sub>4</sub>,NO<sub>3</sub>,PM<sub>2.5</sub>,EC,OC,TC) <br>
                            <input name="inc_csn" type="checkbox" id="inc_csn" value="y">
                            <strong>CSN</strong> (e.g. SO<sub>4</sub>,NO<sub>3</sub>,NH<sub>4</sub>,PM<sub>2.5</sub>,EC,OC,TC)<br>
                            <input name="inc_castnet" type="checkbox" id="inc_castnet" value="y">
                            <strong>CASTNet</strong> (e.g. SO<sub>4</sub>,NO<sub>3</sub>,NH<sub>4</sub>,SO<sub>2</sub>,HNO<sub>3</sub>,TNO<sub>3</sub>) <br>
                            
                            <input name="inc_castnet_hr" type="checkbox" id="inc_castnet_hr" value="y">
                            <strong>CASTNet</strong> <strong>- Hourly</strong> (O<sub>3</sub>, RH, Precip, T, Solor Rad, WSPD, WDIR) <br>
                            <input name="inc_castnet_daily" type="checkbox" id="inc_castnet_daily" value="y">
                            <strong>CASTNet Daily </strong>(1-hr and 8-hr max O<sub>3</sub>) <br>
                            <input name="inc_castnet_drydep" type="checkbox" id="inc_castnet_drydep" value="y">
                            <strong>CASTNet Dry Dep </strong>(SO<sub>4</sub>,NO<sub>3</sub>,NH<sub>4</sub>,HNO<sub>3</sub>,TNO<sub>3</sub>,O<sub>3</sub>,SO<sub>2</sub>) <br>
                            <input name="inc_capmon" type="checkbox" id="inc_capmon" value="y">
                            <strong>CAPMON</strong>                             (SO<sub>4</sub>,NO<sub>3</sub>,NH<sub>4</sub>,HNO<sub>3</sub>,TNO<sub>3</sub>,SO<sub>2</sub>)<br>
                            <input name="inc_naps" type="checkbox" id="inc_naps" value="y">
                            <strong>NAPS - Hourly</strong> (O<sub>3</sub>,NO,NO<sub>2</sub>,NO<sub>X</sub>,SO<sub>2</sub>,PM<sub>2.5</sub>,PM<sub>10</sub>)<br>
                            
                            <input name="inc_nadp" type="checkbox" id="inc_nadp" value="y">
                            <strong>NADP </strong> (e.g. SO<sub>4</sub>,NO<sub>3</sub>,NH<sub>4</sub>,Precip, Cl Ion)<br>
                            <input name="inc_amon" type="checkbox" id="inc_amon" value="y">
                            <strong>AMON</strong> (NH<sub>3</sub>)<br>
                            <font face="Arial, Helvetica, sans-serif">
                            <input name="inc_airmon_dep" type="checkbox" id="inc_airmon_dep" value="y">
                            <strong>AIRMON (Deposition)</strong> (SO<sub>4</sub>,NO<sub>3</sub>,NH<sub>4</sub>,Precip)</font><br>
                            </span><span class="style8">
                            <input name="inc_aqs_hourly" type="checkbox" id="inc_aqs_hourly" value="y">
                            <strong>AQS - Hourly</strong> (e.g. NO,NO<sub>2</sub>,NO<sub>x</sub>,NO<sub>y</sub>,SO<sub>2</sub>,CO,PM<sub>2.5</sub>,O<sub>3</sub>,etc.)<br>
                            <input name="inc_aqs_daily_O3" type="checkbox" id="inc_aqs_daily_O3" value="y">
                            <strong>AQS - Daily O<sub>3</sub> </strong> (1-hr and 8-hr max O<sub>3</sub>)<br>
                            <input name="inc_aqs_daily" type="checkbox" id="inc_aqs_daily" value="y">
                            <strong>AQS - Daily</strong> (e.g. PM<sub>2.5</sub>,PM<sub>10</sub>, and PAMS species) <br>
                            <input name="inc_aqs_daily_oaqps" type="checkbox" id="inc_aqs_daily" value="y">
                            <strong>AQS - Daily OAQPS O<sub>3</sub> </strong> (Various 8-hr max O<sub>3</sub>)<br>
                            <input name="inc_aqs_daily" type="checkbox" id="inc_aqs_daily" value="y">                             
                            <strong>AQS - Daily O<sub>3</sub> (Old name)</strong> Old 1-hr and 8-hr max O<sub>3</sub> network <br>
                            <input name="inc_aqs_daily_pm" type="checkbox" id="inc_aqs_daily_pm" value="y">
                            <strong>AQS - Daily (Old name) </strong> PM<sub>2.5</sub>,PM<sub>10</sub>, and PAMS species network <br>
                            <input name="inc_search" type="checkbox" id="inc_search" value="y">
                            <strong>SEARCH</strong> (e.g. O<sub>3</sub>,CO,SO<sub>2</sub>,NO,HNO<sub>3</sub>,etc.)<br>
                            <input name="inc_search_daily" type="checkbox" id="inc_search_daily" value="y">
                            <strong>SEARCH Daily </strong> (Fine and Coarse Mode Species)<br>
                            <input name="inc_aeronet" type="checkbox" id="inc_aeronet" value="y">
                            <strong>AERONET </strong> (AOD: 340, 380, 440, 500, 675, 870, 1020, 1640)<br>
                            <input name="inc_fluxnet" type="checkbox" id="inc_fluxnet" value="y">
                            <strong>FluxNet </strong> (Soil/Flux variables)<br>
                            <input name="inc_mdn" type="checkbox" id="inc_mdn" value="y">
                            <strong>MDN</strong> (Hg) <br>
                            <font face="Arial, Helvetica, sans-serif">
                            <input name="inc_tox" type="checkbox" id="inc_tox" value="y">
                            <strong>Toxics / HAPs</strong><br>
                            <font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif">
                            <input name="inc_mod" type="checkbox" id="inc_mod" value="y">
                            <strong>Model_Model</strong> </font></font> </font></font></span></p>
                          <p><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><strong>European Networks<br>
                            </strong><font face="Arial, Helvetica, sans-serif">
<input name="inc_admn" type="checkbox" id="inc_admn" value="y">
<span class="style8">ADMN</span> </font></font></font><span class="style8">(SO<sub>4</sub>,NO<sub>3</sub>,NH<sub>4</sub>,Precip, Na Ion, Cl Ion)</span></font><br>
                          <font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif">
                          <input name="inc_aganet" type="checkbox" id="inc_aganet" value="y">
                          <span class="style8"><strong>AGANET</strong></span></font></font></font></font> <span class="style8"><font face="Arial, Helvetica, sans-serif">(HCl, NO<sub>2</sub>, NO<sub>Y</sub>, SO<sub>X</sub>, HNO<sub>3</sub>, SO<sub>2</sub>, Cl, Na)</font></span><br>
                          <font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif">
                          <input name="inc_airbase_hourly" type="checkbox" id="inc_airbase_hourly" value="y">
                          <span class="style8"><strong>AirBase_Hourly</strong></span></font></font></font></font> <span class="style8"><font face="Arial, Helvetica, sans-serif">(NO, NO<sub>2</sub>, NO<sub>X</sub>, SO<sub>2</sub>, CO, PM<sub>2.5</sub>, PM<sub>10</sub>, O<sub>3</sub>)</font></span><br>
                          <font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif">
                          <input name="inc_airbase_daily" type="checkbox" id="inc_airbase_daily" value="y">
                          <span class="style8"><strong>AirBase_Daily</strong></span>
                          </font></font></font></font><span class="style8"><font face="Arial, Helvetica, sans-serif">(NO, NO<sub>2</sub>, NO<sub>X</sub>, SO<sub>2</sub>, CO, PM<sub>2.5</sub>, PM<sub>10</sub>, O<sub>3</sub>)</font></span><br>
                          <font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif">
                          <input name="inc_aurn_hourly" type="checkbox" id="inc_aurn_hourly" value="y">
                          <span class="style8"><strong>AURN_Hourly</strong></span></font></font></font></font> <span class="style8"><font face="Arial, Helvetica, sans-serif">(NO, NO<sub>2</sub>, NO<sub>X</sub>, SO<sub>2</sub>, CO, PM<sub>2.5</sub>, PM<sub>10</sub>, O<sub>3</sub>)</font></span><br>
                          <font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif">
                          <input name="inc_aurn_daily" type="checkbox" id="inc_aurn_daily" value="y">
                          <span class="style8"><strong>AURN_Daily</strong></span> </font></font></font></font><span class="style8"><font face="Arial, Helvetica, sans-serif">(NO, NO<sub>2</sub>, NO<sub>X</sub>, SO<sub>2</sub>, CO, PM<sub>2.5</sub>, PM<sub>10</sub>, O<sub>3</sub>)</font></span><br>
                          <font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif">
                          <input name="inc_emep_hourly" type="checkbox" id="inc_emep_hourly" value="y">
                          <span class="style8"><strong>EMEP_Hourly</strong></span></font></font></font></font> <span class="style8"><font face="Arial, Helvetica, sans-serif">(NO, NO<sub>2</sub>, NO<sub>X</sub>, SO<sub>2</sub>, CO, PM<sub>2.5</sub>, PM<sub>10</sub>, O<sub>3</sub>)</font></span><br>
                          <font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif">
                          <input name="inc_emep_daily" type="checkbox" id="inc_emep_daily" value="y">
                          <span class="style8"><strong>EMEP_Daily</strong></span> </font></font></font></font><span class="style8"><font face="Arial, Helvetica, sans-serif">(NO, NO<sub>2</sub>, NO<sub>X</sub>, SO<sub>2</sub>, CO, PM<sub>2.5</sub>, PM<sub>10</sub>, O<sub>3</sub>)</font></span></p>
                          <p><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><strong>Campaigns<br>
                            </strong><font face="Arial, Helvetica, sans-serif">
<input name="inc_calnex" type="checkbox" id="inc_calnex" value="y">
<span class="style6">CALNEX</span> </font></font></font><span class="style8"></span></font><br>
                          <font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif">
<input name="inc_soas" type="checkbox" id="inc_soas" value="y">
<span class="style6">SOAS</span> </font></font></font><span class="style8"></span></font><br>
                          <font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif">
<input name="inc_special" type="checkbox" id="inc_special" value="y">
<span class="style6">Special</span> </font></font></font><span class="style8"></span></font><br>
                          <font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif">

                        </div></td>
                      <td width="242"><div align="left">
                        <div align="left">
                          <span class="style5"><font face="Arial, Helvetica, sans-serif"><strong>Species to Plot</strong></font></span><font face="Arial, Helvetica, sans-serif"><strong><br>
                          </strong><br>
                          <select name="gas_species" id="gas_species">
                            <option value="" selected></option>
                            <optgroup label="Gas Species">
                               <option value="O3"><font face="Arial, Helvetica, sans-serif">O3 (hourly or daily)</font></option>
                               <option value="O3_1hrmax"><font face="Arial, Helvetica, sans-serif">O3 1-hrmax (daily)</font></option>
                               <option value="O3_8hrmax"><font face="Arial, Helvetica, sans-serif">O3 8-hrmax (daily)</font></option>
                               <option value="O3_1hrmax_9cell"><font face="Arial, Helvetica, sans-serif">O3 1-hrmax 9-cell avg (daily)</font></option>
                               <option value="O3_8hrmax_9cell"><font face="Arial, Helvetica, sans-serif">O3 8-hrmax 9-cell avg (daily)</font></option>
                               <option value="O3_1hrmax_time"><font face="Arial, Helvetica, sans-serif">O3 1-hrmax hour (daily)</font></option>
                               <option value="O3_8hrmax_time"><font face="Arial, Helvetica, sans-serif">O3 8-hrmax hour (daily)</font></option>
                               <option value="W126"><font face="Arial, Helvetica, sans-serif">W126 12H Value (daily)</font></option>
                               <option value="SO2"><font face="Arial, Helvetica, sans-serif">SO2</font></option>
                               <option value="NH3">NH3</option>
                               <option value="HNO3">HNO3</option>
                               <option value="TNO3">TNO3 (NO3+HNO3)</option>
                               <option value="CO"><font face="Arial, Helvetica, sans-serif">CO</font></option>
                               <option value="NO"><font face="Arial, Helvetica, sans-serif">NO</font></option>
                               <option value="NO2"><font face="Arial, Helvetica, sans-serif">NO2</font></option>
                               <option value="NOX"><font face="Arial, Helvetica, sans-serif">NOX</font></option>
                               <option value="NOY"><font face="Arial, Helvetica, sans-serif">NOY</font></option>
                               <option value="H2O2"><font face="Arial, Helvetica, sans-serif">H2O2</font></option>
                               <option value="HOx"><font face="Arial, Helvetica, sans-serif">HOx</font></option>
			       <option value="Acetaldehyde"><font face="Arial, Helvetica, sans-serif">Acetaldehyde</font></option>
                	       <option value="Formaldehyde"><font face="Arial, Helvetica, sans-serif">Formaldehyde</font></option>
			       <option value="Benzene"><font face="Arial, Helvetica, sans-serif">Benzene</font></option>
			       <option value="Ethane"><font face="Arial, Helvetica, sans-serif">Ethane</font></option>
			       <option value="Ethylene"><font face="Arial, Helvetica, sans-serif">Ethylene</font></option>
			       <option value="Isoprene"><font face="Arial, Helvetica, sans-serif">Isoprene</font></option>
			       <option value="Toluene"><font face="Arial, Helvetica, sans-serif">Toluene</font></option>
                            </optgroup>
                            <optgroup label="Met Variables">
                               <option value="SFC_TMP"><font face="Arial, Helvetica, sans-serif">Surface Temperature</font></option>
                               <option value="Dewpoint"><font face="Arial, Helvetica, sans-serif">Dewpoint Temperature</font></option>
                               <option value="precip"><font face="Arial, Helvetica, sans-serif">Precipitation</font></option>
                               <option value="WSPD10"><font face="Arial, Helvetica, sans-serif">10m Wind Speed</font></option>
                               <option value="WDIR10"><font face="Arial, Helvetica, sans-serif">10m Wind Direction</font></option>
                               <option value="RH"><font face="Arial, Helvetica, sans-serif">Relative Humidity</font></option>
                               <option value="PBLH"><font face="Arial, Helvetica, sans-serif">PBL Height</font></option>
 		   	       <option value="Solar_Rad"><font face="Arial, Helvetica, sans-serif">Solar Radiation</font></option>
                               <option value="SRAD_ETA_CLR"><font face="Arial, Helvetica, sans-serif">Clear Sky ETA SolRad</font></option>
                               <option value="SRAD_ETA_ADJ"><font face="Arial, Helvetica, sans-serif">Adjusted ETA SolRad</font></option>
                               <option value="SRAD_BEIS_CLR"><font face="Arial, Helvetica, sans-serif">Clear Sky BEIS SolRad</font></option>
                               <option value="SRAD_BEIS_ADJ"><font face="Arial, Helvetica, sans-serif">Adjusted BEIS SolRad</font></option>
                               <option value="CLDTRANS"><font face="Arial, Helvetica, sans-serif">Cloud Transmisivity</font></option>
			    </optgroup>
                            <optgroup label="AOD Variables">
			       <option value="AOD_340"><font face="Arial, Helvetica, sans-serif">AOD 340</font></option>
			       <option value="AOD_380"><font face="Arial, Helvetica, sans-serif">AOD 380</font></option>
			       <option value="AOD_440"><font face="Arial, Helvetica, sans-serif">AOD 440</font></option>
			       <option value="AOD_500"><font face="Arial, Helvetica, sans-serif">AOD 500</font></option>
			       <option value="AOD_675"><font face="Arial, Helvetica, sans-serif">AOD 675</font></option>
			       <option value="AOD_870"><font face="Arial, Helvetica, sans-serif">AOD 870</font></option>
			       <option value="AOD_1020"><font face="Arial, Helvetica, sans-serif">AOD 1020</font></option>
			       <option value="AOD_1640"><font face="Arial, Helvetica, sans-serif">AOD 1640</font></option>
			       <option value="H2OCOL"><font face="Arial, Helvetica, sans-serif">Column H2O</font></option>
                            </optgroup>
                            <optgroup label="Soil/Flux Variables"> 
                               <option value="USTAR"><font face="Arial, Helvetica, sans-serif">USTAR</font></option>
                               <option value="Soil_Heat_Flx"><font face="Arial, Helvetica, sans-serif">Soil Heat Flux</font></option>
                               <option value="Sens_Heat_Flx"><font face="Arial, Helvetica, sans-serif">Sensible Heat Flux</font></option>
                               <option value="Ltnt_Heat_Flx"><font face="Arial, Helvetica, sans-serif">Latent Heat Flux</font></option>
                               <option value="Soil_H2O_Cntn"><font face="Arial, Helvetica, sans-serif">Soil Water Conc.</font></option>
                               <option value="Soil_Tmp"><font face="Arial, Helvetica, sans-serif">Soil Temperature</font></option>
                               <option value="SW_Dwn"><font face="Arial, Helvetica, sans-serif">Shortwave Down</font></option>
                               <option value="SW_Diff_Dwn"><font face="Arial, Helvetica, sans-serif">Shortwave Diff. Down</font></option>
                               <option value="SW_Up"><font face="Arial, Helvetica, sans-serif">Shortwave Up</font></option>
                               <option value="LW_Dwn"><font face="Arial, Helvetica, sans-serif">Longwave Down</font></option>
                               <option value="LW_Up"><font face="Arial, Helvetica, sans-serif">Longwave Up</font></option>
                               <option value="SW_Net"><font face="Arial, Helvetica, sans-serif">Shortwave Net</font></option>
                            </optgroup>
                          </select>
                          <br>
                            Choose Gas/Met/AOD/Flux Species</font></p>
                          <p><font face="Arial, Helvetica, sans-serif">
                            <select name="part_species" id="part_species">
                              <option value="" selected></option>
                              <optgroup label="PM2.5 Species">
                              <option value="SO4">SO4</option>
                              <option value="NO3">NO3</option>
                              <option value="NH4">NH4</option>
                              <option value="EC">EC</option>
                              <option value="OC">OC</option>
                              <option value="TC">TC</option>
			      <option value="other">PM Other</option>
			      <option value="ncom">NCOM</option>
                              <option value="Cl">Cl Ion</option>
                              <option value="Na">Na Ion</option>
                              <option value="PM_TOT">PM2.5 Mass (I+J)</option>
			      <option value="PM_FRM">PM2.5 FRM Equiv. (I+J)</option>
			      <optgroup label="PM Species (Sharp Cutoff)">
                              <option value="PM25_SO4">PM2.5 SO4</option>
                              <option value="PM25_NO3">PM_2.5 NO3</option>
                              <option value="PM25_NH4">PM_2.5 NH4</option>
                              <option value="PM25_TOT">PM_2.5 Total Mass</option>
			      <option value="PM25_FRM">PM_2.5 FRM Equiv.</option>
                              <option value="PM25_EC">PM_2.5 EC</option>
                              <option value="PM25_OC">PM_2.5 OC</option>
                              <option value="PM25_TC">PM_2.5 TC</option>
                              <option value="PM25_Cl">PM_2.5 Cl Ion</option>
                              <option value="PM25_Na">PM_2.5 Na Ion</option>
			      <optgroup label="PM Course Species">
                              <option value="PMC_SO4">PM_Coarse SO4</option>
                              <option value="PMC_NO3">PM_Coarse NO3</option>
                              <option value="PMC_NH4">PM_Coarse NH4</option>
                              <option value="PMC_TOT">PM_Coarse Total Mass</option>
                              <option value="PMC_Cl">PM_Coarse Cl Ion</option>
                              <option value="PMC_Na">PM_Coarse Na Ion</option>
			      <option value="PM10">PM10 Mass</option>
			      <optgroup label="PM2.5 Soil Species">
			      <option value="Na">Sodium (Na)</option>
                              <option value="Cl">Clorine (Cl)</option>
                              <option value="Fe">Iron (Fe)</option>
                              <option value="Al">Aluminium (Al)</option>
                              <option value="Si">Silicon (Si)</option>
                              <option value="Ti">Titanium (Ti)</option>
                              <option value="Ca">Calcium (Ca)</option>
                              <option value="Mg">Magnesium (Mg)</option>
                              <option value="K">Potassium (K)</option>
                              <option value="Mn">Mangenese (Mn)</option>
                              <option value="soil">Soil (IMPROVE Eqn.)</option>
                            </select>
                            <br>
                            Choose Particle Species                            </font></p>
                          <p><font face="Arial, Helvetica, sans-serif">
                          <select name="dep_species" id="dep_species">
                            <option value="" selected></option>
			    <optgroup label="Wet Deposition (NADP)">
                            <option value="SO4_dep">SO4 (wet dep)</option>
                            <option value="SO4_conc">SO4 (wet conc)</option>
                            <option value="NO3_dep">NO3 (wet dep)</option>
                            <option value="NO3_conc">NO3 (wet conc)</option>
                            <option value="NH4_dep">NH4 (wet dep)</option>
                            <option value="NH4_conc">NH4 (wet conc)</option>
                            <option value="Cl_dep">Cl Ion (wet dep)</option>
                            <option value="Cl_conc">Cl Ion (wet conc)</option>
                            <option value="CA_dep">Ca (wet dep)</option>
                            <option value="CA_conc">Ca (wet conc)</option>
                            <option value="MG_dep">Mg (wet dep)</option>
                            <option value="MG_conc">Mg (wet conc)</option>
                            <option value="K_dep">K (wet dep)</option>
                            <option value="K_conc">K (wetconc)</option>
                            <option value="NA_dep">Na (wetdep)</option>
                            <option value="NA_conc">Na (wet conc)</option>
                            <optgroup label="Mercury Wet Deposition (MDN)">
			    <option value="HGconc">Hg (wet conc)</option>
                            <option value="HGdep">Hg (wet dep)</option>
                            <optgroup label="Dry Deposition (CASTNET)">
                            <option value="SO4_ddep">SO4 (dry dep)</option>
                            <option value="NO3_ddep">NO3 (dry dep)</option>
                            <option value="NH4_ddep">NH4 (dry dep)</option>
                            <option value="HNO3_ddep">HNO3 (dry dep)</option>
                            <option value="TNO3_ddep">TNO3 (dry dep)</option>
                            <option value="O3_ddep">O3 (dry dep)</option>
                            <option value="SO2_ddep">SO2 (dry dep)</option>
                          </select>
                          <br>
Choose Deposition Species <br>
                            </font><font face="Arial, Helvetica, sans-serif">
                              </font><br>
                            <select name="tox_species" id="tox_species">
                              <option value= ""SELECTED></option>
                              <option value="Acrolein">Acrolein</option>
                              <option value="Acrylonitrile">Acrylonitrile</option>
                              <option value="ALD2">ALD2</option>
                              <option value="Arsenic">Arsenic</option>
                              <option value="Benzene">Benzene</option>
                              <option value="BR2_C2_12">BR2_C2_12</option>
                              <option value="Butadiene13">Butadiene13</option>
                              <option value="Cadmium_PM10">Cadmium_PM10</option>
                              <option value="Cadmium_PM25">Cadmium_PM25</option>
                              <option value="Carbontet">Carbontet</option>
                              <option value="Chromium_PM10">Chromium_PM10</option>
                              <option value="Chromium_PM25">Chromium_PM25</option>
                              <option value="CHCL3">CHCL3</option>
                              <option value="CL_ETHE">CL_ETHE</option>
                              <option value="CL2">CL2</option>
                              <option value="CL2_C2_12">CL2_C2_12</option>
                              <option value="CL2_ME">CL2_ME</option>
                              <option value="CL3_ETHE">CL3_ETHE</option>
                              <option value="CL4_ETHE">CL4_ETHE</option>                                                        
                              <option value="CL4_Ethane1122">CL4_Ethane1122</option>
                              <option value="CR_III_PM10">CR_III_PM10</option>
                              <option value="CR_III_PM25">CR_III_PM25</option>
                              <option value="CR_VI_PM10">CR_VI_PM10</option>
                              <option value="CR_VI_PM25">CR_VI_PM25</option>
                              <option value="Dichlorobenzene">Dichlorobenzene</option>
                              <option value="Formaldehyde">Formaldehyde</option>
                              <option value="Lead_PM10">Lead_PM10</option>
                              <option value="Lead_PM25">Lead_PM25</option>
                              <option value="Manganese_PM10">Manganese_PM10</option>
                              <option value="Manganese_PM25">Manganese_PM25</option>
                              <option value="MEOH">MEOH</option>
                              <option value="MXYL">MXYL</option>
                              <option value="Nickel_PM10">Nickel_PM10</option>
                              <option value="Nickel_PM25">Nickel_PM25</option>
                              <option value="OXYL">OXYL</option>
                              <option value="Propdichloride">Propdichloride</option>
                              <option value="PXYL">PXYL</option>
                              <option value="Toluene">Toluene</option>
                            </select>
                            <br>
                            Choose Toxics/HAP
                            Species<br>
                            </p>
                            <p>&nbsp;</p>
                           Create a custom species list. Currently only applies to Soccer Goal plot script. Acceptable format is comma separated species in quotes. For example: &quot;SO4&quot;,&quot;NO3&quot;,&quot;NH4&quot;. Names must match names used in database. A mapping of the AMET database names, which must be used below, can be found here <a href=./AMET_Species_Name_Mapping.txt>AMET Species Name Mapping</a><br>
                            <font face="Arial, Helvetica, sans-serif">
                              <input name="custom_species" type="text" id="custom_species" size="35" maxlength="20000">
                              </font><br>
                            <font face="Arial, Helvetica, sans-serif">                              </font></p>
                          </p>
                        </div>
                        </div></td>
                    </tr>
                  </table></td>
              </tr>
<!-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: -->
<!-- End Monitor / Network and Species Criteria Section -->
<!-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: -->

<!-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: -->
<!-- Date and Time Criteria
<!-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: -->
<td>&nbsp;</td>
<tr> <br>
<td><table width="800" border="1" align="left" cellpadding="10" cellspacing="5">
<tr align="center" valign="middle"> 
<td height="47" colspan="2"> <div align="center" class="style4 style3"><strong>  <font face="Arial, Helvetica, sans-serif">Date and Time Criteria</font></strong></div></td>
</tr>
<tr align="center" valign="middle" bgcolor="#CCCCCC"> 
<td colspan="2"> <div align="center"> 
<table width="100%" border="1" bordercolor="#CCCCCC">
<tr align="center"> 
<td colspan="3"><font color="#666666" face="Arial, Helvetica, sans-serif" class="style5"><strong>Start Date</strong></font></td>
<td colspan="3"><font color="#666666" face="Arial, Helvetica, sans-serif" class="style5"><strong>End Date</strong></font></td>
</tr>
<tr align="center" valign="middle"> 
<td><strong><font face="Arial, Helvetica, sans-serif"> 

<?php
	$dm1=$a8;		// set start date
	$dm2=$a9;		// set end date
	$miny=$dm1[6].$dm1[7].$dm1[8].$dm1[9];
	$maxy=$dm2[6].$dm2[7].$dm2[8].$dm2[9];
	echo " <select name=\"ys\" id=\"select15\" >";
	echo "	<option SELECTED></option>";
    $minyear=1990;
	$year=2020;	
	$y=1;$select="";
	while($y>0){
	   if($year == $miny) {
	      $select="SELECTED"; 
	   }
	   if($year == $minyear){
	      $y=-1;
	   }  
	   echo "  <option value=\"".$year."\" $select>".$year."</option>";
	   $select="";
	   $year=$year-1;
	}
 	echo "               </select>											";
?>

<br>
Year </font></strong></td>
<td><strong><font face="Arial, Helvetica, sans-serif"> 
<?php
	$dm1=$a8;		// set start date
	$dm2=$a9;		// set end date
	$minm=$dm1[0].$dm1[1];
	$maxm=$dm2[0].$dm2[1];  
	$miny=$dm1[6].$dm1[7].$dm1[8].$dm1[9];
	$maxy=$dm2[6].$dm2[7].$dm2[8].$dm2[9]; 
	$num_years=$maxy-$miny;
	if ($num_years > 0) {
	   $minm=sprintf("%02d",1);
           $maxm=sprintf("%02d",12);
	}
	//list($yy1,$yy2,$yy3,$yy4,$mm1,$mm2,$dd1,$dd2) = split('[]', $_POST['max_date']);
	echo " <select name=\"ms\" id=\"select5\" >";
	echo "	<option SELECTED></option>";
	$month=$minm;
	$m=1;$select="SELECTED";
	while($m>0){
	if($month == $maxm){$m=-1;} 
	    echo "<option value=\"".$month."\" $select>".$month."</option>";
	//	echo "  <option value=\"".$month."\">".$month."</option>";
		$select="";
		//if ($month < 10) {
		$month=sprintf("%02d",$month+1);
		if ($month == 13){$month=sprintf("%02d",1);}
		//}
	}
 	echo "               </select>											";
?>
<br>
Month </font></strong></td>
<td><strong><font face="Arial, Helvetica, sans-serif"> 

<select name="ds" id="select6">
	<option value="1" selected>01</option>
	<option value="2">02</option>
        <option value="3">03</option>
        <option value="4">04</option>
        <option value="5">05</option>
        <option value="6">06</option>
        <option value="7">07</option>
        <option value="8">08</option>
        <option value="9">09</option>
        <option value="10">10</option>
        <option value="11">11</option>
        <option value="12">12</option>
        <option value="13">13</option>
        <option value="14">14</option>
        <option value="15">15</option>
        <option value="16">16</option>
        <option value="17">17</option>
        <option value="18">18</option>
        <option value="19">19</option>
        <option value="20">20</option>
        <option value="21">21</option>
        <option value="22">22</option>
        <option value="23">23</option>
        <option value="24">24</option>
        <option value="25">25</option>
        <option value="26">26</option>
        <option value="27">27</option>
        <option value="28">28</option>
        <option value="29">29</option>
        <option value="30">30</option>
        <option value="31">31</option>
</select>
<br>
Day </font></strong></td>
<td><strong><font face="Arial, Helvetica, sans-serif">
  <?php
	//$y1=2;$y2=0;$y3=0;$y4=4;
	//$dm1=$_GET['min_date'];
	//$dm2=$_GET['max_date'];
	$dm1=$a8;		// set start date
	$dm2=$a9;		// set end date
	$miny=$dm1[6].$dm1[7].$dm1[8].$dm1[9];
	$maxy=$dm2[6].$dm2[7].$dm2[8].$dm2[9];
	//$miny=2000;
	echo " <select name=\"ye\" id=\"select15\" >";
	echo "	<option SELECTED></option>";
	$miny=1990;
	$year=2020;
	$y=1;$select="";
	while($y>0){
		if($year == $miny){
			$y=-1;
		}
		if ($year == $maxy) {
		   $select="SELECTED";
		} 
		echo "                 <option value=\"".$year."\" $select>".$year."</option>			";
		$select="";
		$year=$year-1;
	 }
	 echo "               </select>											";
?>
  <br>
Year </font></strong></td>
<td><strong><font face="Arial, Helvetica, sans-serif"> 

<?php
	// $dm1=$_GET['min_date'];
	// $dm2=$_GET['max_date'];
	$dm1=$a8;		// set start date
	$dm2=$a9;		// set end date
	$minm=$dm1[0].$dm1[1];
	$maxm=$dm2[0].$dm2[1];
	$miny=$dm1[6].$dm1[7].$dm1[8].$dm1[9];
	$maxy=$dm2[6].$dm2[7].$dm2[8].$dm2[9]; 
	$num_years=$maxy-$miny;
	if ($num_years > 0) {
	   $minm=sprintf("%02d",1);
           $maxm=sprintf("%02d",12);
	}
	//list($yy1,$yy2,$yy3,$yy4,$mm1,$mm2,$dd1,$dd2) = split('[]', $_POST['max_date']);
	echo " <select name=\"me\" id=\"select7\" >";
	echo "	<option SELECTED></option>";
	$month=$minm;
	$m=1;$select="";
	while($m>0){
	if($month == $maxm){
		$m=-1;
		$select="SELECTED";
	} 
	    echo "<option value=\"".$month."\" $select>".$month."</option>";
	//	echo "  <option value=\"".$month."\">".$month."</option>";
		$select="";
		//if ($month < 10) {
		$month=sprintf("%02d",$month+1);
		if ($month == 13){$month=sprintf("%02d",1);}
		//}
	}
 	echo "               </select>											";
?>
<br>
Month </font></strong></td>
<td><strong><font face="Arial, Helvetica, sans-serif"> 

<select name="de" id="select8">
	<option value="1">01</option>
        <option value="2">02</option>
        <option value="3">03</option>
        <option value="4">04</option>
        <option value="5">05</option>
        <option value="6">06</option>
        <option value="7">07</option>
        <option value="8">08</option>
        <option value="9">09</option>
        <option value="10">10</option>
        <option value="11">11</option>
        <option value="12">12</option>
        <option value="13">13</option>
        <option value="14">14</option>
        <option value="15">15</option>
        <option value="16">16</option>
        <option value="17">17</option>
        <option value="18">18</option>
        <option value="19">19</option>
        <option value="20">20</option>
        <option value="21">21</option>
        <option value="22">22</option>
        <option value="23">23</option>
        <option value="24">24</option>
        <option value="25">25</option>
        <option value="26">26</option>
        <option value="27">27</option>
        <option value="28">28</option>
        <option value="29">29</option>
        <option value="30">30</option>
        <option value="31" selected>31</option>
</select>

<br>
Day </font></strong></td>
</tr>
</table>
</div></td>
</tr>
<tr align="center" valign="top" bgcolor="#CCCCCC">
  <td>    <p align="left" class="style5"><span class="style5 style7"><font face="Arial, Helvetica, sans-serif"><strong>Set Hour Range </strong></font></span></p>
    <div align="left"><span class="style5 style7"><strong><font face="Arial, Helvetica, sans-serif"><span class="style10">Start Hour</span>              
      <select name="start_hour" id="start_hour">
                <option ></option>
                <option value="00" selected>12AM</option>
                <option value="01">1AM</option>
                <option value="02">2AM</option>
                <option value="03">3AM</option>
                <option value="04">4AM</option>
                <option value="05">5AM</option>
                <option value="06">6AM</option>
                <option value="07">7AM</option>
                <option value="08">8AM</option>
                <option value="09">9AM</option>
                <option value="10">10AM</option>
                <option value="11">11AM</option>
                <option value="12">12PM</option>
                <option value="13">1PM</option>
                <option value="14">2PM</option>
                <option value="15">3PM</option>
                <option value="16">4PM</option>
                <option value="17">5PM</option>
                <option value="18">6PM</option>
                <option value="19">7PM</option>
                <option value="20">8PM</option>
                <option value="21">9PM</option>
                <option value="22">10PM</option>
                <option value="23">11PM</option>
              </select>
&nbsp;&nbsp;&nbsp;<span class="style10">End Hour</span>
  <select name="end_hour" id="end_hour">
        <option ></option>
                 <option value="00">12AM</option>
                <option value="01">1AM</option>
                <option value="02">2AM</option>
                <option value="03">3AM</option>
                <option value="04">4AM</option>
                <option value="05">5AM</option>
                <option value="06">6AM</option>
                <option value="07">7AM</option>
                <option value="08">8AM</option>
                <option value="09">9AM</option>
                <option value="10">10AM</option>
                <option value="11">11AM</option>
                <option value="12">12PM</option>
                <option value="13">1PM</option>
                <option value="14">2PM</option>
                <option value="15">3PM</option>
                <option value="16">4PM</option>
                <option value="17">5PM</option>
                <option value="18">6PM</option>
                <option value="19">7PM</option>
                <option value="20">8PM</option>
                <option value="21">9PM</option>
                <option value="22">10PM</option>
                <option value="23" selected>11PM</option>
  </select>
  <br>
      </font></strong></span>    </div>
    <div align="left"><font face="Arial, Helvetica, sans-serif">Use this option to isolate a range of hours to include in the analysis. Hours are in LST. The default is to include all hours of the day in the analysis. </font></div>

  <span class="style5 style7"><strong><font face="Arial, Helvetica, sans-serif">    </font></strong></span></td>
  <td><div align="left">
  <font face="Arial, Helvetica, sans-serif" class="style5"><strong>Select Parameter Occurrence (PO) Code </strong></font><br>
  <br>
  <select name="POCode" id="POCode">
            <option value="All" selected>All</option>
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
            <option value="4">4</option>
            <option value="5">5</option>
            <option value="6">6</option>
            <option value="7">7</option>
            <option value="8">8</option>
            <option value="9">9</option>
            <option value="10">10</option>
            <option value="11">11</option>
            <option value="12">12</option>
  </select>
  <br>
  <font face="Arial, Helvetica, sans-serif">Use this option
  to isolate the data by a specific parameter occurrence code. Most observations use a parameter occurrence code of 1.</font></p>
  </div>    </td>
</tr>

<tr align="center" valign="top" bgcolor="#CCCCCC"> 
<td width="281"> <div align="left">
  <class="style5"><font face="Arial, Helvetica, sans-serif"><strong>Seasonal Analysis</strong></font></p>
</div>
<div align="left"><font face="Arial, Helvetica, sans-serif"> 
<select name="season" id="select12">
	<option SELECTED></option>
        <option value="winter">Winter (Dec,Jan,Feb)</option>
        <option value="spring">Spring (Mar,Apr,May)</option>
        <option value="summer">Summer (Jun,Jul,Aug)</option>
        <option value="fall">Autumn (Sep,Oct,Nov)</option>
</select>
<br>
Use this option to isolate evaluation data by a particular 
season of the year.  When using this option, set the dates above
to cover the entire season or year.  <em>All months in the season chosen
must fall within the dates set above.</em></font></div></td>
<td width="50%"> <div align="left">
  <font face="Arial, Helvetica, sans-serif" class="style5"><strong>Individual Monthly Analysis </strong></font><br>
  <br>
  <select name="ind_month" id="ind_month">
	    <option ></option>
            <option value="01">Jan</option>
            <option value="02">Feb</option>
            <option value="03">Mar</option>
     	    <option value="04">Apr</option>
	    <option value="05">May</option>
	    <option value="06">Jun</option>
	    <option value="07">Jul</option>
	    <option value="08">Aug</option>
	    <option value="09">Sep</option>
	    <option value="10">Oct</option>
	    <option value="11">Nov</option>
	    <option value="12">Dec</option>
  </select>
  <br>
  <font face="Arial, Helvetica, sans-serif">Use this option 
  to isolate a data set by an individual month of the year. When using this option, set the dates above to cover at least the entire month. <em>It is preferrable to set the date range above to the whole year and then select an individual month from the list above.</em></font></p>
</div></td>
</tr>
<tr align="center" valign="top" bgcolor="#CCCCCC"> 
<td width="281" height="213"> <div align="left"> 

<span class="style5"><font face="Arial, Helvetica, sans-serif"><strong>Remove Negative Values</strong></font><font face="Arial, Helvetica, sans-serif"></font></span><font face="Arial, Helvetica, sans-serif"><br>
<p><font face="Arial, Helvetica, sans-serif">
<select name="remove_negatives" id="remove_negatives">
<option value="y" selected>yes</option>
<option value="n">no</option>
</select>
<br>
Select "yes" to remove negative values from the analysis. All values less than zero are removed from the analysis. Obviously this can be a problem when plotting species with acceptable negative values (e.g. temperature).</font><br>

<td width="50%"> <div align="left">
<div align="left">
  <span class="style5"><font face="Arial, Helvetica, sans-serif"><strong>Temporal Averaging</strong></font><font face="Arial, Helvetica, sans-serif"></font></span><font face="Arial, Helvetica, sans-serif"><br>
    <br>
    <select name="data_averaging" id="select3">
      <option value="n" selected>All Available Pairs</option>
      <option value="h">Hour Average</option>
      <option value="d">Daily Average</option>
	  <option value="m">Monthly Average</option>
	  <option value="ym">Year/Month Average</option>
      <option value="s">Seasonal Average</option>
	  <option value="a">Annual Average</option>
    </select>
    <br>
        The default option is to use all available observations.  Alternatively, monthly average values can be used for the analysis. Currently, this option really only applies to the various scatterplots that can be generated. Most of the programs that can be run use all the available pairs, and some programs require hourly data to be used.</font>            </p>
  
  <input name="use_avg_stats" type="checkbox" id="use_avg_stats" value="y" unchecked>
  <font face="Arial, Helvetica, sans-serif">Use average values for statistic calculations (<em>note this option only applies to scatter plots</em>) </font> </p>
  </div>
<div align="left">
<p>&nbsp;</p>
</div>
</div></td>
</tr>
</table>
<br></td>
</tr>
<td>&nbsp;</td>
  
<tr> 
<td><table width="800" border="1" align="left" cellpadding="10" cellspacing="5">
<tr align="center" valign="middle"> 
<td height="41" colspan="2"> <div align="center" class="style4 style3"><strong>  <font face="Arial, Helvetica, sans-serif">Geography Criteria</font></strong></div></td>
</tr>

<tr align="center" valign="top" bgcolor="#CCCCCC"> 
<td width="320"> <div align="left">
<class="style5"><font face="Arial, Helvetica, sans-serif"><strong>Site Landuse (AQS only) </strong></font></p>
</div>
<div align="left">
<p><font face="Arial, Helvetica, sans-serif"> 
<select name="loc_setting" id="select21">
<option ></option>
	<option value="RURAL">Rural</option>
        <option value="SUBURBAN">Suburban</option>
        <option value="URBAN AND CENTER CITY">Urban</option>
</select>
<br> 
Isolate AQS evaluation data by whether the site location setting is described as rural, suburban or urban.  Only applies to AQS sites.</font></p>
</div></td>
<td width="320"> <div align="left"> 
<font face="Arial, Helvetica, sans-serif" class="style5"><strong>Latitude-Longitude 
</strong></font><br>
<br>
<font face="Arial, Helvetica, sans-serif"><strong>Lat</strong>
 between 
 <input name="lat1" type="text" id="lat1" size="10">
 &amp;
 <input name="lat2" type="text" id="lat2" size="10">
 deg</font></p>
 <p><font face="Arial, Helvetica, sans-serif"><strong>Lon 
 </strong>between 
 <input name="lon1" type="text" id="lon1" size="10">
 &amp;
 <input name="lon2" type="text" id="lon2" size="10">
 deg</font><br>
<br>
<font face="Arial, Helvetica, sans-serif">Specify bounds on the evaluation data to examine. Latitudes must be given south to north, and Longitudes must be given west to east.</font></p>
</div></td>
</tr>
</table></td>
</tr>
<tr> 
<td>&nbsp;</td>
</tr>
<tr> 
<td><table width="800" border="1" align="left" cellpadding="10" cellspacing="5">
<tr align="center" valign="middle"> 
<td colspan="2"> <div align="center" class="style4 style3"><strong>  <font face="Arial, Helvetica, sans-serif">Data Format and Plot Specifications</font></strong></div></td>
</tr>
<tr align="center" valign="top" bgcolor="#CCCCCC"> 
<td height="204"> <div align="left"> 
<span class="style5"><font face="Arial, Helvetica, sans-serif"><strong>&quot;Soccergoal&quot; Plot / &quot;Bugle&quot; Plot Options</strong></font></span><font face="Arial, Helvetica, sans-serif"><strong><br>
</strong></font><br>
<font face="Arial, Helvetica, sans-serif">
	<select name="soccerplot_opt" id="select14">
		<option value=1 selected>NMB vs. NME</option>
		<option value=2>FB vs. FE</option>
		<option value=3>NMdnB vs. NMdnE</option>
	</select>
</font>Select statistics to plot.<br>
</p>
</div></td>
<td> <div align="left"> 
<font face="Arial, Helvetica, sans-serif" class="style5"><strong>AMET Plots Axis Options </strong></font><br>
<br>
<font face="Arial, Helvetica, sans-serif">x axis min: </font><font face="Arial, Helvetica, sans-serif">
<input name="x_axis_min" type="text" id="x_axis_min" size="5">
</font><font face="Arial, Helvetica, sans-serif"> x axis max: </font><font face="Arial, Helvetica, sans-serif">
<input name="x_axis_max" type="text" id="x_axis_max" size="5">
</font></p>
<p><font face="Arial, Helvetica, sans-serif">y axis min: 
<input name="y_axis_min" type="text" id="y_axis_min" size="5">
 y axis max: 
  <input name="y_axis_max" type="text" id="y_axis_max" size="5">
</font></p>
<p><font face="Arial, Helvetica, sans-serif">bias_y axis min:
<input name="bias_y_axis_min" type="text" id="bias_y_axis_min" size="5">
 bias y axis max:
  <input name="bias_y_axis_max" type="text" id="bias_y_axis_max" size="5">
</font></p>
<p><font face="Arial, Helvetica, sans-serif"> density zlim max:
    <input name="density_zlim" type="text" id="density_zlim" size="5">
    density num bins: 
    <input name="num_dens_bins" type="text" id="num_dens_bins" size="5">
<br>
   </font></p>
   skill plot max limit:
  <input name="max_limit" type="text" id="max_limit" size="5" value=70> 
    <br>
  </font></p>
  Enter a value above to set the x and y axes limits for several plots (scatter, box, stacked bar, time series, etc). The density values only apply to the density scatter plot. Leave the value blank to use the value calculated by the script. The skill plot max limit only applies to the skill scatterplot.</font></p>
</div></td>
</tr>
<tr align="center" valign="top" bgcolor="#CCCCCC">
  <td><div align="left">
      <span class="style5"><font face="Arial, Helvetica, sans-serif"><strong>Scatter Plot Options</strong></font></span><font face="Arial, Helvetica, sans-serif"><strong><br>
        </strong></font><br>
        <input name="conf_line" type="checkbox" id="conf_line" value="y" unchecked>
        Include 2-to-1 Confidence Lines <br>
        <input name="pca_flag" type="checkbox" id="pca_flag" value="y" unchecked> 
        Use PCA Regions<br>
         <input name="bin_by_mod" type="checkbox" id="bin_by_mod" value="y" unchecked>
        Bin by Model Values (binned bias plot only)<br>
        <br>
        <em><font face="Arial, Helvetica, sans-serif"><strong>Statistics</strong></font></em> (include up to 5) </p>
      <p>
        <input name="stat1" type="checkbox" id="stat1" value="y" unchecked>Number of Pairs<br>
        <input name="stat2" type="checkbox" id="stat2" value="y" unchecked>Mean Obs<br>
		<input name="stat3" type="checkbox" id="stat3" value="y" unchecked>Mean Model<br>
		<input name="stat4" type="checkbox" id="stat4" value="y" checked>Index of Agreement<br>
        <input name="stat5" type="checkbox" id="stat5" value="y" unchecked>Correlation<br>
		<input name="stat6" type="checkbox" id="stat6" value="y" unchecked>R Squared<br>
        <input name="stat7" type="checkbox" id="stat7" value="y" unchecked>RMSE<br>
        <input name="stat8" type="checkbox" id="stat8" value="y" checked>Systematic RMSE<br>
        <input name="stat9" type="checkbox" id="stat9" value="y" checked>Unsystematic RMSE<br>
		<input name="stat10" type="checkbox" id="stat10" value="y" unchecked>
		Norm Mean Bias (NMB, %) <br>
        <input name="stat11" type="checkbox" id="stat11" value="y" unchecked>
        Norm Mean Error (NME, %) <br>
        <input name="stat12" type="checkbox" id="stat12" value="y" unchecked>
        Norm Median Bias (NMdnB, %) <br>
        <input name="stat13" type="checkbox" id="stat13" value="y" unchecked>
        Norm Median Error (NMdnE, %) <br>	
        <input name="stat14" type="checkbox" id="stat14" value="y" unchecked>
        Mean Bias (MB) <br>
        <input name="stat15" type="checkbox" id="stat15" value="y" unchecked>
        Mean Error (ME) <br>
        <input name="stat16" type="checkbox" id="stat16" value="y" checked>
        Median Bias (MdnB) <br>
        <input name="stat17" type="checkbox" id="stat17" value="y" checked>
        Median Error (MdnE) <br>
        <input name="stat18" type="checkbox" id="stat18" value="y" unchecked>
        Fractional Bias (FB, %) <br>
        <input name="stat19" type="checkbox" id="stat19" value="y" unchecked>
        Fractional Error (FE, %)</p>
      <p><font face="Arial, Helvetica, sans-serif"><em><strong>Plot Colors</strong></em> <br>
        <br>
Color 1 </font><font face="Arial, Helvetica, sans-serif">
 <select name="network1_color" id="network1_color">
  <option value=blue>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4>Drk Green</option>
  <option value=orange3>Orange</option>
  <option value=brown>Brown</option>
  <option value=purple>Purple</option>
  <option value=grey60 selected>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>

<select name="network1_color2" id="network1_color2">
  <option value=blue>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4>Drk Green</option>
  <option value=orange3>Orange</option>
  <option value=brown>Brown</option>
  <option value=purple>Purple</option>
  <option value=grey60 selected>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>
</font><br>
<font face="Arial, Helvetica, sans-serif">Color 2</font><font face="Arial, Helvetica, sans-serif">
  <select name="network2_color" id="network2_color">
  <option value=blue>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red selected>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4>Drk Green</option>
  <option value=orange2>Orange</option>
  <option value=brown>Brown</option>
  <option value=purple>Purple</option>
  <option value=grey60>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>
<select name="network2_color2" id="network2_color2">
  <option value=blue>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red selected>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4>Drk Green</option>
  <option value=orange2>Orange</option>
  <option value=brown>Brown</option>
  <option value=purple>Purple</option>
  <option value=grey60>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>
<br>
</font><font face="Arial, Helvetica, sans-serif">Color 3</font><font face="Arial, Helvetica, sans-serif">
  <select name="network3_color" id="network3_color">
  <option value=blue selected>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4>Drk Green</option>
  <option value=orange2>Orange</option>
  <option value=brown>Brown</option>
  <option value=purple>Purple</option>
  <option value=grey60>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>
</font><font face="Arial, Helvetica, sans-serif">
<select name="network3_color2" id="network3_color2">
  <option value=blue selected>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4>Drk Green</option>
  <option value=orange2>Orange</option>
  <option value=brown>Brown</option>
  <option value=purple>Purple</option>
  <option value=grey60>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>
</font><br>
  <font face="Arial, Helvetica, sans-serif">Color 4</font><font face="Arial, Helvetica, sans-serif">
  <select name="network4_color" id="network4_color">
  <option value=blue>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4 selected>Drk Green</option>
  <option value=orange2>Orange</option>
  <option value=brown>Brown</option>
  <option value=purple>Purple</option>
  <option value=grey60>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>
</font><font face="Arial, Helvetica, sans-serif">
<select name="network4_color2" id="network4_color2">
  <option value=blue>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4 selected>Drk Green</option>
  <option value=orange2>Orange</option>
  <option value=brown>Brown</option>
  <option value=purple>Purple</option>
  <option value=grey60>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>
</font><br>
<font face="Arial, Helvetica, sans-serif">Color 5
<select name="network5_color" id="network5_color">
  <option value=blue>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3 selected>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4>Drk Green</option>
  <option value=orange2>Orange</option>
  <option value=brown>Brown</option>
  <option value=purple>Purple</option>
  <option value=grey60>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>
<select name="network5_color2" id="network5_color2">
  <option value=blue>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3 selected>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4>Drk Green</option>
  <option value=orange2>Orange</option>
  <option value=brown>Brown</option>
  <option value=purple>Purple</option>
  <option value=grey60>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>
</font><br>
<font face="Arial, Helvetica, sans-serif">Color 6
  <select name="network6_color" id="network6_color">
  <option value=blue>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4>Drk Green</option>
  <option value=orange2 selected>Orange</option>
  <option value=brown>Brown</option>
  <option value=purple>Purple</option>
  <option value=grey60>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>
  <select name="network6_color2" id="network6_color2">
  <option value=blue>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4>Drk Green</option>
  <option value=orange2 selected>Orange</option>
  <option value=brown>Brown</option>
  <option value=purple>Purple</option>
  <option value=grey60>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>
</font><br>
<font face="Arial, Helvetica, sans-serif">Color 7 
  <select name="network7_color" id="network7_color">
  <option value=blue>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4>Drk Green</option>
  <option value=orange2>Orange</option>
  <option value=brown selected>Brown</option>
  <option value=purple>Purple</option>
  <option value=grey60>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>
  <select name="network7_color2" id="network7_color2">
  <option value=blue>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4>Drk Green</option>
  <option value=orange2>Orange</option>
  <option value=brown selected>Brown</option>
  <option value=purple>Purple</option>
  <option value=grey60>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>
</font><br>
<font face="Arial, Helvetica, sans-serif">Color 8 
  <select name="network8_color" id="network8_color">
  <option value=blue>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4>Drk Green</option>
  <option value=orange2>Orange</option>
  <option value=brown>Brown</option>
  <option value=purple selected>Purple</option>
  <option value=grey60>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>
  <select name="network8_color2" id="network8_color2">
  <option value=blue>Blue</option>
  <option value=skyblue2>Lgt Blue</option>
  <option value=red>Red</option>
  <option value=yellow>Yellow</option>
  <option value=yellow3>Drk Yellow</option>
  <option value=green1>Lgt Green</option>
  <option value=green>Green</option>
  <option value=green4>Drk Green</option>
  <option value=orange2>Orange</option>
  <option value=brown>Brown</option>
  <option value=purple selected>Purple</option>
  <option value=grey60>Lgt Grey</option>
  <option value=grey45>Med Grey</option>
  <option value=grey25>Drk Grey</option>
  <option value=black>Black</option>
  <option value=transparent>None</option>
</select>
<p><font face="Arial, Helvetica, sans-serif"><em><strong>Plot Symbols</strong></em> <br>
        <br>
Network 1 </font><font face="Arial, Helvetica, sans-serif">
 <select name="network1_symbol" id="network1_symbol">
  <option value=16 selected>Circle</option>
  <option value=17>Triangle</option>
  <option value=15>Square</option>
  <option value=18>Diamond</option>
  <option value=11>Star</option>
  <option value=8>Burst</option>
  <option value=4>X</option>
</select>
</font><br>
Network 2 </font><font face="Arial, Helvetica, sans-serif">
 <select name="network2_symbol" id="network2_symbol">
  <option value=16>Circle</option>
  <option value=17 selected>Triangle</option>
  <option value=15>Square</option>
  <option value=18>Diamond</option>
  <option value=11>Star</option>
  <option value=8>Burst</option>
  <option value=4>X</option>
</select>
</font><br>
Network 3 </font><font face="Arial, Helvetica, sans-serif">
 <select name="network3_symbol" id="network3_symbol">
  <option value=16>Circle</option>
  <option value=17>Triangle</option>
  <option value=15 selected>Square</option>
  <option value=18>Diamond</option>
  <option value=11>Star</option>
  <option value=8>Burst</option>
  <option value=4>X</option>
</select>
</font><br>
Network 4 </font><font face="Arial, Helvetica, sans-serif">
 <select name="network4_symbol" id="network4_symbol">
  <option value=16>Circle</option>
  <option value=17>Triangle</option>
  <option value=15>Square</option>
  <option value=18 selected>Diamond</option>
  <option value=11>Star</option>
  <option value=8>Burst</option>
  <option value=4>X</option>
</select>
</font></br>
Network 5 </font><font face="Arial, Helvetica, sans-serif">
 <select name="network5_symbol" id="network5_symbol">
  <option value=16>Circle</option>
  <option value=17>Triangle</option>
  <option value=15>Square</option>
  <option value=18>Diamond</option>
  <option value=11 selected>Star</option>
  <option value=8>Burst</option>
  <option value=4>X</option>
</select>
</font></br>
Network 6 </font><font face="Arial, Helvetica, sans-serif">
 <select name="network6_symbol" id="network6_symbol">
  <option value=16>Circle</option>
  <option value=17>Triangle</option>
  <option value=15>Square</option>
  <option value=18>Diamond</option>
  <option value=11>Star</option>
  <option value=8 selected>Burst</option>
  <option value=4>X</option>
</select>
</font></br>
Network 7 </font><font face="Arial, Helvetica, sans-serif">
 <select name="network7_symbol" id="network7_symbol">
  <option value=16>Circle</option>
  <option value=17>Triangle</option>
  <option value=15>Square</option>
  <option value=18>Diamond</option>
  <option value=11>Star</option>
  <option value=8>Burst</option>
  <option value=4 selected>X</option>
</select>
</font></p>
  <td><div align="left">
      <span class="style5"><font face="Arial, Helvetica, sans-serif"><strong>AMET Model Eval Stats/Plots</strong></font></span><br>
          <br>
          <font face="Arial, Helvetica, sans-serif">
          <input name="run_info_text" type="checkbox" id="run_info_text" value="y" checked>
Include run info text on plots<br>
          </font><font face="Arial, Helvetica, sans-serif"><br>
        <input name="zeroprecip" type="checkbox" id="zeroprecip" value="n" unchecked>
        Do not include zero precipitation observations in analysis.  Only use when precipitation data are available (e.g. NADP, AIRMON)</font> </p>
      <p><font face="Arial, Helvetica, sans-serif">
        <input name="inc_valid" type="checkbox" id="inc_valid" value="y" unchecked>
Include all valid samples in wet deposition analysis.  Only use for NADP and AIRMON networks. </font></p>
      <p><font face="Arial, Helvetica, sans-serif"><strong><font face="Arial, Helvetica, sans-serif">
      <input name="coverage" type="text" id="coverage" title="Coverage" size="3" maxlength="3" value=75>
      </font></strong>Enter minimum completeness (as a %) for site specific calculations (e.g. at least 3 of 4 obs = 75%).  Note that this criteria does not apply to bulk domain computed statistics, only site specific calculations </font>. </p>
      <p><font face="Arial, Helvetica, sans-serif"><strong><font face="Arial, Helvetica, sans-serif">
        <input name="num_obs_limit" type="text" id="num_obs_limit" title="Num_Obs_Limit" size="5" maxlength="5" value=1>
      </font></strong>Enter minimum number of observations required for site statistics calculations (default is set at 1 which would include all sites that meet the completeness criteria above)</font></p>
      <p><font face="Arial, Helvetica, sans-serif"><br>
        </font><font face="Arial, Helvetica, sans-serif"><strong>
          Stacked Bar Chart Options </strong></font></p>
      <p><font face="Arial, Helvetica, sans-serif">
      <input name="inc_FRM_adj" type="checkbox" id="inc_FRM_adj" value="y" checked>
      </font>Include CSN FRM adjustment <br>
      <font face="Arial, Helvetica, sans-serif">
      <input name="use_median" type="checkbox" id="use_median" value="y" checked>
      </font>Use median instead of mean <br>
      <br>
  <p><span class="style5"><font face="Arial, Helvetica, sans-serif"><strong>Boxplot Options</strong></font></span><font face="Arial, Helvetica, sans-serif"><strong> <br>
  </strong></font><br>
  <input name="inc_whiskers" type="checkbox" id="inc_whiskers" value="y" unchecked>
  Include whiskers on boxplot<br>
  <input name="inc_ranges" type="checkbox" id="inc_ranges" value="y" checked>
  Include 25-75% quartile ranges on boxplot<br>
  <input name="inc_median_lines" type="checkbox" id="inc_median_lines" value="y" unchecked>
  Include median lines on boxplot<br>
  <input name="remove_mean" type="checkbox" id="remove_mean" value="y" unchecked>
  Subtract mean from Hourly Boxplot or Spatial Plot scripts </p>
  <p><span class="style5"><font face="Arial, Helvetica, sans-serif"><strong>Time Series Plot Options </strong></font></span><font face="Arial, Helvetica, sans-serif"><strong> <br>
  </strong>
     <p><font face="Arial, Helvetica, sans-serif">Choose which averaging function to plot on time series<strong><br>
     <select name="avg_func_opt" id="avg_func_opt">
       <option value="mean" selected>Mean</option>
       <option value="median">Median</option>
       <option value="sum">Sum</option>
     </select>
   </font></p>
  </strong></font>
  <input name="inc_legend" type="checkbox" id="inc_legend" value="y" checked>
  Include legend on time series plots <br>
  <input name="inc_points" type="checkbox" id="inc_points" value="y" checked>
  Include points on time series plots <br>
  <input name="use_var_mean" type="checkbox" id="use_var_mean" value="y" unchecked>
  Subtract period mean from time series plots <br><br>
  <font face="Arial, Helvetica, sans-serif">
  <input name="obs_per_day_limit" type="text" id="obs_per_day_limit" size="4" value="0">
  </font>
  Specify minimum limit on number of records per time unit (e.g. day) to include </p>
  <font face="Arial, Helvetica, sans-serif">
  <input name="line_width_val" type="text" id="line_width_val" size="4" value="1">
  </font>
  Specify time series line widths </p>
  <div></td>

</tr>

<tr align="center" valign="top" bgcolor="#CCCCCC">
   <td><div align="left">
   <span class="style5"><font face="Arial, Helvetica, sans-serif"><strong>Overlay File Options</strong></font></span><font face="Arial, Helvetica, sans-serif"><strong><br>
     <br> 
     </strong>
     <select name="overlay_opt" id="select14">
       <option value=1 selected>Hourly</option>
       <option value=2>Daily</option>
       <option value=3>1hr Max (use with hourly data)</option>
       <option value=4>8hr Max (use with hourly data)</option>
     </select>
   </font></p>
   <p><font face="Arial, Helvetica, sans-serif">Currently, observation overlay files can be generated from hourly or daily data. If using hourly data (e.g. AQS hourly), choose hourly below. If using daily (e.g. AQS 8hr max) choose daily. You can also use hourly data (e.g. CASTNet hourly) to create daily values by selecting either 1hr or 8hr max below. <strong><br>
     </strong></font><br>
   </p>
   </div></td>

<td><div align="left">
<font face="Arial, Helvetica, sans-serif" class="style5"><strong>Add Custom MYSQL Query </strong></font><br>
  <br>
  <font face="Arial, Helvetica, sans-serif">
  <input name="custom_query" type="text" id="axis_limit" size="50" maxlength="20000">
  <br>
  <br>
  Use the box above to create your own custom MYSQL query. The query should begin with 'and' and contain valid MYSQL query commands. This is an advanced option for users familiar with database structure and queries. An example of a correctly formatted statement is:</font></p>
<p><font face="Arial, Helvetica, sans-serif"><strong>
      and d.SO4_ob &gt; 5 and d.SO4_ob &lt; 10 </strong></font></p>
<p><em><font face="Arial, Helvetica, sans-serif">The d refers to the main data table where the site compare data are stored. </font></em></p>
</div></td>
</tr>
<tr align="center" valign="top" bgcolor="#CCCCCC">
  <td colspan="2" align="left"><p><strong>Spatial Plot Options</strong></p>
    <p>Number of Intervals<font face="Arial, Helvetica, sans-serif">:
      &nbsp;
      <input name="num_ints" type="text" id="num_ints" size="5" value="">
    </font>&nbsp;&nbsp;RMSE Range Max:&nbsp;&nbsp;<font face="Arial, Helvetica, sans-serif"> &nbsp;&nbsp;&nbsp;
    <input name="rmse_range_max" type="text" id="rmse_range_max" size="5" value="">
    </font><br>
      % Error Range Max:<font face="Arial, Helvetica, sans-serif">
  <input name="perc_error_max" type="text" id="perc_error_max" size="5" value="">
  </font> &nbsp;&nbsp;&nbsp;Abs. Error Range Max:<font face="Arial, Helvetica, sans-serif">
  <input name="abs_error_max" type="text" id="abs_error_max" size="5" value="">
  <br>
  </font>% Range Min: <font face="Arial, Helvetica, sans-serif"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <input name="perc_range_min" type="text" id="perc_range_min" size="5" value="">
  </font>&nbsp;&nbsp;&nbsp;% Range Max:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <input name="perc_range_max" type="text" id="perc_range_max" size="5" value="">
  <br>
      Abs. Range Min:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <input name="abs_range_min" type="text" id="abs_range_min" size="5" value="">
  &nbsp;&nbsp;&nbsp;Abs. Range Max:
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input name="abs_range_max" type="text" id="abs_range_max" size="5" value="">
        <br>
      Difference Min:
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input name="diff_range_min" type="text" id="diff_range_min" size="5" value="">
  &nbsp;&nbsp;&nbsp;Difference Max:<font face="Arial, Helvetica, sans-serif"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <input name="diff_range_max" type="text" id="diff_range_max" size="5" value="">
  <br>
  </font><font face="Arial, Helvetica, sans-serif"><br>
</font>This options applies to either the stats and plots program, in which a percent range would be entered, or the spatial plot program, in which case a concentrations range would be entered.</p>
    <p>Plot using greyscale 
      <input name="greyscale" type="checkbox" id="greyscale" value="y" unchecked>
      <br>
      Include counties on map
      <input name="inc_counties" type="checkbox" id="inc_counties" value="y" checked>
      <br>
      Symbol size factor (default is one)
      <input name="symbsizfac" type="text" id="symbsizfac" size="4" value="1">
    </p></td>
  </tr>
<tr align="center" valign="top" bgcolor="#CCCCCC"> 
<td width="281" align="left"><p><span class="style5"><font face="Arial, Helvetica, sans-serif"><strong>Custom title (applied to all plots)</strong></font></span><font face="Arial, Helvetica, sans-serif"><strong> <br>
</strong></font><br>
<input name="custom_title" type="text" id="custom_title" size="50" maxlength="20000">

<td width="50%"> <div align="left">
<div align="left">
  <font face="Arial, Helvetica, sans-serif"><strong><span class="style4 style5 style3">Choose Program to Run</span><br>
  </strong></font></p>
</div>
<div align="left"><font face="Arial, Helvetica, sans-serif">
  <select name="run_program" id="select4">
    <option value="" selected><font face="Arial, Helvetica, sans-serif">Choose AMET Script to Execute</font></option>
    <optgroup label="Scatter Plots">
    <option value="AQ_Scatterplot.R"><font face="Arial, Helvetica, sans-serif">Multiple Networks Model/Ob Scatterplot (select stats only)</font></option>
    <option value="AQ_Scatterplot_single.R"><font face="Arial, Helvetica, sans-serif">Single Network Model/Ob Scatterplot (includes all stats)</font></option>
    <option value="AQ_Scatterplot_density.R"><font face="Arial, Helvetica, sans-serif">Density Scatterplot (single run, single network)</font></option>
    <option value="AQ_Scatterplot_mtom.R"><font face="Arial, Helvetica, sans-serif">Model/Model Scatterplot (multiple networks)</font></option>
    <option value="AQ_Scatterplot_percentiles.R"><font face="Arial, Helvetica, sans-serif">Scatterplot of Percentiles (single network, single run)</font></option>
    <option value="AQ_Scatterplot_skill.R"><font face="Arial, Helvetica, sans-serif">Ozone Skill Scatterplot (single network, mult runs)</font></option>
    <option value="AQ_Scatterplot_bins.R"><font face="Arial, Helvetica, sans-serif">Binned MB & RMSE Scatterplots (single net., mult. run)</font></option>
    <option value="AQ_Scatterplot_multi.R"><font face="Arial, Helvetica, sans-serif">Multi Simulation Scatter plot (single network, mult runs)</font></option>
    <option value="AQ_Scatterplot_soil.R"><font face="Arial, Helvetica, sans-serif">Soil Scatter plot (single network, mult runs)</font></option>
    </optgroup>
    <optgroup label="Time Series Plots">
    <option value="AQ_Timeseries.R"><font face="Arial, Helvetica, sans-serif">Time-series Plot (single network, multiple sites averaged)</font></option>
    <option value="AQ_Timeseries_multi_networks.R"><font face="Arial, Helvetica, sans-serif">Multi-Network Time-series Plot (mult. net., single run)</font></option>
    <option value="AQ_Timeseries_MtoM.R"><font face="Arial, Helvetica, sans-serif">Model-to-Model Time-series Plot (single net., multi run)</font></option>
    <option value="AQ_Monthly_Stat_Plot.R"><font face="Arial, Helvetica, sans-serif">Year-long Monthly Statistics Plot (single network)</font></option>
    </optgroup>
    <optgroup label="Spatial Plots">
    <option value="AQ_Stats_Plots.R"><font face="Arial, Helvetica, sans-serif">Species Statistics and Spatial Plots (multi networks)</font></option>
    <option value="AQ_Plot_Spatial.R"><font face="Arial, Helvetica, sans-serif">Spatial Plot (multi networks)</font></option>
    <option value="AQ_Plot_Spatial_MtoM.R"><font face="Arial, Helvetica, sans-serif">Model/Model Diff Spatial Plot (multi network, multi run)</font></option>
    <option value="AQ_Plot_Spatial_Diff.R"><font face="Arial, Helvetica, sans-serif">Spatial Plot of Bias/Error Difference (multi network, multi run)</font></option>
    <option value="AQ_Plot_Spatial_Ratio.R"><font face="Arial, Helvetica, sans-serif">Ratio Spatial Plot to total PM2.5 (multi network, multi run)</font></option>
    </optgroup>
    <optgroup label="Box Plots">
    <option value="AQ_Boxplot.R"><font face="Arial, Helvetica, sans-serif">Boxplot (single network, multi run)</font></option>
    <option value="AQ_Boxplot_DofW.R"><font face="Arial, Helvetica, sans-serif">Day of Week Boxplot (single network, multiple runs)</font></option>
    <option value="AQ_Boxplot_Hourly.R"><font face="Arial, Helvetica, sans-serif">Hourly Boxplot (single network, multiple runs)</font></option>
    <option value="AQ_Boxplot_MDA8.R"><font face="Arial, Helvetica, sans-serif">8hr Average Boxplot (single network, hourly data, can be slow)</font></option>
    <option value="AQ_Boxplot_Roselle.R"><font face="Arial, Helvetica, sans-serif">Roselle Boxplot (single network, multiple simulations)</font></option>
    </optgroup>
    <optgroup label="Stacked Bar Plots">
    <option value="AQ_Stacked_Barplot.R"><font face="Arial, Helvetica, sans-serif">PM2.5 Stacked Bar Plot (CSN or IMPROVE, multi run)</font></option>
    <option value="AQ_Stacked_Barplot_AE6.R"><font face="Arial, Helvetica, sans-serif">PM2.5 Stacked Bar Plot AE6 (CSN or IMPROVE, multi run)</font></option>
    <option value="AQ_Stacked_Barplot_soil.R"><font face="Arial, Helvetica, sans-serif">Soil Stacked Bar Plot (CSN or IMPROVE,multi run)</font></option>
    <option value="AQ_Stacked_Barplot_soil_multi.R"><font face="Arial, Helvetica, sans-serif">Soil Stacked Bar Plot Multi (CSN and IMPROVE,single run)</font></option>
    <option value="AQ_Stacked_Barplot_panel.R"><font face="Arial, Helvetica, sans-serif">Multi-Panel Stacked Bar Plot (full year data required)</font></option>
    <option value="AQ_Stacked_Barplot_panel_AE6.R"><font face="Arial, Helvetica, sans-serif">Multi-Panel Stacked Bar Plot AE6 (full year data)</font></option>
    <option value="AQ_Stacked_Barplot_panel_AE6_multi.R"><font face="Arial, Helvetica, sans-serif">Multi-Panel, Mulit Run Stacked Bar Plot AE6 (full year data)</font></option>
    </optgroup>
    <optgroup label="Misc Scripts">
    <option value="AQ_Raw_Data.R"><font face="Arial, Helvetica, sans-serif">Create raw data csv file (single network, single simulation)</font></option>
    <option value="AQ_Soccerplot.R"><font face="Arial, Helvetica, sans-serif">"Soccergoal" plot (multiple networks)</font></option>
    <option value="AQ_Bugleplot.R"><font face="Arial, Helvetica, sans-serif">"Bugle" plot (multiple networks)</font></option>
    <option value="AQ_Histogram.R"><font face="Arial, Helvetica, sans-serif">Histogram (single network/species only)</font></option>
    <option value="AQ_Temporal_Plots.R"><font face="Arial, Helvetica, sans-serif">CDF, Q-Q, Taylor Plots (single network, multi run)</font></option>
	</optgroup>
	<optgroup label="Experimental Scripts (may not work correctly)">
	<option value="AQ_Overlay_File.R"><font face="Arial, Helvetica, sans-serif">Create PAVE/VERDI Obs Overlay File (hourly/daily data only)</font></option>
	<option value="AQ_Scatterplot_log.R"><font face="Arial, Helvetica, sans-serif">Log-Log Model/Ob Scatterplot (multiple networks)</font></option>
	<option value="AQ_Spectal_Analysis.R"><font face="Arial, Helvetica, sans-serif">Spectal Analysis (single network, single run, experimental)</font></option>
	<option value="AQ_Plot_Spatial_Ratio.R"><font face="Arial, Helvetica, sans-serif">PM Ratio Spatial Plot (multi network, single run)</font></option>
  </select>
  <br>
<br>
Choose which program to run to create specific stats and figures. Note that some programs require certain temporal data (e.g. hourly, monthly). For information regarding each of the programs, <a href="./script_info.php">click here</a>. </font></div>
</div>
<p>&nbsp;</p>
</div></td>
</tr>
</table></td>
</tr>
<tr> 
<td><div align="center"><font face="Arial, Helvetica, sans-serif"><strong> 
<input name="submit" type="submit" id="submit" value="Run Program">
</strong></font></div></td>
</tr>
</table>
<blockquote> 
   <blockquote> 
      <p align="left">&nbsp;</p>
   </blockquote>
</blockquote>
</form> 
</blockquote>
</blockquote>
</div>
<blockquote> 
   <p align="left">&nbsp;</p>
</blockquote>
<p>&nbsp;</p>
<!-- InstanceEndEditable --></td>
              </tr>
              <tr> 
                <td valign="TOP"><hr width="70%" color="#0000CC"> 
            </table></TD>
        </TR>
      </TABLE></TD>
  </TR>
  <TR> 
    <TD background="Templates/images/blkbottom.gif"> <DIV align="center"> 
        <P><A href="http://www.snakeyewebtemplates.com" target="_blank" class="type1"><BR>
          &nbsp;&nbsp; </A></P>
      </DIV></TD>
  </TR>
</TABLE>
</BODY>
<!-- InstanceEnd --></HTML>
