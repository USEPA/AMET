header <- "
####################### MODEL TO OBS DENSITY SCATTERPLOT ######################### 
### AMET CODE: R_Scatterplot_density.r 
###
### This script is part of the AMET-AQ system.  This script creates a single model-to-obs
### scatterplot. This script will plot a single species from up to three networks on a 
### single plot. Additionally, summary statistics are also included on the plot. The 
### script will also allow a second run to plotted on top of the first run. Output for
### is png, pdf or both.
###
### Last Updated by Wyat Appel: Feb 2020
##################################################################################
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

filename_pdf <- paste(run_name1,species,pid,"scatterplot_density.pdf",sep="_")             # Set PDF filename
filename_png <- paste(run_name1,species,pid,"scatterplot_density.png",sep="_")             # Set PNG filename
filename_txt <- paste(run_name1,species,pid,"scatterplot_density.csv",sep="_")       # Set output file name

## Create a full path to file
filename_pdf <- paste(figdir,filename_pdf,sep="/")      # Set PDF filename
filename_png <- paste(figdir,filename_png,sep="/")      # Set PNG filenam
filename_txt <- paste(figdir,filename_txt,sep="/")      # Set output file name

#################################

axis.max      <- NULL
axis.min      <- NULL
number_bins   <- NULL
dens_zlim     <- NULL

### Retrieve units and model labels from database table ###
network <- network_names[1]
#units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
#model_name_qs   <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
################################################

run_name 	<- run_name1
network 	<- network_names[[1]]						# Set network
{
   if (Sys.getenv("AMET_DB") == 'F') {
      sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,species)
      data_exists      <- sitex_info$data_exists
      if (data_exists == "y") {
         aqdat_query.df   <- sitex_info$sitex_data
         units            <- as.character(sitex_info$units[[1]])
         model_name       <- "Model"
      }
   }
   else {
      query_result    <- query_dbase(run_name1,network,species)
      aqdat_query.df  <- query_result[[1]]
      data_exists     <- query_result[[2]]
      if (data_exists == "y") { units <- query_result[[3]] }
      model_name      <- query_result[[4]]
   }
}
if (data_exists == "n") { stop("Stopping because data_exists is false. Likely no data found for query.") }
ob_col_name <- paste(species,"_ob",sep="")
mod_col_name <- paste(species,"_mod",sep="")
aqdat.df <- data.frame(Network=aqdat_query.df$network,Stat_ID=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=round(aqdat_query.df[[ob_col_name]],5),Mod_Value=round(aqdat_query.df[[mod_col_name]],5),Month=aqdat_query.df$month)      # Create dataframe of network values to be used to create a list

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


##############################
### Write Data to CSV File ###
##############################
write.table(run_name1,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
write.table(dates,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(aqdat_query.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
###############################

#######################################################
### If user sets axis maximum, compute axis minimum ###
#######################################################
axis.max <- max(c(axis.max,aqdat.df$Obs_Value,aqdat.df$Mod_Value))
axis.min <- axis.max * .033
if ((length(y_axis_max) > 0) || (length(x_axis_max) > 0)) {
   axis.max <- max(y_axis_max,x_axis_max)
   axis.min <- axis.max * 0.033
}
if ((length(y_axis_min) > 0) || (length(x_axis_min) > 0)) {
   axis.min <- min(y_axis_min,x_axis_min)
}
{
   if (length(num_dens_bins) > 0) {
      number_bins <- num_dens_bins
   }
   else { 
      number_bins <- 50 
   }
}
{  
   if (length(density_zlim) > 0) {
      dens_zlim <- c(0,density_zlim)
   }
   else { 
      dens_zlim <- NULL
   }
}
#######################################################

##############################################
########## MAKE SCATTERPLOT: ALL US ##########
##############################################
plot_chars <- c(1,2,3,4)                                 	# set vector of plot characters
pdf(file=filename_pdf,width=8,height=8)
plot.density.scatter.plot(x=aqdat.df$Obs_Value,y=aqdat.df$Mod_Value,xlim=c(axis.min,axis.max),ylim=c(axis.min,axis.max),zlim=dens_zlim,main=title,num.bins=number_bins)

#### Define Stats placement and add text ####
axis.length <- (axis.max - axis.min)
x1 <- axis.max*0.12
x2 <- axis.max*0.05
x3 <- axis.max*0.37
x4 <- axis.max*0.29
x5 <- axis.max*0.15
x6 <- axis.max*0.37
x7 <- axis.max*0.22
x8 <- axis.max*0.45
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
x <- c(x1,x2,x3,x4,x5,x6,x7,x8)
y <- c(y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15,y16,y17,y18)  # set vector of y offsets

text(x=x[1],y=y[18],paste("(",units,")",sep=""),adj=c(0,0),cex=.8)
text(x=x[2],y=y[10],"r ",adj=c(0,0),cex=.8)
text(x=x[2],y=y[11],"RMSE ",adj=c(0,0),cex=.8)
text(x=x[2],y=y[12],expression(paste(RMSE[s])),adj=c(0,0),cex=.8)
text(x=x[2],y=y[13],expression(paste(RMSE[u])),adj=c(0,0),cex=.8)
text(x=x[2],y=y[14],"MB ",adj=c(0,0),cex=.8)
text(x=x[2],y=y[15],"ME ",adj=c(0,0),cex=.8)
text(x=x[2],y=y[16],"MdnB ",adj=c(0,0),cex=.8)
text(x=x[2],y=y[17],"MdnE ",adj=c(0,0),cex=.8)
text(x=x[3],y=y[18],paste("(%)",sep=""),adj=c(0,0),cex=.8)
text(x=x[4],y=y[10],"NMB ",adj=c(0,0),cex=.8)
text(x=x[4],y=y[11],"NME ",adj=c(0,0),cex=.8)
text(x=x[4],y=y[12],"NMdnB ",adj=c(0,0),cex=.8)
text(x=x[4],y=y[13],"NMdnE ",adj=c(0,0),cex=.8)
text(x=x[4],y=y[14],"FB ",adj=c(0,0),cex=.8)
text(x=x[4],y=y[15],"FE ",adj=c(0,0),cex=.8)
text(x=x[5],y=y[10],"=",adj=c(0,0),cex=.8)
text(x=x[5],y=y[11],"=",adj=c(0,0),cex=.8)
text(x=x[5],y=y[12],"=",adj=c(0,0),cex=.8)
text(x=x[5],y=y[13],"=",adj=c(0,0),cex=.8)
text(x=x[5],y=y[14],"=",adj=c(0,0),cex=.8)
text(x=x[5],y=y[15],"=",adj=c(0,0),cex=.8)
text(x=x[5],y=y[16],"=",adj=c(0,0),cex=.8)
text(x=x[5],y=y[17],"=",adj=c(0,0),cex=.8)
text(x=x[6],y=y[10],"=",adj=c(0,0),cex=.8)
text(x=x[6],y=y[11],"=",adj=c(0,0),cex=.8)
text(x=x[6],y=y[12],"=",adj=c(0,0),cex=.8)
text(x=x[6],y=y[13],"=",adj=c(0,0),cex=.8)
text(x=x[6],y=y[14],"=",adj=c(0,0),cex=.8)
text(x=x[6],y=y[15],"=",adj=c(0,0),cex=.8)
text(x=x[7],y=y[10],sprintf("%.2f",corr),adj=c(1,0),cex=.8)
text(x=x[7],y=y[11],sprintf("%.2f",rmse),adj=c(1,0),cex=.8)
text(x=x[7],y=y[12],sprintf("%.2f",rmse_sys),adj=c(1,0),cex=.8)
text(x=x[7],y=y[13],sprintf("%.2f",rmse_unsys),adj=c(1,0),cex=.8)
text(x=x[7],y=y[14],sprintf("%.2f",mb),adj=c(1,0),cex=.8)
text(x=x[7],y=y[15],sprintf("%.2f",me),adj=c(1,0),cex=.8)
text(x=x[7],y=y[16],sprintf("%.2f",med_bias),adj=c(1,0),cex=.8)
text(x=x[7],y=y[17],sprintf("%.2f",med_error),adj=c(1,0),cex=.8)
text(x=x[8],y=y[10],sprintf("%.1f",nmb),adj=c(1,0),cex=.8)
text(x=x[8],y=y[11],sprintf("%.1f",nme),adj=c(1,0),cex=.8)
text(x=x[8],y=y[12],sprintf("%.1f",nmdnb),adj=c(1,0),cex=.8)
text(x=x[8],y=y[13],sprintf("%.1f",nmdne),adj=c(1,0),cex=.8)
text(x=x[8],y=y[14],sprintf("%.1f",fb),adj=c(1,0),cex=.8)
text(x=x[8],y=y[15],sprintf("%.1f",fe),adj=c(1,0),cex=.8)
###########################

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
