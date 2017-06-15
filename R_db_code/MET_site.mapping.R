#######################################################################################################
#####################################################################################################
#                                                                 ################################
#     AMET Observation Site Mapping to Model Grid                 ###############################
#                                                                 ###############################
#       Version 2.0                                               ###############################
#       Date: April 18, 2017                                      ###############################
#       Contributors:Robert Gilliam                               ###############################
#                                                                 ###############################
#	Developed by the US Environmental Protection Agency	            ###############################
#                                                                 ################################
#####################################################################################################
#######################################################################################################
#
#  V2.0, 2017Apr18, Robert Gilliam: Initial Development
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
#     wrf_site_map    --> Builds sitelist, a master list of site ids that is updated each hour
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
#       report_type    -- Longitude of sites in hourly site array
#       site_locname   -- String describing site location (i.e, for KRDU 'Raleigh-Durham, NC')
#       lat            -- MPAS cell's latitudes
#       lon            -- MPAS cell's longitudes
#       latv           -- MPAS latitude of vertex cells
#       lonv           -- MPAS longitude of vertex cells
#       cells_on_vertex-- grid cell indicies of vertex cells 
#       cind           -- MPAS indices where observation site resides
#       cwgt           -- Barrycentric interpolation weights
#
# Output: Update site information
#         supdate<-list(sitelist=sitelist, sitenum=sitenum, cind=cind, cwgt=cwgt)

 mpas_site_map <-function(site, sites_unique, sitelist, sitenum, 
                          slat, slon, report_type, site_locname,
                          lat, lon, latv, lonv, cells_on_vertex,
                          cind, cwgt, mysqldbase, sitecommand, 
                          sitemax=15000, updateSiteTable=F) {

  # If update site table open temporary site query file
  if(updateSiteTable) {
    system("rm tmp.site.query") 
    sfile<-file("tmp.site.query","a")
    writeLines(paste("use",mysqldbase,";"),con=sfile) 
  }
  
  # Build site arrays with MPAS cell indices and barycentric weights, or
  # WRF i,j grid indices (only works for Lambert or PolarStereo projections
  writeLines("Mapping MADIS obs sites to MPAS grid") 
  nsr <- length(sites_unique) 
  for(s in 1:nsr) {
    if(sites_unique[s] %in% sitelist){ next }
    sitenum<-sitenum+1
    try(if(sitenum>sitemax) stop("Error: sitenum > sitemax"))
    sitelist[sitenum]<-sites_unique[s]
    inds <-which(sites_unique[s] == site)[1]
    dist <-sqrt( (latv - slat[inds])^2 + (cos(latv*pi/180)*(lonv - slon[inds]))^2)
    vmap <-which(dist==min(dist,na.rm=T), arr.ind = TRUE)

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
      writeLines(paste("Inserting sites into AMET stations table",s,nsr,sites_unique[s],site_locname[inds])) 
      query<-paste("REPLACE into stations (stat_id, ob_network, common_name, lat, lon) VALUES ('",sitelist[sitenum],"','",
                   report_type[inds],"','",site_locname[inds],"','",slat[inds],"','",slon[inds],"')",sep="")
      writeLines(paste(query,";"),con=sfile)             
    }
  }

  if(updateSiteTable){
    close(sfile)
    system(sitecommand)
    writeLines(paste("*** DATABASE ACTION ***: Updating stations table in AMET database:",mysqldbase))
  }

  writeLines(paste("Finished: Mapping observation sites to MPAS grid. Number of sites mapped:",sitenum))

  supdate<-list(sitelist=sitelist, sitenum=sitenum, cind=cind, cwgt=cwgt)
  return(supdate)
 }
#####--------------------------	   END OF FUNCTION: MPAS_SITE_MAP      -------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------     START OF FUNCTION: WRF_SITE_MAP     ------------------------------####
# A Mapping of observations sites to the WRF grid. The sitelist and mapping/interpolation
# values are only updated as new sites are found in order to make script as efficient as possible.
#
# Input:
#       site           -- An array of current hour observation site ids
#       sites_unique   -- Unique sites for the current hour
#       sitelist       -- Master list of site ids preserved throughout the AMET run
#       sitenum        -- Number of unique sites in sitelist
#       slat           -- Latitude of sites in hourly site array
#       slon           -- Longitude of sites in hourly site array
#       report_type    -- Longitude of sites in hourly site array
#       site_locname   -- String describing site location (i.e, for KRDU 'Raleigh-Durham, NC')
#       proj           -- WRF projection. 1- Lambert, 2-Polar Sterographic (not implemented yet)
#       wrfind         -- Index mapping to site array with interpolation weights 
#       interp         -- Interpolation option. 1-Nearest Neighbor, 2-Smart Bi-linear
#       sitemax        -- Maximum number of unique sites. Currently MADIS has ~4500 global sites
#       updateSiteTable-- Update AMET database (stations table) with any new sites. 
#       buffer         -- # of Grid cells from domain boundary where sites are rejected
#
# Output: List of update site information
#         supdate<-list(sitelist=sitelist, sitenum=sitenum, wrfind=wrfind)


 wrf_site_map <-function(site, sites_unique, sitelist, sitenum, slat, slon,
                         report_type, site_locname, proj, wrfind, 
                         interp, mysqldbase, sitecommand, sitemax=15000, 
                         updateSiteTable=F, buffer=5) {
  
  # If update site table open temporary site query file
  if(updateSiteTable) {
    system("rm tmp.site.query") 
    sfile<-file("tmp.site.query","a")
    writeLines(paste("use",mysqldbase,";"),con=sfile) 
  }

  # Find range of lat-lon to exclude sites outside of domain. Adjust the
  range_lat<-range(proj$lat)
  range_lon<-range(proj$lon)
  
  writeLines("Mapping MADIS obs sites to WRF grid") 
  nsr <- length(sites_unique)
  nsites_outside_domain<-0 
  for(s in 1:nsr) {
    if(sites_unique[s] %in% sitelist){ next }

    inds             <-which(sites_unique[s] == site)[1]    
    grdind           <-lamb_latlon_to_ij(proj$lat1, proj$lon1, 1, 1, proj$truelat1, proj$truelat2, 
                               proj$standlon, proj$dx, slat[inds], slon[inds], radius= 6370000.0)

    if(grdind$i < buffer || grdind$i > (proj$nx-buffer) || grdind$j < buffer || grdind$j > (proj$ny-buffer) ) { 
      nsites_outside_domain<-nsites_outside_domain+1
      writeLines(paste(nsites_outside_domain,"Sites ****",sites_unique[s],"**** excluded because out of WRF domain"))
      next 
    }

    sitenum          <-sitenum+1
    sitelist[sitenum]<-sites_unique[s]
    try(if(sitenum>sitemax) stop("Error: sitenum > sitemax"))

    # Using the closest WRF grid cell to each MADIS station, store the cell indices. For nearest neighbor interp
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
                      "     Closest WRF grid cell: ",sprintf("%5.3f",wrfind[sitenum,1,1]), sprintf("%5.3f",wrfind[sitenum,2,1]),
                      sprintf("%5.3f",dx),sprintf("%5.3f",dy)))

    if(updateSiteTable){
      writeLines(paste("Inserting sites into AMET stations table",s,nsr,inds,sites_unique[s],site_locname[inds])) 
      query<-paste("REPLACE into stations (stat_id, ob_network, common_name, lat, lon) VALUES ('",sitelist[sitenum],"','",
                   report_type[inds],"','",site_locname[inds],"','",slat[inds],"','",slon[inds],"')",sep="")
      writeLines(paste(query,";"),con=sfile)             
    }
  }
  if(updateSiteTable){
    close(sfile)
    system(sitecommand)
    writeLines(paste("*** DATABASE ACTION ***: Updating stations table in AMET database:",mysqldbase))
  }
  
  writeLines(paste("Finished: Mapping observation sites to WRF grid. Number of sites mapped:",sitenum))
  writeLines(paste("Num sites excluded because outside of WRF domain:",nsites_outside_domain))
  writeLines(paste("Total sites in current observation dataset:",sitenum+nsites_outside_domain)) 

  supdate<-list(sitelist=sitelist, sitenum=sitenum, wrfind=wrfind)
  return(supdate)
 }
#####--------------------------	    END OF FUNCTION: WRF_SITE_MAP      -------------------------------####
##########################################################################################################
