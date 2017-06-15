#######################################################################################################
#######################################################################################################
#		AMET Statistics Function Library
#						 	
# Version 1.2, Robert Gilliam, May 2, 2013
# Updates: Added header for better version control
#
#	Developed by the US Environmental Protection Agency 	
#
#-----------------------------------------------------------------------###############################
#######################################################################################################
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
        warning("Both arguments do not have the same length. Proceeding by truncating length of the longer to the length of the shorter")
    score <- mean(abs(comp[1:min.length] - base[1:min.length]), 
        na.rm = na.rm)
    return(score)
}
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################


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
        warning("Both arguments do not have the same length. Proceeding by truncating length of the longer to the length of the shorter")
    score <- mean(comp[1:min.length] - base[1:min.length], na.rm = na.rm)
    return(score)
}
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
mfbias <- function (base, comp, na.rm = FALSE) 
{
    if (!is.numeric(base) | !is.numeric(comp)) 
        stop("Both base and comp must be numeric")
    min.length <- min(length(base), length(comp))
    if (length(base) != length(comp)) 
        warning("Both arguments do not have the same length. Proceeding by truncating length of the longer to the length of the shorter")
    score <- mean(2 * (comp[1:min.length] - base[1:min.length])/(comp[1:min.length] + 
        base[1:min.length]), na.rm = na.rm) * 100
    return(score)
}
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
mnbias <- function (base, comp, na.rm = FALSE) 
{
    if (!is.numeric(base) | !is.numeric(comp)) 
        stop("Both base and comp must be numeric")
    min.length <- min(length(base), length(comp))
    if (length(base) != length(comp)) 
        warning("Both arguments do not have the same length. Proceeding by truncating length of the longer to the length of the shorter")
    score <- mean((comp[1:min.length] - base[1:min.length])/base[1:min.length], 
        na.rm = na.rm) * 100
    return(score)
}

##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
mngerror <- function (base, comp, na.rm = FALSE) 
{
    if (!is.numeric(base) | !is.numeric(comp)) 
        stop("Both base and comp must be numeric")
    min.length <- min(length(base), length(comp))
    if (length(base) != length(comp)) 
        warning("Both arguments do not have the same length. Proceeding by truncating length of the longer to the length of the shorter")
    score <- mean(abs(comp[1:min.length] - base[1:min.length])/base[1:min.length], 
        na.rm = na.rm) * 100
    return(score)
}
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
   nmbias <- function (base, comp, na.rm = FALSE) 
{
    if (!is.numeric(base) | !is.numeric(comp)) 
        stop("Both base and comp must be numeric")
    min.length <- min(length(base), length(comp))
    if (length(base) != length(comp)) 
        warning("Both arguments do not have the same length. Proceeding by truncating length of the longer to the length of the shorter")
    score <- sum(comp[1:min.length] - base[1:min.length], na.rm = na.rm)/sum(base[1:min.length], 
        na.rm = na.rm) * 100
    return(score)
}
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################

###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
 nmerror <- function (base, comp, na.rm = FALSE) 
{
    if (!is.numeric(base) | !is.numeric(comp)) 
        stop("Both base and comp must be numeric")
    min.length <- min(length(base), length(comp))
    if (length(base) != length(comp)) 
        warning("Both arguments do not have the same length. Proceeding by truncating length of the longer to the length of the shorter")
    score <- sum(abs(comp[1:min.length] - base[1:min.length]), 
        na.rm = na.rm)/sum(base, na.rm = na.rm) * 100
    return(score)
}
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################
 rmserror <- function (base, comp, na.rm = FALSE) 
{
    if (!is.numeric(base) | !is.numeric(comp)) 
        stop("Both base and comp must be numeric")
    min.length <- min(length(base), length(comp))
    if (length(base) != length(comp)) 
        warning("Both arguments do not have the same length. Proceeding by truncating length of the longer to the length of the shorter")
    score <- sqrt(mean((comp[1:min.length] - base[1:min.length])^2, 
        na.rm = na.rm))
    return(score)
}
##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################


###############################################################
#- - - - - - - - -   START OF FUNCTION  -  - - - - - - - - - ##
###############################################################

##############################################################################################################
#----------------------------------------  END OF FUNCTION  ------------------------------------------------##
##############################################################################################################
