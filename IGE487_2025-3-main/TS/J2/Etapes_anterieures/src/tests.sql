-- Initialisation du schéma
-- CREATE SCHEMA "Herbivorie";
SET SCHEMA 'Herbivorie';

-- Données de référence (commentées pour usage ultérieur)
/*
INSERT INTO Arbre (arbre, description) VALUES ('AS98', 'ARBRE1'), ('AS89', 'ARBRE2');
INSERT INTO PEUPLEMENT (PEUP, DESCRIPTION) VALUES ('A3444','PEUP1'), ('A3445','PEUP2');
INSERT INTO PLACETTE_CORE (PLAC, PEUP, DATE) VALUES ('A1','A3444','2025-10-30'), ('A2','A3445','2025-10-31');
INSERT INTO PLACETTE_DOMINANT (PLAC, RANG, ARBRE) VALUES ('A1','2','AS98'), ('A2','1','AS89');
INSERT INTO TAUX (TCAT, TMIN, TMAX) VALUES ('A', 0, 25), ('B', 25, 50);
INSERT INTO placette_couvert (plac, ctype, tcat) VALUES ('A1', 'graminees', 'A'), ('A2', 'mousses', 'B');
INSERT INTO placette_obstruction (plac, nature, hauteur, tcat) VALUES ('A1', 'feuillu', '1m', 'A'), ('A2', 'coniferien', '2m', 'B');

SELECT p.plac, p.peup, p.date, pe.description
FROM placette_core AS p
JOIN peuplement AS pe ON p.peup = pe.peup;
*/

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

INSERT INTO plant1 (id,plac) select plant_conv(id), placette_conv(placette) from megantic where plant_verif(id)and placette_verif(placette);

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