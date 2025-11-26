/*
////
-- =========================================================================== A
-- Meteo_req4.sql
-- ---------------------------------------------------------------------------
Activité : IFT187_2022-1
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 17
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.1.1a
Statut : en cours de développement
Résumé : Test minimaliste d’importation des carnets météorologiques.
-- =========================================================================== A
*/

/*
-- =========================================================================== B
////

Test minimaliste d’importation des carnets météorologiques dans la base de données.

////
-- =========================================================================== B
*/

--
-- Spécification du schéma
--
SET SCHEMA 'Herbivorie' ;

-- Vider les tables du contenu des précédents essais
--delete from ObsTemperature ;
--delete from ObsHumidite ;
--delete from ObsPrecipitations ;
--delete from ObsVents ;
--delete from ObsPression ;
--delete from "Staging".CarnetMeteo ;

-- Ajouter les données au carnet météorologique (remarquons la conversion implicite des données numériques!!!)
INSERT INTO "Staging".CarnetMeteo (
  zone,
  temp_min,
  temp_max,
  hum_min,
  hum_max,
  prec_tot,
  prec_nat,
  vent_min,
  vent_max,
  pres_min,
  pres_max,
  date,
  note
)
SELECT
  z.zone,

  -- Températures
  (
    -2 + (
      EXTRACT(DAY FROM (d - DATE '2023-05-01'))::int % 8
    )
  )::text AS temp_min,

  (
    5 + (
      EXTRACT(DAY FROM (d - DATE '2023-05-01'))::int % 10
    )
  )::text AS temp_max,

  -- Humidité
  (
    45 + (
      EXTRACT(DAY FROM (d - DATE '2023-05-01'))::int % 20
    )
  )::text AS hum_min,

  (
    65 + (
      EXTRACT(DAY FROM (d - DATE '2023-05-01'))::int % 20
    )
  )::text AS hum_max,

  -- Précipitations
  (EXTRACT(DOY FROM d)::int % 7)::text AS prec_tot,
  'P'::text AS prec_nat,

  -- Vents
  (
    2 + (EXTRACT(DOY FROM d)::int % 5)
  )::text AS vent_min,

  (
    10 + (EXTRACT(DOY FROM d)::int % 10)
  )::text AS vent_max,

  -- Pression
  (
    1000 + (EXTRACT(DOY FROM d)::int % 8)
  )::text AS pres_min,

  (
    1010 + (EXTRACT(DOY FROM d)::int % 8)
  )::text AS pres_max,

  d::text AS date,

  ('Météo générée – MI zone ' || z.zone)::text AS note

FROM generate_series(
        DATE '2023-05-01',
        DATE '2023-09-30',
        INTERVAL '1 day'
     ) AS g(d)
CROSS JOIN (VALUES ('MIA'), ('MIB')) AS z(zone);

-- Faire l’importation
call Meteo_ELT () ;

-- Fin

/*
-- =========================================================================== Z
////
.Contributeurs
* (LL01) luc.lavoie@usherbrooke.ca

.Tâches projetées
* 2022-01-23 LL01. Enrichier

.Tâches réalisées
* 2022-01-23 LL01. Création.

.Références
* {CoFELI}/Exemple/Herbivorie/pub/Herbivorie_EPP.pdf
////

.Adresse, droits d’auteur et copyright
  Groupe Metis
  Département d’informatique
  Faculté des sciences
  Université de Sherbrooke
  Sherbrooke (Québec)  J1K 2R1
  Canada
  http://info.usherbrooke.ca/llavoie/
  [CC-BY-NC-4.0 (http://creativecommons.org/licenses/by-nc/4.0)]

-- -----------------------------------------------------------------------------
-- fin de {CoFELI}/Exemple/Herbivorie/src/Meteo_req4.sql
-- =========================================================================== Z
*/
