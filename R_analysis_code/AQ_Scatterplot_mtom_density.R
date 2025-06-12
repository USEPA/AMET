header <- "
####################### MODEL TO MODEL SCATTERPLOT ####################### 
### AMET CODE: R_Scatterplot_MtoM.r 
###
### This script is part of the AMET-AQ system.  This script creates a single
### model-to-model scatterplot.  However, the model points correspond to network
### observation sites, and does not use all the model grid points (only what
### is in the database).  Two model runs must be provided.  The script attempts
### to match all points in one run with all points in the other run.  
###
### Last Updated by Wyat Appel: Jun 2020
##########################################################################
"

## get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Load Required R Libraries
if(!require(ggplot2))             { stop("Required Package ggplot2 was not loaded") 	}
if(!require(plotly))              { stop("Required Package plotly was not loaded")	}
if(!require(htmlwidgets))         { stop("Required Package htmlwidgets was not loaded") }

## Set some defaults
network <- network_names[1] 														# Use first network to set units
networks_title <- network_label[1]
n <- 2
while (n <= length(network_names)) {
   networks_title <- paste(networks_title,network_label[n],sep=", ")
   n <- n+1
}
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste("Model to Model for",species,"at",networks_title,"sites for",dates,sep=" ") }
   else { title <- custom_title }
}

## Set output file names
filename_pdf	<- paste(run_name1,species,pid,"scatterplot_mtom_density.pdf",sep="_")   # Set filename for pdf format file
filename_png 	<- paste(run_name1,species,pid,"scatterplot_mtom_density.png",sep="_")   # Set filename for png format file
filename_html	<- paste(run_name1,species,pid,"scatterplot_mtom_density.html",sep="_")   # Set filename for html format file

## Create a full path to output files
filename_pdf 	<- paste(figdir,filename_pdf,sep="/")                          # Set PDF filename
filename_png 	<- paste(figdir,filename_png,sep="/")                          # Set PNG filename
filename_html	<- paste(figdir,filename_html,sep="/")                          # Set HTML filename
#################################

###################################
### Set variable initial values ###
###################################
axis.max 	 <- NULL
sinfo    	 <- NULL
avg_text 	 <- ""
remove_negatives <- "n"
aqdat1.df 	 <- NULL
aqdat2.df 	 <- NULL
###################################

for (j in 1:length(network_names)) {						# Loop through for each network
   network		<- network_names[[j]]						# Set network name
   ob_col_name <- paste(species,"_ob",sep="")
   mod_col_name <- paste(species,"_mod",sep="")
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info      <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,species)
         data_exists      <- sitex_info$data_exists
         if (data_exists == "y") {
            aqdat_query.df  <- sitex_info$sitex_data
            aqdat_query.df  <- aqdat_query.df[,-ob_col_name]
         }
         sitex_info      <- read_sitex(Sys.getenv("OUTDIR2"),network,run_name2,species)
         data_exists2    <- sitex_info$data_exists
         if (data_exists == "y") {
            aqdat_query2.df <- sitex_info$sitex_data
            aqdat_query2.df <- aqdat_query2.df[,-ob_col_name]
            units           <- as.character(sitex_info$units[[1]])
         }
      }
      else {
         query_result    <- query_dbase(run_name1,network,species)
         aqdat_query.df  <- query_result[[1]]
         data_exists     <- query_result[[2]]
         query_result2   <- query_dbase(run_name2,network,species)
         aqdat_query2.df <- query_result2[[1]]
         data_exists2    <- query_result2[[2]]
         if (data_exists == "y") { units <- query_result[[3]] }
      }
   }
   aqdat1.df <- rbind(aqdat1.df,aqdat_query.df)
   aqdat2.df <- rbind(aqdat2.df,aqdat_query2.df)
   if ((data_exists == "n") || (data_exists2 == "n")) {
      total_networks <- (total_networks-1)
      if (total_networks == 0) { stop("Stopping because total_networks is zero. Likely no data found for query.") }
   }
}

### Match the points between each of the runs.  This is necessary if the data from each query do not match exactly ###
aqdat1.df$statdate<-paste(aqdat1.df$stat_id,aqdat1.df$ob_dates,aqdat1.df$ob_hour,sep="")	# Create unique column that combines the site name with the ob start date for run 1
aqdat2.df$statdate<-paste(aqdat2.df$stat_id,aqdat2.df$ob_dates,aqdat2.df$ob_hour,sep="")	# Create unique column that combines the site name with the ob start date for run 2
{
   if (length(aqdat1.df$statdate) <= length(aqdat2.df$statdate)) {				# If more obs in run 1 than run 2
      match.ind<-match(aqdat1.df$statdate,aqdat2.df$statdate)					# Match the unique column (statdate) between the two runs
      aqdat.df<-data.frame(network=aqdat1.df$network, stat_id=aqdat1.df$stat_id, lat=aqdat1.df$lat, lon=aqdat1.df$lon, ob_dates=aqdat1.df$ob_dates, aqdat1.df[[mod_col_name]], aqdat2.df[match.ind,mod_col_name], month=aqdat1.df$month)	# eliminate points that are not common between the two runs
   }
   else { match.ind<-match(aqdat2.df$statdate,aqdat1.df$statdate) 				# If more obs in run 2 than run 1
      aqdat.df<-data.frame(network=aqdat2.df$network, stat_id=aqdat2.df$stat_id, lat=aqdat2.df$lat, lon=aqdat2.df$lon, ob_dates=aqdat2.df$ob_dates, aqdat1.df[match.ind,mod_col_name], aqdat2.df[[mod_col_name]], month=aqdat2.df$month)	# eliminate points that are not common between the two runs
   }
}
#######################################################################################################################

aqdat.df <- data.frame(Network=aqdat.df$network,Stat_ID=aqdat.df$stat_id,lat=aqdat.df$lat,lon=aqdat.df$lon,Obs_Value=aqdat.df[,7],Mod_Value=aqdat.df[,6],Start_Date=aqdat.df$ob_dates,Month=aqdat.df$month)

### Remove missing model values ###
indic.na <- is.na(aqdat.df$Obs_Value)
aqdat.df <- aqdat.df[!indic.na,]
indic.na <- is.na(aqdat.df$Mod_Value)        # Indentify NA records
aqdat.df <- aqdat.df[!indic.na,]             # Remove NA records
###################################

{
   if (averaging != "n") {                                               # Average observations to a monthly average if requested
      if (use_avg_stats == "y") {
         aqdat.df <- Average(aqdat.df)
      }
      else {
         aqdat.df <- Average(aqdat.df)
      }
   }
   indic.na <- is.na(aqdat.df$Obs_Value)        # Indentify NA records
   aqdat.df <- aqdat.df[!indic.na,]             # Remove NA records
   indic.na <- is.na(aqdat.df$Mod_Value)        # Indentify NA records
   aqdat.df <- aqdat.df[!indic.na,]             # Remove NA records
}

axis.max <- max(c(axis.max,aqdat.df$Obs_Value,aqdat.df$Mod_Value))
axis.min <- axis.max * .033

### If user sets axis maximum, compute axis minimum ###
if ((length(y_axis_max) > 0) || (length(x_axis_max) > 0)) {
   axis.max <- max(y_axis_max,x_axis_max)
   axis.min <- axis.max * 0.033
}
if ((length(y_axis_min) > 0) || (length(x_axis_min) > 0)) {
   axis.min <- max(y_axis_max,x_axis_max)
}
#######################################################

##############################################
########## MAKE SCATTERPLOT: ALL US ##########
##############################################
y.x.lm <- lm(aqdat.df$Mod_Value~aqdat.df$Obs_Value)$coeff

options(bitmapType='cairo')

sp <- ggplot(aqdat.df,aes(x=Obs_Value,y=Mod_Value)) + geom_hex(bins=100) + scale_fill_gradientn(colours=c("light blue","blue","dark green","yellow","orange","red")) + geom_abline(intercept = 0, slope=1) + xlim(0,axis.max) + ylim(0,axis.max) + geom_smooth(method=lm, linetype="dashed", color="black") + labs(title=title,x=run_name2,y=run_name1) + scale_y_continuous(expand=c(0,0), limits=c(0,axis.max), breaks = pretty(c(0,axis.max), n = 10)) + scale_x_continuous(expand=c(0,0), limits=c(0,axis.max), breaks = pretty(c(0,axis.max), n = 10)) + theme(legend.title = element_text(size=14), legend.text = element_text(size=12), legend.justification=c(1,0), legend.position=c(0.98,0.02), legend.background=element_blank(), legend.key=element_blank(), plot.title=element_text(hjust=0.5))
p <- ggplotly(sp, width=1450, height=1250)

sp <- sp + annotate("text",0.02*(axis.max),0.97*(axis.max),label=paste("Y =",signif(y.x.lm[1],2),"+",signif(y.x.lm[2],2),"* X"),hjust=0,vjust=1,size=5)
sp <- sp + annotate("text",0.02*(axis.max),0.93*(axis.max),label=paste("Units =",units),hjust=0,vjust=1,size=5)
p <- p %>% layout(annotations=list(xanchor="left",align="left",text=paste("Y =",signif(y.x.lm[1],2),"+",signif(y.x.lm[2],2),"* X"),x=axis.max*0.02,y=axis.max*0.97,showarrow=FALSE))
p <- p %>% layout(annotations=list(xanchor="left",align="left",text=paste("Units = ",units),x=axis.max*0.02,y=axis.max*0.93,showarrow=FALSE))

saveWidget(p, file=filename_html,selfcontained=T)
ggsave(filename_pdf,height=8,width=8)

### Convert pdf file to png file ###
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_pdf," png:",filename_png,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}
####################################

