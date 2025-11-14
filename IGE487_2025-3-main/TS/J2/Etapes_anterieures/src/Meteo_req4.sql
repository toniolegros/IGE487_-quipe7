/*
////
-- =========================================================================== A
-- Meteo_req4.sql
-- ---------------------------------------------------------------------------
Activité : IFT187_2022-1
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 17
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.1.1a
Statut : en cours de développement
Résumé : Test minimaliste d’importation des carnets météorologiques.
-- =========================================================================== A
*/

/*
-- =========================================================================== B
////

Test minimaliste d’importation des carnets météorologiques dans la base de données.

////
-- =========================================================================== B
*/

--
-- Spécification du schéma
--
SET SCHEMA 'Herbivorie' ;

-- Vider les tables du contenu des précédents essais
delete from ObsTemperature ;
delete from ObsHumidite ;
delete from ObsPrecipitations ;
delete from ObsVents ;
delete from ObsPression ;
delete from CarnetMeteo ;

-- Ajouter les données au carnet météorologique (remarquons la conversion implicite des données numériques!!!)
insert into CarnetMeteo values
  ('MMA',10, 14, 18, 24, 0, 'P', 4, 20, 1028, 1030, '2016-05-04', 'départ'),
  ('MMB',10, 14, 18, 24, null, null, 4, 20, 1028, 1030, '2016-05-05', 'comme hier'),
  ('MMA',10, 14, 18, 24, null, null, 4, 20, 1028, 1030, '2015-05-05', 'refus d'),
  ('MMC',10, 65, -2, 24, 10, 'K', 4, 2000, 1028, 2000, '2016-07-05', 'refus m'),
  ('MMB',12, 15, 24, 30, 1, 'P', 8, 10, 1026, 1028, '2016-05-06', 'fin'),
  ('MMA','-5','2','60','80','10','N','5','20','1000','1015','2023-01-15','Neige légère'),
  ('MMA','0','5','40','70','0','P','0','10','1010','1020','2023-03-20','Temps calme, ciel couvert'),
  ('MMA','10','18','35','55','5','P','3','15','1005','1012','2023-05-10','Petite pluie intermittente'),
  ('MMB','20','28','50','75','0','P','5','25','1002','1010','2023-06-18','Chaud, un peu venteux'),
  ('MMB','25','32','30','60','0','P','10','40','998','1008','2023-07-05','Chaleur + vents modérés'),
('MMB','15','22','70','90','12','P','8','30','1008','1018','2023-09-01','Pluie soutenue'),
('MMC','-2','3','65','85','7','N','5','18','1005','1015','2023-11-10','Neige fondante'),
('MMC','-10','-3','50','70','15','N','0','12','1015','1025','2023-12-02','Froid sec, neige fine'),
('MMA','-15','-5','40','60','0','N','0','8','1020','1030','2022-01-25','Grand froid, ciel dégagé'),
('MMA','5','12','45','65','2','P','2','18','1005','1015','2022-04-12','Pluie faible'),
('MMA','8','16','55','75','3','P','4','22','1000','1010','2022-05-30','Pluie éparse'),
('MMB','12','20','60','80','0','P','0','18','1008','1016','2022-06-21','Temps lourd, humide'),
('MMB','18','26','40','65','1','P','5','28','999','1007','2022-07-13','Orages isolés, pluie courte'),
('MMB','22','29','35','55','0','P','12','35','997','1005','2022-08-09','Chaud, rafales'),
('MMC','5','11','75','95','9','P','6','19','1006','1014','2022-09-27','Pluie continue'),
('MMC','0','6','80','98','20','N','4','15','1002','1011','2022-10-30','Neige abondante'),
('MMA','-3','4','50','80','0','N','3','17','1003','1012','2021-12-15','Neige + vent modéré'),
('MMA','-1','7','55','78','4','P','2','14','1009','1018','2021-11-10','Pluie froide'),
('MMB','7','15','45','70','6','P','5','20','1001','1010','2021-10-03','Pluie régulière'),
('MMB','10','18','35','60','0','P','0','16','1007','1016','2021-09-19','Nuageux, quelques éclaircies'),
('MMC','14','22','50','72','0','P','8','26','1004','1013','2021-08-02','Chaud et venteux'),
('MMC','9','17','65','88','11','P','3','21','1002','1011','2021-06-25','Pluie + humidité élevée'),
('MMA','3','10','40','63','0','P','0','12','1008','1017','2021-04-14','Temps frais, sec'),
('MMA','-8','0','55','82','5','N','2','13','1012','1021','2020-02-05','Neige modérée'),
('MMB','-4','3','60','86','8','N','1','16','1009','1019','2020-03-11','Neige fondante + vent léger'),
('MMA','-60','0','50','80','5','N','5','15','1000','1010','2023-01-10','Température trop basse'),
('MMA','0','60','40','70','2','P','3','18','1002','1012','2023-03-05','Température trop haute'),
('MMA','-2','5','-10','50','0','P','0','10','1010','1020','2023-04-01','Humidité min négative'),
('MMB','5','12','40','120','3','P','4','16','1005','1015','2023-05-09','Humidité max trop élevée'),
('MMB','10','20','50','80','0','P','20','350','1000','1010','2023-06-18','Vent max hors domaine'),
('MMC','8','15','45','70','1','P','5','22','890','1000','2023-07-22','Pression min trop basse'),
('MMC','12','18','55','75','0','P','4','19','1005','1120','2023-08-30','Pression max trop haute'),
('MMA','4','10','60','85','-5','P','2','14','1003','1013','2023-09-14','Précipitation négative'),
('MMA','1','7','50','80','600','P','1','12','1004','1014','2023-10-03','Précipitation trop élevée'),
('MMB','0','8','55','82','3','X','3','17','1007','1017','2023-11-19','Code précipitation invalide'),
('MMB','-1','6','48','77','2','','2','13','1009','1019','2023-12-01','Code précipitation vide'),
('MMC','3','9','40','68','1','P','NA','15','1006','1016','2022-01-05','Vent min non numérique'),
('MMC','5','11','52','79','4','P','6','NA','1002','1012','2022-02-14','Vent max non numérique'),
('MMA','NA','5','45','70','0','P','0','10','1008','1018','2022-03-20','Temp min non numérique'),
('MMA','2','9','55','NA','0','P','1','11','1001','1011','2022-04-09','Hum max non numérique'),
('MMB','7','14','60','88','6','P','4','19','abc','1010','2022-05-28','Pres min non numérique'),
('MMB','9','16','58','83','5','P','3','18','1004','def','2022-06-15','Pres max non numérique'),
('MMC','10','18','50','75','0','P','5','20','1005','1015','2022/07/01','Date mauvais format'),
('MMC','-3','4','48','72','1','N','2','13','1011','1021','2022-13-05','Date invalide'),
('MMA','0','5','40','60','0','P','0','10','1000','1010','1500-01-01','Date hors domaine'),
('XXX','3','9','55','78','2','P','2','14','1007','1017','2021-09-09','Zone invalide'),
('','4','10','50','80','0','P','1','12','1003','1013','2021-10-10','Zone vide'),
('MMA','','','60','85','','P','5','15','1002','1012','2021-11-11','Valeurs manquantes'),
('MMB','5','12','45','70','3','P','3','14','1006','1016','','Date vide'),
('MMC','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','Toutes valeurs NA');

-- Faire l’importation
call Meteo_ELT () ;

-- Fin

/*
-- =========================================================================== Z
////
.Contributeurs
* (LL01) luc.lavoie@usherbrooke.ca

.Tâches projetées
* 2022-01-23 LL01. Enrichier

.Tâches réalisées
* 2022-01-23 LL01. Création.

.Références
* {CoFELI}/Exemple/Herbivorie/pub/Herbivorie_EPP.pdf
////

.Adresse, droits d’auteur et copyright
  Groupe Metis
  Département d’informatique
  Faculté des sciences
  Université de Sherbrooke
  Sherbrooke (Québec)  J1K 2R1
  Canada
  http://info.usherbrooke.ca/llavoie/
  [CC-BY-NC-4.0 (http://creativecommons.org/licenses/by-nc/4.0)]

-- -----------------------------------------------------------------------------
-- fin de {CoFELI}/Exemple/Herbivorie/src/Meteo_req4.sql
-- =========================================================================== Z
*/
