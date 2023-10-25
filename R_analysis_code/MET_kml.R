#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#                AMET (Atmospheric Model Evaluation Tool)               #
#                                                                       #
#                Google Earth KML Generation for MET Obs                #
#                            MET_kml.R                                  #
#                                                                       #
#         Developed by the US Environmental Protection Agency           #
#-----------------------------------------------------------------------#
#########################################################################
# Change LOG
#  Initial Version, Apr 19, 2023, Robert Gilliam                            
#
#############################################################################################################
  options(warn=-1)
#############################################################################################################
#	Load required modules
  if(!require(date))   {stop("Required Package date was not loaded")}
  if(!require(RMySQL)) {stop("Required Package RMySQL was not loaded")}
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#    Initialize AMET Directory Structure Via Env. Vars
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


 # Added variable for KML file creation for AQ or MET sites
 ametmode         <- Sys.getenv("AMET_MODE")
 if(ametmode=="")                               { ametmode <- "MET"                  }

 ## Check for Static file setting and set to empty if missing. Backward compat.
 ## & print input files for user notification 
 if(ametRstatic=="")                            { ametRstatic <- "./"               }
 writeLines(paste("AMET R Config input file:",ametRinput))
 writeLines(paste("AMET R Static input file:",ametRstatic))

 ## source some configuration files, AMET libs, and input
 source (paste(ametR,"/MET_amet.misc-lib.R",sep=""))
 source (paste(ametR,"/MET_amet.plot-lib.R",sep=""))
 source (mysqlloginconfig)
 source (ametRinput)
 try(source (ametRstatic),silent=T)

 if(!exists("project") )                         { project <- Sys.getenv("AMET_PROJECT")	}


 ametdbase      <- Sys.getenv("AMET_DATABASE")
 mysqlserver    <- Sys.getenv("MYSQL_SERVER")
 mysql          <-list(server=mysqlserver,dbase=ametdbase,login=amet_login,
                        passwd=amet_pass,maxrec=maxrec)

 # Site data count below which site is skipped at statistics set to NA
 # Logic added for backward compatibility where thresh is ENV setting
 # Or directly specified in ametRinput like in AMET GUI
 dates <- mdy.date(month = ms, day = ds, year = ys)
 datee <- mdy.date(month = me, day = de, year = ye)+1
 dateep<- mdy.date(month = me, day = de, year = ye)
############################################################################
  nd       <-c(31,leapy(ys),31,30,31,30,31,31,30,31,30,31)
  d1       <-date.mdy(dates)
  d2       <-date.mdy(datee)
  d2p      <-date.mdy(dateep)

  d1p      <-paste(d1$year,dform(d1$month),dform(d1$day),sep="")
  d2p      <-paste(d2p$year,dform(d2p$month),dform(d2p$day),sep="")
  d1q      <-paste(d1$year,"-",dform(d1$month),"-",dform(d1$day),sep="")
  d2q      <-paste(d2$year,"-",dform(d2$month),"-",dform(d2$day),sep="")
  datex    <-datee       


  ametmode<-"MET"
  sfctable       <-paste(project,"_surface",sep="")

  datestrmet <-paste(">= '",d1q,"' AND d.ob_date < '",d2q,"'",sep="")
  qstat      <-paste("SELECT  DISTINCT s.stat_id, s.lat, s.lon, s.elev, s.ob_network, ",
                     "s.common_name, s.landuse, s.landuse, s.state, s.country, ",
                     "s.landuse, s.landuse, s.landuse, s.landuse FROM ", 
                     sfctable," d, stations s WHERE", 
                     "d.stat_id=s.stat_id AND d.ob_date ",datestrmet," ORDER BY s.stat_id ")

  statdat<-ametQuery(qstat,mysql)
  uid    <-unique(statdat[,1])
  ns     <-length(uid)

#  ID	LAT	LON	ELEV	NET	NAME	CITY	COUNTY	STATE	COUNTRY	   AQSITENUM	LANDUSE      LOCDESC     GMTOFFSET
  
  lat    <- array(NA,c(ns))
  lon    <- lat
  elev   <- lat
  obnet  <- lat
  commn  <- lat

  city   <- lat
  county <- lat
  state  <- lat
  country<- lat

  aqsnum <- lat
  landuse<- lat
  locdesc<- lat
  gmtoff <- lat

  for (s in 1:ns ) {
    ind        <-which(uid[s] == statdat[,1])[1]
    lat[s]     <- statdat[ind,2]
    lon[s]     <- statdat[ind,3]
    elev[s]    <- statdat[ind,4]
    obnet[s]   <- statdat[ind,5]
    commn[s]   <- statdat[ind,6]

    city[s]    <- statdat[ind,7]
    county[s]  <- statdat[ind,8]
    state[s]   <- statdat[ind,9]
    country[s] <- statdat[ind,10]

    aqsnum[s]  <- statdat[ind,11]
    landuse[s] <- statdat[ind,12]
    locdesc[s] <- statdat[ind,13]
    gmtoff[s]  <- statdat[ind,14]

  }

  # AQ Rules for Masking NULLs, Missing data, etc
  city      <- ifelse(city == "-999", NA, city)
  city      <- ifelse(city == "NULL", NA, city)
  county    <- ifelse(county == "NULL", NA, county)
  country   <- ifelse(country == "NULL", NA, country)
  landuse   <- ifelse(landuse == "NULL", NA, landuse)
  landuse   <- ifelse(landuse == "Unknown", NA, landuse)
  landuse   <- ifelse(landuse == "-999", NA, landuse)
  locdesc   <- ifelse(locdesc == "-999", NA, locdesc)
  locdesc   <- ifelse(locdesc == "NULL", NA, locdesc)
  locdesc   <- ifelse(locdesc == "Unknown", NA, locdesc)

  # Create list structure for all site metadata
  statget=list(id=uid, lat=lat, lon=lon, elev=elev, obnet=obnet, commn=commn,
               city=city, county=county, state=state, country=country,
               aqsnum=aqsnum, landuse=landuse, locdesc=locdesc, gmtoff=gmtoff)

  kmloutf  <-paste(savedir,"/AMET.SITEFILE.",model,".kml",sep="")
  writeMetSiteKML(statget, fileout=kmloutf, ametmode=ametmode)

############################################################################
############################################################################
#quit(save='no')

