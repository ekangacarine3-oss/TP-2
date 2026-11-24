-- ============================================================================
-- Base de données MySQL : api
-- TP2 Premium — Application mobile Flutter + API REST PHP / MySQL
-- Établissement : ISIG GOMA — Licence 3 (Langage de Programmation Mobile)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `api`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `api`;

CREATE TABLE IF NOT EXISTS `account` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(190) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_account_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `famille_membre` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nom` VARCHAR(100) NOT NULL,
  `postnom` VARCHAR(100) NOT NULL,
  `prenom` VARCHAR(100) NOT NULL,
  `lieu_naissance` VARCHAR(150) NOT NULL,
  `date_naissance` DATE NOT NULL,
  `parente` VARCHAR(100) NOT NULL,
  `image` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_famille_nom` (`nom`),
  KEY `idx_famille_parente` (`parente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tbl_etudiant` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nom` VARCHAR(100) NOT NULL,
  `postnom` VARCHAR(100) NOT NULL,
  `prenom` VARCHAR(100) NOT NULL,
  `matricule` VARCHAR(50) DEFAULT NULL,
  `promotion` VARCHAR(50) DEFAULT 'Licence 3',
  `filiere` VARCHAR(100) DEFAULT 'Informatique de Gestion',
  `email` VARCHAR(190) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_etudiant_matricule` (`matricule`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Données de démonstration facultatives (décommenter si souhaité) :
-- INSERT INTO `famille_membre` (`nom`, `postnom`, `prenom`, `lieu_naissance`, `date_naissance`, `parente`) VALUES
-- ('Kidumu', 'Mumbere', 'Jean', 'Butembo', '1972-03-20', 'Père'),
-- ('Kavira', 'Kabhil', 'Marie', 'Goma', '1978-09-11', 'Mère'),
-- ('Kidumu', 'Kabhil', 'Patrick', 'Goma', '2004-11-08', 'Frère'),
-- ('Kidumu', 'Kabhil', 'Sarah', 'Goma', '2006-07-19', 'Sœur');
