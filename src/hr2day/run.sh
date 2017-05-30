#!/bin/sh

###
### script to compute daily data file from hourly data
###

IOAPI_ISPH=19;  export IOAPI_ISPH
EXECUTION_ID=/project/nox/src/hr2day/hr2day.exe; export EXECUTION_ID

DATA=/project/showard/holland2/data

### set input and output files
INFILE=${DATA}/CMAQ_O3_PM25_36km_2006.ioapi; export INFILE
OUTFILE=daily.ioapi; export OUTFILE

### set to use local time (default is GMT)
USELOCAL=Y; export USELOCAL
USEDST=N; export USEDST  

### set partial day switch
PARTIAL_DAY=Y; export PARTIAL_DAY
HROFFSET=0; export HROFFSET

### define species (format: "Name, units, From_species, Operation")
###  operations : {SUM, AVG, MIN, MAX, @MAXT, MAXDIF, 8HRMAX,
###                W126, @8HRMAXO3, HR@8HRMAX}

SPECIES_1="O3_8HRMAX,ppm,O3,8HRMAX"; export SPECIES_1
SPECIES_2="O3_W126,ppm,0.001*O3,W126"; export SPECIES_2
SPECIES_3="PM25,ug/m3,PM25,AVG"; export SPECIES_3
SPECIES_4="PM25_MAX,ug/m3,PM25,MAX"; export SPECIES_4

${EXECUTION_ID}


