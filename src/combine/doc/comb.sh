#!/bin/sh
#
# script for running the combine program on Unix
#
#  generates a new concentration file from output from the CMAQ model run I2a dataset
#

BASE=/project/model_evalb/extract_util

EXECUTION_ID=combineV3.0; export EXECUTION_ID

#EXEC=${BASE}/bin/${EXECUTION_ID}.exe
 EXEC=/project/model_evalb/extract_util/src/combine/combineV3.0.exe
#EXEC=/direct/linux/tools/bin/combine.exe

## use GENSPEC switch to generate a new specdef file (does not generate output file)
   GENSPEC=N; export GENSPEC

## define name of species definition file
   SPECIES_DEF=spec.def; export SPECIES_DEF

## define name of input files
#  INFILE1=${BASE}/cmaq_data/CCTM_I2a.std.200101.conc; export INFILE1
   INFILE1=/project/model_evalb/model_eval/2001_05release/cctm_J2b_b313/12km/CCTM_J2b_b313.std.12km.200101.conc; export INFILE1
   INFILE2=/project/model_evalb/model_eval/2001_05release/cctm_J2b_b313/12km/CCTM_J2b_b313.std.12km.200101.dep; export INFILE2
 
## define name of output file 
#  OUTFILE=${BASE}/combine/output/I2a.combineV2.0.200101.conc; export OUTFILE
   OUTFILE=CCTM_J2b_b313.std.12km.200101.conc; export OUTFILE

${EXEC}

echo runs competed with output file = $OUTFILE
