SET SCHEMA 'Herbivorie';

-- Date_eco
CREATE OR REPLACE FUNCTION DateEco_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
DECLARE
  d date;
BEGIN
  -- Tentative de conversion sécurisée
  BEGIN
    d := v::date;
  EXCEPTION WHEN others THEN
    -- Si la conversion échoue (format pourri, valeur impossible)
    RETURN FALSE;
  END;
  RETURN v::date >= DATE '1582-12-20' AND v::date <= current_date;
END;
$$;

CREATE OR REPLACE FUNCTION DateEco_CONV(v text)
RETURNS Date_eco
LANGUAGE plpgsql AS $$
DECLARE
  result Date_eco;
BEGIN
    IF NOT DateEco_verif(v) THEN
    RETURN NULL;
  END IF;
  result := v::Date_eco;
  RETURN result;
    EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION DateEco_verif(v Date_eco)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v >= DATE '1582-12-20' AND v <= current_date;
END;
$$;

CREATE OR REPLACE FUNCTION DateEco_CONV(v Date_eco)
RETURNS Date_eco
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

--Site
-- Site_id basé sur la table megantic
CREATE OR REPLACE FUNCTION Site_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v IS NOT NULL
     AND v SIMILAR TO '[A-Z]{2}[0-9]{2}'
     AND EXISTS (
       SELECT 1 FROM megantic m
       WHERE m.site_id = v
     );
END;
$$;

CREATE OR REPLACE FUNCTION Site_conv(v text)
RETURNS Site_id
LANGUAGE plpgsql AS $$
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

-- Zone
-- Zone_id basé sur megantic.zone
CREATE OR REPLACE FUNCTION Zone_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v IS NOT NULL
     AND v SIMILAR TO 'MM[A-C]'
     AND EXISTS (
       SELECT 1 FROM megantic m
       WHERE m.zone = v
     );
END;
$$;

CREATE OR REPLACE FUNCTION Zone_conv(v text)
RETURNS Zone_id
LANGUAGE plpgsql AS $$
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


-- ===========================
--  Obstruction_nature (TEXT)
-- ===========================
CREATE OR REPLACE FUNCTION ObstructionNature_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
DECLARE
  tmp obstruction_nature;
BEGIN
  -- On tente le cast, mais on NE laisse pas l'exception remonter
  BEGIN
    tmp := v::obstruction_nature;
  EXCEPTION WHEN others THEN
    RETURN FALSE;          -- valeur invalide (ex: 'rocheux')
  END;

  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION ObstructionNature_CONV(v text)
RETURNS obstruction_nature
LANGUAGE plpgsql AS $$
DECLARE
  result obstruction_nature;
BEGIN
  -- Si ce n’est pas valide, on renvoie NULL (et l’ELT filtrera)
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
LANGUAGE plpgsql AS $$
BEGIN
  -- Une valeur déjà typée obstruction_nature est forcément valide
  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION ObstructionNature_CONV(v obstruction_nature)
RETURNS obstruction_nature
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;


-- ==================
--  Hauteur_obs (TEXT)
-- ==================
CREATE OR REPLACE FUNCTION HauteurObs_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
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
LANGUAGE plpgsql AS $$
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

-- surcharge ENUM
CREATE OR REPLACE FUNCTION HauteurObs_verif(v hauteur_obs)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION HauteurObs_CONV(v hauteur_obs)
RETURNS hauteur_obs
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

--Couvert
CREATE OR REPLACE FUNCTION CouvertType_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
DECLARE
  tmp couvert_type;
BEGIN
  BEGIN
    tmp := v::couvert_type;   -- 'herbes' va tomber ici
  EXCEPTION WHEN others THEN
    RETURN FALSE;             -- on NE jette PAS d'exception, on renvoie FALSE
  END;

  RETURN TRUE;
END;
$$;


CREATE OR REPLACE FUNCTION CouvertType_conv(v text)
RETURNS couvert_type
LANGUAGE plpgsql AS $$
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
LANGUAGE plpgsql AS $$
BEGIN
  RETURN true;
END;
$$;

CREATE OR REPLACE FUNCTION CouvertType_CONV(v couvert_type)
RETURNS couvert_type
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

-- Plant_id
-- Plant_id basé sur megantic.id
CREATE OR REPLACE FUNCTION Plant_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v IS NOT NULL
     AND v SIMILAR TO 'MM[A-C][0-9]{4}'
     AND EXISTS (
       SELECT 1 FROM megantic m
       WHERE m.id = v
     );
END;
$$;

CREATE OR REPLACE FUNCTION Plant_conv(v text)
RETURNS Plant_id
LANGUAGE plpgsql AS $$
DECLARE
  result Plant_id;
BEGIN
  IF NOT Plant_verif(v) THEN
    RETURN NULL;
  END IF;
  result := v::Plant_id;
  RETURN result;
EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$$;

-- Placette_id
-- Placette_id basé sur megantic.plac
CREATE OR REPLACE FUNCTION Placette_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v IS NOT NULL
     AND v SIMILAR TO '[A-Z][0-9]'
     AND EXISTS (
       SELECT 1 FROM megantic m
       WHERE m.plac = v
     );
END;
$$;

CREATE OR REPLACE FUNCTION Placette_conv(v text)
RETURNS Placette_id
LANGUAGE plpgsql AS $$
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

-- Peuplement_id
-- Peuplement_id basé sur megantic.peup
CREATE OR REPLACE FUNCTION Peuplement_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v IS NOT NULL
     AND v SIMILAR TO '[A-Z][0-9]{4}'
     AND EXISTS (
       SELECT 1 FROM megantic m
       WHERE m.peup = v
     );
END;
$$;

CREATE OR REPLACE FUNCTION Peuplement_conv(v text)
RETURNS Peuplement_id
LANGUAGE plpgsql AS $$
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

-- Arbre_id
CREATE OR REPLACE FUNCTION Arbre_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v IS NOT NULL
     AND v SIMILAR TO '[A-Z]{2}[0-9]{2}'
     AND EXISTS (
       SELECT 1 FROM megantic m
       WHERE m.arbre = v
     );
END;
$$;

CREATE OR REPLACE FUNCTION Arbre_conv(v text)
RETURNS Arbre_id
LANGUAGE plpgsql AS $$
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

-- Parcelle
CREATE OR REPLACE FUNCTION Parcelle_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
DECLARE
  p integer;
BEGIN
  BEGIN
    p := v::integer;
  EXCEPTION WHEN others THEN
     RETURN FALSE;
  END;

  RETURN p BETWEEN 1 AND 99;
END;
$$;

CREATE OR REPLACE FUNCTION Parcelle_CONV(v text)
RETURNS Parcelle_id
LANGUAGE plpgsql AS $$
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

CREATE OR REPLACE FUNCTION Parcelle_verif(v Parcelle_id)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v BETWEEN 0 AND 99;
END;
$$;

CREATE OR REPLACE FUNCTION Parcelle_CONV(v Parcelle_id)
RETURNS Parcelle_id
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

-- Dim_mm
CREATE OR REPLACE FUNCTION Dim_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v ~ '^[0-9]{1,3}$' AND v::integer BETWEEN 1 AND 999;
END;
$$;

CREATE OR REPLACE FUNCTION Dim_CONV(v text)
RETURNS Dim_mm
LANGUAGE plpgsql AS $$
DECLARE
  result Dim_mm;
BEGIN
  result := v::Dim_mm;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION Dim_verif(v Dim_mm)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v BETWEEN 1 AND 999;
END;
$$;

CREATE OR REPLACE FUNCTION Dim_CONV(v Dim_mm)
RETURNS Dim_mm
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

CREATE OR REPLACE FUNCTION TCat_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
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
LANGUAGE plpgsql AS $$
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

--État
-- Etat_id basé sur megantic.etat
CREATE OR REPLACE FUNCTION Etat_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
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

  RETURN EXISTS (
    SELECT 1 FROM megantic m
    WHERE upper(btrim(m.etat)) = upper(btrim(v))
  );
END;
$$;

CREATE OR REPLACE FUNCTION Etat_conv(v text)
RETURNS Etat_id
LANGUAGE plpgsql AS $$
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

-- Description
CREATE OR REPLACE FUNCTION Description_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN char_length(v) BETWEEN 1 AND 400;
END;
$$;

CREATE OR REPLACE FUNCTION Description_CONV(v text)
RETURNS Description
LANGUAGE plpgsql AS $$
DECLARE
  result Description;
BEGIN
  result := v::Description;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION Description_verif(v Description)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN char_length(v) BETWEEN 1 AND 400;
END;
$$;

CREATE OR REPLACE FUNCTION Description_CONV(v Description)
RETURNS Description
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

