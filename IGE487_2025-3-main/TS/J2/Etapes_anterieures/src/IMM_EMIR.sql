
SET SCHEMA 'Herbivorie';


------------------------------
-- Site
------------------------------
-- Évaluation
CREATE OR REPLACE FUNCTION Site_EVA()
RETURNS TABLE (
    id  Site_id,
    site Description,
    description Description
)
BEGIN ATOMIC
    SELECT id, site, description
    FROM Site;
END;


-- Insertion (strict)
CREATE OR REPLACE PROCEDURE Site_INS
(
  _id Site_id,
  _site Description,
  _description Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO Site (id, site, description)
  VALUES (_id, _site, _description);
END;
$$;

-- Modification (non stricte)
CREATE OR REPLACE PROCEDURE Site_MOD
(
  _id Site_id,
  _site Description,
  _description Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE Site
  SET
    site = _site,
    description = _description
  WHERE id = _id;
END;
$$;

-- Retrait (strict)
CREATE OR REPLACE PROCEDURE Site_RET
(
  _id Site_id
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM Site
  WHERE id = _id;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION 'Site_RET : aucun Site avec id = %', _id;
  END IF;
END;
$$;

------------------------------
-- Zone
------------------------------
CREATE OR REPLACE FUNCTION Zone_EVA ()
RETURNS TABLE
(
  id Site_id,
  zone zone_id,
  description description
)
LANGUAGE sql AS
$$
  SELECT
    id, zone, description
  FROM Zone;
$$;

CREATE OR REPLACE PROCEDURE Zone_INS
(
  _id Site_id,
  _zone zone_id,
  _description description
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO Zone (id, zone, description)
  VALUES (_id, _zone, _description);
END;
$$;

CREATE OR REPLACE PROCEDURE Zone_MOD
(
  _id Site_id,
  _zone zone_id,
  _description description
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE Zone
  SET
    id = _id,
    description = _description
  WHERE zone = _zone;
END;
$$;

CREATE OR REPLACE PROCEDURE Zone_RET
(
  _zone zone_id
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM Zone
  WHERE zone = _zone;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION 'Zone_RET : aucune Zone avec zone = %', _zone;
  END IF;
END;
$$;

------------------------------
-- Peuplement
------------------------------
CREATE OR REPLACE FUNCTION Peuplement_EVA ()
RETURNS TABLE
(
  peup Peuplement_id,
  description Description
)
LANGUAGE sql AS
$$
  SELECT
    peup, description
  FROM Peuplement;
$$;

CREATE OR REPLACE PROCEDURE Peuplement_INS
(
  _peup Peuplement_id,
  _description Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO Peuplement (peup, description)
  VALUES (_peup, _description);
END;
$$;

CREATE OR REPLACE PROCEDURE Peuplement_MOD
(
  _peup Peuplement_id,
  _description Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE Peuplement
  SET
    description = _description
  WHERE peup = _peup;
END;
$$;

CREATE OR REPLACE PROCEDURE Peuplement_RET
(
  _peup Peuplement_id
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM Peuplement
  WHERE peup = _peup;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION 'Peuplement_RET : aucun Peuplement avec peup = %', _peup;
  END IF;
END;
$$;

------------------------------
-- Arbre
------------------------------
CREATE OR REPLACE FUNCTION Arbre_EVA ()
RETURNS TABLE
(
  arbre Arbre_id,
  description Description
)
LANGUAGE sql AS
$$
  SELECT
    arbre, description
  FROM Arbre;
$$;

CREATE OR REPLACE PROCEDURE Arbre_INS
(
  _arbre Arbre_id,
  _description Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO Arbre (arbre, description)
  VALUES (_arbre, _description);
END;
$$;

CREATE OR REPLACE PROCEDURE Arbre_MOD
(
  _arbre Arbre_id,
  _description Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE Arbre
  SET
    description = _description
  WHERE arbre = _arbre;
END;
$$;

CREATE OR REPLACE PROCEDURE Arbre_RET
(
  _arbre Arbre_id
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM Arbre
  WHERE arbre = _arbre;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION 'Arbre_RET : aucun Arbre avec arbre = %', _arbre;
  END IF;
END;
$$;

------------------------------
-- Taux
------------------------------
CREATE OR REPLACE FUNCTION Taux_EVA ()
RETURNS TABLE
(
  tCat TTaux,
  tMin Taux_val,
  tMax Taux_val
)
LANGUAGE sql AS
$$
  SELECT
    tCat, tMin, tMax
  FROM Taux;
$$;

CREATE OR REPLACE PROCEDURE Taux_INS
(
  _tCat TTaux,
  _tMin Taux_val,
  _tMax Taux_val
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO Taux (tCat, tMin, tMax)
  VALUES (_tCat, _tMin, _tMax);
END;
$$;

CREATE OR REPLACE PROCEDURE Taux_MOD
(
  _tCat TTaux,
  _tMin Taux_val,
  _tMax Taux_val
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE Taux
  SET
    tMin = _tMin,
    tMax = _tMax
  WHERE tCat = _tCat;
END;
$$;

CREATE OR REPLACE PROCEDURE Taux_RET
(
  _tCat TTaux
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM Taux
  WHERE tCat = _tCat;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION 'Taux_RET : aucun Taux avec tCat = %', _tCat;
  END IF;
END;
$$;

------------------------------
-- UNITE
------------------------------
CREATE OR REPLACE FUNCTION UNITE_EVA ()
RETURNS TABLE
(
  UNITE_ID unite_id,
  UNITE unite_mesure,
  DESCRIPTION description
)
LANGUAGE sql AS
$$
  SELECT
    UNITE_ID, UNITE, DESCRIPTION
  FROM UNITE;
$$;

CREATE OR REPLACE PROCEDURE UNITE_INS
(
  _UNITE_ID unite_id,
  _UNITE unite_mesure,
  _DESCRIPTION description
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO UNITE (UNITE_ID, UNITE, DESCRIPTION)
  VALUES (_UNITE_ID, _UNITE, _DESCRIPTION);
END;
$$;

CREATE OR REPLACE PROCEDURE UNITE_MOD
(
  _UNITE_ID unite_id,
  _UNITE unite_mesure,
  _DESCRIPTION description
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE UNITE
  SET
    UNITE = _UNITE,
    DESCRIPTION = _DESCRIPTION
  WHERE UNITE_ID = _UNITE_ID;
END;
$$;

CREATE OR REPLACE PROCEDURE UNITE_RET
(
  _UNITE_ID unite_id
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM UNITE
  WHERE UNITE_ID = _UNITE_ID;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION 'UNITE_RET : aucune UNITE avec UNITE_ID = %', _UNITE_ID;
  END IF;
END;
$$;

------------------------------
-- Placette
------------------------------
CREATE OR REPLACE FUNCTION Placette_EVA ()
RETURNS TABLE
(
  zone Zone_id,
  plac Placette_id
)
LANGUAGE sql AS
$$
  SELECT
    zone, plac
  FROM Placette;
$$;

CREATE OR REPLACE PROCEDURE Placette_INS
(
  _zone Zone_id,
  _plac Placette_id
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO Placette (zone, plac)
  VALUES (_zone, _plac);
END;
$$;

CREATE OR REPLACE PROCEDURE Placette_MOD
(
  _zone Zone_id,
  _plac Placette_id
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE Placette
  SET
    zone = _zone
  WHERE zone = _zone AND plac = _plac;
END;
$$;

CREATE OR REPLACE PROCEDURE Placette_RET
(
  _zone Zone_id,
  _plac Placette_id
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM Placette
  WHERE zone = _zone AND plac = _plac;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION 'Placette_RET : aucune Placette (zone,plac) = (%,%)',
      _zone, _plac;
  END IF;
END;
$$;

------------------------------
-- Placette_core
------------------------------
CREATE OR REPLACE FUNCTION Placette_core_EVA ()
RETURNS TABLE
(
  zone zone_id,
  plac Placette_id,
  peup Peuplement_id,
  date Date_eco
)
LANGUAGE sql AS
$$
  SELECT
    zone, plac, peup, date
  FROM Placette_core;
$$;

CREATE OR REPLACE PROCEDURE Placette_core_INS
(
  _zone zone_id,
  _plac Placette_id,
  _peup Peuplement_id,
  _date Date_eco
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO Placette_core (zone, plac, peup, date)
  VALUES (_zone, _plac, _peup, _date);
END;
$$;

CREATE OR REPLACE PROCEDURE Placette_core_MOD
(
  _zone zone_id,
  _plac Placette_id,
  _peup Peuplement_id,
  _date Date_eco
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE Placette_core
  SET
    zone = _zone,
    peup = _peup,
    date = _date
  WHERE zone = _zone AND plac = _plac AND peup = _peup AND date = _date;
END;
$$;

CREATE OR REPLACE PROCEDURE Placette_core_RET
(
  _zone zone_id,
  _plac Placette_id,
  _peup Peuplement_id,
  _date Date_eco
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM Placette_core
  WHERE zone = _zone AND plac = _plac AND peup = _peup AND date = _date;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION
      'Placette_core_RET : aucune ligne (zone,plac,peup,date) = (%,%,%,%)',
      _zone, _plac, _peup, _date;
  END IF;
END;
$$;

------------------------------
-- Placette_Dominant
------------------------------
CREATE OR REPLACE FUNCTION Placette_Dominant_EVA ()
RETURNS TABLE
(
  zone Zone_id,
  plac Placette_id,
  rang rang,
  arbre Arbre_id
)
LANGUAGE sql AS
$$
  SELECT
    zone, plac, rang, arbre
  FROM Placette_Dominant;
$$;

CREATE OR REPLACE PROCEDURE Placette_Dominant_INS
(
  _zone Zone_id,
  _plac Placette_id,
  _rang rang,
  _arbre Arbre_id
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO Placette_Dominant (zone, plac, rang, arbre)
  VALUES (_zone, _plac, _rang, _arbre);
END;
$$;

CREATE OR REPLACE PROCEDURE Placette_Dominant_MOD
(
  _zone Zone_id,
  _plac Placette_id,
  _rang rang,
  _arbre Arbre_id
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE Placette_Dominant
  SET
    zone = _zone,
    arbre = _arbre
  WHERE plac = _plac AND rang = _rang;
END;
$$;

CREATE OR REPLACE PROCEDURE Placette_Dominant_RET
(
  _plac Placette_id,
  _rang rang
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM Placette_Dominant
  WHERE plac = _plac AND rang = _rang;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION
      'Placette_Dominant_RET : aucune ligne (plac,rang) = (%,%)',
      _plac, _rang;
  END IF;
END;
$$;

------------------------------
-- Placette_Obstruction
------------------------------
CREATE OR REPLACE FUNCTION Placette_Obstruction_EVA ()
RETURNS TABLE
(
  zone Zone_id,
  plac Placette_id,
  nature obstruction_nature,
  hauteur hauteur_obs,
  tcat TTaux,
  tval taux_val
)
LANGUAGE sql AS
$$
  SELECT
    zone, plac, nature, hauteur, tcat, tval
  FROM Placette_Obstruction;
$$;

CREATE OR REPLACE PROCEDURE Placette_Obstruction_INS
(
  _zone Zone_id,
  _plac Placette_id,
  _nature obstruction_nature,
  _hauteur hauteur_obs,
  _tcat TTaux,
  _tval taux_val
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO Placette_Obstruction (zone, plac, nature, hauteur, tcat, tval)
  VALUES (_zone, _plac, _nature, _hauteur, _tcat, _tval);
END;
$$;

CREATE OR REPLACE PROCEDURE Placette_Obstruction_MOD
(
  _zone Zone_id,
  _plac Placette_id,
  _nature obstruction_nature,
  _hauteur hauteur_obs,
  _tcat TTaux,
  _tval taux_val
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE Placette_Obstruction
  SET
    zone = _zone,
    tcat = _tcat,
    tval = _tval
  WHERE plac = _plac AND nature = _nature AND hauteur = _hauteur;
END;
$$;

CREATE OR REPLACE PROCEDURE Placette_Obstruction_RET
(
  _plac Placette_id,
  _nature obstruction_nature,
  _hauteur hauteur_obs
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM Placette_Obstruction
  WHERE plac = _plac AND nature = _nature AND hauteur = _hauteur;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION
      'Placette_Obstruction_RET : aucune ligne (plac,nature,hauteur) = (%,%,%)',
      _plac, _nature, _hauteur;
  END IF;
END;
$$;

------------------------------
-- Placette_Couvert
------------------------------
CREATE OR REPLACE FUNCTION Placette_Couvert_EVA ()
RETURNS TABLE
(
  zone Zone_id,
  plac Placette_id,
  ctype couvert_type,
  tcat TTaux,
  tval taux_val
)
LANGUAGE sql AS
$$
  SELECT
    zone, plac, ctype, tcat, tval
  FROM Placette_Couvert;
$$;

CREATE OR REPLACE PROCEDURE Placette_Couvert_INS
(
  _zone Zone_id,
  _plac Placette_id,
  _ctype couvert_type,
  _tcat TTaux,
  _tval taux_val
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO Placette_Couvert (zone, plac, ctype, tcat, tval)
  VALUES (_zone, _plac, _ctype, _tcat, _tval);
END;
$$;

CREATE OR REPLACE PROCEDURE Placette_Couvert_MOD
(
  _zone Zone_id,
  _plac Placette_id,
  _ctype couvert_type,
  _tcat TTaux,
  _tval taux_val
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE Placette_Couvert
  SET
    zone = _zone,
    tcat = _tcat,
    tval = _tval
  WHERE plac = _plac AND ctype = _ctype;
END;
$$;

CREATE OR REPLACE PROCEDURE Placette_Couvert_RET
(
  _plac Placette_id,
  _ctype couvert_type
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM Placette_Couvert
  WHERE plac = _plac AND ctype = _ctype;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION
      'Placette_Couvert_RET : aucune ligne (plac,ctype) = (%,%)',
      _plac, _ctype;
  END IF;
END;
$$;

------------------------------
-- Parcelle
------------------------------
CREATE OR REPLACE FUNCTION Parcelle_EVA ()
RETURNS TABLE
(
  zone Zone_id,
  plac Placette_id,
  parcelle Parcelle_id
)
LANGUAGE sql AS
$$
  SELECT
    zone, plac, parcelle
  FROM Parcelle;
$$;

CREATE OR REPLACE PROCEDURE Parcelle_INS
(
  _zone Zone_id,
  _plac Placette_id,
  _parcelle Parcelle_id
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO Parcelle (zone, plac, parcelle)
  VALUES (_zone, _plac, _parcelle);
END;
$$;

CREATE OR REPLACE PROCEDURE Parcelle_MOD
(
  _zone Zone_id,
  _plac Placette_id,
  _parcelle Parcelle_id
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE Parcelle
  SET
    zone = _zone
  WHERE zone = _zone AND plac = _plac AND parcelle = _parcelle;
END;
$$;

CREATE OR REPLACE PROCEDURE Parcelle_RET
(
  _zone Zone_id,
  _plac Placette_id,
  _parcelle Parcelle_id
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM Parcelle
  WHERE zone = _zone AND plac = _plac AND parcelle = _parcelle;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION
      'Parcelle_RET : aucune ligne (zone,plac,parcelle) = (%,%,%)',
      _zone, _plac, _parcelle;
  END IF;
END;
$$;

------------------------------
-- Plant
------------------------------
CREATE OR REPLACE FUNCTION Plant_EVA ()
RETURNS TABLE
(
  zone Zone_id,
  id Plant_id,
  plac Placette_id,
  date Date_eco,
  note Description
)
LANGUAGE sql AS
$$
  SELECT
    zone, id, plac, date, note
  FROM Plant;
$$;

CREATE OR REPLACE PROCEDURE Plant_INS
(
  _zone Zone_id,
  _id Plant_id,
  _plac Placette_id,
  _date Date_eco,
  _note Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO Plant (zone, id, plac, date, note)
  VALUES (_zone, _id, _plac, _date, _note);
END;
$$;

CREATE OR REPLACE PROCEDURE Plant_MOD
(
  _zone Zone_id,
  _id Plant_id,
  _plac Placette_id,
  _date Date_eco,
  _note Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE Plant
  SET
    zone = _zone,
    plac = _plac,
    date = _date,
    note = _note
  WHERE id = _id;
END;
$$;

CREATE OR REPLACE PROCEDURE Plant_RET
(
  _id Plant_id
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM Plant
  WHERE id = _id;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION 'Plant_RET : aucun Plant avec id = %', _id;
  END IF;
END;
$$;

------------------------------
-- ObsDimension
------------------------------
CREATE OR REPLACE FUNCTION ObsDimension_EVA ()
RETURNS TABLE
(
  id Plant_id,
  longueur Dim_mm,
  largeur Dim_mm,
  date Date_eco,
  unite_id unite_id,
  note Description
)
LANGUAGE sql AS
$$
  SELECT
    id, longueur, largeur, date, unite_id, note
  FROM ObsDimension;
$$;

CREATE OR REPLACE PROCEDURE ObsDimension_INS
(
  _id Plant_id,
  _longueur Dim_mm,
  _largeur Dim_mm,
  _date Date_eco,
  _unite_id unite_id,
  _note Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO ObsDimension (id, longueur, largeur, date, unite_id, note)
  VALUES (_id, _longueur, _largeur, _date, _unite_id, _note);
END;
$$;

CREATE OR REPLACE PROCEDURE ObsDimension_MOD
(
  _id Plant_id,
  _longueur Dim_mm,
  _largeur Dim_mm,
  _date Date_eco,
  _unite_id unite_id,
  _note Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE ObsDimension
  SET
    longueur = _longueur,
    largeur = _largeur,
    unite_id = _unite_id,
    note = _note
  WHERE id = _id AND date = _date;
END;
$$;

CREATE OR REPLACE PROCEDURE ObsDimension_RET
(
  _id Plant_id,
  _date Date_eco
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM ObsDimension
  WHERE id = _id AND date = _date;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION
      'ObsDimension_RET : aucune ligne (id,date) = (%,%)', _id, _date;
  END IF;
END;
$$;

------------------------------
-- ObsFloraison
------------------------------
CREATE OR REPLACE FUNCTION ObsFloraison_EVA ()
RETURNS TABLE
(
  id Plant_id,
  fleur BOOLEAN,
  date Date_eco,
  note Description
)
LANGUAGE sql AS
$$
  SELECT
    id, fleur, date, note
  FROM ObsFloraison;
$$;

CREATE OR REPLACE PROCEDURE ObsFloraison_INS
(
  _id Plant_id,
  _fleur BOOLEAN,
  _date Date_eco,
  _note Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO ObsFloraison (id, fleur, date, note)
  VALUES (_id, _fleur, _date, _note);
END;
$$;

CREATE OR REPLACE PROCEDURE ObsFloraison_MOD
(
  _id Plant_id,
  _fleur BOOLEAN,
  _date Date_eco,
  _note Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE ObsFloraison
  SET
    fleur = _fleur,
    note = _note
  WHERE id = _id AND date = _date;
END;
$$;

CREATE OR REPLACE PROCEDURE ObsFloraison_RET
(
  _id Plant_id,
  _date Date_eco
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM ObsFloraison
  WHERE id = _id AND date = _date;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION
      'ObsFloraison_RET : aucune ligne (id,date) = (%,%)', _id, _date;
  END IF;
END;
$$;

------------------------------
-- Etat
------------------------------
CREATE OR REPLACE FUNCTION Etat_EVA ()
RETURNS TABLE
(
  etat Etat_id,
  description Description
)
LANGUAGE sql AS
$$
  SELECT
    etat, description
  FROM Etat;
$$;

CREATE OR REPLACE PROCEDURE Etat_INS
(
  _etat Etat_id,
  _description Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO Etat (etat, description)
  VALUES (_etat, _description);
END;
$$;

CREATE OR REPLACE PROCEDURE Etat_MOD
(
  _etat Etat_id,
  _description Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE Etat
  SET
    description = _description
  WHERE etat = _etat;
END;
$$;

CREATE OR REPLACE PROCEDURE Etat_RET
(
  _etat Etat_id
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM Etat
  WHERE etat = _etat;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION 'Etat_RET : aucun Etat avec etat = %', _etat;
  END IF;
END;
$$;

------------------------------
-- ObsEtat
------------------------------
CREATE OR REPLACE FUNCTION ObsEtat_EVA ()
RETURNS TABLE
(
  id Plant_id,
  etat Etat_id,
  date Date_eco,
  note Description
)
LANGUAGE sql AS
$$
  SELECT
    id, etat, date, note
  FROM ObsEtat;
$$;

CREATE OR REPLACE PROCEDURE ObsEtat_INS
(
  _id Plant_id,
  _etat Etat_id,
  _date Date_eco,
  _note Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO ObsEtat (id, etat, date, note)
  VALUES (_id, _etat, _date, _note);
END;
$$;

CREATE OR REPLACE PROCEDURE ObsEtat_MOD
(
  _id Plant_id,
  _etat Etat_id,
  _date Date_eco,
  _note Description
)
LANGUAGE plpgsql AS
$$
BEGIN
  UPDATE ObsEtat
  SET
    etat = _etat,
    note = _note
  WHERE id = _id AND date = _date;
END;
$$;

CREATE OR REPLACE PROCEDURE ObsEtat_RET
(
  _id Plant_id,
  _date Date_eco
)
LANGUAGE plpgsql AS
$$
DECLARE
  nb INTEGER;
BEGIN
  DELETE FROM ObsEtat
  WHERE id = _id AND date = _date;

  GET DIAGNOSTICS nb = ROW_COUNT;
  IF nb = 0 THEN
    RAISE EXCEPTION
      'ObsEtat_RET : aucune ligne (id,date) = (%,%)', _id, _date;
  END IF;
END;
$$;
