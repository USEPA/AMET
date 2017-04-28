#!/usr/bin/perl
##------------------------------------------------------
#       AMET-AQ Database Setup Script                   #
#                                                       #
#       PURPOSE: To input site compare output into      #
#               the AMET-AQ MYSQL database              #
#                                                       #
#       Last Update: 05/02/2006 by Wyat Appel           #
#--------------------------------------------------------


require(RMySQL)                                              # Use MYSQL perl package
amet_base    <- Sys.getenv('AMETBASE')
dbase        <- Sys.getenv('AMET_DATABASE')
run_id       <- Sys.getenv('AMET_PROJECT')

source.command <- paste(amet_base,"/configure/amet-config.R",sep="")
source(source.command)

mysql           <- list(login=root_login, passwd=root_pass, server=mysql_server, dbase=dbase, maxrec=5000000)           # Set MYSQL login and query options
con             <- dbConnect(MySQL(),user=root_login,password=root_pass,dbname=dbase,host=mysql_server)

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Create new project log, units and site metadata tables if running AMET for the first time
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
aq_new_1 <- paste("create table ",run_id," (proj_code varchar(50), POCode integer, valid_code character(10), invalid_code character(10), network varchar(25), stat_id varchar(25), stat_id_POCode varchar(100), lat double, lon double, i integer(4), j integer(4), ob_dates date, ob_datee date, ob_hour integer(2), month integer(2), precip_ob double, precip_mod double)",sep="")
cat(paste(aq_new_1,"\n\n",sep=""))
aq_new_2 <- paste("alter table ",run_id," add UNIQUE(network, stat_id,POCode,ob_dates,ob_datee,ob_hour)",sep="")
aq_new_3 <- paste("alter table ",run_id," add INDEX(month)",sep="")
dbSendQuery(con,aq_new_1)
dbSendQuery(con,aq_new_2)
dbSendQuery(con,aq_new_3)
cat(paste("\nThe project table ",run_id," has been created \n",sep="") 
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

