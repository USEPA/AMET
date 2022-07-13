header <- "
############################ MODEL SKILL SCATTER PLOT ##############################
### AMET CODE: R_Scatterplot_skill.R 
###
### This script is part of the AMET-AQ system.  This script creates a unique forecast
### skill scatter plot.  The scipt was orinally designed to work specifically with 8-hr
### max ozone, as all the lines and stats were based on the criteria for 8-hr ozone.
### However, users can now specifiy the criteria line, and the forecast statistics are
### calculated based on the user specified criteria. So, it may be used with any species.
### Output format is png, pdf or both.
###
### Last Updated by Wyat Appel: Feb 2020
#####################################################################################
"

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

### Set file names and titles ###
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(run_name1," ",species," for ",dates,sep="") }
   else { title <- custom_title }
}

filename_pdf <- paste(run_name1,species,pid,"scatterplot_skill.pdf",sep="_")             # Set PDF filename
filename_png <- paste(run_name1,species,pid,"scatterplot_skill.png",sep="_")             # Set PNG filename
filename_txt <- paste(run_name1,species,pid,"scatterplot_skill_data.csv",sep="_")       # Set output file name


## Create a full path to file
filename_pdf <- paste(figdir,filename_pdf,sep="/")      # Set PDF filename
filename_png <- paste(figdir,filename_png,sep="/")      # Set PNG filenam
filename_txt <- paste(figdir,filename_txt,sep="/")      # Set output file name

#################################

axis.max     <- NULL
num_obs      <- NULL
sinfo        <- NULL
avg_text     <- ""
legend_names <- NULL
legend_cols  <- NULL
legend_chars <- NULL
point_char   <- NULL
point_color  <- NULL

hit_exceed    <- 0
hit_nonexceed <- 0
miss_exceed   <- 0
false_alarm   <- 0

### Retrieve units and model labels from database table ###
network <- network_names[1]
#units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
#model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
################################################

run_name <- run_name1
network <- network_names[[1]]						# Set network

#############################################
### Read sitex file or query the database ###
#############################################
{
   if (Sys.getenv("AMET_DB") == 'F') {
      sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name,species)
      aqdat_query.df   <- sitex_info$sitex_data
      data_exists      <- sitex_info$data_exists
      if (data_exists == "y") { units <- as.character(sitex_info$units[[1]]) }
      model_name       <- "Model"
   }
   else {
      query_result    <- query_dbase(run_name,network,species)
      aqdat_query.df  <- query_result[[1]]
      data_exists     <- query_result[[2]]
      if (data_exists == "y") { units <- query_result[[3]] }
      model_name      <- query_result[[4]]
   }
}
ob_col_name <- paste(species,"_ob",sep="")
mod_col_name <- paste(species,"_mod",sep="")
#############################################

#########################################################
#### Calculate statistics for each requested network ####
#########################################################

## Calculate stats using all pairs, regardless of averaging
data_all.df <- data.frame(network=I(aqdat_query.df$network),stat_id=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,ob_val=aqdat_query.df[[ob_col_name]],mod_val=aqdat_query.df[[mod_col_name]])
stats.df <-try(DomainStats(data_all.df))      # Compute stats using DomainStats function for entire domain
corr        <- NULL
rmse        <- NULL
nmb         <- NULL
nme         <- NULL
mb          <- NULL
me          <- NULL
med_bias    <- NULL
med_error   <- NULL
fb          <- NULL
fe          <- NULL
nmb         <- round(stats.df$Percent_Norm_Mean_Bias,1)
nme         <- round(stats.df$Percent_Norm_Mean_Err,1)
nmdnb       <- round(stats.df$Norm_Median_Bias,1)
nmdne       <- round(stats.df$Norm_Median_Error,1)
mb          <- round(stats.df$Mean_Bias,2)
me          <- round(stats.df$Mean_Err,2)
med_bias    <- round(stats.df$Median_Bias,2)
med_error   <- round(stats.df$Median_Error,2)
fb          <- round(stats.df$Frac_Bias,2)
fe          <- round(stats.df$Frac_Err,2)
corr        <- round(stats.df$Correlation,2)
rmse        <- round(stats.df$RMSE,2)
rmse_sys    <- round(stats.df$RMSE_systematic,2)
rmse_unsys  <- round(stats.df$RMSE_unsystematic,2)
index_agr   <- round(stats.df$Index_of_Agree,2)
#########################################################
 
######################
aqdat.df <- data.frame(Network=aqdat_query.df$network,Stat_ID=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=round(aqdat_query.df[[ob_col_name]],5),Mod_Value=round(aqdat_query.df[[mod_col_name]],5),Month=aqdat_query.df$month)	# Create dataframe of network values to be used to create a list
sinfo<-list(plotval_obs=aqdat.df$Obs_Value,plotval_mod=aqdat.df$Mod_Value)        # create of list of plot values and corresponding statistics
for (i in 1:length(sinfo$plotval_obs)) {
   if (sinfo$plotval_obs[i] >= max_limit) {
      if (sinfo$plotval_mod[i] >= max_limit) {
         hit_exceed <- hit_exceed+1
      }
      if (sinfo$plotval_mod[i] < max_limit) {
         miss_exceed <- miss_exceed+1
      }
      }
   if (sinfo$plotval_obs[i] < max_limit) {
      if (sinfo$plotval_mod[i] < max_limit) {
         hit_nonexceed <- hit_nonexceed+1                          
      }
      if (sinfo$plotval_mod[i] >= max_limit) {
         false_alarm <- false_alarm+1
      }
   }
}
Accuracy <- round((hit_nonexceed+hit_exceed)/length(sinfo$plotval_obs)*100,1)
Bias     <- round((false_alarm+hit_exceed)/(miss_exceed+hit_exceed),1)
FAR      <- round(false_alarm/(false_alarm+hit_exceed)*100,1)
CSI      <- round(hit_exceed/(false_alarm+miss_exceed+hit_exceed)*100,1)
POD      <- round(hit_exceed/(miss_exceed+hit_exceed)*100,1)
##############################
 ### Write Data to CSV File ###
##############################
write.table(run_name1,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
write.table(dates,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(aqdat.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
###############################
count <- sum(is.na(aqdat.df$Obs_Value))	# count number of NAs in column
len   <- length(aqdat.df$Obs_Value)
if (count != len) {			# test to see if data is available, if so, compute axis.max
   axis.max <- max(c(1.5*max_limit,axis.max,aqdat.df$Obs_Value,aqdat.df$Mod_Value))	# set axis limit from data obs and mod maximum
   axis.min <- axis.max * .033	# set axis minimum to look like 0 (weird R thing)
}
### If user sets axis maximum, compute axis minimum ###
if (length(y_axis_max) > 0) {
   axis.max <- y_axis_max
   axis.min <- axis.max * 0.033
}
if (length(y_axis_min) > 0) {
   axis.min <- y_axis_min
}
#######################################################

##############################################
########## MAKE SCATTERPLOT: ALL US ##########
##############################################

#### Define Stats box placement ####
axis.length <- (axis.max - axis.min)
label1 <- axis.max * 0.580
right  <- axis.max                                        # define box rightside
left   <- axis.max - (axis.length * 0.550)
bottom <- axis.min
top    <- axis.max - (axis.length * 0.820)
x7 <- axis.max - (axis.length * 0.250)                    # define right justification for run name
x6 <- axis.max - (axis.length * 0.040)                    # define right justification for NME
x5 <- axis.max - (axis.length * 0.110)                    # define right justification for NMB
x4 <- axis.max - (axis.length * 0.190)                    # define right justification for RMSEu
x3 <- axis.max - (axis.length * 0.280)                    # define right justification for RMSEs
x2 <- axis.max - (axis.length * 0.350)                    # define right justification for Index of Agreement
x1 <- axis.max - (axis.length * 0.470)                    # define right justification for Network
y1 <- axis.max - (axis.length * 0.890)                    # define y for labels
y2 <- axis.max - (axis.length * 0.860)                    # define y for run name
y3 <- axis.max - (axis.length * 0.920)                    # define y for network 1
y4 <- axis.max - (axis.length * 0.950)                    # define y for network 2
y5 <- axis.max - (axis.length * 0.980)                    # define y for network 3
y6 <- axis.max - (axis.length * 0.700)                    # define y for species text
y7 <- axis.max - (axis.length * 0.660)                    # define y for timescale (averaging)
y8 <- axis.max - (axis.length * 0.740)
y9 <- axis.max - (axis.length * 0.780)
y10 <- axis.max - (axis.length * 0.110)
y11 <- axis.max - (axis.length * 0.140)
y12 <- axis.max - (axis.length * 0.170)
y13 <- axis.max - (axis.length * 0.200)
y14 <- axis.max - (axis.length * 0.230)
y15 <- axis.max - (axis.length * 0.260)
y16 <- axis.max - (axis.length * 0.290)
y17 <- axis.max - (axis.length * 0.320)
y18 <- axis.max - (axis.length * 0.070)
x <- c(x1,x2,x3,x4,x5,x6,x7)                              		# set vector of x offsets
y <- c(y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15,y16,y17,y18)	# set vector of y offsets
######################################

### Preset values for plot characters and colors (these can be changed to user preference) ###
plot_chars <- c(0,2,3,4)                                  # set vector of plot characters
##############################################################################################
pdf(file=filename_pdf,width=8,height=8)
### Plot and draw rectangle with stats ###
par(mai=c(1,1,0.5,0.5),lab=c(8,8,7))
plot(1,1,type="n", pch=2, col="red", ylim=c(axis.min, axis.max), xlim=c(axis.min, axis.max), xlab="Observation", ylab=model_name, cex.axis=1.3, cex.lab=1.3)	# create plot axis and labels, but do not plot any points
text(axis.max,y[6], paste(species," (",units,")"),cex=1.2,adj=c(1,0))		# add species text
##########################################

### Put title at top of boxplot ###
title(main=title,cex.main=1.1)
###################################

### Plot points and stats for each network ###
point_color <- plot_colors[1]
points(sinfo$plotval_obs,sinfo$plotval_mod,pch=plot_chars[1],col=plot_colors[1],cex=.8)  # plot points for each network
legend_names <- c(legend_names,paste(network_label[1]," (",run_name,")",sep=""))
legend_cols  <- c(legend_cols,plot_colors[1])
legend_chars <- c(legend_chars,plot_chars[1])
   
##############################################

### Put 1-to-1 lines and confidence lines on plot ###
abline(h=max_limit)
abline(v=max_limit)

### Add descripitive text to plot area ###
if (run_info_text == "y") {
   if (rpo != "None") {   
      text(x=x[1],y=y[8], paste("RPO = ",rpo,sep=""),cex=1,adj=c(0,.5))		# add RPO region to plot
   }
   if (pca != "None") {
      text(x=x[4],y=y[8], paste("PCA = ",pca,sep=""),cex=1,adj=c(0.25,0.5))	# add PCA region to plot
   }
   if (state != "All") {
      text(x=x[1],y=y[9], paste("State = ",state,sep=""),cex=1,adj=c(0,.5))	# add State abbreviation to plot
   }
   if (site != "All") {
      text(x=x[4],y=y[9], paste("Site = ",site,sep=""),cex=1)			# add Site name to plot
   }
}
text(x=0.953*max_limit,y=0.953*max_limit,hit_nonexceed,cex=1.5,pos=2)
text(x=0.953*max_limit,y=1.047*max_limit,false_alarm,cex=1.5,pos=2)
text(x=1.047*max_limit,y=1.047*max_limit,hit_exceed,cex=1.5,pos=4)
text(x=1.047*max_limit,y=0.953*max_limit,miss_exceed,cex=1.5,pos=4)
text(x=axis.max*0.75,y=y[2],"Accuracy (%)",adj=c(0,0))
text(x=axis.max*0.75,y=y[1],"Bias",adj=c(0,0))
text(x=axis.max*0.75,y=y[3],"CSI (%)",adj=c(0,0))
text(x=axis.max*0.75,y=y[4],"POD (%)",adj=c(0,0))
text(x=axis.max*0.75,y=y[5],"FAR (%)",adj=c(0,0))
text(x=axis.max*0.92,y=y[2],"=",adj=c(0,0))
text(x=axis.max*0.92,y=y[1],"=",adj=c(0,0))
text(x=axis.max*0.92,y=y[3],"=",adj=c(0,0))
text(x=axis.max*0.92,y=y[4],"=",adj=c(0,0))
text(x=axis.max*0.92,y=y[5],"=",adj=c(0,0))
text(x=axis.max,y=y[2],sprintf("%.1f",Accuracy),adj=c(1,0))
text(x=axis.max,y=y[1],sprintf("%.1f",Bias),adj=c(1,0))
text(x=axis.max,y=y[3],sprintf("%.1f",CSI),adj=c(1,0))
text(x=axis.max,y=y[4],sprintf("%.1f",POD),adj=c(1,0))
text(x=axis.max,y=y[5],sprintf("%.1f",FAR),adj=c(1,0))

text(x=axis.max*0.07,y=y[18],paste("(",units,")",sep=""),adj=c(0,0),cex=.8)
text(x=axis.max*0.01,y=y[10],"r ",adj=c(0,0),cex=.8)
text(x=axis.max*0.01,y=y[11],"RMSE ",adj=c(0,0),cex=.8)
text(x=axis.max*0.01,y=y[12],expression(paste(RMSE[s])),adj=c(0,0),cex=.8)
text(x=axis.max*0.01,y=y[13],expression(paste(RMSE[u])),adj=c(0,0),cex=.8)
text(x=axis.max*0.01,y=y[14],"MB ",adj=c(0,0),cex=.8)
text(x=axis.max*0.01,y=y[15],"ME ",adj=c(0,0),cex=.8)
text(x=axis.max*0.01,y=y[16],"MdnB ",adj=c(0,0),cex=.8)
text(x=axis.max*0.01,y=y[17],"MdnE ",adj=c(0,0),cex=.8)
text(x=axis.max*0.32,y=y[18],paste("(%)",sep=""),adj=c(0,0),cex=.8)
text(x=axis.max*0.24,y=y[10],"NMB ",adj=c(0,0),cex=.8)
text(x=axis.max*0.24,y=y[11],"NME ",adj=c(0,0),cex=.8)
text(x=axis.max*0.24,y=y[12],"NMdnB ",adj=c(0,0),cex=.8)
text(x=axis.max*0.24,y=y[13],"NMdnE ",adj=c(0,0),cex=.8)
text(x=axis.max*0.24,y=y[14],"FB ",adj=c(0,0),cex=.8)
text(x=axis.max*0.24,y=y[15],"FE ",adj=c(0,0),cex=.8)
text(x=axis.max*0.10,y=y[10],"=",adj=c(0,0),cex=.8)
text(x=axis.max*0.10,y=y[11],"=",adj=c(0,0),cex=.8)
text(x=axis.max*0.10,y=y[12],"=",adj=c(0,0),cex=.8)
text(x=axis.max*0.10,y=y[13],"=",adj=c(0,0),cex=.8)
text(x=axis.max*0.10,y=y[14],"=",adj=c(0,0),cex=.8)
text(x=axis.max*0.10,y=y[15],"=",adj=c(0,0),cex=.8)
text(x=axis.max*0.10,y=y[16],"=",adj=c(0,0),cex=.8)
text(x=axis.max*0.10,y=y[17],"=",adj=c(0,0),cex=.8)
text(x=axis.max*0.33,y=y[10],"=",adj=c(0,0),cex=.8)
text(x=axis.max*0.33,y=y[11],"=",adj=c(0,0),cex=.8)
text(x=axis.max*0.33,y=y[12],"=",adj=c(0,0),cex=.8)
text(x=axis.max*0.33,y=y[13],"=",adj=c(0,0),cex=.8)
text(x=axis.max*0.33,y=y[14],"=",adj=c(0,0),cex=.8)
text(x=axis.max*0.33,y=y[15],"=",adj=c(0,0),cex=.8)
text(x=axis.max*0.18,y=y[10],sprintf("%.2f",corr),adj=c(1,0),cex=.8)
text(x=axis.max*0.18,y=y[11],sprintf("%.2f",rmse),adj=c(1,0),cex=.8)
text(x=axis.max*0.18,y=y[12],sprintf("%.2f",rmse_sys),adj=c(1,0),cex=.8)
text(x=axis.max*0.18,y=y[13],sprintf("%.2f",rmse_unsys),adj=c(1,0),cex=.8)
text(x=axis.max*0.18,y=y[14],sprintf("%.2f",mb),adj=c(1,0),cex=.8)
text(x=axis.max*0.18,y=y[15],sprintf("%.2f",me),adj=c(1,0),cex=.8)
text(x=axis.max*0.18,y=y[16],sprintf("%.2f",med_bias),adj=c(1,0),cex=.8)
text(x=axis.max*0.18,y=y[17],sprintf("%.2f",med_error),adj=c(1,0),cex=.8)
text(x=axis.max*0.40,y=y[10],sprintf("%.1f",nmb),adj=c(1,0),cex=.8)
text(x=axis.max*0.40,y=y[11],sprintf("%.1f",nme),adj=c(1,0),cex=.8)
text(x=axis.max*0.40,y=y[12],sprintf("%.1f",nmdnb),adj=c(1,0),cex=.8)
text(x=axis.max*0.40,y=y[13],sprintf("%.1f",nmdne),adj=c(1,0),cex=.8)
text(x=axis.max*0.40,y=y[14],sprintf("%.1f",fb),adj=c(1,0),cex=.8)
text(x=axis.max*0.40,y=y[15],sprintf("%.1f",fe),adj=c(1,0),cex=.8)

##########################################

### Put 1-to-1 lines and confidence lines on plot ### 
abline(0,1)				# create 1-to-1 line
if (conf_line=="y") {
   abline(0,(1/1.5),col="black",lty=1)	# create lower bound 2-to-1 line
   abline(0,1.5,col="black",lty=1)	# create upper bound 2-to-1 line
}
#####################################################

### Put legend on the plot ###
legend("topleft", legend_names, pch=legend_chars,col=legend_cols, merge=F, cex=1, bty="n")
##############################

### Convert pdf file to png file ###
dev.off()
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_pdf," png:",filename_png,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}
####################################
