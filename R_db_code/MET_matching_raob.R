#######################################################################################################
#####################################################################################################
#                                                                 ################################
#       AMET Upper-Air Meteorology Model-Obs Matching Driver          
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
#       This wrapper matches Rawindsone profiles (Theta, WS/WD and RH)
#       with either WRF or MPAS meteorology.   
#                                                            
#       Developed by the US EPA           
#                                                                 ################################
#####################################################################################################
#
#  V1.4, 2018Sep30, Robert Gilliam: Initial Development
#
#  V1.5, 2021Jan07, Robert Gilliam: 
#         - Added controls for MCIP compatibility. Main updates made in MET_model_read.R.
#         - MPAS limited area mesh are compatible. Interp weights are NA for sites not in the domain
#         - Added forecast cycle and forecast hour in the case of forecast model eval.
#         - Temp text query files pushed to MySQL file naming was changed by adding a random large
#           number in the name (num between 1-100000). This allows multiple threads at the same time
#           in the same project directory.
#
#######################################################################################################
#######################################################################################################
  options(warn=-1)
  if(!require(RMySQL)) {stop("Required Package RMySQL was not loaded") }
  if(!require(date))   {stop("Required Package date was not loaded")   }
  if(!require(ncdf4))  {stop("Required Package ncdf4 was not loaded")  }

  config_file     <- Sys.getenv("MYSQL_CONFIG")  
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
  #if (mysqlpass == 'config_file')  { mysqlpass  <- amet_pass  }
  ##############################################################
  mysqlpass  <- amet_pass 
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
  native         <- as.logical(Sys.getenv("NATIVE"))
  mandatory      <- as.logical(Sys.getenv("MANDATORY"))
  ametproject    <- Sys.getenv("AMET_PROJECT")
  projectdesc    <- Sys.getenv("RUN_DESCRIPTION")
  skipind        <- Sys.getenv("SKIPIND")
  updateSiteTable<-as.logical(Sys.getenv("UPDATE_SITES"))
  autoftp        <-as.logical(Sys.getenv("AUTOFTP"))
  madis_server   <- Sys.getenv("MADIS_SERVER")
  verbose        <- as.logical(Sys.getenv("VERBOSE"))

  userid         <-system("echo $USER",intern = TRUE)
  projectdate    <-as.POSIXlt(Sys.time(), "GMT")

  # Hard Coded settings that do not require user input with RAOB matching option.
  # maxdtmin is set to 60 since soundings take place over an hour. Raob is the only 
  # dataset. No need to minimize site mapping since all sites are in each file.
  # Only nearests neighbor interp is needed since balloons actually travel to adjacent
  # model grid cells; so approximation is implied.
  maxdtmin         <- 60
  madis_dset       <- "raob" 
  total_loop_max   <- 999999
  buffer           <- 5
  total_loop_count <- 1 
  interp           <- 1

  # MySQL connection information and command to send temporary query file to database.
  # This method is dramatically quicker than sending single queries for each of the
  # thousands of sites in the site loop. 
  # mysql server details below has two options with the first commented out. 1) Plain text
  # file with password (not secure) and 2) The default, via csh script and password argument.
  # For option 1, the file is $AMETBASE/configure/amet-config.R 
  query_file1<-paste("tmp.raob.query.",sample(1:100000,1),sep="")
  query_file2<-paste("tmp.site.query.",sample(1:100000,1),sep="")

  mysql          <-list(server=mysqlserver,dbase=ametdbase,login=mysqllogin,passwd=mysqlpass,maxrec=5E6)
  command        <-paste("mysql --host=",mysql$server," --user=",mysql$login," --password='",
                          mysql$passwd,"' --database=",mysql$dbase," < ",query_file1,sep="")
  sitecommand    <-paste("mysql --host=",mysql$server," --user=",mysql$login," --password='",
                          mysql$passwd,"' --database=",mysql$dbase," < ",query_file2,sep="")

  files <-system(paste("ls -Llh ",met_output,"*",sep=''),intern=T)
  nf    <-length(files)
  
  # Skip index setting for first file (1) and all after (2)
  a        <-strsplit(skipind,split=" ")
  skipind1 <-as.numeric(unlist(a)[1])
  skipind2 <-as.numeric(unlist(a)[2])
  
  # Forecast model output? Initialize related vars
  fcast <- as.logical(Sys.getenv('FORECAST'))
  if (is.na(fcast) || !fcast) {
     fcast    <- F
     init_utc <- -99
     fcast_hr <- 0
     dthr     <- 0
  }

  # Site mapping to model grid arrays for MPAS or WRF. Note CIND and CWGT are MPAS index
  # arrays and interp weighting values. WRFIND is the eqivalent for WRF. Values [site,1:3,1:2]
  # are indicies of the four grid point surrounding the obs site. [site,1,1:2] is the first and
  # second I index. [site,2,1:2] is the first and second J index. The third [site,3,1:2] is
  # DX and DY (in fractional grid form) of the obs site with respect to the grid point to the 
  # south and west. These are computed in site mapping to keep from repetative logic and calculations.
  # For RAOB matching nearest neighbor is used since balloon soundings are not static with respect to
  # the surface launch site ground location. 
  sitenum <-as.integer(0)
  sitemax <-as.integer(1000)
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
   wrf.chk  <- ncatt_get(f1, varid=0, attname="TITLE" )$value
   mpas.chk <- ncatt_get(f1, varid=0, attname="model_name" )$value
   mcip.chk <- ncatt_get(f1, varid=0, attname="EXEC_ID" )$value
  nc_close(f1)
  if(mpas.chk != 0) {
   metmodel<-"mpas"
   writeLines(paste("Matching MPAS output file with raob sounding observations:",file))
  } else if(wrf.chk != 0) {
   metmodel<-"wrf"
   writeLines(paste("Matching WRF output file with raob sounding observations:",file))
  } else if(mcip.chk != 0) {
   metmodel<-"mcip"
   writeLines(paste("Matching MCIP METCRO3D/METDOT3D file with raob sounding observations:",file))
  } else { 
   writeLines("The model output is not standard WRF or MPAS output. Double check. 
               Terminating model-observation matching.")
   quit(save="no")
  }

  # Check to see if Database exist. If not generate and add stations and project_log tables
  # Then update AMET database project table and add new project if not existing
  if(f == 1){
    qout<-new_dbase_tables(mysql)
    qout<-new_raob_met_table(mysql, ametproject, metmodel, userid, projectdesc, projectdate)
  }

  # MPAS Grid and Met extraction. List specs below show what is returned by the model read
  #list includes: 
  #projection <-list(mproj=0,lat=lat,lon=lon,latv=latv,lonv=lonv,cells_on_vertex=cells_on_vertex,conef=cone)
  #raob_met    <-list(time=time, elev=elev, sigu=sigu, sigm=sigm, u=u, v=v, theta=theta, temp=tk,
  #                    qv=qv, rh=rh, pblh=pblh, psf=psf, p=p, levzf=levzf, levzh=levzh)
  if(metmodel == "mpas"){
    model <-mpas_raob(file,t=1)
  }

  # WRF Grid and Met extraction.  List specs below show what is returned by the model read
  #list includes:
  #projection <-list(mproj=mproj,lat=lat,lon=lon,lat1=lat1,lon1=lon1,nx=nx,ny=ny,
  #                  dx=dx,truelat1=truelat1,truelat2=truelat2,standlon=standlon,conef=cone)
  #raob_met    <-list(time=time, elev=elev, sigu=sigu, sigm=sigm, u=u, v=v, theta=theta, temp=tk,
  #                    qv=qv, rh=rh, pblh=pblh, psf=psf, p=p, levzf=levzf, levzh=levzh)
  if(metmodel == "wrf"){
    model <-wrf_raob(file,t=1)
  }

  if(metmodel == "mcip"){
    model <-mcip_raob(file,t=1)
  }

  # If forecast run, use date/time function to get init time and output interval
  if (fcast) {
    init_utc <- model_time_format(model$raob_met$time)$hc
     dthr    <- as.numeric(model_time_format(model$raob_met$time[2])$hc) -
                as.numeric(model_time_format(model$raob_met$time[1])$hc)
    fcast_hr <- 0
  }

##########################################################################
# begin loop for hours in MPAS file (Model values are extracted each time increment)
if(f == 1) { skipind <- skipind1 }
if(f > 1)  { skipind <- skipind2 }
nt  <-length(model$raob_met$time)
if(skipind > nt) { next }

for(t in skipind:nt){

  # Time component extraction from WRF or MPAS Time variable
  # return variable contains one list variable 
  # modeldate, modeltime, yc, mc, dc, hc
  datetime <- model_time_format(model$raob_met$time[t])
  # Limit times to standard soundings (i.e.; 00 and 12 UTC)
  if(datetime$hc != "00" & datetime$hc != "12") { next }

  # Compute forecast hour if applicable
  if (fcast) {
    fcast_hr <- (t-1) * dthr
  }

  # Extract obs from MADIS file along with site metadata
  # return variable contains two lists: site and raob_met
  # Skip time if MADIS file is not availiable or has 0 or 1 sites.
  # site:    ns, nsr, site, site_unique, slat ,slon, site_locname, report_type, 
  #          ihour, imin, isec, stime, stime2
  #raob_met  ghgtm=ghgtm, prest=prest, presw=presw, presm=presm, tempm=temp, temps=temps, 
  #          mixrm=mixr, mixrs=mixrs, rhm=rhm, rhs=rhs, um=um, vm=vm, us=us, vs=vs,
  #          wspdm=wspd, wspds=wspds, wdirm=wdir, wdirs=wdirs, wdirma=wdira1, wdirsa=wdira2
  obs <- madis_raob(madisbase, datetime, autoftp, madis_server,
                    model$projection$standlon, model$projection$conef)
  if(obs$meta$ns <= 1 ) { next }

  # Load new profile for current timestep.
  # Changed from surface script where all times in model output 
  # are loaded to save memory space since profiles are 4D.
  if(metmodel == "mpas"){
    model <-mpas_raob(file,t=t)
  }
  if(metmodel == "wrf"){
    model <-wrf_raob(file,t=t)
  }
  if(metmodel == "mcip"){
    model <-mcip_raob(file,t=t)
  }

  # MAP observation sites to model grid cell and update new sites.
  if(metmodel == "mpas" & total_loop_count <= total_loop_max){
    site_update <- mpas_site_map(obs$meta$site, obs$meta$sites_unique, sitelist, sitenum, obs$meta$slat, 
                                 obs$meta$slon, obs$meta$elev, obs$meta$report_type, obs$meta$site_locname,
                                 model$projection$lat, model$projection$lon, model$projection$latv, 
                                 model$projection$lonv, model$projection$cells_on_vertex,
                                 cind, cwgt,  mysql$dbase, sitecommand, sitemax, updateSiteTable,
                                 tmpquery_file=query_file2)
    sitenum <-site_update$sitenum
    sitelist<-site_update$sitelist
    cind    <-site_update$cind
    cwgt    <-site_update$cwgt
  }
  if((metmodel == "wrf" || metmodel == "mcip") & total_loop_count <= total_loop_max){
    site_update <- wrf_site_map(obs$meta$site, obs$meta$sites_unique, sitelist, sitenum, obs$meta$slat, 
                                obs$meta$slon, obs$meta$elev, obs$meta$report_type, obs$meta$site_locname, 
                                model$projection, wrfind, interp, mysql$dbase, sitecommand, sitemax, 
                                updateSiteTable, buffer=buffer, tmpquery_file=query_file2)
    sitenum <-site_update$sitenum
    sitelist<-site_update$sitelist
    wrfind  <-site_update$wrfind
  }

writeLines("**********************************************************************************************")

# Open new query file
system(paste("rm -f ",query_file1)) 
sfile<-file(query_file1,"a")
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

    ###############################################################################################
    # Define model profiles, dependent on model.
    if(metmodel == "mpas"){
      if(is.na(cwgt[s,1])) { next }
      t_mod     <- model$raob_met$temp[,cind[s,1]]
      rh_mod    <- model$raob_met$rh[,cind[s,1]]
      u_mod     <- model$raob_met$u[,cind[s,1]]
      v_mod     <- model$raob_met$v[,cind[s,1]]
      zlev_mod  <- model$raob_met$levzh[,cind[s,1]]
      plev_mod  <- model$raob_met$p[,cind[s,1]]
    }
    if(metmodel == "wrf" || metmodel == "mcip"){
      x         <-wrfind[s,1,1]
      y         <-wrfind[s,2,1]
      t_mod     <- model$raob_met$temp[x,y,]
      rh_mod    <- model$raob_met$rh[x,y,]
      u_mod     <- model$raob_met$u[x,y,]
      v_mod     <- model$raob_met$v[x,y,]
      zlev_mod  <- model$raob_met$levzh[x,y,]
      plev_mod  <- model$raob_met$p[x,y,]
     }
     varid_str <-"v1_id, v2_id"
     var_str   <-"v1_val, v2_val"
     ####################################################################################################
     # Pass significant level profiles on their native levels so they can be written to query connection.
     # Temp and RH of obs and model
     if(native) {
      varid_vals <-"'T_OBS_N', 'RH_OBS_N'"
      profiles   <- data.frame(obs$raob_met$temps[,all.sind],obs$raob_met$rhs[,all.sind])
      levels     <- obs$raob_met$prest[,all.sind]
      raob_query_native(sfile, ametproject, obs$meta$site[all.sind],mysqltimestr, datetime$modeltime,
                        varid_str, var_str, varid_vals, profiles, levels, fcast_hr=fcast_hr, init_utc=init_utc) 
      varid_vals <-"'T_MOD_N', 'RH_MOD_N'"
      profiles   <- data.frame(t_mod,rh_mod)
      levels     <- plev_mod
      raob_query_native(sfile, ametproject, obs$meta$site[all.sind],mysqltimestr, datetime$modeltime,
                        varid_str, var_str, varid_vals, profiles, levels, fcast_hr=fcast_hr, init_utc=init_utc) 
      # U and V of obs and model
      varid_vals<-"'U_OBS_N', 'V_OBS_N'"
      profiles  <- data.frame(obs$raob_met$us[,all.sind],obs$raob_met$vs[,all.sind])
      levels    <- obs$raob_met$ghgts[,all.sind]
      raob_query_native(sfile, ametproject, obs$meta$site[all.sind],mysqltimestr, datetime$modeltime,
                        varid_str, var_str, varid_vals, profiles, levels, fcast_hr=fcast_hr, init_utc=init_utc) 
      varid_vals<-"'U_MOD_N', 'V_MOD_N'"
      profiles  <- data.frame(u_mod,v_mod)
      levels    <- zlev_mod
      raob_query_native(sfile, ametproject, obs$meta$site[all.sind],mysqltimestr, datetime$modeltime,
                        varid_str, var_str, varid_vals, profiles, levels, fcast_hr=fcast_hr, init_utc=init_utc) 
     } 
     ###############################################################################################
     # Mandatory Pressure level interpolation and query write to main query file connection.
     # Temp 
     if(mandatory) {
      varid_vals<-"'T_OBS_M', 'T_MOD_M'"
      obsdf   <- data.frame(obs$raob_met$presm[,all.sind], obs$raob_met$tempm[,all.sind])
      moddf   <- data.frame(plev_mod, t_mod)
      raob_query_mandatory(sfile, ametproject, obs$meta$site[all.sind],mysqltimestr, datetime$modeltime,
                           varid_str, var_str, varid_vals, obsdf, moddf, fcast_hr=fcast_hr, init_utc=init_utc) 

      # RH 
      varid_vals<-"'RH_OBS_M', 'RH_MOD_M'"
      obsdf   <- data.frame(obs$raob_met$presm[,all.sind], obs$raob_met$rhm[,all.sind])
      moddf   <- data.frame(plev_mod, rh_mod)
      raob_query_mandatory(sfile, ametproject, obs$meta$site[all.sind],mysqltimestr, datetime$modeltime,
                           varid_str, var_str, varid_vals, obsdf, moddf, fcast_hr=fcast_hr, init_utc=init_utc) 

     # U 
      varid_vals<-"'U_OBS_M', 'U_MOD_M'"
      obsdf   <- data.frame(obs$raob_met$presm[,all.sind], obs$raob_met$um[,all.sind])
      moddf   <- data.frame(plev_mod, u_mod)
      raob_query_mandatory(sfile, ametproject, obs$meta$site[all.sind],mysqltimestr, datetime$modeltime,
                           varid_str, var_str, varid_vals, obsdf, moddf, fcast_hr=fcast_hr, init_utc=init_utc) 

     # V 
      varid_vals<-"'V_OBS_M', 'V_MOD_M'"
      obsdf   <- data.frame(obs$raob_met$presm[,all.sind], obs$raob_met$vm[,all.sind])
      moddf   <- data.frame(plev_mod, v_mod)
      raob_query_mandatory(sfile, ametproject, obs$meta$site[all.sind],mysqltimestr, datetime$modeltime,
                           varid_str, var_str, varid_vals, obsdf, moddf, fcast_hr=fcast_hr, init_utc=init_utc) 
     } 
     ###############################################################################################

  }
  close(sfile)
  system(command)
  # End of loop over observations sites
  ##########################################################################
  writeLines("**********************************************************************************************")
  total_loop_count <- total_loop_count + 1
} 
  # End of loop over times
##########################################################################

##########################################################################
}  # End of loop over files
system(paste("rm -f ",query_file1)) 
system(paste("rm -f ",query_file2)) 
quit(save="no")

