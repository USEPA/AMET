#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#                AMET (Automated Model Evaluation Tool)                 #
#                                                                       #
#                Rawindsode (RAOB) Statistical Plots                    #
#                              MET_raob.R                               #
#                                                                       #
#         Developed by the US Environmental Protection Agency           #
#-----------------------------------------------------------------------#
#########################################################################
# Version 1.4, Sep 30, 2018, Robert Gilliam                             #
#   - Completely redone from the version in AMETV1.2 because of changes #
#     in the matching_raob.csh/MET_matching_raob.R model-obs matching   #
#     reformulation that reads MADIS raob files directly. This version  #
#     partitions the analysis into two datasets. 1) model-obs data that #
#     is on mandatory pressure levels (e.g., 1000, 850, 700, 500, etc)  #
#     and 2) model-obs data on their native pressure levels.            #
#     Mandatory pressure level analysis (T, RH, WS, WD) includes:       #
#     1) Spatial statistics computed over a defined pressure layer.     #
#     2) Profile statistics for all mandatory pressure levels for a     #
#        single site, grouping of sites or all sites in the domain.     #
#     3) Histograms of model, obs and binned differences at each        #
#        pressure level for one site or a grouping.                     #
#     4) Curtain plots (time-height) of model, obs and difference       #
#        at single sites.                                               #
#                                                                       #
#     Native pressure level analysis (T, RH, WS)                        #
#     1) Single time profiles of Theta and RH at single sites with      #
#        the interpolated difference.                                   # 
#     2) Curtain plots of Theta and RH where the model is the shaded    #
#        and raob obs overlaid with same color scale symbols. Also      #
#        the difference between obs and model is a secondary plot.      #
#                                                                       #         
# Version 1.5, Apr 25, 2022, Robert Gilliam                             #
#         - Wind vector error added for better wind error analysis      #
#         - Gross QC limits on Mod-Obs difference allowed in stats      # 
#           calculations. Defined in raob.input. Default use if         #
#           old raob.input.                                             #
#         - Wind vector error calculated for spatial and timeseries     #
#           plots. (need to make backward compatible if old             #
#           raob.input is used)                                         #
#         - New split config input file where "more" static settings    #
#           are split into a timeseries.static.input and key configs    #
#           remain in the timeseries.input. Backward compatible.        #
#         - Added auto lat-lon bounds if set to NA or missing.          #
#         - Mod config file so lat-lon is used in site grouping queries #
#         - Other streamline updates.                                   #
#                                                                       #         
#########################################################################
  options(warn=-1)
#########################################################################
#	Load required modules
  if(!require(maps))   {stop("Required Package maps was not loaded")}
  if(!require(mapdata)){stop("Required Package mapdata was not loaded")}
  if(!require(date))   {stop("Required Package date was not loaded")}
  if(!require(RMySQL)) {stop("Required Package RMySQL was not loaded")}
  if(!require(akima))  {stop("Required Package akima was not loaded")}
  if(!require(fields)) {stop("Required Package fields was not loaded")}
#########################################################################
#    Initialize AMET Diractory Structure Via Env. Vars
#    AND Load required function and conf. files
#########################################################################
 ametbase         <- Sys.getenv("AMETBASE")
 ametR            <- paste(ametbase,"/R_analysis_code",sep="")
 ametRinput       <- Sys.getenv("AMETRINPUT")
 mysqlloginconfig <- Sys.getenv("MYSQL_CONFIG")
 ametdbase        <- Sys.getenv("AMET_DATABASE")
 mysqlserver      <- Sys.getenv("MYSQL_SERVER")
 ametRstatic      <- Sys.getenv("AMETRSTATIC")

 # Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
 # and not specified via AMET_OUT, then set figdir to the current directory
 if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")  }
 if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"                    }
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

 # New runid setting for plot labels. If not set, empty for old plot names.
 if(!exists("runid"))                          { runid <- "NORUNID"  }
 if(runid == "")                               { runid <- "NORUNID"  }

 ## MySQL list for connection and date range list
 mysql      <-list(server=mysqlserver,dbase=ametdbase,login=amet_login,
                   passwd=amet_pass,maxrec=maxrec)
 #################################
 textfile   <-paste(figdir,"/raob_stats.",project,".txt",sep="")

  # User QC settings representing the largest difference allowed between mod and obs.
  # if these are not defined because of old timeseries.input, set default values and notify
  if(!exists("qcerror") )   {
    writeLines("** Importance Notice **")
    writeLines("User QC limits (qcerror) in AMETv1.5+ not defined in raob.input because it is old.")
    writeLines("Default to 15, 20, 10, 50 for T, WS, Q and RH. User can alter if they update raob.input")
    writeLines("e.g., qcerror <- c(15,20,10,50)")
    writeLines(" ****************************************** ")
    qcerror <- c(15,20,10,50)
  }

 ##########################################################################################
 #### MANDATORY PRESSURE LEVEL ANALYSIS ######

 # SPATIAL STATISTICS for all sites for specified pressure layer range
 # and given time range. Done for T, RH, WS and WD
 if(SPATIALM){

  writeLines("  *****   SPATIAL STATISTICS FOR MODEL-RAOB DATA   *****")

  # Temperature statsq array is: [sites,metric,variable] 
  # metric is    RMSE, MAE, BIAS, CORR, COUNT
  # variable is  T, RH, WS, WD, WNDVEC

  # TEMP
  query  <-paste("SELECT",my.varget.spatial,"FROM",criteria.tm,extrall," ORDER BY stat_id")
  writeLines(paste(query))
  dataq  <-ametQuery(query,mysql)
  if(dim(dataq)[1] == 0) {
    stop(paste("No data found. Check query dates or other settings and rerun"))
  }

  sitesq <- unique(dataq[,1])
  nsq    <- length(sitesq)
  statsq <-array(NA,c(nsq,5,5))
  slatlon<-array(NA,c(nsq,2))
  for(s in 1:nsq){
     a           <- which(dataq[,1] == sitesq[s])
     if(length(a) < spatial.thresh) { next }
     slatlon[s,1]<-dataq[a[1],2]
     slatlon[s,2]<-dataq[a[1],3]
     obs         <-dataq[a,10]
     mod         <-dataq[a,12]
     statsq[s,1,]<-simple.stats(obs,mod)
  }

  if(anyNA(bounds)){
    bounds          <-c(range(slatlon[,1]),range(slatlon[,2]))
    plotopts$bounds <-bounds
    writeLines(paste("** WARNING ** bounds for spatial analysis were not found. Setting to RAOB site range."))
    writeLines(paste("** BOUNDS  ** LAT/LON SOUTH, NORTH, WEST, EAST:",bounds[1],bounds[2],bounds[3],bounds[4]))
  }

  # RH
  query  <-paste("SELECT",my.varget.spatial,"FROM",criteria.rhm,extrall," ORDER BY stat_id")
  dataq  <-ametQuery(query,mysql)
  for(s in 1:nsq){
     a           <- which(dataq[,1] == sitesq[s])
     if(length(a) < spatial.thresh) { next }
     obs         <-dataq[a,10]
     mod         <-dataq[a,12]
     statsq[s,2,]<-simple.stats(obs,mod)
  }

  # WS and WD statistics
  query  <-paste("SELECT",my.varget.spatial,"FROM",criteria.um,extrall," ORDER BY stat_id,ob_date,plevel")
  dataqu <-ametQuery(query,mysql)
  query  <-paste("SELECT",my.varget.spatial,"FROM",criteria.vm,extrall," ORDER BY stat_id,ob_date,plevel")
  dataqv <-ametQuery(query,mysql)
  for(s in 1:nsq){
     writeLines(paste("Site ID:",sitesq[s]," site ",s,"of",nsq,"  Lat-Lon  ",slatlon[s,1],slatlon[s,2]))
     a            <- which(dataqu[,1] == sitesq[s])
     b            <- which(dataqv[,1] == sitesq[s])
     if(length(a) <  spatial.thresh) { next }
     obsu         <-dataqu[a,10]
     modu         <-dataqu[a,12]
     obsv         <-dataqv[b,10]
     modv         <-dataqv[b,12]
     if(length(obsu) != length(modu)) { 
       writeLines(paste("Site had data inconsitancies, will skip"))  
       next 
     }
     obsws        <-sqrt(obsu^2 + obsv^2)
     modws        <-sqrt(modu^2 + modv^2)
     obsws        <-ifelse(obsws < 0, NA, obsws)
     obsws        <-ifelse(obsws > 250, NA, obsws)
     modws        <-ifelse( is.na(obsws), NA, modws)
     statsq[s,3,] <-simple.stats(obsws,modws)

     obswd        <- 180+(360/(2*pi))*atan2(obsu,obsv)
     modwd        <- 180+(360/(2*pi))*atan2(modu,modv)
     diffwd       <- obswd- modwd  
     diffwd       <-ifelse(diffwd > 180 , diffwd-360, diffwd)
     diffwd       <-ifelse(diffwd< -180 , diffwd+360, diffwd)
     obswd0       <-runif(length(diffwd),min=0,max=0.001)
     modwd0       <-diffwd
     statsq[s,4,] <-simple.stats(obswd0,modwd0)
     
     # Added in v1.5. Russ Bullock average wind vector error
     statsq[s,5,2]<- mean(sqrt( (modu-obsu)^2 + (modv-obsv)^2  ))

  }
  tmp<- plotSpatialRaob(statsq, slatlon, sitesq, lev.array, 
                        col.array, plotopts, plotlab, runid=runid)
  ############################################################################
  # New in Version 1.3: Text file with set SITES=(....) string to use in
  # site specific profile statistics and curtain plots. All sites in lat-lon box.
  str  <-paste("set SITES=(",sitesq[1],sep="")
  for(s in 2:nsq) {  
   str <-paste(str," ",sitesq[s],sep="")
  }
  str  <-paste(str,")",sep="")
  sfile<-file(paste(plotopts$figdir,"/spatial.setSITES.all.txt",sep=""),"w") 
  writeLines(str, con =sfile)
  close(sfile)
  ############################################################################

 }
 ##########################################################################################
#break
 ##########################################################################################
 # Timeseries of Domain STATISTICS for all sites for specified pressure layer range,
 # given time range and lat-lon bounds. Done for T, RH, WS and WD
 if(TSERIESM){
  writeLines("  *****   TIMESERIES STATS FOR MODEL-RAOB DATA   *****")
  # Temperature statsq array is: [day,metric,variable] 
  # metric is    RMSE, MAE, BIAS, CORR, COUNT
  # variable is  T, RH, WS, WD
  query  <-paste("SELECT",my.varget.spatial,"FROM",criteria.tm,extrall," ORDER BY stat_id")
  writeLines(paste(query))
  dataqt <-ametQuery(query,mysql)
  query  <-paste("SELECT",my.varget.spatial,"FROM",criteria.rhm,extrall," ORDER BY stat_id")
  dataqrh<-ametQuery(query,mysql)
  query  <-paste("SELECT",my.varget.spatial,"FROM",criteria.um,extrall," ORDER BY stat_id,ob_date,plevel")
  dataqu <-ametQuery(query,mysql)
  query  <-paste("SELECT",my.varget.spatial,"FROM",criteria.vm,extrall," ORDER BY stat_id,ob_date,plevel")
  dataqv <-ametQuery(query,mysql)

  iso.datet  <-  ISOdatetime(year=dataqt[,4], month=dataqt[,5],day=dataqt[,6],
                             hour=dataqt[,7], min=0, sec=0, tz="GMT")
  iso.daterh <-  ISOdatetime(year=dataqrh[,4], month=dataqrh[,5],day=dataqrh[,6],
                             hour=dataqrh[,7], min=0, sec=0, tz="GMT")
  iso.dateu  <-  ISOdatetime(year=dataqu[,4], month=dataqu[,5],day=dataqu[,6],
                             hour=dataqu[,7], min=0, sec=0, tz="GMT")
  iso.datev  <-  ISOdatetime(year=dataqv[,4], month=dataqv[,5],day=dataqv[,6],
                             hour=dataqv[,7], min=0, sec=0, tz="GMT")

  minmax    <- range(iso.datet,iso.daterh,iso.dateu,iso.datev,na.rm=T)
  date.vecm <- seq(minmax[1],minmax[2],by=(60*60*12))

  nt        <- length(date.vecm)
  statsq <-array(NA,c(nt,5,5))

  writeLines(paste("QC applied on mod-obs difference allowed (see raob.input qcerror)"))
  writeLines(paste("Max diff allowed T/WS/RH ...",qcerror[1],qcerror[2],qcerror[4]))
  # Temperature stats loop over days
  for(tt in 1:nt){
     a            <- which(date.vecm[tt] == iso.datet)
     if(length(a) < spatial.thresh) { next }
     obs          <-dataqt[a,10]
     mod          <-dataqt[a,12]
     obs          <-ifelse( abs(mod-obs) > qcerror[1], NA, obs)
     statsq[tt,1,]<-simple.stats(obs,mod)
  }
  # Rel. Humd. stats loop over days
  for(tt in 1:nt){
     a            <- which(date.vecm[tt] == iso.daterh)
     if(length(a) < spatial.thresh) { next }
     obs          <-dataqrh[a,10]
     mod          <-dataqrh[a,12]
     obs          <-ifelse( abs(mod-obs) > qcerror[4], NA, obs)
     statsq[tt,2,]<-simple.stats(obs,mod)
  }


  # WS and WD stat loop over days
  for(tt in 1:nt){
     a             <- which(date.vecm[tt] == iso.dateu)
     b             <- which(date.vecm[tt] == iso.datev)
     if(length(a) <  spatial.thresh) { next }
     if(length(a) != length(b)) { next }
     obsu          <-dataqu[a,10]
     modu          <-dataqu[a,12]
     obsv          <-dataqv[b,10]
     modv          <-dataqv[b,12]
     obsws         <-sqrt(obsu^2 + obsv^2)
     modws         <-sqrt(modu^2 + modv^2)
     obsws         <-ifelse(obsws < 0, NA, obsws)
     obsws         <-ifelse(obsws > 250, NA, obsws)
     modws         <-ifelse( is.na(obsws), NA, modws)
     obsws         <-ifelse( abs(modws-obsws) > qcerror[2], NA, obsws)
     statsq[tt,3,]<-simple.stats(obsws,modws)

     obswd         <- 180+(360/(2*pi))*atan2(obsu,obsv)
     modwd         <- 180+(360/(2*pi))*atan2(modu,modv)
     diffwd        <- obswd- modwd  
     diffwd        <-ifelse(diffwd > 180 , diffwd-360, diffwd)
     diffwd        <-ifelse(diffwd< -180 , diffwd+360, diffwd)
     obswd0        <-runif(length(diffwd),min=0,max=0.001)
     modwd0        <-diffwd
     statsq[tt,4,] <-simple.stats(obswd0,modwd0)
     # Added in v1.5. Russ Bullock average wind vector error 
     statsq[tt,5,2]<-mean(sqrt( (modu-obsu)^2 + (modv-obsv)^2  ))
  }
  ## Need a AMET bug fix. When AMET_PLAYER for spatial stats is low, spatial.thresh
  ## is not met and all values are NA. Fix: statement when all time series stats are NA
  ## that user runs timeseries alone with deeper PLAYER or lower the spatial.thresh
  tmp<- plotTseriesRaobM(statsq, date.vecm, plotopts, plotlab, textstats, runid=runid)

 }
 ##########################################################################################

 ##########################################################################################
 # Mandatory PRESSURE LEVEL PROFILES mean, rmse, bias over user defined
 # time range. Done for T, RH, WS and WD
 if(PROFM){

  writeLines("  *****   MANDATORY PROFILE STATISTICS FOR MODEL-RAOB DATA   *****")
  queryt  <-paste("SELECT",my.varget.spatial,"FROM",criteria.tms," ORDER BY stat_id,ob_date,plevel")
  queryrh <-paste("SELECT",my.varget.spatial,"FROM",criteria.rhms," ORDER BY stat_id,ob_date,plevel")
  queryu  <-paste("SELECT",my.varget.spatial,"FROM",criteria.ums," ORDER BY stat_id,ob_date,plevel")
  queryv  <-paste("SELECT",my.varget.spatial,"FROM",criteria.vms," ORDER BY stat_id,ob_date,plevel")

  for(s in 1:ns){

    writeLines(paste("Extracting temperature, rel. hum. and wind profile data from the databse"))
    writeLines(paste(queryt[s]))
    dataqt <-ametQuery(queryt[s],mysql)
    dataqrh<-ametQuery(queryrh[s],mysql)
    dataqu <-ametQuery(queryu[s],mysql)
    dataqv <-ametQuery(queryv[s],mysql)
    levelq <- rev(sort( unique(c(dataqt[,8],dataqrh[,8],dataqu[,8],dataqv[,8]))))
    maxdiml<-round(max(dim(dataqv),dim(dataqu),dim(dataqt),dim(dataqrh))/length(levelq))
    maxdiml<-round(max(dim(dataqv),dim(dataqu),dim(dataqt),dim(dataqrh)))

    # Check to see if site has enough data to pass threshold
    if(length(levelq) < level.thresh || maxdiml  < sounding.thresh ) {
      writeLines(paste("Sample size does not meet the defined threshold of:",level.thresh))
      next
    }

    # T
    nlq     <- length(levelq)
    if(nlq < 0) { 
      writeLines(paste("******    WARNING: Site",statid[s],"has no data. Site skipped.  *******"))
      next
    }
    statsq  <-array(NA,c(nlq,4,5))
    diffsq  <-array(NA,c(nlq,4,maxdiml))
    obsmodt <-array(NA,c(nlq,2,maxdiml))
    datet   <-array(NA,c(nlq,4,maxdiml))
    for(l in 1:nlq){
     a      <- which(dataqt[,8] == levelq[l])
     if(length(a) == 0) { next } 
     datet[l,1,1:length(a)]   <-dataqt[a,4]
     datet[l,2,1:length(a)]   <-dataqt[a,5]
     datet[l,3,1:length(a)]   <-dataqt[a,6]
     datet[l,4,1:length(a)]   <-dataqt[a,7]
     obsmodt[l,1,1:length(a)] <-dataqt[a,10]
     obsmodt[l,2,1:length(a)] <-dataqt[a,12]
     diffsq[l,1,]             <-obsmodt[l,2,] - obsmodt[l,1,]
     statsq[l,1,]             <-simple.stats(obsmodt[l,1,],obsmodt[l,2,])
    }
    # RH
    obsmodrh <-array(NA,c(nlq,2,maxdiml))
    daterh   <-array(NA,c(nlq,4,maxdiml))
    for(l in 1:nlq){
     a      <- which(dataqrh[,8] == levelq[l])
     if(length(a) == 0) { next } 
     daterh[l,1,1:length(a)]   <-dataqrh[a,4]
     daterh[l,2,1:length(a)]   <-dataqrh[a,5]
     daterh[l,3,1:length(a)]   <-dataqrh[a,6]
     daterh[l,4,1:length(a)]   <-dataqrh[a,7]
     obsmodrh[l,1,1:length(a)] <-dataqrh[a,10]
     obsmodrh[l,2,1:length(a)] <-dataqrh[a,12]
     diffsq[l,2,]              <-obsmodrh[l,2,] - obsmodrh[l,1,]
     statsq[l,2,]              <-simple.stats(obsmodrh[l,1,],obsmodrh[l,2,])
    }
    # U and V to WS and WD
    obsmodws <-array(NA,c(nlq,2,maxdiml))
    obsmodwd <-array(NA,c(nlq,2,maxdiml))
    datews   <-array(NA,c(nlq,4,maxdiml))
    for(l in 1:nlq){
     a       <- which(dataqu[,8] == levelq[l])
     b       <- which(dataqv[,8] == levelq[l])
     if(length(a) < 2) { next } 
     datews[l,1,1:length(a)]  <-dataqu[a,4]
     datews[l,2,1:length(a)]  <-dataqu[a,5]
     datews[l,3,1:length(a)]  <-dataqu[a,6]
     datews[l,4,1:length(a)]  <-dataqu[a,7]
     obsu                     <-dataqu[a,10]
     modu                     <-dataqu[a,12]
     obsv                     <-dataqv[b,10]
     modv                     <-dataqv[b,12]
     obsws                    <-sqrt(obsu^2 + obsv^2)
     modws                    <-sqrt(modu^2 + modv^2)
     obsws                    <-ifelse(obsws < 0, NA, obsws)
     obsws                    <-ifelse(obsws > 250, NA, obsws)
     modws                    <-ifelse( is.na(obsws), NA, modws)
     obsmodws[l,1,1:length(a)]<-obsws[1:length(a)]
     obsmodws[l,2,1:length(a)]<-modws[1:length(a)]
     diffsq[l,3,]             <-obsmodws[l,2,] - obsmodws[l,1,]
     statsq[l,3,]             <-simple.stats(obsmodws[l,1,],obsmodws[l,2,])

     obswd       <- 180+(360/(2*pi))*atan2(obsu,obsv)
     modwd       <- 180+(360/(2*pi))*atan2(modu,modv)
     diffwd      <- obswd- modwd  
     diffwd      <-ifelse(diffwd > 180 , diffwd-360, diffwd)
     diffwd      <-ifelse(diffwd< -180 , diffwd+360, diffwd)
     obswd0      <-runif(length(diffwd),min=0,max=0.001)
     modwd0      <-diffwd

     obsmodwd[l,1,1:length(a)]<-obswd0[1:length(a)]
     obsmodwd[l,2,1:length(a)]<-modwd0[1:length(a)]
     diffsq[l,4,]             <-obsmodwd[l,2,] - obsmodwd[l,1,]
     statsq[l,4,]             <-simple.stats(obsmodwd[l,1,],obsmodwd[l,2,])
    }

    # Check array for surface pressure levels that vary from
    # sounding to sounding. Remove these levels based on much
    # fewer data points.
    nmax         <-max(statsq[,,5],na.rm=T)
    for(l in 1:nlq){
     for(v in 1:4) {
       if(is.na(statsq[l,v,5])) { next }
       if( statsq[l,v,5] < nmax/2 ) {
         statsq[l,1:4,1:4] <- NA
         diffsq[l,1:4,]    <- NA
         obsmodt[l,1:2,]   <-NA
         obsmodrh[l,1:2,]  <-NA
         obsmodws[l,1:2,]  <-NA
         obsmodwd[l,1:2,]  <-NA
       }
     }
    }

    lev.na       <- !is.na(statsq[,1,1])
    nlevs.new    <- sum(ifelse(lev.na,1,0),na.rm=T)
    statsq.new   <- array(NA,c(nlevs.new,4,5))
    diffsq.new   <- array(NA,c(nlevs.new,4,dim(diffsq)[3]))
    datet.new    <- array(NA,c(nlevs.new,4,maxdiml))
    daterh.new   <- array(NA,c(nlevs.new,4,maxdiml))
    datews.new   <- array(NA,c(nlevs.new,4,maxdiml))
    obsmodt.new  <- array(NA,c(nlevs.new,2,maxdiml))
    obsmodrh.new <- array(NA,c(nlevs.new,2,maxdiml))
    obsmodws.new <- array(NA,c(nlevs.new,2,maxdiml))
    obsmodwd.new <- array(NA,c(nlevs.new,2,maxdiml))
    levels.new   <- array(NA,c(nlevs.new))
    count        <- 1
    for(l in 1:nlq){
     if(lev.na[l]) {
       statsq.new[count,1:4,1:5] <- statsq[l,1:4,]
       diffsq.new[count,1:4,]    <- diffsq[l,1:4,]
       datet.new[count,,]        <- datet[l,1:4,]
       daterh.new[count,,]       <- daterh[l,1:4,]
       datews.new[count,,]       <- datews[l,1:4,]
       obsmodt.new[count,1:2,]   <- obsmodt[l,1:2,]
       obsmodrh.new[count,1:2,]  <- obsmodrh[l,1:2,]
       obsmodws.new[count,1:2,]  <- obsmodws[l,1:2,]
       obsmodwd.new[count,1:2,]  <- obsmodwd[l,1:2,]
       levels.new[count]         <- levelq[l]
       count                     <- count+1
     }
    }
   
    writeLines(paste("Plotting T, RH, WS and WD statistics profiles for site:",statid[s]))
    tmp<- plotProfRaobM(statsq.new, diffsq.new, levels.new, statid[s], plotopts, plotlab, runid=runid)
    tmp<- plotDistRaobM(obsmodrh.new, levels.new, statid[s], plotopts, plotlab, runid=runid)
    
   }
 }

 # Mandatory PRESSURE LEVEL CURTAIN PLOTS. RAOB, Model and difference
 # over user defined time range. Done for T, RH and WS. No wind direction.
 if(CURTAINM){

  stdpress <-c(1000,925,850,700,500,400,300,250,200,150,100,70,50,30,20,10)
  writeLines("  *****   MODEL-RAOB CURTAIN PLOTS ON MANDATORY PRESSURE LEVELS   *****")

  queryt   <-paste("SELECT",my.varget.spatial,"FROM",criteria.tmc," ORDER BY stat_id,ob_date,plevel")
  queryrh  <-paste("SELECT",my.varget.spatial,"FROM",criteria.rhmc," ORDER BY stat_id,ob_date,plevel")
  queryu   <-paste("SELECT",my.varget.spatial,"FROM",criteria.umc," ORDER BY stat_id,ob_date,plevel")
  queryv   <-paste("SELECT",my.varget.spatial,"FROM",criteria.vmc," ORDER BY stat_id,ob_date,plevel")

  for(s in 1:nsc){
    writeLines(paste("Extracting temperature, rel. hum. and wind profile data from the databse"))
    writeLines(paste(queryt[s]))
    dataqt <-ametQuery(queryt[s],mysql)
    dataqrh<-ametQuery(queryrh[s],mysql)
    dataqu <-ametQuery(queryu[s],mysql)
    dataqv <-ametQuery(queryv[s],mysql)
    levelq <- rev(sort( unique(c(dataqt[,8],dataqrh[,8],dataqu[,8],dataqv[,8]))))
    maxdiml<-round(max(dim(dataqv),dim(dataqu),dim(dataqt),dim(dataqrh))/5)

    is.mandatory <- which(is.element(levelq,stdpress))
    levelq       <- levelq[is.mandatory]
    nlq          <- length(levelq)

    # Check to see if site has enough data to pass threshold
    if(nlq < level.thresh) {
      writeLines(paste("******    WARNING: Sample size for the # of layers",nlq,
                       "does not meet the threshold of",level.thresh,"."))
      next
    }

    # T
    statsq  <-array(NA,c(nlq,4,5))
    diffsq  <-array(NA,c(nlq,4,maxdiml))
    obsmodt <-array(NA,c(nlq,2,maxdiml))
    datet   <-array(NA,c(nlq,4,maxdiml))
    for(l in 1:nlq){
     a      <- which(dataqt[,8] == levelq[l])
     if(length(a) == 0) { next } 
     datet[l,1,1:length(a)]   <-dataqt[a,4]
     datet[l,2,1:length(a)]   <-dataqt[a,5]
     datet[l,3,1:length(a)]   <-dataqt[a,6]
     datet[l,4,1:length(a)]   <-dataqt[a,7]
     obsmodt[l,1,1:length(a)] <-dataqt[a,10]
     obsmodt[l,2,1:length(a)] <-dataqt[a,12]
     diffsq[l,1,]             <-obsmodt[l,2,] - obsmodt[l,1,]
     statsq[l,1,]             <-simple.stats(obsmodt[l,1,],obsmodt[l,2,])
    }
    # RH
    obsmodrh <-array(NA,c(nlq,2,maxdiml))
    daterh   <-array(NA,c(nlq,4,maxdiml))
    for(l in 1:nlq){
     a      <- which(dataqrh[,8] == levelq[l])
     if(length(a) == 0) { next } 
     daterh[l,1,1:length(a)]   <-dataqrh[a,4]
     daterh[l,2,1:length(a)]   <-dataqrh[a,5]
     daterh[l,3,1:length(a)]   <-dataqrh[a,6]
     daterh[l,4,1:length(a)]   <-dataqrh[a,7]
     obsmodrh[l,1,1:length(a)] <-dataqrh[a,10]
     obsmodrh[l,2,1:length(a)] <-dataqrh[a,12]
     diffsq[l,2,]              <-obsmodrh[l,2,] - obsmodrh[l,1,]
     statsq[l,2,]              <-simple.stats(obsmodrh[l,1,],obsmodrh[l,2,])
    }
    # U and V to WS and WD
    obsmodws <-array(NA,c(nlq,2,maxdiml))
    obsmodwd <-array(NA,c(nlq,2,maxdiml))
    datews   <-array(NA,c(nlq,4,maxdiml))
    for(l in 1:nlq){
     a       <- which(dataqu[,8] == levelq[l])
     b       <- which(dataqv[,8] == levelq[l])
     if(length(a) < 2) { next } 
     datews[l,1,1:length(a)]  <-dataqu[a,4]
     datews[l,2,1:length(a)]  <-dataqu[a,5]
     datews[l,3,1:length(a)]  <-dataqu[a,6]
     datews[l,4,1:length(a)]  <-dataqu[a,7]
     obsu                     <-dataqu[a,10]
     modu                     <-dataqu[a,12]
     obsv                     <-dataqv[b,10]
     modv                     <-dataqv[b,12]
     obsws                    <-sqrt(obsu^2 + obsv^2)
     modws                    <-sqrt(modu^2 + modv^2)
     obsws                    <-ifelse(obsws < 0, NA, obsws)
     obsws                    <-ifelse(obsws > 250, NA, obsws)
     modws                    <-ifelse( is.na(obsws), NA, modws)
     obsmodws[l,1,1:length(a)]<-obsws
     obsmodws[l,2,1:length(a)]<-modws
     diffsq[l,3,]             <-obsmodws[l,2,] - obsmodws[l,1,]
     statsq[l,3,]             <-simple.stats(obsmodws[l,1,],obsmodws[l,2,])

     obswd       <- 180+(360/(2*pi))*atan2(obsu,obsv)
     modwd       <- 180+(360/(2*pi))*atan2(modu,modv)
     diffwd      <- obswd- modwd  
     diffwd      <-ifelse(diffwd > 180 , diffwd-360, diffwd)
     diffwd      <-ifelse(diffwd< -180 , diffwd+360, diffwd)
     obswd0      <-runif(length(diffwd),min=0,max=0.001)
     modwd0      <-diffwd

     obsmodwd[l,1,1:length(a)] <-obswd0
     obsmodwd[l,2,1:length(a)] <-modwd0
     diffsq[l,4,]              <-obsmodwd[l,2,] - obsmodwd[l,1,]
     statsq[l,4,]              <-simple.stats(obsmodwd[l,1,],obsmodwd[l,2,])
    }

    # Check array for surface pressure levels that vary from
    # sounding to sounding. Remove these levels based on much
    # fewer data points.
    nmax         <-max(statsq[,,5],na.rm=T)
    for(l in 1:nlq){
     for(v in 1:4) {
       if(is.na(statsq[l,v,5])) { next }
       if( statsq[l,v,5] < nmax/2 ) {
         statsq[l,1:4,1:4] <- NA
         diffsq[l,1:4,]    <- NA
         obsmodt[l,1:2,]   <-NA
         obsmodrh[l,1:2,]  <-NA
         obsmodws[l,1:2,]  <-NA
         obsmodwd[l,1:2,]  <-NA
       }
     }
    }

    lev.na       <- !is.na(statsq[,1,1])
    nlevs.new    <- sum(ifelse(lev.na,1,0),na.rm=T)
    statsq.new   <- array(NA,c(nlevs.new,4,5))
    diffsq.new   <- array(NA,c(nlevs.new,4,dim(diffsq)[3]))
    datet.new    <- array(NA,c(nlevs.new,4,maxdiml))
    daterh.new   <- array(NA,c(nlevs.new,4,maxdiml))
    datews.new   <- array(NA,c(nlevs.new,4,maxdiml))
    obsmodt.new  <- array(NA,c(nlevs.new,2,maxdiml))
    obsmodrh.new <- array(NA,c(nlevs.new,2,maxdiml))
    obsmodws.new <- array(NA,c(nlevs.new,2,maxdiml))
    obsmodwd.new <- array(NA,c(nlevs.new,2,maxdiml))
    levels.new   <- array(NA,c(nlevs.new))
    count        <- 1
    for(l in 1:nlq){
     if(lev.na[l]) {
       statsq.new[count,1:4,1:5] <- statsq[l,1:4,]
       diffsq.new[count,1:4,]    <- diffsq[l,1:4,]
       datet.new[count,,]        <- datet[l,1:4,]
       daterh.new[count,,]       <- daterh[l,1:4,]
       datews.new[count,,]       <- datews[l,1:4,]
       obsmodt.new[count,1:2,]   <- obsmodt[l,1:2,]
       obsmodrh.new[count,1:2,]  <- obsmodrh[l,1:2,]
       obsmodws.new[count,1:2,]  <- obsmodws[l,1:2,]
       obsmodwd.new[count,1:2,]  <- obsmodwd[l,1:2,]
       levels.new[count]         <- levelq[l]
       count                     <- count+1
     }
    }
   
   iso.datet <- ISOdatetime(year=datet.new[nlevs.new,1,], month=datet.new[nlevs.new,2,],
               day=datet.new[nlevs.new,3,],hour=datet.new[nlevs.new,4,], min=0, sec=0, tz="GMT")
   iso.daterh<- ISOdatetime(year=daterh.new[nlevs.new,1,], month=daterh.new[nlevs.new,2,],
               day=daterh.new[nlevs.new,3,],hour=daterh.new[nlevs.new,4,], min=0, sec=0, tz="GMT")
   iso.datews<- ISOdatetime(year=datews.new[nlevs.new,1,], month=datews.new[nlevs.new,2,],
               day=datews.new[nlevs.new,3,],hour=datews.new[nlevs.new,4,], min=0, sec=0, tz="GMT")

   minmax    <- range(iso.datet,iso.daterh,iso.datews,na.rm=T)
   date.vec  <-seq(minmax[1],minmax[2],by=(60*60*12))
   tmp<- plotProfTimeM(obsmodt.new, levels.new, iso.datet, date.vec, statidc[s], 
                 1, plotopts, plotlab, nt.thresh=5) 
   tmp<- plotProfTimeM(obsmodrh.new, levels.new, iso.daterh, date.vec, statidc[s],
                 2, plotopts, plotlab, nt.thresh=5) 
   tmp<- plotProfTimeM(obsmodws.new, levels.new, iso.datews, date.vec, statidc[s],
                 3, plotopts, plotlab, nt.thresh=5) 


  }
 }
 ############################################################################

 ##########################################################################################
 #### NATIVE PRESSURE LEVEL ANALYSIS ######

 ############################################################################
 # Profile of Model and RAOB on their Native levels for one time.
 # Done for T, RH, WS and WD
 if(PROFN){

  writeLines("  *****   PROFILE PLOTS ON NATIVE PRESSURE LEVELS OF RAOB AND MODEL  *****")

  for(s in 1:nsc){
    writeLines(paste("Extracting temperature, rel. hum. and wind profile data from the database"))
    query  <-paste("SELECT",my.varget.main,"FROM",raob.table,"WHERE",criteria.ton1[s]," ORDER BY plevel")
    writeLines(query)
    datato <-ametQuery(query,mysql)

    query  <-paste("SELECT",my.varget.main,"FROM",raob.table,"WHERE",criteria.tmn1[s]," ORDER BY plevel")
    datatm <-ametQuery(query[1],mysql)

    query  <-paste("SELECT",my.varget.main,"FROM",raob.table,"WHERE",criteria.uon1[s]," ORDER BY plevel")
    datauo <-ametQuery(query[1],mysql)

    query  <-paste("SELECT",my.varget.main,"FROM",raob.table,"WHERE",criteria.umn1[s]," ORDER BY plevel")
    dataum <-ametQuery(query[1],mysql)

    raob   <-list(site=statidc[s], date= my.dates, p_trh=datato[,6], t=datato[,8], rh=round(datato[,10]))    
    model  <-list(site=statidc[s], date= my.dates, p_trh=datatm[,6], t=datatm[,8], rh=round(datatm[,10]))    

    # Abort plotting if sample size is less than defined threshold
    if(length(raob$p_trh) < profilen.thresh) {
      writeLines(paste("Number of profile levels", length(raob$p_trh),
                 "does not meet the defined threshold of:",profilen.thresh))
      next
    }
    writeLines(paste("Plotting T and RH native level profiles for site:",statidc[s]))
    tmp<- plotProfRaobN(raob, model, plotopts, plotlab)
  }

 }
 ############################################################################

 ############################################################################
 # Time-Height plots of Model (Curtain plot) with RAOB overlaid
 # with markers of same color scale for subjective comparison
 # since levels of datasets are different and stats no computed.
 # Done for T, RH, WS and WD
 if(CURTAINN){

  writeLines("  *****   CURTAIN PLOTS ON NATIVE PRESSURE LEVELS OF RAOB AND MODEL  *****")

  for(s in 1:nsc){

    query     <-paste("SELECT",my.varget.main,"FROM",raob.table,"WHERE",criteria.ton2[s]," ORDER BY ob_date, plevel")
    datato    <-ametQuery(query[1],mysql)
    if(dim(datato)[1] < profilen.thresh*2) {
     writeLines(paste("*****  Number of samples is less than profilen.thresh ***** Will skip site:",statidc[s]))
     next
    } 
    iso.dateto<- ISOdatetime(year=datato[,2], month=datato[,3],
                 day=datato[,4],hour=datato[,5], min=0, sec=0, tz="GMT")
    minmax    <- range(iso.dateto,na.rm=T)
    date.veco <- seq(minmax[1],minmax[2],by=(60*60*12))
    raob      <- list(site=statidc[s], date=iso.dateto, datev=date.veco, p_trh=datato[,6], t=datato[,8], rh=datato[,10])

    query     <-paste("SELECT",my.varget.main,"FROM",raob.table,"WHERE",criteria.tmn2[s]," ORDER BY ob_date, plevel")
    datatm    <-ametQuery(query[1],mysql)
    if(dim(datatm)[1] < profilen.thresh*2) {
     writeLines(paste("*****  Number of samples is less than profilen.thresh ***** Will skip site:",statidc[s]))
     next
    } 
    iso.datetm<- ISOdatetime(year=datatm[,2], month=datatm[,3],
                 day=datatm[,4],hour=datatm[,5], min=0, sec=0, tz="GMT")
    minmax    <- range(iso.datetm,na.rm=T)
    date.vecm <- seq(minmax[1],minmax[2],by=(60*60*12))
    model     <- list(site=statidc[s], date=iso.datetm, datev=date.vecm, p_trh=datatm[,6], t=datatm[,8], rh=datatm[,10])

    if( length(unique(iso.datetm)) < 3) {
     writeLines(paste("*****  Number of soundings is less than 3 ***** Will skip site:",statidc[s]))
     next
    }
    #  Wind data is sparse so not implemented yet
    #query     <-paste("SELECT",my.varget.main,"FROM",raob.table,"WHERE",criteria.uon2[s]," ORDER BY ob_date, plevel")
    #datat     <-ametQuery(query[1],mysql)

    #query     <-paste("SELECT",my.varget.main,"FROM",raob.table,"WHERE",criteria.umn2[s]," ORDER BY ob_date, plevel")
    #datat     <-ametQuery(query[1],mysql)

    tmp<- plotProfTimeN(raob, model, plotopts, plotlab, user.custom.plot.settings, profilen.thresh)

  }

 }
############################################################################

