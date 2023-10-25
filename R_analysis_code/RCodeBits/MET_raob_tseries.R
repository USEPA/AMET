#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#                AMET (Atmospheric Model Evaluation Tool)               #
#                                                                       #
#                      SOLAR Radiation Analysis                         #
#                          MET_raob_tseries.R                           #
#                                                                       #
#         Developed by the US Environmental Protection Agency           #
#-----------------------------------------------------------------------#
#########################################################################
#                                                                       #
#     This add-on script takes text output from the raob timeseries     #
#     for mutiple sensitivity runs and              
#         
#########################################################################
#########################################################################

ametbase <-"/home/grc/AMET_v13"

runs     <-c("wrfv4_morr","wrfv4_gfs","wrfv4_wsm6")
datestr  <-"20160101-20160801.1000-200mb"

runs     <-c("mpas52_12km_epaphys_nlcd40f","wrfv4_hyb_nomodis")
datestr  <-"20160101-20161231.1000-200mb"
runs     <-c("mpas52_12km_epaphys_nlcd40f","wrf_conus12_oaqps")
datestr  <-"20160101-20161231.1000-200mb"


varid    <-c("TEMP","RH","WS","WD")
varunit  <-c("K","%","m/s","Deg")
ylim1    <-c(0,0,1,0)
ylim2    <-c(2,30,4,35)

for(v in 1:length(varid)){
 for(r in 1:length(runs)){

   csv.file  <-paste(ametbase,"/output/",runs[r],"/raob/TSERIES/raob.daily.",varid[v],".",datestr,".",runs[r],".csv",sep="")
   writeLines(csv.file)
   rm(csv.data)
   csv.data  <-read.csv(file=csv.file,  header = T)
   if(r == 1) {
     dates   <-csv.data[,1]
     ntimes  <-length(dates)
     rm(stats)
     stats   <-array(NA,c(ntimes,4,length(runs)))
     for(tt in 1:ntimes){
       stats[tt,1,r]<- as.numeric(as.character(csv.data[tt,2]))
       stats[tt,2,r]<- as.numeric(as.character(csv.data[tt,3]))
       stats[tt,3,r]<- as.numeric(as.character(csv.data[tt,4]))
       stats[tt,4,r]<- as.numeric(as.character(csv.data[tt,5]))
     }
   }
   if(r > 1) {
     date2   <-csv.data[,1]
     for(tt in 1:ntimes){
       ind<-which(as.character(dates[tt]) == as.character(date2))
       if(length(ind)>0){
        stats[tt,1,r] <- as.numeric(as.character(csv.data[ind,2]))
        stats[tt,2,r] <- as.numeric(as.character(csv.data[ind,3]))
        stats[tt,3,r] <- as.numeric(as.character(csv.data[ind,4]))
        stats[tt,4,r] <- as.numeric(as.character(csv.data[ind,5]))
       }
     }
   }
 }

   # Comparison Timeseries Plot For Each Statistic TEMP, RH, WS, WD
   tmpvarlab1<-paste("", sep="")
   tmpvarlab2<-paste("RMSE of ",varid[v],"(",varunit[v],") --  Date/Level: ",datestr,sep="")
   plotvar1  <-stats[,2,1]
   plotvar2  <-stats[,2,2]
   plotvar1  <-as.character(stats[,1,1])
   plotvar2  <-as.character(stats[,1,2])
#   plotvar3  <-as.character(stats[,1,3])
   ylims     <-c(ylim1[v],ylim2[v])
   figure    <-paste("raob.compare.tseries.",varid[v],".","RMSE.pdf",sep="")
   pdf(file= figure, width = 10, height = 5)
   par(new=F)
   plot(dates,plotvar1,xlab="Date",axes=FALSE,ylab=tmpvarlab1,
        pch=4,cex=0.75,col="black",ylim=ylims,
        vfont=c("serif","bold"),label=TRUE,type="l",lwd=1)
   par(new=T)
   plot(dates,plotvar2,xlab="",axes=FALSE,ylab=tmpvarlab1,
        pch=4,cex=0.75,col="red",ylim=ylims,
        vfont=c("serif","bold"),label=TRUE,type="l",lwd=1)
#   par(new=T)
#   plot(dates,plotvar3,xlab="",axes=FALSE,ylab=tmpvarlab1,
#        pch=4,cex=0.75,col="blue",ylim=ylims,
#        vfont=c("serif","bold"),label=TRUE,type="l",lwd=1)
   #par(tck=1)
   axis(1,col="black",lty=3,at=dates[seq(1,ntimes)],
        labels=dates[seq(1,ntimes)], col.ticks="gray")
   axis(2,col="black",lty=3, col.ticks="gray")
   title(tmpvarlab2)
   box()
   dev.off()
   ##########################################################

   plot(dates,plotvar1,type="l",lwd=1)


}


############################################################################
quit(save='no')

