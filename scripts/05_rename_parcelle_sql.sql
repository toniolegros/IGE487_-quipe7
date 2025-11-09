BEGIN;

-- Rename existing domain to free name
ALTER DOMAIN "Herbivorie".parcelle RENAME TO parcelle_domain;

-- Rename the consolidated reference table to the canonical name
ALTER TABLE "Herbivorie".parcelle_ref RENAME TO parcelle;

-- Add FK constraint (NOT VALID to avoid immediate validation failures)
ALTER TABLE "Herbivorie".plant
  ADD CONSTRAINT plant_parcelle_fk FOREIGN KEY (parcelle_id) REFERENCES "Herbivorie".parcelle(parcelle_id) NOT VALID;

COMMIT;

-- Verification
SELECT 'types' AS what, t.typname FROM pg_type t JOIN pg_namespace n ON t.typnamespace = n.oid WHERE t.typname ILIKE 'parcelle%';
SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema='Herbivorie' AND table_name LIKE 'parcelle%';
SELECT conname, convalidated FROM pg_constraint WHERE conname = 'plant_parcelle_fk' OR conname LIKE 'plant_%';
