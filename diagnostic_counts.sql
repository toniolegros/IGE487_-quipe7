-- diagnostic_counts.sql
SET search_path TO "Herbivorie";
-- counts and samples for migration troubleshooting
SELECT 'Taux count' AS info, count(*) FROM taux;
SELECT 'Placette_Obstruction tcat count' AS info, count(*) FROM placette_obstruction WHERE tcat IS NOT NULL;
SELECT 'Placette_Obstruction taux_pct count' AS info, count(*) FROM placette_obstruction WHERE taux_pct IS NOT NULL;
SELECT 'Placette_Couvert tcat count' AS info, count(*) FROM placette_couvert WHERE tcat IS NOT NULL;
SELECT 'Placette_Couvert taux_pct count' AS info, count(*) FROM placette_couvert WHERE taux_pct IS NOT NULL;
SELECT 'Mesure total count' AS info, count(*) FROM public.mesure;

-- Samples
SELECT 'Taux sample' AS src, * FROM taux LIMIT 5;
SELECT 'Placette_Obstruction sample' AS src, * FROM placette_obstruction LIMIT 5;
SELECT 'Placette_Couvert sample' AS src, * FROM placette_couvert LIMIT 5;
