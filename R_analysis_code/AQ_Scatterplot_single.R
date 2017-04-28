################## MODEL SKILL SCATTER PLOT #################### 
### AMET CODE: R_Scatterplot_skill.R 
###
### This script is part of the AMET-AQ system.  This script creates
### a scatter plot for a single network that includes more statistics 
### than the multiple network scatter plot.  Although limited to a
### single network, multiple runs may be used.
###
### Last Updated by Wyat Appel: March, 2017
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

mysql <- list(login=root_login, passwd=root_pass, server=mysql_server, dbase=dbase, maxrec=maxrec)

### Set file names and titles ###
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(run_name1," ",species," for ",dates,sep="") }
   else { title <- custom_title }
}

filename_pdf <- paste(run_name1,species,pid,"scatterplot_single.pdf",sep="_")             # Set PDF filename
filename_png <- paste(run_name1,species,pid,"scatterplot_single.png",sep="_")             # Set PNG filename
filename_txt <- paste(run_name1,species,pid,"scatterplot_single.csv",sep="_")       # Set output file name


## Create a full path to file
filename_pdf <- paste(figdir,filename_pdf,sep="/")      # Set PDF filename
filename_png <- paste(figdir,filename_png,sep="/")      # Set PNG filenam
filename_txt <- paste(figdir,filename_txt,sep="/")      # Set output file name

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
### Define statistics arrays ###
################################
num_pairs	     <- NULL
corr                 <- NULL
index_agr            <- NULL
rmse                 <- NULL
rmse_sys             <- NULL
rmse_unsys           <- NULL
nmb                  <- NULL
nme                  <- NULL
nmdnb                <- NULL
nmdne                <- NULL
mean_obs	     <- NULL
mean_mod	     <- NULL
mb                   <- NULL
me                   <- NULL
median_obs	     <- NULL
median_mod	     <- NULL
med_bias             <- NULL
med_error            <- NULL
fb                   <- NULL
fe                   <- NULL
stats_array          <- NULL
stats_array_include  <- NULL
stats_names_include  <- NULL
max_diff		<- NULL
min_diff		<- NULL
###############################

### Retrieve units and model labels from database table ###
network <- network_names[1]
units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units <- db_Query(units_qs,mysql)
model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
model_name <- db_Query(model_name_qs,mysql)
if (length(units) == 0) {
   units <- ""
}
################################################

run_count <- 1
num_runs <- 1									# Set number of runs to 1
run_name[1] <- run_name1
if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   num_runs <- 2								# If so, set number of runs to 2
   run_name[2] <- run_name2
}
for (j in 1:num_runs) {
   criteria <- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")           # Set part of the MYSQL query
   check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name[j],"' and COLUMN_NAME = 'POCode';",sep="")
   query_table_info.df <-db_Query(check_POCode,mysql)
   {
      if (length(query_table_info.df$COLUMN_NAME) == 0) {        # Check to see if POCode column exists or not
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name[j]," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="") # Set the rest of the MYSQL query
         aqdat_query.df<-db_Query(qs,mysql)
         aqdat_query.df$POCode <- 1
      }
      else {
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name[j]," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="") # Set the rest of the MYSQL query
         aqdat_query.df<-db_Query(qs,mysql)
      }
   }
   aqdat_query.df<-db_Query(qs,mysql)							# Query the database and store in aqdat.df dataframe     
   aqdat_query.df$stat_id <- paste(aqdat_query.df$stat_id,aqdat_query.df$POCode,sep='')      # Create unique site using site ID and PO Code
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
      aqdat.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=round(aqdat_query.df[,9],5),Mod_Value=round(aqdat_query.df[,10],5),Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month,precip_ob=aqdat_query.df$precip_ob,precip_mod=aqdat_query.df$precip_mod)
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
      aqdat.df <- data.frame(Network=aqdat.df$network,Stat_ID=I(aqdat.df$stat_id),lat=aqdat.df$lat,lon=aqdat.df$lon,Obs_Value=round(aqdat.df[,9],5),Mod_Value=round(aqdat.df[,10],5),Month=aqdat.df$month,precip_ob=aqdat.df$precip_ob)      # Create dataframe of network values to be used to create a list
      aqdat_stats.df <- aqdat.df
   }
   sinfo[[j]]<-list(plotval_obs=aqdat.df$Obs_Value,plotval_mod=aqdat.df$Mod_Value)        # create of list of plot values and corresponding statistics 
   
   #########################################################
   #### Calculate statistics for each requested network ####
   #########################################################
   data_all.df <- data.frame(network=I(aqdat_stats.df$Network),stat_id=I(aqdat_stats.df$Stat_ID),lat=aqdat_stats.df$lat,lon=aqdat_stats.df$lon,ob_val=aqdat_stats.df$Obs_Value,mod_val=aqdat_stats.df$Mod_Value,precip_val=aqdat_stats.df$precip_ob)
   stats.df <-try(DomainStats(data_all.df))      # Compute stats using DomainStats function for entire domain
   num_pairs   		<- stats.df$NUM_OBS
   nmb[j]         	<- round(stats.df$Percent_Norm_Mean_Bias,1)
   nme[j]         	<- round(stats.df$Percent_Norm_Mean_Err,1)
   nmdnb[j]       	<- round(stats.df$Norm_Median_Bias,1)
   nmdne[j]       	<- round(stats.df$Norm_Median_Error,1)
   mean_obs[j]		<- round(stats.df$MEAN_OBS,2)
   mean_mod[j]		<- round(stats.df$MEAN_MODEL,2)
   mb[j]          	<- round(stats.df$Mean_Bias,2)
   me[j]          	<- round(stats.df$Mean_Err,2)
   median_obs[j]	<- round(stats.df$Median_obs,2)
   median_mod[j]	<- round(stats.df$Median_model,2)
   med_bias[j]    	<- round(stats.df$Median_Bias,2)
   med_error[j]   	<- round(stats.df$Median_Error,2)
   fb[j]          	<- round(stats.df$Frac_Bias,2)
   fe[j]          	<- round(stats.df$Frac_Err,2)
   corr[j]        	<- round(stats.df$Correlation,2)
   rmse[j]        	<- round(stats.df$RMSE,2)
   rmse_sys[j]    	<- round(stats.df$RMSE_systematic,2)
   rmse_unsys[j]  	<- round(stats.df$RMSE_unsystematic,2)
   index_agr[j]   	<- round(stats.df$Index_of_Agree,2)
   max_diff[j]          <- round(stats.df$Max_Diff,2)
   min_diff[j]		<- round(stats.df$Min_Diff,2)
   #########################################################
 
   ##############################
   ### Write Data to CSV File ###
   ##############################
   if (j == 1) {
      write.table(run_name1,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
      write.table(dates,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(aqdat_query.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
   }
   else {
      write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(run_name2,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(aqdat_query.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
   }
   ###############################
   count <- sum(is.na(aqdat.df$Obs_Value))						# count number of NAs in column
   len   <- length(aqdat.df$Obs_Value)
   if (count != len) {									# test to see if data is available, if so, compute axis.max
      axis.max <- max(c(axis.max,aqdat.df$Obs_Value,aqdat.df$Mod_Value))		# set axis limit from data obs and mod maximum
      axis.min <- axis.max * .033							# set axis minimum to look like 0 (weird R thing)
   }

   ### If user sets axis maximum, compute axis minimum ###
   if ((length(y_axis_max) > 0) || (length(x_axis_max) > 0)) {
      axis.max <- max(y_axis_max,x_axis_max)
      axis.min <- axis.max * 0.033
   }
   if ((length(y_axis_min) > 0) || (length(x_axis_min) > 0)) {
      axis.min <- min(y_axis_min,x_axis_min)
   }
}
#######################################################

for (k in 1:num_runs) {
   ##############################################
   ########## MAKE SCATTERPLOT: ALL US ##########
   ##############################################
   if (k == 1) {

      #### Define Stats box placement ####
      axis.length <- (axis.max - axis.min)
      label1 <- axis.max * 0.580
      right  <- axis.max                                        # define box rightside
      left   <- axis.max - (axis.length * 0.550)
      bottom <- axis.min
      top    <- axis.max - (axis.length * 0.820)
      x7 <- axis.max - (axis.length * 0.250)                    # define right justification for run name
      x6 <- axis.max - (axis.length * 0.040)                    # define right justification for NME
      x5 <- axis.max - (axis.length * 0.110)                    # define right justification for NMB
      x4 <- axis.max - (axis.length * 0.190)                    # define right justification for RMSEu
      x3 <- axis.max - (axis.length * 0.280)                    # define right justification for RMSEs
      x2 <- axis.max - (axis.length * 0.350)                    # define right justification for Index of Agreement
      x1 <- axis.max - (axis.length * 0.470)                    # define right justification for Network
      y1 <- axis.max - (axis.length * 0.890)                    # define y for labels
      y2 <- axis.max - (axis.length * 0.860)                    # define y for run name
      y3 <- axis.max - (axis.length * 0.920)                    # define y for network 1
      y4 <- axis.max - (axis.length * 0.950)                    # define y for network 2
      y5 <- axis.max - (axis.length * 0.980)                    # define y for network 3
      y6 <- axis.max - (axis.length * 0.640)                    # define y for species text
      y7 <- axis.max - (axis.length * 0.650)                    # define y for timescale (averaging)
      y8 <- axis.max - (axis.length * 0.740)
      y9 <- axis.max - (axis.length * 0.780)
      y10 <- axis.max - (axis.length * 0.820)
      x <- c(x1,x2,x3,x4,x5,x6,x7)                              		# set vector of x offsets
      y <- c(y1,y2,y3,y4,y5,y6,y7,y8,y9,y10)	# set vector of y offsets
      ######################################

      ### Preset values for plot characters and colors (these can be changed to user preference) ###
      plot_chars <- c(1,2,3,4)                                 	# set vector of plot characters
      ##############################################################################################
      pdf(file=filename_pdf,width=8,height=8)
      ### Plot and draw rectangle with stats ###
      par(mai=c(1,1,0.5,0.5),lab=c(8,8,7))
      plot(1,1,type="n", pch=2, col="red", ylim=c(axis.min, axis.max), xlim=c(axis.min, axis.max), xlab=paste("Observation (",units,")",sep=""), ylab=paste(model_name," (",units,")",sep=""), cex.axis=1.2, cex.lab=1.2)	# create plot axis and labels, but do not plot any points
      text(axis.max,y[7], aqdat.df$avg_text, cex=1.2,adj=c(1,0))
      ##########################################

      ### Put title at top of boxplot ###
      title(main=title,cex.main=1.1)
      ###################################
   }
   if (k == 2) {
         ### Preset values for plot characters and colors (these can be changed to user preference) ###
         plot_chars <- c(1,2,3,4)
         plot_colors  <- plot_colors2                          # set vector of plot colors
   }
   ### Plot points and stats for each network ###
   point_color <- plot_colors[1]
   points(sinfo[[k]]$plotval_obs,sinfo[[k]]$plotval_mod,pch=plot_chars[1],col=plot_colors[1],cex=1)  # plot points for each network
   legend_names <- c(legend_names,paste(network_label[1],species,"(",run_name[k],")",sep=" "))
   legend_cols  <- c(legend_cols,plot_colors[1])
   legend_chars <- c(legend_chars,plot_chars[1])
   if (k == 1) {
      x_stats <- NULL
      y_stats <- NULL
      x_stats[1] <- axis.max - (axis.length * 0.999)
      x_stats[2] <- axis.max - (axis.length * 0.780)
      x_stats[3] <- axis.max - (axis.length * 0.900)
      x_stats[4] <- axis.max - (axis.length * 0.680)
      x_stats[5] <- axis.max - (axis.length * 0.800)
      x_stats[6] <- axis.max - (axis.length * 0.580)
      x_stats[7] <- axis.max - (axis.length * 0.910)
      x_stats[8] <- axis.max - (axis.length * 0.690)
      y_stats[1] <- axis.max - (axis.length * 0.120)
      y_stats[2] <- axis.max - (axis.length * 0.150)
      y_stats[3] <- axis.max - (axis.length * 0.180)
      y_stats[4] <- axis.max - (axis.length * 0.210)
      y_stats[5] <- axis.max - (axis.length * 0.240)
      y_stats[6] <- axis.max - (axis.length * 0.270)
      y_stats[7] <- axis.max - (axis.length * 0.300)
      y_stats[8] <- axis.max - (axis.length * 0.330)
      y_stats[9] <- axis.max - (axis.length * 0.360)
      y_stats[10] <- axis.max - (axis.length * 0.390)
      y_stats[11] <- axis.max - (axis.length * 0.420)
      y_stats[12] <- axis.max - (axis.length * 0.450)
      y_stats[13] <- axis.max - (axis.length * 0.480)
      y_stats[14] <- axis.max - (axis.length * 0.080)
   }
   else {
      y_stats <- NULL
      x_stats <- NULL
      x_stats[1] <- axis.max - (axis.length * 0.430)
      x_stats[2] <- axis.max - (axis.length * 0.200)
      x_stats[3] <- axis.max - (axis.length * 0.330)
      x_stats[4] <- axis.max - (axis.length * 0.100)
      x_stats[5] <- axis.max - (axis.length * 0.230)
      x_stats[6] <- axis.max - (axis.length * 0.000)
      x_stats[7] <- axis.max - (axis.length * 0.340)
      x_stats[8] <- axis.max - (axis.length * 0.110)
      x_stats[9] <- axis.max - (axis.length * 0.220)
      y_stats[1] <- axis.max - (axis.length * 0.780)
      y_stats[2] <- axis.max - (axis.length * 0.810)
      y_stats[3] <- axis.max - (axis.length * 0.840)
      y_stats[4] <- axis.max - (axis.length * 0.870)
      y_stats[5] <- axis.max - (axis.length * 0.900)
      y_stats[6] <- axis.max - (axis.length * 0.930)
      y_stats[7] <- axis.max - (axis.length * 0.960)
      y_stats[8] <- axis.max - (axis.length * 0.990)
      y_stats[9] <- axis.max - (axis.length * 1.020)
      y_stats[15] <- axis.max - (axis.length * 0.690)
      y_stats[14] <- axis.max - (axis.length * 0.740)
      text(x=x_stats[9],y=y_stats[15],run_name[k],cex=1)
   }
   ##############################################
   text(x=x_stats[7],y=y_stats[14],paste("(",units,")",sep=""),adj=c(0,0),cex=.8)
   text(x=x_stats[1],y=y_stats[1],"RMSE ",adj=c(0,0),cex=.8)
#   text(x=x_stats[1],y=y_stats[2],"RMSEs ",adj=c(0,0),cex=.8)
#   text(x=x_stats[1],y=y_stats[3],"RMSEu ",adj=c(0,0),cex=.8)
   text(x=x_stats[1],y=y_stats[2],"MB ",adj=c(0,0),cex=.8)
   text(x=x_stats[1],y=y_stats[3],"ME ",adj=c(0,0),cex=.8)
   text(x=x_stats[1],y=y_stats[4],"MdnB ",adj=c(0,0),cex=.8)
   text(x=x_stats[1],y=y_stats[5],"MdnE ",adj=c(0,0),cex=.8)
   text(x=x_stats[1],y=y_stats[7],"MaxDiff ",adj=c(0,0),cex=.8)
#   text(x=x_stats[1],y=y_stats[9],"MinDiff ",adj=c(0,0),cex=.8)
   text(x=x_stats[1],y=y_stats[8],"Mean_O ",adj=c(0,0),cex=.8)
   text(x=x_stats[1],y=y_stats[9],"Mean_M ",adj=c(0,0),cex=.8)
   text(x=x_stats[1],y=y_stats[10], "Num_Ob",adj=c(0,0),cex=.8)
#   text(x=x_stats[1],y=y_stats[12],"Med_O ",adj=c(0,0),cex=.8)
#   text(x=x_stats[1],y=y_stats[13],"Med_M ",adj=c(0,0),cex=.8)
   text(x=x_stats[8],y=y_stats[14],paste("(%)",sep=""),adj=c(0,0),cex=.8)
   text(x=x_stats[2],y=y_stats[1],"IA ",adj=c(0,0),cex=.8)
   text(x=x_stats[2],y=y_stats[2],"NMB ",adj=c(0,0),cex=.8)
   text(x=x_stats[2],y=y_stats[3],"NME ",adj=c(0,0),cex=.8)
   text(x=x_stats[2],y=y_stats[4],"NMdnB ",adj=c(0,0),cex=.8)
   text(x=x_stats[2],y=y_stats[5],"NMdnE ",adj=c(0,0),cex=.8)
#   text(x=x_stats[2],y=y_stats[6],"FB ",adj=c(0,0),cex=.8)
#   text(x=x_stats[2],y=y_stats[7],"FE ",adj=c(0,0),cex=.8)
   text(x=x_stats[2],y=y_stats[7],"MinDiff ",adj=c(0,0),cex=.8)
   text(x=x_stats[2],y=y_stats[8],"Med_O ",adj=c(0,0),cex=.8)
   text(x=x_stats[2],y=y_stats[9],"Med_M ",adj=c(0,0),cex=.8)
#   text(x=x_stats[3],y=y_stats[1],"=",adj=c(0,0),cex=.8)
#   text(x=x_stats[3],y=y_stats[2],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[3],y=y_stats[1],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[3],y=y_stats[2],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[3],y=y_stats[3],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[3],y=y_stats[4],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[3],y=y_stats[5],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[3],y=y_stats[7],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[3],y=y_stats[8],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[3],y=y_stats[9],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[3],y=y_stats[10],"=",adj=c(0,0),cex=.8)
#   text(x=x_stats[3],y=y_stats[12],"=",adj=c(0,0),cex=.8)
#   text(x=x_stats[3],y=y_stats[12],"=",adj=c(0,0),cex=.8)
#   text(x=x_stats[3],y=y_stats[13],"=",adj=c(0,0),cex=.8)
#   text(x=x_stats[4],y=y_stats[1],"=",adj=c(0,0),cex=.8)
#   text(x=x_stats[4],y=y_stats[2],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[4],y=y_stats[1],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[4],y=y_stats[2],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[4],y=y_stats[3],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[4],y=y_stats[4],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[4],y=y_stats[5],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[4],y=y_stats[7],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[4],y=y_stats[8],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[4],y=y_stats[9],"=",adj=c(0,0),cex=.8)
   text(x=x_stats[5],y=y_stats[1],sprintf("%.2f",rmse[k]),adj=c(1,0),cex=.8)
#   text(x=x_stats[5],y=y_stats[2],sprintf("%.2f",rmse_sys[k]),adj=c(1,0),cex=.8)
#   text(x=x_stats[5],y=y_stats[3],sprintf("%.2f",rmse_unsys[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[5],y=y_stats[2],sprintf("%.2f",mb[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[5],y=y_stats[3],sprintf("%.2f",me[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[5],y=y_stats[4],sprintf("%.2f",med_bias[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[5],y=y_stats[5],sprintf("%.2f",med_error[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[5],y=y_stats[7],sprintf("%.2f",max_diff[k]),adj=c(1,0),cex=.8)
#   text(x=x_stats[5],y=y_stats[9],sprintf("%.2f",min_diff[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[5],y=y_stats[8],sprintf("%.2f",mean_obs[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[5],y=y_stats[9],sprintf("%.2f",mean_mod[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[5],y=y_stats[10],sprintf("%.0f",num_pairs[k]),adj=c(1,0),cex=.8)
#   text(x=x_stats[5],y=y_stats[12],sprintf("%.2f",median_obs[k]),adj=c(1,0),cex=.8)
#   text(x=x_stats[5],y=y_stats[13],sprintf("%.2f",median_mod[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[6],y=y_stats[1],sprintf("%.2f",index_agr[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[6],y=y_stats[2],sprintf("%.1f",nmb[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[6],y=y_stats[3],sprintf("%.1f",nme[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[6],y=y_stats[4],sprintf("%.1f",nmdnb[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[6],y=y_stats[5],sprintf("%.1f",nmdne[k]),adj=c(1,0),cex=.8)
#   text(x=x_stats[6],y=y_stats[6],sprintf("%.1f",fb[k]),adj=c(1,0),cex=.8)
#   text(x=x_stats[6],y=y_stats[7],sprintf("%.1f",fe[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[6],y=y_stats[7],sprintf("%.2f",min_diff[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[6],y=y_stats[8],sprintf("%.2f",median_obs[k]),adj=c(1,0),cex=.8)
   text(x=x_stats[6],y=y_stats[9],sprintf("%.2f",median_mod[k]),adj=c(1,0),cex=.8)
   #####################################################
}

### Add descripitive text to plot area ###
if (run_info_text == "y") {
   if (rpo != "None") {   
      text(x=axis.max,y=y[7], paste("RPO = ",rpo,sep=""),cex=1,adj=c(1,.5))		# add RPO region to plot
   }
   if (pca != "None") {
      text(x=axis.max,y=y[7], paste("PCA = ",pca,sep=""),cex=1,adj=c(1,0.5))	# add PCA region to plot
   }
   if (state != "All") {
      text(x=axis.max,y=y[7], paste("State = ",state,sep=""),cex=1,adj=c(1,.5))	# add State abbreviation to plot
   }
   if (site != "All") {
      text(x=axis.max,y=y[7], paste("Site = ",site,sep=""),cex=1,adj=c(1,.5))			# add Site name to plot
   }
}

##########################################

### Put 1-to-1 lines and confidence lines on plot ### 
abline(0,1)                                     # create 1-to-1 line
if (conf_line=="y") {
   abline(0,(1/1.5),col="black",lty=1)              # create lower bound 2-to-1 line
   abline(0,1.5,col="black",lty=1)                # create upper bound 2-to-1 line
}
#####################################################

### Put legend on the plot ###
legend("topleft", legend_names, pch=legend_chars,col=legend_cols, merge=F, cex=1, bty="n")
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
