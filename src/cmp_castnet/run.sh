#!/bin/sh

#
# script for running the cmp_castnet site-extract program on Unix
#

EXEC=cmp_castnet.exe  

## define time window
  START_DATE=2002153;  export START_DATE
  END_DATE=2002158   export END_DATE

  START_TIME=0;        export START_TIME
  END_TIME=230000;     export END_TIME

## flag to indicate to compute maximun hourly & 8-hour daily values
## else output hourly values
  COMPUTE_MAX=Y; export COMPUTE_MAX

## adjust for daylight savings 
  APPLY_DLS=N; export APPLY_DLS 

## define ozone species (convert from ppb to ppm)
  OZONE="0.001*O3,ppm"; export OZONE

## Projection sphere type (use type #20 to match CMAQ)                                                       
  IOAPI_ISPH=20; export IOAPI_ISPH  

## define missing values string
  MISSING="-99."; export MISSING

## define partial day settings (from_hour, to_hour)
#  PARTIAL_DAY="11,17"; export PARTIAL_DAY

#############################################################
#  Input files
#############################################################

# ioapi input files containing VNAMES (max of 10)
M3_FILE_1=/project/aliceg/CA11/conc_files/CB4/cctm_J4c_02emisv25.std.200206.conc;  export M3_FILE_1
 

#  SITE FILE containing site-id, longitude, latitude
SITE_FILE=/project/model_evalb/extract_util/castnet/obs/castnet_sites.txt; export SITE_FILE

# : input data file                        
IN_TABLE=/project/model_evalb/extract_util/castnet/obs/cast_ozone_2002.csv; export IN_TABLE


#############################################################
#  Output files
#############################################################

#  output table 
  OUT_TABLE=maxout.csv; export OUT_TABLE

  AVG_TABLE=avgout.csv; export AVG_TABLE

 /project/model_eval/src/cmp_castnet/${EXEC}

 echo run completed, output file = ${OUT_TABLE}

