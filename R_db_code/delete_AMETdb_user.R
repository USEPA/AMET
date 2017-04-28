#!/usr/bin/perl
##------------------------------------------------------
#       AMET Database Setup Script                      #
#                                                       #
#       PURPOSE: Deletes a database and an amet         #
#                user for both MET and AQ               #
#                                                       #
#       Author:  Alexis Zubrow, IE UNC                  # 
#	Last Updated by Wyat Appel: April, 2017		#
#--------------------------------------------------------


## Before anything else, get the AMETBASE variable and source
## the file containing MYSQL login and location information
## Note: need perl_lib before add other packages
amet_base <- Sys.getenv('AMETBASE')
if (!exists("amet_base")) {
   stop("Must set AMETBASE environmental variable")
}
source.command <- paste(amet_base,"/configure/amet-config.R",sep="")
source(source.command)

dbase <-Sys.getenv('AMET_DATABASE')
#       or die "Must set AMET_DATABASE environmental variable\n";
#}

# LOAD Required Perl Modules
require(RMySQL)                                              # Use MYSQL R package

args                    <- commandArgs(TRUE)
mysql_root_login        <- args[1]
mysql_root_pass         <- args[2]
delete_db               <- args[3]
delete_user             <- args[4]

# Connect to MySQL database and Set AMET Passwords ametsecure (for read and write ability to database)
con             <- dbConnect(MySQL(),user=mysql_root_login,password=mysql_root_pass,dbname="mysql",host=mysql_server)
if (!exists("con")) {
   stop("Your MySQL server was not found or login or passwords incorrect, please check to see if server is running or passwords are correct.")
}

## Check if they want to delete the database
#cat("WARNING, WARNING!!")
#cat("Deleting the database will destroy the data in all MET and AQ projects.")
{
   if (delete_db == "yes") {
      print(paste("Deleting database:",dbase))
      q <- paste("drop DATABASE",dbase)
      drop_database_log <- try(dbSendQuery(con,q),silent=T) 
      if (class(drop_database_log)=="try-error") {
         print(paste("Failed to delete database with the following error: ",create_database_log,". Perhaps the database doesn't exists.",sep=""))
         stop()
      }
   }
   else {
      print(paste("Not deleting database:",dbase))
   }
}

## Check if they want to delete the user
#cat("WARNING, WARNING!!")
#cat("Deleting the user will mean that you can't access data through this user")
{
   if (delete_user == "yes") {
      print(paste("Deleting user:", root_login))
      q <- paste("delete from mysql.user where user='",root_login,"'",sep="")
      drop_user_log <- try(dbSendQuery(con,q),silent=T)
      if (class(drop_database_log)=="try-error") {
         print(paste("Failed to delete user with the following error: ",create_database_log,". Perhaps the user doesn't exists.",sep=""))
         stop()
      }
      q <- "FLUSH PRIVILEGES"
      flush_log <- try(dbSendQuery(con,q),silent=T)
      if (class(flush_log)=="try-error") {
         print(paste("Failed to flush privileges with the error: ",flush_log,". This probably isn't a big deal really.",sep=""))
      }
   }
   else {
      print(paste("Not deleting user:",root_login))
   }
}
