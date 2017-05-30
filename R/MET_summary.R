#########################################################################
#-----------------------------------------------------------------------#
#						 			#
#		AMET (Automated Model Evaluation Tool)			#
#						 			#
#			SUMMRAY	                		 	#
#			       summary.R			 	#
#                                                                       #
#						 			#
#  This R script is used by the AMET tool to extract a          	#
#  dataset via user-contructed query. Once data is queried, a R data	#
#  file is saved and several statistical plots are automatically        #
#  generated.			                                        #
#                                                                       #
#	Version: 	1.1					 	#
#	Date:		June 02, 2004					#
#	Contributors:	Robert Gilliam					#
#                                                                       #
#	Developed by and for NOAA, ARL, ASMD on assignment to US EPA	#
#                                                                       #
#-----------------------------------------------------------------------#
#       Changed to summary.R and modified for MET/AQ combined           #
#       setup -- Alexis Zubrow (IE UNC), Oct 2007                       #
#						 			#
#                                                                       #
#########################################################################

########################################################
#    Initialize AMET Diractory Structure Via Env. Vars
#    AND Load required function and conf. files
##############################################################################################

## get some environmental variables and setup some directories
  term<-Sys.getenv("TERM") 				# are we using via the web or not?
  ametbase<-Sys.getenv("AMETBASE") 			# base directory of AMET
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
  source (ametRinput)	                                # Anaysis configuration/input file

  ## Plot configurations
  plotfmt	<-Sys.getenv("AMET_PTYPE")						# Plot format
  plotopts	<-list(plotfmt=plotfmt,plotsize=plotsize,symb=symb,symbsiz=symbsiz)
  dstatloc	<-c(16,17,18)      
  
#	Load required modules
  if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}
  if(!require(maps)){stop("Required Package maps was not loaded")}
  
  nhdelay<-1

 # If timeseries is setup in realtime mode, the start and end date are determined 
 # by the system date/time
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
########################################################################################################################
#	MAIN TIME SERIES PROGRAM
########################################################################################################################
 # Setup/Config. meteorological variable names/id's, and set max records
 mysql		<-list(server=server,dbase=dbase,login=login,passwd=passwd,maxrec=maxrec)
 
 varsName	<-c("Temperature (2m)","Specific Humidity (2m)","Wind Speed (10m)","Wind Direction (deg.)")
 varid		<-c("T","Q","WS","WD")
 ####################################
 # Build MySQL query from input data
 ####################################
 varxstr	<-paste("SELECT DATE_FORMAT(ob_date,'%Y%m%d'),HOUR(ob_time),d.stat_id,s.ob_network,d.T_mod,d.T_ob, d.Q_mod,d.WVMR_ob, d.U_mod,d.U_ob, d.V_mod,d.V_ob")
 
	# Station ID
	if(length(statid) == 1){ # One station or all stations
		if(statid == "ALL"){ # All stations
			stat_qry <- ""		
		} else{
			stat_qry <- paste("AND d.stat_id=",statid,sep="")
		}
	} else{ # Multiple selected stations
		stat_list <- paste("d.stat_id=",statid[1],sep="")

		for(tmp in statid[2:length(statid)]){
			stat_list <- paste(stat_list," OR d.stat_id=",tmp,sep="")
		}
		stat_qry <- paste("AND (", stat_list, ")",sep="")
		statid <- "Multiple Stations"
	}

	# Latitude
	if(lat == "ALL"){
		lat_qry <- ""
	} else{
		lat_qry <- paste("AND s.lat BETWEEN ",lat[1]," AND ",lat[2],sep="")
	}
	
	# Longitude
	if(lon == "ALL"){
		lon_qry <- ""
	} else{
		lon_qry <- paste("AND s.lon BETWEEN ",lon[1]," AND ", lon[2], sep="")
	}

	# dates
	date_qry <- paste("AND d.ob_date BETWEEN ",dates," AND ", datee, sep="")
	
	query <-paste(varxstr, " FROM ", project, "_surface d, stations s WHERE  s.stat_id=d.stat_id ", stat_qry, " ", lat_qry, " ", lon_qry, " ", date_qry, " ", querystr, sep="") # Surface data table in evaluation database

################################################################################
# LOOP through the query array and generate statistics and plots 
#   1) Query the database for the met dataprint
#   2) Massage the met data (convert u,v to ws and wd, etc)
#   3) Make a R data file and text file of time series if user specifies
#   4) Find min and max date, create hourly date object over that period, match data (date) extracted from database to this date time object, then create time series
#   5) Plot time series
################################################################################
 for(q in 1:length(query)){
   
    #   1) Query the database for the met data
    writeLines("Query used to extract data from MySQL database:")
    data<-ametQuery(query[q],mysql)
    if (length(na.omit(data)) == 0){
    	stop(
		     paste('',
		           '**********************************************************************************',
		           'NO DATA WAS FOUND FOR THIS QUERY: Please change some of the criteria and try again',
		           '**********************************************************************************',sep="\n")
		     )
	}	# stop if no data is found

    # Save dataframe into R datafile if specified
    if(wantsave){
         save(data,file=paste(savedir,"/",pid[q],".web_query.Rdata",sep=""))
    }
    
    # if text statistics are specified, open text file and write header lines
    if (textstats){   
         sfile<-file(paste(figdir,"/tmp",sep=""),"w") 
         writeLines("Model Evaluation Metrics", con =sfile)
         writeLines("--------------------------------------------------------", con =sfile)
    }

    locs<-c(1,2,3,4,5,6,9,10,11,12,7,8)
    datap<-massageTseries(data,loc=locs,iftseries=F,addrand=TRUE)
    
    if (diurnal){
         ################################
         #	Temperature Stats	#
         ################################
         writeLines("Plotting diurnal Temperature.. Figure name:")
         figure<-paste(figdir,"/",project,".",pid[q],".T.diurnal",sep="")
         obs<-datap$temp[,2]
         mod<-datap$temp[,1]
         if(length(na.omit(obs)) > 0 ) {
         var<-data.frame(as.POSIXlt(datap$date, tz="GMT")$hour,mod,obs)
         labels<-list(varname="2 m Temperature",amet="NOAA/EPA AMET Product",units="K")
         try(dstats<-diurnalplot(var,statloc=dstatloc,figure,plotopts=plotopts,labels=labels))

         if (textstats){
    	      sfile<-file(paste(figdir,"/tmp",sep=""),"a") 
    	      writeLines("--------------------------------------------------------", con =sfile)
              writeLines("Diurnal Temperature (2 m) Statistics", con =sfile)
              close(sfile)
    
              tmp<-data.frame(dstats$metrics)
              write.table(tmp,paste(figdir,"/tmpx",sep=""),sep=",",col.names=dstats$id, row.names=F, quote=FALSE)
              system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
              system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))
         }
         rm(obs,mod,var,stats,tmp)
         }
         #######################################################################################
         ################################
         #	Wind Speed Stats	#
         ################################
         writeLines("Plotting diurnal Wind Speed.. Figure name:")
         figure<-paste(figdir,"/",project,".",pid[q],".WS.diurnal",sep="")
         obs<-datap$ws[,2]
         mod<-datap$ws[,1]
         if(length(na.omit(obs)) > 0 ) {
         var<-data.frame(as.POSIXlt(datap$date, tz="GMT")$hour,mod,obs)
         labels<-list(varname="10 m Wind Speed",amet="NOAA/EPA AMET Product",units="m/s")
         try(dstats<-diurnalplot(var,statloc=dstatloc,figure,plotopts=plotopts,labels=labels))

         if (textstats){
    	      sfile<-file(paste(figdir,"/tmp",sep=""),"a") 
    	      writeLines("--------------------------------------------------------", con =sfile)
              writeLines("Diurnal Wind Speed (10 m) Statistics", con =sfile)
              close(sfile)
    
              tmp<-data.frame(dstats$metrics)
              write.table(tmp,paste(figdir,"/tmpx",sep=""),sep=",",col.names=dstats$id,quote=FALSE, row.names=F)
              system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
              system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))
         }
         rm(obs,mod,var,stats,tmp)
         }
         #######################################################################################
         ################################
         #	Wind Direction Stats	#
         ################################
         writeLines("Plotting diurnal Wind Direction.. Figure name:")
         figure<-paste(figdir,"/",project,".",pid[q],".WD.diurnal",sep="")
         obs=datap$wd[,2]
         mod=datap$wd[,1]
         diff<-mod-obs
         diff<-ifelse(diff > 180 , diff-360, diff)
         diff<-ifelse(diff< -180 , diff+360, diff)
         obs<-runif(length(diff),min=0,max=0.001)
         mod<-diff
         if(length(na.omit(obs)) > 0 ) {
         var<-data.frame(as.POSIXlt(datap$date, tz="GMT")$hour,mod,obs)
         labels<-list(varname="10 m Wind Direction",amet="NOAA/EPA AMET Product",units="deg")
         try(dstats<-diurnalplot(var,statloc=dstatloc,figure,plotopts=plotopts,labels=labels))

         if (textstats){
    	      sfile<-file(paste(figdir,"/tmp",sep=""),"a") 
    	      writeLines("--------------------------------------------------------", con =sfile)
              writeLines("Diurnal Wind Direction (10 m) Statistics", con =sfile)
              close(sfile)
    
              tmp<-data.frame(dstats$metrics)
              write.table(tmp,paste(figdir,"/tmpx",sep=""),sep=",",col.names=dstats$id,quote=FALSE, row.names=F)
              system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
              system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))
         }
         rm(obs,mod,var,stats,tmp)
         }
         #######################################################################################
         ################################
         #	Mixing Ratio Stats	#
         ################################
         writeLines("Plotting diurnal Mixing Ratio.. Figure name:")
         figure<-paste(figdir,"/",project,".",pid[q],".Q.diurnal",sep="")
         obs<-datap$q[,2]*1000
         mod<-datap$q[,1]*1000
         if(length(na.omit(obs)) > 0 ) {
         var<-data.frame(as.POSIXlt(datap$date, tz="GMT")$hour,mod,obs)
         labels<-list(varname="2 m Mixing Ratio",amet="NOAA/EPA AMET Product",units="g/kg")
         try(dstats<-diurnalplot(var,statloc=dstatloc,figure,plotopts=plotopts,labels=labels))

         if (textstats){
    	      sfile<-file(paste(figdir,"/tmp",sep=""),"a") 
    	      writeLines("--------------------------------------------------------", con =sfile)
              writeLines("Diurnal Mixing Ratio (2 m) Statistics", con =sfile)
              close(sfile)
    
              tmp<-data.frame(dstats$metrics)
              write.table(tmp,paste(figdir,"/tmpx",sep=""),sep=",",col.names=dstats$id,quote=FALSE, row.names=F)
              system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
              system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))
         }
         rm(obs,mod,var,stats,tmp)
         }
         #######################################################################################

  }	## 	END OF DIURNAL PLOTS AND TABLES
  
  ###################################################################################################
  #	AMET Performance Plot Option
  ###################################################################################################
  if (ametp){
         #######################################################################################
         ################################
         #	Temperature Stats	#
         ################################
         figure<-paste(figdir,"/",project,".",pid[q],".T.ametplot",sep="")
         qdesc<-c(mysql$server,mysql$dbase,mysql$login,mysql$passwd,project,model,queryID[q],varid[1],statid,obnetwork,lat[1],lon[1],elev,landuse,dates[q],datee[q],obtime,fcasthr,level,syncond,query[q],figure,1)
         obs=datap$temp[,2]
         mod=datap$temp[,1]
         if(length(na.omit(obs)) > 0 ) {
         var<-list(obs=obs,mod=mod)
         stats<-genvarstats(var,varsName[1])
         try(ametplot(obs,mod,datap$ws[,2],stats$metrics,qdesc=qdesc,pid=pid,figureid=figure,plotopts=plotopts))
          if (textstats){
    	      sfile<-file(paste(figdir,"/tmp",sep=""),"a") 
    	      writeLines("--------------------------------------------------------", con =sfile)
              writeLines("Collective Temperature (2 m) Statistics", con =sfile)
              close(sfile)
    
              tmp<-data.frame(stats$id,stats$metrics)
              write.table(tmp,paste(figdir,"/tmpx",sep=""),sep=",",quote=FALSE, row.names=F)
              system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
              system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))
         }
         rm(obs,mod,var,stats,tmp)
         }
         #######################################################################################
         ################################
         #	Wind Speed Stats	#
         ################################
         figure<-paste(figdir,"/",project,".",pid[q],".WS.ametplot",sep="")
         qdesc<-c(mysql$server,mysql$dbase,mysql$login,mysql$passwd,project,model,queryID[q],varid[3],statid,obnetwork,lat[1],lon[1],elev,landuse,dates[q],datee[q],obtime,fcasthr,level,syncond,query[q],figure,1)
         obs=datap$ws[,2]
         mod=datap$ws[,1]
         if(length(na.omit(obs)) > 0 ) {
         var<-list(obs=obs,mod=mod)
         stats<-genvarstats(var,varsName[3])
         try(ametplot(obs,mod,datap$ws[,2],stats$metrics,qdesc=qdesc,pid=pid,figureid=figure,plotopts=plotopts))

          if (textstats){
    	      sfile<-file(paste(figdir,"/tmp",sep=""),"a") 
    	      writeLines("--------------------------------------------------------", con =sfile)
              writeLines("Collective Wind Speed (10 m) Statistics", con =sfile)
              close(sfile)
    
              tmp<-data.frame(stats$id,stats$metrics)
              write.table(tmp,paste(figdir,"/tmpx",sep=""),sep=",",quote=FALSE, row.names=F)
              system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
              system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))
         }
         rm(obs,mod,var,stats,tmp)
         }
        #######################################################################################
         ################################
         #	Wind Direction Stats	#
         ################################
         writeLines("Plotting summary of Wind Direction.. Figure name:")
         figure<-paste(figdir,"/",project,".",pid[q],".WD.ametplot",sep="")
         qdesc<-c(server,dbase,login,passwd,project,model,queryID[q],varid[4],statid,obnetwork,lat[1],lon[1],elev,landuse,dates[q],datee[q],obtime,fcasthr,level,syncond,query[q],figure,4)
         obs=datap$wd[,2]
         mod=datap$wd[,1]
         diff<-mod-obs
         diff<-ifelse(diff > 180 , diff-360, diff)
         diff<-ifelse(diff< -180 , diff+360, diff)
         obs<-runif(length(diff),min=0,max=0.001)
         mod<-diff
         if(length(na.omit(obs)) > 0 ) {
         var<-list(obs=obs,mod=mod)
         stats<-genvarstats(var,varsName[4])
         try(ametplot(obs,mod,datap$ws[,2],stats$metrics,qdesc=qdesc,pid=pid,figureid=figure,wdflag=1,plotopts=plotopts))

          if (textstats){
   	      sfile<-file(paste(figdir,"/tmp",sep=""),"a") 
    	      writeLines("--------------------------------------------------------", con =sfile)
              writeLines("Collective Wind Direction (10 m) Statistics", con =sfile)
              close(sfile)
    
              tmp<-data.frame(stats$id,stats$metrics)
              write.table(tmp,paste(figdir,"/tmpx",sep=""),sep=",",quote=FALSE)
              system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
              system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))
         }
         rm(obs,mod,var,stats,tmp)
         }
        #######################################################################################
         ################################
         #	Mixing Ratio Stats	#
         ################################
         writeLines("Plotting summary of Mixing Ratio.. Figure name:")
         figure<-paste(figdir,"/",project,".",pid[q],".Q.ametplot",sep="")
         qdesc<-c(mysql$server,mysql$dbase,mysql$login,mysql$passwd,project,model,queryID[q],varid[2],statid,obnetwork,lat[1],lon[1],elev,landuse,dates[q],datee[q],obtime,fcasthr,level,syncond,query[q],figure,1)
         obs=datap$q[,2]*1000
         mod=datap$q[,1]*1000
         if(length(na.omit(obs)) > 0 ) {
         var<-list(obs=obs,mod=mod)
         stats<-genvarstats(var,varsName[2])
         try(ametplot(obs,mod,datap$ws[,2],stats$metrics,qdesc=qdesc,pid=pid,figureid=figure,plotopts=plotopts))

          if (textstats){
    	      sfile<-file(paste(figdir,"/tmp",sep=""),"a") 
    	      writeLines("--------------------------------------------------------", con =sfile)
              writeLines("Collective Mixing Ratio (2 m) Statistics", con =sfile)
              close(sfile)
    
              tmp<-data.frame(stats$id,stats$metrics)
              write.table(tmp,paste(figdir,"/tmpx",sep=""),sep=",",quote=FALSE)
              system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
              system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))
         }
         rm(obs,mod,var,stats,tmp)
         }
        #######################################################################################

   }	## END of AMET PLOT
   # If Text statistic file is generated mv final temporary file figdir/tmp to savedir/stats.some_process_id.dat	
   if (textstats){
   	system(paste("mv ",figdir,"/tmp ",savedir,"/stats.",project,".",pid[q],".dat",sep=""))
   	system(paste("rm -f ",figdir,"/tmp* ",sep=""))
   }
 } #   END OF LOOP THROUGH Queries
