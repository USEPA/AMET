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
    
    //cache_amet: directory where run_info and output files will be stored
    public String cache_amet = "-Enter file path-";
    //amet_base: root direcroty of AMET software, should contain Run_analysis.R scripts folder
    public String amet_base = "-Enter file path-";
    //mysql_config: config file for connecting to MySQL
    public String mysql_config = "-Enter file path-";
    //rscript: links to rscript.exe
    public String rScript = "-Enter file path-";
    //ametstatic: static input file for scripts
    public String amet_static = "-Enter file path-";
    //pid: temp folder for output
    public String dir_name = "-Enter file path- Example: /work/MOD3DEV/AMET/dev/AMETJavaGUIdev/cache/guidir.";
    //rlibs: R library directory
    public String rLibs = "-Enter file path-";
    //pandoc: Links to pandoc binary file for plotly files
    public String pandoc = "-Enter file path-";
    //run_analysis: links to R analysis scripts (R_analysis_code)
    public String run_analysis = "-Enter file path-";
    
    //keystore login information
    public String keystore = "-Enter keystore file path-";
    public String keystore_password = "-Enter keystore password-";
    
    //database connection information
    public String conn = "jdbc:mariadb://amet.ib:3306?&useSSL=true";
}


    

