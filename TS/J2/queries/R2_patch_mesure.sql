SET search_path TO "Herbivorie", public;

-- Place (ou crée) la table Mesure dans le schéma "Herbivorie"
DO $$
BEGIN
  IF to_regclass('public.mesure') IS NOT NULL AND to_regclass('"Herbivorie".Mesure') IS NULL THEN
    ALTER TABLE public.mesure SET SCHEMA "Herbivorie";
  ELSIF to_regclass('"Herbivorie".Mesure') IS NULL THEN
    CREATE TABLE "Herbivorie".Mesure (
      mesure_id     BIGSERIAL PRIMARY KEY,
      typemesure_id TEXT,
      unite_id      TEXT,
      valeur        NUMERIC,
      date_obs      DATE,
      source        TEXT,
      commentaire   TEXT
    );
  END IF;
END
$$ LANGUAGE plpgsql;
