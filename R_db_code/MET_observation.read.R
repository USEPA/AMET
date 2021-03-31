#######################################################################################################
#####################################################################################################
#                                                                 ################################
#     AMET Read Observations Functions Library                    ###############################
#                                                                 ###############################
#     Developed by the US Environmental Protection Agency         ###############################
#                                                                 ################################
#####################################################################################################
#######################################################################################################
#
#  V1.3, 2017Apr18, Robert Gilliam: Initial Development
#  V1.4, 2018Sep30, Robert Gilliam: 
#    - Added functions to parse BSRN radiation observations and average.
#    - Added functions rawindonde (raob) observation file read.
#    - Added functions wind profile (profiler) observation file read.
#
#######################################################################################################
#######################################################################################################
#     This script contains the following functions
#
#     madis_surface      --> Takes MADIS directory, date/time information and model projection
#                            then opens MADIS files and extracts site information and their observations.
#                            Wind direction is adjusted to match the projection. A standard AMET
#                            observation list is returned. See function for list details.
#
#     madis_raob         --> Rawindsonde data reader for MADIS NetCDF files
#
#     madis_profiler     --> Wind profiler data reader for MADIS NetCDF files
#
#     text_surface       --> Text observation option instead of MADIS surface NetCDF file. See function
#                            for input text file details. The same standard AMET surface obs list is
#                            returned as MADIS option.
#
#     bsrn_observations  --> Main BSRN radiation observation read function. This calls the parse function below
#                            to arrange a data field with monthly radiation, time and by site IDs.
#
#     bsrn_parse         --> Parser of BSRN text file format.
#
#     bsrn_get_avg       --> Temporal averaging routine of 1 min BSRN radiation given user time average window spec.
#
#     check_for_bsrn_read--> Simple function that checks if the current model time is in BSRN obs data.
#
#######################################################################################################
#######################################################################################################

##########################################################################################################
#####--------------------------  START OF FUNCTION: MADIS_SURFACE  -----------------------------------####
# Function that reads MADIS surface met NetCDF file and extracts observations into AMET surface
# observation list structure.
#
# Input:
#       madisbase   -- base directory of MADIS obs file structure.
#       madis_dset  -- MADIS surface obs dataset: metar, sao or maritime (only)
#       datetime    -- Date time list that includes modeldate, modeltime, yc, mc, dc, hc
#       lonc        -- Center longitude of a WRF model projection. Used to alter wind direction
#       conef       -- Model domain cone factor. Like lonc, this is used to rotate wind to model.
#
# Output: Multi-level list of observation meta data and actual observed meteorology
#
#  site   <-list(ns=ns,nsr=nsr,site=site,sites_unique=sites_unique,slat=slat,slon=slon,site_locname=site_locname,
#                report_type=report_type,ihour=ihour,imin=imin,isec=isec,
#                stime=stime,stime2=stime2)
#  sfc_met<-list(t2=stemp,q2=smixr,u10=su10,v10=sv10)


 madis_surface <-function(madisbase, madis_dset, datetime, autoftp, madis_server, lonc=0.0, conef=0.0) {

  madisdir  <-paste(madisbase,"/point/",madis_dset,"/netcdf",sep="")
  madis_file<-paste(madisdir,"/",datetime$yc,datetime$mc,datetime$dc,"_",datetime$hc,"00",sep="")
  if(madis_dset == "mesonet") {
    madisdir  <-paste(madisbase,"/LDAD/",madis_dset,"/netCDF",sep="")
    madis_file<-paste(madisdir,"/",datetime$yc,datetime$mc,datetime$dc,"_",datetime$hc,"00",sep="")
  }

  if(madis_dset != "sao" & madis_dset != "metar" & madis_dset != "maritime" & madis_dset != "mesonet") {
    stop("Check MADISDSET setting. Only metar, sao or maritime are acceptable ids.")
  }

  if(!file.exists(madis_file) & autoftp) {
    madispath   <-paste("/point/",madis_dset,"/netcdf/",sep="")
    if(madis_dset == "mesonet") {
      madispath   <-"/LDAD/mesonet/netCDF/"
    }
    gzname      <-paste(datetime$yc,datetime$mc,datetime$dc,"_",datetime$hc,"00.gz",sep="")
    nogzname    <-paste(datetime$yc,datetime$mc,datetime$dc,"_",datetime$hc,"00",sep="")
    remote_file <- paste(madis_server,"/",datetime$yc,"/",datetime$mc,"/",datetime$dc,
                         madispath,gzname,sep="")
    writeLines(paste("Getting remote file, unzipping and moving to the MADIS archive:",remote_file,nogzname))
    try(download.file(remote_file,gzname,"wget"))
    system(paste("gunzip",gzname))
    system(paste("mv",nogzname,madis_file))
  }  

  if(!file.exists(madis_file)) { 
    writeLines(paste("MADIS FILE *NOT* Found: ",madis_file," for time:",datetime$modeldate,datetime$modeltime))
    writeLines("Skipping to next time")
    system(paste("rm",gzname))
    return(NA)
  }
  writeLines(paste("Opening MADIS",madis_dset," for time:",datetime$modeldate,datetime$modeltime))
  writeLines(paste(madis_file))

  unix_time_str<-paste(datetime$yc,"-",datetime$mc,"-",datetime$dc," ",datetime$hc,":00:00",sep="")
  epoch_time   <-as.integer(as.POSIXct(unix_time_str,tz="UTC"))

  f2     <-nc_open(madis_file)
    if(madis_dset != "mesonet"){
      site   <- ncvar_get(f2, varid="stationName")
      stime  <- ncvar_get(f2, varid="timeObs")
    } else {
      site   <- ncvar_get(f2, varid="stationId")
      stime  <- ncvar_get(f2, varid="observationTime")    
    }  
    slat   <- ncvar_get(f2, varid="latitude")
    slon   <- ncvar_get(f2, varid="longitude")
    selev  <- ncvar_get(f2, varid="elevation")

    stime2 <- array(epoch_time,c(length(site)))
    
    # Some MADIS file types have different specs, so logic required for each
    if(madis_dset == "sao") {
        report_type  <- array("SAO",c(length(site)))
        site_locname <- array("NULL",c(length(site)))
        altm         <- ncvar_get(f2, varid="altimeter")/100
        precip1      <- ncvar_get(f2, varid="precip1Hour")
        snow         <- array("NULL",c(length(site)))
    } else if (madis_dset == "maritime") {
        report_type  <- array("MARITIME",c(length(site)))
        site_locname <- array("NULL",c(length(site)))
        altm         <- ncvar_get(f2, varid="seaLevelPress")/100
        precip1      <- array("NULL",c(length(site)))
        snow         <- array("NULL",c(length(site)))
    } else if (madis_dset == "metar") {
        site_locname <- ncvar_get(f2, varid="locationName")
        report_type  <- ncvar_get(f2, varid="reportType")
        altm         <- ncvar_get(f2, varid="altimeter")/100
        precip1      <- ncvar_get(f2, varid="precip1Hour")
        snow         <- ncvar_get(f2, varid="snowCover")
    } else if (madis_dset == "mesonet") {
        report_type  <- array("MESONET",c(length(site)))
        site_locname <- ncvar_get(f2, varid="homeWFO")
        report_type  <- ncvar_get(f2, varid="dataProvider")
        altm         <- ncvar_get(f2, varid="altimeter")/100
        precip1      <- array("NULL",c(length(site)))
        snow         <- array("NULL",c(length(site)))
    }
    site_locname<- gsub("'"," ",site_locname)  # replace any ' with space
    
    timeday  <-((stime+0.5)/(60*60*24))
    timehour <-(timeday-floor(timeday))*24
    timemin  <-(timehour-floor(timehour))*60
    timesec  <-(timemin-floor(timemin))*60
    ihour    <-as.integer(floor(timehour))
    imin     <-as.integer(floor(timemin))
    isec     <-as.integer(floor(timesec))
  
    ns<-length(site)
    # Station Pressure NOTE: Copied from MADIS code m_ztopsa.f. 
    # Ignore MADIS code condition for sites above 11,000 m as no sites exist
    # calc produces spres in mb. Clausius-Calapeyron vapor pressure to mixing
    # ratio requires Pressure in kPa, thus, spres(mb)/10
    P0       <-1013.2
    T0       <-288.0
    GAMMA    <-0.0065
    C1       <-5.256
    C2       <-14600.0
    Z11      <-11000.0
    P11      <-226.0971
    spres    <- P0*((T0-GAMMA*selev)/T0)**C1
    spres    <- spres/10
    
    # Second method to calculation station pressure from altimeter and elevation
    # This is more accurate since the elevation only does not account for weather
    # related pressure fluctuations. Causes ~+/- 0.1 g/kg differences.
    # Altimeter from mb to mmHg
    Pa<- altm * 0.750062
    # Altimeter from mmHg to inHg and converted to station pressure inHg
    Pa<- 0.03937007 * Pa
    stationpres<- Pa * ( (288- 0.0065 *selev)/288 )^5.2561
    # Station Pressure from inHg to mmHg to mb to kPa
    stationpres<-stationpres * 25.4
    stationpres<-stationpres * 1.333224
    stationpres<-stationpres/10
    # QC of station pressure. No sites above ~ 6 km or 500 mb
    stationpres<-ifelse(stationpres < 50, NA, stationpres)
    stationpres<-ifelse(stationpres > 1100, NA, stationpres)
    
    # 2-m Temperature
    stemp <- ncvar_get(f2, varid="temperature")
    stemp <-ifelse(stemp > 400,NA, stemp)

    # 2-m Mixing Ratio
    sdewp <- ncvar_get(f2, varid="dewpoint")
    
    # Compute Mixing ratio from dewpoint and station pressure.
    e      <- 0.611 * exp ( (2.501E6/461.5) * ( (1/273.14) -(1/sdewp) ) )
    smixr1 <- 0.62197 * (e/(spres-e))
    smixr2 <- 0.62197 * (e/(stationpres-e))
    smixr  <-ifelse(smixr2 <   0.000001,NA, smixr2)

    # 10-m Wind Speed. Set crazy values to NA. Set zero wind speed to NA.
    swspd <- ncvar_get(f2, varid="windSpeed")
    swdir <- ncvar_get(f2, varid="windDir")
    swspd <-ifelse(swspd > 4000,NA, swspd)
    swspd <-ifelse(swspd == 0,NA, swspd)
    swdir <-ifelse(swdir > 4000,NA, swdir)

    # Adjustment of wind direction from magnetic north to the projection.
    # Note: conef is zero for MPAS, so no adjustment done.
    adjust <- (lonc - slon) * conef;
    swdir  <- swdir+adjust
    su10   <-(-1)*swspd*sin(swdir*pi/180)
    sv10   <-(-1)*swspd*cos(swdir*pi/180) 
    
    # Rough QC of station pressure

  nc_close(f2) # Close MADIS obs file

  sites_unique <-unique(site)
  nsr          <-length(sites_unique)

  site   <-list(ns=ns, nsr=nsr, site=site, sites_unique=sites_unique, slat=slat, slon=slon,
                elev=selev, site_locname=site_locname, report_type=report_type, ihour=ihour,
                imin=imin, isec=isec, stime=stime, stime2=stime2)
  sfc_met<-list(t2=stemp, q2=smixr, u10=su10, v10=sv10, psf=stationpres,
                precip1=precip1,snow=snow)

  return(list(meta=site,sfc_met=sfc_met))

 }
#####----------------------	  END OF FUNCTION: MADIS_SURFACE     ---------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------  START OF FUNCTION: MADIS_RAOB     -----------------------------------####
# Function that reads MADIS rawindsonde profile NetCDF file and extracts observations into AMET raob
# observation list structure.
#
# Input:
#       madisbase   -- base directory of MADIS obs file structure.
#       datetime    -- Date time list that includes modeldate, modeltime, yc, mc, dc, hc
#       autoftp     -- Automatic FTP option (T/F)
#       madis_server-- MADIS FTP server name
#       lonc        -- Center longitude of a WRF model projection. Used to alter wind direction
#       conef       -- Model domain cone factor. Like lonc, this is used to rotate wind to model.
#
# Output: Multi-level list of observation meta data and observed meteorology
#
#  site   <-list(ns=ns,nsr=nsr,site=site,sites_unique=sites_unique,slat=slat,slon=slon,site_locname=site_locname,
#                report_type=report_type,ihour=ihour,imin=imin,isec=isec,
#                stime=stime,stime2=stime2)
#  raob_met<-list(ghgtm=ghgtm, prest=prest, presw=presw, presm=presm, tempm=temp, temps=temps, 
#                 mixrm=mixr, mixrs=mixrs, rhm=rhm, rhs=rhs, um=um, vm=vm, us=us, vs=vs,
#                 wspdm=wspd, wspds=wspds, wdirm=wdir, wdirs=wdirs, wdirma=wdira1, wdirsa=wdira2 )


 madis_raob <-function(madisbase, datetime, autoftp, madis_server, lonc=0.0, conef=0.0) {

  madisdir  <-paste(madisbase,"/point/",madis_dset,"/netcdf",sep="")
  madis_file<-paste(madisdir,"/",datetime$yc,datetime$mc,datetime$dc,"_",datetime$hc,"00",sep="")

  if(!file.exists(madis_file) & autoftp) {
    madispath   <-paste("/point/",madis_dset,"/netcdf/",sep="")
    gzname      <-paste(datetime$yc,datetime$mc,datetime$dc,"_",datetime$hc,"00.gz",sep="")
    nogzname    <-paste(datetime$yc,datetime$mc,datetime$dc,"_",datetime$hc,"00",sep="")
    remote_file <- paste(madis_server,"/",datetime$yc,"/",datetime$mc,"/",datetime$dc,
                         madispath,gzname,sep="")
    writeLines(paste("Getting remote file, unzipping and moving to the MADIS archive:",remote_file,nogzname))
    try(download.file(remote_file,gzname,"wget",quiet = T))
    if(file.exists(gzname)) {
      system(paste("gunzip",gzname))
      system(paste("mv",nogzname,madis_file))
    }
  }  

  if(!file.exists(madis_file)) { 
    writeLines(paste("MADIS FILE *NOT* Found: ",madis_file," for time:",datetime$modeldate,datetime$modeltime))
    writeLines("Skipping to next time")
    system(paste("rm",gzname))
    site<-list(ns=0)
    return(meta=list(meta=site))
  }
  writeLines(paste("Opening MADIS",madis_dset," for time:",datetime$modeldate,datetime$modeltime))
  writeLines(paste(madis_file))

  unix_time_str<-paste(datetime$yc,"-",datetime$mc,"-",datetime$dc," ",datetime$hc,":00:00",sep="")
  epoch_time   <-as.integer(as.POSIXct(unix_time_str,tz="UTC"))

  f2     <-nc_open(madis_file)
    site   <- ncvar_get(f2, varid="staName")
    stime  <- ncvar_get(f2, varid="synTime")    
    slat   <- ncvar_get(f2, varid="staLat")
    slon   <- ncvar_get(f2, varid="staLon")
    selev  <- ncvar_get(f2, varid="staElev")

    stime2       <- array(epoch_time,c(length(site)))
    report_type  <- array("RAOB",c(length(site)))
    site_locname <- array("NULL",c(length(site)))
    
    # replace any ' with space
    site_locname <- gsub("'"," ",site_locname)  
    
    timeday  <-((stime+0.5)/(60*60*24))
    timehour <-(timeday-floor(timeday))*24
    timemin  <-(timehour-floor(timehour))*60
    timesec  <-(timemin-floor(timemin))*60
    ihour    <-as.integer(floor(timehour))
    imin     <-as.integer(floor(timemin))
    isec     <-as.integer(floor(timesec))
  
    ns       <-length(site)
    
    # Height coordinates of ROAB. Significant and Mandantory levels
    # Note: temperature/dewpoint and winds are on different levels.
    #       Native levels will be put in database for plotting.
    #       Mandantory levels will be matched with model for statistics.
    prest <- ncvar_get(f2, varid="prSigT")
    presw <- ncvar_get(f2, varid="prSigW")
    presm <- ncvar_get(f2, varid="prMan")
    ghgtm <- ncvar_get(f2, varid="htMan")
    ghgts <- ncvar_get(f2, varid="htSigW")

    mlevs <- dim(presm)[1]
    tlevs <- dim(prest)[1]
    wlevs <- dim(presw)[1]

    # Temperature (K). QC Limits come from MADIS Raob gross check.
    # temp -> Mandantory level temperature, temps <- Sig. level temp
    temp <- ncvar_get(f2, varid="tpMan")
    temp <- ifelse(temp < 173, NA, temp)
    tempm<- ifelse(temp > 373, NA, temp)

    temps <- ncvar_get(f2, varid="tpSigT")
    temps <- ifelse(temps < 173, NA, temps)
    temps <- ifelse(temps > 373, NA, temps)

    # Dewpoint depression (K). QC Limits come from MADIS Raob gross check.
    # dewp -> Mandantory level dew temperature, dewps <- Sig. level dew temp
    dewpd <- ncvar_get(f2, varid="tdMan")
    dewpd <-ifelse(dewpd < 0.,NA, dewpd)
    dewpd <-ifelse(dewpd > 60,NA, dewpd)
    dewpm <- tempm - dewpd
    
    dewpd <- ncvar_get(f2, varid="tdSigT")
    dewpd <-ifelse(dewpd < 0.,NA, dewpd)
    dewpd <-ifelse(dewpd > 60,NA, dewpd)
    dewps  <- temps - dewpd

    # Compute Mixing ratio from dewpoint (station pressure hPa to kPa).
    # mixr -> Mandantory level mixing ratio, mixrs <- Sig. level mixr
    e      <- 0.611 * exp ( (2.501E6/461.5) * ( (1/273.14) -(1/dewpm) ) )
    mixr   <- 0.62197 * (e/(presm/10-e))
    mixr   <-ifelse(mixr*1000 <   0.00000001,NA, mixr)
    mixrm  <-ifelse(mixr*1000 >   30,NA, mixr)

    e      <- 0.611 * exp ( (2.501E6/461.5) * ( (1/273.14) -(1/dewps) ) )
    mixrs  <- 0.62197 * (e/(prest/10-e))
    mixrs  <-ifelse(mixrs*1000 <   0.00000001,NA, mixrs)
    mixrs  <-ifelse(mixrs*1000 >   30,NA, mixrs)

    # Compute RH (%) from mixing ratio and temperature (saturated mixr)
    # rh -> Mandantory level rel. hum., rhs <- Sig. level rel. hum.
    e      <- 0.611 * exp ( (2.501E6/461.5) * ( (1/273.14) -(1/tempm) ) )
    smixr  <- 0.62197 * (e/(presm/10-e))
    smixr  <-ifelse(smixr*1000 <   0.00000001,NA, smixr)
    smixr  <-ifelse(smixr*1000 >   35,NA, smixr)
    rh     <- 100*mixrm/smixr
    rh     <-ifelse(rh > 100, 100, rh)
    rhm    <-ifelse(rh <   0,   0, rh)

    e      <- 0.611 * exp ( (2.501E6/461.5) * ( (1/273.14) -(1/temps) ) )
    smixr  <- 0.62197 * (e/(prest/10-e))
    smixr  <-ifelse(smixr*1000 <   0.00000001,NA, smixr)
    smixr  <-ifelse(smixr*1000 >   35,NA, smixr)
    rhs    <- 100*mixrs/smixr
    rhs    <-ifelse(rhs > 100, 100, rhs)
    rhs    <-ifelse(rhs <   0,   0, rhs)

    # 10-m Wind Speed. Set crazy values to NA. Set zero wind speed to NA.
    wspd  <- ncvar_get(f2, varid="wsMan")
    wdir  <- ncvar_get(f2, varid="wdMan")
    wspd  <-ifelse(wspd > 300,NA, wspd)
    wdir  <-ifelse(wdir <   0, NA, wdir)
    wdir  <-ifelse(wdir > 360, NA, wdir)

    wspds <- ncvar_get(f2, varid="wsSigW")
    wdirs <- ncvar_get(f2, varid="wdSigW")
    wspds <-ifelse(wspds > 300,NA, wspds)
    wdirs <-ifelse(wdirs <   0, NA, wdirs)
    wdirs <-ifelse(wdirs > 360, NA, wdirs)
    slevs <-dim(wdirs)[1]

    # Adjustment of wind direction from magnetic north to the projection.
    # Note: conef is zero for MPAS, so no adjustment done.
    adjust <- (lonc - slon) * conef
    adjust_levels <-function(A) A + adjust
    wdiram        <-t(apply(wdir,1,adjust_levels))
    wdiras        <-t(apply(wdirs,1,adjust_levels))
    if(dim(wdiram)[1] == 1 ){
      wdiram      <-array(wdiram)
      wdiras      <-array(wdiras)
    }

    um     <-(-1)*wspd*sin(wdiram*pi/180)
    vm     <-(-1)*wspd*cos(wdiram*pi/180) 
    
    us     <-(-1)*wspds*sin(wdiras*pi/180)
    vs     <-(-1)*wspds*cos(wdiras*pi/180) 

  nc_close(f2) # Close MADIS obs file  

  sites_unique <-unique(site)
  nsr          <-length(sites_unique)

  site   <-list(ns=ns, nsr=nsr, site=site, sites_unique=sites_unique, slat=slat, slon=slon,
                elev=selev, site_locname=site_locname, report_type=report_type, ihour=ihour,
                imin=imin, isec=isec, stime=stime, stime2=stime2)
  raob_met<-list(ghgtm=ghgtm, ghgts=ghgts, prest=prest, presw=presw, presm=presm, tempm=temp, 
                 temps=temps, mixrm=mixr, mixrs=mixrs, rhm=rhm, rhs=rhs, um=um, vm=vm, us=us, vs=vs,
                 wspdm=wspd, wspds=wspds, wdirm=wdir, wdirs=wdirs, wdiram=wdiram, wdiras=wdiras )

  return(list(meta=site, raob_met=raob_met))

 }
#####----------------------   	   END OF FUNCTION: MADIS_RAOB       ---------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: TEXT_SURFACE             ------------------------####
#  Text surface meteorology observation file read function. Allows user to leverage non-standard
#  meteorology observations using a simple text file format.
#  One line file header: site, network, slat, slon, YYYYMMDD, HHMM, t2m, wvmr2m, u10, v10
#  Followed by observations. One file for each hour that includes all sites in directory:
#  $AMETBASE/obs/MET/surface_text. See this directory for README file that provides more information.
#
# Input:
#       madisbase   -- base directory of MADIS obs file structure.
#       datetime    -- Date time list that includes modeldate, modeltime, yc, mc, dc, hc
#       lonc        -- Center longitude of a WRF model projection. Used to alter wind direction
#       conef       -- Model domain cone factor. Like lonc, this is used to rotate wind to model.
#
# Output: Multi-level list of observation meta data and actual observed meteorology
#
#  site   <-list(ns=ns,nsr=nsr,site=site,sites_unique=sites_unique,slat=slat,slon=slon,site_locname=site_locname,
#                report_type=report_type,ihour=ihour,imin=imin,isec=isec,
#                stime=stime,stime2=stime2)
#  sfc_met<-list(t2=stemp,q2=smixr,u10=su10,v10=sv10)

 text_surface <-function(madisbase, datetime, lonc, conef) {

  textobsdir  <-paste(madisbase,"/surface_text",sep="")
  obsfile     <-paste(textobsdir,"/",datetime$yc,datetime$mc,datetime$dc,"_",datetime$hc,"00",sep="")

  if(!file.exists(obsfile)) { 
    writeLines(paste("Text Observation FILE *NOT* Found: ",obsfile," for time:",
                     datetime$modeldate,datetime$modeltime))
    writeLines("Skipping to next time")
    return(NA)
  }
  writeLines(paste("Opening Text Observation file",obsfile," for time:",
                    datetime$modeldate,datetime$modeltime))
  obsarray    <-read.delim(obsfile,sep=",",header=T)
  site        <-as.character(obsarray[,1])
  report_type <-as.character(obsarray[,2])
  slat        <-as.numeric(obsarray[,3])
  slon        <-as.numeric(obsarray[,4])

  stemp       <-as.numeric(obsarray[,7])
  smixr       <-as.numeric(obsarray[,8])
  su10        <-as.numeric(obsarray[,9])
  sv10        <-as.numeric(obsarray[,10])

  stime    <- as.numeric(datetime$yc)*1E6 + as.numeric(datetime$mc)*1E4 + 
              as.numeric(datetime$dc)*1E2 + as.numeric(datetime$hc)
  ihour    <-as.integer(datetime$hc)
  imin     <-as.integer(00)
  isec     <-as.integer(00)

  # Adjustment of wind direction from magnetic north to the projection.
  # Note: conef is zero for MPAS, so no adjustment done.
  swspd  <- sqrt(su10^2 + sv10^2)
  swdir  <- 180+(360/(2*pi))*atan2(su10,sv10)
  adjust <- (lonc - slon) * conef
  swdir2 <- swdir+adjust
  su10   <-(-1)*swspd*sin(swdir2*pi/180)
  sv10   <-(-1)*swspd*cos(swdir2*pi/180) 
  
  
  site_locname <- array("NULL",c(length(site)))
  stime  <- array(stime,c(length(site)))
  stime2 <- array(stime,c(length(site)))

  ns           <-length(site)
  sites_unique <-unique(site)
  nsr          <-length(sites_unique)

  site   <-list(ns=ns,nsr=nsr,site=site,sites_unique=sites_unique,slat=slat,slon=slon,site_locname=site_locname,
                report_type=report_type,ihour=ihour,imin=imin,isec=isec,
                stime=stime,stime2=stime2)
  sfc_met<-list(t2=stemp,q2=smixr,u10=su10,v10=sv10)

  return(list(meta=site,sfc_met=sfc_met))

 }
#####--------------------------	  END OF FUNCTION TEXT_SURFACE     -----------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: BSRN_OBSERVATIONS        ------------------------####
#
# Input:
#
# Output: 
#

 bsrn_observations <-function(madisbase, datetime, model_lat, model_lon, ametdbase, sitecommand,  
                              bsrn_server, bsrn_login, bsrn_pass, autoftp=F, updateSiteTable=F) {

  ndays.month     <- 31
  mins.in.a.month <- 60*24*ndays.month
  rows.in.a.month <- mins.in.a.month*2

  bsrnsitefile    <-paste(madisbase,"/bsrn/bsrn_sites.csv",sep="")
  latr            <-range(model_lat)
  lonr            <-range(model_lon)
  lonr360          <-ifelse(lonr < 0, lonr + 360,lonr)
  if(range(lonr)[2]-range(lonr)[1] > 359) {
    lonr360<-c(-180,180)
  }

  day.get <- datetime$dc
  tmp     <- unlist(strsplit(datetime$yc,split=""))
  yy      <- paste(tmp[3],tmp[4],sep="")
  datefile<- paste(datetime$mc,yy,sep="")
  
  # Read BSRN stations metadata file for site information
  writeLines(paste("Opening BSRN site metadata file",bsrnsitefile," and updating stations table."))
  bsrn.site.data<-read.delim(bsrnsitefile,sep=",",header=T)
  ns            <- dim(bsrn.site.data)[1]
  common_name   <-as.character(bsrn.site.data[,1])
  stat_id       <-tolower(as.character(bsrn.site.data[,2]))
  country       <-as.character(bsrn.site.data[,3])
  slat          <-as.numeric(bsrn.site.data[,4])
  slon          <-as.numeric(bsrn.site.data[,5])
  selev         <-as.numeric(bsrn.site.data[,6])
  slon360       <-ifelse(slon < 0, slon + 360,slon)
  ob_network    <-array("BSRN",c(ns))
  site_avail    <-array(8,c(ns))

  ##########################################################
  # Update Site information in the AMET stations table
  if(updateSiteTable) {
    system("rm -f tmp.site.query") 
    sfile<-file("tmp.site.query","a")
    writeLines(paste("use",mysql$dbase,";"),con=sfile) 
    for(s in 1:ns) {  
        query <-paste("REPLACE into stations (stat_id, ob_network, common_name, country, lat, lon, elev)
                       VALUES ('",stat_id[s],"','",ob_network[s],"','",common_name[s],"','",country[s],"',",
                       slat[s],",",slon[s],",",selev[s],");",sep="")
        writeLines(paste(query),con=sfile)             
    }            
    close(sfile)
    system(sitecommand)
  }
  ##########################################################
  
  # Cycle through sites to determine if in domain and create 
  ns_in_domain   <- 0
  site_ind       <- array(NA,c(ns))
  stat_id_domain <- array(NA,c(ns))
  stat_ll_domain <- array(NA,c(ns,2))
  for(s in 1:ns) {  
    
    if( (slat[s] < latr[1] | slat[s] > latr[2]) | 
#        (slon360[s] < lonr360[1] | slon360[s] > lonr360[2]) ) {
        (slon[s] < lonr[1] | slon[s] > lonr[2]) ) {
       writeLines(paste("LAT OUT OF BOUNDS",stat_id[s],slat[s],latr[1],latr[2])) 
       next 
    }
    else {
       writeLines(paste("IN BOUNDS",stat_id[s],slat[s],slon[s]))
       ns_in_domain <- ns_in_domain + 1 
       site_ind[ns_in_domain]<-s       
    }
  }
  stat_id_domain   <-stat_id[site_ind[1:ns_in_domain]]
  slat_in_domain   <-slat[site_ind[1:ns_in_domain]]
  slon_in_domain   <-slon[site_ind[1:ns_in_domain]]
  sname_in_domain  <-common_name[site_ind[1:ns_in_domain]]
  network_in_domain<-ob_network[site_ind[1:ns_in_domain]]

  site_avail       <-array(0,c(ns_in_domain))
  site_data        <-array(NA,c(mins.in.a.month,5,ns_in_domain))
  site_date        <-array(NA,c(mins.in.a.month,2,ns_in_domain))

  # Download BSRN obs file for each site in domain and setup bsrn obs data array
  for(s in 1:ns_in_domain) {  
    bsrnobsfile <-paste(madisbase,"/bsrn/",stat_id_domain[s],datefile,".dat",sep="")
    if(autoftp & !file.exists(bsrnobsfile) ) { 
      bsrn_server  <-"ftp://ftp.bsrn.awi.de/"
      gzname       <-paste(stat_id_domain[s],datefile,".dat.gz",sep="")
      nogzname     <-paste(stat_id_domain[s],datefile,".dat",sep="")
      remote_file  <- paste(bsrn_server,"/",stat_id_domain[s],"/",gzname,sep="")
      writeLines(paste("Getting remote file and moving to the BSRN archive:",remote_file,bsrnobsfile))

      try(download.file(remote_file,gzname,"wget",extra=paste("--user",bsrn_login,
                        "--password",bsrn_pass,"--max-redirect=0")))

      if(site_avail[s] != 0 ){
        writeLines(paste("File was not availiable for these dates:",remote_file))
      }
      else {
        system(paste("gunzip",gzname))
        system(paste("mv",nogzname,bsrnobsfile))
        system(paste("rm -f ",gzname))
      }    
    }
    if(!file.exists(bsrnobsfile)) { 
      site_avail[s]<-0
      writeLines(paste("BSRN Site FILE *NOT* found: ",bsrnobsfile))
      writeLines("Will skip and set obs data for this site to missing.")
      next
    }

    if(file.exists(bsrnobsfile)) { 
      writeLines(paste("BSRN monthly Site FILE is in the archive: ",bsrnobsfile))
      writeLines(paste("PARSING BSRN data.... "))
      obs <-bsrn_parse(bsrnobsfile)
      if(is.list(obs)){
        site_avail[s]     <-1
        site_date[,1,s]   <-obs$daytime$day    
        site_date[,2,s]   <-obs$daytime$hour    
        site_data[,1,s]   <-obs$sfc_met$swr_global   
      }     
    }


  }  # END LOOP THROUGH SITES
  ###########################################################################################################
  system("date")


  site   <-list(ns=ns_in_domain, nsr=ns_in_domain, site=stat_id_domain, 
                sites_unique=stat_id_domain, slat=slat_in_domain, slon=slon_in_domain, 
                report_type=sname_in_domain, site_locname=network_in_domain)

  return(list(meta=site,ob_times=site_date, sfc_met=site_data))

 }
#####--------------------------	  END OF FUNCTION BSRN_OBSERVATIONS     ------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: BSRN_PARSE               ------------------------####
#
# Input:
#
# Output: 
#

 bsrn_parse <-function(bsrnobsfile) {

  ndays.month     <- 31
  mins.in.a.month <- 60*24*ndays.month
  rows.in.a.month <- mins.in.a.month*2

  bsrn.data <-read.delim(bsrnobsfile,header=F,blank.lines.skip = FALSE)
  nl        <-dim(bsrn.data)[1]
  row_start <- 0
  count     <- 0
  for(l in 1:nl){
   if(trimws(bsrn.data[l,1])=="*C0100" || trimws(bsrn.data[l,1])=="*U0100") {
    row_start <- count +1
    break
   }
   count<-count+1
  }

  if(row_start== 0) {
    return(0)
    next
  }
  # PARSE into arrays where data of interest can be extracted
  a         <-read.delim(bsrnobsfile,skip=row_start+1,sep=",")
  b         <-as.character(unlist(a[1:rows.in.a.month,1]))
  c         <-strsplit(b,"")

  day          <-array(NA,c(mins.in.a.month))
  min          <-array(NA,c(mins.in.a.month))
  swr_global   <-array(NA,c(mins.in.a.month))
  swr_direct   <-array(NA,c(mins.in.a.month))
  swr_diffuse  <-array(NA,c(mins.in.a.month))
  lwr_down     <-array(NA,c(mins.in.a.month))
  temp         <-array(NA,c(mins.in.a.month))
  relhum       <-array(NA,c(mins.in.a.month))

  row<-1
  ind<-1
  while(row <= rows.in.a.month) {
    d<- unlist(c[row])
    e<- unlist(c[row+1])
    day[ind]         <-as.numeric(paste(d[1],d[2],d[3],sep=""))
    min[ind]         <-as.numeric(paste(d[4],d[5],d[6],d[7],d[8],sep=""))
    swr_global[ind]  <-as.numeric(paste(d[12],d[13],d[14],d[15],sep=""))
    swr_direct[ind]  <-as.numeric(paste(d[35],d[36],d[37],d[38],sep=""))
    swr_diffuse[ind] <-as.numeric(paste(e[12],e[13],e[14],e[15],sep=""))
    lwr_down[ind]    <-as.numeric(paste(e[35],e[36],e[37],e[38],sep=""))
    temp[ind]        <-as.numeric(paste(e[59],e[60],e[61],e[62],d[63],sep=""))
    relhum[ind]      <-as.numeric(paste(e[65],e[66],e[67],e[68],d[69],sep=""))
    ind<- ind + 1
    row<- row +2  
  }
  swr_global  <-ifelse(swr_global == -999, NA, swr_global)
  swr_direct  <-ifelse(swr_direct == -999, NA, swr_direct)
  swr_diffuse <-ifelse(swr_diffuse == -999, NA, swr_diffuse)
  lwr_down    <-ifelse(lwr_down == -999, NA, lwr_down)
  temp        <-ifelse(temp == -999, NA, temp)
  relhum      <-ifelse(relhum == -999, NA, relhum)
  hour.of.day <-min/60

  daytime  <-list(day=day,hour=hour.of.day)

# Full list of met for future.  
#  sfc_met  <-list(swr_global=swr_global, swr_direct=swr_direct, swr_diffuse=swr_diffuse, 
#                  lwr_down=lwr_down, temp=temp, relhum=relhum)  
  sfc_met  <-list(swr_global=swr_global)  
  return(list(daytime=daytime,sfc_met=sfc_met))

 }
#####--------------------------	  END OF FUNCTION BSRN_OBSERVATIONS     ------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: BSRN_GET_AVG             ------------------------####
#
# Input:
#
# Output: 
#

 bsrn_get_avg <-function(datetime, obs_meta, obs_time, sfc_met, window=4) {

  # Commented out for debugging
  obs_meta<-obs$meta
  obs_time<-obs$ob_time
  sfc_met<-obs$sfc_met

  model_month_date <-as.numeric(datetime$dc) + as.numeric(datetime$hc)/24 +
                     as.numeric(datetime$minc)/(24*60) + as.numeric(datetime$minc)/(24*60*60)

  swr_avg    <-array(NA,c(obs_meta$ns))
  good_sites <- 0
  bad_sites  <- 0
  for(s in 1:obs_meta$ns) {
    
    month_date   <- obs_time[,1,s]+(obs_time[,2,s]/24)
    month_sum_na <- sum(is.na(month_date))
    month_sum    <- sum(!is.na(month_date))
    month_nt     <-length(month_date)
    if(month_sum_na == month_nt) {
     writeLines(paste("No data for site. Skipping:",obs_meta$site[s],bad_sites+1))
     bad_sites<- bad_sites+1
     next;
    }
    else {
     writeLines(paste("Obs are valid. Will grab the data for correct time.",
                       obs_meta$site[s],datetime$modeldate, datetime$modeltime,good_sites+1))
     ind.center  <-which.min(abs(month_date - model_month_date))
     start       <-ind.center-window
     end         <-ind.center+window
     if(length(start) == 0 )  { next }
     if(end >= month_nt-window ) {
       start       <-month_nt-(window*2)
       end         <-month_nt
     }
     if(start <= 1 ) {
       start       <- 1
       end         <- window*2
     }
     all.na.check<- sum(is.na(sfc_met[ start:end,1,s]))
     if(all.na.check == (end-start+1)){
       next
     }
     swr_avg[s]  <- round(mean(sfc_met[ start:end,1,s],na.rm=T))
     good_sites<-good_sites+1
    }
  }

  return(swr_avg)

 }
#####--------------------------	  END OF FUNCTION BSRN_GET_AVG          ------------------------------####
##########################################################################################################

##########################################################################################################
#####------------------          START OF FUNCTION: ADJUST_LEVELS             ------------------------####
#
# Input:
#
# Output: 
#

 adjust_levels <-function(in.array) in.array * scale.fac 

#####---------------------      END OF FUNCTION ADJUST_LEVELS           ------------------------------####
##########################################################################################################

##########################################################################################################
#####------------------    START OF FUNCTION: CHECK_FOR_BSRN_FILE             ------------------------####
#
# Input:
#
# Output: 
#

 check_for_bsrn_read <-function(datetime) {

  read_new_bsrn_file <- FALSE
  
  if( as.numeric(datetime$dc) == 1 & as.numeric(datetime$hc) == 0 ) {
    read_new_bsrn_file <- TRUE
  }

  return(read_new_bsrn_file)

 }
#####-------------------  END OF FUNCTION CHECK_FOR_BSRN_FILE           ------------------------------####
##########################################################################################################

##########################################################################################################

    ###################################################################
    # MADIS Cacluation for Mixing ratio Not used, but preserved here in case of need later
    # SUB CALL --- > OB= M_WMR(PTMP(I)/100.,OBTMP(I,1)-273.15)/1000.
    #T     <-sdewp
    #P     <-spres*10
    #EPS   <-0.62197
    #ES0   <-6.1078
    #X     <- 0.02*(T-12.5+7500./P)
    #WFW   <- 1.+ 4.5E-06*P + 1.4E-03*X*X
    #T     <- T-273.15
    #POL   <- 0.99999683          + T*(-0.90826951E-02 +  T*(0.78736169E-04   + T*(-0.61117958E-06 +
    #         T*(0.43884187E-08   + T*(-0.29883885E-10 +  T*(0.21874425E-12   + T*(-0.17892321E-14 +
    #         T*(0.11112018E-16   + T*(-0.30994571E-19)))))))))
    #ESW   <- ES0/POL**8
    #FMESW <- WFW * ESW
    #R     <- EPS*FMESW/(P-FMESW)
    ###################################################################

