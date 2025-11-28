
SET SCHEMA 'Herbivorie';

---------------------------------------------------------------------------
--  SCHEMA IMM (Lecture) + EMIR (Écriture)
---------------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS "Herbivorie_lecture";
CREATE SCHEMA IF NOT EXISTS "Herbivorie_ecriture";


---------------------------------------------------------------------------
--  SITE
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Site_EVA()
RETURNS TABLE (
    id Site_id,
    site Description,
    description Description
)
BEGIN ATOMIC
    SELECT id, site, description
    FROM Site;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Site_INS(
    _id Site_id,
    _site Description,
    _description Description
)
BEGIN ATOMIC
    INSERT INTO Site(id, site, description)
    VALUES (_id, _site, _description);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Site_MOD(
    _id Site_id,
    _site Description,
    _description Description
)
BEGIN ATOMIC
    UPDATE Site
    SET site = _site,
        description = _description
    WHERE id = _id;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Site_RET(
    _id Site_id
)
BEGIN ATOMIC
    DELETE FROM Site WHERE id = _id;
END;

---------------------------------------------------------------------------
--  ZONE
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Zone_EVA()
RETURNS TABLE (
    s_id Site_id,
    zone Zone_id,
    description Description
)
BEGIN ATOMIC
    SELECT id, zone, description
    FROM Zone;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Zone_INS(
    _id Site_id,
    _zone Zone_id,
    _description Description
)
BEGIN ATOMIC
    INSERT INTO Zone(id, zone, description)
    VALUES (_id, _zone, _description);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Zone_MOD(
    _id Site_id,
    _zone Zone_id,
    _description Description
)
BEGIN ATOMIC
    UPDATE Zone
    SET description = _description
    WHERE id = _id AND zone = _zone;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Zone_RET(
    _id Site_id,
    _zone Zone_id
)
BEGIN ATOMIC
    DELETE FROM Zone
    WHERE id = _id AND zone = _zone;
END;

---------------------------------------------------------------------------
--  PLACETTE
---------------------------------------------------------------------------
-- Table: Placette(id, zone, plac)

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Placette_EVA()
RETURNS TABLE (
    id Site_id,
    zone Zone_id,
    plac Placette_id
)
BEGIN ATOMIC
    SELECT id, zone, plac
    FROM Placette;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Placette_INS(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id
)
BEGIN ATOMIC
    INSERT INTO Placette(id, zone, plac)
    VALUES (_id, _zone, _plac);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Placette_MOD(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id
)
BEGIN ATOMIC
    UPDATE Placette
    SET id = _id, zone = _zone
    WHERE id = _id AND zone = _zone AND plac = _plac;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Placette_RET(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id
)
BEGIN ATOMIC
    DELETE FROM Placette
    WHERE id = _id AND zone = _zone AND plac = _plac;
END;

---------------------------------------------------------------------------
--  PARCELLE
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Parcelle_EVA()
RETURNS TABLE (
    id Site_id,
    zone Zone_id,
    plac Placette_id,
    parcelle Parcelle_id
)
BEGIN ATOMIC
    SELECT id, zone, plac, parcelle
    FROM Parcelle;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Parcelle_INS(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id,
    _parcelle Parcelle_id
)
BEGIN ATOMIC
    INSERT INTO Parcelle(id, zone, plac, parcelle)
    VALUES (_id, _zone, _plac, _parcelle);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Parcelle_MOD(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id,
    _parcelle Parcelle_id
)
BEGIN ATOMIC
    UPDATE Parcelle
    SET parcelle = _parcelle
    WHERE id = _id AND zone = _zone AND plac = _plac;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Parcelle_RET(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id
)
BEGIN ATOMIC
    DELETE FROM Parcelle
    WHERE id = _id AND zone = _zone AND plac = _plac;
END;

---------------------------------------------------------------------------
--  PEUPLEMENT
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Peuplement_EVA()
RETURNS TABLE(
    peup Peuplement_id,
    description Description
)
BEGIN ATOMIC
    SELECT peup, description
    FROM Peuplement;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Peuplement_INS(
    _peup Peuplement_id,
    _description Description
)
BEGIN ATOMIC
    INSERT INTO Peuplement(peup, description)
    VALUES (_peup, _description);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Peuplement_MOD(
    _peup Peuplement_id,
    _description Description
)
BEGIN ATOMIC
    UPDATE Peuplement
    SET description = _description
    WHERE peup = _peup;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Peuplement_RET(
    _peup Peuplement_id
)
BEGIN ATOMIC
    DELETE FROM Peuplement
    WHERE peup = _peup;
END;

---------------------------------------------------------------------------
--  ARBRE
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Arbre_EVA()
RETURNS TABLE(
    arbre Arbre_id,
    description Description
)
BEGIN ATOMIC
    SELECT arbre, description
    FROM Arbre;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Arbre_INS(
    _arbre Arbre_id,
    _description Description
)
BEGIN ATOMIC
    INSERT INTO Arbre(arbre, description)
    VALUES(_arbre, _description);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Arbre_MOD(
    _arbre Arbre_id,
    _description Description
)
BEGIN ATOMIC
    UPDATE Arbre
    SET description = _description
    WHERE arbre = _arbre;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Arbre_RET(
    _arbre Arbre_id
)
BEGIN ATOMIC
    DELETE FROM Arbre
    WHERE arbre = _arbre;
END;

---------------------------------------------------------------------------
--  PLANT
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Plant_EVA()
RETURNS TABLE(
    s_id Site_id,
    zone Zone_id,
    id   Plant_id,
    plac Placette_id,
    date Date_eco,
    note Description
)
BEGIN ATOMIC
    SELECT s_id, zone, id, plac, date, note
    FROM Plant;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Plant_INS(
    _s_id Site_id,
    _zone Zone_id,
    _id   Plant_id,
    _plac Placette_id,
    _date Date_eco,
    _note Description
)
BEGIN ATOMIC
    INSERT INTO Plant(s_id, zone, id, plac, date, note)
    VALUES (_s_id, _zone, _id, _plac, _date, _note);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Plant_MOD(
    _s_id Site_id,
    _zone Zone_id,
    _id   Plant_id,
    _plac Placette_id,
    _date Date_eco,
    _note Description
)
BEGIN ATOMIC
    UPDATE Plant
    SET plac = _plac,
        date = _date,
        note = _note
    WHERE id = _id;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Plant_RET(
    _id Plant_id
)
BEGIN ATOMIC
    DELETE FROM Plant WHERE id = _id;
END;

---------------------------------------------------------------------------
--  PLACETTE_CORE
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Placette_core_EVA()
RETURNS TABLE (
    id   Site_id,
    zone Zone_id,
    plac Placette_id,
    peup Peuplement_id,
    date Date_eco
)
BEGIN ATOMIC
    SELECT id, zone, plac, peup, date
    FROM Placette_core;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Placette_core_INS(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id,
    _peup Peuplement_id,
    _date Date_eco
)
BEGIN ATOMIC
    INSERT INTO Placette_core(id, zone, plac, peup, date)
    VALUES (_id, _zone, _plac, _peup, _date);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Placette_core_MOD(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id,
    _peup Peuplement_id,
    _date Date_eco
)
BEGIN ATOMIC
    UPDATE Placette_core
    SET peup = _peup,
        date = _date
    WHERE id = _id AND zone = _zone AND plac = _plac;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Placette_core_RET(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id
)
BEGIN ATOMIC
    DELETE FROM Placette_core
    WHERE id = _id AND zone = _zone AND plac = _plac;
END;

---------------------------------------------------------------------------
--  PLACETTE_DOMINANT
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Placette_Dominant_EVA()
RETURNS TABLE (
    id Site_id,
    zone Zone_id,
    plac Placette_id,
    rang INTEGER,
    arbre Arbre_id
)
BEGIN ATOMIC
    SELECT id, zone, plac, rang, arbre
    FROM Placette_Dominant;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Placette_Dominant_INS(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id,
    _rang INTEGER,
    _arbre Arbre_id
)
BEGIN ATOMIC
    INSERT INTO Placette_Dominant(id, zone, plac, rang, arbre)
    VALUES (_id, _zone, _plac, _rang, _arbre);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Placette_Dominant_MOD(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id,
    _rang INTEGER,
    _arbre Arbre_id
)
BEGIN ATOMIC
    UPDATE Placette_Dominant
    SET arbre = _arbre
    WHERE id = _id AND zone = _zone AND plac = _plac AND rang = _rang;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Placette_Dominant_RET(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id,
    _rang INTEGER
)
BEGIN ATOMIC
    DELETE FROM Placette_Dominant
    WHERE id = _id AND zone = _zone AND plac = _plac AND rang = _rang;
END;

---------------------------------------------------------------------------
--  PLACETTE_OBSTRUCTION
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Placette_Obstruction_EVA()
RETURNS TABLE (
    id Site_id,
    zone Zone_id,
    plac Placette_id,
    nature obstruction_nature,
    hauteur hauteur_obs,
    tcat TTaux,
    tval Taux_val
)
BEGIN ATOMIC
    SELECT id, zone, plac, nature, hauteur, tcat, tval
    FROM Placette_Obstruction;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Placette_Obstruction_INS(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id,
    _nature obstruction_nature,
    _hauteur hauteur_obs,
    _tcat TTaux,
    _tval Taux_val
)
BEGIN ATOMIC
    INSERT INTO Placette_Obstruction(id, zone, plac, nature, hauteur, tcat, tval)
    VALUES (_id, _zone, _plac, _nature, _hauteur, _tcat, _tval);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Placette_Obstruction_MOD(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id,
    _nature obstruction_nature,
    _hauteur hauteur_obs,
    _tcat TTaux,
    _tval Taux_val
)
BEGIN ATOMIC
    UPDATE Placette_Obstruction
    SET nature = _nature,
        hauteur = _hauteur,
        tcat = _tcat,
        tval = _tval
    WHERE id = _id AND zone = _zone AND plac = _plac;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Placette_Obstruction_RET(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id
)
BEGIN ATOMIC
    DELETE FROM Placette_Obstruction
    WHERE id = _id AND zone = _zone AND plac = _plac;
END;

---------------------------------------------------------------------------
--  PLACETTE_COUVERT
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Placette_Couvert_EVA()
RETURNS TABLE (
    id Site_id,
    zone Zone_id,
    plac Placette_id,
    ctype couvert_type,
    tcat TTaux,
    tval Taux_val
)
BEGIN ATOMIC
    SELECT id, zone, plac, ctype, tcat, tval
    FROM Placette_Couvert;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Placette_Couvert_INS(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id,
    _ctype couvert_type,
    _tcat TTaux,
    _tval Taux_val
)
BEGIN ATOMIC
    INSERT INTO Placette_Couvert(id, zone, plac, ctype, tcat, tval)
    VALUES (_id, _zone, _plac, _ctype, _tcat, _tval);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Placette_Couvert_MOD(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id,
    _ctype couvert_type,
    _tcat TTaux,
    _tval Taux_val
)
BEGIN ATOMIC
    UPDATE Placette_Couvert
    SET ctype = _ctype, tcat = _tcat, tval = _tval
    WHERE id = _id AND zone = _zone AND plac = _plac;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".Placette_Couvert_RET(
    _id Site_id,
    _zone Zone_id,
    _plac Placette_id
)
BEGIN ATOMIC
    DELETE FROM Placette_Couvert
    WHERE id = _id AND zone = _zone AND plac = _plac;
END;

---------------------------------------------------------------------------
--  OBS_DIMENSION
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".ObsDimension_EVA()
RETURNS TABLE(
    id Plant_id,
    longueur Dim_mm,
    largeur Dim_mm,
    date Date_eco,
    unite_id Unite_id,
    note Description
)
BEGIN ATOMIC
    SELECT id, longueur, largeur, date, unite_id, note
    FROM ObsDimension;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".ObsDimension_INS(
    _id Plant_id,
    _long Dim_mm,
    _larg Dim_mm,
    _date Date_eco,
    _unite Unite_id,
    _note Description
)
BEGIN ATOMIC
    INSERT INTO ObsDimension(id, longueur, largeur, date, unite_id, note)
    VALUES (_id, _long, _larg, _date, _unite, _note);
END;

---------------------------------------------------------------------------
--  OBS_FLORAISON
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".ObsFloraison_EVA()
RETURNS TABLE(
    id Plant_id,
    fleur boolean,
    date Date_eco,
    note Description
)
BEGIN ATOMIC
    SELECT id, fleur, date, note
    FROM ObsFloraison;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".ObsFloraison_INS(
    _id Plant_id,
    _fleur boolean,
    _date Date_eco,
    _note Description
)
BEGIN ATOMIC
    INSERT INTO ObsFloraison(id, fleur, date, note)
    VALUES (_id, _fleur, _date, _note);
END;

---------------------------------------------------------------------------
--  OBS_ETAT
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".ObsEtat_EVA()
RETURNS TABLE(
    id Plant_id,
    etat Etat_id,
    date Date_eco,
    note Description
)
BEGIN ATOMIC
    SELECT id, etat, date, note
    FROM ObsEtat;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie_ecriture".ObsEtat_INS(
    _id Plant_id,
    _etat Etat_id,
    _date Date_eco,
    _note Description
)
BEGIN ATOMIC
    INSERT INTO ObsEtat(id, etat, date, note)
    VALUES (_id, _etat, _date, _note);
END;
