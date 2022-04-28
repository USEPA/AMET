header <- "
####################### MODEL TO OBS DENSITY SCATTERPLOT ##########################
### AMET CODE: R_Scatterplot_density_ggplot.r 
###
### This script is part of the AMET-AQ system.  This script creates a single model-to-obs
### density scatterplot, where higher density areas of the plot are shaded differently
### from lower density areas. This script will plot a single species for a single network
### using the R ggplot package.  
###
### Last Updated by Wyat Appel: June, 2019
####################################################################################
"

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

require(ggplot2)

### Set file names and titles ###
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(run_name1," ",species," for ",dates,sep="") }
   else { title <- custom_title }
}

filename_pdf <- paste(run_name1,species,pid,"scatterplot_density_ggplot.pdf",sep="_")             # Set PDF filename
filename_png <- paste(run_name1,species,pid,"scatterplot_density_ggplot.png",sep="_")             # Set PNG filename
filename_txt <- paste(run_name1,species,pid,"scatterplot_density_ggplot.csv",sep="_")       # Set output file name

## Create a full path to file
filename_pdf <- paste(figdir,filename_pdf,sep="/")      # Set PDF filename
filename_png <- paste(figdir,filename_png,sep="/")      # Set PNG filenam
filename_txt <- paste(figdir,filename_txt,sep="/")      # Set output file name

#################################

axis.max      <- NULL
axis.min      <- NULL
number_bins   <- NULL
dens_zlim     <- NULL
network <- network_names[1]

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
axis.max <- max(c(axis.max,quantile(aqdat.df$Obs_Value,quantile_max),quantile(aqdat.df$Mod_Value,quantile_max)))
axis.min <- min(aqdat.df$Obs_Value,aqdat.df$Mod_Value)
if ((length(y_axis_max) > 0) || (length(x_axis_max) > 0)) {
   axis.max <- max(y_axis_max,x_axis_max)
   axis.min <- axis.max * 0.035
}
if ((length(y_axis_min) > 0) || (length(x_axis_min) > 0)) {
   axis.min <- min(y_axis_min,x_axis_min)
}

dens_zlim <- 0.5 
if(length(aqdat.df$Obs_Value > 50000)) { dens_zlim <- 1 }

if (length(density_zlim) > 0) {
   dens_zlim <- density_zlim 
}
#######################################################

##############################################
########## MAKE SCATTERPLOT: ALL US ##########
##############################################
#pdf(file=filename_pdf,width=8,height=8)
#plot.density.scatter.plot(x=aqdat.df$Obs_Value,y=aqdat.df$Mod_Value,xlim=c(axis.min,axis.max),ylim=c(axis.min,axis.max),zlim=dens_zlim,main=title,num.bins=number_bins)

y.x.lm <- lm(aqdat.df$Mod_Value~aqdat.df$Obs_Value)$coeff

options(bitmapType='cairo')

#sp <- ggplot(aqdat.df,aes(x=Obs_Value,y=Mod_Value)) + stat_density_2d(aes(fill = ..level..), geom="polygon") + scale_fill_gradient(low="blue", high="red") + geom_abline(intercept = 0, slope=1)
print(axis.max)
sp <- ggplot(aqdat.df,aes(x=Obs_Value,y=Mod_Value)) + geom_hex(bins=100) + scale_fill_gradientn(colours=c("light blue","blue","dark green","yellow","orange","red")) + geom_abline(intercept = 0, slope=1) + xlim(0,axis.max) + ylim(0,axis.max) + geom_smooth(method=lm, linetype="dashed", color="black") + labs(title=title,x=network,y=model_name) + scale_y_continuous(expand=c(0,0), limits=c(0,axis.max), breaks = pretty(c(0,axis.max), n = 10)) + scale_x_continuous(expand=c(0,0), limits=c(0,axis.max), breaks = pretty(c(0,axis.max), n = 10)) + theme(legend.justification=c(1,0), legend.position=c(0.98,0.02), legend.background=element_blank(), legend.key=element_blank(), plot.title=element_text(hjust=0.5))
sp <- sp + annotate("text",0.02*(axis.max),0.95*(axis.max),label=paste("Y =",signif(y.x.lm[1],2),"+",signif(y.x.lm[2],2),"* X"),hjust=0,vjust=1,size=5)
ggsave(filename_pdf,height=8,width=8)
#sp

### Convert pdf file to png file ###
#dev.off()
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_pdf," png:",filename_png,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}
####################################
