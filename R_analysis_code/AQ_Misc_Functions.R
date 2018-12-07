#########################################################################
#-----------------------------------------------------------------------#
#						 			#
#			Miscellanous Functions				#
#						 			#
# A collection of functions used in the AMET system. Functions Include: #
#       db_Query							#
#	mcipFileLookup							#
#	gen_cormatrix				 			#
#	plotSpatial							#	
#	DomainStats							#
#	SitesStats							#
#	Average								#
#									#
#	Version: 	1.2					 	#
#	Last UpDate:	May 29, 2009					#
#	Contributors:	Wyat Appel, Robert Gilliam			#
#						 			#
#   Developed by and for EPA, NERL, AMAD 				#
#-----------------------------------------------------------------------#
#########################################################################

##############################
### Get some common R info ###
##############################

## get some environmental variables and setup some directories
ametbase        <- Sys.getenv("AMETBASE")                       # base directory of AMET
dbase           <- Sys.getenv("AMET_DATABASE")                  # AMET database
ametRinput      <- Sys.getenv("AMETRINPUT")                     # input file for this script
ametptype       <- Sys.getenv("AMET_PTYPE")                     # Prefered output type
config_file     <- Sys.getenv("MYSQL_CONFIG")                   # MySQL configuration file 

## source some configuration files, AMET libs, and input
source (config_file)
if(ametRinput != "") {
   source (ametRinput)  # Anaysis configuration/input file
}

## Check for output directory via namelist and AMET_OUT env var, if not specified in namelist
## and not specified via AMET_OUT, then set figdir to the current directory
if(!exists("figdir") )                         { figdir <- Sys.getenv("AMET_OUT")       }
if( length(unlist(strsplit(figdir,""))) == 0 ) { figdir <- "./"                 }

## Load Required Libraries
if(!require(RMySQL)){stop("Required Package RMySQL was not loaded")}

mysql <- list(login=amet_login, passwd=amet_pass, server=mysql_server, dbase=dbase, maxrec=maxrec)           # Set MYSQL login and query options
##############################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
#
# Written by Chris Nolte, 7/7/06
# Create labeled rectangles for color maps.
# original code: /home/nolte/misc/R/mylegend.r
#

#
# Revised by Kristen Foley, 4/19/11  
# (Code change: New option to provide
#  labels.  Also now includes a label at the
#  bottom of the first bin and the very
# very top bin.)
#

mylegend <- function(x,y,dx=NULL,dy=NULL,cols,bounds,fmt=NA,labels=NULL,
                     cex=1,xw=3,yo=2.5, horizontal=FALSE, ...) {
if (length(cols) != (length(bounds)-1)) {
    print(cols)
    print(bounds)
    stop ('mylegend: there should be one more break than color')
  }
  nrect <- length(cols)

  if(is.null(labels)){
    if (!is.na(fmt)) {
      labels <- c(sprintf(fmt,bounds))
    } else {
      labels <- c(bounds)
    }
  }

  parm <- par('usr')
  deltax <- parm[2] - parm[1]
  deltay <- parm[4] - parm[3]
  if (horizontal) {
    if (is.null(dx)) dx <- 0.96*deltax/nrect
    if (is.null(dy)) dy <- 0.04*deltay
    rect.b <- rep(y,nrect)
    rect.l <- seq(from=x, by=dx, length.out=nrect)
    rect.l.lab <- seq(from=x, by=dx, length.out=nrect+1)
    text(x=rect.l.lab, y=rect.b-yo*dy, labels=labels, adj=c(0.5,0),cex=cex)
  } else {
    if (is.null(dx)) dx <- 0.03*deltax
    if (is.null(dy)) dy <- 0.90*deltay/nrect
    rect.l <- rep(x,nrect)
    rect.b <- seq(from=y, by=dy, length.out=nrect)
    rect.b.lab <- seq(from=y, by=dy, length.out=nrect+1)
    text(x=rect.l + xw*dx, y=rect.b.lab, labels=labels, adj=c(0,0.5),cex=cex)
  }
  rect.r <- rect.l + dx
  rect.t <- rect.b + dy
  rect(rect.l, rect.b, rect.r, rect.t, col=cols, border="black")
}

##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Query CIRAQ MySQL database
#
# Input: Standard MySQL query string (query) (e.g. query<-"SELECT stat_id from stations where state='NC' " )
#   also, the maximum number of records (maxrec). Setting maxrec to a lower number will increase the speed
#   of the connection and retrieval of the data. Database (dbase), password (passwd)
#   
# Output: A data frames with all data from query criterion. Columns= variables, Rows=records
#   
#
# Options: The maximum record (maxrec) is an option. The default is set to a resonably low value (100,000)
#   		login is optional, default is gilliam. Server (server) is also optional, default is snow
#
#
#   Query for station data 
#   "select v.metric_value, stat.lat, stat.lon from STATS v, stations stat  where v.query_id='qstatwint' and v.metric_id='mbias' and v.var_id='T'and stat.stat_id=v.stat_id" 
#    plotSpatialUS(sinfo,"MM5_2001 Surface Stations","mm52001.stat.pdf") 
#
# NOTE: 
#   
###
 	db_Query<-function(query,mysql,get=1,verbose=FALSE)
 {
  db<-dbDriver("MySQL")				# MySQL Database type
  con <-dbConnect(db,user=mysql$login,pass=mysql$passwd,host=mysql$server,dbname=mysql$dbase)		# Database connect

  for (q in 1:length(query)){
    rs<-dbSendQuery(con,query[q])	# Send query and place results in data frame
    if(verbose){ print(query[q]) }
  }
  if(get == 1){df<-fetch(rs,n=mysql$maxrec)}
  
  dbClearResult(rs)
  dbDisconnect(con)		# Database disconnect
  
  return(df)

 }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Query CIRAQ MySQL database
#
# Input: MCIP variable lookup file and variable of interest
#   
# Output: List contaning the variable of interest, the file and variable description
#   
#
# Options:
#
# NOTE: 
#   
###
 	mcipFileLookup<-function(lookup,var)
 {

  # Open connection to MCIP variable lookup file and put lines into array
  con <- file(lookup, "r", blocking = FALSE)
  lines<-readLines(con) # empty
 
 file <-array(NA,c(length(var)))
 filen<-array(NA,c(length(var)))
 vdesc<-array(NA,c(length(var)))
 
 for(v in 1:length(var)){
  # Loop through each line, find variable and corresponding MCIP file type and variable description
  for(l in 1:length(lines)){

       wrds<-unlist(strsplit(lines[l],"\t"))
       head<-unlist(strsplit(lines[l]," "))

       if(head[1] == "&"){
            filepre<-head[2]
            filehand<-head[3]
       }
     
       if(wrds[1] == var[v]){
            file[v] <-filepre
            filen[v]<-as.numeric(filehand)
            vdesc[v]<-wrds[3]
       }
  }
 }  
  var<-list(var=var,ftype=file,filen=filen,desc=vdesc)
  return(var)

 }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Generate a correlation matrix from a matrix of variables
#
# Input: variable matrix (varm), variable id's (varid)
#   
# Output: A data fram that contatians the correlation between all variables
#   	  in the variable matrix
#
# Options:  Logical to generate a text file with correlation values (gentext), default
#	    is false. Text file name. The default will be generate in the run directory
#	    with the name correlation.matrix.dat.
# NOTE: 
#   
###
 	gen_cormatrix<-function(varm,varid,nstat,mask,
 				gentext=T,textfile="correlation.matrix.dat",
 				corrplot=T,corfig="correlation.matrix"		)
 {

      novar<-length(varid)
      cormatrix<-array(1,c(novar,novar,nstat))
      for(s in 1:nstat){
        print(paste("Station ",s))
	for(v1 in 1:novar){
		for(v2 in 1:novar){
			if(v1 != v2) {
				cormatrix[v1,v2,s]<-cor(varm[,v1,s]*mask,varm[,v2,s]*mask,use="complete.obs")
			}
		}
	}
       }  
	
	
	return(cormatrix)
 }
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
###  Plot station (point) data spatially.
#
# Input:  This funtion requires a list (sinfo) which contains subsets
#         latitude (lat), longitude (lon) and value to plot (plotval).
#         Also, the plot title, figure and optional number of levels. 
#         Default levels is 10.
#    
# Output:  PDF plot 
#   
# 
# Options: Number of intervals in coloring
#
# statid<-c("Count","Correlation","Anomoly correlation","Variance","Standard deviation","RMSE","Mean Absolute Error",
#           "Mean bias","Mean Fractional Bias","Mean Normalized Bias","Mean Normalized Gross Error",
#           "Normailized mean bias","Normalized mean error")
# maxallow<-c(5)
#     levs     <-c(0,1,2,3,4)
#     levcols  <-c("green","blue","yellow","red")
#     statloc<-7
#     title<-paste(statid[statloc]," Distribution")
#     figure<-"test.pdf"
#     plotval<-sstats$metrics[,statloc]
#     sinfo<-list(lat=sstats$lat,lon=sstats$lon,plotval=plotval,levs=levs,levcol=levscols)
# 
# NOTE:  Future version will allow user to specify a color scheme and levels
#
###
   require(fields)

   plotops<-list(plotfmt="pdf")
        plotSpatial<-function(sinfo,varlab,figure="spatial",nlevs=0,bounds=c(24,50,-120,-60),plotopts=plotopts,histplot=F,shadeplot=F,sres=0.25,plot_units)
 {
######################################################################################################
#---------------------------------------------------------------------------------------------------##
######################################################################################################
# Open Figure  for plot functions
  if (plotopts$plotfmt == "pdf") {
     #pdf(file= paste(figure,".pdf",sep=""), width = 8, height = 8)
      pdf(file= paste(figure,".pdf",sep=""))
  }
  if (plotopts$plotfmt == "png") {
     bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, height = (541*plotopts$plotsize)/100, res=png_res,pointsize=10*plotopts$plotsize)  
  }
  if (plotopts$plotfmt == "jpeg") {
     jpeg(filename=paste(figure,".jpeg",sep=""), width = (700*plotopts$plotsize), height = (541*plotopts$plotsize), quality=100, pointsize=10*plotopts$plotsize)
  }
   par(oma=c(0,0,0,5))
  if(max(abs(na.omit(sinfo[[1]]$plotval))) <= 1 ){
    sinfo[[1]]$convFac<-1
  }
# Set map symbols and calculate size based on relative data magnitude
  #spch          <-plotopts$symb         #       Symbol (19-solid circle, )
#  mincex        <-0.65
#  scex          <-mincex+(abs(sinfo[[1]]$plotval)/max(sinfo[[1]]$levs))
  scex          <-c(plotopts$symbsiz*1.2*symbsizfac,plotopts$symbsiz*1.1*symbsizfac,plotopts$symbsiz*symbsizfac,plotopts$symbsiz*symbsizfac,plotopts$symbsiz*0.9*symbsizfac)	# Make first symbols plotted slightly larger
  scex2         <-c(plotopts$symbsiz*1.3*symbsizfac,plotopts$symbsiz*1.1*symbsizfac,plotopts$symbsiz*symbsizfac,plotopts$symbsiz*.81*symbsizfac,plotopts$symbsiz*symbsizfac)
  lonw<- bounds[3]+(bounds[3]*.01)
  lone<- bounds[4]-(bounds[4]*.01)
  lats<- bounds[1]-(bounds[1]*.01)
  latn<- bounds[2]+(bounds[2]*.01)
  par (mai=c(.4,.1,.4,.1))
  legoffset <- (1/40)*(lone-lonw)
  legoffset2<- (1/90)*(lone-lonw)
  legoffset3<- (1/100)*(lone-lonw)
  textoffset<- (1/63)*(lone-lonw)
  legend.size <- (3*(latn-lats))/(lone-lonw)
  if (legend.size > 1) {
     if (plotopts$plotfmt == "png") {
        legend.size <- 1 
     }
  }
  if (plotopts$plotfmt == "pdf") {
     if (legend.size > .78) {   
        legend.size <- .78 
     }
  }
  if (length(levLab) > 20) {
     legend.size <- legend.size * 18/(length(levLab))
  }

# Plot Map and values
#  m<-map('usa',plot=FALSE)
#  map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1)
  if ((lone < -40) && (lats > 0)) {	# plotting for the U.S., so use U.S. maps
     {
        text_offset <- 1.2
        if (((abs(lonw-lone))*(abs(lats-latn))) < 50) {	# This is an abitrary limit designed to identify small plotting areas 
           map("usa", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1)
           map("county", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, col='grey30', boundary = TRUE, lty = 1, add=T)
        }
        else {
           map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1)
           map("state", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1, add=T)
           if (inc_counties == 'y') {
              map("county", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, col='grey40', boundary = TRUE, lty = 1, add=T, lwd=0.2)
           }
        }
     }
  }
  else {	# most likely plotting for Europe, so don't use U.S. maps
     text_offset <- 2
     map("worldHires", xlim=c(lonw,lone),ylim=c(lats,latn),resolution=0, boundary = TRUE, lty = 1)
  }
  for (k in 1:total_networks) {
     pcols<-array(NA,c(length(sinfo[[k]]$plotval))) 
     pcols<-sinfo[[k]]$levcols[cut(sinfo[[k]]$plotval,br=sinfo[[k]]$levs,labels=FALSE,include.lowest=T,right=F)]
     if(max(abs(na.omit(sinfo[[k]]$plotval))) <= 1 ){
        sinfo[[k]]$convFac<-1 
     }
     for (l in 1:length(sinfo[[k]]$lon)) {
        points(c(sinfo[[k]]$lon[l],sinfo[[k]]$lon[l]),c(sinfo[[k]]$lat[l],sinfo[[k]]$lat[l]),pch=c(spch[k],spch2[k]), cex=c(scex[k],scex2[k]), lwd=c(1,.25), col=c(pcols[l],"white"))			# Plot points
     }
  }
  box()

###################
#### Draw Title ###
###################
  par(xpd=NA)
  title(main=paste(varlab[1]),cex.main = 0.6, cex.sub=0.8,line=0.25,sub=sub_title)
#  text(lone-legoffset2+legoffset,lats+0.7*legoffset,"An AMET Product",adj=c(0,1),cex=0.65)
  text(lone-legoffset2+legoffset,latn,paste("units = ",plot_units,sep=""),adj=c(0,.5),cex=0.6)
  text(lone-legoffset2+legoffset,latn-textoffset,paste("coverage limit = ",coverage_limit,"%",sep=""),adj=c(0,.5),cex=0.6)
#  text(lone*1.02,lats*1.05,"(d)",adj=c(1,0),cex = 2)
###################
### Draw legend ###
###################
#  if (unique_labels == "n") {
#     levLab<-sinfo[[1]]$levs[1:(length(sinfo[[1]]$levs)-1)]
#  }
   mylegend(x=lone-legoffset3+legoffset,y=lats,labels=levLab,cols=sinfo[[1]]$cols_legend,bounds=sinfo[[1]]$levs_legend,cex=legend.size,xw=text_offset)
#  legend(x=lone-legoffset3+legoffset,y=latn-((latn-lats)/2), legend=rev(levLab), col=rev(sinfo[[1]]$levcols), pch=spch[1], pt.cex=legend.size, cex=legend.size, inset=c(0,0),yjust=0.5)
#  image.plot(add=T,legend.only=T,breaks=sinfo[[1]]$levs_legend,lab.breaks=levLab,col=sinfo[[1]]$cols_legend,zlim=c(min(sinfo[[1]]$levs_legend),max(sinfo[[1]]$levs_legend)))
   dev.off()

   if(histplot){
      if (plotopts$plotfmt == "pdf") {
         pdf(file= paste(figure,".pdf",sep=""))
      }
      if (plotopts$plotfmt == "png") {
         bitmap(file=paste(figure,".png",sep=""), width = (700*plotopts$plotsize)/100, height = (541*plotopts$plotsize)/100, res=png_res,pointsize=10*plotopts$plotsize)
      }
      if (plotopts$plotfmt == "jpeg") {
         jpeg(filename=paste(figure,".jpeg",sep=""), width = (700*plotopts$plotsize), height = (541*plotopts$plotsize), quality=100, pointsize=10*plotopts$plotsize)
      }

      plotval_tot <- NULL
      for (k in 1:total_networks) {      
         plotval_tot <- c(plotval_tot,sinfo[[k]]$plotval)
      }
      ### Remove first and last elements from levels list (very large by default) ###
      sinfo[[1]]$levs <- sinfo[[1]]$levs[-1]
      last_elem<- length(sinfo[[1]]$levs)
      sinfo[[1]]$levs <- sinfo[[1]]$levs[-last_elem]
      sinfo[[1]]$levcols <- sinfo[[1]]$levcols[-1]
      ###############################################################################
      positive_count <- sum(plotval_tot > 0)
      negative_count <- sum(plotval_tot < 0)
      perc_pos <- positive_count/length(plotval_tot)
      perc_neg <- round(100*(negative_count/length(plotval_tot)),1)
      sub_title <- paste("Number of sites w/ Decreased Bias/Error: ",negative_count," (",perc_neg,"%)",sep="")
      ### Set any plot values > max or min levels to the max or min level ###
      for (i in 1:length(plotval_tot)) {
         if (plotval_tot[i] > max(sinfo[[1]]$levs)) {
            plotval_tot[i] <- max(sinfo[[1]]$levs)
         }
         if (plotval_tot[i] < min(sinfo[[1]]$levs)) {
            plotval_tot[i] <- min(sinfo[[1]]$levs)
         }
      }
      ########################################################################
      if (length(na.omit(plotval_tot)) > 0){
         {
            if (length(hist_max > 0)) {
               hist(plotval_tot,breaks=sinfo[[1]]$levs,col=sinfo[[1]]$levcols,freq=T,ylab="Number of Mode/Ob Pairs",xlab=plot_units,main=varlab,sub=sub_title,cex.main=0.8,ylim=c(0,hist_max))
            }
            else {
               hist(plotval_tot,breaks=sinfo[[1]]$levs,col=sinfo[[1]]$levcols,freq=T,ylab="Number of Mode/Ob Pairs",xlab=plot_units,main=varlab,sub=sub_title,cex.main=0.8)
            }
         }
     }

     dev.off()
   }
}
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################
                                                                                                           
###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################

#data.df<-(network,stat_id,lat,lon,ob_val,mod_val)

DomainStats<-function(data_all.df,rm_negs="T")
{

## Determine total numbers of observations per sites ##
data.df <- data_all.df
#split_sites <- split(data.df,data.df$stat_id)
#for (h in 1:(length(split_sites))) {
#   sub.df <- split_sites[[h]]
#   total_obs <- c(total_obs,length(sub.df$stat_id))
#}
#######################################################

## Remove missing and zero concentration observations from dataset ##
if ((rm_negs == "T") || (rm_negs == "t") || (rm_negs == "Y") || (rm_negs == "y")) {
   indic.nonzero <- data.df$ob_val >= 0
   data.df <- data.df[indic.nonzero,]
   indic.nonzero <- data.df$mod_val >= 0
   data.df <- data.df[indic.nonzero,]
}
##############################################

## Full Domain Statistics ##
avg_conc    <- NULL	# Mean of Obs and Model
rmse        <- NULL	# Root Mean Square Error
nmb         <- NULL	# Normalized Mean Bias
nme         <- NULL	# Normalized Mean Error
nmdnb       <- NULL	# Normalized Median Bias
nmdne	    <- NULL	# Normalized Median Error
mdnnb       <- NULL     # Median Normalized Bias
mean_obs    <- NULL	# Obs Mean
mean_model  <- NULL	# Model Mean
sum_obs	    <- NULL
sum_model   <- NULL
median_obs  <- NULL
median_mod  <- NULL
median_diff <- NULL
skew_obs    <- NULL
skew_mod    <- NULL
stdev_obs   <- NULL	# Standard Deviation, obs
stdev_model <- NULL	# Standard Deviation, model
cor_model   <- NULL	# Correlation (Pearson)
r_sqrd      <- NULL
mb          <- NULL	# Mean Bias
me          <- NULL	# Mean Error
med_bias    <- NULL	# Median Bias
med_error   <- NULL	# Median Error
fb          <- NULL	# Fractional Bias
fe          <- NULL	# Fractional Error
nb          <- NULL	# Normalized Bias
ne          <- NULL	# Normalized Error
lats        <- NULL
lons        <- NULL
sites       <- NULL	
index_agree <- NULL	# Willmott Index of Agreement
rmse_sys    <- NULL	# Systematic RMSE
rmse_unsys  <- NULL	# Unsystematic RMSE
diff_mean   <- NULL
sd_diff     <- NULL
max_diff    <- NULL
min_diff    <- NULL

## Compute full domain statistics

if (length(data.df$stat_id) > 1) {
   num_obs     <- length(data.df$stat_id)
   avg_conc    <- signif(c(avg_conc, (mean(data.df$mod_val)+mean(data.df$ob_val))/2),5)
   mb          <- signif(c(mb, mean(data.df$mod_val-data.df$ob_val)),3)
   me          <- signif(c(me, mean(abs(data.df$mod_val-data.df$ob_val))),3)
   med_bias    <- signif(c(med_bias, median(data.df$mod_val-data.df$ob_val)),3)
   med_error   <- signif(c(med_error, median(abs(data.df$mod_val-data.df$ob_val))),3)
   rmse        <- signif(sqrt(c(rmse, sum((data.df$mod_val - data.df$ob_val)^2)/num_obs)),3)
   nmb         <- signif(c(nmb, (mean(data.df$mod_val - data.df$ob_val)/(mean(data.df$ob_val)))*100),3)
   nme         <- signif(c(nme, (mean(abs(data.df$mod_val-data.df$ob_val))/(mean(data.df$ob_val)))*100),3)
   nmdnb       <- signif(c(nmdnb, (median(data.df$mod_val - data.df$ob_val)/(median(data.df$ob_val)))*100),3)
   nmdne       <- signif(c(nmdne, (median(abs(data.df$mod_val-data.df$ob_val))/(median(data.df$ob_val)))*100),3)
   mdnnb       <- signif(c(mdnnb, (median((data.df$mod_val - data.df$ob_val)/data.df$ob_val))*100),3)
   mean_obs    <- signif(c(mean_obs, mean(data.df$ob_val)),5)
   mean_model  <- signif(c(mean_model, mean(data.df$mod_val)),5)
   sum_obs     <- signif(c(sum_obs, sum(data.df$ob_val)),5)
   sum_model   <- signif(c(sum_model, sum(data.df$mod_val)),5)
   median_obs  <- signif(c(median_obs, median(data.df$ob_val)),5)
   median_mod  <- signif(c(median_mod, median(data.df$mod_val)),5)
   median_diff <- c(median_diff, (median(data.df$mod_val)-median(data.df$ob_val)))
   skew_obs    <- signif(c(skew_obs, (median(data.df$ob_val)/mean(data.df$ob_val))),3)
   skew_mod    <- signif(c(skew_mod, (median(data.df$mod_val)/mean(data.df$mod_val))),3)
   stdev_obs   <- signif(c(stdev_obs, sd(data.df$ob_val)),3)
   stdev_model <- signif(c(stdev_model, sd(data.df$mod_val)),3)
   cor_model   <-  round(c(cor_model, cor(data.df$mod_val, data.df$ob_val,method="pearson")),2)
   #cor_model  <-  round(c(cor_model, sum(((data.df$ob_val-mean_obs)/stdev_obs)*((data.df$mod_val-mean_model)/stdev_model))*(1/(num_obs-1))),2)
   r_sqrd      <- signif((cor_model)^2,3)
   ls_regress  <- lsfit(data.df$ob_val,data.df$mod_val)
   intercept   <- ls_regress$coefficients[1]
   X           <- ls_regress$coefficients[2]
   rmse_sys    <- signif(sqrt(c(rmse_sys, (sum(((intercept+X*data.df$ob_val) - data.df$ob_val)^2))/num_obs)),3)
   rmse_unsys  <- signif(sqrt(c(rmse_unsys, sum((data.df$mod_val - (intercept+X*data.df$ob_val))^2)/num_obs)),3)
   index_agree <- signif(1-((sum((data.df$ob_val-data.df$mod_val)^2))/(sum((abs(data.df$mod_val-mean(data.df$ob_val))+abs(data.df$ob_val-mean(data.df$ob_val)))^2))),3)
   diff_mean   <- signif(c(diff_mean,mean(data.df$mod_val-data.df$ob_val)),3)
   sd_diff     <- signif(c(sd_diff,sd(data.df$mod_val-data.df$ob_val)),3)
#   max_diff    <- signif(c(max_diff,max(data.df$mod_val-data.df$ob_val)),3)
   max_diff    <- signif(max(data.df$mod_val-data.df$ob_val),3)
#   min_diff    <- signif(c(min_diff,min(data.df$mod_val-data.df$ob_val)),3)
   min_diff    <- signif(min(data.df$mod_val-data.df$ob_val),3)

### These statistics divide by the individual obsevations, so zero values need to be removed to avoid NaNs ###
   indic.nonzero <- data.df$ob_val > 0
   data.df <- data.df[indic.nonzero,]
   indic.nonzero <- data.df$mod_val > 0
   data.df <- data.df[indic.nonzero,]
   
   nb          <- signif(c(nb,((sum((data.df$mod_val-data.df$ob_val)/data.df$ob_val))/length(data.df$stat_id))*100),3)
   ne          <- signif(c(ne,((sum((abs(data.df$mod_val-data.df$ob_val))/data.df$ob_val))/length(data.df$stat_id))*100),3)
   fb          <- signif(c(fb,(sum((data.df$mod_val-data.df$ob_val)/((data.df$mod_val+data.df$ob_val)/2)))/length(data.df$stat_id))*100,3)
   fe          <- signif(c(fe,(sum(abs(data.df$mod_val-data.df$ob_val)/((data.df$mod_val+data.df$ob_val)/2)))/length(data.df$stat_id))*100,3)

   stats_all.df <- data.frame(NUM_OBS=num_obs, AVG_CONC=avg_conc, MEAN_OBS=mean_obs, MEAN_MODEL=mean_model, SUM_OBS=sum_obs, SUM_MODEL=sum_model, STDEV_OBS=stdev_obs, STDEV_MODEL=stdev_model, Correlation=cor_model, R_Squared=r_sqrd, Mean_Bias=mb, Mean_Err=me, Median_Bias=med_bias, Median_Error=med_error, Percent_Norm_Bias=nb, Percent_Norm_Err=ne, Percent_Norm_Mean_Bias=nmb, Percent_Norm_Mean_Err=nme, Norm_Median_Bias=nmdnb, Norm_Median_Error=nmdne, Frac_Bias=fb, Frac_Err=fe, Index_of_Agreement=index_agree, RMSE=rmse, RMSE_systematic=rmse_sys, RMSE_unsystematic=rmse_unsys,Diff_Mean=diff_mean,SD_Diff=sd_diff, Skew_Obs=skew_obs, Skew_Mod=skew_mod, Median_obs=median_obs, Median_model=median_mod, Median_Diff=median_diff,Max_Diff=max_diff,Min_Diff=min_diff)

   }
}

##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################

#################################################################
### Format of datain.df dataframe used by SitesStats function ###
# datain.df<-(network,stat_id,lat,lon,ob_val,mod_val)	
#################################################################

SitesStats<-function(datain.df)
{
 
datain_all.df <- NULL
sub.df <- NULL
total_obs <- NULL

## Determine total numbers of observations per sites ##
datain_all.df <- datain.df
split_sites <- split(datain_all.df,datain_all.df$stat_id)
for (h in 1:(length(split_sites))) {
   sub.df <- split_sites[[h]]
   total_obs <- c(total_obs,length(sub.df$stat_id))
} 
#######################################################
 
## Site Statistics ##
sites         <- NULL
lats          <- NULL
lons          <- NULL
num_obs       <- NULL	# Total number of model/obs pairs
mean_obs      <- NULL	# Mean of obs values
mean_model    <- NULL	# Mean of model values
sum_obs       <- NULL   # Mean of obs values
sum_model     <- NULL   # Mean of model values
median_obs    <- NULL
median_mod    <- NULL
median_diff   <- NULL
skew_obs      <- NULL
skew_mod      <- NULL
site_coverage <- NULL	# Percent coverage
site_rmse     <- NULL	# Root Mean Square Error
site_mb       <- NULL	# Mean Bias
site_me       <- NULL	# Mean Error
site_nmb      <- NULL	# Normalized Mean Bias
site_nme      <- NULL	# Normalized Mean Error
site_nmdnb    <- NULL
site_nmdne    <- NULL
site_corr     <- NULL	# Correlation (Pearson)
site_r_sqrd   <- NULL
site_fb       <- NULL	# Fractional Bias
site_fe       <- NULL	# Fractional Error
site_nb       <- NULL	# Normalized Bias
site_ne       <- NULL	# Normalized Error
sub.df        <- NULL
sd_obs	      <- NULL	# Standard deviation of the obs
sd_mod        <- NULL	# Standard deviation of the model
coef_var_obs  <- NULL	# Coefficient of variation, obs
coef_var_mod  <- NULL	# Coefficient of variation, model
index_agree   <- NULL	# Willmott Index of Agreement
rmse_sys      <- NULL	# Systematic RMSE
rmse_unsys    <- NULL	# Unsystematic RMSE


## Compute site specific statistics 
temp <- split(datain_all.df,datain_all.df$stat_id)
for (i in 1:length(temp)) {
   ls_regress <- NULL
   intercept  <- NULL
   X          <- NULL
   sub.df <- temp[[i]]
   num_good_obs <- length(sub.df$stat_id)			# First assume all queried obs are valid
#   if ((valid_only == "y") && (remove_negatives == "y")) {	# Check that we assuming all records are valid and we are removing negative values
#   if (valid_only == "y") {
#      indic.missing <- sub.df$ob_val < 0			# Check for observations that are less than 0
#      sub.df$ob_val[indic.missing] <- 0				# Replace those observations with 0 (we assume a valid observation, just not negative)
#      indic.missing <- sub.df$mod_val >= 0			# Find all the good model values
#      sub.df <- sub.df[indic.missing,]				# Remove any records with a missing modeled value
#      num_good_obs <- length(sub.df$stat_id)			# Count the remaining records
#   }
#   else {
   indic.missing <- sub.df$ob_val >= 0 
   sub.df <- sub.df[indic.missing,]
   indic.missing <- sub.df$mod_val >= 0
   sub.df <- sub.df[indic.missing,]
   num_good_obs <- length(sub.df$stat_id)
#   }
   coverage <- round((num_good_obs/total_obs[i])*100)
   if ((length(sub.df$stat_id) > 0) && (coverage >= coverage_limit) && (num_good_obs >= num_obs_limit)) {	# number of observations necessary for evaluation(completeness criteria)
      site_coverage <- c(site_coverage, coverage)
      sites         <- c(sites, as.character(unique(sub.df$stat_id)))		# Set site ID
      lats          <- c(lats, sub.df$lat[1])		# Set lat to first lat record in sub.df
      lons          <- c(lons, sub.df$lon[1])		# Set lon to first lon record in sub.df
      num_obs       <- c(num_obs,length(sub.df$stat_id))	
      mean_obs      <- c(mean_obs, round(mean(sub.df$ob_val),5))
      mean_model    <- c(mean_model, round(mean(sub.df$mod_val),5))
      sum_obs	    <- c(sum_obs, round(sum(sub.df$ob_val),5))
      sum_model	    <- c(sum_model, round(sum(sub.df$mod_val),5))
      median_obs    <- c(median_obs, median(sub.df$ob_val))
      median_mod    <- c(median_mod, median(sub.df$mod_val))
      median_diff   <- c(median_diff, median(sub.df$mod_val-sub.df$ob_val))
      skew_obs      <- c(skew_obs, round((median(sub.df$ob_val)/mean(sub.df$ob_val)),2))
      skew_mod      <- c(skew_mod, round((median(sub.df$mod_val)/mean(sub.df$mod_val)),2))
      site_mb       <- c(site_mb, round(mean(sub.df$mod_val-sub.df$ob_val),4))
      site_me       <- c(site_me, round(mean(abs(sub.df$mod_val-sub.df$ob_val)),4))
      if (mean(sub.df$ob_val) > 0) {
         site_nmb      <- c(site_nmb, round(((sum(sub.df$mod_val-sub.df$ob_val))/sum(sub.df$ob_val))*100,2))
         site_nme      <- c(site_nme, round((sum((abs(sub.df$mod_val-sub.df$ob_val)))/sum(sub.df$ob_val))*100,2))
      }
      else { 
         site_nmb <- c(site_nmb,NA)
         site_nme <- c(site_nme,NA)
      }
      site_nmdnb    <- c(site_nmdnb, round((median(sub.df$mod_val - sub.df$ob_val)/(median(sub.df$ob_val))*100),2))
      site_nmdne    <- c(site_nmdne, round((median(abs(sub.df$mod_val-sub.df$ob_val))/(median(sub.df$ob_val))*100),2))
      site_nb       <- c(site_nb,round(((sum((sub.df$mod_val-sub.df$ob_val)/sub.df$ob_val))/length(sub.df$stat_id))*100,2))
      site_ne       <- c(site_ne,round(((sum((abs(sub.df$mod_val-sub.df$ob_val))/sub.df$ob_val))/length(sub.df$stat_id))*100,2))
      site_rmse     <- c(site_rmse, round(sqrt((sum((sub.df$mod_val-sub.df$ob_val)^2))/length(sub.df$stat_id)),4))
      site_fb       <- c(site_fb,round((sum((sub.df$mod_val-sub.df$ob_val)/((sub.df$mod_val+sub.df$ob_val)/2),na.rm=T))/length(sub.df$stat_id)*100,1))
      site_fe       <- c(site_fe,round((sum(abs(sub.df$mod_val-sub.df$ob_val)/((sub.df$mod_val+sub.df$ob_val)/2),na.rm=T))/length(sub.df$stat_id)*100,1))
      site_corr     <- c(site_corr, round(cor(sub.df$mod_val, sub.df$ob_val),3))
      site_r_sqrd   <- round((site_corr)^2,3)
      sd_obs        <- c(sd_obs, round(sd(sub.df$ob_val),3))
      sd_mod        <- c(sd_mod, round(sd(sub.df$mod_val),3))
      coef_var_obs  <- c(coef_var_obs, round(sd(sub.df$ob_val)/mean(sub.df$ob_val),3))
      coef_var_mod  <- c(coef_var_mod, round(sd(sub.df$mod_val)/mean(sub.df$mod_val),3))
      index_agree   <- c(index_agree, round(1-((sum((sub.df$ob_val-sub.df$mod_val)^2))/(sum((abs(sub.df$mod_val-mean(sub.df$ob_val))+abs(sub.df$ob_val-mean(sub.df$ob_val)))^2))),2) )
      if (length(sub.df$ob_val) > 1) {	# Can only be calculated if more that one observation/model pair available
         ls_regress    <- lsfit(sub.df$ob_val,sub.df$mod_val)
         intercept     <- ls_regress$coefficients[1]
         X             <- ls_regress$coefficients[2]
         rmse_sys      <- c(rmse_sys, round(sqrt((sum(((intercept+X*sub.df$ob_val)-sub.df$ob_val)^2))/length(sub.df$stat_id)),4))
         rmse_unsys    <- c(rmse_unsys, round(sqrt((sum((sub.df$mod_val-(intercept+X*sub.df$ob_val))^2))/length(sub.df$stat_id)),4))
      }
      else {					# If only one observation/model pair available, set variables to NA
         rmse_sys      <- c(rmse_sys,"NA")
         rmse_unsys    <- c(rmse_unsys,"NA")
      }
   }
} 
####################################

##################################

sites_stats.df <- data.frame(Network=I(network),Site_ID=I(sites),lat=lats,lon=lons,Num_Obs=num_obs,Obs_mean=mean_obs,Mod_mean=mean_model,Obs_median=median_obs,Mod_median=median_mod,Obs_sum=sum_obs,Mod_sum=sum_model,Coverage=site_coverage,MB=site_mb, ME=site_me, NMB=site_nmb, NME=site_nme, NMdnB=site_nmdnb, NMdnE=site_nmdne, FB=site_fb, FE=site_fe, COR=site_corr, R_Squared=site_r_sqrd, Stand_Dev_obs=sd_obs, Stand_Dev_mod=sd_mod, Coeff_of_Var_obs=coef_var_obs, Coeff_of_Var_mod=coef_var_mod, Index_of_Agree=index_agree, RMSE=site_rmse, RMSE_systematic=rmse_sys, RMSE_unsystematic=rmse_unsys, Skew_Obs=skew_obs, Skew_Mod=skew_mod, Median_Diff=median_diff)

}
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################

#################################################################
### Format of datain.df dataframe used by SitesStats function ###
# datain.df<-(network,stat_id,lat,lon,ob_val,mod_val)        
#################################################################

HourStats<-function(datain.df)
{

coverage_limit	<- 0	# Set coverage limit to 0 for this function only
datain_all.df	<- NULL
sub.df		<- NULL
total_obs	<- NULL

## Determine total numbers of observations per sites ##
datain_all.df <- datain.df
split_hours <- split(datain_all.df,datain_all.df$Date_Hour)
for (h in 1:(length(split_hours))) {
   sub.df <- split_hours[[h]]
   total_obs <- c(total_obs,length(sub.df$Date_Hour))
}
#######################################################

## Site Statistics ##
num_obs       <- NULL   # Total number of model/obs pairs
mean_obs      <- NULL   # Mean of obs values
mean_model    <- NULL   # Mean of model values
sum_obs       <- NULL   # Mean of obs values
sum_model     <- NULL   # Mean of model values
median_obs    <- NULL
median_mod    <- NULL
median_diff   <- NULL
skew_obs      <- NULL
skew_mod      <- NULL
date_hour     <- NULL
hour_coverage <- NULL   # Percent coverage
hour_rmse     <- NULL   # Root Mean Square Error
hour_mb       <- NULL   # Mean Bias
hour_me       <- NULL   # Mean Error
hour_nmb      <- NULL   # Normalized Mean Bias
hour_nme      <- NULL   # Normalized Mean Error
hour_nmdnb    <- NULL
hour_nmdne    <- NULL
hour_corr     <- NULL   # Correlation (Pearson)
hour_r_sqrd   <- NULL
hour_fb       <- NULL   # Fractional Bias
hour_fe       <- NULL   # Fractional Error
hour_nb       <- NULL   # Normalized Bias
hour_ne       <- NULL   # Normalized Error
sub.df        <- NULL
sd_obs        <- NULL   # Standard deviation of the obs
sd_mod        <- NULL   # Standard deviation of the model
coef_var_obs  <- NULL   # Coefficient of variation, obs
coef_var_mod  <- NULL   # Coefficient of variation, model
index_agree   <- NULL   # Willmott Index of Agreement
rmse_sys      <- NULL   # Systematic RMSE
rmse_unsys    <- NULL   # Unsystematic RMSE

## Compute hour specific statistics 
temp <- split(datain_all.df,datain_all.df$Date_Hour)
for (i in 1:length(temp)) {
   ls_regress <- NULL
   intercept  <- NULL
   X          <- NULL
   sub.df <- temp[[i]]
   num_good_obs <- length(sub.df$Date_Hour)                       # First assume all queried obs are valid
#   if ((valid_only == "y") && (remove_negatives == "y")) {      # Check that we assuming all records are valid and we are removing negative values
#   if (valid_only == "y") {
#      indic.missing <- sub.df$ob_val < 0                        # Check for observations that are less than 0
#      sub.df$ob_val[indic.missing] <- 0                         # Replace those observations with 0 (we assume a valid observation, just not negative)
#      indic.missing <- sub.df$mod_val >= 0                      # Find all the good model values
#      sub.df <- sub.df[indic.missing,]                          # Remove any records with a missing modeled value
#      num_good_obs <- length(sub.df$Date_Hour)                    # Count the remaining records
#   }
#   else {
#      if (remove_negatives == "y") {    # If removing negative observations and valid_only (which applies only to NADP) is not checked
         indic.missing <- sub.df$ob_val >= 0
         sub.df <- sub.df[indic.missing,]
         indic.missing <- sub.df$mod_val >= 0
         sub.df <- sub.df[indic.missing,]
         num_good_obs <- length(sub.df$Date_Hour)
#      }
#   }
   coverage <- round((num_good_obs/total_obs[i])*100)
   if ((length(sub.df$Date_Hour) > 0) && (coverage >= coverage_limit) && (num_good_obs >= num_obs_limit)) {       # number of observations necessary for evaluation(completeness criteria)
      hour_coverage	<- c(hour_coverage, coverage)
      date_hour		<- c(date_hour, as.character(unique(sub.df$Date_Hour)))           # Set site ID
#      lats          <- c(lats, sub.df$lat[1])           # Set lat to first lat record in sub.df
#      lons          <- c(lons, sub.df$lon[1])           # Set lon to first lon record in sub.df
      num_obs       <- c(num_obs,length(sub.df$Date_Hour))
      mean_obs      <- c(mean_obs, round(mean(sub.df$ob_val),3))
      mean_model    <- c(mean_model, round(mean(sub.df$mod_val),3))
      median_obs    <- c(median_obs, median(sub.df$ob_val))
      median_mod    <- c(median_mod, median(sub.df$mod_val))
      median_diff   <- c(median_diff, median(sub.df$mod_val-sub.df$ob_val))
      skew_obs      <- c(skew_obs, round((median(sub.df$ob_val)/mean(sub.df$ob_val)),2))
      skew_mod      <- c(skew_mod, round((median(sub.df$mod_val)/mean(sub.df$mod_val)),2))
      hour_mb       <- c(hour_mb, round(mean(sub.df$mod_val-sub.df$ob_val),4))
      hour_me       <- c(hour_me, round(abs(mean(sub.df$mod_val-sub.df$ob_val)),4))
      if (mean(sub.df$ob_val) > 0) {
         hour_nmb      <- c(hour_nmb, round(((sum(sub.df$mod_val-sub.df$ob_val))/sum(sub.df$ob_val))*100,2))
         hour_nme      <- c(hour_nme, round((sum((abs(sub.df$mod_val-sub.df$ob_val)))/sum(sub.df$ob_val))*100,2))
      }
      else {
         hour_nmb <- c(hour_nmb,NA)
         hour_nme <- c(hour_nme,NA)
      }
      hour_nmdnb    <- c(hour_nmdnb, round((median(sub.df$mod_val - sub.df$ob_val)/(median(sub.df$ob_val))*100),2))
      hour_nmdne    <- c(hour_nmdne, round((median(abs(sub.df$mod_val-sub.df$ob_val))/(median(sub.df$ob_val))*100),2))
      hour_nb       <- c(hour_nb,round(((sum((sub.df$mod_val-sub.df$ob_val)/sub.df$ob_val))/length(sub.df$Date_Hour))*100,2))
      hour_ne       <- c(hour_ne,round(((sum((abs(sub.df$mod_val-sub.df$ob_val))/sub.df$ob_val))/length(sub.df$Date_Hour))*100,2))
      hour_rmse     <- c(hour_rmse, round(sqrt((sum((sub.df$mod_val-sub.df$ob_val)^2))/length(sub.df$Date_Hour)),4))
      hour_fb       <- c(hour_fb,round((sum((sub.df$mod_val-sub.df$ob_val)/((sub.df$mod_val+sub.df$ob_val)/2),na.rm=T))/length(sub.df$Date_Hour)*100,1))
      hour_fe       <- c(hour_fe,round((sum(abs(sub.df$mod_val-sub.df$ob_val)/((sub.df$mod_val+sub.df$ob_val)/2),na.rm=T))/length(sub.df$Date_Hour)*100,1))
      hour_corr     <- c(hour_corr, round(cor(sub.df$mod_val, sub.df$ob_val),3))
      hour_r_sqrd   <- round((hour_corr)^2,3)
      sd_obs        <- c(sd_obs, round(sd(sub.df$ob_val),3))
      sd_mod        <- c(sd_mod, round(sd(sub.df$mod_val),3))
      coef_var_obs  <- c(coef_var_obs, round(sd(sub.df$ob_val)/mean(sub.df$ob_val),3))
      coef_var_mod  <- c(coef_var_mod, round(sd(sub.df$mod_val)/mean(sub.df$mod_val),3))
      index_agree   <- c(index_agree, round(1-((sum((sub.df$ob_val-sub.df$mod_val)^2))/(sum((abs(sub.df$mod_val-mean(sub.df$ob_val))+abs(sub.df$ob_val-mean(sub.df$ob_val)))^2))),2) )
      if (length(sub.df$ob_val) > 1) {  # Can only be calculated if more that one observation/model pair available
         ls_regress    <- lsfit(sub.df$ob_val,sub.df$mod_val)
         intercept     <- ls_regress$coefficients[1]
         X             <- ls_regress$coefficients[2]
         rmse_sys      <- c(rmse_sys, round(sqrt((sum(((intercept+X*sub.df$ob_val)-sub.df$ob_val)^2))/length(sub.df$Date_Hour)),4))
         rmse_unsys    <- c(rmse_unsys, round(sqrt((sum((sub.df$mod_val-(intercept+X*sub.df$ob_val))^2))/length(sub.df$Date_Hour)),4))
      }
      else {                                    # If only one observation/model pair available, set variables to NA
         rmse_sys      <- c(rmse_sys,"NA")
         rmse_unsys    <- c(rmse_unsys,"NA")
      }
   }
}
####################################

##################################

hour_stats.df <- data.frame(Network=I(network),Date_Hour=I(date_hour),Num_Obs=num_obs,Obs_mean=mean_obs,Mod_mean=mean_model,Obs_median=median_obs,Mod_median=median_mod,Coverage=hour_coverage,MB=hour_mb, ME=hour_me, NMB=hour_nmb, NME=hour_nme, NMdnB=hour_nmdnb, NMdnE=hour_nmdne, FB=hour_fb, FE=hour_fe, COR=hour_corr, R_Squared=hour_r_sqrd, Stand_Dev_obs=sd_obs, Stand_Dev_mod=sd_mod, Coeff_of_Var_obs=coef_var_obs, Coeff_of_Var_mod=coef_var_mod, Index_of_Agree=index_agree, RMSE=hour_rmse, RMSE_systematic=rmse_sys, RMSE_unsystematic=rmse_unsys, Skew_Obs=skew_obs, Skew_Mod=skew_mod, Median_Diff=median_diff)

}
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
Average<-function(datain.df) {
   Obs_Mean		<- NULL
   Mod_Mean		<- NULL
   Obs_Count		<- NULL
   Obs_Good		<- NULL
   Precip_Ob_Sum 	<- NULL
   Precip_Mod_Sum	<- NULL
   Sites		<- NULL
   Lats         	<- NULL
   Lons			<- NULL
   States	        <- NULL
   category		<- NULL
   names(datain.df)
   if (!"State" %in% colnames(datain.df)) {
      datain.df$State <- "NA"
   }
   datain.df$good_ob	<- 0							# Assign a new column indicating whether ob is good or not (default in not good)

   indic.nonzero <- datain.df$Mod_Value >= 0
   datain.df     <- datain.df[indic.nonzero,]
  
   indic.na <- datain.df$Obs_Value < 0
   datain.df$Obs_Value[indic.na] <- NA
   {
   if ((network == "NADP") || (network == "MDN")) {				# Do things differently for deposition networks
      indic.na <- datain.df$precip_ob <= 0.127
      datain.df$good_ob[indic.na] <- 1
      indic.na <- is.na(datain.df$Obs_Value)
      datain.df$good_ob[!indic.na] <- 1
   }
   else {
      indic.na <- is.na(datain.df$Obs_Value)
      datain.df$good_ob[!indic.na] <- 1
   }
   }
   if (units == "mg/l") {
      datain.df$VWA_ob 	<- datain.df$Obs_Value*datain.df$precip_ob
      datain.df$VWA_mod	<- datain.df$Mod_Value*datain.df$precip_mod
   }
   if (remove_mean == 'y') {
      domain_obs_mean <-  mean(datain.df$Obs_Value,na.rm=T)
      domain_mod_mean <-  mean(datain.df$Mod_Value,na.rm=T)
   }
   {
      if (averaging == "s") {
         season <- rep("NA", length(datain.df$Month))
         season[datain.df$Month %in% c(12,1,2)] <- "winter"
         season[datain.df$Month %in% c(3,4,5)] <- "spring"
         season[datain.df$Month %in% c(6,7,8)] <- "summer"
         season[datain.df$Month %in% c(9,10,11)] <- "fall"
         datain.df$season <- season
         split_all <- split(datain.df,datain.df$season)
         avg_text_1 <- "Seasonal "
      }
      else if (averaging == "h") {
         split_all <- split(datain.df,datain.df$Hour)
         avg_text_1 <- "Hourly"
      }
      else if (averaging == "d") {
         split_all <- split(datain.df,datain.df$Start_Date)
         avg_text_1 <- "Daily "
      }
      else if (averaging == "m") {
         split_all  <- split(datain.df,datain.df$Month)
         avg_text_1 <- "Monthly "
      }
      else if (averaging == "a") {
         split_all <- split(datain.df,datain.df$Stat_ID)
         avg_text_1 <- "Period "
      }
      else if (averaging == "ym") {
         years			<- substr(datain.df$Start_Date,1,4)
         months			<- substr(datain.df$Start_Date,6,7)
         yearmonth		<- paste(years,months,sep="_")
         datain.df$Year		<- years
         datain.df$YearMonth 	<- yearmonth
         split_all 		<- split(datain.df,datain.df$YearMonth)
         avg_text_1 		<- "Monthly "
      }
   }
   for (i in 1:length(split_all)) { 
      data_split.df  <- split_all[[i]]
      if (averaging == "s") {
         category      <- c(category,tapply(data_split.df$season,data_split.df$Stat_ID,unique))	# Create list of all seasons used
      }
      else if (averaging == "h") {
         category      <- c(category,tapply(data_split.df$Hour,data_split.df$Stat_ID,unique))	# Create list of all hours used
      }
      else if (averaging == "d") {
         category      <- c(category,tapply(as.character(data_split.df$Start_Date),data_split.df$Stat_ID,unique))	# Create list of all days used
      }
      else if (averaging == "m") {
         category      <- c(category,tapply(data_split.df$Month,data_split.df$Stat_ID,unique))	# Create list of all months used
      }
      else if (averaging == "a") {
         category      <- c(category,tapply((split_all[[i]]$Stat_ID),split_all[[i]]$Stat_ID,unique))	# Create list of all sites used
      }
      else if (averaging == "ym") {
         category       <- c(category,tapply(data_split.df$YearMonth,data_split.df$Stat_ID,unique))	# If using multiple years, use YearMonth count
      }
      if ((units == "kg/ha") || (units == "cm") || (units == "mm")) {
         Obs_Mean       <- c(Obs_Mean,tapply(data_split.df$Obs_Value,data_split.df$Stat_ID,sum,na.rm=T))
         Mod_Mean       <- c(Mod_Mean,tapply(data_split.df$Mod_Value,data_split.df$Stat_ID,sum,na.rm=T))
         Obs_Count      <- c(Obs_Count,tapply(data_split.df$Obs_Value,data_split.df$Stat_ID,length))
         Obs_Good       <- c(Obs_Good,tapply(data_split.df$good_ob,data_split.df$Stat_ID,sum))
#         Precip_Ob_Sum  <- c(Precip_Ob_Sum,tapply(data_split.df$precip_ob,data_split.df$Stat_ID,sum,na.rm=T))
#         Precip_Mod_Sum <- c(Precip_Mod_Sum,tapply(data_split.df$precip_mod,data_split.df$Stat_ID,sum,na.rm=T))
         Sites          <- c(Sites,tapply(data_split.df$Stat_ID,data_split.df$Stat_ID,unique))
         States         <- c(States,tapply(as.character(data_split.df$State),data_split.df$Stat_ID,unique))
         Lats           <- c(Lats,tapply(data_split.df$lat,data_split.df$Stat_ID,unique))
         Lons           <- c(Lons,tapply(data_split.df$lon,data_split.df$Stat_ID,unique))
         avg_text	<- paste(avg_text_1, " Accumulated",sep="")          # set averaging text to accumulated
      }
      else if (units == "mg/l") { # If dealing with wet concentration, calculate a volume weighted average
         Obs_Mean       <- c(Obs_Mean,tapply(data_split.df$VWA_ob,data_split.df$Stat_ID,mean,na.rm=T))
         Mod_Mean       <- c(Mod_Mean,tapply(data_split.df$VWA_mod,data_split.df$Stat_ID,mean,na.rm=T))
         Obs_Count      <- c(Obs_Count,tapply(data_split.df$Obs_Value,data_split.df$Stat_ID,length))
         Obs_Good       <- c(Obs_Good,tapply(data_split.df$good_ob,data_split.df$Stat_ID,sum))
#         Precip_Ob_Sum  <- c(Precip_Ob_Sum,tapply(data_split.df$precip_ob,data_split.df$Stat_ID,sum,na.rm=T))
#         Precip_Mod_Sum <- c(Precip_Mod_Sum,tapply(data_split.df$precip_mod,data_split.df$Stat_ID,sum,na.rm=T))
         Sites          <- c(Sites,tapply(data_split.df$Stat_ID,data_split.df$Stat_ID,unique))
         States         <- c(States,tapply(as.character(data_split.df$State),data_split.df$Stat_ID,unique))
         Lats           <- c(Lats,tapply(data_split.df$lat,data_split.df$Stat_ID,unique))
         Lons           <- c(Lons,tapply(data_split.df$lon,data_split.df$Stat_ID,unique)) 
         avg_text      <- paste("VW ",avg_text_1, "Average",sep="")                         # set text as volume weighted average
      }
      else {
         if (remove_mean == 'y') {
            data_split.df$Obs_Value	<- data_split.df$Obs_Value - domain_obs_mean
            data_split.df$Mod_Value	<- data_split.df$Mod_Value - domain_mod_mean
         }
         Obs_Mean	<- c(Obs_Mean,tapply(data_split.df$Obs_Value,data_split.df$Stat_ID,mean,na.rm=T))
         Mod_Mean	<- c(Mod_Mean,tapply(data_split.df$Mod_Value,data_split.df$Stat_ID,mean,na.rm=T))
         Obs_Count	<- c(Obs_Count,tapply(data_split.df$Obs_Value,data_split.df$Stat_ID,length))
         Obs_Good	<- c(Obs_Good,tapply(data_split.df$good_ob,data_split.df$Stat_ID,sum))
#         Precip_Ob_Sum	<- c(Precip_Ob_Sum,tapply(data_split.df$precip_ob,data_split.df$Stat_ID,sum,na.rm=T))
#         Precip_Mod_Sum	<- c(Precip_Mod_Sum,tapply(data_split.df$precip_mod,data_split.df$Stat_ID,sum,na.rm=T))
         Sites		<- c(Sites,tapply(data_split.df$Stat_ID,data_split.df$Stat_ID,unique))
         States         <- c(States,tapply(as.character(data_split.df$State),data_split.df$Stat_ID,unique))
         Lats		<- c(Lats,tapply(data_split.df$lat,data_split.df$Stat_ID,unique))
         Lons		<- c(Lons,tapply(data_split.df$lon,data_split.df$Stat_ID,unique))
         avg_text       <- paste(avg_text_1, " Average",sep="")
      }
   }
   coverage <- (Obs_Good/Obs_Count*100)
#   data_out.df			<- data.frame(Stat_ID=I(Sites),lat=Lats,lon=Lons,Obs_Value=Obs_Mean,Mod_Value=Mod_Mean,precip_ob=Precip_Ob_Sum, precip_mod=Precip_Mod_Sum,Month=I(category),YearMonth=I(category),Coverage=coverage)
   data_out.df                 <- data.frame(Stat_ID=I(Sites),State=I(States),lat=Lats,lon=Lons,Obs_Value=Obs_Mean,Mod_Value=Mod_Mean,Month=I(category),YearMonth=I(category),Coverage=coverage)
   indic.nan			<- is.nan(data_out.df$Obs_Value)		# check for NaNs
   data_out.df			<- data_out.df[!indic.nan,]			# remove records with NaNs
   indic.good			<- data_out.df$Coverage >= coverage_limit	# check to see if site coverage matches limit
   data_out.df			<- data_out.df[indic.good,]			# remove records that don't meet coverage limit
   data_out.df$Network		<- network
   data_out.df$avg_text		<- avg_text
   aqdat.df			<- data_out.df
}
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################

draw.uneven.image <- function(x, y, z, size=1,zlim=range(z, na.rm=T), add=F, xlab="x", ylab="y", col=tim.colors(64),
					xlim=c(min(x,na.rm=T)-size,max(x,na.rm=T)+size),ylim=c(min(y,na.rm=t)-size,max(y,na.rm=T)+size),...)
{
  require(fields)

  xbounds <- c(min(x, na.rm=T)-size, max(x, na.rm=T)+size)
  ybounds <- c(min(y, na.rm=T)-size, max(y, na.rm=T)+size)
  suppressWarnings( image.plot(xbounds,ybounds, matrix(NA,nrow=2,ncol=2),zlim=zlim,col=col,xlab=xlab,ylab=ylab,xlim=xlim,ylim=ylim,...))

  for (i in 1:length(z)){
    x.area <- c(x[i]-size, x[i], x[i]+size)
    y.area <- c(y[i]-size, y[i], y[i]+size)
  
    image(x.area, y.area, matrix(rep(z[i],length(x.area)*length(y.area)), ncol=length(y.area)), zlim=zlim, add=T, col=col, ...)
    map(database="state",add=T)

  }

}

##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################

###################################################################################
#- - - - - - - - -   START OF FUNCTION DENSITY SCATTER PLOT -  - - - - - - - - - ##
###################################################################################

plot.density.scatter.plot <- function(x, y,  xlim=NULL, ylim=NULL, zlim=NULL, main=NULL, num.bins=50, ...)
{
 if (!is.numeric(x))
   stop("x must be numeric")
 if (!is.numeric(y))
   stop("y must be numeric")

 x.data <- as.vector(x)
 y.data <- as.vector(y)

 if (length(x.data)!=length(y.data))
   stop("x and y must have the same length.")

 if (is.null(xlim)) {
   data.bins.x <- pretty(c(x.data,y.data),n=num.bins)
 } else {
   data.bins.x <- seq(min(xlim),max(xlim),length=num.bins)
}

 if (is.null(ylim)) {
   data.bins.y <- pretty(c(x.data,y.data),n=num.bins)
 } else {
   data.bins.y <- seq(min(ylim),max(ylim),length=num.bins)
 }

 bin.x.min <-  min(data.bins.x)
 bin.x.max <- max(data.bins.x)
 bin.x.length <- data.bins.x[2] - data.bins.x[1]
 bin.y.min <-  min(data.bins.y)
 bin.y.max <- max(data.bins.y)
 bin.y.length <- data.bins.y[2] - data.bins.y[1]
 x.cut <- cut(x.data,data.bins.x,include.lowest=T)
 y.cut <- cut(y.data,data.bins.y,include.lowest=T)
 tab.x.y <- table(x.cut,y.cut)
 #Density in percent
 tab.x.y <- tab.x.y/length(x.data)*100
 #When data density =0, plot should be white.
 tab.x.y[tab.x.y==0] <- NA

 plot.seq.x <- seq(bin.x.min+bin.x.length/2,bin.x.max-bin.x.length/2,by=bin.x.length)
 plot.seq.y <- seq(bin.y.min+bin.y.length/2,bin.y.max-bin.y.length/2,by=bin.y.length)
 if(is.null(zlim))
   zlim <- range(tab.x.y,na.rm=T)
 #Density in percent
 if(is.null(main))
   main <- "Data Density Plot (%)"
# xlab <- deparse(substitute(x))
# ylab <- deparse(substitute(y))
  xlab <- paste(network," (",units,")",sep="")
  ylab <- paste(model_name," (",units,")",sep="")

 my.col.ramp <- colorRampPalette(c(grey(.9),"darkorchid4", "blue","darkgreen","yellow","orange","red", "brown"))
 my.col <- my.col.ramp(200)
 require(fields)
 image.plot(plot.seq.x,plot.seq.y,tab.x.y,col=my.col,zlim=zlim,main=main,xlab=xlab,ylab=ylab,...)
 # Include 1-1 line
 abline(0,1,col=1)
 # Include regression line
 y.x.lm <- lm(y.data~x.data)$coeff
 abline(y.x.lm[1],y.x.lm[2],col=grey(.3),lty=3,lwd=2)
 legend("topleft",bty="n",legend=paste("Y =",signif(y.x.lm[1],2),"+",signif(y.x.lm[2],2),"* X"),text.col=grey(.3))

 box()
}

##########################################################################
### Code to create color palette that will be used throughout the code ###
##########################################################################
hot_colors      <- colorRampPalette(c("yellow","orange","firebrick"))
cool_colors     <- colorRampPalette(c("darkorchid4","blue","green"))
all_colors      <- colorRampPalette(c("darkorchid4","blue","green","yellow","orange","firebrick"))
#all_colors      <- colorRampPalette(c("darkorchid4","blue","green4","green","yellow","yellow3","orange","firebrick"))
#all_colors      <- colorRampPalette(c("darkorchid4","blue","green4","green","yellow","orange","firebrick"))

if(!exists("greyscale")) {
   greyscale <- "n"
}

### Create greyscale colors palette ###
if (greyscale == "y") {
   hot_colors     <- colorRampPalette(c("grey60","grey80","grey90"))
   cool_colors    <- colorRampPalette(c("grey0","grey20","grey40"))
   all_colors     <- colorRampPalette(c("grey95","grey80","grey60","grey40","grey20","grey0"))
}
#########################################################################

#########################################################
### Create list of requested run_names
#########################################################

if(!exists("run_name1")) {
   run_name1 <- NULL
}

{
   run_names       <- run_name1
   if ((exists("run_name2")) && (nchar(run_name2) > 0)) {
      run_names <- c(run_names,run_name2)
   }
   if ((exists("run_name3")) && (nchar(run_name3) > 0)) {
      run_names <- c(run_names,run_name3)
   }
   if ((exists("run_name4")) && (nchar(run_name4) > 0)) {
      run_names <- c(run_names,run_name4)
   }
   if ((exists("run_name5")) && (nchar(run_name5) > 0)) {
      run_names <- c(run_names,run_name5)
   }
   if ((exists("run_name6")) && (nchar(run_name6) > 0)) {
      run_names <- c(run_names,run_name6)
   }
   if ((exists("run_name7")) && (nchar(run_name7) > 0)) {
      run_names <- c(run_names,run_name7)
   }
}
#########################################################

########################################
### Function to aggregate query data ###
########################################

aggregate_query <- function(data_in.df)
{
#   print(data_in.df)
   data_in.df[data_in.df==-999] <- NA
   agg_data <- aggregate(data_in.df[,-c(1,2,3,4,5,6,7)],by=list(stat_id=data_in.df$stat_id,lat=data_in.df$lat,lon=data_in.df$lon,ob_dates=data_in.df$ob_dates,ob_datee=data_in.df$ob_datee,ob_hour=data_in.df$ob_hour),FUN=function(x)mean(x,na.rm=T))
   agg_data[is.na(agg_data)] <- -999
   agg_data <- cbind(network=network,agg_data)
   #Order the outgoing data by start date and hour. Required for time series plots since the sorting is lost after the aggregate is run
   agg_data <- agg_data[order(agg_data$ob_dates,agg_data$ob_hour),]	
   agg_data$POCode <- 1
   return(agg_data)
}
########################################


############################################
### Function to read sitex file directly ###
############################################
read_sitex <- function(directory,network,run_name,species)
{
   if (!exists("aggregate_data")) { aggregate_data <- "y" }
   sitex_file 	<- paste(directory,"/",network,"_",run_name,".csv",sep="")
   species_ob 	<- paste(species[1],"_ob",sep="")
   species_mod 	<- paste(species[1],"_mod",sep="")
   if(file.exists(sitex_file)) {
      data_in.df 	<- read.csv(sitex_file,skip=5,header=T,as.is=T)
      if ((network == "AQS_Daily_O3") || (network == "CASTNET_Daily") || (network == "NAPS_Daily_O3") || (network == "EMEP_Daily_O3")) {
         data_in.df$Shh <- 0
      }
      ob_date_start <- paste(data_in.df$SYYYY,sprintf("%02d",data_in.df$SMM),sprintf("%02d",data_in.df$SDD),sep="-")
      ob_date_end   <- paste(data_in.df$EYYYY,sprintf("%02d",data_in.df$EMM),sprintf("%02d",data_in.df$EDD),sep="-")
      all_species   <- c(paste(species[1],"_ob",sep=""), paste(species[1],"_mod",sep=""))
      i <- 2
      while (i <= length(species)) {
         all_species <- c(all_species, paste(species[i],"_ob",sep=""), paste(species[i],"_mod",sep=""))
         i <- i+1
      }
      all_species <- c(all_species,"POCode")
      if ((network ==  "NADP_dep") || (network == "NADP_conc")) {
         all_species <- c(all_species,"Precip_ob","Precip_mod")
      }
      sitex_data.df <- data.frame(network=network,stat_id=data_in.df$SiteId,lat=data_in.df$Latitude,lon=data_in.df$Longitude,ob_dates=ob_date_start,ob_datee=ob_date_end,ob_hour=sprintf("%02d",data_in.df$Shh),month=sprintf("%02d",data_in.df$SMM),stringsAsFactors=F)
      for (j in 1:length(all_species)) {
         { 
            if (!(all_species[j]%in%names(data_in.df))) { sitex_data.df[all_species[j]] <- "-999" }
            else { sitex_data.df[all_species[j]] <- data_in.df[,all_species[j]] }
         }
      }
      species_units    <- read.csv(sitex_file,skip=3,nrows=1,header=F)
      header	       <- names(data_in.df)
      ob_unit	       <- species_units[which(header==species_ob)]
      data_exists_flag <- "y"
      num_specs        <- length(species)-1
      for (k in 0:num_specs) {
         ob_col  <- 9  + (2*k)
         mod_col <- 10 + (2*k)
         {
            if (length(sitex_data.df$stat_id > 0)) {
               count <- sum(is.na(sitex_data.df[,ob_col]))
               len   <- length(sitex_data.df[,mod_col])
               if (count == len) {
                  data_exists_flag <- "n"
               }
               else {
                  if ((remove_negatives == 'y') || (remove_negatives == 'Y') || (remove_negatives == 't') || (remove_negatives == 'T')) {
                     indic.nonzero       <- sitex_data.df[,ob_col] >= 0
                     sitex_data.df       <- sitex_data.df[indic.nonzero,]
                     indic.nonzero       <- sitex_data.df[,mod_col] >= 0
                     sitex_data.df       <- sitex_data.df[indic.nonzero,]
                  }
                  if (obs_per_day_limit > 0) {
                     num_obs_value <- tapply(sitex_data.df[,ob_col],sitex_data.df$ob_dates,function(x)sum(!is.na(x)))
                     drop_days <- names(num_obs_value)[num_obs_value < obs_per_day_limit]
                     aqdat_temp.df <- subset(sitex_data.df,!(ob_dates%in%drop_days))
                     aqdat_temp.df$ob_dates <- factor(aqdat_temp.df$ob_dates)
                     sitex_data.df <- aqdat_temp.df
                  }
               }
            }
            else {
               data_exists_flag <- "n"
            }
         }
      }
      if (data_exists_flag == "y") {
         if ((aggregate_data == 'y') || (aggregate_data == 'Y') || (aggregate_data == 't') || (aggregate_data == 'T')) {
            sitex_data.df <- aggregate_query(sitex_data.df)
         }
         sitex_data.df$stat_id <- paste(sitex_data.df$stat_id,sitex_data.df$POCode,sep='')
      }
      return(list(sitex_data=sitex_data.df,units=ob_unit,data_exists=data_exists_flag))
   }
   else {
      data_exists_flag <- "n"
      return(list(sitex_data=NULL,units=NULL,data_exists=data_exists_flag))
   }
}
############################################

##################################
### Function to query database ###
##################################

query_dbase <- function(project_id,network,species,criteria="Default",orderby=c("stat_id","ob_dates","ob_hour"))
{
   run_name     <- gsub("[.]","_",project_id)
   if (!exists("aggregate_data")) { aggregate_data <- "y" }
   data_order <- orderby[1]
   i <- 2 
   while (i <= length(orderby)) {
      data_order <- paste(data_order,orderby[i],sep=",")
      i <- i+1
   }
   species_query_string <- paste(", d.",species[1],"_ob, d.",species[1],"_mod",sep="")
   i <- 2
   while (i <= length(species)) {
      species_query_string <- paste(species_query_string,", d.",species[i],"_ob, d.",species[i],"_mod",sep="")
      i <- i+1
   }
   if (criteria == "Default") {
      criteria <- paste(" WHERE d.",species[1],"_ob is not NULL and d.network='",network,"'",query,sep="")                       # Set first part of the MYSQL query
   }
   if (zeroprecip == "y") { criteria <- paste(criteria, " and d.precip_ob > 0",sep="") }
   if (all_valid == "y") { criteria <- paste(criteria, " and (d.valid_code != ' ' or d.valid_code IS NULL)",sep="") }
   if (all_valid_amon == "y") { criteria <- paste(criteria, " and d.valid_code != 'C'",sep="") }
   check_POCode        <- paste("select * from information_schema.COLUMNS where TABLE_NAME = '",run_name,"' and COLUMN_NAME = 'POCode';",sep="")
   query_table_info.df <-db_Query(check_POCode,mysql)
   {
      if (length(query_table_info.df$COLUMN_NAME) == 0) {        # Check to see if POCode column exists or not
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month",species_query_string,",s.state from ",run_name," as d, site_metadata as s",criteria,"ORDER BY",data_order,sep=" ")      # Set the rest of the MYSQL query
         aqdat_query.df<-db_Query(qs,mysql)
#         aqdat_query.df$POCode <- 1
      }
      else {
         qs <- paste("SELECT d.network,d.stat_id,d.lat,d.lon,d.ob_dates,d.ob_datee,d.ob_hour,d.month",species_query_string,",POCode,s.state from ",run_name," as d, site_metadata as s",criteria,"ORDER BY",data_order,sep=" ")      # Set the rest of the MYSQL query
         aqdat_query.df<-db_Query(qs,mysql)
      }
   }
   print(qs)
   data_exists_flag <- "y"
   num_specs <- length(species)-1
   for (k in 0:num_specs) {
      ob_col  <- 9+2*k
      mod_col <- 10+2*k
      {
         if (length(aqdat_query.df$stat_id > 0)) {
            count_na <- sum(is.na(aqdat_query.df[,ob_col]))	# Check for all data not available
            count_missing <- sum(aqdat_query.df[,ob_col] < -90)	# Check for all data missing
            len   <- length(aqdat_query.df[,mod_col])
            if ((count_na == len) || (count_missing == len)) {
               data_exists_flag <- "n"
            }
            else {
               if ((all_valid == "y") && ((network == "NADP") || (network == "AMON") || (network == "MDN"))) {
                  indic.missing <- aqdat_query.df[,ob_col] < 0  # Check for observations that are less than 0
                  aqdat_query.df[indic.missing,ob_col] <- 0     # Replace those observations with 0 (we assume a valid observation, just not negative). Applies primarily to NTN networks (i.e. NADP, AMON, MDN)
               }
               if ((remove_negatives == 'y') || (remove_negatives == 'Y') || (remove_negatives == 't') || (remove_negatives == 'T')) {
                  indic.nonzero       <- aqdat_query.df[,ob_col] >= 0
                  aqdat_query.df      <- aqdat_query.df[indic.nonzero,]
                  indic.nonzero       <- aqdat_query.df[,mod_col] >= 0
                  aqdat_query.df      <- aqdat_query.df[indic.nonzero,]
               }
               if (obs_per_day_limit > 0) {
                  num_obs_value <- tapply(aqdat_query.df[,ob_col],aqdat_query.df$ob_dates,function(x)sum(!is.na(x)))
                  drop_days <- names(num_obs_value)[num_obs_value < obs_per_day_limit]
                  aqdat_temp.df <- subset(aqdat_query.df,!(ob_dates%in%drop_days))
                  aqdat_temp.df$ob_dates <- factor(aqdat_temp.df$ob_dates)
                  aqdat_query.df <- aqdat_temp.df
               }
            }
         }
         else {
            data_exists_flag <- "n"
         }
      }
   }
   if (data_exists_flag == "y") {
      if (length(query_table_info.df$COLUMN_NAME) == 0) { aqdat_query.df$POCode <- 1 }
      if ((aggregate_data == 'y') || (aggregate_data == 'Y') || (aggregate_data == 't') || (aggregate_data == 'T')) {
         aqdat_query.df <- aggregate_query(aqdat_query.df)
      }
      if ((!exists("merge_statid_POC") || merge_statid_POC == "y")) {
         aqdat_query.df$stat_id <- paste(aqdat_query.df$stat_id,aqdat_query.df$POCode,sep='')
      }
   }
   units_qs        <- paste("SELECT ",species[1]," from project_units where proj_code = '",run_name,"' and network = '",network,"'", sep="")
   units           <- db_Query(units_qs,mysql)
   if (length(units) == 0) {
      units <- ""
   }
   model_name_qs   <- paste("SELECT model from aq_project_log where proj_code ='",run_name,"'", sep="")
   model_name_out  <- db_Query(model_name_qs,mysql)
   model_name      <- model_name_out[[1]]
   return(list(aqdat_query.df,data_exists_flag,units,model_name))
}
########################################
