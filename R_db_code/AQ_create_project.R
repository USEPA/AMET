##------------------------------------------------------
#       AMET AQ Database Table Creation                 #
#                                                       #
#       PURPOSE: To create a MYSQL table usable for     #
#               the AMET-AQ system                      #
#							#
#       Last Update: 06/08/2017 by Wyat Appel           #
#--------------------------------------------------------

######################################################################################

suppressMessages(require(RMySQL))	# Use RMYSQL package

amet_base <- Sys.getenv('AMETBASE')
iof (!exists("amet_base")) {
   stop("Must set AMETBASE environment variable")
}

dbase <-Sys.getenv('AMET_DATABASE')
if (!exists("dbase")) {
   stop("Must set AMET_DATABASE environment variable")
}

config_file     <- Sys.getenv("MYSQL_CONFIG")   # MySQL configuration file
if (!exists("config_file")) {
   stop("Must set MYSQL_CONFIG environment variable")
}
source(config_file)

project_id	<- Sys.getenv('AMET_PROJECT')
model		<- Sys.getenv('MODEL_TYPE')
user_name	<- Sys.getenv('USER_NAME')
email		<- Sys.getenv('EMAIL_ADDR')
description	<- Sys.getenv('RUN_DESCRIPTION')
delete_table	<- Sys.getenv('DELETE_PROJECT')
remake_table	<- Sys.getenv('REMAKE_PROJECT')
update_table	<- Sys.getenv('UPDATE_PROJECT')

project_id 	<- gsub("[.]","_",project_id)
project_id      <- gsub("[-]","_",project_id)

args              <- commandArgs(2)
mysql_login       <- args[1]
mysql_pass        <- args[2]

### Use MySQL login/password from config file if requested ###
if (mysql_login == 'config_file') { mysql_login <- amet_login }
if (mysql_pass == 'config_file')  { mysql_pass  <- amet_pass  }
##############################################################

con             <- dbConnect(MySQL(),user=mysql_login,password=mysql_pass,dbname=dbase,host=mysql_server)
MYSQL_tables    <- dbListTables(con)

##################################################
### Function to create a AMET AQ project table ###
##################################################
create_table<-function()
{
   aq_new_1 <- paste("create table ",project_id," (proj_code varchar(100), POCode integer, valid_code character(10), invalid_code character(10), network varchar(25), stat_id varchar(25), stat_id_POCode varchar(100), lat double, lon double, i integer(4), j integer(4), ob_dates date, ob_datee date, ob_hour integer(2), month integer(2), precip_ob double, precip_mod double)",sep="")
   aq_new_2 <- paste("alter table ",project_id," add UNIQUE(network, stat_id,POCode,ob_dates,ob_datee,ob_hour)",sep="")
   aq_new_3 <- paste("alter table ",project_id," add INDEX(month)",sep="")
   create_table_log1 <- dbSendQuery(con,aq_new_1)
   create_table_log2 <- dbSendQuery(con,aq_new_2)
   create_table_log3 <- dbSendQuery(con,aq_new_3)
   cat(paste("\nThe project table ",project_id," has been created \n",sep=""))
}
##################################################

exists <- "n"
cat(paste("\nActive MySQL database = ",dbase,"\n",sep=""))
cat(paste("Project ID = ",project_id,"\n\n",sep=""))
if (length(MYSQL_tables) != 0) {
   cat("List of existing projects in dbase\n")
   cat(paste(MYSQL_tables,"\n",sep=""))
   if (project_id %in% MYSQL_tables) {
      cat ("\nThe project ID name you provided already exists.  Would you like to delete the existing project id (y/n)? \n")
      cat(paste(delete_table,"\n"))
      if ((delete_table == 'y') || (delete_table == 'Y') || (delete_table == 't') || (delete_table == 'T')) {
         drop <- paste("drop table ",project_id,sep="")
         mysql_result <- dbSendQuery(con,drop)
         drop2 <- paste("delete from aq_project_log where proj_code = '",project_id,"'",sep="")
         mysql_result <- dbSendQuery(con,drop2)
         cat("The following MySQL database tables have been successfully removed from the database. \n")
      }
      else {
         cat(paste("\nWould you like to update the description of the existing project ",project_id," (y/n)? \n",sep=""))
         cat(paste(update_table,"\n"))
         if ((update_table == 'y') || (update_table == 'Y') || (update_table == 't') || (update_table == 'T')) {
            cat(paste("\n\nModel = ",model,"\n",sep=""))
            cat(paste("\n\n user name = ",user_name,"\n",sep=""))
            cat(paste("\n\n email = ",email,"\n",sep=""))
            cat(paste("\n\n Project Description = ",description,"\n",sep=""))
            current_date <- Sys.Date()
	    current_time <- Sys.time()
	    current_time <- substr(current_time,12,19)
	    year <- substr(current_date,1,4)
	    mon  <- substr(current_date,6,7)
            day  <- substr(current_date,9,10)
            proj_time <- current_time
            proj_date <- paste(year,mon,day,sep="")
            cat(paste("\nproj_date=",proj_date))
            table_query <- paste("REPLACE INTO aq_project_log (proj_code, model, user_id, email, description, proj_date, proj_time) VALUES ('",project_id,"','",model,"','",user_name,"','",email,"','",description,"',",proj_date,",'",proj_time,"')",sep="")
            mysql_result <- dbSendQuery(con,table_query)
            cat("\nThe following existing project description has been successfully updated.  Please review the following for accuracy, then use the link below to advance to the next step.")
         }
         else {
            cat(paste("\nWould you like to re-make the table for project ",project_id," (y/n)? (Note this will delete all existing data in project ",project_id," but retain the existing project description): \n",sep=""))
            cat(paste(remake_table,"\n"))
            if ((remake_table == 'y') || (remake_table == 'Y') || (remake_table == 't') || (remake_table == 'T')) {
               drop <- paste("drop table ",project_id,sep="")
               mysql_result <- dbSendQuery(con,drop)
               create_table()
               cat("\nThe following database table has been successfully re-generated.  Please review the following for accuracy, then use the link below to advance to the next step. \n")
            }
            else {
               cat(paste("\nAlright, doing nothing. Change the flags in the script if you wish to delete, update or re-make project ",project_id,".\n\n",sep=""))
            }
         }
      }
      exists <- 'y'
   }
}

if (exists != "y") {
   cat(paste("\nNo existing project named ",project_id," found.  Creating new project ",project_id," with the information below:",sep=""))
   cat(paste("\nmodel = ",model,sep=""))
   cat(paste("\nuser name = ",user_name,sep=""))
   cat(paste("\nemail = ",email,sep=""))
   cat(paste("\nproject description = ",description,"\n\n",sep=""))
   current_date <- Sys.Date()
   current_time <- Sys.time()
   current_time <- substr(current_time,12,19)
   year <- substr(current_date,1,4)
   mon  <- substr(current_date,6,7)
   day  <- substr(current_date,9,10)
   proj_date <- paste(year,mon,day,sep="")
   proj_time <- current_time
   table_query <- paste("REPLACE INTO aq_project_log (proj_code, model, user_id, email, description, proj_date, proj_time) VALUES ('",project_id,"','",model,"','",user_name,"','",email,"','",description,"',",proj_date,",'",proj_time,"')",sep="")
   mysql_result <- dbSendQuery(con,table_query)
   create_table()
   cat("\n### The following database tables have been successfully generated.  Please review the following for accuracy. ### \n")
}

query_min <- paste("SELECT * from aq_project_log where proj_code='",project_id,"' ",sep="")
query_results <- suppressWarnings(dbGetQuery(con,query_min))
cat(paste("project_id  = ",project_id,"\n",sep=""))
cat(paste("model       = ",query_results$model,"\n",sep=""))
cat(paste("user        = ",query_results$user,"\n",sep=""))
cat(paste("email       = ",query_results$email,"\n",sep=""))
cat(paste("description = ",query_results$description,"\n",sep=""))
cat(paste("proj_date   = ",query_results$proj_date,"\n",sep=""))
cat(paste("proj_time   = ",query_results$proj_time,"\n",sep=""))
mysql_result <- dbDisconnect(con)

