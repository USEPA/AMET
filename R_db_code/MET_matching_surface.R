#######################################################################################################
#####################################################################################################
#                                                                 ################################
#       AMET (Atmospheric Model Evaluation Tool) Version 1.3            
#                                                                  
#       Meteorological Models:
#            Model for Prediction Across Scales (MPAS)
#            Weather Research and Forecasting Model (WRF) 
#                                                  
#       This "R" script provides an interface to match MADIS
#       observations with either WRF or MPAS model output and
#       insert into AMET configured MySQL database. This specific
#       script is the master that calls R functions that read
#       model output, MADIS observations, interpolate, 
#       and construct the database queries.   
#                                                            
#       Version:        1.3                                         
#       Date:           April 28, 2017                     
#       Contributors:   Robert Gilliam, Russ Bullock 
#                                                     
#       Developed by the US EPA           
#                                                                 ################################
#####################################################################################################
#######################################################################################################
  if(!require(RMySQL)) {stop("Required Package RMySQL was not loaded") }
  if(!require(date))   {stop("Required Package date was not loaded")   }
  if(!require(ncdf4))  {stop("Required Package ncdf4 was not loaded")  }

  config_file     <- Sys.getenv("MYSQL_CONFIG")   # MySQL configuration file
  if (!exists("config_file")) {
     stop("Must set MYSQL_CONFIG environment variable")
  }
  source(config_file)

  amet_base <- Sys.getenv('AMETBASE')
  if (!exists("amet_base")) {
     stop("Must set AMETBASE environment variable")
  }

  ametdbase <-Sys.getenv('AMET_DATABASE')
  if (!exists("ametdbase")) {
     stop("Must set AMET_DATABASE environment variable")
  }

  mysqllogin <-Sys.getenv('MYSQL_LOGIN')
  if (!exists("mysqllogin")) {
     stop("Must set MYSQL_LOGIN environment variable")
  }

  # Get Login and Password from R command arguments
  args              <- commandArgs(1)
  mysqlpass         <- args[1]

  ### Use MySQL login/password from config file if requested ###
  if (mysqlpass == 'config_file')  { mysqlpass  <- amet_pass  }
  ##############################################################

  # Initialize AMET Directory Structure Via Env. Vars
  # AND Load required function and configuration files
  source(paste(amet_base,"/R_db_code/MET_model.read.R",sep="")) 
  source(paste(amet_base,"/R_db_code/MET_observation.read.R",sep="")) 
  source(paste(amet_base,"/R_db_code/MET_site.mapping.R",sep="")) 
  source(paste(amet_base,"/R_db_code/MET_dbase.R",sep=""))
  source(paste(amet_base,"/R_db_code/MET_misc.R",sep=""))

# Users can pass login and password via environmental variables if not concerned about security.

  madisbase      <- Sys.getenv("MADISBASE")  
  mysqlserver    <- Sys.getenv("MYSQL_SERVER")
  met_output     <- Sys.getenv("METOUTPUT") 
  madis_dset     <- Sys.getenv("MADISDSET") 
  ametproject    <- Sys.getenv("AMET_PROJECT")
  projectdesc    <- Sys.getenv("RUN_DESCRIPTION")
  maxdtmin       <- as.numeric(Sys.getenv("MAXDTMIN"))
  skipind        <- Sys.getenv("SKIPIND")
  interp         <- Sys.getenv("INTERP_METHOD")
  updateSiteTable<-as.logical(Sys.getenv("UPDATE_SITES"))
  autoftp        <-as.logical(Sys.getenv("AUTOFTP"))
  madis_server   <- Sys.getenv("MADIS_SERVER")
  verbose        <- as.logical(Sys.getenv("VERBOSE"))

  userid         <-system("echo $USER",intern = TRUE)
  projectdate    <-as.POSIXlt(Sys.time(), "GMT")

  # MySQL connection information and command to send temporary query file to database.
  # This method is dramatically quicker than sending single queries for each of the
  # thousands of sites in the site loop. 
  # mysql server details below has two options with the first commented out. 1) Plain text
  # file with password (not secure) and 2) The default, via csh script and password argument.
  # For option 1, the file is $AMETBASE/configure/amet-config.R 
  mysql          <-list(server=mysqlserver,dbase=ametdbase,login=mysqllogin,passwd=mysqlpass,maxrec=5E6)
  command        <-paste("mysql --host=",mysql$server," --user=",mysql$login," --password='",
                          mysql$passwd,"' --database=",mysql$dbase," < tmp.query",sep="")
  sitecommand    <-paste("mysql --host=",mysql$server," --user=",mysql$login," --password='",
                          mysql$passwd,"' --database=",mysql$dbase," < tmp.site.query",sep="")
  dateO <-mdy.date(month = 1, day = 01, year = 1970)
  files <-system(paste("ls -lh ",met_output,"*",sep=''),intern=T)
  nf    <-length(files)

  # Hard coded settings now
  buffer  <- 5
  
  # Skip index setting for first file (1) and all after (2)
  a<-strsplit(skipind,split=" ")
  skipind1 <-as.numeric(unlist(a)[1])
  skipind2 <-as.numeric(unlist(a)[2])
  
  # Site mapping to model grid arrays for MPAS or WRF. Note CIND and CWGT are MPAS index
  # arrays and interp weighting values. WRFIND is the eqivalent for WRF. Values [site,1:3,1:2]
  # are indicies of the four grid point surrounding the obs site. [site,1,1:2] is the first and
  # second I index. [site,2,1:2] is the first and second J index. The third [site,3,1:2] is
  # DX and DY (in fractional grid form) of the obs site with respect to the grid point to the 
  # south and west. These are computed in site mapping to keep from repetative logic and calculations. 
  sitenum <-as.integer(0)
  sitemax <-as.integer(45000)
  sitelist<-array(NA,c(sitemax))
  cind    <-array(NA,c(sitemax,3))
  cwgt    <-array(NA,c(sitemax,3))
  wrfind  <-array(NA,c(sitemax,3,2))

##########################################################################
# Begin loop over Model Output files
for(f in 1:nf) {

  # Model output file name from list spec and meteorological model
  parts<-unlist(strsplit(files[f], " "))
  file <-parts[length(parts)]
  f1  <-nc_open(file)
   head    <- ncatt_get(f1, varid=0, attname="TITLE" )$value
   metmodel<- ncatt_get(f1, varid=0, attname="model_name" )$value
  nc_close(f1)
  if(metmodel == "mpas") {
   metmodel<-"mpas"
   writeLines(paste("Matching MPAS output file with observations:",file))
  } else if(head != 0) {
   metmodel<-"wrf"
   writeLines(paste("Matching WRF output file with observations:",file))
  } else if(metmodel == 0 & head == 0){ 
   writeLines("The model output is not standard WRF or MPAS output. Double check. 
               Terminating model-observation matching.")
   quit(save="no")
  }

  # Check to see if Database exist. If not generate and add stations and project_log tables
  # Then update AMET database project table and add new project if not existing
  if(f == 1){
    qout<-new_dbase_tables(mysql)
    qout<-new_surface_met_table(mysql, ametproject, metmodel, userid, projectdesc, projectdate)
  }

  # MPAS Grid and Sfc Met extraction
  #list includes: 
  #projection <-list(mproj=0,lat=lat,lon=lon,latv=latv,lonv=lonv,cells_on_vertex=cells_on_vertex,conef=cone)
  #sfc_met    <-list(time=time,t2=t2,q2=q2,u10=u10,v10=v10,swr=swr)
  if(metmodel == "mpas"){
    model<-mpas_surface(file)
  }

  # WRF Grid and Sfc Met extraction
  #list includes:
  #projection <-list(mproj=mproj,lat=lat,lon=lon,lat1=lat1,lon1=lon1,nx=nx,ny=ny,
  #                  dx=dx,truelat1=truelat1,truelat2=truelat2,standlon=standlon,conef=cone)
  #sfc_met    <-list(time=time,t2=t2,q2=q2,u10=u10,v10=v10,swr=swr)
  if(metmodel == "wrf"){
    model<-wrf_surface(file)
  }

##########################################################################
# begin loop for hours in MPAS file (reads one MADIS file)
if(f == 1) { skipind <- skipind1 }
if(f > 1)  { skipind <- skipind2 }
nt  <-length(model$sfc_met$time)
if(skipind > nt) { next }

for(t in skipind:nt){

  # Check time for missing or zero data and skip. This ensures initial times
  # in model output that are often zero do not get compared with obs.
  if(metmodel == "mpas"){
    if(sum( model$sfc_met$t2[,t]) == 0) {
      writeLines(paste("MPAS time period skipped because initial model time"))
      next 
    }
  }
  if(metmodel == "wrf"){
    if(sum( model$sfc_met$t2[,,t]) == 0){ 
      writeLines(paste("WRF time period skipped because initial model time"))
      next 
    }
  }

  # Time component extraction from WRF or MPAS Time variable
  # return variable contains one list variable 
  # modeldate, modeltime, yc, mc, dc, hc
  datetime<- model_time_format(model$sfc_met$time[t])

  # Extract obs from MADIS file along with site metadata
  # return variable contains two lists: site and sfc_met
  # site:    ns, nsr, site, site_unique, slat ,slon, site_locname, report_type, 
  #          ihour, imin, isec, stime, stime2
  # sfc_met: t2, q2, u10, v10
  if(madis_dset != "text") {
    obs<- madis_surface(madisbase, madis_dset, datetime, autoftp, madis_server,
                        model$projection$standlon, model$projection$conef)
    if(is.na(obs[1])) { next }
  } else if(madis_dset == "text") {
    obs<- text_surface(madisbase, datetime, model$projection$standlon, model$projection$conef)
  }
  if(metmodel == "mpas"){
    site_update <- mpas_site_map(obs$meta$site, obs$meta$sites_unique, sitelist, sitenum, obs$meta$slat, 
                                 obs$meta$slon, obs$meta$report_type, obs$meta$site_locname,
                                 model$projection$lat, model$projection$lon, model$projection$latv, 
                                 model$projection$lonv, model$projection$cells_on_vertex,
                                 cind, cwgt,  mysql$dbase, sitecommand, sitemax, updateSiteTable)
    sitenum <-site_update$sitenum
    sitelist<-site_update$sitelist
    cind    <-site_update$cind
    cwgt    <-site_update$cwgt
  }
  if(metmodel == "wrf"){
    site_update <- wrf_site_map(obs$meta$site, obs$meta$sites_unique, sitelist, sitenum, obs$meta$slat, 
                                obs$meta$slon, obs$meta$report_type, obs$meta$site_locname, model$projection, 
                                wrfind, interp, mysql$dbase, sitecommand, sitemax, 
                                updateSiteTable, buffer=buffer)
    sitenum <-site_update$sitenum
    sitelist<-site_update$sitelist
    wrfind  <-site_update$wrfind
  }

writeLines("**********************************************************************************************")
# Open new query file
system("rm tmp.query") 
sfile<-file("tmp.query","a")
writeLines(paste("use",mysql$dbase,";"),con=sfile) 
##########################################################################
  # Main Loop over observation sites for a defined date/time of model output
  for(s in 1:sitenum){   

    # Find all obs for the unique site and determine the closest to WRF time
    all.sind  <-which(sitelist[s] == obs$meta$site)
    if(sum(all.sind,na.rm=T) == 0 ) { next }

    time        <-as.numeric(datetime$hc)
    tdiff       <-abs(obs$meta$stime[all.sind]-obs$meta$stime2[all.sind])/60
    ndiff       <-which(tdiff==min(tdiff,na.rm=T))[1]
    sind        <-all.sind[ndiff]
    nhour       <-sprintf("%02d",obs$meta$ihour[sind])
    nmin        <-sprintf("%02d",obs$meta$imin[sind])
    nsec        <-sprintf("%02d",obs$meta$isec[sind])
    actual_time <-paste(nhour,":",nmin,":",nsec,sep="")
    mysqltimestr<-paste(datetime$yc,"-",datetime$mc,"-",datetime$dc," ",datetime$modeltime,sep="") 
    # If time of site ob is outside user defined window, skip
    if(tdiff[ndiff]>maxdtmin) {
      if(verbose) {
        writeLines(paste("Site",s,"of",sitenum,"unique sites -",obs$meta$site[sind],datetime$modeldate,
                          datetime$modeltime,actual_time,"(obs time) MAXDTMIN Violation - skipped - tdiff (min):",tdiff))
      }
      next
    }
    if(verbose) {
      writeLines(paste("Site",s,"of",sitenum,"unique sites -",obs$meta$site[sind],datetime$modeldate,
                       "Model time:",datetime$modeltime,"  Obs time:",actual_time))
    }

    if(is.na(obs$sfc_met$t2[sind]))  { obs$sfc_met$t2[sind]  <-"NULL" }
    if(is.na(obs$sfc_met$q2[sind]))  { obs$sfc_met$q2[sind]  <-"NULL" }
    if(is.na(obs$sfc_met$u10[sind])) { obs$sfc_met$u10[sind] <-"NULL" }
    if(is.na(obs$sfc_met$v10[sind])) { obs$sfc_met$v10[sind] <-"NULL" }

    # Calculate model values base on barycentric interpolation if MPAS
    if(metmodel == "mpas"){
      t2_int   <-cwgt[s,1]*model$sfc_met$t2[cind[s,1],t]+cwgt[s,2]*model$sfc_met$t2[cind[s,2],t]+
                 cwgt[s,3]*model$sfc_met$t2[cind[s,3],t]
      q2_int   <-cwgt[s,1]*model$sfc_met$q2[cind[s,1],t]+cwgt[s,2]*model$sfc_met$q2[cind[s,2],t]+
                 cwgt[s,3]*model$sfc_met$q2[cind[s,3],t]
      u10_int  <-cwgt[s,1]*model$sfc_met$u10[cind[s,1],t]+cwgt[s,2]*model$sfc_met$u10[cind[s,2],t]+
                 cwgt[s,3]*model$sfc_met$u10[cind[s,3],t]
      v10_int  <-cwgt[s,1]*model$sfc_met$v10[cind[s,1],t]+cwgt[s,2]*model$sfc_met$v10[cind[s,2],t]+
                 cwgt[s,3]*model$sfc_met$v10[cind[s,3],t]
    }
    if(metmodel == "wrf"){
      # Compute model values from the site-mapped grid idicies. This is a bilinear interpolation
      # calculation using the four grid points surrounding observation site. It is written to
      # work with nearest neighbor where fractional grid index in x and y direction (wrfind[s,3,1:2])
      # are set to zero in the site mapping routine.
      t2_int<- (model$sfc_met$t2[wrfind[s,1,1],wrfind[s,2,1],t] + ( wrfind[s,3,1] * 
               (model$sfc_met$t2[wrfind[s,1,2],wrfind[s,2,1],t] - model$sfc_met$t2[wrfind[s,1,1],wrfind[s,2,1],t]) )) +
               (wrfind[s,3,2] * (model$sfc_met$t2[wrfind[s,1,1],wrfind[s,2,2],t] + ( wrfind[s,3,1] * 
               (model$sfc_met$t2[wrfind[s,1,2],wrfind[s,2,2],t] - model$sfc_met$t2[wrfind[s,1,1],wrfind[s,2,2],t]) ) -
               (model$sfc_met$t2[wrfind[s,1,1],wrfind[s,2,1],t] + ( wrfind[s,3,1] * 
               (model$sfc_met$t2[wrfind[s,1,2],wrfind[s,2,1],t] - model$sfc_met$t2[wrfind[s,1,1],wrfind[s,2,1],t]) )) ))
      q2_int<- (model$sfc_met$q2[wrfind[s,1,1],wrfind[s,2,1],t] + ( wrfind[s,3,1] * 
               (model$sfc_met$q2[wrfind[s,1,2],wrfind[s,2,1],t] - model$sfc_met$q2[wrfind[s,1,1],wrfind[s,2,1],t]) )) +
               (wrfind[s,3,2] * (model$sfc_met$q2[wrfind[s,1,1],wrfind[s,2,2],t] + ( wrfind[s,3,1] * 
               (model$sfc_met$q2[wrfind[s,1,2],wrfind[s,2,2],t] - model$sfc_met$q2[wrfind[s,1,1],wrfind[s,2,2],t]) ) -
               (model$sfc_met$q2[wrfind[s,1,1],wrfind[s,2,1],t] + ( wrfind[s,3,1] * 
               (model$sfc_met$q2[wrfind[s,1,2],wrfind[s,2,1],t] - model$sfc_met$q2[wrfind[s,1,1],wrfind[s,2,1],t]) )) ))
      u10_int<- (model$sfc_met$u10[wrfind[s,1,1],wrfind[s,2,1],t] + ( wrfind[s,3,1] * 
               (model$sfc_met$u10[wrfind[s,1,2],wrfind[s,2,1],t] - model$sfc_met$u10[wrfind[s,1,1],wrfind[s,2,1],t]) )) +
               (wrfind[s,3,2] * (model$sfc_met$u10[wrfind[s,1,1],wrfind[s,2,2],t] + ( wrfind[s,3,1] * 
               (model$sfc_met$u10[wrfind[s,1,2],wrfind[s,2,2],t] - model$sfc_met$u10[wrfind[s,1,1],wrfind[s,2,2],t]) ) -
               (model$sfc_met$u10[wrfind[s,1,1],wrfind[s,2,1],t] + ( wrfind[s,3,1] * 
               (model$sfc_met$u10[wrfind[s,1,2],wrfind[s,2,1],t] - model$sfc_met$u10[wrfind[s,1,1],wrfind[s,2,1],t]) )) ))
      v10_int<- (model$sfc_met$v10[wrfind[s,1,1],wrfind[s,2,1],t] + ( wrfind[s,3,1] * 
               (model$sfc_met$v10[wrfind[s,1,2],wrfind[s,2,1],t] - model$sfc_met$v10[wrfind[s,1,1],wrfind[s,2,1],t]) )) +
               (wrfind[s,3,2] * (model$sfc_met$v10[wrfind[s,1,1],wrfind[s,2,2],t] + ( wrfind[s,3,1] * 
               (model$sfc_met$v10[wrfind[s,1,2],wrfind[s,2,2],t] - model$sfc_met$v10[wrfind[s,1,1],wrfind[s,2,2],t]) ) -
               (model$sfc_met$v10[wrfind[s,1,1],wrfind[s,2,1],t] + ( wrfind[s,3,1] * 
               (model$sfc_met$v10[wrfind[s,1,2],wrfind[s,2,1],t] - model$sfc_met$v10[wrfind[s,1,1],wrfind[s,2,1],t]) )) ))
    }

    q1    <-paste("REPLACE INTO ",ametproject,"_surface (proj_code, stat_id, ob_date, ob_time,fcast_hr, init_utc,T_ob,  T_mod,
                   U_ob,  U_mod,  V_ob,  V_mod,  WVMR_ob, Q_ob,Q_mod)",sep="")
    q2    <-paste("('",ametproject,"','",obs$meta$site[sind],"','",mysqltimestr,"','",
                  datetime$modeltime,"',0,00,",obs$sfc_met$t2[sind],",",t2_int,",",
                  obs$sfc_met$u10[sind],",",u10_int,",",obs$sfc_met$v10[sind],",",v10_int,",",
                  obs$sfc_met$q2[sind],",",obs$sfc_met$q2[sind],",",q2_int,")",sep="")

    query <-paste(q1,"VALUES",q2)
    writeLines(paste(query,";"),con=sfile)
  }
  close(sfile)
  system(command)
  # End of loop over observations sites
  ##########################################################################
  writeLines("**********************************************************************************************")
} 
  # End of loop over times
##########################################################################

##########################################################################
}  # End of loop over files
system("rm tmp.query tmp.site.query") 
quit(save="no")

