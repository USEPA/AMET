#######################################################################################################
#####################################################################################################
#                                                                 ################################
#       AMET Surface Radiation Model-Obs Matching Driver          
#                                                                  
#       Meteorological Models:
#            Model for Prediction Across Scales (MPAS)
#            Weather Research and Forecasting Model (WRF) 
#                                                  
#       This "R" script provides an interface to match BSRN or SURFRAD 
#       Radiation observations with either WRF or MPAS model output and
#       insert into AMET configured MySQL database. This is the control
#       script that calls R functions that read model output, observations,
#       interpolate and construct the database queries that are sent to MySQL. 
#                                                            
#       Developed by the US EPA           
#                                                                 ################################
#####################################################################################################
#
#  V1.4, 2018Sep30, Robert Gilliam: Initial Development
#
#  V1.5, 2021May, Robert Gilliam: 
#         - Added controls for MCIP compatibility. Main updates made in MET_model_read.R.
#         - MPAS limited area mesh are compatible. Interp weights are NA for sites not in the domain
#         - Added forecast cycle and forecast hour in the case of forecast model eval.
#         - Temp text query files pushed to MySQL file naming was changed by adding a random large
#           number in the name (num between 1-100000). This allows multiple threads at the same time
#           in the same project directory.
#         - Added option to use SURFRAD data directly if specified. Script and functions called are
#           more generalize to radiation datasets with use of "rad" instead of "bsrn". Script was also
#           renamed MET_matching_rad.R and matching_rad.csh
#
#  V1.6, 2023Jun, Robert Gilliam: 
#         - Added capability for Unified Forecast System (UFS) for NOAA.
#         - Fixed forecast and init UTC for forecast output of single times
#
#######################################################################################################
#######################################################################################################
  options(warn=-1)
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
  #mysqlpass <- "config_file" # for dev and debugging (uses R config file with MySQL credentials
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
  rad_dset       <- Sys.getenv("RADIATION_DSET") 
  ametproject    <- Sys.getenv("AMET_PROJECT")
  projectdesc    <- Sys.getenv("RUN_DESCRIPTION")
  window         <- as.numeric(Sys.getenv("OBS_AVG_WINDOW_MIN"))
  skipind        <- Sys.getenv("SKIPIND")
  interp         <- Sys.getenv("INTERP_METHOD")
  updateSiteTable<-as.logical(Sys.getenv("UPDATE_SITES"))
  total_loop_max <- as.numeric(Sys.getenv("MAX_TIMES_SITE_CHECK"))
  autoftp        <-as.logical(Sys.getenv("AUTOFTP"))
  rad_server     <- Sys.getenv("RAD_SERVER")
  rad_login      <- Sys.getenv("RAD_LOGIN")
  rad_pass       <- Sys.getenv("RAD_PASS")
  verbose        <- as.logical(Sys.getenv("VERBOSE"))

  userid         <-system("echo $USER",intern = TRUE)
  projectdate    <-as.POSIXlt(Sys.time(), "GMT")

  # MySQL connection information and command to send temporary query file to database.
  # This method is dramatically quicker than sending single queries for each of the
  # thousands of sites in the site loop. 
  # mysql server details below has two options with the first commented out. 1) Plain text
  # file with password (not secure) and 2) The default, via csh script and password argument.
  # For option 1, the file is $AMETBASE/configure/amet-config.R 
  query_file1<-paste("tmp.bsrn.query.",sample(1:100000,1),sep="")
  query_file2<-paste("tmp.site.query.",sample(1:100000,1),sep="")

  mysql          <-list(server=mysqlserver,dbase=ametdbase,login=mysqllogin,passwd=mysqlpass,maxrec=5E6)
  command        <-paste("mysql --host=",mysql$server," --user=",mysql$login," --password='",
                          mysql$passwd,"' --database=",mysql$dbase," < ",query_file1,sep="")
  sitecommand    <-paste("mysql --host=",mysql$server," --user=",mysql$login," --password='",
                          mysql$passwd,"' --database=",mysql$dbase," < ",query_file2,sep="")

  files <-system(paste("ls -Llh ",met_output,"*",sep=''),intern=T)
  nf    <-length(files)

  # Hard coded settings now
  buffer           <- 5
  total_loop_count <- 1 
 
  # Skip index setting for first file (1) and all after (2)
  a<-strsplit(skipind,split=" ")
  skipind1 <-as.numeric(unlist(a)[1])
  skipind2 <-as.numeric(unlist(a)[2])
  
  # Forecast model output? Initialize related vars
  fcast <- as.logical(Sys.getenv('FORECAST'))
  if (is.na(fcast) || !fcast) {
     fcast    <- F
     init_utc <- -99
     fcast_hr <- -99
     dthr     <- 0
  }

  # Site mapping to model grid arrays for MPAS or WRF. Note CIND and CWGT are MPAS index
  # arrays and interp weighting values. WRFIND is the eqivalent for WRF. Values [site,1:3,1:2]
  # are indicies of the four grid point surrounding the obs site. [site,1,1:2] is the first and
  # second I index. [site,2,1:2] is the first and second J index. The third [site,3,1:2] is
  # DX and DY (in fractional grid form) of the obs site with respect to the grid point to the 
  # south and west. These are computed in site mapping to keep from repetative logic and calculations. 
  sitenum <-as.integer(0)
  sitemax <-as.integer(500)
  sitelist<-array(NA,c(sitemax))
  cind    <-array(NA,c(sitemax,3))
  cwgt    <-array(NA,c(sitemax,3))
  wrfind  <-array(NA,c(sitemax,3,2))

##########################################################################
# Begin loop over Model Output files
for(f in 1:nf) {

  # Initialize radiation file read to T
  read_new_rad_file <- TRUE

  # Model output file names from list spec and met model check.
  parts<-unlist(strsplit(files[f], " "))
  file <-parts[length(parts)]
  f1  <-nc_open(file)
   wrf.chk  <- ncatt_get(f1, varid=0, attname="TITLE" )$value
   mpas.chk <- ncatt_get(f1, varid=0, attname="model_name" )$value
   mcip.chk <- ncatt_get(f1, varid=0, attname="EXEC_ID" )$value
   ufs.chk  <- ncatt_get(f1, varid=0, attname="source" )$value
  nc_close(f1)
  if(mpas.chk != 0) {
   metmodel<-"mpas"
   writeLines(paste("Matching MPAS output file with surface observations:",file))
  } else if(wrf.chk != 0) {
   metmodel<-"wrf"
   writeLines(paste("Matching WRF output file with surface observations:",file))
  } else if(mcip.chk != 0) {
   metmodel<-"mcip"
   writeLines(paste("Matching MCIP METCRO2D file with surface observations:",file))
  } else if(ufs.chk != 0) {
   metmodel<-"ufs"
   writeLines(paste("Matching NOAA UFS output with surface observations:",file))
  } else { 
   writeLines("The model output is not standard WRF, MPAS, UFS output OR MCIP. Double check. 
               Terminating model-observation matching.")
   quit(save="no")
  }

  # Check to see if Database exist. If not generate and add stations and project_log tables
  # Then update AMET database project table and add new project if not existing
  if(f == 1){
    qout<-new_dbase_tables(mysql)
    qout<-new_surface_met_table(mysql, ametproject, metmodel, userid, projectdesc, projectdate)
  }

  # MPAS Grid and Sfc Met extraction shortwave radiation at surface
  #list includes: 
  #projection <-list(mproj=0,lat=lat,lon=lon,latv=latv,lonv=lonv,cells_on_vertex=cells_on_vertex,conef=cone)
  #sfc_met    <-list(time=time,t2=t2,q2=q2,u10=u10,v10=v10,swr=swr)
  if(metmodel == "mpas"){
    model<-mpas_surface(file)
  }

  # WRF Grid and Sfc Met extraction including shortwave radiation at surface
  #list includes:
  #projection <-list(mproj=mproj,lat=lat,lon=lon,lat1=lat1,lon1=lon1,nx=nx,ny=ny,
  #                  dx=dx,truelat1=truelat1,truelat2=truelat2,standlon=standlon,conef=cone)
  #sfc_met    <-list(time=time,t2=t2,q2=q2,u10=u10,v10=v10,swr=swr)
  if(metmodel == "wrf"){
    model<-wrf_surface(file)
  }

  # MCIP Grid and Sfc Met extraction
  #list includes:
  #projection <-list(mproj=mproj,lat=lat,lon=lon,lat1=lat1,lon1=lon1,nx=nx,ny=ny,
  #                  dx=dx,truelat1=truelat1,truelat2=truelat2,standlon=standlon,conef=cone)
  #sfc_met    <-list(time=time,t2=t2,q2=q2,u10=u10,v10=v10,swr=swr,psf=psf)
  if(metmodel == "mcip"){
    model<-mcip_surface(file)
  }

  # UFS Grid Info & Sfc Met extraction
  #list includes:
  #projection <-list(mproj=mproj,lat=lat,lon=lon,lat1=lat1,lon1=lon1,nx=nx,ny=ny,
  #                  dx=dx,truelat1=truelat1,truelat2=truelat2,standlon=standlon,conef=cone)
  #sfc_met    <-list(time=time,t2=t2,q2=q2,u10=u10,v10=v10,swr=swr,psf=psf)
  # set interpolation to nearest neighbor for UFS because of simple slow site mapping
  if(metmodel == "ufs"){
    model  <-ufs_surface(file)
    interp <-1
  }

  # If forecast run, use date/time function to get init time and output interval
  if (fcast & f==1) {
    init_utc  <- model_time_format(model$sfc_met$time[1])$hc
    dthr      <- as.numeric(model_time_format(model$sfc_met$time[2])$hc) -
                 as.numeric(model_time_format(model$sfc_met$time[1])$hc)
    fcast_hr0 <- as.numeric(model_time_format(model$sfc_met$time[1])$hc)
    fcast_hr  <- 0
    if(is.na(dthr)) {
      dthr   <- 1
    }
  }
  if (fcast & f==2) {
    dthr      <- as.numeric(model_time_format(model$sfc_met$time[1])$hc) - fcast_hr0
  }
##########################################################################
# begin loop for hours in Model file (reads one RAD file)
if(f == 1) { skipind <- skipind1 }
if(f > 1)  { skipind <- skipind2 }
nt  <-length(model$sfc_met$time)
if(skipind > nt) { next }

for(t in skipind:nt){

  # Check time for missing or zero data and skip. This ensures initial times
  # in model output that are often zero do not get compared with obs.
  if(metmodel == "mpas"){
    if(sum( model$sfc_met$swr[,t]) == 0) {
      writeLines(paste("MPAS time period skipped because initial model time"))
      next 
    }
  }
  if(metmodel == "wrf" || metmodel == "mcip" || metmodel == "ufs"){
    if(sum( model$sfc_met$swr[,,t]) == 0){ 
      writeLines(paste("WRF time period skipped because initial model time"))
      next 
    }
  }

  # Time component extraction from WRF or MPAS Time variable
  # return variable contains one list variable 
  # modeldate, modeltime, yc, mc, dc, hc
  datetime<- model_time_format(model$sfc_met$time[t])

  # Compute forecast hour if applicable
  if (fcast & total_loop_count > 1) {
    fcast_hr <- fcast_hr + dthr
  }

  # Check for first time of the month to judge if new RAD file
  # needs to be ingested. BSRN = first of month, 
  # SRAD= first hour of the day read_new_rad_file
  if(total_loop_count > 1 ) {
    read_new_rad_file <-check_for_rad_read(datetime, t, skipind, rad_dset)
  }

  # Extract obs from BSRN or SURFRAD obs files along with site metadata
  # return variable contains two lists: site and sfc_met
  # site:    ns, nsr, site, site_unique, slat ,slon, site_locname, report_type, 
  #          ihour, imin, isec, stime, stime2
  # sfc_met: t2, q2, u10, v10 
  if(rad_dset == "bsrn" & read_new_rad_file) {
    obs<- bsrn_observations(madisbase, datetime, model$projection$lat, model$projection$lon,  
                            ametdbase, sitecommand, rad_server,                            
                            rad_login, rad_pass, autoftp, updateSiteTable, tmpquery_file=query_file2)
    read_new_rad_file <- FALSE
    if(is.na(obs[1])) { next }
  } 
  if(rad_dset == "srad" & read_new_rad_file) {
    obs<- surfrad_observations(madisbase, datetime, model$projection$lat, model$projection$lon,  
                               ametdbase, sitecommand, rad_server,                            
                               rad_login, rad_pass, autoftp, updateSiteTable, tmpquery_file=query_file2)
    read_new_rad_file <- FALSE
  } else if(rad_dset == "text") {
    writeLines("Text radiation option is not functional yet. Only options that work are bsrn and srad")
    writeLines("Change setenv RADIATION_DSET srad or bsrn in matching_bsrn.csh")
    quit(save="no")
  }

  swr_obs_avg <- get_rad_avg(datetime, obs$meta, obs$ob_time, obs$sfc_met, window)
  
  # Site mapping. This is not as important for speed since there are such few sites, but preserved
  # noththeless. I will help to some degree with MPAS global data.
  if(metmodel == "mpas" & total_loop_count <= total_loop_max){
    site_update <- mpas_site_map(obs$meta$site, obs$meta$sites_unique, sitelist, sitenum, obs$meta$slat, 
                                 obs$meta$slon, obs$meta$elev, obs$meta$report_type, obs$meta$site_locname,
                                 model$projection$lat, model$projection$lon, model$projection$latv, 
                                 model$projection$lonv, model$projection$cells_on_vertex,
                                 cind, cwgt,  mysql$dbase, sitecommand, sitemax, updateSiteTable=F,
                                 tmpquery_file=query_file2)
    sitenum <-site_update$sitenum
    sitelist<-site_update$sitelist
    cind    <-site_update$cind
    cwgt    <-site_update$cwgt
  }
  if((metmodel == "wrf" || metmodel == "mcip" || metmodel == "ufs") & total_loop_count <= total_loop_max){
    site_update <- wrf_site_map(obs$meta$site, obs$meta$sites_unique, sitelist, sitenum, obs$meta$slat, 
                                obs$meta$slon, obs$meta$elev, obs$meta$report_type, obs$meta$site_locname, 
                                model$projection, wrfind, interp, mysql$dbase, sitecommand, sitemax, 
                                updateSiteTable=F, buffer=buffer, tmpquery_file=query_file2)
    sitenum <-site_update$sitenum
    sitelist<-site_update$sitelist
    wrfind  <-site_update$wrfind
  }

writeLines("**********************************************************************************************")
# Open new query file
system(paste("rm -f ",query_file2)) 
system(paste("rm -f ",query_file1)) 
sfile<-file(query_file1,"a")
writeLines(paste("use",mysql$dbase,";"),con=sfile) 
##########################################################################
  # Main Loop over observation sites for a defined date/time of model output
  for(s in 1:sitenum){   

    sind  <-which(sitelist[s] == obs$meta$site)
    mysqltimestr<-paste(datetime$yc,"-",datetime$mc,"-",datetime$dc," ",datetime$modeltime,sep="") 
    if(verbose) {
      writeLines(paste("Site",s,"of",sitenum,"unique sites -",obs$meta$site[sind],datetime$modeldate,
                       "Model time:",datetime$modeltime," init/forecast hr:",init_utc,"/",fcast_hr))
    }

    # Set missing or bad obs values to MySQL NULL
    swr_obs_avgn <- as.numeric(swr_obs_avg[sind])
    if(is.na(swr_obs_avgn) || is.nan(swr_obs_avgn))  { swr_obs_avgn  <-"NULL" }

    # Calculate model values base on barycentric interpolation if MPAS
    if(metmodel == "mpas"){
      if(is.na(cwgt[s,1])) { next }
      swr_int   <-cwgt[s,1]*model$sfc_met$swr[cind[s,1],t]+cwgt[s,2]*model$sfc_met$swr[cind[s,2],t]+
                  cwgt[s,3]*model$sfc_met$swr[cind[s,3],t]
    }
    if(metmodel == "wrf" || metmodel == "mcip" || metmodel == "ufs"){
      # Compute model values from the site-mapped grid idicies. This is a bilinear interpolation
      # calculation using the four grid points surrounding observation site. It is written to
      # work with nearest neighbor where fractional grid index in x and y direction (wrfind[s,3,1:2])
      # are set to zero in the site mapping routine.
      swr_int<-(model$sfc_met$swr[wrfind[s,1,1],wrfind[s,2,1],t] + ( wrfind[s,3,1] * 
               (model$sfc_met$swr[wrfind[s,1,2],wrfind[s,2,1],t] - model$sfc_met$swr[wrfind[s,1,1],wrfind[s,2,1],t]) )) +
               (wrfind[s,3,2] * (model$sfc_met$swr[wrfind[s,1,1],wrfind[s,2,2],t] + ( wrfind[s,3,1] * 
               (model$sfc_met$swr[wrfind[s,1,2],wrfind[s,2,2],t] - model$sfc_met$swr[wrfind[s,1,1],wrfind[s,2,2],t]) ) -
               (model$sfc_met$swr[wrfind[s,1,1],wrfind[s,2,1],t] + ( wrfind[s,3,1] * 
               (model$sfc_met$swr[wrfind[s,1,2],wrfind[s,2,1],t] - model$sfc_met$swr[wrfind[s,1,1],wrfind[s,2,1],t]) )) ))
    }

    q1    <-paste("REPLACE INTO ",ametproject,"_surface (proj_code, stat_id, ob_date, 
                  ob_time, fcast_hr, init_utc, SRAD_ob,  SRAD_mod)",sep="")
    q2    <-paste("('",ametproject,"','",obs$meta$site[sind],"','",mysqltimestr,"','",
                  datetime$modeltime,"',",fcast_hr,",",init_utc,",",swr_obs_avgn,",",round(swr_int),")",sep="")

    query <-paste(q1,"VALUES",q2)
    writeLines(paste(query,";"),con=sfile)
  }
  close(sfile)
  system(command)
  system(paste("rm -f ",query_file1)) 
  system(paste("rm -f ",query_file2)) 
  # End of loop over observations sites
  ##########################################################################
  writeLines("**********************************************************************************************")
  total_loop_count <- total_loop_count + 1
} 
  # End of loop over times
##########################################################################

##########################################################################
}  # End of loop over files
quit(save="no")

