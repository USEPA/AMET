################################################################
### THIS FILE CONTAINS CODE TO DRAW A CUSTOMIZED PLOTS OF
### NMB, NME, CORRELATION, and FB, FE and RMSE.
### The script is ideally used with a long time period, specifically
### a year.  Average monthly domain-wide statistics are calculated 
### and plotted.  NMB, NME and CORRELATION are plotted together,
### while MdnB, MndE and RMSE are plotted together.  However, any
### one of the computed statistics can be plotted with a small
### change to the script.  The script works with multiple years as
### well.
###
### Last updated by Wyat Appel: June, 2017
################################################################

## get some environmental variables and setup some directories
ametbase	<- Sys.getenv("AMETBASE")			# base directory of AMET
ametR		<- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

################################################
### Retrieve units label from database table ###
################################################
network		<- network_names[1]
units_qs	<- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
units 		<- db_Query(units_qs,mysql)
model_name_qs 	<- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
model_name 	<- db_Query(model_name_qs,mysql)
model_name 	<- model_name[[1]]
if (length(units) == 0) {
 units <- ""
}
################################################

################################################
## Set output names and remove existing files ##
################################################
filename_stats	<- paste(run_name1,species,pid,"stats.csv",sep="_")
filename1_pdf	<- paste(run_name1,species,pid,"plot1.pdf",sep="_")
filename1_png	<- paste(run_name1,species,pid,"plot1.png",sep="_")
filename2_pdf	<- paste(run_name1,species,pid,"statsplot1.pdf",sep="_")
filename2_png	<- paste(run_name1,species,pid,"statsplot1.png",sep="_")
filename3_pdf	<- paste(run_name1,species,pid,"statsplot2.pdf",sep="_")
filename3_png	<- paste(run_name1,species,pid,"statsplot2.png",sep="_")

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { main.title <- paste(run_name1,species,"for",network_label[1],"for",dates,sep=" ") }
   else { main.title <- custom_title }
}

## Create a full path to file
filename_stats	<- paste(figdir,filename_stats,sep="/")
filename1_pdf   <- paste(figdir,filename1_pdf,sep="/")
filename1_png   <- paste(figdir,filename1_png,sep="/")
filename2_pdf   <- paste(figdir,filename2_pdf,sep="/")
filename2_png   <- paste(figdir,filename2_png,sep="/")
filename3_pdf   <- paste(figdir,filename3_pdf,sep="/")
filename3_png   <- paste(figdir,filename3_png,sep="/")

################################################

query_in		<- query
monthly_OBS		<- NULL
monthly_Mean_OBS	<- NULL
monthly_Mean_MOD	<- NULL
monthly_Mdn_OBS		<- NULL
monthly_Mdn_MOD		<- NULL
monthly_Sum_OBS		<- NULL
monthly_Sum_MOD		<- NULL
monthly_NMB		<- NULL
monthly_NME		<- NULL
monthly_NMdnB		<- NULL
monthly_NMdnE		<- NULL
monthly_CORR		<- NULL
monthly_FB		<- NULL
monthly_FE		<- NULL
monthly_MdnB		<- NULL
monthly_MdnE		<- NULL
monthly_RMSE		<- NULL
monthly_median		<- NULL
monthly_diff_median	<- NULL
y.axis.min		<- NULL
y.axis.max		<- NULL
right.axis.max		<- NULL
month_labels		<- NULL

network<-network_names[[1]]                                               # Set network name
network_name<-network_label[[1]]

#######################################
### Compute total number of  months ###
#######################################
start_month     <- month_start
end_month       <- month_end
num_years       <- (year_end-year_start)+1
years           <- seq(year_start,year_end,by=1)
months          <- NULL
##########################################

#########################################
### Compute statistics for each month ###
#########################################
s_month <- start_month
e_month <- end_month
i <- start_month 
for (y in 1:num_years) {
   year <- years[y]
   if (num_years > 1) {   
      if (y < num_years ) {
         e_month <- 12
      }
      if (y > 1) {
         s_month <- 1
      }
      if (y == num_years) {
         e_month <- end_month
      }
   }
       
#   for (m in 1:12) {
   for (m in s_month:e_month) {
   months <- c(months,i)   
   i <- i+1
   month_labels<-c(month_labels,m)
      ###########################################
      ####        Set Initial Values         ####
      ###########################################
      data_all.df				<- NULL
      stats_all.df				<- NULL
      stats_all.df$NUM_OBS			<- NA 
      stats_all.df$Percent_Norm_Mean_Bias	<- NA
      stats_all.df$Percent_Norm_Mean_Err	<- NA
      stats_all.df$Norm_Median_Bias		<- NA
      stats_all.df$Norm_Median_Error		<- NA
      stats_all.df$Correlation			<- NA
      stats_all.df$Frac_Bias			<- NA
      stats_all.df$Frac_Err			<- NA
      stats_all.df$Median_Bias			<- NA
      stats_all.df$Median_Error			<- NA
      stats_all.df$RMSE				<- NA
      ###########################################
      query			<- paste(query_in," and month = ",m,sep="")
      criteria 			<- paste(" WHERE d.",species,"_ob is not NULL and d.network='",network,"' ",query,sep="")	# Set part of the MYSQL query
      check_POCode		<- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name1,"' and COLUMN_NAME = 'POCode';",sep="")
      query_table_info.df	<-db_Query(check_POCode,mysql)
      {
         if (length(query_table_info.df$COLUMN_NAME) == 0) {        # Check to see if POCode column exists or not
            qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, precip_ob, precip_mod from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")      # Set the rest of the MYSQL query
            aqdat_query.df<-db_Query(qs,mysql)
            aqdat_query.df$POCode <- 1
         }
         else {
            qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.",species,"_ob,d.",species,"_mod, d.POCode, precip_ob from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")   # Set rest of the MYSQL criteria
            aqdat_query.df<-db_Query(qs,mysql)
         }
      }
      aqdat_query.df$stat_id <- paste(aqdat_query.df$stat_id,aqdat_query.df$POCode,sep="")
      ###################################################################################################################
      ### Create properly formated dataframe to be used with DomainStats function and compute stats for entire domain ###
      ###################################################################################################################
      if (length(aqdat_query.df$stat_id) > 0) {
         data_all.df <- data.frame(network=I(aqdat_query.df$network),stat_id=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,ob_val=aqdat_query.df[,9],mod_val=aqdat_query.df[,10],precip_val=aqdat_query.df$precip_ob)
         stats_all.df 	<- try(DomainStats(data_all.df))      # Compute stats using DomainStats function for entire domain
         indic.nonzero 	<- data_all.df$ob_val > 0
         data_stats.df 	<- data_all.df[indic.nonzero,]
         indic.nonzero 	<- data_stats.df$mod_val > 0
         data_stats.df 	<- data_stats.df[indic.nonzero,]
         mod_obs_diff 	<- data_stats.df$mod_val-data_stats.df$ob_val
      }
      monthly_OBS		<- c(monthly_OBS,stats_all.df$NUM_OBS)
      monthly_Mean_OBS		<- c(monthly_Mean_OBS, stats_all.df$MEAN_OBS)
      monthly_Mean_MOD		<- c(monthly_Mean_MOD, stats_all.df$MEAN_MOD)
      monthly_Mdn_OBS   	<- c(monthly_Mdn_OBS, stats_all.df$Median_obs)
      monthly_Mdn_MOD		<- c(monthly_Mdn_MOD, stats_all.df$Median_mod)
      monthly_Sum_OBS		<- c(monthly_Sum_OBS, stats_all.df$SUM_OBS)
      monthly_Sum_MOD		<- c(monthly_Sum_MOD, stats_all.df$SUM_MOD)
      monthly_NMB		<- c(monthly_NMB,stats_all.df$Percent_Norm_Mean_Bias)
      monthly_NME		<- c(monthly_NME,stats_all.df$Percent_Norm_Mean_Err)
      monthly_CORR		<- c(monthly_CORR,stats_all.df$Correlation)      
      monthly_FB		<- c(monthly_FB,stats_all.df$Frac_Bias)
      monthly_FE		<- c(monthly_FE,stats_all.df$Frac_Err)
      monthly_MdnB		<- c(monthly_MdnB,stats_all.df$Median_Bias)
      monthly_MdnE		<- c(monthly_MdnE,stats_all.df$Median_Error)
      monthly_NMdnB		<- c(monthly_NMdnB,stats_all.df$Norm_Median_Bias)
      monthly_NMdnE		<- c(monthly_NMdnE,stats_all.df$Norm_Median_Error)
      monthly_RMSE		<- c(monthly_RMSE,stats_all.df$RMSE)
      monthly_median		<- c(monthly_median, signif(stats_all.df$Median_Diff,3))
      monthly_diff_median	<- c(monthly_diff_median, signif(median(mod_obs_diff),3))
      ##################################
   }
}
num_months      <- length(months)
#####################################


###########################################
### Write Stats File with Monthly Stats ###
###########################################
all_stats.df <- data.frame(Month=months, Number_of_Obs = monthly_OBS, Mean_Obs=monthly_Mean_OBS, Mean_Mod=monthly_Mean_MOD, Sum_Obs=monthly_Sum_OBS, Sum_Mod=monthly_Sum_MOD, Percent_Normalized_Mean_Bias=monthly_NMB, Percent_Normalized_Mean_Error=monthly_NME, Correlation=monthly_CORR, Percent_Fractional_Bias=monthly_FB, Percent_Fractional_Error=monthly_FE, Median_Bias=monthly_MdnB, Median_Error=monthly_MdnE, Percent_Normalized_Median_Bias=monthly_NMdnB, Percent_Normalized_Median_Error=monthly_NMdnE, RMSE=monthly_RMSE, Median_Difference=monthly_median, Paired_Median_Difference=monthly_diff_median)

header <- c(paste("Run Name = ",run_name1,sep=""),paste("Evaluation Dates = ",dates,sep=""),paste("Species = ",species,sep=""),paste("State = ",state,sep=""),paste("Site Name = ",site,sep=""),paste("Network = ",network_name,sep=""),paste("Units = ",units,sep=""))
write.table(header, file=filename_stats, append=F, sep="," ,col.names=F, row.names=F)
write.table("",file=filename_stats, append=T, sep=",",col.names=F,row.names=F)
write.table(all_stats.df, file=filename_stats, append=T, sep=",",col.names=T,row.names=F)
###########################################

#########################
### Mean Obs/Mod Plot ###
#########################

### Set axis minimums and maximums ###
y.axis.min <- min(monthly_Mean_OBS,monthly_Mean_MOD)
y.axis.max <- max(monthly_Mean_OBS,monthly_Mean_MOD)
if ((units == "kg/ha") || (units == "mm") || (units == "cm")) {	# If plotting wet deposition, use sum instead of mean
   y.axis.max <- max(monthly_Sum_OBS,monthly_Sum_MOD)	
   y.axis.min <- min(monthly_Sum_OBS,monthly_Sum_MOD)
}
y.axis.max <- y.axis.max+((y.axis.max-y.axis.min)*0.20)	# Add 20% of the plot range on top to leave room for legend
y.axis.min <- y.axis.min-((y.axis.max-y.axis.min)*0.10)	# Add 10% of the plot range on bottom for number of obs
######################################

### Create empty plotting region with labels ###
pdf(file=filename1_pdf,width=10,height=8)
par(lab=c(12,10,10),mar=c(5,4,4,4))
plot(1,1,type='n',xlab="Months",ylab=paste(species," (",units,")",sep=""),xlim=c(1,num_months),ylim=c(y.axis.min,y.axis.max),las=1,cex.lab=1.3,cex.axis=1.2,col.axis="white")
usr <- par("usr")                               # set axis limits to usr
y_tickmarks <- axTicks(2)                       # find y tickmark locations using axTicks function
abline(h=y_tickmarks,col="grey85",lty=1)        # plot horizontal lines at each tickmark location
axis(side=1,at=seq(1:num_months),labels=month_labels,las=1,cex.axis=1)
axis(side=2,las=2,cex.axis=1.2)
######################################

### Add points and lines to the plot ###
par(new=T)
{
   if ((units == "kg/ha") || (units == "mm") || (units == "cm")) {	# Plot sum instead of mean if plotting wet deposition
      plot(months,monthly_Sum_OBS,type="b",pch=2,col="blue",xlab="",ylab="",ylim=c(y.axis.min,y.axis.max),axes=F,cex=1.3)
      par(new=T)
      plot(months,monthly_Sum_MOD,type="b",pch=4,col="red",ylim=c(y.axis.min,y.axis.max),xlab="",ylab="",axes=F,cex=1.3)
   }
   else {
      plot(months,monthly_Mean_OBS,type="b",pch=2,col="blue",xlab="",ylab="",ylim=c(y.axis.min,y.axis.max),axes=F,cex=1.3)
      par(new=T)
      plot(months,monthly_Mean_MOD,type="b",pch=4,col="red",ylim=c(y.axis.min,y.axis.max),xlab="",ylab="",axes=F,cex=1.3)
   }
}
######

### Add various text, legend and title to the plot ###
{
   if (length(months) <= 12) {	# If plotting multiple years, add vertical lines and year name to denote each year
      text(x=months,y=y.axis.min,labels=monthly_OBS)
   }
   else {
      text(x=seq(7,max(months),by=12),y=y.axis.min,labels=years)
      year_mark<-seq(13,max(months),by=12)
      abline(v=year_mark,col="gray40",lty=1)
   }
}
legend("topleft",c(network_name,model_name),pch=c(2,4),lty=c(1,1),col=c("blue","red"),bty="n",cex=1.3)
title(main=main.title,cex=1.5)
######

### Finish up ###
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density 150x150 ",filename1_pdf," png:",filename1_png,sep="")
   dev.off()
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename1_pdf,sep="")
      system(remove_command)
   }
}
########################

########################
### NMB/NME/COR Plot ###
########################

### Set axis minimums and maximums ###
y.axis.min <- min(monthly_NMB)
y.axis.max <- max(monthly_NMB, monthly_NME)
y.axis.max <- y.axis.max+((y.axis.max-y.axis.min)*0.20) # Add 20% of the plot range on top to leave room for legend
y.axis.min <- y.axis.min-((y.axis.max-y.axis.min)*0.10) # Add 10% of the plot range on bottom for number of obs
######

### Create empty plotting region with labels ###
pdf(file=filename2_pdf,width=10,height=8)
par(lab=c(12,10,10),mar=c(5,4,4,4))
plot(1,1,type='n',xlab="Months",ylab="NMB / NME (%)",xlim=c(1,num_months),ylim=c(y.axis.min,y.axis.max),las=1,cex.lab=1.3,cex.axis=1.2,col.axis="white")
usr <- par("usr")                               # set axis limits to usr
y_tickmarks <- axTicks(2)                       # find y tickmark locations using axTicks function
abline(h=y_tickmarks,col="grey85",lty=1)        # plot horizontal lines at each tickmark location
abline(h=0,col="black",lty=1)
axis(side=1,at=seq(1:num_months),labels=month_labels,las=1,cex.axis=1)
axis(side=2,las=2,cex.axis=1.2)
######

### Add points and lines to the plot ###
par(new=T)
plot(months,monthly_NMB,type="b",pch=2,col="blue",xlab="",ylab="",ylim=c(y.axis.min,y.axis.max),axes=F,cex=1.3)
par(new=T)
plot(months,monthly_NME,type="b",pch=4,col="red",ylim=c(y.axis.min,y.axis.max),xlab="",ylab="",axes=F,cex=1.3)
par(new=T)
plot(months,monthly_CORR,type="b",pch=5,col="green",ylim=c(0,1),xlab="",ylab="",axes=F,cex=1.3)
axis(side=4,at=c(seq(0,1,.1)),las=2,cex.axis=1.2)
mtext("Correlation (r)",side=4,adj=0.5,line=3,cex=1.5)
######

### Add various text, legend and title to the plot ###
{
   if (length(months) <= 12) {
      text(x=months,y=0.012,labels=monthly_OBS)
   }
   else {
      text(x=seq(7,max(months),by=12),y=0.012,labels=years)
      year_mark<-seq(13,max(months),by=12)
      abline(v=year_mark,col="gray40",lty=1)
   }
}
legend("topleft",c("Correlation","NMB","NME"),pch=c(5,2,4),lty=c(1,1,1),col=c("green","blue","red"),bty="n",cex=1.3)
title(main=main.title,cex=1.5)
#######################################################

### Finish Up ###
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density 150x150 ",filename2_pdf," png:",filename2_png,sep="")
   dev.off()
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename2_pdf,sep="")
      system(remove_command)
   }
}
########################

###########################
### MdnB/MdnE/RMSE Plot ###
###########################

### Set axis minimums and maximums ###
y.axis.min <- min(monthly_MdnB,monthly_MdnE,monthly_RMSE)
y.axis.max <- max(monthly_MdnB,monthly_MdnE,monthly_RMSE)
y.axis.max <- y.axis.max+((y.axis.max-abs(y.axis.min))*0.20) # Add 20% of the plot range on top to leave room for legend
y.axis.min <- y.axis.min-((y.axis.max-abs(y.axis.min))*0.10) # Add 10% of the plot range on bottom for number of obs
######

### Create empty plotting region with labels ###
pdf(file=filename3_pdf,width=10,height=8)
par(lab=c(12,10,10),mar=c(5,4,4,4))
plot(1,1,type='n',xlab="Months",ylab=paste("MdnB / MdnE / RMSE (",units,")",sep=""),xlim=c(1,num_months),ylim=c(y.axis.min,y.axis.max),las=1,cex.lab=1.3,cex.axis=1.2,col.axis="white")
usr <- par("usr")				# set axis limits to usr
y_tickmarks <- axTicks(2)			# find y tickmark locations using axTicks function
abline(h=y_tickmarks,col="grey85",lty=1)	# plot horizontal lines at each tickmark location
abline(h=0,col="black",lty=1)			# add black horizontal line at 0
axis(side=1,at=seq(1:num_months),labels=month_labels,las=1,cex.axis=1)
axis(side=2,las=2,cex.axis=1.2)
######

### Add points and lines to the plot ###
par(new=T)
plot(months,monthly_MdnB,type="b",pch=2,col="blue",xlab="",ylab="",ylim=c(y.axis.min,y.axis.max),axes=F,cex=1.3)
par(new=T)
plot(months,monthly_MdnE,type="b",pch=4,col="red",ylim=c(y.axis.min,y.axis.max),xlab="",ylab="",axes=F,cex=1.3)
par(new=T)
plot(months,monthly_RMSE,type="b",pch=5,col="green",ylim=c(y.axis.min,y.axis.max),xlab="",ylab="",axes=F,cex=1.3)
######

### Add various text, legend and title to the plot ###
{
   if (length(months) <= 12) {
      text(x=months,y=y.axis.min,labels=monthly_OBS)
   }
   else {
      text(x=seq(7,max(months),by=12),y=y.axis.min,labels=years)
      year_mark<-seq(13,max(months),by=12)
      abline(v=year_mark,col="gray40",lty=1)
   }
}
legend("topleft",c("RMSE","Median Bias","Median Error"),pch=c(5,2,4),lty=c(1,1,1),col=c("green","blue","red"),bty="n",cex=1.3)
title(main=main.title,cex=1.5)
######

### Finish Up ###
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density 150x150 ",filename3_pdf," png:",filename3_png,sep="")
   dev.off()
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename3_pdf,sep="")
      system(remove_command)
   }
}

########################
