##################################################################
## Filename: amet-config.R                                      ##
##                                                              ##
## This file is required by the various AMET R scripts.		##
##                                                              ##
## This file provides necessary MYSQL information to the file   ##
## above so that data from Site Compare can be added to the     ##
## systems MYSQL database.					## 
##################################################################

##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## Site Compare Configuration
amet_base         <-  "/project/amet_aq/AMET_Code/Release_Code_v13/AMET_v13";   		# The AMET base directory where AMET is installed
#EXEC_sitex_daily  <-  paste(amet_base,"/src/sitecmp_dailyo3/sitecmp_dailyo3.exe,sep="")	# full path to site compare daily executable
EXEC_sitex_daily  <-  "/home/css/bin_test/sitecmp_daily_newheader_poc.exe"                      # full path to site compare daily executable
#EXEC_sitex        <-  paste(amet_base,"/src/sitecmp/sitecmp.exe",sep="")			# full path to site compare executable
EXEC_sitex        <-  "/home/css/bin_test/sitecmp_newheader_poc.exe"                            # full path to site compare executable
obs_data_dir      <-  paste(amet_base,"/obs/AQ",sep="")						# full path location of obs data

##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## MySQL Configuration
mysql_server	<- "newton.rtpnc.epa.gov"	## Name of MYSQL server
root_login	<- "AMETv13_User"	## AMET Root login for MYSQL server
root_pass	<- "AMETv13_User"	## AMET Root password for MYSQL server
#mysql_tmpdir	<- "/project/amet_aq/"
maxrec		<- -1			## Set MySQL maximum records for queries (-1 for no maximum)

##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## Misc Executables 
#Bldoverlay_exe  <- paste(amet_base,"/src/bldoverlay/bldoverlay.exe",sep="")	## Path to boundary overlay executable
Bldoverlay_exe	<- "/home/appel/bin/bldoverlay.exe"	## Path to boundary overlay executable

##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
R_dir		<- "/share/linux86_64/R-3.2.4/lib64/R"		## Path to R main directory
R_exe		<- "/share/linux86_64/R-3.2.4/bin/R"		## Path to R executable
R_script	<- "/share/linux86_64/R-3.2.4/bin/Rscript"	## Path to Rscript executable
R_lib		<- "/share/linux86_64/R-3.2.4/lib/R/library"	## Path to R library directory
R_proj_lib	<- "/home/appel/linux/lib/proj4"                ## Path to proj4 executable
##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
