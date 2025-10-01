-- Vues pour le jalon 1

-- Vue pour exposer les conditions météo hors précipitations
CREATE OR REPLACE VIEW ConditionsMeteo AS
SELECT 
    id,
    date_observation,
    temperature_min,
    temperature_max,
    humidite,
    unite_temperature,
    unite_humidite
FROM Meteo;