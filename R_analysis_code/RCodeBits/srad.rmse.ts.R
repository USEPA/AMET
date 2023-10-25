source("/home/grc/AMET_v13/R_analysis_code/MET_amet.stats-lib.R")

file<-"/home/grc/AMET_v13/output/denver4_wrfv43_mskf_on/bsrn/srad.timeseries.bos.20140727-20140811.csv"

file<-"/home/grc/AMET_v13/output/denver4_wrfv43_kf_ltng/bsrn/srad.timeseries.bou.20140727-20140811.csv"
#file<-"/home/grc/AMET_v13/output/denver4_wrfv43_kf_ltng/bsrn/srad.timeseries.bos.20140727-20140811.csv"

#file<-"/home/grc/AMET_v13/output/denver4_wrfv43_kf_on_ltng/bsrn/srad.timeseries.bou.20140727-20140811.csv"
#file<-"/home/grc/AMET_v13/output/denver4_wrfv43_kf_on_ltng/bsrn/srad.timeseries.bos.20140727-20140811.csv"

a<-read.csv(file, header = TRUE, sep = ",")
obs<-a[,2]
mod<-a[,3]

obs<-ifelse(obs==0,NA,obs)
mod<-ifelse(obs==0,NA,mod)
rmserror(mod,obs,na.rm=T)
mbias(obs,mod,na.rm=T)




