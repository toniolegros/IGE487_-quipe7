SET SCHEMA 'Herbivorie';

CREATE OR REPLACE PROCEDURE ELT_Meteo()
LANGUAGE plpgsql
AS $$
BEGIN


    /* =====================================================================
       1) STRUCTURES DE BASE : SITE et ZONE à partir des CSV météo
       ===================================================================== */

    -------------------------------------------------------------------
    -- 1.1 Sites depuis tous les fichiers météo
    -------------------------------------------------------------------
    INSERT INTO Site (id, site, description)
    SELECT DISTINCT
        site_conv(s.siteid)                         AS id,
        site_conv(s.siteid)                         AS site,
        description_conv('Site importé (météo)')    AS description
    FROM (
        SELECT siteid FROM ige487_68.obstemperature
        UNION
        SELECT siteid FROM ige487_68.obshumidite
        UNION
        SELECT siteid FROM ige487_68.obsprecipitation
        UNION
        SELECT siteid FROM ige487_68.obspression
        UNION
        SELECT siteid FROM ige487_68.obsvents
    ) AS s
    WHERE site_verif(s.siteid)
    ON CONFLICT DO NOTHING;


    -------------------------------------------------------------------
    -- 1.2 Zones depuis tous les fichiers météo
    -------------------------------------------------------------------
    INSERT INTO Zone (id, zone, description)
    SELECT DISTINCT
        site_conv(s.siteid)                         AS id,
        zone_conv(s.zoneid)                         AS zone,
        description_conv('Zone importée (météo)')   AS description
    FROM (
        SELECT siteid, zoneid FROM ige487_68.obstemperature
        UNION
        SELECT siteid, zoneid FROM ige487_68.obshumidite
        UNION
        SELECT siteid, zoneid FROM ige487_68.obsprecipitation
        UNION
        SELECT siteid, zoneid FROM ige487_68.obspression
        UNION
        SELECT siteid, zoneid FROM ige487_68.obsvents
    ) AS s
    WHERE site_verif(s.siteid)
      AND zone_verif(s.zoneid)
    ON CONFLICT DO NOTHING;



    /* =====================================================================
       2) TEMPERATURE : obstemperature.csv -> ObsTemperature
       ===================================================================== */

    -------------------------------------------------------------------
    -- 2.1 Rejets température
    -------------------------------------------------------------------
    WITH src AS (
        SELECT
            t.*,
            to_jsonb(t) AS ligne_raw,
            ROUND(CAST(t.temperature AS numeric))::text AS tmin_norm,
            ROUND(CAST(t.temperature AS numeric))::text AS tmax_norm,
            site_verif(t.siteid)                         AS ok_site,
            zone_verif(t.zoneid)                         AS ok_zone,
            DateEco_verif(t.date)                        AS ok_date,
            Temperature_verif(ROUND(CAST(t.temperature AS numeric))::text) AS ok_tmin,
            Temperature_verif(ROUND(CAST(t.temperature AS numeric))::text) AS ok_tmax
        FROM ige487_68.obstemperature t
    )
    INSERT INTO Rejets(flux, motif, details, ligne, attributs)
    SELECT
        'METEO_TEMPERATURE' AS flux,
        COALESCE(
            concat_ws(
                ', ',
                CASE WHEN NOT ok_site THEN 'Site invalide' END,
                CASE WHEN NOT ok_zone THEN 'Zone invalide' END,
                CASE WHEN NOT ok_date THEN 'Date invalide' END,
                CASE WHEN NOT ok_tmin THEN 'Température invalide' END,
                CASE WHEN NOT ok_tmax THEN 'Température invalide' END
            ),
            'Rejet sans motif identifié'
        ) AS motif,
        'Meteo_ELT - TEMPERATURE' AS details,
        ligne_raw                                   AS ligne,
        concat_ws(
            ', ',
            format('siteid=%s', siteid),
            format('zoneid=%s', zoneid),
            format('date=%s', date),
            format('temperature=%s', temperature),
            format('note=%s', note)
        ) AS attributs
    FROM src
    WHERE NOT (
        ok_site
        AND ok_zone
        AND ok_date
        AND ok_tmin
        AND ok_tmax
    );

    -------------------------------------------------------------------
    -- 2.2 ObsTemperature valides
    -------------------------------------------------------------------
    WITH src AS (
        SELECT
            t.*,
            ROUND(CAST(t.temperature AS numeric))::text AS tmin_norm,
            ROUND(CAST(t.temperature AS numeric))::text AS tmax_norm,
            site_verif(t.siteid)                         AS ok_site,
            zone_verif(t.zoneid)                         AS ok_zone,
            DateEco_verif(t.date)                        AS ok_date,
            Temperature_verif(ROUND(CAST(t.temperature AS numeric))::text) AS ok_tmin,
            Temperature_verif(ROUND(CAST(t.temperature AS numeric))::text) AS ok_tmax
        FROM ige487_68.obstemperature t
    )
    INSERT INTO ObsTemperature(id, zone, date, temp_min, temp_max, note)
    SELECT
        site_conv(siteid)                          AS id,
        zone_conv(zoneid)                          AS zone,
        DateEco_conv(date)                         AS date,
        Temperature_conv(tmin_norm)                AS temp_min,
        Temperature_conv(tmax_norm)                AS temp_max,
        COALESCE(note, '')                         AS note
    FROM src
    WHERE
        ok_site
        AND ok_zone
        AND ok_date
        AND ok_tmin
        AND ok_tmax
    ON CONFLICT (id, zone, date) DO NOTHING;


    /* =====================================================================
       3) HUMIDITE : obshumidite.csv -> ObsHumidite
       ===================================================================== */

    -------------------------------------------------------------------
    -- 3.1 Rejets humidité
    -------------------------------------------------------------------
    WITH src AS (
        SELECT
            t.*,
            to_jsonb(t) AS ligne_raw,
            ROUND(CAST(t.humidite AS numeric))::text AS hmin_norm,
            ROUND(CAST(t.humidite AS numeric))::text AS hmax_norm,
            site_verif(t.siteid)                        AS ok_site,
            zone_verif(t.zoneid)                        AS ok_zone,
            DateEco_verif(t.date)                       AS ok_date,
            Humidite_verif(ROUND(CAST(t.humidite AS numeric))::text) AS ok_hmin,
            Humidite_verif(ROUND(CAST(t.humidite AS numeric))::text) AS ok_hmax
        FROM ige487_68.obshumidite t
    )
    INSERT INTO Rejets(flux, motif, details, ligne, attributs)
    SELECT
        'METEO_HUMIDITE' AS flux,
        COALESCE(
            concat_ws(
                ', ',
                CASE WHEN NOT ok_site THEN 'Site invalide' END,
                CASE WHEN NOT ok_zone THEN 'Zone invalide' END,
                CASE WHEN NOT ok_date THEN 'Date invalide' END,
                CASE WHEN NOT ok_hmin THEN 'Humidité invalide' END,
                CASE WHEN NOT ok_hmax THEN 'Humidité invalide' END
            ),
            'Rejet sans motif identifié'
        ),
        'Meteo_ELT - HUMIDITE',
        ligne_raw,
        concat_ws(
            ', ',
            format('siteid=%s', siteid),
            format('zoneid=%s', zoneid),
            format('date=%s', date),
            format('humidite=%s', humidite),
            format('note=%s', note)
        )
    FROM src
    WHERE NOT (
        ok_site
        AND ok_zone
        AND ok_date
        AND ok_hmin
        AND ok_hmax
    );

    -------------------------------------------------------------------
    -- 3.2 ObsHumidite valides
    -------------------------------------------------------------------
    WITH src AS (
        SELECT
            t.*,
            ROUND(CAST(t.humidite AS numeric))::text AS hmin_norm,
            ROUND(CAST(t.humidite AS numeric))::text AS hmax_norm,
            site_verif(t.siteid)                        AS ok_site,
            zone_verif(t.zoneid)                        AS ok_zone,
            DateEco_verif(t.date)                       AS ok_date,
            Humidite_verif(ROUND(CAST(t.humidite AS numeric))::text) AS ok_hmin,
            Humidite_verif(ROUND(CAST(t.humidite AS numeric))::text) AS ok_hmax
        FROM ige487_68.obshumidite t
    )
    INSERT INTO ObsHumidite(id, zone, date, hum_min, hum_max, note)
    SELECT
        site_conv(siteid),
        zone_conv(zoneid),
        DateEco_conv(date),
        Humidite_conv(hmin_norm),
        Humidite_conv(hmax_norm),
        COALESCE(note, '')
    FROM src
    WHERE
        ok_site
        AND ok_zone
        AND ok_date
        AND ok_hmin
        AND ok_hmax
    ON CONFLICT (id, zone, date) DO NOTHING;



    /* =====================================================================
       4) PRESSION : obspression.csv -> ObsPression
       ===================================================================== */

    -------------------------------------------------------------------
    -- 4.1 Rejets pression
    -------------------------------------------------------------------
    WITH src AS (
        SELECT
            t.*,
            to_jsonb(t) AS ligne_raw,
            ROUND(CAST(t.pression AS numeric))::text AS pmin_norm,
            ROUND(CAST(t.pression AS numeric))::text AS pmax_norm,
            site_verif(t.siteid)                        AS ok_site,
            zone_verif(t.zoneid)                        AS ok_zone,
            DateEco_verif(t.date)                       AS ok_date,
            Pression_verif(ROUND(CAST(t.pression AS numeric))::text) AS ok_pmin,
            Pression_verif(ROUND(CAST(t.pression AS numeric))::text) AS ok_pmax
        FROM ige487_68.obspression t
    )
    INSERT INTO Rejets(flux, motif, details, ligne, attributs)
    SELECT
        'METEO_PRESSION' AS flux,
        COALESCE(
            concat_ws(
                ', ',
                CASE WHEN NOT ok_site THEN 'Site invalide' END,
                CASE WHEN NOT ok_zone THEN 'Zone invalide' END,
                CASE WHEN NOT ok_date THEN 'Date invalide' END,
                CASE WHEN NOT ok_pmin THEN 'Pression invalide' END,
                CASE WHEN NOT ok_pmax THEN 'Pression invalide' END
            ),
            'Rejet sans motif identifié'
        ),
        'Meteo_ELT - PRESSION',
        ligne_raw,
        concat_ws(
            ', ',
            format('siteid=%s', siteid),
            format('zoneid=%s', zoneid),
            format('date=%s', date),
            format('pression=%s', pression),
            format('note=%s', note)
        )
    FROM src
    WHERE NOT (
        ok_site
        AND ok_zone
        AND ok_date
        AND ok_pmin
        AND ok_pmax
    );

    -------------------------------------------------------------------
    -- 4.2 ObsPression valides
    -------------------------------------------------------------------
    WITH src AS (
        SELECT
            t.*,
            ROUND(CAST(t.pression AS numeric))::text AS pmin_norm,
            ROUND(CAST(t.pression AS numeric))::text AS pmax_norm,
            site_verif(t.siteid)                        AS ok_site,
            zone_verif(t.zoneid)                        AS ok_zone,
            DateEco_verif(t.date)                       AS ok_date,
            Pression_verif(ROUND(CAST(t.pression AS numeric))::text) AS ok_pmin,
            Pression_verif(ROUND(CAST(t.pression AS numeric))::text) AS ok_pmax
        FROM ige487_68.obspression t
    )
    INSERT INTO ObsPression(id, zone, date, pres_min, pres_max, note)
    SELECT
        site_conv(siteid),
        zone_conv(zoneid),
        DateEco_conv(date),
        Pression_conv(pmin_norm),
        Pression_conv(pmax_norm),
        COALESCE(note, '')
    FROM src
    WHERE
        ok_site
        AND ok_zone
        AND ok_date
        AND ok_pmin
        AND ok_pmax
    ON CONFLICT (id, zone, date) DO NOTHING;


    /* =====================================================================
       5) PRECIPITATIONS : obsprecipitation.csv -> ObsPrecipitations
       ===================================================================== */

    -------------------------------------------------------------------
    -- 5.1 Rejets précipitations
    -------------------------------------------------------------------
    WITH src AS (
        SELECT
            t.*,
            to_jsonb(t) AS ligne_raw,
            ROUND(CAST(t.precipitation AS numeric))::text AS ptot_norm,
            site_verif(t.siteid)                                AS ok_site,
            zone_verif(t.zoneid)                                AS ok_zone,
            DateEco_verif(t.date)                               AS ok_date,
            HNP_verif(ROUND(CAST(t.precipitation AS numeric))::text) AS ok_ptot
        FROM ige487_68.obsprecipitation t
    )
    INSERT INTO Rejets(flux, motif, details, ligne, attributs)
    SELECT
        'METEO_PRECIPITATIONS' AS flux,
        COALESCE(
            concat_ws(
                ', ',
                CASE WHEN NOT ok_site THEN 'Site invalide' END,
                CASE WHEN NOT ok_zone THEN 'Zone invalide' END,
                CASE WHEN NOT ok_date THEN 'Date invalide' END,
                CASE WHEN NOT ok_ptot THEN 'Précipitation totale invalide' END
            ),
            'Rejet sans motif identifié'
        ),
        'Meteo_ELT - PRECIPITATIONS',
        ligne_raw,
        concat_ws(
            ', ',
            format('siteid=%s', siteid),
            format('zoneid=%s', zoneid),
            format('date=%s', date),
            format('precipitationtotale=%s', precipitation),
            format('note=%s', note)
        )
    FROM src
    WHERE NOT (
        ok_site
        AND ok_zone
        AND ok_date
        AND ok_ptot
    );

    -------------------------------------------------------------------
    -- 5.2 ObsPrecipitations valides
    -------------------------------------------------------------------
    WITH src AS (
        SELECT
            t.*,
            ROUND(CAST(t.precipitation AS numeric))::text AS ptot_norm,
            site_verif(t.siteid)                                AS ok_site,
            zone_verif(t.zoneid)                                AS ok_zone,
            DateEco_verif(t.date)                               AS ok_date,
            HNP_verif(ROUND(CAST(t.precipitation AS numeric))::text) AS ok_ptot
        FROM ige487_68.obsprecipitation t
    )
    INSERT INTO ObsPrecipitations(id, zone, date, prec_tot, prec_nat, note)
    SELECT
        site_conv(siteid),
        zone_conv(zoneid),
        DateEco_conv(date),
        HNP_conv(ptot_norm),
        'P',
        COALESCE(note, '')
    FROM src
    WHERE
        ok_site
        AND ok_zone
        AND ok_date
        AND ok_ptot
    ON CONFLICT (id, zone, date, prec_nat) DO NOTHING;



    /* =====================================================================
       6) VENTS : obsvents.csv -> ObsVents
       ===================================================================== */

    -------------------------------------------------------------------
    -- 6.1 Rejets vents
    -------------------------------------------------------------------
    WITH src AS (
        SELECT
            t.*,
            to_jsonb(t) AS ligne_raw,
            ROUND(CAST(t.ventmin AS numeric))::text AS vmin_norm,
            ROUND(CAST(t.ventmax AS numeric))::text AS vmax_norm,
            site_verif(t.siteid)                    AS ok_site,
            zone_verif(t.zoneid)                    AS ok_zone,
            DateEco_verif(t.date)                   AS ok_date,
            Vitesse_verif(ROUND(CAST(t.ventmin AS numeric))::text) AS ok_vmin,
            Vitesse_verif(ROUND(CAST(t.ventmax AS numeric))::text) AS ok_vmax
        FROM ige487_68.obsvents t
    )
    INSERT INTO Rejets(flux, motif, details, ligne, attributs)
    SELECT
        'METEO_VENTS' AS flux,
        COALESCE(
            concat_ws(
                ', ',
                CASE WHEN NOT ok_site THEN 'Site invalide' END,
                CASE WHEN NOT ok_zone THEN 'Zone invalide' END,
                CASE WHEN NOT ok_date THEN 'Date invalide' END,
                CASE WHEN NOT ok_vmin THEN 'Vent invalide' END,
                CASE WHEN NOT ok_vmax THEN 'Vent invalide' END
            ),
            'Rejet sans motif identifié'
        ),
        'Meteo_ELT - VENTS',
        ligne_raw,
        concat_ws(
            ', ',
            format('siteid=%s', siteid),
            format('zoneid=%s', zoneid),
            format('date=%s', date),
            format('vent=%s', ventmin),
            format('vent=%s', ventmax),
            format('note=%s', note)
        )
    FROM src
    WHERE NOT (
        ok_site
        AND ok_zone
        AND ok_date
        AND ok_vmin
        AND ok_vmax
    );

    -------------------------------------------------------------------
    -- 6.2 ObsVents valides
    -------------------------------------------------------------------
    WITH src AS (
        SELECT
            t.*,
            ROUND(CAST(t.ventmin AS numeric))::text AS vmin_norm,
            ROUND(CAST(t.ventmax AS numeric))::text AS vmax_norm,
            site_verif(t.siteid)                    AS ok_site,
            zone_verif(t.zoneid)                    AS ok_zone,
            DateEco_verif(t.date)                   AS ok_date,
            Vitesse_verif(ROUND(CAST(t.ventmin AS numeric))::text) AS ok_vmin,
            Vitesse_verif(ROUND(CAST(t.ventmax AS numeric))::text) AS ok_vmax
        FROM ige487_68.obsvents t
    )
    INSERT INTO ObsVents(id, zone, date, vent_min, vent_max, note)
    SELECT
        site_conv(siteid),
        zone_conv(zoneid),
        DateEco_conv(date),
        Vitesse_conv(vmin_norm),
        Vitesse_conv(vmax_norm),
        COALESCE(note, '')
    FROM src
    WHERE
        ok_site
        AND ok_zone
        AND ok_date
        AND ok_vmin
        AND ok_vmax
    ON CONFLICT (id, zone, date) DO NOTHING;

END;
$$;