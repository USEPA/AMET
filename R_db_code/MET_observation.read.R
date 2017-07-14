#######################################################################################################
#####################################################################################################
#                                                                 ################################
#     AMET Read Observations Functions Library                    ###############################
#                                                                 ###############################
#       Version 1.3                                               ###############################
#       Date: April 18, 2017                                      ###############################
#       Contributors:Robert Gilliam                               ###############################
#                                                                 ###############################
#     Developed by the US Environmental Protection Agency         ###############################
#                                                                 ################################
#####################################################################################################
#######################################################################################################
#
#  V1.3, 2017Apr18, Robert Gilliam: Initial Development
#
#######################################################################################################
#######################################################################################################
#     This script contains the following functions
#
#     madis_surface    --> Takes MADIS directory, date/time information and model projection
#                          then opens MADIS files and extracts site information and their observations.
#                          Wind direction is adjusted to match the projection. A standard AMET
#                          observation list is returned. See function for list details.
#
#     text_surface     --> Text observation option instead of MADIS surface NetCDF file. See function
#                          for input text file details. The same standard AMET surface obs list is
#                          returned as MADIS option.
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
    download.file(remote_file,gzname,"wget")
    system(paste("gunzip",gzname))
    system(paste("mv",nogzname,madis_file))
  }  

  if(!file.exists(madis_file)) { 
    writeLines(paste("MADIS FILE *NOT* Found: ",madis_file," for time:",datetime$modeldate,datetime$modeltime))
    writeLines("Skipping to next time")
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
    } else if (madis_dset == "maritime") {
        report_type  <- array("MARITIME",c(length(site)))
        site_locname <- array("NULL",c(length(site)))
        altm         <- ncvar_get(f2, varid="seaLevelPress")/100
    } else if (madis_dset == "metar") {
        site_locname <- ncvar_get(f2, varid="locationName")
        report_type  <- ncvar_get(f2, varid="reportType")
        altm         <- ncvar_get(f2, varid="altimeter")/100
    } else if (madis_dset == "mesonet") {
        report_type  <- array("MESONET",c(length(site)))
        site_locname <- ncvar_get(f2, varid="homeWFO")
        report_type  <- ncvar_get(f2, varid="dataProvider")
        altm         <- ncvar_get(f2, varid="altimeter")/100
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
    
    # 2-m Temperature
    stemp <- ncvar_get(f2, varid="temperature")
    stemp <-ifelse(stemp > 400,NA, stemp)

    # 2-m Mixing Ratio
    sdewp <- ncvar_get(f2, varid="dewpoint")
    
    # Compute Mixing ratio from dewpoint and station pressure.
    e     <- 0.611 * exp ( (2.501E6/461.5) * ( (1/273.14) -(1/sdewp) ) )
    smixr1 <- 0.62197 * (e/(spres-e))
    smixr2 <- 0.62197 * (e/(stationpres-e))
    smixr <-ifelse(smixr2 <   0.000001,NA, smixr2)

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
    su10  <-(-1)*swspd*sin(swdir*pi/180)
    sv10  <-(-1)*swspd*cos(swdir*pi/180) 
    
  nc_close(f2) # Close MADIS obs file

  sites_unique <-unique(site)
  nsr          <-length(sites_unique)

  site   <-list(ns=ns,nsr=nsr,site=site,sites_unique=sites_unique,slat=slat,slon=slon,site_locname=site_locname,
                report_type=report_type,ihour=ihour,imin=imin,isec=isec,
                stime=stime,stime2=stime2)
  sfc_met<-list(t2=stemp,q2=smixr,u10=su10,v10=sv10)

  return(list(meta=site,sfc_met=sfc_met))

 }
#####----------------------	  END OF FUNCTION: MADIS_SURFACE     ---------------------------------####
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

