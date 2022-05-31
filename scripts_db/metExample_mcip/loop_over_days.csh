#! /bin/csh 
#############################################################
# Main run config setttings: date start/end, WRF exe, RunID,
#                            relevant dirs

setenv AMET_PROJECT    metExample_mcip

set begday       = 20160701
echo 'begday=',$begday
set endday       = 20160731
echo 'endday=',$endday

setenv METTMPDIRX /proj/ie/proj/CMAS/AMET/AMET_v15/model_data/MET/metExample_mcip/TMP

#############################################################
set sfcscript   = $AMETBASE/scripts_db/metExample_mcip/matching_surface.csh
set bsrnscript   = $AMETBASE/scripts_db/metExample_mcip/matching_bsrn.csh
set raobscript   = $AMETBASE/scripts_db/metExample_mcip/matching_raob.csh
#############################################################


set year  = `echo begday |cut -b1-4`
echo 'year=',$year
set date = $begday
echo 'date=',$date
echo $begday
#-- Main LOOP Over Days defined above.
while ( $date <= $endday )

	setenv YYYY `echo $date | cut -b 1-4`
	echo 'YYYS='$YYYY
	setenv YY   `echo $date | cut -b3-4`
	echo 'YY='$YY
	setenv YYMMDD   `echo $date | cut -b3-8`
	echo 'YYMMDD='$YYMMDD

  setenv GRIDCRO $AMETBASE/model_data/MET/$AMET_PROJECT/GRIDCRO2D_${YYMMDD}.nc
  setenv METCRO  $AMETBASE/model_data/MET/$AMET_PROJECT/METCRO3D_${YYMMDD}.nc
  setenv METDOT  $AMETBASE/model_data/MET/$AMET_PROJECT//METDOT3D_${YYMMDD}.nc

  echo 'date=',$date

  #echo "Running AMET radiation matching"
  #    $bsrnscript
  #echo "Running AMET surface matching"
  # $sfcscript
  echo "Running AMET raob matching"
   $raobscript
  
 ###########################################################
 # Advance day +1
 set date = `date -d "$date 1 days" '+%Y%m%d' `
 echo 'date=',$date

end

exit(1)
####################################################################

