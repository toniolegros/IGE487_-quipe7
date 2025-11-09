-- scripts/03_fix_parcelle_schema.sql
-- Ensure parcelle exists in Herbivorie schema and migrate rows from staging.parcelle

SET search_path = staging, "Herbivorie", public;

-- Create parcelle in Herbivorie schema (explicitly qualified)
CREATE TABLE IF NOT EXISTS "Herbivorie".parcelle (
  parcelle_id SERIAL PRIMARY KEY,
  site_id TEXT NOT NULL,
  zone_id TEXT NOT NULL,
  code TEXT NOT NULL,
  description TEXT,
  UNIQUE (site_id, zone_id, code)
);

-- Copy distinct parcelle rows from staging.parcelle into Herbivorie.parcelle
INSERT INTO "Herbivorie".parcelle (site_id, zone_id, code, description)
SELECT DISTINCT site_id, zone_id, code, description
FROM staging.parcelle
ON CONFLICT (site_id, zone_id, code) DO NOTHING;

-- Update plant.parcelle_id to point to Herbivorie.parcelle.parcelle_id by matching on site/zone/code
UPDATE "Herbivorie".plant AS pl
SET parcelle_id = hp.parcelle_id
FROM staging.parcelle sp
JOIN "Herbivorie".parcelle hp ON hp.site_id = sp.site_id AND hp.zone_id = sp.zone_id AND hp.code = sp.code
WHERE pl.parcelle_id = sp.parcelle_id;

-- Note: staging.parcelle may be retained for traceability.
