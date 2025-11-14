/*
////
-- =========================================================================== B
*/

--
-- Spécification du schéma
--
SET SCHEMA 'Herbivorie' ;

CREATE VIEW VueConditionsMeteo AS
SELECT
    z.zone,
    t.date,
    t.temp_min,
    t.temp_max,
    t.note,
    h.hum_min,
    h.hum_max,
    v.vent_min,
    v.vent_max,
    p.pres_min,
    p.pres_max
FROM Zone z
JOIN ObsTemperature t ON (z.zone = t.zone)
JOIN ObsHumidite h  ON (t.date = h.date and z.zone = h.zone)
JOIN ObsVents v     ON (t.date = v.date and z.zone = v.zone)
JOIN ObsPression p  ON (t.date = p.date and z.zone = p.zone);

-- Retirer les données météorologiques pour une période donnée (date de début, date de fin) si la température
--  minimale rapportée est en deçà d’une température donnée.
--  Définir une procédure.

CREATE OR REPLACE PROCEDURE SupprimerDonneesMeteo(
    date_debut Date_eco,
    date_fin   Date_eco,
    seuil_temp Temperature
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Supprimer d'abord les précipitations (car elles ont FK avec TypePrecipitations)
  DELETE FROM ObsPrecipitations
  WHERE date BETWEEN date_debut AND date_fin
    AND date IN (
      SELECT date
      FROM ObsTemperature
      WHERE temp_min < seuil_temp
    );

  -- Supprimer humidité
  DELETE FROM ObsHumidite
  WHERE date BETWEEN date_debut AND date_fin
    AND date IN (
      SELECT date
      FROM ObsTemperature
      WHERE temp_min < seuil_temp
    );

  -- Supprimer vents
  DELETE FROM ObsVents
  WHERE date BETWEEN date_debut AND date_fin
    AND date IN (
      SELECT date
      FROM ObsTemperature
      WHERE temp_min < seuil_temp
    );

  -- Supprimer pression
  DELETE FROM ObsPression
  WHERE date BETWEEN date_debut AND date_fin
    AND date IN (
      SELECT date
      FROM ObsTemperature
      WHERE temp_min < seuil_temp
    );

  -- Enfin supprimer température (table "pivot")
  DELETE FROM ObsTemperature
  WHERE date BETWEEN date_debut AND date_fin
    AND temp_min < seuil_temp;

END;
$$;

-- Augmenter les températures rapportées d’un pourcentage donné durant une période donnée (date de début, date de fin).
--  Définir une procédure.

CREATE OR REPLACE PROCEDURE AugmenterTemperatures(
    date_debut Date_eco,
    date_fin   Date_eco,
    pourcentage NUMERIC  -- ex: 10 = +10%
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Mise à jour des températures
  UPDATE ObsTemperature
  SET
    temp_min = ROUND(temp_min * (1 + pourcentage / 100.0)),
    temp_max = ROUND(temp_max * (1 + pourcentage / 100.0))
  WHERE date BETWEEN date_debut AND date_fin;
END;
$$;

-- Définir l’assertion requise de la table Taux. Dans le script de création, on suggère de vérifier que les intervalles associés aux catégories ne se
--  chevauchent pas. Mettre en oeuvre l’assertion requise à l’aide d’une fonction.

CREATE OR REPLACE FUNCTION Verif_Taux()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Vérifie le chevauchement avec une autre ligne
    IF EXISTS (
        SELECT 1
        FROM Taux t
        WHERE t.tcat <> NEW.categorie
          AND t.tmin <= NEW.borne_max
          AND t.tmax >= NEW.borne_min
    ) THEN
        RAISE EXCEPTION 'Chevauchement détecté pour la catégorie % (intervalle [% - %])',
            NEW.categorie, NEW.borne_min, NEW.borne_max;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_verif_taux
BEFORE INSERT OR UPDATE ON Taux
FOR EACH ROW
EXECUTE FUNCTION Verif_Taux();

