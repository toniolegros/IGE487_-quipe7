-- Initialisation du schéma
-- CREATE SCHEMA "Herbivorie";
SET SCHEMA 'Herbivorie';

INSERT INTO "Herbivorie".placette (plac)
SELECT placette_conv(placette1::text)
FROM megantic
WHERE placette_verif(placette1::text)
GROUP BY placette1;

INSERT INTO "Herbivorie".placette_core (plac, peup, date)
SELECT placette_conv(placette1::text),
FROM megantic
WHERE placette_verif(placette1::text)
GROUP BY placette1;

-- Insertion dans la table Plant
INSERT INTO Plant (id, plac, parcelle, date, note)
SELECT
  plant_conv(id) as id,
  placette_conv(placette) as plac,
  parcelle_conv(sous_parcelle) as parcelle,
  date_eco_conv(date) as date,
  description_conv(note) as note
FROM megantic
WHERE plant_verif(id)
  AND placette_verif(placette)
  AND parcelle_verif(sous_parcelle :: text);
  --AND date_eco_verif(date :: text)
 -- AND description_verif(note);

INSERT INTO plant1 (id,plac) select plant_conv(id), placette_conv(placette) from megantic where plant_verif(id) and placette_verif(placette);

DROP FUNCTION IF EXISTS placette_conv(text);
DROP FUNCTION IF EXISTS placette_conv("Herbivorie".placette_id);


INSERT INTO Parcelle1 (plac, parcelle) select placette_conv(plac),parcelle_conv(parcelle) from megantic where placette_verif(placette) and parcelle_verif(sous_parcelle);

SELECT * FROM "Herbivorie".placette_core WHERE plac = 'A1';
-- Insertion dans la table ObsDimension
INSERT INTO ObsDimension
SELECT
  Plant_id_CONV(id::varchar),
  Dim_mm_CONV(longueur::varchar),
  Dim_mm_CONV(largeur::varchar),
  Date_eco_CONV("date"::varchar),
  Description_CONV(note::varchar)
FROM megantic
WHERE Plant_id_CONF(id::varchar)
  AND Dim_mm_CONF(longueur::varchar)
  AND Dim_mm_CONF(largeur::varchar)
  AND Date_eco_CONF("date"::varchar)
  AND Description_CONF(note::varchar);

-- Insertion dans la table ObsFloraison
INSERT INTO ObsFloraison
SELECT
  Plant_id_CONV(id::varchar),
  Fleur_CONV(fleur::varchar),
  Date_eco_CONV("date"::varchar),
  Description_CONV(note::varchar)
FROM megantic
WHERE Plant_id_CONF(id::varchar)
  AND Fleur_CONF(fleur::varchar)
  AND Date_eco_CONF("date"::varchar)
  AND Description_CONF(note::varchar);

-- Insertion dans la table ObsEtat
INSERT INTO ObsEtat
SELECT
  Plant_id_CONV(id::varchar),
  Etat_id_CONV(etat::varchar),
  Date_eco_CONV("date"::varchar),
  Description_CONV(note::varchar)
FROM megantic
WHERE Plant_id_CONF(id::varchar)
  AND Etat_id_CONF(etat::varchar)
  AND Date_eco_CONF("date"::varchar)
  AND Description_CONF(note::varchar);