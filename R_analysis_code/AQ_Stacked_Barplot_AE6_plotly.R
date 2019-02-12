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
filename_html    <- paste(run_name1,pid,"stacked_barplot_AE6.html",sep="_")
filename_txt	 <- paste(run_name1,pid,"stacked_barplot_AE6_data.csv",sep="_")

## Create a full path to file
filename_html <- paste(figdir,filename_html,sep="/")      # Set PDF filename
filename_txt  <- paste(figdir,filename_txt,sep="/")      # Set output file name

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
         units            <- as.character(sitex_info$units[[1]])
      }
      else {
         query_result    <- query_dbase(run_name,network,species)
         aqdat_query.df  <- query_result[[1]]
         units           <- query_result[[3]]
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
   
#   aqdat_all.df[aqdat_all.df < 0] <- NA
   aqdat_all.df <- aqdat_all.df[ -c(1,3,4,6,7,8,43,44)]
   aqdat_agg.df <- aggregate(aqdat_all.df, by=list(aqdat_all.df$stat_id,aqdat_all.df$ob_dates), FUN=mean, na.rm=TRUE)
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
   {
      if (j == 1) {
         SO4  <- c(medians.df$SO4_ob,medians.df$SO4_mod)
         NO3  <- c(medians.df$NO3_ob,medians.df$NO3_mod)
         NH4  <- c(medians.df$NH4_ob,medians.df$NH4_mod)
         EC   <- c(medians.df$EC_ob,medians.df$EC_mod)
         OC   <- c(medians.df$OC_ob,medians.df$OC_mod)
         Al   <- c(medians.df$Al_ob,medians.df$Al_mod)
         Ca   <- c(medians.df$Ca_ob,medians.df$Ca_mod)
         Fe   <- c(medians.df$Fe_ob,medians.df$Fe_mod)
         K    <- c(medians.df$K_ob,medians.df$K_mod)
         Mg   <- c(medians.df$Mg_ob,medians.df$Mg_mod)
         Mn   <- c(medians.df$Mn_ob,medians.df$Mn_mod)
         Si   <- c(medians.df$Si_ob,medians.df$Si_mod)
         Ti   <- c(medians.df$Ti_ob,medians.df$Ti_mod)
         Na   <- c(medians.df$Na_ob,medians.df$Na_mod)
         Cl   <- c(medians.df$Cl_ob,medians.df$Cl_mod)
         NCOM <- c(medians.df$NCOM_ob,medians.df$NCOM_mod)
         OTHR <- c(other_ob,other_mod)

         SO4_perc  <- c(round(100*(medians.df$SO4_ob/medians_tot_ob),1),round(100*(medians.df$SO4_mod/medians_tot_mod),1))
         NO3_perc  <- c(round(100*(medians.df$NO3_ob/medians_tot_ob),1),round(100*(medians.df$NO3_mod/medians_tot_mod),1))
         NH4_perc  <- c(round(100*(medians.df$NH4_ob/medians_tot_ob),1),round(100*(medians.df$NH4_mod/medians_tot_mod),1))
         EC_perc   <- c(round(100*(medians.df$EC_ob/medians_tot_ob),1),round(100*(medians.df$EC_mod/medians_tot_mod),1))
         OC_perc   <- c(round(100*(medians.df$OC_ob/medians_tot_ob),1),round(100*(medians.df$OC_mod/medians_tot_mod),1))
         Al_perc   <- c(round(100*(medians.df$Al_ob/medians_tot_ob),1),round(100*(medians.df$Al_mod/medians_tot_mod),1))
         Ca_perc   <- c(round(100*(medians.df$Ca_ob/medians_tot_ob),1),round(100*(medians.df$Ca_mod/medians_tot_mod),1))
         Fe_perc   <- c(round(100*(medians.df$Fe_ob/medians_tot_ob),1),round(100*(medians.df$Fe_mod/medians_tot_mod),1))
         K_perc    <- c(round(100*(medians.df$K_ob/medians_tot_ob),1),round(100*(medians.df$K_mod/medians_tot_mod),1))
         Mg_perc   <- c(round(100*(medians.df$Mg_ob/medians_tot_ob),1),round(100*(medians.df$Mg_mod/medians_tot_mod),1))
         Mn_perc   <- c(round(100*(medians.df$Mn_ob/medians_tot_ob),1),round(100*(medians.df$Mn_mod/medians_tot_mod),1))
         Si_perc   <- c(round(100*(medians.df$Si_ob/medians_tot_ob),1),round(100*(medians.df$Si_mod/medians_tot_mod),1))
         Ti_perc   <- c(round(100*(medians.df$Ti_ob/medians_tot_ob),1),round(100*(medians.df$Ti_mod/medians_tot_mod),1))
         Na_perc   <- c(round(100*(medians.df$Na_ob/medians_tot_ob),1),round(100*(medians.df$Na_mod/medians_tot_mod),1))
         Cl_perc   <- c(round(100*(medians.df$Cl_ob/medians_tot_ob),1),round(100*(medians.df$Cl_mod/medians_tot_mod),1))
         NCOM_perc <- c(round(100*(medians.df$NCOM_ob/medians_tot_ob),1),round(100*(medians.df$NCOM_mod/medians_tot_mod),1))
         OTHR_perc <- c(round(100*(other_ob/medians_tot_ob),1),round(100*(other_mod/medians_tot_mod),1))
  
         NUM_SITES <- c(num_sites,num_sites)
         NUM_PAIRS <- c(num_pairs,num_pairs)

         ob_mod <- c(network,run_name)
         catarray <- c(network,run_name)
         xform <- list(categoryorder = "array", categoryarray = catarray)
      }

      else {
         SO4  <- c(SO4,medians.df$SO4_mod)
         NO3  <- c(NO3,medians.df$NO3_mod)
         NH4  <- c(NH4,medians.df$NH4_mod)
         EC   <- c(EC,medians.df$EC_mod)
         OC   <- c(OC,medians.df$OC_mod)
         Al   <- c(Al,medians.df$Al_mod)
         Ca   <- c(Ca,medians.df$Ca_mod)
         Fe   <- c(Fe,medians.df$Fe_mod)
         K    <- c(K,medians.df$K_mod)
         Mg   <- c(Mg,medians.df$Mg_mod)
         Si   <- c(Si,medians.df$Si_mod)
         Ti   <- c(Ti,medians.df$Ti_mod)
         Na   <- c(Na,medians.df$Na_mod)
         Cl   <- c(Cl,medians.df$Cl_mod)
         NCOM <- c(NCOM,medians.df$NCOM_mod)
         OTHR <- c(OTHR,other_mod)
   
         SO4_perc  <- c(SO4_perc,round(100*(medians.df$SO4_mod/medians_tot_mod),1))
         NO3_perc  <- c(NO3_perc,round(100*(medians.df$NO3_mod/medians_tot_mod),1))
         NH4_perc  <- c(NH4_perc,round(100*(medians.df$NH4_mod/medians_tot_mod),1))
         EC_perc   <- c(EC_perc,round(100*(medians.df$EC_mod/medians_tot_mod),1))
         OC_perc   <- c(OC_perc,round(100*(medians.df$OC_mod/medians_tot_mod),1))
         Al_perc   <- c(Al_perc,round(100*(medians.df$Al_mod/medians_tot_mod),1))
         Ca_perc   <- c(Ca_perc,round(100*(medians.df$Ca_mod/medians_tot_mod),1))
         Fe_perc   <- c(Fe_perc,round(100*(medians.df$Fe_mod/medians_tot_mod),1))
         K_perc   <- c(K_perc,round(100*(medians.df$K_mod/medians_tot_mod),1))
         Mg_perc   <- c(Mg_perc,round(100*(medians.df$Mg_mod/medians_tot_mod),1))
         Si_perc   <- c(Si_perc,round(100*(medians.df$Si_mod/medians_tot_mod),1))
         Ti_perc   <- c(Ti_perc,round(100*(medians.df$Ti_mod/medians_tot_mod),1))
         Na_perc   <- c(Na_perc,round(100*(medians.df$Na_mod/medians_tot_mod),1))
         Cl_perc   <- c(Cl_perc,round(100*(medians.df$Cl_mod/medians_tot_mod),1))
         NCOM_perc <- c(NCOM_perc,round(100*(medians.df$NCOM_mod/medians_tot_mod),1))
         OTHR_perc <- c(OTHR_perc,round(100*(other_mod/medians_tot_mod),1))

         NUM_SITES <- c(NUM_SITES,num_sites)
         NUM_PAIRS <- c(NUM_PAIRS,num_pairs)

         ob_mod <- c(ob_mod,run_name)
         catarray <- c(catarray,run_name)
         xform <- list(categoryorder = "array", categoryarray = catarray)
      }
   }
}

merged.df <- data.frame(ob_mod,SO4,NO3,NH4,EC,OC,Al,Ca,Fe,K,Mg,Si,Ti,Na,Cl,NCOM,OTHR,SO4_perc,NO3_perc,NH4_perc,EC_perc,OC_perc,Al_perc,Ca_perc,Fe_perc,Si_perc,Ti_perc,NCOM_perc,OTHR_perc,NUM_SITES,NUM_PAIRS)

p <- plot_ly(data=merged.df,x=ob_mod,y=~SO4,type="bar",height=img_height,width=img_width,name="SO4",marker=list(color="red"),text=paste("% of total:",SO4_perc,"<br># of sites:",NUM_SITES,"<br># of pairs:",NUM_PAIRS)) %>%
  add_trace(y=~NO3, name="NO3", marker=list(color="yellow"), text=paste("% of total:",NO3_perc)) %>%
  add_trace(y=~NH4, name="NH4", marker=list(color="orange"), text=paste("% of total:",NH4_perc)) %>%
  add_trace(y=~EC, name="EC", marker=list(color="darkgray"), text=paste("% of total:",EC_perc)) %>%
  add_trace(y=~OC, name="OC", marker=list(color="black"), text=paste("% of total:",OC_perc)) %>%
  add_trace(y=~Al, name="Al", marker=list(color="lightblue"), text=paste("% of total:",Al_perc)) %>%
  add_trace(y=~Ca, name="Ca", marker=list(color="blue"), text=paste("% of total:",Ca_perc)) %>%
  add_trace(y=~Fe, name="Fe", marker=list(color="firebrick"), text=paste("% of total:",Fe_perc)) %>%
  add_trace(y=~K, name="K", marker=list(color="darkyellow"), text=paste("% of total:",K_perc)) %>%
  add_trace(y=~Mg, name="Mg", marker=list(color="green"), text=paste("% of total:",Mg_perc)) %>%
  add_trace(y=~Si, name="Si", marker=list(color="gray"), text=paste("% of total:",Si_perc)) %>%
  add_trace(y=~Ti, name="Ti", marker=list(color="orange"), text=paste("% of total:",Ti_perc)) %>%
  add_trace(y=~Na, name="Na", marker=list(color="purple"), text=paste("% of total:",Na_perc)) %>%
  add_trace(y=~Cl, name="Cl", marker=list(color="lightseagreen"), text=paste("% of total:",Cl_perc)) %>%
  add_trace(y=~NCOM, name="NCOM", marker=list(color="pink"), text=paste("% of total:",NCOM_perc)) %>%
  add_trace(y=~OTHR, name="Other", marker=list(color="lightgray"), text=paste("% of total:",OTHR_perc)) %>%
  layout(title=title,yaxis=list(title=paste("Species (",units,")")),barmode='stack', xaxis=xform)

saveWidget(p, file=filename_html,selfcontained=T)

