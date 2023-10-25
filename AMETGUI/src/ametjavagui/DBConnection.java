package ametjavagui;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;


/**
 *
 * @author Michael Morton
 * 
 * 
 */

public class DBConnection {
    
    //public String username;
    //public String password;
    Config config = new Config();
    
    public Connection con;
    public Statement stmt;
    public ResultSet rs;
    

    public void getDBConnection() throws SQLException {
        System.setProperty("javax.net.ssl.trustStore", config.keystore);
        System.setProperty("javax.net.ssl.trustStoreType", "jks");
        System.setProperty("javax.net.ssl.trustStorePassword", config.keystore_password);
        
        try {
            con = DriverManager.getConnection(config.conn,WelcomeScreen.username,WelcomeScreen.password);
            stmt = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
            //System.out.println("-Connected to the Database-");           
        } catch (SQLException e) {
            System.out.println("-Database Connection Failed-");
            e.printStackTrace();
        }
    }
   
    
    public void closeDBConnection() throws SQLException {
        if(con != null && !con.isClosed()){
            con.close();
           // System.out.println("-Database Connection Closed-");
        }
    }
    
    public void query(String query) throws SQLException {
        try {
            rs = stmt.executeQuery(query);
            //System.out.println("-Executed Query-");
        } catch (SQLException e) {
            System.out.println("-Query Failed-");
            e.printStackTrace();
        }
    }
    
    public void printRS() throws SQLException {
        ResultSetMetaData rsmd = rs.getMetaData();
        int columnsNumber = rsmd.getColumnCount();
        while (rs.next()) {
            for (int i = 1; i <= columnsNumber; i++) {
                if (i > 1) System.out.print(",  ");
                String columnValue = rs.getString(i);
                System.out.print(columnValue);
            }
            System.out.println("");
        }
    }
    
    public ResultSet getRS() {
        return rs;
    }
}
