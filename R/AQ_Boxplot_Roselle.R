################################################################
### AMET CODE: BOX PLOT Roselle
###
### This script is part of the AMET-AQ system.  It plots a box plot
### without whiskers. The script is designed to plot multiple simulations,
### but will work fine with a single simulation. The script creates
### a box plot for the observations, and each individual simulation
### for a single network. Included on the plot are select statistics
### for each model simulation.
###
### Last updated by Wyat Appel; December 6, 2012
###
################################################################

## get some environmental variables and setup some directories
ametbase<-Sys.getenv("AMETBASE")                        # base directory of AMET
dbase<-Sys.getenv("AMET_DATABASE")      # AMET database
ametR<-paste(ametbase,"/R",sep="")                    # R directory
ametRinput <- Sys.getenv("AMETRINPUT")                # input file for this script
ametptype <- Sys.getenv("AMET_PTYPE")    # Prefered output type
## Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
## and not specified via AMET_OUT, then set figdir to the current directory
if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")       }
if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"                 }

## source some configuration files, AMET libs, and input
source(paste(ametbase,"/configure/amet-config.R",sep=""))
source (paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file
source (ametRinput)                                     # Anaysis configuration/input file
source (ametNetworkInput) # Network related input

## Load Required Libraries
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}

mysql <- list(login=login, passwd=passwd, server=server, dbase=dbase, maxrec=maxrec)           # Set MYSQL login and query options


### Retrieve units label from database table ###
network <- network_names[1]
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql)
################################################

### Set file names and titles ###
outname_pdf  <- paste(run_name1,species,"boxplot.pdf",sep="_")
outname_png  <- paste(run_name1,species,"boxplot.png",sep="_")
y_label <- paste(network," ",species," (",units,")",sep="") 
#################################

{
   if (custom_title == "") { title <- paste(run_name1,species,"for",network_label[1],"for",start_date,end_date,sep=" ") }
   else { title <- custom_title }
}

## Create a full path to file
outname_pdf	<- paste(figdir,outname_pdf,sep="/")
outname_png	<- paste(figdir,outname_png,sep="/")

run_names <- NULL
run_names <- run_name1
{
   if (run_name2 != "empty") {
      run_names <- c(run_names,run_name2)
   }
   if (run_name3 != "empty") {
      run_names <- c(run_names,run_name3)
   }
   if (run_name4 != "empty") {
      run_names <- c(run_names,run_name4)
   }
   if (run_name5 != "empty") {
      run_names <- c(run_names,run_name5)
   }
}
labels <- c(network,run_names)
run_names <- c(run_name1,run_names)

obs_values   <- NULL
mod_values   <- NULL
q0.spec1     <- NULL
q0.spec2     <-NULL
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

#network <- network_names[[1]]
for (j in 1:length(run_names)) {
   query <- paste(" and s.stat_id=d.stat_id and d.ob_dates BETWEEN",start_date,"and",end_date,"and d.ob_datee BETWEEN",start_date,"and",end_date,"and ob_hour between",start_hour,"and",end_hour,add_query,sep=" ")
   criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
   qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_names[j]," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")      # Set the rest of the MYSQL query
   aqdat.df<-db_Query(qs,mysql)	# Query the database and store in aqdat.df dataframe

   ## test that the query worked
   if (length(aqdat.df) == 0){
   ## error the queried returned nothing
      writeLines("ERROR: Check species/network pairing and Obs start and end dates")
      stop(paste("ERROR querying db: \n",qs))
   }

   indic.nonzero <- aqdat.df[,9] >= 0						# Determine the missing obs 
   aqdat.df <- aqdat.df[indic.nonzero,]						# Remove missing obs/mod pairs from dataframe
   indic.nonzero <- aqdat.df[,10] >= 0
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
#############################################################################################

########## MAKE PRIOR BOXPLOT ALL U.S. ##########
### To get a new graphics window (linux systems), use X11() ###
pdf(outname_pdf, width=8, height=8)						# Set output device with options

{
   par(mai=c(1,1,0.5,0.5))                                                         # Set plot margins
   boxplot_info <- boxplot(mod_values,plot=F)
   boxplot(mod_values,range=0, border="transparent", col=plot_colors, ylim=c(y.axis.min, y.axis.max), xlab="", ylab=y_label, names=labels, cex.axis=.8, cex.lab=1.2, cex=1, las=1, boxwex=.4) # Create boxplot
   x.axis.max <- length(run_names) 
}


### Put title at top of boxplot ###
title(main=title,cex=1)
###################################

#x1 <-x.axis.max*0.27
x1 <- x.axis.max-(x.axis.max*.60)
#x1 <- 1
x2 <-x.axis.max*0.55
x3 <-x.axis.max*0.65
x4 <-x.axis.max*0.75
x5 <-x.axis.max*0.85
x6 <-x.axis.max*0.95
x7 <-x.axis.max*1.05

x1 <- x.axis.max-(x.axis.max*.55)-(1-2/x.axis.max)
x2 <- x.axis.max-(x.axis.max*.35)-(1-2/x.axis.max)
x3 <- x.axis.max-(x.axis.max*.25)-(1-2/x.axis.max)
x4 <- x.axis.max-(x.axis.max*.15)-(1-2/x.axis.max)
x5 <- x.axis.max-(x.axis.max*.05)-(1-2/x.axis.max)
x6 <- x.axis.max+(x.axis.max*.05)-(1-2/x.axis.max)
x7 <- x.axis.max+(x.axis.max*.15)-(1-2/x.axis.max)

y.rec.top <- y.axis.min+(y.axis.max*.30)
y1 <- y.axis.min+(y.axis.max*.27)
y2 <- y.axis.min+(y.axis.max*.23)
y3 <- y.axis.min+(y.axis.max*.19)
y4 <- y.axis.min+(y.axis.max*.15)
y5 <- y.axis.min+(y.axis.max*.11)
y6 <- y.axis.min+(y.axis.max*.07)
y7 <- y.axis.min+(y.axis.max*.03)
y8 <- y.axis.min+(y.axis.max*.00)

x <- c(x1,x2,x3,x4,x5,x6,x7)
y <- c(y1,y2,y3,y4,y5,y6,y7,y8)

rect(ybottom=y.axis.min,ytop=y.rec.top,xright=x.axis.max+.5,xleft=0.5,col="gray85")

text(x[1],y[1], "Simulation",font=3,cex=0.8,adj=c(0.5,0))
text(x[2],y[1], "r" ,font=3,cex=0.8,adj=c(0.5,0))		# write correlation title
text(x[3],y[1], "RMSE", font=3,cex=0.8,adj=c(0.5,0))		# write RMSE title
text(x[4],y[1], "NMB",font=3,cex=0.8,adj=c(0.5,0))		# write NMB systematic title
text(x[5],y[1], "NME",font=3,cex=0.8,adj=c(0.5,0))		# write NME unsystematic title
text(x[6],y[1], "MB",font=3,cex=0.8,adj=c(0.5,0))		# write MB title
text(x[7],y[1], "ME",font=3,cex=0.8,adj=c(0.5,0))		# write ME title

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

#run_names <- c("NADP","MM5","WRF")
   if (j != 1) {
      text(x[1],y[j+1], run_names[j], cex=0.8,adj=c(0.5,0))	# add run_name text to stats box
      text(x[2],y[j+1], corr[j], cex=0.9,adj=c(0.5,0))		# write correlation value
      text(x[3],y[j+1], rmse[j], cex=0.9,adj=c(0.5,0))		# write RMSE value
      text(x[4],y[j+1], nmb[j], cex=0.9,adj=c(0.5,0))		# write NMB value
      text(x[5],y[j+1], nme[j], cex=0.9,adj=c(0.5,0))		# write NME value
      text(x[6],y[j+1], mb[j], cex=0.9,adj=c(0.5,0))		# write MB value
      text(x[7],y[j+1], me[j], cex=0.9,adj=c(0.5,0))		# write ME value
   }
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
text(x=18,y=y.axis.max*0.90,paste("Site: ",site,sep=""),cex=1.2,adj=c(0,0))
if (state != "All") {
   text(x=18,y=y.axis.max*0.85,paste("State: ",state,sep=""),cex=1.2,adj=c(0,0))
}
#abline(h=0)

########################

### Process if PNG output requested ###
if (ametptype == "png") {
   ### Convert pdf format file to png format ###
   convert_command<-paste("convert -density 150x150 ",outname_pdf," ",outname_png,sep="")
   dev.off()
   system(convert_command)

#   ### Remove PDF ###
#   remove_command <- paste("rm ",outname_norm_bias_pdf,sep="")
#   system(remove_command)
}
#############################################
