SET SCHEMA 'Herbivorie';


CREATE TABLE JeuTests_Complet (
  -- Blocs pour SITE
  site_id           TEXT,
  site_nom          TEXT,
  site_description  TEXT,

  -- Blocs pour ZONE
  zone_code         TEXT,
  zone_site_id      TEXT,
  zone_description  TEXT,

  -- Blocs pour PEUPLEMENT
  peup_code         TEXT,
  peup_description  TEXT,

  -- Blocs pour ARBRE
  arbre_code        TEXT,
  arbre_description TEXT,

  -- Blocs pour TAUX (référentiel)
  taux_cat          TEXT,
  taux_min          TEXT,
  taux_max          TEXT,

  -- Blocs pour TAUX_VALEUR
  tauxv_cat         TEXT,
  tauxv_val         TEXT,

  -- Blocs pour UNITE
  unite_id          TEXT,
  unite_code        TEXT,
  unite_description TEXT,

  -- Blocs pour PLACETTE
  plac_code         TEXT,

  -- Blocs pour PLACETTE_CORE
  placcore_plac     TEXT,
  placcore_peup     TEXT,
  placcore_date     TEXT,

  -- Blocs pour PLACETTE_DOMINANT
  placdom_plac      TEXT,
  placdom_rang      TEXT,
  placdom_arbre     TEXT,

  -- Blocs pour PLACETTE_OBSTRUCTION
  placobs_plac      TEXT,
  placobs_nature    TEXT,
  placobs_hauteur   TEXT,
  placobs_tcat      TEXT,

  -- Blocs pour PLACETTE_COUVERT
  placcouv_plac     TEXT,
  placcouv_ctype    TEXT,
  placcouv_tcat     TEXT,

  -- Blocs pour PARCELLE1
  parc_plac         TEXT,
  parc_num          TEXT,

  -- Blocs pour PLANT
  plant_id          TEXT,
  plant_plac        TEXT,
  plant_date        TEXT,
  plant_note        TEXT,

  -- Blocs pour OBSDIMENSION
  obsdim_id         TEXT,
  obsdim_long       TEXT,
  obsdim_larg       TEXT,
  obsdim_date       TEXT,
  obsdim_note       TEXT,

  -- Blocs pour OBSFLORAISON
  obsfl_id          TEXT,
  obsfl_fleur       TEXT,
  obsfl_date        TEXT,
  obsfl_note        TEXT,

  -- Blocs pour ETAT
  etat_code         TEXT,
  etat_description  TEXT,

  -- Blocs pour OBSETAT
  obsetat_id        TEXT,
  obsetat_etat      TEXT,
  obsetat_date      TEXT,
  obsetat_note      TEXT,

  -- Blocs pour PLANT1
  plant1_id         TEXT,
  plant1_plac       TEXT
);

INSERT INTO JeuTests_Complet (
  site_id, site_nom, site_description,
  zone_code, zone_site_id, zone_description,
  peup_code, peup_description,
  arbre_code, arbre_description,
  taux_cat, taux_min, taux_max,
  tauxv_cat, tauxv_val,
  unite_id, unite_code, unite_description,
  plac_code,
  placcore_plac, placcore_peup, placcore_date,
  placdom_plac, placdom_rang, placdom_arbre,
  placobs_plac, placobs_nature, placobs_hauteur, placobs_tcat,
  placcouv_plac, placcouv_ctype, placcouv_tcat,
  parc_plac, parc_num,
  plant_id, plant_plac, plant_date, plant_note,
  obsdim_id, obsdim_long, obsdim_larg, obsdim_date, obsdim_note,
  obsfl_id, obsfl_fleur, obsfl_date, obsfl_note,
  etat_code, etat_description,
  obsetat_id, obsetat_etat, obsetat_date, obsetat_note,
  plant1_id, plant1_plac
)
VALUES
-- 1) Cas 100 % valide pour quasiment tout
('SA01','Site A','Site principal',
 'MMA','SA01','Zone A du site A',
 'P0001','Peuplement feuillu dense',
 'AB12','Érable à sucre',
 'A','0','10',
 'A','5',
 '1','mm','Millimetre',
 'A1',
 'A1','P0001','2020-05-12',
 'A1','1','AB12',
 'A1','feuillu','1m','A',
 'A1','graminees','A',
 'A1','1',
 'MMA0001','A1','2020-05-12','Plant sain',
 'MMA0001','20','15','2020-05-12','dimension OK',
 'MMA0001','1','2020-05-12','fleur OK',
 'A','Plant sain',
 'MMA0001','A','2020-05-12','etat OK',
 'MMA0001','A1'),

-- 2) Id plant invalide, etat invalide, longueur invalide
('SA02','Site B','Autre site',
 'MMB','SA02','Zone B',
 'P0002','Peuplement coniférien',
 'CD34','Sapin baumier',
 'B','11','30',
 'B','25',
 '2','°C','Degré Celsius',
 'B2',
 'B2','P0002','2021-06-01',
 'B2','2','CD34',
 'B2','coniferien','2m','B',
 'B2','fougeres','B',
 'B2','2',
 'XXX001','B2','2021-06-01','ID plant invalide',
 'XXX001','NA','10','2021-06-01','longueur NA',
 'XXX001','true','2021-06-01','fleur OK format',
 'AA','Code etat trop long',
 'XXX001','AA','2021-06-01','etat invalide',
 'XXX001','B2'),

-- 3) Placette invalide, parcelle invalide, date invalide
('SA03','Site C','Site test',
 'MMC','SA03','Zone C',
 'P0003','Peuplement mixte',
 'EF56','Pin gris',
 'C','31','60',
 'C','40',
 '3','%','Pourcentage',
 '11A',        -- plac_code invalide (pour tester placette_verif)
 '11A','P0003','2020-13-01',   -- date invalide
 '11A','1','EF56',
 '11A','feuillu','1m','C',
 '11A','mousses','C',
 '11A','X',    -- parcelle invalide
 'MMB0001','11A','2020-13-01','Placette et date invalides',
 'MMB0001','25','20','2020-13-01','dimension avec date invalide',
 'MMB0001','1','2020-13-01','fleur OK mais date KO',
 'B','Etat ok B',
 'MMB0001','B','2020-13-01','etat ok mais date KO',
 'MMB0001','11A'),

-- 4) Fleur invalide, largeur non numérique, etat vide
('SA04','Site D','Site test 2',
 'MMD','SA04','Zone D',
 'P0004','Peuplement test',
 'GH78','Chêne rouge',
 'D','0','100',
 'D','90',
 '4','cm','Centimètre',
 'C3',
 'C3','P0004','2022-03-10',
 'C3','1','GH78',
 'C3','total','2m','D',
 'C3','graminees','D',
 'C3','3',
 'MMB0002','C3','2022-03-10','note vide test',
 'MMB0002','15','xx','2022-03-10','largeur non numérique',
 'MMB0002','maybe','2022-03-10','fleur invalide',
 'C','Etat C ok',
 'MMB0002','', '2022-03-10','etat vide',
 'MMB0002','C3'),

-- 5) Parcelle hors intervalle, longueur = 0, note trop longue
('SA05','Site E','Site test 3',
 'MME','SA05','Zone E',
 'P0005','Peuplement test 5',
 'IJ90','Bouleau jaune',
 'E','0','50',
 'E','5',
 '5','m','Mètre',
 'E1',
 'E1','P0005','2023-01-01',
 'E1','1','IJ90',
 'E1','feuillu','1m','E',
 'E1','fougeres','E',
 'E1','150',      -- parcelle > 99
 'MMC0001','E1','2023-01-01',RPAD('x',410,'x'), -- note > 400
 'MMC0001','0','10','2023-01-01','longueur 0',
 'MMC0001','1','2023-01-01','fleur ok',
 'Z','Etat limite Z',
 'MMC0001','Z','2023-01-01','etat ok',
 'MMC0001','E1');
