##################################################################
## Filename: amet-config.pl                                     ##
##                                                              ##
## This file is required by the various AMET R scripts.		##
##                                                              ##
## This file provides necessary MYSQL information to the file   ##
## above so that data from Site Compare can be added to the     ##
## systems MYSQL database.					## 
##################################################################

##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## MySQL Configuration
server<-"localhost"			## Name of MYSQL server
login<-"ametsecure"			## AMET login for MYSQL server
passwd<-"xxxxxx"			## AMET password for MYSQL server
dbase<-Sys.getenv("AMET_DATABASE")	## Get AMET Database name from enviornment variable (redundant)
maxrec<--1				## Max number of records to extract from the database for one day (num. stations * 24)

##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## R Library path
oldLibPath <- .libPaths()
newLibPath <- c("/share/linux9.0/R_2.7.1/lib/R/bin/R",oldLibPath) ## oldPath + additional paths
.libPaths(newLibPath)
##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

