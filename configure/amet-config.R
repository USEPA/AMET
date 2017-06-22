##################################################################
## Filename: amet-config.R                                      ##
##                                                              ##
## This file is required by the various AMET R scripts.		##
##                                                              ##
## This file provides necessary MYSQL information to the files  ##
## above so that data from Site Compare can be added to the     ##
## systems MYSQL database.					## 
##################################################################

##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## Directory Paths
amet_base         <- Sys.getenv('AMETBASE')                             ## The AMET base directory where AMET is installed

##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## MySQL Configuration ###
## The AMET user info provided here must have database write permission if used in the aqProject.csh and/or metProject.csh scripts 
## Otherwise, if just used for the analysis side of AMET, database read permission only is sufficient
mysql_server	<- "localhost"	## Name of MYSQL server
amet_login	<- "ametsecure"		## AMET Root login for MYSQL serve
amet_pass	<- "xxxxxxxxxx"		## AMET Root password for MYSQL server
maxrec		<- -1			## Set MySQL maximum records for queries (-1 for no maximum)

##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## Misc Executables 
Bldoverlay_exe    <- paste(amet_base,"/bin/bldoverlay.exe",sep="")	## Full path to build overlay executable
EXEC_sitex_daily  <- paste(amet_base,"/bin/sitecmp_dailyo3.exe",sep="") ## Full path to site compare daily executable
EXEC_sitex        <- paste(amet_base,"/bin/sitecmp.exe",sep="")		## Full path to site compare executable

