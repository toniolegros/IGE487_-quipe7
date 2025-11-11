SET search_path TO "Herbivorie", public;

-- 0) Sécurité: supprimer Parcelle.site_id seulement si cohérent avec Zone(site_id)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='Herbivorie' AND table_name='parcelle' AND column_name='site_id'
  ) THEN
    IF NOT EXISTS (
      SELECT 1
      FROM Parcelle p JOIN Zone z ON z.zone_id = p.zone_id
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
ALTER TABLE Placette_core
  ADD COLUMN IF NOT EXISTS parcelle_id INT REFERENCES Parcelle(parcelle_id);

-- 1.b) (Optionnel) Peupler parcelle_id si on connaît le "code" de la parcelle
-- Adapte le nom de la colonne du code si besoin.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='Herbivorie' AND table_name='parcelle' AND column_name='code') THEN
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

-- 2) (Option) si parcelle_id est fiable, on pourra ensuite nettoyer :
-- ALTER TABLE Placette_core DROP COLUMN IF EXISTS site_id;
-- ALTER TABLE Placette_core DROP COLUMN IF EXISTS zone_id;

-- 3) Index (unique si la règle métier l’exige)
CREATE UNIQUE INDEX IF NOT EXISTS parcelle_code_unique
  ON Parcelle(site_id, zone_id, code);
