################## MODEL TO OBS SCATTERPLOT #################### 
### AMET CODE: R_Scatterplot.r 
###
### This script is part of the AMET-AQ system.  This script creates
### a single model-to-obs scatterplot. This script will plot a
### single species from up to three networks on a single plot.  
### Additionally, summary statistics are also included on the plot.  
### The script will also allow a second run to plotted on top of the
### first run. 
###
### Last Updated by Wyat Appel; March, 2017
################################################################

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")        # base directory of AMET
dbase           <- Sys.getenv("AMET_DATABASE")      # AMET database
ametR           <- paste(ametbase,"/R_analysis_code",sep="")      # R directory
ametRinput      <- Sys.getenv("AMETRINPUT")  # input file for this script
ametptype       <- Sys.getenv("AMET_PTYPE")   # Prefered output type
## Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
## and not specified via AMET_OUT, then set figdir to the current directory
if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")       }
if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"                 }

## source some configuration files, AMET libs, and input
source(paste(ametbase,"/configure/amet-config.R",sep=""))
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file
source(ametRinput)                                     # Anaysis configuration/input file

## Load Required Libraries 
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}

mysql <- list(login=amet_login, passwd=amet_pass, server=mysql_server, dbase=dbase, maxrec=maxrec)

### Set file names and titles ###

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(run_name1," ",species," for ",dates,sep="") }
   else { title <- custom_title }
}

filename_pdf <- paste(run_name1,species,pid,"scatterplot.pdf",sep="_")             # Set PDF filename
filename_png <- paste(run_name1,species,pid,"scatterplot.png",sep="_")             # Set PNG filename
filename_txt <- paste(run_name1,species,pid,"scatterplot.csv",sep="_")       # Set output file name

## Create a full path to file
filename_pdf <- paste(figdir,filename_pdf,sep="/")      # Set PDF filename
filename_png <- paste(figdir,filename_png,sep="/")      # Set PNG filenam
filename_txt <- paste(figdir,filename_txt,sep="/")      # Set output file name

#################################

axis.max     <- NULL
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
network <- network_names[1]
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql)
model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
model_name <- db_Query(model_name_qs,mysql)
model_name <- model_name[[1]]
################################################

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
labels <- c(network,run_names)

for (j in 1:length(run_names)) {
   source(ametRinput)
   run_name <- run_names[j]
   criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")		# Set part of the MYSQL query
   check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name1,"' and COLUMN_NAME = 'POCode';",sep="")
   query_table_info.df <-db_Query(check_POCode,mysql)
   {
      if (length(query_table_info.df$COLUMN_NAME)==0) {
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")	# Set the rest of the MYSQL query
         aqdat_query.df        <- db_Query(qs,mysql)
         aqdat_query.df$POCode <- 1
      }
      else {
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod,d.POCode from ",run_name," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")   # Set the rest of the MYSQL query
         aqdat_query.df        <- db_Query(qs,mysql)  
      }
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
      ####################### 
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
   axis.max <- max(c(axis.max,aqdat.df$Obs_Value,aqdat.df$Mod_Value),na.rm=T) 
   #########################################################
   #### Calculate statistics for each requested network ####
   #########################################################
   ## Calculate stats using all pairs, regardless of averaging
   data_all.df <- data.frame(network=I(aqdat_stats.df$Network),stat_id=I(aqdat_stats.df$Stat_ID),lat=aqdat_stats.df$lat,lon=aqdat_stats.df$lon,ob_val=aqdat_stats.df$Obs_Value,mod_val=aqdat_stats.df$Mod_Value,precip_val=aqdat_stats.df$precip_ob)
   stats.df <-try(DomainStats(data_all.df))      # Compute stats using DomainStats function for entire domain
   num_pairs   <- NULL
   mean_mod    <- NULL
   mean_obs	  <- NULL
   corr        <- NULL
   r_sqrd	  <- NULL
   rmse        <- NULL
   nmb         <- NULL
   nme         <- NULL
   mb          <- NULL
   me          <- NULL
   med_bias    <- NULL
   med_error   <- NULL
   fb          <- NULL
   fe          <- NULL
   stats_array <- NULL
   stats_array_include <- NULL
   stats_names_include <- NULL
   num_pairs   <- stats.df$NUM_OBS
   mean_obs    <- round(stats.df$MEAN_OBS,1)
   mean_mod    <- round(stats.df$MEAN_MODEL,1)
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
   r_sqrd	  <- round(stats.df$R_Squared,2)
   rmse        <- round(stats.df$RMSE,2)
   rmse_sys    <- round(stats.df$RMSE_systematic,2)
   rmse_unsys  <- round(stats.df$RMSE_unsystematic,2)
   index_agr   <- round(stats.df$Index_of_Agree,2)
   stats_array <- c(num_pairs,mean_obs,mean_mod,index_agr,corr,r_sqrd,rmse,rmse_sys,rmse_unsys,nmb,nme,nmdnb,nmdne,mb,me,med_bias,med_error,fb,fe)		# Order must be matched to AMET query page order
   stats_names <- c("n","Mn_O","Mn_M","IofA","r",expression(paste(R^2)),"RMSE",expression(paste(RMSE[s])),expression(paste(RMSE[u])),"NMB","NME","NMdnB","NMdnE","MB","ME","MdnB","MdnE","FB","FE")	# Order must be matched to order above
   for (i in 1:19) {
      if (stats_flags[i] == "y") {
          stats_array_include <- c(stats_array_include,stats_array[i])
          stats_names_include <- c(stats_names_include,stats_names[i])
      }
   }
   #########################################################

   sinfo[[j]]<-list(plotval_obs=aqdat.df$Obs_Value,plotval_mod=aqdat.df$Mod_Value,stat1=stats_array_include[1],stat2=stats_array_include[2],stat3=stats_array_include[3],stat4=stats_array_include[4],stat5=stats_array_include[5])        # create of list of plot values and corresponding statistics
   ##############################
   ### Write Data to CSV File ###
   ##############################
   if (j == 1) {
      write.table(run_name1,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
      write.table(dates,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(aqdat.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
   }
   else {
      write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(aqdat.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
   }
 
   ###############################
}				# End for loop for networks

axis.min <- axis.max * .033

### If user sets axis maximum, compute axis minimum ###
if ((length(y_axis_max) > 0) || (length(x_axis_max) > 0)) {
   axis.max <- max(y_axis_max,x_axis_max)
   axis.min <- axis.max * 0.033
}
if ((length(y_axis_min) > 0) || (length(x_axis_min) > 0)) {
   axis.min <- max(y_axis_max,x_axis_max)
   axis.min <- axis.max * 0.033
}
#######################################################

for (i in 1:length(run_names)) {
   run_name <- run_names[i]
   if (i == 1) {
      ##############################################
      ########## MAKE SCATTERPLOT: ALL US ##########
      ##############################################
      #### Define Stats box placement ####
      axis.length <- (axis.max - axis.min)
      label1 <- axis.max * 0.580
      right  <- axis.max                                        # define box rightside
      left   <- axis.max - (axis.length * 0.580)
      bottom <- axis.min
      top    <- axis.max - (axis.length * 0.820)
      x7 <- axis.max - (axis.length * 0.260)                    # define right justification for run name
      x6 <- axis.max - (axis.length * 0.040)                    # define right justification for NME
      x5 <- axis.max - (axis.length * 0.120)                    # define right justification for NMB
      x4 <- axis.max - (axis.length * 0.200)                    # define right justification for RMSEu
      x3 <- axis.max - (axis.length * 0.290)                    # define right justification for RMSEs
      x2 <- axis.max - (axis.length * 0.370)                    # define right justification for Index of Agreement
      x1 <- axis.max - (axis.length * 0.410)                    # define right justification for Network
      y1 <- axis.max - (axis.length * 0.830)                    # define y for labels
      y2 <- axis.max - (axis.length * 0.860)                    # define y for run 1 
      y3 <- axis.max - (axis.length * 0.890)                    # define y for run 2
      y4 <- axis.max - (axis.length * 0.920)                    # define y for run 3
      y5 <- axis.max - (axis.length * 0.950)                    # define y for run 4
      y6 <- axis.max - (axis.length * 0.980)                    # define y for run 5
      y7 <- axis.max - (axis.length * 1.01)
      y8 <- axis.max - (axis.length * 0.700)                    # define y for species text
      y9 <- axis.max - (axis.length * 0.660)                    # define y for timescale (averaging)
      y10 <- axis.max - (axis.length * 0.740)
      y11 <- axis.max - (axis.length * 0.780)
      x <- c(x1,x2,x3,x4,x5,x6,x7)                              # set vector of x offsets
      y <- c(y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11)                        # set vector of y offsets
      ######################################

      ### Preset values for plot characters and colors (these can be changed to user preference) ###
#      plot_chars <- c(1,2,3,4,5)                                 	# set vector of plot characters
      plot_chars <- c(1,1,1,1,1,1)
      #plot_colors <- c("red","blue","green","purple","orange")
      ##############################################################################################
      pdf(file=filename_pdf,width=8,height=8)
      ### Plot and draw rectangle with stats ###
      par(mai=c(1,1,0.5,0.5))
      plot(1,1,type="n", pch=2, col="red", ylim=c(axis.min, axis.max), xlim=c(axis.min, axis.max), xlab="Observation", ylab=model_name, cex.axis=1.3, cex.lab=1.3)	# create plot axis and labels, but do not plot any points
      text(axis.max,y[8], paste(species," (",units,")"),cex=1.2,adj=c(1,0))		# add species text
      text(axis.max,y[9], aqdat.df$avg_text, cex=1.2,adj=c(1,0))			# add timescale text (e.g. monthly average)
   }

#   rect(ybottom=bottom,ytop=top,xright=right,xleft=left)			# create rectangle for stats
   text(x[2],y[1], stats_names_include[1] ,font=3,cex=0.8)
   text(x[3],y[1], stats_names_include[2] ,font=3,cex=0.8)					# write RMSE systematic title
   text(x[4],y[1], stats_names_include[3] ,font=3,cex=0.8)					# write RMSE unsystematic title
   text(x[5],y[1], stats_names_include[4] ,font=3,cex=0.8)					# write NMB title
   text(x[6],y[1], stats_names_include[5] ,font=3,cex=0.8)					# write NME title
   ##########################################

   #################################################
   ### Plot points and stats for each simulation ###
   #################################################
   point_color <- plot_colors[i]
   points(sinfo[[i]]$plotval_obs,sinfo[[i]]$plotval_mod,pch=plot_chars[i],col=plot_colors[i],cex=1)	# plot points for each network
   text(x[1],y[i+1], run_name, cex=0.9, adj=c(1,0.5))								# add network text to stats box
   text(x[2],y[i+1], sinfo[[i]]$stat1, cex=0.9)								# write network stat1
   text(x[3],y[i+1], sinfo[[i]]$stat2, cex=0.9)								# write network stat2
   text(x[4],y[i+1], sinfo[[i]]$stat3, cex=0.9)                          					# write network stat3
   text(x[5],y[i+1], sinfo[[i]]$stat4, cex=0.9)       	                    				# write netowrk stat4
   text(x[6],y[i+1], sinfo[[i]]$stat5, cex=0.9)								# write network stat5

   if (run_info_text == "y") {
      legend_names <- c(legend_names,run_name)
   }
   legend_cols  <- c(legend_cols,plot_colors[i])
   legend_chars <- c(legend_chars,plot_chars[i])
}
##############################################

###################################
### Put title at top of boxplot ###
###################################
title(main=title,cex.main=1.1)
###################################

### Put 1-to-1 lines and confidence lines on plot ###
abline(0,1)                                     # create 1-to-1 line
if (conf_line=="y") {
   abline(0,(1/1.5),col="black",lty=1)              # create lower bound 2-to-1 line
   abline(0,1.5,col="black",lty=1)                # create upper bound 2-to-1 line
} 

### Add descripitive text to plot area ###
if (run_info_text == "y") {
   if (rpo != "None") {
      text(x=x[1],y=y[9], paste("RPO = ",rpo,sep=""),cex=1,adj=c(0,.5))           # add RPO region to plot
   }
   if (pca != "None") {
      text(x=x[4],y=y[9], paste("PCA = ",pca,sep=""),cex=1,adj=c(0.25,0.5))
   }
   if (state != "All") {
      text(x=x[1],y=y[10], paste("State = ",state,sep=""),cex=1,adj=c(0,.5))       # add State abbreviation to plot
   }
   if (site != "All") {
      text(x=x[4],y=y[10], paste("Site = ",site,sep=""),cex=1,adj=c(0.25,0.5))                     # add Site name to plot
   }
}
##########################################


#####################################################

### Put legend on the plot ###
legend("topleft", legend_names, pch=legend_chars,col=legend_cols, merge=F, cex=1.2, bty="n")
##############################

### Convert pdf file to png file ###
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density 150x150 ",filename_pdf," png:",filename_png,sep="")
   dev.off()
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}
####################################
