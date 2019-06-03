################################################################
### AMET CODE: KELLY MULTISIMULATION PLOT
###
### This script is part of the AMET-AQ system. It essentially
### creates a grid plot of model NMB, NME, RMSE, MB, ME and
### correlation for a single network/species and multiple
### simulations. The grid is plotted with NOAA climate region on
### the y-axis and simulation on the x-axis. Each shaded box in the
### grid is color coded to the performance range for that particular
### region/simulation. This particular version of the code is designed
### to work for multiple simulations.
###
### Original concept and some code developed by Jim Kelly of EPA.  
###
### Last updated by Wyat Appel: May, 2019
################################################################

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")        		# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

require(reshape2)
require(data.table)
require(ggplot2)
require(RColorBrewer)

network <- network_names[1]
network_name <- network_label[1]
num_runs <- 1

### Retrieve units and model labels from database table ###
#model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
#model_name <- db_Query(model_name_qs,mysql)
################################################

################################################
## Set output names and remove existing files ##
################################################
filename_nmb    <- paste(run_name1,species,pid,"Kellyplot_NMB",sep="_")
filename_nme    <- paste(run_name1,species,pid,"Kellyplot_NME",sep="_")
filename_rmse   <- paste(run_name1,species,pid,"Kellyplot_RMSE",sep="_")
filename_mb     <- paste(run_name1,species,pid,"Kellyplot_MB",sep="_")
filename_me     <- paste(run_name1,species,pid,"Kellyplot_ME",sep="_")
filename_corr   <- paste(run_name1,species,pid,"Kellyplot_Corr",sep="_")
filename_txt    <- paste(run_name1,species,pid,"stats_data.csv",sep="_")      # Set output file name
filename_zip    <- paste(run_name1,species,pid,"Kellyplot.zip",sep="_")

## Create a full path to file
filename        <- NULL
filename[1]     <- paste(figdir,filename_nmb,sep="/")
filename[2]     <- paste(figdir,filename_nme,sep="/")
filename[5]     <- paste(figdir,filename_rmse,sep="/")
filename[3]     <- paste(figdir,filename_mb,sep="/")
filename[4]     <- paste(figdir,filename_me,sep="/")
filename[6]     <- paste(figdir,filename_corr,sep="/")
filename_txt    <- paste(figdir,filename_txt,sep="/")
filename_zip    <- paste(figdir,filename_zip,sep="/")
#################################################

method <- "Mean"
if (use_median == "y") {
   method <- "Median"
}

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(network,species,"for",dates,sep=" ") }
   else { title <- custom_title }
}
################################################

season         <- NULL
region         <- NULL
sim_labels	<- NULL
sub_title	<- paste("Sim1:",run_names[1])

### Define NOAA climate regions database queries ###
region[1] <- " and (s.state='IL' or s.state='IN' or s.state='KY' or s.state='MO' or s.state='OH' or s.state='TN' or s.state='WV')"
region[2] <- " and (s.state='IA' or s.state='MI' or s.state='MN' or s.state='WI')"
region[3] <- " and (s.state='CT' or s.state='DE' or s.state='ME' or s.state='MD' or s.state='MA' or s.state='NH' or s.state='NJ' or s.state='NY' or s.state='PA' or s.state='RI' or s.state='VT')"
region[4] <- " and (s.state='ID' or s.state='OR' or s.state='WA')"
region[5] <- " and (s.state='AR' or s.state='KS' or s.state='LA' or s.state='MS' or s.state='OK' or s.state='TX')"
region[6] <- " and (s.state='AL' or s.state='FL' or s.state='GA' or s.state='SC' or s.state='NC' or s.state='VA')"
region[7] <- " and (s.state='AZ' or s.state='CO' or s.state='NM' or s.state='UT')"
region[8] <- " and (s.state='CA' or s.state='NV')"
region[9] <- " and (s.state='MT' or s.state='NE' or s.state='ND' or s.state='SD' or s.state='WY')"

### NOAA climate region names ###
region_names <- c("Ohio Valley","Upper Midwest","Northeast","Northwest","South","Southeast","Southwest","West","NRockiesPlains")
k <- 1

### Categorize each state into a climate region ###
state2region <- data.frame(state=c("IL","IN","KY","MO","OH","TN","WV","IA","MI","MN","WI","CT","DE","ME","MD","MA","NH","NJ","NY","PA","RI","VT","ID","OR","WA","AR","KS","LA","MS","OK","TX","AL","FL","GA","SC","NC","VA","AZ","CO","NM","UT","CA","NV","MT","NE","ND","SD","WY"),reg=c("Ohio Valley","Ohio Valley","Ohio Valley","Ohio Valley","Ohio Valley","Ohio Valley","Ohio Valley","Upper Midwest","Upper Midwest","Upper Midwest","Upper Midwest","Northeast","Northeast","Northeast","Northeast","Northeast","Northeast","Northeast","Northeast","Northeast","Northeast","Northeast","Northwest","Northwest","Northwest","South","South","South","South","South","South","Southeast","Southeast","Southeast","Southeast","Southeast","Southeast","Southwest","Southwest","Southwest","Southwest","West","West","NRockiesPlains","NRockiesPlains","NRockiesPlains","NRockiesPlains","NRockiesPlains"))

### Categorize each month into a season ###
month2season <- data.frame(month=c(1,2,3,4,5,6,7,8,9,10,11,12),season = c("Winter","Winter","Spring","Spring","Spring","Summer","Summer","Summer","Fall","Fall","Fall","Winter"))

for (s in 1:length(run_names)) {
   run_name <- run_names[s]
   query_result   <- query_dbase(run_name,network,species)
   aqdat_query.df <- query_result[[1]]
   data_exists    <- query_result[[2]]
   units          <- query_result[[3]]
   model_name     <- query_result[[4]] 
   ob_col_name <- paste(species,"_ob",sep="")
   mod_col_name <- paste(species,"_mod",sep="")
   aqdat.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,month=aqdat_query.df$month,state=aqdat_query.df$state,Obs_Value=aqdat_query.df[[ob_col_name]],Mod_Value=aqdat_query.df[[mod_col_name]])
   aqdat.df$region <- state2region$reg[match(aqdat.df$state,state2region$state)]
   aqdat.df$region <- factor(aqdat.df$region, levels=c("Ohio Valley","Upper Midwest","Northeast","Northwest","South","Southeast","Southwest","West","NRockiesPlains"))

   for (r in 1:length(region_names)) {
      aqdat_sub.df <- subset(aqdat.df,aqdat.df$region == region_names[r])
      data_all.df <- data.frame(network=I(aqdat_sub.df$Network),stat_id=I(aqdat_sub.df$Stat_ID),lat=aqdat_sub.df$lat,lon=aqdat_sub.df$lon,ob_val=aqdat_sub.df$Obs_Value,mod_val=aqdat_sub.df$Mod_Value)
      stats_all.df <-try(DomainStats(data_all.df,rm_negs="T"))       # Compute stats using DomainStats function for entire domain
      {
         if (k == 1) {
            sinfo_data.df<-data.frame(NMB=stats_all.df$Percent_Norm_Mean_Bias,NME=stats_all.df$Percent_Norm_Mean_Err,MB=stats_all.df$Mean_Bias,ME=stats_all.df$Mean_Err,RMSE=stats_all.df$RMSE,COR=stats_all.df$Correlation,region=region_names[r],simulation=run_names[s])
         }
         else {
            sinfo_data_temp.df <- data.frame(NMB=stats_all.df$Percent_Norm_Mean_Bias,NME=stats_all.df$Percent_Norm_Mean_Err,MB=stats_all.df$Mean_Bias,ME=stats_all.df$Mean_Err,RMSE=stats_all.df$RMSE,COR=stats_all.df$Correlation,region=region_names[r],simulation=run_names[s])
            sinfo_data.df <- rbind(sinfo_data.df,sinfo_data_temp.df)
         }
      }
      k <- k+1
   }
   sim_labels <- c(sim_labels,paste("Sim",s,sep=""))
   if (s > 1) { sub_title <- paste(sub_title,"\n","Sim",s,": ",run_names[s],sep="") }
}

sinfo_data.df$simulation <- factor(sinfo_data.df$simulation, levels=run_names)

data_melted.df <- melt(sinfo_data.df,id=c("simulation","region"))
data_melted.df = as.data.table(data_melted.df)
data_melted.df$simulation = factor(data_melted.df$simulation, levels=run_names,labels=sim_labels)
data_melted.df$region = factor(data_melted.df$region, levels=rev(c("Northeast","Ohio Valley","Upper Midwest","Southeast","South","NRockiesPlains","Southwest","West","Northwest")))

stats <- c("NMB","NME","MB","ME","RMSE","COR")
stat_unit <- c("%","%",units,units,units,"")
for (i in 1:6) {
   stat_in <- stats[i]
   data.tmp <- data_melted.df[data_melted.df$variable == stat_in,]
   if (stat_in == "NMB") {
      nmb_max <- 100
      int     <- 20
      if (max(abs(data.tmp$value)) < 75) {
         nmb_max <- 50 
         int     <- 10
      }
      data.tmp <- binval(dt=data.tmp,mn=-nmb_max,mx=nmb_max,sp=int)
      nlab     <- data.tmp[,length(levels(fac))]
      col.rng  <- rev(brewer.pal(nlab,'RdBu'))
      col.rng[ceiling(nlab/2)] <- 'grey70'
      alp <- 1
   }
   if (stat_in == "NME") {
      nme_max <- 180
      int     <- 20
      if (max(abs(data.tmp$value)) < 125) {
         nme_max <- 90
         int     <- 10
      }
      data.tmp <- binval(dt=data.tmp,mn=0,mx=nme_max,sp=int)
      nlab     <- data.tmp[,length(levels(fac))]
      col.rng  <- rev(brewer.pal(nlab,'YlOrBr'))
      alp <- 1
   }
   if (stat_in == "MB") {
      mb.max <- max(abs(quantile(data.tmp$value,quantile_max)))
      pick.case <- as.numeric(cut(mb.max,c(0,0.1,0.15,0.35,0.5,2,3,4,5,8,100000),include.lowest=T))
      val <- c(0.1,0.2,0.4,0.5,1,2,4,5,6,8,10)
      int <- c(0.02,0.04,0.08,0.1,0.2,0.4,0.8,1,1.2,1.6,2)

      data.tmp <- binval(dt=data.tmp,mn=-val[pick.case],mx=val[pick.case],sp=int[pick.case])
      nlab     <- data.tmp[,length(levels(fac))]
      col.rng  <- rev(brewer.pal(nlab,'RdBu'))
      col.rng[ceiling(nlab/2)] <- 'grey70'
      alp <- 1
   }
   if (stat_in == "ME") {
      me.max    <- ceiling(max(data.tmp$value))
      me.min    <- floor(min(data.tmp$value))
      me.range  <- me.max-me.min
      if(me.range == 0) {
         me.range <- 1
         me.max   <- me.max+1
      }
      print(me.max)
      print(me.min)
      pick.case <- as.numeric(cut(me.range,c(0,1,2,3,4,5,6,7,8,10,12,14,20,100000),include.lowest=T))
       int <- c(0.2,0.25,0.5,0.5,0.5,0.75,1,1.5,1.5,1.5,2,3,4)
      print(pick.case)
      print(int[pick.case])
      data.tmp  <- binval(dt=data.tmp,mn=me.min,mx=me.max,sp=int[pick.case])
      nlab      <- data.tmp[,length(levels(fac))]
      col.rng   <- rev(brewer.pal(nlab,'YlOrBr'))
      alp <- 1
   }

   if (stat_in == "RMSE") {
      rmse.max  <- ceiling(max(data.tmp$value))
      rmse.min  <- floor(min(data.tmp$value))
      rmse.range <- rmse.max-rmse.min
      if(rmse.range == 0) {
         rmse.range <- 1
         rmse.max <- rmse.max+1
      }
      print(rmse.max)
      print(rmse.min)
      pick.case <- as.numeric(cut(rmse.range,c(0,1,2,3,4,5,6,7,8,10,12,14,20,30,40,50,100000),include.lowest=T))
      int <- c(0.2,0.25,0.5,0.5,0.5,0.75,1,1.5,1.5,1.5,2,3,4,5,6,7.5,10)
      print(pick.case)
      print(int[pick.case])
      data.tmp <- binval(dt=data.tmp,mn=rmse.min,mx=rmse.max+int[pick.case],sp=int[pick.case])
      nlab     <- data.tmp[,length(levels(fac))]
      col.rng  <- rev(brewer.pal(nlab,'YlOrBr'))
      alp <- 0.9
   }
   if (stat_in == "COR") {
      data.tmp <- binval(dt=data.tmp,mn=0,mx=0.9,sp=0.1)
      nlab     <- data.tmp[,length(levels(fac))]
      col.rng  <- rev(brewer.pal(nlab,'YlGnBu'))
      alp <- 0.9   
   }

   plt <- ggplot() +
     geom_tile(data=data.tmp,aes(x=simulation,y=region,fill=fac),color='black',lwd=0.3,alpha=0.8) +
     facet_wrap(~variable) +
     scale_fill_manual(values=col.rng,name=stat_unit[i],drop=F) +
     scale_x_discrete(name='',expand=c(0,0)) +
     scale_y_discrete(name='',expand=c(0,0)) +
     guides(fill = guide_legend(reverse=T)) +
     theme(strip.text=element_text(size=18),
           axis.text.y=element_text(size=16),
           axis.text.x=element_text(size=12,angle=0,hjust=0.5),
           axis.title=element_text(size=15),
           legend.text=element_text(size=15),
           legend.title=element_text(size=15),
           plot.title=element_text(size=14,hjust=0.5),
           plot.subtitle=element_text(size=6,hjust=0)) +
     labs(title=title,subtitle=sub_title)

   ggsave(plt,file=paste(filename[i],".pdf",sep=""),dpi=600,width=6.5,height=4)

   ### Convert pdf file to png file ###
   #dev.off()
   if ((ametptype == "png") || (ametptype == "both")) {
      convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename[i],".pdf"," png:",filename[i],".png",sep="")
      system(convert_command)

      if (ametptype == "png") {
         remove_command <- paste("rm ",filename[i],".pdf",sep="")
         system(remove_command)
      }
   }
}
####################################

