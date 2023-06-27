#######################################################################################################
#####################################################################################################
#                                                                 ################################
#     AMET Observation Site Mapping to Model Grid                 ###############################
#                                                                 ###############################
#     Developed by the US Environmental Protection Agency         ###############################
#                                                                 ################################
#####################################################################################################
#######################################################################################################
#
#  V1.3, 2017Apr18, Robert Gilliam: Initial Development
#  V1.4, 2018Sep30, Robert Gilliam: Site mapping functions for mpas and wrf were updated to insert
#                                   site elevation and state in the database stations table.
#  V1.5, 2019Oct30, Robert Gilliam: 
#       - Added calls i,j grid index for domains on other WRF map projections:
#         polar stereog, mercator and regular lat-lon. 
#  V1.5, 2020Jan15, Robert Gilliam: 
#       - Made changes to mpas_site_map for limited-area MPAS grids where sites can be outside
#         of the model domain. Prior it was assumed global so no checks on site-to-model indexing.
#  V1.5, 2020Feb26, Robert Gilliam: 
#       - Added random number to site query filename for multiple runs in the same directory
#       - Old MADIS datasets have site(s) with NA for lat-lon coordinates. Check and skip those now. 
#  V1.5, 2022May04, Robert Gilliam: 
#       - New master Metadata file for surface and upper-air sites was developed for reliable state
#         and country mapping in stations table for more flexible query & data analysis. Ignored 
#         if file is not present and backward compatible. $AMETBASE/obs/MET/mastermeta.Rdata
#
#  V1.6, 2023JUN20, Robert Gilliam:
#       - Updated site mapping for surface text obs where some metadata is not availiable and set to NA
#       - Fixed messages for wrf site mapping function that also works for MCIP and UFS, not just WRF.
#
#######################################################################################################
#######################################################################################################
#     This script contains the following functions
#
#     mpas_site_map    --> Builds sitelist, a master list of site ids that is updated each hour
#                          with any new sites. Alongside the sitelist is an array of the same size
#                          that contains interpolation weightings and surrounding verticies id 
#                          for each site with respect to the observation location within the
#                          MPAS polygon grid structure. This allows AMET to calculate these
#                          interpolation factors only once and just add new sites as they are found.
#
#     wrf_site_map     --> Builds sitelist, a master list of site ids that is updated each hour
#                          with any new sites. Alongside the sitelist is an array of the same size
#                          that contains the nearest i,j grid cell where the observation site is 
#                          located. Also calculated is dx/dy location of the obs site from the lower
#                          left corner of the grid cell. Similar to MPAS interpolation weights, these
#                          are used in the bi-linear interpolation option, but set to zero for 
#                          nearest neighbor, so a single formula can be used for both options. For
#                          limited area models like WRF, this function also rejects sites that are
#                          not within the model domain. Buffer is the number of grid cells from domain
#                          boundary (default =5) were sites are rejected, as to not include sites
#                          in the model boundary zone. This is hard coded, but can be changed in main script. 
#
#
#######################################################################################################
#######################################################################################################

##########################################################################################################
#####--------------------------     START OF FUNCTION: MPAS_SITE_MAP     -----------------------------####
# A Mapping of observations sites to the MPAS unstructured grid. The sitelist and mapping/interpolation
# values are only updated as new sites are found in order to make script as efficient as possible.
#
# Input:
#       site           -- An array of current hour observation site ids
#       sites_unique   -- Unique sites for the current hour
#       sitelist       -- Master list of site ids preserved throughout the AMET run
#       sitenum        -- Number of unique sites in sitelist
#       slat           -- Latitude of sites in hourly site array
#       slon           -- Longitude of sites in hourly site array
#       elev           -- Site elevation (m)
#       report_type    -- Longitude of sites in hourly site array
#       site_locname   -- String describing site location (i.e, for KRDU 'Raleigh-Durham, NC')
#       lat            -- MPAS cell's latitudes
#       lon            -- MPAS cell's longitudes
#       latv           -- MPAS latitude of vertex cells
#       lonv           -- MPAS longitude of vertex cells
#       cells_on_vertex-- grid cell indicies of vertex cells 
#       cind           -- MPAS indices where observation site resides
#       cwgt           -- Barrycentric interpolation weights
#       mysqldbase     -- mysql database connection list for site update query
#       sitecommand    -- mysql command to push query file to server
#       sitemax        -- Optional - max number of sites allowed
#       updateSiteTable-- Optional - update stations table with potential new sites
#       tmpquery_file  -- Optional - site update query file name
#       mastermeta_file-- Optional - master site metadata file name 
#
# Output: Update site information
#         supdate<-list(sitelist=sitelist, sitenum=sitenum, cind=cind, cwgt=cwgt)

 mpas_site_map <-function(site, sites_unique, sitelist, sitenum, 
                          slat, slon, elev, report_type, site_locname,
                          lat, lon, latv, lonv, cells_on_vertex,
                          cind, cwgt, mysqldbase, sitecommand, 
                          sitemax=15000, updateSiteTable=F,
                          tmpquery_file="tmp.site.query",
                          mastermeta_file="xxxyyyvv", madis_dset="metar") {

  # If update site table open temporary site query file
  if(updateSiteTable) {
    system(paste("rm -f ",tmpquery_file)) 
    sfile<-file(tmpquery_file,"a")
    writeLines(paste("use",mysqldbase,";"),con=sfile) 
    use.metafile  <-F
    if(file.exists(mastermeta_file) & madis_dset!="text") {
      load(mastermeta_file)
      use.metafile<-T
    }
  }
  
  # Build site arrays with MPAS cell indices and barycentric weights, or
  # WRF i,j grid indices (only works for Lambert or PolarStereo projections
  writeLines("Mapping MADIS obs sites to MPAS grid") 
  nsr <- length(sites_unique) 
  nsites_outside_domain<-0 
  for(s in 1:nsr) {
    if(sites_unique[s] %in% sitelist){ next }
    inds <-which(sites_unique[s] == site)[1]
    if(is.na(slat[inds]) || is.na(slon[inds])) { next }
    dist <-sqrt( (latv - slat[inds])^2 + (cos(latv*pi/180)*(lonv - slon[inds]))^2)
    vmap <-which(dist==min(dist,na.rm=T), arr.ind = TRUE)

    #if( min(cind[sitenum,]) <= 0 || max(cind[sitenum,]) > length(latv) ) { 
    if( min(cells_on_vertex[,vmap]) <= 0 || max(cells_on_vertex[,vmap]) > length(latv) ) { 
      nsites_outside_domain<-nsites_outside_domain+1
      writeLines(paste(nsites_outside_domain,"Sites ****",sites_unique[s],"**** excluded because out of MPAS domain"))
      next 
    }
    sitenum<-sitenum+1
    try(if(sitenum>sitemax) stop("Error: sitenum > sitemax"))
    sitelist[sitenum]<-sites_unique[s]
  # Using the closest MPAS vertex to each MADIS station, store the cell indices for that vertex
    cind[sitenum,1]<-cells_on_vertex[1,vmap]
    cind[sitenum,2]<-cells_on_vertex[2,vmap]
    cind[sitenum,3]<-cells_on_vertex[3,vmap]

  # Move origin for interpolation to the first cell for that vertex
    XB <- lon[cind[sitenum,2]]-lon[cind[sitenum,1]]  #longitude coord for center of cell 2
    YB <- lat[cind[sitenum,2]]-lat[cind[sitenum,1]]  #latitude coord for center of cell 2
    XC <- lon[cind[sitenum,3]]-lon[cind[sitenum,1]]  #longitude coord for center of cell 3
    YC <- lat[cind[sitenum,3]]-lat[cind[sitenum,1]]  #latitude coord for center of cell 3
    XP <- slon[inds]-lon[cind[sitenum,1]]  #longitude coord for interpolation point
    YP <- slat[inds]-lat[cind[sitenum,1]]  #latitude coord for interpolation point

  # Calculate barycentric weights
    D <- XB*YC-XC*YB
    cwgt[sitenum,1] <- (XP*(YB-YC)+YP*(XC-XB)+XB*YC-XC*YB)/D
    cwgt[sitenum,2] <- ((XP*YC)-(YP*XC))/D
    cwgt[sitenum,3] <- ((YP*XB)-(XP*YB))/D

    writeLines(paste("sitenum:",sitenum,"is",sitelist[sitenum],"at",slat[inds],slon[inds],
                     "  MPAS cell coord:",lat[cind[sitenum,2]],lon[cind[sitenum,2]]))

    if(updateSiteTable){
      tmps    <- trimws(unlist(strsplit(site_locname[inds],','))[2])
      state   <- ifelse(is.na(unlist(strsplit(tmps,""))[1]),"99",substr(tmps,1,2))
      elevs   <- ifelse(is.na(elev[inds]),-9999.99,round(elev[inds]))
      country <-"99"
      if(use.metafile){
        sm<-which(sitelist[sitenum] == mastermeta[,1])[1]
        if(is.na(sm)) { next }
        if(sum(sm)>0) {
          elevs              <-ifelse(is.na(mastermeta[sm,2]),'NULL',round(as.numeric(mastermeta[sm,2])))
          site_locname[inds] <-ifelse(is.na(mastermeta[sm,3]) || nchar(trimws(mastermeta[sm,3]))==0,"99",mastermeta[sm,3])
          state              <-ifelse(is.na(mastermeta[sm,4]) || nchar(trimws(mastermeta[sm,4]))==0,"99",mastermeta[sm,4])
          country            <-ifelse(is.na(mastermeta[sm,5]) || nchar(trimws(mastermeta[sm,5]))==0,"99",mastermeta[sm,5])
          site_locname[inds] <-sub("'", "",site_locname[inds])
        }
      }
      if(madis_dset=="text"){
          site_locname[inds] <-"99"
          state              <-"99"
          country            <-"99"
          elevs              <--9999.99
      }
      writeLines(paste("Inserting site into AMET stations table (meta):",s,sites_unique[s],elevs,site_locname[inds], state, country, site_locname[inds], sep=" ** ")) 
      query<-paste("REPLACE into stations (stat_id, ob_network, common_name, state, lat, lon, elev, country) VALUES ('",sitelist[sitenum],"','",
                   report_type[inds],"','",site_locname[inds],"','",state,"',",slat[inds],",",slon[inds],",",elevs,",'",country,"')",sep="")
      writeLines(paste(query,";"),con=sfile)             
    }


  }

  if(updateSiteTable){
    close(sfile)
    system(sitecommand)
    writeLines(paste("*** DATABASE ACTION ***: Updating stations table in AMET database:",mysqldbase))
    system(paste("rm -f ",tmpquery_file))
  }
  writeLines(paste("Total sites in current observation dataset:",sitenum+nsites_outside_domain)) 
  writeLines(paste("Num sites excluded because outside of MPAS domain:",nsites_outside_domain))
  writeLines(paste("Finished: Mapping observation sites to MPAS grid. Number of sites mapped:",sitenum))

  supdate<-list(sitelist=sitelist, sitenum=sitenum, cind=cind, cwgt=cwgt)
  return(supdate)
 }
#####--------------------------	   END OF FUNCTION: MPAS_SITE_MAP      -------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------     START OF FUNCTION: WRF_SITE_MAP     ------------------------------####
# A Mapping of observations sites to the WRF/MCIP/UFS grid. The sitelist and mapping/interpolation
# values are only updated as new sites are found in order to make script as efficient as possible.
# Note: this function orginally for WRF also works with MCIP and NOAA UFS, given proper projection.
#
# Input:
#       site           -- An array of current hour observation site ids
#       sites_unique   -- Unique sites for the current hour
#       sitelist       -- Master list of site ids preserved throughout the AMET run
#       sitenum        -- Number of unique sites in sitelist
#       slat           -- Latitude of sites in hourly site array
#       slon           -- Longitude of sites in hourly site array
#       elev           -- Site elevation (m)
#       report_type    -- Longitude of sites in hourly site array
#       site_locname   -- String describing site location (i.e, for KRDU 'Raleigh-Durham, NC')
#       proj           -- Model Domain projection. 1- Lambert, 2-Polar Stero, 3-Mercator, 4-Lat-Lon
#       wrfind         -- Index mapping to site array with interpolation weights 
#       interp         -- Interpolation option. 1-Nearest Neighbor, 2-Smart Bi-linear
#       mysqldbase     -- mysql database connection list for site update query
#       sitecommand    -- mysql command to push query file to server
#       sitemax        -- Maximum number of unique sites. Currently MADIS has ~4500 global sites
#       updateSiteTable-- Update AMET database (stations table) with any new sites. 
#       buffer         -- Optional - # of Grid cells from domain boundary where sites are rejected
#       mastermeta_file-- Optional - master site metadata file name 
#       tmpquery_file  -- Optional - site update query file name
#
# Output: List of update site information
#         supdate<-list(sitelist=sitelist, sitenum=sitenum, wrfind=wrfind)


 wrf_site_map <-function(site, sites_unique, sitelist, sitenum, slat, slon,
                         elev, report_type, site_locname, proj, wrfind, 
                         interp, mysqldbase, sitecommand, sitemax=15000, 
                         updateSiteTable=F, buffer=5, mastermeta_file="xxxyyyvv",
                         tmpquery_file="tmp.site.query", madis_dset="metar") {

  # If update site table open temporary site query file
  if(updateSiteTable) {
    system(paste("rm -f ",tmpquery_file)) 
    sfile<-file(tmpquery_file,"a")
    writeLines(paste("use",mysqldbase,";"),con=sfile) 
    use.metafile  <-F
    if(file.exists(mastermeta_file) & madis_dset!="text") {
      load(mastermeta_file)
      use.metafile<-T
    }
  }

  # Find range of lat-lon to exclude sites outside of domain. Adjust the
  range_lat<-range(proj$lat)
  range_lon<-range(proj$lon)
  
  writeLines("Mapping MADIS obs sites to WRF/MCIP/UFS grid") 
  nsr <- length(sites_unique)
  nsites_outside_domain<-0 
  for(s in 1:nsr) {
    if(sites_unique[s] %in% sitelist){ next }
    inds             <-which(sites_unique[s] == site)[1]    
    # Simple QA on site lat lon values. Some mesonet files have bad site locations.
    if(is.na(slat[inds]) || is.na(slon[inds])) { next }
    if(abs(slat[inds]) > 90 || abs(slon[inds]) > 360) { next }

    if(proj$mproj == 1) {
      grdind  <-lamb_latlon_to_ij(proj$lat1, proj$lon1, 1, 1, proj$truelat1, proj$truelat2, proj$standlon,
                                  proj$dx, slat[inds], slon[inds], radius= 6370000.0)
    }
    if(proj$mproj == 2) {
      grdind  <-polars_latlon_to_ij(proj$lat1, proj$lon1, proj$dx, proj$truelat1, proj$standlon,  
                                    slat[inds], slon[inds], radius= 6370000.0)
    }
    if(proj$mproj == 3) {
      grdind  <-mercat_latlon_to_ij(proj$lat1, proj$lon1, proj$lat, proj$lon, proj$dx, 
                                    proj$truelat1, slat[inds], slon[inds], radius= 6370000.0)
    }
    if(proj$mproj == 4) {
      grdind  <-latlon_latlon_to_ij(proj$lat, proj$lon, slat[inds], slon[inds])
    }

    if(grdind$i < buffer || grdind$i > (proj$nx-buffer) || grdind$j < buffer || grdind$j > (proj$ny-buffer) ) { 
      nsites_outside_domain<-nsites_outside_domain+1
      #writeLines(paste(nsites_outside_domain,"Sites ****",sites_unique[s],"**** excluded because out of model domain"))
      next 
    }

    sitenum          <-sitenum+1
    sitelist[sitenum]<-sites_unique[s]
    try(if(sitenum>sitemax) stop("Error: sitenum > sitemax"))

    #difflat <- abs(proj$lat[grdind$i,grdind$j] - slat[inds])
    #difflon <- abs(proj$lon[grdind$i,grdind$j] - slon[inds])
    #writeLines(paste("Lat-lon COMPARE ",difflat, difflon, "--", proj$lat[grdind$i,grdind$j], proj$lon[grdind$i,grdind$j], "---", slat[inds], slon[inds]))

    # Using the closest model grid cell to each MADIS station, store the cell indices. For nearest neighbor interp
    # option 1, the closest index is used and the deviation is set to 0.0 so one calculation can be used
    # for both interp methods. Interp = 2 (bi-linear) the fractional i,j (dx/dy) are stored for weighting
    # the four grid points surrounding the obs site. 
    if (interp == 1) {	           # Nearest neighbor interpolation
      dx                 <- 0.0
      dy                 <- 0.0
      wrfind[sitenum,1,1]<- round(grdind$i)
      wrfind[sitenum,1,2]<- round(grdind$i)+1
      wrfind[sitenum,2,1]<- round(grdind$j)
      wrfind[sitenum,2,2]<- round(grdind$j)+1
      wrfind[sitenum,3,1]<- dx
      wrfind[sitenum,3,2]<- dy
    }
    if (interp == 2 ){             # Bi-linear 
      xo<-floor(grdind$i)
      yo<-floor(grdind$j)
      dx<- grdind$i - xo
      dy<- grdind$j - yo
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
          dy<- dy-0.5

      } else if(dx > 0.5 & dy < 0.5) {
          x1<- xo
          y1<- yo-1
          dx<- dx-0.5
          dy<- dy+0.5
      } else if(dx > 0.5 & dy > 0.5) {
          x1<- xo
          y1<- yo
          dx<- dx-0.5
          dy<- dy-0.5
      }

      wrfind[sitenum,1,1]<- x1
      wrfind[sitenum,1,2]<- x1+1
      wrfind[sitenum,2,1]<- y1
      wrfind[sitenum,2,2]<- y1+1
      wrfind[sitenum,3,1]<- dx
      wrfind[sitenum,3,2]<- dy
    }

    writeLines(paste("sitenum:",sitenum,"is",sitelist[sitenum],"at lat-lon: ",sprintf("%5.3f",slat[inds]),sprintf("%5.3f",slon[inds]),
                     "     Closest model grid cell: ",sprintf("%5.3f",wrfind[sitenum,1,1]), sprintf("%5.3f",wrfind[sitenum,2,1]),
                     sprintf("%5.3f",dx),sprintf("%5.3f",dy)))

    if(updateSiteTable){
      tmps    <- trimws(unlist(strsplit(site_locname[inds],','))[2])
      state   <- ifelse(is.na(unlist(strsplit(tmps,""))[1]),"99",substr(tmps,1,2))
      elevs   <- ifelse(is.na(elev[inds]),-9999.99,round(elev[inds]))
      country <-"99"
      if(use.metafile){
        sm<-which(sitelist[sitenum] == mastermeta[,1])[1]
        if(is.na(sm)) { next }
        if(sum(sm)>0) {
          elevs              <-ifelse(is.na(mastermeta[sm,2]),'NULL',round(as.numeric(mastermeta[sm,2])))
          site_locname[inds] <-ifelse(is.na(mastermeta[sm,3]) || nchar(trimws(mastermeta[sm,3]))==0,"99",mastermeta[sm,3])
          state              <-ifelse(is.na(mastermeta[sm,4]) || nchar(trimws(mastermeta[sm,4]))==0,"99",mastermeta[sm,4])
          country            <-ifelse(is.na(mastermeta[sm,5]) || nchar(trimws(mastermeta[sm,5]))==0,"99",mastermeta[sm,5])
          site_locname[inds] <-sub("'", "",site_locname[inds])
        }
      }
      if(madis_dset=="text"){
          site_locname[inds] <-"99"
          state              <-"99"
          country            <-"99"
          elevs              <--9999.99
      }
      writeLines(paste("Inserting site into AMET stations table (meta):",s,sites_unique[s],elevs,site_locname[inds], state, country, site_locname[inds], sep=" ** ")) 
      query<-paste("REPLACE into stations (stat_id, ob_network, common_name, state, lat, lon, elev, country) VALUES ('",sitelist[sitenum],"','",
                   report_type[inds],"','",site_locname[inds],"','",state,"',",slat[inds],",",slon[inds],",",elevs,",'",country,"')",sep="")
      writeLines(paste(query,";"),con=sfile)             
    }
  }
  if(updateSiteTable){
    close(sfile)
    system(sitecommand)
    writeLines(paste("*** DATABASE ACTION ***: Updating stations table in AMET database:",mysqldbase))
    system(paste("rm -f ",tmpquery_file))
  }
  writeLines(paste("Total sites in current observation dataset:",sitenum+nsites_outside_domain)) 
  writeLines(paste("Num sites excluded because outside of model domain:",nsites_outside_domain))
  writeLines(paste("Finished: Mapping observation sites to model grid. Number of sites mapped:",sitenum))
  supdate<-list(sitelist=sitelist, sitenum=sitenum, wrfind=wrfind)
  return(supdate)
 }
#####--------------------------	    END OF FUNCTION: WRF_SITE_MAP      -------------------------------####
##########################################################################################################


