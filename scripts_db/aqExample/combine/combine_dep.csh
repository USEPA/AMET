#!/bin/csh -f

 set YEAR    = 2002
 set METYEAR = 02
 set MONTH   = 07 
 set STDAY   = 01 
 set ENDAY   = 10 
 set METDIR  = ./ 
 set MODEL   = 2001ah_k4a_eus12b
 set GRID    = 36km
 set APPL    = Kzmin_Y
 set DATADIR = ./ 

 setenv OUTFILE ./test.${GRID}.dep
 rm $OUTFILE

 setenv SPECIES_DEF spec_def_dep_AE6_All_Species
# setenv SPECIES_DEF spec_def_dep_AE6_AMET_Species_Only

@ DAY = ${STDAY}
 while ( $DAY <= ${ENDAY} )
    set DATE = ${YEAR}${MONTH}`printf "%02d" $DAY`
    set METDATE = `printf "%02d" $METYEAR`${MONTH}`printf "%02d" $DAY`
    setenv INFILE1 ${DATADIR}/DRYDEP.${DATE} 
    setenv INFILE2 ${DATADIR}/WETDEP1.${DATE}
    setenv INFILE3 ${METDIR}/METCRO2D_${METDATE}    
    ~/AMET/bin/combine.exe
@ DAY++
    end

exit 0


