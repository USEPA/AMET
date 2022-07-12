header <- "
############################### AE6 STACKED BAR PLOT #################################
### AMET CODE: AQ_Stacked_Barplot_AE6_ggplot.R 
###
### This code creates a stacked bar plot of PM species from the IMPROVE, CSN, SEARCH or
### AQS Daily networks using the ggplot R package. Data are then averaged for SO4, NO3, 
### NH4, EC, OC soil species, NCOM, PMother and total PM2.5. These averages are then 
### plotted as a stacked bar plot, along with the percent of the total PM2.5 that each 
### species comprises.
###
### Last updated by Wyat Appel: Jan 2021
######################################################################################
"

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

library(plotly)
library(htmlwidgets)

network <- network_names[1]
network_name <- network_label[1]
num_runs <- 1

### Retrieve units and model labels from database table ###
#units_qs <- paste("SELECT Fe from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
#model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
################################################

### Set filenames and titles ###
filename_pdf     <- paste(run_name1,pid,"stacked_barplot_AE6_ggplot.pdf",sep="_")
filename_png     <- paste(run_name1,pid,"stacked_barplot_AE6_ggplot.png",sep="_")
filename_txt	 <- paste(run_name1,pid,"stacked_barplot_AE6_ggplot_data.csv",sep="_")

## Create a full path to file
filename_pdf  <- paste(figdir,filename_pdf,sep="/")      # Set PDF filename
filename_png  <- paste(figdir,filename_png,sep="/")      # Set PNG filename
filename_txt  <- paste(figdir,filename_txt,sep="/")      # Set output file name

method <- "Mean"
if (use_median == "y") {
   method <- "Median"
}

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { 
      title <- paste(dates,sep="")
      if (clim_reg != "None") { paste(title,clim_reg,sep=", ") } 
   }
   else { title <- custom_title }
}
################################

{
   run_names       <- run_name1
   if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
      run_names <- c(run_names,run_name2)
   }
   if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
      run_names <- c(run_names,run_name3)
   }
   if ((exists("run_name4")) && (nchar(run_name4) > 0)) {
      run_names <- c(run_names,run_name4)
   }
   if ((exists("run_name5")) && (nchar(run_name5) > 0)) {
      run_names <- c(run_names,run_name5)
   }
   if ((exists("run_name6")) && (nchar(run_name6) > 0)) {
      run_names <- c(run_names,run_name6)
   }
   if ((exists("run_name7")) && (nchar(run_name7) > 0)) {
      run_names <- c(run_names,run_name7)
   }
}

axis.max	<- NULL
sinfo	       <- NULL
medians        <- NULL
data.df        <- NULL
medians_       <- NULL
data2.df       <- NULL
drop_names     <- NULL
species_names  <- NULL
species_names2 <- NULL

remove_negatives <- "n"
criteria <- paste(" WHERE d.SO4_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
#species <- c("SO4","NO3","NH4","PM_TOT","PM_FRM","EC","OC","TC","soil","NCOM","NaCl","OTHER","OTHER_REM")
species <- c("SO4","NO3","NH4","PM_TOT","EC","OC","Al","Fe","Si","Ca","Ti","Mg","Mn","K","Na","Cl","NCOM")

merge_statid_POC <- "n"
for (j in 1:length(run_names)) {
   medians.df <- NULL
   run_name <- run_names[j]
   #############################################
   ### Read sitex file or query the database ###
   #############################################
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name,species)
         aqdat_query.df   <- sitex_info$sitex_data
         data_exists      <- sitex_info$data_exists
         if (data_exists == "y") { units <- as.character(sitex_info$units[[1]]) }
      }
      else {
         query_result    <- query_dbase(run_name,network,species)
         aqdat_query.df  <- query_result[[1]]
         data_exists	 <- query_result[[2]]
         if (data_exists == "y") { units <- query_result[[3]] }
         model_name      <- query_result[[4]]
      }
   }
   #############################################
   aqdat_all.df <- aqdat_query.df
   aqdat_all.df[aqdat_all.df == -999] <- NA

   ### Calculate NH4 from NO3 and SO4 if unavailable ###
   aqdat_all.df$NH4_ob[aqdat_all.df$NH4 == -999] <- 0.2903*aqdat_all.df$NO3_ob+0.375*aqdat_all.df$SO4_ob
#   aqdat_all.df$OTHER_ob[aqdat_all.df$OTHER_ob == -999] <- aqdat_all.df$PM_TOT_ob-aqdat_all.df$SO4_ob-aqdat_all.df$NO3_ob-(0.2903*aqdat_all.df$NO3_ob+0.375*aqdat_all.df$SO4_ob)-aqdat_all.df$OC_ob-aqdat_all.df$EC_ob-aqdat_all.df$Na_ob-aqdat_all.df$Cl_ob-aqdat_all.df$Al_ob-aqdat_all.df$Ca_ob-aqdat_all.df$Fe_ob-aqdat_all.df$K_ob-aqdat_all.df$Si_ob-aqdat_all.df$Ti_ob
   aqdat_all.df$NCOM_ob <- 0.8*aqdat_all.df$OC_ob

   blank_mod  <- 0.4
   blank_mod2 <- 0.4
   blank_ob   <- 0.4
   blank_ob2  <- 0.4
   if (network == 'IMPROVE') {
      blank_mod  <- 0
      blank_ob   <- 0   
   }
  if (method == "Mean") { avg_fun <- "mean" } 
  if (method == "Median") { avg_fun <- "median" }

#   aqdat_all.df[aqdat_all.df < 0] <- NA
   aqdat_all.df <- aqdat_all.df[ -c(1,3,4,6,7,8,43,44)]
   aqdat_agg.df <- aggregate(aqdat_all.df, by=list(aqdat_all.df$stat_id,aqdat_all.df$ob_dates), FUN=avg_fun, na.rm=TRUE)
   complete_records <- complete.cases(aqdat_agg.df[,5:36])
   aqdat_sub.df <- aqdat_agg.df[complete_records,]

   ##########################################################
   ### Average all data for a species into a single value ###
   ##########################################################
#   l <- 5							# offset for first species ob value

#   aqdat_sub.df <- aqdat_agg.df
#   len <- length(aqdat_sub.df)
#   while (l < len) { 					# loop through each column
#      indic.nan <- is.nan(aqdat_sub.df[,l]) != "NaN"		# determine missing data from ob column
#      aqdat_sub.df <- aqdat_sub.df[indic.nan,]		# remove missing model/ob pairs from dataframe
#      l <- l+1
#   }  

   num_sites	<- length(unique(aqdat_sub.df$Group.1))
   num_pairs	<- length(aqdat_sub.df$Group.1)   
 
   data.df		<- aqdat_sub.df[5:length(aqdat_sub.df)]
   {
      if (use_median == "y") {
         medians.df        <- lapply(data.df,median, na.rm=TRUE)
      }
      else {
         medians.df   <- lapply(data.df,mean, na.rm=TRUE)
      }
   }
   ##############################################################

   ########################################################################################
   ### Calculate percent of total PM2.5 (without other category) each species comprises ###
   ########################################################################################
#   NCOM_ob              <- 0.8*medians.df$OC_ob
#   other_mod	        <- medians.df$OTHRIJ_mod
   other_ob	        <- medians.df$PM_TOT_ob-(medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+medians.df$Al_ob+medians.df$Ca_ob+medians.df$Fe_ob+medians.df$K_ob+medians.df$Mg_ob+medians.df$Si_ob+medians.df$Ti_ob+medians.df$Na_ob+medians.df$Cl_ob+medians.df$NCOM_ob)
   if (other_ob < 0) {
      other_ob <- 0
   }
   other_mod            <- medians.df$PM_TOT_mod-(medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$Al_mod+medians.df$Ca_mod+medians.df$Fe_mod+medians.df$K_mod+medians.df$Mg_mod+medians.df$Si_mod+medians.df$Ti_mod+medians.df$Na_mod+medians.df$Cl_mod+medians.df$NCOM_mod) 
   medians_tot_ob       <- medians.df$SO4_ob+medians.df$NO3_ob+medians.df$NH4_ob+medians.df$EC_ob+medians.df$OC_ob+medians.df$Al_ob+medians.df$Ca_ob+medians.df$Fe_ob+medians.df$K_ob+medians.df$Si_ob+medians.df$Ti_ob+medians.df$Na_ob+medians.df$Cl_ob+medians.df$NCOM_ob+other_ob
   medians_tot_mod      <- medians.df$SO4_mod+medians.df$NO3_mod+medians.df$NH4_mod+medians.df$EC_mod+medians.df$OC_mod+medians.df$Al_mod+medians.df$Ca_mod+medians.df$Fe_mod+medians.df$Si_mod+medians.df$Ti_mod+medians.df$Na_mod+medians.df$Cl_mod+medians.df$NCOM_mod+other_mod
#   total_ob            <- data.df$SO4_ob+data.df$NO3_ob+data.df$NH4_ob+data.df$EC_ob+data.df$OC_ob+data.df$soil_ob+data.df$NaCl_ob+data.df$OTHER_ob+water_ob+NCOM_ob
#   total_mod           <- data.df$SO4_mod+data.df$NO3_mod+data.df$NH4_mod+data.df$EC_mod+data.df$OC_mod+data.df$soil_mod+data.df$NaCl_mod+data.df$NCOM_mod+data.df$OTHER_REM_mod

#   medians.df$tot_ob   <- medians_tot_ob
#   medians.df$tot_mod <- medians_tot_mod

   axis.max <- max(axis.max,medians.df$PM_TOT_ob,medians.df$PM_TOT_mod)
   {
      if (j == 1) {
         NUM_SITES <- c(num_sites,num_sites)
         NUM_PAIRS <- c(num_pairs,num_pairs)
         data_out.df <- data.frame(obs_mod=network,species=c("SO4","NO3","NH4","EC","OC","Al","Ca","Fe","K","Mg","Mn","Si","Ti","Na","Cl","NCOM","OTHR"),value=c(medians.df$SO4_ob,medians.df$NO3_ob,medians.df$NH4_ob,medians.df$EC_ob,medians.df$OC_ob,medians.df$Al_ob,medians.df$Ca_ob,medians.df$Fe_ob,medians.df$K_ob,medians.df$Mg_ob,medians.df$Mn_ob,medians.df$Si_ob,medians.df$Ti_ob,medians.df$Na_ob,medians.df$Cl_ob,medians.df$NCOM_ob,other_ob))
         data_out_mod.df <- data.frame(obs_mod=paste("Sim",j,sep=""),species=c("SO4","NO3","NH4","EC","OC","Al","Ca","Fe","K","Mg","Mn","Si","Ti","Na","Cl","NCOM","OTHR"),value=c(medians.df$SO4_mod,medians.df$NO3_mod,medians.df$NH4_mod,medians.df$EC_mod,medians.df$OC_mod,medians.df$Al_mod,medians.df$Ca_mod,medians.df$Fe_mod,medians.df$K_mod,medians.df$Mg_mod,medians.df$Mn_mod,medians.df$Si_mod,medians.df$Ti_mod,medians.df$Na_mod,medians.df$Cl_mod,medians.df$NCOM_mod,other_mod))    
         data_out.df <- rbind(data_out.df,data_out_mod.df)
         sim_legend <- paste("Sim1: ",run_names[j],sep="")
      }

      else {
         NUM_SITES <- c(NUM_SITES,num_sites)
         NUM_PAIRS <- c(NUM_PAIRS,num_pairs)
         data_out_mod.df <- data.frame(obs_mod=paste("Sim",j,sep=""),species=c("SO4","NO3","NH4","EC","OC","Al","Ca","Fe","K","Mg","Mn","Si","Ti","Na","Cl","NCOM","OTHR"),value=c(medians.df$SO4_mod,medians.df$NO3_mod,medians.df$NH4_mod,medians.df$EC_mod,medians.df$OC_mod,medians.df$Al_mod,medians.df$Ca_mod,medians.df$Fe_mod,medians.df$K_mod,medians.df$Mg_mod,medians.df$Mn_mod,medians.df$Si_mod,medians.df$Ti_mod,medians.df$Na_mod,medians.df$Cl_mod,medians.df$NCOM_mod,other_mod))
         data_out.df <- rbind(data_out.df,data_out_mod.df)
         sim_legend <- paste(sim_legend,"\nSim",j,": ",run_names[j],sep="")
      }
   }
}

write.table(data_out.df,file=filename_txt,append=F,row.names=F,sep=",")      # Write raw data to csv file

data_out.df$species <- factor(data_out.df$species, levels=c("SO4","NO3","NH4","EC","OC","Al","Ca","Fe","K","Mg","Mn","Si","Ti","Na","Cl","NCOM","OTHR"))
bar_colors <- c("red","yellow","orange","grey20","black","lightblue","blue","firebrick","yellow4","green4","blue4","gray50","orange","purple","lightseagreen","pink","gray70")
axis.max <- axis.max+(0.05*j)*axis.max	# Make room at the top for simulations legend
if (length(y_axis_max) > 0) {
   axis.max <- y_axis_max
}

#pdf(file=filename_pdf,width=9,height=9)
bp <- ggplot(data_out.df, aes(x=obs_mod,y=value)) + geom_bar(aes(color=species,fill=species),stat="identity",position=position_stack(reverse=TRUE)) + scale_color_manual(values=bar_colors,guide=guide_legend(reverse=TRUE)) + scale_fill_manual(values=bar_colors,guide=guide_legend(reverse=TRUE)) + theme(panel.grid.major.x = element_blank(), panel.grid.major.y=element_line(size=.1, color="white")) + labs(title=title,x="Network / Simulation", y=paste(method," Concentration (",units,")",sep="")) + scale_y_continuous(expand=c(0,0.1), limits=c(0,axis.max), breaks = pretty(c(0,axis.max), n = 10)) + theme(axis.title.y=element_text(size=15),axis.title.x=element_blank(), plot.title=element_text(size=10, hjust=0.5), axis.text.y=element_text(size=12),axis.text.x=element_text(size=12))
#bp <- bp + annotate("text",x=1,y=axis.max,label=paste("# of Obs:",num_pairs,"\n # of Sites:",num_sites,sep=""),hjust=1)
#bp <- bp + annotation_custom(grob=textGrob(label=paste("# of Obs:",num_pairs,"\n # of Sites:",num_sites,sep=""),gp=gpar(cex=0.8), hjust=1),xmin=,xmax=2.8,ymin=axis.max,ymax=axis.max)
bp <- bp + annotate("text",-Inf,axis.max,label=sim_legend,hjust=0,vjust=1)
{
   if (num_sites != 1) {
      bp <- bp + annotate("text",Inf,axis.max,label=paste("# of Obs:",num_pairs,"\n # of Sites:",num_sites,sep=""),hjust=1,vjust=1)
   }
   else {
      bp <- bp + annotate("text",Inf,axis.max,label=paste("# of Obs:",num_pairs,"\n Site:",site,sep=""),hjust=1,vjust=1)
   }
}
bp
ggsave(filename_pdf,width=9,height=9)
#dev.off()

if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_pdf," png:",filename_png,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}

