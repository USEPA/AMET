################################################################
### THIS FILE CONTAINS CODE TO DRAW A CUSTOMIZED "STACKED BAR PLOT".
### The code is interactive with the AMET_AQ system developed by
### Wyat Appel.  Data are queried from the MYSQL database for the STN
### network.  Data are then averaged for SO4, NO3, NH4, EC, OC and PM2.5
### for the model and ob values.  These averages are then plotted on
### a stacked bar plot, along with the percent of the total PM2.5
### that each specie comprises.
###
### Last updated by Wyat Appel: June, 2017 
################################################################

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

network <- network_names[1]
network_name <- network_label[1]
num_runs <- 1

### Retrieve units and model labels from database table ###
model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
model_name <- db_Query(model_name_qs,mysql)
################################################

### Set filenames and titles ###
filename_pdf    <- paste(run_name1,pid,"stacked_barplot_AE6.pdf",sep="_")
filename_png    <- paste(run_name1,pid,"stacked_barplot_AE6.png",sep="_")
filename_txt	<- paste(run_name1,pid,"stacked_barplot_AE6_data.csv",sep="_")

## Create a full path to file
filename_pdf <- paste(figdir,filename_pdf,sep="/")      # Set PDF filename
filename_png <- paste(figdir,filename_png,sep="/")      # Set PNG filenam
filename_txt <- paste(figdir,filename_txt,sep="/")      # Set output file name

method <- "Mean"
if (use_median == "y") {
   method <- "Median"
}

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(network_name," Stacked Barplot (",method,") for ",run_name1," for ",dates,sep="") }
   else { title <- custom_title }
}
################################

if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   num_runs <- 2
}

medians          <- NULL
data.df          <- NULL
medians_2        <- NULL
data2.df         <- NULL
drop_names     <- NULL
species_names  <- NULL
species_names2 <- NULL
correlation    <- NULL
correlation2   <- NULL
rmse           <- NULL
rmse2          <- NULL
rmse_sys       <- NULL
rmse_sys2      <- NULL
rmse_unsys     <- NULL
rmse_unsys2    <- NULL

criteria <- paste(" WHERE d.SO4_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
qs <- paste("SELECT d.proj_code,d.network,d.stat_id,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.SO4_ob,d.SO4_mod,d.NO3_ob,d.NO3_mod,d.NH4_ob,d.NH4_mod,d.PM_TOT_ob,d.PM_TOT_mod,d.PM_FRM_ob,PM_FRM_mod,d.EC_ob,d.EC_mod,d.OC_ob,d.OC_mod,d.TC_ob,d.TC_mod,d.soil_ob,d.soil_mod,d.ncom_mod,d.NaCl_ob,d.NaCl_mod,d.other_ob,d.other_mod,d.other_rem_mod from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")
aqdat_all.df <- db_Query(qs,mysql)

### Calculate NH4 from NO3 and SO4 if unavailable ###
aqdat_all.df$NH4_ob[aqdat_all.df$NH4 == -999] <- 0.2903*aqdat_all.df$NO3_ob+0.375*aqdat_all.df$SO4_ob
aqdat_all.df$other_ob[aqdat_all.df$other_ob == -999] <- aqdat_all.df$PM_TOT_ob-aqdat_all.df$SO4_ob-aqdat_all.df$NO3_ob-(0.2903*aqdat_all.df$NO3_ob+0.375*aqdat_all.df$SO4_ob)-aqdat_all.df$OC_ob-aqdat_all.df$EC_ob-aqdat_all.df$NaCl_ob-aqdat_all.df$soil_ob


aqdat_store.df <- aqdat_all.df

if (num_runs > 1) {
   qs <- paste("SELECT d.proj_code,d.network,d.stat_id,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.SO4_ob,d.SO4_mod,d.NO3_ob,d.NO3_mod,d.NH4_ob,d.NH4_mod,d.PM_TOT_ob,d.PM_TOT_mod,d.PM_FRM_ob,PM_FRM_mod,d.EC_ob,d.EC_mod,d.OC_ob,d.OC_mod,d.TC_ob,d.TC_mod,d.soil_ob,d.soil_mod,d.ncom_mod,d.NaCl_ob,d.NaCl_mod,d.other_ob,d.other_mod,d.other_rem_mod from ",run_name2," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")
   aqdat_all2.df <- db_Query(qs,mysql)
   aqdat_all2.df$NH4_ob[aqdat_all2.df$NH4 == -999] <- 0.2903*aqdat_all2.df$NO3_ob+0.375*aqdat_all2.df$SO4_ob
   aqdat_all2.df$other_ob[aqdat_all2.df$other_ob == -999] <- aqdat_all2.df$PM_TOT_ob-aqdat_all2.df$SO4_ob-aqdat_all2.df$NO3_ob-(0.2903*aqdat_all2.df$NO3_ob+0.375*aqdat_all2.df$SO4_ob)-aqdat_all2.df$OC_ob-aqdat_all2.df$EC_ob-aqdat_all2.df$NaCl_ob-aqdat_all2.df$soil_ob
}

blank_mod  <- 0.4
blank_mod2 <- 0.4
blank_ob   <- 0.4
blank_ob2  <- 0.4
if (network == 'IMPROVE') {
   aqdat_all.df$PM_FRM_ob <- aqdat_all.df$PM_TOT_ob
   aqdat_all.df$PM_FRM_mod <- aqdat_all.df$PM_TOT_mod
   blank_mod  <- 0
   blank_ob   <- 0   
}
if ((network == 'IMPROVE') && (num_runs > 1)) {
   aqdat_all2.df$PM_FRM_ob <- aqdat_all2.df$PM_TOT_ob
   aqdat_all2.df$PM_FRM_mod <- aqdat_all2.df$PM_TOT_mod
   blank_ob2  <- 0
   blank_mod2 <- 0
}


##########################################################
### Average all data for a species into a single value ###
##########################################################
l <- 8							# offset for first species ob value

aqdat_sub.df <- aqdat_all.df
len <- length(aqdat_sub.df)

while (l < len) { 					# loop through each column
   indic.nonzero <- aqdat_sub.df[,l] >= 0		# determine missing data from ob column
   aqdat_sub.df <- aqdat_sub.df[indic.nonzero,]		# remove missing model/ob pairs from dataframe
   l <- l+1
}  

num_sites	<- length(unique(aqdat_sub.df$stat_id))
num_pairs	<- length(aqdat_sub.df$stat_id)   
 
data.df		<- aqdat_sub.df[8:len]
{
   if (use_median == "y") {
      medians.df        <- lapply(data.df,median)
   }
   else {
      medians.df   <- lapply(data.df,mean)
   }
}
##############################################################
if (num_runs > 1) {
   l <- 8                                          # offset for first specie ob value

   aqdat_sub2.df <- aqdat_all2.df
   len <- length(aqdat_sub2.df)

   while (l < len) {                                       # loop through each column
      indic.nonzero <- aqdat_sub2.df[,l] >= 0               # determine missing data from ob column
      aqdat_sub2.df <- aqdat_sub2.df[indic.nonzero,]         # remove missing model/ob pairs from dataframe
      l <- l+1
   }  

   data2.df	<- aqdat_sub2.df[8:len]
   {
      if (use_median == "y") {
         medians2.df        <- lapply(data2.df,median)
      }
      else {
         medians2.df   <- lapply(data2.df,mean)
      }
   }
 
   num_sites_2	<- length(unique(aqdat_sub2.df$stat_id)) 
   num_pairs_2	<- length(aqdat_sub2.df$stat_id)
}

##############################################################

########################################################################################
### Calculate percent of total PM2.5 (without other category) each species comprises ###
########################################################################################
   water_ob             <- 0.24*(medians.df$SO4_ob+medians.df$NH4_ob)
   NCOM_ob              <- 0.8*medians.df$OC_ob
   other_ob             <- medians.df$other_ob-(water_ob+blank_ob+NCOM_ob)
   if (other_ob < 0) {
      other_ob <- 0
   }
   other_mod            <- medians.df$other_rem_mod
   medians_tot_ob       <- medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$TC_ob+medians.df$soil_ob+medians.df$NaCl_ob+NCOM_ob+other_ob+blank_ob+water_ob
   medians_tot_mod      <- medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$TC_mod+medians.df$soil_mod+medians.df$NaCl_mod+medians.df$ncom_mod+other_mod+blank_mod
   total_ob            <- data.df$SO4_ob+data.df$NO3_ob+data.df$NH4_ob+data.df$TC_ob+data.df$soil_ob+data.df$NaCl_ob+data.df$other_ob+water_ob+NCOM_ob
   total_mod           <- data.df$SO4_mod+data.df$NO3_mod+data.df$NH4_mod+data.df$TC_mod+data.df$soil_mod+data.df$NaCl_mod+data.df$ncom_mod+data.df$other_rem_mod+blank_mod
   if (inc_FRM_adj == 'y') {
      FRM_adj                <- data.df$PM_FRM_mod-data.df$PM_TOT_mod
      if (FRM_adj < 0) {
         FRM_adj <- 0
      }
      FRM_adj_median         <- medians.df$PM_FRM_mod-medians.df$PM_TOT_mod
      if (FRM_adj_median < 0) {
         FRM_adj_median <- 0
      }
      total_mod		     <- data.df$SO4_mod+data.df$NO3_mod+data.df$NH4_mod+data.df$TC_mod+data.df$soil_mod+data.df$NaCl_mod+data.df$ncom_mod+blank_mod+data.df$other_rem_mod+FRM_adj
      medians_tot_mod	     <- medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$TC_mod+medians.df$soil_mod+medians.df$NaCl_mod+medians.df$ncom_mod+other_mod+blank_mod+FRM_adj_median
   }

   SO4_ob_percent	<- round(medians.df$SO4_ob/(medians_tot_ob)*100,1)
   NO3_ob_percent	<- round(medians.df$NO3_ob/(medians_tot_ob)*100,1)
   NH4_ob_percent	<- round(medians.df$NH4_ob/(medians_tot_ob)*100,1)
   TC_ob_percent	<- round(medians.df$TC_ob/(medians_tot_ob)*100,1)
   EC_ob_percent        <- round(medians.df$EC_ob/(medians_tot_ob)*100,1)
   OC_ob_percent	<- round(medians.df$OC_ob/(medians_tot_ob)*100,1)
   soil_ob_percent	<- round(medians.df$soil_ob/(medians_tot_ob)*100,1)
   NaCl_ob_percent	<- round(medians.df$NaCl_ob/(medians_tot_ob)*100,1)
   other_ob_percent	<- round(other_ob/(medians_tot_ob)*100,1)
   ncom_ob_percent	<- round(NCOM_ob/(medians_tot_ob)*100,1)
   water_ob_percent	<- round(water_ob/(medians_tot_ob)*100,1)
   blank_ob_percent	<- round(blank_ob/(medians_tot_ob)*100,1)

   SO4_mod_percent	<- round(medians.df$SO4_mod/(medians_tot_mod)*100,1)
   NO3_mod_percent	<- round(medians.df$NO3_mod/(medians_tot_mod)*100,1)
   NH4_mod_percent	<- round(medians.df$NH4_mod/(medians_tot_mod)*100,1)
   EC_mod_percent       <- round(medians.df$EC_mod/(medians_tot_mod)*100,1)
   OC_mod_percent       <- round(medians.df$OC_mod/(medians_tot_mod)*100,1)
   TC_mod_percent	<- round(medians.df$TC_mod/(medians_tot_mod)*100,1)
   soil_mod_percent     <- round(medians.df$soil_mod/(medians_tot_mod)*100,1)
   NaCl_mod_percent     <- round(medians.df$NaCl_mod/(medians_tot_mod)*100,1)
   other_mod_percent	<- round(medians.df$other_mod/(medians_tot_mod)*100,1)
   ncom_mod_percent     <- round(medians.df$ncom_mod/(medians_tot_mod)*100,1)
   other_rem_mod_percent<- round(medians.df$other_rem_mod/(medians_tot_mod)*100,1)
   blank_mod_percent    <- round(blank_mod/(medians_tot_mod)*100,1)
 
   if (inc_FRM_adj == 'y') {
      FRM_adj_mod_percent	<- round(FRM_adj_median/(medians_tot_mod)*100,1)
   }

   correlation	<- round(cor(total_mod, total_ob),2)
   rmse		<- round(sqrt(c(rmse, sum((total_mod - total_ob)^2)/length(total_ob))),2)
   ls_regress	<- lsfit(total_ob,total_mod)
   intercept	<- ls_regress$coefficients[1]
   X		<- ls_regress$coefficients[2]
   rmse_sys	<- round(sqrt(c(rmse_sys, sum(((intercept+X*total_ob) - total_ob)^2))/length(total_ob)),2)
   rmse_unsys	<- round(sqrt(c(rmse_unsys, sum((total_mod - (intercept+X*total_ob))^2)/length(total_ob))),2)
   index_agree	<- round(1-((sum((total_ob-total_mod)^2))/(sum((abs(total_mod-mean(total_ob))+abs(total_ob-mean(total_ob)))^2))),2)
   
   if (num_runs > 1) {
       water_ob2            <- 0.24*(medians2.df$SO4_ob+medians2.df$NH4_ob)
       NCOM_ob2             <- 0.8*medians2.df$OC_ob
       other_ob2            <- medians2.df$other_ob-(water_ob2+blank_ob2+NCOM_ob2)
       if (other_ob2 < 0) {
          other_ob2 <- 0
       }

       total_ob2	<- data2.df$SO4_ob+data2.df$NO3_ob+data2.df$NH4_ob+data2.df$TC_ob+data2.df$soil_ob+data2.df$NaCl_ob+data2.df$other_ob+water_ob2+NCOM_ob2
       total_mod2	<- data2.df$SO4_mod+data2.df$NO3_mod+data2.df$NH4_mod+data2.df$TC_mod+data2.df$soil_mod+data2.df$NaCl_mod+data2.df$ncom_mod+data2.df$other_rem_mod
       medians_tot_mod2     <- medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$TC_mod+medians2.df$soil_mod+medians2.df$NaCl_mod+medians2.df$ncom_mod+medians2.df$other_rem_mod

      if (inc_FRM_adj == 'y') {
         FRM_adj2               <- data2.df$PM_FRM_mod-data2.df$PM_TOT_mod
         if (FRM_adj2 < 0) { FRM_adj2 <- 0 }
         FRM_adj_median2        <- medians2.df$PM_FRM_mod-medians2.df$PM_TOT_mod
         if (FRM_adj_median2 < 0) { FRM_adj_median2 <- 0 }
         total_mod2             <- data2.df$SO4_mod+data2.df$NO3_mod+data2.df$NH4_mod+data2.df$TC_mod+data2.df$soil_mod+data2.df$NaCl_mod+data2.df$ncom_mod+data2.df$other_rem_mod+FRM_adj2
         medians_tot_mod2       <- medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$TC_mod+medians2.df$soil_mod+medians2.df$NaCl_mod+medians2.df$ncom_mod+medians2.df$other_rem_mod+FRM_adj_median2
      }


      SO4_mod_percent2		<- round(medians2.df$SO4_mod/(medians_tot_mod2)*100,1)
      NO3_mod_percent2		<- round(medians2.df$NO3_mod/(medians_tot_mod2)*100,1)
      NH4_mod_percent2		<- round(medians2.df$NH4_mod/(medians_tot_mod2)*100,1)
      EC_mod_percent2		<- round(medians2.df$EC_mod/(medians_tot_mod2)*100,1)
      OC_mod_percent2		<- round(medians2.df$OC_mod/(medians_tot_mod2)*100,1)
      TC_mod_percent2		<- round(medians2.df$TC_mod/(medians_tot_mod2)*100,1)
      soil_mod_percent2		<- round(medians2.df$soil_mod/(medians_tot_mod2)*100,1)
      NaCl_mod_percent2		<- round(medians2.df$NaCl_mod/(medians_tot_mod2)*100,1)
      other_mod_percent2	<- round(medians2.df$other_mod/(medians_tot_mod2)*100,1)
      ncom_mod_percent2		<- round(medians2.df$ncom_mod/(medians_tot_mod2)*100,1)
      other_rem_mod_percent2	<- round(medians2.df$other_rem_mod/(medians_tot_mod2)*100,1)
      blank_mod_percent2        <- round(blank_mod2/(medians_tot_mod2)*100,1)

      if (inc_FRM_adj == 'y') {
         FRM_adj_mod_percent2       <- round(FRM_adj_median2/(medians_tot_mod2)*100,1)
      }

      correlation2 <- round(cor(total_mod2, total_ob2),2) 
      rmse2        <- round(sqrt(c(rmse2, sum((total_mod2 - total_ob2)^2)/length(total_ob2))),2)
      ls_regress   <- lsfit(total_ob2,total_mod2)
      intercept    <- ls_regress$coefficients[1]
      X            <- ls_regress$coefficients[2]
      rmse_sys2    <- round(sqrt(c(rmse_sys2, sum(((intercept+X*total_ob2) - total_ob2)^2))/length(total_ob2)),2)
      rmse_unsys2  <- round(sqrt(c(rmse_unsys2, sum((total_mod2 - (intercept+X*total_ob2))^2)/length(total_ob2))),2)
      index_agree2 <- round(1-((sum((total_ob2-total_mod2)^2))/(sum((abs(total_mod2-mean(total_ob2))+abs(total_ob2-mean(total_ob2)))^2))),2)
   }
###############################################################

{
   if ((network == 'CSN') && (inc_FRM_adj == 'y')) {
      data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,medians.df$EC_ob,medians.df$EC_mod,medians.df$OC_ob,medians.df$OC_mod,medians.df$soil_ob,medians.df$soil_mod,medians.df$NaCl_ob,medians.df$NaCl_mod,NCOM_ob,medians.df$ncom_mod,other_ob,medians.df$other_rem_mod,blank_ob,blank_mod,water_ob,FRM_adj_median),byrow=T,ncol=2)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
      out_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,SO4_ob_percent,SO4_mod_percent,medians.df$NO3_ob,medians.df$NO3_mod,NO3_ob_percent,NO3_mod_percent,medians.df$NH4_ob,medians.df$NH4_mod,NH4_ob_percent,NH4_mod_percent,medians.df$EC_ob,medians.df$EC_mod,EC_ob_percent,EC_mod_percent,medians.df$OC_ob,medians.df$OC_mod,OC_ob_percent,OC_mod_percent,medians.df$soil_ob,medians.df$soil_mod,soil_ob_percent,soil_mod_percent,medians.df$NaCl_ob,medians.df$NaCl_mod,NaCl_ob_percent,NaCl_mod_percent,NCOM_ob,medians.df$ncom_mod,ncom_ob_percent,ncom_mod_percent,other_ob,medians.df$other_rem_mod,other_ob_percent,other_rem_mod_percent,blank_ob,blank_mod,blank_ob_percent,blank_mod_percent,water_ob,FRM_adj_median,water_ob_percent,FRM_adj_mod_percent),byrow=T,ncol=4)
   }
   else if (network == 'CSN') {
      data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,medians.df$EC_ob,medians.df$EC_mod,medians.df$OC_ob,medians.df$OC_mod,medians.df$soil_ob,medians.df$soil_mod,medians.df$NaCl_ob,medians.df$NaCl_mod,NCOM_ob,medians.df$ncom_mod,other_ob,medians.df$other_rem_mod,blank_ob,blank_mod,water_ob,0),byrow=T,ncol=2)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
   } 
   else {
      data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,medians.df$EC_ob,medians.df$EC_mod,medians.df$OC_ob,medians.df$OC_mod,medians.df$soil_ob,medians.df$soil_mod,medians.df$NaCl_ob,medians.df$NaCl_mod,NCOM_ob,medians.df$ncom_mod,other_ob,medians.df$other_rem_mod),byrow=T,ncol=2)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
   }
   yaxis.max   <- max(c(sum(data_matrix[,1]),sum(data_matrix[,2])))        # find the max of the average values to set y-axis max
}

if (num_runs > 1) {
   if ((network == 'CSN') && (inc_FRM_adj == 'y')) {
      data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians2.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians2.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,medians2.df$NH4_mod,medians.df$EC_ob,medians.df$EC_mod,medians2.df$EC_mod,medians.df$OC_ob,medians.df$OC_mod,medians2.df$OC_mod,medians.df$soil_ob,medians.df$soil_mod,medians2.df$soil_mod,medians.df$NaCl_ob,medians.df$NaCl_mod,medians2.df$NaCl_mod,NCOM_ob,medians.df$ncom_mod,medians2.df$ncom_mod,other_ob,medians.df$other_rem_mod,medians2.df$other_rem_mod,blank_ob,blank_mod,blank_mod2,water_ob,FRM_adj_median,FRM_adj_median2),byrow=T,ncol=3)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
   }
   else if (network == 'CSN') {
      data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians2.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians2.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,medians2.df$NH4_mod,medians.df$EC_ob,medians.df$EC_mod,medians2.df$EC_mod,medians.df$OC_ob,medians.df$OC_mod,medians2.df$OC_mod,medians.df$soil_ob,medians.df$soil_mod,medians2.df$soil_mod,medians.df$NaCl_ob,medians.df$NaCl_mod,medians2.df$NaCl_mod,NCOM_ob,medians.df$ncom_mod,medians2.df$ncom_mod,other_ob,medians.df$other_rem_mod,medians2.df$other_rem_mod,blank_ob,blank_mod,blank_mod2,water_ob,0,0),byrow=T,ncol=3)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
   }
   else {
   data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians2.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians2.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,medians2.df$NH4_mod,medians.df$EC_ob,medians.df$EC_mod,medians2.df$EC_mod,medians.df$OC_ob,medians.df$OC_mod,medians2.df$OC_mod,medians.df$soil_ob,medians.df$soil_mod,medians2.df$soil_mod,medians.df$NaCl_ob,medians.df$NaCl_mod,medians2.df$NaCl_mod,NCOM_ob,medians.df$ncom_mod,medians2.df$ncom_mod,other_ob,medians.df$other_rem_mod,medians2.df$other_rem_mod),byrow=T,ncol=3)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
   }
   yaxis.max   <- max(c(sum(data_matrix[,1]),sum(data_matrix[,2]),sum(data_matrix[,3])))        # find the max of the average values to set y-axis max 
}

yaxis.max   <- round(yaxis.max*1.2,1)  # find the max of the average values to set y-axis max 

   if (length(y_axis_max) > 0) {
      yaxis.max <- y_axis_max
   }
{
   if (num_runs > 1) {
      simulations	<- paste(network_label,run_name1,run_name2,sep=",")
      sim_names		<- c(network_label,"Simulation 1","Simulation 2")
   }
   else {
      simulations	<- paste(network_label,run_name1,sep="")
      sim_names		<- c(network_label,run_name1)
   }
}
write.table(paste(simulations,": ",dates,sep=""),file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
write.table(aqdat_all.df,file=filename_txt,append=F,row.names=F,sep=",")      # Write raw data to csv file
{
   if (num_runs == 1) {
      write.table("Observed(ug/m3),Modeled(ug/m3),Observed(%),Modeled(%)",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
   }
   else {
      write.table("Observed, Modeled, Modeled",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
   }
}

{
   if (network == 'CSN') {
      write.table(out_matrix,file=filename_txt,append=T,col.names=F,row.names=c("SO4","NO3","NH4","EC","OC","Soil","NaCl","NCOM","Other","blank","water"),sep=",")
#       write.table(out_matrix,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      species_names <- c("H2O/FRM Adj","Blank Adj","Other","NCOM","NaCl","Soil","OC","EC",expression(paste(NH[4]^"  +")),expression(paste(NO[3]^"  -")),expression(paste(SO[4]^"  2-")))
      plot_cols     <- c("yellow","red","orange","black","grey","brown4","seagreen1","pink","white","grey35","light blue")
      plot_cols_leg <- c("light blue","grey35","white","pink","seagreen1","brown4","grey","black","orange","red","yellow") 
   }
   else {
      write.table(data_matrix,file=filename_txt,append=T,col.names=F,row.names=c("SO4","NO3","NH4","EC","OC","Soil","NaCl","NCOM","Other"),sep=",")
      species_names <- c("Other","NCOM","NaCl","Soil","OC","EC",expression(paste(NH[4]^"  +")),expression(paste(NO[3]^"  -")),expression(paste(SO[4]^"  2-")))
      plot_cols     <- c("yellow","red","orange","black","grey","brown4","seagreen1","pink","white")
      plot_cols_leg <- c("white","pink","seagreen1","brown4","grey","black","orange","red","yellow")
   }
}

########## MAKE STACKED BARPLOT: ALL SITES ##########
pdf(file=filename_pdf,width=10,height=8)
par(mai=c(1,1,0.5,0.5))		# set margins

{
   if (num_runs == 1) {
      barplot(data_matrix, beside=FALSE, ylab="Concentration (ug/m3)",names.arg=sim_names,width=0.5,xlim=c(0,2),ylim=c(0,yaxis.max),col=plot_cols,xpd=F,space=.6,cex.axis=1.4,cex.names=1.2,cex.lab=1.2)
      x1_adjust <- 1
      x2_adjust <- 1
   }
   else {
      barplot(data_matrix, beside=FALSE, ylab="Concentration (ug/m3)",names.arg=sim_names,width=0.3,xlim=c(0,2),ylim=c(0,yaxis.max),col=plot_cols,xpd=F,space=.9,cex.axis=1.4,cex.names=1.2,cex.lab=1.2)
      x1_adjust <- .91
      x2_adjust <- .77
   }
}
legend("topright",species_names,fill=plot_cols_leg,cex=0.9)

x1 <- x1_adjust*.27
x2 <- x2_adjust*1.08
x3 <- 1.4

##########################################################################
### Add percentage values next to each species on the stacked bar plot ###
##########################################################################
text(x1,(medians.df$SO4_ob/2),paste(SO4_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$SO4_ob+(medians.df$NO3_ob/2)),paste(NO3_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+(medians.df$NH4_ob/2)),paste(NH4_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+(medians.df$EC_ob/2)),paste(EC_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+(medians.df$OC_ob/2)),paste(OC_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+(medians.df$soil_ob/2)),paste(soil_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+medians.df$soil_ob+(medians.df$NaCl_ob/2)),paste(NaCl_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+medians.df$soil_ob+medians.df$NaCl_ob+(NCOM_ob/2)),paste(ncom_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+medians.df$soil_ob+medians.df$NaCl_ob+NCOM_ob+(other_ob/2)),paste(other_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
if (network == 'CSN') {
   text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+medians.df$soil_ob+medians.df$NaCl_ob+NCOM_ob+other_ob+(blank_ob/2)),paste(blank_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+medians.df$soil_ob+medians.df$NaCl_ob+NCOM_ob+other_ob+blank_ob+(water_ob/2)),paste(water_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
}

{
if ((network == 'CSN') && (inc_FRM_adj == 'y')) {
   text(x2,(medians.df$SO4_mod/2),paste(SO4_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+(medians.df$NO3_mod/2)),paste(NO3_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+(medians.df$NH4_mod/2)),paste(NH4_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+(medians.df$EC_mod/2)),paste(EC_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+(medians.df$OC_mod/2)),paste(OC_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+(medians.df$soil_mod/2)),paste(soil_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+(medians.df$NaCl_mod/2)),paste(NaCl_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+medians.df$NaCl_mod+(medians.df$ncom_mod/2)),paste(ncom_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+medians.df$NaCl_mod+medians.df$ncom_mod+(medians.df$other_rem_mod/2)),paste(other_rem_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+medians.df$NaCl_mod+medians.df$ncom_mod+medians.df$other_rem_mod+(blank_mod/2)),paste(blank_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+medians.df$NaCl_mod+medians.df$ncom_mod+medians.df$other_rem_mod+blank_mod+(FRM_adj_median/2)),paste(FRM_adj_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))

}

else {
   text(x2,(medians.df$SO4_mod/2),paste(SO4_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+(medians.df$NO3_mod/2)),paste(NO3_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+(medians.df$NH4_mod/2)),paste(NH4_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+(medians.df$EC_mod/2)),paste(EC_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+(medians.df$OC_mod/2)),paste(OC_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+(medians.df$soil_mod/2)),paste(soil_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+(medians.df$NaCl_mod/2)),paste(NaCl_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+medians.df$NaCl_mod+(medians.df$ncom_mod/2)),paste(ncom_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+medians.df$NaCl_mod+medians.df$ncom_mod+(medians.df$other_rem_mod/2)),paste(other_rem_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   if (network == 'CSN') {
      text(x2,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+medians.df$NaCl_mod+medians.df$ncom_mod+medians.df$other_rem_mod+(blank_mod/2)),paste(blank_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   }
}
}

if (num_runs > 1) {
   if ((network == 'CSN') && (inc_FRM_adj == 'y')) {
      text(x3,(medians2.df$SO4_mod/2),paste(SO4_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+(medians2.df$NO3_mod/2)),paste(NO3_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+(medians2.df$NH4_mod/2)),paste(NH4_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+(medians2.df$EC_mod/2)),paste(EC_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+(medians2.df$OC_mod/2)),paste(OC_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+(medians2.df$soil_mod/2)),paste(soil_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+medians2.df$soil_mod+(medians2.df$NaCl_mod/2)),paste(NaCl_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+medians2.df$soil_mod+medians2.df$NaCl_mod+(medians2.df$ncom_mod/2)),paste(ncom_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+medians2.df$soil_mod+medians2.df$NaCl_mod+medians2.df$ncom_mod+(medians2.df$other_rem_mod/2)),paste(other_rem_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+medians2.df$soil_mod+medians2.df$NaCl_mod+medians2.df$ncom_mod+medians2.df$other_rem_mod+(blank_mod2/2)),paste(blank_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+medians2.df$soil_mod+medians2.df$NaCl_mod+medians2.df$ncom_mod+medians2.df$other_rem_mod+blank_mod2+(FRM_adj_median2/2)),paste(FRM_adj_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   }
   else {
      text(x3,(medians2.df$SO4_mod/2),paste(SO4_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+(medians2.df$NO3_mod/2)),paste(NO3_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+(medians2.df$NH4_mod/2)),paste(NH4_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+(medians2.df$EC_mod/2)),paste(EC_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+(medians2.df$OC_mod/2)),paste(OC_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+(medians2.df$soil_mod/2)),paste(soil_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+medians2.df$soil_mod+(medians2.df$NaCl_mod/2)),paste(NaCl_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+medians2.df$soil_mod+medians2.df$NaCl_mod+(medians2.df$ncom_mod/2)),paste(ncom_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+medians2.df$soil_mod+medians2.df$NaCl_mod+medians2.df$ncom_mod+(medians2.df$other_rem_mod/2)),paste(other_rem_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      if (network == 'CSN') {
         text(x3,(medians2.df$SO4_mod+medians2.df$NO3_mod+medians2.df$NH4_mod+medians2.df$EC_mod+medians2.df$OC_mod+medians2.df$soil_mod+medians2.df$NaCl_mod+medians2.df$ncom_mod+medians2.df$other_rem_mod+(blank_mod2/2)),paste(blank_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
      }
   }  
}
##########################################################################

############################################################
### Add number of sites and number of obs counts to plot ###
############################################################
text(2.07,yaxis.max*.60,paste("# of sites: ",num_sites,sep=""),cex=1.2,adj=c(1,0))
text(2.07,yaxis.max*.57,paste("# of obs: ",num_pairs,sep=""),cex=1.2,adj=c(1,0))
if (run_info_text == "y") {
   if (rpo != "None") {
      text(2.07,yaxis.max*.53,paste("RPO: ",rpo,sep=""),cex=1,adj=c(1,0))
   }
   if (pca != "None") {
      text(2.07,yaxis.max*.50,paste("PCA: ",pca,sep=""),cex=.9,adj=c(1,0))
   }
   if (site != "All") {
      text(2.07,yaxis.max*.47,paste("Site: ",site,sep=""),cex=1,adj=c(1,0))
   }
   if (state != "All") {
      text(2.07,yaxis.max*.44,paste("State: ",state,sep=""),cex=1,adj=c(1,0))
   }
} 
############################################################

###################################
### Add statistics to plot area ###
###################################
text(2.07,yaxis.max*.35,paste("RMSE: ",rmse,sep=""),cex=1,adj=c(1,0))
text(2.07,yaxis.max*.32,paste("RMSEs: ",rmse_sys,sep=""),cex=1,adj=c(1,0))
text(2.07,yaxis.max*.29,paste("RMSEu: ",rmse_unsys,sep=""),cex=1,adj=c(1,0))
text(2.07,yaxis.max*.26,paste("IA:   ",index_agree,sep=""),cex=1,adj=c(1,0))
text(2.07,yaxis.max*.23,paste("r:   ",correlation,sep=""),cex=1,adj=c(1,0))

if (num_runs > 1) {
   ### Add statistics to plot area ###
   text(0,yaxis.max*.97,paste("Simulation 1:",run_name1),cex=1,adj=c(0,0))
   text(0,yaxis.max*.94,paste("Simulation 2:",run_name2),cex=1,adj=c(0,0))
   text(2.07,yaxis.max*.38,"Simulation 1",cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.16,"Simulation 2",cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.13,paste("RMSE: ",rmse2,sep=""),cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.10,paste("RMSEs: ",rmse_sys2,sep=""),cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.07,paste("RMSEu: ",rmse_unsys2,sep=""),cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.04,paste("IA:   ",index_agree2,sep=""),cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.01,paste("r:   ",correlation2,sep=""),cex=1,adj=c(1,0))
}
######################################

## Put title at top of barplot ##
title(main=title,cex.main=1.1)

## Convert pdf to png ##
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density 150x150 ",filename_pdf," png:",filename_png,sep="")
   dev.off()
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}
########################


