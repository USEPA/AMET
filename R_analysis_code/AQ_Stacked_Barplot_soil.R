################################################################
### THIS FILE CONTAINS CODE TO DRAW A CUSTOMIZED "STACKED BAR PLOT".
### The code is interactive with the AMET_AQ system developed by
### Wyat Appel.  Data are queried from the MYSQL database for the STN
### network.  Data are then averaged for Fe, Al, Ti, EC, OC and PM2.5
### for the model and ob values.  These averages are then plotted on
### a stacked bar plot, along with the percent of the total PM2.5
### that each specie comprises.
###
### Last updated by Wyat Appel: June, 2017
################################################################

# get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")		        # base directory of AMET
ametR           <- paste(ametbase,"/R_analysis_code",sep="")    # R directory

## source miscellaneous R input file 
source(paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file

network <- network_names[1]
network_name <- network_label[1]
num_runs <- 1

### Retrieve units and model labels from database table ###
units_qs <- paste("SELECT Fe from project_units where proj_code = '",run_name1,"' and network = '",network,"'", sep="")
model_name_qs <- paste("SELECT model from aq_project_log where proj_code ='",run_name1,"'", sep="")
################################################

### Set filenames and titles ###
filename_pdf    <- paste(run_name1,pid,"stacked_barplot_soil.pdf",sep="_")
filename_png    <- paste(run_name1,pid,"stacked_barplot_soil.png",sep="_")
filename_txt    <- paste(run_name1,pid,"stacked_barplot_data_soil.csv",sep="_")

## Create a full path to file
filename_pdf <- paste(figdir,filename_pdf,sep="/")      # Set PDF filename
filename_png <- paste(figdir,filename_png,sep="/")      # Set PNG filenam
filename_txt <- paste(figdir,filename_txt,sep="/")      # Set output file name

{
   if (use_median == "y") {
      method <- "Median"
   }
   else {
      method <- "Mean"
   }
}

if(!exists("dates")) { dates <- paste(start_date,"-",end_date) }
{
   if (custom_title == "") { title <- paste(network_name," Stacked Barplot (",method,") for ",run_name1," for ",dates,sep="") }
   else { title <- custom_title }
}
################################

if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
   num_runs <- 2
}

medians          <- NULL
data.df          <- NULL
medians_2        <- NULL
data2.df         <- NULL
drop_names     <- NULL
species_names  <- NULL
species_names2 <- NULL
correlation    <- NULL
correlation2   <- NULL
rmse           <- NULL
rmse2          <- NULL
rmse_sys       <- NULL
rmse_sys2      <- NULL
rmse_unsys     <- NULL
rmse_unsys2    <- NULL

criteria <- paste(" WHERE d.Fe_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
species 	<- c("Cl","Na","Fe","Al","Si","Ti","Ca","Mg","K","Mn")
#############################################
### Read sitex file or query the database ###
#############################################
{
   if (Sys.getenv("AMET_DB") == 'F') {
      sitex_info       <- read_sitex(Sys.getenv("OUTDIR"),network,run_name1,species)
      aqdat_query.df   <- sitex_info$sitex_data
      units            <- as.character(sitex_info$units[[1]])
   }
   else {
      query_result    <- query_dbase(run_name1,network,species,criteria)
      aqdat_query.df  <- query_result[[1]]
      units           <- db_Query(units_qs,mysql)
      model_name      <- db_Query(model_name_qs,mysql)
      model_name      <- model_name[[1]]
   }
}
#############################################

if (num_runs > 1) {
   #############################################
   ### Read sitex file or query the database ###
   #############################################
   {
      if (Sys.getenv("AMET_DB") == 'F') {
         sitex_info       <- read_sitex(Sys.getenv("OUTDIR2"),network,run_name2,species)
         aqdat_query2.df  <- sitex_info$sitex_data
         units            <- as.character(sitex_info$units[[1]])
      }
      else {
         query_result2   <- query_dbase(run_name2,network,species,criteria)
         aqdat_query2.df <- query_result2[[1]] 
      }
   }
   #############################################
}

##########################################################
### Average all data for a species into a single value ###
##########################################################
l <- 9							# offset for first species ob value

aqdat_sub.df <- aqdat_query.df
len <- length(aqdat_sub.df)

while (l < len) { 					# loop through each column
   indic.nonzero <- aqdat_sub.df[,l] >= 0		# determine missing data from ob column
   aqdat_sub.df <- aqdat_sub.df[indic.nonzero,]		# remove missing model/ob pairs from dataframe
   l <- l+1
}  

num_sites	<- length(unique(aqdat_sub.df$stat_id))
num_pairs	<- length(aqdat_sub.df$stat_id)   
 
data.df		<- aqdat_sub.df[8:len]
{
   if (use_median == "y") {
      medians.df        <- lapply(data.df,median)
   }
   else {
      medians.df   <- lapply(data.df,mean)
   }
}
##############################################################
if (num_runs > 1) {
   l <- 9                                          # offset for first specie ob value

   aqdat_sub2.df <- aqdat_query2.df
   len <- length(aqdat_sub2.df)

   while (l < len) {                                       # loop through each column
      indic.nonzero <- aqdat_sub2.df[,l] >= 0               # determine missing data from ob column
      aqdat_sub2.df <- aqdat_sub2.df[indic.nonzero,]         # remove missing model/ob pairs from dataframe
      l <- l+1
   }  

   data2.df	<- aqdat_sub2.df[8:len]
   {
   if (use_median == "y") {
      medians2.df        <- lapply(data2.df,median)
   }
   else {
      medians2.df   <- lapply(data2.df,mean)
   }
}
 
   num_sites_2	<- length(unique(aqdat_sub2.df$stat_id)) 
   num_pairs_2	<- length(aqdat_sub2.df$stat_id)
}

########################################################################################
### Calculate percent of total PM2.5 (without other category) each species comprises ###
########################################################################################
total_ob	<- data.df$Cl_ob+data.df$Na_ob+data.df$Fe_ob+data.df$Al_ob+data.df$Ti_ob+data.df$Si_ob+data.df$Ca_ob+data.df$Mg_ob+data.df$K_ob+data.df$Mn_ob
total_mod	<- data.df$Cl_mod+data.df$Na_mod+data.df$Fe_mod+data.df$Al_mod+data.df$Ti_mod+data.df$Si_mod+data.df$Ca_mod+data.df$Mg_mod+data.df$K_mod+data.df$Mn_mod
medians_tot_ob	<- medians.df$Cl_ob+medians.df$Na_ob+medians.df$Fe_ob+medians.df$Al_ob+medians.df$Ti_ob+medians.df$Si_ob+medians.df$Ca_ob+medians.df$Mg_ob+medians.df$K_ob+medians.df$Mn_ob
medians_tot_mod	<- medians.df$Cl_mod+medians.df$Na_mod+medians.df$Fe_mod+medians.df$Al_mod+medians.df$Ti_mod+medians.df$Si_mod+medians.df$Ca_mod+medians.df$Mg_mod+medians.df$K_mod+medians.df$Mn_mod

Cl_ob_percent   <- round(medians.df$Cl_ob/(medians_tot_ob)*100,1)
Na_ob_percent	<- round(medians.df$Na_ob/(medians_tot_ob)*100,1)
Fe_ob_percent	<- round(medians.df$Fe_ob/(medians_tot_ob)*100,1)
Al_ob_percent	<- round(medians.df$Al_ob/(medians_tot_ob)*100,1)
Ti_ob_percent	<- round(medians.df$Ti_ob/(medians_tot_ob)*100,1)
Si_ob_percent	<- round(medians.df$Si_ob/(medians_tot_ob)*100,1)
Ca_ob_percent	<- round(medians.df$Ca_ob/(medians_tot_ob)*100,1)
Mg_ob_percent	<- round(medians.df$Mg_ob/(medians_tot_ob)*100,1)
K_ob_percent	<- round(medians.df$K_ob /(medians_tot_ob)*100,1)
Mn_ob_percent	<- round(medians.df$Mn_ob/(medians_tot_ob)*100,1)

Cl_mod_percent  <- round(medians.df$Cl_mod/(medians_tot_mod)*100,1)
Na_mod_percent  <- round(medians.df$Na_mod/(medians_tot_mod)*100,1)
Fe_mod_percent	<- round(medians.df$Fe_mod/(medians_tot_mod)*100,1)
Al_mod_percent	<- round(medians.df$Al_mod/(medians_tot_mod)*100,1)
Ti_mod_percent	<- round(medians.df$Ti_mod/(medians_tot_mod)*100,1)
Si_mod_percent	<- round(medians.df$Si_mod/(medians_tot_mod)*100,1)
Ca_mod_percent  <- round(medians.df$Ca_mod/(medians_tot_mod)*100,1)
Mg_mod_percent  <- round(medians.df$Mg_mod/(medians_tot_mod)*100,1)
K_mod_percent	<- round(medians.df$K_mod /(medians_tot_mod)*100,1)
Mn_mod_percent  <- round(medians.df$Mn_mod/(medians_tot_mod)*100,1)

correlation	<- round(cor(total_mod, total_ob),2)
rmse		<- round(sqrt(c(rmse, sum((total_mod - total_ob)^2)/length(total_ob))),2)
ls_regress	<- lsfit(total_ob,total_mod)
intercept	<- ls_regress$coefficients[1]
X		<- ls_regress$coefficients[2]
rmse_sys	<- round(sqrt(c(rmse_sys, sum(((intercept+X*total_ob) - total_ob)^2))/length(total_ob)),2)
rmse_unsys	<- round(sqrt(c(rmse_unsys, sum((total_mod - (intercept+X*total_ob))^2)/length(total_ob))),2)
index_agree	<- round(1-((sum((total_ob-total_mod)^2))/(sum((abs(total_mod-mean(total_ob))+abs(total_ob-mean(total_ob)))^2))),2)
   
if (num_runs > 1) {
    total_ob2		<- data2.df$Cl_ob+data2.df$Na_ob+data2.df$Fe_ob+data2.df$Al_ob+data2.df$Ti_ob+data2.df$Si_ob+data2.df$Ca_ob+data2.df$Mg_ob+data2.df$K_ob+data2.df$Mn_ob
    total_mod2		<- data2.df$Cl_mod+data2.df$Na_mod+data2.df$Fe_mod+data2.df$Al_mod+data2.df$Ti_mod+data2.df$Si_mod+data2.df$Ca_mod+data2.df$Mg_mod+data2.df$K_mod+data2.df$Mn_mod
    medians_tot_mod2	<- medians2.df$Cl_mod+medians2.df$Na_mod+medians2.df$Fe_mod+medians2.df$Al_mod+medians2.df$Ti_mod+medians2.df$Si_mod+medians2.df$Ca_mod+medians2.df$Mg_mod+medians2.df$K_mod+medians2.df$Mn_mod

   Cl_mod_percent2	<- round(medians2.df$Cl_mod/(medians_tot_mod2)*100,1)
   Na_mod_percent2	<- round(medians2.df$Na_mod/(medians_tot_mod2)*100,1)
   Fe_mod_percent2	<- round(medians2.df$Fe_mod/(medians_tot_mod2)*100,1)
   Al_mod_percent2	<- round(medians2.df$Al_mod/(medians_tot_mod2)*100,1)
   Ti_mod_percent2	<- round(medians2.df$Ti_mod/(medians_tot_mod2)*100,1)
   Si_mod_percent2	<- round(medians2.df$Si_mod/(medians_tot_mod2)*100,1)
   Ca_mod_percent2	<- round(medians2.df$Ca_mod/(medians_tot_mod2)*100,1)
   Mg_mod_percent2	<- round(medians2.df$Mg_mod/(medians_tot_mod2)*100,1)
   K_mod_percent2	<- round(medians2.df$K_mod /(medians_tot_mod2)*100,1)
   Mn_mod_percent2	<- round(medians2.df$Mn_mod/(medians_tot_mod2)*100,1)

   correlation2 <- round(cor(total_mod2, total_ob2),2) 
   rmse2        <- round(sqrt(c(rmse2, sum((total_mod2 - total_ob2)^2)/length(total_ob2))),2)
   ls_regress   <- lsfit(total_ob2,total_mod2)
   intercept    <- ls_regress$coefficients[1]
   X            <- ls_regress$coefficients[2]
   rmse_sys2    <- round(sqrt(c(rmse_sys2, sum(((intercept+X*total_ob2) - total_ob2)^2))/length(total_ob2)),2)
   rmse_unsys2  <- round(sqrt(c(rmse_unsys2, sum((total_mod2 - (intercept+X*total_ob2))^2)/length(total_ob2))),2)
   index_agree2 <- round(1-((sum((total_ob2-total_mod2)^2))/(sum((abs(total_mod2-mean(total_ob2))+abs(total_ob2-mean(total_ob2)))^2))),2)
}
###############################################################

data_matrix <- matrix(c(medians.df$Fe_ob,medians.df$Fe_mod,medians.df$Al_ob,medians.df$Al_mod,medians.df$Ti_ob,medians.df$Ti_mod,medians.df$Si_ob,medians.df$Si_mod,medians.df$Ca_ob,medians.df$Ca_mod,medians.df$Mg_ob,medians.df$Mg_mod,medians.df$K_ob,medians.df$K_mod,medians.df$Mn_ob,medians.df$Mn_mod,medians.df$Cl_ob,medians.df$Cl_mod,medians.df$Na_ob,medians.df$Na_mod),byrow=T,ncol=2)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
yaxis.max   <- max(c(sum(data_matrix[,1]),sum(data_matrix[,2])))*1.1        # find the max of the average values to set y-axis max

if (num_runs > 1) {
    data_matrix <- matrix(c(medians.df$Fe_ob,medians.df$Fe_mod,medians2.df$Fe_mod,medians.df$Al_ob,medians.df$Al_mod,medians2.df$Al_mod,medians.df$Ti_ob,medians.df$Ti_mod,medians2.df$Ti_mod,medians.df$Si_ob,medians.df$Si_mod,medians2.df$Si_mod,medians.df$Ca_ob,medians.df$Ca_mod,medians2.df$Ca_mod,medians.df$Mg_ob,medians.df$Mg_mod,medians2.df$Mg_mod,medians.df$K_ob,medians.df$K_mod,medians2.df$K_mod,medians.df$Mn_ob,medians.df$Mn_mod,medians2.df$Mn_mod,medians.df$Cl_ob,medians.df$Cl_mod,medians2.df$Cl_mod,medians.df$Na_ob,medians.df$Na_mod,medians2.df$Na_mod),byrow=T,ncol=3)  # create matrix of average values needed by barplot, 2 columns (ob,model) and species by row
   yaxis.max   <- (max(c(sum(data_matrix[,1]),sum(data_matrix[,2]),sum(data_matrix[,3]))))*1.1        # find the max of the average values to set y-axis max
}

if (length(y_axis_max) > 0) {
   yaxis.max <- y_axis_max
}

{
   if (num_runs > 1) {
      simulations	<- paste(network_name,run_name1,run_name2,sep=",")
      sim_names		<- c(network_name,"Simulation 1","Simulation 2")
   }
   else {
      simulations	<- paste(network_name,run_name1,sep="")
      sim_names		<- c(network_name,run_name1)
   }
}
write.table(simulations,file=filename_txt,append=F,col.names=F,row.names=F,sep=",")
write.table("Observed, Modeled",file=filename_txt,append=T,col.names=F,row.names=F,sep=",")
write.table(data_matrix,file=filename_txt,append=T,col.names=F,row.names=c("Fe","Al","Ti","Si","Ca","Mg","K","Mn","Cl","Na"),sep=",")

########## MAKE STACKED BARPLOT: ALL SITES ##########

species_names <- c("Na","Cl","Mn","K","Mg","Ca","Si","Ti","Al","Fe")
plot_cols     <- c("brown4","purple","seagreen1","grey","white","blue","yellow","orange","light blue","red3")
plot_cols_leg <- c("red3","light blue","orange","yellow","blue","white","grey","seagreen1","purple","brown4")

pdf(file=filename_pdf,width=10,height=8)
par(mai=c(1,1,0.5,0.5))		# set margins

{
   if (num_runs == 1) {
      barplot(data_matrix, beside=FALSE, ylab="Mean Concentration (ug/m3)",names.arg=sim_names,width=0.5,xlim=c(0,2),ylim=c(0,yaxis.max),col=plot_cols,xpd=F,space=.6,cex.axis=1.4,cex.names=1.2,cex.lab=1.2)
      x1_adjust <- 1
      x2_adjust <- 1
   }
   else {
      barplot(data_matrix, beside=FALSE, ylab="Mean Concentration (ug/m3)",names.arg=sim_names,width=0.3,xlim=c(0,2),ylim=c(0,yaxis.max),col=plot_cols,xpd=F,space=.9,cex.axis=1.4,cex.names=1.2,cex.lab=1.2)
      x1_adjust <- .91
      x2_adjust <- .77
   }
}
legend("topright",species_names,fill=plot_cols_leg,cex=1.2)

x1 <- x1_adjust*.27
x2 <- x2_adjust*1.08
x3 <- 1.4

#########################################################################
### Add percentage values next to each specie on the stacked bar plot ###
#########################################################################
text(x1,(medians.df$Fe_ob/2),paste(Fe_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$Fe_ob+(medians.df$Al_ob/2)),paste(Al_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$Fe_ob+medians.df$Al_ob+(medians.df$Ti_ob/2)),paste(Ti_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$Fe_ob+medians.df$Al_ob+medians.df$Ti_ob+(medians.df$Si_ob/2)),paste(Si_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$Fe_ob+medians.df$Al_ob+medians.df$Ti_ob+medians.df$Si_ob+(medians.df$Ca_ob/2)),paste(Ca_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$Fe_ob+medians.df$Al_ob+medians.df$Ti_ob+medians.df$Si_ob+medians.df$Ca_ob+(medians.df$Mg_ob/2)),paste(Mg_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$Fe_ob+medians.df$Al_ob+medians.df$Ti_ob+medians.df$Si_ob+medians.df$Ca_ob+medians.df$Mg_ob+(medians.df$K_ob/2)),paste(K_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$Fe_ob+medians.df$Al_ob+medians.df$Ti_ob+medians.df$Si_ob+medians.df$Ca_ob+medians.df$Mg_ob+medians.df$K_ob+(medians.df$Mn_ob/2)),paste(Mn_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$Fe_ob+medians.df$Al_ob+medians.df$Ti_ob+medians.df$Si_ob+medians.df$Ca_ob+medians.df$Mg_ob+medians.df$K_ob+(medians.df$Mn_ob)+(medians.df$Cl_ob/2)),paste(Cl_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x1,(medians.df$Fe_ob+medians.df$Al_ob+medians.df$Ti_ob+medians.df$Si_ob+medians.df$Ca_ob+medians.df$Mg_ob+medians.df$K_ob+(medians.df$Mn_ob)+(medians.df$Cl_ob)+(medians.df$Na_ob/2)),paste(Na_ob_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))

text(x2,(medians.df$Fe_mod/2),paste(Fe_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x2,(medians.df$Fe_mod+(medians.df$Al_mod/2)),paste(Al_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x2,(medians.df$Fe_mod+medians.df$Al_mod+(medians.df$Ti_mod/2)),paste(Ti_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x2,(medians.df$Fe_mod+medians.df$Al_mod+medians.df$Ti_mod+(medians.df$Si_mod/2)),paste(Si_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x2,(medians.df$Fe_mod+medians.df$Al_mod+medians.df$Ti_mod+medians.df$Si_mod+(medians.df$Ca_mod/2)),paste(Ca_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x2,(medians.df$Fe_mod+medians.df$Al_mod+medians.df$Ti_mod+medians.df$Si_mod+medians.df$Ca_mod+(medians.df$Mg_mod/2)),paste(Mg_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x2,(medians.df$Fe_mod+medians.df$Al_mod+medians.df$Ti_mod+medians.df$Si_mod+medians.df$Ca_mod+medians.df$Mg_mod+(medians.df$K_mod/2)),paste(K_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x2,(medians.df$Fe_mod+medians.df$Al_mod+medians.df$Ti_mod+medians.df$Si_mod+medians.df$Ca_mod+medians.df$Mg_mod+medians.df$K_mod+(medians.df$Mn_mod/2)),paste(Mn_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x2,(medians.df$Fe_mod+medians.df$Al_mod+medians.df$Ti_mod+medians.df$Si_mod+medians.df$Ca_mod+medians.df$Mg_mod+medians.df$K_mod+medians.df$Mn_mod+(medians.df$Cl_mod/2)),paste(Cl_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))
text(x2,(medians.df$Fe_mod+medians.df$Al_mod+medians.df$Ti_mod+medians.df$Si_mod+medians.df$Ca_mod+medians.df$Mg_mod+medians.df$K_mod+medians.df$Mn_mod+medians.df$Cl_mod+(medians.df$Na_mod/2)),paste(Na_mod_percent,"% --",sep=""),cex=1.2,adj=c(1,0.5))

if (num_runs > 1) {
   text(x3,(medians2.df$Fe_mod/2),paste(Fe_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x3,(medians2.df$Fe_mod+(medians2.df$Al_mod/2)),paste(Al_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x3,(medians2.df$Fe_mod+medians2.df$Al_mod+(medians2.df$Ti_mod/2)),paste(Ti_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x3,(medians2.df$Fe_mod+medians2.df$Al_mod+medians2.df$Ti_mod+(medians2.df$Si_mod/2)),paste(Si_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x3,(medians2.df$Fe_mod+medians2.df$Al_mod+medians2.df$Ti_mod+medians2.df$Si_mod+(medians2.df$Ca_mod/2)),paste(Ca_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x3,(medians2.df$Fe_mod+medians2.df$Al_mod+medians2.df$Ti_mod+medians2.df$Si_mod+medians2.df$Ca_mod+(medians2.df$Mg_mod/2)),paste(Mg_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x3,(medians2.df$Fe_mod+medians2.df$Al_mod+medians2.df$Ti_mod+medians2.df$Si_mod+medians2.df$Ca_mod+medians2.df$Mg_mod+(medians2.df$K_mod/2)),paste(K_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x3,(medians2.df$Fe_mod+medians2.df$Al_mod+medians2.df$Ti_mod+medians2.df$Si_mod+medians2.df$Ca_mod+medians2.df$Mg_mod+medians2.df$K_mod+(medians2.df$Mn_mod/2)),paste(Mn_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x3,(medians2.df$Fe_mod+medians2.df$Al_mod+medians2.df$Ti_mod+medians2.df$Si_mod+medians2.df$Ca_mod+medians2.df$Mg_mod+medians2.df$K_mod+medians2.df$Mn_mod+(medians2.df$Cl_mod/2)),paste(Cl_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
   text(x3,(medians2.df$Fe_mod+medians2.df$Al_mod+medians2.df$Ti_mod+medians2.df$Si_mod+medians2.df$Ca_mod+medians2.df$Mg_mod+medians2.df$K_mod+medians2.df$Mn_mod+medians2.df$Cl_mod+(medians2.df$Na_mod/2)),paste(Na_mod_percent2,"% --",sep=""),cex=1.2,adj=c(1,0.5))
}
##########################################################################

############################################################
### Add number of sites and number of obs counts to plot ###
############################################################
text(2.07,yaxis.max*.53,paste("# of sites: ",num_sites,sep=""),cex=1.2,adj=c(1,0))
text(2.07,yaxis.max*.49,paste("# of obs: ",num_pairs,sep=""),cex=1.2,adj=c(1,0))
if (run_info_text == "y") {
   if (rpo != "None") {
      text(2.07,yaxis.max*.55,paste("RPO: ",rpo,sep=""),cex=1,adj=c(1,0))
   }
   if (pca != "None") {
      text(2.07,yaxis.max*.51,paste("PCA: ",pca,sep=""),cex=1,adj=c(1,0))
   }
   if (site != "All") {
      text(2.07,yaxis.max*.47,paste("Site: ",site,sep=""),cex=1,adj=c(1,0))
   }
   if (state != "All") {
      text(2.07,yaxis.max*.44,paste("State: ",state,sep=""),cex=1,adj=c(1,0))
   }
} 
############################################################

###################################
### Add statistics to plot area ###
###################################
text(2.07,yaxis.max*.35,paste("RMSE: ",rmse,sep=""),cex=1,adj=c(1,0))
text(2.07,yaxis.max*.32,paste("RMSEs: ",rmse_sys,sep=""),cex=1,adj=c(1,0))
text(2.07,yaxis.max*.29,paste("RMSEu: ",rmse_unsys,sep=""),cex=1,adj=c(1,0))
text(2.07,yaxis.max*.26,paste("IA:   ",index_agree,sep=""),cex=1,adj=c(1,0))
text(2.07,yaxis.max*.23,paste("r:   ",correlation,sep=""),cex=1,adj=c(1,0))

if (num_runs > 1) {
   ### Add statistics to plot area ###
   text(0,yaxis.max*0.95,paste("Sim 1:",run_name1),cex=1,adj=c(0,0))
   text(0,yaxis.max*0.92,paste("Sim 2:",run_name2),cex=1,adj=c(0,0))
   text(2.07,yaxis.max*.38,"Simulation 1",cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.16,"Simulation 2",cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.13,paste("RMSE: ",rmse2,sep=""),cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.10,paste("RMSEs: ",rmse_sys2,sep=""),cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.07,paste("RMSEu: ",rmse_unsys2,sep=""),cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.04,paste("IA:   ",index_agree2,sep=""),cex=1,adj=c(1,0))
   text(2.07,yaxis.max*.01,paste("r:   ",correlation2,sep=""),cex=1,adj=c(1,0))
}
######################################

## Put title at top of barplot ##
title(main=title,cex.main=1)

## Convert pdf to png ##
dev.off()
if ((ametptype == "png") || (ametptype == "both")) {
   convert_command<-paste("convert -flatten -density ",png_res,"x",png_res," ",filename_pdf," png:",filename_png,sep="")
   system(convert_command)

   if (ametptype == "png") {
      remove_command <- paste("rm ",filename_pdf,sep="")
      system(remove_command)
   }
}
########################


