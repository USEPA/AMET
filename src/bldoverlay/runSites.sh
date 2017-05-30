#!/bin/sh

FILETYPE=SITES; export FILETYPE
INFILE=/project/model_eval/obs_data/castnet_sites.txt; export INFILE

VALUE="2.0"; export VALUE

SDATE=2001001; export SDATE
EDATE=2001005; export EDATE

OUTFILE=sites.ncf; export OUTFILE

/project/nox/src/bldoverlay/bldoverlay.exe

echo run complete, output = ${OUTFILE}
