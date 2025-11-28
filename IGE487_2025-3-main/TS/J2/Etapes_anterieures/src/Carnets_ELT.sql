SET SCHEMA 'Herbivorie';

CREATE OR REPLACE PROCEDURE Carnets_ELT()
LANGUAGE plpgsql AS
$$
BEGIN
/* ===========================================================
   1) CARNET PLANT
   =========================================================== */

------------------------------
-- INSERT : Site (données minimales)
------------------------------
WITH src AS (
    SELECT DISTINCT site_id
    FROM "Staging".carnetPlant
    WHERE site_id IS NOT NULL
)
INSERT INTO Site(id, site, description)
SELECT
    site_conv(site_id),
    site_conv(site_id),              -- nom simplifié
    description_conv('Carnet site')  -- description minimale
FROM src
WHERE site_verif(site_id)
ON CONFLICT DO NOTHING;


------------------------------
-- INSERT : Zone
------------------------------
WITH src AS (
    SELECT DISTINCT site_id, zone
    FROM "Staging".carnetPlant
    WHERE zone IS NOT NULL
)
INSERT INTO Zone(id, zone, description)
SELECT
    site_conv(site_id),
    zone_conv(zone),
    description_conv('Zone issue des carnets')
FROM src
WHERE site_verif(site_id)
  AND zone_verif(zone)
ON CONFLICT DO NOTHING;


------------------------------
-- INSERT : Placette
------------------------------
WITH src AS (
    SELECT DISTINCT site_id, zone, plac
    FROM "Staging".carnetPlant
    WHERE plac IS NOT NULL
)
INSERT INTO Placette(id, zone, plac)
SELECT
    site_conv(site_id),
    zone_conv(zone),
    placette_conv(plac)
FROM src
WHERE site_verif(site_id)
  AND zone_verif(zone)
  AND placette_verif(plac)
ON CONFLICT DO NOTHING;


------------------------------
-- INSERT : Parcelle
------------------------------
WITH src AS (
    SELECT DISTINCT site_id, zone, plac, parcelle
    FROM "Staging".carnetPlant
    WHERE parcelle IS NOT NULL
)
INSERT INTO Parcelle(id, zone, plac, parcelle)
SELECT
    site_conv(site_id),
    zone_conv(zone),
    placette_conv(plac),
    parcelle_conv(parcelle)
FROM src
WHERE site_verif(site_id)
  AND zone_verif(zone)
  AND placette_verif(plac)
  AND parcelle_verif(parcelle)
ON CONFLICT DO NOTHING;


------------------------------
-- INSERT : Plant
------------------------------
WITH src AS (
    SELECT DISTINCT site_id, zone, plac, id, date, note
    FROM "Staging".carnetPlant
    WHERE id IS NOT NULL
)
INSERT INTO Plant(s_id, zone, id, plac, date, note)
SELECT
    site_conv(site_id)       AS s_id,
    zone_conv(zone)          AS zone,
    plant_conv(id)           AS id,
    placette_conv(plac)      AS plac,
    dateeco_conv(date)       AS date,
    description_conv(note)   AS note
FROM src
WHERE site_verif(site_id)
  AND zone_verif(zone)
  AND plant_verif(id)
  AND placette_verif(plac)
  AND dateeco_verif(date)
  AND description_verif(note)
ON CONFLICT DO NOTHING;



/* ===========================================================
   2) CARNET PLACETTE
   =========================================================== */


------------------------------
-- Peuplement
------------------------------
WITH src AS (
  SELECT DISTINCT peup
  FROM "Staging".carnetPlacette
  WHERE peup IS NOT NULL
)
INSERT INTO Peuplement(peup, description)
SELECT
  peuplement_conv(peup),
  description_conv('Peuplement issu des carnets')
FROM src
WHERE peuplement_verif(peup)
ON CONFLICT DO NOTHING;


------------------------------
-- Placette_core
------------------------------
WITH src AS (
  SELECT DISTINCT site_id, zone, plac, peup, date
  FROM "Staging".carnetPlacette
)
INSERT INTO Placette_core(id, zone, plac, peup, date)
SELECT
  site_conv(site_id),
  zone_conv(zone),
  placette_conv(plac),
  peuplement_conv(peup),
  dateeco_conv(date)
FROM src
WHERE site_verif(site_id)
  AND zone_verif(zone)
  AND placette_verif(plac)
  AND peuplement_verif(peup)
  AND dateeco_verif(date)
ON CONFLICT DO NOTHING;

------------------------------
-- ARBRE (doit venir AVANT Placette_Dominant)
------------------------------
WITH src AS (
    SELECT DISTINCT site_id, arbre
    FROM "Staging".carnetPlacette
    WHERE arbre IS NOT NULL
)
INSERT INTO Arbre(arbre, description)
SELECT
    arbre_conv(arbre),
    description_conv(
        'Arbre issu des carnets — site ' || site_id
    )
FROM src
WHERE site_verif(site_id)
  AND arbre_verif(arbre)
ON CONFLICT DO NOTHING;



------------------------------
-- Placette_Dominant
------------------------------
WITH src AS (
  SELECT DISTINCT site_id, zone, plac, rang, arbre
  FROM "Staging".carnetPlacette
  WHERE arbre IS NOT NULL
    AND rang BETWEEN 1 AND 3
)
INSERT INTO Placette_Dominant(id, zone, plac, rang, arbre)
SELECT
  site_conv(site_id),
  zone_conv(zone),
  placette_conv(plac),
  rang,
  arbre_conv(arbre)
FROM src
WHERE site_verif(site_id)
  AND zone_verif(zone)
  AND placette_verif(plac)
  AND arbre_verif(arbre)
ON CONFLICT DO NOTHING;



------------------------------
-- Placette_Obstruction
------------------------------
WITH src AS (
  SELECT DISTINCT site_id, zone, plac,
         nature, hauteur,
         tcat_obstruction, tval_obstruction
  FROM "Staging".carnetPlacette
)
INSERT INTO Placette_Obstruction(id, zone, plac, nature, hauteur, tcat, tval)
SELECT
  site_conv(site_id),
  zone_conv(zone),
  placette_conv(plac),
  obstructionNature_conv(nature),
  hauteurObs_conv(hauteur),
  tcat_conv(tcat_obstruction),
  tval_obstruction
FROM src
WHERE site_verif(site_id)
  AND zone_verif(zone)
  AND placette_verif(plac)
  AND obstructionNature_verif(nature)
  AND hauteurObs_verif(hauteur)
  AND TCat_verif(tcat_obstruction)
  AND tval_obstruction BETWEEN 0 AND 100
ON CONFLICT DO NOTHING;



------------------------------
-- Placette_Couvert
------------------------------
WITH src AS (
  SELECT DISTINCT site_id, zone, plac,
         ctype, tcat_couvert, tval_couvert
  FROM "Staging".carnetPlacette
)
INSERT INTO Placette_Couvert(id, zone, plac, ctype, tcat, tval)
SELECT
  site_conv(site_id),
  zone_conv(zone),
  placette_conv(plac),
  couvertType_conv(ctype),
  tcat_conv(tcat_couvert),
  tval_couvert
FROM src
WHERE site_verif(site_id)
  AND zone_verif(zone)
  AND placette_verif(plac)
  AND CouvertType_verif(ctype)
  AND TCat_verif(tcat_couvert)
  AND tval_couvert BETWEEN 0 AND 100
ON CONFLICT DO NOTHING;



/* ===========================================================
   3) CARNET OBSERVATION
   =========================================================== */

------------------------------
-- OBS DIMENSION
------------------------------
WITH src AS (
  SELECT id, date, longueur, largeur, unite_id, note
  FROM "Staging".carnetObservation
  WHERE type_observation = 'dimension'
)
INSERT INTO ObsDimension(id, longueur, largeur, date, unite_id, note)
SELECT
  plant_conv(id),
  longueur,
  largeur,
  dateeco_conv(date),
  unite_id,
  description_conv(note)
FROM src
WHERE plant_verif(id)
  AND dateeco_verif(date)
  AND longueur BETWEEN 1 AND 999
  AND largeur BETWEEN 1 AND 999
  AND description_verif(note)
ON CONFLICT DO NOTHING;


------------------------------
-- OBS FLORAISON
------------------------------
WITH src AS (
  SELECT id, date, fleur, note
  FROM "Staging".carnetObservation
  WHERE type_observation = 'floraison'
)
INSERT INTO ObsFloraison(id, fleur, date, note)
SELECT
  plant_conv(id),
  fleur,
  dateeco_conv(date),
  description_conv(note)
FROM src
WHERE plant_verif(id)
  AND dateeco_verif(date)
  AND description_verif(note)
ON CONFLICT DO NOTHING;

------------------------------
-- ETAT (doit être inséré AVANT ObsEtat)
------------------------------
WITH src AS (
    SELECT DISTINCT etat
    FROM "Staging".carnetObservation
    WHERE type_observation = 'etat'
      AND etat IS NOT NULL
)
INSERT INTO Etat(etat, description)
SELECT
    etat_conv(etat),
    description_conv('État issu des carnets — ' || etat)
FROM src
WHERE etat_verif(etat)
ON CONFLICT DO NOTHING;



------------------------------
-- OBS ETAT
------------------------------
WITH src AS (
  SELECT id, date, etat, note
  FROM "Staging".carnetObservation
  WHERE type_observation = 'etat'
)
INSERT INTO ObsEtat(id, etat, date, note)
SELECT
  plant_conv(id),
  etat_conv(etat),
  dateeco_conv(date),
  description_conv(note)
FROM src
WHERE plant_verif(id)
  AND etat_verif(etat)
  AND dateeco_verif(date)
  AND description_verif(note)
ON CONFLICT DO NOTHING;

END;
$$;
