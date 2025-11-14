DROP TABLE IF EXISTS megantic CASCADE;
SET SCHEMA 'Herbivorie';


CREATE TABLE megantic (
  site_id           TEXT,
  site_nom          TEXT,
  description_site  TEXT,
  description       TEXT,
  zone              TEXT,
  description_zone  TEXT,
  plac              TEXT,
  placette          TEXT,
  parcelle          TEXT,
  rang              INTEGER,
  peup              TEXT,
  description_peup  TEXT,
  arbre             TEXT,
  description_arbre TEXT,
  etat              TEXT,
  description_etat  TEXT,
  id                TEXT,
  date              TEXT,
  note              TEXT,
  fleur             BOOLEAN,
  longueur          INTEGER,
  largeur           INTEGER,
  unite_id          INTEGER,
  tcat              TEXT,
  tval            INTEGER,
  ctype             TEXT,
  nature            TEXT,
  hauteur           TEXT
);

INSERT INTO megantic values ('MM01','Site Mégantic 1','Zone d’étude principale','Placette MMA-A1','MMA','Zone A','A1','A1','01',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','Plant sain','MMA0001','2023-05-04','Observation calme',true,12,8,1,'A',85,'graminees','feuillu','1m'),
('MM01','Site Mégantic 1','Zone d’étude principale','Placette MMA-A1','MMA','Zone A','A1','A1','02',2,'P1234','Peuplement mixte','AB12','Érable rouge','B','Stress léger','MMA0002','2023-05-04','Sol humide',false,14,9,1,'B',65,'fougeres','coniferien','2m'),
('MM01','Site Mégantic 1','Zone d’étude principale','Placette MMA-A1','MMA','Zone A','A1','A1','03',3,'P1234','Peuplement mixte','AC34','Pin blanc','A','Bon état','MMA0003','2023-05-04','RAS',true,10,7,1,'C',45,'mousses','total','1m'),
('MM01','Site Mégantic 1','Zone d’étude principale','Placette MMA-A2','MMA','Zone A','A2','A2','01',1,'P3456','Peuplement érablière','AB12','Érable rouge','A','Bon état','MMA0004','2023-05-05','Couvert élevé',false,11,6,1,'D',20,'graminees','feuillu','2m'),
('MM01','Site Mégantic 1','Zone d’étude principale','Placette MMA-A2','MMA','Zone A','A2','A2','02',2,'P3456','Peuplement érablière','AD56','Bouleau blanc','C','Dépérissement léger','MMA0005','2023-05-05','Litière dense',false,15,8,1,'E',4,'fougeres','total','1m'),
('MM01','Site Mégantic 1','Zone d’étude principale','Placette MMA-A3','MMA','Zone A','A3','A3','01',1,'P5678','Peuplement coniférien','AC34','Pin blanc','A','RAS','MMA0006','2023-05-06','Température basse',true,13,7,1,'A',82,'mousses','coniferien','2m'),
('MM01','Site Mégantic 1','Zone d’étude principale','Placette MMA-A3','MMA','Zone A','A3','A3','02',2,'P5678','Peuplement coniférien','AE78','Sapin baumier','B','Stress hydrique','MMA0007','2023-05-06','Vent modéré',true,16,9,1,'B',60,'graminees','total','1m'),
('MM01','Site Mégantic 1','Zone d’étude principale','Placette MMA-A3','MMA','Zone A','A3','A3','03',3,'P5678','Peuplement coniférien','AB12','Érable rouge','A','Bon état','MMA0008','2023-05-06','Léger ombrage',false,9,5,1,'C',42,'fougeres','feuillu','2m'),
('MM01','Site Mégantic 1','Zone d’étude principale','Placette MMA-A4','MMA','Zone A','A4','A4','01',1,'P6789','Peuplement mixte','AB12','Érable rouge','A','Bon état','MMA0009','2023-05-07','RAS',true,14,8,1,'A',90,'graminees','feuillu','1m'),
('MM01','Site Mégantic 1','Zone d’étude principale','Placette MMA-A4','MMA','Zone A','A4','A4','02',2,'P6789','Peuplement mixte','AC34','Pin blanc','B','Stress hydrique','MMA0010','2023-05-07','Humide',false,12,7,1,'B',63,'mousses','coniferien','2m'),
('MM01','Site Mégantic 1','Zone d’étude principale','Placette MMA-A5','MMA','Zone A','A5','A5','01',1,'P1111','Peuplement mixte','AB12','Érable rouge','A','RAS','MMA0011','2023-05-08','Beaucoup de lumière',true,13,8,1,'A',78,'graminees','feuillu','1m'),
('MM01','Site Mégantic 1','Zone d’étude principale','Placette MMA-A5','MMA','Zone A','A5','A5','02',2,'P1111','Peuplement mixte','AC34','Pin blanc','B','Stress léger','MMA0012','2023-05-08','Couvert variable',false,12,7,1,'B',58,'mousses','coniferien','2m'),
('MM01','Site Mégantic 1','Zone d’étude principale','Placette MMA-A5','MMA','Zone A','A5','A5','03',3,'P1111','Peuplement mixte','AE78','Sapin baumier','C','État faible','MMA0013','2023-05-08','RAS',false,11,6,1,'C',37,'fougeres','total','1m'),
('MM01','Site Mégantic 1','Zone d’étude principale','Placette MMA-A6','MMA','Zone A','A6','A6','01',1,'P2222','Peuplement érablière','AB12','Érable rouge','A','RAS','MMA0014','2023-05-09','Sol bien drainé',true,14,9,1,'A',83,'graminees','feuillu','1m'),
('MM01','Site Mégantic 1','Zone d’étude principale','Placette MMA-A6','MMA','Zone A','A6','A6','02',2,'P2222','Peuplement érablière','AC34','Pin blanc','B','Stress léger','MMA0015','2023-05-09','Ombre légère',false,12,8,1,'B',62,'fougeres','coniferien','2m'),
('MM02','Site Mégantic 2','Zone secondaire','Placette MMB-B1','MMB','Zone B','B1','B1','01',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','RAS','MMB0001','2023-06-10','Bonne visibilité',true,14,10,1,'A',88,'graminees','feuillu','1m'),
('MM02','Site Mégantic 2','Zone secondaire','Placette MMB-B1','MMB','Zone B','B1','B1','02',2,'P1234','Peuplement mixte','AC34','Pin blanc','B','Stress léger','MMB0002','2023-06-10','Humidité élevée',false,12,7,1,'B',66,'mousses','coniferien','2m'),
('MM02','Site Mégantic 2','Zone secondaire','Placette MMB-B1','MMB','Zone B','B1','B1','03',3,'P1234','Peuplement mixte','AE78','Sapin baumier','C','Dépérissement','MMB0003','2023-06-10','Sol détrempé',false,10,6,1,'C',40,'fougeres','total','1m'),
('MM02','Site Mégantic 2','Zone secondaire','Placette MMB-B2','MMB','Zone B','B2','B2','01',1,'P3456','Peuplement érablière','AB12','Érable rouge','A','RAS','MMB0004','2023-06-11','Brise légère',true,15,9,1,'A',82,'graminees','feuillu','2m'),
('MM02','Site Mégantic 2','Zone secondaire','Placette MMB-B2','MMB','Zone B','B2','B2','02',2,'P3456','Peuplement érablière','AC34','Pin blanc','A','Bon état','MMB0005','2023-06-11','RAS',false,11,7,1,'D',18,'fougeres','coniferien','1m'),
('MM02','Site Mégantic 2','Zone secondaire','Placette MMB-B2','MMB','Zone B','B2','B2','03',3,'P3456','Peuplement érablière','AE78','Sapin baumier','B','Stress hydrique','MMB0006','2023-06-11','Couvert dense',false,14,8,1,'E',5,'mousses','total','2m'),
('MM02','Site Mégantic 2','Zone secondaire','Placette MMB-B3','MMB','Zone B','B3','B3','01',1,'P5678','Peuplement coniférien','AC34','Pin blanc','A','RAS','MMB0007','2023-06-12','Température élevée',true,16,10,1,'A',80,'graminees','feuillu','1m'),
('MM02','Site Mégantic 2','Zone secondaire','Placette MMB-B3','MMB','Zone B','B3','B3','02',2,'P5678','Peuplement coniférien','AB12','Érable rouge','B','Stress léger','MMB0008','2023-06-12','RAS',false,12,7,1,'B',59,'fougeres','coniferien','2m'),
('MM02','Site Mégantic 2','Zone secondaire','Placette MMB-B3','MMB','Zone B','B3','B3','03',3,'P5678','Peuplement coniférien','AE78','Sapin baumier','C','Faible vitalité','MMB0009','2023-06-12','Sec',false,11,6,1,'C',39,'mousses','total','1m'),
('MM03','Site Mégantic 3','Zone haute altitude','Placette MMC-C1','MMC','Zone C','C1','C1','01',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','Bon état','MMC0001','2023-07-20','Bonne hydratation',true,14,9,1,'A',81,'graminees','feuillu','2m'),
('MM03','Site Mégantic 3','Zone haute altitude','Placette MMC-C1','MMC','Zone C','C1','C1','02',2,'P1234','Peuplement mixte','AC34','Pin blanc','B','Stress léger','MMC0002','2023-07-20','RAS',false,13,7,1,'B',57,'fougeres','coniferien','1m'),
('XX99','Site bidon','Description bidon','Ligne invalide zone','XXX','Zone X','Z1','Z1','01',1,'P0000','Peuplement inconnu','ZZ99','Arbre inconnu','Z','État inconnu','TR0000','2023-05-04','Zone invalide',true,10,5,1,'A',80,'graminees','feuillu','1m'),
('', 'Site vide','Desc vide','Ligne invalide site_id','MMA','Zone A','A1','A1','02',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMA0099','2023-05-04','Site_id vide',true,12,7,1,'B',60,'graminees','feuillu','1m'),
('MM01','Site Mégantic 1','Zone A','Mauvais id','MMA','Zone A','A1','A1','03',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','BADID','2023-05-04','ID invalide',true,11,6,1,'C',40,'graminees','feuillu','1m'),
('MM01','Site Mégantic 1','Zone A','Date format invalide','MMA','Zone A','A2','A2','01',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMA0100','04/05/2023','Date non ISO',true,10,5,1,'A',85,'graminees','feuillu','1m'),
('MM01','Site Mégantic 1','Zone A','Date impossible','MMA','Zone A','A2','A2','02',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMA0101','2023-13-01','Mois 13',true,9,4,1,'B',60,'graminees','feuillu','1m'),
('MM01','Site Mégantic 1','Zone A','Longueur négative','MMA','Zone A','A3','A3','01',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMA0102','2023-05-06','Longueur < 0',true,-5,8,1,'A',80,'graminees','feuillu','1m'),
('MM01','Site Mégantic 1','Zone A','Largeur négative','MMA','Zone A','A3','A3','02',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMA0103','2023-05-06','Largeur < 0',true,10,-3,1,'B',60,'graminees','feuillu','1m'),
('MM01','Site Mégantic 1','Zone A','Unité invalide','MMA','Zone A','A4','A4','01',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMA0104','2023-05-07','unite_id=9',true,12,7,9,'A',80,'graminees','feuillu','1m'),
('MM01','Site Mégantic 1','Zone A','tcat inconnu','MMA','Zone A','A4','A4','02',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMA0105','2023-05-07','tcat=Z',true,12,7,1,'Z',50,'graminees','feuillu','1m'),
('MM02','Site Mégantic 2','Zone B','tvalcc trop grand','MMB','Zone B','B1','B1','01',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMB0100','2023-06-10','tvalcc=150',true,12,7,1,'A',150,'graminees','feuillu','1m'),
('MM02','Site Mégantic 2','Zone B','tvalcc négatif','MMB','Zone B','B1','B1','02',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMB0101','2023-06-10','tvalcc=-5',true,12,7,1,'B',-5,'graminees','feuillu','1m'),
('MM02','Site Mégantic 2','Zone B','ctype inconnu','MMB','Zone B','B2','B2','01',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMB0102','2023-06-11','ctype=herbes',true,12,7,1,'A',80,'herbes','feuillu','1m'),
('MM02','Site Mégantic 2','Zone B','nature inconnue','MMB','Zone B','B2','B2','02',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMB0103','2023-06-11','nature=rocheux',true,12,7,1,'B',60,'graminees','rocheux','1m'),
('MM02','Site Mégantic 2','Zone B','hauteur inconnue','MMB','Zone B','B3','B3','01',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMB0104','2023-06-12','hauteur=3m',true,12,7,1,'A',80,'graminees','feuillu','3m'),
('MM02','Site Mégantic 2','Zone B','rang=0','MMB','Zone B','B3','B3','01',0,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMB0105','2023-06-12','rang=0',true,12,7,1,'A',80,'graminees','feuillu','1m'),
('MM03','Site Mégantic 3','Zone C','parcelle non numérique','MMC','Zone C','C1','C1','AA',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMC0100','2023-07-20','parcelle=AA',true,12,7,1,'A',80,'graminees','feuillu','1m'),
('MM03','Site Mégantic 3','Zone C','etat invalide','MMC','Zone C','C1','C1','01',1,'P1234','Peuplement mixte','AB12','Érable rouge','AB','État invalide','MMC0101','2023-07-20','etat=AB',true,12,7,1,'A',80,'graminees','feuillu','1m'),
('MM03','Site Mégantic 3','Zone C','arbre invalide','MMC','Zone C','C2','C2','01',1,'P1234','Peuplement mixte','1234','Arbre invalide','A','OK','MMC0102','2023-07-21','arbre=1234',true,12,7,1,'A',80,'graminees','feuillu','1m'),
('MM03','Site Mégantic 3','Zone C','peup vide','MMC','Zone C','C2','C2','02',1,'','Peuplement vide','AB12','Érable rouge','A','OK','MMC0103','2023-07-21','peup vide',true,12,7,1,'A',80,'graminees','feuillu','1m'),
('MM01','Site Mégantic 1','Zone A','zone vide','', 'Zone vide','A1','A1','01',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMA0106','2023-05-04','zone vide',true,12,7,1,'A',80,'graminees','feuillu','1m'),
('MM01','Site Mégantic 1','Zone A','id null','MMA','Zone A','A1','A1','02',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK',NULL,'2023-05-04','id manquant',true,12,7,1,'A',80,'graminees','feuillu','1m'),
('MM01','Site Mégantic 1','Zone A','date vide','MMA','Zone A','A1','A1','03',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMA0107','', 'date vide',true,12,7,1,'A',80,'graminees','feuillu','1m'),
('MM02','Site Mégantic 2','Zone B','tcat null','MMB','Zone B','B1','B1','03',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMB0106','2023-06-10','tcat null',true,12,7,1,NULL,50,'graminees','feuillu','1m'),
('MM02','Site Mégantic 2','Zone B','tvalcc null','MMB','Zone B','B2','B2','03',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMB0107','2023-06-11','tvalcc null',true,12,7,1,'A',NULL,'graminees','feuillu','1m'),
('MM03','Site Mégantic 3','Zone C','fleur null','MMC','Zone C','C3','C3','03',1,'P1234','Peuplement mixte','AB12','Érable rouge','A','OK','MMC0104','2023-07-22','fleur null',NULL,12,7,1,'A',80,'graminees','feuillu','1m');


CREATE TABLE IF NOT EXISTS Rejets (
    rejet_id   BIGSERIAL PRIMARY KEY,
    flux       TEXT NOT NULL,
    motif      TEXT NOT NULL,
    details    TEXT,
    attributs  text,
    ligne      JSONB NOT NULL,
    date_rejet TIMESTAMP NOT NULL DEFAULT now()
);

CREATE OR REPLACE VIEW Rejets_Synthese AS
SELECT
    flux,
    COUNT(*) AS total_rejets,
    MAX(date_rejet) AS dernier_rejet,
    MIN(motif) AS exemple_motif,
    MIN(ligne::text) AS exemple_ligne
FROM Rejets
GROUP BY flux
ORDER BY flux;


CREATE OR REPLACE VIEW Rejets_Detail AS
SELECT
    rejet_id,
    flux,
    date_rejet,
    motif,
    details,
    ligne
FROM Rejets
ORDER BY date_rejet DESC;

call megantic_ELT();

select * from site_eva();

-- Lire tous les plants
SELECT * FROM Plant_EVA();

SELECT * FROM "Herbivorie".obshumidite_EVA();

-- Lire les plants d’une zone donnée
SELECT * FROM Plant_EVA_par_zone('MMA');

-- Insérer un nouveau plant
CALL Plant_INS('MMA', 'MMA0001', 'A1', DATE '2023-05-04', 'Plant observé en bordure');

-- Modifier entièrement un plant
CALL Plant_MOD('MMB', 'MMA0001', 'B2', DATE '2023-06-01', 'Plant déplacé');

-- Modifier seulement la note
CALL Plant_MOD_note('MMA0001', 'Note corrigée');

-- Supprimer un plant (strict : erreur si l’id n’existe pas)
CALL Plant_RET('MMA0001');


select * from rejets_synthese;

select * from rejets;
