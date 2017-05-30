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
### Last Updated by Wyat Appel; December 6, 2012
###
### Modified to work with combined MET/AQ mode, Alexis Zubrow (IE UNC) Oct, 2007
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
outname_pdf <- paste(run_name1,species,"scatterplot.pdf",sep="_")                               # Set PDF filename
outname_png <- paste(run_name1,species,"scatterplot.png",sep="_")                               # Set PNG filename
{
   if (custom_title == "") { title <- paste(run_name1,species,"for",start_date,"to",end_date,sep=" ") }
   else { title <- custom_title }
}

## Create a full path to file
outname_pdf <- paste(figdir,outname_pdf,sep="/")
outname_png <- paste(figdir,outname_png,sep="/")

####################################################

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

run_count <- 1
num_runs <- 1									# Set number of runs to 1
if (run_name2 != "empty") {							# Check to see if second run set
   num_runs <- 2								# If so, set number of runs to 2
}
run_name <- run_name1

while (run_count <= num_runs) {
   for (j in 1:length(network_names)) {
      network <- network_names[[j]]						# Set network
      query <- paste(" and s.stat_id=d.stat_id and d.ob_dates BETWEEN", start_date, "and", end_date, "and d.ob_datee BETWEEN", start_date, "and", end_date, "and ob_hour between", start_hour, "and", end_hour, add_query,sep=" ")
      criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")             # Set part of the MYSQL query
      qs <- paste("SELECT d.network,d.stat_id,s.lat,s.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")      # Set the rest of the MYSQL query
      aqdat_query.df<-db_Query(qs,mysql)							# Query the database and store in aqdat.df dataframe    

      ## test that the query worked
      if (length(aqdat_query.df) == 0){
        ## error the queried returned nothing
        writeLines("ERROR: Check species/network pairing and Obs start and end dates")
        stop(paste("ERROR querying db: \n",qs))
      }
 
      ################################################################################
      ### if plotting all obs, remove missing obs and zero precip obs if requested ###
      ################################################################################
      if (remove_negatives == "y") {
         indic.nonzero <- aqdat_query.df[,9] >= 0                                                  # determine which obs are missing (less than 0); 
         aqdat_query.df <- aqdat_query.df[indic.nonzero,]                                                        # remove missing obs from dataframe
         indic.nonzero <- aqdat_query.df[,10] >= 0
         aqdat_query.df <- aqdat_query.df[indic.nonzero,]
      }
      #################################################################################

      if (averaging != "n") {
         aqdat.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=round(aqdat_query.df[,9],5),Mod_Value=round(aqdat_query.df[,10],5),Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month,precip_ob=aqdat_query.df$precip_ob,precip_mod=aqdat_query.df$precip_mod)
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
         aqdat.df <- data.frame(Network=aqdat.df$network,Stat_ID=aqdat.df$stat_id,lat=aqdat.df$lat,lon=aqdat.df$lon,Obs_Value=round(aqdat.df[,9],5),Mod_Value=round(aqdat.df[,10],5),Month=aqdat.df$month,precip_ob=aqdat.df$precip_ob)      # Create dataframe of network values to be used to create a list
         aqdat_stats.df <- aqdat.df
      }
      axis.max <- max(c(axis.max,aqdat.df$Obs_Value,aqdat.df$Mod_Value)) 
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

      if (run_count == 1) {
         sinfo[[j]]<-list(plotval_obs=aqdat.df$Obs_Value,plotval_mod=aqdat.df$Mod_Value,stat1=stats_array_include[1],stat2=stats_array_include[2],stat3=stats_array_include[3],stat4=stats_array_include[4],stat5=stats_array_include[5],r_sqrd=r_sqrd)        # create of list of plot values and corresponding statistics
      }
      else {
         sinfo2[[j]]<-list(plotval_obs=aqdat.df$Obs_Value,plotval_mod=aqdat.df$Mod_Value,stat1=stats_array_include[1],stat2=stats_array_include[2],stat3=stats_array_include[3],stat4=stats_array_include[4],stat5=stats_array_include[5])        # create of list of plot values and corresponding statistics
      }
      ##############################
      ### Write Data to CSV File ###
      ##############################
      if (j == 1) {
         filename_txt <- paste(run_name1,species,"scatterplot.csv",sep="_")     # Set output file name
         filename_txt <- paste(figdir,filename_txt, sep="/")  ## make full path
         write.table(run_name1,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
         write.table(t(c(start_date,end_date)),file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
         write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
         write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
         write.table(aqdat_query.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
      }
      else {
         write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
         write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
         write.table(aqdat_query.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
      }
   
      ###############################
   }				# End for loop for networks
   run_count <- run_count+1
   run_name <- run_name2
}				# End while loop runs
axis.min <- axis.max * .033

### If user sets axis maximum, compute axis minimum ###
if ((length(y_axis_max) > 0) || (length(x_axis_max) > 0)) {
   axis.max <- max(y_axis_max,x_axis_max)
   axis.min <- axis.max * 0.033
}
if ((length(y_axis_min) > 0) || (length(x_axis_min) > 0)) {
   axis.min <- min(y_axis_min,x_axis_min)
}
#######################################################

run_name <- run_name1
run_count = 1;
while (run_count <= num_runs) {
   ##############################################
   ########## MAKE SCATTERPLOT: ALL US ##########
   ##############################################
   if (run_count == 1) {
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
      x1 <- axis.max - (axis.length * 0.490)                    # define right justification for Network
      y1 <- axis.max - (axis.length * 0.890)                    # define y for labels
      y2 <- axis.max - (axis.length * 0.850)                    # define y for run name
      y3 <- axis.max - (axis.length * 0.920)                    # define y for network 1
      y4 <- axis.max - (axis.length * 0.950)                    # define y for network 2
      y5 <- axis.max - (axis.length * 0.980)                    # define y for network 3
      y6 <- axis.max - (axis.length * 0.700)                    # define y for species text
      y7 <- axis.max - (axis.length * 0.660)                    # define y for timescale (averaging)
      y8 <- axis.max - (axis.length * 0.740)
      y9 <- axis.max - (axis.length * 0.780)
      y10 <- axis.max*0.82
      y11 <- axis.max*0.78
      x <- c(x1,x2,x3,x4,x5,x6,x7)                              # set vector of x offsets
      y <- c(y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11)                # set vector of y offsets
      ######################################

      ### Preset values for plot characters and colors (these can be changed to user preference) ###
      plot_chars <- c(1,2,3,4)                                 	# set vector of plot characters
      ##############################################################################################
      pdf(file=outname_pdf,width=8,height=8)
      ### Plot and draw rectangle with stats ###
      par(mai=c(1,1,0.5,0.5))
      plot(1,1,type="n", pch=2, col="red", ylim=c(axis.min, axis.max), xlim=c(axis.min, axis.max), xlab="Observation", ylab=model_name, cex.axis=1.3, cex.lab=1.3)	# create plot axis and labels, but do not plot any points
      if (run_info_text == "y") {
         text(x[7],y[2], run_name, cex=1)						# add run name text
      }
      text(axis.max,y[6], paste(species," (",units,")"),cex=1.2,adj=c(1,0))		# add species text
      text(axis.max,y[7], aqdat.df$avg_text, cex=1.2,adj=c(1,0))			# add timescale text (e.g. monthly average)
      rect(ybottom=bottom,ytop=top,xright=right,xleft=left)			# create rectangle for stats
      text(x[2],y[1], stats_names_include[1] ,font=3,cex=0.8)
      text(x[3],y[1], stats_names_include[2] ,font=3,cex=0.8)					# write RMSE systematic title
      text(x[4],y[1], stats_names_include[3] ,font=3,cex=0.8)					# write RMSE unsystematic title
      text(x[5],y[1], stats_names_include[4] ,font=3,cex=0.8)					# write NMB title
      text(x[6],y[1], stats_names_include[5] ,font=3,cex=0.8)					# write NME title
      ##########################################

      ### Put title at top of boxplot ###
      title(main=title,cex.main=1.1)
      ###################################
   }

   if (run_count == 2) {
      ### Preset values for plot characters and colors (these can be changed to user preference) ###
      plot_chars <- c(1,2,3,4)
      plot_colors  <- plot_colors2   			# set vector of plot colors
      ##############################################################################################
      #### Define Stats box placement for run 2 ####
      right <- axis.max * 0.560					# define box rightside
      left <- axis.max * 0.010					# define box leftside
      bottom <- axis.max * 0.810				# define box bottom
      top <- axis.max  	                  			# define box top
      x7 <- axis.max * 0.300
      x6 <- axis.max * 0.520
      x5 <- axis.max * 0.440                  			# define right justification for run name
      x4 <- axis.max * 0.360                    		# define right justification for NME
      x3 <- axis.max * 0.280                    		# define right justification for NMB
      x2 <- axis.max * 0.200                    		# define right justification for RMSE
      x1 <- axis.max * 0.090                    		# define right justification for Network
      y1 <- axis.max * 0.940                    		# define y for labels
      y2 <- axis.max * 0.980                    		# define y for run name
      y3 <- axis.max * 0.900                    		# define y for network 1
      y4 <- axis.max * 0.870                    		# define y for network 2
      y5 <- axis.max * 0.840                    		# define y for network 3
      y6 <- axis.max * 0.810
      x2 <- c(x1,x2,x3,x4,x5,x6,x7)                    		# set vector of x offsets
      y2 <- c(y1,y2,y3,y4,y5,y6)					# set vector of y offsets
      rect(ybottom=bottom,ytop=top,xright=right,xleft=left)     # create rectangle for stats
      text(x2[7],y2[2], run_name, cex=1)				# add run name to stats box
      text(x2[2],y2[1], stats_names_include[1] ,font=3,cex=0.8)
      text(x2[3],y2[1], stats_names_include[2] ,font=3,cex=0.8)	# write RMSE title
      text(x2[4],y2[1], stats_names_include[3] ,font=3,cex=0.8)                   # write NMB title
      text(x2[5],y2[1], stats_names_include[4] ,font=3,cex=0.8)                   # write NME title
      text(x2[6],y2[1], stats_names_include[5] ,font=3,cex=0.8)
      ##############################################
   }   

   ### Plot points and stats for each network ###
   for (i in 1:length(network_names)) {									# loop through each network
      point_color <- plot_colors[i]
           
      if (run_count == 1) { 
         points(sinfo[[i]]$plotval_obs,sinfo[[i]]$plotval_mod,pch=plot_chars[i],col=plot_colors[i],cex=1)	# plot points for each network
         text(x[1],y[i+2], network_label[i], cex=0.9)								# add network text to stats box
         text(x[2],y[i+2], sinfo[[i]]$stat1, cex=0.9)								# write network stat1
         text(x[3],y[i+2], sinfo[[i]]$stat2, cex=0.9)								# write network stat2
         text(x[4],y[i+2], sinfo[[i]]$stat3, cex=0.9)                          					# write network stat3
         text(x[5],y[i+2], sinfo[[i]]$stat4, cex=0.9)       	                    				# write netowrk stat4
         text(x[6],y[i+2], sinfo[[i]]$stat5, cex=0.9)								# write network stat5
      }
      else {
         points(sinfo2[[i]]$plotval_obs,sinfo2[[i]]$plotval_mod,pch=plot_chars[i],col=plot_colors[i],cex=1)	# plot points for each network
         text(x2[1],y2[i+2], network_label[i], cex=0.9)                                                   	# add network text to stats box for run 2
         text(x2[2],y2[i+2], sinfo2[[i]]$stat1, cex=0.9)                                             		# write network Index of Agreement for run 2
         text(x2[3],y2[i+2], sinfo2[[i]]$stat2, cex=0.9)                                                     	# write network NMB for run 2
         text(x2[4],y2[i+2], sinfo2[[i]]$stat3, cex=0.9)                                                     	# write network NME for run 2
         text(x2[5],y2[i+2], sinfo2[[i]]$stat4, cex=0.9)
         text(x2[6],y2[i+2], sinfo2[[i]]$stat5, cex=0.9)
      }
      {
         if (run_info_text == "y") {
            legend_names <- c(legend_names,paste(network_label[i]," (",run_name,")",sep=""))
         }
         else {
            legend_names <- c(legend_names,paste(network_label[i],sep=""))
         }
      }
      legend_cols  <- c(legend_cols,plot_colors[i])
      legend_chars <- c(legend_chars,plot_chars[i])
   }
   ##############################################
   run_count <- run_count+1
   run_name <- run_name2
}

### Put 1-to-1 lines and confidence lines on plot ###
abline(0,1)                                     # create 1-to-1 line
if (conf_line=="y") {
   abline(0,(1/1.5),col="black",lty=1)              # create lower bound 2-to-1 line
   abline(0,1.5,col="black",lty=1)                # create upper bound 2-to-1 line
} 

### Add descripitive text to plot area ###
if (run_info_text == "y") {
   if (rpo != "None") {
      text(x=axis.max,y=y[8], paste("RPO = ",rpo,sep=""),cex=1,adj=c(1,0))           # add RPO region to plot
   }
   if (state != "All") {
      text(x=axis.max,y=y[9], paste("State = ",state,sep=""),cex=1,adj=c(1,0))       # add State abbreviation to plot
   }
   if (site != "All") {
      text(x=x[4],y=y[9], paste("Site = ",site,sep=""),cex=1,adj=c(0.25,0.5))                     # add Site name to plot
   }
}
##########################################


#####################################################

### Put legend on the plot ###
{
   if (num_runs < 2) {
      legend("topleft", legend_names, pch=legend_chars,col=legend_cols, merge=F, cex=1.2, bty="n")
   }
   else {
      legend(0,y2[6], legend_names, pch=legend_chars,col=legend_cols, merge=F, cex=1, bty="n")
   }
}
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
