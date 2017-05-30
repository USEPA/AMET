################################################################
### AMET CODE: BUGLE PLOT
###
### This script is part of the AMET-AQ system.  It plots a unique 
### type of plot referred to as a "bugle" plot.  The idea behind
### the plot is that model performance should be adjusted as a function
### of the average concentration of the observed value for that species. 
### Therefore, as the average concentration of the species decreases,
### the acceptable performance criteria increase.  This code applies
### this idea to both NMB (or FB) and NME (or FE).  A MYSQL query
### provides the necessary input data.  The output is two plots, one
### for the bias and one for the error (in both png and pdf formats).
###
### Last updated by Wyat Appel; July 30, 2007
###
### Modified to work with combined MET/AQ mode, Alexis Zubrow (IE UNC) Nov, 2007
###
################################################################

## get some environmental variables and setup some directories
ametbase<-Sys.getenv("AMETBASE") 			# base directory of AMET
dbase<-Sys.getenv("AMET_DATABASE")      # AMET database
ametR<-paste(ametbase,"/R",sep="")                    # R directory
ametRinput <- Sys.getenv("AMETRINPUT")                # input file for this script
ametptype <- Sys.getenv("AMET_PTYPE")    # Prefered output type

## Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
## and not specified via AMET_OUT, then set figdir to the current directory
if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")	}
if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"			}

## source some configuration files, AMET libs, and input
source(paste(ametbase,"/configure/amet-config.R",sep=""))
source (paste(ametR,"/AQ_Misc_Functions.R",sep=""))  	# Miscellanous AMET R-functions file
source (ametRinput)	                                # Anaysis configuration/input file
source (ametNetworkInput) # Network related input

## Load Required Libraries
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}
if(!require(Hmisc)){stop("Required Package Hmisc was not loaded")}

mysql <- list(login=login, passwd=passwd, server=server, dbase=dbase, maxrec=maxrec)		# Set MYSQL login and query options


total_obs <- NULL
specinfo <- NULL
k <- 0

### Retrieve units label from database table ###
network <- network_names[1] 
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql) 
################################################

### Set file names and titles ###
outname_pdf <- paste(run_name1,species,"bugleplot_error.pdf",sep="_")
outname2_pdf <- paste(run_name1,species,"bugleplot_bias.pdf",sep="_")
outname_png <- paste(run_name1,species,"bugleplot_error.png",sep="_")
outname2_png <- paste(run_name1,species,"bugleplot_bias.png",sep="_")
{
   if (custom_title == "") { title <- paste("Bugleplot for ",run_name1," ",species," for ",start_date,end_date,"; State=",state,"; Site=",site,sep="") }
   else { title <- custom_title }
}

## Create a full path to file
outname_pdf <- paste(figdir,outname_pdf,sep="/")
outname2_pdf <- paste(figdir,outname2_pdf,sep="/")
outname_png <- paste(figdir,outname_png,sep="/")
outname2_png <- paste(figdir,outname2_png,sep="/")

#################################

### Set values to NULL ###
plotinfo <- NULL
plot_vals <- NULL
max_conc  <- NULL
##########################

for (j in 1:length(network_names)) {
   nmb <- NULL				
   nme <- NULL
   fb  <- NULL
   fe  <- NULL
   drop_names <- NULL
   species_names <- NULL
   network<-network_names[[j]]
   query <- paste(" and s.stat_id=d.stat_id and d.ob_dates BETWEEN",start_date,"and",end_date,"and d.ob_datee BETWEEN",start_date,"and",end_date,"and ob_hour between",start_hour,"and",end_hour,add_query,sep=" ")
   criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
   qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")	# Set the rest of the database query
   aqdat.df <- db_Query(qs,mysql)		# Query the database

   ## test that the query worked
   if (length(aqdat.df) == 0){
     ## error the queried returned nothing
     writeLines("ERROR: Check species/network pairing and Obs start and end dates")
     stop(paste("ERROR querying db: \n",qs))
   }
        
   if (soccerplot_opt == 1) { 			# If using NMB/NME, set appropriate axis labels
      ylabel1 <- "Normalized Mean Bias (%)"
      ylabel2 <- "Normalized Mean Error (%)"
   }
   else { 					# If using FB/FE, set appropriate axis labels
      ylabel1 <- "Fractional Bias (%)"
      ylabel2 <- "Fractional Error (%)"
   }

   ### Create properly formatted dataframe and then call DomainStats and SitesStats to create statistics ###
   data_all.df <- data.frame(network=I(aqdat.df$network),stat_id=I(aqdat.df$stat_id),lat=aqdat.df$lat,lon=aqdat.df$lon,ob_val=aqdat.df[,9],mod_val=aqdat.df[,10],precip_val=aqdat.df$precip_ob)
   stats_all.df <- DomainStats(data_all.df)
   #sites_stats.df <- SitesStats(data_all.df)
   #########################################################################################################

   if (soccerplot_opt == 1) {	# If using NMB/NME, create list with those values
      plot_vals[[j]]<-list(VAL1=stats_all.df$AVG_CONC,VAL2=stats_all.df$Percent_Norm_Bias, VAL3=stats_all.df$Percent_Norm_Err) 
   }
   else { plot_vals[[j]]<-list(VAL1=stats_all.df$AVG_CONC,VAL2=stats_all.df$FB,VAL3=stats_all.df$FE) }	# Else, use FB/FE instead

   max_conc <- max(max_conc,stats_all.df$AVG_CONC)	# Determine the maximum average concentration
}

####################################


########## MAKE BUGLE PLOT: ERROR/CONCENTRATION ##########

pdf(file=outname_pdf,width=10,height=8)			# Set output device and device options
par(mai=c(1,1,0.5,0.5))					# Set margins
x <- seq(0,max_conc*1.20, by=0.01)			# Create a sequence from 1 to 1.2*max_conc, increasing by 0.01
y_goal <- 150*exp(-x/0.75)+50				# y value for the goal
y_crit <- 125*exp(-x/0.75)+75				# y value for the criteria
plot(x, y_goal, type="l", pch=2, col="dark green", ylim=c(7.4,192.7), xlim=c((max_conc*0.046), (max_conc*1.20)), xlab=paste("Average Concentration (",units,")",sep=""), ylab=ylabel2, cex.axis=1.5, cex.lab=1.2,lwd=2)						# plot goal line
lines(x,y_crit,col="red",lwd=2)				# plot criteria line
abline(h=50)						# plot 50% horizontal line
abline(h=100)						# plot 100% horizontal line
abline(h=150)						# plot 150% horizontal line

for (n in 1:length(network_names)) {			# For each network, plot values as points
   network_vals <- plot_vals[[n]]			# From the list for each network, put values to plot into network_vals vector
   plot_val1 <- network_vals$VAL1			# Set plot value 1 from network_vals (VAL1 column)
   plot_val2 <- network_vals$VAL3			# Set plot value 2 from network vals (VAL3 column)
   plot_chars <- c(2,3,4)				# Set vector of plot characters
   plot_cols  <- c("green","blue","red")		# Set vector of plot colors
   plot_char <- plot_chars[n]				# Set plot character based on network used
   points(plot_val1,plot_val2,pch=plot_char,col=plot_cols[n],cex=1.5)	# Plot error points for each network on the plot
}

### Put title at top of boxplot ###
title(main=title,cex.main=1)			# Add title to the plot
###################################

### Put legend on the plot ###
leg_chars <- c(3,3,plot_chars)	# A little work-around for the legend, plotting lines for the goal and criteria line, characters for the points
leg_cols  <- c("red","dark green",plot_cols)	# Set criteria line as red, goal line as green, and the appropriate plot color
leg_types <- c(1,1,0,0,0,0,0)	# The work-around for the legend
legend_names <- c("Criteria","Goal",network_label)	# Set legend names
legend("topright", legend_names, pch=leg_chars, lty=leg_types,col=leg_cols, merge=F, cex=1.5, bty="n")	# Place legend on the plot
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
############################################

########## MAKE BUGLE PLOT: BIAS/CONCENTRATION ##########

pdf(file=outname2_pdf,width=10,height=8)			# Set output device and device options
par(mai=c(1,1,0.5,0.5))         				# Set margins

### Create criteria and goal lines for the bugle plot ###
x <- seq(0,max_conc*1.20, by=0.01)				# Create a sequence from 1 to 1.2*max_conc, increasing by 0.01
y_goal     <- 170*exp(-x/0.5)+30				# y value for the goal
y_goal_neg <- -170*exp(-x/0.5)-30				# y value for the goal (negative bias)
y_crit     <- 140*exp(-x/0.5)+60				# y value for the criteria
y_crit_neg <- -(140*exp(-x/0.5)+60)				# y value for the criteria (negative bias)
#########################################################

plot(x, y_goal, type="l", pch=2, col="dark green", ylim=c(-192.7,192.7), xlim=c((max_conc*0.046), (max_conc*1.20)), xlab=paste("Average Concentration (",units,")",sep=""), ylab=ylabel1, cex.axis=1.5, cex.lab=1.2,lwd=2)						# Create plot using goal line
lines(x,y_crit,col="red",lwd=2)					# Add criteria line to the plot
lines(x,y_goal_neg,col="dark green",lwd=2)			# Add negative goal line to the plot
lines(x,y_crit_neg,col="red",lwd=2)				# Add negative criteria line to the plot
abline(h=50)							# Add 50% horizonal line to the plot
abline(h=100)							# Add 100% horizonal line to the plot
abline(h=150)							# Add 150% horizonal line to the plot
abline(h=0)							# Add 0% horizonal line to the plot
abline(h=-50)							# Add -50% horizonal line to the plot
abline(h=-100)							# Add -100% horizonal line to the plot
abline(h=-150)							# Add -150% horizonal line to the plot


for (n in 1:length(network_names)) {    				# for each network, plot values as points
   network_vals <- plot_vals[[n]]					# From the list for each network, put values to plot into network_vals vector
   plot_val1 <- network_vals$VAL1					# Set plot value 1 from network_vals (VAL1 column)
   plot_val2 <- network_vals$VAL2					# Set plot value 2 from network vals (VAL2 column)
   plot_chars <- c(2,3,4,5,6)						# Set plot characters
   plot_cols  <- c("green","blue","red","yellow","brown")		# Set plot colors
   plot_char <- plot_chars[n]						# Set plot characters based on current network
   points(plot_val1,plot_val2,pch=plot_char,col=plot_cols[n],cex=1.5)	# Plot points for corresponding network
}

### Put title at top of boxplot ###
title(main=title,cex.main=1)
###################################

### Put legend on the plot ###
leg_chars <- c(3,3,plot_chars)
leg_cols  <- c("red","dark green",plot_cols)
leg_types <- c(1,1,0,0,0,0,0)
legend_names <- c("Criteria","Goal",network_label)
legend("topright", legend_names, pch=leg_chars, lty=leg_types,col=leg_cols, merge=F, cex=1.5, bty="n")
##############################

### Process if PNG output requested ###
if (ametptype == "png") {
   ### Convert pdf format file to png format ###
   convert_command<-paste("convert -density 150x150 ",outname2_pdf," ",outname2_png,sep="")
   dev.off()
   system(convert_command)
   
#   ### Remove PDF ###
#   remove_command <- paste("rm ",outname2_pdf,sep="")
#   system(remove_command)
}
############################################
