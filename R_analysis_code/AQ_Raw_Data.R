header <- "
################## WRITE RAW QUERY OUTPUT #################### 
### AMET CODE: AQ_Raw_Data.R 
###
### This script is part of the AMET-AQ system.  This script simply
### writes a database query as a comma separated file, suitable for
### use in spreadsheet programs. Single simulation, single network,
### single species.
###
### Last Updated by Wyat Appel: Dec 2020
################################################################
"

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
      data_exists    <- query_result[[2]]
      if (data_exists == "y") { units <- query_result[[3]] }
      model_name     <- query_result[[4]]
   }
}
ob_col_name <- paste(species,"_ob",sep="")
mod_col_name <- paste(species,"_mod",sep="")
{
   if (averaging != "n") {
      aqdat.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),State=I(aqdat_query.df$state),County=I(aqdat_query.df$county),Landuse=I(aqdat_query.df$landuse),Loc_setting=I(aqdat_query.df$loc_setting),NLCD_Loc_setting=I(aqdat_query.df$NLCD2011_Imperv_Surf_Loc_Setting),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=round(aqdat_query.df[[ob_col_name]],5),Mod_Value=round(aqdat_query.df[[mod_col_name]],5),Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month)
      aqdat.df <- Average(aqdat.df)
   }
   else {
      aqdat.df <- aqdat_query.df
   }
}
write.table(run_name1,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
write.table(dates,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(aqdat.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")

