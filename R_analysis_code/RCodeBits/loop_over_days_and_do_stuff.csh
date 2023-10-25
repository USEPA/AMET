#! /bin/csh 

#SBATCH -J EQUATES_PROC2
#SBATCH --export=NONE
#SBATCH -p singlepe
#SBATCH -t 24:00:00
#SBATCH -n 1

#############################################################
# Main run config setttings: date start/end, WRF exe, RunID,
#                            relevant dirs
set begday       = 20150101 
set endday       = 20151231 

#############################################################
setenv NETWORK KDED 
#setenv NETWORK NJWxNet

set year  = `echo begday |cut -b1-4`
set date = $begday
echo $begday
#-- Main LOOP Over Days defined above.
while ( $date <= $endday )

  # Date stuff. Day prior, current day and next day
  set dm1 = `date -d "$date -1 days" '+%Y%m%d' `
  set dp1 = `date -d "$date  1 days" '+%Y%m%d' `
  set dp2 = `date -d "$date  2 days" '+%Y%m%d' `

  setenv YYYYM `echo $dm1 |cut -b1-4`
  setenv YYM   `echo $date |cut -b3-4`
  setenv MMM   `echo $dm1 |cut -b5-6`
  setenv DDM   `echo $dm1 |cut -b7-8`

  setenv YYYYS `echo $date |cut -b1-4`
  setenv YYS   `echo $date |cut -b3-4`
  setenv MMS   `echo $date |cut -b5-6`
  setenv DDS   `echo $date |cut -b7-8`

  setenv YYYYE `echo $dp1  |cut -b1-4`
  setenv YYE   `echo $date |cut -b3-4`
  setenv MME   `echo $dp1  |cut -b5-6`
  setenv DDE   `echo $dp1  |cut -b7-8`

 ###########################################################
 # Do Stuff here
 setenv DATESTR $YYYYS$MMS$DDS
 R --no-save --slave --args < meso_srad.search.R
 #exit(1)
 ###########################################################
 # Advance day +1
 set date = `date -d "$date 1 days" '+%Y%m%d' `

end

exit(1)
####################################################################

