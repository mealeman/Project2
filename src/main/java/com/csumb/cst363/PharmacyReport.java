package com.csumb.cst363;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.Date;
import java.util.Random;
import java.util.Scanner;


public class PharmacyReport {
	
	static final String DBURL = "jdbc:mysql://localhost:3306/mydb";  // database URL
	static final String USERID = "root";
	static final String PASSWORD = "1L1k3TuRt5";
	
	public static void main(String[] args) {
		
		// connect to mysql server
		
		try (Connection conn = DriverManager.getConnection(DBURL, USERID, PASSWORD);) {
			
			PreparedStatement ps;
			ResultSet rs;

			String rxnumber;

			Scanner inputId = new Scanner(System.in);
			System.out.printf("Enter a pharmacy Name: ");
			
			String pharmId = inputId.nextLine();		
			
			Scanner inputStart = new Scanner(System.in);
			System.out.printf("Enter a Start Date: ");
			
			String startDate = inputStart.nextLine();
			
			Scanner inputEnd = new Scanner(System.in);
			System.out.printf("Enter a End Date: ");
			
			String endDate = inputEnd.nextLine();

			
			String sqlSELECT = "select rxnumber, trade_name, p.quantity from pharmacy_sells_drug s join prescription p on s.drug_drug_id = p.drug_id join drug d on p.drug_id = d.drug_id where Pharmacy_name = ? and date >= ? and date <= ?";
			
			ps = conn.prepareStatement(sqlSELECT);
			
			ps.setString(1,  pharmId);
			ps.setDate(2,  java.sql.Date.valueOf(startDate));
			ps.setDate(3,  java.sql.Date.valueOf(endDate));

			rs = ps.executeQuery();
			while (rs.next()) {
				rxnumber = rs.getString("rxnumber");
				String tradeName = rs.getString("trade_name");
				int quantity = rs.getInt("quantity");				

				System.out.printf("%10s, %10s \n", tradeName, quantity);
			}
		} catch (SQLException e) {
			System.out.println("Error: SQLException "+e.getMessage());
		}
		
	}

}
