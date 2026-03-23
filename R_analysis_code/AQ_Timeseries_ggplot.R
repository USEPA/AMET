header <- "
###################### TIME SERIES PLOT (GGPLOT Version) ##########################
### AMET CODE: AQ_Timeseries_ggplot.R
###
### This script is part of the AMET-AQ system.  It plots single timeseries for a 
### single species, single network for multiple simulations. Data are averaged across
### time and space to create single time series. The script also plots the bias, RMSE
### and correlation.
###
### Last updated by Wyat Appel: August 2025 
###################################################################################
"

## get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")			# base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

if(!require(dplyr))	{ stop("Required Package dplyr was not loaded") 	}
if(!require(tidyr))     { stop("Required Package tidyr was not loaded") 	}
if(!require(ggplot2))   { stop("Required Package ggplot2 was not loaded") 	}
if(!require(gridExtra)) { stop("Required Package gridExtra was not loaded") 	}

## Set some defaults
network 	<- network_names[1]
species 	<- species[1]
labels 		<- c(network,run_names)
num_runs 	<- length(run_names)
if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
run_names_title <- run_names
if(length(run_names)>1) {run_names_title <- "Multi-Run" }
main.title 	<- get_title(run_names_title=run_names_title,species,network_names,site=site,state=state,rpo=rpo,pca=pca,clim_reg=clim_reg,dates=dates,custom_title="")

## Set output file name
filename_txt <- paste(run_name1,species,pid,"timeseries.csv",sep="_")

## Create a full path to file
filename_txt	<- paste(figdir,filename_txt,sep="/")           # Filename for diff spatial plot

#######################
### Set NULL values ###
#######################
Obs_Mean	<- NULL
Mod_Mean	<- NULL
Obs_Period_Mean	<- NULL
Mod_Period_Mean	<- NULL
Bias_Mean	<- NULL
CORR		<- NULL
RMSE		<- NULL
Dates		<- NULL
All_Data.df	<- NULL
Num_Obs		<- NULL
ymin		<- NULL
ymax		<- NULL
bias_min        <- NULL
bias_max        <- NULL
corr_min	<- NULL
corr_max	<- NULL
rmse_max	<- NULL
rmse_min	<- NULL
x_label		<- "Date"
#######################

for (j in 1:num_runs) {	# For each simulation being plotted
   run_name <- run_names[j]
   #############################################
   ### Read sitex file or query the database ###
   #############################################
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         outdir           <- "OUTDIR" 
         if (j >1) { outdir <- paste("OUTDIR",j,sep="") }
         sitex_info       <- read_sitex(Sys.getenv(outdir),network,run_name,species) 
         aqdat_query.df   <- sitex_info$sitex_data
         data_exists	  <- sitex_info$data_exists
         if (data_exists == "y") { units <- as.character(sitex_info$units[[1]]) }
      }
      else {
         query_result    <- query_dbase(run_name,network,species,orderby=c("ob_dates","ob_hour"))
         aqdat_query.df  <- query_result[[1]]
         data_exists     <- query_result[[2]]
         if (data_exists == "y") { units <- query_result[[3]] }
         model_name	 <- query_result[[4]]
      }
   }
   #############################################
   {
      if (data_exists == "n") {
         All_Data.df <- merge(All_Data.df,paste("No Data for ",run_name,sep=""))
         num_runs <- (num_runs-1)
         if (num_runs == 0) { stop("Stopping because num_runs is zero. Likely no data found for query.") }
      }
      else {
         ob_col_name <- paste(species,"_ob",sep="")
         mod_col_name <- paste(species,"_mod",sep="")
	 aqdat.df <- data.frame(Network=aqdat_query.df$network,Stat_ID=aqdat_query.df$stat_id,lat=aqdat_query.df$lat,lon=aqdat_query.df$lon,Obs_Value=aqdat_query.df[[ob_col_name]],Mod_Value=aqdat_query.df[[mod_col_name]],Hour=aqdat_query.df$ob_hour,Start_Date=I(aqdat_query.df$ob_dates),End_Date=I(aqdat_query.df$ob_datee),Month=aqdat_query.df$month)
	 Date_Hour            <- paste(aqdat.df$Start_Date," ",aqdat.df$Hour,":00:00",sep="") # Create unique Date/Hour field
	 aqdat.df$Date_Hour   <- Date_Hour                                                    # Add Date_Hour field to dataframe
	 if (obs_per_day_limit > 0) {
            num_obs_value <- tapply(aqdat.df$Obs_Value,aqdat.df$Date_Hour,function(x)sum(!is.na(x)))
            drop_days <- names(num_obs_value)[num_obs_value < obs_per_day_limit]
            aqdat_new.df <- subset(aqdat.df,!(Date_Hour%in%drop_days))
            aqdat.df <- aqdat_new.df
         }

         if ((state != "All") && (custom_title == "")) {
            main.title      <- paste(run_name1,species,"for",network,"State:",aqdat_query.df$state[1],sep=" ")
            main.title.bias <- paste("Bias for",run_name1,species,"for",network,"Site:",site,"in",aqdat_query.df$county[1],"county,",aqdat_query.df$state[1],sep=" ")
         }
         if ((site != "All") && (custom_title == "")) {
            main.title      <- paste(run_name1,species,"for",network,"Site:",site,"in",aqdat_query.df$county[1],"county,",aqdat_query.df$state[1],sep=" ")
            main.title.bias <- paste("Bias for",run_name1,species,"for",network,"Site:",site,"in",aqdat_query.df$county[1],"county,",aqdat_query.df$state[1],sep=" ")
         }

         Date_Hour_Factor     <- factor(aqdat.df$Date_Hour,levels=unique(aqdat.df$Date_Hour))                   # Create unique levels so tapply maintains correct time order

         ### Calculate Obs and Model Means ###
         Obs_Period_Mean[[j]]	<- mean(aqdat.df$Obs_Value)
         Mod_Period_Mean[[j]]	<- mean(aqdat.df$Mod_Value)
         Obs_Mean[[j]]	<- tapply(aqdat.df$Obs_Value,Date_Hour_Factor,FUN=avg_func)
         Mod_Mean[[j]]	<- tapply(aqdat.df$Mod_Value,Date_Hour_Factor,FUN=avg_func)
         Num_Obs[[j]]         <- length(aqdat.df$Obs_Value)

         #if ((units == "kg/ha") || (units == "mm")){	# Accumulate values if using precip/dep species
	 if (any(units == "kg/ha" | units == "mm")) { # Code to run if any unit matches }
            Obs_Period_Mean[[j]] <- median(aqdat.df$Obs_Value)
            Mod_Period_Mean[[j]] <- median(aqdat.df$Mod_Value)
         }
	 if (use_var_mean == "y") {
            Obs_Mean[[j]]	<- Obs_Mean[[j]] - Obs_Period_Mean[[j]]
            Mod_Mean[[j]]	<- Mod_Mean[[j]] - Mod_Period_Mean[[j]]
         }
         Bias_Mean[[j]]	<- Mod_Mean[[j]]-Obs_Mean[[j]]
         CORR[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Date_Hour,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value)))
         RMSE[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Date_Hour,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))
         Dates[[j]]		<- as.POSIXct(unique(aqdat.df$Date_Hour),origin="1970-01-01")
         if (averaging == "ym") {
	    years                     <- substr(aqdat.df$Start_Date,1,4)
	    months                    <- substr(aqdat.df$Start_Date,6,7)
	    yearmonth                 <- paste(years,months,sep="-")
	    aqdat.df$Year		<- years
	    aqdat.df$YearMonth	<- yearmonth
	    Obs_Mean[[j]]		<- tapply(aqdat.df$Obs_Value,aqdat.df$YearMonth,FUN=avg_func)
	    Mod_Mean[[j]]		<- tapply(aqdat.df$Mod_Value,aqdat.df$YearMonth,FUN=avg_func)
	    Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
	    CORR[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$YearMonth,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value)))
	    RMSE[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$YearMonth,function(dfrm)sqrt(mean((dfrm$Mod_Value - dfrm$Obs_Value)^2))))
	    Dates[[j]]           <- as.POSIXct(paste(unique(aqdat.df$YearMonth),"-01",sep=""),origin="1970-01-01")
	    x_label              <- "Month"
	 }
	 if (averaging == "m") {
	    Obs_Mean[[j]]        <- tapply(aqdat.df$Obs_Value,aqdat.df$Month,FUN=avg_func)
	    Mod_Mean[[j]]        <- tapply(aqdat.df$Mod_Value,aqdat.df$Month,FUN=avg_func)
	    Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
	    CORR[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Month,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value)))
	    RMSE[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Month,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))
	    Dates[[j]]            <- unique(aqdat.df$Month)
	    x_label		   <- "Month"
	 }
         if (averaging == "d") {
            Obs_Mean[[j]]        <- tapply(aqdat.df$Obs_Value,aqdat.df$Start_Date,FUN=avg_func)
            Mod_Mean[[j]]        <- tapply(aqdat.df$Mod_Value,aqdat.df$Start_Date,FUN=avg_func)
            Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
            CORR[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Start_Date,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value)))
            RMSE[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Start_Date,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))
#            Dates[[j]]           <- as.POSIXct(unique(aqdat.df$Start_Date),origin="1970-01-01")
	    Dates[[j]] <- as.POSIXct(paste0(unique(aqdat.df$Start_Date), " 00:00:00"),tz = "America/New_York", format = "%Y-%m-%d %H:%M:%S")
         }
         if (averaging == "h") {
            Obs_Mean[[j]]        <- tapply(aqdat.df$Obs_Value,aqdat.df$Hour,FUN=avg_func)
            Mod_Mean[[j]]        <- tapply(aqdat.df$Mod_Value,aqdat.df$Hour,FUN=avg_func)
            Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
            CORR[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Hour,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value)))
            RMSE[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Hour,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))
            Dates[[j]]           <- unique(aqdat.df$Hour)
            x_label		   <- paste("Hour (",TIME_FORMAT,")") 
         }
         if (averaging == "a") {
            years                <- substr(aqdat.df$Start_Date,1,4)
            aqdat.df$Year        <- years
            Obs_Mean[[j]]        <- tapply(aqdat.df$Obs_Value,aqdat.df$Year,FUN=avg_func)
            Mod_Mean[[j]]        <- tapply(aqdat.df$Mod_Value,aqdat.df$Year,FUN=avg_func)
            Bias_Mean[[j]]       <- Mod_Mean[[j]]-Obs_Mean[[j]]
            CORR[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Year,function(dfrm)cor(dfrm$Obs_Value,dfrm$Mod_Value)))
            RMSE[[j]]            <- as.matrix(by(aqdat.df[,c("Obs_Value","Mod_Value")],aqdat.df$Year,function(dfrm)sqrt(mean((dfrm$Mod_Value-dfrm$Obs_Value)^2))))
            Dates[[j]]           <- unique(aqdat.df$Year)
            x_label              <- "Year"
         }
         if (j == 1) { # Set number of sites based on first run loaded (applies if runs have different number of sites)
            num_sites    <- length(unique(aqdat.df$Stat_ID))
         }
         if (num_sites == 1) {	# If only one site, CORR is calculated as NA, and therefore must be replaced with zeros to keep the code working (hack)
            CORR[[j]][is.na(CORR[[j]])] <- 0
         }
         Num_Obs[[j]]		<- length(aqdat.df$Obs_Value)
         ymin			<- min(ymin,Obs_Mean[[j]], Mod_Mean[[j]])
         ymax			<- max(ymax,Obs_Mean[[j]], Mod_Mean[[j]])
         bias_min		<- min(bias_min,Bias_Mean[[j]])
         bias_max		<- max(bias_max,Bias_Mean[[j]])
         corr_min             <- min(corr_min,CORR[[j]],na.rm=T)
         if (corr_min == "Inf") {
            corr_min <- 0
         }
         corr_max             <- max(corr_max,CORR[[j]],na.rm=T)
         if (corr_max == "-Inf") {
            corr_max <- 1
         }
         rmse_max		<- max(rmse_max,RMSE[[j]])
         rmse_min		<- min(rmse_min,RMSE[[j]])
         {
            if (j == 1) {
               col_name1		      <- paste(run_names[1],"_Obs_Average",sep="")
               col_name2               <- paste(run_names[1],"_Model_Average",sep="")
               col_name3               <- paste(run_names[1],"_Bias_Average",sep="")
               col_name4               <- paste(run_names[1],"_RMSE_Average",sep="")
               col_name5               <- paste(run_names[1],"_Corr_Average",sep="")
               All_Data.df	      <- data.frame(Date=Dates[[j]])
               All_Data.df[,col_name1] <- signif((Obs_Mean[[j]]),6)
               All_Data.df[,col_name2] <- signif((Mod_Mean[[j]]),6)
               All_Data.df[,col_name3] <- signif((Bias_Mean[[j]]),6)
               All_Data.df[,col_name4] <- signif((RMSE[[j]]),6)
               All_Data.df[,col_name5] <- signif((CORR[[j]]),3)
            }
            else {
               col_name1 <- paste(run_names[j],"_Obs_Average",sep="")
               col_name2 <- paste(run_names[j],"_Model_Average",sep="")
               col_name3 <- paste(run_names[j],"_Bias_Average",sep="")
               col_name4 <- paste(run_names[j],"_RMSE_Average",sep="")
               col_name5 <- paste(run_names[j],"_Corr_Average",sep="")
               temp.df <- data.frame(Date=Dates[[j]])
               temp.df[,col_name1] <- signif((Obs_Mean[[j]]),6)
               temp.df[,col_name2] <- signif((Mod_Mean[[j]]),6)
               temp.df[,col_name3] <- signif((Bias_Mean[[j]]),6)
               temp.df[,col_name4] <- signif((RMSE[[j]]),6)      
               temp.df[,col_name5] <- signif((CORR[[j]]),3)
               All_Data.df <- merge(All_Data.df,temp.df,by="Date",all.x=T)
            }
         }
         #####################################
      } # Close else statement
   } # Close if/else statement
} # End num_runs loop

### Stop script if no data available ###
if (length(Dates[[1]]) == 0) { stop("Stopping because length of dates was zero. Likely no data found for query.") }
########################################

### Write data to be plotted to file ###
write.table(All_Data.df,file=filename_txt,append=F,row.names=F,sep=",")      # Write raw data to csv file
########################################

prepare_combined_stat_data <- function() {
  n_runs <- length(Dates)
  
  # For each run, create a dataframe with all stats in long format
  dfs <- lapply(1:n_runs, function(k) {
    # Extract vectors for this run
    date_vec <- Dates[[k]]
    run <- run_names[k]
    
    # Combine all stats into a wide dataframe
    df_wide <- data.frame(
      run_name = run,
      date = date_vec,
      obs_value = Obs_Mean[[k]],
      mod_value = Mod_Mean[[k]],
      bias_value = Bias_Mean[[k]],
      rmse_value = RMSE[[k]],
      corr_value = CORR[[k]]
    )
    
    # Convert from wide to long format (one row per stat per date)
    df_long <- df_wide %>%
      pivot_longer(
        cols = c(obs_value, mod_value, bias_value, rmse_value, corr_value),
        names_to = "Type",
        values_to = "Value"
      )
    
    return(df_long)
  })
  
  # Combine all runs vertically
  combined_df <- bind_rows(dfs)
  
  # Optionally order factor levels
  combined_df$run_name <- factor(combined_df$run_name, levels = run_names)
  combined_df$Type <- factor(combined_df$Type, levels = c("obs_value", "mod_value", "bias_value", "rmse_value", "corr_value"))
  
  return(combined_df)
}

### Calculate some values for plot formatting ###
range		<- ymax-ymin
ymax		<- ymax+(0.3*range)
bias_range	<- bias_max-bias_min
bias_max	<- bias_max+(0.3*bias_range)
corr_range      <- corr_max-corr_min
corr_max        <- corr_max+(0.3*corr_range)
rmse_range	<- rmse_max-rmse_min
rmse_max	<- rmse_max+(0.3*rmse_range)

if (length(y_axis_max) > 0) {
   ymax		<- y_axis_max
}
if (length(y_axis_min) > 0) {
   ymin		<- y_axis_min
}
if (length(bias_y_axis_max) > 0) { 
    bias_max   <- bias_y_axis_max
}
if (length(bias_y_axis_min) > 0) {
    bias_min   <- bias_y_axis_min
}

#################################################

filename_pdf         <- paste(run_name1,species,pid,"timeseries.pdf",sep="_")              # Set output file name
filename_png         <- paste(run_name1,species,pid,"timeseries.png",sep="_")

filename_pdf         <- paste(figdir,filename_pdf,sep="/")           # Filename for obs spatial plot
filename_png         <- paste(figdir,filename_png,sep="/")           # Filename for model spatial plot

# Prepare data for Bias, RMSE, Correlation
prepare_stat_data <- function(stat_list, stat_name, y_lab, y_min, y_max) {
  n_runs <- length(stat_list)
  dfs <- lapply(1:n_runs, function(k) {
    data.frame(Date = Dates[[k]],
               Value = stat_list[[k]],
               Run = factor(run_names[k], levels=run_names),
               Stat = stat_name)
  })
  df <- bind_rows(dfs)
  df$y_min <- y_min
  df$y_max <- y_max
  df$y_lab <- y_lab
  return(df)
}

combined_df <- prepare_combined_stat_data()
obs_unique <- combined_df %>%
  filter(Type == "obs_value") %>%
  distinct(date, Value)

obs_unique$run_name 	<- network_names[1]
obs_unique$Type		<- "obs_value"
# Only model runs - exclude obs to avoid duplication
mod_only <- combined_df %>%
  filter(Type == "mod_value")
mod_only$run_name <- as.character(mod_only$run_name)

# Combine obs_unique and mod_only into one data frame
combined_mod_obs_df <- rbind(obs_unique, mod_only)

df_bias <- combined_df %>% filter(Type == "bias_value")
df_rmse <- combined_df %>% filter(Type == "rmse_value")
df_corr <- combined_df %>% filter(Type == "corr_value")

num_days <- length(unique(df_bias$date))   # Or use your main date vector

time_tick <- if (num_days < 30) {
  "1 day"
} else if (num_days < 60) {
  "2 days"
} else if (num_days < 90) {
  "3 days"
} else if (num_days < 370) {
  "1 week"
} else {
  "2 weeks"
}
one_day_secs <- (num_days/100)*(24 * 60 * 60)

legend_rows <- 1
if (num_runs > 2) { legend_rows <- 2 }

min_date <- as.POSIXct(min(obs_unique$date))
max_date <- as.POSIXct(max(obs_unique$date))

# Combine levels: observation first, then unique model runs
all_runs <- c(network_names[1], unique(mod_only$run_name))

# Set combined run_name as factor with levels in the order you want
combined_mod_obs_df$run_name <- factor(combined_mod_obs_df$run_name, levels = all_runs)

# Count unique levels
num_runs_plots <- length(levels(combined_mod_obs_df$run_name))

# Now in scale_color_manual use levels for breaks
p_model_obs <- ggplot(combined_mod_obs_df, aes(x = date, y = Value, color = run_name)) +
  geom_line(size = as.numeric(line_width)) +
  {if(inc_points == "y") geom_point()} +
  labs(title = main.title, y = paste(species, " (", units, ")", sep = ""), x = x_label) +
  scale_color_manual(
    values = plot_colors[1:num_runs_plots],    # supply colors matching levels
    breaks = levels(combined_mod_obs_df$run_name)  # breaks = factor levels
  ) +
  scale_x_datetime(date_labels = ifelse(averaging == "ym", "%b %Y", "%b %d"),
                   date_breaks = time_tick,
                   limits = c(min_date, max_date),
                   expand = expansion(mult = 0, add = one_day_secs)
  ) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        legend.position = ifelse(inc_legend == "y", "top", "none"),
        plot.title = element_text(hjust = 0.5)) +
  guides(color = guide_legend(title = NULL,nrow=legend_rows))

p_model_obs <- p_model_obs +
  annotate("text",
           x = max_date,  # x-position at max date for right alignment
           y = max(combined_mod_obs_df$Value) * 1.05,       # y = Inf for top of the plot
           label = paste("# of sites:", num_sites),
           hjust = 1,     # right justify text at x-position
           vjust = 1,   # shift slightly down from top edge
           size = 4,      # text size, adjust as needed
           fontface = "italic")

p_bias <- ggplot(df_bias, aes(x = date, y = Value, color = run_name)) +
  geom_hline(yintercept = 0, color = "black") +            # Add background line first
  geom_line(size = as.numeric(line_width), linetype = "solid") +
  {if(inc_points == 'y') geom_point()} +
  labs(title = NULL, y = paste("Bias (", units, ")", sep = ""), x = x_label) +
  scale_color_manual(values = plot_colors[2:(num_runs_plots + 1)]) +
  scale_x_datetime(date_labels = ifelse(averaging == "ym", "%b %Y", "%b %d"), 
                   date_breaks = time_tick, limits=c(min_date,max_date),expand=expansion(mult=0,add=one_day_secs)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        legend.position = ifelse(inc_legend == 'f', "top", "none")) +
  guides(color = guide_legend(title = NULL,nrow=legend_rows))

p_rmse <- ggplot(df_rmse, aes(x=date, y=Value, color=run_name)) +
  geom_line(size=as.numeric(line_width), linetype="solid") +
  {if(inc_points == 'y') geom_point()} +
  labs(title = NULL, y = paste("RMSE (", units, ")", sep = ""), x = x_label) +
  scale_color_manual(values = plot_colors[2:(num_runs_plots + 1)]) +
  scale_x_datetime(date_labels = ifelse(averaging=="ym", "%b %Y", "%b %d"), date_breaks = time_tick, limits=c(min_date,max_date),expand=expansion(mult=0,add=one_day_secs)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        legend.position = ifelse(inc_legend == 'f', "top", "none")) +
  guides(color = guide_legend(title = NULL,nrow=legend_rows))

p_corr <- ggplot(df_corr, aes(x=date, y=Value, color=run_name)) +
  geom_line(size=as.numeric(line_width), linetype="solid") +
  {if(inc_points == 'y') geom_point()} +
  scale_color_manual(values = plot_colors[2:(num_runs_plots + 1)]) +
  labs(title = NULL, y = "Correlation", x = x_label) +
  scale_x_datetime(date_labels = ifelse(averaging=="ym", "%b %Y", "%b %d"), date_breaks = time_tick, limits=c(min_date,max_date),expand=expansion(mult=0,add=one_day_secs)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        legend.position = ifelse(inc_legend == 'f', "top", "none")) +
  guides(color = guide_legend(title = NULL,nrow=legend_rows))

# Always include p_model_obs
plots_to_include <- list(p_model_obs)

# Conditionally add plots
if (inc_bias == "y") {
  plots_to_include <- c(plots_to_include, list(p_bias))
}

if (inc_rmse == "y") {
  plots_to_include <- c(plots_to_include, list(p_rmse))
}

if (inc_corr == "y") {
  plots_to_include <- c(plots_to_include, list(p_corr))
}

### Output to pdf
# Calculate PDF height dynamically, e.g., 5 inches per plot (adjust as needed)
plot_height_per_plot <- 5
#plot_width_per_plot <- 20
#pdf_width <- plot_width_per_plot - 3*((length(plots_to_include))-1)
pdf_height <- plot_height_per_plot * length(plots_to_include)
pdf(filename_pdf, width=15, height=pdf_height)
do.call(grid.arrange, c(plots_to_include,ncol=1))
dev.off()

#######################
### Create PNG Plot ###
#######################
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_pdf," png:",filename_png,sep="")
   system(convert_command)
    if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}

