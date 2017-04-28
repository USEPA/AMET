#!/usr/bin/R
##------------------------------------------------------
#       AMET Database Setup Script                      #
#                                                       #
#       PURPOSE: Sets up a database and an amet         #
#                user for both MET and AQ               #
#                                                       #
#       Author:  K. Wyat Appel, USEPA                   # 
#       Last updated by Wyat Appel: April, 2017		#
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

# LOAD Required R Modules
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}

args			<- commandArgs()
mysql_root_login	<- args[1]
mysql_root_pass		<- args[2]


# Connect to MySQL database and Set AMET Passwords ametsecure (for read and write ability to database)
con             <- dbConnect(MySQL(),user=mysql_root_login,password=mysql_root_pass,dbname="mysql",host=mysql_server)
if (!exists("con")) {
   stop("Your MySQL server was not found or login or passwords incorrect, please check to see if server is running or passwords are correct.")
}
## Add the ametsecure user w/ full privileges, assumes MYSQL v4.0 or greater
print(paste("Creating or modifying user ",root_login,")",sep=""))
q <- paste("REPLACE INTO mysql.user (Host,User,Password,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv,Grant_priv,Alter_priv) VALUES('%','",root_login,"',PASSWORD('",root_pass,"'), 'Y','Y','Y','Y','Y','Y','Y','Y')",sep="")
create_user_log <- try(dbSendQuery(con,q),silent=T)
if (class(create_user_log)=="try-error") {
   print(paste("Failed to create new user with the error: ",create_user_log,".",sep=""))
   stop()
}
q <- "FLUSH PRIVILEGES"
flush_log <- try(dbSendQuery(con,q),silent=T)
if (class(flush_log)=="try-error") {
   print(paste("Failed to flush privileges with the error: ",flush_log,". This probably isn't a big deal really.",sep=""))
}

## Create a new database
cat(paste("Creating new database",dbase,")"))
q <- paste("create DATABASE",dbase)
create_database_log <- try(dbSendQuery(con,q),silent=T)
if (class(create_database_log)=="try-error") {
   print(paste("Failed to create new database with the error: ",create_database_log,". Perhaps the database already exists.",sep=""))
   stop()
}


