-- =======================
-- BDD ELT Script (FINAL avec METEO)
-- =======================

SET SCHEMA 'Herbivorie_BDD';

-- =======================
-- DIMENSIONS
-- =======================

-- Dim_Date : à partir de toutes les dates utiles (eco + meteo)
INSERT INTO Dim_Date
SELECT DISTINCT
    d AS date_key,
    EXTRACT(YEAR FROM d)::int AS annee,
    EXTRACT(MONTH FROM d)::int AS mois,
    EXTRACT(DAY FROM d)::int AS jour,
    TO_CHAR(d, 'TMMonth') AS nom_mois,
    EXTRACT(QUARTER FROM d)::int AS trimestre
FROM (
    SELECT date FROM "Herbivorie".Placette_core
    UNION
    SELECT date FROM "Herbivorie".ObsTemperature
    UNION
    SELECT date FROM "Herbivorie".ObsHumidite
    UNION
    SELECT date FROM "Herbivorie".ObsVents
    UNION
    SELECT date FROM "Herbivorie".ObsPression
    UNION
    SELECT date FROM "Herbivorie".ObsPrecipitations
) AS X(d)
ON CONFLICT DO NOTHING;

-- Dim_Site
INSERT INTO Dim_Site
SELECT DISTINCT id, site, description
FROM "Herbivorie".Site
ON CONFLICT DO NOTHING;

-- Dim_Zone
INSERT INTO Dim_Zone
SELECT DISTINCT zone, id, description
FROM "Herbivorie".Zone
ON CONFLICT DO NOTHING;

-- Dim_Placette
INSERT INTO Dim_Placette
SELECT DISTINCT zone, plac
FROM "Herbivorie".Placette
ON CONFLICT DO NOTHING;

-- Dim_Parcelle
INSERT INTO Dim_Parcelle
SELECT DISTINCT zone, plac, parcelle
FROM "Herbivorie".Parcelle
ON CONFLICT DO NOTHING;

-- Dim_Peuplement
INSERT INTO Dim_Peuplement
SELECT DISTINCT peup, description
FROM "Herbivorie".Peuplement
ON CONFLICT DO NOTHING;

-- Dim_Arbre
INSERT INTO Dim_Arbre
SELECT DISTINCT arbre, description
FROM "Herbivorie".Arbre
ON CONFLICT DO NOTHING;

-- Dim_Plant
INSERT INTO Dim_Plant
SELECT DISTINCT id
FROM "Herbivorie".Plant
ON CONFLICT DO NOTHING;

-- Dim_Taux
INSERT INTO Dim_Taux
SELECT DISTINCT tcat::text, tmin, tmax
FROM "Herbivorie".Taux
ON CONFLICT DO NOTHING;

-- Dim_CouvertType
INSERT INTO Dim_CouvertType
SELECT DISTINCT ctype::text
FROM "Herbivorie".Placette_Couvert
ON CONFLICT DO NOTHING;

-- Dim_ObstructionNature
INSERT INTO Dim_ObstructionNature
SELECT DISTINCT nature::text
FROM "Herbivorie".Placette_Obstruction
ON CONFLICT DO NOTHING;

-- Dim_Hauteur
INSERT INTO Dim_Hauteur
SELECT DISTINCT hauteur::text
FROM "Herbivorie".Placette_Obstruction
ON CONFLICT DO NOTHING;

-- Dim_PrecipitationType
INSERT INTO Dim_PrecipitationType
SELECT DISTINCT code::text, libelle
FROM "Herbivorie".TypePrecipitations
ON CONFLICT DO NOTHING;


-- =======================
-- FAITS ECOLOGIQUES
-- =======================

-- Fait_Observation
INSERT INTO Fait_Observation
SELECT
    pc.date,
    pl.id,
    pc.peup,
    pa.parcelle,
    pl.plac,
    pl.zone,
    z.id AS site_id,
    pd.arbre,
    od.longueur,
    od.largeur,
    oe.etat,
    ofl.fleur
FROM "Herbivorie".Plant pl

JOIN "Herbivorie".Placette_core pc
  ON pc.plac = pl.plac
 AND pc.zone = pl.zone
 AND pc.date = pl.date

JOIN "Herbivorie".Parcelle pa
  ON pa.zone = pl.zone
 AND pa.plac = pl.plac

JOIN "Herbivorie".ObsDimension od
  ON od.id = pl.id
 AND od.date = pl.date

LEFT JOIN "Herbivorie".ObsEtat oe
  ON oe.id = pl.id
 AND oe.date = pl.date

LEFT JOIN "Herbivorie".ObsFloraison ofl
  ON ofl.id = pl.id
 AND ofl.date = pl.date

JOIN "Herbivorie".Zone z
  ON z.zone = pl.zone

LEFT JOIN "Herbivorie".Placette_Dominant pd
  ON pd.zone = pc.zone
 AND pd.plac = pc.plac

ON CONFLICT DO NOTHING;


-- Fait_Obstruction
INSERT INTO Fait_Obstruction
SELECT
    pc.date,
    o.zone,
    o.plac,
    o.nature::text,
    o.hauteur::text,
    o.tcat::text,
    o.tval
FROM "Herbivorie".Placette_Obstruction o
JOIN "Herbivorie".Placette_core pc
  ON o.zone = pc.zone AND o.plac = pc.plac
ON CONFLICT DO NOTHING;

-- Fait_Couvert
INSERT INTO Fait_Couvert
SELECT
    pc.date,
    c.zone,
    c.plac,
    c.ctype::text,
    c.tcat::text,
    c.tval
FROM "Herbivorie".Placette_Couvert c
JOIN "Herbivorie".Placette_core pc
  ON c.zone = pc.zone AND c.plac = pc.plac
ON CONFLICT DO NOTHING;


-- =======================
-- FAITS METEO
-- =======================

-- Temperature
INSERT INTO Fait_Temperature
SELECT
    t.date,
    t.zone,
    z.id AS site_id,
    t.temp_min,
    t.temp_max,
    t.note
FROM "Herbivorie".ObsTemperature t
JOIN "Herbivorie".Zone z ON z.zone = t.zone
ON CONFLICT DO NOTHING;

-- Humidité
INSERT INTO Fait_Humidite
SELECT
    h.date,
    h.zone,
    z.id AS site_id,
    h.hum_min,
    h.hum_max
FROM "Herbivorie".ObsHumidite h
JOIN "Herbivorie".Zone z ON z.zone = h.zone
ON CONFLICT DO NOTHING;

-- Vents
INSERT INTO Fait_Vents
SELECT
    v.date,
    v.zone,
    z.id AS site_id,
    v.vent_min,
    v.vent_max
FROM "Herbivorie".ObsVents v
JOIN "Herbivorie".Zone z ON z.zone = v.zone
ON CONFLICT DO NOTHING;

-- Pression
INSERT INTO Fait_Pression
SELECT
    p.date,
    p.zone,
    z.id AS site_id,
    p.pres_min,
    p.pres_max
FROM "Herbivorie".ObsPression p
JOIN "Herbivorie".Zone z ON z.zone = p.zone
ON CONFLICT DO NOTHING;

-- Précipitations
INSERT INTO Fait_Precipitations
SELECT
    pr.date,
    pr.zone,
    z.id AS site_id,
    pr.prec_tot,
    pr.prec_nat::text
FROM "Herbivorie".ObsPrecipitations pr
JOIN "Herbivorie".Zone z ON z.zone = pr.zone
ON CONFLICT DO NOTHING;
