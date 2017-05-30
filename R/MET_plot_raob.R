#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#		AMET (Atmospheric Model Evaluation Tool)                            #
#                                                                       #
#			Raob Profile Comparison Plot                                      #
#		        MET_plot_raob.R                                             #
#                                                                       #
#                                                                       #
#	This "R" script extracts obs-model matched raob data from             #
#	the evaluation database (table id_profiler). The level-time           #
#	data is organized by height and time, then potential temp,            #
#	relative humidity and wind is plotted. If date range is specified     #
#	the profiles plotted are average profiles over that time period.      #
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
# Updates: - Pulled some configurable options out of MET_plot_raob.R    #
#            and placed into the plot_raob.input file                   #
#          - Minor plot updates for png and pdf's                       #
#          - Extensive cleaning of R script, R input and .csh files     #
#-----------------------------------------------------------------------#
#                                                                       #
#########################################################################
#	Load required modules
  if(!require(RMySQL)) {stop("Required Package RMySQL was not loaded")}
  if(!require(date))   {stop("Required Package date was not loaded")  }
  if(!require(maps))   {stop("Required Package maps was not loaded")  }
  if(!require(mapdata)){stop("Required Package mapdata was not loaded")  }
  if(!require(akima))  {stop("Required Package akima was not loaded")  }
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

 dates<-list(y=ys,m=ms,d=ds,h=hs)
 datee<-list(y=ye,m=me,d=de,h=he)

 ## mysql connection configuration
 mysql		<-list(server=server,dbase=dbase,login=login,passwd=passwd,maxrec=maxrec)

#################################
 textfile	<-paste("raob_stats.",project,".txt",sep="")
 textfile     <-paste(figdir,textfile,sep="/")
 if(term == "web") {
   textfile	<-paste("cache/raob_stats.",project,".txt",sep="") 
 }
 system(paste("rm -f ",textfile))

# Layer Mode Plotting
if(player){
 
 # Construct MySQL Query given all criteria from raob.input
 datestr	<-paste(" AND ob_date BETWEEN ",dates$y,dform(dates$m),dform(dates$d),
                        " AND ",datee$y,dform(datee$m),dform(datee$d)," AND ob_time BETWEEN '",
			otime[1],"' AND '",otime[2],"'",sep="")
 query1		<-paste("SELECT ",varxtrac1," FROM ",table," WHERE ",varcri1,mainstr1,datestr,fcasthrstr)
 query2		<-paste("SELECT ",varxtrac1," FROM ",table," WHERE ",varcri2,mainstr1,datestr,fcasthrstr)
 
 # Query Database for T and RH (query1) and U and V wind (query2)
 writeLines("Database queries for RAOB layer average data")
 data1		<-ametQuery(query1,mysql)
 data2		<-ametQuery(query2,mysql)
 writeLines("--------------------------------------------------------------------------------")
 #---------------------------------------------------------------------------------
 # Check to see if data was extracted from database, if not (e.g., length of data frame is 0) then abort and provide use a message)
 if(length(data1) == 0 | length(data2) == 0){
	writeLines("*********************************************************************")
	writeLines("                                                                     ")
	writeLines(paste("NO DATA WAS FOUND FOR THIS DAY"))
	writeLines("                                                                     ")
	writeLines("*********************************************************************")
 	q(save="no")
 }
 #---------------------------------------------------------------------------------

 # Find unique station id's from T and RH data and U and V data
 raobid1<-unique(data1[,1])
 raobid2<-unique(data2[,1])
 raobid<-unique(c(raobid1,raobid2))

 # Loop through each station and caculate bias of T, RH and Wind Speed, as well as caculate the mean obs and modeled wind vectors over the specified layer
 nstat<-length(raobid)
 bias		<-array(NA,c(nstat,3))
 meanowind	<-array(NA,c(nstat,2))
 meanmwind	<-array(NA,c(nstat,2))
 lat		<-array(NA,c(nstat))
 lon		<-array(NA,c(nstat))

 for(s in 1:nstat) {
	sindex1		<-raobid[s] == data1[,1]
	sindex2		<-raobid[s] == data2[,1]
	bias[s,1]	<-mean(data1[sindex1,5],na.rm=T)-mean(data1[sindex1,4],na.rm=T)
	bias[s,2]	<-mean(data1[sindex1,7],na.rm=T)-mean(data1[sindex1,6],na.rm=T)
	meanowind[s,1]	<-mean(data2[sindex2,4],na.rm=T)
	meanowind[s,2]	<-mean(data2[sindex2,6],na.rm=T)
	meanmwind[s,1]	<-mean(data2[sindex2,5],na.rm=T)
	meanmwind[s,2]	<-mean(data2[sindex2,7],na.rm=T)
	bias[s,3]	<-sqrt(  meanmwind[s,1]**2 + meanmwind[s,2]**2 ) - sqrt(  meanowind[s,1]**2 + meanowind[s,2]**2 )
	
	lat[s]		<-mean(data2[sindex2,2],na.rm=T)
	lon[s]		<-mean(data2[sindex2,3],na.rm=T)
 }
  if(textstats) {
    write.table(data.frame(bias,row.names=raobid),textfile,sep=",",
                col.names=c("Potential Temperature BIAS (K)","Relative Humidity  BIAS (%)","Wind Speed BIAS (m/s)") )
  }
########################################################################################
#	Plot Profile
  res=100
  figure<-paste(figdir,"/raob_layer_stats.",project,sep="")

  if (plotopts$plotfmt == "bmp") {bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, height = (350*plotopts$plotsize)/100, res=100,pointsize=10*plotopts$plotsize)	}
  if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(figure,".jpeg",sep=""), width = (700*plotopts$plotsize), height = (350*plotopts$plotsize), quality=100)	} 
  if (plotopts$plotfmt == "png"){ png(file=paste(figure,".png",sep=""), width = 1100, height = 1100*8.5/11 )      }
  if (plotopts$plotfmt == "pdf"){pdf(file= paste(figure,".pdf",sep=""), width = 11, height = 8.5)	}

  writeLines("RAOB profile plot:")
  writeLines(paste(figure,".",plotopts$plotfmt,sep="")); 

########################################################################################
  #	Prepare Plotting Parameters
  lonw<-min(lon,na.rm=T)-1
  lone<-max(lon,na.rm=T)+1
  lats<-min(lat,na.rm=T)-1
  latn<-max(lat,na.rm=T)+1
  
  
  ccolsT	<-colpT[cut(bias[,1],br=levsT,labels=FALSE,include.lowest=T)]
  ccolsRH	<-colpRH[cut(bias[,2],br=levsRH,labels=FALSE,include.lowest=T)]
  ccolsWS	<-colpWS[cut(bias[,3],br=levsWS,labels=FALSE,include.lowest=T)]

  # Wind Vectors
  wsm<-sqrt(  meanmwind[,1]**2 + meanmwind[,2]**2 )
  wso<-sqrt(  meanowind[,1]**2 + meanowind[,2]**2 )
  qam<-ifelse(abs(wsm)>100,NA,1)
  qao<-ifelse(abs(wso)>100,NA,1*qam)
  ws<-c(sqrt(  meanmwind[,1]**2 + meanmwind[,2]**2 ),sqrt(  meanowind[,1]**2 + meanowind[,2]**2 ))
  ws<-ifelse(abs(ws)>100,NA,ws)
  maxws<-max(ws,na.rm=T)
  dlon<-6
  x0m<-lon;x0o<-lon; 
  y0m<-lat;y0o<-lat; 
  x1o<-x0o+(meanowind[,1]/maxws)*dlon*qao
  y1o<-y0o+(meanowind[,2]/maxws)*dlon*qao
  x1m<-x0m+(meanmwind[,1]/maxws)*dlon*qao
  y1m<-y0m+(meanmwind[,2]/maxws)*dlon*qao
  
  par(mfrow=c(2,2))
  par(mai=c(0,0,0,0))
  #------------------------------------------------------------------------------------------------------------
  #  Plot Spatial Temperature Bias
  title<-"Mean Potential Temperature Bias (K)"
  m<-map('usa',plot=FALSE)
  map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
  map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65), add=T)
  points(lon,lat,pch=plotopts$symb, cex=plotopts$symbsiz, col=ccolsT)
  points(lon,lat,pch=plotopts$symbo, cex=plotopts$symbsiz, col="black")
  legend(lone,lats,format(levsT,digit=2),col=colpT,fill=F,pch=plotopts$symb,
        xjust=1,yjust=0,bg='white',y.intersp=1,pt.cex=2,pt.bg="white")
  title(title,sub=infolab,line=0, cex.sub=0.9)
  box(which="figure")
  writeLines(" ------------------- ********************* -------------------------- ********************")
  #------------------------------------------------------------------------------------------------------------
  #  Plot Spatial RH Bias
  title<-"Mean Relative Humidity Bias (%)"
  m<-map('usa',plot=FALSE)
  map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
  map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65), add=T)
  points(lon,lat,pch=plotopts$symb, cex=plotopts$symbsiz, col=ccolsRH)
  points(lon,lat,pch=plotopts$symbo, cex=plotopts$symbsiz, col="black")
  legend(lone,lats,format(levsRH,digit=2),col=colpRH,fill=F,pch=plotopts$symb,
        xjust=1,yjust=0,bg='white',y.intersp=1,pt.cex=2,pt.bg="white")
  title(title,sub=infolab,line=0, cex.sub=0.9)
  box(which="figure")
  #------------------------------------------------------------------------------------------------------------
  #  Plot Spatial Wind Speed Bias
  title<-"Mean Wind Speed Bias (m/s)"
  m<-map('usa',plot=FALSE)
  map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
  map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65), add=T)
  points(lon,lat,pch=plotopts$symb, cex=plotopts$symbsiz, col=ccolsWS)
  points(lon,lat,pch=plotopts$symbo, cex=plotopts$symbsiz, col="black")
  legend(lone,lats,format(levsWS,digit=2),col=colpWS,fill=F,pch=plotopts$symb,
        xjust=1,yjust=0,bg='white',y.intersp=1,pt.cex=2,pt.bg="white")
  title(title,sub=infolab,line=0, cex.sub=0.9)
  box(which="figure")
  #------------------------------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------------------------------
  #  Plot Mean Wind Vectors
  title<-"Mean Wind Vectors"
  m<-map('usa',plot=FALSE)
  map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65))
  map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, col=gray(0.65), add=T)
  arrows(x0m, y0m, x1m, y1m,length=0.05,col="blue")
  arrows(x0o, y0o, x1o, y1o,length=0.05,col="red")
  title(title,sub=infolab,line=0, cex.sub=0.9)
  legend(lone,lats,c("Observed Wind","Model Wind"),col=c("red","blue"),fill=F,pch=plotopts$symb,
        xjust=1,yjust=0,bg='white',y.intersp=1,pt.cex=2,pt.bg="white")
  box(which="figure")
  #------------------------------------------------------------------------------------------------------------
  dev.off()


}	# END OF PLAYER MODE


# Profile Comparison Mode Plotting
if(prof){

 # Construct MySQL Query given all criteria from raob.input
 datestr	<-paste(" AND ob_date BETWEEN ",dates$y,dform(dates$m),dform(dates$d),
                        " AND ",datee$y,dform(datee$m),dform(datee$d)," AND ob_time BETWEEN '",
			otime[1],"' AND '",otime[2],"'",sep="")
 query1		<-paste("SELECT ",varxtrac2," FROM ",table," WHERE ",varcri1,mainstr2,datestr,fcasthrstr)
 query2		<-paste("SELECT ",varxtrac2," FROM ",table," WHERE ",varcri2,mainstr2,datestr,fcasthrstr)
 
 # Query Database for T and RH (query1) and U and V wind (query2)
 writeLines("Database queries for RAOB profile data")
 data1		<-ametQuery(query1,mysql)
 data2		<-ametQuery(query2,mysql)
 writeLines("--------------------------------------------------------------------------------")
 
 #---------------------------------------------------------------------------------
 # Check to see if data was extracted from database, if not (e.g., length of data frame is 0) then abort and provide use a message)
 if(length(data1) == 0 | length(data2) == 0){
	writeLines("*********************************************************************")
	writeLines("                                                                     ")
	writeLines(paste("NO DATA WAS FOUND FOR THIS DAY"))
	writeLines("                                                                     ")
	writeLines("*********************************************************************")
 	q(save="no")
 }
 #---------------------------------------------------------------------------------

  levels<-sort(unique(c(data1[,3],data2[,3])),decreasing = T)
  
  
  nlevs<-length(levels[1:(length(levels)-1)])
  obs<-array(NA,c(nlevs,5))		# Model-Obs arrays  col1=temp, col2=RH, col3=WS, col4=U, col5=V
  mod<-array(NA,c(nlevs,5))
  height<-array(NA,c(nlevs))

 for(l in 1:nlevs) {
	sindex1		<-levels[l] == (data1[,3])
	sindex2		<-levels[l] == (data2[,3])

	height[l]	<-mean(data1[sindex1,2],na.rm=T)
	obs[l,1]	<-mean(data1[sindex1,4],na.rm=T)
	mod[l,1]	<-mean(data1[sindex1,5],na.rm=T)
	obs[l,2]	<-mean(data1[sindex1,6],na.rm=T)
	mod[l,2]	<-mean(data1[sindex1,7],na.rm=T)

	obs[l,4]	<-mean(data2[sindex2,4],na.rm=T)
	obs[l,5]	<-mean(data2[sindex2,6],na.rm=T)
	mod[l,4]	<-mean(data2[sindex2,5],na.rm=T)
	mod[l,5]	<-mean(data2[sindex2,7],na.rm=T)

	obs[l,3]	<-sqrt( obs[l,4]**2 + obs[l,5]**2 )
	mod[l,3]	<-sqrt( mod[l,4]**2 + mod[l,5]**2 )

 }
 levels<-height
 if(textstats) {
    write.table(data.frame(obs[,1:3],mod[,1:3],row.names=levels),textfile,sep=",",append=T,
                col.names=c("Obs. Potential Temperature (K)","Obs. Relative Humidity (%)",
                "Obs. Wind Speed  (m/s)","Mod. Potential Temperature (K)","Mod. Relative Humidity (%)",
                "Mod. Wind Speed (m/s)") )
  }
########################################################################################
#	Plot Profile
  res=100
  figure<-paste(figdir,"/raob_prof_comp.",project,".",statid,sep="")
  if (plotopts$plotfmt == "pdf"){pdf(file= paste(figure,".pdf",sep=""), width = 11, height = 8.5)	}
  if (plotopts$plotfmt == "png"){bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/res, height = (541*plotopts$plotsize)/res, res=res)	}
  if (plotopts$plotfmt == "jpeg"){jpeg(file=paste(figure,".jpeg",sep=""), width = (700*plotopts$plotsize), height = (541*plotopts$plotsize), quality=100)	}
  
  writeLines("RAOB profile plot:")
  writeLines(paste(figure,".",plotopts$plotfmt,sep="")); 

#---------------------------------------------------------------------------------------------------------------------

  #---------------------------------------------
  #	Prepare Plotting Parameters
  maxli<-sum(ifelse(levels < proflim[2],1,0),na.rm=T)
  Tlims<-round(range(obs[1:maxli,1],mod[1:maxli,1],na.rm=T))
  RHlims<-c(0,100)
  WSlims<-round(range(obs[1:maxli,3],mod[1:maxli,3],na.rm=T))
  
  # Adjust Pot. Temp for Interpolations errors that lead to a decrease with height   
  nz<-length(levels)
  for(z in 2:nz){
    zl<-(nz+1)-z
    zu<-zl+1
    if(obs[zu,1] < obs[zl,1])  {   obs[zl,1]<-obs[zu,1]		}
    if(mod[zu,1] < mod[zl,1])  {   mod[zl,1]<-mod[zu,1]		}    
  } 
  
  # Wind Vectors
  veclength<-1/3
  WSlims<-round(range(obs[1:maxli,3],mod[1:maxli,3],na.rm=T))
  wsm<-sqrt(  obs[,4]**2 + obs[,5]**2 )
  wso<-sqrt(  mod[,4]**2 + mod[,5]**2 )
  qam<-ifelse(abs(wsm)>100,NA,1)
  qao<-ifelse(abs(wso)>100,NA,1*qam*veclength)
  ws<-c(sqrt(  obs[,4]**2 + obs[,5]**2 ),sqrt(  mod[,4]**2 + mod[,5]**2 ))
  ws<-ifelse(abs(ws)>100,NA,ws)
  maxws<-max(wsm,wso,na.rm=T)
  dlon<-6
  
  yscale<-diff(proflim)/diff(WSlims)
  xscale<-1

  x0m<-(diff(WSlims)/3)+WSlims[1];x0o<-(diff(WSlims)*2/3)+WSlims[1]; 
  y0m<-levels;y0o<-levels;
  qao<-qao/5 
  x1o<-x0o+(obs[,4])*xscale*qao
  y1o<-y0o+(obs[,5])*yscale*qao
  x1m<-x0m+(mod[,4])*xscale*qao
  y1m<-y0m+(mod[,5])*yscale*qao


  par(mfrow=c(1,4))
  par(bg="lightblue1")
  par(fg="black")
  #------------------------------------------------------------------------------------------------------------
  #  Plot Spatial Temperature Bias
  pobs<-obs[,1]
  pmod<-mod[,1]
  par(mai=c(0.35,0.35,0.1,0))
  par(mgp=c(2,0.7,0))
  pobs<-obs[,1]
  pmod<-mod[,1]
  par(tck=0.05)
  plot(pobs,levels,xlim=Tlims,ylim=proflim, axes=T,
       ylab=paste(layerlab,"(",layerunit,")"), xlab="Potential Temperature (K)",
       type='o',pch=19, col="red")
  par(tck=1)
  axis(2,col=gray(.9),at=levels,labels=F)

  par(new=T)
  plot(pmod,levels,xlim=Tlims,ylim=proflim, axes=F,
       ylab="", xlab="",
       type='o',pch=19,col="blue")
   lines(Tlims,c(0,0),col="black",lwd=2)
   rect(Tlims[1]-10,-1000,Tlims[2]+10,0,col="darkgreen",density=200)
   
   text(Tlims[1],proflim[2],infolabProf1,pos=4,cex=1.55)
   text(Tlims[1],proflim[2]-(150*proflim[2]/5000),infolabProf2,pos=4,cex=1.35)
   text(Tlims[1],proflim[2]-(300*proflim[2]/5000),infolabProf3,pos=4,cex=1.35)
  legend(Tlims[1],proflim[2]-(400*proflim[2]/5000),c("Observation","Model"),col=c("red","blue"),lty=1,lwd=2,cex=1.5)
   
   box()
  #------------------------------------------------------------------------------------------------------------
  #  Plot Spatial Relative Humidity Bias
  pobs<-obs[,2]
  pmod<-mod[,2]
  par(mai=c(0.35,0.0,0.1,0))
  par(mgp=c(2,0.7,0))
  par(tck=0.05)
  plot(pobs,levels,xlim=RHlims,ylim=proflim, axes=F,
       ylab="", xlab="Relative Humidity (%)",
       type='o',pch=19,col="red")
  par(tck=1)
  axis(2,col=gray(.9),at=levels,labels=F)
  par(tck=0.05)
  axis(1,at=seq(0,100,20),label=c("",seq(20,80,20),"") )
  par(new=T)
  plot(pmod,levels,xlim=RHlims,ylim=proflim, axes=F,
       ylab="", xlab="",
       type='o',pch=19,col="blue")
   lines(RHlims,c(0,0),col="black",lwd=2)
   rect(RHlims[1]-10,-1000,RHlims[2]+10,0,col="darkgreen",density=200)
   box()
  #------------------------------------------------------------------------------------------------------------
  #  Plot Profile Wind Speed 
  #------------------------------------------------------------------------------------------------------------
  pobs<-obs[,3]
  pmod<-mod[,3]
  par(mai=c(0.35,0.0,0.1,0))
  par(mgp=c(2,0.7,0))
  par(tck=0.05)
  plot(pobs,levels,xlim=WSlims,ylim=proflim, axes=F,
       ylab="", xlab="Wind Speed (m/s) Profile",
       type='o',pch=19,col="red")
  par(tck=1)
  axis(2,col=gray(.9),at=levels,labels=F)
  par(tck=0.05)
  axis(1 )
  par(new=T)
  plot(pmod,levels,xlim=WSlims,ylim=proflim, axes=F,
       ylab="", xlab="",
       type='o',pch=19,col="blue")
   lines(WSlims,c(0,0),col="black",lwd=2)
   rect(WSlims[1]-10,-1000,WSlims[2]+10,0,col="darkgreen",density=200)
   box()
  #------------------------------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------------------------------
  #  Plot Profile Wind vectors
  #------------------------------------------------------------------------------------------------------------
  pobs<-obs[,3]
  pmod<-mod[,3]
  par(mai=c(0.35,0.0,0.1,0.1))
  par(mgp=c(2,0.7,0))
  par(tck=0.05)
  plot(pobs,levels,xlim=WSlims,ylim=proflim, axes=F,
       ylab="", xlab="Wind Vector Profile",
       type='o',pch=19,col=NA)
  par(tck=1)
  axis(2,col=gray(.9),at=levels,labels=F)
  par(new=T)
  plot(pmod,levels,xlim=WSlims,ylim=proflim, axes=F,
       ylab="", xlab="",
       type='o',pch=19,col=NA)
  arrows(x0m, y0m, x1m, y1m,length=0.05,col="blue")
  arrows(x0o, y0o, x1o, y1o,length=0.05,col="red")
   lines(WSlims,c(0,0),col="black",lwd=2)
   rect(WSlims[1]-10,-1000,WSlims[2]+10,0,col="darkgreen",density=200)
   box()
  #------------------------------------------------------------------------------------------------------------
  dev.off()
  writeLines(paste("Text file of profiles and layer statistics: ",textfile))
}	# END OF PROFILER MODE

