header <- "
################################ SOCCERGOAL PLOT (PLOTLY) ##############################
### AMET CODE: R_Soccerplot_plotly.R
###
### This script is part of the AMET-AQ system.  It plots a unique type of plot referred
### to as a soccergoal plot. The idea behind the soccer goal plot is that criteria 
### and goal lines are plotted in such a way as to form a soccer goal on the plot area.
### Two statistics are then plotted, Bias (NMB, FB, NMdnB) on the x-axis and error 
### (NME, FE, NMdnE) on the y-axis.  The better the performance of the model, the closer
### the plotted points will fall within the goal lines. This type of plot is used by EPA
### and other planning organizations as part of their assessment of model performance.
###
### Last updated by Wyat Appel: Jul 2026
#########################################################################################
"

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## Load Required R Libraries
if(!require(plotly))              { stop("Required Package plotly was not loaded") }
if(!require(htmlwidgets))         { stop("Required Package htmlwidgets was not loaded") }

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Set some defaults
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste("Soccergoal plot for ",run_name1," for ",dates,"; State=",state,"; Site=",site,sep="") }   
   else { title <- custom_title }
}

## Set output file names
filename_html_norm <- paste(run_name1,pid,"soccerplot_norm.html",sep="_")             # Set PDF filename
filename_html_frac <- paste(run_name1,pid,"soccerplot_frac.html",sep="_")             # Set PDF filename

## Create a full path to output files
filename_html_norm <- paste(figdir,filename_html_norm,sep="/")
filename_html_frac <- paste(figdir,filename_html_frac,sep="/")

## Initialize stats_all.df dataframe
stats_all.df <- NULL

################################
for (j in 1:length(network_names)) {	# Loop through each network
   mean_obs      <- NULL
   mean_mod      <- NULL
   nmb           <- NULL				
   nme           <- NULL
   fb            <- NULL
   fe            <- NULL
   nmdnb	 <- NULL
   nmdne	 <- NULL
   drop_names    <- NULL
   network       <- network_names[[j]]						# Set network name based on loop value
   criteria <- paste(" where d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
   
   #############################################
   ### Read sitex file or query the database ###
   #############################################
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,species)
         aqdat_query.df   <- sitex_info$sitex_data
         data_exists      <- sitex_info$data_exists
         if (data_exists == "y") { units <- as.character(sitex_info$units[[1]]) }
      }
      else {
         query_result    <- query_dbase(run_name1,network,species,rm_negs="F")
         aqdat_query.df  <- query_result[[1]]
         data_exists	 <- query_result[[2]]
         if (data_exists == "y") { units <- query_result[[3]] }
         model_name      <- query_result[[4]]
      }
   }
   #############################################
   l <- 11 
   if(Met_query) { l <- 8 }
   for (i in 1:length(species)) { 								# For each species, calculate several statistics
     data_all.df <- data.frame(network=I(aqdat_query.df$network),stat_id=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,ob_val=aqdat_query.df[,l],mod_val=aqdat_query.df[,(l+1)])	# Create properly formatted dataframe to use with DomainStats function
      good_count <- sum(!is.na(data_all.df$ob_val))		# Count the number of non-missing values
      if (good_count > 0) {					# If there are non-missing values, continue
         stats.df <- DomainStats(data_all.df,remove_negatives)		# Call DomainStats function to compute stats for the entire domain
         stats.df$Network <- network
	 stats.df$species <- species[i]
	 stats_all.df <- rbind(stats_all.df,stats.df)
	 
      }
      l   <- l+2								# Increment to next ob specie column
      i <- i+1
   }
}

####################################

plot_chars <- c(15,19,23,24,25,seq(from=0,to=14,by=1))

#############################################
########## MAKE NMB/FB SOCCERPLOTS ##########
#############################################

p <- plot_ly(data = stats_all.df, x=~Percent_Norm_Mean_Bias,y=~Percent_Norm_Mean_Err,height=img_height,width=img_width,type='scatter',mode='markers',marker=list(size=20),symbol=~species,symbols=plot_chars,color=~Network,colors=plot_colors,marker=list(size=12),legend=list(title="species"),legendshowlegend=TRUE,text= ~paste("NMB:",Percent_Norm_Mean_Bias,"<br>NME:",Percent_Norm_Mean_Err,"<br>Network:",Network,"<br>species:",species),hoverinfo='text') %>%
	layout(title=list(text=title,y=0.97),font=list(size=15),xaxis=list(title="Normalized Mean Bias (%)",dtick=10,range=c(-100,100)),yaxis=list(title="Normalized Mean Error (%)",dtick=10,range=c(0,125))) 
p <- p %>%  add_segments(x=-15,xend=-15,y=0,yend=35,line=list(dash="dash",color='red'),inherit=F,showlegend=TRUE,name="Goal") %>%
   add_segments(x=15,xend=15,y=0,yend=35,line=list(dash="dash",color='red'),inherit=F,showlegend=FALSE) %>%
   add_segments(x=-15,xend=15,y=35,yend=35,line=list(dash="dash",color='red'),inherit=F,showlegend=FALSE) %>%
   add_segments(x=-30,xend=-30,y=0,yend=50,line=list(dash="dash",color='blue'),inherit=F,showlegend=TRUE,name="Target") %>%
   add_segments(x=30,xend=30,y=0,yend=50,line=list(dash="dash",color='blue'),inherit=F,showlegend=FALSE) %>%
   add_segments(x=-30,xend=30,y=50,yend=50,line=list(dash="dash",color='blue'),inherit=F,showlegend=FALSE) %>%
   add_segments(x=-60,xend=-60,y=0,yend=75,line=list(dash="dash",color='black'),inherit=F,showlegend=TRUE,name="Acceptable") %>%
   add_segments(x=60,xend=60,y=0,yend=75,line=list(dash="dash",color='black'),inherit=F,showlegend=FALSE) %>%
   add_segments(x=-60,xend=60,y=75,yend=75,line=list(dash="dash",color='black'),inherit=F,showlegend=FALSE)

saveWidget(p, file=filename_html_norm,selfcontained=T)

p <- plot_ly(data = stats_all.df, x=~Frac_Bias,y=~Frac_Err,height=img_height,width=img_width,type='scatter',mode='markers',marker=list(size=20),symbol=~species,symbols=plot_chars,color=~Network,colors=plot_colors,marker=list(size=12),legend=list(title="species"),legendshowlegend=TRUE,text= ~paste("FB:",Frac_Bias,"<br>FE:",Frac_Err,"<br>Network:",Network,"<br>species:",species),hoverinfo='text') %>%
	layout(title=list(text=title,y=0.97),xaxis=list(title="Fractional Bias (%)",dtick=10,range=c(-100,100)),yaxis=list(title="Fractional Error (%)",dtick=10,range=c(0,125)))
p <- p %>%  add_segments(x=-15,xend=-15,y=0,yend=35,line=list(dash="dash",color='red'),inherit=F,showlegend=TRUE,name="Goal") %>%
   add_segments(x=15,xend=15,y=0,yend=35,line=list(dash="dash",color='red'),inherit=F,showlegend=FALSE) %>%
   add_segments(x=-15,xend=15,y=35,yend=35,line=list(dash="dash",color='red'),inherit=F,showlegend=FALSE) %>%
   add_segments(x=-30,xend=-30,y=0,yend=50,line=list(dash="dash",color='blue'),inherit=F,showlegend=TRUE,name="Target") %>%
   add_segments(x=30,xend=30,y=0,yend=50,line=list(dash="dash",color='blue'),inherit=F,showlegend=FALSE) %>%
   add_segments(x=-30,xend=30,y=50,yend=50,line=list(dash="dash",color='blue'),inherit=F,showlegend=FALSE) %>%
   add_segments(x=-60,xend=-60,y=0,yend=75,line=list(dash="dash",color='black'),inherit=F,showlegend=TRUE,name="Acceptable") %>%
   add_segments(x=60,xend=60,y=0,yend=75,line=list(dash="dash",color='black'),inherit=F,showlegend=FALSE) %>%
   add_segments(x=-60,xend=60,y=75,yend=75,line=list(dash="dash",color='black'),inherit=F,showlegend=FALSE)

saveWidget(p, file=filename_html_frac,selfcontained=T)
