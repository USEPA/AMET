#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#                AMET (Atmospheric Model Evaluation Tool)               #
#                                                                       #
#                    Timeseries of T, Q, WS, WD                         #
#                        MET_timeseries.R                               #
#                                                                       #
#                                                                       #
#         Version: 	1.3                                                 #
#         Date:		May 15, 2017                                          #
#         Contributors:	Robert Gilliam                                  #
#                                                                       #
#         Developed by the US Environmental Protection Agency           #
#-----------------------------------------------------------------------#
#########################################################################
#                                                                       #
#	Version: 	1.2                                                         #
#	Date:		Oct, 2007                                                     #
#	Contributors:	Alexis Zubrow (IE UNC)                                  #
#                                                                       #
#-----------------------------------------------------------------------#
# Version 1.2, May 8, 2013, Rob Gilliam                                 #
#   Updates: - Pulled  some user configurable settings from             #
#              MET_timeseries.R and placed in timeseries.input          #
#            - Catch in place for sites that may not have T, Q and Wind #
#              Maritime sites for example do not have Q. In these cases #
#              mod-obs are set to constant value and stats to zero      #
#            - In case of multiple sites, text file for each plot       #
#            - Extensive code clean and reformatting                    #
#                                                                       #
#  Version 1.3, May 15, 2017, Rob Gilliam                               # 
#  Updates: - Removed hard coded amet-config.R config option that       #
#             defined MySQL server, database and password (unsecure).   #
#             Now users define that file location in csh wrapper scripts#
#             via setenv MYSQL_CONFIG variable.                         #
#           - Removed some deprecated variables and cleaned/formatted   #
#             script for better readability. Also changed dir names     #
#             to reflect the update (i.e., R_analysis_code instead of R)#      
#-----------------------------------------------------------------------#
#                                                                       #
#########################################################################
#########################################################################
#	Load required modules
  if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}
  if(!require(date))  {stop("Required Package date was not loaded")  }
########################################################
#    Initialize AMET Diractory Structure Via Env. Vars
#    AND Load required function and conf. files
##############################################################################################

## get some environmental variables and setup some directories
 ametbase         <-Sys.getenv("AMETBASE")
 ametR            <-paste(ametbase,"/R_analysis_code",sep="")
 ametRinput       <- Sys.getenv("AMETRINPUT")
 mysqlloginconfig <-Sys.getenv("MYSQL_CONFIG")

 # Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
 # and not specified via AMET_OUT, then set figdir to the current directory
 if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")	}
 if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"			}
  
 ## source some configuration files, AMET libs, and input
 source (paste(ametR,"/MET_amet.misc-lib.R",sep=""))
 source (paste(ametR,"/MET_amet.plot-lib.R",sep=""))
 source (paste(ametR,"/MET_amet.stats-lib.R",sep=""))
 source (mysqlloginconfig)
 source (ametRinput)

 ametdbase      <- Sys.getenv("AMET_DATABASE")
 mysqlserver    <- Sys.getenv("MYSQL_SERVER")
 mysql          <-list(server=mysqlserver,dbase=ametdbase,login=amet_login,
                        passwd=amet_pass,maxrec=maxrec)

########################################################################################################################
#	MAIN TIME SERIES PROGRAM
########################################################################################################################

  drange_plot <-paste(dates$y,dform(dates$m),dform(dates$d),"-",datee$y,dform(datee$m),dform(datee$d),sep="")

  # If the time series should be an hourly average of a collection  of stations, 
  # convert the station id vector, which contains multiple stations, to a single
  # query string and rename station id (statid) to OBS_GROUP
  # Double check. If users says groupsites, but only one site specified, force
  # to single site plot
  if(length(statid) == 1) {
    groupstat<-F
  } 
  if(groupstat)  {
    tmp<-"("
    statvar	<-"stat_id"
    for(sn in 1:length(statid) ) {
      conj <-" OR "
      if(sn == length(statid)) { conj<-""}
      tmp  <-paste(tmp,statvar,"='",statid[sn],"'",conj,sep="")
    }
    statstr<-paste(tmp,")")
    statid <-"GROUP_AVG"
  }
  # Check if user has defined a figure directory (figdir), if not set figdir to users current directory.
  # Then set up figure names. 
  if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")	}
  if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"			}
  figure  <-paste(figdir,"/",model1,".",statid,".",drange_plot,sep="")
  textfile<-paste(figdir,"/",model1,".",statid,".",drange_plot,".txt",sep="")
 
 savefile_name<-paste(figure,".Rdata",sep="")
   

for (sn in 1:length(statid)){
  # Loop Dependent definitions
  # Resets plot options with statid figure name and lables

  plotopts<-list(plotfmt=plotfmt,symb=symb,symbsiz=symbsiz,plotsize=plotsize,figure=figure[sn])

#######################################################################################################################################
#   STEP 1) Query the database for the station's met data
#######################################################################################################################################
#	Create Queries from date and query specs provided by user
  query1<-paste("SELECT  DATE_FORMAT(ob_date,'%Y%m%d'),HOUR(ob_time),stat_id,fcast_hr,T_mod,T_ob, 
                 Q_mod,WVMR_ob, U_mod,U_ob, V_mod,V_ob FROM ",table1,"  WHERE  ",statstr[sn],
                 "  and ob_date BETWEEN ",dates$y,dform(dates$m),dform(dates$d)," and ",datee$y,
                 dform(datee$m),dform(datee$d)," ",extra," ORDER BY ob_date,ob_time",sep="")
                 
  query2<-paste("SELECT  DATE_FORMAT(ob_date,'%Y%m%d'),HOUR(ob_time),stat_id,fcast_hr,T_mod,T_ob,
                 Q_mod,WVMR_ob, U_mod,U_ob, V_mod,V_ob FROM ",table2,"  WHERE  ",statstr[sn],
                 "  and ob_date BETWEEN ",dates$y,dform(dates$m),dform(dates$d)," and ",datee$y,
                 dform(datee$m),dform(datee$d)," ",extra," ORDER BY ob_date,ob_time",sep="")

# Query Database and put into data frame, then massage data
  data1<-ametQuery(query1,mysql)

  # If no data is in the database for the station then skip to next station or end program
 if ( dim(data1)[1] == 0) {
		writeLines(paste('',
		           '**********************************************************************************',
		           'NO DATA WAS FOUND FOR THIS SITE: Will skip to next site or terminate              ',
		           '**********************************************************************************',sep="\n"))
    next;
  }

  #######################################################################################################################################
  #   STEP 2) Massage the met data (convert u,v to ws and wd, etc)
  #######################################################################################################################################
  header   <-c("Date","Time","Ob Temp","Model Temp","Ob Sp. Hum","Model Sp. Hum","Ob U","Model U","Ob V",
               "Model V","Ob Precip","Model Precip")
  locs     <-c(1,2,3,4,5,6,9,10,11,12,7,8)
  tseries1 <-massageTseries(data1,loc=locs,iftseries=TRUE)

  # Condition that user want to compare a second model to observations and first model
  if (comp){
     data2    <-ametQuery(query2,mysql)
     if(length(data2) == 0){
       data2  <-data1;comp<-FALSE
     }
     tseries2 <-massageTseries(data2,loc=locs,iftseries=TRUE)
  }
  else {
     tseries2 <-tseries1
     data2    <-data1
  }
  
  #######################################################################################
  #   STEP 3) Make a R data file and text file of time series if user specifies
  #######################################################################################
  # If users specifies they want a R data file with timeseries data then write
  if (savefile){
        writeLines(paste("R data file output:",savefile_name[sn]))
  	save(tseries1,tseries2,data1, data2, file=savefile_name[sn])
  }
  
  ##################################################################################################
  #   STEP 4) Find min and max date, create hourly date object over that period, match data (date) 
  #           extracted from database to this date time object, then create time series
  ##################################################################################################
  date.vec<-seq(min(tseries1$date,tseries2$date),max(tseries1$date,tseries2$date),by="hour")
  tl  <-length(date.vec)
  temp<-array(,c(tl,3))
  q   <-array(,c(tl,3))
  ws  <-array(,c(tl,3))
  wd  <-array(,c(tl,3))
  
  if(groupstat) {
    for(t in 1:length(date.vec) ) {
      date.ind1<-date.vec[t] == tseries1$date
      date.ind2<-date.vec[t] == tseries2$date
      temp[t,1]<-mean(tseries1$temp[date.ind1,1],na.rm=T)
      temp[t,2]<-mean(tseries1$temp[date.ind1,2],na.rm=T)
      temp[t,3]<-mean(tseries2$temp[date.ind2,1],na.rm=T)

      q[t,1]<-mean(tseries1$q[date.ind1,1],na.rm=T)*1000
      q[t,2]<-mean(tseries1$q[date.ind1,2],na.rm=T)*1000
      q[t,3]<-mean(tseries2$q[date.ind2,1],na.rm=T)*1000

      ws[t,1]<-mean(tseries1$ws[date.ind1,1],na.rm=T)
      ws[t,2]<-mean(tseries1$ws[date.ind1,2],na.rm=T)
      ws[t,3]<-mean(tseries2$ws[date.ind2,1],na.rm=T)

      wd[t,1]<-mean(tseries1$wd[date.ind1,1],na.rm=T)
      wd[t,2]<-mean(tseries1$wd[date.ind1,2],na.rm=T)
      wd[t,3]<-mean(tseries2$wd[date.ind2,1],na.rm=T)
    }
  }
  else{
      date.ind1        <-match( tseries1$date, date.vec)
      date.ind2        <-match( tseries2$date, date.vec)

      temp[date.ind1,1]<-tseries1$temp[,1]
      temp[date.ind1,2]<-tseries1$temp[,2]
      temp[date.ind2,3]<-tseries2$temp[,1]
      na.check<- sum(ifelse( is.na(temp[,1]),1,0),na.rm=T)
      if(na.check == tl) { temp[,1:3]<-273 }
      
      q[date.ind1,1]   <-tseries1$q[,1]*1000
      q[date.ind1,2]   <-tseries1$q[,2]*1000
      q[date.ind2,3]   <-tseries2$q[,1]*1000
      na.check<- sum(ifelse( is.na(q[,1]),1,0),na.rm=T)
      if(na.check == tl) { q[,1:3]<-0.001; }

      ws[date.ind1,1]  <-tseries1$ws[,1]
      ws[date.ind1,2]  <-tseries1$ws[,2]
      ws[date.ind2,3]  <-tseries2$ws[,1]
      na.check<- sum(ifelse( is.na(ws[,1]),1,0),na.rm=T)
      if(na.check == tl) { ws[,1:3]<-2; }

      wd[date.ind1,1]  <-tseries1$wd[,1]
      wd[date.ind1,2]  <-tseries1$wd[,2]
      wd[date.ind2,3]  <-tseries2$wd[,1]
      na.check<- sum(ifelse( is.na(wd[,1]),1,0),na.rm=T)
      if(na.check == tl) { wd[,1:3]<-1; }
  }
  
  # Write text output if user specifies
  if(textout) {
     writeLines(paste("R text file output:",textfile[sn]))
     write.table(data.frame(date.vec,temp[,1],temp[,2],temp[,3], q[,1],q[,2],ws[,1],ws[,2],wd[,1],wd[,2]),
                 textfile[sn],sep=",", col.names=c("Date Time","Temp Mod (K)","Temp Obs (K)","Temp Mod2 (K)",
                 "Q Mod (g/kg)","Q Obs (g/kg)","WS Mod (m/s)","WS Obs (m/s)","WD Mod (Deg)","WD Obs (Deg)"),
                 row.names=F, quote=FALSE)
  }
  writeLines(paste("Plotting figure for site: ",statid[sn],"-->",figure[sn],".",plotopts$plotfmt,sep=""))
  writeLines(paste("---------------------------------------------------------------------------------------"))
#######################################################################################
#   STEP 5) Plot time series
#######################################################################################
 try(
         plotTseries(temp,ws,wd,q,date.vec,plotopts,qclims,comp=comp,
                     tsnames=c(statid[sn],model1,model2),wdweightws=wdweightws)
 )
 rm(temp,ws,ws,q,tseries1,data1)
}	# End of loop through station ids
########################################################################################################################
#				FINISHED
########################################################################################################################
quit(save="no")
