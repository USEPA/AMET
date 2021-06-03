#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#                AMET (Atmospheric Model Evaluation Tool)               #
#                                                                       #
#                  PRISM-Model Precipitation Comparison                 #
#                          MET_prism_precip.R                           #
#                                                                       #
#         Developed by the US Environmental Protection Agency           #
#-----------------------------------------------------------------------#
#########################################################################
#
# Version 1.4, Sep 30, 2018, Robert Gilliam 
#  - Initial development. Codes external to AMET were developed earlier, but this version integrates
#    a WRF version and MPAS version to fit within the AMET structure. It also, rather than just create
#    plots, which are less friendly to modify to ones taste, just creates a small new NetCDF file
#    with the PRISM and model precipitation totals using NCO tools. This simplifies the script. It's
#    also highly configurable for retrospective simulations where grid scale and convective rain are
#    accumulative over the simulation. You provide the start and end files and time index and the total 
#    precipitation is simply computed. Of course PRISM only has monthly and daily precipitation, so that
#    is the only granularity with this script currently. Users will have to take the NetCDF files from those
#    comparisons to do evaluations of weekly, seasonaly or annual precipitation.
#	
#-----------------------------------------------------------------------#####################################
  options(warn=-1)
#############################################################################################################
  require(ncdf4)
  require(maps)
  require(mapdata)
  require(akima)
  require(fields)

 ametbase         <- Sys.getenv("AMETBASE")
 ametR            <- paste(ametbase,"/R_analysis_code",sep="")
 source (paste(ametR,"/MET_amet.prism-lib.R",sep=""))


  model          <-Sys.getenv("MODEL")
  model_start    <-Sys.getenv("MODEL_START")
  model_end      <-Sys.getenv("MODEL_END")
  start_tindex   <-as.integer(Sys.getenv("START_TINDEX"))
  end_tindex     <-as.integer(Sys.getenv("END_TINDEX"))
  precip_outfile <-Sys.getenv("OUTFILE")

  daily          <-as.logical(Sys.getenv("DAILY"))

  prismdir       <-Sys.getenv("PRISM_DIR") 
  prism_prefix   <-Sys.getenv("PRISM_PREFIX") 

 ###############################################################################################
 ###############################################################################################
 #
 # Open one of the model outputs and grab model name information
  f1  <-nc_open(model_start)
   head    <- ncatt_get(f1, varid=0, attname="TITLE" )$value
   model   <- ncatt_get(f1, varid=0, attname="model_name" )$value
  if(model == "mpas") {
   model<-"mpas"
   writeLines(paste("Matching MPAS output file with PRISM precipitation:",model_start))
   model_start_date <-ncvar_get(f1,varid="xtime")[start_tindex]
  } else if(head != 0) {
   model<-"wrf"
   writeLines(paste("Matching WRF output file with PRISM precipitation:",model_start))
   model_start_date <-ncvar_get(f1,varid="Times")[start_tindex]
  } else if(model == 0 & head == 0){ 
   writeLines("The model output is not standard WRF or MPAS output. Double check. 
               Terminating model-observation matching.")
   quit(save="no")
  }
  nc_close(f1)

  # Read prism file and get grid information and monthly precip total on prism grid.
  # List contains:
  # grid        <-list(lat=lat, lon=lon, dxdykm=dxdykm, nx=nx, ny=ny)
  # precip
  prism <- prism_read(model_start_date, prismdir, prism_prefix, daily=daily)
  

 if(model == "mpas") {
  # Get mpas precip at the start and end of the period
  # grid       <-list(lat=lat_mpas, lon=lon_mpas, carea=carea, landmask=landmask, lm.na=lm.na, ncells=ncells)
  # precip
  modelp1 <-mpas_precip(model_start, tindex=start_tindex)   
  modelp2 <-mpas_precip(model_end, tindex=end_tindex)   
  model_precip_mm   <- (modelp2$precip - modelp1$precip)
  prism_precip_mm   <- prism_to_mpas_grid(model_precip_mm, prism$precip, modelp1$grid$lat, modelp1$grid$lon, prism$grid$lat,  
                                         prism$grid$lon, prism$grid$dxdykm, modelp1$grid$carea, modelp1$grid$ncells)
  prism.na.mask     <- ifelse(is.na(prism_precip_mm), 0, 1)
  model_precip_mm   <- model_precip_mm * prism.na.mask
  prism_precip_mm   <- ifelse(is.na(prism_precip_mm), 0, prism_precip_mm)
 }
 if(model == "wrf") {
  modelp1 <-wrf_precip(model_start, tindex=start_tindex)   
  modelp2 <-wrf_precip(model_end, tindex=end_tindex)   
  model_precip_mm   <- modelp1$grid$lm.na*(modelp2$precip - modelp1$precip)
  model_precip_mm   <- (modelp2$precip - modelp1$precip)
  prism_precip_mm   <- prism_to_wrf_grid(model_precip_mm, prism$precip, modelp1$grid$lat, modelp1$grid$lon, prism$grid$lat,  
                                         prism$grid$lon, prism$grid$dxdykm)
  prism.na.mask     <- ifelse(is.na(prism_precip_mm), 0, 1)
  model_precip_mm   <- model_precip_mm * prism.na.mask
  prism_precip_mm   <- ifelse(is.na(prism_precip_mm), 0, prism_precip_mm)

 }
  
 f1  <-nc_open(precip_outfile,write=T)
   writeLines(paste("See model output:",precip_outfile))
   ncvar_put(f1,varid="PRISM_PRECIP_MM",prism_precip_mm)
   ncvar_put(f1,varid="MODEL_PRECIP_MM",model_precip_mm)
 nc_close(f1)

###############################################################################################



