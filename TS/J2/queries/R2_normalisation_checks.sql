\echo ==== R2 - VERIFICATIONS NORMALISATION (1NF->3NF/BCNF) ====
SET search_path TO "Herbivorie", public;

-- 1) Inventaire des clés primaires
\echo -- PK
SELECT c.relname AS table_name, a.attname AS pk_column
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_index i ON i.indrelid = c.oid AND i.indisprimary
JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = ANY(i.indkey)
WHERE c.relkind = 'r'
  AND n.nspname NOT IN ('pg_catalog','information_schema')
ORDER BY table_name, pk_column;

-- 2) Inventaire des clés étrangères
\echo -- FK
SELECT conrelid::regclass AS table_name,
       a.attname           AS column_name,
       confrelid::regclass AS ref_table,
       af.attname          AS ref_column
FROM pg_constraint
JOIN LATERAL unnest(conkey)  WITH ORDINALITY AS u (attnum, ord) ON true
JOIN pg_attribute a  ON a.attrelid  = conrelid  AND a.attnum  = u.attnum
JOIN LATERAL unnest(confkey) WITH ORDINALITY AS uf(attnum, ord) ON uf.ord = u.ord
JOIN pg_attribute af ON af.attrelid = confrelid AND af.attnum = uf.attnum
WHERE contype = 'f'
ORDER BY table_name, column_name;

-- 3) Index uniques (autres que PK)
\echo -- UNIQUE INDEX
SELECT t.relname AS table_name, i.relname AS index_name
FROM pg_index x
JOIN pg_class i ON i.oid = x.indexrelid
JOIN pg_class t ON t.oid = x.indrelid
WHERE x.indisunique AND NOT x.indisprimary
ORDER BY t.relname, i.relname;

-- 4) Colonnes des lieux (site/zone/placette/parcelle)
\echo -- COLONNES LIEUX
SELECT table_name, column_name
FROM information_schema.columns
WHERE table_schema='Herbivorie'
  AND column_name IN ('site_id','zone_id','placette','parcelle','parcelle_id','code')
ORDER BY table_name, column_name;

-- 4.b) Cohérence Parcelle(zone->site) si colonnes présentes
\echo -- COHERENCE PARCELLE (zone -> site)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='Herbivorie' AND table_name='parcelle' AND column_name='site_id')
     AND EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='Herbivorie' AND table_name='parcelle' AND column_name='zone_id') THEN
     RAISE NOTICE 'Différences site_id entre Parcelle et Zone ?';
  END IF;
END
$$ LANGUAGE plpgsql;

SELECT p.parcelle_id, p.zone_id, p.site_id AS site_in_parcelle, z.site_id AS site_from_zone
FROM Parcelle p
JOIN Zone z ON z.zone_id = p.zone_id
WHERE EXISTS (
  SELECT 1
  FROM information_schema.columns
  WHERE table_schema='Herbivorie' AND table_name='parcelle' AND column_name='site_id'
)
AND p.site_id IS DISTINCT FROM z.site_id;

-- 5) Doublons d’observations (BCNF)
\echo -- DOUBLONS OBSERVATIONS
SELECT 'ObsDimension' AS t, id, date, COUNT(*) c
FROM ObsDimension GROUP BY id, date HAVING COUNT(*)>1
UNION ALL
SELECT 'ObsFloraison', id, date, COUNT(*) FROM ObsFloraison GROUP BY id, date HAVING COUNT(*)>1
UNION ALL
SELECT 'ObsEtat', id, date, COUNT(*) FROM ObsEtat GROUP BY id, date HAVING COUNT(*)>1;

-- 6) Champs texte suspects (1NF)
\echo -- CHAMPS TEXTE A INSPECTER
SELECT table_name, column_name
FROM information_schema.columns
WHERE table_schema='Herbivorie' AND data_type IN ('text','character varying')
ORDER BY table_name, column_name;

-- 7) ENUMs "métier"
\echo -- ENUM TYPES
SELECT t.typname AS enum_type
FROM pg_type t
JOIN pg_enum e ON e.enumtypid = t.oid
GROUP BY t.typname
ORDER BY t.typname;

-- 8) Fonction compacité des taux
\echo -- FONCTION COMPACTITE TAUX
CREATE OR REPLACE FUNCTION Test_Taux_compacite(sMin INT, sMax INT)
RETURNS boolean
LANGUAGE SQL IMMUTABLE AS $$
  WITH b AS (
    SELECT tMin, tMax,
           lead(tMin) OVER (ORDER BY tMin) AS next_min
    FROM Taux
  )
  SELECT (SELECT min(tMin) FROM Taux) = sMin
     AND (SELECT max(tMax) FROM Taux) = sMax
     AND NOT EXISTS (
           SELECT 1 FROM b
           WHERE next_min IS NOT NULL
             AND (tMax + 1) <> next_min
       );
$$;

-- 8.b) Test (adapte 0..100 à ta grille)
\echo -- RESULTAT COMPACTITE (attendu: t/f selon vos Taux)
SELECT Test_Taux_compacite(0,100) AS taux_compacts;

\echo ==== FIN R2 CHECKS ====
