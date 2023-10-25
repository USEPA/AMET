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
import java.awt.Cursor;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.Random;
import javax.swing.JFileChooser;

public class MeteorologyForm extends javax.swing.JFrame {
    Config config = new Config();

    //Variable instantiation and setting default values
    public String run_program = "";
    public String amet_static = "";
    public String script = "";
    public String query = "\"\""; 
    public String file_path = "\"\"";
    public String dir_path = "\"\"";
    public String figdir = "\"\"";
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
    public boolean wrapper = false;
    public String annual_PRISM = "";
    public String daily_PRISM = "";
    public String monthly_PRISM = "";
    public String precip_dir_name = "";
    public String WRF_file = "";
    public String model_prefix = "";
    public String start_time_index = "";
    public String end_time_index = "";
    public String netCDF = "";
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
    public String dates = "\"\""; 
    public String year_start = "\"\"";
    public int start_year;
    public int end_year;
    public int start_month;
    public int end_month;
    public int start_day;
    public int end_day;
    public String month_name = "\"\"";
    public String year_end = "\"\"";
    public String month_start = "\"\"";
    public String month_end = "\"\"";
    public String day_start = "\"\"";
    public String day_end = "\"\"";
    public String s_day_start = "\"\"";
    public String s_month_start = "\"\"";
    public String s_day_end = "\"\"";
    public String s_month_end = "\"\"";
    public String year_start1 = "\"\"";
    public int start_year1;
    public int end_year1;
    public int start_month1;
    public int end_month1;
    public int start_day1;
    public int end_day1;
    public String year_end1 = "\"\"";
    public String month_start1 = "\"\"";
    public String month_end1 = "\"\"";
    public String day_start1 = "\"\"";
    public String day_end1 = "\"\"";
    public String s_day_start1 = "\"\"";
    public String s_month_start1 = "\"\"";
    public String s_day_end1 = "\"\"";
    public String s_month_end1 = "\"\"";
    public String site_id = "\"\"";
    public String site = "";
    public String run_id = "AMET_GUI";
    public String run_id_reset = "AMET_GUI";
    public String start_hour = "\"\"";
    public String hs = "\"\"";
    public String end_hour = "\"\"";
    public String he = "\"\"";
    public String start_range = "\"\"";
    public String rs = "\"\"";
    public String end_range = "\"\"";
    public String re = "\"\"";
    public String initial_time = "\"\"";
    public String it = "\"\"";
    
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
    public String model = "";
    public String grid_spacing = "";
    public String Owner = "";
    public String Description = "";
    public String Project_Creation_Date = "";
    public String Earliest_Record = "";
    public String Latest_Record = "";
    public String country = "";
    public String state = "\"\"";
    public String continent = "";
    public String username = System.getProperty("user.name");
    public String script_wrapper = "";
    public String analysis_wrapper = "";
    
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
        
        //Sets format for dates in the date picker
        DatePickerSettings startDateSettings1 = new DatePickerSettings();
        DatePickerSettings endDateSettings1 = new DatePickerSettings();
        startDateSettings1.setFormatForDatesCommonEra("yyyy/MM/dd");
        endDateSettings1.setFormatForDatesCommonEra("yyyy/MM/dd");
        StartDatePicker1.setSettings(startDateSettings1);
        EndDatePicker1.setSettings(endDateSettings1);
        
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
        
        if (!PrecipDirectoryTextField.getText().equals("")) {
            precip_dir_name = PrecipDirectoryTextField.getText();
            CustomDirectoryNameTextField.setText(precip_dir_name);
        }
        
        //Output properties formatting
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
        max_rec = MaxRecordsTextField.getText();
        model_prefix = ModelOutputTextField.getText();
        grid_spacing = GridSpacingTextField.getText();
        start_time_index = StartTimeIndexTextField.getText();
        end_time_index = EndTimeIndexTextField.getText();
        netCDF = checkBoxFormat(NetCDFCheckBox);
        
        //precip formatting
        if (MonthlyAnalysisCheckBox.isSelected()){
            analysis_wrapper = "MN";
        }
        else if (SeasonalAnalysisCheckBox.isSelected()){
            analysis_wrapper = "SE";
        }
        else if (ClimateRegionMonthlyCheckBox.isSelected()){
            analysis_wrapper = "RM";
        }
        else if (ClimateRegionSeasonalCheckBox.isSelected()){
            analysis_wrapper = "RS";
        }
        else if (DailyRadioButton.isSelected()){
            analysis_wrapper = "DA";
        }
        else if (MonthlyRadioButton.isSelected()){
            analysis_wrapper = "MN";
        }
        else if (AnnualRadioButton.isSelected()){
            analysis_wrapper = "AN";
        }
        //else if (wrapper = true){
            //analysis_wrapper = "NP";
        //}
        else {
            analysis_wrapper = "";
        }

        //state formatting
        state = StateComboBox.getSelectedItem().toString();
        if (state.equals("Select a State")) {
            state = "\"All\"";
        } 
        else {
            state = "'" + state + "'";
        }
        
        //country formatting
        country = CountryComboBox.getSelectedItem().toString();
        if (country.equals("Select a Country")) {
            country = "\"All\"";
        } 
        else {
        country = "'" + country + "'";
        }
        
        //continent formatting
        continent = ContinentComboBox.getSelectedItem().toString();
        if (continent.equals("Select a Region")) {
            continent = "\"All\"";
        } 
        else {
        continent = continent;
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
        
        String sd1 = StartDatePicker1.getDateStringOrEmptyString();
        String ed1 = EndDatePicker1.getDateStringOrEmptyString();
        
        if (!sd1.equals("")) {
            year_start1 = sd1.substring(0, 4);
            month_start1 = sd1.substring(5, 7);
            day_start1 = sd1.substring(8, 10);
            
            start_year1 = Integer.parseInt(year_start1);
            start_month1 = Integer.parseInt(month_start1);
            start_day1 = Integer.parseInt(day_start1);
            
            if("0".equals(sd.substring(8,9))){
                s_day_start1 = sd1.substring(9, 10);
            }
            else {
                s_day_start1 = day_start1;
            }
            if("0".equals(sd1.substring(5,6))){
                s_month_start1 = sd1.substring(6, 7);
            }
            else {
                s_month_start1 = month_start1;
            }
        }
        if (!ed1.equals("")) {
            year_end1 = ed1.substring(0, 4);
            month_end1  = ed1.substring(5, 7);
            day_end1  = ed1.substring(8, 10);
            
            end_year1 = Integer.parseInt(year_end1);
            end_month1 = Integer.parseInt(month_end1);
            end_day1 = Integer.parseInt(day_end1);
            
            if("0".equals(ed1.substring(8,9))){
                s_day_end1 = ed1.substring(9, 10);
            }
            else {
                s_day_end1 = day_end1;
            }
            if("0".equals(ed1.substring(5,6))){
                s_month_end1 = ed1.substring(6, 7);
            }
            else {
                s_month_end1 = month_end1;
            }
        }
        
        if (!StartDatePicker1.getDateStringOrEmptyString().equals("")) {
            PRISMCheckBox.setSelected(true);
        }
        
        //PRISM analysis variables
        if (DailyRadioButton.isSelected()) {
            daily_PRISM = "T";
        }
        else {
            daily_PRISM = "F";
        }
        if (MonthlyRadioButton.isSelected()) {
            monthly_PRISM = "T";
        }
        else {
            monthly_PRISM = "F";
        }
        if (AnnualRadioButton.isSelected()) {
            annual_PRISM = "T";
        }
        else {
            annual_PRISM = "F";
        }

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
       
        // extra variable formatting
        if ("Upper-Air: Spatial, Profile and Time Series".equals(ProgramComboBox.getSelectedItem().toString())){
           extra = query_string;
        }
        else if ("Upper-Air: Mandatory Profile Statistics".equals(ProgramComboBox.getSelectedItem().toString())){
           extra = query_string;
        }
        else if ("Upper-Air: Mandatory Time Series Statistics".equals(ProgramComboBox.getSelectedItem().toString())){
           extra = query_string;
        }
        else if ("Spatial Statistics: 2-m Temp, 2-m Moisture and 10-m Wind".equals(ProgramComboBox.getSelectedItem().toString())){
           extra = query_string;
        }
        else if ("Shortwave Radiation Statistics: Spatial, Diurnal and Time Series".equals(ProgramComboBox.getSelectedItem().toString())){
            extra = query_string;
        }
        else {
           extra = extra;
        }
        
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
        else if ("Upper-Air: Native Theta / RH Profiles (Single time)".equals(ProgramComboBox.getSelectedItem().toString())){
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
            //ProfilePlotsCheckBox.setSelected(false);
            wrapper = false;
        }
        else if ("Upper-Air: Native Theta / RH Profiles (Every sounding of period)".equals(ProgramComboBox.getSelectedItem().toString())){
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
            //ProfilePlotsCheckBox.setSelected(true);
            //wrapper = true;
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
                    + " " + hs +":00:00' and '" + year_end + "-" + month_end + "-" + day_end + " " + he + ":00:00'\n" + extra + " ORDER BY ob_date,ob_time";
        }
        else if ("Time Series: 2-m Temp, 2-m Moisture, 2-m RH and Sfc Pressure".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "SELECT DATE_FORMAT(ob_date,'%Y%m%d'), HOUR(ob_date), stat_id, fcast_hr, T_mod, T_ob, Q_mod, WVMR_ob, PSFC_mod, PSFC_ob\n"
                    + "FROM " + project_id + "_surface" + "\n" + "WHERE stat_id = '" + site + "' and ob_date BETWEEN " + year_start + month_start + day_start 
                    + " and " + year_end + month_end + day_end + "\n" + extra + " ORDER BY ob_date,ob_time";
        }
        else if ("Daily Statistics: 2-m Temp, 2-m Moisture and 10-m Wind".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "SELECT DATE_FORMAT(ob_date,'%Y%m%d'), HOUR(ob_date), d.stat_id, s.ob_network, d.T_mod, d.T_ob, d.Q_mod, d.WVMR_ob, d.U_mod, d.U_ob, d.V_mod, d.V_ob\n"
                    + "FROM " + project_id + "_surface d, stations s" + "\n" + "WHERE  s.stat_id=d.stat_id AND ob_date BETWEEN " + year_start + month_start + day_start 
                    + " AND " + year_end + month_end + day_end  + "\n" + query_string + " ORDER BY ob_date";
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
                    + " AND " + year_end + month_end + day_end + "\n" + extra + " ORDER BY ob_date";
        }
        else if ("Spatial Statistics: 2-m Temp, 2-m Moisture and 10-m Wind".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "SELECT d.stat_id, d.T_mod, d.T_ob, d.Q_mod, d.WVMR_ob, d.U_mod, d.U_ob, d.V_mod, d.V_ob, HOUR(d.ob_time) "
                    + "FROM "  + project_id + "_surface d, stations s\n" + "WHERE s.stat_id=d.stat_id and d.ob_date  >= '" + year_start + "-" + month_start + "-" + day_start
                    + "' AND d.ob_date < '" + year_end + "-" + month_end + "-" + day_end + "'\n" + extra + "ORDER BY d.stat_id\n\n"
                    + "SELECT DISTINCT s.stat_id, s.lat, s.lon, s.elev  FROM " + project_id + "_surface d, stations s\n"
                    + "WHERE s.stat_id=d.stat_id and d.ob_date  >= '" + year_start + "-" + month_start + "-" + day_start
                    + "' AND d.ob_date < '" + year_end + "-" + month_end + "-" + day_end + "'\n"+ extra + " ORDER BY ob_stat_id";
        }
        else if ("Upper-Air: Spatial, Profile and Time Series".equals(ProgramComboBox.getSelectedItem().toString())){
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
        else if ("Upper-Air: Native Theta / RH Profiles (Single time)".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "SELECT s.stat_id, YEAR(d.ob_date), MONTH(d.ob_date), DAY(d.ob_date), HOUR(d.ob_date), plevel, v1_id, v1_val, v2_id, v2_val\n"
                + "FROM " + project_id + "_raob WHERE ob_date='" + year_start + "-" + month_start + "-" + day_start + " " + hs + ":00:00'\n"
                + "AND (v1_id='T_OBS_M' OR v2_id='T_MOD_M') AND plevel " + "BETWEEN " + layer_lower + " AND " + layer_upper + "\n" 
                + "ORDER BY plevel";
        }
        else if ("Upper-Air: Native Theta / RH Profiles (Every sounding of period)".equals(ProgramComboBox.getSelectedItem().toString())){
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
        else if ("PRISM Analysis".equals(ProgramComboBox.getSelectedItem().toString())){
            query = "Not applicable for PRISM-based precipitation analysis";}
        else {
            query = "";
        }
        
        if (null == ProgramComboBox.getSelectedItem().toString()) {
            amet_static = "";
        }
        else //Sets amet_static for different plot types
        switch (ProgramComboBox.getSelectedItem().toString()) {
            case "Upper-Air: Spatial, Profile and Time Series":
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
            case "Upper-Air: Native Theta / RH Profiles (Single time)":
                amet_static = "/raob.static.input";
                break;
            case "Upper-Air: Native Theta / RH Profiles (Every sounding of period)":
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

    //Sets script_wrapper for different plot types
    switch (ProgramComboBox.getSelectedItem().toString()) {
            case "Upper-Air: Spatial, Profile and Time Series":
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
            case "Upper-Air: Native Theta / RH Profiles (Single time)":
                script_wrapper = "UA";
                break;
            case "Upper-Air: Native Theta / RH Profiles (Every sounding of period)":
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
            case "PRISM Analysis":
                script_wrapper = "PR";
                break;
            default:
                script_wrapper = "";
                break;
        }
   
    if (PRISMCheckBox.isSelected()) {
        year_start = year_start1;
        month_start = month_start1;
        day_start = day_start1;
        year_end = year_end1;
        month_end = month_end1;
        day_end = day_end1;
    }
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
        //System.out.println(config.cache_amet + "/" + "run_info_files" + "/" + run_info);
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
                + "querystr    <- \" AND ob_date BETWEEN " + year_start + month_start + day_start + " AND " + year_end + month_end + day_end + query_string  + " ORDER BY ob_date" + "\"\n"
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
                + "# PRISM Analysis variable settings #\n"
                + "amet_gui       <- T\n"
                + "model_outdir   <- \"" + WRF_file + "\"\n" 
                + "model_prefix   <- " + "\"" + model_prefix + "\"" + "\n" 
                + "\n"
                + "daily          <- " + daily_PRISM + "\n"
                + "monthly        <- " + monthly_PRISM + "\n"
                + "annual         <- " + annual_PRISM + "\n"
                + "\n"
                + "start_tindex   <- " + start_time_index + "\n"
                + "end_tindex     <- " + end_time_index + "\n"
                + "\n"
                + "donetcdf       <- " + netCDF + "\n"
                + "\n"
                + "prismdir       <- " + "\"" + config.cache_amet + "/prismdir_shared\"" + "\n"
                + "\n"
                + "use.default.precip.levs   <- T \n"
                + "use.range.precip.levs     <- F \n"
                + "\n"
                + "bil            <- T" + "\n"
                + "prism_prefix   <- \"noprefixneeded\"" + "\n"
                + "leaf_dxdykm    <- " + grid_spacing + "\n"
                + "\n"
                + "pbins          <-c(0,25,50,75,100,125,150,175,200,250)" + "\n"
                + "pdbins         <-c(-250,-100,-50,-25,-15,-5,0,5,15,25,50,100,250)" + "\n"
                + "cols1          <-c(\"#ffffe5\",\"#f7fcb9\",\"#d9f0a3\",\"#addd8e\",\"#78c679\",\"#41ab5d\",\"#238443\",\"#006837\",\"#004529\",\"#2171b5\",\"#6baed6\",\"#bdd7e7\",\"#eff3ff\")" + "\n"
                + "dcols1         <-c(\"#543005\",\"#8c510a\",\"#bf812d\",\"#dfc27d\",\"#f6e8c3\",\"#f5f5f5\",\"#c7eae5\",\"#80cdc1\",\"#35978f\",\"#01665e\",\"#003c30\")" + "\n"
                + "\n"
        );
        file.closeWriter();
    }
    
    //Dynamically executes the r scripts
    public void executeProgram() {
        setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
            Process p = null;
            String os = System.getProperty("os.name").toLowerCase();
            //System.out.println(os);
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
                    //System.out.println("linux");
                    String sites = site_id.replace("\"","");
                    if (MonthlyAnalysisCheckBox.isSelected() || SeasonalAnalysisCheckBox.isSelected() || ClimateRegionMonthlyCheckBox.isSelected() || ClimateRegionSeasonalCheckBox.isSelected() || wrapper == true || PRISMCheckBox.isSelected()){
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
                                + "setenv AMET_YEAR " + year_start1 + "&& "
                                + "setenv AMET_MONTH " + month_start1 + "&& "

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
        String date_range3 = year_start + "-" + month_start + "-" + day_start + "_" + hs + "." + "00" +  "." + "00";

        OutputWindowMET output = new OutputWindowMET(this);
        
        //output formatting for each script
        switch(run_program) {
            case "MET_kml.R":
                output.newFile(prefix_diag + "R.SDOUT.txt", "Diagnostic File (txt)");
                output.newFile(prefix_diag + "AMET.SITEFILE." + project_id  + ".kml", "Google Earth Site Map (KML)");
                //output.newFile(prefix_diag + "AMET.GOOGLEEARTH." + project_id + "." + year_start + month_start + day_start + "-" + year_end + month_end + day_end  + ".kml", "Google Earth Site Map (KML)");
                break;
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
                
                output.newFile(prefix2 + ".WS.ametplot.pdf", "Summary Statistics 10-m Wind Speed (PDF)");
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
                
                output.newFile(prefix5 + "spatial.RMSE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Temperature Root-Mean-Squared Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.RMSE.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Relative Humidity Root-Mean-Squared Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.RMSE.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Wind Speed Root-Mean-Squared Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.RMSE.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Wind Direction Root-Mean-Squared Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.RMSE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf"," ");
                
                output.newFile(prefix5 + "spatial.RMSE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Spatial Temperature Root-Mean-Squared Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.RMSE.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Spatial Relative Humidity Root-Mean-Squared Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.RMSE.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Spatial Wind Speed Root-Mean-Squared Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.RMSE.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Spatial Wind Direction Root-Mean-Squared Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.RMSE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png"," ");
                
                output.newFile(prefix5 + "spatial.BIAS.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Temperature Bias Plot (PDF)");
                output.newFile(prefix5 + "spatial.BIAS.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Relative Humidity Bias Plot (PDF)");
                output.newFile(prefix5 + "spatial.BIAS.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Wind Speed Bias Plot (PDF)");
                output.newFile(prefix5 + "spatial.BIAS.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Wind Direction Bias Plot (PDF)");
                output.newFile(prefix5 + "spatial.BIAS.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf"," ");
                
                output.newFile(prefix5 + "spatial.BIAS.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Spatial Temperature Bias Plot (PNG)");
                output.newFile(prefix5 + "spatial.BIAS.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Spatial Relative Humidity Bias Plot (PNG)");
                output.newFile(prefix5 + "spatial.BIAS.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Spatial Wind Speed Bias Plot (PNG)");
                output.newFile(prefix5 + "spatial.BIAS.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Spatial Wind Direction Bias Plot (PNG)");
                output.newFile(prefix5 + "spatial.BIAS.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png"," ");
                
                output.newFile(prefix5 + "spatial.MAE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Temperature Mean Absolute Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.MAE.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Relative Humidity Mean Absolute Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.MAE.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Wind Speed Mean Absolute Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.MAE.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Wind Direction Mean Absolute Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.MAE.WNDVEC." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Wind Vector Mean Absolute Error Plot (PDF)");
                output.newFile(prefix5 + "spatial.MAE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf"," ");
                
                output.newFile(prefix5 + "spatial.MAE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Spatial Temperature Mean Absolute Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.MAE.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Spatial Relative Humidity Mean Absolute Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.MAE.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + "." + run_id + ".png", "Spatial Wind Direction Mean Absolute Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.MAE.WNDVEC." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Spatial Wind Vector Mean Absolute Error Plot (PNG)");
                output.newFile(prefix5 + "spatial.MAE.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png"," ");
                
                output.newFile(prefix5 + "spatial.CORR.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Temperature Anomaly Correlation Plot (PDF)");
                output.newFile(prefix5 + "spatial.CORR.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Relative Humidity Anomaly Correlation Plot (PDF)");
                output.newFile(prefix5 + "spatial.CORR.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Wind Speed Anomaly Correlation Plot (PDF)");
                output.newFile(prefix5 + "spatial.CORR.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Spatial Wind Direction Anomaly Correlation Plot (PDF)");
                output.newFile(prefix5 + "spatial.CORR.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf"," ");
                
                output.newFile(prefix5 + "spatial.CORR.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Spatial Temperature Anomaly Correlation Plot (PNG)");
                output.newFile(prefix5 + "spatial.CORR.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Spatial Relative Humidity Anomaly Correlation Plot (PNG)");
                output.newFile(prefix5 + "spatial.CORR.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Spatial Wind Speed Anomaly Correlation Plot (PNG)");
                output.newFile(prefix5 + "spatial.CORR.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Spatial Wind Direction Anomaly Correlation Plot (PNG)");
                output.newFile(prefix5 + "spatial.CORR.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png"," ");
                
                output.newFile(prefix5 + "spatial.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".csv", "Spatial Temperature Dataset (csv)");
                output.newFile(prefix5 + "spatial.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".csv", "Spatial Relative Humidity Dataset (csv)");
                output.newFile(prefix5 + "spatial.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".csv", "Spatial Wind Speed Dataset (csv)");
                output.newFile(prefix5 + "spatial.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".csv", "Spatial Wind Direction Dataset (csv)");
                output.newFile(prefix5 + "spatial.WNDVEC." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".csv", "Spatial Wind Vector Dataset (csv)");
                output.newFile(prefix5 + "spatial.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".csv"," ");
                
                output.newFile(prefix5 + "daily.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Time Series Daily Statistics Temperature Plot (PDF)");
                output.newFile(prefix5 + "daily.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Time Series Daily Statistics Relative Humidity Plot (PDF)");
                output.newFile(prefix5 + "daily.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Time Series Daily Statistics Wind Speed Plot (PDF)");
                output.newFile(prefix5 + "daily.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Time Series Daily Statistics Wind Direction Plot (PDF)");
                output.newFile(prefix5 + "daily.WNDVEC." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Time Series Daily Statistics Wind Vector Plot (PDF)");
                output.newFile(prefix5 + "daily.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf"," ");
                
                output.newFile(prefix5 + "daily.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Time Series Daily Statistics Temperature Plot (PNG)");
                output.newFile(prefix5 + "daily.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Time Series Daily Statistics Relative Humidity Plot (PNG)");
                output.newFile(prefix5 + "daily.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Time Series Daily Statistics Wind Speed Plot (PNG)");
                output.newFile(prefix5 + "daily.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Time Series Daily Statistics Wind Direction Plot (PNG)");
                output.newFile(prefix5 + "daily.WNDVEC." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Time Series Daily Statistics Wind Vector Plot (PNG)");
                output.newFile(prefix5 + "daily.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png"," ");
                
                output.newFile(prefix5 + "daily.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".csv", "Time Series Daily Statistics Temperature Dataset (csv)");
                output.newFile(prefix5 + "daily.RH." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".csv", "Time Series Daily Statistics Relative Humidity Dataset (csv)");
                output.newFile(prefix5 + "daily.WS." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".csv", "Time Series Daily Statistics Wind Speed Dataset (csv)");
                output.newFile(prefix5 + "daily.WD." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".csv", "Time Series Daily Statistics Wind Direction Dataset (csv)");
                output.newFile(prefix5 + "daily.WNDVEC." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".csv", "Time Series Daily Statistics Wind Vector Dataset (csv)");
                output.newFile(prefix5 + "daily.TEMP." + date_range2 + "." + layer_lower + "-" + layer_upper + "mb." + project_id + "." +  year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" +run_id + ".csv"," ");
                
                output.newFile(prefix5 + "profileM." + site + ".TEMP." + date_range2 + "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", site + " Temperature Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + site + ".RH." + date_range2 +  "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", site + " Relative Humidity Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + site + ".WS." + date_range2 +  "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", site + " Wind Speed Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + site + ".WD." + date_range2 +  "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", site + " Wind Direction Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + site + ".TEMP." + date_range2 + "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf"," ");
                
                output.newFile(prefix5 + "profileM." + site + ".TEMP." + date_range2 + "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", site + " Temperature Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + site + ".RH." + date_range2 +  "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", site + " Relative Humidity Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + site + ".WS." + date_range2 +  "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", site + " Wind Speed Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + site + ".WD." + date_range2 +  "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", site + " Wind Direction Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + site + ".TEMP." + date_range2 + "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png"," ");
                
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".TEMP." + date_range2 + "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Temperature Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".RH." + date_range2 +  "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".WS." + date_range2 +  "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Wind Speed Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".WD." + date_range2 +  "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id +".pdf", "Wind Direction Profile Statistics (PDF)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".TEMP." + date_range2 + "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf"," ");
                
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".TEMP." + date_range2 + "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Temperature Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".RH." + date_range2 +  "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".WS." + date_range2 +  "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Wind Speed Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".WD." + date_range2 +  "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Wind Direction Profile Statistics (PNG)");
                output.newFile(prefix5 + "profileM." + "GROUP_AVG" + ".TEMP." + date_range2 + "." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png"," ");
                
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".100mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Histogram Plot 100 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".150mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Histogram Plot 150 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".200mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Histogram Plot 200 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".250mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Histogram Plot 250 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".300mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Histogram Plot 300 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".400mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Histogram Plot 400 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".500mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Histogram Plot 500 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".700mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Histogram Plot 700 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".850mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Histogram Plot 850 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".925mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Histogram Plot 925 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".1000mb." + project_id + "." +  year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" +run_id + ".pdf", "Relative Humidity Histogram Plot 1000 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".100mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf"," ");
                
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".100mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Histogram Plot 100 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".150mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Histogram Plot 150 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".200mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Histogram Plot 200 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".250mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Histogram Plot 250 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".300mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Histogram Plot 300 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".400mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Histogram Plot 400 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".500mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Histogram Plot 500 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".700mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Histogram Plot 700 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".850mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Histogram Plot 850 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".925mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Histogram Plot 925 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".1000mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Histogram Plot 1000 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + site + "." + date_range2 + ".100mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png"," ");
                
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".100mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Plot 100 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".150mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Plot 150 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".200mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Plot 200 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".250mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Plot 250 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".300mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Plot 300 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".400mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Plot 400 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".500mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Plot 500 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".700mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Plot 700 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".850mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Plot 850 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".925mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Plot 925 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".1000mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf", "Relative Humidity Plot 1000 mb (PDF)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".100mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".pdf"," ");
                
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".100mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Plot 100 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".150mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Plot 150 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".200mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Plot 200 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".250mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Plot 250 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".300mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Plot 300 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".400mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Plot 400 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".500mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Plot 500 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".700mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Plot 700 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".850mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Plot 850 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".925mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Plot 925 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".1000mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png", "Relative Humidity Plot 1000 mb (PNG)");
                output.newFile(prefix5 + "RHdist." + "GROUP_AVG" + "." + date_range2 + ".100mb." + project_id + "." + year_start + month_start + day_start + "_" + year_end + month_end + day_end  + "_" + run_id + ".png"," ");
                
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
            case "MET_prism_precip.R":
                output.newFile(prefix_diag + "R.SDOUT.txt","Multiple outputs were created, but only the first date's output is listed below.");
                output.newFile(prefix_diag + "R.SDOUT.txt","Users can copy all data from the cache directory:");
                output.newFile(prefix_diag + "R.SDOUT.txt",file_path);
                
                output.newFile(prefix4 + "prism-wrf.monthly." + year_start1 + "-" + month_start1 + "-" + day_start1 + ".nc", "NetCD File");
                output.newFile(prefix4 + "prism-wrf.daily." + year_start1 + "-" + month_start1 + "-" + day_start1 + "_files", "NetCD File");
                output.newFile(prefix4 + "prism-wrf.annual." + year_start1 + "-" + month_start1 + "-" + day_start1 + "_files", "NetCD File");
                
                output.newFile(prefix4 + "prism.leaf.monthly." + year_start1 + "-" + month_start1 + "-" + day_start1 + ".html", "Precip Leaflet (html)");
                output.newFile(prefix4 + "prism.leaf.daily." + year_start1 + "-" + month_start1 + "-" + day_start1 + ".html", "Precip Leaflet (html)");
                output.newFile(prefix4 + "prism.leaf.annual." + year_start1 + "-" + month_start1 + "-" + day_start1 + ".html", "Precip Leaflet (html)");
                
                output.newFile(prefix4 + "prism.monthly." + year_start1 + "-" + month_start1 + "-" + day_start1 + ".txt", "Precip Monthly Data (txt)");
                output.newFile(prefix4 + "prism.daily." + year_start1 + "-" + month_start1 + "-" + day_start1 + ".txt", "Precip Daily Data (txt)");
                output.newFile(prefix4 + "prism.annual." + year_start1 + "-" + month_start1 + "-" + day_start1 + ".txt", "Precip Annual Data (txt)");
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
        
        //assigning R scripts to run_program combo box fields
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
            case "Upper-Air: Spatial, Profile and Time Series":
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
            case "Upper-Air: Native Theta / RH Profiles (Single time)":
                run_program = "MET_raob.R";
                break;
            case "Upper-Air: Native Theta / RH Profiles (Every sounding of period)":
                run_program = "MET_raob.R";
                break;
            case "Upper-Air: Native Curtain":
                run_program = "MET_raob.R";
                break;
            case "PRISM Analysis":
                run_program = "MET_prism_precip.R";
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
        
        //Country
        if (!country.equals("\"All\"")) { 
            str = str + " AND s.country=" + country;
        }
        
        //Continent
        switch(continent) {
            case "Africa":
                str = str + " and (s.country='Morocco' or s.country='Senegal' or s.country='Mauritius' or s.country='Ghana' or s.country='Algeria' or s.country='Botswana' or s.country='Tunisia' or s.country='Egypt' or s.country='Seychelles' or s.country='Tanzania' or s.country='Mozambique' or s.country='Libya' or s.country='Madagascar' or s.country='South Africa' or s.country='Namibia' or s.country='Gabon' or s.country='Republic of the Congo' or s.country='Cameroon' or s.country='Congo' or s.country='Central African Republic' or s.country='Côte d'Ivoire' or s.country='Mali' or s.country='Liberia' or s.country='Mauritania' or s.country='Guinea' or s.country='Zimbabwe' or s.country='Uganda' or s.country='Niger' or s.country='Benin' or s.country='Chad' or s.country='Burkina Faso' or s.country='Equatorial Guinea' or s.country='Togo' or s.country='Kenya' or s.country='Zambia' or s.country='Djibouti' or s.country='The Gambia' or s.country='British Indian Ocean Territory' or s.country='Ethiopia' or s.country='Angola' or s.country='Nigeria' or s.country='Guinea-Bissau' or s.country='Sudan' or s.country='Sierra Leone' or s.country='São Tomé and Príncipe' or s.country='Rwanda' or s.country='Burundi' or s.country='Eswatini' or s.country='Malawi' or s.country='Eritrea'or s.country='Cape Verde')";                
                break;
            case "Asia":
                 str = str + " and (s.country='Japan' or s.country='Singapore' or s.country='Saudi Arabia' or s.country='Yemen' or s.country='India' or s.country='Bangladesh' or s.country='Nepal' or s.country='South Korea' or s.country='Cyprus' or s.country='Mainland China' or s.country='Hong Kong' or s.country='Taiwan' or s.country='Macau' or s.country='Philippines' or s.country='Israel' or s.country='Turkey' or s.country='Iran' or s.country='Pakistan' or s.country='Lebanon' or s.country='Cambodia' or s.country='Malaysia' or s.country='Bahrain' or s.country='Oman' or s.country='Qatar' or s.country='Iraq' or s.country='United Arab Emirates' or s.country='Indonesia' or s.country='Jordan' or s.country='Kuwait' or s.country='Syria' or s.country='Afghanistan' or s.country='Thailand' or s.country='Laos' or s.country='Vietnam' or s.country='Maldives' or s.country='Myanmar' or s.country='Sri Lanka' or s.country='Bhutan')";              
                break;
            case "Australia / Oceania":
                str = str + " and (s.country='Samoa' or s.country='Australia' or s.country='Federated States of Micronesia' or s.country='Guam' or s.country='New Zealand' or s.country='Niue' or s.country='Marshall Islands' or s.country='French Polynesia' or s.country='Fiji' or s.country='Tonga' or s.country='Papua New Guinea' or s.country='Papua New Guinea' or s.country='Vanuatu' or s.country='Kiribati')";
                break;
            case "Europe":
                str = str + " and (s.country='Gibraltar' or s.country='United Kingdom' or s.country='Germany' or s.country='Italy' or s.country='Lithuania' or s.country='Russia' or s.country='Estonia' or s.country='Finland' or s.country='Switzerland' or s.country='Belgium' or s.country='Denmark and the Faroe Islands' or s.country='Austria' or s.country='Sweden' or s.country='Norway' or s.country='Hungary' or s.country='Hungary' or s.country='Ireland' or s.country='France' or s.country='Greece' or s.country='Bulgaria' or s.country='Croatia' or s.country='Slovakia' or s.country='Portugal' or s.country='Romania' or s.country='Iceland' or s.country='Latvia' or s.country='Luxembourg' or s.country='Moldova' or s.country='Slovenia' or s.country='Serbia and Montenegro' or s.country='Spain' or s.country='Czech Republic' or s.country='Bosnia and Herzegovina' or s.country='North Macedonia' or s.country='Malta' or s.country='Netherlands' or s.country='Kosovo' or s.country='Albania')";
                break;   
            case "North America":
                str = str + " and (s.country='United States' or s.country='US (Alaska)' or s.country='Puerto Rico' or s.country='Hawaii' or s.country='U.S. Virgin Islands' or s.country='Bahamas' or s.country='Mexico' or s.country='Canada' or s.country='Cuba' or s.country='Cayman Islands' or s.country='Jamaica' or s.country='El Salvador' or s.country='Honduras' or s.country='Bermuda' or s.country='Dominica' or s.country='Barbados' or s.country='Guadeloupe' or s.country='Martinique' or s.country='Saint Barthélemy' or s.country='Saint Martin' or s.country='Antigua and Barbuda' or s.country='Costa Rica' or s.country='Grenada' or s.country='Saint Vincent and the Grenadines' or s.country='Nicaragua' or s.country='Belize' or s.country='Trinidad and Tobago' or s.country='Saint Kitts and Nevis' or s.country='Caribbean Netherlands' or s.country='Aruba' or s.country='Curaçao' or s.country='Sint Maarten' or s.country='Dominican Republic' or s.country='Guatemala' or s.country='Saint Lucia' or s.country='Turks and Caicos' or s.country='Panama' or s.country='Greenland' or s.country='Alaska' or s.country='Midway Island' or s.country='British Virgin Islands'or s.country='Haiti')";
                break;
            case "South America":
                str = str + " and (s.country='Chile' or s.country='Brazil' or s.country='Venezuela' or s.country='Ecuador' or s.country='Argentina' or s.country='Peru' or s.country='Colombia' or s.country='Paraguay' or s.country='Uruguay' or s.country='French Guiana' or s.country='Guyana' or s.country='Suriname' or s.country='Bolivia')";                
                break;
            case "Australia and New Zealand":
                str = str + " and (s.country='Australia' or s.country='New Zealand')";
                break;
            case "Central America":
                str = str + " and (s.country='Mexico' or s.country='El Salvador' or s.country='Honduras' or s.country='Costa Rica' or s.country='Nicaragua' or s.country='Belize' or s.country='Guatemala' or s.country='Panama')";
                break;
            case "Eastern Asia":
                str = str + " and (s.country='Japan' or s.country='South Korea' or s.country='Mainland China' or s.country='Hong Kong' or s.country='Taiwan' or s.country='Macau')";
                break;
            case "Eastern Europe":
                str = str + " and (s.country='Russia' or s.country='Hungary' or s.country='Poland' or s.country='Bulgaria' or s.country='Slovakia' or s.country='Romania' or s.country='Moldova' or s.country='Czech Republic')";
                break;
            case "Melanesia":
                str = str + " and (s.country='Fiji' or s.country='Papua New Guinea' or s.country='Vanuatu')";
                break;
            case "Micronesia":
                str = str + " and (s.country='Federated States of Micronesia' or s.country='Guam' or s.country='Marshall Islands' or s.country='Kiribati')";
                break;
            case "Northern Africa":
                str = str + " and (s.country='Morocco' or s.country='Algeria' or s.country='Tunisia' or s.country='Egypt' or s.country='Libya' or s.country='Sudan')";
                break;
            case "Northern America":
                str = str + " and (s.country='United States' or s.country='US (Alaska)' or s.country='Hawaii' or s.country='Canada' or s.country='Greenland' or s.country='Alaska')";
                break;
            case "Northern Europe":
                str = str + " and (s.country='United Kingdom' or s.country='Lithuania' or s.country='Estonia' or s.country='Finland' or s.country='Denmark and the Faroe Islands' or s.country='Sweden' or s.country='Norway' or s.country='Ireland' or s.country='Iceland' or s.country='Latvia')";
                break;
            case "Polynesia":
                str = str + " and (s.country='Samoa' or s.country='Niue' or s.country='French Polynesia' or s.country='Tonga' or s.country='Cook Islands')";
                break;
            case "South-eastern Asia":
                str = str + " and (s.country='Singapore' or s.country='Philippines' or s.country='Cambodia' or s.country='Malaysia' or s.country='Indonesia' or s.country='Thailand' or s.country='Laos' or s.country='Vietnam' or s.country='Myanmar')";
                break;
            case "Southern Asia":
                str = str + " and (s.country='India' or s.country='Bangladesh' or s.country='Nepal' or s.country='Iran' or s.country='Pakistan' or s.country='Afghanistan' or s.country='Maldives' or s.country='Sri Lanka' or s.country='Bhutan')";
                break;
            case "Southern Europe":
                str = str + " and (s.country='Gibraltar' or s.country='Italy' or s.country='Greece' or s.country='Croatia' or s.country='Portugal' or s.country='Slovenia' or s.country='Serbia and Montenegro' or s.country='Spain' or s.country='Bosnia and Herzegovina' or s.country='North Macedonia' or s.country='Malta' or s.country='Kosovo' or s.country='Albania')";
                break;
            case "Sub-Saharan Africa":
                str = str + " and (s.country='Angola' or s.country='Botswana' or s.country='British Indian Ocean Territory' or s.country='Burundi' or s.country='Cameroon' or s.country='Central African Republic' or s.country='Chad' or s.country='Congo' or s.country='Djibouti' or s.country='Equatorial Guinea' or s.country='Eritrea' or s.country='Eswatini' or s.country='Ethiopia' or s.country='Gabon' or s.country='Kenya' or s.country='Madagascar' or s.country='Malawi' or s.country='Mauritius' or s.country='Mozambique' or s.country='Namibia' or s.country='Republic of the Congo' or s.country='Rwanda' or s.country='São Tomé and Príncipe' or s.country='Seychelles' or s.country='South Africa' or s.country='Tanzania' or s.country='Uganda' or s.country='Zambia' or s.country='Zimbabwe')";
                break;
            case "Western Africa":
                str = str + " and (s.country='Benin' or s.country='Burkina Faso' or s.country='Cape Verde' or s.country='Côte d'Ivoire' or s.country='Ghana' or s.country='Guinea' or s.country='Guinea-Bissau' or s.country='Liberia' or s.country='Mali' or s.country='Mauritania' or s.country='Niger' or s.country='Nigeria' or s.country='Senegal' or s.country='Sierra Leone' or s.country='The Gambia' or s.country='Togo')";
                break;
            case "Western Asia":
                str = str + " and (s.country='Saudi Arabia' or s.country='Yemen' or s.country='Cyprus' or s.country='Israel' or s.country='Turkey' or s.country='Lebanon' or s.country='Bahrain' or s.country='Oman' or s.country='Qatar' or s.country='Iraq' or s.country='United Arab Emirates' or s.country='Jordan' or s.country='Kuwait' or s.country='Syria')";
                break;
            case "Western Europe":
                str = str + " and (s.country='Germany' or s.country='Switzerland' or s.country='Belgium' or s.country='Austria' or s.country='France' or s.country='Luxembourg' or s.country='Netherlands')";
                break;
            default:
                break;
        }
        
        //Observation Networks
        if (AllRadioButton.isSelected()) {
            str = str + " ";
        }
        if (MetarRadioButton.isSelected()) {
            str = str + " AND (s.ob_network='METAR' OR s.ob_network='ASOS' OR s.ob_network='SAO' OR s.ob_network='OTHER-MTR')";
        }
        if (MaritimeRadioButton.isSelected()) {
            str = str + " AND (s.ob_network='MARITIME')";
        }
        if (MesonetRadioButton.isSelected()) {
            str = str + " AND (s.ob_network!='METAR' OR s.ob_network!='MARITIME' OR s.ob_network!='ASOS' OR s.ob_network!='SAO' OR s.ob_network!='OTHER-MTR') ";
        }
       
        //Forecast Period
        initial_time = textFormat(StartHourComboBox2.getSelectedItem().toString());
        start_range = textFormat(StartHourComboBox1.getSelectedItem().toString());
        end_range = textFormat(EndHourComboBox1.getSelectedItem().toString());
        
        if (!start_range.equals("\"Start Forecast Hour\"")) {
            rs = hourFormat(start_range);
        }
        else {
            rs = "\"\"";
        }
        if (!end_range.equals("\"End Forecast Hour\"")) {
            re = hourFormat(end_range);
        }
        else {
            re = "\"\"";
        }
         if (!initial_time.equals("\"Initialization UTC\"")) {
            it = hourFormat(it);
        }
        else {
            it = "\"\"";
        }
       if (ProgramComboBox.getSelectedItem().toString().equals("Time Series: 2-m Temp, 2-m Moisture and 10-m Wind") || ProgramComboBox.getSelectedItem().toString().equals("Time Series: 2-m Temp, 2-m Moisture, 2-m RH and Sfc Pressure")){
           if (rs != "\"\"" && re != "\"\"" && it != "\"\""){
               str = str + " AND fcast_hr BETWEEN " + rs + " and " + re + " AND init_utc=" + it;
               System.out.println(str);
           }
           else { 
               str = str;
           }
       }
       else {
           if (rs != "\"\"" && re != "\"\"" && it != "\"\""){
               str = str + " AND d.fcast_hr BETWEEN " + rs + " and " + re + " AND d.init_utc=" + it;
           }
           else { 
               str = str;
           }
           
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
       
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        buttonGroup1 = new javax.swing.ButtonGroup();
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
        jPanel1 = new javax.swing.JPanel();
        SeasonalLabel = new javax.swing.JLabel();
        SeasonalTextArea = new javax.swing.JTextArea();
        SeasonalAnalysisCheckBox = new javax.swing.JCheckBox();
        SeasonalAnalysisTextArea = new javax.swing.JTextArea();
        MonthlyAnalysisLabel = new javax.swing.JLabel();
        MonthlyAnalysisTextArea = new javax.swing.JTextArea();
        MonthlyAnalysisCheckBox = new javax.swing.JCheckBox();
        ForecastPeriodLabel = new javax.swing.JLabel();
        StartHourLabel1 = new javax.swing.JLabel();
        StartHourComboBox1 = new javax.swing.JComboBox<>();
        EndHourComboBox1 = new javax.swing.JComboBox<>();
        StartHourComboBox2 = new javax.swing.JComboBox<>();
        HourRangeLabel = new javax.swing.JLabel();
        HourRangeTextArea = new javax.swing.JTextArea();
        StartHourLabel = new javax.swing.JLabel();
        StartHourComboBox = new javax.swing.JComboBox<>();
        EndHourComboBox = new javax.swing.JComboBox<>();
        EndHourLabel = new javax.swing.JLabel();
        RegionalTab = new javax.swing.JPanel();
        Left2 = new javax.swing.JPanel();
        StateLabel = new javax.swing.JLabel();
        StateInfoLabel = new javax.swing.JLabel();
        StateComboBox = new javax.swing.JComboBox<>();
        CountryLabel = new javax.swing.JLabel();
        CountryInfoLabel = new javax.swing.JLabel();
        CountryComboBox = new javax.swing.JComboBox<>();
        ClimateRegionMonthlyLabel = new javax.swing.JLabel();
        ClimateRegionMonthlyTextArea = new javax.swing.JTextArea();
        ClimateRegionMonthlyCheckBox = new javax.swing.JCheckBox();
        ClimateRegionSeasonalLabel = new javax.swing.JLabel();
        ClimateRegionSeasonalTextArea = new javax.swing.JTextArea();
        ClimateRegionSeasonalCheckBox = new javax.swing.JCheckBox();
        ClimateRegionsMapButton = new javax.swing.JButton();
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
        ContinentLabel = new javax.swing.JLabel();
        ContinentInfoLabel = new javax.swing.JLabel();
        ContinentComboBox = new javax.swing.JComboBox<>();
        SiteIDTab = new javax.swing.JPanel();
        Left3 = new javax.swing.JPanel();
        SiteIDLabel = new javax.swing.JLabel();
        SiteIDTextArea = new javax.swing.JTextArea();
        SiteIDTextField = new javax.swing.JTextField();
        SiteIDTextArea1 = new javax.swing.JTextArea();
        SiteIDTextArea2 = new javax.swing.JTextArea();
        METNetworkLabel = new javax.swing.JLabel();
        METNetworkInfoLabel = new javax.swing.JLabel();
        METNetworkInfoLabel1 = new javax.swing.JLabel();
        MetSiteFinderButton = new javax.swing.JButton();
        AllRadioButton = new javax.swing.JRadioButton();
        MetarRadioButton = new javax.swing.JRadioButton();
        MaritimeRadioButton = new javax.swing.JRadioButton();
        MesonetRadioButton = new javax.swing.JRadioButton();
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
        PRISMCheckBox = new javax.swing.JCheckBox();
        PRISMAnalysisTab = new javax.swing.JPanel();
        Left7 = new javax.swing.JPanel();
        DateRangeLabel1 = new javax.swing.JLabel();
        StartDateLabel1 = new javax.swing.JLabel();
        EndDateLabel1 = new javax.swing.JLabel();
        StartDatePicker1 = new com.github.lgooddatepicker.components.DatePicker();
        EndDatePicker1 = new com.github.lgooddatepicker.components.DatePicker();
        AnalysisTypeLabel = new javax.swing.JLabel();
        DailyRadioButton = new javax.swing.JRadioButton();
        MonthlyRadioButton = new javax.swing.JRadioButton();
        AnnualRadioButton = new javax.swing.JRadioButton();
        WRFFilesLabel = new javax.swing.JLabel();
        WRFFilesTextArea = new javax.swing.JTextArea();
        WRFFilesButton = new javax.swing.JButton();
        GridSpacingLabel = new javax.swing.JLabel();
        GridSpacingTextArea = new javax.swing.JTextArea();
        GridSpacingTextField = new javax.swing.JTextField();
        ModelLabel = new javax.swing.JLabel();
        ModelTextArea = new javax.swing.JTextArea();
        ModelOutputTextField = new javax.swing.JTextField();
        ModelLabel1 = new javax.swing.JLabel();
        ModelTextArea1 = new javax.swing.JTextArea();
        StartTimeIndexTextField = new javax.swing.JTextField();
        StartTimeIndexLabel = new javax.swing.JLabel();
        EndTimeIndexLabel = new javax.swing.JLabel();
        EndTimeIndexTextField = new javax.swing.JTextField();
        NetCDFCheckBox = new javax.swing.JCheckBox();
        ModelLabel2 = new javax.swing.JLabel();
        RunPRISMButton = new javax.swing.JButton();
        WRFFilesTextArea1 = new javax.swing.JTextArea();
        PrecipDirectoryLabel = new javax.swing.JLabel();
        PrecipDirectoryTextField = new javax.swing.JTextField();
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
        jTabbedPane1.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        jTabbedPane1.setMaximumSize(new java.awt.Dimension(999, 576));
        jTabbedPane1.setMinimumSize(new java.awt.Dimension(999, 576));
        jTabbedPane1.setPreferredSize(new java.awt.Dimension(999, 576));

        ProjectTab.setBackground(new java.awt.Color(255, 255, 255));
        ProjectTab.setPreferredSize(new java.awt.Dimension(1000, 543));

        Left1.setBackground(new java.awt.Color(174, 211, 232));
        Left1.setPreferredSize(new java.awt.Dimension(24, 570));

        javax.swing.GroupLayout Left1Layout = new javax.swing.GroupLayout(Left1);
        Left1.setLayout(Left1Layout);
        Left1Layout.setHorizontalGroup(
            Left1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 24, Short.MAX_VALUE)
        );
        Left1Layout.setVerticalGroup(
            Left1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 570, Short.MAX_VALUE)
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
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
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

        jTabbedPane1.addTab("Project  ", ProjectTab);

        DateTimeTab.setBackground(new java.awt.Color(255, 255, 255));

        Left5.setBackground(new java.awt.Color(174, 211, 232));
        Left5.setPreferredSize(new java.awt.Dimension(24, 570));

        javax.swing.GroupLayout Left5Layout = new javax.swing.GroupLayout(Left5);
        Left5.setLayout(Left5Layout);
        Left5Layout.setHorizontalGroup(
            Left5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 24, Short.MAX_VALUE)
        );
        Left5Layout.setVerticalGroup(
            Left5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 570, Short.MAX_VALUE)
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

        jPanel1.setBackground(new java.awt.Color(255, 255, 255));
        jPanel1.setPreferredSize(new java.awt.Dimension(419, 500));

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
        SeasonalAnalysisTextArea.setText("Note that monthly/seasonal analysis can take up to an hour to generate for spatial statistics run and 5-20 minutes for others.  Also, the analyses will not be provided in an Output Window, but stored in the User's cache directory that is provided in pop-up window when complete.");
        SeasonalAnalysisTextArea.setWrapStyleWord(true);
        SeasonalAnalysisTextArea.setBackground(new java.awt.Color(255, 255, 255));
        SeasonalAnalysisTextArea.setForeground(new java.awt.Color(0, 112, 185));
        SeasonalAnalysisTextArea.setPreferredSize(new java.awt.Dimension(407, 79));

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

        ForecastPeriodLabel.setText("Forecast Options");
        ForecastPeriodLabel.setBackground(new java.awt.Color(255, 255, 255));
        ForecastPeriodLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        ForecastPeriodLabel.setForeground(new java.awt.Color(0, 112, 185));

        StartHourLabel1.setText("For weather forecast applications");
        StartHourLabel1.setBackground(new java.awt.Color(255, 255, 255));
        StartHourLabel1.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        StartHourLabel1.setForeground(new java.awt.Color(0, 112, 185));

        StartHourComboBox1.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Start Forecast Hour", "0", "24", "48", "72", "96", "120", "144", "168", "192", "216", "240", "360", " " }));
        StartHourComboBox1.setBackground(new java.awt.Color(191, 182, 172));
        StartHourComboBox1.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        StartHourComboBox1.setForeground(new java.awt.Color(0, 63, 105));

        EndHourComboBox1.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "End Forecast Hour", "24", "48", "72", "96", "120", "144", "168", "192", "216", "240", "360" }));
        EndHourComboBox1.setBackground(new java.awt.Color(191, 182, 172));
        EndHourComboBox1.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        EndHourComboBox1.setForeground(new java.awt.Color(0, 63, 105));

        StartHourComboBox2.setMaximumRowCount(6);
        StartHourComboBox2.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Initialization UTC", "00", "06", "12", "18", " ", " ", " " }));
        StartHourComboBox2.setBackground(new java.awt.Color(191, 182, 172));
        StartHourComboBox2.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        StartHourComboBox2.setForeground(new java.awt.Color(0, 63, 105));

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                    .addComponent(SeasonalAnalysisTextArea, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, 417, Short.MAX_VALUE)
                    .addComponent(MonthlyAnalysisLabel, javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(MonthlyAnalysisTextArea, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(SeasonalLabel, javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(ForecastPeriodLabel, javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(SeasonalTextArea, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addGroup(javax.swing.GroupLayout.Alignment.LEADING, jPanel1Layout.createSequentialGroup()
                        .addGap(6, 6, 6)
                        .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                            .addComponent(StartHourComboBox2, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.PREFERRED_SIZE, 192, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(StartHourLabel1, javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(StartHourComboBox1, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(EndHourComboBox1, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.PREFERRED_SIZE, 192, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(MonthlyAnalysisCheckBox, javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(SeasonalAnalysisCheckBox, javax.swing.GroupLayout.Alignment.LEADING))))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addGap(37, 37, 37)
                .addComponent(ForecastPeriodLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(StartHourLabel1)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(StartHourComboBox2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(StartHourComboBox1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(EndHourComboBox1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(MonthlyAnalysisLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(MonthlyAnalysisTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 48, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(MonthlyAnalysisCheckBox)
                .addGap(18, 18, 18)
                .addComponent(SeasonalLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(SeasonalTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 48, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(SeasonalAnalysisCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(SeasonalAnalysisTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 92, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

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

        EndHourComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Default", "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23" }));
        EndHourComboBox.setBackground(new java.awt.Color(191, 182, 172));
        EndHourComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        EndHourComboBox.setForeground(new java.awt.Color(0, 63, 105));

        EndHourLabel.setText("End Hour (UTC)");
        EndHourLabel.setBackground(new java.awt.Color(255, 255, 255));
        EndHourLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        EndHourLabel.setForeground(new java.awt.Color(0, 112, 185));

        javax.swing.GroupLayout DateTimeTabLayout = new javax.swing.GroupLayout(DateTimeTab);
        DateTimeTab.setLayout(DateTimeTabLayout);
        DateTimeTabLayout.setHorizontalGroup(
            DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(DateTimeTabLayout.createSequentialGroup()
                .addComponent(Left5, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(DateRangeLabel)
                    .addGroup(DateTimeTabLayout.createSequentialGroup()
                        .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(StartDateLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(EndDateLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(EndDatePicker, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(StartDatePicker, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                    .addComponent(DateRangeTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 420, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(HourRangeLabel)
                    .addGroup(DateTimeTabLayout.createSequentialGroup()
                        .addGap(6, 6, 6)
                        .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addGroup(DateTimeTabLayout.createSequentialGroup()
                                .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addComponent(StartHourLabel)
                                    .addComponent(EndHourLabel))
                                .addGap(18, 18, 18)
                                .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addComponent(StartHourComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(EndHourComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                            .addComponent(HourRangeTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 60, Short.MAX_VALUE)
                .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, 427, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(32, 32, 32))
        );
        DateTimeTabLayout.setVerticalGroup(
            DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(DateTimeTabLayout.createSequentialGroup()
                .addComponent(Left5, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
            .addGroup(DateTimeTabLayout.createSequentialGroup()
                .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, 514, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGroup(DateTimeTabLayout.createSequentialGroup()
                        .addGap(40, 40, 40)
                        .addComponent(DateRangeLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(DateRangeTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 81, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(StartDateLabel)
                            .addComponent(StartDatePicker, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addGap(18, 18, 18)
                        .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(EndDatePicker, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(EndDateLabel))
                        .addGap(26, 26, 26)
                        .addComponent(HourRangeLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(HourRangeTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 67, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(StartHourComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(StartHourLabel))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(EndHourComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(EndHourLabel))))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        jTabbedPane1.addTab("Date / Time ", DateTimeTab);

        RegionalTab.setBackground(new java.awt.Color(255, 255, 255));
        RegionalTab.setPreferredSize(new java.awt.Dimension(1000, 543));

        Left2.setBackground(new java.awt.Color(174, 211, 232));
        Left2.setPreferredSize(new java.awt.Dimension(25, 570));

        javax.swing.GroupLayout Left2Layout = new javax.swing.GroupLayout(Left2);
        Left2.setLayout(Left2Layout);
        Left2Layout.setHorizontalGroup(
            Left2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 25, Short.MAX_VALUE)
        );
        Left2Layout.setVerticalGroup(
            Left2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 570, Short.MAX_VALUE)
        );

        StateLabel.setText("State");
        StateLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        StateLabel.setForeground(new java.awt.Color(0, 112, 185));

        StateInfoLabel.setText("Isolate an evaluation dataset by state");
        StateInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        StateInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        StateComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Select a State", "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY" }));
        StateComboBox.setBackground(new java.awt.Color(191, 182, 172));
        StateComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        StateComboBox.setForeground(new java.awt.Color(0, 63, 105));
        StateComboBox.setMinimumSize(new java.awt.Dimension(215, 23));
        StateComboBox.setOpaque(true);
        StateComboBox.setPreferredSize(new java.awt.Dimension(215, 23));
        StateComboBox.setToolTipText("Only works for stations that have the state specified in the Metadata.  More stations will be added in the future.");

        CountryLabel.setText("Country");
        CountryLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        CountryLabel.setForeground(new java.awt.Color(0, 112, 185));

        CountryInfoLabel.setText("Isolate an evaluation dataset by country");
        CountryInfoLabel.setAlignmentX(0.5F);
        CountryInfoLabel.setBackground(new java.awt.Color(255, 255, 255));
        CountryInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        CountryInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        CountryComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Select a Country", "United States", "US (Alaska)", "Puerto Rico", "Hawaii", "U.S. Virgin Islands", "Bahamas", "Mexico", "Canada", "Cuba", "Cayman Islands", "Jamaica", "El Salvador", "Honduras", "Bermuda", "Dominica", "Barbados", "Guadeloupe", "Martinique", "Saint Barthélemy", "Saint Martin", "Antigua and Barbuda", "Costa Rica", "Grenada", "Saint Vincent and the Grenadines", "Nicaragua", "Belize", "Trinidad and Tobago", "Saint Kitts and Nevis", "Caribbean Netherlands", "Aruba", "Curaçao", "Sint Maarten", "Dominican Republic", "Guatemala", "Saint Lucia", "Turks and Caicos", "Panama", "Gibraltar", "United Kingdom", "Samoa", "Germany", "Australia", "Federated States of Micronesia", "Italy", "Greenland", "Lithuania", "Guam", "Russia", "Alaska", "Japan", "Estonia", "Finland", "Midway Island", "Switzerland", "Belgium", "Denmark and the Faroe Islands", "Austria", "Sweden", "Norway", "Chile", "New Zealand", "Hungary", "Niue", "Marshall Islands", "Morocco", "French Polynesia", "Poland", "Singapore", "Saudi Arabia", "Yemen", "Ireland", "France", "India", "Bangladesh", "Nepal", "South Korea", "Greece", "Bulgaria", "Senegal", "Croatia", "Slovakia", "Cyprus", "Portugal", "Mainland China", "Hong Kong", "Taiwan", "Macau", "Philippines", "Israel", "Turkey", "Romania", "Mauritius", "Ghana", "Iran", "Brazil", "Iceland", "Pakistan", "Algeria", "Latvia", "Luxembourg", "Venezuela", "Botswana", "Lebanon", "Cambodia", "Malaysia", "Bahrain", "Oman", "Moldova", "Ecuador", "Tunisia", "Fiji", "Tonga", "Gilbert Islands", "Egypt", "Qatar", "Slovenia", "Serbia and Montenegro", "Seychelles", "Tanzania", "Argentina", "Canary Islands", "Iraq", "Papua New Guinea", "United Arab Emirates", "Spain", "Peru", "Colombia", "Indonesia", "Mozambique", "Libya", "Jordan", "Madagascar", "Paraguay", "Uruguay", "South Africa", "Namibia", "Czech Republic", "Bosnia and Herzegovina", "Saint Helena", "Ascension and Tristan da Cunha", "Gabon", "Kuwait", "Syria", "Afghanistan", "North Macedonia", "French Guiana", "Thailand", "Guyana", "Malta", "Republic of the Congo", "Cameroon", "Congo", "Central African Republic", "Laos", "Vietnam", "Maldives", "Myanmar", "Côte d'Ivoire", "Mali", "Liberia", "Mauritania", "Guinea", "Cape Verde", "Netherlands", "Suriname", "Zimbabwe", "Uganda", "Niger", "Benin", "Chad", "Burkina Faso", "Cook Islands", "Bolivia", "Equatorial Guinea", "Vanuatu", "Sri Lanka", "Togo", "Kenya", "Wake Island", "Zambia", "Djibouti", "The Gambia", "British Indian Ocean Territory", "Ethiopia", "Kosovo", "Angola", "Albania", "Kiribati", "Nigeria", "Guinea-Bissau", "Sudan", "Sierra Leone", "São Tomé and Príncipe", "British Virgin Islands", "Haiti", "Rwanda", "Burundi", "Eswatini", "Malawi", "Eritrea", "Bhutan" }));
        CountryComboBox.setBackground(new java.awt.Color(191, 182, 172));
        CountryComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        CountryComboBox.setForeground(new java.awt.Color(0, 63, 105));

        ClimateRegionMonthlyLabel.setText("U.S. Climate Regions Monthly Analysis");
        ClimateRegionMonthlyLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        ClimateRegionMonthlyLabel.setForeground(new java.awt.Color(0, 112, 185));

        ClimateRegionMonthlyTextArea.setColumns(20);
        ClimateRegionMonthlyTextArea.setEditable(false);
        ClimateRegionMonthlyTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        ClimateRegionMonthlyTextArea.setLineWrap(true);
        ClimateRegionMonthlyTextArea.setRows(5);
        ClimateRegionMonthlyTextArea.setText("Use this option to isolate evaluation data by the months of the year and U.S. climate regions. When using this option, set the dates range to cover the entire year.  \n");
        ClimateRegionMonthlyTextArea.setWrapStyleWord(true);
        ClimateRegionMonthlyTextArea.setBackground(new java.awt.Color(255, 255, 255));
        ClimateRegionMonthlyTextArea.setForeground(new java.awt.Color(0, 112, 185));
        ClimateRegionMonthlyTextArea.setPreferredSize(new java.awt.Dimension(400, 83));

        ClimateRegionMonthlyCheckBox.setText("U.S. Climate Regions Monthly Analysis");
        ClimateRegionMonthlyCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        ClimateRegionMonthlyCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ClimateRegionMonthlyCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        ClimateRegionMonthlyCheckBox.setToolTipText("Running Upper-Air Statistics produces spatial and profile statistics for the whole model domain or defined windowed area.");

        ClimateRegionSeasonalLabel.setText("U.S Climate Regions Seasonal Analysis");
        ClimateRegionSeasonalLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        ClimateRegionSeasonalLabel.setForeground(new java.awt.Color(0, 112, 185));

        ClimateRegionSeasonalTextArea.setColumns(20);
        ClimateRegionSeasonalTextArea.setEditable(false);
        ClimateRegionSeasonalTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        ClimateRegionSeasonalTextArea.setLineWrap(true);
        ClimateRegionSeasonalTextArea.setRows(5);
        ClimateRegionSeasonalTextArea.setText("Use this option to isolate evaluation data by the  seasons of the year and U.S. climate regions. When using this option, set the dates range to cover the entire season or year.  \n");
        ClimateRegionSeasonalTextArea.setWrapStyleWord(true);
        ClimateRegionSeasonalTextArea.setBackground(new java.awt.Color(255, 255, 255));
        ClimateRegionSeasonalTextArea.setForeground(new java.awt.Color(0, 112, 185));
        ClimateRegionSeasonalTextArea.setPreferredSize(new java.awt.Dimension(400, 83));

        ClimateRegionSeasonalCheckBox.setText("U.S. Climate Regions Seasonal Analysis");
        ClimateRegionSeasonalCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        ClimateRegionSeasonalCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ClimateRegionSeasonalCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        ClimateRegionSeasonalCheckBox.setToolTipText("Running Upper-Air Statistics produces spatial and profile statistics for the whole model domain or defined windowed area.");

        ClimateRegionsMapButton.setText("Map of U.S. Climate Regions");
        ClimateRegionsMapButton.setAlignmentX(0.5F);
        ClimateRegionsMapButton.setBackground(new java.awt.Color(0, 63, 105));
        ClimateRegionsMapButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ClimateRegionsMapButton.setForeground(new java.awt.Color(191, 182, 172));
        ClimateRegionsMapButton.setMaximumSize(new java.awt.Dimension(274, 23));
        ClimateRegionsMapButton.setMinimumSize(new java.awt.Dimension(274, 23));
        ClimateRegionsMapButton.setPreferredSize(new java.awt.Dimension(274, 23));
        ClimateRegionsMapButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                ClimateRegionsMapButtonActionPerformed(evt);
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

        LatTextField2.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        LatTextField2.setBackground(new java.awt.Color(191, 182, 172));
        LatTextField2.setForeground(new java.awt.Color(0, 63, 105));

        LonLabel2.setText("to");
        LonLabel2.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        LonLabel2.setForeground(new java.awt.Color(0, 112, 185));

        LonTextField1.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        LonTextField1.setBackground(new java.awt.Color(191, 182, 172));
        LonTextField1.setForeground(new java.awt.Color(0, 63, 105));

        LonTextField2.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        LonTextField2.setBackground(new java.awt.Color(191, 182, 172));
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

        ContinentLabel.setText("Continent / Geographic Region");
        ContinentLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        ContinentLabel.setForeground(new java.awt.Color(0, 112, 185));

        ContinentInfoLabel.setText("Isolate an evaluation dataset by geographic region");
        ContinentInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        ContinentInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        ContinentComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Select a Region", "-Continents-", "Africa", "Asia", "Australia / Oceania", "Europe", "North America", "South America", " ", "-Geographic Regions-", "Australia and New Zealand", "Central America", "Eastern Asia", "Eastern Europe", "Melanesia", "Micronesia", "Northern Africa", "Northern America", "Northern Europe", "Polynesia", "South America", "South-eastern Asia", "Southern Asia", "Southern Europe", "Sub-Saharan Africa", "Western Africa", "Western Asia", "Western Europe" }));
        ContinentComboBox.setBackground(new java.awt.Color(191, 182, 172));
        ContinentComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ContinentComboBox.setForeground(new java.awt.Color(0, 63, 105));

        javax.swing.GroupLayout RegionalTabLayout = new javax.swing.GroupLayout(RegionalTab);
        RegionalTab.setLayout(RegionalTabLayout);
        RegionalTabLayout.setHorizontalGroup(
            RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(RegionalTabLayout.createSequentialGroup()
                .addComponent(Left2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addComponent(CountryLabel)
                        .addComponent(LatLonLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 257, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(LatLonTextArea, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 377, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGroup(RegionalTabLayout.createSequentialGroup()
                            .addGap(6, 6, 6)
                            .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                .addComponent(LatLonPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addComponent(CountryInfoLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 336, javax.swing.GroupLayout.PREFERRED_SIZE))))
                    .addComponent(CountryComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(StateComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(StateLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 67, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGroup(RegionalTabLayout.createSequentialGroup()
                        .addGap(6, 6, 6)
                        .addComponent(StateInfoLabel)))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, RegionalTabLayout.createSequentialGroup()
                        .addComponent(ClimateRegionsMapButton, javax.swing.GroupLayout.PREFERRED_SIZE, 274, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(90, 90, 90))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, RegionalTabLayout.createSequentialGroup()
                        .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(ClimateRegionMonthlyLabel)
                            .addComponent(ContinentLabel)
                            .addComponent(ContinentComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(ClimateRegionSeasonalLabel)
                            .addComponent(ClimateRegionMonthlyTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(ClimateRegionSeasonalTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 393, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(ClimateRegionMonthlyCheckBox))
                        .addGap(40, 40, 40))
                    .addGroup(RegionalTabLayout.createSequentialGroup()
                        .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(ClimateRegionSeasonalCheckBox)
                            .addGroup(RegionalTabLayout.createSequentialGroup()
                                .addGap(6, 6, 6)
                                .addComponent(ContinentInfoLabel)))
                        .addContainerGap())))
        );
        RegionalTabLayout.setVerticalGroup(
            RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(RegionalTabLayout.createSequentialGroup()
                .addComponent(Left2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
            .addGroup(RegionalTabLayout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addGroup(RegionalTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(RegionalTabLayout.createSequentialGroup()
                        .addComponent(LatLonLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(LatLonPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(LatLonTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 64, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(StateLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(StateInfoLabel)
                        .addGap(18, 18, 18)
                        .addComponent(StateComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(24, 24, 24)
                        .addComponent(CountryLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(CountryInfoLabel)
                        .addGap(18, 18, 18)
                        .addComponent(CountryComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(RegionalTabLayout.createSequentialGroup()
                        .addComponent(ContinentLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ContinentInfoLabel)
                        .addGap(18, 18, 18)
                        .addComponent(ContinentComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(24, 24, 24)
                        .addComponent(ClimateRegionMonthlyLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ClimateRegionMonthlyTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 66, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ClimateRegionMonthlyCheckBox)
                        .addGap(26, 26, 26)
                        .addComponent(ClimateRegionSeasonalLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ClimateRegionSeasonalTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 66, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ClimateRegionSeasonalCheckBox)))
                .addGap(32, 32, 32)
                .addComponent(ClimateRegionsMapButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        jTabbedPane1.addTab("Regional  ", RegionalTab);

        SiteIDTab.setBackground(new java.awt.Color(255, 255, 255));

        Left3.setBackground(new java.awt.Color(174, 211, 232));
        Left3.setPreferredSize(new java.awt.Dimension(24, 570));

        javax.swing.GroupLayout Left3Layout = new javax.swing.GroupLayout(Left3);
        Left3.setLayout(Left3Layout);
        Left3Layout.setHorizontalGroup(
            Left3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 24, Short.MAX_VALUE)
        );
        Left3Layout.setVerticalGroup(
            Left3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 570, Short.MAX_VALUE)
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

        SiteIDTextField.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SiteIDTextField.setBackground(new java.awt.Color(191, 182, 172));
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
        SiteIDTextArea2.setText("Creates a kml Google Earth file that allows the user to see all sites used in the selected project for the selected time period.");
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

        METNetworkInfoLabel1.setText("surface meteorology summary and daily statistics.");
        METNetworkInfoLabel1.setBackground(new java.awt.Color(255, 255, 255));
        METNetworkInfoLabel1.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        METNetworkInfoLabel1.setForeground(new java.awt.Color(0, 112, 185));

        MetSiteFinderButton.setText("Surface Meteorology Site Finder");
        MetSiteFinderButton.setBackground(new java.awt.Color(0, 63, 105));
        MetSiteFinderButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        MetSiteFinderButton.setForeground(new java.awt.Color(191, 182, 172));
        MetSiteFinderButton.setMaximumSize(new java.awt.Dimension(378, 23));
        MetSiteFinderButton.setPreferredSize(new java.awt.Dimension(130, 23));
        MetSiteFinderButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                MetSiteFinderButtonActionPerformed(evt);
            }
        });

        buttonGroup1.add(AllRadioButton);
        AllRadioButton.setSelected(true);
        AllRadioButton.setText("All");
        AllRadioButton.setBackground(new java.awt.Color(255, 255, 255));
        AllRadioButton.setFont(new java.awt.Font("Times New Roman", 1, 16));
        AllRadioButton.setForeground(new java.awt.Color(0, 112, 185));

        buttonGroup1.add(MetarRadioButton);
        MetarRadioButton.setText("METAR");
        MetarRadioButton.setBackground(new java.awt.Color(255, 255, 255));
        MetarRadioButton.setFont(new java.awt.Font("Times New Roman", 1, 16));
        MetarRadioButton.setForeground(new java.awt.Color(0, 112, 185));

        buttonGroup1.add(MaritimeRadioButton);
        MaritimeRadioButton.setText("MARITIME");
        MaritimeRadioButton.setBackground(new java.awt.Color(255, 255, 255));
        MaritimeRadioButton.setFont(new java.awt.Font("Times New Roman", 1, 16));
        MaritimeRadioButton.setForeground(new java.awt.Color(0, 112, 185));

        buttonGroup1.add(MesonetRadioButton);
        MesonetRadioButton.setText("Mesonet");
        MesonetRadioButton.setBackground(new java.awt.Color(255, 255, 255));
        MesonetRadioButton.setFont(new java.awt.Font("Times New Roman", 1, 16));
        MesonetRadioButton.setForeground(new java.awt.Color(0, 112, 185));

        javax.swing.GroupLayout SiteIDTabLayout = new javax.swing.GroupLayout(SiteIDTab);
        SiteIDTab.setLayout(SiteIDTabLayout);
        SiteIDTabLayout.setHorizontalGroup(
            SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(SiteIDTabLayout.createSequentialGroup()
                .addComponent(Left3, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addGroup(SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(SiteIDTabLayout.createSequentialGroup()
                        .addGroup(SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(SiteIDLabel)
                            .addComponent(SiteIDTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 350, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addGroup(SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                                .addComponent(SiteIDTextArea, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                .addComponent(SiteIDTextArea1, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.PREFERRED_SIZE, 494, javax.swing.GroupLayout.PREFERRED_SIZE)))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addGroup(SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addGroup(SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                .addComponent(METNetworkLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                .addComponent(METNetworkInfoLabel)
                                .addComponent(METNetworkInfoLabel1))
                            .addComponent(AllRadioButton)
                            .addComponent(MetarRadioButton)
                            .addComponent(MaritimeRadioButton)
                            .addComponent(MesonetRadioButton))
                        .addGap(40, 40, 40))
                    .addGroup(SiteIDTabLayout.createSequentialGroup()
                        .addGroup(SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(SiteIDTextArea2, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(MetSiteFinderButton, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                        .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))))
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
                        .addComponent(AllRadioButton)
                        .addGap(18, 18, 18)
                        .addComponent(MetarRadioButton)
                        .addGap(18, 18, 18)
                        .addComponent(MaritimeRadioButton)
                        .addGap(18, 18, 18)
                        .addComponent(MesonetRadioButton))
                    .addGroup(SiteIDTabLayout.createSequentialGroup()
                        .addComponent(SiteIDLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(SiteIDTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 64, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SiteIDTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(SiteIDTextArea1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addGap(73, 73, 73)
                .addComponent(MetSiteFinderButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(SiteIDTextArea2, javax.swing.GroupLayout.PREFERRED_SIZE, 53, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        jTabbedPane1.addTab("Site ID / Networks ", SiteIDTab);

        OutputPropertiesTab.setBackground(new java.awt.Color(255, 255, 255));

        Left6.setBackground(new java.awt.Color(174, 211, 232));
        Left6.setPreferredSize(new java.awt.Dimension(24, 570));

        javax.swing.GroupLayout Left6Layout = new javax.swing.GroupLayout(Left6);
        Left6.setLayout(Left6Layout);
        Left6Layout.setHorizontalGroup(
            Left6Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 24, Short.MAX_VALUE)
        );
        Left6Layout.setVerticalGroup(
            Left6Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 570, Short.MAX_VALUE)
        );

        CustomRunNameLabel.setText("Custom Run Name");
        CustomRunNameLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        CustomRunNameLabel.setForeground(new java.awt.Color(0, 112, 185));

        CustomRunNameTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        CustomRunNameTextField.setBackground(new java.awt.Color(191, 182, 172));
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

        HeightTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        HeightTextField.setBackground(new java.awt.Color(191, 182, 172));
        HeightTextField.setForeground(new java.awt.Color(0, 63, 105));

        WidthLabel.setText("Width");
        WidthLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        WidthLabel.setForeground(new java.awt.Color(0, 112, 185));

        WidthTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        WidthTextField.setBackground(new java.awt.Color(191, 182, 172));
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

        CustomDirectoryNameTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        CustomDirectoryNameTextField.setBackground(new java.awt.Color(191, 182, 172));
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

        ClearFilesTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ClearFilesTextField.setBackground(new java.awt.Color(191, 182, 172));
        ClearFilesTextField.setForeground(new java.awt.Color(0, 63, 105));
        ClearFilesTextField.setMinimumSize(new java.awt.Dimension(548, 23));
        ClearFilesTextField.setPreferredSize(new java.awt.Dimension(548, 23));
        ClearFilesTextField.setToolTipText("Only enter the Custom Directory Name.  The path will be generated automatically.");
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
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
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

        jTabbedPane1.addTab("Output Properties ", OutputPropertiesTab);

        RunAnalysisTab.setBackground(new java.awt.Color(255, 255, 255));

        Left4.setBackground(new java.awt.Color(174, 211, 232));
        Left4.setPreferredSize(new java.awt.Dimension(24, 570));

        javax.swing.GroupLayout Left4Layout = new javax.swing.GroupLayout(Left4);
        Left4.setLayout(Left4Layout);
        Left4Layout.setHorizontalGroup(
            Left4Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 24, Short.MAX_VALUE)
        );
        Left4Layout.setVerticalGroup(
            Left4Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 570, Short.MAX_VALUE)
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
        ProgramComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Choose AMET Script to Execute", " ", "- Time Series Analysis -", "Time Series: 2-m Temp, 2-m Moisture and 10-m Wind", "Time Series: 2-m Temp, 2-m Moisture, 2-m RH and Sfc Pressure", " ", "- Daily Statistics Analysis -", "Daily Statistics: 2-m Temp, 2-m Moisture and 10-m Wind", " ", "- Summary Analysis -", "Summary Statistics: 2-m Temp, 2-m Moisture and 10-m Wind", " ", "- Spatial Surface Analysis -", "Spatial Statistics: 2-m Temp, 2-m Moisture and 10-m Wind", " ", "- Shortwave Radiation Analysis -", "Shortwave Radiation Statistics: Spatial, Diurnal and Time Series", " ", "- Upper-Air Analysis -", "Upper-Air: Spatial, Profile and Time Series", "Upper-Air: Mandatory Spatial Statistics", "Upper-Air: Mandatory Time Series Statistics", "Upper-Air: Mandatory Profile Statistics", "Upper-Air: Mandatory Curtain", "Upper-Air: Native Theta / RH Profiles (Single time)", "Upper-Air: Native Theta / RH Profiles (Every sounding of period)", "Upper-Air: Native Curtain", " ", "-PRISM Analysis-", "PRISM Analysis" }));
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

        MaxRecordsTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        MaxRecordsTextField.setText("5000000");
        MaxRecordsTextField.setBackground(new java.awt.Color(191, 182, 172));
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

        PRISMCheckBox.setText("PRISM precipitation analysis is selected to run");
        PRISMCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        PRISMCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        PRISMCheckBox.setForeground(new java.awt.Color(0, 112, 185));

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
                                        .addComponent(ShortwaveRadEvalPlotOptionsButton, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.PREFERRED_SIZE, 378, javax.swing.GroupLayout.PREFERRED_SIZE))
                                    .addComponent(PRISMCheckBox)))
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
                .addGroup(RunAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(SaveFileCheckBox)
                    .addComponent(PRISMCheckBox))
                .addGap(18, 18, 18)
                .addComponent(TextOutCheckBox)
                .addGap(114, 114, 114)
                .addComponent(RunProgramButton)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
            .addGroup(RunAnalysisTabLayout.createSequentialGroup()
                .addComponent(Left4, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
        );

        jTabbedPane1.addTab("Run Analysis", RunAnalysisTab);

        PRISMAnalysisTab.setBackground(new java.awt.Color(255, 255, 255));

        Left7.setBackground(new java.awt.Color(174, 211, 232));
        Left7.setPreferredSize(new java.awt.Dimension(24, 570));

        javax.swing.GroupLayout Left7Layout = new javax.swing.GroupLayout(Left7);
        Left7.setLayout(Left7Layout);
        Left7Layout.setHorizontalGroup(
            Left7Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 24, Short.MAX_VALUE)
        );
        Left7Layout.setVerticalGroup(
            Left7Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 570, Short.MAX_VALUE)
        );

        DateRangeLabel1.setText("Date Range");
        DateRangeLabel1.setBackground(new java.awt.Color(255, 255, 255));
        DateRangeLabel1.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        DateRangeLabel1.setForeground(new java.awt.Color(0, 112, 185));

        StartDateLabel1.setText("Start Date");
        StartDateLabel1.setBackground(new java.awt.Color(255, 255, 255));
        StartDateLabel1.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        StartDateLabel1.setForeground(new java.awt.Color(0, 112, 185));

        EndDateLabel1.setText("End Date");
        EndDateLabel1.setBackground(new java.awt.Color(255, 255, 255));
        EndDateLabel1.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        EndDateLabel1.setForeground(new java.awt.Color(0, 112, 185));

        StartDatePicker1.setBackground(new java.awt.Color(255, 255, 255));
        StartDatePicker1.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        StartDatePicker1.setForeground(new java.awt.Color(0, 112, 185));

        EndDatePicker1.setBackground(new java.awt.Color(255, 255, 255));
        EndDatePicker1.setFont(new java.awt.Font("sansserif", 1, 12)); // NOI18N
        EndDatePicker1.setForeground(new java.awt.Color(0, 112, 185));

        AnalysisTypeLabel.setText("Analysis Period");
        AnalysisTypeLabel.setBackground(new java.awt.Color(255, 255, 255));
        AnalysisTypeLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        AnalysisTypeLabel.setForeground(new java.awt.Color(0, 112, 185));

        buttonGroup1.add(DailyRadioButton);
        DailyRadioButton.setText("Daily (one month max)");
        DailyRadioButton.setBackground(new java.awt.Color(255, 255, 255));
        DailyRadioButton.setFont(new java.awt.Font("Times New Roman", 1, 16));
        DailyRadioButton.setForeground(new java.awt.Color(0, 112, 185));

        buttonGroup1.add(MonthlyRadioButton);
        MonthlyRadioButton.setText("Monthly (for date range)");
        MonthlyRadioButton.setBackground(new java.awt.Color(255, 255, 255));
        MonthlyRadioButton.setFont(new java.awt.Font("Times New Roman", 1, 16));
        MonthlyRadioButton.setForeground(new java.awt.Color(0, 112, 185));

        buttonGroup1.add(AnnualRadioButton);
        AnnualRadioButton.setText("Annual (for start date year)");
        AnnualRadioButton.setBackground(new java.awt.Color(255, 255, 255));
        AnnualRadioButton.setFont(new java.awt.Font("Times New Roman", 1, 16));
        AnnualRadioButton.setForeground(new java.awt.Color(0, 112, 185));

        WRFFilesLabel.setText("Model Output Directory");
        WRFFilesLabel.setBackground(new java.awt.Color(255, 255, 255));
        WRFFilesLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        WRFFilesLabel.setForeground(new java.awt.Color(0, 112, 185));

        WRFFilesTextArea.setColumns(20);
        WRFFilesTextArea.setEditable(false);
        WRFFilesTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        WRFFilesTextArea.setLineWrap(true);
        WRFFilesTextArea.setRows(5);
        WRFFilesTextArea.setText("Location of model output that covers the defined analysis periods.\n");
        WRFFilesTextArea.setWrapStyleWord(true);
        WRFFilesTextArea.setBackground(new java.awt.Color(255, 255, 255));
        WRFFilesTextArea.setForeground(new java.awt.Color(0, 112, 185));
        WRFFilesTextArea.setPreferredSize(new java.awt.Dimension(400, 109));

        WRFFilesButton.setText("Select DIrectory");
        WRFFilesButton.setAlignmentX(0.5F);
        WRFFilesButton.setBackground(new java.awt.Color(0, 63, 105));
        WRFFilesButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        WRFFilesButton.setForeground(new java.awt.Color(191, 182, 172));
        WRFFilesButton.setMaximumSize(new java.awt.Dimension(274, 23));
        WRFFilesButton.setMinimumSize(new java.awt.Dimension(274, 23));
        WRFFilesButton.setPreferredSize(new java.awt.Dimension(274, 23));
        WRFFilesButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                WRFFilesButtonActionPerformed(evt);
            }
        });

        GridSpacingLabel.setText("Leaflet Grid Resolution (km)");
        GridSpacingLabel.setBackground(new java.awt.Color(255, 255, 255));
        GridSpacingLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        GridSpacingLabel.setForeground(new java.awt.Color(0, 112, 185));

        GridSpacingTextArea.setColumns(20);
        GridSpacingTextArea.setEditable(false);
        GridSpacingTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        GridSpacingTextArea.setLineWrap(true);
        GridSpacingTextArea.setRows(5);
        GridSpacingTextArea.setText("Leaflets are interactive HTML-based plots of the raster data. Default (-99) sets this value to the model grid resolution. Nearest-neighbor interpolation is used. Default is advised.");
        GridSpacingTextArea.setWrapStyleWord(true);
        GridSpacingTextArea.setBackground(new java.awt.Color(255, 255, 255));
        GridSpacingTextArea.setForeground(new java.awt.Color(0, 112, 185));
        GridSpacingTextArea.setPreferredSize(new java.awt.Dimension(400, 109));

        GridSpacingTextField.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        GridSpacingTextField.setText("-99");
        GridSpacingTextField.setBackground(new java.awt.Color(191, 182, 172));
        GridSpacingTextField.setForeground(new java.awt.Color(0, 63, 105));
        GridSpacingTextField.setMinimumSize(new java.awt.Dimension(232, 22));
        GridSpacingTextField.setPreferredSize(new java.awt.Dimension(232, 22));

        ModelLabel.setText("Model Output Prefix");
        ModelLabel.setBackground(new java.awt.Color(255, 255, 255));
        ModelLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        ModelLabel.setForeground(new java.awt.Color(0, 112, 185));

        ModelTextArea.setColumns(20);
        ModelTextArea.setEditable(false);
        ModelTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        ModelTextArea.setLineWrap(true);
        ModelTextArea.setRows(5);
        ModelTextArea.setText("Naming convention for model output files (before date stamp).\ne.g.; WRF \"wrfout_d0*_\"  or  MPAS \"history.\"");
        ModelTextArea.setWrapStyleWord(true);
        ModelTextArea.setBackground(new java.awt.Color(255, 255, 255));
        ModelTextArea.setForeground(new java.awt.Color(0, 112, 185));
        ModelTextArea.setPreferredSize(new java.awt.Dimension(400, 109));
        ModelTextArea.setToolTipText("");

        ModelOutputTextField.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        ModelOutputTextField.setText("wrfout_d01_");
        ModelOutputTextField.setBackground(new java.awt.Color(191, 182, 172));
        ModelOutputTextField.setForeground(new java.awt.Color(0, 63, 105));
        ModelOutputTextField.setMinimumSize(new java.awt.Dimension(232, 22));
        ModelOutputTextField.setPreferredSize(new java.awt.Dimension(232, 22));

        ModelLabel1.setText("Model Precip Indices");
        ModelLabel1.setBackground(new java.awt.Color(255, 255, 255));
        ModelLabel1.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        ModelLabel1.setForeground(new java.awt.Color(0, 112, 185));

        ModelTextArea1.setColumns(20);
        ModelTextArea1.setEditable(false);
        ModelTextArea1.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        ModelTextArea1.setLineWrap(true);
        ModelTextArea1.setRows(5);
        ModelTextArea1.setText("Time indices of start and end model outputs that define total precip of analysis period");
        ModelTextArea1.setWrapStyleWord(true);
        ModelTextArea1.setBackground(new java.awt.Color(255, 255, 255));
        ModelTextArea1.setForeground(new java.awt.Color(0, 112, 185));
        ModelTextArea1.setPreferredSize(new java.awt.Dimension(400, 109));
        ModelTextArea1.setToolTipText("");

        StartTimeIndexTextField.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        StartTimeIndexTextField.setText("1");
        StartTimeIndexTextField.setBackground(new java.awt.Color(191, 182, 172));
        StartTimeIndexTextField.setForeground(new java.awt.Color(0, 63, 105));
        StartTimeIndexTextField.setMinimumSize(new java.awt.Dimension(232, 22));
        StartTimeIndexTextField.setPreferredSize(new java.awt.Dimension(232, 22));

        StartTimeIndexLabel.setText("Start Time Index");
        StartTimeIndexLabel.setBackground(new java.awt.Color(255, 255, 255));
        StartTimeIndexLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        StartTimeIndexLabel.setForeground(new java.awt.Color(0, 112, 185));

        EndTimeIndexLabel.setText("End Time Index");
        EndTimeIndexLabel.setBackground(new java.awt.Color(255, 255, 255));
        EndTimeIndexLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        EndTimeIndexLabel.setForeground(new java.awt.Color(0, 112, 185));

        EndTimeIndexTextField.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        EndTimeIndexTextField.setText("24");
        EndTimeIndexTextField.setBackground(new java.awt.Color(191, 182, 172));
        EndTimeIndexTextField.setForeground(new java.awt.Color(0, 63, 105));
        EndTimeIndexTextField.setMinimumSize(new java.awt.Dimension(232, 22));
        EndTimeIndexTextField.setPreferredSize(new java.awt.Dimension(232, 22));

        NetCDFCheckBox.setSelected(true);
        NetCDFCheckBox.setText("Create a NetCDF file");
        NetCDFCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        NetCDFCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        NetCDFCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        ModelLabel2.setText("NetCDF File Creation");
        ModelLabel2.setBackground(new java.awt.Color(255, 255, 255));
        ModelLabel2.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        ModelLabel2.setForeground(new java.awt.Color(0, 112, 185));

        RunPRISMButton.setText("Run Analysis");
        RunPRISMButton.setBackground(new java.awt.Color(38, 161, 70));
        RunPRISMButton.setFont(new java.awt.Font("Times New Roman", 1, 20)); // NOI18N
        RunPRISMButton.setForeground(new java.awt.Color(0, 63, 105));
        RunPRISMButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                RunPRISMButtonActionPerformed(evt);
            }
        });

        WRFFilesTextArea1.setColumns(20);
        WRFFilesTextArea1.setEditable(false);
        WRFFilesTextArea1.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        WRFFilesTextArea1.setLineWrap(true);
        WRFFilesTextArea1.setRows(5);
        WRFFilesTextArea1.setText("This tab provides a method to evaluate precipitation using 4km CONUS PRISM data for daily, monthly and annual periods. Data is automatically retrieved from PRISM servers for the specified period. https://prism.oregonstate.edu\nhttps://prism.oregonstate.edu/");
        WRFFilesTextArea1.setWrapStyleWord(true);
        WRFFilesTextArea1.setBackground(new java.awt.Color(255, 255, 255));
        WRFFilesTextArea1.setForeground(new java.awt.Color(0, 63, 105));
        WRFFilesTextArea1.setPreferredSize(new java.awt.Dimension(400, 109));

        PrecipDirectoryLabel.setText("Custom Directory Name");
        PrecipDirectoryLabel.setBackground(new java.awt.Color(255, 255, 255));
        PrecipDirectoryLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        PrecipDirectoryLabel.setForeground(new java.awt.Color(0, 112, 185));

        PrecipDirectoryTextField.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        PrecipDirectoryTextField.setBackground(new java.awt.Color(191, 182, 172));
        PrecipDirectoryTextField.setForeground(new java.awt.Color(0, 63, 105));
        PrecipDirectoryTextField.setMinimumSize(new java.awt.Dimension(232, 22));
        PrecipDirectoryTextField.setPreferredSize(new java.awt.Dimension(232, 22));

        javax.swing.GroupLayout PRISMAnalysisTabLayout = new javax.swing.GroupLayout(PRISMAnalysisTab);
        PRISMAnalysisTab.setLayout(PRISMAnalysisTabLayout);
        PRISMAnalysisTabLayout.setHorizontalGroup(
            PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(PRISMAnalysisTabLayout.createSequentialGroup()
                .addComponent(Left7, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addGroup(PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(PRISMAnalysisTabLayout.createSequentialGroup()
                        .addGroup(PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addGroup(PRISMAnalysisTabLayout.createSequentialGroup()
                                .addGroup(PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addComponent(DateRangeLabel1)
                                    .addComponent(AnalysisTypeLabel)
                                    .addComponent(DailyRadioButton)
                                    .addComponent(MonthlyRadioButton)
                                    .addComponent(AnnualRadioButton)
                                    .addComponent(ModelLabel1)
                                    .addComponent(ModelLabel2)
                                    .addGroup(PRISMAnalysisTabLayout.createSequentialGroup()
                                        .addGap(6, 6, 6)
                                        .addGroup(PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                            .addGroup(PRISMAnalysisTabLayout.createSequentialGroup()
                                                .addComponent(StartTimeIndexLabel)
                                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                                .addComponent(StartTimeIndexTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 41, javax.swing.GroupLayout.PREFERRED_SIZE)
                                                .addGap(18, 18, 18)
                                                .addComponent(EndTimeIndexLabel)
                                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                                .addComponent(EndTimeIndexTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 41, javax.swing.GroupLayout.PREFERRED_SIZE))
                                            .addGroup(PRISMAnalysisTabLayout.createSequentialGroup()
                                                .addGroup(PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                                    .addComponent(StartDateLabel1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                                    .addComponent(EndDateLabel1, javax.swing.GroupLayout.PREFERRED_SIZE, 93, javax.swing.GroupLayout.PREFERRED_SIZE))
                                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                                .addGroup(PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                                    .addComponent(StartDatePicker1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                                    .addComponent(EndDatePicker1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                                            .addComponent(ModelTextArea1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                                    .addComponent(PrecipDirectoryLabel)
                                    .addComponent(PrecipDirectoryTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 97, Short.MAX_VALUE)
                                .addGroup(PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addComponent(WRFFilesLabel)
                                    .addComponent(WRFFilesTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(GridSpacingLabel)
                                    .addComponent(GridSpacingTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(ModelLabel)
                                    .addComponent(ModelTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addGroup(PRISMAnalysisTabLayout.createSequentialGroup()
                                        .addGap(6, 6, 6)
                                        .addGroup(PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                            .addComponent(GridSpacingTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 100, javax.swing.GroupLayout.PREFERRED_SIZE)
                                            .addComponent(WRFFilesButton, javax.swing.GroupLayout.PREFERRED_SIZE, 240, javax.swing.GroupLayout.PREFERRED_SIZE)
                                            .addComponent(ModelOutputTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 132, javax.swing.GroupLayout.PREFERRED_SIZE)
                                            .addComponent(RunPRISMButton, javax.swing.GroupLayout.PREFERRED_SIZE, 200, javax.swing.GroupLayout.PREFERRED_SIZE)))))
                            .addComponent(WRFFilesTextArea1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                        .addGap(36, 36, 36))
                    .addGroup(PRISMAnalysisTabLayout.createSequentialGroup()
                        .addComponent(NetCDFCheckBox)
                        .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))))
        );
        PRISMAnalysisTabLayout.setVerticalGroup(
            PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(PRISMAnalysisTabLayout.createSequentialGroup()
                .addComponent(Left7, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, PRISMAnalysisTabLayout.createSequentialGroup()
                .addGap(20, 20, 20)
                .addComponent(WRFFilesTextArea1, javax.swing.GroupLayout.PREFERRED_SIZE, 31, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(DateRangeLabel1)
                    .addComponent(WRFFilesLabel))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(PRISMAnalysisTabLayout.createSequentialGroup()
                        .addComponent(WRFFilesTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 31, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(WRFFilesButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(GridSpacingLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(GridSpacingTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 68, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(GridSpacingTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(ModelLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ModelTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 47, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ModelOutputTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(PRISMAnalysisTabLayout.createSequentialGroup()
                        .addGroup(PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(StartDateLabel1)
                            .addComponent(StartDatePicker1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addGap(18, 18, 18)
                        .addGroup(PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(EndDatePicker1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(EndDateLabel1))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(AnalysisTypeLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(DailyRadioButton)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(MonthlyRadioButton)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(AnnualRadioButton)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ModelLabel1)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ModelTextArea1, javax.swing.GroupLayout.PREFERRED_SIZE, 35, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addGroup(PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(StartTimeIndexLabel)
                            .addComponent(StartTimeIndexTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(EndTimeIndexTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(EndTimeIndexLabel))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ModelLabel2)))
                .addGap(0, 0, 0)
                .addComponent(NetCDFCheckBox)
                .addGroup(PRISMAnalysisTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(PRISMAnalysisTabLayout.createSequentialGroup()
                        .addGap(25, 25, 25)
                        .addComponent(RunPRISMButton))
                    .addGroup(PRISMAnalysisTabLayout.createSequentialGroup()
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(PrecipDirectoryLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(PrecipDirectoryTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addGap(41, 41, 41))
        );

        jTabbedPane1.addTab("PRECIPITATION", PRISMAnalysisTab);

        BackTab.setBackground(new java.awt.Color(255, 255, 255));

        Left8.setBackground(new java.awt.Color(174, 211, 232));
        Left8.setPreferredSize(new java.awt.Dimension(24, 570));

        javax.swing.GroupLayout Left8Layout = new javax.swing.GroupLayout(Left8);
        Left8.setLayout(Left8Layout);
        Left8Layout.setHorizontalGroup(
            Left8Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 24, Short.MAX_VALUE)
        );
        Left8Layout.setVerticalGroup(
            Left8Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 570, Short.MAX_VALUE)
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
                .addGap(0, 0, Short.MAX_VALUE))
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

        jTabbedPane1.addTab("Back    ", BackTab);

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

        setSize(new java.awt.Dimension(999, 753));
        setLocationRelativeTo(null);
    }// </editor-fold>//GEN-END:initComponents

    private void ClimateRegionsMapButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ClimateRegionsMapButtonActionPerformed
        new ClimateRegionsMap().setVisible(true);
    }//GEN-LAST:event_ClimateRegionsMapButtonActionPerformed

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
            else if (ClimateRegionMonthlyCheckBox.isSelected()) {
                new WrapperPopUpWindow(file_path).setVisible(true);
            }
            else if (ClimateRegionSeasonalCheckBox.isSelected()) {
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
        if (dbase.equals(SelectDatabaseComboBox.getSelectedItem().toString())) { 
            return; }

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

    private void WRFFilesButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_WRFFilesButtonActionPerformed
        JFileChooser chooser = new JFileChooser();
        chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
        
        if(chooser.showOpenDialog(null) == JFileChooser.APPROVE_OPTION) {
            String filePath = (chooser.getSelectedFile().getPath());
            WRF_file = filePath;
            System.out.println("WFR file: " + WRF_file);
        }
        else {
            System.out.println("No model output directory set.");
        }

    }//GEN-LAST:event_WRFFilesButtonActionPerformed

    private void RunPRISMButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_RunPRISMButtonActionPerformed
        ProgramComboBox.setSelectedIndex(29);
        saveVariables();

        createRunInfo();
        executeProgram();

        outputWindow();
    }//GEN-LAST:event_RunPRISMButtonActionPerformed

    private void MetSiteFinderButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_MetSiteFinderButtonActionPerformed
        ProgramComboBox.setSelectedIndex(0);
        run_program = "MET_kml.R";
        
        saveVariables();


        createRunInfo();
        executeProgram();
        
        outputWindow();
    }//GEN-LAST:event_MetSiteFinderButtonActionPerformed

    /**
     * @param args the command line arguments
     */

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JRadioButton AllRadioButton;
    private javax.swing.JLabel AnalysisTypeLabel;
    private javax.swing.JRadioButton AnnualRadioButton;
    private javax.swing.JPanel BackTab;
    private javax.swing.JButton BarPlotOptionsButton;
    private javax.swing.JButton ClearFilesButton;
    private javax.swing.JLabel ClearFilesLabel;
    private javax.swing.JTextField ClearFilesTextField;
    private javax.swing.JCheckBox ClimateRegionMonthlyCheckBox;
    private javax.swing.JLabel ClimateRegionMonthlyLabel;
    private javax.swing.JTextArea ClimateRegionMonthlyTextArea;
    private javax.swing.JCheckBox ClimateRegionSeasonalCheckBox;
    private javax.swing.JLabel ClimateRegionSeasonalLabel;
    private javax.swing.JTextArea ClimateRegionSeasonalTextArea;
    private javax.swing.JButton ClimateRegionsMapButton;
    private javax.swing.JComboBox<String> ContinentComboBox;
    private javax.swing.JLabel ContinentInfoLabel;
    private javax.swing.JLabel ContinentLabel;
    private javax.swing.JComboBox<String> CountryComboBox;
    private javax.swing.JLabel CountryInfoLabel;
    private javax.swing.JLabel CountryLabel;
    private javax.swing.JLabel CustomDirectoryNameLabel;
    private javax.swing.JTextField CustomDirectoryNameTextField;
    private javax.swing.JLabel CustomRunNameLabel;
    private javax.swing.JTextField CustomRunNameTextField;
    private javax.swing.JRadioButton DailyRadioButton;
    private javax.swing.JLabel DateRangeLabel;
    private javax.swing.JLabel DateRangeLabel1;
    private javax.swing.JTextArea DateRangeTextArea;
    private javax.swing.JPanel DateTimeTab;
    private javax.swing.JButton DiurnalStatSummaryPlotOptionsButton;
    private javax.swing.JLabel EndDateLabel;
    private javax.swing.JLabel EndDateLabel1;
    private com.github.lgooddatepicker.components.DatePicker EndDatePicker;
    private com.github.lgooddatepicker.components.DatePicker EndDatePicker1;
    private javax.swing.JComboBox<String> EndHourComboBox;
    private javax.swing.JComboBox<String> EndHourComboBox1;
    private javax.swing.JLabel EndHourLabel;
    private javax.swing.JLabel EndTimeIndexLabel;
    private javax.swing.JTextField EndTimeIndexTextField;
    private javax.swing.JLabel Footer;
    private javax.swing.JLabel ForecastPeriodLabel;
    private javax.swing.JComboBox<String> GraphicsFormatComboBox;
    private javax.swing.JLabel GraphicsFormatLabel;
    private javax.swing.JTextArea GraphicsFormatTextArea;
    private javax.swing.JLabel GridSpacingLabel;
    private javax.swing.JTextArea GridSpacingTextArea;
    private javax.swing.JTextField GridSpacingTextField;
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
    private javax.swing.JPanel Left7;
    private javax.swing.JPanel Left8;
    private javax.swing.JLabel LonLabel1;
    private javax.swing.JLabel LonLabel2;
    private javax.swing.JTextField LonTextField1;
    private javax.swing.JTextField LonTextField2;
    private javax.swing.JLabel METNetworkInfoLabel;
    private javax.swing.JLabel METNetworkInfoLabel1;
    private javax.swing.JLabel METNetworkLabel;
    private javax.swing.JLabel METPlotOptionsLabel;
    private javax.swing.JRadioButton MaritimeRadioButton;
    private javax.swing.JLabel MaxRecordsLabel;
    private javax.swing.JTextField MaxRecordsTextField;
    private javax.swing.JRadioButton MesonetRadioButton;
    private javax.swing.JButton MetSiteFinderButton;
    private javax.swing.JRadioButton MetarRadioButton;
    private javax.swing.JLabel ModelLabel;
    private javax.swing.JLabel ModelLabel1;
    private javax.swing.JLabel ModelLabel2;
    private javax.swing.JTextField ModelOutputTextField;
    private javax.swing.JTextArea ModelTextArea;
    private javax.swing.JTextArea ModelTextArea1;
    private javax.swing.JCheckBox MonthlyAnalysisCheckBox;
    private javax.swing.JLabel MonthlyAnalysisLabel;
    private javax.swing.JTextArea MonthlyAnalysisTextArea;
    private javax.swing.JRadioButton MonthlyRadioButton;
    private javax.swing.JCheckBox NetCDFCheckBox;
    private javax.swing.JPanel OutputPropertiesTab;
    private javax.swing.JPanel PRISMAnalysisTab;
    public javax.swing.JCheckBox PRISMCheckBox;
    private javax.swing.JLabel PlotSpecificAdvancedOptionsLabel;
    private javax.swing.JTextArea PlotlyIamgeInfoTextArea;
    private javax.swing.JLabel PlotlyImageLabel;
    private javax.swing.JPanel PlotlyImagePanel;
    private javax.swing.JLabel PrecipDirectoryLabel;
    private javax.swing.JTextField PrecipDirectoryTextField;
    private javax.swing.JComboBox<String> ProgramComboBox;
    private javax.swing.JLabel ProgramLabel;
    private javax.swing.JTextArea ProgramTextArea;
    private javax.swing.JLabel ProjectDetailsLabel;
    private javax.swing.JTextArea ProjectDetailsTextArea;
    private javax.swing.JPanel ProjectTab;
    private javax.swing.JButton RAOBPlotOptionsButton;
    private javax.swing.JPanel RegionalTab;
    private javax.swing.JButton ReturnButton;
    private javax.swing.JPanel RunAnalysisTab;
    private javax.swing.JButton RunPRISMButton;
    private javax.swing.JButton RunProgramButton;
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
    private javax.swing.JLabel StartDateLabel1;
    private com.github.lgooddatepicker.components.DatePicker StartDatePicker;
    private com.github.lgooddatepicker.components.DatePicker StartDatePicker1;
    private javax.swing.JComboBox<String> StartHourComboBox;
    private javax.swing.JComboBox<String> StartHourComboBox1;
    private javax.swing.JComboBox<String> StartHourComboBox2;
    private javax.swing.JLabel StartHourLabel;
    private javax.swing.JLabel StartHourLabel1;
    private javax.swing.JLabel StartTimeIndexLabel;
    private javax.swing.JTextField StartTimeIndexTextField;
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
    private javax.swing.JButton WRFFilesButton;
    private javax.swing.JLabel WRFFilesLabel;
    private javax.swing.JTextArea WRFFilesTextArea;
    private javax.swing.JTextArea WRFFilesTextArea1;
    private javax.swing.JLabel WidthLabel;
    private javax.swing.JTextField WidthTextField;
    private javax.swing.ButtonGroup buttonGroup1;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JPanel jPanel2;
    private javax.swing.JTabbedPane jTabbedPane1;
    // End of variables declaration//GEN-END:variables
}
