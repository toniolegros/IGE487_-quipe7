-- Initialisation du schéma
-- CREATE SCHEMA "Herbivorie";
SET SCHEMA 'Herbivorie';


create or replace procedure Megantic_ELT ()
language plpgsql as
$$
begin

-- ==================
--  SITE_BASE : INSERT
-- ==================
WITH src AS (
  SELECT DISTINCT
    site_id,
    site_nom,
    description_site
  FROM "Staging".megantic
  WHERE site_id IS NOT NULL
)
INSERT INTO Site (id, site, description)
SELECT
  site_conv(s.site_id),          -- vers le domaine Site_id
  description_conv(s.site_nom),  -- nom lisible
  description_conv(s.description_site)
FROM src s
WHERE
      site_verif(s.site_id)
  AND description_verif(s.site_nom)
  AND description_verif(s.description_site)
  AND site_conv(s.site_id) IS NOT NULL
  AND description_conv(s.site_nom) IS NOT NULL
  AND description_conv(s.description_site) IS NOT NULL
ON CONFLICT DO NOTHING;

-- SITE_BASE : journalisation des rejets
WITH src AS (
  SELECT
    m.*,
    to_jsonb(m) AS ligne_raw,

    -- Vérifs brutes
    COALESCE(site_verif(m.site_id), false)                 AS ok_site_id,
    COALESCE(description_verif(m.site_nom), false)         AS ok_site_nom,
    COALESCE(description_verif(m.description_site), false) AS ok_desc,

    -- Conversions sécurisées (appelées seulement si verif = true)
    CASE
      WHEN site_verif(m.site_id)
        THEN COALESCE(site_conv(m.site_id) IS NOT NULL, false)
      ELSE false
    END AS ok_site_id_conv,

    CASE
      WHEN description_verif(m.site_nom)
        THEN COALESCE(description_conv(m.site_nom) IS NOT NULL, false)
      ELSE false
    END AS ok_site_nom_conv,

    CASE
      WHEN description_verif(m.description_site)
        THEN COALESCE(description_conv(m.description_site) IS NOT NULL, false)
      ELSE false
    END AS ok_desc_conv

  FROM "Staging".megantic m
  WHERE m.site_id IS NOT NULL
)
INSERT INTO Rejets (flux, motif, details, ligne, attributs)
SELECT
  'SITE_BASE' AS flux,
  COALESCE(
    concat_ws(
      ', ',
      CASE WHEN NOT ok_site_id      THEN 'Identifiant de site invalide' END,
      CASE WHEN NOT ok_site_nom     THEN 'Nom de site invalide' END,
      CASE WHEN NOT ok_desc         THEN 'Description de site invalide' END,
      CASE WHEN NOT ok_site_id_conv THEN 'Conversion site_id NULL' END,
      CASE WHEN NOT ok_site_nom_conv THEN 'Conversion nom de site NULL' END,
      CASE WHEN NOT ok_desc_conv    THEN 'Conversion description site NULL' END
    ),
    'Rejet sans motif identifié'
  ) AS motif,
  'Megantic_ELT - SITE_BASE' AS details,
    ligne_raw AS ligne,

  concat_ws(
    ', ',
    CASE WHEN NOT ok_site_id
      THEN format('site_id=%s', site_id)
    END,
    CASE WHEN NOT ok_site_nom
      THEN format('site_nom=%s', site_nom)
    END,
    CASE WHEN NOT ok_desc
      THEN format('description_site=%s', description_site)
    END,
    CASE WHEN NOT ok_site_id_conv
      THEN format('site_id(conv)=%s', site_id)
    END,
    CASE WHEN NOT ok_site_nom_conv
      THEN format('site_nom(conv)=%s', site_nom)
    END,
    CASE WHEN NOT ok_desc_conv
      THEN format('description_site(conv)=%s', description_site)
    END
  ) AS attributs
FROM src
WHERE NOT (
  ok_site_id AND ok_site_nom AND ok_desc
  AND ok_site_id_conv AND ok_site_nom_conv AND ok_desc_conv
);

-- =================
--  ZONE_BASE : INSERT
-- =================
WITH src AS (
  SELECT DISTINCT
    site_id,
    zone,
    description_zone
  FROM "Staging".megantic
  WHERE zone IS NOT NULL
)
INSERT INTO Zone (id, zone, description)
SELECT
  site_conv(s.site_id),
  zone_conv(s.zone),
  description_conv(s.description_zone)
FROM src s
WHERE
      site_verif(s.site_id)
  AND zone_verif(s.zone)
  AND description_verif(s.description_zone)
  AND site_conv(s.site_id) IS NOT NULL
  AND zone_conv(s.zone) IS NOT NULL
  AND description_conv(s.description_zone) IS NOT NULL
  AND EXISTS (
    SELECT 1 FROM Site si
    WHERE si.id = site_conv(s.site_id)
  )
ON CONFLICT DO NOTHING;

-- ================
--  ZONE_BASE : REJETS
-- ================
WITH src AS (
  SELECT
    m.*,
    to_jsonb(m) AS ligne_raw,

    COALESCE(site_verif(m.site_id), false)                  AS ok_site_id,
    COALESCE(zone_verif(m.zone), false)                     AS ok_zone,
    COALESCE(description_verif(m.description_zone), false)  AS ok_desc,

    CASE
      WHEN site_verif(m.site_id)
        THEN COALESCE(site_conv(m.site_id) IS NOT NULL, false)
      ELSE false
    END AS ok_site_id_conv,

    CASE
      WHEN zone_verif(m.zone)
        THEN COALESCE(zone_conv(m.zone) IS NOT NULL, false)
      ELSE false
    END AS ok_zone_conv,

    CASE
      WHEN description_verif(m.description_zone)
        THEN COALESCE(description_conv(m.description_zone) IS NOT NULL, false)
      ELSE false
    END AS ok_desc_conv,


    CASE
      WHEN site_verif(m.site_id)
        THEN EXISTS (
               SELECT 1
               FROM Site si
               WHERE si.id = site_conv(m.site_id)
             )
      ELSE false
    END AS ok_fk_site

  FROM "Staging".megantic m
  WHERE m.zone IS NOT NULL
)
INSERT INTO Rejets (flux, motif, details, ligne, attributs)
SELECT
  'ZONE_BASE' AS flux,
  COALESCE(
    concat_ws(
      ', ',
      CASE WHEN NOT ok_site_id      THEN 'Identifiant de site invalide' END,
      CASE WHEN NOT ok_zone         THEN 'Zone invalide' END,
      CASE WHEN NOT ok_desc         THEN 'Description de zone invalide' END,
      CASE WHEN NOT ok_site_id_conv THEN 'Conversion site_id NULL' END,
      CASE WHEN NOT ok_zone_conv    THEN 'Conversion zone NULL' END,
      CASE WHEN NOT ok_desc_conv    THEN 'Conversion description zone NULL' END,
      CASE WHEN NOT ok_fk_site      THEN 'Site inexistant (FK)' END
    ),
    'Rejet sans motif identifié'
  ) AS motif,
  'Megantic_ELT - ZONE_BASE' AS details,
   ligne_raw AS ligne,

  concat_ws(
    ', ',
    CASE WHEN NOT ok_site_id
      THEN format('site_id=%s', site_id)
    END,
    CASE WHEN NOT ok_zone
      THEN format('zone=%s', zone)
    END,
    CASE WHEN NOT ok_desc
      THEN format('description_zone=%s', description_zone)
    END,
    CASE WHEN NOT ok_site_id_conv
      THEN format('site_id(conv)=%s', site_id)
    END,
    CASE WHEN NOT ok_zone_conv
      THEN format('zone(conv)=%s', zone)
    END,
    CASE WHEN NOT ok_desc_conv
      THEN format('description_zone(conv)=%s', description_zone)
    END,
    CASE WHEN NOT ok_fk_site
      THEN format('site_fk=%s', site_id)
    END
  ) AS attributs
FROM src
WHERE NOT (
  ok_site_id AND ok_zone AND ok_desc
  AND ok_site_id_conv AND ok_zone_conv AND ok_desc_conv
  AND ok_fk_site
);

/* ===========================================================
   1) PLACETTE  +  REJETS
   =========================================================== */

WITH src AS (
  SELECT DISTINCT
    zone,
    plac
  FROM "Staging".megantic
)
INSERT INTO Placette (zone, plac)
SELECT
  zone_conv(s.zone),
  placette_conv(s.plac)
FROM src s
WHERE
      zone_verif(s.zone)
  AND placette_verif(s.plac)
  AND zone_conv(s.zone) IS NOT NULL
  AND placette_conv(s.plac) IS NOT NULL
  AND EXISTS (
    SELECT 1
    FROM Zone z
    WHERE z.zone = zone_conv(s.zone)
  )
ON CONFLICT DO NOTHING;

-- ==================================
--  PLACETTE_BASE : REJETS
-- ==================================
WITH src AS (
  SELECT
    m.*,
    to_jsonb(m) AS ligne_raw,
    COALESCE(zone_verif(m.zone), false)         AS ok_zone,
    COALESCE(placette_verif(m.plac), false)     AS ok_placette,
    COALESCE(zone_conv(m.zone) IS NOT NULL, false)     AS ok_zone_conv,
    COALESCE(placette_conv(m.plac) IS NOT NULL, false) AS ok_plac_conv
  FROM "Staging".megantic m
)
INSERT INTO Rejets (flux, motif, details, ligne, attributs)
SELECT
  'PLACETTE_BASE' AS flux,
  COALESCE(
    concat_ws(
      ', ',
      CASE WHEN NOT ok_zone
           THEN 'Identifiant de zone invalide (format MMA)' END,
      CASE WHEN NOT ok_placette
           THEN 'Identifiant de placette invalide (format A0)' END,
      CASE WHEN NOT ok_zone_conv
           THEN 'Conversion de zone invalide (zone_conv = NULL)' END,
      CASE WHEN NOT ok_plac_conv
           THEN 'Conversion de placette invalide (placette_conv = NULL)' END
    ),
    'Rejet sans motif identifié'
  ) AS motif,
  'Megantic_ELT - PLACETTE_BASE' AS details,
  ligne_raw AS ligne,
  concat_ws(
    ', ',
    CASE WHEN NOT ok_zone
      THEN format('zone=%s', zone) END,
    CASE WHEN NOT ok_placette
      THEN format('plac=%s', plac) END,
    CASE WHEN NOT ok_zone_conv
      THEN format('zone(conv)=%s', zone) END,
    CASE WHEN NOT ok_plac_conv
      THEN format('plac(conv)=%s', plac) END
  ) AS attributs
FROM src
WHERE NOT (ok_zone AND ok_placette AND ok_zone_conv AND ok_plac_conv);


-- =====================
--  PEUPLEMENT_BASE : INSERT
-- =====================
WITH src AS (
  SELECT DISTINCT
    peup,
    description_peup
  FROM "Staging".megantic
  WHERE peup IS NOT NULL
)
INSERT INTO Peuplement (peup, description)
SELECT
  peuplement_conv(s.peup),
  description_conv(s.description_peup)
FROM src s
WHERE
      peuplement_verif(s.peup)
  AND description_verif(s.description_peup)
  AND peuplement_conv(s.peup) IS NOT NULL
  AND description_conv(s.description_peup) IS NOT NULL
ON CONFLICT DO NOTHING;

-- ====================
--  PEUPLEMENT_BASE : REJETS
-- ====================
WITH src AS (
  SELECT
    m.*,
    to_jsonb(m) AS ligne_raw,
    COALESCE(peuplement_verif(m.peup), false)            AS ok_peup,
    COALESCE(description_verif(m.description_peup), false) AS ok_desc,
    COALESCE(peuplement_conv(m.peup) IS NOT NULL, false)        AS ok_peup_conv,
    COALESCE(description_conv(m.description_peup) IS NOT NULL, false) AS ok_desc_conv
  FROM "Staging".megantic m
  WHERE m.peup IS NOT NULL
)
INSERT INTO Rejets (flux, motif, details, ligne, attributs)
SELECT
  'PEUPLEMENT_BASE' AS flux,
  COALESCE(
    concat_ws(
      ', ',
      CASE WHEN NOT ok_peup      THEN 'Code de peuplement invalide' END,
      CASE WHEN NOT ok_desc      THEN 'Description de peuplement invalide' END,
      CASE WHEN NOT ok_peup_conv THEN 'Conversion peuplement NULL' END,
      CASE WHEN NOT ok_desc_conv THEN 'Conversion description peuplement NULL' END
    ),
    'Rejet sans motif identifié'
  ) AS motif,
  'Megantic_ELT - PEUPLEMENT_BASE' AS details,
  ligne_raw AS ligne,
  concat_ws(
    ', ',
    CASE WHEN NOT ok_peup
      THEN format('peup=%s', peup) END,
    CASE WHEN NOT ok_desc
      THEN format('description_peup=%s', description_peup) END,
    CASE WHEN NOT ok_peup_conv
      THEN format('peup(conv)=%s', peup) END,
    CASE WHEN NOT ok_desc_conv
      THEN format('description_peup(conv)=%s', description_peup) END
  ) AS attributs
FROM src
WHERE NOT (ok_peup AND ok_desc AND ok_peup_conv AND ok_desc_conv);

/* ===========================================================
   2) PLACETTE_CORE  +  REJETS
   =========================================================== */

-- =============================
--  PLACETTE_CORE_BASE : INSERT
-- =============================
WITH src AS (
  SELECT DISTINCT
    zone,
    plac,
    peup,
    date
  FROM "Staging".megantic
)
INSERT INTO Placette_core (zone, plac, peup, date)
SELECT
  zone_conv(s.zone),
  placette_conv(s.plac),
  peuplement_conv(s.peup),
  dateeco_conv(s.date)
FROM src s
WHERE
      zone_verif(s.zone)
  AND placette_verif(s.plac)
  AND peuplement_verif(s.peup)
  AND dateeco_verif(s.date)
  AND zone_conv(s.zone) IS NOT NULL
  AND placette_conv(s.plac) IS NOT NULL
  AND peuplement_conv(s.peup) IS NOT NULL
  AND dateeco_conv(s.date) IS NOT NULL
  AND EXISTS (
    SELECT 1
    FROM Placette p
    WHERE p.zone = zone_conv(s.zone)
      AND p.plac = placette_conv(s.plac)
  )
  AND EXISTS (
    SELECT 1
    FROM Peuplement pe
    WHERE pe.peup = peuplement_conv(s.peup)
  )
ON CONFLICT DO NOTHING;

-- ===============================
--  PLACETTE_CORE_BASE : REJETS
-- ===============================
WITH src AS (
  SELECT
    m.*,
    to_jsonb(m) AS ligne_raw,
    COALESCE(zone_verif(m.zone), false)         AS ok_zone,
    COALESCE(placette_verif(m.plac), false)     AS ok_placette,
    COALESCE(peuplement_verif(m.peup), false)   AS ok_peup,
    COALESCE(dateeco_verif(m.date), false)      AS ok_date,
    COALESCE(zone_conv(m.zone) IS NOT NULL, false)         AS ok_zone_conv,
    COALESCE(placette_conv(m.plac) IS NOT NULL, false)     AS ok_plac_conv,
    COALESCE(peuplement_conv(m.peup) IS NOT NULL, false)   AS ok_peup_conv,
    COALESCE(dateeco_conv(m.date) IS NOT NULL, false)      AS ok_date_conv,
    EXISTS (
      SELECT 1 FROM Placette p
      WHERE p.zone = zone_conv(m.zone)
        AND p.plac = placette_conv(m.plac)
    ) AS ok_fk_placette,
    EXISTS (
      SELECT 1 FROM Peuplement pe
      WHERE pe.peup = peuplement_conv(m.peup)
    ) AS ok_fk_peup
  FROM "Staging".megantic m
)
INSERT INTO Rejets (flux, motif, details, ligne, attributs)
SELECT
  'PLACETTE_CORE_BASE' AS flux,
  COALESCE(
    concat_ws(
      ', ',
      CASE WHEN NOT ok_zone        THEN 'Zone invalide (Zone_verif)' END,
      CASE WHEN NOT ok_placette    THEN 'Placette invalide (Placette_verif)' END,
      CASE WHEN NOT ok_peup        THEN 'Peuplement invalide (Peuplement_verif)' END,
      CASE WHEN NOT ok_date        THEN 'Date écologique invalide (DateEco_verif)' END,
      CASE WHEN NOT ok_zone_conv   THEN 'Conversion zone NULL' END,
      CASE WHEN NOT ok_plac_conv   THEN 'Conversion placette NULL' END,
      CASE WHEN NOT ok_peup_conv   THEN 'Conversion peuplement NULL' END,
      CASE WHEN NOT ok_date_conv   THEN 'Conversion date NULL' END,
      CASE WHEN NOT ok_fk_placette THEN 'Placette (zone,plac) inexistante dans Placette' END,
      CASE WHEN NOT ok_fk_peup     THEN 'Peuplement inexistant dans Peuplement' END
    ),
    'Rejet sans motif identifié'
  ) AS motif,
  'Megantic_ELT - PLACETTE_CORE_BASE' AS details,
  ligne_raw AS ligne,
  concat_ws(
    ', ',
    CASE WHEN NOT ok_zone
      THEN format('zone=%s', zone) END,
    CASE WHEN NOT ok_placette
      THEN format('plac=%s', plac) END,
    CASE WHEN NOT ok_peup
      THEN format('peup=%s', peup) END,
    CASE WHEN NOT ok_date
      THEN format('date=%s', date) END,
    CASE WHEN NOT ok_zone_conv
      THEN format('zone(conv)=%s', zone) END,
    CASE WHEN NOT ok_plac_conv
      THEN format('plac(conv)=%s', plac) END,
    CASE WHEN NOT ok_peup_conv
      THEN format('peup(conv)=%s', peup) END,
    CASE WHEN NOT ok_date_conv
      THEN format('date(conv)=%s', date) END,
    CASE WHEN NOT ok_fk_placette
      THEN format('fk_placette(zone,plac)=%s,%s', zone, plac) END,
    CASE WHEN NOT ok_fk_peup
      THEN format('fk_peuplement=%s', peup) END
  ) AS attributs
FROM src
WHERE NOT (
  ok_zone AND ok_placette AND ok_peup AND ok_date
  AND ok_zone_conv AND ok_plac_conv AND ok_peup_conv AND ok_date_conv
  AND ok_fk_placette AND ok_fk_peup
);




/* ===========================================================
   3) PARCELLE  +  REJETS
   =========================================================== */
-- ===================
--  PARCELLE_BASE : INSERT
-- ===================
WITH src AS (
  SELECT DISTINCT
    zone,
    plac,
    parcelle
  FROM "Staging".megantic
  WHERE parcelle IS NOT NULL
)
INSERT INTO parcelle (zone, plac, parcelle)
SELECT
  zone_conv(s.zone),
  placette_conv(s.plac),
  parcelle_conv(s.parcelle)
FROM src s
WHERE
      zone_verif(s.zone)
  AND placette_verif(s.plac)
  AND parcelle_verif(s.parcelle)
  AND zone_conv(s.zone) IS NOT NULL
  AND placette_conv(s.plac) IS NOT NULL
  AND parcelle_conv(s.parcelle) IS NOT NULL
  AND EXISTS (
    SELECT 1 FROM Placette p
    WHERE p.zone = zone_conv(s.zone)
      AND p.plac = placette_conv(s.plac)
  )
ON CONFLICT DO NOTHING;

-- ============================
--  PARCELLE_BASE : REJETS
-- ============================
WITH src AS (
  SELECT
    m.*,
    to_jsonb(m) AS ligne_raw,
    COALESCE(zone_verif(m.zone), false)             AS ok_zone,
    COALESCE(placette_verif(m.plac), false)         AS ok_placette,
    COALESCE(parcelle_verif(m.parcelle), false)     AS ok_parcelle,
    COALESCE(zone_conv(m.zone) IS NOT NULL, false)        AS ok_zone_conv,
    COALESCE(placette_conv(m.plac) IS NOT NULL, false)    AS ok_plac_conv,
    COALESCE(parcelle_conv(m.parcelle) IS NOT NULL, false) AS ok_parcelle_conv,
    EXISTS (
      SELECT 1
      FROM Placette p
      WHERE p.zone = zone_conv(m.zone)
        AND p.plac = placette_conv(m.plac)
    ) AS ok_fk_placette
  FROM "Staging".megantic m
  WHERE m.parcelle IS NOT NULL
)
INSERT INTO Rejets (flux, motif, details, ligne, attributs)
SELECT
  'PARCELLE_BASE' AS flux,
  COALESCE(
    concat_ws(
      ', ',
      CASE WHEN NOT ok_zone
        THEN 'Zone invalide' END,
      CASE WHEN NOT ok_placette
        THEN 'Placette invalide' END,
      CASE WHEN NOT ok_parcelle
        THEN 'Parcelle invalide' END,
      CASE WHEN NOT ok_zone_conv
        THEN 'Conversion zone NULL' END,
      CASE WHEN NOT ok_plac_conv
        THEN 'Conversion placette NULL' END,
      CASE WHEN NOT ok_parcelle_conv
        THEN 'Conversion parcelle NULL' END,
      CASE WHEN NOT ok_fk_placette
        THEN 'Placette inexistante (FK)' END
    ),
    'Rejet sans motif identifié'
  ) AS motif,
  'Megantic_ELT - PARCELLE_BASE' AS details,
  ligne_raw AS ligne,
  concat_ws(
    ', ',
    CASE WHEN NOT ok_zone
      THEN format('zone=%s', zone) END,
    CASE WHEN NOT ok_placette
      THEN format('plac=%s', plac) END,
    CASE WHEN NOT ok_parcelle
      THEN format('parcelle=%s', parcelle) END,
    CASE WHEN NOT ok_zone_conv
      THEN format('zone(conv)=%s', zone) END,
    CASE WHEN NOT ok_plac_conv
      THEN format('plac(conv)=%s', plac) END,
    CASE WHEN NOT ok_parcelle_conv
      THEN format('parcelle(conv)=%s', parcelle) END,
    CASE WHEN NOT ok_fk_placette
      THEN format('fk_placette(zone,plac)=%s,%s', zone, plac) END
  ) AS attributs
FROM src
WHERE NOT (
  ok_zone
  AND ok_placette
  AND ok_parcelle
  AND ok_zone_conv
  AND ok_plac_conv
  AND ok_parcelle_conv
  AND ok_fk_placette
);

-- ================================
--  PLACETTE_COUVERT_BASE : INSERT
-- ================================
WITH src AS (
  SELECT DISTINCT
    zone,
    plac,
    ctype,
    tcat,
    tval
  FROM "Staging".megantic
  WHERE ctype IS NOT NULL
),
src2 AS (
  SELECT
    s.*,
    t.tMin AS tmin,
    t.tMax AS tmax
  FROM src s
  LEFT JOIN Taux t
    ON t.tCat::text = s.tcat
)
INSERT INTO Placette_Couvert (zone, plac, ctype, tcat, tval)
SELECT
  zone_conv(s.zone),
  placette_conv(s.plac),
  CouvertType_conv(s.ctype),
  TCat_conv(s.tcat),
  s.tval::Taux_val
FROM src2 s
WHERE
  zone_verif(s.zone)
  AND placette_verif(s.plac)
  AND CouvertType_verif(s.ctype)
  AND TCat_verif(s.tcat)
  AND s.tval BETWEEN 0 AND 100     -- borne générale DVCT
  AND s.tmin IS NOT NULL           -- borne venant de TAUX
  AND s.tmax IS NOT NULL
  AND s.tval BETWEEN s.tmin AND s.tmax    -- borne TAUX
  AND zone_conv(s.zone)         IS NOT NULL
  AND placette_conv(s.plac)     IS NOT NULL
  AND CouvertType_conv(s.ctype) IS NOT NULL
  AND TCat_conv(s.tcat)         IS NOT NULL
  AND EXISTS (
      SELECT 1 FROM Placette p
      WHERE p.zone = zone_conv(s.zone)
        AND p.plac = placette_conv(s.plac)
  )
  AND EXISTS (
      SELECT 1 FROM Taux t
      WHERE t.tCat = TCat_conv(s.tcat)
  )
ON CONFLICT DO NOTHING;



-- ==================================
--  PLACETTE_COUVERT_BASE : REJETS
-- ==================================
WITH src AS (
  SELECT
    m.*,
    to_jsonb(m) AS ligne_raw,
    t.tMin AS tmin,
    t.tMax AS tmax,

    COALESCE(zone_verif(m.zone), false)         AS ok_zone,
    COALESCE(placette_verif(m.plac), false)     AS ok_placette,
    COALESCE(CouvertType_verif(m.ctype), false) AS ok_ctype,
    COALESCE(TCat_verif(m.tcat), false)         AS ok_tcat,
    (m.tval BETWEEN 0 AND 100)                  AS ok_tval,

    ( t.tMin IS NOT NULL
      AND t.tMax IS NOT NULL
      AND m.tval BETWEEN t.tMin AND t.tMax
    )                                           AS ok_tval_bounds,

    COALESCE(zone_conv(m.zone) IS NOT NULL, false)         AS ok_zone_conv,
    COALESCE(placette_conv(m.plac) IS NOT NULL, false)     AS ok_plac_conv,
    COALESCE(CouvertType_conv(m.ctype) IS NOT NULL, false) AS ok_ctype_conv,
    COALESCE(TCat_conv(m.tcat) IS NOT NULL, false)         AS ok_tcat_conv,

    EXISTS (
      SELECT 1 FROM Placette p
      WHERE p.zone = zone_conv(m.zone)
        AND p.plac = placette_conv(m.plac)
    ) AS ok_fk_placette,

    EXISTS (
      SELECT 1 FROM Taux t2
      WHERE t2.tCat = TCat_conv(m.tcat)
    ) AS ok_fk_taux

  FROM "Staging".megantic m
  LEFT JOIN Taux t ON t.tCat::text = m.tcat
  WHERE m.ctype IS NOT NULL
)
INSERT INTO Rejets (flux, motif, details, ligne, attributs)
SELECT
  'PLACETTE_COUVERT_BASE',
  COALESCE(
    concat_ws(
      ', ',
      CASE WHEN NOT ok_zone         THEN 'Zone invalide' END,
      CASE WHEN NOT ok_placette     THEN 'Placette invalide' END,
      CASE WHEN NOT ok_ctype        THEN 'Type de couvert invalide' END,
      CASE WHEN NOT ok_tcat         THEN 'Catégorie de taux invalide' END,
      CASE WHEN NOT ok_tval         THEN 'Valeur tVal hors [0..100]' END,
      CASE WHEN NOT ok_tval_bounds  THEN format('tVal hors intervalle [%s-%s]', tmin, tmax) END,
      CASE WHEN NOT ok_zone_conv    THEN 'Conversion zone NULL' END,
      CASE WHEN NOT ok_plac_conv    THEN 'Conversion placette NULL' END,
      CASE WHEN NOT ok_ctype_conv   THEN 'Conversion type couv. NULL' END,
      CASE WHEN NOT ok_tcat_conv    THEN 'Conversion tCat NULL' END,
      CASE WHEN NOT ok_fk_placette  THEN 'Placette inexistante (FK)' END,
      CASE WHEN NOT ok_fk_taux      THEN 'Taux inexistant (FK)' END
    ),
    'Rejet sans motif identifié'
  ) AS motif,
  'Megantic_ELT - PLACETTE_COUVERT_BASE',
  ligne_raw,
  concat_ws(
    ', ',
    format('zone=%s', zone),
    format('plac=%s', plac),
    format('ctype=%s', ctype),
    format('tcat=%s', tcat),
    format('tval=%s', tval),
    CASE WHEN tmin IS NOT NULL THEN format('tmin=%s', tmin) END,
    CASE WHEN tmax IS NOT NULL THEN format('tmax=%s', tmax) END
  ) AS attributs
FROM src
WHERE NOT (
  ok_zone AND ok_placette AND ok_ctype AND ok_tcat AND ok_tval AND ok_tval_bounds
  AND ok_zone_conv AND ok_plac_conv AND ok_ctype_conv AND ok_tcat_conv
  AND ok_fk_placette AND ok_fk_taux
);

/* ===========================================================
   4) PLANT  +  REJETS
   =========================================================== */

-- ===================
--  PLANT_BASE : INSERT
-- ===================
WITH src AS (
  SELECT DISTINCT
    zone,
    plac,
    id,
    date,
    note
  FROM "Staging".megantic
  WHERE id IS NOT NULL
)
INSERT INTO Plant (zone, id, plac, date, note)
SELECT
  zone_conv(s.zone),
  plant_conv(s.id),
  placette_conv(s.plac),
  dateeco_conv(s.date),
  description_conv(s.note)
FROM src s
WHERE
      zone_verif(s.zone)
  AND placette_verif(s.plac)
  AND plant_verif(s.id)
  AND dateeco_verif(s.date)
  AND (s.note IS NULL OR description_verif(s.note))
  AND zone_conv(s.zone) IS NOT NULL
  AND placette_conv(s.plac) IS NOT NULL
  AND plant_conv(s.id) IS NOT NULL
  AND dateeco_conv(s.date) IS NOT NULL
  AND (s.note IS NULL OR description_conv(s.note) IS NOT NULL)
  AND EXISTS (
    SELECT 1 FROM Placette p
    WHERE p.zone = zone_conv(s.zone)
      AND p.plac = placette_conv(s.plac)
  )
ON CONFLICT DO NOTHING;

-- =====================
--  PLANT_BASE : REJETS
-- =====================
WITH src AS (
  SELECT
    m.*,
    to_jsonb(m) AS ligne_raw,
    COALESCE(zone_verif(m.zone), false)         AS ok_zone,
    COALESCE(placette_verif(m.plac), false)     AS ok_placette,
    COALESCE(plant_verif(m.id), false)          AS ok_id,
    COALESCE(dateeco_verif(m.date), false)      AS ok_date,
    (m.note IS NULL OR description_verif(m.note)) AS ok_note,
    COALESCE(zone_conv(m.zone) IS NOT NULL, false)     AS ok_zone_conv,
    COALESCE(placette_conv(m.plac) IS NOT NULL, false) AS ok_plac_conv,
    COALESCE(plant_conv(m.id) IS NOT NULL, false)      AS ok_id_conv,
    COALESCE(dateeco_conv(m.date) IS NOT NULL, false)  AS ok_date_conv,
    (m.note IS NULL OR description_conv(m.note) IS NOT NULL) AS ok_note_conv,
    EXISTS (
      SELECT 1 FROM Placette p
      WHERE p.zone = zone_conv(m.zone)
        AND p.plac = placette_conv(m.plac)
    ) AS ok_fk_placette
  FROM "Staging".megantic m
  WHERE m.id IS NOT NULL
)
INSERT INTO Rejets (flux, motif, details, ligne, attributs)
SELECT
  'PLANT_BASE' AS flux,
  COALESCE(
    concat_ws(
      ', ',
      CASE WHEN NOT ok_zone       THEN 'Zone invalide' END,
      CASE WHEN NOT ok_placette   THEN 'Placette invalide' END,
      CASE WHEN NOT ok_id         THEN 'Identifiant de plant invalide' END,
      CASE WHEN NOT ok_date       THEN 'Date écologique invalide' END,
      CASE WHEN NOT ok_note       THEN 'Note invalide (Description)' END,
      CASE WHEN NOT ok_zone_conv  THEN 'Conversion zone NULL' END,
      CASE WHEN NOT ok_plac_conv  THEN 'Conversion placette NULL' END,
      CASE WHEN NOT ok_id_conv    THEN 'Conversion plant NULL' END,
      CASE WHEN NOT ok_date_conv  THEN 'Conversion date NULL' END,
      CASE WHEN NOT ok_note_conv  THEN 'Conversion note NULL' END,
      CASE WHEN NOT ok_fk_placette THEN 'Placette inexistante (FK)' END
    ),
    'Rejet sans motif identifié'
  ) AS motif,
  'Megantic_ELT - PLANT_BASE' AS details,
  ligne_raw AS ligne,
  concat_ws(
    ', ',
    CASE WHEN NOT ok_zone
      THEN format('zone=%s', zone) END,
    CASE WHEN NOT ok_placette
      THEN format('plac=%s', plac) END,
    CASE WHEN NOT ok_id
      THEN format('id=%s', id) END,
    CASE WHEN NOT ok_date
      THEN format('date=%s', date) END,
    CASE WHEN NOT ok_note
      THEN format('note=%s', note) END,
    CASE WHEN NOT ok_zone_conv
      THEN format('zone(conv)=%s', zone) END,
    CASE WHEN NOT ok_plac_conv
      THEN format('plac(conv)=%s', plac) END,
    CASE WHEN NOT ok_id_conv
      THEN format('id(conv)=%s', id) END,
    CASE WHEN NOT ok_date_conv
      THEN format('date(conv)=%s', date) END,
    CASE WHEN NOT ok_note_conv
      THEN format('note(conv)=%s', note) END,
    CASE WHEN NOT ok_fk_placette
      THEN format('fk_placette(zone,plac)=%s,%s', zone, plac) END
  ) AS attributs
FROM src
WHERE NOT (
  ok_zone AND ok_placette AND ok_id AND ok_date AND ok_note
  AND ok_zone_conv AND ok_plac_conv AND ok_id_conv AND ok_date_conv AND ok_note_conv
  AND ok_fk_placette
);



/* ===========================================================
   5) OBS_DIMENSION  +  REJETS
   =========================================================== */

-- ===========================
--  OBSDIMENSION_BASE : INSERT
-- ===========================
WITH src AS (
  SELECT DISTINCT
    id,
    longueur,
    largeur,
    date,
    unite_id,
    note
  FROM "Staging".megantic
  WHERE id IS NOT NULL
    AND longueur IS NOT NULL
    AND largeur IS NOT NULL
)
INSERT INTO ObsDimension (id, longueur, largeur, date, unite_id, note)
SELECT
  plant_conv(s.id),
  s.longueur,
  s.largeur,
  dateeco_conv(s.date),
  s.unite_id,
  CASE
    WHEN s.note IS NOT NULL AND description_verif(s.note)
      THEN description_conv(s.note)
    ELSE NULL
  END
FROM src s
WHERE
      plant_verif(s.id)
  AND dateeco_verif(s.date)
  AND s.longueur BETWEEN 1 AND 999
  AND s.largeur  BETWEEN 1 AND 999
  AND (s.note IS NULL OR description_verif(s.note))
  AND plant_conv(s.id) IS NOT NULL
  AND dateeco_conv(s.date) IS NOT NULL
  AND plant_conv(s.id) IN (SELECT id FROM Plant)
  AND EXISTS (SELECT 1 FROM UNITE u WHERE u.unite_id = s.unite_id)
ON CONFLICT DO NOTHING;

-- =============================
--  OBSDIMENSION_BASE : REJETS
-- =============================
WITH src AS (
  SELECT
    m.*,
    to_jsonb(m) AS ligne_raw,
    COALESCE(plant_verif(m.id), false)       AS ok_id,
    COALESCE(dateeco_verif(m.date), false)   AS ok_date,
    (m.longueur BETWEEN 1 AND 999)           AS ok_longueur,
    (m.largeur  BETWEEN 1 AND 999)           AS ok_largeur,
    (m.note IS NULL OR description_verif(m.note)) AS ok_note,
    COALESCE(plant_conv(m.id) IS NOT NULL, false)     AS ok_id_conv,
    COALESCE(dateeco_conv(m.date) IS NOT NULL, false) AS ok_date_conv,
    (m.note IS NULL OR description_conv(m.note) IS NOT NULL) AS ok_note_conv,
    EXISTS (SELECT 1 FROM Plant p WHERE p.id = plant_conv(m.id)) AS ok_fk_plant,
    EXISTS (SELECT 1 FROM UNITE u WHERE u.unite_id = m.unite_id) AS ok_fk_unite
  FROM "Staging".megantic m
  WHERE m.id IS NOT NULL
    AND m.longueur IS NOT NULL
    AND m.largeur IS NOT NULL
)
INSERT INTO Rejets (flux, motif, details, ligne, attributs)
SELECT
  'OBSDIMENSION_BASE' AS flux,
  COALESCE(
    concat_ws(
      ', ',
      CASE WHEN NOT ok_id        THEN 'Identifiant de plant invalide' END,
      CASE WHEN NOT ok_date      THEN 'Date écologique invalide' END,
      CASE WHEN NOT ok_longueur  THEN 'Longueur hors [1..999]' END,
      CASE WHEN NOT ok_largeur   THEN 'Largeur hors [1..999]' END,
      CASE WHEN NOT ok_note      THEN 'Note invalide' END,
      CASE WHEN NOT ok_id_conv   THEN 'Conversion plant NULL' END,
      CASE WHEN NOT ok_date_conv THEN 'Conversion date NULL' END,
      CASE WHEN NOT ok_note_conv THEN 'Conversion note NULL' END,
      CASE WHEN NOT ok_fk_plant  THEN 'Plant inexistant (FK)' END,
      CASE WHEN NOT ok_fk_unite  THEN 'Unité inexistante (FK)' END
    ),
    'Rejet sans motif identifié'
  ) AS motif,
  'Megantic_ELT - OBSDIMENSION_BASE' AS details,
  ligne_raw AS ligne,
  concat_ws(
    ', ',
    CASE WHEN NOT ok_id
      THEN format('id=%s', id) END,
    CASE WHEN NOT ok_date
      THEN format('date=%s', date) END,
    CASE WHEN NOT ok_longueur
      THEN format('longueur=%s', longueur) END,
    CASE WHEN NOT ok_largeur
      THEN format('largeur=%s', largeur) END,
    CASE WHEN NOT ok_note
      THEN format('note=%s', note) END,
    CASE WHEN NOT ok_id_conv
      THEN format('id(conv)=%s', id) END,
    CASE WHEN NOT ok_date_conv
      THEN format('date(conv)=%s', date) END,
    CASE WHEN NOT ok_note_conv
      THEN format('note(conv)=%s', note) END,
    CASE WHEN NOT ok_fk_plant
      THEN format('fk_plant=%s', id) END,
    CASE WHEN NOT ok_fk_unite
      THEN format('fk_unite=%s', unite_id) END
  ) AS attributs
FROM src
WHERE NOT (
  ok_id AND ok_date AND ok_longueur AND ok_largeur AND ok_note
  AND ok_id_conv AND ok_date_conv AND ok_note_conv
  AND ok_fk_plant AND ok_fk_unite
);

/* ===========================================================
   6) OBS_FLORAISON  +  REJETS
   =========================================================== */

-- ===========================
--  OBSFLORAISON_BASE : INSERT
-- ===========================
WITH src AS (
  SELECT DISTINCT
    id,
    fleur,
    date,
    note
  FROM "Staging".megantic
  WHERE id IS NOT NULL
)
INSERT INTO ObsFloraison (id, fleur, date, note)
SELECT
  plant_conv(s.id),
  s.fleur,
  dateeco_conv(s.date),
  description_conv(s.note)
FROM src s
WHERE
      plant_verif(s.id)
  AND dateeco_verif(s.date)
  AND description_verif(s.note)
  AND s.fleur IS NOT NULL
  AND plant_conv(s.id) IS NOT NULL
  AND dateeco_conv(s.date) IS NOT NULL
  AND description_conv(s.note) IS NOT NULL
  AND EXISTS (SELECT 1 FROM Plant p WHERE p.id = plant_conv(s.id))
ON CONFLICT DO NOTHING;


-- =============================
--  OBSFLORAISON_BASE : REJETS
-- =============================
WITH src AS (
  SELECT
    m.*,
    to_jsonb(m) AS ligne_raw,
    COALESCE(plant_verif(m.id), false)       AS ok_id,
    COALESCE(dateeco_verif(m.date), false)   AS ok_date,
    COALESCE(description_verif(m.note), false) AS ok_note,
    COALESCE(plant_conv(m.id) IS NOT NULL, false)     AS ok_id_conv,
    COALESCE(dateeco_conv(m.date) IS NOT NULL, false) AS ok_date_conv,
    COALESCE(description_conv(m.note) IS NOT NULL, false) AS ok_note_conv,
    COALESCE(m.fleur IS NOT NULL, false) AS ok_fleur,
    EXISTS (SELECT 1 FROM Plant p WHERE p.id = plant_conv(m.id)) AS ok_fk_plant
  FROM "Staging".megantic m
  WHERE m.id IS NOT NULL
)
INSERT INTO Rejets (flux, motif, details, ligne, attributs)
SELECT
  'OBSFLORAISON_BASE' AS flux,
  COALESCE(
    concat_ws(
      ', ',
      CASE WHEN NOT ok_id        THEN 'Identifiant de plant invalide' END,
      CASE WHEN NOT ok_date      THEN 'Date écologique invalide' END,
      CASE WHEN NOT ok_note      THEN 'Note invalide' END,
      CASE WHEN NOT ok_id_conv   THEN 'Conversion plant NULL' END,
      CASE WHEN NOT ok_fleur   THEN 'Conversion fleur NULL' END,
      CASE WHEN NOT ok_date_conv THEN 'Conversion date NULL' END,
      CASE WHEN NOT ok_note_conv THEN 'Conversion note NULL' END,
      CASE WHEN NOT ok_fk_plant  THEN 'Plant inexistant (FK)' END
    ),
    'Rejet sans motif identifié'
  ) AS motif,
  'Megantic_ELT - OBSFLORAISON_BASE' AS details,
  ligne_raw AS ligne,
  concat_ws(
    ', ',
    CASE WHEN NOT ok_id
      THEN format('id=%s', id) END,
    CASE WHEN NOT ok_date
      THEN format('date=%s', date) END,
    CASE WHEN NOT ok_note
      THEN format('note=%s', note) END,
    CASE WHEN NOT ok_id_conv
      THEN format('id(conv)=%s', id) END,
    CASE WHEN NOT ok_date_conv
      THEN format('date(conv)=%s', date) END,
    CASE WHEN NOT ok_note_conv
      THEN format('note(conv)=%s', note) END,
    CASE WHEN NOT ok_fk_plant
      THEN format('fk_plant=%s', id) END
  ) AS attributs
FROM src
WHERE NOT (
  ok_id AND ok_date AND ok_note
  AND ok_id_conv AND ok_date_conv AND ok_note_conv
  AND ok_fk_plant
);




/* ===========================================================
   7) ETAT (référentiel)  +  REJETS
   =========================================================== */

-- ==============
--  ETAT_BASE
-- ==============
WITH src AS (
  SELECT DISTINCT
    etat,
    description_etat
  FROM "Staging".megantic
  WHERE etat IS NOT NULL
)
INSERT INTO Etat (etat, description)
SELECT
  etat_conv(s.etat),
  description_conv(s.description_etat)
FROM src s
WHERE
      etat_verif(s.etat)
  AND description_verif(s.description_etat)
  AND etat_conv(s.etat) IS NOT NULL
  AND description_conv(s.description_etat) IS NOT NULL
ON CONFLICT DO NOTHING;

WITH src AS (
  SELECT
    m.*,
    to_jsonb(m) AS ligne_raw,
    COALESCE(etat_verif(m.etat), false)                AS ok_etat,
    COALESCE(description_verif(m.description_etat), false) AS ok_desc,
    COALESCE(etat_conv(m.etat) IS NOT NULL, false)            AS ok_etat_conv,
    COALESCE(description_conv(m.description_etat) IS NOT NULL, false) AS ok_desc_conv
  FROM "Staging".megantic m
  WHERE m.etat IS NOT NULL
)
INSERT INTO Rejets (flux, motif, details, ligne, attributs)
SELECT
  'ETAT_BASE' AS flux,
  COALESCE(
    concat_ws(
      ', ',
      CASE WHEN NOT ok_etat      THEN 'Code d''état invalide' END,
      CASE WHEN NOT ok_desc      THEN 'Description d''état invalide' END,
      CASE WHEN NOT ok_etat_conv THEN 'Conversion état NULL' END,
      CASE WHEN NOT ok_desc_conv THEN 'Conversion description NULL' END
    ),
    'Rejet sans motif identifié'
  ) AS motif,
  'Megantic_ELT - ETAT_BASE' AS details,
  ligne_raw AS ligne,
  concat_ws(
    ', ',
    CASE WHEN NOT ok_etat
      THEN format('etat=%s', etat) END,
    CASE WHEN NOT ok_desc
      THEN format('description_etat=%s', description_etat) END,
    CASE WHEN NOT ok_etat_conv
      THEN format('etat(conv)=%s', etat) END,
    CASE WHEN NOT ok_desc_conv
      THEN format('description_etat(conv)=%s', description_etat) END
  ) AS attributs
FROM src
WHERE NOT (ok_etat AND ok_desc AND ok_etat_conv AND ok_desc_conv);



/* ===========================================================
   8) OBS_ETAT  +  REJETS
   =========================================================== */

-- ====================
--  OBSETAT_BASE INSERT
-- ====================
WITH src AS (
  SELECT DISTINCT
    id,
    etat,
    date,
    note
  FROM "Staging".megantic
  WHERE id IS NOT NULL
    AND etat IS NOT NULL
)
INSERT INTO ObsEtat (id, etat, date, note)
SELECT
  plant_conv(s.id),
  etat_conv(s.etat),
  dateeco_conv(s.date),
  description_conv(s.note)
FROM src s
WHERE
      plant_verif(s.id)
  AND etat_verif(s.etat)
  AND dateeco_verif(s.date)
  AND description_verif(s.note)
  AND plant_conv(s.id) IS NOT NULL
  AND etat_conv(s.etat) IS NOT NULL
  AND dateeco_conv(s.date) IS NOT NULL
  AND description_conv(s.note) IS NOT NULL
  AND EXISTS (SELECT 1 FROM Plant p WHERE p.id = plant_conv(s.id))
  AND EXISTS (SELECT 1 FROM Etat  e WHERE e.etat = etat_conv(s.etat))
ON CONFLICT DO NOTHING;

-- ===================
--  OBSETAT_BASE REJETS
-- ===================
WITH src AS (
  SELECT
    m.*,
    to_jsonb(m) AS ligne_raw,
    COALESCE(plant_verif(m.id), false)        AS ok_id,
    COALESCE(etat_verif(m.etat), false)       AS ok_etat,
    COALESCE(dateeco_verif(m.date), false)    AS ok_date,
    COALESCE(description_verif(m.note), false) AS ok_note,
    COALESCE(plant_conv(m.id) IS NOT NULL, false)     AS ok_id_conv,
    COALESCE(etat_conv(m.etat) IS NOT NULL, false)    AS ok_etat_conv,
    COALESCE(dateeco_conv(m.date) IS NOT NULL, false) AS ok_date_conv,
    COALESCE(description_conv(m.note) IS NOT NULL, false) AS ok_note_conv,
    EXISTS (SELECT 1 FROM Plant p WHERE p.id = plant_conv(m.id)) AS ok_fk_plant,
    EXISTS (SELECT 1 FROM Etat  e WHERE e.etat = etat_conv(m.etat)) AS ok_fk_etat
  FROM "Staging".megantic m
  WHERE m.id IS NOT NULL
    AND m.etat IS NOT NULL
)
INSERT INTO Rejets (flux, motif, details, ligne, attributs)
SELECT
  'OBSETAT_BASE' AS flux,
  COALESCE(
    concat_ws(
      ', ',
      CASE WHEN NOT ok_id        THEN 'Identifiant de plant invalide' END,
      CASE WHEN NOT ok_etat      THEN 'État invalide' END,
      CASE WHEN NOT ok_date      THEN 'Date écologique invalide' END,
      CASE WHEN NOT ok_note      THEN 'Note invalide' END,
      CASE WHEN NOT ok_id_conv   THEN 'Conversion plant NULL' END,
      CASE WHEN NOT ok_etat_conv THEN 'Conversion état NULL' END,
      CASE WHEN NOT ok_date_conv THEN 'Conversion date NULL' END,
      CASE WHEN NOT ok_note_conv THEN 'Conversion note NULL' END,
      CASE WHEN NOT ok_fk_plant  THEN 'Plant inexistant (FK)' END,
      CASE WHEN NOT ok_fk_etat   THEN 'État inexistant (FK)' END
    ),
    'Rejet sans motif identifié'
  ) AS motif,
  'Megantic_ELT - OBSETAT_BASE' AS details,
  ligne_raw AS ligne,
  concat_ws(
    ', ',
    CASE WHEN NOT ok_id
      THEN format('id=%s', id) END,
    CASE WHEN NOT ok_etat
      THEN format('etat=%s', etat) END,
    CASE WHEN NOT ok_date
      THEN format('date=%s', date) END,
    CASE WHEN NOT ok_note
      THEN format('note=%s', note) END,
    CASE WHEN NOT ok_id_conv
      THEN format('id(conv)=%s', id) END,
    CASE WHEN NOT ok_etat_conv
      THEN format('etat(conv)=%s', etat) END,
    CASE WHEN NOT ok_date_conv
      THEN format('date(conv)=%s', date) END,
    CASE WHEN NOT ok_note_conv
      THEN format('note(conv)=%s', note) END,
    CASE WHEN NOT ok_fk_plant
      THEN format('fk_plant=%s', id) END,
    CASE WHEN NOT ok_fk_etat
      THEN format('fk_etat=%s', etat) END
  ) AS attributs
FROM src
WHERE NOT (
  ok_id AND ok_etat AND ok_date AND ok_note
  AND ok_id_conv AND ok_etat_conv AND ok_date_conv AND ok_note_conv
  AND ok_fk_plant AND ok_fk_etat
);

-- =================
--  ARBRE_BASE : INSERT
-- =================
WITH src AS (
  SELECT DISTINCT
    arbre,
    description_arbre
  FROM "Staging".megantic
  WHERE arbre IS NOT NULL
)
INSERT INTO Arbre (arbre, description)
SELECT
  arbre_conv(s.arbre),
  description_conv(s.description_arbre)
FROM src s
WHERE
      arbre_verif(s.arbre)
  AND description_verif(s.description_arbre)
  AND arbre_conv(s.arbre) IS NOT NULL
  AND description_conv(s.description_arbre) IS NOT NULL
ON CONFLICT DO NOTHING;

-- ================
--  ARBRE_BASE : REJETS
-- ================
WITH src AS (
  SELECT
    m.*,
    to_jsonb(m) AS ligne_raw,
    COALESCE(arbre_verif(m.arbre), false)              AS ok_arbre,
    COALESCE(description_verif(m.description_arbre), false) AS ok_desc,
    COALESCE(arbre_conv(m.arbre) IS NOT NULL, false)          AS ok_arbre_conv,
    COALESCE(description_conv(m.description_arbre) IS NOT NULL, false) AS ok_desc_conv
  FROM "Staging".megantic m
  WHERE m.arbre IS NOT NULL
)
INSERT INTO Rejets (flux, motif, details, ligne, attributs)
SELECT
  'ARBRE_BASE' AS flux,
  COALESCE(
    concat_ws(
      ', ',
      CASE WHEN NOT ok_arbre      THEN 'Code d''arbre invalide' END,
      CASE WHEN NOT ok_desc       THEN 'Description d''arbre invalide' END,
      CASE WHEN NOT ok_arbre_conv THEN 'Conversion arbre NULL' END,
      CASE WHEN NOT ok_desc_conv  THEN 'Conversion description arbre NULL' END
    ),
    'Rejet sans motif identifié'
  ) AS motif,
  'Megantic_ELT - ARBRE_BASE' AS details,
  ligne_raw AS ligne,
  concat_ws(
    ', ',
    CASE WHEN NOT ok_arbre
      THEN format('arbre=%s', arbre) END,
    CASE WHEN NOT ok_desc
      THEN format('description_arbre=%s', description_arbre) END,
    CASE WHEN NOT ok_arbre_conv
      THEN format('arbre(conv)=%s', arbre) END,
    CASE WHEN NOT ok_desc_conv
      THEN format('description_arbre(conv)=%s', description_arbre) END
  ) AS attributs
FROM src
WHERE NOT (
  ok_arbre AND ok_desc AND ok_arbre_conv AND ok_desc_conv
);



-- ==============================
--  PLACETTE_DOMINANT_BASE : INSERT
-- ==============================
WITH src AS (
  SELECT DISTINCT
    zone,
    plac,
    rang,
    arbre
  FROM "Staging".megantic
  WHERE rang IS NOT NULL
)
INSERT INTO Placette_Dominant (zone, plac, rang, arbre)
SELECT
  zone_conv(s.zone),
  placette_conv(s.plac),
  s.rang::rang,
  arbre_conv(s.arbre)
FROM src s
WHERE
      zone_verif(s.zone)
  AND placette_verif(s.plac)
  AND arbre_verif(s.arbre)
  AND s.rang BETWEEN 1 AND 3
  AND zone_conv(s.zone) IS NOT NULL
  AND placette_conv(s.plac) IS NOT NULL
  AND arbre_conv(s.arbre) IS NOT NULL
  AND EXISTS (
    SELECT 1 FROM Placette p
    WHERE p.zone = zone_conv(s.zone)
      AND p.plac = placette_conv(s.plac)
  )
  AND EXISTS (
    SELECT 1 FROM Arbre a
    WHERE a.arbre = arbre_conv(s.arbre)
  )
ON CONFLICT DO NOTHING;

-- ================================
--  PLACETTE_DOMINANT_BASE : REJETS
-- ================================
WITH src AS (
  SELECT
    m.*,
    to_jsonb(m) AS ligne_raw,
    COALESCE(zone_verif(m.zone), false)         AS ok_zone,
    COALESCE(placette_verif(m.plac), false)     AS ok_placette,
    COALESCE(arbre_verif(m.arbre), false)       AS ok_arbre,
    COALESCE(m.rang BETWEEN 1 AND 3, false)     AS ok_rang,
    COALESCE(zone_conv(m.zone) IS NOT NULL, false)     AS ok_zone_conv,
    COALESCE(placette_conv(m.plac) IS NOT NULL, false) AS ok_plac_conv,
    COALESCE(arbre_conv(m.arbre) IS NOT NULL, false)   AS ok_arbre_conv,
    EXISTS (
      SELECT 1 FROM Placette p
      WHERE p.zone = zone_conv(m.zone)
        AND p.plac = placette_conv(m.plac)
    ) AS ok_fk_placette,
    EXISTS (
      SELECT 1 FROM Arbre a
      WHERE a.arbre = arbre_conv(m.arbre)
    ) AS ok_fk_arbre
  FROM "Staging".megantic m
  WHERE m.rang IS NOT NULL
)
INSERT INTO Rejets (flux, motif, details, ligne, attributs)
SELECT
  'PLACETTE_DOMINANT_BASE' AS flux,
  COALESCE(
    concat_ws(
      ', ',
      CASE WHEN NOT ok_zone       THEN 'Zone invalide' END,
      CASE WHEN NOT ok_placette   THEN 'Placette invalide' END,
      CASE WHEN NOT ok_arbre      THEN 'Arbre invalide' END,
      CASE WHEN NOT ok_rang       THEN 'Rang invalide (1..3)' END,
      CASE WHEN NOT ok_zone_conv  THEN 'Conversion zone NULL' END,
      CASE WHEN NOT ok_plac_conv  THEN 'Conversion placette NULL' END,
      CASE WHEN NOT ok_arbre_conv THEN 'Conversion arbre NULL' END,
      CASE WHEN NOT ok_fk_placette THEN 'Placette inexistante (FK)' END,
      CASE WHEN NOT ok_fk_arbre    THEN 'Arbre inexistant (FK)' END
    ),
    'Rejet sans motif identifié'
  ) AS motif,
  'Megantic_ELT - PLACETTE_DOMINANT_BASE' AS details,
  ligne_raw AS ligne,
  concat_ws(
    ', ',
    CASE WHEN NOT ok_zone
      THEN format('zone=%s', zone) END,
    CASE WHEN NOT ok_placette
      THEN format('plac=%s', plac) END,
    CASE WHEN NOT ok_arbre
      THEN format('arbre=%s', arbre) END,
    CASE WHEN NOT ok_rang
      THEN format('rang=%s', rang) END,
    CASE WHEN NOT ok_zone_conv
      THEN format('zone(conv)=%s', zone) END,
    CASE WHEN NOT ok_plac_conv
      THEN format('plac(conv)=%s', plac) END,
    CASE WHEN NOT ok_arbre_conv
      THEN format('arbre(conv)=%s', arbre) END,
    CASE WHEN NOT ok_fk_placette
      THEN format('fk_placette(zone,plac)=%s,%s', zone, plac) END,
    CASE WHEN NOT ok_fk_arbre
      THEN format('fk_arbre=%s', arbre) END
  ) AS attributs
FROM src
WHERE NOT (
  ok_zone AND ok_placette AND ok_arbre AND ok_rang
  AND ok_zone_conv AND ok_plac_conv AND ok_arbre_conv
  AND ok_fk_placette AND ok_fk_arbre
);

-- ===================================
--  PLACETTE_OBSTRUCTION_BASE : INSERT
-- ===================================
WITH src AS (
  SELECT DISTINCT
    zone,
    plac,
    nature,
    hauteur,
    tcat,
    tval
  FROM "Staging".megantic
  WHERE nature IS NOT NULL
    AND hauteur IS NOT NULL
),
src2 AS (
  SELECT
    s.*,
    t.tMin AS tmin,
    t.tMax AS tmax
  FROM src s
  LEFT JOIN Taux t
    ON t.tCat::text = s.tcat
)
INSERT INTO Placette_Obstruction (zone, plac, nature, hauteur, tcat, tval)
SELECT
  zone_conv(s.zone),
  placette_conv(s.plac),
  ObstructionNature_conv(s.nature),
  HauteurObs_conv(s.hauteur),
  TCat_conv(s.tcat),
  s.tval::Taux_val
FROM src2 s
WHERE
  zone_verif(s.zone)
  AND placette_verif(s.plac)
  AND ObstructionNature_verif(s.nature)
  AND HauteurObs_verif(s.hauteur)
  AND TCat_verif(s.tcat)
  AND s.tval BETWEEN 0 AND 100
  AND s.tmin IS NOT NULL
  AND s.tmax IS NOT NULL
  AND s.tval BETWEEN s.tmin AND s.tmax
  AND zone_conv(s.zone) IS NOT NULL
  AND placette_conv(s.plac) IS NOT NULL
  AND ObstructionNature_conv(s.nature) IS NOT NULL
  AND HauteurObs_conv(s.hauteur) IS NOT NULL
  AND TCat_conv(s.tcat) IS NOT NULL
  AND EXISTS (
      SELECT 1 FROM Placette p
      WHERE p.zone = zone_conv(s.zone)
        AND p.plac = placette_conv(s.plac)
  )
  AND EXISTS (
      SELECT 1 FROM Taux t2
      WHERE t2.tCat = TCat_conv(s.tcat)
  )
ON CONFLICT (zone, plac, nature, hauteur) DO NOTHING;


-- =====================================
--  PLACETTE_OBSTRUCTION_BASE : REJETS
-- =====================================
WITH src AS (
  SELECT
    m.*,
    to_jsonb(m) AS ligne_raw,
    t.tMin AS tmin,
    t.tMax AS tmax,

    COALESCE(zone_verif(m.zone), false)                AS ok_zone,
    COALESCE(placette_verif(m.plac), false)            AS ok_placette,
    COALESCE(ObstructionNature_verif(m.nature), false) AS ok_nature,
    COALESCE(HauteurObs_verif(m.hauteur), false)       AS ok_hauteur,
    COALESCE(TCat_verif(m.tcat), false)                AS ok_tcat,
    (m.tval BETWEEN 0 AND 100)                         AS ok_tval,

    ( t.tMin IS NOT NULL
      AND t.tMax IS NOT NULL
      AND m.tval BETWEEN t.tMin AND t.tMax
    )                                                  AS ok_tval_bounds,

    COALESCE(zone_conv(m.zone) IS NOT NULL, false)                AS ok_zone_conv,
    COALESCE(placette_conv(m.plac) IS NOT NULL, false)            AS ok_plac_conv,
    COALESCE(ObstructionNature_conv(m.nature) IS NOT NULL, false) AS ok_nature_conv,
    COALESCE(HauteurObs_conv(m.hauteur) IS NOT NULL, false)       AS ok_hauteur_conv,
    COALESCE(TCat_conv(m.tcat) IS NOT NULL, false)                AS ok_tcat_conv,

    EXISTS (
      SELECT 1 FROM Placette p
      WHERE p.zone = zone_conv(m.zone)
        AND p.plac = placette_conv(m.plac)
    ) AS ok_fk_placette,
    EXISTS (
      SELECT 1 FROM Taux t2
      WHERE t2.tCat = TCat_conv(m.tcat)
    ) AS ok_fk_taux

  FROM "Staging".megantic m
  LEFT JOIN Taux t ON t.tCat::text = m.tcat
  WHERE m.nature IS NOT NULL
    AND m.hauteur IS NOT NULL
)
INSERT INTO Rejets (flux, motif, details, ligne, attributs)
SELECT
  'PLACETTE_OBSTRUCTION_BASE',
  COALESCE(
    concat_ws(
      ', ',
      CASE WHEN NOT ok_zone         THEN 'Zone invalide' END,
      CASE WHEN NOT ok_placette     THEN 'Placette invalide' END,
      CASE WHEN NOT ok_nature       THEN 'Nature invalide' END,
      CASE WHEN NOT ok_hauteur      THEN 'Hauteur invalide' END,
      CASE WHEN NOT ok_tcat         THEN 'Catégorie taux invalide' END,
      CASE WHEN NOT ok_tval         THEN 'tVal hors [0..100]' END,
      CASE WHEN NOT ok_tval_bounds  THEN format('tVal hors intervalle [%s-%s]', tmin, tmax) END,
      CASE WHEN NOT ok_zone_conv    THEN 'Conversion zone NULL' END,
      CASE WHEN NOT ok_plac_conv    THEN 'Conversion placette NULL' END,
      CASE WHEN NOT ok_nature_conv  THEN 'Conversion nature NULL' END,
      CASE WHEN NOT ok_hauteur_conv THEN 'Conversion hauteur NULL' END,
      CASE WHEN NOT ok_tcat_conv    THEN 'Conversion tCat NULL' END,
      CASE WHEN NOT ok_fk_placette  THEN 'Placette inexistante (FK)' END,
      CASE WHEN NOT ok_fk_taux      THEN 'Taux inexistant (FK)' END
    ),
    'Rejet sans motif identifié'
  ),
  'Megantic_ELT - PLACETTE_OBSTRUCTION_BASE',
  ligne_raw,
  concat_ws(
    ', ',
    format('zone=%s', zone),
    format('plac=%s', plac),
    format('nature=%s', nature),
    format('hauteur=%s', hauteur),
    format('tcat=%s', tcat),
    format('tval=%s', tval),
    CASE WHEN tmin IS NOT NULL THEN format('tmin=%s', tmin) END,
    CASE WHEN tmax IS NOT NULL THEN format('tmax=%s', tmax) END
  ) AS attributs
FROM src
WHERE NOT (
  ok_zone AND ok_placette AND ok_nature AND ok_hauteur
  AND ok_tcat AND ok_tval AND ok_tval_bounds
  AND ok_zone_conv AND ok_plac_conv AND ok_nature_conv AND ok_hauteur_conv AND ok_tcat_conv
  AND ok_fk_placette AND ok_fk_taux
);

end;
$$;