-- Procédures et triggers pour le jalon 1

-- Procédure pour valider et transférer les données de CarnetMeteo vers Meteo
CREATE OR REPLACE FUNCTION transferer_donnees_meteo()
RETURNS void AS $$
BEGIN
    INSERT INTO Meteo (date_observation, temperature_min, temperature_max, humidite, precipitation, unite_temperature, unite_humidite, unite_precipitation)
    SELECT 
        date_releve,
        CASE WHEN temperature_min_raw IS NOT NULL THEN temperature_min_raw ELSE NULL END,
        CASE WHEN temperature_max_raw IS NOT NULL THEN temperature_max_raw ELSE NULL END,
        CASE WHEN humidite_raw IS NOT NULL THEN humidite_raw ELSE NULL END,
        CASE WHEN precipitation_raw IS NOT NULL THEN precipitation_raw ELSE NULL END,
        COALESCE(unite_temperature_raw, 'C'),
        COALESCE(unite_humidite_raw, '%'),
        COALESCE(unite_precipitation_raw, 'mm')
    FROM CarnetMeteo;

    -- Optionnel : vider CarnetMeteo après transfert
    DELETE FROM CarnetMeteo;
END;
$$ LANGUAGE plpgsql;

-- Procédure pour supprimer les données météo d'une période si Tmin < seuil
CREATE OR REPLACE FUNCTION supprimer_donnees_meteo(seuil NUMERIC, debut_periode DATE, fin_periode DATE)
RETURNS void AS $$
BEGIN
    DELETE FROM Meteo
    WHERE temperature_min < seuil
      AND date_observation BETWEEN debut_periode AND fin_periode;
END;
$$ LANGUAGE plpgsql;

-- Procédure pour augmenter les températures d'un pourcentage pour une période donnée
CREATE OR REPLACE FUNCTION augmenter_temperatures(pourcentage NUMERIC, debut_periode DATE, fin_periode DATE)
RETURNS void AS $$
BEGIN
    UPDATE Meteo
    SET temperature_min = temperature_min * (1 + pourcentage / 100),
        temperature_max = temperature_max * (1 + pourcentage / 100)
    WHERE date_observation BETWEEN debut_periode AND fin_periode;
END;
$$ LANGUAGE plpgsql;