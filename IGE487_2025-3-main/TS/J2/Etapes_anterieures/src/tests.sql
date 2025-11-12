-- Initialisation du schéma
-- CREATE SCHEMA "Herbivorie";
SET SCHEMA 'Herbivorie';

-- =============================
-- 1) Insertion des placettes
-- =============================
INSERT INTO Placette (plac)
SELECT DISTINCT placette_conv(placette1::text)
FROM megantic
WHERE placette_verif(placette1::text)
ON CONFLICT DO NOTHING;

-- =============================
-- 2) Insertion dans Placette_core
-- =============================
INSERT INTO Placette_core (plac, peup, date)
SELECT DISTINCT
    placette_conv(placette1::text),
    NULL::Peuplement_id,
    dateeco_conv("date"::text)
FROM megantic
WHERE placette_verif(placette1::text)
  AND dateeco_verif("date"::text)
ON CONFLICT DO NOTHING;

-- =============================
-- 3) Insertion dans Parcelle1
-- =============================
INSERT INTO Parcelle1 (plac, parcelle)
SELECT DISTINCT
    placette_conv(placette1::text),
    parcelle_conv(sous_parcelle::text)
FROM megantic
WHERE placette_verif(placette1::text)
  AND parcelle_verif(sous_parcelle::text)
ON CONFLICT DO NOTHING;

-- =============================
-- 4) Insertion des plants
-- =============================
INSERT INTO Plant (id, plac, date, note)
SELECT DISTINCT
    plant_conv(id::text),
    placette_conv(placette1::text),
    dateeco_conv("date"::text),
    CASE
      WHEN note IS NOT NULL AND description_verif(note::text)
        THEN description_conv(note::text)
      ELSE NULL
    END
FROM megantic
WHERE plant_verif(id::text)
  AND placette_verif(placette1::text)
  AND dateeco_verif("date"::text)
  --AND description_verif(note::text)
ON CONFLICT DO NOTHING;

-- =============================
-- 5) Insertion des observations de dimensions
-- =============================
INSERT INTO ObsDimension (id, longueur, largeur, date, note)
SELECT DISTINCT
    plant_conv(id::text),
    dim_conv(longueur::text),
    dim_conv(largeur::text),
    dateeco_conv("date"::text),
    CASE
      WHEN note IS NOT NULL AND description_verif(note::text)
        THEN description_conv(note::text)
      ELSE NULL
    END
FROM megantic
WHERE plant_verif(id::text)
  AND dim_verif(longueur::text)
  AND dim_verif(largeur::text)
  AND dateeco_verif("date"::text)
ON CONFLICT DO NOTHING;

-- =============================
-- 6) Insertion des observations de floraison
-- =============================
INSERT INTO ObsFloraison (id, fleur, date, note)
SELECT DISTINCT
    plant_conv(id::text),
    CASE
        WHEN lower(NULLIF(trim(fleur::text), '')) IN ('1','true','t')  THEN TRUE
        WHEN lower(NULLIF(trim(fleur::text), '')) IN ('0','false','f') THEN FALSE
    END,
    dateeco_conv("date"::text),
    CASE
      WHEN NULLIF(TRIM(note), '') IS NOT NULL AND description_verif(note::text)
        THEN description_conv(note::text)
      ELSE NULL
    END
FROM megantic
WHERE plant_verif(id::text)
  AND dateeco_verif("date"::text)
  AND lower(NULLIF(trim(fleur::text), '')) IN ('1','true','t','0','false','f')
ON CONFLICT DO NOTHING;


-- =============================
-- 7) Insertion des états (référentiel)
-- =============================
INSERT INTO Etat (etat, description)
SELECT DISTINCT
    etat_conv(upper(btrim(etat::text))),
    NULL::Description
FROM megantic
WHERE etat IS NOT NULL
  AND btrim(etat::text) <> ''
  AND etat_verif(upper(btrim(etat::text)))
ON CONFLICT DO NOTHING;


-- =============================
-- 8) Insertion des observations d’état
-- =============================
INSERT INTO ObsEtat (id, etat, date, note)
SELECT DISTINCT
  plant_conv(s.id_txt),
  etat_conv(s.etat_norme),
  dateeco_conv(s.date_txt),
  CASE
    WHEN s.note_txt IS NOT NULL AND btrim(s.note_txt) <> '' AND description_verif(s.note_txt)
      THEN description_conv(s.note_txt)
    ELSE NULL
  END
FROM (
  SELECT
    id::text        AS id_txt,
    upper(btrim(etat::text)) AS etat_norme,   -- normalisation une seule fois
    "date"::text    AS date_txt,
    note::text      AS note_txt
  FROM megantic
) AS s
WHERE plant_verif(s.id_txt)
  AND s.etat_norme IS NOT NULL AND s.etat_norme <> ''     -- écarte NULL/blancs
  AND etat_verif(s.etat_norme)                            -- test via le domaine
  AND dateeco_verif(s.date_txt)
  AND EXISTS (SELECT 1 FROM Plant p WHERE p.id = plant_conv(s.id_txt))
  AND EXISTS (SELECT 1 FROM Etat  e WHERE e.etat = etat_conv(s.etat_norme))
ON CONFLICT DO NOTHING;

