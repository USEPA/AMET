#!/bin/sh

SDATE=2001001; export SDATE
EDATE=2001031; export EDATE

FILETYPE=AIRS; export FILETYPE

## set overlay type to one of the following: (HOURLY, DAILY, 1HRMAX, 8HRMAX) 
 OLAYTYPE=HOURLY; export OLAYTYPE
 OLAYTYPE=DAILY; export OLAYTYPE
#OLAYTYPE=1HRMAX; export OLAYTYPE
#OLAYTYPE=8HRMAX; export OLAYTYPE

INFILE=/project/model_eval/obs_data/airs_ozone.txt; export INFILE

OUTFILE=airs.ncf; export OUTFILE

/project/nox/src/bldoverlay/bldoverlay.exe

echo run complete, output = ${OUTFILE}
