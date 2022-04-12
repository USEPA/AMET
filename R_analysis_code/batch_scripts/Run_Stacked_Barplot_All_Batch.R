ametbase         <- Sys.getenv("AMETBASE")
dbase            <- Sys.getenv("AMET_DATABASE")
out_dir          <- Sys.getenv("AMET_OUT")
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
states                  <- c("All")
#states             <- c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")
#states             <- c("AZ","CA","CO","ID","IA","KS","MT","NE","NV","NM","ND","OK","OR","SD","TX","UT","WA","WY") # Western States
###################################

######################################
####### Configuration Options ########
######################################
run_name1               <- Sys.getenv("AMET_PROJECT")      # AMET project name
run_name2               <- Sys.getenv("AMET_PROJECT2")     # Additional run to include on plot 
#start_date             <- "20060101"                           # Set the start date of the analysis
#end_date               <- "20061231"                           # Set the end date of the analysis

#batch_query            <- c("month=1","month=2","month=3","month=4","month=5","month=6","month=7","month=8","month=9","month=10","month=11","month=12",
#                             "(month=12 or month=1 or month=2)", 
#                             "(month=3 or month=4 or month=5)",
#                             "(month=6 or month=7 or month=8)",
#                             "(month=9 or month=10 or month=11)")
#batch_names             <- c("January","February","March","April","May","June","July","August","September","October","November","December",
#                             "Winter","Spring","Summer","Fall")
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

pid_date <- paste(start_year,start_month,sep="")

#query_string2<-paste(" and d.ob_dates >=",start_date,"and d.ob_datee <=",end_date,additional_query,sep=" ")

### Set and create output directory ###
#out_dir                 <- paste(out_dir,"bar_plots",sep="/")
mkdir_main_command      <- paste("mkdir -p",out_dir,sep=" ")
system(mkdir_main_command)      # This will create a subdirectory with the name of the project
#######################################

run_script_command1 <- paste(amet_base,"/R_analysis_code/AQ_Stacked_Barplot.R",sep="")
run_script_command2 <- paste(amet_base,"/R_analysis_code/AQ_Stacked_Barplot_AE6.R",sep="")
run_script_command3 <- paste(amet_base,"/R_analysis_code/AQ_Stacked_Barplot_soil.R",sep="")
run_script_command4 <- paste(amet_base,"/R_analysis_code/AQ_Stacked_Barplot_soil_multi.R",sep="")
run_script_command5 <- paste(amet_base,"/R_analysis_code/AQ_Stacked_Barplot_AE6_ggplot.R",sep="")
run_script_command6 <- paste(amet_base,"/R_analysis_code/AQ_Stacked_Barplot_AE6_plotly.R",sep="")
run_script_command7 <- paste(amet_base,"/R_analysis_code/AQ_Stacked_Barplot_AE6_ts.R",sep="")

###############################################################################################
### This portion of the code will create seasonal soccer goal plots for the various species ###
###############################################################################################

#for (m in 1:length(batch_query)) {	# Create a subdirectory for each month
#   mkdir_command <- paste("mkdir -p ",out_dir,"/",batch_names[m],sep="")
#   system(mkdir_command)
#}
for (m in 1:length(batch_query)) {
   species_list         <- c("PM_TOT","soil")
   for (i in 1:length(species_list)) {
      species_in	<- species_list[i]
      dates 		<- batch_names[m]
      figdir                 <- paste(out_dir,species_in,sep="/")
      if (batch_names[m] != "None") {
         figdir                 <- paste(out_dir,batch_names[m],species_in,sep="/")
      }
      mkdir_command     <- paste("mkdir -p",figdir)
      network_names 	<- c("CSN")
      network_label 	<- c("CSN")
      pid 		<- paste(pid_date,network_names,sep="_")
      query 		<- paste(query_string,"and (",batch_query[m],")",sep="")
      sites <- "All"
      if (by_site == 'y') {
         qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
         sites.df <- db_Query(qs,mysql)
         sites    <- sites.df$stat_id
         if (length(sites) == 0) { sites <- "All" }
      }
      for (s in 1:length(sites)) {
         if (sites[s] != "All") {
            pid   <- paste(pid_date,network_label,sites[s],sep="_")
            query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
            site  <- sites[s]
         }
         if (species_in == "PM_TOT") {
            if (AE5_barplot == 'y') { 
               system(mkdir_command) 
               try(source(run_script_command1)) 
            }
            if (AE6_barplot == 'y') {
               system(mkdir_command)
               try(source(run_script_command2))
               try(source(run_script_command5))
               try(source(run_script_command6))
            }
            if (AE6_barplot_timeseries == 'y') {
               system(mkdir_command)
               try(source(run_script_command7))
            }
         }
         if (species_in == "soil") {
            if (soil_barplot == 'y') { 
               system(mkdir_command) 
               try(source(run_script_command3)) 
            }
         }
      }
   }
}

for (m in 1:length(batch_query)) {
   species_list         <- c("PM_TOT","soil")
   for (i in 1:length(species_list)) {
      species_in        <- species_list[i]
      dates             <- batch_names[m]
      figdir            <- paste(out_dir,species_in,sep="/")
      if (batch_names[m] != "None") {
         figdir                 <- paste(out_dir,batch_names[m],species_in,sep="/")
      }
      mkdir_command     <- paste("mkdir -p",figdir)
      network_names     <- c("IMPROVE")
      network_label     <- c("IMPROVE")
      pid               <- paste(pid_date,network_names,sep="_")
      query             <- paste(query_string,"and (",batch_query[m],")",sep="")
      sites <- "All"
      if (by_site == 'y') {
         qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
         sites.df <- db_Query(qs,mysql)
         sites    <- sites.df$stat_id
         if (length(sites) == 0) { sites <- "All" }
      }
      for (s in 1:length(sites)) {
         if (sites[s] != "All") {
            pid   <- paste(pid_date,network_label,sites[s],sep="_")
            query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
            site  <- sites[s]
         }
         if (species_in == "PM_TOT") {
            if (AE5_barplot == 'y') { 
               system(mkdir_command) 
               try(source(run_script_command1)) 
            }
            if (AE6_barplot == 'y') { 
               system(mkdir_command) 
               try(source(run_script_command2)) 
               try(source(run_script_command5))
               try(source(run_script_command6))
            }
            if (AE6_barplot_timeseries == 'y') {
               system(mkdir_command)
               try(source(run_script_command7))
            }
         }
         if (species_in == "soil") {
            if (soil_barplot == 'y') { 
               system(mkdir_command) 
               try(source(run_script_command3)) 
            }
         }
      }
   }
}

for (m in 1:length(batch_query)) {
   species_list         <- c("PM_TOT")
   for (i in 1:length(species_list)) {
      species_in        <- species_list[i]
      dates             <- batch_names[m]
      figdir            <- paste(out_dir,species_in,sep="/")
      if (batch_names[m] != "None") {
         figdir                 <- paste(out_dir,batch_names[m],species_in,sep="/")
      }
      mkdir_command     <- paste("mkdir -p",figdir)
      network_names     <- c("AQS_Daily")
      network_label     <- c("AQS_Daily")
      pid               <- paste(pid_date,network_names,sep="_")
      query             <- paste(query_string,"and (",batch_query[m],")",sep="")
      sites <- "All"
      if (by_site == 'y') {
         qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
         sites.df <- db_Query(qs,mysql)
         sites    <- sites.df$stat_id
         if (length(sites) == 0) { sites <- "All" }
      }
      for (s in 1:length(sites)) {
         if (sites[s] != "All") {
            pid   <- paste(pid_date,network_label,sites[s],sep="_")
            query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
            site  <- sites[s]
         }
         if (species_in == "PM_TOT") {
            if (AE5_barplot == 'y') {
               system(mkdir_command)
               try(source(run_script_command1))
            }
            if (AE6_barplot == 'y') {
               system(mkdir_command)
               try(source(run_script_command2))
               try(source(run_script_command5))
               try(source(run_script_command6))
            }
            if (AE6_barplot_timeseries == 'y') {
               system(mkdir_command)
               try(source(run_script_command7))
            }
         }
      }
   }
}

for (m in 1:length(batch_query)) {
   species_list         <- c("PM_TOT","soil")
   for (i in 1:length(species_list)) {
      species_in	   <- species_list[i]
      dates                <- batch_names[m]
      figdir               <- paste(out_dir,species_in,sep="/")
      if (batch_names[m] != "None") {
         figdir            <- paste(out_dir,batch_names[m],species_in,sep="/")
      }
      mkdir_command        <- paste("mkdir -p",figdir)
      network_names        <- c("CSN","IMPROVE")
      network_label        <- c("CSN","IMPROVE")
      pid                  <- paste(pid_date,"multi_network",sep="_")
      query                <- paste(query_string,"and (",batch_query[m],")",sep="")
      sites <- "All"
      if (by_site == 'y') {
         qs <- paste("SELECT distinct(d.stat_id) from ",run_name1," as d, site_metadata as s where d.network = '",network_names,"' ",query,sep="")
         sites.df <- db_Query(qs,mysql)
         sites    <- sites.df$stat_id
         if (length(sites) == 0) { sites <- "All" }
      }
      for (s in 1:length(sites)) {
         if (sites[s] != "All") {
            pid   <- paste(pid_date,network_label,sites[s],sep="_")
            query <- paste(query_string," and (",batch_query[m],") and d.stat_id ='",sites[s],"'",sep="")
            site  <- sites[s]
         }
         if (species_in == "soil") {
            if (soil_multi_barplot == 'y') { 
               system(mkdir_command)
               try(source(run_script_command4)) 
            }
         }
         if (species_in == "PM_TOT") {
   #         if (panel_AE6_multi_barplot == 'y') { 
   #             system(mkdir -p_command) 
   #             try(source(run_script_command7)) 
   #         }
         }
      }
   }
}

####################################
### End Monthly Analysis Section ###
####################################
