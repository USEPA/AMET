################## CDF, Q-Q, TAYLOR and SPECTRAL PLOTS  #################### 
### AMET CODE: AQ_Temporal.R
###
### This script creates four plots, a Cumulative Distribution Plot (CDF), a
### Q-Q plot, and Taylor diagram plot, and a periodogram. The periodogram plot
### should be used with caution, as the code has not been robustly tested at
### this point. This code is new to the AMETv1.2 release.
###
### Last Updated by Wyat Appel: December 6, 2012
###
############################################################################

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
if(!require(stats)){stop("Required Package stats was not loaded")}
if(!require(plotrix)){stop("Required Package plotrix was not loaded")}

mysql <- list(login=login, passwd=passwd, server=server, dbase=dbase, maxrec=maxrec)           # Set MYSQL login and query options

network <- network_names[1]

### Set file names and titles ###
outname_ecdf_pdf 	<- paste(run_name1,species,"ecdf.pdf",sep="_")			# Set PDF filename
outname_ecdf_png 	<- paste(run_name1,species,"ecdf.png",sep="_") 			# Set PNG filename
outname_qq_pdf 		<- paste(run_name1,species,"qq.pdf",sep="_")                        # Set PDF filename
outname_qq_png 		<- paste(run_name1,species,"qq.png",sep="_")                        # Set PNG filename
outname_taylor_pdf 	<- paste(run_name1,species,"taylor.pdf",sep="_")                    # Set PDF filename
outname_taylor_png 	<- paste(run_name1,species,"taylor.png",sep="_")                    # Set PNG filename
outname_spectral_pdf	<- paste(run_name1,species,"periodogram.pdf",sep="_")               # Set PDF filename
outname_spectral_png	<- paste(run_name1,species,"periodogram.png",sep="_")               # Set PNG filename
## Create a full path to file 
outname_ecdf_pdf	<- paste(figdir,outname_ecdf_pdf,sep="/")
outname_ecdf_png 	<- paste(figdir,outname_ecdf_png,sep="/")
outname_qq_pdf		<- paste(figdir,outname_qq_pdf,sep="/")
outname_qq_png		<- paste(figdir,outname_qq_png,sep="/")
outname_taylor_pdf	<- paste(figdir,outname_taylor_pdf,sep="/")
outname_taylor_png	<- paste(figdir,outname_taylor_png,sep="/")
outname_spectral_pdf	<- paste(figdir,outname_spectral_pdf,sep="/")
outname_spectral_png	<- paste(figdir,outname_spectral_png,sep="/")

#################################

axis.max     <- NULL
qq.axis.max  <- NULL
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
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql)
model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
model_name <- db_Query(model_name_qs,mysql)
model_name <- model_name[[1]]
################################################

run_count <- 1
num_runs <- 1									# Set number of runs to 1
run_names <- run_name1
if (run_name2 != "empty") {							# Check to see if second run set
   num_runs <- 2
   run_names <- c(run_names,run_name2)						# If so, set number of runs to 2
}
if (run_name3 != "empty") {                                                     # Check to see if second run set
   num_runs <- 3                                                                # If so, set number of runs to 2
   run_names <- c(run_names,run_name3)
}
run_name <- run_name1

network <- network_names[[1]]
for (j in 1:length(run_names)) {
   run_name <- run_names[j]						# Set network
   query <- paste(" and s.stat_id=d.stat_id and d.ob_dates BETWEEN", start_date, "and", end_date, "and d.ob_datee BETWEEN", start_date, "and", end_date, "and ob_hour between", start_hour, "and", end_hour, add_query,sep=" ")
   criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")		# Set part of the MYSQL query
   qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")	# Set the rest of the MYSQL query
   aqdat_query.df<-db_Query(qs,mysql)							# Query the database and store in aqdat.df dataframe     

   ## test that the query worked
   if (length(aqdat_query.df) == 0){
      ## error the queried returned nothing
      writeLines("ERROR: Check species/network pairing and Obs start and end dates")
      stop(paste("ERROR querying db: \n",qs))
   }
   if (averaging != "n") {
      aqdat.df <- data.frame(Network=aqdat_query.df$network,Stat_ID=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=round(aqdat_query.df[,9],5),Mod_Value=round(aqdat_query.df[,10],5),Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month,precip_ob=aqdat_query.df$precip_ob,precip_mod=aqdat_query.df$precip_mod)
      {
         if (use_avg_stats == "y") {
            aqdat.df <- Average(aqdat.df)
            aqdat_stats.df <- aqdat.df                               # Call Monthly_Average function in Misc_Functions.R
         }
         else {
            aqdat_stats.df <- aqdat.df
            aqdat.df <- Average(aqdat.df)
         }
      }
   }
   else { 
      aqdat.df <- aqdat_query.df
      ### if plotting all obs, remove missing obs and zero precip obs if requested ###
      if (remove_negatives == "y") {
         indic.nonzero <- aqdat.df[,9] >= 0		# determine which obs are missing (less than 0); 
         aqdat.df <- aqdat.df[indic.nonzero,]	# remove missing obs from dataframe
         indic.nonzero <- aqdat.df[,10] >= 0          # determine which obs are missing (less than 0); 
         aqdat.df <- aqdat.df[indic.nonzero,]        # remove missing obs from dataframe
      }
      ######################
      aqdat.df <- data.frame(Network=aqdat.df$network,Stat_ID=aqdat.df$stat_id,lat=aqdat.df$lat,lon=aqdat.df$lon,Obs_Value=round(aqdat.df[,9],5),Mod_Value=round(aqdat.df[,10],5),Month=aqdat.df$month,precip_ob=aqdat.df$precip_ob)      # Create dataframe of network values to be used to create a list
      aqdat_stats.df <- aqdat.df
   }
   axis.max <- max(c(axis.max,aqdat.df$Obs_Value,aqdat.df$Mod_Value)) 
   sinfo[[j]]<-list(plotval_obs=aqdat.df$Obs_Value,plotval_mod=aqdat.df$Mod_Value)        # create of list of plot values and corresponding statistics
}				# End for loop for networks
#######################################################

### Set Plotting Defaults ###
leg_colors <- 'black'
leg_names <- network_label
#############################

###########################################
### Create Cumulative Distribution Plot ###
###########################################
pdf(file=outname_ecdf_pdf,width=8,height=8)
Fn_obs <- ecdf(sinfo[[1]]$plotval_obs)  	# Compute CDF information for observations
xmax <- max(sinfo[[1]]$plotval_obs,sinfo[[1]]$plotval_mod)
plot(Fn_obs, col='black', xlab=paste('value (', units,')',sep=""),xlim=c(0,xmax),main=paste("CDF for",run_name1,"/",network_label,species,"for",start_date,"to",end_date,sep=" "),cex.main=1)	# Plot CDF for Observations
for (i in 1:num_runs) {		# For each model simulation
   Fn_mod <- ecdf(sinfo[[i]]$plotval_mod)
   plot(Fn_mod, col=plot_colors[i], add=T)
   leg_names <- c(leg_names, run_names[i])
   leg_colors <- c(leg_colors,plot_colors[i])
}
legend("bottomright", leg_names, pch=1, col=leg_colors,bty='n',cex=1,inset=c(0,0.03))	# Plot legend

if (run_info_text == "y") {
   if (rpo != "None") {
      text(x=xmax,y=.4, paste("RPO = ",rpo,sep=""),cex=1,adj=c(1,0.5))           # add RPO region to plot
   }
   if (state != "All") {
      text(x=xmax,y=.34, paste("State = ",state,sep=""),cex=1,adj=c(1,.5))       # add State abbreviation to plot
   }
   if (site != "All") {
      text(x=xmax,y=.31, paste("Site = ",site,sep=""),cex=1,adj=c(1,0.5))                     # add Site name to plot
   }
}
dev.off()
### Process if PNG output requested ###
if (ametptype == "png") {
   ### Convert pdf format file to png format ###
   convert_command<-paste("convert -density 150x150 ",outname_ecdf_pdf," ",outname_ecdf_png,sep="")
   system(convert_command)

#   ### Remove PDF ###
#   remove_command <- paste("rm ",outname_pdf,sep="")
#   system(remove_command)
}
####################################

##########################
### Create Taylor Plot ###
##########################
i <- 1
pdf(file=outname_taylor_pdf,width=8,height=8)
taylor.diagram(sinfo[[i]]$plotval_obs, sinfo[[i]]$plotval_mod,main=paste("Taylor Diagram for",run_name1,"/",network_label,species,"for",start_date,"to",end_date,sep=" "),cex.main=.9)
while (i < num_runs) {
   i <- i+1
   taylor.diagram(sinfo[[i]]$plotval_ob,sinfo[[i]]$plotval_mod,add=T,col=plot_colors[i])
}
legend("bottomright",legend=leg_names,pch=1,col=leg_colors,bty='n')
dev.off()

### Process if PNG output requested ###
if (ametptype == "png") {
   ### Convert pdf format file to png format ###
   convert_command<-paste("convert -density 150x150 ",outname_taylor_pdf," ",outname_taylor_png,sep="")
   system(convert_command)

#   ### Remove PDF ###
#   remove_command <- paste("rm ",outname_pdf,sep="")
#   system(remove_command)
}
####################################

##############################################################
### Create Periodogram Plot (Experimental; Use w/ caution) ###
##############################################################
i <- 1
num_obs <- length(sinfo[[i]]$plotval_obs)
if(num_obs < 100000) {	# Do not plot the periodogram for large datasets (takes too long)
   pdf(file=outname_spectral_pdf,width=8,height=8)
   spec.pgram(sinfo[[i]]$plotval_obs,col="black",main="")
   for (i in 1:num_runs) {
      spec.pgram(sinfo[[i]]$plotval_mod,add=T,col=plot_colors[i])
   }
}
legend("bottomleft", legend=leg_names, lty=1, col=leg_colors, cex=1, bty="n")
title(main=paste("Periodogram for",run_name1,"/",network_label,species,"for",start_date,"to",end_date,sep=" "),cex.main=1)
dev.off()

### Process if PNG output requested ###
if (ametptype == "png") {
  ### Convert pdf format file to png format ###
  convert_command<-paste("convert -density 150x150 ",outname_spectral_pdf," ",outname_spectral_png,sep="")
  system(convert_command)

   #   ### Remove PDF ###
   #   remove_command <- paste("rm ",outname_pdf,sep="")
   #   system(remove_command)
}
####################################

#####################################
### Create Quantile-Quantile Plot ###
#####################################
i <- 1
leg_names<-run_name1
leg_colors<-plot_colors[i]
pdf(file=outname_qq_pdf,width=8,height=8)
for (j in 1:num_runs) {
   qq.axis.max <- max(qq.axis.max,sinfo[[j]]$plotval_obs,sinfo[[j]]$plotval_mod)
}
qq_tmp <- qqplot(sinfo[[i]]$plotval_obs,sinfo[[i]]$plotval_mod, plot.it=F)
plot(qq_tmp$x,qq_tmp$y,pch=1,xlab=paste('Observed ',species,' (',units,')',sep=""), xlim=c(0,qq.axis.max),ylim=c(0,qq.axis.max),ylab=paste('Predicted ',species,' (',units,')',sep=""), col=plot_colors[i])
while (i < num_runs) {         # For each model simulation
   i <- i+1
   qq_tmp <- qqplot(sinfo[[i]]$plotval_obs,sinfo[[i]]$plotval_mod, plot.it=F)
   points(qq_tmp$x,qq_tmp$y,col=plot_colors[i])
   leg_names <- c(leg_names, run_names[i])
   leg_colors <- c(leg_colors,plot_colors[i])
}  
abline(0,1)
title(main=paste("Q-Q Plot for",network_label,species,"for",start_date,"to",end_date,sep=" "),cex.main=1)
legend("topleft", leg_names, pch=1, col=leg_colors,bty='n',cex=1,inset=c(0,0.03))   # Plot legend

if (run_info_text == "y") {
   if (rpo != "None") {
      text(x=qq.axis.max,y=0, paste("RPO = ",rpo,sep=""),cex=1,adj=c(1,0.5))           # add RPO region to plot
   }
   if (state != "All") {
      text(x=qq.axis.max,y=0.12*qq.axis.max, paste("State = ",state,sep=""),cex=1,adj=c(1,0.5))       # add State abbreviation to plot
   }
   if (site != "All") {
      text(x=qq.axis.max,y=0.18*qq.axis.max, paste("Site = ",site,sep=""),cex=1,adj=c(1,0.5))                     # add Site name to plot
   }
}
dev.off()

### Process if PNG output requested ###
if (ametptype == "png") {
   ### Convert pdf format file to png format ###
   convert_command<-paste("convert -density 150x150 ",outname_qq_pdf," ",outname_qq_png,sep="")
   system(convert_command)

#   ### Remove PDF ###
#   remove_command <- paste("rm ",outname_pdf,sep="")
#   system(remove_command)
}
####################################
