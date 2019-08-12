header <- "
################################### BOX PLOT #######################################
### AMET CODE: AQ_Boxplot.R
###
### This script is part of the AMET-AQ system.  It plots a box plot without whiskers.
###  The script is designed to create a box plot with monthly boxes.  Individual 
### observation/model pairs are provided through a MYSQL query, from which the script 
### computes the 25% and 75% quartiles, as well as the median values for both obs
### and model values.  The script then plots these values as a box plot. Suggest using
### the new ggplot or plotly AMET box plots for better box plot graphics. 
###
### Last updated by Wyat Appel: June, 2019
#####################################################################################
"

## get some environmental variables and setup some directories
ametbase	<- Sys.getenv("AMETBASE")			# base directory of AMET
ametR		<- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

### Retrieve units label from database table ###
network <- network_names[1] 
#units_qs <- paste("SELECT ",species," from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
#units <- db_Query(units_qs,mysql) 
run2 <- "False"
run3 <- "False"
################################################

### Set file names and titles ###
network<-network_names[[1]]
filename_all_pdf	<- paste(run_name1,species,pid,"boxplot_all.pdf",sep="_")
filename_all_png	<- paste(run_name1,species,pid,"boxplot_all.png",sep="_")
filename_bias_pdf	<- paste(run_name1,species,pid,"boxplot_bias.pdf",sep="_")
filename_bias_png	<- paste(run_name1,species,pid,"boxplot_bias.png",sep="_")
filename_norm_bias_pdf  <- paste(run_name1,species,pid,"boxplot_norm_bias.pdf",sep="_")
filename_norm_bias_png  <- paste(run_name1,species,pid,"boxplot_norm_bias.png",sep="_")

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(run_name1,species,"for",network_label[1],"for",dates,sep=" ") }
   else { title <- custom_title }
}

## Create a full path to file
filename_all_pdf         <- paste(figdir,filename_all_pdf,sep="/")
filename_all_png         <- paste(figdir,filename_all_png,sep="/")
filename_bias_pdf        <- paste(figdir,filename_bias_pdf,sep="/")
filename_bias_png        <- paste(figdir,filename_bias_png,sep="/")
filename_norm_bias_pdf   <- paste(figdir,filename_norm_bias_pdf,sep="/")
filename_norm_bias_png   <- paste(figdir,filename_norm_bias_png,sep="/")
#################################

q1.bias2 	<- NULL
q1.bias3 	<- NULL
q3.bias2 	<- NULL
q3.bias3 	<- NULL
q1.norm_bias2   <- NULL
q1.norm_bias3   <- NULL
q2.norm_bias2	<- NULL
q2.norm_bias3 	<- NULL
q3.norm_bias2   <- NULL
q3.norm_bias3   <- NULL

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
#      units	      <- db_Query(units_qs,mysql)
      query_result    <- query_dbase(run_name1,network,species)
      aqdat_query.df  <- query_result[[1]]
      data_exists     <- query_result[[2]]
      if (data_exists == "y") { units <- query_result[[3]] }
   }
}
if (data_exists == "n") { stop("Stopping because data_exists flag is false. Likely no data found for query.") }

years   <- substr(aqdat_query.df$ob_dates,1,4)
months  <- substr(aqdat_query.df$ob_dates,6,7)
yearmonth <- paste(years,months,sep="_")
aqdat_query.df$Year <- years
aqdat_query.df$YearMonth <- yearmonth

if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   run2 <- "True"
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info       <- read_sitex(Sys.getenv("OUTDIR2"),network,run_name2,species)
         aqdat_query2.df   <- sitex_info$sitex_data
         aqdat_query2.df   <- aqdat_query2.df[with(aqdat_query2.df,order(stat_id,ob_dates,ob_hour)),]
      }
      else {
         query_result2    <- query_dbase(run_name2,network,species)
         aqdat_query2.df  <- query_result2[[1]]
      }
   }
   years2   <- substr(aqdat_query2.df$ob_dates,1,4)
   months2  <- substr(aqdat_query2.df$ob_dates,6,7)
   yearmonth2 <- paste(years2,months2,sep="_")
   aqdat_query2.df$Year <- years2
   aqdat_query2.df$YearMonth <- yearmonth2
}

if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
   run3 <- "True" 
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info        <- read_sitex(Sys.getenv("OUTDIR2"),network,run_name3,species)
         aqdat_query3.df   <- sitex_info$sitex_data
         aqdat_query3.df   <- aqdat_query3.df[with(aqdat_query3.df,order(stat_id,ob_dates,ob_hour)),]
      }
      else {
         query_result3    <- query_dbase(run_name3,network,species)
         aqdat_query3.df  <- query_result3[[1]]
      }
   }
   years3   <- substr(aqdat_query3.df$ob_dates,1,4)
   months3  <- substr(aqdat_query3.df$ob_dates,6,7)
   yearmonth3 <- paste(years3,months3,sep="_")
   aqdat_query3.df$Year <- years3
   aqdat_query3.df$YearMonth <- yearmonth3
}
total_days <- as.numeric(max(as.Date(aqdat_query.df$ob_datee))-min(as.Date(aqdat_query.df$ob_dates)))	# Calculate the total length, in days, of the period being plotted
x.axis.min <- min(aqdat_query.df$month)	# Find the first month available from the query
ob_col_name <- paste(species,"_ob",sep="")
mod_col_name <- paste(species,"_mod",sep="")
{
if ((total_days <= 31) && (averaging == "n")) {	# If only plotting one month, plot all times instead of averaging to a single month
   aqdat.df <- data.frame(network=aqdat_query.df$network,stat_id=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,ob_dates=aqdat_query.df$ob_dates,Obs_Value=aqdat_query.df[[ob_col_name]],Mod_Value=aqdat_query.df[[mod_col_name]],Month=aqdat_query.df$month,Split_On=aqdat_query.df$ob_dates)
if (run2 == "True") {
      aqdat2.df <- data.frame(network=aqdat_query2.df$network,stat_id=aqdat_query2.df$stat_id,lat=aqdat_query2.df$lat,lon=aqdat_query2.df$lon,ob_dates=aqdat_query2.df$ob_dates,Obs_Value=aqdat_query2.df[[ob_col_name]],Mod_Value=aqdat_query2.df[[mod_col_name]],Month=aqdat_query2.df$month,Split_On=aqdat_query2.df$ob_dates)
   }
   if (run3 == "True") {
      aqdat3.df <- data.frame(network=aqdat_query3.df$network,stat_id=aqdat_query3.df$stat_id,lat=aqdat_query3.df$lat,lon=aqdat_query3.df$lon,ob_dates=aqdat_query3.df$ob_dates,Obs_Value=aqdat_query3.df[[ob_col_name]],Mod_Value=aqdat_query3.df[[mod_col_name]],Month=aqdat_query3.df$month,Split_On=aqdat_query3.df$ob_dates)
   }
}
else {
   aqdat.df <- data.frame(network=aqdat_query.df$network,stat_id=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,ob_dates=aqdat_query.df$ob_dates,Obs_Value=aqdat_query.df[[ob_col_name]],Mod_Value=aqdat_query.df[[mod_col_name]],Month=aqdat_query.df$month,Split_On=aqdat_query.df$YearMonth)
   if (run2 == "True") {
      aqdat2.df <- data.frame(network=aqdat_query2.df$network,stat_id=aqdat_query2.df$stat_id,lat=aqdat_query2.df$lat,lon=aqdat_query2.df$lon,ob_dates=aqdat_query2.df$ob_dates,Obs_Value=aqdat_query2.df[[ob_col_name]],Mod_Value=aqdat_query2.df[[mod_col_name]],Month=aqdat_query2.df$month,Split_On=aqdat_query2.df$YearMonth)
   }
   if (run3 == "True") {
      aqdat3.df <- data.frame(network=aqdat_query3.df$network,stat_id=aqdat_query3.df$stat_id,lat=aqdat_query3.df$lat,lon=aqdat_query3.df$lon,ob_dates=aqdat_query3.df$ob_dates,Obs_Value=aqdat_query3.df[[ob_col_name]],Mod_Value=aqdat_query3.df[[mod_col_name]],Month=aqdat_query3.df$month,Split_On=aqdat_query3.df$YearMonth)
   }
}
}
Bias			<- aqdat.df$Mod_Value-aqdat.df$Obs_Value
Norm_Bias		<- ((aqdat.df$Mod_Value-aqdat.df$Obs_Value)/aqdat.df$Obs_Value)*100
aqdat.df$Bias		<- Bias
aqdat.df$Norm_Bias	<- Norm_Bias

if (run2 == "True") {
   Bias2                    <- aqdat2.df$Mod_Value-aqdat2.df$Obs_Value
   Norm_Bias2               <- ((aqdat2.df$Mod_Value-aqdat2.df$Obs_Value)/aqdat2.df$Obs_Value)*100
   aqdat2.df$Bias           <- Bias2
   aqdat2.df$Norm_Bias      <- Norm_Bias2
}
if (run3 == "True") {
   Bias3                    <- aqdat3.df$Mod_Value-aqdat3.df$Obs_Value
   Norm_Bias3               <- ((aqdat3.df$Mod_Value-aqdat3.df$Obs_Value)/aqdat3.df$Obs_Value)*100
   aqdat3.df$Bias           <- Bias3
   aqdat3.df$Norm_Bias      <- Norm_Bias3
}

######################

### Find q1, median, q2 for each group of both species ###
obs.stats	<- boxplot(split(aqdat.df$Obs_Value, aqdat.df$Split_On), plot=F)
mod.stats	<- boxplot(split(aqdat.df$Mod_Value, aqdat.df$Split_On), plot=F)
bias.stats	<- boxplot(split(aqdat.df$Bias, aqdat.df$Split_On), plot=F)
norm_bias.stats <- boxplot(split(aqdat.df$Norm_Bias, aqdat.df$Split_On), plot=F)

### Isolate the medians from the boxplot stats.
median.spec1		<- obs.stats$stats[3,]
median.spec2		<- mod.stats$stats[3,]
median.bias		<- bias.stats$stats[3,]
median.norm_bias	<- norm_bias.stats$stats[3,]

### Isolate the 3rd quartile (top of the boxplot's box).
q1.spec1	<- obs.stats$stats[2,]
q1.spec2	<- mod.stats$stats[2,]
q3.spec1	<- obs.stats$stats[4,]
q3.spec2	<- mod.stats$stats[4,]
q3.bias		<- bias.stats$stats[4,]
q1.bias		<- bias.stats$stats[2,]
q3.norm_bias	<- norm_bias.stats$stats[4,]
q1.norm_bias	<- norm_bias.stats$stats[2,]

bar_colors   <- c("gray65","gray45")
bar_width    <- c(0.8,0.5)


if (run2 == "True") {
   ### Find q1, median, q2 for each group of both species ###
   obs.stats2       <- boxplot(split(aqdat2.df$Obs_Value, aqdat2.df$Split_On), plot=F)
   mod.stats2       <- boxplot(split(aqdat2.df$Mod_Value, aqdat2.df$Split_On), plot=F)
   bias.stats2      <- boxplot(split(aqdat2.df$Bias, aqdat2.df$Split_On), plot=F)
   norm_bias.stats2 <- boxplot(split(aqdat2.df$Norm_Bias, aqdat2.df$Split_On), plot=F)

   ### Isolate the medians from the boxplot stats.
   median.spec1_2           <- obs.stats2$stats[3,]
   median.spec2_2           <- mod.stats2$stats[3,]
   median.bias2             <- bias.stats2$stats[3,]
   median.norm_bias2        <- norm_bias.stats2$stats[3,]

   ### Isolate the 3rd quartile (top of the boxplot's box).
   q3.spec1_2       <- obs.stats2$stats[4,]
   q3.spec2_2       <- mod.stats2$stats[4,]
   q3.bias2         <- bias.stats2$stats[4,]
   q1.bias2         <- bias.stats2$stats[2,]
   q3.norm_bias2    <- norm_bias.stats2$stats[4,]
   q1.norm_bias2    <- norm_bias.stats2$stats[2,]
   
   bar_colors   <- c("gray65","gray45","gray25")
   bar_width    <- c(0.8,0.5,0.2)
}

if (run3 == "True") {
   ### Find q1, median, q2 for each group of both species ###
   obs.stats3       <- boxplot(split(aqdat3.df$Obs_Value, aqdat3.df$Split_On), plot=F)
   mod.stats3       <- boxplot(split(aqdat3.df$Mod_Value, aqdat3.df$Split_On), plot=F)
   bias.stats3      <- boxplot(split(aqdat3.df$Bias, aqdat3.df$Split_On), plot=F)
   norm_bias.stats3 <- boxplot(split(aqdat3.df$Norm_Bias, aqdat3.df$Split_On), plot=F)

   ### Isolate the medians from the boxplot stats.
   median.spec1_3           <- obs.stats3$stats[3,]
   median.spec2_3           <- mod.stats3$stats[3,]
   median.bias3             <- bias.stats3$stats[3,]
   median.norm_bias3        <- norm_bias.stats3$stats[3,]

   ### Isolate the 3rd quartile (top of the boxplot's box).
   q3.spec1_3       <- obs.stats3$stats[4,]
   q3.spec2_3       <- mod.stats3$stats[4,]
   q3.bias3         <- bias.stats3$stats[4,]
   q1.bias3         <- bias.stats3$stats[2,]
   q3.norm_bias3    <- norm_bias.stats3$stats[4,]
   q1.norm_bias3    <- norm_bias.stats3$stats[2,]

   bar_colors   <- c("gray80","gray60","gray35","gray10")
   bar_width    <- c(0.8,0.6,0.3,0.1)
}

whisker_color <- "transparent"
if (inc_whiskers == 'y') {
   whisker_color <- plot_colors
}
box_ltype <- 0
bar_colors <- "transparent"
if (inc_ranges == 'y') {
   box_ltype <- 1
   bar_colors <- plot_colors
}
line_type <- c(1,2,3,4,5,6)

###################
### Set up axes ###
###################
num.groups <- length(unique(aqdat.df$Split_On))
#num.groups <- length(unique(aqdat.df$ob_dates))

x.axis.max <- num.groups-1
y.axis.min <- min(c(q1.spec1, q1.spec2))
if (length(y_axis_min) > 0) {
   y.axis.min <- y_axis_min
}  
y.axis.max.value <- max(c(q3.spec1, q3.spec2))				# Determine y-axis maximum
if (inc_whiskers == 'y') { 
   y.axis.min <- min(c(aqdat.df$Obs_Value,aqdat.df$Mod_Value))                              # Set y-axis minimum values
   y.axis.max.value <- max(c(aqdat.df$Obs_Value,aqdat.df$Mod_Value))                        # Determine y-axis maximum value
}
y.axis.max <- c(sum((y.axis.max.value * 0.25),y.axis.max.value))		# Set y-axis maximum based on value above (adjusted by 30%)
if (length(y_axis_max) > 0) { 					# Set user defined y axis limit
   y.axis.max <- y_axis_max						# Set y-axis max based on user input
}
bias.y.axis.min <- min(q1.bias,q1.bias2,q1.bias3)
bias.y.axis.max.value <- max(q3.bias,q3.bias2,q3.bias3)
if (inc_whiskers == 'y') {
   bias.y.axis.min <- min(Bias,Bias2,Bias3)                              # Set y-axis minimum values
   bias.y.axis.max.value <- max(Bias,Bias2,Bias3)                        # Determine y-axis maximum value
}
bias.y.axis.max <- bias.y.axis.max.value+((bias.y.axis.max.value-bias.y.axis.min)*0.25)

norm_bias.y.axis.min <- min(q1.norm_bias,q1.norm_bias2,q1.norm_bias3)
norm_bias.y.axis.max.value <- max(q3.norm_bias,q3.norm_bias2,q3.norm_bias3)
if (inc_whiskers == 'y') {
   norm_bias.y.axis.min <- min(Norm_Bias,Norm_Bias2,Norm_Bias3)                              # Set y-axis minimum values
   norm_bias.y.axis.max.value <- max(Norm_Bias,Norm_Bias2,Norm_Bias3)                        # Determine y-axis maximum value
}
norm_bias.y.axis.max <- norm_bias.y.axis.max.value+((norm_bias.y.axis.max.value-norm_bias.y.axis.min)*0.25)

###################

##########################################
####### MAKE BOXPLOT: Entire Domain ######
##########################################

if (inc_ranges != "y") {
   plot_colors <- "transparent"
}

pdf(file=filename_all_pdf, width=8, height=8)
par(mai=c(1,1,0.5,0.5),las=1)

legend_names  <- c(network_label[1], run_name1)
legend_fill   <- c(plot_colors[1],plot_colors[2])
legend_colors <- c(plot_colors2[1],plot_colors2[2])
legend_type   <- c(0,1,2,3,4)
label 	      <- paste(species," (",units,")",sep="")

### User option to remove boxes and only plot median lines ###
range <- y.axis.max - y.axis.min
boxplot(split(aqdat.df$Obs_Value, aqdat.df$Split_On), range=0, border=plot_colors[1], whiskcol=whisker_color[1], staplecol=whisker_color[1], col=plot_colors[1], boxwex=bar_width[1], ylim=c(y.axis.min-(0.05*range), y.axis.max), xlab="Months", ylab=label, cex.axis=1.0, cex.lab=1.3)
boxplot(split(aqdat.df$Mod_Value,aqdat.df$Split_On), range=0, border=plot_colors[2], whiskcol=whisker_color[2], staplecol=whisker_color[2], col=plot_colors[2], boxwex=bar_width[2], add=T, cex.axis=1.0, cex.lab=1.3)
if (run2 == "True") {
    boxplot(split(aqdat2.df$Mod_Value,aqdat2.df$Split_On), range=0, border=plot_colors[3], whiskcol=whisker_color[3], staplecol=whisker_color[3], col=plot_colors[3], boxwex=bar_width[3], add=T, cex.axis=1.0, cex.lab=1.3)
   legend_names <- c(legend_names, run_name2)
}
if (run3 == "True") {
    boxplot(split(aqdat3.df$Mod_Value,aqdat3.df$Split_On), range=0, border=plot_colors[4], whiskcol=whisker_color[4], staplecol=whisker_color[4], col=plot_colors[4], boxwex=bar_width[4], add=T, cex.axis=1.0, cex.lab=1.3)
   legend_names <- c(legend_names, run_name3)
}
###############################################################

### Put title at top of boxplot ###
title(main=title, cex.main=0.9)

### Count number of samples per month ###
nsamples.table <- obs.stats$n

num_months <- length(nsamples.table)

### Put number of samples above each month ###
range <- y.axis.max - y.axis.min
{
   if(length(nsamples.table) <= 36) {
      text(x=1:num_months,y=y.axis.min-(0.05*range),labels=nsamples.table,cex=0.75,adj=c(0.5,0.5),srt=90)
   }
   else {
      year_mark<-seq(13,num_months,by=12)       # Do not plot number of obs if plotting more than a year
      text(x=seq(7,num_months,by=12),y=y.axis.min,labels=unique(years))
      abline(v=year_mark,col="gray40",lty=1)
   }
}
###################################

### Place points, connected by lines, to denote where the medians are ###
x.loc <- 1:num.groups
points(x.loc, median.spec1, pch=plot_symbols[1], col=plot_colors2[1])						# Add points for obs median values
lines(x.loc, median.spec1, lty=line_type[1], col=plot_colors2[1])							# Connect median points with a line
x.loc <- 1:num.groups
points(x.loc, median.spec2, pch=plot_symbols[2], col=plot_colors2[2])					# Add points for model median values
lines(x.loc, median.spec2, lty=line_type[2], col=plot_colors2[2])					# Connect median points with a line

if (run2 == "True") {
   x.loc <- 1:num.groups
   points(x.loc, median.spec2_2, pch=plot_symbols[3], col=plot_colors2[3])                                  # Add points for model median values
   lines(x.loc, median.spec2_2, lty=line_type[3], col=plot_colors2[3])                                   # Connect median points with a line
}
if (run3 == "True") {
   x.loc <- 1:num.groups
   points(x.loc, median.spec2_3, pch=plot_symbols[4], col=plot_colors2[4])                                  # Add points for model median values
   lines(x.loc, median.spec2_3, lty=line_type[4], col=plot_colors2[4])                                   # Connect median points with a line
}


### Put legend on the plot ###
legend("topleft", legend_names, fill=plot_colors, pch=plot_symbols, lty=line_type, col=plot_colors2, merge=F, cex=1, bty="n")
##############################

### Put text stating coverage limit used ###
#if (averaging == "m") {
#   text("topright",paste("Coverage Limit = ",coverage_limit,"%",sep=""),cex=0.75,adj=c(0,.5))
#}
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

### Convert pdf format file to png format ###
dev.off()
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_all_pdf," png:",filename_all_png,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_all_pdf,sep="")
      system(remove_command)
   }
}
#############################################

###############################################
####### MAKE Bias BOXPLOT: Entire Domain ######
###############################################

legend_names <- c(run_name1)
plot_colors  <- plot_colors[-1]
plot_colors2 <- plot_colors2[-1]
plot_symbols <- plot_symbols[-1]

pdf(file=filename_bias_pdf, width=8, height=8)
par(mai=c(1,1,0.5,0.5),las=1)
label <- paste("Bias (",units,")",sep="")
### User option to remove boxes and only plot median lines ###
boxplot(split(aqdat.df$Bias, aqdat.df$Split_On), range=0, border=plot_colors[1], col=plot_colors[1], whiskcol=whisker_color[1], staplecol=whisker_color[1], boxwex=bar_width[1], ylim=c(bias.y.axis.min, bias.y.axis.max), xlab="Date", ylab=label, cex.axis=1.0, cex.lab=1.3)
if (run2 == "True") {
   boxplot(split(aqdat2.df$Bias, aqdat2.df$Split_On), range=0, border=plot_colors[2], col=plot_colors[2], whiskcol=whisker_color[2], staplecol=whisker_color[2], boxwex=bar_width[2], ylim=c(bias.y.axis.min, bias.y.axis.max), xlab="Date", ylab=label, cex.axis=1.0, cex.lab=1.3, add=T)
   legend_names <- c(legend_names, run_name2)
}
if (run3 == "True") {
   boxplot(split(aqdat3.df$Bias, aqdat3.df$Split_On), range=0, border=plot_colors[3], col=plot_colors[3], whiskcol=whisker_color[3], staplecol=whisker_color[3], boxwex=bar_width[3], ylim=c(bias.y.axis.min, bias.y.axis.max), xlab="Date", ylab=label, cex.axis=1.0, cex.lab=1.3, add=T)
   legend_names <- c(legend_names, run_name3)
}
###############################################################

### Put title at top of boxplot ###
title(main=title, cex.main=0.9)
###################################

### Place points, connected by lines, to denote where the medians are ###
x.loc <- 1:num.groups
points(x.loc, pch=plot_symbols[1], median.bias,col=plot_colors2[1])                                              # Add points for obs median values
lines(x.loc, median.bias, col=plot_colors2[1], lty=line_type[1])                                                      # Connect median points with a line
abline(h=0)

if (run2 == "True") {
   points(x.loc, pch=plot_symbols[2], median.bias2, col=plot_colors2[2])                                              # Add points for obs median values
   lines(x.loc, median.bias2, col=plot_colors2[2], lty=line_type[2]) 
}
if (run3 == "True") {
   points(x.loc, pch=plot_symbols[3], median.bias3, col=plot_colors2[3])                                              # Add points for obs median values
   lines(x.loc, median.bias3, col=plot_colors2[3], lty=line_type[3])
}

### Put legend on the plot ###
legend("topleft",legend_names,pch=plot_symbols,fill=plot_colors,lty=line_type,col=plot_colors2,merge=F,cex=1,bty="n")
##############################

### Put text stating coverage limit used ###
if (averaging == "m") {
   text(x.axis.min,y.axis.max*.96,paste("Coverage Limit = ",coverage_limit,"%",sep=""),cex=0.75,adj=c(0,.5))
}
if (run_info_text == "y") {
   if (rpo != "None") {
      text(x.axis.max,bias.y.axis.max*.93,paste("RPO = ",rpo,sep=""),adj=c(0.5,.5),cex=.75)
   }
   if (pca != "None") {
      text(x.axis.max,bias.y.axis.max*.90,paste("PCA = ",pca,sep=""),adj=c(0.5,.5),cex=.75)
   }
   if (site != "All") {
      text(x.axis.max,bias.y.axis.max*.87,paste("Site = ",site,sep=""),adj=c(0.5,.5),cex=.75)
   }
   if (state != "All") {
      text(x.axis.max,bias.y.axis.max*.84,paste("State = ",state,sep=""),adj=c(0.5,.5),cex=.75)
   }
}
############################################

### Count number of samples per month ###
nsamples.table <- obs.stats$n
#########################################

num_months <- length(nsamples.table)
### Put number of samples above each month ###
{
#   if ((inc_ranges == "y") && (total_days <= 731)) {
   if (length(nsamples.table) <= 36) {
#      text(x=1:num_months,y=apply(cbind(q3.bias),1,max)+((bias.y.axis.max-bias.y.axis.min)*0.02),labels=nsamples.table,cex=0.75)
      text(x=1:num_months,y=bias.y.axis.min,labels=nsamples.table,cex=0.75,adj=c(0.5,1),srt=90)
   }
   else {
      year_mark<-seq(13,num_months,by=12)       # Do not plot number of obs if plotting more than a year
      abline(v=year_mark,col="gray40",lty=1)
   }
}
##############################################

### Convert pdf format file to png format ###
dev.off()
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_bias_pdf," png:",filename_bias_png,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_bias_pdf,sep="")
      system(remove_command)
   }
}
#############################################

##########################################################
####### MAKE Normalized Bias BOXPLOT: Entire Domain ######
##########################################################
pdf(file=filename_norm_bias_pdf, width=8, height=8)
par(mai=c(1,1,0.5,0.5),las=1)
label <- "Normalized Bias (%)"
### User option to remove boxes and only plot median lines ###
boxplot(split(aqdat.df$Norm_Bias, aqdat.df$Split_On), range=0, border=plot_colors[1], col=plot_colors[1], whiskcol=whisker_color[1], staplecol=whisker_color[1], boxwex=bar_width[1], ylim=c(norm_bias.y.axis.min, norm_bias.y.axis.max), xlab="Date", ylab=label, cex.axis=0.8, cex.lab=1.3)
if (run2 == "True") {
   boxplot(split(aqdat2.df$Norm_Bias, aqdat2.df$Split_On), range=0, border=plot_colors[2], col=plot_colors[2], whiskcol=whisker_color[2], staplecol=whisker_color[2], boxwex=bar_width[2], ylim=c(norm_bias.y.axis.min, norm_bias.y.axis.max), xlab="Date", ylab=label, cex.axis=0.8, cex.lab=1.3, add=T)
}
if (run3 == "True") {
   boxplot(split(aqdat3.df$Norm_Bias, aqdat3.df$Split_On), range=0, border=plot_colors[3], col=plot_colors[3], whiskcol=whisker_color[3], staplecol=whisker_color[3], boxwex=bar_width[3], ylim=c(norm_bias.y.axis.min, norm_bias.y.axis.max), xlab="Date", ylab=label, cex.axis=0.8, cex.lab=1.3, add=T)
} 
###############################################################

### Put title at top of boxplot ###
title(main=title, cex.main=0.9)
###################################

### Place points, connected by lines, to denote where the medians are ###
x.loc <- 1:num.groups
points(x.loc, pch=plot_symbols[1], col=plot_colors2[1], median.norm_bias)                                              # Add points for obs median values
lines(x.loc, col=plot_colors2[1], lty=line_type[1], median.norm_bias)                                                      # Connect median points with a line
abline(h=0)

if (run2 == "True") {
   points(x.loc, pch=plot_symbols[2], median.norm_bias2, col=plot_colors2[2])                                              # Add points for obs median values
   lines(x.loc, median.norm_bias2, col=plot_colors2[2], lty=line_type[2])
}

if (run3 == "True") {
   points(x.loc, pch=plot_symbols[3], median.norm_bias3, col=plot_colors2[3])                                              # Add points for obs median values
   lines(x.loc, median.norm_bias3, col=plot_colors2[3], lty=line_type[3])
}

### Put legend on the plot ###
legend("topleft",legend_names,pch=plot_symbols,fill=plot_colors,lty=line_type,col=plot_colors2,merge=F,cex=1,bty="n")
##############################

### Put text stating coverage limit used ###
if (averaging == "m") {
   text(x.axis.min,y.axis.max*.96,paste("Coverage Limit = ",coverage_limit,"%",sep=""),cex=0.75,adj=c(0,.5))
}
if (run_info_text == "y") {
   if (rpo != "None") {
      text(x.axis.max,norm_bias.y.axis.max*.93,paste("RPO = ",rpo,sep=""),adj=c(0.5,.5),cex=.75)
   }
   if (pca != "None") {
      text(x.axis.max,norm_bias.y.axis.max*.90,paste("PCA = ",pca,sep=""),adj=c(0.5,.5),cex=.75)
   }
   if (site != "All") {
      text(x.axis.max,norm_bias.y.axis.max*.87,paste("Site = ",site,sep=""),adj=c(0.5,.5),cex=.75)
   }
   if (state != "All") {
      text(x.axis.max,norm_bias.y.axis.max*.84,paste("State = ",state,sep=""),adj=c(0.5,.5),cex=.75)
   }
}
############################################

### Count number of samples per month ###
nsamples.table <- obs.stats$n
#########################################

num_months <- length(nsamples.table)
### Put number of samples above each month ###
{
   if (length(nsamples.table) <= 36) {
      text(x=1:num_months,y=norm_bias.y.axis.min,labels=nsamples.table,cex=0.75,adj=c(0.5,1),srt=90)
   }
   else {
      year_mark<-seq(13,num_months,by=12)       # Do not plot number of obs if plotting more than a year
      abline(v=year_mark,col="gray40",lty=1)
   }
}
##############################################

### Convert pdf format file to png format ###
dev.off()
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_norm_bias_pdf," png:",filename_norm_bias_png,sep="")
   system(convert_command)
   
   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_norm_bias_pdf,sep="")
      system(remove_command)
   }
}
#############################################
