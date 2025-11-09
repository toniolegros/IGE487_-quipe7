-- scripts/04_finalise_parcelle.sql
-- Finalise la consolidation des parcelles :
--  - crée la table Herbivorie.parcelle si nécessaire
--  - copie les lignes depuis toutes les autres tables "parcelle" présentes
--  - met à jour Herbivorie.plant.parcelle_id pour pointer vers Herbivorie.parcelle
--  - affiche des comptes de vérification

SET client_min_messages = warning;
BEGIN;

-- Travailler explicitement avec le schéma Herbivorie en cible
SET search_path = "Herbivorie", staging, public;

-- 1) Assurer la présence de la table cible
-- Note: il existe déjà un DOMAIN/TYPE nommé 'parcelle' dans le schéma Herbivorie;
-- pour éviter le conflit de nom, nous créons une table `parcelle_ref` qui
-- servira de table de référence consolidée. Un renommage manuel ultérieur
-- peut être effectué si on supprime/renomme le domain en question.
CREATE TABLE IF NOT EXISTS "Herbivorie".parcelle_ref (
  parcelle_id SERIAL PRIMARY KEY,
  site_id TEXT NOT NULL,
  zone_id TEXT NOT NULL,
  code TEXT NOT NULL,
  description TEXT,
  UNIQUE (site_id, zone_id, code)
);

-- 2) Copier les données depuis d'autres schémas qui ont pu contenir une table parcelle
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT table_schema FROM information_schema.tables
    WHERE table_name = 'parcelle' AND table_schema <> 'Herbivorie'
  LOOP
    RAISE NOTICE 'Copying parcelle rows from schema %', r.table_schema;
    EXECUTE format(
      'INSERT INTO "Herbivorie".parcelle_ref (site_id, zone_id, code, description)
       SELECT DISTINCT site_id, zone_id, code, description FROM %I.parcelle
       ON CONFLICT (site_id, zone_id, code) DO NOTHING',
      r.table_schema);
  END LOOP;
END$$;

-- 3) Réconcilier plant.parcelle_id : associer les plants aux parcelles nouvellement créées
UPDATE "Herbivorie".plant pl
SET parcelle_id = hp.parcelle_id
FROM "Herbivorie".parcelle_ref hp
WHERE hp.site_id = regexp_replace(pl.plac,'[0-9]','','g')
  AND hp.zone_id = pl.plac
  AND hp.code = pl.parcelle::text;

-- 4) Vérifications (résultats affichés à l'utilisateur)
SELECT 'after_finalize' AS phase, 'site', count(*) FROM "Herbivorie".site;
SELECT 'after_finalize', 'zone', count(*) FROM "Herbivorie".zone;
SELECT 'after_finalize', 'parcelle_ref', count(*) FROM "Herbivorie".parcelle_ref;
SELECT 'after_finalize', 'placette_core', count(*) FROM "Herbivorie".placette_core;
SELECT 'after_finalize', 'plant', count(*) FROM "Herbivorie".plant;
SELECT 'after_finalize', 'obsdimension', count(*) FROM "Herbivorie".obsdimension;
SELECT 'after_finalize', 'obsfloraison', count(*) FROM "Herbivorie".obsfloraison;

COMMIT;

-- Notes :
-- - Ce script est conçu pour être non-destructif (INSERT ... ON CONFLICT DO NOTHING) ;
--   il ne supprime aucune table existante.
-- - Après exécution, vous pouvez (si souhaité) supprimer la table parcelle présente
--   dans d'autres schémas (staging/public) pour éviter la confusion, mais faites-le
--   seulement après validation et sauvegarde.
