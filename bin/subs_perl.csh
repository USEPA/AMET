#! /bin/csh -f

######################################################
# Change location of base install for perl           #
# by resetting the MYPERLDIR variable below          #
######################################################

setenv AMETBASE ~/AMET

setenv PERLDIR /usr/bin/perl
setenv MYPERLDIR /path/to/perl

foreach i ( `find $MYAMETBASE -iname "*.pl" ` )

	echo 'Updating path to Perl in file ' $i
	sed -i 's:'$PERLDIR':'$MYPERLDIR':' $i
end
