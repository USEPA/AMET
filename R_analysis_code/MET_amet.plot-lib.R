#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#                AMET (Atmospheric Model Evaluation Tool)               #
#                                                                       #
#                     AMET Plotting Function Library                    #
#                          MET_amet.plot-lib.R                          #
#                                                                       #
#         Developed by the US Environmental Protection Agency           #
#-----------------------------------------------------------------------#
#########################################################################
#
# Version 1.1, August 18, 2005, Robert Gilliam
#
# Version 1.2, May 6, 2013, Robert Gilliam
#  - Extensive code cleansing
#
# Version 1.4, Sep 30, 2018, Robert Gilliam
#  - More code cleansing and documentation. Removed tabs.
#  - Summary plot (ametplot) function modified to remove information header
#    that was not useful and contained a lot of missing values. Users
#    can utilize plot label variable to distinquish plots.
#  - Added functions for new T, Q, RH and PS timeseries
#  - Added a number of RAOB-Model plotting functions
#
# Version 1.5, Apr 16, 2021, Robert Gilliam
#  - Wind vector error added for better wind error analysis
#  - Gross QC limits on Mod-Obs difference allowed in stats calculations. 
#    Defined in raob.input. Default use if old raob.input.
#  - Wind vector error calculated for spatial and timeseries plots.
#  - Other minor streamline updates. 
#  - AMETPLOT statistics change -- removed normalized for un/systematic error
#
#-----------------------------------------------------------------------##################
##########################################################################################
##########################################################################################
#	This collection contains the following functions
#
#       plotTseries      --> Plot Surface Meteorological Time Series of T, WS, WD and Q	
#
#       plotTseriesRH    --> Plot Surface Meteorological Time Series of T, Q, RH and PS	
#
#       diurnalplot      --> Plot diurnal statistics
#
#       ametplot         --> Create AMET Model Performance Plot for a particular subset of data
#
#       wdScatter        --> Wind direction scatter plot
#
#       plotSpatial      --> Plots spatial statistics
#
#       plotSpatialRaob  --> Plots RAOB spatial statistics from mandatory pressure level
#                            data for specified lat-lon bounds. T, RH, WS, WD. 
#
#       plotTseriesRaobM --> Plots daily RAOB statistics from mandatory pressure level
#                            data for specified lat-lon bounds. T, RH, WS, WD. 
# 
#       plotProfRaobM    --> Plots RAOB-Model profiles on Mandantory pressure levels.
#                            Plots mean bias boxplots of T, RH, WS, WD
#
#       plotDistRaobM    --> Plots RH distibution on each mandantory pressure levels.
#                            
#       plotProfTimeM    --> Time-height curtain plots on mandantory pressure levels.
#                            
#       plotProfRaobN    --> Plots RAOB-Model profiles on native pressure levels.
#                            Plots single time profiles of T and RH only.
#                            
#       plotProfTimeN    --> Time-Height curtain plots on native pressure levels. Model
#                            is shaded background. Obs are symbols overlaid w/same color.
#                            
##########################################################################################
##########################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Plot Surface Meteorological Time Series of T, WS, WD and Q
#
# Input: model and observation list with mod defined as model
#	 and obs defined as the observation
#   
# Output:  Model statistics matrix../../R_analysis_code/MET_raob.R
#
# NOTE: The database must have a table names stations (within the AMET framework)
#   
###
 plotTseries	<-function(temp,ws,wd,q,date.vec,plotopts,qclims,
                           comp=FALSE,tsnames=c("Observed","Model 1","Model2"),
                           wdweightws=FALSE) 
  {

  if (plotopts$plotfmt == "pdf"){pdf(file= paste(plotopts$figure,".pdf",sep=""), width = 8.5, height = 11)	}
  if (plotopts$plotfmt == "png"){bitmap(file=paste(plotopts$figure,".png",sep=""), width = 8.5, height = 11, 
                                 res=100,pointsize=12*plotopts$plotsize)	}
  if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(plotopts$figure,".jpeg",sep=""), 
                                  width = (541*plotopts$plotsize), height = (700*plotopts$plotsize), 
                                  quality=100)	}
 # Apply quality control limits to data
  temp<-ifelse(temp< qclims$qcT[2]  & temp > qclims$qcT[1] , temp, NA)
  q   <-ifelse(q   < qclims$qcQ[2]  & q    > qclims$qcQ[1] ,    q, NA)
  ws  <-ifelse(ws  < qclims$qcWS[2] & ws   > qclims$qcWS[1],   ws, NA)
  wd  <-ifelse(ws  < qclims$qcWS[2] & ws   > qclims$qcWS[1],   wd, NA)

  if(!comp) { leglab<-tsnames[1:2];tscols<-c("black","red")       }
  if(comp)  { leglab<-tsnames;     tscols<-c("black","red","blue")}

  par(mfrow=c(4,1))
  par(bg="white")
  par(fg="black")
#################################################################
  #########################################################
  #     PLOT Mixing Ratio
  ##############################
  val      <-q

  vallab   <-"2-m Mixing Ratio (g kg-1)"
  miny     <-min(val,na.rm=TRUE)-2;
  maxy     <-max(val,na.rm=TRUE);
  dy       <-0.09*(maxy-miny);ps1<-maxy-dy;ps2<-ps1-dy;ps3<-ps2-dy
  ##############################
  #     Compute quick stats
  ##############################
  ss       <-quickstats(val[,2],val[,1],digs=2)
  ss2      <-ss
  ss2$mae  <-"";ss2$bias<-"";ss2$ioa<-"";
  seps     <-""
  if (comp){
    ss2    <-quickstats(val[,2],val[,3],digs=2);seps<-"/"
  }	
  minval   <-1
  maxval   <-length(time)

  par(new=F)
  par(mai=c(0.25,0.35,0.2,0.1))
  par(mai=c(0,0.35,0.02,0.02))
  par(mgp=c(1.40,0.2,0))
  plot(date.vec,val[,2],xlab="",axes=FALSE,ylab=vallab,xlim=range(date.vec),ylim=c(miny,maxy),
       pch=4,cex=0.75,col=tscols[1],vfont=c("serif","bold"),label=TRUE,type="l",lwd=1, bg="yellow")
  par(tck=1)
  axis(2,col="black",lty=3)
  par(tck=1)
  axis(1,col="black",lty=3,at=date.vec[seq(1,length(date.vec),by=24)],
       labels=as.character(date.vec[seq(1,length(date.vec),by=24)]))
  par(new=T)
  plot(date.vec,val[,1],xlim=range(date.vec),ylim=c(miny,maxy),tick=FALSE,labels=F,
       type="l",pch=5,col=tscols[2],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
  par(new=T)
  if (comp){
    plot(date.vec,val[,3],axes=FALSE,xlim=range(date.vec),ylim=c(miny,maxy),
    tick=FALSE,type="l",pch=5,col=tscols[3],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
  }
  title("Observation-Model Time Series",line=-1,outer=T)
  rect(date.vec[1],miny-0.04*(maxy-miny),date.vec[length(date.vec)-2],
       miny+0.06*(maxy-miny),col="white",border="black")
  legend(date.vec[1],maxy,leglab,col=tscols,lty=1,lwd=2,cex=0.90,xjust=.20)
  statsstr<-paste("Time Series Statistics -->     ","MAE ",ss$mae,seps,ss2$mae,"                 ",
                  "BIAS ",ss$bias,seps,ss2$bias,"                 ",
                  "AC  ",ss$ioa,seps,ss2$ioa)
  text(date.vec[1], miny,statsstr,col="black", pos=4,cex=plotopts$scex)
#################################################################################################



#################################################################
  #########################################################
  #    PLOT Temperature
  ##############################
  val<-temp

  vallab<-"2-m Temperature (K)"
  miny<-min(val,na.rm=TRUE)-2;
  maxy<-max(val,na.rm=TRUE);
  dy<-0.09*(maxy-miny);ps1<-maxy-dy;ps2<-ps1-dy;ps3<-ps2-dy
  ##############################
  #   Compute quick stats
  ##############################
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
  plot(date.vec,val[,1],xlim=range(date.vec),ylim=c(miny,maxy),tick=FALSE,labels=F,
       type="l",pch=5,col=tscols[2],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
  par(new=T)
  if (comp){
    plot(date.vec,val[,3],axes=FALSE,xlim=range(date.vec),ylim=c(miny,maxy),
         tick=FALSE,type="l",pch=5,col=tscols[3],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
  }
  rect(date.vec[1],miny-0.04*(maxy-miny),date.vec[length(date.vec)-2],miny+0.06*(maxy-miny),col="white",border="black")
  statsstr<-paste("Time Series Statistics -->     ","MAE ",ss$mae,seps,ss2$mae,"                 ",
                  "BIAS ",ss$bias,seps,ss2$bias,"                 ",
                  "AC  ",ss$ioa,seps,ss2$ioa)
  text(date.vec[1], miny,statsstr,col="black", pos=4,cex=plotopts$scex)
#################################################################################################


#################################################################
  #########################################################
  #    PLOT Wind Speed
  ##############################
  val<-ws

  vallab<-"10-m Wind Speed (m s-1)"
  miny<-min(val,na.rm=TRUE)-1;
  maxy<-max(val,na.rm=TRUE);
  dy<-0.09*(maxy-miny);ps1<-maxy-dy;ps2<-ps1-dy;ps3<-ps2-dy
  ##############################
  #   Compute quick stats
  ##############################
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
  plot(date.vec,val[,1],xlim=range(date.vec),ylim=c(miny,maxy),tick=FALSE,labels=F,
       type="l",pch=5,col=tscols[2],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
  par(new=T)
  if (comp){
    plot(date.vec,val[,3],axes=FALSE,xlim=range(date.vec),ylim=c(miny,maxy),
         tick=FALSE,type="l",pch=5,col=tscols[3],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
  }
  rect(date.vec[1],miny-0.04*(maxy-miny),date.vec[length(date.vec)-2],miny+0.06*(maxy-miny),col="white",border="black")
  statsstr<-paste("Time Series Statistics -->     ","MAE ",ss$mae,seps,ss2$mae,"                 ",
                  "BIAS ",ss$bias,seps,ss2$bias,"                 ",
                  "AC  ",ss$ioa,seps,ss2$ioa)
  text(date.vec[1], miny,statsstr,col="black", pos=4,cex=plotopts$scex)
#################################################################################################

#################################################################
  #########################################################
  #    PLOT Wind Direction
  ##############################
  val<-wd

  vallab<-"10-m Wind Direction (deg)"
  miny<--5;
  maxy<-360;
  dy<-0.09*(maxy-miny);ps1<-maxy-dy;ps2<-ps1-dy;ps3<-ps2-dy
  ##############################
  #   Compute quick stats
  ##############################
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
  plot(date.vec,val[,1],xlim=range(date.vec),ylim=c(miny,maxy),tick=FALSE,labels=F,
       type="l",pch=5,col=tscols[2],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
  par(new=T)
  if (comp){
    plot(date.vec,val[,3],axes=FALSE,xlim=range(date.vec),ylim=c(miny,maxy),
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
#####################################################################
#- - - - - - - - - - - -  START OF FUNCTION - -  - - - - - - - - - ##
#####################################################################
###  Plot Surface Meteorological Time Series of T, Q, RH and PS
#
# Input: Met arrays [time,3] where the second dim is mod1, obs, mod2
#        arrays are temp, mixing ratio, rel. hum. and sfc press. 
#        Also, date vector, plot options, etc. 
# Output: Time series plot. No variables are output back to main script.
#
#   
###
 plotTseriesRH	<-function(temp, q, rh, ps, date.vec, plotopts, 
                           comp=FALSE, tsnames=c("obs","model1","model2")) 
  {
  
  
  if (plotopts$plotfmt == "pdf"){pdf(file= paste(plotopts$figure,".pdf",sep=""), width = 8.5, height = 11)	}
  if (plotopts$plotfmt == "png"){bitmap(file=paste(plotopts$figure,".png",sep=""), width = 8.5, height = 11, 
                                 res=100,pointsize=12*plotopts$plotsize)	}
  if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(plotopts$figure,".jpeg",sep=""), 
                                  width = (541*plotopts$plotsize), height = (700*plotopts$plotsize), 
                                  quality=100)	}
                                  
  if(!comp) { leglab<-tsnames[1:2];tscols<-c("black","red")       }
  if(comp)  { leglab<-tsnames;     tscols<-c("black","red","blue")}

  par(mfrow=c(4,1))
  par(bg="white")
  par(fg="black")
#################################################################
  #########################################################
  #     PLOT Mixing Ratio
  ##############################
  val<-q

  vallab<-"2-m Mixing Ratio (g kg-1)"
  miny<-min(val,na.rm=TRUE)-2;
  maxy<-max(val,na.rm=TRUE)+2;
  dy<-0.09*(maxy-miny);ps1<-maxy-dy;ps2<-ps1-dy;ps3<-ps2-dy
  ##############################
  #     Compute quick stats
  ##############################
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
  plot(date.vec,val[,1],xlim=range(date.vec),ylim=c(miny,maxy),tick=FALSE,labels=F,
       type="l",pch=5,col=tscols[2],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
  par(new=T)
  if (comp){
    plot(date.vec,val[,3],axes=FALSE,xlim=range(date.vec),ylim=c(miny,maxy),
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
  #    PLOT Temperature
  ##############################
  val<-temp

  vallab<-"2-m Temperature (K)"
  miny<-min(val,na.rm=TRUE)-2;
  maxy<-max(val,na.rm=TRUE);
  dy<-0.09*(maxy-miny);ps1<-maxy-dy;ps2<-ps1-dy;ps3<-ps2-dy
  ##############################
  #   Compute quick stats
  ##############################
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
  plot(date.vec,val[,1],xlim=range(date.vec),ylim=c(miny,maxy),tick=FALSE,labels=F,
       type="l",pch=5,col=tscols[2],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
  par(new=T)
  if (comp){
    plot(date.vec,val[,3],axes=FALSE,xlim=range(date.vec),ylim=c(miny,maxy),
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
  #    PLOT Wind Speed
  ##############################
  val<-rh

  vallab<-"2-m Relative Humidity (%)"
  miny<-min(val,na.rm=TRUE)-10;
  maxy<-105;
  dy<-0.09*(maxy-miny);ps1<-maxy-dy;ps2<-ps1-dy;ps3<-ps2-dy
  ##############################
  #   Compute quick stats
  ##############################
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
  plot(date.vec,val[,1],xlim=range(date.vec),ylim=c(miny,maxy),tick=FALSE,labels=F,
       type="l",pch=5,col=tscols[2],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
  par(new=T)
  if (comp){
    plot(date.vec,val[,3],axes=FALSE,xlim=range(date.vec),ylim=c(miny,maxy),
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
  #    PLOT Wind Direction
  ##############################
  val<-ps

  vallab<-"Station Pressure (mb)"
  miny<-min(val,na.rm=TRUE)-10;
  maxy<-max(val,na.rm=TRUE);
  dy<-0.09*(maxy-miny);ps1<-maxy-dy;ps2<-ps1-dy;ps3<-ps2-dy
  ##############################
  #   Compute quick stats
  ##############################
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
  par(mai=c(.02,0.35,0,0.02))
  par(mgp=c(1.40,0.2,0))
  plot(date.vec,val[,2],xlab="",axes=FALSE,ylab=vallab,xlim=range(date.vec),ylim=c(miny,maxy),
       pch=4,cex=0.75,col=tscols[1],vfont=c("serif","bold"),label=F,tick=F,type="l",lwd=1, bg="yellow")
  par(tck=1)
  axis(2,col="black",lty=3)
  par(tck=1)
  axis(1,col="black",lty=3,at=date.vec[seq(1,length(date.vec),by=24)],labels=as.character(date.vec[seq(1,length(date.vec),by=24)]))
  par(new=T)
  plot(date.vec,val[,1],xlim=range(date.vec),ylim=c(miny,maxy),tick=FALSE,labels=F,
       type="l",pch=5,col=tscols[2],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
  par(new=T)
  if (comp){
    plot(date.vec,val[,3],axes=FALSE,xlim=range(date.vec),ylim=c(miny,maxy),
         tick=FALSE,type="l",pch=5,col=tscols[3],lty=1,xlab="",ylab="",cex=0.75,lwd=1)
  }
  rect(date.vec[1],miny-0.04*(maxy-miny),date.vec[length(date.vec)-2],miny+0.06*(maxy-miny),col="white",border="black")
  statsstr<-paste("Time Series Statistics -->     ","MAE ",ss$mae,seps,ss2$mae,"                 ",
                  "BIAS ",ss$bias,seps,ss2$bias,"                 ",
                  "IOA ",ss$ioa,seps,ss2$ioa)
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
       if( sum(var[ind,3],na.rm=T) == 0 ) { next;	}
       stats		<-genvarstats(list(obs=var[ind,3],mod=var[ind,2]),"Temperature (2m)")
       dstats[h,]	<-stats$metrics[statloc]
       allstats[h,]	<-stats$metrics
   }
   statsAllHours<-genvarstats(list(obs=var[,3],mod=var[,2]),"Temperature (2m)")
   allstatsx    <-list(metrics=allstats,id=stats$id,name=stats$name,allHoursStats=statsAllHours$metrics[statloc])
  ##########################################################################
 
  #################################################################################################################################
  #	GENERATE DIURNAL STATISTICS PLOT
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  if (plotopts$plotfmt == "pdf"){
    writeLines(paste("Figure: ",figure,".pdf",sep=""))
    pdf(file= paste(figure,".pdf",sep=""), width = 10, height = 5)
  }
  if (plotopts$plotfmt == "bmp"){
    writeLines(paste("Figure: ",figure,".png",sep=""))
    bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, height = (350*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)
  }
  if (plotopts$plotfmt == "jpeg"){
    writeLines(paste("Figure: ",figure,".jpeg",sep=""))
    jpeg(file=paste(figure,".jpeg",sep=""), width = (700*plotopts$plotsize), height = (350*plotopts$plotsize), quality=100)
  }
  if (plotopts$plotfmt == "png"){
    writeLines(paste("Figure: ",figure,".png",sep=""))
    bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, height = (350*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)
  }
  #:::::::::::::::::::::::::::::::::::::::::::::::


  ##############################################
  # Compute data limits for axis specs, generate labels, line colors, etc
  maxs   <- ceiling(max(dstats,na.rm=TRUE)*1.10)
  mins   <- (min(dstats,na.rm=TRUE)*1.05)
  ylim   <-c(mins,maxs)
  ylocs  <-c(-5,-4,-3,-2,-1,0,1,2,3,4,5)
  if(labels$units == "deg"){
    ylocs<-c(-90,-60,-40,-30,-20,-10,0,10,20,30,40,60,90)
    ylim<-c(mins,maxs)
  }

  ylabs     <-ylocs
  h         <-0:23
  xlim      <-c(0,23)
  xlocs     <-seq(0,23,3)
  xlabs     <-paste(xlocs)

  linecols  <-c(2,4,gray(.10),gray(.10),gray(.10))
  linecols  <-c(2,4,3,5,6)
  ylinescol <-gray(0.80)
  legbg     <-'white'
  linetype  <-c(1,1,1,1,1)
  pchtype   <-c(0,1,4,5,6)
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
        for(i in 1:ng) {
            g <-gray(i/ng)
            ss<-ss+dd
        }
        ng<-100; ss<-22; e<-24; dd<-(e-ss)/ng
        for(i in 1:ng) {
            g <-gray(1-(i/ng))
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

  server      <-"NONE"
  dbase       <- "NONE"
  login       <- "NONE"
  pass        <- "NONE"
  project     <- "NONE"
  model       <- "NONE"
  queryID     <- "NONE"	
  varid       <- "NONE"	
  statid      <- "NONE"	
  obnetwork   <- "NONE"	
  lat         <- "NONE"		
  lon         <- "NONE"
  elev        <- "NONE"	
  landuse     <- "NONE"	
  obdatestart <- "NONE"		
  obdateend   <- "NONE"		
  obtime      <- "NONE"		
  fcasthr     <- "NONE"		
  level       <- "NONE"	
  syncond     <- "NONE"	
  state       <- "NONE"
  query       <- "NONE"
################################ 
  server      <- qdesc[1]
  dbase       <- qdesc[2]
  login       <- qdesc[3]
  pass        <- qdesc[4]
  project     <- qdesc[5]
  model       <- qdesc[6]
  queryID     <- qdesc[7]	
  varid       <- qdesc[8]	
  statid      <- qdesc[9]	
  obnetwork   <- qdesc[10]	
  lat         <- qdesc[11]		
  lon         <- qdesc[12]
  elev        <- qdesc[13]	
  landuse     <- qdesc[14]	
  obdatestart <- qdesc[15]		
  obdateend   <- qdesc[16]		
  obtime      <- qdesc[17]		
  fcasthr     <- qdesc[18]		
  level       <- qdesc[19]	
  syncond     <- qdesc[20]	
  state       <- qdesc[21]
  query       <- qdesc[22]

###############################################
#   Set plot margins and figure name 
  writeLines(paste("Figure: ",figure,".",plotopts$plotfmt,sep=""))	
	
  if (plotopts$plotfmt == "pdf"){
    pdf(file= paste(figure,".pdf",sep=""), width = 8.5, height = 11)
  }
  if (plotopts$plotfmt == "png"){
    bitmap(file=paste(figure,".png",sep=""), width = (541*plotopts$plotsize)/100, 
           height = (700*plotopts$plotsize)/100, res=100)
  }
	
  px1<-array(,)
  px2<-array(,)
  py1<-array(,)
  py2<-array(,)

  px1[1]<-0.01; px2[1]<-9.99; py1[1]<-0.01; py2[1]<-9.99 #Top Title
  px1[2]<-0.10; px2[2]<-9.90; py1[2]<-8.50; py2[2]<-9.90 #Top Information
  px1[3]<-0.25; px2[3]<-6.00; py1[3]<-4.00; py2[3]<-9.50 #Scatter Plot
  px1[4]<-0.35; px2[4]<-5.85; py1[4]<-0.50; py2[4]<-3.50 #Range-Stats Plot
  px1[5]<-6.50; px2[5]<-9.90; py1[5]<-0.30; py2[5]<-3.80 #Histogram
  px1[6]<-6.15; px2[6]<-9.90; py1[6]<-4.25; py2[6]<-9.50 #Tables Stats

###################################################################################################
#------------------------------------------------------------------------------------------------##
#----				Top Table Description Zone 				-------####
###################################################################################################
  par(new=FALSE)
  par(mai=c(0,0,0,0))
  x<-c(0,1)
  y<-c(0,1)
	
  par(fig=c(px1[1],px2[1],py1[1],py2[1])/10)
  # Plot Rectangle that outlines table area
  plot(x,y, axes=TRUE, type='n',xlab='',ylab='',tick=FALSE,labels=FALSE )

  head<-array(NA,c(3,3,2))
  head[3,1,1]<-"Variable";head[3,2,1]<-"Query ID";head[3,3,1]<-"Forecast Hour";
  head[3,1,2]<-varid     ;head[3,2,2]<-queryID   ;head[3,3,2]<-fcasthr;
  ##########################################################################
  colxmod<-c(0.50,0.40,0.60)
  topdiv <-0.85
  margx  <-0.0
  spaceV <-topdiv/length(head[,1,1])
  spaceH <- 0.90*((1-margx)/length(head[1,,1]))

  for(c in 1:length(head[1,,1])){
    for(r in 1:length(head[,1,1])){
	
      x1<-margx+spaceH*(c-1)
      x2<-margx+spaceH*(colxmod[c])+spaceH*(c-1)
      y<-topdiv-spaceV*r
    }
  }
  par(font=6)
  #text(0.5,topdiv+0.03,"Model Performance Report",offset = 0.5, vfont=c("serif","bold"),cex=1 )	
  par(font=1)
	
  ###################################################################################################
  #------------------------------------------------------------------------------------------------##
  #--------                                Scatter Plot                                   -------####
  ###################################################################################################
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
  #--------                            Stats-Over-Range Plot                              -------####
  ###################################################################################################
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

  if (varid == "WS" || varid == "WD"){
    minval<-1; maxval<-10; mid<-2:11; interval<-1
  }

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
        rangestats[n,2]<-mean(abs(mod2),na.rm=T)
        rangestats[n,3]<-mean(mod2,na.rm=T)
      }
      else {
        rangestats[n,1]<-sqrt(var(mod2-obs2,na.rm=T))
        rangestats[n,2]<-mean(abs(mod2-obs2),na.rm=T)
        rangestats[n,3]<- mean(mod2,na.rm=T)-mean(obs2,na.rm=T)
      }
    }
    else {
      rangex[n]<-NA
      rangestats[n,1]<-NA
      rangestats[n,2]<-NA
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
  plot(rangex,stdev,xlab="Observed Range", ylab="Statistics Value",xlim=c(minval,maxval),
       ylim=c(miny,maxy),pch="o",cex=0.5,col=4,vfont=c("serif","bold") )
  lines(rangex,stdev,col=4 )
  lines(rangex,mae,col=2)
  lines(rangex,bias,col=3 )
  mtext("Statistical Metrics versus Observation Range",side=3,outer = FALSE, col=1, cex=1.25)
  x<-maxval+0.04*(maxval-minval)
  y<-maxy+0.04*(maxy-miny)
  legend(x,y,c("StDev","MAE","BIAS"),col=c(4,2,3),lty=1,bg=gray(.9),bty=1,xjust=1,yjust=1)
  ###################################################################################################
  #------------------------------------------------------------------------------------------------##
  #--------                            Histogram Plot                                     -------####
  ###################################################################################################
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
  #--------                   Lower-Left Table Description Zone                           -------####
  ###################################################################################################
  par(new=TRUE)

  x<-c(0,1)
  y<-c(0,1)

  par(fig=c(px1[6],px2[6],py1[6],py2[6])/10)

  # Plot Rectangle that outlines table area
  plot(x,y, axes=TRUE, type='n',xlab='',ylab='',tick=FALSE,labels=FALSE )

  # Define the metrics to plot from the original metrics array
  metricsID   <-c("count","maxO","minO","meanO","medianO","sumO","varO","maxM","minM","meanM",
                  "medianM","sumM","varM","cor","var","sdev","mae","bias","mngerror","nmbias",
                  "nmerror","rmses","rmseu","rmserror","ac")
  metricsLength<-length(metricsID)
  m2<-array(,);m2id<-array(,)

  adjustment<-mean(obs,na.rm=TRUE)/(max(range(obs,na.rm=TRUE),range(mod,na.rm=TRUE))-min(range(obs,na.rm=TRUE),range(mod,na.rm=TRUE)))

  m2[1]<-format(metrics[1],digits=5);            m2id[1] <-'Data count                ';
  m2[2]<-sprintf("%.2f",metrics[14]);            m2id[2] <-'Correlation               ';
  m2[3]<-sprintf("%.2f",metrics[16]);            m2id[3] <-'Standard Deviation        ';
  m2[4]<-sprintf("%.2f",metrics[17]);            m2id[4] <-'Mean Absolute Error       ';
  m2[5]<-sprintf("%.2f",metrics[18]);            m2id[5] <-'Mean Bias                 ';
  m2[6]<-sprintf("%.2f",metrics[19]*adjustment); m2id[6] <-'*Mean Normalized Error (%)';
  m2[7]<-sprintf("%.2f",metrics[20]*adjustment); m2id[7] <-'*Normalized Mean Bias (%) ';
  m2[8]<-sprintf("%.2f",metrics[21]*adjustment); m2id[8] <-'*Normalized Mean Error (%)';
  m2[9]<-sprintf("%.2f",metrics[22]);            m2id[9] <-'Systematic RMSE           ';
  m2[10]<-sprintf("%.2f",metrics[23]);           m2id[10]<-'Unsystematic RMSE         ';
  m2[11]<-sprintf("%.2f",metrics[24]);           m2id[11]<-'Root-Mean-Sqr-Error       ';
  m2[12]<-sprintf("%.2f",metrics[25]);           m2id[12]<-'Anomaly Correlation       ';

  if (wdflag == 1){m2[2]="n/a";m2[6:10]="n/a";m2[12]="n/a"}
    lmarg1<- 0.01
    lmarg2<- 0.75
    topstart<-0.85
    topline<-topstart+0.05
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
  a     <-runif(length(obs),min=0,max=1)
  x     <-((obs+a)*sin(wdd*3.14/180))
  y     <-((obs+a)*cos(wdd*3.14/180))

  min   <-min(min(x),min(y))
  max   <-max(max(x),max(y))
  #writeLines(paste(min,max,sep="   "))
  min   <--radius;max<-radius;
  plot(x,y,axes=FALSE, tick=TRUE,labels=TRUE,pch=".",cex=2,xlab='',ylab='',xlim=c(min,max),ylim=c(min,max),col=dc)

  deg   <-c(1:360)
  for (i in 2:radius-1) {
    r   <-i
    cx  <-((i)*sin(deg*3.14/180))
    cy  <-((i)*cos(deg*3.14/180))

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
  cx     <-((radius)*sin(deg*3.14/180))
  cy     <-((radius)*cos(deg*3.14/180))
  polygon(cx,cy)
  radius <-fr
  cx     <-((radius)*sin(deg*3.14/180))
  cy     <-((radius)*cos(deg*3.14/180))
  polygon(cx,cy,col=1)

  j      <-0
  radius <-10
  offset <-0.5

  for (i in 1:12) {
    cx   <-((radius)*sin(j*3.14/180))
    cy   <-((radius)*cos(j*3.14/180))
    lines(c(0,cx),c(0,cy),lty=3)

    lab  <-j
    if (lab > 180){lab<-lab-360;}

    labx <-((radius+offset)*sin(j*3.14/180))
    laby <-((radius+offset)*cos(j*3.14/180))
    text(labx,laby,paste(lab))
    j    <-j+30
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
                          histplot=F,shadeplot=F,sres=0.25, map.db="worldHires",
                          scale.symb=F, scale.by=sinfo$plotval, mincex=0.50, maxcex=2,
                          max.val.scaled=max(abs(sinfo$plotval)), 
                          outline.symb=F, neg.pos=F ) {

######################################################################################################
# Open Figure  for plot functions

  if (plotopts$plotfmt == "pdf"){
    pdf(file= paste(figure,".pdf",sep=""), width = 11, height = 8.5)
  }
  if (plotopts$plotfmt == "png"){
      bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, 
      height = (541*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)
  }

  sinfo$plotval<-ifelse(abs(sinfo$plotval) > max(sinfo$levs),NA,sinfo$plotval)	
  pcols<-array(NA,c(length(sinfo$plotval)))

  pcols<-sinfo$levcols[cut(sinfo$plotval,br=sinfo$levs,labels=FALSE,include.lowest=T,right=T)]
  if(max(abs(na.omit(sinfo$plotval))) <= 1 ){
    sinfo$convFac<-1
  }
# Set map symbols and calculate size based on relative data magnitude
  spch    <-plotopts$symb
  spch2   <-1
  scex    <-plotopts$symbsiz
  lonw    <- bounds[3]
  lone    <- bounds[4]
  lats    <-bounds[1]
  latn    <-bounds[2]

  legoffset<- (1/50)*(lone-lonw)
  
  if(scale.symb) {
   scaled  <- abs(scale.by)/max.val.scaled
   scex    <-mincex+ (scaled * (maxcex-mincex) )
   #writeLines(paste(scex))
  }


# Plot Map and values
  m<-map('usa',plot=FALSE)
  #map(map.db, xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1)
  map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1)
  if(lonw > -150 & lone < 0 & lats > 0 & latn > 25) {
    map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, add=T)
  }
  points(sinfo$lon,sinfo$lat,pch=spch, cex=scex, col=pcols)

  if(outline.symb) {
    ocols <-"black"
    if(neg.pos) {
     ocols<-ifelse(scale.by < 0,"black","gray")
    }
    points(sinfo$lon,sinfo$lat,pch=spch2, cex=scex, col=ocols)
  }

  box()
# Draw legend
  levLab<-sinfo$levs[1:(length(sinfo$levs)-1)]*sinfo$convFac
  legend(lone,lats,levLab,col=sinfo$levcols,pch=spch,xjust=1,yjust=0, pt.cex=1.35, cex=1.20)

# Draw Title
  title(main=paste(varlab[1]),cex.main = 1.0, line=0.25)
  dev.off() 
 
 if(histplot){
  if (plotopts$plotfmt == "pdf"){
    pdf(file= paste(figure,".hist.pdf",sep=""), width = 11, height = 8.5)
  }
  if (plotopts$plotfmt == "png"){
    bitmap(file=paste(figure,".hist.png",sep=""), width = (700*plotopts$plotsize)/100, 
           height = (541*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)
  }
  histvals <-ifelse(sinfo$plotval > max(sinfo$levs),max(sinfo$levs),sinfo$plotval)
  histvals <-ifelse(histvals < min(sinfo$levs),min(sinfo$levs),histvals)
  if (length(na.omit(histvals)) > 0){
 	hist(histvals,breaks=sinfo$levs,col=sinfo$levcols,freq=T,ylab="Number of Sites",xlab=varlab[1],main="")
  }
  dev.off()
 } 

 if(shadeplot){
  if (plotopts$plotfmt == "pdf"){
      pdf(file= paste(figure,".shade.pdf",sep=""), width = 11, height = 8.5)
  }
  if (plotopts$plotfmt == "png"){
    bitmap(file=paste(figure,".shade.png",sep=""), width = (700*plotopts$plotsize)/100, 
           height = (541*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)
  }

  dat<-na.omit(cbind(sinfo$lon,sinfo$lat,sinfo$plotval))
  lon<-dat[,1]
  lat<-dat[,2]
  dat<-dat[,3]
  val<-interp(lon,lat,dat,xo=seq(lonw,lone,by=sres),yo=seq(lats,latn,by=sres),duplicate="mean", linear=T)
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
###  Plot Spatial Statistics for RAOB-Model Comparison
#
# Input: statistics array, site information, levels for each statistic
#        and met variable, color scale, plot options and labels
#   
# Output:  PDF plots of T,RH,WS and WD RMSE, MAE, BIAS and CORR 
#   
###

 ################################################################
 plotSpatialRaob <-function(statsq, slatlon, sitesq, lev.array, 
                            col.array, plotopts, plotlab) {
 ################################################################
 nv<- length(varID)
 nm<- length(metricID)
 ns<- dim(statsq)[1]

 if( dim(statsq)[2] > nv ) {
   writeLines("** Importance Notice **")
   writeLines("raob.input is old and does not consider wind vector error")
   writeLines("WNDVEC mean error plot skipped until raob.input is update to AMETv1.5+")
 }

 for(v in 1:nv) {
  for(m in 1:nm) {

   #  WNDVEC v=5 only has mean error  m=1, added in v1.5
   if(v == 5 & m != 2) {
     next
   }

   num.missing <- sum(is.na(statsq[,v,m]))
   if(num.missing > 0.25*ns) {
     writeLines(paste("*************************************************"))
     writeLines(paste("Not enough good data for plot. Skipping:",plotlab$varName[v],plotlab$metricID[m]))
     next
   }

   figure  <- paste(plotopts$figdir,"/","raob.spatial.",metricID[m],".",varID[v],".",plotlab$datelab,".", 
                    plotlab$figurelablev,".",plotopts$project,".",plotopts$plotfmt,sep="")

      if (plotopts$plotfmt == "pdf"){
     pdf(file= figure, width = 11, height = 8.5)
   }
   if (plotopts$plotfmt == "png"){
     bitmap(file=figure, width = (700*plotopts$plotsize)/100, 
            height = (541*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)
   }
   writeLines(paste("*************************************************"))
   writeLines(paste("Plotting",plotlab$varName[v],plotlab$metricID[m]))
   writeLines(paste(figure))

   nlevs        <-sum(ifelse(is.na(lev.array[,v,m]),0,1))
   levs         <-lev.array[1:nlevs,v,m]
   plotval      <-ifelse(abs(statsq[,v,m]) > max(levs), max(levs), statsq[,v,m])	
   levcols      <-col.array[1:nlevs,v,m]
   pcols        <-levcols[cut(plotval,br=levs,labels=FALSE,include.lowest=T,right=T)]
   pcols        <-ifelse(abs(statsq[,v,m]) > max(levs), "black", pcols)	

   # Set map symbols and calculate size based on relative data magnitude
   spch    <- plotopts$symb		
   spch2   <- 21
   mincex  <- 0.65
   scex    <- plotopts$symbsiz
   lonw    <- bounds[3]
   lone    <- bounds[4]
   lats    <- bounds[1]
   latn    <- bounds[2]
   legoffset<- (1/50)*(lone-lonw)
   # Symbol conditions so circle, square, diamond and triangle options are outlined
   if(spch == 19) { spch2<-21 }
   if(spch == 15) { spch2<-22 }
   if(spch == 17) { spch2<-24 }
   if(spch == 18) { spch2<-23 }

   # Plot Map and values
   map('usa',plot=FALSE)
   map("world", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1)
   if(lonw > -150 & lone < 0 & lats > 0 & latn > 25) {
     map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, add=T)
   }
   points(slatlon[,2],slatlon[,1],pch=spch, cex=scex, col=pcols)
   points(slatlon[,2],slatlon[,1],pch=spch2,cex=scex, col="black")
   box()
  
   # Draw legend
   levLab<-levs[1:(length(levs)-1)]
   legend(lone,lats,levLab,col=levcols,pch=spch,xjust=1,yjust=0, cex=0.80)

   # Draw Title
   main  <-paste(plotlab$varName[v]," ",plotlab$metricID[m],"(",plotlab$varUnits[v],")",sep="")
   title(main=main, cex.main = 1.0, line=0.25)
   subl  <-paste(plotlab$infolabProf2,"  ---  Layer Average:",plotlab$figurelablev,sep="")
   title(sub=subl, cex.main = 1.0, line=0.25)
   dev.off() 
  }  # End of variable loop
 }  # End of metric loop

 if(textstats){
   textfile   <- paste(plotopts$figdir,"/","raob.spatial.TEMP.",plotlab$datelab,".", 
                    plotlab$figurelablev,".",plotopts$project,".csv",sep="")
   writeLines(paste("Writing spatial statistics csv text file for TEMP:",textfile))
   sitetxtout <-data.frame(slatlon,format(statsq[,1,1:4], digits = 3))
   write.table(sitetxtout,file=textfile,append=F, quote=F, sep=",",
               col.names=c(" siteID, siteLat "," siteLon "," TEMP RMSE "," TEMP MAE "," TEMP BIAS "," TEMP CORR "),
               row.names=sitesq)
   textfile   <- paste(plotopts$figdir,"/","raob.spatial.RH.",plotlab$datelab,".", 
                    plotlab$figurelablev,".",plotopts$project,".csv",sep="")
   writeLines(paste("Writing spatial statistics csv text file for RH:",textfile))
   sitetxtout <-data.frame(slatlon,format(statsq[,2,1:4], digits = 3))
   write.table(sitetxtout,file=textfile,append=F, quote=F, sep=",",
               col.names=c(" siteID, siteLat "," siteLon "," RH RMSE "," RH MAE "," RH BIAS "," RH CORR "),
               row.names=sitesq)
   textfile   <- paste(plotopts$figdir,"/","raob.spatial.WS.",plotlab$datelab,".", 
                    plotlab$figurelablev,".",plotopts$project,".csv",sep="")
   writeLines(paste("Writing spatial statistics csv text file for WS:",textfile))
   sitetxtout <-data.frame(slatlon,format(statsq[,3,1:4], digits = 3))
   write.table(sitetxtout,file=textfile,append=F, quote=F, sep=",",
               col.names=c(" siteID, siteLat "," siteLon "," WS RMSE "," WS MAE "," WS BIAS "," WS CORR "),
               row.names=sitesq)
   textfile   <- paste(plotopts$figdir,"/","raob.spatial.WD.",plotlab$datelab,".", 
                    plotlab$figurelablev,".",plotopts$project,".csv",sep="")
   writeLines(paste("Writing spatial statistics csv text file for WD:",textfile))
   sitetxtout <-data.frame(slatlon,format(statsq[,4,1:3], digits = 3))
   write.table(sitetxtout,file=textfile,append=F, quote=F, sep=",",
               col.names=c(" siteID, siteLat "," siteLon "," WD RMSE "," WD MAE "," WD BIAS "),
               row.names=sitesq)
   textfile   <- paste(plotopts$figdir,"/","raob.spatial.WNDVEC.",plotlab$datelab,".", 
                    plotlab$figurelablev,".",plotopts$project,".csv",sep="")
   writeLines(paste("Writing spatial statistics csv text file for WNDVEC:",textfile))
   sitetxtout <-data.frame(slatlon,format(statsq[,5,2], digits = 3))
   write.table(sitetxtout,file=textfile,append=F, quote=F, sep=",",
               col.names=c(" siteID, siteLat "," siteLon "," WNDVEV MAE "),
               row.names=sitesq)
 }

  
 }
###############################################################
#-------------------  END OF FUNCTION  ----------------------##
###############################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Plot Spatial Statistics for RAOB-Model Comparison
#
# Input: statistics array, site information, levels for each statistic
#        and met variable, color scale, plot options and labels
#   
# Output:  PDF plots of T,RH,WS and WD RMSE, MAE, BIAS and CORR 
#   
###

 ################################################################
 plotTseriesRaobM <-function(statsq, date.vecm,
                           plotopts, plotlab, textstats=F) {
 ################################################################
 nv<- length(varID)
 nm<- length(metricID)
 ns<- dim(statsq)[1]

 if( dim(statsq)[2] > nv ) {
   writeLines("** Importance Notice **")
   writeLines("raob.input is old and does not consider wind vector error")
   writeLines("WNDVEC mean error plot skipped until raob.input is update to AMETv1.5+")
 }
 nt<- length(date.vecm)
 for(v in 1:nv) {

   figure  <- paste(plotopts$figdir,"/","raob.daily.",varID[v],".",plotlab$datelab,".", 
                    plotlab$figurelablev,".",plotopts$project,".",plotopts$plotfmt,sep="")
   textfile<- paste(plotopts$figdir,"/","raob.daily.",varID[v],".",plotlab$datelab,".", 
                    plotlab$figurelablev,".",plotopts$project,".csv",sep="")

   if (plotopts$plotfmt == "pdf"){
     pdf(file= figure, width = 11, height = 8.5)
   }
   if (plotopts$plotfmt == "png"){
     bitmap(file=figure, width = (700*plotopts$plotsize)/100, 
            height = (541*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)
   }
   writeLines(paste("*************************************************"))
   writeLines(paste("Plotting RAOB Timeseries Statistics ",plotlab$varName[v]))
   writeLines(paste(figure))
   if(textstats){
    writeLines(paste("Writing daily statistics csv text file:",textfile))
    write.table(format(statsq[,v,1:4], digits = 3),file=textfile,append=F, quote=F, sep=",",
                col.names=c("     DATE/TIME,        RMSE","    MAE","     BIAS","    CORR"),
                row.names=date.vecm)
   }

   par(mfrow=c(4,1))
   par(bg="white")
   par(fg="black")
   par(mai=c(0.25,0.5,0.25,0.25))
   par(mgp=c(1.40,0.2,0))

   if(v == 5) {
     # If mean wind vector error plot as MAE and skip other panels
     m <-2
     tmpvarlab1<-paste(metricID[m]," (",plotlab$varUnits[v],")", sep="")
     tmpvarlab2<-paste("Daily ",plotlab$varName[v]," ",metricID[m]," (",plotlab$varUnits[v],")", sep="")
     plotvar   <-statsq[,v,m]
     par(new=F)
     plot(date.vecm,plotvar,xlab="",axes=FALSE,ylab=tmpvarlab1,
          xlim=range(date.vecm),pch=4,cex=0.75,col="black",
          vfont=c("serif","bold"),label=TRUE,type="l",lwd=2)
     par(tck=1)
     axis(1,col="black",lty=3,at=date.vecm[seq(1,nt)],
          labels=date.vecm[seq(1,nt)], col.ticks="gray")
     axis(2,col="black",lty=3, col.ticks="gray")
     title(tmpvarlab2)
     box()
     dev.off()
     break
   }

   # RMSE Panel (1 of 4)
   m <-1
   tmpvarlab1<-paste(metricID[m]," (",plotlab$varUnits[v],")", sep="")
   tmpvarlab2<-paste("Daily ",plotlab$varName[v]," ",metricID[m]," (",plotlab$varUnits[v],")", sep="")
   plotvar   <-statsq[,v,m]
   par(new=F)
   plot(date.vecm,plotvar,xlab="",axes=FALSE,ylab=tmpvarlab1,
        xlim=range(date.vecm),pch=4,cex=0.75,col="black",
        vfont=c("serif","bold"),label=TRUE,type="l",lwd=2)
   par(tck=1)
   axis(1,col="black",lty=3,at=date.vecm[seq(1,nt)],
        labels=date.vecm[seq(1,nt)], col.ticks="gray")
   axis(2,col="black",lty=3, col.ticks="gray")
   title(tmpvarlab2)
   box()
   
   # MAE Panel (2 of 4)
   m <-2
   tmpvarlab1<-paste(metricID[m]," (",plotlab$varUnits[v],")", sep="")
   tmpvarlab2<-paste("Daily ",plotlab$varName[v]," ",metricID[m]," (",plotlab$varUnits[v],")", sep="")
   plotvar   <-statsq[,v,m]
   plot(date.vecm,plotvar,xlab="",axes=FALSE,ylab=tmpvarlab1,
        xlim=range(date.vecm),pch=4,cex=0.75,col="black",
        vfont=c("serif","bold"),label=TRUE,type="l",lwd=2)
   par(tck=1)
   axis(1,col="black",lty=3,at=date.vecm[seq(1,nt)],
        labels=date.vecm[seq(1,nt)], col.ticks="gray")
   axis(2,col="black",lty=3, col.ticks="gray")
   title(tmpvarlab2)
   box()
   # BIAS Panel (3 of 4)
   m <-3
   tmpvarlab1<-paste(metricID[m]," (",plotlab$varUnits[v],")", sep="")
   tmpvarlab2<-paste("Daily ",plotlab$varName[v]," ",metricID[m]," (",plotlab$varUnits[v],")", sep="")
   plotvar   <-statsq[,v,m]
   plot(date.vecm,plotvar,xlab="",axes=FALSE,ylab=tmpvarlab1,
        xlim=range(date.vecm),pch=4,cex=0.75,col="black",
        vfont=c("serif","bold"),label=TRUE,type="l",lwd=2)
   par(tck=1)
   lines(c(date.vecm[nt],date.vecm[1]),c(0,0),col="black",lwd=1)
   axis(1,col="black",lty=3,at=date.vecm[seq(1,nt)],
        labels=date.vecm[seq(1,nt)], col.ticks="gray")
   axis(2,col="black",lty=3, col.ticks="gray")
   title(tmpvarlab2)
   box()
   # Correlation Panel (4 of 4)
   if(v == 4) {
     # If wind direction skip correlation panel and end plot
     dev.off()
   }
   if(v != 4) {
    m <-4
    tmpvarlab1<-paste(metricID[m], sep="")
    tmpvarlab2<-paste("Daily ",plotlab$varName[v]," ",metricID[m], sep="")
    plotvar   <-statsq[,v,m]
    tmpmin    <-min(plotvar,na.rm=T)
    plot(date.vecm,plotvar,xlab="",axes=FALSE,ylab=tmpvarlab1,
         xlim=range(date.vecm),ylim=c(tmpmin,1),pch=4,cex=0.75,col="black",
         vfont=c("serif","bold"),label=TRUE,type="l",lwd=2)
    par(tck=1)
    axis(1,col="black",lty=3,at=date.vecm[seq(1,nt)],
         labels=date.vecm[seq(1,nt)], col.ticks="gray")
    axis(2,col="black",lty=3, col.ticks="gray")
    title(tmpvarlab2)
    box()
    dev.off()
   }

 }   # End loop over variables

 return()

 }
###############################################################
#-------------------  END OF FUNCTION  ----------------------##
###############################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Profile Statistics for RAOB-Model Comparison
#
# Input: statistics array, site information, levels for each statistic
#        and met variable, color scale, plot options and labels
#   
# Output:  PDF profile plots for T, RH, WS and WS. Each variable has
#          a multipanel profile boxplot of diffs, RMSE, BIAS and CORR.
#   
###

 ################################################################
 plotProfRaobM <-function(statsq.new, diffsq.new, levels.new, 
                          site_name, plotopts, plotlab) {
 ################################################################

 # Set correlation of WD to 0
 statsq.new[,4,4] <- 0
 nz               <- length(levels.new)
 ndiffs           <- dim(diffsq.new)[3]
 for(v in 1:4){

  num.nas<-sum(ifelse(is.na(statsq.new[,v,3]),1,0))
  if(num.nas > (nz/2)){
    writeLines(paste("*** Not enough data for the profile stats plots. Variable:",
                     plotlab$varName[v],"Will skip. ***"))
    next
  }

  figure <- paste(plotopts$figdir,"/","raob.profileM.",site_name,".",varID[v],".", 
                  plotlab$datelab,".",plotopts$project,".",plotopts$plotfmt,sep="")

  if (plotopts$plotfmt == "pdf"){
    pdf(file= figure, width = 15, height = 8.4, pointsize=16)
  }
  if (plotopts$plotfmt == "png"){
    bitmap(file=figure, width = (700*plotopts$plotsize)/100, 
           height = (541*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)
  }
  writeLines(paste("*************************************************"))
  writeLines(paste("Plotting",plotlab$varName[v]))
  writeLines(paste(figure))

  par(mfrow=c(1,1))
  par(mfrow=c(1,4))
  par(bg="white")
  par(fg="black")
  proflim <-range(levels.new)

  ### BOXPLOT of Differences
  par(mai=c(0.50,0.5,0.2,0))
  par(mgp=c(2,0.7,0))
  datam    <-matrix();
  levelsm  <-matrix();
  count    <-1
  for(z in 1:nz) {
    datam[count:(count+ndiffs-1)]   <- diffsq.new[z,v,]
    levelsm[count:(count+ndiffs-1)] <- levels.new[z]
    count                           <-count+ndiffs
  }
  df.stats<-data.frame(datam,levelsm) 
  boxplot(datam ~ factor(levelsm, levels=levels.new), data=df.stats, ylab="Pressure (mb)", 
          xlab=paste("MOD-OBS (",plotlab$varUnits[v],")",sep=""),main="", varwidth=T, 
          horizontal=T, col="bisque", outline=T)
  title(plotlab$varName[v])

  ### BIAS profile
  par(mai=c(0.50,0.5,0.2,0.2))
  par(mgp=c(2,0.7,0))
  xlims    <- range(statsq.new[,v,3],na.rm=T)
  xlims[1] <- -1*max(abs(xlims))
  xlims[2] <-  1*max(abs(xlims))
  par(tck=0.05)
  plot(statsq.new[,v,3],levels.new,xlim=xlims,ylim=rev(proflim), axes=T,
       ylab="Pressure (mb)", xlab=paste("BIAS (",plotlab$varUnits[v],")",sep=""),
       type='o',pch=19, col="black")
  par(tck=1)
  axis(2,col=gray(.9),at=levels.new,labels=F)
  lines(c(0,0),rev(proflim),col="gray",lwd=1)
  box()
  title(plotlab$varName[v])

  ### RMSE profile
  par(mai=c(0.50,0.5,0.2,0.2))
  par(mgp=c(2,0.7,0))
  xlims    <- ceiling(range(statsq.new[,v,1],na.rm=T))
  xlims[1] <- 0
  #xlims[2] <- 25
  par(tck=0.05)
  plot(statsq.new[,v,1],levels.new,xlim=xlims,ylim=rev(proflim), axes=T,
       ylab="Pressure (mb)", xlab=paste("RMSE (",plotlab$varUnits[v],")",sep=""),
       type='o',pch=19, col="black")
  par(tck=1)
  axis(2,col=gray(.9),at=levels.new,labels=F)
  box()
  title(plotlab$varName[v])

  ### ANOMALY CORR profile
  par(mai=c(0.50,0.5,0.2,0.2))
  par(mgp=c(2,0.7,0))
  xlims    <- c(0,1)
  par(tck=0.05)
  plot(statsq.new[,v,4],levels.new,xlim=xlims,ylim=rev(proflim), axes=T,
       ylab="Pressure (mb)", xlab=paste("IOA Corr",sep=""),
       type='o',pch=19, col="black")
  par(tck=1)
  axis(2,col=gray(.9),at=levels.new,labels=F)
  box()
  title(plotlab$varName[v])

  dev.off()

  }

 }

###############################################################
#-------------------  END OF FUNCTION  ----------------------##
###############################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Plot Distribtions of RAOB-Model on each Pressure Level
#
# Input: statistics array, site information, levels for each statistic
#        and met variable, plot options and labels
#   
# Output:  Profile plots for T, RH, WS and WD. Each variable has
#          2 panel plot of the Obs and Model distribution on each
#          pressure level.
#   
###

 ################################################################
 plotDistRaobM <-function(obsmod, levels.new, site_name,
                          plotopts, plotlab) {
 ################################################################
 nz               <- length(levels.new)
 ndiffs           <- dim(obsmod)[3]
 for(z in 1:nz){

  obs <- obsmod[z,1,]
  mod <- obsmod[z,2,]
  obs <-ifelse(obs > 100, 100, obs)
  mod <-ifelse(mod > 100, 100, mod)
  obs <-ifelse(obs < 0, 0.1, obs)
  mod <-ifelse(mod < 0, 0.1, mod)

  num.good <-sum( ifelse(is.na(obs),0,1))
  if(num.good == 0) { 
    writeLines(paste("Pressure level",levels.new[z],"has no data. No plot was generated."))
    next
  }

  figure <- paste(plotopts$figdir,"/","raob.RHdist.",site_name,".",plotlab$datelab,".", 
                  levels.new[z],"mb.",plotopts$project,".",plotopts$plotfmt,sep="")
  if (plotopts$plotfmt == "pdf"){
    pdf(file= figure, width = 10, height = 12, pointsize=16)
  }
  if (plotopts$plotfmt == "png"){
    bitmap(file=figure, width = (700*plotopts$plotsize)/100, 
           height = (541*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)
  }
  writeLines(paste("*************************************************"))
  writeLines(paste("Plotting distribution of RH at level:",levels.new[z],"mb"))
  writeLines(paste(figure))

  par(mfrow=c(3,1))
  par(bg="white")
  par(fg="black")

  ### BOXPLOT of Differences
  par(mai=c(0.75,0.75,0.5,0.5))
  par(mai=c(0.5,0.5,0.25,0.25))
  par(mgp=c(2,0.7,0))

  a   <-hist(obs,breaks=seq(0,100,by=5), plot = F)  
  b   <-hist(mod,breaks=seq(0,100,by=5), plot = F) 
  maxcount <- max( a$counts, b$counts, na.rm=T) 
  hist(obs,breaks=seq(0,100,by=5),ylim=c(0,maxcount), freq=T,ylab="Count",
       xlab=paste("RAOB RH (mb)"),main="", plot = T)  
  hist(mod,breaks=seq(0,100,by=5),ylim=c(0,maxcount), freq=T,ylab="Count",
       xlab=paste("Model RH (mb)"),main="", plot = T)  
  plot(a$mids,b$counts-a$counts,type='b',ylab="Mod-Obs Count",xlab="RH(%)")
  lines(c(100,0),c(0,0),col="gray",lwd=2)
  dev.off()

  }

 }
###############################################################
#-------------------  END OF FUNCTION  ----------------------##
###############################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Plot Curtain plots of RAOB and Model on Mandatory pressure
###  levels. T, RH, WS and WD. RAOB, Model and difference plots
#
# Input: obs/model array, levels, date vector, site name,
#        met variable, plot options and labels
#   
# Output:  Curtain plots for T, RH, WS and WD. Plot of RAOB, Model
#          and difference.
#          
#   
###

 ################################################################
 plotProfTimeM <-function(obsmod, levels.new, iso.date, date.vec,
                          site_name, varnum, plotopts, plotlab, nt.thresh=5) {
 ################################################################
 #plotProfTimeM(obsmodt.new, levels.new, iso.datet, date.vec,statid[s], 1, plotopts, plotlab) 
 #obsmod    <- obsmodt.new
 #iso.date  <- iso.datet
 #site_name <- statid[s]
 # Take obsmod array and reshape into timeseries that matches date.vec
 nt           <- length(date.vec)
 omdims       <- dim(obsmod)
 stdheight    <-c(0,0.8,1.5,3,5.5,7,9,10.5,12,13.5,16,18.5,20.5,24.0,26.5,31.5)
 stdpress     <-c(1000,925,850,700,500,400,300,250,200,150,100,70,50,30,20,10)

 # Check levels in data to remove any that are not mandatory.
 is.mandatory <- which(is.element(levels.new,stdpress))
 levels.new   <- levels.new[is.mandatory]
 nz           <- length(levels.new)

 obs <-array(NA,c(nz,nt))
 mod <-array(NA,c(nz,nt))
 for(tt in 1:nt){
   a<-which(date.vec[tt] == iso.date)
   if(length(a) == 0 || a>nt ) { next }
   obs[,a[1]] <-obsmod[is.mandatory,1,a[1]]
   mod[,a[1]] <-obsmod[is.mandatory,2,a[1]]
 }

 nt.nona<-sum(ifelse(!is.na(obs[nz,]),1,0))

 if(nt.nona < nt.thresh || nz == 0 ) {
   writeLines(paste("Not enough or no mandatory pressure level data was",
              "found at",site_name,"for variable:",plotlab$varID[varnum]))
   return()
 }

 obs.new <- obs
 mod.new <- mod

 max.diff        <- max(abs(mod.new-obs.new),na.rm=T)
 plot.lev.range  <-round(c(0,max(obs.new,mod.new,na.rm=T)))
 diff.lev.range  <-round(c(-1*max.diff,max.diff))

 if(varnum == 1) { plot.lev.range[1] <- min(obs.new,mod.new,na.rm=T) }
 if(varnum == 2) { plot.lev.range[2] <- 100 }
 if(varnum == 4) { plot.lev.range[2] <- 360 }
 plot.levs<-round(seq(plot.lev.range[1],plot.lev.range[2],length.out=12))
 diff.levs<-round(seq(diff.lev.range[1],diff.lev.range[2],length.out=12))

 if(varnum == 1) { diff.levs <- round(seq(-6,6,length.out=12)) }
 if(varnum == 2) { diff.levs <- round(seq(-50,50,length.out=12)) }
 if(varnum == 3) { diff.levs <- round(seq(-6,6,length.out=12)) }
 if(varnum == 4) { diff.levs <- round(seq(-90,90,length.out=12)) }

  figure1 <- paste(plotopts$figdir,"/","raob.curtainM.",site_name,".OBS.",plotlab$varID[varnum],".", 
                   plotlab$datelab,".",plotopts$project,".",plotopts$plotfmt,sep="")
  figure2 <- paste(plotopts$figdir,"/","raob.curtainM.",site_name,".MOD.",plotlab$varID[varnum],".", 
                   plotlab$datelab,".",plotopts$project,".",plotopts$plotfmt,sep="")
  figure3 <- paste(plotopts$figdir,"/","raob.curtainM.",site_name,".MOD-OBS.",plotlab$varID[varnum],".", 
                   plotlab$datelab,".",plotopts$project,".",plotopts$plotfmt,sep="")

  writeLines(paste("*************************************************"))
  writeLines(paste("Plotting Time-Pressure (Curtain Plot) of Met for ",
                    plotlab$varName[varnum],"Site:",site_name))
 
 hgt      <-array(NA,c(nz))
 for(zz in 1:nz){
   zi     <- which(levels.new[zz] == stdpress)
   hgt[zz]<-stdheight[zi]
 }

 writeLines(paste(figure1))
 pdf(file= figure1, width = 14, height = 7, pointsize=12)
 plot.title<-paste("RAOB Curtain Plot of ", plotlab$varName[varnum],
                  "(",plotlab$varUnits[varnum],")"," at site ", site_name, sep="")
 filled.contour(date.vec, hgt, t(obs.new),  color.palette =topo.colors,levels=plot.levs,
                plot.axes= {axis(1,at=date.vec,col=gray(.25),labels=date.vec, lwd=1) },
                xlab="Date/Time", ylab="Pressure (mb)")
 axis(2,col=gray(.85),at=hgt,labels=levels.new,cex=0.85)
 title(main=plot.title)
 dev.off()

 writeLines(paste(figure2))
 pdf(file= figure2, width = 14, height = 7, pointsize=12)
 plot.title<-paste("MODEL Curtain Plot of ", plotlab$varName[varnum],
                  "(",plotlab$varUnits[varnum],")"," at site ", site_name, sep="")
 filled.contour(date.vec, hgt, t(mod.new),  color.palette =topo.colors,levels=plot.levs,
                plot.axes= {axis(1,at=date.vec,col=gray(.25),labels=date.vec, lwd=1) },
                xlab="Date/Time", ylab="Pressure (mb)")
 axis(2,col=gray(.85),at=hgt,labels=levels.new,cex=0.85)
 title(main=plot.title)
 dev.off()

 writeLines(paste(figure3))
 pdf(file= figure3, width = 14, height = 8, pointsize=12)
 plot.title<-paste("MODEL-RAOB Curtain Plot of ", plotlab$varName[varnum],
                  "(",plotlab$varUnits[varnum],")"," at site ", site_name, sep="")
 filled.contour(date.vec, hgt, t(mod.new-obs.new),  color.palette =topo.colors,
                plot.axes= {axis(1,at=date.vec,col=gray(.25),labels=date.vec, lwd=1) },
                levels=diff.levs, xlab="Date/Time", ylab="Pressure (mb)")
 axis(2,col=gray(.85),at=hgt,labels=levels.new,cex=0.85)
 title(main=plot.title)
 dev.off()

 return(writeLines("Finished mandatory level curtain plots"))
 }
###############################################################
#-------------------  END OF FUNCTION  ----------------------##
###############################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Profiles for RAOB-Model Comparison
#
# Input:   Data list for raob and model with pressure, temp, rh,
#          u, v and the time stamp.
#   
# Output:  PDF profile plots for T/RH or WS/WD. Each variable has
#          a 2 panel profile plot. One for each variable duo.
#   
###

 ################################################################
 plotProfRaobN <-function(raob, model, plotopts, plotlab) {
 ################################################################

  variables="TEMP-RH"

  tmpa        <-unlist(strsplit(raob$date,split=" "))
  datestamp   <-paste(tmpa[1],tmpa[2],sep="_")

  theta_raob  <- raob$t * (1000/raob$p_trh)^0.286
  theta_model <- model$t *(1000/model$p_trh)^0.286


  # Interpolate obs to model levels for difference plotting
  func              = splinefun(x=model$p_trh, y=theta_model, method="fmm",  ties = mean)
  mod_on_raob_theta <-func(raob$p_trh)
  func              = splinefun(x=model$p_trh, y=model$rh, method="fmm",  ties = mean)
  mod_on_raob_rh    <-func(raob$p_trh)

  # Mask out model on obs level values where obs pressure is less or more than model range
  mod_on_raob_theta <-ifelse( raob$p_trh < min(model$p_trh,na.rm=T), NA, mod_on_raob_theta)
  mod_on_raob_theta <-ifelse( raob$p_trh > max(model$p_trh,na.rm=T), NA, mod_on_raob_theta)
  mod_on_raob_rh    <-ifelse( raob$p_trh < min(model$p_trh,na.rm=T), NA, mod_on_raob_rh)
  mod_on_raob_rh    <-ifelse( raob$p_trh > max(model$p_trh,na.rm=T), NA, mod_on_raob_rh)
  
  figure <- paste(plotopts$figdir,"/","raob.profileN.",raob$site,".",variables,".", 
                  datestamp,".",plotopts$project,".",plotopts$plotfmt,sep="")

  if (plotopts$plotfmt == "pdf"){
    pdf(file= figure, width = 10, height = 10, pointsize=16)
  }
  if (plotopts$plotfmt == "png"){
    bitmap(file=figure, width = (800*plotopts$plotsize)/100, 
           height = (800*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)
  }
  writeLines(paste("Figure output:",figure))
  writeLines(paste("*************************************************"))

  par(mfrow=c(1,1))
  par(mfrow=c(2,2))
  par(bg="white")
  par(fg="black")

  ### BOXPLOT of Differences
  par(mai=c(0.5,0.75,0.5,0.1))
  par(mgp=c(2,0.7,0))

  limsx   <-range(theta_model,theta_raob)
  limsp   <-range(raob$p_trh,model$p_trh)

  diff.th <-mod_on_raob_theta-theta_raob
  maxd.th <-ceiling(abs(max(diff.th,na.rm=T)))

  diff.rh <-mod_on_raob_rh-raob$rh
  maxd.rh <-ceiling(abs(max(diff.rh,na.rm=T)))

  plot(theta_raob, raob$p_trh, xlim=limsx, ylim=rev(limsp), 
       xlab="", ylab="Pressure (mb)", type='l', col='red')
  par(new=T)
  plot(theta_model, model$p_trh, xlim=limsx, ylim=rev(limsp), 
       xlab="", ylab="", type='l', col='blue')
  legend(limsx[1],min(limsp),c("RAOB","Model"),col=c("red","blue"),lty=1,lwd=2,cex=0.90,xjust=.20)
  title("Potential Temperature (K)")

  plot(diff.th, raob$p_trh, xlim=c(-maxd.th,maxd.th), ylim=rev(limsp),
       xlab="", ylab="Pressure (mb)", type='l', col='red')
  lines(c(0,0),rev(limsp),col="gray",lwd=1)
  title("Model-RAOB Theta (K)")

  plot(raob$rh, raob$p_trh,xlim=c(0,100), ylim=rev(limsp),
       xlab="", ylab="Pressure (mb)", type='l', col='red')
  par(new=T)
  plot(model$rh, model$p_trh,xlim=c(0,100), ylim=rev(limsp),
       xlab="", ylab="", type='l', col='blue')
  legend(0,min(limsp),c("RAOB","Model"),col=c("red","blue"),lty=1,lwd=2,cex=0.90,xjust=.20)
  title("Relative Humidity (%)")

  plot(diff.rh, raob$p_trh, xlim=c(-maxd.rh,maxd.rh), ylim=rev(limsp),
       xlab="", ylab="Pressure (mb)", type='l', col='red')
  lines(c(0,0),rev(limsp),col="gray",lwd=1)
  title("Model-RAOB RH (%)")

  dev.off()

 }

###############################################################
#-------------------  END OF FUNCTION  ----------------------##
###############################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Plot Curtain plots of RAOB and Model on Native pressure levs
###  levels. Variable are temperature and rel. humidity
#
# Input: raob list, model list, site name, plot options and labels
#        obs and model lists contain date vectors, levels and data.
#   
# Output:  Curtain plots for T and RH. Plot has model as background
#          and raob values plotted as symbols overlaid with same      
#          color scale.
###

 ################################################################
 plotProfTimeN <-function(raob, model, plotopts, plotlab, user.custom.plot.settings, profilen.thresh=5) {
 ################################################################

 # Date manipulation. Change to character string for manipulation for plot labels.
 date.char <-as.character(model$datev)

 # Take obsmod array and reshape into timeseries that matches date.vec.
 # 
 nz    <- 150
 nt    <- length(model$datev)

 # Obs Model arrays. 3 positions. 1-pressure, 2-temp, 3-rh
 obs   <-array(NA,c(nz,nt,4))
 mod   <-array(NA,c(nz,nt,4))
 maxnlo<- 0
 maxnlm<- 0
 for(tt in 1:nt){
   a          <-which(raob$datev[tt]  == raob$date)
   b          <-which(model$datev[tt] == model$date)
   if(length(a) == 0 || length(b) == 0) { next }
   na         <-length(a)
   nb         <-length(b)         
   obs[1:na,tt,1] <-rev(raob$p_trh[a])
   mod[1:nb,tt,1] <-rev(model$p_trh[b])
   obs[1:na,tt,2] <-rev(raob$t[a])
   mod[1:nb,tt,2] <-rev(model$t[b])
   obs[1:na,tt,4] <-rev(raob$rh[a])
   mod[1:nb,tt,4] <-rev(model$rh[b])
   if( na > maxnlo ) { maxnlo <- na }
   if( nb > maxnlm ) { maxnlm <- nb }
 }

 # If max good data in all observed profiles is less than threshold abort plotting
 # for this site and return to plot the next site.
 if(maxnlo < profilen.thresh) {
   return(paste("Not enough samples at site ",raob$site,". Threshold of ",profilen.thresh," not met."))
 }


 # Reduce array size to the max levels in a single profile.
 obs      <- obs[1:maxnlo,,]
 mod      <- mod[1:maxnlm,,]

 # Convert temperature to potential temperature
 obs[,,3] <-obs[,,2] * (1000/obs[,,1])^0.286
 mod[,,3] <-mod[,,2] * (1000/mod[,,1])^0.286

 # Set model layer pressure to the average for the period.
 # Rational is there are only minimal changes and shaded plotting 
 # requires static value for each level. Approx. the height of 
 # each layer using hypsometric eq.
 hgt <- array(NA,maxnlm)
 for(z in 1:maxnlm) {
  #mod[z,,1] <- round(mean(mod[z,,1],na.rm=T))
  mod[z,,1] <- mean(mod[z,,1],na.rm=T)
  #if(z == 1) {
  #  p2  <- mod[z,1,1]/10
  #  p1  <- 100
  #  log(p1/p2)*29.3*mean(mod[,,2],na.rm=T)
  #}
 }
 plot.plevs <- sort(mod[,1,1],decreasing =T)

 # Flip Y diminsion of data arrays for the fact that pressure 
 # decreases with height. Neccessary for filled.contour plotting.
 model_theta<-mod[,,3]*NA
 model_rh   <-mod[,,4]*NA
 for(tt in 1:nt){
  model_theta[,tt]<-rev(mod[,tt,3])
  model_rh[,tt]   <-rev(mod[,tt,4])
 }

# Interpolate Model to Obs levels for bias/difference plotting.
  mod_theta_obs      <- model_theta * NA
  mod_theta_obs_diff <- model_theta * NA
  mod_rh_obs         <- model_rh * NA
  mod_rh_obs_diff    <- model_rh * NA

  mod_theta_obs      <- obs[,,3] * NA
  mod_theta_obs_diff <- obs[,,3] * NA
  mod_rh_obs         <- obs[,,4] * NA
  mod_rh_obs_diff    <- obs[,,4] * NA

  for(tt in 1:nt){  
    obs.levels             <- obs[,tt,1]
    num_good_levs          <- sum(ifelse(!is.na(obs.levels),1,0))
    #if(num_good_levs < profilen.thresh) { next}
    if(num_good_levs < 2) { next}

    func        = splinefun(x=mod[,tt,1], y=rev(model_theta[,tt]), method="fmm",  ties = mean)
    mod_theta_obs[,tt]     <-func(obs.levels)
    mod_theta_obs_diff[,tt]<- mod_theta_obs[,tt] - obs[,tt,3]

    func        = splinefun(x=mod[,tt,1], y=rev(model_rh[,tt]), method="fmm",  ties = mean)
    mod_rh_obs[,tt]        <-func(obs.levels)
    mod_rh_obs_diff[,tt]   <- mod_rh_obs[,tt] - obs[,tt,4]
    
    # If observed pressure is below or above model pressure set NA because of bad interp
    ind_below <- which( obs[,tt,1] > max(mod[,tt,1],na.rm=T))
    ind_above <- which( obs[,tt,1] < min(mod[,tt,1],na.rm=T))
    if(length(ind_below) > 0 ) {
      mod_theta_obs[ind_below,tt]      <- NA
      mod_theta_obs_diff[ind_below,tt] <- NA
      mod_rh_obs[ind_below,tt]         <- NA
      mod_rh_obs_diff[ind_below,tt]    <- NA
    }
    if(length(ind_above) > 0 ) {
      mod_theta_obs[ind_above,tt]      <- NA
      mod_theta_obs_diff[ind_above,tt] <- NA
      mod_rh_obs[ind_above,tt]         <- NA
      mod_rh_obs_diff[ind_above,tt]    <- NA
    }
  }

 # Setup plot limits and levels
 plot.lims.t      <- round(range(obs[,,3],mod[,,3],na.rm=T))
 plot.lims.rh     <- round(range(obs[,,4],mod[,,4],na.rm=T))
 plot.lims.t.diff <- round(max(abs((range(mod_theta_obs_diff,na.rm=T))),na.rm=T))
 plot.lims.rh.diff<- round(max(abs((range(mod_rh_obs_diff,na.rm=T))),na.rm=T))
 # User User settings
 if(user.custom.plot.settings$use.user.range){
  plot.lims.t.diff  <-user.custom.plot.settings$diff.t
  plot.lims.rh.diff <-user.custom.plot.settings$diff.rh
 }


 plot.levs.t      <-unique(round(seq(plot.lims.t[1],plot.lims.t[2],length.out=15)))
 plot.levs.rh     <-unique(round(seq(plot.lims.rh[1],plot.lims.rh[2],length.out=15)))
 plot.levs.t.diff <-unique(seq(-1*plot.lims.t.diff,plot.lims.t.diff,length.out=15))
 plot.levs.rh.diff<-unique(seq(-1*plot.lims.rh.diff,plot.lims.rh.diff,length.out=15))

 # Create color arrays for raob observations that match shaded model color scheme
 pcols.to        <-array("white",c(maxnlo,nt))
 pcols.rho       <-array("white",c(maxnlo,nt))
 pcols.to.diff   <-array("white",c(maxnlo,nt))
 pcols.rho.diff  <-array("white",c(maxnlo,nt))
 cols.t          <-topo.colors(length(plot.levs.t))
 cols.rh         <-topo.colors(length(plot.levs.rh))
 cols.t.diff     <-topo.colors(length(plot.levs.t.diff))
 cols.rh.diff    <-topo.colors(length(plot.levs.rh.diff))

 cols.t          <-topo.colors(length(plot.levs.t))
 cols.rh         <-rev(topo.colors(length(plot.levs.rh)))
 cols.t.diff     <-topo.colors(length(plot.levs.t.diff))
 cols.rh.diff    <-rev(topo.colors(length(plot.levs.rh.diff)))

 plotval.to      <-obs[,,3]
 plotval.rho     <-obs[,,4]
 plotval.to.diff <-mod_theta_obs_diff
 plotval.rho.diff<-mod_rh_obs_diff

 datelab    <- array(NA,nt)
 for(tt in 1:nt) {
    pcols.to[,tt]       <-cols.t[cut(plotval.to[,tt],br=plot.levs.t,labels=FALSE,include.lowest=T,right=T)]
    pcols.rho[,tt]      <-cols.rh[cut(plotval.rho[,tt],br=plot.levs.rh,labels=FALSE,include.lowest=T,right=T)]
    pcols.to.diff[,tt]  <-cols.t.diff[cut(plotval.to.diff[,tt],br=plot.levs.t.diff,labels=FALSE,include.lowest=T,right=T)]
    pcols.rho.diff[,tt] <-cols.rh.diff[cut(plotval.rho.diff[,tt],br=plot.levs.rh.diff,labels=FALSE,include.lowest=T,right=T)]
    tmp1                <- unlist(strsplit(date.char[tt],split=" "))
    tmp2                <- unlist(strsplit(tmp1[1],split="-"))
    tmp3                <- unlist(strsplit(tmp1[2],split=":"))
    datelab[tt]         <- paste(tmp2[2],"/",tmp2[3],sep="")
 }

 tmp1              <- unlist(strsplit(date.char[1],split=" "))
 tmp2              <- unlist(strsplit(tmp1[1],split="-"))
 year.month.lab    <- paste(tmp2[1],"-",tmp2[2],sep="")
 year.month.lab    <- paste(tmp2[1],sep="")

 # Double check that vertical pressure coordinate has no duplicity or NA's
 num.nas <- sum(ifelse(is.name(mod[,1,1]),1,0))
 if(num.nas > 0) { 
  return(paste("Aborting plot because of NA's in pressure. Site:",raob$site))
 }
 num.unique.p <- length(unique(mod[,1,1]))
 if(num.unique.p != maxnlm) {
  return(paste("Aborting plot because of duplicate pressure levels. Site:",raob$site))
 }

 # Figure names and print to log or screen
 figure1 <- paste(plotopts$figdir,"/","raob.curtainN.",raob$site,".T.", 
                  plotlab$datelab,".",plotopts$project,".",plotopts$plotfmt,sep="")
 figure2 <- paste(plotopts$figdir,"/","raob.curtainN.",raob$site,".RH.", 
                  plotlab$datelab,".",plotopts$project,".",plotopts$plotfmt,sep="")
 figure3 <- paste(plotopts$figdir,"/","raob.curtainN.",raob$site,".T.DIFF.", 
                  plotlab$datelab,".",plotopts$project,".",plotopts$plotfmt,sep="")
 figure4 <- paste(plotopts$figdir,"/","raob.curtainN.",raob$site,".RH.DIFF.", 
                  plotlab$datelab,".",plotopts$project,".",plotopts$plotfmt,sep="")

 writeLines(paste("*************************************************"))
 writeLines(paste("Plotting Time-Pressure (Curtain Plot) on Native Levels for ",
                    "Temperature and Rel. Humidity at Site:", raob$site))
 writeLines(paste(figure1))
 writeLines(paste(figure2))
 writeLines(paste(figure3))
 writeLines(paste(figure4))
 
 # Main figure plotting. Model as background and RAOB 
 # as overlaid colored points
 ##########################################################
 pdf(file= figure1, width = 14, height = 7, pointsize=12)
  par(mai=c(1,1,0.5,0.5))
  par(tck=0.025)
  par(mgp=c(2.5,0.5,0))      
  plot.title<-paste("RAOB-Model Curtain Plot for Potential Temperature (K)"," at site ", raob$site, sep="")
  image(1:nt, rev(plot.plevs), t(model_theta),  col =cols.t,  axes = FALSE,
                 levels=plot.levs.t, ylim=rev(range(mod[,1,1])),
                 xlab=paste("Month/Day ",year.month.lab), ylab="Pressure (mb)")
  axis(2,col="black", at=mod[,1,1], labels=round(mod[,1,1]), cex=0.85)
  axis(1,col="black", at=1:nt, labels=datelab, cex=0.85)
  for(zz in 1:maxnlo){
    points(1:nt,obs[zz,1:nt,1], pch=19, cex=1.25, col=pcols.to[zz,])
    points(1:nt,obs[zz,1:nt,1], pch=21, cex=1.25, col="black")
  }
  legend(1,mod[maxnlm,1,1],plot.levs.t,cols.t, horiz =TRUE, bg="white")
  box()
  title(main=plot.title)
 dev.off()
 #########

 pdf(file= figure2, width = 14, height = 7, pointsize=12)
  par(mai=c(1,1,0.5,0.5))
  par(tck=0.025)
  par(mgp=c(2.5,0.5,0))      
  plot.title<-paste("RAOB-Model Curtain Plot for Relative Humidity (%)"," at site ", raob$site, sep="")
  image(1:nt, rev(plot.plevs), t(model_rh),  col =cols.rh,  axes = FALSE,
                 levels=plot.levs.rh, ylim=rev(range(mod[,1,1])),
                 xlab=paste("Month/Day ",year.month.lab), ylab="Pressure (mb)")
  axis(2,col="black", at=mod[,1,1], labels=round(mod[,1,1]), cex=0.85)
  axis(1,col="black", at=1:nt, labels=datelab, cex=0.85)
  for(zz in 1:maxnlo){
    points(1:nt,obs[zz,1:nt,1], pch=19, cex=1.25, col=pcols.rho[zz,])
    points(1:nt,obs[zz,1:nt,1], pch=21, cex=1.25, col="black")
  }
  legend(1,mod[maxnlm,1,1],plot.levs.rh,cols.rh, horiz =TRUE, bg="white")
  box()
  title(main=plot.title)
 dev.off()
 #########

 pdf(file= figure3, width = 14, height = 7, pointsize=12)
  par(mai=c(1,1,0.5,0.5))
  par(tck=0.025)
  par(mgp=c(2.5,0.5,0))      
  plot.title<-paste("Potential Temperature Difference (K) Model-RAOB"," at site ", raob$site, sep="")
  image(1:nt, rev(plot.plevs), t(model_theta*NA),  col =cols.t,  axes = FALSE,
                 levels=plot.levs.t, ylim=rev(range(mod[,1,1])),
                 xlab=paste("Month/Day ",year.month.lab), ylab="Pressure (mb)")
  axis(2,col="black", at=mod[,1,1], labels=round(mod[,1,1]), cex=0.85)
  axis(1,col="black", at=1:nt, labels=datelab, cex=0.85)
  for(zz in 1:maxnlo){
    dot.scaled <- 1+ abs(mod_theta_obs_diff[zz,])/max(mod_theta_obs_diff,na.rm=T)
    points(1:nt,obs[zz,1:nt,1], pch=19, cex=dot.scaled, col=pcols.to.diff[zz,])
    points(1:nt,obs[zz,1:nt,1], pch=21, cex=dot.scaled, col="black")
  }
  legend(1,mod[maxnlm,1,1],format(plot.levs.t.diff, digits = 1),cols.t.diff,horiz =TRUE, bg="white")
  box()
  title(main=plot.title)
 dev.off()
 #########

 pdf(file= figure4, width = 14, height = 7, pointsize=12)
  par(mai=c(1,1,0.5,0.5))
  par(tck=0.025)
  par(mgp=c(2.5,0.5,0))      
  plot.title<-paste("Relative Humidity Difference (%) Model-RAOB"," at site ", raob$site, sep="")
  image(1:nt, rev(plot.plevs), t(model_rh*NA),  col =cols.t,  axes = FALSE,
                 levels=plot.levs.rh, ylim=rev(range(mod[,1,1])),
                 xlab=paste("Month/Day ",year.month.lab), ylab="Pressure (mb)")
  axis(2,col="black", at=mod[,1,1], labels=round(mod[,1,1]), cex=0.85)
  axis(1,col="black", at=1:nt, labels=datelab, cex=0.85)
  for(zz in 1:maxnlo){
    dot.scaled <- 1+ abs(mod_rh_obs_diff[zz,])/max(mod_rh_obs_diff,na.rm=T)
    points(1:nt,obs[zz,1:nt,1], pch=19, cex=dot.scaled, col=pcols.rho.diff[zz,])
    points(1:nt,obs[zz,1:nt,1], pch=21, cex=dot.scaled, col="black")
  }
  legend(1,mod[maxnlm,1,1],format(plot.levs.rh.diff, digits = 1),cols.rh.diff,horiz =TRUE, bg="white")
  box()
  title(main=plot.title)
 dev.off()
 #########


 #############################################################

 }
###############################################################
#-------------------  END OF FUNCTION  ----------------------##
###############################################################





