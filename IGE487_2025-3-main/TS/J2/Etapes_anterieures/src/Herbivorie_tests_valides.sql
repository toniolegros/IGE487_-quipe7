
SET SCHEMA 'Herbivorie' ;
-- ========== ARBRE (10) ==========
INSERT INTO Arbre VALUES ('CH01','Chêne rouge');
INSERT INTO Arbre VALUES ('CH02','Chêne blanc');
INSERT INTO Arbre VALUES ('ER01','Érable à sucre');
INSERT INTO Arbre VALUES ('ER02','Érable rouge');
INSERT INTO Arbre VALUES ('PI01','Pin blanc');
INSERT INTO Arbre VALUES ('PI02','Pin gris');
INSERT INTO Arbre VALUES ('BO01','Bouleau jaune');
INSERT INTO Arbre VALUES ('BO02','Bouleau à papier');
INSERT INTO Arbre VALUES ('SA01','Sapin baumier');
INSERT INTO Arbre VALUES ('ME01','Mélèze laricin');

-- ========== PEUPLEMENT (5) ==========
INSERT INTO Peuplement VALUES ('P0001','Forêt feuillue mature');
INSERT INTO Peuplement VALUES ('P0002','Forêt coniférienne mixte');
INSERT INTO Peuplement VALUES ('P0003','Forêt mixte jeune');
INSERT INTO Peuplement VALUES ('P0004','Boisé urbain');
INSERT INTO Peuplement VALUES ('P0005','Forêt humide');

-- ========== ETAT (5) ==========
INSERT INTO Etat VALUES ('A','Actif et en croissance');
INSERT INTO Etat VALUES ('B','Bourgeonnement');
INSERT INTO Etat VALUES ('F','Floraison');
INSERT INTO Etat VALUES ('R','Repos');
INSERT INTO Etat VALUES ('S','Stress hydrique');

-- ========== TAUX (10) ==========
INSERT INTO Taux VALUES ('F',  0, 30);  -- feuillus
INSERT INTO Taux VALUES ('C',  0, 20);  -- conifères
INSERT INTO Taux VALUES ('T',  0, 50);  -- total
INSERT INTO Taux VALUES ('G', 10, 20);  -- graminées
INSERT INTO Taux VALUES ('M',  5, 15);  -- mousses
INSERT INTO Taux VALUES ('O',  0, 10);  -- fougères
INSERT INTO Taux VALUES ('H', 50, 60);  -- herbacées
INSERT INTO Taux VALUES ('L', 60, 70);  -- litière
INSERT INTO Taux VALUES ('P', 70, 80);  -- pierres
INSERT INTO Taux VALUES ('S', 80,100);  -- sol nu

INSERT INTO Placette VALUES ('A1','P0001','F','F','C','C','T','T','G','M','O','CH01','ER01','PI01','2024-05-10');
INSERT INTO Placette VALUES ('A2','P0002','F','F','C','C','T','T','H','M','O','CH02','ER02','PI02','2024-05-11');
INSERT INTO Placette VALUES ('B1','P0003','F','F','C','C','T','T','G','M','O','BO01','ER02','SA01','2024-05-12');
INSERT INTO Placette VALUES ('B2','P0004','F','F','C','C','T','T','G','L','O','ME01','CH01','ER01','2024-05-13');
INSERT INTO Placette VALUES ('C1','P0005','F','F','C','C','T','T','M','M','O','CH02','ER01','PI02','2024-05-14');
INSERT INTO Placette VALUES ('C2','P0001','F','F','C','C','T','T','H','M','O','ER02','PI01','BO02','2024-05-15');
INSERT INTO Placette VALUES ('D1','P0002','F','F','C','C','T','T','G','M','O','BO02','PI01','ER01','2024-05-16');
INSERT INTO Placette VALUES ('D2','P0003','F','F','C','C','T','T','G','M','O','SA01','ER01','PI02','2024-05-17');
INSERT INTO Placette VALUES ('E1','P0004','F','F','C','C','T','T','G','L','O','CH01','ER02','BO01','2024-05-18');
INSERT INTO Placette VALUES ('E2','P0005','F','F','C','C','T','T','M','M','O','ME01','PI02','BO02','2024-05-19');

INSERT INTO Plant VALUES ('MMA0001','A1',10,'2024-05-10','Plant vigoureux sous couvert feuillu');
INSERT INTO Plant VALUES ('MMA0002','A2',15,'2024-05-11','Plant exposé partiellement');
INSERT INTO Plant VALUES ('MMA0003','B1',20,'2024-05-12','Plant jeune sur sol humide');
INSERT INTO Plant VALUES ('MMA0004','B2',25,'2024-05-13','Plant à l’ombre dense');
INSERT INTO Plant VALUES ('MMA0005','C1',30,'2024-05-14','Plant bien enraciné');
INSERT INTO Plant VALUES ('MMB0006','C2',35,'2024-05-15','Plant sain');
INSERT INTO Plant VALUES ('MMB0007','D1',40,'2024-05-16','Plant moyen développement');
INSERT INTO Plant VALUES ('MMB0008','D2',45,'2024-05-17','Plant en croissance rapide');
INSERT INTO Plant VALUES ('MMC0009','E1',50,'2024-05-18','Plant mature');
INSERT INTO Plant VALUES ('MMC0010','E2',55,'2024-05-19','Plant dans clairière');

-- ObsDimension
INSERT INTO ObsDimension VALUES ('MMA0001',120,80,'2024-05-12','Feuille large et saine');
INSERT INTO ObsDimension VALUES ('MMA0002',90,60,'2024-05-12','Feuille fine');
INSERT INTO ObsDimension VALUES ('MMA0003',110,70,'2024-05-13','Feuille normale');
INSERT INTO ObsDimension VALUES ('MMA0004',130,85,'2024-05-14','Feuille robuste');
INSERT INTO ObsDimension VALUES ('MMA0005',125,75,'2024-05-15','Feuille verte et épaisse');
INSERT INTO ObsDimension VALUES ('MMB0006',140,95,'2024-05-16','Feuille mature');
INSERT INTO ObsDimension VALUES ('MMB0007',150,90,'2024-05-17','Feuille grande');
INSERT INTO ObsDimension VALUES ('MMB0008',135,80,'2024-05-18','Feuille en expansion');
INSERT INTO ObsDimension VALUES ('MMC0009',145,100,'2024-05-19','Feuille finale');
INSERT INTO ObsDimension VALUES ('MMC0010',155,105,'2024-05-20','Feuille maximale');

-- ObsFloraison
INSERT INTO ObsFloraison VALUES ('MMA0001',TRUE,'2024-05-12','Floraison complète');
INSERT INTO ObsFloraison VALUES ('MMA0002',FALSE,'2024-05-13','Aucun bouton visible');
INSERT INTO ObsFloraison VALUES ('MMA0003',TRUE,'2024-05-14','Début floraison');
INSERT INTO ObsFloraison VALUES ('MMA0004',TRUE,'2024-05-15','Fleur ouverte');
INSERT INTO ObsFloraison VALUES ('MMA0005',FALSE,'2024-05-16','Non fleuri');
INSERT INTO ObsFloraison VALUES ('MMB0006',TRUE,'2024-05-17','Floraison observée');
INSERT INTO ObsFloraison VALUES ('MMB0007',FALSE,'2024-05-18','Floraison terminée');
INSERT INTO ObsFloraison VALUES ('MMB0008',TRUE,'2024-05-19','Nouvelle fleur');
INSERT INTO ObsFloraison VALUES ('MMC0009',TRUE,'2024-05-20','Pleine floraison');
INSERT INTO ObsFloraison VALUES ('MMC0010',FALSE,'2024-05-21','Floraison absente');

-- ObsEtat
INSERT INTO ObsEtat VALUES ('MMA0001','A','2024-05-12','Croissance normale');
INSERT INTO ObsEtat VALUES ('MMA0002','B','2024-05-13','Début de bourgeonnement');
INSERT INTO ObsEtat VALUES ('MMA0003','F','2024-05-14','En floraison');
INSERT INTO ObsEtat VALUES ('MMA0004','A','2024-05-15','Croissance stable');
INSERT INTO ObsEtat VALUES ('MMA0005','R','2024-05-16','Repos temporaire');
INSERT INTO ObsEtat VALUES ('MMB0006','S','2024-05-17','Stress hydrique modéré');
INSERT INTO ObsEtat VALUES ('MMB0007','F','2024-05-18','Floraison tardive');
INSERT INTO ObsEtat VALUES ('MMB0008','A','2024-05-19','Croissance active');
INSERT INTO ObsEtat VALUES ('MMC0009','R','2024-05-20','Repos post-floraison');
INSERT INTO ObsEtat VALUES ('MMC0010','S','2024-05-21','Sol sec, stressé');
