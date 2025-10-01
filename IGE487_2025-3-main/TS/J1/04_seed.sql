-- Données de test représentatives pour le jalon 1

-- Données de test pour la table Meteo
INSERT INTO Meteo (date_observation, temperature_min, temperature_max, humidite, precipitation)
VALUES
    ('2025-09-01', 15.5, 25.3, 60.0, 5.0),
    ('2025-09-02', 14.0, 24.0, 55.0, 0.0),
    ('2025-09-03', 10.0, 20.0, 70.0, 12.0);

-- Données de test pour la table CarnetMeteo
INSERT INTO CarnetMeteo (date_releve, temperature_min_raw, temperature_max_raw, humidite_raw, precipitation_raw)
VALUES
    ('2025-09-01', 15.5, 25.3, 60.0, 5.0),
    ('2025-09-02', NULL, 24.0, 55.0, NULL),
    ('2025-09-03', 10.0, 20.0, NULL, 12.0);