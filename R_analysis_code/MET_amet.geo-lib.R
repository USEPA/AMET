#######################################################################################################
#######################################################################################################
#		AMET Geographic Function Library
#						 		
#	Version: 	1.1
#	Date:		August 18, 2005
#	Contributors:	Robert Gilliam
#	
#	Developed by the US Environmental Protection Agency 	
#
# Version 1.2, Robert Gilliam, May 2, 2013
# Updates: Code formatting only, no functionality changes!
#
#
#-----------------------------------------------------------------------###############################
#######################################################################################################
#######################################################################################################
#	This collection contains the following functions
#
#	getgrib		--> 	Simple format function, formats numbers from one to two digit 
#
#	latlon2ijStereo -->	Caculates the i,j location for a particular lat-lon  location on a Lambert grid
#
#	ij2latlonStereo -->	Caculates the lat-lon of a particular grid point on polar stereographic projection
#
#	latlon2ijLAMBERT -->	Caculates the i,j location for a particular lat-lon location on a Lambert grid
#
#	cone -->		Calcuates the cone factor
#
#######################################################################################################
###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
### Extracts variable from Grib file and puts in R array
#
# Input: Grib file (gfile), variable (var), wgrib full path, prefix of npa precip files
#	  npa grib file directory and maxprecip
#
#
# Output: Precipitation array with projection information
#
#
# Options:
#
#
#
#
# NOTE:
#
###
 	getgrib<-function(date,gribdir,var="'APCP'",wgrib="/usr/local/bin/wgrib",
 				gunzip="/usr/gunzip", gzip="/usr/gzip", gzext="gz",
 				npaprefix="multi15",compressed=F,dothour=T)
 {
 
 hourform<-dform(date$h)
 if(dothour) {	hourform<-paste(".",dform(date$h),sep="")	}
 
 if(!compressed) {
   gfile<-paste(gribdir,"/",npaprefix,".",date$y,dform(date$m),dform(date$d),hourform,sep="")
   #writeLines(gfile)
   if(!file.exists(gfile)){	return()	};
 }
 if(compressed) {
   gfile<-paste(gribdir,"/",npaprefix,".",date$y,dform(date$m),dform(date$d),hourform,".",gzext,sep="")
   if(!file.exists(gfile)){	return()	};
   #writeLines(paste(gunzip,gfile),con = stdout())
   system(paste(gunzip,gfile))
   gfile<-paste(gribdir,"/",npaprefix,".",date$y,dform(date$m),dform(date$d),hourform,sep="")
 }
 vdate<-paste(date$y,date$m,date$d,date$h,sep="")
 
 if(file.exists("test.asc")){system("rm test.asc")}
 if(file.exists(gfile)){
    writeLines(paste("NPA grib file",gfile),con=stdout())
    system(paste(wgrib," -s ",gfile," | grep '",var,"' | ",wgrib," -i -s -text -h -o test.asc ",gfile,sep=""),intern=TRUE)
    data<-matrix(scan("test.asc",0),ncol=1,byrow=TRUE)
    values<-data[3:length(data)]
    nx<-data[1]; ny<-data[2]
    valarray<-array(NA,c(ny,nx))
    cs<-1; c<-nx
    for(yy in 1:ny){
        valarray[yy,]<-values[cs:c]
        cs<-c+1
        c<-c+nx
    }

    proj<-system(paste(wgrib,"  -V -d 1 ",gfile,sep=""),intern=TRUE)
    wrd5<-unlist(strsplit(proj[5]," "))
    lat1<-as.numeric(wrd5[6])
    lon1<-as.numeric(wrd5[8])
    lonc<-as.numeric(wrd5[10])
    wrd6<-unlist(strsplit(proj[6]," "))
    dx<-as.numeric(wrd6[12])
    dy<-as.numeric(wrd6[14])
    wrd7<-unlist(strsplit(proj[7]," "))
    minp<-as.numeric(wrd7[5])
    maxp<-as.numeric(wrd7[6])

    valarray<-ifelse(valarray > maxp | valarray < minp,NA,valarray)
    units="%"

    if(compressed) {
        system(paste(gzip,gfile))
    }

    return(valarray,nx,ny,lat1,lon1,lonc,dx,dy,vdate,units,minp,maxp)
 }
 return(0)

 }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
### Calculates the i,j grid point of a given lat-lon value on a polar stereographic projection
#
# Input: Latitude and longitude
#
#
#
# Output: Corresponding i,j grid point
#
#ALAT1<-22.813
#ALON1<- -120.351
#DX<-14287.5
#
# NOTE:
#   
###
 	latlon2ijStereo<-function(ALAT,ALON,ALAT1=22.813,ALON1=-120.351,DX=14287.5,ALONV=-105)
 {
#$$$   SUBPROGRAM  DOCUMENTATION  BLOCK
#
# SUBPROGRAM:  W3FB06        LAT/LON TO POLA (I,J) FOR GRIB
#   PRGMMR: STACKPOLE        ORG: NMC42       DATE:88-04-05
#
# ABSTRACT: CONVERTS THE COORDINATES OF A LOCATION ON EARTH GIVEN IN
#   THE NATURAL COORDINATE SYSTEM OF LATITUDE/LONGITUDE TO A GRID
#   COORDINATE SYSTEM OVERLAID ON A POLAR STEREOGRAPHIC MAP PRO-
#   JECTION TRUE AT 60 DEGREES N OR S LATITUDE. W3FB06 IS THE REVERSE
#   OF W3FB07. USES GRIB SPECIFICATION OF THE LOCATION OF THE GRID
#
# PROGRAM HISTORY LOG:
#   88-01-01  ORIGINAL AUTHOR:  STACKPOLE, W/NMC42
#   90-04-12  R.E.JONES   CONVERT TO CRAY CFT77 FORTRAN
#
# USAGE:  CALL W3FB06 (ALAT,ALON,ALAT1,ALON1,DX,ALONV,XI,XJ)
#   INPUT ARGUMENT LIST:
#     ALAT     - LATITUDE IN DEGREES (NEGATIVE IN SOUTHERN HEMIS)
#     ALON     - EAST LONGITUDE IN DEGREES, REAL*4
#     ALAT1    - LATITUDE  OF LOWER LEFT POINT OF GRID (POINT (1,1))
#     ALON1    - LONGITUDE OF LOWER LEFT POINT OF GRID (POINT (1,1))
#                ALL REAL*4
#     DX       - MESH LENGTH OF GRID IN METERS AT 60 DEG LAT
#                 MUST BE SET NEGATIVE IF USING
#                 SOUTHERN HEMISPHERE PROJECTION.
#                   190500.0 LFM GRID,
#                   381000.0 NH PE GRID, -381000.0 SH PE GRID, ETC.
#     ALONV    - THE ORIENTATION OF THE GRID.  I.E.,
#                THE EAST LONGITUDE VALUE OF THE VERTICAL MERIDIAN
#                WHICH IS PARALLEL TO THE Y-AXIS (OR COLUMNS OF
#                OF THE GRID)ALONG WHICH LATITUDE INCREASES AS
#                THE Y-COORDINATE INCREASES.  REAL*4
#                   FOR EXAMPLE:
#                   255.0 FOR LFM GRID,
#                   280.0 NH PE GRID, 100.0 SH PE GRID, ETC.
#
#   OUTPUT ARGUMENT LIST:
#     XI       - I COORDINATE OF THE POINT SPECIFIED BY ALAT, ALON
#     XJ       - J COORDINATE OF THE POINT; BOTH REAL*4
#
#   REMARKS: FORMULAE AND NOTATION LOOSELY BASED ON HOKE, HAYES,
#     AND RENNINGER'S "MAP PROJECTIONS AND GRID SYSTEMS...", MARCH 1981
#     AFGWC/TN-79/003
#
# ATTRIBUTES:
#   LANGUAGE: CRAY CFT77 FORTRAN
#   MACHINE:  CRAY Y-MP8/832
#
#$$$
#
         RERTH<-6.3712E+6
         PI   <-3.1416
         SS60 <-1.86603
#
#        PRELIMINARY VARIABLES AND REDIFINITIONS
#
#        H <- 1 FOR NORTHERN HEMISPHERE; <- -1 FOR SOUTHERN
#
#        REFLON IS LONGITUDE UPON WHICH THE POSITIVE X-COORDINATE
#        DRAWN THROUGH THE POLE AND TO THE RIGHT LIES
#        ROTATED AROUND FROM ORIENTATION (Y-COORDINATE) LONGITUDE
#        DIFFERENTLY IN EACH HEMISPHERE
#
         H      <- 1.0
         DXL    <- DX
         REFLON <- ALONV - 270.0

         if (DX < 0) {
           H      <- -1.0
           DXL    <- -DX
           REFLON <- ALONV - 90.0
          }

#
         RADPD  <- PI / 180.0
         REBYDX <- RERTH/DXL
#
#        RADIUS TO LOWER LEFT HAND (LL) CORNER
#
         ALA1 <-  ALAT1 * RADPD
         RMLL <- REBYDX * cos(ALA1) * SS60/(1. + H * sin(ALA1))
#
#        USE LL POINT INFO TO LOCATE POLE POINT
#
         ALO1  <- (ALON1 - REFLON) * RADPD
         POLEI <- 1. - RMLL * cos(ALO1)
         POLEJ <- 1. - H * RMLL * sin(ALO1)
#
#        RADIUS TO DESIRED POINT AND THE I J TOO
#
         ALA <- ALAT   * RADPD
         RM  <- REBYDX * cos(ALA) * SS60/(1. + H * sin(ALA))
#
         ALO <- (ALON - REFLON) * RADPD
         XI  <- POLEI + RM * cos(ALO)
         XJ  <- POLEJ + H * RM * sin(ALO)
	 return(XI,XJ)
#
 }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
### Calculates the i,j grid point of a given lat-lon value on a polar stereographic projection
#
# Input: Latitude and longitude
#
#
#
# Output: Corresponding i,j grid point
#
#
# NOTE:
#   
###
 	ij2latlonStereo<-function(XI,XJ,ALAT1=22.813,ALON1=-120.351,DX=14287.5,ALONV=-105)
 {
#$$$   SUBPROGRAM  DOCUMENTATION  BLOCK
#
# SUBPROGRAM:  W3FB07        GRID COORDS TO LAT/LON FOR GRIB
#   PRGMMR: STACKPOLE        ORG: NMC42       DATE:88-04-05
#
# ABSTRACT: CONVERTS THE COORDINATES OF A LOCATION ON EARTH GIVEN IN A
#   GRID COORDINATE SYSTEM OVERLAID ON A POLAR STEREOGRAPHIC MAP PRO-
#   JECTION TRUE AT 60 DEGREES N OR S LATITUDE TO THE
#   NATURAL COORDINATE SYSTEM OF LATITUDE/LONGITUDE
#   W3FB07 IS THE REVERSE OF W3FB06.
#   USES GRIB SPECIFICATION OF THE LOCATION OF THE GRID
#
# PROGRAM HISTORY LOG:
#   88-01-01  ORIGINAL AUTHOR:  STACKPOLE, W/NMC42
#   90-04-12  R.E.JONES   CONVERT TO CRAY CFT77 FORTRAN
#
# USAGE:  CALL W3FB07(XI,XJ,ALAT1,ALON1,DX,ALONV,ALAT,ALON)
#   INPUT ARGUMENT LIST:
#     XI       - I COORDINATE OF THE POINT  REAL*4
#     XJ       - J COORDINATE OF THE POINT  REAL*4
#     ALAT1    - LATITUDE  OF LOWER LEFT POINT OF GRID (POINT 1,1)
#                LATITUDE <0 FOR SOUTHERN HEMISPHERE; REAL*4
#     ALON1    - LONGITUDE OF LOWER LEFT POINT OF GRID (POINT 1,1)
#                  EAST LONGITUDE USED THROUGHOUT; REAL*4
#     DX       - MESH LENGTH OF GRID IN METERS AT 60 DEG LAT
#                 MUST BE SET NEGATIVE IF USING
#                 SOUTHERN HEMISPHERE PROJECTION; REAL*4
#                   190500.0 LFM GRID,
#                   381000.0 NH PE GRID, -381000.0 SH PE GRID, ETC.
#     ALONV    - THE ORIENTATION OF THE GRID.  I.E.,
#                THE EAST LONGITUDE VALUE OF THE VERTICAL MERIDIAN
#                WHICH IS PARALLEL TO THE Y-AXIS (OR COLUMNS OF
#                THE GRID) ALONG WHICH LATITUDE INCREASES AS
#                THE Y-COORDINATE INCREASES.  REAL*4
#                   FOR EXAMPLE:
#                   255.0 FOR LFM GRID,
#                   280.0 NH PE GRID, 100.0 SH PE GRID, ETC.
#
#   OUTPUT ARGUMENT LIST:
#     ALAT     - LATITUDE IN DEGREES (NEGATIVE IN SOUTHERN HEMI.)
#     ALON     - EAST LONGITUDE IN DEGREES, REAL*4
#
#   REMARKS: FORMULAE AND NOTATION LOOSELY BASED ON HOKE, HAYES,
#     AND RENNINGER'S "MAP PROJECTIONS AND GRID SYSTEMS...", MARCH 1981
#     AFGWC/TN-79/003
#
# ATTRIBUTES:
#   LANGUAGE: CRAY CFT77 FORTRAN
#   MACHINE:  CRAY Y-MP8/832
#
#$$$
#
         RERTH<-6.3712E+6
         PI   <-3.1416 
         SS60 <-1.86603
#
#        PRELIMINARY VARIABLES AND REDIFINITIONS
#
#        H <- 1 FOR NORTHERN HEMISPHERE; <- -1 FOR SOUTHERN
#
#        REFLON IS LONGITUDE UPON WHICH THE POSITIVE X-COORDINATE
#        DRAWN THROUGH THE POLE AND TO THE RIGHT LIES
#        ROTATED AROUND FROM ORIENTATION (Y-COORDINATE) LONGITUDE
#        DIFFERENTLY IN EACH HEMISPHERE
#
         H      <- 1.0
         DXL    <- DX
         REFLON <- ALONV - 270.0
         if (DX < 0) {
           H      <- -1.0
           DXL    <- -DX
           REFLON <- ALONV - 90.0
         }
#
         RADPD  <- PI    / 180.0
         DEGPRD <- 180.0 / PI
         REBYDX <- RERTH / DXL
#
#        RADIUS TO LOWER LEFT HAND (LL) CORNER
#
         ALA1 <-  ALAT1 * RADPD
         RMLL <- REBYDX * cos(ALA1) * SS60/(1. + H * sin(ALA1))
#
#        USE LL POINT INFO TO LOCATE POLE POINT
#
         ALO1 <- (ALON1 - REFLON) * RADPD
         POLEI <- 1. - RMLL * cos(ALO1)
         POLEJ <- 1. - H * RMLL * sin(ALO1)
#
#        RADIUS TO THE I,J POINT (IN GRID UNITS)
#
         XX <-  XI - POLEI
         YY <- (XJ - POLEJ) * H
         R2 <-  XX**2 + YY**2
#
#
#        NOW THE MAGIC FORMULAE
#
           GI2    <- (REBYDX * SS60)**2
           ALAT   <- DEGPRD * H * asin((GI2 - R2)/(GI2 + R2))
           ARCCOS <- acos(XX/sqrt(R2))
           ALON <- REFLON - DEGPRD * ARCCOS
           if (YY > 0) {
             ALON <- REFLON + DEGPRD * ARCCOS
           }

           
         if (R2 == 0) {
           ALAT <- H * 90.
           ALON <- REFLON
         }

      if (ALON < 0) { ALON = ALON + 360 }
  return(ALAT,ALON)

 }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
### Calculates the i,j grid point of a given lat-lon value on a LAMBERT Conf projection
#
# Input: Latitude and longitude
#
#
#
# Output: Corresponding i,j grid point
#
#
# NOTE:
#
###
 	latlon2ijLAMBERT<-function(ALAT, ELON, ALAT1, ELON1, DX, ELONV, ALATAN1, ALATAN2, RERTH=6.370997E+6)
 {
#$$$   SUBPROGRAM  DOCUMENTATION  BLOCK
####################################################################################
# 	Subroutine adapted from NOAA/FSL as documented below
#	migrated from fortran to perl
####################################################################################
# SUBPROGRAM:    M_LCLLIJ    LAT/LON TO LAMBERT(I,J) FOR GRIB
#   PRGMMR: STACKPOLE        ORG: NMC42       DATE:88-11-28

# ABSTRACT: CONVERTS THE COORDINATES OF A LOCATION ON EARTH GIVEN IN
#   THE NATURAL COORDINATE SYSTEM OF LATITUDE/LONGITUDE TO A GRID
#   COORDINATE SYSTEM OVERLAID ON A LAMBERT CONFORMAL TANGENT CONE
#   PROJECTION TRUE AT A GIVEN N OR S LATITUDE. W3FB11 IS THE REVERSE
#   OF W3FB12. USES GRIB SPECIFICATION OF THE LOCATION OF THE GRID

# PROGRAM HISTORY LOG:
#   88-11-25  ORIGINAL AUTHOR:  STACKPOLE, W/NMC42
#   99-08-31  M. BARTH          RENAMED FROM W3FB11 IN ORDER TO
#                               SEND IN CONE CONSTANT.  THIS
#                               ALLOWS SINGLE OR DOUBLE TANGENT
#                               LAMBERT CONFORMAL PROJECTIONS
#                               TO BE USED.
#   99-09-15  M. BARTH          COPIED FROM MSAS & MODIFIED FOR MADIS.

# USAGE:  CALL M_LCLLIJ (ALAT,ELON,ALAT1,ELON1,DX,ELONV,ALATAN,CONE,XI,
#                        XJ)
#   INPUT ARGUMENT LIST:
#     ALAT     - LATITUDE IN DEGREES (NEGATIVE IN SOUTHERN HEMIS)
#     ELON     - EAST LONGITUDE IN DEGREES, REAL*4
#     ALAT1    - LATITUDE  OF LOWER LEFT POINT OF GRID (POINT (1,1))
#     ELON1    - LONGITUDE OF LOWER LEFT POINT OF GRID (POINT (1,1))
#                ALL REAL*4
#     DX       - MESH LENGTH OF GRID IN METERS AT TANGENT LATITUDE
#     ELONV    - THE ORIENTATION OF THE GRID.  I.E.,
#                THE EAST LONGITUDE VALUE OF THE VERTICAL MERIDIAN
#                WHICH IS PARALLEL TO THE Y-AXIS (OR COLUMNS OF
#                OF THE GRID) ALONG WHICH LATITUDE INCREASES AS
#                THE Y-COORDINATE INCREASES.  REAL*4
#                THIS IS ALSO THE MERIDIAN (ON THE BACK SIDE OF THE
#                TANGENT CONE) ALONG WHICH THE CUT IS MADE TO LAY
#                THE CONE FLAT.
#     ALATAN   - THE LATITUDE AT WHICH THE LAMBERT CONE IS TANGENT TO
#                (TOUCHES OR OSCULATES) THE SPHERICAL EARTH.  IF THIS
#                IS A DUAL-TANGENT PROJECTION, THIS IS THE EQUIVALENT
#                SINGLE-TANGENT LATITUDE CALCULATED BY M_EQVLAT.F
#                 SET NEGATIVE TO INDICATE A
#                 SOUTHERN HEMISPHERE PROJECTION
#     CONE     - THE LAMBERT CONFORMAL CONE CONSTANT

#   OUTPUT ARGUMENT LIST:
#     XI       - I COORDINATE OF THE POINT SPECIFIED BY ALAT, ELON
#     XJ       - J COORDINATE OF THE POINT; BOTH REAL*4

#   REMARKS: FORMULAE AND NOTATION LOOSELY BASED ON HOKE, HAYES,
#     AND RENNINGER'S "MAP PROJECTIONS AND GRID SYSTEMS...", MARCH 1981
#     AFGWC/TN-79/003

# ATTRIBUTES:
#   LANGUAGE: IBM VS FORTRAN
#   MACHINE:  NAS

#$$$

## WORK_TO_DO		*	Variable earth radius according to model
         RERTH<- 6.370997E+6;
         PI<-	 3.14159;

#        PRELIMINARY VARIABLES AND REDIMINITIONS

#        H = 1 FOR NORTHERN HEMISPHERE; = -1 FOR SOUTHERN
         RADPD <- PI/180.0;
         REBYDX <-RERTH/DX;
         ALATN1 <- ALATAN1 * RADPD;
         ALATN2 <- ALATAN2 * RADPD;

	ALATAN<-cone(ALATAN1,ALATAN2);

           H <- -1;
         if(ALATAN > 0) {
           H <- 1;
           }

	CONE<- ( log(cos (ALATN1)) - log( cos(ALATN2)) ) / ( log( tan( (45*RADPD) - (H*ALATN1/2) ) ) - log( tan( (45*RADPD) - (H*ALATN2/2) ) ) );
	# Caculate modified tangent intersection

        ALATN1 <- ALATAN * RADPD;

#         AN = H * SIN(ALATN1) --> THIS IS THE DIFF FROM W3FB11
         AN <- CONE;
         COSLTN <- cos(ALATN1);

#        MAKE SURE THAT INPUT LONGITUDES DO NOT PASS THROUGH
#        THE CUT ZONE (FORBIDDEN TERRITORY) OF THE FLAT MAP
#        AS MEASURED FROM THE VERTICAL (REFERENCE) LONGITUDE.

         ELON1L <- ELON1;
         if( (ELON1 - ELONV) > 180){
         	ELON1L <- ELON1 - 360;
        }
         if( (ELON1 - ELONV) < (-180)){
         	ELON1L <- ELON1 + 360;
        }

         ELONL <- ELON;
         if( (ELON  - ELONV) > 180){
         	ELONL  <- ELON  - 360;
        }
         if( (ELON - ELONV) < -180){
         	ELONL <- ELON + 360;
        }

         ELONVR <- ELONV * RADPD;

#        RADIUS TO LOWER LEFT HAND (LL) CORNER

         ALA1 <-  ALAT1 * RADPD;
         RMLL <- REBYDX * (COSLTN)^(1.0-AN) * (1.0+AN)^AN *  ( (cos(ALA1)/ (1.0+H*sin(ALA1)))^AN)/AN;

#        USE LL POINT INFO TO LOCATE POLE POINT

         ELO1 <- ELON1L * RADPD;
         ARG <- AN * (ELO1-ELONVR);
         POLEI <- 1.0 - H * RMLL * sin(ARG);
         POLEJ <- 1.0 + RMLL * cos(ARG);

#        RADIUS TO DESIRED POINT AND THE I J TOO

         ALA <-  ALAT * RADPD;
         RM <- REBYDX *  COSLTN^(1.0-AN) * (1.0+AN)^AN * ((cos(ALA)/ (1.0+H*sin(ALA)))^AN)/AN;

         ELO <- ELONL * RADPD;
         ARG <- AN*(ELO-ELONVR);

         XI <- POLEI + H * RM * sin(ARG);
         XJ <- POLEJ - RM * cos(ARG);

         
#        IF COORDINATE LESS THAN 1
#        COMPENSATE FOR ORIGIN AT (1,1)

#            	XI = XI - 1.0;	#  Critical shift of index cordinates of station location to conform with perl array standards.
#            	XJ = XJ - 1.0;	#  (e.g. Model gridpoint i=1,j=1 eq i=0,j=0 in perl because arrays start at zero not 1)
      				
#	writeLines "  W-E index---> $XI     N-S index---> $XJ\n";
	return(XI,XJ);

#** ---------------------------------------------------------------------
#** REQUIRED STANDARD FSL DISCLAIMER (NOVEMBER 2000)
#** ---------------------------------------------------------------------
#**   OPEN SOURCE LICENSE/DISCLAIMER,  FORECAST SYSTEMS LABORATORY
#**   NOAA/OAR/FSL, 325 BROADWAY BOULDER, CO 80305
#** 
#**   THIS SOFTWARE IS DISTRIBUTED UNDER THE OPEN SOURCE DEFINITION, 
#**   WHICH MAY BE FOUND AT http://www.opensource.org/osd.html.
#** 
#**   IN PARTICULAR, REDISTRIBUTION AND USE IN SOURCE AND BINARY FORMS,
#**   WITH OR WITHOUT MODifICATION, ARE PERMITTED PROVIDED THAT THE 
#**   FOLLOWING CONDITIONS ARE MET:
#** 
#**   - REDISTRIBUTIONS OF SOURCE CODE MUST RETAIN THIS NOTICE, THIS LIST
#**     OF CONDITIONS AND THE FOLLOWING DISCLAIMER.
#** 
#**   - REDISTRIBUTIONS IN BINARY FORM MUST PROVIDE ACCESS TO THIS 
#**     NOTICE, THIS LIST OF CONDITIONS AND THE FOLLOWING DISCLAIMER, AND
#**     THE UNDERLYING SOURCE CODE.
#** 
#**   - ALL MODIFICATIONS TO THIS SOFTWARE MUST BE CLEARLY DOCUMENTED, 
#**     AND ARE SOLELY THE RESPONSIBILITY OF THE AGENT MAKING THE 
#**     MODIFICATIONS.
#** 
#**   - IF SIGNIFICANT MODIFICATIONS OR ENHANCEMENTS ARE MADE TO THIS
#**     SOFTWARE, THE FSL SOFTWARE POLICY MANAGER 
#**     (softwaremgr@fsl.noaa.gov) BE NOTIFIED.
#** 
#**   THIS SOFTWARE AND ITS DOCUMENTATION ARE IN THE PUBLI# DOMAIN AND 
#**   ARE FURNISHED "AS IS."  THE AUTHORS, THE UNITED STATES GOVERNMENT,
#**   ITS INSTRUMENTALITIES, OFFICERS, EMPLOYEES, AND AGENTS MAKE NO 
#**   WARRANTY, EXPRESS OR IMPLIED, AS TO THE USEFULNESS OF THE SOFTWARE
#**   AND DOCUMENTATION FOR ANY PURPOSE.  THEY ASSUME NO RESPONSIBILITY 
#**   (1) FOR THE USE OF THE SOFTWARE AND DOCUMENTATION; OR (2) TO 
#**   PROVIDE TECHNICAL SUPPORT TO USERS.
#** ---------------------------------------------------------------------
 }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################
###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
### FSL fortran subroutine converted to R
#	This subroutine caculates the cone angle
#
# Input: Two Lambert true latitudes (e.g. 30,60)
#
#
#
# Output: Cone angle for use by the latlon2ijLAMBERT routine
#
#
# NOTE:
#
###
 	cone<-function(XLAT1, XLAT2)

 {
       PI<-3.14159265358979;
        RADPDG<-PI/180;
        DGPRAD<-180/PI;

#        SIND(X) <- SIN (RADPDG*X)
       SINL1 <- sin (RADPDG * XLAT1);
       SINL2 <- sin (RADPDG * XLAT2);

        if ( abs(SINL1 - SINL2) > 0.001) {
          AL1 <- log((1.0 - SINL1)/(1.0 - SINL2));
          AL2 <- log((1.0 + SINL1)/(1.0 + SINL2));
        }
        else {
#  CASE LAT1 NEAR OR EQUAL TO LAT2
          TAU <- -1* (SINL1 - SINL2)/(2.0 - SINL1 - SINL2);
          TAU <- TAU*TAU;
          AL1  <- 2.0 / (2.0 - SINL1 - SINL2) * (1.0    + TAU * (1.0/3.0 + TAU * (1.0/5.0 + TAU * (1.0/7.0))));
          TAU <-   (SINL1 - SINL2)/(2.0 + SINL1 + SINL2);
          TAU <- TAU*TAU;
          AL2  <- (-1)*2.0 / (2.0 + SINL1 + SINL2) * (1.0    + TAU * (1.0/3.0 + TAU * (1.0/5.0 + TAU * (1.0/7.0))));
	}

        MEQVLAT <- asin((AL1 + AL2) / (AL1 - AL2))/RADPDG;

	return(MEQVLAT)

 }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################
