
##### Search for Network
datestr<- Sys.getenv('DATESTR')
netcheck<- Sys.getenv('NETWORK')

library(stringr)
require(ncdf4)

hr<-c("0000","0200","0300","0400","0500","0600","0700","0800","0900","0100","1000","1100","1200")
for(h in 1:length(hr)){
madis_file<-paste("/work/MOD3DEV/grc/obs/MET/point/metar/netcdf/",datestr,"_",hr[h],sep="")
if(file.exists(madis_file)) {
  #writeLines(paste("opening",madis_file))
  f2 <-nc_open(madis_file)
    site   <- ncvar_get(f2, varid="stationName")
    stemp <- ncvar_get(f2, varid="temperature")    
  nc_close(f2) 
ii<-which(str_detect(site, netcheck))
if(length(ii) > 0){
  writeLines(paste("Sites found date, number:",netcheck,datestr,hr[h],stemp[ii[1]]))
}
if(length(ii) == 0){
  writeLines(paste("NO ",netcheck," Sites",datestr, hr[h]))
}

}
}
quit(save="no")
#############################


##### Search for Network
datestr<- Sys.getenv('DATESTR')
netcheck<- Sys.getenv('NETWORK')

library(stringr)
require(ncdf4)

hr<-c("0000","0200","0300","0400","0500","0600","0700","0800","0900","0100","1000","1100","1200")
for(h in 1:length(hr)){
madis_file<-paste("/work/MOD3DEV/grc/obs/MET/LDAD/mesonet/netCDF/",datestr,"_",hr[h],sep="")
if(file.exists(madis_file)) {
  writeLines(paste("opening",madis_file))
  f2 <-nc_open(madis_file)
    site1       <- ncvar_get(f2, varid="stationName")
    site2       <- ncvar_get(f2, varid="stationId")
    srad        <- ncvar_get(f2, varid="solarRadiation")
    report_type <- ncvar_get(f2, varid="dataProvider")
  nc_close(f2) 
ii<-which(str_detect(report_type, netcheck))
if(length(ii) > 0){
  writeLines(paste("Sites found date, number:",netcheck, datestr, hr[h], length(ii)))
}
if(length(ii) == 0){
  writeLines(paste("NO ",netcheck," Sites",datestr, hr[h]))
}

}
}
quit(save="no")
#############################
library(stringr)
require(ncdf4)
madis_file<-"/work/MOD3DEV/grc/obs/MET/LDAD/mesonet/netCDF/20200101_0000_new"
madis_file<-"20200101_0000_new"
  f2     <-nc_open(madis_file)
    site   <- ncvar_get(f2, varid="stationName")
    stemp <- ncvar_get(f2, varid="temperature")    
  nc_close(f2) # Close MADIS obs file

which(str_detect(site, "WANT"))




