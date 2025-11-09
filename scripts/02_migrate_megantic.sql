-- scripts/02_migrate_megantic.sql
-- Exemple de migration sécurisée depuis staging.megantic vers une table normalisée
-- Ce script ne modifie pas les tables de production: il crée une table de sortie
-- staging.megantic_normalized qui peut être inspectée et utilisée pour tests.

CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.megantic_normalized (
  global_id TEXT,
  placette TEXT,
  parcelle_code TEXT,
  longueur INTEGER,
  largeur INTEGER,
  fleur BOOLEAN,
  date_obs DATE,
  JJ INTEGER,
  etat TEXT,
  note TEXT
);

TRUNCATE TABLE staging.megantic_normalized;

INSERT INTO staging.megantic_normalized (global_id, placette, parcelle_code, longueur, largeur, fleur, date_obs, JJ, etat, note)
SELECT
  id,
  placette,
  NULLIF(sous_parcelle,'') AS parcelle_code,
  CASE WHEN longueur ~ '^[0-9]+$' THEN CAST(longueur AS INTEGER) ELSE NULL END,
  CASE WHEN largeur ~ '^[0-9]+$' THEN CAST(largeur AS INTEGER) ELSE NULL END,
  CASE WHEN lower(fleur) IN ('1','true','t','y') THEN true WHEN lower(fleur) IN ('0','false','f','n') THEN false ELSE NULL END,
  -- Accept only valid YYYY-MM-DD where month/day not 00
  CASE WHEN date_obs ~ '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$' THEN CAST(date_obs AS DATE) ELSE NULL END,
  JJ,
  etat,
  note
FROM staging.megantic;

-- Vérification rapide
SELECT count(*) AS normalized_count FROM staging.megantic_normalized;
SELECT * FROM staging.megantic_normalized LIMIT 10;

-- NOTE pour la suite :
-- - si vous souhaitez alimenter les tables concrètes (Placette_core, Plant, Mesure),
--   écrire des INSERT ... SELECT à partir de staging.megantic_normalized en faisant
--   les règles de mapping (création de Site/Zone/Parcelle si nécessaire, génération
--   d'un global_id unique, et association des mesures à TypeMesure/UniteMesure).
