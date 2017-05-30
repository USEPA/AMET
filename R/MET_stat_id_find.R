#########################################################################
#-----------------------------------------------------------------------#
#						 			#
#		AMET (Automated Model Evaluation Tool)			#
#						 			#
#			WEB-BASED Surface Station Chooser		#
#			       stat_id_find.R			 	#
#						 			#
#  This R script is used by various AMET web-based tools to choose	#
#  or find a surface obs station to perform statitics on. The web 	#
#  interface is interactive and passes lat-lon information to this      #
#  R script via the stat_id.input file. The needed information is	#
#  center lat-lon of point-click, zoom factor.				#

#  A plot is then generated with locations of all availiable surface
#  station. The user can then explicity choose a station or group
#  of stations

#	Version: 	1.1					 	#
#	Date:		June 20, 2004					#
#	Contributors:	Robert Gilliam					#
#						 			#
#	Developed by and for NOAA, ARL, ASMD on assignment to US EPA	#
#-----------------------------------------------------------------------#
#########################################################################
#:::::::::::::::::::::::::::::::::::::::::::::
#	Load required modules
  require("RMySQL")
  require("DBI")
  require("maps")
#:::::::::::::::::::::::::::::::::::::::::::::
#	Load AMET R configuration
source("./wwwR/amet_config.R")
source("./cache/stat_id.input")
source("./wwwR/amet.misc-lib.R")
#:::::::::::::::::::::::::::::::::::::::::::::
  bounds<-c(latc-((8.5/11)*zoom),latc+((8.5/11)*zoom),lonc-zoom,lonc+zoom)
  query<-paste("SELECT  stat_id,ob_network,lat,lon,elev,landuse,common_name,state,country from  stations where lat BETWEEN",bounds[1],"and",bounds[2],"and lon BETWEEN ",bounds[3],"and",bounds[4],"ORDER BY stat_id")
  mysql$maxrec<-5000
#:::::::::::::::::::::::::::::::::::::::::::::
#  Query the data base for all stations
     sdata<-ametQuery(query,mysql)
#:::::::::::::::::::::::::::::::::::::::::::::
  gridloc<-list(x=sdata[,4],y=sdata[,3])

  # Color scale for various observation networks
  nwscol<-"red";nwssiz<-1.00;
  castcol<-"green";castsiz<-1.25
  maritimecol<-"blue";maritimesiz<-1.10
  othercol<-"orange";othersiz<-0.75

  scols<-array(othercol,c(length(sdata[,1])))
  scols<-ifelse(sdata[,2] == "ASOS" | sdata[,2] == "SAO" | sdata[,2] == "OTHER-MTR", nwscol, scols)
  scols<-ifelse(sdata[,2] == "MARITIME" | sdata[,2] == "GoMOOS", maritimecol, scols)
  scols<-ifelse(sdata[,2] == "CASTNET",  castcol, scols)

  scex<-array(othersiz,c(length(sdata[,1])))
  scex<-ifelse(sdata[,2] == "ASOS" | sdata[,2] == "SAO" | sdata[,2] == "OTHER-MTR", nwssiz, scex)
  scex<-ifelse(sdata[,2] == "MARITIME" | sdata[,2] == "GoMOOS", maritimesiz, scex)
  scex<-ifelse(sdata[,2] == "CASTNET", castsiz, scex)

  spch<-19 # Circle
  ix<-700
  iy<-541
  pres=100
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#	DRAW Map and Plot Station locations
#   png(file="./cache/statmap.png", width = ix, height = iy)
   bitmap (paste("./cache/statmap.",fignum,".png",sep=""), width=ix/pres, height=iy/pres, res=pres, pointsize=12) 
   par(mai=c(0,0,0,0))
   map("state",xlim=c(bounds[3],bounds[4]),ylim=c(bounds[1],bounds[2]),resolution=0, boundary = TRUE, lty = 1)
   par(mai=c(0,0,0,0))
   points(gridloc,pch=spch,cex=scex,col=scols)
   par(mai=c(0,0,0,0))
   map("state",xlim=c(bounds[3],bounds[4]),ylim=c(bounds[1],bounds[2]),resolution=0, boundary = TRUE, lty = 1,add=TRUE)
# Draw legend
   legend(bounds[4],bounds[1],c("Mesonet","NWS/FAA","CASTNET","MARITIME"),col=c(othercol,nwscol,castcol,maritimecol),
          fill=TRUE,pch=spch,xjust=1,yjust=0, y.intersp=.7, cex=.85, pt.cex=1, bty=T, bg="white")
# Draw Title
#   title(main=paste(varlab))
# AMET Product label
   text(bounds[3],bounds[1]+0.03*(bounds[2]-bounds[1]),"NOAA/EPA, AMET Product",adj=c(0,1))
   spar<-par()
   pbounds<-spar$usr
   dev.off()
   
   write(pbounds,file="./cache/scoords.dat")


