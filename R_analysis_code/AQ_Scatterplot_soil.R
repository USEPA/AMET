################## MODEL TO OBS SCATTERPLOT #################### 
### AMET CODE: R_Scatterplot_soil.r 
###
### This script is part of the AMET-AQ system.  This script creates
### a single model-to-obs scatterplot of the percent soil composition by
### the individual soil species. This script will create a single plot
### for a single network and model simulation.  
###
### Last Updated by Wyat Appel: June, 2017
################################################################

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

### Set file names and titles ###
network <- network_names[[1]]
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(run_name1,network,"soil species for",dates,sep=" ") }
   else { title <- custom_title }
}

filename_pdf <- paste(run_name1,species,pid,"scatterplot_soil.pdf",sep="_")             # Set PDF filename
filename_png <- paste(run_name1,species,pid,"scatterplot_soil.png",sep="_")             # Set PNG filename
filename_txt <- paste(run_name1,species,pid,"scatterplot_soil.csv",sep="_")       # Set output file name


## Create a full path to file
filename_pdf <- paste(figdir,filename_pdf,sep="/")      # Set PDF filename
filename_png <- paste(figdir,filename_png,sep="/")      # Set PNG filenam
filename_txt <- paste(figdir,filename_txt,sep="/")      # Set output file name

#################################

axis.max     <- NULL
num_obs      <- NULL
sinfo        <- NULL
sinfo2	     <- NULL
avg_text     <- ""
legend_names <- NULL
legend_cols  <- NULL
legend_chars <- NULL
point_char   <- NULL
point_color  <- NULL

### Retrieve units and model labels from database table ###
#units_qs <- paste("SELECT Fe from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
#model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
################################################

#############################################
### Read sitex file or query the database ###
#############################################
species <- c("Fe","Al","Si","Ti","Ca","Mg","K","Mn")
{
   if (Sys.getenv("AMET_DB") == 'F') {
      sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,species)
      aqdat_query.df   <- sitex_info$sitex_data
      data_exists      <- sitex_info$data_exists
      if (data_exists == "y") { units <- as.character(sitex_info$units[[1]]) }
      model_name       <- "Model"
   }
   else {
      query_result    <- query_dbase(run_name1,network,species)
      aqdat_query.df  <- query_result[[1]]
      data_exists     <- query_result[[2]]
      if (data_exists == "y") { units <- query_result[[3]] }
      model_name      <- query_result[[4]]
   }
}

aqdat.df 	      <- aqdat_query.df
aqdat.df$Soil_Tot_ob  <- aqdat.df$Fe_ob+aqdat.df$Al_ob+aqdat.df$Si_ob+aqdat.df$Ti_ob+aqdat.df$Ca_ob+aqdat.df$Mg_ob+aqdat.df$Mg_ob+aqdat.df$K_ob+aqdat.df$Mn_ob
aqdat.df$Soil_Tot_mod <- aqdat.df$Fe_mod+aqdat.df$Al_mod+aqdat.df$Si_mod+aqdat.df$Ti_mod+aqdat.df$Ca_mod+aqdat.df$Mg_mod+aqdat.df$Mg_mod+aqdat.df$K_mod+aqdat.df$Mn_mod
aqdat.df$Fe_perc_ob   <- (aqdat.df$Fe_ob/aqdat.df$Soil_Tot_ob)*100
aqdat.df$Fe_perc_mod  <- (aqdat.df$Fe_mod/aqdat.df$Soil_Tot_mod)*100
aqdat.df$Al_perc_ob   <- (aqdat.df$Al_ob/aqdat.df$Soil_Tot_ob)*100
aqdat.df$Al_perc_mod  <- (aqdat.df$Al_mod/aqdat.df$Soil_Tot_mod)*100
aqdat.df$Si_perc_ob   <- (aqdat.df$Si_ob/aqdat.df$Soil_Tot_ob)*100
aqdat.df$Si_perc_mod  <- (aqdat.df$Si_mod/aqdat.df$Soil_Tot_mod)*100
aqdat.df$Ti_perc_ob   <- (aqdat.df$Ti_ob/aqdat.df$Soil_Tot_ob)*100
aqdat.df$Ti_perc_mod  <- (aqdat.df$Ti_mod/aqdat.df$Soil_Tot_mod)*100
aqdat.df$Ca_perc_ob   <- (aqdat.df$Ca_ob/aqdat.df$Soil_Tot_ob)*100
aqdat.df$Ca_perc_mod  <- (aqdat.df$Ca_mod/aqdat.df$Soil_Tot_mod)*100
aqdat.df$Mg_perc_ob   <- (aqdat.df$Mg_ob/aqdat.df$Soil_Tot_ob)*100
aqdat.df$Mg_perc_mod  <- (aqdat.df$Mg_mod/aqdat.df$Soil_Tot_mod)*100
aqdat.df$K_perc_ob    <- (aqdat.df$K_ob/aqdat.df$Soil_Tot_ob)*100
aqdat.df$K_perc_mod   <- (aqdat.df$K_mod/aqdat.df$Soil_Tot_mod)*100
aqdat.df$Mn_perc_ob   <- (aqdat.df$Mn_ob/aqdat.df$Soil_Tot_ob)*100
aqdat.df$Mn_perc_mod  <- (aqdat.df$Mn_mod/aqdat.df$Soil_Tot_mod)*100

Fe_perc_ob_mean       <- tapply(aqdat.df$Fe_perc_ob,aqdat.df$stat_id,mean,na.rm=T)
Fe_perc_mod_mean      <- tapply(aqdat.df$Fe_perc_mod,aqdat.df$stat_id,mean,na.rm=T)
Al_perc_ob_mean       <- tapply(aqdat.df$Al_perc_ob,aqdat.df$stat_id,mean,na.rm=T)
Al_perc_mod_mean      <- tapply(aqdat.df$Al_perc_mod,aqdat.df$stat_id,mean,na.rm=T)
Si_perc_ob_mean       <- tapply(aqdat.df$Si_perc_ob,aqdat.df$stat_id,mean,na.rm=T)
Si_perc_mod_mean      <- tapply(aqdat.df$Si_perc_mod,aqdat.df$stat_id,mean,na.rm=T)
Ti_perc_ob_mean       <- tapply(aqdat.df$Ti_perc_ob,aqdat.df$stat_id,mean,na.rm=T)
Ti_perc_mod_mean      <- tapply(aqdat.df$Ti_perc_mod,aqdat.df$stat_id,mean,na.rm=T)
Ca_perc_ob_mean       <- tapply(aqdat.df$Ca_perc_ob,aqdat.df$stat_id,mean,na.rm=T)
Ca_perc_mod_mean      <- tapply(aqdat.df$Ca_perc_mod,aqdat.df$stat_id,mean,na.rm=T)
Mg_perc_ob_mean       <- tapply(aqdat.df$Mg_perc_ob,aqdat.df$stat_id,mean,na.rm=T)
Mg_perc_mod_mean      <- tapply(aqdat.df$Mg_perc_mod,aqdat.df$stat_id,mean,na.rm=T)
K_perc_ob_mean        <- tapply(aqdat.df$K_perc_ob,aqdat.df$stat_id,mean,na.rm=T)
K_perc_mod_mean       <- tapply(aqdat.df$K_perc_mod,aqdat.df$stat_id,mean,na.rm=T)
Mn_perc_ob_mean       <- tapply(aqdat.df$Mn_perc_ob,aqdat.df$stat_id,mean,na.rm=T)
Mn_perc_mod_mean      <- tapply(aqdat.df$Mn_perc_mod,aqdat.df$stat_id,mean,na.rm=T)


##############################
### Write Data to CSV File ###
##############################
write.table(run_name1,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
write.table(dates,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(aqdat_query.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
###############################

###############################################
########## MAKE SCATTERPLOT: ALL US ##########
#############################################
### Preset values for plot characters and colors (these can be changed to user preference) ###
plot_chars <- c(1,2,3,4)                                 	# set vector of plot characters
##############################################################################################
pdf(file=filename_pdf,width=8,height=8)
### Plot and draw rectangle with stats ###
par(mai=c(1,1,0.5,0.5))
plot(1,1,type="n", pch=2, col="red", ylim=c(0,100), xlim=c(0,100), xlab="Observation (percent)", ylab=paste(model_name," (percent)",sep=""), cex.axis=1.3, cex.lab=1.3)	# create plot axis and labels, but do not plot any points
if (run_info_text == "y") {
   text(85,30,"Averaged by Site", cex=1)						# add run name text
}
 ### Put title at top of boxplot ###
title(main=title,cex.main=1)
###################################

### Plot points and stats for each network ###
plot_colors     <- c("brown4","purple","seagreen1","grey","black","blue","yellow2","orange","light blue","red3")
#point_color <- plot_colors[i]
points(Fe_perc_ob_mean,Fe_perc_mod_mean,pch=1,col=plot_colors[1],cex=1)	# plot points for each network
points(Al_perc_ob_mean,Al_perc_mod_mean,pch=1,col=plot_colors[2],cex=1)
points(Ti_perc_ob_mean,Ti_perc_mod_mean,pch=1,col=plot_colors[3],cex=1)
points(Si_perc_ob_mean,Si_perc_mod_mean,pch=1,col=plot_colors[4],cex=1)
points(Ca_perc_ob_mean,Ca_perc_mod_mean,pch=1,col=plot_colors[5],cex=1)
points(Mg_perc_ob_mean,Mg_perc_mod_mean,pch=1,col=plot_colors[6],cex=1)
points(K_perc_ob_mean,K_perc_mod_mean,pch=1,col=plot_colors[7],cex=1)
points(Mn_perc_ob_mean,Mn_perc_mod_mean,pch=1,col=plot_colors[8],cex=1)
##############################################

### Put 1-to-1 lines and confidence lines on plot ###
abline(0,1)                                     # create 1-to-1 line
if (conf_line=="y") {
   abline(0,(1/1.5),col="black",lty=1)              # create lower bound 2-to-1 line
   abline(0,1.5,col="black",lty=1)                # create upper bound 2-to-1 line
} 

### Add descripitive text to plot area ###
if (run_info_text == "y") {
   if (rpo != "None") {
      text(x=x[1],y=y[8], paste("RPO = ",rpo,sep=""),cex=1,adj=c(0,.5))           # add RPO region to plot
   }
   if (pca != "None") {
      text(x=x[4],y=y[8], paste("PCA = ",pca,sep=""),cex=1,adj=c(0.25,0.5))
   }
   if (state != "All") {
      text(x=x[1],y=y[9], paste("State = ",state,sep=""),cex=1,adj=c(0,.5))       # add State abbreviation to plot
   }
   if (site != "All") {
      text(x=x[4],y=y[9], paste("Site = ",site,sep=""),cex=1,adj=c(0.25,0.5))                     # add Site name to plot
   }
}
##########################################


#####################################################

### Put legend on the plot ###
legend("topleft", c("Fe","Al","Ti","Si","Ca","Mg","K","Mn"), pch=1,col=plot_colors, merge=F, cex=1.2, bty="n")
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
