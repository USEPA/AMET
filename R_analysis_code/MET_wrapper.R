#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#                AMET (Atmospheric Model Evaluation Tool)               #
#                                                                       #
#         Developed by the US Environmental Protection Agency           #
#-----------------------------------------------------------------------#
#########################################################################
#                                                                       #
#                                                                       #
# Version 1.2, May 8, 2013, Robert Gilliam                              #
#                                                                       #            
#                                                                       #            
#########################################################################
  options(warn=-1)
#:::::::::::::::::::::::::::::::::::::::::::::
#	Load required modules
  if(!require(maps))   {stop("Required Package maps was not loaded")}
  if(!require(mapdata)){stop("Required Package mapdata was not loaded")}
  if(!require(date))   {stop("Required Package date was not loaded")}
  if(!require(RMySQL)) {stop("Required Package RMySQL was not loaded")}
  if(!require(akima))  {stop("Required Package akima was not loaded")}
  if(!require(fields)) {stop("Required Package fields was not loaded")}
#########################################################################
#    Initialize AMET Diractory Structure Via Env. Vars
#    AND Load required function and conf. files
#########################################################################
 ## Get environmental variables and setup main AMET directories and files
 ametbase         <- Sys.getenv("AMETBASE")
 wrapperrunid     <- unlist(strsplit(Sys.getenv("WRAPPER_RUNID"), ".", fixed = TRUE))
 ametR            <- paste(ametbase,"/R_analysis_code",sep="")
 ametRinput       <- Sys.getenv("AMETRINPUT")
 mysqlloginconfig <- Sys.getenv("MYSQL_CONFIG")
 ametRstatic      <- Sys.getenv("AMETRSTATIC")

 # Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
 # and not specified via AMET_OUT, then set figdir to the current directory
 if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")      }
 if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"                        }
 ## Check for Static file setting and set to empty if missing. Backward compat.
 ## & print input files for user notification
 if(ametRstatic=="") { ametRstatic <- "./" }
 writeLines(paste("AMET R Config input file:",ametRinput))
 writeLines(paste("AMET R Static input file:",ametRstatic))

 ## source some configuration files, AMET libs, and input
 source (paste(ametR,"/MET_amet.misc-lib.R",sep=""))
 source (paste(ametR,"/MET_amet.plot-lib.R",sep=""))
 source (paste(ametR,"/MET_amet.stats-lib.R",sep=""))
 source (mysqlloginconfig)
 source (ametRinput)
 source (ametRstatic)

 ametdbase1   <- Sys.getenv("AMET_DATABASE")
 mysqlserver  <- Sys.getenv("MYSQL_SERVER")
 mysql1       <- list(server=mysqlserver,dbase=ametdbase1,login=amet_login,
                      passwd=amet_pass,maxrec=maxrec)
######################################################################### 
 # Temporary R input to change various settings before main script run
 # -  Wrapper RUNID has 2 two character IDs with period dividing (SP.MN) to control script and mode
 # -  Script ID SP=spatial surface  DB= daily bar stats  SM=summary stats
 #              SW=sw radiation     UA=upper-air/raob
 # -  Anal ID   MN= montly          SE=seasonal          CR=climate regions      

 # Capture orginal input configuration files (main config and static) before redefining for wrapper
 ametRinput1  <-ametRinput
 ametRstatic1 <-ametRstatic
 
 # Redfine main config as a dummy file so settings below are not overwritten
 tmpRinput <-".tmpR"
 Sys.unsetenv("AMETRINPUT") 
 Sys.setenv(AMETRINPUT=tmpRinput) 
 dstring   <-"writeLines('Dummy R configuration input loaded....') "
 if(!file.exists(".tmpR")) {
   write(dstring,file=tmpRinput, append=F)
 }
 
 # Fixing cases where variables may not exist in configs files for various scripts
 if(!exists("bounds"))           { bounds <- c(NA,NA,NA,NA)  }
 if(!exists("ys"))               { ys <- as.numeric(Sys.getenv("AMET_YEAR")) }
 if(is.na(ys))                   { ys <- as.numeric(Sys.getenv("AMET_YEAR")) }
 if(is.na(daily))                { daily <- F }


 # Define a window if lat-lon bounds are defined
 extra_window   <-paste(" AND (s.lat BETWEEN",bounds[1]," AND ",bounds[2],
                        "AND  s.lon BETWEEN",bounds[3]," AND ",bounds[4],") ")
 if(anyNA(bounds)){
   extra_window <- ""
 }

 # Define US Climate Regions for extra query criteria
 nregions               <-9
 regional_states        <-array(NA,c(nregions,11))
 extra_region           <-array(NA,c(nregions))
 region_names           <-c("Northeast","UpperMidwest","OhioValley","Southeast","NorthernRockiesPlains",
                            "South","Southwest","Northwest","West")
 regional_states[1,1:11]<-c("CT","DE","ME","MD","MA","NH","NJ","NY","PA","RI","VT")
 regional_states[2,1:4] <-c("IA","MI","MN","WI")
 regional_states[3,1:7] <-c("IL","IN","KY","MO","OH","TN","WV")
 regional_states[4,1:6] <-c("AL","FL","GA","NC","SC","VA")
 regional_states[5,1:5] <-c("MT","NE","ND","SD","WY")
 regional_states[6,1:6] <-c("AR","KS","LA","MS","OK","TX")
 regional_states[7,1:4] <-c("AZ","CO","NM","UT")
 regional_states[8,1:3] <-c("ID","OR","WA")
 regional_states[9,1:2] <-c("CA","NV")
 for(rr in 1:nregions) {
   nstates <- sum(ifelse(is.na(regional_states[rr,]),0,1))
   tmpstr<-" AND ( "
   for(ss in 1:(nstates-1)) {
      tmpstr<-paste(tmpstr,"s.state='",regional_states[rr,ss],"' OR ",sep="")
   }
   extra_region[rr] <-paste(tmpstr,"s.state='",regional_states[rr,nstates],"') ",sep="")
   rm(tmpstr)
 }
 if(wrapperrunid[2] != "RM" & wrapperrunid[2] != "RS") {    nregions <- 1 }


 # Check for valid run mode. If FALSE at the end of script warning message returned.
 if.good.mode       <-F

     writeLines(paste("DEBUG",daily))
 ######################################################################### 
 #################################
 # MONTHLY LOOP
 if(wrapperrunid[2] == "MN" || wrapperrunid[2] == "RM")   {
   mnendday <-c("31","28","31","30","31","30","31","31","30","31","30","31")

   for(ii in 1:12) {

     # RAOB pushes year variables ys and ye as character. 
     # These need to be numeric in universal wrapper.
     if(is.character(ys)){
       ys<-as.numeric(ys)
       ye<-as.numeric(ye)
     }
     #######################################
     # Set up all year, month and day start and 
     # end variables to create date strings
     year_start0000  <- sprintf("%03d", ys)
     year_end0000    <- sprintf("%03d", ys)
     year_end0000p1  <- sprintf("%03d", ys)
     month_start00   <- sprintf("%02d", ii)
     month_end00     <- sprintf("%02d", ii)
     month_end00p1   <- sprintf("%02d", ii+1)
     if(month_end00p1 == "13"){   
       month_end00p1   <- "01"
       year_end0000p1  <- sprintf("%03d", ys+1)
     }
     day_start00     <- "01"
     day_end00       <- mnendday[ii]
     day_end00p1     <- "01"
     yyyymmdd_start  <- paste(year_start0000,month_start00,day_start00,sep="")
     yyyymmdd_end    <- paste(year_end0000,month_end00,day_end00,sep="")
     yyyymmdd_endp1  <- paste(year_end0000p1,month_end00p1,day_end00p1,sep="")
     #######################################

     #######################################
     # SPATIAL SURFACE MONTHLY RUN wrapperrunid=SP.MN
     if(wrapperrunid[1] == "SP" & wrapperrunid[2] == "MN")   {
       date<-c(yyyymmdd_start,yyyymmdd_end)
       extra <- extra_window
       writeLines(paste("RUNNING SPATIAL SURFACE MONTHLY-->",
                        yyyymmdd_start," to ",yyyymmdd_end,sep=""))
       try(source (paste(ametR,"/MET_spatial_surface.R",sep="")), silent=T)
       if.good.mode <-T
     }
     #######################################

     #######################################
     # DAILY SURFACE STATS by MONTHLY wrapperrunid=DB.MN
     if(wrapperrunid[1] == "DB" )   {
       for(rr in 1:nregions){
         if(wrapperrunid[2] == "RM") {  
           querystr   <-paste("AND d.ob_date >=  ",yyyymmdd_start," AND d.ob_date < ",
                              yyyymmdd_endp1, extra_window, extra_region[rr], " ORDER BY d.ob_date", sep="")
           runid      <- paste(yyyymmdd_start,".", yyyymmdd_end,".", region_names[rr],sep="")
           writeLines(paste("RUNNING REGIONAL DAILY STATS by MONTH-->",yyyymmdd_start,
                            " to ",yyyymmdd_endp1,region_names[rr]))
         }
         else {
           querystr   <-paste("AND d.ob_date >=  ",yyyymmdd_start," AND d.ob_date < ",
                              yyyymmdd_endp1, extra_window," ORDER BY d.ob_date", sep="")
           runid   <- paste(yyyymmdd_start,".",yyyymmdd_end,sep="")
           writeLines(paste("RUNNING DAILY STATS by MONTH-->",yyyymmdd_start,
                            " to ",yyyymmdd_endp1,sep=""))
         }
         try(source (paste(ametR,"/MET_daily_barplot.R",sep="")), silent=T)
         if.good.mode <-T
       }
     }
     #######################################

     #######################################
     # SUMMARY STATS by MONTHLY AND REGION wrapperrunid=SM.MN
     if(wrapperrunid[1] == "SM" )   {
       for(rr in 1:nregions){
         if(wrapperrunid[2] == "RM") {  
            querystr   <-paste("AND d.ob_date >=  ",yyyymmdd_start," AND d.ob_date < ",
                               yyyymmdd_endp1, extra_window, extra_region[rr], sep="")
            query_str  <- querystr
            runid      <- paste(yyyymmdd_start,".", yyyymmdd_end,".", region_names[rr],sep="")
            writeLines(paste("RUNNING REGIONAL SUMMARY STATS by MONTH-->",yyyymmdd_start,
                             " to ",yyyymmdd_endp1,region_names[rr]))
         }
         else {
           querystr   <-paste("AND d.ob_date >=  ",yyyymmdd_start," AND d.ob_date < ",
                              yyyymmdd_endp1, extra_window, sep="")
           runid      <- paste(yyyymmdd_start,".",yyyymmdd_end,sep="")
           writeLines(paste("RUNNING SUMMARY STATS by MONTH-->",yyyymmdd_start,
                            " to ",yyyymmdd_endp1))
         }
         query_str  <- querystr
         pid        <- runid
         queryID    <- pid
         figid_sub  <- runid
         query_str  <- querystr
         try(source (paste(ametR,"/MET_summary.R",sep="")), silent=T)
         if.good.mode<-T
       }
     }
     #######################################
     
     #######################################
     # Upper-air STATS by MONTHLY wrapperrunid=UA.MN
     if(wrapperrunid[1] == "UA" )   {
       # Force Spatial, Timeseries and Profile Stats as wrapper protocol.
       # No site specific options so curtainM off & all Native level options.
       statid    <-"ALL"
       TSERIESM  <-TRUE
       PROFM     <-TRUE
       CURTAINM  <-FALSE
       PROFN     <-FALSE
       CURTAINN  <-FALSE
       ys<-as.character(year_start0000); ye <-as.character(year_end0000); 
       ms<-as.character(month_start00);  me <-as.character(month_end00); 
       ds<-as.character(day_start00);    de <-as.character(day_end00);
       for(rr in 1:nregions){
         if(wrapperrunid[2] == "RM") {  
           SPATIALM  <-FALSE
           writeLines(paste("RUNNING Upper-Air STATS by REGION & MONTH-->",yyyymmdd_start,
                            " to ",yyyymmdd_end,sep=""))
           extra     <- extra_region[rr]
           runid     <- region_names[rr]
         }
         else {
           SPATIALM  <-TRUE
           writeLines(paste("RUNNING Upper-Air STATS by MONTH-->",yyyymmdd_start,
                            " to ",yyyymmdd_end,sep=""))
           extra  <- ""
           runid     <- "MONTHLY"
         }
         try(source (paste(ametR,"/MET_raob.R",sep="")), silent=T)
         if.good.mode <-T
       }
     }
     #######################################

     #######################################
     # SW Radiation STATS by MONTHLY wrapperrunid=SW.MN
     if(wrapperrunid[1] == "SW" & wrapperrunid[2] == "MN")   {
       diurnal   <- TRUE    
       spatial   <- TRUE   
       timeseries<- FALSE    
       histogram <- FALSE    
       ys<-as.character(year_start0000); ye <-as.character(year_end0000); 
       ms<-as.character(month_start00);  me <-as.character(month_end00); 
       ds<-as.character(day_start00);    de <-as.character(day_end00);
       date<-c(yyyymmdd_start,yyyymmdd_end)
       writeLines(paste("RUNNING SW Radiation STATS by MONTH-->",yyyymmdd_start,
                        " to ",yyyymmdd_end,sep=""))
       try(source (paste(ametR,"/MET_plot_radiation.R",sep="")), silent=T)
       if.good.mode <-T
     }
     #######################################
   }
  }
 #################################
 ######################################################################### 

 ############################################################################################ 
 ############################################################################################ 
 ############################################################################################ 

 ######################################################################### 
 #################################
 # SEASONAL LOOP
 if(wrapperrunid[2] == "SE" || wrapperrunid[2] == "RS" )   {
   seas <-c("0101","0401","0701","1001")
   seae <-c("0401","0701","1001","1231")
   sear <-c("0331","0630","0930","1231")
   seal <-c("JanFebMar","AprMayJun","JulAugSep","OctNovDec")

   for(ii in 1:4) {

     # RAOB pushes year variables ys and ye as character. 
     # These need to be numeric in universal wrapper.
     if(is.character(ys)){
       ys<-as.numeric(ys)
       ye<-as.numeric(ye)
     }
     #######################################
     # Set up all year 4 digits
     # end variables to create date strings
     year_start0000  <- sprintf("%03d", ys)
     year_end0000    <- sprintf("%03d", ys)
     #######################################

     #######################################
     # SPATIAL SURFACE SEASONAL RUN wrapperrunid=SP.SE
     if(wrapperrunid[1] == "SP" & wrapperrunid[2] == "SE")   {
       date<-c(paste(year_start0000,seas[ii],sep=""),paste(year_start0000,sear[ii],sep=""))
       extra <- extra_window
       writeLines(paste("RUNNING SPATIAL SURFACE SEASONAL-->",
                        year_start0000,seas[ii]," to < ",
                        year_end0000,seae[ii],sep=""))
       try(source (paste(ametR,"/MET_spatial_surface.R",sep="")), silent=T)
       if.good.mode <-T
     }
     #######################################

     #######################################
     # DAILY SURFACE STATS by SEASON wrapperrunid=DB.SE
     if(wrapperrunid[1] == "DB")   {
       for(rr in 1:nregions){
         if(wrapperrunid[2] == "RS") {  
           querystr   <-paste("AND d.ob_date >=  ",year_start0000,seas[ii]," AND d.ob_date < ",
                              year_start0000,seae[ii], extra_window, extra_region[rr],
                              " ORDER BY d.ob_date", sep="")
           runid   <- paste(year_start0000,seas[ii],".",year_start0000,sear[ii],
                            ".",region_names[rr],sep="")
           writeLines(paste("RUNNING DAILY DOMAIN STATS SEASONALLY-->",
                            year_start0000,seas[ii]," to < ",
                            year_end0000,seae[ii],sep=""))
         }
         else {
           querystr   <-paste("AND d.ob_date >=  ",year_start0000,seas[ii]," AND d.ob_date < ",
                              year_start0000,seae[ii], extra_window," ORDER BY d.ob_date", sep="")
           runid   <- paste(year_start0000,seas[ii],".",year_start0000,sear[ii],sep="")
           writeLines(paste("RUNNING DAILY DOMAIN STATS SEASONAL-->",
                            year_start0000,seas[ii]," to < ",
                            year_end0000,seae[ii],sep=""))
         }
         try(source (paste(ametR,"/MET_daily_barplot.R",sep="")), silent=T)
         if.good.mode <-T
       }
     }
     #######################################

     #######################################
     # SUMMARY STATS by SEASON wrapperrunid=SM.SE
     if(wrapperrunid[1] == "SM" )   {
       for(rr in 1:nregions){
         if(wrapperrunid[2] == "RS") {  
           querystr   <-paste("AND d.ob_date >=  ",year_start0000,seas[ii]," AND d.ob_date < ",
                              year_start0000,seae[ii], extra_window, extra_region[rr], sep="")
           runid      <- paste(year_start0000,seas[ii],".",year_start0000,sear[ii],
                               ".",region_names[rr],sep="")
           writeLines(paste("RUNNING REGIONAL SUMMARY STATS SEASONALLY-->",
                            year_start0000,seas[ii]," to < ",
                            year_end0000,seae[ii],sep=""))
         }
         else {
           querystr   <-paste("AND d.ob_date >=  ",year_start0000,seas[ii]," AND d.ob_date < ",
                              year_start0000,seae[ii], extra_window, sep="")
           runid      <- paste(year_start0000,seas[ii],".",year_start0000,sear[ii],sep="")
           writeLines(paste("RUNNING SUMMARY STATS SEASONALLY-->",
                            year_start0000,seas[ii]," to < ",
                            year_end0000,seae[ii],sep=""))
         }
         query_str  <- querystr
         pid        <- runid
         queryID    <- pid
         figid_sub  <- runid
         query_str  <- querystr
         try(source (paste(ametR,"/MET_summary.R",sep="")), silent=T)
         if.good.mode<-T
       }
     }
     #######################################

     #######################################
     # Upper-air STATS by SEASON wrapperrunid=UA.SE
     if(wrapperrunid[1] == "UA" )   {
       # Force Spatial, Timeseries and Profile Stats as wrapper protocol.
       # No site specific options so curtainM off & all Native level options.
       statid    <-"ALL"
       TSERIESM  <-TRUE
       PROFM     <-TRUE
       CURTAINM  <-FALSE
       PROFN     <-FALSE
       CURTAINN  <-FALSE
       tmpxs     <- unlist(strsplit(seas[ii],split=""))
       tmpxe     <- unlist(strsplit(sear[ii],split=""))
       ys        <-as.character(year_start0000); ye <-as.character(year_end0000); 
       ms        <-paste(tmpxs[1],tmpxs[2],sep="");
       me        <-paste(tmpxe[1],tmpxe[2],sep="");
       ds        <-paste(tmpxs[3],tmpxs[4],sep="");
       de        <-paste(tmpxe[3],tmpxe[4],sep="");
       for(rr in 1:nregions){
         if(wrapperrunid[2] == "RS") {  
           SPATIALM  <-FALSE
           writeLines(paste("RUNNING REGIONAL Upper-Air STATS SEASONALLY-->",
                            year_start0000,seas[ii]," to < ",
                            year_end0000,seae[ii],sep=""))
           extra     <- extra_region[rr]
           runid     <- region_names[rr]
         }
         else {
           SPATIALM  <-TRUE
           writeLines(paste("RUNNING Upper-Air STATS SEASONALLY-->",
                            year_start0000,seas[ii]," to < ",
                            year_end0000,seae[ii],sep=""))
           extra     <- ""
           runid     <- "SEASONAL"
         }
         try(source (paste(ametR,"/MET_raob.R",sep="")), silent=T)
         if.good.mode <-T
       }
     }
     #######################################

     #######################################
     # SW Radiation STATS by SEASON wrapperrunid=SW.SE
     if(wrapperrunid[1] == "SW" & wrapperrunid[2] == "SE")   {
       diurnal   <- TRUE    
       spatial   <- TRUE   
       timeseries<- FALSE    
       histogram <- FALSE    
       tmpxs     <- unlist(strsplit(seas[ii],split=""))
       tmpxe     <- unlist(strsplit(sear[ii],split=""))
       ys        <-as.character(year_start0000); ye <-as.character(year_end0000); 
       ms        <-paste(tmpxs[1],tmpxs[2],sep="");
       me        <-paste(tmpxe[1],tmpxe[2],sep="");
       ds        <-paste(tmpxs[3],tmpxs[4],sep="");
       de        <-paste(tmpxe[3],tmpxe[4],sep="");
       date<-c(paste(year_start0000,seas[ii],sep=""),paste(year_start0000,seae[ii],sep=""))
       writeLines(paste("RUNNING SW Radiation STATS SEASONALLY-->",
                        year_start0000,seas[ii]," to < ",
                        year_end0000,seae[ii],sep=""))
       try(source (paste(ametR,"/MET_plot_radiation.R",sep="")), silent=T)
       if.good.mode <-T
     }
     #######################################

   }
  }
 #################################
 ######################################################################### 
 #system(paste("rm",tmpRinput)) 
 if(!if.good.mode){
   writeLines(paste("ERROR---> Wrapper mode ",wrapperrunid[1],".",wrapperrunid[2]," not implemented or wrong.",sep=""))
   writeLines("Current mode option codes:")
   writeLines(paste("                    Monthly (MN), Seasonal (SE) for year", sprintf("%03d", ys)))
   writeLines(paste("Spatial Surface Analysis   SP.MN, SP.SE"))
   writeLines(paste("Daily Surface Statistics   DB.MN, DB.SE"))
   writeLines(paste("Summary Surface Statistics SM.MN, SM.SE"))
   writeLines(paste("Upper-air Statistics       UA.MN, UA.SE"))
   writeLines(paste("Shortwave Rad. Statistics  SW.MN, SW.SE"))

   writeLines(paste("                                       "))
   writeLines(paste("           Regional Monthly (RM), Seasonal (RS) for year", sprintf("%03d", ys)))
   writeLines(paste("Daily Surface Statistics   DB.RM, DB.RS"))
   writeLines(paste("Summary Surface Statistics SM.RM, SM.RS"))
   writeLines(paste("Upper-air Statistics       UA.RM, UA.RS"))
 }

