##------------------------------------------------------
#       AMET AQ Database Table Creation                 #
#                                                       #
#       PURPOSE: To create a MYSQL table usable for     #
#               the AMET-AQ system                      #
#							#
#       Last Update: 03/13/2017 by Wyat Appel           #
#--------------------------------------------------------

######################################################################################

require(RMySQL)                                              # Use RMYSQL package

amet_base	<- Sys.getenv('AMETBASE')
dbase		<- Sys.getenv('AMET_DATABASE')

source.command <- paste(amet_base,"/configure/amet-config.R",sep="")
source(source.command)

amet_R_input <- Sys.getenv('AMETRINPUT')
source(amet_R_input)

mysql           <- list(login=root_login, passwd=root_pass, server=mysql_server, dbase=dbase, maxrec=5000000)           # Set MYSQL login and query options
con             <- dbConnect(MySQL(),user=root_login,password=root_pass,dbname=dbase,host=mysql_server)
MYSQL_tables    <- dbListTables(con)

exists <- "n"
cat(paste("Active MySQL database = ",dbase,"\n\n",sep=""))
cat("Enter project id name (project id will checked to see if it already exists): \n")
cat(paste("Project ID = ",run_id,"\n\n",sep=""))

if (length(MYSQL_tables) != 0) {
   cat("List of existing projects in dbase\n")
   cat(paste(MYSQL_tables,"\n",sep=""))
   if (run_id %in% MYSQL_tables) {
      cat ("\nThe project ID name you provided already exists.  Would you like to delete the existing project id (y/n)? \n")
      cat(paste(delete_table,"\n"))
      if (delete_table == 'y') {
         cat(paste("\nAre you sure you want to delete project ",run_id," from the database (y/n)? \n",sep=""))
         cat(paste(delete_table2,"\n\n"))
         if (delete_table2 == "y") {
            drop <- paste("drop table ",run_id,sep="")
            dbSendQuery(con,drop)
            drop2 <- paste("delete from aq_project_log where proj_code = '",run_id,"'",sep="")
            dbSendQuery(con,drop2)
            cat("The following MySQL database tables have been successfully removed from the database. \n")
         }
      }
      else {
         cat(paste("\nWould you like to update the description of the existing project ",run_id," (y/n)? \n",sep=""))
         cat(paste(update_table,"\n"))
         if (update_table == "y") {
            cat("Enter model (e.i. CMAQ): ")
            cat(paste("\n\nModel = ",model,"\n",sep=""))
            cat("Enter user name: ")
            cat(paste("\n\n user name = ",login,"\n",sep=""))
            cat("Enter email address: ")
            cat(paste("\n\n email = ",email,"\n",sep=""))
            cat("Enter project description: ")
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
            table_query <- paste("REPLACE INTO aq_project_log (proj_code, model, user_id, email, description, proj_date, proj_time) VALUES ('",run_id,"','",model,"','",login,"','",email,"','",description,"',",proj_date,",'",proj_time,"')",sep="")
            dbSendQuery(con,table_query)
            cat("\nThe following existing project description has been successfully updated.  Please review the following for accuracy, then use the link below to advance to the next step.")
         }
         else {
            cat(paste("\nWould you like to re-make the table for project ",run_id," (y/n)? (Note this will delete all existing data in project ",run_id," but retain the existing project description): \n",sep=""))
            cat(paste(remake_table,"\n"))
            if (remake_table == "y") {
               cat(paste("\nAre you sure you wish to re-make the data table for ",run_id," (y/n)? \n",sep=""))
               cat(paste(remake_table2,"\n"))
               if (remake_table2 == "y") {
                  drop <- paste("drop table ",run_id,sep="")
                  dbSendQuery(con,drop)
                  create.command <- paste("R --no-save --slave < ",amet_base,"/R_db_code/AQ_create_database_table.R",sep="")
                  system(create.command)
                  cat("\nThe following database table has been successfully re-generated.  Please review the following for accuracy, then use the link below to advance to the next step. \n")
               }
            }
            else {
               cat(paste("\nAlright, doing nothing. Change the flags in the script if you wish to delete, update or re-make project ",run_id,".\n",sep=""))
            }
         }
      }
      exists <- 'y'
   }
}

if (exists != "y") {
   cat(paste("\nNo existing project named ",run_id," found.  Creating new project ",run_id," \n",sep=""))
   cat("\nEnter model (e.i. CMAQ): ")
   cat(paste("\n model = ",model,"\n",sep=""))
   cat("Enter user name: ")
   cat(paste("\n user name = ",login,"\n",sep=""))
   cat("Enter email address: ")
   cat(paste("\n email = ",email,"\n",sep=""))
   cat("Enter project description: ")
   cat(paste("\n project description = ",description,"\n\n",sep=""))
   current_date <- Sys.Date()
   current_time <- Sys.time()
   current_time <- substr(current_time,12,19)
   year <- substr(current_date,1,4)
   mon  <- substr(current_date,6,7)
   day  <- substr(current_date,9,10)
   proj_date <- paste(year,mon,day,sep="")
   proj_time <- current_time
   table_query <- paste("REPLACE INTO aq_project_log (proj_code, model, user_id, email, description, proj_date, proj_time) VALUES ('",run_id,"','",model,"','",login,"','",email,"','",description,"',",proj_date,",'",proj_time,"')",sep="")
   cat(table_query)
   dbSendQuery(con,table_query)
   create.command <- paste("R --no-save --slave < ",amet_base,"/R_db_code/AQ_create_database_table.R",sep="")
   system(create.command)
   cat("### The following database tables have been successfully generated.  Please review the following for accuracy. ### \n\n")
}
query_min <- paste("SELECT * from aq_project_log where proj_code='",run_id,"' ",sep="")   # set query for project log table for all information regarding current project
query_results <- dbGetQuery(con,query_min)                                      # execute query
cat(paste("\nproject_id  = ",run_id,"\n",sep=""))
cat(paste("model       = ",query_results$model,"\n",sep=""))
cat(paste("user        = ",query_results$user,"\n",sep=""))
cat(paste("email       = ",query_results$email,"\n",sep=""))
cat(paste("description = ",query_results$description,"\n",sep=""))
cat(paste("proj_date   = ",query_results$proj_date,"\n",sep=""))
cat(paste("proj_time   = ",query_results$proj_time,"\n",sep=""))
dbDisconnect(con)

