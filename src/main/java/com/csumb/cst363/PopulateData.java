package com.csumb.cst363;

import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;
import java.sql.Connection;

public class PopulateData {

	public static void main(String[] args) {
		//100 random patients, 10 random doctors and 100 random prescriptions.

		final String DBURL = "jdbc:mysql://localhost:3306/mydb";
	    final String USERID = "local";
		final String PASSWORD = "password";
		
	    final String[] specialties= {"Internal Medicine", "Family Medicine", "Pediatrics", "Orthpedics", "Dermatology", 
				"Cardiology", "Gynecology", "Gastroenterology", "Psychiatry", "Oncology"};
	    
	    final String[] firstNames= {"Vanessa", "Laurence", "Tyler", "Alicia", "Alice", "Bob", "Timothy", "Hector", "Alicia"};
	    final String[] lastNames= {"Li", "Grant", "Smith", "Jones", "Reed", "Zhao", "Estrada", "Lin", "Rea", "Butcher", "Burke", "Birch", "Card"};
	    
	    ArrayList<String> allSSN= new ArrayList<String>();
	    HashMap<Integer, String> doctors = new HashMap<Integer, String>();
	    
	    String ssn="0";
	    int id;
	    int row_count;
	    Random rand = new Random();
		   
	   	
	   try(Connection con=DriverManager.getConnection(DBURL, USERID, PASSWORD);){
		   PreparedStatement ps;
		   ResultSet rs;
		   
		   //clear doctor table
		   ps=con.prepareStatement("DELETE FROM Doctor");
		   ps.executeUpdate();
		   ps=con.prepareStatement("ALTER TABLE Doctor AUTO_INCREMENT=1");
		   ps.executeUpdate();
		   
		   //Generate Doctors
			String sqlINSERT = "insert into Doctor (last_name, first_name, specialty, practice_since, ssn) values( ?, ?, ?, ?, ?)";
			String[] keycols = {"id"};
			ps = con.prepareStatement(sqlINSERT, keycols);
				
			//insert 10 doctors into table
			allSSN.add("0");
			for(int i=1; i<=10; i++) {
				String practice_since = Integer.toString(2000+rand.nextInt(20));
				//ensure generated ssn is unique between all patients and doctors
				while(allSSN.contains(ssn)) {
					ssn=Integer.toString(123450000+rand.nextInt(10000));
				}
				allSSN.add(ssn);
				String lastname=lastNames[rand.nextInt(lastNames.length)];
				String firstname=firstNames[rand.nextInt(firstNames.length)];
				String specialty=specialties[rand.nextInt(specialties.length)];
			
				ps.setString(1, lastname);
				ps.setString(2, firstname);
				ps.setString(3, specialty);
				ps.setString(4, practice_since);
				ps.setString(5, ssn);
				
				row_count=ps.executeUpdate();
				rs = ps.getGeneratedKeys();
				rs.next();
				id = rs.getInt(1);
				doctors.put(id, lastname);
			}
			
			
			//clear patient table
	    	ps=con.prepareStatement("DELETE FROM Patient");
			ps.executeUpdate();
			ps=con.prepareStatement("ALTER TABLE Patient AUTO_INCREMENT=1");
			ps.executeUpdate();
			
			//Generate patients
			sqlINSERT = "insert into Patient (ssn, first_name, last_name, Doctor_id, doctor_name) values (?,?,?,?,?)";
			ps = con.prepareStatement(sqlINSERT);
			
			for(int i=1; i<=100; i++) {
				while(allSSN.contains(ssn)) {
					ssn=Integer.toString(123450000+rand.nextInt(10000));
				}
				allSSN.add(ssn);
				String lastname=lastNames[rand.nextInt(lastNames.length)];
				String firstname=firstNames[rand.nextInt(firstNames.length)];
				
				ArrayList<Integer> doctorKeys = new ArrayList<Integer>(doctors.keySet());
				int doctorID = doctorKeys.get(rand.nextInt(doctorKeys.size()));
				String doctorName = doctors.get(doctorID);
				
				ps.setString(1, ssn);
				ps.setString(2, firstname);
				ps.setString(3, lastname);
				ps.setInt(4, doctorID);
				ps.setString(5, doctorName);
				
				ps.executeUpdate();
			}
			
			//clear prescription table
			ps=con.prepareStatement("DELETE FROM Prescription");
			ps.executeUpdate();
			ps=con.prepareStatement("ALTER TABLE Prescription AUTO_INCREMENT=1");
			ps.executeUpdate();
			
			//get drug hashmap
			HashMap<Integer, String> drugs = new HashMap<Integer, String>();
			String drugSQL = "select drug_id, trade_name from drug";
			ps = con.prepareStatement(drugSQL);
			rs = ps.executeQuery();
			
			while(rs.next()) {
				drugs.put(rs.getInt(1), rs.getString(2));
			}
			
			//Generate prescriptions
			sqlINSERT = "insert into Prescription (drug_id, tradename, quantity, patient, doctor) values (?, ?, ?, ?, ?)";
			ps = con.prepareStatement(sqlINSERT);
			
			for(int i=1; i<=100; i++) {
				int drugID = rand.nextInt(99) + 1;
				
				ps.setInt(1, drugID);
				ps.setString(2, drugs.get(drugID));
				ps.setInt(3, rand.nextInt(20) + 1);
				ps.setInt(4, rand.nextInt(100) + 1);
				ps.setInt(5, rand.nextInt(10) + 1);
				
				ps.executeUpdate();
				
			}
		
	   }catch (SQLException e) {
			System.out.println("Error: SQLException "+e.getMessage());
	   }
	   
	}
 }

	   
