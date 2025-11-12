SET SCHEMA 'Herbivorie';

-- Date_eco
CREATE OR REPLACE FUNCTION DateEco_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v::date >= DATE '1582-12-20' AND v::date <= current_date;
END;
$$;

CREATE OR REPLACE FUNCTION DateEco_CONV(v text)
RETURNS Date_eco
LANGUAGE plpgsql AS $$
DECLARE
  result Date_eco;
BEGIN
  result := v::Date_eco;
  RETURN result;
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
CREATE OR REPLACE FUNCTION Site_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v IN (SELECT id FROM site);
END;
$$;

CREATE OR REPLACE FUNCTION site_CONV(v text)
RETURNS site_id
LANGUAGE plpgsql AS $$
DECLARE
  result site_id;
BEGIN
  result := v::site_id;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION site_verif(v Etat_id)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

CREATE OR REPLACE FUNCTION site_CONV(v Etat_id)
RETURNS site_id
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

-- Zone
CREATE OR REPLACE FUNCTION Zone_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v IN (SELECT zone FROM Zone);
END;
$$;

CREATE OR REPLACE FUNCTION Zone_CONV(v text)
RETURNS Zone_id
LANGUAGE plpgsql AS $$
DECLARE
  result Zone_id;
BEGIN
  result := v::Zone_id;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION Zone_verif(v Zone_id)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

CREATE OR REPLACE FUNCTION Zone_CONV(v Zone_id)
RETURNS Zone_id
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

--Obstruction_nature
CREATE OR REPLACE FUNCTION ObstructionNature_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v IN ('feuillu', 'coniferien', 'total');
END;
$$;

CREATE OR REPLACE FUNCTION ObstructionNature_CONV(v text)
RETURNS obstruction_nature
LANGUAGE plpgsql AS $$
DECLARE
  result obstruction_nature;
BEGIN
  result := v::obstruction_nature;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION ObstructionNature_verif(v obstruction_nature)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

CREATE OR REPLACE FUNCTION ObstructionNature_CONV(v obstruction_nature)
RETURNS obstruction_nature
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

-- hauteur_obs
CREATE OR REPLACE FUNCTION HauteurObs_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v IN ('1m', '2m');
END;
$$;

CREATE OR REPLACE FUNCTION HauteurObs_CONV(v text)
RETURNS hauteur_obs
LANGUAGE plpgsql AS $$
DECLARE
  result hauteur_obs;
BEGIN
  result := v::hauteur_obs;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION HauteurObs_verif(v hauteur_obs)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
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
BEGIN
  RETURN v IN ('graminees', 'mousses', 'fougeres');
END;
$$;

CREATE OR REPLACE FUNCTION CouvertType_CONV(v text)
RETURNS couvert_type
LANGUAGE plpgsql AS $$
DECLARE
  result couvert_type;
BEGIN
  result := v::couvert_type;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION CouvertType_verif(v couvert_type)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
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
CREATE OR REPLACE FUNCTION Plant_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v IN (SELECT id FROM megantic);
END;
$$;

CREATE OR REPLACE FUNCTION Plant_CONV(v text)
RETURNS plant_id
LANGUAGE plpgsql AS $$
DECLARE
  result plant_id;
BEGIN
  result := v::plant_id;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION Plant_verif(v plant_id)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

CREATE OR REPLACE FUNCTION Plant_CONV(v plant_id)
RETURNS plant_id
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

-- Placette_id
CREATE OR REPLACE FUNCTION Placette_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v IN (SELECT placette1 FROM megantic);
END;
$$;


CREATE OR REPLACE FUNCTION Placette_CONV(v text)
RETURNS placette_id
LANGUAGE plpgsql AS $$
DECLARE
  result placette_id;
BEGIN
  result := v::placette_id;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION Placette_verif(v placette_id)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;


CREATE OR REPLACE FUNCTION Placette_CONV(v placette_id)
RETURNS placette_id
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

-- Peuplement_id

CREATE OR REPLACE FUNCTION Peuplement_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v IN (SELECT peup FROM peuplement);
END;
$$;

CREATE OR REPLACE FUNCTION Peuplement_CONV(v text)
RETURNS Peuplement_id
LANGUAGE plpgsql AS $$
DECLARE
  result Peuplement_id;
BEGIN
  result := v::Peuplement_id;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION Peuplement_verif(v Peuplement_id)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

CREATE OR REPLACE FUNCTION Peuplement_CONV(v Peuplement_id)
RETURNS Peuplement_id
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

-- Arbre_id
CREATE OR REPLACE FUNCTION Arbre_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v IN (SELECT arbre FROM Arbre);
END;
$$;

CREATE OR REPLACE FUNCTION Arbre_CONV(v text)
RETURNS Arbre_id
LANGUAGE plpgsql AS $$
DECLARE
  result Arbre_id;
BEGIN
  result := v::Arbre_id;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION Arbre_verif(v Arbre_id)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

CREATE OR REPLACE FUNCTION Arbre_CONV(v Arbre_id)
RETURNS Arbre_id
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

-- Parcelle
CREATE OR REPLACE FUNCTION Parcelle_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v ~ '^[0-9]{1,2}$' AND v::integer BETWEEN 0 AND 99;
END;
$$;

CREATE OR REPLACE FUNCTION Parcelle_CONV(v text)
RETURNS Parcelle
LANGUAGE plpgsql AS $$
DECLARE
  result Parcelle;
BEGIN
  result := v::Parcelle;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION Parcelle_verif(v Parcelle)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v BETWEEN 0 AND 99;
END;
$$;

CREATE OR REPLACE FUNCTION Parcelle_CONV(v Parcelle)
RETURNS Parcelle
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

--État
CREATE OR REPLACE FUNCTION Etat_verif(v text)
RETURNS boolean
LANGUAGE plpgsql AS $$
DECLARE
  result Etat_id;
BEGIN
  BEGIN
    result := upper(btrim(v))::Etat_id;
    RETURN TRUE;
  EXCEPTION WHEN others THEN
    RETURN FALSE;
  END;
END;
$$;

CREATE OR REPLACE FUNCTION Etat_CONV(v text)
RETURNS Etat_id
LANGUAGE plpgsql AS $$
DECLARE
  result Etat_id;
BEGIN
  result := upper(btrim(v))::Etat_id;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION Etat_verif(v Etat_id)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
END;
$$;

CREATE OR REPLACE FUNCTION Etat_CONV(v Etat_id)
RETURNS Etat_id
LANGUAGE plpgsql AS $$
BEGIN
  RETURN v;
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

