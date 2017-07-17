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
ametbase        <- Sys.getenv("AMETBASE")        		# base directory of AMET
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
filename_pdf    <- paste(run_name1,pid,"stacked_barplot_panel_AE6.pdf",sep="_")
filename_png    <- paste(run_name1,pid,"stacked_barplot_panel_AE6.png",sep="_")
filename_txt    <- paste(run_name1,pid,"stacked_barplot_panel_AE6_data.csv",sep="_")

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
################################################


pdf(file=filename_pdf,width=10,height=8)
my.layout <- layout(matrix(c(1, 5,  9, 13, 17,
                             2, 6,  10, 14, 18,
                             3, 7,  11, 15, 19,
                             4, 8,  12, 16, 20),nrow=4,ncol=5,byrow=T),
                             widths=c(.7,1,1,1,1),heights=c(1,1,1,1))

par(mgp=c(2,0.5,0))
par(mai=c(0.4,0.4,0.2,0.05))

season         <- NULL
pca            <- NULL

pca[1] <- " and s.stat_id=d.stat_id and (s.state='ME' or s.state='NH' or s.state='VT' or s.state='MA' or s.state='NY' or s.state='NJ' or s.state='MD' or s.state='DE' or s.state='CT' or s.state='RI' or s.state='PA' or s.state='DC' or s.state='VA' or s.state='WV')"
pca[2] <- " and s.stat_id=d.stat_id and (s.state='OH' or s.state='MI' or s.state='IN' or s.state='IL' or s.state='WI')"
pca[3] <- " and s.stat_id=d.stat_id and (s.state='NC' or s.state='SC' or s.state='GA' or s.state='FL')"
pca[4] <- " and s.stat_id=d.stat_id and (s.state='KY' or s.state='TN' or s.state='MS' or s.state='AL' or s.state='LA' or s.state='MO' or s.state='OK' or s.state='AR')"

season[4] <- " and (d.month = 12 or d.month = 1 or d.month = 2)"
season[1] <- " and (d.month = 3 or d.month = 4 or d.month = 5)"
season[2] <- " and (d.month = 6 or d.month = 7 or d.month = 8)"
season[3] <- " and (d.month = 9 or d.month = 10 or d.month = 11)"

season_names <- c("Spring","Summer","Fall","Winter")
pca_names <- c("Northeast","Great Lakes","Atlantic","South")
figure_names <- c("(a)","(b)","(c)","(d)")

for (i in 1:4) {
{
   if (network == 'CSN') {
      species_names <- c("H2O/FRM Adj","Blank Adj","Other","NCOM","NaCl","Soil","OC","EC",expression(paste(NH[4]^"  +")),expression(paste(NO[3]^"  -")),expression(paste(SO[4]^"  2-")))
      plot_cols     <- c("yellow","red","orange","black","grey","brown4","seagreen1","pink","white","grey35","light blue")
      plot_cols_leg <- c("light blue","grey35","white","pink","seagreen1","brown4","grey","black","orange","red","yellow")
   }
   else {
      species_names <- c("Other","NCOM","NaCl","Soil","OC","EC",expression(paste(NH[4]^"  +")),expression(paste(NO[3]^"  -")),expression(paste(SO[4]^"  2-")))
      plot_cols     <- c("yellow","red","orange","black","grey","brown4","seagreen1","pink","white")
      plot_cols_leg <- c("white","pink","seagreen1","brown4","grey","black","orange","red","yellow")
   }
}

   plot.new()
   text(x=.30,y=.99,paste(season_names[i],sep=" "),cex=1)
   legend(x=0.04,y=0.94,species_names,fill=plot_cols_leg,cex=.7,bty="o")
   mtext(run_name1,cex=0.7,side=2)
}

for (n in 1:4) {
   for (p in 1:4) {
      medians          <- NULL
      data             <- NULL
      drop_names     <- NULL
      species_names  <- NULL
      species_names2 <- NULL
      criteria <- paste(" WHERE d.SO4_ob is not NULL and d.network='",network,"' ",season[p],pca[n],sep="")          # Set part of the MYSQL query
      check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name1,"' and COLUMN_NAME = 'POCode';",sep="")
      query_table_info.df <-db_Query(check_POCode,mysql)
      {
      if (length(query_table_info.df$COLUMN_NAME) == 0) {    # Check to see if POCode column exists or not
         qs <- paste("SELECT d.proj_code,d.network,d.stat_id,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.SO4_ob,d.SO4_mod,d.NO3_ob,d.NO3_mod,d.NH4_ob,d.NH4_mod,d.PM_TOT_ob,d.PM_TOT_mod,d.PM_FRM_ob,PM_FRM_mod,d.EC_ob,d.EC_mod,d.OC_ob,d.OC_mod,d.TC_ob,d.TC_mod,d.soil_ob,d.soil_mod,d.ncom_mod,d.NaCl_ob,d.NaCl_mod,d.other_ob,d.other_mod,d.other_rem_mod from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")
         aqdat_all.df<-db_Query(qs,mysql)
         aqdat_all.df$POCode <- 1

         }
         else {
            qs <- paste("SELECT d.proj_code,d.network,d.stat_id,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.SO4_ob,d.SO4_mod,d.NO3_ob,d.NO3_mod,d.NH4_ob,d.NH4_mod,d.PM_TOT_ob,d.PM_TOT_mod,d.PM_FRM_ob,PM_FRM_mod,d.EC_ob,d.EC_mod,d.OC_ob,d.OC_mod,d.TC_ob,d.TC_mod,d.soil_ob,d.soil_mod,d.ncom_mod,d.NaCl_ob,d.NaCl_mod,d.other_ob,d.other_mod,d.other_rem_mod from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")
            aqdat_all.df <- db_Query(qs,mysql)
         }
      }
      aqdat_all.df$stat_id <- paste(aqdat_all.df$stat_id,aqdat_all.df$POCode,sep='')      # Create unique site using site ID and PO Code
      blank_mod  <- 0.4
      blank_mod2 <- 0.4
      blank_ob   <- 0.4
      if (network == 'IMPROVE') {
         aqdat_all.df$PM_FRM_ob <- aqdat_all.df$PM_TOT_ob
         aqdat_all.df$PM_FRM_mod <- aqdat_all.df$PM_TOT_mod
         blank_mod  <- 0
         blank_ob   <- 0
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

      num_sites       <- length(unique(aqdat_sub.df$stat_id))
      num_pairs       <- length(aqdat_sub.df$stat_id)

      data.df         <- aqdat_sub.df[8:len]
      {
         if (use_median == "y") {
            medians.df        <- lapply(data.df,median)
         }
         else {
            medians.df   <- lapply(data.df,mean)
         }
      }
##############################################################

###############################################################
### Calculate percent of total PM2.5 each species comprises ###
###############################################################
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
         if (FRM_adj < 0) { FRM_adj <- 0 }
         FRM_adj_median         <- medians.df$PM_FRM_mod-medians.df$PM_TOT_mod
         if (FRM_adj_median < 0) { FRM_adj_median <- 0 }
         total_mod              <- data.df$SO4_mod+data.df$NO3_mod+data.df$NH4_mod+data.df$TC_mod+data.df$soil_mod+data.df$NaCl_mod+data.df$ncom_mod+blank_mod+data.df$other_rem_mod+FRM_adj
         medians_tot_mod        <- medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$TC_mod+medians.df$soil_mod+medians.df$NaCl_mod+medians.df$ncom_mod+other_mod+blank_mod+FRM_adj_median
      }

      SO4_ob_percent       <- round(medians.df$SO4_ob/(medians_tot_ob)*100,1)
      NO3_ob_percent       <- round(medians.df$NO3_ob/(medians_tot_ob)*100,1)
      NH4_ob_percent       <- round(medians.df$NH4_ob/(medians_tot_ob)*100,1)
      TC_ob_percent        <- round(medians.df$TC_ob/(medians_tot_ob)*100,1)
      EC_ob_percent        <- round(medians.df$EC_ob/(medians_tot_ob)*100,1)
      OC_ob_percent        <- round(medians.df$OC_ob/(medians_tot_ob)*100,1)
      soil_ob_percent      <- round(medians.df$soil_ob/(medians_tot_ob)*100,1)
      NaCl_ob_percent      <- round(medians.df$NaCl_ob/(medians_tot_ob)*100,1)
      other_ob_percent     <- round(other_ob/(medians_tot_ob)*100,1)
      NCOM_ob_percent      <- round(NCOM_ob/(medians_tot_ob)*100,1)
      water_ob_percent     <- round(water_ob/(medians_tot_ob)*100,1)
      blank_ob_percent     <- round(blank_ob/(medians_tot_ob)*100,1)

      SO4_mod_percent      <- round(medians.df$SO4_mod/(medians_tot_mod)*100,1)
      NO3_mod_percent      <- round(medians.df$NO3_mod/(medians_tot_mod)*100,1)
      NH4_mod_percent      <- round(medians.df$NH4_mod/(medians_tot_mod)*100,1)
      EC_mod_percent       <- round(medians.df$EC_mod/(medians_tot_mod)*100,1)
      OC_mod_percent       <- round(medians.df$OC_mod/(medians_tot_mod)*100,1)
      TC_mod_percent       <- round(medians.df$TC_mod/(medians_tot_mod)*100,1)
      soil_mod_percent     <- round(medians.df$soil_mod/(medians_tot_mod)*100,1)
      NaCl_mod_percent     <- round(medians.df$NaCl_mod/(medians_tot_mod)*100,1)
      other_mod_percent    <- round(medians.df$other_mod/(medians_tot_mod)*100,1)
      ncom_mod_percent     <- round(medians.df$ncom_mod/(medians_tot_mod)*100,1)
      other_rem_mod_percent<- round(medians.df$other_rem_mod/(medians_tot_mod)*100,1)
      blank_mod_percent    <- round(blank_mod/(medians_tot_mod)*100,1)

      if (inc_FRM_adj == 'y') {
         FRM_adj_mod_percent       <- round(FRM_adj_median/(medians_tot_mod)*100,1)
      }

      {  
         if ((network == 'CSN') && (inc_FRM_adj == 'y')) {
            data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,medians.df$EC_ob,medians.df$EC_mod,medians.df$OC_ob,medians.df$OC_mod,medians.df$soil_ob,medians.df$soil_mod,medians.df$NaCl_ob,medians.df$NaCl_mod,NCOM_ob,medians.df$ncom_mod,other_ob,medians.df$other_rem_mod,blank_ob,blank_mod,water_ob,FRM_adj_median),byrow=T,ncol=2)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
         }
         else if (network == 'CSN') {
            data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,medians.df$EC_ob,medians.df$EC_mod,medians.df$OC_ob,medians.df$OC_mod,medians.df$soil_ob,medians.df$soil_mod,medians.df$NaCl_ob,medians.df$NaCl_mod,NCOM_ob,medians.df$ncom_mod,other_ob,medians.df$other_rem_mod,blank_ob,blank_mod,water_ob,0),byrow=T,ncol=2)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
         }
         else {
            data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,medians.df$EC_ob,medians.df$EC_mod,medians.df$OC_ob,medians.df$OC_mod,medians.df$soil_ob,medians.df$soil_mod,medians.df$NaCl_ob,medians.df$NaCl_mod,NCOM_ob,medians.df$ncom_mod,other_ob,medians.df$other_rem_mod),byrow=T,ncol=2)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
         }
         yaxis.max   <- round(max(c(sum(data_matrix[,1]),sum(data_matrix[,2]))),)        # find the max of the average values to set y-axis max
      }

      yaxis.max   <- yaxis.max*1.2  # find the max of the average values to set y-axis max

      if (length(y_axis_max) > 0) {
           yaxis.max <- y_axis_max
      }
 
      if ((n == 1) && (p == 1)) {
         if (network == 'CSN') {
            write.table(paste(simulations,season[p],pca[n],sep=" "),file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
            write.table("Observed, Modeled",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
            write.table(data_matrix,file=filename_txt,append=T,col.names=F,row.names=c("SO4","NO3","NH4","EC","OC","Soil","NaCl","NCOM","Other","blank","water"),sep=",")
         }
         else {
            write.table(paste(simulations,season[p],pca[n],sep=" "),file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
            write.table("Observed, Modeled",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
            write.table(data_matrix,file=filename_txt,append=T,col.names=F,row.names=c("SO4","NO3","NH4","EC","OC","Soil","NaCl","NCOM","Other"),sep=",")
         }
      }
      else {
         if (network == 'CSN') {
            write.table(paste(simulations,season[p],pca[n],sep=" "),file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
            write.table("Observed, Modeled",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
            write.table(data_matrix,file=filename_txt,append=F,col.names=F,row.names=c("SO4","NO3","NH4","EC","OC","Soil","NaCl","NCOM","Other","blank","water"),sep=",")
         }
         else {
            write.table(paste(simulations,season[p],pca[n],sep=" "),file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
            write.table("Observed, Modeled",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
            write.table(data_matrix,file=filename_txt,append=F,col.names=F,row.names=c("SO4","NO3","NH4","EC","OC","Soil","NaCl","NCOM","Other"),sep=",")
         }
      }

      {
         if (network == 'CSN') {
            write.table(data_matrix,file=filename_txt,append=T,col.names=F,row.names=c("SO4","NO3","NH4","EC","OC","Soil","NaCl","NCOM","Other","blank","water"),sep=",")
         }
         else {
            write.table(data_matrix,file=filename_txt,append=T,col.names=F,row.names=c("SO4","NO3","NH4","EC","OC","Soil","NaCl","NCOM","Other"),sep=",")
         }
      }
########## MAKE STACKED BARPLOT: ALL SITES ##########

      barplot(data_matrix, beside=FALSE, ylab="Concentration (ug/m3)",width=0.12,ylim=c(0,yaxis.max),col=plot_cols,xpd=F,space=1.7,cex.axis=.8,cex.names=.8,cex.lab=.8, xlim=c(0,1))
      mtext(network,side=1,at=(.26),adj=0.5,cex=.6)
      mtext(model_name,side=1,at=(.58),adj=0.5,cex=.6)
      x1 <- .19
      x2 <- .19
      x3 <- .67
      x4 <- .67

#########################################################################
### Add percentage values next to each specie on the stacked bar plot ###
#########################################################################
      text(x1,(medians.df$SO4_ob/2),paste(SO4_ob_percent,"%",sep=""),cex=.6,adj=c(1,0.5))
      text(x2,(medians.df$SO4_ob+(medians.df$NO3_ob/2)),paste(NO3_ob_percent,"% ---",sep=""),cex=.6,adj=c(1,0.5))
      text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+(medians.df$NH4_ob/2)),paste(NH4_ob_percent,"%",sep=""),cex=.6,adj=c(1,0.5))
      text(x2,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+(medians.df$EC_ob/2)),paste(EC_ob_percent,"% ---",sep=""),cex=.6,adj=c(1,0.5))
      text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+(medians.df$OC_ob/2)),paste(OC_ob_percent,"%",sep=""),cex=.6,adj=c(1,0.5))
      text(x2,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+(medians.df$soil_ob/2)),paste(soil_ob_percent,"% ---",sep=""),cex=.6,adj=c(1,0.5))
      text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+medians.df$soil_ob+(medians.df$NaCl_ob/2)),paste(NaCl_ob_percent,"%",sep=""),cex=.6,adj=c(1,0.5))
      text(x2,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+medians.df$soil_ob+medians.df$NaCl_ob+(NCOM_ob/2)),paste(NCOM_ob_percent,"% ---",sep=""),cex=.6,adj=c(1,0.5))
      text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+medians.df$soil_ob+medians.df$NaCl_ob+NCOM_ob+(other_ob/2)),paste(other_ob_percent,"%",sep=""),cex=.6,adj=c(1,0.5))
       if (network == 'CSN') {
         text(x2,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+medians.df$soil_ob+medians.df$NaCl_ob+NCOM_ob+other_ob+(blank_ob/2)),paste(blank_ob_percent,"% ---",sep=""),cex=.6,adj=c(1,0.5))
         text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+medians.df$soil_ob+medians.df$NaCl_ob+NCOM_ob+other_ob+blank_ob+(water_ob/2)),paste(water_ob_percent,"%",sep=""),cex=.6,adj=c(1,0.5))
      }

      {
         if ((network == 'CSN') && (inc_FRM_adj == 'y')) {
            text(x3,(medians.df$SO4_mod/2),paste(SO4_mod_percent,"%",sep=""),cex=.6,adj=c(0,0.5))
            text(x4,(medians.df$SO4_mod+(medians.df$NO3_mod/2)),paste("--- ",NO3_mod_percent,"%",sep=""),cex=.6,adj=c(0,0.5))
            text(x3,(medians.df$SO4_mod+medians.df$NO3_mod+(medians.df$NH4_mod/2)),paste(NH4_mod_percent,"%",sep=""),cex=.6,adj=c(0,0.5))
            text(x4,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+(medians.df$EC_mod/2)),paste("--- ",EC_mod_percent,"%",sep=""),cex=.6,adj=c(0,0.5))
            text(x3,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+(medians.df$OC_mod/2)),paste(OC_mod_percent,"%",sep=""),cex=.6,adj=c(0,0.5))
            text(x4,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+(medians.df$soil_mod/2)),paste("--- ",soil_mod_percent,"%",sep=""),cex=.6,adj=c(0,0.5))
            text(x3,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+(medians.df$NaCl_mod/2)),paste(NaCl_mod_percent,"%",sep=""),cex=.6,adj=c(0,0.5))
            text(x4,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+medians.df$NaCl_mod+(medians.df$ncom_mod/2)),paste("--- ",ncom_mod_percent,"%",sep=""),cex=.6,adj=c(0,0.5))
            text(x3,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+medians.df$NaCl_mod+medians.df$ncom_mod+(medians.df$other_rem_mod/2)),paste(other_rem_mod_percent,"%",sep=""),cex=.6,adj=c(0,0.5))
            text(x4,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+medians.df$NaCl_mod+medians.df$ncom_mod+medians.df$other_rem_mod+(blank_mod/2)),paste("--- ",blank_mod_percent,"%",sep=""),cex=.6,adj=c(0,0.5))
            text(x3,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+medians.df$NaCl_mod+medians.df$ncom_mod+medians.df$other_rem_mod+blank_mod+(FRM_adj_median/2)),paste(FRM_adj_mod_percent,"%",sep=""),cex=.6,adj=c(0,0.5))
         }  
         else {
            text(x3,(medians.df$SO4_mod/2),paste(SO4_mod_percent,"%",sep=""),cex=0.6,adj=c(0,0.5))
            text(x4,(medians.df$SO4_mod+(medians.df$NO3_mod/2)),paste("--- ",NO3_mod_percent,"%",sep=""),cex=0.6,adj=c(0,0.5))
            text(x3,(medians.df$SO4_mod+medians.df$NO3_mod+(medians.df$NH4_mod/2)),paste(NH4_mod_percent,"%",sep=""),cex=0.6,adj=c(0,0.5))
            text(x4,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+(medians.df$EC_mod/2)),paste("--- ",EC_mod_percent,"%",sep=""),cex=0.6,adj=c(0,0.5))
            text(x3,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+(medians.df$OC_mod/2)),paste(OC_mod_percent,"%",sep=""),cex=0.6,adj=c(0,0.5))
            text(x4,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+(medians.df$soil_mod/2)),paste("--- ",soil_mod_percent,"%",sep=""),cex=0.6,adj=c(0,0.5))
            text(x3,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+(medians.df$NaCl_mod/2)),paste(NaCl_mod_percent,"%",sep=""),cex=0.6,adj=c(0,0.5))
            text(x4,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+medians.df$NaCl_mod+(medians.df$ncom_mod/2)),paste("--- ",ncom_mod_percent,"%",sep=""),cex=0.6,adj=c(0,0.5))
            text(x3,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+medians.df$NaCl_mod+medians.df$ncom_mod+(medians.df$other_rem_mod/2)),paste(other_rem_mod_percent,"%",sep=""),cex=0.6,adj=c(0,0.5))
            if (network == 'CSN') {
               text(x4,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$soil_mod+medians.df$NaCl_mod+medians.df$ncom_mod+medians.df$other_rem_mod+(blank_mod/2)),paste("--- ",blank_mod_percent,"%",sep=""),cex=0.6,adj=c(0,0.5))
            }
         }
      }
##########################################################################

## Put title at top of barplot ##
     title(main=pca_names[n],cex.main=1)


   }       # End PCA loop
}          # End Season loop

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

