################################################################
### THIS FILE CONTAINS CODE TO DRAW A CUSTOMIZED "STACKED BAR PLOT".
### The code is interactive with the AMET_AQ system developed by
### Wyat Appel.  Data are queried from the MYSQL database for the STN
### network.  Data are then averaged for SO4, NO3, NH4, EC, OC and PM2.5
### for the model and ob values.  These averages are then plotted on
### a stacked bar plot, along with the percent of the total PM2.5
### that each specie comprises.
###
### Last updated by Wyat Appel: April, 2017 
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

network <- network_names[1]
network_name <- network_label[1]
num_runs <- 1  

### Retrieve units and model labels from database table ###
model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
model_name <- db_Query(model_name_qs,mysql)
################################################

### Set filenames and titles ###
filename_pdf    <- paste(run_name1,pid,"stacked_barplot_panel.pdf",sep="_")
filename_png    <- paste(run_name1,pid,"stacked_barplot_panel.png",sep="_")
filename_txt    <- paste(run_name1,pid,"stacked_barplot_panel_data.csv",sep="_")

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
      species_names <- c("Other","OC","EC",expression(paste(NH[4]^"  +")),expression(paste(NO[3]^"  -")),expression(paste(SO[4]^"  2-")))
      plot_cols     <- c("yellow","red","orange","black","grey","white")
      plot_cols_leg <- c("white","grey","black","orange","red","yellow")
      plot.new()
      text(x=.43,y=.95,paste(figure_names[i],season_names[i],sep=" "),cex=1.4)
      legend(x=0.04,y=0.80,species_names,fill=plot_cols_leg,cex=1,bty="o")
      mtext(run_name1,cex=0.8,side=2)
   }

for (n in 1:4) {
   for (p in 1:4) {
      medians.df     <- NULL
      data.df        <- NULL
      drop_names     <- NULL
      species_names  <- NULL
      species_names2 <- NULL
      rmse           <- NULL
      rmse_sys       <- NULL
      rmse_unsys     <- NULL
      criteria <- paste(" WHERE d.SO4_ob is not NULL and d.network='",network,"' ",season[p],pca[n],sep="")          # Set part of the MYSQL query
      qs <- paste("SELECT d.proj_code,d.network,d.stat_id,d.ob_dates,d.ob_datee,d.ob_hour,d.month,d.SO4_ob,d.SO4_mod,d.NO3_ob,d.NO3_mod,d.NH4_ob,d.NH4_mod,d.PM_TOT_ob,d.PM_TOT_mod,d.EC_ob,d.EC_mod,d.OC_ob,d.OC_mod,d.TC_ob,d.TC_mod from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")
      aqdat_all.df <- db_Query(qs,mysql)

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
   total_ob         <- medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob
   other_ob	    <- medians.df$PM_TOT_ob-total_ob   

   SO4_ob_percent   <- round(medians.df$SO4_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+other_ob)*100,0)
   NO3_ob_percent   <- round(medians.df$NO3_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+other_ob)*100,0)
   NH4_ob_percent   <- round(medians.df$NH4_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+other_ob)*100,0)
   EC_ob_percent   <- round(medians.df$EC_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+other_ob)*100,0)
   OC_ob_percent   <- round(medians.df$OC_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+other_ob)*100,0)
   Other_ob_percent <- round(other_ob/(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+other_ob)*100,0)

   total_mod        <- medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod
   other_mod        <- medians.df$PM_TOT_mod-total_mod

   SO4_mod_percent   <- round(medians.df$SO4_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+other_mod)*100,0)
   NO3_mod_percent   <- round(medians.df$NO3_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+other_mod)*100,0)
   NH4_mod_percent   <- round(medians.df$NH4_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+other_mod)*100,0)
   EC_mod_percent    <- round(medians.df$EC_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+other_mod)*100,0)
   OC_mod_percent    <- round(medians.df$OC_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+other_mod)*100,0)
   Other_mod_percent <- round(other_mod/(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+other_mod)*100,0)
   ###############################################################

   data_matrix <- matrix(c(medians.df$SO4_ob,medians.df$SO4_mod,medians.df$NO3_ob,medians.df$NO3_mod,medians.df$NH4_ob,medians.df$NH4_mod,medians.df$EC_ob,medians.df$EC_mod,medians.df$OC_ob,medians.df$OC_mod,other_ob,other_mod),byrow=T,ncol=2)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
   yaxis.max   <- round(max(c(sum(data_matrix[,1]),sum(data_matrix[,2]))),)+5                                                              # find the max of the average values to set y-axis max 
   if (length(y_axis_max) > 0) {
      yaxis.max <- y_axis_max
   }

   simulations <- paste("STN,",run_name1,sep="")

if ((n == 1) && (p == 1)) {
   write.table(paste(simulations,season[p],pca[n],sep=" "),file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
   write.table("Observed, Modeled",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
   write.table(data_matrix,file=filename_txt,append=T,col.names=F,row.names=c("SO4","NO3","NH4","EC","OC","OTHER"),sep=",")
}
else {
   write.table(paste(simulations,season[p],pca[n],sep=" "),file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
   write.table("Observed, Modeled",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
   write.table(data_matrix,file=filename_txt,append=T,col.names=F,row.names=c("SO4","NO3","NH4","EC","OC","OTHER"),sep=",")
}

########## MAKE STACKED BARPLOT: ALL SITES ##########
   barplot(data_matrix, beside=FALSE, ylab="Concentration (ug/m3)",width=0.12,ylim=c(0,yaxis.max),col=plot_cols,xpd=F,space=1.7,cex.axis=.8,cex.names=.8,cex.lab=.8, xlim=c(0,1))
   mtext(network,side=1,at=(.26),adj=0.5,cex=.6)
   mtext(model_name,side=1,at=(.58),adj=0.5,cex=.6)
   x1_adjust <- 1
   x2_adjust <- 1

   x1 <- .19
   x2 <- .19
   x3 <- .67
   x4 <- .67

#########################################################################
### Add percentage values next to each specie on the stacked bar plot ###
#########################################################################
   text(x1,(medians.df$SO4_ob/2),paste(SO4_ob_percent,"%",sep=""),cex=.75,adj=c(1,.5))
   text(x2,(medians.df$SO4_ob+(medians.df$NO3_ob/2)),paste(NO3_ob_percent,"% ---",sep=""),cex=.75,adj=c(1,.5))
   text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+(medians.df$NH4_ob/2)),paste(NH4_ob_percent,"%",sep=""),cex=.75,adj=c(1,.5))
   text(x2,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+(medians.df$EC_ob/2)),paste(EC_ob_percent,"% --",sep=""),cex=.75,adj=c(1,0))
   text(x1,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+(medians.df$OC_ob/2)),paste(OC_ob_percent,"% --",sep=""),cex=.75,adj=c(1,0))
   text(x2,(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+(other_ob/2)),paste(Other_ob_percent,"%",sep=""),cex=.75,adj=c(1,0.5))

   text(x3,(medians.df$SO4_mod/2),paste(SO4_mod_percent,"%",sep=""),cex=.75,adj=c(0,0.5))
   text(x4,(medians.df$SO4_mod+(medians.df$NO3_mod/2)),paste("--- ",NO3_mod_percent,"%",sep=""),cex=.75,adj=c(0,0.5))
   text(x3,(medians.df$SO4_mod+medians.df$NO3_mod+(medians.df$NH4_mod/2)),paste(NH4_mod_percent,"%",sep=""),cex=.75,adj=c(0,0.5))
   text(x4,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+(medians.df$EC_mod/2)),paste("--- ",EC_mod_percent,"%",sep=""),cex=.75,adj=c(0,0.5))
   text(x3,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+(medians.df$OC_mod/2)),paste(OC_mod_percent,"%",sep=""),cex=.75,adj=c(0,0.5))
   text(x4,(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+(other_mod/2)),paste("--- ",Other_mod_percent,"%",sep=""),cex=.75,adj=c(0,0.5))

##########################################################################

## Put title at top of barplot ##
title(main=pca_names[n],cex.main=1)


   }       # End PCA loop
}       # End Season loop

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

