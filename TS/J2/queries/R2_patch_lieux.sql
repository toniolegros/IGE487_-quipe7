SET search_path TO "Herbivorie", public;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'Herbivorie'
      AND table_name   = 'parcelle'
      AND column_name  = 'site_id'
  ) THEN
    -- Ici on sait que la table Parcelle existe ET qu'elle a la colonne site_id
    IF NOT EXISTS (
      SELECT 1
      FROM Parcelle p
      JOIN Zone z ON z.zone_id = p.zone_id
      WHERE p.site_id IS DISTINCT FROM z.site_id
    ) THEN
      ALTER TABLE Parcelle DROP COLUMN site_id;
    ELSE
      RAISE NOTICE 'Parcelle.site_id != Zone.site_id pour certaines lignes. Corrigez avant DROP.';
    END IF;
  END IF;
END
$$ LANGUAGE plpgsql;


-- 1) Relier Placette_core à Parcelle sans casser
DO $$
BEGIN
  -- On ne fait l’ALTER TABLE que si les deux tables existent
  IF to_regclass('"Herbivorie".parcelle')      IS NOT NULL
     AND to_regclass('"Herbivorie".placette_core') IS NOT NULL THEN

    EXECUTE '
      ALTER TABLE "Herbivorie".placette_core
      ADD COLUMN IF NOT EXISTS parcelle_id INT
        REFERENCES "Herbivorie".parcelle(parcelle_id)
    ';
  ELSE
    RAISE NOTICE 'Patch lieux: Parcelle ou Placette_core absente, pas d''ALTER TABLE.';
  END IF;
END
$$ LANGUAGE plpgsql;


DO $$
BEGIN
  IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'Herbivorie'
          AND table_name   = 'parcelle'
          AND column_name  = 'code'
     ) THEN
    UPDATE Placette_core pc
    SET parcelle_id = p.parcelle_id
    FROM Parcelle p
    WHERE pc.parcelle_id IS NULL
      AND pc.site_id  = p.site_id
      AND pc.zone_id  = p.zone_id
      AND pc.code     = p.code;
  END IF;
END
$$ LANGUAGE plpgsql;


-- 3) Index (unique si la règle métier l’exige)
DO $$
BEGIN
  IF to_regclass('"Herbivorie".parcelle') IS NOT NULL THEN
    EXECUTE '
      CREATE UNIQUE INDEX IF NOT EXISTS parcelle_code_unique
      ON "Herbivorie".parcelle(site_id, zone_id, code)
    ';
  ELSE
    RAISE NOTICE 'Patch lieux: Parcelle absente, pas de création d''index.';
  END IF;
END
$$ LANGUAGE plpgsql;
