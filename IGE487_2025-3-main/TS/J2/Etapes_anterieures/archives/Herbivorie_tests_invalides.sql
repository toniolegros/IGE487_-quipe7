
SET SCHEMA 'Herbivorie' ;

-- ================================================================
--  Jeu de tests complet pour Meteo_cre.sql
--  Contient 50 cas : 25 valides + 25 invalides
-- ================================================================

-- ======================
-- SECTION 1 : Données valides
-- ======================

-- (1) Arbres valides
INSERT INTO Arbre VALUES ('CH01', 'Chêne rouge');
INSERT INTO Arbre VALUES ('ER02', 'Érable à sucre');
INSERT INTO Arbre VALUES ('PI03', 'Pin blanc');
INSERT INTO Arbre VALUES ('BO04', 'Bouleau jaune');
INSERT INTO Arbre VALUES ('SA05', 'Sapin baumier');

-- (2) Peuplements valides
INSERT INTO Peuplement VALUES ('P0001', 'Forêt mixte feuillue');
INSERT INTO Peuplement VALUES ('C0002', 'Coniférienne dense');
INSERT INTO Peuplement VALUES ('F0003', 'Forêt feuillue humide');

-- (3) États valides
INSERT INTO Etat VALUES ('A', 'Actif en croissance');
INSERT INTO Etat VALUES ('R', 'Repos hivernal');
INSERT INTO Etat VALUES ('S', 'Stress hydrique');
INSERT INTO Etat VALUES ('T', 'Traumatisé');

-- (4) Taux valides
INSERT INTO Taux VALUES ('F', 0, 30);
INSERT INTO Taux VALUES ('C', 0, 20);
INSERT INTO Taux VALUES ('T', 0, 50);
INSERT INTO Taux VALUES ('G', 10, 20);
INSERT INTO Taux VALUES ('M', 5, 15);
INSERT INTO Taux VALUES ('O', 0, 10);
INSERT INTO Taux VALUES ('N', 0, 5);

-- (5) Placette valide
INSERT INTO Placette VALUES (
  'A1','P0001',
  'F','F','C','C','T','T','G','M','O',
  'CH01','ER02','PI03','2024-05-10'
);

-- (6) Plant valide
INSERT INTO Plant VALUES ('MMA0001','A1',10,'2024-05-10','Plant sain en sol humide');
INSERT INTO Plant VALUES ('MMB0002','A1',20,'2024-05-12','Plant exposé au soleil');
INSERT INTO Plant VALUES ('MMC0003','A1',5,'2024-05-13','Plant ombragé');

-- (7) Observations valides
INSERT INTO ObsDimension VALUES ('MMA0001',120,80,'2024-05-12','Feuille développée');
INSERT INTO ObsDimension VALUES ('MMB0002',100,60,'2024-05-14','Croissance moyenne');
INSERT INTO ObsFloraison VALUES ('MMA0001',TRUE,'2024-05-12','Floraison observée');
INSERT INTO ObsEtat VALUES ('MMA0001','A','2024-05-12','Plant actif');
INSERT INTO ObsEtat VALUES ('MMB0002','R','2024-05-14','Repos temporaire');

-- (8) Autres cas valides
INSERT INTO Placette VALUES (
  'B2','C0002','F','F','C','C','T','T','G','M','O',
  'ER02','PI03','SA05','2024-06-15'
);

INSERT INTO Plant VALUES ('MMA0004','B2',15,'2024-06-16','Plant sous conifères');
INSERT INTO ObsFloraison VALUES ('MMA0004',FALSE,'2024-06-17','Pas de floraison');
INSERT INTO ObsEtat VALUES ('MMA0004','A','2024-06-17','Croissance stable');
INSERT INTO ObsDimension VALUES ('MMA0004',90,50,'2024-06-17','Hauteur moyenne');

-- (9) Taux additionnel cohérent
INSERT INTO Taux VALUES ('P', 30, 40);

-- (10) Placette cohérente supplémentaire
INSERT INTO Placette VALUES (
  'C3','F0003','F','F','C','C','T','T','G','M','O',
  'CH01','ER02','BO04','2024-07-01'
);

-- ===> Total valides : 25
-- ===========================


-- ======================
-- SECTION 2 : Tests invalides
-- ======================

-- (26) Arbre invalide (minuscules)
INSERT INTO Arbre VALUES ('ch10', 'Format invalide');  -- domaine invalide

-- (27) Peuplement invalide (trop court)
INSERT INTO Peuplement VALUES ('P01', 'Format trop court');  -- format

-- (28) Taux invalide (tMin > tMax)
INSERT INTO Taux VALUES ('Z', 60, 20);

-- (29) Taux invalide (hors bornes)
INSERT INTO Taux VALUES ('Y', -5, 120);

-- (30) Description trop longue
INSERT INTO Arbre VALUES ('XX99', repeat('a', 401));

-- (31) Plant avec mauvais format ID
INSERT INTO Plant VALUES ('MMZ9999','A1',10,'2024-05-12','ID hors plage');

-- (32) Plant parcelle hors bornes
INSERT INTO Plant VALUES ('MMA0999','A1',150,'2024-05-12','Parcelle invalide');

-- (33) Placette avec code invalide
INSERT INTO Placette VALUES ('A12','P0001','F','F','C','C','T','T','G','M','O','CH01','ER02','PI03','2024-05-10');

-- (34) Placette avec peuplement inexistant
INSERT INTO Placette VALUES ('F1','P9999','F','F','C','C','T','T','G','M','O','CH01','ER02','PI03','2024-05-10');

-- (35) Plant avec placette inexistante
INSERT INTO Plant VALUES ('MMA0100','Z9',10,'2024-05-12','Placette inconnue');

-- (36) Observation de dimension avec plant inexistant
INSERT INTO ObsDimension VALUES ('MMX9999',100,50,'2024-05-20','Plant inconnu');

-- (37) ObsEtat avec état inexistant
INSERT INTO ObsEtat VALUES ('MMA0001','Z','2024-05-12','État inconnu');

-- (38) Date observation avant date plant
INSERT INTO ObsDimension VALUES ('MMA0001',110,70,'2024-05-01','Avant identification');

-- (39) Date future
INSERT INTO ObsFloraison VALUES ('MMA0001',TRUE,'2099-01-01','Futur impossible');

-- (40) Taux incohérent (tMin + tMin > total)
INSERT INTO Taux VALUES ('Q', 0, 10);
INSERT INTO Placette VALUES ('E4','P0001','F','F','C','C','Q','Q','G','M','O','CH01','ER02','PI03','2024-05-10');

-- (41) Arbres dominants non distincts
INSERT INTO Placette VALUES ('G5','P0001','F','F','C','C','T','T','G','M','O','CH01','CH01','CH01','2024-05-10');

-- (42) Doublon sur clé primaire Arbre
INSERT INTO Arbre VALUES ('CH01','Doublon arbre');

-- (43) Doublon sur clé primaire Plant
INSERT INTO Plant VALUES ('MMA0001','A1',5,'2024-05-11','Doublon');

-- (44) ObsFloraison sur plant supprimé
DELETE FROM Plant WHERE id='MMC0003';
INSERT INTO ObsFloraison VALUES ('MMC0003',TRUE,'2024-05-12','Plant supprimé');

-- (45) Date de placette avant 1582
INSERT INTO Placette VALUES ('H6','P0001','F','F','C','C','T','T','G','M','O','CH01','ER02','PI03','1500-01-01');

-- (46) Taux avec intervalle de 0
INSERT INTO Taux VALUES ('X', 10, 10); -- possible si interdit par ton trigger → invalide selon version

-- (47) Observation avec valeurs nulles
INSERT INTO ObsDimension VALUES ('MMA0001',NULL,80,'2024-05-12','Hauteur manquante');

-- (48) Plant avec description vide
INSERT INTO Plant VALUES ('MMA0998','A1',10,'2024-05-12','');

-- (49) Observation avec date < 1582
INSERT INTO ObsEtat VALUES ('MMA0001','A','1400-01-01','Date trop ancienne');

-- (50) Observation avec date > courant
INSERT INTO ObsEtat VALUES ('MMA0001','A','2100-01-01','Date future');

-- ===> Total invalides : 25
-- ================================================================
