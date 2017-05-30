#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#		AMET (Atmospheric Model Evaluation Tool)                            #
#                                                                       #
#			Wind Profile Statistics Plot                                      #
#		        MET_plot_prof.R                                             #
#                                                                       #
#                                                                       #
#	This "R" script extracts obs-model matched profile data from          #
#	the evaluation database (table id_profiler). The level-time           #
#	data is organized by height and time, then wind components            #
#	are used to calculates statistics. The results are time-height        #
#	plots various statistical metrics.                                    #
#                                                                       #
#	Version: 	1.1                                                         #
#	Date:		August 29, 2005                                               #
#	Contributors:	Robert Gilliam                                          #
#                                                                       #
#-----------------------------------------------------------------------#
#                                                                       #
#       Modified for MET/AQ combined setup --                           #
#                   Alexis Zubrow (IE UNC), Jan 2008                    #
#                                                                       #
#-----------------------------------------------------------------------#
# Version 1.2, May 8, 2013, Rob Gilliam                                 #
# Updates: - Pulled some configurable options out of MET_plot_prof.R    #
#            and placed into the plot_prof.input file                   #
#          - Added min.sample option (default 0) to skip statistics     #
#            if number of samples is less than this prescription        #
#          - Added min.WS.error QC option to ignore model-obs pairs when# 
#            abs difference greater than this value (m/s)               #
#          - General improvements of plots (labels, etc)                #
#          - Mean model PBL height added to plot.                       #
#          - Updated plotting option of hourly model-obs wind profiles. #
#          - Added option to print a site map in i,j model coordinates  #
#            this helps guide users to site names in database and loc.  #
#          - Added boxplot profile of MEA, bias, ioa for full day.      #
#          - Added histogram of Wind RMSE that includes all levels and  #
#            all times of day.                                          #
#          - Extensive cleaning of R script, R input and .csh files     #
#-----------------------------------------------------------------------#
#                                                                       #
#########################################################################

#########################################################################
# Load required modules

  if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}
  if(!require(date))  {stop("Required Package date was not loaded")  }
  if(!require(fields)){stop("Required Package fields was not loaded")}

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#    Initialize AMET Diractory Structure Via Env. Vars
#    AND Load required function and conf. files
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
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

  nhdelay<-1

 if (realtime){
     a<-system(" date '+%y%m%d%H'",intern=TRUE)
     b<-unlist(strsplit(a,split=""))
     ys<-2000+as.numeric(paste(b[1],b[2],sep=""));ye<-ys
     ms<-as.numeric(paste(b[3],b[4],sep=""));me<-ms
     ds<-as.numeric(paste(b[5],b[6],sep=""));de<-ds
     hs<-as.numeric(paste(b[7],b[8],sep=""));he<-hs
     datee<-list(y=ye,m=me,d=de,h=he)
     datee<-datecalc(datee,5,"hour")

 }

  ################################################################################## 

   dates<-list(y=ys,m=ms,d=ds,h=hs)
   datee<-list(y=ye,m=me,d=de,h=he)
   
   # New variable, check to see if provided, if not set to 0
   if(!exists("min.sample") )   {  min.sample  <- 0   }
   if(!exists("min.WS.error"))  {  min.WS.error<-5    }		# For older versions of input 

   ## mysql connection configuration
   mysql		<-list(server=server,dbase=dbase,login=login,passwd=passwd,maxrec=maxrec)

################################################################################################
#  Query Data and determine height and sigma levels

for (sn in 1:length(statstr)){
 if (processprof){

 datestr <-paste(" AND ob_date BETWEEN ",dates$y,dform(dates$m),dform(dates$d),
                 " AND ",datee$y,dform(datee$m),dform(datee$d)," AND ob_time BETWEEN '",
                 otime[1],"' AND '",otime[length(otime)],"'",sep="")
                 
 query   <-paste("SELECT ",varxtrac," FROM ",table," WHERE ",statstr[sn],levstr,datestr)
 data    <-ametQuery(query,mysql)
 
 a<-dim(data)
 if(length(data) == 0){
	stop(
	     paste('',
	           '**********************************************************************************',
	           'NO DATA WAS FOUND FOR THIS QUERY: Please change some of the criteria and try again',
	           '**********************************************************************************',sep="\n")
	    )
 }

 levs  <-(unique(data[,3]))
 levs  <-sort(unique(data[,3]),decreasing =T)
 loc   <-1:length(data[,1])
 nstats<-9
 mt    <-array(NA,c(length(otime),length(levs),nstats,nvar));
 H     <-array(NA,c(length(otime),length(levs)));

#####  LOOP THROUGH TIME OF Day
for(t in 1:length(otime)){

#####  LOOP THROUGH LEVELS
 for(z in 1:(length(levs)) ){
	locx<-na.omit(ifelse(otime[t] == data[,2] & levs[z] == data[,3], loc,NA))

	# Temperature Arrays
	prep<-ifelse(data[,Hloc] == 0,NA,data[,Hloc])
	H[t,z]<-mean(prep[na.omit(locx)])
	# Temperature Arrays
	prep<-ifelse(data[,Tloc] == 0 | data[,Tloc] > 999, NA,data[,Tloc])
	Tmod<-prep[na.omit(locx)]
	prep<-ifelse(data[,Tloc+1] == 0 | data[,Tloc+1] > 999, NA,data[,Tloc+1])
	Tobs<-prep[na.omit(locx)]
  
  if(length(na.omit(Tobs)) > min.sample & length(na.omit(Tmod)) > min.sample){
	 mt[t,z,1,1]<-min(length(na.omit(Tobs)),length(na.omit(Tmod)))
	 mt[t,z,2,1]<-magerror(Tobs,Tmod,na.rm=TRUE)
	 mt[t,z,3,1]<-mbias(Tobs,Tmod,na.rm=TRUE)
	 mt[t,z,4,1]<-sqrt(var(Tobs-Tmod,na.rm=TRUE))
	 mt[t,z,5,1]<-rmserror(Tobs,Tmod,na.rm=TRUE)
	 mt[t,z,6,1]<-cor(Tobs,Tmod,use="complete.obs")
	 mt[t,z,7,1]<-ac(Tobs,Tmod)
	 mt[t,z,8,1]<-mean(Tmod,na.rm=TRUE)
	 mt[t,z,9,1]<-mean(Tobs,na.rm=TRUE)
  }

	# Wind Arrays
	prep<-ifelse(data[,Uloc] == 0 | data[,Uloc] > 999,NA,data[,Uloc])
	Umod<-prep[na.omit(locx)]
	prep<-ifelse(data[,Uloc+1] == 0 | data[,Uloc+1] > 999,NA,data[,Uloc+1])
	Uobs<-prep[na.omit(locx)]
	prep<-ifelse(data[,Vloc] == 0 | data[,Vloc] > 999,NA,data[,Vloc])
	Vmod<-prep[na.omit(locx)]
	prep<-ifelse(data[,Vloc+1] == 0 | data[,Vloc+1] > 999,NA,data[,Vloc+1])
	Vobs<-prep[na.omit(locx)]

	WSobs<-sqrt(Uobs^2+Vobs^2)
	WSmod<-sqrt(Umod^2+Vmod^2)
 	# Note new mask out added above
  WS.NA.MASK<-ifelse( abs(WSobs-WSmod) > min.WS.error,NA,1.0)
  WSobs<-WSobs*WS.NA.MASK
	WSmod<-WSmod*WS.NA.MASK
 		
	WDmod<-180+(360/(2*pi))*atan2(Umod,Vmod)
 	WDobs<-180+(360/(2*pi))*atan2(Uobs,Vobs)
	diff<-WDmod-WDobs*WS.NA.MASK
	diff<-ifelse(diff > 180 , diff-360, diff)
	diff<-ifelse(diff< -180 , diff+360, diff)
	WDobs<-runif(length(diff),min=0,max=0.001)
	WDmod<-diff

  if(length(na.omit(WSobs)) > min.sample & length(na.omit(WSmod)) > min.sample){
	  mt[t,z,1,2]<-min(length(na.omit(WSobs)),length(na.omit(WSmod)))
	  mt[t,z,2,2]<-magerror(WSobs,WSmod,na.rm=TRUE)
	  mt[t,z,3,2]<-mbias(WSobs,WSmod,na.rm=TRUE)
	  mt[t,z,4,2]<-sqrt(var(WSobs-WSmod,na.rm=TRUE))
	  mt[t,z,5,2]<-rmserror(WSobs,WSmod,na.rm=TRUE)
	  mt[t,z,6,2]<-cor(WSobs,WSmod,use="complete.obs")
	  mt[t,z,7,2]<-ac(WSobs,WSmod)
	  mt[t,z,8,2]<-mean(WSmod,na.rm=TRUE)
	  mt[t,z,9,2]<-mean(WSobs,na.rm=TRUE) 

	  mt[t,z,1,3]<-min(length(na.omit(WDobs)),length(na.omit(WDmod)))
	  mt[t,z,2,3]<-magerror(WDobs,WDmod,na.rm=TRUE)
	  mt[t,z,3,3]<-mbias(WDobs,WDmod,na.rm=TRUE)
	  mt[t,z,4,3]<-sqrt(var(WDobs-WDmod,na.rm=TRUE))
	  mt[t,z,5,3]<-rmserror(WDobs,WDmod,na.rm=TRUE)
	  mt[t,z,6,3]<-NA
	  mt[t,z,7,3]<-NA
	  mt[t,z,8,3]<- 180+(360/(2*pi))*atan2(mean(Umod*WS.NA.MASK,na.rm=T),mean(Vmod*WS.NA.MASK,na.rm=T)) 
	  mt[t,z,9,3]<- 180+(360/(2*pi))*atan2(mean(Uobs*WS.NA.MASK,na.rm=T),mean(Vobs*WS.NA.MASK,na.rm=T)) 
  }

	# OTHER Arrays most not used yet. PBL height of model is used in V1.3
	prep<-ifelse(data[,SNRloc] == 0,NA,data[,SNRloc])
	SNR<-prep[na.omit(locx)]
	prep<-ifelse(data[,PBLloc] <= 0,NA,data[,PBLloc])
	PBLmod<-prep[na.omit(locx)]*WS.NA.MASK
	prep<-ifelse(data[,PBLloc+1] <= 0,NA,data[,PBLloc+1])
	PBLobs<-prep[na.omit(locx)]*WS.NA.MASK
	PBLobs<-PBLmod
	
  if(length(na.omit(SNR)) > min.sample){
	  mt[t,z,1,4]<-length(na.omit(SNR))
	  mt[t,z,2,4]<-NA
	  mt[t,z,3,4]<-NA
	  mt[t,z,4,4]<-NA
	  mt[t,z,5,4]<-NA
	  mt[t,z,6,4]<-NA
	  mt[t,z,7,4]<-NA
	  mt[t,z,8,4]<-NA
	  mt[t,z,9,4]<-mean(SNR,na.rm=TRUE)
  }

  if(length(na.omit(PBLmod)) > min.sample){
	  mt[t,z,1,5]<-length(na.omit(PBLmod))
	  #mt[t,z,2,5]<-magerror(PBLobs,PBLmod,na.rm=TRUE)
	  #mt[t,z,3,5]<-mbias(PBLobs,PBLmod,na.rm=TRUE)
	  #mt[t,z,4,5]<-sqrt(var(PBLobs-PBLmod,na.rm=TRUE))
	  #mt[t,z,5,5]<-rmserror(PBLobs,PBLmod,na.rm=TRUE)
	  #mt[t,z,6,5]<-cor(PBLobs,PBLmod,na.rm=TRUE)
	  #mt[t,z,7,5]<-ac(PBLobs,PBLmod)
	  mt[t,1,8,5]<-mean(PBLmod,na.rm=TRUE)
	  mt[t,1,9,5]<-mean(PBLobs,na.rm=TRUE)
  }
	# grab number of model-obs pairs used and rejected and print for user info
	n.rejected  <-sum(ifelse(is.na(WSobs),1,0))
	n.considered<-sum(ifelse(is.na(WSobs),0,1))
	writeLines(paste("Statistics computed for sigma level",levs[z],"Height",H[t,z]," and time",otime[t],"and number of obs considered/rejected",n.considered,n.rejected))

  }  # END LOOP THROUGh LEVELS
 }	# END LOOP THROUGH TIME

} 	# END of Processing Routine

###############################################################################
###############################################################################
 if(plotprof){
###############################################################################
min(mt[,,8,1],na.rm=TRUE)
 ll<-array(,c(nvar,9));		# Lower limit value for each stat and variable
 ll[1,]<-c(0,0,-5 ,0,0,-1,0,min(mt[,,8,1],mt[,,9,1],na.rm=TRUE),min(mt[,,8,1],mt[,,9,1],na.rm=TRUE))	# T
 ll[2,]<-c(0,0,-5 ,0,0,-1,0,0,0)	# WS
 ll[3,]<-c(0,0,-45,0,0,-1,0,0,0)	# WD
 ll[4,]<-c(0,0,-1 ,0,0,-1,0,0,0)	# SNR
 ll[5,]<-c(0,0,-1 ,0,0,-1,0,0,0)	# PBLH

###############################################################################
 ul<-array(,c(nvar,9));		# Lower limit value for each stat and variable
 ul[1,]<-c(max(mt[,,1,1],na.rm=TRUE),5,5  ,5, 5, 1,1,max(mt[,,8,1],mt[,,9,1],na.rm=TRUE),max(mt[,,8,1],mt[,,9,1],na.rm=TRUE))	# T
 ul[2,]<-c(max(mt[,,1,2],na.rm=TRUE),5,5  ,5, 5, 1,1,max(mt[,,8,2],mt[,,9,2],na.rm=TRUE),max(mt[,,8,2],mt[,,9,2],na.rm=TRUE))	# WS
 ul[3,]<-c(max(mt[,,1,3],na.rm=TRUE),90,45,90,90,1,1,360,360)	# WD
 ul[4,]<-c(max(mt[,,1,4],na.rm=TRUE),1,1  ,3, 3, 1,1,max(mt[,,8,4],mt[,,9,4],na.rm=TRUE),max(mt[,,8,4],mt[,,9,4],na.rm=TRUE))	# SNR
 ul[5,]<-c(max(mt[,,1,5],na.rm=TRUE),1,1  ,3, 3, 1,1,max(mt[,,8,5],mt[,,9,5],na.rm=TRUE),max(mt[,,8,5],mt[,,9,5],na.rm=TRUE))	# PBLH

###############################################################################
##################################	Mean Specs
 lims<-array(,c(nvar,2));		# Lower limit value for each stat and variable
 lims[1,]<-c(ll[1,8],ul[1,8])	# T
 lims[2,]<-c(ll[2,8],ul[2,8])	# WS
 lims[3,]<-c(ll[3,8],ul[3,8])	# WD
 lims[4,]<-c(ll[4,8],ul[4,8])	# SNR
 lims[5,]<-c(ll[5,8],ul[5,8])	# PBLH


 mean.PBL.mod<- mt[,1,8,5]
###############################################################################
#	Height corresponding to Sigma levels
 height<-matrix();
 for(z in 1:length(levs)){
   height[z]<-mean(H[,z],na.rm=TRUE)
 }
###############################################################################

 if (textstats){
   system(paste("rm -f ",figdir,"/tmp",sep=""))
   sfile<-file(paste(figdir,"/tmp",sep=""),"w") 
   writeLines("Model Evaluation Metrics from the Profiler", con =sfile)
   writeLines("--------------------------------------------------------", con =sfile)
 }

#	Loop through variables and statistics plots
for(v in 1:length(varloc)){
 for(s in 1:length(statloc)){

	plotopts$figure<-paste(figdir,"/wind.profile.stats.",project,".",varid[varloc[v]],".",metric[statloc[s]],".",statid[sn],sep="")
	
	varstat	<-mt[,,statloc[s],varloc[v]]
	varstat[,length(height)]<-NA
	t	<- 1:nrow(varstat)
	h	<-sort(round(height))
	locs	<-seq(0,21,3)

	tmp	<-paste(0:23,"UTC")
	daylab	<-tmp[locs+1]
	level.range<-c(ll[varloc[v],statloc[s]],ul[varloc[v],statloc[s]])
	is.all.na<- sum(ifelse( !is.na(array(varstat,c( dim(varstat)[1] *  dim(varstat)[2]))),1,0)) == 0

	if(  (statloc[s] == 8 || statloc[s] == 9) &  varloc[v] == 2) {
	 level.range<-range(   mt[,,8,2], mt[,,9,2], na.rm=T, finite=T )
	}
	# Case of mean wind direction plot of model and obs -- This makes color scale the same for both
	if(  (statloc[s] == 8 || statloc[s] == 9) &  varloc[v] == 3) {
	    level.range<-c(0,360)
	}
  if(!is.all.na ) {
  writeLines(paste(plotopts$figure,plotopts$plotfmt,sep="."))
  if (plotopts$plotfmt == "pdf"){pdf(file= paste(plotopts$figure,".pdf",sep=""), width = 11, height = 8.5)	}
  if (plotopts$plotfmt == "png"){ png(file=paste(plotopts$figure,".png",sep=""), width = 1100, height = 1100*8.5/11 )      }
  if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(plotopts$figure,".jpeg",sep=""), width = (700*plotopts$plotsize), height = (541*plotopts$plotsize), quality=100)	}
	  
  if( !exists("imageplot") ) { imageplot <- F  }
	if( imageplot == T) {
    par(tck=0.025)
    par(mgp=c(3,1,0))      
    tmplabs<-c("4","5","6","7","8","9","10","11")
    image(0:23, h, varstat, zlim=level.range, ylim=c(zliml,zlimu), xlim=c(0,23), col =tim.colors(),
          plot.title = title(main = paste("Time-Height",statname[statloc[s]],"of",var[varloc[v]],varunits[varloc[v]]) ),
          xlab = "Time of Day (UTC)", ylab = "Height Above Surface (m)",axes = FALSE)
    contour(0:23,h,varstat, add=T, vfont = c("sans serif", "bold"), drawlabels = T,
            method="edge", labcex= 1.25, lwd=1.75, col="white" )      
    axis(1,at=locs,col=gray(.25),labels=daylab)
    axis(2,col=gray(.85),at=h,labels=h,cex=0.85)
    par(new=T)
    points(0:23, mean.PBL.mod,  ylim=c(zliml,zlimu), xlim=c(0,23),xlab="",ylab="", pch=21, bg="black", col="white")
    box()
	}
	else {
    par(tck=1)
    par(mgp=c(0,0.1,0))      
    filled.contour(0:23,h,varstat,ylim=c(zliml,zlimu),zlim=level.range, color.palette =topo.colors,
    plot.title = title(main = paste("Time-Height",statname[statloc[s]],"of",var[varloc[v]],varunits[varloc[v]]) ),
	  	                 xlab = "Time of Day (UTC)", ylab = "Height Above Surface (m)",
    plot.axes= {	axis(1,at=locs,col=gray(.25),labels=daylab, lwd=1)
    axis(2,col=gray(.85),at=h,labels=h,cex=0.85)}	)
    if( statloc[s] >= 8) {
      par(new=T)
      points(0:23, mean.PBL.mod,  ylim=c(zliml,zlimu), xlim=c(0,23),xlab="",ylab="", pch=21, bg="black", col="white")
	  }
	}
	dev.off()
  }
  if (textstats){
    sfile<-file(paste(figdir,"/tmp",sep=""),"a") 
    writeLines("--------------------------------------------------------", con =sfile)
    writeLines(paste(var[varloc[v]],statname[statloc[s]]," Statistics"), con =sfile)
    close(sfile)
    tmp<-data.frame((height),aperm(varstat,c(2,1)))
    write.table(tmp,paste(figdir,"/tmpx",sep=""),sep=",",col.names=c("Height",paste(0:23,"UTC")),quote=FALSE, row.names=F)
    system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
    system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))
  }
	#########################################################################
	#########################################################################
 }
}
 system(paste("mv ",figdir,"/tmp ",figdir,"/stats.wind.profile.",project,".",statid[sn],".csv",sep=""))
 system(paste("rm -f ",figdir,"/tmp* ",sep=""))
} ## END of Plot Routine

} ## end of sn loop (over site_id's) 

if(!exists("plotSiteMap"))  {  plotSiteMap<-F  }		# For older versions of input set this new flag to F if not defined
###################################################################################################################################
#############################################################################################
# Query for unique sites over the same time period and plot map of site location and id
if(plotSiteMap) {


 datestr	<-paste(" ob_date BETWEEN ",dates$y,dform(dates$m),dform(dates$d)," AND ",datee$y,dform(datee$m),dform(datee$d),sep="")
 query		<-paste("select distinct(stat_id),i,j from",table," WHERE ",datestr)
 data		<-ametQuery(query,mysql)

 siteid_strlength<-length(unlist(strsplit(statid, "")))

 if (statid == "GROUP_AVG") { 
  siteid_strlength<-5
 }

 a<-dim(data)
 if(length(data) == 0){
	writeLines("*********************************************************************")
	writeLines("                                                                     ")
	writeLines(paste("NO Observation site DATA WAS FOUND FOR THIS DAY"))
	writeLines("                                                                     ")
	writeLines("*********************************************************************")
 	q(save="no")
 }
 ns<-length(data[,1])

 psite_id	<-array(NA,c(ns))
 site_i		<-array(NA,c(ns))
 site_j		<-array(NA,c(ns))

 ss<-1
 for(s in 1:ns) {
   strlength<-length(unlist(strsplit(data[s,1], "")))
   if( strlength == siteid_strlength) {
     writeLines(paste("Site and length",data[s,1], strlength, s, data[s,2], data[s,3]))
     psite_id[ss] <- data[s,1] 
     site_i[ss]  <- data[s,2]
     site_j[ss]  <- data[s,3]
     ss<-ss+1
   }
 }

 plotopts$figure<- paste(figdir,"/wind.profile.SITES",sep="")
 plotopts$plotsize <-0.8	
 if (plotopts$plotfmt == "pdf"){pdf(file= paste(plotopts$figure,".pdf",sep=""), width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){bitmap(file=paste(plotopts$figure,".png",sep=""), width = 11, height = 8.5, res=100,pointsize=10*plotopts$plotsize)      }
 if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(plotopts$figure,".jpeg",sep=""), width = (700*plotopts$plotsize), height = (541*plotopts$plotsize), quality=100)	}

 plot(site_i,site_j,pch="", main="ACARS/Airport Sites IDs in Model Domain X-Y Space", xlab="Model X index", ylab="Model Y Index")
 text(site_i,site_j,psite_id,col="red")
 dev.off() 
}
  #############################################################################################

if(!exists("plotSingleProfile"))  {  plotSingleProfile<-F  }		# For older versions of input set this new flag to F if not defined
###################################################################################################################################
  #############################################################################################
  #############################################################################################
if(plotSingleProfile){
  hour<-paste(0:23,"UTC",sep="")
  for( hr in 1:24) {
	plotopts$figure<-paste(figdir,"/profile.COMPS.",project,".",statid,".",hour[hr],sep="")
	
	Tmod	<-mt[hr,,8,1]
	Tobs	<-mt[hr,,9,1]
	WSmod	<-mt[hr,,8,2]
	WSobs	<-mt[hr,,9,2]
	WDmod	<-mt[hr,,8,3]
	WDobs	<-mt[hr,,9,3]
	t	<- 1:nrow(varstat)
	h	<-sort(round(height))
	locs	<-seq(1,24,3)
        
  good_data<- sum(ifelse(is.na(WSmod),0,1))* sum(ifelse(is.na(WSobs),0,1)) != 0

  if(good_data) {
    writeLines(paste(plotopts$figure,plotopts$plotfmt,sep="."))
    if (plotopts$plotfmt == "pdf"){pdf(file= paste(plotopts$figure,".pdf",sep=""), width = 11, height = 8.5)	}
    if (plotopts$plotfmt == "png"){png(file=paste(plotopts$figure,".png",sep=""), width = 1000*plotopts$plotsize, height = 750*plotopts$plotsize)      }
    if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(plotopts$figure,".jpeg",sep=""), width = (700*plotopts$plotsize), height = (541*plotopts$plotsize), quality=100)	}
	
  	# Wind Vectors
  	proflim<-round(range(height))
  	veclength<-1/3
  	WSlims  <-round(range(WSmod-1,WSobs+1, na.rm=T))
  	wsm<-WSmod
  	wso<-WSobs
  	qam<-ifelse(abs(wsm)>100,NA,1)
  	qao<-ifelse(abs(wso)>100,NA,1*qam*veclength)
  	ws<-c(wso,wsm)
  	ws<-ifelse(abs(ws)>100,NA,ws)
  	maxws<-max(wsm,wso,na.rm=T)
  	dlon<-6
  
  	uobs<- -1 * WSobs * sin (WDobs*pi/180)
  	vobs<- -1 * WSobs * cos (WDobs*pi/180)

  	umod<- -1 * WSmod * sin (WDmod*pi/180)
  	vmod<- -1 * WSmod * cos (WDmod*pi/180)

  	yscale<-diff(proflim)/diff(WSlims)
  	xscale<-1

  	x0m<-(diff(WSlims)/3)+WSlims[1];x0o<-(diff(WSlims)*2/3)+WSlims[1]; 
  	y0m<-height;y0o<-height;
  	qao<-qao/5 
  	x1o<-x0o+(uobs)*xscale*qao
  	y1o<-y0o+(vobs)*yscale*qao
  	x1m<-x0m+(umod)*xscale*qao
  	y1m<-y0m+(vmod)*yscale*qao

  	par(mfrow=c(1,3))
    #------------------------------------------------------------------------------------------------------------
    #  Plot Spatial Temperature Bias
  	Tlims  <-round(range(Tmod, Tobs, na.rm=T))
  	if(sum(ifelse(is.na(Tmod),0,1)) == 0) { Tlims<-c(0,1)	}
  	proflim<-round(range(height))
  	par(mai=c(0.35,0.35,0.1,0))
    par(mgp=c(1.5,0.5,0))

  	par(tck=0.02)
  	plot(Tobs,height,xlim=Tlims,ylim=proflim, axes=T,
         ylab="Height (m)", xlab="Potential Temperature (K)",
         type='o',pch=19, col="red")
  	par(tck=1)
  	axis(2,col=gray(.9),at=height,labels=F)

  	par(new=T)
  	plot(Tmod,height,xlim=Tlims,ylim=proflim, axes=F,ylab="", xlab="",type='o',pch=19,col="blue")
   	legend(Tlims[1],proflim[2]-(400*proflim[2]/5000),c("Obs","Model"),col=c("red","blue"),lty=1,lwd=2,cex=1.5)       
    box()
        
    #------------------------------------------------------------------------------------------------------------
    #  Plot Profile Wind Speed 
    #------------------------------------------------------------------------------------------------------------
    proflim<-round(range(height))
    par(mai=c(0.35,0.0,0.1,0))
    par(mai=c(0.35,0.0,0.1,0))
    par(mgp=c(1.5,0.5,0))
    par(tck=0.02)
    plot(WSobs,height,xlim=WSlims,ylim=proflim, axes=T,ylab="Height (m)", xlab="Wind Speed (m s-1)",
         type='o',pch=19, col="red")
    par(tck=1)
    axis(2,col=gray(.9),at=height,labels=F)

    par(new=T)
    plot(WSmod,height,xlim=WSlims,ylim=proflim, axes=F,ylab="", xlab="",type='o',pch=19,col="blue")
   	legend(WSlims[1],proflim[2]-(400*proflim[2]/5000),c("Aircraft","Model"),col=c("red","blue"),lty=1,lwd=2,cex=1.5)       
   	box()
   	#------------------------------------------------------------------------------------------------------------
   	#------------------------------------------------------------------------------------------------------------
   	#  Plot Profile Wind vectors
   	#------------------------------------------------------------------------------------------------------------
   	par(mai=c(0.35,0.0,0.1,0.1))
   	par(mgp=c(1.5,0.5,0))
   	par(tck=0.02)
   	plot(WSobs,height,xlim=WSlims,ylim=proflim, axes=T,
   	     ylab="Height (m)", xlab="Wind Vectors ",
   	     type='o',pch=19, col=NA)
  	par(tck=1)
  	axis(2,col=gray(.9),at=height,labels=F)
  	par(new=T)
  	plot(WSmod,height,xlim=WSlims,ylim=proflim, axes=F, ylab="", xlab="", type='o',pch=19,col=NA)
  	arrows(x0m, y0m, x1m, y1m,length=0.05,col="blue")
  	arrows(x0o, y0o, x1o, y1o,length=0.05,col="red")
   	box()
   	#------------------------------------------------------------------------------------------------------------
  	dev.off()
   }
 }
}

#############################################################################################
if(!exists("errorHistPlot"))  {  errorHistPlot <- F  }		# For older versions of input set this new flag to F if not defined
#############################################################################################
if(errorHistPlot){
	plotopts$figure<-paste(figdir,"/error.Hist.",project,".",statid,sep="")
	Tmean	<- mean(mt[,,5,1],na.rm=T)
	WSmean	<- mean(mt[,,5,2],na.rm=T)
	WDmean	<- mean(mt[,,5,3],na.rm=T)

	writeLines(paste(plotopts$figure,plotopts$plotfmt,sep="."))
	if (plotopts$plotfmt == "pdf"){pdf(file= paste(plotopts$figure,".pdf",sep=""), width = 8.5, height = 11)	}
	if (plotopts$plotfmt == "png"){png(file=paste(plotopts$figure,".png",sep=""), width = 751*plotopts$plotsize, height = 1000*plotopts$plotsize)      }
	if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(plotopts$figure,".jpeg",sep=""), width = (751*plotopts$plotsize), height = (1000*plotopts$plotsize), quality=100)	}

 	par(mfrow=c(3,1))
	#------------------------------------------------------------------------------------------------------------
	#  Plot Spatial Temperature Bias

	par(mai=c(0.35,0.35,0.1,0))
	par(mgp=c(1.5,0.5,0))
        
	good_data<- sum(  ifelse(  is.na(mt[,,5,1]) , 0, 1)) != 0
	if(good_data) {
	  a<-hist(mt[,,5,1], col="gray", border="red", main="", xlab="Potential Temperature RMSE Error Distribution (K)", ylab="Occurances", freq=T)
	  text(max(a$mids),max(a$counts),paste("Mean RMSE: ",format(Tmean,digits=5)," K",sep=""), pos=2)
  }
  good_data<- sum(ifelse(is.na(mt[,,5,2]),0,1)) != 0
  if(good_data) {
    a<-hist(mt[,,5,2], col="gray", border="blue", main="",  xlab="Wind Speed Error Distribution (m/s)", ylab="Occurances", freq=T)
    text(max(a$mids),max(a$counts),paste("Mean RMSE: ",format(WSmean,digits=5)," m/s",sep=""), pos=2)
  }  

  good_data<- sum(ifelse(is.na(mt[,,5,3]),0,1)) != 0
  if(good_data) {
    a<-hist(mt[,,5,3], col="gray", border="green", main="", xlab="Wind Direction Error Distribution (deg)", ylab="Occurances", freq=T)
    text(max(a$mids),max(a$counts),paste("Mean RMSE: ",format(WDmean,digits=5)," deg",sep=""), pos=2)
   }
  dev.off()

}
#############################################################################################
if(!exists("verticalBoxPlot"))  {  verticalBoxPlot <- F  }		# For older versions of input set this new flag to F if not defined
###################################################################################################################################
if(verticalBoxPlot){

  for(v in 1:length(varloc)){
   for(s in 1:length(statlocBP)){

     varstat	<-mt[,,statlocBP[s],varloc[v]]
     is.all.na<- sum(ifelse( !is.na(array(varstat,c( dim(varstat)[1] *  dim(varstat)[2]))),1,0)) == 0
     if(!is.all.na ) {

     plotopts$figure<-paste(figdir,"/boxplot.",project,".",varid[varloc[v]],".",metric[statlocBP[s]],".",statid[sn],sep="")
	
     writeLines(paste(plotopts$figure,plotopts$plotfmt,sep="."))
     if (plotopts$plotfmt == "pdf"){pdf(file= paste(plotopts$figure,".pdf",sep=""), width = 8.5, height = 11)	}
     if (plotopts$plotfmt == "png"){png(file=paste(plotopts$figure,".png",sep=""), width = 751*plotopts$plotsize, height = 1000*plotopts$plotsize)      }
     if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(plotopts$figure,".jpeg",sep=""), width = (751*plotopts$plotsize), height = (1000*plotopts$plotsize), quality=100)	}
	  
     datam  <-matrix();
     heightm<-matrix();
     c<-1
     for(z in 1:length(levs)){
       datam[c:(c+23)] <- varstat[,z]
       heightm[c:(c+23)] <- round(height[z])
       c<-c+24
     }
     df.stats<-data.frame(datam,heightm)
     statlab<- paste(statname[statlocBP[s]],varunits[varloc[v]])
     titles<- paste("Distribution by Height of",statname[statlocBP[s]],"for",var[varloc[v]])
     boxplot.stats.file<- paste(figdir,"/boxp.stats.",metric[statlocBP[s]],".",varid[varloc[v]],".csv",sep="")
          
     if(custom.limits){
       a<-boxplot(datam ~ heightm, data=df.stats, ylab="Height (m)", xlab=statlab, main=titles,
       varwidth=T, horizontal=T, col="bisque", ylim=c(custom.lowlim[s,v],custom.uplim[s,v]))
     }
     else {
       a<-boxplot(datam ~ heightm, data=df.stats, ylab="Height (m)", xlab=statlab, main=titles, varwidth=T, horizontal=T, col="bisque")
     }
     write.table(a$stats,file=boxplot.stats.file,sep=",",col.names=a$names,
                 row.names=c("95thP","75thP","median","25thP","5thP")) 
     dev.off()
     }  
   }
  }
}
#############################################################################################
