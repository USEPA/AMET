##################### SOCCER GOAL PLOT #########################
### AMET CODE: R_Soccerplot.R
###
### This script is part of the AMET-AQ system.  It plots a unique
### type of plot referred to as a "soccer goal" plot. The idea behind
### the soccer goal plot is that criteria and goal lines are plotted
### in such a way as to form a "soccer goal" on the plot area.  Two
### statistics are then plotted, Bias (NMB, FB, NMdnB) on the x-axis and
### error (NME, FE, NMdnE) on the y-axis.  The better the performance of the
### model, the closer the plotted points will fall within the "goal"
### lines.  This type of plot is used by EPA and RPOs as part of their
### assessment of model performance.
###
### Update since AMETv1.1:
### Note that the script no longer accepts "All" as a species, as the large 
### number of species now available prohibits this. Instead, the user may 
### now specify a list of species to include. This creates a more useful plot, 
### as the user is not bound to all the species available for each network.
###
### Last updated by Wyat Appel; December, 2012
###
### Modified to work with combined MET/AQ mode, Alexis Zubrow (IE UNC) Nov, 2007
###
################################################################

## get some environmental variables and setup some directories
ametbase<-Sys.getenv("AMETBASE")                        # base directory of AMET
dbase<-Sys.getenv("AMET_DATABASE")      # AMET database
ametR<-paste(ametbase,"/R",sep="")                    # R directory
ametRinput <- Sys.getenv("AMETRINPUT")                # input file for this script
ametptype <- Sys.getenv("AMET_PTYPE")    # Prefered output type

## Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
## and not specified via AMET_OUT, then set figdir to the current directory
if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")       }
if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"                 }

## source some configuration files, AMET libs, and input
source(paste(ametbase,"/configure/amet-config.R",sep=""))
source (paste(ametR,"/AQ_Misc_Functions.R",sep=""))     # Miscellanous AMET R-functions file
source (ametRinput)                                     # Anaysis configuration/input file
source (ametNetworkInput) # Network related input

## Load Required Libraries
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}
if(!require(Hmisc)){stop("Required Package Hmisc was not loaded")}

mysql <- list(login=login, passwd=passwd, server=server, dbase=dbase, maxrec=maxrec)            # Set MYSQL login and query options

### Retrieve units label from database table ###
network <- network_names[1]
run_name <- run_name1
#################################################

### Set file names and titles ###
outname_pdf <- paste(run_name1,"soccerplot_sites.pdf",sep="_")
outname2_pdf <- paste(run_name1,"soccerplot.pdf",sep="_")
outname_png <- paste(run_name1,"soccerplot_sites.png",sep="_")
outname2_png <- paste(run_name1,"soccerplot.png",sep="_")
{
   if (custom_title == "") { title <- paste("Soccergoal plot for ",run_name1," for ",dates,"; State=",state,"; Site=",site,sep="") }
   else { title <- custom_title }
}

## Create a full path to file
outname_pdf <- paste(figdir,outname_pdf,sep="/")
outname2_pdf <- paste(figdir,outname2_pdf,sep="/")
outname_png <- paste(figdir,outname_png,sep="/")
outname2_png <- paste(figdir,outname2_png,sep="/")

#################################

### Set initial NULL vectors ###
plotinfo  <- NULL
plot_vals <- NULL
################################

 writeLines(species[1])
#species <- c(species)
species_query <- paste("d.",species[1],"_ob, d.",species[1],"_mod",sep="")
if (length(species) > 1) {
   for (i in 2:length(species)) {
      species_query <- paste(species_query,",d.",species[i],"_ob, d.",species[i],"_mod",sep="")
   }
}

for (j in 1:length(network_names)) {	# Loop through each network
   mean_obs      <- NULL
   mean_mod      <- NULL
   nmb           <- NULL				
   nme           <- NULL
   fb            <- NULL
   fe            <- NULL
   nmdnb	 <- NULL
   nmdne	 <- NULL
   network       <- network_names[[j]]						# Set network name based on loop value
   query <- paste(" and s.stat_id=d.stat_id and d.ob_dates BETWEEN",start_date,"and",end_date,"and d.ob_datee BETWEEN",start_date,"and",end_date,"and ob_hour between",start_hour,"and",end_hour,add_query,sep=" ")
   criteria <- paste(" WHERE d.",species[1],"_ob is not NULL and d.network='",network,"' ",query,sep="")          # Set part of the MYSQL query
   qs	<- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month,",species_query,",d.precip_ob from ",run_name1," as d, site_metadata as s",criteria," ORDER BY network,stat_id",sep="")    # Set the rest of the MYSQL query 
   aqdat_all.df      <- db_Query(qs,mysql)						# Query the database for a specific species

   l <- 9
   for (i in 1:length(species)) { 								# For each species, calculate several statistics
     data_all.df <- data.frame(network=I(aqdat_all.df$network),stat_id=I(aqdat_all.df$stat_id),lat=aqdat_all.df$lat,lon=aqdat_all.df$lon,ob_val=aqdat_all.df[,l],mod_val=aqdat_all.df[,(l+1)],precip_val=aqdat_all.df$precip_ob)	# Create properly formatted dataframe to use with DomainStats function
      good_count <- sum(!is.na(data_all.df$ob_val))		# Count the number of non-missing values
      if (good_count > 0) {					# If there are non-missing values, continue
         stats_all.df <- DomainStats(data_all.df)		# Call DomainStats function to compute stats for the entire domain
         if (!is.null(stats_all.df)) {
            mean_obs <- c(mean_obs,stats_all.df$MEAN_OBS) 
            mean_mod <- c(mean_mod,stats_all.df$MEAN_MODEL)
            nmb <- c(nmb,stats_all.df$Percent_Norm_Mean_Bias)	# Store NMB values from DomainStats in vector called nmb
            nme <- c(nme,stats_all.df$Percent_Norm_Mean_Err)	# Store NME values from DomainStats in vector called nme
            fb  <- c(fb,stats_all.df$Frac_Bias)			# Store FB values from DomainStats in vector called fb
            fe  <- c(fe,stats_all.df$Frac_Err)			# Store FE values from DomainStats in vector called fe
            nmdnb <- c(nmdnb,stats_all.df$Norm_Median_Bias)	# Store NMdnB values in vector
            nmdne <- c(nmdne,stats_all.df$Norm_Median_Error)	# Store NmdnE values in vector
         }
         else {
            mean_obs <- c(mean_obs,NA)
            mean_mod <- c(mean_mod,NA)
            nmb      <- c(nmb,NA)
            nme      <- c(nme,NA)
            fb       <- c(fb,NA)
            fe       <- c(fe,NA)
            nmdnb    <- c(nmdnb,NA)
            nmdne    <- c(nmdne,NA)
         } 
      }
      else {				# If all values are missing, set statistic value to NA
         mean_obs <- c(mean_obs,NA)
         mean_mod <- c(mean_mod,NA)
         nmb	  <- c(nmb,NA)
         nme	  <- c(nme,NA)
         fb	  <- c(fb,NA)
         fe	  <- c(fe,NA)
         nmdnb	  <- c(nmdnb,NA)
         nmdne	  <- c(nmdne,NA)
      }
      l   <- l+2								# Increment to next ob specie column
      i <- i+1
   }

   if (soccerplot_opt == 1) { 							# If user selected to use NMB/NME for plot axes	
      plot_vals[[j]] <- list(Species=species,VAL1=nmb,VAL2=nme) 		# Set plot values to be used as nmb and nme vectors
      xlabel <- "Normalized Mean Bias (%)"					# Set x-axis label as NMB
      ylabel <- "Normalized Mean Error (%)"					# Set y-axis label as NME
   }
   if (soccerplot_opt == 2) { 									# Else use FB/FE for plot axes
      plot_vals[[j]] <- list(Species=species,VAL1=fb,VAL2=fe)		# Set plot values to be used as fb and fe vectors
      xlabel <- "Fractional Bias (%)"						# Set x-axis label as FB
      ylabel <- "Fractional Error (%)"						# Set y-axis label as FE
   }
   if (soccerplot_opt == 3) {
      plot_vals[[j]] <- list(Species=species,VAL1=nmdnb,VAL2=nmdne)	# Set plot values to be used as fb and fe vectors
      xlabel <- "Normalized Median Bias (%)"					# Set x-axis label as NMdnB
      ylabel <- "Normalized Median Error (%)"					# Set y-axis label as NMdnE
   }
}

####################################

#plot_chars <- c(0,2,3,4,5,6,8)							# Set plot characters to use
plot_chars <- seq(from=1,to=30,by=1)
plot_cols  <- c("red","blue","green4","orange","purple","brown","yellow4","darkgreen","blue3")	# Set plot colors to use
#plot_colors <- c("red","red4","blue","blue4","green","darkgreen","orange","orange4","brown","yellow4","darkorchid4","lightpink2","mediumvioletred","slategray4")

###########################################################
########## MAKE SOCCERPLOT: DOMAIN / All SPECIES ##########
###########################################################

pdf(file=outname2_pdf,width=10,height=8)
par(mai=c(1,1,0.5,1))									# Set margins
plot(1, 1, type="n",pch=2, col="green", ylim=c(4.8,125), xlim=c(-85, 85), xlab=xlabel, ylab=ylabel, cex.axis=1.2, cex.lab=1.4, axes=FALSE)
axis(1,at=c(-100,-75,-60,-45,-30,-15,0,15,30,45,60,75,100),cex.axis=1.4) 		# Create x-axis
axis(2,at=c(0,25,50,75,100,125),cex.axis=1.4,las=2)					# Create left side y-axis
axis(4,at=c(0,25,50,75,100,125),cex.axis=1.4,las=2)					# Create right side y-axis
mtext(ylabel,side=4,adj=0.5,line=3,cex=1.4)
lines(c(0,0),c(0,125))									# Draw center line
abline(h=125) 										# Create top border line
rect(ybottom=0,ytop=35,xright=15,xleft=-15,lty=2,lwd=1,border="grey45")			# Create rectangle for 35/15 box
rect(ybottom=0,ytop=50,xright=30,xleft=-30,lty=2,lwd=1,border="grey45")			# Create rectangle for 75/30 box
rect(ybottom=0,ytop=75,xright=60,xleft=-60,lty=2,lwd=1,border="grey45")
text(-3,35,"35",cex=1.2)								# Add text for 35% goal line
text(-3,50,"50",cex=1.2)								# Add text for 50% goal line
text(-3,75,"75",cex=1.2) 								# Add text for 75% goal line
abline(h=0)

legend_names <- species
legend_chars <- plot_chars
values <- NULL 
for (n in 1:length(network_names)) {							# For each network, plot values as points
   y <- c(120,115,110,105,100,95,90,85)							# Y offsets for network labels (used below)
   for (i in 1:length(species)) {							# Plot each available species
      points(plot_vals[[n]]$VAL1[i],plot_vals[[n]]$VAL2[i],pch=plot_chars[i],col=plot_cols[n],cex=2)            # Plot points using the appropriate character
   } 
   text(50,y[n],network_label[n],col=plot_cols[n],pos=4,cex=1.3)			# Add text for the network on the plot area
}

### Put title at top of boxplot ###
title(main=title,cex.main=1.2)
###################################

### Put legend on the plot ###
legend(-90,125, legend_names, pch=legend_chars, col="black", merge=F, cex=1.3, bty="n")
##############################

### Convert pdf format file to png format ###
dev.off()
convert_command<-paste("convert -density 150x150 ",outname2_pdf," png:",outname2_png,sep="")
#dev.off()
system(convert_command)
#############################################

