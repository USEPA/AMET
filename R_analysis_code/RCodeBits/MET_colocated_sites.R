#########################################################################
#	Load required modules
  if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}
  if(!require(date))  {stop("Required Package date was not loaded")  }
########################################################
#    Initialize AMET Diractory Structure Via Env. Vars
#    AND Load required function and conf. files
##############################################################################################

## get some environmental variables and setup some directories
 ametbase         <- "/home/grc/AMET_v13"
 ametRinput       <- Sys.getenv("AMETRINPUT")
 mysqlloginconfig <- Sys.getenv("MYSQL_CONFIG")
 ametR            <- paste(ametbase,"/R_analysis_code",sep="")
 source (paste(ametR,"/MET_amet.misc-lib.R",sep=""))
 source (paste(ametR,"/MET_amet.plot-lib.R",sep=""))
 source (paste(ametR,"/MET_amet.stats-lib.R",sep=""))

mysql_server    <- "tesla.epa.gov"
amet_login      <- "rgilliam"
amet_pass       <- "283ButterFish!"
maxrec          <- 10000000
mysql1          <-list(server=mysql_server,dbase="amad_nrt",login=amet_login,
                        passwd=amet_pass,maxrec=maxrec)
mysql2          <-list(server=mysql_server,dbase="amad_amet_herwehe",login=amet_login,
                        passwd=amet_pass,maxrec=maxrec)
########################################################################################################################
#	MAIN TIME SERIES PROGRAM
########################################################################################################################
#######################################################################################################################################
#   STEP 1) Query the database for the station's met data
#######################################################################################################################################
#	Create Queries from date and query specs provided by user
 query1<-paste("SELECT stat_id,lat,lon from stations",sep="")
                 

  # Query Database and put into data frame, then massage data
 met_sites<-ametQuery(query1,mysql1)
 met_sites_noaa<-ametQuery(query1,mysql2)

 writeLines(paste(query1))


 aq_sites<-  read.csv(file="/home/grc/AMET_v13/scripts_analysis/denver4_base/denver_aq_sites4km.csv",sep=",",header=F)

 n.sites<-dim(aq_sites)[1]
 file.out<-"CO_aq_met_sites3.csv"
 sfile<-file(file.out,"w")
 for(s in 1:n.sites ) {
   # Find buddy site
   d<-dist.lat.lon(aq_sites[s,4],met_sites[,2],aq_sites[s,3],met_sites[,3])
   buddy_ind            <- which( d == min(d) )
   buddy_other          <- which( d < 48 )
   d_sort_sites         <- sort(d[buddy_other])

   d2<-dist.lat.lon(aq_sites[s,4],met_sites_noaa[,2],aq_sites[s,3],met_sites_noaa[,3])
   buddy_ind_noaa       <- which( d2 == min(d2) )

   sind  <- which( d == d_sort_sites[1] )
   bsid1 <-met_sites[sind,1]
   bdist1<-round(d_sort_sites[1])
   sind  <- which( d == d_sort_sites[2] )
   bsid2 <-met_sites[sind,1]
   bdist2<-round(d_sort_sites[1])
   sind  <- which( d == d_sort_sites[3] )
   bsid3 <-met_sites[sind,1]
   bdist3<-round(d_sort_sites[1])

   noaaid<-met_sites_noaa[buddy_ind_noaa[1],1]
   noaadist<-round(min(d2))

   #writeLines(paste("Other sites near",aq_sites[s,1], met_sites[buddy_other[3],1],d[buddy_other[2]]))
   #writeLines(paste(aq_sites[s,1],",",met_sites[buddy_ind,1],",",min(d)), con =sfile)

   writeLines(paste(aq_sites[s,1],",",bsid1,",",bsid2,",",bsid3,",",noaaid,",",bdist1,",",bdist2,",",bdist3,",",noaadist), con =sfile)

   if(s==1) {
     str  <-paste("set SITES=(",bsid1," ",bsid2," ",bsid3," ",noaaid,sep="")
   }
   if(s>1){
      str <-paste(str," ",bsid1," ",bsid2," ",bsid3," ",noaaid,sep="")
    }
   #writeLines(paste(s,str))
   #writeLines(paste("------------------------"))
  }
close(sfile)

 str  <-paste(str,")",sep="")
 sfile<-file(paste("spatial.setSITES.all.txt",sep=""),"w")
 writeLines(str, con =sfile)
 close(sfile)

########################################################################################################################
#				FINISHED
########################################################################################################################
quit(save="no")


 query1<-paste("SELECT stat_id,lat,lon from stations",sep="")
                 

  # Query Database and put into data frame, then massage data
 met_sites_noaa<-ametQuery(query1,mysql2)

 writeLines(paste(query1))

 load("/work/YODA/users/bwells01/MetAdj/ISH/ish.sites.Rdata")
 aq_sites<- ish.sites 

 n.sites<-dim(aq_sites)[1]
 file.out<-"US_AQ_MET_sites.KSITES.csv"
 sfile<-file(file.out,"w")
 for(s in 1:n.sites ) {

   # Find buddy site
   #d2<-dist.lat.lon(aq_sites[s,4],met_sites_noaa[,2],aq_sites[s,3],met_sites_noaa[,3])
   d2<-dist.lat.lon(aq_sites[s,5],met_sites_noaa[,2],aq_sites[s,6],met_sites_noaa[,3])
   buddy_ind_noaa       <- which( d2 == min(d2) )

   noaaid<-met_sites_noaa[buddy_ind_noaa[1],1]
   noaadist<-round(min(d2))

   buddy_other          <- which( d2 < 200 )
   d_sort_sites         <- sort(d2[buddy_other])

   if(length(d_sort_sites) < 1){
     noaaid<-"NOSITE"
     noaadist<-99999
     next
   }
   if(length(d_sort_sites) >= 1){
   for(b in 1:length(buddy_other)){
     sind  <- which( d2 == d_sort_sites[b] )
     bsid <-met_sites_noaa[sind,1]
     first_letter<-unlist(strsplit(bsid,split=""))[1]
     #if(first_letter=="K" || first_letter=="C" || first_letter=="P"){
     if(first_letter=="K"){
       noaaid<-bsid
       noaadist<-d_sort_sites[b] 
       writeLines(paste("Site ID and distance",noaaid, noaadist))
       break     
     }
   }
   }
   # Query site for completeness
   #sid<-paste(" AND stat_id='",c(noaaid,bsid1,bsid2,bsid3),"'",sep="")
   #sid<-paste(" AND stat_id='",c(noaaid),"'",sep="")
   #query1<-paste("SELECT T_ob from 12us_tseries_surface where ob_date BETWEEN 20080101 and 20171231",sid, sep="")
   #met_sites<-ametQuery(query1[1],mysql1)

   writeLines(paste(aq_sites[s,1],",",noaaid,",",round(noaadist)), con =sfile)

   if(s==1) {
     str  <-paste("set SITES=(",noaaid,sep="")
   }
   if(s>1){
      str <-paste(str," ",noaaid,sep="")
    }
  }
close(sfile)
str  <-paste(str,")",sep="")
sfile<-file(paste("spatial.setSITES.all.txt",sep=""),"w")
writeLines(str, con =sfile)
close(sfile)



