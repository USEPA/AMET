#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#                AMET (Atmospheric Model Evaluation Tool)               #
#                                                                       #
#                    Timeseries of T, Q, RH, PS                         #
#                        MET_timeseries_rh.R                            #
#                                                                       #
#         Developed by the US Environmental Protection Agency           #
#-----------------------------------------------------------------------#
#########################################################################
#-----------------------------------------------------------------------#
#  Version 1.4, Sep 30, 2018, Robert Gilliam                            # 
#   - Intial version copied from the existing timeseries script.        #
#     Modified for T, Q, RH and PS (surface pressure).                  #
#     Surface pressure was added to the model-obs surface met matching  #
#     since it is needed for RH calcs (saturated mixing ratio).         #
#-----------------------------------------------------------------------#
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

 ametdbase1     <- Sys.getenv("AMET_DATABASE1")
 ametdbase2     <- Sys.getenv("AMET_DATABASE2")
 mysqlserver    <- Sys.getenv("MYSQL_SERVER")
 mysql1          <-list(server=mysqlserver,dbase=ametdbase1,login=amet_login,
                        passwd=amet_pass,maxrec=maxrec)
 mysql2          <-list(server=mysqlserver,dbase=ametdbase2,login=amet_login,
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
  figure  <-paste(figdir,"/",model1,".RH.",statid,".",drange_plot,sep="")
  textfile<-paste(figdir,"/",model1,".RH.",statid,".",drange_plot,".txt",sep="")
 
 savefile_name<-paste(figure,".Rdata",sep="")
   

for (sn in 1:length(statid)){
  # Loop Dependent definitions
  # Resets plot options with statid figure name and lables

  plotopts<-list(plotfmt=plotfmt,symb=symb,symbsiz=symbsiz,plotsize=plotsize,figure=figure[sn])

#######################################################################################################################################
#   STEP 1) Query the database for the station's met data
#######################################################################################################################################
#	Create Queries from date and query specs provided by user
  query1<-paste("SELECT  DATE_FORMAT(ob_date,'%Y%m%d'),HOUR(ob_date),stat_id,fcast_hr,T_mod,T_ob, 
                 Q_mod,WVMR_ob, PSFC_mod,PSFC_ob FROM ",table1,"  WHERE  ",statstr[sn],
                 "  and ob_date BETWEEN ",dates$y,dform(dates$m),dform(dates$d)," and ",datee$y,
                 dform(datee$m),dform(datee$d)," ",extra," ORDER BY ob_date,ob_time",sep="")
                 
  query2<-paste("SELECT  DATE_FORMAT(ob_date,'%Y%m%d'),HOUR(ob_date),stat_id,fcast_hr,T_mod,T_ob,
                 Q_mod,WVMR_ob,  PSFC_mod,PSFC_ob FROM ",table2,"  WHERE  ",statstr[sn],
                 "  and ob_date BETWEEN ",dates$y,dform(dates$m),dform(dates$d)," and ",datee$y,
                 dform(datee$m),dform(datee$d)," ",extra," ORDER BY ob_date,ob_time",sep="")

# Query Database and put into data frame, then massage data
  writeLines(paste("MySQL query:",query1))
  data1 <-ametQuery(query1,mysql1)

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
  day      <- data1[,1]
  timex    <- data1[,2]
  iso.date <- ISOdatetime(year=as.numeric(substr(day,1,4)), month=as.numeric(substr(day,5,6)), 
                          day=as.numeric(substr(day,7,8)),  hour=as.numeric(timex), min=0, sec=0, tz="GMT")
  temp     <-array(,c(length(timex),2))
  q        <-array(0,c(length(timex),2))
  rh       <-array(,c(length(timex),2))
  ps       <-array(,c(length(timex),2))
 
  qcedvar  <- data1[,5]
  qcedvar  <- ifelse( qcedvar <  qclims$qcT[1], NA, qcedvar)
  temp[,1] <- ifelse( qcedvar >  qclims$qcT[2], NA, qcedvar)
  qcedvar  <- data1[,6]
  qcedvar  <- ifelse( qcedvar <  qclims$qcT[1], NA, qcedvar)
  temp[,2] <- ifelse( qcedvar >  qclims$qcT[2], NA, qcedvar)

  qcedvar  <- data1[,7]
  qcedvar  <- ifelse( qcedvar <  qclims$qcQ[1]/1000, NA, qcedvar)
  q[,1]    <- ifelse( qcedvar >  qclims$qcQ[2]/1000, NA, qcedvar)
  qcedvar  <- data1[,8]
  qcedvar  <- ifelse( qcedvar <  qclims$qcQ[1]/1000, NA, qcedvar)
  q[,2]    <- ifelse( qcedvar >  qclims$qcQ[2]/1000, NA, qcedvar)

  qcedvar  <- data1[,9]
  qcedvar  <- ifelse( qcedvar <  qclims$qcPS[1], NA, qcedvar)
  ps[,1]   <- ifelse( qcedvar >  qclims$qcPS[2], NA, qcedvar)
  qcedvar  <- data1[,10]
  qcedvar  <- ifelse( qcedvar <  qclims$qcPS[1], NA, qcedvar)
  ps[,2]   <- ifelse( qcedvar >  qclims$qcPS[2], NA, qcedvar)

  es       <- 0.611 * exp ( (2.501E6/461.5) * ( (1/273.14) -(1/temp[,1]) ) )
  smixr    <- 0.62197 * (es/(ps[,1]-es))
  smixr    <- ifelse(smixr <   0.000001,NA, smixr)
  rh[,1]   <- q[,1]/smixr
  rh[,1]   <- ifelse(rh[,1] > 100, 100.0, rh[,1])
  rh[,1]   <- ifelse(rh[,1] <   0,    NA, rh[,1])
  es       <- 0.611 * exp ( (2.501E6/461.5) * ( (1/273.14) -(1/temp[,2]) ) )
  smixr    <- 0.62197 * (es/(ps[,2]-es))
  smixr    <- ifelse(smixr <   0.000001,NA, smixr)
  rh[,2]   <- q[,2]/smixr
  rh[,2]   <- ifelse(rh[,2] > 100, 100.0, rh[,2])
  rh[,2]   <- ifelse(rh[,2] <   0,    NA, rh[,2])
  rh       <- rh*100

  
  tseries1 <- list(statid=statid[sn], obnet="METAR", date=iso.date, temp=temp,
                 q=q, rh=rh, ps=ps*10, units="mks")

  # Condition that user want to compare a second model to observations and first model
  if (comp){
     data2    <-ametQuery(query2,mysql2)
     if(dim(data2)[1] == 0){
       writeLines(paste("Project ID 2 did not have any data. Either change dates",
                        "to period where both projects have data or remove AMET_PROJECT2",
                        "project id from the run_timeseries.csh script and just plot AMET_PROJECT1"))
       next                  
     }

     day      <- data2[,1]
     timex    <- data2[,2]
     iso.date2<- ISOdatetime(year=as.numeric(substr(day,1,4)), month=as.numeric(substr(day,5,6)), 
                             day=as.numeric(substr(day,7,8)),  hour=as.numeric(timex), min=0, sec=0, tz="GMT")
     temp     <-array(,c(length(timex),2))
     q        <-array(0,c(length(timex),2))
     rh       <-array(,c(length(timex),2))
     ps       <-array(,c(length(timex),2))

     qcedvar  <- data2[,5]
     qcedvar  <- ifelse( qcedvar <  qclims$qcT[1], NA, qcedvar)
     temp[,1] <- ifelse( qcedvar >  qclims$qcT[2], NA, qcedvar)
     qcedvar  <- data2[,6]
     qcedvar  <- ifelse( qcedvar <  qclims$qcT[1], NA, qcedvar)
     temp[,2] <- ifelse( qcedvar >  qclims$qcT[2], NA, qcedvar)

     qcedvar  <- data2[,7]
     qcedvar  <- ifelse( qcedvar <  qclims$qcQ[1]/1000, NA, qcedvar)
     q[,1]    <- ifelse( qcedvar >  qclims$qcQ[2]/1000, NA, qcedvar)
     qcedvar  <- data2[,8]
     qcedvar  <- ifelse( qcedvar <  qclims$qcQ[1]/1000, NA, qcedvar)
     q[,2]    <- ifelse( qcedvar >  qclims$qcQ[2]/1000, NA, qcedvar)

     qcedvar  <- data2[,9]
     qcedvar  <- ifelse( qcedvar <  qclims$qcPS[1], NA, qcedvar)
     ps[,1]   <- ifelse( qcedvar >  qclims$qcPS[2], NA, qcedvar)
     qcedvar  <- data2[,10]
     qcedvar  <- ifelse( qcedvar <  qclims$qcPS[1], NA, qcedvar)
     ps[,2]   <- ifelse( qcedvar >  qclims$qcPS[2], NA, qcedvar)

     es       <- 0.611 * exp ( (2.501E6/461.5) * ( (1/273.14) -(1/temp[,1]) ) )
     smixr    <- 0.62197 * (es/(ps[,1]-es))
     smixr    <- ifelse(smixr <   0.000001,NA, smixr)
     rh[,1]   <- q[,1]/smixr
     rh[,1]   <- ifelse(rh[,1] > 100, 100.0, rh[,1])
     rh[,1]   <- ifelse(rh[,1] <   0,    NA, rh[,1])
     es       <- 0.611 * exp ( (2.501E6/461.5) * ( (1/273.14) -(1/temp[,2]) ) )
     smixr    <- 0.62197 * (es/(ps[,2]-es))
     smixr    <- ifelse(smixr <   0.000001,NA, smixr)
     rh[,2]   <- q[,2]/smixr
     rh[,2]   <- ifelse(rh[,2] > 100, 100.0, rh[,2])
     rh[,2]   <- ifelse(rh[,2] <   0,    NA, rh[,2])
     rh       <- rh*100
     tseries2<-list(statid=statid[sn], obnet="METAR", date=iso.date2, temp=temp,
                    q=q, rh=rh, ps=ps*10, units="mks")
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
  ps  <-array(,c(tl,3))
  rh  <-array(,c(tl,3))
  
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

      rh[t,1]<-mean(tseries1$rh[date.ind1,1],na.rm=T)
      rh[t,2]<-mean(tseries1$rh[date.ind1,2],na.rm=T)
      rh[t,3]<-mean(tseries2$rh[date.ind2,1],na.rm=T)

      ps[t,1]<-mean(tseries1$ps[date.ind1,1],na.rm=T)*10
      ps[t,2]<-mean(tseries1$ps[date.ind1,2],na.rm=T)*10
      ps[t,3]<-mean(tseries2$ps[date.ind2,1],na.rm=T)*10
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

      rh[date.ind1,1]  <-tseries1$rh[,1]
      rh[date.ind1,2]  <-tseries1$rh[,2]
      rh[date.ind2,3]  <-tseries2$rh[,1]
      rh.check<- sum(ifelse( is.na(rh[,1]),1,0),na.rm=T)
      if(na.check == tl) { rh[,1:3]<-50.0 ; }

      ps[date.ind1,1]  <-tseries1$ps[,1]
      ps[date.ind1,2]  <-tseries1$ps[,2]
      ps[date.ind2,3]  <-tseries2$ps[,1]
      na.check<- sum(ifelse( is.na(ps[,1]),1,0),na.rm=T)
      if(na.check == tl) { ps[,1:3]<-1012.0; }
  }
  
  # Write text output if user specifies
  if(textout) {
     #writeLines(paste("R text file output:",textfile[sn]))
     write.table(
     data.frame(date.vec,temp[,1],temp[,2],temp[,3], q[,1],q[,2],q[,2],
                rh[,1],rh[,2],rh[,3],ps[,1],ps[,2],ps[,3]),textfile[sn],sep=",", 
                col.names=c("Date Time","Temp Mod (K)","Temp Obs (K)","Temp Mod2 (K)",
                            "Q Mod (g/kg)","Q Obs (g/kg)","Q Mod2 (g/kg)",
                            "RH Mod (%)","RH Obs (%)","RH Mod2 (%)",
                            "PS Mod (mb)","PS Obs (mb)","PS Mod2 (mb)"),
                            row.names=F, quote=FALSE)
  }
  writeLines(paste("---------------------------------------------------------------------------------------"))
  writeLines(paste("Plotting figure: ",statid[sn],"-->",figure[sn],".",plotopts$plotfmt,sep=""))
  writeLines(paste("---------------------------------------------------------------------------------------"))
#######################################################################################
#   STEP 5) Plot time series
#######################################################################################

 plotTseriesRH(temp, q, rh, ps, date.vec, plotopts, comp=comp, tsnames=c(statid[sn],model1,model2))

 rm(temp,ws,ws,q,tseries1,data1)
}	# End of loop through station ids
########################################################################################################################
#				FINISHED
########################################################################################################################
quit(save="no")
