#########################################################################
#-----------------------------------------------------------------------#
#		AMET (Atmospheric Model Evaluation Tool)                            #
#                                                                       #
#			PLOT STATION STATISTICS			                             	        #
#									                                                      #
#	An AMET "R" script that plots station statistics for a		            #
#	given queried dataset.					                             	        #
#						 			                                                      #
#	Version: 	1.1					                                                #
#	Date:		April 13, 2004					                                      #
#	Contributors:	Robert Gilliam					                                #
#						 			                                                      #
#	Developed by and for NOAA, ARL, ASMD on assignment to US EPA	        #
#-----------------------------------------------------------------------#
# Change LOG
# daily_station_stats-1.1 (05/04/2004)	
#	Initial deveopment: The program currently reads a configuration file that is placed in
#	the location where the execution takes place. The configuration allows user to choose
#	a start day and month, and an end day and month. Also, specific database, table/project ID,
#	area to examine (lat-lon bounds), figure and save file directories
#
# daily_station_stats-1.2 (09/06/2005)
#	Modified daily_spatial.R to "new" (summer 2005) unified format that joins the web version
#	and old automated version. This was done by using AMET environmental variables. The initalization
#	section below 
#
# Modified to work with combined MET/AQ mode, Alexis Zubrow (IE UNC) Oct, 2007
#
# Changed name to MET_spatial_surface.R, Alexis Zubrow (IE UNC) Nov, 2007
#
# Version 1.2, May 8, 2013, Rob Gilliam                                 
# Updates: - Pulled some configurable options out of MET_spatial_surface.R    
#            and placed into the spatial_surface.input file  
#          - Sample threshold so sites where sample size is small are ignored 
#          - Spatial plot bounds can be manually specified in run_spatial_surface.csh 
#          - text file with set SITES=(....) string of all site id's in domain
#            This is helpful to use in run_timeseries.csh script. File: spatial.setSITES.all.txt               
#          - Extensive cleaning of R script, R input and .csh files     
#########################################################################
#	Load required modules
  if(!require(maps)){stop("Required Package maps was not loaded")}
  if(!require(mapdata)){stop("Required Package mapdata was not loaded")}
  if(!require(date)){stop("Required Package date was not loaded")}
  if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}
  if(!require(akima)){stop("Required Package akima was not loaded")}
  if(!require(fields)){stop("Required Package fields was not loaded")}

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#    Initialize AMET Diractory Structure Via Env. Vars
#    AND Load required function and conf. files
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## get some environmental variables and setup some directories
  term<-Sys.getenv("TERM") 				                      # are we using via the web or not?
  ametbase<-Sys.getenv("AMETBASE") 			                # base directory of AMET
  ametR<-paste(ametbase,"/R",sep="")                    # R directory
  ametRinput <- Sys.getenv("AMETRINPUT")                # input file for this script


  # Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
  # and not specified via AMET_OUT, then set figdir to the current directory
  if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")	}
  if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"			}

  ## source some configuration files, AMET libs, and input
  source(paste(ametbase,"/configure/amet-config.R",sep=""))
  source (paste(ametR,"/MET_amet.misc-lib.R",sep=""))  	# Miscellanous AMET R-functions file
  source (paste(ametR,"/MET_amet.plot-lib.R",sep=""))  	# AMET Plot functions file
  source (paste(ametR,"/MET_amet.stats-lib.R",sep=""))  # AMET Plot functions file
  source (ametRinput)	                                  # Anaysis configuration/input file

  nhdelay<-1

 if (realtime){
     a<-system(" date '+%y%m%d%H'",intern=TRUE)
     b<-unlist(strsplit(a,split=""))
     ys<-2000+as.numeric(paste(b[1],b[2],sep=""));ye<-ys
     ms<-as.numeric(paste(b[3],b[4],sep=""));me<-ms
     ds<-as.numeric(paste(b[5],b[6],sep=""));de<-ds
     hs<-as.numeric(paste(b[7],b[8],sep=""));he<-hs
     datee<-list(y=ye,m=me,d=de,h=he)
     datee<-datecalc(datee,5,"hour")
 }

 dates<-mdy.date(month = ms, day = ds, year = ys)
 datee<-mdy.date(month = me, day = de, year = ye)

 #ndays<-datee-dates
 #thresh<- round(ndays*0.50)

######################################################
 mysql<-list(server=server,dbase=dbase,login=login,passwd=passwd,maxrec=maxrec)
 nd=c(31,leapy(ys),31,30,31,30,31,31,30,31,30,31);
     
 datex<-dates
 while(datex <= datee) {
  if(!exists("daily")) { daily <-T }   # Make compatible with old versions of input file that do not contain daily flag	
  if(daily) {	      # Flag to compute daily rather than period-based spatial statistics
	  d1<-date.mdy(datex)     
	  d2<-date.mdy(datex+1)     
	  d1<-paste(d1$year,dform(d1$month),dform(d1$day),sep="")
	  d2<-paste(d2$year,dform(d2$month),dform(d2$day),sep="")
    savefile<-paste(savedir,"/",saveid,".",d1,".RData",sep="")
    daterange<-d1
  }
  else {
	  d1<-date.mdy(dates)     
	  d2<-date.mdy(datee)     
	  d1<-paste(d1$year,dform(d1$month),dform(d1$day),sep="")
	  d2<-paste(d2$year,dform(d2$month),dform(d2$day),sep="")
    datex<-datee       
    savefile<-paste(savedir,"/",saveid,".",d1,".",d2,".RData",sep="")
    daterange<-paste(d1,".",d2,sep="")
  }
	datestr<-paste("BETWEEN",d1,"AND",d2)
	query<-paste("SELECT  d.stat_id,d.T_mod,d.T_ob,d.Q_mod,d.WVMR_ob, d.U_mod,d.U_ob, d.V_mod,d.V_ob, HOUR(d.ob_time) FROM ",
	          sfctable,"  d, stations s  WHERE s.stat_id=d.stat_id and d.ob_date ",datestr,extra," ORDER BY d.stat_id ")
	qstat<-paste("SELECT  DISTINCT s.stat_id, s.lat, s.lon, s.elev  FROM ",sfctable," d, stations s WHERE d.stat_id=s.stat_id AND d.ob_date ",datestr,extra," ORDER BY s.stat_id ")
  
	monthAbr<-c("JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC")
        

	if(file.exists(savefile) & checksave ) {
  		load(savefile)
	}
	else {
    sstats<-try(stationStatsSfc(query,qstat,mysql,wsmin=0.5,thresh=thresh,t.test=t.test.flag),silent=FALSE)
   } 	
  if(wantsave ){
    try(save(sstats,file=savefile))
  }	

  if(textstats){
    t.dframe<-data.frame(sstats$stationID, sstats$lat, sstats$lon, sstats$metrics[,,1], row.names=sstats$stationID,check.names=F)
    ws.dframe<-data.frame(sstats$stationID, sstats$lat, sstats$lon, sstats$metrics[,,2], row.names=sstats$stationID,check.names=F)
    wd.dframe<-data.frame(sstats$stationID, sstats$lat, sstats$lon, sstats$metrics[,,3], row.names=sstats$stationID,check.names=F)
    q.dframe<-data.frame(sstats$stationID, sstats$lat, sstats$lon, sstats$metrics[,,4], row.names=sstats$stationID,check.names=F)        

    head<-"station_id, lat, lon"
    for(n in 1:length(statAbr) ){
     head<-paste(head,statAbr[n],sep=", ")
    }
    	   
    tmp.file<-paste(figdir,"/tmp",sep="")
    head.file<-paste(figdir,"/head",sep="")
    t.dframe.file<-  paste(figdir,"/",model,".spatial.temp.stats.csv",sep="")
    ws.dframe.file<- paste(figdir,"/",model,".spatial.wndspd.stats.csv",sep="")
    wd.dframe.file<- paste(figdir,"/",model,".spatial.wnddir.stats.csv",sep="")
    q.dframe.file<-  paste(figdir,"/",model,".spatial.mixr.stats.csv",sep="")

    sfile<-file(head.file) 
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
    statloc<-sget[s]
    varloc<-vget[v]
    plotlab[1]<-paste(statid[statloc],"of",varid[varloc],"  Date:",datestr)
     
    plotlab[2]<-paste("Query:",query)
    plotlab[3]<-paste("Database:",dbase)
    fileName<-paste(figdir,"/",saveid,".",d1,".",statAbr[statloc],".",varAbr[varloc],sep="")
    fileName<-paste(figdir,"/",saveid,".",statAbr[statloc],".",varAbr[varloc],".",daterange,sep="")
    plotval<-sstats$metrics[,statloc,varloc]
    if( length(na.omit(plotval)) == 0 ) { next }
    sinfo<-list(lat=sstats$lat,lon=sstats$lon,plotval=plotval,levs=na.omit(levs[statloc,varloc,]),levcols=na.omit(levcols[statloc,varloc,]),convFac=convfactor[varloc])
		#---------------------------------------------------##
		#	Plot Spatial statisitics
    if(wantfigs){
      sstats$lon<-ifelse(sstats$lon > 0,sstats$lon*-1,sstats$lon)
      if(!exists("bounds") || is.na(bounds[1])) {
        bounds<-c(min(sstats$lat),max(sstats$lat),min(sstats$lon),max(sstats$lon))
      }
      try(plotSpatial(sinfo,varlab=plotlab,figure=fileName,bounds=bounds,plotopts=plotopts,sres=sres,histplot=histplot,shadeplot=shadeplot))
      writeLines(fileName)
      #system(paste(convert," -trim ",fileName,".",plotopts$plotfmt," ",fileName,".",plotopts$plotfmt,sep=""),ignore.stderr = T)
      try(dev.off(),silent=T)
    }
		#---------------------------------------------------##
	} # END LOOP THROUGH STATSTIC
 }
	datex<-datex+1
}# End LOOP over specified dates

# New in Version 1.3: Text file with set SITES=(....) string to use in run_timeseries plots. Includes all sites in domain.
 ns<-length(sstats$stationID)
 str<-paste("set SITES=(",sstats$stationID[1],sep="")
 for(s in 2:ns) {  
  str<-paste(str," ",sstats$stationID[s],sep="")
 }
 str<-paste(str,")",sep="")
 
 sfile<-file(paste(figdir,"/spatial.setSITES.all.txt",sep=""),"w") 
 writeLines(str, con =sfile)
 close(sfile)
