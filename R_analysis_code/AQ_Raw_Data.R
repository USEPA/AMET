################## MODEL TO OBS SCATTERPLOT #################### 
### AMET CODE: R_Scatterplot.r 
###
### This script is part of the AMET-AQ system.  This script creates
### a single model-to-obs scatterplot. This script will plot a
### single species from up to three networks on a single plot.  
### Additionally, summary statistics are also included on the plot.  
### The script will also allow a second run to plotted on top of the
### first run. 
###
### Last Updated by Wyat Appel: June, 2017
################################################################

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

filename_txt <- paste(run_name1,pid,"rawdata.csv",sep="_")     # Set output file name
filename_txt <- paste(figdir,filename_txt,sep="/")     # Set output file name

### Retrieve units and model labels from database table ###
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
network <- network_names[1]
################################################
network <- network_names[1]
run_name <- run_name1
criteria <- paste(" WHERE d.ob_dates is not NULL and d.network='",network,"' ",query,sep="")             # Set part of the MYSQL query
check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name,"' and COLUMN_NAME = 'POCode';",sep="")
query_table_info.df <-db_Query(check_POCode,mysql)
{
if (length(query_table_info.df$COLUMN_NAME) == 0) {    # Check to see if POCode column exists or not
      qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.i,d.j,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod from ",run_name," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")      # Set the rest of the MYSQL query
      aqdat_query.df<-db_Query(qs,mysql)
      aqdat_query.df$POCode <- 1
   }
   else {
      qs <- paste("SELECT d.network,d.stat_id,d.POCode,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod from ",run_name," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")        # Set the rest of the MYSQL query
      aqdat_query.df<-db_Query(qs,mysql)
   }
}

write.table(run_name1,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
write.table(dates,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(aqdat_query.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")

