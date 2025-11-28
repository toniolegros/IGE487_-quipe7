SET SCHEMA 'Herbivorie';

-------------------------------------------------
-- Date_eco
-------------------------------------------------
CREATE OR REPLACE FUNCTION DateEco_verif(v text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  d date;
BEGIN
  IF v IS NULL THEN
      RETURN FALSE;
  END IF;

  BEGIN
    d := v::date;
  EXCEPTION WHEN others THEN
    RETURN FALSE;
  END;

  RETURN d >= DATE '1582-12-20'
     AND d <= current_date;
END;
$$;

CREATE OR REPLACE FUNCTION DateEco_conv(v text)
RETURNS Date_eco
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result Date_eco;
BEGIN
  IF NOT DateEco_verif(v) THEN
    RETURN NULL;
  END IF;

  result := v::date;
  RETURN result;

EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION DateEco_verif(v Date_eco)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN v >= DATE '1582-12-20' AND v <= current_date;
END;
$$;

CREATE OR REPLACE FUNCTION DateEco_CONV(v Date_eco)
RETURNS Date_eco
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN v;
END;
$$;

-------------------------------------------------
-- Site_id (basé sur la forme uniquement)
-- ex : MA, MB, MI, etc.
-------------------------------------------------
CREATE OR REPLACE FUNCTION Site_verif(v text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN v IS NOT NULL;
     --AND v ~ '^M[A-Z]$';
END;
$$;

CREATE OR REPLACE FUNCTION Site_conv(v text)
RETURNS Site_id
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result Site_id;
BEGIN
  IF NOT Site_verif(v) THEN
    RETURN NULL;
  END IF;

  result := v::Site_id;
  RETURN result;

EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$$;

-------------------------------------------------
-- Zone_id (3 lettres, ex : MIA, MIB, MMA, ...)
-------------------------------------------------
CREATE OR REPLACE FUNCTION Zone_verif(v text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN v IS NOT NULL;
    -- AND v ~ '^[A-Z]{3}$';
END;
$$;

CREATE OR REPLACE FUNCTION Zone_conv(v text)
RETURNS Zone_id
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result Zone_id;
BEGIN
  IF NOT Zone_verif(v) THEN
    RETURN NULL;
  END IF;

  result := v::Zone_id;
  RETURN result;

EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$$;

-------------------------------------------------
-- Obstruction_nature (ENUM / domaine)
-------------------------------------------------
CREATE OR REPLACE FUNCTION ObstructionNature_verif(v text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  tmp obstruction_nature;
BEGIN
  BEGIN
    tmp := v::obstruction_nature;
  EXCEPTION WHEN others THEN
    RETURN FALSE;
  END;

  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION ObstructionNature_CONV(v text)
RETURNS obstruction_nature
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result obstruction_nature;
BEGIN
  IF NOT ObstructionNature_verif(v) THEN
    RETURN NULL;
  END IF;

  BEGIN
    result := v::obstruction_nature;
  EXCEPTION WHEN others THEN
    RETURN NULL;
  END;

  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION ObstructionNature_verif(v obstruction_nature)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION ObstructionNature_CONV(v obstruction_nature)
RETURNS obstruction_nature
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN v;
END;
$$;

-------------------------------------------------
-- Hauteur_obs (ENUM / domaine)
-------------------------------------------------
CREATE OR REPLACE FUNCTION HauteurObs_verif(v text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  tmp hauteur_obs;
BEGIN
  BEGIN
    tmp := v::hauteur_obs;
  EXCEPTION WHEN others THEN
    RETURN FALSE;
  END;

  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION HauteurObs_CONV(v text)
RETURNS hauteur_obs
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result hauteur_obs;
BEGIN
  IF NOT HauteurObs_verif(v) THEN
    RETURN NULL;
  END IF;

  BEGIN
    result := v::hauteur_obs;
  EXCEPTION WHEN others THEN
    RETURN NULL;
  END;

  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION HauteurObs_verif(v hauteur_obs)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION HauteurObs_CONV(v hauteur_obs)
RETURNS hauteur_obs
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN v;
END;
$$;

-------------------------------------------------
-- Couvert_type (ENUM / domaine)
-------------------------------------------------
CREATE OR REPLACE FUNCTION CouvertType_verif(v text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  tmp couvert_type;
BEGIN
  BEGIN
    tmp := v::couvert_type;
  EXCEPTION WHEN others THEN
    RETURN FALSE;
  END;

  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION CouvertType_conv(v text)
RETURNS couvert_type
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result couvert_type;
BEGIN
  IF NOT CouvertType_verif(v) THEN
    RETURN NULL;
  END IF;

  result := v::couvert_type;
  RETURN result;

EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION CouvertType_verif(v couvert_type)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION CouvertType_CONV(v couvert_type)
RETURNS couvert_type
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN v;
END;
$$;

-------------------------------------------------
-- Plant_id (ex : MIA0001)
-------------------------------------------------
CREATE OR REPLACE FUNCTION Plant_verif(v text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN v IS NOT NULL
     AND v ~ '^[A-Z]{3}[0-9]{4}$';
END;
$$;

CREATE OR REPLACE FUNCTION Plant_conv(v text)
RETURNS Plant_id
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result Plant_id;
BEGIN
  IF Plant_verif(v) THEN
    RETURN CAST(v AS Plant_id);
  ELSE
    RETURN NULL;
  END IF;

EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$$;

-------------------------------------------------
-- Placette_id (une lettre A–Z + un ou plusieurs chiffres)
-- ex : A1, B2, Z14, M123
-------------------------------------------------
CREATE OR REPLACE FUNCTION Placette_verif(v text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN v IS NOT NULL
     AND v ~ '^[A-Z][0-9]+$';
END;
$$;

CREATE OR REPLACE FUNCTION Placette_conv(v text)
RETURNS Placette_id
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result Placette_id;
BEGIN
  IF NOT Placette_verif(v) THEN
    RETURN NULL;
  END IF;

  result := v::Placette_id;
  RETURN result;

EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$$;

-------------------------------------------------
-- Peuplement_id (1 lettre + 4 chiffres, ex : A0001)
-------------------------------------------------
CREATE OR REPLACE FUNCTION Peuplement_verif(v text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN v IS NOT NULL
     AND v ~ '^[A-Z][0-9]{4}$';
END;
$$;

CREATE OR REPLACE FUNCTION Peuplement_conv(v text)
RETURNS Peuplement_id
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result Peuplement_id;
BEGIN
  IF NOT Peuplement_verif(v) THEN
    RETURN NULL;
  END IF;

  result := v::Peuplement_id;
  RETURN result;

EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$$;

-------------------------------------------------
-- Arbre_id (2 lettres + 2 chiffres, ex : AB12)
-------------------------------------------------
CREATE OR REPLACE FUNCTION Arbre_verif(v text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN v IS NOT NULL
     AND v ~ '^[A-Z]{2}[0-9]{2}$';
END;
$$;

CREATE OR REPLACE FUNCTION Arbre_conv(v text)
RETURNS Arbre_id
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result Arbre_id;
BEGIN
  IF NOT Arbre_verif(v) THEN
    RETURN NULL;
  END IF;

  result := v::Arbre_id;
  RETURN result;

EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$$;

-------------------------------------------------
-- Parcelle_id (1–99)
-------------------------------------------------
CREATE OR REPLACE FUNCTION Parcelle_verif(v text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  p integer;
BEGIN
  BEGIN
    p := v::integer;
  EXCEPTION WHEN others THEN
     RETURN FALSE;
  END;

  RETURN p BETWEEN 0 AND 99;
END;
$$;

CREATE OR REPLACE FUNCTION Parcelle_CONV(v text)
RETURNS Parcelle_id
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result Parcelle_id;
BEGIN
  IF NOT Parcelle_verif(v) THEN
    RETURN NULL;
  END IF;

  result := v::Parcelle_id;
  RETURN result;

EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$$;

-------------------------------------------------
-- Dim_mm (1 à 3 chiffres, 1..999)
-------------------------------------------------
CREATE OR REPLACE FUNCTION Dim_verif(v text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN v ~ '^[0-9]{1,3}$'
     AND v::integer BETWEEN 0 AND 999;
END;
$$;

CREATE OR REPLACE FUNCTION Dim_CONV(v text)
RETURNS Dim_mm
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result Dim_mm;
BEGIN
  result := v::Dim_mm;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION Dim_verif(v Dim_mm)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN v BETWEEN 0 AND 999;
END;
$$;

CREATE OR REPLACE FUNCTION Dim_CONV(v Dim_mm)
RETURNS Dim_mm
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN v;
END;
$$;

-------------------------------------------------
-- TCat / TTaux (ENUM ou domaine)
-------------------------------------------------
CREATE OR REPLACE FUNCTION TCat_verif(v text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  tmp TTaux;
BEGIN
  BEGIN
    tmp := v::TTaux;
  EXCEPTION WHEN others THEN
    RETURN FALSE;
  END;

  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION TCat_conv(v text)
RETURNS TTaux
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result TTaux;
BEGIN
  IF NOT TCat_verif(v) THEN
    RETURN NULL;
  END IF;

  result := v::TTaux;
  RETURN result;

EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$$;

-------------------------------------------------
-- Etat_id (basé sur domaine / enum Etat_id)
-------------------------------------------------
CREATE OR REPLACE FUNCTION Etat_verif(v text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  tmp Etat_id;
BEGIN
  IF v IS NULL THEN
    RETURN FALSE;
  END IF;

  BEGIN
    tmp := upper(btrim(v))::Etat_id;
  EXCEPTION WHEN others THEN
    RETURN FALSE;
  END;

  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION Etat_conv(v text)
RETURNS Etat_id
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result Etat_id;
BEGIN
  IF NOT Etat_verif(v) THEN
    RETURN NULL;
  END IF;

  result := upper(btrim(v))::Etat_id;
  RETURN result;

EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$$;

-------------------------------------------------
-- Description
-------------------------------------------------
CREATE OR REPLACE FUNCTION Description_verif(v text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN char_length(v) BETWEEN 1 AND 400;
END;
$$;

CREATE OR REPLACE FUNCTION Description_CONV(v text)
RETURNS Description
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result Description;
BEGIN
  result := v::Description;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION Description_verif(v Description)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN char_length(v) BETWEEN 1 AND 400;
END;
$$;

CREATE OR REPLACE FUNCTION Description_CONV(v Description)
RETURNS Description
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN v;
END;
$$;
