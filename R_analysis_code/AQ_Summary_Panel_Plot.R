header <- "
######################## Multipanel Plot #######################
### AMET CODE: AQ_Summary_Panel_Plot.R 
###
### This script is part of the AMET-AQ system.  This script creates
### a multipanel plot consisting of a spatial plot of either mod-ob or
### mod-mod, time series plot, histogram plot, and density scatter plot.
### These four plots are then combined into a single html plot using
### the plotly subplot function. 
###
### Created by Wyat Appel: June 2025
################################################################
"

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Load required R libraries
if(!require(ggplot2))           { stop("Required Package ggplot2 was not loaded")	}
if(!require(plotly))           	{ stop("Required Package plotly was not loaded")       	}
if(!require(htmlwidgets))	{ stop("Required Package htmlwidgets was not loaded")	}
if(!require(gridExtra))		{ stop("Required Package gridExtra was not loaded")     }

## Set output file names
filename_html <- paste(run_name1,species,pid,"summary_panel_plot.html",sep="_")     # Set output file name
filename_html <- paste(figdir,filename_html,sep="/")     # Set output file name

## Set some defaults
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
main.title 	<- get_title(run_names,species,network_label,dates,custom_title,site=site,state=state,rpo=rpo,pca=pca,clim_reg=clim_reg)
run_name 	<- run_names[1]
ob_col_name 	<- paste(species,"_ob",sep="")
mod_col_name 	<- paste(species,"_mod",sep="")
averaging 	<- 'e'
multi_run 	<- 0
if (run_name2 != "") { multi_run <- 1 }

{
   if (Sys.getenv("AMET_DB") == 'F') {
      sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_names[1],species)
      aqdat_query.df   <- sitex_info$sitex_data
      data_exists               <- sitex_info$data_exists
      aqdat_query.df$county     <- NA
      if (data_exists == "y") {
         units            <- as.character(sitex_info$units[[1]])
      }
   }
   else {
      query_result     <- query_dbase(run_name1,network_names,species)
      aqdat_query.df   <- query_result[[1]]
      data_exists    <- query_result[[2]]
      if (data_exists == "y") { units <- query_result[[3]] }
      model_name     <- query_result[[4]]
   }
   aqdat.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),State=I(aqdat_query.df$state),County=I(aqdat_query.df$county),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=aqdat_query.df[[ob_col_name]],Mod_Value=aqdat_query.df[[mod_col_name]],Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month)
   aqdat_spatial.df <- Average(aqdat.df)
}
   if (multi_run) {
      ob_col_name2 <- paste(species,"_ob2",sep="")
      mod_col_name2 <- paste(species,"_mod2",sep="")
      {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name2,species)
         aqdat_query2.df   <- sitex_info$sitex_data
      }
      else {
         query_result     <- query_dbase(run_name2,network_names,species)
         aqdat_query2.df   <- query_result[[1]]
         data_exists    <- query_result[[2]]
         if (data_exists == "y") { units <- query_result[[3]] }
         model_name     <- query_result[[4]]
      }
   }
   aqdat_query.df$date_time <- paste(aqdat_query.df$ob_dates,aqdat_query.df$ob_hour,sep="_")
   aqdat_query2.df$date_time <- paste(aqdat_query2.df$ob_dates,aqdat_query2.df$ob_hour,sep="_")
   aqdat_query2_sub.df <- aqdat_query2.df[,c("stat_id","date_time",mod_col_name)]
   aqdat_query.df <- merge(aqdat_query.df, aqdat_query2_sub.df, by=c("stat_id","date_time"), all=FALSE, suffixes=c("","2"))
   aqdat2.df <- data.frame(Network=I(aqdat_query2.df$network),Stat_ID=I(aqdat_query2.df$stat_id),State=I(aqdat_query2.df$state),County=I(aqdat_query2.df$county),lat=aqdat_query2.df$lat,lon=aqdat_query2.df$lon,Obs_Value=aqdat_query2.df[[ob_col_name]],Mod_Value=aqdat_query2.df[[mod_col_name]],Hour=aqdat_query2.df$ob_hour,Start_Date=aqdat_query2.df$ob_dates,Month=aqdat_query2.df$month)
   aqdat_spatial2.df <- Average(aqdat2.df)
   aqdat_spatial2_sub.df <- aqdat_spatial2.df[,c("Stat_ID","Mod_Value")]
   aqdat_spatial.df <- merge(aqdat_spatial.df, aqdat_spatial2_sub.df, by=c("Stat_ID"), all=FALSE, suffixes=c("","2"))
   aqdat.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),State=I(aqdat_query.df$state),County=I(aqdat_query.df$county),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=aqdat_query.df[[ob_col_name]],Mod_Value=aqdat_query.df[[mod_col_name]],Mod_Value2=aqdat_query.df[[mod_col_name2]],Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month)
}
averaging <- 'e'
Date_Hour            <- paste(aqdat.df$Start_Date," ",aqdat.df$Hour,sep="") # Create unique Date/Hour field
aqdat.df$Date_Hour   <- Date_Hour                                                    # Add Date_Hour field to dataframe
if (obs_per_day_limit > 0) {
   num_obs_value <- tapply(aqdat.df$Obs_Value,aqdat.df$Date_Hour,function(x)sum(!is.na(x)))
   drop_days <- names(num_obs_value)[num_obs_value < obs_per_day_limit]
   aqdat_new.df <- subset(aqdat.df,!(Date_Hour%in%drop_days))
   aqdat.df <- aqdat_new.df
}

num_sites <- length(unique(aqdat.df$Stat_ID))
###################################################################

Date_Hour_Factor     <- factor(aqdat.df$Date_Hour,levels=unique(aqdat.df$Date_Hour))                   # Create unique levels so tapply maintains correct time order
s <- 1
if (avg_func_name == "sum") { s <- num_sites }

### Calculate Obs and Model Means ###
Obs_Period_Mean <- mean(aqdat.df$Obs_Value)
Mod_Period_Mean <- mean(aqdat.df$Mod_Value)
Obs_Mean        <- tapply(aqdat.df$Obs_Value,Date_Hour_Factor,FUN=avg_func)
Mod_Mean        <- tapply(aqdat.df$Mod_Value,Date_Hour_Factor,FUN=avg_func)
Num_Obs         <- length(aqdat.df$Obs_Value)
Bias_Mean       <- Mod_Mean-Obs_Mean
Error_Mean      <- abs(Mod_Mean-Obs_Mean)
Corr_Mean       <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Date_Hour,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value)))
RMSE_Mean       <- by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Date_Hour,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2)))
Mod_Mean2	<- Mod_Mean
Networks	<- mean(aqdat.df$Network)
if (multi_run) {
   Mod_Period_Mean2 	<- mean(aqdat.df$Mod_Value2)
   Mod_Mean2		<- tapply(aqdat.df$Mod_Value2,Date_Hour_Factor,FUN=avg_func)
   Bias_Mean2		<- Mod_Mean2-Obs_Mean
   Error_Mean2		<- abs(Mod_Mean2-Obs_Mean)
   Corr_Mean2		<- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value2")],aqdat.df$Date_Hour,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value2)))
   RMSE_Mean2		<- by(aqdat.df[,c("Obs_Value","Mod_Value2")],aqdat.df$Date_Hour,function(dfrm)sqrt(mean((dfrm$Mod_Value2-dfrm$Obs_Value)^2)))
}
Dates           <- unique(aqdat.df$Date_Hour)
Num_Records     <- tapply(aqdat.df$Stat_ID,aqdat.df$Date_Hour,FUN = function(x) length(x))
Num_Sites       <- tapply(aqdat.df$Stat_ID,aqdat.df$Date_Hour,FUN = function(x) length(unique(x)))
data.df         <- data.frame(Dates=Dates,Obs=Obs_Mean,Mod=Mod_Mean,Num_Obs=Num_Obs,Bias_Mean=Bias_Mean,Error_Mean=Error_Mean,Corr_Mean=Corr_Mean,RMSE_Mean=RMSE_Mean,Num_Records=Num_Records,Num_Sites=Num_Sites,Network=Networks)
if (multi_run) {
   data.df <- data.frame(Dates=Dates,Obs=Obs_Mean,Mod=Mod_Mean,Mod2=Mod_Mean2,Num_Obs=Num_Obs,Bias_Mean=Bias_Mean,Bias_Mean2=Bias_Mean2,Error_Mean=Error_Mean,Error_Mean2=Error_Mean2,Corr_Mean=Corr_Mean,Corr_Mean2=Corr_Mean2,RMSE_Mean=RMSE_Mean,RMSE_Mean2=RMSE_Mean2,Num_Records=Num_Records,Num_Sites=Num_Sites,Network=Networks)
}
data.df 	<- data.df[order(as.Date(data.df$Dates, format = "%Y-%m-%d")),]
data.df         <- unique(data.df)

######################
### Histogram Plot ###
######################
aqdat.df$Network_diff_name <- paste(run_name1,aqdat.df$Network,"Bias")
p1 <- plot_ly(data = aqdat.df, x=~Obs_Value,type='histogram',alpha=0.6,name=~Network)
   p1 <- p1 %>% add_histogram(data=aqdat.df,x=~Mod_Value,name=run_name)
   p1 <- p1 %>% add_histogram(data=aqdat.df,x=~(Mod_Value-Obs_Value),name=~Network_diff_name)
   p1 <- p1 %>% layout(shapes=list(vline(0)),title=list(text=main.title,font=list(size=20),y=0.995),barmode="overlay",xaxis=list(title=list(text=paste(species," (",units,")",sep=""),standoff=5),titlefont=list(size=15),tickfont=list(size=15)),yaxis=list(title="Frequency",titlefont=list(size=15),tickfont=list(size=15)),legend=list(font=list(size=15)))
   if (multi_run) {
      aqdat.df$Network_diff_name2 <- paste(run_name2,aqdat.df$Network,"Bias")
      p1 <- p1 %>% add_histogram(data=aqdat.df,x=~Mod_Value2,name=run_name2)
      p1 <- p1 %>% add_histogram(data=aqdat.df,x=~(Mod_Value2-Obs_Value),name=~Network_diff_name2)
   }
######################

############################
### Density Scatter Plot ###
############################
axis.max <- max(c(quantile(aqdat.df$Obs_Value,quantile_max),quantile(aqdat.df$Mod_Value,quantile_max)))
axis.min <- min(aqdat.df$Obs_Value,aqdat.df$Mod_Value)
if ((length(y_axis_max) > 0) || (length(x_axis_max) > 0)) {
   axis.max <- max(y_axis_max,x_axis_max)
   axis.min <- axis.max * 0.035
}
if ((length(y_axis_min) > 0) || (length(x_axis_min) > 0)) {
   axis.min <- min(y_axis_min,x_axis_min)
}
y.x.lm <- lm(aqdat.df$Mod_Value~aqdat.df$Obs_Value)$coeff
options(bitmapType='cairo')
sp <- ggplot(aqdat.df,aes(x=Obs_Value,y=Mod_Value)) + geom_hex(bins=100) + scale_fill_gradientn(colours=c("light blue","blue","dark green","yellow","orange","red")) + geom_abline(intercept = 0, slope=1) + xlim(0,axis.max) + ylim(0,axis.max) + geom_smooth(method=lm, linetype="dashed", color="black") + labs(title=main.title,x="Obs",y="Model") + scale_y_continuous(expand=c(0,0), limits=c(0,axis.max), breaks = pretty(c(0,axis.max), n = 10)) + scale_x_continuous(expand=c(0,0), limits=c(0,axis.max), breaks = pretty(c(0,axis.max), n = 10)) + theme(legend.justification=c(1,0), legend.position='none', legend.background=element_blank(), legend.key=element_blank(), plot.title=element_text(hjust=0.5,vjust=0.5))
if (multi_run) {
   sp <- ggplot(aqdat.df,aes(x=Mod_Value,y=Mod_Value2)) + geom_hex(bins=100) + scale_fill_gradientn(colours=c("light blue","blue","dark green","yellow","orange","red")) + geom_abline(intercept = 0, slope=1) + xlim(0,axis.max) + ylim(0,axis.max) + geom_smooth(method=lm, linetype="dashed", color="black") + labs(title=main.title,x=run_name1,y=run_name2) + scale_y_continuous(expand=c(0,0), limits=c(0,axis.max), breaks = pretty(c(0,axis.max), n = 10)) + scale_x_continuous(expand=c(0,0), limits=c(0,axis.max), breaks = pretty(c(0,axis.max), n = 10)) + theme(legend.justification=c(1,0), legend.position='none', legend.background=element_blank(), legend.key=element_blank(), plot.title=element_text(hjust=0.5,vjust=0.5),axis.title.x=element_text(margin=margin(t=30)))
}
p2 <- ggplotly(sp)
########################################################

#######################
### Timeseries Plot ###
#######################
x_label 	<- "Date"
obs_label 	<- paste(network_label,collapse=", ")
Num_Sites 	<- length(unique(aqdat.df$Stat_ID))
Num_Records 	<- length(aqdat.df$Stat_ID)
xaxis 		<- list(title= x_label, automargin = TRUE,font=list(size=10),tickfont=list(size=12))
yaxis 		<- list(title=paste(species," (",units,")"),automargin=TRUE,font=list(size=10),tickfont=list(size=15))
p3 		<- plot_ly(data=data.df, x=~Dates, y=~Obs_Mean, type="scatter", width=img_width, height=img_height, mode='lines+markers', line = list(color=plot_colors[1]), marker=list(symbol='circle',color=plot_colors[1],size=10), name=obs_label, text=~paste("Name: Obs<br>Date: ",Dates,"<br>Obs value: ",round(Obs_Mean,3))) %>%  
     			layout(title=main.title,font=list(size=15),xaxis=xaxis,yaxis=yaxis,theme(plot.title=element_text(hjust=0.5,vjust=0.5)),margin=list(t=50,b=110)) %>%
		        layout(annotations=list(x=~Dates,y=~Obs_Mean,text=~Network,xanchor='left',yanchor='bottom',showarrow=FALSE,clicktoshow='onoff',visible=FALSE),plot_bgcolor='#e5ecf6')
		p3 <- add_trace(p3, x=~Dates, y=~Mod_Mean, type="scatter", name=paste(run_names[1]," (# Sites: ",Num_Sites,")",sep=""),mode='lines+markers', line = list(color='plot_colors[2]'), marker=list(symbol='circle',color=plot_colors[2]),text=~paste("Name:",run_name,"<br>Date: ",Dates,"<br>Mod value: ",round(Mod_Mean,3))) %>% 
		        layout(annotations = list(x=~Dates,y=~Mod_Mean,text=run_names[1],xanchor='left',yanchor='bottom',showarrow=FALSE,clicktoshow='onoff',visible=FALSE,font=list(color=plot_colors[2]))) 
		p3 <- add_trace(p3, x=~Dates, y=~Bias_Mean, type="scatter", name=paste(run_names[1]," Bias (# Sites: ",Num_Sites,")",sep=""),mode='lines+markers', line = list(color='plot_colors[2]'), marker=list(symbol='square-open',color=plot_colors[2]),text=~paste("Name:",run_name," Bias<br>Date: ",Dates,"<br>Bias value: ",round(Bias_Mean,3))) %>%
		        layout(annotations = list(x=~Dates,y=~Bias_Mean,text=run_names[1],xanchor='left',yanchor='bottom',showarrow=FALSE,clicktoshow='onoff',visible=FALSE,font=list(color=plot_colors[2])))
if (multi_run) {
		p3 <- add_trace(p3, x=~Dates, y=~Mod_Mean2, type="scatter", name=paste(run_names[2]," (# Sites: ",Num_Sites,")",sep=""),mode='lines+markers', line = list(color='plot_colors[3]'), marker=list(symbol='circle',color=plot_colors[3]),text=~paste("Name:",run_name2,"<br>Date: ",Dates,"<br>Mod value: ",round(Mod_Mean2,3))) %>%
		        layout(annotations = list(x=~Dates,y=~Mod_Mean,text=run_names[3],xanchor='left',yanchor='bottom',showarrow=FALSE,clicktoshow='onoff',visible=FALSE,font=list(color=plot_colors[3])))
		p3 <- add_trace(p3, x=~Dates, y=~Bias_Mean2, type="scatter", name=paste(run_names[2]," Bias (# Sites: ",Num_Sites,")",sep=""),mode='lines+markers', line = list(color='plot_colors[3]'), marker=list(symbol='square-open',color=plot_colors[3]),text=~paste("Name:",run_name2,"Diff<br>Date: ",Dates,"<br>Mod value: ",round(Bias_Mean2,3))) %>%
		        layout(annotations = list(x=~Dates,y=~Bias_Mean2,text=run_names[3],xanchor='left',yanchor='bottom',showarrow=FALSE,clicktoshow='onoff',visible=FALSE,font=list(color=plot_colors[3])))
}
#######################


####################
### Spatial Plot ###
####################
library(sf)
if(!require(maps)){stop("Required Package maps was not loaded")}
if(!require(mapdata)){stop("Required Package mapdata was not loaded")}
data_in <- data.frame(stat_id=aqdat_spatial.df$Stat_ID,lat=aqdat_spatial.df$lat,lon=aqdat_spatial.df$lon,Obs_Value=aqdat_spatial.df$Obs_Value,Mod_Value=aqdat_spatial.df$Mod_Value,plotval=(aqdat_spatial.df$Mod_Value-aqdat_spatial.df$Obs_Value),Network=aqdat_spatial.df$Network)
colorbar_name 	<- "Mean(Model-Ob)"
hovertext	<- "Model-Ob"
if (multi_run) {
   colorbar_name 	<- "Mean(Model-Model)"
   hovertext		<- paste(run_name,"-",run_name2)
   data_in <- data.frame(stat_id=aqdat_spatial.df$Stat_ID,lat=aqdat_spatial.df$lat,lon=aqdat_spatial.df$lon,Obs_Value=aqdat_spatial.df$Obs_Value,Mod_Value=aqdat_spatial.df$Mod_Value,Mod_Value2=aqdat_spatial.df$Mod_Value2,plotval=(aqdat_spatial.df$Mod_Value-aqdat_spatial.df$Mod_Value2),Network=aqdat_spatial.df$Network)
}
{
   if ((length(diff_range_min) == 0) || (length(diff_range_max) == 0)) {
      plot_range_max <- max(quantile(abs(data_in$plotval),quantile_max))
      plot_range_min <- -plot_range_max
   }
   else {
      plot_range_max <- diff_range_max
      plot_range_min <- diff_range_min
   }
}
bounds<-c(min(data_in$lat),max(data_in$lat),min(data_in$lon),max(data_in$lon))
lat_mid <- mean(range(data_in$lat))
lon_mid <- mean(range(data_in$lon))
color_palette     <- list(c(0, "violet"), list(0.15, "blue"),c(0.15, "blue"), list(0.35, "green"),c(0.35, "green"), list(0.5, "white"),c(0.5, "white"), list(0.65, "yellow"),c(0.65, "yellow"), list(0.75, "orange"),c(0.75, "orange"), list(0.85, "red"),c(0.85, "red"), list(1, "#8B0000"))
us_state  <- map_data("state")
us_county <- map_data("county")
canada    <- map_data("worldHires", "Canada")
mexico    <- map_data("worldHires", "Mexico")
world_map <- map_data("world")
world     <- st_as_sf(world_map,coords=c("long","lat"))
p4     	<- plot_ly(data=data_in,lat = ~lat, lon=~lon, marker = list(color = 'black',showscale=FALSE,size=22),mode='markers',type='scattermapbox',name=paste0('BG'))
{
   if(multi_run) {
      p4 <- p4 %>% add_trace(data=data_in,lat = ~lat, lon=~lon, marker = list(color = ~plotval,colorbar=list(title=paste0(colorbar_name,"<br>",species,"<br>",units),len=1,lenmode="fraction",x=.92),colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=TRUE,size=20),mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>",Network,": ",signif(Obs_Value,4)," ",units,"<br>",run_name,": ",signif(Mod_Value,4)," ",units,"<br>",run_name2,": ",signif(Mod_Value2,4),"<br>Metric: ",hovertext,"<br>Value: ",signif(plotval,4)," ",units,sep=""),hoverinfo='text',name=("Sites (Diff)"))
   }
   else {
      p4 <- p4 %>% add_trace(data=data_in,lat = ~lat, lon=~lon, marker = list(color = ~plotval,colorbar=list(title=paste0(colorbar_name,"<br>",species,"<br>",units),len=1,lenmode="fraction",x=.92),colorscale=color_palette,cmin=plot_range_min,cmax=plot_range_max,showscale=TRUE,size=20),mode='markers',type='scattermapbox',text=~paste("Stat_ID: ",stat_id,"<br>Network: ",Network,"<br>Lat: ",lat,"<br>Lon: ",lon,"<br>",Network,": ",signif(Obs_Value,4)," ",units,"<br>",run_name,": ",signif(Mod_Value,4)," ",units,"<br>Metric: ",hovertext,"<br>Value: ",signif(plotval,4)," ",units,sep=""),hoverinfo='text',name=("Sites (Diff)"))
   }
}
p4 <- p4 %>% layout(mapbox = list(style='open-street-map', zoom=3, domain=list(x = c(0, 1), y = c(0, 1)),center=list(lon=lon_mid,lat=lat_mid)),showlegend=TRUE)
##########################

#######################################
### Create and save multipanel plot ###
#######################################
fig <- subplot(p4,p2,p3,p1,widths=c(0.5,0.3),heights=c(0.5,0.5),nrows=2,titleY=T,titleX=T,margin=0.03)
saveWidget(fig, file=filename_html,selfcontained=T)
#######################################
