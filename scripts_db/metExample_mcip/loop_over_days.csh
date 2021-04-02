#! /bin/csh 

#SBATCH -J AMET_Testing
#SBATCH --export=NONE
#SBATCH -p singlepe
#SBATCH -t 01:00:00
#SBATCH -n 1

#############################################################
# System config setttings ** No need to change **
limit stacksize unlimited
limit memorylocked unlimited
limit vmemoryuse unlimited
limit coredumpsize unlimited
cat $0
date
uname -a
#############################################################

#############################################################
# Main run config setttings: date start/end, WRF exe, RunID,
#                            relevant dirs
set begday       = 20201018
set endday       = 20201029

setenv METTMPDIRX /work/MOD3DEV/grc/NRT_WRF_CMAQ/model_outputs/12us/mcip/EPA_MCIP/TMP

#############################################################
set sfcscript   = /home/grc/AMET_v13/scripts_db/mcip_12us1/matching_surface.csh
set bsrnscript   = /home/grc/AMET_v13/scripts_db/mcip_12us1/matching_bsrn.csh
set raobscript   = /home/grc/AMET_v13/scripts_db/mcip_12us1/matching_raob.csh
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

  setenv GRIDCROX /work/MOD3DEV/grc/NRT_WRF_CMAQ/model_outputs/12us/mcip/EPA_MCIP/GRIDCRO2D
  setenv METCRO2DX  /work/MOD3DEV/grc/NRT_WRF_CMAQ/model_outputs/12us/mcip/EPA_MCIP/METCRO2D_${date}.nc4
  setenv METCRO3DX  /work/MOD3DEV/grc/NRT_WRF_CMAQ/model_outputs/12us/mcip/EPA_MCIP/METCRO3D_${date}.nc4
  setenv METDOT3DX  /work/MOD3DEV/grc/NRT_WRF_CMAQ/model_outputs/12us/mcip/EPA_MCIP/METDOT3D_${date}.nc4

  echo $date

  echo "Running AMET radiation matching"
   $bsrnscript
  echo "Running AMET surface matching"
   $sfcscript
  echo "Running AMET raob matching"
   $raobscript
  
 ###########################################################
 # Advance day +1
 set date = `date -d "$date 1 days" '+%Y%m%d' `

end

exit(1)
####################################################################

