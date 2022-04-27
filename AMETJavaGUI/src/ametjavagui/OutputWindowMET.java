/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ametjavagui;

import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.StringSelection;
import java.awt.Color;
import java.awt.Desktop;
import java.io.File;
import java.io.IOException;

/**
 *
 * @author mmorto01
 */
public class OutputWindowMET extends javax.swing.JFrame {
    
    int line = 0;
    javax.swing.JLabel[] labels = new javax.swing.JLabel[91];
    
    final Color COLOR_NORMAL = new Color(0,122,185);
    final Color COLOR_ACTIVE = new Color(0,63,105);
    
    MeteorologyForm form;

    /**
     * Creates new form OutputWindow
     */
    public OutputWindowMET(MeteorologyForm form) {
        this.form = form;
        initComponents();
        jTextArea1.setText(form.query);
        jTextArea2.setText(form.file_path);
        jLabel2.setText("Program Output (" + form.run_program + ")");
        
        System.out.println(outLabel0.getText());
        labels[0] = outLabel0;
        labels[1] = outLabel1;
        labels[2] = outLabel2;
        labels[3] = outLabel3;
        labels[4] = outLabel4;
        labels[5] = outLabel5;
        labels[6] = outLabel6;
        labels[7] = outLabel7;
        labels[8] = outLabel8;
        labels[9] = outLabel9;
        labels[10] = outLabel10;
        labels[11] = outLabel11;
        labels[12] = outLabel12;
        labels[13] = outLabel13;
        labels[14] = outLabel14;
        labels[15] = outLabel15;
        labels[16] = outLabel16;
        labels[17] = outLabel17;
        labels[18] = outLabel18;
        labels[19] = outLabel19;
        labels[20] = outLabel20;
        labels[21] = outLabel21;
        labels[22] = outLabel22;
        labels[23] = outLabel23;
        labels[24] = outLabel24;
        labels[25] = outLabel25;
        labels[26] = outLabel26;
        labels[27] = outLabel27;
        labels[28] = outLabel28;
        labels[29] = outLabel29;
        labels[30] = outLabel30;
        labels[31] = outLabel31;
        labels[32] = outLabel32;
        labels[33] = outLabel33;
        labels[34] = outLabel34;
        labels[35] = outLabel35;
        labels[36] = outLabel36;
        labels[37] = outLabel37;
        labels[38] = outLabel38;
        labels[39] = outLabel39;
        labels[40] = outLabel40;
        labels[41] = outLabel41;
        labels[42] = outLabel42;
        labels[43] = outLabel43;
        labels[44] = outLabel44;
        labels[45] = outLabel45;
        labels[46] = outLabel46;
        labels[47] = outLabel47;
        labels[48] = outLabel48;
        labels[49] = outLabel49;
        labels[50] = outLabel50;
        labels[51] = outLabel51;
        labels[52] = outLabel52;
        labels[53] = outLabel53;
        labels[54] = outLabel54;
        labels[55] = outLabel55;
        labels[56] = outLabel56;
        labels[57] = outLabel57;
        labels[58] = outLabel58;
        labels[59] = outLabel59;
        labels[60] = outLabel60;
        labels[61] = outLabel61;
        labels[62] = outLabel62;
        labels[63] = outLabel63;
        labels[64] = outLabel64;
        labels[65] = outLabel65;
        labels[66] = outLabel66;
        labels[67] = outLabel67;
        labels[68] = outLabel68;
        labels[69] = outLabel69;
        labels[70] = outLabel70;
        labels[71] = outLabel71;
        labels[72] = outLabel72;
        labels[73] = outLabel73;
        labels[74] = outLabel74;
        labels[75] = outLabel75;
        labels[76] = outLabel76;
        labels[77] = outLabel77;
        labels[78] = outLabel78;
        labels[79] = outLabel79;
        labels[80] = outLabel80;
        labels[81] = outLabel81;
        labels[82] = outLabel82;
        labels[83] = outLabel83;
        labels[84] = outLabel84;
        labels[85] = outLabel85;
        labels[86] = outLabel86;
        labels[87] = outLabel87;
        labels[88] = outLabel88;
        labels[89] = outLabel89;
        labels[90] = outLabel90;

    }
    
    public void newFile(String link, String name) {
        //see if file was created
        File myFile = new File(link);
        if (myFile.exists()) {
            labels[line].setText(name);
            labels[line].setForeground(COLOR_NORMAL);


            labels[line].addMouseListener(new java.awt.event.MouseAdapter() {
                @Override
                public void mouseClicked(java.awt.event.MouseEvent evt) {
                    evt.getComponent().setForeground(COLOR_ACTIVE);
                    outputEvent(evt, link);
                }
                public void mouseEntered(java.awt.event.MouseEvent evt) {
                    evt.getComponent().setFont(new java.awt.Font("Tahoma", 2, 11));
                }
                public void mouseExited(java.awt.event.MouseEvent evt) {
                    evt.getComponent().setFont(new java.awt.Font("Tahoma", 0, 11));
                }
            });
            line++;
        } else {
            System.out.println("File " + name + " not found!"); 
        }
    }
    
    public void checkIfSuccess() {
        if (outLabel0.getText().equals("-")) {
            outLabel0.setText("Error with creating the output files");
        }
    }
    
    private void outputEvent(java.awt.event.MouseEvent evt, String link) {
        System.out.println("clicked!");
        try {
            File myFile = new File(link);
            Desktop.getDesktop().open(myFile);
        } catch (IOException e) {
            System.out.println("File does not exist");
        }  
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jPanel1 = new javax.swing.JPanel();
        jLabel1 = new javax.swing.JLabel();
        jTextArea1 = new javax.swing.JTextArea();
        jLabel3 = new javax.swing.JLabel();
        jTextArea2 = new javax.swing.JTextArea();
        CopyButton = new javax.swing.JButton();
        jLabel2 = new javax.swing.JLabel();
        jScrollPane2 = new javax.swing.JScrollPane();
        jPanel2 = new javax.swing.JPanel();
        outLabel0 = new javax.swing.JLabel();
        outLabel1 = new javax.swing.JLabel();
        outLabel2 = new javax.swing.JLabel();
        outLabel3 = new javax.swing.JLabel();
        outLabel4 = new javax.swing.JLabel();
        outLabel5 = new javax.swing.JLabel();
        outLabel6 = new javax.swing.JLabel();
        outLabel7 = new javax.swing.JLabel();
        outLabel8 = new javax.swing.JLabel();
        outLabel9 = new javax.swing.JLabel();
        outLabel10 = new javax.swing.JLabel();
        outLabel11 = new javax.swing.JLabel();
        outLabel12 = new javax.swing.JLabel();
        outLabel13 = new javax.swing.JLabel();
        outLabel14 = new javax.swing.JLabel();
        outLabel15 = new javax.swing.JLabel();
        outLabel16 = new javax.swing.JLabel();
        outLabel17 = new javax.swing.JLabel();
        outLabel18 = new javax.swing.JLabel();
        outLabel19 = new javax.swing.JLabel();
        outLabel20 = new javax.swing.JLabel();
        outLabel21 = new javax.swing.JLabel();
        outLabel22 = new javax.swing.JLabel();
        outLabel23 = new javax.swing.JLabel();
        outLabel24 = new javax.swing.JLabel();
        outLabel25 = new javax.swing.JLabel();
        outLabel26 = new javax.swing.JLabel();
        outLabel27 = new javax.swing.JLabel();
        outLabel28 = new javax.swing.JLabel();
        outLabel29 = new javax.swing.JLabel();
        outLabel30 = new javax.swing.JLabel();
        outLabel31 = new javax.swing.JLabel();
        outLabel32 = new javax.swing.JLabel();
        outLabel33 = new javax.swing.JLabel();
        outLabel34 = new javax.swing.JLabel();
        outLabel35 = new javax.swing.JLabel();
        outLabel36 = new javax.swing.JLabel();
        outLabel37 = new javax.swing.JLabel();
        outLabel38 = new javax.swing.JLabel();
        outLabel39 = new javax.swing.JLabel();
        outLabel40 = new javax.swing.JLabel();
        outLabel41 = new javax.swing.JLabel();
        outLabel42 = new javax.swing.JLabel();
        outLabel43 = new javax.swing.JLabel();
        outLabel44 = new javax.swing.JLabel();
        outLabel45 = new javax.swing.JLabel();
        outLabel46 = new javax.swing.JLabel();
        outLabel47 = new javax.swing.JLabel();
        outLabel48 = new javax.swing.JLabel();
        outLabel49 = new javax.swing.JLabel();
        outLabel50 = new javax.swing.JLabel();
        outLabel51 = new javax.swing.JLabel();
        outLabel52 = new javax.swing.JLabel();
        outLabel53 = new javax.swing.JLabel();
        outLabel54 = new javax.swing.JLabel();
        outLabel55 = new javax.swing.JLabel();
        outLabel56 = new javax.swing.JLabel();
        outLabel57 = new javax.swing.JLabel();
        outLabel58 = new javax.swing.JLabel();
        outLabel59 = new javax.swing.JLabel();
        outLabel60 = new javax.swing.JLabel();
        outLabel61 = new javax.swing.JLabel();
        outLabel62 = new javax.swing.JLabel();
        outLabel63 = new javax.swing.JLabel();
        outLabel64 = new javax.swing.JLabel();
        outLabel65 = new javax.swing.JLabel();
        outLabel66 = new javax.swing.JLabel();
        outLabel67 = new javax.swing.JLabel();
        outLabel68 = new javax.swing.JLabel();
        outLabel69 = new javax.swing.JLabel();
        outLabel70 = new javax.swing.JLabel();
        outLabel71 = new javax.swing.JLabel();
        outLabel72 = new javax.swing.JLabel();
        outLabel73 = new javax.swing.JLabel();
        outLabel74 = new javax.swing.JLabel();
        outLabel75 = new javax.swing.JLabel();
        outLabel76 = new javax.swing.JLabel();
        outLabel77 = new javax.swing.JLabel();
        outLabel78 = new javax.swing.JLabel();
        outLabel79 = new javax.swing.JLabel();
        outLabel80 = new javax.swing.JLabel();
        outLabel81 = new javax.swing.JLabel();
        outLabel82 = new javax.swing.JLabel();
        outLabel83 = new javax.swing.JLabel();
        outLabel84 = new javax.swing.JLabel();
        outLabel85 = new javax.swing.JLabel();
        outLabel86 = new javax.swing.JLabel();
        outLabel87 = new javax.swing.JLabel();
        outLabel88 = new javax.swing.JLabel();
        outLabel89 = new javax.swing.JLabel();
        outLabel90 = new javax.swing.JLabel();
        jTextArea3 = new javax.swing.JTextArea();

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        setTitle("Output");
        setBackground(new java.awt.Color(255, 255, 255));
        setResizable(false);

        jPanel1.setBackground(new java.awt.Color(255, 255, 255));
        jPanel1.setForeground(new java.awt.Color(255, 255, 255));
        jPanel1.setMaximumSize(new java.awt.Dimension(650, 700));
        jPanel1.setPreferredSize(new java.awt.Dimension(650, 900));

        jLabel1.setBackground(new java.awt.Color(255, 255, 255));
        jLabel1.setFont(new java.awt.Font("Times New Roman", 1, 20)); // NOI18N
        jLabel1.setForeground(new java.awt.Color(0, 112, 185));
        jLabel1.setText("MySQL Query");

        jTextArea1.setEditable(false);
        jTextArea1.setBackground(new java.awt.Color(255, 255, 255));
        jTextArea1.setColumns(20);
        jTextArea1.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        jTextArea1.setForeground(new java.awt.Color(0, 112, 185));
        jTextArea1.setLineWrap(true);
        jTextArea1.setRows(5);
        jTextArea1.setText("Sample");
        jTextArea1.setWrapStyleWord(true);

        jLabel3.setBackground(new java.awt.Color(255, 255, 255));
        jLabel3.setFont(new java.awt.Font("Times New Roman", 1, 20)); // NOI18N
        jLabel3.setForeground(new java.awt.Color(0, 112, 185));
        jLabel3.setText("File Directory Location");

        jTextArea2.setEditable(false);
        jTextArea2.setBackground(new java.awt.Color(255, 255, 255));
        jTextArea2.setColumns(20);
        jTextArea2.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        jTextArea2.setForeground(new java.awt.Color(0, 112, 185));
        jTextArea2.setLineWrap(true);
        jTextArea2.setRows(5);
        jTextArea2.setText("Sample");
        jTextArea2.setWrapStyleWord(true);
        jTextArea2.setPreferredSize(new java.awt.Dimension(638, 26));

        CopyButton.setBackground(new java.awt.Color(0, 63, 105));
        CopyButton.setFont(new java.awt.Font("Times New Roman", 1, 14)); // NOI18N
        CopyButton.setForeground(new java.awt.Color(191, 182, 172));
        CopyButton.setText("Copy Directory Location");
        CopyButton.setMaximumSize(new java.awt.Dimension(100, 26));
        CopyButton.setMinimumSize(new java.awt.Dimension(100, 26));
        CopyButton.setPreferredSize(new java.awt.Dimension(100, 26));
        CopyButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                CopyButtonActionPerformed(evt);
            }
        });

        jLabel2.setBackground(new java.awt.Color(255, 255, 255));
        jLabel2.setFont(new java.awt.Font("Times New Roman", 1, 20)); // NOI18N
        jLabel2.setForeground(new java.awt.Color(0, 112, 185));
        jLabel2.setText("Program Output");

        jScrollPane2.setBackground(new java.awt.Color(255, 255, 255));

        jPanel2.setBackground(new java.awt.Color(255, 255, 255));

        outLabel0.setBackground(new java.awt.Color(255, 255, 255));
        outLabel0.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel0.setForeground(new java.awt.Color(0, 112, 185));
        outLabel0.setText("-");

        outLabel1.setBackground(new java.awt.Color(255, 255, 255));
        outLabel1.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel1.setForeground(new java.awt.Color(0, 112, 185));
        outLabel1.setText("-");

        outLabel2.setBackground(new java.awt.Color(255, 255, 255));
        outLabel2.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel2.setForeground(new java.awt.Color(0, 112, 185));
        outLabel2.setText("-");

        outLabel3.setBackground(new java.awt.Color(255, 255, 255));
        outLabel3.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel3.setForeground(new java.awt.Color(0, 112, 185));
        outLabel3.setText("-");

        outLabel4.setBackground(new java.awt.Color(255, 255, 255));
        outLabel4.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel4.setForeground(new java.awt.Color(0, 112, 185));
        outLabel4.setText("-");

        outLabel5.setBackground(new java.awt.Color(255, 255, 255));
        outLabel5.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel5.setForeground(new java.awt.Color(0, 112, 185));
        outLabel5.setText("-");

        outLabel6.setBackground(new java.awt.Color(255, 255, 255));
        outLabel6.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel6.setForeground(new java.awt.Color(0, 112, 185));
        outLabel6.setText("-");

        outLabel7.setBackground(new java.awt.Color(255, 255, 255));
        outLabel7.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel7.setForeground(new java.awt.Color(0, 112, 185));
        outLabel7.setText("-");

        outLabel8.setBackground(new java.awt.Color(255, 255, 255));
        outLabel8.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel8.setForeground(new java.awt.Color(0, 112, 185));
        outLabel8.setText("-");

        outLabel9.setBackground(new java.awt.Color(255, 255, 255));
        outLabel9.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel9.setForeground(new java.awt.Color(0, 112, 185));
        outLabel9.setText("-");

        outLabel10.setBackground(new java.awt.Color(255, 255, 255));
        outLabel10.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel10.setForeground(new java.awt.Color(0, 112, 185));
        outLabel10.setText("-");

        outLabel11.setBackground(new java.awt.Color(255, 255, 255));
        outLabel11.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel11.setForeground(new java.awt.Color(0, 112, 185));
        outLabel11.setText("-");

        outLabel12.setBackground(new java.awt.Color(255, 255, 255));
        outLabel12.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel12.setForeground(new java.awt.Color(0, 112, 185));
        outLabel12.setText("-");

        outLabel13.setBackground(new java.awt.Color(255, 255, 255));
        outLabel13.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel13.setForeground(new java.awt.Color(0, 112, 185));
        outLabel13.setText("-");

        outLabel14.setBackground(new java.awt.Color(255, 255, 255));
        outLabel14.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel14.setForeground(new java.awt.Color(0, 112, 185));
        outLabel14.setText("-");

        outLabel15.setBackground(new java.awt.Color(255, 255, 255));
        outLabel15.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel15.setForeground(new java.awt.Color(0, 112, 185));
        outLabel15.setText("-");

        outLabel16.setBackground(new java.awt.Color(255, 255, 255));
        outLabel16.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel16.setForeground(new java.awt.Color(0, 112, 185));
        outLabel16.setText("-");

        outLabel17.setBackground(new java.awt.Color(255, 255, 255));
        outLabel17.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel17.setForeground(new java.awt.Color(0, 112, 185));
        outLabel17.setText("-");

        outLabel18.setBackground(new java.awt.Color(255, 255, 255));
        outLabel18.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel18.setForeground(new java.awt.Color(0, 112, 185));
        outLabel18.setText("-");

        outLabel19.setBackground(new java.awt.Color(255, 255, 255));
        outLabel19.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel19.setForeground(new java.awt.Color(0, 112, 185));
        outLabel19.setText("-");

        outLabel20.setBackground(new java.awt.Color(255, 255, 255));
        outLabel20.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel20.setForeground(new java.awt.Color(0, 112, 185));
        outLabel20.setText("-");

        outLabel21.setBackground(new java.awt.Color(255, 255, 255));
        outLabel21.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel21.setForeground(new java.awt.Color(0, 112, 185));
        outLabel21.setText("-");

        outLabel22.setBackground(new java.awt.Color(255, 255, 255));
        outLabel22.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel22.setForeground(new java.awt.Color(0, 112, 185));
        outLabel22.setText("-");

        outLabel23.setBackground(new java.awt.Color(255, 255, 255));
        outLabel23.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel23.setForeground(new java.awt.Color(0, 112, 185));
        outLabel23.setText("-");

        outLabel24.setBackground(new java.awt.Color(255, 255, 255));
        outLabel24.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel24.setForeground(new java.awt.Color(0, 112, 185));
        outLabel24.setText("-");

        outLabel25.setBackground(new java.awt.Color(255, 255, 255));
        outLabel25.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel25.setForeground(new java.awt.Color(0, 112, 185));
        outLabel25.setText("-");

        outLabel26.setBackground(new java.awt.Color(255, 255, 255));
        outLabel26.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel26.setForeground(new java.awt.Color(0, 112, 185));
        outLabel26.setText("-");

        outLabel27.setBackground(new java.awt.Color(255, 255, 255));
        outLabel27.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel27.setForeground(new java.awt.Color(0, 112, 185));
        outLabel27.setText("-");

        outLabel28.setBackground(new java.awt.Color(255, 255, 255));
        outLabel28.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel28.setForeground(new java.awt.Color(0, 112, 185));
        outLabel28.setText("-");

        outLabel29.setBackground(new java.awt.Color(255, 255, 255));
        outLabel29.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel29.setForeground(new java.awt.Color(0, 112, 185));
        outLabel29.setText("-");

        outLabel30.setBackground(new java.awt.Color(255, 255, 255));
        outLabel30.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel30.setForeground(new java.awt.Color(0, 112, 185));
        outLabel30.setText("-");

        outLabel31.setBackground(new java.awt.Color(255, 255, 255));
        outLabel31.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel31.setForeground(new java.awt.Color(0, 112, 185));
        outLabel31.setText("-");

        outLabel32.setBackground(new java.awt.Color(255, 255, 255));
        outLabel32.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel32.setForeground(new java.awt.Color(0, 112, 185));
        outLabel32.setText("-");

        outLabel33.setBackground(new java.awt.Color(255, 255, 255));
        outLabel33.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel33.setForeground(new java.awt.Color(0, 112, 185));
        outLabel33.setText("-");

        outLabel34.setBackground(new java.awt.Color(255, 255, 255));
        outLabel34.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel34.setForeground(new java.awt.Color(0, 112, 185));
        outLabel34.setText("-");

        outLabel35.setBackground(new java.awt.Color(255, 255, 255));
        outLabel35.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel35.setForeground(new java.awt.Color(0, 112, 185));
        outLabel35.setText("-");

        outLabel36.setBackground(new java.awt.Color(255, 255, 255));
        outLabel36.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel36.setForeground(new java.awt.Color(0, 112, 185));
        outLabel36.setText("-");

        outLabel37.setBackground(new java.awt.Color(255, 255, 255));
        outLabel37.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel37.setForeground(new java.awt.Color(0, 112, 185));
        outLabel37.setText("-");

        outLabel38.setBackground(new java.awt.Color(255, 255, 255));
        outLabel38.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel38.setForeground(new java.awt.Color(0, 112, 185));
        outLabel38.setText("-");

        outLabel39.setBackground(new java.awt.Color(255, 255, 255));
        outLabel39.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel39.setForeground(new java.awt.Color(0, 112, 185));
        outLabel39.setText("-");

        outLabel40.setBackground(new java.awt.Color(255, 255, 255));
        outLabel40.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel40.setForeground(new java.awt.Color(0, 112, 185));
        outLabel40.setText("-");

        outLabel41.setBackground(new java.awt.Color(255, 255, 255));
        outLabel41.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel41.setForeground(new java.awt.Color(0, 112, 185));
        outLabel41.setText("-");

        outLabel42.setBackground(new java.awt.Color(255, 255, 255));
        outLabel42.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel42.setForeground(new java.awt.Color(0, 112, 185));
        outLabel42.setText("-");

        outLabel43.setBackground(new java.awt.Color(255, 255, 255));
        outLabel43.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel43.setForeground(new java.awt.Color(0, 112, 185));
        outLabel43.setText("-");

        outLabel44.setBackground(new java.awt.Color(255, 255, 255));
        outLabel44.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel44.setForeground(new java.awt.Color(0, 112, 185));
        outLabel44.setText("-");

        outLabel45.setBackground(new java.awt.Color(255, 255, 255));
        outLabel45.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel45.setForeground(new java.awt.Color(0, 112, 185));
        outLabel45.setText("-");

        outLabel46.setBackground(new java.awt.Color(255, 255, 255));
        outLabel46.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel46.setForeground(new java.awt.Color(0, 112, 185));
        outLabel46.setText("-");

        outLabel47.setBackground(new java.awt.Color(255, 255, 255));
        outLabel47.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel47.setForeground(new java.awt.Color(0, 112, 185));
        outLabel47.setText("-");

        outLabel48.setBackground(new java.awt.Color(255, 255, 255));
        outLabel48.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel48.setForeground(new java.awt.Color(0, 112, 185));
        outLabel48.setText("-");

        outLabel49.setBackground(new java.awt.Color(255, 255, 255));
        outLabel49.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel49.setForeground(new java.awt.Color(0, 112, 185));
        outLabel49.setText("-");

        outLabel50.setBackground(new java.awt.Color(255, 255, 255));
        outLabel50.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel50.setForeground(new java.awt.Color(0, 112, 185));
        outLabel50.setText("-");

        outLabel51.setBackground(new java.awt.Color(255, 255, 255));
        outLabel51.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel51.setForeground(new java.awt.Color(0, 112, 185));
        outLabel51.setText("-");

        outLabel52.setBackground(new java.awt.Color(255, 255, 255));
        outLabel52.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel52.setForeground(new java.awt.Color(0, 112, 185));
        outLabel52.setText("-");

        outLabel53.setBackground(new java.awt.Color(255, 255, 255));
        outLabel53.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel53.setForeground(new java.awt.Color(0, 112, 185));
        outLabel53.setText("-");

        outLabel54.setBackground(new java.awt.Color(255, 255, 255));
        outLabel54.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel54.setForeground(new java.awt.Color(0, 112, 185));
        outLabel54.setText("-");

        outLabel55.setBackground(new java.awt.Color(255, 255, 255));
        outLabel55.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel55.setForeground(new java.awt.Color(0, 112, 185));
        outLabel55.setText("-");

        outLabel56.setBackground(new java.awt.Color(255, 255, 255));
        outLabel56.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel56.setForeground(new java.awt.Color(0, 112, 185));
        outLabel56.setText("-");

        outLabel57.setBackground(new java.awt.Color(255, 255, 255));
        outLabel57.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel57.setForeground(new java.awt.Color(0, 112, 185));
        outLabel57.setText("-");

        outLabel58.setBackground(new java.awt.Color(255, 255, 255));
        outLabel58.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel58.setForeground(new java.awt.Color(0, 112, 185));
        outLabel58.setText("-");

        outLabel59.setBackground(new java.awt.Color(255, 255, 255));
        outLabel59.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel59.setForeground(new java.awt.Color(0, 112, 185));
        outLabel59.setText("-");

        outLabel60.setBackground(new java.awt.Color(255, 255, 255));
        outLabel60.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel60.setForeground(new java.awt.Color(0, 112, 185));
        outLabel60.setText("-");

        outLabel61.setBackground(new java.awt.Color(255, 255, 255));
        outLabel61.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel61.setForeground(new java.awt.Color(0, 112, 185));
        outLabel61.setText("-");

        outLabel62.setBackground(new java.awt.Color(255, 255, 255));
        outLabel62.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel62.setForeground(new java.awt.Color(0, 112, 185));
        outLabel62.setText("-");

        outLabel63.setBackground(new java.awt.Color(255, 255, 255));
        outLabel63.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel63.setForeground(new java.awt.Color(0, 112, 185));
        outLabel63.setText("-");

        outLabel64.setBackground(new java.awt.Color(255, 255, 255));
        outLabel64.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel64.setForeground(new java.awt.Color(0, 112, 185));
        outLabel64.setText("-");

        outLabel65.setBackground(new java.awt.Color(255, 255, 255));
        outLabel65.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel65.setForeground(new java.awt.Color(0, 112, 185));
        outLabel65.setText("-");

        outLabel66.setBackground(new java.awt.Color(255, 255, 255));
        outLabel66.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel66.setForeground(new java.awt.Color(0, 112, 185));
        outLabel66.setText("-");

        outLabel67.setBackground(new java.awt.Color(255, 255, 255));
        outLabel67.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel67.setForeground(new java.awt.Color(0, 112, 185));
        outLabel67.setText("-");

        outLabel68.setBackground(new java.awt.Color(255, 255, 255));
        outLabel68.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel68.setForeground(new java.awt.Color(0, 112, 185));
        outLabel68.setText("-");

        outLabel69.setBackground(new java.awt.Color(255, 255, 255));
        outLabel69.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel69.setForeground(new java.awt.Color(0, 112, 185));
        outLabel69.setText("-");

        outLabel70.setBackground(new java.awt.Color(255, 255, 255));
        outLabel70.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel70.setForeground(new java.awt.Color(0, 112, 185));
        outLabel70.setText("-");

        outLabel71.setBackground(new java.awt.Color(255, 255, 255));
        outLabel71.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel71.setForeground(new java.awt.Color(0, 112, 185));
        outLabel71.setText("-");

        outLabel72.setBackground(new java.awt.Color(255, 255, 255));
        outLabel72.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel72.setForeground(new java.awt.Color(0, 112, 185));
        outLabel72.setText("-");

        outLabel73.setBackground(new java.awt.Color(255, 255, 255));
        outLabel73.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel73.setForeground(new java.awt.Color(0, 112, 185));
        outLabel73.setText("-");

        outLabel74.setBackground(new java.awt.Color(255, 255, 255));
        outLabel74.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel74.setForeground(new java.awt.Color(0, 112, 185));
        outLabel74.setText("-");

        outLabel75.setBackground(new java.awt.Color(255, 255, 255));
        outLabel75.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel75.setForeground(new java.awt.Color(0, 112, 185));
        outLabel75.setText("-");

        outLabel76.setBackground(new java.awt.Color(255, 255, 255));
        outLabel76.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel76.setForeground(new java.awt.Color(0, 112, 185));
        outLabel76.setText("-");

        outLabel77.setBackground(new java.awt.Color(255, 255, 255));
        outLabel77.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel77.setForeground(new java.awt.Color(0, 112, 185));
        outLabel77.setText("-");

        outLabel78.setBackground(new java.awt.Color(255, 255, 255));
        outLabel78.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel78.setForeground(new java.awt.Color(0, 112, 185));
        outLabel78.setText("-");

        outLabel79.setBackground(new java.awt.Color(255, 255, 255));
        outLabel79.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel79.setForeground(new java.awt.Color(0, 112, 185));
        outLabel79.setText("-");

        outLabel80.setBackground(new java.awt.Color(255, 255, 255));
        outLabel80.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel80.setForeground(new java.awt.Color(0, 112, 185));
        outLabel80.setText("-");

        outLabel81.setBackground(new java.awt.Color(255, 255, 255));
        outLabel81.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel81.setForeground(new java.awt.Color(0, 112, 185));
        outLabel81.setText("-");

        outLabel82.setBackground(new java.awt.Color(255, 255, 255));
        outLabel82.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel82.setForeground(new java.awt.Color(0, 112, 185));
        outLabel82.setText("-");

        outLabel83.setBackground(new java.awt.Color(255, 255, 255));
        outLabel83.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel83.setForeground(new java.awt.Color(0, 112, 185));
        outLabel83.setText("-");

        outLabel84.setBackground(new java.awt.Color(255, 255, 255));
        outLabel84.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel84.setForeground(new java.awt.Color(0, 112, 185));
        outLabel84.setText("-");

        outLabel85.setBackground(new java.awt.Color(255, 255, 255));
        outLabel85.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel85.setForeground(new java.awt.Color(0, 112, 185));
        outLabel85.setText("-");

        outLabel86.setBackground(new java.awt.Color(255, 255, 255));
        outLabel86.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel86.setForeground(new java.awt.Color(0, 112, 185));
        outLabel86.setText("-");

        outLabel87.setBackground(new java.awt.Color(255, 255, 255));
        outLabel87.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel87.setForeground(new java.awt.Color(0, 112, 185));
        outLabel87.setText("-");

        outLabel88.setBackground(new java.awt.Color(255, 255, 255));
        outLabel88.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel88.setForeground(new java.awt.Color(0, 112, 185));
        outLabel88.setText("-");

        outLabel89.setBackground(new java.awt.Color(255, 255, 255));
        outLabel89.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel89.setForeground(new java.awt.Color(0, 112, 185));
        outLabel89.setText("-");

        outLabel90.setBackground(new java.awt.Color(255, 255, 255));
        outLabel90.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        outLabel90.setForeground(new java.awt.Color(0, 112, 185));
        outLabel90.setText("-");

        javax.swing.GroupLayout jPanel2Layout = new javax.swing.GroupLayout(jPanel2);
        jPanel2.setLayout(jPanel2Layout);
        jPanel2Layout.setHorizontalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(outLabel0, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel2, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel3, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel4, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel5, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel6, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel7, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel8, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel9, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel10, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel11, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel12, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel13, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel14, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel15, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel16, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel17, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel18, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel19, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel20, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel21, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel22, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel23, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel24, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel25, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel26, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel27, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel28, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel29, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel30, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel31, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel32, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel33, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel34, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel35, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel36, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel37, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel38, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel39, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel40, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel41, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel42, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel43, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel44, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel45, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel46, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel47, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel48, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel49, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel50, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel51, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel52, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel53, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel54, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel55, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel56, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel57, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel58, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel59, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel60, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel61, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel62, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel63, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel64, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel65, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel66, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel67, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel68, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel69, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel70, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel71, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel72, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel73, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel74, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel75, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel76, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel77, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel78, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel79, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel80, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel81, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel82, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel83, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel84, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel85, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel86, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel87, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel88, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel89, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(outLabel90, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );
        jPanel2Layout.setVerticalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel2Layout.createSequentialGroup()
                .addComponent(outLabel0, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel1, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel2, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel3, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel4, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel5, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel6, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel7, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel8, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel9, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel10, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel11, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel12, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel13, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel14, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel15, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel16, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel17, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel18, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel19, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel20, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel21, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel22, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel23, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel24, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel25, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel26, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel27, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel28, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel29, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel30, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel31, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel32, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel33, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel34, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel35, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel36, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel37, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel38, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel39, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel40, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel41, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel42, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel43, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel44, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel45, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel46, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel47, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel48, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel49, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel50, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel51, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel52, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel53, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel54, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel55, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel56, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel57, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel58, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel59, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel60, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel61, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel62, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel63, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel64, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel65, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel66, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel67, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel68, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel69, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel70, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel71, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel72, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel73, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel74, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel75, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel76, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel77, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel78, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel79, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel80, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel81, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel82, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel83, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel84, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel85, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel86, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel87, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel88, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel89, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(outLabel90, javax.swing.GroupLayout.PREFERRED_SIZE, 20, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 693, Short.MAX_VALUE))
        );

        jScrollPane2.setViewportView(jPanel2);

        jTextArea3.setEditable(false);
        jTextArea3.setBackground(new java.awt.Color(255, 255, 255));
        jTextArea3.setColumns(20);
        jTextArea3.setFont(new java.awt.Font("Times New Roman", 0, 14)); // NOI18N
        jTextArea3.setForeground(new java.awt.Color(0, 112, 185));
        jTextArea3.setLineWrap(true);
        jTextArea3.setRows(5);
        jTextArea3.setText("Plots opened remotely using links below will have some latency depending on system and network configuration because the image or text viewer is being launched remotely.\n\nUsers can open these files faster in most cases by using their SFTP client and remote directory provided above.");
        jTextArea3.setWrapStyleWord(true);

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jScrollPane2)
                    .addComponent(jTextArea3)
                    .addComponent(jTextArea1)
                    .addGroup(jPanel1Layout.createSequentialGroup()
                        .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(jLabel1)
                            .addComponent(jLabel2)
                            .addComponent(jLabel3))
                        .addGap(0, 0, Short.MAX_VALUE))
                    .addComponent(jTextArea2, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel1Layout.createSequentialGroup()
                        .addGap(0, 0, Short.MAX_VALUE)
                        .addComponent(CopyButton, javax.swing.GroupLayout.PREFERRED_SIZE, 225, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap())
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jLabel1)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(jTextArea1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jLabel3)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(jTextArea2, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(CopyButton, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jLabel2)
                .addGap(1, 1, 1)
                .addComponent(jTextArea3, javax.swing.GroupLayout.PREFERRED_SIZE, 87, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jScrollPane2, javax.swing.GroupLayout.DEFAULT_SIZE, 539, Short.MAX_VALUE)
                .addContainerGap())
        );

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void CopyButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_CopyButtonActionPerformed
        Toolkit toolkit = Toolkit.getDefaultToolkit();
        Clipboard clipboard = toolkit.getSystemClipboard();
        StringSelection strSel = new StringSelection(form.file_path);
        clipboard.setContents(strSel, null);
        
        System.out.println("Directory Location Copied to Clipboard");
    }//GEN-LAST:event_CopyButtonActionPerformed

    /**
     * @param args the command line arguments
     */
    

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton CopyButton;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JPanel jPanel2;
    private javax.swing.JScrollPane jScrollPane2;
    private javax.swing.JTextArea jTextArea1;
    private javax.swing.JTextArea jTextArea2;
    private javax.swing.JTextArea jTextArea3;
    private javax.swing.JLabel outLabel0;
    private javax.swing.JLabel outLabel1;
    private javax.swing.JLabel outLabel10;
    private javax.swing.JLabel outLabel11;
    private javax.swing.JLabel outLabel12;
    private javax.swing.JLabel outLabel13;
    private javax.swing.JLabel outLabel14;
    private javax.swing.JLabel outLabel15;
    private javax.swing.JLabel outLabel16;
    private javax.swing.JLabel outLabel17;
    private javax.swing.JLabel outLabel18;
    private javax.swing.JLabel outLabel19;
    private javax.swing.JLabel outLabel2;
    private javax.swing.JLabel outLabel20;
    private javax.swing.JLabel outLabel21;
    private javax.swing.JLabel outLabel22;
    private javax.swing.JLabel outLabel23;
    private javax.swing.JLabel outLabel24;
    private javax.swing.JLabel outLabel25;
    private javax.swing.JLabel outLabel26;
    private javax.swing.JLabel outLabel27;
    private javax.swing.JLabel outLabel28;
    private javax.swing.JLabel outLabel29;
    private javax.swing.JLabel outLabel3;
    private javax.swing.JLabel outLabel30;
    private javax.swing.JLabel outLabel31;
    private javax.swing.JLabel outLabel32;
    private javax.swing.JLabel outLabel33;
    private javax.swing.JLabel outLabel34;
    private javax.swing.JLabel outLabel35;
    private javax.swing.JLabel outLabel36;
    private javax.swing.JLabel outLabel37;
    private javax.swing.JLabel outLabel38;
    private javax.swing.JLabel outLabel39;
    private javax.swing.JLabel outLabel4;
    private javax.swing.JLabel outLabel40;
    private javax.swing.JLabel outLabel41;
    private javax.swing.JLabel outLabel42;
    private javax.swing.JLabel outLabel43;
    private javax.swing.JLabel outLabel44;
    private javax.swing.JLabel outLabel45;
    private javax.swing.JLabel outLabel46;
    private javax.swing.JLabel outLabel47;
    private javax.swing.JLabel outLabel48;
    private javax.swing.JLabel outLabel49;
    private javax.swing.JLabel outLabel5;
    private javax.swing.JLabel outLabel50;
    private javax.swing.JLabel outLabel51;
    private javax.swing.JLabel outLabel52;
    private javax.swing.JLabel outLabel53;
    private javax.swing.JLabel outLabel54;
    private javax.swing.JLabel outLabel55;
    private javax.swing.JLabel outLabel56;
    private javax.swing.JLabel outLabel57;
    private javax.swing.JLabel outLabel58;
    private javax.swing.JLabel outLabel59;
    private javax.swing.JLabel outLabel6;
    private javax.swing.JLabel outLabel60;
    private javax.swing.JLabel outLabel61;
    private javax.swing.JLabel outLabel62;
    private javax.swing.JLabel outLabel63;
    private javax.swing.JLabel outLabel64;
    private javax.swing.JLabel outLabel65;
    private javax.swing.JLabel outLabel66;
    private javax.swing.JLabel outLabel67;
    private javax.swing.JLabel outLabel68;
    private javax.swing.JLabel outLabel69;
    private javax.swing.JLabel outLabel7;
    private javax.swing.JLabel outLabel70;
    private javax.swing.JLabel outLabel71;
    private javax.swing.JLabel outLabel72;
    private javax.swing.JLabel outLabel73;
    private javax.swing.JLabel outLabel74;
    private javax.swing.JLabel outLabel75;
    private javax.swing.JLabel outLabel76;
    private javax.swing.JLabel outLabel77;
    private javax.swing.JLabel outLabel78;
    private javax.swing.JLabel outLabel79;
    private javax.swing.JLabel outLabel8;
    private javax.swing.JLabel outLabel80;
    private javax.swing.JLabel outLabel81;
    private javax.swing.JLabel outLabel82;
    private javax.swing.JLabel outLabel83;
    private javax.swing.JLabel outLabel84;
    private javax.swing.JLabel outLabel85;
    private javax.swing.JLabel outLabel86;
    private javax.swing.JLabel outLabel87;
    private javax.swing.JLabel outLabel88;
    private javax.swing.JLabel outLabel89;
    private javax.swing.JLabel outLabel9;
    private javax.swing.JLabel outLabel90;
    // End of variables declaration//GEN-END:variables
}
