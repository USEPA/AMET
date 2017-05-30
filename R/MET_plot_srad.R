#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#		AMET (Atmospheric Model Evaluation Tool)                            #
#                                                                       #
#			SOLAR Radiation Analysis SCRIPT			                              #
#			    MET_plot_srad.R			 	                                        #
#                                                                       #
#                                                                       #
#	This AMET script extracts a user specified set of solar		            #
#	radiation (model and observations) data from a projects		            #
#	surface table. The user can specify three plot modes.		              #
#	1) 	Diurnal box plot of model and observed distribution	              #
#		of SRAD values that includes diurnal bias and error                 #
#	2)	Spatial plots that provides value bias, variability               #
#		bias and error for 4 parts of the day			                          #
#			12-14 UTC					                                                #
#			15-17 UTC					                                                #
#			18-20 UTC					                                                #	
#			21-23 UTC                                                         #
#                                                                       #
# 3) Time Series model-obs shortwave radiation at each site             #
#                                                                       #
# Full implementation into AMET April 2013                              #
#	                                                                      #
# Added as new option: Version 1.2, May 8, 2013, Rob Gilliam            #
#-----------------------------------------------------------------------#
#                                                                       #
#########################################################################
#########################################################################
#	Load required modules
  if(!require(RMySQL)) {stop("Required Package RMySQL was not loaded")}
  if(!require(date))   {stop("Required Package date was not loaded")  }
  if(!require(fields)) {stop("Required Package fields was not loaded")}
  if(!require(maps))   {stop("Required Package maps was not loaded")}
  if(!require(mapdata)){stop("Required Package mapdata was not loaded")}
  if(!require(akima))  {stop("Required Package akima was not loaded")}

#########################################################################
#    Initialize AMET Diractory Structure Via Env. Vars
#    AND Load required function and conf. files
#########################################################################
  term<-Sys.getenv("TERM") 				# are we using via the web or not?
  ametbase<-Sys.getenv("AMETBASE") 			# root directory for amet
  ametR<-paste(ametbase,"/R",sep="")                    # R directory
  ametRinput <- Sys.getenv("AMETRINPUT")                # input file for this script
  
  # Check for output directory via namelist and AMETOUT env var, if not specified in namelist
  # and not specified via AMETOUT, then set figdir to the current directory
  if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")	}
  if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"			}

  ## source some configuration files, AMET libs, and input
  source(paste(ametbase,"/configure/amet-config.R",sep=""))
  source (paste(ametR,"/MET_amet.misc-lib.R",sep=""))  	# Miscellanous AMET R-functions file
  source (paste(ametR,"/MET_amet.plot-lib.R",sep=""))  	# AMET Plot functions file
  source (paste(ametR,"/MET_amet.stats-lib.R",sep=""))  # AMET Plot functions file
  source (ametRinput)	                                # Anaysis configuration/input file

#########################################################################
#					Main Program     	   
#########################################################################

 ## mysql connection configuration
 mysql		<-list(server=server,dbase=dbase,login=login,passwd=passwd,maxrec=maxrec)
 
 dates<-mdy.date(month = ms, day = ds, year = ys)
 datee<-mdy.date(month = me, day = de, year = ye)
 d1<-date.mdy(dates)     
 d2<-date.mdy(datee)     
 d1<-paste(d1$year,dform(d1$month),dform(d1$day),sep="")
 d2<-paste(d2$year,dform(d2$month),dform(d2$day),sep="")
 
 varsName<-c("Temperature (2m)","Specific Humidity (2m)","Wind Speed (10m)","Wind Direction (deg.)")
 varid<-c("T","Q","WS","WD")

 # Construction of database query
 query<- paste("SELECT  DATE_FORMAT(ob_date,'%Y%m%d'),HOUR(ob_time), d.stat_id, s.ob_network, s.lat, s.lon, ", 
                "d.T_mod,d.T_ob, d.U_mod, d.U_ob, d.V_mod, d.V_ob, d.SRAD_mod, d.SRAD_ob FROM ",
                project,"_surface d, stations s WHERE s.stat_id=d.stat_id AND d.SRAD_ob > 0 AND ",
                "d.ob_date BETWEEN ",d1," AND ",d2, extra, sep="")
 query<- paste("SELECT  DATE_FORMAT(ob_date,'%Y%m%d'),HOUR(ob_time), stat_id,", 
                "SRAD_mod, SRAD_ob FROM ",
                project,"_surface WHERE  SRAD_ob > 0 AND ",
                "ob_date BETWEEN ",d1," AND ",d2, extra, sep="")
 data<-ametQuery(query,mysql)
 
 ## test to see if query returned anything
if (length(data) == 0) {
   ## error the queried returned nothing
  writeLines("ERROR: query returned no results.")
  writeLines("       Check settings, specifically start and end dates")
  stop(paste("ERROR querying db: \n",query))
}
    
id_loc<-3
hr_loc<-2
sr_ob_loc<-5
sr_mod_loc<-4
h1<-c(12,15,18,21)
h2<-c(14,17,20,23)
##############################################################################################
 # Do spatial plot mode if specified in namelist
if(spatial) {
  # Define sites and location then prepare statistics arrays
  stat_array	<- array(NA,c(nsites,7,4))
  index<-1:length(data[,id_loc])
     
  #-----------------------  LOOP THROUGH Sites and Hours ------------------------------------
  for(s in 1:nsites) {
    writeLines(paste("Computing statistics for site:",sites[s],s,"of",nsites))
    for(hh in 1:4) {
      mask      <- index[sites[s] == data[,id_loc] & (data[,hr_loc] >= h1[hh] & data[,hr_loc] <= h2[hh]) ]
      stat_array[s,1,hh] <- mean(data[mask,sr_ob_loc], na.rm=T)
      stat_array[s,2,hh] <- mean(data[mask,sr_mod_loc], na.rm=T)
      stat_array[s,3,hh] <- magerror(data[mask,sr_ob_loc], data[mask,sr_mod_loc], na.rm=T)
      stat_array[s,4,hh] <- mbias(data[mask,sr_ob_loc], data[mask,sr_mod_loc], na.rm=T)
      stat_array[s,5,hh] <- rmserror(data[mask,sr_ob_loc], data[mask,sr_mod_loc], na.rm=T)
      stat_array[s,6,hh] <- sd(data[mask,sr_ob_loc], na.rm=T)
      stat_array[s,7,hh] <- sd(data[mask,sr_mod_loc], na.rm=T)       
    }
  }
  #-------------------------------------------------------------------------------  
 
  #-------------------------------------------------------------------------------
  # Generate Spatial Plot
  res=100
  for(hr in 1:4) {

    figure<-paste(figdir,"/srad.spatial.",h1[hr],"to",h2[hr],"UTC.",d1,"-",d2,sep="")
    if (plotopts$plotfmt == "png"){bitmap(file=paste(figure,".png",sep=""), width = 11, height = 8.5, res=100,pointsize=10*plotopts$plotsize)	}
    if (plotopts$plotfmt == "pdf"){writeLines(paste(figure,".pdf",sep=""));pdf(file= paste(figure,".pdf",sep=""), width = 10, height = 5)	}
    writeLines(paste(figure,".",plotopts$plotfmt,sep=""))
     
     lonw<-min(lon,na.rm=T)-1		# Lat/Lon Bounds of Plot
     lone<-max(lon,na.rm=T)
     lats<-min(lat,na.rm=T)
     latn<-max(lat,na.rm=T)
  
     lats <- lats + (lats-latn)/10
     lone <- lone + (lone-lonw)/15 
    
     lonw<- -135
     lone<-  -65
     lats<-24
     latn<-55

     legend.div<-20
     a<-round(max(abs(range(stat_array[,4,]))))
     levsBIAS<- seq(-1*a,a,by=round(a*2/ legend.div ))
     a<-round(max(abs(range(stat_array[,5,]))))
     levsRMSE<- seq(0,a,by=round(a/ legend.div ))
     a<-round(max(abs(range(stat_array[,7,hr]-stat_array[,6,hr]))))
     levsSDEV<- seq(-1*a,a,by=round(a*2/ legend.div ))
     a<-round(max(abs(range(stat_array[,3,]))))
     levsMAE<- seq(0,a,by=round(a / legend.div ))
     
     levsBIAS<-c(-400,-150,-100,-75,-50,-30,-20,-10,0,10,20,30,50,75,100,150,400)
     levsRMSE<-c(0,10,20,30,40,50,75,100,125,150,175,200,250,300,400)
     levsMAE<-levsRMSE
     levsSDEV<-levsBIAS
     
     colBIAS<-rev(rainbow(length(levsBIAS)))
     colRMSE<-rev(rainbow(length(levsRMSE)))
     colSDEV<-rev(rainbow(length(levsSDEV)))
     colMAE<-rev(rainbow(length(levsMAE)))
     
     # Modify colors that surround zero to grey
     cl<-length(colBIAS)
     #colBIAS[((cl/2)):((cl/2)+2)]<-"gray"
     cl<-length(colSDEV)
     #colSDEV[((cl/2)):((cl/2)+2)]<-"gray"

     pcolsBIAS	<-colBIAS[cut(stat_array[,4,hr],br=levsBIAS,labels=FALSE,include.lowest=T)]
     pcolsRMSE	<-colRMSE[cut(stat_array[,5,hr],br=levsRMSE,labels=FALSE,include.lowest=T)]
     pcolsSDEV	<-colSDEV[cut(stat_array[,7,hr]-stat_array[,6,hr],br=levsSDEV,labels=FALSE,include.lowest=T)]
     pcolsMAE	<-colMAE[cut(stat_array[,3,hr],br=levsMAE,labels=FALSE,include.lowest=T)]
 
     par(mfrow=c(2,2))
     par(mai=c(0,0,0,0))
     #------------------------------------------------------------------------------------------------------------
     #  Plot Spatial Solar Radiation Bias
     title   <-"Mean Shortwave Radiation Bias (W/m^2)"
     infolab <-""
     m<-map('usa',plot=FALSE)
     map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
     map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65), add=T)
     points(lon,lat,pch=plotopts$symb, cex=plotopts$symbsiz, col=pcolsBIAS)
     points(lon,lat,pch=plotopts$symbo, cex=plotopts$symbsiz, col="black")
     legend(-125,24,format(levsBIAS,digit=2),col=colBIAS,fill=F,pch=plotopts$symb,
           xjust=1,yjust=0,bg='white',y.intersp=.75,pt.cex=0.55,cex=0.55,pt.bg="white",bty=T,horiz=F)
     title(title,sub=infolab,line=1, cex.sub=0.5)
     box(which="figure")
     writeLines(" ------------------- ********************* -------------------------- ********************")
     #------------------------------------------------------------------------------------------------------------
     #  Plot Spatial Radiation MAE
     title   <-"Mean Shortwave Radiation MAE (W/m^2)"
     infolab <-""
     m<-map('usa',plot=FALSE)
     map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
     map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65), add=T)
     points(lon,lat,pch=plotopts$symb, cex=plotopts$symbsiz, col=pcolsMAE)
     points(lon,lat,pch=plotopts$symbo, cex=plotopts$symbsiz, col="black")
     legend(-125,24,format(levsMAE,digit=2),col=colMAE,fill=F,pch=plotopts$symb,
           xjust=1,yjust=0,bg='white',y.intersp=.75,pt.cex=0.55,cex=0.55,pt.bg="white",bty=T,horiz=F)
     title(title,sub=infolab,line=1, cex.sub=0.5)
     box(which="figure")
     #------------------------------------------------------------------------------------------------------------
     #  Plot Spatial RH Bias
     title   <-"Mean Shortwave Radiation RMSE (W/m^2)"
     infolab <-""
     m<-map('usa',plot=FALSE)
     map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
     map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65), add=T)
     points(lon,lat,pch=plotopts$symb, cex=plotopts$symbsiz, col=pcolsRMSE)
     points(lon,lat,pch=plotopts$symbo, cex=plotopts$symbsiz, col="black")
     legend(-125,24,format(levsRMSE,digit=2),col=colRMSE,fill=F,pch=plotopts$symb,
           xjust=1,yjust=0,bg='white',y.intersp=.75,pt.cex=0.55,cex=0.55,pt.bg="white",bty=T,horiz=F)
     title(title,sub=infolab,line=1, cex.sub=0.5)
     box(which="figure")
     #------------------------------------------------------------------------------------------------------------
     #------------------------------------------------------------------------------------------------------------
     #  Plot Mean Wind Vectors
     title   <-"Mean Shortwave Radiation SDEV Difference (W/m^2)"
     infolab <-""
     m<-map('usa',plot=FALSE)
     map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
     map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65), add=T)
     points(lon,lat,pch=plotopts$symb, cex=plotopts$symbsiz, col=pcolsSDEV)
     points(lon,lat,pch=plotopts$symbo, cex=plotopts$symbsiz, col="black")
     legend(-125,24,format(levsSDEV,digit=2),col=colSDEV,fill=F,pch=plotopts$symb,
           xjust=1,yjust=0,bg='white',y.intersp=.75,pt.cex=0.55,cex=0.55,pt.bg="white",bty=T,horiz=F)
     title(title,sub=infolab,line=1, cex.sub=0.5)
     box(which="figure")
     #------------------------------------------------------------------------------------------------------------
     dev.off()
     #-------------------------------------------------------------------------------
     
   }
}
##############################################################################################

##############################################################################################
 # Do diurnal plot mode if specified in namelist
if(diurnal) {

# LOOP through each site and generates stats and plots  
for(ss in 1:nsites){

  # Define sites and location then prepare statistics arrays

  stat_array_diurnal	<- array(NA,c(7,24))
  index<-1:length(data[,id_loc])
  for(hh in 1:24) {     
    writeLines(paste("Computing statistics for hour :",hh-1))
    
    dst<-0    
    if(hh == 1)           { hour_obs <- hh-dst;  hour_mod <- hh  }
    if(hh > 1 & hh < 24)  { hour_obs <- hh-dst; hour_mod  <- hh   }
    if(hh == 24)          { hour_obs <- hh-dst; hour_mod  <- 0    }
    if(hh == 24 & dst == 0) { hour_obs <- 0; hour_mod  <- 0    }
        
    mask_obs      <- data[,hr_loc] == hour_obs & data[,id_loc] == sites[ss]
    mask_mod      <- data[,hr_loc] == hour_mod & data[,id_loc] == sites[ss]
        
    stat_array_diurnal[1,hh] <- mean(data[mask_obs,sr_ob_loc],na.rm=T)
    stat_array_diurnal[2,hh] <- mean(data[mask_mod,sr_mod_loc],na.rm=T)
    stat_array_diurnal[3,hh] <- rmserror(data[mask_obs,sr_ob_loc], data[mask_mod,sr_mod_loc], na.rm=T)
    stat_array_diurnal[4,hh] <- magerror(data[mask_obs,sr_ob_loc], data[mask_mod,sr_mod_loc], na.rm=T)
    stat_array_diurnal[5,hh] <- mbias(data[mask_obs,sr_ob_loc], data[mask_mod,sr_mod_loc], na.rm=T)
    stat_array_diurnal[6,hh] <- sd(data[mask_obs,sr_ob_loc], na.rm=T)
    stat_array_diurnal[7,hh] <- sd(data[mask_mod,sr_mod_loc], na.rm=T)
        
  }
   

  #################################################################################################################################
  #	GENERATE DIURNAL STATISTICS PLOT
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  figure<-paste(figdir,"/srad.diurnal.",sites[ss],".",d1,"-",d2,sep="")
  if (plotopts$plotfmt == "pdf"){writeLines(paste(figure,".pdf",sep=""));pdf(file= paste(figure,".pdf",sep=""), width = 10, height = 5)	}
  if (plotopts$plotfmt == "bmp"){writeLines(paste(figure,".png",sep=""));bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, height = (350*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)	}
  #if (plotopts$plotfmt == "png"){writeLines(paste(figure,".png",sep=""));png(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize), height = (350*plotopts$plotsize), pointsize=10*plotopts$plotsize)	}
  if (plotopts$plotfmt == "jpeg"){writeLines(paste(figure,".jpeg",sep=""));jpeg(file=paste(figure,".jpeg",sep=""), width = (700*plotopts$plotsize), height = (350*plotopts$plotsize), quality=100)	}
  if (plotopts$plotfmt == "png"){writeLines(paste(figure,".png",sep=""));bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, height = (350*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)	}
  #:::::::::::::::::::::::::::::::::::::::::::::::
  hr<-seq(0,23)
  xlim<-c(0,23)
  par(mfrow=c(3,1))
  par(mai=c(0.00,0.40,0.05,0.05))
  par(mgp=c(1.0,0.10,0))
  par(tcl=0.50)
    
  #######################################################################
  #   Plot top panel of 3-panel plot (Mean radiation of mod and obs)
  ylim <- c(0,range(stat_array_diurnal[1:2,],na.rm=T)[2])
  ylabs<- seq(0,ceiling(ylim[2]/100)*100,by=100)
    
  linecols <-c("red","blue")
  linetype <-c(1,1)
  pchtype  <-c(0,1)
  leglab   <-c("Observation","Model")

  par(new=FALSE)
  plot(hr,stat_array_diurnal[1,],xlim=xlim, ylim=ylim,xlab="Time of Day",ylab=paste("Mean Shortwave(W/m^2) ",sep=""),
         label=FALSE,tick=FALSE,lty=linetype[1],pch=pchtype[1],col=linecols[1],type="l",lwd=1, axis=F)   		

  par(tck=1)
  axis(1,at=hr,labels=NA,cex=1.25,col="gray",lty=1)
  axis(2,at=ylabs,labels=ylabs,cex=1.25,col="gray",lty=1)
    
  par(new=TRUE)
  plot(hr,stat_array_diurnal[1,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
       lty=linetype[1],pch=pchtype[1],col=linecols[1],type="l",lwd=1)   		

  par(new=TRUE)
  plot(hr,stat_array_diurnal[2,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[2],pch=pchtype[2],col=linecols[2],type="l",lwd=1)   		
        
  legend( 1, ylim[2]+(ylim[2]*0.04), leglab, col = linecols, 
         lty = 1, bg="white", pch=NA, xjust=0, yjust=1)
  #title("Mean Shortwave Radiation",sub="test",line=0, cex.sub=0.50)
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
         label=FALSE,tick=FALSE,lty=linetype[1],pch=pchtype[1],col=linecols[1],type="l",lwd=1)   		

  par(tck=1)
	axis(1,at=hr,labels=NA,cex=1.25,col="gray",lty=1)
	axis(2,cex=1.25,col="gray",lty=1)
    
  par(new=TRUE)
  plot(hr,stat_array_diurnal[5,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[1],pch=pchtype[1],col=linecols[1],type="l",lwd=1)   		
  par(new=TRUE)
  plot(hr,stat_array_diurnal[3,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[2],pch=pchtype[2],col=linecols[2],type="l",lwd=1)   		
  par(new=TRUE)
  plot(hr,stat_array_diurnal[4,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[3],pch=pchtype[3],col=linecols[3],type="l",lwd=1)   		
        
  legend( 1, ylim[2]+(ylim[2]*0.04), leglab, col = linecols, 
           lty = 1, bg="white", pch=NA, xjust=0, yjust=1)
  lines(c(-1,24),c(0,0),lwd=2)       
  #title("Mean Shortwave Radiation",sub="test",line=0, cex.sub=0.50)
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
  leglab   <-c("Observation","Model")

  par(new=FALSE)
  plot(hr,stat_array_diurnal[6,],xlim=xlim, ylim=ylim,xlab="Time of Day",ylab=paste("Variability (W/m^2) ",sep=""),
         label=FALSE,tick=FALSE,lty=linetype[1],pch=pchtype[1],col=linecols[1],type="l",lwd=1)   		

  par(tck=1)
	axis(1,at=hr,labels=hr,cex=1.25,col="gray",lty=1)
	axis(2,at=ylabs,labels=ylabs,cex=1.25,col="gray",lty=1)
    
  par(new=TRUE)
  plot(hr,stat_array_diurnal[6,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[1],pch=pchtype[1],col=linecols[1],type="l",lwd=1)   		

  par(new=TRUE)
  plot(hr,stat_array_diurnal[7,],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[2],pch=pchtype[2],col=linecols[2],type="l",lwd=1)   		
        
  legend( 1, ylim[2]+(ylim[2]*0.04), leglab, col = linecols, 
           lty = 1, bg="white", pch=NA, xjust=0, yjust=1)
  #title("Mean Shortwave Radiation",sub="test",line=0, cex.sub=0.50)
  #######################################################################

  #------------------------------------------------------------------------------------------------------------
  dev.off()
  #-------------------------------------------------------------------------------
 }  #END LOOP OVER SITES

}
##############################################################################################
if(timeseries) {

  # LOOP through each site and generates stats and plots  
  for(ss in 1:nsites){
    mask <- data[,id_loc] == sites[ss] 
    day<-data[mask,1]
    timex<-data[mask,2]
    obs<-data[mask,sr_ob_loc]
    mod<-data[mask,sr_mod_loc]
    
	  iso.date <- ISOdatetime(year=as.numeric(substr(day,1,4)), month=as.numeric(substr(day,5,6)), 
	                         day=as.numeric(substr(day,7,8)),  hour=as.numeric(timex), min=0, sec=0, tz="GMT")
	                         
    date.vec<-seq(min(iso.date),max(iso.date),by="hour")
	  ts.length<-length(date.vec)
	  ts.values<-array(0,c(ts.length,2))
	  for(tt in 1:ts.length){
	    mask2<- iso.date == date.vec[tt]
	    nsample<-sum(ifelse(mask2,1,0),na.rm=T)
	    if(nsample == 1) {
	      ts.values[tt,1]<-obs[mask2]
	      ts.values[tt,2]<-mod[mask2]
	    }  
	  }
	  
    figure<-paste(figdir,"/srad.timeseries.",sites[ss],".",d1,"-",d2,sep="")

    if (plotopts$plotfmt == "pdf"){writeLines(paste(figure,".pdf",sep=""));pdf(file= paste(figure,".pdf",sep=""), width = 10, height = 5)	}
    if (plotopts$plotfmt == "bmp"){writeLines(paste(figure,".png",sep=""));bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, height = (350*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)	}
    if (plotopts$plotfmt == "png"){writeLines(paste(figure,".png",sep=""));bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, height = (350*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)	}

    par(bg="white")
    par(fg="black")
    tscols<-c("red","blue") 	
  
    val<-ts.values
    vallab<-"Global Shorwave Radiation (W m^2)"
    miny<-min(val,na.rm=TRUE)-2;
    maxy<-max(val,na.rm=TRUE);
    dy<-0.09*(maxy-miny);ps1<-maxy-dy;ps2<-ps1-dy;ps3<-ps2-dy
    ##############################################################
    #par(new=F)
	  #par(mai=c(0.25,0.35,0.2,0.1))
	  #par(mai=c(0,0.35,0.02,0.02))
	  #par(mgp=c(1.40,0.2,0))
	  plot(date.vec,val[,1],xlab="",axes=FALSE,ylab=vallab,xlim=range(date.vec),ylim=c(miny,maxy),
	       pch=4,cex=0.75,col=tscols[1],vfont=c("serif","bold"),label=TRUE,type="l",lwd=1, bg="yellow")
	  par(tck=1)
	  axis(2,col="black",lty=3)
	  par(tck=1)
	  axis(1,col="black",lty=3,at=date.vec[seq(1,length(date.vec),by=24)],labels=as.character(date.vec[seq(1,length(date.vec),by=24)]))
	  par(new=T)
	  plot(date.vec,val[,2],xlim=range(date.vec),ylim=c(miny,maxy),label=FALSE,tick=FALSE,
	       type="l",pch=5,col=tscols[2],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
	  title("Observation-Model Time Series",line=-1,outer=T)
    legend(date.vec[1],maxy,c("SurfRad","WRF"),col=tscols,lty=1,lwd=2,cex=0.90,xjust=.20)
    #------------------------------------------------------------------------------------------------------------
    dev.off()
    #-------------------------------------------------------------------------------
  }  #END LOOP OVER SITES
}
##############################################################################################


