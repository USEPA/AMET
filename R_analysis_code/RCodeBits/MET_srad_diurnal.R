#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#                AMET (Atmospheric Model Evaluation Tool)               #
#                                                                       #
#                      SOLAR Radiation Analysis                         #
#                          MET_srad_diurnal.R                           #
#                                                                       #
#         Developed by the US Environmental Protection Agency           #
#-----------------------------------------------------------------------#
#########################################################################
#######################################################################
#
#  AMET analysis scripts not yet supported, but may be useful examples
#  of analyses that piggyback on other AMET scripts
#   
#  This script reads R data file outputs from the shortwave radiation
#  analysis and plots the diurnal radiation statistis. This plots
#  all specified site data and one or more model runs on the same
#  plot. Also plots the average diurnal values of all sites for a
#  a particular simulations.
#
#  This can be modified to run on command, but this version is
#  copy and paste in an interative R session.
#
#######################################################################

# Main Settings. AMET dir, run IDs, sites, date range
ametbase <-"/home/grc/AMET_v13"
runid    <-c("wrfv4_morr","wrfv4_gfs","wrfv4_wsm6")
statid   <-c("bil","bon","bos","bou","clh","dra","fpe","gcr","lrc","psu","sxf")
datestr  <-"20160101-20160801"

ametbase <-"/home/grc/AMET_v13"
runid    <-c("mpas52_12km_epaphys_nlcd40f","mpas52_25km_epaphys_nlcd40f","wrfv4_hyb_nomodis2")
runid    <-c("mpas52_12km_epaphys_nlcd40f","mpas52_25km_epaphys_nlcd40f")
statid   <-c("bil","bon","bos","bou","clh","dra","fpe","gcr","lrc","psu","sxf")
statid   <-c("bon","gcr","psu")
datestr  <-"20160201-20170101"

ametbase <-"/work/MOD3DEV/grc/NRT_WRF_CMAQ/AMET"
runid    <-c("108nhemi_tseries","108nhemi_trig1","108nhemi_grell5")
statid   <-c("bil","bon","bos","bou","clh","dra","fpe","gcr","lrc","psu","sxf")
datestr  <-"20100701-20100930"

#######################################################################


nruns    <-length(runid)
nsites   <-length(statid)

master_array <-array(NA,c(nruns,nsites,7,24))

for(r in 1:nruns){
  for(s in 1:nsites){
   rm(stat_array_diurnal)
   rdatafile<-paste(ametbase,"/output/",runid[r],"/bsrn/srad.diurnal.",statid[s],".",datestr,".Rdata",sep="")
   rdatafile<-paste(ametbase,"/output/",runid[r],"/bsrn/DIURNAL/srad.diurnal.",statid[s],".",datestr,".Rdata",sep="")
   if(file.exists(rdatafile)){
    writeLines(rdatafile)
    load(rdatafile)
    master_array[r,s,,]<-stat_array_diurnal
   }
  }
}



  #######################################################################
  #   MAE Plot for Mutiple Simulations
  col.headers         <-c("BSRN","MODEL","RMSE","MAE","BIAS","SD_OBS","SD_MOD")
  hr   <-seq(0,23)
  xlim <-c(0,23)
  ylim<-c(0,200)

  ylabs<- seq(0,ceiling(ylim[2]/100)*100,by=100)
    
  linecols <-c("blue","red","black")
  linetype <-c(1,1,1)
  pchtype  <-c(16,16,16)
  leglab   <-c("BSRN","Model")

  r<-1
  s<-1
  varind<-4

  plotvar <- master_array[r,s,varind,]
  pdf(file= paste("srad.diurnal.MAE.pdf",sep=""), width = 10, height = 5)
  par(new=FALSE)
  plot(hr,plotvar,xlim=xlim, ylim=ylim,xlab="Solar Time of Day",ylab=paste("MAE (W/m^2) ",sep=""),
         label=F,tick=F,lty=linetype[r],pch=pchtype[r],col=linecols[r],type="p",cex=0.5, axes=F)   		

  par(tck=1)
  axis(1,at=hr,labels=hr,cex=1.25,col="gray",lty=1)
  axis(2,cex=1.25,col="gray",lty=1)
    
  for(r in 1:nruns){
    for(s in 1:nsites){
      par(new=TRUE)
      plotvar <- master_array[r,s,varind,]
      plot(hr,plotvar,xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
           lty=linetype[r],pch=pchtype[r],col=linecols[r],type="p",cex=0.5, axes=F) 
    }
    avg.plotvar <-array(NA,c(24))
    for(hh in 1:24) {
      avg.plotvar[hh] <- mean(master_array[r,,varind,hh],na.rm=T)
    }
    par(new=TRUE)
    plot(hr,avg.plotvar,xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[r],pch=pchtype[r],col=linecols[r],type="l",lwd=1.5, axes=F) 
  }
 box()
 dev.off()

#######################################################################

  #######################################################################
  #   BIAS Plot for Mutiple Simulations
  col.headers         <-c("BSRN","MODEL","RMSE","MAE","BIAS","SD_OBS","SD_MOD")
  hr   <-seq(0,23)
  xlim <-c(0,23)

  ylim<-c(-50,150)
  ylabs<- seq(0,ceiling(ylim[2]/100)*100,by=100)
    
  linecols <-c("blue","red","black")
  linetype <-c(1,1,1)
  pchtype  <-c(16,16,16)
  leglab   <-c("BSRN","Model")

  r<-1
  s<-1
  varind<-5

  plotvar <- master_array[r,s,varind,]
  pdf(file= paste("srad.diurnal.BIAS.pdf",sep=""), width = 10, height = 5)
  par(new=FALSE)
  plot(hr,plotvar,xlim=xlim, ylim=ylim,xlab="Solar Time of Day",ylab=paste("BIAS (W/m^2) ",sep=""),
         label=F,tick=F,lty=linetype[r],pch=pchtype[r],col=linecols[r],type="p",cex=0.5, axes=F)   		

  par(tck=1)
  axis(1,at=hr,labels=hr,cex=1.25,col="gray",lty=1)
  axis(2,cex=1.25,col="gray",lty=1)
    
  for(r in 1:nruns){
    for(s in 1:nsites){
      par(new=TRUE)
      plotvar <- master_array[r,s,varind,]
      plot(hr,plotvar,xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
           lty=linetype[r],pch=pchtype[r],col=linecols[r],type="p",cex=0.5, axes=F) 
    }
    avg.plotvar <-array(NA,c(24))
    for(hh in 1:24) {
      avg.plotvar[hh] <- mean(master_array[r,,varind,hh],na.rm=T)
    }
    par(new=TRUE)
    plot(hr,avg.plotvar,xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[r],pch=pchtype[r],col=linecols[r],type="l",lwd=1.5, axes=F) 
  }
 box()
 dev.off()

#######################################################################

  #######################################################################
  #   Sdev Plot for Mutiple Simulations
  col.headers         <-c("BSRN","MODEL","RMSE","MAE","BIAS","SD_OBS","SD_MOD")
  hr   <-seq(0,23)
  xlim <-c(0,23)

  ylim<-c(-75,75)
  ylabs<- seq(0,ceiling(ylim[2]/100)*100,by=100)
    
  linecols <-c("blue","red","black")
  linetype <-c(1,1,1)
  pchtype  <-c(16,16,16)
  leglab   <-c("BSRN","Model")

  r<-1
  s<-1
  varind<-5

  plotvar <- master_array[r,s,7,] - master_array[r,s,6,]
  pdf(file= paste("srad.diurnal.SDEVdiff.pdf",sep=""), width = 10, height = 5)
  par(new=FALSE)
  plot(hr,plotvar,xlim=xlim, ylim=ylim,xlab="Solar Time of Day",ylab=paste("Diff SDev (W/m^2) ",sep=""),
         label=F,tick=F,lty=linetype[r],pch=pchtype[r],col=linecols[r],type="p",cex=0.5, axes=F)   		

  par(tck=1)
  axis(1,at=hr,labels=hr,cex=1.25,col="gray",lty=1)
  axis(2,cex=1.25,col="gray",lty=1)
    
  for(r in 1:nruns){
    for(s in 1:nsites){
      par(new=TRUE)
      plotvar <- master_array[r,s,7,] - master_array[r,s,6,]
      plot(hr,plotvar,xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
           lty=linetype[r],pch=pchtype[r],col=linecols[r],type="p",cex=0.5, axes=F) 
    }
    avg.plotvar <-array(NA,c(24))
    for(hh in 1:24) {
      avg.plotvar[hh] <- mean(master_array[r,,7,hh]-master_array[r,,6,hh],na.rm=T)
    }
    par(new=TRUE)
    plot(hr,avg.plotvar,xlim=xlim, ylim=ylim,label=FALSE,ylab="",xlab="",tick=FALSE,
         lty=linetype[r],pch=pchtype[r],col=linecols[r],type="l",lwd=1.5, axes=F) 
  }
 box()
 dev.off()

#######################################################################
READ.SRAD.CSV<-F
source("/home/grc/AMET_v13/R_analysis_code/MET_amet.stats-lib.R")
source("/home/grc/AMET_v13/R_analysis_code/MET_amet.misc-lib.R")
if(READ.SRAD.CSV){

runs<-c("denver4_base_gdit","denver4_wrfv43","denver4_wrfv43_mskf","denver4_wrfv43_mskf_on")
sites<-c("bos","bou")
ns<-length(sites)
nr<-length(runs)

for(rr in 1:nr){
writeLines("-------------------------")
for(ss in 1:ns){
 csv.file  <-paste("/home/grc/AMET_v13/output/",runs[rr],"/bsrn/srad.timeseries.",sites[ss],".20140727-20140811.csv",sep="")
 csv.data  <-read.csv(file=csv.file,  header = T)
 obs <- csv.data[,2]
 mod <- csv.data[,3]

 obs.na<-ifelse(obs == 0,NA,obs)
 mod.na<-ifelse(mod == 0,NA,mod)

 stats.na<-simple.stats(obs.na,mod.na)
 writeLines(paste("RMSE    BIAS    COR",sites[ss],runs[rr]))
 writeLines(paste(round(stats.na[1]),round(stats.na[3]),stats.na[4]))

}}


}






