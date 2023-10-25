  require(ncdf4)

  yyyy      <- Sys.getenv("YYYY")
  file      <- Sys.getenv("OUTFILE")

  prefix    <-"wrf_prism_precip"

  files <-file
  nf    <-length(files)

  for(f in 1:nf) {
    parts<-unlist(strsplit(files[f], " "))
    file <-parts[length(parts)]

    f1  <-nc_open(file)
      tmpp<- ncvar_get(f1,varid="PRISM_PRECIP_MM")
      tmpm<- ncvar_get(f1,varid="MODEL_PRECIP_MM")
    nc_close(f1)

    writeLines(paste("Reading wrf-prism file and adding to total precip:",file))
    writeLines(paste(round(sum(tmpp)),round(sum(tmpm))))
    if(f ==1 ){
      prism_total<-tmpp
      model_total<-tmpm
    }
    if(f>1) {
      prism_total<- prism_total + tmpp
      model_total<- model_total + tmpm
    }

  }
  prism_total_masked<-ifelse(prism_total==0,NA,prism_total)
  model_total_masked<-ifelse(prism_total==0,NA,model_total)
  diff <- model_total_masked- prism_total_masked
  bias.grid <-mean(diff,na.rm=T)
  mea.grid  <-mean(abs(diff),na.rm=T)
  cor.grid  <-cor(matrix(model_total_masked),matrix(prism_total_masked),use='complete.obs')
  writeLines(paste("Grid Mean Error -- Bias (mm):",bias.grid))  
  writeLines(paste("Grid Mean Absolute Error (mm):",mea.grid))  
  writeLines(paste("Grid Correlation:",cor.grid))
  writeLines(paste("Note that model and obs gridpoint are set to missing for all no-precip obs cells."))

quit(save="no")

  writeLines(paste("Creating accumulated precipitation file:",accumout))
  system(paste("cp",file,accumout))
  f1  <-nc_open(accumout, write=T)
    tmpp<- ncvar_put(f1,varid="PRISM_PRECIP_MM",prism_total)
    tmpm<- ncvar_put(f1,varid="MODEL_PRECIP_MM",model_total)
  nc_close(f1)



    f1  <-nc_open("wrfv4_hyb_nomodis_2016Annual.nc")
      prism_ann<- ncvar_get(f1,varid="PRISM_PRECIP_MM")
    nc_close(f1)

  require(ncdf4)
  accumout<-"wrfv4_hyb_nomodis_JFM_MASK.nc"
  accumout<-"wrfv4_hyb_nomodis_OND_MASK.nc"
  accumout<-"wrfv4_hyb_nomodis_JAS_MASK.nc"
  accumout<-"wrfv4_hyb_nomodis_AMJ_MASK.nc"
  f1  <-nc_open(accumout, write=T)
    tmpp<- ncvar_get(f1,varid="PRISM_PRECIP_MM")
    tmpm<- ncvar_get(f1,varid="MODEL_PRECIP_MM")
 #    tmppm<-ifelse(prism_ann > 25.4*10, tmpp, 0)
    tmppm<-ifelse(tmpp > 25.4*2.5, tmpp, 0)
    tmpmm<-ifelse(tmppm == 0, 0, tmpm)
    ncvar_put(f1,varid="PRISM_PRECIP_MM",tmppm)
    ncvar_put(f1,varid="MODEL_PRECIP_MM",tmpmm)
  nc_close(f1)






