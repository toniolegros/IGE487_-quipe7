-- scripts/03_push_to_herbivorie.sql
-- Idempotent mapping from staging.megantic_normalized into the Herbivorie schema
-- Inserts Sites, Zones, Parcelles, a default Peuplement, Placette_core, Plants,
-- ObsDimension and ObsFloraison based on normalized staging data.

-- Usage: run this file with psql connected to the database that contains the
-- staging schema and the Herbivorie schema (the project default environment).

SET client_min_messages = warning;
BEGIN;

-- Use the staging data and Herbivorie target schema
SET search_path = staging, "Herbivorie", public;

-- 0) Defensive: ensure the normalized staging table exists
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='staging' AND table_name='megantic_normalized') THEN
    RAISE EXCEPTION 'staging.megantic_normalized not found; run scripts/02_migrate_megantic.sql first';
  END IF;
END;
$$;

-- 1) Ensure a default Peuplement exists so we can insert Placette_core rows
INSERT INTO peuplement (peup, description)
VALUES ('I0001','Import automatique depuis Megantic CSV')
ON CONFLICT (peup) DO NOTHING;

-- 2) Create Parcelle table if the consolidated DDL was not applied yet
CREATE TABLE IF NOT EXISTS parcelle (
  parcelle_id SERIAL PRIMARY KEY,
  site_id TEXT NOT NULL,
  zone_id TEXT NOT NULL,
  code TEXT NOT NULL,
  description TEXT,
  UNIQUE (site_id, zone_id, code)
);

-- 3) Insert Sites (site_id = alphabetic prefix of placette, e.g. A from A1)
INSERT INTO site (site_id, nom)
SELECT DISTINCT regexp_replace(placette,'[0-9]','','g') AS site_id,
       regexp_replace(placette,'[0-9]','','g') AS nom
FROM staging.megantic_normalized
WHERE placette IS NOT NULL
ON CONFLICT (site_id) DO NOTHING;

-- 4) Insert Zones (zone_id = placette code)
INSERT INTO zone (zone_id, site_id, nom)
SELECT DISTINCT placette AS zone_id,
       regexp_replace(placette,'[0-9]','','g') AS site_id,
       placette AS nom
FROM staging.megantic_normalized
WHERE placette IS NOT NULL
ON CONFLICT (zone_id) DO NOTHING;

-- 5) Insert Parcelles (code comes from parcelle_code)
INSERT INTO parcelle (site_id, zone_id, code, description)
SELECT DISTINCT
  regexp_replace(placette,'[0-9]','','g') AS site_id,
  placette AS zone_id,
  parcelle_code AS code,
  format('Import: placette=%s', placette) AS description
FROM staging.megantic_normalized
WHERE parcelle_code IS NOT NULL AND parcelle_code <> ''
ON CONFLICT (site_id, zone_id, code) DO NOTHING;

-- 6) Insert Placette_core rows (we provide a default peuplement 'IMP' and a date)
INSERT INTO placette_core (plac, peup, date, site_id, zone_id)
SELECT placette AS plac,
       'I0001'::text AS peup,
       COALESCE(MIN(date_obs), CURRENT_DATE) AS date,
       regexp_replace(placette,'[0-9]','','g') AS site_id,
       placette AS zone_id
FROM staging.megantic_normalized
GROUP BY placette
ON CONFLICT (plac) DO NOTHING;

-- 7) Insert or update Plants
-- plant.parcelle must be integer; use numeric parcelle_code when available, else 0
-- set parcelle_id to Parcelle.parcelle_id when possible
-- create a small sequence for synthetic ids if needed
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relkind='S' AND relname='mig_plant_seq') THEN
    CREATE SEQUENCE mig_plant_seq START 20000;
  END IF;
END$$;

-- a) Insert plants whose global_id already match the domain pattern MM[A-C]####
INSERT INTO plant (id, global_id, plac, parcelle, date, note, parcelle_id)
SELECT m.global_id AS id,
       m.global_id AS global_id,
       m.placette AS plac,
       CASE WHEN m.parcelle_code ~ '^[0-9]+$' THEN CAST(m.parcelle_code AS INTEGER) ELSE 0 END AS parcelle,
       COALESCE(m.date_obs, CURRENT_DATE) AS date,
       COALESCE(NULLIF(m.note, ''), 'importé')::text AS note,
       p.parcelle_id
FROM (
  SELECT DISTINCT ON (global_id) *
  FROM staging.megantic_normalized
  WHERE global_id IS NOT NULL
  ORDER BY global_id, COALESCE(date_obs, CURRENT_DATE) ASC
) m
LEFT JOIN parcelle p ON p.site_id = regexp_replace(m.placette,'[0-9]','','g') AND p.zone_id = m.placette AND p.code = m.parcelle_code
WHERE m.global_id ~ '^MM[A-C][0-9]{4}$'
ON CONFLICT (id) DO UPDATE
  SET global_id = EXCLUDED.global_id,
      plac = EXCLUDED.plac,
      parcelle = EXCLUDED.parcelle,
      parcelle_id = COALESCE(EXCLUDED.parcelle_id, plant.parcelle_id),
      date = LEAST(COALESCE(plant.date, EXCLUDED.date), EXCLUDED.date),
      note = EXCLUDED.note;

-- b) For rows with non-conforming global_id, generate a synthetic id (kept unique)
INSERT INTO plant (id, global_id, plac, parcelle, date, note, parcelle_id)
SELECT ('MMA' || lpad(nextval('mig_plant_seq')::text,4,'0')) AS id,
       m.global_id AS global_id,
       m.placette AS plac,
       CASE WHEN m.parcelle_code ~ '^[0-9]+$' THEN CAST(m.parcelle_code AS INTEGER) ELSE 0 END AS parcelle,
       COALESCE(m.date_obs, CURRENT_DATE) AS date,
       COALESCE(NULLIF(m.note, ''), 'importé')::text AS note,
       p.parcelle_id
FROM (
  SELECT DISTINCT ON (global_id) *
  FROM staging.megantic_normalized
  WHERE global_id IS NOT NULL
  ORDER BY global_id, COALESCE(date_obs, CURRENT_DATE) ASC
) m
LEFT JOIN parcelle p ON p.site_id = regexp_replace(m.placette,'[0-9]','','g') AND p.zone_id = m.placette AND p.code = m.parcelle_code
WHERE NOT (m.global_id ~ '^MM[A-C][0-9]{4}$')
ON CONFLICT (id) DO NOTHING;

-- 8) Insert ObsDimension for rows having longueur and largeur
INSERT INTO obsdimension (id, longueur, largeur, date, note)
SELECT p.id,
       m.longueur::int,
       m.largeur::int,
       COALESCE(m.date_obs, CURRENT_DATE) AS date,
  COALESCE(NULLIF(m.note,''), 'importé')::text
FROM staging.megantic_normalized m
JOIN plant p ON p.id = m.global_id
WHERE m.longueur IS NOT NULL AND m.largeur IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM obsdimension od WHERE od.id = p.id AND od.date = COALESCE(m.date_obs, CURRENT_DATE)
  );

-- 9) Insert ObsFloraison for rows with fleur information
INSERT INTO obsfloraison (id, fleur, date, note)
SELECT p.id,
       m.fleur::boolean,
       COALESCE(m.date_obs, CURRENT_DATE) AS date,
  COALESCE(NULLIF(m.note,''), 'importé')::text
FROM staging.megantic_normalized m
JOIN plant p ON p.id = m.global_id
WHERE m.fleur IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM obsfloraison ofl WHERE ofl.id = p.id AND ofl.date = COALESCE(m.date_obs, CURRENT_DATE)
  );

-- 10) Log summary
INSERT INTO log_operation (operation, objet, details)
VALUES ('MIGRATION_PUSH', 'Megantic -> Herbivorie', format('sites=%s;zones=%s;parcelles=%s;plants=%s',
  (SELECT count(*) FROM site),
  (SELECT count(*) FROM zone),
  (SELECT count(*) FROM parcelle),
  (SELECT count(*) FROM plant) ) );

COMMIT;

-- Verification queries (user-run or reviewed after execution):
-- SELECT count(*) FROM "Site";
-- SELECT count(*) FROM "Zone";
-- SELECT count(*) FROM Parcelle;
-- SELECT count(*) FROM "Placette_core";
-- SELECT count(*) FROM "Plant";
-- SELECT count(*) FROM "ObsDimension";
-- SELECT count(*) FROM "ObsFloraison";
