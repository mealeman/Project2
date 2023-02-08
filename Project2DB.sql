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
    ON DELETE cascade
    ON UPDATE cascade,
  CONSTRAINT `fk_Contract_PharmaceuticalCompany1`
    FOREIGN KEY (`PharmaceuticalCompany_Pharm Co name`)
    REFERENCES `mydb`.`PharmaceuticalCompany` (`Pharm Co name`)
    ON DELETE cascade
    ON UPDATE cascade)
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
  `pharmacy_id` INT NULL,
  `pharmacy_name` VARCHAR(45) NULL,
  `company` VARCHAR(45) NULL,
  `doctor` INT NOT NULL,
  `patient` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`rxnumber`),
  INDEX `doctor_idx` (`doctor` ASC) VISIBLE,
  INDEX `patient_idx` (`patient` ASC) VISIBLE,
  INDEX `fk_Prescription_1_idx` (`pharmacy_id` ASC) VISIBLE,
  INDEX `company_idx` (`company` ASC) VISIBLE,
  INDEX `drug.drug_id_idx` (`drug_id` ASC) VISIBLE,
  CONSTRAINT `prescription.doctor`
    FOREIGN KEY (`doctor`)
    REFERENCES `mydb`.`Doctor` (`id`)
    ON DELETE cascade
    ON UPDATE cascade,
  CONSTRAINT `prescription.patient`
    FOREIGN KEY (`patient`)
    REFERENCES `mydb`.`Patient` (`patientid`)
    ON DELETE cascade
    ON UPDATE cascade,
  CONSTRAINT `prescription.pharmacy`
    FOREIGN KEY (`pharmacy_id`)
    REFERENCES `mydb`.`Pharmacy` (`id`)
    ON DELETE cascade
    ON UPDATE cascade,
  CONSTRAINT `prescription.company`
    FOREIGN KEY (`company`)
    REFERENCES `mydb`.`PharmaceuticalCompany` (`Pharm Co name`)
    ON DELETE cascade
    ON UPDATE cascade,
  CONSTRAINT `drug.drug_id`
    FOREIGN KEY (`drug_id`)
    REFERENCES `mydb`.`drug` (`drug_id`)
    ON DELETE cascade
    ON UPDATE cascade)
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
    ON DELETE cascade
    ON UPDATE cascade,
  CONSTRAINT `fk_Pharmacy_sells_Drug_drug1`
  FOREIGN KEY (`drug_drug_id`)
    REFERENCES `mydb`.`drug` (`drug_id`)
    -- FOREIGN KEY (`drug_drug_id` , `drug_Pharmacy_sells_Drug_pharmacy_id`)
    -- REFERENCES `mydb`.`drug` (`drug_id` , `Pharmacy_sells_Drug_pharmacy_id`)
    ON DELETE cascade
    ON UPDATE cascade)
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
    ON DELETE cascade
    ON UPDATE cascade,
  CONSTRAINT `fk_drug_has_PharmaceuticalCompany_PharmaceuticalCompany1`
    FOREIGN KEY (`PharmaceuticalCompany_Pharm Co name`)
    REFERENCES `mydb`.`PharmaceuticalCompany` (`Pharm Co name`)
    ON DELETE cascade
    ON UPDATE cascade)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

--
-- Table structure for table `drug`
--

INSERT INTO `drug` VALUES 
(1,'Tylenol with Codeine','acetaminophen and codeine'),
(2,'Proair Proventil','albuterol aerosol'),
(3,'Accuneb','albuterol HFA'),
(4,'Fosamax','alendronate'),
(5,'Zyloprim','allopurinol'),
(6,'Xanax','alprazolam'),
(7,'Elavil','amitriptyline'),
(8,'Augmentin','amoxicillin and clavulanate K+'),
(9,'Amoxil','amoxicillin'),
(10,'Adderall XR','amphetamine and dextroamphetamine XR'),
(11,'Tenormin','atenolol'),
(12,'Lipitor','atorvastatin'),
(13,'Zithromax','azithromycin'),
(14,'Lotrel','benazepril and amlodipine'),
(15,'Soma','carisoprodol'),
(16,'Coreg','carvedilol'),
(17,'Omnicef','cefdinir'),
(18,'Celebrex','celecoxib'),
(19,'Keflex','cephalexin'),
(20,'Cipro','ciprofloxacin'),
(21,'Celexa','citalopram'),
(22,'Klonopin','clonazepam'),
(23,'Catapres','clonidine HCl'),
(24,'Plavix','clopidogrel'),
(25,'Premarin','conjugated estrogens'),
(26,'Flexeril','cyclobenzaprine'),
(27,'Valium','diazepam'),
(28,'Voltaren','diclofenac sodium'),
(29,'Yaz','drospirenone and ethinyl estradiol'),
(30,'Cymbalta','Duloxetine'),
(31,'Vibramycin','doxycycline hyclate'),
(32,'Vasotec','enalapril'),
(33,'Lexapro','escitalopram'),
(34,'Nexium','esomeprazole'),
(35,'Zetia','ezetimibe'),
(36,'Tricor','fenofibrate'),
(37,'Allegra','fexofenadine'),
(38,'Diflucan','fluconozole'),
(39,'Prozac','fluoxetine HCl'),
(40,'Advair','fluticasone and salmeterol inhaler'),
(41,'Flonase','fluticasone nasal spray'),
(42,'Folic Acid','folic acid'),
(43,'Lasix','furosemide'),
(44,'Neurontin','gabapentin'),
(45,'Amaryl','glimepiride'),
(46,'Diabeta','glyburide'),
(47,'Glucotrol','glipizide'),
(48,'Microzide','hydrochlorothiazide'),
(49,'Lortab','hydrocodone and acetaminophen'),
(50,'Motrin','ibuprophen'),
(51,'Lantus','insulin glargine'),
(52,'Imdur','isosorbide mononitrate'),
(53,'Prevacid','lansoprazole'),
(54,'Levaquin','levofloxacin'),
(55,'Levoxl','levothyroxine sodium'),
(56,'Zestoretic','lisinopril and hydrochlorothiazide'),
(57,'Prinivil','lisinopril'),
(58,'Ativan','lorazepam'),
(59,'Cozaar','losartan'),
(60,'Mevacor','lovastatin'),
(61,'Mobic','meloxicam'),
(62,'Glucophage','metformin HCl'),
(63,'Medrol','methylprednisone'),
(64,'Toprol','metoprolol succinate XL'),
(65,'Lopressor','metoprolol tartrate'),
(66,'Nasonex','mometasone'),
(67,'Singulair','montelukast'),
(68,'Naprosyn','naproxen'),
(69,'Prilosec','omeprazole'),
(70,'Percocet','oxycodone and acetaminophen'),
(71,'Protonix','pantoprazole'),
(72,'Paxil','paroxetine'),
(73,'Actos','pioglitazone'),
(74,'Klor-Con','potassium Chloride'),
(75,'Pravachol','pravastatin'),
(76,'Deltasone','prednisone'),
(77,'Lyrica','pregabalin'),
(78,'Phenergan','promethazine'),
(79,'Seroquel','quetiapine'),
(80,'Zantac','ranitidine'),
(81,'Crestor','rosuvastatin'),
(82,'Zoloft','sertraline HCl'),
(83,'Viagra','sildenafil HCl'),
(84,'Vytorin','simvastatin and ezetimibe'),
(85,'Zocor','simvastatin'),
(86,'Aldactone','spironolactone'),
(87,'Bactrim DS','sulfamethoxazole and trimethoprim DS'),
(88,'Flomax','tamsulosin'),
(89,'Restoril','temezepam'),
(90,'Topamax','topiramate'),
(91,'Ultram','tramadol'),
(92,'Aristocort','triamcinolone Ace topical'),
(93,'Desyrel','trazodone HCl'),
(94,'Dyazide','triamterene and hydrochlorothiazide'),
(95,'Valtrex','valaciclovir'),
(96,'Diovan','valsartan'),
(97,'Effexor XR','venlafaxine XR'),
(98,'Calan SR','verapamil SR'),
(99,'Ambien','zolpidem');

--
-- Pharmacy Entry
--
insert into `Pharmacy` (`name`, `address`, `phone`, `supervisor`) values ('CVS', '7 Albert Street', '9999999999','Karen');