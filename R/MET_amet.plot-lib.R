#######################################################################################################
#######################################################################################################
#	
#		AMET Plotting Function Library	
#						
#
#	Version: 	1.1
#	Date:		August 18, 2005
#	Contributors:	Robert Gilliam
#
#	Developed by US EPA
#
# Version 1.2, May 6, 2013, Rob Gilliam
#  - Extensive code cleansing
#	
#-----------------------------------------------------------------------###############################
#######################################################################################################
#######################################################################################################
#	This collection contains the following functions
#
#	plotTseries	--> Plot Surface Meteorological Time Series of T, WS, WD and Q	
#
#	diurnalplot	--> Plot diurnal statistics	
#
#	ametplot	--> Create AMET Model Performance Plot for a particular subset of data	
#
#	plotSpatial	--> Plots spatial statistics 
#
#	plotPrecip	--> Plots NPA-model precip comparison 
#
#######################################################################################################
#######################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Plot Surface Meteorological Time Series of T, WS, WD and Q
#
# Input: model and observation list with mod defined as model
#	 and obs defined as the observation
#   
# Output:  Model statistics matrix
#
# NOTE: The database must have a table names stations (within the AMET framework)
#   
###
 plotTseries	<-function(temp,ws,wd,q,date.vec,plotopts,qclims,
                           comp=FALSE,tsnames=c("Observed","Model 1","Model2"),
                           wdweightws=FALSE) 
  {
  
  
  if (plotopts$plotfmt == "pdf"){pdf(file= paste(plotopts$figure,".pdf",sep=""), width = 8.5, height = 11)	}
  if (plotopts$plotfmt == "png"){bitmap(file=paste(plotopts$figure,".png",sep=""), width = 8.5, height = 11, res=100,pointsize=12*plotopts$plotsize)	}
  if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(plotopts$figure,".jpeg",sep=""), width = (541*plotopts$plotsize), height = (700*plotopts$plotsize), quality=100)	}
 # Apply quality control limits to data
	temp<-ifelse(temp< qclims$qcT[2]  & temp > qclims$qcT[1] , temp, NA)
	q   <-ifelse(q   < qclims$qcQ[2]  & q    > qclims$qcQ[1] ,    q, NA)
	ws  <-ifelse(ws  < qclims$qcWS[2] & ws   > qclims$qcWS[1],   ws, NA)
	wd  <-ifelse(ws  < qclims$qcWS[2] & ws   > qclims$qcWS[1],   wd, NA)

	if(!comp) 	{ leglab<-tsnames[1:2];		tscols<-c("black","red") 	    }
	if(comp)	  { leglab<-tsnames;		tscols<-c("black","red","blue") 	}

	par(mfrow=c(4,1))
	par(bg="white")
	par(fg="black")


#################################################################
	#########################################################
	#	PLOT Mixing Ratio
	##############################
	val<-q

	vallab<-"2-m Mixing Ratio (g kg-1)"
	miny<-min(val,na.rm=TRUE)-2;
	maxy<-max(val,na.rm=TRUE);
	dy<-0.09*(maxy-miny);ps1<-maxy-dy;ps2<-ps1-dy;ps3<-ps2-dy
	##############################
	#	Compute quick stats
	ss<-quickstats(val[,2],val[,1],digs=2)
	ss2<-ss
	ss2$mae<-"";ss2$bias<-"";ss2$ioa<-"";
	seps<-""
	if (comp){
		ss2<-quickstats(val[,2],val[,3],digs=2);seps<-"/"
	}
		
	minval<-1
	maxval<-length(time)
	
  par(new=F)
	par(mai=c(0.25,0.35,0.2,0.1))
	par(mai=c(0,0.35,0.02,0.02))
	par(mgp=c(1.40,0.2,0))
	plot(date.vec,val[,2],xlab="",axes=FALSE,ylab=vallab,xlim=range(date.vec),ylim=c(miny,maxy),
	     pch=4,cex=0.75,col=tscols[1],vfont=c("serif","bold"),label=TRUE,type="l",lwd=1, bg="yellow")
	par(tck=1)
	axis(2,col="black",lty=3)
	par(tck=1)
	axis(1,col="black",lty=3,at=date.vec[seq(1,length(date.vec),by=24)],labels=as.character(date.vec[seq(1,length(date.vec),by=24)]))
	par(new=T)
	plot(date.vec,val[,1],xlim=range(date.vec),ylim=c(miny,maxy),label=FALSE,tick=FALSE,
	     type="l",pch=5,col=tscols[2],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
	par(new=T)
	if (comp){
		plot(date.vec,val[,3],xlim=range(date.vec),ylim=c(miny,maxy),label=FALSE,
		     tick=FALSE,type="l",pch=5,col=tscols[3],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
	}
	title("Observation-Model Time Series",line=-1,outer=T)
  rect(date.vec[1],miny-0.04*(maxy-miny),date.vec[length(date.vec)-2],miny+0.06*(maxy-miny),col="white",border="black")
  legend(date.vec[1],maxy,leglab,col=tscols,lty=1,lwd=2,cex=0.90,xjust=.20)
  statsstr<-paste("Time Series Statistics -->     ","MAE ",ss$mae,seps,ss2$mae,"                 ",
                  "BIAS ",ss$bias,seps,ss2$bias,"                 ",
                  "IOA ",ss$ioa,seps,ss2$ioa)
  text(date.vec[1], miny,statsstr,col="black", pos=4,cex=plotopts$scex)
#################################################################################################



#################################################################
	#########################################################
	#	PLOT Temperature
	##############################
	val<-temp

	vallab<-"2-m Temperature (K)"
	miny<-min(val,na.rm=TRUE)-2;
	maxy<-max(val,na.rm=TRUE);
	dy<-0.09*(maxy-miny);ps1<-maxy-dy;ps2<-ps1-dy;ps3<-ps2-dy
	##############################
	#	Compute quick stats
	ss<-quickstats(val[,2],val[,1],digs=2)
	ss2<-ss
	ss2$mae<-"";ss2$bias<-"";ss2$ioa<-"";
	seps<-""
	if (comp){
		ss2<-quickstats(val[,2],val[,3],digs=2);seps<-"/"
	}
		
	minval<-1
	maxval<-length(time)
	
        par(new=F)
	par(mai=c(0,0.35,0,0.02))
	par(mgp=c(1.40,0.2,0))
	plot(date.vec,val[,2],xlab="",axes=FALSE,ylab=vallab,xlim=range(date.vec),ylim=c(miny,maxy),
	     pch=4,cex=0.75,col=tscols[1],vfont=c("serif","bold"),label=F,tick=F,type="l",lwd=1, bg="yellow")
	par(tck=1)
	axis(2,col="black",lty=3)
	par(tck=1)
	axis(1,col="black",lty=3,at=date.vec[seq(1,length(date.vec),by=24)],labels=as.character(date.vec[seq(1,length(date.vec),by=24)]))
	par(new=T)
	plot(date.vec,val[,1],xlim=range(date.vec),ylim=c(miny,maxy),label=FALSE,tick=FALSE,
	     type="l",pch=5,col=tscols[2],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
	par(new=T)
	if (comp){
		plot(date.vec,val[,3],xlim=range(date.vec),ylim=c(miny,maxy),label=FALSE,
		     tick=FALSE,type="l",pch=5,col=tscols[3],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
	}
  rect(date.vec[1],miny-0.04*(maxy-miny),date.vec[length(date.vec)-2],miny+0.06*(maxy-miny),col="white",border="black")
  statsstr<-paste("Time Series Statistics -->     ","MAE ",ss$mae,seps,ss2$mae,"                 ",
                  "BIAS ",ss$bias,seps,ss2$bias,"                 ",
                  "IOA ",ss$ioa,seps,ss2$ioa)
  text(date.vec[1], miny,statsstr,col="black", pos=4,cex=plotopts$scex)
#################################################################################################


#################################################################
	#########################################################
	#	PLOT Wind Speed
	##############################
	val<-ws

	vallab<-"10-m Wind Speed (m s-1)"
	miny<-min(val,na.rm=TRUE)-1;
	maxy<-max(val,na.rm=TRUE);
	dy<-0.09*(maxy-miny);ps1<-maxy-dy;ps2<-ps1-dy;ps3<-ps2-dy
	##############################
	#	Compute quick stats
	ss<-quickstats(val[,2],val[,1],digs=2)
	ss2<-ss
	ss2$mae<-"";ss2$bias<-"";ss2$ioa<-"";
	seps<-""
	if (comp){
		ss2<-quickstats(val[,2],val[,3],digs=2);seps<-"/"
	}
		
	minval<-1
	maxval<-length(time)
	
        par(new=F)
	par(mai=c(0,0.35,0,0.02))
	par(mgp=c(1.40,0.2,0))
	plot(date.vec,val[,2],xlab="",axes=FALSE,ylab=vallab,xlim=range(date.vec),ylim=c(miny,maxy),
	     pch=4,cex=0.75,col=tscols[1],vfont=c("serif","bold"),label=F,tick=F,type="l",lwd=1, bg="yellow")
	par(tck=1)
	axis(2,col="black",lty=3)
	par(tck=1)
	axis(1,col="black",lty=3,at=date.vec[seq(1,length(date.vec),by=24)],labels=as.character(date.vec[seq(1,length(date.vec),by=24)]))
	par(new=T)
	plot(date.vec,val[,1],xlim=range(date.vec),ylim=c(miny,maxy),label=FALSE,tick=FALSE,
	     type="l",pch=5,col=tscols[2],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
	par(new=T)
	if (comp){
		plot(date.vec,val[,3],xlim=range(date.vec),ylim=c(miny,maxy),label=FALSE,
		     tick=FALSE,type="l",pch=5,col=tscols[3],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
	}
  rect(date.vec[1],miny-0.04*(maxy-miny),date.vec[length(date.vec)-2],miny+0.06*(maxy-miny),col="white",border="black")
  statsstr<-paste("Time Series Statistics -->     ","MAE ",ss$mae,seps,ss2$mae,"                 ",
                  "BIAS ",ss$bias,seps,ss2$bias,"                 ",
                  "IOA ",ss$ioa,seps,ss2$ioa)
  text(date.vec[1], miny,statsstr,col="black", pos=4,cex=plotopts$scex)
#################################################################################################

#################################################################
	#########################################################
	#	PLOT Wind Direction
	##############################
	val<-wd

	vallab<-"10-m Wind Direction (deg)"
	miny<--5;
	maxy<-360;
	dy<-0.09*(maxy-miny);ps1<-maxy-dy;ps2<-ps1-dy;ps3<-ps2-dy
	##############################
	#	Compute quick stats
	ss<-quickstats(val[,2],val[,1],ws[,2],digs=2,wd=TRUE,wdweightws=wdweightws)
	ss2<-ss
	ss2$mae<-"";ss2$bias<-"";ss2$ioa<-"";
	seps<-""
	if (comp){
		ss2<-quickstats(val[,2],val[,3],ws[,2],digs=2,wd=TRUE,wdweightws=wdweightws)
	}
		
	minval<-1
	maxval<-length(time)
	
        par(new=F)
	par(mai=c(.02,0.35,0,0.02))
	par(mgp=c(1.40,0.2,0))
	plot(date.vec,val[,2],xlab="",axes=FALSE,ylab=vallab,xlim=range(date.vec),ylim=c(miny,maxy),
	     pch=4,cex=0.75,col=tscols[1],vfont=c("serif","bold"),label=F,tick=F,type="l",lwd=1, bg="yellow")
	par(tck=1)
	axis(2,col="black",lty=3)
	par(tck=1)
	axis(1,col="black",lty=3,at=date.vec[seq(1,length(date.vec),by=24)],labels=as.character(date.vec[seq(1,length(date.vec),by=24)]))
	par(new=T)
	plot(date.vec,val[,1],xlim=range(date.vec),ylim=c(miny,maxy),label=FALSE,tick=FALSE,
	     type="l",pch=5,col=tscols[2],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
	par(new=T)
	if (comp){
		plot(date.vec,val[,3],xlim=range(date.vec),ylim=c(miny,maxy),label=FALSE,
		     tick=FALSE,type="l",pch=5,col=tscols[3],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
	}
  rect(date.vec[1],miny-0.04*(maxy-miny),date.vec[length(date.vec)-2],miny+0.06*(maxy-miny),col="white",border="black")
  statsstr<-paste("Time Series Statistics -->     ","MAE ",ss$mae,seps,ss2$mae,"                 ",
                  "BIAS ",ss$bias,seps,ss2$bias,"                 ")
  text(date.vec[length(date.vec)],90,"      East",col=gray(.1), pos=3,cex=1.2)
  text(date.vec[length(date.vec)],180,"      South",col=gray(.1), pos=3,cex=1.2)
  text(date.vec[length(date.vec)],270,"      West",col=gray(.1), pos=3,cex=1.2)
  text(date.vec[length(date.vec)],0,"      North",col=gray(.1), pos=3,cex=1.2)
  text(date.vec[1], miny,statsstr,col="black", pos=4,cex=plotopts$scex)
#################################################################################################

  dev.off()
  return()
}
#####--------------------------		END OF FUNCTION 	--------------------------------------####
##########################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Plots diurnal statistics
###  
#
# Input: observed and simulated timeseries in list (var(obs=?,mod=?)), statistics location vector (statloc),
#	 figure name (figure), plotopts list, label list (varname, amet, units)
#   
#   
# Output:  AMET performance plot
#   
#
# Options:
# NOTE: 
#   
##########################################################################################################
    diurnalplot<-function(var,statloc=c(17,18),
 				figure="diurnal",plotopts,
 				labels=list(varname="",amet="NOAA/EPA AMET Product",units=""))
 {
  ##########################################################################
  # Cycle through each hour of the day and compute diurnal statistics 
   dstats	<-array(NA,c(24,length(statloc)))
   allstats	<-array(NA,c(24,25))
   for(h in 1:24){
       ind<-(h-1) == var[,1]
       if( length(var[ind,3]) == 0 ) { next;	}
       stats		<-genvarstats(list(obs=var[ind,3],mod=var[ind,2]),"Temperature (2m)")
       dstats[h,]	<-stats$metrics[statloc]
       allstats[h,]	<-stats$metrics   
   }
   statsAllHours<-genvarstats(list(obs=var[,3],mod=var[,2]),"Temperature (2m)")
   allstatsx<-list(metrics=allstats,id=stats$id,name=stats$name,allHoursStats=statsAllHours$metrics[statloc])
  ##########################################################################
 
  #################################################################################################################################
  #	GENERATE DIURNAL STATISTICS PLOT
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  if (plotopts$plotfmt == "pdf"){writeLines(paste(figure,".pdf",sep=""));pdf(file= paste(figure,".pdf",sep=""), width = 10, height = 5)	}
  if (plotopts$plotfmt == "bmp"){writeLines(paste(figure,".png",sep=""));bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, height = (350*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)	}
  #if (plotopts$plotfmt == "png"){writeLines(paste(figure,".png",sep=""));png(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize), height = (350*plotopts$plotsize), pointsize=10*plotopts$plotsize)	}
  if (plotopts$plotfmt == "jpeg"){writeLines(paste(figure,".jpeg",sep=""));jpeg(file=paste(figure,".jpeg",sep=""), width = (700*plotopts$plotsize), height = (350*plotopts$plotsize), quality=100)	}
  if (plotopts$plotfmt == "png"){writeLines(paste(figure,".png",sep=""));bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, height = (350*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)	}
  #:::::::::::::::::::::::::::::::::::::::::::::::


  ##############################################
  # Compute data limits for axis specs, generate labels, line colors, etc
  maxs<- ceiling(max(dstats,na.rm=TRUE)*1.10)
  mins<- (min(dstats,na.rm=TRUE)*1.05)
  ylim<-c(mins,maxs)
  ylocs<-c(-5,-4,-3,-2,-1,0,1,2,3,4,5)
  if(labels$units == "deg"){
        ylocs<-c(-90,-60,-40,-30,-20,-10,0,10,20,30,40,60,90)
#       ylim<-c(-90,90)  
       ylim<-c(mins,maxs)
  }

  ylabs<-ylocs
  h<-0:23
  xlim<-c(0,23)
  xlocs<-seq(0,23,3)
  xlabs<-paste(xlocs)

  linecols<-c(2,4,gray(.10),gray(.10),gray(.10))
  linecols<-c(2,4,3,5,6)
  ylinescol<-gray(0.80)
  legbg<-'white'
  linetype<-c(1,1,1,1,1)
  pchtype<-c(0,1,4,5,6)
  par(mgp=c(2,0.5,0))
  par(tcl=0.50)
  ##############################################

  ##############################################
  # LOOP THROUGH STATISITIC and plot
  for (s in 1:length(statloc)){

     #  First time through POST plotting commands
     if(s == 1) {
        par(new=FALSE)
	plot(h,dstats[,s],xlim=xlim, ylim=ylim,xlab="Time of Day (UTC)",ylab=paste("Evaluation Metric (",labels$units,") ",sep=""),
	     label=FALSE,tick=FALSE,lty=linetype[s],pch=pchtype[s],col=linecols[s],type="b",lwd=2, axes=F )   		
        ng<-1000; ss<-10; e<-12; dd<-(e-ss)/ng
        #rect(-1,ylim[1]-10,ss,ylim[2]+10,col="black",border=F)
        for(i in 1:ng) {
            g<-gray(i/ng)
        #    rect(ss,ylim[1]-10,ss+dd,ylim[2]+10,col=g,border=F)
            ss<-ss+dd
        }
        ng<-100; ss<-22; e<-24; dd<-(e-ss)/ng
        for(i in 1:ng) {
            g<-gray(1-(i/ng))
        #    rect(ss,ylim[1]-10,ss+dd,ylim[2]+10,col=g,border=F)
            ss<-ss+dd
        }
   	par(tck=1)
	axis(1,at=xlocs,labels=xlabs,cex=1.25,col=ylinescol,lty=2)
	axis(2,at=ylocs,labels=ylabs,cex=1.25,col=ylinescol,lty=2)
        par(new=TRUE)
	plot(h, dstats[,s], xlim=xlim, ylim=ylim, label=FALSE, ylab="", xlab="", tick=FALSE, label=FALSE,
	     lty=linetype[s], pch=pchtype[s], col=linecols[s], type="b", lwd=2,  axes=F )
	lines(c(-1,24),c(0,0),col=gray(0.50),lwd=3)       		
     }
     #############################	
     #############################
     #  Additional time through POST plotting commands
     if(s > 1) {
        par(new=TRUE)
	plot(h,dstats[,s],xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
	     lty=linetype[s],pch=pchtype[s],col=linecols[s],type="b",lwd=2, axes=F )   		
     		
     }
     if(s == length(statloc)){
         legend(length(h), ylim[2], stats$id[statloc], col = linecols, lty = 1, bg=legbg, pch=pchtype, xjust=1, yjust=1)
         box()
     }
     #############################
	
   }
   title(paste("Diurnal Statistics for",labels$varname),line=1)

   dev.off()
  ###############################################
  #	END PLOT				#
  ###############################################

 return(allstatsx)
}
#####--------------------------		END OF FUNCTION 	--------------------------------------####
##########################################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Create AMET Model Performance Plot for a particular subset of data
#
# Input: statistics array (AMET style, diurnal dimensions 
#	 (hour of day, forecast hour, variable, stat value)
#	
#   
# Output:  Model performance plot
#
# NOTE: 
#   
###
######################################################################################################
#		
#	INPUT: 
######################################################################################################
    ametplot<-function(obs,mod,wso,metrics,qdesc=FALSE,pid=1,figureid="web.pdf",wdflag=0,plotopts){

 	server<-	"NONE"
	dbase<-		"NONE"
	login<-		"NONE"
	pass<-		"NONE"
	project<-	"NONE"
	model<-		"NONE"
	queryID<-	"NONE"	
	varid<-		"NONE"	
	statid<-	"NONE"	
	obnetwork<-	"NONE"	
	lat<-		"NONE"		
	lon<-		"NONE"
	elev<-		"NONE"	
	landuse<-	"NONE"	
	obdatestart<-	"NONE"		
	obdateend<-	"NONE"		
	obtime<-	"NONE"		
	fcasthr<-	"NONE"		
	level<-		"NONE"	
	syncond<-	"NONE"	
	state<-		"NONE"
	query<-		"NONE"
################################ 
	server<-	qdesc[1]	# then just fill in with NULL data, else define descriptor
	dbase<-		qdesc[2]	# variables that are used in this plotting function
	login<-		qdesc[3]
	pass<-		qdesc[4]
	project<-	qdesc[5]
	model<-		qdesc[6]
	queryID<-	qdesc[7]	
	varid<-		qdesc[8]	
	statid<-	qdesc[9]	
	obnetwork<-	qdesc[10]	
	lat<-		qdesc[11]		
	lon<-		qdesc[12]
	elev<-		qdesc[13]	
	landuse<-	qdesc[14]	
	obdatestart<-	qdesc[15]		
	obdateend<-	qdesc[16]		
	obtime<-	qdesc[17]		
	fcasthr<-	qdesc[18]		
	level<-		qdesc[19]	
	syncond<-	qdesc[20]	
	state<-		qdesc[21]
	query<-		qdesc[22]

###############################################
#   Set plot margins and figure name 
	
	# Open Web figure in cache directory
	
  if (plotopts$plotfmt == "pdf"){pdf(file= paste(figure,".pdf",sep=""), width = 8.5, height = 11)	}
  if (plotopts$plotfmt == "bmp"){bitmap(file=paste(figure,".png",sep=""), width = (541*plotopts$plotsize)/100, height = (700*plotopts$plotsize)/100, res=100)	}
  if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(figure,".jpeg",sep=""), width = (541*plotopts$plotsize), height = (700*plotopts$plotsize), quality=100)	}
  if (plotopts$plotfmt == "png"){bitmap(file=paste(figure,".png",sep=""), width = (541*plotopts$plotsize)/100, height = (700*plotopts$plotsize)/100, res=100)	}


	
	px1<-array(,)
	px2<-array(,)
	py1<-array(,)
	py2<-array(,)
	
	px1[1]<-0.01; px2[1]<-9.99; py1[1]<-0.01; py2[1]<-9.99		#	Top Title
	px1[2]<-0.10; px2[2]<-9.90; py1[2]<-8.50; py2[2]<-9.90		#	Top Information
	px1[3]<-0.25; px2[3]<-6.00; py1[3]<-4.00; py2[3]<-8.25		#	Scatter Plot
	px1[4]<-0.35; px2[4]<-5.85; py1[4]<-0.50; py2[4]<-3.50		#	Range-Stats Plot
	px1[5]<-6.50; px2[5]<-9.90; py1[5]<-0.30; py2[5]<-3.80		#	Histogram
	px1[6]<-6.15; px2[6]<-9.90; py1[6]<-4.25; py2[6]<-8.30		#	Tables Stats


###################################################################################################
#------------------------------------------------------------------------------------------------##
#----				Top Table Description Zone 				-------####
###################################################################################################
	#writeLines("Plotting dataset information, table statistics and boarders ...... ")
	par(new=FALSE)
	par(mai=c(0,0,0,0))
	x<-c(0,1)
	y<-c(0,1)
	
	par(fig=c(px1[1],px2[1],py1[1],py2[1])/10)
	# Plot Rectangle that outlines table area
	plot(x,y, axes=TRUE, type='n',xlab='',ylab='',tick=FALSE,labels=FALSE )

	par(new=TRUE)
	par(fig=c(px1[2],px2[2],py1[2],py2[2])/10)
	# Plot Rectangle that outlines table area
	plot(x,y, axes=TRUE, type='n',xlab='',ylab='',tick=FALSE,labels=FALSE )

	head<-array(NA,c(3,3,2))
	head[1,1,1]<-"Model";head[1,2,1]<-"Station";head[1,3,1]<-"Date Range";
	head[1,1,2]<-model  ;
	head[1,2,2]<-statid   ;
	head[1,3,2]<-paste(obdatestart," to ",obdateend);
#	if (obdatestart == "")	{	head[1,3,2]<-paste("All days")	}
#	if(statid == "")		{	head[1,2,2]<-"All Stations"		}
#	if(model == "")			{	head[1,1,2]<-project			}
	
	head[2,1,1]<-"Model Run";head[2,2,1]<-"Network";head[2,3,1]<-"Time of Day";
	head[2,1,2]<-project    
	head[2,2,2]<-obnetwork
	head[2,3,2]<-obtime
#	if(obnetwork == ""){		head[2,2,2]<-"All Networks"			}
#	if(obtime    == ""){		head[2,3,2]<-"All Times"			}

	head[3,1,1]<-"Variable";head[3,2,1]<-"Query ID";head[3,3,1]<-"Forecast Hour";
	head[3,1,2]<-varid     ;head[3,2,2]<-queryID   ;head[3,3,2]<-fcasthr;
#	if(fcasthr    == ""){		head[3,3,2]<-"All forecasts"			}

	##########################################################################
	colxmod<-c(0.50,0.40,0.60)
	topdiv <-0.85
	margx  <-0.0
	spaceV<-topdiv/length(head[,1,1])
	spaceH<- 0.90*((1-margx)/length(head[1,,1]))


	for(c in 1:length(head[1,,1])){
		for(r in 1:length(head[,1,1])){
		
			x1<-margx+spaceH*(c-1)
			x2<-margx+spaceH*(colxmod[c])+spaceH*(c-1)
			y<-topdiv-spaceV*r
			text(x1,y,paste(head[r,c,1],":"),offset = 0.5, adj=c(0,0),vfont=c("serif","bold"),cex=1.0  )
			text(x2,y,head[r,c,2],offset = 0.5, adj=c(0,0),cex=.80 ,vfont=c("serif","plain") )

		}
	}
	par(font=6)
	text(0.5,topdiv+0.03,"Model Performance Report",offset = 0.5, vfont=c("serif","bold"),cex=1 )	
	par(font=1)
	
###################################################################################################
#------------------------------------------------------------------------------------------------##
#--------				Scatter Plot 			         	-------####
###################################################################################################
	#writeLines("Plotting scatter of data ...... ")
	par(new=TRUE)
	mino<-min(obs,na.rm=TRUE);minm<-min(mod,na.rm=TRUE);minval<-min(mino,minm);
	maxo<-max(obs,na.rm=TRUE);maxm<-max(mod,na.rm=TRUE);maxval<-max(maxm,maxm);
	xl<-c(minval,maxval);yl<-c(minval,maxval);
	par(mgp=c(-2.5,-1.30,0))
	par(tcl=0.20)
	par(fig=c(px1[3],px2[3],py1[3],py2[3])/10)

	if (wdflag == 1){
		wdScatter(wso,mod,10,2,0.5)
       		mtext("Wind Direction Error",side=3,outer = FALSE, col=1, cex=1.25)
	}
	else {
		plot(obs,mod,xlab="Observed", ylab="Predicted",xlim=c(minval,maxval),ylim=c(minval,maxval),pch="o",cex=0.5)
		mnv<-minval;mxv<-maxval
		x<-c(mnv,mxv)
		y<-c(mnv,mxv)
		lines(x,y,col=4,lwd=3)
       		mtext("Observation-Model Scatter",side=3,outer = FALSE, col=1, cex=1.25)
        }
###################################################################################################
#------------------------------------------------------------------------------------------------##
#--------			Stats-Over-Range Plot  			         	-------####
###################################################################################################
	#writeLines("Plotting major statistics over the range of data ...... ")

	if (varid == "WD"){obs<-wso}
		
	par(new=TRUE)
	div<-20
	maxval<-mean(obs,na.rm=TRUE)+2*sd(obs,na.rm=TRUE)
	minval<-mean(obs,na.rm=TRUE)-2*sd(obs,na.rm=TRUE)
	if(minval < min(obs,na.rm=TRUE)){
	   minval<-min(obs,na.rm=TRUE)
	}
	if(maxval > max(obs,na.rm=TRUE)){
	   maxval<-max(obs,na.rm=TRUE)
	}

	range<-maxval-minval
	int<-range/div
	
	
	b<-hist(obs,breaks=div,plot=FALSE)
	breaks<- b$breaks
	mid<- b$mids
	div<-length(mid)
	interval<-(breaks[2]-breaks[1])

	if (varid == "WS" || varid == "WD"){    minval<-1; maxval<-10; mid<-2:11; interval<-1    }   # Hard-coded intervals for wind speed and direction

	rangex<-array(,)
	rangestats<-array(,c(length(mid),3))
	for(n in 1:length(mid)) {
		obs2<-obs[(obs < mid[n]+(interval)/2) & (obs > mid[n]-(interval)/2)]
		mod2<-mod[(obs < mid[n]+(interval)/2) & (obs > mid[n]-(interval)/2)]
		diff2<-mod2-obs2
		zero<-array(0,length(mod2))
		if(length(obs2) > 1) {

		        rangex[n]<-mid[n]
			if (varid == "WD"){
				rangestats[n,1]<-sqrt(var(mod2,na.rm=T))
				rangestats[n,2]<-mean(abs(mod2),na.rm=T)		# AMD Model evaluation statistics
				rangestats[n,3]<-mean(mod2,na.rm=T)
			}
			else {
				rangestats[n,1]<-sqrt(var(mod2-obs2,na.rm=T))
				rangestats[n,2]<-mean(abs(mod2-obs2),na.rm=T)		# AMD Model evaluation statistics
				rangestats[n,3]<- mean(mod2,na.rm=T)-mean(obs2,na.rm=T)
			}
		}
		else {
		        rangex[n]<-NA
			rangestats[n,1]<-NA
			rangestats[n,2]<-NA		# AMD Model evaluation statistics
			rangestats[n,3]<-NA
		
		}
	}
        rm(obs2);rm(mod2)
	good<-is.na(rangestats[,1]) | is.na(rangestats[,2])| is.na(rangestats[,3])
	rangex<-mid[!good]
	stdev	<-rangestats[!good,1]
	mae	<-rangestats[!good,2]
	bias	<-rangestats[!good,3]

	rng<-c(min(bias),max(stdev,mae))
	miny<-rng[1]- 0.04*abs(diff(rng))
	maxy<-rng[2]+ 0.04*abs(diff(rng))
	
	par(tck=1)
	par(mgp=c(-1.25,0,0))
	par(fig=c(px1[4],px2[4],py1[4],py2[4])/10)
	plot(rangex,stdev,xlab="Observed Range", ylab="Statistics Value",xlim=c(minval,maxval),ylim=c(miny,maxy),pch="o",cex=0.5,col=4,vfont=c("serif","bold") )
	lines(rangex,stdev,col=4 )
	lines(rangex,mae,col=2)
	lines(rangex,bias,col=3 )
        mtext("Statistical Metrics versus Observation Range",side=3,outer = FALSE, col=1, cex=1.25)
	x<-maxval+0.04*(maxval-minval)
	y<-maxy+0.04*(maxy-miny)
	legend(x,y,c("StDev","MAE","BIAS"),col=c(4,2,3),lty=1,bg=gray(.9),bty=1,xjust=1,yjust=1)
###################################################################################################
#------------------------------------------------------------------------------------------------##
#--------				Histogram Plot  			      	-------####
###################################################################################################
	#writeLines("Plotting histogram of model error ...... ")
	histlab<-"Obs and Mod Box Plots"
	if (varid == "WD"){histlab<-"Wind Dir Error Histogram"}
	par(new=TRUE)
	
	vhMin=min(mod-obs,na.rm=TRUE)
	vhMax=max(mod-obs,na.rm=TRUE)

	par(tck=NA)
	par(tcl=0.20)
	par(mgp=c(-1.15, 0, 0))
	par(fig=c(px1[5],px2[5],py1[5],py2[5])/10)

	if(wdflag == 1){
	     hist(mod-obs, breaks =80, freq=FALSE, col="wheat2", border="gray",xlim=c(vhMin,vhMax),main="",xlab="")
	}
	else {
	     boxplot(obs,mod,names=c("Obs","Mod"),col=c("red","blue"))	
	}
        mtext(histlab,side=3,outer = FALSE, col=1, cex=1.2)
###################################################################################################
#------------------------------------------------------------------------------------------------##
#----				Lower-Left Table Description Zone 			---------##
###################################################################################################
	#writeLines("Plotting dataset information, table statistics and boarders ...... ")
	par(new=TRUE)
	
	x<-c(0,1)
	y<-c(0,1)
	
	par(fig=c(px1[6],px2[6],py1[6],py2[6])/10)
	
	# Plot Rectangle that outlines table area
	plot(x,y, axes=TRUE, type='n',xlab='',ylab='',tick=FALSE,labels=FALSE )
	
	# Define the metrics to plot from the original metrics array
	metricsID<-c("maxO","minO","meanO","medianO","sumO","varO","maxM","minM","meanM","medianM","sumM","varM",
	"cor","var","sdev","magerror","mbias","mfbias","mnbias","mngerror","nmbias","nmerror","rmserror","length")
	metricsLength<-length(metricsID)
	m2<-array(,);m2id<-array(,)

	adjustment<-mean(obs,na.rm=TRUE)/(max(range(obs,na.rm=TRUE),range(mod,na.rm=TRUE))-min(range(obs,na.rm=TRUE),range(mod,na.rm=TRUE)))
	
	m2[1]<-format(metrics[1],digits=5);             m2id[1]<-'Data count                 ';
	m2[2]<-format(metrics[14],digits=5);            m2id[2]<-'Correlation                ';
	m2[3]<-format(metrics[16],digits=5);            m2id[3]<-'Standard Deviation         ';
	m2[4]<-format(metrics[17],digits=5);            m2id[4]<-'Mean Absolute Error        ';
	m2[5]<-format(metrics[18],digits=5);            m2id[5]<-'Mean Bias                  ';
	m2[6]<-format(metrics[19],digits=5);	        m2id[6]<-'*Mean Fractional Bias (%)  ';
	m2[7]<-format(metrics[20]*adjustment,digits=5); m2id[7]<-'*Mean Normalized Bias (%)  ';
	m2[8]<-format(metrics[21]*adjustment,digits=5); m2id[8]<-'*Mean Normalized Error (%) ';
	m2[9]<-format(metrics[22]*adjustment,digits=5); m2id[9]<-'*Normalized Mean Bias (%)  ';
	m2[10]<-format(metrics[23]*adjustment,digits=5);m2id[10]<-'*Normalized Mean Error (%)';
	m2[11]<-format(metrics[24],digits=5);           m2id[11]<-'Root-Mean-Sqr-Error       ';
	m2[12]<-format(metrics[25],digits=5);           m2id[12]<-'Index of Agreement        ';
	
	if (wdflag == 1){m2[2]="n/a";m2[6:10]="n/a";m2[12]="n/a"}
	
	lmarg1<-	0.01
	lmarg2<-	0.75

	topstart<-0.85;topline<-topstart+0.05
	space<-topstart/(length(m2))

	lines(c(0,1),c(topline,topline))
	lines(c(lmarg2-0.05,lmarg2-0.05),c(.05,topline))

	text(0.5,(1-(1-topline)/2),"Model Performance Statistics",cex=1.2)
	text(0.5,0.005,"* Stats are normalized by observation range",cex=0.8)
	
	x1<-lmarg1
	x2<-lmarg2
	y<-topstart-0.02
	for(v in 1:length(m2)){
		text(x1,y,m2id[v],offset = 0.5, adj=c(0,0),cex=0.85 )
		text(x2,y,m2[v],offset = 0.5, adj=c(0,0),cex=0.85 )
		y<-y-(space)
	}	
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------


	dev.off() 
 }
#####--------------------------		END OF FUNCTION 	--------------------------------------####
##########################################################################################################
##########################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Create wind direction error scatter plot
#
# Input:  observed wind speed (obs), wind direction error (wdd), radius of plot in m/s
#	   	plot color (dc), minimum wind speed allowed (fr=0.5 m/s)
#   
# Output:  wind direction as function of wind speed plot
#
# NOTE: 
# 		wdScatter(wso,mod,10,2,0.5)  
######################################################################################################
  wdScatter <- function(obs,wdd,radius=10,dc=2,fr=0.50) {

	mean(wdd)
		a<-runif(length(obs),min=0,max=1)
		x<-((obs+a)*sin(wdd*3.14/180))
		y<-((obs+a)*cos(wdd*3.14/180))

	min<-min(min(x),min(y))
	max<-max(max(x),max(y))
	writeLines(paste(min,max,sep="   "))
	min<--radius;max<-radius;
	plot(x,y,axes=FALSE, tick=TRUE,labels=TRUE,pch=".",cex=2,xlab='',ylab='',xlim=c(min,max),ylim=c(min,max),col=dc)

 	deg<-c(1:360)
        for (i in 2:radius-1) {
		r<-i
		cx<-((i)*sin(deg*3.14/180))
		cy<-((i)*cos(deg*3.14/180))

		if(i < radius){
			polygon(cx,cy,lty=3)
		}
		else {
			polygon(cx,cy)
		}
		text(r+0.25,0.25,paste(r))
		text(-r+0.25,0.25,paste(r))
        }
        
	lines(c(0,0),c(min,max),lw=2)
        lines(c(min,max),c(0,0),lw=2)
	cx<-((radius)*sin(deg*3.14/180))
	cy<-((radius)*cos(deg*3.14/180))
	polygon(cx,cy)
	radius<-fr
	cx<-((radius)*sin(deg*3.14/180))
	cy<-((radius)*cos(deg*3.14/180))
	polygon(cx,cy,col=1)

	j<-0;radius<-10;offset<-0.5

	for (i in 1:12) {
		cx<-((radius)*sin(j*3.14/180))
		cy<-((radius)*cos(j*3.14/180))
		lines(c(0,cx),c(0,cy),lty=3)

		lab<-j
		if (lab > 180){lab<-lab-360;}

		labx<-((radius+offset)*sin(j*3.14/180))
		laby<-((radius+offset)*cos(j*3.14/180))
		text(labx,laby,paste(lab))
		j<-j+30
	}

}
#####--------------------------		END OF FUNCTION 	--------------------------------------####
##########################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Plot station (point) data spatially.
#
# Input:  This funtion requires a list (sinfo) which contains subsets
#	  latitude (lat), longitude (lon) and value to plot (plotval).
#	  Also, the plot title, figure and optional number of levels. 
#	  Default levels is 10.
#   
# Output:  PDF plot 
#   
#
# Options: Number of intervals in coloring
#
# statid<-c("Count","Correlation","Anomoly correlation","Variance","Standard deviation","RMSE","Mean Absolute Error",
#           "Mean bias","Mean Fractional Bias","Mean Normalized Bias","Mean Normalized Gross Error",
#           "Normailized mean bias","Normalized mean error")
# maxallow<-c(5)
#     levs     <-c(0,1,2,3,4)
#     levcols  <-c("green","blue","yellow","red")
#     statloc<-7
#     title<-paste(statid[statloc]," Distribution")
#     figure<-"test.pdf"
#     plotval<-sstats$metrics[,statloc]
#     sinfo<-list(lat=sstats$lat,lon=sstats$lon,plotval=plotval,levs=levs,levcol=levscols)
#
# NOTE:  Future version will allow user to specify a color scheme and levels
#   
###
 	plotSpatial<-function(sinfo,varlab,figure="spatial",nlevs=0,
 	                      bounds=c(24,50,-120,-60),plotopts=plotopts,
 	                      histplot=F,shadeplot=F,sres=0.25, map.db="worldHires")
 {
######################################################################################################
# Open Figure  for plot functions
  if (plotopts$plotfmt == "pdf"){pdf(file= paste(figure,".pdf",sep=""), width = 11, height = 8.5)	}
  if (plotopts$plotfmt == "png"){bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, height = (541*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)	}
  if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(figure,".jpeg",sep=""), width = (700*plotopts$plotsize), height = (541*plotopts$plotsize), quality=100)	}

  sinfo$plotval<-ifelse(abs(sinfo$plotval) > max(sinfo$levs),NA,sinfo$plotval)	
  pcols<-array(NA,c(length(sinfo$plotval)))

  pcols<-sinfo$levcols[cut(sinfo$plotval,br=sinfo$levs,labels=FALSE,include.lowest=T,right=T)]
  if(max(abs(na.omit(sinfo$plotval))) <= 1 ){
    sinfo$convFac<-1
  }
# Set map symbols and calculate size based on relative data magnitude
  spch		<-plotopts$symb		#	Symbol (19-solid circle, )
  mincex	<-0.65
  scex		<-mincex+(abs(sinfo$plotval)/max(sinfo$levs))
  scex		<-plotopts$symbsiz
  lonw<- bounds[3]
  lone<- bounds[4]
  lats<-bounds[1]
  latn<-bounds[2]

  lats <- lats + (lats-latn)/10
  lone <- lone + (lone-lonw)/15 

  legoffset<- (1/50)*(lone-lonw)
# Plot Map and values
  m<-map('usa',plot=FALSE)
  map(map.db, xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1)
  map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, add=T)
  points(sinfo$lon,sinfo$lat,pch=spch, cex=scex, col=pcols)
  box()
  
# Draw legend
  levLab<-sinfo$levs[1:(length(sinfo$levs)-1)]*sinfo$convFac
  #legend(lone-legoffset,lats+2*legoffset,levLab,col=sinfo$levcols,pch=spch,xjust=1,yjust=0, pt.cex=0.75, cex=0.75)
  legend(lone,lats,levLab,col=sinfo$levcols,pch=spch,xjust=1,yjust=0, pt.cex=0.75, cex=0.75)

# Draw Title
  title(main=paste(varlab[1]),cex.main = 0.90, line=0.25)
#    
  #text(lonw+legoffset,lats+legoffset,"An Atmospheric Model Evaluation Tool (AMET) Product",adj=c(0,1),cex=0.75)
  dev.off() 
 
 if(histplot){
  if (plotopts$plotfmt == "pdf"){pdf(file= paste(figure,".hist.pdf",sep=""), width = 11, height = 8.5)	}
  if (plotopts$plotfmt == "png"){bitmap(file=paste(figure,".hist.png",sep=""), width = (700*plotopts$plotsize)/100, height = (541*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)	}
  if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(figure,".hist.jpeg",sep=""), width = (700*plotopts$plotsize), height = (541*plotopts$plotsize), quality=100)	}

  histvals<-ifelse(sinfo$plotval > max(sinfo$levs),max(sinfo$levs),sinfo$plotval)
  histvals<-ifelse(histvals < min(sinfo$levs),min(sinfo$levs),histvals)
  if (length(na.omit(histvals)) > 0){
 	hist(histvals,breaks=sinfo$levs,col=sinfo$levcols,freq=T,ylab="Number of Sites",xlab=varlab[1],main="")
  }
  dev.off()
 } 

 if(shadeplot){
  if (plotopts$plotfmt == "pdf"){pdf(file= paste(figure,".shade.pdf",sep=""), width = 11, height = 8.5)	}
  if (plotopts$plotfmt == "png"){bitmap(file=paste(figure,".shade.png",sep=""), width = (700*plotopts$plotsize)/100, height = (541*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)	}
  if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(figure,".shade.jpeg",sep=""), width = (700*plotopts$plotsize), height = (541*plotopts$plotsize), quality=100)	}

  dat<-na.omit(cbind(sinfo$lon,sinfo$lat,sinfo$plotval))
  lon<-dat[,1]
  lat<-dat[,2]
  dat<-dat[,3]
  val<-interp(lon,lat,dat,xo=seq(lonw,lone,by=sres),yo=seq(lats,latn,by=sres))
  image(val,xlim=c(lonw,lone),ylim=c(lats,latn),breaks=sinfo$levs,col=sinfo$levcols[1:(length(sinfo$levs)-1)])
  map("worldHires",xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, add=T)
  map("state",xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, fill=F, bg="black", lty = 1, add=T)
  box()
  
# Draw legend
  levLab<-sinfo$levs[1:(length(sinfo$levs)-1)]*sinfo$convFac
  legend(lone-legoffset,lats+2*legoffset,levLab,col=sinfo$levcols,pch=spch,xjust=1,yjust=0)

# Draw Title
  title(main=paste(varlab[1]),cex.main = 0.90)

  #text(lonw+legoffset,lats+legoffset,"An Atmospheric Model Evaluation (AMET) Product",adj=c(0,1),cex=0.75)
  dev.off() 
 } 

  
 }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################
###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Plot station (point) data spatially.
#
# Input:  This funtion requires a list (sinfo) which contains subsets
#	  latitude (lat), longitude (lon) and value to plot (plotval).
#	  Also, the plot title, figure and optional number of levels. 
#	  Default levels is 10.
#   
# Output:  PDF plot 
#   
#
# Options: Number of intervals in coloring
#
# statid<-c("Count","Correlation","Anomoly correlation","Variance","Standard deviation","RMSE","Mean Absolute Error",
#           "Mean bias","Mean Fractional Bias","Mean Normalized Bias","Mean Normalized Gross Error",
#           "Normailized mean bias","Normalized mean error")
# maxallow<-c(5)
#     levs     <-c(0,1,2,3,4)
#     levcols  <-c("green","blue","yellow","red")
#     statloc<-7
#     title<-paste(statid[statloc]," Distribution")
#     figure<-"test.pdf"
#     plotval<-sstats$metrics[,statloc]
#     sinfo<-list(lat=sstats$lat,lon=sstats$lon,plotval=plotval,levs=levs,levcol=levscols)
#
# NOTE:  Future version will allow user to specify a color scheme and levels
#   
###
 	plot_multipleSpatial<-function(sinfo,varlab,figure="spatial",nlevs=0,
 	                               bounds=c(24,50,-120,-60),plotopts=plotopts,
 	                               histplot=F,shadeplot=F,sres=0.25)
 {
######################################################################################################
#---------------------------------------------------------------------------------------------------##
######################################################################################################
# Open Figure  for plot functions
  if (plotopts$plotfmt == "pdf"){pdf(file= paste(figure,".pdf",sep=""), width = 11, height = 8.5)	}
  if (plotopts$plotfmt == "png"){bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, height = (541*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)	}
  if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(figure,".jpeg",sep=""), width = (700*plotopts$plotsize), height = (541*plotopts$plotsize), quality=100)	}

  sinfo$plotval<-ifelse(abs(sinfo$plotval) > max(sinfo$levs),NA,sinfo$plotval)	
  pcols<-array(NA,c(length(sinfo$plotval)))

  pcols<-sinfo$levcols[cut(sinfo$plotval,br=sinfo$levs,labels=FALSE,include.lowest=T,right=T)]
  if(max(abs(na.omit(sinfo$plotval))) <= 1 ){
    sinfo$convFac<-1
  }
# Set map symbols and calculate size based on relative data magnitude
  spch		<-plotopts$symb		#	Symbol (19-solid circle, )
  mincex	<-0.65
  scex		<-mincex+(abs(sinfo$plotval)/max(sinfo$levs))
  scex		<-plotopts$symbsiz
  lonw<- bounds[3]
  lone<- bounds[4]
  lats<-bounds[1]
  latn<-bounds[2]
  legoffset<- (1/50)*(lone-lonw)
# Plot Map and values
  m<-map('usa',plot=FALSE)
  map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1)
  map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, add=T)
  points(sinfo$lon,sinfo$lat,pch=spch, cex=scex, col=pcols)
  box()
  
# Draw legend
  levLab<-sinfo$levs[1:(length(sinfo$levs)-1)]*sinfo$convFac
  legend(lone-legoffset,lats+2*legoffset,levLab,col=sinfo$levcols,pch=spch,xjust=1,yjust=0, pt.cex=0.75, cex=0.75)

# Draw Title
  title(main=paste(varlab[1]),cex.main = 0.90, line=0.25)

  #text(lonw+legoffset,lats+legoffset,"An Atmospheric Model Evaluation (AMET) Product",adj=c(0,1),cex=0.75)
  dev.off() 
   
 }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Plots NPA-based precipitation fields including the observed (NPA)
#    modeled, the difference between observed and modeled as well as
#    the hit/miss/false alarm plots.
#
# Input: 	AMET style precipiation list (e.g. list(obs,mod1,mod2,etc))
#		Directory for plots to be generated
#		Number of levels to plot
#
# Output:  Precip. Plots
#
#
# Options: Number of precip levels
#
# NOTE:
#
###
 	plotPrecip<-function(precip,plotopts=list(plotsize=1.4),plotdir="/home/mm5/amet/figure/npa",
 	                     nlevs=25,varlab)
 {
#----------------------------------------------------------
 #	Define grid dimensions and lat-lon bounds for plotting
 dims<-dim(precip$mod)
 ny<-dims[1]
 nx<-dims[2]
 lats<- min(precip$lat)
 latn<- max(precip$lat)
 lonw<- min(precip$lon)
 lone<- max(precip$lon)
 dlat<-latn-lats
 dlon<-lone-lonw
 lone<-lone+(0.10*dlon)
#----------------------------------------------------------

#----------------------------------------------------------
 #	PLOT COMMANDS
 obs<-aperm(precip$obs,c(2,1))
 mod<-aperm(precip$mod,c(2,1))
 grid<-aperm(precip$mod-precip$obs,c(2,1))				# Define variable to be plotted
 gridloc<-list(x=aperm(precip$lon,c(2,1)),y=aperm(precip$lat,c(2,1)))		# Define lat-lon of each grid point in list

#----------------------------------------------------------
 # Contour Levels (In future, there is a need to make these configurable via function input)

  diffcols<-array("white",c(nx,ny))
  obscols<-array("white",c(nx,ny))
  modcols<-array("white",c(nx,ny))
  hitcols<-ifelse( aperm(precip$logicfield,c(2,1)) == 1 ,"green",gray(0.80))
  hitcols<-ifelse( aperm(precip$logicfield,c(2,1)) == -1 ,"red",hitcols)
  hitcols<-ifelse( aperm(precip$logicfield,c(2,1)) == -2 ,"yellow",hitcols)

   a1<-quantile(obs,seq(0,1,.01),na.rm=TRUE)
   a2<-quantile(mod,seq(0,1,.01),na.rm=TRUE)
   a3<-quantile(grid,seq(0,1,.01),na.rm=TRUE)
   maxl<-max(a1[length(a1)-1],a2[length(a2)-1],na.rm=TRUE)
   levs<-round(seq(0,maxl,by=maxl/nlevs))
   ranged<-range(a3[2],a3[length(a3)-1])
   if(length(na.omit(ranged)) == 0) {ranged<-range(0,a1)}
   if(length(levs) > maxl){
      levs<-round(seq(0,maxl))
   }
   ccols<-rev(rainbow(length(levs)))
   ccols<-ifelse(levs == 0,"white",ccols)

 if(sum(obs,na.rm=TRUE) > 0){obscols<-ccols[cut(obs,br=levs,labels=FALSE)]}
 if(sum(mod,na.rm=TRUE) > 0){modcols<-ccols[cut(mod,br=levs,labels=FALSE)]}
 difflevs<-seq(ranged[1],ranged[2],by=ceiling(diff(ranged)/nlevs))
 ccols2<-rev(rainbow(length(difflevs)))
 diffcols<-ccols2[cut(grid,br=difflevs,labels=FALSE)]
#----------------------------------------------------------
#----------------------------------------------------------
#	Main Plot commands  (Observed Precip)
#----------------------------------------------------------
# Open figure to plot
  figure<-paste(plotdir,"/npa-model.comp.",varlab$fig,sep="")
  writeLines(figure)
  if (plotopts$plotfmt == "pdf") {pdf(file= paste(figure,".pdf",sep=""), width = 11, height = 8.5)	}
  #if (plotopts$plotfmt == "png"){bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, height = (541*plotopts$plotsize)/100, res=100)	}
  if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(figure,".jpeg",sep=""), width = (700*plotopts$plotsize), height = (541*plotopts$plotsize), quality=100)	}
  if (plotopts$plotfmt == "png") {png(file=paste(figure,".png",sep=""), width = (1000*plotopts$plotsize), height = (775*plotopts$plotsize), pointsize=13*plotopts$plotsize)	}
  lab<-paste("Total Observed Precipitation (mm)")
  par(mfrow=c(2,2))
  par(mai=c(0,0,0,0))

   #	Plot hires map of domain, given model lat-lon bounds
   map("state",xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1)


# Draw Title
#  Add AMET logo, plot gridpoints and redraw map
  par(new=TRUE)
   points(gridloc,pch=plotopts$symb,cex=plotopts$symbsiz,col=obscols)
  par(new=TRUE)
   map("worldHires",xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1,add=TRUE)
   map("state",xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1,add=TRUE)
   text(lonw,lats+1,"NOAA/EPA, AMET Product",adj=c(0,1))
# Draw legend
   legend(lone,lats,levs,col=ccols,fill=TRUE,pch=plotopts$symb,xjust=1,yjust=0,bg='white',y.intersp=.7,cex=.85)
   rect(lonw-10,latn-(0.20*dlat),lone+10,latn+10,col="white",border=F)
   text(lonw+(dlon/2),latn-(0.05*dlat),lab)
   text(lonw+(dlon/2),latn-(0.10*dlat),paste("DATE:",varlab$date))
   text(lonw+(dlon/2),latn-(0.15*dlat),varlab$title2)

#   title(main=lab,line=-3)
#   title(main=paste("DATE:",varlab$date),line=-2)
#   title(main=varlab$title2,line=-1)
   box(which="figure")

#----------------------------------------------------------
#	Main Plot commands  (Modeled Precip)
#----------------------------------------------------------
  lab<-paste("Total Model Precipitation (mm)")

   #	Plot hires map of domain, given model lat-lon bounds
   map("state",xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1)

# Draw Title
   title(main=lab,line=-1)
#  Add AMET logo, plot gridpoints and redraw map
  par(new=TRUE)
   points(gridloc,pch=plotopts$symb,cex=plotopts$symbsiz,col=modcols)
  par(new=TRUE)
   map("worldHires",xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1,add=TRUE)
   map("state",xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1,add=TRUE)
   text(lonw,lats+1,"NOAA/EPA, AMET Product",adj=c(0,1))
# Draw legend
   legend(lone,lats,levs,col=ccols,fill=TRUE,pch=plotopts$symb,xjust=1,yjust=0,bg='white',y.intersp=.7,cex=.85)
   rect(lonw-10,latn-(0.10*dlat),lone+10,latn+10,col="white",border=F)
   text(lonw+(dlon/2),latn-(0.05*dlat),lab)
#   rect(lonw-10,latn-2,lone+10,latn,col="white",border=F)
#   title(main=lab,line=-1.5)
   box(which="figure")
#----------------------------------------------------------
#	Main Plot commands  (Precip Difference)
#----------------------------------------------------------
# Open figure to plot
  lab<-paste("Bias of Modeled Precipitation (mm)")

   #	Plot hires map of domain, given model lat-lon bounds
   map("state",xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1)


   # Draw Title
   title(main=lab,line=-1)
   #  Add AMET logo, plot gridpoints and redraw map
  par(new=TRUE)
   points(gridloc,pch=plotopts$symb,cex=plotopts$symbsiz,col=diffcols)
  par(new=TRUE)
   map("worldHires",xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1,add=TRUE)
   map("state",xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1,add=TRUE)
   text(lonw,lats+1,"NOAA/EPA, AMET Product",adj=c(0,1))
   # Draw legend
   legend(lone,lats,round(difflevs),col=ccols2,fill=TRUE,pch=plotopts$symb,xjust=1,yjust=0,bg='white',y.intersp=.7,cex=.85)
   rect(lonw-10,latn-(0.10*dlat),lone+10,latn+10,col="white",border=F)
   text(lonw+(dlon/2),latn-(0.05*dlat),lab)
#   rect(lonw-10,latn-2,lone+10,latn,col="white",border=F)
#   title(main=lab,line=-1.5)
   box(which="figure")
#----------------------------------------------------------
#	Main Plot commands  (Model Precip hit field, Where model predicted rain correcly)
#----------------------------------------------------------
# Open figure to plot
  lab<-paste("Categorical Precipitation Evaluation")

   #	Plot hires map of domain, given model lat-lon bounds
   map("state",xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1)


# Draw Title
#  Add AMET logo, plot gridpoints and redraw map
  par(new=TRUE)
   points(gridloc,pch=plotopts$symb,cex=plotopts$symbsiz,col=hitcols)
  par(new=TRUE)
   map("worldHires",xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1,add=TRUE)
   map("state",xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1,add=TRUE)
   text(lonw,lats+1,"NOAA/EPA, AMET Product",adj=c(0,1))
   legend(lone,lats,c(paste("Correct",precip$hits),paste("False Alarm",precip$false),paste("Missed",precip$miss),paste("TS",precip$ts),paste("BIAS",precip$bias),paste("POD",precip$pod),paste("FAR",precip$far),paste("CSI",precip$csi)),col=c("green","red","yellow",NA,NA,NA,NA,NA),fill=TRUE,pch=plotopts$symb,xjust=1,yjust=0,bg='white',y.intersp=.7,cex=.85)
   rect(lonw-10,latn-(0.10*dlat),lone+10,latn+10,col="white",border=F)
   text(lonw+(dlon/2),latn-(0.05*dlat),lab)
#   rect(lonw-10,latn-2,lone+10,latn,col="white",border=F)
#   title(main=lab,line=-1.5)
# Draw legend
  box(which="figure")
#----------------------------------------------------------
#----------------------------------------------------------
dev.off()
}
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################
	                                                                             