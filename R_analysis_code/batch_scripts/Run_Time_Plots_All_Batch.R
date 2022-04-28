ametbase      	 <- Sys.getenv("AMETBASE")
dbase            <- Sys.getenv("AMET_DATABASE")
out_dir		 <- Sys.getenv("AMET_OUT")
ametRinput       <- Sys.getenv("AMETRINPUT")
config_file      <- Sys.getenv("MYSQL_CONFIG")                   # MySQL configuration file
ametR            <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

source(ametRinput)
source(config_file)
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}
mysql <- list(login=amet_login, passwd=amet_pass, server=mysql_server, dbase=dbase, maxrec=maxrec)           # Set MYSQL login and query options

###################################
### Does not need to be changed ###
###################################
states			<- c("All")
#states             <- c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")
#states             <- c("AZ","CA","CO","ID","IA","KS","MT","NE","NV","NM","ND","OK","OR","SD","TX","UT","WA","WY") # Western States
###################################

######################################
####### Configuration Options ########
######################################
run_name1		<- Sys.getenv("AMET_PROJECT")	# AMET project name
run_name2		<- Sys.getenv("AMET_PROJECT2")	# Additional run to include on plot 

### These options are set in run_info file but setting here will override that setting ###
#start_date		<- "20060101"				# Set the start date of the analysis
#end_date		<- "20061231"				# Set the end date of the analysis
#batch_query		<- c("month=1 or month=2 or month=3 or month=4 or month=5 or month=6 or month=7 or month=8 or month=9 or month=10 or month=11 or month=12")
#batch_names		<- c("All")
#hourly_ozone_analysis	<- 'y'					# Flag to include hourly ozone analysis
#daily_ozone_analysis	<- 'y'					# Flag to include daily ozone analysis
#aerosol_analysis	<- 'y'					# Flag to include aerosol analysis
#dep_analysis      	<- 'y'					# Flag to include analysis of deposition performance
#gas_analysis      	<- 'y'					# Flag to include gas analysis

#ozone_averaging         <- 'n'  # Flag to average ozone data; options are n (none), d (daily), m (month), s (season), y (all)           
#aerosol_averaging       <- 'n'  # Flag to average aerosol data; options are n (none), d (daily), m (month), s (season), y (all)
#deposition_averaging    <- 'n'  # Flag to sum deposition data; options are n (none), d (daily), m (month), s (season), y (all)
#gas_averaging           <- 'n'  # Flag to average gas data; options are n (none), d (daily), m (month), s (season), y (all)

#######################################

#####################
### Other Options ###
#####################

### Custom Title ###
custom_title <- ""
##############################

### Set default value for by_site flag ###
if(!exists("by_site")) { 
   print("by_site flag not set. Defaulting to n. Set by_site flag in config file to create plots by individual site id.")
   by_site <- "n" 
}
if ((by_site == 'T') || (by_site == "t") || (by_site == "Y")) { by_site <- "y" }


### Main Database Query String. ###
query_string<-paste(" and s.stat_id=d.stat_id and d.ob_dates >=",start_date,"and d.ob_datee <=",end_date,additional_query,sep=" ")
query_string2<-paste(" and d.ob_dates >=",start_date,"and d.ob_datee <=",end_date,additional_query,sep=" ")

### Set and create output directory ###
#out_dir 		<- paste(out_dir,"time_plots",sep="/")
mkdir_main_command      <- paste("mkdir -p",out_dir,sep=" ")
system(mkdir_main_command)      # This will create a subdirectory with the name of the project
#######################################

run_script_command1 <- paste(ametbase,"/R_analysis_code/AQ_Timeseries.R",sep="")
run_script_command2 <- paste(ametbase,"/R_analysis_code/AQ_Temporal_Plots.R",sep="")
run_script_command3 <- paste(ametbase,"/R_analysis_code/AQ_Boxplot.R",sep="")
run_script_command4 <- paste(ametbase,"/R_analysis_code/AQ_Boxplot_Roselle.R",sep="")
run_script_command5 <- paste(ametbase,"/R_analysis_code/AQ_Monthly_Stat_Plot.R",sep="")
run_script_command6 <- paste(ametbase,"/R_analysis_code/AQ_Boxplot_Hourly.R",sep="")
run_script_command7 <- paste(ametbase,"/R_analysis_code/AQ_Timeseries_MtoM.R",sep="")
run_script_command8 <- paste(ametbase,"/R_analysis_code/AQ_Timeseries_plotly.R",sep="")
run_script_command9 <- paste(ametbase,"/R_analysis_code/AQ_Boxplot_plotly.R",sep="")
run_script_command10 <- paste(ametbase,"/R_analysis_code/AQ_Boxplot_ggplot.R",sep="")

#######################################################################################
### This portion of the code will create monthly stat plots for the various species ###
#######################################################################################
if (hourly_ozone_analysis == 'y') {
   averaging <- ozone_averaging
   for (m in 1:length(batch_query)) {
      network_names_list  <- c("AQS_Hourly","CASTNET_Hourly")
      network_label_list  <- c("AQS_Hourly","CASTNET_Hourly")
      for (i in 1:length(network_names_list)) {
         species	<- "O3"
         figdir         <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command 	<- paste("mkdir -p",figdir)
         dates 		<- batch_names[m]
         network_names	<- network_names_list[i]
         network_label 	<- network_label_list[i]
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         sites <- "All"
         if (by_site == 'y') {
            qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
            print(qs)
            sites.df <- db_Query(qs,mysql)
            sites    <- sites.df$stat_id
            print(sites)
            if (length(sites) == 0) { sites <- "All" }
         }
         for (s in 1:length(sites)) {
            if (sites[s] != "All") {
               pid   <- paste(network_label,sites[s],sep="_")
               query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
               site  <- sites[s]
            }
            if (timeseries_plot	== 'y') { 
               system(mkdir_command)
               try(source(run_script_command1))
               try(source(run_script_command8))
            }
            if (temporal_plot	== 'y') { 
               system(mkdir_command)
               try(source(run_script_command2)) 
            }
            if (box_plot		== 'y') { 
               system(mkdir_command)
   	       try(source(run_script_command3)) 
               try(source(run_script_command9))
               try(source(run_script_command10))
            }
            if (box_plot_roselle   == 'y') { 
               system(mkdir_command)
               try(source(run_script_command4)) 
            }
            if (monthly_stat_plot	== 'y') { 
               system(mkdir_command)
	       try(source(run_script_command5)) 
            }
            if (box_plot_hourly	== 'y') {
               system(mkdir_command)
               try(source(run_script_command6)) 
            }
            if ((timeseries_mtom    == 'y') && (exists("run_name2")) && (nchar(run_name2) > 0)) {
               system(mkdir_command)
               try(source(run_script_command7)) 
            }  
         }
      }
   }
}
if (daily_ozone_analysis == 'y') {  
   averaging <- ozone_averaging
   species_list 	<- c("O3_1hrmax","O3_8hrmax")
   network_names_list	<- c("AQS_Daily_O3","CASTNET_Daily")
   network_label_list	<- c("AQS_Daily","CASTNET_Daily")
   for (m in 1:length(batch_query)) {
      for (n in 1:length(network_names_list)) {
         network_names <- network_names_list[n]
         network_label <- network_label_list[n]
         for (i in 1:length(species_list)) {
            species	<- species_list[i]
            figdir                 <- paste(out_dir,species,sep="/")
            if (batch_names[m] != "None") {
               figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
            }
            mkdir_command 	<- paste("mkdir -p",figdir)
            dates 		<- batch_names[m]
#            network_names 	<- c("AQS_Daily_O3")
#            network_label 	<- c("AQS_Daily")
            pid		<- network_label
            query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
            sites <- "All"
            if (by_site == 'y') {
               qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
               sites.df <- db_Query(qs,mysql)
               sites    <- sites.df$stat_id
               if (length(sites) == 0) { sites <- "All" }
            }
            for (s in 1:length(sites)) {
               if (sites[s] != "All") {
                  pid   <- paste(network_label,sites[s],sep="_")
                  query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
                  site  <- sites[s]
               }
               if (timeseries_plot    == 'y') {
                  system(mkdir_command)
                  try(source(run_script_command1))
                  try(source(run_script_command8))
               }
               if (temporal_plot      == 'y') {
                  system(mkdir_command)
                  try(source(run_script_command2))
               }
               if (box_plot           == 'y') {
                  system(mkdir_command)
                  try(source(run_script_command3))
                  try(source(run_script_command9))
                  try(source(run_script_command10))
               }
               if (box_plot_roselle   == 'y') {
                  system(mkdir_command)
                  try(source(run_script_command4))
               }
               if (monthly_stat_plot  == 'y') {
                  system(mkdir_command)
                  try(source(run_script_command5))
               }
               if ((timeseries_mtom    == 'y') && (exists("run_name2")) && (nchar(run_name2) > 0)) {
                  system(mkdir_command)
                  try(source(run_script_command7))
               }
            }
         }        
      }
   }
}

if (aerosol_analysis == 'y') {
   averaging <- aerosol_averaging
   for (m in 1:length(batch_query)) {
      species_list <- c("SO4","NO3","EC","OC","TC","PM_TOT")
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         dates 		<- batch_names[m]
         figdir         <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command 	<- paste("mkdir -p",figdir)
         network_names 	<- c("IMPROVE")
         network_label 	<- c("IMPROVE")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         sites <- "All"
         if (by_site == 'y') {
            qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
            sites.df <- db_Query(qs,mysql)
            sites    <- sites.df$stat_id
            if (length(sites) == 0) { sites <- "All" }
         }
         for (s in 1:length(sites)) {
            if (sites[s] != "All") {
               pid   <- paste(network_label,sites[s],sep="_")
               query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
               site  <- sites[s]
            }
            if (timeseries_plot    == 'y') {
               system(mkdir_command)
               try(source(run_script_command1))
               try(source(run_script_command8))
            }
            if (temporal_plot      == 'y') {
               system(mkdir_command)
               try(source(run_script_command2))
            }
            if (box_plot           == 'y') {
               system(mkdir_command)
                try(source(run_script_command3))
                try(source(run_script_command9))
                try(source(run_script_command10))
            }
            if (box_plot_roselle   == 'y') {
               system(mkdir_command)
               try(source(run_script_command4))
            }
            if (monthly_stat_plot  == 'y') {
               system(mkdir_command)
               try(source(run_script_command5))
            }
            if ((timeseries_mtom    == 'y') && (exists("run_name2")) && (nchar(run_name2) > 0)) {
               system(mkdir_command)
               try(source(run_script_command7))
            }
         }
      }
   }
   for (m in 1:length(batch_query)) {
      species_list <- c("SO4","NO3","NH4","EC","OC","TC","PM_TOT")
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command 	<- paste("mkdir -p",figdir)
         dates 		<- batch_names[m]
         network_names 	<- c("CSN")
         network_label 	<- c("CSN")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         sites <- "All"
         if (by_site == 'y') {
            qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
            sites.df <- db_Query(qs,mysql)
            sites    <- sites.df$stat_id
            if (length(sites) == 0) { sites <- "All" }
         }
         for (s in 1:length(sites)) {
            if (sites[s] != "All") {
               pid   <- paste(network_label,sites[s],sep="_")
               query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
               site  <- sites[s]
            }
            if (timeseries_plot    == 'y') {
               system(mkdir_command)
               try(source(run_script_command1))
               try(source(run_script_command8))
            }
            if (temporal_plot      == 'y') {
               system(mkdir_command)
               try(source(run_script_command2))
            }
            if (box_plot           == 'y') {
               system(mkdir_command)
               try(source(run_script_command3))
               try(source(run_script_command9))
               try(source(run_script_command10))
            }
            if (box_plot_roselle   == 'y') {
               system(mkdir_command)
               try(source(run_script_command4))
            }
            if (monthly_stat_plot  == 'y') {
               system(mkdir_command)
               try(source(run_script_command5))
            }
            if ((timeseries_mtom    == 'y') && (exists("run_name2")) && (nchar(run_name2) > 0)) {
               system(mkdir_command)
               try(source(run_script_command7))
            }
         }	
      }
   }
   for (m in 1:length(batch_query)) {
      species_list <- c("SO4","NO3","TNO3","NH4","SO2")
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command 	<- paste("mkdir -p",figdir)
         dates 		<- batch_names[m]
         network_names 	<- c("CASTNET")
         network_label 	<- c("CASTNET")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         sites <- "All"
         if (by_site == 'y') {
            qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
            sites.df <- db_Query(qs,mysql)
            sites    <- sites.df$stat_id
            if (length(sites) == 0) { sites <- "All" }
         }
         for (s in 1:length(sites)) {
            if (sites[s] != "All") {
               pid   <- paste(network_label,sites[s],sep="_")
               query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
               site  <- sites[s]
            }
            if (timeseries_plot    == 'y') {
               system(mkdir_command)
               try(source(run_script_command1))
               try(source(run_script_command8))
            }
            if (temporal_plot      == 'y') {
               system(mkdir_command)
               try(source(run_script_command2))
            }
            if (box_plot           == 'y') {
               system(mkdir_command)
               try(source(run_script_command3))
               try(source(run_script_command9))
               try(source(run_script_command10))
            }
            if (box_plot_roselle   == 'y') {
               system(mkdir_command)
               try(source(run_script_command4))
            }
            if (monthly_stat_plot  == 'y') {
               system(mkdir_command)
               try(source(run_script_command5))
            }
            if ((timeseries_mtom    == 'y') && (exists("run_name2")) && (nchar(run_name2) > 0)) {
               system(mkdir_command)
               try(source(run_script_command7))
            }
         }
      }
   }
   for (m in 1:length(batch_query)) {
      species_list <- c("PM_TOT","EC","OC","SO4","NO3","NH4")
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command 	<- paste("mkdir -p",figdir)
         system(mkdir_command)
         dates 		<- batch_names[m]
         network_names 	<- c("AQS_Daily")
         network_label 	<- c("AQS_Daily")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         sites <- "All"
         if (by_site == 'y') {
            qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
            sites.df <- db_Query(qs,mysql)
            sites    <- sites.df$stat_id
            if (length(sites) == 0) { sites <- "All" }
         }
         for (s in 1:length(sites)) {
            if (sites[s] != "All") {
               pid   <- paste(network_label,sites[s],sep="_")
               query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
               site  <- sites[s]
            }
            if (timeseries_plot    == 'y') {
               system(mkdir_command)
               try(source(run_script_command1))
               try(source(run_script_command8))
            }
            if (temporal_plot      == 'y') {
               system(mkdir_command)
               try(source(run_script_command2))
            }
            if (box_plot           == 'y') {
               system(mkdir_command)
               try(source(run_script_command3))
               try(source(run_script_command9))
               try(source(run_script_command10))
            }
            if (box_plot_roselle   == 'y') {
               system(mkdir_command)
               try(source(run_script_command4))
            }
            if (monthly_stat_plot  == 'y') {
               system(mkdir_command)
               try(source(run_script_command5))
            }
            if ((timeseries_mtom    == 'y') && (exists("run_name2")) && (nchar(run_name2) > 0)) {
               system(mkdir_command)
               try(source(run_script_command7))
            }
         }
      }
   }
   for (m in 1:length(batch_query)) {
      species_list <- c("PM_TOT")
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command 	<- paste("mkdir -p",figdir)
         dates 		<- batch_names[m]
         network_names 	<- c("AQS_Hourly")
         network_label 	<- c("AQS_Hourly")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         sites <- "All"
         if (by_site == 'y') {
            qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
            sites.df <- db_Query(qs,mysql)
            sites    <- sites.df$stat_id
            if (length(sites) == 0) { sites <- "All" }
         }
         for (s in 1:length(sites)) {
            if (sites[s] != "All") {
               pid   <- paste(network_label,sites[s],sep="_")
               query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
               site  <- sites[s]
            }
            if (timeseries_plot    == 'y') {
               system(mkdir_command)
               try(source(run_script_command1))
               try(source(run_script_command8))
            }
            if (temporal_plot      == 'y') {
               system(mkdir_command)
               try(source(run_script_command2))
            }
            if (box_plot           == 'y') {
               system(mkdir_command)
               try(source(run_script_command3))
               try(source(run_script_command9))
               try(source(run_script_command10))
            }
            if (box_plot_roselle   == 'y') {
               system(mkdir_command)
               try(source(run_script_command4))
            }
            if (monthly_stat_plot  == 'y') {
               system(mkdir_command)
               try(source(run_script_command5))
            }
            if (box_plot_hourly   == 'y') {
               system(mkdir_command)
               try(source(run_script_command6))
            }
            if ((timeseries_mtom    == 'y') && (exists("run_name2")) && (nchar(run_name2) > 0)) {
               system(mkdir_command)
               try(source(run_script_command7))
            }
         }
      }
   }
}
if (dep_analysis == 'y') {	
   averaging <- deposition_averaging
   species_list <- c("SO4_dep","NO3_dep","NH4_dep","Precip")
   for (m in 1:length(batch_query)) {
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         dates		<- batch_names[m]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command 	<- paste("mkdir -p",figdir)
         network_names	<- c("NADP") 
         network_label	<- c("NADP")
         pid            <- network_label
         query		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         sites <- "All"
         if (by_site == 'y') {
            qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
            sites.df <- db_Query(qs,mysql)
            sites    <- sites.df$stat_id
            if (length(sites) == 0) { sites <- "All" }
         }
         for (s in 1:length(sites)) {
            if (sites[s] != "All") {
               pid   <- paste(network_label,sites[s],sep="_")
               query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
               site  <- sites[s]
            }
            if (timeseries_plot    == 'y') {
               system(mkdir_command)
               try(source(run_script_command1))
               try(source(run_script_command8))
            }
            if (temporal_plot      == 'y') {
               system(mkdir_command)
               try(source(run_script_command2))
            }
            if (box_plot           == 'y') {
               system(mkdir_command)
               try(source(run_script_command3))
               try(source(run_script_command9))
               try(source(run_script_command10))
            }
            if (box_plot_roselle   == 'y') {
               system(mkdir_command)
               try(source(run_script_command4))
            }
            if (monthly_stat_plot  == 'y') {
               system(mkdir_command)
               try(source(run_script_command5))
            }
            if ((timeseries_mtom    == 'y') && (exists("run_name2")) && (nchar(run_name2) > 0)) {
               system(mkdir_command)
               try(source(run_script_command7))
            }
         }
      }
   }
}
if (gas_analysis == 'y') {	
   averaging <- gas_averaging 
   species_list <- c("O3","SO2","NO","NO2","NOY","CO")
   for (m in 1:length(batch_query)) {
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         dates 		<- batch_names[m]
         figdir         <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir      <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command  <- paste("mkdir -p",figdir)
         network_names 	<- c("SEARCH")
         network_label 	<- c("SEARCH")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         sites <- "All"
         if (by_site == 'y') {
            qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
            sites.df <- db_Query(qs,mysql)
            sites    <- sites.df$stat_id
            if (length(sites) == 0) { sites <- "All" }
         }
         for (s in 1:length(sites)) {
            if (sites[s] != "All") {
               pid   <- paste(network_label,sites[s],sep="_")
               query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
               site  <- sites[s]
            }
            if (timeseries_plot    == 'y') {
               system(mkdir_command)
               try(source(run_script_command1))
               try(source(run_script_command8))
            }
            if (temporal_plot      == 'y') {
               system(mkdir_command)
               try(source(run_script_command2))
            }
            if (box_plot           == 'y') {
               system(mkdir_command)
               try(source(run_script_command3))
               try(source(run_script_command9))
               try(source(run_script_command10))
            }
            if (box_plot_roselle   == 'y') {
               system(mkdir_command)
               try(source(run_script_command4))
            }
            if (monthly_stat_plot  == 'y') {
               system(mkdir_command)
               try(source(run_script_command5))
            }
            if (box_plot_hourly   == 'y') {
               system(mkdir_command)
               try(source(run_script_command6))
            }
            if ((timeseries_mtom    == 'y') && (exists("run_name2")) && (nchar(run_name2) > 0)) {
               system(mkdir_command)
               try(source(run_script_command7))
            }
         }
      }
   }
   species_list <- c("SO2","NO","NO2","NOX","NOY","CO")
   for (m in 1:length(batch_query)) {
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         dates 		<- batch_names[m]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command  <- paste("mkdir -p",figdir)
         network_names 	<- c("AQS_Hourly")
         network_label 	<- c("AQS_Hourly")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         sites <- "All"
         if (by_site == 'y') {
            qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
            sites.df <- db_Query(qs,mysql)
            sites    <- sites.df$stat_id
            if (length(sites) == 0) { sites <- "All" }
         }
         for (s in 1:length(sites)) {
            if (sites[s] != "All") {
               pid   <- paste(network_label,sites[s],sep="_")
               query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
               site  <- sites[s]
            }
            if (timeseries_plot    == 'y') {
               system(mkdir_command)
               try(source(run_script_command1))
               try(source(run_script_command8))
            }
            if (temporal_plot      == 'y') {
               system(mkdir_command)
               try(source(run_script_command2))
            }
            if (box_plot           == 'y') {
               system(mkdir_command)
               try(source(run_script_command3))
               try(source(run_script_command9))
               try(source(run_script_command10))
            }
            if (box_plot_roselle   == 'y') {
               system(mkdir_command)
               try(source(run_script_command4))
            }
            if (monthly_stat_plot  == 'y') {
               system(mkdir_command)
               try(source(run_script_command5))
            }
            if (box_plot_hourly   == 'y') {
               system(mkdir_command)
               try(source(run_script_command6))
            }
            if ((timeseries_mtom    == 'y') && (exists("run_name2")) && (nchar(run_name2) > 0)) {
               system(mkdir_command)
               try(source(run_script_command7))
            }
         }
      }
   }
}
if (AE6_analysis == 'y') {
   averaging <- AE6_averaging
   species_list <- c("Na","Cl","Fe","Al","Si","Ti","Ca","Mg","K","Mn","soil","NaCl","other","ncom","other_rem")
   for (m in 1:length(batch_query)) {
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         dates 		<- batch_names[m]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command  <- paste("mkdir -p",figdir)
         network_names 	<- c("CSN")
         network_label 	<- c("CSN")
         pid            <- network_label         
	 query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         sites <- "All"
         if (by_site == 'y') {
            qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
            sites.df <- db_Query(qs,mysql)
            sites    <- sites.df$stat_id
            if (length(sites) == 0) { sites <- "All" }
         }
         for (s in 1:length(sites)) {
            if (sites[s] != "All") {
               pid   <- paste(network_label,sites[s],sep="_")
               query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
               site  <- sites[s]
            }
            if (timeseries_plot    == 'y') {
               system(mkdir_command)
               try(source(run_script_command1))
               try(source(run_script_command8))
            }
            if (temporal_plot      == 'y') {
               system(mkdir_command)
               try(source(run_script_command2))
            }
            if (box_plot           == 'y') {
               system(mkdir_command)
               try(source(run_script_command3))
               try(source(run_script_command9))
               try(source(run_script_command10))
            }
            if (box_plot_roselle   == 'y') {
               system(mkdir_command)
               try(source(run_script_command4))
            }
            if (monthly_stat_plot  == 'y') {
               system(mkdir_command)
               try(source(run_script_command5))
            }
            if ((timeseries_mtom    == 'y') && (exists("run_name2")) && (nchar(run_name2) > 0)) {
               system(mkdir_command)
               try(source(run_script_command7))
            }
         }
      }
   }
   species_list <- c("Na","NaCl","Fe","Al","Si","Ti","Ca","Mg","K","Mn","soil")
   for (m in 1:length(batch_query)) {
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         dates 		<- batch_names[m]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command  <- paste("mkdir -p",figdir)
         network_names 	<- c("IMPROVE")
         network_label 	<- c("IMPROVE")
         pid            <- network_label
         query		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         sites <- "All"
         if (by_site == 'y') {
            qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
            sites.df <- db_Query(qs,mysql)
            sites    <- sites.df$stat_id
            if (length(sites) == 0) { sites <- "All" }
         }
         for (s in 1:length(sites)) {
            if (sites[s] != "All") {
               pid   <- paste(network_label,sites[s],sep="_")
               query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
               site  <- sites[s]
            }
            if (timeseries_plot    == 'y') {
               system(mkdir_command)
               try(source(run_script_command1))
               try(source(run_script_command8))
            }
            if (temporal_plot      == 'y') {
               system(mkdir_command)
               try(source(run_script_command2))
            }
            if (box_plot           == 'y') {
               system(mkdir_command)
               try(source(run_script_command3))
               try(source(run_script_command9))
               try(source(run_script_command10))
            }
            if (box_plot_roselle   == 'y') {
               system(mkdir_command)
               try(source(run_script_command4))
            }
            if (monthly_stat_plot  == 'y') {
               system(mkdir_command)
               try(source(run_script_command5))
            }
            if ((timeseries_mtom    == 'y') && (exists("run_name2")) && (nchar(run_name2) > 0)) {
               system(mkdir_command)
               try(source(run_script_command7))
            }
         }
      }
   }
}
if (AOD_analysis == 'y') {
   averaging <- AOD_averaging
   species_list <- c("AOD_500")
   for (m in 1:length(batch_query)) {
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         dates 		<- batch_names[m]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command  <- paste("mkdir -p",figdir)
         system(mkdir_command)
         network_names 	<- c("AERONET")
         network_label 	<- c("AERONET")
         pid            <- network_label
         query <- paste(query_string,"and (",batch_query[m],")",sep=" ")
         if (timeseries_plot    == 'y') {
            system(mkdir_command)
            try(source(run_script_command1))
            try(source(run_script_command8))
         }
         if (temporal_plot      == 'y') {
            system(mkdir_command)
            try(source(run_script_command2))
         }
         if (box_plot           == 'y') {
            system(mkdir_command)
            try(source(run_script_command3))
            try(source(run_script_command9))
            try(source(run_script_command10))
         }
         if (box_plot_roselle   == 'y') {
            system(mkdir_command)
            try(source(run_script_command4))
         }
         if (monthly_stat_plot  == 'y') {
            system(mkdir_command)
            try(source(run_script_command5))
         }
         if ((timeseries_mtom    == 'y') && (exists("run_name2")) && (nchar(run_name2) > 0)) {
            system(mkdir_command)
            try(source(run_script_command7))
         }
      }
   }
}
if (PAMS_analysis == 'y') {
   averaging <- PAMS_averaging
   species_list <- c("Isoprene","Ethane","Ethylene","Toluene")
   for (m in 1:length(batch_query)) {
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         dates 		<- batch_names[m]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command  <- paste("mkdir -p",figdir)
         network_names 	<- c("AQS_Hourly")
         network_label 	<- c("AQS_Hourly")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         sites <- "All"
         if (by_site == 'y') {
            qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
            sites.df <- db_Query(qs,mysql)
            sites    <- sites.df$stat_id
            if (length(sites) == 0) { sites <- "All" }
         }
         for (s in 1:length(sites)) {
            if (sites[s] != "All") {
               pid   <- paste(network_label,sites[s],sep="_")
               query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
               site  <- sites[s]
            }
            if (timeseries_plot    == 'y') {
               system(mkdir_command)
               try(source(run_script_command1))
               try(source(run_script_command8))
            }
            if (temporal_plot      == 'y') {
               system(mkdir_command)
               try(source(run_script_command2))
            }
            if (box_plot           == 'y') {
               system(mkdir_command)
               try(source(run_script_command3))
               try(source(run_script_command9))
               try(source(run_script_command10))
            }
            if (box_plot_roselle   == 'y') {
               system(mkdir_command)
               try(source(run_script_command4))
            }
            if (monthly_stat_plot  == 'y') {
               system(mkdir_command)
               try(source(run_script_command5))
            }
            if (box_plot_hourly   == 'y') {
               system(mkdir_command)
               try(source(run_script_command6))
            }
            if ((timeseries_mtom    == 'y') && (exists("run_name2")) && (nchar(run_name2) > 0)) {
               system(mkdir_command)
               try(source(run_script_command7))
            }
         }
      }
   }
   species_list <- c("Isoprene","Ethane","Ethylene","Toluene","Acetaldehyde","Formaldehyde")
   for (m in 1:length(batch_query)) {
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         dates 		<- batch_names[m]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command  <- paste("mkdir -p",figdir)
         network_names 	<- c("AQS_Daily")
         network_label 	<- c("AQS_Daily")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         sites <- "All"
         if (by_site == 'y') {
            qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
            sites.df <- db_Query(qs,mysql)
            sites    <- sites.df$stat_id
            if (length(sites) == 0) { sites <- "All" }
         }
         for (s in 1:length(sites)) {
            if (sites[s] != "All") {
               pid   <- paste(network_label,sites[s],sep="_")
               query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
               site  <- sites[s]
            }
            if (timeseries_plot    == 'y') {
               system(mkdir_command)
               try(source(run_script_command1))
               try(source(run_script_command8))
            }
            if (temporal_plot      == 'y') {
               system(mkdir_command)
               try(source(run_script_command2))
            }
            if (box_plot           == 'y') {
               system(mkdir_command)
               try(source(run_script_command3))
               try(source(run_script_command9))
               try(source(run_script_command10))
            }
            if (box_plot_roselle   == 'y') {
               system(mkdir_command)
               try(source(run_script_command4))
            }
            if (monthly_stat_plot  == 'y') {
               system(mkdir_command)
               try(source(run_script_command5))
            }
            if ((timeseries_mtom    == 'y') && (exists("run_name2")) && (nchar(run_name2) > 0)) {
               system(mkdir_command)
               try(source(run_script_command7))
            }
         }
      }
   }
}
