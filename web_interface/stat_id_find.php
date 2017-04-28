<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><!-- InstanceBegin template="/Templates/amet2.dwt" codeOutsideHTMLIsLocked="false" -->
<HEAD>
<!-- #BeginEditable "doctitle" --> 
<TITLE>Atmospheric Model Evaluation Tool</TITLE>
<!-- #EndEditable --> 
<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<LINK rel="stylesheet" href="file:///C|/Documents%20and%20Settings/kappel/Desktop/general.css" type="text/css">
<style type="text/css">
<!--
@import url(file:///C|/Documents%20and%20Settings/kappel/Desktop/generalie.css);
.style1 {font-family: Broadway, "Brush Script"}
-->
</style>
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_jumpMenu(targ,selObj,restore){ //v3.0
  eval(targ+".location='"+selObj.options[selObj.selectedIndex].value+"'");
  if (restore) selObj.selectedIndex=0;
}
//-->
</script>
</HEAD>
<BODY bgcolor="#000000" text="#000000">
<TABLE width="100%" border="0" cellspacing="0" cellpadding="0">
  <TR> 
    <TD background="file:///C|/Documents%20and%20Settings/kappel/Desktop/images/images_03.jpg" valign="TOP"> <TABLE border="0" cellspacing="0" cellpadding="0" width="647">
        <TR> 
          <TD width="594" height="53" background="file:///C|/Documents%20and%20Settings/kappel/Desktop/images/header_02.jpg" class="companyname">&nbsp;</TD>
          <TD background="file:///C|/Documents%20and%20Settings/kappel/Desktop/images/images_03.jpg" width="53"><IMG src="file:///C|/Documents%20and%20Settings/kappel/Desktop/images/images_03.jpg" alt="" name="spacer" width="53" height="53" id="spacer"></TD>
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
                  <h1 class="generic"><font color="#0066CC" size="5">Surface Observations Site Utility</font></h1>
                  <p>
 <?php 
	 if (!$_POST['zoomed']){
	    echo "<form action=\"stat_id_find.php\" method=\"post\" name=\"regionchoose\"> ";
        echo "<font color=\"#000000\">Point and click on map to choose a search region.</font> <br>";

		echo "<input name=\"pix\" type=\"image\" border=\"0\" src=\"gifs/usa.png\"> <br>";
		echo "<input name=\"zoomed\" type=\"hidden\" value=\"1\" id=\"zoomed\"> ";
		echo "<input name=\"script\" type=\"hidden\" value=\"".$_GET['script']."\" id=\"zoomed\"> ";
        echo "<input name=\"database_id\" type=\"hidden\" value=\"".$_GET['database_id']."\" id=\"zoomed\"> ";
		echo "</form>";
	 }
 ?>
 <?php 
	if ($_POST['zoomed'] == 1){
/////////////////////////////////////////////// 
include ( '../configure/amet-www-config.php'); 
$database_id=                   $_POST['database_id'];
///////////////////////////////////////////////
			$llat=20;
			$ulat=55;
			$wlon=-130;
			$elon=-60;
			$pixX=638;
			$pixY=384;
			$zoom=4;
			$latpp=($ulat-$llat)/$pixY;
			$lonpp=-1*($wlon-$elon)/$pixX;
			
			$latc=$llat+$latpp*($pixY-$_POST['pix_y']);
			$lonc=$wlon+$lonpp*$_POST['pix_x'];
			
			echo "Your approximate coordinates <br>Latitude: ".sprintf("%8.2f",$latc)."  Longitude: ".sprintf("%8.2f",$lonc)." <br>";
			$pid = (rand()%1000000);
			$l[0]="# STAT_ID_FIND.R Input file 		\n";
  			$l[1]="latc<-$latc 						\n";
  			$l[2]="lonc<- $lonc 					\n";
  			$l[3]="zoom<- $zoom 					\n";
  			$l[4]="fignum<- $pid 					\n";
			$f = fopen("./cache/stat_id.input", "w+");
			$i=0;
			while ($i<10) {
//   			echo $l[$i]."<br>";
				fwrite($f, $l[$i]);
				$i=$i+1;
			}
			fclose($f); 
    putenv("LD_LIBRARY_PATH=$R_proj_lib");
	putenv("R_LIBS=$R_lib");
	putenv("R_HOME=$R_dir");
	$output=exec("$R_script ./stat_id_find.R \"$database_id\" > ./cache/r_spatial.out");

     echo "$output <p>";			
///		Form to find Surface Observation Sites
		echo "<form action=\"stat_id_find.php \" method=\"post\" name=\"stationchoose\"> ";
        echo "<font color=\"#000000\">Point and click on map to choose a surface observation site, after specifing a serach radius (km).</font> <br>";
///		Search Radius List Box
 		echo "<select name=\"radius\" id=\"radius\">		";
 		echo "<option value=\"5\">5 km</option>				";
 		echo "<option value=\"10\">10 km</option>			";
  		echo "<option value=\"20\" >20 km</option>	";
 		echo "<option value=\"36\">36 km</option>			";
 		echo "<option value=\"48\" selected>48 km</option>			";
 		echo "<option value=\"75\">75 km</option>			";
 		echo "<option value=\"100\">100 km</option>			";
 		echo "<option value=\"200\">200 km</option>			";
 		echo "<option value=\"300\">300 km</option>			";
 		echo "<option value=\"500\">500 km</option>			";
 		echo "        </select>							";
		echo "<p>&nbsp;</p> ";
///		Interactive Image, Form Input
		echo "<input name=\"pix\" type=\"image\" border=\"0\" src=\"./cache/statmap.$pid.png\"> <br>";
		echo "<input name=\"zoomed\" type=\"hidden\" value=\"2\" id=\"zoomed\"> ";
	////////////////////////////////////////////////////////////////
	// 			Open timeseries template file
	 $f = fopen("./cache/scoords.dat", "r");
	 	$i=0;
		while (!feof($f)) {
   			$l[$i] = fgets($f,1000);
			$i=$i+1;
		}
		$nl=$i;
		fclose($f);
		$h=explode(" ", $l[0]);
		$lon1=$h[0];$lon2=$h[1];$lat1=$h[2];$lat2=$h[3];
	////////////////////////////////////////////////////////////////
		echo "<input name=\"lat1\" type=\"hidden\" value=\"$lat1\" id=\"zoomed\"> ";
		echo "<input name=\"lat2\" type=\"hidden\" value=\"$lat2\" id=\"zoomed\"> ";
		echo "<input name=\"lon1\" type=\"hidden\" value=\"$lon1\" id=\"zoomed\"> ";
		echo "<input name=\"lon2\" type=\"hidden\" value=\"$lon2\" id=\"zoomed\"> ";
		echo "<input name=\"database_id\" type=\"hidden\" value=\"$database_id\" id=\"zoomed\"> ";
		echo "<input name=\"script\" type=\"hidden\" value=\"".$_POST['script']."\" id=\"zoomed\"> ";
		echo "</form>";

	
	}
 ?>
 <?php 
	if ($_POST['zoomed'] == 2){
    /////////////////////////////////////////////// 
      include ( '../configure/amet-www-config.php'); 
      include ( '../configure/amet-lib.php'); 
	  //$database_id=                   $_POST['database_id'];
    ///////////////////////////////////////////////
			$llat=$_POST['lat1'];
			$ulat=$_POST['lat2'];
			$wlon=$_POST['lon1'];
			$elon=$_POST['lon2'];
			$database_id=$_POST['database_id'];
			$pixX=700;
			$pixY=541;
			$zoom=3;
			$latpp=($ulat-$llat)/$pixY;
			$lonpp=-1*($wlon-$elon)/$pixX;
			
			$latc=$llat+$latpp*($pixY-$_POST['pix_y']);
			$lonc=$wlon+$lonpp*$_POST['pix_x'];
			
			echo "Your approximate coordinates <br>Latitude: ".sprintf("%8.2f",$latc)."  Longitude: ".sprintf("%8.2f",$lonc)."<br>";

////////////////////////////////////////////
//		MYSQL Connection to find observations close to specified coordinates
		$link = mysql_connect($http_server,$root_login,$root_pass) or die("Connect Error: ".mysql_error());
		if (! $link)
		die("Couldn't connect to MySQL");
        mysql_select_db($database_id , $link)
		or die("Select DB Error: ".mysql_error());
		
		$result=mysql_query("SELECT stat_id,stat_name,network,lat,lon,elevation,state from site_metadata ")or die("There was an error accessing the database ".mysql_error());
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;;;::::
	//	OPEN station list file that is used to add multiple station to any query
		$pid = (rand()%1000000);
		//$pid2 = $_POST['pid'];
		$stat_list_file="stat_list.$pid.dat";
		$f = fopen("./cache/$stat_list_file", "w+");
			print "$dist ";

		echo "<form name=\"jumptoscript\"> ";
		echo "<select name=\"station\" id=\"station\" onChange=\"MM_jumpMenu('parent',this,0)\"> ";
        echo " <option value=\"\" SELECTED> Choose observation from this list </option> ";
        echo " <option value=\"".$_POST['script'].".php?stat_id=Selected_Sites&stat_file=$stat_list_file\" > Include all these sites in the analysis </option> ";
		if ($row = mysql_fetch_array($result)) {
		do {
			$dist=distance($row["lat"],$row["lon"],$latc,$lonc,"K");
			if ($dist <= $_POST['radius']) {
			    $proj_str[$i]="Obs ID: ".$row["stat_id"]." -- ".$row["network"]." -- ".$row["stat_name"]." --- ".sprintf("%8.2f",$dist)." km from coordinates above";
                echo " <option value=\"".$_POST['script'].".php?stat_id=".$row["stat_id"]."&stat_file=$stat_list_file\" $select> $proj_str[$i]  </option> ";
				fwrite($f,$row["stat_id"]."\n");
			}	
		}
		while($row = mysql_fetch_array($result));

		} 
		else{
			die("No project were found in the database, this is likely a connection error. Contact AMET system adminsitrator <br>".mysql_error());
		}
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;;;::::
		  fclose($f); 
          echo " <option value=\"\" ></option> ";
		  echo "</select> ";
		  echo " </form>";
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;;;::::	
		}	
 ?>
 </p>
                  <!-- InstanceEndEditable --></td>
              </tr>
              <tr> 
                <td valign="TOP"><hr width="70%" color="#0000CC"> 
                  <p align="center"><b><a href="file:///C|/Documents%20and%20Settings/kappel/Desktop/amet.php">Home</a> 
                    &nbsp;<img src="file:///C|/Documents%20and%20Settings/kappel/Desktop/images/bullet.gif" width="10" height="10" border="0"> 
                    &nbsp;<a href="file:///C|/Documents%20and%20Settings/kappel/Desktop/dbasesetup.php">New Project</a> &nbsp;<img src="file:///C|/Documents%20and%20Settings/kappel/Desktop/images/bullet.gif" width="10" height="10" border="0"> 
                    &nbsp;<a href="file:///C|/Documents%20and%20Settings/kappel/Desktop/met-utils.php">Meteorological Analysis</a> &nbsp;<img src="file:///C|/Documents%20and%20Settings/kappel/Desktop/images/bullet.gif" width="10" height="10" border="0"> 
                    &nbsp;<a href="file:///C|/Documents%20and%20Settings/kappel/Desktop/aq-utils.php">Air-Quality Analysis</a>&nbsp;<img src="file:///C|/Documents%20and%20Settings/kappel/Desktop/images/bullet.gif" width="10" height="10" border="0"> 
                    &nbsp;<a href="file:///C|/Documents%20and%20Settings/kappel/Desktop/contact.html">Contact</a><br>
                  </b><A href="http://www.epa.gov/asmdnerl/index.html">Atmospheric Sciences Modeling Division</A></p>
                </td></tr>
            </table></TD>
        </TR>
      </TABLE></TD>
  </TR>
  <TR> 
    <TD background="file:///C|/Documents%20and%20Settings/kappel/Desktop/images/blkbottom.gif"> <DIV align="center"> 
        <P><A href="http://www.snakeyewebtemplates.com" target="_blank" class="type1"><BR>
          &nbsp;&nbsp; </A></P>
      </DIV></TD>
  </TR>
</TABLE>
</BODY>
<!-- InstanceEnd --></HTML>
