----------------------------------------------------------------------
-- CRÉATION DU SCHÉMA STAGING
----------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS "ige487_63";


----------------------------------------------------------------------
-- 1. site.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_63".carnetplacette63 (
    arbre_id text,
couverture_type text,
ctid text,
date_placette text,
hauteur integer,
obstruction_type text,
peuplement_id text,
placette_numero integer,
rang_arbre text,
site_id text,
taux_couverture text,
taux_obstruction integer,
zone_id text
);

----------------------------------------------------------------------
-- 2. zone.csv
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_63".carnetplant63 (
    ctid tid,
date_debut_emplacement text,
date_fin_emplacement text,
date_identification text,
date_observation text,
est_actuel text,
est_fruit text,
etat_id text,
largeur text,
longueur text,
note_emplacement text,
note_observation text,
note_plant text,
parcelle integer,
placette_numero integer,
plant_id integer,
site_id text,
zone_id text
);


----------------------------------------------------------------------
-- 3. arbre.csv
-- ⚠ Ton arbre.csv ressemble en réalité à un doublon de site.csv
-- Mais je crée la table quand même pour respecter ton fichier
----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "ige487_63".carnet_meteo63 (
    ctid tid,
date text,
hum_max  integer,
hum_min integer,
note text,
prec_nat text,
prec_tot text,
pres_max text,
pres_min text,
site_id text,
temp_max integer,
temp_min integer,
vent_max text,
vent_min integer,
zone_id text
);