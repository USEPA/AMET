################################################################
### THIS FILE CONTAINS CODE TO DRAW A CUSTOMIZED BOXPLOT DISPLAY.  It
### draws side-by-side boxplots for the various groups, without median
### lines or whiskers.  This means that to see the boxplot, we have o
### give it a colored background.  We also draw points at the medians
### of the boxplots, and connect these with lines.
### NOTE: The user should make sure the data is sorted by group before
### using this code.
################################################################

batch <- 'y'

amet_base        <- Sys.getenv("AMETBASE")
dbase            <- Sys.getenv("AMET_DATABASE")
out_dir          <- Sys.getenv("AMET_OUT")
ametRinput       <- Sys.getenv("AMETRINPUT")
source(ametRinput)

#states             <- c("All")
#states             <- c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")
#states             <- c("AZ","CA","CO","ID","IA","KS","MT","NE","NV","NM","ND","OK","OR","SD","TX","UT","WA","WY") # Western States
#states             <- c("CA")

######################################
####### Configuration Options ########
######################################
run_name1               <- Sys.getenv("AMET_PROJECT")	# AMET project name
run_name2               <- Sys.getenv("AMET_PROJECT2")	# Additional run to include on plot 
#start_date             <- "20060101"                           # Set the start date of the analysis
#end_date               <- "20061231"                           # Set the end date of the analysis
#batch_query            <- c("month=1","month=2","month=3","month=4","month=5","month=6","month=7","month=8","month=9","month=10","month=11","month=12",
#                             "(month=12 or month=1 or month=2)", 
#                             "(month=3 or month=4 or month=5)",
#                             "(month=6 or month=7 or month=8)",
#                             "(month=9 or month=10 or month=11)")
#batch_names             <- c("January","February","March","April","May","June","July","August","September","October","November","December",
#                             "Winter","Spring","Summer","Fall")

#hourly_ozone_analysis	<- 'n'                                  # Flag to include hourly ozone analysis
#daily_ozone_analysis	<- 'y'                                  # Flag to include daily ozone analysis
#aerosol_analysis	<- 'y'                                  # Flag to include aerosol analysis
#dep_analysis		<- 'y'                                  # Flag to include analysis of deposition performance
#gas_analysis		<- 'y'                                  # Flag to include gas analysis

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

### Main Database Query String. ###
query_string<-paste(" and s.stat_id=d.stat_id and d.ob_dates >=",start_date,"and d.ob_datee <=",end_date,additional_query,sep=" ")

### Set and create output directory ###
#out_dir 		<- paste(out_dir,"spatial_plots",sep="/")
mkdir_main_command      <- paste("mkdir -p",out_dir,sep=" ")
system(mkdir_main_command)      # This will create a subdirectory with the name of the project
#######################################

run_script_command1 <- paste(amet_base,"/R_analysis_code/AQ_Stats_Plots.R",sep="")
run_script_command2 <- paste(amet_base,"/R_analysis_code/AQ_Plot_Spatial.R",sep="")
run_script_command3 <- paste(amet_base,"/R_analysis_code/AQ_Plot_Spatial_Diff.R",sep="")
run_script_command4 <- paste(amet_base,"/R_analysis_code/AQ_Plot_Spatial_MtoM.R",sep="")
run_script_command5 <- paste(amet_base,"/R_analysis_code/AQ_Plot_Spatial_Ratio.R",sep="")
run_script_command6 <- paste(amet_base,"/R_analysis_code/AQ_Plot_Spatial_interactive.R",sep="")
run_script_command7 <- paste(amet_base,"/R_analysis_code/AQ_Plot_Spatial_Diff_interactive.R",sep="")

##########################################################################################
### This portion of the code will create monthly spatial plots for the various species ###
##########################################################################################
#for (m in 1:length(batch_query)) {
#   mkdir_command <- paste("mkdir ",out_dir,"/",batch_names[m],sep="")
#   system(mkdir_command)
#}
if (hourly_ozone_analysis == 'y') {
   averaging <- ozone_averaging
   for (m in 1:length(batch_query)) {
      species 		<- "O3"
      figdir                 <- paste(out_dir,species,sep="/")
      if (batch_names[m] != "None") {
         figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
      }
      mkdir_command	<- paste("mkdir -p",figdir)
      dates 		<- batch_names[m]
      network_names 	<- c("AQS_Hourly","NAPS","EMEP_Hourly")
      network_label 	<- c("AQS","NAPS","EMEP")
      pid               <- "multi_network"
      query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
      print(query)
      system(mkdir_command)
      if (stat_plots    == 'y')	{ try(source(run_script_command1)) }
      if (spatial_plots == 'y')	{ try(source(run_script_command2)) }
      if (diff_plots    == 'y')	{ try(source(run_script_command3)) }
      if (mtom_plots    == 'y')	{ try(source(run_script_command4)) }
      if (spatial_plots == 'y') { try(source(run_script_command6)) }
      if (diff_plots    == 'y') { try(source(run_script_command7)) }
   }
}

if (daily_ozone_analysis == 'y') {
   averaging <- ozone_averaging
   for (m in 1:length(batch_query)) {
      species 		<- "O3_1hrmax"
      figdir                 <- paste(out_dir,species,sep="/")
      if (batch_names[m] != "None") {
         figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
      }
      mkdir_command  	<- paste("mkdir -p",figdir)
      dates 		<- batch_names[m]
      network_names 	<- c("AQS_Daily_O3","CASTNET_Daily","NAPS_Daily_O3","EMEP_Daily_O3")
      network_label 	<- c("AQS","CASTNET","NAPS","EMEP")
      pid            	<- "multi_network"
      query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
#      print(query)
      system(mkdir_command)
      if (stat_plots    == 'y') { try(source(run_script_command1)) }
      if (spatial_plots == 'y') { try(source(run_script_command2)) }
      if (diff_plots    == 'y') { try(source(run_script_command3)) }
      if (mtom_plots    == 'y') { try(source(run_script_command4)) }
      if (spatial_plots == 'y') { try(source(run_script_command6)) }
      if (diff_plots    == 'y') { try(source(run_script_command7)) }
   }
   for (m in 1:length(batch_query)) {
      species 		<- "O3_8hrmax"
      figdir                 <- paste(out_dir,species,sep="/")
      if (batch_names[m] != "None") {
         figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
      }
      mkdir_command  	<- paste("mkdir -p",figdir)
      dates 		<- batch_names[m]
      network_names 	<- c("AQS_Daily_O3","CASTNET_Daily","NAPS_Daily_O3","EMEP_Daily_O3")
      network_label 	<- c("AQS","CASTNET","NAPS","EMEP")
      pid            	<- "multi_network"
      query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
      system(mkdir_command)
      if (stat_plots    == 'y') { try(source(run_script_command1)) }
      if (spatial_plots == 'y') { try(source(run_script_command2)) }
      if (diff_plots    == 'y') { try(source(run_script_command3)) }
      if (mtom_plots    == 'y') { try(source(run_script_command4)) }
      if (spatial_plots == 'y') { try(source(run_script_command6)) }
      if (diff_plots    == 'y') { try(source(run_script_command7)) }
   }
}

if (aerosol_analysis == 'y') {
   averaging <- aerosol_averaging
   for (m in 1:length(batch_query)) {
      species_list <- c("SO4","NO3","NH4")
      for (i in 1:length(species_list)) { 
         species	<- species_list[i]
         dates 		<- batch_names[m]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command	<- paste("mkdir -p",figdir)
         network_names 	<- c("IMPROVE","CSN","CASTNET")
         network_label 	<- c("IMPROVE","CSN","CASTNET")
         pid 		<- "multi_network"
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         print(query)
         system(mkdir_command)
         if (stat_plots    == 'y') { try(source(run_script_command1)) }
         if (spatial_plots == 'y') { try(source(run_script_command2)) }
         if (diff_plots    == 'y') { try(source(run_script_command3)) }
         if (mtom_plots    == 'y') { try(source(run_script_command4)) }
         if (spatial_plots == 'y') { try(source(run_script_command6)) }
         if (diff_plots    == 'y') { try(source(run_script_command7)) }
      }
   }
   for (m in 1:length(batch_query)) {
      species_list <- c("HNO3","TNO3")
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         dates		<- batch_names[m]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command  <- paste("mkdir -p",figdir)
         network_names 	<- c("CASTNET")
         network_label 	<- c("CASTNET")
         pid 		<- network_names 
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (stat_plots    == 'y') { try(source(run_script_command1)) }
         if (spatial_plots == 'y') { try(source(run_script_command2)) }
         if (diff_plots    == 'y') { try(source(run_script_command3)) }
         if (mtom_plots    == 'y') { try(source(run_script_command4)) }
         if (spatial_plots == 'y') { try(source(run_script_command6)) }
         if (diff_plots    == 'y') { try(source(run_script_command7)) }
      }
   }
   for (m in 1:length(batch_query)) {
      species 		<- "PM_TOT"
      figdir                 <- paste(out_dir,species,sep="/")
      if (batch_names[m] != "None") {
         figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
      }
      mkdir_command 	<- paste("mkdir -p",figdir)
      dates 		<- batch_names[m]
      network_names 	<- c("IMPROVE","CSN","AQS_Daily","AQS_Hourly")
      network_label 	<- c("IMPROVE","CSN","AQS_Daily","AQS_Hourly")
      pid 		<- "multi_network"
      query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
      system(mkdir_command)
      if (stat_plots    == 'y') { try(source(run_script_command1)) }
      if (spatial_plots == 'y') { try(source(run_script_command2)) }
      if (diff_plots    == 'y') { try(source(run_script_command3)) }
      if (mtom_plots    == 'y') { try(source(run_script_command4)) }
      if (spatial_plots == 'y') { try(source(run_script_command6)) }
      if (diff_plots    == 'y') { try(source(run_script_command7)) }
   }
   for (m in 1:length(batch_query)) {
      species_list <- c("EC","OC","TC") 
      for (i in 1:length(species_list)) {
         species	<- species_list[i]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command  <- paste("mkdir -p",figdir)
         dates 		<- batch_names[m]
         network_names 	<- c("IMPROVE","CSN")
         network_label 	<- c("IMPROVE","CSN")
         pid 		<- "multi_network" 
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         print(query)
         system(mkdir_command)
         if (stat_plots    == 'y') { try(source(run_script_command1)) }
         if (spatial_plots == 'y') { try(source(run_script_command2)) }
         if (diff_plots    == 'y') { try(source(run_script_command3)) }
         if (mtom_plots    == 'y') { try(source(run_script_command4)) }
         if (ratio_plots   == 'y') { try(source(run_script_command5)) }
         if (spatial_plots == 'y') { try(source(run_script_command6)) }
         if (diff_plots    == 'y') { try(source(run_script_command7)) }
      }
   }
}

if (dep_analysis == 'y') {
   averaging <- deposition_averaging
   for (m in 1:length(batch_query)) {
      species_list <- c("SO4_dep","NO3_dep","NH4_dep","Precip")
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         dates		<- batch_names[m]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command  <- paste("mkdir -p",figdir)
         network_names 	<- c("NADP")
         network_label 	<- c("NADP")
         pid 		<- network_names
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         print(query)
         system(mkdir_command)
         if (stat_plots    == 'y') { try(source(run_script_command1)) }
         if (spatial_plots == 'y') { try(source(run_script_command2)) }
         if (diff_plots    == 'y') { try(source(run_script_command3)) }
         if (mtom_plots    == 'y') { try(source(run_script_command4)) }
         if (spatial_plots == 'y') { try(source(run_script_command6)) }
         if (diff_plots    == 'y') { try(source(run_script_command7)) }
      }
   }      
}

if (gas_analysis == 'y') {
   averaging <- gas_averaging
   for (m in 1:length(batch_query)) {
      species_list <- c("SO2","NO2","NOY","NOX","CO")
      for (i in 1:length(species_list)) {
         species        <- species_list[i]
         figdir                 <- paste(out_dir,species,sep="/")
         if (batch_names[m] != "None") {
            figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
         }
         mkdir_command  <- paste("mkdir -p",figdir)
         dates          <- batch_names[m]
         network_names  <- c("AQS_Hourly")
         network_label  <- c("AQS")
         pid            <- network_names
         query          <- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (stat_plots    == 'y') { try(source(run_script_command1)) }
         if (spatial_plots == 'y') { try(source(run_script_command2)) }
         if (diff_plots    == 'y') { try(source(run_script_command3)) }
         if (mtom_plots    == 'y') { try(source(run_script_command4)) }
         if (spatial_plots == 'y') { try(source(run_script_command6)) }
         if (diff_plots    == 'y') { try(source(run_script_command7)) }
      }
   }
   for (m in 1:length(batch_query)) {
      species        <- "SO2"
      figdir                 <- paste(out_dir,species,sep="/")
      if (batch_names[m] != "None") {
         figdir                 <- paste(out_dir,batch_names[m],species,sep="/")
      }
      mkdir_command  <- paste("mkdir -p",figdir)
      dates          <- batch_names[m]
      network_names  <- c("CASTNET")
      network_label  <- c("CASTNET")
      pid            <- network_names
      query          <- paste(query_string,"and (",batch_query[m],")",sep=" ")
      system(mkdir_command)
      if (stat_plots    == 'y') { try(source(run_script_command1)) }
      if (spatial_plots == 'y') { try(source(run_script_command2)) }
      if (diff_plots    == 'y') { try(source(run_script_command3)) }
      if (mtom_plots    == 'y') { try(source(run_script_command4)) }
      if (spatial_plots == 'y') { try(source(run_script_command6)) }
      if (diff_plots    == 'y') { try(source(run_script_command7)) }
   }
}

if (AE6_analysis == 'y') {
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
         network_names 	<- c("IMPROVE","CSN")
         network_label 	<- c("IMPROVE","CSN")
         pid 		<- "multi_network"
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (stat_plots    == 'y') { try(source(run_script_command1)) }
         if (spatial_plots == 'y') { try(source(run_script_command2)) }
         if (diff_plots    == 'y') { try(source(run_script_command3)) }
         if (mtom_plots    == 'y') { try(source(run_script_command4)) }
         if (ratio_plots   == 'y') { try(source(run_script_command5)) }
         if (spatial_plots == 'y') { try(source(run_script_command6)) }
         if (diff_plots    == 'y') { try(source(run_script_command7)) }
      }
   }
}
if (AOD_analysis == 'y') {
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
         network_names 	<- c("AERONET")
         network_label 	<- c("AERONET")
         pid 		<- paste(run_name1,dates,species,sep="_")
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (stat_plots    == 'y') { try(source(run_script_command1)) }
         if (spatial_plots == 'y') { try(source(run_script_command2)) }
         if (diff_plots    == 'y') { try(source(run_script_command3)) }
         if (mtom_plots    == 'y') { try(source(run_script_command4)) }
         if (spatial_plots == 'y') { try(source(run_script_command6)) }
         if (diff_plots    == 'y') { try(source(run_script_command7)) }
      }
   }
}
if (PAMS_analysis == 'y') {
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
         pid 		<- paste(run_name1,dates,species,sep="_")
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)        
         if (stat_plots    == 'y') { try(source(run_script_command1)) }
         if (spatial_plots == 'y') { try(source(run_script_command2)) }
         if (diff_plots    == 'y') { try(source(run_script_command3)) }
         if (mtom_plots    == 'y') { try(source(run_script_command4)) }
         if (spatial_plots == 'y') { try(source(run_script_command6)) }
         if (diff_plots    == 'y') { try(source(run_script_command7)) }
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
         pid 		<- paste(run_name1,dates,species,sep="_")
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (stat_plots    == 'y') { try(source(run_script_command1)) }
         if (spatial_plots == 'y') { try(source(run_script_command2)) }
         if (diff_plots    == 'y') { try(source(run_script_command3)) }
         if (mtom_plots    == 'y') { try(source(run_script_command4)) }
         if (spatial_plots == 'y') { try(source(run_script_command6)) }
         if (diff_plots    == 'y') { try(source(run_script_command7)) }
      }
   }
}

