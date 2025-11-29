SET SCHEMA 'Herbivorie';

---------------------------------------------------------------------------
-- SCHEMAS IMM + EMIR
---------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS "Herbivorie_lecture";
CREATE SCHEMA IF NOT EXISTS "Herbivorie_ecriture";



---------------------------------------------------------------------------
-- =========================  IMM — EVA (lecture seule) ===================
---------------------------------------------------------------------------

-- TYPE PRECIPITATIONS
CREATE OR REPLACE FUNCTION "Herbivorie_lecture".typeprecipitations_EVA()
RETURNS TABLE (
    code    Code_P,
    libelle TEXT
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT code, libelle
    FROM "Herbivorie".typeprecipitations;
$$;


-- OBS TEMPERATURE
CREATE OR REPLACE FUNCTION "Herbivorie_lecture".obstemperature_EVA()
RETURNS TABLE (
    id       site_id,
    zone     zone_id,
    date     Date_eco,
    temp_min Temperature,
    temp_max Temperature,
    note     TEXT
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id, zone, date, temp_min, temp_max, note
    FROM "Herbivorie".ObsTemperature;
$$;


-- OBS HUMIDITE
CREATE OR REPLACE FUNCTION "Herbivorie_lecture".obshumidite_EVA()
RETURNS TABLE (
    id      site_id,
    zone    zone_id,
    date    Date_eco,
    hum_min Humidite,
    hum_max Humidite,
    note    TEXT
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id, zone, date, hum_min, hum_max, note
    FROM "Herbivorie".ObsHumidite;
$$;


-- OBS VENTS
CREATE OR REPLACE FUNCTION "Herbivorie_lecture".obsvents_EVA()
RETURNS TABLE (
    id       site_id,
    zone     zone_id,
    date     Date_eco,
    vent_min Vitesse,
    vent_max Vitesse,
    note     TEXT
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id, zone, date, vent_min, vent_max, note
    FROM "Herbivorie".ObsVents;
$$;


-- OBS PRESSION
CREATE OR REPLACE FUNCTION "Herbivorie_lecture".obspression_EVA()
RETURNS TABLE (
    id       site_id,
    zone     zone_id,
    date     Date_eco,
    pres_min Pression,
    pres_max Pression,
    note     TEXT
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id, zone, date, pres_min, pres_max, note
    FROM "Herbivorie".ObsPression;
$$;


-- OBS PRECIPITATIONS
CREATE OR REPLACE FUNCTION "Herbivorie_lecture".obsprecipitations_EVA()
RETURNS TABLE (
    id       site_id,
    zone     zone_id,
    date     Date_eco,
    prec_tot HNP,
    prec_nat Code_P,
    note     TEXT
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id, zone, date, prec_tot, prec_nat, note
    FROM "Herbivorie".ObsPrecipitations;
$$;


-- CARNET METEO (Staging)
CREATE OR REPLACE FUNCTION "Herbivorie_lecture".CarnetMeteo_EVA()
RETURNS TABLE (
    id text,
    zone text,
    temp_min TEXT,
    temp_max TEXT,
    hum_min  TEXT,
    hum_max  TEXT,
    prec_tot TEXT,
    prec_nat TEXT,
    vent_min TEXT,
    vent_max TEXT,
    pres_min TEXT,
    pres_max TEXT,
    date     TEXT,
    note     TEXT
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT *
    FROM "Staging".carnetmeteo;
$$;




---------------------------------------------------------------------------
-- ========================  EMIR — PROCÉDURES ===========================
---------------------------------------------------------------------------

-------------------------------------------
-- TYPE PRECIPITATIONS
-------------------------------------------

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".typeprecipitations_INS(
    _code    Code_P,
    _libelle TEXT
)
BEGIN ATOMIC
    INSERT INTO typeprecipitations (code, libelle)
    VALUES (_code, _libelle);
END;


CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".typeprecipitations_MOD_libelle(
    _code    Code_P,
    _libelle TEXT
)
BEGIN ATOMIC
    UPDATE typeprecipitations
    SET libelle = _libelle
    WHERE code = _code;
END;


CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".typeprecipitations_RET(
    _code Code_P
)
BEGIN ATOMIC
    DELETE FROM typeprecipitations
    WHERE code = _code;
END;



-------------------------------------------
-- OBS TEMPERATURE
-------------------------------------------

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obstemperature_INS(
    _id site_id, _zone zone_id,
    _date Date_eco, _temp_min Temperature,
    _temp_max Temperature, _note TEXT
)
BEGIN ATOMIC
    INSERT INTO ObsTemperature (id, zone, date, temp_min, temp_max, note)
    VALUES (_id, _zone, _date, _temp_min, _temp_max, _note);
END;


CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obstemperature_MOD_temp(
    _id site_id, _zone zone_id,
    _date Date_eco, _temp_min Temperature,
    _temp_max Temperature
)
BEGIN ATOMIC
    UPDATE ObsTemperature
    SET temp_min = _temp_min,
        temp_max = _temp_max
    WHERE date = _date;
END;


CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obstemperature_MOD_note(
    _date Date_eco, _note TEXT
)
BEGIN ATOMIC
    UPDATE ObsTemperature
    SET note = _note
    WHERE date = _date;
END;


CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obstemperature_RET(_date Date_eco)
BEGIN ATOMIC
    DELETE FROM ObsTemperature WHERE date = _date;
END;



-------------------------------------------
-- OBS HUMIDITE
-------------------------------------------

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obshumidite_INS(
    _id site_id, _zone zone_id,
    _date Date_eco, _hum_min Humidite,
    _hum_max Humidite, _note TEXT
)
BEGIN ATOMIC
    INSERT INTO ObsHumidite (id, zone, date, hum_min, hum_max, note)
    VALUES (_id, _zone, _date, _hum_min, _hum_max, _note);
END;


CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obshumidite_MOD_hum(
    _id site_id, _zone zone_id,
    _date Date_eco, _hum_min Humidite,
    _hum_max Humidite
)
BEGIN ATOMIC
    UPDATE ObsHumidite
    SET hum_min = _hum_min,
        hum_max = _hum_max
    WHERE date = _date;
END;


CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obshumidite_RET(_date Date_eco)
BEGIN ATOMIC
    DELETE FROM ObsHumidite WHERE date = _date;
END;



-------------------------------------------
-- OBS VENTS
-------------------------------------------

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obsvents_INS(
    _id site_id, _zone zone_id,
    _date Date_eco, _vent_min Vitesse,
    _vent_max Vitesse, _note TEXT
)
BEGIN ATOMIC
    INSERT INTO ObsVents (id, zone, date, vent_min, vent_max, note)
    VALUES (_id, _zone, _date, _vent_min, _vent_max, _note);
END;


CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obsvents_MOD_vent(
    _id site_id, _zone zone_id,
    _date Date_eco, _vent_min Vitesse,
    _vent_max Vitesse
)
BEGIN ATOMIC
    UPDATE ObsVents
    SET vent_min = _vent_min,
        vent_max = _vent_max
    WHERE date = _date;
END;


CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obsvents_RET(_date Date_eco)
BEGIN ATOMIC
    DELETE FROM ObsVents WHERE date = _date;
END;



-------------------------------------------
-- OBS PRESSION
-------------------------------------------

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obspression_INS(
    _id site_id, _zone zone_id,
    _date Date_eco, _pres_min Pression,
    _pres_max Pression, _note TEXT
)
BEGIN ATOMIC
    INSERT INTO ObsPression (id, zone, date, pres_min, pres_max, note)
    VALUES (_id, _zone, _date, _pres_min, _pres_max, _note);
END;


CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obspression_MOD_pres(
    _id site_id, _zone zone_id,
    _date Date_eco, _pres_min Pression,
    _pres_max Pression
)
BEGIN ATOMIC
    UPDATE ObsPression
    SET pres_min = _pres_min,
        pres_max = _pres_max
    WHERE date = _date;
END;


CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obspression_RET(_date Date_eco)
BEGIN ATOMIC
    DELETE FROM ObsPression WHERE date = _date;
END;



-------------------------------------------
-- OBS PRECIPITATIONS
-------------------------------------------

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obsprecipitations_INS(
    _id site_id, _zone zone_id,
    _date Date_eco, _prec_tot HNP,
    _prec_nat Code_P, _note TEXT
)
BEGIN ATOMIC
    INSERT INTO ObsPrecipitations (id, zone, date, prec_tot, prec_nat, note)
    VALUES (_id, _zone, _date, _prec_tot, _prec_nat, _note);
END;


CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obsprecipitations_MOD_prec_tot(
    _id site_id, _zone zone_id,
    _date Date_eco, _prec_nat Code_P,
    _prec_tot HNP
)
BEGIN ATOMIC
    UPDATE ObsPrecipitations
    SET prec_tot = _prec_tot
    WHERE date = _date AND prec_nat = _prec_nat;
END;


CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".obsprecipitations_RET(
    _date Date_eco, _prec_nat Code_P
)
BEGIN ATOMIC
    DELETE FROM ObsPrecipitations
    WHERE date = _date AND prec_nat = _prec_nat;
END;



-------------------------------------------
-- CARNET METEO
-------------------------------------------

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".CarnetMeteo_INS(
    id TEXT,
    zone TEXT,
    temp_min TEXT,
    temp_max TEXT,
    hum_min TEXT,
    hum_max TEXT,
    prec_tot TEXT,
    prec_nat TEXT,
    vent_min TEXT,
    vent_max TEXT,
    pres_min TEXT,
    pres_max TEXT,
    date TEXT,
    note TEXT
)
BEGIN ATOMIC
    INSERT INTO "Staging".CarnetMeteo
    VALUES (id, zone, temp_min, temp_max, hum_min, hum_max,
            prec_tot, prec_nat, vent_min, vent_max,
            pres_min, pres_max, date, note);
END;



CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".CarnetMeteo_MOD_all(
    id TEXT,
    zone TEXT,
    temp_min TEXT,
    temp_max TEXT,
    hum_min TEXT,
    hum_max TEXT,
    prec_tot TEXT,
    prec_nat TEXT,
    vent_min TEXT,
    vent_max TEXT,
    pres_min TEXT,
    pres_max TEXT,
    date TEXT
)
BEGIN ATOMIC
    UPDATE "Staging".CarnetMeteo
    SET id = id,
        zone = zone,
        temp_min = temp_min,
        temp_max = temp_max,
        hum_min = hum_min,
        hum_max = hum_max,
        prec_tot = prec_tot,
        prec_nat = prec_nat,
        vent_min = vent_min,
        vent_max = vent_max,
        pres_min = pres_min,
        pres_max = pres_max
    WHERE date = date;
END;



CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".CarnetMeteo_MOD_note(
    _note TEXT,
    _date TEXT
)
BEGIN ATOMIC
    UPDATE "Staging".CarnetMeteo
    SET note = _note
    WHERE date = _date;
END;



CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".CarnetMeteo_RET(_date TEXT)
BEGIN ATOMIC
    DELETE FROM "Staging".CarnetMeteo WHERE date = _date;
END;
