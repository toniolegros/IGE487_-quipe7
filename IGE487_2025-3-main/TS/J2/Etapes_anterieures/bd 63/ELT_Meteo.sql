SET SCHEMA 'Herbivorie';

CREATE OR REPLACE PROCEDURE ELT_carnet_meteo63()
LANGUAGE plpgsql
AS $$
BEGIN

    /* ================================================================
       0) TABLE REJETS
       ================================================================ */
    CREATE TABLE IF NOT EXISTS Rejets (
        rejet_id   BIGSERIAL PRIMARY KEY,
        flux       TEXT NOT NULL,
        motif      TEXT NOT NULL,
        details    TEXT,
        attributs  TEXT,
        ligne      JSONB NOT NULL,
        date_rejet TIMESTAMP NOT NULL DEFAULT now()
    );



    /* ================================================================
       1) SITES / ZONES
       ================================================================ */

    INSERT INTO Site(id,site,description)
    SELECT DISTINCT
        site_conv(site_id::text),
        site_conv(site_id::text),
        description_conv('Site importé via carnet_meteo63')
    FROM ige487_63.carnet_meteo63
    WHERE site_verif(site_id::text)
    ON CONFLICT DO NOTHING;

    INSERT INTO Zone(id,zone,description)
    SELECT DISTINCT
        site_conv(site_id::text),
        zone_conv(zone_id::text),
        description_conv('Zone importée via carnet_meteo63')
    FROM ige487_63.carnet_meteo63
    WHERE site_verif(site_id::text)
      AND zone_verif(zone_id::text)
    ON CONFLICT DO NOTHING;



    /* ================================================================
       2) TEMPERATURE
       ================================================================ */

    -- 2.1 Rejets
    WITH src AS (
        SELECT
            c.*,
            to_jsonb(c) AS raw,
            site_verif(site_id::text) AS ok_site,
            zone_verif(zone_id::text) AS ok_zone,
            date_eco_verif(date::text) AS ok_date,
            Temperature_verif(temp_min::text) AS ok_tmin,
            Temperature_verif(temp_max::text) AS ok_tmax,
            EXISTS (SELECT 1 FROM Zone z WHERE z.zone = zone_conv(zone_id::text)) AS ok_fk_zone,
            (Temperature_conv(temp_min::text) <= Temperature_conv(temp_max::text)) AS ok_interval
        FROM ige487_63.carnet_meteo63 c
    )
    INSERT INTO Rejets(flux,motif,details,ligne,attributs)
    SELECT
        'CM63_TEMPERATURE',
        concat_ws(', ',
            CASE WHEN NOT ok_site THEN 'site invalide' END,
            CASE WHEN NOT ok_zone THEN 'zone invalide' END,
            CASE WHEN NOT ok_date THEN 'date invalide' END,
            CASE WHEN NOT ok_tmin THEN 'temp_min invalide' END,
            CASE WHEN NOT ok_tmax THEN 'temp_max invalide' END,
            CASE WHEN NOT ok_fk_zone THEN 'zone inconnue' END,
            CASE WHEN NOT ok_interval THEN 'temp_min > temp_max' END
        ),
        'carnet_meteo63 - Temperature',
        raw,
        concat_ws(', ',
            format('site=%s', site_id),
            format('zone=%s', zone_id),
            format('date=%s', date),
            format('temp_min=%s', temp_min),
            format('temp_max=%s', temp_max)
        )
    FROM src
    WHERE NOT (ok_site AND ok_zone AND ok_date AND ok_tmin AND ok_tmax AND ok_fk_zone AND ok_interval);


    -- 2.2 Valides
    WITH src AS (
        SELECT *
        FROM ige487_63.carnet_meteo63 c
        WHERE site_verif(site_id::text)
          AND zone_verif(zone_id::text)
          AND date_eco_verif(date::text)
          AND Temperature_verif(temp_min::text)
          AND Temperature_verif(temp_max::text)
          AND EXISTS (SELECT 1 FROM Zone z WHERE z.zone = zone_conv(zone_id::text))
          AND Temperature_conv(temp_min::text) <= Temperature_conv(temp_max::text)
    )
    INSERT INTO ObsTemperature(id,zone,date,temp_min,temp_max,note)
    SELECT
        site_conv(site_id::text),
        zone_conv(zone_id::text),
        date_eco_conv(date::text),
        Temperature_conv(temp_min::text),
        Temperature_conv(temp_max::text),
        COALESCE(note,'')
    FROM src
    ON CONFLICT DO NOTHING;



    /* ================================================================
       3) HUMIDITE
       ================================================================ */

    WITH rej AS (
        SELECT
            c.*,
            to_jsonb(c) AS raw,
            site_verif(site_id::text) AS ok_site,
            zone_verif(zone_id::text) AS ok_zone,
            date_eco_verif(date::text) AS ok_date,
            Humidite_verif(hum_min::text) AS ok_hmin,
            Humidite_verif(hum_max::text) AS ok_hmax,
            EXISTS (SELECT 1 FROM Zone z WHERE z.zone = zone_conv(zone_id::text)) AS ok_fk_zone,
            Humidite_conv(hum_min::text) <= Humidite_conv(hum_max::text) AS ok_interval
        FROM ige487_63.carnet_meteo63 c
    )
    INSERT INTO Rejets(flux,motif,details,ligne,attributs)
    SELECT
        'CM63_HUMIDITE',
        concat_ws(', ',
            CASE WHEN NOT ok_site THEN 'site invalide' END,
            CASE WHEN NOT ok_zone THEN 'zone invalide' END,
            CASE WHEN NOT ok_date THEN 'date invalide' END,
            CASE WHEN NOT ok_hmin THEN 'hum_min invalide' END,
            CASE WHEN NOT ok_hmax THEN 'hum_max invalide' END,
            CASE WHEN NOT ok_fk_zone THEN 'zone inconnue' END,
            CASE WHEN NOT ok_interval THEN 'hum_min > hum_max' END
        ),
        'carnet_meteo63 - Humidite',
        raw,
        concat_ws(', ',
            format('site=%s', site_id),
            format('zone=%s', zone_id),
            format('date=%s', date),
            format('hum_min=%s', hum_min),
            format('hum_max=%s', hum_max)
        )
    FROM rej
    WHERE NOT (ok_site AND ok_zone AND ok_date AND ok_hmin AND ok_hmax AND ok_fk_zone AND ok_interval);


    WITH val AS (
        SELECT *
        FROM ige487_63.carnet_meteo63 c
        WHERE site_verif(site_id::text)
          AND zone_verif(zone_id::text)
          AND date_eco_verif(date::text)
          AND Humidite_verif(hum_min::text)
          AND Humidite_verif(hum_max::text)
          AND EXISTS (SELECT 1 FROM Zone z WHERE z.zone = zone_conv(zone_id::text))
          AND Humidite_conv(hum_min::text) <= Humidite_conv(hum_max::text)
    )
    INSERT INTO ObsHumidite(id,zone,date,hum_min,hum_max,note)
    SELECT
        site_conv(site_id::text),
        zone_conv(zone_id::text),
        date_eco_conv(date::text),
        Humidite_conv(hum_min::text),
        Humidite_conv(hum_max::text),
        COALESCE(note,'')
    FROM val
    ON CONFLICT DO NOTHING;




    /* ================================================================
       4) PRESSION
       ================================================================ */

    WITH rej AS (
        SELECT
            c.*,
            to_jsonb(c) AS raw,
            site_verif(site_id::text) AS ok_site,
            zone_verif(zone_id::text) AS ok_zone,
            date_eco_verif(date::text) AS ok_date,
            Pression_verif(pres_min::text) AS ok_pmin,
            Pression_verif(pres_max::text) AS ok_pmax,
            EXISTS (SELECT 1 FROM Zone z WHERE z.zone = zone_conv(zone_id::text)) AS ok_fk_zone,
            Pression_conv(pres_min::text) <= Pression_conv(pres_max::text) AS ok_interval
        FROM ige487_63.carnet_meteo63 c
    )
    INSERT INTO Rejets(flux,motif,details,ligne,attributs)
    SELECT
        'CM63_PRESSION',
        concat_ws(', ',
            CASE WHEN NOT ok_site THEN 'site invalide' END,
            CASE WHEN NOT ok_zone THEN 'zone invalide' END,
            CASE WHEN NOT ok_date THEN 'date invalide' END,
            CASE WHEN NOT ok_pmin THEN 'pres_min invalide' END,
            CASE WHEN NOT ok_pmax THEN 'pres_max invalide' END,
            CASE WHEN NOT ok_fk_zone THEN 'zone inconnue' END,
            CASE WHEN NOT ok_interval THEN 'pres_min > pres_max' END
        ),
        'carnet_meteo63 - Pression',
        raw,
        concat_ws(', ',
            format('site=%s', site_id),
            format('zone=%s', zone_id),
            format('date=%s', date),
            format('pres_min=%s', pres_min),
            format('pres_max=%s', pres_max)
        )
    FROM rej
    WHERE NOT (ok_site AND ok_zone AND ok_date AND ok_pmin AND ok_pmax AND ok_fk_zone AND ok_interval);


    WITH val AS (
        SELECT *
        FROM ige487_63.carnet_meteo63 c
        WHERE site_verif(site_id::text)
          AND zone_verif(zone_id::text)
          AND date_eco_verif(date::text)
          AND Pression_verif(pres_min::text)
          AND Pression_verif(pres_max::text)
          AND EXISTS (SELECT 1 FROM Zone z WHERE z.zone = zone_conv(zone_id::text))
          AND Pression_conv(pres_min::text) <= Pression_conv(pres_max::text)
    )
    INSERT INTO ObsPression(id,zone,date,pres_min,pres_max,note)
    SELECT
        site_conv(site_id::text),
        zone_conv(zone_id::text),
        date_eco_conv(date::text),
        Pression_conv(pres_min::text),
        Pression_conv(pres_max::text),
        COALESCE(note,'')
    FROM val
    ON CONFLICT DO NOTHING;




    /* ================================================================
       5) PRECIPITATIONS
       ================================================================ */

    WITH rej AS (
        SELECT
            c.*,
            to_jsonb(c) AS raw,
            site_verif(site_id::text) AS ok_site,
            zone_verif(zone_id::text) AS ok_zone,
            date_eco_verif(date::text) AS ok_date,
            HNP_verif(prec_tot::text) AS ok_ptot,
            Code_P_verif(prec_nat::text) AS ok_pnat,
            EXISTS (SELECT 1 FROM Zone z WHERE z.zone = zone_conv(zone_id::text)) AS ok_fk_zone
        FROM ige487_63.carnet_meteo63 c
    )
    INSERT INTO Rejets(flux,motif,details,ligne,attributs)
    SELECT
        'CM63_PRECIPITATIONS',
        concat_ws(', ',
            CASE WHEN NOT ok_site THEN 'site invalide' END,
            CASE WHEN NOT ok_zone THEN 'zone invalide' END,
            CASE WHEN NOT ok_date THEN 'date invalide' END,
            CASE WHEN NOT ok_ptot THEN 'prec_tot invalide' END,
            CASE WHEN NOT ok_pnat THEN 'prec_nat invalide' END,
            CASE WHEN NOT ok_fk_zone THEN 'zone inconnue' END
        ),
        'carnet_meteo63 - Precipitations',
        raw,
        concat_ws(', ',
            format('site=%s', site_id),
            format('zone=%s', zone_id),
            format('date=%s', date),
            format('prec_tot=%s', prec_tot),
            format('prec_nat=%s', prec_nat)
        )
    FROM rej
    WHERE NOT (ok_site AND ok_zone AND ok_date AND ok_ptot AND ok_pnat AND ok_fk_zone);


    WITH val AS (
        SELECT *
        FROM ige487_63.carnet_meteo63 c
        WHERE site_verif(site_id::text)
          AND zone_verif(zone_id::text)
          AND date_eco_verif(date::text)
          AND HNP_verif(prec_tot::text)
          AND Code_P_verif(prec_nat::text)
          AND EXISTS (SELECT 1 FROM Zone z WHERE z.zone = zone_conv(zone_id::text))
    )
    INSERT INTO ObsPrecipitations(id,zone,date,prec_tot,prec_nat,note)
    SELECT
        site_conv(site_id::text),
        zone_conv(zone_id::text),
        date_eco_conv(date::text),
        HNP_conv(prec_tot::text),
        Code_P_conv(prec_nat::text),
        COALESCE(note,'')
    FROM val
    ON CONFLICT DO NOTHING;




    /* ================================================================
       6) VENTS
       ================================================================ */

    WITH rej AS (
        SELECT
            c.*,
            to_jsonb(c) AS raw,
            site_verif(site_id::text) AS ok_site,
            zone_verif(zone_id::text) AS ok_zone,
            date_eco_verif(date::text) AS ok_date,
            Vitesse_verif(vent_min::text) AS ok_vmin,
            Vitesse_verif(vent_max::text) AS ok_vmax,
            EXISTS (SELECT 1 FROM Zone z WHERE z.zone = zone_conv(zone_id::text)) AS ok_fk_zone,
            Vitesse_conv(vent_min::text) <= Vitesse_conv(vent_max::text) AS ok_interval
        FROM ige487_63.carnet_meteo63 c
    )
    INSERT INTO Rejets(flux,motif,details,ligne,attributs)
    SELECT
        'CM63_VENTS',
        concat_ws(', ',
            CASE WHEN NOT ok_site THEN 'site invalide' END,
            CASE WHEN NOT ok_zone THEN 'zone invalide' END,
            CASE WHEN NOT ok_date THEN 'date invalide' END,
            CASE WHEN NOT ok_vmin THEN 'vent_min invalide' END,
            CASE WHEN NOT ok_vmax THEN 'vent_max invalide' END,
            CASE WHEN NOT ok_fk_zone THEN 'zone inconnue' END,
            CASE WHEN NOT ok_interval THEN 'vent_min > vent_max' END
        ),
        'carnet_meteo63 - Vents',
        raw,
        concat_ws(', ',
            format('site=%s', site_id),
            format('zone=%s', zone_id),
            format('date=%s', date),
            format('vent_min=%s', vent_min),
            format('vent_max=%s', vent_max)
        )
    FROM rej
    WHERE NOT (ok_site AND ok_zone AND ok_date AND ok_vmin AND ok_vmax AND ok_fk_zone AND ok_interval);


    WITH val AS (
        SELECT *
        FROM ige487_63.carnet_meteo63 c
        WHERE site_verif(site_id::text)
          AND zone_verif(zone_id::text)
          AND date_eco_verif(date::text)
          AND Vitesse_verif(vent_min::text)
          AND Vitesse_verif(vent_max::text)
          AND EXISTS (SELECT 1 FROM Zone z WHERE z.zone = zone_conv(zone_id::text))
          AND Vitesse_conv(vent_min::text) <= Vitesse_conv(vent_max::text)
    )
    INSERT INTO ObsVents(id,zone,date,vent_min,vent_max,note)
    SELECT
        site_conv(site_id::text),
        zone_conv(zone_id::text),
        date_eco_conv(date::text),
        Vitesse_conv(vent_min::text),
        Vitesse_conv(vent_max::text),
        COALESCE(note,'')
    FROM val
    ON CONFLICT DO NOTHING;


END;
$$;
