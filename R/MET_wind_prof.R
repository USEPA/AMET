#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#		AMET (Atmospheric Model Evaluation Tool)                            #
#                                                                       #
#			Wind Profile Vector Plot                                          #
#		        MET_wind_prof.R                                             #
#                                                                       #
#                                                                       #
#	This "R" script extracts obs-model matched profile data from	        #						 			
#	the evaluation database (table id_profiler). The level-time	          #
#	data is organized by height and time, then wind components	          #
#	are used to plot wind vectors. The result is a time-height	          #
#	plot of observed wind vectors overlayed with model wind vector	      #
#                                                                       #
#	Version: 	1.2                                                         #
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
#          - Extensive cleaning of R script, R input and .csh files     #
#          - Note: maxWS set to mod-obs max can be tricky as bad obs    #
#            can make this very large and swamp the viewing of lighter  #
#            wind vectors. Below user can set to constant control val.  #
#-----------------------------------------------------------------------#
#                                                                       #
#########################################################################

  if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}
  if(!require(DBI)){   stop("Required Package DBI was not loaded")}
  if(!require(date)){  stop("Required Package date was not loaded")}

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
   mysql<-list(server=server,dbase=dbase,login=login,passwd=passwd,maxrec=maxrec)
 

#################################
#  Query Data and determine height and sigma levels

## loop over stations
for (sn in 1:length(statstr))
{
 datestr	<-paste(" AND ob_date BETWEEN ",dates$y,dform(dates$m),dform(dates$d),
                        " AND ",datee$y,dform(datee$m),dform(datee$d)," AND ob_time BETWEEN '",
			otime[1],"' AND '",otime[length(otime)],"'",sep="")
 query		<-paste("SELECT ",varxtrac," FROM ",table," WHERE ",statstr[sn],levstr,datestr," ORDER BY ob_date,ob_time")
 data		<-ametQuery(query,mysql)
 a<-dim(data)
 if(length(data) == 0){
	writeLines("*********************************************************************")
	writeLines("                                                                     ")
	writeLines(paste("NO DATA WAS FOUND FOR THIS DAY AT STATION: ",statid[sn]))
	writeLines("                                                                     ")
	writeLines("*********************************************************************")
 	#q(save="no")
  next
 }

 ma<-c("January","Febuary","March","April","May","June","July","August","September","October","November","December")
 nd=c(31,leapy(ys),31,30,31,30,31,31,30,31,30,31);
 enddate<-paste(ye,dform(me),dform(de),dform(he),sep="")

 taxis<-matrix(NA);
 Umod<-array(NA,c(200,120));
 Vmod<-array(NA,c(200,120));
 Uobs<-array(NA,c(200,120));
 Vobs<-array(NA,c(200,120));

 rloc<-1:length(data[,1])
 yx=ys;mx=ms;dx=ds;hx=hs;xx<-1
 xx<-1
    
while(xx > 0) {
 datestr<-paste(yx,dform(mx),dform(dx),dform(hx),sep="")
 sqldstr<-paste(yx,dform(mx),dform(dx),sep="")
 sqlhrstr<-paste(dform(hx),":00:00",sep="")
 taxis[xx]<-paste(dform(mx),dform(dx),dform(hx),sep="")
 dloc<-ifelse(data[,1] == sqldstr & data[,2] == sqlhrstr, rloc,NA)
 if(length(na.omit(dloc)) == 0){
  if(datestr == enddate) {nt<-xx;nz<-length(H);xx<--2}
		hx=hx+1
		if(hx > 23)     {	hx=hx-24;dx=dx+1	}
		if(dx > nd[mx])	{	dx<-dx-nd[mx];mx<-mx+1;	}
		if(mx > 12)	{	mx<-1;yx<-yx+1;		}
		xx<-xx+1
		next;
	}
	
 H<-round(na.omit(data[dloc,Hloc]))
 Umod[1:length(H),xx]<-rev( na.omit(data[dloc,Uloc]) )
 Uobs[1:length(H),xx]<-rev( na.omit(data[dloc,Uloc+1]) )
 Vmod[1:length(H),xx]<-rev( na.omit(data[dloc,Vloc]) )
 Vobs[1:length(H),xx]<-rev( na.omit(data[dloc,Vloc+1]) )
        
 #---------------------------------------------------##
 # Date calculations in case of a change of month or year 
 #---------------------------------------------------##
  if(datestr == enddate) {nt<-xx;nz<-length(H);xx<--2}
  hx=hx+1
  if(hx > 23)     {	hx=hx-24;dx=dx+1	}
  if(dx > nd[mx])	{	dx<-dx-nd[mx];mx<-mx+1;	}
  if(mx > 12)	{	mx<-1;yx<-yx+1;		}
	#---------------------------------------------------##

  xx<-xx+1
 }
  
# Condense Extra large arrays to suite the availiable data
  Umod<-ifelse(Umod[1:nz,1:nt] >200,NA,Umod[1:nz,1:nt])
  Vmod<-ifelse(Vmod[1:nz,1:nt] >200,NA,Vmod[1:nz,1:nt])
  Uobs<-ifelse(Uobs[1:nz,1:nt] >200,NA,Uobs[1:nz,1:nt])
  Vobs<-ifelse(Vobs[1:nz,1:nt] >200,NA,Vobs[1:nz,1:nt])
 
  # Define coordinate arrays
  tlab<-array(taxis)
  tnumb<-aperm(array(array(as.numeric(taxis)),c(nt,nz)))
  height<-array(H,c(nz,nt))
  
  WSobs<-sqrt(Uobs^2+Vobs^2)
  WSmod<-sqrt(Umod^2+Vmod^2)
  WSobs=ifelse(WSobs > 2*WSmod, NA, WSobs)
  WSmod=ifelse(WSobs > 2*WSmod, NA, WSmod)
  WDmod = 180+(360/(2*pi))*atan2(Umod,Vmod)
  WDobs = 180+(360/(2*pi))*atan2(Uobs,Vobs)
  WSdiff<-WSmod-WSobs
  maxWS<-max(max(WSobs,na.rm=T),max(WSmod,na.rm=T))
  #maxWS=15

########################################################################################
#	Plot Profile
 figure<-paste(figdir,"/",project,".wind_vector_profile.",sqldstr,".",statid[sn],sep="")
 if (plotopts$plotfmt == "pdf"){writeLines(paste(figure,".pdf",sep=""));pdf(file= paste(figure,".pdf",sep=""), width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){writeLines(paste(figure,".png",sep=""));bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, height = (541*plotopts$plotsize)/100, res=100)	}
 if (plotopts$plotfmt == "jpeg"){writeLines(paste(figure,".jpeg",sep=""));jpeg(file=paste(figure,".jpeg",sep=""), width = (700*plotopts$plotsize), height = (541*plotopts$plotsize), quality=100)	}
 
 m1<-0.90;m2<-0.90;m3<-0.25;m4<-0.1

 xlab<-paste("Time (UTC) on",ma[ms],dform(ds),",",ys)
 ylab<-"Height (m)"
 main<-paste("Observed-Simulated Wind Profile, Site:",statid[sn])
 xlim<-c(min(tnumb)-1,max(tnumb)+1)
 ylim<-c(0,max(height)+100)

 xscale<-  diff(xlim)/(8.5-m1-m3)
 yscale<-  ylim[2]/(11-m2-m4)
 xscale<-  1
 yscale<-  100
 x0<-tnumb
 y0<-height
 x1o<-x0+(Uobs/maxWS)*xscale
 y1o<-y0+(Vobs/maxWS)*yscale
 x1m<-x0+(Umod/maxWS)*xscale
 y1m<-y0+(Vmod/maxWS)*yscale

 par(mai=c(m1,m2,m3,m4))
 par(tck=.00)
 plot(tnumb,height,
 	pch=16,cex=0.25,col="black",xlim=xlim,ylim=ylim,
 	axes=TRUE,xaxt='n',xlab=xlab,ylab=ylab,main=main)

 # Plot X-labels and X-axis
 labs<-seq(0,23,by=3)
 locs<-tnumb[1,labs+1]
 par(mgp=c(2,0.5,0))
 par(tck=1)
 axis(1,at=locs,labels=paste(labs,"00",sep=""),col=gray(.75))

 locs<-c(0,rev(height[,1]))
 par(tck=1)
 axis(2,at=locs,labels=NA,col=gray(.75))
 arrows(x0, y0, x1o, y1o,length=0.05,col="black")
 arrows(x0, y0, x1m, y1m,length=0.05,col="red")

 xl<-max(tnumb)+0.04*(diff(range(tnumb)))
 yl<-max(height)+0.04*(diff(range(height)))
 legend(xl,yl,c("Observed","Simulated"),col=c("black","red"),lty=1,bg=gray(.9),bty=1,xjust=1,yjust=1)

 rect(xlim[1],ylim[2]-ylim[2]*0.05,xlim[1]+2,ylim[2],border=1,col="white")
 text(xlim[1]+1,ylim[2]-ylim[2]*0.040,paste(format(maxWS,digits=2),"m/s"),col="black", pos=3,cex=0.95)
 arrows(xlim[1]+0.5, ylim[2]-ylim[2]*0.035, xlim[1]+1.5, ylim[2]-ylim[2]*0.035, length = 0.05)
 dev.off()
 
} ## end stations loop
