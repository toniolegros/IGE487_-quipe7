/*
////
-- =========================================================================== A
-- Meteo_elt.sql
-- ---------------------------------------------------------------------------
Activité : IFT187_2022-1
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 17
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.1.1a
Statut : en cours de développement
Résumé : Importation des données d'observations météorologiques.
-- =========================================================================== A
*/

/*
-- =========================================================================== B
////

Création des types, tables et routines requises pour les tâches d’importation
(vérification, conversion et transformation) requises par le mécanisme d’ELT.

Utilisation de la stratégie B et de la tactique 1 décrites dans le document
Herbivorie_ELT_SCL.adoc

Le présent solutionnaire comprend plus de types de mesures (et de mesures)
que ce qui était requis au TP4.

Par contre, le jeu de données esquissé est insuffisant par rapport aux exigences
du TP4.

////
-- =========================================================================== B
*/

--
-- Spécification du schéma
--
SET SCHEMA 'Herbivorie' ;

--
-- == Ajustement du domaine Date_eco
--
-- Afin d’offrir une meilleure validation des données, nous modifions la
-- définition de Date_eco afin de la réduire à une portée plus réaliste.
-- NOTE : ceci n'était pas demandé dans le TP4.
--
alter domain Date_eco drop constraint Date_eco_check ;
alter domain Date_eco add constraint Date_eco_check
  check ((extract(year from value) between 2016 and 2030));

--
-- == Vérification et conversion de Date_eco
--

-- Vérification
create or replace function Date_eco_verif (argument text)
returns boolean -- vrai SSI valide
language sql as
$$
with
  syntaxe as (
    select argument,
      argument similar to '[0-9]{4}-[0-9]{2}-[0-9]{2}' as syntaxe_ok,
      split_part(argument, '-', 1) as annee_p,
      split_part(argument, '-', 2) as mois_p,
      split_part(argument, '-', 3) as jour_p
    ),
  evaluation as (
    select *,
      case when syntaxe_ok then annee_p::int else 1900 end annee,
      case when syntaxe_ok then mois_p::int else 1 end mois,
      case when syntaxe_ok then jour_p::int else 1 end jour
    from syntaxe),
  verification as (
    select *,
      case
      when mois in (1,3,5,7,8,10,12) then jour between 1 and 31
      when mois in (4,6,9,11) then jour between 1 and 30
      when mois = 2 then
        case when annee/4*4 = annee and (annee/100*100 <> annee or annee/400*400 = annee)
        then jour between 1 and 29
        else jour between 1 and 28 end
      else false end as valide
    from evaluation)
select
  syntaxe_ok and valide and (annee between 2016 and 2030) as resultat
from verification
$$;

-- Petit test Date_eco_verif
with
  A (d) as (values ('2021-12-03'), ('2021-02-29'), ('0000-12-31'), ('2015-12-31'), ('2031-01-01'))
select
  d as date , Date_eco_verif(d) as valide
from A ;

-- Conversion
CREATE OR REPLACE FUNCTION Date_eco_conv (argument text)
RETURNS Date_eco
LANGUAGE sql AS
$$
SELECT CASE
         WHEN Date_eco_verif(argument)
           THEN to_date(argument, 'yyyy-mm-dd')::Date_eco
         ELSE NULL::Date_eco
       END;
$$;


--
-- == Vérification d'entiers compris entre dans un intervalle [min..max] compris dans [-999999..999999]
--

create or replace function Entier_verif (argument text, min integer, max integer)
returns boolean -- vrai SSI valide
language sql as
$$
select
  case
    when argument similar to '(-)?[0-9]{1,6}' then
      cast (argument as integer) between min and max
    else
      false
  end
$$;

--
-- == Vérification et conversion de valeurs de type Temperature
--

-- Verification
create or replace function Temperature_verif (argument text)
returns boolean -- vrai SSI valide
language sql as
$$
select Entier_verif(argument, -50, 50) ;
$$;

-- Conversion
CREATE OR REPLACE FUNCTION Temperature_conv (argument text)
RETURNS Temperature
LANGUAGE sql AS
$$
SELECT CASE
         WHEN Temperature_verif(argument)
           THEN CAST(argument AS integer)::Temperature
         ELSE NULL::Temperature
       END;
$$;




--
-- == Vérification et conversion de valeurs de type Humidite
--

-- Verification
create or replace function Humidite_verif (argument text)
returns boolean -- vrai SSI valide
language sql as
$$
select Entier_verif(argument, 0, 100) ;
$$;

-- Conversion
create or replace function Humidite_conv (argument text)
returns Humidite
language sql as
$$
    SELECT CASE
         WHEN Humidite_verif(argument)
           THEN CAST(argument AS integer)::humidite
         ELSE NULL::humidite
       END;
$$;


--
-- == Vérification et conversion de valeurs de type Vitesse
--

-- Verification
create or replace function Vitesse_verif (argument text)
returns boolean -- vrai SSI valide
language sql as
$$
select Entier_verif(argument, 0, 300) ;
$$;

-- Conversion
create or replace function Vitesse_conv (argument text)
returns Vitesse
language sql as
$$
    SELECT CASE
         WHEN Vitesse_verif(argument)
           THEN CAST(argument AS integer)::vitesse
         ELSE NULL::vitesse
       END;
$$;

--
-- == Vérification et conversion de valeurs de type Pression
--

-- Verification
create or replace function Pression_verif (argument text)
returns boolean -- vrai SSI valide
language sql as
$$
select Entier_verif(argument, 900, 1100) ;
$$;

-- Conversion
create or replace function Pression_conv (argument text)
returns Pression
language sql as
$$
    SELECT CASE
         WHEN Pression_verif(argument)
           THEN CAST(argument AS integer)::pression
         ELSE NULL::pression
       END;
$$;

--
-- == Vérification et conversion de valeurs de type HNP
--

-- Verification
create or replace function HNP_verif (argument text)
returns boolean -- vrai SSI valide
language sql as
$$
select Entier_verif(argument, 0, 500) ;
$$;

-- Conversion
create or replace function HNP_conv (argument text)
returns HNP
language sql as
$$
    SELECT CASE
         WHEN HNP_verif(argument)
           THEN CAST(argument AS integer)::hnp
         ELSE NULL::hnp
       END;
$$;

--
-- == Vérification et conversion de valeurs de type Code_P
--

-- Verification
create or replace function Code_P_verif (argument text)
returns boolean -- vrai SSI valide
language sql as
$$
select argument in (select code from TypePrecipitations)
$$;

-- Conversion
CREATE OR REPLACE FUNCTION Code_p_conv(argument text)
RETURNS Code_P
LANGUAGE sql AS
$$
SELECT CASE
         WHEN Code_p_verif(argument)
           THEN argument::Code_P
         ELSE NULL::Code_P
       END;
$$;

--
-- == Définition de la procédure d’importation
--

CREATE OR REPLACE PROCEDURE Meteo_ELT ()
LANGUAGE plpgsql AS
$$
BEGIN
  -------------------------------------------------------------------
  -- 1) Créer les SITES manquants à partir des zones du CarnetMeteo
  -------------------------------------------------------------------
  INSERT INTO "Herbivorie".Site (id, site, description)
  SELECT DISTINCT
         (LEFT(zone_conv(zone), 2) || '00')::Site_id AS id,
         'Site ' || LEFT(zone_conv(zone), 2)         AS site,
         'Site importé automatiquement depuis CarnetMeteo' AS description
  FROM "Staging".CarnetMeteo
  WHERE zone_verif(zone)
  ON CONFLICT (id) DO NOTHING;

  -------------------------------------------------------------------
  -- 2) Créer les ZONES manquantes
  -------------------------------------------------------------------
  INSERT INTO "Herbivorie".Zone (id, zone, description)
  SELECT DISTINCT
         (LEFT(zone_conv(zone), 2) || '00')::Site_id AS id,
         zone_conv(zone)                             AS zone,
         'Zone importée automatiquement (ELT)'       AS description
  FROM "Staging".CarnetMeteo
  WHERE zone_verif(zone)
  ON CONFLICT (zone) DO NOTHING;


  -------------------------------------------------------------------
  -- 3) ObsTemperature + Rejets
  -------------------------------------------------------------------
  WITH src AS (
    SELECT
      c.*,
      to_jsonb(c) AS ligne_raw,
      -- Vérifs brutes
      COALESCE(zone_verif(c.zone), false)              AS ok_zone,
      COALESCE(date_eco_verif(c.date), false)          AS ok_date,
      COALESCE(Temperature_verif(c.temp_min), false)   AS ok_temp_min,
      COALESCE(Temperature_verif(c.temp_max), false)   AS ok_temp_max,
      -- Conversions non NULL
      COALESCE(zone_conv(c.zone) IS NOT NULL, false)             AS ok_zone_conv,
      COALESCE(date_eco_conv(c.date) IS NOT NULL, false)         AS ok_date_conv,
      COALESCE(Temperature_conv(c.temp_min) IS NOT NULL, false)  AS ok_temp_min_conv,
      COALESCE(Temperature_conv(c.temp_max) IS NOT NULL, false)  AS ok_temp_max_conv,
      -- FK sur Zone
      EXISTS (
        SELECT 1 FROM "Herbivorie".Zone z
        WHERE z.zone = zone_conv(c.zone)
      ) AS ok_fk_zone
    FROM "Staging".CarnetMeteo c
    WHERE c.temp_min IS NOT NULL OR c.temp_max IS NOT NULL
  )

  INSERT INTO "Herbivorie".Rejets (flux, motif, details, ligne, attributs)
  SELECT
    'METEO_TEMPERATURE_BASE' AS flux,
    COALESCE(
      concat_ws(
        ', ',
        CASE WHEN NOT ok_zone          THEN 'Zone invalide' END,
        CASE WHEN NOT ok_date          THEN 'Date invalide' END,
        CASE WHEN NOT ok_temp_min      THEN 'Température minimale invalide' END,
        CASE WHEN NOT ok_temp_max      THEN 'Température maximale invalide' END,
        CASE WHEN NOT ok_zone_conv     THEN 'Conversion zone NULL' END,
        CASE WHEN NOT ok_date_conv     THEN 'Conversion date NULL' END,
        CASE WHEN NOT ok_temp_min_conv THEN 'Conversion temp_min NULL' END,
        CASE WHEN NOT ok_temp_max_conv THEN 'Conversion temp_max NULL' END,
        CASE WHEN NOT ok_fk_zone       THEN 'Zone inexistante (FK)' END
      ),
      'Rejet sans motif identifié'
    ) AS motif,
    'Meteo_ELT - METEO_TEMPERATURE_BASE' AS details,
    ligne_raw AS ligne,
    concat_ws(
      ', ',
      CASE WHEN NOT ok_zone     THEN format('zone=%s', zone) END,
      CASE WHEN NOT ok_date     THEN format('date=%s', date) END,
      CASE WHEN NOT ok_temp_min THEN format('temp_min=%s', temp_min) END,
      CASE WHEN NOT ok_temp_max THEN format('temp_max=%s', temp_max) END
    ) AS attributs
  FROM src
  WHERE NOT (
    ok_zone AND ok_date AND ok_temp_min AND ok_temp_max
    AND ok_zone_conv AND ok_date_conv AND ok_temp_min_conv AND ok_temp_max_conv
    AND ok_fk_zone
  );


  INSERT INTO "Herbivorie".ObsTemperature (zone, date, temp_min, temp_max, note)
  SELECT
    zone_conv(zone)              AS zone,
    date_eco_conv(date)          AS date,
    Temperature_conv(temp_min)   AS temp_min,
    Temperature_conv(temp_max)   AS temp_max,
    COALESCE(note, '')           AS note
  from "Staging".CarnetMeteo where zone_verif(zone) and date_eco_verif(date) and Temperature_verif(temp_min) and Temperature_verif(temp_max) ON CONFLICT (zone, date) DO NOTHING;


  -------------------------------------------------------------------
  -- 4) ObsHumidite + Rejets
  -------------------------------------------------------------------
  WITH src AS (
    SELECT
      c.*,
      to_jsonb(c) AS ligne_raw,
      COALESCE(zone_verif(c.zone), false)           AS ok_zone,
      COALESCE(date_eco_verif(c.date), false)       AS ok_date,
      COALESCE(Humidite_verif(c.hum_min), false)    AS ok_hum_min,
      COALESCE(Humidite_verif(c.hum_max), false)    AS ok_hum_max,
      COALESCE(zone_conv(c.zone) IS NOT NULL, false)         AS ok_zone_conv,
      COALESCE(date_eco_conv(c.date) IS NOT NULL, false)     AS ok_date_conv,
      COALESCE(Humidite_conv(c.hum_min) IS NOT NULL, false)  AS ok_hum_min_conv,
      COALESCE(Humidite_conv(c.hum_max) IS NOT NULL, false)  AS ok_hum_max_conv,
      EXISTS (
        SELECT 1 FROM "Herbivorie".Zone z
        WHERE z.zone = zone_conv(c.zone)
      ) AS ok_fk_zone
    FROM "Staging".CarnetMeteo c
    WHERE c.hum_min IS NOT NULL OR c.hum_max IS NOT NULL
  )
  INSERT INTO "Herbivorie".Rejets (flux, motif, details, ligne, attributs)
  SELECT
    'METEO_HUMIDITE_BASE' AS flux,
    COALESCE(
      concat_ws(
        ', ',
        CASE WHEN NOT ok_zone        THEN 'Zone invalide' END,
        CASE WHEN NOT ok_date        THEN 'Date invalide' END,
        CASE WHEN NOT ok_hum_min     THEN 'Humidité minimale invalide' END,
        CASE WHEN NOT ok_hum_max     THEN 'Humidité maximale invalide' END,
        CASE WHEN NOT ok_zone_conv   THEN 'Conversion zone NULL' END,
        CASE WHEN NOT ok_date_conv   THEN 'Conversion date NULL' END,
        CASE WHEN NOT ok_hum_min_conv THEN 'Conversion hum_min NULL' END,
        CASE WHEN NOT ok_hum_max_conv THEN 'Conversion hum_max NULL' END,
        CASE WHEN NOT ok_fk_zone     THEN 'Zone inexistante (FK)' END
      ),
      'Rejet sans motif identifié'
    ) AS motif,
    'Meteo_ELT - METEO_HUMIDITE_BASE' AS details,
    ligne_raw AS ligne,
    concat_ws(
      ', ',
      CASE WHEN NOT ok_zone     THEN format('zone=%s', zone) END,
      CASE WHEN NOT ok_date     THEN format('date=%s', date) END,
      CASE WHEN NOT ok_hum_min  THEN format('hum_min=%s', hum_min) END,
      CASE WHEN NOT ok_hum_max  THEN format('hum_max=%s', hum_max) END
    ) AS attributs
  FROM src
  WHERE NOT (
    ok_zone AND ok_date AND ok_hum_min AND ok_hum_max
    AND ok_zone_conv AND ok_date_conv AND ok_hum_min_conv AND ok_hum_max_conv
    AND ok_fk_zone
  );

  INSERT INTO "Herbivorie".ObsHumidite (zone, date, hum_min, hum_max)
  SELECT
    zone_conv(zone)             AS zone,
    date_eco_conv(date)         AS date,
    Humidite_conv(hum_min)      AS hum_min,
    Humidite_conv(hum_max)      AS hum_max
  from "Staging".CarnetMeteo where zone_verif(zone) and date_eco_verif(date) and Humidite_verif(hum_min) and Humidite_verif(hum_max) ON CONFLICT (zone, date) DO NOTHING;


  -------------------------------------------------------------------
  -- 5) ObsPrecipitations + Rejets
  -------------------------------------------------------------------
  WITH src AS (
    SELECT
      c.*,
      to_jsonb(c) AS ligne_raw,
      COALESCE(zone_verif(c.zone), false)        AS ok_zone,
      COALESCE(date_eco_verif(c.date), false)    AS ok_date,
      COALESCE(HNP_verif(c.prec_tot), false)     AS ok_prec_tot,
      COALESCE(Code_p_verif(c.prec_nat), false)  AS ok_prec_nat,
      COALESCE(zone_conv(c.zone) IS NOT NULL, false)    AS ok_zone_conv,
      COALESCE(date_eco_conv(c.date) IS NOT NULL, false) AS ok_date_conv,
      COALESCE(HNP_conv(c.prec_tot) IS NOT NULL, false) AS ok_prec_tot_conv,
      COALESCE(Code_p_conv(c.prec_nat) IS NOT NULL, false) AS ok_prec_nat_conv,
      EXISTS (
        SELECT 1 FROM "Herbivorie".Zone z
        WHERE z.zone = zone_conv(c.zone)
      ) AS ok_fk_zone
    FROM "Staging".CarnetMeteo c
    WHERE c.prec_tot IS NOT NULL OR c.prec_nat IS NOT NULL
  )
  INSERT INTO "Herbivorie".Rejets (flux, motif, details, ligne, attributs)
  SELECT
    'METEO_PRECIPITATIONS_BASE' AS flux,
    COALESCE(
      concat_ws(
        ', ',
        CASE WHEN NOT ok_zone          THEN 'Zone invalide' END,
        CASE WHEN NOT ok_date          THEN 'Date invalide' END,
        CASE WHEN NOT ok_prec_tot      THEN 'Précipitations totales invalides' END,
        CASE WHEN NOT ok_prec_nat      THEN 'Nature de précipitations invalide' END,
        CASE WHEN NOT ok_zone_conv     THEN 'Conversion zone NULL' END,
        CASE WHEN NOT ok_date_conv     THEN 'Conversion date NULL' END,
        CASE WHEN NOT ok_prec_tot_conv THEN 'Conversion prec_tot NULL' END,
        CASE WHEN NOT ok_prec_nat_conv THEN 'Conversion prec_nat NULL' END,
        CASE WHEN NOT ok_fk_zone       THEN 'Zone inexistante (FK)' END
      ),
      'Rejet sans motif identifié'
    ) AS motif,
    'Meteo_ELT - METEO_PRECIPITATIONS_BASE' AS details,
    ligne_raw AS ligne,
    concat_ws(
      ', ',
      CASE WHEN NOT ok_zone      THEN format('zone=%s', zone) END,
      CASE WHEN NOT ok_date      THEN format('date=%s', date) END,
      CASE WHEN NOT ok_prec_tot  THEN format('prec_tot=%s', prec_tot) END,
      CASE WHEN NOT ok_prec_nat  THEN format('prec_nat=%s', prec_nat) END
    ) AS attributs
  FROM src
  WHERE NOT (
    ok_zone AND ok_date AND ok_prec_tot AND ok_prec_nat
    AND ok_zone_conv AND ok_date_conv AND ok_prec_tot_conv AND ok_prec_nat_conv
    AND ok_fk_zone
  );

  INSERT INTO "Herbivorie".ObsPrecipitations (zone, date, prec_tot, prec_nat)
  SELECT
    zone_conv(zone)           AS zone,
    date_eco_conv(date)       AS date,
    HNP_conv(prec_tot)        AS prec_tot,
    Code_p_conv(prec_nat)     AS prec_nat
from "Staging".CarnetMeteo where zone_verif(zone) and date_eco_verif(date) and HNP_verif(prec_tot) and Code_p_verif(prec_nat) ON CONFLICT (zone, date, prec_nat) DO NOTHING;


  -------------------------------------------------------------------
  -- 6) ObsVents + Rejets
  -------------------------------------------------------------------
  WITH src AS (
    SELECT
      c.*,
      to_jsonb(c) AS ligne_raw,
      COALESCE(zone_verif(c.zone), false)          AS ok_zone,
      COALESCE(date_eco_verif(c.date), false)      AS ok_date,
      COALESCE(Vitesse_verif(c.vent_min), false)   AS ok_vent_min,
      COALESCE(Vitesse_verif(c.vent_max), false)   AS ok_vent_max,
      COALESCE(zone_conv(c.zone) IS NOT NULL, false)      AS ok_zone_conv,
      COALESCE(date_eco_conv(c.date) IS NOT NULL, false)  AS ok_date_conv,
      COALESCE(Vitesse_conv(c.vent_min) IS NOT NULL, false) AS ok_vent_min_conv,
      COALESCE(Vitesse_conv(c.vent_max) IS NOT NULL, false) AS ok_vent_max_conv,
      EXISTS (
        SELECT 1 FROM "Herbivorie".Zone z
        WHERE z.zone = zone_conv(c.zone)
      ) AS ok_fk_zone
    FROM "Staging".CarnetMeteo c
    WHERE c.vent_min IS NOT NULL OR c.vent_max IS NOT NULL
  )
  INSERT INTO "Herbivorie".Rejets (flux, motif, details, ligne, attributs)
  SELECT
    'METEO_VENTS_BASE' AS flux,
    COALESCE(
      concat_ws(
        ', ',
        CASE WHEN NOT ok_zone         THEN 'Zone invalide' END,
        CASE WHEN NOT ok_date         THEN 'Date invalide' END,
        CASE WHEN NOT ok_vent_min     THEN 'Vent minimal invalide' END,
        CASE WHEN NOT ok_vent_max     THEN 'Vent maximal invalide' END,
        CASE WHEN NOT ok_zone_conv    THEN 'Conversion zone NULL' END,
        CASE WHEN NOT ok_date_conv    THEN 'Conversion date NULL' END,
        CASE WHEN NOT ok_vent_min_conv THEN 'Conversion vent_min NULL' END,
        CASE WHEN NOT ok_vent_max_conv THEN 'Conversion vent_max NULL' END,
        CASE WHEN NOT ok_fk_zone      THEN 'Zone inexistante (FK)' END
      ),
      'Rejet sans motif identifié'
    ) AS motif,
    'Meteo_ELT - METEO_VENTS_BASE' AS details,
    ligne_raw AS ligne,
    concat_ws(
      ', ',
      CASE WHEN NOT ok_zone     THEN format('zone=%s', zone) END,
      CASE WHEN NOT ok_date     THEN format('date=%s', date) END,
      CASE WHEN NOT ok_vent_min THEN format('vent_min=%s', vent_min) END,
      CASE WHEN NOT ok_vent_max THEN format('vent_max=%s', vent_max) END
    ) AS attributs
  FROM src
  WHERE NOT (
    ok_zone AND ok_date AND ok_vent_min AND ok_vent_max
    AND ok_zone_conv AND ok_date_conv AND ok_vent_min_conv AND ok_vent_max_conv
    AND ok_fk_zone
  );

  INSERT INTO "Herbivorie".ObsVents (zone, date, vent_min, vent_max)
  SELECT
    zone_conv(zone)         AS zone,
    date_eco_conv(date)     AS date,
    Vitesse_conv(vent_min)  AS vent_min,
    Vitesse_conv(vent_max)  AS vent_max
  from "Staging".CarnetMeteo where zone_verif(zone) and date_eco_verif(date) and Vitesse_verif(vent_min) and Vitesse_verif(vent_max) ON CONFLICT (zone, date) DO NOTHING;


  -------------------------------------------------------------------
  -- 7) ObsPression + Rejets
  -------------------------------------------------------------------
  WITH src AS (
    SELECT
      c.*,
      to_jsonb(c) AS ligne_raw,
      COALESCE(zone_verif(c.zone), false)          AS ok_zone,
      COALESCE(date_eco_verif(c.date), false)      AS ok_date,
      COALESCE(Pression_verif(c.pres_min), false)  AS ok_pres_min,
      COALESCE(Pression_verif(c.pres_max), false)  AS ok_pres_max,
      COALESCE(zone_conv(c.zone) IS NOT NULL, false)          AS ok_zone_conv,
      COALESCE(date_eco_conv(c.date) IS NOT NULL, false)      AS ok_date_conv,
      COALESCE(Pression_conv(c.pres_min) IS NOT NULL, false)  AS ok_pres_min_conv,
      COALESCE(Pression_conv(c.pres_max) IS NOT NULL, false)  AS ok_pres_max_conv,
      EXISTS (
        SELECT 1 FROM "Herbivorie".Zone z
        WHERE z.zone = zone_conv(c.zone)
      ) AS ok_fk_zone,
      (Pression_conv(c.pres_min) <= Pression_conv(c.pres_max)) AS ok_intervalle
    FROM "Staging".CarnetMeteo c
    WHERE c.pres_min IS NOT NULL OR c.pres_max IS NOT NULL
  )
  INSERT INTO "Herbivorie".Rejets (flux, motif, details, ligne, attributs)
  SELECT
    'METEO_PRESSION_BASE' AS flux,
    COALESCE(
      concat_ws(
        ', ',
        CASE WHEN NOT ok_zone          THEN 'Zone invalide' END,
        CASE WHEN NOT ok_date          THEN 'Date invalide' END,
        CASE WHEN NOT ok_pres_min      THEN 'Pression min invalide' END,
        CASE WHEN NOT ok_pres_max      THEN 'Pression max invalide' END,
        CASE WHEN NOT ok_zone_conv     THEN 'Conversion zone NULL' END,
        CASE WHEN NOT ok_date_conv     THEN 'Conversion date NULL' END,
        CASE WHEN NOT ok_pres_min_conv THEN 'Conversion pres_min NULL' END,
        CASE WHEN NOT ok_pres_max_conv THEN 'Conversion pres_max NULL' END,
        CASE WHEN NOT ok_intervalle    THEN 'pres_min > pres_max' END,
        CASE WHEN NOT ok_fk_zone       THEN 'Zone inexistante (FK)' END
      ),
      'Rejet sans motif identifié'
    ) AS motif,
    'Meteo_ELT - METEO_PRESSION_BASE' AS details,
    ligne_raw AS ligne,
    concat_ws(
      ', ',
      CASE WHEN NOT ok_zone     THEN format('zone=%s', zone) END,
      CASE WHEN NOT ok_date     THEN format('date=%s', date) END,
      CASE WHEN NOT ok_pres_min THEN format('pres_min=%s', pres_min) END,
      CASE WHEN NOT ok_pres_max THEN format('pres_max=%s', pres_max) END
    ) AS attributs
  FROM src
  WHERE NOT (
    ok_zone AND ok_date AND ok_pres_min AND ok_pres_max
    AND ok_zone_conv AND ok_date_conv AND ok_pres_min_conv AND ok_pres_max_conv
    AND ok_intervalle
    AND ok_fk_zone
  );

  INSERT INTO "Herbivorie".ObsPression (zone, date, pres_min, pres_max)
  with T as ( select
    zone_conv(zone)          AS zone,
    date_eco_conv(date)      AS date,
    Pression_conv(pres_min)  AS pres_min,
    Pression_conv(pres_max)  AS pres_max
  from "Staging".CarnetMeteo
  where zone_verif(zone) and date_eco_verif(date) and Pression_verif(pres_min) and Pression_verif(pres_max))
   select * from T
   where pres_min <= pres_max
   ON CONFLICT (zone, date) DO NOTHING;

END;
$$;

/*
-- =========================================================================== Z
////
.Contributeurs
* (LL01) luc.lavoie@usherbrooke.ca

.Tâches projetées
* 2022-01-23 LL01. Refactoriser les mesures.

.Tâches réalisées
* 2022-01-23 LL01. Épurer le schéma.
* 2017-09-17 LL01. Création.

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
-- fin de {CoFELI}/Exemple/Herbivorie/Carnetmeteo/Meteo_elt.sql
-- =========================================================================== Z
*/
