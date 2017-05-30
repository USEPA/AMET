#!/bin/csh

######################################################
# Link Binary files to common location $AMETBASE/bin #
#                                                    #
# User will likely need to change some of the paths  #
######################################################


# Set AMETBASE
setenv AMETBASE ~/AMET

# Make sure we are in $AMETBASE/bin
cd $AMETBASE/bin

# Link Tier 2 software utilities

## Madis ##
ln -sf /usr/local/pkgs/madis/bin/* .
ln -sf /usr/local/pkgs/madis/static madis_static

## NetCDF ##
ln -sf /usr/bin/ncdump .

## wgrib
ln -sf /usr/local/bin/wgrib .

# Tier 3 software utilities

## cmp_airs
ln -sf $AMETBASE/src/cmp_airs/cmp_airs.exe .

## combine
ln -sf $AMETBASE/src/combine/combine.exe .

## sitecmp
ln -sf $AMETBASE/src/sitecmp/sitecmp.exe .

## bldoverlay
ln -sf $AMETBASE/src/bldoverlay/bldoverlay .
## mm5tonetcdf
ln -sf /usr/local/bin/examiner .
ln -sf /usr/local/bin/archiver .


