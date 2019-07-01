header <- "
########################### MDA8 BOX PLOT ###################################
### AMET Code: AQ_Boxplot_MDA8.R 
###
### THIS FILE CONTAINS CODE TO DRAW A CUSTOMIZED HOURLY BOXPLOT DISPLAY.  It
### draws side-by-side boxplots for the various groups, without median values.
### This particular code uses hourly data to create a diurnal average curve 
### showing the data trend throughout the course of a 24-hr period.  The
### code is specifically designed to use AQS ozone data to compute MDA8 values.
###
### Last updated by Wyat Appel: June, 2019
#############################################################################
"

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")        		# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

### Retrieve units label from database table ###
network <- network_names[1]
#units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
################################################

### Set file names and titles ###
filename_pdf <- paste(run_name1,species,pid,"boxplot_MDA8.pdf",sep="_")
filename_png <- paste(run_name1,species,pid,"boxplot_MDA8.png",sep="_")

## Create a full path to file
filename_pdf <- paste(figdir,filename_pdf,sep="/")
filename_png <- paste(figdir,filename_png,sep="/")

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(run_name1,"MDA8 Ozone for",dates,sep=" ") }
   else { title <- custom_title }
}

label <- "MDA8 Ozone (ppb)"
#################################
{
   if (Sys.getenv("AMET_DB") == 'F') {
      sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,species)
      aqdat_query.df   <- (sitex_info$sitex_data)
      aqdat_query.df   <- aqdat_query.df[with(aqdat_query.df,order(stat_id,ob_dates,ob_hour)),]
      units            <- as.character(sitex_info$units[[1]])
   }
   else {
#      units <- db_Query(units_qs,mysql)
      query_result    <- query_dbase(run_name1,network,species)
      aqdat_query.df  <- query_result[[1]]
      data_exists     <- query_result[[2]]
      if (data_exists == "y") { units <- query_result[[3]] }
   }
}
hr_avg_ob   <- NULL
hr_avg_mod  <- NULL
max_hour    <- NULL
max_avg_ob  <- NULL
max_avg_mod <- NULL
hour <- NULL
day  <- NULL
stat_id <- NULL

ob_col_name <- paste(species,"_ob",sep="")
mod_col_name <- paste(species,"_mod",sep="")
split_sites <- split(aqdat_query.df,aqdat_query.df$stat_id)
for (s in 1:length(split_sites)) {
   sub.df <- split_sites[[s]]
   for (i in 1:(length(sub.df$stat_id)-7)) {
      hr_avg_ob2 <- mean(c(sub.df[i,ob_col_name],sub.df[(i+1),ob_col_name],sub.df[(i+2),ob_col_name],sub.df[(i+3),ob_col_name],sub.df[(i+4),ob_col_name],sub.df[(i+5),ob_col_name],sub.df[(i+6),ob_col_name],sub.df[(i+7),ob_col_name]))
      hr_avg_ob <- c(hr_avg_ob,hr_avg_ob2) 
      hr_avg_mod2 <- mean(c(sub.df[i,mod_col_name],sub.df[(i+1),mod_col_name],sub.df[(i+2),mod_col_name],sub.df[(i+3),mod_col_name],sub.df[(i+4),mod_col_name],sub.df[(i+5),mod_col_name],sub.df[(i+6),mod_col_name],sub.df[(i+7),mod_col_name]))
      hr_avg_mod <- c(hr_avg_mod,hr_avg_mod2)
      hour <- c(hour,sub.df$ob_hour[i])
      day <- c(day,sub.df$ob_dates[i])
      stat_id <- c(stat_id,sub.df$stat_id[i])
   }
}

aqdat.df <- data.frame(ob_val=hr_avg_ob,mod_val=hr_avg_mod,hour=hour,day=day,stat_id=stat_id)

#######################

### Find q1, median, q2 for each group of both species ###
q1.spec1 <- tapply(aqdat.df$ob_val, aqdat.df$hour, quantile, 0.25, na.rm=T)    # Compute ob 25% quartile
q1.spec2 <- tapply(aqdat.df$mod_val, aqdat.df$hour, quantile, 0.25, na.rm=T)   # Compute model 25% quartile
median.spec1 <- tapply(aqdat.df$ob_val, aqdat.df$hour, median, na.rm=T)                # Compute ob median value
median.spec2 <- tapply(aqdat.df$mod_val, aqdat.df$hour, median, na.rm=T)       # Compute model median value
q3.spec1 <- tapply(aqdat.df$ob_val, aqdat.df$hour, quantile, 0.75, na.rm=T)    # Compute ob 75% quartile
q3.spec2 <- tapply(aqdat.df$mod_val, aqdat.df$hour, quantile, 0.75, na.rm=T)   # Compute model 75% quartile
################################################

### Set up axes so that they will be big enough for both data species  that will be added ###
num.groups <- length(unique(aqdat.df$hour))					# Count the number of sites used in each month
y.axis.min <- min(c(0,0))							# Set y-axis minimum values
y.axis.max.value <- max(c(q3.spec1, q3.spec2))					# Determine y-axis maximum value
y.axis.max <- c(sum((y.axis.max.value * 0.3),y.axis.max.value))			# Add 30% of the y-axis maximum value to the y-axis maximum value
#############################################################################################

########## MAKE PRIOR BOXPLOT ALL U.S. ##########
### To get a new graphics window (linux systems), use X11() ###
pdf(filename_pdf, width=8, height=8)						# Set output device with options

if (inc_ranges != "y") {
   plot_colors <- "transparent"
}
whisker_color <- "transparent"
if (inc_whiskers == 'y') {
   whisker_color <- plot_colors
}

par(mai=c(1,1,0.5,0.5), lab=c(12,10,10), mar=c(5,4,4,5))								# Set plot margins
boxplot(split(aqdat.df$ob_val, aqdat.df$hour), range=0, border=plot_colors[1], whiskcol=whisker_color[1], staplecol=whisker_color[1], col=plot_colors[1], ylim=c(y.axis.min, y.axis.max), xlab="Hour LST", ylab=label, cex.axis=1.3, cex.lab=1.3)	# Create boxplot

## Do the same thing for model values.  Use a different color for the background.
boxplot(split(aqdat.df$mod_val,aqdat.df$hour), range=0, border=plot_colors[2], whiskcol=whisker_color[2], staplecol=whisker_color[2],col=plot_colors[2], boxwex=0.5, add=T, cex.axis=1.3, cex.lab=1.3)	# Plot model values on existing plot

### Put title at top of boxplot ###
title(main=title, cex.main=0.8)
###################################

### Place points, connected by lines, to denote where the medians are ###
x.loc <- 1:num.groups								# Set number of median points to plot
points(x.loc, median.spec1,pch=plot_symbols[1],col=plot_colors2[1])						# Plot median points
lines(x.loc, median.spec1,col=plot_colors2[1])							# Connect median points with a line

### Second species ###								# As above, except for model values
x.loc <- 1:num.groups
points(x.loc, median.spec2, pch=plot_symbols[2], col=plot_colors2[2])
lines(x.loc, median.spec2, lty=2, col=plot_colors2[2])
#########################################################################

### Put legend on the plot ###
legend("topleft", c(network_label[1], "CMAQ"), pch=plot_symbols, fill =plot_colors, lty=c(1,2), col=plot_colors, merge=F,cex=1.2)
##############################

### Count number of samples per hour ###
nsamples.table <- table(aqdat.df$hour)
#########################################

### Put text on plot ###
#text(x=18,y=y.axis.max,paste("RPO: ",rpo,sep=""),cex=1.2,adj=c(0,0))
#text(x=18,y=y.axis.max*0.95,paste("PCA: ",pca,sep=""),cex=1.2,adj=c(0,0))
#if (state != "All") {
#   text(x=18,y=y.axis.max*0.85,paste("State: ",state,sep=""),cex=1.2,adj=c(0,0))
#}
#text(x=18,y=y.axis.max*0.90,paste("Site: ",site,sep=""),cex=1.2,adj=c(0,0))
########################

### Put text stating coverage limit used ###
if (averaging == "m") {
   text(topright,paste("Coverage Limit = ",coverage_limit,"%",sep=""),cex=0.75,adj=c(0,.5))
}
if (run_info_text == "y") {
   if (rpo != "None") {
      text(x.axis.max,y.axis.max*.93,paste("RPO = ",rpo,sep=""),adj=c(0.5,.5),cex=.9)
   }
   if (pca != "None") {
      text(x.axis.max,y.axis.max*.90,paste("PCA = ",pca,sep=""),adj=c(0.5,.5),cex=.9)
   }
   if (site != "All") {
      text(x.axis.max,y.axis.max*.87,paste("Site = ",site,sep=""),adj=c(0.5,.5),cex=.9)
   }
   if (state != "All") {
      text(x.axis.max,y.axis.max*.84,paste("State = ",state,sep=""),adj=c(0.5,.5),cex=.9)
   }
}
############################################

### Put number of samples above each hour ###
text(x=1:24,y=y.axis.min,labels=nsamples.table,cex=.75,srt=90)

### Convert pdf to png ###
dev.off()
if ((ametptype == "png") || (ametptype == "both")) {   
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_pdf," png:",filename_png,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}

##########################
