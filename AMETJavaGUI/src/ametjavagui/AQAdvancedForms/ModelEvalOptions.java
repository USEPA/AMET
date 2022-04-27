/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ametjavagui.AQAdvancedForms;

import ametjavagui.AirQualityForm;

/**
 *
 * @author MMORTO01
 */
public class ModelEvalOptions extends javax.swing.JFrame {

    /**
     * Creates new form ModelEvalOptionsStatsPlots
     */
    
    AirQualityForm form;
    
    public ModelEvalOptions(AirQualityForm form) {
        this.form = form;
        initComponents();
    }

    /**
     * This method is called from within the constructor to initialize the form. WARNING: Do NOT modify this code. The content of this method is always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jPanel1 = new javax.swing.JPanel();
        ScatterPlotOptionsLabel = new javax.swing.JLabel();
        RunInfoCheckBox = new javax.swing.JCheckBox();
        ZeroPrecipCheckBox = new javax.swing.JCheckBox();
        ZeroPrecipLabel = new javax.swing.JTextArea();
        ValidObsCheckBox = new javax.swing.JCheckBox();
        ValidObsLabel = new javax.swing.JTextArea();
        MinCompletenessLabel = new javax.swing.JTextArea();
        MinCompletenessTextField = new javax.swing.JTextField();
        MinNumObsLabel = new javax.swing.JTextArea();
        MinNumObsTextField = new javax.swing.JTextField();
        BoxPlotOptionsLabel = new javax.swing.JLabel();
        IncludeWhiskersCheckBox = new javax.swing.JCheckBox();
        IncludeQuartileRangeCheckBox = new javax.swing.JCheckBox();
        IncludeMedianCheckBox = new javax.swing.JCheckBox();
        SubtractMeanCheckBox = new javax.swing.JCheckBox();
        OverlapBoxesCheckBox = new javax.swing.JCheckBox();
        SaveButton = new javax.swing.JButton();
        CancelButton = new javax.swing.JButton();
        jPanel2 = new javax.swing.JPanel();
        StackedBarchartOptionsLabel = new javax.swing.JLabel();
        IncludeFRMCheckBox = new javax.swing.JCheckBox();
        UseMedianCheckBox = new javax.swing.JCheckBox();
        TimeSeriesPlotOptionsLabel = new javax.swing.JLabel();
        AvergaingFunctionLabel = new javax.swing.JTextArea();
        AveragingFunctionComboBox = new javax.swing.JComboBox<>();
        IncludeLegendCheckBox = new javax.swing.JCheckBox();
        IncludePointsCheckBox = new javax.swing.JCheckBox();
        IncludeBiasCheckBox = new javax.swing.JCheckBox();
        IncludeRMSECheckBox = new javax.swing.JCheckBox();
        IncludeCorrelationCheckBox = new javax.swing.JCheckBox();
        SubtractPeriodMeanCheckBox = new javax.swing.JCheckBox();
        MinLimitNumRecordsLabel = new javax.swing.JTextArea();
        MinLimitNumRecordsTextField = new javax.swing.JTextField();
        LineWidthsLabel = new javax.swing.JTextArea();
        LineWidthsTextField = new javax.swing.JTextField();

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        setTitle("Model Evaluation Options");
        setAlwaysOnTop(true);
        setResizable(false);

        jPanel1.setBackground(new java.awt.Color(255, 255, 255));
        jPanel1.setForeground(new java.awt.Color(255, 255, 255));
        jPanel1.setPreferredSize(new java.awt.Dimension(553, 660));

        ScatterPlotOptionsLabel.setBackground(new java.awt.Color(255, 255, 255));
        ScatterPlotOptionsLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        ScatterPlotOptionsLabel.setForeground(new java.awt.Color(0, 112, 185));
        ScatterPlotOptionsLabel.setText("Scatter Plot Options");

        RunInfoCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        RunInfoCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        RunInfoCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        RunInfoCheckBox.setSelected(true);
        RunInfoCheckBox.setText("Include run info text on plots.");

        ZeroPrecipCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        ZeroPrecipCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ZeroPrecipCheckBox.setForeground(new java.awt.Color(255, 255, 255));

        ZeroPrecipLabel.setEditable(false);
        ZeroPrecipLabel.setBackground(new java.awt.Color(255, 255, 255));
        ZeroPrecipLabel.setColumns(20);
        ZeroPrecipLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        ZeroPrecipLabel.setForeground(new java.awt.Color(0, 112, 185));
        ZeroPrecipLabel.setLineWrap(true);
        ZeroPrecipLabel.setRows(5);
        ZeroPrecipLabel.setText("Do not include zero precipitation observations in analysis. Only use when precipitation data are available (e.g. NAPD, AIRMON).");
        ZeroPrecipLabel.setWrapStyleWord(true);
        ZeroPrecipLabel.setMaximumSize(new java.awt.Dimension(490, 42));
        ZeroPrecipLabel.setMinimumSize(new java.awt.Dimension(490, 42));

        ValidObsCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        ValidObsCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        ValidObsCheckBox.setForeground(new java.awt.Color(255, 255, 255));
        ValidObsCheckBox.setSelected(true);

        ValidObsLabel.setEditable(false);
        ValidObsLabel.setBackground(new java.awt.Color(255, 255, 255));
        ValidObsLabel.setColumns(20);
        ValidObsLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        ValidObsLabel.setForeground(new java.awt.Color(0, 112, 185));
        ValidObsLabel.setLineWrap(true);
        ValidObsLabel.setRows(5);
        ValidObsLabel.setText("Include only and all valid observations in the analysis based on availabel valid codes (obs w/ missing valid codes are considered valid). Currently applies to only NADP, MDN and AMON networks. ");
        ValidObsLabel.setWrapStyleWord(true);
        ValidObsLabel.setMaximumSize(new java.awt.Dimension(490, 56));
        ValidObsLabel.setMinimumSize(new java.awt.Dimension(490, 56));

        MinCompletenessLabel.setEditable(false);
        MinCompletenessLabel.setBackground(new java.awt.Color(255, 255, 255));
        MinCompletenessLabel.setColumns(20);
        MinCompletenessLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        MinCompletenessLabel.setForeground(new java.awt.Color(0, 112, 185));
        MinCompletenessLabel.setLineWrap(true);
        MinCompletenessLabel.setRows(5);
        MinCompletenessLabel.setText("Enter minimum completeness (as a %) for site specific calculations (e.g. at least 3 of 4 obs = 75%). Note that this criteria does not apply to bulk domain computed statistics, only site specific calculations.");
        MinCompletenessLabel.setWrapStyleWord(true);
        MinCompletenessLabel.setMaximumSize(new java.awt.Dimension(490, 56));
        MinCompletenessLabel.setMinimumSize(new java.awt.Dimension(490, 56));

        MinCompletenessTextField.setBackground(new java.awt.Color(191, 182, 172));
        MinCompletenessTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        MinCompletenessTextField.setForeground(new java.awt.Color(0, 63, 105));
        MinCompletenessTextField.setText("75");
        MinCompletenessTextField.setMinimumSize(new java.awt.Dimension(150, 23));
        MinCompletenessTextField.setPreferredSize(new java.awt.Dimension(150, 23));

        MinNumObsLabel.setEditable(false);
        MinNumObsLabel.setBackground(new java.awt.Color(255, 255, 255));
        MinNumObsLabel.setColumns(20);
        MinNumObsLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        MinNumObsLabel.setForeground(new java.awt.Color(0, 112, 185));
        MinNumObsLabel.setLineWrap(true);
        MinNumObsLabel.setRows(5);
        MinNumObsLabel.setText("Enter minimum number of observations required for site statistics calculations (default is set at 1 which would include all sites that meet the completeness criteria above).");
        MinNumObsLabel.setWrapStyleWord(true);
        MinNumObsLabel.setMaximumSize(new java.awt.Dimension(509, 56));
        MinNumObsLabel.setMinimumSize(new java.awt.Dimension(509, 56));
        MinNumObsLabel.setPreferredSize(new java.awt.Dimension(509, 56));

        MinNumObsTextField.setBackground(new java.awt.Color(191, 182, 172));
        MinNumObsTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        MinNumObsTextField.setForeground(new java.awt.Color(0, 63, 105));
        MinNumObsTextField.setText("1");
        MinNumObsTextField.setMinimumSize(new java.awt.Dimension(150, 23));
        MinNumObsTextField.setPreferredSize(new java.awt.Dimension(150, 23));

        BoxPlotOptionsLabel.setBackground(new java.awt.Color(255, 255, 255));
        BoxPlotOptionsLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        BoxPlotOptionsLabel.setForeground(new java.awt.Color(0, 112, 185));
        BoxPlotOptionsLabel.setText("Box Plot Options");

        IncludeWhiskersCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        IncludeWhiskersCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        IncludeWhiskersCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        IncludeWhiskersCheckBox.setText("Include whiskers on box plots.");

        IncludeQuartileRangeCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        IncludeQuartileRangeCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        IncludeQuartileRangeCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        IncludeQuartileRangeCheckBox.setSelected(true);
        IncludeQuartileRangeCheckBox.setText("Include 25-75% quartile ranges on box plots.");
        IncludeQuartileRangeCheckBox.setToolTipText("");

        IncludeMedianCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        IncludeMedianCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        IncludeMedianCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        IncludeMedianCheckBox.setText("Include median line on box plot.");
        IncludeMedianCheckBox.setActionCommand("Include median line on box plots.");

        SubtractMeanCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        SubtractMeanCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SubtractMeanCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        SubtractMeanCheckBox.setText(" Subtract mean from Hourly Boxplot or Spatial Plot scripts. ");

        OverlapBoxesCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        OverlapBoxesCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        OverlapBoxesCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        OverlapBoxesCheckBox.setText(" Overlap boxes in GGplot box plots.");

        SaveButton.setBackground(new java.awt.Color(0, 63, 105));
        SaveButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        SaveButton.setForeground(new java.awt.Color(191, 182, 172));
        SaveButton.setText("Save");
        SaveButton.setMaximumSize(new java.awt.Dimension(100, 26));
        SaveButton.setMinimumSize(new java.awt.Dimension(100, 26));
        SaveButton.setPreferredSize(new java.awt.Dimension(100, 26));
        SaveButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                SaveButtonActionPerformed(evt);
            }
        });

        CancelButton.setBackground(new java.awt.Color(0, 63, 105));
        CancelButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        CancelButton.setForeground(new java.awt.Color(191, 182, 172));
        CancelButton.setText("Cancel");
        CancelButton.setMaximumSize(new java.awt.Dimension(100, 26));
        CancelButton.setMinimumSize(new java.awt.Dimension(100, 26));
        CancelButton.setPreferredSize(new java.awt.Dimension(100, 26));
        CancelButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                CancelButtonActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(ScatterPlotOptionsLabel)
                    .addComponent(RunInfoCheckBox)
                    .addComponent(BoxPlotOptionsLabel)
                    .addComponent(IncludeWhiskersCheckBox)
                    .addComponent(IncludeQuartileRangeCheckBox)
                    .addComponent(IncludeMedianCheckBox)
                    .addComponent(SubtractMeanCheckBox)
                    .addComponent(OverlapBoxesCheckBox)
                    .addGroup(jPanel1Layout.createSequentialGroup()
                        .addComponent(SaveButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(40, 40, 40)
                        .addComponent(CancelButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(jPanel1Layout.createSequentialGroup()
                        .addGap(6, 6, 6)
                        .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(MinCompletenessTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(MinNumObsTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                    .addComponent(MinCompletenessLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 490, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGroup(jPanel1Layout.createSequentialGroup()
                        .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(ZeroPrecipCheckBox)
                            .addComponent(ValidObsCheckBox))
                        .addGap(0, 0, 0)
                        .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(ValidObsLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 490, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(ZeroPrecipLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 490, javax.swing.GroupLayout.PREFERRED_SIZE)))
                    .addComponent(MinNumObsLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(0, 38, Short.MAX_VALUE))
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(ScatterPlotOptionsLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(RunInfoCheckBox)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel1Layout.createSequentialGroup()
                        .addGap(27, 27, 27)
                        .addComponent(ZeroPrecipCheckBox)
                        .addGap(38, 38, 38)
                        .addComponent(ValidObsCheckBox))
                    .addGroup(jPanel1Layout.createSequentialGroup()
                        .addGap(18, 18, 18)
                        .addComponent(ZeroPrecipLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 42, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ValidObsLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 56, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addGap(12, 12, 12)
                .addComponent(MinCompletenessLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 68, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(MinCompletenessTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(MinNumObsLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 56, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(MinNumObsTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(BoxPlotOptionsLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(IncludeWhiskersCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(IncludeQuartileRangeCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(IncludeMedianCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(SubtractMeanCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(OverlapBoxesCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 20, Short.MAX_VALUE)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(SaveButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(CancelButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(26, 26, 26))
        );

        jPanel2.setBackground(new java.awt.Color(255, 255, 255));
        jPanel2.setPreferredSize(new java.awt.Dimension(502, 660));

        StackedBarchartOptionsLabel.setBackground(new java.awt.Color(255, 255, 255));
        StackedBarchartOptionsLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        StackedBarchartOptionsLabel.setForeground(new java.awt.Color(0, 112, 185));
        StackedBarchartOptionsLabel.setText("Stacked Barchart Options");

        IncludeFRMCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        IncludeFRMCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        IncludeFRMCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        IncludeFRMCheckBox.setSelected(true);
        IncludeFRMCheckBox.setText(" Include CSN FRM adjustment.");

        UseMedianCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        UseMedianCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        UseMedianCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        UseMedianCheckBox.setText("Use median instead of mean.");

        TimeSeriesPlotOptionsLabel.setBackground(new java.awt.Color(255, 255, 255));
        TimeSeriesPlotOptionsLabel.setFont(new java.awt.Font("Times New Roman", 1, 18)); // NOI18N
        TimeSeriesPlotOptionsLabel.setForeground(new java.awt.Color(0, 112, 185));
        TimeSeriesPlotOptionsLabel.setText("Time Series Plot Options");

        AvergaingFunctionLabel.setEditable(false);
        AvergaingFunctionLabel.setBackground(new java.awt.Color(255, 255, 255));
        AvergaingFunctionLabel.setColumns(20);
        AvergaingFunctionLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        AvergaingFunctionLabel.setForeground(new java.awt.Color(0, 112, 185));
        AvergaingFunctionLabel.setLineWrap(true);
        AvergaingFunctionLabel.setRows(5);
        AvergaingFunctionLabel.setText("Choose which averaging function to plot on the time series (note that the sum option averages the domain-wide sum by the number of sites).");
        AvergaingFunctionLabel.setWrapStyleWord(true);
        AvergaingFunctionLabel.setMaximumSize(new java.awt.Dimension(490, 42));
        AvergaingFunctionLabel.setMinimumSize(new java.awt.Dimension(490, 42));

        AveragingFunctionComboBox.setBackground(new java.awt.Color(191, 182, 172));
        AveragingFunctionComboBox.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        AveragingFunctionComboBox.setForeground(new java.awt.Color(0, 63, 105));
        AveragingFunctionComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Mean", "Median", "Sum" }));
        AveragingFunctionComboBox.setMinimumSize(new java.awt.Dimension(150, 23));
        AveragingFunctionComboBox.setPreferredSize(new java.awt.Dimension(150, 23));

        IncludeLegendCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        IncludeLegendCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        IncludeLegendCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        IncludeLegendCheckBox.setSelected(true);
        IncludeLegendCheckBox.setText("Include legend on time series plots.");

        IncludePointsCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        IncludePointsCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        IncludePointsCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        IncludePointsCheckBox.setSelected(true);
        IncludePointsCheckBox.setText("Include points on time series plots.");

        IncludeBiasCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        IncludeBiasCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        IncludeBiasCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        IncludeBiasCheckBox.setSelected(true);
        IncludeBiasCheckBox.setText("Include bias on interactive time series plots.");

        IncludeRMSECheckBox.setBackground(new java.awt.Color(255, 255, 255));
        IncludeRMSECheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        IncludeRMSECheckBox.setForeground(new java.awt.Color(0, 112, 185));
        IncludeRMSECheckBox.setText("Include RMSE on interactive time series plots.");

        IncludeCorrelationCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        IncludeCorrelationCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        IncludeCorrelationCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        IncludeCorrelationCheckBox.setText("Include Correlation on interactive time series plots.");

        SubtractPeriodMeanCheckBox.setBackground(new java.awt.Color(255, 255, 255));
        SubtractPeriodMeanCheckBox.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        SubtractPeriodMeanCheckBox.setForeground(new java.awt.Color(0, 112, 185));
        SubtractPeriodMeanCheckBox.setText("Subtract period mean from time series plots.");

        MinLimitNumRecordsLabel.setEditable(false);
        MinLimitNumRecordsLabel.setBackground(new java.awt.Color(255, 255, 255));
        MinLimitNumRecordsLabel.setColumns(20);
        MinLimitNumRecordsLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        MinLimitNumRecordsLabel.setForeground(new java.awt.Color(0, 112, 185));
        MinLimitNumRecordsLabel.setLineWrap(true);
        MinLimitNumRecordsLabel.setRows(5);
        MinLimitNumRecordsLabel.setText("Specify minimum limit on number of records per time unit (e.g. day) to include.");
        MinLimitNumRecordsLabel.setWrapStyleWord(true);

        MinLimitNumRecordsTextField.setBackground(new java.awt.Color(191, 182, 172));
        MinLimitNumRecordsTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        MinLimitNumRecordsTextField.setForeground(new java.awt.Color(0, 63, 105));
        MinLimitNumRecordsTextField.setText("0");
        MinLimitNumRecordsTextField.setMinimumSize(new java.awt.Dimension(150, 23));
        MinLimitNumRecordsTextField.setPreferredSize(new java.awt.Dimension(150, 23));

        LineWidthsLabel.setEditable(false);
        LineWidthsLabel.setBackground(new java.awt.Color(255, 255, 255));
        LineWidthsLabel.setColumns(20);
        LineWidthsLabel.setFont(new java.awt.Font("Times New Roman", 1, 12)); // NOI18N
        LineWidthsLabel.setForeground(new java.awt.Color(0, 112, 185));
        LineWidthsLabel.setLineWrap(true);
        LineWidthsLabel.setRows(5);
        LineWidthsLabel.setText("Specify line widths for time series plots.");
        LineWidthsLabel.setWrapStyleWord(true);

        LineWidthsTextField.setBackground(new java.awt.Color(191, 182, 172));
        LineWidthsTextField.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        LineWidthsTextField.setForeground(new java.awt.Color(0, 63, 105));
        LineWidthsTextField.setText("1");
        LineWidthsTextField.setMinimumSize(new java.awt.Dimension(150, 23));
        LineWidthsTextField.setPreferredSize(new java.awt.Dimension(150, 23));

        javax.swing.GroupLayout jPanel2Layout = new javax.swing.GroupLayout(jPanel2);
        jPanel2.setLayout(jPanel2Layout);
        jPanel2Layout.setHorizontalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel2Layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel2Layout.createSequentialGroup()
                        .addGap(6, 6, 6)
                        .addComponent(AveragingFunctionComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                    .addGroup(jPanel2Layout.createSequentialGroup()
                        .addGroup(jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(MinLimitNumRecordsLabel)
                            .addComponent(AvergaingFunctionLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(LineWidthsLabel)
                            .addGroup(jPanel2Layout.createSequentialGroup()
                                .addGroup(jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addComponent(StackedBarchartOptionsLabel)
                                    .addComponent(IncludeFRMCheckBox)
                                    .addComponent(UseMedianCheckBox)
                                    .addComponent(TimeSeriesPlotOptionsLabel)
                                    .addComponent(IncludeLegendCheckBox)
                                    .addComponent(IncludePointsCheckBox)
                                    .addComponent(IncludeBiasCheckBox)
                                    .addComponent(IncludeRMSECheckBox)
                                    .addComponent(IncludeCorrelationCheckBox)
                                    .addComponent(SubtractPeriodMeanCheckBox)
                                    .addGroup(jPanel2Layout.createSequentialGroup()
                                        .addGap(6, 6, 6)
                                        .addGroup(jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                            .addComponent(LineWidthsTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                            .addComponent(MinLimitNumRecordsTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))))
                                .addGap(0, 0, Short.MAX_VALUE)))
                        .addContainerGap())))
        );
        jPanel2Layout.setVerticalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel2Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(StackedBarchartOptionsLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(IncludeFRMCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(UseMedianCheckBox)
                .addGap(18, 18, 18)
                .addComponent(TimeSeriesPlotOptionsLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(AvergaingFunctionLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 54, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(AveragingFunctionComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(IncludeLegendCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(IncludePointsCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(IncludeBiasCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(IncludeRMSECheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(IncludeCorrelationCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(SubtractPeriodMeanCheckBox)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(MinLimitNumRecordsLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 34, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(MinLimitNumRecordsTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(LineWidthsLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 22, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(LineWidthsTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(105, Short.MAX_VALUE))
        );

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, 0)
                .addComponent(jPanel2, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
            .addComponent(jPanel2, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void SaveButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_SaveButtonActionPerformed
        form.run_info_text = form.checkBoxFormat(RunInfoCheckBox);
        form.zeroprecip = form.checkBoxFormat(ZeroPrecipCheckBox);
        form.all_valid = form.checkBoxFormat(ValidObsCheckBox);
        form.coverage_limit = form.numFormat(MinCompletenessTextField.getText());
        form.num_obs_limit = form.numFormat(MinLimitNumRecordsTextField.getText());
        form.inc_whiskers = form.checkBoxFormat(IncludeWhiskersCheckBox);
        form.inc_ranges = form.checkBoxFormat(IncludeQuartileRangeCheckBox);
        form.inc_median_lines = form.checkBoxFormat(IncludeMedianCheckBox);
        form.remove_mean = form.checkBoxFormat(SubtractMeanCheckBox);
        form.overlap_boxes = form.checkBoxFormat(OverlapBoxesCheckBox);
        form.inc_FRM_adj = form.checkBoxFormat(IncludeFRMCheckBox);
        form.use_median = form.checkBoxFormat(UseMedianCheckBox);
        form.avg_func_name = form.textFormat(AveragingFunctionComboBox.getSelectedItem().toString());
        form.avg_func = form.textFormat(AveragingFunctionComboBox.getSelectedItem().toString());
        form.inc_legend = form.checkBoxFormat(IncludeLegendCheckBox);
        form.inc_points = form.checkBoxFormat(IncludePointsCheckBox);
        form.inc_bias = form.checkBoxFormat(IncludeBiasCheckBox);
        form.inc_rmse = form.checkBoxFormat(IncludeRMSECheckBox);
        form.inc_corr = form.checkBoxFormat(IncludeCorrelationCheckBox);
        form.use_var_mean = form.checkBoxFormat(SubtractPeriodMeanCheckBox);
        form.obs_per_day_limit = form.numFormat(MinLimitNumRecordsTextField.getText());
        form.line_width = form.textFormat(LineWidthsTextField.getText());
        System.out.println("Model Evaluation Options Saved");
        setVisible(false);
        dispose();
        
    }//GEN-LAST:event_SaveButtonActionPerformed

    private void CancelButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_CancelButtonActionPerformed
        setVisible(false);
        dispose();
    }//GEN-LAST:event_CancelButtonActionPerformed

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JComboBox<String> AveragingFunctionComboBox;
    private javax.swing.JTextArea AvergaingFunctionLabel;
    private javax.swing.JLabel BoxPlotOptionsLabel;
    private javax.swing.JButton CancelButton;
    private javax.swing.JCheckBox IncludeBiasCheckBox;
    private javax.swing.JCheckBox IncludeCorrelationCheckBox;
    private javax.swing.JCheckBox IncludeFRMCheckBox;
    private javax.swing.JCheckBox IncludeLegendCheckBox;
    private javax.swing.JCheckBox IncludeMedianCheckBox;
    private javax.swing.JCheckBox IncludePointsCheckBox;
    private javax.swing.JCheckBox IncludeQuartileRangeCheckBox;
    private javax.swing.JCheckBox IncludeRMSECheckBox;
    private javax.swing.JCheckBox IncludeWhiskersCheckBox;
    private javax.swing.JTextArea LineWidthsLabel;
    private javax.swing.JTextField LineWidthsTextField;
    private javax.swing.JTextArea MinCompletenessLabel;
    private javax.swing.JTextField MinCompletenessTextField;
    private javax.swing.JTextArea MinLimitNumRecordsLabel;
    private javax.swing.JTextField MinLimitNumRecordsTextField;
    private javax.swing.JTextArea MinNumObsLabel;
    private javax.swing.JTextField MinNumObsTextField;
    private javax.swing.JCheckBox OverlapBoxesCheckBox;
    private javax.swing.JCheckBox RunInfoCheckBox;
    private javax.swing.JButton SaveButton;
    private javax.swing.JLabel ScatterPlotOptionsLabel;
    private javax.swing.JLabel StackedBarchartOptionsLabel;
    private javax.swing.JCheckBox SubtractMeanCheckBox;
    private javax.swing.JCheckBox SubtractPeriodMeanCheckBox;
    private javax.swing.JLabel TimeSeriesPlotOptionsLabel;
    private javax.swing.JCheckBox UseMedianCheckBox;
    private javax.swing.JCheckBox ValidObsCheckBox;
    private javax.swing.JTextArea ValidObsLabel;
    private javax.swing.JCheckBox ZeroPrecipCheckBox;
    private javax.swing.JTextArea ZeroPrecipLabel;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JPanel jPanel2;
    // End of variables declaration//GEN-END:variables
}
