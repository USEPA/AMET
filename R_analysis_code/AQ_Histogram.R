header <- "
####################### HISTOGRAM PLOT ##########################
### AMET CODE: AQ_Histogram.R
###
### This script is part of the AMET-AQ system.  This script creates
### a histogram of model and ob values using the R histogram
### function. Designed for single simulation, single network and
### single species.
###
### Last Updated by Wyat Appel: June, 2019
##################################################################
"

## get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")        		# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

### Retrieve units label from database table ###
network <- network_names[1]
#units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
#units <- db_Query(units_qs,mysql)
################################################


network <- network_names[[1]]                                             # Set network

### Set file names and titles ###
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") {
      main.title        <- paste(run_name1,species,"for",network_label[1],"for",dates,sep=" ")
      main.title.bias   <- paste(run_name1,species,"for",network_label[1],"for",dates,sep=" ")
   }
   else {
     main.title   <- custom_title
     main.title.bias <- custom_title
  }
}
sub.title       <- ""
filename_all_pdf	<- paste(run_name1,species,pid,"histogram.pdf",sep="_")			# Set PDF filename
filename_all_png	<- paste(run_name1,species,pid,"histogram.png",sep="_")			# Set PNG filename
filename_bias_pdf 	<- paste(run_name1,species,pid,"histogram_bias.pdf",sep="_")                  # Set PDF filename
filename_bias_png 	<- paste(run_name1,species,pid,"histogram_bias.png",sep="_")                  # Set PNG filename

## Create a full path to file
filename_all_pdf	<- paste(figdir,filename_all_pdf,sep="/")                 # Set PDF filename
filename_all_png	<- paste(figdir,filename_all_png,sep="/")                 # Set PNG filename
filename_bias_pdf	<- paste(figdir,filename_bias_pdf,sep="/")                  # Set PDF filename
filename_bias_png	<- paste(figdir,filename_bias_png,sep="/")                  # Set PNG filename

#####################################################   
{
   if (Sys.getenv("AMET_DB") == 'F') {
      sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,species)
      data_exists      <- sitex_info$data_exists
      if (data_exists == "y") {
         aqdat_query.df   <- sitex_info$sitex_data
         aqdat_query.df   <- aqdat_query.df[with(aqdat_query.df,order(network,stat_id)),]
         units            <- as.character(sitex_info$units[[1]])
      }
   }
   else {
      query_result    <- query_dbase(run_name1,network,species)
      aqdat_query.df  <- query_result[[1]]
      data_exists     <- query_result[[2]]
      if (data_exists == "y") { units <- query_result[[3]] }
   }
}
if (data_exists == "n") { stop("Stopping because data_exists is false. Likely no data found for query.") }

### If plotting another simulation ###
run2 <- "False"
if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   run2 <- "True"
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name2,species)
         aqdat_query2.df  <- sitex_info$sitex_data
         aqdat_query2.df  <- aqdat_query2.df[with(aqdat_query2.df,order(network,stat_id)),]
         units            <- as.character(sitex_info$units[[1]])
      }
      else {
         query_result2    <- query_dbase(run_name2,network,species)
         aqdat_query2.df  <- query_result2[[1]]
      }
   }
}
######################################

#########################################################
#### Calculate statistics for each requested network ####
#########################################################
## Calculate stats using all pairs, regardless of averaging
ob_col_name <- paste(species,"_ob",sep="")
mod_col_name <- paste(species,"_mod",sep="")
aqdat_stats.df <- data.frame(network=aqdat_query.df$network,stat_id=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=aqdat_query.df[[ob_col_name]],Mod_Value=aqdat_query.df[[mod_col_name]],month=aqdat_query.df$month)
   
n <- length(aqdat_stats.df$Obs_Value)
obs.mean <- mean(aqdat_stats.df$Obs_Value)
obs.sd   <- sqrt(var(aqdat_stats.df$Obs_Value) * ((n-1)/n))
mod.mean <- mean(aqdat_stats.df$Mod_Value)
mod.sd   <- sqrt(var(aqdat_stats.df$Mod_Value) * ((n-1)/n))
bias     <- aqdat_stats.df$Mod_Value-aqdat_stats.df$Obs_Value
x.seq.ob <- seq(min(aqdat_stats.df$Obs_Value), max(aqdat_stats.df$Obs_Value), length=100)
x.seq.mod <- seq(min(aqdat_stats.df$Mod_Value), max(aqdat_stats.df$Mod_Value), length=100)
obs.mean.log <- mean(log(aqdat_stats.df$Obs_Value))
mod.mean.log <- mean(log(aqdat_stats.df$Mod_Value))
obs.sd.log <- sqrt(var(log(aqdat_stats.df$Obs_Value)) * ((n-1)/n))
mod.sd.log <- sqrt(var(log(aqdat_stats.df$Mod_Value)) * ((n-1)/n))


### If plotting another simulation ###
if (run2 == "True") {
   if ((network ==  "NADP_dep") || (network == "NADP_conc")) {                               # If NADP and remove 0 precip obs selected
      if (zeroprecip == 'n') {
         indic.noprecip <- aqdat_query2.df$precip_ob > 0                                                # determine where precipitation obs are 0
         aqdat_query2.df <- aqdat_query2.df[indic.noprecip,]                                                   # remove 0 precip pairs from dataframe
      }
   }
   aqdat_stats2.df <- data.frame(network=aqdat_query2.df$network,stat_id=aqdat_query2.df$stat_id,lat=aqdat_query2.df$lat,lon=aqdat_query2.df$lon,Obs_Value=aqdat_query2.df[[ob_col_name]],Mod_Value=aqdat_query2.df[[mod_col_name]],month=aqdat_query2.df$month)

   n2 <- length(aqdat_stats2.df$Mod_Value)
   mod.mean2 <- mean(aqdat_stats2.df$Mod_Value)
   mod.sd2   <- sqrt(var(aqdat_stats2.df$Mod_Value) * ((n2-1)/n2))
   bias2     <- aqdat_stats2.df$Mod_Value-aqdat_stats2.df$Obs_Value
   x.seq.mod2 <- seq(min(aqdat_stats2.df$Mod_Value), max(aqdat_stats2.df$Mod_Value), length=100)
   mod.mean.log2 <- mean(log(aqdat_stats2.df$Mod_Value))
   mod.sd.log2 <- sqrt(var(log(aqdat_stats2.df$Mod_Value)) * ((n2-1)/n2))
}
#######################################

x.axis.max <- max(aqdat_stats.df$Obs_Value,aqdat_stats.df$Mod_Value)*.95

pdf(file=filename_all_pdf,width=8,height=8)
plot_hist_obs <- hist(aqdat_stats.df$Obs_Value, plot=F)
plot_hist_mod <- hist(aqdat_stats.df$Mod_Value, plot=F)
xmax <- max(plot_hist_obs$breaks,plot_hist_mod$breaks)
ymax <- max(plot_hist_obs$density,plot_hist_mod$density)*1.05
hist_breaks <- seq(0,xmax,length.out=10)
hist(aqdat_stats.df$Obs_Value, col=NULL, border='red', breaks=hist_breaks, ylim=c(0,ymax), xlim=c(0,xmax), prob=T, main=main.title, xlab=paste("Concentration (",units,")"),cex.main=.9)
hist(aqdat_stats.df$Mod_Value, col=NULL, border='blue', breaks=hist_breaks, cex=1, prob=T, axes=F, main="", xlab="", ylab="", add=T)
lines(x.seq.ob, dnorm(x.seq.ob, mean=obs.mean, sd=obs.sd), col="blue")
lines(x.seq.ob, dnorm(x.seq.mod, mean=mod.mean, sd=mod.sd), col="red")
legend("topright", c(network,'CMAQ'), lty=c(1,1), col=c("red","blue"), merge=F, cex=1.2, bty="n")

text(x=x.axis.max,y=0.7*ymax, paste("RPO = ",rpo,sep=""),cex=1,adj=c(1,.5))           # add RPO region to plot
text(x=x.axis.max,y=0.65*ymax, paste("PCA = ",pca,sep=""),cex=1,adj=c(1,0.5))
text(x=x.axis.max,y=0.6*ymax, paste("State = ",state,sep=""),cex=1,adj=c(1,.5))       # add State abbreviation to plot
text(x=x.axis.max,y=0.55*ymax, paste("Site = ",site,sep=""),cex=1,adj=c(1,.5))                     # add Site name to plot

### Convert pdf file to png file ###
dev.off()
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_all_pdf," png:",filename_all_png,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_all_pdf,sep="")
      system(remove_command)
   }
}
####################################

pdf(file=filename_bias_pdf,width=8,height=8)
bias_hist <- hist(bias,plot=F)
bias_max <- max(abs(bias_hist$breaks))
hist(bias, col=NULL, border='black', breaks=25, prob=F, xlim=c(-bias_max,bias_max), main=main.title.bias, xlab=paste("Concentration (",units,")"),cex.main=.9)

### Convert pdf file to png file ###
dev.off()
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_bias_pdf," png:",filename_bias_png,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_bias_pdf,sep="")
      system(remove_command)
   }
}
####################################

