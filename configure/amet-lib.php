<?php
////*******************************************************************************************************/////
////****************************** 		FUNCTION SECTION		***********************************/////
////*******************************************************************************************************/////
// This function courtesy of drudge@phpcoders.net

function get_csv($filename, $delim =","){

$row = 0;
$dump = array();

$f = fopen ($filename,"r");
$size = filesize($filename)+1;
while ($data = fgetcsv($f, $size, $delim)) {
$dump[$row] = $data;
echo $data[1]."<br>";
$row++;
}
fclose ($f);

return $dump;
}
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//	END of CVS file reading function
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

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

function distance($lat1, $lon1, $lat2, $lon2, $unit){

   $theta = $lon1 - $lon2;
   $dist = sin(deg2rad($lat1)) * sin(deg2rad($lat2)) + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($theta));
  $dist  = acos($dist);
  $dist = rad2deg($dist);
  $dist = $dist * 60 * 1.1515;
  if ($unit == "K") {
  	$dist = $dist * 1.609344;
  } 
  elseif ($unit == "N") {
  	$dist = $dist * 0.8684;
  }
	return $dist;
}
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//	END of DISTANCE FUNCTION
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 ?>
