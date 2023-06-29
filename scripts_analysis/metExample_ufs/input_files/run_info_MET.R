###  Consolidated R input settings file for Meteorology scripts ###
###  Combined for universal input to AMET GUI method of running analysis scripts ###
### daily_barplot, radiation, raob, spatial_surface, summary, timeseries, timeseries_rh ###


# Main settings for timeseries #
project    <- Sys.getenv("AMET_PROJECT")
project2   <- ""
project1   <- project
model      <- project
model1     <- project
model2     <- project2
saveid     <- project
statid     <- "ALL"
statid     <- c("KGSO","KMFL")

# Extra label to distinguish plots and out files (daily barplot) #
runid      <-"AMET_GUI"
pid        <- runid
queryID    <- pid
figid_sub  <- runid

# Plot and figure output directory #
figdir     <- Sys.getenv("AMET_OUT")
savedir    <- Sys.getenv("AMET_OUT")

# Maximum records allowed from database #
maxrec     <- 5000000

# Threshold count for computing statistics
thresh     <- 120

# Logical controls #
savefile   <- T
textout    <- T
textstats  <- textout
wantsave   <- savefile
wdweightws <- T
groupstat  <- F
ametp      <- T
diurnal    <- T
spatial    <- T
timeseries <- T
histogram  <- T
SPATIALM   <- T
TSERIESM   <- T
PROFM      <- T
CURTAINM   <- F
PROFN      <- F
CURTAINN   <- F

# Logicals for spatial surface statistics #
histplot    <- F
shadeplot   <- F
daily       <- F
wantfigs    <- T
checksave   <- F
t.test.flag <- F

# Specific query for daily barplot #
querystr   <-"AND ob_date BETWEEN 20160701 AND 20160731 ORDER BY ob_date"
querystr   <-"AND d.ob_date >=  20160701 AND d.ob_date < 20160801 ORDER BY d.ob_date"

# Specific query for summary plots #
#query_str  <-"AND ob_date BETWEEN 20160101 AND 20160106"

# Fine-tune query extra specs #
extra      <- ""
extra2     <- ""

# Date-based specs #
date <- c(as.numeric(paste(Sys.getenv("AMET_YEAR"),"0101",sep="")),as.numeric(paste(Sys.getenv("AMET_YEAR"),"1231",sep="")))
hs   <- "00"
he   <- "23"
ds   <- "01"
de   <- "02"
ms   <- "01"
me   <- "01"
ys   <- Sys.getenv("AMET_YEAR")
ye   <- Sys.getenv("AMET_YEAR")
dates<-list(y=as.numeric(ys),m=as.numeric(ms),d=as.numeric(ds),h=as.numeric(hs))
datee<-list(y=as.numeric(ye),m=as.numeric(me),d=as.numeric(de),h=as.numeric(he))

# Spatial statistics plotting bounds (latSouth, latNorth, longWest, longEast) #
lats    <-as.numeric(unlist(strsplit(Sys.getenv("AMET_BOUNDS_LAT")," ")))[1]
latn    <-as.numeric(unlist(strsplit(Sys.getenv("AMET_BOUNDS_LAT")," ")))[2]
lonw    <-as.numeric(unlist(strsplit(Sys.getenv("AMET_BOUNDS_LON")," ")))[1]
lone    <-as.numeric(unlist(strsplit(Sys.getenv("AMET_BOUNDS_LON")," ")))[2]
bounds  <-c(lats,latn,lonw,lone)

# Plot settings #
plotsize  <- 1
plotfmt   <- "pdf"
symb      <- 19
symbo     <- 21
symbsiz   <- 1.6
scex      <- 0.65
pheight   <- 900
pwidth    <- 1600
sres      <- 0.10

plotopts   <-list(figdir=figdir, plotsize=plotsize, plotfmt=plotfmt, symb=symb,symbo=symbo, symbsiz=symbsiz, pheight=pheight, pwidth=pwidth, project=project, bounds=bounds)

# GROSS	QC/QA limits for T (K), WS (m/s), Q (g/kg), RH (%) and PS (hPa): Min, Max
qcT   <-c(240,315)
qcQ   <-c(0,30)
qcWS  <-c(1.5,25)
qcRH  <-c(0,102)
qcPS  <-c(50,107)
qclims<-list(qcT=qcT,qcQ=qcQ,qcWS=qcWS,qcRH=qcRH,qcPS=qcPS)                                                                   

# QC limits on max difference between Model and Obs as another filter #
# value assignment is T, WS, Q, RH  -- SI units #
qcerror    <- c(15,20,10,50)

# Summary plot index loc of required stats from query #
dstatloc <-c(16,17,18)

# RAOB: Pressure layer range for RAOB DATA EXTRACTION
layer    <- c(1000,100)

# RAOB: Pressure layer range for RAOB PLOTTING
proflim  <- c(1000,300)

# RAOB: Sample size threshold of 5 samples for spatial layer avg. statistics
spatial.thresh <- 5 

# RAOB: Sample size threshold for pressure level statistics
level.thresh   <- 5

# RAOB: Sample size threshold for number of sounding
sounding.thresh<- 5
 
# RAOB: Sample size threshold for minimum layers needed for native profile plot
profilen.thresh<- 5

# RAOB: Configurable range for difference *PLOT* range (Native Curtain plots)
# Note diff.t 5 is -5 to +5 diff range.
use.user.range <- TRUE
diff.t         <- 5
diff.rh        <- 50
user.custom.plot.settings <- list(use.user.range=use.user.range, diff.t=diff.t, diff.rh=diff.rh)

# Summary plot labels #
stat_id     <- "NULL"
obnetwork   <- "ALL"
lat         <- "ALL"
lon         <- "ALL"
elev        <- "NULL"
landuse     <- "NULL"
date_s      <- "ALL"
date_e      <- "ALL"
obtime      <- "ALL"
fcasthr     <- "ALL"
level       <- "surface"
syncond     <- "NULL"
figure      <- "NULL"

# Levels for Shortwave radiation Metrics Bias, RMSE, Mean Abs Error and St.Dev #
levsBIAS    <- c(-300,-150,-100,-75,-40,-20,-10,0,10,20,40,75,100,150,300)
levsRMSE    <- c(0,25,50,75,100,125,150,175,200,250,300,400,500)
levsMAE     <- c(0,25,50,75,100,125,150,175,200,250,300)
levsSDEV    <- c(-150,-100,-75,-40,-20,-10,0,10,20,40,75,100,150)

# Inputs from PRISM Tab
  # Used in other scripts
amet_gui       <- T
model_outdir   <- "/work/ROMO/met/2021_WRF"
model_prefix   <- "wrfout_d01_"

daily          <- F
monthly        <- F
annual         <- F

start_tindex   <- 1
end_tindex     <- 24

donetcdf       <- T

prismdir       <- "./prismdir_shared"

use.default.precip.levs   <- T 
use.range.precip.levs     <- F 

bil            <- T
prism_prefix   <- "noprefixneeded"
leaf_dxdykm    <- -99

pbins          <-c(0,25,50,75,100,125,150,175,200,250)
pdbins         <-c(-250,-100,-50,-25,-15,-5,0,5,15,25,50,100,250)
cols1          <-c("#ffffe5","#f7fcb9","#d9f0a3","#addd8e","#78c679","#41ab5d","#238443","#006837","#004529","#2171b5","#6baed6","#bdd7e7","#eff3ff")
dcols1         <-c("#543005","#8c510a","#bf812d","#dfc27d","#f6e8c3","#f5f5f5","#c7eae5","#80cdc1","#35978f","#01665e","#003c30")



