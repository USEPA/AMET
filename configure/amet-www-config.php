<?php
//////////////////////////////////////////////////////////////////
// Filename: amet-www-config.php                                //
//                                                              //
// This file is required by the various AMET PHP programs.      // 
//                                                              //
// This file provides necessary MYSQL information to the file   //
// above so that data from Site Compare can be added to the     //
// system's MYSQL database.                                     // 
//////////////////////////////////////////////////////////////////

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// MySQL Configuration
$mysql_server="darwin.rtpnc.epa.gov";	// Name of MYSQL server
$root_login="wyat";		// Root login for MYSQL server
$root_pass="283ButterFish!";		// Root password for MYSQL server

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// R executable path
$R_dir="/share/linux86_64/R-3.2.4/lib64/R";                     // Path to R main directory
$R_exe="/share/linux86_64/R-3.2.4/bin/R";                       // Path to R executable
$R_script="/share/linux86_64/R-3.2.4/bin/Rscript";		// Path to R script executable
$R_lib=" /share/linux86_64/R-3.2.4/lib/R/library";              // Path to R library directory
$R_proj_lib="/home/appel/linux/lib/proj4";                  	// Path to proj4 executable

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Web paths
$http_server="newton.rtpnc.epa.gov";					// An expample if amet was on http://www.coastwx.com (www.coastwx.com)
$http_amet="wyat/AMETv13_Code";						// Extension from server root to amet
$amet_base="/project/amet_aq/AMET_Code/Release_Code_v13/AMET_v13";	// Base directory where AMET-AQ is installed
$cache_amet="$amet_base/web_interface/cache";				// Default AMET cache directory (needs to have read/write access for web server
$http_cgi="cgi-bin";
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
?>
