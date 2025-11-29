DROP SCHEMA IF EXISTS "Staging" CASCADE;
CREATE SCHEMA IF NOT EXISTS "Staging";
CREATE SCHEMA IF NOT EXISTS "Herbivorie";
SET SCHEMA 'Staging';

--------------------------------------------------------------
-- TABLES DES CARNETS
--------------------------------------------------------------

-- ============================
-- CARNET PLANT
-- ============================
CREATE TABLE carnetPlant (
  site_id   TEXT,
  id        TEXT,      -- Plant_id
  zone      TEXT,      -- Zone_id
  plac      TEXT,      -- Placette_id
  parcelle  TEXT,      -- Parcelle_id (01..99)
  date      TEXT,      -- Date identification
  note      TEXT       -- Description
);

COMMENT ON TABLE carnetPlant IS 'Carnet des plants : identité et localisation des plants';


-- ============================
-- CARNET PLACETTE
-- ============================
CREATE TABLE carnetPlacette (
  site_id           TEXT,
  zone              TEXT,
  plac              TEXT,
  date              TEXT,

  peup              TEXT,
  rang              INTEGER,
  arbre             TEXT,

  nature            TEXT,
  hauteur           TEXT,
  tcat_obstruction  TEXT,
  tval_obstruction  INTEGER,

  ctype             TEXT,
  tcat_couvert      TEXT,
  tval_couvert      INTEGER
);

COMMENT ON TABLE carnetPlacette IS 'Carnet des placettes : peuplement, dominants, obstruction et couvert';


-- ============================
-- CARNET OBSERVATION
-- ============================
CREATE TABLE carnetObservation (
  id                TEXT,
  date              TEXT,
  type_observation  TEXT,     -- 'dimension', 'floraison', 'etat'

  longueur          INTEGER,
  largeur           INTEGER,
  unite_id          INTEGER,

  fleur             BOOLEAN,
  etat              TEXT,
  note              TEXT
);

COMMENT ON TABLE carnetObservation IS 'Carnet des observations : dimensions, floraison, état';


--------------------------------------------------------------
-- DONNÉES DE TEST : MIA (5000)
--------------------------------------------------------------

-- ============================
-- CARNET PLANT MIA
-- ============================
INSERT INTO carnetPlant (id, zone, plac, parcelle, date, note, site_id)
SELECT
  'MIA' || LPAD(i::text, 4, '0'),
  'MIA',
  CASE
    WHEN i BETWEEN 1 AND 1250 THEN 'A1'
    WHEN i BETWEEN 1251 AND 2500 THEN 'A2'
    WHEN i BETWEEN 2501 AND 3750 THEN 'A3'
    ELSE 'A4'
  END,
  LPAD(((i - 1) % 4 + 1)::text, 2, '0'),
  '2023-05-01',
  'Plant identifié — zone MIA',
  'MI'
FROM generate_series(1, 5000) AS s(i);


-- ============================
-- CARNET PLACETTE MIA
-- ============================
INSERT INTO carnetPlacette (
  zone, plac, date, peup,
  rang, arbre,
  nature, hauteur, tcat_obstruction, tval_obstruction,
  ctype, tcat_couvert, tval_couvert,
  site_id
)
SELECT
  'MIA',
  CASE
    WHEN i BETWEEN 1 AND 250 THEN 'A1'
    WHEN i BETWEEN 251 AND 500 THEN 'A2'
    WHEN i BETWEEN 501 AND 750 THEN 'A3'
    ELSE 'A4'
  END,
  (DATE '2023-05-01' + ((i - 1) % 30))::text,
  'P1234',
  ((i - 1) % 3) + 1,
  'AB12',
  'feuillu',
  '1m',
  'B',
  50 + (i % 25),
  'graminees',
  'C',
  30 + (i % 20),
  'MI'
FROM generate_series(1, 1000) AS s(i);


-- ============================
-- CARNET OBSERVATION MIA
-- ============================

-- Dimensions
INSERT INTO carnetObservation (id, date, type_observation, longueur, largeur, unite_id, fleur, etat, note)
SELECT
  'MIA' || LPAD(i::text, 4, '0'),
  (DATE '2023-05-01' + ((i - 1) % 150))::text,
  'dimension',
  10 + (i % 5),
  5 + (i % 3),
  1,
  NULL,
  NULL,
  'Mesure de feuille — MIA'
FROM generate_series(1, 5000) AS s(i);

-- Floraison
INSERT INTO carnetObservation (id, date, type_observation, longueur, largeur, unite_id, fleur, etat, note)
SELECT
  'MIA' || LPAD(i::text, 4, '0'),
  (DATE '2023-05-01' + ((i - 1) % 150) + 15)::text,
  'floraison',
  NULL, NULL, NULL,
  (i % 2 = 0),
  NULL,
  'Observation floraison — MIA'
FROM generate_series(1, 5000) AS s(i);

-- État
INSERT INTO carnetObservation (id, date, type_observation, longueur, largeur, unite_id, fleur, etat, note)
SELECT
  'MIA' || LPAD(i::text, 4, '0'),
  (DATE '2023-05-01' + ((i - 1) % 150) + 30)::text,
  'etat',
  NULL, NULL, NULL,
  NULL,
  'A',
  'Observation état — MIA'
FROM generate_series(1, 5000) AS s(i);



--------------------------------------------------------------
-- DONNÉES DE TEST : MIB (5000)
--------------------------------------------------------------

-- ============================
-- CARNET PLANT MIB
-- ============================
INSERT INTO carnetPlant (id, zone, plac, parcelle, date, note, site_id)
SELECT
  'MIB' || LPAD(i::text, 4, '0'),
  'MIB',
  CASE
    WHEN i BETWEEN 1 AND 1250 THEN 'B1'
    WHEN i BETWEEN 1251 AND 2500 THEN 'B2'
    WHEN i BETWEEN 2501 AND 3750 THEN 'B3'
    ELSE 'B4'
  END,
  LPAD(((i - 1) % 4 + 1)::text, 2, '0'),
  '2023-05-01',
  'Plant identifié — zone MIB',
  'MI'
FROM generate_series(1, 5000) AS s(i);


-- ============================
-- CARNET PLACETTE MIB
-- ============================
INSERT INTO carnetPlacette (
  zone, plac, date, peup,
  rang, arbre,
  nature, hauteur, tcat_obstruction, tval_obstruction,
  ctype, tcat_couvert, tval_couvert,
  site_id
)
SELECT
  'MIB',
  CASE
    WHEN i BETWEEN 1 AND 250 THEN 'B1'
    WHEN i BETWEEN 251 AND 500 THEN 'B2'
    WHEN i BETWEEN 501 AND 750 THEN 'B3'
    ELSE 'B4'
  END,
  (DATE '2023-05-01' + ((i - 1) % 30))::text,
  'P1234',
  ((i - 1) % 3) + 1,
  'AB12',
  'coniferien',
  '2m',
  'C',
  35 + (i % 25),
  'fougeres',
  'D',
  15 + (i % 20),
  'MI'
FROM generate_series(1, 1000) AS s(i);


-- ============================
-- CARNET OBSERVATION MIB
-- ============================

-- Dimensions
INSERT INTO carnetObservation (id, date, type_observation, longueur, largeur, unite_id, fleur, etat, note)
SELECT
  'MIB' || LPAD(i::text, 4, '0'),
  (DATE '2023-05-01' + ((i - 1) % 150))::text,
  'dimension',
  11 + (i % 5),
  6 + (i % 3),
  1,
  NULL,
  NULL,
  'Mesure de feuille — MIB'
FROM generate_series(1, 5000) AS s(i);

-- Floraison
INSERT INTO carnetObservation (id, date, type_observation, longueur, largeur, unite_id, fleur, etat, note)
SELECT
  'MIB' || LPAD(i::text, 4, '0'),
  (DATE '2023-05-01' + ((i - 1) % 150) + 15)::text,
  'floraison',
  NULL, NULL, NULL,
  (i % 2 = 1),
  NULL,
  'Observation floraison — MIB'
FROM generate_series(1, 5000) AS s(i);

-- État
INSERT INTO carnetObservation (id, date, type_observation, longueur, largeur, unite_id, fleur, etat, note)
SELECT
  'MIB' || LPAD(i::text, 4, '0'),
  (DATE '2023-05-01' + ((i - 1) % 150) + 30)::text,
  'etat',
  NULL, NULL, NULL,
  NULL,
  'A',
  'Observation état — MIB'
FROM generate_series(1, 5000) AS s(i);


SET SCHEMA 'Herbivorie';

CREATE TABLE IF NOT EXISTS Rejets (
    rejet_id   BIGSERIAL PRIMARY KEY,
    flux       TEXT NOT NULL,
    motif      TEXT NOT NULL,
    details    TEXT,
    attributs  text,
    ligne      JSONB NOT NULL,
    date_rejet TIMESTAMP NOT NULL DEFAULT now()
);

CREATE OR REPLACE VIEW Rejets_Synthese AS
SELECT
    flux,
    COUNT(*) AS total_rejets,
    MAX(date_rejet) AS dernier_rejet,
    MIN(motif) AS exemple_motif,
    MIN(ligne::text) AS exemple_ligne
FROM Rejets
GROUP BY flux
ORDER BY flux;


CREATE OR REPLACE VIEW Rejets_Detail AS
SELECT
    rejet_id,
    flux,
    date_rejet,
    motif,
    details,
    ligne
FROM Rejets
ORDER BY date_rejet DESC;

CALL Carnets_ELT();

--Équipe 68
CALL ETL_Herbivorie();
CALL elt_meteo();

--Équipe 63
call elt_carnets63();
CALL ELT_carnet_meteo63();


--------------------------------------------------------------
-- VÉRIFICATIONS
--------------------------------------------------------------
SELECT 'carnetPlant' AS table_name, COUNT(*) FROM carnetPlant
UNION ALL
SELECT 'carnetPlacette', COUNT(*) FROM carnetPlacette
UNION ALL
SELECT 'carnetObservation', COUNT(*) FROM carnetObservation;

SELECT * FROM carnetPlant LIMIT 5;
SELECT * FROM carnetPlacette LIMIT 5;
SELECT * FROM carnetObservation LIMIT 5;

select * from "Herbivorie_lecture".arbre_eva();