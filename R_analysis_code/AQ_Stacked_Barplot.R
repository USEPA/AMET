################################################################
### THIS FILE CONTAINS CODE TO DRAW A CUSTOMIZED "STACKED BAR PLOT".
### The code is interactive with the AMET_AQ system developed by
### Wyat Appel.  Data are queried from the MYSQL database for the STN
### network.  Data are then averaged for SO4, NO3, NH4, EC, OC and PM2.5
### for the model and ob values.  These averages are then plotted on
### a stacked bar plot, along with the percent of the total PM2.5
### that each specie comprises.
###
### Last updated by Wyat Appel: April, 2017 
################################################################

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")        # base directory of AMET
dbase           <- Sys.getenv("AMET_DATABASE")      # AMET database
ametR           <- paste(ametbase,"/R_analysis_code",sep="")      # R directory
ametRinput      <- Sys.getenv("AMETRINPUT")  # input file for this script
ametptype       <- Sys.getenv("AMET_PTYPE")   # Prefered output type
## Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
## and not specified via AMET_OUT, then set figdir to the current directory
if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")       }
if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"                 }

## source some configuration files, AMET libs, and input
source(paste(ametbase,"/configure/amet-config.R",sep=""))
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file
source(ametRinput)                                     # Anaysis configuration/input file

## Load Required Libraries 
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}

mysql <- list(login=amet_login, passwd=amet_pass, server=mysql_server, dbase=dbase, maxrec=maxrec)

network <- network_names[1]
network_name <- network_label[1]
num_runs <- 1   

### Retrieve units and model labels from database table ###
model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
model_name <- db_Query(model_name_qs,mysql)
################################################

### Set filenames and titles ###
filename_pdf    <- paste(run_name1,pid,"stacked_barplot.pdf",sep="_")
filename_png    <- paste(run_name1,pid,"stacked_barplot.png",sep="_")
filename_txt    <- paste(run_name1,pid,"stacked_barplot_data.csv",sep="_")

## Create a full path to file
filename_pdf <- paste(figdir,filename_pdf,sep="/")      # Set PDF filename
filename_png <- paste(figdir,filename_png,sep="/")      # Set PNG filenam
filename_txt <- paste(figdir,filename_txt,sep="/")      # Set output file name

method <- "Mean"
if (use_median == "y") {
   method <- "Median"
}

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(network_name," Stacked Barplot (",method,") for ",run_name1," for ",dates,sep="") }
   else { title <- custom_title }
}

################################

if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   num_runs <- 2
}

if (species == "") {	# Default to normal PM_TOT if species not selected
   species <- "PM_TOT"
}


medians          <- NULL
data             <- NULL
medians_2        <- NULL
data2            <- NULL
drop_names     <- NULL
species_names  <- NULL
species_names2 <- NULL
correlation    <- NULL
correlation2   <- NULL
rmse           <- NULL
rmse2          <- NULL
rmse_sys       <- NULL
rmse_sys2      <- NULL
rmse_unsys     <- NULL
rmse_unsys2    <- NULL

criteria <- paste(" WHERE d.SO4_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
#criteria <- paste(" WHERE d.SO4_ob is not NULL",query,sep="")
qs <- paste("SELECT d.proj_code,d.network,d.stat_id,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.SO4_ob,d.SO4_mod,d.NO3_ob,d.NO3_mod,d.NH4_ob,d.NH4_mod,d.EC_ob,d.EC_mod,d.OC_ob,d.OC_mod,d.",species,"_ob,d.",species,"_mod,d.TC_ob,d.TC_mod from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")
aqdat_all.df <- db_Query(qs,mysql)
aqdat_all.df$NH4_ob[aqdat_all.df$NH4 == -999] <- 0.2903*aqdat_all.df$NO3_ob+0.375*aqdat_all.df$SO4_ob
aqdat_store.df <- aqdat_all.df

if (num_runs > 1) {
   qs <- paste("SELECT d.proj_code,d.network,d.stat_id,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.SO4_ob,d.SO4_mod,d.NO3_ob,d.NO3_mod,d.NH4_ob,d.NH4_mod,d.EC_ob,d.EC_mod,d.OC_ob,d.OC_mod,d.",species,"_ob,d.",species,"_mod,d.TC_ob,d.TC_mod from ",run_name2," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")
   aqdat_all2.df <- db_Query(qs,mysql)
   aqdat_all2.df$NH4_ob[aqdat_all2.df$NH4 == -999] <- 0.2903*aqdat_all2.df$NO3_ob+0.375*aqdat_all2.df$SO4_ob
}

##########################################################
### Average all data for a species into a single value ###
##########################################################
l <- 8                                                  # offset for first species ob value

aqdat_sub.df <- aqdat_all.df
len <- length(aqdat_sub.df)

while (l < len) {                                       # loop through each column
   indic.nonzero <- aqdat_sub.df[,l] >= 0               # determine missing data from ob column
   aqdat_sub.df <- aqdat_sub.df[indic.nonzero,]         # remove missing model/ob pairs from dataframe
   l <- l+1
}
num_sites <- length(unique(aqdat_sub.df$stat_id))
num_pairs <- length(aqdat_sub.df$stat_id)

data.df         <- aqdat_sub.df[8:len]
{
   if (use_median == "y") {
      medians.df        <- lapply(data.df,median)
   }
   else {
      medians.df   <- lapply(data.df,mean)
   }
}
TC_ob  <- medians.df$EC_ob+medians.df$OC_ob
TC_mod <- medians.df$EC_mod+medians.df$OC_mod
##############################################################

if (num_runs > 1) {
   l <- 8                                          # offset for first species ob value

   aqdat_sub2.df <- aqdat_all2.df
   len <- length(aqdat_sub2.df)
   while (l < len) {                                       # loop through each column
      indic.nonzero <- aqdat_sub2.df[,l] >= 0               # determine missing data from ob column
      aqdat_sub2.df <- aqdat_sub2.df[indic.nonzero,]         # remove missing model/ob pairs from dataframe
      l <- l+1
   }

   data2.df     <- aqdat_sub2.df[8:len]
   {
      if (use_median == "y") {
         medians2.df        <- lapply(data2.df,median)
      }
      else {
         medians2.df   <- lapply(data2.df,mean)
      }
   }
   num_sites_2 <- length(unique(aqdat_sub2.df$stat_id))
   num_pairs_2 <- length(aqdat_sub2.df$stat_id)
   TC_ob2  <- medians2.df$EC_ob+medians2.df$OC_ob
   TC_mod2 <- medians2.df$EC_mod+medians2.df$OC_mod
}

###############################################################
### Calculate percent of total PM2.5 each species comprises ###
###############################################################
other_ob      <- data.df[,11]-(data.df$SO4_ob+data.df$NO3_ob+data.df$NH4_ob+data.df$EC_ob+data.df$OC_ob)
med_other_ob      <- median(other_ob)
total_ob          <- data.df[,11]

SO4_ob_percent   <- round(medians.df$SO4_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+med_other_ob)*100,1)
NO3_ob_percent   <- round(medians.df$NO3_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+med_other_ob)*100,1)
NH4_ob_percent   <- round(medians.df$NH4_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+med_other_ob)*100,1)
EC_ob_percent    <- round(medians.df$EC_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+med_other_ob)*100,1)
OC_ob_percent    <- round(medians.df$OC_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+med_other_ob)*100,1)
TC_ob_percent    <- round(TC_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+med_other_ob)*100,1)
Other_ob_percent <- round(med_other_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+med_other_ob)*100,1)

other_mod      <- data.df[,11]-(data.df$SO4_mod+data.df$NO3_mod+data.df$NH4_mod+data.df$EC_mod+data.df$OC_mod)
med_other_mod    <- median(other_mod)
total_mod        <- data.df[,12]

SO4_mod_percent   <- round(medians.df$SO4_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+med_other_mod)*100,1)
NO3_mod_percent   <- round(medians.df$NO3_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+med_other_mod)*100,1)
NH4_mod_percent   <- round(medians.df$NH4_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+med_other_mod)*100,1)
EC_mod_percent    <- round(medians.df$EC_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+med_other_mod)*100,1)
OC_mod_percent    <- round(medians.df$OC_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+med_other_mod)*100,1)
TC_mod_percent    <- round(TC_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+med_other_mod)*100,1)
Other_mod_percent <- round(med_other_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+med_other_mod)*100,1)

correlation	<- round(cor(total_mod, total_ob),2)
rmse 		<- round(sqrt(c(rmse, sum((data.df[,12] - data.df[,11])^2)/length(data.df[,11]))),2)
ls_regress	<- lsfit(total_ob,total_mod)
intercept	<- ls_regress$coefficients[1]
X		<- ls_regress$coefficients[2]
rmse_sys	<- round(sqrt(c(rmse_sys, sum(((intercept+X*total_ob) - total_ob)^2))/length(total_ob)),2)
rmse_unsys	<- round(sqrt(c(rmse_unsys, sum((total_mod - (intercept+X*total_ob))^2)/length(total_ob))),2) 
index_agree	<- round(1-((sum((data.df[,11]-data.df[,12])^2))/(sum((abs(data.df[,12]-mean(data.df[,11]))+abs(data.df[,11]-mean(data.df[,11])))^2))),2)

if (num_runs > 1) {
   other_mod2         <- data2.df[,11]-(data2.df$SO4_mod+data2.df$NO3_mod+data2.df$NH4_mod+data2.df$EC_mod+data2.df$OC_mod)
   med_other_mod2    <- median(other_mod2)
   total_ob2         <- data2.df[,11]
   total_mod2        <- data2.df[,12]
   
   SO4_mod_percent2  <- round(medians2.df$SO4_mod/(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+med_other_mod2)*100,1)
   NO3_mod_percent2  <- round(medians2.df$NO3_mod/(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+med_other_mod2)*100,1)
   NH4_mod_percent2  <- round(medians2.df$NH4_mod/(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+med_other_mod2)*100,1)
   EC_mod_percent2   <- round(medians2.df$EC_mod/(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+med_other_mod2)*100,1)
   OC_mod_percent2   <- round(medians2.df$OC_mod/(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+med_other_mod2)*100,1)
   TC_mod_percent2   <- round(TC_mod2/(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+med_other_mod2)*100,1)
   Other_mod_percent2<- round(med_other_mod2/(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+med_other_mod2)*100,1)

   correlation2	<- round(cor(total_mod2, total_ob2),2)
   rmse2		<- round(sqrt(c(rmse2, sum((data2.df[,12] - data2.df[,11])^2)/length(data2.df[,11]))),2)
   ls_regress	<- lsfit(total_ob2,total_mod2)
   intercept		<- ls_regress$coefficients[1]
   X			<- ls_regress$coefficients[2]
   rmse_sys2		<- round(sqrt(c(rmse_sys2, sum(((intercept+X*total_ob2) - total_ob2)^2))/length(total_ob2)),2)
   rmse_unsys2	<- round(sqrt(c(rmse_unsys2, sum((total_mod2 - (intercept+X*total_ob2))^2)/length(total_ob2))),2)
   index_agree2	<- round(1-((sum((data2.df[,11]-data2.df[,12])^2))/(sum((abs(data2.df[,12]-mean(data2.df[,11]))+abs(data2.df[,11]-mean(data2.df[,11])))^2))),2)
}
###############################################################

   data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,medians.df$EC_ob,medians.df$EC_mod,medians.df$OC_ob,medians.df$OC_mod,med_other_ob,med_other_mod),byrow=T,ncol=2)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row

if (num_runs > 1) {
   data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians2.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians2.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,medians2.df$NH4_mod,medians.df$EC_ob,medians.df$EC_mod,medians2.df$EC_mod,medians.df$OC_ob,medians.df$OC_mod,medians2.df$OC_mod,med_other_ob,med_other_mod,med_other_mod2),byrow=T,ncol=3)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
}

yaxis.max   <- round(max(c(sum(data_matrix[,1]),sum(data_matrix[,2]))),)+5								# find the max of the average values to set y-axis max 
if (length(y_axis_max) > 0) {
   yaxis.max <- y_axis_max
}

{
   if (num_runs > 1) {
      simulations       <- paste(network_label,run_name1,run_name2,sep=",")
      sim_names         <- c(network_label[1],"Simulation 1","Simulation 2")
   }
   else {
      simulations       <- paste(network_label,run_name1,sep="")
      sim_names         <- c(network_label[1],run_name1)
   }
}

write.table(simulations,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
write.table("Observed, Modeled",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(data_matrix,file=filename_txt,append=T,col.names=F,row.names=c("SO4","NO3","NH4","EC","OC","OTHER"),sep=",")
species_names <- c("Other","OC","EC",expression(paste(NH[4]^"  +")),expression(paste(NO[3]^"  -")),expression(paste(SO[4]^"  2-")))
plot_cols     <- c("yellow","red","orange","black","grey","white")
plot_cols_leg <- c("white","grey","black","orange","red","yellow")

########## MAKE STACKED BARPLOT: ALL SITES ##########
pdf(file=filename_pdf,width=10,height=8)
par(mai=c(1,1,0.5,0.5))		# set margins

{
   if (num_runs == 1) {
      barplot(data_matrix, beside=FALSE, ylab="Concentration (ug/m3)",names.arg=sim_names,width=0.5,xlim=c(0,2),ylim=c(0,yaxis.max),col=plot_cols,xpd=F,space=.6,cex.axis=1.4,cex.names=1.4,cex.lab=1.4)
      x1_adjust <- 1
      x2_adjust <- 1
   }
   else {
      barplot(data_matrix, beside=FALSE, ylab="Concentration (ug/m3)",names.arg=sim_names,width=0.3,xlim=c(0,2),ylim=c(0,yaxis.max),col=plot_cols,xpd=F,space=.9,cex.axis=1.4,cex.names=1,cex.lab=1.4)
      x1_adjust <- .91
      x2_adjust <- .77
   }
}
legend("topright",species_names,fill=plot_cols_leg,cex=1.2)

x1 <- x1_adjust*.27
x2 <- x2_adjust*1.08
x3 <- 1.4

#########################################################################
### Add percentage values next to each specie on the stacked bar plot ###
#########################################################################
text(x1,(medians.df$SO4_ob/2),paste(SO4_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
text(x1,(medians.df$SO4_ob+(medians.df$NO3_ob/2)),paste(NO3_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+(medians.df$NH4_ob/2)),paste(NH4_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+(medians.df$EC_ob/2)),paste(EC_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+(medians.df$OC_ob/2)),paste(OC_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$TC_ob+(med_other_ob/2)),paste(Other_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0))

text(x2,(medians.df$SO4_mod/2),paste(SO4_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
text(x2,(medians.df$SO4_mod+(medians.df$NO3_mod/2)),paste(NO3_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+(medians.df$NH4_mod/2)),paste(NH4_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+(medians.df$EC_mod/2)),paste(EC_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+(medians.df$OC_mod/2)),paste(OC_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))  
text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$TC_mod+(med_other_mod/2)),paste(Other_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))

if (num_runs > 1) {
   text(x3,(medians2.df$SO4_mod/2),paste(SO4_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0))
   text(x3,(medians2.df$SO4_mod+(medians2.df$NO3_mod/2)),paste(NO3_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0))
   text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+(medians2.df$NH4_mod/2)),paste(NH4_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0))
   text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+(medians2.df$EC_mod/2)),paste(EC_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0))
   text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+(medians2.df$OC_mod/2)),paste(OC_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0))
   text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$TC_mod+(med_other_mod2/2)),paste(Other_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0))
}
##########################################################################

############################################################
### Add number of sites and number of obs counts to plot ###
############################################################
text(2.07,yaxis.max*.64,paste("# of sites: ",num_sites,sep=""),cex=1.2,adj=c(1,0))
text(2.07,yaxis.max*.60,paste("# of obs: ",num_pairs,sep=""),cex=1.2,adj=c(1,0))
if (run_info_text == "y") {
   if (rpo != "None") {
      text(2.07,yaxis.max*.55,paste("RPO: ",rpo,sep=""),cex=1,adj=c(1,0))
   }
   if (pca != "None") {
      text(2.07,yaxis.max*.51,paste("PCA: ",pca,sep=""),cex=1,adj=c(1,0))
   }
   if (site != "All") {
      text(2.07,yaxis.max*.47,paste("Site: ",site,sep=""),cex=1,adj=c(1,0))
   }
   if (state != "All") {
      text(2.07,yaxis.max*.43,paste("State: ",state,sep=""),cex=1,adj=c(1,0))
   }
} 
############################################################

###################################
### Add statistics to plot area ###
###################################
#text(2.07,yaxis.max*.38,run_name1,cex=1,adj=c(1,0))
text(2.07,yaxis.max*.35,paste("RMSE: ",rmse,sep=""),cex=1,adj=c(1,0))
text(2.07,yaxis.max*.32,paste("RMSEs: ",rmse_sys,sep=""),cex=1,adj=c(1,0))
text(2.07,yaxis.max*.29,paste("RMSEu: ",rmse_unsys,sep=""),cex=1,adj=c(1,0))
text(2.07,yaxis.max*.26,paste("r:   ",correlation,sep=""),cex=1,adj=c(1,0))

if (num_runs > 1) {
   ### Add statistics to plot area ###
   text(0,yaxis.max*0.9,paste("Simulation 1:",run_name1),cex=1,adj=c(0,0))
   text(0,yaxis.max*0.87,paste("Simulation 2:",run_name2),cex=1,adj=c(0,0))
   text(2.07,yaxis.max*.38,"Simulation 1",cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.16,"Simulation 2",cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.13,paste("RMSE: ",rmse2,sep=""),cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.10,paste("RMSEs: ",rmse_sys2,sep=""),cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.07,paste("RMSEu: ",rmse_unsys2,sep=""),cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.04,paste("r:   ",correlation2,sep=""),cex=1,adj=c(1,0))
}
######################################

## Put title at top of barplot ##
title(main=title,cex.main=1.3)

## Convert pdf to png ##
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density 150x150 ",filename_pdf," png:",filename_png,sep="")
   dev.off()
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}
########################


