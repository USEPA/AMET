##------------------------------------------------------##
#   FILE NAME: AMET_species_list.pl			 #
#							 #
#   This file is required by the AMET perl script        #
#   amet_extract_all.pl.  It establishes the species     #
#   that will be extracted for each network.  This is    #
#   the default version of this file.  Changes can be    #
#   made and used with the amet_extract_all.pl script    #
#							 #
#       REQUIRED: amet_extract_all.pl	 		 #
#	                                                 #
#       PURPOSE: Species configuration file              #
#                                                        #
#       LAST UPDATE by Wyat Appel: November 6, 2012      #
##------------------------------------------------------##

@spec_num=(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31);   

##########################
## IMPROVE Species List ##
##########################

$k=10;
$species_IMPROVE = "
  AERO_1=\"SO4f_val,ug/m3,ASO4IJ,,SO4\";                         export AERO_1   # sulfate
  AERO_2=\"NO3f_val,ug/m3,ANO3IJ,,NO3\";                         export AERO_2   # nitrate
  AERO_3=\"NH4f_val,ug/m3,ANH4IJ,,NH4\";                         export AERO_3   # ammonium
  AERO_4=\"MF_val,ug/m3,PMIJ,ug/m3,PM_TOT\";                     export AERO_4   # Total PM2.5 mass 
  AERO_5=\"OCf_val,ug/m3,AOCIJ,,OC\";                            export AERO_5   # Organic Carbon
  AERO_6=\"ECf_val,ug/m3,AECIJ,,EC\";                            export AERO_6   # Elemental Carbon
  AERO_7=\"OCf_val+ECf_val,ug/m3,AOCIJ+AECIJ,,TC\";              export AERO_7   # Total Carbon
  AERO_8=\"CHLf_val,ug/m3,ACLIJ,ug/m3,Cl\";                      export AERO_8   # CL Ion
  AERO_9=\"MT_val,ug/m3,PM10,ug/m3,PM10\";                       export AERO_9   # PM10
  AERO_10=\"CM_calculated_val,ug/m3,PMC_TOT,ug/m3,PMC_TOT\";	 export AERO_10  # PM Course
";
$species_cutoff_IMPROVE = "
## PM2.5 Sharp Cutoff Species
## Requires preprocessing using AERODIAM file
  AERO_11=\"SO4f_val,ug/m3,PM25_SO4,,PM25_SO4\";                 export AERO_11  # sulfate (< 2.5um)
  AERO_12=\"NO3f_val,ug/m3,PM25_NO3,,PM25_NO3\";                 export AERO_12  # nitrate (< 2.5um)
  AERO_13=\"NH4f_val,ug/m3,PM25_NH4,,PM25_NH4\";                 export AERO_13  # ammonium (< 2.5um)
  AERO_14=\"OCf_val,ug/m3,PM25_OC,,PM25_OC\";                    export AERO_14  # Organic Carbon (< 2.5um)
  AERO_15=\"ECf_val,ug/m3,PM25_EC,,PM25_EC\";                    export AERO_15  # Elemental Carbon (< 2.5um)
  AERO_16=\"OCf_val+ECf_val,ug/m3,PM25_OC+PM25_EC,,PM25_TC\";    export AERO_16  # Total Carbon (< 2.5um)
  AERO_17=\"MF_val,ug/m3,PM25_TOT,ug/m3,PM25_TOT\";              export AERO_17  # Total PM2.5 mass (< 2.5um)
  AERO_18=\"CHLf_val,ug/m3,PM25_CL,ug/m3,PM25_Cl\";              export AERO_18  # CL Ion (< 2.5um)
";
if (($cutoff eq "y") || ($cutoff eq "Y") || ($cutoff eq "t") || ($cutoff eq "T")) { $k=18; }
$species_AE6_IMPROVE = "
# new AE6 species
## note: we use XRF sodium because there is not IC sodium mesaurement
## we use IC measurement for chlorid (CHLf_val) instead of XRF chlroine (CLf_Val)
  AERO_$spec_num[$k+0]=\"NAf_val,ug/m3, ANAIJ,,Na\";                          export AERO_$spec_num[$k+0]  # sodium
  AERO_$spec_num[$k+1]=\"NAf_val + CHLf_val,ug/m3,ACLIJ + ANAIJ,,NaCl\";      export AERO_$spec_num[$k+1]  # sodium chloride
  AERO_$spec_num[$k+2]=\"FEf_val,ug/m3, AFEJ,,Fe\";                           export AERO_$spec_num[$k+2]  # iron
  AERO_$spec_num[$k+3]=\"ALf_val,ug/m3,AALJ,,Al\";                            export AERO_$spec_num[$k+3]  # aluminum 
  AERO_$spec_num[$k+4]=\"SIf_val,ug/m3, ASIJ,,Si\";                           export AERO_$spec_num[$k+4]  # silicon
  AERO_$spec_num[$k+5]=\"TIf_val,ug/m3, ATIJ,,Ti\";                           export AERO_$spec_num[$k+5]  # titanium
  AERO_$spec_num[$k+6]=\"CAf_val,ug/m3,ACAJ,,Ca\";                            export AERO_$spec_num[$k+6]  # calcium
  AERO_$spec_num[$k+7]=\"MGf_val,ug/m3,AMGJ,,Mg\";                            export AERO_$spec_num[$k+7]  # magnesium
  AERO_$spec_num[$k+8]=\"Kf_val,ug/m3,AKJ,,K\";                               export AERO_$spec_num[$k+8]  # potassium
  AERO_$spec_num[$k+9]=\"MNf_val,ug/m3,AMNJ,,Mn\";                            export AERO_$spec_num[$k+9]  # manganese
  AERO_$spec_num[$k+10]=\"2.20*ALf_val+2.49*SIf_val+1.63*CAf_val+2.42*FEf_val+1.94*TIf_val,ug/m3,ASOILJ,,soil\";       export AERO_$spec_num[$k+10]  # IMPROVE soil eqn.
";

################################
### End IMPROVE Species List ###
################################


##############################
### Start CSN Species List ###
##############################

$k=8;
$species_CSN = "
  AERO_1=\"m_so4,ug/m3, ASO4IJ,,SO4\";                           export AERO_1   # sulfate
  AERO_2=\"m_no3,ug/m3, ANO3IJ,,NO3\";                           export AERO_2   # nitrate
  AERO_3=\"m_nh4,ug/m3, ANH4IJ,,NH4\";                           export AERO_3   # ammonium
  AERO_4=\"FRM PM2.5 Mass,ug/m3,PMIJ,,PM_TOT\";                  export AERO_4   # PM2.5
  AERO_5=\"FRM PM2.5 Mass,ug/m3,PMIJ_FRM,,PM_FRM\";              export AERO_5   # FRM Equivalent PM2.5
  AERO_6=\"oc_adj,ug/m3, AOCIJ,,OC\";                            export AERO_6   # Organic Carbon
  AERO_7=\"ec_niosh,ug/m3, AECIJ,,EC\";                          export AERO_7   # Elemental Carbon
  AERO_8=\"oc_adj+ec_niosh,ug/m3,AOCIJ+AECIJ,,TC\";              export AERO_8   # Total Carbon
";
$species_cutoff_CSN = "
## PM2.5 Sharp Cutoff Species
## Requires preprocessing using AERODIAM file
  AERO_9=\"m_so4,ug/m3, PM25_SO4,,PM25_SO4\";                    export AERO_9   # sulfate (sharp cutoff)
  AERO_10=\"m_no3,ug/m3, PM25_NO3,,PM25_NO3\";                   export AERO_10  # nitrate (sharp cutoff)
  AERO_11=\"m_nh4,ug/m3, PM25_NH4,,PM25_NH4\";                   export AERO_11  # ammonium (sharp cutoff)
  AERO_12=\"oc_adj,ug/m3, PM25_OC,,PM25_OC\";                    export AERO_12  # Organic Carbon (sharp cutoff)
  AERO_13=\"ec_niosh,ug/m3, PM25_EC,,PM25_EC\";                  export AERO_13  # Elemental Carbon (sharp cutoff)
  AERO_14=\"oc_adj+ec_niosh,ug/m3,PM25_OC+PM25_EC,,PM25_TC\";    export AERO_14  # Total Carbon (sharp cutoff)
  AERO_15=\"FRM PM2.5 Mass,ug/m3,PM25_TOT,ug/m3,PM25_TOT\";      export AERO_15  # Total PM2.5 (sharp cutoff)
  AERO_16=\"FRM PM2.5 Mass,ug/m3,PM25_FRM,ug/m3,PM25_FRM\";      export AERO_16  # FRM Equivalent PM2.5 (sharp cutoff)
";
if (($cutoff eq "y") || ($cutoff eq "Y") || ($cutoff eq "t") || ($cutoff eq "T")) { $k=16; }
$species_AE6_CSN = "
# AERO6 species
## note we use Sodium Ion instead of sodium (XRF) becasue XRF is not reliable for sodium
## all other elemental concentrations (including Cl and K) come from XRF
   AERO_$spec_num[$k+0]=\"Sodium Ion,ug/m3, ANAIJ,,Na\";        export AERO_$spec_num[$k+0]   # sodium
   AERO_$spec_num[$k+1]=\"chlorine,ug/m3, ACLIJ,,Cl\";          export AERO_$spec_num[$k+1]   # chlorine
   AERO_$spec_num[$k+2]=\"iron,ug/m3, AFEJ,,Fe\";               export AERO_$spec_num[$k+2]   # iron
   AERO_$spec_num[$k+3]=\"aluminum,ug/m3,AALJ,,Al\";            export AERO_$spec_num[$k+3]   # aluminum 
   AERO_$spec_num[$k+4]=\"silicon,ug/m3, ASIJ,,Si\";            export AERO_$spec_num[$k+4]   # silicon
   AERO_$spec_num[$k+5]=\"titanium,ug/m3, ATIJ,,Ti\";           export AERO_$spec_num[$k+5]   # titanium
   AERO_$spec_num[$k+6]=\"calcium,ug/m3,ACAJ,,Ca\";             export AERO_$spec_num[$k+6]   # calcium
   AERO_$spec_num[$k+7]=\"magnesium,ug/m3,AMGJ,,Mg\";           export AERO_$spec_num[$k+7]   # magnesium
   AERO_$spec_num[$k+8]=\"potassium,ug/m3,AKJ,,K\";             export AERO_$spec_num[$k+8]   # potassium
   AERO_$spec_num[$k+9]=\"manganese,ug/m3,AMNJ,,Mn\";           export AERO_$spec_num[$k+9]   # manganese
   AERO_$spec_num[$k+10]=\"2.2*aluminum+2.49*silicon+1.63*calcium+2.42*iron+1.94*titanium,ug/m3,ASOILJ,,soil\"; export AERO_$spec_num[$k+10]   # SOIL_OLD
   AERO_$spec_num[$k+11]=\"Sodium Ion + chlorine, ug/m3, ANAIJ+ACLIJ,,NaCl\";                                   export AERO_$spec_num[$k+11]   # NaCl
   AERO_$spec_num[$k+12]=\"FRM PM2.5 Mass - m_so4 - m_no3 - m_nh4 - oc_adj - ec_niosh - [Sodium Ion] - [chlorine] - 2.2*aluminum - 2.49*silicon - 1.63*calcium - 2.42*iron - 1.94*titanium , ug/m3, AUNSPEC1IJ,,OTHER\";        export AERO_$spec_num[$k+12]   # PM Other
   AERO_$spec_num[$k+13]=\",ug/m3,ANCOMIJ,,NCOM\";    export AERO_$spec_num[$k+13]   # NCOM
   AERO_$spec_num[$k+14]=\",ug/m3,AUNSPEC2IJ,,OTHER_REM\";    export AERO_$spec_num[$k+14]   # PM Other Remainder
";

############################
### End CSN Species List ###
############################


#########################################
### Start CASTNET Weekly Species List ###
#########################################

# AEROSOL Variables (1-10)  - compute average over time

$species_CASTNET = "
# GAS Variables (1-10)  - compute average over time
# Model output was originally in ppm, but conversions were already
# made in the combine extract to convert to ug/m3.

  GAS_1=\"nhno3,ug/m3,HNO3_UGM3,,HNO3\";                 export GAS_1 # nitric acid
  GAS_2=\"total_so2,ug/m3,SO2_UGM3,,SO2\";               export GAS_2 # sulfur dioxide (total SO2 = Whatman Filter + 0.667*Nylon Filter)

# AEROSOL Variables  - compute average over time

  AERO_1=\"tso4,ug/m3,ASO4IJ,ug/m3,SO4\";                       	export AERO_1   # sulfate
  AERO_2=\"tno3,ug/m3,ANO3IJ,ug/m3,NO3\";                        	export AERO_2   # nitrate
  AERO_3=\"tnh4,ug/m3,ANH4IJ,ug/m3,NH4\";                     		export AERO_3   # ammonium
  AERO_4=\"tno3+nhno3,ug/m3,ANO3IJ+HNO3_UGM3,ug/m3,TNO3\";    	  	export AERO_4   # total nitrate
";
$species_cutoff_CASTNET = "
## PM2.5 Sharp Cutoff Species
## Requires preprocessing using AERODIAM file
  AERO_5=\"tso4,ug/m3,PM25_SO4,ug/m3,PM25_SO4\";                        export AERO_5   # sulfate using sharp cutoff
  AERO_6=\"tno3,ug/m3,PM25_NO3,ug/m3,PM25_NO3\";                        export AERO_6   # nitrate using sharp cutoff
  AERO_7=\"tnh4,ug/m3,PM25_NH4,ug/m3,PM25_NH4\";                        export AERO_7   # ammonium using sharp cutoff
  AERO_8=\"tno3+nhno3,ug/m3,PM25_NO3+HNO3_UGM3,ug/m3,PM25_TNO3\";       export AERO_8   # total nitrate using sharp cutoff
";
$species_AE6_CASTNET = "";

#######################################
### End CASTNET Weekly Species List ###
#######################################


#########################################
### Start CASTNET Hourly Species List ###
#########################################

$species_CASTNET_Hourly = "
  GAS_1=\"ozone,ppb,O3,ppb,O3\";				 export GAS_1 # ozone
  GAS_2=\"temperature,C,SFC_TMP,C,SFC_TMP\";			 export GAS_2 # 2 meter temperature
  GAS_3=\"relative_humidity,%,RH,%,RH\";			 export GAS_3 # Relative Humidity
  GAS_4=\"solar_radiation,watts/m2,SOL_RAD,watts/m2,Solar_Rad\"; export GAS_4 # Solar Radiation
  GAS_5=\"precipitation,mm/hr,precip,mm/hr,precip\";		 export GAS_5 # Precipitation
  GAS_6=\"windspeed,m/s,WSPD10,m/s,WSPD10\";			 export GAS_6 # Wind Speed
  GAS_7=\"wind_direction,deg,WDIR10,deg,WDIR10\";		 export GAS_7 # Wind Direction
";
$species_cutoff_CASTNET_Hourly ="";
$species_cutoff_CASTNET_Hourly = "";

#######################################
### End CASTNET Hourly Species List ###
#######################################

########################################
### Start CASTNET Daily Species List ###
########################################

$species_CASTNET_Daily = "
## flag to indicate to compute maximun hourly daily values
## else output hourly values

  COMPUTE_MAX=Y; export COMPUTE_MAX

## adjust for daylight savings 
  APPLY_DLS=N; export APPLY_DLS

## define ozone species 
  OZONE=\"O3,ppb\";     export OZONE    # Assume model ozone is in ppb (if not, this should be specified so that conversion can take place)
  OBS_FACTOR=\"$gas_convert\";  export OBS_FACTOR       # Multiply by 1000 to convert ppm to ppb
";
$species_cutoff_CASTNET_Daily = "";
$species_AE6_CASTNET_Daily = "";

######################################
### End CASTNET Daily Species List ###
######################################


#########################################
### Start CASTNET Drydep Species List ###
#########################################

$species_CASTNET_Drydep = "
  PREC_1=\"OZONE_FLUX,kg/ha,DDEP_O3,,O3_ddep\";                  export PREC_1   # sulfate
  PREC_2=\"SO2_FLUX,kg/ha,DDEP_SO2,,SO2_ddep\";                  export PREC_2   # nitrate
  PREC_3=\"HNO3_FLUX,kg/ha,DDEP_HNO3,,HNO3_ddep\";               export PREC_3   # ammonium
  PREC_4=\"HNO3_FLUX+NO3_FLUX,kg/ha,DDEP_TNO3,,TNO3_ddep\";      export PREC_4   # ammonium
  PREC_5=\"SO4_FLUX,kg/ha,DDEP_ASO4IJ,,SO4_ddep\";                export PREC_5   # fine sulfate
  PREC_6=\"NO3_FLUX,kg/ha,DDEP_ANO3IJ,,NO3_ddep\";                export PREC_6   # fine nitrate
  PREC_7=\"NH4_FLUX,kg/ha,DDEP_NHX,,NH4_ddep\";                  export PREC_7   # total NHX
";
$species_cutoff_CASTNET_Drydep ="";
$species_cutoff_CASTNET_Drydep = "";

#######################################
### End CASTNET Drydep Species List ###
#######################################


###############################
### Start NADP Species List ###
###############################

$species_NADP = "
  CHAR_1=\"Valcode\";       export CHAR_1
  CHAR_2=\"Invalcode\";     export CHAR_2

# Wet Concentration Variables (1-10) - compute volume-weighted average (VWAVG) in mg/l
# Observed values are already volume-weighted averages for the collection
# period.  Original model output is hourly wet deposition. To calculate
# VWAVG, the modeled wet deposition is accumulated for the collection time
# period, divided by the total precipitation (mm), and * 100. Resultingi
# units are mg/l.

  WETCON_1=\"NH4,mg/l,WDEP_NHX,mg/l,NH4_conc\"; export WETCON_1
  WETCON_2=\"NO3,mg/l,WDEP_TNO3,mg/l,NO3_conc\"; export WETCON_2
  WETCON_3=\"SO4,mg/l,WDEP_TSO4,mg/l,SO4_conc\"; export WETCON_3
  WETCON_4=\"Cl,mg/l,WDEP_TCL,mg/l,Cl_conc\"; export WETCON_4

# Wet Deposition Variables (1-10) - compute accumulated wet deposition in kg/ha
# Observed values are volume-weighted average wet concentrations for thei
# collection period (mg/l). To convert to wet deposition, multiply the wet
# concentration values by the total observed precip (Sub Ppt in mm), and then
# divide by 100. Original model output is hourly wet deposition. The modeled
# wet deposition is accumulated for the collection time period.

  WETDEP_1=\"NH4,kg/ha,WDEP_NHX,kg/ha,NH4_dep\"; export WETDEP_1    # Ammonium wet deposition
  WETDEP_2=\"NO3,kg/ha,WDEP_TNO3,kg/ha,NO3_dep\"; export WETDEP_2   # Nitrate wet deposition
  WETDEP_3=\"SO4,kg/ha,WDEP_TSO4,kg/ha,SO4_dep\"; export WETDEP_3  # Sulfate wet deposition 
  WETDEP_4=\"Cl,kg/ha,WDEP_TCL,kg/ha,Cl_dep\"; export WETDEP_4  # Sulfate wet deposition 

# Precipitation Variables (1-10) - compute accumulated precipitation

  PREC_1=\"Sub Ppt,mm,$precip_convert*RT,mm,Precip\"; export PREC_1
";
$species_cutoff_NADP = "";
$species_AE6_NADP = "

# AERO6 species
  WETCON_5=\"Ca,mg/l,WDEP_CAJ,mg/l,CA_conc\"; export WETCON_5
  WETCON_6=\"Mg,mg/l,WDEP_MGJ,mg/l,MG_conc\"; export WETCON_6
  WETCON_7=\"K,mg/l,WDEP_KJ,mg/l,K_conc\"; export WETCON_7

  WETDEP_5=\"Ca,kg/ha,WDEP_CAJ,kg/ha,CA_dep\"; export WETDEP_5
  WETDEP_6=\"Mg,kg/ha,WDEP_MGJ,kg/ha,MG_dep\"; export WETDEP_6
  WETDEP_7=\"K,kg/ha,WDEP_KJ,kg/ha,K_dep\"; export WETDEP_7
";

#############################
### End NADP Species List ###
#############################


####################################
### Start AQS Daily Species List ###
####################################

$species_AQS_Daily_O3 = "
## flag to indicate to compute maximun hourly daily values
## else output hourly values

  COMPUTE_MAX=Y; export COMPUTE_MAX

## adjust for daylight savings 
  APPLY_DLS=N; export APPLY_DLS

## define ozone species 
  OZONE=\"O3,ppb\";	export OZONE	# Assume model ozone is in ppb (if not, this should be specified so that conversion can take place)
  OBS_FACTOR=\"$gas_convert\";	export OBS_FACTOR	# Multiply by 1000 to convert ppm to ppb
";
$species_cutoff_AQS_Daily_O3 = "";
$species_AE6_AQS_Daily_O3 = "";

##################################
### End AQS Daily Species List ###
##################################


#####################################
### Start AQS Hourly Species List ###
#####################################

$species_AQS_Hourly = "
  GAS_1=\"O3,ppb,O3,ppb,O3\";             export GAS_1 # O3
  GAS_2=\"NOY,ppb,NOY,ppb,NOY\";          export GAS_2 # NOY
  GAS_3=\"NO,ppb,NO,ppb,NO\";             export GAS_3 # NO
  GAS_4=\"NO2,ppb,NO2,ppb,NO2\";          export GAS_4 # NO2
  GAS_5=\"NOX,ppb,NO+NO2,ppb,NOX\";       export GAS_5 # NOX
  GAS_6=\"CO,ppb,CO,ppb,CO\";             export GAS_6 # CO
  GAS_7=\"SO2,ppb,SO2,ppb,SO2\";          export GAS_7 # SO2
  GAS_8=\"PM25,ug/m3,PMIJ,ug/m3,PM_TOT\"; export GAS_8 # PM25
";
$species_cutoff_AQS_Hourly = "";
$species_AE6_AQS_Hourly = "";

###################################
### End AQS Hourly Species List ###
###################################


#######################################
### Start AQS_Daily_PM Species List ###
#######################################

$species_AQS_Daily_PM = "
  AERO_1=\"PM25,ug/m3,PMIJ,ug/m3,PM_TOT\";		export AERO_1   # PM2.5 Total Mass
  AERO_2=\"PM25,ug/m3,PMIJ_FRM,ug/m3,PM_FRM\";		export AERO_2   # PM2.5 Total Mass (I+J with FRM adjustment)
  AERO_3=\"PM10,ug/m3,PM10,ug/m3,PM10\";		export AERO_3   # PM10 Total Mass
";
$species_cutoff_AQS_Daily_PM = "
## PM2.5 Sharp Cutoff Species
## Requires preprocessing using AERODIAM file
  AERO_3=\"PM25,ug/m3,PM25_TOT,ug/m3,PM25_TOT\";	export AERO_4   # PM2.5 Total Mass with sharp cutoff
  AERO_4=\"PM25,ug/m3,PM25_FRM,,PM25_FRM\";		export AERO_5   # PM2.5 Total Mass (cutoff with FRM adjustment)
";
$species_AE6_AQS_Daily_PM = "";

################################
### End AQS FRM Species List ###
################################

########################################
### Start SEARCH Hourly Species List ###
########################################

$species_SEARCH_Hourly = "
   AERO_1=\"o3,ppb,O3,,O3\";			export AERO_1
   AERO_2=\"co,ppb,CO,,CO\";			export AERO_2
   AERO_3=\"so2,ppb,SO2,,SO2\";			export AERO_3
   AERO_4=\"no,ppb,NO,,NO\";			export AERO_4
   AERO_5=\"no2,ppb,NO2,,NO2\";			export AERO_5
   AERO_6=\"noy,ppb,NOY,ppb,NOY\";     	 	export AERO_6
#   AERO_7=\"ec,ug/m3,AECIJ,ug/m3,EC\";		export AERO_7
#   AERO_8=\"oc,ug/m3,AOCIJ,ug/m3,OC\";		export AERO_8
#   AERO_9=\"tc,ug/m3,AECIJ+AOCIJ,ug/m3,TC\";	export AERO_9
#   AERO_10=\"teom,ug/m3,PMIJ,,PM_TOT\";	export AERO_10
";
$species_cutoff_SEARCH_Hourly = "
#   AERO_10=\"ec,ug/m3,PM25_EC,ug/m3,PM25_EC\";		export AERO_10
#   AERO_11=\"oc,ug/m3,PM25_OC,ug/m3,PM25_OC\";		export AERO_11
#   AERO_12=\"tc,ug/m3,PM25_EC+PM25_OC,ug/m3,PM25_TC\";	export AERO_12
#   AERO_14=\"nh4,ug/m3,PM25_NH4,,PM25_NH4\";		export AERO_14
";
$species_AE6_SEARCH_Hourly = "";

######################################
### End SEARCH Hourly Species List ###
######################################

#######################################
### Start SEARCH Daily Species List ###
#######################################

$species_SEARCH_Daily = "
   AERO_1=\"pcm1 so4,ug/m3,ASO4IJ,ug/m3,SO4\";                            export AERO_1
   AERO_2=\"pcm1 no3+pcm1 teflon no3,ug/m3,ANO3IJ,ug/m3,NO3\";            export AERO_2
   AERO_3=\"pcm1 teflon nh4+pcm1 vol nh4,ug/m3,ANH4IJ,ug/m3,NH4\";        export AERO_3
   AERO_4=\"pcm3 ec,ug/m3,AECIJ,ug/m3,EC\";                               export AERO_4
   AERO_5=\"pcm3 oc,ug/m3,AOCIJ,ug/m3,OC\";                               export AERO_5
   AERO_6=\"pcm1 mass,ug/m3,PMIJ,ug/m3,PM_TOT\";                          export AERO_6
";
$species_cutoff_SEARCH_Daily = "";
$species_AE6_SEARCH_Daily = "";

#####################################
### End SEARCH Daily Species List ###
#####################################

#################################################
### Start NAPS (Canadian) Hourly Species List ###
#################################################

$species_NAPS = "
   AERO_1=\"O3,ppb,O3,ppb,O3\";				export AERO_1
   AERO_2=\"TEOMPM25,ug/m3,PMIJ,ug/m3,PM_TOT\";		export AERO_2
   AERO_3=\"TEOMPM10,ug/m3,PM10,ug/m3,PM10\";		export AERO_3
   AERO_4=\"CO,ppb,CO,ppb,CO\";				export AERO_4
   AERO_5=\"NO,ppb,NO,ppb,NO\";                         export AERO_5
   AERO_6=\"NO2,ppb,NO2,ppb,NO2\";                      export AERO_6
   AERO_7=\"NOX,ppb,NO+NO2,ppb,NOX\";                      export AERO_7
   AERO_8=\"SO2,ppb,SO2,ppb,SO2\";                      export AERO_8
";
$species_cutoff_NAPS = "";
$species_AE6_NAPS = "";

####################################
### End NAPS Hourly Species List ###
####################################

###########################################
### Start AIRBASE (Europe) Species List ###
###########################################

$species_AIRBASE = "

# AEROSOL Variables  - compute average over time
AERO_1=\"PM10,ug/m3,PM10,ug/m3,PM10\"; export AERO_1 # PM10
AERO_2=\"PM25,ug/m3,PM25,ug/m3,PM25\"; export AERO_2 # PM25

# GAS Variables  - compute average over time
GAS_1=\"CO,ppb,CO,ppb,CO\"; export GAS_1 # CO
GAS_2=\"SO2,ppb,SO2,ppb,SO2\"; export GAS_2 # SO2
GAS_3=\"O3,ppb,O3,ppb,O3\"; export GAS_3 # O3
GAS_4=\"NO,ppb,NO,ppb,NO\"; export GAS_4 # NO
GAS_5=\"NO2,ppb,NO2,ppb,NO2\"; export GAS_5 # NO2
GAS_6=\"NOX,ppb,NO+NO2,ppb,NOX\"; export GAS_6 # NOX
";
$species_cutoff_AIRBASE = "";
$species_AE6_AIRBASE = "";

################################
### End AIRBASE Species List ###
################################

########################################
### Start AURN (Europe) Species List ###
########################################

$species_AURN = "
# AEROSOL Variables - compute average over time
AERO_1=\"0.77649*NHX,ugN/m3,NHX,ugN/m3,NHX\"; export AERO_1 # NHX
AERO_2=\"0.22590*NOY,ugN/m3,NOY,ugN/m3,NOY\"; export AERO_2 # NOY
AERO_3=\"0.33379*SOX,ugS/m3,SOX,ugS/m3,SOX\"; export AERO_3 # SOX
AERO_4=\"PM10,ug/m3,PM10,ug/m3,PM10\"; export AERO_4 # PM10
AERO_5=\"PM25,ug/m3,PM25,ug/m3,PM25\"; export AERO_5 # PM25

# GAS Variables - compute average over time
GAS_1=\"862.07*CO,ppb,CO,ppb,CO\"; export GAS_1 # CO
GAS_2=\"0.38162*SO2,ppb,SO2,ppb,SO2\"; export GAS_2 # SO2
GAS_3=\"0.50000*O3,ppb,O3,ppb,O3\"; export GAS_3 # O3
GAS_4=\"0.81486*NO,ppb,NO,ppb,NO\"; export GAS_4 # NO
GAS_5=\"0.53146*NO2,ppb,NO2,ppb,NO2\"; export GAS_5 # NO2
";
$species_cutoff_AURN = "";
$species_AE6_AURN = "";

#############################
### End AURN Species List ###
#############################

########################################
### Start EMEP (Europe) Species List ###
########################################

$species_EMEP = "
# AEROSOL Variables - compute average over time
AERO_1=\"NHX,ugN/m3,NHX,ugN/m3,NHX\"; export AERO_1 # NHX
AERO_2=\"NOY,ugN/m3,NOY,ugN/m3,NOY\"; export AERO_2 # NOY
AERO_3=\"SOX,ugS/m3,SOX,ugS/m3,SOX\"; export AERO_3 # SOX
AERO_4=\"PM10,ug/m3,PM10,ug/m3,PM10\"; export AERO_4 # PM10
AERO_5=\"PM25,ug/m3,PM25,ug/m3,PM25\"; export AERO_5 # PM25

# GAS Variables - compute average over time
GAS_1=\"CO,ppb,CO,ppb,CO\"; export GAS_1 # CO
GAS_2=\"SO2,ppb,SO2,ppb,SO2\"; export GAS_2 # SO2
GAS_3=\"O3,ppb,O3,ppb,O3\"; export GAS_3 # O3
GAS_4=\"NO,ppb,NO,ppb,NO\"; export GAS_4 # NO
GAS_5=\"NO2,ppb,NO2,ppb,NO2\"; export GAS_5 # NO2
";
$species_cutoff_EMEP = "";
$species_AE6_EMEP = "";

#############################
### End EMEP Species List ###
#############################

##########################################
### Start AGANET (Europe) Species List ###
##########################################

$species_AGANET = "
# AEROSOL Variables - compute average over time
AERO_1=\"0.22590*NOY,ugN/m3,NOY,ugN/m3,NOY\"; export AERO_1 # NOY
AERO_2=\"0.33379*SOX,ugS/m3,SOX,ugS/m3,SOX\"; export AERO_2 # SOX
AERO_3=\"NA,ug/m3,PM_NA,ug/m3,NA\"; export AERO_3 # NA
AERO_4=\"CL,ug/m3,PM_CL,ug/m3,CL\"; export AERO_4 # CL

# GAS Variables - compute average over time
GAS_1=\"0.38803*HNO3,ppb,HNO3,ppb,HNO3\"; export GAS_1 # HNO3
GAS_2=\"0.38162*SO2,ppb,SO2,ppb,SO2\"; export GAS_2 # SO2
GAS_3=\"0.92404*HCL,ppb,HCL,ppb,HCL\"; export GAS_3 # HCL
GAS_4=\"0.53146*NO2,ppb,NO2,ppb,NO2\"; export GAS_4 # NO2
";
$species_cutoff_AGANET = "";
$species_AE6_AGANET = "";

###############################
### End AGANET Species List ###
###############################

########################################
### Start ADMN (Europe) Species List ###
########################################

$species_ADMN = "
# Wet Concentration Variables (1-10) - compute volume-weighted average (VWAVG) in mg/l
# Observed values are already volume-weighted averages for the collection
# period.  Original model output is hourly wet deposition. To calculate
# VWAVG, the modeled wet deposition is accumulated for the collection time
# period, divided by the total precipitation (mm), and * 100. Resultingi
# units are mg/l.

WETCON_1=\"0.016*SOX_conc,mgS/l,WETDEP_SOX,mgS/l,SOX_conc\"; export WETCON_1               # Sulfate wet concentration
WETCON_2=\"0.014*NOY_conc,mgN/l,WETDEP_NOY,mgN/l,NOY_conc\"; export WETCON_2               # Nitrate wet concentration
WETCON_3=\"0.014*NHX_conc,mgN/l,WETDEP_NHX,mgN/l,NHX_conc\"; export WETCON_3               # Ammonium wet concentration
WETCON_4=\"0.001*NA_conc,mg/l,WETDEP_PM_NA,mg/l,NA_conc\"; export WETCON_4                # Na wet concentration
WETCON_5=\"0.001*CL_conc,mg/l,WETDEP_PM_CL,mg/l,CL_conc\"; export WETCON_5                # Cl wet concentration
WETCON_6=\"0.016*NSS_SOX_conc,mgS/l,WETDEP_NSS_SOX,mgS/l,NSS_SOX_conc\"; export WETCON_6  # Nss sulfate wet concentration

# Wet Deposition Variables (1-10) - compute accumulated wet deposition in kg/ha
# Observed values are volume-weighted average wet concentrations for thei
# collection period (mg/l). To convert to wet deposition, multiply the wet
# concentration values by the total observed precip (Sub Ppt in mm), and then
# divide by 100. Original model output is hourly wet deposition. The modeled
# wet deposition is accumulated for the collection time period.

WETDEP_1=\"0.016*SOX_conc,kgS/ha,WETDEP_SOX,kgS/ha,SOX_dep\"; export WETDEP_1              # Sulfate wet deposition
WETDEP_2=\"0.014*NOY_conc,kgN/ha,WETDEP_NOY,kgN/ha,NOY_dep\"; export WETDEP_2               # Nitrate wet deposition
WETDEP_3=\"0.014*NHX_conc,kgN/ha,WETDEP_NHX,kgN/ha,NHX_dep\"; export WETDEP_3               # Ammonium wet deposition
WETDEP_4=\"0.001*NA_conc,kg/ha,WETDEP_PM_NA,kg/ha,NA_dep\"; export WETDEP_4                # Na wet deposition
WETDEP_5=\"0.001*CL_conc,kg/ha,WETDEP_PM_CL,kg/ha,CL_dep\"; export WETDEP_5                # Cl wet deposition
WETDEP_6=\"0.016*NSS_SOX_conc,kgS/ha,WETDEP_NSS_SOX,kgS/ha,NSS_SOX_dep\"; export WETDEP_6  # Nss sulfate wet deposition


# Precipitation Variables (1-10) - compute accumulated precipitation

   PREC_1=\"Sub Ppt,mm,RT,mm,Precip\"; export PREC_1
#   PREC_1=\"Sub Ppt,mm,RT*10.,mm,Precip\"; export PREC_1
";
$species_cutoff_ADMN = "";
$species_AE6_ADMN = "";

#############################
### End ADMN Species List ###
#############################

########################################
### Start NAMN (Europe) Species List ###
########################################

$species_NAMN = "
# AEROSOL Variables (1-10)  - compute average over time
AERO_1=\"0.77649*NHX,ugN/m3,NHX,ugN/m3,NHX\"; export AERO_1 # NHX

# GAS Variables - compute average over time
GAS_1=\"1.43554*NH3,ppb,NH3,ppb,NH3\"; export GAS_1 # NH3
";
$species_cutoff_NAMN = "";
$species_AE6_NAMN = "";

#############################
### End NAMN Species List ###
#############################

1;	# Required for some reason to get file to load correctly
