-- Jeu de données enrichi pour tester les tables Placette et Taux
-- Ajout de cas limites et scénarios variés

-- Insertion de données dans la table Taux
INSERT INTO Taux (tCat, tMin, tMax) VALUES
  ('A', 0, 20),
  ('B', 21, 40),
  ('C', 41, 60),
  ('D', 61, 80),
  ('E', 81, 100),
  ('F', 101, 120), -- Cas limite hors intervalle [0..100]
  ('G', 50, 70);   -- Chevauchement avec l'existant

-- Insertion de données dans la table Placette
INSERT INTO Placette (plac, peup, obs_F1, obs_F2, obs_C1, obs_C2, obs_T1, obs_T2, graminees, mousses, fougeres, arb_P1, arb_P2, arb_P3, date) VALUES
  ('P1', 'PEUP1', 'A', 'B', 'C', 'D', 'E', 'E', 'A', 'B', 'C', 1, 2, 3, '2025-10-01'),
  ('P2', 'PEUP2', 'B', 'C', 'D', 'E', 'A', 'B', 'C', 'D', 'E', 2, 3, 4, '2025-10-02'),
  ('P3', 'PEUP3', 'C', 'D', 'E', 'A', 'B', 'C', 'D', 'E', 'A', 3, 4, 5, '2025-10-03'),
  ('P4', 'PEUP4', 'D', 'E', 'A', 'B', 'C', 'D', 'E', 'A', 'B', 4, 5, 6, '2025-10-04'),
  ('P5', 'PEUP5', 'E', 'A', 'B', 'C', 'D', 'E', 'A', 'B', 'C', 5, 6, 7, '2025-10-05'),
  ('P6', 'PEUP6', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'A', 'B', 6, 7, 8, '2025-10-06'),
  ('P7', 'PEUP7', 'B', 'C', 'D', 'E', 'A', 'B', 'C', 'D', 'E', 7, 8, 9, '2025-10-07');

-- Ajout de données aléatoires pour tester les contraintes
DO $$
DECLARE
  i INTEGER;
BEGIN
  FOR i IN 1..100000 LOOP
    INSERT INTO Placette (plac, peup, obs_F1, obs_F2, obs_C1, obs_C2, obs_T1, obs_T2, graminees, mousses, fougeres, arb_P1, arb_P2, arb_P3, date) VALUES
      ('P' || i, 'PEUP' || i, 'A' || MOD(i, 5), 'B' || MOD(i, 5), 'C' || MOD(i, 5), 'D' || MOD(i, 5), 'E' || MOD(i, 5), 'F' || MOD(i, 5), 'G' || MOD(i, 5), 'H' || MOD(i, 5), 'I' || MOD(i, 5), MOD(i, 10), MOD(i, 10) + 1, MOD(i, 10) + 2, CURRENT_DATE);
  END LOOP;
END $$;

-- Complément du jeu de données pour tester toutes les fonctions et tables

-- Insertion de données dans la table ObsFloraison
INSERT INTO ObsFloraison (id, fleur, date, note) VALUES
  ('PLANT1', true, '2025-10-01', 'Floraison observée'),
  ('PLANT2', false, '2025-10-02', 'Pas de floraison'),
  ('PLANT3', true, '2025-10-03', 'Floraison observée'),
  ('PLANT4', false, '2025-10-04', 'Pas de floraison'),
  ('PLANT5', true, '2025-10-05', 'Floraison observée');

-- Insertion de données dans la table ObsDimension
INSERT INTO ObsDimension (id, longueur, largeur, date, note) VALUES
  ('PLANT1', 150, 50, '2025-10-01', 'Dimensions normales'),
  ('PLANT2', 200, 70, '2025-10-02', 'Dimensions grandes'),
  ('PLANT3', 120, 40, '2025-10-03', 'Dimensions petites'),
  ('PLANT4', 180, 60, '2025-10-04', 'Dimensions normales'),
  ('PLANT5', 160, 55, '2025-10-05', 'Dimensions normales');

-- Insertion de données dans la table ObsEtat
INSERT INTO ObsEtat (id, etat, date, note) VALUES
  ('PLANT1', 'A', '2025-10-01', 'État sain'),
  ('PLANT2', 'B', '2025-10-02', 'État moyen'),
  ('PLANT3', 'C', '2025-10-03', 'État faible'),
  ('PLANT4', 'A', '2025-10-04', 'État sain'),
  ('PLANT5', 'B', '2025-10-05', 'État moyen');

-- Insertion de données dans la table ObsTemperature
INSERT INTO ObsTemperature (date, temp_min, temp_max, note) VALUES
  ('2025-10-01', -5, 10, 'Températures basses'),
  ('2025-10-02', 0, 15, 'Températures normales'),
  ('2025-10-03', 5, 20, 'Températures élevées'),
  ('2025-10-04', -10, 5, 'Températures très basses'),
  ('2025-10-05', 10, 25, 'Températures très élevées');

-- Insertion de données dans la table ObsHumidite
INSERT INTO ObsHumidite (date, hum_min, hum_max) VALUES
  ('2025-10-01', 30, 50),
  ('2025-10-02', 40, 60),
  ('2025-10-03', 50, 70),
  ('2025-10-04', 20, 40),
  ('2025-10-05', 60, 80);

-- Insertion de données dans la table ObsVents
INSERT INTO ObsVents (date, vent_min, vent_max) VALUES
  ('2025-10-01', 10, 20),
  ('2025-10-02', 15, 25),
  ('2025-10-03', 20, 30),
  ('2025-10-04', 5, 15),
  ('2025-10-05', 25, 35);

-- Insertion de données dans la table ObsPression
INSERT INTO ObsPression (date, pres_min, pres_max) VALUES
  ('2025-10-01', 950, 1000),
  ('2025-10-02', 960, 1010),
  ('2025-10-03', 970, 1020),
  ('2025-10-04', 940, 990),
  ('2025-10-05', 980, 1030);

-- Insertion de données dans la table ObsPrecipitations
INSERT INTO ObsPrecipitations (date, prec_tot, prec_nat) VALUES
  ('2025-10-01', 10, 'P'),
  ('2025-10-02', 20, 'N'),
  ('2025-10-03', 30, 'G'),
  ('2025-10-04', 5, 'P'),
  ('2025-10-05', 15, 'N');

-- Ajout de données spécifiques dans CarnetMeteo pour valider la procédure Meteo_ELT

-- Insertion de données brutes dans CarnetMeteo
INSERT INTO CarnetMeteo (temp_min, temp_max, hum_min, hum_max, prec_tot, prec_nat, vent_min, vent_max, pres_min, pres_max, date, note) VALUES
  (-5, 10, 30, 50, 10, 'P', 10, 20, 950, 1000, '2025-10-01', 'Conditions normales'),
  (0, 15, 40, 60, 20, 'N', 15, 25, 960, 1010, '2025-10-02', 'Conditions humides'),
  (5, 20, 50, 70, 30, 'G', 20, 30, 970, 1020, '2025-10-03', 'Conditions venteuses'),
  (-10, 5, 20, 40, 5, 'P', 5, 15, 940, 990, '2025-10-04', 'Conditions froides'),
  (10, 25, 60, 80, 15, 'N', 25, 35, 980, 1030, '2025-10-05', 'Conditions chaudes'),
  (null, null, null, null, null, null, null, null, null, null, '2025-10-06', 'Données manquantes'),
  (-50, 50, 0, 100, 500, 'G', 300, 300, 1100, 1100, '2025-10-07', 'Cas extrêmes');

-- Fin du jeu de données