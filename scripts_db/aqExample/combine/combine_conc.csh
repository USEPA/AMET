#!/bin/csh -f

 set YEAR    = 2002
 set METYEAR = 02
 set MONTH   = 07 
 set STDAY   = 01 
 set ENDAY   = 10 
 set METDIR  = /project/amet_aq/AMET_Code/CEP_Code/test_data
 set MODEL   = 2001ah_k4a_eus12b 
 set GRID    = 36km
 set APPL    = Kzmin_Y
 set DATADIR = /project/amet_aq/AMET_Code/CEP_Code/test_data

 setenv OUTFILE ./test.${GRID}.conc.test
 rm $OUTFILE

 setenv SPECIES_DEF spec_def_conc_CB05_AE6_All_Species
# setenv SPECIES_DEF spec_def_conc_CB05_AE6_AMET_Species_Only
# setenv SPECIES_DEF spec_12_CB4_std 

@ DAY = ${STDAY}
 while ( $DAY <= ${ENDAY} )
    set DATE = ${YEAR}${MONTH}`printf "%02d" $DAY`
    set METDATE = `printf "%02d" $METYEAR`${MONTH}`printf "%02d" $DAY`
#    setenv INFILE1 ${DATADIR}/test.ACONC.${DATE}
    setenv INFILE1 ${DATADIR}/test.CONC.${DATE}
    setenv INFILE2 ${DATADIR}/test.AEROVIS.${DATE}
    setenv INFILE3 ${METDIR}/METCRO3D_${METDATE}
    setenv INFILE4 ${DATADIR}/AERODIAM_${DATE}
    setenv INFILE5 ${METDIR}/METCRO2D_${METDATE}
    ~/AMET/bin/combine.exe
@ DAY++
    end

exit 0


