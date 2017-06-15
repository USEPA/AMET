#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#                AMET (Atmospheric Model Evaluation Tool)               #
#                                                                       #
#                    Daily Statistics Bar Plots                         #
#                      MET_daily_barplot.R                              #
#                                                                       #
#                                                                       #
#         Version: 	1.3                                             #
#         Date:		May 15, 2017                                    #
#         Contributors:	Robert Gilliam                                  #
#                                                                       #
#         Developed by the US Environmental Protection Agency           #
#-----------------------------------------------------------------------#
#########################################################################
#                                                                       #
#  This script queries a range of days as defined by user. Once the     #
#  batch of data is pulled from the database, it is seperated by day.   #
#  Daily model evaluation metrics are calculated and plotted via simple #
#  bar plot for RMSE, bias and correlation.                             #
#                                                                       #
# Version 1.2, May 8, 2013, Rob Gilliam                                 #
# Updates: -Added logic to skip days where no data exists to aviod fail #
#          -Print of day to screen as loop through daily computations   #
#          -Changed "Mean Bias" to "Bias" in plot label                 #
#          -Cleaned code                                                #
#                                                                       #            
# Version 1.3, May 15, 2017, Rob Gilliam                                #
#  Updates: - Removed old amet-config.R configuration option that       #
#             defined MySQL server, database and password (unsecure).   #
#           - Changed directory names to reflect new directory structure#
#             of AMET. Also reformatted some parts of the code          #
#             for better readability.                                   #
#########################################################################
#:::::::::::::::::::::::::::::::::::::::::::::
#	Load required modules
  if(!require(RMySQL)) {stop("Required Package RMySQL was not loaded")}

########################################################
#    Initialize AMET Directory Structure Via Env. Vars
#    AND Load required function and conf. files
#########################################################

  ## get some environmental variables and setup some directories
  ametbase         <-Sys.getenv("AMETBASE")
  ametR            <-paste(ametbase,"/R_analysis_code",sep="")
  ametRinput       <-Sys.getenv("AMETRINPUT")
  mysqlloginconfig <-Sys.getenv("MYSQL_CONFIG")

  # Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
  # and not specified via AMET_OUT, then set figdir to the current directory
  if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")	}
  if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"                       }

  ## source some configuration files, AMET libs, and input
  source (paste(ametR,"/MET_amet.misc-lib.R",sep=""))
  source (paste(ametR,"/MET_amet.plot-lib.R",sep=""))
  source (paste(ametR,"/MET_amet.stats-lib.R",sep=""))
  source (mysqlloginconfig)
  source (ametRinput)	                                

  ametdbase      <- Sys.getenv("AMET_DATABASE")
  mysqlserver    <- Sys.getenv("MYSQL_SERVER")
  mysql          <-list(server=mysqlserver,dbase=ametdbase,login=mysqllogin,
                        passwd=mysqlpasswd,maxrec=maxrec)


  plotopts       <-list(plotfmt=plotfmt)
  dailybox.Rfile <-paste(figdir,"/daily_bar_",project,".",runid,".Rdata",sep="")
#####################################################################
# MAIN PROGRAM
# 1. Query for data over requested time period
# 2. Determine number of dates in data extracted from database
# 3. Loop through dates; skip days with no data after setting to NA
# 4. Build correlation, bias & RMSE arrays for plots
# 5. Plot bar plots
#####################################################################

#####################################################################
# Query Database and retrieve data
#####################################################################
 varsName <-c("Temperature (2m)","Specific Humidity (2m)","Wind Speed (10m)","Wind Direction (deg.)")
 varid    <-c("T","Q","WS","WD")
 varxstr  <-paste("SELECT DATE_FORMAT(ob_date,'%Y%m%d'),HOUR(ob_time),d.stat_id,s.ob_network,
                   d.T_mod,d.T_ob, d.Q_mod,d.WVMR_ob, d.U_mod,d.U_ob, d.V_mod,d.V_ob")
 query    <-paste(varxstr," FROM ",project,"_surface d, stations s WHERE  s.stat_id=d.stat_id ",querystr,sep="")
 writeLines(paste("query: ",query))
 data     <- ametQuery(query,mysql)

 ## test to see if query returned anything
 if (length(data) == 0) {
   stop(paste('',
              '**********************************************************************************',
              'NO DATA WAS FOUND FOR THIS QUERY: Please change some of the criteria and try again',
              '**********************************************************************************',sep="\n"))
 }
#####################################################################
# Determine Date Range
#####################################################################
 numDays  <- length(unique(data[,1]))
 dates    <- format(seq.Date(from=as.Date(data[1,1],format="%Y%m%d"),length.out=numDays,by="day"),'%Y%m%d')
 locs     <-c(1,2,3,4,5,6,9,10,11,12,7,8)
 
 # Create Vectors to hold working data
 corData           <- array(NA,c(numDays,4))
 colnames(corData) <- c("T","Q","WS","WD")
 biasData          <- array(NA,c(numDays,4))
 colnames(biasData)<- c("T","Q","WS","WD")
 RMSEData          <- array(NA,c(numDays,4))
 colnames(RMSEData)<- c("T","Q","WS","WD")
 
#####################################################################
 # Loop through dates to generate data
 for(i in 1:numDays){
  writeLines(paste("Computing stats for day:",dates[i]))
 	dayLoc  <- which(data[,1] == dates[i]) # Find rows which contain data for given date
 	if(length(dayLoc) == 0) { 
 	  writeLines(paste("No data will skip:",dates[i])) 
 	  next 
 	}
  # Fill with massaged data (ws,wd) for working day
 	dayData <- massageTseries(data[dayLoc,],loc=locs,iftseries=FALSE,addrand=FALSE) 

 	## Calculate Temperature Statistics
 	if(sum(ifelse(is.na(dayData$temp[,1]), 0,1)) != 0 ){
 	  corData[i,1]  <- cor(dayData$temp[,2],dayData$temp[,1],use="complete.obs")
 	  biasData[i,1] <- mbias(dayData$temp[,2],dayData$temp[,1],na.rm=T)
 	  RMSEData[i,1] <- rmserror(dayData$temp[,2],dayData$temp[,1],na.rm=T)
 	}

 	## Calculate Mixing Ratio Statistics
 	if(sum(ifelse(is.na(dayData$q[,1]), 0,1)) != 0 ){
 	  corData[i,2]  <- cor(dayData$q[,2],dayData$q[,1],use="complete.obs")
 	  biasData[i,2] <- mbias(dayData$q[,2],dayData$q[,1],na.rm=T)
 	  RMSEData[i,2] <- rmserror(dayData$q[,2],dayData$q[,1],na.rm=T)
 	}

 	## Calculate Wind Speed Statistics
 	if(sum(ifelse(is.na(dayData$ws[,1]), 0,1)) != 0 ){
 	  corData[i,3]  <- cor(dayData$ws[,2],dayData$ws[,1],use="complete.obs")
 	  biasData[i,3] <- mbias(dayData$ws[,2],dayData$ws[,1],na.rm=T)
 	  RMSEData[i,3] <- rmserror(dayData$ws[,2],dayData$ws[,1],na.rm=T)
 	}

 	## Calculate Wind Direction Statistics
 	if(sum(ifelse(is.na(dayData$wd[,1]), 0,1)) != 0 ){
 	  corData[i,4]  <- cor(dayData$wd[,2],dayData$wd[,1],use="complete.obs")
 	  biasData[i,4] <- mbias(dayData$wd[,2],dayData$wd[,1],na.rm=T)
 	  RMSEData[i,4] <- rmserror(dayData$wd[,2],dayData$wd[,1],na.rm=T)
  }
 }
 writeLines(paste("Daily R file output",dailybox.Rfile))
 save(corData,biasData,RMSEData,file=dailybox.Rfile)
#####################################################################

#####################################################################
 # Write out daily temperature statistics to text file

 sfile<-file(paste(figdir,"/tmp",sep=""),"a")
 writeLines("--------------------------------------------------------", con =sfile)
 writeLines("Daily Temperature (2 m) Correlation", con =sfile)
 close(sfile)
 write.table(corData[,1],paste(figdir,"/tmpx",sep=""),sep=",",col.names=F, row.names=F, quote=FALSE)
 system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
 system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))

 sfile<-file(paste(figdir,"/tmp",sep=""),"a")
 writeLines("--------------------------------------------------------", con =sfile)
 writeLines("Daily Temperature (2 m) Bias", con =sfile)
 close(sfile)
 write.table(biasData[,1],paste(figdir,"/tmpx",sep=""),sep=",",col.names=F, row.names=F, quote=FALSE)
 system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
 system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))

 sfile<-file(paste(figdir,"/tmp",sep=""),"a")
 writeLines("--------------------------------------------------------", con =sfile)
 writeLines("Daily Temperature (2 m) RMSE", con =sfile)
 close(sfile)
 write.table(RMSEData[,1],paste(figdir,"/tmpx",sep=""),sep=",",col.names=F, row.names=F, quote=FALSE)
 system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
 system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))

 system(paste("mv ",figdir,"/tmp ",figdir,"/",project,".T.daily_stats.dat",sep=""))
 system(paste("rm -f ",figdir,"/tmp* ",sep=""))

 # Write out daily mixing ratio statistics to text file

 sfile<-file(paste(figdir,"/tmp",sep=""),"a")
 writeLines("--------------------------------------------------------", con =sfile)
 writeLines("Daily Mixing Ratio (2 m) Correlation", con =sfile)
 close(sfile)
 write.table(corData[,2],paste(figdir,"/tmpx",sep=""),sep=",",col.names=F, row.names=F, quote=FALSE)
 system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
 system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))

 sfile<-file(paste(figdir,"/tmp",sep=""),"a")
 writeLines("--------------------------------------------------------", con =sfile)
 writeLines("Daily Mixing Ratio (2 m) Bias", con =sfile)
 close(sfile)
 write.table(biasData[,2],paste(figdir,"/tmpx",sep=""),sep=",",col.names=F, row.names=F, quote=FALSE)
 system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
 system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))

 sfile<-file(paste(figdir,"/tmp",sep=""),"a")
 writeLines("--------------------------------------------------------", con =sfile)
 writeLines("Daily Mixing Ratio (2 m) RMSE", con =sfile)
 close(sfile)
 write.table(RMSEData[,2],paste(figdir,"/tmpx",sep=""),sep=",",col.names=F, row.names=F, quote=FALSE)
 system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
 system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))

 system(paste("mv ",figdir,"/tmp ",figdir,"/",project,".Q.daily_stats.dat",sep=""))
 system(paste("rm -f ",figdir,"/tmp* ",sep=""))

 # Write out daily wind speed statistics to text file

 sfile<-file(paste(figdir,"/tmp",sep=""),"a")
 writeLines("--------------------------------------------------------", con =sfile)
 writeLines("Daily Wind Speed (10 m) Correlation", con =sfile)
 close(sfile)
 write.table(corData[,3],paste(figdir,"/tmpx",sep=""),sep=",",col.names=F, row.names=F, quote=FALSE)
 system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
 system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))

 sfile<-file(paste(figdir,"/tmp",sep=""),"a")
 writeLines("--------------------------------------------------------", con =sfile)
 writeLines("Daily Wind Speed (10 m) Bias", con =sfile)
 close(sfile)
 write.table(biasData[,3],paste(figdir,"/tmpx",sep=""),sep=",",col.names=F, row.names=F, quote=FALSE)
 system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
 system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))

 sfile<-file(paste(figdir,"/tmp",sep=""),"a")
 writeLines("--------------------------------------------------------", con =sfile)
 writeLines("Daily Wind Speed (10 m) RMSE", con =sfile)
 close(sfile)
 write.table(RMSEData[,3],paste(figdir,"/tmpx",sep=""),sep=",",col.names=F, row.names=F, quote=FALSE)
 system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
 system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))

 system(paste("mv ",figdir,"/tmp ",figdir,"/",project,".WS.daily_stats.dat",sep=""))
 system(paste("rm -f ",figdir,"/tmp* ",sep=""))

 # Write out daily wind direction statistics to text file

 sfile<-file(paste(figdir,"/tmp",sep=""),"a")
 writeLines("--------------------------------------------------------", con =sfile)
 writeLines("Daily Wind Direction (10 m) Correlation", con =sfile)
 close(sfile)
 write.table(corData[,4],paste(figdir,"/tmpx",sep=""),sep=",",col.names=F, row.names=F, quote=FALSE)
 system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
 system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))

 sfile<-file(paste(figdir,"/tmp",sep=""),"a")
 writeLines("--------------------------------------------------------", con =sfile)
 writeLines("Daily Wind Direction (10 m) Bias", con =sfile)
 close(sfile)
 write.table(biasData[,4],paste(figdir,"/tmpx",sep=""),sep=",",col.names=F, row.names=F, quote=FALSE)
 system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
 system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))

 sfile<-file(paste(figdir,"/tmp",sep=""),"a")
 writeLines("--------------------------------------------------------", con =sfile)
 writeLines("Daily Wind Direction (10 m) RMSE", con =sfile)
 close(sfile)
 write.table(RMSEData[,4],paste(figdir,"/tmpx",sep=""),sep=",",col.names=F, row.names=F, quote=FALSE)
 system(paste("cat ",figdir,"/tmp ",figdir,"/tmpx> ",figdir,"/tmpxx",sep=""))
 system(paste("mv ",figdir,"/tmpxx ",figdir,"/tmp",sep=""))

 system(paste("mv ",figdir,"/tmp ",figdir,"/",project,".WD.daily_stats.dat",sep=""))
 system(paste("rm -f ",figdir,"/tmp* ",sep=""))
#####################################################################

#####################################################################
# Plot data
#####################################################################
 
 #################################
 #Temperature Bar Plots
 dates <- format(seq.Date(from=as.Date(data[1,1],format="%Y%m%d"),length.out=numDays,by="day"),'%b-%d-%y')
 pname <-paste(figdir,"/",project,".",runid,".T.daily_barplot_cor.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 mp    <- barplot(corData[,1],beside=T,main=paste(varsName[1],"Daily Correlation"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()


 pname <-paste(figdir,"/",project,".",runid,".T.daily_barplot_bias.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 mp    <- barplot(biasData[,1],beside=T,main=paste(varsName[1],"Daily Bias"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()


 pname <-paste(figdir,"/",project,".",runid,".T.daily_barplot_RMSE.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 mp    <- barplot(RMSEData[,1],beside=T,main=paste(varsName[1],"Daily RMSE Error"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()
 #################################


 #################################
 # Mixing Ratio Bar Plots
 # Test to see if data is missing.  This is true for MCIP as there is no Q in the METCRO2D files
 if(length(which(is.na(dayData$q)) == TRUE) != length(dayData$q)) {
   pname<-paste(figdir,"/",project,".",runid,".Q.daily_barplot_cor.",plotopts$plotfmt,sep="")
   if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
   if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
   barplot(corData[,2],beside=T,main=paste(varsName[2],"Daily Correlation"),mar=c(7,4,4,2))
   axis(1,labels=dates,at=mp,las=2)
   dev.off()

   pname<-paste(figdir,"/",project,".",runid,".Q.daily_barplot_bias.",plotopts$plotfmt,sep="")
   if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
   if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
   barplot(biasData[,2],beside=T,main=paste(varsName[2],"Daily Bias"),mar=c(7,4,4,2))
   axis(1,labels=dates,at=mp,las=2)
   dev.off()

   pname<-paste(figdir,"/",project,".",runid,".Q.daily_barplot_RMSE.",plotopts$plotfmt,sep="")
   if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
   if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
   barplot(RMSEData[,2],beside=T,main=paste(varsName[2],"Daily RMSE Error"),mar=c(7,4,4,2))
   axis(1,labels=dates,at=mp,las=2)
   dev.off()
 }
 #################################

 #################################
 #Wind Speed Bar Plots
 pname<-paste(figdir,"/",project,".",runid,".WS.daily_barplot_cor.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 barplot(corData[,3],beside=T,main=paste(varsName[3],"Daily Correlation"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()

 pname<-paste(figdir,"/",project,".",runid,".WS.daily_barplot_bias.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 barplot(biasData[,3],beside=T,main=paste(varsName[3],"Daily Bias"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()

 pname<-paste(figdir,"/",project,".",runid,".WS.daily_barplot_RMSE.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 barplot(RMSEData[,3],beside=T,main=paste(varsName[3],"Daily RMSE Error"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()
 #################################

 #################################
 #Wind Direction Bar Plots
 pname<-paste(figdir,"/",project,".",runid,".WD.daily_barplot_cor.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 barplot(corData[,4],beside=T,main=paste(varsName[4],"Daily Correlation"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()

 pname<-paste(figdir,"/",project,".",runid,".WD.daily_barplot_bias.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 barplot(biasData[,4],beside=T,main=paste(varsName[4],"Daily Bias"),mar=c(7,4,4,2))
 axis(1,labels=dates,at=mp,las=2)
 dev.off()

 pname<-paste(figdir,"/",project,".",runid,".WD.daily_barplot_RMSE.",plotopts$plotfmt,sep="")
 if (plotopts$plotfmt == "pdf"){pdf(file= pname, width = 11, height = 8.5)	}
 if (plotopts$plotfmt == "png"){png(file=pname, width=600,height=600)      }
 barplot(RMSEData[,4],beside=T,main=paste(varsName[4],"Daily RMSE Error"),mar=c(7,4,4,2))	
 axis(1,labels=dates,at=mp,las=2)
 dev.off()
 #################################
quit(save='no')
