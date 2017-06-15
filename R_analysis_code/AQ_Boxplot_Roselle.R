################################################################
### THIS FILE CONTAINS CODE TO DRAW A CUSTOMIZED HOURLY BOXPLOT DISPLAY.  It
### draws side-by-side boxplots for the various groups, with median value,
### interquartile and 25% and 75% quartile ranges indicated.  It is designed
### to work with any temporal data (e.g. hourly, daily, or weekly).
### It may be used with either one or two model simulation, but is
### designed to only work with a single network at a time.  It is called a
### Roselle plot because Shawn Roselle suggested that it be added to
### the AMET system.
###
### Last updated by Wyat Appel April, 2017
################################################################

## get some environmental variables and setup some directories
ametbase	<- Sys.getenv("AMETBASE")        # base directory of AMET
dbase		<- Sys.getenv("AMET_DATABASE")      # AMET database
ametR		<- paste(ametbase,"/R_analysis_code",sep="")      # R directory
ametRinput 	<- Sys.getenv("AMETRINPUT")  # input file for this script
ametptype 	<- Sys.getenv("AMET_PTYPE")   # Prefered output type
## Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
## and not specified via AMET_OUT, then set figdir to the current directory
if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")       }
if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"                 }

## source some configuration files, AMET libs, and input
source (paste(ametbase,"/configure/amet-config.R",sep=""))
source (paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file
source (ametRinput)                                     # Anaysis configuration/input file

## Load Required Libraries
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}

mysql           <- list(login=amet_login, passwd=amet_pass, server=mysql_server, dbase=dbase, maxrec=maxrec)             # Set MYSQL login and query options

### Retrieve units label from database table ###
network 	<- network_names[1]
units_qs	<- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units		<- db_Query(units_qs,mysql)
################################################

### Set file names and titles ###
filename_pdf	 <- paste(run_name1,species,pid,"boxplot_roselle.pdf",sep="_")
filename_png 	 <- paste(run_name1,species,pid,"boxplot_roselle.png",sep="_")
filename_bias_pdf <- paste(run_name1,species,pid,"boxplot_roselle_bias.pdf",sep="_")
filename_bias_png <- paste(run_name1,species,pid,"boxplot_roselle_bias.png",sep="_")
y_label 	 <- paste(network," ",species," (",units,")",sep="")
y_label_bias 	 <- paste(network," ",species," Bias (",units,")",sep="") 

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(run_name1,species,"for ",dates,sep=" ") }
   else { title <- custom_title }
}
#################################

## Create a full path to file
filename_pdf		<- paste(figdir,filename_pdf,sep="/")
filename_png		<- paste(figdir,filename_png,sep="/")
filename_bias_pdf	<- paste(figdir,filename_bias_pdf,sep="/")
filename_bias_png        <- paste(figdir,filename_bias_png,sep="/")

run_names <- NULL
run_names <- run_name1
{
   if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
      run_names <- c(run_names,run_name2)
   }
   if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
      run_names <- c(run_names,run_name3)
   }
   if ((exists("run_name4")) && (nchar(run_name4) > 0)) {
      run_names <- c(run_names,run_name4)
   }
   if ((exists("run_name5")) && (nchar(run_name5) > 0)) {
      run_names <- c(run_names,run_name5)
   }
   if ((exists("run_name6")) && (nchar(run_name6) > 0)) {
      run_names <- c(run_names,run_name6)
   }
}
labels      <- c(network,run_names)
labels_bias <- run_names
run_names <- c(run_name1,run_names)

obs_values   <- NULL
mod_values   <- NULL
bias_values  <- NULL
q0.spec1     <- NULL
q0.spec2     <- NULL
q1.spec1     <- NULL
q1.spec2     <- NULL
median.spec1 <- NULL
median.spec2 <- NULL
q3.spec1     <- NULL
q3.spec2     <- NULL
q4.spec1     <- NULL
q4.spec2     <- NULL

nmb        <- NULL
nme        <- NULL
mb         <- NULL
me         <- NULL
corr       <- NULL
rmse       <- NULL
rmse_sys   <- NULL
rmse_unsys <- NULL
index_agr  <- NULL
bias_max   <- NULL
bias_min   <- NULL

for (j in 1:length(run_names)) {
   criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
   check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name1,"' and COLUMN_NAME = 'POCode';",sep="")
   query_table_info.df <-db_Query(check_POCode,mysql)
   {
      if (length(query_table_info.df$COLUMN_NAME)==0) {   # Check to see if individual project tables exist
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_names[j]," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")      # Set the rest of the MYSQL query
         aqdat.df<-db_Query(qs,mysql) # Query the database and store in aqdat.df dataframe
         aqdat.df$POCode <- 1
      }
      else {
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob,d.POCode from ",run_names[j]," as d, site_metadata as s",criteria," ORDER BY stat_id,ob_dates,ob_hour",sep="")	# Set the rest of the MYSQL query
         aqdat.df<-db_Query(qs,mysql) # Query the database and store in aqdat.df dataframe
      }
   }

   indic.nonzero <- aqdat.df[,9] >= -100						# Determine the missing obs 
   aqdat.df <- aqdat.df[indic.nonzero,]						# Remove missing obs/mod pairs from dataframe
   indic.nonzero <- aqdat.df[,10] >= -100
   aqdat.df <- aqdat.df[indic.nonzero,]

   obs_values[[j]] <- aqdat.df[,9]
   {
   if (j == 1) {
      mod_values[[j]] <- aqdat.df[,9]
   }
   else {
      mod_values[[j]] <- aqdat.df[,10]
   }
   }
   #######################
  
   if (j > 1) {
      bias_values[j-1] <- aqdat.df[10]-aqdat.df[9]
      bias_max <- max(bias_max,bias_values[[j-1]])
      bias_min <- min(bias_min,bias_values[[j-1]])
   }

   ### Find q1, median, q2 for each group of both species ###
   q0.spec1[j] <- quantile(aqdat.df[,9], 0.05, na.rm=T)		# Compute ob 25% quartile
   q0.spec2[j] <- quantile(aqdat.df[,10], 0.05, na.rm=T)	# Compute model 25% quartile
   q1.spec1[j] <- quantile(aqdat.df[,9], 0.25, na.rm=T)		# Compute ob 25% quartile
   q1.spec2[j] <- quantile(aqdat.df[,10], 0.25, na.rm=T)	# Compute model 25% quartile
   median.spec1[j] <- median(aqdat.df[,9],na.rm=T)		# Compute ob median value
   median.spec2[j] <- median(aqdat.df[,10], na.rm=T)		# Compute model median value
   q3.spec1[j] <- quantile(aqdat.df[,9], 0.75, na.rm=T)		# Compute ob 75% quartile
   q3.spec2[j] <- quantile(aqdat.df[,10], 0.75, na.rm=T)	# Compute model 75% quartile
   q4.spec1[j] <- quantile(aqdat.df[,9], 0.95, na.rm=T)		# Compute ob 75% quartile
   q4.spec2[j] <- quantile(aqdat.df[,10], 0.95, na.rm=T)	# Compute model 75% quartile
   ################################################

   #########################################################
   #### Calculate statistics for simulation 1           ####
   #########################################################
   ## Calculate stats using all pairs, regardless of averaging
   data_all.df <- NULL
   stats.df    <- NULL
   data_all.df <- data.frame(network=I(aqdat.df$network),stat_id=I(aqdat.df$stat_id),lat=aqdat.df$lat,lon=aqdat.df$lon,ob_val=aqdat.df[,9],mod_val=aqdat.df[,10],precip_val=aqdat.df$precip_ob)
   stats.df <-try(DomainStats(data_all.df))      # Compute stats using DomainStats function for entire domain
   nmb[j]        <- round(stats.df$Percent_Norm_Mean_Bias,1)
   nme[j]        <- round(stats.df$Percent_Norm_Mean_Err,1)
   mb[j]         <- round(stats.df$Mean_Bias,2)
   me[j]         <- round(stats.df$Mean_Err,2)
   corr[j]       <- round(stats.df$Correlation,2)
   rmse[j]       <- round(stats.df$RMSE,2)
   rmse_sys[j]   <- round(stats.df$RMSE_systematic,2)
   rmse_unsys[j] <- round(stats.df$RMSE_unsystematic,2)
   index_agr[j]  <- round(stats.df$Index_of_Agree,2)
   #########################################################
}

### Set up axes so that they will be big enough for both data species  that will be added ###
num.groups <- length(unique(aqdat.df$ob_hour))				# Count the number of sites used in each month
y.axis.min <- min(c(-.5,-.5))						# Set y-axis minimum values
y.axis.max.value <- max(c(q4.spec1, q4.spec2))				# Determine y-axis maximum value
y.axis.max <- c(sum((y.axis.max.value * 0.38),y.axis.max.value))	# Add 38% of the y-axis maximum value to the y-axis maximum value
y.axis.min.value <- min(c(q0.spec1, q0.spec2))
y.axis.min <- y.axis.min.value-(0.35*y.axis.max)

if (length(y_axis_max) > 0) {
   y.axis.max <-y_axis_max
}

if (length(y_axis_min) > 0) {
   y.axis.min <- y_axis_min
}

#############################################################################################


##########################################
########## MAKE ROSELLE BOXPLOT ##########
##########################################

y.axis.max.value <- max(c(q4.spec1, q4.spec2))
y.axis.min.value <- min(c(q0.spec1, q0.spec2))
if (length(y_axis_max) > 0) {
   y.axis.max.value <-y_axis_max
}

if (length(y_axis_min) > 0) {
   y.axis.min.value <- y_axis_min
}
y_range <- y.axis.max.value-y.axis.min.value
y.axis.min <- y.axis.min.value-(0.3*y_range)
y.axis.max <- y.axis.max.value+(0.05*y_range*length(run_names))

pdf(filename_pdf, width=8, height=8)						# Set output device with options
{
   par(mai=c(1,1,0.5,0.5))                                                         # Set plot margins
   boxplot_info <- boxplot(mod_values,plot=F)
   boxplot(mod_values,range=0, border="transparent", col=plot_colors, ylim=c(y.axis.min, y.axis.max), xlab="", ylab=y_label, names=labels, cex.axis=.8, cex.lab=1.2, cex=1, las=1, boxwex=.4) # Create boxplot
   x.axis.max <- length(run_names) 
}
### Put title at top of boxplot ###
title(main=title,cex=1)
###################################

for (j in 1:length(run_names)) {
   {
      if (j == 1) {
         lines(c((j-.15),(j+.15)), c(q0.spec1[j],q0.spec1[j]))				# create horizontal black line below quartile
         lines(c((j-.2),(j+.2)), c(median.spec1[j],median.spec1[j]),col="white",lwd=2)	# Denote median as a white line 
         lines(c((j-.15),(j+.15)), c(q4.spec1[j],q4.spec1[j]))				# create horizontal black line above quartile
         lines(c(j,j),c(q0.spec1[j],q1.spec1[j]),col="black",lty=2)			# create vertical black line denoting lower 25 quartile
         lines(c(j,j),c(q3.spec1[j],q4.spec1[j]),col="black",lty=2)			# create vertical black line denoting upper 75 quartile
      }
      else {
         ### Second species ###								# As above, except for model values
         lines(c((j-.15),(j+.15)), c(q0.spec2[j],q0.spec2[j]))				# create vertical black line below quartile
         lines(c((j-.2),(j+.2)), c(median.spec2[j],median.spec2[j]),col="white",lwd=2)	# Connect median points with a line
         lines(c((j-.15),(j+.15)), c(q4.spec2[j],q4.spec2[j]))				# create vertical black line above quartile
         lines(c(j,j),c(q0.spec2[j],q1.spec2[j]),col="black",lty=2)			# create horizontal black line denoting lower 25 quartile
         lines(c(j,j),c(q3.spec2[j],q4.spec2[j]),col="black",lty=2)			# create horizontal black line denoting upper 75 quartile
      }
   }   
   #########################################################################
}

y.rec.top <- y.axis.min+(y_range*.25)
y1 <- y.axis.min+(y_range*.21)
y2 <- y.axis.min+(y_range*.17)
y3 <- y.axis.min+(y_range*.13)
y4 <- y.axis.min+(y_range*.09)
y5 <- y.axis.min+(y_range*.05)
y6 <- y.axis.min+(y_range*.01)

y<-c(y1,y2,y3,y4,y5,y6)

rect(ybottom=y.axis.min,ytop=y.rec.top,xright=x.axis.max+.5,xleft=0.45,col="gray85")

text(1,y[1], "r" ,font=3,cex=0.8,adj=c(0.5,0))               # write correlation title
text(1,y[2], "RMSE", font=3,cex=0.8,adj=c(0.5,0))            # write RMSE title
text(1,y[3], "NMB",font=3,cex=0.8,adj=c(0.5,0))              # write NMB systematic title
text(1,y[4], "NME",font=3,cex=0.8,adj=c(0.5,0))              # write NME unsystematic title
text(1,y[5], "MB",font=3,cex=0.8,adj=c(0.5,0))               # write MB title
text(1,y[6], "ME",font=3,cex=0.8,adj=c(0.5,0))               # write ME title

for (j in 2:x.axis.max) {
   text(j,y[1], corr[j], cex=0.9,adj=c(0.5,0),col=plot_colors[j])          # write correlation value
   text(j,y[2], rmse[j], cex=0.9,adj=c(0.5,0),col=plot_colors[j])          # write RMSE value
   text(j,y[3], nmb[j], cex=0.9,adj=c(0.5,0),col=plot_colors[j])           # write NMB value
   text(j,y[4], nme[j], cex=0.9,adj=c(0.5,0),col=plot_colors[j])           # write NME value
   text(j,y[5], mb[j], cex=0.9,adj=c(0.5,0),col=plot_colors[j])            # write MB value
   text(j,y[6], me[j], cex=0.9,adj=c(0.5,0),col=plot_colors[j])            # write ME value
}


##########################################

### Put legend on the plot ###
legend("topleft", labels, fill = plot_colors, merge=F, cex=1.1, bty='n')
##############################

### Count number of samples per hour ###
nsamples.table <- table(aqdat.df$ob_hour)
#########################################

### Put text on plot ###
text(x=18,y=y.axis.max,paste("RPO: ",rpo,sep=""),cex=1.2,adj=c(0,0))
text(x=18,y=y.axis.max*0.95,paste("PCA: ",pca,sep=""),cex=1.2,adj=c(0,0))
text(x=18,y=y.axis.max*0.90,paste("Site: ",site,sep=""),cex=1.2,adj=c(0,0))
if (state != "All") {
   text(x=18,y=y.axis.max*0.85,paste("State: ",state,sep=""),cex=1.2,adj=c(0,0))
}

########################

### Convert pdf to png ###
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density 150x150 ",filename_pdf," png:",filename_png,sep="")
   dev.off()
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}
##########################

plot_colors_bias <- plot_colors[-1]
y.axis.max <- bias_max
y.axis.min <- bias_min
y_range <- y.axis.max-y.axis.min
y.axis.min <- y.axis.min-(0.3*y_range)
y.axis.max <- y.axis.max+(0.05*y_range*length(run_names))
pdf(filename_bias_pdf, width=8, height=8)                                          # Set output device with options
par(mai=c(1,1,0.5,0.5))                                                         # Set plot margins
boxplot_info <- boxplot(bias_values,plot=F)
boxplot(bias_values, col=plot_colors_bias, xlab="", ylab=y_label_bias, ylim=c(y.axis.min, y.axis.max), names=labels_bias, cex.axis=.8, cex.lab=1.2, cex=1, las=1, boxwex=.4) # Create boxplot
x.axis.max <- length(run_names)-1
legend("topleft", labels_bias, fill = plot_colors_bias, merge=F, cex=1.1, bty='n')
### Put title at top of boxplot ###
title(main=title,cex=1)
###################################

y.rec.top <- y.axis.min+(y_range*.25)
y1 <- y.axis.min+(y_range*.21)
y2 <- y.axis.min+(y_range*.17)
y3 <- y.axis.min+(y_range*.13)
y4 <- y.axis.min+(y_range*.09)
y5 <- y.axis.min+(y_range*.05)
y6 <- y.axis.min+(y_range*.01)

y<-c(y1,y2,y3,y4,y5,y6)
x<-c(0.6)

rect(ybottom=y.axis.min,ytop=y.rec.top,xright=x.axis.max+.5,xleft=0.45,col="gray85")

text(x[1],y[1], "r" ,font=3,cex=0.8,adj=c(0.5,0))               # write correlation title
text(x[1],y[2], "RMSE", font=3,cex=0.8,adj=c(0.5,0))            # write RMSE title
text(x[1],y[3], "NMB",font=3,cex=0.8,adj=c(0.5,0))              # write NMB systematic title
text(x[1],y[4], "NME",font=3,cex=0.8,adj=c(0.5,0))              # write NME unsystematic title
text(x[1],y[5], "MB",font=3,cex=0.8,adj=c(0.5,0))               # write MB title
text(x[1],y[6], "ME",font=3,cex=0.8,adj=c(0.5,0))               # write ME title

for (j in 1:x.axis.max) {
   text(j,y[1], corr[j+1], cex=0.9,adj=c(0.5,0),col=plot_colors_bias[j])          # write correlation value
   text(j,y[2], rmse[j+1], cex=0.9,adj=c(0.5,0),col=plot_colors_bias[j])          # write RMSE value
   text(j,y[3], nmb[j+1], cex=0.9,adj=c(0.5,0),col=plot_colors_bias[j])           # write NMB value
   text(j,y[4], nme[j+1], cex=0.9,adj=c(0.5,0),col=plot_colors_bias[j])           # write NME value
   text(j,y[5], mb[j+1], cex=0.9,adj=c(0.5,0),col=plot_colors_bias[j])            # write MB value
   text(j,y[6], me[j+1], cex=0.9,adj=c(0.5,0),col=plot_colors_bias[j])            # write ME value
}   
abline(h=0,col="black")

if ((ametptype == "png") || (ametptype == "both")) {   
   convert_command<-paste("convert -flatten -density 150x150 ",filename_bias_pdf," png:",filename_bias_png,sep="")
   dev.off()
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_bias_pdf,sep="")
      system(remove_command)
   }
}

