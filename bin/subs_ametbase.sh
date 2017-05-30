#! /bin/csh -f

######################################################
# Change location of $AMETBASE variable to reflect the
#       location of your AMET installation           #
######################################################

setenv AMETBASE "\~/AMET"
setenv MYAMETBASE /path/to/AMET

foreach i ( `find $MYAMETBASE -iname "*.csh" ` )
	echo 'Updating AMETBASE in file ' $i
	sed -i 's:'$AMETBASE':'$MYAMETBASE':'  $i
end
