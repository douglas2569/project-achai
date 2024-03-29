-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 14-Jul-2023 às 17:01
-- Versão do servidor: 10.4.27-MariaDB
-- versão do PHP: 8.0.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `achai`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `admins`
--
DROP TABLE IF EXISTS `admins`;
CREATE TABLE `admins` (
  `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY ,
  `user` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  `email` varchar(320) DEFAULT NULL,
  `hash` varchar(50) NOT NULL
  
);

--
-- Extraindo dados da tabela `admins`
--

INSERT INTO `admins` VALUES (7,'root','202cb962ac59075b964b07152d234b70','root','A0E812B01BFC8E2417C254A074DF599D');
-- --------------------------------------------------------

--
-- Estrutura da tabela `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  `name` varchar(50) DEFAULT NULL,
  `icon_name` varchar(200) DEFAULT NULL  
);

--
-- Extraindo dados da tabela `categories`
--

INSERT INTO `categories` VALUES (87,'Ver todos','none'),(88,'Eletrônicos','headphones_FILL0_wght300_GRAD0_opsz40.svg'),(89,'Garrafas','water_bottle_FILL0_wght300_GRAD0_opsz40.svg'),(90,'Guarda-chuvas','umbrella_FILL0_wght300_GRAD0_opsz40.svg'),(91,'Todas','list_FILL0_wght300_GRAD0_opsz40.svg'),(102,'Papelaria','none'),(103,'Vestíveis','none'),(104,'Outros','none');

-- --------------------------------------------------------

--
-- Estrutura da tabela `things`
--

DROP TABLE IF EXISTS `things`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `things` (
  `id` int NOT NULL AUTO_INCREMENT  PRIMARY KEY,
  `description` text,
  `local` varchar(100) NOT NULL,
  `date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `returned_status` tinyint(1) DEFAULT '0',
  `reserved_status` tinyint(1) DEFAULT '0',
  `category_id` int NOT NULL DEFAULT '0',
  `image_address` varchar(64) NOT NULL,

  FOREIGN KEY(`category_id`) REFERENCES `categories`(`id`)
  
);

--
-- Estrutura da tabela `reserved`
--

DROP TABLE IF EXISTS `reserved`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reserved` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
  `date` DATETIME NOT NULL,
  `thing_id` INT NOT NULL,
  
  FOREIGN KEY(`thing_id`) REFERENCES `things`(`id`)
);

-- --------------------------------------------------------

--
-- Estrutura da tabela `returned`
--
DROP TABLE IF EXISTS `returned`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `returned` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `date` DATETIME NOT NULL,
  `thing_id` INT NOT NULL,
  
  PRIMARY KEY (`id`),
  FOREIGN KEY(`thing_id`) REFERENCES `things`(`id`)

);

-- --------------------------------------------------------



INSERT INTO `things` VALUES (245,'','Sala 01','2023-10-09 11:47:28',0,0,88,'api/assets/imgs/de85dc47df7ed0874bf9ca789a0a3157.png'),(246,'','Lab 03','2023-10-09 11:48:00',0,0,89,'api/assets/imgs/80f0c18812f8d20af6fbf90ae7326e59.png');

-- --------------------------------------------------------

--
-- Estrutura da tabela `zips`
--

DROP TABLE IF EXISTS `zips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `zips` (
  `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `file_address` varchar(200) COLLATE utf8mb3_unicode_ci DEFAULT NULL  
);

--
-- Table structure for table `emaillist`
--

DROP TABLE IF EXISTS `emaillist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emaillist` (
  `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY ,
  `addr` varchar(100) NOT NULL,
  `reserve_quantity` INT DEFAULT 1, 
  `status`  TINYINT DEFAULT 1,
  UNIQUE KEY `addr` (`addr`)
);

--
-- Table structure for table `listvalidationcodes`
--

DROP TABLE IF EXISTS `listvalidationcodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `listvalidationcodes` (
  `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `code` INT(4) NOT NULL,
  `create_at` INT DEFAULT TIME_TO_SEC(CURRENT_TIMESTAMP),
  
  `thing_id` INT NOT NULL,
  FOREIGN KEY(`thing_id`) REFERENCES `things`(`id`)
);

--
-- Acionadores `things`
--
DELIMITER $$
CREATE TRIGGER `after_things_update_reserved_filed` AFTER UPDATE ON `things` FOR EACH ROW BEGIN
    IF OLD.reserved_status = 0 AND NEW.reserved_status = 1 THEN
        INSERT INTO reserved
		SET date =  NOW(), thing_id = OLD.id;
    END IF;
END
$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `after_things_update_returned_filed` AFTER UPDATE ON `things` FOR EACH ROW BEGIN
    IF NEW.returned_status = 1 AND OLD.returned_status = 0 THEN
        INSERT INTO returned
		SET date = NOW(), thing_id = OLD.id;
    END IF;
END
$$
DELIMITER ;


-- --------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_register_listvalidationcodes;
DELIMITER $$

CREATE PROCEDURE sp_register_listvalidationcodes(	  
    code_p INT,
    thing_id_p INT
  )

BEGIN    
    
    DECLARE track_no VARCHAR(10) DEFAULT '0/0';
    DECLARE EXIT HANDLER FOR SQLEXCEPTION, NOT FOUND, SQLWARNING
    
    BEGIN    
        GET DIAGNOSTICS CONDITION 1 @`errno` = MYSQL_ERRNO, @`sqlstate` = RETURNED_SQLSTATE, @`text` = MESSAGE_TEXT;
        SET @full_error = CONCAT('ERROR ', @`errno`, ' (', @`sqlstate`, '): ', @`text`);
        SELECT track_no, @full_error;

        ROLLBACK;    
    END;

    START TRANSACTION;
        SET track_no = '1/2';
        INSERT INTO listvalidationcodes (code, thing_id) values(code_p, thing_id_p);

        SET track_no = '2/2'; 
        DELETE FROM listvalidationcodes WHERE (TIME_TO_SEC(NOW())) - (create_at) >= 300 OR (TIME_TO_SEC(NOW())) - (create_at)  < 0;        
                
        SET track_no = '0/2';
        SET @full_error = 'successfully executed.';
        SELECT track_no, @full_error;
    COMMIT;

END; $$

DELIMITER ;


-- Não será mais usado pq um msm email pode reservar quanto ele quiser ele so nao poderia reservar 3x em um pequeno espaço de tempo, ou seja, eu teria que ter um historico das ultimas 3 reservas e nao ficar comparando com o ultimo
-- DROP PROCEDURE IF EXISTS sp_update_emaillist;

-- DELIMITER $$
-- CREATE PROCEDURE sp_update_emaillist(emaillist_id_p INT, expiration_time_p VARCHAR(50) 
--   )

-- BEGIN 
--     DECLARE reserved_quantity INT DEFAULT 0;
--     DECLARE track_no VARCHAR(10) DEFAULT '0/0';
--     DECLARE EXIT HANDLER FOR SQLEXCEPTION, NOT FOUND, SQLWARNING
    
--     BEGIN    
--         GET DIAGNOSTICS CONDITION 1 @`errno` = MYSQL_ERRNO, @`sqlstate` = RETURNED_SQLSTATE, @`text` = MESSAGE_TEXT;
--         SET @full_error = CONCAT('ERROR ', @`errno`, ' (', @`sqlstate`, '): ', @`text`);
--         SELECT track_no, @full_error;
--     END;

--     SELECT reserve_quantity INTO reserved_quantity FROM emaillist WHERE id = emaillist_id_p;
    
--     SET track_no = '1/2';
--     IF reserved_quantity > 0 THEN          
--       UPDATE emaillist SET reserve_quantity = reserve_quantity - 1, last_reserve_datetime = TIME_TO_SEC(NOW()) + TIME_TO_SEC(expiration_time_p) WHERE id = emaillist_id_p;              
--     END IF;    
    
--     SET track_no = '2/2';
--     UPDATE emaillist SET reserve_quantity = 3, last_reserve_datetime = TIME_TO_SEC(NOW()) + TIME_TO_SEC(expiration_time_p) WHERE last_reserve_datetime <= TIME_TO_SEC(NOW()) AND reserve_quantity = 0;          
    
--     SET track_no = '0/2';
--     SET @full_error = 'successfully executed.';
--     SELECT track_no, @full_error;
         
-- END; $$

-- DELIMITER ;

