SET SCHEMA 'Herbivorie';

CREATE OR REPLACE PROCEDURE ETL_Herbivorie()
LANGUAGE plpgsql
AS $$
BEGIN
    ------------------------------------------------------------------
    -- 0) TABLE DE REJETS UNIQUE
    ------------------------------------------------------------------
    CREATE TABLE IF NOT EXISTS Rejets (
        rejet_id   BIGSERIAL PRIMARY KEY,
        flux       TEXT NOT NULL,
        motif      TEXT NOT NULL,
        details    TEXT,
        attributs  TEXT,
        ligne      JSONB NOT NULL,
        date_rejet TIMESTAMP NOT NULL DEFAULT now()
    );

    /* ==============================================================
       1) DONNÉES STRUCTURELLES : SITE / ZONE / PLACETTE / PARCELLE
       ============================================================== */

    ------------------------------
    -- SITE
    ------------------------------
    WITH src AS (
        SELECT DISTINCT siteid
        FROM ige487_68.site
        WHERE siteid IS NOT NULL
    )
    INSERT INTO Site(id, site, description)
    SELECT
        site_conv(siteid)                      AS id,
        description_conv(siteid)               AS site,
        description_conv('Site issu des CSV')  AS description
    FROM src
    WHERE site_verif(siteid)
    ON CONFLICT DO NOTHING;


    ------------------------------
    -- ZONE
    ------------------------------
    WITH src AS (
        SELECT DISTINCT siteid, zoneid
        FROM ige487_68.zone
        WHERE zoneid IS NOT NULL
    )
    INSERT INTO Zone(id, zone, description)
    SELECT
        site_conv(siteid)                      AS id,
        zone_conv(zoneid)                      AS zone,
        description_conv('Zone issue des CSV') AS description
    FROM src
    WHERE site_verif(siteid)
      AND zone_verif(zoneid)
    ON CONFLICT DO NOTHING;


    ------------------------------
    -- PLACETTE
    ------------------------------
    WITH src AS (
        SELECT DISTINCT siteid, zoneid, placetteid
        FROM ige487_68.placette
        WHERE placetteid IS NOT NULL
    )
    INSERT INTO Placette(id, zone, plac)
    SELECT
        site_conv(siteid),
        zone_conv(zoneid),
        placette_conv(placetteid)
    FROM src
    WHERE site_verif(siteid)
      AND zone_verif(zoneid)
      AND placette_verif(placetteid)
    ON CONFLICT DO NOTHING;


    ------------------------------
    -- PARCELLE
    ------------------------------
    WITH src AS (
        SELECT DISTINCT siteid, zoneid, placetteid, parcelleid
        FROM ige487_68.parcelle
        WHERE parcelleid IS NOT NULL
    )
    INSERT INTO Parcelle(id, zone, plac, parcelle)
    SELECT
        site_conv(siteid),
        zone_conv(zoneid),
        placette_conv(placetteid),
        parcelle_conv(parcelleid)
    FROM src
    WHERE site_verif(siteid)
      AND zone_verif(zoneid)
      AND placette_verif(placetteid)
      AND parcelle_verif(parcelleid)
    ON CONFLICT DO NOTHING;



   /* ==============================================================
   2) PEUPLEMENT / PLACETTE_CORE / ARBRE / DOMINANT
   ============================================================== */


---------------------------------------------------------
-- 2.1 — PEUPLEMENT + REJETS
---------------------------------------------------------

-- Lignes valides
INSERT INTO Peuplement(peup, description)
SELECT
    peuplement_conv(peuplementid),
    description_conv(description)
FROM ige487_68.peuplement s
WHERE peuplementid IS NOT NULL
  AND peuplement_verif(peuplementid)
  AND description_verif(description)
ON CONFLICT DO NOTHING;

-- Rejets
INSERT INTO Rejets(flux, motif, details, attributs, ligne)
SELECT
    'peuplement' AS flux,
    CASE
        WHEN peuplementid IS NULL THEN 'peuplementid NULL'
        WHEN NOT peuplement_verif(peuplementid) THEN 'peuplementid invalide'
        WHEN NOT description_verif(description) THEN 'description invalide'
        ELSE 'règle non spécifiée'
    END AS motif,
    NULL::text AS details,
    CONCAT('peuplementid=', COALESCE(peuplementid,'')) AS attributs,
    to_jsonb(s.*) AS ligne
FROM ige487_68.peuplement s
WHERE NOT (
    peuplementid IS NOT NULL
    AND peuplement_verif(peuplementid)
    AND description_verif(description)
);



---------------------------------------------------------
-- 2.2 — PLACETTE_CORE + REJETS
---------------------------------------------------------

-- Valides
INSERT INTO Placette_core(id, zone, plac, peup, date)
SELECT
    site_conv(siteid),
    zone_conv(zoneid),
    placette_conv(placetteid),
    peuplement_conv(peuplementid),
    DateEco_conv(date)
FROM (
    SELECT DISTINCT
        p.siteid,
        p.zoneid,
        p.placetteid,
        p.peuplementid,
        oc.date
    FROM ige487_68.placette p
    JOIN ige487_68.obscouverture oc
      ON oc.siteid     = p.siteid
     AND oc.zoneid     = p.zoneid
     AND oc.placetteid = p.placetteid
) s
WHERE site_verif(siteid)
  AND zone_verif(zoneid)
  AND placette_verif(placetteid)
  AND peuplement_verif(peuplementid)
  AND DateEco_verif(date)
ON CONFLICT DO NOTHING;

-- Rejets
INSERT INTO Rejets(flux, motif, details, attributs, ligne)
SELECT
    'placette_core' AS flux,
    CASE
        WHEN NOT site_verif(siteid) THEN 'site invalide'
        WHEN NOT zone_verif(zoneid) THEN 'zone invalide'
        WHEN NOT placette_verif(placetteid) THEN 'placette invalide'
        WHEN NOT peuplement_verif(peuplementid) THEN 'peuplement invalide'
        WHEN NOT DateEco_verif(date) THEN 'date invalide'
        ELSE 'règle non spécifiée'
    END AS motif,
    NULL::text AS details,
    CONCAT_WS(', ',
        'siteid='||COALESCE(siteid,''),
        'zoneid='||COALESCE(zoneid,''),
        'placetteid='||COALESCE(placetteid,''),
        'peuplementid='||COALESCE(peuplementid,'')
    ) AS attributs,
    to_jsonb(s.*) AS ligne
FROM (
    SELECT DISTINCT
        p.siteid,
        p.zoneid,
        p.placetteid,
        p.peuplementid,
        oc.date
    FROM ige487_68.placette p
    JOIN ige487_68.obscouverture oc
      ON oc.siteid     = p.siteid
     AND oc.zoneid     = p.zoneid
     AND oc.placetteid = p.placetteid
) s
WHERE NOT (
    site_verif(siteid)
    AND zone_verif(zoneid)
    AND placette_verif(placetteid)
    AND peuplement_verif(peuplementid)
    AND DateEco_verif(date)
);




---------------------------------------------------------
-- 2.3 — ARBRE + REJETS
---------------------------------------------------------

-- Valides
INSERT INTO Arbre(arbre, description)
SELECT
    arbre_conv(arbreid),
    description_conv('Arbre issu des observations CSV — site ' || siteid)
FROM ige487_68.obsarbre s
WHERE arbreid IS NOT NULL
  AND site_verif(siteid)
  AND arbre_verif(arbreid)
ON CONFLICT DO NOTHING;

-- Rejets
INSERT INTO Rejets(flux, motif, details, attributs, ligne)
SELECT
    'arbre' AS flux,
    CASE
        WHEN arbreid IS NULL THEN 'arbreid NULL'
        WHEN NOT arbre_verif(arbreid) THEN 'arbreid invalide'
        WHEN NOT site_verif(siteid) THEN 'site invalide'
        ELSE 'règle non spécifiée'
    END AS motif,
    NULL::text AS details,
    CONCAT_WS(', ',
        'siteid='||COALESCE(siteid,''),
        'arbreid='||COALESCE(arbreid,'')
    ) AS attributs,
    to_jsonb(s.*) AS ligne
FROM ige487_68.obsarbre s
WHERE NOT (
    arbreid IS NOT NULL
    AND arbre_verif(arbreid)
    AND site_verif(siteid)
);



---------------------------------------------------------
-- 2.4 — PLACETTE_DOMINANT + REJETS
---------------------------------------------------------

-- Valides
INSERT INTO Placette_Dominant(id, zone, plac, rang, arbre)
SELECT
    site_conv(siteid),
    zone_conv(zoneid),
    placette_conv(placetteid),
    rang,
    arbre_conv(arbreid)
FROM ige487_68.obsarbre s
WHERE arbreid IS NOT NULL
  AND rang BETWEEN 1 AND 3
  AND site_verif(siteid)
  AND zone_verif(zoneid)
  AND placette_verif(placetteid)
  AND arbre_verif(arbreid)
ON CONFLICT DO NOTHING;

-- Rejets
INSERT INTO Rejets(flux, motif, details, attributs, ligne)
SELECT
    'placette_dominant' AS flux,
    CASE
        WHEN arbreid IS NULL THEN 'arbreid NULL'
        WHEN NOT arbre_verif(arbreid) THEN 'arbre invalide'
        WHEN rang NOT BETWEEN 1 AND 3 THEN 'rang invalide'
        WHEN NOT site_verif(siteid) THEN 'site invalide'
        WHEN NOT zone_verif(zoneid) THEN 'zone invalide'
        WHEN NOT placette_verif(placetteid) THEN 'placette invalide'
        ELSE 'règle non spécifiée'
    END AS motif,
    NULL::text AS details,
    CONCAT_WS(', ',
        'siteid='||COALESCE(siteid,''),
        'zoneid='||COALESCE(zoneid,''),
        'placetteid='||COALESCE(placetteid,''),
        'arbreid='||COALESCE(arbreid,''),
        'rang='||COALESCE(rang::text,'')
    ) AS attributs,
    to_jsonb(s.*) AS ligne
FROM ige487_68.obsarbre s
WHERE NOT (
    arbreid IS NOT NULL
    AND arbre_verif(arbreid)
    AND rang BETWEEN 1 AND 3
    AND site_verif(siteid)
    AND zone_verif(zoneid)
    AND placette_verif(placetteid)
);



    /* ==============================================================
       3) PLANT (LOCALISATION) + REJETS
       ============================================================== */

    -- Lignes valides
    INSERT INTO Plant(s_id, zone, id, plac, date, note)
    SELECT
        site_conv(siteid),
        zone_conv(zoneid),
        plant_conv(plantid),
        placette_conv(placetteid),
        DateEco_conv(date),
        description_conv(note)
    FROM ige487_68.obsplantlocalisation s
    WHERE plantid IS NOT NULL
      AND plant_verif(plantid)
      AND site_verif(siteid)
      AND zone_verif(zoneid)
      AND placette_verif(placetteid)
      AND DateEco_verif(date)
      AND description_verif(note)
      AND EXISTS (
            SELECT 1
            FROM Placette pl
            WHERE pl.id   = site_conv(siteid)
              AND pl.zone = zone_conv(zoneid)
              AND pl.plac = placette_conv(placetteid)
      )
    ON CONFLICT DO NOTHING;

    -- Rejets
    INSERT INTO Rejets(flux, motif, details, attributs, ligne)
    SELECT
        'obsplantlocalisation' AS flux,
        CASE
            WHEN plantid IS NULL THEN 'plantid NULL'
            WHEN NOT plant_verif(plantid) THEN 'plantid invalide'
            WHEN NOT site_verif(siteid) THEN 'siteid invalide'
            WHEN NOT zone_verif(zoneid) THEN 'zoneid invalide'
            WHEN NOT placette_verif(placetteid) THEN 'placetteid invalide'
            WHEN NOT DateEco_verif(date) THEN 'date invalide'
            WHEN NOT description_verif(note) THEN 'note invalide'
            WHEN NOT EXISTS (
                    SELECT 1
                    FROM Placette pl
                    WHERE pl.id   = site_conv(siteid)
                      AND pl.zone = zone_conv(zoneid)
                      AND pl.plac = placette_conv(placetteid)
                 )
                 THEN 'placette inexistante (FK)'
            ELSE 'règle non spécifiée'
        END AS motif,
        NULL::text AS details,
        CONCAT_WS(', ',
            'plantid='   || COALESCE(plantid, ''),
            'siteid='    || COALESCE(siteid, ''),
            'zoneid='    || COALESCE(zoneid, ''),
            'placetteid='|| COALESCE(placetteid, '')
        ) AS attributs,
        to_jsonb(s.*) AS ligne
    FROM ige487_68.obsplantlocalisation s
    WHERE plantid IS NULL
       OR NOT plant_verif(plantid)
       OR NOT site_verif(siteid)
       OR NOT zone_verif(zoneid)
       OR NOT placette_verif(placetteid)
       OR NOT DateEco_verif(date)
       OR NOT description_verif(note)
       OR NOT EXISTS (
              SELECT 1
              FROM Placette pl
              WHERE pl.id   = site_conv(siteid)
                AND pl.zone = zone_conv(zoneid)
                AND pl.plac = placette_conv(placetteid)
         );



    /* ==============================================================
       4) OBS DIMENSION + REJETS
       ============================================================== */

    -- Valides
    INSERT INTO ObsDimension(id, longueur, largeur, date, unite_id, note)
    SELECT
        plant_conv(plantid),
        ROUND(longueur)::INTEGER,
        ROUND(largeur)::INTEGER,
        DateEco_conv(date),
        1,
        description_conv(note)
    FROM ige487_68.obsdimension s
    WHERE plant_verif(plantid)
      AND DateEco_verif(date)
      AND longueur BETWEEN 1 AND 999
      AND largeur  BETWEEN 1 AND 999
      AND description_verif(note)
      AND EXISTS (
            SELECT 1
            FROM Plant p
            WHERE p.id = plant_conv(plantid)
      )
    ON CONFLICT DO NOTHING;

    -- Rejets
    INSERT INTO Rejets(flux, motif, details, attributs, ligne)
    SELECT
        'obsdimension' AS flux,
        CASE
            WHEN NOT plant_verif(plantid) THEN 'plantid invalide'
            WHEN NOT DateEco_verif(date) THEN 'date invalide'
            WHEN longueur NOT BETWEEN 1 AND 999
                 OR largeur NOT BETWEEN 1 AND 999
                 THEN 'dimensions hors bornes'
            WHEN NOT description_verif(note) THEN 'note invalide'
            WHEN NOT EXISTS (
                    SELECT 1
                    FROM Plant p
                    WHERE p.id = plant_conv(plantid)
                 )
                 THEN 'plant inexistant (FK)'
            ELSE 'règle non spécifiée'
        END AS motif,
        NULL::text AS details,
        'plantid=' || COALESCE(plantid, '') AS attributs,
        to_jsonb(s.*) AS ligne
    FROM ige487_68.obsdimension s
    WHERE NOT (
        plant_verif(plantid)
        AND DateEco_verif(date)
        AND longueur BETWEEN 1 AND 999
        AND largeur BETWEEN 1 AND 999
        AND description_verif(note)
        AND EXISTS (
            SELECT 1
            FROM Plant p
            WHERE p.id = plant_conv(plantid)
        )
    );



    /* ==============================================================
       5) OBS FLORAISON + REJETS
       ============================================================== */

    -- Valides
    INSERT INTO ObsFloraison(id, fleur, date, note)
    SELECT
        plant_conv(plantid),
        CASE WHEN typefloraison IN ('FL','FR') THEN TRUE ELSE FALSE END,
        DateEco_conv(date),
        description_conv(note)
    FROM ige487_68.obsfloraison s
    WHERE plant_verif(plantid)
      AND DateEco_verif(date)
      AND description_verif(note)
      AND typefloraison IS NOT NULL
      AND typefloraison IN ('FL','FR','NF','NA')
      AND EXISTS (
            SELECT 1
            FROM Plant p
            WHERE p.id = plant_conv(plantid)
      )
    ON CONFLICT DO NOTHING;

    -- Rejets
    INSERT INTO Rejets(flux, motif, details, attributs, ligne)
    SELECT
        'obsfloraison' AS flux,
        CASE
            WHEN NOT plant_verif(plantid) THEN 'plantid invalide'
            WHEN NOT DateEco_verif(date) THEN 'date invalide'
            WHEN NOT description_verif(note) THEN 'note invalide'
            WHEN typefloraison IS NULL THEN 'typefloraison NULL'
            WHEN typefloraison NOT IN ('FL','FR','NF','NA')
                 THEN 'typefloraison inconnu'
            WHEN NOT EXISTS (
                    SELECT 1
                    FROM Plant p
                    WHERE p.id = plant_conv(plantid)
                 )
                 THEN 'plant inexistant (FK)'
            ELSE 'règle non spécifiée'
        END AS motif,
        NULL::text AS details,
        'plantid=' || COALESCE(plantid, '') AS attributs,
        to_jsonb(s.*) AS ligne
    FROM ige487_68.obsfloraison s
    WHERE NOT (
        plant_verif(plantid)
        AND DateEco_verif(date)
        AND description_verif(note)
        AND typefloraison IS NOT NULL
        AND typefloraison IN ('FL','FR','NF','NA')
        AND EXISTS (
            SELECT 1
            FROM Plant p
            WHERE p.id = plant_conv(plantid)
        )
    );



    /* ==============================================================
       6) ETAT (RÉPERTOIRE) + OBS ETAT + REJETS
       ============================================================== */

    -- Répertoire Etat
    WITH src AS (
        SELECT DISTINCT etat
        FROM ige487_68.obsetat
        WHERE etat IS NOT NULL
    )
    INSERT INTO Etat(etat, description)
    SELECT
        etat_conv(etat),
        description_conv('État issu des CSV — ' || etat)
    FROM src
    WHERE etat_verif(etat)
    ON CONFLICT DO NOTHING;


    -- ObsEtat valides
    INSERT INTO ObsEtat(id, etat, date, note)
    SELECT
        plant_conv(plantid),
        etat_conv(etat),
        DateEco_conv(date),
        description_conv(note)
    FROM ige487_68.obsetat s
    WHERE plant_verif(plantid)
      AND etat_verif(etat)
      AND DateEco_verif(date)
      AND description_verif(note)
      AND EXISTS (
            SELECT 1
            FROM Plant p
            WHERE p.id = plant_conv(plantid)
      )
    ON CONFLICT DO NOTHING;

    -- Rejets ObsEtat
    INSERT INTO Rejets(flux, motif, details, attributs, ligne)
    SELECT
        'obsetat' AS flux,
        CASE
            WHEN NOT plant_verif(plantid) THEN 'plantid invalide'
            WHEN NOT etat_verif(etat) THEN 'etat invalide'
            WHEN NOT DateEco_verif(date) THEN 'date invalide'
            WHEN NOT description_verif(note) THEN 'note invalide'
            WHEN NOT EXISTS (
                    SELECT 1
                    FROM Plant p
                    WHERE p.id = plant_conv(plantid)
                 )
                 THEN 'plant inexistant (FK)'
            ELSE 'règle non spécifiée'
        END AS motif,
        NULL::text AS details,
        'plantid=' || COALESCE(plantid, '') AS attributs,
        to_jsonb(s.*) AS ligne
    FROM ige487_68.obsetat s
    WHERE NOT (
        plant_verif(plantid)
        AND etat_verif(etat)
        AND DateEco_verif(date)
        AND description_verif(note)
        AND EXISTS (
            SELECT 1
            FROM Plant p
            WHERE p.id = plant_conv(plantid)
        )
    );



    /* ==============================================================
       7) COUVERT & OBSTRUCTION (PLACETTE)
       ============================================================== */

    ------------------------------
    -- PLACETTE_COUVERT
    ------------------------------
    WITH src AS (
        SELECT siteid, zoneid, placetteid,
               tauxmousses, tauxgraminees, tauxfougeres
        FROM ige487_68.obscouverture
    ),
    unpivot_couv AS (
        SELECT
            siteid,
            zoneid,
            placetteid,
            'mousses'::couvert_type AS ctype,
            ROUND(tauxmousses)::INTEGER AS tval
        FROM src
        UNION ALL
        SELECT
            siteid,
            zoneid,
            placetteid,
            'graminees'::couvert_type,
            ROUND(tauxgraminees)::INTEGER
        FROM src
        UNION ALL
        SELECT
            siteid,
            zoneid,
            placetteid,
            'fougeres'::couvert_type,
            ROUND(tauxfougeres)::INTEGER
        FROM src
    )
    INSERT INTO Placette_Couvert(id, zone, plac, ctype, tcat, tval)
    SELECT
        site_conv(siteid),
        zone_conv(zoneid),
        placette_conv(placetteid),
        ctype,
        t.tCat,
        LEAST(GREATEST(tval,0),100)
    FROM unpivot_couv u
    JOIN Taux t
      ON LEAST(GREATEST(u.tval,0),100) BETWEEN t.tMin AND t.tMax
    WHERE site_verif(siteid)
      AND zone_verif(zoneid)
      AND placette_verif(placetteid)
    ON CONFLICT DO NOTHING;


    ------------------------------
    -- PLACETTE_OBSTRUCTION
    ------------------------------
    WITH src AS (
        SELECT
            siteid,
            zoneid,
            placetteid,
            hauteur,
            AVG(tauxfeuillu)  AS avg_feuillu,
            AVG(tauxconifere) AS avg_conifere
        FROM ige487_68.obsobstruction
        GROUP BY siteid, zoneid, placetteid, hauteur
    ),
    unpivot_obs AS (
        SELECT
            siteid,
            zoneid,
            placetteid,
            hauteur,
            'feuillu'::obstruction_nature AS nature,
            ROUND(avg_feuillu)::INTEGER   AS tval
        FROM src
        UNION ALL
        SELECT
            siteid,
            zoneid,
            placetteid,
            hauteur,
            'coniferien'::obstruction_nature,
            ROUND(avg_conifere)::INTEGER
        FROM src
    )
    INSERT INTO Placette_Obstruction(id, zone, plac, nature, hauteur, tcat, tval)
    SELECT
        site_conv(siteid),
        zone_conv(zoneid),
        placette_conv(placetteid),
        nature,
        CASE WHEN hauteur = 1 THEN '1m'::hauteur_obs ELSE '2m'::hauteur_obs END,
        t.tCat,
        LEAST(GREATEST(tval,0),100)
    FROM unpivot_obs u
    JOIN Taux t
      ON LEAST(GREATEST(tval,0),100) BETWEEN t.tMin AND t.tMax
    WHERE site_verif(siteid)
      AND zone_verif(zoneid)
      AND placette_verif(placetteid)
    ON CONFLICT DO NOTHING;

END;
$$;
