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
#  - Version 1.5, Jul 6, 2022, Robert Gilliam                             
#       - Major update! OSU/PRISM Group ended ASCII data distribution. 
#         Added the PRISM BIL raster data cabability to replace ASCII.
#         Old ASCII is still operable, but BIL is much simpler and enables Leaflet HTML plot output.
#         Added specific functionality for daily, monthly or annual comparisons. Monthly default.
#         BIL (Raster data) format is the only workable option if user does not have ASCII archived.
#         Update also adds better screen prints of operation and stats + test stats output file.
#         Cool new Leaflet plots are configurable using color and level settings via wrapper.
#         The run_prism_comp.csh wrapper is updated for single anal or looping over days/months/years.
#   
#-----------------------------------------------------------------------#
#########################################################################
  options(warn=-1)
#############################################################################################################
  if(!require(ncdf4))      {stop("Required Package NCDF4 was not loaded")}
  if(!require(prism))      {stop("Required Package prism was not loaded")}
  if(!require(raster))     {stop("Required Package raster was not loaded")}
  if(!require(leaflet))    {stop("Required Package leaflet was not loaded")}
  if(!require(htmlwidgets)){stop("Required Package htmlwidgets was not loaded")}

  ametbase       <- Sys.getenv("AMETBASE")
  ametR          <- paste(ametbase,"/R_analysis_code",sep="")
  source (paste(ametR,"/MET_amet.prism-lib.R",sep=""))

  # Hardcoded GUI on/off switch for testing
  # amet_gui       <- FALSE 
  if(!exists("amet_gui"))                  { amet_gui   <- FALSE  }

  # New logic to bypass ENV inputs if in GUI mode where these are passed via run_info_MET.R config
  if(!amet_gui) {
   project        <-Sys.getenv("AMET_PROJECT")
   model_start    <-Sys.getenv("MODEL_START")
   model_end      <-Sys.getenv("MODEL_END")
   start_tindex   <-as.integer(Sys.getenv("START_TINDEX"))
   end_tindex     <-as.integer(Sys.getenv("END_TINDEX"))
   precip_outfile <-Sys.getenv("OUTFILE")

   daily          <-as.logical(Sys.getenv("DAILY"))
   annual         <-as.logical(Sys.getenv("ANNUAL"))

   prismdir       <-Sys.getenv("PRISM_DIR") 
   prism_prefix   <-Sys.getenv("PRISM_PREFIX") 
   bil            <-as.logical(Sys.getenv("PRISM_BIL")) 

   leaf_dxdykm    <-as.numeric(Sys.getenv("LEAF_DXDYKM"))
   pbins          <-as.numeric(unlist(strsplit(Sys.getenv("LEAF_LEVELS")," ")))
   pdbins         <-as.numeric(unlist(strsplit(Sys.getenv("LEAF_DLEVELS")," ")))
   cols1          <-unlist(strsplit(Sys.getenv("LEAF_COLOR")," "))
   dcols1         <-unlist(strsplit(Sys.getenv("LEAF_DCOLOR")," "))
   donetcdf       <-TRUE 
   use.default.precip.levs <-FALSE 
   use.range.precip.levs   <-FALSE
  }

  if(model_start == ""  || is.na(model_start) )  { 
   stop(paste("Model start date output does not exist. Adjust script and retry."))
  }
 
  # GUI INPUTS
  if(amet_gui) {
    savedir        <-Sys.getenv("AMET_OUT")
  }

  # Backward compatability for old wrapper before BIL data option
  if(!exists("bil"))     {    bil    <- TRUE     }
  if(!exists("annual"))  {    annual <- FALSE    }
  if(!exists("daily"))   {    daily  <- FALSE    }

  if(!exists("use.default.precip.levs")) {  use.default.precip.levs <-FALSE;  }  
  if(!exists("use.range.precip.levs"))   {  use.range.precip.levs   <-FALSE;  }  


  if(!exists("savedir") ) {
    parts    <-unlist(strsplit(precip_outfile,split="/"))
    nparts   <-length(parts)
    savedir  <-paste(parts[2:nparts-1],sep="/",collapse="/")
  }

 ###############################################################################################
 ###############################################################################################
 #
 # Open one of the model outputs and grab model name information
 writeLines(paste("            "))
 writeLines(paste("     ------------------------------------------------------       "))
 writeLines(paste("     Reading PRISM and Model Output & Regrid For Comparison       "))
 writeLines(paste("     ------------------------------------------------------       "))
 writeLines(paste("            "))
  writeLines(paste(model_start))
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

 ###################################################################################
 # Main Processing 1. Aquire and read PRISM, Read model precip and interpolate PRISM to model grid
  # Read prism file and get grid information and monthly precip total on prism grid.
  # List contains:
  # prism$grid        <-list(lat=lat, lon=lon, dxdykm=dxdykm, nx=nx, ny=ny)
  # prism$precip
  if(bil) {
    prism <- prism_read_bil(model_start_date, prismdir, daily=daily, annual=annual)
  } else {
    #prism <- prism_read(model_start_date, prismdir, prism_prefix, daily=daily)
    prism <- prism_read_bil(model_start_date, prismdir, daily=daily, annual=annual)
  }

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
  dxdykm            <- ifelse(leaf_dxdykm == -99, round(min(modelp1$grid$carea)), leaf_dxdykm)
 }

 if(model == "wrf") {
  modelp1 <-wrf_precip(model_start, tindex=start_tindex)   
  modelp2 <-wrf_precip(model_end, tindex=end_tindex)   
  model_precip_mm   <- modelp1$grid$lm.na*(modelp2$precip - modelp1$precip)
  model_precip_mm   <- (modelp2$precip - modelp1$precip)
  model_rainc_mm   <- modelp1$grid$lm.na*(modelp2$rainc - modelp1$rainc)
  model_rainc_mm   <- (modelp2$rainc - modelp1$rainc)
  model_rainnc_mm   <- modelp1$grid$lm.na*(modelp2$rainnc - modelp1$rainnc)
  model_rainnc_mm   <- (modelp2$rainnc - modelp1$rainnc)
  prism_precip_mm   <- prism_to_wrf_grid(model_precip_mm, prism$precip, modelp1$grid$lat, modelp1$grid$lon, prism$grid$lat,  
                                         prism$grid$lon, prism$grid$dxdykm)
  prism.na.mask     <- ifelse(is.na(prism_precip_mm), 0, 1)
  model_precip_mm   <- model_precip_mm * prism.na.mask
  model_rainc_mm   <- model_rainc_mm * prism.na.mask
  model_rainnc_mm   <- model_rainnc_mm * prism.na.mask
  prism_precip_mm   <- ifelse(is.na(prism_precip_mm), 0, prism_precip_mm)
  dxdykm            <- ifelse(leaf_dxdykm == -99, modelp1$grid$dx/1000, leaf_dxdykm)
 }
 ###################################################################################
  
 ###################################################################################
 # Compute grid statisitcs for land cells in full WRF/MPAS domain (CONUS only)
 # Print to std output & write text file.
 prism_total_masked<-ifelse(prism_precip_mm == 0,NA, prism_precip_mm)
 model_total_masked<-ifelse(prism_precip_mm == 0,NA, model_precip_mm)
 if(sum(prism_precip_mm,na.rm=T)==0) {
   psmessage <- "   ---- No Precipitation reported for this period ---- "
   diff      <- 0
   bias.grid <- 0
   mea.grid  <- 0
   cor.grid  <- 1
 } else {
   psmessage <- "   "
   diff      <- model_total_masked- prism_total_masked
   bias.grid <-sprintf("%5.3f", mean(diff,na.rm=T))
   mea.grid  <-sprintf("%5.3f",mean(abs(diff),na.rm=T))
   cor.grid  <-sprintf("%5.3f",cor(matrix(model_total_masked),matrix(prism_total_masked),use='complete.obs'))
 }
 # Chop up full path and name of NetCDF file to get directory for text stats file & write stats to text
 parts    <-unlist(strsplit(model_start_date,split="_"))
 start_day<-parts[1]

 period   <-"monthly"
 if(daily)  { period  <-"daily"  }
 if(annual) { period  <-"annual" }

 # Print statistics to screen
 writeLines(paste("     -----------------------------------------       "))
 writeLines(paste("     Computing Grid Statistics & Write to Text       "))
 writeLines(paste("     -----------------------------------------       "))
 writeLines(paste(psmessage))
 writeLines(paste("Period and start day:",period," ",start_day))
 writeLines(paste("Grid Mean Error -- Bias (mm):",bias.grid))  
 writeLines(paste("Grid Mean Absolute Error (mm):",mea.grid))  
 writeLines(paste("Grid Correlation:",cor.grid))
 writeLines(paste("Note that model and obs gridpoint are set to missing for all no-precip obs cells."))

 txtstatf <- paste(savedir,"/",project,".prism.",period,".",start_day,".txt",sep="")
 writeLines(paste("Grid statistics are preserved in this text file:",txtstatf))
 sfile    <-file(txtstatf,"w")
 writeLines(paste("Period and start day:",period," ",start_day), con=sfile)
 writeLines(paste("Grid Mean Error -- Bias (mm):",bias.grid), con =sfile)  
 writeLines(paste("Grid Mean Absolute Error (mm):",mea.grid), con =sfile)  
 writeLines(paste("Grid Correlation:",cor.grid), con =sfile)
 writeLines(paste("Note that model and obs gridpoint are set to missing for all no-precip obs cells."), con =sfile)
 close(sfile)
 writeLines(paste("            "))
 ###################################################################################

 ###################################################################################
 # Write Model and PRISM grids on model domain to NetCDF output
 if(donetcdf) {
   precip_outfile <- paste(savedir,"/",project,".prism-",model,".",period,".",start_day,".nc",sep="")
   netcdf_precip(model_start, precip_outfile, prism_precip_mm, model_precip_mm,model_rainc_mm, model_rainnc_mm, 
                 model=model, ncks="ncks", ncrename="ncrename", ncatted="ncatted")
   writeLines(paste("            ",precip_outfile))
 }
 ###################################################################################


 ###################################################################################
 # Leaflet HTML Output option
 if(bil) {
  writeLines(paste("     -----------------------------------------------       "))
  writeLines(paste("     Creating Leaflet HTML Outputs for Visualization       "))
  writeLines(paste("     -----------------------------------------------       "))
  writeLines(paste("            "))
  leaffile <- paste(savedir,"/",project,".prism.leaf.",period,".",start_day,".html",sep="")
  regrid_ll<-regrid2d_to_latlon(model_precip_mm, modelp1$grid$lat, modelp1$grid$lon,
                               grid_data2=prism_precip_mm, dxdykm=dxdykm, model=model)
  writeLines(paste(leaffile,"            "))

  rlon     <- range(regrid_ll$grid$lon)
  rlat     <- range(regrid_ll$grid$lat)
  xy       <- cbind(as.vector(modelp1$grid$lon), as.vector(modelp1$grid$lat))

  r <- raster(ncols=regrid_ll$grid$nx, nrows=regrid_ll$grid$ny, xmn=rlon[1], xmx=rlon[2], ymn=rlat[1], ymx=rlat[2])
  # get the (last) indices
  r1 <- rasterize(xy, r)
  r2 <- rasterize(xy, r)
  r3 <- rasterize(xy, r)
  r4 <- rasterize(xy, r)
  values(r1) <- as.vector(regrid_ll$varout)
  values(r2) <- as.vector(regrid_ll$varout2)
  values(r3) <- as.vector(regrid_ll$varout-regrid_ll$varout2)
  values(r4) <- as.vector( 100* (regrid_ll$varout-regrid_ll$varout2)/regrid_ll$varout2)

  # Default precip and difference range if not specified or use.default.precip.levs
  writeLines(paste("AUTO PRECIP RANGE", use.default.precip.levs))
  if(sum(pbins) == 0 || use.default.precip.levs) {
    pbins          <-c(0,25,50,75,100,125,150,175,200,250)
    if(daily) { pbins          <-c(0,1,5,10,15,20,25,50,75,100,150,300) }
    if(annual) { pbins         <-c(0,50,100,200,300,400,500,750,1000,2000,3000,5000) }
  writeLines(paste("AUTO PRECIP RANGE", use.default.precip.levs,annual,daily))
    pdbins         <-c(-250,-100,-50,-25,-15,-5,0,5,15,25,50,100,250)
  }
  if(length(cols1) == 0 || length(dcols1) == 0 || use.default.precip.levs) {
    cols1 <-c('#ffffe5','#f7fcb9','#d9f0a3','#addd8e','#78c679','#41ab5d','#238443','#006837','#004529')
    cols1 <-c('#ffffe5','#f7fcb9','#d9f0a3','#addd8e','#78c679','#41ab5d','#238443','#006837','#004529','#e7e1ef','#c994c7','#dd1c77')
    cols1 <-c("#ffffe5","#f7fcb9","#d9f0a3","#addd8e","#78c679","#41ab5d","#238443","#006837","#004529","#2171b5","#6baed6","#bdd7e7","#eff3ff")
   dcols1 <-c("#543005","#8c510a","#bf812d","#dfc27d","#f6e8c3","#f5f5f5","#c7eae5","#80cdc1","#35978f","#01665e","#003c30")
  }
 
  pmax  <- max(regrid_ll$varout, regrid_ll$varout2, na.rm=T)
  pdmax <- max(abs(regrid_ll$varout-regrid_ll$varout2), na.rm=T)
  if(max(pbins) < pmax) {
   pbins<-round(c(pbins,pmax))
  }
  if(max(pdbins) < pdmax) {
   pdbins<-round(c(-pdmax,pdbins,pdmax)) 
  }
 
  modgroup   <-paste(toupper(model),"(mm)")
  obsgroup   <-paste("PRISM (mm)")
  diffgroup  <-paste(toupper(model),"-PRISM (mm)",sep="")
  diffpgroup <-paste(toupper(model),"-PRISM (%)",sep="")

  transp<-0.65

  pal1 <- colorBin(cols1, values(r1), na.color = "transparent",pretty=T,bins=pbins)
  pal2 <- colorBin(cols1, values(r2), na.color = "transparent",pretty=T,bins=pbins)
  pal3 <- colorBin(dcols1, values(r3), na.color = "transparent",pretty=T,bins=pdbins)
  pal4 <- colorBin(dcols1, values(r4), na.color = "transparent",pretty=T,bins=c(-250,seq(-100,100,by=25),250))

  my.leaf<-leaflet() %>% addTiles() 
  saveWidget(my.leaf, file=leaffile, selfcontained=T)

  my.leaf<-leaflet() %>% addTiles() %>%
  addRasterImage(flip(r1,"y"), colors = pal1, opacity = transp, group=modgroup) %>%
  addRasterImage(flip(r2,"y"), colors = pal2, opacity = transp, group=obsgroup) %>%
  addRasterImage(flip(r3,"y"), colors = pal3, opacity = transp, group=diffgroup) %>%
  addRasterImage(flip(r4,"y"), colors = pal4, opacity = transp, group=diffpgroup) %>%
  addLegend(pal = pal1, values = values(r1),title = "Total Precipitation (mm)")  %>%
  addLegend(pal = pal3, values = values(r3),title = "Diff Precipitation (mm)")  %>%
  addLegend(pal = pal4, values = values(r4),title = "Diff Precipitation (%)")  %>%
  addLayersControl(overlayGroups = c(modgroup, obsgroup, diffgroup, diffpgroup), 
                   options = layersControlOptions(collapsed = FALSE))  %>%
  hideGroup(c(modgroup,diffgroup,diffpgroup))
  saveWidget(my.leaf, file=leaffile, selfcontained=T)
  writeLines(paste("Leaflet HTML output:",leaffile))
  writeLines(paste("            "))
 } else {
  writeLines(paste("     Leaflet plot output option can be enabled if PRISM raster data is set.   "))
  writeLines(paste("       i.e. setenv PRISM_BIL   T"))
 }
 ###################################################################################
#
###############################################################################################



