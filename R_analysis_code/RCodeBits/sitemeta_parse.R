library(stringr)
require(ncdf4)
madis_dir       <-"/work/MOD3DEV/grc/obs/MET/LDAD/mesonet/netCDF/"
madis_dir       <-"/work/MOD3DEV/grc/obs/MET/point/metar/netcdf/"
mastermeta_file <-"/home/grc/AMET_v13/obs/MET/mastermeta.Rdata"

if(file.exists(mastermeta_file)) {
 load(mastermeta_file)
}
if(!file.exists(mastermeta_file)) {
  mastermeta <-array(NA,c(50000,5))
}


year<-c("2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013")
month<-c("01","02","03","04","05","06","07","08","09","10","11","12")
ny<-length(year)
nm<-length(month)
#ny<-10
#nm<-1
for(yy in 1:ny){

 for(mm in 1:nm){

  madis_file<-paste(madis_dir,year[yy],month[mm],"01_0000",sep="")
  if(file.exists(madis_file)) {
   writeLines(paste("Processing:",madis_file))
   f2     <-nc_open(madis_file)
    site         <- ncvar_get(f2, varid="stationName")
    site_locname <- ncvar_get(f2, varid="locationName")
    selev  <- ncvar_get(f2, varid="elevation")
   nc_close(f2) # Close MADIS obs file

  mm<-sum(ifelse(is.na(mastermeta[,1]),0,1))
  ns<-length(site)
  for(ss in 1:ns){
    com_name <- trimws(unlist(strsplit(site_locname[ss],','))[1])
    tmps2    <- trimws(unlist(strsplit(site_locname[ss],','))[2])
    state    <- ifelse(is.na(unlist(strsplit(tmps2,""))[1]),'',substr(tmps2,1,2))
    k        <-which(site[ss] == mastermeta[,1])
    if( sum(which(site[ss] == mastermeta[,1])) == 0 ) {
      mastermeta[mm,1]   <- site[ss]
      mastermeta[mm,2]   <- selev[ss]
      mastermeta[mm,3]   <- com_name
      mastermeta[mm,4]   <- state
      writeLines(paste(mm,site[ss],selev[ss],com_name, state, sep=" -- "))
      mm                 <- mm + 1
    }
  }

  }
 }
}
save(mastermeta,file=mastermeta_file)
stop("Finished")



mastermeta_file <-"/home/grc/AMET_v13/obs/MET/mastermeta.Rdata"
load(mastermeta_file)
data<-read.csv(file="metar_codes_country.txt",sep="\t")
ccode<-data[,1]
cdesc<-data[,2]
mm<-sum(ifelse(is.na(mastermeta[,1]),0,1))
mastermeta2 <-array(NA,c(mm,5))
mastermeta2 <- mastermeta[1:mm,]
mastermeta<-mastermeta2

for(ss in 1:mm){
 stat_id   <-mastermeta[ss,1]
 statsplit <-unlist(strsplit(stat_id,""))
 first1    <-statsplit[1]
 first2    <-paste(statsplit[1],statsplit[2],sep="")
 if(first1 == "K") { mastermeta[ss,5] <- trimws(as.character(cdesc[which(ccode==first1)])); next }
 if(first1 == "C") { mastermeta[ss,5] <- trimws(as.character(cdesc[which(ccode==first1)])); next }
 if(first1 == "U") { mastermeta[ss,5] <- trimws(as.character(cdesc[which(ccode==first1)])); next }
 if(first1 == "Y") { mastermeta[ss,5] <- trimws(as.character(cdesc[which(ccode==first1)])); next }
 if(first1 == "Z") { mastermeta[ss,5] <- trimws(as.character(cdesc[which(ccode==first1)])); next }

 ind<-which(ccode==first2)
 if(sum(ind)>0) {
  mastermeta[ss,5] <- trimws(as.character(cdesc[ind]))
 }
}

save(mastermeta,file=mastermeta_file)

stop("Finished")



mastermeta_file <-"/home/grc/AMET_v13/obs/MET/mastermeta.Rdata"
load(mastermeta_file)
mm<-sum(ifelse(is.na(mastermeta[,1]),0,1))
for(ss in 1:mm){
 mastermeta[ss,2]<-ifelse(is.na(mastermeta[ss,2]) || nchar(trimws(mastermeta[ss,2]))==0,NA, as.numeric(mastermeta[ss,2]))
 mastermeta[ss,3]<-ifelse(is.na(mastermeta[ss,3]) || nchar(trimws(mastermeta[ss,3]))==0,"99", mastermeta[ss,3])
 mastermeta[ss,4]<-ifelse(is.na(mastermeta[ss,4]) || nchar(trimws(mastermeta[ss,4]))==0,"99", mastermeta[ss,4])
 mastermeta[ss,5]<-ifelse(is.na(mastermeta[ss,5]) || nchar(trimws(mastermeta[ss,5]))==0,"99", mastermeta[ss,5])
}
save(mastermeta,file=mastermeta_file)
stop("Finished")

mastermeta_file <-"/home/grc/AMET_v13/obs/MET/mastermeta.Rdata"
load(mastermeta_file)

ucountry<-unique(mastermeta[,5])
nc<-length(ucountry)

str  <-paste(ucountry[1],sep="")

for(ss in 2:nc){
  str <-paste(str,", ",ucountry[ss],sep="")
}
 sfile<-file(paste("countries.txt",sep=""),"w")
 writeLines(str, con =sfile)
 close(sfile)
stop("Finished")


## RAOB metadata exploration

mastermeta_file <-"/home/grc/AMET_v13/obs/MET/mastermeta.Rdata"
load(mastermeta_file)

#### US RAOB read and parse code to site ID, state, country and description
filein<-"raob.us.txt"
 zz <- file(filein, "rt")
 aa<-readLines(zz,n=-1)
close(zz)
nlines<-length(aa)
mastermetaUS <-array(NA,c(nlines,4))
for(ll in 1:nlines) {
 b       <-unlist(strsplit(aa[ll],split=""))
 state   <-trimws(paste(b[83],b[84],sep=""))
 cabrv   <-trimws(paste(b[87],b[88],sep=""))
 sdesc   <-trimws(paste(b[58],b[59],b[60],b[61],b[62],b[63],b[64],b[65],b[66],b[67],b[68],b[69],b[70],b[71],b[72],b[73],b[74],b[75],b[76],b[77],b[78],b[79],b[80],sep=""))

 statid <-trimws(paste("K",b[2],b[3],b[4],sep=""))
 if(cabrv =="CA"){  statid <-paste("C",b[2],b[3],b[4],sep="")    }
 if(cabrv =="MX"){  statid <-paste("M",b[2],b[3],b[4],sep="")    }
 if(state=="AK"){   statid <-paste("P",b[2],b[3],b[4],sep="")    }
 mastermetaUS[ll,]<-c(statid,state,cabrv,sdesc)
}
###########

#### US RAOB read and parse code to site ID, state, country and description
filein<-"raob.global.txt"
 zz <- file(filein, "rt")
 aa<-readLines(zz,n=-1)
close(zz)
nlines<-length(aa)
mastermetaGL <-array(NA,c(nlines,4))
for(ll in 1:nlines) {
 b       <-unlist(strsplit(aa[ll],split=""))
 state   <-trimws(paste(b[79],b[80],sep=""))
 cabrv   <-trimws(paste(b[83],b[84],sep=""))
 sdesc   <-trimws(paste(b[53],b[54],b[55],b[56],b[57],b[58],b[59],b[60],b[61],b[62],b[63],b[64],b[65],b[66],b[67],b[68],b[69],b[70],b[71],b[72],b[73],b[74],b[75],b[76],b[77],sep=""))

 statid <-trimws(paste(b[1],b[2],b[3],b[4],sep=""))
 if(cabrv =="US"){  statid <-paste("K",b[2],b[3],b[4],sep="")    }
 mastermetaGL[ll,]<-c(statid,state,cabrv,sdesc)
}
###########
statidu<-unique(mastermetaUS[,1])
ns1     <-length(statidu)
mastermetaUS2 <-array(NA,c(ns1,4))
for(ss in 1:ns1){
  ind<-which( statidu[ss] == mastermetaUS[,1])[1]
  mastermetaUS2[ss,] <- mastermetaUS[ind,]
}

statidu<-unique(mastermetaGL[,1])
ns2     <-length(statidu)
mastermetaGL2 <-array(NA,c(ns2,4))
for(ss in 1:ns2){
  ind<-which( statidu[ss] == mastermetaGL[,1])[1]
  mastermetaGL2[ss,] <- mastermetaGL[ind,]
}
mastermeta<-array(NA,c(ns1+ns2,4))
mastermeta[1:ns1,]<- mastermetaUS2
mastermeta[(ns1+1):(ns1+ns2),]<- mastermetaGL2
########################
mastermetaUA<-mastermeta

mastermeta_file <-"/home/grc/AMET_v13/obs/MET/mastermeta.Rdata"
load(mastermeta_file)

save(mastermeta,mastermetaUA,mastermetaSFC,file=mastermeta_file)

stop("Finished")

########################
########################


mastermeta_file <-"/home/grc/AMET_v13/obs/MET/mastermeta.Rdata"
load(mastermeta_file)
data<-read.csv(file="metar_codes_country.txt",sep="\t")
ccode<-data[,1]
cdesc<-data[,2]
mm<-sum(ifelse(is.na(mastermetaUA[,1]),0,1))
mastermeta2 <-array(NA,c(mm,5))
mastermeta2[,1] <- mastermetaUA[1:mm,1]
mastermeta2[,4:5] <- mastermetaUA[1:mm,2:3]
mastermeta2[,3] <- mastermetaUA[1:mm,4]
mastermetaUA<-mastermeta2

for(ss in 1:mm){
 stat_id   <-mastermetaUA[ss,1]
 statsplit <-unlist(strsplit(stat_id,""))
 first1    <-statsplit[1]
 first2    <-paste(statsplit[1],statsplit[2],sep="")
 if(first1 == "K") { mastermetaUA[ss,5] <- trimws(as.character(cdesc[which(ccode==first1)])); next }
 if(first1 == "C") { mastermetaUA[ss,5] <- trimws(as.character(cdesc[which(ccode==first1)])); next }
 if(first1 == "U") { mastermetaUA[ss,5] <- trimws(as.character(cdesc[which(ccode==first1)])); next }
 if(first1 == "Y") { mastermetaUA[ss,5] <- trimws(as.character(cdesc[which(ccode==first1)])); next }
 if(first1 == "Z") { mastermetaUA[ss,5] <- trimws(as.character(cdesc[which(ccode==first1)])); next }

 ind<-which(ccode==first2)
 if(sum(ind)>0) {
  mastermetaUA[ss,5] <- trimws(as.character(cdesc[ind]))
 }
}

for(ss in 1:mm){
 if(mastermetaUA[ss,3] =="") { mastermetaUA[ss,3]<-NA }
 if(mastermetaUA[ss,4] =="") { mastermetaUA[ss,4]<-NA }
 mastermetaUA[ss,3]<- sub("'", "",mastermetaUA[ss,3])
 mastermetaUA[ss,4]<- sub("'", "",mastermetaUA[ss,4])
 mastermetaUA[ss,5]<- sub("'", "",mastermetaUA[ss,5])
 writeLines(paste(ss,mastermetaUA[ss,1],mastermetaUA[ss,2],mastermetaUA[ss,3],mastermetaUA[ss,4],mastermetaUA[ss,5], sep=" -- "))
}


ns1<-dim(mastermetaSFC)[1]
ns2<-dim(mastermetaUA)[1]

mastermetaALL<-array(NA,c(ns1+ns2,5))
mastermetaALL[1:ns1,]<- mastermetaSFC
mastermetaALL[(ns1+1):(ns1+ns2),]<- mastermetaUA
mastermeta<-mastermetaALL
save(mastermeta,mastermetaALL,mastermetaSFC,mastermetaUA,file=mastermeta_file)

stop("Finished")



