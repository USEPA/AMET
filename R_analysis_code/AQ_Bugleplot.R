################################################################
### AMET CODE: BUGLE PLOT
###
### This script is part of the AMET-AQ system.  It plots a unique 
### type of plot referred to as a "bugle" plot.  The idea behind
### the plot is that model performance should be adjusted as a function
### of the average concentration of the observed value for that specie. 
### Therefore, as the average concentration of the specie decreses,
### the acceptable performance criteria increase.  This code applies
### this idea to both NMB (or FB) and NME (or FE).  A MYSQL query
### provides the necessary input data.  The output is two plots, one
### for the bias and one for the error (in both png and pdf formats).
###
### Last updated by Wyat Appel: June, 2017
################################################################

## get some environmental variables and setup some directories
ametbase	<- Sys.getenv("AMETBASE")        		# base directory of AMET
ametR		<- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

### Retrieve units label from database table ###
network <- network_names[1] 
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql) 
################################################

### Set file names and titles ###
filename_error_pdf	<- paste(run_name1,species,pid,"bugleplot_error.pdf",sep="_")
filename_bias_pdf 	<- paste(run_name1,species,pid,"bugleplot_bias.pdf",sep="_")
filename_error_png 	<- paste(run_name1,species,pid,"bugleplot_error.png",sep="_")
filename_bias_png 	<- paste(run_name1,species,pid,"bugleplot_bias.png",sep="_")

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(run_name1,species,"for",network_label[1],"for",dates,sep=" ") }
   else { title <- custom_title }
}

## Create a full path to file
filename_error_pdf	<- paste(figdir,filename_error_pdf,sep="/")
filename_bias_pdf	<- paste(figdir,filename_bias_pdf,sep="/")
filename_error_png	<- paste(figdir,filename_error_png,sep="/")
filename_bias_png	<- paste(figdir,filename_bias_png,sep="/")
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
   criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
   check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name1,"' and COLUMN_NAME = 'POCode';",sep="")
   query_table_info.df <-db_Query(check_POCode,mysql)
   {
      if (length(query_table_info.df$COLUMN_NAME)==0) {   # Check to see if individual project tables exist
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")      # Set the rest of the MYSQL query
            aqdat.df <- db_Query(qs,mysql)               # Query the database 
            aqdat.df$POCode <- 1
         }
      else {
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob,d.POCode from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")	# Set the rest of the database query
         aqdat.df <- db_Query(qs,mysql)               # Query the database
      }
   }
   cat(qs)
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
   #########################################################################################################

   if (soccerplot_opt == 1) {	# If using NMB/NME, create list with those values
      plot_vals[[j]]<-list(VAL1=stats_all.df$AVG_CONC,VAL2=stats_all.df$Percent_Norm_Mean_Bias, VAL3=stats_all.df$Percent_Norm_Mean_Err) 
   }
   else { plot_vals[[j]]<-list(VAL1=stats_all.df$AVG_CONC,VAL2=stats_all.df$Frac_Bias,VAL3=stats_all.df$Frac_Err) }	# Else, use FB/FE instead

   max_conc <- max(max_conc,stats_all.df$AVG_CONC)	# Determine the maximum average concentration
}

####################################


########## MAKE BUGLE PLOT: ERROR/CONCENTRATION ##########

pdf(file=filename_error_pdf,width=10,height=8)			# Set output device and device options
par(mai=c(1,1,0.5,0.5))					# Set margins
x <- seq(0,max_conc*1.20, by=0.01)			# Create a sequence from 1 to 1.2*max_conc, increasing by 0.01
y_goal <- 150*exp(-x/0.75)+50				# y value for the goal
y_crit <- 125*exp(-x/0.75)+75				# y value for the criteria
plot(x, y_goal, type="l", pch=2, col="dark green", ylim=c(7.4,192.7), xlim=c((max_conc*0.046), (max_conc*1.20)), xlab=paste("Mod/Obs Average Concentration (",units,")",sep=""), ylab=ylabel2, cex.axis=1.5, cex.lab=1.2,lwd=2)						# plot goal line
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

### Create png format file from pdf file ###
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density 150x150 ",filename_error_pdf," png:",filename_error_png,sep="")
   dev.off()
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_error_pdf,sep="")
      system(remove_command)
   }
}
############################################

########## MAKE BUGLE PLOT: BIAS/CONCENTRATION ##########

pdf(file=filename_bias_pdf,width=10,height=8)			# Set output device and device options
par(mai=c(1,1,0.5,0.5))         				# Set margins

### Create criteria and goal lines for the bugle plot ###
x <- seq(0,max_conc*1.20, by=0.01)				# Create a sequence from 1 to 1.2*max_conc, increasing by 0.01
y_goal     <- 170*exp(-x/0.5)+30				# y value for the goal
y_goal_neg <- -170*exp(-x/0.5)-30				# y value for the goal (negative bias)
y_crit     <- 140*exp(-x/0.5)+60				# y value for the criteria
y_crit_neg <- -(140*exp(-x/0.5)+60)				# y value for the criteria (negative bias)
#########################################################

plot(x, y_goal, type="l", pch=2, col="dark green", ylim=c(-192.7,192.7), xlim=c((max_conc*0.046), (max_conc*1.20)), xlab=paste("Average Concentration (",units,")",sep=""), ylab=ylabel1, cex.axis=1.5, cex.lab=1.5,lwd=2)	# Create plot using goal line
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

### Create png format file from pdf file ###
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density 150x150 ",filename_bias_pdf," png:",filename_bias_png,sep="")
   dev.off()
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_bias_pdf,sep="")
      system(remove_command)
   }
}
############################################
