
SET SCHEMA 'Herbivorie';


---------------------------------
-- Site
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".Site_EVA()
RETURNS TABLE (
  id   Site_id,
  site Description,
  description Description
)
BEGIN ATOMIC
  SELECT id, site, description
  FROM Site;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Site_INS(
  _id Site_id,
  _site Description,
  _description Description
)
BEGIN ATOMIC
  INSERT INTO Site (id, site, description)
  VALUES (_id, _site, _description);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Site_MOD(
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

CREATE OR REPLACE PROCEDURE "Herbivorie".Site_RET(
  _id Site_id
)
BEGIN ATOMIC
  DELETE FROM Site
  WHERE id = _id;
END;

---------------------------------
-- Zone
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".Zone_EVA()
RETURNS TABLE (
  id   Site_id,
  zone Zone_id,
  description Description
)
BEGIN ATOMIC
  SELECT id, zone, description
  FROM Zone;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Zone_INS(
  _id Site_id,
  _zone Zone_id,
  _description Description
)
BEGIN ATOMIC
  INSERT INTO Zone (id, zone, description)
  VALUES (_id, _zone, _description);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Zone_MOD(
  _id Site_id,
  _zone Zone_id,
  _description Description
)
BEGIN ATOMIC
  UPDATE Zone
  SET id = _id,
      description = _description
  WHERE zone = _zone;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Zone_RET(
  _zone Zone_id
)
BEGIN ATOMIC
  DELETE FROM Zone
  WHERE zone = _zone;
END;

---------------------------------
-- Peuplement
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".Peuplement_EVA()
RETURNS TABLE (
  peup        Peuplement_id,
  description Description
)
BEGIN ATOMIC
  SELECT peup, description
  FROM Peuplement;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Peuplement_INS(
  _peup Peuplement_id,
  _description Description
)
BEGIN ATOMIC
  INSERT INTO Peuplement (peup, description)
  VALUES (_peup, _description);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Peuplement_MOD(
  _peup Peuplement_id,
  _description Description
)
BEGIN ATOMIC
  UPDATE Peuplement
  SET description = _description
  WHERE peup = _peup;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Peuplement_RET(
  _peup Peuplement_id
)
BEGIN ATOMIC
  DELETE FROM Peuplement
  WHERE peup = _peup;
END;

---------------------------------
-- Arbre
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".Arbre_EVA()
RETURNS TABLE (
  arbre       Arbre_id,
  description Description
)
BEGIN ATOMIC
  SELECT arbre, description
  FROM Arbre;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Arbre_INS(
  _arbre Arbre_id,
  _description Description
)
BEGIN ATOMIC
  INSERT INTO Arbre (arbre, description)
  VALUES (_arbre, _description);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Arbre_MOD(
  _arbre Arbre_id,
  _description Description
)
BEGIN ATOMIC
  UPDATE Arbre
  SET description = _description
  WHERE arbre = _arbre;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Arbre_RET(
  _arbre Arbre_id
)
BEGIN ATOMIC
  DELETE FROM Arbre
  WHERE arbre = _arbre;
END;

---------------------------------
-- Taux
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".Taux_EVA()
RETURNS TABLE (
  tCat TTaux,
  tMin Taux_val,
  tMax Taux_val
)
BEGIN ATOMIC
  SELECT tCat, tMin, tMax
  FROM Taux;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Taux_INS(
  _tCat TTaux,
  _tMin Taux_val,
  _tMax Taux_val
)
BEGIN ATOMIC
  INSERT INTO Taux (tCat, tMin, tMax)
  VALUES (_tCat, _tMin, _tMax);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Taux_MOD(
  _tCat TTaux,
  _tMin Taux_val,
  _tMax Taux_val
)
BEGIN ATOMIC
  UPDATE Taux
  SET tMin = _tMin,
      tMax = _tMax
  WHERE tCat = _tCat;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Taux_RET(
  _tCat TTaux
)
BEGIN ATOMIC
  DELETE FROM Taux
  WHERE tCat = _tCat;
END;

---------------------------------
-- UNITE
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".UNITE_EVA()
RETURNS TABLE (
  UNITE_ID   unite_id,
  UNITE     unite_mesure,
  DESCRIPTION description
)
BEGIN ATOMIC
  SELECT UNITE_ID, UNITE, DESCRIPTION
  FROM UNITE;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".UNITE_INS(
  _UNITE_ID unite_id,
  _UNITE    unite_mesure,
  _DESCRIPTION Description
)
BEGIN ATOMIC
  INSERT INTO UNITE (UNITE_ID, UNITE, DESCRIPTION)
  VALUES (_UNITE_ID, _UNITE, _DESCRIPTION);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".UNITE_MOD(
  _UNITE_ID unite_id,
  _UNITE    unite_mesure,
  _DESCRIPTION Description
)
BEGIN ATOMIC
  UPDATE UNITE
  SET UNITE = _UNITE,
      DESCRIPTION = _DESCRIPTION
  WHERE UNITE_ID = _UNITE_ID;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".UNITE_RET(
  _UNITE_ID unite_id
)
BEGIN ATOMIC
  DELETE FROM UNITE
  WHERE UNITE_ID = _UNITE_ID;
END;

---------------------------------
-- Placette
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".Placette_EVA()
RETURNS TABLE (
  zone Zone_id,
  plac Placette_id
)
BEGIN ATOMIC
  SELECT zone, plac
  FROM Placette;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Placette_INS(
  _zone Zone_id,
  _plac Placette_id
)
BEGIN ATOMIC
  INSERT INTO Placette (zone, plac)
  VALUES (_zone, _plac);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Placette_MOD(
  _zone Zone_id,
  _plac Placette_id
)
BEGIN ATOMIC
  UPDATE Placette
  SET zone = _zone
  WHERE zone = _zone AND plac = _plac;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Placette_RET(
  _zone Zone_id,
  _plac Placette_id
)
BEGIN ATOMIC
  DELETE FROM Placette
  WHERE zone = _zone AND plac = _plac;
END;

---------------------------------
-- Placette_core
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".Placette_core_EVA()
RETURNS TABLE (
  zone zone_id,
  plac Placette_id,
  peup Peuplement_id,
  date Date_eco
)
BEGIN ATOMIC
  SELECT zone, plac, peup, date
  FROM Placette_core;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Placette_core_INS(
  _zone zone_id,
  _plac Placette_id,
  _peup Peuplement_id,
  _date Date_eco
)
BEGIN ATOMIC
  INSERT INTO Placette_core (zone, plac, peup, date)
  VALUES (_zone, _plac, _peup, _date);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Placette_core_MOD(
  _zone zone_id,
  _plac Placette_id,
  _peup Peuplement_id,
  _date Date_eco
)
BEGIN ATOMIC
  UPDATE Placette_core
  SET zone = _zone,
      peup = _peup,
      date = _date
  WHERE zone = _zone AND plac = _plac AND peup = _peup AND date = _date;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Placette_core_RET(
  _zone zone_id,
  _plac Placette_id,
  _peup Peuplement_id,
  _date Date_eco
)
BEGIN ATOMIC
  DELETE FROM Placette_core
  WHERE zone = _zone AND plac = _plac AND peup = _peup AND date = _date;
END;

---------------------------------
-- Placette_Dominant
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".Placette_Dominant_EVA()
RETURNS TABLE (
  zone  Zone_id,
  plac  Placette_id,
  rang  rang,
  arbre Arbre_id
)
BEGIN ATOMIC
  SELECT zone, plac, rang, arbre
  FROM Placette_Dominant;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Placette_Dominant_INS(
  _zone Zone_id,
  _plac Placette_id,
  _rang rang,
  _arbre Arbre_id
)
BEGIN ATOMIC
  INSERT INTO Placette_Dominant (zone, plac, rang, arbre)
  VALUES (_zone, _plac, _rang, _arbre);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Placette_Dominant_MOD(
  _zone Zone_id,
  _plac Placette_id,
  _rang rang,
  _arbre Arbre_id
)
BEGIN ATOMIC
  UPDATE Placette_Dominant
  SET zone = _zone,
      arbre = _arbre
  WHERE plac = _plac AND rang = _rang;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Placette_Dominant_RET(
  _plac Placette_id,
  _rang rang
)
BEGIN ATOMIC
  DELETE FROM Placette_Dominant
  WHERE plac = _plac AND rang = _rang;
END;

---------------------------------
-- Placette_Obstruction
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".Placette_Obstruction_EVA()
RETURNS TABLE (
  zone    Zone_id,
  plac    Placette_id,
  nature  obstruction_nature,
  hauteur hauteur_obs,
  tcat    TTaux,
  tval    Taux_val
)
BEGIN ATOMIC
  SELECT zone, plac, nature, hauteur, tcat, tval
  FROM Placette_Obstruction;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Placette_Obstruction_INS(
  _zone    Zone_id,
  _plac    Placette_id,
  _nature  obstruction_nature,
  _hauteur hauteur_obs,
  _tcat    TTaux,
  _tval    Taux_val
)
BEGIN ATOMIC
  INSERT INTO Placette_Obstruction (zone, plac, nature, hauteur, tcat, tval)
  VALUES (_zone, _plac, _nature, _hauteur, _tcat, _tval);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Placette_Obstruction_MOD(
  _zone    Zone_id,
  _plac    Placette_id,
  _nature  obstruction_nature,
  _hauteur hauteur_obs,
  _tcat    TTaux,
  _tval    Taux_val
)
BEGIN ATOMIC
  UPDATE Placette_Obstruction
  SET zone = _zone,
      tcat = _tcat,
      tval = _tval
  WHERE plac = _plac AND nature = _nature AND hauteur = _hauteur;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Placette_Obstruction_RET(
  _plac    Placette_id,
  _nature  obstruction_nature,
  _hauteur hauteur_obs
)
BEGIN ATOMIC
  DELETE FROM Placette_Obstruction
  WHERE plac = _plac AND nature = _nature AND hauteur = _hauteur;
END;

---------------------------------
-- Placette_Couvert
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".Placette_Couvert_EVA()
RETURNS TABLE (
  zone  Zone_id,
  plac  Placette_id,
  ctype couvert_type,
  tcat  TTaux,
  tval  Taux_val
)
BEGIN ATOMIC
  SELECT zone, plac, ctype, tcat, tval
  FROM Placette_Couvert;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Placette_Couvert_INS(
  _zone  Zone_id,
  _plac  Placette_id,
  _ctype couvert_type,
  _tcat  TTaux,
  _tval  Taux_val
)
BEGIN ATOMIC
  INSERT INTO Placette_Couvert (zone, plac, ctype, tcat, tval)
  VALUES (_zone, _plac, _ctype, _tcat, _tval);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Placette_Couvert_MOD(
  _zone  Zone_id,
  _plac  Placette_id,
  _ctype couvert_type,
  _tcat  TTaux,
  _tval  Taux_val
)
BEGIN ATOMIC
  UPDATE Placette_Couvert
  SET zone = _zone,
      tcat = _tcat,
      tval = _tval
  WHERE plac = _plac AND ctype = _ctype;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Placette_Couvert_RET(
  _plac  Placette_id,
  _ctype couvert_type
)
BEGIN ATOMIC
  DELETE FROM Placette_Couvert
  WHERE plac = _plac AND ctype = _ctype;
END;

---------------------------------
-- Parcelle
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".Parcelle_EVA()
RETURNS TABLE (
  zone     Zone_id,
  plac     Placette_id,
  parcelle Parcelle_id
)
BEGIN ATOMIC
  SELECT zone, plac, parcelle
  FROM Parcelle;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Parcelle_INS(
  _zone     Zone_id,
  _plac     Placette_id,
  _parcelle Parcelle_id
)
BEGIN ATOMIC
  INSERT INTO Parcelle (zone, plac, parcelle)
  VALUES (_zone, _plac, _parcelle);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Parcelle_MOD(
  _zone     Zone_id,
  _plac     Placette_id,
  _parcelle Parcelle_id
)
BEGIN ATOMIC
  UPDATE Parcelle
  SET zone = _zone
  WHERE zone = _zone AND plac = _plac AND parcelle = _parcelle;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Parcelle_RET(
  _zone     Zone_id,
  _plac     Placette_id,
  _parcelle Parcelle_id
)
BEGIN ATOMIC
  DELETE FROM Parcelle
  WHERE zone = _zone AND plac = _plac AND parcelle = _parcelle;
END;

---------------------------------
-- Plant
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".Plant_EVA()
RETURNS TABLE (
  zone Zone_id,
  id   Plant_id,
  plac Placette_id,
  date Date_eco,
  note Description
)
BEGIN ATOMIC
  SELECT zone, id, plac, date, note
  FROM Plant;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Plant_INS(
  _zone Zone_id,
  _id   Plant_id,
  _plac Placette_id,
  _date Date_eco,
  _note Description
)
BEGIN ATOMIC
  INSERT INTO Plant (zone, id, plac, date, note)
  VALUES (_zone, _id, _plac, _date, _note);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Plant_MOD(
  _zone Zone_id,
  _id   Plant_id,
  _plac Placette_id,
  _date Date_eco,
  _note Description
)
BEGIN ATOMIC
  UPDATE Plant
  SET zone = _zone,
      plac = _plac,
      date = _date,
      note = _note
  WHERE id = _id;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Plant_RET(
  _id Plant_id
)
BEGIN ATOMIC
  DELETE FROM Plant
  WHERE id = _id;
END;

---------------------------------
-- ObsDimension
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".ObsDimension_EVA()
RETURNS TABLE (
  id       Plant_id,
  longueur Dim_mm,
  largeur  Dim_mm,
  date     Date_eco,
  unite_id unite_id,
  note     Description
)
BEGIN ATOMIC
  SELECT id, longueur, largeur, date, unite_id, note
  FROM ObsDimension;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".ObsDimension_INS(
  _id       Plant_id,
  _longueur Dim_mm,
  _largeur  Dim_mm,
  _date     Date_eco,
  _unite_id unite_id,
  _note     Description
)
BEGIN ATOMIC
  INSERT INTO ObsDimension (id, longueur, largeur, date, unite_id, note)
  VALUES (_id, _longueur, _largeur, _date, _unite_id, _note);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".ObsDimension_MOD(
  _id       Plant_id,
  _longueur Dim_mm,
  _largeur  Dim_mm,
  _date     Date_eco,
  _unite_id unite_id,
  _note     Description
)
BEGIN ATOMIC
  UPDATE ObsDimension
  SET longueur = _longueur,
      largeur  = _largeur,
      unite_id = _unite_id,
      note     = _note
  WHERE id = _id AND date = _date;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".ObsDimension_RET(
  _id   Plant_id,
  _date Date_eco
)
BEGIN ATOMIC
  DELETE FROM ObsDimension
  WHERE id = _id AND date = _date;
END;

---------------------------------
-- ObsFloraison
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".ObsFloraison_EVA()
RETURNS TABLE (
  id    Plant_id,
  fleur BOOLEAN,
  date  Date_eco,
  note  Description
)
BEGIN ATOMIC
  SELECT id, fleur, date, note
  FROM ObsFloraison;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".ObsFloraison_INS(
  _id   Plant_id,
  _fleur BOOLEAN,
  _date  Date_eco,
  _note  Description
)
BEGIN ATOMIC
  INSERT INTO ObsFloraison (id, fleur, date, note)
  VALUES (_id, _fleur, _date, _note);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".ObsFloraison_MOD(
  _id   Plant_id,
  _fleur BOOLEAN,
  _date  Date_eco,
  _note  Description
)
BEGIN ATOMIC
  UPDATE ObsFloraison
  SET fleur = _fleur,
      note  = _note
  WHERE id = _id AND date = _date;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".ObsFloraison_RET(
  _id   Plant_id,
  _date Date_eco
)
BEGIN ATOMIC
  DELETE FROM ObsFloraison
  WHERE id = _id AND date = _date;
END;

---------------------------------
-- Etat
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".Etat_EVA()
RETURNS TABLE (
  etat        Etat_id,
  description Description
)
BEGIN ATOMIC
  SELECT etat, description
  FROM Etat;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Etat_INS(
  _etat Etat_id,
  _description Description
)
BEGIN ATOMIC
  INSERT INTO Etat (etat, description)
  VALUES (_etat, _description);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Etat_MOD(
  _etat Etat_id,
  _description Description
)
BEGIN ATOMIC
  UPDATE Etat
  SET description = _description
  WHERE etat = _etat;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".Etat_RET(
  _etat Etat_id
)
BEGIN ATOMIC
  DELETE FROM Etat
  WHERE etat = _etat;
END;

---------------------------------
-- ObsEtat
---------------------------------
CREATE OR REPLACE FUNCTION "Herbivorie".ObsEtat_EVA()
RETURNS TABLE (
  id   Plant_id,
  etat Etat_id,
  date Date_eco,
  note Description
)
BEGIN ATOMIC
  SELECT id, etat, date, note
  FROM ObsEtat;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".ObsEtat_INS(
  _id   Plant_id,
  _etat Etat_id,
  _date Date_eco,
  _note Description
)
BEGIN ATOMIC
  INSERT INTO ObsEtat (id, etat, date, note)
  VALUES (_id, _etat, _date, _note);
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".ObsEtat_MOD(
  _id   Plant_id,
  _etat Etat_id,
  _date Date_eco,
  _note Description
)
BEGIN ATOMIC
  UPDATE ObsEtat
  SET etat = _etat,
      note = _note
  WHERE id = _id AND date = _date;
END;

CREATE OR REPLACE PROCEDURE "Herbivorie".ObsEtat_RET(
  _id   Plant_id,
  _date Date_eco
)
BEGIN ATOMIC
  DELETE FROM ObsEtat
  WHERE id = _id AND date = _date;
END;
