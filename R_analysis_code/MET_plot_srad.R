#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#                AMET (Atmospheric Model Evaluation Tool)               #
#                                                                       #
#                      SOLAR Radiation Analysis                         #
#                          MET_plot_srad.R                              #
#                                                                       #
#         Developed by the US Environmental Protection Agency           #
#-----------------------------------------------------------------------#
#########################################################################
# Version 1.2, May 8, 2013, Robert Gilliam                              #
#       This AMET script extracts a user specified set of solar         #
#       radiation (model and observations) data from a projects         #
#       surface table. The user can specify three plot modes.           #
#                                                                       #
#	1)      Diurnal box plot of model and observed distribution           #
#         of SRAD values that includes diurnal bias and error           #
#	2)      Spatial plots that provides value bias, variability           #
#         bias and error for 4 parts of the day                         #
#			    12-14 LST                                                     #
#			    15-17 LST                                                     #
#			    18-20 LST                                                     #
#			    21-23 LST                                                     #
# 3)     Time Series model-obs shortwave radiation at each site         #
#                                                                       #
# Version 1.4, Sep 30, 2018, Robert Gilliam                             #
#               Pulled from V1.2 and modified for BSRN observations     #
#               that are global. Main change is pulling site info       #
#               from the database with BSRN value for ob_network        #
#               instead of hard coded values in plot_srad.input.        #
#               Diurnal plots were modified to center the plot around   #
#               solar noon for each site since it was updated for       #
#               global MPAS output. Also, histogram plots were added    #
#               to analyze the model-obs distribution properties.       #
#                                                                       #
#########################################################################
#	Load required modules
  if(!require(RMySQL)) {stop("Required Package RMySQL was not loaded")}
  if(!require(date))   {stop("Required Package date was not loaded")  }
  if(!require(fields)) {stop("Required Package fields was not loaded")}
  if(!require(maps))   {stop("Required Package maps was not loaded")}
  if(!require(mapdata)){stop("Required Package mapdata was not loaded")}

#########################################################################
#    Initialize AMET Diractory Structure Via Env. Vars
#    AND Load required function and conf. files
#########################################################################
 ## Get environmental variables and setup main AMET directories and files
 ametbase         <- Sys.getenv("AMETBASE")
 ametR            <- paste(ametbase,"/R_analysis_code",sep="")
 ametRinput       <- Sys.getenv("AMETRINPUT")
 mysqlloginconfig <- Sys.getenv("MYSQL_CONFIG")

 ## source some configuration files, AMET libs, and input
 source (paste(ametR,"/MET_amet.misc-lib.R",sep=""))
 source (paste(ametR,"/MET_amet.plot-lib.R",sep=""))
 source (paste(ametR,"/MET_amet.stats-lib.R",sep=""))
 source (mysqlloginconfig)
 source (ametRinput)

 ametdbase1   <- Sys.getenv("AMET_DATABASE")
 ametdbase2   <- Sys.getenv("AMET_DATABASE2")
 mysqlserver  <- Sys.getenv("MYSQL_SERVER")
 mysql1       <- list(server=mysqlserver,dbase=ametdbase1,login=amet_login,
                      passwd=amet_pass,maxrec=maxrec)
 mysql2       <- list(server=mysqlserver,dbase=ametdbase2,login=amet_login,
                      passwd=amet_pass,maxrec=maxrec)

#########################################################################
#					Main Program     	   
#########################################################################

 # Set up date specs and query of SRAD data from MySQL
 d1     <-paste(ys,dform(ms),dform(ds),sep="")
 d2     <-paste(ye,dform(me),dform(de),sep="")
 query1 <- paste("SELECT  DATE_FORMAT(d.ob_date,'%Y%m%d'),HOUR(d.ob_date), d.stat_id,s.lat, s.lon,",
               "d.SRAD_mod, d.SRAD_ob FROM ",project1,"_surface d, stations s  WHERE d.stat_id=s.stat_id ", 
               "AND s.ob_network='BSRN' AND d.SRAD_ob > 0 AND d.ob_date BETWEEN ",d1," AND ",d2, extra, sep="")
# query1 <- paste("SELECT  DATE_FORMAT(d.ob_date,'%Y%m%d'),HOUR(d.ob_date), d.stat_id,s.lat, s.lon,",
#               "d.SRAD_mod, d.SRAD_ob FROM ",project1,"_surface d, stations s  WHERE d.stat_id=s.stat_id ", 
#               "AND s.ob_network='BSRN' AND d.SRAD_ob > 0 AND (d.ob_date < ",d1," OR d.ob_date > ",d2,")", extra, sep="")
 query2 <- paste("SELECT  DATE_FORMAT(d.ob_date,'%Y%m%d'),HOUR(d.ob_date), d.stat_id,s.lat, s.lon,",
               "d.SRAD_mod, d.SRAD_ob FROM ",project2,"_surface d, stations s  WHERE d.stat_id=s.stat_id ", 
               "AND s.ob_network='BSRN' AND d.SRAD_ob > 0 AND d.ob_date BETWEEN ",d1," AND ",d2, extra, sep="")
 writeLines(paste(query1))
 data1  <-ametQuery(query1,mysql1)
 sens   <- TRUE
 if(project2 =="") {
  sens <- FALSE
 }
 # Hard code turn off of sensitivity for now.
 sens <- FALSE

 # Load data from sensitivity run if specified
 if(sens) {
   data2  <-ametQuery(query2,mysql2)
 }

 ## test to see if query returned anything
 if (dim(data1)[1] < 24) {
  writeLines("ERROR: query returned either no results or fewer than one day of data.")
  writeLines("       Check settings, specifically start and end dates")
  quit(save="no")
 }

 # Set column index locations for data from query. 
 # Define hour start and end for binned statistics.
 hr_loc     <- 2
 id_loc     <- 3
 lat_loc    <- 4
 lon_loc    <- 5
 sr_mod_loc <- 6
 sr_ob_loc  <- 7
 tod.label  <- c("eary-morning","mid-morning","early-afternoon","late-afternoon")
 nhrbin     <- length(tod.label)
 # Determine number of unique sites and their information from main project
 sites <- unique(data1[,id_loc])
 nsites<- length(sites)
 lon   <- array(NA,c(nsites))
 lat   <- array(NA,c(nsites))
 for(s in 1:nsites) {
  inds   <- which(data1[,id_loc] == sites[s])[1]
  lat[s] <- data1[inds,lat_loc]
  lon[s] <- data1[inds,lon_loc]
 }
 # Determine number of unique sites and their information from sensitivity
 sites_common<-""
 if(sens) {
   sites2  <- unique(data2[,id_loc])
   nsites2 <- length(sites2)
   lon2    <- array(NA,c(nsites2))
   lat2    <- array(NA,c(nsites2))
   for(s in 1:nsites2) {
     inds    <- which(data2[,id_loc] == sites2[s])[1]
     lat2[s] <- data2[inds,lat_loc]
     lon2[s] <- data2[inds,lon_loc]
   }
   sites_common<-intersect(sites,sites2)
 }
 # Compare two runs and set up sites in both domains
 #
 #nsitesc     <-length(sites_common)
 #lonc        <-array(NA,c(nsitesc))
 #latc        <-array(NA,c(nsitesc))
 #for(s in 1:nsitesc){
 #  inds  <-which(sites_common[s] == sites)[1]
 #}

##############################################################################################
 # Do spatial plot mode if specified in namelist
if(spatial) {

  writeLines(paste("Spatial Statistic Plots",sep=""))
  # Define sites and location then prepare statistics arrays
  stat_array <- array(NA,c(nsites,7,nhrbin))
  index      <- 1:length(data1[,id_loc])

  # LOOP over sites and hours bins over the daytime
  for(s in 1:nsites) {

    mask     <- index[sites[s] == data1[,id_loc] ]
    max_rad  <- max(data1[mask,sr_mod_loc],na.rm=T)
    ind_max  <- which(max_rad == data1[mask,sr_mod_loc])
    utc_max  <- data1[mask[ind_max],hr_loc]

    h1       <- c(utc_max - (2* delt), utc_max- delt, utc_max, utc_max+delt)
    h2       <- c(utc_max- delt, utc_max, utc_max+delt, utc_max + (2* delt))
    h2_plot  <- h2-1

    writeLines(paste("Computing spatial statistics for site:",sites[s],s,"of",nsites," --- Centering array around solar noon ~",utc_max))
    for(hh in 1:nhrbin) {
      mask               <- index[sites[s] == data1[,id_loc] & (data1[,hr_loc] >= h1[hh] & data1[,hr_loc] < h2[hh]) ]
      stat_array[s,1,hh] <- mean(data1[mask,sr_ob_loc], na.rm=T)
      stat_array[s,2,hh] <- mean(data1[mask,sr_mod_loc], na.rm=T)
      stat_array[s,3,hh] <- magerror(data1[mask,sr_ob_loc], data1[mask,sr_mod_loc], na.rm=T)
      stat_array[s,4,hh] <- mbias(data1[mask,sr_ob_loc], data1[mask,sr_mod_loc], na.rm=T)
      stat_array[s,5,hh] <- rmserror(data1[mask,sr_ob_loc], data1[mask,sr_mod_loc], na.rm=T)
      stat_array[s,6,hh] <- sd(data1[mask,sr_ob_loc], na.rm=T)
      stat_array[s,7,hh] <- sd(data1[mask,sr_mod_loc], na.rm=T)       
    }
  }
  stat_array <- ifelse(is.nan(stat_array),NA,stat_array)
  #-------------------------------------------------------------------------------  

  #-------------------------------------------------------------------------------
  # Generate Spatial Plot
  for(hr in 1:nhrbin) {

    figure <- paste(figdir,"/srad.spatial.",tod.label[hr],".",d1,"-",d2,sep="")
    writeLines(paste(figure,".pdf",sep=""))
    pdf(file= paste(figure,".pdf",sep=""), width = 10, height = 5)
     
     # OLD color scheme. Too much green in the center of the scale.
     colBIAS <-rev(rainbow(length(levsBIAS)))
     colRMSE <-rev(rainbow(length(levsRMSE)))
     colSDEV <-rev(rainbow(length(levsSDEV)))
     colMAE  <-rev(rainbow(length(levsMAE)))

     # Default color that works the best in Rob's opinion.
     colBIAS <-tim.colors(length(levsBIAS))
     colRMSE <-tim.colors(length(levsRMSE))
     colSDEV <-tim.colors(length(levsSDEV))
     colMAE  <-tim.colors(length(levsMAE))
     
     pcolsBIAS	<-colBIAS[cut(stat_array[,4,hr],br=levsBIAS,labels=FALSE,include.lowest=T)]
     pcolsRMSE	<-colRMSE[cut(stat_array[,5,hr],br=levsRMSE,labels=FALSE,include.lowest=T)]
     pcolsSDEV	<-colSDEV[cut(stat_array[,7,hr]-stat_array[,6,hr],br=levsSDEV,labels=FALSE,include.lowest=T)]
     pcolsMAE	<-colMAE[cut(stat_array[,3,hr],br=levsMAE,labels=FALSE,include.lowest=T)]
 
     par(mfrow=c(2,2))
     par(mai=c(0,0,0,0))
     #------------------------------------------------------------------------------------------------------------
     #  Plot Spatial Solar Radiation Bias
     title   <-"Shortwave Radiation Bias (W/m^2)"
     infolab <-""
     #m<-map('usa',plot=FALSE)
     #map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
     map("world", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
     #map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65), add=T)
     points(lon,lat,pch=plotopts$symb, cex=plotopts$symbsiz, col=pcolsBIAS)
     points(lon,lat,pch=plotopts$symbo, cex=plotopts$symbsiz, col="black")
     legend(lonw,lats,format(levsBIAS,digit=2),col=colBIAS,fill=F,pch=plotopts$symb,
            xjust=0,yjust=0,bg='white',y.intersp=.75,pt.cex=0.55,cex=0.55,pt.bg="white",bty=T,horiz=F)
     title(title,sub=infolab,line=1, cex.sub=0.5)
     box(which="figure")
     writeLines(" ------------------- ********************* -------------------------- ********************")
     #------------------------------------------------------------------------------------------------------------
     #  Plot Spatial Radiation MAE
     title   <-"Shortwave Radiation MAE (W/m^2)"
     infolab <-""
     #m<-map('usa',plot=FALSE)
     map("world", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
     #map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
     #map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65), add=T)
     points(lon,lat,pch=plotopts$symb, cex=plotopts$symbsiz, col=pcolsMAE)
     points(lon,lat,pch=plotopts$symbo, cex=plotopts$symbsiz, col="black")
     legend(lonw,lats,format(levsMAE,digit=2),col=colMAE,fill=F,pch=plotopts$symb,
           xjust=0,yjust=0,bg='white',y.intersp=.75,pt.cex=0.55,cex=0.55,pt.bg="white",bty=T,horiz=F)
     title(title,sub=infolab,line=1, cex.sub=0.5)
     box(which="figure")
     #------------------------------------------------------------------------------------------------------------
     #  Plot Spatial RMSE 
     title   <-"Shortwave Radiation RMSE (W/m^2)"
     infolab <-""
     #m<-map('usa',plot=FALSE)
     map("world", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
     #map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
     #map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65), add=T)
     points(lon,lat,pch=plotopts$symb, cex=plotopts$symbsiz, col=pcolsRMSE)
     points(lon,lat,pch=plotopts$symbo, cex=plotopts$symbsiz, col="black")
     legend(lonw,lats,format(levsRMSE,digit=2),col=colRMSE,fill=F,pch=plotopts$symb,
           xjust=0,yjust=0,bg='white',y.intersp=.75,pt.cex=0.55,cex=0.55,pt.bg="white",bty=T,horiz=F)
     title(title,sub=infolab,line=1, cex.sub=0.5)
     box(which="figure")
     #------------------------------------------------------------------------------------------------------------
     #------------------------------------------------------------------------------------------------------------
     #  Plot Std. Dev difference 
     title   <-"Shortwave Radiation SDEV Difference (W/m^2)"
     infolab <-""
     #m<-map('usa',plot=FALSE)
     #map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
     map("world", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
     #map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65), add=T)
     points(lon,lat,pch=plotopts$symb, cex=plotopts$symbsiz, col=pcolsSDEV)
     points(lon,lat,pch=plotopts$symbo, cex=plotopts$symbsiz, col="black")
     legend(lonw,lats,format(levsSDEV,digit=2),col=colSDEV,fill=F,pch=plotopts$symb,
           xjust=0,yjust=0,bg='white',y.intersp=.75,pt.cex=0.55,cex=0.55,pt.bg="white",bty=T,horiz=F)
     title(title,sub=infolab,line=1, cex.sub=0.5)
     box(which="figure")
     #------------------------------------------------------------------------------------------------------------
     dev.off()
     #-------------------------------------------------------------------------------   
   }
   figure<-paste(figdir,"/BSRN.SITE.PLOT",sep="")
   writeLines(paste(figure,".pdf",sep=""))
   pdf(file= paste(figure,".pdf",sep=""), width = 10, height = 5)
   title   <-"Map of BSRN Sites"
   infolab <-""
   map("world", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
   text(lon,lat,sites,col="red",cex=0.75)
   title(title,sub=infolab,line=1, cex.sub=0.5)
   box(which="figure")
   dev.off()

}
##############################################################################################

##############################################################################################
 # Do diurnal plot mode if specified in namelist
if(diurnal) {

 writeLines(paste("Diurnal Statistic Plots",sep=""))
 # LOOP through each site and generates stats and plots  
 for(ss in 1:nsites){

  # Define sites and location then prepare statistics arrays
  stat_array_diurnal  <- array(NA,c(7,24))
  stat_array_diurnal2 <- array(NA,c(7,24))
  hour_obs_utc        <- array(NA,c(24))
  index               <-1:length(data1[,id_loc])
  col.headers         <-c("HOUR_UTC","BSRN","MODEL","RMSE","MAE","BIAS","SD_OBS","SD_MOD")
  for(hh in 1:24) {     
    hour_obs_utc[hh]         <- hh-1
    mask_obs                 <- data1[,hr_loc] == hour_obs_utc[hh] & data1[,id_loc] == sites[ss]
    mask_mod                 <- mask_obs     
    stat_array_diurnal[1,hh] <- mean(data1[mask_obs,sr_ob_loc],na.rm=T)
    stat_array_diurnal[2,hh] <- mean(data1[mask_mod,sr_mod_loc],na.rm=T)
    stat_array_diurnal[3,hh] <- rmserror(data1[mask_obs,sr_ob_loc], data1[mask_mod,sr_mod_loc], na.rm=T)
    stat_array_diurnal[4,hh] <- magerror(data1[mask_obs,sr_ob_loc], data1[mask_mod,sr_mod_loc], na.rm=T)
    stat_array_diurnal[5,hh] <- mbias(data1[mask_obs,sr_ob_loc], data1[mask_mod,sr_mod_loc], na.rm=T)
    stat_array_diurnal[6,hh] <- sd(data1[mask_obs,sr_ob_loc], na.rm=T)
    stat_array_diurnal[7,hh] <- sd(data1[mask_mod,sr_mod_loc], na.rm=T)        

    # See if sensitivity run was activated and current site is in both model domains.
    # Only compute mean
    compsite                 <- which(sites[ss] == sites_common)
    if(length(compsite) > 0) {
      mask_obs2                <- data2[,hr_loc] == hour_obs_utc[hh] & data2[,id_loc] == sites[ss]
      mask_mod2                <- mask_obs     
      stat_array_diurnal2[1,hh]<- mean(data2[mask_obs2,sr_ob_loc],na.rm=T)
      stat_array_diurnal2[2,hh]<- mean(data2[mask_mod2,sr_mod_loc],na.rm=T)
    }
  }
  obs.check <-sum(stat_array_diurnal[1,],na.rm=T)
  mod.check <-sum(stat_array_diurnal[2,],na.rm=T)
  if(obs.check < 24 || mod.check < 24) { next}
  stat_array_diurnal          <-ifelse(is.nan(stat_array_diurnal),NA,stat_array_diurnal)
  stat_array_diurnal2         <-ifelse(is.nan(stat_array_diurnal2),NA,stat_array_diurnal2)
  stat_array_diurnal_centered <-stat_array_diurnal*NA
  stat_array_diurnal_centered2<-stat_array_diurnal*NA

  # Reorder array to center around max radiation (solar noon) time of day
  max_hr_loc    <- which(stat_array_diurnal[2,] == max(stat_array_diurnal[2,],na.rm=T))
  offset        <-hour_obs_utc[max_hr_loc]
  hr_center_map <- 12

  hour_obs_utc_centered <- hour_obs_utc + (hr_center_map+offset)

  for(hh in 1:24) {
    if(hour_obs_utc_centered[hh] < 24) { 
      hour_obs_utc_centered[hh]  <- hour_obs_utc_centered[hh]
    }
    if(hour_obs_utc_centered[hh] >= 24 & hour_obs_utc_centered[hh] < 48) { 
      hour_obs_utc_centered[hh]  <- hour_obs_utc_centered[hh] -24
    }
    if(hour_obs_utc_centered[hh] >= 48 ) { 
      hour_obs_utc_centered[hh]  <- hour_obs_utc_centered[hh] -48
    }
    mapind <- which(hour_obs_utc_centered[hh] == hour_obs_utc)
    stat_array_diurnal_centered[,hh]<-stat_array_diurnal[,mapind]
    stat_array_diurnal_centered2[,hh]<-stat_array_diurnal2[,mapind]
   }

  # Overwrite UTC-based array of statistics with Centered.
  stat_array_diurnal  <-stat_array_diurnal_centered
  stat_array_diurnal2 <-stat_array_diurnal_centered2

  #################################################################################################################################
  #	GENERATE DIURNAL STATISTICS PLOT
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  figure<-paste(figdir,"/srad.diurnal.",sites[ss],".",d1,"-",d2,sep="")
  if (textstats){   
    textout.df  <-data.frame(hour_obs_utc_centered,t(ifelse(is.na(stat_array_diurnal),0,stat_array_diurnal)))
    textout.file<-paste(figure,".csv",sep="")
    write.table(textout.df,textout.file,sep=",",col.names=col.headers, 
                row.names=F, quote=FALSE)
  }
  writeLines(paste(figure,".pdf",sep=""))
  pdf(file= paste(figure,".pdf",sep=""), width = 10, height = 5)
  #:::::::::::::::::::::::::::::::::::::::::::::::
  par(mfrow=c(3,1))
  par(mai=c(0.00,0.40,0.05,0.05))
  par(mgp=c(1.0,0.10,0))
  par(tcl=0.50)
    
  hr   <-seq(0,23)
  xlim <-c(0,23)

  #######################################################################
  #   Plot top panel of 3-panel plot (Mean radiation of mod and obs)
  ylim <- c(0,range(stat_array_diurnal[1:2,],na.rm=T)[2])
  ylabs<- seq(0,ceiling(ylim[2]/100)*100,by=100)
    
  linecols <-c("black","red")
  linetype <-c(1,1,1)
  pchtype  <-c(0,1,1)
  leglab   <-c("BSRN","Model")

  par(new=FALSE)
  plot(hr,stat_array_diurnal[1,],xlim=xlim, ylim=ylim,xlab="Time of Day",ylab=paste("Mean Shortwave(W/m^2) ",sep=""),
         label=F,tick=F,lty=linetype[1],pch=pchtype[1],col=linecols[1],type="l",lwd=1, axes=F)   		

  par(tck=1)
  axis(1,at=hr,labels=hour_obs_utc_centered,cex=1.25,col="gray",lty=1)
  axis(2,at=ylabs,labels=ylabs,cex=1.25,col="gray",lty=1)
    
  par(new=TRUE)
  plot(hr,stat_array_diurnal[1,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
       lty=linetype[1],pch=pchtype[1],col=linecols[1],type="l",lwd=1, axes=F)   		

  par(new=TRUE)
  plot(hr,stat_array_diurnal[2,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[2],pch=pchtype[2],col=linecols[2],type="l",lwd=1, axes=F)   		
        
  if(sens){
    linecols <-c("black","red","blue","gray")
    leglab   <-c("BSRN","Model1","Model2")
    par(new=TRUE)
    plot(hr,stat_array_diurnal2[2,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[3],pch=pchtype[3],col=linecols[3],type="l",lwd=1, axes=F)   		
    par(new=TRUE)
    plot(hr,stat_array_diurnal2[1,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[3],pch=pchtype[3],col=linecols[4],type="l",lwd=1, axes=F)   		
  }

  legend( 1, ylim[2]+(ylim[2]*0.04), leglab, col = linecols, 
         lty = 1, bg="white", pch=NA, xjust=0, yjust=1)
  box()
  #######################################################################
  #######################################################################
  #   Plot middle panel of 3-panel plot (BIAS, RMSE and MAE)
  ylim <- range(stat_array_diurnal[3:5,],na.rm=T)
  ylabs<- seq(0,ceiling(ylim[2]/100)*100,by=100)
    
  linecols <-c(2,3,4)
  linetype <-c(1,1,1)
  pchtype  <-c(0,1,2)
  leglab   <-c("BIAS","RMSE","MAE")

  par(new=FALSE)
  plot(hr,stat_array_diurnal[5,],xlim=xlim, ylim=ylim,xlab="Time of Day",ylab=paste("Evaluation Metrics(W/m^2) ",sep=""),
       label=FALSE,tick=FALSE,lty=linetype[1],pch=pchtype[1],col=linecols[1],type="l",lwd=1, axes=F)   		

  par(tck=1)
  axis(1,at=hr,labels=NA,cex=1.25,col="gray",lty=1)
  axis(2,cex=1.25,col="gray",lty=1)
    
  par(new=TRUE)
  plot(hr,stat_array_diurnal[5,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[1],pch=pchtype[1],col=linecols[1],type="l",lwd=1, axes=F)   		
  par(new=TRUE)
  plot(hr,stat_array_diurnal[3,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[2],pch=pchtype[2],col=linecols[2],type="l",lwd=1, axes=F)   		
  par(new=TRUE)
  plot(hr,stat_array_diurnal[4,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[3],pch=pchtype[3],col=linecols[3],type="l",lwd=1, axes=F)   		
        
  legend( 1, ylim[2]+(ylim[2]*0.04), leglab, col = linecols, 
           lty = 1, bg="white", pch=NA, xjust=0, yjust=1)
  lines(c(-1,24),c(0,0),lwd=2)       
  box()
  #######################################################################
  #######################################################################
  #   Plot top panel of 3-panel plot (Mean radiation of mod and obs)
  par(mai=c(0.35,0.40,0.05,0.05))
  par(mgp=c(0.90,0.10,0))

  ylim <- c(0,range(stat_array_diurnal[6:7,],na.rm=T)[2])
  ylabs<- seq(0,ceiling(ylim[2]/100)*100,by=100)
    
  linecols <-c(4,2)
  linetype <-c(1,1)
  pchtype  <-c(0,1)
  leglab   <-c("BSRN","Model")

  par(new=FALSE)
  plot(hr,stat_array_diurnal[6,],xlim=xlim, ylim=ylim,xlab="Time of Day",ylab=paste("Variability (W/m^2) ",sep=""),
         label=FALSE,tick=FALSE,lty=linetype[1],pch=pchtype[1],col=linecols[1],type="l",lwd=1, axes=F)   		

  par(tck=1)
  axis(1,at=hr,labels=hour_obs_utc_centered,cex=1.25,col="gray",lty=1)
  axis(2,at=ylabs,labels=ylabs,cex=1.25,col="gray",lty=1)
    
  par(new=TRUE)
  plot(hr,stat_array_diurnal[6,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[1],pch=pchtype[1],col=linecols[1],type="l",lwd=1, axes=F)   		

  par(new=TRUE)
  plot(hr,stat_array_diurnal[7,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[2],pch=pchtype[2],col=linecols[2],type="l",lwd=1, axes=F)   		
        
  legend( 1, ylim[2]+(ylim[2]*0.04), leglab, col = linecols, 
           lty = 1, bg="white", pch=NA, xjust=0, yjust=1)
  box()
  #######################################################################

  #------------------------------------------------------------------------------------------------------------
  dev.off()
  #-------------------------------------------------------------------------------
 }  #END LOOP OVER SITES

}
##############################################################################################
if(timeseries) {

 writeLines(paste("Timeseries plots",sep=""))
 # LOOP through each site and generates stats and plots  
 for(ss in 1:nsites){ 
   mask  <- data1[,id_loc] == sites[ss] 
   day   <- data1[mask,1]
   timex <- data1[mask,2]
   obs   <- data1[mask,sr_ob_loc]
   mod   <- data1[mask,sr_mod_loc]
    
   iso.date <- ISOdatetime(year=as.numeric(substr(day,1,4)), month=as.numeric(substr(day,5,6)), 
                           day=as.numeric(substr(day,7,8)),  hour=as.numeric(timex), min=0, sec=0, tz="GMT")
	                         
   date.vec  <-seq(min(iso.date),max(iso.date),by="hour")
   ts.length <-length(date.vec)
   ts.values <-array(0,c(ts.length,2))
   for(tt in 1:ts.length){
     mask2   <- iso.date == date.vec[tt]
     nsample <-sum(ifelse(mask2,1,0),na.rm=T)
     if(nsample == 1) {
       ts.values[tt,1]<-obs[mask2]
       ts.values[tt,2]<-mod[mask2]
     }  
   }
	  
   figure<-paste(figdir,"/srad.timeseries.",sites[ss],".",d1,"-",d2,sep="")
   if (textstats){   
     textout.df  <-data.frame(date.vec,ts.values)
     textout.file<-paste(figure,".csv",sep="")
     write.table(textout.df,textout.file,sep=",",col.names=c("Date","BSRN","MODEL"), 
                row.names=F, quote=FALSE)
   }
   writeLines(paste(figure,".pdf",sep=""))
   pdf(file= paste(figure,".pdf",sep=""), width = 10, height = 5)

   par(bg="white")
   par(fg="black")
   tscols<-c("red","blue") 	
  
   val<-ts.values
   vallab<-"Global Shorwave Radiation (W m^2)"
   miny<-min(val,na.rm=TRUE)-2;
   maxy<-max(val,na.rm=TRUE);
   dy<-0.09*(maxy-miny);ps1<-maxy-dy;ps2<-ps1-dy;ps3<-ps2-dy
    ##############################################################
   plot(date.vec,val[,1],xlab="",ylab=vallab,xlim=range(date.vec),ylim=c(miny,maxy),axes =F,
        pch=4,cex=0.75,col=tscols[1],vfont=c("serif","bold"),label=TRUE,type="l",lwd=1, bg="yellow")
   par(tck=1)
   axis(2,col="black",lty=3)
   par(tck=1)
   axis(1,col="black",lty=3,at=date.vec[seq(1,length(date.vec),by=24)],labels=as.character(date.vec[seq(1,length(date.vec),by=24)]))
   par(new=T)
   plot(date.vec,val[,2],xlim=range(date.vec),ylim=c(miny,maxy),label=FALSE,tick=FALSE,axes =F,
        type="l",pch=5,col=tscols[2],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
   title("BSRN-Model Time Series",line=-1,outer=T)
   legend(date.vec[1],maxy,c("BSRN Obs","Model"),col=tscols,lty=1,lwd=2,cex=0.90,xjust=.20)
   #------------------------------------------------------------------------------------------------------------
   dev.off()
   #-------------------------------------------------------------------------------
  }  #END LOOP OVER SITES
}
##############################################################################################
##############################################################################################
if(histogram) {

 writeLines(paste("Model-Obs Histogram plots",sep=""))
 # LOOP through each site and generates stats and plots  
 for(ss in 1:nsites){ 
   mask  <- data1[,id_loc] == sites[ss] 
   day   <- data1[mask,1]
   timex <- data1[mask,2]
   obs   <- data1[mask,sr_ob_loc]
   mod   <- data1[mask,sr_mod_loc]
    	  
   figure<-paste(figdir,"/srad.histogram.",sites[ss],".",d1,"-",d2,".pdf",sep="")
   writeLines(paste(figure,sep=""))
   pdf(file= figure, width = 10, height = 12, pointsize=16)

   par(mfrow=c(3,1))
   par(bg="white")
   par(fg="black")

   title.lab <-paste("Distribution of Shortwave Radiation  Site:",sites[ss],"  Date:",d1,"-",d2,sep="")
   ### BOXPLOT of Differences
   par(mai=c(0.75,0.75,0.5,0.5))
   par(mai=c(0.5,0.5,0.25,0.25))
   par(mgp=c(2,0.7,0))
   obs      <-ifelse(obs > 1361, NA, obs)
   mod      <-ifelse(mod > 1361, NA, mod)
   obs      <-ifelse(obs < 0, 0, obs)
   mod      <-ifelse(mod < 0, 0, mod)
   a        <-hist(obs,breaks=seq(0,1400,by=100), plot = F)  
   b        <-hist(mod,breaks=seq(0,1400,by=100), plot = F) 
   maxcount <- max( a$counts, b$counts, na.rm=T) 
   hist(obs,breaks=seq(0,1400,by=100),ylim=c(0,maxcount), freq=T,ylab="Count",
        xlab=paste("BSRN SWRad(W/m^2)"),main="", plot = T)  
   title(title.lab)
   hist(mod,breaks=seq(0,1400,by=100),ylim=c(0,maxcount), freq=T,ylab="Count",
        xlab=paste("Model SWRad(W/m^2)"),main="", plot = T)  
   plot(a$mids,b$counts-a$counts,type='b',ylab="Model-BSRN Count",xlab="SWRad(W/m^2)")
   lines(c(1400,0),c(0,0),col="gray",lwd=2)
   #------------------------------------------------------------------------------------------------------------
   dev.off()
   #-------------------------------------------------------------------------------
 }  #END LOOP OVER SITES

}
##############################################################################################


