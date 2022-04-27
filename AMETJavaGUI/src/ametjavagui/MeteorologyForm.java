/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ametjavagui;

/**
 *
 * @author Michael Morton
 * 
 **/

import com.github.lgooddatepicker.components.DatePickerSettings;
import ametjavagui.METAdvancedForms.TimeSeriesPlotOptions;
import ametjavagui.METAdvancedForms.DailyBarPlotOptions;
import ametjavagui.METAdvancedForms.SpatialPlotOptions;
import ametjavagui.METAdvancedForms.SummaryPlotOptions;
import ametjavagui.METAdvancedForms.RadiationPlotOptions;
import ametjavagui.METAdvancedForms.RAOBPlotOptions;
import java.awt.Color;
import java.awt.Cursor;
import java.awt.Desktop;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.Random;

public class MeteorologyForm extends javax.swing.JFrame {
    Config config = new Config();

    //Variable instantiation and setting default values
    public String run_program = "";
    public String amet_static = "";
    public String script = "";
    public String query = "\"\""; 
    public String file_path = "\"\"";
    public String dir_path = "\"\"";
    public String path = "\"\"";
    public String dbase = "\"\""; 
    public String dbase2 = "\"\"";
    public String pid = "";
    public String dir_name = "";
    public String dir_namex = "";
    public String dir_name_delete = "";
    public String run_info = "\"\"";
    public String mysql_server = "amet.ib";
    public String run_name1 = "\"\""; 
    public String run_name2 = ""; 
    public String species_in = "\"\"";  
    public String max_rec = "\"\"";
    public String save_file = "F";
    public String text_out = "F";
    public String wd_weight_ws = "F";
    public boolean weight = false;
    public boolean weight_reset = false;
    public String group_stat = "F";
    public boolean groupstat = false;
    public boolean groupstat_reset = false;
    public String comp = "F";
    public boolean compare = false;
    public String ametp = "T";
    public boolean ametplot = true;
    public boolean ametplot_reset = true;
    public String diurnal = "T";
    public boolean diurnal_summary = true;
    public boolean diurnal_summary_reset = true;
    public boolean diurnal_rad = true;
    public boolean diurnal_rad_reset = true;
    public String spatial = "T";
    public boolean spatial_rad = true;
    public boolean spatial_rad_reset = true;
    public String time_series = "T";
    public boolean time_series_rad = true;
    public boolean time_series_rad_reset = true;
    public String histogram = "T";
    public boolean histogram_rad = true;
    public boolean histogram_rad_reset = true;
    public String spatial_m = "T";
    public boolean spatialm = true;
    public boolean spatialm_reset = true;
    public String t_series_m = "F";
    public boolean tseriesm = false;
    public boolean tseriesm_reset = false;
    public String prof_m = "T";
    public boolean profm = true;
    public boolean profm_reset = true;
    public String curtain_m = "F";
    public boolean curtainm = false;
    public boolean curtainm_reset = false;
    public String prof_n = "F";
    public boolean profn = false;
    public boolean profn_reset = false;
    public String curtain_n = "F";
    public boolean curtainn = false;
    public boolean curtainn_reset = false;
    public String hist_plot = "F";
    public boolean histplot = false;
    public boolean hist_plot_reset = false;
    public String shade_plot = "F";
    public boolean shadeplot = false;
    public boolean shade_plot_reset = false;
    public String daily = "F";
    public boolean dailyplot = false;
    public boolean daily_plot_reset = false;
    public String want_figs = "T";
    public String check_save = "F";
    public boolean checksave = false;
    public boolean check_save_reset = false;
    public String t_test_flag = "F";
    public boolean ttest = false;
    public boolean t_test_reset = false;
    public String thresh = "24";
    public String thresh_reset = "24";
    public String extra = ""; 
    public String extra_reset = "";
    public String extra2 = ""; 
    public String year_start = "\"\"";
    public int start_year;
    public int end_year;
    public int start_month;
    public int end_month;
    public int start_day;
    public int end_day;
    public String year_end = "\"\"";
    public String month_start = "\"\"";
    public String month_end = "\"\"";
    public String day_start = "\"\"";
    public String day_end = "\"\"";
    public String s_day_start = "\"\"";
    public String s_month_start = "\"\"";
    public String s_day_end = "\"\"";
    public String s_month_end = "\"\"";
    public String site_id = "\"\"";
    public String site = "";
    public String run_id = "AMET_GUI";
    public String run_id_reset = "AMET_GUI";
    public String start_hour = "\"\"";
    public String hs = "\"\"";
    public String end_hour = "\"\"";
    public String he = "\"\"";
    public int window = 0;
    public String lat_south = "NA";
    public String lat_south_reset = "NA";
    public String lat_north = "NA";
    public String lat_north_reset = "NA";
    public String lon_west = "NA";
    public String lon_west_reset = "NA";
    public String lon_east = "NA";
    public String lon_east_reset = "NA";
    public String query_string = "";
    public String querystr = "";
    public String query_str = "";
    public int plot_size = 1;
    public String plot_format = "pdf";
    public String symbol = "19";
    public String symbol2 = "21";
    public String symbol_scale_factor = "1.35";
    public String stat_text_scale_factor = "0.65";
    public String img_height = "\"NULL\"";
    public String img_width = "\"NULL\"";
    public String sres = "0.10";
    public String qc_temp_limit_lower = "240";
    public String qc_temp_limit_lower_reset = "240";
    public String qc_temp_limit_upper = "315";
    public String qc_temp_limit_upper_reset = "315";
    public String qc_moisture_limit_lower = "0";
    public String qc_moisture_limit_lower_reset = "0";
    public String qc_moisture_limit_upper = "30";
    public String qc_moisture_limit_upper_reset = "30";
    public String qc_wind_limit_lower = "1.5";
    public String qc_wind_limit_lower_reset = "1.5";
    public String qc_wind_limit_upper = "25";
    public String qc_wind_limit_upper_reset = "25";
    public String qc_humidity_limit_lower = "0";
    public String qc_humidity_limit_lower_reset = "0";
    public String qc_humidity_limit_upper = "102";
    public String qc_humidity_limit_upper_reset = "102";
    public String qc_pressure_kPa_lower = "500";
    public String qc_pressure_kPa_lower_reset = "500";
    public String qc_pressure_kPa_upper = "1070";
    public String qc_pressure_kPa_upper_reset = "1070";
    public int qc_pressure_limit_lower = Integer.parseInt(qc_pressure_kPa_lower)  / 10;
    public int qc_pressure_limit_upper = Integer.parseInt(qc_pressure_kPa_upper)  / 10;
    public String qc_error_temp = "15";
    public String qc_error_temp_reset = "15";
    public String qc_error_wind = "20";
    public String qc_error_wind_reset = "20";
    public String qc_error_moisture = "10";
    public String qc_error_moisture_reset = "10";
    public String qc_error_humidity = "50";
    public String qc_error_humidity_reset = "50";
    public String delt = "3";
    public String layer_lower = "1000";
    public String layer_lower_reset = "1000";
    public String layer_upper = "200";
    public String layer_upper_reset = "200";
    public String proflim_lower = "1000";
    public String proflim_lower_reset = "1000";
    public String proflim_upper = "200";
    public String proflim_upper_reset = "200";
    public String spatial_thresh = "5";
    public String spatial_thresh_reset = "5";
    public String level_thresh = "5";
    public String level_thresh_reset = "5";
    public String sounding_thresh = "5";
    public String sounding_thresh_reset = "5";
    public String profilen_thresh = "5";
    public String profilen_thresh_reset = "5";
    public String use_user_range = "T";
    public boolean user_range = true;
    public boolean user_range_reset = true;
    public String diff_t = "5";
    public String diff_t_reset = "5";
    public String diff_rh = "50";
    public String diff_rh_reset = "50";
    public int hs_index = 0;
    public String stat_id = "\"NULL\"";
    public String ob_network = "\"ALL\"";
    public String lat = "\"ALL\"";
    public String lon = "\"ALL\"";
    public String elev = "\"NULL\"";
    public String landuse = "\"NULL\"";
    public String date_s = "\"ALL\"";
    public String date_e = "\"ALL\"";
    public String ob_time = "\"ALL\"";
    public String fcast_hr = "\"ALL\"";
    public String level = "\"surface\"";
    public String syncond = "\"NULL\"";
    public String figure = "\"NULL\"";
    public String bias_level1 = "-300";
    public String bias_level2 = "-150";
    public String bias_level3 = "-100";
    public String bias_level4 = "-75";
    public String bias_level5 = "-40";
    public String bias_level6 = "-20";
    public String bias_level7 = "-10";
    public String bias_level8 = "0";
    public String bias_level9 = "10";
    public String bias_level10 = "20";
    public String bias_level11 = "40";
    public String bias_level12 = "75";
    public String bias_level13 = "100";
    public String bias_level14 = "150";
    public String bias_level15 = "300";
    public String bias_level1_reset = "-300";
    public String bias_level2_reset = "-150";
    public String bias_level3_reset = "-100";
    public String bias_level4_reset = "-75";
    public String bias_level5_reset = "-40";
    public String bias_level6_reset = "-20";
    public String bias_level7_reset = "-10";
    public String bias_level8_reset = "0";
    public String bias_level9_reset = "10";
    public String bias_level10_reset = "20";
    public String bias_level11_reset = "40";
    public String bias_level12_reset = "75";
    public String bias_level13_reset = "100";
    public String bias_level14_reset = "150";
    public String bias_level15_reset = "300";
    public String rmse_level1 = "0";
    public String rmse_level2 = "25";
    public String rmse_level3 = "50";
    public String rmse_level4 = "75";
    public String rmse_level5 = "100";
    public String rmse_level6 = "125";
    public String rmse_level7 = "150";
    public String rmse_level8 = "175";
    public String rmse_level9 = "200";
    public String rmse_level10 = "250";
    public String rmse_level11 = "300";
    public String rmse_level12 = "400";
    public String rmse_level13 = "500";
    public String rmse_level1_reset = "0";
    public String rmse_level2_reset = "25";
    public String rmse_level3_reset = "50";
    public String rmse_level4_reset = "75";
    public String rmse_level5_reset = "100";
    public String rmse_level6_reset = "125";
    public String rmse_level7_reset = "150";
    public String rmse_level8_reset = "175";
    public String rmse_level9_reset = "200";
    public String rmse_level10_reset = "250";
    public String rmse_level11_reset = "300";
    public String rmse_level12_reset = "400";
    public String rmse_level13_reset = "500";
    public String mae_level1 = "0";
    public String mae_level2 = "25";
    public String mae_level3 = "50";
    public String mae_level4 = "75";
    public String mae_level5 = "100";
    public String mae_level6 = "125";
    public String mae_level7 = "150";
    public String mae_level8 = "175";
    public String mae_level9 = "200";
    public String mae_level10 = "250";
    public String mae_level11 = "300";
    public String mae_level1_reset = "0";
    public String mae_level2_reset = "25";
    public String mae_level3_reset = "50";
    public String mae_level4_reset = "75";
    public String mae_level5_reset = "100";
    public String mae_level6_reset = "125";
    public String mae_level7_reset = "150";
    public String mae_level8_reset = "175";
    public String mae_level9_reset = "200";
    public String mae_level10_reset = "250";
    public String mae_level11_reset = "300";
    public String sdev_level1 = "-150";
    public String sdev_level2 = "-100";
    public String sdev_level3 = "-75";
    public String sdev_level4 = "-40";
    public String sdev_level5 = "-20";
    public String sdev_level6 = "-10";
    public String sdev_level7 = "0";
    public String sdev_level8 = "10";
    public String sdev_level9 = "20";
    public String sdev_level10 = "40";
    public String sdev_level11 = "75";
    public String sdev_level12 = "100";
    public String sdev_level13 = "150";
    public String sdev_level1_reset = "-150";
    public String sdev_level2_reset = "-100";
    public String sdev_level3_reset = "-75";
    public String sdev_level4_reset = "-40";
    public String sdev_level5_reset = "-20";
    public String sdev_level6_reset = "-10";
    public String sdev_level7_reset = "0";
    public String sdev_level8_reset = "10";
    public String sdev_level9_reset = "20";
    public String sdev_level10_reset = "40";
    public String sdev_level11_reset = "75";
    public String sdev_level12_reset = "100";
    public String sdev_level13_reset = "150";
    public String inc_all = "";
    public String inc_METAR = "";
    public String inc_AIRNOW = "";
    public String inc_ASOS = "";
    public String inc_MARITIME = "";
    public String inc_SAO = "";
    public String inc_Mesonet = "";
    public String Project_Code = "";
    public String Model = "";
    public String Owner = "";
    public String Description = "";
    public String Project_Creation_Date = "";
    public String Earliest_Record = "";
    public String Latest_Record = "";
    public String state = "\"\"";
    public String username = System.getProperty("user.name");
    public String script_wrapper = "";
    public String analysis_wrapper = "";
    public Color bright_blue = new Color(0,112,185);
    public Color dark_blue = new Color(0,63,105);
    public Color[] colors = {dark_blue, dark_blue, bright_blue, bright_blue, dark_blue, bright_blue, dark_blue, bright_blue, dark_blue, bright_blue, dark_blue, bright_blue, dark_blue, bright_blue,};
    
    //Variables for Advanced Spatial Surface Plot
    public String stat_abr1 = "\"count\"";
    public String stat_abr2 = "\"corr\"";
    public String stat_abr3 = "\"ac\"";
    public String stat_abr4 = "\"var\"";
    public String stat_abr5 = "\"sdev\"";
    public String stat_abr6 = "\"rmse\"";
    public String stat_abr7 = "\"mae\"";
    public String stat_abr8 = "\"bias\"";
    public String stat_abr9 = "\"mfbias\"";
    public String stat_abr10 = "\"mnbias\"";
    public String stat_abr11 = "\"mngerr\"";
    public String stat_abr12 = "\"nmbias\"";
    public String stat_abr13 = "\"nmerr\"";
    public String stat_abr14 = "\"max\"";
    public String stat_abr15 = "\"min\"";
    public String var_abr1 = "\"T\"";
    public String var_abr2 = "\"WS\"";
    public String var_abr3 = "\"WD\"";
    public String var_abr4 = "\"Q\"";
    public String stat_id1 = "\"Count\"";
    public String stat_id2 = "\"Correlation\"";
    public String stat_id3 = "\"Anomaly Correlation\"";
    public String stat_id4 = "\"Variance\"";
    public String stat_id5 = "\"Standard Deviation\"";
    public String stat_id6 = "\"RMSE\"";
    public String stat_id7 = "\"Mean Absolute Error\"";
    public String stat_id8 = "\"Mean Bias\"";
    public String stat_id9 = "\"Mean Fractional Bias\"";
    public String stat_id10 = "\"Mean Normalized Bias\"";
    public String stat_id11 = "\"Mean Normalized Gross Error\"";
    public String stat_id12 = "\"Normalized Mean Bias\"";
    public String stat_id13 = "\"Normalized Mean Error\"";
    public String stat_id14 = "\"Difference Max Value\"";
    public String stat_id15 = "\"Difference Min Value\"";
    public String var_id1 = "\"2 m Temperature (C)\"";
    public String var_id2 = "\"Wind Speed (m/s)\"";
    public String var_id3 = "\"Wind Direction (Deg.)\"";
    public String var_id4 = "\"Mixing Ratio (g/kg)\"";
    public String great_color = "gray(0.8)";
    public String good_color = "\"green\"";
    public String fair_color = "\"blue\"";
    public String caution_color = "\"yellow\"";
    public String questionable_color = "\"red\"";
    public String bad_color = "\"black\"";
    public String L1_error1 = "0";
    public String L1_error2 = "0.50";
    public String L1_error3 = "1";
    public String L1_error4 = "1.5";
    public String L1_error5 = "2";
    public String L1_error6 = "2.5";
    public String L1_error7 = "3";
    public String L1_error8 = "4";
    public String L1_error9 = "5";
    public String L1_error10 = "6";
    public String L1_error11 = "7";
    public String L1_error12 = "8";
    public String L2_error1 = "-3";
    public String L2_error2 = "-2";
    public String L2_error3 = "-1";
    public String L2_error4 = "-0.5";
    public String L2_error5 = "-0.25";
    public String L2_error6 = "0";
    public String L2_error7 = "0.25";
    public String L2_error8 = "0.5";
    public String L2_error9 = "1";
    public String L2_error10 = "2";
    public String L2_error11 = "3";
    public String L2_error12 = "4";
    public String L1wd_error1 = "0";
    public String L1wd_error2 = "10";
    public String L1wd_error3 = "20";
    public String L1wd_error4 = "30";
    public String L1wd_error5 = "40";
    public String L1wd_error6 = "50";
    public String L1wd_error7 = "60";
    public String L1wd_error8 = "70";
    public String L1wd_error9 = "80";
    public String L1wd_error10 = "90";
    public String L1wd_error11 = "135";
    public String L1wd_error12 = "180";
    public String L2wd_error1 = "-40";
    public String L2wd_error2 = "-30";
    public String L2wd_error3 = "-20";
    public String L2wd_error4 = "-10";
    public String L2wd_error5 = "0";
    public String L2wd_error6 = "10";
    public String L2wd_error7 = "20";
    public String L2wd_error8 = "30";
    public String L2wd_error9 = "40";
    public String L1n_error1 = "0";
    public String L1n_error2 = "5";
    public String L1n_error3 = "10";
    public String L1n_error4 = "15";
    public String L1n_error5 = "20";
    public String C1n_color1 = "\"green\"";
    public String C1n_color2 = "\"blue\"";
    public String C1n_color3 = "\"yellow\"";
    public String C1n_color4 = "\"red\"";
    public String C1n_color5 = "\"red\"";
    public String L2n_error1 = "-20";
    public String L2n_error2 = "-15";
    public String L2n_error3 = "-10";
    public String L2n_error4 = "-5";
    public String L2n_error5 = "0";
    public String L2n_error6 = "5";
    public String L2n_error7 = "10";
    public String L2n_error8 = "15";
    public String L2n_error9 = "20";
    public String C2n_color1 = "\"red\"";
    public String C2n_color2 = "\"yellow\"";
    public String C2n_color3 = "\"blue\"";
    public String C2n_color4 = "\"green\"";
    public String C2n_color5 = "\"green\"";
    public String C2n_color6 = "\"blue\"";
    public String C2n_color7 = "\"yellow\"";
    public String C2n_color8 = "\"red\"";
    public String C2n_color9 = "\"red\"";
    public String L1iW_value1 = "0";
    public String L1iW_value2 = "0.2";
    public String L1iW_value3 = "0.4";
    public String L1iW_value4 = "0.5";
    public String L1iW_value5 = "0.6";
    public String L1iW_value6 = "0.7";
    public String L1iW_value7 = "0.8";
    public String L1iW_value8 = "0.9";
    public String L1iW_value9 = "1.0";
    
    //Variables not in use yet
    public String dates = "\"\""; 
    public String averaging = "\"n\""; 
    public String rpo = "\"\"";
    public String pca = "\"\"";
    public String clim_reg = "\"\"";
    public String world_reg = "\"\"";
    public String aggregate_data = "\"\"";
    public String custom_title = "\"\"";
    public String remove_negatives = "\"y\"";
    public String figdir = "\"\"";
    public String map_type = "1";
    public String month_name = "\"\"";
    public int month = 0;
    public String poCode = "\"\"";
    public String zeroprecip = "\"\"";
    public String ametptype = "\"\"";
    public String custom_query = "";
   
    //file naming info
    public String project_id = "";
    public String project_id2 = "";
    public String species = "";
    public String pidx = "";
    
    //check helper variable
    public boolean isNetworkSelectedTemp = false;
    public boolean isNetworkSelected = false;
    
    
//##############################################################################
//   MAIN FUNCTIONS 
//##############################################################################

    /**
     * Creates new form MeteorologyForm
     */
    public MeteorologyForm() {
        initComponents();
        
        //Sets format for dates in the date picker
        DatePickerSettings startDateSettings = new DatePickerSettings();
        DatePickerSettings endDateSettings = new DatePickerSettings();
        startDateSettings.setFormatForDatesCommonEra("yyyy/MM/dd");
        endDateSettings.setFormatForDatesCommonEra("yyyy/MM/dd");
        StartDatePicker.setSettings(startDateSettings);
        EndDatePicker.setSettings(endDateSettings);
        
        //MYSQL query that populates the list of databases
        try {
            DBConnection db = new DBConnection();
            db.getDBConnection();
            
            db.query("SHOW databases;");
            ResultSet rs = db.getRS();
            
            ResultSetMetaData rsmd = rs.getMetaData();
            int columnsNumber = rsmd.getColumnCount();
            while (rs.next()) {
                for (int i = 1; i <= columnsNumber; i++) {
                    if (i > 1) System.out.print(",  ");
                    String columnValue = rs.getString(i);
                    SelectDatabaseComboBox.addItem(columnValue);
                    SelectAdditionalDatabaseComboBox.addItem(columnValue);
                }
            }
            db.closeDBConnection(); 
        } catch (SQLException e) {
            errorWindow("SQL Exception", "This error typically occurs when the application is not getting any info from the database. This could be because it cannot find the database on the network, the login credintials were incorrect, or the path to the database was incorrect.");
        } catch (NullPointerException e) {
            errorWindow("SQL/Null Pointer Exception", "This error typically occurs when the application is not getting any info from the database. This could be because it cannot find the database on the network, the login credintials were incorrect, or the path to the database was incorrect.");
        }
    }
    
    //Saves and formats variables
    public void saveVariables() {
        //Generate a random pid
        Random rand = new Random();
        pidx = String.valueOf(rand.nextInt(1000000));
        pid = "\"" + pidx + "\"";
        run_info = "run_info_MET." + pidx + ".R";
        
        if("".equals(CustomDirectoryNameTextField.getText())){
            dir_name = pid;
            dir_namex = pidx;}
        else {
            dir_namex = CustomDirectoryNameTextField.getText();
            dir_namex = dir_namex.replaceAll("\\s","");
        }
        if(!dir_namex.equals(pidx)){
            dir_name = "\"" + dir_namex + "\"";
        }
        System.out.println(run_info);
        
        
        figdir = "\"" + config.dir_name + username + "." + dir_namex + "\"";
        file_path = config.dir_name  + username + "." + dir_namex;
        
        dbase = SelectDatabaseComboBox.getSelectedItem().toString();
        
        run_name1 = textFormat(SelectProjectComboBox.getSelectedItem().toString());
        run_name2 = textFormat(SelectAdditionalProjectComboBox2.getSelectedItem().toString());
        
        if (run_name2.equals("\"<Select a Database First>\"") && SelectAdditionalDatabaseComboBox.getSelectedItem().toString().equals("Choose a Database")){
            run_name2 = "\"\"";
        }
        
        if (!numNullFormat(LatTextField1.getText()).equals("NULL")){
            lat_south = numNullFormat(LatTextField1.getText());   
        }
        else {
            lat_south = "NA";
        }
        
        if (!numNullFormat(LatTextField2.getText()).equals("NULL")){
            lat_north = numNullFormat(LatTextField2.getText());
        }
        else {
            lat_north = "NA";
        }
        
        if (!numNullFormat(LonTextField1.getText()).equals("NULL")){
            lon_west = numNullFormat(LonTextField1.getText());
        }
        else {
            lon_west = "NA";
        }
        
        if (!numNullFormat(LonTextField2.getText()).equals("NULL")){
            lon_east = numNullFormat(LonTextField2.getText());
        }
        else {
            lon_east = "NA";
        }

        isNetworkSelected = isNetworkSelectedTemp; //saves temp value, using this instead of a check function is much faster
        clim_reg = textFormat(ClimateComboBox.getSelectedItem().toString());
        world_reg = textFormat(WorldComboBox.getSelectedItem().toString());
        if (!CustomRunNameTextField.getText().equals("")){
            run_id = CustomRunNameTextField.getText();
        }
        
        dates = "\"" + year_start + month_start + day_start + " to " + year_end + month_end + day_end + "\"";  
        start_hour = textFormat(StartHourComboBox.getSelectedItem().toString());

        if (!start_hour.equals("\"Default\"")) {
            hs = hourFormat(start_hour);
        }
        else {
            if (hs.equals("\"\"")){
            hs = "00";
            }
        }
        end_hour = textFormat(EndHourComboBox.getSelectedItem().toString());
        if (!end_hour.equals("\"Default\"")) {
            he = hourFormat(end_hour);
        }
        else {
            he = "23";
        }
        

        save_file = checkBoxFormat(SaveFileCheckBox);
        text_out = checkBoxFormat(TextOutCheckBox);
        symbol = symbolFormat(SymbolComboBox.getSelectedItem().toString());
        symbol_scale_factor = numNullFormat(SymbolScaleTextField.getText());
        stat_text_scale_factor = numNullFormat(TextScaleTextField.getText());
        inc_all = checkBoxFormat(AllCheckBox);
        inc_METAR = checkBoxFormat(METARCheckBox);
        inc_ASOS = checkBoxFormat(ASOSCheckBox);
        inc_MARITIME = checkBoxFormat(MaritimeCheckBox);
        inc_SAO = checkBoxFormat(SAOCheckBox);
        inc_Mesonet = checkBoxFormat(MesonetCheckBox);
        max_rec = MaxRecordsTextField.getText();
        
        if (MonthlyAnalysisCheckBox.isSelected()){
            analysis_wrapper = "MN";
        }
        else if (SeasonalAnalysisCheckBox.isSelected()){
            analysis_wrapper = "SE";
        }
        else {
            analysis_wrapper = "";
        }
        System.out.println(analysis_wrapper);

        //state formatting
        state = StateComboBox.getSelectedItem().toString();
        if (state.equals("Include all states")) {
            state = "\"All\"";
        } 
        else {
            state = "'" + state + "'";
        }
        
        //RPO formatting
        if (RPOComboBox.getSelectedItem().toString().equals("None")) {
            rpo = "\"None\"";
        } 
        else {
            rpo = textFormat(RPOComboBox.getSelectedItem().toString());
        }
        
        //PCA formatting
        if (PCAComboBox.getSelectedItem().toString().equals("None")) {
            pca = "\"None\"";
        } 
        else {
            pca = textFormat(PCAComboBox.getSelectedItem().toString());
        }
          
        //Date formatting
        String sd = StartDatePicker.getDateStringOrEmptyString();
        String ed = EndDatePicker.getDateStringOrEmptyString();
        
        if (!sd.equals("")) {
            year_start = sd.substring(0, 4);
            month_start = sd.substring(5, 7);
            day_start = sd.substring(8, 10);
            
            start_year = Integer.parseInt(year_start);
            start_month = Integer.parseInt(month_start);
            start_day = Integer.parseInt(day_start);
            
            if("0".equals(sd.substring(8,9))){
                s_day_start = sd.substring(9, 10);
            }
            else {
                s_day_start = day_start;
            }
            if("0".equals(sd.substring(5,6))){
                s_month_start = sd.substring(6, 7);
            }
            else {
                s_month_start = month_start;
            }
        }
        if (!ed.equals("")) {
            year_end = ed.substring(0, 4);
            month_end  = ed.substring(5, 7);
            day_end  = ed.substring(8, 10);
            
            end_year = Integer.parseInt(year_end);
            end_month = Integer.parseInt(month_end);
            end_day = Integer.parseInt(day_end);
            
            if("0".equals(ed.substring(8,9))){
                s_day_end = ed.substring(9, 10);
            }
            else {
                s_day_end = day_end;
            }
            if("0".equals(ed.substring(5,6))){
                s_month_end = ed.substring(6, 7);
            }
            else {
                s_month_end = month_end;
            }
        }  
        System.out.println("starting date: " + month_start + "/" + day_start + "/" + year_start);
        System.out.println("ending date: " + month_end + "/" + day_end + "/" + year_end);

        System.out.println("starting date: " + start_month + "/" + start_day + "/" + start_year);
        System.out.println("ending date: " + end_month + "/" + end_day + "/" + end_year);
        
        //Image height and width formatting
        if (img_height.equals("NULL")) { 
            HeightTextField.getText();
        } 
        else { 
            img_height = HeightTextField.getText();
        }
        
        if (img_width.equals("NULL")) { 
            WidthTextField.getText();
        } else { 
            img_width = WidthTextField.getText();
        }
        
        //Site ID formatting
        if (textFormat(SiteIDTextField.getText()).equals("\"\"")) {
            site_id = "\"ALL\"";
        } else {
            site_id = textFormat(SiteIDTextField.getText());
        }

        //amet plot type formatting
        if (GraphicsFormatComboBox.getSelectedItem().toString().equals("PNG")) {
            plot_format = "png";
        } 
        if (GraphicsFormatComboBox.getSelectedItem().toString().equals("PDF")) {
            plot_format = "pdf";
        } 
        
        //Helper functions
        programFormat();
        queryFormat();
        
        site = SiteIDTextField.getText();
        String siteid = site_id.replace("\"","");
        
        //Sets analysis selection for Upper-Air analyses
        if ("Upper-Air: Mandatory Spatial Statistics".equals(ProgramComboBox.getSelectedItem().toString())){
            spatialm = true;
            spatial_m = "T";
            tseriesm = false;
            t_series_m = "F";
            profm = false;
            prof_m  = "F";
            curtainm = false;
            curtain_m = "F";
            profn = false;
            prof_n = "F";
            curtainn = false;
            curtain_n = "F";
        }
        else if ("Upper-Air: Mandatory Time Series Statistics".equals(ProgramComboBox.getSelectedItem().toString())){
            spatialm = false;
            spatial_m = "F";
            tseriesm = true;
            t_series_m = "T";
            profm = false;
            prof_m  = "F";
            curtainm = false;
            curtain_m = "F";
            profn = false;
            prof_n = "F";
            curtainn = false;
            curtain_n = "F";
        }
        else if ("Upper-Air: Mandatory Profile Statistics".equals(ProgramComboBox.getSelectedItem().toString())){
            spatialm = false;
            spatial_m = "F";
            tseriesm = false;
            t_series_m = "F";
            profm = true;
            prof_m  = "T";
            curtainm = false;
            curtain_m = "F";
            profn = false;
            prof_n = "F";
            curtainn = false;
            curtain_n = "F";
        }
        else if ("Upper-Air: Mandatory Curtain".equals(ProgramComboBox.getSelectedItem().toString())){
            spatialm = false;
            spatial_m = "F";
            tseriesm = false;
            t_series_m = "F";
            profm = false;
            prof_m  = "F";
            curtainm = true;
            curtain_m = "T";
            profn = false;
            prof_n = "F";
            curtainn = false;
            curtain_n = "F";
        }
        else if ("Upper-Air: Native Theta / RH Profiles".equals(ProgramComboBox.getSelectedItem().toString())){
            spatialm = false;
            spatial_m = "F";
            tseriesm = false;
            t_series_m = "F";
            profm = false;
            prof_m  = "F";
            curtainm = false;
            curtain_m = "F";
            profn = true;
            prof_n = "T";
            curtainn = false;
            curtain_n = "F";
        }
        else if ("Upper-Air: Native Curtain".equals(ProgramComboBox.getSelectedItem().toString())){
            spatialm = false;
            spatial_m = "F";
            tseriesm = false;
            t_series_m = "F";
            profm = false;
            prof_m  = "F";
            curtainm = false;
            curtain_m = "F";
            profn = false;
            prof_n = "F";
            curtainn = true;
            curtain_n = "T";
        }
        
        //generate MySQL queries for Output window
        if ("Time Series: 2-m Temp, 2-m Moisture and 10-m Wind".equals(ProgramComboBox.getSelectedItem().toString())) {
            query = "SELECT DATE_FORMAT(ob_date,'%Y%m%d'), HOUR(ob_date), stat_id, fcast_hr, T_mod, T_ob, Q_mod, WVMR_ob, U_mod, U_ob, V_mod, V_ob, HOUR(ob_time)\n"
                    + "FROM " + project_id + "_surface" + "\n" + "WHERE stat_id = '" + site + "' and ob_date BETWEEN \n" + "'" + year_start + "-" + month_start + "-" + day_start 
                    + " " + hs +":00:00' and '" + year_end + "-" + month_end + "-" + day_end + " " + he + ":00:00'\n" + "ORDER BY ob_date,ob_time" + " " + extra;
        }
        else if ("Time Series: 2-m Temp, 2-m Moisture, 2-m RH and Sfc Pressure".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "SELECT DATE_FORMAT(ob_date,'%Y%m%d'), HOUR(ob_date), stat_id, fcast_hr, T_mod, T_ob, Q_mod, WVMR_ob, PSFC_mod, PSFC_ob\n"
                    + "FROM " + project_id + "_surface" + "\n" + "WHERE stat_id = '" + site + "' and ob_date BETWEEN " + year_start + month_start + day_start 
                    + " and " + year_end + month_end + day_end + "\n" + "ORDER BY ob_date,ob_time" + " " + extra;
        }
        else if ("Daily Statistics: 2-m Temp, 2-m Moisture and 10-m Wind".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "SELECT DATE_FORMAT(ob_date,'%Y%m%d'), HOUR(ob_date), d.stat_id, s.ob_network, d.T_mod, d.T_ob, d.Q_mod, d.WVMR_ob, d.U_mod, d.U_ob, d.V_mod, d.V_ob\n"
                    + "FROM " + project_id + "_surface d, stations s" + "\n" + "WHERE  s.stat_id=d.stat_id AND ob_date BETWEEN " + year_start + month_start + day_start 
                    + " AND " + year_end + month_end + day_end  + "\n" + "ORDER BY ob_date" + query_string;
        }
        else if ("Summary Statistics: 2-m Temp, 2-m Moisture and 10-m Wind".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "SELECT DATE_FORMAT(ob_date,'%Y%m%d'), HOUR(ob_date), d.stat_id, s.ob_network, d.T_mod, d.T_ob, d.Q_mod, d.WVMR_ob, d.U_mod,d.U_ob, d.V_mod, d.V_ob, HOUR(ob_time)\n"
                    + "FROM " + project_id + "_surface d, stations s" + "\n" + "WHERE  s.stat_id=d.stat_id AND ob_date BETWEEN " + year_start + month_start + day_start 
                    + " AND " + year_end + month_end + day_end + "\n" + query_string;
        }
         else if ("Shortwave Radiation Statistics: Spatial, Diurnal and Time Series".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "SELECT DATE_FORMAT(ob_date,'%Y%m%d'), HOUR(ob_date), d.stat_id, s.lat, s.lon, d.SRAD_mod, d.SRAD_ob "
                    + "FROM " + project_id + "_surface d, stations s" + "\n" + "WHERE  s.stat_id=d.stat_id AND (s.ob_network='SRAD' || s.ob_network='BSRN') " 
                    + "AND d.SRAD_ob > 0 AND d.ob_date BETWEEN " + year_start + month_start + day_start 
                    + " AND " + year_end + month_end + day_end + "\n" + "ORDER BY ob_date" + " " + extra;
        }
        else if ("Spatial Statistics: 2-m Temp, 2-m Moisture and 10-m Wind".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "SELECT d.stat_id, d.T_mod, d.T_ob, d.Q_mod, d.WVMR_ob, d.U_mod, d.U_ob, d.V_mod, d.V_ob, HOUR(d.ob_time) "
                    + "FROM "  + project_id + "_surface d, stations s\n" + "WHERE s.stat_id=d.stat_id and d.ob_date  >= '" + year_start + "-" + month_start + "-" + day_start
                    + "' AND d.ob_date < '" + year_end + "-" + month_end + "-" + day_end + "'\n" + extra + "ORDER BY d.stat_id\n\n"
                    + "SELECT DISTINCT s.stat_id, s.lat, s.lon, s.elev  FROM " + project_id + "_surface d, stations s\n"
                    + "WHERE s.stat_id=d.stat_id and d.ob_date  >= '" + year_start + "-" + month_start + "-" + day_start
                    + "' AND d.ob_date < '" + year_end + "-" + month_end + "-" + day_end + "'\n" + "ORDER BY d.stat_id" + " " + extra;
        }
        else if ("Upper-Air: Spatial, Profile, Time Series and Curtain".equals(ProgramComboBox.getSelectedItem().toString())){
            if("T".equals(spatial_m)){
                query = "SELECT s.stat_id, s.lat, s.lon, YEAR(d.ob_date), MONTH(d.ob_date), DAY(d.ob_date), HOUR(d.ob_date), d.plevel, d.v1_id, d.v1_val, d.v2_id, d.v2_val\n"
                    + "FROM " + project_id + "_raob d ,stations s WHERE d.stat_id=s.stat_id AND d.ob_date\n"
                    + "BETWEEN '" + year_start + "-" + month_start + "-" + day_start 
                    + " " + hs + ":00:00' AND '" + year_end + "-" + month_end + "-" + day_end + " " + he + ":00:00'\n" 
                    + "AND (d.v1_id='T_OBS_M' OR d.v2_id='T_MOD_M') AND d.plevel " + "BETWEEN " + layer_lower + " AND " + layer_upper + "\n" 
                    + "AND (s.lat BETWEEN " + lat_south + " AND " + lat_north + " AND s.lon BETWEEN " + lon_west + " AND " + lon_east + ")\n"
                    + "ORDER BY stat_id";
            }
            else if("T".equals(t_series_m)){
                query = "SELECT s.stat_id, s.lat, s.lon, YEAR(d.ob_date), MONTH(d.ob_date), DAY(d.ob_date), HOUR(d.ob_date), d.plevel, d.v1_id, d.v1_val, d.v2_id, d.v2_val\n"
                    + "FROM " + project_id + "_raob d ,stations s WHERE d.stat_id=s.stat_id AND d.ob_date\n"
                    + "BETWEEN '" + year_start + "-" + month_start + "-" + day_start 
                    + " " + hs + ":00:00' AND '" + year_end + "-" + month_end + "-" + day_end + " " + he + ":00:00'\n" 
                    + "AND (d.v1_id='T_OBS_M' OR d.v2_id='T_MOD_M') AND d.plevel " + "BETWEEN " + layer_lower + " AND " + layer_upper + "\n" 
                    + "AND (s.lat BETWEEN " + lat_south + " AND " + lat_north + " AND s.lon BETWEEN " + lon_west + " AND " + lon_east + ")\n"
                    + "ORDER BY stat_id";
            }
            else if("T".equals(prof_m)){
                query = "SELECT s.stat_id, s.lat, s.lon, YEAR(d.ob_date), MONTH(d.ob_date), DAY(d.ob_date), HOUR(d.ob_date), d.plevel, d.v1_id, d.v1_val, d.v2_id, d.v2_val\n"
                    + "FROM " + project_id + "_raob d ,stations s WHERE d.stat_id=s.stat_id AND d.ob_date\n"
                    + "BETWEEN '" + year_start + "-" + s_month_start + "-" + s_day_start 
                    + " " + hs + ":00:00' AND '" + year_end + "-" + month_end + "-" + day_end + " " + he + ":00:00' AND HOUR(d.ob_date)=0\n" 
                    + "AND (d.v1_id='T_OBS_M' OR d.v2_id='T_MOD_M') AND d.stat_id='" + siteid + "'\n"
                    + "ORDER BY stat_id, ob_date, plevel";        
            }
            else if("T".equals(curtain_m)){
                query = "SELECT s.stat_id, s.lat, s.lon, YEAR(d.ob_date), MONTH(d.ob_date), DAY(d.ob_date), HOUR(d.ob_date), d.plevel, d.v1_id, d.v1_val, d.v2_id, d.v2_val\n"
                    + "FROM " + project_id + "_raob d ,stations s WHERE d.stat_id=s.stat_id AND d.ob_date\n"
                    + "BETWEEN '" + year_start + "-" + month_start + "-" + day_start 
                    + " " + hs + ":00:00' AND '" + year_end + "-" + month_end + "-" + day_end + " " + he + ":00:00' AND HOUR(d.ob_date)=0\n" 
                    + "AND (d.v1_id='T_OBS_M' OR d.v2_id='T_MOD_M') AND d.stat_id='" + siteid + "'\n"
                    + "ORDER BY stat_id, ob_date, plevel";
            } 
            else if("T".equals(prof_n)){
                query = "SELECT s.stat_id, YEAR(d.ob_date), MONTH(d.ob_date), DAY(d.ob_date), HOUR(d.ob_date), plevel, v1_id, v1_val, v2_id, v2_val\n"
                    + "FROM " + project_id + "_raob WHERE ob_date='" + year_start + "-" + month_start + "-" + day_start + " " + hs + ":00:00'\n"
                    + "AND (v1_id='T_OBS_M' OR v2_id='T_MOD_M') AND plevel " + "BETWEEN " + layer_lower + " AND " + layer_upper + "\n" 
                    + "ORDER BY plevel";        
            }
            else if("T".equals(curtain_n)){
                query = "SELECT s.stat_id, YEAR(d.ob_date), MONTH(d.ob_date), DAY(d.ob_date), HOUR(d.ob_date), plevel, v1_id, v1_val, v2_id, v2_val\n"
                    + "FROM " + project_id + "_raob WHERE ob_date='" + year_start + "-" + month_start + "-" + day_start + " " + hs + ":00:00'\n"
                    + "AND (v1_id='T_OBS_M' OR v2_id='T_MOD_M') AND plevel " + "BETWEEN " + layer_lower + " AND " + layer_upper + "\n" 
                    + "ORDER BY plevel";        
            }
            else {
                query = "";
            }
         }
        else if ("Upper-Air: Mandatory Spatial Statistics".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "SELECT s.stat_id, s.lat, s.lon, YEAR(d.ob_date), MONTH(d.ob_date), DAY(d.ob_date), HOUR(d.ob_date), d.plevel, d.v1_id, d.v1_val, d.v2_id, d.v2_val\n"
                + "FROM " + project_id + "_raob d ,stations s WHERE d.stat_id=s.stat_id AND d.ob_date\n"
                + "BETWEEN '" + year_start + "-" + month_start + "-" + day_start 
                + " " + hs + ":00:00' AND '" + year_end + "-" + month_end + "-" + day_end + " " + he + ":00:00'\n" 
                + "AND (d.v1_id='T_OBS_M' OR d.v2_id='T_MOD_M') AND d.plevel " + "BETWEEN " + layer_lower + " AND " + layer_upper + "\n" 
                + "AND (s.lat BETWEEN " + lat_south + " AND " + lat_north + " AND s.lon BETWEEN " + lon_west + " AND " + lon_east + ")\n"
                + "ORDER BY stat_id";
        }
        else if ("Upper-Air: Mandatory Time Series Statistics".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "SELECT s.stat_id, s.lat, s.lon, YEAR(d.ob_date), MONTH(d.ob_date), DAY(d.ob_date), HOUR(d.ob_date), d.plevel, d.v1_id, d.v1_val, d.v2_id, d.v2_val\n"
                + "FROM " + project_id + "_raob d ,stations s WHERE d.stat_id=s.stat_id AND d.ob_date\n"
                + "BETWEEN '" + year_start + "-" + month_start + "-" + day_start 
                + " " + hs + ":00:00' AND '" + year_end + "-" + month_end + "-" + day_end + " " + he + ":00:00'\n" 
                + "AND (d.v1_id='T_OBS_M' OR d.v2_id='T_MOD_M') AND d.plevel " + "BETWEEN " + layer_lower + " AND " + layer_upper + "\n" 
                + "AND (s.lat BETWEEN " + lat_south + " AND " + lat_north + " AND s.lon BETWEEN " + lon_west + " AND " + lon_east + ")\n"
                + "ORDER BY stat_id";
        }
        else if ("Upper-Air: Mandatory Profile Statistics".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "SELECT s.stat_id, s.lat, s.lon, YEAR(d.ob_date), MONTH(d.ob_date), DAY(d.ob_date), HOUR(d.ob_date), d.plevel, d.v1_id, d.v1_val, d.v2_id, d.v2_val\n"
                + "FROM " + project_id + "_raob d ,stations s WHERE d.stat_id=s.stat_id AND d.ob_date\n"
                + "BETWEEN '" + year_start + "-" + s_month_start + "-" + s_day_start 
                + " " + hs + ":00:00' AND '" + year_end + "-" + month_end + "-" + day_end + " " + he + ":00:00' AND HOUR(d.ob_date)=0\n" 
                + "AND (d.v1_id='T_OBS_M' OR d.v2_id='T_MOD_M') AND d.stat_id='" + siteid + "'\n"
                + "ORDER BY stat_id, ob_date, plevel"; 
        }
        else if ("Upper-Air: Mandatory Curtain".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "SELECT s.stat_id, s.lat, s.lon, YEAR(d.ob_date), MONTH(d.ob_date), DAY(d.ob_date), HOUR(d.ob_date), d.plevel, d.v1_id, d.v1_val, d.v2_id, d.v2_val\n"
                + "FROM " + project_id + "_raob d ,stations s WHERE d.stat_id=s.stat_id AND d.ob_date\n"
                + "BETWEEN '" + year_start + "-" + month_start + "-" + day_start 
                + " " + hs + ":00:00' AND '" + year_end + "-" + month_end + "-" + day_end + " " + he + ":00:00' AND HOUR(d.ob_date)=0\n" 
                + "AND (d.v1_id='T_OBS_M' OR d.v2_id='T_MOD_M') AND d.stat_id='" + siteid + "'\n"
                + "ORDER BY stat_id, ob_date, plevel";
        }
        else if ("Upper-Air: Native Theta / RH Profiles".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "SELECT s.stat_id, YEAR(d.ob_date), MONTH(d.ob_date), DAY(d.ob_date), HOUR(d.ob_date), plevel, v1_id, v1_val, v2_id, v2_val\n"
                + "FROM " + project_id + "_raob WHERE ob_date='" + year_start + "-" + month_start + "-" + day_start + " " + hs + ":00:00'\n"
                + "AND (v1_id='T_OBS_M' OR v2_id='T_MOD_M') AND plevel " + "BETWEEN " + layer_lower + " AND " + layer_upper + "\n" 
                + "ORDER BY plevel";
        }
        else if ("Upper-Air: Native Curtain".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "SELECT s.stat_id, YEAR(d.ob_date), MONTH(d.ob_date), DAY(d.ob_date), HOUR(d.ob_date), plevel, v1_id, v1_val, v2_id, v2_val\n"
                + "FROM " + project_id + "_raob WHERE ob_date='" + year_start + "-" + month_start + "-" + day_start + " " + hs + ":00:00'\n"
                + "AND (v1_id='T_OBS_M' OR v2_id='T_MOD_M') AND plevel " + "BETWEEN " + layer_lower + " AND " + layer_upper + "\n" 
                + "ORDER BY plevel"; 
        }
        else {
            query = "";
        }
        
        if (null == ProgramComboBox.getSelectedItem().toString()) {
            amet_static = "";
        }
        else //Sets amet_static for different plot types
        switch (ProgramComboBox.getSelectedItem().toString()) {
            case "Upper-Air: Spatial, Profile, Time Series and Curtain":
                amet_static = "/raob.static.input";
                break;
            case "Upper-Air: Mandatory Spatial Statistics":
                amet_static = "/raob.static.input";
                break;
            case "Upper-Air: Mandatory Time Series Statistics":
                amet_static = "/raob.static.input";
                break;
            case "Upper-Air: Mandatory Profile Statistics":
                amet_static = "/raob.static.input";
                break;
            case "Upper-Air: Mandatory Curtain":
                amet_static = "/raob.static.input";
                break;
            case "Upper-Air: Native Theta / RH Profiles":
                amet_static = "/raob.static.input";
                break;
            case "Upper-Air: Native Curtain":
                amet_static = "/raob.static.input";
                break;
            case "Spatial Statistics: 2-m Temp, 2-m Moisture and 10-m Wind":
                amet_static = "/spatial_surface.static.input";
                break;
            case "Time Series: 2-m Temp, 2-m Moisture and 10-m Wind":
                amet_static = "/timeseries.static.input";
                break;
            case "Time Series: 2-m Temp, 2-m Moisture, 2-m RH and Sfc Pressure":
                amet_static = "/timeseries.static.input";
                break;
            case "Shortwave Radiation Statistics: Spatial, Diurnal and Time Series":
                amet_static = "/plot_radiation.static.input";
                break;
            default:
                amet_static = "";
                break;
        }
    System.out.println(amet_static);
    
    //Sets script_wrapper for different plot types
    switch (ProgramComboBox.getSelectedItem().toString()) {
            case "Upper-Air: Spatial, Profile, Time Series and Curtain":
                script_wrapper = "UA";
                break;
            case "Upper-Air: Mandatory Spatial Statistics":
                script_wrapper = "UA";
                break;
            case "Upper-Air: Mandatory Time Series Statistics":
                script_wrapper = "UA";
                break;
            case "Upper-Air: Mandatory Profile Statistics":
                script_wrapper = "UA";
                break;
            case "Upper-Air: Mandatory Curtain":
                script_wrapper = "UA";
                break;
            case "Upper-Air: Native Theta / RH Profiles":
                script_wrapper = "UA";
                break;
            case "Upper-Air: Native Curtain":
                script_wrapper = "UA";
                break;
            case "Spatial Statistics: 2-m Temp, 2-m Moisture and 10-m Wind":
                script_wrapper = "SP";
                break;
            case "Summary Statistics: 2-m Temp, 2-m Moisture and 10-m Wind":
                script_wrapper = "SM";
                break;
            case "Daily Statistics: 2-m Temp, 2-m Moisture and 10-m Wind":
                script_wrapper = "DB";
                break;
            case "Shortwave Radiation Statistics: Spatial, Diurnal and Time Series":
                script_wrapper = "SW";
                break;
            default:
                script_wrapper = "";
                break;
        }
        System.out.println(script_wrapper);

    }
   
    public void popupWindow(){
        if (MonthlyAnalysisCheckBox.isSelected()){
                WrapperPopUpWindow wpuw = new WrapperPopUpWindow(file_path);
                wpuw.setVisible(true);
            }
        
    }
    
     //Checks variables for common errors
    public boolean checkVariables() {
        boolean hasError = false;
        String error = "You must provide a response for the following fields: ";
        //Check if database is selected
        if (dbase.equals("Choose a Database")) { 
            error = error + "\n- Database"; 
            hasError = true; 
        }
        //Check if project is selected
        if (project_id.equals("<Select a Database First>") || project_id.isEmpty() || project_id.equals("Choose a Project")) { 
            error = error + "\n- Project"; 
            hasError = true; 
        }
        //Check if program is selected
        if (run_program.equals("Choose AMET Script to Execute") || run_program.isEmpty() || ProgramComboBox.getSelectedItem().toString().equals(" ")) { 
            error = error + "\n- Evaluation Script"; 
            hasError = true; 
        }
        //Check if start_date is greater than end_date
        if (start_year > end_year) {
            error = "The start date entered occurs before the end date. This needs to be corrected before the analyses are ran or no output will be generated.\n"
                    + "\n Start Date: " + month_start + "/" + day_start + "/" + year_start
                    + "\n End Date:   " + month_end + "/" + day_end + "/" + year_end;
            hasError = true;
        }
        if (start_year == end_year && start_month > end_month) {
            error = "The start date entered occurs before the end date. This needs to be corrected before the analyses are ran or no output will be generated.\n"
                    + "\n Start Date: " + month_start + "/" + day_start + "/" + year_start
                    + "\n End Date:   " + month_end + "/" + day_end + "/" + year_end;
            hasError = true;
        }
        if (start_year == end_year && start_month == end_month && start_day > end_day) {
            error = "The start date entered occurs before the end date. This needs to be corrected before the analyses are ran or no output will be generated.\n"
                    + "\n Start Date: " + month_start + "/" + day_start + "/" + year_start
                    + "\n End Date:   " + month_end + "/" + day_end + "/" + year_end;
            hasError = true;
        }
               
        if (hasError) {
            errorWindow("Input Error", error);
            return true;
        } else {
            return false;
        }
    }
    
    //Creates run_info.r file used by r scripts
    public void createRunInfo() {
        System.out.println(config.cache_amet + "/" + "run_info_files" + "/" + run_info);
        NewFile file = new NewFile(true, config.cache_amet + "/" + "run_info_files" + "/" + run_info);
        file.openWriter();
        file.writeTo(""
                + "###  Consolidated R input settings file for Meteorology scripts ###\n"
                + "###  Combined for universal input to AMET GUI method of running analysis scripts ###\n"
                + "### daily_barplot, radiation, raob, spatial_surface, summary, timeseries, timeseries_rh ###\n"
                + "\n"
                + "# Main settings for timeseries #\n"
                + "project    <- " + run_name1 + "\n"
                + "project2   <- " + run_name2 + "\n"
                + "project1   <- project" + "\n"
                + "model      <- project" + "\n"
                + "model1     <- project" + "\n"
                + "model2     <- project2" + "\n"
                + "saveid     <- project" + "\n"
                //+ "statid     <- " + site_id + "\n"
                //+ "statid     <- c(" + site_id + ")\n"
                + "statid     <-unlist(strsplit(Sys.getenv(\"AMET_SITEID\"),\" \"))\n"
                + "\n"
                + "# Extra label to distinguish plots and out files (daily barplot) #\n"
                + "runid      <-" + "\"" + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + "\"" + "\n"
                + "pid        <- runid\n"
                + "queryID    <- pid\n"
                + "figid_sub  <- runid\n"
                + "\n"
                + "# Plot and figure output directory #\n"
                + "figdir     <- " + figdir + "\n"
                + "savedir    <- " + figdir + "\n"
                + "\n"
                + "# Maximum records allowed from database #\n"
                + "maxrec     <- " + max_rec + "\n"
                + "\n"
                + "# Logical controls #\n"
                + "savefile   <- " + save_file + "\n"
                + "textout    <- " + text_out + "\n"
                + "textstats  <- textout\n" 
                + "wantsave   <- savefile\n"
                + "wdweightws <- " + wd_weight_ws + "\n"
                + "groupstat  <- " + group_stat + "\n"
                + "comp       <- " + comp + "\n"
                + "ametp      <- " + ametp + "\n"
                + "diurnal    <- " + diurnal + "\n"
                + "spatial    <- " + spatial + "\n"
                + "timeseries <- " + time_series + "\n"
                + "histogram  <- " + histogram + "\n"
                + "SPATIALM   <- " + spatial_m + "\n"
                + "TSERIESM   <- " + t_series_m + "\n"
                + "PROFM      <- " + prof_m + "\n"
                + "CURTAINM   <- " + curtain_m +"\n"
                + "PROFN      <- " + prof_n + "\n"
                + "CURTAINN   <- " + curtain_n +"\n"
                + "\n"
                + "# Logicals for spatial surface statistics #\n"
                + "histplot     <- " + hist_plot + "\n" 
                + "shadeplot    <- " + shade_plot + "\n"
                + "daily        <- " + daily + "\n"
                + "wantfigs     <- " + want_figs + "\n"
                + "checksave    <- " + check_save + "\n"
                + "t.test.flag  <- " + t_test_flag + "\n"
                + "\n"
                + "# Threshold count for computing statistics #\n"
                + "thresh       <- " + thresh + "\n"
                + "\n"
                + "# Specific query for daily barplot #\n"
                + "querystr    <- \" AND ob_date BETWEEN " + year_start + month_start + day_start + " AND " + year_end + month_end + day_end  + " ORDER BY ob_date" + query_string + "\"\n"
                + "# Specific query for summary plots #\n"
                + "query_str   <- \" AND ob_date BETWEEN " + year_start + month_start + day_start + " AND " + year_end + month_end + day_end + query_string + "\"\n"
                + "\n"
                + "# Fine-tune query extra specs #\n"
                + "extra      <- " + "\"" + extra + "\"" + "\n"
                + "extra2     <- " + "\"" + extra2 + "\"" + "\n"
                + "\n"
                + "# Date-based specs #\n"
                + "date <- c(" +  year_start + month_start + day_start + "," + year_end + month_end + day_end + ")\n"
                + "hs   <- " + hs + "\n"
                + "he   <- " + he + "\n"
                + "ds   <- " + day_start + "\n"
                + "de   <- " + day_end + "\n"
                + "ms   <- " + month_start + "\n"
                + "me   <- " + month_end + "\n"
                + "ys   <- " + year_start + "\n"
                + "ye   <- " + year_end + "\n"
                + "dates<-list(y=ys,m=ms,d=ds,h=hs)\n"
                + "datee<-list(y=ye,m=me,d=de,h=he)\n"
                + "\n"
                + "window    <- " + window + "\n"
                + "\n"
                + "# Spatial statistics plotting bounds (latSouth, latNorth, longWest, longEast) #\n"
                + "lats      <- " + lat_south + "\n"
                + "latn      <- " + lat_north + "\n"
                + "lonw      <- " + lon_west + "\n"
                + "lone      <- " + lon_east + "\n"
                + "bounds <- c(lats,latn,lonw,lone)\n"
                + "\n"
                + "# Plot settings #\n"
                + "plotsize  <- " + plot_size + "\n"
                + "plotfmt   <- \"" + plot_format + "\"\n"
                + "symb      <- " + symbol + "\n"
                + "symbo     <- " + symbol2 + "\n"
                + "symbsiz   <- " + symbol_scale_factor + "\n"
                + "scex      <- " + stat_text_scale_factor + "\n"
                + "pheight   <- " + img_height + "\n"
                + "pwidth    <- " + img_width + "\n"
                + "sres      <- " + sres + "\n"
                + "\n"
                + "plotopts   <-list(figdir=figdir, plotsize=plotsize, plotfmt=plotfmt, symb=symb,symbo=symbo, symbsiz=symbsiz, pheight=pheight, pwidth=pwidth, project=project, bounds=bounds)\n"
                + "\n"
                + "# GROSS QC/QA limits for T (K), WS (m/s), and Q (g/kg): Min, Max #\n"
                + "qcT        <-c(" + qc_temp_limit_lower + "," + qc_temp_limit_upper + ")\n"
                + "qcQ        <-c(" + qc_moisture_limit_lower + "," + qc_moisture_limit_upper + ")\n"
                + "qcWS       <-c(" + qc_wind_limit_lower + "," + qc_wind_limit_upper + ")\n"
                + "qcRH       <-c(" + qc_humidity_limit_lower + "," + qc_humidity_limit_upper + ")\n"
                + "qcPS       <-c(" + qc_pressure_limit_lower + "," + qc_pressure_limit_upper + ")\n"
                + "qclims  <-list(qcT=qcT,qcQ=qcQ,qcWS=qcWS,qcRH=qcRH,qcPS=qcPS)" + "\n"
                + "\n"
                + "# QC limits on max difference between Model and Obs as another filter #\n"
                + "# value assignment is T, WS, Q, RH  -- SI units #\n"
                + "qcerror    <- c(" + qc_error_temp + "," + qc_error_wind + "," + qc_error_moisture + "," + qc_error_humidity + ")\n"
                + "\n"
               // + "# Intervals over the sunlight hours to average statistics #\n"
               // + "delt       <- " + delt + "\n"
                + "\n"
                + "# Summary plot index loc of required stats from query #\n"
                + "dstatloc   <-c(16,17,18)\n"
                + "\n"
                + "# RAOB: Pressure layer range for RAOB DATA EXTRACTION #\n"
                + "layer      <- c(" + layer_lower + "," + layer_upper + ")\n"
                + "\n"
                + "# RAOB: Pressure layer range for RAOB PLOTTING #\n"
                + "proflim    <- c(" + proflim_lower + "," + proflim_upper + ")\n"
                + "\n"
                + "# RAOB: Sample size threshold of 5 samples for spatial layer average statistics #\n"
                + "spatial.thresh   <- " + spatial_thresh + "\n"
                + "\n"
                + "# RAOB: Sample size threshold for pressure level statistics #\n"
                + "level.thresh     <- " + level_thresh + "\n"
                + "\n"
                + "# RAOB: Sample size theshold for number of sounding #\n"
                + "sounding.thresh  <- " + sounding_thresh + "\n"
                + "\n"
                + "# RAOB: Sample size threshold for minimum layers needed for native profile plot #\n"
                + "profilen.thresh  <- " + profilen_thresh + "\n"
                + "\n"
                + "# RAOB: Configurable range for differnece *PLOT* range (Native Curtain plots) #\n"
                + "# Note diff.t 5 is -5 to +5 diff range #\n"
                + "use.user.range   <- " + use_user_range + "\n"
                + "diff.t           <- " + diff_t + "\n"
                + "diff.rh          <- " + diff_rh + "\n"
                + "user.custom.plot.settings   <- list(use.user.range=use.user.range, diff.t=diff.t, diff.rh=diff.rh)\n"
                + "\n"
                + "# Summary plot labels #\n"
                + "stat_id     <- " + stat_id + "\n"
                + "obnetwork   <- " + ob_network + "\n"
                + "lat         <- " + lat + "\n"
                + "lon         <- " + lon + "\n"
                + "elev        <- " + elev + "\n"
                + "landuse     <- " + landuse + "\n"
                + "date_s      <- " + date_s + "\n"
                + "date_e      <- " + date_e + "\n"
                + "obtime      <- " + ob_time + "\n"
                + "fcasthr     <- " + fcast_hr + "\n"
                + "level       <- " + level + "\n"
                + "syncond     <- " + syncond + "\n"
                + "figure      <- " + figure + "\n"
                + "\n"
                + "# Levels for Shortwave radiation Metrics Bias, RMSE, Mean Abs Error and St.Dev #\n"
                + "levsBIAS    <- c(" + bias_level1 + "," + bias_level2 + "," + bias_level3 + "," + bias_level4 + "," + bias_level5 + "," + bias_level6 + "," + bias_level7 + "," + bias_level8 + "," + bias_level9 + "," + bias_level10 + "," + bias_level11 + "," + bias_level12 + "," + bias_level13 + "," + bias_level14 + "," + bias_level15 + ")\n"
                + "levsRMSE    <- c(" + rmse_level1 + "," + rmse_level2 + "," + rmse_level3 + "," + rmse_level4 + "," + rmse_level5 + "," + rmse_level6 + "," + rmse_level7 + "," + rmse_level8 + "," + rmse_level9 + "," + rmse_level10 + "," + rmse_level11 + "," + rmse_level12 + "," + rmse_level13 + ")\n" 
                + "levsMAE     <- c(" + mae_level1 + "," + mae_level2 + "," + mae_level3 + "," + mae_level4 + "," + mae_level5 + "," + mae_level6 + "," + mae_level7 + "," + mae_level8 + "," + mae_level9 + "," + mae_level10 + "," + mae_level11 + ")\n" 
                + "levsSDEV    <- c(" + sdev_level1 + "," + sdev_level2 + "," + sdev_level3 + "," + sdev_level4 + "," + sdev_level5 + "," + sdev_level6 + "," + sdev_level7 + "," + sdev_level8 + "," + sdev_level9 + "," + sdev_level10 + "," + sdev_level11 + "," + sdev_level12 + "," + sdev_level13 + ")\n" 
                + "\n"
                /*+ "# R code to prep for MET_timeseries.R run #\n"
                + "statstr  <-paste(\" stat_id='\",statid,\"' \",sep=\"\")\n"
                + "table1   <-paste(model1,\"_surface\",sep=\"\")\n"
                + "table2   <-paste(model2,\"_surface\",sep=\"\")\n"
                + "if(model1 != model2 & model2 != \"\") { comp  <- T }\n"*/
                + "\n"
                + "## Advanced SPATIAL SURFACE statistics settings below. ##\n"
                + "\n"
                /*+ "# R code prep for MET_spatial_surface.R #\n"
                + "sfctable	<-paste(model,\"_surface\",sep=\"\")\n"
                + "\n"
                + "#########################################################################\n"
                + "#	Configurable Statistics Definitions                                   #\n"
                + "#########################################################################\n"
                + "#             1       2       3    4      5     6       7    8       9        10       11       12       13     14     15\n"
                + "statAbr <- c(" + stat_abr1 + "," + stat_abr2 + "," + stat_abr3 + "," + stat_abr4 + "," + stat_abr5 + "," + stat_abr6 + "," + stat_abr7 + "," + stat_abr8 + "," + stat_abr9 + "," + stat_abr10 + "," + stat_abr11 + "," + stat_abr12 + "," + stat_abr13 + "," + stat_abr14 + "," + stat_abr15 + ")\n"
                + "sfixed  <- c(6,8,3,2,5,7)\n"
                + "vfixed  <- c(1,2,3)\n"
                + "\n"
                + "# Various set-up definitions for main plot function #\n"
                + "plotlab      <- array(,)\n"
                + "statid_array       <- c(" + stat_id1 + "," + stat_id2 + "," + stat_id3 + "," + stat_id4 + "," + stat_id5 + "," + stat_id6 + "," + stat_id7 + "," + stat_id8 + "," + stat_id9 + "," + stat_id10 + "," + stat_id11 + "," +  stat_id12 + "," + stat_id13 + "," + stat_id14 + "," + stat_id15 + ")\n"
                + "varid_array        <- c(" + var_id1 + "," + var_id2 + "," + var_id3 + "," + var_id4 + ")\n"
                + "\n"
                + "statAbr      <- c(" + stat_abr1 + "," + stat_abr2 + "," + stat_abr3 + "," + stat_abr4 + "," + stat_abr5 + "," + stat_abr6 + "," + stat_abr7 + "," + stat_abr8 + "," + stat_abr9 + "," + stat_abr10 + "," + stat_abr11 + "," + stat_abr12 + "," + stat_abr13 + "," + stat_abr14 + "," + stat_abr15 + ")\n"
                + "varAbr       <- c(" + var_abr1 + "," + var_abr2 + "," + var_abr3 + "," + var_abr4 + ")\n"
                + "vget	       <- c(1,2,3,4)\n"
                + "sget	       <- c(3,6,7,8)\n"
                + "\n"
                + "convfactor <- c(1.8,1.94,1,1)\n"
                + "convfactor <- c(1,1,1,1)\n"
                + "\n"
                + "great   <- " + great_color + "\n"
                + "good    <- " + good_color + "\n"
                + "fair    <- " + fair_color + "\n"
                + "caut    <- " + caution_color + "\n"
                + "quest   <- " + questionable_color + "\n"
                + "bad     <- " + bad_color + "\n"
                + "\n"
                + "###############################################################\n"
                + "# Plotting Protocol defnitions (colors, scales, etc)          #\n" 
                + "# These are pretty esoteric. A user will have to read code    #\n"
                + "# to see how these are used. In general though, L* stands for #\n"
                + "# levels for each statistics and C* for corresponding color   #\n"
                + "###############################################################\n"
                + "\n"
                + "require(fields)\n" //need to load "fields" package or "tim.colors" breaks the code
                + "\n"
                + "levcols <- array(NA,c(length(statid_array),length(varid_array),20))\n"
                + "levs    <- array(NA,c(length(statid_array),length(varid_array),20))\n"
                + "\n"
                + "# Typical Error and bias range w/ color scale #\n"
                + "L1     <- c(seq(0.75,3,by=0.25),4,10)\n"
                + "L1     <- c(" + L1_error1 + "," + L1_error2 + "," + L1_error3 + "," + L1_error4 + "," + L1_error5 + "," + L1_error6 + "," + L1_error7 + "," + L1_error8 + "," + L1_error9 + "," + L1_error10 + "," + L1_error11 + "," + L1_error12 +")\n"
                + "C1     <- tim.colors(length(L1))\n"
                + "\n"
                + "L2     <- c(" + L2_error1 + "," + L2_error2 + "," + L2_error3 + "," + L2_error4 + "," + L2_error5 + "," + L2_error6 + "," + L2_error7 + "," + L2_error8 + "," + L2_error9 + "," + L2_error10 + "," + L2_error11 + "," + L2_error12 +")\n"
                + "C2     <- tim.colors(length(L2))\n"
                + "C2[length(L2)/2] <- great\n"
                + "\n"
                + "# Error and bias scale for wind direction #\n"
                + "L1wd   <- c(" + L1wd_error1 + "," + L1wd_error2 + "," + L1wd_error3 + "," + L1wd_error4 + "," + L1wd_error5 + "," + L1wd_error6 + "," + L1wd_error7 + "," + L1wd_error8 + "," + L1wd_error9 + "," + L1wd_error10 + "," + L1wd_error11 + "," + L1wd_error12 +")\n"
                + "C1wd   <- rev(rainbow(length(L1wd)))\n"
                + "\n"
                + "L2wd   <- c(" + L2wd_error1 + "," + L2wd_error2 + "," + L2wd_error3 + "," + L2wd_error4 + "," + L2wd_error5 + "," + L2wd_error6 + "," + L2wd_error7 + "," + L2wd_error8 + "," + L2wd_error9 + ")\n"
                + "C2wd   <- rev(rainbow(length(L2wd)))\n"
                + "C2wd[(length(L2wd)/2)+1] <- great\n"
                + "\n"
                + "# Fractional and normalized scales #\n"
                + "L1n    <- c(" + L1n_error1 + "," + L1n_error2 + "," + L1n_error3 + "," + L1n_error4 + "," + L1n_error5 + ")\n"
                + "C1n    <- c(" + C1n_color1 + "," + C1n_color2 + "," + C1n_color3 + "," + C1n_color4 + "," + C1n_color5 + ")\n"
                + "L2n    <- c(" + L2n_error1 + "," + L2n_error2 + "," + L2n_error3 + "," + L2n_error4 + "," + L2n_error5 + "," + L2n_error6 + "," + L2n_error7 + "," + L2n_error8 + "," + L2n_error9 + ")\n" 
                + "C2n    <- c(" + C2n_color1 + "," + C2n_color2 + "," + C2n_color3 + "," + C2n_color4 + "," + C2n_color5 + "," + C2n_color6 + "," + C2n_color7 + "," + C2n_color8 + "," + C2n_color9 + ")\n"
                + "C2n    <- rev(rainbow(length(L2n)))\n"
                + "\n"
                + "# Typical range w/ color scale for Index of Agreement/Correlation Type plots #\n"
                + "L1iT   <- c(0.0,seq(0.5,1,by=0.05))\n"
                + "L1iW   <- c(" + L1iW_value1 + "," + L1iW_value2 + "," + L1iW_value3 + "," + L1iW_value4 + "," + L1iW_value5 + "," + L1iW_value6 + "," + L1iW_value7 + "," + L1iW_value8 + "," + L1iW_value9 + ")\n"
                + "L1iW   <- c(seq(0,1,by=0.1))\n"
                + "C1iT   <- tim.colors(length(L1iT))\n"
                + "C1iW   <- tim.colors(length(L1iW))\n"
                + "\n"
                + "##########################################################################\n"
                + "\n"
                + "     levs[1,,1]<-NA	# Set all count stats to NA (Plot Function will automatically set levels)\n"
                + "\n"
                + "##########################################################################\n"
                + "# 	Define Temperature Stat levels and colorscale                        #\n"
                + "##########################################################################\n"
                + "     levs[2,1,1:length(L1iT)]<-L1iT;   levcols[2,1,1:length(C1iT)]<-C1iT\n"
                + "     levs[3,1,1:length(L1iT)]<-L1iT;   levcols[3,1,1:length(C1iT)]<-C1iT\n"
                + "\n"
                + "     levs[4,1,1:length(L1)]<-L1;       levcols[4,1,1:length(C1)]<-C1\n"
                + "     levs[5,1,1:length(L1)]<-L1;       levcols[5,1,1:length(C1)]<-C1\n"
                + "     levs[6,1,1:length(L1)]<-L1;       levcols[6,1,1:length(C1)]<-C1\n"
                + "     levs[7,1,1:length(L1)]<-L1;       levcols[7,1,1:length(C1)]<-C1\n"
                + "     levs[8,1,1:length(L2)]<-L2;       levcols[8,1,1:length(C2)]<-C2\n"
                + "\n"
                + "     levs[9,1,1:length(L1n)]<-L1n;     levcols[9,1,1:length(C1n)]<-C1n\n"
                + "     levs[10,1,1:length(L2n)]<-L2n;    levcols[10,1,1:length(C2n)]<-C2n\n"
                + "     levs[11,1,1:length(L1n)]<-L1n;    levcols[11,1,1:length(C1n)]<-C1n\n"
                + "     levs[12,1,1:length(L2n)]<-L2n;    levcols[12,1,1:length(C2n)]<-C2n\n"
                + "     levs[13,1,1:length(L1n)]<-L1n;    levcols[13,1,1:length(C1n)]<-C1n\n"
                + "     levs[14,1,1:length(L2)]<-L2;      levcols[14,1,1:length(C2)]<-C2\n"
                + "     levs[15,1,1:length(L2)]<-L2;      levcols[15,1,1:length(C2)]<-C2\n"
                + "\n"
                + "##########################################################################\n"
                + "# 	Define Wind Speed Stat levels and colorscale                         #\n"
                + "##########################################################################\n"
                + "     levs[2,2,1:length(L1iW)]<-L1iW;   levcols[2,2,1:length(C1iW)]<-C1iW\n"
                + "     levs[3,2,1:length(L1iW)]<-L1iW;   levcols[3,2,1:length(C1iW)]<-C1iW\n"
                + "\n"
                + "     levs[4,2,1:length(L1)]<-L1;       levcols[4,2,1:length(C1)]<-C1\n"
                + "     levs[5,2,1:length(L1)]<-L1;       levcols[5,2,1:length(C1)]<-C1\n"
                + "     levs[6,2,1:length(L1)]<-L1;       levcols[6,2,1:length(C1)]<-C1\n"
                + "     levs[7,2,1:length(L1)]<-L1;       levcols[7,2,1:length(C1)]<-C1\n"
                + "     levs[8,2,1:length(L2)]<-L2;       levcols[8,2,1:length(C2)]<-C2\n"
                + "\n"
                + "     levs[9,2,1:length(L1n)]<-L1n;     levcols[9,2,1:length(C1n)]<-C1n\n"
                + "     levs[10,2,1:length(L2n)]<-L2n;    levcols[10,2,1:length(C2n)]<-C2n\n"  
                + "     levs[11,2,1:length(L1n)]<-L1n;    levcols[11,2,1:length(C1n)]<-C1n\n"
                + "     levs[12,2,1:length(L2n)]<-L2n;    levcols[12,2,1:length(C2n)]<-C2n\n"
                + "     levs[13,2,1:length(L1n)]<-L1n;    levcols[13,2,1:length(C1n)]<-C1n\n"
                + "     levs[14,2,1:length(L2)]<-L2;      levcols[14,2,1:length(C2)]<-C2\n"
                + "     levs[15,2,1:length(L2)]<-L2;      levcols[15,2,1:length(C2)]<-C2\n"
                + "\n"
                + "##########################################################################\n"
                + "# 	Define Wind Direction Stat levels and colorscale                     #\n"
                + "##########################################################################\n"
                + "     levs[2,3,1:length(L1iW)]<-L1iW;   levcols[2,3,1:length(C1iW)]<-C1iW\n"
                + "     levs[3,3,1:length(L1iW)]<-L1iW;   levcols[3,3,1:length(C1iW)]<-C1iW\n"
                + "\n"
                + "     levs[4,3,1:length(L1wd)]<-L1wd;   levcols[4,3,1:length(C1wd)]<-C1wd\n"
                + "     levs[5,3,1:length(L1wd)]<-L1wd;   levcols[5,3,1:length(C1wd)]<-C1wd\n"
                + "     levs[6,3,1:length(L1wd)]<-L1wd;   levcols[6,3,1:length(C1wd)]<-C1wd\n"
                + "     levs[7,3,1:length(L1wd)]<-L1wd;   levcols[7,3,1:length(C1wd)]<-C1wd\n"
                + "     levs[8,3,1:length(L2wd)]<-L2wd;   levcols[8,3,1:length(C2wd)]<-C2wd\n"
                + "\n"
                + "     levs[9,3,1:length(L1n)]<-L1n;     levcols[9,3,1:length(C1n)]<-C1n\n"
                + "     levs[10,3,1:length(L2n)]<-L2n;    levcols[10,3,1:length(C2n)]<-C2n\n"
                + "     levs[11,3,1:length(L1n)]<-L1n;    levcols[11,3,1:length(C1n)]<-C1n\n"
                + "     levs[12,3,1:length(L2n)]<-L2n;    levcols[12,3,1:length(C2n)]<-C2n\n"
                + "     levs[13,3,1:length(L1n)]<-L1n;    levcols[13,3,1:length(C1n)]<-C1n\n"
                + "     levs[14,3,1:length(L2wd)]<-L2wd;  levcols[14,3,1:length(C2wd)]<-C2wd\n"
                + "     levs[15,3,1:length(L2wd)]<-L2wd;  levcols[15,3,1:length(C2wd)]<-C2wd\n"
                + "\n"
                + "##########################################################################\n"
                + "# 	Define Mixing Ratio Stat levels and colorscale                       #\n"
                + "##########################################################################\n"
                + "     levs[2,4,1:length(L1iT)]<-L1iT;   levcols[2,4,1:length(C1iT)]<-C1iT\n"
                + "     levs[3,4,1:length(L1iT)]<-L1iT;   levcols[3,4,1:length(C1iT)]<-C1iT\n"
                + "\n"
                + "     levs[4,4,1:length(L1)]<-L1;       levcols[4,4,1:length(C1)]<-C1\n"
                + "     levs[5,4,1:length(L1)]<-L1;       levcols[5,4,1:length(C1)]<-C1\n"
                + "     levs[6,4,1:length(L1)]<-L1;       levcols[6,4,1:length(C1)]<-C1\n"
                + "     levs[7,4,1:length(L1)]<-L1;       levcols[7,4,1:length(C1)]<-C1\n"
                + "     levs[8,4,1:length(L2)]<-L2;       levcols[8,4,1:length(C2)]<-C2\n"
                + "\n"
                + "     levs[9,4,1:length(L1n)]<-L1n;     levcols[9,4,1:length(C1n)]<-C1n\n"
                + "     levs[10,4,1:length(L2n)]<-L2n;    levcols[10,4,1:length(C2n)]<-C2n\n"
                + "     levs[11,4,1:length(L1n)]<-L1n;    levcols[11,4,1:length(C1n)]<-C1n\n"
                + "     levs[12,4,1:length(L2n)]<-L2n;    levcols[12,4,1:length(C2n)]<-C2n\n"
                + "     levs[13,4,1:length(L1n)]<-L1n;    levcols[13,4,1:length(C1n)]<-C1n\n"
                + "     levs[14,4,1:length(L2)]<-L2;      levcols[14,4,1:length(C2)]<-C2\n"
                + "     levs[15,4,1:length(L2)]<-L2;      levcols[15,4,1:length(C2)]<-C2\n"*/
                
        );
        file.closeWriter();
    }
    
    //Dynamically executes the r scripts
    public void executeProgram() {
        setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
            Process p = null;
            String os = System.getProperty("os.name").toLowerCase();
            System.out.println(os);
            if (os.contains("win")) {
                try {
                    p = Runtime.getRuntime().exec("cmd /c"
                            + "set AMETBASE=" + config.amet_base + "&& "
                            + "set AMETRINPUT=" + config.cache_amet + "\\run_info_MET.R&& "
                            + "setenv MYSQL_CONFIG " + config.mysql_config + "&& "
                            + "setenv AMET_OUT " + config.cache_amet + "&& " 
                                    
                            + "setenv AMET_DATABASE1 " + dbase + "&& "
                            + "setenv AMET_DATABASE2 " + dbase2 + "&& "
                            + "setenv MYSQL_SERVER " + mysql_server + "&&"
                            + config.rScript + " " + config.run_analysis + run_program + ">" + config.cache_amet + "\\R.SDOUT.txt"
                    );
                } catch (IOException e) {
                    errorWindow("IOExcpetion", "There was a problem in running R_analysis_code through the command prompt. This is usually a problem caused by incorect paths in the config file"); 
                }
            } else {
                try {
                    System.out.println("linux");
                    String sites = site_id.replace("\"","");
                    if (MonthlyAnalysisCheckBox.isSelected() || SeasonalAnalysisCheckBox.isSelected()){
                        p = Runtime.getRuntime().exec(new String[]{"csh","-c",""
                                + "setenv AMETBASE " + config.amet_base + "&& "
                                + "mkdir -p ./cache/guidir." + username + "."  + dir_name + "&&"
                                + "setenv AMETRINPUT " + config.cache_amet + "/" + "run_info_files" + "/" + run_info + "&& "
                                + "setenv MYSQL_CONFIG " + config.mysql_config + "&& "
                                + "setenv AMET_OUT " + config.dir_name + username + "."  + dir_name + "&& "
                                + "setenv AMETRSTATIC " + config.amet_static + amet_static + "&& "
                                + "setenv WRAPPER_RUNID " + script_wrapper + "." + analysis_wrapper + "&&"
                                + "set SITES=(" + sites + ")" + "&&"
                                + "setenv AMET_SITEID \"$SITES[*]\"" + "&& "

                                + "setenv AMET_DATABASE " + dbase + "&& "
                                + "setenv AMET_DATABASE1 " + dbase + "&& "
                                + "setenv AMET_DATABASE2 " + dbase2 + "&& "
                                + "setenv MYSQL_SERVER " + mysql_server + "&&"
                                + "setenv R_LIBS " + config.rLibs + "&& "
                                + config.rScript + " " + config.run_analysis + "MET_wrapper.R" + ">" + config.dir_name + username + "."  +  dir_name + "/R.SDOUT.txt"
                        });
                        
                    }
                    else {
                        p = Runtime.getRuntime().exec(new String[]{"csh","-c",""
                                + "setenv AMETBASE " + config.amet_base + "&& "
                                + "mkdir -p ./cache/guidir." + username + "."  + dir_name + "&&"
                                + "setenv AMETRINPUT " + config.cache_amet + "/" + "run_info_files" + "/" + run_info + "&& "
                                + "setenv MYSQL_CONFIG " + config.mysql_config + "&& "
                                + "setenv AMET_OUT " + config.dir_name + username + "."  + dir_name + "&& "
                                + "setenv AMETRSTATIC " + config.amet_static + amet_static + "&& "
                                + "set SITES=(" + sites + ")" + "&&"
                                + "setenv AMET_SITEID \"$SITES[*]\"" + "&& "

                                + "setenv AMET_DATABASE " + dbase + "&& "
                                + "setenv AMET_DATABASE1 " + dbase + "&& "
                                + "setenv AMET_DATABASE2 " + dbase2 + "&& "
                                + "setenv MYSQL_SERVER " + mysql_server + "&&"
                                + "setenv R_LIBS " + config.rLibs + "&& "
                                + config.rScript + " " + config.run_analysis + run_program + ">" + config.dir_name + username + "."  +  dir_name + "/R.SDOUT.txt"
                        });
                    }
                } catch (IOException e) {
                    errorWindow("IOExcpetion", "There was a problem in running R_analysis_code through the command prompt. This is usually a problem caused by incorect paths in the config file"); 
                }
            }
            System.out.println("Script is running...");
            //System.out.println(config.rLibs);
            
            //Prints cmd output if failed
        try {
            p.waitFor();
            final int exitValue = p.waitFor();
            if (exitValue == 0)
                System.out.println("Successfully executed the command: ");
            else {
                System.out.println("Failed to execute the following command: due to the following error(s):");
                try (final BufferedReader b = new BufferedReader(new InputStreamReader(p.getErrorStream()))) {
                    String line;
                    if ((line = b.readLine()) != null)
                        System.out.println(line);
                } catch (final IOException e) {
                    e.printStackTrace();
                }                
            }
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("End Execute Program");
        
        setCursor(Cursor.getPredefinedCursor(Cursor.DEFAULT_CURSOR));
    }
    
    
    
    //Displays the output
    public void outputWindow() {
        site = SiteIDTextField.getText();
        String prefix =  config.dir_name + username + "."  + dir_namex + "/" + project_id + "." + site + "." + year_start + month_start + day_start + "-" + year_end + month_end + day_end;
        String prefix2 = config.dir_name + username + "."  + dir_namex + "/" + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id;
        String prefix3 = config.dir_name + username + "."  + dir_namex + "/" + "srad.";
        String prefix4 = config.dir_name + username + "."  + dir_namex + "/" + project_id + ".";
        String prefix5 = config.dir_name + username + "."  + dir_namex + "/" + "raob.";
        String prefix_diag = config.dir_name + username + "."  + dir_namex + "/";
        String date_range = year_start + month_start + day_start + "-" + year_end + month_end + day_end;
        String date_range2 = year_start + month_start + day_start + "-" + year_end + month_end + day_end;
        String date_range3 = year_start + "-" + month_start + "-" + day_start + "_" + hs + ":" + "00" +  ":" + "00";

        OutputWindowMET output = new OutputWindowMET(this);
        
        System.out.println(run_program);
        
        switch(run_program) {
            case "MET_timeseries.R":
                output.newFile(prefix_diag + "R.SDOUT.txt", "Diagnostic File (txt)");
                output.newFile(prefix + ".time_series.Rdata", "Time Series Data (Rdata)");
                output.newFile(prefix + ".time_series.txt", "Time Series Data (txt)");
                output.newFile(prefix_diag + "R.SDOUT.txt"," ");
                
                output.newFile(prefix + ".time_series.pdf", site + " Time Series Plot (PDF)");
                output.newFile(prefix + ".time_series.png", site + " Time Series Plot (PNG)");
                if(site.contains(" ")){
                    String split[] = site.split(" ", 0);
                    for (String s: split)
                        output.newFile(config.dir_name + username + "."  + dir_namex + "/" + project_id + "." + s + "." + year_start + month_start + day_start + "-" + year_end + month_end + day_end + ".time_series.pdf", s + " Time Series Plot (PDF)");
                    for (String p: split)
                        output.newFile(config.dir_name + username + "."  + dir_namex + "/" + project_id + "." + p + "." + year_start + month_start + day_start + "-" + year_end + month_end + day_end + ".time_series.png", p + " Time Series Plot (PNG)");
                }
                output.newFile(config.dir_name + username + "."  + dir_namex + "/" + project_id + ".GROUP_AVG." + year_start + month_start + day_start + "-" + year_end + month_end + day_end + ".time_series.pdf", "Group Average Time Series Plot (PDF)");
                output.newFile(config.dir_name + username + "."  + dir_namex + "/" + project_id + ".GROUP_AVG." + year_start + month_start + day_start + "-" + year_end + month_end + day_end + ".time_series.png", "Group Average Time Series Plot (PNG)");
                break;
            case "MET_timeseries_rh.R":
                output.newFile(prefix_diag + "R.SDOUT.txt", "Diagnostic File (txt)");
                output.newFile(prefix + ".time_series_RH.Rdata", "Time Series Data (Rdata)");
                output.newFile(prefix + ".time_series_RH.txt", "Time Series Data (txt)");
                output.newFile(prefix_diag + "R.SDOUT.txt"," ");
                
                output.newFile(prefix + ".time_series_RH.pdf", site + " Time Series Plot (PDF)");
                output.newFile(prefix + ".time_series_RH.png", site + " Time Series Plot (PNG)");
                if(site.contains(" ")){
                    String split[] = site.split(" ", 0);
                    for (String s: split)
                        output.newFile(config.dir_name + username + "."  + dir_namex + "/" + project_id + "." + s + "." + year_start + month_start + day_start + "-" + year_end + month_end + day_end + ".time_series_RH.pdf", s + " Time Series Plot (PDF)");
                    for (String p: split)
                        output.newFile(config.dir_name + username + "."  + dir_namex + "/" + project_id + "." + p + "." + year_start + month_start + day_start + "-" + year_end + month_end + day_end + ".time_series_RH.png", p + " Time Series Plot (PNG)");
                }
                output.newFile(config.dir_name + username + "."  + dir_namex + "/" + project_id + ".GROUP_AVG." + year_start + month_start + day_start + "-" + year_end + month_end + day_end + ".time_series_RH.pdf", "Group Average Time Series Plot (PDF)");
                output.newFile(config.dir_name + username + "."  + dir_namex + "/" + project_id + ".GROUP_AVG." + year_start + month_start + day_start + "-" + year_end + month_end + day_end + ".time_series_RH.png", "Group Average Time Series Plot (PNG)");
                break;
            case "MET_daily_barplot.R":
                output.newFile(prefix_diag + "R.SDOUT.txt", "Diagnostic File (txt)");
                output.newFile(prefix2 + ".daily_barplot.Rdata", "Daily Bar Plot Data (Rdata)");
                output.newFile(prefix_diag + "R.SDOUT.txt"," ");
                
                output.newFile(prefix2 + ".T.daily_barplot_" + "RMSE.pdf", "Daily Bar Plot 2-m Temperature RMSE (PDF)");
                output.newFile(prefix2 + ".T.daily_barplot_" + "BIAS.pdf", "Daily Bar Plot 2-m Temperature BIAS (PDF)");
                output.newFile(prefix2 + ".T.daily_barplot_" + "CORR.pdf", "Daily Bar Plot 2-m Temperature CORR (PDF)");
                
                output.newFile(prefix2 + ".T.daily_barplot_" + "RMSE.png", "Daily Bar Plot 2-m Temperature RMSE (PNG)");
                output.newFile(prefix2 + ".T.daily_barplot_" + "BIAS.png", "Daily Bar Plot 2-m Temperature BIAS (PNG)");
                output.newFile(prefix2 + ".T.daily_barplot_" + "CORR.png", "Daily Bar Plot 2-m Temperature CORR (PNG)");
                output.newFile(prefix2 + ".T.daily_stats.csv", "Daily Statistics Temperature (csv)");
                output.newFile(prefix2 + ".T.daily_stats.csv"," ");
                
                output.newFile(prefix2 + ".Q.daily_barplot_" + "RMSE.pdf", "Daily Bar Plot 2-m Water Vapor Mixing Ratio RMSE (PDF)");
                output.newFile(prefix2 + ".Q.daily_barplot_" + "BIAS.pdf", "Daily Bar Plot 2-m Water Vapor Mixing Ratio BIAS (PDF)");
                output.newFile(prefix2 + ".Q.daily_barplot_" + "CORR.pdf", "Daily Bar Plot 2-m Water Vapor Mixing Ratio CORR (PDF)");
               
                output.newFile(prefix2 + ".Q.daily_barplot_" + "RMSE.png", "Daily Bar Plot 2-m Water Vapor Mixing Ratio RMSE (PNG)");
                output.newFile(prefix2 + ".Q.daily_barplot_" + "BIAS.png", "Daily Bar Plot 2-m Water Vapor Mixing Ratio BIAS (PNG)");
                output.newFile(prefix2 + ".Q.daily_barplot_" + "CORR.png", "Daily Bar Plot 2-m Water Vapor Mixing Ratio CORR (PNG)");
                output.newFile(prefix2 + ".Q.daily_stats.csv", "Daily Statistics Moisture (csv)");
                output.newFile(prefix2 + ".Q.daily_stats.csv"," ");
                
                output.newFile(prefix2 + ".WD.daily_barplot_" + "RMSE.pdf", "Daily Bar Plot 10-m Wind Direction RMSE (PDF)");
                output.newFile(prefix2 + ".WD.daily_barplot_" + "BIAS.pdf", "Daily Bar Plot 10-m Wind Direction BIAS (PDF)");
                output.newFile(prefix2 + ".WD.daily_barplot_" + "CORR.pdf", "Daily Bar Plot 10-m Wind Direction CORR (PDF)");
                
                output.newFile(prefix2 + ".WD.daily_barplot_" + "RMSE.png", "Daily Bar Plot 10-m Wind Direction RMSE (PNG)");
                output.newFile(prefix2 + ".WD.daily_barplot_" + "BIAS.png", "Daily Bar Plot 10-m Wind Direction BIAS (PNG)");
                output.newFile(prefix2 + ".WD.daily_barplot_" + "CORR.png", "Daily Bar Plot 10-m Wind Direction CORR (PNG)");
                output.newFile(prefix2 + ".WD.daily_stats.csv", "Daily Statistics Wind Direction (csv)");
                output.newFile(prefix2 + ".WD.daily_stats.csv"," ");
                
                output.newFile(prefix2 + ".WS.daily_barplot_" + "RMSE.pdf", "Daily Bar Plot 10-m Wind Speed RMSE (PDF)");
                output.newFile(prefix2 + ".WS.daily_barplot_" + "BIAS.pdf", "Daily Bar Plot 10-m Wind Speed BIAS (PDF)");
                output.newFile(prefix2 + ".WS.daily_barplot_" + "CORR.pdf", "Daily Bar Plot 10-m Wind Speed CORR (PDF)");
                
                output.newFile(prefix2 + ".WS.daily_barplot_" + "RMSE.png", "Daily Bar Plot 10-m Wind Speed RMSE (PNG)");
                output.newFile(prefix2 + ".WS.daily_barplot_" + "BIAS.png", "Daily Bar Plot 10-m Wind Speed BIAS (PNG)");
                output.newFile(prefix2 + ".WS.daily_barplot_" + "CORR.png", "Daily Bar Plot 10-m Wind Speed CORR (PNG)");
                output.newFile(prefix2 + ".WS.daily_stats.csv", "Daily Statistics Wind Speed (csv)");
                output.newFile(prefix2 + ".WS.daily_stats.csv"," ");
                
                output.newFile(prefix2 + ".WNDVEC.daily_barplot_" + "ME.pdf", "Daily Bar Plot Wind Vector ME (PDF)");
                output.newFile(prefix2 + ".WNDVEC.daily_barplot_" + "ME.png", "Daily Bar Plot Wind Vector ME (PNG)");
                output.newFile(prefix2 + ".WNDVEC.daily_stats.csv", "Daily Statistics Wind Vector (csv)");
                break;
            case "MET_summary.R":
                output.newFile(prefix_diag + "R.SDOUT.txt", "Diagnostic File (txt)");
                output.newFile(config.dir_name + username + "."  + dir_namex + "/" + "stats." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".csv", "Summary Statistics Data (csv)");
                output.newFile(config.dir_name + username + "."  + dir_namex + "/" + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".web_query.Rdata", "Summary Statistics Data (Rdata)");
                output.newFile(prefix_diag + "R.SDOUT.txt", " ");
                
                output.newFile(prefix2 + ".T.ametplot.png", "Summary Statistics 2-m Temperature (PNG)");
                output.newFile(prefix2 + ".T.diurnal.png", "Diurnal Statistics 2-m Temperature (PNG)");
                output.newFile(prefix2 + ".T.ametplot.png", " ");
                
                output.newFile(prefix2 + ".T.ametplot.pdf", "Summary Statistics 2-m Temperature (PDF)");
                output.newFile(prefix2 + ".T.diurnal.pdf", "Diurnal Statistics 2-m Temperature (PDF)");
                output.newFile(prefix2 + ".T.ametplot.pdf", " ");
                
                output.newFile(prefix2 + ".Q.ametplot.png", "Summary Statistics 2-m Water Vapor Mixing Ratio (PNG)");
                output.newFile(prefix2 + ".Q.diurnal.png", "Diurnal Statistics 2-m Water Vapor Mixing Ratio (PNG)");
                output.newFile(prefix2 + ".Q.ametplot.png", " ");
                
                output.newFile(prefix2 + ".Q.ametplot.pdf", "Summary Statistics 2-m Water Vapor Mixing Ratio (PDF)");
                output.newFile(prefix2 + ".Q.diurnal.pdf", "Diurnal Statistics 2-m Water Vapor Mixing Ratio (PDF)");
                output.newFile(prefix2 + ".Q.ametplot.pdf", " ");
                
                output.newFile(prefix2 + ".WD.ametplot.png", "Summary Statistics 10-m Wind Direction (PNG)");
                output.newFile(prefix2 + ".WD.diurnal.png", "Diurnal Statistics 10-m Wind Direction (PNG)");
                output.newFile(prefix2 + ".WD.ametplot.png", " ");
                
                output.newFile(prefix2 + ".WD.ametplot.pdf", "Summary Statistics 10-m Wind Direction (PDF)");
                output.newFile(prefix2 + ".WD.diurnal.pdf", "Diurnal Statistics 10-m Wind Direction (PDF)");
                output.newFile(prefix2 + ".WD.ametplot.pdf", " ");
                
                output.newFile(prefix2 + ".WS.ametplot.png", "Summary Statistics 10-m Wind Speed (PNG)");
                output.newFile(prefix2 + ".WS.diurnal.png", "Diurnal Statistics 10-m Wind Speed (PNG)");
                
                output.newFile(prefix2 + ".WS.ametplot.pdf", "Diurnal Statistics 10-m Wind Speed (PDF)");
                output.newFile(prefix2 + ".WS.diurnal.pdf", "Diurnal Statistics 10-m Wind Speed (PDF)");
                break;
            case "MET_plot_radiation.R":
                output.newFile(prefix_diag + "R.SDOUT.txt", "Diagnostic File (txt)");
                output.newFile(config.dir_name + username + "."  + dir_namex + "/" + "BSRN.SITE.PLOT.pdf", "Plot of BSRN Sites (PDF)");
                output.newFile(prefix_diag + "R.SDOUT.txt", " ");
                
                output.newFile(prefix3 + "spatial.early-morning." + date_range + ".pdf", "Shortwave Radiation Spatial Plot Early Morning (PDF)");
                output.newFile(prefix3 + "spatial.mid-morning." + date_range + ".pdf", "Shortwave Radiation Spatial Plot Mid Morning (PDF)");
                output.newFile(prefix3 + "spatial.early-afternoon." + date_range + ".pdf", "Shortwave Radiation Spatial Plot Early Afternoon (PDF)");
                output.newFile(prefix3 + "spatial.late-afternoon." + date_range + ".pdf", "Shortwave Radiation Spatial Plot Late Afternoon (PDF)");
                output.newFile(prefix3 + "spatial.early-morning." + date_range + ".pdf", " ");
                
                output.newFile(prefix3 + "diurnal.bon." + date_range + ".pdf", "Shortwave Radiation Diurnal Plot BON (PDF)");
                output.newFile(prefix3 + "diurnal.dra." + date_range + ".pdf", "Shortwave Radiation Diurnal Plot DRA (PDF)");
                output.newFile(prefix3 + "diurnal.fpk." + date_range + ".pdf", "Shortwave Radiation Diurnal Plot FPK (PDF)");
                output.newFile(prefix3 + "diurnal.gwn." + date_range + ".pdf", "Shortwave Radiation Diurnal Plot GWN (PDF)");
                output.newFile(prefix3 + "diurnal.psu." + date_range + ".pdf", "Shortwave Radiation Diurnal Plot PSU (PDF)");
                output.newFile(prefix3 + "diurnal.sxf." + date_range + ".pdf", "Shortwave Radiation Diurnal Plot SXF (PDF)");
                output.newFile(prefix3 + "diurnal.tbl." + date_range + ".pdf", "Shortwave Radiation Diurnal Plot TBL (PDF)");
                output.newFile(prefix3 + "diurnal.bon." + date_range + ".pdf", " ");
                
                output.newFile(prefix3 + "histogram.bon." + date_range + ".pdf", "Shortwave Radiation Histogram BON (PDF)");
                output.newFile(prefix3 + "histogram.dra." + date_range + ".pdf", "Shortwave Radiation Histogram DRA (PDF)");
                output.newFile(prefix3 + "histogram.fpk." + date_range + ".pdf", "Shortwave Radiation Histogram FPK (PDF)");
                output.newFile(prefix3 + "histogram.gwn." + date_range + ".pdf", "Shortwave Radiation Histogram GWN (PDF)");
                output.newFile(prefix3 + "histogram.psu." + date_range + ".pdf", "Shortwave Radiation Histogram PSU (PDF)");
                output.newFile(prefix3 + "histogram.sxf." + date_range + ".pdf", "Shortwave Radiation Histogram SXF (PDF)");
                output.newFile(prefix3 + "histogram.tbl." + date_range + ".pdf", "Shortwave Radiation Histogram TBL (PDF)");
                output.newFile(prefix3 + "histogram.bon." + date_range + ".pdf", " ");
                
                output.newFile(prefix3 + "timeseries.bon." + date_range + ".pdf", "Shortwave Radiation Time Series Plot BON (PDF)");
                output.newFile(prefix3 + "timeseries.dra." + date_range + ".pdf", "Shortwave Radiation Time Series Plot DRA (PDF)");
                output.newFile(prefix3 + "timeseries.fpk." + date_range + ".pdf", "Shortwave Radiation Time Series Plot FPK (PDF)");
                output.newFile(prefix3 + "timeseries.gwn." + date_range + ".pdf", "Shortwave Radiation Time Series Plot GWN (PDF)");
                output.newFile(prefix3 + "timeseries.psu." + date_range + ".pdf", "Shortwave Radiation Time Series Plot PSU (PDF)");
                output.newFile(prefix3 + "timeseries.sxf." + date_range + ".pdf", "Shortwave Radiation Time Series Plot SXF (PDF)");
                output.newFile(prefix3 + "timeseries.tbl." + date_range + ".pdf", "Shortwave Radiation Time Series Plot TBL (PDF)");
                break;
            case "MET_spatial_surface.R":
                output.newFile(prefix_diag + "R.SDOUT.txt", "Diagnostic File (txt)");
                output.newFile(prefix4 + date_range + ".RData", "Surface Spatial Plot Data (Rdata)");
                output.newFile(prefix4 + "spatial." + "mixr2m" + ".stats." + date_range + ".csv", "Mixing Ratio 2-m Spatial Statistics (csv)");
                output.newFile(prefix4 + "spatial." + "temp2m" + ".stats." + date_range + ".csv", "Temperature 2-m Spatial Statistics (csv)");
                output.newFile(prefix4 + "spatial." + "wndspd10m" + ".stats." + date_range + ".csv", "Wind Speed 10-m Spatial Statistics (csv)");
                output.newFile(prefix4 + "spatial." + "wnddir10m" + ".stats." + date_range + ".csv", "Wind Direction 10-m Spatial Statistics (csv)");
                output.newFile(config.dir_name + username + "."  + dir_namex + "/" + "spatial.setSITES.all.txt", "Site ID List (txt)");
                output.newFile(prefix_diag + "R.SDOUT.txt", " ");
                
                output.newFile(prefix4 + "rmse." + "T." + date_range + ".pdf", "RMSE 2-m Temperature Spatial Plot (PDF)");
                output.newFile(prefix4 + "rmse." + "Q." + date_range + ".pdf", "RMSE 2-m Water Vapor Mixing Ratio Spatial Plot (PDF)");
                output.newFile(prefix4 + "rmse." + "WS." + date_range + ".pdf", "RMSE 10-m Wind Speed Spatial Plot (PDF)");
                output.newFile(prefix4 + "rmse." + "WD." + date_range + ".pdf", "RMSE 10-m Wind Direction Spatial Plot (PDF)");
                output.newFile(prefix4 + "rmse." + "T." + date_range + ".shade.pdf", "RMSE 2-m Temperature Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "rmse." + "Q." + date_range + ".shade.pdf", "RMSE 2-m Water Vapor Mixing Ratio Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "rmse." + "WS." + date_range + ".shade.pdf", "RMSE 10-m Wind Speed Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "rmse." + "WD." + date_range + ".shade.pdf", "RMSE 10-m Wind Direction Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "rmse." + "T." + date_range + ".hist.pdf", "RMSE 2-m Temperature Histogram (PDF)");
                output.newFile(prefix4 + "rmse." + "Q." + date_range + ".hist.pdf", "RMSE 2-m Water Vapor Mixing Ratio Histogram (PDF)");
                output.newFile(prefix4 + "rmse." + "WS." + date_range + ".hist.pdf", "RMSE 10-m Wind Speed Histogram (PDF)");
                output.newFile(prefix4 + "rmse." + "WD." + date_range + ".hist.pdf", "RMSE 10-m Wind Direction Histogram (PDF)");
                output.newFile(prefix4 + "rmse." + "T." + date_range + ".pdf", " ");
                
                output.newFile(prefix4 + "rmse." + "T." + date_range + ".png", "RMSE 2-m Temperature Spatial Plot (PNG)");
                output.newFile(prefix4 + "rmse." + "Q." + date_range + ".png", "RMSE 2-m Water Vapor Mixing Ratio Spatial Plot (PNG)");
                output.newFile(prefix4 + "rmse." + "WS." + date_range + ".png", "RMSE 10-m Wind Speed Spatial Plot (PNG)");
                output.newFile(prefix4 + "rmse." + "WD." + date_range + ".png", "RMSE 10-m Wind Direction Spatial Plot (PNG)");
                output.newFile(prefix4 + "rmse." + "T." + date_range + ".shade.png", "RMSE 2-m Temperature Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "rmse." + "Q." + date_range + ".shade.png", "RMSE 2-m Water Vapor Mixing Ratio Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "rmse." + "WS." + date_range + ".shade.png", "RMSE 10-m Wind Speed Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "rmse." + "WD." + date_range + ".shade.png", "RMSE 10-m Wind Direction Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "rmse." + "T." + date_range + ".hist.png", "RMSE 2-m Temperature Histogram (PNG)");
                output.newFile(prefix4 + "rmse." + "Q." + date_range + ".hist.png", "RMSE 2-m Water Vapor Mixing Ratio Histogram (PNG)");
                output.newFile(prefix4 + "rmse." + "WS." + date_range + ".hist.png", "RMSE 10-m Wind Speed Histogram (PNG)");
                output.newFile(prefix4 + "rmse." + "WD." + date_range + ".hist.png", "RMSE Win10-m Windd Direction Histogram (PNG)");
                output.newFile(prefix4 + "rmse." + "T." + date_range + ".png", " ");
                
                output.newFile(prefix4 + "bias." + "T." + date_range + ".pdf", "BIAS 2-m Temperature Spatial Plot (PDF)");
                output.newFile(prefix4 + "bias." + "Q." + date_range + ".pdf", "BIAS 2-m Water Vapor Mixing Ratio Spatial Plot (PDF)");
                output.newFile(prefix4 + "bias." + "WS." + date_range + ".pdf", "BIAS 10-m Wind Speed Spatial Plot (PDF)");
                output.newFile(prefix4 + "bias." + "WD." + date_range + ".pdf", "BIAS 10-m Wind Direction Spatial Plot (PDF)");
                output.newFile(prefix4 + "bias." + "T." + date_range + ".shade.pdf", "BIAS 2-m Temperature Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "bias." + "Q." + date_range + ".shade.pdf", "BIAS 2-m Water Vapor Mixing Ratio Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "bias." + "WS." + date_range + ".shade.pdf", "BIAS 10-m Wind Speed Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "bias." + "WD." + date_range + ".shade.pdf", "BIAS 10-m Wind Direction Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "bias." + "T." + date_range + ".hist.pdf", "BIAS 2-m Temperature Histogram (PDF)");
                output.newFile(prefix4 + "bias." + "Q." + date_range + ".hist.pdf", "BIAS 2-m Water Vapor Mixing Ratio Histogram (PDF)");
                output.newFile(prefix4 + "bias." + "WS." + date_range + ".hist.pdf", "BIAS 10-m Wind Speed Histogram (PDF)");
                output.newFile(prefix4 + "bias." + "WD." + date_range + ".hist.pdf", "BIAS 10-m Wind Direction Histogram (PDF)");
                output.newFile(prefix4 + "bias." + "T." + date_range + ".pdf", " ");
                
                output.newFile(prefix4 + "bias." + "T." + date_range + ".png", "BIAS 2-m Temperature Spatial Plot (PNG)");
                output.newFile(prefix4 + "bias." + "Q." + date_range + ".png", "BIAS 2-m Water Vapor Mixing Ratio Spatial Plot (PNG)");
                output.newFile(prefix4 + "bias." + "WS." + date_range + ".png", "BIAS 10-m Wind Speed Spatial Plot (PNG)");
                output.newFile(prefix4 + "bias." + "WD." + date_range + ".png", "BIAS 10-m Wind Direction Spatial Plot (PNG)");
                output.newFile(prefix4 + "bias." + "T." + date_range + ".shade.png", "BIAS 2-m Temperature Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "bias." + "Q." + date_range + ".shade.png", "BIAS 2-m Water Vapor Mixing Ratio Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "bias." + "WS." + date_range + ".shade.png", "BIAS 10-m Wind Speed Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "bias." + "WD." + date_range + ".shade.png", "BIAS 10-m Wind Direction Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "bias." + "T." + date_range + ".hist.png", "BIAS 2-m Temperature Histogram (PNG)");
                output.newFile(prefix4 + "bias." + "Q." + date_range + ".hist.png", "BIAS 2-m Water Vapor Mixing Ratio Histogram (PNG)");
                output.newFile(prefix4 + "bias." + "WS." + date_range + ".hist.png", "BIAS 10-m Wind Speed Histogram (PNG)");
                output.newFile(prefix4 + "bias." + "WD." + date_range + ".hist.png", "BIAS 10-m Wind10-m Wind Direction Histogram (PNG)");
                output.newFile(prefix4 + "bias." + "T." + date_range + ".png", " ");
                
                output.newFile(prefix4 + "mae." + "T." + date_range + ".pdf", "MAE 2-m Temperature Spatial Plot (PDF)");
                output.newFile(prefix4 + "mae." + "Q." + date_range + ".pdf", "MAE 2-m Water Vapor Mixing Ratio Spatial Plot (PDF)");
                output.newFile(prefix4 + "mae." + "WS." + date_range + ".pdf", "MAE 10-m Wind Speed Spatial Plot (PDF)");
                output.newFile(prefix4 + "mae." + "WD." + date_range + ".pdf", "MAE 10-m Wind Direction Spatial Plot (PDF)");
                output.newFile(prefix4 + "mae." + "T." + date_range + ".shade.pdf", "MAE 2-m Temperature Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "mae." + "Q." + date_range + ".shade.pdf", "MAE 2-m Water Vapor Mixing Ratio Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "mae." + "WS." + date_range + ".shade.pdf", "MAE 10-m Wind Speed Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "mae." + "WD." + date_range + ".shade.pdf", "MAE 10-m Wind Direction Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "mae." + "T." + date_range + ".hist.pdf", "MAE 2-m Temperature Histogram (PDF)");
                output.newFile(prefix4 + "mae." + "Q." + date_range + ".hist.pdf", "MAE 2-m Water Vapor Mixing Ratio Histogram (PDF)");
                output.newFile(prefix4 + "mae." + "WS." + date_range + ".hist.pdf", "MAE 10-m Wind Speed Histogram (PDF)");
                output.newFile(prefix4 + "mae." + "WD." + date_range + ".hist.pdf", "MAE 10-m Wind Direction Histogram (PDF)");
                output.newFile(prefix4 + "mae." + "T." + date_range + ".pdf", " ");
                
                output.newFile(prefix4 + "mae." + "T." + date_range + ".png", "MAE 2-m Temperature Spatial Plot (PNG)");
                output.newFile(prefix4 + "mae." + "Q." + date_range + ".png", "MAE 2-m Water Vapor Mixing Ratio Spatial Plot (PNG)");
                output.newFile(prefix4 + "mae." + "WS." + date_range + ".png", "MAE 10-m Wind Speed Spatial Plot (PNG)");
                output.newFile(prefix4 + "mae." + "WD." + date_range + ".png", "MAE 10-m Wind Direction Spatial Plot (PNG)");
                output.newFile(prefix4 + "mae." + "T." + date_range + ".shade.png", "MAE 2-m Temperature Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "mae." + "Q." + date_range + ".shade.png", "MAE 2-m Water Vapor Mixing Ratio Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "mae." + "WS." + date_range + ".shade.png", "MAE 10-m Wind Speed Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "mae." + "WD." + date_range + ".shade.png", "MAE 10-m Wind Direction Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "mae." + "T." + date_range + ".hist.png", "MAE 2-m Temperature Histogram (PNG)");
                output.newFile(prefix4 + "mae." + "Q." + date_range + ".hist.png", "MAE 2-m Water Vapor Mixing Ratio Histogram (PNG)");
                output.newFile(prefix4 + "mae." + "WS." + date_range + ".hist.png", "MAE 10-m Wind Speed Histogram (PNG)");
                output.newFile(prefix4 + "mae." + "WD." + date_range + ".hist.png", "MAE 10-m Wind Direction Histogram (PNG)");
                output.newFile(prefix4 + "mae." + "T." + date_range + ".png", " ");
                
                output.newFile(prefix4 + "ac." + "T." + date_range + ".pdf", "AC 2-m Temperature Spatial Plot (PDF)");
                output.newFile(prefix4 + "ac." + "Q." + date_range + ".pdf", "AC 2-m Water Vapor Mixing Ratio Spatial Plot (PDF)");
                output.newFile(prefix4 + "ac." + "WS." + date_range + ".pdf", "AC 10-m Wind Speed Spatial Plot (PDF)");
                output.newFile(prefix4 + "ac." + "WD." + date_range + ".pdf", "AC 10-m Wind Direction Spatial Plot (PDF)");
                output.newFile(prefix4 + "ac." + "T." + date_range + ".shade.pdf", "AC 2-m Temperature Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "ac." + "Q." + date_range + ".shade.pdf", "AC 2-m Water Vapor Mixing Ratio Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "ac." + "WS." + date_range + ".shade.pdf", "AC 10-m Wind Speed Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "ac." + "WD." + date_range + ".shade.pdf", "AC 10-m Wind Direction Shaded Statistic Plot (PDF)");
                output.newFile(prefix4 + "ac." + "T." + date_range + ".hist.pdf", "AC 2-m Temperature Histogram (PDF)");
                output.newFile(prefix4 + "ac." + "Q." + date_range + ".hist.pdf", "AC 2-m Water Vapor Mixing Ratio Histogram (PDF)");
                output.newFile(prefix4 + "ac." + "WS." + date_range + ".hist.pdf", "AC 10-m Wind Speed Histogram (PDF)");
                output.newFile(prefix4 + "ac." + "WD." + date_range + ".hist.pdf", "AC 10-m Wind Direction Histogram (PDF)");
                
                output.newFile(prefix4 + "ac." + "T." + date_range + ".png", "AC 2-m Temperature Spatial Plot (PNG)");
                output.newFile(prefix4 + "ac." + "Q." + date_range + ".png", "AC 2-m Water Vapor Mixing Ratio Spatial Plot (PNG)");
                output.newFile(prefix4 + "ac." + "WS." + date_range + ".png", "AC 10-m Wind Speed Spatial Plot (PNG)");
                output.newFile(prefix4 + "ac." + "WD." + date_range + ".png", "AC 10-m Wind Direction Spatial Plot (PNG)");
                output.newFile(prefix4 + "ac." + "T." + date_range + ".shade.png", "AC 2-m Temperature Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "ac." + "Q." + date_range + ".shade.png", "AC 2-m Water Vapor Mixing Ratio Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "ac." + "WS." + date_range + ".shade.png", "AC 10-m Wind Speed Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "ac." + "WD." + date_range + ".shade.png", "AC 10-m Wind Direction Shaded Statistic Plot (PNG)");
                output.newFile(prefix4 + "ac." + "T." + date_range + ".hist.png", "AC 2-m Temperature Histogram (PNG)");
                output.newFile(prefix4 + "ac." + "Q." + date_range + ".hist.png", "AC 2-m Water Vapor Mixing Ratio Histogram (PNG)");
                output.newFile(prefix4 + "ac." + "WS." + date_range + ".hist.png", "AC 10-m Wind Speed Histogram (PNG)");
                output.newFile(prefix4 + "ac." + "WD." + date_range + ".hist.png", "AC 10-m Wind Direction Histogram (PNG)");
                break;
            case "MET_raob.R":
                output.newFile(prefix_diag + "R.SDOUT.txt", "Diagnostic File (txt)");
                if(site.contains(" ")){
                    output.newFile(prefix_diag + "R.SDOUT.txt","Multiple sites selected, but only the first site's output listed below.");
                    output.newFile(prefix_diag + "R.SDOUT.txt","Users can copy all site data from the cache directory:");
                    output.newFile(prefix_diag + "R.SDOUT.txt",file_path);
                    String single_site = site.split(" ")[0];
                    site = single_site;
                }
                output.newFile(prefix_diag + "R.SDOUT.txt"," ");
                
                output.newFile(prefix5 + "spatial.RMSE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Temperature Root-Mean-Squared Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.RMSE.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Relative Humidity Root-Mean-Squared Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.RMSE.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Wind Speed Root-Mean-Squared Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.RMSE.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Wind Direction Root-Mean-Squared Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.RMSE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf"," ");
                
                output.newFile(prefix5 + "spatial.RMSE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Temperature Root-Mean-Squared Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.RMSE.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Relative Humidity Root-Mean-Squared Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.RMSE.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Wind Speed Root-Mean-Squared Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.RMSE.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Wind Direction Root-Mean-Squared Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.RMSE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png"," ");
                
                output.newFile(prefix5 + "spatial.BIAS.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Temperature Bias Plot (PDF)");
                output.newFile(prefix5 + "spatial.BIAS.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Relative Humidity Bias Plot (PDF)");
                output.newFile(prefix5 + "spatial.BIAS.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Wind Speed Bias Plot (PDF)");
                output.newFile(prefix5 + "spatial.BIAS.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Wind Direction Bias Plot (PDF)");
                output.newFile(prefix5 + "spatial.BIAS.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf"," ");
                
                output.newFile(prefix5 + "spatial.BIAS.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Temperature Bias Plot (PNG)");
                output.newFile(prefix5 + "spatial.BIAS.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Relative Humidity Bias Plot (PNG)");
                output.newFile(prefix5 + "spatial.BIAS.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Wind Speed Bias Plot (PNG)");
                output.newFile(prefix5 + "spatial.BIAS.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Wind Direction Bias Plot (PNG)");
                output.newFile(prefix5 + "spatial.BIAS.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png"," ");
                
                output.newFile(prefix5 + "spatial.MAE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Temperature Mean Absolute Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.MAE.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Relative Humidity Mean Absolute Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.MAE.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Wind Speed Mean Absolute Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.MAE.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Wind Direction Mean Absolute Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.MAE.WNDVEC." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Wind Vector Mean Absolute Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.MAE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf"," ");
                
                output.newFile(prefix5 + "spatial.MAE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Temperature Mean Absolute Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.MAE.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Relative Humidity Mean Absolute Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.MAE.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Wind Speed Mean Absolute Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.MAE.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Wind Direction Mean Absolute Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.MAE.WNDVEC." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Wind Vector Mean Absolute Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.MAE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png"," ");
                
                output.newFile(prefix5 + "spatial.CORR.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Temperature Anomaly Correlation Plot (PDF)");
                output.newFile(prefix5 + "spatial.CORR.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Relative Humidity Anomaly Correlation Plot (PDF)");
                output.newFile(prefix5 + "spatial.CORR.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Wind Speed Anomaly Correlation Plot (PDF)");
                output.newFile(prefix5 + "spatial.CORR.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Spatial Wind Direction Anomaly Correlation Plot (PDF)");
                output.newFile(prefix5 + "spatial.CORR.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf"," ");
                
                output.newFile(prefix5 + "spatial.CORR.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Temperature Anomaly Correlation Plot (PNG)");
                output.newFile(prefix5 + "spatial.CORR.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Relative Humidity Anomaly Correlation Plot (PNG)");
                output.newFile(prefix5 + "spatial.CORR.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Wind Speed Anomaly Correlation Plot (PNG)");
                output.newFile(prefix5 + "spatial.CORR.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Spatial Wind Direction Anomaly Correlation Plot (PNG)");
                output.newFile(prefix5 + "spatial.CORR.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png"," ");
                
                output.newFile(prefix5 + "spatial.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".csv", "Spatial Temperature Dataset (csv)");
                output.newFile(prefix5 + "spatial.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".csv", "Spatial Relative Humidity Dataset (csv)");
                output.newFile(prefix5 + "spatial.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".csv", "Spatial Wind Speed Dataset (csv)");
                output.newFile(prefix5 + "spatial.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".csv", "Spatial Wind Direction Dataset (csv)");
                output.newFile(prefix5 + "spatial.WNDVEC." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".csv", "Spatial Wind Vector Dataset (csv)");
                output.newFile(prefix5 + "spatial.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".csv"," ");
                
                output.newFile(prefix5 + "daily.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Time Series Daily Statistics Temperature Plot (PDF)");
                output.newFile(prefix5 + "daily.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Time Series Daily Statistics Relative Humidity Plot (PDF)");
                output.newFile(prefix5 + "daily.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Time Series Daily Statistics Wind Speed Plot (PDF)");
                output.newFile(prefix5 + "daily.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Time Series Daily Statistics Wind Direction Plot (PDF)");
                output.newFile(prefix5 + "daily.WNDVEC." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf", "Time Series Daily Statistics Wind Vector Plot (PDF)");
                output.newFile(prefix5 + "daily.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".pdf"," ");
                
                output.newFile(prefix5 + "daily.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Time Series Daily Statistics Temperature Plot (PNG)");
                output.newFile(prefix5 + "daily.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Time Series Daily Statistics Relative Humidity Plot (PNG)");
                output.newFile(prefix5 + "daily.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Time Series Daily Statistics Wind Speed Plot (PNG)");
                output.newFile(prefix5 + "daily.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Time Series Daily Statistics Wind Direction Plot (PNG)");
                output.newFile(prefix5 + "daily.WNDVEC." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png", "Time Series Daily Statistics Wind Vector Plot (PNG)");
                output.newFile(prefix5 + "daily.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".png"," ");
                
                output.newFile(prefix5 + "daily.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".csv", "Time Series Daily Statistics Temperature Dataset (csv)");
                output.newFile(prefix5 + "daily.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".csv", "Time Series Daily Statistics Relative Humidity Dataset (csv)");
                output.newFile(prefix5 + "daily.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".csv", "Time Series Daily Statistics Wind Speed Dataset (csv)");
                output.newFile(prefix5 + "daily.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".csv", "Time Series Daily Statistics Wind Direction Dataset (csv)");
                output.newFile(prefix5 + "daily.WNDVEC." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".csv", "Time Series Daily Statistics Wind Vector Dataset (csv)");
                output.newFile(prefix5 + "daily.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + ".csv"," ");
                
                output.newFile(prefix5 + "profileM." + site + ".TEMP." + date_range2 + "." + project_id + ".pdf", site + " Temperature Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + site + ".RH." + date_range2 +  "." + project_id + ".pdf", site + " Relative Humidity Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + site + ".WS." + date_range2 +  "." + project_id + ".pdf", site + " Wind Speed Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + site + ".WD." + date_range2 +  "." + project_id + ".pdf", site + " Wind Direction Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + site + ".TEMP." + date_range2 + "." + project_id + ".pdf"," ");
                
                output.newFile(prefix5 + "profileM." + site + ".TEMP." + date_range2 + "." + project_id + ".png", site + " Temperature Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + site + ".RH." + date_range2 +  "." + project_id + ".png", site + " Relative Humidity Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + site + ".WS." + date_range2 +  "." + project_id + ".png", site + " Wind Speed Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + site + ".WD." + date_range2 +  "." + project_id + ".png", site + " Wind Direction Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + site + ".TEMP." + date_range2 + "." + project_id + ".png"," ");
                
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".TEMP." + date_range2 + "." + project_id + ".pdf", "Temperature Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".RH." + date_range2 +  "." + project_id + ".pdf", "Relative Humidity Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".WS." + date_range2 +  "." + project_id + ".pdf", "Wind Speed Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".WD." + date_range2 +  "." + project_id + ".pdf", "Wind Direction Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".TEMP." + date_range2 + "." + project_id + ".pdf"," ");
                
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".TEMP." + date_range2 + "." + project_id + ".png", "Temperature Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".RH." + date_range2 +  "." + project_id + ".png", "Relative Humidity Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".WS." + date_range2 +  "." + project_id + ".png", "Wind Speed Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".WD." + date_range2 +  "." + project_id + ".png", "Wind Direction Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".TEMP." + date_range2 + "." + project_id + ".png"," ");
                
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".100mb." + project_id + ".pdf", "Relative Humidity Histogram Plot 100 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".150mb." + project_id + ".pdf", "Relative Humidity Histogram Plot 150 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".200mb." + project_id + ".pdf", "Relative Humidity Histogram Plot 200 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".250mb." + project_id + ".pdf", "Relative Humidity Histogram Plot 250 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".300mb." + project_id + ".pdf", "Relative Humidity Histogram Plot 300 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".400mb." + project_id + ".pdf", "Relative Humidity Histogram Plot 400 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".500mb." + project_id + ".pdf", "Relative Humidity Histogram Plot 500 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".700mb." + project_id + ".pdf", "Relative Humidity Histogram Plot 700 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".850mb." + project_id + ".pdf", "Relative Humidity Histogram Plot 850 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".925mb." + project_id + ".pdf", "Relative Humidity Histogram Plot 925 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".1000mb." + project_id + ".pdf", "Relative Humidity Histogram Plot 1000 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".100mb." + project_id + ".pdf"," ");
                
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".100mb." + project_id + ".png", "Relative Humidity Histogram Plot 100 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".150mb." + project_id + ".png", "Relative Humidity Histogram Plot 150 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".200mb." + project_id + ".png", "Relative Humidity Histogram Plot 200 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".250mb." + project_id + ".png", "Relative Humidity Histogram Plot 250 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".300mb." + project_id + ".png", "Relative Humidity Histogram Plot 300 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".400mb." + project_id + ".png", "Relative Humidity Histogram Plot 400 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".500mb." + project_id + ".png", "Relative Humidity Histogram Plot 500 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".700mb." + project_id + ".png", "Relative Humidity Histogram Plot 700 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".850mb." + project_id + ".png", "Relative Humidity Histogram Plot 850 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".925mb." + project_id + ".png", "Relative Humidity Histogram Plot 925 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".1000mb." + project_id + ".png", "Relative Humidity Histogram Plot 1000 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".100mb." + project_id + ".png"," ");
                
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".100mb." + project_id + ".pdf", "Relative Humidity Plot 100 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".150mb." + project_id + ".pdf", "Relative Humidity Plot 150 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".200mb." + project_id + ".pdf", "Relative Humidity Plot 200 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".250mb." + project_id + ".pdf", "Relative Humidity Plot 250 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".300mb." + project_id + ".pdf", "Relative Humidity Plot 300 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".400mb." + project_id + ".pdf", "Relative Humidity Plot 400 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".500mb." + project_id + ".pdf", "Relative Humidity Plot 500 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".700mb." + project_id + ".pdf", "Relative Humidity Plot 700 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".850mb." + project_id + ".pdf", "Relative Humidity Plot 850 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".925mb." + project_id + ".pdf", "Relative Humidity Plot 925 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".1000mb." + project_id + ".pdf", "Relative Humidity Plot 1000 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".100mb." + project_id + ".pdf"," ");
                
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".100mb." + project_id + ".png", "Relative Humidity Plot 100 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".150mb." + project_id + ".png", "Relative Humidity Plot 150 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".200mb." + project_id + ".png", "Relative Humidity Plot 200 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".250mb." + project_id + ".png", "Relative Humidity Plot 250 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".300mb." + project_id + ".png", "Relative Humidity Plot 300 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".400mb." + project_id + ".png", "Relative Humidity Plot 400 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".500mb." + project_id + ".png", "Relative Humidity Plot 500 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".700mb." + project_id + ".png", "Relative Humidity Plot 700 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".850mb." + project_id + ".png", "Relative Humidity Plot 850 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".925mb." + project_id + ".png", "Relative Humidity Plot 925 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".1000mb." + project_id + ".png", "Relative Humidity Plot 1000 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".100mb." + project_id + ".png"," ");
                
                output.newFile(prefix5 + "curtainM." + site + ".MOD.TEMP." + date_range2 + "." + project_id + ".pdf","Model Temperature Curtain Plot -- Mandatory Level -- " + site + " (PDF)");
                output.newFile(prefix5 + "curtainM." + site + ".OBS.TEMP." + date_range2 + "." + project_id + ".pdf","Observed Temperature Curtain Plot -- Mandatory Level -- " + site + " (PDF)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD-OBS.TEMP." + date_range2 + "." + project_id + ".pdf","Model-Observed Difference Temperature Curtain Plot -- Mandatory Level -- " + site + " (PDF)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD.TEMP." + date_range2 + "." + project_id + ".pdf"," ");
                
                output.newFile(prefix5 + "curtainM." + site + ".MOD.TEMP." + date_range2 + "." + project_id + ".png","Model Temperature Curtain Plot -- Mandatory Level -- " + site + " (PNG)");
                output.newFile(prefix5 + "curtainM." + site + ".OBS.TEMP." + date_range2 + "." + project_id + ".png","Observed Temperature Curtain Plot -- Mandatory Level -- " + site + " (PNG)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD-OBS.TEMP." + date_range2 + "." + project_id + ".png","Model-Observed Difference Temperature Curtain Plot -- Mandatory Level -- " + site + " (PNG)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD.TEMP." + date_range2 + "." + project_id + ".png"," ");
                
                output.newFile(prefix5 + "curtainM." + site + ".MOD.RH." + date_range2 + "." + project_id + ".pdf","Model Relative Humidity Curtain Plot -- Mandatory Level -- " + site + " (PDF)");
                output.newFile(prefix5 + "curtainM." + site + ".OBS.RH." + date_range2 + "." + project_id + ".pdf","Observed Relative Humidity Curtain Plot -- Mandatory Level -- " + site + " (PDF)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD-OBS.RH." + date_range2 + "." + project_id + ".pdf","Model-Observed Difference Relative Humidity Curtain Plot -- Mandatory Level -- " + site + " (PDF)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD.RH." + date_range2 + "." + project_id + ".pdf"," ");
                
                output.newFile(prefix5 + "curtainM." + site + ".MOD.RH." + date_range2 + "." + project_id + ".png","Model Relative Humidity Curtain Plot -- Mandatory Level -- " + site + " (PNG)");
                output.newFile(prefix5 + "curtainM." + site + ".OBS.RH." + date_range2 + "." + project_id + ".png","Observed Relative Humidity Curtain Plot -- Mandatory Level -- " + site + " (PNG)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD-OBS.RH." + date_range2 + "." + project_id + ".png","Model-Observed Difference Relative Humidity Curtain Plot -- Mandatory Level -- " + site + " (PNG)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD.RH." + date_range2 + "." + project_id + ".png"," ");

                output.newFile(prefix5 + "curtainM." + site + ".MOD.WS." + date_range2 + "." + project_id + ".pdf","Model Wind Speed Curtain Plot -- Mandatory Level -- " + site + " (PDF)");
                output.newFile(prefix5 + "curtainM." + site + ".OBS.WS." + date_range2 + "." + project_id + ".pdf","Observed Wind Speed Curtain Plot -- Mandatory Level -- " + site + " (PDF)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD-OBS.WS." + date_range2 + "." + project_id + ".pdf","Model-Observed Difference Wind Speed Curtain Plot -- Mandatory Level -- " + site + " (PDF)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD.WS." + date_range2 + "." + project_id + ".pdf"," ");
                
                output.newFile(prefix5 + "curtainM." + site + ".MOD.WS." + date_range2 + "." + project_id + ".png","Model Wind Speed Curtain Plot -- Mandatory Level -- " + site + " (PNG)");
                output.newFile(prefix5 + "curtainM." + site + ".OBS.WS." + date_range2 + "." + project_id + ".png","Observed Wind Speed Curtain Plot -- Mandatory Level -- " + site + " (PNG)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD-OBS.WS." + date_range2 + "." + project_id + ".png","Model-Observed Difference Wind Speed Curtain Plot -- Mandatory Level -- " + site + " (PNG)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD.WS." + date_range2 + "." + project_id + ".png"," ");
                
                output.newFile(prefix5 + "curtainM." + site + ".MOD.WD." + date_range2 + "." + project_id + ".pdf","Model Wind Dirtection Curtain Plot -- Mandatory Level -- " + site + " (PDF)");
                output.newFile(prefix5 + "curtainM." + site + ".OBS.WD." + date_range2 + "." + project_id + ".pdf","Observed Wind Direction Curtain Plot -- Mandatory Level -- " + site + " (PDF)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD-OBS.WD." + date_range2 + "." + project_id + ".pdf","Model-Observed Difference Wind Direction Curtain Plot -- Mandatory Level -- " + site + " (PDF)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD.WD." + date_range2 + "." + project_id + ".pdf"," ");
                
                output.newFile(prefix5 + "curtainM." + site + ".MOD.WD." + date_range2 + "." + project_id + ".png","Model Wind Dirtection Curtain Plot -- Mandatory Level -- " + site + " (PNG)");
                output.newFile(prefix5 + "curtainM." + site + ".OBS.WD." + date_range2 + "." + project_id + ".png","Observed Wind Direction Curtain Plot -- Mandatory Level -- " + site + " (PNG)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD-OBS.WD." + date_range2 + "." + project_id + ".png","Model-Observed Difference Wind Direction Curtain Plot -- Mandatory Level -- " + site + " (PNG)");
                output.newFile(prefix5 + "curtainM." + site + ".MOD.WD." + date_range2 + "." + project_id + ".png"," ");
                
                output.newFile(prefix5 + "profileN." + site + ".TEMP-RH." + date_range3 + "." + project_id + ".pdf", "Native Level Temperature-Relative Humidity Profile Plot -- " + year_start + "-" + month_start + "-" + day_start + " (PDF)");
                output.newFile(prefix5 + "profileN." + site + ".TEMP-RH." + date_range3 + "." + project_id + ".png", "Native Level Temperature-Relative Humidity Profile Plot -- " + year_start + "-" + month_start + "-" + day_start + " (PNG)");
                output.newFile(prefix5 + "profileN." + site + ".TEMP-RH." + date_range3 + "." + project_id + ".pdf"," ");
                output.newFile(prefix5 + "profileN." + site + ".TEMP-RH." + date_range3 + "." + project_id + ".png"," ");
                
                output.newFile(prefix5 + "curtainN." + site + ".T." + date_range2 + "." + project_id + ".pdf", "Native Level Temperature Curtain Plot (PDF)");
                output.newFile(prefix5 + "curtainN." + site + ".RH." + date_range2 + "." + project_id + ".pdf", "Native Level Relative Humidity Curtain Plot (PDF)");
                output.newFile(prefix5 + "curtainN." + site + ".WS." + date_range2 + "." + project_id + ".pdf", "Native Level Wind Speed Curtain Plot (PDF)");
                output.newFile(prefix5 + "curtainN." + site + ".WD." + date_range2 + "." + project_id + ".pdf", "Native Level Wind Direction Curtain Plot (PDF)");
                output.newFile(prefix5 + "curtainN." + site + ".T." + date_range2 + "." + project_id + ".pdf"," ");
                
                output.newFile(prefix5 + "curtainN." + site + ".T." + date_range2 + "." + project_id + ".png", "Native Level Temperature Curtain Plot (PNG)");
                output.newFile(prefix5 + "curtainN." + site + ".RH." + date_range2 + "." + project_id + ".png", "Native Level Relative Humidity Curtain Plot (PNG)");
                output.newFile(prefix5 + "curtainN." + site + ".WS." + date_range2 + "." + project_id + ".png", "Native Level Wind Speed Curtain Plot (PNG)");
                output.newFile(prefix5 + "curtainN." + site + ".WD." + date_range2 + "." + project_id + ".png", "Native Level Wind Direction Curtain Plot (PNG)");
                output.newFile(prefix5 + "curtainN." + site + ".T." + date_range2 + "." + project_id + ".png"," ");
                
                output.newFile(prefix5 + "curtainN." + site + ".T.DIFF." + date_range2 + "." + project_id + ".pdf", "Native Level Temperature Difference Curtain Plot (PDF)");
                output.newFile(prefix5 + "curtainN." + site + ".RH.DIFF." + date_range2 + "." + project_id + ".pdf", "Native Level Relative Humidity Difference Curtain Plot (PDF)");
                output.newFile(prefix5 + "curtainN." + site + ".WS.DIFF." + date_range2 + "." + project_id + ".pdf", "Native Level Wind Speed Difference Curtain Plot (PDF)");
                output.newFile(prefix5 + "curtainN." + site + ".WD.DIFF." + date_range2 + "." + project_id + ".pdf", "Native Level Wind Direction Difference Curtain Plot (PDF)");
                
                output.newFile(prefix5 + "curtainN." + site + ".T.DIFF." + date_range2 + "." + project_id + ".png", "Native Level Temperature Difference Curtain Plot (PNG)");
                output.newFile(prefix5 + "curtainN." + site + ".RH.DIFF." + date_range2 + "." + project_id + ".png", "Native Level Relative Humidity Difference Curtain Plot (PNG)");
                output.newFile(prefix5 + "curtainN." + site + ".WS.DIFF." + date_range2 + "." + project_id + ".png", "Native Level Wind Speed Difference Curtain Plot (PNG)");
                output.newFile(prefix5 + "curtainN." + site + ".WD.DIFF." + date_range2 + "." + project_id + ".png", "Native Level Wind Direction Difference Curtain Plot (PNG)");
                break;
            default:
               errorWindow("Program does not exist", "Cannot generate output in outputWindow() method");
               output.dispose();
        }
        output.checkIfSuccess();
        output.setVisible(true);
    }
        
//##############################################################################
//    HELPER FUNCTIONS
//##############################################################################
    //Returns <""> for R if empty, else returns value
    public String checkBoxFormat(javax.swing.JCheckBox checkBox) {
        if (checkBox.isSelected()) {
            isNetworkSelectedTemp = true;
            return "T";
        } else {
            return "F";
        }
    }
    
    //Returns <""> for R if empty, else returns value
    public String textFormat(String str){
        if (str.equals("") || str.equals(" ") || str.equals("None")) {
            return "\"\"";
        } else {
            return "\"" + str + "\"";
        }
    }
    
    //Returns 0 is empty, else returns value
    public int numFormat(String str) {
        try {
            return Integer.parseInt(str);
        } catch(Exception e) {
            return 0;
        }
    }
    
    //Returns NULL if empty, else returns value
    public String numNullFormat(String str) {
        if (str.isEmpty() || str.equals(" ") || str == null) {
            return "NULL";
        } else {
            return str;
        }
    }
    
    //general error window call
    private void errorWindow(String title, String message) {
        ErrorWindow ew = new ErrorWindow(title, message);
        ew.setVisible(true);
    }
    
     //assigning program names values to run_program combo box fields
    private void programFormat() {
         int index = ProgramComboBox.getSelectedIndex();
        System.out.println(index);
        switch(index) {
            case 2:
                ProgramComboBox.setSelectedIndex(3);
                break;
            case 6:
                ProgramComboBox.setSelectedIndex(7);
                break;
            case 9:
                ProgramComboBox.setSelectedIndex(10);
                break;
            case 12:
                ProgramComboBox.setSelectedIndex(13);
                break;
            case 15:
                ProgramComboBox.setSelectedIndex(16);
                break;
            case 18:
                ProgramComboBox.setSelectedIndex(19);
                break;
            default:
        }
        
        String str = ProgramComboBox.getSelectedItem().toString();
        switch(str) {
            case "Time Series: 2-m Temp, 2-m Moisture and 10-m Wind":
                run_program = "MET_timeseries.R";
                break;
            case "Time Series: 2-m Temp, 2-m Moisture, 2-m RH and Sfc Pressure":
                run_program = "MET_timeseries_rh.R";
                break;
            case "Daily Statistics: 2-m Temp, 2-m Moisture and 10-m Wind":
                run_program = "MET_daily_barplot.R";
                break;
            case "Summary Statistics: 2-m Temp, 2-m Moisture and 10-m Wind":
                run_program = "MET_summary.R";
                break;
            case "Shortwave Radiation Statistics: Spatial, Diurnal and Time Series":
                run_program = "MET_plot_radiation.R";
                break;
            case "Spatial Statistics: 2-m Temp, 2-m Moisture and 10-m Wind":
                run_program = "MET_spatial_surface.R";
                break;
            case "Upper-Air: Spatial, Profile, Time Series and Curtain":
                run_program = "MET_raob.R";
                break;
            case "Upper-Air: Mandatory Spatial Statistics":
                run_program = "MET_raob.R";
                break;
            case "Upper-Air: Mandatory Time Series Statistics":
                run_program = "MET_raob.R";
                break;
            case "Upper-Air: Mandatory Profile Statistics":
                run_program = "MET_raob.R";
                break;
            case "Upper-Air: Mandatory Curtain":
                run_program = "MET_raob.R";
                break;
            case "Upper-Air: Native Theta / RH Profiles":
                run_program = "MET_raob.R";
                break;
            case "Upper-Air: Native Curtain":
                run_program = "MET_raob.R";
                break;
            default:
        }       
    }
    
     //assigning values to hour feilds
    private String hourFormat(String str) {
        String hour = "";
        switch(str) {
            case "\"00\"":
                hour = "00";
                break;
            case "\"01\"":
                hour = "01";
                break;
            case "\"02\"":
                hour = "02";
                break;
            case "\"03\"":
                hour = "03";
                break;
            case "\"04\"":
                hour = "04";
                break;
            case "\"05\"":
                hour = "05";
                break;
            case "\"06\"":
                hour = "06";
                break;
            case "\"07\"":
                hour = "07";
                break;
            case "\"08\"":
                hour = "08";
                break;
            case "\"09\"":
                hour = "09";
                break;
            case "\"10\"":
                hour = "10";
                break;
            case "\"11\"":
                hour = "11";
                break;
            case "\"12\"":
                hour = "12";
                break;
            case "\"13\"":
                hour = "13";
                break;
            case "\"14\"":
                hour = "14";
                break;
            case "\"15\"":
                hour = "15";
                break;
            case "\"16\"":
                hour = "16";
                break;
            case "\"17\"":
                hour = "17";
                break;
            case "\"18\"":
                hour = "18";
                break;
            case "\"19\"":
                hour = "19";
                break;
            case "\"20\"":
                hour = "20";
                break;
            case "\"21\"":
                hour = "21";
                break;
            case "\"22\"":
                hour = "22";
                break;
            case "\"23\"":
                hour = "23";
                break;
            default:
                break;
        }
        return hour;
    }
    
    //assigning values to symbol names
    private String symbolFormat(String str){
        switch(str) {
            case "Circle":
                symbol = "19";
                break;
            case "Square":
                symbol = "15";
                break;
            case "Diamond":
                symbol = "18";
                break;
            case "Triangle":
                symbol = "17";
                break;
            default:
                System.out.println("Error");
                symbol = "0";
        }
        return symbol;
    }
    
    private void queryFormat() {
        String str = "";
        
       
        //Latitude and Longitude
        if (!lat_south.equals("NA") && !lat_north.equals("NA")) {
            str = str + " AND s.lat BETWEEN " + lat_south + " AND " + lat_north;
        }
        if (!lon_west.equals("NA") && !lon_east.equals("NA")) {
            str = str + " AND s.lon BETWEEN " + lon_west + " AND " + lon_east;
        }
        
        //Hour Range
        if (!hs.equals("") && !he.equals("")){
            str = str + " AND HOUR(d.ob_date) BETWEEN " + hs + " AND " + he;
        }
        
        //State
        if (!state.equals("\"All\"")) { 
            str = str + " AND s.state=" + state;
        }
        
        //Observation Networks
        if (AllCheckBox.isSelected()) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='ASOS' OR s.ob_network='MARITIME' OR s.ob_network='SAO' OR s.ob_network='Mesonet')";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("F") && inc_MARITIME.equals("F") && inc_SAO.equals("F") && inc_Mesonet.equals("F")) {
            str = str + " AND s.ob_network='METAR'";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("T") && inc_MARITIME.equals("F") && inc_SAO.equals("F") && inc_Mesonet.equals("F")) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='ASOS')";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("F") && inc_MARITIME.equals("T") && inc_SAO.equals("F") && inc_Mesonet.equals("F")) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='MARITIME')";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("F") && inc_MARITIME.equals("F") && inc_SAO.equals("T") && inc_Mesonet.equals("F")) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='SAO')";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("F") && inc_MARITIME.equals("F") && inc_SAO.equals("F") && inc_Mesonet.equals("T")) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='Mesonet')";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("T") && inc_MARITIME.equals("T") && inc_SAO.equals("F") && inc_Mesonet.equals("F")) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='ASOS' OR s.ob_network='MARITIME')";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("T") && inc_MARITIME.equals("F") && inc_SAO.equals("T") && inc_Mesonet.equals("F")) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='ASOS' OR s.ob_network='SAO')";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("T") && inc_MARITIME.equals("F") && inc_SAO.equals("F") && inc_Mesonet.equals("T")) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='ASOS' OR s.ob_network='Mesonet')";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("F") && inc_MARITIME.equals("T") && inc_SAO.equals("T") && inc_Mesonet.equals("F")) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='SAO' OR s.ob_network='MARITIME')";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("F") && inc_MARITIME.equals("T") && inc_SAO.equals("F") && inc_Mesonet.equals("T")) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='Mesonet' OR s.ob_network='MARITIME')";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("F") && inc_MARITIME.equals("F") && inc_SAO.equals("T") && inc_Mesonet.equals("T")) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='SAO' OR s.ob_network='Mesonet')";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("T") && inc_MARITIME.equals("T") && inc_SAO.equals("T") && inc_Mesonet.equals("F")) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='ASOS' OR s.ob_network='MARITIME' OR s.ob_network='SAO')";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("T") && inc_MARITIME.equals("T") && inc_SAO.equals("F") && inc_Mesonet.equals("T")) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='ASOS' OR s.ob_network='MARITIME' OR s.ob_network='Mesonet')";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("T") && inc_MARITIME.equals("F") && inc_SAO.equals("T") && inc_Mesonet.equals("T")) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='ASOS' OR s.ob_network='Mesonet' OR s.ob_network='SAO')";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("F") && inc_MARITIME.equals("T") && inc_SAO.equals("T") && inc_Mesonet.equals("T")) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='Mesonet' OR s.ob_network='MARITIME' OR s.ob_network='SAO')";
        }
        if (inc_METAR.equals("T") && inc_ASOS.equals("T") && inc_MARITIME.equals("T") && inc_SAO.equals("T") && inc_Mesonet.equals("T")) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='ASOS' OR s.ob_network='MARITIME' OR s.ob_network='SAO'OR s.ob_network='Mesonet')";
        }
        
        if (inc_METAR.equals("F") && inc_ASOS.equals("T") && inc_MARITIME.equals("F") && inc_SAO.equals("F") && inc_Mesonet.equals("F")) {
            str = str + " AND s.ob_network='ASOS'";
        }
        if (inc_METAR.equals("F") && inc_ASOS.equals("T") && inc_MARITIME.equals("T") && inc_SAO.equals("F") && inc_Mesonet.equals("F")) {
            str = str + " AND (s.ob_network='ASOS' OR s.ob_network='MARITIME')";
        }
        if (inc_METAR.equals("F") && inc_ASOS.equals("T") && inc_MARITIME.equals("F") && inc_SAO.equals("T") && inc_Mesonet.equals("F")) {
            str = str + " AND (s.ob_network='ASOS' OR s.ob_network='SAO')";
        }
        if (inc_METAR.equals("F") && inc_ASOS.equals("T") && inc_MARITIME.equals("F") && inc_SAO.equals("F") && inc_Mesonet.equals("T")) {
            str = str + " AND (s.ob_network='ASOS' OR s.ob_network='Mesonet')";
        }
        if (inc_METAR.equals("F") && inc_ASOS.equals("T") && inc_MARITIME.equals("T") && inc_SAO.equals("T") && inc_Mesonet.equals("F")) {
            str = str + " AND (s.ob_network='ASOS' OR s.ob_network='MARITIME' OR s.ob_network='SAO')";
        }
        if (inc_METAR.equals("F") && inc_ASOS.equals("T") && inc_MARITIME.equals("T") && inc_SAO.equals("F") && inc_Mesonet.equals("T")) {
            str = str + " AND (s.ob_network='ASOS' OR s.ob_network='MARITIME' OR s.ob_network='Mesonet')";
        }
        if (inc_METAR.equals("F") && inc_ASOS.equals("T") && inc_MARITIME.equals("F") && inc_SAO.equals("T") && inc_Mesonet.equals("T")) {
            str = str + " AND (s.ob_network='ASOS' OR s.ob_network='Mesonet' OR s.ob_network='SAO')";
        }
        if (inc_METAR.equals("F") && inc_ASOS.equals("T") && inc_MARITIME.equals("T") && inc_SAO.equals("T") && inc_Mesonet.equals("T")) {
            str = str + " AND (s.ob_network='ASOS' OR s.ob_network='MARITIME' OR s.ob_network='SAO' OR s.ob_network='Mesonet')";
        }
        
        if (inc_METAR.equals("F") && inc_ASOS.equals("F") && inc_MARITIME.equals("T") && inc_SAO.equals("F") && inc_Mesonet.equals("F")) {
            str = str + " AND s.ob_network='MARITIME'";
        }
        if (inc_METAR.equals("F") && inc_ASOS.equals("F") && inc_MARITIME.equals("T") && inc_SAO.equals("T") && inc_Mesonet.equals("F")) {
            str = str + " AND (s.ob_network='MARITIME' OR s.ob_network='SAO')";
        }
        if (inc_METAR.equals("F") && inc_ASOS.equals("F") && inc_MARITIME.equals("T") && inc_SAO.equals("F") && inc_Mesonet.equals("T")) {
            str = str + " AND (s.ob_network='MARITIME' OR s.ob_network='Mesonet')";
        }
        if (inc_METAR.equals("F") && inc_ASOS.equals("F") && inc_MARITIME.equals("T") && inc_SAO.equals("T") && inc_Mesonet.equals("T")) {
            str = str + " AND (s.ob_network='MARITIME' OR s.ob_network='SAO' OR s.ob_network='Mesonet')";
        }
        
        if (inc_METAR.equals("F") && inc_ASOS.equals("F") && inc_MARITIME.equals("F") && inc_SAO.equals("T") && inc_Mesonet.equals("F")) {
            str = str + " AND s.ob_network='SAO'";
        }
        if (inc_METAR.equals("F") && inc_ASOS.equals("F") && inc_MARITIME.equals("F") && inc_SAO.equals("T") && inc_Mesonet.equals("T")) {
            str = str + " AND (s.ob_network='SAO' OR s.ob_network='Mesonet')";
        }
        if (inc_METAR.equals("F") && inc_ASOS.equals("F") && inc_MARITIME.equals("F") && inc_SAO.equals("F") && inc_Mesonet.equals("T")) {
            str = str + " AND s.ob_network='Mesonet'";
        }
        
        //Month
        switch(month_name) {
            case "\"January\"":
                str = str + " AND month = 01";
                break;
            case "\"February\"":
                str = str + " AND month = 02";
                break;
            case "\"March\"":
                str = str + " AND month = 03";
                break;
            case "\"April\"":
                str = str + " AND month = 04";
                break;
            case "\"May\"":
                str = str + " AND month = 05";
                break;
            case "\"June\"":
                str = str + " AND month = 06";
                break;
            case "\"July\"":
                str = str + " AND month = 07";
                break;
            case "\"August\"":
                str = str + " AND month = 08";
                break;
            case "\"September\"":
                str = str + " AND month = 09";
                break;
            case "\"October\"":
                str = str + " AND month = 10";
                break;
            case "\"November\"":
                str = str + " AND month = 11";
                break;
            case "\"December\"":
                str = str + " AND month = 12";
                break;
        }
        
  
        
        query_string = str;
     
        System.out.println(query_string);
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        Header = new javax.swing.JLabel();
        Footer = new javax.swing.JLabel();
        jTabbedPane1 = new javax.swing.JTabbedPane();
        ProjectTab = new javax.swing.JPanel();
        Left1 = new javax.swing.JPanel();
        SelectDatabaseLabel = new javax.swing.JLabel();
        SelectDatabaseComboBox = new javax.swing.JComboBox<>();
        SelectProjectLabel = new javax.swing.JLabel();
        SelectProjectComboBox = new javax.swing.JComboBox<>();
        ProjectDetailsLabel = new javax.swing.JLabel();
        ProjectDetailsTextArea = new javax.swing.JTextArea();
        SelectAdditionalDatabaseLabel = new javax.swing.JLabel();
        SelectAdditionalDatabaseInfoLabel = new javax.swing.JLabel();
        SelectAdditionalDatabaseComboBox = new javax.swing.JComboBox<>();
        SelectAdditionalProjectLabel2 = new javax.swing.JLabel();
        SelectAdditionalProjectInfoLabel2 = new javax.swing.JLabel();
        SelectAdditionalProjectComboBox2 = new javax.swing.JComboBox<>();
        DateTimeTab = new javax.swing.JPanel();
        Left5 = new javax.swing.JPanel();
        DateRangeLabel = new javax.swing.JLabel();
        DateRangeTextArea = new javax.swing.JTextArea();
        StartDateLabel = new javax.swing.JLabel();
        StartDatePicker = new com.github.lgooddatepicker.components.DatePicker();
        EndDateLabel = new javax.swing.JLabel();
        EndDatePicker = new com.github.lgooddatepicker.components.DatePicker();
        MonthlyAnalysisLabel = new javax.swing.JLabel();
        MonthlyAnalysisTextArea = new javax.swing.JTextArea();
        MonthlyAnalysisCheckBox = new javax.swing.JCheckBox();
        MonthlyAnalysisTextArea1 = new javax.swing.JTextArea();
        jPanel1 = new javax.swing.JPanel();
        HourRangeLabel = new javax.swing.JLabel();
        HourRangeTextArea = new javax.swing.JTextArea();
        StartHourLabel = new javax.swing.JLabel();
        StartHourComboBox = new javax.swing.JComboBox<>();
        EndHourLabel = new javax.swing.JLabel();
        EndHourComboBox = new javax.swing.JComboBox<>();
        SeasonalLabel = new javax.swing.JLabel();
        SeasonalTextArea = new javax.swing.JTextArea();
        SeasonalAnalysisCheckBox = new javax.swing.JCheckBox();
        SeasonalAnalysisTextArea = new javax.swing.JTextArea();
        RegionalTab = new javax.swing.JPanel();
        Left2 = new javax.swing.JPanel();
        StateLabel = new javax.swing.JLabel();
        StateInfoLabel = new javax.swing.JLabel();
        StateComboBox = new javax.swing.JComboBox<>();
        ClimateLabel = new javax.swing.JLabel();
        ClimateInfoLabel = new javax.swing.JLabel();
        ClimateComboBox = new javax.swing.JComboBox<>();
        WorldLabel = new javax.swing.JLabel();
        WorldInfoLabel = new javax.swing.JLabel();
        WorldComboBox = new javax.swing.JComboBox<>();
        RPOLabel = new javax.swing.JLabel();
        RPOInfoLabel = new javax.swing.JLabel();
        RPOComboBox = new javax.swing.JComboBox<>();
        PCALabel = new javax.swing.JLabel();
        PCAInfoLabel = new javax.swing.JLabel();
        PCAComboBox = new javax.swing.JComboBox<>();
        AerosolMapButton = new javax.swing.JButton();
        OzoneMapButton = new javax.swing.JButton();
        LatLonLabel = new javax.swing.JLabel();
        LatLonTextArea = new javax.swing.JTextArea();
        LatLonPanel = new javax.swing.JPanel();
        LatLabel1 = new javax.swing.JLabel();
        LonLabel1 = new javax.swing.JLabel();
        LatLabel2 = new javax.swing.JLabel();
        LatTextField1 = new javax.swing.JTextField();
        LatTextField2 = new javax.swing.JTextField();
        LonLabel2 = new javax.swing.JLabel();
        LonTextField1 = new javax.swing.JTextField();
        LonTextField2 = new javax.swing.JTextField();
        SiteIDTab = new javax.swing.JPanel();
        Left3 = new javax.swing.JPanel();
        SiteIDLabel = new javax.swing.JLabel();
        SiteIDTextArea = new javax.swing.JTextArea();
        SiteIDTextField = new javax.swing.JTextField();
        SiteIDTextArea1 = new javax.swing.JTextArea();
        SiteIDTextArea2 = new javax.swing.JTextArea();
        METNetworkLabel = new javax.swing.JLabel();
        METNetworkInfoLabel = new javax.swing.JLabel();
        SAOCheckBox = new javax.swing.JCheckBox();
        MaritimeCheckBox = new javax.swing.JCheckBox();
        ASOSCheckBox = new javax.swing.JCheckBox();
        METARCheckBox = new javax.swing.JCheckBox();
        AllCheckBox = new javax.swing.JCheckBox();
        METNetworkInfoLabel1 = new javax.swing.JLabel();
        MesonetCheckBox = new javax.swing.JCheckBox();
        OutputPropertiesTab = new javax.swing.JPanel();
        Left6 = new javax.swing.JPanel();
        CustomRunNameLabel = new javax.swing.JLabel();
        CustomRunNameTextField = new javax.swing.JTextField();
        PlotlyImageLabel = new javax.swing.JLabel();
        PlotlyIamgeInfoTextArea = new javax.swing.JTextArea();
        PlotlyImagePanel = new javax.swing.JPanel();
        HeightLabel = new javax.swing.JLabel();
        HeightTextField = new javax.swing.JTextField();
        WidthLabel = new javax.swing.JLabel();
        WidthTextField = new javax.swing.JTextField();
        GraphicsFormatLabel = new javax.swing.JLabel();
        GraphicsFormatTextArea = new javax.swing.JTextArea();
        GraphicsFormatComboBox = new javax.swing.JComboBox<>();
        CustomDirectoryNameLabel = new javax.swing.JLabel();
        CustomDirectoryNameTextField = new javax.swing.JTextField();
        jPanel2 = new javax.swing.JPanel();
        SymbolSettingsLabel = new javax.swing.JLabel();
        SymbolLabel = new javax.swing.JLabel();
        SymbolComboBox = new javax.swing.JComboBox<>();
        SymbolScaleLabel = new javax.swing.JLabel();
        SymbolScaleTextField = new javax.swing.JTextField();
        TextScaleLabel = new javax.swing.JLabel();
        TextScaleTextField = new javax.swing.JTextField();
        ClearFilesLabel = new javax.swing.JLabel();
        ClearFilesTextField = new javax.swing.JTextField();
        ClearFilesButton = new javax.swing.JButton();
        RunAnalysisTab = new javax.swing.JPanel();
        Left4 = new javax.swing.JPanel();
        ProgramLabel = new javax.swing.JLabel();
        ProgramTextArea = new javax.swing.JTextArea();
        ProgramComboBox = new javax.swing.JComboBox<>();
        METPlotOptionsLabel = new javax.swing.JLabel();
        MaxRecordsLabel = new javax.swing.JLabel();
        MaxRecordsTextField = new javax.swing.JTextField();
        SaveFileCheckBox = new javax.swing.JCheckBox();
        TextOutCheckBox = new javax.swing.JCheckBox();
        PlotSpecificAdvancedOptionsLabel = new javax.swing.JLabel();
        BarPlotOptionsButton = new javax.swing.JButton();
        TimeSeriesPlotOptionsButton = new javax.swing.JButton();
        DiurnalStatSummaryPlotOptionsButton = new javax.swing.JButton();
        SpatialPlotOptionsButton = new javax.swing.JButton();
        ShortwaveRadEvalPlotOptionsButton = new javax.swing.JButton();
        RAOBPlotOptionsButton = new javax.swing.JButton();
        RunProgramButton = new javax.swing.JButton();
        BackTab = new javax.swing.JPanel();
        Left8 = new javax.swing.JPanel();
        ReturnButton = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setTitle("Meteorology Form");
        setBackground(new java.awt.Color(255, 255, 255));
        setMinimumSize(new java.awt.Dimension(1000, 728));
        setResizable(false);

        Header.setIcon(new javax.swing.ImageIcon(getClass().getResource("/Pictures/top_2022.png"))); // NOI18N

        Footer.setIcon(new javax.swing.ImageIcon(getClass().getResource("/Pictures/bottom_2022.png"))); // NOI18N

        jTabbedPane1.setBackground(new java.awt.Color(38, 161, 70));
        jTabbedPane1.setForeground(new java.awt.Color(0, 63, 105));
        jTabbedPane1.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        jTabbedPane1.setMaximumSize(new java.awt.Dimension(999, 576));
        jTabbedPane1.setMinimumSize(new java.awt.Dimension(999, 576));
        jTabbedPane1.setPreferredSize(new java.awt.Dimension(999, 576));

        ProjectTab.setBackground(new java.awt.Color(255, 255, 255));
        ProjectTab.setPreferredSize(new java.awt.Dimension(1000, 543));

        Left1.setBackground(new java.awt.Color(174, 211, 232));
        Left1.setPreferredSize(new java.awt.Dimension(24, 543));

        javax.swing.GroupLayout Left1Layout = new javax.swing.GroupLayout(Left1);
        Left1.setLayout(Left1Layout);
        Left1Layout.setHorizontalGroup(
            Left1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 24, Short.MAX_VALUE)
        );
        Left1Layout.setVerticalGroup(
            Left1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 543, Short.MAX_VALUE)
        );

        SelectDatabaseLabel.setText("Select a Database for Project 1");
        SelectDatabaseLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        SelectDatabaseLabel.setForeground(new java.awt.Color(0, 112, 185));

        SelectDatabaseComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Choose a Database" }));
        SelectDatabaseComboBox.setBackground(new java.awt.Color(191, 182, 172));
        SelectDatabaseComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SelectDatabaseComboBox.setForeground(new java.awt.Color(0, 63, 105));
        SelectDatabaseComboBox.setMinimumSize(new java.awt.Dimension(407, 23));
        SelectDatabaseComboBox.setPreferredSize(new java.awt.Dimension(407, 23));
        SelectDatabaseComboBox.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                SelectDatabaseComboBoxItemStateChanged(evt);
            }
        });

        SelectProjectLabel.setText("Select Project 1");
        SelectProjectLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        SelectProjectLabel.setForeground(new java.awt.Color(0, 112, 185));

        SelectProjectComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new ComboItem[] { new ComboItem("sample", "<Select a Database First>") }));
        SelectProjectComboBox.setBackground(new java.awt.Color(191, 182, 172));
        SelectProjectComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SelectProjectComboBox.setForeground(new java.awt.Color(0, 63, 105));
        SelectProjectComboBox.setMinimumSize(new java.awt.Dimension(407, 23));
        SelectProjectComboBox.setPreferredSize(new java.awt.Dimension(407, 23));
        SelectProjectComboBox.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                SelectProjectComboBoxItemStateChanged(evt);
            }
        });

        ProjectDetailsLabel.setText("Project Metadata");
        ProjectDetailsLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        ProjectDetailsLabel.setForeground(new java.awt.Color(0, 112, 185));

        ProjectDetailsTextArea.setColumns(20);
        ProjectDetailsTextArea.setEditable(false);
        ProjectDetailsTextArea.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ProjectDetailsTextArea.setLineWrap(true);
        ProjectDetailsTextArea.setRows(5);
        ProjectDetailsTextArea.setWrapStyleWord(true);
        ProjectDetailsTextArea.setBackground(new java.awt.Color(255, 255, 255));
        ProjectDetailsTextArea.setBorder(new javax.swing.border.LineBorder(new java.awt.Color(0, 63, 105), 1, true));
        ProjectDetailsTextArea.setForeground(new java.awt.Color(0, 112, 185));
        ProjectDetailsTextArea.setPreferredSize(new java.awt.Dimension(445, 300));

        SelectAdditionalDatabaseLabel.setText("Select a Database for Project 2 (optional)");
        SelectAdditionalDatabaseLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        SelectAdditionalDatabaseLabel.setForeground(new java.awt.Color(0, 112, 185));

        SelectAdditionalDatabaseInfoLabel.setText("Only used for scripts that compare model simulations.");
        SelectAdditionalDatabaseInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SelectAdditionalDatabaseInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        SelectAdditionalDatabaseComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Choose a Database" }));
        SelectAdditionalDatabaseComboBox.setBackground(new java.awt.Color(191, 182, 172));
        SelectAdditionalDatabaseComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SelectAdditionalDatabaseComboBox.setForeground(new java.awt.Color(0, 63, 105));
        SelectAdditionalDatabaseComboBox.setMinimumSize(new java.awt.Dimension(407, 23));
        SelectAdditionalDatabaseComboBox.setPreferredSize(new java.awt.Dimension(407, 23));
        SelectAdditionalDatabaseComboBox.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                SelectAdditionalDatabaseComboBoxItemStateChanged(evt);
            }
        });

        SelectAdditionalProjectLabel2.setText("Select Project 2 (optional)");
        SelectAdditionalProjectLabel2.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        SelectAdditionalProjectLabel2.setForeground(new java.awt.Color(0, 112, 185));

        SelectAdditionalProjectInfoLabel2.setText("Only used for scripts that compare model simulations.");
        SelectAdditionalProjectInfoLabel2.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SelectAdditionalProjectInfoLabel2.setForeground(new java.awt.Color(0, 112, 185));

        SelectAdditionalProjectComboBox2.setModel(new javax.swing.DefaultComboBoxModel<>(new ComboItem[] { new ComboItem("sample", "<Select a Database First>") }));
        SelectAdditionalProjectComboBox2.setBackground(new java.awt.Color(191, 182, 172));
        SelectAdditionalProjectComboBox2.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SelectAdditionalProjectComboBox2.setForeground(new java.awt.Color(0, 63, 105));
        SelectAdditionalProjectComboBox2.setMinimumSize(new java.awt.Dimension(407, 23));
        SelectAdditionalProjectComboBox2.setPreferredSize(new java.awt.Dimension(407, 23));
        SelectAdditionalProjectComboBox2.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                SelectAdditionalProjectComboBox2ItemStateChanged(evt);
            }
        });

        javax.swing.GroupLayout ProjectTabLayout = new javax.swing.GroupLayout(ProjectTab);
        ProjectTab.setLayout(ProjectTabLayout);
        ProjectTabLayout.setHorizontalGroup(
            ProjectTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(ProjectTabLayout.createSequentialGroup()
                .addComponent(Left1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addGroup(ProjectTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(SelectDatabaseLabel)
                    .addGroup(ProjectTabLayout.createSequentialGroup()
                        .addGroup(ProjectTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(SelectProjectLabel)
                            .addComponent(SelectAdditionalDatabaseLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(SelectAdditionalProjectLabel2)
                            .addComponent(SelectAdditionalDatabaseComboBox, 0, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(SelectAdditionalProjectComboBox2, 0, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(SelectProjectComboBox, 0, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(SelectDatabaseComboBox, 0, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(SelectAdditionalDatabaseInfoLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(SelectAdditionalProjectInfoLabel2))
                        .addGap(40, 40, 40)
                        .addGroup(ProjectTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(ProjectDetailsLabel)
                            .addComponent(ProjectDetailsTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 445, javax.swing.GroupLayout.PREFERRED_SIZE))))
                .addContainerGap(34, Short.MAX_VALUE))
        );
        ProjectTabLayout.setVerticalGroup(
            ProjectTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(ProjectTabLayout.createSequentialGroup()
                .addComponent(Left1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
            .addGroup(ProjectTabLayout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addComponent(SelectDatabaseLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(SelectDatabaseComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addGroup(ProjectTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addGroup(ProjectTabLayout.createSequentialGroup()
                        .addComponent(SelectProjectLabel)
                        .addGap(12, 12, 12)
                        .addComponent(SelectProjectComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(114, 114, 114)
                        .addComponent(SelectAdditionalDatabaseLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(SelectAdditionalDatabaseInfoLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(SelectAdditionalDatabaseComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SelectAdditionalProjectLabel2)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(SelectAdditionalProjectInfoLabel2)
                        .addGap(12, 12, 12)
                        .addComponent(SelectAdditionalProjectComboBox2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(ProjectTabLayout.createSequentialGroup()
                        .addComponent(ProjectDetailsLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(ProjectDetailsTextArea, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        jTabbedPane1.addTab("Project", ProjectTab);

        DateTimeTab.setBackground(new java.awt.Color(255, 255, 255));

        Left5.setBackground(new java.awt.Color(174, 211, 232));
        Left5.setPreferredSize(new java.awt.Dimension(24, 543));

        javax.swing.GroupLayout Left5Layout = new javax.swing.GroupLayout(Left5);
        Left5.setLayout(Left5Layout);
        Left5Layout.setHorizontalGroup(
            Left5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 24, Short.MAX_VALUE)
        );
        Left5Layout.setVerticalGroup(
            Left5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 543, Short.MAX_VALUE)
        );

        DateRangeLabel.setText("Date Range");
        DateRangeLabel.setBackground(new java.awt.Color(255, 255, 255));
        DateRangeLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        DateRangeLabel.setForeground(new java.awt.Color(0, 112, 185));

        DateRangeTextArea.setColumns(20);
        DateRangeTextArea.setEditable(false);
        DateRangeTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        DateRangeTextArea.setLineWrap(true);
        DateRangeTextArea.setRows(5);
        DateRangeTextArea.setText("The default date range is set as earliest and latest records of the selected project.  The default range can be changed by changing the start date and end date either directly in the corresponding text field or selected from the calendars to the right of the text fields.");
        DateRangeTextArea.setWrapStyleWord(true);
        DateRangeTextArea.setBackground(new java.awt.Color(255, 255, 255));
        DateRangeTextArea.setForeground(new java.awt.Color(0, 112, 185));
        DateRangeTextArea.setPreferredSize(new java.awt.Dimension(400, 109));

        StartDateLabel.setText("Start Date");
        StartDateLabel.setBackground(new java.awt.Color(255, 255, 255));
        StartDateLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        StartDateLabel.setForeground(new java.awt.Color(0, 112, 185));

        StartDatePicker.setBackground(new java.awt.Color(255, 255, 255));
        StartDatePicker.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        StartDatePicker.setForeground(new java.awt.Color(0, 112, 185));

        EndDateLabel.setText("End Date");
        EndDateLabel.setBackground(new java.awt.Color(255, 255, 255));
        EndDateLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        EndDateLabel.setForeground(new java.awt.Color(0, 112, 185));

        EndDatePicker.setBackground(new java.awt.Color(255, 255, 255));
        EndDatePicker.setFont(new java.awt.Font("sansserif", 1, 12)); // NOI18N
        EndDatePicker.setForeground(new java.awt.Color(0, 112, 185));

        MonthlyAnalysisLabel.setText("Monthly Analysis");
        MonthlyAnalysisLabel.setBackground(new java.awt.Color(255, 255, 255));
        MonthlyAnalysisLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        MonthlyAnalysisLabel.setForeground(new java.awt.Color(0, 112, 185));

        MonthlyAnalysisTextArea.setColumns(20);
        MonthlyAnalysisTextArea.setEditable(false);
        MonthlyAnalysisTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        MonthlyAnalysisTextArea.setLineWrap(true);
        MonthlyAnalysisTextArea.setRows(5);
        MonthlyAnalysisTextArea.setText("Use this option to isolate evaluation data by the  months of the year. When using this option, set the dates range to cover the entire year.  \n");
        MonthlyAnalysisTextArea.setWrapStyleWord(true);
        MonthlyAnalysisTextArea.setBackground(new java.awt.Color(255, 255, 255));
        MonthlyAnalysisTextArea.setForeground(new java.awt.Color(0, 112, 185));
        MonthlyAnalysisTextArea.setPreferredSize(new java.awt.Dimension(400, 83));

        MonthlyAnalysisCheckBox.setText("Monthly Analysis");
        MonthlyAnalysisCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        MonthlyAnalysisCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        MonthlyAnalysisCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        MonthlyAnalysisCheckBox.setToolTipText("Running Upper-Air Statistics produces spatial and profile statistics for the whole model domain or defined windowed area.");

        MonthlyAnalysisTextArea1.setColumns(20);
        MonthlyAnalysisTextArea1.setEditable(false);
        MonthlyAnalysisTextArea1.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        MonthlyAnalysisTextArea1.setLineWrap(true);
        MonthlyAnalysisTextArea1.setRows(5);
        MonthlyAnalysisTextArea1.setText("Note that monthly analysis can take up to an hour to generate for spatial statistics run and 5-20 minutes for others.  Also, the analyses will not be provided in an Output Window, but stored in the User's cache directory that is provided in pop-up window when complete.");
        MonthlyAnalysisTextArea1.setWrapStyleWord(true);
        MonthlyAnalysisTextArea1.setBackground(new java.awt.Color(255, 255, 255));
        MonthlyAnalysisTextArea1.setForeground(new java.awt.Color(0, 112, 185));
        MonthlyAnalysisTextArea1.setPreferredSize(new java.awt.Dimension(407, 79));

        jPanel1.setBackground(new java.awt.Color(255, 255, 255));
        jPanel1.setPreferredSize(new java.awt.Dimension(419, 500));

        HourRangeLabel.setText("Hour Range");
        HourRangeLabel.setBackground(new java.awt.Color(255, 255, 255));
        HourRangeLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        HourRangeLabel.setForeground(new java.awt.Color(0, 112, 185));

        HourRangeTextArea.setColumns(20);
        HourRangeTextArea.setEditable(false);
        HourRangeTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        HourRangeTextArea.setLineWrap(true);
        HourRangeTextArea.setRows(5);
        HourRangeTextArea.setText("Use this option to query data for a range of hours. This option is only available for select analyses including: Daily Bar and Summary Plots. Hours are in UTC. The default is to include all hours of the day.");
        HourRangeTextArea.setWrapStyleWord(true);
        HourRangeTextArea.setBackground(new java.awt.Color(255, 255, 255));
        HourRangeTextArea.setForeground(new java.awt.Color(0, 112, 185));
        HourRangeTextArea.setPreferredSize(new java.awt.Dimension(407, 79));

        StartHourLabel.setText("Start Hour (UTC)");
        StartHourLabel.setBackground(new java.awt.Color(255, 255, 255));
        StartHourLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        StartHourLabel.setForeground(new java.awt.Color(0, 112, 185));

        StartHourComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Default", "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23" }));
        StartHourComboBox.setBackground(new java.awt.Color(191, 182, 172));
        StartHourComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        StartHourComboBox.setForeground(new java.awt.Color(0, 63, 105));

        EndHourLabel.setText("End Hour (UTC)");
        EndHourLabel.setBackground(new java.awt.Color(255, 255, 255));
        EndHourLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        EndHourLabel.setForeground(new java.awt.Color(0, 112, 185));

        EndHourComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Default", "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23" }));
        EndHourComboBox.setBackground(new java.awt.Color(191, 182, 172));
        EndHourComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        EndHourComboBox.setForeground(new java.awt.Color(0, 63, 105));

        SeasonalLabel.setText("Seasonal Analysis");
        SeasonalLabel.setBackground(new java.awt.Color(255, 255, 255));
        SeasonalLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        SeasonalLabel.setForeground(new java.awt.Color(0, 112, 185));

        SeasonalTextArea.setColumns(20);
        SeasonalTextArea.setEditable(false);
        SeasonalTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SeasonalTextArea.setLineWrap(true);
        SeasonalTextArea.setRows(5);
        SeasonalTextArea.setText("Use this option to isolate evaluation data by the  seasons of the year. When using this option, set the dates range to cover the entire season or year.  \n");
        SeasonalTextArea.setWrapStyleWord(true);
        SeasonalTextArea.setBackground(new java.awt.Color(255, 255, 255));
        SeasonalTextArea.setForeground(new java.awt.Color(0, 112, 185));
        SeasonalTextArea.setPreferredSize(new java.awt.Dimension(400, 83));

        SeasonalAnalysisCheckBox.setText("Seasonal Analysis");
        SeasonalAnalysisCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        SeasonalAnalysisCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SeasonalAnalysisCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        SeasonalAnalysisCheckBox.setToolTipText("Running Upper-Air Statistics produces spatial and profile statistics for the whole model domain or defined windowed area.");

        SeasonalAnalysisTextArea.setColumns(20);
        SeasonalAnalysisTextArea.setEditable(false);
        SeasonalAnalysisTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SeasonalAnalysisTextArea.setLineWrap(true);
        SeasonalAnalysisTextArea.setRows(5);
        SeasonalAnalysisTextArea.setText("Note that monthly analysis can take up to an hour to generate for spatial statistics run and 5-20 minutes for others.  Also, the analyses will not be provided in an Output Window, but stored in the User's cache directory that is provided in pop-up window when complete.");
        SeasonalAnalysisTextArea.setWrapStyleWord(true);
        SeasonalAnalysisTextArea.setBackground(new java.awt.Color(255, 255, 255));
        SeasonalAnalysisTextArea.setForeground(new java.awt.Color(0, 112, 185));
        SeasonalAnalysisTextArea.setPreferredSize(new java.awt.Dimension(407, 79));

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(SeasonalAnalysisTextArea, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel1Layout.createSequentialGroup()
                        .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(StartHourLabel)
                            .addComponent(EndHourLabel))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(StartHourComboBox, 0, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(EndHourComboBox, 0, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
                    .addComponent(SeasonalAnalysisCheckBox))
                .addContainerGap(160, Short.MAX_VALUE))
            .addComponent(HourRangeTextArea, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(SeasonalLabel)
                    .addComponent(HourRangeLabel))
                .addGap(0, 0, Short.MAX_VALUE))
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addComponent(SeasonalTextArea, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addContainerGap())
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addComponent(HourRangeLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(HourRangeTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(StartHourLabel)
                    .addComponent(StartHourComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(18, 18, 18)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(EndHourLabel)
                    .addComponent(EndHourComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(53, 53, 53)
                .addComponent(SeasonalLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(SeasonalTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 48, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(12, 12, 12)
                .addComponent(SeasonalAnalysisCheckBox)
                .addGap(18, 18, 18)
                .addComponent(SeasonalAnalysisTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(14, Short.MAX_VALUE))
        );

        javax.swing.GroupLayout DateTimeTabLayout = new javax.swing.GroupLayout(DateTimeTab);
        DateTimeTab.setLayout(DateTimeTabLayout);
        DateTimeTabLayout.setHorizontalGroup(
            DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(DateTimeTabLayout.createSequentialGroup()
                .addComponent(Left5, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(DateRangeLabel)
                    .addGroup(DateTimeTabLayout.createSequentialGroup()
                        .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(StartDateLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(EndDateLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(EndDatePicker, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(StartDatePicker, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                    .addComponent(MonthlyAnalysisCheckBox)
                    .addComponent(MonthlyAnalysisLabel)
                    .addComponent(MonthlyAnalysisTextArea1, javax.swing.GroupLayout.DEFAULT_SIZE, 420, Short.MAX_VALUE)
                    .addComponent(DateRangeTextArea, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(MonthlyAnalysisTextArea, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                .addGap(40, 40, 40)
                .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(40, 40, 40))
        );
        DateTimeTabLayout.setVerticalGroup(
            DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(DateTimeTabLayout.createSequentialGroup()
                .addComponent(Left5, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
            .addGroup(DateTimeTabLayout.createSequentialGroup()
                .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                    .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, 514, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGroup(javax.swing.GroupLayout.Alignment.LEADING, DateTimeTabLayout.createSequentialGroup()
                        .addGap(40, 40, 40)
                        .addComponent(DateRangeLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(DateRangeTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 94, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(StartDateLabel)
                            .addComponent(StartDatePicker, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addGap(18, 18, 18)
                        .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(EndDatePicker, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(EndDateLabel))
                        .addGap(40, 40, 40)
                        .addComponent(MonthlyAnalysisLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(MonthlyAnalysisTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 48, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(MonthlyAnalysisCheckBox)
                        .addGap(18, 18, 18)
                        .addComponent(MonthlyAnalysisTextArea1, javax.swing.GroupLayout.PREFERRED_SIZE, 93, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        jTabbedPane1.addTab("Date / Time", DateTimeTab);

        RegionalTab.setBackground(new java.awt.Color(255, 255, 255));
        RegionalTab.setPreferredSize(new java.awt.Dimension(1000, 543));

        Left2.setBackground(new java.awt.Color(174, 211, 232));

        javax.swing.GroupLayout Left2Layout = new javax.swing.GroupLayout(Left2);
        Left2.setLayout(Left2Layout);
        Left2Layout.setHorizontalGroup(
            Left2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 25, Short.MAX_VALUE)
        );
        Left2Layout.setVerticalGroup(
            Left2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 543, Short.MAX_VALUE)
        );

        StateLabel.setText("State");
        StateLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        StateLabel.setForeground(new java.awt.Color(0, 112, 185));

        StateInfoLabel.setText("Isolate an evaluation dataset by state");
        StateInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        StateInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        StateComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Include all states", "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY" }));
        StateComboBox.setBackground(new java.awt.Color(191, 182, 172));
        StateComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        StateComboBox.setForeground(new java.awt.Color(0, 63, 105));
        StateComboBox.setMinimumSize(new java.awt.Dimension(215, 23));
        StateComboBox.setOpaque(true);
        StateComboBox.setPreferredSize(new java.awt.Dimension(215, 23));
        StateComboBox.setToolTipText("Only works for stations that have the state specified in the Metadata.  More stations will be added in the future.");

        ClimateLabel.setText("Climate Regions");
        ClimateLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        ClimateLabel.setForeground(new java.awt.Color(0, 112, 185));

        ClimateInfoLabel.setText("Isolate an evaluation dataset by climate region");
        ClimateInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        ClimateInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        ClimateComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Not Enabled", "Central", "East-North Central", "Northeast", "Northwest", "South", "Southeast", "Southwest", "West", "West-North Central" }));
        ClimateComboBox.setBackground(new java.awt.Color(191, 182, 172));
        ClimateComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ClimateComboBox.setForeground(new java.awt.Color(0, 63, 105));

        WorldLabel.setText("World Regions");
        WorldLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        WorldLabel.setForeground(new java.awt.Color(0, 112, 185));

        WorldInfoLabel.setText("Isolate an evaluation dataset by continent");
        WorldInfoLabel.setAlignmentX(0.5F);
        WorldInfoLabel.setBackground(new java.awt.Color(255, 255, 255));
        WorldInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        WorldInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        WorldComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Not Enabled", "North America", "U.S. & Canada", "South America", "Europe", "Asia" }));
        WorldComboBox.setBackground(new java.awt.Color(191, 182, 172));
        WorldComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        WorldComboBox.setForeground(new java.awt.Color(0, 63, 105));

        RPOLabel.setText("Regional Planning Organizations (RPO) Regions");
        RPOLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        RPOLabel.setForeground(new java.awt.Color(0, 112, 185));

        RPOInfoLabel.setText("Isolate an evaluation dataset by a RPO region");
        RPOInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        RPOInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        RPOComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Not Enabled", "VISTAS", "CENRAP", "MANE-VU", "LADCO", "WRAP" }));
        RPOComboBox.setBackground(new java.awt.Color(191, 182, 172));
        RPOComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        RPOComboBox.setForeground(new java.awt.Color(0, 63, 105));

        PCALabel.setText("Principal Component Analysis (PCA) Regions");
        PCALabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        PCALabel.setForeground(new java.awt.Color(0, 112, 185));

        PCAInfoLabel.setText("Isolate an evaluation dataset by PCA region");
        PCAInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        PCAInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        PCAComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Not Enabled", "Northeast (Ozone)", "Great Lakes (Ozone)", "Mid-Atlantic (Ozone)", "Southwest (Ozone)", "Northeast (Aerosols)", "Great Lakes (Aerosols)", "Southeast (Aerosols)", "Lower Midwest (Aerosols)", "West (Aerosols)" }));
        PCAComboBox.setBackground(new java.awt.Color(191, 182, 172));
        PCAComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        PCAComboBox.setForeground(new java.awt.Color(0, 63, 105));

        AerosolMapButton.setText("Map of Aerosol PCA Regions");
        AerosolMapButton.setAlignmentX(0.5F);
        AerosolMapButton.setBackground(new java.awt.Color(0, 63, 105));
        AerosolMapButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        AerosolMapButton.setForeground(new java.awt.Color(191, 182, 172));
        AerosolMapButton.setMaximumSize(new java.awt.Dimension(274, 23));
        AerosolMapButton.setMinimumSize(new java.awt.Dimension(274, 23));
        AerosolMapButton.setPreferredSize(new java.awt.Dimension(274, 23));
        AerosolMapButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                AerosolMapButtonActionPerformed(evt);
            }
        });

        OzoneMapButton.setText("Map of Ozone PCA Regions");
        OzoneMapButton.setAlignmentX(0.5F);
        OzoneMapButton.setBackground(new java.awt.Color(0, 63, 105));
        OzoneMapButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        OzoneMapButton.setForeground(new java.awt.Color(191, 182, 172));
        OzoneMapButton.setMaximumSize(new java.awt.Dimension(274, 23));
        OzoneMapButton.setMinimumSize(new java.awt.Dimension(274, 23));
        OzoneMapButton.setPreferredSize(new java.awt.Dimension(274, 23));
        OzoneMapButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                OzoneMapButtonActionPerformed(evt);
            }
        });

        LatLonLabel.setText("Latitude and Longitude");
        LatLonLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        LatLonLabel.setForeground(new java.awt.Color(0, 112, 185));

        LatLonTextArea.setColumns(20);
        LatLonTextArea.setEditable(false);
        LatLonTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        LatLonTextArea.setLineWrap(true);
        LatLonTextArea.setRows(5);
        LatLonTextArea.setText("Query data and set spatial plotting region based on latitude and longitude bounds. Latitude order must be given south to north, and Longitude order west to east. ");
        LatLonTextArea.setWrapStyleWord(true);
        LatLonTextArea.setBackground(new java.awt.Color(255, 255, 255));
        LatLonTextArea.setForeground(new java.awt.Color(0, 112, 185));

        LatLonPanel.setBackground(new java.awt.Color(255, 255, 255));

        LatLabel1.setText("Latitude from");
        LatLabel1.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        LatLabel1.setForeground(new java.awt.Color(0, 112, 185));

        LonLabel1.setText("Longitude from");
        LonLabel1.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        LonLabel1.setForeground(new java.awt.Color(0, 112, 185));

        LatLabel2.setText("to");
        LatLabel2.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        LatLabel2.setForeground(new java.awt.Color(0, 112, 185));

        LatTextField1.setBackground(new java.awt.Color(191, 182, 172));
        LatTextField1.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        LatTextField1.setForeground(new java.awt.Color(0, 63, 105));

        LatTextField2.setBackground(new java.awt.Color(191, 182, 172));
        LatTextField2.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        LatTextField2.setForeground(new java.awt.Color(0, 63, 105));

        LonLabel2.setText("to");
        LonLabel2.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        LonLabel2.setForeground(new java.awt.Color(0, 112, 185));

        LonTextField1.setBackground(new java.awt.Color(191, 182, 172));
        LonTextField1.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        LonTextField1.setForeground(new java.awt.Color(0, 63, 105));

        LonTextField2.setBackground(new java.awt.Color(191, 182, 172));
        LonTextField2.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        LonTextField2.setForeground(new java.awt.Color(0, 63, 105));

        javax.swing.GroupLayout LatLonPanelLayout = new javax.swing.GroupLayout(LatLonPanel);
        LatLonPanel.setLayout(LatLonPanelLayout);
        LatLonPanelLayout.setHorizontalGroup(
            LatLonPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(LatLonPanelLayout.createSequentialGroup()
                .addGroup(LatLonPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(LatLabel1)
                    .addComponent(LonLabel1))
                .addGap(6, 6, 6)
                .addGroup(LatLonPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, LatLonPanelLayout.createSequentialGroup()
                        .addComponent(LatTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, 64, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(LatLabel2)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(LatTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, 64, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, LatLonPanelLayout.createSequentialGroup()
                        .addComponent(LonTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, 64, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(LonLabel2)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(LonTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, 64, javax.swing.GroupLayout.PREFERRED_SIZE))))
        );
        LatLonPanelLayout.setVerticalGroup(
            LatLonPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(LatLonPanelLayout.createSequentialGroup()
                .addGroup(LatLonPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(LatTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(LatLabel2)
                    .addComponent(LatTextField2, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(LatLabel1))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(LatLonPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(LonTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(LonTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(LonLabel2)
                    .addComponent(LonLabel1)))
        );

        javax.swing.GroupLayout RegionalTabLayout = new javax.swing.GroupLayout(RegionalTab);
        RegionalTab.setLayout(RegionalTabLayout);
        RegionalTabLayout.setHorizontalGroup(
            RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(RegionalTabLayout.createSequentialGroup()
                .addComponent(Left2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addComponent(ClimateLabel)
                        .addGroup(RegionalTabLayout.createSequentialGroup()
                            .addGap(6, 6, 6)
                            .addComponent(LatLonPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                            .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                .addComponent(WorldLabel)
                                .addGroup(RegionalTabLayout.createSequentialGroup()
                                    .addGap(6, 6, 6)
                                    .addComponent(WorldInfoLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 336, javax.swing.GroupLayout.PREFERRED_SIZE)))
                            .addGroup(RegionalTabLayout.createSequentialGroup()
                                .addGap(6, 6, 6)
                                .addComponent(ClimateInfoLabel)))
                        .addComponent(LatLonLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 257, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(LatLonTextArea, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 377, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addComponent(ClimateComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(WorldComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 40, Short.MAX_VALUE)
                .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, RegionalTabLayout.createSequentialGroup()
                        .addGap(0, 0, Short.MAX_VALUE)
                        .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(AerosolMapButton, javax.swing.GroupLayout.PREFERRED_SIZE, 274, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(OzoneMapButton, javax.swing.GroupLayout.PREFERRED_SIZE, 274, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addGap(124, 124, 124))
                    .addGroup(RegionalTabLayout.createSequentialGroup()
                        .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(RPOComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(PCALabel)
                            .addComponent(StateComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(RPOLabel)
                            .addComponent(StateLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 67, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addGroup(RegionalTabLayout.createSequentialGroup()
                                .addGap(6, 6, 6)
                                .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addComponent(StateInfoLabel)
                                    .addComponent(RPOInfoLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 412, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(PCAInfoLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 412, javax.swing.GroupLayout.PREFERRED_SIZE)))
                            .addComponent(PCAComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addGap(40, 40, 40))))
        );
        RegionalTabLayout.setVerticalGroup(
            RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(RegionalTabLayout.createSequentialGroup()
                .addComponent(Left2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
            .addGroup(RegionalTabLayout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(StateLabel)
                    .addComponent(LatLonLabel))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(RegionalTabLayout.createSequentialGroup()
                        .addComponent(StateInfoLabel)
                        .addGap(18, 18, 18)
                        .addComponent(StateComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(24, 24, 24)
                        .addComponent(RPOLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(RPOInfoLabel)
                        .addGap(18, 18, 18)
                        .addComponent(RPOComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(24, 24, 24)
                        .addComponent(PCALabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(PCAInfoLabel)
                        .addGap(18, 18, 18)
                        .addComponent(PCAComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(40, 40, 40)
                        .addComponent(AerosolMapButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(OzoneMapButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(RegionalTabLayout.createSequentialGroup()
                        .addComponent(LatLonPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(LatLonTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 64, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(ClimateLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ClimateInfoLabel)
                        .addGap(18, 18, 18)
                        .addComponent(ClimateComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(24, 24, 24)
                        .addComponent(WorldLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(WorldInfoLabel)
                        .addGap(18, 18, 18)
                        .addComponent(WorldComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        jTabbedPane1.addTab("Regional", RegionalTab);

        SiteIDTab.setBackground(new java.awt.Color(255, 255, 255));

        Left3.setBackground(new java.awt.Color(174, 211, 232));
        Left3.setPreferredSize(new java.awt.Dimension(24, 543));

        javax.swing.GroupLayout Left3Layout = new javax.swing.GroupLayout(Left3);
        Left3.setLayout(Left3Layout);
        Left3Layout.setHorizontalGroup(
            Left3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 24, Short.MAX_VALUE)
        );
        Left3Layout.setVerticalGroup(
            Left3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 543, Short.MAX_VALUE)
        );

        SiteIDLabel.setText("Site ID");
        SiteIDLabel.setBackground(new java.awt.Color(255, 255, 255));
        SiteIDLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        SiteIDLabel.setForeground(new java.awt.Color(0, 112, 185));

        SiteIDTextArea.setColumns(20);
        SiteIDTextArea.setEditable(false);
        SiteIDTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SiteIDTextArea.setLineWrap(true);
        SiteIDTextArea.setRows(5);
        SiteIDTextArea.setText("Site ID option for a single or multiple observation sites. If Site ID is left blank, all available observations will be used. Required for surface Time Series analyses.");
        SiteIDTextArea.setWrapStyleWord(true);
        SiteIDTextArea.setBackground(new java.awt.Color(255, 255, 255));
        SiteIDTextArea.setForeground(new java.awt.Color(0, 112, 185));
        SiteIDTextArea.setPreferredSize(new java.awt.Dimension(400, 58));

        SiteIDTextField.setBackground(new java.awt.Color(191, 182, 172));
        SiteIDTextField.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SiteIDTextField.setForeground(new java.awt.Color(0, 63, 105));
        SiteIDTextField.setMinimumSize(new java.awt.Dimension(232, 22));
        SiteIDTextField.setPreferredSize(new java.awt.Dimension(232, 22));

        SiteIDTextArea1.setColumns(20);
        SiteIDTextArea1.setEditable(false);
        SiteIDTextArea1.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SiteIDTextArea1.setLineWrap(true);
        SiteIDTextArea1.setRows(5);
        SiteIDTextArea1.setText("When entering multiple sites for Time Series or Upper-Air Analyses, add a single space between each Site ID.\n\nExample: KRDU KGSO KATL");
        SiteIDTextArea1.setWrapStyleWord(true);
        SiteIDTextArea1.setBackground(new java.awt.Color(255, 255, 255));
        SiteIDTextArea1.setForeground(new java.awt.Color(0, 112, 185));
        SiteIDTextArea1.setPreferredSize(new java.awt.Dimension(400, 100));

        SiteIDTextArea2.setColumns(20);
        SiteIDTextArea2.setEditable(false);
        SiteIDTextArea2.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SiteIDTextArea2.setLineWrap(true);
        SiteIDTextArea2.setRows(5);
        SiteIDTextArea2.setText("For surface meteorology site finder, please reference NOAA's MADIS interactive interface.\n\nhttps://madis-data.ncep.noaa.gov/MadisSurface/");
        SiteIDTextArea2.setWrapStyleWord(true);
        SiteIDTextArea2.setBackground(new java.awt.Color(255, 255, 255));
        SiteIDTextArea2.setForeground(new java.awt.Color(0, 112, 185));
        SiteIDTextArea2.setPreferredSize(new java.awt.Dimension(400, 79));

        METNetworkLabel.setText("MET Observation Networks");
        METNetworkLabel.setBackground(new java.awt.Color(255, 255, 255));
        METNetworkLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        METNetworkLabel.setForeground(new java.awt.Color(0, 112, 185));

        METNetworkInfoLabel.setText("Query data based on monitoring network. Used for");
        METNetworkInfoLabel.setBackground(new java.awt.Color(255, 255, 255));
        METNetworkInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        METNetworkInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        SAOCheckBox.setText("SAO");
        SAOCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        SAOCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SAOCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        MaritimeCheckBox.setText("MARITIME");
        MaritimeCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        MaritimeCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        MaritimeCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        ASOSCheckBox.setText("ASOS");
        ASOSCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        ASOSCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ASOSCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        METARCheckBox.setText("METAR");
        METARCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        METARCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        METARCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        AllCheckBox.setText("All");
        AllCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AllCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        AllCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        AllCheckBox.setToolTipText("Selects MATAR, ASOS , MARITIME, and SAO");

        METNetworkInfoLabel1.setText("surface meteorology summary and daily statistics.");
        METNetworkInfoLabel1.setBackground(new java.awt.Color(255, 255, 255));
        METNetworkInfoLabel1.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        METNetworkInfoLabel1.setForeground(new java.awt.Color(0, 112, 185));

        MesonetCheckBox.setText("Mesonet");
        MesonetCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        MesonetCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        MesonetCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        javax.swing.GroupLayout SiteIDTabLayout = new javax.swing.GroupLayout(SiteIDTab);
        SiteIDTab.setLayout(SiteIDTabLayout);
        SiteIDTabLayout.setHorizontalGroup(
            SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(SiteIDTabLayout.createSequentialGroup()
                .addComponent(Left3, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addGroup(SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(SiteIDLabel)
                    .addComponent(SiteIDTextArea1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(SiteIDTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(SiteIDTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 350, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(SiteIDTextArea2, javax.swing.GroupLayout.PREFERRED_SIZE, 400, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 95, Short.MAX_VALUE)
                .addGroup(SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(METARCheckBox)
                    .addComponent(AllCheckBox)
                    .addComponent(ASOSCheckBox)
                    .addComponent(MaritimeCheckBox)
                    .addComponent(SAOCheckBox)
                    .addComponent(METNetworkLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(METNetworkInfoLabel)
                    .addComponent(METNetworkInfoLabel1)
                    .addComponent(MesonetCheckBox))
                .addGap(40, 40, 40))
        );
        SiteIDTabLayout.setVerticalGroup(
            SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(SiteIDTabLayout.createSequentialGroup()
                .addComponent(Left3, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
            .addGroup(SiteIDTabLayout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addGroup(SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(SiteIDTabLayout.createSequentialGroup()
                        .addComponent(METNetworkLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(METNetworkInfoLabel)
                        .addGap(0, 0, 0)
                        .addComponent(METNetworkInfoLabel1)
                        .addGap(18, 18, 18)
                        .addComponent(AllCheckBox)
                        .addGap(18, 18, 18)
                        .addComponent(METARCheckBox)
                        .addGap(18, 18, 18)
                        .addComponent(ASOSCheckBox)
                        .addGap(18, 18, 18)
                        .addComponent(MaritimeCheckBox)
                        .addGap(18, 18, 18)
                        .addComponent(SAOCheckBox)
                        .addGap(18, 18, 18)
                        .addComponent(MesonetCheckBox))
                    .addGroup(SiteIDTabLayout.createSequentialGroup()
                        .addComponent(SiteIDLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(SiteIDTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 64, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SiteIDTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SiteIDTextArea1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SiteIDTextArea2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        jTabbedPane1.addTab("Site ID / Networks", SiteIDTab);

        OutputPropertiesTab.setBackground(new java.awt.Color(255, 255, 255));

        Left6.setBackground(new java.awt.Color(174, 211, 232));
        Left6.setPreferredSize(new java.awt.Dimension(24, 543));

        javax.swing.GroupLayout Left6Layout = new javax.swing.GroupLayout(Left6);
        Left6.setLayout(Left6Layout);
        Left6Layout.setHorizontalGroup(
            Left6Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 24, Short.MAX_VALUE)
        );
        Left6Layout.setVerticalGroup(
            Left6Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 543, Short.MAX_VALUE)
        );

        CustomRunNameLabel.setText("Custom Run Name");
        CustomRunNameLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        CustomRunNameLabel.setForeground(new java.awt.Color(0, 112, 185));

        CustomRunNameTextField.setBackground(new java.awt.Color(191, 182, 172));
        CustomRunNameTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        CustomRunNameTextField.setForeground(new java.awt.Color(0, 63, 105));
        CustomRunNameTextField.setMinimumSize(new java.awt.Dimension(548, 23));
        CustomRunNameTextField.setPreferredSize(new java.awt.Dimension(548, 23));

        PlotlyImageLabel.setText("Plot Dimensions (pixels)");
        PlotlyImageLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        PlotlyImageLabel.setForeground(new java.awt.Color(0, 112, 185));

        PlotlyIamgeInfoTextArea.setColumns(20);
        PlotlyIamgeInfoTextArea.setEditable(false);
        PlotlyIamgeInfoTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        PlotlyIamgeInfoTextArea.setLineWrap(true);
        PlotlyIamgeInfoTextArea.setRows(5);
        PlotlyIamgeInfoTextArea.setText("Leave blank for default size (900 x 1600).");
        PlotlyIamgeInfoTextArea.setWrapStyleWord(true);
        PlotlyIamgeInfoTextArea.setBackground(new java.awt.Color(255, 255, 255));
        PlotlyIamgeInfoTextArea.setForeground(new java.awt.Color(0, 112, 185));
        PlotlyIamgeInfoTextArea.setMinimumSize(new java.awt.Dimension(447, 18));
        PlotlyIamgeInfoTextArea.setPreferredSize(new java.awt.Dimension(447, 18));

        PlotlyImagePanel.setBackground(new java.awt.Color(255, 255, 255));

        HeightLabel.setText("Height");
        HeightLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        HeightLabel.setForeground(new java.awt.Color(0, 112, 185));

        HeightTextField.setBackground(new java.awt.Color(191, 182, 172));
        HeightTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        HeightTextField.setForeground(new java.awt.Color(0, 63, 105));

        WidthLabel.setText("Width");
        WidthLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        WidthLabel.setForeground(new java.awt.Color(0, 112, 185));

        WidthTextField.setBackground(new java.awt.Color(191, 182, 172));
        WidthTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        WidthTextField.setForeground(new java.awt.Color(0, 63, 105));

        javax.swing.GroupLayout PlotlyImagePanelLayout = new javax.swing.GroupLayout(PlotlyImagePanel);
        PlotlyImagePanel.setLayout(PlotlyImagePanelLayout);
        PlotlyImagePanelLayout.setHorizontalGroup(
            PlotlyImagePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(PlotlyImagePanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(HeightLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(HeightTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 82, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(WidthLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(WidthTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 91, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        PlotlyImagePanelLayout.setVerticalGroup(
            PlotlyImagePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(PlotlyImagePanelLayout.createSequentialGroup()
                .addGap(0, 0, 0)
                .addGroup(PlotlyImagePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(HeightTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(WidthLabel)
                    .addComponent(HeightLabel)
                    .addComponent(WidthTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        GraphicsFormatLabel.setText("Graphics Format");
        GraphicsFormatLabel.setBackground(new java.awt.Color(255, 255, 255));
        GraphicsFormatLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        GraphicsFormatLabel.setForeground(new java.awt.Color(0, 112, 185));

        GraphicsFormatTextArea.setColumns(20);
        GraphicsFormatTextArea.setEditable(false);
        GraphicsFormatTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        GraphicsFormatTextArea.setLineWrap(true);
        GraphicsFormatTextArea.setRows(5);
        GraphicsFormatTextArea.setText("Specify plot format. PNG is recommended for Summary Analysis.\n Analysis.");
        GraphicsFormatTextArea.setWrapStyleWord(true);
        GraphicsFormatTextArea.setBackground(new java.awt.Color(255, 255, 255));
        GraphicsFormatTextArea.setDisabledTextColor(new java.awt.Color(0, 80, 184));
        GraphicsFormatTextArea.setForeground(new java.awt.Color(0, 112, 185));
        GraphicsFormatTextArea.setMinimumSize(new java.awt.Dimension(447, 18));
        GraphicsFormatTextArea.setPreferredSize(new java.awt.Dimension(447, 18));

        GraphicsFormatComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "PDF", "PNG" }));
        GraphicsFormatComboBox.setBackground(new java.awt.Color(191, 182, 172));
        GraphicsFormatComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        GraphicsFormatComboBox.setForeground(new java.awt.Color(0, 63, 105));

        CustomDirectoryNameLabel.setText("Custom Directory Name");
        CustomDirectoryNameLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        CustomDirectoryNameLabel.setForeground(new java.awt.Color(0, 112, 185));

        CustomDirectoryNameTextField.setBackground(new java.awt.Color(191, 182, 172));
        CustomDirectoryNameTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        CustomDirectoryNameTextField.setForeground(new java.awt.Color(0, 63, 105));
        CustomDirectoryNameTextField.setMinimumSize(new java.awt.Dimension(548, 23));
        CustomDirectoryNameTextField.setPreferredSize(new java.awt.Dimension(548, 23));

        jPanel2.setBackground(new java.awt.Color(255, 255, 255));
        jPanel2.setPreferredSize(new java.awt.Dimension(402, 435));

        SymbolSettingsLabel.setText("Symbol Settings");
        SymbolSettingsLabel.setBackground(new java.awt.Color(255, 255, 255));
        SymbolSettingsLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        SymbolSettingsLabel.setForeground(new java.awt.Color(0, 112, 185));

        SymbolLabel.setText("Symbol :");
        SymbolLabel.setBackground(new java.awt.Color(255, 255, 255));
        SymbolLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        SymbolLabel.setForeground(new java.awt.Color(0, 112, 185));

        SymbolComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Circle", "Square", "Diamond", "Triangle" }));
        SymbolComboBox.setBackground(new java.awt.Color(191, 182, 172));
        SymbolComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SymbolComboBox.setForeground(new java.awt.Color(0, 63, 105));

        SymbolScaleLabel.setText("Symbol Scale Factor (0.5 to 1.5):");
        SymbolScaleLabel.setBackground(new java.awt.Color(255, 255, 255));
        SymbolScaleLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        SymbolScaleLabel.setForeground(new java.awt.Color(0, 112, 185));

        SymbolScaleTextField.setBackground(new java.awt.Color(191, 182, 172));
        SymbolScaleTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SymbolScaleTextField.setForeground(new java.awt.Color(0, 63, 105));
        SymbolScaleTextField.setText("1.35");
        SymbolScaleTextField.setMaximumSize(new java.awt.Dimension(65, 23));
        SymbolScaleTextField.setMinimumSize(new java.awt.Dimension(65, 23));
        SymbolScaleTextField.setPreferredSize(new java.awt.Dimension(65, 23));

        TextScaleLabel.setText("Text Size Scale Factor:");
        TextScaleLabel.setBackground(new java.awt.Color(255, 255, 255));
        TextScaleLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        TextScaleLabel.setForeground(new java.awt.Color(0, 112, 185));

        TextScaleTextField.setBackground(new java.awt.Color(191, 182, 172));
        TextScaleTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        TextScaleTextField.setForeground(new java.awt.Color(0, 63, 105));
        TextScaleTextField.setText("0.65");
        TextScaleTextField.setMaximumSize(new java.awt.Dimension(65, 23));
        TextScaleTextField.setMinimumSize(new java.awt.Dimension(65, 23));
        TextScaleTextField.setPreferredSize(new java.awt.Dimension(65, 23));

        javax.swing.GroupLayout jPanel2Layout = new javax.swing.GroupLayout(jPanel2);
        jPanel2.setLayout(jPanel2Layout);
        jPanel2Layout.setHorizontalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel2Layout.createSequentialGroup()
                .addGroup(jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel2Layout.createSequentialGroup()
                        .addComponent(SymbolLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(SymbolComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addComponent(SymbolSettingsLabel)
                    .addGroup(jPanel2Layout.createSequentialGroup()
                        .addGroup(jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(TextScaleLabel)
                            .addComponent(SymbolScaleLabel))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(TextScaleTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 65, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(SymbolScaleTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 65, javax.swing.GroupLayout.PREFERRED_SIZE))))
                .addGap(0, 40, Short.MAX_VALUE))
        );
        jPanel2Layout.setVerticalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel2Layout.createSequentialGroup()
                .addComponent(SymbolSettingsLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(SymbolLabel)
                    .addComponent(SymbolComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(18, 18, 18)
                .addGroup(jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(SymbolScaleLabel)
                    .addComponent(SymbolScaleTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 23, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(18, 18, 18)
                .addGroup(jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(TextScaleLabel)
                    .addComponent(TextScaleTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 23, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addContainerGap(296, Short.MAX_VALUE))
        );

        ClearFilesLabel.setText("Clear Files from User Cache Directory");
        ClearFilesLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        ClearFilesLabel.setForeground(new java.awt.Color(0, 112, 185));

        ClearFilesTextField.setBackground(new java.awt.Color(191, 182, 172));
        ClearFilesTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ClearFilesTextField.setForeground(new java.awt.Color(0, 63, 105));
        ClearFilesTextField.setMinimumSize(new java.awt.Dimension(548, 23));
        ClearFilesTextField.setPreferredSize(new java.awt.Dimension(548, 23));
        ClearFilesTextField.addFocusListener(new java.awt.event.FocusAdapter() {
            public void focusLost(java.awt.event.FocusEvent evt) {
                ClearFilesTextFieldFocusLost(evt);
            }
        });

        ClearFilesButton.setText("Clear Files");
        ClearFilesButton.setBackground(new java.awt.Color(0, 63, 105));
        ClearFilesButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ClearFilesButton.setForeground(new java.awt.Color(191, 182, 172));
        ClearFilesButton.setMaximumSize(new java.awt.Dimension(378, 23));
        ClearFilesButton.setPreferredSize(new java.awt.Dimension(130, 23));
        ClearFilesButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                ClearFilesButtonActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout OutputPropertiesTabLayout = new javax.swing.GroupLayout(OutputPropertiesTab);
        OutputPropertiesTab.setLayout(OutputPropertiesTabLayout);
        OutputPropertiesTabLayout.setHorizontalGroup(
            OutputPropertiesTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(OutputPropertiesTabLayout.createSequentialGroup()
                .addComponent(Left6, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addGroup(OutputPropertiesTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(OutputPropertiesTabLayout.createSequentialGroup()
                        .addGroup(OutputPropertiesTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(CustomDirectoryNameLabel)
                            .addComponent(CustomDirectoryNameTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 447, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addGroup(OutputPropertiesTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                                .addComponent(CustomRunNameLabel, javax.swing.GroupLayout.Alignment.LEADING)
                                .addComponent(PlotlyImageLabel, javax.swing.GroupLayout.Alignment.LEADING)
                                .addComponent(GraphicsFormatLabel, javax.swing.GroupLayout.Alignment.LEADING)
                                .addComponent(GraphicsFormatComboBox, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.PREFERRED_SIZE, 140, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addComponent(PlotlyIamgeInfoTextArea, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                .addComponent(CustomRunNameTextField, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.PREFERRED_SIZE, 447, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addComponent(PlotlyImagePanel, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                            .addComponent(GraphicsFormatTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 470, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(ClearFilesLabel)
                            .addComponent(ClearFilesTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 447, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 67, Short.MAX_VALUE)
                        .addComponent(jPanel2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(OutputPropertiesTabLayout.createSequentialGroup()
                        .addComponent(ClearFilesButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(0, 0, Short.MAX_VALUE))))
        );
        OutputPropertiesTabLayout.setVerticalGroup(
            OutputPropertiesTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(OutputPropertiesTabLayout.createSequentialGroup()
                .addComponent(Left6, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
            .addGroup(OutputPropertiesTabLayout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addGroup(OutputPropertiesTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(OutputPropertiesTabLayout.createSequentialGroup()
                        .addComponent(CustomRunNameLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(CustomRunNameTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(24, 24, 24)
                        .addComponent(PlotlyImageLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(PlotlyIamgeInfoTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 18, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(PlotlyImagePanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(24, 24, 24)
                        .addComponent(GraphicsFormatLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(GraphicsFormatTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 18, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(GraphicsFormatComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(24, 24, 24)
                        .addComponent(CustomDirectoryNameLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(CustomDirectoryNameTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(ClearFilesLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ClearFilesTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addComponent(jPanel2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(ClearFilesButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        jTabbedPane1.addTab("Output Properties", OutputPropertiesTab);

        RunAnalysisTab.setBackground(new java.awt.Color(255, 255, 255));

        Left4.setBackground(new java.awt.Color(174, 211, 232));
        Left4.setPreferredSize(new java.awt.Dimension(24, 543));

        javax.swing.GroupLayout Left4Layout = new javax.swing.GroupLayout(Left4);
        Left4.setLayout(Left4Layout);
        Left4Layout.setHorizontalGroup(
            Left4Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 24, Short.MAX_VALUE)
        );
        Left4Layout.setVerticalGroup(
            Left4Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 543, Short.MAX_VALUE)
        );

        ProgramLabel.setText("Choose Evaluation Script");
        ProgramLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        ProgramLabel.setForeground(new java.awt.Color(0, 112, 185));

        ProgramTextArea.setColumns(20);
        ProgramTextArea.setEditable(false);
        ProgramTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        ProgramTextArea.setLineWrap(true);
        ProgramTextArea.setRows(5);
        ProgramTextArea.setText("Note that each program requires certain base inputs like temporal range and site ID(s), but also have optional settings.  Review each tab and Advanced Options on the bottom right to make sure the analysis extracts the desired data for the analysis.");
        ProgramTextArea.setWrapStyleWord(true);
        ProgramTextArea.setBackground(new java.awt.Color(255, 255, 255));
        ProgramTextArea.setBorder(null);
        ProgramTextArea.setForeground(new java.awt.Color(0, 112, 185));
        ProgramTextArea.setMinimumSize(new java.awt.Dimension(400, 80));
        ProgramTextArea.setPreferredSize(new java.awt.Dimension(400, 80));

        ProgramComboBox.setMaximumRowCount(20);
        ProgramComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Choose AMET Script to Execute", " ", "- Time Series Analysis -", "Time Series: 2-m Temp, 2-m Moisture and 10-m Wind", "Time Series: 2-m Temp, 2-m Moisture, 2-m RH and Sfc Pressure", " ", "- Daily Statistics Analysis -", "Daily Statistics: 2-m Temp, 2-m Moisture and 10-m Wind", " ", "- Summary Analysis -", "Summary Statistics: 2-m Temp, 2-m Moisture and 10-m Wind", " ", "- Spatial Surface Analysis -", "Spatial Statistics: 2-m Temp, 2-m Moisture and 10-m Wind", " ", "- Shortwave Radiation Analysis -", "Shortwave Radiation Statistics: Spatial, Diurnal and Time Series", " ", "- Upper-Air Analysis -", "Upper-Air: Spatial, Profile, Time Series and Curtain", "Upper-Air: Mandatory Spatial Statistics", "Upper-Air: Mandatory Time Series Statistics", "Upper-Air: Mandatory Profile Statistics", "Upper-Air: Mandatory Curtain", "Upper-Air: Native Theta / RH Profiles", "Upper-Air: Native Curtain" }));
        ProgramComboBox.setBackground(new java.awt.Color(191, 182, 172));
        ProgramComboBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        ProgramComboBox.setForeground(new java.awt.Color(0, 63, 105));
        ProgramComboBox.setMinimumSize(new java.awt.Dimension(548, 23));
        ProgramComboBox.setPreferredSize(new java.awt.Dimension(548, 23));

        METPlotOptionsLabel.setText("Miscellaneous Options");
        METPlotOptionsLabel.setBackground(new java.awt.Color(255, 255, 255));
        METPlotOptionsLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        METPlotOptionsLabel.setForeground(new java.awt.Color(0, 112, 185));

        MaxRecordsLabel.setText("Maxium Number of Record:");
        MaxRecordsLabel.setBackground(new java.awt.Color(255, 255, 255));
        MaxRecordsLabel.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        MaxRecordsLabel.setForeground(new java.awt.Color(0, 112, 185));

        MaxRecordsTextField.setText("5000000");
        MaxRecordsTextField.setBackground(new java.awt.Color(191, 182, 172));
        MaxRecordsTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        MaxRecordsTextField.setForeground(new java.awt.Color(0, 63, 105));
        MaxRecordsTextField.setPreferredSize(new java.awt.Dimension(100, 23));

        SaveFileCheckBox.setSelected(true);
        SaveFileCheckBox.setText("Generate R data file containing the data used in statistics plots");
        SaveFileCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        SaveFileCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SaveFileCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        TextOutCheckBox.setSelected(true);
        TextOutCheckBox.setText("Create text output file");
        TextOutCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        TextOutCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        TextOutCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        PlotSpecificAdvancedOptionsLabel.setText("Advanced Analysis-Specific Options");
        PlotSpecificAdvancedOptionsLabel.setBackground(new java.awt.Color(255, 255, 255));
        PlotSpecificAdvancedOptionsLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        PlotSpecificAdvancedOptionsLabel.setForeground(new java.awt.Color(0, 112, 185));

        BarPlotOptionsButton.setText("Daily Statistics Analysis");
        BarPlotOptionsButton.setBackground(new java.awt.Color(0, 63, 105));
        BarPlotOptionsButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        BarPlotOptionsButton.setForeground(new java.awt.Color(191, 182, 172));
        BarPlotOptionsButton.setMaximumSize(new java.awt.Dimension(378, 23));
        BarPlotOptionsButton.setPreferredSize(new java.awt.Dimension(378, 23));
        BarPlotOptionsButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BarPlotOptionsButtonActionPerformed(evt);
            }
        });

        TimeSeriesPlotOptionsButton.setText("Time Series Analysis");
        TimeSeriesPlotOptionsButton.setBackground(new java.awt.Color(0, 63, 105));
        TimeSeriesPlotOptionsButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        TimeSeriesPlotOptionsButton.setForeground(new java.awt.Color(191, 182, 172));
        TimeSeriesPlotOptionsButton.setMaximumSize(new java.awt.Dimension(378, 23));
        TimeSeriesPlotOptionsButton.setPreferredSize(new java.awt.Dimension(378, 23));
        TimeSeriesPlotOptionsButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                TimeSeriesPlotOptionsButtonActionPerformed(evt);
            }
        });

        DiurnalStatSummaryPlotOptionsButton.setText("Summary Analysis");
        DiurnalStatSummaryPlotOptionsButton.setBackground(new java.awt.Color(0, 63, 105));
        DiurnalStatSummaryPlotOptionsButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        DiurnalStatSummaryPlotOptionsButton.setForeground(new java.awt.Color(191, 182, 172));
        DiurnalStatSummaryPlotOptionsButton.setMaximumSize(new java.awt.Dimension(378, 23));
        DiurnalStatSummaryPlotOptionsButton.setPreferredSize(new java.awt.Dimension(378, 23));
        DiurnalStatSummaryPlotOptionsButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                DiurnalStatSummaryPlotOptionsButtonActionPerformed(evt);
            }
        });

        SpatialPlotOptionsButton.setText("Spatial Surface Analysis");
        SpatialPlotOptionsButton.setBackground(new java.awt.Color(0, 63, 105));
        SpatialPlotOptionsButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SpatialPlotOptionsButton.setForeground(new java.awt.Color(191, 182, 172));
        SpatialPlotOptionsButton.setMaximumSize(new java.awt.Dimension(378, 23));
        SpatialPlotOptionsButton.setMinimumSize(new java.awt.Dimension(378, 23));
        SpatialPlotOptionsButton.setPreferredSize(new java.awt.Dimension(378, 23));
        SpatialPlotOptionsButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                SpatialPlotOptionsButtonActionPerformed(evt);
            }
        });

        ShortwaveRadEvalPlotOptionsButton.setText("Shortwave Radiation Analysis");
        ShortwaveRadEvalPlotOptionsButton.setBackground(new java.awt.Color(0, 63, 105));
        ShortwaveRadEvalPlotOptionsButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ShortwaveRadEvalPlotOptionsButton.setForeground(new java.awt.Color(191, 182, 172));
        ShortwaveRadEvalPlotOptionsButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                ShortwaveRadEvalPlotOptionsButtonActionPerformed(evt);
            }
        });

        RAOBPlotOptionsButton.setText("Upper-Air Analysis");
        RAOBPlotOptionsButton.setBackground(new java.awt.Color(0, 63, 105));
        RAOBPlotOptionsButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        RAOBPlotOptionsButton.setForeground(new java.awt.Color(191, 182, 172));
        RAOBPlotOptionsButton.setMaximumSize(new java.awt.Dimension(378, 23));
        RAOBPlotOptionsButton.setPreferredSize(new java.awt.Dimension(378, 23));
        RAOBPlotOptionsButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                RAOBPlotOptionsButtonActionPerformed(evt);
            }
        });

        RunProgramButton.setText("Run Analysis");
        RunProgramButton.setBackground(new java.awt.Color(38, 161, 70));
        RunProgramButton.setFont(new java.awt.Font("Times New Roman", 1, 20)); // NOI18N
        RunProgramButton.setForeground(new java.awt.Color(0, 63, 105));
        RunProgramButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                RunProgramButtonActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout RunAnalysisTabLayout = new javax.swing.GroupLayout(RunAnalysisTab);
        RunAnalysisTab.setLayout(RunAnalysisTabLayout);
        RunAnalysisTabLayout.setHorizontalGroup(
            RunAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(RunAnalysisTabLayout.createSequentialGroup()
                .addComponent(Left4, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addGroup(RunAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(RunAnalysisTabLayout.createSequentialGroup()
                        .addGroup(RunAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(ProgramComboBox, 0, 0, Short.MAX_VALUE)
                            .addGroup(RunAnalysisTabLayout.createSequentialGroup()
                                .addGroup(RunAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addComponent(ProgramLabel)
                                    .addComponent(METPlotOptionsLabel)
                                    .addGroup(RunAnalysisTabLayout.createSequentialGroup()
                                        .addComponent(MaxRecordsLabel)
                                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                                        .addComponent(MaxRecordsTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                                    .addComponent(SaveFileCheckBox)
                                    .addComponent(TextOutCheckBox)
                                    .addComponent(ProgramTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                                .addGap(0, 0, Short.MAX_VALUE)))
                        .addGap(40, 40, 40)
                        .addGroup(RunAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addGroup(RunAnalysisTabLayout.createSequentialGroup()
                                .addGap(4, 4, 4)
                                .addGroup(RunAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addComponent(TimeSeriesPlotOptionsButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(DiurnalStatSummaryPlotOptionsButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(BarPlotOptionsButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(RAOBPlotOptionsButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addGroup(RunAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                                        .addComponent(SpatialPlotOptionsButton, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                        .addComponent(ShortwaveRadEvalPlotOptionsButton, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.PREFERRED_SIZE, 378, javax.swing.GroupLayout.PREFERRED_SIZE))))
                            .addComponent(PlotSpecificAdvancedOptionsLabel))
                        .addGap(435, 435, 435))
                    .addGroup(RunAnalysisTabLayout.createSequentialGroup()
                        .addComponent(RunProgramButton, javax.swing.GroupLayout.PREFERRED_SIZE, 200, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))))
        );
        RunAnalysisTabLayout.setVerticalGroup(
            RunAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(RunAnalysisTabLayout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addGroup(RunAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addGroup(RunAnalysisTabLayout.createSequentialGroup()
                        .addComponent(ProgramLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ProgramTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(ProgramComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(50, 50, 50)
                        .addComponent(METPlotOptionsLabel)
                        .addGap(18, 18, 18)
                        .addGroup(RunAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(MaxRecordsLabel)
                            .addComponent(MaxRecordsTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 23, javax.swing.GroupLayout.PREFERRED_SIZE)))
                    .addGroup(RunAnalysisTabLayout.createSequentialGroup()
                        .addComponent(PlotSpecificAdvancedOptionsLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(TimeSeriesPlotOptionsButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(BarPlotOptionsButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(DiurnalStatSummaryPlotOptionsButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SpatialPlotOptionsButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(ShortwaveRadEvalPlotOptionsButton)
                        .addGap(18, 18, 18)
                        .addComponent(RAOBPlotOptionsButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addGap(18, 18, 18)
                .addComponent(SaveFileCheckBox)
                .addGap(18, 18, 18)
                .addComponent(TextOutCheckBox)
                .addGap(86, 86, 86)
                .addComponent(RunProgramButton)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
            .addGroup(RunAnalysisTabLayout.createSequentialGroup()
                .addComponent(Left4, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
        );

        jTabbedPane1.addTab("Run Analysis", RunAnalysisTab);

        BackTab.setBackground(new java.awt.Color(255, 255, 255));

        Left8.setBackground(new java.awt.Color(174, 211, 232));
        Left8.setPreferredSize(new java.awt.Dimension(24, 543));

        javax.swing.GroupLayout Left8Layout = new javax.swing.GroupLayout(Left8);
        Left8.setLayout(Left8Layout);
        Left8Layout.setHorizontalGroup(
            Left8Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 24, Short.MAX_VALUE)
        );
        Left8Layout.setVerticalGroup(
            Left8Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 543, Short.MAX_VALUE)
        );

        ReturnButton.setText("Return to Welcome Screen");
        ReturnButton.setBackground(new java.awt.Color(0, 63, 105));
        ReturnButton.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        ReturnButton.setForeground(new java.awt.Color(191, 182, 172));
        ReturnButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                ReturnButtonActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout BackTabLayout = new javax.swing.GroupLayout(BackTab);
        BackTab.setLayout(BackTabLayout);
        BackTabLayout.setHorizontalGroup(
            BackTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(BackTabLayout.createSequentialGroup()
                .addComponent(Left8, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addComponent(ReturnButton, javax.swing.GroupLayout.PREFERRED_SIZE, 286, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 40, Short.MAX_VALUE))
        );
        BackTabLayout.setVerticalGroup(
            BackTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(BackTabLayout.createSequentialGroup()
                .addComponent(Left8, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
            .addGroup(BackTabLayout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addComponent(ReturnButton)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        jTabbedPane1.addTab("Back", BackTab);

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(Header)
                    .addComponent(jTabbedPane1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(Footer, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                .addGap(0, 0, 0))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addComponent(Header)
                .addGap(0, 0, 0)
                .addComponent(jTabbedPane1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, 0)
                .addComponent(Footer))
        );

        jTabbedPane1.getAccessibleContext().setAccessibleName("MET Form");
        jTabbedPane1.getAccessibleContext().setAccessibleDescription("");

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void AerosolMapButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_AerosolMapButtonActionPerformed
        new AerosolMap().setVisible(true);
    }//GEN-LAST:event_AerosolMapButtonActionPerformed

    private void OzoneMapButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_OzoneMapButtonActionPerformed
        new OzoneMap().setVisible(true);
    }//GEN-LAST:event_OzoneMapButtonActionPerformed

    private void TimeSeriesPlotOptionsButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_TimeSeriesPlotOptionsButtonActionPerformed
        TimeSeriesPlotOptions tspOptions = new TimeSeriesPlotOptions(this);
        tspOptions.setVisible(true);
    }//GEN-LAST:event_TimeSeriesPlotOptionsButtonActionPerformed

    private void SpatialPlotOptionsButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_SpatialPlotOptionsButtonActionPerformed
        SpatialPlotOptions spOptions = new SpatialPlotOptions(this);
        spOptions.setVisible(true);
    }//GEN-LAST:event_SpatialPlotOptionsButtonActionPerformed

    private void RunProgramButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_RunProgramButtonActionPerformed
        saveVariables();
        
        if (!checkVariables()) {
            createRunInfo();
            executeProgram();
            if (MonthlyAnalysisCheckBox.isSelected()) {
                new WrapperPopUpWindow(file_path).setVisible(true);
            }
            else if (SeasonalAnalysisCheckBox.isSelected()) {
                new WrapperPopUpWindow(file_path).setVisible(true);
            }
            else {
                outputWindow();
            }
        }
    }//GEN-LAST:event_RunProgramButtonActionPerformed

    private void BarPlotOptionsButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BarPlotOptionsButtonActionPerformed
        DailyBarPlotOptions dbpOptions = new DailyBarPlotOptions(this);
        dbpOptions.setVisible(true);
    }//GEN-LAST:event_BarPlotOptionsButtonActionPerformed

    private void DiurnalStatSummaryPlotOptionsButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_DiurnalStatSummaryPlotOptionsButtonActionPerformed
        SummaryPlotOptions spOptions = new SummaryPlotOptions(this);
        spOptions.setVisible(true);
    }//GEN-LAST:event_DiurnalStatSummaryPlotOptionsButtonActionPerformed

    private void ShortwaveRadEvalPlotOptionsButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ShortwaveRadEvalPlotOptionsButtonActionPerformed
        RadiationPlotOptions rpOptions = new RadiationPlotOptions(this);
        rpOptions.setVisible(true);
    }//GEN-LAST:event_ShortwaveRadEvalPlotOptionsButtonActionPerformed

    private void RAOBPlotOptionsButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_RAOBPlotOptionsButtonActionPerformed
        script = ProgramComboBox.getSelectedItem().toString();
        RAOBPlotOptions raobOptions = new RAOBPlotOptions(this, script);
        raobOptions.setVisible(true);
    }//GEN-LAST:event_RAOBPlotOptionsButtonActionPerformed

    private void ReturnButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ReturnButtonActionPerformed
        new WelcomeScreen().setVisible(true);
        setVisible(false);
        dispose();
    }//GEN-LAST:event_ReturnButtonActionPerformed

    private void SelectAdditionalProjectComboBox2ItemStateChanged(java.awt.event.ItemEvent evt) {//GEN-FIRST:event_SelectAdditionalProjectComboBox2ItemStateChanged
        //Check to see if project is selectable
        try {
            SelectAdditionalProjectComboBox2.getSelectedItem().toString();
        } catch (Exception e) {
            return;
        }

        //check to see if value has changed, issue with "ItemStateChange" calling twice
        if (project_id2.equals(SelectAdditionalProjectComboBox2.getSelectedItem().toString())) {
            return;
        }
        else {
            project_id2 = SelectAdditionalProjectComboBox2.getSelectedItem().toString();
        }

        setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));

        try {
            String database = SelectAdditionalDatabaseComboBox.getSelectedItem().toString();
            DBConnection db = new DBConnection();
            db.getDBConnection();
            db.query("USE " + database + ";");
            db.query("SELECT proj_code,user_id,model,email,description,DATE_FORMAT(proj_date,'%m/%d/%Y'),proj_time,DATE_FORMAT(min_date,'%m/%d/%Y'),DATE_FORMAT(max_date,'%m/%d/%Y') FROM project_log WHERE proj_code = '" + project_id + "';");
            ResultSet rs = db.getRS();

            while (rs.next()) {
                ProjectDetailsTextArea.setText( ""
                    + "Project Code: " + rs.getString(1) + "\n\n"
                    + "Model: " + rs.getString(3) + "\n\n"
                    + "Owner: " + rs.getString(2) + "\n\n"
                    + "Description: " + rs.getString(5) + "\n"
                    + "Project Creation Date: " + rs.getString(6) + "\n\n"
                    + "Earliest Record: " + rs.getString(8) + "\n\n"
                    + "Last Database Population Occurred on " + rs.getString(9) + "\n\n"
                );
            }

            db.closeDBConnection();

        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Query Failed");
        }

        setCursor(Cursor.getPredefinedCursor(Cursor.DEFAULT_CURSOR));
    }//GEN-LAST:event_SelectAdditionalProjectComboBox2ItemStateChanged

    private void SelectAdditionalDatabaseComboBoxItemStateChanged(java.awt.event.ItemEvent evt) {//GEN-FIRST:event_SelectAdditionalDatabaseComboBoxItemStateChanged
        //Check to see if database is selectable
        try {
            SelectAdditionalDatabaseComboBox.getSelectedItem().toString();
        } catch (Exception e) {
            return;
        }

        //check to see if value has changed, issue with "ItemStateChange" calling twice
        if (dbase2.equals(SelectAdditionalDatabaseComboBox.getSelectedItem().toString())) { return; }

        //Populates project Combo Boxes
        setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));

        try {
            dbase2 = SelectAdditionalDatabaseComboBox.getSelectedItem().toString();
        }
        catch (Exception e) {

        }

        if (!dbase2.equals("Choose a database") || !dbase2.equals("Query Failed")) {
            SelectAdditionalProjectComboBox2.removeAllItems();

            try {
                DBConnection db = new DBConnection();
                db.getDBConnection();
                db.query("USE " + dbase2 + ";");
                db.query("SELECT proj_code, user_id, DATE_FORMAT(proj_date,'%m/%d/%Y'), proj_time, description FROM project_log ORDER BY proj_code");
                ResultSet rs = db.getRS();
                ResultSetMetaData rsmd = rs.getMetaData();

                SelectAdditionalProjectComboBox2.addItem(new ComboItem("Choose a Project", "Choose a Project"));
                int columnsNumber = rsmd.getColumnCount();
                while (rs.next()) {
                    String columnValue = rs.getString(1);
                    SelectAdditionalProjectComboBox2.addItem(new ComboItem("Project ID: " + rs.getString(1) + ", User ID: " + rs.getString(2) + ", SetupDate: " + rs.getString(3), rs.getString(1) ));
                }

                db.closeDBConnection();

            } catch (SQLException e) {

            }
        }

        setCursor(Cursor.getPredefinedCursor(Cursor.DEFAULT_CURSOR));
    }//GEN-LAST:event_SelectAdditionalDatabaseComboBoxItemStateChanged

    private void SelectProjectComboBoxItemStateChanged(java.awt.event.ItemEvent evt) {//GEN-FIRST:event_SelectProjectComboBoxItemStateChanged
        //Check to see if project is selectable

        try {
            SelectProjectComboBox.getSelectedItem().toString();
        } catch (Exception e) {
            return;
        }

        //check to see if value has changed, issue with "ItemStateChange" calling twice
        if (project_id.equals(SelectProjectComboBox.getSelectedItem().toString())) {
            return;
        } else {
            project_id = SelectProjectComboBox.getSelectedItem().toString();
        }

        setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));

        try {
            DBConnection db = new DBConnection();
            db.getDBConnection();
            db.query("USE " + dbase + ";");
            db.query("SELECT proj_code,user_id,model,email,description,DATE_FORMAT(proj_date,'%m/%d/%Y'),proj_time,DATE_FORMAT(min_date,'%m/%d/%Y'),DATE_FORMAT(max_date,'%m/%d/%Y') FROM project_log WHERE proj_code = '" + project_id + "';");
            ResultSet rs = db.getRS();

            while (rs.next()) {
                Project_Code = rs.getString(1);
                Model = rs.getString(3);
                Owner = rs.getString(2);
                Description = rs.getString(5);
                Project_Creation_Date = rs.getString(6);
            }

            if(project_id != "Choose a Project"){
                db.getDBConnection();
                db.query("USE " + dbase + ";");
                db.query("SELECT DATE_FORMAT(min(ob_date),'%m/%d/%Y'),DATE_FORMAT(max(ob_date),'%m/%d/%Y') from " + project_id + "_surface;");
                ResultSet rs_date = db.getRS();

                while (rs_date.next()) {
                    Earliest_Record = rs_date.getString(1);
                    Latest_Record = rs_date.getString(2);

                    //Save Project Dates
                    year_start = rs_date.getString(1).substring(6, 10);
                    month_start = rs_date.getString(1).substring(0, 2);
                    day_start = rs_date.getString(1).substring(3, 5);

                    year_end = rs_date.getString(2).substring(6, 10);
                    month_end  = rs_date.getString(2).substring(0, 2);
                    day_end  = rs_date.getString(2).substring(3, 5);
                }}

                ProjectDetailsTextArea.setText( ""
                    + "Project ID: " + Project_Code + "\n\n"
                    + "Model: " + Model + "\n\n"
                    + "Owner: " + Owner + "\n\n"
                    + "Description: " + Description + "\n\n"
                    + "Last Database Population: " + Project_Creation_Date + "\n\n"
                    + "Earliest Record: " + Earliest_Record + "\n\n"
                    + "Lastest Record: " + Latest_Record + "\n\n"
                );

                //Auto set the dates for the project
                StartDatePicker.setText(year_start + "/" + month_start + "/" + day_start);
                EndDatePicker.setText(year_end + "/" + month_end + "/" + day_end);

                db.closeDBConnection();

            } catch (SQLException e) {
                e.printStackTrace();
                System.out.println("Query Failed");
            }

            setCursor(Cursor.getPredefinedCursor(Cursor.DEFAULT_CURSOR));
    }//GEN-LAST:event_SelectProjectComboBoxItemStateChanged

    private void SelectDatabaseComboBoxItemStateChanged(java.awt.event.ItemEvent evt) {//GEN-FIRST:event_SelectDatabaseComboBoxItemStateChanged
        //Check to see if database is selectable
        try {
            SelectDatabaseComboBox.getSelectedItem().toString();
        } catch (Exception e) {
            return;
        }

        //check to see if value has changed, issue with "ItemStateChange" calling twice
        if (dbase.equals(SelectDatabaseComboBox.getSelectedItem().toString())) { return; }

        //Populates project Combo Boxes
        setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));

        try {
            dbase = SelectDatabaseComboBox.getSelectedItem().toString();
        }
        catch (Exception e) {

        }

        if (!dbase.equals("Choose a database") || !dbase.equals("Query Failed")) {
            SelectProjectComboBox.removeAllItems();
            //SelectAdditionalProjectComboBox1.removeAllItems();

            try {
                DBConnection db = new DBConnection();
                db.getDBConnection();
                db.query("USE " + dbase + ";");
                db.query("SELECT proj_code, user_id, DATE_FORMAT(proj_date,'%m/%d/%Y'), proj_time, description FROM project_log ORDER BY proj_code");
                ResultSet rs = db.getRS();
                ResultSetMetaData rsmd = rs.getMetaData();

                SelectProjectComboBox.addItem(new ComboItem("Choose a Project", "Choose a Project"));
                int columnsNumber = rsmd.getColumnCount();
                while (rs.next()) {
                    String columnValue = rs.getString(1);
                    SelectProjectComboBox.addItem(new ComboItem("Project ID: " + rs.getString(1) + ", User ID: " + rs.getString(2) + ", SetupDate: " + rs.getString(3), rs.getString(1) ));
                }
                db.closeDBConnection();

            } catch (SQLException e) {

            }
        }

        setCursor(Cursor.getPredefinedCursor(Cursor.DEFAULT_CURSOR));
    }//GEN-LAST:event_SelectDatabaseComboBoxItemStateChanged

    private void ClearFilesButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ClearFilesButtonActionPerformed
        ClearFilesWindow cfw = new ClearFilesWindow(dir_path, path);
        cfw.setVisible(true);
    }//GEN-LAST:event_ClearFilesButtonActionPerformed

    private void ClearFilesTextFieldFocusLost(java.awt.event.FocusEvent evt) {//GEN-FIRST:event_ClearFilesTextFieldFocusLost
        dir_name_delete = ClearFilesTextField.getText();
        dir_path = "guidir."  + username + "." + dir_name_delete;
        path = config.dir_name  + username + "." + dir_name_delete;
    }//GEN-LAST:event_ClearFilesTextFieldFocusLost

    /**
     * @param args the command line arguments
     */

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JCheckBox ASOSCheckBox;
    private javax.swing.JButton AerosolMapButton;
    private javax.swing.JCheckBox AllCheckBox;
    private javax.swing.JPanel BackTab;
    private javax.swing.JButton BarPlotOptionsButton;
    private javax.swing.JButton ClearFilesButton;
    private javax.swing.JLabel ClearFilesLabel;
    private javax.swing.JTextField ClearFilesTextField;
    private javax.swing.JComboBox<String> ClimateComboBox;
    private javax.swing.JLabel ClimateInfoLabel;
    private javax.swing.JLabel ClimateLabel;
    private javax.swing.JLabel CustomDirectoryNameLabel;
    private javax.swing.JTextField CustomDirectoryNameTextField;
    private javax.swing.JLabel CustomRunNameLabel;
    private javax.swing.JTextField CustomRunNameTextField;
    private javax.swing.JLabel DateRangeLabel;
    private javax.swing.JTextArea DateRangeTextArea;
    private javax.swing.JPanel DateTimeTab;
    private javax.swing.JButton DiurnalStatSummaryPlotOptionsButton;
    private javax.swing.JLabel EndDateLabel;
    private com.github.lgooddatepicker.components.DatePicker EndDatePicker;
    private javax.swing.JComboBox<String> EndHourComboBox;
    private javax.swing.JLabel EndHourLabel;
    private javax.swing.JLabel Footer;
    private javax.swing.JComboBox<String> GraphicsFormatComboBox;
    private javax.swing.JLabel GraphicsFormatLabel;
    private javax.swing.JTextArea GraphicsFormatTextArea;
    private javax.swing.JLabel Header;
    private javax.swing.JLabel HeightLabel;
    private javax.swing.JTextField HeightTextField;
    private javax.swing.JLabel HourRangeLabel;
    private javax.swing.JTextArea HourRangeTextArea;
    private javax.swing.JLabel LatLabel1;
    private javax.swing.JLabel LatLabel2;
    private javax.swing.JLabel LatLonLabel;
    private javax.swing.JPanel LatLonPanel;
    private javax.swing.JTextArea LatLonTextArea;
    private javax.swing.JTextField LatTextField1;
    private javax.swing.JTextField LatTextField2;
    private javax.swing.JPanel Left1;
    private javax.swing.JPanel Left2;
    private javax.swing.JPanel Left3;
    private javax.swing.JPanel Left4;
    private javax.swing.JPanel Left5;
    private javax.swing.JPanel Left6;
    private javax.swing.JPanel Left8;
    private javax.swing.JLabel LonLabel1;
    private javax.swing.JLabel LonLabel2;
    private javax.swing.JTextField LonTextField1;
    private javax.swing.JTextField LonTextField2;
    private javax.swing.JCheckBox METARCheckBox;
    private javax.swing.JLabel METNetworkInfoLabel;
    private javax.swing.JLabel METNetworkInfoLabel1;
    private javax.swing.JLabel METNetworkLabel;
    private javax.swing.JLabel METPlotOptionsLabel;
    private javax.swing.JCheckBox MaritimeCheckBox;
    private javax.swing.JLabel MaxRecordsLabel;
    private javax.swing.JTextField MaxRecordsTextField;
    private javax.swing.JCheckBox MesonetCheckBox;
    private javax.swing.JCheckBox MonthlyAnalysisCheckBox;
    private javax.swing.JLabel MonthlyAnalysisLabel;
    private javax.swing.JTextArea MonthlyAnalysisTextArea;
    private javax.swing.JTextArea MonthlyAnalysisTextArea1;
    private javax.swing.JPanel OutputPropertiesTab;
    private javax.swing.JButton OzoneMapButton;
    private javax.swing.JComboBox<String> PCAComboBox;
    private javax.swing.JLabel PCAInfoLabel;
    private javax.swing.JLabel PCALabel;
    private javax.swing.JLabel PlotSpecificAdvancedOptionsLabel;
    private javax.swing.JTextArea PlotlyIamgeInfoTextArea;
    private javax.swing.JLabel PlotlyImageLabel;
    private javax.swing.JPanel PlotlyImagePanel;
    private javax.swing.JComboBox<String> ProgramComboBox;
    private javax.swing.JLabel ProgramLabel;
    private javax.swing.JTextArea ProgramTextArea;
    private javax.swing.JLabel ProjectDetailsLabel;
    private javax.swing.JTextArea ProjectDetailsTextArea;
    private javax.swing.JPanel ProjectTab;
    private javax.swing.JButton RAOBPlotOptionsButton;
    private javax.swing.JComboBox<String> RPOComboBox;
    private javax.swing.JLabel RPOInfoLabel;
    private javax.swing.JLabel RPOLabel;
    private javax.swing.JPanel RegionalTab;
    private javax.swing.JButton ReturnButton;
    private javax.swing.JPanel RunAnalysisTab;
    private javax.swing.JButton RunProgramButton;
    private javax.swing.JCheckBox SAOCheckBox;
    private javax.swing.JCheckBox SaveFileCheckBox;
    private javax.swing.JCheckBox SeasonalAnalysisCheckBox;
    private javax.swing.JTextArea SeasonalAnalysisTextArea;
    private javax.swing.JLabel SeasonalLabel;
    private javax.swing.JTextArea SeasonalTextArea;
    private javax.swing.JComboBox<String> SelectAdditionalDatabaseComboBox;
    private javax.swing.JLabel SelectAdditionalDatabaseInfoLabel;
    private javax.swing.JLabel SelectAdditionalDatabaseLabel;
    private javax.swing.JComboBox<ComboItem> SelectAdditionalProjectComboBox2;
    private javax.swing.JLabel SelectAdditionalProjectInfoLabel2;
    private javax.swing.JLabel SelectAdditionalProjectLabel2;
    private javax.swing.JComboBox<String> SelectDatabaseComboBox;
    private javax.swing.JLabel SelectDatabaseLabel;
    private javax.swing.JComboBox<ComboItem> SelectProjectComboBox;
    private javax.swing.JLabel SelectProjectLabel;
    private javax.swing.JButton ShortwaveRadEvalPlotOptionsButton;
    private javax.swing.JLabel SiteIDLabel;
    private javax.swing.JPanel SiteIDTab;
    private javax.swing.JTextArea SiteIDTextArea;
    private javax.swing.JTextArea SiteIDTextArea1;
    private javax.swing.JTextArea SiteIDTextArea2;
    private javax.swing.JTextField SiteIDTextField;
    private javax.swing.JButton SpatialPlotOptionsButton;
    private javax.swing.JLabel StartDateLabel;
    private com.github.lgooddatepicker.components.DatePicker StartDatePicker;
    private javax.swing.JComboBox<String> StartHourComboBox;
    private javax.swing.JLabel StartHourLabel;
    private javax.swing.JComboBox<String> StateComboBox;
    private javax.swing.JLabel StateInfoLabel;
    private javax.swing.JLabel StateLabel;
    private javax.swing.JComboBox<String> SymbolComboBox;
    private javax.swing.JLabel SymbolLabel;
    private javax.swing.JLabel SymbolScaleLabel;
    private javax.swing.JTextField SymbolScaleTextField;
    private javax.swing.JLabel SymbolSettingsLabel;
    private javax.swing.JCheckBox TextOutCheckBox;
    private javax.swing.JLabel TextScaleLabel;
    private javax.swing.JTextField TextScaleTextField;
    private javax.swing.JButton TimeSeriesPlotOptionsButton;
    private javax.swing.JLabel WidthLabel;
    private javax.swing.JTextField WidthTextField;
    private javax.swing.JComboBox<String> WorldComboBox;
    private javax.swing.JLabel WorldInfoLabel;
    private javax.swing.JLabel WorldLabel;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JPanel jPanel2;
    private javax.swing.JTabbedPane jTabbedPane1;
    // End of variables declaration//GEN-END:variables
}
