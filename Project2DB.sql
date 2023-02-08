-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
DROP SCHEMA IF exists `mydb`;

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`PharmaceuticalCompany`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`PharmaceuticalCompany` (
  `Pharm Co name` VARCHAR(45) NOT NULL,
  `phone` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Pharm Co name`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Pharmacy`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Pharmacy` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `address` VARCHAR(45) NOT NULL,
  `phone` VARCHAR(45) NOT NULL,
  `supervisor` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Contract`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Contract` (
  `contractid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `startdate` DATE NOT NULL,
  `enddate` DATE NOT NULL,
  `contracttext` VARCHAR(500) NOT NULL,
  `Pharmacy_id` INT NOT NULL,
  `PharmaceuticalCompany_Pharm Co name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`contractid`, `Pharmacy_id`, `PharmaceuticalCompany_Pharm Co name`),
  INDEX `fk_Contract_Pharmacy1_idx` (`Pharmacy_id` ASC) VISIBLE,
  INDEX `fk_Contract_PharmaceuticalCompany1_idx` (`PharmaceuticalCompany_Pharm Co name` ASC) VISIBLE,
  CONSTRAINT `fk_Contract_Pharmacy1`
    FOREIGN KEY (`Pharmacy_id`)
    REFERENCES `mydb`.`Pharmacy` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Contract_PharmaceuticalCompany1`
    FOREIGN KEY (`PharmaceuticalCompany_Pharm Co name`)
    REFERENCES `mydb`.`PharmaceuticalCompany` (`Pharm Co name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Doctor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Doctor` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `last_name` VARCHAR(45) NOT NULL,
  `first_name` VARCHAR(45) NOT NULL,
  `ssn` CHAR(11) NOT NULL,
  `specialty` VARCHAR(45) NOT NULL,
  `practice_since` CHAR (4) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Patient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Patient` (
  `patientid` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ssn` VARCHAR(45) NOT NULL,
  `first_name` VARCHAR(45) NULL,
  `last_name` VARCHAR(45) NULL,
  `city` VARCHAR(45) NULL,
  `state` VARCHAR(2) NULL,
  `street` VARCHAR(45) NULL,
  `zipcode` VARCHAR(45) NULL,
  `birthday` DATE NULL,
  `Doctor_id` INT NOT NULL,
  `doctor_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`patientid`),
  INDEX `fk_Patient_Doctor1_idx` (`doctor_name` ASC) VISIBLE,
  CONSTRAINT `fk_Patient_Doctor1`
    FOREIGN KEY (`Doctor_id`)
    REFERENCES `mydb`.`Doctor` (`id`)
    ON DELETE cascade
    ON UPDATE cascade)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`drug`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`drug` (
  `drug_id` INT(11) NOT NULL,
  `trade_name` VARCHAR(100) NULL,
  `formula` VARCHAR(200) NULL,
  -- `Pharmacy_sells_Drug_pharmacy_id` INT NOT NULL,
  PRIMARY KEY (`drug_id`))
  -- PRIMARY KEY (`drug_id`, `Pharmacy_sells_Drug_pharmacy_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Prescription`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Prescription` (
  `rxnumber` INT NOT NULL auto_increment,
  `drug_id` INT(11) NOT NULL,
  `tradename` VARCHAR(45) NULL,
  `date` DATE NULL,
  `quantity` INT UNSIGNED NOT NULL,
  `price` INT UNSIGNED NULL,
  `pharmacy` INT NULL,
  `company` VARCHAR(45) NULL,
  `doctor` INT NOT NULL,
  `patient` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`rxnumber`),
  INDEX `doctor_idx` (`doctor` ASC) VISIBLE,
  INDEX `patient_idx` (`patient` ASC) VISIBLE,
  INDEX `fk_Prescription_1_idx` (`pharmacy` ASC) VISIBLE,
  INDEX `company_idx` (`company` ASC) VISIBLE,
  INDEX `drug.drug_id_idx` (`drug_id` ASC) VISIBLE,
  CONSTRAINT `prescription.doctor`
    FOREIGN KEY (`doctor`)
    REFERENCES `mydb`.`Doctor` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `prescription.patient`
    FOREIGN KEY (`patient`)
    REFERENCES `mydb`.`Patient` (`patientid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `prescription.pharmacy`
    FOREIGN KEY (`pharmacy`)
    REFERENCES `mydb`.`Pharmacy` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `prescription.company`
    FOREIGN KEY (`company`)
    REFERENCES `mydb`.`PharmaceuticalCompany` (`Pharm Co name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `drug.drug_id`
    FOREIGN KEY (`drug_id`)
    REFERENCES `mydb`.`drug` (`drug_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Pharmacy_sells_Drug`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Pharmacy_sells_Drug` (
  `Pharmacy_id` INT NOT NULL,
  `drug_drug_id` INT(11) NOT NULL,
  `drug_Pharmacy_sells_Drug_pharmacy_id` INT NOT NULL,
  PRIMARY KEY (`Pharmacy_id`, `drug_drug_id`, `drug_Pharmacy_sells_Drug_pharmacy_id`),
  INDEX `fk_Pharmacy_sells_Drug_drug1_idx` (`drug_drug_id` ASC, `drug_Pharmacy_sells_Drug_pharmacy_id` ASC) VISIBLE,
  CONSTRAINT `fk_Pharmacy_sells_Drug_Pharmacy1`
    FOREIGN KEY (`Pharmacy_id`)
    REFERENCES `mydb`.`Pharmacy` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Pharmacy_sells_Drug_drug1`
  FOREIGN KEY (`drug_drug_id`)
    REFERENCES `mydb`.`drug` (`drug_id`)
    -- FOREIGN KEY (`drug_drug_id` , `drug_Pharmacy_sells_Drug_pharmacy_id`)
    -- REFERENCES `mydb`.`drug` (`drug_id` , `Pharmacy_sells_Drug_pharmacy_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`drug_has_PharmaceuticalCompany`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`drug_has_PharmaceuticalCompany` (
  `drug_drug_id` INT(11) NOT NULL,
  `drug_Pharmacy_sells_Drug_pharmacy_id` INT NOT NULL,
  `PharmaceuticalCompany_Pharm Co name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`drug_drug_id`, `drug_Pharmacy_sells_Drug_pharmacy_id`, `PharmaceuticalCompany_Pharm Co name`),
  INDEX `fk_drug_has_PharmaceuticalCompany_PharmaceuticalCompany1_idx` (`PharmaceuticalCompany_Pharm Co name` ASC) VISIBLE,
  INDEX `fk_drug_has_PharmaceuticalCompany_drug1_idx` (`drug_drug_id` ASC, `drug_Pharmacy_sells_Drug_pharmacy_id` ASC) VISIBLE,
  CONSTRAINT `fk_drug_has_PharmaceuticalCompany_drug1`
    FOREIGN KEY (`drug_drug_id`)
    -- FOREIGN KEY (`drug_drug_id` , `drug_Pharmacy_sells_Drug_pharmacy_id`)
    REFERENCES `mydb`.`drug` (`drug_id`)
    -- REFERENCES `mydb`.`drug` (`drug_id` , `Pharmacy_sells_Drug_pharmacy_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_drug_has_PharmaceuticalCompany_PharmaceuticalCompany1`
    FOREIGN KEY (`PharmaceuticalCompany_Pharm Co name`)
    REFERENCES `mydb`.`PharmaceuticalCompany` (`Pharm Co name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

/*
select d.name from Doctor d join Patient p on p.primarydoctorssn=d.ssn
group by d.name having count(p.ssn)>=3;
select genericname
from Prescription
group by genericname
having count(genericname) =
    (select max(generic_count) as max_count
	from (select genericname, count(genericname) as generic_count
	from Prescription
	group by genericname) as p1);
select Pharmacy
from Pharmacy p
    join Prescription d on d.pharmacy = p.name
group by pharmacy
having count(genericname) =
    (select min(generic_count) as min_count
	from (select genericname, count(genericname) as generic_count
	from Prescription
	group by genericname) as p1);
    
select name, startdate
from Contract
order by startdate asc
limit 1;
select count(*) as Brand_Name_Count
from Prescription
where tradename != 'null';
*/