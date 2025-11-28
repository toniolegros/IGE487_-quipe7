----------------------------------------------------------------------
-- CRÉATION DU SCHÉMA STAGING
----------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS "ige487_68";


----------------------------------------------------------------------
-- 1. site.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".site (
    siteid TEXT,
    nom TEXT
);

----------------------------------------------------------------------
-- 2. zone.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".zone (
    zoneid TEXT,
    siteid TEXT
);


----------------------------------------------------------------------
-- 3. arbre.csv
-- ⚠ Ton arbre.csv ressemble en réalité à un doublon de site.csv
-- Mais je crée la table quand même pour respecter ton fichier
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".arbre (
    arbreid TEXT,
    description TEXT
);


----------------------------------------------------------------------
-- 4. peuplement.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".peuplement (
    peuplementid TEXT,
    description TEXT
);


----------------------------------------------------------------------
-- 5. placette.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".placette (
    placetteid TEXT,
    siteid TEXT,
    zoneid TEXT,
    peuplementid TEXT,
    superficie NUMERIC,
    coordx NUMERIC,
    coordy NUMERIC
);


----------------------------------------------------------------------
-- 6. parcelle.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".parcelle (
    siteid TEXT,
    zoneid TEXT,
    placetteid TEXT,
    parcelleid TEXT
);


----------------------------------------------------------------------
-- 7. plant.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".plant (
    plantid TEXT
);


----------------------------------------------------------------------
-- 8. obsarbre.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".obsarbre (
    siteid TEXT,
    zoneid TEXT,
    placetteid TEXT,
    arbreid TEXT,
    date DATE,
    rang INTEGER,
    note TEXT
);


----------------------------------------------------------------------
-- 9. obscouverture.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".obscouverture (
    siteid TEXT,
    zoneid TEXT,
    placetteid TEXT,
    date DATE,
    tauxmousses NUMERIC,
    tauxgraminees NUMERIC,
    tauxfougeres NUMERIC,
    note TEXT
);


----------------------------------------------------------------------
-- 10. obsobstruction.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".obsobstruction (
    siteid TEXT,
    zoneid TEXT,
    placetteid TEXT,
    date DATE,
    hauteur INTEGER,
    tauxfeuillu NUMERIC,
    tauxconifere NUMERIC,
    note TEXT
);


----------------------------------------------------------------------
-- 11. obsplantlocalisation.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".obsplantlocalisation (
    plantid TEXT,
    date DATE,
    siteid TEXT,
    zoneid TEXT,
    placetteid TEXT,
    parcelleid TEXT,
    coordx NUMERIC,
    coordy NUMERIC,
    note TEXT
);


----------------------------------------------------------------------
-- 12. obsdimension.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".obsdimension (
    plantid TEXT,
    date DATE,
    longueur NUMERIC,
    largeur NUMERIC,
    note TEXT
);


----------------------------------------------------------------------
-- 13. obsfloraison.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".obsfloraison (
    plantid TEXT,
    date DATE,
    typefloraison TEXT,
    note TEXT
);


----------------------------------------------------------------------
-- 14. obsetat.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".obsetat (
    plantid TEXT,
    date DATE,
    etat TEXT,
    note TEXT
);


----------------------------------------------------------------------
-- 15. obshumidite.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".obshumidite (
    siteid TEXT,
    zoneid TEXT,
    placetteid TEXT,
    date DATE,
    humidite NUMERIC,
    note TEXT
);


----------------------------------------------------------------------
-- 16. obspression.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".obspression (
    siteid TEXT,
    zoneid TEXT,
    placetteid TEXT,
    date DATE,
    pression NUMERIC,
    note TEXT
);


----------------------------------------------------------------------
-- 17. obstemperature.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".obstemperature (
    siteid TEXT,
    zoneid TEXT,
    placetteid TEXT,
    date DATE,
    temperature NUMERIC,
    note TEXT
);


----------------------------------------------------------------------
-- 18. obsprecipitation.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".obsprecipitation (
    siteid TEXT,
    zoneid TEXT,
    placetteid TEXT,
    date DATE,
    precipitation NUMERIC,
    note TEXT
);


----------------------------------------------------------------------
-- 19. precipitation.csv (doublon public)
-- Je crée quand même la table
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_68".precipitation (
    siteid TEXT,
    zoneid TEXT,
    placetteid TEXT,
    date DATE,
    precipitation NUMERIC
);


-- Schéma pour les rejets
CREATE SCHEMA IF NOT EXISTS "Rejets";

-- Rejets localisation des plants
CREATE TABLE IF NOT EXISTS "Rejets".obsplantlocalisation (
    plantid     TEXT,
    date        DATE,
    siteid      TEXT,
    zoneid      TEXT,
    placetteid  TEXT,
    parcelleid  TEXT,
    coordx      NUMERIC,
    coordy      NUMERIC,
    note        TEXT,
    raison      TEXT
);

-- Rejets obsdimension
CREATE TABLE IF NOT EXISTS "Rejets".obsdimension (
    plantid   TEXT,
    date      DATE,
    longueur  NUMERIC,
    largeur   NUMERIC,
    note      TEXT,
    raison    TEXT
);

-- Rejets obsfloraison
CREATE TABLE IF NOT EXISTS "Rejets".obsfloraison (
    plantid       TEXT,
    date          DATE,
    typefloraison TEXT,
    note          TEXT,
    raison        TEXT
);

-- Rejets obsetat
CREATE TABLE IF NOT EXISTS "Rejets".obsetat (
    plantid  TEXT,
    date     DATE,
    etat     TEXT,
    note     TEXT,
    raison   TEXT
);
