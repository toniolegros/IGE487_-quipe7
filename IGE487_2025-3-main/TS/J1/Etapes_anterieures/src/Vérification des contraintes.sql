-- Vérification des contraintes CHECK ajoutées dans CarnetMeteo
-- Test 1 : Insérer des données valides
INSERT INTO CarnetMeteo (temp_min, temp_max, hum_min, hum_max, vent_min, vent_max, pres_min, pres_max, prec_tot, prec_nat, date, note)
VALUES (-5, 10, 30, 70, 5, 20, 1000, 1020, 5, 'P', '2025-10-05', 'Données valides');

-- Test 2 : Insérer des données invalides (temp_min > temp_max)
INSERT INTO CarnetMeteo (temp_min, temp_max, hum_min, hum_max, vent_min, vent_max, pres_min, pres_max, prec_tot, prec_nat, date, note)
VALUES (15, 10, 30, 70, 5, 20, 1000, 1020, 5, 'P', '2025-10-05', 'Température invalide');

-- Test 3 : Insérer des données invalides (prec_tot < 0)
INSERT INTO CarnetMeteo (temp_min, temp_max, hum_min, hum_max, vent_min, vent_max, pres_min, pres_max, prec_tot, prec_nat, date, note)
VALUES (-5, 10, 30, 70, 5, 20, 1000, 1020, -5, 'P', '2025-10-05', 'Précipitations invalides');

-- Test 4 : Vérifier les relations entre les tables
-- Insérer des données dans ObsPrecipitations pour valider la clé étrangère
INSERT INTO ObsPrecipitations (date, prec_tot, prec_nat)
VALUES ('2025-10-05', 5, 'P');

-- Insérer des données dans CarnetMeteo avec une référence valide
INSERT INTO CarnetMeteo (temp_min, temp_max, hum_min, hum_max, vent_min, vent_max, pres_min, pres_max, prec_tot, prec_nat, date, note)
VALUES (-5, 10, 30, 70, 5, 20, 1000, 1020, 5, 'P', '2025-10-05', 'Référence valide');