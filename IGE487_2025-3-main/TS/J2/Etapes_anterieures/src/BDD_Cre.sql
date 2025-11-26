-- =======================
-- BDD Create Script (FINAL avec METEO)
-- =======================

DROP SCHEMA IF EXISTS "Herbivorie_BDD" CASCADE;
CREATE SCHEMA "Herbivorie_BDD";
SET SCHEMA 'Herbivorie_BDD';



-- =======================
-- DIMENSIONS
-- =======================

CREATE TABLE Dim_Date (
    date_key   date PRIMARY KEY,
    annee      int,
    mois       int,
    jour       int,
    nom_mois   text,
    trimestre  int
);

CREATE TABLE Dim_Site (
    site_id     text PRIMARY KEY,
    site_nom    text,
    description text
);

CREATE TABLE Dim_Zone (
    zone_id     text PRIMARY KEY,
    site_id     text REFERENCES Dim_Site(site_id),
    description text
);

CREATE TABLE Dim_Placette (
    zone_id     text REFERENCES Dim_Zone(zone_id),
    placette_id text,
    PRIMARY KEY (zone_id, placette_id)
);

CREATE TABLE Dim_Parcelle (
    zone_id     text,
    placette_id text,
    parcelle_id int,
    PRIMARY KEY (zone_id, placette_id, parcelle_id),
    FOREIGN KEY (zone_id, placette_id)
        REFERENCES Dim_Placette(zone_id, placette_id)
);

CREATE TABLE Dim_Peuplement (
    peup_id     text PRIMARY KEY,
    description text
);

CREATE TABLE Dim_Arbre (
    arbre_id    text PRIMARY KEY,
    description text
);

CREATE TABLE Dim_Plant (
    plant_id    text PRIMARY KEY
);

CREATE TABLE Dim_Taux (
    tcat text PRIMARY KEY,
    tmin int,
    tmax int
);

CREATE TABLE Dim_CouvertType (
    ctype text PRIMARY KEY
);

CREATE TABLE Dim_ObstructionNature (
    nature text PRIMARY KEY
);

CREATE TABLE Dim_Hauteur (
    hauteur text PRIMARY KEY
);

-- === Dimension METEO (type précipitation) ===
CREATE TABLE Dim_PrecipitationType (
    code    text PRIMARY KEY,
    libelle text
);

-- =======================
-- TABLES DE FAITS (ECO)
-- =======================

-- 1) Observations de plants
CREATE TABLE Fait_Observation (
    date_key       date REFERENCES Dim_Date(date_key),
    plant_id       text REFERENCES Dim_Plant(plant_id),
    peup_id        text REFERENCES Dim_Peuplement(peup_id),
    parcelle_id    int,
    placette_id    text,
    zone_id        text,
    site_id        text,
    arbre_id       text REFERENCES Dim_Arbre(arbre_id),
    longueur_mm    int,
    largeur_mm     int,
    etat           text,
    fleur          boolean,
    PRIMARY KEY (date_key, plant_id)
);

-- 2) Obstruction latérale
CREATE TABLE Fait_Obstruction (
    date_key   date REFERENCES Dim_Date(date_key),
    zone_id    text,
    placette_id text,
    nature     text REFERENCES Dim_ObstructionNature(nature),
    hauteur    text REFERENCES Dim_Hauteur(hauteur),
    tcat       text REFERENCES Dim_Taux(tcat),
    tval       int,
    PRIMARY KEY (date_key, zone_id, placette_id, nature, hauteur)
);

-- 3) Couvert au sol
CREATE TABLE Fait_Couvert (
    date_key    date REFERENCES Dim_Date(date_key),
    zone_id     text,
    placette_id text,
    ctype       text REFERENCES Dim_CouvertType(ctype),
    tcat        text REFERENCES Dim_Taux(tcat),
    tval        int,
    PRIMARY KEY (date_key, zone_id, placette_id, ctype)
);

-- =======================
-- TABLES DE FAITS (METEO)
-- =======================

CREATE TABLE Fait_Temperature (
    date_key  date REFERENCES Dim_Date(date_key),
    zone_id   text REFERENCES Dim_Zone(zone_id),
    site_id   text REFERENCES Dim_Site(site_id),
    temp_min  int,
    temp_max  int,
    note      text,
    PRIMARY KEY (date_key, zone_id)
);

CREATE TABLE Fait_Humidite (
    date_key  date REFERENCES Dim_Date(date_key),
    zone_id   text REFERENCES Dim_Zone(zone_id),
    site_id   text REFERENCES Dim_Site(site_id),
    hum_min   int,
    hum_max   int,
    PRIMARY KEY (date_key, zone_id)
);

CREATE TABLE Fait_Vents (
    date_key  date REFERENCES Dim_Date(date_key),
    zone_id   text REFERENCES Dim_Zone(zone_id),
    site_id   text REFERENCES Dim_Site(site_id),
    vent_min  int,
    vent_max  int,
    PRIMARY KEY (date_key, zone_id)
);

CREATE TABLE Fait_Pression (
    date_key  date REFERENCES Dim_Date(date_key),
    zone_id   text REFERENCES Dim_Zone(zone_id),
    site_id   text REFERENCES Dim_Site(site_id),
    pres_min  int,
    pres_max  int,
    PRIMARY KEY (date_key, zone_id)
);

CREATE TABLE Fait_Precipitations (
    date_key  date REFERENCES Dim_Date(date_key),
    zone_id   text REFERENCES Dim_Zone(zone_id),
    site_id   text REFERENCES Dim_Site(site_id),
    prec_tot  int,
    prec_nat  text REFERENCES Dim_PrecipitationType(code),
    PRIMARY KEY (date_key, zone_id, prec_nat)
);
