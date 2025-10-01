-- Définitions de types ou domaines pour le jalon 1

-- Ajout des types pour les données météo
CREATE DOMAIN Temperature AS NUMERIC(5, 2) CHECK (VALUE BETWEEN -100 AND 100);
CREATE DOMAIN Humidite AS NUMERIC(5, 2) CHECK (VALUE BETWEEN 0 AND 100);
CREATE DOMAIN Precipitation AS NUMERIC(5, 2) CHECK (VALUE >= 0);
CREATE DOMAIN Unite AS TEXT CHECK (VALUE IN ('C', '%', 'mm'));

-- Ajout des types pour gérer les valeurs manquantes
CREATE DOMAIN ValeurManquante AS TEXT CHECK (VALUE IN ('NA', 'ND', 'NULL'));