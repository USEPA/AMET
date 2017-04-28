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
source("../configure/amet-config.R")
source("./cache/stat_id.input")
source("../R_analysis_code/AQ_Misc_Functions.R")
#:::::::::::::::::::::::::::::::::::::::::::::
  bounds<-c(latc-((8.5/11)*zoom),latc+((8.5/11)*zoom),lonc-zoom,lonc+zoom)
  args <- commandArgs(TRUE)
  dbase <- args[1]
#  print(args)
#  dbase <- "cmaq_v47"
  print(dbase)
  mysql <- list(login=root_login, passwd=root_pass, server=mysql_server, dbase=dbase, maxrec=1000000)             # Set MYSQL login and query options
  query<-paste("SELECT  stat_id,stat_name,network,lat,lon,elevation,state from site_metadata where lat BETWEEN",bounds[1],"and",bounds[2],"and lon BETWEEN ",bounds[3],"and",bounds[4],"ORDER BY stat_id")
#  mysql$maxrec<-5000
#:::::::::::::::::::::::::::::::::::::::::::::
#  Query the data base for all stations
     sdata<-db_Query(query,mysql)
#:::::::::::::::::::::::::::::::::::::::::::::
  gridloc<-list(x=sdata[,5],y=sdata[,4])
  
  # Color scale for various observation networks
  aircol<-"orange";airsiz<-1.00
  impcol<-"red";impsiz<-1.00
  stncol<-"dark green";stnsiz<-0.75
  castcol<-"blue";castsiz<-1.10
  nadpcol<-"purple";nadpsiz<-1.25
  searchcol<-"yellow";searchsiz<-1.25
  aeronetcol<-"brown";aeronetsiz<-1.25
  amoncol<-"light green";amonsiz<-1.25
  toxcol<-"magenta";toxsiz<-0.75
  othercol <-"black";othersiz<-0.75

  scols<-array(othercol,c(length(sdata[,1])))
  scols<-ifelse(sdata[,3] == "AQS" , aircol, scols)
  scols<-ifelse(sdata[,3] == "improve" , impcol, scols)
  scols<-ifelse(sdata[,3] == "csn" , csncol, scols)
  scols<-ifelse(sdata[,3] == "castnet", castcol, scols)
  scols<-ifelse(sdata[,3] == "nadp"  , nadpcol, scols)
  scols<-ifelse(sdata[,3] == "search"  , searchcol, scols)
  scols<-ifelse(sdata[,3] == "AERONET"  , aeronetcol, scols)
  scols<-ifelse(sdata[,3] == "amon"  , amoncol, scols)
  scols<-ifelse(sdata[,3] == "toxics"  , toxcol, scols)

  scex<-array(othersiz,c(length(sdata[,1])))
  scex<-ifelse(sdata[,3] == "AQS" , airsiz, scex)
  scex<-ifelse(sdata[,3] == "improve" , impsiz, scex)
  scex<-ifelse(sdata[,3] == "csn" , csnsiz, scex)
  scex<-ifelse(sdata[,3] == "castnet" , castsiz, scex)
  scex<-ifelse(sdata[,3] == "nadp" , nadpsiz, scex)
  scex<-ifelse(sdata[,3] == "search" , searchsiz, scex)
  scex<-ifelse(sdata[,3] == "AERONET" , aeronetsiz, scex)
  scex<-ifelse(sdata[,3] == "amon" , amonsiz, scex)
  scex<-ifelse(sdata[,3] == "toxics" , toxsiz, scex)

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
   legend(bounds[4],bounds[1],c("AIRS/CSN","IMPROVE","CSN Only","CASTNET","NADP","SEARCH","AERONET","AMON","TOXICS"),col=c(aircol,impcol,stncol,castcol,nadpcol,searchcol,aeronetcol,amoncol,toxcol),fill=TRUE,pch=spch,xjust=1,yjust=0,bty="n",y.intersp=.7,cex=.85)
# Draw Title
#   title(main=paste(varlab))
# AMET Product label
   text(bounds[3],bounds[1]+0.03*(bounds[2]-bounds[1]),"AMET Product",adj=c(0,1))
   spar<-par()
   pbounds<-spar$usr
   dev.off()
   
   write(pbounds,file="./cache/scoords.dat")


