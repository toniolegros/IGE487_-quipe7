-- Requêtes de vérification pour le jalon 1

-- Vérification des données insérées dans Meteo
SELECT * FROM Meteo;

-- Vérification des données insérées dans CarnetMeteo
SELECT * FROM CarnetMeteo;

-- Test de la procédure transferer_donnees_meteo
CALL transferer_donnees_meteo();
SELECT * FROM Meteo;
SELECT * FROM CarnetMeteo;

-- Test de la vue ConditionsMeteo
SELECT * FROM ConditionsMeteo;

-- Test de la procédure supprimer_donnees_meteo
CALL supprimer_donnees_meteo(12.0, '2025-09-01', '2025-09-03');
SELECT * FROM Meteo;

-- Test de la procédure augmenter_temperatures
CALL augmenter_temperatures(10.0, '2025-09-01', '2025-09-03');
SELECT * FROM Meteo;