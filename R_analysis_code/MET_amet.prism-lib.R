#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#                AMET (Atmospheric Model Evaluation Tool)               #
#                                                                       #
#            AMET PRISM-Model Precipitation Function Library	        #
#                       MET_amet.prism-lib.R                            #
#                                                                       #
#         Developed by the US Environmental Protection Agency           #
#-----------------------------------------------------------------------#
#########################################################################
#
# Version 1.4, Sep 30, 2018, Robert Gilliam
#  - Initial development of functions to read PRISM, WRF and MPAS, interpolate PRISM to model and
#    populate a NetCDF file with those grids. Note the NetCDF file is created using NCO commands
#    in the csh run script prior to the execution of the main R script. 
#     
# Version 1.5, Jul 6, 2021, Robert Gilliam
#  - Added example function to sum prism-model NetCDF files for defined period and compute grid stats.
#  - New Raster data and Leaflets functions added for major update to PRISM-WRF/MPAS analysis.
#    prism_read_bil uses R prism package to aquire data automatically for daily/monthly/annual anal.
#    regrid2d_to_latlon does regridding of WRF/MPAS/PRISM for Leaflet HTML plotting
#	
#-----------------------------------------------------------------------###############################
#######################################################################################################
#######################################################################################################
#     This script contains the following functions
#
#     prism_read     --> Open PRISM text-base grid files and place into data structure with grid
#                        and its geo-metadata for interpolation to MPAS or WRF
#
#     prism_read_bil --> Use R PRISM package to aquire and read PRISM BIL raster grid files 
#                        and place into data structure with grid information
#
#     mpas_precip    --> Read a MPAS output file at specified time index and get total precip
#
#     wrf_precip     --> Read a WRF output file at specified time index and get total precip
#
#  prism_to_mpas_grid--> Take mpas and prism precip and grid information and interpolate prism to mpas
#
#  prism_to_wrf_grid --> Take wrf and prism precip and grid information and interpolate prism to mpas
#
#  precip_accum      --> Example function to take daily/monthly prism-model NetCDF files and total + stats
#
#  regrid2d_to_latlon--> Regridding of model and PRISM to Lat-Lon grid for Leaflet plot output
#
#######################################################################################################
#######################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: PRISM_READ   ------------------------####
#  Open PRISM ASCII grid file and read header with grid information and 2-D precipitation grid
#
# Input:
#      model_start_date     -- Model output for start date in order to read correct prism file
#      prismdir             -- Location of prism data files
#      prism_prefix         -- Prefix name of prism files
#      daily                -- Logical for daily analysis  (default monthly)
#
# Output: prism_precip
#
#  projection  <-list(lat, lon, dxdykm, nx, ny)
#  precip2d    <-list(precip2d)

prism_read <-function(model_start_date, prismdir, prism_prefix, daily=FALSE) {

 ###############################################################################
 ## Define Year and Month of Evaluation based on model output time start.
 #  This time format is the same in MPAS and WRF only the variable name is diff.
 # 2016-07-01_00:00:00
 parts    <-unlist(strsplit(model_start_date, "-"))
 yyyy     <-parts[1]
 mm       <-parts[2]
 dd       <-unlist(strsplit(parts[3], "_"))[1]
 ###############################################################################

 ###############################################################################
 ## Read PRISM monthly precip file and extract 2-D precip array and grid info 
 # a is the read of the main prism 2D array, c is the read of the header
 prismfile   <-paste(prismdir,"/",yyyy,"/",prism_prefix,yyyy,mm,"_asc.asc",sep="")
 if(daily) {
   prismfile   <-paste(prismdir,"/",yyyy,"/",prism_prefix,yyyy,mm,dd,"_asc.asc",sep="")
 }

 writeLines(paste("Reading PRISM monthly precip:",prismfile)) 
 a           <-read.delim(prismfile,sep=" ",header=F,skip=6) 
 precip      <-as.matrix(a)
 prism_precip<-ifelse(precip<0,NA,precip)
 c           <-read.delim(prismfile,sep=" ",header=F) 
 #Read prism data file header
 nx          <-as.numeric(as.character(c[1,2]))
 ny          <-as.numeric(as.character(c[2,2]))
 lllon       <-as.numeric(as.character(c[3,2]))
 lllat       <-as.numeric(as.character(c[4,2]))
 ddeg        <-as.numeric(as.character(c[5,2]))
 dxdykm      <-ddeg*111.111

 lat_1d      <-rev(seq(lllat,lllat+((ny-1)*ddeg),by=ddeg))
 lon_1d      <-seq(lllon,lllon+((nx-1)*ddeg),by=ddeg)

 lat         <-array(NA,c(ny,nx))
 lon         <-array(NA,c(ny,nx))
 for(x in 1:nx){
   lat[,x]   <-lat_1d
 }
 for(y in 1:ny) {
   lon[y,]   <-lon_1d
 }
 lon         <-ifelse(lon < 0, 360+lon,lon) 
 ###############################################################################################
 # grid metadata list to return
 grid        <-list(lat=lat, lon=lon, dxdykm=dxdykm, nx=nx, ny=ny)

 return(list(grid=grid, precip=prism_precip))

}
#####--------------------------	  END OF FUNCTION: PRISM_READ      -----------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: PRISM_READ_BIL   ---------------------####
#  Open PRISM BIL (RASTER) grid file and read header with grid information and 2-D precipitation grid
#
# Input:
#      model_start_date     -- Model output for start date in order to read correct prism file
#      prismdir             -- Location of prism data files
#      daily                -- Logical for daily analysis  (default monthly)
#      annual               -- Logical for annual analysis (default monthly)
#
# Output: prism_precip
#
#  grid        <-list(lat, lon, dxdykm, nx, ny)
#  precip      <-list(precip)

prism_read_bil <-function(model_start_date, prismdir, 
                          daily=FALSE, annual=FALSE) {

 ###############################################################################
 ## Define Year and Month of Evaluation based on model output time start.
 #  This time format is the same in MPAS and WRF only the variable name is diff.
 # 2016-07-01_00:00:00
 parts    <-unlist(strsplit(model_start_date, "-"))
 yyyy     <-as.numeric(parts[1])
 mm       <-as.numeric(parts[2])
 dd       <-as.numeric(unlist(strsplit(parts[3], "_"))[1])
 bil_day  <-as.Date(paste(yyyy,mm,dd,sep="-"))
 ###############################################################################

 # Set local PRISM directory to put PRISM BIL files & retrieve datasets
 prism_set_dl_dir(prismdir)

 ###############################################################################
 ## Read PRISM monthly precip file and extract 2-D precip array and grid info 
 # a is the read of the main prism 2D array, c is the read of the header
 if(annual) {
   writeLines("Annual precip")
   bil   <-get_prism_annual(  "ppt", year=yyyy, keepZip = FALSE)
   pd    <- prism_archive_subset("ppt", "annual", years=yyyy)
 } else if (daily) {
   writeLines("Daily precip")
   bil   <-get_prism_dailys(  "ppt", dates=bil_day, keepZip = FALSE)
   pd    <- prism_archive_subset("ppt", "daily", dates=bil_day)
 } else {
   writeLines("Monthly precip")
   bil   <-get_prism_monthlys("ppt", year=yyyy, mon=mm, keepZip = FALSE)
   pd    <- prism_archive_subset("ppt", "monthly", years=yyyy, mon=mm)
 }

 rast<-raster(pd_to_file(pd))
 precip<-values(rast)
 prism_precip<-ifelse(precip<0,NA,precip)

 ny<-dim(rast)[1]
 nx<-dim(rast)[2]
 ncell<-nx*ny
 bounds<-extent(rast)[1:4]
 bounds<-c(bounds[3],bounds[4],bounds[2],bounds[1])
 dx<-xres(rast)
 dy<-yres(rast)

 ddeg<-dx
 lllon       <-bounds[4]
 lllat       <-bounds[1]
 dxdykm      <-dx*111.111

 lat_1d      <-rev(seq(lllat,lllat+((ny-1)*ddeg),by=ddeg))
 lon_1d      <-seq(lllon,lllon+((nx-1)*ddeg),by=ddeg)

 lat         <-array(NA,c(ny,nx))
 lon         <-array(NA,c(ny,nx))
 for(x in 1:nx){
   lat[,x]   <-lat_1d
 }
 for(y in 1:ny) {
   lon[y,]   <-lon_1d
 }
 lon         <-ifelse(lon < 0, 360+lon,lon)

 ###############################################################################################
 # grid metadata list to return
 grid        <-list(lat=lat, lon=lon, dxdykm=dxdykm, nx=nx, ny=ny)

 return(list(grid=grid, precip=t(array(prism_precip,c(nx,ny))) ))

}
#####--------------------------	  END OF FUNCTION: PRISM_READ      -----------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: MPAS_PRECIP   ------------------------####
#  Read precipitation from MPAS output
#
# Input:
#      model_output   -- MPAS output file with rainc and rainnc
#      tindex         -- Time index in model output file to get precip total
#      rainc_var      -- Convective rainfall total variable name
#      rainnc_var     -- Grid-scale rainfall total variable name
#
# Output: list with grid information (list) and total precip
#         grid <-list(lat, lon,  carea, landmask, lm.na, ncell)
#         precip

mpas_precip <-function(model_output,tindex=1,rainc_var="rainc",rainnc_var="rainnc") {


  writeLines(paste("Reading MPAS file:",model_output)) 
  m1<-nc_open(model_output)
    lat_mpas<-ncvar_get(m1,varid="latCell")
    lon_mpas<-ncvar_get(m1,varid="lonCell")
    lat_mpas<- lat_mpas * (180/pi)
    lon_mpas<- lon_mpas * (180/pi)
    carea   <-sqrt(ncvar_get(m1,varid="areaCell"))/1000
    rain    <-ncvar_get(m1,varid=rainc_var,c(1,tindex),c(-1,1)) + ncvar_get(m1,varid=rainnc_var,c(1,tindex),c(-1,1))
    landmask<-ncvar_get(m1,varid="xland", start=c(1,1), count=c(-1,1))
    #landmask<-ncvar_get(m1,varid="xland")
    #landmask<-landmask[,1]
    lm.na   <-ifelse(landmask == 0, 1, 1)
    lm.na   <-ifelse(landmask == 2, NA, 1)
    ncells  <-dim(lat_mpas)
  nc_close(m1)

 grid       <-list(lat=lat_mpas, lon=lon_mpas, carea=carea, landmask=landmask, 
                   lm.na=lm.na, ncells=ncells)

 return(list(grid=grid, precip=rain))

}
#####--------------------------	  END OF FUNCTION: MPAS_PRECIP       ---------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: WRF_PRECIP   ------------------------####
#  Read precipitation from WRF output
#
# Input:
#      model_output   -- WRF output file with rainc and rainnc
#      tindex         -- Time index in model output file to get
#      rainc_var      -- Convective rainfall total variable name
#      rainnc_var     -- Grid-scale rainfall total variable name
#
# Output: list with grid information (list) and total precip
#         grid <-list(lat, lon, landmask, lm.na, nx, ny)
#         precip

wrf_precip <-function(model_output,tindex=1,rainc_var="RAINC",rainnc_var="RAINNC") {


  writeLines(paste("Reading WRF output:",model_output)) 
  m1<-nc_open(model_output)
     lat_wrf <-ncvar_get(m1,varid="XLAT",c(1,1,1),c(-1,-1,1))
     lon_wrf <-ncvar_get(m1,varid="XLONG",c(1,1,1),c(-1,-1,1))
     landmask<-ncvar_get(m1,varid="LANDMASK",c(1,1,1),c(-1,-1,1))
     dx      <- ncatt_get(m1, varid=0, attname="DX" )$value
     lm.na   <-ifelse(landmask == 0, 1, 1)
     lm.na   <-ifelse(landmask == 0, NA, 1)
     dv      <-dim(lat_wrf)
     rain    <-ncvar_get(m1,varid=rainc_var,c(1,1,tindex),c(-1,-1,1)) + 
               ncvar_get(m1,varid=rainnc_var,c(1,1,tindex),c(-1,-1,1))
  nc_close(m1)

 grid       <-list(lat=lat_wrf, lon=lon_wrf, landmask=landmask, 
                   lm.na=lm.na, nx=dv[1], ny=dv[2], dx=dx)

 return(list(grid=grid, precip=rain))

}
#####--------------------------	  END OF FUNCTION: WRF_PRECIP       ---------------------------------####
##########################################################################################################
##########################################################################################################
#####--------------------------   START OF FUNCTION: PRISM_TO_MPAS_GRID           --------------------####
#  Purpose:
#
# Input: model_precip  --> 2D array of model precip
#        prism_precip  --> 2D array of prism precip
#        lat_mpas      --> 2D latitude array of MPAS
#        lon_mpas      --> 2D longitude array of MPAS
#        lat_prism     --> 2D latitude array of PRISM data
#        lon_prism     --> 2D longitude array of PRISM data
#        dxkm          --> grid spacing in km  of PRISM data
#        carea         --> Size of MPAS grid cell
#        ncells        --> Number of MPAS mesh points
#
# Output: prism_on_mpas --> PRISM data interpolated to MPAS mesh

 prism_to_mpas_grid <-function(model_precip, prism_precip, lat_mpas, lon_mpas,   
                               lat_prism, lon_prism, dxkm, carea, ncells) {

  nx_prism      <- dim(prism_precip)[2]
  ny_prism      <- dim(prism_precip)[1]
  latrng        <- range(lat_prism)
  lonrng        <- range(lon_prism)
  prism_on_mpas <- model_precip * NA
 
  for(i in 1:ncells) {
    if(lat_mpas[i] > latrng[1] & lat_mpas[i] < latrng[2] & lon_mpas[i] > lonrng[1] & lon_mpas[i] < lonrng[2] ){     
     prism.cell.diam<-round(carea[i]/dxkm)
     #writeLines(paste("MPAS cell",i,"of",ncells,"PRISM cell diameter relative to MPAS grid",round(prism.cell.diam)))
     yloc<-which.min(abs(lat_mpas[i] - lat_prism[,1]))
     xloc<-which.min(abs(lon_mpas[i] - lon_prism[1,]))
     n<-floor(prism.cell.diam/2)
     if( (yloc-n) > 0 & (yloc+n) <= ny_prism & (xloc-n) > 0 & (xloc+n) <=nx_prism ) {
       prism_on_mpas[i]<-mean(prism_precip[(yloc-n):(yloc+n),(xloc-n):(xloc+n)],na.rm=T)
     }
    }   
  }  

 return(prism_on_mpas)

}
#####--------------------------	  END OF FUNCTION: PRISM_TO_MPAS_GRID       --------------------------####
##########################################################################################################
##########################################################################################################
#####--------------------------   START OF FUNCTION: PRISM_TO_WRF_GRID           --------------------####
#  Purpose:
#
# Input: model_precip  --> 2D array of model precip
#        prism_precip  --> 2D array of prism precip
#        lat_wrf       --> 2D latitude array of WRF
#        lon_wrf       --> 2D longitude array of WRF
#        lat_prism     --> 2D latitude array of PRISM data
#        lon_prism     --> 2D longitude array of PRISM data
#        dxkm          --> grid spacing in km for new lat-lon grid
#
# Output: prism_on_wrf --> PRISM data interpolated to WRF grid
#
 prism_to_wrf_grid <-function(model_precip, prism_precip, lat_wrf,    
                               lon_wrf, lat_prism, lon_prism, dxkm) {

  latrng        <- range(lat_prism)
  lonrng        <- range(lon_prism)
  prism_on_wrf  <- model_precip * NA
  nx_wrf        <- dim(model_precip)[1]
  ny_wrf        <- dim(model_precip)[2]
  nx_prism      <- dim(prism_precip)[2]
  ny_prism      <- dim(prism_precip)[1]
  
  lon_wrf_0360  <-ifelse(lon_wrf < 0, 360+lon_wrf, lon_wrf)

  for(y in 1:ny_wrf) {
    for(x in 1:nx_wrf) {
      yloc<-which.min(abs(lat_wrf[x,y] - lat_prism[,1]))
      xloc<-which.min(abs(lon_wrf_0360[x,y] - lon_prism[1,]))
      #writeLines(paste(x,y, lat_wrf[x,y], lon_wrf[x,y], yloc,xloc))
      if(yloc < 2 || yloc > (ny_prism-1) || xloc < 2 || xloc > (nx_prism-1)) { next }
      #prism.on.wrf[x,y]<- mean( c(prism_precip[(yloc-1):(yloc+1),xloc],
      #                    prism_precip[(yloc-1):(yloc+1),xloc+1],prism_precip[(yloc-1):(yloc+1),xloc-1]))
      prism_on_wrf[x,y]<- prism_precip[yloc,xloc]
    }
  }  

 return(prism_on_wrf)

}
#####--------------------------	  END OF FUNCTION: PRISM_TO_WRF_GRID       --------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: PRECIP ACCUM   ------------------------####
#  Purpose: This is an example function of how users can add precip from daily or monthly
#           prism-model NetCDF files to defined period, seasonal/annual file. Also prints 
#           domain precip statistics of that file.
#
# Input: precipdir --> location of model-prism daily or monthly NetCDF files to be totaled
#        accumout  --> path and name of total precip file of defined period
#        prefix    --> this is a prefix used to list desired daily/monthly prism-model files
#                      to be considered in total precip and statistics calcs.
#
# Output: Nothing is passed out of this function, but accumout file is generated within function.
#

 precip_accum <-function(precipdir,accumout,prefix="") {
   
  require(ncdf4)
  #precipdir <-"/home/grc/AMET_v13/output/wrf_conus12_oaqps/prism/accum-bin"
  #prefix    <-"mpas_prism_precip"
  #accumout  <-"/home/grc/AMET_v13/output/wrfv4_hyb_nomodis/prism/wrfv4_hyb_nomodis_2016Annual.nc"

  files <-system(paste("ls -lh ",precipdir,"/",prefix,"*",sep=''),intern=T)
  nf    <-length(files)

  for(f in 1:nf) {
    parts<-unlist(strsplit(files[f], " "))
    file <-parts[length(parts)]
    writeLines(paste("Reading wrf-prism file and adding to total precip:",file))

    f1  <-nc_open(file)
      tmpp<- ncvar_get(f1,varid="PRISM_PRECIP_MM")
      tmpm<- ncvar_get(f1,varid="MODEL_PRECIP_MM")
    nc_close(f1)

    if(f ==1 ){
      prism_total<-tmpp
      model_total<-tmpm
    }
    if(f>1) {
      prism_total<- prism_total + tmpp
      model_total<- model_total + tmpm
    }

  }
  prism_total_masked<-ifelse(prism_total==0,NA,prism_total)
  model_total_masked<-ifelse(prism_total==0,NA,model_total)
  diff <- model_total_masked- prism_total_masked
  bias.grid <-mean(diff,na.rm=T)
  mea.grid  <-mean(abs(diff),na.rm=T)
  cor.grid  <-cor(matrix(model_total_masked),matrix(prism_total_masked),use='complete.obs')
  writeLines(paste("Creating accumulated precipitation file:",accumout))
  system(paste("cp",file,accumout))
  f1  <-nc_open(accumout, write=T)
    tmpp<- ncvar_put(f1,varid="PRISM_PRECIP_MM",prism_total)
    tmpm<- ncvar_put(f1,varid="MODEL_PRECIP_MM",model_total)
  nc_close(f1)
  writeLines(paste("Grid Mean Error -- Bias (mm):",bias.grid))  
  writeLines(paste("Grid Mean Absolute Error (mm):",mea.grid))  
  writeLines(paste("Grid Correlation:",cor.grid))
  writeLines(paste("Note that model and obs gridpoint are set to missing for all no-precip obs cells."))

 return(list())

}
#####--------------------------	  END OF FUNCTION: PRECIP ACCUM      ---------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------       START OF FUNCTION: REGRID2D_TO_LATLON         --------------------####
#  Purpose:
#
# Input: grid_data  --> 2D array of data to interpolate to a lat-lon grid
#        lat        --> 2D latitude array defining grid_data points
#        lon        --> 2D longitude array defining grid_data points
#        dxkm       --> grid spacing in km of new lat-lon grid
#        rosub      --> search radius in grid cells for interpolation routine (WRF interp efficiency)
#        model      --> wrf or mpas precipitation
#    grid_data2     --> 2nd array of 2D data to interpolate to same lat-lon grid
#
# Output: List with interpolated data grid + lat, lon and grid spacing
#         grid=list(lat, lon, dxdy, nx, ny)       
#         varout (2D interpolated array)

 regrid2d_to_latlon <-function(grid_data, lat, lon, grid_data2=0, dxdykm=4, rosub=10, model="wrf") {

 # For testing
 #lon       <- modelp1$grid$lon
 #lat       <- modelp1$grid$lat
 #grid_data <- model_precip_mm
 #grid_data2<- prism_precip_mm
 #rosub     <- 10

 # Initial model grid input information
 DOGRID2   <- FALSE
 nx        <- dim(grid_data)[1]
 ny        <- dim(grid_data)[2]
 lon_lims  <-range(lon)
 lat_lims  <-range(lat)
 dxdy      <- dxdykm/111.11

 # Since PRISM only covers CONUS, change latitude and longitude bounds of new
 # Lat-Lon grid to PRISM area coverage if model domain extends beyond PRISM
 if(model == "mpas") {
  lon_lims[1]<- -125
  lon_lims[2]<- -66  
  lat_lims[1]<-  24
  lat_lims[2]<-  50
 }
 nxll      <-round(diff(lon_lims)/dxdy)
 nyll      <-round(diff(lat_lims)/dxdy)
 ll_lat    <-array(NA,c(nxll,nyll))
 ll_lon    <-array(NA,c(nxll,nyll))
 varout    <-array(NA,c(nxll,nyll))


 if(length(grid_data2) > 0) { 
   DOGRID2   <- TRUE
 }
 # If second 2D gridded input data is provided, regrid into varout2
 if(DOGRID2) {
   varout2    <-array(NA,c(nxll,nyll))
 }

 # Create lat-lon array for lat-lon grid given input grid bounds
 loncount  <- lon_lims[1]
 for(xx in 1:nxll){
  latcount <-lat_lims[1]
  for(yy in 1:nyll) {
    ll_lat[xx,yy]<-latcount
    ll_lon[xx,yy]<-loncount
    latcount     <-latcount+dxdy 
  }
  loncount <-loncount+dxdy
 }

 writeLines(paste("Starting intensive interpolation loop at date/time"))
 system("date")
 if( model == "wrf") {
 # Main interpolation from any 2D grid with 2D lat-lon arrays to
 # a lat-lon grid covering the same area for WRF 2D grids only
 # For efficiency, nearest grid cell search uses small subset that
 # moves as loop over Lat-Lon grid progresses. Rather than distance
 # calc every loop.
 for(xx in 1:nxll){
  x0           <- NA
  y0           <- NA
  for(yy in 1:nyll) {
    if(is.na(x0) & is.na(y0) ) {
      distdeg      <-sqrt( (lat - ll_lat[xx,yy])^2 + (lon - ll_lon[xx,yy])^2)
      if(min(distdeg,na.rm=T) > dxdy) { next }
      indxy        <-which(distdeg==min(distdeg,na.rm=T), arr.ind = TRUE)
      varout[xx,yy]<-grid_data[indxy[1],indxy[2]]
      if(DOGRID2) {
        varout2[xx,yy]<-grid_data2[indxy[1],indxy[2]]
      }
      x0           <-indxy[1]
      y0           <-indxy[2]
      x1           <-0
      y1           <-0
      #writeLines(paste(xx,yy,min(distdeg,na.rm=T),x1,x2,y1,y2,"    ",x0,y0))
    }
    else {
      x1           <- ifelse( x0-rosub <=0, 1,  x0-rosub)
      x2           <- ifelse( x0+rosub >nx, nx, x0+rosub)
      y1           <- ifelse( y0-rosub <=0, 1,  y0-rosub)
      y2           <- ifelse( y0+rosub >ny, ny, y0+rosub)
      lat_sub      <- lat[x1:x2,y1:y2]
      lon_sub      <- lon[x1:x2,y1:y2]
      grid_data_sub<- grid_data[x1:x2,y1:y2]
      distdeg      <-sqrt( (lat_sub - ll_lat[xx,yy])^2 + (lon_sub - ll_lon[xx,yy])^2)
      if(min(distdeg,na.rm=T) > dxdy) { next }
      indxy        <-which(distdeg==min(distdeg,na.rm=T), arr.ind = TRUE)
      x0           <-indxy[1]+x1-1
      y0           <-indxy[2]+y1-1
      varout[xx,yy]<-grid_data[x0,y0]
      if(DOGRID2) {
        varout2[xx,yy]<-grid_data2[x0,y0]
      }
    }
  }
 }
 } else if( model == "mpas") {
   lonw       <-ifelse(lon > 180, lon-360,lon)
   lonna      <-ifelse(lonw < lon_lims[1], NA, lonw)
   lonna      <-ifelse(lonw > lon_lims[2], NA, lonna)
   lonna      <-ifelse(lat  < lat_lims[1], NA, lonna)
   lonna      <-ifelse(lat  > lat_lims[2], NA, lonna)
   latm       <-lat[!is.na(lonna)]
   grid_datam <-grid_data[!is.na(lonna)]
   if(DOGRID2) {
     grid_data2m <-grid_data2[!is.na(lonna)]
   }
   lonm       <-lonna[!is.na(lonna)]
   for(xx in 1:nxll){
    for(yy in 1:nyll) {       
      ind<-which.min(sqrt( (latm - ll_lat[xx,yy])^2 + (lonm - ll_lon[xx,yy])^2))
      varout[xx,yy]<-grid_datam[ind]
      if(DOGRID2) {
        varout2[xx,yy]<-grid_data2m[ind]
      }
    }
   }
 }

 writeLines(paste("End interpolation loop date/time"))
 system("date")
 writeLines(paste("User can reduce processing time by increasing LEAF_DXDYKM that is currently set at:",dxdykm,"km"))
 grid       <-list(lat=ll_lat, lon=ll_lon, dxdy=dxdy, nx=nxll, ny=nyll)
 return(list(grid=grid, varout=varout, varout2=varout2))

}
#####-----------------  END OF FUNCTION: REGRID2D_TO_LATLON   --------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: TEMPLATE   ------------------------####
#  Purpose:
#
# Input:
#
# Output: 
#

 template <-function() {


 return(list())

}
#####--------------------------	  END OF FUNCTION: TEMPLATE       ---------------------------------####
##########################################################################################################


