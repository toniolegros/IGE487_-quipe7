--
-- Spécification du schéma
--
SET SCHEMA 'Herbivorie' ;

----------
-- EMIR --
----------

-- Type Precipitations
-- Évaluation
CREATE OR REPLACE FUNCTION "Herbivorie".typeprecipitations_EVA()
RETURNS TABLE (
    code    Code_P,
    libelle TEXT
)
BEGIN ATOMIC
    SELECT *
    FROM typeprecipitations;
END;

-- Insertion
CREATE OR REPLACE PROCEDURE "Herbivorie".typeprecipitations_INS(
    _code    Code_P,
    _libelle TEXT
)
BEGIN ATOMIC
    INSERT INTO typeprecipitations (code, libelle)
    VALUES (_code, _libelle);
END;

-- Modification
CREATE OR REPLACE PROCEDURE "Herbivorie".typeprecipitations_MOD_libelle(
    _code    Code_P,
    _libelle TEXT
)
BEGIN ATOMIC
    UPDATE typeprecipitations
    SET libelle = _libelle
    WHERE code = _code;
END;

-- Retrait
CREATE OR REPLACE PROCEDURE "Herbivorie".typeprecipitations_RET(
    _code Code_P
)
BEGIN ATOMIC
    DELETE FROM typeprecipitations
    WHERE code = _code;
END;

-- ObsTemperature
-- ObsTemperature : Évaluation
CREATE OR REPLACE FUNCTION "Herbivorie".obstemperature_EVA()
RETURNS TABLE (
    zone zone_id,
    date      Date_eco,
    temp_min  Temperature,
    temp_max  Temperature,
    note      TEXT
)
BEGIN ATOMIC
    SELECT *
    FROM ObsTemperature;
END;

-- ObsTemperature : Insertion
CREATE OR REPLACE PROCEDURE "Herbivorie".obstemperature_INS(
    _zone zone_id,
    _date     Date_eco,
    _temp_min Temperature,
    _temp_max Temperature,
    _note     TEXT
)
BEGIN ATOMIC
    INSERT INTO ObsTemperature (zone, date, temp_min, temp_max, note)
    VALUES (_zone, _date, _temp_min, _temp_max, _note);
END;

-- ObsTemperature : Modification (temp_min / temp_max / note)
CREATE OR REPLACE PROCEDURE "Herbivorie".obstemperature_MOD_temp(
    _zone zone_id,
    _date     Date_eco,
    _temp_min Temperature,
    _temp_max Temperature
)
BEGIN ATOMIC
    UPDATE ObsTemperature
    SET temp_min = _temp_min,
        temp_max = _temp_max
    WHERE date = _date;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".obstemperature_MOD_note(
    _date Date_eco,
    _note TEXT
)
BEGIN ATOMIC
    UPDATE ObsTemperature
    SET note = _note
    WHERE date = _date;
END;

-- ObsTemperature : Retrait
CREATE OR REPLACE PROCEDURE "Herbivorie".obstemperature_RET(
    _date Date_eco
)
BEGIN ATOMIC
    DELETE FROM ObsTemperature
    WHERE date = _date;
END;

-- ObsHumidite
-- ObsHumidite : Évaluation
CREATE OR REPLACE FUNCTION "Herbivorie".obshumidite_EVA()
RETURNS TABLE (
    zone zone_id,
    date     Date_eco,
    hum_min  Humidite,
    hum_max  Humidite
)
BEGIN ATOMIC
    SELECT *
    FROM ObsHumidite;
END;

-- ObsHumidite : Insertion
CREATE OR REPLACE PROCEDURE "Herbivorie".obshumidite_INS(
    _zone zone_id,
    _date    Date_eco,
    _hum_min Humidite,
    _hum_max Humidite
)
BEGIN ATOMIC
    INSERT INTO ObsHumidite (zone, date, hum_min, hum_max)
    VALUES (_zone, _date, _hum_min, _hum_max);
END;

-- ObsHumidite : Modification
CREATE OR REPLACE PROCEDURE "Herbivorie".obshumidite_MOD_hum(
    _zone zone_id,
    _date    Date_eco,
    _hum_min Humidite,
    _hum_max Humidite
)
BEGIN ATOMIC
    UPDATE ObsHumidite
    SET hum_min = _hum_min,
        hum_max = _hum_max
    WHERE date = _date;
END;

-- ObsHumidite : Retrait
CREATE OR REPLACE PROCEDURE "Herbivorie".obshumidite_RET(
    _date Date_eco
)
BEGIN ATOMIC
    DELETE FROM ObsHumidite
    WHERE date = _date;
END;

-- ObsVents
-- ObsVents : Évaluation
CREATE OR REPLACE FUNCTION "Herbivorie".obsvents_EVA()
RETURNS TABLE (
    zone zone_id,
    date     Date_eco,
    vent_min Vitesse,
    vent_max Vitesse
)
BEGIN ATOMIC
    SELECT *
    FROM ObsVents;
END;

-- ObsVents : Insertion
CREATE OR REPLACE PROCEDURE "Herbivorie".obsvents_INS(
    _zone zone_id,
    _date     Date_eco,
    _vent_min Vitesse,
    _vent_max Vitesse
)
BEGIN ATOMIC
    INSERT INTO ObsVents (zone, date, vent_min, vent_max)
    VALUES (_zone, _date, _vent_min, _vent_max);
END;

-- ObsVents : Modification
CREATE OR REPLACE PROCEDURE "Herbivorie".obsvents_MOD_vent(
    _zone zone_id,
    _date     Date_eco,
    _vent_min Vitesse,
    _vent_max Vitesse
)
BEGIN ATOMIC
    UPDATE ObsVents
    SET vent_min = _vent_min,
        vent_max = _vent_max
    WHERE date = _date;
END;

-- ObsVents : Retrait
CREATE OR REPLACE PROCEDURE "Herbivorie".obsvents_RET(
    _date Date_eco
)
BEGIN ATOMIC
    DELETE FROM ObsVents
    WHERE date = _date;
END;

-- ObsPression
-- ObsPression : Évaluation
CREATE OR REPLACE FUNCTION "Herbivorie".obspression_EVA()
RETURNS TABLE (
    zone zone_id,
    date     Date_eco,
    pres_min Pression,
    pres_max Pression
)
BEGIN ATOMIC
    SELECT *
    FROM ObsPression;
END;

-- ObsPression : Insertion
CREATE OR REPLACE PROCEDURE "Herbivorie".obspression_INS(
    _zone zone_id,
    _date     Date_eco,
    _pres_min Pression,
    _pres_max Pression
)
BEGIN ATOMIC
    INSERT INTO ObsPression (zone,date, pres_min, pres_max)
    VALUES (_zone,_date, _pres_min, _pres_max);
END;

-- ObsPression : Modification
CREATE OR REPLACE PROCEDURE "Herbivorie".obspression_MOD_pres(
    _zone zone_id,
    _date     Date_eco,
    _pres_min Pression,
    _pres_max Pression
)
BEGIN ATOMIC
    UPDATE ObsPression
    SET pres_min = _pres_min,
        pres_max = _pres_max
    WHERE date = _date;
END;

-- ObsPression : Retrait
CREATE OR REPLACE PROCEDURE "Herbivorie".obspression_RET(
    _date Date_eco
)
BEGIN ATOMIC
    DELETE FROM ObsPression
    WHERE date = _date;
END;

-- ObsPrecipitations
-- ObsPrecipitations : Évaluation
CREATE OR REPLACE FUNCTION "Herbivorie".obsprecipitations_EVA()
RETURNS TABLE (
    zone zone_id,
    date     Date_eco,
    prec_tot HNP,
    prec_nat Code_P
)
BEGIN ATOMIC
    SELECT *
    FROM ObsPrecipitations;
END;

-- ObsPrecipitations : Insertion
CREATE OR REPLACE PROCEDURE "Herbivorie".obsprecipitations_INS(
    _zone zone_id,
    _date     Date_eco,
    _prec_tot HNP,
    _prec_nat Code_P
)
BEGIN ATOMIC
    INSERT INTO ObsPrecipitations (zone, date, prec_tot, prec_nat)
    VALUES (_zone, _date, _prec_tot, _prec_nat);
END;

-- ObsPrecipitations : Modification (seulement prec_tot, la nature est la clé)
CREATE OR REPLACE PROCEDURE "Herbivorie".obsprecipitations_MOD_prec_tot(
    _zone zone_id,
    _date     Date_eco,
    _prec_nat Code_P,
    _prec_tot HNP
)
BEGIN ATOMIC
    UPDATE ObsPrecipitations
    SET prec_tot = _prec_tot
    WHERE date = _date
      AND prec_nat = _prec_nat;
END;

-- ObsPrecipitations : Retrait (par date + prec_nat)
CREATE OR REPLACE PROCEDURE "Herbivorie".obsprecipitations_RET(
    _date     Date_eco,
    _prec_nat Code_P
)
BEGIN ATOMIC
    DELETE FROM ObsPrecipitations
    WHERE date = _date
      AND prec_nat = _prec_nat;
END;

-- CarnetMeteo
-- CarnetMeteo : Évaluation
CREATE OR REPLACE FUNCTION "Herbivorie".carnetmeteo_EVA()
RETURNS TABLE (
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
BEGIN ATOMIC
    SELECT *
    FROM "Staging".CarnetMeteo;
END;

-- CarnetMeteo : Insertion
CREATE OR REPLACE PROCEDURE "Herbivorie".carnetmeteo_INS(
    _zone text,
    _temp_min TEXT,
    _temp_max TEXT,
    _hum_min  TEXT,
    _hum_max  TEXT,
    _prec_tot TEXT,
    _prec_nat TEXT,
    _vent_min TEXT,
    _vent_max TEXT,
    _pres_min TEXT,
    _pres_max TEXT,
    _date     TEXT,
    _note     TEXT
)
BEGIN ATOMIC
    INSERT INTO "Staging".CarnetMeteo (
        zone, temp_min, temp_max, hum_min, hum_max,
        prec_tot, prec_nat, vent_min, vent_max,
        pres_min, pres_max, date, note
    )
    VALUES (
        _zone, _temp_min, _temp_max, _hum_min, _hum_max,
        _prec_tot, _prec_nat, _vent_min, _vent_max,
        _pres_min, _pres_max, _date, _note
    );
END;

-- CarnetMeteo : Modification (mise à jour générale des colonnes non clés)
CREATE OR REPLACE PROCEDURE "Herbivorie".carnetmeteo_MOD_all(
    _zone TEXT,
    _date     TEXT,
    _temp_min TEXT,
    _temp_max TEXT,
    _hum_min  TEXT,
    _hum_max  TEXT,
    _prec_tot TEXT,
    _prec_nat TEXT,
    _vent_min TEXT,
    _vent_max TEXT,
    _pres_min TEXT,
    _pres_max TEXT,
    _note     TEXT
)
BEGIN ATOMIC
    UPDATE "Staging".CarnetMeteo
    SET zone = zone,
        temp_min = _temp_min,
        temp_max = _temp_max,
        hum_min  = _hum_min,
        hum_max  = _hum_max,
        prec_tot = _prec_tot,
        prec_nat = _prec_nat,
        vent_min = _vent_min,
        vent_max = _vent_max,
        pres_min = _pres_min,
        pres_max = _pres_max,
        note     = _note
    WHERE
      date = _date;
END;

-- CarnetMeteo : Modification ciblée (note)
CREATE OR REPLACE PROCEDURE "Herbivorie".carnetmeteo_MOD_note(
    _date TEXT,
    _note TEXT
)
BEGIN ATOMIC
    UPDATE "Staging".CarnetMeteo
    SET note = _note
    WHERE date = _date;
END;

-- CarnetMeteo : Retrait
CREATE OR REPLACE PROCEDURE "Herbivorie".carnetmeteo_RET(
    _date TEXT
)
BEGIN ATOMIC
    DELETE FROM "Staging".CarnetMeteo
    WHERE date = _date;
END;