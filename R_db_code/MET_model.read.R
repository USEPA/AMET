#######################################################################################################
#####################################################################################################
#                                                                 ################################
#     AMET Read Model Functions Library                           ###############################
#                                                                 ###############################
#     Developed by the US Environmental Protection Agency         ###############################
#                                                                 ################################
#####################################################################################################
#######################################################################################################
#
#  V1.3, 2017Apr18, Robert Gilliam: Initial Development
#  V1.4, 2018Sep30, Robert Gilliam: 
#       - Added functions for reading model upper-air meteorology for
#         matching to rawindsonde observations. Also computes what is not 
#         explicitly in the model output. Profiles include pressure, height,
#         temperature, rh, u and v wind components. Other values are included
#         for potential future use for other obs sources like theta and q.
#
#######################################################################################################
#     This script contains the following functions
#
#     mpas_surface       --> Open MPAS output and read surface variables to be
#                            matched with MADIS surface observations. Also grabs grid 
#                            structure information for matching obs to the grid.
#
#     wrf_surface        --> Open WRF output and read surface variables to be
#                            matched with MADIS surface observations. Also grabs the 
#                            projection information for obs matching. 
#
#     mpas_raob          --> Open MPAS output and read 3D met variables to be
#                            matched with MADIS raob observations. Also grabs grid 
#                            structure information for matching obs to the grid.
#
#     wrf_raob           --> Open WRF output and read 3D met variables to be
#                            matched with MADIS raob observations. Also grabs the 
#                            projection information for obs matching.
#
#     model_time_format  --> Takes either MPAS or WRF timestamp and reformats for various AMET
#                            functions and MySQL.
#
#     cone               --> Cone factor for a model domain that is used for wind rotation.
#
#     lamb_latlon_to_ij  --> Find an i,j grid index for a latitude and longitude coordinate given
#                            the model projection (Lambert Conformal only) definition.
#
#######################################################################################################
#######################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: MPAS_SURFACE  -----------------------------------####
#  Open MPAS output and extract grid information and surface met data for comparision to MADIS obs
#
# Input:
#       file   -- Model output file name. Full path and file name
#
# Output: Multi-level list of model projection data and surface meteorology.
#
#  projection <-list(mproj=0, lat=lat, lon=lon, latv=latv, lonv=lonv, 
#                    cells_on_vertex=cells_on_vertex, conef=0, standlon=0)
#  sfc_met    <-list(time=time,t2=t2,q2=q2,u10=u10,v10=v10)

 mpas_surface <-function(file) {

  writeLines(paste("Reading MPAS Model Output File:",file))
  f1 <-nc_open(file)
   lat    <- ncvar_get(f1, varid="latCell")
   lon    <- ncvar_get(f1, varid="lonCell")
   latv   <- ncvar_get(f1, varid="latVertex")
   lonv   <- ncvar_get(f1, varid="lonVertex")
   time   <- ncvar_get(f1, varid="xtime")

   cells_on_vertex <- ncvar_get(f1, varid="cellsOnVertex")

   t2     <- ncvar_get(f1, varid="t2m")
   q2     <- ncvar_get(f1, varid="q2")
   u10    <- ncvar_get(f1, varid="u10")
   v10    <- ncvar_get(f1, varid="v10")
   swr    <- ncvar_get(f1, varid="swdnb")
   psf    <- ncvar_get(f1, varid="surface_pressure")/1000
  nc_close(f1)

  #swr    <-t2 * 0.0
  # Get met array dimensions; set first good model time to 1
  ncells  <-dim(t2)[1]
  nt      <-length(time)
    
  # MPAS in radians, convert to degrees and +/- 180 Lon reference
  lat  <- lat * (180/pi)
  lon  <- lon * (180/pi)
  latv <- latv * (180/pi)
  lonv <- lonv * (180/pi)

  # Convert to same Lon reference as obs sites
  lon  <-ifelse(lon > 180, lon - 360, lon)
  lonv <-ifelse(lonv > 180, lonv - 360, lonv)

  # Check dimensions of met variables to determine if file has only 
  # one time. If so, add a time dimension to the array for interpolation
  # compatability. 
  if( nt == 1 ) {
    t2  <-array(t2,c(ncells,1))
    q2  <-array(q2,c(ncells,1))
    u10 <-array(u10,c(ncells,1))
    v10 <-array(v10,c(ncells,1))
    swr <-array(swr,c(ncells,1))
    psf <-array(psf,c(ncells,1))
  }

  projection <-list(mproj=0, lat=lat, lon=lon, latv=latv, lonv=lonv, 
                    cells_on_vertex=cells_on_vertex, conef=0, standlon=0)
  sfc_met    <-list(time=time, t2=t2, q2=q2, u10=u10, v10=v10, swr=swr, psf=psf)
  
  return(list(projection=projection,sfc_met=sfc_met))

 }
#####--------------------------	  END OF FUNCTION: MPAS_SURFACE    -----------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: WRF_SURFACE  ------------------------------------####
#  Open WRF output and extract grid information and surface met data for comparision to MADIS obs
# Input:
#       file   -- Model output file name. Full path and file name
#
# Output: Multi-level list of model projection data and surface meteorology.
#
#  projection <-list(mproj=mproj, lat=lat, lon=lon, lat1=lat1, lon1=lon1, nx=nx, ny=ny, dx=dx,
#                    truelat1=truelat1, truelat2=truelat2, standlon=standlon, conef=conef)
#  sfc_met    <-list(time=time,t2=t2,q2=q2,u10=u10,v10=v10)

 wrf_surface <-function(file) {

  f1  <-nc_open(file)

   head <- ncatt_get(f1, varid=0, attname="TITLE" )$value
   time <- ncvar_get(f1, varid="Times")
   mproj<- ncatt_get(f1, varid=0, attname="MAP_PROJ" )$value
   
   if(mproj == 1){
    lat1    <- ncvar_get(f1, varid="XLAT",start=c(1,1,1),count=c(1,1,1))
    lon1    <- ncvar_get(f1, varid="XLONG",start=c(1,1,1),count=c(1,1,1))
    lat     <- ncvar_get(f1, varid="XLAT",start=c(1,1,1),count=c(-1,-1,1))
    lon     <- ncvar_get(f1, varid="XLONG",start=c(1,1,1),count=c(-1,-1,1))
    nx      <- ncatt_get(f1, varid=0, attname="WEST-EAST_GRID_DIMENSION" )$value
    ny      <- ncatt_get(f1, varid=0, attname="SOUTH-NORTH_GRID_DIMENSION" )$value
    dx      <- ncatt_get(f1, varid=0, attname="DX" )$value
    truelat1<- ncatt_get(f1, varid=0, attname="TRUELAT1" )$value
    truelat2<- ncatt_get(f1, varid=0, attname="TRUELAT2" )$value
    standlon<- ncatt_get(f1, varid=0, attname="STAND_LON" )$value
   }

   if(mproj == 2){
    lat1      <- ncvar_get(f1, varid="XLAT",start=c(1,1,1),count=c(1,1,1))
    lon1      <- ncvar_get(f1, varid="XLONG",start=c(1,1,1),count=c(1,1,1))
    lat       <- ncvar_get(f1, varid="XLAT",start=c(1,1,1),count=c(-1,-1,1))
    lon       <- ncvar_get(f1, varid="XLONG",start=c(1,1,1),count=c(-1,-1,1))
    nx        <- ncatt_get(f1, varid=0, attname="WEST-EAST_GRID_DIMENSION" )$value
    ny        <- ncatt_get(f1, varid=0, attname="SOUTH-NORTH_GRID_DIMENSION" )$value
    dx        <- ncatt_get(f1, varid=0, attname="DX" )$value
    truelat1  <- ncatt_get(f1, varid=0, attname="TRUELAT1" )$value
    truelat2  <- ncatt_get(f1, varid=0, attname="TRUELAT2" )$value
    standlon  <- ncatt_get(f1, varid=0, attname="STAND_LON" )$value
   }
   conef  <- cone(truelat1,truelat2)

   t2     <- ncvar_get(f1, varid="T2")
   q2     <- ncvar_get(f1, varid="Q2")
   u10    <- ncvar_get(f1, varid="U10")
   v10    <- ncvar_get(f1, varid="V10")
   swr    <- ncvar_get(f1, varid="SWDOWN")
   psf    <- ncvar_get(f1, varid="PSFC")/1000
   
  nc_close(f1)
  
  # Check dimensions of met variables to determine if file has only 
  # one time. If so, add a time dimension to the array for interpolation
  # compatability. 
  nt    <-length(time)
  if( nt == 1 ) {
    t2  <-array(t2,c(nx,ny,1))
    q2  <-array(q2,c(nx,ny,1))
    u10 <-array(u10,c(nx,ny,1))
    v10 <-array(v10,c(nx,ny,1))
    swr <-array(swr,c(nx,ny,1))
    psf <-array(psf,c(nx,ny,1))
  }

  projection <-list(mproj=mproj, lat=lat, lon=lon, lat1=lat1, lon1=lon1, nx=nx, ny=ny, dx=dx,
                    truelat1=truelat1, truelat2=truelat2, standlon=standlon, conef=conef)
  sfc_met    <-list(time=time, t2=t2, q2=q2, u10=u10, v10=v10, swr=swr, psf=psf)
  
  return(list(projection=projection,sfc_met=sfc_met))

 }
#####--------------------------	  END OF FUNCTION: WRF_SURFACE     -----------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: WRF_RAOB     ------------------------------------####
#  Open WRF output and extract grid information and met data for matching to MADIS RAOB profiles
# Input:
#       file   -- Model output file name. Full path and file name
#          t   -- Time index to get. Unlike surface met, this was added to
#                 cut down on array size in memory instead of grabbing all times at once.
#
# Output: Multi-level list of model projection data and sounding meteorology.
#
#  projection <-list(mproj=mproj, lat=lat, lon=lon, lat1=lat1, lon1=lon1, nx=nx, ny=ny, dx=dx,
#                    truelat1=truelat1, truelat2=truelat2, standlon=standlon, conef=conef)
#  raob_met    <-list(time=time, elev=elev, sigu=sigu, sigm=sigm, u=u, v=v, theta=theta, temp=tk,
#                      qv=qv, rh=rh, pblh=pblh, psf=psf, p=p, levzf=levzf, levzh=levzh)

 wrf_raob <-function(file,t=1) {

  f1  <-nc_open(file)

   head <- ncatt_get(f1, varid=0, attname="TITLE" )$value
   time <- ncvar_get(f1, varid="Times")
   mproj<- ncatt_get(f1, varid=0, attname="MAP_PROJ" )$value
   
   if(mproj == 1){
    lat1    <- ncvar_get(f1, varid="XLAT",start=c(1,1,1),count=c(1,1,1))
    lon1    <- ncvar_get(f1, varid="XLONG",start=c(1,1,1),count=c(1,1,1))
    lat     <- ncvar_get(f1, varid="XLAT",start=c(1,1,1),count=c(-1,-1,1))
    lon     <- ncvar_get(f1, varid="XLONG",start=c(1,1,1),count=c(-1,-1,1))
    nx      <- ncatt_get(f1, varid=0, attname="WEST-EAST_GRID_DIMENSION" )$value
    ny      <- ncatt_get(f1, varid=0, attname="SOUTH-NORTH_GRID_DIMENSION" )$value
    dx      <- ncatt_get(f1, varid=0, attname="DX" )$value
    truelat1<- ncatt_get(f1, varid=0, attname="TRUELAT1" )$value
    truelat2<- ncatt_get(f1, varid=0, attname="TRUELAT2" )$value
    standlon<- ncatt_get(f1, varid=0, attname="STAND_LON" )$value
   }

   if(mproj == 2){
    lat1      <- ncvar_get(f1, varid="XLAT",start=c(1,1,1),count=c(1,1,1))
    lon1      <- ncvar_get(f1, varid="XLONG",start=c(1,1,1),count=c(1,1,1))
    lat       <- ncvar_get(f1, varid="XLAT",start=c(1,1,1),count=c(-1,-1,1))
    lon       <- ncvar_get(f1, varid="XLONG",start=c(1,1,1),count=c(-1,-1,1))
    nx        <- ncatt_get(f1, varid=0, attname="WEST-EAST_GRID_DIMENSION" )$value
    ny        <- ncatt_get(f1, varid=0, attname="SOUTH-NORTH_GRID_DIMENSION" )$value
    dx        <- ncatt_get(f1, varid=0, attname="DX" )$value
    truelat1  <- ncatt_get(f1, varid=0, attname="TRUELAT1" )$value
    truelat2  <- ncatt_get(f1, varid=0, attname="TRUELAT2" )$value
    standlon  <- ncatt_get(f1, varid=0, attname="STAND_LON" )$value
   }

   conef  <- cone(truelat1,truelat2)

   sigu   <- ncvar_get(f1, varid="ZNU")
   sigm   <- ncvar_get(f1, varid="ZNW")

   p      <- ncvar_get(f1, varid="P",      start=c(1,1,1,t),count=c(-1,-1,-1,1))/100
   pb     <- ncvar_get(f1, varid="PB",     start=c(1,1,1,t),count=c(-1,-1,-1,1))/100
   ph     <- ncvar_get(f1, varid="PH",     start=c(1,1,1,t),count=c(-1,-1,-1,1))/9.81
   phb    <- ncvar_get(f1, varid="PHB",    start=c(1,1,1,t),count=c(-1,-1,-1,1))/9.81

   u      <- ncvar_get(f1, varid="U",      start=c(1,1,1,t),count=c(-1,-1,-1,1))
   v      <- ncvar_get(f1, varid="V",      start=c(1,1,1,t),count=c(-1,-1,-1,1))
   theta  <- ncvar_get(f1, varid="T",      start=c(1,1,1,t),count=c(-1,-1,-1,1))
   t00    <- as.numeric(ncvar_get(f1, varid="T00",    start=c(t),count=c(1)))
   qv     <- ncvar_get(f1, varid="QVAPOR", start=c(1,1,1,t),count=c(-1,-1,-1,1))
   pblh   <- ncvar_get(f1, varid="PBLH",   start=c(1,1,t),count=c(-1,-1,1))
   psf    <- ncvar_get(f1, varid="PSFC",   start=c(1,1,t),count=c(-1,-1,1))/100
   elev   <- ncvar_get(f1, varid="HGT",    start=c(1,1,t),count=c(-1,-1,1))   
   t2m    <- ncvar_get(f1, varid="T2",     start=c(1,1,t),count=c(-1,-1,1))

  nc_close(f1)

  nzh <-dim(sigu)[1]
  nzf <-dim(sigm)[1]

  # Some calcs to derive variables needed for other calcs and comp to obs profiles
  # theta = baseP + pert; pressure = baseP + pert; temp, satmixr and RH
  theta  <- theta + 300
  p      <- p + pb
  levzf  <- ph+phb
  tk     <- theta / (1000/p) ^ 0.2857143
  e      <- 0.611 * exp ( (2.501E6/461.5) * ( (1/273.14) -(1/tk) ) )
  #mixrs  <- 0.62197 * (e/(p/10-e))
  mixrs  <- 0.62197 * (e/(p/10))
  rh     <- 100*(qv/mixrs)
  rh     <- ifelse(rh > 100,100,rh)
  rh     <- ifelse(rh < 0.0,0.1,rh)

  # Calcuate full level heigh above ground level and center height of full levels
  levzh      <- p*0.0
  levzf[,,1] <- 0.0
  for(z in 2:nzf) {
    levzf[,,z] <- levzf[,,z] - elev
  }
  for(z in 1:nzh) {
    levzh[,,z] <- levzf[,,z] + (levzf[,,z+1] - levzf[,,z])/2
  }
  
  projection <-list(mproj=mproj, lat=lat, lon=lon, lat1=lat1, lon1=lon1, nx=nx, ny=ny, dx=dx,
                    truelat1=truelat1, truelat2=truelat2, standlon=standlon, conef=conef)
  raob_met    <-list(time=time, elev=elev, sigu=sigu, sigm=sigm, u=u, v=v, theta=theta, temp=tk,
                      qv=qv, rh=rh, pblh=pblh, psf=psf, p=p, levzf=levzf, levzh=levzh)
  
  return(list(projection=projection, raob_met=raob_met))

 }
#####--------------------------	  END OF FUNCTION: WRF_RAOB        -----------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: MPAS_RAOB     -----------------------------------####
#  Open MPAS output and extract grid information and upper-air met data for comparision to MADIS raob soundings
#
# Input:
#       file   -- Model output file name. Full path and file name
#
# Output: Multi-level list of model projection data and sounding meteorology.
#
#  projection <-list(mproj=0, lat=lat, lon=lon, latv=latv, lonv=lonv, 
#                    cells_on_vertex=cells_on_vertex, conef=0, standlon=0)
#  raob_met    <-list(time=time, elev=elev, sigu=sigu, sigm=sigm, u=u, v=v, theta=theta, temp=tk,
#                      qv=qv, rh=rh, pblh=pblh, psf=psf, p=p, levzf=levzf, levzh=levzh)

 mpas_raob <-function(file, t=1) {

  writeLines(paste("Reading MPAS Model Output File:",file))
  f1 <-nc_open(file)
   lat    <- ncvar_get(f1, varid="latCell")
   lon    <- ncvar_get(f1, varid="lonCell")
   latv   <- ncvar_get(f1, varid="latVertex")
   lonv   <- ncvar_get(f1, varid="lonVertex")
   time   <- ncvar_get(f1, varid="xtime")
   cells_on_vertex <- ncvar_get(f1, varid="cellsOnVertex")
   # Get met array dimensions; set first good model time to 1
   ncells <-dim(t)[1]
   nt     <-length(time)

   hgt   <- ncvar_get(f1, varid="zgrid")
   p     <- ncvar_get(f1, varid="pressure", start=c(1,1,t),count=c(-1,-1,1))/100
   theta <- ncvar_get(f1, varid="theta", start=c(1,1,t),count=c(-1,-1,1))
   rh    <- ncvar_get(f1, varid="relhum", start=c(1,1,t),count=c(-1,-1,1))
   u     <- ncvar_get(f1, varid="uReconstructZonal", start=c(1,1,t),count=c(-1,-1,1))
   v     <- ncvar_get(f1, varid="uReconstructMeridional", start=c(1,1,t),count=c(-1,-1,1))
   pblh  <- ncvar_get(f1, varid="hpbl", start=c(1,t),count=c(-1,1))
   psf   <- ncvar_get(f1, varid="surface_pressure", start=c(1,t),count=c(-1,1))/100
   elev  <- hgt[1,]

  nc_close(f1)

  # Some calcs to derive variables needed for other calcs and comp to obs profiles
  # theta = baseP + pert; pressure = baseP + pert; temp, satmixr and RH
  sigu   <- hgt[,1]*0.0
  nzf    <- length(sigu)
  sigm   <- sigu[1:(nzf-1)]
  nzh    <- length(sigm)

  tk     <- theta / (1000/p) ^ 0.2857143
  e      <- 0.611 * exp ( (2.501E6/461.5) * ( (1/273.14) -(1/tk) ) )
  mixrs  <- 0.62197 * (e/(p/10))
  qv     <- rh*mixrs/100

  # Calcuate full level heigh above ground level and center height of full levels
  levzh      <- p*0.0
  levzf      <- hgt*0.0
  for(z in 2:nzf) {
    levzf[z,] <- hgt[z,] - elev
  }
  for(z in 1:nzh) {
    levzh[z,] <- levzf[z,] + (levzf[z+1,] - levzf[z,])/2
  }
    
  # MPAS in radians, convert to degrees and +/- 180 Lon reference
  lat  <- lat * (180/pi)
  lon  <- lon * (180/pi)
  latv <- latv * (180/pi)
  lonv <- lonv * (180/pi)

  # Convert to same Lon reference as obs sites
  lon  <-ifelse(lon > 180, lon - 360, lon)
  lonv <-ifelse(lonv > 180, lonv - 360, lonv)

  projection <-list(mproj=0, lat=lat, lon=lon, latv=latv, lonv=lonv, 
                    cells_on_vertex=cells_on_vertex, conef=0, standlon=0)

  raob_met    <-list(time=time, elev=elev, sigu=sigu, sigm=sigm, u=u, v=v, theta=theta, temp=tk,
                      qv=qv, rh=rh, pblh=pblh, psf=psf, p=p, levzf=levzf, levzh=levzh)

  return(list(projection=projection, raob_met=raob_met))

 }
#####--------------------------	  END OF FUNCTION: MPAS_RAOB       -----------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: MODEL_TIME_FORMAT       -------------------------####
#  This function take WRF or MPAS timestamp (same format) and reformats to the AMET standard 
#  that is YYYYMMDD HH:00:00 as well as individual components year, month, day and hour.
# Input:
#       timestamp   -- Timestamp from model output. i.e., 2017-05-05_00:00:00
#
# Output: Multi-level time list with several standard used time values
#         yc (YYYY), mc (MM), dc (DD), hc (HH), modeldate (YYYYMMDD) and modeltime (12:00:00)

 model_time_format <-function(timestamp) {

  tmp1      <- unlist(strsplit(timestamp,"_"))
  yc        <- unlist(strsplit(tmp1,"-"))[1]
  mc        <- unlist(strsplit(tmp1,"-"))[2]
  dc        <- unlist(strsplit(tmp1,"-"))[3]
  hc        <- unlist(strsplit(tmp1[2],":"))[1]
  minc      <- unlist(strsplit(tmp1[2],":"))[2]
  secc      <- unlist(strsplit(tmp1[2],":"))[3]
  modeldate <-paste(yc,mc,dc,sep="")
  modeltime <-paste(hc,":",minc,":",secc,sep="")

  return(list(modeldate=modeldate,modeltime=modeltime,
              yc=yc,mc=mc,dc=dc,hc=hc,minc=minc,secc=secc))

 }
#####--------------------------	  END OF FUNCTION: MODEL_TIME_FORMAT     -----------------------------####
##########################################################################################################
##########################################################################################################

##########################################################################################################
#####--------------------------   START OF FUNCTION: CONE         ------------------------------------####
#  Cone factor function
# Input:
#        true1  -- first true latitude of the projection
#        true2  -- second true latitude of the projection
#         hemi  -- Hemisphere of the projection (N=1, S=-1)
#
# Output: Cone factor

 cone <-function(true1,true2,hemi=1) {

   true1  <-33
   true2  <-45
   hemi   <- 1   

   pi180  <-pi/180

   cone   <- log10(cos(true1 * pi180)) - log10(cos(true2 * pi180))
   cone   <- cone / ( log10( tan((45.0 - hemi*true1/2.0) * pi180)) 
             -  log10( tan((45.0 - hemi*true2/2.0) * pi180)) )

   # if met_tru1 and met_tru2 are the same
   if(true1 == true2) {
     cone <- hemi * sin(true1*pi180)
   }
  return(cone)

 }
#####--------------------------	  END OF FUNCTION: CONE           ------------------------------------####
##########################################################################################################

##########################################################################################################
##########################################################################################################
#####-------------------   START OF FUNCTION: LAMB_LATLON_TO_IJ         ------------------------------####
# Cacluation of i and j index of a specified latitude and longitude for a given lambert conformal
# projection.
# Input:
#        reflat  -- Latitude of a reference point of the grid. Typically lower left corner of the domain
#        reflon  -- Longitude of a reference point of the grid. Typically lower left corner of the domain
#        iref    -- I index of the reference point.
#        jref    -- J index of the reference point.
#        stdlt1  -- first true latitude of the projection
#        stdlt2  -- second true latitude of the projection
#        stdlon  -- center longitude of the LC projection
#        delx    -- grid spacing in meters
#        grdlat  -- Latitude of point of interest (usually an observation location)
#        grdlon  -- Longitude of point of interest (usually an observation location)
#        radius  -- Radius of the earth in meters. Default is current value for WRF and MPAS
#
# Output: List with i and j index values in fractional form

 lamb_latlon_to_ij <- function(reflat, reflon, iref, jref, stdlt1, stdlt2,
                               stdlon, delx, grdlat, grdlon, radius= 6370000.0) {

#reflat  <- 20.8568
#reflon  <- -121.492
#iref    <- 1
#jref    <- 1
#stdlt1  <- 33.0
#stdlt2  <- 45.0
#stdlon  <- -97.0
#delx    <-12000
#dely    <-12000
#radius  <- 6370000.0
#grdlat<-obs$meta$slat[7731]
#grdlon<-obs$meta$slon[7731]

   pi     <- 4.0*atan(1.0)
   pi2    <- pi/2.0
   pi4    <- pi/4.0
   d2r    <- pi/180.0
   r2d    <- 180.0/pi
   omega4 <- 4.0*pi/86400.0

   if(stdlt1 == stdlt2) {
     gcon <- sin( abs(stdlt1) * d2r)
   } else {
     gcon <- (log(sin((90.0- abs(stdlt1))* d2r))-log(sin((90.0- abs(stdlt2))* d2r)))/
             (log(tan((90.0- abs(stdlt1))*0.5* d2r))-log(tan((90.0- abs(stdlt2))*0.5* d2r)))
   }

   ogcon  <- 1.0/gcon
   ahem   <- abs( stdlt1 / stdlt1 )
   deg    <- (90.0- abs(stdlt1)) * d2r
   cn1    <- sin(deg)
   cn2    <- radius * cn1 * ogcon
   deg    <- deg * 0.5
   cn3    <- tan(deg)
   deg    <- (90.0- abs(reflat)) * 0.5 * d2r
   cn4    <- tan(deg)
   rih    <- cn2 *(cn4 / cn3)**gcon
   deg    <- (reflon-stdlon) * d2r * gcon

   xih    <- rih * sin(deg) - delx/2
   yih    <- (-1 * rih * cos(deg) * ahem) - delx/2

   deg    <- (90.0 - (grdlat * ahem) ) * 0.5 * d2r
   cn4    <- tan(deg)
  
   rrih   <- cn2 *  (cn4/cn3)**gcon
   check  <- 180.0-stdlon
   alnfix <- stdlon + check
   alon   <- grdlon + check

   if (alon<0.0)  { alon <- alon+360.0 }
   if (alon>360.0){ alon <- alon-360.0 }
 
   deg    <- (alon-alnfix) * gcon * d2r
   XI     <- rrih * sin(deg)
   XJ     <- -1* rrih * cos(deg) * ahem

   grdi   <- iref+(XI-xih)/(delx)
   grdj   <- jref+(XJ-yih)/(delx)

  return(list(i=grdi, j=grdj))

 }
#####--------------------------	  END OF FUNCTION: LAMB_LATLON_TO_IJ  --------------------------------####
##########################################################################################################

#         XCART = M_XGRID(LAT,LON,X_POLE_U,LAT_TRUE_U,LON_XX_U)
#         YCART = M_YGRID(LAT,LON,Y_POLE_U,LAT_TRUE_U,LON_XX_U)

#         RI = XCART/DM_U + 1
#         RJ = YCART/DM_U + 1

#C * * * * * * * * * * EARTH LENGTH CONVERSIONS* * * * * * * * * * * * *
#C* *
#C
#C
#C  TRANSFORMATION FUNCTIONS FROM (LAT,LON) TO (X,Y) IN METERS
#C  AND THE INVERSE FUNCTIONS.  (TAKEN FROM THE MAPS DEVELOPER GUIDE -
#C  CHAPTER 6). ADDED ON OCTOBER 29, 1984, FROM STAN BENJAMIN MACROS.
#C
#C       M_XGRID AND M_YGRID GIVE (X,Y) AS A FUNCTION OF (LAT,LON)
#C
#C
#C HISTORY:
#C
#C       K. BREWSTER 8-85
#C       B. JEWETT   7-29-87     ALTERED FOR USE WITH DIFFERENT GRID DOM
#CINS
#C       T.L.SMITH   3-16-90     STANDARDIZED, MADE ENTRY PTS INDIVID FU
#CCTIONS
#C       M. BARTH    11-24-98    SENT IN GRID-DEMINITION PARAMS AS ARGS
#C       M. BARTH    06-17-99    REDEFINED LON_XX (ADDED -90)
#C       M. BARTH    09-15-99    COPIED FROM MSAS AND MODIFIED FOR MADIS.
#C       L. BENJAMIN 06-19-08    CHANGED MADISCON INCLUDE TO INTQC1CON1

#      FUNCTION M_XGRID(LAT,LON,X_POLE,LAT_TRUE,LON_XX)
#C
#      INCLUDE 'IMPLICIT'
#      INCLUDE 'INTQC1CON1'
#      REAL M_XGRID
#      REAL LAT,LON,X_POLE,LAT_TRUE,LON_XX
#C
#      M_XGRID=(X_POLE+((1.+SIN(LAT_TRUE*RADDEG_P))/
#     +(1.+SIN(LAT*RADDEG_P)))*EARTH_RAD_P*COS(LAT*RADDEG_P)*
#     +COS((LON-LON_XX-90.)*RADDEG_P))
#      RETURN
#      END


#      FUNCTION M_YGRID(LAT,LON,Y_POLE,LAT_TRUE,LON_XX)
#      INCLUDE 'IMPLICIT'
#      INCLUDE 'INTQC1CON1'
#      REAL M_YGRID
#      REAL LAT,LON,Y_POLE,LAT_TRUE,LON_XX

#      M_YGRID=(Y_POLE+((1.+SIN(LAT_TRUE*RADDEG_P))/
#     +(1.+SIN(LAT*RADDEG_P)))*EARTH_RAD_P*COS(LAT*RADDEG_P)*
#     +SIN((LON-LON_XX-90.)*RADDEG_P))
#      RETURN
#      END

##########################################################################################################
#####--------------------------        START OF FUNCTION INTERP2D_FULL  ------------------------------####
# 
# A developed, but now unused nearest neighbor or bi-linear interpolation option
# This was preserved for possible use in new development, but not currently used because
# a more efficient method was developed.

 interp2d_full <-function(var,i,j,interp_type=2) {

  if (interp_type == 1) {	           # Nearest neighbor interpolation
    interp_value<-var[round(i),round(j)]
  }
  
  if (interp_type == 2 ){             # Bi-linear 
    xo<-floor(i)
    yo<-floor(j)
    dx<- i- xo
    dy<- j- yo
    x1<- xo
    y1<- yo
 
    if(dx < 0.5 & dy < 0.5){
      x1<- xo-1
      y1<- yo-1
      dx<- dx+0.5
      dy<- dy+0.5

    } else if(dx < 0.5 & dy > 0.5) {
      x1<- xo-1
      y1<- yo
      dx<- dx+0.5
      dy<- dy+0.0

    } else if(dx > 0.5 & dy < 0.5) {
      x1<- xo
      y1<- yo-1
      dx<- dx
      dy<- dy+0.5
    }

    x2<-x1+1
    y2<-y1+1

    gp11<-var[x1,y1]
    gp21<-var[x2,y1]
    gp12<-var[x1,y2]
    gp22<-var[x2,y2]

    f1<- gp11 + ( dx * (gp21-gp11) )
    f2<- gp12 + ( dx * (gp22-gp12) )

    interp_value<-f1 + (dy * (f2-f1) )

  }

  return (interp_value)    	                         

 }
#####--------------------------	        END OF FUNCTION: INTERP2D_FULL   -----------------------------####
##########################################################################################################

#####--------------------------        START OF FUNCTION: INTERP2D_QUICK  -----------------------------####
# 
# A developed, but now unused nearest neighbor or bi-linear interpolation option
# This was preserved for possible use in new development, but not currently used because
# a more efficient method was developed.

 interp2d_quick <-function(var,wrfind) {

    #f1<- var[wrfind[1,1],wrfind[2,1]] + ( wrfind[3,1] * (var[wrfind[1,2],wrfind[2,1]] - var[wrfind[1,1],wrfind[2,1]]) )
    #f2<- var[wrfind[1,1],wrfind[2,2]] + ( wrfind[3,1] * (var[wrfind[1,2],wrfind[2,2]] - var[wrfind[1,1],wrfind[2,2]]) )
    #f1<- gp11 + ( dx * (gp21-gp11) )
    #f2<- gp12 + ( dx * (gp22-gp12) )
    #interp_value<-f1 + (wrfind[3,2] * (f2-f1) )

    #interp_value<-
    #(var[wrfind[1,1],wrfind[2,1]] + ( wrfind[3,1] * (var[wrfind[1,2],wrfind[2,1]] - var[wrfind[1,1],wrfind[2,1]]) )) +
    #( wrfind[3,2] *
    # (var[wrfind[1,1],wrfind[2,2]] + ( wrfind[3,1] * (var[wrfind[1,2],wrfind[2,2]] - var[wrfind[1,1],wrfind[2,2]]) ) -
    # (var[wrfind[1,1],wrfind[2,1]] + ( wrfind[3,1] * (var[wrfind[1,2],wrfind[2,1]] - var[wrfind[1,1],wrfind[2,1]]) )) ))

    #interp_value<-var[wrfind[1,1],wrfind[2,1]]
    
  return (interp_value)    	                         

 }
#####--------------------------	   END OF FUNCTION INTERP2D_QUICK      -------------------------------####
##########################################################################################################

