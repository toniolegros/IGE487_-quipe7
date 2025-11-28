DROP schema IF EXISTS "Staging" CASCADE;
CREATE SCHEMA IF NOT EXISTS "Staging";
CREATE SCHEMA IF NOT EXISTS "Herbivorie";
SET SCHEMA 'Staging';


CREATE TABLE megantic (
  site_id           TEXT,
  site_nom          TEXT,
  description_site  TEXT,
  description       TEXT,
  zone              TEXT,
  description_zone  TEXT,
  plac              TEXT,
  placette          TEXT,
  parcelle          TEXT,
  rang              INTEGER,
  peup              TEXT,
  description_peup  TEXT,
  arbre             TEXT,
  description_arbre TEXT,
  etat              TEXT,
  description_etat  TEXT,
  id                TEXT,
  date              TEXT,
  note              TEXT,
  fleur             BOOLEAN,
  longueur          INTEGER,
  largeur           INTEGER,
  unite_id          INTEGER,
  tcat              TEXT,
  tval            INTEGER,
  ctype             TEXT,
  nature            TEXT,
  hauteur           TEXT
);

-- Nettoyer d'éventuelles données précédentes pour MI
DELETE FROM megantic
WHERE site_id LIKE 'MI%';

----------------------------------------------------------
-- 1) 5 000 lignes pour la zone MIA (placettes A1..A4)
----------------------------------------------------------
INSERT INTO megantic (
  site_id, site_nom, description_site, description,
  zone, description_zone,
  plac, placette, parcelle, rang,
  peup, description_peup,
  arbre, description_arbre,
  etat, description_etat,
  id, date, note,
  fleur, longueur, largeur, unite_id,
  tcat, tval, ctype, nature, hauteur
)
SELECT
  'MI' AS site_id,
  'Mont d''Iberville' AS site_nom,
  'Site principal P2_J2 – Mont d''Iberville' AS description_site,

  'Placette ' ||
    CASE
      WHEN i BETWEEN    1 AND  1250 THEN 'MIA-A1'
      WHEN i BETWEEN 1251 AND  2500 THEN 'MIA-A2'
      WHEN i BETWEEN 2501 AND  3750 THEN 'MIA-A3'
      ELSE                                 'MIA-A4'
    END AS description,

  'MIA' AS zone,
  'Zone inférieure – Mont d''Iberville' AS description_zone,

  -- plac / placette (A1..A4)
  CASE
    WHEN i BETWEEN    1 AND  1250 THEN 'A1'
    WHEN i BETWEEN 1251 AND  2500 THEN 'A2'
    WHEN i BETWEEN 2501 AND  3750 THEN 'A3'
    ELSE                                 'A4'
  END AS plac,
  CASE
    WHEN i BETWEEN    1 AND  1250 THEN 'A1'
    WHEN i BETWEEN 1251 AND  2500 THEN 'A2'
    WHEN i BETWEEN 2501 AND  3750 THEN 'A3'
    ELSE                                 'A4'
  END AS placette,

  -- parcelle 01..04
  CASE (i % 4)
    WHEN 1 THEN '01'
    WHEN 2 THEN '02'
    WHEN 3 THEN '03'
    ELSE       '04'
  END AS parcelle,

  ((i - 1) % 4) + 1 AS rang,

  -- Peuplement générique (codes compatibles avec l’exemple initial)
  'P1234' AS peup,
  'Peuplement mixte' AS description_peup,
  'AB12' AS arbre,
  'Érable rouge' AS description_arbre,

  'A' AS etat,
  'Bon état' AS description_etat,

  -- Identifiant de plant : MIA0001 .. MIA5000
  'MIA' || LPAD(i::text, 4, '0') AS id,

  -- Période de 150 jours à partir du 2023-05-01 (format texte ISO)
  (DATE '2023-05-01' + ((i - 1) % 150))::text AS date,

  'Observation générée – site MI / zone MIA' AS note,

  (i % 2 = 0) AS fleur,
  10 + (i % 5) AS longueur,
  5 + (i % 3) AS largeur,
  1 AS unite_id,

  'A' AS tcat,
  40 + (i % 40) AS tval,      -- 40..79
  'graminees' AS ctype,
  'feuillu'   AS nature,
  '1m'        AS hauteur
FROM generate_series(1, 5000) AS s(i);

----------------------------------------------------------
-- 2) 5 000 lignes pour la zone MIB (placettes B1..B4)
----------------------------------------------------------
INSERT INTO megantic (
  site_id, site_nom, description_site, description,
  zone, description_zone,
  plac, placette, parcelle, rang,
  peup, description_peup,
  arbre, description_arbre,
  etat, description_etat,
  id, date, note,
  fleur, longueur, largeur, unite_id,
  tcat, tval, ctype, nature, hauteur
)
SELECT
  'MI' AS site_id,
  'Mont d''Iberville' AS site_nom,
  'Site principal P2_J2 – Mont d''Iberville' AS description_site,

  'Placette ' ||
    CASE
      WHEN i BETWEEN    1 AND  1250 THEN 'MIB-B1'
      WHEN i BETWEEN 1251 AND  2500 THEN 'MIB-B2'
      WHEN i BETWEEN 2501 AND  3750 THEN 'MIB-B3'
      ELSE                                 'MIB-B4'
    END AS description,

  'MIB' AS zone,
  'Zone supérieure – Mont d''Iberville' AS description_zone,

  -- plac / placette (B1..B4)
  CASE
    WHEN i BETWEEN    1 AND  1250 THEN 'B1'
    WHEN i BETWEEN 1251 AND  2500 THEN 'B2'
    WHEN i BETWEEN 2501 AND  3750 THEN 'B3'
    ELSE                                 'B4'
  END AS plac,
  CASE
    WHEN i BETWEEN    1 AND  1250 THEN 'B1'
    WHEN i BETWEEN 1251 AND  2500 THEN 'B2'
    WHEN i BETWEEN 2501 AND  3750 THEN 'B3'
    ELSE                                 'B4'
  END AS placette,

  -- parcelle 01..04
  CASE (i % 4)
    WHEN 1 THEN '01'
    WHEN 2 THEN '02'
    WHEN 3 THEN '03'
    ELSE       '04'
  END AS parcelle,

  ((i - 1) % 4) + 1 AS rang,

  'P1234' AS peup,
  'Peuplement mixte' AS description_peup,
  'AB12' AS arbre,
  'Érable rouge' AS description_arbre,

  'A' AS etat,
  'Bon état' AS description_etat,

  -- Identifiant de plant : MIB0001 .. MIB5000
  'MIB' || LPAD(i::text, 4, '0') AS id,

  (DATE '2023-05-01' + ((i - 1) % 150))::text AS date,
  'Observation générée – site MI / zone MIB' AS note,

  (i % 2 = 1) AS fleur,
  11 + (i % 5) AS longueur,
  6  + (i % 3) AS largeur,
  1 AS unite_id,

  'A' AS tcat,
  35 + (i % 40) AS tval,
  'fougeres' AS ctype,
  'coniferien' AS nature,
  '2m'        AS hauteur
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

call megantic_ELT();
CALL Carnets_ELT();


select * from "Herbivorie_lecture".site_eva();

-- Lire tous les plants
SELECT * FROM Plant_EVA();

SELECT * FROM "Herbivorie".obshumidite_EVA();

-- Lire les plants d’une zone donnée
SELECT * FROM Plant_EVA_par_zone('MIA');

-- Insérer un nouveau plant
CALL Plant_INS('MMA', 'MMA0001', 'A1', DATE '2023-05-04', 'Plant observé en bordure');

-- Modifier entièrement un plant
CALL Plant_MOD('MMB', 'MMA0001', 'B2', DATE '2023-06-01', 'Plant déplacé');

-- Modifier seulement la note
CALL Plant_MOD_note('MMA0001', 'Note corrigée');

-- Supprimer un plant (strict : erreur si l’id n’existe pas)
CALL Plant_RET('MMA0001');


select * from rejets_synthese;

select * from rejets;
