################################################################
### THIS FILE CONTAINS CODE TO DRAW A CUSTOMIZED SCATTER PLOT.
################################################################

amet_base      	 <- Sys.getenv("AMETBASE")
dbase            <- Sys.getenv("AMET_DATABASE")
out_dir		 <- Sys.getenv("AMET_OUT")
ametRinput       <- Sys.getenv("AMETRINPUT")
source(ametRinput)

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

### Main Database Query String. ###
query_string<-paste(" and s.stat_id=d.stat_id and d.ob_dates >=",start_date,"and d.ob_datee <=",end_date,additional_query,sep=" ")

### Set and create output directory ###
out_dir 		<- paste(out_dir,"scatter_plots",sep="/")
mkdir_main_command      <- paste("mkdir -p",out_dir,sep=" ")
system(mkdir_main_command)      # This will create a subdirectory with the name of the project
#######################################

run_script_command1 <- paste(amet_base,"/R_analysis_code/AQ_Scatterplot.R",sep="")
run_script_command2 <- paste(amet_base,"/R_analysis_code/AQ_Scatterplot_single.R",sep="")
run_script_command3 <- paste(amet_base,"/R_analysis_code/AQ_Scatterplot_density.R",sep="")
run_script_command4 <- paste(amet_base,"/R_analysis_code/AQ_Scatterplot_bins.R",sep="")
run_script_command5 <- paste(amet_base,"/R_analysis_code/AQ_Scatterplot_percentiles.R",sep="")
run_script_command6 <- paste(amet_base,"/R_analysis_code/AQ_Scatterplot_skill.R",sep="")
run_script_command7 <- paste(amet_base,"/R_analysis_code/AQ_Scatterplot_mtom.R",sep="")

#######################################################################################
### This portion of the code will create monthly stat plots for the various species ###
#######################################################################################
for (m in 1:length(batch_query)) {
   mkdir_command <- paste("mkdir -p ",out_dir,"/",batch_names[m],sep="")
   cat(mkdir_command)
   system(mkdir_command)
}
if (hourly_ozone_analysis == 'y') {
   averaging <- ozone_averaging
   for (m in 1:length(batch_query)) {
      species_list <- c("O3")
      for (i in 1:length(species_list)) {
         species 		<- species_list[i]
         sub_dir 		<- batch_names[m]
         figdir 		<- paste(out_dir,sub_dir,species,sep="/")
         mkdir_command 	<- paste("mkdir",figdir)
         dates 		<- batch_names[m]
         network_names 	<- c("AQS_Hourly")
         network_label 	<- c("AQS_Hourly")
         pid                 <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (scatter_plot		== 'y') { try(source(run_script_command1)) }
         if (scatter_single_plot	== 'y') { try(source(run_script_command2)) }
         if (scatter_density_plot	== 'y') { try(source(run_script_command3)) }
         if (scatter_bins_plot		== 'y') { try(source(run_script_command4)) }
         if (scatter_percentiles_plot	== 'y') { try(source(run_script_command5)) }
         if (scatter_skill_plot		== 'y') { try(source(run_script_command6)) }
         if (scatter_mtom_plot		== 'y') { try(source(run_script_command7)) }
      }
   }
}
if (daily_ozone_analysis == 'y') {  
   averaging <- ozone_averaging
   species_list <- c("O3_1hrmax","O3_8hrmax")
   for (m in 1:length(batch_query)) {
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         sub_dir 	<- batch_names[m]
         figdir 	<- paste(out_dir,sub_dir,species,sep="/")
         mkdir_command 	<- paste("mkdir",figdir)
         dates 		<- batch_names[m]
         network_names 	<- c("AQS_Daily_O3")
         network_label 	<- c("AQS_Daily")
         pid		<- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (scatter_plot               == 'y') { try(source(run_script_command1)) }
         if (scatter_single_plot        == 'y') { try(source(run_script_command2)) }
         if (scatter_density_plot       == 'y') { try(source(run_script_command3)) }
         if (scatter_bins_plot          == 'y') { try(source(run_script_command4)) }
         if (scatter_percentiles_plot   == 'y') { try(source(run_script_command5)) }
         if (scatter_skill_plot         == 'y') { try(source(run_script_command6)) }
         if (scatter_mtom_plot          == 'y') { try(source(run_script_command7)) }
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
         sub_dir 	<- batch_names[m]
         figdir 	<- paste(out_dir,sub_dir,species,sep="/")
         mkdir_command 	<- paste("mkdir",figdir)
         network_names 	<- c("IMPROVE")
         network_label 	<- c("IMPROVE")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (scatter_plot               == 'y') { try(source(run_script_command1)) }
         if (scatter_single_plot        == 'y') { try(source(run_script_command2)) }
         if (scatter_density_plot       == 'y') { try(source(run_script_command3)) }
         if (scatter_bins_plot          == 'y') { try(source(run_script_command4)) }
         if (scatter_percentiles_plot   == 'y') { try(source(run_script_command5)) }
         if (scatter_skill_plot         == 'y') { try(source(run_script_command6)) }
         if (scatter_mtom_plot          == 'y') { try(source(run_script_command7)) }
      }
   }
   for (m in 1:length(batch_query)) {
      species_list <- c("SO4","NO3","NH4","TC","PM_TOT")
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         sub_dir 	<- batch_names[m]
         figdir 	<- paste(out_dir,sub_dir,species,sep="/")
         mkdir_command 	<- paste("mkdir",figdir)
         dates 		<- batch_names[m]
         network_names 	<- c("CSN")
         network_label 	<- c("CSN")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (scatter_plot               == 'y') { try(source(run_script_command1)) }
         if (scatter_single_plot        == 'y') { try(source(run_script_command2)) }
         if (scatter_density_plot       == 'y') { try(source(run_script_command3)) }
         if (scatter_bins_plot          == 'y') { try(source(run_script_command4)) }
         if (scatter_percentiles_plot   == 'y') { try(source(run_script_command5)) }
         if (scatter_skill_plot         == 'y') { try(source(run_script_command6)) } 
         if (scatter_mtom_plot          == 'y') { try(source(run_script_command7)) }
      }
   }
   for (m in 1:length(batch_query)) {
      species_list <- c("SO4","NO3","TNO3","NH4","SO2")
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         sub_dir 	<- batch_names[m]
         figdir 	<- paste(out_dir,sub_dir,species,sep="/")
         mkdir_command 	<- paste("mkdir",figdir)
         dates 		<- batch_names[m]
         network_names 	<- c("CASTNET")
         network_label 	<- c("CASTNET")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         if (scatter_plot               == 'y') { try(source(run_script_command1)) }
         if (scatter_single_plot        == 'y') { try(source(run_script_command2)) }
         if (scatter_density_plot       == 'y') { try(source(run_script_command3)) }
         if (scatter_bins_plot          == 'y') { try(source(run_script_command4)) }
         if (scatter_percentiles_plot   == 'y') { try(source(run_script_command5)) }
         if (scatter_skill_plot         == 'y') { try(source(run_script_command6)) }
         if (scatter_mtom_plot          == 'y') { try(source(run_script_command7)) }
      }
   }
   for (m in 1:length(batch_query)) {
      species_list <- c("PM_TOT")
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         sub_dir 	<- batch_names[m]
         figdir 	<- paste(out_dir,sub_dir,species,sep="/")
         mkdir_command 	<- paste("mkdir",figdir)
         system(mkdir_command)
         dates 		<- batch_names[m]
         network_names 	<- c("AQS_Daily")
         network_label 	<- c("AQS_Daily")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (scatter_plot               == 'y') { try(source(run_script_command1)) }
         if (scatter_single_plot        == 'y') { try(source(run_script_command2)) }
         if (scatter_density_plot       == 'y') { try(source(run_script_command3)) }
         if (scatter_bins_plot          == 'y') { try(source(run_script_command4)) }
         if (scatter_percentiles_plot   == 'y') { try(source(run_script_command5)) }
         if (scatter_skill_plot         == 'y') { try(source(run_script_command6)) }
         if (scatter_mtom_plot          == 'y') { try(source(run_script_command7)) }
      }
   }
   for (m in 1:length(batch_query)) {
      species_list <- c("PM_TOT")
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         sub_dir 	<- batch_names[m]
         figdir 	<- paste(out_dir,sub_dir,species,sep="/")
         mkdir_command 	<- paste("mkdir",figdir)
         dates 		<- batch_names[m]
         network_names 	<- c("AQS_Hourly")
         network_label 	<- c("AQS_Hourly")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (scatter_plot               == 'y') { try(source(run_script_command1)) }
         if (scatter_single_plot        == 'y') { try(source(run_script_command2)) }
         if (scatter_density_plot       == 'y') { try(source(run_script_command3)) }
         if (scatter_bins_plot          == 'y') { try(source(run_script_command4)) }
         if (scatter_percentiles_plot   == 'y') { try(source(run_script_command5)) }
         if (scatter_skill_plot         == 'y') { try(source(run_script_command6)) }
         if (scatter_mtom_plot          == 'y') { try(source(run_script_command7)) }
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
         sub_dir	<- batch_names[m]
         figdir 	<- paste(out_dir,sub_dir,species,sep="/")
         mkdir_command 	<- paste("mkdir",figdir)
         network_names	<- c("NADP") 
         network_label	<- c("NADP")
         pid            <- network_label
         query		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (scatter_plot               == 'y') { try(source(run_script_command1)) }
         if (scatter_single_plot        == 'y') { try(source(run_script_command2)) }
         if (scatter_density_plot       == 'y') { try(source(run_script_command3)) }
         if (scatter_bins_plot          == 'y') { try(source(run_script_command4)) }
         if (scatter_percentiles_plot   == 'y') { try(source(run_script_command5)) }
         if (scatter_skill_plot         == 'y') { try(source(run_script_command6)) }
         if (scatter_mtom_plot          == 'y') { try(source(run_script_command7)) }
      }
   }
}
if (gas_analysis == 'y') {	
   averaging <- gas_averaging 
   species_list <- c("O3","SO2","NO2","NOY","CO")
   for (m in 1:length(batch_query)) {
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         dates 		<- batch_names[m]
         sub_dir 	<- batch_names[m]
         figdir         <- paste(out_dir,sub_dir,species,sep="/")
         mkdir_command  <- paste("mkdir",figdir)
         network_names 	<- c("SEARCH")
         network_label 	<- c("SEARCH")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (scatter_plot               == 'y') { try(source(run_script_command1)) }
         if (scatter_single_plot        == 'y') { try(source(run_script_command2)) }
         if (scatter_density_plot       == 'y') { try(source(run_script_command3)) }
         if (scatter_bins_plot          == 'y') { try(source(run_script_command4)) }
         if (scatter_percentiles_plot   == 'y') { try(source(run_script_command5)) }
         if (scatter_skill_plot         == 'y') { try(source(run_script_command6)) }
         if (scatter_mtom_plot          == 'y') { try(source(run_script_command7)) }
      }
   }
   species_list <- c("SO2","NO2","NOX","NOY","CO")
   for (m in 1:length(batch_query)) {
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         dates 		<- batch_names[m]
         sub_dir	<- batch_names[m]
         figdir         <- paste(out_dir,sub_dir,species,sep="/")
         mkdir_command  <- paste("mkdir",figdir)
         network_names 	<- c("AQS_Hourly")
         network_label 	<- c("AQS_Hourly")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (scatter_plot               == 'y') { try(source(run_script_command1)) }
         if (scatter_single_plot        == 'y') { try(source(run_script_command2)) }
         if (scatter_density_plot       == 'y') { try(source(run_script_command3)) }
         if (scatter_bins_plot          == 'y') { try(source(run_script_command4)) }
         if (scatter_percentiles_plot   == 'y') { try(source(run_script_command5)) }
         if (scatter_skill_plot         == 'y') { try(source(run_script_command6)) }
         if (scatter_mtom_plot          == 'y') { try(source(run_script_command7)) }
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
         sub_dir 	<- batch_names[m]
         figdir         <- paste(out_dir,sub_dir,species,sep="/")
         mkdir_command  <- paste("mkdir",figdir)
         network_names 	<- c("CSN")
         network_label 	<- c("CSN")
         pid            <- network_label         
	 query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (scatter_plot               == 'y') { try(source(run_script_command1)) }
         if (scatter_single_plot        == 'y') { try(source(run_script_command2)) }
         if (scatter_density_plot       == 'y') { try(source(run_script_command3)) }
         if (scatter_bins_plot          == 'y') { try(source(run_script_command4)) }
         if (scatter_percentiles_plot   == 'y') { try(source(run_script_command5)) }
         if (scatter_skill_plot         == 'y') { try(source(run_script_command6)) }
         if (scatter_mtom_plot          == 'y') { try(source(run_script_command7)) }
         if (species == "soil") {
            if (scatter_soil_plot       == 'y') { try(source(run_script_command1)) }
         }
      }
   }
   species_list <- c("Na","NaCl","Fe","Al","Si","Ti","Ca","Mg","K","Mn","soil")
   for (m in 1:length(batch_query)) {
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         dates 		<- batch_names[m]
         sub_dir 	<- batch_names[m]
         figdir         <- paste(out_dir,sub_dir,species,sep="/")
         mkdir_command  <- paste("mkdir",figdir)
         network_names 	<- c("IMPROVE")
         network_label 	<- c("IMPROVE")
         pid            <- network_label
         query		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (scatter_plot               == 'y') { try(source(run_script_command1)) }
         if (scatter_single_plot        == 'y') { try(source(run_script_command2)) }
         if (scatter_density_plot       == 'y') { try(source(run_script_command3)) }
         if (scatter_bins_plot          == 'y') { try(source(run_script_command4)) }
         if (scatter_percentiles_plot   == 'y') { try(source(run_script_command5)) }
         if (scatter_skill_plot         == 'y') { try(source(run_script_command6)) }
         if (scatter_mtom_plot          == 'y') { try(source(run_script_command7)) }
         if (species == "soil") {
            if (scatter_soil_plot       == 'y') { try(source(run_script_command1)) }
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
         sub_dir 	<- batch_names[m]
         figdir         <- paste(out_dir,sub_dir,species,sep="/")
         mkdir_command  <- paste("mkdir",figdir)
         system(mkdir_command)
         network_names 	<- c("AERONET")
         network_label 	<- c("AERONET")
         pid            <- network_label
         query <- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (scatter_plot               == 'y') { try(source(run_script_command1)) }
         if (scatter_single_plot        == 'y') { try(source(run_script_command2)) }
         if (scatter_density_plot       == 'y') { try(source(run_script_command3)) }
         if (scatter_bins_plot          == 'y') { try(source(run_script_command4)) }
         if (scatter_percentiles_plot   == 'y') { try(source(run_script_command5)) }
         if (scatter_skill_plot         == 'y') { try(source(run_script_command6)) }
         if (scatter_mtom_plot          == 'y') { try(source(run_script_command7)) }
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
         sub_dir 	<- batch_names[m]
         figdir         <- paste(out_dir,sub_dir,species,sep="/")
         mkdir_command  <- paste("mkdir",figdir)
         network_names 	<- c("AQS_Hourly")
         network_label 	<- c("AQS_Hourly")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (scatter_plot               == 'y') { try(source(run_script_command1)) }
         if (scatter_single_plot        == 'y') { try(source(run_script_command2)) }
         if (scatter_density_plot       == 'y') { try(source(run_script_command3)) }
         if (scatter_bins_plot          == 'y') { try(source(run_script_command4)) }
         if (scatter_percentiles_plot   == 'y') { try(source(run_script_command5)) }
         if (scatter_skill_plot         == 'y') { try(source(run_script_command6)) }
         if (scatter_mtom_plot          == 'y') { try(source(run_script_command7)) }
      }
   }
   species_list <- c("Isoprene","Ethane","Ethylene","Toluene","Acetaldehyde","Formaldehyde")
   for (m in 1:length(batch_query)) {
      for (i in 1:length(species_list)) {
         species 	<- species_list[i]
         dates 		<- batch_names[m]
         sub_dir 	<- batch_names[m]
         figdir         <- paste(out_dir,sub_dir,species,sep="/")
         mkdir_command  <- paste("mkdir",figdir)
         network_names 	<- c("AQS_Daily")
         network_label 	<- c("AQS_Daily")
         pid            <- network_label
         query 		<- paste(query_string,"and (",batch_query[m],")",sep=" ")
         system(mkdir_command)
         if (scatter_plot               == 'y') { try(source(run_script_command1)) }
         if (scatter_single_plot        == 'y') { try(source(run_script_command2)) }
         if (scatter_density_plot       == 'y') { try(source(run_script_command3)) }
         if (scatter_bins_plot          == 'y') { try(source(run_script_command4)) }
         if (scatter_percentiles_plot   == 'y') { try(source(run_script_command5)) }
         if (scatter_skill_plot         == 'y') { try(source(run_script_command6)) }
         if (scatter_mtom_plot          == 'y') { try(source(run_script_command7)) }
      }
   }
}
