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
FROM ObsTemperature t
JOIN ObsHumidite h  ON t.date = h.date
JOIN ObsVents v     ON t.date = v.date
JOIN ObsPression p  ON t.date = p.date;

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

-- Nouvelle table ObsFloraison

CREATE TABLE ObsFloraison_new (
  id    Plant_id   NOT NULL,
  date  Date_eco   NOT NULL,
  note  Description NOT NULL,
  CONSTRAINT ObsFloraison_new_pk PRIMARY KEY (id),
  CONSTRAINT ObsFloraison_new_fk FOREIGN KEY (id) REFERENCES Plant (id)
);

INSERT INTO ObsFloraison_new (id, date, note)
SELECT DISTINCT ON (id) id, date, note
FROM ObsFloraison
WHERE fleur = true
ORDER BY id, date ASC;

-- Remplacement de l'ancienne table

DROP TABLE ObsFloraison;

ALTER TABLE ObsFloraison_new
RENAME TO ObsFloraison;
