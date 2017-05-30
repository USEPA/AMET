#######################################################################################################
#######################################################################################################
#
#		AMET Miscellanous Function Library
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
#  - massageTseries: removed outdated logic for MixRatio in the case of MARITIME
#  - quickstats: Bug fix that only impacted run_timeseries.csh statistics (index of agreement
#                and wind direction statistics). IOA for wind speed was mostly impacted
#                because obs and model did not include the same maskout of values below minimum
#                allowable wind speed. Wind direction error was lower than it should have been
#                because an experimental option where mod-obs wind direction differences were 
#                weighted as a function of wind speed. This was disabled. Also, MAE and Bias functions
#                were used instead of direct computation in the quickstats function.
#  - stationStatsSfc: threshold sample size implemented, so sites with a lot of missing data can be 
#                     ignored.
#  - station.ts.filter: New function that uses K-Z filter to partition model-obs time series into 
#                       intra-day, diurnal and synoptic components. Note: Not fully operational!
#  - kz.filter: New K-Z filtering function. Note: Not fully operational! It works, but controling 
#               script is not supported yet.
#
#-----------------------------------------------------------------------###############################
#######################################################################################################
#######################################################################################################
#	This collection contains the following functions
#
#	dform           --> Simple format function, formats numbers from one to two digit 
#
#	avewindow       --> Simple Averaging window function
#
#	quickstats      --> A simple function that caculates error, bias, ioa statistics from a given dataset
#	
#	ac              --> Anomoly correlation/index of agreement function
#
#	genvarstats     --> Complete Model Performance Metrics Caculations
#
#	datecalc        --> Calculate Dates given an inital date and dour or day to add
#
#	ametQuery	      --> MySQL Query  Function 	
#
#	massageTseries	--> Takes surface related variables, filters bad data, converts wind componentes speed and direction.
#
#	stationStatsSfc	--> Sorts a set of paired obs-model data by site and computes model performance metrics
#
#	compressedcheck --> Checks a file for compression.
#
#	acumprecip      --> Acummulates precipitation from NPA precipitation files in the savedir/npa/R-save
#
# station.ts.filter-> K-Z filtering of model-obs times series at each site in the model domain
#
# kz.filter       --> R version of the K-Z filter function
#
#######################################################################################################
#######################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
# Simple format function, formats numbers from one to two digit (e.g. 7 to 07)
   dform<-function(num) {
     if(num<10){num<-paste("0",num,sep="")}
     return(num)
   }
#####--------------------------		END OF FUNCTION 	--------------------------------------####
##########################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
#	Averaging window function
 avewindow<-function(obs,window){
##########################################################################################################
 	
 	smth<-array(NA,c(length(obs),1))
 	for (t in (window+1):(length(obs)-window) ){
 		smth[t]<- mean(obs[(t-window):(t+window)],na.rm=TRUE) 	
 	}
 return(smth)
}
#####--------------------------		END OF FUNCTION 	--------------------------------------####
##########################################################################################################
##########################################################################################################

##########################################################################################################
##########################################################################################################
#				FUNCTION Quick Stats 
 quickstats<-function(obs,mod,wsob,digs=5,wd=FALSE,wdweightws=FALSE){
##########################################################################################################
 	if (wd){
 		diff<-mod-obs
		diff<-ifelse(diff > 180 , diff-360, diff)
		diff<-ifelse(diff< -180 , diff+360, diff)
		obs<-runif(length(diff),min=0,max=0.001) * diff/diff
		#mod<-diff*(0.320*log(ifelse(wsob>1,wsob,1)+0.380))		 # Turned off this dangerous options as it's not well documented
		                                                       # WS limit can be used to change WD statistics based on min wind speed
		#if(!wdweightws){ 
	  mod<-diff
		#}
 	}
	mae  <-magerror(obs, mod,na.rm=T)		# AMD Model evaluation statistics
 	bias <-mbias(obs,mod,na.rm=T)
	ioa  <-ac(obs,mod*obs/obs)

  # Turned off Apr 2013. Used standard functions above although no problems with code below.
 	#mae <-(1/length(na.omit(obs)))*sum(abs(mod-obs),na.rm=TRUE)
 	#bias<-(1/length(na.omit(obs)))*sum(mod-obs,na.rm=TRUE)
	
	# Turned this off Apr 2013 in place of above. Mean or climate value use in formula is subtracted from model. This ensures
	# that vector has same missing samples as observations.
	#ioa <-ac(obs,mod)

	mfbias  <-format(mfbias(obs, mod, na.rm = TRUE),digits=digs)
	mnbias  <-format(mnbias(obs, mod, na.rm = TRUE),digits=digs)
	mngerror<-format(mngerror(obs, mod, na.rm = TRUE),digits=digs)
	nmbias  <-format(nmbias(obs, mod, na.rm = TRUE),digits=digs)
	nmerror <-format(nmerror(obs, mod, na.rm = TRUE),digits=digs)
	rmserror<-format(rmserror(obs, mod, na.rm = TRUE),digits=digs)

	mae     <-format(mae,digits=digs+1)
	bias    <-format(bias,digits=digs)
	ioa     <-format(ioa,digits=digs)
	
	qc<-list(mae=mae,bias=bias,ioa=ioa,mfbias=mfbias,mnbias=mnbias,mngerror=mngerror,
	         nmbias=nmbias,nmerror=nmerror,rmserror=rmserror)
	return(qc)
}
#####--------------------------		END OF FUNCTION 	--------------------------------------####
####################################################################################################################################################################################################################
##########################################################################################################

####################################################################################################################################################################################################################
##########################################################################################################
#				FUNCTION AC (ANOMOLY CORRELATION)
 ac<-function(obs,mod){
##########################################################################################################
 	cm<-mean(obs,na.rm=TRUE)
	p1<-sum (    (mod-cm)*(obs-cm),na.rm=TRUE        )
	p2<-(sum(  (mod-cm)^2,na.rm=TRUE ) * sum ( (obs-cm)^2,na.rm=TRUE )  )^0.5
	ac<-p1/p2
}
#####--------------------------		END OF FUNCTION 	--------------------------------------####
##########################################################################################################
##########################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Model Performance Metrics Caculations
#
# Input: model and observation list with mod defined as model 
#	 and obs defined as the observation
#   
# Output:  Model statistics matrix
#
# NOTE: The database must have a table names stations (within the AMET framework)
#   
###
  genvarstats<-function(var,varname="DEFAULT"){
 
		mod<-var$mod
		obs<-var$obs
		diff<-mod-obs
#############################################################
	metrics<-array(,)
	metrics[1]<-length(obs)
	metrics[1]<-sum(ifelse(!is.na(mod),1,0))
	metrics[2]<-max(obs,na.rm=T)		# Standard description of observation data
	metrics[3]<-min(obs,na.rm=T)
	metrics[4]<-mean(obs,na.rm=T)
	metrics[5]<-median(obs,na.rm=T)
	metrics[6]<-sum(obs,na.rm=T)
	metrics[7]<-var(obs,use="complete.obs")

	metrics[8]<-max(mod,na.rm=T)		# Standard description of model data
	metrics[9]<-min(mod,na.rm=T)
	metrics[10]<-mean(mod,na.rm=T)
	metrics[11]<-median(mod,na.rm=T)
	metrics[12]<-sum(mod,na.rm=T)
	metrics[13]<-var(mod,use="complete.obs")

	metrics[14]<-cor(mod,obs,use="complete.obs")	# Correlation and variance
	metrics[15]<-var(diff,use="complete.obs")
	metrics[16]<-sqrt(var(diff,use="complete.obs"))

	
	metrics[17]<-magerror(obs, mod,na.rm=T)		# AMD Model evaluation statistics
 	metrics[18]<-mbias(obs,mod,na.rm=T)
	metrics[19]<-mfbias(obs, mod,na.rm=T)
	metrics[20]<-mnbias(obs, mod,na.rm=T)
	metrics[21]<-mngerror(obs, mod,na.rm=T)
	metrics[22]<-nmbias(obs, mod,na.rm=T)
	metrics[23]<-nmerror(obs, mod,na.rm=T)
	metrics[24]<-rmserror(obs, mod,na.rm=T)
	metrics[25]<-ac(obs,mod)
		

 	metricsID<-c("count","maxO","minO","meanO","medianO","sumO","varO","maxM","minM","meanM","medianM","sumM","varM",
	"cor","var","sdev","mae","bias","mfbias","mnbias","mngerror","nmbias","nmerror","rmserror","ac")
	metricsNAME<-c("Number of Pairs","Max. Obs","Min. Obs")
	out<-list(metrics=metrics,id=metricsID,name=metricsNAME,var=varname)
	return(out)
}
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
### Calculate Dates given start date and hour add
#
# Input: current date list date<-list(y,m,d,h), a timestep and units of the
#	 the timestep ("hour" or "day")
#
#
# Output: date list of new time
#
#
# Options: verbose option to write out extra information from function
#
# NOTE:
#
###
datecalc<-function(date,dt,units,verbose=F)
  {
      if(units == "hour"){
	rdate<-mdy.date(month=as.numeric(date$m), day=as.numeric(date$d), year=as.numeric(date$y))
	h<-as.numeric(date$h)
	dtd<-(h/24)+(dt/24)
	rdate<-rdate+dtd
	h<-round((((h/24)+(dt/24))-floor((h/24)+(dt/24)))*24)
	dstr<-date.mmddyyyy(rdate)
	ch<-unlist(strsplit(dstr,"/"))
	y<-as.numeric(ch[3])
	m<-as.numeric(ch[1])
	d<-as.numeric(ch[2])
	if(verbose){writeLines(paste("Date ",date$y,date$m,date$d,date$h," plus ",dt,units,"--> converts to",y,m,d,h),con = stdout())}
	date<-list(y=y,m=m,d=d,h=h)
      }
      if(units == "day") {
	rdate<-mdy.date(month=as.numeric(date$m), day=as.numeric(date$d), year=as.numeric(date$y))+dt
	dstr<-date.mmddyyyy(rdate)
	ch<-unlist(strsplit(dstr,"/"))
	y<-as.numeric(ch[3])
	m<-as.numeric(ch[1])
	d<-as.numeric(ch[2])
	h<-as.numeric(date$h)
      }
   return(y,m,d,h)
  }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
### Leap Year Caculator
#
# Input: Year
#
# Output: 28 or 29 depending on leap year query
#
#
# Options: none
#
# NOTE:
#
###
# Simple leap year function
leapy<-function(y) {
   ## Leap Year Calc
   c1<-y/4	; c1i<-floor(c1)    
   c2<-y/100	; c2i<-floor(c2)
   c3<-y/400	; c3i<-floor(c3)
   ly=28
   if( ((c1 == c1i) & (c2 !=c2i)) || (c3 == c3i) ) {
     ly=29
   }
   return(ly)
}
#####--------------------------		END OF FUNCTION 	--------------------------------------####
##########################################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  MySQL Query  Function 
#
# Input: Standard MySQL query string (query) (e.g. query<-"SELECT stat_id from stations where state='NC' " )
#   also, the maximum number of records (maxrec). Setting maxrec to a lower number will increase the speed
#   of the connection and retrieval of the data. Database (dbase), password (passwd)
#   
# Output: A data frames with all data from query criterion. Columns= variables, Rows=records
#   
#
# Options: The maximum record (maxrec) is an option. The default is set to a resonably low value (100,000)
#   		login is optional, default is gilliam. Server (server) is also optional, default is snow
#
#
#   Query for station data 
#   "select v.metric_value, stat.lat, stat.lon from STATS v, stations stat  where v.query_id='qstatwint' and v.metric_id='mbias' and v.var_id='T'and stat.stat_id=v.stat_id" 
#    plotSpatialUS(sinfo,"MM5_2001 Surface Stations","mm52001.stat.pdf") 
#
# NOTE: 
#   
###
 	ametQuery<-function(query,mysql,get=1)
 {
  db<-dbDriver("MySQL")				# MySQL Database type
  con <-dbConnect(db,user=mysql$login,pass=mysql$passwd,host=mysql$server,dbname=mysql$dbase)		# Database connect

  for (q in 1:length(query)){
      rs<-dbSendQuery(con,query[q])	# Send query and place results in data frame
      writeLines(query[q])
  }
  if(get == 1){df<-fetch(rs,n=mysql$maxrec)}
  
  dbClearResult(rs)
  dbDisconnect(con)		# Database disconnect
  
  return(df)

 }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################



###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Takes surface related variables, filters bad data, converts 
###  wind componentes speed and direction.
#
# Input: data frame from mysql query including date,time,station id, ob network, T, U, V, Q 
#   	 for both the model and observations.
#   
#   
# Output:  List variable with massaged surface variables
#   
#
# Options: units ("mks" for metric or "std" for standard American units)
#   		
#     
#    
#     
#
# NOTE: The loc vector identifies which column belongs to specific variables.
#	loc[1] = column of date variable (e.g., 20010109), loc[2]= col. of time of day, loc[2]=col. of station id
#	loc[4 through 11] = col of ob. network that corresponds to model T, obs T, mod U, obs U, mod V, obs V, mod Q, obs Q
#
###
 massageTseries	<-function(data,loc=c(1,2,3,4,5,6,7,8,9,10,11,12),units="mks",
                           qcerror=c(15,15,10),iftseries=T,addrand=FALSE,
                           windlim=c(0.5,100),window=0)                         
{
##########################################################################################################

	day<- data[,loc[1]]
	timex<- data[,loc[2]]
	station <-data[,loc[3]]
	obnetwork<-data[,loc[4]]
	temp<-array(,c(length(timex),2))
	q<-array(0,c(length(timex),2))
	ws<-array(,c(length(timex),2))
	wd<-array(,c(length(timex),2))


	iso.date <- ISOdatetime(year=as.numeric(substr(day,1,4)), month=as.numeric(substr(day,5,6)), 
	                         day=as.numeric(substr(day,7,8)),  hour=as.numeric(timex), min=0, sec=0, tz="GMT")

#	Populate Surface Variable arrays
	temp[,1]<-data[,loc[5]]; temp[,2]<-avewindow(data[,loc[6]],window);
	ws[,1]  <-data[,loc[7]];   ws[,2]<-avewindow(data[,loc[8]],window);
	wd[,1]  <-data[,loc[9]];   wd[,2]<-avewindow(data[,loc[10]],window);
	q[,1]   <-data[,loc[11]];   q[,2]<-avewindow(data[,loc[12]],window);

	
	temp[,1]<-ifelse(abs(temp[,1]-temp[,2]) > qcerror[1],NA,temp[,1])
	temp[,2]<-ifelse(abs(temp[,1]-temp[,2]) > qcerror[1],NA,temp[,2])
	
	q[,1]<-ifelse(abs(q[,1]-q[,2])*1000     > qcerror[3],NA,q[,1])
	q[,2]<-ifelse(abs(q[,1]-q[,2])*1000     > qcerror[3],NA,q[,2])

	if (iftseries){}	# If for timeseries then preserve missing data (NA) elements, else if for batch statisitcs, remove missing values from arrays
	else{
	  dum<-array(,c(length(ws[,1]),4))
	  dum[,1]=ws[,1];dum[,2]=ws[,2];dum[,3]=wd[,1];dum[,4]=wd[,2];
	  dum[,2]<-ifelse(sqrt(dum[,2]^2 + dum[,4]^2) < windlim[1] | sqrt(dum[,1]^2 + dum[,3]^2) > windlim[2],NA,dum[,2])
	  dum[,1]<-ifelse(sqrt(dum[,2]^2 + dum[,4]^2) < windlim[1] | sqrt(dum[,1]^2 + dum[,3]^2) > windlim[2],NA,dum[,1])
	  ws<-array(,c(length(dum[,1]),2))
	  wd<-array(,c(length(dum[,1]),2))
	  ws[,1]=dum[,1];ws[,2]=dum[,2];wd[,1]=dum[,3];wd[,2]=dum[,4];
	}

	if(addrand) {
		tadd<-runif(length(temp[,2]),-0.5,0.5)
		temp[,2]=temp[,2]+tadd;
	}

	 tmpWSm<-ifelse(sqrt(ws[,1]^2 + wd[,1]^2) < windlim[2],sqrt(ws[,1]^2 + wd[,1]^2) ,NA)
	 tmpWSo<-ifelse(sqrt(ws[,2]^2 + wd[,2]^2) < windlim[2],sqrt(ws[,2]^2 + wd[,2]^2) ,NA)
	if(addrand) {
		wsadd<-runif(length(tmpWSo),-0.25,0.25)
		tmpWSo=tmpWSo+wsadd;
	}

	 tmpWDm<-180+(360/(2*pi))*atan2(ws[,1],wd[,1])
 	 tmpWDo<-180+(360/(2*pi))*atan2(ws[,2],wd[,2])
####################################################
# Public Friendly Conversions
#	Wind converion to Knots
  if (units == "std"){
	  ws[,1]<-tmpWSm*1.92;    ws[,2]<-tmpWSo*1.92;
	  wd[,1]<-tmpWDm;    wd[,2]<-tmpWDo;
	# 	Temp in Fareinheigt
	  temp<-(temp-273.14)*1.8+32
  }
####################################################
# UNCOMMENT FOR WIND IN m/s
	  ws[,1]<-tmpWSm;    ws[,2]<-tmpWSo;
	  wd[,1]<-tmpWDm;    wd[,2]<-tmpWDo;
####################################################
   tseries<-list(statid=station,obnet=obnetwork,date=iso.date,temp=temp,ws=ws,wd=wd,q=q,units=units)
   return(tseries)
}
##########################################################################################################
#####--------------------------		END OF FUNCTION 	--------------------------------------####
##########################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Station statistics computer. This function queries a set of station (point) data
#	then calculates individual model performance statistics for each station and
#	for all surface variables 
#
# Input: MySQL query (query) defining the station dataset, database (dbase) name where data 
#		is stored, database password (pass)   
#   
#   
#   
# Output: List containing matrix of model performance metrics for each station, station id,
#   		latitude of station, longitude of station.
#
# Options: maximum number of records allowed in database query (maxrec), default is 10000.
#   
    
#
# NOTE: This function is designed to work within the AMET framework for major surface variables
#	inlcuding temperature, wind speed and wind direction
# Example: 
#
#------------------------------------------------------------------------------------
   stationStatsSfc<-function(query,qstat, mysql, thresh=12,
                             wsmin=1.5, wsmax=20, t.test=F, conf.level=0.95, paired=F,
                             t.col=c(3,2), u.col=c(7,6), v.col=c(9,8), q.col=c(5,4), stat.col=1 )
 {


  conf.lim<-(1-conf.level)

#######################################################################################
#	Get station met data (data df) and Station meta data (statdat df)
#	also remove missing data and set up metrics array
#------------------------------------------------------------------------------------##
  data<-ametQuery(query,mysql)
  statdat<-ametQuery(qstat,mysql)		
  statget=list(id=statdat[,1],lat=statdat[,2],lon=statdat[,3],elev=statdat[,4])
  ns<-length(statget$id)

  #tmpd<-na.omit(data)		
  tmpd<-data
  metrics<-array(NA,dim=c(ns,17,4))

#------------------------------------------------------------------------------------##
#######################################################################################
#	Get all stations id's from station metadata table via query

#------------------------------------------------------------------------------------##
#######################################################################################
#	LOOP through station list and grab obs/model values for each, then calculate
#	station stats.
 c<-1
 s<-1
 writeLines(paste("Total number of observations in the domain is:",length(data[,1])))
 for (s in 1:ns ) {
    
    # Set up station id vector, corresponding index vector, and index-corresponding-to-current-id vector
    id<-tmpd[,stat.col]
    index<-1:length(tmpd[,stat.col])
    
    ini      <- index[id == statget$id[s]]

    iniT<- ini[ tmpd[ini,t.col[1]] > 200  &  tmpd[ini,t.col[1]] < 350 & !is.na(tmpd[ini,t.col[1]]) ]

    #############################################################
    #	Temperature Statistics
    obsT <-tmpd[iniT,t.col[1]]
    modT <-tmpd[iniT,t.col[2]]

    if (  length(na.omit(obsT * modT)) > thresh )  {
    #############################################################
      if( t.test) {
        tval<-t.test( obsT, modT, conf.level = conf.level, paired = paired)$p.value 
        if(tval > conf.lim) {   obsT = modT   }
      }
      #############################################################
      diff<-modT-obsT
 	    metrics[s,1,1]<-length(obsT) 				                 # Count
 	    metrics[s,2,1]<-cor(modT,obsT)			                 # Correlation
 	    metrics[s,3,1]<-ac(obsT,modT)			                   # Anomoly correlation
 	    metrics[s,4,1]<-var(diff,na.rm=T)			               # Variance
 	    metrics[s,5,1]<-sqrt(var(diff,na.rm=T))			         # Standard deviation
 	    metrics[s,6,1]<-rmserror(obsT, modT,na.rm=T)		     # RMSE
 	    metrics[s,7,1]<-magerror(obsT, modT,na.rm=T)		     # MAE
 	    metrics[s,8,1]<-mbias(obsT,modT,na.rm=T)		         # Mean bias
 	    metrics[s,9,1]<-mfbias(obsT, modT,na.rm=T)		       # Mean Fractional bias
 	    metrics[s,10,1]<-mnbias(obsT, modT,na.rm=T)		       # Mean Normalized Bias
 	    metrics[s,11,1]<-mngerror(obsT, modT,na.rm=T)		     # Mean Normalized Gross Error
 	    metrics[s,12,1]<-nmbias(obsT, modT,na.rm=T)		       # Normailized mean bias
 	    metrics[s,13,1]<-nmerror(obsT, modT,na.rm=T)		     # Normalized mean error
 	    metrics[s,14,1]<-max(modT,na.rm=T)-min(modT,na.rm=T) # DTR Model
 	    metrics[s,15,1]<-max(obsT,na.rm=T)-min(obsT,na.rm=T) # DTR Obs
 	    metrics[s,16,1]<-mean(modT,na.rm=T)	                 # DTR Model
 	    metrics[s,17,1]<-mean(obsT,na.rm=T)	                 # DTR Obs
 	  }
#############################################################
#	Wind Statistics
    obsWS <-sqrt( tmpd[ini,u.col[1]]^2 + tmpd[ini,v.col[1]]^2)
    iniW<- ini[obsWS > wsmin & obsWS < wsmax & !is.na(tmpd[ini,u.col[1]]) & !is.na(tmpd[ini,v.col[1]])]

    obsWS<-sqrt( tmpd[iniW,u.col[1]]^2 + tmpd[iniW,v.col[1]]^2)
    modWS<-sqrt( tmpd[iniW,u.col[2]]^2 + tmpd[iniW,v.col[2]]^2)

    obsWD<-180+(360/(2*pi))*atan2(tmpd[iniW,u.col[1]],tmpd[iniW,v.col[1]])
    modWD<-180+(360/(2*pi))*atan2(tmpd[iniW,u.col[2]],tmpd[iniW,v.col[2]])

    if (  length(na.omit(obsWS * modWS)) > thresh  )  {
 	    if( t.test) {
 	      tval<-t.test( obsWS, modWS, conf.level = conf.level, paired = paired)$p.value 
 	      if(tval > conf.lim) {   obsWS = modWS ;  obsWD = modWD   }
 	    }
 	    diff<-modWS-obsWS
 	    metrics[s,1,2]<-length(obsWS) 		# Count
 	    metrics[s,2,2]<-cor(modWS,obsWS)		# Correlation
 	    metrics[s,3,2]<-ac(obsWS,modWS)		# Anomoly correlation
 	    metrics[s,4,2]<-var(diff)			# Variance
 	    metrics[s,5,2]<-sqrt(var(diff))		# Standard deviation
 	    metrics[s,6,2]<-rmserror(obsWS, modWS)	# RMSE
 	    metrics[s,7,2]<-magerror(obsWS, modWS)	# MAE
 	    metrics[s,8,2]<-mbias(obsWS,modWS)		# Mean bias
 	    metrics[s,9,2]<-mfbias(obsWS, modWS)		# Mean Fractional bias
 	    metrics[s,10,2]<-mnbias(obsWS, modWS)		# Mean Normalized Bias
 	    metrics[s,11,2]<-mngerror(obsWS, modWS)	# Mean Normalized Gross Error	
 	    metrics[s,12,2]<-nmbias(obsWS, modWS)		# Normailized mean bias
 	    metrics[s,13,2]<-nmerror(obsWS, modWS)	# Normalized mean error	
 	    metrics[s,14,2]<-max(modWS,na.rm=T)-min(modWS,na.rm=T)	# DTR Model
 	    metrics[s,15,2]<-max(obsWS,na.rm=T)-min(obsWS,na.rm=T)	# DTR Obs
 	    metrics[s,16,2]<-mean(modWS,na.rm=T)	                    # Mean Mod Wind Speed
 	    metrics[s,17,2]<-mean(obsWS,na.rm=T)	                    # Mean Obs Wind Speed
    }
 	  if (  length(na.omit(obsWD * modWD)) > thresh  )  {
      diff<-modWD-obsWD
      a<-ifelse(diff > 180 , diff-360, diff)
 	    a<-ifelse(a< -180 , a+360, a)
 	    diff<-a
 	    obs<-runif(length(diff),min=0,max=0.001)
 	    mod<-a

 	    metrics[s,1,3]<-length(obsWD) 		# Count
 	    metrics[s,2,3]<-cor(modWD,obsWD)	# Correlation 
 	    metrics[s,3,3]<-ac(obsWD,modWD)		# Anomoly correlation
 	    metrics[s,4,3]<-var(diff)		# Variance
 	    metrics[s,5,3]<-sqrt(var(diff))		# Standard deviation
 	    metrics[s,6,3]<-rmserror(obsWD, modWD)	# RMSE	
 	    metrics[s,7,3]<-magerror(obsWD, modWD)	# MAE
 	    metrics[s,8,3]<-mbias(obsWD,modWD)	# Mean bias
 	    metrics[s,9,3]<-mfbias(obsWD, modWD)	# Mean Fractional bias
 	    metrics[s,10,3]<-mnbias(obsWD, modWD)	# Mean Normalized Bias
 	    metrics[s,11,3]<-mngerror(obsWD, modWD)	# Mean Normalized Gross Error	
 	    metrics[s,12,3]<-nmbias(obsWD, modWD)	# Normailized mean bias
 	    metrics[s,13,3]<-nmerror(obsWD, modWD)	# Normalized mean error	
 	    metrics[s,14,3]<-max(mod,na.rm=TRUE)	# Max difference
 	    metrics[s,15,3]<-min(mod,na.rm=TRUE)	# Min difference
 	    metrics[s,16,3]<-mean(mod,na.rm=TRUE)	# Mean Difference
 	    metrics[s,17,3]<-mean(mod,na.rm=TRUE)	# Min difference
 	  }
    #############################################################
    #	Specific Humidity Statistics
    iniQ<- ini[tmpd[ini,q.col[1]]*1000 > 0  &  tmpd[ini,q.col[1]]*1000 < 50 & 
           !is.na(tmpd[ini,q.col[1]]) ]
    obsQ<-tmpd[iniQ,q.col[1]]*1000
    modQ<-tmpd[iniQ,q.col[2]]*1000

    if (  length(na.omit(obsQ * modQ)) > thresh )  { 	
      #############################################################
      if( t.test) {
        tval<-t.test( obsQ, modQ, conf.level = conf.level, paired = paired)$p.value 
        if(tval > conf.lim) {   obsQ = modQ  }
      }
      #############################################################
      diff<-modQ-obsQ
      metrics[s,1,4]<-length(obsQ) 		# Count
      metrics[s,2,4]<-cor(modQ,obsQ)		# Correlation
      metrics[s,3,4]<-ac(obsQ,modQ)		# Anomoly correlation
      metrics[s,4,4]<-var(diff)		# Variance
      metrics[s,5,4]<-sqrt(var(diff))	# Standard deviation
      metrics[s,6,4]<-rmserror(obsQ, modQ)	# RMSE
      metrics[s,7,4]<-magerror(obsQ, modQ)	# MAE
      metrics[s,8,4]<-mbias(obsQ,modQ)	# Mean bias
      metrics[s,9,4]<-mfbias(obsQ, modQ)	# Mean Fractional bias
      metrics[s,10,4]<-mnbias(obsQ, modQ)	# Mean Normalized Bias
      metrics[s,11,4]<-mngerror(obsQ, modQ)	# Mean Normalized Gross Error
      metrics[s,12,4]<-nmbias(obsQ, modQ)	# Normailized mean bias
      metrics[s,13,4]<-nmerror(obsQ, modQ)	# Normalized mean error
      metrics[s,14,4]<-max(modQ,na.rm=TRUE)-max(obsQ,na.rm=TRUE)	# Max difference
      metrics[s,15,4]<-min(modQ,na.rm=TRUE)-min(obsQ,na.rm=TRUE)	# Min difference
      metrics[s,14,4]<-max(modQ,na.rm=T)-min(modQ,na.rm=T)	# DTR Model
      metrics[s,15,4]<-max(obsQ,na.rm=T)-min(obsQ,na.rm=T)	# DTR Obs
      metrics[s,16,4]<-mean(modQ,na.rm=T)	                    # Mean Mod Wind Speed
      metrics[s,17,4]<-mean(obsQ,na.rm=T)	                    # Mean Obs Wind Speed
    }
    writeLines(paste("Station ID ",statget$id[s]," has been processed, this is ",s,"out of ",ns," total stations"))
    point<-ifelse(id == statget$id[s],T,F)
    tmpd<-tmpd[!point,]
    rm(obsT,modT,obsWS,modWS,obsWD,modWD,obsU,modU,obsV,modV,obsQ,modQ)
  }
  returnlist<-list(metrics=metrics,stationID=statget$id,lat=statget$lat,lon=statget$lon)
  return(returnlist)
}
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################
###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  This function extracts surface data from the database, partitions by site, then filters
#    into intra-day, diurnal and synoptic components. The observed and modeled timeseries
#    are compared in terms of variablity and correlation
#
# Input: MySQL query (query) defining the station dataset, database (dbase) name where data 
#		is stored, database password (pass)   
#   
# Output: List with correlation and variability of model and obs filtered timeseries.
#
#------------------------------------------------------------------------------------
   station.ts.filter<-function(query,qstat, mysql, thresh=12,
                             wsmin=1.5, wsmax=20, t.test=F, conf.level=0.95, paired=F,
                             t.col=c(3,2), u.col=c(7,6), v.col=c(9,8), q.col=c(5,4), stat.col=1 )
 {


  conf.lim<-(1-conf.level)

#######################################################################################
#	Get station met data (data df) and Station meta data (statdat df)
#	also remove missing data and set up metrics array
#------------------------------------------------------------------------------------##
  data<-ametQuery(query,mysql)
  statdat<-ametQuery(qstat,mysql)		
  statget=list(id=statdat[,1],lat=statdat[,2],lon=statdat[,3],elev=statdat[,4])
  ns<-length(statget$id)

  #tmpd<-na.omit(data)		
  tmpd<-data
  metrics<-array(NA,dim=c(ns,9,3))

#------------------------------------------------------------------------------------##
#######################################################################################
#	Get all stations id's from station metadata table via query

#------------------------------------------------------------------------------------##
#######################################################################################
#	LOOP through station list and grab obs/model values for each, then calculate
#	station stats.
 c<-1
 s<-1
 writeLines(paste("Total number of observations in the domain is:",length(data[,1])))
 for (s in 1:ns ) {
    # Set up station id vector, corresponding index vector, and index-corresponding-to-current-id vector
    id<-tmpd[,stat.col]
    index<-1:length(tmpd[,stat.col])
    
    ini      <- index[id == statget$id[s]]

    iniT<- ini[ tmpd[ini,t.col[1]] > 200  &  tmpd[ini,t.col[1]] < 350 & !is.na(tmpd[ini,t.col[1]]) ]
    #############################################################
    if (  length(iniT) > 0 )  {
    	
    #############################################################
    #	Temperature Statistics
    obsT <-tmpd[iniT,t.col[1]]
    modT <-tmpd[iniT,t.col[2]]

        ts_diurnal_obs	<-kz.filter(obsT, 3, 3,na.edge=F)
        ts_synoptic_obs	<-kz.filter(obsT, 13, 5,na.edge=F)
        ts_seas_obs		<-kz.filter(obsT, 505, 3,na.edge=F)
        ts_intraday_obs	<-obsT - ts_diurnal_obs
        ts_diurnal_obs	<-ts_diurnal_obs -  ts_synoptic_obs
        ts_synoptic_obs	<-ts_synoptic_obs - ts_seas_obs

        ts_diurnal_mod	<-kz.filter(modT, 3, 3,na.edge=F)
        ts_synoptic_mod	<-kz.filter(modT, 13, 5,na.edge=F)
        ts_seas_mod		<-kz.filter(modT, 505, 3,na.edge=F)
        ts_intraday_mod	<-modT - ts_diurnal_mod
        ts_diurnal_mod	<-ts_diurnal_mod -  ts_synoptic_mod
        ts_synoptic_mod	<-ts_synoptic_mod - ts_seas_mod

        metrics[s,1,1]<-var(ts_intraday_obs,na.rm=T)			# Variance
 	metrics[s,2,1]<-var(ts_diurnal_obs,na.rm=T)			# Variance
 	metrics[s,3,1]<-var(ts_synoptic_obs,na.rm=T)			# Variance
 	metrics[s,4,1]<-var(ts_intraday_mod,na.rm=T)			# Variance
 	metrics[s,5,1]<-var(ts_diurnal_mod,na.rm=T)			# Variance
 	metrics[s,6,1]<-var(ts_synoptic_mod,na.rm=T)			# Variance
 	metrics[s,7,1]<-cor(ts_intraday_mod, ts_intraday_obs)	# Variance
 	metrics[s,8,1]<-cor(ts_diurnal_mod, ts_diurnal_obs)	# Variance
 	metrics[s,9,1]<-cor(ts_synoptic_mod, ts_synoptic_obs)	# Variance
        writeLines("Temperature")
     }
    
#############################################################
#	Wind Statistics
    obsWS <-sqrt( tmpd[ini,u.col[1]]^2 + tmpd[ini,v.col[1]]^2)
    iniW<- ini[obsWS > wsmin & obsWS < wsmax & !is.na(tmpd[ini,u.col[1]]) & !is.na(tmpd[ini,v.col[1]])]

#############################################################
    if (length(iniW) > thresh){
#############################################################

        obsWS<-sqrt( tmpd[iniW,u.col[1]]^2 + tmpd[iniW,v.col[1]]^2)
        modWS<-sqrt( tmpd[iniW,u.col[2]]^2 + tmpd[iniW,v.col[2]]^2)

        ts_diurnal_obs	<-kz.filter(obsWS, 3, 3,na.edge=F)
        ts_synoptic_obs	<-kz.filter(obsWS, 13, 5,na.edge=F)
        ts_seas_obs		<-kz.filter(obsWS, 505, 3,na.edge=F)
        ts_intraday_obs	<-obsWS - ts_diurnal_obs
        ts_diurnal_obs	<-ts_diurnal_obs -  ts_synoptic_obs
        ts_synoptic_obs	<-ts_synoptic_obs - ts_seas_obs

        ts_diurnal_mod	<-kz.filter(modWS, 3, 3,na.edge=F)
        ts_synoptic_mod	<-kz.filter(modWS, 13, 5,na.edge=F)
        ts_seas_mod		<-kz.filter(modWS, 505, 3,na.edge=F)
        ts_intraday_mod	<-modWS - ts_diurnal_mod
        ts_diurnal_mod	<-ts_diurnal_mod -  ts_synoptic_mod
        ts_synoptic_mod	<-ts_synoptic_mod - ts_seas_mod
        #############################################################
     	metrics[s,1,2]<-var(ts_intraday_obs,na.rm=T)			# Variance
 	metrics[s,2,2]<-var(ts_diurnal_obs,na.rm=T)			# Variance
 	metrics[s,3,2]<-var(ts_synoptic_obs,na.rm=T)			# Variance
 	metrics[s,4,2]<-var(ts_intraday_mod,na.rm=T)			# Variance
 	metrics[s,5,2]<-var(ts_diurnal_mod,na.rm=T)			# Variance
 	metrics[s,6,2]<-var(ts_synoptic_mod,na.rm=T)			# Variance	
 	metrics[s,7,2]<-cor(ts_intraday_mod, ts_intraday_obs)	# Variance
 	metrics[s,8,2]<-cor(ts_diurnal_mod, ts_diurnal_obs)	# Variance
 	metrics[s,9,2]<-cor(ts_synoptic_mod, ts_synoptic_obs)	# Variance
        writeLines("Wind Speed")
    }
    #############################################################
    #	Specific Humidity Statistics
    iniQ<- ini[tmpd[ini,q.col[1]]*1000 > 0  &  tmpd[ini,q.col[1]]*1000 < 50 & 
           !is.na(tmpd[ini,q.col[1]]) ]

    obsQ<-tmpd[iniQ,q.col[1]]*1000
    modQ<-tmpd[iniQ,q.col[2]]*1000
    #############################################################
    if (  length(na.omit(obsQ * modQ)) > thresh )  {
    	  	
        ts_diurnal_obs	<-kz.filter(obsQ, 3, 3,na.edge=F)
        ts_synoptic_obs	<-kz.filter(obsQ, 13, 5,na.edge=F)
        ts_seas_obs	<-kz.filter(obsQ, 505, 3,na.edge=F)
        ts_intraday_obs	<-obsQ - ts_diurnal_obs
        ts_diurnal_obs	<-ts_diurnal_obs -  ts_synoptic_obs
        ts_synoptic_obs	<-ts_synoptic_obs - ts_seas_obs

        ts_diurnal_mod	<-kz.filter(modQ, 3, 3,na.edge=F)
        ts_synoptic_mod	<-kz.filter(modQ, 13, 5,na.edge=F)
        ts_seas_mod	<-kz.filter(modQ, 505, 3,na.edge=F)
        ts_intraday_mod	<-modQ - ts_diurnal_mod
        ts_diurnal_mod	<-ts_diurnal_mod -  ts_synoptic_mod
        ts_synoptic_mod	<-ts_synoptic_mod - ts_seas_mod
        #############################################################    	
 	metrics[s,1,3]<-var(ts_intraday_obs,na.rm=T)		# Variance
 	metrics[s,2,3]<-var(ts_diurnal_obs,na.rm=T)		# Variance
 	metrics[s,3,3]<-var(ts_synoptic_obs,na.rm=T)		# Variance
 	metrics[s,4,3]<-var(ts_intraday_mod,na.rm=T)		# Variance
 	metrics[s,5,3]<-var(ts_diurnal_mod,na.rm=T)		# Variance
 	metrics[s,6,3]<-var(ts_synoptic_mod,na.rm=T)		# Variance
 	metrics[s,7,3]<-cor(ts_intraday_mod, ts_intraday_obs)	# Variance
 	metrics[s,8,3]<-cor(ts_diurnal_mod, ts_diurnal_obs)	# Variance
 	metrics[s,9,3]<-cor(ts_synoptic_mod, ts_synoptic_obs)	# Variance
        writeLines("Mixing Ratio")
     }     
     writeLines(paste("Station ID ",statget$id[s]," has been processed, this is ",s,"out of ",ns," total stations"))
     point<-ifelse(id == statget$id[s],T,F)
     tmpd<-tmpd[!point,]
     rm(obsT,modT,obsWS,modWS,obsWD,modWD,obsU,modU,obsV,modV,obsQ,modQ)

  }
 returnlist<-list(metrics=metrics,stationID=statget$id,lat=statget$lat,lon=statget$lon)
 return(returnlist)
 }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################

####################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
### File Compression Check 
#
# Input: file to be checked
#	 
#
#
# Output: New file name, if file was compressed or uncompressed and
#	 
#
# Options:
#
#
#
#
# NOTE:
###
 	compressedcheck<-function(file,action,gunzip="/usr/bin/gunzip",gzip="/usr/bin/gzip")
 {
    	
    	wrd1<-unlist(strsplit(file,"/"))
	fpart<-wrd1[length(wrd1)]
    	wrd2<-unlist(strsplit(fpart,""))
	gzpart<-paste(wrd2[length(wrd2)-1],wrd2[length(wrd2)],sep="")
	
	nw<-length(wrd1)-1;dir<-""
	for(i in 1:nw) { dir<-paste(dir,"/",wrd1[i],sep="") }
	newfile<-file
	fullnewfile<-file

	if(action == "none"){
		return()
	}
	
	if(gzpart == "gz" & action == "gunzip"){
	    system(paste(gunzip," ",dir,"/",fpart,sep=""))
	    writeLines(paste(gunzip," ",dir,"/",fpart,sep=""))
	    nngz<-length(wrd2)-3;nf<-""
	    for(i in 1:nngz) { nf<-paste(nf,wrd2[i],sep="") }
	    newfile<-paste(dir,"/",nf,sep="")
	}
	if(gzpart != "gz" & action == "gzip"){
	    newfile<-paste(dir,"/",fpart,".gz",sep="")
	    system(paste(gzip," ",dir,"/",fpart,sep=""))
	    writeLines(paste(gzip," ",dir,"/",fpart,sep=""))
	}

    return(newfile)
 }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Computes Cummulative NPA and Model Precipitation from standard AMET
###  style R datafiles
#
# Input: Date list with year (date$ys/date$ye), month(date$ms/date$me), day(date$ds/date$de) start and end
#   		archive directory where R precipitation files are stored as well as the project identifer.
#
#
# Output:  Plot of precip total difference between time periods
#
#
# Options:
# NOTE:
#
###
 	acumprecip<-function(date,id=c("sst","nosst"),
	                  savedir="/home/amet/archive/npa/R-save",
	                  nummod=1,maxallow=50,minallow=0.1,
			  fcast=F,initutc=0,fcasthrlim=c(0,24))
 {

  ly<-leapy(date$ys)
  nd=c(31,ly,31,30,31,30,31,31,30,31,30,31);	#Array that provides the number of days for each month (used in some date calculations)

  d<-date$ds
  m<-date$ms
  y<-date$ys
  h<-date$hs
  t<-1
  cumprecip<-0
  #----------------------------------------------------------------------------------
  # Begin loop over specified period. Loop is terminated when y,m,d = date$ye/$me/$de
  filecount<-0
  ini<-1;nodatacount<-0;
  while (t > 0){
    skip<-F
  #---------------------------------------------------------------------------------------------
  # Define files to process given the data file type (hourly, daily, in future possibly monthly)	    
    if(fcast){
      a<-system(paste("ls ",savedir,"/npa.",id[1],".",dform(y),dform(m),dform(d),dform(h),".",dform(initutc),"*",sep=""),intern=TRUE,ignore.stderr =T)
      if(length(a) == 0) {
         file<-"nonthin"
      }
      else {
       for(f in 1:length(a)){
        b<-unlist(strsplit(a[f],split="/"))
	c<-unlist(strsplit(b[length(b)],split="\\."))
	fcasthr<-c[5]
	if(fcasthr >= fcasthrlim[1] & fcasthr <= fcasthrlim[2]){
	  file<-a[f]
	}
	else {
	    skip<-T
	    file<-""
	}
       }
      }
    }
    else {
      file<-paste(savedir,"/npa.",id[1],".",dform(y),dform(m),dform(d),dform(h),".RData",sep="")
    }
  #---------------------------------------------------------------------------------------------
  # Check to see if files exist, if so open and get precip data, then add to existing sum of precip
    if(file.exists(file) & !skip ){
	#-------------------------------------------------------
	# Precip File 1
	filecount<-filecount+1
   	writeLines(paste("File ",filecount,"exists:",file))
	load(file)

	if (ini == 1){
  	  dims<-dim(precip$obs)
  	  ny<-dims[1];nx<-dims[2];				  # Get dimensions nx,ny
	  obs<-array(0,c(ny,nx,2))
	  mod<-array(0,c(ny,nx,2))
	  ini<-0
	}
      if(dim(precip$mod)[1] == dim(obs)[1]) {
	precip$mod<-ifelse(precip$mod > maxallow | precip$mod < minallow,NA,precip$mod)  # Throw out model precip values that exceed the period maximum (mm)
	precip$obs<-ifelse(precip$obs > maxallow | precip$obs < minallow,NA,precip$obs)  # Throw out observed precip values that exceed the period maximum (mm)

	obs[,,1]<-ifelse(precip$obs<maxallow,precip$obs,NA);			# Construct obs 3-d array with cummulative precip in layer 1 (e.g. [,,1]) and new precip array in layer 2
	mod[,,1]<-ifelse(precip$obs<maxallow,precip$mod,NA);			# Construct obs 3-d array with cummulative precip in layer 1 (e.g. [,,1]) and new precip array in layer 2
        mod[,,2]<-colSums(aperm(mod,c(3,1,2)),na.rm=TRUE)
        obs[,,2]<-colSums(aperm(obs,c(3,1,2)),na.rm=TRUE)

      }	
     
     }

    #-------------------------------------------------------
    # When end date is approached, set t < 0 which will end loop
    if (d == date$de & m == date$me & y == date$ye & h ==date$he) {t<--10}
    #-------------------------------------------------------
    curdate<-list(y=y,m=m,d=d,h=h)
    #-------------------------------------------------------
    # Caculate next time for following iteration
    dnext<-datecalc(curdate,1,"hour")
    h<-dnext$h
    d<-dnext$d
    m<-dnext$m
    y<-dnext$y
    #-------------------------------------------------------
    
    t<-t+1
  }
  if(ini == 0){
    obsx<-obs[,,2]
    modx<-mod[,,2]
  }
  else { return(F)	}
  #-----------------------------------------------
  # Construct AMET style cummulative precip list (Used by NPA plotting function)
  cumprecip<-list(obs=obsx,mod1=modx,lat=precip$lat,lon=precip$lon,missing=nodatacount)

  return(cumprecip)

 }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################
###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
### Computes a variety of statistics provided a stat specification
#
# Input: variable array and type of statistics
#	 
#
#
# Output: statistics
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
 	compute_stat<-function(var,stat="mean")
 {
    if(stat == "mean"){
      varo<-mean(var,na.rm=TRUE)
    }

    if(stat == "min"){
      varo<-min(var,na.rm=TRUE)
    }

    if(stat == "max"){
      varo<-max(var,na.rm=TRUE)
    }
    return(varo)
 }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
#   This script calculates great-circle distances between 
#   the two points – that is, the shortest distance over the earth’s
#   surface – using the ‘Haversine’ formula.
#
# It assumes a spherical earth, ignoring ellipsoidal effects – which is 
# accurate enough* for most purposes… – giving an ‘as-the-crow-flies’ distance between the two points (ignoring any hills!).
#
# Input: lat and lon of two points
#
# Output: distance between lat-lon points in km
#
# Options: none
# NOTE:
#
###

   dist.lat.lon <-function(lat1, lat2, lon1, lon2 ) {
         
        # Constants 
        deg2rad = pi/180
        R = 6371
        
        
        dlat = (lat2 - lat1 ) * deg2rad
        dlon = (lon2 - lon1 ) * deg2rad
        
        a = ( sin(dlat/2) * sin(dlat/2) )+ (cos( lat1 * deg2rad) * cos( lat2 * deg2rad ) * sin(dlon/2)*sin(dlon/2) )
        c = 2 * atan2( sqrt(a), sqrt(1-a) )
        d = R * c
     return(d)
   }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##

##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
### Implement the K-Z (Kolmogorov-Zurbenko) filter.
#
# Input:
#   x is a vector containing the time series to be filtered
#   integer "m" represents the size of the moving average window, m > 2
#   integer "k" represents the number of times this filter is applied
# Output:
#   returns as a vector a smoothed time series, using a KZ filter.
#
# Options:
#   na.edge (T or F): Determines how the filter treats the values at the
#     beginning and end ("edges") of the time series.  If T, the edge
#     values as left as missing; this is the recommended (and therefore
#     the default) setting.  If F, the edges are estimated using
#     interpolation techniques similar to those used for missing values
#     in the series.
#   na.middle (T or F): Determines how the filter treats missing values
#     within the time series.  If T, the missing values will remain, and
#     all values which the filter attempts to calculate based on the
#     missing values will also be missing.  If F (default setting), the
#     filter will increase the weights given to the surrounding
#     non-missing values in the filtering process.
#
# NOTE: This function uses the "filter" function, which is part of the
#   "ts" package in R.
###
kz.filter <- function(x, m, k, na.edge=T, na.middle=F){

  ##### Check user input for consistency or unusual options or inputs.
  if ( m <= 2)
    stop("m must be an integer greater than 2")

  if ( k <= 0)
    stop("k must be an integer greater than 0")

  if (m %% 2 == 0)
    warning("Because m is even, filtering window will reach slightly further into future values than past ones")
  
  if (na.middle==T && na.edge==F){
    na.edge <- T
    warning("na.middle=T overrides; na.edge is now set to T")
  }
  #####


  ##### If na.edge=T and na.middle=T, or if na.edge=T and there are no
  ##### missing values in the series, then use the filter method in
  ##### the "ts" package.
  if ( na.edge==T && (na.middle==T || sum(is.na(x))==0) ){

    #Specify the weights for the filter function.
    weights <- rep(1,m)/m

    #Initialize the vector.
    y <- x

    #Apply the filter k times.
    for (i in 1:k)
      y <- as.vector(filter(y, filter=weights, sides=2, method="conv", circular=F))

    return(y)
  }
  #####


  
  ##### If na.edge=F, and/or there are missing values in the time
  ##### series which the user wants to smooth, we have to implement a
  ##### "custom-built" method.

  ### Handle odd vs. even window size differently.
  
  # If window size is odd, there are q values to both the left and right
  # of the chosen position in the averaging window, i.e. m=(2*q)+1
  if (m %% 2 != 0){
    q2 <- (m-1)/2  #Number of "future" values to include in window
    q1 <- q2       #Number of "past" values to include in window
  }
  
  # If window size is even, there cannot be equal numbers of values to
  # both the left and right of the chosen position in the averaging
  # window.  For compatibility with the "filter" function in "ts" package,
  # this filter window will include one more value from the "future" than
  # from the "past".
  else{
    q2 <- m/2      #Number of "future" values to include in window
    q1 <- (m/2)-1  #Number of "past" values to include in window
  }
  ###


  ### Buffer time series edges with missing values.
  # Put missing values at the ends so that the the averaging window can
  # extend  beyond the first and last elements in the series.
  y <- c(rep(NA, q1), x, rep(NA, q2))
  ###
  
  ### If na.edge=F && na.middle=F, we will try provide values at edges
  ### of the time series, as well as near missing values in the time
  ### series.  Smoothing in these areas may not be very accurate.
  if ( na.edge==F && na.middle==F ){
    res <- rep(NA, length(y))
    for (i in 1:k){
      for ( j in (1:length(x))+q1 )
        res[j] <- mean(y[(j-q1):(j+q2)], na.rm=T)
      y <- res
    }
    return(y[(1:length(x))+q1])
  }
  ###
  
  ### If na.edge=T && na.middle=F, there will be missing values at
  ### the edges, but not in the middle of the time series.
  else if ( na.edge==T && na.middle==F ){
    res <- rep(NA, length(y))
    for (i in 1:k){
      length.y <- length(y)    
      for ( j in (1+(i*q1)):(length.y-(i*q2)) )
        res[j] <- mean(y[(j-q1):(j+q2)], na.rm=T)
      y <- res
    }
    # The values on the edges are replaced with NA, because there were
    # not enough neighboring values to get a good estimate for them.
    y[1:(q1+(k*q1))] <- NA
    y[(length.y-(k*q2)-q2+1):length.y] <- NA
    
    return( y[(q1+1):(length.y-q2)] )
#    return( y[(q1+(k*q1)+1):(length.y-(k*q2)-q2)] )
  }
  ###
}



### Find the cutoff frequency that corresponds with a particular choice
### of m (size of moving average window) and k (number of times filter is
### applied).
#
# Input:
#   integer m represents the size of the moving average window
#   integer k represents the number of times this filter is applied
#   alpha represents the squared modulus of the transfer function.  The
#     K-Z filter is implemented in the literature with alpha=0.5, so the
#     function defaults to this value.
# Output:
#   returns approximate cutoff frequency specified filter
#
# Note: This is based on an approximation of the Dirichlet kernel using
# a 2 term-only expansion of the Maclaurin series for sin(x).  This is
# the same approximation used in Rao et al, Bulletin of the American
# Meteorology Society, Vol. 78, pg. 2156, equations (3) and (4).
###
find.kz.cutoff.freq <- function(m, k, alpha=0.5){
  tmp <- (alpha)^(1/(2*k))
  f <- (sqrt(6)/pi) * sqrt( (1-tmp) / ((m*m)-tmp) )
  return(f)
}



### Find values of m (moving average window) and k (number of times filter
### is applied) which give a cutoff frequency approximately (given a
### certain precision) equal to that specified by the user.
#
# Input:
#  f is cutoff frequency
#  prec specifies how close the approximation should be
#  m gives a range of possible sizes for the moving average window (should
#    have m > 2), but the algorithm does not specifically require this
#  k gives a range of possible number of times the filter should be applied
#
# Output:
#  function returns a list of possible values of m and k, and their
#    corresponding cutoff frequencies, such the cutoff frequencies are
#    within prec of user-specified cutoff frequency
###
find.kz.params.by.cutoff.freq <- function(f, prec=0.001, k=seq(1,25), m=seq(3,25)){
  x <- data.frame( m=sort(rep(m, length(k))), k=rep(k, length(m)) , f=rep(0, length(k)*length(m)) )
  x$f <- find.kz.cutoff.freq(x$m, x$k)

  #Find cutoff freq in the range [f-prec, f+prec].
  keep.indic <- x$f >= (f-prec) & x$f <= (f+prec)
  y <- x[keep.indic,]

  #Sort by cutoff freq
  order.indic <- order(y$f)
  return(y[order.indic,])
}
