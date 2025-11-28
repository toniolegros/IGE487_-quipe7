SET SCHEMA 'Herbivorie';

CREATE OR REPLACE PROCEDURE ELT_carnets63()
LANGUAGE plpgsql
AS $$
BEGIN
    /* ===========================================================
       0 — TABLE DE REJETS
       =========================================================== */

    CREATE TABLE IF NOT EXISTS Rejets (
        rejet_id   BIGSERIAL PRIMARY KEY,
        flux       TEXT NOT NULL,
        motif      TEXT NOT NULL,
        details    TEXT,
        attributs  TEXT,
        ligne      JSONB NOT NULL,
        date_rejet TIMESTAMP NOT NULL DEFAULT now()
    );


    /* ===========================================================
       1 — SITE / ZONE / PLACETTE
       =========================================================== */

    -- SITE
    WITH src AS (
        SELECT DISTINCT site_id
        FROM ige487_63.carnetplacette63
        WHERE site_id IS NOT NULL
    )
    INSERT INTO Site(id, site, description)
    SELECT
        Site_conv(site_id),
        Site_conv(site_id),
        Description_conv('Site du carnet placette 63')
    FROM src
    WHERE Site_verif(site_id)
    ON CONFLICT DO NOTHING;


    -- ZONE
    WITH src AS (
        SELECT DISTINCT site_id, zone_id
        FROM ige487_63.carnetplacette63
        WHERE zone_id IS NOT NULL
    )
    INSERT INTO Zone(id, zone, description)
    SELECT
        Site_conv(site_id),
        Zone_conv(zone_id),
        Description_conv('Zone du carnet placette 63')
    FROM src
    WHERE Site_verif(site_id)
      AND Zone_verif(zone_id)
    ON CONFLICT DO NOTHING;


    -- PLACETTE
    WITH src AS (
        SELECT DISTINCT site_id, zone_id, placette_numero
        FROM ige487_63.carnetplacette63
    )
    INSERT INTO Placette(id, zone, plac)
    SELECT
        Site_conv(site_id),
        Zone_conv(zone_id),
        Placette_conv(placette_numero::text)
    FROM src
    WHERE Site_verif(site_id)
      AND Zone_verif(zone_id)
      AND Placette_verif(placette_numero::text)
    ON CONFLICT DO NOTHING;


    /* ===========================================================
       2 — PEUPLEMENT & PLACETTE CORE
       =========================================================== */

    -- PEUPLEMENT
    WITH src AS (
        SELECT DISTINCT peuplement_id
        FROM ige487_63.carnetplacette63
        WHERE peuplement_id IS NOT NULL
    )
    INSERT INTO Peuplement(peup, description)
    SELECT
        Peuplement_conv(peuplement_id),
        Description_conv('Peuplement carnet placette 63')
    FROM src
    WHERE Peuplement_verif(peuplement_id)
    ON CONFLICT DO NOTHING;


    -- PLACETTE CORE
    WITH src AS (
        SELECT DISTINCT site_id, zone_id, placette_numero,
                        peuplement_id, date_placette
        FROM ige487_63.carnetplacette63
    )
    INSERT INTO Placette_core(id, zone, plac, peup, date)
    SELECT
        Site_conv(site_id),
        Zone_conv(zone_id),
        Placette_conv(placette_numero::text),
        Peuplement_conv(peuplement_id),
        DateEco_conv(date_placette)
    FROM src
    WHERE Site_verif(site_id)
      AND Zone_verif(zone_id)
      AND Placette_verif(placette_numero::text)
      AND Peuplement_verif(peuplement_id)
      AND DateEco_verif(date_placette)
    ON CONFLICT DO NOTHING;


    /* ===========================================================
       3 — ARBRE DOMINANT (blindé)
       =========================================================== */

    WITH src AS (
        SELECT DISTINCT
            site_id,
            zone_id,
            placette_numero,
            rang_arbre,
            arbre_id
        FROM ige487_63.carnetplacette63
        WHERE arbre_id IS NOT NULL
          AND (rang_arbre::text) ~ '^[0-9]+$'
          AND (rang_arbre::int BETWEEN 1 AND 3)
    )
    INSERT INTO Placette_Dominant(id, zone, plac, rang, arbre)
    SELECT
        Site_conv(site_id),
        Zone_conv(zone_id),
        Placette_conv(placette_numero::text),
        rang_arbre::int,
        Arbre_conv(arbre_id)
    FROM src
    WHERE Site_verif(site_id)
      AND Zone_verif(zone_id)
      AND Placette_verif(placette_numero::text)
      AND Arbre_verif(arbre_id)
    ON CONFLICT DO NOTHING;


    /* ===========================================================
       4 — OBSTRUCTION & COUVERTURE (blindé)
       =========================================================== */

    -- OBSTRUCTION
    WITH src AS (
        SELECT DISTINCT
            site_id,
            zone_id,
            placette_numero,
            obstruction_type,
            hauteur,
            taux_obstruction,
            CASE
                WHEN (taux_obstruction::text) ~ '^[0-9]+$'
                THEN taux_obstruction::int
                ELSE NULL
            END AS taux_int
        FROM ige487_63.carnetplacette63
        WHERE obstruction_type IS NOT NULL
    )
    INSERT INTO Placette_Obstruction(id, zone, plac, nature, hauteur, tcat, tval)
    SELECT
        Site_conv(site_id),
        Zone_conv(zone_id),
        Placette_conv(placette_numero::text),
        ObstructionNature_conv(obstruction_type),
        HauteurObs_conv(hauteur::text),
        TCat_conv('F'),
        taux_int
    FROM src
    WHERE Site_verif(site_id)
      AND Zone_verif(zone_id)
      AND Placette_verif(placette_numero::text)
      AND ObstructionNature_verif(obstruction_type)
      AND HauteurObs_verif(hauteur::text)
      AND taux_int IS NOT NULL
      AND taux_int BETWEEN 0 AND 100
    ON CONFLICT DO NOTHING;


    -- COUVERTURE
    WITH src AS (
        SELECT DISTINCT
            site_id,
            zone_id,
            placette_numero,
            couverture_type,
            taux_couverture,
            CASE
                WHEN (taux_couverture::text) ~ '^[0-9]+$'
                THEN taux_couverture::int
                ELSE NULL
            END AS taux_int
        FROM ige487_63.carnetplacette63
        WHERE couverture_type IS NOT NULL
    )
    INSERT INTO Placette_Couvert(id, zone, plac, ctype, tcat, tval)
    SELECT
        Site_conv(site_id),
        Zone_conv(zone_id),
        Placette_conv(placette_numero::text),
        CouvertType_conv(couverture_type),
        TCat_conv('F'),
        taux_int
    FROM src
    WHERE Site_verif(site_id)
      AND Zone_verif(zone_id)
      AND Placette_verif(placette_numero::text)
      AND CouvertType_verif(couverture_type)
      AND taux_int IS NOT NULL
      AND taux_int BETWEEN 0 AND 100
    ON CONFLICT DO NOTHING;


    /* ===========================================================
       5 — PARCELLES & PLANTES
       =========================================================== */

    -- PARCELLE
    WITH src AS (
        SELECT DISTINCT
            site_id,
            zone_id,
            placette_numero,
            parcelle
        FROM ige487_63.carnetplant63
        WHERE parcelle IS NOT NULL
    )
    INSERT INTO Parcelle(id, zone, plac, parcelle)
    SELECT
        Site_conv(site_id),
        Zone_conv(zone_id),
        Placette_conv(placette_numero::text),
        Parcelle_conv(parcelle::text)
    FROM src
    WHERE Site_verif(site_id)
      AND Zone_verif(zone_id)
      AND Placette_verif(placette_numero::text)
      AND Parcelle_verif(parcelle::text)
    ON CONFLICT DO NOTHING;


    -- PLANT
    WITH src AS (
        SELECT DISTINCT
            site_id,
            zone_id,
            placette_numero,
            plant_id,
            date_observation,
            note_plant
        FROM ige487_63.carnetplant63
    )
    INSERT INTO Plant(s_id, zone, id, plac, date, note)
    SELECT
        Site_conv(site_id),
        Zone_conv(zone_id),
        Plant_conv(plant_id::text),
        Placette_conv(placette_numero::text),
        DateEco_conv(date_observation),
        Description_conv(note_plant)
    FROM src
    WHERE Site_verif(site_id)
      AND Zone_verif(zone_id)
      AND Plant_verif(plant_id::text)
      AND Placette_verif(placette_numero::text)
      AND DateEco_verif(date_observation)
      AND Description_verif(note_plant)
    ON CONFLICT DO NOTHING;


    /* ===========================================================
       6 — OBSERVATIONS
       =========================================================== */

    -- DIMENSION
   WITH src AS (
    SELECT
        plant_id,
        date_observation,
        longueur,
        largeur,
        note_observation
    FROM ige487_63.carnetplant63
    WHERE longueur IS NOT NULL
      AND largeur IS NOT NULL
      AND (longueur::text) ~ '^[0-9]+$'
      AND (largeur::text) ~ '^[0-9]+$'
)
INSERT INTO ObsDimension(id, longueur, largeur, date, unite_id, note)
SELECT
    Plant_conv(plant_id::text),
    longueur::int,
    largeur::int,
    DateEco_conv(date_observation),
    1,
    Description_conv(note_observation)
FROM src
WHERE Plant_verif(plant_id::text)
  AND DateEco_verif(date_observation)
  AND Description_verif(note_observation)
ON CONFLICT DO NOTHING;



    -- FLORAISON
WITH src AS (
    SELECT
        plant_id,
        date_observation,
        est_fruit,
        note_observation
    FROM ige487_63.carnetplant63
    WHERE est_fruit IS NOT NULL
)
INSERT INTO ObsFloraison(id, fleur, date, note)
SELECT
    Plant_conv(plant_id::text),
    CASE
        WHEN est_fruit ILIKE 'O' THEN TRUE
        WHEN est_fruit ILIKE '1' THEN TRUE
        WHEN est_fruit ILIKE 'TRUE' THEN TRUE
        ELSE FALSE
    END,
    DateEco_conv(date_observation),
    Description_conv(note_observation)
FROM src
WHERE Plant_verif(plant_id::text)
  AND DateEco_verif(date_observation)
  AND Description_verif(note_observation)
ON CONFLICT DO NOTHING;



    -- ETAT
    WITH src AS (
        SELECT DISTINCT etat_id
        FROM ige487_63.carnetplant63
        WHERE etat_id IS NOT NULL
    )
    INSERT INTO Etat(etat, description)
    SELECT
        Etat_conv(etat_id),
        Description_conv('État carnet plant 63')
    FROM src
    WHERE Etat_verif(etat_id)
    ON CONFLICT DO NOTHING;


    -- OBS ETAT
    WITH src AS (
        SELECT plant_id, date_observation, etat_id, note_observation
        FROM ige487_63.carnetplant63
        WHERE etat_id IS NOT NULL
    )
    INSERT INTO ObsEtat(id, etat, date, note)
    SELECT
        Plant_conv(plant_id::text),
        Etat_conv(etat_id),
        DateEco_conv(date_observation),
        Description_conv(note_observation)
    FROM src
    WHERE Plant_verif(plant_id::text)
      AND Etat_verif(etat_id)
      AND DateEco_verif(date_observation)
      AND Description_verif(note_observation)
    ON CONFLICT DO NOTHING;



    /* ===========================================================
       7 — REJETS PLACETTE (blindé)
       =========================================================== */

    INSERT INTO Rejets(flux, motif, details, attributs, ligne)
    SELECT
        'carnetplacette63',
        'Échec validation placette',
        'Attribut(s) invalide(s)',
        (
            CASE WHEN NOT Site_verif(t.site_id) THEN 'site_id ' ELSE '' END ||
            CASE WHEN NOT Zone_verif(t.zone_id) THEN 'zone_id ' ELSE '' END ||
            CASE WHEN NOT Placette_verif(t.placette_numero::text) THEN 'placette_numero ' ELSE '' END ||
            CASE WHEN t.peuplement_id IS NOT NULL AND NOT Peuplement_verif(t.peuplement_id) THEN 'peuplement_id ' ELSE '' END ||
            CASE WHEN t.date_placette IS NOT NULL AND NOT DateEco_verif(t.date_placette) THEN 'date_placette ' ELSE '' END ||
            CASE WHEN t.obstruction_type IS NOT NULL AND NOT ObstructionNature_verif(t.obstruction_type) THEN 'obstruction_type ' ELSE '' END ||
            CASE WHEN t.hauteur IS NOT NULL AND NOT HauteurObs_verif(t.hauteur::text) THEN 'hauteur ' ELSE '' END ||

            -- TAUX_OBSTRUCTION invalides
            CASE
                WHEN t.taux_obstruction IS NULL THEN ''
                WHEN NOT (t.taux_obstruction::text ~ '^[0-9]+$') THEN 'taux_obstruction '
                WHEN (
                        t.taux_obstruction::text ~ '^[0-9]+$'
                        AND (t.taux_obstruction::int < 0 OR t.taux_obstruction::int > 100)
                     )
                THEN 'taux_obstruction '
                ELSE ''
            END ||

            CASE WHEN t.couverture_type IS NOT NULL AND NOT CouvertType_verif(t.couverture_type) THEN 'couverture_type ' ELSE '' END ||

            -- TAUX_COUVERTURE invalides
            CASE
                WHEN t.taux_couverture IS NULL THEN ''
                WHEN NOT (t.taux_couverture::text ~ '^[0-9]+$') THEN 'taux_couverture '
                WHEN (
                        t.taux_couverture::text ~ '^[0-9]+$'
                        AND (t.taux_couverture::int < 0 OR t.taux_couverture::int > 100)
                     )
                THEN 'taux_couverture '
                ELSE ''
            END ||

            CASE WHEN t.arbre_id IS NOT NULL AND NOT Arbre_verif(t.arbre_id) THEN 'arbre_id ' ELSE '' END ||
            CASE
                WHEN t.rang_arbre IS NULL THEN ''
                WHEN NOT (t.rang_arbre::text ~ '^[0-9]+$') THEN 'rang_arbre '
                WHEN (
                        t.rang_arbre::text ~ '^[0-9]+$'
                        AND (t.rang_arbre::int < 1 OR t.rang_arbre::int > 3)
                     )
                THEN 'rang_arbre '
                ELSE ''
            END
        ),
        to_jsonb(t)
    FROM ige487_63.carnetplacette63 t
    WHERE
           NOT Site_verif(t.site_id)
        OR NOT Zone_verif(t.zone_id)
        OR NOT Placette_verif(t.placette_numero::text)
        OR (t.peuplement_id IS NOT NULL AND NOT Peuplement_verif(t.peuplement_id))
        OR (t.date_placette IS NOT NULL AND NOT DateEco_verif(t.date_placette))
        OR (t.obstruction_type IS NOT NULL AND NOT ObstructionNature_verif(t.obstruction_type))
        OR (t.hauteur IS NOT NULL AND NOT HauteurObs_verif(t.hauteur::text))
        OR (
            t.taux_obstruction IS NOT NULL AND (
                NOT (t.taux_obstruction::text ~ '^[0-9]+$')
                OR (
                    t.taux_obstruction::text ~ '^[0-9]+$'
                    AND (t.taux_obstruction::int < 0 OR t.taux_obstruction::int > 100)
                )
            )
        )
        OR (t.couverture_type IS NOT NULL AND NOT CouvertType_verif(t.couverture_type))
        OR (
            t.taux_couverture IS NOT NULL AND (
                NOT (t.taux_couverture::text ~ '^[0-9]+$')
                OR (
                    t.taux_couverture::text ~ '^[0-9]+$'
                    AND (t.taux_couverture::int < 0 OR t.taux_couverture::int > 100)
                )
            )
        )
        OR (t.arbre_id IS NOT NULL AND NOT Arbre_verif(t.arbre_id))
        OR (
            t.rang_arbre IS NOT NULL AND (
                NOT (t.rang_arbre::text ~ '^[0-9]+$')
                OR (
                    t.rang_arbre::text ~ '^[0-9]+$'
                    AND (t.rang_arbre::int < 1 OR t.rang_arbre::int > 3)
                )
            )
        );


    /* ===========================================================
       8 — REJETS PLANT (blindé)
       =========================================================== */

    INSERT INTO Rejets(flux, motif, details, attributs, ligne)
    SELECT
        'carnetplant63',
        'Échec validation plant',
        'Attribut(s) invalide(s)',
        (
            CASE WHEN NOT Site_verif(p.site_id) THEN 'site_id ' ELSE '' END ||
            CASE WHEN NOT Zone_verif(p.zone_id) THEN 'zone_id ' ELSE '' END ||
            CASE WHEN NOT Placette_verif(p.placette_numero::text) THEN 'placette_numero ' ELSE '' END ||
            CASE WHEN NOT Plant_verif(p.plant_id::text) THEN 'plant_id ' ELSE '' END ||
            CASE WHEN p.date_observation IS NOT NULL AND NOT DateEco_verif(p.date_observation) THEN 'date_observation ' ELSE '' END ||
            CASE WHEN p.note_plant IS NOT NULL AND NOT Description_verif(p.note_plant) THEN 'note_plant ' ELSE '' END ||
            CASE WHEN p.note_observation IS NOT NULL AND NOT Description_verif(p.note_observation) THEN 'note_observation ' ELSE '' END ||

            -- LONGUEUR
            CASE
                WHEN p.longueur IS NULL THEN ''
                WHEN NOT (p.longueur::text ~ '^[0-9]+(\.[0-9]+)?$') THEN 'longueur '
                WHEN (
                        p.longueur::text ~ '^[0-9]+(\.[0-9]+)?$'
                        AND (p.longueur::float < 1 OR p.longueur::float > 999)
                     )
                THEN 'longueur '
                ELSE ''
            END ||

            -- LARGEUR
            CASE
                WHEN p.largeur IS NULL THEN ''
                WHEN NOT (p.largeur::text ~ '^[0-9]+(\.[0-9]+)?$') THEN 'largeur '
                WHEN (
                        p.largeur::text ~ '^[0-9]+(\.[0-9]+)?$'
                        AND (p.largeur::float < 1 OR p.largeur::float > 999)
                     )
                THEN 'largeur '
                ELSE ''
            END ||

            CASE WHEN p.etat_id IS NOT NULL AND NOT Etat_verif(p.etat_id) THEN 'etat_id ' ELSE '' END
        ),
        to_jsonb(p)
    FROM ige487_63.carnetplant63 p
    WHERE
           NOT Site_verif(p.site_id)
        OR NOT Zone_verif(p.zone_id)
        OR NOT Placette_verif(p.placette_numero::text)
        OR NOT Plant_verif(p.plant_id::text)
        OR (p.date_observation IS NOT NULL AND NOT DateEco_verif(p.date_observation))
        OR (p.note_plant IS NOT NULL AND NOT Description_verif(p.note_plant))
        OR (p.note_observation IS NOT NULL AND NOT Description_verif(p.note_observation))
        OR (
            p.longueur IS NOT NULL AND (
                NOT (p.longueur::text ~ '^[0-9]+(\.[0-9]+)?$')
                OR (
                    p.longueur::text ~ '^[0-9]+(\.[0-9]+)?$'
                    AND (p.longueur::float < 1 OR p.longueur::float > 999)
                )
            )
        )
        OR (
            p.largeur IS NOT NULL AND (
                NOT (p.largeur::text ~ '^[0-9]+(\.[0-9]+)?$')
                OR (
                    p.largeur::text ~ '^[0-9]+(\.[0-9]+)?$'
                    AND (p.largeur::float < 1 OR p.largeur::float > 999)
                )
            )
        )
        OR (p.etat_id IS NOT NULL AND NOT Etat_verif(p.etat_id));

END;
$$;
