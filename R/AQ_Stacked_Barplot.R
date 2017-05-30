##################### STACKED BAR PLOT #########################
###
### The code is interactive with the AMET_AQ system developed by Wyat
### Appel.  Data are queried from the MYSQL database for the CSN or
### SEARCH networks.  Data are then averaged for SO4, NO3, NH4, EC, OC
### and PM2.5 for the model and ob values.  These averages are then
### plotted on a stacked bar plot, along with the percent of the total
### PM2.5 that each species comprises.
###
### Last updated by Wyat Appel; December 6, 2012
###
### Modified to work with combined MET/AQ mode, Alexis Zubrow (IE UNC) Nov, 2007
###
################################################################

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
if(!require(Hmisc)){stop("Required Package Hmisc was not loaded")}
   
mysql <- list(login=login, passwd=passwd, server=server, dbase=dbase, maxrec=maxrec)           # Set MYSQL login and query options

### Retrieve units and model labels from database table ###
model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
model_name <- db_Query(model_name_qs,mysql)
################################################

### Set filenames and titles ###
outname_pdf <- paste(run_name1,"PM2.5","stacked_barplot.pdf",sep="_")
outname_png <- paste(run_name1,"PM2.5","stacked_barplot.png",sep="_")
## Create a full path to file
outname_pdf <- paste(figdir,outname_pdf,sep="/")
outname_png <- paste(figdir,outname_png,sep="/")

plot_cols     <- NULL
network <- network_names[1]
num_runs <- 1
{
   if (use_median == "y") {
      method <- "Median"
   }
   else {
      method <- "Mean"
   }
}
{
   if (custom_title == "") { title <- paste(network," Stacked Barplot (",method,") for ",run_name1," for ",dates,sep="") }
   else { title <- custom_title }
}
################################

if (run_name2 != "empty") {
   num_runs <- 2
}

if (species == "") {	# Default to normal PM_TOT if species not selected
   species <- "PM_TOT"
}


correlation    <- NULL
correlation2   <- NULL
rmse           <- NULL
rmse2          <- NULL
rmse_sys       <- NULL
rmse_sys2      <- NULL
rmse_unsys     <- NULL
rmse_unsys2    <- NULL

query <- paste(" and s.stat_id=d.stat_id and d.ob_dates BETWEEN",start_date,"and",end_date,"and d.ob_datee BETWEEN",start_date,"and",end_date,"and ob_hour between",start_hour,"and",end_hour,add_query,sep=" ")
criteria <- paste(" WHERE d.SO4_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
qs <- paste("SELECT d.proj_code,d.network,d.stat_id,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.SO4_ob,d.SO4_mod,d.NO3_ob,d.NO3_mod,d.NH4_ob,d.NH4_mod,d.EC_ob,d.EC_mod,d.OC_ob,d.OC_mod,d.",species,"_ob,d.",species,"_mod,d.TC_ob,d.TC_mod from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")
aqdat_all.df <- db_Query(qs,mysql)

## test that the query worked
if (length(aqdat_all.df) == 0){
  ## error the queried returned nothing
  writeLines("ERROR: Check species/network pairing and Obs start and end dates")
  stop(paste("ERROR querying db: \n",qs))
}

if (num_runs > 1) {
   qs <- paste("SELECT d.proj_code,d.network,d.stat_id,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.SO4_ob,d.SO4_mod,d.NO3_ob,d.NO3_mod,d.NH4_ob,d.NH4_mod,d.EC_ob,d.EC_mod,d.OC_ob,d.OC_mod,d.",species,"_ob,d.",species,"_mod,d.TC_ob,d.TC_mod from ",run_name2," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")
   aqdat_all2.df <- db_Query(qs,mysql)
   ## test that the query worked
   if (length(aqdat_all2.df) == 0) {
      ## error the queried returned nothing
      writeLines("ERROR: Check species/network pairing and Obs start and end dates")
      stop(paste("ERROR querying db: \n",qs))
   }
}

##########################################################
### Average all data for a species into a single value ###
##########################################################
l <- 8                                                  # offset for first species ob value

aqdat_sub.df <- aqdat_all.df
len <- length(aqdat_sub.df)

while (l < len) {                                       # loop through each column
   indic.nonzero <- aqdat_sub.df[,l] >= 0               # determine missing data from ob column
   aqdat_sub.df <- aqdat_sub.df[indic.nonzero,]         # remove missing model/ob pairs from dataframe
   l <- l+1
}
num_sites <- length(unique(aqdat_sub.df$stat_id))
num_pairs <- length(aqdat_sub.df$stat_id)

data.df         <- aqdat_sub.df[8:len]
{
   if (use_median == "y") {
      medians.df        <- lapply(data.df,median)
   }
   else {
      medians.df   <- lapply(data.df,mean)
   }
}
TC_ob  <- medians.df$EC_ob+medians.df$OC_ob
TC_mod <- medians.df$EC_mod+medians.df$OC_mod
##############################################################

if (num_runs > 1) {
   l <- 8                                          # offset for first species ob value

   aqdat_sub2.df <- aqdat_all2.df
   len <- length(aqdat_sub2.df)
   while (l < len) {                                       # loop through each column
      indic.nonzero <- aqdat_sub2.df[,l] >= 0               # determine missing data from ob column
      aqdat_sub2.df <- aqdat_sub2.df[indic.nonzero,]         # remove missing model/ob pairs from dataframe
      l <- l+1
   }

   data2.df     <- aqdat_sub2.df[8:len]
   {
      if (use_median == "y") {
         medians2.df        <- lapply(data2.df,median)
      }
      else {
         medians2.df   <- lapply(data2.df,mean)
      }
   }
   num_sites_2 <- length(unique(aqdat_sub2.df$stat_id))
   num_pairs_2 <- length(aqdat_sub2.df$stat_id)
   TC_ob2  <- medians2.df$EC_ob+medians2.df$OC_ob
   TC_mod2 <- medians2.df$EC_mod+medians2.df$OC_mod
}

{
if (remove_other == "y") {
   ########################################################################################
   ### Calculate percent of total PM2.5 (without other category) each species comprises ###
   ########################################################################################
   other_ob_all      <- data.df[,11]-(data.df$SO4_ob+data.df$NO3_ob+data.df$NH4_ob+data.df$EC_ob+data.df$OC_ob)
   total_ob_no_other <- data[[11]]-other_ob_all
   total_ob        <- median(total_ob_no_other)

   SO4_ob_percent   <- round(medians.df$SO4_ob/(medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob)*100,1)
   NO3_ob_percent   <- round(medians.df$NO3_ob/(medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob)*100,1)
   NH4_ob_percent   <- round(medians.df$NH4_ob/(medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob)*100,1)
   EC_ob_percent    <- round(medians.df$EC_ob/(medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob)*100,1)
   OC_ob_percent    <- round(medians.df$OC_ob/(medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob)*100,1)
   TC_ob_percent    <- round(TC_ob/(medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob)*100,1)

   other_mod_all      <- data.df[,12]-(data.df$SO4_mod+data.df$NO3_mod+data.df$NH4_mod+data.df$EC_mod+data.df$OC_mod)
   total_mod_no_other <- data.df[,12]-other_mod_all
   total_mod          <- median(total_mod_no_other)

   SO4_mod_percent   <- round(medians.df$SO4_mod/(medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod)*100,1)
   NO3_mod_percent   <- round(medians.df$NO3_mod/(medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod)*100,1)
   NH4_mod_percent   <- round(medians.df$NH4_mod/(medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod)*100,1)
   EC_mod_percent    <- round(medians.df$EC_mod/(medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod)*100,1)
   OC_mod_percent    <- round(medians.df$OC_mod/(medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod)*100,1)
   TC_mod_percent    <- round(TC_mod/(medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod)*100,1)

   correlation	<- round(cor(total_mod_no_other, total_ob_no_other),2)
   rmse		<- round(sqrt(c(rmse, sum((total_mod_no_other - total_ob_no_other)^2)/length(total_ob_no_other))),2)
   ls_regress	<- lsfit(total_ob_no_other,total_mod_no_other)
   intercept	<- ls_regress$coefficients[1]
   X		<- ls_regress$coefficients[2]
   rmse_sys	<- round(sqrt(c(rmse_sys, sum(((intercept+X*total_ob_no_other) - total_ob_no_other)^2))/length(total_ob_no_other)),2)
   rmse_unsys	<- round(sqrt(c(rmse_unsys, sum((total_mod_no_other - (intercept+X*total_ob_no_other))^2)/length(total_ob_no_other))),2)
   index_agree	<- round(1-((sum((total_ob_no_other-total_mod_no_other)^2))/(sum((abs(total_mod_no_other-mean(total_ob_no_other))+abs(total_ob_no_other-mean(total_ob_no_other)))^2))),2)
   
   if (num_runs > 1) {
      other_mod_all2      <- data2.df[,12]-(data2.df$SO4_mod+data2.df$NO3_mod+data2.df$NH4_mod+data2.df$EC_mod+data2.df$OC_mod)
      total_mod_no_other2 <- data2.df[,12]-other_mod_all2
      total_mod2          <- median(total_mod_no_other2)     

      SO4_mod_percent2   <- round(medians2.df$SO4_mod/(medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod)*100,1)
      NO3_mod_percent2   <- round(medians2.df$NO3_mod/(medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod)*100,1)
      NH4_mod_percent2   <- round(medians2.df$NH4_mod/(medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod)*100,1)
      EC_mod_percent2    <- round(medians2.df$EC_mod/(medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod)*100,1)
      OC_mod_percent2    <- round(medians2.df$OC_mod/(medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod)*100,1)
      TC_mod_percent2    <- round(TC_mod2/(medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod)*100,1)

      correlation2 <- round(cor(total_mod_no_other2, total_ob_no_other),2) 
      rmse2        <- round(sqrt(c(rmse2, sum((total_mod_no_other2 - total_ob_no_other)^2)/length(total_ob_no_other))),2)
      ls_regress   <- lsfit(total_ob_no_other,total_mod_no_other2)
      intercept    <- ls_regress$coefficients[1]
      X            <- ls_regress$coefficients[2]
      rmse_sys2    <- round(sqrt(c(rmse_sys2, sum(((intercept+X*total_ob_no_other) - total_ob_no_other)^2))/length(total_ob_no_other)),2)
      rmse_unsys2  <- round(sqrt(c(rmse_unsys2, sum((total_mod_no_other2 - (intercept+X*total_ob_no_other))^2)/length(total_ob_no_other))),2)
      index_agree2 <- round(1-((sum((total_ob_no_other-total_mod_no_other2)^2))/(sum((abs(total_mod_no_other2-mean(total_ob_no_other))+abs(total_ob_no_other-mean(total_ob_no_other)))^2))),2)
   }
   ###############################################################
}
else {
   ###############################################################
   ### Calculate percent of total PM2.5 each species comprises ###
   ###############################################################
   other_ob      <- data.df[,11]-(data.df$SO4_ob+data.df$NO3_ob+data.df$NH4_ob+data.df$EC_ob+data.df$OC_ob)
#   other_ob          <- data[[11]]-(data[[1]]+data[[3]]+data[[5]]+data[[7]]+data[[9]])
   med_other_ob      <- median(other_ob)
   total_ob          <- data.df[,11]

   SO4_ob_percent   <- round(medians.df$SO4_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+med_other_ob)*100,1)
   NO3_ob_percent   <- round(medians.df$NO3_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+med_other_ob)*100,1)
   NH4_ob_percent   <- round(medians.df$NH4_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+med_other_ob)*100,1)
   EC_ob_percent    <- round(medians.df$EC_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+med_other_ob)*100,1)
   OC_ob_percent    <- round(medians.df$OC_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+med_other_ob)*100,1)
   TC_ob_percent    <- round(TC_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+med_other_ob)*100,1)
   Other_ob_percent <- round(med_other_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+med_other_ob)*100,1)

   other_mod      <- data.df[,11]-(data.df$SO4_mod+data.df$NO3_mod+data.df$NH4_mod+data.df$EC_mod+data.df$OC_mod)
   med_other_mod    <- median(other_mod)
   total_mod        <- data.df[,12]

   SO4_mod_percent   <- round(medians.df$SO4_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+med_other_mod)*100,1)
   NO3_mod_percent   <- round(medians.df$NO3_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+med_other_mod)*100,1)
   NH4_mod_percent   <- round(medians.df$NH4_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+med_other_mod)*100,1)
   EC_mod_percent    <- round(medians.df$EC_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+med_other_mod)*100,1)
   OC_mod_percent    <- round(medians.df$OC_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+med_other_mod)*100,1)
   TC_mod_percent    <- round(TC_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+med_other_mod)*100,1)
   Other_mod_percent <- round(med_other_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+med_other_mod)*100,1)

   correlation  <- round(cor(total_mod, total_ob),2)
   rmse 	<- round(sqrt(c(rmse, sum((data.df[,12] - data.df[,11])^2)/length(data.df[,11]))),2)
   ls_regress	<- lsfit(total_ob,total_mod)
   intercept	<- ls_regress$coefficients[1]
   X		<- ls_regress$coefficients[2]
   rmse_sys	<- round(sqrt(c(rmse_sys, sum(((intercept+X*total_ob) - total_ob)^2))/length(total_ob)),2)
   rmse_unsys	<- round(sqrt(c(rmse_unsys, sum((total_mod - (intercept+X*total_ob))^2)/length(total_ob))),2) 
   index_agree	<- round(1-((sum((data.df[,11]-data.df[,12])^2))/(sum((abs(data.df[,12]-mean(data.df[,11]))+abs(data.df[,11]-mean(data.df[,11])))^2))),2)

   if (num_runs > 1) {
      other_mod2         <- data2.df[,11]-(data2.df$SO4_mod+data2.df$NO3_mod+data2.df$NH4_mod+data2.df$EC_mod+data2.df$OC_mod)
      med_other_mod2    <- median(other_mod2)
      total_ob2         <- data2.df[,11]
      total_mod2        <- data2.df[,12]
   
      SO4_mod_percent2  <- round(medians2.df$SO4_mod/(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+med_other_mod2)*100,1)
      NO3_mod_percent2  <- round(medians2.df$NO3_mod/(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+med_other_mod2)*100,1)
      NH4_mod_percent2  <- round(medians2.df$NH4_mod/(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+med_other_mod2)*100,1)
      EC_mod_percent2   <- round(medians2.df$EC_mod/(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+med_other_mod2)*100,1)
      OC_mod_percent2   <- round(medians2.df$OC_mod/(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+med_other_mod2)*100,1)
      TC_mod_percent2   <- round(TC_mod2/(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+med_other_mod2)*100,1)
      Other_mod_percent2<- round(med_other_mod2/(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+med_other_mod2)*100,1)

      correlation2	<- round(cor(total_mod2, total_ob2),2)
      rmse2		<- round(sqrt(c(rmse2, sum((data2.df[,12] - data2.df[,11])^2)/length(data2.df[,11]))),2)
      ls_regress	<- lsfit(total_ob2,total_mod2)
      intercept		<- ls_regress$coefficients[1]
      X			<- ls_regress$coefficients[2]
      rmse_sys2		<- round(sqrt(c(rmse_sys2, sum(((intercept+X*total_ob2) - total_ob2)^2))/length(total_ob2)),2)
      rmse_unsys2	<- round(sqrt(c(rmse_unsys2, sum((total_mod2 - (intercept+X*total_ob2))^2)/length(total_ob2))),2)
      index_agree2	<- round(1-((sum((data2.df[,11]-data2.df[,12])^2))/(sum((abs(data2.df[,12]-mean(data2.df[,11]))+abs(data2.df[,11]-mean(data2.df[,11])))^2))),2)
   }
}
   ###############################################################
}

{
   if (remove_other == "y") {
      if (use_TC == "y") {
         data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,TC_ob,TC_mod),byrow=T,ncol=2)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
      }
      else {
         data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,medians.df$EC_ob,medians.df$EC_mod,medians.df$OC_ob,medians.df$OC_mod),byrow=T,ncol=2)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
      }
   }
   else {
      if (use_TC == "y") {
         data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,TC_ob,TC_mod,med_other_ob,med_other_mod),byrow=T,ncol=2)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
      }
      else {
         data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,medians.df$EC_ob,medians.df$EC_mod,medians.df$OC_ob,medians.df$OC_mod,med_other_ob,med_other_mod),byrow=T,ncol=2)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
      }
   }
}

if (num_runs > 1) {
   if (use_TC == 'y') {
      data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians2.df$SO4_mod,medians.df$SO4_ob,medians.df$SO4_mod,medians2.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians2.df$NO3_mod,TC_ob,TC_mod,TC_mod2,med_other_ob,med_other_mod,med_other_mod2),byrow=T,ncol=3)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
   }
   else {
      data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians2.df$SO4_mod,medians.df$SO4_ob,medians.df$SO4_mod,medians2.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians2.df$NO3_mod,medians.df$EC_ob,medians.df$EC_mod,medians2.df$EC_mod,medians.df$OC_ob,medians.df$OC_mod,medians2.df$OC_mod,med_other_ob,med_other_mod,med_other_mod2),byrow=T,ncol=3)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
   }
}

yaxis.max   <- round(max(c(sum(data_matrix[,1]),sum(data_matrix[,2]))),)+5								# find the max of the average values to set y-axis max 
if (length(y_axis_max) > 0) {
   yaxis.max <- y_axis_max
}

{
   if (num_runs > 1) {
      simulations <- paste("CSN,",run_name1,",",run_name2,sep="")
   }
   else {
      simulations <- paste("CSN,",run_name1,sep="")
   }
}

filename_txt <- paste(run_name1,"PM2.5","stacked_barplot.csv",sep="_")     # Set output file name
filename_txt <- paste(figdir,filename_txt, sep="/")  ## make full path
write.table(simulations,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
write.table("Observed, Modeled",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
{
   if (remove_other == "y") {
      if (use_TC == "y") {
         write.table(data_matrix,file=filename_txt,append=T,col.names=F,row.names=c("SO4","NO3","NH4","TC"),sep=",")
         species_names <- c("TC",expression(paste(NH[4]^"  +")),expression(paste(NO[3]^"  -")),expression(paste(SO[4]^"  2-")))
         plot_cols     <- c("yellow","red","orange","grey")
         plot_cols_leg <- c("grey","orange","red","yellow")
      }
      else {
         write.table(data_matrix,file=filename_txt,append=T,col.names=F,row.names=c("SO4","NO3","NH4","EC","OC"),sep=",")
         species_names <- c("OC","EC",expression(paste(NH[4]^"  +")),expression(paste(NO[3]^"  -")),expression(paste(SO[4]^"  2-")))
         plot_cols     <- c("yellow","red","orange","light blue","grey")
         plot_cols_leg <- c("grey","light blue","orange","red","yellow")
      }
   }
   else {
      if (use_TC == "y") {
         write.table(data_matrix,file=filename_txt,append=T,col.names=F,row.names=c("SO4","NO3","NH4","TC","OTHER"),sep=",")
         species_names <- c("Other","TC",expression(paste(NH[4]^"  +")),expression(paste(NO[3]^"  -")),expression(paste(SO[4]^"  2-")))
         plot_cols     <- c("yellow","red","orange","grey","brown4")
         plot_cols_leg <- c("brown4","grey","orange","red","yellow")
      }
      else {
         write.table(data_matrix,file=filename_txt,append=T,col.names=F,row.names=c("SO4","NO3","NH4","EC","OC","OTHER"),sep=",")
         species_names <- c("Other","OC","EC",expression(paste(NH[4]^"  +")),expression(paste(NO[3]^"  -")),expression(paste(SO[4]^"  2-")))
         plot_cols     <- c("yellow","red","orange","light blue","grey","brown4")
         plot_cols_leg <- c("brown4","grey","light blue","orange","red","yellow")
      }
   }
}

########## MAKE STACKED BARPLOT: ALL SITES ##########
pdf(file=outname_pdf,width=10,height=8)
par(mai=c(1,1,0.5,0.5))		# set margins

{
   if (num_runs == 1) {
      barplot(data_matrix, beside=FALSE, ylab="Concentration (ug/m3)",names.arg=c("CSN",model_name),width=0.5,xlim=c(0,2),ylim=c(0,yaxis.max),col=plot_cols,xpd=F,space=.6,cex.axis=1.4,cex.names=1.4,cex.lab=1.4)
      x1_adjust <- 1
      x2_adjust <- 1
   }
   else {
      barplot(data_matrix, beside=FALSE, ylab="Concentration (ug/m3)",names.arg=c("CSN",run_name1,run_name2),width=0.3,xlim=c(0,2),ylim=c(0,yaxis.max),col=plot_cols,xpd=F,space=.9,cex.axis=1.4,cex.names=1,cex.lab=1.4)
#      barplot(data_matrix, beside=FALSE, ylab="Concentration (ug/m3)",names.arg=c("CSN","SAPRC07","SAPRC99"),width=0.3,xlim=c(0,2),ylim=c(0,yaxis.max),col=plot_cols,xpd=F,space=.9,cex.axis=1.4,cex.names=1.2,cex.lab=1.4)
      x1_adjust <- .91
      x2_adjust <- .77
   }
}
legend("topright",species_names,fill=plot_cols_leg,cex=1.2)

x1 <- x1_adjust*.27
x2 <- x2_adjust*1.08
x3 <- 1.4

#########################################################################
### Add percentage values next to each specie on the stacked bar plot ###
#########################################################################
text(x1,(medians.df$SO4_ob/2),paste(SO4_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
text(x1,(medians.df$SO4_ob+(medians.df$NO3_ob/2)),paste(NO3_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+(medians.df$NH4_ob/2)),paste(NH4_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
{
   if (use_TC == "y") {
      text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+(TC_ob/2)),paste(TC_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
   }
   else {
      text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+(medians.df$EC_ob/2)),paste(EC_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
      text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+(medians.df$OC_ob/2)),paste(OC_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
   }
}
if (remove_other != "y") {
   text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+TC_ob+(med_other_ob/2)),paste(Other_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
}

text(x2,(medians.df$SO4_mod/2),paste(SO4_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
text(x2,(medians.df$SO4_mod+(medians.df$NO3_mod/2)),paste(NO3_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+(medians.df$NH4_mod/2)),paste(NH4_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
{
   if (use_TC == "y") {
      text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+(TC_mod/2)),paste(TC_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
   }
   else {
      text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+(medians.df$EC_mod/2)),paste(EC_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
      text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+(medians.df$OC_mod/2)),paste(OC_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))  
   }
}
if (remove_other != "y") {
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+TC_mod+(med_other_mod/2)),paste(Other_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
}

if (num_runs > 1) {
   text(x3,(medians2.df$SO4_mod/2),paste(SO4_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
   text(x3,(medians2.df$SO4_mod+(medians2.df$NO3_mod/2)),paste(NO3_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
   text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+(medians2.df$NH4_mod/2)),paste(NH4_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
   {
      if (use_TC == "y") {
         text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+(TC_mod/2)),paste(TC_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
      }
      else {
         text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+(medians2.df$EC_mod/2)),paste(EC_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
         text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+(medians2.df$OC_mod/2)),paste(OC_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
      }
   }
   if (remove_other != "y") {
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+TC_mod+(med_other_mod/2)),paste(Other_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0))
   }
}
##########################################################################

############################################################
### Add number of sites and number of obs counts to plot ###
############################################################
text(2.07,yaxis.max*.64,paste("# of sites: ",num_sites,sep=""),cex=1.2,adj=c(1,0))
text(2.07,yaxis.max*.60,paste("# of obs: ",num_pairs,sep=""),cex=1.2,adj=c(1,0))
if (run_info_text == "y") {
   if (rpo != "None") {
      text(2.07,yaxis.max*.55,paste("RPO: ",rpo,sep=""),cex=1,adj=c(1,0))
   }
   if (site != "All") {
      text(2.07,yaxis.max*.47,paste("Site: ",site,sep=""),cex=1,adj=c(1,0))
   }
   if (state != "All") {
      text(2.07,yaxis.max*.43,paste("State: ",state,sep=""),cex=1,adj=c(1,0))
   }
} 
############################################################

###################################
### Add statistics to plot area ###
###################################
text(2.07,yaxis.max*.38,run_name1,cex=1,adj=c(1,0))
text(2.07,yaxis.max*.35,paste("RMSE: ",rmse,sep=""),cex=1,adj=c(1,0))
text(2.07,yaxis.max*.32,paste("RMSEs: ",rmse_sys,sep=""),cex=1,adj=c(1,0))
text(2.07,yaxis.max*.29,paste("RMSEu: ",rmse_unsys,sep=""),cex=1,adj=c(1,0))
#text(2.07,yaxis.max*.26,paste("IA:   ",index_agree,sep=""),cex=1,adj=c(1,0))
text(2.07,yaxis.max*.26,paste("r:   ",correlation,sep=""),cex=1,adj=c(1,0))

if (num_runs > 1) {
   ### Add statistics to plot area ###
   text(2.07,yaxis.max*.16,run_name2,cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.13,paste("RMSE: ",rmse2,sep=""),cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.10,paste("RMSEs: ",rmse_sys2,sep=""),cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.07,paste("RMSEu: ",rmse_unsys2,sep=""),cex=1,adj=c(1,0))
#   text(2.07,yaxis.max*.04,paste("IA:   ",index_agree2,sep=""),cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.04,paste("r:   ",correlation2,sep=""),cex=1,adj=c(1,0))
}
######################################

## Put title at top of barplot ##
title(main=title,cex.main=1.3)

## Convert pdf to png ##
convert_command<-paste("convert -density 150x150 ",outname_pdf," png:",outname_png,sep="")
dev.off()
system(convert_command)
########################


