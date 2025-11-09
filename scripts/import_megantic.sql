-- scripts/import_megantic.sql
-- Crée un schéma staging et importe le CSV de mesures Megantic
-- Pour usage avec psql côté serveur (le fichier doit être présent dans /tmp du conteneur)

CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.megantic (
  id TEXT,
  placette TEXT,
  longueur INTEGER,
  largeur INTEGER,
  fleur TEXT,
  sous_parcelle TEXT,
  date_obs TEXT,
  JJ INTEGER,
  etat TEXT,
  note TEXT
);

-- Import : s'assurer que le fichier a été copié dans /tmp/megantic_mesures.csv
-- Utiliser : COPY staging.megantic FROM '/tmp/megantic_mesures.csv' DELIMITER ';' CSV HEADER NULL 'NA';

-- Exemple d'exécution côté container (si le fichier est en /tmp/) :
-- psql -U herbivorie -d herbivorie_dev -c "COPY staging.megantic FROM '/tmp/megantic_mesures.csv' DELIMITER ';' CSV HEADER NULL 'NA';"

-- Safety: vérifier quelques lignes après import
SELECT count(*) AS total_rows FROM staging.megantic;
SELECT id, placette, longueur, largeur, fleur, sous_parcelle, date_obs, JJ, etat, note FROM staging.megantic LIMIT 10;
