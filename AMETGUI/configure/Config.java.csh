#!/bin/csh -f


#############################################################
cat << End_Of_Config  > ${CONFIGURE}/Config.java

package ametjavagui;

public class Config {

    public String cache_amet =   "${AMETGUI_CACHE}";

    public String amet_base =    "${AMETBASE}";

    public String mysql_config = "${AMETBASE}/configure/amet-config.R";

    public String rScript =      "${R_EXE} --no-save <";

    public String amet_static =  "${AMETBASE}/scripts_analysis/metExample_wrf/input_files";

    public String dir_name =     "${AMETGUI_CACHE}/guidir.";

    public String rLibs =        "${R_LIBRARY}";

    public String pandoc =       "${PANDOC_EXE}";

    public String run_analysis = "${AMETBASE}/R_analysis_code/";

    public String keystore = "${KEYSTORE_JKS}";
    public String keystore_password = "${KEYSTORE_PASS}";

    public String conn = "jdbc:mariadb://${MYSQL_SERVER}:3306?&useSSL=true";
}

End_Of_Config
