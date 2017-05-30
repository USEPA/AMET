######################
### Template Files ###
######################

The files in this directory are template files that are updated by the perl and php scripts.  These files should not be altered, unless you know what you are doing. 

The files sitex_* are template script files for running the Site Compare software.  They are used by the perl script extract_all.pl, where they are updated with user specified inputs.  Any changes in the template files would most likely require changes to the extract_all.pl script, since various locations in the template files are hardcoded into the extract_all.pl script.
  
The file run_info.template is updated by the php script querygen_aq.php and is used by the various R scripts.  The template is updated with various user specified options for running the R scripts

The file amet_conf.template is updated by the php script matchsetup.php and is used by the perl script extract_all.pl to set all the user specified options, specifically which networks to extract and add data to the database for, what time periods to use and where the model input concentration or depostion files are located.

The files amet.dwt and AMET.dwt are template files used by the php scripts and should not be altered or moved. 
