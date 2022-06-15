#! /bin/csh 
#############################################################
# Main run config setttings: date start/end, WRF exe, RunID,
#                            relevant dirs
setenv AMETBASE   /home/user/AMET

set begday       = 20160701
set endday       = 20160731

#############################################################
set sfcscript   = $AMETBASE/scripts_db/metExample_mcip/matching_surface.csh
set raobscript  = $AMETBASE/scripts_db/metExample_mcip/matching_raob.csh
#############################################################


set year  = `echo begday |cut -b1-4`
set date = $begday
echo $begday
#-- Main LOOP Over Days defined above.
while ( $date <= $endday )

  setenv YYYYS `echo $date |cut -b1-4`
  setenv YYS   `echo $date |cut -b3-4`
  setenv MMS   `echo $date |cut -b5-6`
  setenv DDS   `echo $date |cut -b7-8`

  setenv METTMPDIRX $AMETBASE/model_data/MET/metExample_mcip/TMP
  setenv GRIDCROX   $AMETBASE/model_data/MET/metExample_mcip/GRIDCRO2D
  setenv METCRO2DX  $AMETBASE/model_data/MET/metExample_mcip/METCRO2D_${YYS}${MMS}${DDS}.nc
  setenv METCRO3DX  $AMETBASE/model_data/MET/metExample_mcip/METCRO3D_${YYS}${MMS}${DDS}.nc
  setenv METDOT3DX  $AMETBASE/model_data/MET/metExample_mcip/METDOT3D_${YYS}${MMS}${DDS}.nc

  echo $date

  echo "Running AMET upper-air met matching"
  $raobscript
 
  ## SURFACE MET disabled below. To enable daily surface met matching the $sfcscript needs
  ## this line modified for correct METOUTPUT setting passed into the script:
  ##  setenv METOUTPUT ${METCRO2DX}
  #echo "Running AMET surface met matching"
  #$sfcscript
 
 ###########################################################
 # Advance day +1
 set date = `date -d "$date 1 days" '+%Y%m%d' `

end

exit(1)
####################################################################

