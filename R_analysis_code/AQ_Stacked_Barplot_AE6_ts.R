header <- "
############################ AE6 STACKED BAR PLOT TIME SERIES ###########################
### AMET CODE: AQ_Stacked_Barplot_AE6_ts.R
###
### This code creates a time series stacked bar plot of PM species from the IMPROVE, CSN,
### SEARCH or AQS Daily networks using the ggplot R package. Data are averaged across sites
### for each observation period (e.g. day) for SO4, NO3, NH4, EC, OC soil species, NCOM, 
### PMother and total PM2.5. These averages are then plotted as a stacked bar plot time series.
### This script allows for a single network but multiple simulations.
###
### Last updated by Wyat Appel: June 2025 
#########################################################################################
"

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Load Required R Libraries
if(!require(plotly))              { stop("Required Package plotly was not loaded") 	}
if(!require(htmlwidgets))         { stop("Required Package htmlwidgets was not loaded") }

## Set some defaults
network 		<- network_names[1]
network_name 		<- network_label[1]
num_runs 		<- 1
method 			<- "Mean"
remove_negatives	<- "n"
x_factor 		<- network
merge_statid_POC 	<- "n"
if (use_median == "y") {
   method <- "Median"
}

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(network_name," Stacked Barplot for ",run_name1," for ",dates,sep="") }
   else { title <- custom_title }
}

## Set output filenames
filename_pdf     <- paste(run_name1,pid,"stacked_barplot_AE6_ts.pdf",sep="_")
filename_png     <- paste(run_name1,pid,"stacked_barplot_AE6_ts.png",sep="_")
filename_html	 <- paste(run_name1,pid,"stacked_barplot_AE6_ts.html",sep="_")
filename_txt	 <- paste(run_name1,pid,"stacked_barplot_AE6_data_ts.csv",sep="_")

## Create a full path to output files
filename_pdf  <- paste(figdir,filename_pdf,sep="/")      # Set PDF filename
filename_png  <- paste(figdir,filename_png,sep="/")      # Set PNG filename
filename_html  <- paste(figdir,filename_html,sep="/")
filename_txt  <- paste(figdir,filename_txt,sep="/")      # Set output file name
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

###################################
### Set variable initial values ###
###################################
axis.max	<- NULL
sinfo	       	<- NULL
medians        	<- NULL
data.df        	<- NULL
medians_       	<- NULL
data2.df       	<- NULL
drop_names     	<- NULL
species_names  	<- NULL
species_names2 	<- NULL
x_labels       	<- NULL
###################################

criteria <- paste(" WHERE d.SO4_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
species <- c("SO4","NO3","NH4","PM_TOT","EC","OC","Al","Fe","Si","Ca","Ti","Mg","K","Na","Cl","NCOM")

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
         aqdat_query.df <- aqdat_query.df[, !names(aqdat_query.df) %in% c("state")]
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

   {
      if (Sys.getenv("AMET_DB") == 'F') { aqdat_all.df <- aqdat_all.df[ -c(1,3,4,6,7,8,44)] }
      else { aqdat_all.df     <- aqdat_all.df[ -c(1,3,4,5,6,8,9,10,43,44,45,46,47)] }
   }
   aqdat_agg.df <- aggregate(aqdat_all.df, by=list(aqdat_all.df$stat_id,aqdat_all.df$ob_dates), FUN=avg_fun, na.rm=TRUE)
   complete_records <- complete.cases(aqdat_agg.df[,5:36])
   aqdat_sub.df <- aqdat_agg.df[complete_records,]
   aqdat_sub.df$OTHR_ob <- aqdat_sub.df$PM_TOT_ob-aqdat_sub.df$SO4_ob-aqdat_sub.df$NO3_ob-(0.2903*aqdat_sub.df$NO3_ob+0.375*aqdat_sub.df$SO4_ob)-aqdat_sub.df$OC_ob-aqdat_sub.df$EC_ob-aqdat_sub.df$Na_ob-aqdat_sub.df$Cl_ob-aqdat_sub.df$Al_ob-aqdat_sub.df$Ca_ob-aqdat_sub.df$Fe_ob-aqdat_sub.df$K_ob-aqdat_sub.df$Si_ob-aqdat_sub.df$Ti_ob-aqdat_sub.df$NCOM_ob
   aqdat_sub.df$OTHR_mod <- aqdat_sub.df$PM_TOT_mod-aqdat_sub.df$SO4_mod-aqdat_sub.df$NO3_mod-(0.2903*aqdat_sub.df$NO3_mod+0.375*aqdat_sub.df$SO4_mod)-aqdat_sub.df$OC_mod-aqdat_sub.df$EC_mod-aqdat_sub.df$Na_mod-aqdat_sub.df$Cl_mod-aqdat_sub.df$Al_mod-aqdat_sub.df$Ca_mod-aqdat_sub.df$Fe_mod-aqdat_sub.df$K_mod-aqdat_sub.df$Si_mod-aqdat_sub.df$Ti_mod-aqdat_sub.df$NCOM_mod
    aqdat_sub.df$OTHR_ob[aqdat_sub.df$OTHR_ob < 0] <- 0
    aqdat_sub.df$OTHR_mod[aqdat_sub.df$OTHR_mod < 0] <- 0
   data_ts.df   <- aggregate(aqdat_sub.df,by=list(aqdat_sub.df$Group.2), FUN=avg_fun,na.rm=TRUE)
   data_ts.df   <- data_ts.df[-c(2,3,4,5,38)]
   names(data_ts.df)[1] <- "ob_dates"
   num_dates <- length(unique(data_ts.df$ob_dates))
   data_ts_obs.df <- data_ts.df[-c(3,5,7,8,9,11,13,15,17,19,21,23,25,27,29,31,33,34,36)]
   names(data_ts_obs.df)[-1] <- gsub("_ob","",names(data_ts_obs.df)[-1])
   data_ts_melted_obs.df <- melt(data_ts_obs.df,id=c("ob_dates"))
   names(data_ts_melted_obs.df)[2] <- "species"
   data_ts_melted_obs.df$cat <- network

   data_ts_mod.df <- data_ts.df[-c(2,4,6,8,9,10,12,14,16,18,20,22,24,26,28,30,32,34,35)]
   names(data_ts_mod.df)[-1] <- gsub("_mod","",names(data_ts_mod.df)[-1])
   data_ts_melted_mod.df <- melt(data_ts_mod.df,id=c("ob_dates"))
   names(data_ts_melted_mod.df)[2] <- "species"
   data_ts_melted_mod.df$cat <- paste("Sim",j,sep="") 

   num_sites	<- length(unique(aqdat_sub.df$Group.1))
   num_pairs	<- length(aqdat_sub.df$Group.1)   

   {
      if (j == 1) {
         data_merged.df <- rbind(data_ts_melted_obs.df,data_ts_melted_mod.df)
         data_merged.df$value[data_merged.df$value < 0] <- 0
         NUM_SITES <- c(num_sites,num_sites)
         NUM_PAIRS <- c(num_pairs,num_pairs)
         sim_legend <- paste("Sim1: ",run_names[j],sep="") 
      }

      else {
         data_merged.df <- rbind(data_merged.df,data_ts_melted_mod.df)
         NUM_SITES <- c(NUM_SITES,num_sites)
         NUM_PAIRS <- c(NUM_PAIRS,num_pairs)
         sim_legend <- paste(sim_legend,"\nSim",j,": ",run_names[j],sep="") 
      }
   }
   x_factor <- c(x_factor,paste("Sim",j,sep=""))
}

title <- paste(title,sim_legend,sep="\n\n")

data_merged.df$species <- factor(data_merged.df$species, levels=c("SO4","NO3","NH4","EC","OC","Al","Ca","Fe","K","Mg","Si","Ti","Na","Cl","NCOM","OTHR"))
data_merged.df$cat     <- factor(data_merged.df$cat, levels=x_factor)
bar_colors <- c("red","yellow","orange","grey20","black","lightblue","blue","firebrick","yellow4","green4","gray50","orange","purple","lightseagreen","pink","gray70")

dates_uniq <- unique(data_merged.df$ob_dates)
year  <- substr(dates_uniq,3,4)
month <- substr(dates_uniq,6,7)
day   <- substr(dates_uniq,9,10)
dates_new <- paste(month,day,year,sep="/")
dates_names <- c(dates_uniq = dates_new)
names(dates_names) <- dates_uniq

options(bitmapType='cairo')

bp_temp <- ggplot(data_merged.df, aes(x=cat,y=value)) + geom_bar(aes(color=species,fill=species),stat="identity",position=position_stack(reverse=TRUE)) + facet_grid(~ob_dates,labeller=as_labeller(dates_names))
pdata <- ggplot_build(bp_temp)$data
axis.max <-  max(pdata[[1]]$ymax)

bp <- ggplot(data_merged.df, aes(x=cat,y=value,date=ob_dates)) + geom_bar(aes(color=species,fill=species),stat="identity",position=position_stack(reverse=TRUE),width=0.75) + facet_grid(~ob_dates, labeller=as_labeller(dates_names)) + scale_color_manual(values=bar_colors,guide=guide_legend(reverse=TRUE)) + scale_fill_manual(values=bar_colors,guide=guide_legend(reverse=TRUE)) + theme(strip.text.x = element_text(angle=270), panel.grid.major.x = element_blank(), panel.spacing.x=unit(0.1,"line"), panel.grid.major.y=element_line(size=.1, color="white")) + labs(title=title,x="Network / Simulation", y=paste(method," Concentration (",units,")",sep="")) + scale_y_continuous(expand=c(0,0.1), limits=c(0,axis.max), breaks = pretty(c(0,axis.max), n = 10)) + theme(axis.title.y=element_text(size=15),axis.title.x=element_blank(), plot.title=element_text(size=12, vjust=1, hjust=0.5), axis.text.y=element_text(size=12),axis.text.x=element_text(angle=90,hjust=0.5,vjust=0.5,size=10))

ggsave(filename_pdf,width=15,height=9)

axis.max <- axis.max+(0.2*j)*axis.max
bp <- ggplot(data_merged.df, aes(x=cat,y=value,date=ob_dates)) + geom_bar(aes(color=species,fill=species),stat="identity",position=position_stack(reverse=TRUE), width=0.75) + facet_grid(~ob_dates) + scale_color_manual(values=bar_colors,guide=guide_legend(reverse=TRUE)) + scale_fill_manual(values=bar_colors,guide=guide_legend(reverse=TRUE)) + theme(strip.text.x=element_blank(), panel.spacing.x = unit(0.1,"lines"), panel.grid.major.x = element_blank(), panel.grid.major.y=element_line(size=.1, color="white")) + labs(title=title,x="Network / Simulation", y=paste(method," Concentration (",units,")",sep="")) + scale_y_continuous(expand=c(0,0.1), limits=c(0,axis.max), breaks = pretty(c(0,axis.max), n = 10)) + theme(axis.title.y=element_text(size=15),axis.title.x=element_blank(), plot.title=element_text(size=12, vjust=0, hjust=0.5), axis.text.y=element_text(size=12),axis.text.x=element_text(angle=90,hjust=0.5,vjust=0.5,size=10))

bp <- ggplotly(bp,tooltip=c("species","value","cat","date")) %>%
 layout(yaxis=list(autorange=TRUE))
   
saveWidget(bp, file=filename_html,selfcontained=T)
