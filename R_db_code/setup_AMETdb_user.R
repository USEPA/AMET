#!/usr/bin/R
##------------------------------------------------------
#       AMET Database Setup Script                      #
#                                                       #
#       PURPOSE: Sets up a database and an amet         #
#                user for both MET and AQ               #
#                                                       #
#       AUTHOR:  K. Wyat Appel, USEPA                   # 
#       LAST UPDATE: 01/2022 by K. Wyat Appel		#
#--------------------------------------------------------

## Before anything else, get the AMETBASE variable and source
## the file containing MYSQL login and location information
amet_base <- Sys.getenv('AMETBASE') 
if (!exists("amet_base")) {
   stop("Must set AMETBASE environmental variable")
}
source.command <- paste(amet_base,"/configure/amet-config.R",sep="")
source(source.command)

dbase <-Sys.getenv('AMET_DATABASE')
if (!exists("amet_base")) {
   stop("Must set AMET_DATABASE environmental variable")
}

# LOAD Required R Modules
suppressMessages(if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")})

args			<- commandArgs(4)
mysql_root_login	<- args[1]
mysql_root_pass		<- args[2]
amet_login		<- args[3]
amet_pass		<- args[4]

# Connect to MySQL database and Set AMET Passwords ametsecure (for read and write ability to database)
con             <- dbConnect(MySQL(),user=mysql_root_login,password=mysql_root_pass,dbname="mysql",host=mysql_server)
if (!exists("con")) {
   stop("Your MySQL server was not found or login or passwords incorrect, please check to see if server is running or passwords are correct.")
}
## Add the ametsecure user w/ full privileges, assumes MYSQL v4.0 or greater
cat(paste("\nCreating or modifying user ",amet_login,"...",sep=""))
q1 <- paste("CREATE USER '",amet_login,"' IDENTIFIED BY '",amet_pass,"'",sep="")
q2 <- paste("GRANT ALL PRIVILEGES ON * . * TO '",amet_login,"'",sep="")
create_user_log <- try(dbSendQuery(con,q1),silent=T)
modify_user_log <- try(dbSendQuery(con,q2),silent=T)
if (class(create_user_log)=="try-error") {
   cat(paste("\nFailed to create new user with the error: ",create_user_log,".",sep=""))
   stop()
}
if (class(modify_user_log)=="try-error") {
   cat(paste("\nFailed to grant new user privileges with the error: ",modify_user_log,".",sep=""))
   stop()
}
q <- "FLUSH PRIVILEGES"
flush_log <- try(dbSendQuery(con,q),silent=T)
if (class(flush_log)=="try-error") {
   cat(paste("\nFailed to flush privileges with the error: ",flush_log,". This probably isn't a big deal really.",sep=""))
}
cat("done. \n")
