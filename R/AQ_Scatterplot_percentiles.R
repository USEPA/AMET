############# PERCENTILE MODEL TO OBS SCATTERPLOT ##############
### AMET CODE: AQ_Scatterplot_percentiles.r 
###
### This script is part of the AMET-AQ system.  This script is a 
### a variation of the standard scatter plot script in which the
### different percentiles (e.g. 50%) of the data are color color
### coded.  Since the percentiles are different colors, the 
### script only works with a single network and single model
### simulation. This script is part of the AMETv1.2 code.
###
### Last Updated by Wyat Appel; December 6, 2012
###
################################################################

## get some environmental variables and setup some directories
ametbase<-Sys.getenv("AMETBASE")	# base directory of AMET
dbase<-Sys.getenv("AMET_DATABASE")      # AMET database
ametR<-paste(ametbase,"/R",sep="")	# R directory
ametRinput <- Sys.getenv("AMETRINPUT")	# input file for this script
ametptype <- Sys.getenv("AMET_PTYPE")	# Prefered output type

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

### Set file names and titles ###
outname_pdf <- paste(run_name1,species,"scatterplot_percentiles.pdf",sep="_")                               # Set PDF filename
outname_png <- paste(run_name1,species,"scatterplot_percentiles.png",sep="_")                               # Set PNG filename
{
   if (custom_title == "") { title <- paste(run_name1,species,"for",start_date,"to",end_date,sep=" ") }
   else { title <- custom_title }
}

## Create a full path to file
outname_pdf <- paste(figdir,outname_pdf,sep="/")
outname_png <- paste(figdir,outname_png,sep="/")

#################################

run_name	<- NULL
axis.max	<- NULL
num_obs		<- NULL
sinfo		<- NULL
avg_text	<- ""
legend_names	<- NULL
legend_cols	<- NULL
legend_chars	<- NULL
point_char	<- NULL
point_color	<- NULL

################################
### Define percentile arrays ###
################################
percentile_5_ob		<- NULL
percentile_5_mod	<- NULL
percentile_25_ob	<- NULL
percentile_25_mod	<- NULL
percentile_50_ob	<- NULL
percentile_50_mod	<- NULL
percentile_75_ob	<- NULL
percentile_75_mod	<- NULL
percentile_95_ob	<- NULL
percentile_95_mod	<- NULL
###############################

### Retrieve units and model labels from database table ###
network <- network_names[1]
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql)
model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
model_name <- db_Query(model_name_qs,mysql)
################################################

run_count <- 1
num_runs <- 1									# Set number of runs to 1
run_name[1] <- run_name1

query <- paste(" and s.stat_id=d.stat_id and d.ob_dates BETWEEN", start_date, "and", end_date, "and d.ob_datee BETWEEN", start_date, "and", end_date, "and ob_hour between", start_hour, "and", end_hour, add_query,sep=" ")
criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")           # Set part of the MYSQL query
qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")      # Set the rest of the MYSQL query
aqdat.df<-db_Query(qs,mysql)							# Query the database and store in aqdat.df dataframe     

## test that the query worked
if (length(aqdat.df) == 0){
   ## error the queried returned nothing
   writeLines("ERROR: Check species/network pairing and Obs start and end dates")
   stop(paste("ERROR querying db: \n",qs))
}

####################### 
if (remove_negatives == "y") {
   indic.nonzero <- aqdat.df[,9] >= 0                                                  # determine which obs are missing (less than 0); 
   aqdat.df <- aqdat.df[indic.nonzero,]                                                        # remove missing obs from dataframe
   indic.nonzero <- aqdat.df[,10] >= 0
   aqdat.df <- aqdat.df[indic.nonzero,]
}
######################

################################################
### Calculate percentiles based on each site ###
################################################
temp <- split(aqdat.df,aqdat.df$stat_id)
for (i in 1:length(temp)) { 
   sub.df <- temp[[i]]
   percentile_5_ob <- c(percentile_5_ob, quantile(sub.df[,9],.05))
   percentile_5_mod <- c(percentile_5_mod, quantile(sub.df[,10],.05))
   percentile_25_ob <- c(percentile_25_ob, quantile(sub.df[,9],.25))
   percentile_25_mod <- c(percentile_25_mod, quantile(sub.df[,10],.25))
   percentile_50_ob <- c(percentile_50_ob, quantile(sub.df[,9],.50))
   percentile_50_mod <- c(percentile_50_mod, quantile(sub.df[,10],.50))
   percentile_75_ob <- c(percentile_75_ob, quantile(sub.df[,9],.75))
   percentile_75_mod <- c(percentile_75_mod, quantile(sub.df[,10],.75))
   percentile_95_ob <- c(percentile_95_ob, quantile(sub.df[,9],.95))
   percentile_95_mod <- c(percentile_95_mod, quantile(sub.df[,10],.95))
}
#################################################

##############################
### Determine axis maximum ###
##############################
axis.max <- max(percentile_95_ob,percentile_95_mod)
axis.min <- axis.max * 0.033

axis.length <- (axis.max - axis.min)
y1 <- axis.max - (axis.length * 0.750)                    # define y for species text
y2 <- axis.max - (axis.length * 0.800)                    # define y for timescale (averaging)

### If user sets axis maximum, compute axis minimum ###
if ((length(y_axis_max) > 0) || (length(x_axis_max) > 0)) {
   axis.max <- max(y_axis_max,x_axis_max)
   axis.min <- axis.max * 0.033
}
if ((length(y_axis_min) > 0) || (length(x_axis_min) > 0)) {
   axis.min <- min(y_axis_min,x_axis_min)
}
#######################################################


########################################################################################
### Set plot options and create blank plot area with correct lables and axis lengths ###
########################################################################################
plot_char <-16 
pdf(file=outname_pdf,width=8,height=8)
### Plot and draw rectangle with stats ###
par(mai=c(1,1,0.5,0.5),lab=c(8,8,7))
plot(1,1,type="n", pch=plot_char, col="red", ylim=c(axis.min, axis.max), xlim=c(axis.min, axis.max), xlab=paste("Observed ", species," (", units,")",sep=""), ylab=paste(model_name," ",species," (",units,")",sep=""), cex.axis=1.2, cex.lab=1.2)	# create plot axis and labels, but do not plot any points
text(axis.max,y1, network, cex=1, adj=c(1,0.5))
text(axis.max,y2, paste(species," (",units,")"), cex=1, adj=c(1,0.5))		# add species text
#########################################################################################

###################################
### Put title at top of boxplot ###
###################################
title(main=title,cex.main=1.1)
###################################

#######################################
### Plot points for each percentile ###
#######################################
colors <- plot_colors
points(percentile_5_ob,percentile_5_mod,pch=plot_char,col=colors[1],cex=.8)  # plot points for each network
points(percentile_25_ob,percentile_25_mod,pch=plot_char,col=colors[2],cex=.8)  # plot points for each network
points(percentile_50_ob,percentile_50_mod,pch=plot_char,col=colors[3],cex=.8)  # plot points for each network
points(percentile_75_ob,percentile_75_mod,pch=plot_char,col=colors[4],cex=.8)  # plot points for each network
points(percentile_95_ob,percentile_95_mod,pch=plot_char,col=colors[5],cex=.8)  # plot points for each network
legend_names <- c("5th","25th","50th","75th","95th")
legend_cols  <- colors
legend_char <- plot_char
#######################################

##########################################
### Add descripitive text to plot area ###
##########################################
if (run_info_text == "y") {
   if (rpo != "None") {   
      text(x=axis.max,y=y[7], paste("RPO = ",rpo,sep=""),cex=1,adj=c(1,.5))		# add RPO region to plot
   }
   if (state != "All") {
      text(x=axis.max,y=y[7], paste("State = ",state,sep=""),cex=1,adj=c(1,.5))	# add State abbreviation to plot
   }
   if (site != "All") {
      text(x=axis.max,y=y[7], paste("Site = ",site,sep=""),cex=1,adj=c(1,.5))			# add Site name to plot
   }
}
##########################################

#####################################################
### Put 1-to-1 lines and confidence lines on plot ###
##################################################### 
abline(0,1)                                     # create 1-to-1 line
if (conf_line=="y") {
   abline(0,(1/1.5),col="black",lty=1)              # create lower bound 2-to-1 line
   abline(0,1.5,col="black",lty=1)                # create upper bound 2-to-1 line
}
#####################################################

##############################
### Put legend on the plot ###
##############################
legend("topleft", legend_names, pch=legend_char,col=legend_cols, merge=F, cex=1.2, bty="n")
##############################

### Process if PNG output requested ###
if (ametptype == "png") {
   ### Convert pdf format file to png format ###
   convert_command<-paste("convert -density 150x150 ",outname_pdf," ",outname_png,sep="")
   dev.off()
   system(convert_command)

#   ### Remove PDF ###
#   remove_command <- paste("rm ",outname_pdf,sep="")
#   system(remove_command)
}
####################################
