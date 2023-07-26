package ametjavagui;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author Michael Morton
 */

import ametjavagui.AQAdvancedForms.AdvancedSpeciesSettings;
import ametjavagui.AQAdvancedForms.OverlayFileOptions;
import ametjavagui.AQAdvancedForms.ScatterPlotOptions;
import ametjavagui.AQAdvancedForms.SoccergoalBuglePlotOptions;
import ametjavagui.AQAdvancedForms.SpatialPlotOptions;
import ametjavagui.AQAdvancedForms.AxisOptionsPlots;
import ametjavagui.AQAdvancedForms.ModelEvalOptions;
import com.github.lgooddatepicker.components.DatePickerSettings;
import java.awt.Cursor;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.Random;


public class AirQualityForm extends javax.swing.JFrame {    
    Config config = new Config();

    //Variable instantiation and setting default values
    public String run_program = "";
    public String query = "\"\""; 
    public String dbase = "\"\""; 
    public String run_name1 = "\"\""; 
    public String run_name2 = "\"\""; 
    public String run_name3 = "\"\""; 
    public String run_name4 = "\"\""; 
    public String run_name5 = "\"\""; 
    public String run_name6 = "\"\""; 
    public String run_name7 = "\"\""; 
    public String species_in = "\"\""; 
    public String custom_species = "\"\""; 
    public String custom_species_name = "\"\""; 
    public String custom_species_query = "\"\"";
    public String custom_units = "\"\""; 
    public String inc_csn = "\"\""; 
    public String inc_improve = "\"\""; 
    public String inc_castnet = "\"\""; 
    public String inc_castnet_hr = "\"\""; 
    public String inc_castnet_daily = "\"\""; 
    public String inc_castnet_drydep = "\"\"";
    public String inc_capmon = "\"\""; 
    public String inc_naps = "\"\""; 
    public String inc_naps_daily_o3 = "\"\""; 
    public String inc_nadp = "\"\"";
    public String inc_airmon_dep = "\"\"";
    public String inc_amon = "\"\""; 
    public String inc_aqs_hourly = "\"\""; 
    public String inc_aqs_daily_o3 = "\"\"";
    public String inc_aqs_daily = "\"\"";
    public String inc_aqs_daily_oaqps = "\"\"";
    public String inc_aqs_daily_pm = "\"\""; 
    public String inc_search = "\"\"";
    public String inc_search_daily = "\"\""; 
    public String inc_aeronet = "\"\"";
    public String inc_fluxnet = "\"\"";
    public String inc_noaa_esrl_o3 = "\"\"";
    public String inc_toar = "\"\""; 
    public String inc_mdn = "\"\""; 
    public String inc_tox = "\"\"";
    public String inc_mod = "\"\"";
    public String inc_admn = "\"\"";
    public String inc_aganet = "\"\""; 
    public String inc_airbase_hourly = "\"\""; 
    public String inc_airbase_daily = "\"\""; 
    public String inc_aurn_hourly = "\"\""; 
    public String inc_aurn_daily = "\"\""; 
    public String inc_emep_hourly = "\"\""; 
    public String inc_emep_daily = "\"\""; 
    public String inc_emep_daily_o3 = "\"\""; 
    public String inc_calnex = "\"\""; 
    public String inc_soas = "\"\""; 
    public String inc_special = "\"\""; 
    public String dates = "\"\""; 
    public String averaging = "\"n\""; 
    public String state = "\"\"";
    public String rpo = "\"\"";
    public String pca = "\"\"";
    public String clim_reg = "\"\"";
    public String world_reg = "\"\"";
    public String loc_setting = "\"\"";
    public String conf_line = "\"\"";
    public String pca_flag = "\"\"";
    public String bin_by_mod = "\"\"";
    public String inc_error = "\"\"";
    public String trend_line = "\"y\"";
    public int coverage_limit = 75;
    public String all_valid = "\"y\"";
    public String all_valid_amon = "\"\"";
    public String aggregate_data = "\"\"";
    public int num_obs_limit = 1;
    public String soccerplot_opt = "1";
    public String overlay_opt = "1"; 
    public int png_res = 300;
    public String x_axis_min = "NULL";
    public String x_axis_max = "NULL";
    public String y_axis_min = "NULL";
    public String y_axis_max = "NULL";
    public String nmb_max = "NULL";
    public String nme_max = "NULL";
    public String mb_max = "NULL";
    public String me_min = "NULL";
    public String me_max = "NULL";
    public String rmse_min = "NULL";
    public String rmse_max = "NULL";
    public String nmb_int = "NULL";
    public String nme_int = "NULL";
    public String bias_y_axis_min = "NULL";
    public String bias_y_axis_max = "NULL";
    public String density_zlim = "NULL";
    public String num_dens_bins = "NULL";
    public String max_limit = "70";
    public String x_label_angle = "0";
    public String inc_ranges = "\"y\"";
    public String inc_whiskers = "\"\"";
    public String inc_median_lines = "\"\"";
    public String remove_mean = "\"\"";
    public String overlap_boxes = "\"\"";
    public String avg_func = "mean";
    public String avg_func_name = "\"mean\"";
    public String stat_func = "\"\"";
    public String line_width = "\"1\"";
    public String custom_title = "\"\"";
    public String map_leg_size = "\"\"";
    public String stat_file = "\"\"";
    public String num_ints = "NULL";
    public String perc_error_max = "NULL";
    public String abs_error_max = "NULL";
    public String perc_range_min = "NULL";
    public String perc_range_max = "NULL";
    public String abs_range_min = "NULL";
    public String abs_range_max = "NULL";
    public String diff_range_min = "NULL";
    public String diff_range_max = "NULL";
    public String rmse_range_max = "NULL";
    public String hist_max = "NULL";
    public String quantile_min = "0.001";
    public String quantile_max = "0.999";
    public String symbol_size_fac = "1";
    public String plot_radius = "0";
    public String outlier_radius = "20"; 
    public String fill_opacity = "0.8";
    public String remove_negatives = "\"y\"";
    public String use_avg_stats = "\"\"";
    public String common_sites = "\"y\"";
    public String inc_legend = "\"y\"";
    public String inc_points = "\"y\"";
    public String inc_bias = "\"y\"";
    public String inc_rmse = "\"\"";
    public String inc_corr = "\"\"";
    public String use_var_mean = "\"\"";
    public String plot_cor = "\"\"";
    public String inc_FRM_adj = "\"y\"";
    public String use_median = "\"\"";
    public String stats_flags = "c(\"\",\"\",\"\",\"y\",\"\",\"\",\"\",\"y\",\"y\",\"\",\"\",\"\",\"\",\"\",\"\",\"y\",\"y\",\"\",\"\")";
    public String run_info_text = "\"y\"";
    public String png_from_html = "\"\"";
    public String plot_colors = "c(\"grey60\",\"red\",\"blue\",\"green4\",\"yellow3\",\"orange2\",\"brown\",\"purple\")";
    public String plot_colors2 = "c(\"grey60\",\"red\",\"blue\",\"green4\",\"yellow3\",\"orange2\",\"brown\",\"purple\")";
    public String plot_symbols = "c(16,17,15,18,11,8,4)";
    public String year_start = "\"\"";
    public String year_end = "\"\"";
    public String month_start = "\"\"";
    public String month_end = "\"\"";
    public String day_start = "\"\"";
    public String day_end = "\"\"";
    public String greyscale = "\"\"";
    public String inc_counties = "\"y\"";
    public int obs_per_day_limit = 0;
    public String figdir = "\"\"";
    public String map_type = "1";
    public String img_height = "\"NULL\"";
    public String img_width = "\"NULL\"";
    public String discovaq = "\"\"";
    public String site_id = "\"\"";
    public String start_hour = "\"\"";
    public String end_hour = "\"\"";
    public String season = "\"\"";
    public String month_name = "\"\"";
    public int month = 0;
    public String poCode = "\"\"";
    public String lat1 = "";
    public String lat2 = "";
    public String lon1 = "";
    public String lon2 = "";
    public String zeroprecip = "\"\"";
    public String pid = "\"\"";
    public String dir_name = "";
    public String dir_namex = "";
    public String run_info = "\"\"";
    public String username = System.getProperty("user.name");
    public String file_path = "";
    public String ametptype = "\"both\"";
    public String custom_query = "";
    public String co_network = "";
    public String dir_name_delete = "";
    public String dir_path = "";
    public String path = "";
    public String amet_static = "";
    public String hs = "";
    public String he = "";
    public String mysql_server = "amet.ib";
    
    //file naming info
    public String project_id = "";
    public String species = "";
    public String pidx = "";
    
    //check helper variable
    public boolean isNetworkSelectedTemp = false;
    public boolean isNetworkSelected = false;
    
    
    
//##############################################################################
//   MAIN FUNCTIONS 
//##############################################################################
    //creates a new AMETForm
    public AirQualityForm() {
        //Create the AMET Form
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
        Random rand = new Random();
        pidx = String.valueOf(rand.nextInt(1000000));
        pid = "\"" + pidx + "\"";
        run_info = "run_info_AQ." + pidx + ".R";
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
        
        file_path = config.dir_name  + username + "." + dir_namex;
        figdir = "\"" + config.dir_name + username + "." + dir_namex + "\"";
        dbase = SelectDatabaseComboBox.getSelectedItem().toString();
        run_name1 = textFormat(SelectProjectComboBox.getSelectedItem().toString());
        run_name2 = textFormat(SelectAdditionalProjectComboBox1.getSelectedItem().toString());
        run_name3 = textFormat(SelectAdditionalProjectComboBox2.getSelectedItem().toString());
        run_name4 = textFormat(SelectAdditionalProjectComboBox3.getSelectedItem().toString());
        run_name5 = textFormat(SelectAdditionalProjectComboBox4.getSelectedItem().toString());
        run_name6 = textFormat(SelectAdditionalProjectComboBox5.getSelectedItem().toString());
        run_name7 = textFormat(SelectAdditionalProjectComboBox6.getSelectedItem().toString());
        
        species_in = textFormat(SpeciesComboBox1.getSelectedItem().toString());
        species = SpeciesComboBox1.getSelectedItem().toString();
        
        hs = "00";
        he = "23";

        isNetworkSelectedTemp = false; //sets temp false
        inc_csn = checkBoxFormat(CSNCheckBox);
        inc_improve = checkBoxFormat(IMPROVECheckBox);
        inc_castnet = checkBoxFormat(CASTNetCheckBox);
        inc_castnet_hr = checkBoxFormat(CASTNetHourlyCheckBox);
        inc_castnet_daily = checkBoxFormat(CASTNetDailyCheckBox);
        inc_castnet_drydep = checkBoxFormat(CASTNetDryDepCheckBox);
        inc_capmon = checkBoxFormat(CAPMoNCheckBox);
        inc_naps = checkBoxFormat(NAPSHourlyCheckBox);
        inc_naps_daily_o3 = checkBoxFormat(NAPSDailyO3CheckBox);
        inc_nadp = checkBoxFormat(NADPCheckBox);
        inc_airmon_dep = checkBoxFormat(AIRMONCheckBox);
        inc_amon = checkBoxFormat(AMONCheckBox);
        inc_aqs_hourly = checkBoxFormat(AQSHourlyCheckBox);
        inc_aqs_daily_o3 = checkBoxFormat(AQSDailyO3CheckBox);
        inc_aqs_daily = checkBoxFormat(AQSDailyCheckBox);
        inc_aqs_daily_oaqps = checkBoxFormat(AQSDailyOAQPSCheckBox);
        inc_aqs_daily_pm = checkBoxFormat(AQSDailyCheckBox);
        inc_search = checkBoxFormat(SEARCHHourlyCheckBox);
        inc_search_daily = checkBoxFormat(SEARCHDailyCheckBox);
        inc_aeronet = checkBoxFormat(AERONETCheckBox);
        inc_fluxnet = checkBoxFormat(FluxNetCheckBox);
        inc_noaa_esrl_o3 = checkBoxFormat(NOAAESRLCheckBox);
        inc_toar = checkBoxFormat(TOARCheckBox);
        inc_mdn = checkBoxFormat(MDNCheckBox);
        inc_tox = checkBoxFormat(ToxicsCheckBox);
        inc_mod = checkBoxFormat(ModelModelCheckBox);
        inc_admn = checkBoxFormat(ADMNCheckBox);
        inc_aganet = checkBoxFormat(AGANETCheckBox);
        inc_airbase_hourly = checkBoxFormat(AirBaseHourlyCheckBox);
        inc_airbase_daily = checkBoxFormat(AirBaseDailyCheckBox);
        inc_aurn_hourly = checkBoxFormat(AURNHourlyCheckBox);
        inc_aurn_daily = checkBoxFormat(AURNDailyCheckBox);
        inc_emep_hourly = checkBoxFormat(EMEPHourlyCheckBox);
        inc_emep_daily = checkBoxFormat(EMEPDailyCheckBox);
        inc_emep_daily_o3 = checkBoxFormat(EMEPDailyO3CheckBox);
        inc_calnex = checkBoxFormat(CALNEXCheckBox);
        inc_soas = checkBoxFormat(SOASCheckBox);
        inc_special = checkBoxFormat(SpecialCheckBox);
        isNetworkSelected = isNetworkSelectedTemp; //saves temp value, using this instead of a check function is much faster
        discovaq = textFormat(DiscoverAQComboBox.getSelectedItem().toString());
        averaging = textFormat(TemporalAveragingComboBox.getSelectedItem().toString());
        clim_reg = textFormat(ClimateComboBox.getSelectedItem().toString());
        world_reg = textFormat(WorldComboBox.getSelectedItem().toString());
        aggregate_data = checkBoxFormat(AggregateDataCheckBox);
        custom_title = textFormat(CustomGraphTitleTextField.getText());
        //png_from_html = StaticPNGRadioButton.;
        dates = "\"" + year_start + month_start + day_start + " to " + year_end + month_end + day_end + "\"";  
        start_hour = textFormat(StartHourComboBox.getSelectedItem().toString());
        end_hour = textFormat(EndHourComboBox.getSelectedItem().toString());
        season = textFormat(SeasonalComboBox.getSelectedItem().toString());
        month_name = textFormat(MonthlyComboBox.getSelectedItem().toString());
        poCode = textFormat(POCodeComboBox.getSelectedItem().toString());
        loc_setting = textFormat(SiteLanduseComboBox.getSelectedItem().toString());
        custom_query = CustomMySQLQueryTextField.getText();
        co_network = textFormat(SubsetComboBox.getSelectedItem().toString());
        if (!numNullFormat(LatTextField1.getText()).equals("NULL")){
            lat1 = numNullFormat(LatTextField1.getText());   
        }
        else {
            lat1 = "";
        }
        
        if (!numNullFormat(LatTextField2.getText()).equals("NULL")){
            lat2 = numNullFormat(LatTextField2.getText());
        }
        else {
            lat2 = "";
        }
        
        if (!numNullFormat(LonTextField1.getText()).equals("NULL")){
            lon1 = numNullFormat(LonTextField1.getText());
        }
        else {
            lon1 = "";
        }
        
        if (!numNullFormat(LonTextField2.getText()).equals("NULL")){
            lon2 = numNullFormat(LonTextField2.getText());
        }
        else {
            lon2 = "";
        }
        
        //state formatting
        state = StateComboBox.getSelectedItem().toString();
        if (state.equals("Include all states")) {
            state = "\"All\"";
        } else {
            state = "'" + state + "'";
        }
        
        //RPO formatting
        if (RPOComboBox.getSelectedItem().toString().equals("None")) {
            rpo = "\"None\"";
        } else {
            rpo = textFormat(RPOComboBox.getSelectedItem().toString());
        }
        
        //PCA formatting
        if (PCAComboBox.getSelectedItem().toString().equals("None")) {
            pca = "\"None\"";
        } else {
            pca = textFormat(PCAComboBox.getSelectedItem().toString());
        }
        
        //png_res formatting
        String png_res_name = PNGQualityComboBox.getSelectedItem().toString();
        switch(png_res_name) {
            case "Low":
                png_res = 150;
                break;
            case "Medium":
                png_res = 300;
                break;
            case "High":
                png_res = 600;
                break;  
        }
        
        //Remove negatives formatting
        remove_negatives = NegativeValuesComboBox.getSelectedItem().toString();
        switch(remove_negatives) {
            case "Yes":
                remove_negatives = "\"y\"";
                break;
            case "No":
                remove_negatives = "\"n\"";
        }
        
        //Temporal averagiong formatting
        averaging = TemporalAveragingComboBox.getSelectedItem().toString();
        switch(averaging) {
            case "None":
                averaging = "\"n\"";
                break;
            case "Hour of Day Average":
                averaging = "\"h\"";
                break;
            case "Daily Average":
                averaging = "\"d\"";
                break;
            case "Monthly Average":
                averaging = "\"m\"";
                break;
            case "Year/Month Average":
                averaging = "\"ym\"";
                break;
            case "Seasonal Average":
                averaging = "\"s\"";
                break;
            case "Annual Average":
                averaging = "\"a\"";
                break;
            case "Entire Period Average":
                averaging = "\"e\"";
                break;
            case "Day of Week":
                averaging = "\"dow\"";
                break;
        }
        
        //Date formatting
        String sd = StartDatePicker.getDateStringOrEmptyString();
        String ed = EndDatePicker.getDateStringOrEmptyString();
        if (!sd.equals("")) {
            year_start = sd.substring(0, 4);
            month_start = sd.substring(5, 7);
            day_start = sd.substring(8, 10);
        }
        if (!ed.equals("")) {
            year_end = ed.substring(0, 4);
            month_end  = ed.substring(5, 7);
            day_end  = ed.substring(8, 10);
        }  
        
        //Image height and width formatting
        if (img_height.equals("NULL")) { 
            HeightTextField.getText();
        } 
        else { 
            img_height = textFormat(HeightTextField.getText());
        }
        
        if (img_width.equals("NULL")) { 
            WidthTextField.getText();
        } else { 
            img_width = textFormat(WidthTextField.getText());
        }
        
        
        //Site ID formatting
        if (textFormat(SiteIDTextField.getText()).equals("\"\"")) {
            site_id = "\"All\"";
        } else {
            site_id = textFormat(SiteIDTextField.getText());
        }
    
        //Custom Species formatting
       if (species.equals("Choose a Species") && !custom_species.equals("\"\"")){
            species_in = custom_species;
            species = custom_species;
         }
       if (species.equals("Choose a Species") && custom_species.equals("\"\"") && !custom_species_query.equals("\"\"")){
           species_in = custom_species_query;
           species = custom_species_name;
       }

        //Helper functions
        programFormat();
        queryFormat();
    }
    
    //Checks variables for common errors
    public boolean checkVariables() {
        boolean hasError = false;
        String error = "You must provide a response for the following fields: ";
        //Check if database is selected
        if (dbase.equals("Choose a Database")) { error = error + "\n- Database"; hasError = true; }
        //Check if project is selected
        if (project_id.equals("<Select a Database First>") || project_id.isEmpty() || project_id.equals("Choose a Project")) { error = error + "\n- Project"; hasError = true; }
        //Check if species is selected
        if (species.equals("<Select a Project First>")) { error = error + "\n- Species"; hasError = true; }
        if(species.equals("Choose a Species") && custom_species.equals("\"\"") && custom_species_query.equals("\"\"")) { error = error + "\n- Species"; hasError = true; }
        if (species.equals("\"\"") && custom_species.equals("\"\"")) { error = error + "\n- Species"; hasError = true; }
        //Check if a network is selected
        if (!isNetworkSelected) { error = error + "\n- Network"; hasError = true; }
        //Check if program is selected
        if (run_program.equals("Choose AMET Script to Execute") || run_program.isEmpty()) { error = error + "\n- Program"; hasError = true; }
        //Check if time is conflicting
        if (hasError) {
            errorWindow("Input Error", error);
            return true;
        } else {
            return false;
        }
    }
    
    //Creates run_info.r file used by r scripts
    public void createRunInfo() {
        NewFile file = new NewFile(true, config.cache_amet + "/" + "run_info_files" + "/" + run_info);
        file.openWriter();
        file.writeTo(""
                + "### Indicate this as a MET database query ###\n"
                + "Met_query<- \"F\"\n"
                + "### Use MySQL database for queries\n"
                + "AMET_DB<- \"T\"\n"
                + "#### Main Database Query String ###\n"
                + "query<-\"" + query + "\"\n"
                + "### Process ID number ###\n"
                + "pid<-" + pid + "\n"
                + "### Database Name ###\n"
                + "dbase<-\"" + dbase + "\"\n"
                + "### Parameter Occurrence (PO) Code ###\n"
                + "POCode<-" + "\"\"\n"
                + "### Directory to write figures ###\n"
                + "figdir<-" + figdir + "\n"
                + "### Use only common sites among mulitple simulations ###\n"
                + "common_sites<-" + common_sites + "\n"
                + "### Species ###\n"
                + "species_in<-" + species_in + "\n"
                + "custom_species<-" + custom_species_name + "\n"
                + "custom_species_name<-" + custom_species_name + "\n"
                + "custom_units<-" + custom_units + "\n"
                + "### Project ID Name 1 ###\n"
                + "run_name1<-" + run_name1 + "\n"
                + "project    <- " + run_name1 + "\n"
                + "model      <- project" + "\n"
                + "### Additional Run Names (used for model-to-model comparisons) ###\n"
                + "run_name2<-" + run_name2 + "\n"
                + "run_name3<-" + run_name3 + "\n"
                + "run_name4<-" + run_name4 + "\n"
                + "run_name5<-" + run_name5 + "\n"
                + "run_name6<-" + run_name6 + "\n"
                + "run_name7<-" + run_name7 + "\n"
                + "### Array of Observation Network Flags ###\n"
                + "#inc_networks<-\n"
                + "inc_csn<-" + inc_csn + "\n"
                + "inc_improve<-" + inc_improve + "\n"
                + "inc_castnet<-" + inc_castnet + "\n"
                + "inc_castnet_hr<-" + inc_castnet_hr + "\n"
                + "inc_castnet_daily<-" + inc_castnet_daily + "\n"
                + "inc_castnet_drydep<-" + inc_castnet_drydep + "\n"
                + "inc_capmon<-" + inc_capmon + "\n"
                + "inc_naps<-" + inc_naps + "\n"
                + "inc_naps_daily_o3<-" + inc_naps_daily_o3 + "\n"
                + "inc_nadp<-" + inc_nadp + "\n"
                + "inc_airmon_dep<-" + inc_airmon_dep + "\n"
                + "inc_amon<-" + inc_amon + "\n"
                + "inc_aqs_hourly<-" + inc_aqs_hourly + "\n"
                + "inc_aqs_daily_O3<-" + inc_aqs_daily_o3 + "\n"
                + "inc_aqs_daily<-" + inc_aqs_daily + "\n"
                + "inc_aqs_daily_pm<-" + inc_aqs_daily_pm + "\n"
                + "inc_search<-" + inc_search + "\n"
                + "inc_search_daily<-" + inc_search_daily + "\n"
                + "inc_aeronet<-" + inc_aeronet + "\n"
                + "inc_fluxnet<-" + inc_fluxnet + "\n"
                + "inc_noaa_esrl_o3<-" + inc_noaa_esrl_o3 + "\n"
                + "inc_toar<-" + inc_toar + "\n"
                + "inc_mdn<-" + inc_mdn + "\n"
                + "inc_tox<-" + inc_tox + "\n"
                + "inc_mod<-" + inc_mod + "\n"
                + "## European Networks ##\n"
                + "inc_admn<-" + inc_admn + "\n"
                + "inc_aganet<-" + inc_aganet + "\n"
                + "inc_airbase_hourly<-" + inc_airbase_hourly + "\n"
                + "inc_airbase_daily<-" + inc_airbase_daily + "\n"
                + "inc_aurn_hourly<-" + inc_aurn_hourly + "\n"
                + "inc_aurn_daily<-" + inc_aurn_daily + "\n"
                + "inc_emep_hourly<-" + inc_emep_hourly + "\n"
                + "inc_emep_daily<-" + inc_emep_daily + "\n"
                + "inc_emep_daily_o3<-" + inc_emep_daily_o3 + "\n"
                + "inc_namn<-" + "\"\"" + "\n" //this doesnt exist????
                + "## Campaigns ##\n"
                + "inc_calnex<-" + inc_calnex + "\n"
                + "inc_soas<-" + inc_soas + "\n"
                + "inc_special<-" + inc_special + "\n"
                + "### Universal Plot Options ###\n"
                + "dates<-" + dates + "\n"
                + "custom_title<-" + custom_title + "\n"
                + "png_from_html<-" + png_from_html + "\n"
                + "png_res<-" + png_res + "\n"
                + "x_label_angle<-" + x_label_angle + "\n"
                + "### Plotly Options ###\n"
                + "img_height<-" + img_height + "\n"
                + "img_width<-" + img_width + "\n"
                + "### Flag for Time Averaging ###\n"
                + "averaging<-" + averaging + "\n"
                + "remove_negatives<-" + remove_negatives + "\n"
                + "use_avg_stats<-" + use_avg_stats + "\n"
                + "aggregate_data<-" + aggregate_data + "\n"
                + "merge_statid_POC<-\"y\"\n"
                + "### Time Series Plot Options ###\n"
                + "inc_legend<-" + inc_legend + "\n"
                + "inc_points<-" + inc_points + "\n"
                + "inc_bias<-" + inc_bias + "\n"
                + "inc_rmse<-" + inc_rmse + "\n"
                + "inc_corr<-" + inc_corr + "\n"
                + "use_var_mean<-" + use_var_mean + "\n"
                + "obs_per_day_limit<-" + obs_per_day_limit + "\n"
                + "avg_func<-" + avg_func + "\n"
                + "avg_func_name<-" + avg_func_name + "\n"
                + "line_width<-" + line_width + "\n"
                + "### Kelly Plot Options ###\n"
                + "nmb_max<-" + nmb_max + "\n"
                + "nme_max<-" + nme_max + "\n"
                + "mb_max<-" + mb_max + "\n"
                + "me_min<-" + me_min + "\n"
                + "me_max<-" + me_max + "\n"
                + "rmse_min<-" + rmse_min + "\n"
                + "rmse_max<-" + rmse_max + "\n"
                + "nmb_int<-" + nmb_int + "\n"
                + "nme_int<-" + nme_int + "\n"
                + "### Unique color ranges for some plots ###\n"
                + "color_ranges<-\"n\"\n" //does not exist??
                + "### Monitoring Sites to Include ###\n"
                + "site<-" + site_id + "\n"
                + "### States to Include ###\n"
                + "state<-" + state + "\n"
                + "### Regional Planning Organizations to Include ###\n"
                + "rpo<-" + rpo + "\n"
                + "### Priciple Component Analysis (PCA) Region ###\n"
                + "pca<-" + pca + "\n"
                + "### Climate Region ###\n"
                + "clim_reg<-" + clim_reg + "\n"
                + "### Binned Plot Options ###\n"
                + "pca_flag<-" + pca_flag + "\n"
                + "bin_by_mod<-" + bin_by_mod + "\n"
                + "inc_error<-" + inc_error + "\n"
                + "### Landuse Category\n"
                + "loc_setting<-" + loc_setting + "\n"
                + "### Flag to Include or Remove Zero Precipitation Observations ###\n"
                + "zeroprecip<-" + zeroprecip + "\n" 
                + "### Numerical Limit for Data Completeness as minimum number of required observations (used when calulating site statistics or averages)###\n"
                + "coverage_limit<-" + coverage_limit + "\n"
                + "all_valid<-" + all_valid + "\n"
                + "all_valid_amon<-" + all_valid_amon + "\n"
                + "### Numerical Limit for Data Completeness as minimum number of required observations (used when calulating site statistics or averages)###\n"
                + "num_obs_limit<-" + num_obs_limit + "\n"
                + "### Flag for Soccer and Bugle Plots Setting NMB/NME or FB/FE ###\n"
                + "soccerplot_opt<-" + soccerplot_opt + "\n"
                + "### Flag for PAVE Overlay; 1=hourly, 2=daily ###\n"
                + "overlay_opt<-" + overlay_opt + "\n"
                + "### Flags for Confidence Lines to Plot on Scatterplots ###\n"
                + "conf_line<-" + conf_line + "\n"
                + "trend_line<-" + trend_line + "\n"
                + "### Scatterplot x and y axes limits ###\n"
                + "x_axis_min<-" + x_axis_min + "\n"
                + "x_axis_max<-" + x_axis_max + "\n"
                + "y_axis_min<-" + y_axis_min + "\n"
                + "y_axis_max<-" + y_axis_max + "\n"
                + "bias_y_axis_min<-" + bias_y_axis_min + "\n"
                + "bias_y_axis_max<-" + bias_y_axis_max + "\n"
                + "density_zlim<-" + density_zlim + "\n"
                + "num_dens_bins<-" + num_dens_bins + "\n"
                + "max_limit<-" + max_limit + "\n"
                + "### Hourly Boxplot Options ###\n"
                + "inc_whiskers<-" + inc_whiskers + "\n"
                + "inc_ranges<-" + inc_ranges + "\n"
                + "inc_median_lines<-" + inc_median_lines + "\n"
                + "remove_mean<-" + remove_mean + "\n"
                + "overlap_boxes<-" + overlap_boxes + "\n"
                + "### File containing list of stations created dynamically by the user ###\n"
                + "stat_file<-" + stat_file + "\n"
                + "### Spatial Plot Options ###\n"
                + "symbsizfac<-" + symbol_size_fac + "\n"
                + "plot_radius<-" + plot_radius + "\n"
                + "outlier_radius<-" + outlier_radius + "\n"
                + "fill_opacity<-" + fill_opacity + "\n"
                + "num_ints<-" + num_ints + "\n"
                + "perc_error_max<-" + perc_error_max + "\n"
                + "abs_error_max<-" + abs_error_max + "\n"
                + "rmse_range_max<-" + rmse_range_max + "\n"
                + "perc_range_min<-" + perc_range_min + "\n"
                + "perc_range_max<-" + perc_range_max + "\n"
                + "abs_range_min<-" + abs_range_min + "\n"
                + "abs_range_max<-" + abs_range_max + "\n"
                + "diff_range_min<-" + diff_range_min + "\n"
                + "diff_range_max<-" + diff_range_max + "\n"
                + "greyscale <-" + greyscale + "\n"
                + "inc_counties <-" + inc_counties + "\n"
                + "hist_max<-" + hist_max + "\n"
                + "map_type<-" + map_type + "\n"
                + "quantile_min<-" + quantile_min + "\n"
                + "quantile_max<-" + quantile_max + "\n"
                + "### Stacked Bar Charts Options ###\n"
                + "inc_FRM_adj<-" + inc_FRM_adj + "\n"
                + "use_median<-" + use_median + "\n"
                + "### Array of flags for which statistics to include on scatter plots ###\n"
                + "stats_flags<-" + stats_flags + "\n"
                + "### Flag to include run info text on plots ###\n"
                + "run_info_text<-" + run_info_text + "\n"
                + "### Set Scatter Plot Symbols and Colors ###\n"
                + "plot_colors<-" + plot_colors + "\n"
                + "plot_colors2<-" + plot_colors2 + "\n"
                + "plot_symbols<-" + plot_symbols + "\n"
                + "### Start and End Year/Month ###\n"
                + "year_start<-" + year_start + "\n"
                + "year_end<-" + year_end + "\n"
                + "month_start<-" + month_start + "\n"
                + "month_end<-" + month_end + "\n"
                + "day_start<-" + day_start + "\n"
                + "day_end<-" + day_end + "\n"
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
                + "start_date <- as.integer(paste(year_start,sprintf(\"%02d\",month_start),sprintf(\"%02d\",day_start),sep=\"\"))\n"
                + "end_date   <- as.integer(paste(year_end,sprintf(\"%02d\",month_end),sprintf(\"%02d\",day_end),sep=\"\"))\n"
                + "# Plot and figure output directory #\n"
                + "figdir     <- " + figdir + "\n"
                + "savedir    <- " + figdir + "\n"
                + "\n"
                + "#############################\n"
                + "### Setup Networks Arrays ###\n"
                + "#############################\n"
                + "network_names <- NULL\n"
                + "network_label <- NULL\n"
                + "if (inc_improve == \"y\") {\n"
                + "   network_names <- c(network_names,\"IMPROVE\")\n"
                + "   network_label <- c(network_label,\"IMPROVE\")\n"
                + "}\n"
                + "if (inc_csn == \"y\") {\n"
                + "   network_names <- c(network_names,\"CSN\")\n"
                + "   network_label <- c(network_label,\"CSN\")\n"
                + "}\n"
                + "if (inc_castnet == \"y\") {\n"
                + "   network_names <- c(network_names,\"CASTNET\")\n"
                + "   network_label <- c(network_label,\"CASTNET\")\n"
                + "}\n"
                + "if (inc_castnet_hr == \"y\") {\n"
                + "   network_names <- c(network_names,\"CASTNET_Hourly\")\n"
                + "   network_label <- c(network_label,\"CASTNET\")\n"
                + "}\n"
                + "if (inc_castnet_daily == \"y\") {\n"
                + "   network_names <- c(network_names,\"CASTNET_Daily\")\n"
                + "   network_label <- c(network_label,\"CASTNET\")\n"
                + "}\n"
                + "if (inc_castnet_drydep == \"y\") {\n"
                + "   network_names <- c(network_names,\"CASTNET_Drydep\")\n"
                + "   network_label <- c(network_label,\"CASTNET\")\n"
                + "}\n"
                + "if (inc_capmon == \"y\") {\n"
                + "   network_names <- c(network_names,\"CAPMON\")\n"
                + "   network_label <- c(network_label,\"CAPMON\")\n"
                + "}\n"
                + "if (inc_naps == \"y\") {\n"
                + "   network_names <- c(network_names,\"NAPS\")\n"
                + "   network_label <- c(network_label,\"NAPS\")\n"
                + "}\n"
                + "if (inc_naps_daily_o3 == \"y\") {\n"
                + "   network_names <- c(network_names,\"NAPS_Daily_O3\")\n"
                + "   network_label <- c(network_label,\"NAPS Daily\")\n"
                + "}\n"
                + "if (inc_nadp == \"y\") {\n"
                + "   network_names <- c(network_names,\"NADP\")\n"
                + "   network_label <- c(network_label,\"NADP\")\n"
                + "}\n"
                + "if (inc_airmon_dep == \"y\") {\n"
                + "   network_names <- c(network_names,\"AIRMON\")\n"
                + "   network_label <- c(network_label,\"AIRMON\")\n"
                + "}\n"
                + "if (inc_amon == \"y\") {\n"
                + "   network_names <- c(network_names,\"AMON\")\n"
                + "   network_label <- c(network_label,\"AMON\")\n"
                + "}\n"
                + "if (inc_aqs_hourly == \"y\") {\n"
                + "   network_names <- c(network_names,\"AQS_Hourly\")\n"
                + "   network_label <- c(network_label,\"AQS_Hourly\")\n"
                + "}\n"
                + "if (inc_aqs_daily_O3 == \"y\") {\n"
                + "   network_names <- c(network_names,\"AQS_Daily_O3\")\n"
                + "   network_label <- c(network_label,\"AQS_Daily\")\n"
                + "}\n"
                + "if (inc_aqs_daily == \"y\") {\n"
                + "   network_names <- c(network_names,\"AQS_Daily\")\n"
                + "   network_label <- c(network_label,\"AQS_Daily\")\n"
                + "}\n"
                + "if (inc_aqs_daily_pm == \"y\") {\n"
                + "   network_names <- c(network_names,\"AQS_Daily_PM\")\n"
                + "   network_label <- c(network_label,\"AQS_Daily\")\n"
                + "}\n"
                + "if (inc_search == \"y\") {\n"
                + "   network_names <- c(network_names,\"SEARCH\")\n"
                + "   network_label <- c(network_label,\"SEARCH\")\n"
                + "}\n"
                + "if (inc_search_daily == \"y\") {\n"
                + "   network_names <- c(network_names,\"SEARCH_Daily\")\n"
                + "   network_label <- c(network_label,\"SEARCH_Daily\")\n"
                + "}\n"
                + "if (inc_aeronet == \"y\") {\n"
                + "   network_names <- c(network_names,\"AERONET\")\n"
                + "   network_label <- c(network_label,\"AERONET\")\n"
                + "}\n"
                + "if (inc_fluxnet == \"y\") {\n"
                + "   network_names <- c(network_names,\"FLUXNET\")\n"
                + "   network_label <- c(network_label,\"FluxNet\")\n"
                + "}\n"
                + "if (inc_noaa_esrl_o3 == \"y\") {\n"
                + "   network_names <- c(network_names,\"NOAA_ESRL_O3\")\n"
                + "   network_label <- c(network_label,\"NOAA ESRL\")\n"
                + "}\n"
                + "if (inc_toar == \"y\") {\n"
                + "   network_names <- c(network_names,\"TOAR\")\n"
                + "   network_label <- c(network_label,\"TOAR\")\n"
                + "}\n"
                + "if (inc_mdn == \"y\") {\n"
                + "   network_names <- c(network_names,\"MDN\")\n"
                + "   network_label <- c(network_label,\"MDN\")\n"
                + "}\n"
                + "if (inc_tox == \"y\") {\n"
                + "   network_names <- c(network_names,\"Toxics\")\n"
                + "   network_label <- c(network_label,\"Toxics\")\n"
                + "}\n"
                + "if (inc_mod == \"y\") {\n"
                + "   network_names <- c(network_names,\"Model_Model\")\n"
                + "   network_label <- c(network_label,\"Mod v. Mod\")\n"
                + "}\n"
                + "if (inc_admn == \"y\") {\n"
                + "   network_names <- c(network_names,\"ADMN\")\n"
                + "   network_label <- c(network_label,\"ADMN\")\n"
                + "}\n"
                + "if (inc_aganet == \"y\") {\n"
                + "   network_names <- c(network_names,\"AGANET\")\n"
                + "   network_label <- c(network_label,\"AGANET\")\n"
                + "}\n"
                + "if (inc_airbase_hourly == \"y\") {\n"
                + "   network_names <- c(network_names,\"AirBase_Hourly\")\n"
                + "   network_label <- c(network_label,\"AirBase\")\n"
                + "}\n"
                + "if (inc_airbase_daily == \"y\") {\n"
                + "   network_names <- c(network_names,\"AirBase_Daily\")\n"
                + "   network_label <- c(network_label,\"AirBase\")\n"
                + "}\n"
                + "if (inc_aurn_hourly == \"y\") {\n"
                + "   network_names <- c(network_names,\"AURN_Hourly\")\n"
                + "   network_label <- c(network_label,\"AURN\")\n"
                + "}\n"
                + "if (inc_aurn_daily == \"y\") {\n"
                + "   network_names <- c(network_names,\"AURN_Daily\")\n"
                + "   network_label <- c(network_label,\"AURN\")\n"
                + "}\n"
                + "if (inc_emep_hourly == \"y\") {\n"
                + "   network_names <- c(network_names,\"EMEP_Hourly\")\n"
                + "   network_label <- c(network_label,\"EMEP\")\n"
                + "}\n"
                + "if (inc_emep_daily == \"y\") {\n"
                + "   network_names <- c(network_names,\"EMEP_Daily\")\n"
                + "   network_label <- c(network_label,\"EMEP\")\n"
                + "}\n"
                + "if (inc_calnex == \"y\") {\n"
                + "   network_names <- c(network_names,\"CALNEX\")\n"
                + "   network_label <- c(network_label,\"CALNEX\")\n"
                + "}\n"
                + "if (inc_soas == \"y\") {\n"
                + "   network_names <- c(network_names,\"SOAS\")\n"
                + "   network_label <- c(network_label,\"SOAS\")\n"
                + "}\n"
                + "if (inc_special == \"y\") {\n"
                + "   network_names <- c(network_names,\"Special\")\n"
                + "   network_label <- c(network_label,\"Special\")\n" 
                + "}\n"
                + "\n"
                + "\n"
                + "species <- unlist(strsplit(species_in,\",\"))\n"
 //               + "species <- gsub(\"_ob\",\"\",species)\n"
                + "total_networks<-length(network_names)\n"
                + "network1 <-network_names[[1]]\n"
                + "ametptype <-" + ametptype +"\n"
        );
        file.closeWriter();
    }
    
    //Dynamically executes the r scripts
    public void executeProgram() {
        setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
        
        //Command executed in the windows cmd prompt
            Process p = null;
            String os = System.getProperty("os.name").toLowerCase();
            //System.out.println(os);
            if (os.contains("win")) {
                try {
                    p = Runtime.getRuntime().exec("cmd /c"
                            + "set AMETBASE=" + config.amet_base + "&& "
                            + "set AMETRINPUT=" + config.cache_amet + "\\" + run_info + "&& "
                            + "set AMET_OUT=" + config.cache_amet + "&& "
                            + "set MYSQL_CONFIG=" + config.mysql_config + "&& "
                            + "set RSTUDIO_PANDOC=" + config.pandoc + "&& "
                            + config.rScript + " " + config.run_analysis + run_program + ">" + config.dir_name + username + "."  +  dir_name + "/R.SDOUT.txt"
                    );
                } catch (IOException e) {
                    errorWindow("IOExcpetion", "There was a problem in running R_analysis_code through the command prompt. This is usually a problem caused by incorect paths in the config file"); 
                }
            } else {
                try {
                    //System.out.println("linux");
                    p = Runtime.getRuntime().exec(new String[]{"csh","-c",""
                            + "setenv AMETBASE " + config.amet_base + "&& "
                            + "mkdir -p ./cache/guidir." + username + "."  + dir_name + "&&"
                            + "setenv AMETRINPUT " + config.cache_amet + "/" + "run_info_files" + "/" + run_info + "&& "
                            + "setenv AMET_OUT " + config.dir_name + username + "."  + dir_name + "&& "
                            + "setenv R_LIBS " + config.rLibs + "&& "
                            + "setenv MYSQL_CONFIG " + config.mysql_config + "&& "
                            + "setenv MYSQL_SERVER " + mysql_server + "&&"
                            + "setenv AMET_DATABASE " + dbase + "&& "
                            + "setenv AMETRSTATIC " + config.amet_static + amet_static + "&& "
                            + "setenv RSTUDIO_PANDOC " + config.pandoc + "&& "
                            + config.rScript + " " + config.run_analysis + run_program + ">" + config.dir_name + username + "."  +  dir_name + "/R.SDOUT.txt"
                    });
                } catch (IOException e) {
                    errorWindow("IOExcpetion", "There was a problem in running R_analysis_code through the command prompt. This is usually a problem caused by incorect paths in the config file"); 
                }
            }            

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
        String prefix =  config.dir_name + username + "."  + dir_namex + "/" + project_id + "_" + species + "_" + pidx + "_";
        String prefix2 = config.dir_name + username + "."  + dir_namex + "/" + project_id + "_" + pidx + "_";
        String prefix_diag = config.dir_name + username + "."  + dir_namex + "/";
        OutputWindowAQ output = new OutputWindowAQ(this);
        
        switch(run_program) {
        //Scatterplot 
            case "AQ_Scatterplot.R": //Multiple Networks Model/Ob Scatterplot (select stats only)
                output.newFile(prefix + "scatterplot.pdf", "Mod/Ob Scatterplot (PDF)");
                output.newFile(prefix + "scatterplot.png", "Mod/Ob Scatterplot (PNG)");
                output.newFile(prefix + "scatterplot.csv", "Scatterplot Data (CSV)");
                break;
            case "AQ_Scatterplot_ggplot.R": //GGPlot Scatterplot (multi network, single run)
                output.newFile(prefix + "scatterplot_ggplot.pdf", "Scatterplot (PDF)");
                output.newFile(prefix + "scatterplot_ggplot.png", "Scatterplot (PNG)");
                output.newFile(prefix + "scatterplot_ggplot.csv", "Scatterplot Data (CSV)");
                break;
            case "AQ_Scatterplot_plotly.R": //Interactive Multiple Network Scatterplot
                output.newFile(prefix + "scatterplot.html", "Mod/Ob Scatterplot (HTML)");
                output.newFile(prefix + "scatterplot.csv", "Scatterplot Data (CSV)");
                break;
            case "AQ_Scatterplot_multisim_plotly.R": //Interactive Multiple Simulation Scatterplot
                output.newFile(prefix + "scatterplot_multi.html", "Mod/Ob Scatterplot (HTML)");
                output.newFile(prefix + "scatterplot_multi.csv", "Scatterplot Data (CSV)");
                break;
            case "AQ_Scatterplot_single.R": //Single Network Model/Ob Scatterplot (includes all stats)
                output.newFile(prefix + "scatterplot_single.pdf", "Mod/Ob Scatterplot (PDF)");
                output.newFile(prefix + "scatterplot_single.png", "Mod/Ob Scatterplot (PNG)");
                output.newFile(prefix + "scatterplot_single.csv", "Scatterplot Data (CSV)");
                break;
            case "AQ_Scatterplot_density.R": //Density Scatterplot (single run, single network)
                output.newFile(prefix + "scatterplot_density.pdf", "Mod/Ob Scatterplot (PDF)");
                output.newFile(prefix + "scatterplot_density.png", "Mod/Ob Scatterplot (PNG)");
                output.newFile(prefix + "scatterplot_density.csv", "Scatterplot Data (CSV)");
                break;
            case "AQ_Scatterplot_density_ggplot.R": //GGPlot Density Scatterplot (single run, single network)
                output.newFile(prefix + "scatterplot_density_ggplot.pdf", "Mod/Ob Scatterplot (PDF)");
                output.newFile(prefix + "scatterplot_density_ggplot.png", "Mod/Ob Scatterplot (PNG)");
                output.newFile(prefix + "scatterplot_density_ggplot.csv", "Scatterplot Data (CSV)");
                break;
            case "AQ_Scatterplot_mtom.R": //Model/Model Scatterplot (multiple networks)
                output.newFile(prefix + "scatterplot_mtom.pdf", "Model/Model Scatterplot (PDF)");
                output.newFile(prefix + "scatterplot_mtom.png", "Model/Model Scatterplot (PNG)");
                break;
            case "AQ_Scatterplot_mtom_density.R": //Model/Model Density Scatterplot (single network)
                output.newFile(prefix + "scatterplot_mtom_density.pdf", "MtoM Density Scatterplot (PDF)");
                output.newFile(prefix + "scatterplot_mtom_density.png", "MtoM Density Scatterplot (PNG)");
                break;
            case "AQ_Scatterplot_percentiles.R": //Scatterplot of Percentiles (single network, single run)
                output.newFile(prefix + "scatterplot_percentiles.pdf", "Percentile Scatterplot (PDF)");
                output.newFile(prefix + "scatterplot_percentiles.png", "Percentile Scatterplot (PNG)");
                break;
            case "AQ_Scatterplot_skill.R": //Ozone Skill Scatterplot (single network, mult runs)
                output.newFile(prefix + "scatterplot_skill.pdf", "Skill Plot (PDF)");
                output.newFile(prefix + "scatterplot_skill.png", "Skill Plot (PNG)");
                output.newFile(prefix + "scatterplot_skill.csv", "Skill Plot Data (CSV)");
                break;
            case "AQ_Scatterplot_bins.R": //Binned MB &amp; RMSE Scatterplots (single net., mult. run)
                output.newFile(prefix + "scatterplot_bins.png", "Binned Mean Bias & RMSE Scatterplot (PNG)");
                output.newFile(prefix + "scatterplot_bins.pdf", "Binned Mean Bias & RMSE Scatterplot (PDF)");
                output.newFile(prefix + "scatterplot_bins.csv", "Raw Data File (CSV)");
                break;
            case "AQ_Scatterplot_bins_plotly.R": //Interactive Binned Plot (single net., mult. run)
                output.newFile(prefix + "scatterplot_bins.html", "Binned Scatterplot (HTML)");
                output.newFile(prefix + "scatterplot_bins.csv", "Raw Data File (CSV)");
                break;
            case "AQ_Scatterplot_multi.R": //Multi Simulation Scatter plot (single network, mult runs)
                output.newFile(prefix + "scatterplot.pdf", "Scatterplot (PDF)");
                output.newFile(prefix + "scatterplot.png", "Scatterplot (PNG)");
                output.newFile(prefix + "scatterplot.csv", "Scatterplot Data (CSV)");
                break;
            case "AQ_Scatterplot_soil.R": //Soil Scatter plot (single network, mult runs)
                output.newFile(prefix + "scatterplot_soil.pdf", "Model/Ob Soil Scatterplot (PDF)");
                output.newFile(prefix + "scatterplot_soil.png", "Model/Ob Soil Scatterplot (PNG)");
                break;
        //TimeSeries Plots
            case "AQ_Timeseries.R": //Time-Series Plot (single network, multiple sites averages)
                output.newFile(prefix + "timeseries.pdf", "Time Series Plot (PDF)");
                output.newFile(prefix + "timeseries.png", "Time Series Plot (PNG)");
                output.newFile(prefix + "timeseries.csv", "Timeseries Data (CSV)");
                break;
            case "AQ_Timeseries_dygraph.R": //Dygraph Time-series Plot
                output.newFile(prefix + "timeseries.html", "Time Series (HTML)");
                output.newFile(prefix + "timeseries_dygraph.csv", "Timeseries Data (CSV)");
                break;
            case "AQ_Timeseries_plotly.R": //Plotly Multi-simulation Timeseries
                output.newFile(prefix + "timeseries.html", "Time Series (HTML)");
                output.newFile(prefix + "timeseries.csv", "Timeseries Data (CSV)");
                break;
            case "AQ_Timeseries_networks_plotly.R": //Plotly Multi-network Timeseries
                output.newFile(prefix + "timeseries.html", "Time Series (HTML)");
                output.newFile(prefix + "timeseries.csv", "Timeseries Data (CSV)");
                break;
            case "AQ_Timeseries_multi_species_plotly.R": //Plotly Multi-species Timeseries
                output.newFile(prefix2 + "timeseries.pdf", "Timeseries Plot (PDF)");
                output.newFile(prefix2 + "timeseries.png", "Timeseries Plot (PNG)");
                output.newFile(prefix2 + "timeseries.csv", "Timeseries Data (CSV)");
                break;
            case "AQ_Timeseries_multi_networks.R": //Multi-Network Time-series Plot (mult. net., single run
                output.newFile(prefix + "timeseries.pdf", "Timeseries Plot (PDF)");
                output.newFile(prefix + "timeseries.png", "Timeseries Plot (PNG)");
                output.newFile(prefix + "timeseries.csv", "Timeseries Data (CSV)");
                break;
            case "AQ_Timeseries_multi_species.R": //Multi-Species Time-series Plot (mult. species, single run)
                output.newFile(prefix2 + "timeseries.pdf", "Timeseries Plot (PDF)");
                output.newFile(prefix2 + "timeseries.png", "Timeseries Plot (PNG)");
                output.newFile(prefix2 + "timeseries.csv", "Timeseries Data (CSV)");
                break;
            case "AQ_Timeseries_MtoM.R": //Model-to-Model Time-series Plot (single net., multi run)
                output.newFile(prefix + "timeseries_mtom.pdf", "Timeseries Plot (PDF)");
                output.newFile(prefix + "timeseries_mtom.png", "Timeseries Plot (PNG)");
                output.newFile(prefix + "timeseries_mtom.csv", "Timeseries Data (CSV)");
                break;
            case "AQ_Monthly_Stat_Plot.R": //Year-long Monthly Statistics Plot (single network)
                output.newFile(prefix + "plot1.pdf", "Obs/Mod Plot (PDF)");
                output.newFile(prefix + "plot1.png", "Obs/Mod Plot (PNG)");
                output.newFile(prefix + "stats.csv", "Monthly Stat File (CSV)");
                output.newFile(prefix + "stats_plot1.pdf", "NMB/NME/Corr Plot (PDF)");
                output.newFile(prefix + "stats_plot1.png", "NMB/NME/Corr Plot (PNG)");
                output.newFile(prefix + "stats_plot2.pdf", "MdnB/MdnE/RMSE Plot (PDF)");
                output.newFile(prefix + "stats_plot2.png", "MdnB/MdnE/RMSE Plot (PNG)");
                break;
        //Spatial Plots
            case "AQ_Stats_Plots.R": //Species Statistics and Spatial Plots (multi networks)
                output.newFile(prefix + "stats_plot_NMB.pdf", "NMB (PDF)");
                output.newFile(prefix + "stats_plot_NME.pdf", "NME (PDF)");
                output.newFile(prefix + "stats_plot_MB.pdf", "MB (PDF)");
                output.newFile(prefix + "stats_plot_ME.pdf", "ME (PDF)");
                output.newFile(prefix + "stats_plot_FB.pdf", "FB (PDF)");
                output.newFile(prefix + "stats_plot_FE.pdf", "FE (PDF)");
                output.newFile(prefix + "stats_plot_RMSE.pdf", "RMSE (PDF)");
                output.newFile(prefix + "stats_plot_Corr.pdf", "Corr (PDF)");
                output.newFile(prefix + "stats.csv", "CSV Domain Wide Statistics File");
                output.newFile(prefix + "sites_stats.csv", "CSV Site Specific Statistics File");
                output.newFile(prefix + "stats_data.csv", "Raw Query Data (CSV)");
                break;
            case "AQ_Stats_Plots_leaflet.R": //Interactive Species Statistics and Spatial Plots (multi networks)
                output.newFile(prefix + "stats.csv", "Domain Wide Statistics (CSV)");
                output.newFile(prefix + "sites_stats.csv", "Site Specific Statistics (CSV)");
                output.newFile(prefix + "stats_data.csv", "Raw Query Data (CSV)");
                output.newFile(prefix + "stats_plot_NMB.html", "NMB Plot (HTML)");
                output.newFile(prefix + "stats_plot_NME.html", "NME Plot (HTML)");
                output.newFile(prefix + "stats_plot_MB.html", "MB Plot (HTML)");
                output.newFile(prefix + "stats_plot_ME.html", "ME Plot (HTML)");
                output.newFile(prefix + "stats_plot_FB.html", "FB Plot (HTML)");
                output.newFile(prefix + "stats_plot_FE.html", "FE Plot (HTML)");
                output.newFile(prefix + "stats_plot_RMSE.html", "RMSE Plot (HTML)");
                output.newFile(prefix + "stats_plot_Corr.html", "Corr Plot (HTML)");
                break;
            case "AQ_Plot_Spatial.R": //Spatial Plot (multi networks)
                output.newFile(prefix + "spatialplot_obs.png", "Obs (PNG)");
                output.newFile(prefix + "spatialplot_mod.png", "Model (PNG)");
                output.newFile(prefix + "spatialplot_diff.png", "Difference (PNG)");
                output.newFile(prefix + "spatialplot_ratio.png", "Ratio (PNG)");
                output.newFile(prefix + "spatialplot_obs.pdf", "Obs (PDF)");
                output.newFile(prefix + "spatialplot_mod.pdf", "Model (PDF)");
                output.newFile(prefix + "spatialplot_diff.pdf", "Difference (PDF)");
                output.newFile(prefix + "spatialplot_ratio.pdf", "Ratio (PDF)");
                break;
            case "AQ_Plot_Spatial_leaflet.R": //Interactive Spatial Plot (multi networks)
                output.newFile(prefix + "spatialplot_obs.html", "Obs (html)");
                output.newFile(prefix + "spatialplot_mod.html", "Mod (html)");
                output.newFile(prefix + "spatialplot_diff.html", "Diff (html)");
                break;
            case "AQ_Plot_Spatial_MtoM.R": //Model/Model Diff Spatial Plot (multi network, multi run)
                output.newFile(prefix + "spatialplot_mtom_diff_avg.png", "MtoM Diff Avg Plot (PNG)");
                output.newFile(prefix + "spatialplot_mtom_diff_max.png", "MtoM Diff Max Plot (PNG)");
                output.newFile(prefix + "spatialplot_mtom_diff_min.png", "MtoM Diff Min Plot (PNG)");
                output.newFile(prefix + "spatialplot_mtom_diff_avg.pdf", "MtoM Diff Avg Plot (PDF)");
                output.newFile(prefix + "spatialplot_mtom_diff_max.pdf", "MtoM Diff Max Plot (PDF)");
                output.newFile(prefix + "spatialplot_mtom_diff_min.pdf", "MtoM Diff Min Plot (PDF)");
                break;
            case "AQ_Plot_Spatial_MtoM_leaflet.R": //Interactive Model/Model Diff Spatial Plot (multi network, multi run)
                output.newFile(prefix + "spatialplot_mtom_diff_avg.html", "MtoM Avg Plot");
                output.newFile(prefix + "spatialplot_mtom_diff_max.html", "MtoM Max Plot");
                output.newFile(prefix + "spatialplot_mtom_diff_min.html", "MtoM Min Plot");
                break;
            case "AQ_Plot_Spatial_MtoM_Species.R": //Model/Model Species Diff Spatial Plot (multi network, multi run)
                output.newFile(prefix2 + "spatialplot_mtom_species_diff_avg.png", "Avg Diff (PNG)");
                output.newFile(prefix2 + "spatialplot_mtom_species_diff_max.png", "Max Diff (PNG)");
                output.newFile(prefix2 + "spatialplot_mtom_species_diff_min.png", "Min Diff (PNG)");
                output.newFile(prefix2 + "spatialplot_mtom_species_diff_perc.png", "Percent Diff (PNG)");
                output.newFile(prefix2 + "spatialplot_mtom_species_diff_avg.pdf", "Avg Diff (PDF)");
                output.newFile(prefix2 + "spatialplot_mtom_species_diff_max.pdf", "Max Diff (PDF)");
                output.newFile(prefix2 + "spatialplot_mtom_species_diff_min.pdf", "Min Diff (PDF)");
                output.newFile(prefix2 + "spatialplot_mtom_species_diff_perc.pdf", "Percent Diff (PDF)");
                break;
            case "AQ_Plot_Spatial_Diff.R": //Spatial Plot of Bias/Error Difference (multi network, multi run)
                output.newFile(prefix + "spatialplot_diff.csv", "Plot Data File (CSV)");
                output.newFile(prefix + "spatialplot_bias_1.png", "Run 1 Bias Plot (PNG)");
                output.newFile(prefix + "spatialplot_bias_2.png", "Run 2 Bias Plot (PNG)");
                output.newFile(prefix + "spatialplot_bias_diff.png", "Bias Difference Plot (PNG)");
                output.newFile(prefix + "spatialplot_error_1.png", "Run 1 Error Plot (PNG)");
                output.newFile(prefix + "spatialplot_error_2.png", "Run 2 Error Plot (PNG)");
                output.newFile(prefix + "spatialplot_error_diff.png", "Error Difference Plot (PNG)");
                output.newFile(prefix + "spatialplot_bias_diff_hist.png", "Bias Diff Hist Plot (PNG)");
                output.newFile(prefix + "spatialplot_error_diff_hist.png", "Error Diff Hist Plot (PNG)");
                break;
            case "AQ_Plot_Spatial_Diff_leaflet.R": //Interactive Spatial Plot of Bias/Error Difference (multi networks)
                output.newFile(prefix + "spatialplot_bias_1.html", "Bias1");
                output.newFile(prefix + "spatialplot_bias_2.html", "Bias2");
                output.newFile(prefix + "spatialplot_bias_diff.html", "Bias Diff");
                output.newFile(prefix + "spatialplot_error_1.html", "Error1");
                output.newFile(prefix + "spatialplot_error_2.html", "Error2");
                output.newFile(prefix + "spatialplot_error_diff.html", "Error Diff");
                break;
            case "AQ_Plot_Spatial_Ratio.R": //Ratio Spatial Plot to total PM2.5 (multi network, multi run)
                output.newFile(prefix + "spatialplot_ratio_obs.png", "Obs Spatial Plot (PNG)");
                output.newFile(prefix + "spatialplot_ratio_mod.png", "Model Spatial Plot (PNG)");
                output.newFile(prefix + "spatialplot_ratio_diff.png", "Difference Plot (PNG)");
                output.newFile(prefix + "spatialplot_ratio_obs.pdf", "Obs Spatial Plot (PDF)");
                output.newFile(prefix + "spatialplot_ratio_mod.pdf", "Model Spatial Plot (PDF)");
                output.newFile(prefix + "spatialplot_ratio_diff.pdf", "Difference Plot (PDF)");
                break;
        //Box Plots
            case "AQ_Boxplot.R": //Boxplot (single network, multi run)
                output.newFile(prefix + "boxplot_all.png", "Boxplot (PNG)");
                output.newFile(prefix + "boxplot_all.pdf", "Boxplot (PDF)");
                output.newFile(prefix + "boxplot_bias.png", "Bias Boxplot (PNG)");
                output.newFile(prefix + "boxplot_bias.pdf", "Bias Boxplot (PDF)");
                output.newFile(prefix + "boxplot_norm_bias.png", "Normalized Bias Boxplot (PNG)");
                output.newFile(prefix + "boxplot_norm_bias.pdf", "Normalized Bias Boxplot (PDF)");
                break;
            case "AQ_Boxplot_ggplot.R": //GGPlot Boxplot (single network, multi run)
                output.newFile(prefix + "boxplot_ggplot.png", "Boxplot (PNG)");
                output.newFile(prefix + "boxplot_ggplot.pdf", "Boxplot (PDF)");
                output.newFile(prefix + "boxplot_bias_ggplot.png", "Bias Boxplot (PNG)");
                output.newFile(prefix + "boxplot_bias_ggplot.pdf", "Bias Boxplot (PDF)");
                break;
            case "AQ_Boxplot_plotly.R": //Plotly Boxplot (single network, multi run)
                output.newFile(prefix + "boxplot.html", "Boxplot (HTML)");
                output.newFile(prefix + "boxplot_bias.html", "Bias Boxplot (HTML)");
                output.newFile(prefix + "boxplot_nmb.html", "NMB Boxplot (HTML)");
                output.newFile(prefix + "boxplot.csv", "Data (CSV)");
                break;
            case "AQ_Boxplot_DofW.R": //Day of Week Boxplot (single network, multiple runs)
                output.newFile(prefix + "boxplot_dow.pdf", "Day of Week Boxplot (PDF)");
                output.newFile(prefix + "boxplot_dow.png", "Day of Week Boxplot (PNG)");
                break;
            case "AQ_Boxplot_Hourly.R": //Hourly Boxplot (single network, multiple runs)
                output.newFile(prefix + "boxplot_hourly.pdf", "Boxplot (PDF)");
                output.newFile(prefix + "boxplot_hourly.png", "Boxplot (PNG)");
                output.newFile(prefix + "boxplot_hourly_data.csv", "Median Data (CSV)");
                break;
            case "AQ_Boxplot_MDA8.R": //8hr Average Boxplot (single network, hourly data, can be slow)
                output.newFile(prefix + "boxplot_MDA8.pdf", "MDA8 Boxplot (PDF)");
                output.newFile(prefix + "boxplot_MDA8.png", "MDA8 Boxplot (PNG)");
                break;
            
            case "AQ_Boxplot_Roselle.R": //Roselle Boxplot (single network, multiple simulations)
                output.newFile(prefix + "boxplot_roselle.png", "Roselle Boxplot (PNG)");
                output.newFile(prefix + "boxplot_roselle_bias.png", "Roselle Boxplot Bias (PNG)");
                output.newFile(prefix + "boxplot_roselle.pdf", "Roselle Boxplot (PDF)");
                output.newFile(prefix + "boxplot_roselle_bias.pdf", "Roselle Boxplot Bias (PDF)");
                break;
        // Stacked Bar Plots
            case "AQ_Stacked_Barplot.R": //PM2.5 Stacked Bar Plot (CSN or IMPROVE, multi run)
                output.newFile(prefix2 + "stacked_barplot.png", "Stacked Barplot (PNG)");
                output.newFile(prefix2 + "stacked_barplot.pdf", "Stacked Barplot (PDF)");
                output.newFile(prefix2 + "stacked_barplot.csv", "Barplot Data (CSV)");
                break;
            case "AQ_Stacked_Barplot_AE6.R": //PM2.5 Stacked Bar Plot AE6 (CSN or IMPROVE, multi run)
                output.newFile(prefix2 + "stacked_barplot_AE6.png", "Stacked Barplot (PNG)");
                output.newFile(prefix2 + "stacked_barplot_AE6.pdf", "Stacked Barplot (PDF)");
                output.newFile(prefix2 + "stacked_barplot_AE6_data.csv", "Barplot Data (CSV)");
                break;
            case "AQ_Stacked_Barplot_AE6_plotly.R": //Interactive Stacked Bar Plot
                output.newFile(prefix2 + "stacked_barplot_AE6.html", "Stacked Barplot (HTML)");
            //    output.newFile(prefix2 + "stacked_barplot_AE6_data.csv", "Barplot Data (CSV)");
                break;
            case "AQ_Stacked_Barplot_AE6_ggplot.R": //GGPlot Stacked Bar Plot
                output.newFile(prefix2 + "stacked_barplot_AE6_ggplot.png", "Stacked Barplot (PNG)");
                output.newFile(prefix2 + "stacked_barplot_AE6_ggplot.pdf", "Stacked Barplot (PDF)");
            //    output.newFile(prefix2 + "stacked_barplot_AE6_data_ggplot.csv", "Barplot Data (CSV)");
                break;
            case "AQ_Stacked_Barplot_AE6_ts.R": //Stacked Bar Plot Time Series
                output.newFile(prefix2 + "stacked_barplot_AE6_ts.pdf", "Stacked Barplot (PDF)");
                output.newFile(prefix2 + "stacked_barplot_AE6_ts.png", "Stacked Barplot (PNG)");
                output.newFile(prefix2 + "stacked_barplot_AE6_ts.html", "Stacked Barplot (HTML)");
            //    output.newFile(prefix2 + "stacked_barplot_AE6_data_ts.csv", "Barplot Data (CSV)");
                break;
            case "AQ_Stacked_Barplot_soil.R": //Soil Stacked Bar Plot (CSN or IMPROVE, multi run)
                output.newFile(prefix2 + "stacked_barplot_soil.png", "Stacked Barplot (PNG)");
                output.newFile(prefix2 + "stacked_barplot_soil.pdf", "Stacked Barplot (PDF)");
                output.newFile(prefix2 + "stacked_barplot_data_soil.csv", "Barplot Data (CSV)");
                break; 
            case "AQ_Stacked_Barplot_soil_multi.R": //Soil Stacked Bar Plot Multi (CSN and IMPROVE, single run)
                output.newFile(prefix2 + "stacked_barplot_soil.png", "Stacked Barplot (PNG)");
                output.newFile(prefix2 + "stacked_barplot_soil.pdf", "Stacked Barplot (PDF)");
                output.newFile(prefix2 + "stacked_barplot_data_soil.csv", "Barplot Data (CSV)");
                break;
            case "AQ_Stacked_Barplot_panel.R": //Multi-Panel Stacked Bar Plot (full year data required)
                output.newFile(prefix2 + "stacked_barplot_panel.png", "Stacked Barplot (PNG)");
                output.newFile(prefix2 + "stacked_barplot_panel.pdf", "Stacked Barplot (PDF)");
                output.newFile(prefix2 + "stacked_barplot_panel_data.csv", "Barplot Data (CSV)");
                break;
            case "AQ_Stacked_Barplot_panel_AE6.R": //Multi-Panel Stacked Bar Plot AE6 (full year data)
                output.newFile(prefix2 + "stacked_barplot_panel_AE6.png", "Stacked Barplot (PNG)");
                output.newFile(prefix2 + "stacked_barplot_panel_AE6.pdf", "Stacked Barplot (PDF)");
                output.newFile(prefix2 + "stacked_barplot_panel_AE6.csv", "Barplot Data (CSV)");
                break;
            case "AQ_Stacked_Barplot_panel_AE6_multi.R": //Multi-Panel, Mulit Run Stacked Bar Plot AE6 (full year data)
                output.newFile(prefix2 + "stacked_barplot_panel_AE6_multi.png", "Stacked Barplot (PNG)");
                output.newFile(prefix2 + "stacked_barplot_panel_AE6_multi.pdf", "Stacked Barplot (PDF)");
                output.newFile(prefix2 + "stacked_barplot_panel_AE6_multi_data.csv", "Barplot Data (CSV)");
                break;
        //MISC Scripts
            case "AQ_Kellyplot.R": //Kelly Plot (single species, single network, full year data)
                output.newFile(prefix + "Kellyplot_NMB.png", "NMB (PNG)");
                output.newFile(prefix + "Kellyplot_NME.png", "NME (PNG)");
                output.newFile(prefix + "Kellyplot_MB.png", "MB (PNG)");
                output.newFile(prefix + "Kellyplot_ME.png", "ME (PNG)");
                output.newFile(prefix + "Kellyplot_RMSE.png", "RMSE (PNG)");
                output.newFile(prefix + "Kellyplot_Corr.png", "Corr (PNG)");
                output.newFile(prefix + "Kellyplot_NMB.pdf", "NMB (PDF)");
                output.newFile(prefix + "Kellyplot_NME.pdf", "NME (PDF)");
                output.newFile(prefix + "Kellyplot_MB.pdf", "MB (PDF)");
                output.newFile(prefix + "Kellyplot_ME.pdf", "ME (PDF)");
                output.newFile(prefix + "Kellyplot_RMSE.pdf", "RMSE (PDF)");
                output.newFile(prefix + "Kellyplot_Corr.pdf", "Corr (PDF)"); 
                break;
            case "AQ_Kellyplot_region.R": //Climate Region Kelly Plot (single species, single network, multi sim)
                output.newFile(prefix + "Kellyplot_region_NMB.png", "NMB (PNG)");
                output.newFile(prefix + "Kellyplot_region_NME.png", "NME (PNG)");
                output.newFile(prefix + "Kellyplot_region_MB.png", "MB (PNG)");
                output.newFile(prefix + "Kellyplot_region_ME.png", "ME (PNG)");
                output.newFile(prefix + "Kellyplot_region_RMSE.png", "RMSE (PNG)");
                output.newFile(prefix + "Kellyplot_region_Corr.png", "Corr (PNG)");
                output.newFile(prefix + "Kellyplot_region_NMB.pdf", "NMB (PDF)");
                output.newFile(prefix + "Kellyplot_region_NME.pdf", "NME (PDF)");
                output.newFile(prefix + "Kellyplot_region_MB.pdf", "MB (PDF)");
                output.newFile(prefix + "Kellyplot_region_ME.pdf", "ME (PDF)");
                output.newFile(prefix + "Kellyplot_region_RMSE.pdf", "RMSE (PDF)");
                output.newFile(prefix + "Kellyplot_region_Corr.pdf", "Corr (PDF)"); 
                output.newFile(prefix + "Kellyplot_stats_data_region.csv", "Stats (CSV)"); 
                break;
            case "AQ_Kellyplot_season.R": //Seasonal Kelly Plot (single species, single network, multi sim)
                output.newFile(prefix + "Kellyplot_season_NMB.png", "NMB (PNG)");
                output.newFile(prefix + "Kellyplot_season_NME.png", "NME (PNG)");
                output.newFile(prefix + "Kellyplot_season_MB.png", "MB (PNG)");
                output.newFile(prefix + "Kellyplot_season_ME.png", "ME (PNG)");
                output.newFile(prefix + "Kellyplot_season_RMSE.png", "RMSE (PNG)");
                output.newFile(prefix + "Kellyplot_season_Corr.png", "Corr (PNG)");
                output.newFile(prefix + "Kellyplot_season_NMB.pdf", "NMB (PDF)");
                output.newFile(prefix + "Kellyplot_season_NME.pdf", "NME (PDF)");
                output.newFile(prefix + "Kellyplot_season_MB.pdf", "MB (PDF)");
                output.newFile(prefix + "Kellyplot_season_ME.pdf", "ME (PDF)");
                output.newFile(prefix + "Kellyplot_season_RMSE.pdf", "RMSE (PDF)");
                output.newFile(prefix + "Kellyplot_season_Corr.pdf", "Corr (PDF)"); 
                output.newFile(prefix + "Kellyplot_stats_data_season.csv", "Stats (CSV)"); 
                break;
            case "AQ_Kellyplot_multisim.R": //Multisim Kelly Plot (single species, single network, multi sim)
                output.newFile(prefix + "Kellyplot_multi_NMB.png", "NMB (PNG)");
                output.newFile(prefix + "Kellyplot_multi_NME.png", "NME (PNG)");
                output.newFile(prefix + "Kellyplot_multi_MB.png", "MB (PNG)");
                output.newFile(prefix + "Kellyplot_multi_ME.png", "ME (PNG)");
                output.newFile(prefix + "Kellyplot_multi_RMSE.png", "RMSE (PNG)");
                output.newFile(prefix + "Kellyplot_multi_Corr.png", "Corr (PNG)");
                output.newFile(prefix + "Kellyplot_multi_NMB.pdf", "NMB (PDF)");
                output.newFile(prefix + "Kellyplot_multi_NME.pdf", "NME (PDF)");
                output.newFile(prefix + "Kellyplot_multi_MB.pdf", "MB (PDF)");
                output.newFile(prefix + "Kellyplot_multi_ME.pdf", "ME (PDF)");
                output.newFile(prefix + "Kellyplot_multi_RMSE.pdf", "RMSE (PDF)");
                output.newFile(prefix + "Kellyplot_multi_Corr.pdf", "Corr (PDF)"); 
                break;
            case "AQ_Stats.R": //Species Statistics (multi species, single network)
                output.newFile(prefix2 + "sites_stats.csv", "Site Statistical Data (CSV)");
                output.newFile(prefix2 + "stats_data.csv", "Raw Network Data (CSV)");
                output.newFile(prefix2 + "stats.csv", "Species Statistical Data (CSV)");
                break;
            case "AQ_Raw_Data.R": //Create raw data csv file (single network, single simulation)
                output.newFile(prefix2 + "rawdata.csv", "Raw Network Data (CSV)");
                break;
            case "AQ_Soccerplot.R": //Soccergoal plot (multiple networks)
                output.newFile(prefix2 + "soccerplot.png", "Soccergoal Plot (PNG)");
                output.newFile(prefix2 + "soccerplot.pdf", "Soccergoal Plot (PDF)");
                break; 
            case "AQ_Bugleplot.R": //"Bugle" plot (multiple networks)
                output.newFile(prefix + "bugle_plot_bias.png", "Bugle Plot Bias (PNG)");
                output.newFile(prefix + "bugle_plot_bias.pdf", "Bugle Plot Bias (PDF)");
                output.newFile(prefix + "bugle_plot_error.png", "Bugle Plot Error (PNG)");
                output.newFile(prefix + "bugle_plot_error.pdf", "Bugle Plot Error (PDF)");
                break;
            case "AQ_Histogram.R": //Histogram (single network/species only)
                output.newFile(prefix + "histogram.pdf", "Histogram (PDF)");
                output.newFile(prefix + "histogram.png", "Histogram (PNG)");
                output.newFile(prefix + "histogram_bias.pdf", "Bias (PDF)");
                output.newFile(prefix + "histogram_bias.png", "Bias (PNG)");
                break;
            case "AQ_Temporal_Plots.R": //CDF, Q-Q, Taylor Plots (single network, multi run)
                output.newFile(prefix + "ecdf.pdf", "ECDF (PDF)");
                output.newFile(prefix + "ecdf.png", "ECDF (PNG)");
                output.newFile(prefix + "qq.pdf", "QQ (PDF)");  
                output.newFile(prefix + "qq.png", "QQ (PNG)");  
                output.newFile(prefix + "taylor.pdf", "Taylor (PDF)");
                output.newFile(prefix + "taylor.png", "Taylor (PNG)");
                break;
        //Expiramental Scripts
            case "AQ_Overlay_File.R": //Create PAVE/VERDI Obs Overlay File (hourly/daily data only)
                output.newFile(prefix2 + "overlay.ncf", "PAVE Obs Overlay File (IOAPI file)");
                break;
            case "AQ_Spectral_Analysis.R": //Spectral Analysis (single network, single run, experimental)
                output.newFile(prefix + "spectrum.png", "Average Spectrum Plot (PNG)");
                output.newFile(prefix + "spectrum.pdf", "Average Spectrum Plot(PDF)");
                output.newFile(prefix + "spectrum_all.pdf", "Site Specific Spectrum Plot(PDF)");
                break;
            case "AQ_kml.R":
                output.newFile(prefix_diag + "R.SDOUT.txt", "Diagnostic File (txt)");
                output.newFile(prefix_diag + "AMET.SITEFILE." + project_id  + ".kml", "Google Earth Site Map (KML)");
                //output.newFile(prefix_diag + "AMET.GOOGLEEARTH." + project_id + "." + year_start + month_start + day_start + "-" + year_end + month_end + day_end  + ".kml", "Google Earth Site Map (KML)");
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
    //Returns <""> for R if empty, e;se returns value
    public String checkBoxFormat(javax.swing.JCheckBox checkBox) {
        if (checkBox.isSelected()) {
            isNetworkSelectedTemp = true;
            return "\"y\""; //read as return ""y""
        } else {
            return "\"\"";
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
    
    //assigning program names values to run_program combo box fields
    private void programFormat() {
        String str = ProgramComboBox.getSelectedItem().toString();
        switch(str) {
            //Scatter Plots
            case "Multiple Networks Model/Ob Scatterplot (select stats only)":
                run_program = "AQ_Scatterplot.R";
                break;
            case "GGPlot Scatterplot (multi network, single run)":
                run_program = "AQ_Scatterplot_ggplot.R";
                break;
            case "Interactive Multiple Network Scatterplot":
                run_program = "AQ_Scatterplot_plotly.R";
                break;
            case "Interactive Multiple Simulation Scatterplot":
                run_program = "AQ_Scatterplot_multisim_plotly.R";
                break;
            case "Single Network Model/Ob Scatterplot (includes all stats)":
                run_program = "AQ_Scatterplot_single.R";
                break;
            case "Density Scatterplot (single run, single network)":
                run_program = "AQ_Scatterplot_density.R";
                break;
            case "GGPlot Density Scatterplot (single run, single network)":
                run_program = "AQ_Scatterplot_density_ggplot.R";
                break;
            case "Model/Model Scatterplot (multiple networks)":
                run_program = "AQ_Scatterplot_mtom.R";
                break;
            case "Model/Model Density Scatterplot (single network)":
                run_program = "AQ_Scatterplot_mtom_density.R";
                break;
            case "Scatterplot of Percentiles (single network, single run)":
                run_program = "AQ_Scatterplot_percentiles.R";
                break;
            case "Ozone Skill Scatterplot (single network, mult runs)":
                run_program = "AQ_Scatterplot_skill.R";
                break;
            case "Binned MB & RMSE Scatterplots (single net., mult. run)":
                run_program = "AQ_Scatterplot_bins.R";
                break;
            case "Interactive Binned Scatterplot (single net., mult. run)":
                run_program = "AQ_Scatterplot_bins_plotly.R";
                break;
            case "Multi Simulation Scatterplot (single network, mult runs)":
                run_program = "AQ_Scatterplot_multi.R";
                break;
            case "Soil Scatterplot (single network)":
                run_program = "AQ_Scatterplot_soil.R";
                break;
            //Time-series plots
            case "Time-Series Plot (single network, multiple sites averages)":
                run_program = "AQ_Timeseries.R";
                break;
            case "Dygraph Time-series Plot":
                run_program = "AQ_Timeseries_dygraph.R";
                break;
            case "Plotly Multi-simulation Timeseries":
                run_program = "AQ_Timeseries_plotly.R";
                break;
            case "Plotly Multi-network Timeseries":
                run_program = "AQ_Timeseries_networks_plotly.R";
                break;
            case "Plotly Multi-species Timeseries":
                run_program = "AQ_Timeseries_multi_species_plotly.R";
                break;
            case "Multi-Network Time-series Plot (mult. net., single run)":
                run_program = "AQ_Timeseries_multi_networks.R";
                break;
            case "Multi-Species Time-series Plot (mult. species, single run)":
                run_program = "AQ_Timeseries_multi_species.R";
                break;
            case "Model-to-Model Time-series Plot (single net., multi run)":
                run_program = "AQ_Timeseries_MtoM.R";
                break;
            case "Year-long Monthly Statistics Plot (single network)":
                run_program = "AQ_Monthly_Stat_Plot.R";
                break;
            //Spatial Plots
            case "Species Statistics and Spatial Plots (multi networks)":
                run_program = "AQ_Stats_Plots.R";
                break;
            case "Interactive Species Statistics and Spatial Plots (multi networks)":
                run_program = "AQ_Stats_Plots_leaflet.R";
                break;
            case "Spatial Plot (multi networks)":
                run_program = "AQ_Plot_Spatial.R";
                break;
            case "Interactive Spatial Plot (multi networks)":
                run_program = "AQ_Plot_Spatial_leaflet.R";
                break;
            case "Model/Model Diff Spatial Plot (multi network, multi run)":
                run_program = "AQ_Plot_Spatial_MtoM.R";
                break;
            case "Interactive Model/Model Diff Spatial Plot (multi network, multi run)":
                run_program = "AQ_Plot_Spatial_MtoM_leaflet.R";
                break;
            case "Model/Model Species Diff Spatial Plot (multi network, multi run)":
                run_program = "AQ_Plot_Spatial_MtoM_Species.R";
                break;
            case "Spatial Plot of Bias/Error Difference (multi network, multi run)":
                run_program = "AQ_Plot_Spatial_Diff.R";
                break;
            case "Interactive Spatial Plot of Bias/Error Difference (multi networks)":
                run_program = "AQ_Plot_Spatial_Diff_leaflet.R";
                break;
            case "Ratio Spatial Plot to total PM2.5 (multi network, multi run)":
                run_program = "AQ_Plot_Spatial_Ratio.R";
                break;
            //Boxplot
            case "Boxplot (single network, multi run)":
                run_program = "AQ_Boxplot.R";
                break;
            case "GGPlot Boxplot (single network, multi run)":
                run_program = "AQ_Boxplot_ggplot.R";
                break;
            case "Plotly Boxplot (single network, multi run)":
                run_program = "AQ_Boxplot_plotly.R";
                break;
            case "Day of Week Boxplot (single network, multiple runs)":
                run_program = "AQ_Boxplot_DofW.R";
                break;
            case "Hourly Boxplot (single network, multiple runs)":
                run_program = "AQ_Boxplot_Hourly.R";
                break;
            case "8hr Average Boxplot (single network, hourly data, can be slow)":
                run_program = "AQ_Boxplot_MDA8.R";
                break;
            case "Roselle Boxplot (single network, multiple simulations)":
                run_program = "AQ_Boxplot_Roselle.R";
                break;
            //Stacked Bar Plots
            case "PM2.5 Stacked Bar Plot (CSN or IMPROVE, multi run)":
                run_program = "AQ_Stacked_Barplot.R";
                break;
            case "PM2.5 Stacked Bar Plot AE6 (CSN or IMPROVE, multi run)":
                run_program = "AQ_Stacked_Barplot_AE6.R";
                break;
            case "Interactive Stacked Bar Plot":
                run_program = "AQ_Stacked_Barplot_AE6_plotly.R";
                break;
            case "GGPlot Stacked Bar Plot":
                run_program = "AQ_Stacked_Barplot_AE6_ggplot.R";
                break;
            case "Stacked Bar Plot Time Series":
                run_program = "AQ_Stacked_Barplot_AE6_ts.R";
                break;
            case "Soil Stacked Bar Plot (CSN or IMPROVE, multi run)":
                run_program = "AQ_Stacked_Barplot_soil.R";
                break;
            case "Soil Stacked Bar Plot Multi (CSN and IMPROVE, single run)":
                run_program = "AQ_Stacked_Barplot_soil_multi.R";
                break;
            case "Multi-Panel Stacked Bar Plot (full year data required)":
                run_program = "AQ_Stacked_Barplot_panel.R";
                break;
            case "Multi-Panel Stacked Bar Plot AE6 (full year data)":
                run_program = "AQ_Stacked_Barplot_panel_AE6.R";
                break;
            case "Multi-Panel, Mulit Run Stacked Bar Plot AE6 (full year data)":
                run_program = "AQ_Stacked_Barplot_panel_AE6_multi.R";
                break;
            //Misc Plots
            case "Kelly Plot (single species, single network, full year data)":
                run_program = "AQ_Kellyplot.R";
                break;
            case "Climate Region Kelly Plot (single species, single network, multi sim)":
                run_program = "AQ_Kellyplot_region.R";
                break;
            case "Seasonal Kelly Plot (single species, single network, multi sim)":
                run_program = "AQ_Kellyplot_season.R";
                break;
            case "Multisim Kelly Plot (single species, single network, multi sim)":
                run_program = "AQ_Kellyplot_multisim.R";
                break;
            case "Species Statistics (multi species, single network)":
                run_program = "AQ_Stats.R";
                break;
            case "Create raw data csv file (single network, single simulation)":
                run_program = "AQ_Raw_Data.R";
                break;
            case "\"Soccergoal\" plot (multiple networks)":
                run_program = "AQ_Soccerplot.R";
                break;
            case "\"Bugle\" plot (multiple networks)":
                run_program = "AQ_Bugleplot.R";
                break;
            case "Histogram (single network/species only)":
                run_program = "AQ_Histogram.R";
                break;
            case "CDF, Q-Q, Taylor Plots (single network, multi run)":
                run_program = "AQ_Temporal_Plots.R";
                break;
            //Expiramental
            case "Create PAVE/VERDI Obs Overlay File (hourly/daily data only)":
                run_program = "AQ_Overlay_File.R";
                break;
            case "Spectral Analysis (single network, single run, experimental)":
                run_program = "AQ_Spectral_Analysis.R";
                break;
            default:
                
        }
    }
    
    //assigning values to hour feilds
    private String hourFormat(String str) {
        String hour = "";
        switch(str) {
            case "\"12AM\"":
                hour = "00";
                break;
            case "\"1AM\"":
                hour = "01";
                break;
            case "\"2AM\"":
                hour = "02";
                break;
            case "\"3AM\"":
                hour = "03";
                break;
            case "\"4AM\"":
                hour = "04";
                break;
            case "\"5AM\"":
                hour = "05";
                break;
            case "\"6AM\"":
                hour = "06";
                break;
            case "\"7AM\"":
                hour = "07";
                break;
            case "\"8AM\"":
                hour = "08";
                break;
            case "\"9AM\"":
                hour = "09";
                break;
            case "\"10AM\"":
                hour = "10";
                break;
            case "\"11AM\"":
                hour = "11";
                break;
            case "\"12PM\"":
                hour = "12";
                break;
            case "\"1PM\"":
                hour = "13";
                break;
            case "\"2PM\"":
                hour = "14";
                break;
            case "\"3PM\"":
                hour = "15";
                break;
            case "\"4PM\"":
                hour = "16";
                break;
            case "\"5PM\"":
                hour = "17";
                break;
            case "\"6PM\"":
                hour = "18";
                break;
            case "\"7PM\"":
                hour = "19";
                break;
            case "\"8PM\"":
                hour = "20";
                break;
            case "\"9PM\"":
                hour = "21";
                break;
            case "\"10PM\"":
                hour = "22";
                break;
            case "\"11PM\"":
                hour = "23";
                break;
            default:
                break;
        }
        return hour;
    }

    //general error window call
    private void errorWindow(String title, String message) {
        ErrorWindow ew = new ErrorWindow(title, message);
        ew.setVisible(true);
    }

    //generates my sql query with parameters
    private void queryFormat() {
        String str = " and s.stat_id=d.stat_id";
        //states
        if (!state.equals("\"All\"")) { 
            str = str + " and s.state=" + state;
        }

        //RPO
        switch(rpo) {
            case "\"VISTAS\"":
                str = str + " and (s.state='AL' or s.state='FL' or s.state='GA' or s.state='KY' or s.state='MS' or s.state='NC' or s.state='SC' or s.state='TN' or s.state='VA' or s.state='WV')";
                break;
            case "\"CENRAP\"":
                str = str + " and (s.state='NE' or s.state='KS' or s.state='OK' or s.state='TX' or s.state='MN' or s.state='IA' or s.state='MO' or s.state='AR' or s.state='LA')";
                break;
            case "\"MANE=VU\"":
                str = str + " and (s.state='CT' or s.state='DE' or s.state='DC' or s.state='ME' or s.state='MD' or s.state='MA' or s.state='NH' or s.state='NJ' or s.state='NY' or s.state='PA' or s.state='RI' or s.state='VT')";
                break;
            case "\"LADCO\"":
                str = str + " and (s.state='IL' or s.state='IN' or s.state='MI' or s.state='OH' or s.state='WI')";
                break;
            case "\"WRAP\"":
                str = str + " and (s.state='AK' or s.state='CA' or s.state='OR' or s.state='WA' or s.state='AZ' or s.state='NM' or s.state='CO' or s.state='UT' or s.state='WY' or s.state='SD' or s.state='ND' or s.state='MT' or s.state='ID' or s.state='NV')";
                break;
            default:
                break;
        }
        //PCA
        switch(pca) {
            case "\"Northeast (Ozone)\"":
                str = str + " and (s.state='ME' or s.state='NH' or s.state='VT' or s.state='MA' or s.state='NY' or s.state='NJ' or s.state='MD' or s.state='DE' or s.state='CT' or s.state='RI' or s.state='PA' or s.state='DC')";
                break;
            case "\"Great Lakes (Ozone)\"":
                str = str + " and (s.state='MI' or s.state='IL' or s.state='OH' or s.state='IN' or s.state='WI')";
                break;
            case "\"Mid-Atlantic (Ozone)\"":
                str = str + " and (s.state='WV' or s.state='KY' or s.state='TN' or s.state='VA' or s.state='NC' or s.state='SC' or s.state='GA' or s.state='AL')";
                break;
            case "\"Southwest (Ozone)\"":
                str = str + " and (s.state='LA' or s.state='MS' or s.state='MO' or s.state='TX' or s.state='OK')";
                break;
            case "\"Northeast (Aerosols)\"":
                str = str + " and (s.state='ME' or s.state='NH' or s.state='VT' or s.state='MA' or s.state='NY' or s.state='NJ' or s.state='MD' or s.state='DE' or s.state='CT' or s.state='RI' or s.state='PA' or s.state='DC' or s.state='VA' or s.state='WV')";
                break;
            case "\"Great Lakes (Aerosols)\"":
                str = str + " and (s.state='OH' or s.state='MI' or s.state='IN' or s.state='IL' or s.state='WI')";
                break;
            case "\"Southeast (Aerosols)\"":
                str = str + " and (s.state='NC' or s.state='SC' or s.state='GA' or s.state='FL')";
                break;
            case "\"Lower Midwest (Aerosols)\"":
                str = str + " and (s.state='KY' or s.state='TN' or s.state='MS' or s.state='AL' or s.state='LA' or s.state='MO' or s.state='OK' or s.state='AR')";
                break;
            case "\"West (Aerosols)\"":
                str = str + " and (s.state='CA' or s.state='OR' or s.state='WA' or s.state='AZ' or s.state='NV' or s.state='NM')";
                break;
            default:
                break;
        }
        //Climate Regions
        switch(clim_reg) {
            case "\"Central\"":
                str = str + " and (s.state='IL' or s.state='IN' or s.state='KY' or s.state='MO' or s.state='OH' or s.state='TN' or s.state='WV')";
                break;
            case "\"East-North Central\"":
                str = str + " and (s.state='IA' or s.state='MI' or s.state='MN' or s.state='WI')";
                break;
            case "\"Northeast\"":
                str = str + " and (s.state='CT' or s.state='DE' or s.state='ME' or s.state='MD' or s.state='MA' or s.state='NH' or s.state='NJ' or s.state='NY' or s.state='PA' or s.state='RI' or s.state='VT')";
                break;
            case "\"Northwest\"":
                str = str + " and (s.state='ID' or s.state='OR' or s.state='WA')";
                break;
            case "\"South\"":
                str = str + " and (s.state='AR' or s.state='KS' or s.state='LA' or s.state='MS' or s.state='OK' or s.state='TX')";
                break;
            case "\"Southeast\"":
                str = str + " and (s.state='AL' or s.state='FL' or s.state='GA' or s.state='SC' or s.state='NC' or s.state='VA')";
                break;
            case "\"Southwest\"":
                str = str + " and (s.state='AZ' or s.state='CO' or s.state='NM' or s.state='UT')";
                break;
            case "\"West\"":
                str = str + " and (s.state='CA' or s.state='NV')";
                break;
            case "\"West-North Central\"":
                str = str + " and (s.state='MT' or s.state='NE' or s.state='ND' or s.state='SD' or s.state='WY')";
                break;
            default:
                break;
        }
        //DISCOVER-AQ REGIONS
        switch(discovaq) {
            case "\"4-km Window\"":
                str = str + " and (d.stat_id='Appalac005' or d.stat_id='Billeri011' or d.stat_id='Brookha017' or d.stat_id='CCNY032' or d.stat_id='COVE_SE041' or d.stat_id='Dayton043' or d.stat_id='DRAGON_044' or d.stat_id='DRAGON_045' or d.stat_id='DRAGON_046' or d.stat_id='DRAGON_047' or d.stat_i"
                        + "d='DRAGON_048' or d.stat_id='DRAGON_050' or d.stat_id='DRAGON_051' or d.stat_id='DRAGON_052' or d.stat_id='DRAGON_053' or d.stat_id='DRAGON_054' or d.stat_id='DRAGON_055' or d.stat_id='DRAGON_057' or d.stat_id='DRAGON_058' or d.stat_id='DRAGON_059' or d.stat_id='DRAGON_06"
                        + "1' or d.stat_id='DRAGON_063' or d.stat_id='DRAGON_065' or d.stat_id='DRAGON_068' or d.stat_id='DRAGON_069' or d.stat_id='DRAGON_070' or d.stat_id='DRAGON_071' or d.stat_id='DRAGON_072' or d.stat_id='DRAGON_073' or d.stat_id='DRAGON_074' or d.stat_id='DRAGON_078' or d.stat"
                        + "_id='DRAGON_080' or d.stat_id='DRAGON_082' or d.stat_id='DRAGON_083' or d.stat_id='DRAGON_084' or d.stat_id='DRAGON_086' or d.stat_id='DRAGON_087' or d.stat_id='DRAGON_088' or d.stat_id='DRAGON_090' or d.stat_id='DRAGON_093' or d.stat_id='DRAGON_096' or d.stat_id='DRAGON_"
                        + "097' or d.stat_id='DRAGON_098' or d.stat_id='DRAGON_099' or d.stat_id='Easton_101' or d.stat_id='Egbert102' or d.stat_id='Georgia115' or d.stat_id='GSFC118' or d.stat_id='Harvard122' or d.stat_id='LISCO140' or d.stat_id='SERC187' or d.stat_id='Toronto207' or d.stat_id='UM"
                        + "BC215' or d.stat_id='Wallops223' or d.stat_id='090010017' or d.stat_id='090011123' or d.stat_id='090013007' or d.stat_id='090019003' or d.stat_id='090031003' or d.stat_id='090050005' or d.stat_id='090070007' or d.stat_id='090090027' or d.stat_id='090093002' or d.stat_id='"
                        + "090110124' or d.stat_id='090131001' or d.stat_id='100010002' or d.stat_id='100031007' or d.stat_id='100031010' or d.stat_id='100031013' or d.stat_id='100032004' or d.stat_id='100051002' or d.stat_id='100051003' or d.stat_id='110010041' or d.stat_id='110010043' or d.stat_i"
                        + "d='130550001' or d.stat_id='130590002' or d.stat_id='130670003' or d.stat_id='130730001' or d.stat_id='130850001' or d.stat_id='130890002' or d.stat_id='130970004' or d.stat_id='131210055' or d.stat_id='131350002' or d.stat_id='132130003' or d.stat_id='132230003' or d.sta"
                        + "t_id='132450091' or d.stat_id='132470001' or d.stat_id='210130002' or d.stat_id='210131002' or d.stat_id='210190017' or d.stat_id='210373002' or d.stat_id='210430500' or d.stat_id='210670012' or d.stat_id='210890007' or d.stat_id='211130001' or d.stat_id='211930003' or d."
                        + "stat_id='211950002' or d.stat_id='211990003' or d.stat_id='240030014' or d.stat_id='240051007' or d.stat_id='240053001' or d.stat_id='240090011' or d.stat_id='240130001' or d.stat_id='240150003' or d.stat_id='240170010' or d.stat_id='240210037' or d.stat_id='240230002' or"
                        + " d.stat_id='240251001' or d.stat_id='240259001' or d.stat_id='240290002' or d.stat_id='240313001' or d.stat_id='240330030' or d.stat_id='240338003' or d.stat_id='240430009' or d.stat_id='245100054' or d.stat_id='250010002' or d.stat_id='250034002' or d.stat_id='250051002'"
                        + " or d.stat_id='250070001' or d.stat_id='250092006' or d.stat_id='250095005' or d.stat_id='250130008' or d.stat_id='250150103' or d.stat_id='250154002' or d.stat_id='250170009' or d.stat_id='250171102' or d.stat_id='250213003' or d.stat_id='250250041' or d.stat_id='2502500"
                        + "42' or d.stat_id='250270015' or d.stat_id='250270024' or d.stat_id='260490021' or d.stat_id='260492001' or d.stat_id='260630007' or d.stat_id='260910007' or d.stat_id='260990009' or d.stat_id='260991003' or d.stat_id='261250001' or d.stat_id='261470005' or d.stat_id='2616"
                        + "10008' or d.stat_id='261630001' or d.stat_id='261630019' or d.stat_id='330050007' or d.stat_id='330111011' or d.stat_id='330115001' or d.stat_id='340010006' or d.stat_id='340030006' or d.stat_id='340071001' or d.stat_id='340110007' or d.stat_id='340130003' or d.stat_id='3"
                        + "40150002' or d.stat_id='340170006' or d.stat_id='340190001' or d.stat_id='340210005' or d.stat_id='340230011' or d.stat_id='340250005' or d.stat_id='340273001' or d.stat_id='340290006' or d.stat_id='340315001' or d.stat_id='360010012' or d.stat_id='360050133' or d.stat_id"
                        + "='360130006' or d.stat_id='360130011' or d.stat_id='360150003' or d.stat_id='360270007' or d.stat_id='360290002' or d.stat_id='360410005' or d.stat_id='360430005' or d.stat_id='360530006' or d.stat_id='360551007' or d.stat_id='360610135' or d.stat_id='360631006' or d.stat"
                        + "_id='360650004' or d.stat_id='360671015' or d.stat_id='360715001' or d.stat_id='360750003' or d.stat_id='360790005' or d.stat_id='360810124' or d.stat_id='360830004' or d.stat_id='360850067' or d.stat_id='360870005' or d.stat_id='360910004' or d.stat_id='361010003' or d.s"
                        + "tat_id='361030002' or d.stat_id='361030004' or d.stat_id='361030009' or d.stat_id='361111005' or d.stat_id='361173001' or d.stat_id='361192004' or d.stat_id='370030004' or d.stat_id='370110002' or d.stat_id='370210030' or d.stat_id='370270003' or d.stat_id='370330001' or "
                        + "d.stat_id='370370004' or d.stat_id='370510008' or d.stat_id='370511003' or d.stat_id='370590003' or d.stat_id='370630015' or d.stat_id='370650099' or d.stat_id='370670022' or d.stat_id='370670028' or d.stat_id='370670030' or d.stat_id='370671008' or d.stat_id='370690001' "
                        + "or d.stat_id='370750001' or d.stat_id='370770001' or d.stat_id='370810013' or d.stat_id='370870035' or d.stat_id='370870036' or d.stat_id='370990005' or d.stat_id='371010002' or d.stat_id='371070004' or d.stat_id='371090004' or d.stat_id='371170001' or d.stat_id='37119004"
                        + "1' or d.stat_id='371191005' or d.stat_id='371191009' or d.stat_id='371290002' or d.stat_id='371450003' or d.stat_id='371470006' or d.stat_id='371570099' or d.stat_id='371590021' or d.stat_id='371590022' or d.stat_id='371730002' or d.stat_id='371790003' or d.stat_id='37183"
                        + "0014' or d.stat_id='371830016' or d.stat_id='371990004' or d.stat_id='390030009' or d.stat_id='390071001' or d.stat_id='390090004' or d.stat_id='390170004' or d.stat_id='390170018' or d.stat_id='390230001' or d.stat_id='390230003' or d.stat_id='390250022' or d.stat_id='39"
                        + "0271002' or d.stat_id='390350034' or d.stat_id='390350060' or d.stat_id='390350064' or d.stat_id='390355002' or d.stat_id='390410002' or d.stat_id='390490029' or d.stat_id='390490037' or d.stat_id='390490081' or d.stat_id='390550004' or d.stat_id='390570006' or d.stat_id="
                        + "'390610006' or d.stat_id='390610040' or d.stat_id='390810017' or d.stat_id='390830002' or d.stat_id='390850003' or d.stat_id='390850007' or d.stat_id='390870011' or d.stat_id='390870012' or d.stat_id='390890005' or d.stat_id='390930018' or d.stat_id='390950024' or d.stat_"
                        + "id='390950027' or d.stat_id='390950034' or d.stat_id='390970007' or d.stat_id='390990013' or d.stat_id='391030004' or d.stat_id='391090005' or d.stat_id='391130037' or d.stat_id='391331001' or d.stat_id='391510016' or d.stat_id='391510022' or d.stat_id='391514005' or d.st"
                        + "at_id='391530020' or d.stat_id='391550009' or d.stat_id='391550011' or d.stat_id='391650007' or d.stat_id='391670004' or d.stat_id='391730003' or d.stat_id='420010002' or d.stat_id='420030008' or d.stat_id='420030010' or d.stat_id='420030067' or d.stat_id='420031005' or d"
                        + ".stat_id='420050001' or d.stat_id='420070002' or d.stat_id='420070005' or d.stat_id='420070014' or d.stat_id='420110006' or d.stat_id='420110011' or d.stat_id='420130801' or d.stat_id='420170012' or d.stat_id='420210011' or d.stat_id='420270100' or d.stat_id='420290100' o"
                        + "r d.stat_id='420334000' or d.stat_id='420430401' or d.stat_id='420431100' or d.stat_id='420450002' or d.stat_id='420490003' or d.stat_id='420550001' or d.stat_id='420590002' or d.stat_id='420630004' or d.stat_id='420690101' or d.stat_id='420692006' or d.stat_id='420710007"
                        + "' or d.stat_id='420710012' or d.stat_id='420730015' or d.stat_id='420770004' or d.stat_id='420791100' or d.stat_id='420791101' or d.stat_id='420810100' or d.stat_id='420850100' or d.stat_id='420890002' or d.stat_id='420910013' or d.stat_id='420950025' or d.stat_id='420958"
                        + "000' or d.stat_id='420990301' or d.stat_id='421010004' or d.stat_id='421010024' or d.stat_id='421174000' or d.stat_id='421250005' or d.stat_id='421250200' or d.stat_id='421255001' or d.stat_id='421290006' or d.stat_id='421290008' or d.stat_id='421330008' or d.stat_id='421"
                        + "330011' or d.stat_id='440030002' or d.stat_id='440071010' or d.stat_id='440090007' or d.stat_id='450010001' or d.stat_id='450030003' or d.stat_id='450070005' or d.stat_id='450150002' or d.stat_id='450190046' or d.stat_id='450210002' or d.stat_id='450250001' or d.stat_id='"
                        + "450310003' or d.stat_id='450370001' or d.stat_id='450450016' or d.stat_id='450451003' or d.stat_id='450730001' or d.stat_id='450770002' or d.stat_id='450790007' or d.stat_id='450790021' or d.stat_id='450791001' or d.stat_id='450830009' or d.stat_id='450910006' or d.stat_i"
                        + "d='470010101' or d.stat_id='470090101' or d.stat_id='470090102' or d.stat_id='470651011' or d.stat_id='470654003' or d.stat_id='470890002' or d.stat_id='470930021' or d.stat_id='470931020' or d.stat_id='471050109' or d.stat_id='471210104' or d.stat_id='471550101' or d.sta"
                        + "t_id='471550102' or d.stat_id='471632002' or d.stat_id='471632003' or d.stat_id='500030004' or d.stat_id='510030001' or d.stat_id='510130020' or d.stat_id='510330001' or d.stat_id='510360002' or d.stat_id='510410004' or d.stat_id='510590030' or d.stat_id='510610002' or d."
                        + "stat_id='510690010' or d.stat_id='510850003' or d.stat_id='510870014' or d.stat_id='511071005' or d.stat_id='511130003' or d.stat_id='511390004' or d.stat_id='511530009' or d.stat_id='511611004' or d.stat_id='511630003' or d.stat_id='511650003' or d.stat_id='511790001' or"
                        + " d.stat_id='511970002' or d.stat_id='515100009' or d.stat_id='518000004' or d.stat_id='518000005' or d.stat_id='540030003' or d.stat_id='540110006' or d.stat_id='540250003' or d.stat_id='540291004' or d.stat_id='540390010' or d.stat_id='540610003' or d.stat_id='540690010'"
                        + " or d.stat_id='541071002' or d.stat_id='090010010' or d.stat_id='090013005' or d.stat_id='090032006' or d.stat_id='090091123' or d.stat_id='090092123' or d.stat_id='090113002' or d.stat_id='100010003' or d.stat_id='100031003' or d.stat_id='100031012' or d.stat_id='1100100"
                        + "42' or d.stat_id='130630091' or d.stat_id='130670004' or d.stat_id='130892001' or d.stat_id='131150003' or d.stat_id='131210032' or d.stat_id='131210039' or d.stat_id='131390003' or d.stat_id='132450005' or d.stat_id='132950002' or d.stat_id='210190002' or d.stat_id='2106"
                        + "70014' or d.stat_id='211510003' or d.stat_id='240031003' or d.stat_id='240330025' or d.stat_id='245100006' or d.stat_id='245100007' or d.stat_id='245100008' or d.stat_id='245100040' or d.stat_id='250035001' or d.stat_id='250051004' or d.stat_id='250096001' or d.stat_id='2"
                        + "50130016' or d.stat_id='250132009' or d.stat_id='250230004' or d.stat_id='250250002' or d.stat_id='250250027' or d.stat_id='250250043' or d.stat_id='250270016' or d.stat_id='250270023' or d.stat_id='261150005' or d.stat_id='261630005' or d.stat_id='261630015' or d.stat_id"
                        + "='261630016' or d.stat_id='261630025' or d.stat_id='261630033' or d.stat_id='261630036' or d.stat_id='261630038' or d.stat_id='261630039' or d.stat_id='330111015' or d.stat_id='330150018' or d.stat_id='340011006' or d.stat_id='340030003' or d.stat_id='340070009' or d.stat"
                        + "_id='340071007' or d.stat_id='340150004' or d.stat_id='340171003' or d.stat_id='340172002' or d.stat_id='340210008' or d.stat_id='340218001' or d.stat_id='340230006' or d.stat_id='340270004' or d.stat_id='340292002' or d.stat_id='340310005' or d.stat_id='340390004' or d.s"
                        + "tat_id='340390006' or d.stat_id='340392003' or d.stat_id='340410006' or d.stat_id='340410007' or d.stat_id='360010005' or d.stat_id='360050080' or d.stat_id='360290005' or d.stat_id='360470122' or d.stat_id='360590008' or d.stat_id='360610079' or d.stat_id='360610128' or "
                        + "d.stat_id='360610134' or d.stat_id='360632008' or d.stat_id='360710002' or d.stat_id='360850055' or d.stat_id='361191002' or d.stat_id='370010002' or d.stat_id='370210034' or d.stat_id='370350004' or d.stat_id='370510009' or d.stat_id='370570002' or d.stat_id='370610002' "
                        + "or d.stat_id='370650004' or d.stat_id='370710016' or d.stat_id='370810014' or d.stat_id='370870012' or d.stat_id='370990006' or d.stat_id='371110004' or d.stat_id='371190003' or d.stat_id='371190042' or d.stat_id='371190043' or d.stat_id='371210001' or d.stat_id='37123000"
                        + "1' or d.stat_id='371550005' or d.stat_id='371830020' or d.stat_id='371890003' or d.stat_id='371910005' or d.stat_id='390090003' or d.stat_id='390170003' or d.stat_id='390170015' or d.stat_id='390170016' or d.stat_id='390230005' or d.stat_id='390290020' or d.stat_id='39029"
                        + "0022' or d.stat_id='390350038' or d.stat_id='390350045' or d.stat_id='390350065' or d.stat_id='390351002' or d.stat_id='390490024' or d.stat_id='390490025' or d.stat_id='390570005' or d.stat_id='390610014' or d.stat_id='390610042' or d.stat_id='390615001' or d.stat_id='39"
                        + "0810001' or d.stat_id='390811001' or d.stat_id='390851001' or d.stat_id='390933002' or d.stat_id='390950026' or d.stat_id='390950028' or d.stat_id='390990005' or d.stat_id='390990006' or d.stat_id='390990014' or d.stat_id='391130032' or d.stat_id='391137001' or d.stat_id="
                        + "'391330002' or d.stat_id='391450013' or d.stat_id='391450019' or d.stat_id='391510017' or d.stat_id='391510020' or d.stat_id='391530017' or d.stat_id='391530023' or d.stat_id='391550005' or d.stat_id='391550006' or d.stat_id='420030002' or d.stat_id='420030064' or d.stat_"
                        + "id='420030092' or d.stat_id='420030093' or d.stat_id='420031008' or d.stat_id='420031301' or d.stat_id='420033007' or d.stat_id='420410101' or d.stat_id='420950027' or d.stat_id='421010047' or d.stat_id='421010055' or d.stat_id='421010057' or d.stat_id='421010449' or d.st"
                        + "at_id='421010649' or d.stat_id='421011002' or d.stat_id='440070022' or d.stat_id='440070026' or d.stat_id='440070027' or d.stat_id='440070028' or d.stat_id='450190048' or d.stat_id='450410003' or d.stat_id='450450009' or d.stat_id='450450015' or d.stat_id='450630008' or d"
                        + ".stat_id='450790019' or d.stat_id='470090011' or d.stat_id='470110103' or d.stat_id='470111002' or d.stat_id='470650006' or d.stat_id='470650031' or d.stat_id='470654002' or d.stat_id='470930028' or d.stat_id='470931013' or d.stat_id='470931017' or d.stat_id='471050108' o"
                        + "r d.stat_id='471070101' or d.stat_id='471071002' or d.stat_id='471450004' or d.stat_id='471450103' or d.stat_id='471451001' or d.stat_id='471631007' or d.stat_id='471730105' or d.stat_id='510350001' or d.stat_id='510410003' or d.stat_id='510470002' or d.stat_id='510870015"
                        + "' or d.stat_id='511010003' or d.stat_id='511870004' or d.stat_id='515100020' or d.stat_id='515200006' or d.stat_id='516300004' or d.stat_id='516500008' or d.stat_id='516700010' or d.stat_id='516800015' or d.stat_id='517100024' or d.stat_id='517700011' or d.stat_id='517700"
                        + "015' or d.stat_id='517750011' or d.stat_id='518100008' or d.stat_id='518400002' or d.stat_id='540090005' or d.stat_id='540391005' or d.stat_id='540490006' or d.stat_id='540511002' or d.stat_id='540810002' or d.stat_id='090010012' or d.stat_id='100031008' or d.stat_id='110"
                        + "010023' or d.stat_id='131210048' or d.stat_id='250094005' or d.stat_id='250250040' or d.stat_id='330110020' or d.stat_id='340131003' or d.stat_id='340171002' or d.stat_id='340390003' or d.stat_id='360050112' or d.stat_id='360050113' or d.stat_id='360291013' or d.stat_id='"
                        + "360291014' or d.stat_id='360470052' or d.stat_id='360470118' or d.stat_id='360470121' or d.stat_id='360590005' or d.stat_id='360652001' or d.stat_id='360670017' or d.stat_id='360810120' or d.stat_id='360850111' or d.stat_id='370130151' or d.stat_id='370670023' or d.stat_i"
                        + "d='371290006' or d.stat_id='390010001' or d.stat_id='390133002' or d.stat_id='390350051' or d.stat_id='390350053' or d.stat_id='390490005' or d.stat_id='390490034' or d.stat_id='390610021' or d.stat_id='390810018' or d.stat_id='390810020' or d.stat_id='390850006' or d.sta"
                        + "t_id='390951003' or d.stat_id='391051001' or d.stat_id='391130028' or d.stat_id='391130034' or d.stat_id='391150004' or d.stat_id='391450020' or d.stat_id='391450021' or d.stat_id='391450022' or d.stat_id='391530022' or d.stat_id='391570006' or d.stat_id='420010001' or d."
                        + "stat_id='420030003' or d.stat_id='420030031' or d.stat_id='420030038' or d.stat_id='420033006' or d.stat_id='420037004' or d.stat_id='420951000' or d.stat_id='421230004' or d.stat_id='440070012' or d.stat_id='450430011' or d.stat_id='450430012' or d.stat_id='450630009' or"
                        + " d.stat_id='450630010' or d.stat_id='450770003' or d.stat_id='470110102' or d.stat_id='471450104' or d.stat_id='471453009' or d.stat_id='471630007' or d.stat_id='471730107' or d.stat_id='517600024' or d.stat_id='540090007' or d.stat_id='540090011' or d.stat_id='540290005'"
                        + " or d.stat_id='540290007' or d.stat_id='540290008' or d.stat_id='540290009' or d.stat_id='540290015' or d.stat_id='540990004' or d.stat_id='540990005' or d.stat_id='ABT147' or d.stat_id='ANA115' or d.stat_id='ARE128' or d.stat_id='BEL116' or d.stat_id='BFT142' or d.stat_i"
                        + "d='BWR139' or d.stat_id='CAT175' or d.stat_id='CDR119' or d.stat_id='CKT136' or d.stat_id='CND125' or d.stat_id='COW137' or d.stat_id='CTH110' or d.stat_id='DCP114' or d.stat_id='EGB181' or d.stat_id='GRS420' or d.stat_id='KEF112' or d.stat_id='LRL117' or d.stat_id='MKG11"
                        + "3' or d.stat_id='PAR107' or d.stat_id='PED108' or d.stat_id='PNF126' or d.stat_id='PSU106' or d.stat_id='QAK172' or d.stat_id='SHN418' or d.stat_id='SPD111' or d.stat_id='UVL124' or d.stat_id='VPI120' or d.stat_id='WSP144' or d.stat_id='130590001' or d.stat_id='540390011'"
                        + " or d.stat_id='BRIG1' or d.stat_id='CACO1' or d.stat_id='COHU1' or d.stat_id='DOSO1' or d.stat_id='EGBE1' or d.stat_id='FRRE1' or d.stat_id='GRSM1' or d.stat_id='JARI1' or d.stat_id='LIGO1' or d.stat_id='LYBR1' or d.stat_id='MAVI1' or d.stat_id='MOMO1' or d.stat_id='PACK1"
                        + "' or d.stat_id='QUCI1' or d.stat_id='QURE1' or d.stat_id='ROMA1' or d.stat_id='SHEN1' or d.stat_id='SHRO1' or d.stat_id='SWAN1' or d.stat_id='WASH1' or d.stat_id='CT15' or d.stat_id='KY22' or d.stat_id='KY35' or d.stat_id='MA01' or d.stat_id='MA08' or d.stat_id='MD07' or "
                        + "d.stat_id='MD08' or d.stat_id='MD13' or d.stat_id='MD15' or d.stat_id='MD18' or d.stat_id='MD99' or d.stat_id='MI51' or d.stat_id='MI52' or d.stat_id='NC03' or d.stat_id='NC06' or d.stat_id='NC25' or d.stat_id='NC29' or d.stat_id='NC34' or d.stat_id='NC35' or d.stat_id='N"
                        + "C36' or d.stat_id='NC41' or d.stat_id='NC45' or d.stat_id='NJ00' or d.stat_id='NJ99' or d.stat_id='NY01' or d.stat_id='NY08' or d.stat_id='NY10' or d.stat_id='NY52' or d.stat_id='NY68' or d.stat_id='NY96' or d.stat_id='NY99' or d.stat_id='OH17' or d.stat_id='OH49' or d.st"
                        + "at_id='OH54' or d.stat_id='OH71' or d.stat_id='PA00' or d.stat_id='PA15' or d.stat_id='PA18' or d.stat_id='PA29' or d.stat_id='PA42' or d.stat_id='PA47' or d.stat_id='PA72' or d.stat_id='SC05' or d.stat_id='SC06' or d.stat_id='TN00' or d.stat_id='TN04' or d.stat_id='TN11'"
                        + " or d.stat_id='VA00' or d.stat_id='VA13' or d.stat_id='VA24' or d.stat_id='VA28' or d.stat_id='VA98' or d.stat_id='VA99' or d.stat_id='VT01' or d.stat_id='WV04' or d.stat_id='WV05' or d.stat_id='WV18')  ";
                break;
            case "\"1-km Window\"":
               str = str + " and (d.stat_id='DRAGON_164' or d.stat_id='DRAGON_165' or d.stat_id='DRAGON_167'or d.stat_id='DRAGON_168' or d.stat_id='DRAGON_169' or d.stat_id='DRAGON_171' or d.stat_id='DRAGON_172' or d.stat_id='DRAGON_173' or d.stat_id='DRAGON_174' or d.stat_id='DRAGON_175' or d.stat"
                       + "_id='DRAGON_176' or d.stat_id='DRAGON_178' or d.stat_id='DRAGON_180' or d.stat_id='DRAGON_181' or d.stat_id='DRAGON_183' or d.stat_id='DRAGON_185' or d.stat_id='DRAGON_187' or d.stat_id='DRAGON_190' or d.stat_id='DRAGON_191' or d.stat_id='DRAGON_192' or d.stat_id='DRAGON_1"
                       + "93' or d.stat_id='DRAGON_194' or d.stat_id='DRAGON_195' or d.stat_id='DRAGON_196' or d.stat_id='DRAGON_207' or d.stat_id='DRAGON_216' or d.stat_id='DRAGON_219' or d.stat_id='DRAGON_224' or d.stat_id='DRAGON_225' or d.stat_id='DRAGON_230' or d.stat_id='DRAGON_231' or d.stat"
                       + "_id='DRAGON_234' or d.stat_id='DRAGON_237' or d.stat_id='DRAGON_243' or d.stat_id='DRAGON_250' or d.stat_id='DRAGON_252' or d.stat_id='DRAGON_253' or d.stat_id='Easton_260' or d.stat_id='GSFC303' or d.stat_id='SERC592' or d.stat_id='UMBC680' or d.stat_id='Wallops696' or d."
                       + "stat_id='100010002' or d.stat_id='100010003' or d.stat_id='100031003' or d.stat_id='100031007' or d.stat_id='100031008' or d.stat_id='100031012' or d.stat_id='100032004' or d.stat_id='100051002' or d.stat_id='110010041' or d.stat_id='110010042' or d.stat_id='110010043' or "
                       + "d.stat_id='240031003' or d.stat_id='240051007' or d.stat_id='240053001' or d.stat_id='240150003' or d.stat_id='240251001' or d.stat_id='240290002' or d.stat_id='240313001' or d.stat_id='240330025' or d.stat_id='240330030' or d.stat_id='240338003' or d.stat_id='240430009' o"
                       + "r d.stat_id='245100006' or d.stat_id='245100007' or d.stat_id='245100008' or d.stat_id='245100040' or d.stat_id='340070009' or d.stat_id='340071007' or d.stat_id='340110007' or d.stat_id='340150004' or d.stat_id='420010001' or d.stat_id='420290100' or d.stat_id='420410101'"
                       + " or d.stat_id='420430401' or d.stat_id='420450002' or d.stat_id='420710007' or d.stat_id='420750100' or d.stat_id='420910013' or d.stat_id='421010004' or d.stat_id='421010014' or d.stat_id='421010047' or d.stat_id='421010055' or d.stat_id='421010057' or d.stat_id='42101006"
                       + "3' or d.stat_id='421010449' or d.stat_id='421010649' or d.stat_id='421011002' or d.stat_id='421330008' or d.stat_id='510030001' or d.stat_id='510130020' or d.stat_id='510330001' or d.stat_id='510470002' or d.stat_id='510590030' or d.stat_id='510690010' or d.stat_id='510870"
                       + "014' or d.stat_id='510870015' or d.stat_id='511010003' or d.stat_id='511071005' or d.stat_id='511130003' or d.stat_id='511870004' or d.stat_id='515100009' or d.stat_id='515100020' or d.stat_id='516300004' or d.stat_id='518400002' or d.stat_id='540030003' or d.stat_id='1000"
                       + "31010' or d.stat_id='100031013' or d.stat_id='100051003' or d.stat_id='240030014' or d.stat_id='240090011' or d.stat_id='240130001' or d.stat_id='240170010' or d.stat_id='240199991' or d.stat_id='240210037' or d.stat_id='240259001' or d.stat_id='240339991' or d.stat_id='24"
                       + "5100054' or d.stat_id='340071001' or d.stat_id='340150002' or d.stat_id='420010002' or d.stat_id='420019991' or d.stat_id='420431100' or d.stat_id='420550001' or d.stat_id='420710012' or d.stat_id='420990301' or d.stat_id='421010024' or d.stat_id='421330011' or d.stat_id='"
                       + "510610002' or d.stat_id='510850003' or d.stat_id='511530009' or d.stat_id='511790001' or d.stat_id='110010023' or d.stat_id='517600024' or d.stat_id='ARE128' or d.stat_id='BEL116' or d.stat_id='BWR139' or d.stat_id='SHN418' or d.stat_id='SHEN1' or d.stat_id='WASH1' or d.st"
                       + "at_id='MD07' or d.stat_id='MD13' or d.stat_id='MD15' or d.stat_id='MD18' or d.stat_id='MD99' or d.stat_id='PA00' or d.stat_id='PA47' or d.stat_id='VA00' or d.stat_id='VA28' or d.stat_id='VA98' ) ";
               break;
            case "\"2-km Window SJV\"":
                str = str + " and (d.stat_id = '060010007' or d.stat_id = '060010009' or d.stat_id = '060010011' or d.stat_id = '060050002' or d.stat_id = '060070007' or d.stat_id = '060070008' or d.stat_id = '060090001' or d.stat_id = '060111002' or d.stat_id = '060130002' or d.stat_id = '06013100"
                        + "2' or d.stat_id = '060131004' or d.stat_id = '060170010' or d.stat_id = '060190007' or d.stat_id = '060190011' or d.stat_id = '060190242' or d.stat_id = '060192009' or d.stat_id = '060194001' or d.stat_id = '060195001' or d.stat_id = '060210003' or d.stat_id = '060290007'"
                        + " or d.stat_id = '060290008' or d.stat_id = '060290011' or d.stat_id = '060290014' or d.stat_id = '060290232' or d.stat_id = '060292012' or d.stat_id = '060295002' or d.stat_id = '060296001' or d.stat_id = '060310500' or d.stat_id = '060311004' or d.stat_id = '060333001' o"
                        + "r d.stat_id = '060370002' or d.stat_id = '060370016' or d.stat_id = '060370113' or d.stat_id = '060371002' or d.stat_id = '060371103' or d.stat_id = '060371201' or d.stat_id = '060371302' or d.stat_id = '060371602' or d.stat_id = '060371701' or d.stat_id = '060374002' or "
                        + "d.stat_id = '060374006' or d.stat_id = '060375005' or d.stat_id = '060376012' or d.stat_id = '060379033' or d.stat_id = '060390004' or d.stat_id = '060390500' or d.stat_id = '060392010' or d.stat_id = '060410001' or d.stat_id = '060430003' or d.stat_id = '060470003' or d."
                        + "stat_id = '060530002' or d.stat_id = '060530008' or d.stat_id = '060531003' or d.stat_id = '060550003' or d.stat_id = '060570005' or d.stat_id = '060590007' or d.stat_id = '060591003' or d.stat_id = '060592022' or d.stat_id = '060595001' or d.stat_id = '060610003' or d.st"
                        + "at_id = '060610004' or d.stat_id = '060610006' or d.stat_id = '060612002' or d.stat_id = '060658001' or d.stat_id = '060658005' or d.stat_id = '060659001' or d.stat_id = '060670002' or d.stat_id = '060670006' or d.stat_id = '060670010' or d.stat_id = '060670011' or d.stat"
                        + "_id = '060670012' or d.stat_id = '060670014' or d.stat_id = '060675003' or d.stat_id = '060690002' or d.stat_id = '060690003' or d.stat_id = '060710012' or d.stat_id = '060711004' or d.stat_id = '060712002' or d.stat_id = '060750005' or d.stat_id = '060771002' or d.stat_i"
                        + "d = '060773005' or d.stat_id = '060790005' or d.stat_id = '060792006' or d.stat_id = '060793001' or d.stat_id = '060794002' or d.stat_id = '060798001' or d.stat_id = '060798005' or d.stat_id = '060798006' or d.stat_id = '060811001' or d.stat_id = '060830008' or d.stat_id "
                        + "= '060830011' or d.stat_id = '060831008' or d.stat_id = '060831013' or d.stat_id = '060831014' or d.stat_id = '060831018' or d.stat_id = '060831021' or d.stat_id = '060831025' or d.stat_id = '060832004' or d.stat_id = '060832011' or d.stat_id = '060833001' or d.stat_id = "
                        + "'060834003' or d.stat_id = '060850005' or d.stat_id = '060852009' or d.stat_id = '060870007' or d.stat_id = '060871003' or d.stat_id = '060890004' or d.stat_id = '060890007' or d.stat_id = '060890009' or d.stat_id = '060893003' or d.stat_id = '060950004' or d.stat_id = '0"
                        + "60953003' or d.stat_id = '060970003' or d.stat_id = '060971003' or d.stat_id = '060990005' or d.stat_id = '060990006' or d.stat_id = '061010003' or d.stat_id = '061030005' or d.stat_id = '061070006' or d.stat_id = '061070009' or d.stat_id = '061072002' or d.stat_id = '061"
                        + "072010' or d.stat_id = '061090005' or d.stat_id = '061110007' or d.stat_id = '061110009' or d.stat_id = '061111004' or d.stat_id = '061112002' or d.stat_id = '061113001' or d.stat_id = '061130004' or d.stat_id = '061131003' or d.stat_id = '320310016' or d.stat_id = '32031"
                        + "0020' or d.stat_id = '320310025' or d.stat_id = '320311005' or d.stat_id = '320312002' or d.stat_id = '320312009' or d.stat_id = '060130006' or d.stat_id = '060131001' or d.stat_id = '060132001' or d.stat_id = '060195025' or d.stat_id = '060290016' or d.stat_id = '0602900"
                        + "17' or d.stat_id = '060310004' or d.stat_id = '060374004' or d.stat_id = '060410004' or d.stat_id = '060431001' or d.stat_id = '060472510' or d.stat_id = '060510001' or d.stat_id = '060510005' or d.stat_id = '060510011' or d.stat_id = '060571001' or d.stat_id = '060610002"
                        + "' or d.stat_id = '060631006' or d.stat_id = '060631009' or d.stat_id = '060650003' or d.stat_id = '060651003' or d.stat_id = '060670284' or d.stat_id = '060674001' or d.stat_id = '060710025' or d.stat_id = '060773010' or d.stat_id = '060890008' or d.stat_id = '060953001' "
                        + "or d.stat_id = '060970001' or d.stat_id = '060970002' or d.stat_id = '060973002' or d.stat_id = '061030002' or d.stat_id = '061050002' or d.stat_id = '061132001' or d.stat_id = '060012005' or d.stat_id = '060072002' or d.stat_id = '060074001' or d.stat_id = '060110007' or"
                        + " d.stat_id = '060132007' or d.stat_id = '060170011' or d.stat_id = '060192008' or d.stat_id = '060271023' or d.stat_id = '060271028' or d.stat_id = '060292009' or d.stat_id = '060333010' or d.stat_id = '060333011' or d.stat_id = '060333012' or d.stat_id = '060410003' or d"
                        + ".stat_id = '060631007' or d.stat_id = '060670007' or d.stat_id = '060772010' or d.stat_id = '060792004' or d.stat_id = '060792007' or d.stat_id = '060831020' or d.stat_id = '060831022' or d.stat_id = '060831033' or d.stat_id = '060831037' or d.stat_id = '060850002' or d.s"
                        + "tat_id = '061030006'or d.stat_id = '061073000' or d.stat_id = '061110008' or d.stat_id = '320310022' or d.stat_id = '320310030' or d.stat_id = '320311026' or d.stat_id = '320312010' or d.stat_id = 'LAV410' or d.stat_id = 'PIN414' or d.stat_id = 'SEK430' or d.stat_id = 'YO"
                        + "S204' or d.stat_id = 'YOS404' or d.stat_id = 'BLIS1' or d.stat_id = 'DOME1' or d.stat_id = 'FRES1' or d.stat_id = 'HOOV1' or d.stat_id = 'KAIS1' or d.stat_id = 'LAVO1' or d.stat_id = 'PINN1' or d.stat_id = 'PORE1' or d.stat_id = 'RAFA1' or d.stat_id = 'SAGA1' or d.stat_id"
                        + " = 'SEQU1' or d.stat_id = 'TRIN1' or d.stat_id = 'YOSE1' ) ";
                break;
            default:
                break;
        }
        //site_id or stat_id
        if (!site_id.equals("\"All\"")) {
            str = str + " and d.stat_id='" + site_id.replace("\"","") + "'";
        }
        //date
        String sd = year_start + month_start + day_start;
        String ed = year_end + month_end + day_end;
        str = str + " and d.ob_dates BETWEEN " + sd + " and " + ed + " and d.ob_datee BETWEEN " + sd +  " and " + ed + "";
        //hour
        if (!start_hour.equals("\"\"") && !end_hour.equals("\"\"")) {
            str = str + " and (d.ob_hour >= " + hourFormat(start_hour) + " and d.ob_hour <= " + hourFormat(end_hour) + ")";
        } else {
            str = str + " and (d.ob_hour >= 00 and d.ob_hour <= 23)";
        }
        //Season
        switch(season) {
            case "\"Winter (Dec, Jan, Feb)\"":
                str = str + " and (month = 12 or month = 01 or month = 02)";
                str = str + " and (month(d.ob_dates) = 12 or month(d.ob_dates) = 01 or month(d.ob_dates = 02))";
                break;
            case "\"Spring (Mar, Apr, May)\"":
                str = str + " and (month = 03 or month = 04 or month = 05)";
                str = str + " and (month(d.ob_dates) = 03 or month(d.ob_dates) = 04 or month(d.ob_dates = 05))";
                break;
            case "\"Summer (Jun, Jul, Aug)\"":
                str = str + " and (month = 06 or month = 07 or month = 08)";
                str = str + " and (month(d.ob_dates) = 06 or month(d.ob_dates) = 07 or month(d.ob_dates = 08))";
                break;
            case "\"Autumn (Sep, Oct, Nov)\"":
                str = str + " and (month = 09 or month = 10 or month = 11)";
                str = str + " and (month(d.ob_dates) = 09 or month(d.ob_dates) = 10 or month(d.ob_dates = 11))";
                break;
            default:
                break;
        }
        //Month
        switch(month_name) {
            case "\"January\"":
                str = str + " and month = 01";
                break;
            case "\"February\"":
                str = str + " and month = 02";
                break;
            case "\"March\"":
                str = str + " and month = 03";
                break;
            case "\"April\"":
                str = str + " and month = 04";
                break;
            case "\"May\"":
                str = str + " and month = 05";
                break;
            case "\"June\"":
                str = str + " and month = 06";
                break;
            case "\"July\"":
                str = str + " and month = 07";
                break;
            case "\"August\"":
                str = str + " and month = 08";
                break;
            case "\"September\"":
                str = str + " and month = 09";
                break;
            case "\"October\"":
                str = str + " and month = 10";
                break;
            case "\"November\"":
                str = str + " and month = 11";
                break;
            case "\"December\"":
                str = str + " and month = 12";
                break;
        }
        //POcode
        switch(poCode){
            case "\"1\"":
                str = str + " and POCode = 1";
                break;
            case "\"2\"":
                str = str + " and POCode = 2";
                break;
            case "\"3\"":
                str = str + " and POCode = 3";
                break;
            case "\"4\"":
                str = str + " and POCode = 4";
                break;
            case "\"5\"":
                str = str + " and POCode = 5";
                break;
            case "\"6\"":
                str = str + " and POCode = 6";
                break;
            case "\"7\"":
                str = str + " and POCode = 7";
                break;
            case "\"8\"":
                str = str + " and POCode = 8";
                break;
            case "\"9\"":
                str = str + " and POCode = 9";
                break;
            case "\"10\"":
                str = str + " and POCode = 10";
                break;
            case "\"11\"":
                str = str + " and POCode = 11";
                break;
            case "\"12\"":
                str = str + " and POCode = 12";
                break;           
        }
        //Latitude and Longitude
        if (!lat1.equals("") && !lat2.equals("")) {
            str = str + " and d.lat BETWEEN " + lat1 + " and " + lat2;
        }
        if (!lon1.equals("") && !lon2.equals("")) {
            str = str + " and d.lon BETWEEN " + lon1 + " and " + lon2;
        }
        
        //Site Landuse
        switch(loc_setting) {
            case "\"Rural\"":
                str = str + " and s.loc_setting=\'RURAL'";
                break;
            case "\"Suburban\"":
                str = str + " and s.loc_setting=\'SUBURBAN'";
                break;
            case "\"Urban\"":
                str = str + " and s.loc_setting=\'URBAN AND CENTER CITY'";
                break;
        }
        
        //Custom MySQL Query
        if (!custom_query.equals("")){
            str = str + custom_query;
        } 
        
        //AQS co-Network
       if (co_network.equals("\"IMPROVE\"")){
           str = str + "and s.co_network LIKE \'%IMPROVE%\'";
       }
       if (co_network.equals("\"CSN\"")){
           str = str + "and s.co_network LIKE \'%CSN%\'";
       }
       if (co_network.equals("\"CASTNET\"")){
           str = str + "and s.co_network LIKE \'%CASTNET%\'";
       }
        query = str;
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
        AQFormTabbedPane = new javax.swing.JTabbedPane();
        AQFormTabbedPane.setBorder(null);
        DatabaseProjectTab = new javax.swing.JPanel();
        SelectDatabaseLabel = new javax.swing.JLabel();
        SelectDatabaseComboBox = new javax.swing.JComboBox<>();
        SelectProjectLabel = new javax.swing.JLabel();
        SelectProjectComboBox = new javax.swing.JComboBox<>();
        SelectAdditionalProjectLabel = new javax.swing.JLabel();
        SelectAdditionalProjectComboBox1 = new javax.swing.JComboBox<>();
        SelectAdditionalProjectComboBox2 = new javax.swing.JComboBox<>();
        SelectAdditionalProjectComboBox3 = new javax.swing.JComboBox<>();
        SelectAdditionalProjectComboBox4 = new javax.swing.JComboBox<>();
        SelectAdditionalProjectComboBox5 = new javax.swing.JComboBox<>();
        SelectAdditionalProjectComboBox6 = new javax.swing.JComboBox<>();
        ProjectDetailsLabel = new javax.swing.JLabel();
        ProjectDetailsScrollPane = new javax.swing.JScrollPane();
        ProjectDetailsTextArea = new javax.swing.JTextArea();
        Left1 = new javax.swing.JPanel();
        RegionAreaTab = new javax.swing.JPanel();
        StateLabel = new javax.swing.JLabel();
        StateInfoLabel = new javax.swing.JLabel();
        StateComboBox = new javax.swing.JComboBox<>();
        ClimateLabel = new javax.swing.JLabel();
        ClimateInfoLabel = new javax.swing.JLabel();
        ClimateComboBox = new javax.swing.JComboBox<>();
        WorldLabel = new javax.swing.JLabel();
        WorldInfoLabel = new javax.swing.JLabel();
        WorldComboBox = new javax.swing.JComboBox<>();
        DiscoverAQLabel = new javax.swing.JLabel();
        DiscoverAQComboBox = new javax.swing.JComboBox<>();
        SiteLanduseLabel = new javax.swing.JLabel();
        SiteLanduseTextArea = new javax.swing.JTextArea();
        SiteLanduseComboBox = new javax.swing.JComboBox<>();
        SubsetLabel = new javax.swing.JLabel();
        SubsetComboBox = new javax.swing.JComboBox<>();
        RPOLabel = new javax.swing.JLabel();
        RPOInfoLabel = new javax.swing.JLabel();
        RPOComboBox = new javax.swing.JComboBox<>();
        PCALabel = new javax.swing.JLabel();
        PCAInfoLabel = new javax.swing.JLabel();
        PCAComboBox = new javax.swing.JComboBox<>();
        OzoneMapButton = new javax.swing.JButton();
        AerosolMapButton = new javax.swing.JButton();
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
        Left2 = new javax.swing.JPanel();
        SiteIDTab = new javax.swing.JPanel();
        SiteIDLabel = new javax.swing.JLabel();
        SiteIDTextArea = new javax.swing.JTextArea();
        SiteIDTextField = new javax.swing.JTextField();
        Left3 = new javax.swing.JPanel();
        CustomMySQLQueryLabel1 = new javax.swing.JLabel();
        CustomMySQLQueryTextField = new javax.swing.JTextField();
        CustomMySQLQueryInfoLabel1 = new javax.swing.JTextArea();
        CustomMySQLQueryExampleLabel = new javax.swing.JTextArea();
        CustomMySQLQueryInfoLabel2 = new javax.swing.JTextArea();
        CustomGraphTitleLabel = new javax.swing.JLabel();
        CustomGraphTitleTextField = new javax.swing.JTextField();
        CustomDirectoryNameLabel = new javax.swing.JLabel();
        CustomDirectoryNameTextField = new javax.swing.JTextField();
        ClearFilesLabel = new javax.swing.JLabel();
        ClearFilesTextField = new javax.swing.JTextField();
        ClearFilesButton = new javax.swing.JButton();
        CustomGraphTitleLabel1 = new javax.swing.JLabel();
        AQSiteFinderButton = new javax.swing.JButton();
        SiteIDTextArea2 = new javax.swing.JTextArea();
        AQNetworkSpeciesTab = new javax.swing.JPanel();
        AQNetworkPanel = new javax.swing.JPanel();
        AQNetworkLabel = new javax.swing.JLabel();
        AQNetworkInfoLabel = new javax.swing.JLabel();
        IMPROVECheckBox = new javax.swing.JCheckBox();
        CSNCheckBox = new javax.swing.JCheckBox();
        CASTNetCheckBox = new javax.swing.JCheckBox();
        CASTNetHourlyCheckBox = new javax.swing.JCheckBox();
        CASTNetDailyCheckBox = new javax.swing.JCheckBox();
        CASTNetDryDepCheckBox = new javax.swing.JCheckBox();
        CAPMoNCheckBox = new javax.swing.JCheckBox();
        NAPSHourlyCheckBox = new javax.swing.JCheckBox();
        NAPSDailyO3CheckBox = new javax.swing.JCheckBox();
        NADPCheckBox = new javax.swing.JCheckBox();
        AMONCheckBox = new javax.swing.JCheckBox();
        AIRMONCheckBox = new javax.swing.JCheckBox();
        AERONETCheckBox = new javax.swing.JCheckBox();
        FluxNetCheckBox = new javax.swing.JCheckBox();
        NOAAESRLCheckBox = new javax.swing.JCheckBox();
        AQSHourlyCheckBox = new javax.swing.JCheckBox();
        AQSDailyO3CheckBox = new javax.swing.JCheckBox();
        AQSDailyCheckBox = new javax.swing.JCheckBox();
        AQSDailyOAQPSCheckBox = new javax.swing.JCheckBox();
        AQSDailyDailyO3OldCheckBox = new javax.swing.JCheckBox();
        AQSDailyOldCheckBox = new javax.swing.JCheckBox();
        SEARCHHourlyCheckBox = new javax.swing.JCheckBox();
        SEARCHDailyCheckBox = new javax.swing.JCheckBox();
        TOARCheckBox = new javax.swing.JCheckBox();
        MDNCheckBox = new javax.swing.JCheckBox();
        ToxicsCheckBox = new javax.swing.JCheckBox();
        ModelModelCheckBox = new javax.swing.JCheckBox();
        SpeciesLabel1 = new javax.swing.JLabel();
        SpeciesComboBox1 = new javax.swing.JComboBox<>();
        AdvancedSpeciesButton1 = new javax.swing.JButton();
        Left4 = new javax.swing.JPanel();
        EuropeanNetworkTab = new javax.swing.JPanel();
        EuropeanNetworkPanel = new javax.swing.JPanel();
        EuropeanNetworkLabel = new javax.swing.JLabel();
        EuropeanNetworkInfoLabel = new javax.swing.JLabel();
        ADMNCheckBox = new javax.swing.JCheckBox();
        AGANETCheckBox = new javax.swing.JCheckBox();
        AirBaseHourlyCheckBox = new javax.swing.JCheckBox();
        AirBaseDailyCheckBox = new javax.swing.JCheckBox();
        AURNHourlyCheckBox = new javax.swing.JCheckBox();
        AURNDailyCheckBox = new javax.swing.JCheckBox();
        EMEPHourlyCheckBox = new javax.swing.JCheckBox();
        EMEPDailyCheckBox = new javax.swing.JCheckBox();
        EMEPDailyO3CheckBox = new javax.swing.JCheckBox();
        CampainsPanel = new javax.swing.JPanel();
        CampainsLabel = new javax.swing.JLabel();
        CALNEXCheckBox = new javax.swing.JCheckBox();
        SOASCheckBox = new javax.swing.JCheckBox();
        SpecialCheckBox = new javax.swing.JCheckBox();
        SpeciesPanel = new javax.swing.JPanel();
        SpeciesLabel2 = new javax.swing.JLabel();
        SpeciesComboBox2 = new javax.swing.JComboBox<>();
        AdvancedSpeciesButton2 = new javax.swing.JButton();
        Left5 = new javax.swing.JPanel();
        DateTimeTab = new javax.swing.JPanel();
        DateRangeLabel = new javax.swing.JLabel();
        DateRangePanel = new javax.swing.JPanel();
        StartDateLabel = new javax.swing.JLabel();
        StartDatePicker = new com.github.lgooddatepicker.components.DatePicker();
        EndDateLabel = new javax.swing.JLabel();
        EndDatePicker = new com.github.lgooddatepicker.components.DatePicker();
        HourRangeLabel = new javax.swing.JLabel();
        HourRangeTextArea = new javax.swing.JTextArea();
        HourRangePanel = new javax.swing.JPanel();
        StartHourLabel = new javax.swing.JLabel();
        StartHourComboBox = new javax.swing.JComboBox<>();
        EndHourLabel = new javax.swing.JLabel();
        EndHourComboBox = new javax.swing.JComboBox<>();
        SeasonalLabel = new javax.swing.JLabel();
        SeasonalTextArea = new javax.swing.JTextArea();
        SeasonalComboBox = new javax.swing.JComboBox<>();
        MonthlyLabel = new javax.swing.JLabel();
        MonthlyTextArea = new javax.swing.JTextArea();
        MonthlyComboBox = new javax.swing.JComboBox<>();
        POCodeLabel = new javax.swing.JLabel();
        POCodeTextArea = new javax.swing.JTextArea();
        POCodeComboBox = new javax.swing.JComboBox<>();
        Left6 = new javax.swing.JPanel();
        jPanel1 = new javax.swing.JPanel();
        NegativeValuesLabel = new javax.swing.JLabel();
        NegativeValuesTextArea = new javax.swing.JTextArea();
        NegativeValuesComboBox = new javax.swing.JComboBox<>();
        AggregateDataLabel = new javax.swing.JLabel();
        AggregateDataTextArea = new javax.swing.JTextArea();
        AggregateDataCheckBox = new javax.swing.JCheckBox();
        TemporalAveragingLabel = new javax.swing.JLabel();
        TemporalAveragingTextArea = new javax.swing.JTextArea();
        TemporalAveragingComboBox = new javax.swing.JComboBox<>();
        ProgramTab = new javax.swing.JPanel();
        PlotlyImageLabel = new javax.swing.JLabel();
        PlotlyIamgeInfoTextArea = new javax.swing.JTextArea();
        PlotlyImagePanel = new javax.swing.JPanel();
        HeightLabel = new javax.swing.JLabel();
        HeightTextField = new javax.swing.JTextField();
        WidthLabel = new javax.swing.JLabel();
        WidthTextField = new javax.swing.JTextField();
        PNGQualityLabel = new javax.swing.JLabel();
        PNGQualityTextArea = new javax.swing.JTextArea();
        PNGQualityComboBox = new javax.swing.JComboBox<>();
        AdvancedPlotLabel = new javax.swing.JLabel();
        DataFormattingLabel = new javax.swing.JLabel();
        SoccergoalBuglePlotButton = new javax.swing.JButton();
        AxisOptionsButton = new javax.swing.JButton();
        ScatterPlotButton = new javax.swing.JButton();
        ModelEvalOptionsButton = new javax.swing.JButton();
        OverlayFileButton = new javax.swing.JButton();
        SpatialPlotButton = new javax.swing.JButton();
        RunProgramButton = new javax.swing.JButton();
        Left7 = new javax.swing.JPanel();
        ProgramLabel = new javax.swing.JLabel();
        ProgramTextArea = new javax.swing.JTextArea();
        ProgramComboBox = new javax.swing.JComboBox<>();
        Back = new javax.swing.JPanel();
        Left8 = new javax.swing.JPanel();
        ReturnButton = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setTitle("Air Quality Form");
        setBackground(new java.awt.Color(255, 255, 255));
        setMaximumSize(new java.awt.Dimension(999, 753));
        setMinimumSize(new java.awt.Dimension(999, 728));
        setPreferredSize(new java.awt.Dimension(999, 753));
        setResizable(false);

        Header.setIcon(new javax.swing.ImageIcon(getClass().getResource("/Pictures/top_2022.png"))); // NOI18N
        Header.setAlignmentY(0.0F);
        Header.setBackground(new java.awt.Color(255, 255, 255));
        Header.setForeground(new java.awt.Color(255, 255, 255));
        Header.setIconTextGap(0);
        Header.setPreferredSize(new java.awt.Dimension(1000, 94));

        Footer.setIcon(new javax.swing.ImageIcon(getClass().getResource("/Pictures/bottom_2022.png"))); // NOI18N
        Footer.setAlignmentY(0.0F);
        Footer.setBackground(new java.awt.Color(255, 255, 255));
        Footer.setForeground(new java.awt.Color(255, 255, 255));
        Footer.setIconTextGap(0);
        Footer.setToolTipText("");

        AQFormTabbedPane.setBackground(new java.awt.Color(38, 161, 70));
        AQFormTabbedPane.setForeground(new java.awt.Color(0, 63, 105));
        AQFormTabbedPane.setTabLayoutPolicy(javax.swing.JTabbedPane.SCROLL_TAB_LAYOUT);
        AQFormTabbedPane.setAlignmentX(0.0F);
        AQFormTabbedPane.setAlignmentY(0.0F);
        AQFormTabbedPane.setFont(new java.awt.Font("Times New Roman", 1, 13)); // NOI18N
        AQFormTabbedPane.setInheritsPopupMenu(true);
        AQFormTabbedPane.setMaximumSize(new java.awt.Dimension(999, 550));
        AQFormTabbedPane.setMinimumSize(new java.awt.Dimension(999, 550));
        AQFormTabbedPane.setPreferredSize(new java.awt.Dimension(999, 576));

        DatabaseProjectTab.setBackground(new java.awt.Color(255, 255, 255));
        DatabaseProjectTab.setFont(new java.awt.Font("Times New Roman", 0, 12)); // NOI18N
        DatabaseProjectTab.setForeground(new java.awt.Color(0, 112, 185));
        DatabaseProjectTab.setMaximumSize(new java.awt.Dimension(999, 573));
        DatabaseProjectTab.setMinimumSize(new java.awt.Dimension(999, 573));
        DatabaseProjectTab.setPreferredSize(new java.awt.Dimension(999, 573));

        SelectDatabaseLabel.setText("Select a Database");
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

        SelectProjectLabel.setText("Select a Project");
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

        SelectAdditionalProjectLabel.setText("Select Additional Projects");
        SelectAdditionalProjectLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        SelectAdditionalProjectLabel.setForeground(new java.awt.Color(0, 112, 185));

        SelectAdditionalProjectComboBox1.setBackground(new java.awt.Color(191, 182, 172));
        SelectAdditionalProjectComboBox1.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SelectAdditionalProjectComboBox1.setForeground(new java.awt.Color(0, 63, 105));
        SelectAdditionalProjectComboBox1.setMinimumSize(new java.awt.Dimension(407, 23));
        SelectAdditionalProjectComboBox1.setPreferredSize(new java.awt.Dimension(407, 23));

        SelectAdditionalProjectComboBox2.setBackground(new java.awt.Color(191, 182, 172));
        SelectAdditionalProjectComboBox2.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SelectAdditionalProjectComboBox2.setForeground(new java.awt.Color(0, 63, 105));
        SelectAdditionalProjectComboBox2.setMinimumSize(new java.awt.Dimension(407, 23));
        SelectAdditionalProjectComboBox2.setPreferredSize(new java.awt.Dimension(407, 23));

        SelectAdditionalProjectComboBox3.setBackground(new java.awt.Color(191, 182, 172));
        SelectAdditionalProjectComboBox3.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SelectAdditionalProjectComboBox3.setForeground(new java.awt.Color(0, 63, 105));
        SelectAdditionalProjectComboBox3.setMinimumSize(new java.awt.Dimension(407, 23));
        SelectAdditionalProjectComboBox3.setPreferredSize(new java.awt.Dimension(407, 23));

        SelectAdditionalProjectComboBox4.setBackground(new java.awt.Color(191, 182, 172));
        SelectAdditionalProjectComboBox4.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SelectAdditionalProjectComboBox4.setForeground(new java.awt.Color(0, 63, 105));
        SelectAdditionalProjectComboBox4.setMinimumSize(new java.awt.Dimension(407, 23));
        SelectAdditionalProjectComboBox4.setPreferredSize(new java.awt.Dimension(407, 23));

        SelectAdditionalProjectComboBox5.setBackground(new java.awt.Color(191, 182, 172));
        SelectAdditionalProjectComboBox5.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SelectAdditionalProjectComboBox5.setForeground(new java.awt.Color(0, 63, 105));
        SelectAdditionalProjectComboBox5.setMinimumSize(new java.awt.Dimension(407, 23));
        SelectAdditionalProjectComboBox5.setPreferredSize(new java.awt.Dimension(407, 23));

        SelectAdditionalProjectComboBox6.setBackground(new java.awt.Color(191, 182, 172));
        SelectAdditionalProjectComboBox6.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SelectAdditionalProjectComboBox6.setForeground(new java.awt.Color(0, 63, 105));
        SelectAdditionalProjectComboBox6.setMinimumSize(new java.awt.Dimension(407, 23));
        SelectAdditionalProjectComboBox6.setPreferredSize(new java.awt.Dimension(407, 23));

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
        ProjectDetailsTextArea.setForeground(new java.awt.Color(0, 112, 185));
        ProjectDetailsScrollPane.setViewportView(ProjectDetailsTextArea);

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
            .addGap(0, 0, Short.MAX_VALUE)
        );

        javax.swing.GroupLayout DatabaseProjectTabLayout = new javax.swing.GroupLayout(DatabaseProjectTab);
        DatabaseProjectTab.setLayout(DatabaseProjectTabLayout);
        DatabaseProjectTabLayout.setHorizontalGroup(
            DatabaseProjectTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, DatabaseProjectTabLayout.createSequentialGroup()
                .addComponent(Left1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addGroup(DatabaseProjectTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(SelectDatabaseLabel)
                    .addGroup(DatabaseProjectTabLayout.createSequentialGroup()
                        .addGroup(DatabaseProjectTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(SelectProjectLabel)
                            .addComponent(SelectAdditionalProjectLabel)
                            .addGroup(DatabaseProjectTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                                .addComponent(SelectAdditionalProjectComboBox6, javax.swing.GroupLayout.Alignment.LEADING, 0, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addComponent(SelectAdditionalProjectComboBox5, javax.swing.GroupLayout.Alignment.LEADING, 0, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addComponent(SelectAdditionalProjectComboBox4, javax.swing.GroupLayout.Alignment.LEADING, 0, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addComponent(SelectAdditionalProjectComboBox3, javax.swing.GroupLayout.Alignment.LEADING, 0, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addComponent(SelectAdditionalProjectComboBox2, javax.swing.GroupLayout.Alignment.LEADING, 0, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addComponent(SelectAdditionalProjectComboBox1, javax.swing.GroupLayout.Alignment.LEADING, 0, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addComponent(SelectProjectComboBox, 0, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                        .addGap(60, 60, 60)
                        .addGroup(DatabaseProjectTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(ProjectDetailsLabel)
                            .addComponent(ProjectDetailsScrollPane, javax.swing.GroupLayout.PREFERRED_SIZE, 451, javax.swing.GroupLayout.PREFERRED_SIZE)))
                    .addComponent(SelectDatabaseComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 407, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addContainerGap(21, Short.MAX_VALUE))
        );
        DatabaseProjectTabLayout.setVerticalGroup(
            DatabaseProjectTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(DatabaseProjectTabLayout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addGroup(DatabaseProjectTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(DatabaseProjectTabLayout.createSequentialGroup()
                        .addComponent(SelectDatabaseLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(SelectDatabaseComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SelectProjectLabel)
                        .addGap(12, 12, 12)
                        .addComponent(SelectProjectComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SelectAdditionalProjectLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(SelectAdditionalProjectComboBox1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SelectAdditionalProjectComboBox2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SelectAdditionalProjectComboBox3, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SelectAdditionalProjectComboBox4, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SelectAdditionalProjectComboBox5, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SelectAdditionalProjectComboBox6, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, DatabaseProjectTabLayout.createSequentialGroup()
                        .addComponent(ProjectDetailsLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ProjectDetailsScrollPane, javax.swing.GroupLayout.PREFERRED_SIZE, 279, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap(121, Short.MAX_VALUE))
            .addComponent(Left1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );

        AQFormTabbedPane.addTab("Database/Project", DatabaseProjectTab);

        RegionAreaTab.setBackground(new java.awt.Color(255, 255, 255));
        RegionAreaTab.setForeground(new java.awt.Color(255, 255, 255));
        RegionAreaTab.setMinimumSize(new java.awt.Dimension(999, 573));
        RegionAreaTab.setPreferredSize(new java.awt.Dimension(999, 573));

        StateLabel.setText("State");
        StateLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
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

        ClimateLabel.setText("Climate Regions");
        ClimateLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        ClimateLabel.setForeground(new java.awt.Color(0, 112, 185));

        ClimateInfoLabel.setText("Isolate an evaluation dataset by climate region");
        ClimateInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        ClimateInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        ClimateComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "None", "Central", "East-North Central", "Northeast", "Northwest", "South", "Southeast", "Southwest", "West", "West-North Central" }));
        ClimateComboBox.setBackground(new java.awt.Color(191, 182, 172));
        ClimateComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ClimateComboBox.setForeground(new java.awt.Color(0, 63, 105));

        WorldLabel.setText("World Regions");
        WorldLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        WorldLabel.setForeground(new java.awt.Color(0, 112, 185));

        WorldInfoLabel.setText("Isolate an evaluation dataset by continent");
        WorldInfoLabel.setAlignmentX(0.5F);
        WorldInfoLabel.setBackground(new java.awt.Color(255, 255, 255));
        WorldInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        WorldInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        WorldComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "None", "North America", "U.S. & Canada", "South America", "Europe", "Asia" }));
        WorldComboBox.setBackground(new java.awt.Color(191, 182, 172));
        WorldComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        WorldComboBox.setForeground(new java.awt.Color(0, 63, 105));

        DiscoverAQLabel.setText("Discover-AQ 4-km and 1-km Windows");
        DiscoverAQLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        DiscoverAQLabel.setForeground(new java.awt.Color(0, 112, 185));

        DiscoverAQComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "None", "4-km Window", "1-km Window", "2-km Window SJV" }));
        DiscoverAQComboBox.setBackground(new java.awt.Color(191, 182, 172));
        DiscoverAQComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        DiscoverAQComboBox.setForeground(new java.awt.Color(0, 63, 105));

        SiteLanduseLabel.setText("Site Land Use");
        SiteLanduseLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        SiteLanduseLabel.setForeground(new java.awt.Color(0, 112, 185));

        SiteLanduseTextArea.setColumns(20);
        SiteLanduseTextArea.setEditable(false);
        SiteLanduseTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SiteLanduseTextArea.setLineWrap(true);
        SiteLanduseTextArea.setRows(5);
        SiteLanduseTextArea.setText("Isolate AQS evaluation data by whether the site location setting is described as rural, suburban, or urban. ");
        SiteLanduseTextArea.setWrapStyleWord(true);
        SiteLanduseTextArea.setBackground(new java.awt.Color(255, 255, 255));
        SiteLanduseTextArea.setForeground(new java.awt.Color(0, 112, 185));

        SiteLanduseComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "None", "Rural", "Suburban", "Urban" }));
        SiteLanduseComboBox.setBackground(new java.awt.Color(191, 182, 172));
        SiteLanduseComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SiteLanduseComboBox.setForeground(new java.awt.Color(0, 63, 105));

        SubsetLabel.setText("Subset by AQS co-Network");
        SubsetLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        SubsetLabel.setForeground(new java.awt.Color(0, 112, 185));

        SubsetComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "None", "IMPROVE", "CSN", "CASTNET" }));
        SubsetComboBox.setBackground(new java.awt.Color(191, 182, 172));
        SubsetComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SubsetComboBox.setForeground(new java.awt.Color(0, 63, 105));

        RPOLabel.setText("Regional Planning Organizations (RPO) Regions");
        RPOLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        RPOLabel.setForeground(new java.awt.Color(0, 112, 185));

        RPOInfoLabel.setText("Isolate an evaluation dataset by a RPO region");
        RPOInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        RPOInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        RPOComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "None", "VISTAS", "CENRAP", "MANE-VU", "LADCO", "WRAP" }));
        RPOComboBox.setBackground(new java.awt.Color(191, 182, 172));
        RPOComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        RPOComboBox.setForeground(new java.awt.Color(0, 63, 105));

        PCALabel.setText("Principal Component Analysis (PCA) Regions");
        PCALabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        PCALabel.setForeground(new java.awt.Color(0, 112, 185));

        PCAInfoLabel.setText("Isolate an evaluation dataset by PCA region");
        PCAInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        PCAInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        PCAComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "None", "Northeast (Ozone)", "Great Lakes (Ozone)", "Mid-Atlantic (Ozone)", "Southwest (Ozone)", "Northeast (Aerosols)", "Great Lakes (Aerosols)", "Southeast (Aerosols)", "Lower Midwest (Aerosols)", "West (Aerosols)" }));
        PCAComboBox.setBackground(new java.awt.Color(191, 182, 172));
        PCAComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        PCAComboBox.setForeground(new java.awt.Color(0, 63, 105));

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

        LatLonLabel.setText("Latitude and Longitude");
        LatLonLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        LatLonLabel.setForeground(new java.awt.Color(0, 112, 185));

        LatLonTextArea.setColumns(20);
        LatLonTextArea.setEditable(false);
        LatLonTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        LatLonTextArea.setLineWrap(true);
        LatLonTextArea.setRows(5);
        LatLonTextArea.setText("Specify bounds on the evaluation data to examine. Latitudes must be given South to North, and Longitudes must be given West to East. ");
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

        LatTextField1.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        LatTextField1.setBackground(new java.awt.Color(191, 182, 172));
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

        Left2.setBackground(new java.awt.Color(174, 211, 232));
        Left2.setPreferredSize(new java.awt.Dimension(24, 543));

        javax.swing.GroupLayout Left2Layout = new javax.swing.GroupLayout(Left2);
        Left2.setLayout(Left2Layout);
        Left2Layout.setHorizontalGroup(
            Left2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 24, Short.MAX_VALUE)
        );
        Left2Layout.setVerticalGroup(
            Left2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 0, Short.MAX_VALUE)
        );

        javax.swing.GroupLayout RegionAreaTabLayout = new javax.swing.GroupLayout(RegionAreaTab);
        RegionAreaTab.setLayout(RegionAreaTabLayout);
        RegionAreaTabLayout.setHorizontalGroup(
            RegionAreaTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(RegionAreaTabLayout.createSequentialGroup()
                .addComponent(Left2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addGroup(RegionAreaTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(SiteLanduseLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(SiteLanduseTextArea)
                    .addComponent(StateLabel)
                    .addComponent(ClimateLabel)
                    .addComponent(WorldLabel)
                    .addComponent(DiscoverAQLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addGroup(RegionAreaTabLayout.createSequentialGroup()
                        .addGap(6, 6, 6)
                        .addGroup(RegionAreaTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addGroup(RegionAreaTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                .addComponent(WorldInfoLabel, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                .addComponent(ClimateInfoLabel, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                .addComponent(StateInfoLabel, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                .addGroup(RegionAreaTabLayout.createSequentialGroup()
                                    .addGroup(RegionAreaTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                        .addComponent(StateComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)
                                        .addComponent(ClimateComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)
                                        .addComponent(WorldComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)
                                        .addComponent(DiscoverAQComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE))
                                    .addGap(0, 0, Short.MAX_VALUE)))
                            .addComponent(SiteLanduseComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE))))
                .addGroup(RegionAreaTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(RegionAreaTabLayout.createSequentialGroup()
                        .addGap(125, 125, 125)
                        .addGroup(RegionAreaTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addGroup(RegionAreaTabLayout.createSequentialGroup()
                                .addGap(6, 6, 6)
                                .addComponent(SubsetComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addGap(0, 0, Short.MAX_VALUE))
                            .addGroup(RegionAreaTabLayout.createSequentialGroup()
                                .addComponent(SubsetLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                .addGap(287, 287, 287))
                            .addGroup(RegionAreaTabLayout.createSequentialGroup()
                                .addGroup(RegionAreaTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addGroup(RegionAreaTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                        .addComponent(PCALabel)
                                        .addGroup(RegionAreaTabLayout.createSequentialGroup()
                                            .addGap(6, 6, 6)
                                            .addComponent(LatLonPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                                        .addComponent(LatLonLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 218, javax.swing.GroupLayout.PREFERRED_SIZE)
                                        .addComponent(LatLonTextArea, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 412, javax.swing.GroupLayout.PREFERRED_SIZE))
                                    .addComponent(PCAInfoLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 412, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(RPOInfoLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 412, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addGroup(RegionAreaTabLayout.createSequentialGroup()
                                        .addGap(6, 6, 6)
                                        .addGroup(RegionAreaTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                            .addComponent(RPOComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)
                                            .addComponent(PCAComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)))
                                    .addComponent(RPOLabel))
                                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, RegionAreaTabLayout.createSequentialGroup()
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addGroup(RegionAreaTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(AerosolMapButton, javax.swing.GroupLayout.PREFERRED_SIZE, 274, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(OzoneMapButton, javax.swing.GroupLayout.PREFERRED_SIZE, 274, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addGap(200, 200, 200))))
        );
        RegionAreaTabLayout.setVerticalGroup(
            RegionAreaTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(RegionAreaTabLayout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addGroup(RegionAreaTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(StateLabel)
                    .addComponent(SubsetLabel))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(RegionAreaTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(RegionAreaTabLayout.createSequentialGroup()
                        .addGap(6, 6, 6)
                        .addComponent(SubsetComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(RPOLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(RPOInfoLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(RPOComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(PCALabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(PCAInfoLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(PCAComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(AerosolMapButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(OzoneMapButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(LatLonLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(LatLonPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(LatLonTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 52, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(RegionAreaTabLayout.createSequentialGroup()
                        .addComponent(StateInfoLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(StateComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(ClimateLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(ClimateInfoLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ClimateComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(WorldLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(WorldInfoLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(WorldComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(DiscoverAQLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(DiscoverAQComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SiteLanduseLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(SiteLanduseTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 54, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(SiteLanduseComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap(58, Short.MAX_VALUE))
            .addComponent(Left2, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );

        AQFormTabbedPane.addTab("Region/Area", RegionAreaTab);

        SiteIDTab.setBackground(new java.awt.Color(255, 255, 255));
        SiteIDTab.setForeground(new java.awt.Color(255, 255, 255));
        SiteIDTab.setMinimumSize(new java.awt.Dimension(999, 573));
        SiteIDTab.setPreferredSize(new java.awt.Dimension(999, 573));

        SiteIDLabel.setText("Site ID");
        SiteIDLabel.setBackground(new java.awt.Color(255, 255, 255));
        SiteIDLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        SiteIDLabel.setForeground(new java.awt.Color(0, 112, 185));

        SiteIDTextArea.setColumns(20);
        SiteIDTextArea.setEditable(false);
        SiteIDTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SiteIDTextArea.setLineWrap(true);
        SiteIDTextArea.setRows(5);
        SiteIDTextArea.setText("Manually enter the Site ID for a single observation site.  For time series plot, if Site ID is left blank, all stations for each network will be used.");
        SiteIDTextArea.setWrapStyleWord(true);
        SiteIDTextArea.setBackground(new java.awt.Color(255, 255, 255));
        SiteIDTextArea.setForeground(new java.awt.Color(0, 112, 185));
        SiteIDTextArea.setPreferredSize(new java.awt.Dimension(372, 52));

        SiteIDTextField.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SiteIDTextField.setBackground(new java.awt.Color(191, 182, 172));
        SiteIDTextField.setForeground(new java.awt.Color(0, 63, 105));
        SiteIDTextField.setMinimumSize(new java.awt.Dimension(232, 22));
        SiteIDTextField.setPreferredSize(new java.awt.Dimension(232, 22));

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
            .addGap(0, 593, Short.MAX_VALUE)
        );

        CustomMySQLQueryLabel1.setText("Add Custom MySQL Query");
        CustomMySQLQueryLabel1.setBackground(new java.awt.Color(255, 255, 255));
        CustomMySQLQueryLabel1.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        CustomMySQLQueryLabel1.setForeground(new java.awt.Color(0, 112, 185));

        CustomMySQLQueryTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        CustomMySQLQueryTextField.setBackground(new java.awt.Color(191, 182, 172));
        CustomMySQLQueryTextField.setForeground(new java.awt.Color(0, 63, 105));
        CustomMySQLQueryTextField.setMinimumSize(new java.awt.Dimension(400, 23));
        CustomMySQLQueryTextField.setPreferredSize(new java.awt.Dimension(400, 23));

        CustomMySQLQueryInfoLabel1.setColumns(20);
        CustomMySQLQueryInfoLabel1.setEditable(false);
        CustomMySQLQueryInfoLabel1.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        CustomMySQLQueryInfoLabel1.setLineWrap(true);
        CustomMySQLQueryInfoLabel1.setRows(5);
        CustomMySQLQueryInfoLabel1.setText("Use the box above to create your own custom MySQL query. The Query should begin with 'and' and contain valid MySQL query commands. This is an advanced option for users familiar with database structure and queries. An example of a correctly formatted statement is:");
        CustomMySQLQueryInfoLabel1.setWrapStyleWord(true);
        CustomMySQLQueryInfoLabel1.setBackground(new java.awt.Color(255, 255, 255));
        CustomMySQLQueryInfoLabel1.setForeground(new java.awt.Color(0, 112, 185));
        CustomMySQLQueryInfoLabel1.setPreferredSize(new java.awt.Dimension(400, 92));

        CustomMySQLQueryExampleLabel.setColumns(20);
        CustomMySQLQueryExampleLabel.setEditable(false);
        CustomMySQLQueryExampleLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        CustomMySQLQueryExampleLabel.setLineWrap(true);
        CustomMySQLQueryExampleLabel.setRows(5);
        CustomMySQLQueryExampleLabel.setText("and d.SO4_ob > 5 and d.SO4_ob < 10");
        CustomMySQLQueryExampleLabel.setWrapStyleWord(true);
        CustomMySQLQueryExampleLabel.setBackground(new java.awt.Color(255, 255, 255));
        CustomMySQLQueryExampleLabel.setForeground(new java.awt.Color(0, 112, 185));
        CustomMySQLQueryExampleLabel.setMaximumSize(new java.awt.Dimension(400, 20));
        CustomMySQLQueryExampleLabel.setMinimumSize(new java.awt.Dimension(400, 20));
        CustomMySQLQueryExampleLabel.setPreferredSize(new java.awt.Dimension(400, 20));

        CustomMySQLQueryInfoLabel2.setColumns(20);
        CustomMySQLQueryInfoLabel2.setEditable(false);
        CustomMySQLQueryInfoLabel2.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        CustomMySQLQueryInfoLabel2.setLineWrap(true);
        CustomMySQLQueryInfoLabel2.setRows(5);
        CustomMySQLQueryInfoLabel2.setText("The d refers to the main data table where the site compare data are stored. ");
        CustomMySQLQueryInfoLabel2.setWrapStyleWord(true);
        CustomMySQLQueryInfoLabel2.setBackground(new java.awt.Color(255, 255, 255));
        CustomMySQLQueryInfoLabel2.setForeground(new java.awt.Color(0, 112, 185));
        CustomMySQLQueryInfoLabel2.setMaximumSize(new java.awt.Dimension(400, 36));
        CustomMySQLQueryInfoLabel2.setMinimumSize(new java.awt.Dimension(400, 36));
        CustomMySQLQueryInfoLabel2.setPreferredSize(new java.awt.Dimension(400, 36));

        CustomGraphTitleLabel.setText("Custom Graph Title");
        CustomGraphTitleLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        CustomGraphTitleLabel.setForeground(new java.awt.Color(0, 112, 185));

        CustomGraphTitleTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        CustomGraphTitleTextField.setBackground(new java.awt.Color(191, 182, 172));
        CustomGraphTitleTextField.setForeground(new java.awt.Color(0, 63, 105));
        CustomGraphTitleTextField.setMinimumSize(new java.awt.Dimension(548, 23));
        CustomGraphTitleTextField.setPreferredSize(new java.awt.Dimension(548, 23));

        CustomDirectoryNameLabel.setText("Custom Directory Name");
        CustomDirectoryNameLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        CustomDirectoryNameLabel.setForeground(new java.awt.Color(0, 112, 185));

        CustomDirectoryNameTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        CustomDirectoryNameTextField.setBackground(new java.awt.Color(191, 182, 172));
        CustomDirectoryNameTextField.setForeground(new java.awt.Color(0, 63, 105));
        CustomDirectoryNameTextField.setMinimumSize(new java.awt.Dimension(548, 23));
        CustomDirectoryNameTextField.setPreferredSize(new java.awt.Dimension(548, 23));

        ClearFilesLabel.setText("Clear Files from User Cache Directory");
        ClearFilesLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        ClearFilesLabel.setForeground(new java.awt.Color(0, 112, 185));

        ClearFilesTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ClearFilesTextField.setBackground(new java.awt.Color(191, 182, 172));
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

        CustomGraphTitleLabel1.setText("Output Options");
        CustomGraphTitleLabel1.setFont(new java.awt.Font("Times New Roman", 1, 20)); // NOI18N
        CustomGraphTitleLabel1.setForeground(new java.awt.Color(0, 112, 185));

        AQSiteFinderButton.setText("Air Quality Site Finder");
        AQSiteFinderButton.setBackground(new java.awt.Color(0, 63, 105));
        AQSiteFinderButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        AQSiteFinderButton.setForeground(new java.awt.Color(191, 182, 172));
        AQSiteFinderButton.setMaximumSize(new java.awt.Dimension(378, 23));
        AQSiteFinderButton.setPreferredSize(new java.awt.Dimension(130, 23));
        AQSiteFinderButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                AQSiteFinderButtonActionPerformed(evt);
            }
        });

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
                            .addComponent(SiteIDTextField, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(SiteIDTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 372, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(CustomMySQLQueryLabel1)
                            .addGroup(SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                .addComponent(SiteIDTextArea2, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                .addComponent(AQSiteFinderButton, javax.swing.GroupLayout.PREFERRED_SIZE, 400, javax.swing.GroupLayout.PREFERRED_SIZE)))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 61, Short.MAX_VALUE)
                        .addGroup(SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(CustomGraphTitleLabel1)
                            .addGroup(SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                .addComponent(CustomGraphTitleLabel)
                                .addComponent(CustomDirectoryNameLabel)
                                .addComponent(ClearFilesLabel)
                                .addComponent(CustomDirectoryNameTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 0, Short.MAX_VALUE)
                                .addComponent(CustomGraphTitleTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 453, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addComponent(ClearFilesTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 453, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addComponent(ClearFilesButton, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                        .addGap(26, 26, 26))
                    .addGroup(SiteIDTabLayout.createSequentialGroup()
                        .addGroup(SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(CustomMySQLQueryExampleLabel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(CustomMySQLQueryInfoLabel1, javax.swing.GroupLayout.DEFAULT_SIZE, 596, Short.MAX_VALUE)
                            .addComponent(CustomMySQLQueryInfoLabel2, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(CustomMySQLQueryTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 564, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))))
        );
        SiteIDTabLayout.setVerticalGroup(
            SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(SiteIDTabLayout.createSequentialGroup()
                .addComponent(Left3, javax.swing.GroupLayout.PREFERRED_SIZE, 593, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
            .addGroup(SiteIDTabLayout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addGroup(SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(SiteIDTabLayout.createSequentialGroup()
                        .addComponent(CustomGraphTitleLabel1)
                        .addGap(18, 18, 18)
                        .addComponent(CustomGraphTitleLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(CustomGraphTitleTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(CustomDirectoryNameLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(CustomDirectoryNameTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(ClearFilesLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ClearFilesTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(SiteIDTabLayout.createSequentialGroup()
                        .addComponent(SiteIDLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(SiteIDTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 52, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SiteIDTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(30, 30, 30)
                        .addComponent(AQSiteFinderButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(SiteIDTextArea2, javax.swing.GroupLayout.PREFERRED_SIZE, 53, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addGap(18, 18, 18)
                .addGroup(SiteIDTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(ClearFilesButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(CustomMySQLQueryLabel1))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(CustomMySQLQueryTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(CustomMySQLQueryInfoLabel1, javax.swing.GroupLayout.PREFERRED_SIZE, 68, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, 0)
                .addComponent(CustomMySQLQueryExampleLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(CustomMySQLQueryInfoLabel2, javax.swing.GroupLayout.PREFERRED_SIZE, 36, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        AQFormTabbedPane.addTab("Site ID/MySQL Query", SiteIDTab);

        AQNetworkSpeciesTab.setBackground(new java.awt.Color(255, 255, 255));
        AQNetworkSpeciesTab.setForeground(new java.awt.Color(255, 255, 255));
        AQNetworkSpeciesTab.setMinimumSize(new java.awt.Dimension(999, 573));
        AQNetworkSpeciesTab.setPreferredSize(new java.awt.Dimension(999, 573));

        AQNetworkPanel.setBackground(new java.awt.Color(255, 255, 255));
        AQNetworkPanel.setForeground(new java.awt.Color(255, 255, 255));

        AQNetworkLabel.setText("AQ Observation Networks");
        AQNetworkLabel.setBackground(new java.awt.Color(255, 255, 255));
        AQNetworkLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        AQNetworkLabel.setForeground(new java.awt.Color(0, 112, 185));

        AQNetworkInfoLabel.setText("Choose air quality monitoring networks to use:");
        AQNetworkInfoLabel.setBackground(new java.awt.Color(255, 255, 255));
        AQNetworkInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        AQNetworkInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        IMPROVECheckBox.setText(" IMPROVE (e.g. SO4,NO3,PM2.5,EC,OC,TC) ");
        IMPROVECheckBox.setBackground(new java.awt.Color(255, 255, 255));
        IMPROVECheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        IMPROVECheckBox.setForeground(new java.awt.Color(0, 112, 185));

        CSNCheckBox.setText(" CSN (e.g. SO4,NO3,NH4,PM2.5,EC,OC,TC) ");
        CSNCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        CSNCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        CSNCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        CASTNetCheckBox.setText(" CASTNet (e.g. SO4,NO3,NH4,SO2,HNO3,TNO3) ");
        CASTNetCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        CASTNetCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        CASTNetCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        CASTNetHourlyCheckBox.setText(" CASTNet - Hourly (O3, RH, Precip, T, Solor Rad, WSPD, WDIR) ");
        CASTNetHourlyCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        CASTNetHourlyCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        CASTNetHourlyCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        CASTNetDailyCheckBox.setText(" CASTNet Daily (1-hr and 8-hr max O3) ");
        CASTNetDailyCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        CASTNetDailyCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        CASTNetDailyCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        CASTNetDryDepCheckBox.setText(" CASTNet Dry Dep (SO4,NO3,NH4,HNO3,TNO3,O3,SO2) ");
        CASTNetDryDepCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        CASTNetDryDepCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        CASTNetDryDepCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        CAPMoNCheckBox.setText(" CAPMoN (SO4,NO3,NH4,HNO3,TNO3,SO2) ");
        CAPMoNCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        CAPMoNCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        CAPMoNCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        NAPSHourlyCheckBox.setText(" NAPS - Hourly (O3,NO,NO2,NOX,SO2,PM2.5,PM10) ");
        NAPSHourlyCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        NAPSHourlyCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        NAPSHourlyCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        NAPSDailyO3CheckBox.setText(" NAPS - Daily O3 (1-hr and 8-hr max O3) ");
        NAPSDailyO3CheckBox.setBackground(new java.awt.Color(255, 255, 255));
        NAPSDailyO3CheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        NAPSDailyO3CheckBox.setForeground(new java.awt.Color(0, 112, 185));

        NADPCheckBox.setText(" NADP (e.g. SO4,NO3,NH4,Precip, Cl Ion) ");
        NADPCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        NADPCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        NADPCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        AMONCheckBox.setText(" AMON (NH3) ");
        AMONCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AMONCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        AMONCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        AIRMONCheckBox.setText(" AIRMON (Deposition) (SO4,NO3,NH4,Precip) ");
        AIRMONCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AIRMONCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        AIRMONCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        AERONETCheckBox.setText(" AERONET (AOD: 340, 380, 440, 500, 675, 870, 1020, 1640) ");
        AERONETCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AERONETCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        AERONETCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        FluxNetCheckBox.setText(" FluxNet (Soil/Flux variables) ");
        FluxNetCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        FluxNetCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        FluxNetCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        NOAAESRLCheckBox.setText(" NOAA ESRL (Hourly O3) ");
        NOAAESRLCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        NOAAESRLCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        NOAAESRLCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        AQSHourlyCheckBox.setText(" AQS - Hourly (e.g. NO,NO2,NOx,NOy,SO2,CO,PM2.5,O3,etc.) ");
        AQSHourlyCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AQSHourlyCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        AQSHourlyCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        AQSDailyO3CheckBox.setText(" AQS - Daily O3 (1-hr and 8-hr max O3) ");
        AQSDailyO3CheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AQSDailyO3CheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        AQSDailyO3CheckBox.setForeground(new java.awt.Color(0, 112, 185));

        AQSDailyCheckBox.setText(" AQS - Daily (e.g. PM2.5,PM10, and PAMS species) ");
        AQSDailyCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AQSDailyCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        AQSDailyCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        AQSDailyOAQPSCheckBox.setText(" AQS - Daily OAQPS O3 (Various 8-hr max O3) ");
        AQSDailyOAQPSCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AQSDailyOAQPSCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        AQSDailyOAQPSCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        AQSDailyDailyO3OldCheckBox.setText(" AQS - Daily O3 (Old name) Old 1-hr and 8-hr max O3 network ");
        AQSDailyDailyO3OldCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AQSDailyDailyO3OldCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        AQSDailyDailyO3OldCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        AQSDailyOldCheckBox.setText(" AQS - Daily (Old name) PM2.5,PM10,and PAMS species network ");
        AQSDailyOldCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AQSDailyOldCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        AQSDailyOldCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        SEARCHHourlyCheckBox.setText(" SEARCH Hourly (e.g. O3,CO,SO2,NO,HNO3,etc.) ");
        SEARCHHourlyCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        SEARCHHourlyCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SEARCHHourlyCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        SEARCHDailyCheckBox.setText(" SEARCH Daily (Fine and Coarse Mode Species) ");
        SEARCHDailyCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        SEARCHDailyCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SEARCHDailyCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        TOARCheckBox.setText(" TOAR (Daily O3 values) ");
        TOARCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        TOARCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        TOARCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        MDNCheckBox.setText(" MDN (Hg) ");
        MDNCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        MDNCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        MDNCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        ToxicsCheckBox.setText(" Toxics / HAPs ");
        ToxicsCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        ToxicsCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        ToxicsCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        ModelModelCheckBox.setText(" Model_Model ");
        ModelModelCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        ModelModelCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        ModelModelCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        SpeciesLabel1.setText("Species to Plot");
        SpeciesLabel1.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        SpeciesLabel1.setForeground(new java.awt.Color(0, 112, 185));

        SpeciesComboBox1.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "<Select a Project First>" }));
        SpeciesComboBox1.setBackground(new java.awt.Color(191, 182, 172));
        SpeciesComboBox1.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SpeciesComboBox1.setForeground(new java.awt.Color(0, 63, 105));
        SpeciesComboBox1.setMinimumSize(new java.awt.Dimension(274, 23));
        SpeciesComboBox1.setPreferredSize(new java.awt.Dimension(274, 23));

        AdvancedSpeciesButton1.setText("Advacnced Species Settings");
        AdvancedSpeciesButton1.setBackground(new java.awt.Color(0, 63, 105));
        AdvancedSpeciesButton1.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        AdvancedSpeciesButton1.setForeground(new java.awt.Color(191, 182, 172));
        AdvancedSpeciesButton1.setMaximumSize(new java.awt.Dimension(300, 23));
        AdvancedSpeciesButton1.setMinimumSize(new java.awt.Dimension(274, 23));
        AdvancedSpeciesButton1.setPreferredSize(new java.awt.Dimension(274, 23));
        AdvancedSpeciesButton1.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                AdvancedSpeciesButton1ActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout AQNetworkPanelLayout = new javax.swing.GroupLayout(AQNetworkPanel);
        AQNetworkPanel.setLayout(AQNetworkPanelLayout);
        AQNetworkPanelLayout.setHorizontalGroup(
            AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(AQNetworkPanelLayout.createSequentialGroup()
                .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                        .addComponent(AQNetworkLabel, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addComponent(AQNetworkInfoLabel, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                    .addComponent(IMPROVECheckBox)
                    .addComponent(CSNCheckBox)
                    .addComponent(CASTNetCheckBox)
                    .addComponent(CASTNetHourlyCheckBox)
                    .addComponent(CASTNetDailyCheckBox)
                    .addComponent(CAPMoNCheckBox)
                    .addComponent(CASTNetDryDepCheckBox)
                    .addComponent(NAPSHourlyCheckBox)
                    .addComponent(NAPSDailyO3CheckBox)
                    .addComponent(NADPCheckBox)
                    .addComponent(AMONCheckBox)
                    .addComponent(AIRMONCheckBox)
                    .addComponent(FluxNetCheckBox)
                    .addComponent(NOAAESRLCheckBox)
                    .addComponent(AERONETCheckBox))
                .addGap(18, 18, 18)
                .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(AQSDailyOldCheckBox)
                    .addComponent(AQSDailyDailyO3OldCheckBox)
                    .addComponent(AQSDailyOAQPSCheckBox)
                    .addComponent(AQSDailyCheckBox)
                    .addComponent(AQSDailyO3CheckBox)
                    .addComponent(AQSHourlyCheckBox)
                    .addComponent(SEARCHHourlyCheckBox)
                    .addComponent(SEARCHDailyCheckBox)
                    .addComponent(MDNCheckBox)
                    .addComponent(ToxicsCheckBox)
                    .addComponent(TOARCheckBox)
                    .addComponent(ModelModelCheckBox)
                    .addComponent(AdvancedSpeciesButton1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(SpeciesLabel1)
                    .addComponent(SpeciesComboBox1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        AQNetworkPanelLayout.setVerticalGroup(
            AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(AQNetworkPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(AQNetworkLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(AQNetworkInfoLabel)
                    .addComponent(AQSHourlyCheckBox))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(IMPROVECheckBox)
                    .addComponent(AQSDailyO3CheckBox))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(CSNCheckBox)
                    .addComponent(AQSDailyCheckBox))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(CASTNetCheckBox)
                    .addComponent(AQSDailyOAQPSCheckBox))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(CASTNetHourlyCheckBox)
                    .addComponent(AQSDailyDailyO3OldCheckBox))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(CASTNetDailyCheckBox)
                    .addComponent(AQSDailyOldCheckBox))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(CASTNetDryDepCheckBox)
                    .addComponent(SEARCHHourlyCheckBox))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(CAPMoNCheckBox)
                    .addComponent(SEARCHDailyCheckBox))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(NAPSHourlyCheckBox)
                    .addComponent(TOARCheckBox))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(NAPSDailyO3CheckBox)
                    .addComponent(MDNCheckBox))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(NADPCheckBox)
                    .addComponent(ToxicsCheckBox))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(AMONCheckBox)
                    .addComponent(ModelModelCheckBox))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(AIRMONCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(AQNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(AQNetworkPanelLayout.createSequentialGroup()
                        .addComponent(AERONETCheckBox)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(FluxNetCheckBox)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(NOAAESRLCheckBox)
                        .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                    .addGroup(AQNetworkPanelLayout.createSequentialGroup()
                        .addComponent(SpeciesLabel1)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(SpeciesComboBox1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(AdvancedSpeciesButton1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(0, 0, Short.MAX_VALUE))))
        );

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
            .addGap(0, 0, Short.MAX_VALUE)
        );

        javax.swing.GroupLayout AQNetworkSpeciesTabLayout = new javax.swing.GroupLayout(AQNetworkSpeciesTab);
        AQNetworkSpeciesTab.setLayout(AQNetworkSpeciesTabLayout);
        AQNetworkSpeciesTabLayout.setHorizontalGroup(
            AQNetworkSpeciesTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(AQNetworkSpeciesTabLayout.createSequentialGroup()
                .addComponent(Left4, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(26, 26, 26)
                .addComponent(AQNetworkPanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        AQNetworkSpeciesTabLayout.setVerticalGroup(
            AQNetworkSpeciesTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(AQNetworkSpeciesTabLayout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addComponent(AQNetworkPanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addGap(84, 84, 84))
            .addComponent(Left4, javax.swing.GroupLayout.DEFAULT_SIZE, 587, Short.MAX_VALUE)
        );

        AQFormTabbedPane.addTab("AQ Networks", AQNetworkSpeciesTab);

        EuropeanNetworkTab.setBackground(new java.awt.Color(255, 255, 255));
        EuropeanNetworkTab.setForeground(new java.awt.Color(255, 255, 255));
        EuropeanNetworkTab.setMinimumSize(new java.awt.Dimension(999, 573));
        EuropeanNetworkTab.setPreferredSize(new java.awt.Dimension(999, 576));

        EuropeanNetworkPanel.setBackground(new java.awt.Color(255, 255, 255));
        EuropeanNetworkPanel.setForeground(new java.awt.Color(255, 255, 255));

        EuropeanNetworkLabel.setText("European Networks");
        EuropeanNetworkLabel.setFont(new java.awt.Font("Times New Roman", 1, 20)); // NOI18N
        EuropeanNetworkLabel.setForeground(new java.awt.Color(0, 112, 185));

        EuropeanNetworkInfoLabel.setText("Choose air quality monitoring networks to use:");
        EuropeanNetworkInfoLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        EuropeanNetworkInfoLabel.setForeground(new java.awt.Color(0, 112, 185));

        ADMNCheckBox.setText(" ADMN (SO4,NO3,NH4,Precip, Na Ion, Cl Ion)");
        ADMNCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        ADMNCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ADMNCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        AGANETCheckBox.setText(" AGANET (HCl, NO2, NOY, SOX, HNO3, SO2, Cl, Na) ");
        AGANETCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AGANETCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        AGANETCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        AirBaseHourlyCheckBox.setText(" AirBase_Hourly (NO, NO2, NOX, SO2, CO, PM2.5, PM10, O3) ");
        AirBaseHourlyCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AirBaseHourlyCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        AirBaseHourlyCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        AirBaseDailyCheckBox.setText(" AirBase_Daily (NO, NO2, NOX, SO2, CO, PM2.5, PM10, O3) ");
        AirBaseDailyCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AirBaseDailyCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        AirBaseDailyCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        AURNHourlyCheckBox.setText(" AURN_Hourly (NO, NO2, NOX, SO2, CO, PM2.5, PM10, O3) ");
        AURNHourlyCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AURNHourlyCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        AURNHourlyCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        AURNDailyCheckBox.setText(" AURN_Daily (NO, NO2, NOX, SO2, CO, PM2.5, PM10, O3) ");
        AURNDailyCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AURNDailyCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        AURNDailyCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        EMEPHourlyCheckBox.setText(" EMEP - Hourly (NO, NO2, NOX, SO2, CO, PM2.5, PM10, O3) ");
        EMEPHourlyCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        EMEPHourlyCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        EMEPHourlyCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        EMEPDailyCheckBox.setText(" EMEP - Daily (SO4, NO3, NH44, trace metals, PM2.5, PM10, O3) ");
        EMEPDailyCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        EMEPDailyCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        EMEPDailyCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        EMEPDailyO3CheckBox.setText(" EMEP - Daily O3 (1-rh and 8-hr max O3) ");
        EMEPDailyO3CheckBox.setBackground(new java.awt.Color(255, 255, 255));
        EMEPDailyO3CheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        EMEPDailyO3CheckBox.setForeground(new java.awt.Color(0, 112, 185));

        javax.swing.GroupLayout EuropeanNetworkPanelLayout = new javax.swing.GroupLayout(EuropeanNetworkPanel);
        EuropeanNetworkPanel.setLayout(EuropeanNetworkPanelLayout);
        EuropeanNetworkPanelLayout.setHorizontalGroup(
            EuropeanNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(ADMNCheckBox)
            .addComponent(AGANETCheckBox)
            .addComponent(AirBaseHourlyCheckBox)
            .addComponent(EMEPHourlyCheckBox)
            .addComponent(AURNDailyCheckBox)
            .addComponent(EMEPDailyCheckBox)
            .addComponent(EMEPDailyO3CheckBox)
            .addComponent(EuropeanNetworkLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 372, javax.swing.GroupLayout.PREFERRED_SIZE)
            .addComponent(AirBaseDailyCheckBox)
            .addComponent(AURNHourlyCheckBox)
            .addGroup(EuropeanNetworkPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(EuropeanNetworkInfoLabel))
        );
        EuropeanNetworkPanelLayout.setVerticalGroup(
            EuropeanNetworkPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(EuropeanNetworkPanelLayout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addComponent(EuropeanNetworkLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(EuropeanNetworkInfoLabel)
                .addGap(18, 18, 18)
                .addComponent(ADMNCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(AGANETCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(AirBaseHourlyCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(AirBaseDailyCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(AURNHourlyCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(AURNDailyCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(EMEPHourlyCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(EMEPDailyCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(EMEPDailyO3CheckBox)
                .addContainerGap(88, Short.MAX_VALUE))
        );

        CampainsPanel.setBackground(new java.awt.Color(255, 255, 255));
        CampainsPanel.setForeground(new java.awt.Color(255, 255, 255));

        CampainsLabel.setText("Campains");
        CampainsLabel.setFont(new java.awt.Font("Times New Roman", 1, 20)); // NOI18N
        CampainsLabel.setForeground(new java.awt.Color(0, 112, 185));

        CALNEXCheckBox.setText(" CALNEX ");
        CALNEXCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        CALNEXCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        CALNEXCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        SOASCheckBox.setText(" SOAS ");
        SOASCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        SOASCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SOASCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        SpecialCheckBox.setText(" Special ");
        SpecialCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        SpecialCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SpecialCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        javax.swing.GroupLayout CampainsPanelLayout = new javax.swing.GroupLayout(CampainsPanel);
        CampainsPanel.setLayout(CampainsPanelLayout);
        CampainsPanelLayout.setHorizontalGroup(
            CampainsPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(CampainsPanelLayout.createSequentialGroup()
                .addGroup(CampainsPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(CALNEXCheckBox)
                    .addComponent(SOASCheckBox)
                    .addComponent(SpecialCheckBox)
                    .addComponent(CampainsLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 320, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(0, 0, Short.MAX_VALUE))
        );
        CampainsPanelLayout.setVerticalGroup(
            CampainsPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(CampainsPanelLayout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addComponent(CampainsLabel)
                .addGap(12, 12, 12)
                .addComponent(CALNEXCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(SOASCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(SpecialCheckBox)
                .addContainerGap(13, Short.MAX_VALUE))
        );

        SpeciesPanel.setBackground(new java.awt.Color(255, 255, 255));

        SpeciesLabel2.setText("Species to Plot");
        SpeciesLabel2.setFont(new java.awt.Font("Times New Roman", 1, 20)); // NOI18N
        SpeciesLabel2.setForeground(new java.awt.Color(0, 112, 185));

        SpeciesComboBox2.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "<Select a Project First>" }));
        SpeciesComboBox2.setBackground(new java.awt.Color(191, 182, 172));
        SpeciesComboBox2.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SpeciesComboBox2.setForeground(new java.awt.Color(0, 63, 105));
        SpeciesComboBox2.setMinimumSize(new java.awt.Dimension(274, 23));
        SpeciesComboBox2.setPreferredSize(new java.awt.Dimension(274, 23));

        AdvancedSpeciesButton2.setText("Advacnced Species Settings");
        AdvancedSpeciesButton2.setBackground(new java.awt.Color(0, 63, 105));
        AdvancedSpeciesButton2.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        AdvancedSpeciesButton2.setForeground(new java.awt.Color(191, 182, 172));
        AdvancedSpeciesButton2.setMaximumSize(new java.awt.Dimension(300, 23));
        AdvancedSpeciesButton2.setMinimumSize(new java.awt.Dimension(274, 23));
        AdvancedSpeciesButton2.setPreferredSize(new java.awt.Dimension(274, 23));
        AdvancedSpeciesButton2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                AdvancedSpeciesButton2ActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout SpeciesPanelLayout = new javax.swing.GroupLayout(SpeciesPanel);
        SpeciesPanel.setLayout(SpeciesPanelLayout);
        SpeciesPanelLayout.setHorizontalGroup(
            SpeciesPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(SpeciesPanelLayout.createSequentialGroup()
                .addGroup(SpeciesPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(SpeciesLabel2)
                    .addComponent(SpeciesComboBox2, 0, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(AdvancedSpeciesButton2, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(0, 41, Short.MAX_VALUE))
        );
        SpeciesPanelLayout.setVerticalGroup(
            SpeciesPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(SpeciesPanelLayout.createSequentialGroup()
                .addComponent(SpeciesLabel2)
                .addGap(18, 18, 18)
                .addComponent(SpeciesComboBox2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(AdvancedSpeciesButton2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 29, Short.MAX_VALUE))
        );

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
            .addGap(0, 0, Short.MAX_VALUE)
        );

        javax.swing.GroupLayout EuropeanNetworkTabLayout = new javax.swing.GroupLayout(EuropeanNetworkTab);
        EuropeanNetworkTab.setLayout(EuropeanNetworkTabLayout);
        EuropeanNetworkTabLayout.setHorizontalGroup(
            EuropeanNetworkTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(EuropeanNetworkTabLayout.createSequentialGroup()
                .addComponent(Left5, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addComponent(EuropeanNetworkPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(103, 103, 103)
                .addGroup(EuropeanNetworkTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(SpeciesPanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(CampainsPanel, javax.swing.GroupLayout.PREFERRED_SIZE, 315, Short.MAX_VALUE)))
        );
        EuropeanNetworkTabLayout.setVerticalGroup(
            EuropeanNetworkTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(EuropeanNetworkTabLayout.createSequentialGroup()
                .addGroup(EuropeanNetworkTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(EuropeanNetworkTabLayout.createSequentialGroup()
                        .addGroup(EuropeanNetworkTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addGroup(EuropeanNetworkTabLayout.createSequentialGroup()
                                .addComponent(CampainsPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addGap(80, 80, 80)
                                .addComponent(SpeciesPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                            .addComponent(EuropeanNetworkPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addGap(0, 57, Short.MAX_VALUE))
                    .addComponent(Left5, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                .addGap(0, 0, 0))
        );

        AQFormTabbedPane.addTab("European Networks", EuropeanNetworkTab);

        DateTimeTab.setBackground(new java.awt.Color(255, 255, 255));
        DateTimeTab.setForeground(new java.awt.Color(255, 255, 255));
        DateTimeTab.setMinimumSize(new java.awt.Dimension(999, 573));
        DateTimeTab.setPreferredSize(new java.awt.Dimension(999, 573));

        DateRangeLabel.setText("Set Date Range");
        DateRangeLabel.setBackground(new java.awt.Color(255, 255, 255));
        DateRangeLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        DateRangeLabel.setForeground(new java.awt.Color(0, 112, 185));

        DateRangePanel.setBackground(new java.awt.Color(255, 255, 255));

        StartDateLabel.setText("Start Date");
        StartDateLabel.setBackground(new java.awt.Color(255, 255, 255));
        StartDateLabel.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        StartDateLabel.setForeground(new java.awt.Color(0, 112, 185));

        StartDatePicker.setBackground(new java.awt.Color(255, 255, 255));
        StartDatePicker.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        StartDatePicker.setForeground(new java.awt.Color(0, 112, 185));

        EndDateLabel.setText("End Date");
        EndDateLabel.setBackground(new java.awt.Color(255, 255, 255));
        EndDateLabel.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        EndDateLabel.setForeground(new java.awt.Color(0, 112, 185));

        EndDatePicker.setBackground(new java.awt.Color(255, 255, 255));
        EndDatePicker.setFont(new java.awt.Font("sansserif", 0, 13)); // NOI18N
        EndDatePicker.setForeground(new java.awt.Color(0, 112, 185));

        javax.swing.GroupLayout DateRangePanelLayout = new javax.swing.GroupLayout(DateRangePanel);
        DateRangePanel.setLayout(DateRangePanelLayout);
        DateRangePanelLayout.setHorizontalGroup(
            DateRangePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(DateRangePanelLayout.createSequentialGroup()
                .addComponent(StartDateLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(StartDatePicker, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(EndDateLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 70, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(EndDatePicker, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
        );
        DateRangePanelLayout.setVerticalGroup(
            DateRangePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(DateRangePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                .addComponent(StartDateLabel)
                .addComponent(StartDatePicker, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addComponent(EndDateLabel)
                .addComponent(EndDatePicker, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
        );

        HourRangeLabel.setText("Set Hour Range");
        HourRangeLabel.setBackground(new java.awt.Color(255, 255, 255));
        HourRangeLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        HourRangeLabel.setForeground(new java.awt.Color(0, 112, 185));

        HourRangeTextArea.setColumns(20);
        HourRangeTextArea.setEditable(false);
        HourRangeTextArea.setFont(new java.awt.Font("Times New Roman", 0, 12)); // NOI18N
        HourRangeTextArea.setRows(5);
        HourRangeTextArea.setText("Use this option to isolate a range of hours to include in the analysis. Hours\nare in LST. The default is to include all hours of the day in the analysis.");
        HourRangeTextArea.setBackground(new java.awt.Color(255, 255, 255));
        HourRangeTextArea.setForeground(new java.awt.Color(0, 112, 185));

        HourRangePanel.setBackground(new java.awt.Color(255, 255, 255));

        StartHourLabel.setText("Start Hour");
        StartHourLabel.setBackground(new java.awt.Color(255, 255, 255));
        StartHourLabel.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        StartHourLabel.setForeground(new java.awt.Color(0, 112, 185));

        StartHourComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "None", "12AM", "1AM", "2AM", "3AM", "4AM", "5AM", "6AM", "7AM", "8AM", "9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM", "5PM", "6PM", "7PM", "8PM", "9PM", "10PM", "11PM" }));
        StartHourComboBox.setBackground(new java.awt.Color(191, 182, 172));
        StartHourComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        StartHourComboBox.setForeground(new java.awt.Color(0, 63, 105));

        EndHourLabel.setText("End Hour");
        EndHourLabel.setBackground(new java.awt.Color(255, 255, 255));
        EndHourLabel.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        EndHourLabel.setForeground(new java.awt.Color(0, 112, 185));

        EndHourComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "None", "12AM", "1AM", "2AM", "3AM", "4AM", "5AM", "6AM", "7AM", "8AM", "9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM", "5PM", "6PM", "7PM", "8PM", "9PM", "10PM", "11PM" }));
        EndHourComboBox.setBackground(new java.awt.Color(191, 182, 172));
        EndHourComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        EndHourComboBox.setForeground(new java.awt.Color(0, 63, 105));

        javax.swing.GroupLayout HourRangePanelLayout = new javax.swing.GroupLayout(HourRangePanel);
        HourRangePanel.setLayout(HourRangePanelLayout);
        HourRangePanelLayout.setHorizontalGroup(
            HourRangePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(HourRangePanelLayout.createSequentialGroup()
                .addComponent(StartHourLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(StartHourComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 100, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(EndHourLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(EndHourComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 100, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(21, Short.MAX_VALUE))
        );
        HourRangePanelLayout.setVerticalGroup(
            HourRangePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(HourRangePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                .addComponent(StartHourLabel)
                .addComponent(StartHourComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addComponent(EndHourLabel)
                .addComponent(EndHourComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
        );

        SeasonalLabel.setText("Seasonal Analysis");
        SeasonalLabel.setBackground(new java.awt.Color(255, 255, 255));
        SeasonalLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        SeasonalLabel.setForeground(new java.awt.Color(0, 112, 185));

        SeasonalTextArea.setColumns(20);
        SeasonalTextArea.setEditable(false);
        SeasonalTextArea.setFont(new java.awt.Font("Times New Roman", 0, 12)); // NOI18N
        SeasonalTextArea.setRows(5);
        SeasonalTextArea.setText("Use this option to isolate evaluation data by a particular season of the year. \nWhen using this option, set the dates above to cover the entire season or \nyear.  All months in the season chosen must fall within the dates set above.\n\n");
        SeasonalTextArea.setBackground(new java.awt.Color(255, 255, 255));
        SeasonalTextArea.setForeground(new java.awt.Color(0, 112, 185));

        SeasonalComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "None", "Winter (Dec, Jan, Feb)", "Spring (Mar, Apr, May)", "Summer (Jun, Jul, Aug)", "Autumn (Sep, Oct, Nov)" }));
        SeasonalComboBox.setBackground(new java.awt.Color(191, 182, 172));
        SeasonalComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SeasonalComboBox.setForeground(new java.awt.Color(0, 63, 105));

        MonthlyLabel.setText("Individual Monthly Analysis");
        MonthlyLabel.setBackground(new java.awt.Color(255, 255, 255));
        MonthlyLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        MonthlyLabel.setForeground(new java.awt.Color(0, 112, 185));

        MonthlyTextArea.setColumns(20);
        MonthlyTextArea.setEditable(false);
        MonthlyTextArea.setFont(new java.awt.Font("Times New Roman", 0, 12)); // NOI18N
        MonthlyTextArea.setRows(5);
        MonthlyTextArea.setText("Use this option to isolate a data set by an individual month of the year. \nWhen using this option, set the dates above to cover at least the entire \nmonth. It is preferrable to set the date range above to the whole year and \nthen select an individual month from the list above.\n\n");
        MonthlyTextArea.setBackground(new java.awt.Color(255, 255, 255));
        MonthlyTextArea.setForeground(new java.awt.Color(0, 112, 185));

        MonthlyComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "None", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }));
        MonthlyComboBox.setBackground(new java.awt.Color(191, 182, 172));
        MonthlyComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        MonthlyComboBox.setForeground(new java.awt.Color(0, 63, 105));

        POCodeLabel.setText("Select Parameter Occurrence (PO) Code");
        POCodeLabel.setBackground(new java.awt.Color(255, 255, 255));
        POCodeLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        POCodeLabel.setForeground(new java.awt.Color(0, 112, 185));

        POCodeTextArea.setColumns(20);
        POCodeTextArea.setEditable(false);
        POCodeTextArea.setFont(new java.awt.Font("Times New Roman", 0, 12)); // NOI18N
        POCodeTextArea.setLineWrap(true);
        POCodeTextArea.setRows(5);
        POCodeTextArea.setText("Use this option to isolate the data by a specific PO code. Most observations use a parameter occurrence code of 1.");
        POCodeTextArea.setWrapStyleWord(true);
        POCodeTextArea.setBackground(new java.awt.Color(255, 255, 255));
        POCodeTextArea.setForeground(new java.awt.Color(0, 112, 185));

        POCodeComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "All", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12" }));
        POCodeComboBox.setBackground(new java.awt.Color(191, 182, 172));
        POCodeComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        POCodeComboBox.setForeground(new java.awt.Color(0, 63, 105));

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
            .addGap(0, 570, Short.MAX_VALUE)
        );

        jPanel1.setBackground(new java.awt.Color(255, 255, 255));
        jPanel1.setPreferredSize(new java.awt.Dimension(386, 510));

        NegativeValuesLabel.setText("Remove Negative Values");
        NegativeValuesLabel.setBackground(new java.awt.Color(255, 255, 255));
        NegativeValuesLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        NegativeValuesLabel.setForeground(new java.awt.Color(0, 112, 185));

        NegativeValuesTextArea.setColumns(20);
        NegativeValuesTextArea.setEditable(false);
        NegativeValuesTextArea.setFont(new java.awt.Font("Times New Roman", 0, 12)); // NOI18N
        NegativeValuesTextArea.setLineWrap(true);
        NegativeValuesTextArea.setRows(5);
        NegativeValuesTextArea.setText("Select \"yes\" to remove negative values from the analysis. All values less than zero are removed from the analysis. Obviously this can be a problem when plotting species with acceptable negative values.");
        NegativeValuesTextArea.setWrapStyleWord(true);
        NegativeValuesTextArea.setAutoscrolls(false);
        NegativeValuesTextArea.setBackground(new java.awt.Color(255, 255, 255));
        NegativeValuesTextArea.setForeground(new java.awt.Color(0, 112, 185));
        NegativeValuesTextArea.setMaximumSize(new java.awt.Dimension(356, 62));
        NegativeValuesTextArea.setMinimumSize(new java.awt.Dimension(334, 62));
        NegativeValuesTextArea.setPreferredSize(new java.awt.Dimension(335, 62));

        NegativeValuesComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Yes", "No" }));
        NegativeValuesComboBox.setBackground(new java.awt.Color(191, 182, 172));
        NegativeValuesComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        NegativeValuesComboBox.setForeground(new java.awt.Color(0, 63, 105));

        AggregateDataLabel.setText("Aggregate Data");
        AggregateDataLabel.setBackground(new java.awt.Color(255, 255, 255));
        AggregateDataLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        AggregateDataLabel.setForeground(new java.awt.Color(0, 112, 185));

        AggregateDataTextArea.setColumns(20);
        AggregateDataTextArea.setEditable(false);
        AggregateDataTextArea.setFont(new java.awt.Font("Times New Roman", 0, 12)); // NOI18N
        AggregateDataTextArea.setLineWrap(true);
        AggregateDataTextArea.setRows(5);
        AggregateDataTextArea.setText("Check this box to aggregate duplicate observations. This typically occurs when multiple measurements are reported for the same site and time period using different parameter occurrence codes (POCs). Checking this box will average multiple observations into a single value. If unchecked, observations will not be averaged and each observation will be treated as entirely unique.");
        AggregateDataTextArea.setWrapStyleWord(true);
        AggregateDataTextArea.setBackground(new java.awt.Color(255, 255, 255));
        AggregateDataTextArea.setForeground(new java.awt.Color(0, 112, 185));
        AggregateDataTextArea.setMaximumSize(new java.awt.Dimension(356, 123));
        AggregateDataTextArea.setMinimumSize(new java.awt.Dimension(335, 123));
        AggregateDataTextArea.setPreferredSize(new java.awt.Dimension(335, 123));

        AggregateDataCheckBox.setText("Aggregate Data");
        AggregateDataCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        AggregateDataCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        AggregateDataCheckBox.setForeground(new java.awt.Color(0, 112, 185));

        TemporalAveragingLabel.setText("Temporal Averaging");
        TemporalAveragingLabel.setBackground(new java.awt.Color(255, 255, 255));
        TemporalAveragingLabel.setFont(new java.awt.Font("Times New Roman", 1, 16)); // NOI18N
        TemporalAveragingLabel.setForeground(new java.awt.Color(0, 112, 185));

        TemporalAveragingTextArea.setColumns(20);
        TemporalAveragingTextArea.setEditable(false);
        TemporalAveragingTextArea.setFont(new java.awt.Font("Times New Roman", 0, 12)); // NOI18N
        TemporalAveragingTextArea.setLineWrap(true);
        TemporalAveragingTextArea.setRows(5);
        TemporalAveragingTextArea.setText("The default option is to use all available observations. Alternatively, monthly average values can be used for the analysis. Currently, this option really only applies to the various scatterplots that can be generated. Most of the programs that can be run use all the available pairs, and some programs require hourly data to be used.");
        TemporalAveragingTextArea.setWrapStyleWord(true);
        TemporalAveragingTextArea.setBackground(new java.awt.Color(255, 255, 255));
        TemporalAveragingTextArea.setForeground(new java.awt.Color(0, 112, 185));
        TemporalAveragingTextArea.setMaximumSize(new java.awt.Dimension(356, 106));
        TemporalAveragingTextArea.setMinimumSize(new java.awt.Dimension(335, 106));
        TemporalAveragingTextArea.setPreferredSize(new java.awt.Dimension(335, 106));

        TemporalAveragingComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "None", "Hour of Day Average", "Daily Average", "Monthly Average", "Year/Month Average", "Seasonal Average", "Annual Average", "Entire Period Average", "Day of Week" }));
        TemporalAveragingComboBox.setBackground(new java.awt.Color(191, 182, 172));
        TemporalAveragingComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        TemporalAveragingComboBox.setForeground(new java.awt.Color(0, 63, 105));

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(NegativeValuesLabel)
                    .addComponent(AggregateDataLabel)
                    .addComponent(TemporalAveragingLabel)
                    .addComponent(NegativeValuesComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(AggregateDataCheckBox)
                    .addComponent(TemporalAveragingComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(NegativeValuesTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(TemporalAveragingTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 335, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(AggregateDataTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 335, javax.swing.GroupLayout.PREFERRED_SIZE)))
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addGap(0, 0, 0)
                .addComponent(NegativeValuesLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(NegativeValuesTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(NegativeValuesComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(AggregateDataLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(AggregateDataTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(AggregateDataCheckBox, javax.swing.GroupLayout.PREFERRED_SIZE, 21, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(TemporalAveragingLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(TemporalAveragingTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 106, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(TemporalAveragingComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        javax.swing.GroupLayout DateTimeTabLayout = new javax.swing.GroupLayout(DateTimeTab);
        DateTimeTab.setLayout(DateTimeTabLayout);
        DateTimeTabLayout.setHorizontalGroup(
            DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(DateTimeTabLayout.createSequentialGroup()
                .addComponent(Left6, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(MonthlyLabel)
                    .addComponent(SeasonalLabel)
                    .addComponent(HourRangeLabel)
                    .addComponent(SeasonalTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 493, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(HourRangeTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(MonthlyTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 491, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(POCodeLabel)
                    .addComponent(POCodeTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 434, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGroup(DateTimeTabLayout.createSequentialGroup()
                        .addGap(6, 6, 6)
                        .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(HourRangePanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(DateRangePanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                    .addComponent(DateRangeLabel)
                    .addComponent(POCodeComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(MonthlyComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(SeasonalComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 215, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 41, Short.MAX_VALUE)
                .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, 341, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(30, 30, 30))
        );
        DateTimeTabLayout.setVerticalGroup(
            DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, DateTimeTabLayout.createSequentialGroup()
                .addComponent(Left6, javax.swing.GroupLayout.PREFERRED_SIZE, 570, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(12, 12, 12))
            .addGroup(DateTimeTabLayout.createSequentialGroup()
                .addGap(20, 20, 20)
                .addGroup(DateTimeTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGroup(DateTimeTabLayout.createSequentialGroup()
                        .addComponent(DateRangeLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(DateRangePanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(HourRangeLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(HourRangeTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 38, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(HourRangePanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(SeasonalLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(SeasonalTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 54, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(SeasonalComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(MonthlyLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(MonthlyTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 74, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(MonthlyComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(POCodeLabel)
                        .addGap(1, 1, 1)
                        .addComponent(POCodeTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 37, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(POCodeComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        AQFormTabbedPane.addTab("Date/Time", DateTimeTab);

        ProgramTab.setBackground(new java.awt.Color(255, 255, 255));
        ProgramTab.setForeground(new java.awt.Color(255, 255, 255));
        ProgramTab.setMinimumSize(new java.awt.Dimension(999, 573));
        ProgramTab.setPreferredSize(new java.awt.Dimension(999, 573));

        PlotlyImageLabel.setText("Plotly Image Dimensions");
        PlotlyImageLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        PlotlyImageLabel.setForeground(new java.awt.Color(0, 112, 185));

        PlotlyIamgeInfoTextArea.setColumns(20);
        PlotlyIamgeInfoTextArea.setEditable(false);
        PlotlyIamgeInfoTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        PlotlyIamgeInfoTextArea.setLineWrap(true);
        PlotlyIamgeInfoTextArea.setRows(5);
        PlotlyIamgeInfoTextArea.setText("Enter NULL for auto sizing. Enter height/width values (e.g. 900/1600) to export plot as a PNG file.");
        PlotlyIamgeInfoTextArea.setWrapStyleWord(true);
        PlotlyIamgeInfoTextArea.setBackground(new java.awt.Color(255, 255, 255));
        PlotlyIamgeInfoTextArea.setForeground(new java.awt.Color(0, 112, 185));
        PlotlyIamgeInfoTextArea.setMinimumSize(new java.awt.Dimension(548, 21));
        PlotlyIamgeInfoTextArea.setPreferredSize(new java.awt.Dimension(548, 89));

        PlotlyImagePanel.setBackground(new java.awt.Color(255, 255, 255));

        HeightLabel.setText("Height");
        HeightLabel.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        HeightLabel.setForeground(new java.awt.Color(0, 112, 185));

        HeightTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        HeightTextField.setText("NULL");
        HeightTextField.setBackground(new java.awt.Color(191, 182, 172));
        HeightTextField.setForeground(new java.awt.Color(0, 63, 105));

        WidthLabel.setText("Width");
        WidthLabel.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        WidthLabel.setForeground(new java.awt.Color(0, 112, 185));

        WidthTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        WidthTextField.setText("NULL");
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
                .addContainerGap(142, Short.MAX_VALUE))
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

        PNGQualityLabel.setText("PNG Plot Quality");
        PNGQualityLabel.setBackground(new java.awt.Color(255, 255, 255));
        PNGQualityLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        PNGQualityLabel.setForeground(new java.awt.Color(0, 112, 185));

        PNGQualityTextArea.setColumns(20);
        PNGQualityTextArea.setEditable(false);
        PNGQualityTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        PNGQualityTextArea.setLineWrap(true);
        PNGQualityTextArea.setRows(5);
        PNGQualityTextArea.setText("Specify the image quality of the PNG plots produced. Lower quality images are smaller and load faster.");
        PNGQualityTextArea.setWrapStyleWord(true);
        PNGQualityTextArea.setBackground(new java.awt.Color(255, 255, 255));
        PNGQualityTextArea.setDisabledTextColor(new java.awt.Color(0, 80, 184));
        PNGQualityTextArea.setForeground(new java.awt.Color(0, 112, 185));
        PNGQualityTextArea.setMinimumSize(new java.awt.Dimension(548, 21));
        PNGQualityTextArea.setPreferredSize(new java.awt.Dimension(548, 89));

        PNGQualityComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Low", "Medium", "High" }));
        PNGQualityComboBox.setSelectedIndex(1);
        PNGQualityComboBox.setBackground(new java.awt.Color(191, 182, 172));
        PNGQualityComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        PNGQualityComboBox.setForeground(new java.awt.Color(0, 63, 105));

        AdvancedPlotLabel.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        AdvancedPlotLabel.setText("Advanced Plot Specifications ");
        AdvancedPlotLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        AdvancedPlotLabel.setForeground(new java.awt.Color(0, 112, 185));

        DataFormattingLabel.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        DataFormattingLabel.setText("and Data Formatting");
        DataFormattingLabel.setBackground(new java.awt.Color(255, 255, 255));
        DataFormattingLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        DataFormattingLabel.setForeground(new java.awt.Color(0, 112, 185));

        SoccergoalBuglePlotButton.setText("Soccergoal/Bugle/Kelly Plot Options");
        SoccergoalBuglePlotButton.setBackground(new java.awt.Color(0, 63, 105));
        SoccergoalBuglePlotButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SoccergoalBuglePlotButton.setForeground(new java.awt.Color(191, 182, 172));
        SoccergoalBuglePlotButton.setHideActionText(true);
        SoccergoalBuglePlotButton.setPreferredSize(null);
        SoccergoalBuglePlotButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                SoccergoalBuglePlotButtonActionPerformed(evt);
            }
        });

        AxisOptionsButton.setText("Axis Options");
        AxisOptionsButton.setBackground(new java.awt.Color(0, 63, 105));
        AxisOptionsButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        AxisOptionsButton.setForeground(new java.awt.Color(191, 182, 172));
        AxisOptionsButton.setHideActionText(true);
        AxisOptionsButton.setPreferredSize(new java.awt.Dimension(333, 23));
        AxisOptionsButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                AxisOptionsButtonActionPerformed(evt);
            }
        });

        ScatterPlotButton.setText("Scatter Plot Options");
        ScatterPlotButton.setBackground(new java.awt.Color(0, 63, 105));
        ScatterPlotButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ScatterPlotButton.setForeground(new java.awt.Color(191, 182, 172));
        ScatterPlotButton.setHideActionText(true);
        ScatterPlotButton.setPreferredSize(null);
        ScatterPlotButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                ScatterPlotButtonActionPerformed(evt);
            }
        });

        ModelEvalOptionsButton.setText("Model Evaluation Options");
        ModelEvalOptionsButton.setBackground(new java.awt.Color(0, 63, 105));
        ModelEvalOptionsButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ModelEvalOptionsButton.setForeground(new java.awt.Color(191, 182, 172));
        ModelEvalOptionsButton.setHideActionText(true);
        ModelEvalOptionsButton.setPreferredSize(null);
        ModelEvalOptionsButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                ModelEvalOptionsButtonActionPerformed(evt);
            }
        });

        OverlayFileButton.setText("Overlay File Options");
        OverlayFileButton.setBackground(new java.awt.Color(0, 63, 105));
        OverlayFileButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        OverlayFileButton.setForeground(new java.awt.Color(191, 182, 172));
        OverlayFileButton.setHideActionText(true);
        OverlayFileButton.setPreferredSize(null);
        OverlayFileButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                OverlayFileButtonActionPerformed(evt);
            }
        });

        SpatialPlotButton.setText("Spatial Plot Options");
        SpatialPlotButton.setBackground(new java.awt.Color(0, 63, 105));
        SpatialPlotButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SpatialPlotButton.setForeground(new java.awt.Color(191, 182, 172));
        SpatialPlotButton.setHideActionText(true);
        SpatialPlotButton.setPreferredSize(null);
        SpatialPlotButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                SpatialPlotButtonActionPerformed(evt);
            }
        });

        RunProgramButton.setText("Run Program");
        RunProgramButton.setBackground(new java.awt.Color(38, 161, 70));
        RunProgramButton.setFont(new java.awt.Font("Times New Roman", 1, 20)); // NOI18N
        RunProgramButton.setForeground(new java.awt.Color(0, 63, 105));
        RunProgramButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                RunProgramButtonActionPerformed(evt);
            }
        });

        Left7.setBackground(new java.awt.Color(174, 211, 232));
        Left7.setPreferredSize(new java.awt.Dimension(25, 543));

        javax.swing.GroupLayout Left7Layout = new javax.swing.GroupLayout(Left7);
        Left7.setLayout(Left7Layout);
        Left7Layout.setHorizontalGroup(
            Left7Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 25, Short.MAX_VALUE)
        );
        Left7Layout.setVerticalGroup(
            Left7Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 0, Short.MAX_VALUE)
        );

        ProgramLabel.setText("Choose a Program to Run");
        ProgramLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        ProgramLabel.setForeground(new java.awt.Color(0, 112, 185));

        ProgramTextArea.setColumns(20);
        ProgramTextArea.setEditable(false);
        ProgramTextArea.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        ProgramTextArea.setLineWrap(true);
        ProgramTextArea.setRows(5);
        ProgramTextArea.setText("Choose which program to run to create specific stats and figures. Note that some programs require certain temporal data (e.g. hourly, monthly).\n\n\n");
        ProgramTextArea.setWrapStyleWord(true);
        ProgramTextArea.setBackground(new java.awt.Color(255, 255, 255));
        ProgramTextArea.setBorder(null);
        ProgramTextArea.setForeground(new java.awt.Color(0, 112, 185));
        ProgramTextArea.setMinimumSize(new java.awt.Dimension(548, 51));
        ProgramTextArea.setPreferredSize(new java.awt.Dimension(548, 85));

        ProgramComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Choose AMET Script to Execute", "- Scatter Plots -", "Multiple Networks Model/Ob Scatterplot (select stats only)", "GGPlot Scatterplot (multi network, single run)", "Interactive Multiple Network Scatterplot", "Interactive Multiple Simulation Scatterplot", "Single Network Model/Ob Scatterplot (includes all stats)", "Density Scatterplot (single run, single network)", "GGPlot Density Scatterplot (single run, single network)", "Model/Model Scatterplot (multiple networks)", "Model/Model Density Scatterplot (single network)", "Scatterplot of Percentiles (single network, single run)", "Ozone Skill Scatterplot (single network, mult runs)", "Binned MB & RMSE Scatterplots (single net., mult. run)", "Interactive Binned Scatterplot (single net., mult. run)", "Multi Simulation Scatterplot (single network, mult runs)", "Soil Scatterplot (single network)", "- Time Series Plots -", "Time-Series Plot (single network, multiple sites averages)", "Dygraph Time-series Plot", "Plotly Multi-simulation Timeseries", "Plotly Multi-network Timeseries", "Plotly Multi-species Timeseries", "Multi-Network Time-series Plot (mult. net., single run)", "Multi-Species Time-series Plot (mult. species, single run)", "Model-to-Model Time-series Plot (single net., multi run)", "Year-long Monthly Statistics Plot (single network)", "- Spatial Plots -", "Species Statistics and Spatial Plots (multi networks)", "Interactive Species Statistics and Spatial Plots (multi networks)", "Spatial Plot (multi networks)", "Interactive Spatial Plot (multi networks)", "Model/Model Diff Spatial Plot (multi network, multi run)", "Interactive Model/Model Diff Spatial Plot (multi network, multi run)", "Model/Model Species Diff Spatial Plot (multi network, multi run)", "Spatial Plot of Bias/Error Difference (multi network, multi run)", "Interactive Spatial Plot of Bias/Error Difference (multi networks)", "Ratio Spatial Plot to total PM2.5 (multi network, multi run)", "- Box Plots -", "Boxplot (single network, multi run)", "GGPlot Boxplot (single network, multi run)", "Plotly Boxplot (single network, multi run)", "Day of Week Boxplot (single network, multiple runs)", "Hourly Boxplot (single network, multiple runs)", "8hr Average Boxplot (single network, hourly data, can be slow)", "Roselle Boxplot (single network, multiple simulations)", "- Stacked Bar Plots -", "PM2.5 Stacked Bar Plot (CSN or IMPROVE, multi run)", "PM2.5 Stacked Bar Plot AE6 (CSN or IMPROVE, multi run)", "Interactive Stacked Bar Plot", "GGPlot Stacked Bar Plot", "Stacked Bar Plot Time Series", "Soil Stacked Bar Plot (CSN or IMPROVE, multi run)", "Soil Stacked Bar Plot Multi (CSN and IMPROVE, single run)", "Multi-Panel Stacked Bar Plot (full year data required)", "Multi-Panel Stacked Bar Plot AE6 (full year data)", "Multi-Panel, Mulit Run Stacked Bar Plot AE6 (full year data)", "- Misc Scripts -", "Kelly Plot (single species, single network, full year data)", "Climate Region Kelly Plot (single species, single network, multi sim)", "Seasonal Kelly Plot (single species, single network, multi sim)", "Multisim Kelly Plot (single species, single network, multi sim)", "Species Statistics (multi species, single network)", "Create raw data csv file (single network, single simulation)", "\"Soccergoal\" plot (multiple networks)", "\"Bugle\" plot (multiple networks)", "Histogram (single network/species only)", "CDF, Q-Q, Taylor Plots (single network, multi run)", "- Experimental Scripts (may not work correctly) -", "Create PAVE/VERDI Obs Overlay File (hourly/daily data only)", "Log-Log Model/Ob Scatterplot (multiple networks)", "Spectral Analysis (single network, single run, experimental)", "PM Ratio Spatial Plot (multi network, single run)" }));
        ProgramComboBox.setBackground(new java.awt.Color(191, 182, 172));
        ProgramComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ProgramComboBox.setForeground(new java.awt.Color(0, 63, 105));
        ProgramComboBox.setMinimumSize(new java.awt.Dimension(548, 23));
        ProgramComboBox.setPreferredSize(new java.awt.Dimension(548, 23));

        javax.swing.GroupLayout ProgramTabLayout = new javax.swing.GroupLayout(ProgramTab);
        ProgramTab.setLayout(ProgramTabLayout);
        ProgramTabLayout.setHorizontalGroup(
            ProgramTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(ProgramTabLayout.createSequentialGroup()
                .addComponent(Left7, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addGroup(ProgramTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(ProgramTabLayout.createSequentialGroup()
                        .addGroup(ProgramTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                            .addGroup(ProgramTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                .addComponent(PlotlyImageLabel)
                                .addComponent(PNGQualityLabel)
                                .addComponent(PlotlyImagePanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addComponent(PNGQualityComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, 140, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addComponent(PNGQualityTextArea, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                .addComponent(PlotlyIamgeInfoTextArea, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                            .addGroup(ProgramTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                .addComponent(ProgramLabel)
                                .addComponent(ProgramComboBox, 0, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                .addComponent(ProgramTextArea, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
                        .addGap(18, 18, 18)
                        .addGroup(ProgramTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(ScatterPlotButton, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(OverlayFileButton, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(SoccergoalBuglePlotButton, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(ModelEvalOptionsButton, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(AdvancedPlotLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(DataFormattingLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(SpatialPlotButton, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(AxisOptionsButton, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
                    .addComponent(RunProgramButton, javax.swing.GroupLayout.PREFERRED_SIZE, 200, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addContainerGap(39, Short.MAX_VALUE))
        );
        ProgramTabLayout.setVerticalGroup(
            ProgramTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, ProgramTabLayout.createSequentialGroup()
                .addGap(20, 20, 20)
                .addGroup(ProgramTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(ProgramTabLayout.createSequentialGroup()
                        .addComponent(PlotlyImageLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(PlotlyIamgeInfoTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 35, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(PlotlyImagePanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(PNGQualityLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(PNGQualityTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 33, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(PNGQualityComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(ProgramLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ProgramTextArea, javax.swing.GroupLayout.PREFERRED_SIZE, 30, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ProgramComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 72, Short.MAX_VALUE)
                        .addComponent(RunProgramButton)
                        .addGap(74, 74, 74))
                    .addGroup(ProgramTabLayout.createSequentialGroup()
                        .addComponent(AdvancedPlotLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(DataFormattingLabel)
                        .addGap(30, 30, 30)
                        .addComponent(AxisOptionsButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(30, 30, 30)
                        .addComponent(ModelEvalOptionsButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(30, 30, 30)
                        .addComponent(OverlayFileButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(30, 30, 30)
                        .addComponent(ScatterPlotButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(30, 30, 30)
                        .addComponent(SoccergoalBuglePlotButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(30, 30, 30)
                        .addComponent(SpatialPlotButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))))
            .addComponent(Left7, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );

        AQFormTabbedPane.addTab("Program  ", ProgramTab);

        Back.setBackground(new java.awt.Color(255, 255, 255));
        Back.setPreferredSize(new java.awt.Dimension(999, 569));

        Left8.setBackground(new java.awt.Color(174, 211, 232));
        Left8.setPreferredSize(new java.awt.Dimension(25, 543));

        javax.swing.GroupLayout Left8Layout = new javax.swing.GroupLayout(Left8);
        Left8.setLayout(Left8Layout);
        Left8Layout.setHorizontalGroup(
            Left8Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 25, Short.MAX_VALUE)
        );
        Left8Layout.setVerticalGroup(
            Left8Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 577, Short.MAX_VALUE)
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

        javax.swing.GroupLayout BackLayout = new javax.swing.GroupLayout(Back);
        Back.setLayout(BackLayout);
        BackLayout.setHorizontalGroup(
            BackLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(BackLayout.createSequentialGroup()
                .addComponent(Left8, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(36, 36, 36)
                .addComponent(ReturnButton, javax.swing.GroupLayout.PREFERRED_SIZE, 286, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(653, 653, 653))
        );
        BackLayout.setVerticalGroup(
            BackLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(BackLayout.createSequentialGroup()
                .addComponent(Left8, javax.swing.GroupLayout.PREFERRED_SIZE, 577, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
            .addGroup(BackLayout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addComponent(ReturnButton)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        AQFormTabbedPane.addTab("Back", Back);

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(AQFormTabbedPane, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(Header, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
            .addComponent(Footer)
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addComponent(Header, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, 0)
                .addComponent(AQFormTabbedPane, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, 0)
                .addComponent(Footer))
        );

        AQFormTabbedPane.getAccessibleContext().setAccessibleName("AQ Form ");

        setSize(new java.awt.Dimension(1000, 753));
        setLocationRelativeTo(null);
    }// </editor-fold>//GEN-END:initComponents

    private void AerosolMapButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_AerosolMapButtonActionPerformed
        new AerosolMap().setVisible(true);
    }//GEN-LAST:event_AerosolMapButtonActionPerformed

    private void OzoneMapButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_OzoneMapButtonActionPerformed
        new OzoneMap().setVisible(true);
    }//GEN-LAST:event_OzoneMapButtonActionPerformed

    private void AdvancedSpeciesButton1ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_AdvancedSpeciesButton1ActionPerformed
        AdvancedSpeciesSettings asSettings = new AdvancedSpeciesSettings(this);
        asSettings.setVisible(true);
    }//GEN-LAST:event_AdvancedSpeciesButton1ActionPerformed

    private void AdvancedSpeciesButton2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_AdvancedSpeciesButton2ActionPerformed
        AdvancedSpeciesSettings asSettings = new AdvancedSpeciesSettings(this);
        asSettings.setVisible(true);
    }//GEN-LAST:event_AdvancedSpeciesButton2ActionPerformed

    private void SoccergoalBuglePlotButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_SoccergoalBuglePlotButtonActionPerformed
        SoccergoalBuglePlotOptions sgbpSettings = new SoccergoalBuglePlotOptions(this);
        sgbpSettings.setVisible(true);
    }//GEN-LAST:event_SoccergoalBuglePlotButtonActionPerformed

    private void ScatterPlotButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ScatterPlotButtonActionPerformed
        ScatterPlotOptions spOptions = new ScatterPlotOptions(this);
        spOptions.setVisible(true);
    }//GEN-LAST:event_ScatterPlotButtonActionPerformed

    private void OverlayFileButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_OverlayFileButtonActionPerformed
        OverlayFileOptions ofOptions = new OverlayFileOptions(this);
        ofOptions.setVisible(true);
    }//GEN-LAST:event_OverlayFileButtonActionPerformed

    private void SpatialPlotButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_SpatialPlotButtonActionPerformed
        SpatialPlotOptions spOptions = new SpatialPlotOptions(this);
        spOptions.setVisible(true);
    }//GEN-LAST:event_SpatialPlotButtonActionPerformed

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
            SelectAdditionalProjectComboBox1.removeAllItems();
            SelectAdditionalProjectComboBox2.removeAllItems();
            SelectAdditionalProjectComboBox3.removeAllItems();
            SelectAdditionalProjectComboBox4.removeAllItems();
            SelectAdditionalProjectComboBox5.removeAllItems();
            SelectAdditionalProjectComboBox6.removeAllItems();
            try {
                DBConnection db = new DBConnection();
                db.getDBConnection();
                db.query("USE " + dbase + ";");
                db.query("SELECT proj_code, user_id, DATE_FORMAT(proj_date,'%m/%d/%Y'), proj_time, description FROM aq_project_log ORDER BY proj_code");
                ResultSet rs = db.getRS();
                ResultSetMetaData rsmd = rs.getMetaData();
                
                SelectProjectComboBox.addItem(new ComboItem("Choose a Project", "Choose a Project"));
                int columnsNumber = rsmd.getColumnCount();
                while (rs.next()) {
                    String columnValue = rs.getString(1);
                    SelectProjectComboBox.addItem(new ComboItem("Project ID: " + rs.getString(1) + ", User ID: " + rs.getString(2) + ", SetupDate: " + rs.getString(3), rs.getString(1) ));
                }

                SelectAdditionalProjectComboBox1.addItem("");
                SelectAdditionalProjectComboBox2.addItem("");
                SelectAdditionalProjectComboBox3.addItem("");
                SelectAdditionalProjectComboBox4.addItem("");
                SelectAdditionalProjectComboBox5.addItem("");
                SelectAdditionalProjectComboBox6.addItem("");

                for (int i = 1; i < SelectProjectComboBox.getItemCount(); i++) {
                    SelectAdditionalProjectComboBox1.addItem(SelectProjectComboBox.getItemAt(i).toString());
                    SelectAdditionalProjectComboBox2.addItem(SelectProjectComboBox.getItemAt(i).toString());
                    SelectAdditionalProjectComboBox3.addItem(SelectProjectComboBox.getItemAt(i).toString());
                    SelectAdditionalProjectComboBox4.addItem(SelectProjectComboBox.getItemAt(i).toString());
                    SelectAdditionalProjectComboBox5.addItem(SelectProjectComboBox.getItemAt(i).toString());
                    SelectAdditionalProjectComboBox6.addItem(SelectProjectComboBox.getItemAt(i).toString());
                }

                db.closeDBConnection(); 

            } catch (SQLException e) {

            }
        }
        
        setCursor(Cursor.getPredefinedCursor(Cursor.DEFAULT_CURSOR));
    }//GEN-LAST:event_SelectDatabaseComboBoxItemStateChanged

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
            String database = SelectDatabaseComboBox.getSelectedItem().toString();
            DBConnection db = new DBConnection();
            db.getDBConnection();
            db.query("USE " + database + ";");
            db.query("SELECT proj_code,user_id,model,email,description,DATE_FORMAT(proj_date,'%m/%d/%Y'),proj_time,DATE_FORMAT(min_date,'%m/%d/%Y'),DATE_FORMAT(max_date,'%m/%d/%Y') FROM aq_project_log WHERE proj_code = '" + project_id + "';");
            ResultSet rs = db.getRS();
            
            while (rs.next()) {
                ProjectDetailsTextArea.setText( ""
                    + "Project ID: " + rs.getString(1) + "\n"
                    + "Owner: " + rs.getString(2) + "\n"
                    + "Model: " + rs.getString(3) + "\n"
                    + "Description: " + rs.getString(4) + "\n"
                    + "Project Creation Date: " + rs.getString(5) + "\n"
                    + "Earliest Record: " + rs.getString(8) + "\n"
                    + "Latest Record: " + rs.getString(9) + "\n"
                );
                //Save Project Dates
                year_start = rs.getString(8).substring(6, 10);
                month_start = rs.getString(8).substring(0, 2);
                day_start = rs.getString(8).substring(3, 5);

                year_end = rs.getString(9).substring(6, 10);
                month_end  = rs.getString(9).substring(0, 2);
                day_end  = rs.getString(9).substring(3, 5);
            }
            
            //Auto set the dates for the project
            StartDatePicker.setText(year_start + "/" + month_start + "/" + day_start);
            EndDatePicker.setText(year_end + "/" + month_end + "/" + day_end);
            
            
            db.closeDBConnection(); 
            
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Query Failed");
        }
        
        //Populates species combo box
        try {
            DBConnection db = new DBConnection();
            db.getDBConnection();
            db.query("USE " + dbase + ";");
            db.query("SELECT COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='" + dbase + "' and TABLE_NAME='" + project_id + "' and COLUMN_NAME like '%_ob'order by COLUMN_NAME");

            ResultSet rs = db.getRS();
            ResultSetMetaData rsmd = rs.getMetaData();
            
            SpeciesComboBox1.removeAllItems();
            SpeciesComboBox2.removeAllItems();
            SpeciesComboBox1.addItem("Choose a Species");
            SpeciesComboBox2.addItem("Choose a Species");
                while (rs.next()) {
                    String str = rs.getString(1);
                    str = str.replace("-", "_");
                    str = str.replace(".", "_");
                    str = str.replace("_ob", "");
                    SpeciesComboBox1.addItem(str);
                    SpeciesComboBox2.addItem(str);
                }
        } catch (SQLException e) {
            errorWindow("SQLException", "Problem when trying to populate the species, table containing species possibly does not exist");
        }
        
        setCursor(Cursor.getPredefinedCursor(Cursor.DEFAULT_CURSOR));
    }//GEN-LAST:event_SelectProjectComboBoxItemStateChanged

    private void RunProgramButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_RunProgramButtonActionPerformed
         saveVariables();
        if (!checkVariables()) {
            createRunInfo();
            executeProgram();
            outputWindow();
        }
    }//GEN-LAST:event_RunProgramButtonActionPerformed

    private void AxisOptionsButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_AxisOptionsButtonActionPerformed
       AxisOptionsPlots aoPlots = new AxisOptionsPlots(this);
       aoPlots.setVisible(true);
    }//GEN-LAST:event_AxisOptionsButtonActionPerformed

    private void ModelEvalOptionsButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ModelEvalOptionsButtonActionPerformed
        ModelEvalOptions meosPlots = new ModelEvalOptions(this);
        meosPlots.setVisible(true);
    }//GEN-LAST:event_ModelEvalOptionsButtonActionPerformed

    private void ClearFilesTextFieldFocusLost(java.awt.event.FocusEvent evt) {//GEN-FIRST:event_ClearFilesTextFieldFocusLost
        dir_name_delete = ClearFilesTextField.getText();
        dir_path = "guidir."  + username + "." + dir_name_delete;
        path = config.dir_name  + username + "." + dir_name_delete;
    }//GEN-LAST:event_ClearFilesTextFieldFocusLost

    private void ClearFilesButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ClearFilesButtonActionPerformed
        ClearFilesWindow cfw = new ClearFilesWindow(dir_path, path);
        cfw.setVisible(true);
    }//GEN-LAST:event_ClearFilesButtonActionPerformed

    private void ReturnButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ReturnButtonActionPerformed
        new WelcomeScreen().setVisible(true);
        setVisible(false);
        dispose();
    }//GEN-LAST:event_ReturnButtonActionPerformed

    private void AQSiteFinderButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_AQSiteFinderButtonActionPerformed
        ProgramComboBox.setSelectedIndex(0);
        run_program = "AQ_kml.R";

        saveVariables();

        createRunInfo();
        executeProgram();

        outputWindow();
    }//GEN-LAST:event_AQSiteFinderButtonActionPerformed


    
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JCheckBox ADMNCheckBox;
    private javax.swing.JCheckBox AERONETCheckBox;
    private javax.swing.JCheckBox AGANETCheckBox;
    private javax.swing.JCheckBox AIRMONCheckBox;
    private javax.swing.JCheckBox AMONCheckBox;
    private javax.swing.JTabbedPane AQFormTabbedPane;
    private javax.swing.JLabel AQNetworkInfoLabel;
    private javax.swing.JLabel AQNetworkLabel;
    private javax.swing.JPanel AQNetworkPanel;
    private javax.swing.JPanel AQNetworkSpeciesTab;
    private javax.swing.JCheckBox AQSDailyCheckBox;
    private javax.swing.JCheckBox AQSDailyDailyO3OldCheckBox;
    private javax.swing.JCheckBox AQSDailyO3CheckBox;
    private javax.swing.JCheckBox AQSDailyOAQPSCheckBox;
    private javax.swing.JCheckBox AQSDailyOldCheckBox;
    private javax.swing.JCheckBox AQSHourlyCheckBox;
    private javax.swing.JButton AQSiteFinderButton;
    private javax.swing.JCheckBox AURNDailyCheckBox;
    private javax.swing.JCheckBox AURNHourlyCheckBox;
    private javax.swing.JLabel AdvancedPlotLabel;
    private javax.swing.JButton AdvancedSpeciesButton1;
    private javax.swing.JButton AdvancedSpeciesButton2;
    private javax.swing.JButton AerosolMapButton;
    private javax.swing.JCheckBox AggregateDataCheckBox;
    private javax.swing.JLabel AggregateDataLabel;
    private javax.swing.JTextArea AggregateDataTextArea;
    private javax.swing.JCheckBox AirBaseDailyCheckBox;
    private javax.swing.JCheckBox AirBaseHourlyCheckBox;
    private javax.swing.JButton AxisOptionsButton;
    private javax.swing.JPanel Back;
    private javax.swing.JCheckBox CALNEXCheckBox;
    private javax.swing.JCheckBox CAPMoNCheckBox;
    private javax.swing.JCheckBox CASTNetCheckBox;
    private javax.swing.JCheckBox CASTNetDailyCheckBox;
    private javax.swing.JCheckBox CASTNetDryDepCheckBox;
    private javax.swing.JCheckBox CASTNetHourlyCheckBox;
    private javax.swing.JCheckBox CSNCheckBox;
    private javax.swing.JLabel CampainsLabel;
    private javax.swing.JPanel CampainsPanel;
    private javax.swing.JButton ClearFilesButton;
    private javax.swing.JLabel ClearFilesLabel;
    private javax.swing.JTextField ClearFilesTextField;
    private javax.swing.JComboBox<String> ClimateComboBox;
    private javax.swing.JLabel ClimateInfoLabel;
    private javax.swing.JLabel ClimateLabel;
    private javax.swing.JLabel CustomDirectoryNameLabel;
    private javax.swing.JTextField CustomDirectoryNameTextField;
    private javax.swing.JLabel CustomGraphTitleLabel;
    private javax.swing.JLabel CustomGraphTitleLabel1;
    private javax.swing.JTextField CustomGraphTitleTextField;
    private javax.swing.JTextArea CustomMySQLQueryExampleLabel;
    private javax.swing.JTextArea CustomMySQLQueryInfoLabel1;
    private javax.swing.JTextArea CustomMySQLQueryInfoLabel2;
    private javax.swing.JLabel CustomMySQLQueryLabel1;
    public javax.swing.JTextField CustomMySQLQueryTextField;
    private javax.swing.JLabel DataFormattingLabel;
    private javax.swing.JPanel DatabaseProjectTab;
    private javax.swing.JLabel DateRangeLabel;
    private javax.swing.JPanel DateRangePanel;
    private javax.swing.JPanel DateTimeTab;
    private javax.swing.JComboBox<String> DiscoverAQComboBox;
    private javax.swing.JLabel DiscoverAQLabel;
    private javax.swing.JCheckBox EMEPDailyCheckBox;
    private javax.swing.JCheckBox EMEPDailyO3CheckBox;
    private javax.swing.JCheckBox EMEPHourlyCheckBox;
    private javax.swing.JLabel EndDateLabel;
    private com.github.lgooddatepicker.components.DatePicker EndDatePicker;
    private javax.swing.JComboBox<String> EndHourComboBox;
    private javax.swing.JLabel EndHourLabel;
    private javax.swing.JLabel EuropeanNetworkInfoLabel;
    private javax.swing.JLabel EuropeanNetworkLabel;
    private javax.swing.JPanel EuropeanNetworkPanel;
    private javax.swing.JPanel EuropeanNetworkTab;
    private javax.swing.JCheckBox FluxNetCheckBox;
    private javax.swing.JLabel Footer;
    private javax.swing.JLabel Header;
    private javax.swing.JLabel HeightLabel;
    private javax.swing.JTextField HeightTextField;
    private javax.swing.JLabel HourRangeLabel;
    private javax.swing.JPanel HourRangePanel;
    private javax.swing.JTextArea HourRangeTextArea;
    private javax.swing.JCheckBox IMPROVECheckBox;
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
    private javax.swing.JCheckBox MDNCheckBox;
    private javax.swing.JButton ModelEvalOptionsButton;
    private javax.swing.JCheckBox ModelModelCheckBox;
    private javax.swing.JComboBox<String> MonthlyComboBox;
    private javax.swing.JLabel MonthlyLabel;
    private javax.swing.JTextArea MonthlyTextArea;
    private javax.swing.JCheckBox NADPCheckBox;
    private javax.swing.JCheckBox NAPSDailyO3CheckBox;
    private javax.swing.JCheckBox NAPSHourlyCheckBox;
    private javax.swing.JCheckBox NOAAESRLCheckBox;
    private javax.swing.JComboBox<String> NegativeValuesComboBox;
    private javax.swing.JLabel NegativeValuesLabel;
    private javax.swing.JTextArea NegativeValuesTextArea;
    private javax.swing.JButton OverlayFileButton;
    private javax.swing.JButton OzoneMapButton;
    private javax.swing.JComboBox<String> PCAComboBox;
    private javax.swing.JLabel PCAInfoLabel;
    private javax.swing.JLabel PCALabel;
    private javax.swing.JComboBox<String> PNGQualityComboBox;
    private javax.swing.JLabel PNGQualityLabel;
    private javax.swing.JTextArea PNGQualityTextArea;
    private javax.swing.JComboBox<String> POCodeComboBox;
    private javax.swing.JLabel POCodeLabel;
    private javax.swing.JTextArea POCodeTextArea;
    private javax.swing.JTextArea PlotlyIamgeInfoTextArea;
    private javax.swing.JLabel PlotlyImageLabel;
    private javax.swing.JPanel PlotlyImagePanel;
    private javax.swing.JComboBox<String> ProgramComboBox;
    private javax.swing.JLabel ProgramLabel;
    private javax.swing.JPanel ProgramTab;
    private javax.swing.JTextArea ProgramTextArea;
    private javax.swing.JLabel ProjectDetailsLabel;
    private javax.swing.JScrollPane ProjectDetailsScrollPane;
    private javax.swing.JTextArea ProjectDetailsTextArea;
    private javax.swing.JComboBox<String> RPOComboBox;
    private javax.swing.JLabel RPOInfoLabel;
    private javax.swing.JLabel RPOLabel;
    private javax.swing.JPanel RegionAreaTab;
    private javax.swing.JButton ReturnButton;
    private javax.swing.JButton RunProgramButton;
    private javax.swing.JCheckBox SEARCHDailyCheckBox;
    private javax.swing.JCheckBox SEARCHHourlyCheckBox;
    private javax.swing.JCheckBox SOASCheckBox;
    private javax.swing.JButton ScatterPlotButton;
    private javax.swing.JComboBox<String> SeasonalComboBox;
    private javax.swing.JLabel SeasonalLabel;
    private javax.swing.JTextArea SeasonalTextArea;
    private javax.swing.JComboBox<String> SelectAdditionalProjectComboBox1;
    private javax.swing.JComboBox<String> SelectAdditionalProjectComboBox2;
    private javax.swing.JComboBox<String> SelectAdditionalProjectComboBox3;
    private javax.swing.JComboBox<String> SelectAdditionalProjectComboBox4;
    private javax.swing.JComboBox<String> SelectAdditionalProjectComboBox5;
    private javax.swing.JComboBox<String> SelectAdditionalProjectComboBox6;
    private javax.swing.JLabel SelectAdditionalProjectLabel;
    private javax.swing.JComboBox<String> SelectDatabaseComboBox;
    private javax.swing.JLabel SelectDatabaseLabel;
    private javax.swing.JComboBox<ComboItem> SelectProjectComboBox;
    private javax.swing.JLabel SelectProjectLabel;
    private javax.swing.JLabel SiteIDLabel;
    private javax.swing.JPanel SiteIDTab;
    private javax.swing.JTextArea SiteIDTextArea;
    private javax.swing.JTextArea SiteIDTextArea2;
    private javax.swing.JTextField SiteIDTextField;
    private javax.swing.JComboBox<String> SiteLanduseComboBox;
    private javax.swing.JLabel SiteLanduseLabel;
    private javax.swing.JTextArea SiteLanduseTextArea;
    private javax.swing.JButton SoccergoalBuglePlotButton;
    private javax.swing.JButton SpatialPlotButton;
    private javax.swing.JCheckBox SpecialCheckBox;
    private javax.swing.JComboBox<String> SpeciesComboBox1;
    private javax.swing.JComboBox<String> SpeciesComboBox2;
    private javax.swing.JLabel SpeciesLabel1;
    private javax.swing.JLabel SpeciesLabel2;
    private javax.swing.JPanel SpeciesPanel;
    private javax.swing.JLabel StartDateLabel;
    private com.github.lgooddatepicker.components.DatePicker StartDatePicker;
    private javax.swing.JComboBox<String> StartHourComboBox;
    private javax.swing.JLabel StartHourLabel;
    private javax.swing.JComboBox<String> StateComboBox;
    private javax.swing.JLabel StateInfoLabel;
    private javax.swing.JLabel StateLabel;
    private javax.swing.JComboBox<String> SubsetComboBox;
    private javax.swing.JLabel SubsetLabel;
    private javax.swing.JCheckBox TOARCheckBox;
    private javax.swing.JComboBox<String> TemporalAveragingComboBox;
    private javax.swing.JLabel TemporalAveragingLabel;
    private javax.swing.JTextArea TemporalAveragingTextArea;
    private javax.swing.JCheckBox ToxicsCheckBox;
    private javax.swing.JLabel WidthLabel;
    private javax.swing.JTextField WidthTextField;
    private javax.swing.JComboBox<String> WorldComboBox;
    private javax.swing.JLabel WorldInfoLabel;
    private javax.swing.JLabel WorldLabel;
    private javax.swing.ButtonGroup buttonGroup1;
    private javax.swing.JPanel jPanel1;
    // End of variables declaration//GEN-END:variables
}

//Class used for making combobox items contain a hidden value seperate from what appears in the GUI
class ComboItem {
    private String key;
    private String value;

    public ComboItem(String key, String value) {
        this.key = key;
        this.value = value;
    }

    @Override
    public String toString() {
        return value;
    }

    public String getKey() {
        return key;
    }

    public String getValue() {
        return value;
    }
}