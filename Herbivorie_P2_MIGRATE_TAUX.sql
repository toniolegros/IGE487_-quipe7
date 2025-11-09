-- Herbivorie_P2_MIGRATE_TAUX.sql
-- Migration non destructive : convertir les références catégorielles de la table Taux
-- en mesures quantitatives (taux_pct) et historiser dans la table Mesure.
-- IMPORTANT : une sauvegarde a dû être prise avant exécution (voir Herbivorie_P2_LOG_J2.md).

BEGIN;

-- 1) Création prudente de la table Mesure si elle n'existe pas (historisation)
CREATE TABLE IF NOT EXISTS public.mesure (
  id BIGSERIAL PRIMARY KEY,
  source_table TEXT NOT NULL,
  source_pk TEXT NOT NULL,
  type_mesure TEXT NOT NULL,
  unite TEXT,
  valeur_num NUMERIC,
  valeur_txt TEXT,
  date_obs DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2) S'assurer que les colonnes taux_pct existent (si pas déjà créées)
ALTER TABLE IF EXISTS "Herbivorie".Placette_Obstruction ADD COLUMN IF NOT EXISTS taux_pct INTEGER;
ALTER TABLE IF EXISTS "Herbivorie".Placette_Couvert ADD COLUMN IF NOT EXISTS taux_pct INTEGER;

-- 3) Mettre à jour taux_pct depuis la table Taux en prenant le point milieu (arrondi)
-- pour les lignes qui ont tcat défini mais taux_pct NULL
WITH t AS (
  SELECT tCat, ((tMin + tMax)::NUMERIC / 2)::INT AS midpoint
  FROM "Herbivorie".Taux
)
UPDATE "Herbivorie".Placette_Obstruction p
SET taux_pct = t.midpoint
FROM t
WHERE p.tcat = t.tCat AND p.taux_pct IS NULL ;

WITH t AS (
  SELECT tCat, ((tMin + tMax)::NUMERIC / 2)::INT AS midpoint
  FROM "Herbivorie".Taux
)
UPDATE "Herbivorie".Placette_Couvert p
SET taux_pct = t.midpoint
FROM t
WHERE p.tcat = t.tCat AND p.taux_pct IS NULL;

-- 4) Historiser les valeurs calculées dans la table Mesure (une ligne par observation)
-- Placette_Obstruction -> Mesure(type_mesure='obstruction', unite='%')
INSERT INTO public.mesure (source_table, source_pk, type_mesure, unite, valeur_num, date_obs)
SELECT 'Placette_Obstruction' AS source_table,
       (plac::text || '|' || nature || '|' || hauteur) AS source_pk,
       'obstruction' AS type_mesure,
       '%' AS unite,
       taux_pct::NUMERIC AS valeur_num,
       NULL::DATE AS date_obs
FROM "Herbivorie".Placette_Obstruction
WHERE taux_pct IS NOT NULL;

-- Placette_Couvert -> Mesure(type_mesure='couvert', unite='%')
INSERT INTO public.mesure (source_table, source_pk, type_mesure, unite, valeur_num, date_obs)
SELECT 'Placette_Couvert' AS source_table,
       (plac::text || '|' || ctype) AS source_pk,
       'couvert' AS type_mesure,
       '%' AS unite,
       taux_pct::NUMERIC AS valeur_num,
       NULL::DATE AS date_obs
FROM "Herbivorie".Placette_Couvert
WHERE taux_pct IS NOT NULL;

-- 5) Vérifications simples
SELECT 'Placette_Obstruction taux_pct count' AS info, COUNT(*) FROM "Herbivorie".Placette_Obstruction WHERE taux_pct IS NOT NULL;
SELECT 'Placette_Couvert taux_pct count' AS info, COUNT(*) FROM "Herbivorie".Placette_Couvert WHERE taux_pct IS NOT NULL;
SELECT 'Mesure total count' AS info, COUNT(*) FROM public.mesure;

COMMIT;

-- Fin de script
