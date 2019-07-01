header <- "
##################### DAY OF WEEK BOX PLOT ######################
### AMET CODE: AQ_Boxplot_DofW.R
###
### This script is part of the AMET-AQ system.  It plots a box plot
### without whiskers.  The script is designed to create a box plot
### containing the days of the week.  Individual observation/model pairs are
### provided through a MYSQL query, from which the script computes the
### 25% and 75% quartiles, as well as the median values for both obs
### and model values.  The script then plots these values as a box plot.
###
### Last updated by Wyat Appel; June, 2017
###
################################################################
"

## get some environmental variables and setup some directories
ametbase	<- Sys.getenv("AMETBASE")        		# base directory of AMET
ametR		<- paste(ametbase,"/R_analysis_code",sep="")	# R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

network		<- network_names[1]

### Set file names and titles ###
filename_pdf <- paste(run_name1,species,pid,"boxplot_dow.pdf",sep="_")
filename_png <- paste(run_name1,species,pid,"boxplot_dow.png",sep="_")
filename_csv <- paste(run_name1,species,pid,"boxplot_data.csv",sep="_")      

## Create a full path to file
filename_pdf <- paste(figdir,filename_pdf,sep="/")
filename_png <- paste(figdir,filename_png,sep="/")
filename_csv <- paste(figdir,filename_csv,sep="/")

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(run_name1,species,"for",network_label[1],"for",dates,sep=" ") }
   else { title <- custom_title }
}
#################################

#################################
{
   if (Sys.getenv("AMET_DB") == 'F') {
      sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,species)
      data_exists      <- sitex_info$data_exists
      if (data_exists == "y") {
         aqdat_query.df   <- (sitex_info$sitex_data)
         aqdat_query.df   <- aqdat_query.df[with(aqdat_query.df,order(stat_id,ob_dates,ob_hour)),]
         units            <- as.character(sitex_info$units[[1]])
      }
   }
   else {
#      units          <- db_Query(units_qs,mysql)
      query_result    <- query_dbase(run_name1,network,species)
      aqdat_query.df  <- query_result[[1]]
      data_exists     <- query_result[[2]]
      if (data_exists == "y") { units <- query_result[[3]] }
   }
}
if (data_exists == "n") { stop("Stopping because data_exists flag is false. Likely no data found for query.") }

aqdat.df 	<- aqdat_query.df 

label <- paste(species,"(",units,")",sep=" ")

## test that the query worked
if (length(aqdat.df) == 0){
  ## error the queried returned nothing
  writeLines("ERROR: Check species/network pairing and Obs start and end dates")
  stop(paste("ERROR querying db: \n",qs))
}

week_days		<- weekdays(as.Date(aqdat.df$ob_dates))
aqdat.df$DayOfWeek	<- week_days
aqdat.df$DayOfWeek	<- ordered(aqdat.df$DayOfWeek, levels=c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"))

if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   query_result2        <- query_dbase(run_name2,network,species)
   aqdat2.df            <- query_result2[[1]]
   week_days		<- weekdays(as.Date(aqdat2.df$ob_dates))
   aqdat2.df$DayOfWeek	<- week_days
   aqdat2.df$DayOfWeek  <- ordered(aqdat2.df$DayOfWeek, levels=c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"))
}
#######################

ob_col_name <- paste(species,"_ob",sep="")
mod_col_name <- paste(species,"_mod",sep="")
### Find q1, median, q2 for each group of both species ###
q1.spec1 <- tapply(aqdat.df[[ob_col_name]], aqdat.df$DayOfWeek, quantile, 0.25, na.rm=T)	# Compute ob 25% quartile
q1.spec2 <- tapply(aqdat.df[[mod_col_name]], aqdat.df$DayOfWeek, quantile, 0.25, na.rm=T)	# Compute model 25% quartile
median.spec1 <- tapply(aqdat.df[[ob_col_name]], aqdat.df$DayOfWeek, median, na.rm=T)		# Compute ob median value
median.spec2 <- tapply(aqdat.df[[mod_col_name]], aqdat.df$DayOfWeek, median, na.rm=T)	# Compute model median value
q3.spec1 <- tapply(aqdat.df[[ob_col_name]], aqdat.df$DayOfWeek, quantile, 0.75, na.rm=T)	# Compute ob 75% quartile
q3.spec2 <- tapply(aqdat.df[[mod_col_name]], aqdat.df$DayOfWeek, quantile, 0.75, na.rm=T)	# Compute model 75% quartile
################################################

q1.spec3     <- NULL
median.spec3 <- NULL
q3.spec3     <- NULL

if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   q1.spec3     <- tapply(aqdat2.df[[mod_col_name]], aqdat2.df$DayOfWeek, quantile, 0.25, na.rm=T)	# Compute model 25% quartile
   median.spec3 <- tapply(aqdat2.df[[mod_col_name]], aqdat2.df$DayOfWeek, median, na.rm=T)		# Compute model median value
   q3.spec3     <- tapply(aqdat2.df[[mod_col_name]], aqdat2.df$DayOfWeek, quantile, 0.75, na.rm=T)	# Compute model 75% quartile
}

### Set up axes so that they will be big enough for both data species  that will be added ###
num.groups <- length(unique(aqdat.df$DayOfWeek))				# Count the number of sites used in each month
y.axis.min <- min(c(q1.spec1,q1.spec2))				# Set y-axis minimum values
if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   y.axis.min <- min(c(y.axis.min,q1.spec3))
}
y.axis.max.value <- max(c(q3.spec1, q3.spec2, q3.spec3))			# Determine y-axis maximum value
y.axis.max <- c(sum((y.axis.max.value * 0.2),y.axis.max.value))			# Add 30% of the y-axis maximum value to the y-axis maximum value
if (length(y_axis_max) > 0) {
      y.axis.max <- y_axis_max
}
if (length(y_axis_min) > 0) {
      y.axis.min <- y_axis_min
}
#############################################################################################

########## MAKE PRIOR BOXPLOT ALL U.S. ##########
### To get a new graphics window (linux systems), use X11() ###
pdf(filename_pdf, width=8, height=8)						# Set output device with options

legend_names <- c(network_label[1], run_name1)
legend_fill <- c("gray65", "gray45")
legend_colors <- c(1,"blue")
legend_type <- c(1,2)

par(mai=c(1,1,0.5,0.5))								# Set plot margins
boxplot(split(aqdat.df[[ob_col_name]], aqdat.df$DayOfWeek), range=0, border="transparent", col="gray65", ylim=c(y.axis.min, y.axis.max), xlab="Day of Week", ylab=label, cex.axis=0.9, cex.lab=1.3)	# Create boxplot

## Do the same thing for model values.  Use a different color for the background.
boxplot(split(aqdat.df[[mod_col_name]],aqdat.df$DayOfWeek), range=0, border="transparent", col="gray45", boxwex=0.6, add=T, cex.axis=0.9, cex.lab=1.3)	# Plot model values on existing plot

if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   boxplot(split(aqdat2.df[[mod_col_name]],aqdat2.df$DayOfWeek), range=0, border="transparent", col="gray25", boxwex=0.3, add=T, cex.axis=0.9, cex.lab=1.3)
   legend_names <- c(legend_names, run_name2)
   legend_fill <- c(legend_fill, "gray30")
   legend_colors <- c(legend_colors,"red")
   legend_type <- c(legend_type,2)
}

### Put title at top of boxplot ###
title(main=title)
###################################

### Place points, connected by lines, to denote where the medians are ###
x.loc <- 1:num.groups								# Set number of median points to plot
points(x.loc, median.spec1,pch=4)						# Plot median points
lines(x.loc, median.spec1)							# Connect median points with a line

### Run 1 Modeled Values ###								# As above, except for model values
x.loc <- 1:num.groups
points(x.loc, median.spec2, pch=2, col="blue")
lines(x.loc, median.spec2, lty=2, col="blue")

### Run 2 Modeled Values ###
if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   x.loc <- 1:num.groups 
   points(x.loc, median.spec3, pch=3, col="red")
   lines(x.loc, median.spec3, lty=2, col="red")
}
#########################################################################

{
   if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
      raw_data.df <- data.frame(Median_Obs=median.spec1,Median_Mod=median.spec2,Median_Mod2=median.spec3)
   }
   else {
      raw_data.df <- data.frame(Median_Obs=median.spec1,Median_Mod=median.spec2)
   }
}
write.table(raw_data.df,file=filename_csv,append=T,row.names=F,sep=",")                     # Write raw data to csv file

### Put legend on the plot ###
legend("topleft", legend_names, fill=legend_fill, lty=legend_type, col=legend_colors, merge=F, cex=1)
##############################

### Count number of samples per hour ###
nsamples.table <- table(aqdat.df$ob_hour)
#########################################

### Put text on plot ###
if (run_info_text == 'y') {
   text(x=6,y=y.axis.max,paste("RPO: ",rpo,sep=""),cex=1.2,adj=c(0,0))
   text(x=6,y=y.axis.max*0.97,paste("PCA: ",pca,sep=""),cex=1.2,adj=c(0,0))
   text(x=6,y=y.axis.max*0.94,paste("Site: ",site,sep=""),cex=1.2,adj=c(0,0))
   if (state != "All") {
      text(x=6,y=y.axis.max*0.91,paste("State: ",state,sep=""),cex=1.2,adj=c(0,0))
   }
}

########################

### Put number of samples above each hour ###
#text(x=1:24,y=apply(cbind(q3.spec1,q3.spec2),1,max)+((y.axis.max*0.1)*.35),labels=nsamples.table,cex=1.2)

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
