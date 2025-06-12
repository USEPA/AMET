header <- "
############################ MODEL TO OBS SCATTERPLOT ############################## 
### AMET CODE: R_Scatterplot_plotly.r 
###
### This script is part of the AMET-AQ system.  This script creates a single model-to-obs
### scatterplot using the R plotly package. This script will plot a single species for multiple
### networks and simulations on a single plot.  
###
### Last Updated by Wyat Appel: June 2025 
#####################################################################################
"

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")	# R directory

## Load Required R Libraries
if(!require(plotly))              { stop("Required Package plotly was not loaded") 	}
if(!require(htmlwidgets))         { stop("Required Package htmlwidgets was not loaded") }

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

## Set output file names
filename_html <- paste(run_name1,species[1],pid,"scatterplot.html",sep="_")             # Set PDF filename
filename_txt  <- paste(run_name1,species[1],pid,"scatterplot.csv",sep="_")       # Set output file name

## Create a full path to file
filename_html <- paste(figdir,filename_html,sep="/")      # Set PDF filename
filename_txt  <- paste(figdir,filename_txt,sep="/")      # Set output file name
#################################

## Set some defaults
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
main.title <- get_title(run_names,species,network_label,dates,custom_title,site=site,state=state,rpo=rpo,pca=pca,clim_reg=clim_reg)

###################################
### Set variable initial values ###
###################################
sinfo 		<- NULL
axis.max 	<- NULL
axis.min 	<- NULL
run_count 	<- 1
num_runs        <- length(run_names)
scatter_colors  <- NULL                                                                   # Set number of runs to 1
scatter_symbols <- NULL
network         <- network_names[1]
labels          <- c(network,run_names)
fig		<- NULL
###################################

### Deal with multiple networks and species ###
criteria_in <- "Default"
if (length(network_names) > 1) {
  network_query <- paste("(d.network='",network_names[1],"'",sep="")
  for (i in 2:length(network_names)) {
     network_query <- paste(network_query," or d.network='",network_names[i],"'",sep="")
  }
  network_query  <- paste(network_query,")",sep="")
  criteria_in    <- paste(" WHERE",network_query,query,sep=" ")
}
###############################################

for (k in 1:length(species)) {
   for (j in 1:num_runs) {      # For each simulation being plotted
      run_name <- run_names[j]
      if (length(network_names) > 1) {
         units_qs <- paste("SELECT ",species[k]," from project_units as d where proj_code = '",run_name,"' and ",network_query, sep="")
      }
      #############################################
      ### Read sitex file or query the database ###
      #############################################
      {
         if (Sys.getenv("AMET_DB") == 'F') {
            outdir           <- "OUTDIR"
            if (j >1) { outdir <- paste("OUTDIR",j,sep="") }
            sitex_info       <- read_sitex(Sys.getenv(outdir),network,run_name,species[k])
            aqdat_query.df   <- sitex_info$sitex_data
            data_exists   <- sitex_info$data_exists
            if (data_exists == "y") { units <- as.character(sitex_info$units[[1]]) }
         }
         else {
            query_result    <- query_dbase(run_name,network,criteria=criteria_in,species[k],orderby=c("ob_dates","ob_hour"))
            aqdat_query.df  <- query_result[[1]]
            data_exists     <- query_result[[2]]
            if (data_exists == "y") { units <- query_result[[3]] }
            model_name      <- query_result[[4]]
            units <- unique(units)
            if (is.na(units)) { units <- "NA" }
         }
      }
      ob_col_name <- paste(species[k],"_ob",sep="")
      mod_col_name <- paste(species[k],"_mod",sep="")
      #############################################
      {
         if (data_exists == "n") {
            total_networks <- (total_networks-1)
            aqdat_query.df <- "No data from file or database query."
            if (total_networks == 0) { stop("Stopping because total_networks is zero. Likely no data found for query.") }
         }
         else {
	    unique_networks <- unique(aqdat_query.df$network)
            network <- paste(unique_networks,collapse=",")
            if (averaging != "n") {
               aqdat.df <- data.frame(Network=I(aqdat_query.df$network),Stat_ID=I(aqdat_query.df$stat_id),lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,State=aqdat_query.df$state,Obs_Value=round(aqdat_query.df[[ob_col_name]],5),Mod_Value=round(aqdat_query.df[[mod_col_name]],5),Hour=aqdat_query.df$ob_hour,Start_Date=aqdat_query.df$ob_dates,Month=aqdat_query.df$month)
               {
                  if (use_avg_stats == "y") {
                     aqdat.df <- Average(aqdat.df)
                     aqdat_stats.df <- aqdat.df                               # Call Monthly_Average function in Misc_Functions.R
                  }
                  else {
                     aqdat_stats.df <- aqdat.df
                     aqdat.df <- Average(aqdat.df)
                  }
               }
            }
            else {
               aqdat.df <- aqdat_query.df
               aqdat.df <- data.frame(Network=aqdat.df$network,Stat_ID=aqdat.df$stat_id,lat=aqdat.df$lat,lon=aqdat.df$lon,State=aqdat.df$state,Obs_Value=round(aqdat.df[[ob_col_name]],5),Mod_Value=round(aqdat.df[[mod_col_name]],5),Month=aqdat.df$month)      # Create dataframe of network values to be used to create a list
               aqdat_stats.df <- aqdat.df
            }
            axis.max <- max(c(axis.max,aqdat.df$Obs_Value,aqdat.df$Mod_Value))
            #########################################################
         }      # End no data if/else statement
      }
      ##############################
      ### Write Data to CSV File ###
      ##############################
      if (!file.exists(filename_txt)) {
         write.table(run_name,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
      }
      else {
         write.table("",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
         write.table(run_name,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      }
      write.table(dates,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(network,file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
      write.table(aqdat_query.df,file=filename_txt,append=T,col.names=T,row.names=F,sep=",")
      ###############################
      aqdat.df$Sim_Name <- run_name
      {
         if (j == 1) {
            aqdat_out.df <- aqdat.df
         }
         else {
            aqdat_out.df <- rbind(aqdat_out.df, aqdat.df)
         }
      }
      scatter_colors[j]  <- plot_colors[j]
      scatter_symbols[j] <- plot_symbols[j]
   }    # End for loop for num runs
   run_count <- run_count+1
   run_name <- run_name2
#}       # End for loop for species

### Error check for no data ###
if (length(aqdat_out.df$Stat_ID) == 0) {
   stop("No data were returned from either files or database queries. Perhaps you have a error in your query setup.")
}
###############################

axis.min <- axis.max * .033

### If user sets axis maximum, compute axis minimum ###
if ((length(y_axis_max) > 0) || (length(x_axis_max) > 0)) {
   axis.max <- max(y_axis_max,x_axis_max)
   axis.min <- axis.max * 0.033

}
if ((length(y_axis_min) > 0) || (length(x_axis_min) > 0)) {
   axis.min <- min(y_axis_min,x_axis_min)
}
#######################################################
#if (is.null(img_height)) { img_height <- 1200 }
#if (is.null(img_width)) { img_width <- 1500 }
axis_max <- max(c(aqdat_out.df$Obs_Value, aqdat_out.df$Mod_Value), na.rm = TRUE)
axis_min <- 0

p <- plot_ly(data = aqdat_out.df, x=~Obs_Value,y=~Mod_Value,height=img_height,width=img_width,type='scatter',mode='markers',symbol=~Network,symbols=scatter_symbols,color=~Sim_Name,colors=scatter_colors,marker=list(size=10),text= ~paste("Simulation:",Sim_Name,"<br>Site:",Stat_ID,"<br>Network:",Network,"<br>Lat/Lon:",lat,"/",lon,"<br>State:",State,"<br>Obs:", round(Obs_Value,3), '<br>Mod:', round(Mod_Value,3))) %>%
  layout(
    shapes = list(
      list(
        type = "line",
        x0 = axis_min,
        y0 = axis_min,
        x1 = axis_max,
        y1 = axis_max,
        xref = "x",
        yref = "y",
        line = list(color = "black", dash = "solid")
      )
    ),
    xaxis = list(title = paste(species[k]," Obs (",units,")",sep="")),
    yaxis = list(title = paste(species[k]," Model (",units,")",sep="")),
    title = list(text = main.title,xanchor="center",font=list(size=20))
  )
fig[[k]] <- p
} # End species loop
### Save plot using subplot ###
num_rows 	<- c(1,1,2,2,3,3,4,4,5,5)
subplot_widths 	<- 1
subplot_heights <- 1
if (length(species) == 2) {
   subplot_widths 	<- c(0.5,0.5)
   subplot_heights	<- 1
}
if (length(species) > 2) {
   subplot_widths       <- c(0.5,0.5)
   subplot_heights      <- c(0.5,0.5)
}
fig_out <- subplot(fig,nrows=num_rows[k],widths=subplot_widths,heights=subplot_heights,titleY=T,titleX=T) %>%
	    layout(title=list(text=main.title,xanchor="center",y=.99))
saveWidget(fig_out, file=filename_html,selfcontained=T)

#saveWidget(p, file=filename_html,selfcontained=T)


