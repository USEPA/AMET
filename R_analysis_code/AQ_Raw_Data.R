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

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
network <- network_names[1]
################################################
network <- network_names[1]
run_name <- run_name1
{
   if (Sys.getenv("AMET_DB") == 'F') {
      sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name[j],species)
      aqdat_query.df   <- sitex_info$sitex_data
   }
   else {
      query_result     <- query_dbase(run_name1,network,species)
      aqdat_query.df   <- query_result[[1]]
   }
}

write.table(run_name1,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
write.table(dates,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(aqdat_query.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")

