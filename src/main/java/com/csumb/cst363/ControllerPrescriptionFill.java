package com.csumb.cst363;

import java.sql.Connection;
import java.util.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;


@Controller   
public class ControllerPrescriptionFill {

	@Autowired
	private JdbcTemplate jdbcTemplate;


	/* 
	 * Patient requests form to search for prescription.
	 */
	@GetMapping("/prescription/fill")
	public String getfillForm(Model model) {
		model.addAttribute("prescription", new Prescription());
		return "prescription_fill";
	}


	/*
	 * Process the prescription fill request from a patient.
	 * 1. DONE Validate that Prescription p contains rxid, pharmacy name and pharmacy address
	 *     		and uniquely identify a prescription and a pharmacy.
	 * 2.  DONE update prescription with pharmacyid, name and address.
	 * 3.  DONE update prescription with today's date.
	 * 4.  DONE Display updated prescription 
	 * 5.  or if there is an error show the form with an error message.
	 */
	@PostMapping("/prescription/fill")
	public String processFillForm(Prescription p,  Model model) {

		
		if(!p.getRxid().equals("") && !p.getPharmacyName().equals("") && !p.getPharmacyAddress().equals("") && !p.getPatientLastName().equals("")) {
			if(!p.getRxid().matches("^-?\\d+$")) {
				model.addAttribute("message", "Invalid Rxid");
				model.addAttribute("prescription", p);
				return "prescription_fill";
			}
			
			if(p.getPharmacyAddress().matches(".*[!@#$%^&*()]+.*")) {
				model.addAttribute("message", "Invalid Address: no special characters allowed");
				model.addAttribute("prescription", p);
				return "prescription_fill";
			}
			
			if(p.getPharmacyName().matches(".*[!@#$%^&*()]+.*")) {
				model.addAttribute("message", "Invalid Pharmacy Name: no special characters allowed");
				model.addAttribute("prescription", p);
				return "prescription_fill";
			}
			
			if(p.getPatientLastName().matches(".*[!@#$%^&*()]+.*")) {
				model.addAttribute("message", "Invalid Patient Name: no special characters allowed");
				model.addAttribute("prescription", p);
				return "prescription_fill";
			}
			
			// check the rx number goes to a prescription and last name matches
			try(Connection con=getConnection();){
				PreparedStatement ps = con.prepareStatement("select Patient.last_name from Prescription, Patient where Prescription.patient = Patient.patientid and rxnumber=?");
				ps.setString(1, p.getRxid());
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					if(!rs.getString(1).equals(p.getPatientLastName())) {
						model.addAttribute("message", "Prescription does not correspond to patient");
						model.addAttribute("prescription", p);
						return "prescription_fill";
					}
				}else{
					model.addAttribute("message", "Prescription does not exist");
					model.addAttribute("prescription", p);
					return "prescription_fill";
				}
				
			}catch(SQLException e){
				model.addAttribute("message", "SQL exception" +e.getMessage());
				model.addAttribute("prescription", p);
				return "prescription_fill";
			}
			
			//check that patient exists
			try(Connection con=getConnection();){
				PreparedStatement ps = con.prepareStatement("select first_name from Patient where last_name=?");
				ps.setString(1, p.getPatientLastName());
				ResultSet rs = ps.executeQuery();
				if(!rs.next()) {
					model.addAttribute("message", "Patient does not exist");
					model.addAttribute("prescription", p);
					return "prescription_fill";
				}
				
			}catch(SQLException e) {
				model.addAttribute("message", "SQL exception" +e.getMessage());
				model.addAttribute("prescription", p);
				return "prescription_fill";
			}
			
			//check that pharmacy exists
			try(Connection con=getConnection();){
				PreparedStatement ps = con.prepareStatement("select id from Pharmacy where name=? and address=?");
				ps.setString(1, p.getPharmacyName());
				ps.setString(2, p.getPharmacyAddress());
				
				ResultSet rs = ps.executeQuery();
				if(!rs.next()) {
					model.addAttribute("message", "Pharmacy does not exist");
					model.addAttribute("prescription", p);
					return "prescription_fill";
				}else {
					p.setPharmacyID(rs.getString(1));
				}
			}catch(SQLException e){
				model.addAttribute("message", "SQL exception" +e.getMessage());
				model.addAttribute("prescription", p);
				return "prescription_fill";
			}
			
			//get today's date
			String date = new SimpleDateFormat("dd-MM-yyyy").format(new Date());
			//Update prescription with pharmacyid, name, address, today's date
			try(Connection con=getConnection();){
				PreparedStatement ps = con.prepareStatement("update Prescription set pharmacy_name=?, pharmacy_id=?, date=STR_TO_DATE(?, '%d-%m-%Y') where rxnumber=?");
				ps.setString(1, p.getPharmacyName());
				ps.setString(2, p.getPharmacyID());
				ps.setString(3,date);
				ps.setString(4, p.getRxid());
				p.setDateFilled(date);
				int rc = ps.executeUpdate();
				if(rc==1) {
					PreparedStatement prs = con.prepareStatement("select Doctor.ssn, Doctor.first_name, Doctor.last_name, Patient.ssn, Patient.first_name, Patient.last_name, tradename, quantity, price, Pharmacy.phone from Prescription, Doctor, Patient, Pharmacy where Prescription.doctor = Doctor.id and Prescription.patient = Patient.patientid and Prescription.pharmacy_name = Pharmacy.name and rxnumber=?");
					prs.setString(1, p.getRxid());
					ResultSet rs = prs.executeQuery();
					if(rs.next()) {
						p.setDoctor_ssn(rs.getString(1));
						p.setDoctorFirstName(rs.getString(2));
						p.setDoctorLastName(rs.getString(3));
						p.setPatient_ssn(rs.getString(4));
						p.setPatientFirstName(rs.getString(5));
						p.setPatientLastName(rs.getString(6));
						p.setDrugName(rs.getString(7));
						p.setQuantity(rs.getInt(8));
						p.setCost(rs.getString(9));
						p.setPharmacyPhone(rs.getString(10));
						model.addAttribute("prescription", p);
						return "prescription_show";
					}
				}else{
					model.addAttribute("message", "Something went wrong :(");
					model.addAttribute("prescription", p);
					return "prescription_fill";
				}
				
			}catch(SQLException e){
				model.addAttribute("message", "SQL exception in update statement" +e.getMessage());
				model.addAttribute("prescription", p);
				return "prescription_fill";
			}
			
		}else {
			model.addAttribute("message", "Rxid, Pharmacy name, or Pharmacy address is null");
		}
		return "prescription_fill";
		// TODO  

		// temporary code to set fake data for now.
		/*p.setPharmacyID("70012345");
		p.setCost(String.format("%.2f", 12.5));
		p.setDateFilled( new java.util.Date().toString() );

		// display the updated prescription

		model.addAttribute("message", "Prescription has been filled.");
		model.addAttribute("prescription", p);
		return "prescription_show";*/

	}

	/*
	 * return JDBC Connection using jdbcTemplate in Spring Server
	 */



	private Connection getConnection() throws SQLException {
		Connection conn = jdbcTemplate.getDataSource().getConnection();
		return conn;
	}

}