#########################################################################
#-----------------------------------------------------------------------#
#                                                                       #
#                AMET (Atmospheric Model Evaluation Tool)               #
#                                                                       #
#                   AMET Statistics Function Library	                  #
#                       MET_amet.stats-lib.R                            #
#                                                                       #
#         Developed by the US Environmental Protection Agency           #
#-----------------------------------------------------------------------#
#########################################################################
#
# Version 1.1, August 18, 2005, Robert Gilliam
#
# Version 1.4, Sep 30, 2018, Robert Gilliam
#  - Code cleansing. Removed tabs. Added list and description of functions
#  - Added function simple.stats for RAOB statistics
#
#-----------------------------------------------------------------------##################
##########################################################################################
##########################################################################################
#	This collection contains the following functions
#
#       magerror      --> mean absolute gross error/mean absolute error
#       mbias         --> mean bias
#       mfbias        --> mean fractional bias
#       mngerror      --> mean normalized gross error
#       nmbias        --> normalized mean bias
#       nmerror       --> normalized mean error
#       rmserror      --> root mean squared error
#       simple.stats  --> simple statistic array (rmse,mae,bias,corr)
#
###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
# Statistical functions copied from NOAA ARL ASMD's RMET package
magerror <- function (base, comp, na.rm = FALSE) 
{
    if (!is.numeric(base) | !is.numeric(comp)) 
        stop("Both base and comp must be numeric")
    min.length <- min(length(base), length(comp))
    if (length(base) != length(comp)) 
        warning(paste("Both arguments do not have the same length.Proceeding",
                "by truncating length of the longer to the length of the shorter"))
    score <- mean(abs(comp[1:min.length] - base[1:min.length]), 
        na.rm = na.rm)
    return(score)
}
##########################################################################################
#----------------------------------------  END OF FUNCTION  ----------------------------##
##########################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
# Statistical functions copied from NOAA ARL ASMD's RMET package
mbias <- function (base, comp, na.rm = FALSE) 
{
    if (!is.numeric(base) | !is.numeric(comp)) 
        stop("Both base and comp must be numeric")
    min.length <- min(length(base), length(comp))
    if (length(base) != length(comp)) 
        warning(paste("Both arguments do not have the same length.Proceeding 
                by truncating length of the longer to the length of the shorter"))
    score <- mean(comp[1:min.length] - base[1:min.length], na.rm = na.rm)
    return(score)
}
##########################################################################################
#----------------------------------------  END OF FUNCTION  ----------------------------##
##########################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
mfbias <- function (base, comp, na.rm = FALSE) 
{
    if (!is.numeric(base) | !is.numeric(comp)) 
        stop("Both base and comp must be numeric")
    min.length <- min(length(base), length(comp))
    if (length(base) != length(comp)) 
        warning(paste("Both arguments do not have the same length.Proceeding",
                "by truncating length of the longer to the length of the shorter"))
    score <- mean(2 * (comp[1:min.length] - base[1:min.length])/
                 (comp[1:min.length] + base[1:min.length]), na.rm = na.rm) * 100
    return(score)
}
##########################################################################################
#----------------------------------------  END OF FUNCTION  ----------------------------##
##########################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
mnbias <- function (base, comp, na.rm = FALSE) 
{
    if (!is.numeric(base) | !is.numeric(comp)) 
        stop("Both base and comp must be numeric")
    min.length <- min(length(base), length(comp))
    if (length(base) != length(comp)) 
        warning(paste("Both arguments do not have the same length.Proceeding",
                "by truncating length of the longer to the length of the shorter"))
    score <- mean((comp[1:min.length] - base[1:min.length])/
                  base[1:min.length], na.rm = na.rm) * 100
    return(score)
}
##########################################################################################
#----------------------------------------  END OF FUNCTION  ----------------------------##
##########################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
mngerror <- function (base, comp, na.rm = FALSE) 
{
    if (!is.numeric(base) | !is.numeric(comp)) 
        stop("Both base and comp must be numeric")
    min.length <- min(length(base), length(comp))
    if (length(base) != length(comp)) 
        warning(paste("Both arguments do not have the same length.Proceeding",
                "by truncating length of the longer to the length of the shorter"))
    score <- mean(abs(comp[1:min.length] - base[1:min.length])/
                  base[1:min.length], na.rm = na.rm) * 100
    return(score)
}
##########################################################################################
#----------------------------------------  END OF FUNCTION  ----------------------------##
##########################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
   nmbias <- function (base, comp, na.rm = FALSE) 
{
    if (!is.numeric(base) | !is.numeric(comp)) 
        stop("Both base and comp must be numeric")
    min.length <- min(length(base), length(comp))
    if (length(base) != length(comp)) 
        warning(paste("Both arguments do not have the same length.Proceeding",
                "by truncating length of the longer to the length of the shorter"))
    score <- sum(comp[1:min.length] - base[1:min.length], na.rm = na.rm)/
                 sum(base[1:min.length], na.rm = na.rm) * 100
    return(score)
}
##########################################################################################
#----------------------------------------  END OF FUNCTION  ----------------------------##
##########################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
 nmerror <- function (base, comp, na.rm = FALSE) 
{
    if (!is.numeric(base) | !is.numeric(comp)) 
        stop("Both base and comp must be numeric")
    min.length <- min(length(base), length(comp))
    if (length(base) != length(comp)) 
        warning(paste("Both arguments do not have the same length.Proceeding",
                "by truncating length of the longer to the length of the shorter"))
    score <- sum(abs(comp[1:min.length] - base[1:min.length]), 
                 na.rm = na.rm)/sum(base, na.rm = na.rm) * 100
    return(score)
}
##########################################################################################
#----------------------------------------  END OF FUNCTION  ----------------------------##
##########################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
 rmserror <- function (base, comp, na.rm = FALSE) 
{
    if (!is.numeric(base) | !is.numeric(comp)) 
        stop("Both base and comp must be numeric")
    min.length <- min(length(base), length(comp))
    if (length(base) != length(comp)) 
        warning(paste("Both arguments do not have the same length.Proceeding",
                "by truncating length of the longer to the length of the shorter"))
    score <- sqrt(mean((comp[1:min.length] - base[1:min.length])^2, 
                  na.rm = na.rm))
    return(score)
}
##########################################################################################
#----------------------------------------  END OF FUNCTION  ----------------------------##
##########################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
# Simple statistics function for RAOB-MODEL comparisons
# This just returns rmse, mae, bias and anom. correlation array
# using AMET existing statistics functions in this function file 
  simple.stats <- function (obs, mod) {
     metric    <-array(NA,c(4))
     metric[1] <-rmserror(obs,mod,na.rm=T)
     metric[2] <-magerror(obs,mod,na.rm=T)
     metric[3] <-mbias(obs,mod,na.rm=T)
     metric[4] <-ac(obs,mod)
     metric[5] <-sum(ifelse(is.na(obs),0,1))
     return(metric)
}  
##########################################################################################
#----------------------------------------  END OF FUNCTION  ----------------------------##
##########################################################################################

