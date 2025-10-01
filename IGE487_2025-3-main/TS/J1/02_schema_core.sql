-- Tables et schéma modifié pour le jalon 1

-- Ajout des tables pour les données météo
CREATE TABLE Meteo (
    id SERIAL PRIMARY KEY,
    date_observation DATE NOT NULL,
    temperature_min Temperature,
    temperature_max Temperature,
    humidite Humidite,
    precipitation Precipitation,
    unite_temperature Unite DEFAULT 'C',
    unite_humidite Unite DEFAULT '%',
    unite_precipitation Unite DEFAULT 'mm',
    valeur_manquante ValeurManquante
);

-- Ajout de la table CarnetMeteo pour les relevés bruts
CREATE TABLE CarnetMeteo (
    id SERIAL PRIMARY KEY,
    date_releve DATE NOT NULL,
    temperature_min_raw NUMERIC(5, 2),
    temperature_max_raw NUMERIC(5, 2),
    humidite_raw NUMERIC(5, 2),
    precipitation_raw NUMERIC(5, 2),
    unite_temperature_raw TEXT,
    unite_humidite_raw TEXT,
    unite_precipitation_raw TEXT,
    commentaire TEXT
);

-- Révision de la table ObsFloraison
-- Suppression de la colonne fleur et ajustement de la clé primaire
CREATE TABLE ObsFloraison_Revised AS
SELECT id, date, note
FROM ObsFloraison;

ALTER TABLE ObsFloraison_Revised
ADD CONSTRAINT ObsFloraison_Revised_pk PRIMARY KEY (id, date);

DROP TABLE ObsFloraison;

ALTER TABLE ObsFloraison_Revised
RENAME TO ObsFloraison;

-- Renommage de la table peup en peuplement et adaptation des références
ALTER TABLE Peuplement RENAME COLUMN peup TO peuplement;

-- Mise à jour des références dans les autres tables
ALTER TABLE Placette RENAME COLUMN peup TO peuplement;
ALTER TABLE Placette DROP CONSTRAINT Placette_cr_pe;
ALTER TABLE Placette ADD CONSTRAINT Placette_cr_pe FOREIGN KEY (peuplement) REFERENCES Peuplement (peuplement);