/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ametjavagui;

/**
 *
 * @author MMORTO01
 */
public class Config {
//##############################################################################
//   Linux
//##############################################################################
//User inputed Variables that change depending on the environment
    
    //cache_amet: directory where run_info and outfput files will be stored
    public String cache_amet = "/work/MOD3DEV/AMET/AMETJavaGUI/cache";
    //amet_base: root direcroty of AMET software, should contain Run_analysis.R scripts folder
    public String amet_base = "/work/MOD3DEV/AMET";
    //mysql_config: config file for connecting to my SQL
    public String mysql_config = "/work/MOD3DEV/AMET/configure/amet-config.R";
    //rscript: links to rscript.exe
    public String rScript = "/usr/local/apps/R-3.4.4/intel-18.0/bin/R --no-save <";
    //ametstatic: static input file for scripts
    public String amet_static = "/work/MOD3DEV/AMET/scripts_analysis/metExample_wrf/input_files";
    //pid: temp folder for output
    public String dir_name = "/work/MOD3DEV/AMET/AMETJavaGUI/cache/guidir.";
    //rlibs: R library directory
    public String rLibs = "/usr/local/apps/R-3.4.4/intel-18.0/lib64/R/library";
    //pandoc: Links to pandoc binary file for plotly files
    public String pandoc = "/work/MOD3DEV/AMET/pandoc-2.13/bin/pandoc";
    
    //run_analysis: links to run_analysis
    public String run_analysis = "/work/MOD3DEV/AMET/R_analysis_code/";
    
//##############################################################################
//   Windows
//##############################################################################
    //User inputed Variables that change depending on the environment
    
    //Note: 4 backslashes are used because 1) java requires each backslash to be doubled and 2) R requires each backslash to be doubled, hence needed 1*2*2=4 backslashes
    
//    //cache_amet: directory where run_info and outfput files will be stored
//    public String cache_amet = "C:\\\\Users\\\\mmorto01\\\\OneDrive - Environmental Protection Agency (EPA)\\\\Profile\\\\Documents\\\\AMET_GUI\\\\cache";
//    //amet_base: root direcroty of AMET software, should contain Run_analysis.R scripts folder
//    public String amet_base = "C:\\\\Users\\\\mmorto01\\\\OneDrive - Environmental Protection Agency (EPA)\\\\Profile\\\\Documents\\\\AMET-master";
//    //mysql_config: config file for connecting to my SQL
//    public String mysql_config = "C:\\\\Users\\\\mmorto01\\\\OneDrive - Environmental Protection Agency (EPA)\\\\Profile\\\\Documents\\\\configure\\\\amet-config.R";
//    //rscript: links to rscript.exe
//    public String rScript = "C:\\\\Program Files\\\\R\\\\R-4.1.0\\\\bin\\\\rscript.exe";
//    //pandoc: Links to pandoc binary file for plotly files
//    public String pandoc = "C:\\\\Users\\\\mmorto01\\\\OneDrive - Environmental Protection Agency (EPA)\\\\Profile\\\\Documents\\\\pandoc-2.12";
//    
//    //run_analysis: links to run_analysis, must be single slashed 
//    public String run_analysis = "C:/Users/mmorto01/OneDrive - Environmental Protection Agency (EPA)/Profile/Documents/AMET-master/R_analysis_code/";
        
    //DB Info, do not include completed in public release 
    public String username = "AMET_App";
    public String password = "**************";
    
    public String conn = "jdbc:mariadb://amet.ib:3306?&useSSL=true";
    public String lConn = "jdbc:mariadb://amet.ib:3306?&useSSL=true&trustStore=/home/mmorto01/keystore.jks&trustStorePassword=****************";
    public String wConn = "jdbc:mariadb://amet.ib:3306?&useSSL=true&trustStore=C:/Users/mmorto01/OneDrive - Environmental Protection Agency (EPA)/Profile/Documents/configure/keystore.jks&trustStorePassword=********************";
}


    

