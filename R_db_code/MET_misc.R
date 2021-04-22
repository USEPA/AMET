#######################################################################################################
#####################################################################################################
#                                                                 ################################
#     AMET Miscellaneous Functions Library                        ###############################
#                                                                 ###############################
#	Developed by the US Environmental Protection Agency       ###############################
#                                                                 ################################
#####################################################################################################
#######################################################################################################
#
#  V1.3, 2017Apr18, Robert Gilliam: Initial Development
#  V1.4, 2018Sep30, Robert Gilliam: 
#         - No updates
#  V1.5, 2020Feb05, Robert Gilliam: Added a function to check if variable exist in NetCDF file
#
#######################################################################################################
#######################################################################################################
#     This script contains the following functions
#
#     ncdf_vars_exist   --> Reads variables in NetCDF file and returns logical if var exists or not.
#     test              --> this is a generic function dummy function to copy and paste for new functs.
#
#######################################################################################################
#######################################################################################################
##########################################################################################################
#####---------------------   START OF NCDF_VARS_EXIST FUNCTION      ----------------------------------####
#  Open MPAS output and extract grid information and surface met data for comparision to MADIS obs
#
# Input:
#       file   -- Model output file name. Full path and file name
#       varid  -- Variable to search in file
#
# Output: Logial -- does the variable exist or not in file
#
 ncdf_vars_exist <- function(file, varid="swdnb") {

  f1  <-nc_open(file)

   nvars    <- length(f1$var[])
   varexists<- F
   for(n in 1:nvars){
     #writeLines(paste("variable ID",n,"of",nvars,":",f1$var[[n]]$name))
     if( varid == f1$var[[n]]$name) {
       varexists<-T
     }
   }
  nc_close(f1)

  return(varexists)

 }
#####------------------    END OF NCDF_VARS_EXIST FUNCTION     ---------------------------------------####
##########################################################################################################

##########################################################################################################
#####--------------------------   START OF TEST FUNCTION          ------------------------------------####
#  Test function

 test <-function(file) {

  a<-c(1,1,1,1)
  b<-c(2,2,2,2)
  c<-c(3,3,3,3)
  
  
  return()

 }
#####-------------------------  END OF TEST FUNCTION     -------------------------------------------####
##########################################################################################################

