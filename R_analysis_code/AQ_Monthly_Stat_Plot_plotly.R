header <- "
############################# MONTHLY STAT PLOT ################################
### AMET Code: AQ_Monthly_Stat_Plot_plotly.R
###
### THIS FILE CONTAINS CODE TO DRAW CUSTOMIZED PLOT OF NMB, NME, CORRELATION,
### MB, ME, and RMSE. The script is ideally used with a long time period, 
### specifically a year.  Average monthly domain-wide statistics are calculated 
### and plotted.  NMB, NME and CORRELATION are plotted together, while MdnB, 
### MndE and RMSE are plotted together.  However, any one of the computed 
### statistics can be plotted with a small change to the script.  The script 
### works with multiple years as well.
###
### Last updated by Wyat Appel: June 2025 
#################################################################################
"

## get some environmental variables and setup some directories
ametbase	<- Sys.getenv("AMETBASE")			# base directory of AMET
ametR		<- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Load Required R Libraries
if(!require(plotly))            { stop("Required Package plotly was not loaded") }
if(!require(htmlwidgets))       { stop("Required Package htmlwidgets was not loaded") }

## Set some defaults
network		<- network_names[1]
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
main.title <- get_title(run_names,species,network_names,dates,custom_title,site=site,state=state,rpo=rpo,pca=pca,clim_reg=clim_reg)

################################################
## Set output names and remove existing files ##
################################################
filename_stats	<- paste(run_name1,species,pid,"stats.csv",sep="_")
filename_html	<- paste(run_name1,species,pid,"stats_plot.html",sep="_")

## Create a full path to file
filename_stats	<- paste(figdir,filename_stats,sep="/")
filename_html   <- paste(figdir,filename_html,sep="/")
################################################

query_in		<- query
monthly_OBS		<- NULL
monthly_Mean_OBS	<- NULL
monthly_Mean_MOD	<- NULL
monthly_Mdn_OBS		<- NULL
monthly_Mdn_MOD		<- NULL
monthly_Sum_OBS		<- NULL
monthly_Sum_MOD		<- NULL
monthly_NMB		<- NULL
monthly_NME		<- NULL
monthly_NMdnB		<- NULL
monthly_NMdnE		<- NULL
monthly_CORR		<- NULL
monthly_MB		<- NULL
monthly_ME		<- NULL
monthly_FB		<- NULL
monthly_FE		<- NULL
monthly_MdnB		<- NULL
monthly_MdnE		<- NULL
monthly_RMSE		<- NULL
monthly_median		<- NULL
monthly_diff_median	<- NULL
y.axis.min		<- NULL
y.axis.max		<- NULL
right.axis.max		<- NULL
month_labels		<- NULL

network<-network_names[[1]]                                               # Set network name
network_name<-network_label[[1]]

#######################################
### Compute total number of  months ###
#######################################
if(!exists("year_start")) { year_start <- substr(start_date,1,4) }
if(!exists("year_end")) { year_end <- substr(end_date,1,4) }
start_month     <- as.integer(substr(start_date,5,6))
end_month       <- as.integer(substr(end_date,5,6))
num_years       <- (year_end-year_start)+1
years           <- seq(year_start,year_end,by=1)
months          <- NULL
##########################################

#########################################
### Compute statistics for each month ###
#########################################
s_month <- start_month
e_month <- end_month
i <- start_month 
for (y in 1:num_years) {
   year <- years[y]
   if (num_years > 1) {   
      if (y < num_years ) {
         e_month <- 12
      }
      if (y > 1) {
         s_month <- 1
      }
      if (y == num_years) {
         e_month <- end_month
      }
   }
       
#   for (m in 1:12) {
   for (m in s_month:e_month) {
   months <- c(months,i)   
   i <- i+1
   month_labels<-c(month_labels,m)
      ###########################################
      ####        Set Initial Values         ####
      ###########################################
#      data_all.df				<- NULL
      stats_all.df				<- NULL
      stats_all.df$NUM_OBS			<- NA 
      stats_all.df$Percent_Norm_Mean_Bias	<- NA
      stats_all.df$Percent_Norm_Mean_Err	<- NA
      stats_all.df$Norm_Median_Bias		<- NA
      stats_all.df$Norm_Median_Error		<- NA
      stats_all.df$Correlation			<- NA
      stats_all.df$Frac_Bias			<- NA
      stats_all.df$Frac_Err			<- NA
      stats_all.df$Median_Bias			<- NA
      stats_all.df$Median_Error			<- NA
      stats_all.df$RMSE				<- NA
      ###########################################
      {
         if(Met_query) {
            query               <- paste(query_in,"and Month(ob_date) = ",m,sep="")
         }
         else {
            query             <- paste(query_in," and month = ",m,sep="")
         }
      }
      query_result    <- query_dbase(run_name1,network,species)
      aqdat_query.df  <- query_result[[1]]
      data_exists     <- query_result[[2]]
      if (data_exists == "y") { units <- query_result[[3]] }
      model_name      <- query_result[[4]]
      if (data_exists == "n") { stop("Stopping because data_exists is false. Likely no data found for query.") }
      ###################################################################################################################
      ### Create properly formated dataframe to be used with DomainStats function and compute stats for entire domain ###
      ###################################################################################################################
      ob_col_name <- paste(species,"_ob",sep="")
      mod_col_name <- paste(species,"_mod",sep="")
      if (length(aqdat_query.df$stat_id) > 0) {
         data_stats.df <- data.frame(network=I(aqdat_query.df$network),stat_id=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,ob_val=aqdat_query.df[[ob_col_name]],mod_val=aqdat_query.df[[mod_col_name]])
         stats_all.df 	<- try(DomainStats(data_stats.df))      # Compute stats using DomainStats function for entire domain
         mod_obs_diff 	<- data_stats.df$mod_val-data_stats.df$ob_val
      }
      monthly_OBS		<- c(monthly_OBS,stats_all.df$NUM_OBS)
      monthly_Mean_OBS		<- c(monthly_Mean_OBS, stats_all.df$MEAN_OBS)
      monthly_Mean_MOD		<- c(monthly_Mean_MOD, stats_all.df$MEAN_MOD)
      monthly_Mdn_OBS   	<- c(monthly_Mdn_OBS, stats_all.df$Median_obs)
      monthly_Mdn_MOD		<- c(monthly_Mdn_MOD, stats_all.df$Median_mod)
      monthly_Sum_OBS		<- c(monthly_Sum_OBS, stats_all.df$SUM_OBS)
      monthly_Sum_MOD		<- c(monthly_Sum_MOD, stats_all.df$SUM_MOD)
      monthly_NMB		<- c(monthly_NMB,stats_all.df$Percent_Norm_Mean_Bias)
      monthly_NME		<- c(monthly_NME,stats_all.df$Percent_Norm_Mean_Err)
      monthly_CORR		<- c(monthly_CORR,stats_all.df$Correlation)      
      monthly_MB                <- c(monthly_MB,stats_all.df$Mean_Bias)
      monthly_ME                <- c(monthly_ME,stats_all.df$Mean_Err)
      monthly_FB		<- c(monthly_FB,stats_all.df$Frac_Bias)
      monthly_FE		<- c(monthly_FE,stats_all.df$Frac_Err)
      monthly_MdnB		<- c(monthly_MdnB,stats_all.df$Median_Bias)
      monthly_MdnE		<- c(monthly_MdnE,stats_all.df$Median_Error)
      monthly_NMdnB		<- c(monthly_NMdnB,stats_all.df$Norm_Median_Bias)
      monthly_NMdnE		<- c(monthly_NMdnE,stats_all.df$Norm_Median_Error)
      monthly_RMSE		<- c(monthly_RMSE,stats_all.df$RMSE)
      monthly_median		<- c(monthly_median, signif(stats_all.df$Median_Diff,3))
      monthly_diff_median	<- c(monthly_diff_median, signif(median(mod_obs_diff),3))
      ##################################
   }
}
num_months      <- length(months)
#####################################


###########################################
### Write Stats File with Monthly Stats ###
###########################################
all_stats.df <- data.frame(Month=months, Number_of_Obs = monthly_OBS, Mean_Obs=monthly_Mean_OBS, Mean_Mod=monthly_Mean_MOD, Sum_Obs=monthly_Sum_OBS, Sum_Mod=monthly_Sum_MOD, Percent_Normalized_Mean_Bias=monthly_NMB, Percent_Normalized_Mean_Error=monthly_NME, Correlation=monthly_CORR, Mean_Bias=monthly_MB, Mean_Error=monthly_ME, Percent_Fractional_Bias=monthly_FB, Percent_Fractional_Error=monthly_FE, Median_Bias=monthly_MdnB, Median_Error=monthly_MdnE, Percent_Normalized_Median_Bias=monthly_NMdnB, Percent_Normalized_Median_Error=monthly_NMdnE, RMSE=monthly_RMSE, Median_Difference=monthly_median, Paired_Median_Difference=monthly_diff_median)

header <- c(paste("Run Name = ",run_name1,sep=""),paste("Evaluation Dates = ",dates,sep=""),paste("Species = ",species,sep=""),paste("State = ",state,sep=""),paste("Site Name = ",site,sep=""),paste("Network = ",network_name,sep=""),paste("Units = ",units,sep=""))
write.table(header, file=filename_stats, append=F, sep="," ,col.names=F, row.names=F)
write.table("",file=filename_stats, append=T, sep=",",col.names=F,row.names=F)
write.table(all_stats.df, file=filename_stats, append=T, sep=",",col.names=T,row.names=F)
###########################################

######################
### All Stats Plot ###
######################

MB_scale_max <- 10
MB_scale_ratio <- 10
if (max(abs(c(monthly_MB,monthly_ME))) < 1) { 
   MB_scale_max <- 1 
   MB_scale_ratio <- 100
}

stats_in.df <- data.frame(month=months,Num_Obs=monthly_OBS,Mean_Obs=monthly_Mean_OBS,Mean_Mod=monthly_Mean_MOD,NMB=monthly_NMB,NME=monthly_NME,CORR=monthly_CORR,MdnB=monthly_MdnB,MdnE=monthly_MdnE,RMSE=monthly_RMSE,MB=monthly_MB,ME=monthly_ME)

p <- plot_ly(data = stats_in.df, x=~month,y=~NMB,mode='lines+markers',type='scatter',name="NMB",marker=list(color="Blue",size=10),text=~paste("Month:",month,"<br>Num Obs:",Num_Obs,"<br>Obs Mean:",signif(Mean_Obs,3),"<br>Model Mean:",signif(Mean_Mod,3),"<br>NMB:",NMB,"<br>NME:",NME,"<br>MB:",signif(MB,3),"<br>ME:",signif(ME,3), '<br>Correlation:',CORR),hoverinfo='text')
p <- p %>% add_trace(data=stats_in.df, x=~month, y=~NME, marker=list(color="Red"),name="NME")
p <- p %>% add_trace(data=stats_in.df, x=~month, y=~CORR, yaxis="y3", marker=list(color="Green"),name="Correlation")
p <- p %>% add_trace(data=stats_in.df, x=~month, y=~MB, yaxis="y2", marker=list(color="Brown"),name="Mean Bias")
p <- p %>% add_trace(data=stats_in.df, x=~month, y=~ME, yaxis="y2", marker=list(color="Purple"),name="Mean Error")
p <- p %>% add_trace(data=stats_in.df, x=~month, y=~RMSE, yaxis="y2", marker=list(color="Orange"),name="RMSE")

y3 <- list(overlaying="y",side="right",title="Correlation",range=c(0,1),titlefont=list(size=20),tickfont=list(size=15))
y2 <- list(overlaying="y",side="left",anchor="free",position=0.05,title=paste("MB/ME/RMSE (",units,")",sep=""),scaleanchor='y',scaleratio=MB_scale_ratio,contraintoward="bottom",rangemode="tozero",range=c(-MB_scale_max,MB_scale_max),titlefont=list(size=20),tickfont=list(size=15))

p <- p %>% layout(plot_bgcolor='#e5ecf6',title=list(text=main.title,font=list(size=20),y=0.95),yaxis2=y2,yaxis3=y3,xaxis=list(title="Month",domain=c(0.1,1)),yaxis=list(title="NMB/NME (%)",range=c(-100,100),titlefont=list(size=20),tickfont=list(size=15)),legend=list(font=list(size=20)))
saveWidget(p, file=filename_html,selfcontained=T)
