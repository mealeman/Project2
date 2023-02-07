package com.csumb.cst363;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

/*
 * Controller class for patient interactions.
 *   register as a new patient.
 *   update patient profile.
 */
@Controller
public class ControllerPatient {
	
	@Autowired
	private JdbcTemplate jdbcTemplate;
	
	/*
	 * Request blank patient registration form.
	 */
	@GetMapping("/patient/new")
	public String newPatient(Model model) {
		// return blank form for new patient registration
		model.addAttribute("patient", new Patient());
		return "patient_register";
	}
	
	/*
	 * Process new patient registration	 */
	@PostMapping("/patient/new")
	public String newPatient(Patient p, Model model) {

		// TODO
		
		String errMessage = "";
		int currYear = 2023;
		
		try (Connection con = getConnection();) {
			PreparedStatement ps = con.prepareStatement("insert into patient(ssn, first_name, "
					+ "last_name, birthday, street, city, state, zipcode, doctor_name, Doctor_id) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
					Statement.RETURN_GENERATED_KEYS);			
			ps.setString(1, p.getSsn());
			ps.setString(2, p.getFirst_name());
			ps.setString(3, p.getLast_name());
			ps.setString(4, p.getBirthdate());
			ps.setString(5, p.getStreet());
			ps.setString(6, p.getCity());
			ps.setString(7, p.getState());
			ps.setString(8, p.getZipcode());	
			ps.setString(9, p.getPrimaryName());
			
			Statement stmt = con.createStatement();			
			ResultSet result = stmt.executeQuery("select id from doctor where concat(first_name, ' ',last_name) = '" + p.getPrimaryName() + "'");

			
			if(p.getSsn().isEmpty() || p.getSsn().length() != 9 || p.getSsn().matches("[0-9]+") == false || 
					p.getSsn().charAt(0) == '0' || p.getSsn().charAt(0) == '9' || p.getSsn().substring(3,5).equals("00") ||
					p.getSsn().substring(5,9).equals("0000")) {
				
				errMessage = "Please enter a valid SSN";
				throw new SQLException(errMessage);
			}
			
			if(p.getFirst_name().isEmpty() || p.getLast_name().isEmpty() || 
					!(p.getFirst_name().matches("[a-zA-Z]+")) || !(p.getLast_name().matches("[a-zA-Z]+"))) {				
				
				errMessage = "Please enter valid name entries (letters only).";
				throw new SQLException(errMessage);
			}			
			
			if(p.getBirthdate().isEmpty()) {
				errMessage = "Please enter valid birthdate.";
				throw new SQLException(errMessage);
			}			
				
			String birthDate = p.getBirthdate().substring(0,4);				
			int year = Integer.parseInt(birthDate);		
			
			if(year < 1900 || year > 2022) {
				errMessage = "Please enter valid birthdate (years between 1900-2022).";
				throw new SQLException(errMessage);
			}
			
			int age = currYear - year;
			
			if(p.getCity().isEmpty() || !(p.getCity().matches("[a-zA-Z]+"))) {
				errMessage = "Please enter valid city.";
				throw new SQLException(errMessage);
			}
			
			if(p.getState().isEmpty() || !(p.getState().matches("[a-zA-Z]+"))) {
				errMessage = "Please enter valid state.";
				throw new SQLException(errMessage);
			}
			
			if(!(p.getZipcode().matches("[-0-9]+")) || !(p.getZipcode().length() == 5 || p.getZipcode().length() == 10)) {				
				
				errMessage = "Please enter a valid zip code.";
				throw new SQLException(errMessage);
			}	
			
			if(p.getZipcode().length() > 5 && ((p.getZipcode().charAt(5) != '-') || !(p.getZipcode().substring(6,10).matches("[0-9]+")))) {	
				errMessage = "Please enter a valid zip code (12345-1234)";
				throw new SQLException(errMessage);
			}

			if(!result.isBeforeFirst()){                
                errMessage = "Please enter a valid Doctor Name";
            }
			else{
        	   result.next();
   			   
   			   p.setPrimaryID(result.getInt(1));
   			   ps.setInt(10, p.getPrimaryID()); 
   			   
   			   Statement drStmt = con.createStatement();		   			   
   			   ResultSet drResult = drStmt.executeQuery("select specialty from doctor where concat(first_name, ' ',last_name) = '" + p.getPrimaryName() + "'");	   
   			   
   			   drResult.next();	
   			   
   			   if(age < 18 && !(drResult.getString("specialty").equalsIgnoreCase("pediatrics"))) {
   				   errMessage = "Child patients must select a Pediatrician.";
   				   throw new SQLException(errMessage);
   			   }
   			   if(age >= 18) {
   				   if(drResult.getString("specialty").equalsIgnoreCase("pediatrics")) {
   					   errMessage = "Adult patients cannot select a Pediatrician.";
	   				   throw new SQLException(errMessage);
   				   }   				  
   				   if(!(drResult.getString("specialty").equalsIgnoreCase("family medicine") || 
   						   drResult.getString("specialty").equalsIgnoreCase("internal medicine"))) {
   					   errMessage = "Adult patients must select a Family or Internal Medicine physician.";
	   				   throw new SQLException(errMessage);
   				   }	   				   
   			   }
            }							

			ps.executeUpdate();
			ResultSet rs = ps.getGeneratedKeys();			
			
			if (rs.next()) p.setPatientId((String)rs.getString(1));		
			
			// display message and patient information
			model.addAttribute("message", "Registration successful.");
			model.addAttribute("patient", p);
			
		} catch (SQLException e) {
			
			if (errMessage == "") {
				model.addAttribute("message", "SQL Error."+e.getMessage());
			}
			else {
				model.addAttribute("message", errMessage);
			}
			model.addAttribute("patient", p);
			
			return "patient_register";
		} catch (NullPointerException ex) {
			model.addAttribute("message", errMessage);
			model.addAttribute("patient", p);
			
			return "patient_register";
		}

		/*
		 * Complete database logic to verify and process new patient
		 */
		// remove this fake data.
		p.setPatientId("300198");
		model.addAttribute("message", "Registration successful.");
		model.addAttribute("patient", p);
		return "patient_show";

	}
	
	/*
	 * Request blank form to search for patient by and and id
	 */
	@GetMapping("/patient/edit")
	public String getPatientForm(Model model) {
		return "patient_get";
	}
	
	/*
	 * Perform search for patient by patient id and name.
	 */
	@PostMapping("/patient/show")
	public String getPatientForm(@RequestParam("patientId") String patientId, @RequestParam("last_name") String last_name,
			Model model) {

		// TODO

		/*
		 * code to search for patient by id and name retrieve patient data and primary
		 * doctor  
		 */
		
		// return fake data for now.
		Patient p = new Patient();
		p.setPatientId(patientId);
		p.setLast_name(last_name);
		p.setBirthdate("2001-01-01");
		p.setStreet("123 Main");
		p.setCity("SunCity");
		p.setState("CA");
		p.setZipcode("99999");
		p.setPrimaryID(11111);
		p.setPrimaryName("Dr. Watson");
		p.setSpecialty("Family Medicine");
		p.setYears("1992");

		model.addAttribute("patient", p);
		return "patient_show";
	}

	/*
	 *  Display patient profile for patient id.
	 */
	@GetMapping("/patient/edit/{patientId}")
	public String updatePatient(@PathVariable String patientId, Model model) {

		// TODO Complete database logic search for patient by id.

		// return fake data.
		Patient p = new Patient();
		p.setPatientId(patientId);
		p.setFirst_name("Alex");
		p.setLast_name("Patient");
		p.setBirthdate("2001-01-01");
		p.setStreet("123 Main");
		p.setCity("SunCity");
		p.setState("CA");
		p.setZipcode("99999");
		p.setPrimaryID(11111);
		p.setPrimaryName("Dr. Watson");
		p.setSpecialty("Family Medicine");
		p.setYears("1992");

		model.addAttribute("patient", p);
		return "patient_edit";
	}
	
	
	/*
	 * Process changes to patient profile.  
	 */
	@PostMapping("/patient/edit")
	public String updatePatient(Patient p, Model model) {

		// TODO

		model.addAttribute("patient", p);
		return "patient_show";
	}

	/*
	 * return JDBC Connection using jdbcTemplate in Spring Server
	 */

	private Connection getConnection() throws SQLException {
		Connection conn = jdbcTemplate.getDataSource().getConnection();
		return conn;
	}

}
