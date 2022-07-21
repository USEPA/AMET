#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#                AMET (Atmospheric Model Evaluation Tool)               #
#                                                                       #
#                    Spatial Surface Statistics                         #
#                      MET_spatial_surface.R                            #
#                                                                       #
#         Developed by the US Environmental Protection Agency           #
#-----------------------------------------------------------------------#
#########################################################################
# Change LOG
# daily_station_stats-1.1 (05/04/2004)	
#       Initial deveopment: The program currently reads a configuration file that is placed in
#       the location where the execution takes place. The configuration allows user to choose
#       a start day and month, and an end day and month. Also, specific database, table/project ID,
#       area to examine (lat-lon bounds), figure and save file directories
#
# Modified to work with combined MET/AQ mode, Alexis Zubrow (IE UNC) Oct, 2007
#
# Changed name to MET_spatial_surface.R, Alexis Zubrow (IE UNC) Nov, 2007
#
# Version 1.2, May 8, 2013, Robert Gilliam                                 
# Updates: - Pulled some configurable options out of MET_spatial_surface.R    
#            and placed into the spatial_surface.input file  
#          - Sample threshold so sites where sample size is small are ignored 
#          - Spatial plot bounds can be manually specified in run_spatial_surface.csh 
#          - text file with set SITES=(....) string of all site id's in domain
#            This is helpful to use in run_timeseries.csh script. File: spatial.setSITES.all.txt               
#          - Extensive cleaning of R script, R input and .csh files
#
#  Version 1.3, May 15, 2017, Robert Gilliam
#  Updates: - Removed hard coded amet-config.R config option that       
#             defined MySQL server, database and password (unsecure).   
#             Now users define that file location in csh wrapper scripts
#             via setenv MYSQL_CONFIG variable.
#           - Removed some deprecated variables and cleaned/formatted
#             script for better readability. Also changed dir names
#             to reflect new version (i.e., R_analysis_code instead of R)
#           - Changed the date start and date end to include new MySQL
#             timestamp. The new one condisders the end date to be 00 UTC
#             for that day, while the old considered data for all hours.
#             Now a user can specify the start "day hour" and end "day hour"
#             for more flexibility. In csh wrapper that would be:
#             setenv AMET_DATES "20170502 00"
#             setenv AMET_DATEE "20170510 23"
#           - thresh was input as text instead of numeric. Fixed. Also updated
#             the color scheme and levels for some metrics in spatial_surface.input
#
# Version 1.4, Sep 30, 2018, Robert Gilliam         
#           - Headers updated. More old tab usage was changed to white spaces.
#           - Date part of query was modified to accommodate newer MySQL date considerations.
#             End date with no hour is considered 00 UTC on that day, so a day is added to user
#             end date and query was changed to less than end date.
#                  
#  Version 1.5, Apr 19, 2022, Robert Gilliam                            
#  Updates: - New split config input file where "more" static settings  
#             are split into a spatial_surface.static.input and key configs  
#             remain in the spatial_surface.input. Backward compatible.
#           - More robust threshold setting control for GUI and backward compatibility.
#
#############################################################################################################
  options(warn=-1)
#############################################################################################################
#	Load required modules
  if(!require(maps))   {stop("Required Package maps was not loaded")}
  if(!require(mapdata)){stop("Required Package mapdata was not loaded")}
  if(!require(date))   {stop("Required Package date was not loaded")}
  if(!require(RMySQL)) {stop("Required Package RMySQL was not loaded")}
  if(!require(akima))  {stop("Required Package akima was not loaded")}
  if(!require(fields)) {stop("Required Package fields was not loaded")}
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#    Initialize AMET Diractory Structure Via Env. Vars
#    AND Load required function and conf. files
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## get some environmental variables and setup some directories
 ametbase         <- Sys.getenv("AMETBASE")
 ametR            <- paste(ametbase,"/R_analysis_code",sep="")
 ametRinput       <- Sys.getenv("AMETRINPUT")
 mysqlloginconfig <- Sys.getenv("MYSQL_CONFIG")
 ametRstatic      <- Sys.getenv("AMETRSTATIC")

 # Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
 # and not specified via AMET_OUT, then set figdir to the current directory
 if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")	}
 if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"			}
 ## Check for Static file setting and set to empty if missing. Backward compat.
 ## & print input files for user notification 
 if(ametRstatic=="")                            { ametRstatic <- "./"               }
 writeLines(paste("AMET R Config input file:",ametRinput))
 writeLines(paste("AMET R Static input file:",ametRstatic))

 ## source some configuration files, AMET libs, and input
 source (paste(ametR,"/MET_amet.misc-lib.R",sep=""))
 source (paste(ametR,"/MET_amet.plot-lib.R",sep=""))
 source (paste(ametR,"/MET_amet.stats-lib.R",sep=""))
 source (mysqlloginconfig)
 source (ametRinput)
 try(source (ametRstatic),silent=T)

 ametdbase      <- Sys.getenv("AMET_DATABASE")
 mysqlserver    <- Sys.getenv("MYSQL_SERVER")
 mysql          <-list(server=mysqlserver,dbase=ametdbase,login=amet_login,
                        passwd=amet_pass,maxrec=maxrec)

 # Site data count below which site is skipped at statistics set to NA
 # Logic added for backward compatibility where thresh is ENV setting
 # Or directly specified in ametRinput like in AMET GUI
 thresh_env     <- as.numeric(Sys.getenv("THRESHOLD"))
 if(!exists("thresh") & is.na(thresh_env)){ 
    writeLines(paste("*** WARNING ***   Threshold count for statistics not defined. Setting to 24..."))
    thresh <- 24 
 }
 if(is.numeric(thresh_env) & !exists("thresh")){ 
    thresh <- thresh_env
 }

 dates <- mdy.date(month = ms, day = ds, year = ys)
 datee <- mdy.date(month = me, day = de, year = ye)+1
 dateep<- mdy.date(month = me, day = de, year = ye)
############################################################################
nd     <-c(31,leapy(ys),31,30,31,30,31,31,30,31,30,31)
datex  <-dates
while(datex <= datee) {
  if(!exists("daily")) { daily <-F }   
  if(daily) {	      
    d1       <-date.mdy(datex)
    d2       <-date.mdy(datex+1)
    d2p      <-date.mdy(datex)

    d1p      <-paste(d1$year,dform(d1$month),dform(d1$day),sep="")
    d2p      <-paste(d2p$year,dform(d2$month),dform(d2p$day),sep="")
    d1q      <-paste(d1$year,"-",dform(d1$month),"-",dform(d1$day),sep="")
    d2q      <-paste(d2$year,"-",dform(d2$month),"-",dform(d2$day),sep="")
    savefile <-paste(savedir,"/",saveid,".",d1p,"-",d2p,".RData",sep="")
    daterange<-paste(d1p,"-",d2p,sep="")
  }
  else {
    d1       <-date.mdy(dates)
    d2       <-date.mdy(datee)
    d2p      <-date.mdy(dateep)

    d1p      <-paste(d1$year,dform(d1$month),dform(d1$day),sep="")
    d2p      <-paste(d2p$year,dform(d2p$month),dform(d2p$day),sep="")
    d1q      <-paste(d1$year,"-",dform(d1$month),"-",dform(d1$day),sep="")
    d2q      <-paste(d2$year,"-",dform(d2$month),"-",dform(d2$day),sep="")
    datex    <-datee       
    savefile <-paste(savedir,"/",saveid,".",d1p,"-",d2p,".RData",sep="")
    daterange<-paste(d1p,"-",d2p,sep="")
  }
  datestr  <-paste("BETWEEN '",d1q,"' AND '",d2q,"'",sep="")
  datestr  <-paste(">= '",d1q,"' AND d.ob_date < '",d2q,"'",sep="")
  datestrp <-paste("BETWEEN ",d1p," AND ",d2p,sep="")
  query    <-paste("SELECT  d.stat_id,d.T_mod,d.T_ob,d.Q_mod,d.WVMR_ob, d.U_mod,d.U_ob, d.V_mod,d.V_ob, 
                    HOUR(d.ob_time) FROM ",sfctable,"  d, stations s  WHERE s.stat_id=d.stat_id and d.ob_date ",
                    datestr,extra," ORDER BY d.stat_id ")
  qstat    <-paste("SELECT  DISTINCT s.stat_id, s.lat, s.lon, s.elev  FROM ",sfctable," d, stations s WHERE 
                    d.stat_id=s.stat_id AND d.ob_date ",datestr,extra," ORDER BY s.stat_id ")

  if(file.exists(savefile) & checksave ) {
    load(savefile)
  }
  else {
    writeLines(paste(query))
    writeLines(paste(qstat))
    sstats<-try(stationStatsSfc(query,qstat,mysql,wsmin=0.5,thresh=thresh,t.test=t.test.flag),silent=FALSE)
  } 	
  if(wantsave ){
    try(save(sstats,file=savefile))
  }	

  if(textstats){
    t.dframe  <-data.frame(sstats$stationID, sstats$lat, sstats$lon, sstats$metrics[,,1], row.names=sstats$stationID,check.names=F)
    ws.dframe <-data.frame(sstats$stationID, sstats$lat, sstats$lon, sstats$metrics[,,2], row.names=sstats$stationID,check.names=F)
    wd.dframe <-data.frame(sstats$stationID, sstats$lat, sstats$lon, sstats$metrics[,,3], row.names=sstats$stationID,check.names=F)
    q.dframe  <-data.frame(sstats$stationID, sstats$lat, sstats$lon, sstats$metrics[,,4], row.names=sstats$stationID,check.names=F)        

    head      <-"station_id, lat, lon"
    for(n in 1:length(statAbr) ){
     head     <-paste(head,statAbr[n],sep=", ")
    }
    	   
    tmp.file      <-paste(figdir,"/tmp",sep="")
    head.file     <-paste(figdir,"/head",sep="")
    t.dframe.file <-  paste(figdir,"/",model,".spatial.temp2m.stats.",daterange,".csv",sep="")
    ws.dframe.file<-  paste(figdir,"/",model,".spatial.wndspd10m.stats.",daterange,".csv",sep="")
    wd.dframe.file<-  paste(figdir,"/",model,".spatial.wnddir10m.stats.",daterange,".csv",sep="")
    q.dframe.file <-  paste(figdir,"/",model,".spatial.mixr2m.stats.",daterange,".csv",sep="")

    sfile <-file(head.file) 
    writeLines(head, con =sfile)
    close(sfile)

    write.table(t.dframe,file=tmp.file,sep=",",quote=F,col.names=F, row.names=F)
    system(paste("cat ",head.file,tmp.file," > ",t.dframe.file,sep=" "))

    write.table(ws.dframe,file=tmp.file,sep=",",quote=F,col.names=F, row.names=F)
    system(paste("cat ",head.file,tmp.file," > ",ws.dframe.file,sep=" "))

    write.table(wd.dframe,file=tmp.file,sep=",",quote=F,col.names=F, row.names=F)
    system(paste("cat ",head.file,tmp.file," > ",wd.dframe.file,sep=" "))

    write.table(q.dframe,file=tmp.file,sep=",",quote=F,col.names=F, row.names=F)
    system(paste("cat ",head.file,tmp.file," > ",q.dframe.file,sep=" "))

    system(paste("rm -f",tmp.file,head.file)) 
  }

  if ( length(sstats$stationID) == 0){
  	writeLines("No records were found in the database for the following query:")
  	writeLines(query)
  	quit(save="no")
  }
#---------------------------------------------------##
 for (v in 1:length(vget)) {
  for (s in 1:length(sget)) {
    statloc    <-sget[s]
    varloc     <-vget[v]
    plotlab[1] <-paste(statid[statloc],"of",varid[varloc],"  Date:",datestrp)
     
    plotlab[2] <-paste("Query:",query)
    plotlab[3] <-paste("Database:",ametdbase)
    fileName   <-paste(figdir,"/",saveid,".",statAbr[statloc],".",varAbr[varloc],".",daterange,sep="")
    plotval    <-sstats$metrics[,statloc,varloc]
    if( length(na.omit(plotval)) == 0 ) { next }
    sinfo      <-list(lat=sstats$lat,lon=sstats$lon,plotval=plotval,levs=na.omit(levs[statloc,varloc,]),
                      levcols=na.omit(levcols[statloc,varloc,]),convFac=convfactor[varloc])
    #---------------------------------------------------##
    #           Plot Spatial statisitics
    if(wantfigs){
      if(!exists("bounds") || is.na(bounds[1])) {
        bounds <-c(min(sstats$lat),max(sstats$lat),min(sstats$lon),max(sstats$lon))
      }
      try(plotSpatial(sinfo,varlab=plotlab,figure=fileName,bounds=bounds,plotopts=plotopts,
                      sres=sres,histplot=histplot,shadeplot=shadeplot))
      writeLines(fileName)
      try(dev.off(),silent=T)
    }
   } # END LOOP THROUGH STATISTICS
 }
 datex <-datex+1
}# End LOOP OVER DATES
############################################################################
############################################################################

############################################################################
# New in Version 1.3: Text file with set SITES=(....) string to use in
# run_timeseries plots. Includes all sites in domain.
 ns   <-length(sstats$stationID)
 str  <-paste("set SITES=(",sstats$stationID[1],sep="")
 for(s in 2:ns) {  
  str <-paste(str," ",sstats$stationID[s],sep="")
 }
 str  <-paste(str,")",sep="")
 sfile<-file(paste(figdir,"/spatial.setSITES.all.txt",sep=""),"w") 
 writeLines(str, con =sfile)
 close(sfile)
############################################################################
#quit(save='no')

