#!/bin/sh

SDATE=2001001; export SDATE
EDATE=2001031; export EDATE

FILETYPE=MET; export FILETYPE
INFILE=/project/model_eval/obs_data/castnet_hr.csv; export INFILE
SITEFILE=/project/model_eval/obs_data/castnet_sites.txt; export SITEFILE

OUTFILE=MET.ncf; export OUTFILE

/project/nox/src/bldoverlay/bldoverlay.exe

echo run complete, output = ${OUTFILE}
