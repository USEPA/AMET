#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#		AMET (Atmospheric Model Evaluation Tool)                            #
#                                                                       #
#			Daily Metric Plots                                                #
#		        MET_daily_barplot.R                                         #
#                                                                       #
#                                                                       #
#  This R script is used by the AMET tool to extract a dataset spanning	#
#  several dates via user-contructed query. Once data is queried, 	    #
#  several statistical bar plots are automatically generated            #
#                                                                       #
#	Version: 	1.1                                                         #
#	Date:		Dec. 6 2007                                                   #
#	Contributors:	Neil Davis                                              #
#                                                                       #
# Version 1.2, May 8, 2013, Rob Gilliam                                 #
# Updates: -Added logic to skip days where no data exists to aviod fail #
#          -Print of day to screen as loop through daily computations   #
#          -Changed "Mean Bias" to "Bias" in plot label                 #
#          -Cleaned code                                                #
#                                                                       #            
#                                                                       #
#########################################################################
#:::::::::::::::::::::::::::::::::::::::::::::
#	Load required modules
  libload <- require(RMySQL)
  if(!libload){stop("Could not load required Package RMySQL")}

########################################################
#    Initialize AMET Directory Structure Via Env. Vars
#    AND Load required function and conf. files
#########################################################

## get some environmental variables and setup some directories
  term<-Sys.getenv("TERM") 				# are we using via the web or not?
  ametbase<-Sys.getenv("AMETBASE") 			# base directory of AMET
  ametR<-paste(ametbase,"/R",sep="")                    # R directory
  ametRinput <- Sys.getenv("AMETRINPUT")                # input file for this script

  # Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
  # and not specified via AMET_OUT, then set figdir to the current directory
  if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")	}
  if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"			}

  ## source some configuration files, AMET libs, and input
  source(paste(ametbase,"/configure/amet-config.R",sep=""))
  source (paste(ametR,"/MET_amet.misc-lib.R",sep=""))  	# Miscellanous AMET R-functions file
  source (paste(ametR,"/MET_amet.plot-lib.R",sep=""))  	# AMET Plot functions file
  source (paste(ametR,"/MET_amet.stats-lib.R",sep=""))  # AMET Plot functions file
  source (ametRinput)	                                # Anaysis configuration/input file

  plotopts	<-list(plotfmt=plotfmt)

#####################################################################
# MAIN PROGRAM
# 1. Query for data over requested time period (Jan1-Jan29 2005)
# 2. Determine number of dates included in study
# 3. Loop through dates in study
# 4. Build correlation, bias & RMSE vectors to be plotted
# 5. Plot Error bar plots
#####################################################################

#################
# QUERY DATABASE
#################
 # Setup/Config. meteorological variable names/id's, and set max records
 mysql		<-list(server=server,dbase=dbase,login=login,passwd=passwd,maxrec=maxrec)
 varsName	<-c("Temperature (2m)","Specific Humidity (2m)","Wind Speed (10m)","Wind Direction (deg.)")
 varid		<-c("T","Q","WS","WD")
 varxstr	<-paste("SELECT DATE_FORMAT(ob_date,'%Y%m%d'),HOUR(ob_time),d.stat_id,s.ob_network,d.T_mod,d.T_ob, d.Q_mod,d.WVMR_ob, d.U_mod,d.U_ob, d.V_mod,d.V_ob")
 query		<-paste(varxstr," FROM ",project,"_surface d, stations s WHERE  s.stat_id=d.stat_id ",querystr,sep="")							# Surface data table in evaluation database

 data <- ametQuery(query,mysql)

 ## test to see if query returned anything
 if (length(data) == 0) {

   ## error the queried returned nothing
   stop(
	     paste('',
	           '**********************************************************************************',
	           'NO DATA WAS FOUND FOR THIS QUERY: Please change some of the criteria and try again',
	           '**********************************************************************************',sep="\n")
	     )
 }
##################
# FIND DATE RANGE
##################
 numDays <- length(unique(data[,1]))
 dates <- format(seq.Date(from=as.Date(data[1,1],format="%Y%m%d"),length.out=numDays,by="day"),'%Y%m%d')
 locs <-c(1,2,3,4,5,6,9,10,11,12,7,8)
 
 # Create Vectors to hold working data
 corData <- array(NA,c(numDays,4))
 colnames(corData) <- c("T","Q","WS","WD")
 biasData <- array(NA,c(numDays,4))
 colnames(biasData) <- c("T","Q","WS","WD")
 RMSEData <- array(NA,c(numDays,4))
 colnames(RMSEData) <- c("T","Q","WS","WD")
 
 # Loop through dates to generate data
 for(i in 1:numDays){
  writeLines(paste("Computing stats for day:",dates[i]))
 	dayLoc <- which(data[,1] == dates[i]) # Find rows which contain data for given date
 	if(length(dayLoc) == 0) { 
 	  writeLines(paste("No data will skip:",dates[i])) 
 	  next 
 	}
 	dayData <- massageTseries(data[dayLoc,],loc=locs,iftseries=FALSE,addrand=FALSE) # Fill with massaged data (ws,wd) for working day
 	
 	## Calculate Temperature Statistics
 	if(sum(ifelse(is.na(dayData$temp[,1]), 0,1)) != 0 ){
 	  corData[i,1] = cor(dayData$temp[,2],dayData$temp[,1],use="complete.obs")
 	  biasData[i,1] = mbias(dayData$temp[,2],dayData$temp[,1],na.rm=T)
 	  RMSEData[i,1] = rmserror(dayData$temp[,2],dayData$temp[,1],na.rm=T)
 	}
 	## Calculate Mixing Ratio Statistics
 	if(sum(ifelse(is.na(dayData$q[,1]), 0,1)) != 0 ){
 	  corData[i,2] = cor(dayData$q[,2],dayData$q[,1],use="complete.obs")
 	  biasData[i,2] = mbias(dayData$q[,2],dayData$q[,1],na.rm=T)
 	  RMSEData[i,2] = rmserror(dayData$q[,2],dayData$q[,1],na.rm=T)
 	}
 	## Calculate Wind Speed Statistics
 	if(sum(ifelse(is.na(dayData$ws[,1]), 0,1)) != 0 ){
 	  corData[i,3] = cor(dayData$ws[,2],dayData$ws[,1],use="complete.obs")
 	  biasData[i,3] = mbias(dayData$ws[,2],dayData$ws[,1],na.rm=T)
 	  RMSEData[i,3] = rmserror(dayData$ws[,2],dayData$ws[,1],na.rm=T)
 	}
 	## Calculate Wind Direction Statistics
 	if(sum(ifelse(is.na(dayData$wd[,1]), 0,1)) != 0 ){
 	  corData[i,4] = cor(dayData$wd[,2],dayData$wd[,1],use="complete.obs")
 	  biasData[i,4] = mbias(dayData$wd[,2],dayData$wd[,1],na.rm=T)
 	  RMSEData[i,4] = rmserror(dayData$wd[,2],dayData$wd[,1],na.rm=T)
        }
  }
# save(corData,biasData,RMSEData,file="test.RData")
 
 #Temperature Bar Plots
 dates <- format(seq.Date(from=as.Date(data[1,1],format="%Y%m%d"),length.out=numDays,by="day"),'%b-%d-%y')
 
 pname<-paste(figdir,"/",project,".T.daily_barplot_cor.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 mp <- barplot(corData[,1],beside=T,main=paste(varsName[1],"Daily Correlation"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()


 pname<-paste(figdir,"/",project,".T.daily_barplot_bias.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 mp <- barplot(biasData[,1],beside=T,main=paste(varsName[1],"Daily Bias"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()


 pname<-paste(figdir,"/",project,".T.daily_barplot_RMSE.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 mp <- barplot(RMSEData[,1],beside=T,main=paste(varsName[1],"Daily RMSE Error"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()


  #Mixing Ratio Bar Plots
	# Test to see if data is missing.  This is true for MCIP as there is no Q in the METCRO2D files
if(length(which(is.na(dayData$q)) == TRUE) != length(dayData$q)) {
 pname<-paste(figdir,"/",project,".Q.daily_barplot_cor.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 barplot(corData[,2],beside=T,main=paste(varsName[2],"Daily Correlation"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()

 pname<-paste(figdir,"/",project,".Q.daily_barplot_bias.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 barplot(biasData[,2],beside=T,main=paste(varsName[2],"Daily Bias"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()

 pname<-paste(figdir,"/",project,".Q.daily_barplot_RMSE.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 barplot(RMSEData[,2],beside=T,main=paste(varsName[2],"Daily RMSE Error"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()
}

  #Wind Speed Bar Plots
 pname<-paste(figdir,"/",project,".WS.daily_barplot_cor.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 barplot(corData[,3],beside=T,main=paste(varsName[3],"Daily Correlation"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()

 pname<-paste(figdir,"/",project,".WS.daily_barplot_bias.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 barplot(biasData[,3],beside=T,main=paste(varsName[3],"Daily Bias"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()

 pname<-paste(figdir,"/",project,".WS.daily_barplot_RMSE.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 barplot(RMSEData[,3],beside=T,main=paste(varsName[3],"Daily RMSE Error"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()

  #Wind Direction Bar Plots
 pname<-paste(figdir,"/",project,".WD.daily_barplot_cor.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 barplot(corData[,4],beside=T,main=paste(varsName[4],"Daily Correlation"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()

 pname<-paste(figdir,"/",project,".WD.daily_barplot_bias.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 barplot(biasData[,4],beside=T,main=paste(varsName[4],"Daily Bias"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()

 pname<-paste(figdir,"/",project,".WD.daily_barplot_RMSE.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 barplot(RMSEData[,4],beside=T,main=paste(varsName[4],"Daily RMSE Error"),mar=c(7,4,4,2))	
 axis(1,labels=dates,at=mp,las=2)
 dev.off()
