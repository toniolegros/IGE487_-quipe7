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
    id "Herbivorie".Site_id,
    site "Herbivorie".Description,
    description "Herbivorie".Description
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id, site, description
    FROM "Herbivorie".Site;
$$;

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
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id AS s_id, zone, description
    FROM "Herbivorie".Zone;
$$;

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
--  Table: Placette(id, zone, plac)
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Placette_EVA()
RETURNS TABLE (
    id Site_id,
    zone Zone_id,
    plac Placette_id
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id, zone, plac
    FROM "Herbivorie".Placette;
$$;

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
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id, zone, plac, parcelle
    FROM "Herbivorie".Parcelle;
$$;

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
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT peup, description
    FROM "Herbivorie".Peuplement;
$$;

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
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT arbre, description
    FROM "Herbivorie".Arbre;
$$;

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
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT s_id, zone, id, plac, date, note
    FROM "Herbivorie".Plant;
$$;

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
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id, zone, plac, peup, date
    FROM "Herbivorie".Placette_core;
$$;

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
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id, zone, plac, rang, arbre
    FROM "Herbivorie".Placette_Dominant;
$$;

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
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id, zone, plac, nature, hauteur, tcat, tval
    FROM "Herbivorie".Placette_Obstruction;
$$;

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
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id, zone, plac, ctype, tcat, tval
    FROM "Herbivorie".Placette_Couvert;
$$;

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
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id, longueur, largeur, date, unite_id, note
    FROM "Herbivorie".ObsDimension;
$$;

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
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id, fleur, date, note
    FROM "Herbivorie".ObsFloraison;
$$;

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
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT id, etat, date, note
    FROM "Herbivorie".ObsEtat;
$$;

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


CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Stat_Dimension_Resume()
RETURNS TABLE (
    longueur_moyenne NUMERIC,
    longueur_mediane NUMERIC,
    longueur_min NUMERIC,
    longueur_max NUMERIC,
    largeur_moyenne NUMERIC,
    largeur_mediane NUMERIC,
    largeur_min NUMERIC,
    largeur_max NUMERIC
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT
        AVG(longueur) AS longueur_moyenne,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY longueur) AS longueur_mediane,
        MIN(longueur),
        MAX(longueur),
        AVG(largeur) AS largeur_moyenne,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY largeur),
        MIN(largeur),
        MAX(largeur)
    FROM "Herbivorie".ObsDimension;
$$;


CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Stat_Floraison_Taux()
RETURNS TABLE (
    site Site_id,
    zone Zone_id,
    taux_floraison NUMERIC
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT
        p.s_id AS site,
        p.zone,
        AVG(CASE WHEN f.fleur THEN 1 ELSE 0 END)::NUMERIC AS taux_floraison
    FROM "Herbivorie".Plant p
    LEFT JOIN "Herbivorie".ObsFloraison f ON f.id = p.id
    GROUP BY p.s_id, p.zone
    ORDER BY p.s_id, p.zone;
$$;


CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Stat_Age_Placette()
RETURNS TABLE (
    id Site_id,
    zone Zone_id,
    plac Placette_id,
    age_jours INTEGER
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT
        id,
        zone,
        plac,
        (CURRENT_DATE - date)::INTEGER AS age_jours
    FROM "Herbivorie".Placette_core;
$$;

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Stat_Peuplement_Repartition()
RETURNS TABLE (
    peuplement Peuplement_id,
    nb_placettes INTEGER
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT
        peup,
        COUNT(*)
    FROM "Herbivorie".Placette_core
    GROUP BY peup
    ORDER BY peup;
$$;

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Stat_Diversite_Arbres()
RETURNS TABLE (
    id Site_id,
    zone Zone_id,
    plac Placette_id,
    indice_shannon NUMERIC
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT
        id,
        zone,
        plac,
        -SUM( freq * LOG(freq) ) AS indice_shannon
    FROM (
        SELECT
            id,
            zone,
            plac,
            arbre,
            COUNT(*)::DECIMAL / SUM(COUNT(*)) OVER (PARTITION BY id, zone, plac) AS freq
        FROM "Herbivorie".Placette_Dominant
        GROUP BY id, zone, plac, arbre
    ) t
    GROUP BY id, zone, plac;
$$;

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Stat_Survie_Plantes(_jours INTEGER)
RETURNS TABLE (
    id Plant_id,
    vivante BOOLEAN
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT
        id,
        (CURRENT_DATE - date) < _jours AS vivante
    FROM "Herbivorie".Plant;
$$;

CREATE OR REPLACE FUNCTION "Herbivorie_lecture".Stat_Croissance()
RETURNS TABLE(
    id Plant_id,
    croissance_longueur NUMERIC,
    croissance_largeur NUMERIC
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT
        id,
        MAX(longueur) - MIN(longueur) AS croissance_longueur,
        MAX(largeur) - MIN(largeur) AS croissance_largeur
    FROM "Herbivorie".ObsDimension
    GROUP BY id;
$$;


