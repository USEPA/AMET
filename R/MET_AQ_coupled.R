#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#		AMET (Atmospheric Model Evaluation Tool)                            #
#                                                                       #
#			Example Met-AQ coupled analysis                                   #
#			       MET_AQ_coupled.R                                           #
#                                                                       #
#                                                                       #
#	Version: 	1.1                                                         #
#	Date:		Sep 18, 2007                                                  #
#	Contributors:	Robert Gilliam                                          #
#                                                                       #
#	Developed by and for NOAA, ARL, ASMD on assignment to US EPA          #
#-----------------------------------------------------------------------#
#
# Modified to work with combined MET/AQ mode, Alexis Zubrow (IE UNC) Oct, 2007
#
# Version 1.2, May 6, 2013, Rob Gilliam
# - Cleaned code
#########################################################################
#:::::::::::::::::::::::::::::::::::::::::::::
#	Load required modules
  require(RMySQL)
  require(maps)
  require(mapdata)
#:::::::::::::::::::::::::::::::::::::::::::::
#    Load AMET R configuration and libraries

## get some environmental variables and setup some directories
  term<-Sys.getenv("TERM") 				# are we using via the web or not?
  ametbase<-Sys.getenv("AMETBASE") 			# base directory of AMET
  ametR<-paste(ametbase,"/R",sep="")                    # R directory
  ametRinput <- Sys.getenv("AMETRINPUT")                # input file for this script

  # Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
  # and not specified via AMET_OUT, then set figdir to the current directory
  if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")	}
  if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"			}

  ## source some configuration files, AMET libs, and input
  source(paste(ametbase,"/configure/amet-config.R",sep=""))
  source (paste(ametR,"/MET_amet.misc-lib.R",sep=""))  	# Miscellanous AMET R-functions file
  source (paste(ametR,"/MET_amet.plot-lib.R",sep=""))  	# AMET Plot functions file
  source (paste(ametR,"/MET_amet.stats-lib.R",sep=""))  # AMET Plot functions file
  source (ametRinput)	                                # Anaysis configuration/input file

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#					Main Program     	   
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 maxrec<- -1
 aq_mysql<-list(server=server,dbase=aq_database,login=login,passwd=passwd,maxrec=maxrec)
 met_mysql<-list(server=server,dbase=met_database,login=login,passwd=passwd,maxrec=maxrec)
 
 varsName<-c("Temperature (2m)","Specific Humidity (2m)","Wind Speed (10m)","Wind Direction (deg.)")
 varid<-c("T","Q","WS","WD")

 ## Time processing for query
hour.range.str    <- ""
hour.range.str.LT <- ""
if( !is.na(time.of.day.utc)[1]) {
hour.range.str    <- paste(" AND HOUR(d.ob_time) BETWEEN ",time.of.day.utc[1]," AND ",time.of.day.utc[2],sep="")
hour.range.str.LT <- paste(" AND d.ob_hour BETWEEN ",time.of.day.utc[1]+LT.offset[1]," AND ",time.of.day.utc[2]+LT.offset[2],sep="")
}

  # Construction of database query
     aq_query <- paste("select s.stat_id, DATE_FORMAT(d.ob_dates,'%Y%m%d'),d.ob_hour, ",aq_species_col,
                       " FROM ",aq_project," d,  ",aq_site_table," s ", 
                       "WHERE s.stat_id=d.stat_id AND d.ob_dates BETWEEN ",dates," AND ",datee,
                       " AND s.network='",aq_network,"'", hour.range.str.LT, sep='')
            
     met_query <- paste("select s.stat_id, DATE_FORMAT(d.ob_date,'%Y%m%d'),HOUR(ob_time), ",
                         met_variable_col," FROM ",met_project,"_surface d,  ",met_site_table," s ", 
                         "WHERE s.stat_id=d.stat_id AND d.ob_date BETWEEN ",dates," AND ",datee,hour.range.str, sep='')

     met_site_query <- paste("select distinct(s.stat_id), s.lat, s.lon FROM ",met_site_table," s,  ",met_project,"_surface d ", 
                             "WHERE s.stat_id=d.stat_id AND d.ob_date BETWEEN ",dates," AND ",datee, hour.range.str, sep='')
    
     aq_site_query <- paste("select distinct(s.stat_id), s.lat, s.lon FROM ",aq_site_table," s,  ",aq_project," d ", 
                            "WHERE s.stat_id=d.stat_id AND d.ob_dates BETWEEN ",dates," AND ",datee," AND s.network='",
                            aq_network,"'", hour.range.str.LT, sep='')

    # Query AQ and MET sites and data
  if(query){
       aq_data 	<-ametQuery(aq_query,aq_mysql)
       aq_sites	<-ametQuery(aq_site_query,aq_mysql)
       met_data	<-ametQuery(met_query,met_mysql)
       met_sites<-ametQuery(met_site_query,met_mysql)       

    # write out number of sites
   writeLines(paste("Finishd queries, finding number of sites"))
   writeLines(paste("Number of dimisions of aq_sites", dim(aq_sites)[1], dim(aq_sites)[2]))
    n.sites <- length(aq_sites[,1])

    # write out number of sites
   writeLines(paste("Number of site     d<-dist.lat.lon(aq_sites[s,2],met_sites[,2],aq_sites[s,3],met_sites[,3])
      buddy_ind            <- which( d == min(d) )
      buddy.met.sites[s] <-met_sites[buddy_ind,1]
      buddy.met.dist[s]  <-d[buddy_ind]
s is:",n.sites))
 
    aq_data[,4] <- ifelse(aq_data[,4] == -999000, NA, aq_data[,4])
    aq_data <- na.omit(aq_data)
    met_data <- na.omit(met_data)
    
    max.time.offset.sec <- 6 * 60 * 60 
    # Make ISO date objects for all MET and AQ data
    aq.iso.date <- ISOdatetime(year=as.numeric(substr(aq_data[,2],1,4)), month=as.numeric(substr(aq_data[,2],5,6)), 
	                    day=as.numeric(substr(aq_data[,2],7,8)),  hour=as.numeric(aq_data[,3]), min=0, sec=0, tz="GMT")
    met.iso.date <- ISOdatetime(year=as.numeric(substr(met_data[,2],1,4)), month=as.numeric(substr(met_data[,2],5,6)), 
	                    day=as.numeric(substr(met_data[,2],7,8)),  hour=as.numeric(met_data[,3]), min=0, sec=0, tz="GMT")
 
    #date.vec<-unique(seq(min(aq.iso.date),max(aq.iso.date),by="hour"))
    date.vec<- seq(min(aq.iso.date)- max.time.offset.sec, max(aq.iso.date) + max.time.offset.sec,by="hour")
    
    # Find "buddy" meteorological site for each aq sites 
    buddy.met.sites <-array(NA,c(n.sites))
    buddy.met.dist  <-array(NA,c(n.sites))
    
    # Local to UTC time offset for each AQ site. For now it is set to 4 hours
    
    time.offset     <-array(4,c(n.sites))
    met.aq.fusion   <-array(NA,c(n.sites,length(date.vec),5))
    met.aq.diff.cor <-array(NA,c(n.sites))
    
    for(s in 1:n.sites ) {
      # Find buddy site
      d<-dist.lat.lon(aq_sites[s,2],met_sites[,2],aq_sites[s,3],met_sites[,3])
      buddy_ind            <- which( d == min(d) )
      buddy.met.sites[s] <-met_sites[buddy_ind,1]
      buddy.met.dist[s]  <-d[buddy_ind]
      writeLines(paste("Site number",s))
      if(d[buddy_ind] > max.dist ) { next }
      
      # Pick AQ and MET date
      aq.mask        <-  aq_sites[s,1] == aq_data[,1]
      aq.mask2       <-  aq_data[,1]
      met.mask       <-  buddy.met.sites[s] == met_data[,1]
      
      aq.site.date   <-  aq.iso.date[aq.mask] + (time.offset[s]*60*60) 
      met.site.date  <-  met.iso.date[met.mask]  
      
      a  <- match( met.site.date, date.vec)
      aa <-na.omit(a)
      b  <- match( aq.site.date, date.vec)
      bb <- na.omit(b)

      met.aq.fusion[s,a,1] <-  as.numeric(met_data[met.mask,3])           
      met.aq.fusion[s,a,2] <-  met_data[met.mask,4]
      met.aq.fusion[s,a,3] <-  met_data[met.mask,5] 
      met.aq.fusion[s,b,4] <- aq_data[aq.mask,4] 
      met.aq.fusion[s,b,5] <- aq_data[aq.mask,5]  
      if(length( met.aq.fusion[s,b,4]) == 0 || length(met.aq.fusion[s,b,5]) == 0 ) { next }
      met.aq.diff.cor[s]   <- cor( met.aq.fusion[s,,2]-met.aq.fusion[s,,1], met.aq.fusion[s,,4]-met.aq.fusion[s,,3], use = "complete" )      
      writeLines(paste("AQ site:",aq_sites[s,1],"   ",s," of ",n.sites,"  Buddy met site:",
                       met_sites[buddy_ind,1],"Distance:",d[buddy_ind]))
    }
   
    ###################################################################################################
    # Compute the hourly bias of MET and AQ considering all sites for that hour
     good.ind  <-na.omit(ifelse(  !is.na(met.aq.fusion[1,,1]), 1:length(met.aq.fusion[1,,1]), NA))
     time.vec  <- date.vec[good.ind]   
     time.bias <- array(NA,c(length(time.vec),2))
                                                                
     for(t in 1:length(time.vec) ) {                                                                                                                                                                                                                  
        time.bias[t,1] <- mean( met.aq.fusion[,good.ind[t],3] - met.aq.fusion[,good.ind[t],2] ,na.rm=T)   
        time.bias[t,2] <- mean( met.aq.fusion[,good.ind[t],5] - met.aq.fusion[,good.ind[t],4] ,na.rm=T)   
     }                                                                                                  
    ###################################################################################################         

    ###################################################################################################     
    # Compute the diurnal bias of MET and AQ considering all sites for the hours of the day
    hourly.bias <- array(NA,c(24,2))                                                          
    for(h in 1:24 ) {                                                                                   
       hour<- h-1                                                                                       
       hour.mask <-  met.aq.fusion[1,,1] == hour                                                        
       hourly.bias[h,1] <- mean( met.aq.fusion[,hour.mask,3] - met.aq.fusion[,hour.mask,2] ,na.rm=T)    
       hourly.bias[h,2] <- mean( met.aq.fusion[,hour.mask,5] - met.aq.fusion[,hour.mask,4] ,na.rm=T)    
    } 
    ###################################################################################################  
    
    
  }  # END QUERY CASE: I.E., Gather data and computes statistics
  
       
  ###################################################################################################  
  # Plot spatial correlation, diurnal bias and time series bias of MET and AQ    
  figure<-paste(figdir,"/","met.aq.spatial.corr",sep="")                                                                                                                                                                                                
  if (plotopts$plotfmt == "pdf"){writeLines(paste(figure,".pdf",sep=""));pdf(file= paste(figure,".pdf",sep=""), width = 8.5, height = 11)	}                                                                                                     
  if (plotopts$plotfmt == "bmp"){writeLines(paste(figure,".png",sep=""));bitmap(file=paste(figure,".png",sep=""), width = (1000*plotopts$plotsize)/100, height = (1000*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)	}     
  if (plotopts$plotfmt == "jpeg"){writeLines(paste(figure,".jpeg",sep=""));jpeg(file=paste(figure,".jpeg",sep=""), width = (1000*plotopts$plotsize), height = (1000*plotopts$plotsize), quality=100)	}                                     
  if (plotopts$plotfmt == "png"){writeLines(paste(figure,".png",sep=""));bitmap(file=paste(figure,".png",sep=""), width = (1000*plotopts$plotsize)/100, height = (1000*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)	}     
  
     lat<-aq_sites[,2]                                               
     lon<-aq_sites[,3]                                                   
     lonw<-min(lon,na.rm=T)-1		# Lat/Lon Bounds of Plot         
     lone<-max(lon,na.rm=T)                                              
     lats<-min(lat,na.rm=T)                                              
     latn<-max(lat,na.rm=T)                                              
                                                                         
     lats <- lats + (lats-latn)/10                                         
     lone <- lone + (lone-lonw)/15                                           
     
     levs	<-seq(-1,1,by=0.2)
     cols	<-rev(rainbow(length(levs))) 
     pcols	<-cols[cut(met.aq.diff.cor, br=levs, labels=FALSE, include.lowest=T)] 
    ######
    #------------------------------------------------------------------------------------------------------------       
    #  Plot Spatial Solar Radiation Bias                                                                                
    title   <-"Correlation of AQ and MET Bias"                                                                    
    infolab <-""                                                                                                        
    m<-map('usa',plot=FALSE)                                                                                            ###################################################################################################                                                                                                                     
    map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))     
    map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65), add=TRUE)   
    points(lon,lat,pch=plotopts$symb, cex=plotopts$symbsiz, col=pcols)                                            
    legend(lone,lats,format(levs,digit=2),col=cols,fill=F,pch=plotopts$symb,                                   
          xjust=1,yjust=0,bg='white',y.intersp=1,pt.cex=2,pt.bg="white",bty=T)                                        
    title(title,sub=infolab,line=1, cex.sub=0.9)                                                                      
    box(which="figure")     
    
    dev.off()              
    #---------------------------------------------------------------------------------------
    #  Plot Time series bias    
    figure<-paste(figdir,"/","met.aq.bias.comp",sep="")                                                                                                                                                                                                   
  if (plotopts$plotfmt == "pdf"){writeLines(paste(figure,".pdf",sep=""));pdf(file= paste(figure,".pdf",sep=""), width = 11, height = 8.5)	}                                                                                                   
  if (plotopts$plotfmt == "bmp"){writeLines(paste(figure,".png",sep=""));bitmap(file=paste(figure,".png",sep=""), width = (1000*plotopts$plotsize)/100, height = (773*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)	}           
  if (plotopts$plotfmt == "jpeg"){writeLines(paste(figure,".jpeg",sep=""));jpeg(file=paste(figure,".jpeg",sep=""), width = (1000*plotopts$plotsize), height = (773*plotopts$plotsize), quality=100)	}                                           
  if (plotopts$plotfmt == "png"){writeLines(paste(figure,".png",sep=""));bitmap(file=paste(figure,".png",sep=""), width = (1000*plotopts$plotsize)/100, height = (773*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)	}           


    hr<-1:length(time.bias[,1]) 
    ylim <- range(time.bias,finite=T)           
    xlim<-  range(hr)    
                                                           
    linecols <-c(4,2)                                      
    linetype <-c(1,1)                                      
    pchtype  <-c(0,1)                                      
    leglab   <-c("MET","AQ")                    
    
    par(mfrow=c(2,1))                                         
    par(new=FALSE)                                                                                                           
    plot(hr,time.bias[,1],xlim=xlim, ylim=ylim,xlab="Time of Day",ylab=paste("BIAS",sep=""),      
         label=FALSE,tick=FALSE,lty=linetype[1],pch=pchtype[1],col=linecols[1],type="l",lwd=1, axis=F)   		     
                                                                                                                             
   	par(tck=1)                                                                                                           
	axis(1,at=hr,labels=NA,cex=1.25,col="gray",lty=1)                                                                    
	axis(2,cex=1.25,col="gray",lty=1)                                                              
                                                                                                                             
    par(new=TRUE)                                                                                                            
    plot(hr,time.bias[,1],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,                              
         lty=linetype[1],pch=pchtype[1],col=linecols[1],type="l",lwd=1)   		                                     
                                                                                                                             
    par(new=TRUE)                                                                                                            
    plot(hr,time.bias[,2],,xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,                              
         lty=linetype[2],pch=pchtype[2],col=linecols[2],type="l",lwd=1)   		                                     
                                                                                                                             
    legend( 0, ylim[2], leglab, col = linecols,                                                                   
           lty = 1, bg="white", pch=NA, xjust=0, yjust=1) 
    lines(c(-1,length(hr)),c(0,0),lwd=3)                                                          
    title("Time Series Domain Bias of AQ and MET",line=2, cex.sub=0.50)                                                       

    ##########################################################################################
    hr<-0:23                  
    ylim1 <- range(hourly.bias[,1],finite=T)
    #ylim1 <- c(-5,5)    
    ylim2 <- range(hourly.bias[,2],finite=T)            
    xlim<-  range(hr)                            

    par(new=FALSE)
    par(mgp=c(2,0.50,0))                                                                                                          
    plot(hr,hourly.bias[,1],xlim=xlim, ylim=ylim1,xlab="Time of Day",ylab=paste("BIAS",sep=""),                            
         label=FALSE,tick=FALSE,lty=linetype[1],pch=pchtype[1],col=linecols[1],type="l",lwd=1, axes=F)   	
    par(tck=1)    
    axis(2,labels=T,cex=1.25,col="gray",lty=1, tick=T)        
    axis(1,at=hr,labels=T,cex=1.25,col="gray",lty=1)       
    #par(mgp=c(1.0,99,0)) 
    par(new=TRUE)                                                                                     
    plot(hr,hourly.bias[,2],xlim=xlim, ylim=ylim2,xlab="Time of Day",ylab=paste("BIAS",sep=""),         
         label=FALSE,tick=FALSE,lty=linetype[2],pch=pchtype[2],col=linecols[2],type="l",lwd=1, axes=F)                                                                                                                                                                                                          
    par(tck=1)  
    axis(4,labels=T,cex=1.25,col="gray",ylab="TEST",lty=2,tick=T)
    legend( 0, ylim2[2], leglab, col = linecols,                                                         
           lty = 1, bg="white", pch=NA, xjust=0, yjust=1)  
    lines(c(-1,24),c(0,0),lwd=3)                                                                   
    title("Diurnal AQ and MET BIAS",line=2, cex.sub=0.50)                                                  
    box()
    dev.off()
