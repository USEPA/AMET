############################################################################################
### Statistic: RMSE 1, BIAS 2, COR 3
stat     <-1
statname <-c("RMSE","BIAS","COR")
# Increment of day label on x axis; Mu
day.inc  <-10         
############################################################################################

############################################################################################
# Met Variable T2 1, Q2 2, WS 3, WD 4
metvar   <-1
varname  <-c("T2","Q2","WS10","WD10")
varunits <-c("K","g/kg","m/s","deg")
fac      <-c(1,1000,1,1)
# Range of y axis
yrange   <-c(0.8,2.25)
yrange   <-c(2,2.8)
yrange   <-c(2, 2.8)
yrange   <-c(1.0,3.5)
yrange   <-c(0,1.5)
yrange   <-c(20,125)
yrange   <-c(1.5,2.75)
yrange   <-c(1.5,4.0)
############################################################################################

metvar   <-3
yrange   <-c(1,2.5)

metvar   <-2
yrange   <-c(0,3.0)

metvar   <-1
yrange   <-c(1.5,4.0)

############################################################################################
### RUN INFORMATION
runs    <-c("disaq_4_ltgno","disaq_4_ltgno_grell_ic3","disaq_1_ltgno_nf_nd","disaq_1_grell")
subrun  <-c("JUL2011_1km","JUL2011_1km","JUL2011_1km","JUL2011_1km")
runlab  <-c("4km_K-F","4km_Grell","1km_K-F","1km_Grell")
plotdir <-"/home/grc/AMET_v13/output/disaq_1_grell/daily_barplot"
############################################################################################
############################################################################################
### RUN INFORMATION
runs    <-c("mpas52_12km_epaphys_nlcd40f","mpas52_12km_epaphys_thomtr1","mpas52_12km_epaphys_thomtr2",
            "mpas52_12km_epaphys_nlcd40f","mpas52_12km_epaphys_thomtr1","mpas52_12km_epaphys_thomtr2")
subrun  <-c("JUL2016_CONUS","JUL2016_CONUS","JUL2016_CONUS","JUL2016_GLOBAL","JUL2016_GLOBAL","JUL2016_GLOBAL")

runlab  <-c("CONUS_WSM6tr1","CONUS_THOMtr1","CONUS_THOMtr2","GLOBAL_WSM6tr1","GLOBAL_THOMtr1","GLOBAL_THOMtr2")
plotdir <-"/home/grc/AMET_v13/output/mpas52_12km_epaphys_nlcd40f/daily_barplot"
############################################################################################
############################################################################################
### RUN INFORMATION
runs    <-c("mpas52_12km_epaphys_nlcd40f","wrf_conus12_nrt","mpas52_12km_epaphys_nlcd40f")
subrun  <-c("JJA2016_CONUS","JJA2016_CONUS","JJA2016_GLOBAL")

runs    <-c("mpas52_12km_epaphys_nlcd40f","mpas52_25km_epaphys_nlcd40f","mpas52_25km_epaphys_nonnegKF",
            "mpas52_12km_epaphys_nlcd40f","mpas52_25km_epaphys_nlcd40f","mpas52_25km_epaphys_nonnegKF")
subrun  <-c("AMJ2016_CONUS","AMJ2016_CONUS","AMJ2016_CONUS","AMJ2016_GLOBAL","AMJ2016_GLOBAL","AMJ2016_GLOBAL")
subrun  <-c("JAS2016_CONUS","JAS2016_CONUS","JAS2016_CONUS","JAS2016_GLOBAL","JAS2016_GLOBAL","JAS2016_GLOBAL")
runlab  <-c("MPAS_46-12_CONUS","MPAS_92-25_CONUS","MPAS_92-25_CONUS_nonnegKF",
            "MPAS_46-12_GLOBAL","MPAS_92-25_GLOBAL","MPAS_92-25_GLOBAL_nonnegKF")

runs    <-c("mpas52_12km_epaphys_nlcd40f","mpas52_12km_epaphys_obsgrid","mpas52_12km_epaphys_obsgrid2","wrf_conus12_oaqps")
subrun  <-c("JULY2016_CONUS","JULY2016_CONUS","JULY2016_CONUS","JULY2016_CONUS")
runlab  <-c("MPAS_46-12_CONUS","MPAS_46-12_OBSGRID","MPAS_46-12_OBSGRID2","WRF12_OAQPS")
plotdir <-"/home/grc/AMET_v13/output/mpas52_12km_epaphys_obsgrid2/daily_barplot"

runs    <-c("mpas52_12km_epaphys_obsgrid2","wrfcmaq_aqmeii2_2006_base","wrf_conus_2007","wrfcmaq_aqmeii2_2010_base","wrf_conus_2011","wrf_conus_12km","wrf_conus_12km","wrf_conus12_oaqps")
subrun  <-c("JULY2016_CONUS","JULY2006_CONUS","JULY2007_CONUS","JULY2010_CONUS","JULY2011_CONUS","JULY2013_CONUS","JULY2015_CONUS","JULY2016_CONUS")
runlab  <-c("MPAS_46-12_OBSGRID","WRF12_2006","WRF12_2007","WRF12_2010","WRF12_2011","WRF12_2013","WRF12_2015","WRF12_2016_OAQPS")
plotdir <-"/home/grc/AMET_v13/output/wrf_conus_12km/daily_barplot"

runs    <-c("mpas52_12km_epaphys_nlcd40f","mpas52_12km_epaphys_obsgrid2","wrf_conus12_nrt2","wrf_conus12_oaqps")
subrun  <-c("JA2016_CONUS","JA2016_CONUS","JA2016_CONUS","JA2016_CONUS")
runlab  <-c("MPAS_46-12_CONUS","MPAS_46-12_OBSGRID","WRF12_NRT2016","WRF12_OAQPS")
plotdir <-"/home/grc/AMET_v13/output/mpas52_12km_epaphys_obsgrid/daily_barplot"

# Main 2016 Stats for the year
runs    <-c("mpas52_12km_epaphys_nlcd40f","mpas52_25km_epaphys_nlcd40f","mpas52_12km_epaphys_nlcd40f","mpas52_25km_epaphys_nlcd40f","wrf_conus12_nrt","wrf_conus12_oaqps")
subrun  <-c("JFM2016_CONUS","JFM2016_CONUS","JFM2016_GLOBAL","JFM2016_GLOBAL","JFM2016_CONUS","JFM2016_CONUS")
subrun  <-c("AMJ2016_CONUS","AMJ2016_CONUS","AMJ2016_GLOBAL","AMJ2016_GLOBAL", "AMJ2016_CONUS","AMJ2016_CONUS")
subrun  <-c("JAS2016_CONUS","JAS2016_CONUS","JAS2016_GLOBAL","JAS2016_GLOBAL","JAS2016_CONUS","JAS2016_CONUS")
runlab  <-c("MPAS_46-12_CONUS","MPAS_92-25_CONUS","MPAS_46-12_GLOBAL","MPAS_92-25_GLOBAL","WRF_CONUS12_NRT","WRF_CONUS12_OAQPS")
subrun  <-c("OND2016_CONUS","OND2016_CONUS","OND2016_GLOBAL","OND2016_GLOBAL","OND2016_CONUS","OND2016_CONUS")
plotdir <-"/home/grc/AMET_v13/output/mpas52_12km_epaphys_nlcd40f/daily_barplot"

# Compare Patrick's NOAH run to PX 
runs    <-c("mpas52_12km_epaphys_nlcd40f","MPAS52_4612_J_D_16_NM15YMOFCU")
subrun  <-c("JAS2016_CONUS","JAS2016_CONUS")
runlab  <-c("MPAS_46-12_PXACM","MPAS_46-12_NOAHMOSAIC")
plotdir <-"/home/grc/AMET_v13/output/MPAS52_4612_J_D_16_NM15YMOFCU/daily_barplot"

# MPAS Grid Scale
runs    <-c("mpas52_12km_epaphys_nlcd40f","mpas52_25km_epaphys_nlcd40f","mpas52_12km_epaphys_nlcd40f","mpas52_25km_epaphys_nlcd40f")
subrun  <-c("AMJ2016_CONUS","AMJ2016_CONUS","AMJ2016_GLOBAL","AMJ2016_GLOBAL")
subrun  <-c("OND2016_CONUS","OND2016_CONUS","OND2016_GLOBAL","OND2016_GLOBAL")
subrun  <-c("JAS2016_CONUS","JAS2016_CONUS","JAS2016_GLOBAL","JAS2016_GLOBAL")
subrun  <-c("JFM2016_CONUS","JFM2016_CONUS","JFM2016_GLOBAL","JFM2016_GLOBAL")
runlab  <-c("MPAS_12km_CONUS","MPAS_25km_CONUS","MPAS_46km_GLOBAL","MPAS_92km_GLOBAL")
plotdir <-"/home/grc/AMET_v13/output/mpas52_12km_epaphys_nlcd40f/daily_barplot"

# Main 2016 Stats WRF VS MPAS at 12 km CONUS
runs    <-c("mpas52_12km_epaphys_obsgrid2","wrf_conus12_nrt2","wrf_conus12_oaqps")
runs    <-c("mpas52_12km_epaphys_nlcd40f","wrf_conus12_nrt","wrf_conus12_oaqps")
subrun  <-c("JAS2016_CONUS","JAS2016_CONUS","JAS2016_CONUS")
subrun  <-c("JFM2016_CONUS","JFM2016_CONUS","JFM2016_CONUS")
subrun  <-c("AMJ2016_CONUS","AMJ2016_CONUS","AMJ2016_CONUS")
subrun  <-c("OND2016_CONUS","OND2016_CONUS","OND2016_CONUS")
runlab  <-c("MPAS 12km_CONUS","WRF_12km_NRT","WRF_12km_OAQPS")
plotdir <-"/home/grc/AMET_v13/output/mpas52_12km_epaphys_nlcd40f/daily_barplot/WRFvsMPAS_CONUS12"

# Main 2016 Stats WRF VS MPAS at 12 km CONUS
runs    <-c("wrfv4_conus12_base","wrfv4_conus12_modis","wrfv4_conus12_soil")
subrun  <-c("Apr-Jul2016","Apr-Jul2016","Apr-Jul2016")
runlab  <-c("WRFv4.0_BASE","WRFv4.0_MODIS","WRFv4.0_SOIL")
plotdir <-"/home/grc/AMET_v13/output/wrfv4_conus12_modis/daily_barplot"

runs    <-c("wrfv4_conus12_base","wrfv4_conus12_basererun")
subrun  <-c("TEST","TEST")
runlab  <-c("WRFv4.0_BASE","BASE2")
plotdir <-"/home/grc/AMET_v13/output/wrfv4_conus12_base/daily_barplot"

# Main 2019 NRT statistics for WRFV4-CMAQ5.3 testing
runs    <-c("wrfv4_hyb_modis","wrf_conus12_nrt")
subrun  <-c("WRFV4SENS","WRFV4SENS")
runlab  <-c("WRFv4_Hyb","WRFv3.8_NoHyb")
plotdir <-"/home/grc/AMET_v13/output/wrfv4_hyb_modis/daily_barplot"

# PFAS 4 and 1 km run compared to 12 km
runs    <-c("listos12_base","pfas4","pfas1")
subrun  <-c("PFASCOMP1","PFASCOMP1","PFASCOMP1")
runlab  <-c("CONUS12","PFAS4","PFAS1")
plotdir <-"/home/grc/AMET_v13/output/pfas1/daily_barplot"

# Main 2019 NRT statistics for WRFV4-CMAQ5.3 testing
runs    <-c("wrfv41_hyb_modis","wrfv4_hyb_nomodis","wrf_conus12_oaqps")
subrun  <-c("ONDALL","ONDALL","ONDALL")
runlab  <-c("WRFv41_Hyb_MODIS_LTGN","WRFv40_Hyb_NOMODIS","WRFv38_LTGN")
plotdir <-"/home/grc/AMET_v13/output/wrfv41_hyb_modis/daily_barplot"




# MPAS Paper Summer with OG run
runs    <-c("wrfv4_hyb_nomodis","mpas52_12km_epaphys_nlcd40f","mpas52_25km_epaphys_nlcd40f","MPAS52_4612_J_D_16_NM15YMOFCU")
subrun  <-c("OND_CONUS","OND_CONUS","OND_CONUS","OND_CONUS")
subrun  <-c("AMJ_CONUS","AMJ_CONUS","AMJ_CONUS","AMJ_CONUS")
subrun  <-c("JFM_CONUS","JFM_CONUS","JFM_CONUS","JFM_CONUS")
runlab  <-c("WRF12","MPAS12","MPAS25","MPASNOAH")
plotdir <-"/home/grc/AMET_v13/output/mpas52_12km_epaphys_nlcd40f/daily_barplot"


# 2016 WRFV4.1 Sensitivities
runs    <-c("wrfv41_hyb_modis","wrfv41_hyb_noltng")
subrun  <-c("ONDALL","ONDALL")
subrun  <-c("JASALL","JASALL")
subrun  <-c("AMJALL","AMJALL")
subrun  <-c("JFMALL","JFMALL")
runlab  <-c("WRFv41_LTGN","WRFv41_NOLTNG")
plotdir <-"/home/grc/AMET_v13/output/wrfv41_hyb_noltng/daily_barplot"

# 2016 WRFV4.1 Sensitivities
runs    <-c("denver12_base","denver4_base","denver12_base","denver4_base")
subrun  <-c("COLORADO","COLORADO","COLORADO_METAR","COLORADO_METAR")
runlab  <-c("WRF12","WRF4","WRF12_METAR","WRF4_METAR")
plotdir <-"/home/grc/AMET_v13/output/denver12_base/daily_barplot"


# MPAS Paper Summer with OG run
runs    <-c("wrfv4_hyb_nomodis","mpas52_12km_epaphys_nlcd40f","mpas52_25km_epaphys_nlcd40f","MPAS52_4612_J_D_16_NM15YMOFCU","mpas52_12km_epaphys_obsgrid2")
subrun  <-c("JAS_CONUS","JAS_CONUS","JAS_CONUS","JAS_CONUS","JAS_CONUS")
subrun  <-c("JFM_CONUS","JFM_CONUS","JFM_CONUS","JFM_CONUS","JFM_CONUS")
subrun  <-c("AMJ_CONUS","AMJ_CONUS","AMJ_CONUS","AMJ_CONUS","AMJ_CONUS")
subrun  <-c("OND_CONUS","OND_CONUS","OND_CONUS","OND_CONUS","OND_CONUS")
runlab  <-c("WRF12","MPAS12","MPAS25","MPASNOAH","MPASOG")
plotdir <-"/home/grc/AMET_v13/output/mpas52_12km_epaphys_obsgrid2/daily_barplot"

# 2016 WRFV4.1 Sensitivities
runs    <-c("denver4_base_gdit","denver4_wrfv43","denver4_wrfv43_mskf")
subrun  <-c("COLORADO_METAR","COLORADO_METAR","COLORADO_METAR")
runlab  <-c("WRFv38KF2","WRFv43KF2","WRFv43MSKF")
plotdir <-"/home/grc/AMET_v13/output/denver4_wrfv43_mskf/daily_barplot"

# 2016 WRFV4.1 Sensitivities
runs    <-c("nlcd40_old","nlcd40_new")
subrun  <-c("JUL2016","JUL2016")
runlab  <-c("NLCD40_OLD","NLCD40_NEW")
plotdir <-"/home/grc/AMET_v13/output/nlcd40_old/daily_barplot"

# 2016 WRFV4.1 Sensitivities
runs    <-c("wrfv411_ltng_goodluf","wrfv411_ltng_badluf")
subrun  <-c("CONUS_2016_JFM","CONUS_2016_JFM")
subrun  <-c("CONUS_2016_AMJ","CONUS_2016_AMJ")
subrun  <-c("CONUS_2016_OND","CONUS_2016_OND")
subrun  <-c("CONUS_2016_JAS","CONUS_2016_JAS")
runlab  <-c("NLCD40_ORIG","NLCD40_ERROR")
plotdir <-"/home/grc/AMET_v13/output/wrfv411_ltng_goodluf/daily_barplot"

# 2016 WRFV4.1 Sensitivities
runs    <-c("wrfv433_12us1_ltng","wrfv433_12us1_mskf")
subrun  <-c("JAN_APR2018","JAN_APR2018")
runlab  <-c("BASE","MSKF")
plotdir <-"/home/grc/AMET_v13/output/wrfv433_12us1_mskf/daily_barplot"

############################################################################################

########  DAYS to Compare




## JAN - MAR
days<-c("20160101","20160102","20160103","20160104","20160105","20160106","20160107","20160108","20160109","20160110","20160111","20160112","20160113",
        "20160114","20160115","20160116","20160117","20160118","20160119","20160120","20160121","20160122","20160123","20160124","20160125","20160126",
        "20160127","20160128","20160129","20160130","20160131","20160201","20160202","20160203","20160204","20160205","20160206","20160207","20160208",
        "20160209","20160210","20160211","20160212","20160213","20160214","20160215","20160216","20160217","20160218","20160219",
        "20160220","20160221","20160222","20160223","20160224","20160225","20160226","20160227","20160228","20160229","20160301",
        "20160302","20160303","20160304","20160305","20160306","20160307","20160308","20160309","20160310","20160311","20160312",
        "20160313","20160314","20160315","20160316","20160317","20160318","20160319","20160320","20160321","20160322","20160323",
        "20160324","20160325","20160326","20160327","20160328","20160329")

# APR - JUN
days<-c("20160401","20160402","20160403","20160404","20160405","20160406","20160407","20160408","20160409","20160410","20160411","20160412","20160413",
        "20160414","20160415","20160416","20160417","20160418","20160419","20160420","20160421","20160422","20160423","20160424","20160425","20160426",
        "20160427","20160428","20160429","20160430","20160501","20160502","20160503","20160504","20160505","20160506","20160507","20160508",
        "20160509","20160510","20160511","20160512","20160513","20160514","20160515","20160516","20160517","20160518","20160519",
        "20160520","20160521","20160522","20160523","20160524","20160525","20160526","20160527","20160528","20160529","20160530","20160531","20160601",
        "20160602","20160603","20160604","20160605","20160606","20160607","20160608","20160609","20160610","20160611","20160612",
        "20160613","20160614","20160615","20160616","20160617","20160618","20160619","20160620","20160621","20160622","20160623",
        "20160624","20160625","20160626","20160627","20160628","20160629")


# OCT - DEC
days<-c("20161001","20161002","20161003","20161004","20161005","20161006","20161007","20161008","20161009","20161010","20161011","20161012","20161013",
        "20161014","20161015","20161016","20161017","20161018","20161019","20161020","20161021","20161022","20161023","20161024","20161025","20161026",
        "20161027","20161028","20161029","20161030","20161031","20161101","20161102","20161103","20161104","20161105","20161106","20161107","20161108",
        "20161109","20161110","20161111","20161112","20161113","20161114","20161115","20161116","20161117","20161118","20161119",
        "20161120","20161121","20161122","20161123","20161124","20161125","20161126","20161127","20161128","20161129","20161130","20161201",
        "20161202","20161203","20161204","20161205","20161206","20161207","20161208","20161209","20161210","20161211","20161212",
        "20161213","20161214","20161215","20161216","20161217","20161218","20161219","20161220","20161221","20161222","20161223",
        "20161224","20161225","20161226","20161227","20161228","20161229","20161230")

# JUL - SEP
days<-c("20160701","20160702","20160703","20160704","20160705","20160706","20160707","20160708","20160709","20160710","20160711","20160712","20160713",
        "20160714","20160715","20160716","20160717","20160718","20160719","20160720","20160721","20160722","20160723","20160724","20160725","20160726",
        "20160727","20160728","20160729","20160730","20160731","20160801","20160802","20160803","20160804","20160805","20160806","20160807","20160808",
        "20160809","20160810","20160811","20160812","20160813","20160814","20160815","20160816","20160817","20160818","20160819",
        "20160820","20160821","20160822","20160823","20160824","20160825","20160826","20160827","20160828","20160829","20160830","20160831","20160901",
        "20160902","20160903","20160904","20160905","20160906","20160907","20160908","20160909","20160910","20160911","20160912",
        "20160913","20160914","20160915","20160916","20160917","20160918","20160919","20160920","20160921","20160922","20160923",
        "20160924","20160925","20160926","20160927","20160928","20160929","20160930")

days<-c("20180101","20180102","20180103","20180104","20180105","20180106","20180107","20180108","20180109","20180110","20180111","20180112","20180113",
        "20180114","20180115","20180116","20180117","20180118","20180119","20180120","20180121","20180122","20180123","20180124","20180125","20180126",
        "20180127","20180128","20180129","20180130","20180131","20180201","20180202","20180203","20180204","20180205","20180206","20180207","20180208",
        "20180209","20180210","20180211","20180212","20180213","20180214","20180215","20180216","20180217","20180218","20180219",
        "20180220","20180221","20180222","20180223","20180224","20180225","20180226","20180227","20180228","20180301",
        "20180302","20180303","20180304","20180305","20180306","20180307","20180308","20180309","20180310","20180311","20180312",
        "20180313","20180314","20180315","20180316","20180317","20180318","20180319","20180320","20180321","20180322","20180323")


plotdir<-paste(plotdir,"/",subrun[1],sep="")

nt<-length(days)
colorslate<-c("blue","red","chartreuse3","orange","brown","blueviolet","gray45","hotpink","seagreen1")
nruns<-length(runs)
runcols<-rainbow(nruns)
runcols<-colorslate[1:nruns]
#runcols[nruns]<-"black"
stats<-array(NA,c(nruns,nt,5,3))

for(r in 1:nruns){
 load(paste("/home/grc/AMET_v13/output/",runs[r],"/daily_barplot/",runs[r],".",subrun[r],".daily_barplot.Rdata",sep=""))
 stats[r,,1:5,1]<-RMSEData[1:nt,1:5]
 stats[r,,1:4,2]<-biasData[1:nt,1:4]
 stats[r,,1:4,3]<-corData[1:nt,1:4]
}

system(paste("mkdir -p",plotdir))

########################################################
metvar   <-1
yrange   <-c(-2,2)
yrange   <-c(1.5,3.0)

plot.name<-paste(plotdir,"/dailystats.",varname[metvar],".",statname[stat],".pdf",sep="")
writeLines(paste("Plot name/location:",plot.name))
pdf(plot.name,width = 10, height = 5)
par(new=F)
for(r in 1:(nruns-1)){
# plot(days,stats[r,,metvar,stat]*fac[metvar],col=runcols[r],type='l',ylim=yrange,xlab="",ylab="")
 plot(1:length(days),stats[r,,metvar,stat]*fac[metvar],col=runcols[r],type='l',ylim=yrange,xlab="",ylab="", lwd=2, axes=FALSE)
 par(new=T)
}
r<-r+1
#plot(days,stats[r,,metvar,stat]*fac[metvar],col=runcols[r],type='l',ylim=yrange,xlab="Day",ylab=paste(statname[stat],"(",varunits[metvar],")"))
plot(1:length(days),stats[r,,metvar,stat]*fac[metvar],col=runcols[r],type='l',ylim=yrange,xlab="Day",ylab=paste(statname[stat],"(",varunits[metvar],")"), lwd=2, axes=FALSE)
par(tck=1)
axis(2,col="gray",lty=3)
par(tck=1)
axis(1,col="gray",lty=3,at=seq(1,length(days),by=day.inc),labels=as.character(days[seq(1,length(days),by=day.inc)]))
box()
legend("bottomleft",runlab,text.col=runcols,cex=.6)     
title(paste("Daily",statname[stat]," of ",varname[metvar]))
dev.off()
########################################################

########################################################
metvar   <-2
yrange   <-c(-1,1)
yrange   <-c(0.5,1.5)
yrange   <-c(0,2.0)

plot.name<-paste(plotdir,"/dailystats.",varname[metvar],".",statname[stat],".pdf",sep="")
writeLines(paste("Plot name/location:",plot.name))
pdf(plot.name,width = 10, height = 5)
par(new=F)
for(r in 1:(nruns-1)){
# plot(days,stats[r,,metvar,stat]*fac[metvar],col=runcols[r],type='l',ylim=yrange,xlab="",ylab="")
 plot(1:length(days),stats[r,,metvar,stat]*fac[metvar],col=runcols[r],type='l',ylim=yrange,xlab="",ylab="", lwd=2, axes=FALSE)
 par(new=T)
}
r<-r+1
#plot(days,stats[r,,metvar,stat]*fac[metvar],col=runcols[r],type='l',ylim=yrange,xlab="Day",ylab=paste(statname[stat],"(",varunits[metvar],")"))
plot(1:length(days),stats[r,,metvar,stat]*fac[metvar],col=runcols[r],type='l',ylim=yrange,xlab="Day",ylab=paste(statname[stat],"(",varunits[metvar],")"), lwd=2, axes=FALSE)
par(tck=1)
axis(2,col="gray",lty=3)
par(tck=1)
axis(1,col="gray",lty=3,at=seq(1,length(days),by=day.inc),labels=as.character(days[seq(1,length(days),by=day.inc)]))
box()
legend("bottomleft",runlab,text.col=runcols,cex=.6)     
title(paste("Daily",statname[stat]," of ",varname[metvar]))
dev.off()
########################################################

########################################################
metvar   <-3
#stat <-3
yrange   <-c(-1.25,1.25)
yrange   <-c(1.5,2.2)
#yrange <-c(0,1)
plot.name<-paste(plotdir,"/dailystats.",varname[metvar],".",statname[stat],".pdf",sep="")
writeLines(paste("Plot name/location:",plot.name))
pdf(plot.name,width = 10, height = 5)
par(new=F)
for(r in 1:(nruns-1)){
# plot(days,stats[r,,metvar,stat]*fac[metvar],col=runcols[r],type='l',ylim=yrange,xlab="",ylab="")
 plot(1:length(days),stats[r,,metvar,stat]*fac[metvar],col=runcols[r],type='l',ylim=yrange,xlab="",ylab="", lwd=2, axes=FALSE)
 par(new=T)
}
r<-r+1
#plot(days,stats[r,,metvar,stat]*fac[metvar],col=runcols[r],type='l',ylim=yrange,xlab="Day",ylab=paste(statname[stat],"(",varunits[metvar],")"))
plot(1:length(days),stats[r,,metvar,stat]*fac[metvar],col=runcols[r],type='l',ylim=yrange,xlab="Day",ylab=paste(statname[stat],"(",varunits[metvar],")"), lwd=2, axes=FALSE)
par(tck=1)
axis(2,col="gray",lty=3)
par(tck=1)
axis(1,col="gray",lty=3,at=seq(1,length(days),by=day.inc),labels=as.character(days[seq(1,length(days),by=day.inc)]))
box()
legend("bottomleft",runlab,text.col=runcols,cex=.6)     
title(paste("Daily",statname[stat]," of ",varname[metvar]))
dev.off()
########################################################









