#!/bin/sh

FILETYPE=OBS; export FILETYPE
INFILE=/home/appel/ozone_overlay_input.csv; export INFILE

SPECIES="O3"; export SPECIES
UNITS="ppm"; export UNITS

## set overlay type to one of the following: (HOURLY, DAILY, 1HRMAX, 8HRMAX)
#OLAYTYPE=HOURLY; export OLAYTYPE
#OLAYTYPE=DAILY; export OLAYTYPE
#OLAYTYPE=1HRMAX; export OLAYTYPE
 OLAYTYPE=8HRMAX; export OLAYTYPE

OUTFILE=obs.ncf; export OUTFILE

/project/nox/src/bldoverlay/bldoverlay.exe

echo run complete, output = ${OUTFILE}
