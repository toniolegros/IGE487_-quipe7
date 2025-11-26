--
-- Création du schéma
--
DROP SCHEMA IF EXISTS "Herbivorie" CASCADE ;
CREATE SCHEMA "Herbivorie" ;
SET SCHEMA 'Herbivorie' ;

--
-- Description des placettes
--
--CREATION DES TYPES ENUMERATIONS
CREATE TYPE Ttaux AS ENUM ('A', 'B', 'C', 'D', 'E','F');
CREATE TYPE obstruction_nature AS ENUM ('feuillu','coniferien','total');
CREATE TYPE hauteur_obs AS ENUM ('1m','2m');
CREATE TYPE couvert_type AS ENUM ('graminees','mousses','fougeres');
CREATE TYPE unite_mesure AS ENUM ('mm', 'cm', '%', '°C');


--CREATION DES DOMAIN
CREATE DOMAIN Arbre_id
 -- Code identifiant uniquement une variété d’arbres.
  text
  CHECK (VALUE SIMILAR TO '[A-Z]{2}[0-9]{2}');

CREATE DOMAIN Description
 -- Description textuelle consignée par l’observateur.
 -- Typiquement, une définition, une annotation ou un commentaire associé à une observation.
  TEXT
  CHECK (CHAR_LENGTH (VALUE) BETWEEN 1 AND 400);

CREATE DOMAIN Peuplement_id
 -- Code identifiant uniquement un peuplement végétal de parcelle.
  TEXT
  CHECK (VALUE SIMILAR TO '[A-Z][0-9]{4}');

CREATE DOMAIN Dim_mm
 -- Dimension d’une feuille de trille exprimée en millimètre.
  INTEGER
  CHECK (VALUE BETWEEN 1 AND 999);

CREATE DOMAIN Placette_id
 -- Code identifiant uniquement une placette.
  TEXT
  CHECK (VALUE SIMILAR TO '[A-Z][0-9]');

CREATE DOMAIN Date_eco
 -- Date d’une observation écologique.
  DATE
  CHECK (VALUE >= '1582-12-20' and VALUE <= current_date);

CREATE DOMAIN rang
    INTEGER
    CHECK (VALUE BETWEEN 1 AND 3);

CREATE DOMAIN unite_id
    INTEGER
    CHECK (VALUE BETWEEN 1 AND 4);

CREATE DOMAIN Taux_val
 -- Valeur correspondant à la proportion d’une couverture à un centième près.
  INTEGER
  CHECK (VALUE BETWEEN 0 AND 100);

/*CREATE DOMAIN Taux_id
 -- Code identifiant uniquement un intervalle de couverture communément appelé «taux».
 -- Ces codes sont utilisés notamment lors de la mesure de l’obstruction latérale de la surface au sol.
  TEXT
  CHECK (VALUE SIMILAR TO '[A-Z]{1}');*/

CREATE DOMAIN Plant_id
 -- Code identifiant uniquement un plant de trille.
  TEXT
  CHECK (VALUE SIMILAR TO '[A-Z]{3}[0-9]{4}');

CREATE DOMAIN Parcelle_id
 -- La parcelle est une subdivision de la placette.
  INTEGER
  CHECK (VALUE BETWEEN 0 AND 99);

CREATE DOMAIN Etat_id
 -- Code identifiant uniquement un état d’un plant.
 -- NOTE : La définition est identique à celle de Peuplement_id.
 --   C’est une coïncidence, pas une conséquence d’une assertion commune.
 --   Il est donc important de les distinguer en regard de l'évolutivité.
  TEXT
  CHECK (VALUE SIMILAR TO '[A-Z]{1}');

CREATE DOMAIN Site_id
TEXT
CHECK(VALUE SIMILAR TO 'M[A-Z]{1}');


CREATE DOMAIN Zone_id
    TEXT
    CHECK(VALUE SIMILAR TO '[A-Z]{3}');
COMMENT ON DOMAIN Zone_id IS 'Code de zone relatif à un site (ex: MMA).';



--CRÉATION DES TABLES

CREATE TABLE Site
(id Site_id NOT NULL,
site Description NOT NULL,
description Description NOT NULL,
CONSTRAINT site_cc0 primary key (id)
);
COMMENT ON TABLE Site IS 'Site: unité géographique (ex: zone d''étude).';
COMMENT ON COLUMN site.id IS 'Identifiant du site (ex: SA01)';
COMMENT ON COLUMN Site.site IS 'Nom lisible du site';

CREATE TABLE Zone(
    id Site_id NOT NULL,
    zone zone_id not null ,
    description description NOT NULL,
    constraint zone_cc0 primary key (zone),
    constraint zone_cr0 foreign key (id) references site(id)

);
COMMENT ON TABLE Zone IS 'Zone: subdivision d''un site. (Site -> Zone -> Placette)';
COMMENT ON COLUMN Zone.id IS 'Référence au Site parent';

CREATE TABLE Peuplement
 -- Répertoire des types de peuplement végétal d’une parcelle.
 -- PRÉDICAT : Le type de peuplement identifié par "peup" correspond à la description "description".
(
  peup        Peuplement_id NOT NULL,
  description Description NOT NULL,
  CONSTRAINT Peuplement_cc0 PRIMARY KEY (peup)
);

CREATE TABLE Arbre
 -- Répertoire des variétés d’arbres.
 -- PRÉDICAT : La variété d’arbres identifiée par "arbre" correspond à la description "description".
(
  arbre       Arbre_id    not null ,
  description Description NOT NULL,
  CONSTRAINT Arbre_cc0 PRIMARY KEY (arbre)
);

CREATE TABLE Taux
 -- Répertoire des codes de couverture communément appelés «taux».
 -- PRÉDICAT : Le code de couverture identifié par "tCat" correspond à l’intervalle
 --   de couverture [tMin..tMax].
 -- NOTE : Le choix d’une représentation discrète pour Taux_val a conduit
 --   naturellement à définir le taux de la catégorie tCat par un intervalle
 --   fermé-fermé [compris entre tMin (inclusivement) et tMax (inclusivement)].
 -- CONTRAINTE : Compacité sur [0..100]
 --   Il ne doit y avoir aucun recoupement entre les intervalles associés
 --   aux codes définis et l’union des intervalles définis doit couvrir la totalité
 --   du spectre 0..100.
 -- TODO 2025-01-29 LL01. Mettre en oeuvre la contrainte de compacité.
(
  tCat TTaux  NOT NULL,
  tMin Taux_val NOT NULL,
  tMax Taux_val NOT NULL,
  CONSTRAINT Taux_cc0 PRIMARY KEY (tCat),
  CONSTRAINT Taux_inter CHECK (tMin <= tMax)
);
INSERT INTO taux(tCat, tMin, tMax) VALUES ('A', 75, 100);
INSERT INTO taux(tCat, tMin, tMax) VALUES ('B', 50, 75);
INSERT INTO taux(tCat, tMin, tMax) VALUES ('C', 25, 50);
INSERT INTO taux(tCat, tMin, tMax) VALUES ('D', 5, 25);
INSERT INTO taux(tCat, tMin, tMax) VALUES ('E', 1, 5);
INSERT INTO taux(tCat, tMin, tMax) VALUES ('F', 0, 0);

CREATE TABLE UNITE(
    UNITE_ID unite_id NOT NULL,
    UNITE unite_mesure NOT NULL,
    DESCRIPTION description NOT NULL,
    CONSTRAINT UNITE_CC0 PRIMARY KEY (UNITE_ID)
);
COMMENT ON TABLE Unite IS 'Unité de mesure (ex: mm, °C, %).';
COMMENT ON COLUMN Unite.unite_id IS 'Code unité (ex: mm, °C, %)';
INSERT INTO UNITE(unite_id, unite, description) VALUES (1, 'mm', 'millmimètres');
INSERT INTO UNITE (unite_id, unite, description) VALUES (2, 'cm', 'centimètres') ;
INSERT INTO UNITE (unite_id, unite, description) VALUES (3, '°C', 'Celsuis') ;
INSERT INTO UNITE (unite_id, unite, description) VALUES (4, '%', 'Pourcentage') ;


CREATE TABLE Placette(
 zone Zone_id not null,
 plac Placette_id not null,
CONSTRAINT placette_cc0 PRIMARY KEY (zone,plac),
constraint placette_cr0 foreign key (zone) references Zone(zone)
);

CREATE TABLE Placette_core (
 zone zone_id not null,
 plac Placette_id not null,
 peup Peuplement_id NOT NULL,
 date Date_eco NOT NULL,
CONSTRAINT placette_core_cc0 PRIMARY KEY (zone, plac, peup, date),
CONSTRAINT placette_core_cr0 foreign key (zone,plac) references Placette(zone,plac),
CONSTRAINT Placette_core_cr1 FOREIGN KEY (peup) REFERENCES Peuplement(peup)
);

CREATE TABLE Placette_Dominant (
 zone Zone_id not null,
 plac  Placette_id NOT NULL,
 rang  rang    NOT NULL,
 arbre Arbre_id    NOT NULL,
 -- chaque arbre ne peut apparaître qu'une fois par placette
UNIQUE (plac, arbre),
CONSTRAINT placette_Dominant_cc0 PRIMARY KEY (zone, plac, rang),
CONSTRAINT Placette_Dominant_cr0 FOREIGN KEY (zone,plac) references Placette(zone,plac),
CONSTRAINT Placette_Dominant_cr1 FOREIGN KEY (arbre) REFERENCES arbre(arbre)
);

CREATE TABLE Placette_Obstruction (
 zone Zone_id not null,
 plac Placette_id NOT NULL,
 nature obstruction_nature NOT NULL,
 hauteur hauteur_obs NOT NULL,
 tcat TTaux NOT NULL,
 tval taux_val not null,
 CONSTRAINT Placette_Obstruction_cc0 PRIMARY KEY (zone, plac, nature, hauteur),
 CONSTRAINT Placette_Obstruction_cr0 FOREIGN KEY (zone,plac) references Placette(zone,plac),
 CONSTRAINT Placette_Obstruction_cr1 FOREIGN KEY (tcat) REFERENCES Taux(tCat)
);

CREATE TABLE Placette_Couvert (
 zone Zone_id not null,
 plac Placette_id NOT NULL,
 ctype couvert_type NOT NULL,
 tcat  TTaux NOT NULL,
 tval taux_val not null,
 CONSTRAINT Placette_Couvert_cc0 PRIMARY KEY (zone, plac, ctype),
 CONSTRAINT Placette_Couvert_cr0 FOREIGN KEY (zone,plac) references Placette(zone,plac),
 CONSTRAINT Placette_Couvert_cr1 FOREIGN KEY (tcat) REFERENCES Taux(tCat)
);

CREATE TABLE Parcelle (
  zone Zone_id not null,
  plac Placette_id NOT NULL, -- placette dans laquelle est le trille
  parcelle Parcelle_id    NOT NULL, -- parcelle dans laquelle se trouve le trille
  CONSTRAINT PARCELLE_cc0 PRIMARY KEY (zone, plac, parcelle),
  CONSTRAINT PARCELLE_cr0 FOREIGN KEY (zone,plac) references Placette(zone,plac)
);


CREATE TABLE Plant
 -- Répertoire des plants de trille et de leur emplacement.
 -- PRÉDICAT : Le plant "id" a été identifié dans la parcelle "parcelle" de la
 --   placette "placette" en date du "date".
 --   À cette occasion, l’observateur a consigné le commentaire "note".
(
  zone Zone_id not null,
  id       Plant_id    NOT NULL, -- identifiant unique de chaque trille
  plac Placette_id NOT NULL, -- placette dans laquelle est le trille
  date     Date_eco    not null, -- date de la prise de données
  note     Description NOT NULL, -- note supplémentaire à propos du trille
  CONSTRAINT Plant_cc0 PRIMARY KEY (id),
  CONSTRAINT Plant_cr0 FOREIGN KEY (zone,plac) references Placette(zone,plac)
);
-- ALTER TABLE Plant ALTER COLUMN note DROP NOT NULL;

CREATE TABLE ObsDimension
 -- Répertoire des observations de dimension de plants de trille.
 -- PRÉDICAT : Il a été observé en date du "date" que le plan "id" possédait une feuille
 --   de dimension "longueur" par "largeur".
 --   À cette occasion, l’observateur a consigné le commentaire "note".
(
  id       Plant_id NOT NULL,
  longueur Dim_mm   NOT NULL,
  largeur  Dim_mm   NOT NULL,
  date     Date_eco NOT NULL,
  unite_id unite_id NOT NULL DEFAULT 1, -- unité de mesure
  note     Description,
  CONSTRAINT ObsDimension_cc0 PRIMARY KEY (id, date),
  CONSTRAINT ObsDimension_cr0 FOREIGN KEY (id) REFERENCES Plant(id),
  CONSTRAINT ObsDimension_cr1 FOREIGN KEY (unite_id) REFERENCES UNITE(UNITE_ID)

);

CREATE TABLE ObsFloraison
 -- Répertoire des observations de floraison de plants de trille.
 -- PRÉDICAT : Il a été observé au jour "date" que le plan "id" possédait une fleur (ou non).
 --   À cette occasion, l’observateur a consigné le commentaire "note".
(
  id       Plant_id NOT NULL, -- identifiant unique de chaque trille
  fleur    BOOLEAN  NOT NULL, -- présence de fleur
  date     Date_eco NOT NULL, -- date de l’observation
  note     Description NOT NULL, -- note supplémentaire à propos du trille
  CONSTRAINT ObsFloraison_cc0 PRIMARY KEY (id, date),
  CONSTRAINT ObsFloraison_cr0 FOREIGN KEY (id) REFERENCES Plant (id)
);

CREATE TABLE Etat
 -- Répertoire des états d’un plant.
 -- PRÉDICAT : L’état d’un plant identifié par "etat" correspond à la description "description".
(
  etat        Etat_id     NOT NULL,
  description Description NOT NULL,
  CONSTRAINT Etat_cc0 PRIMARY KEY (etat)
);

CREATE TABLE ObsEtat
 -- Répertoire des observations d’état de plants de trille.
 -- PRÉDICAT : Il a été observé au jour "date" que le plant "id" était dans l’état "etat".
 --   À cette occasion, l’observateur a consigné le commentaire "note".
(
  id       Plant_id NOT NULL, -- identifiant unique de chaque trille
  etat     Etat_id  NOT NULL, -- état du plant
  date     Date_eco not null, -- date de l’observation
  note     Description NOT NULL, -- note supplémentaire à propos du trille
  CONSTRAINT ObsEtat_cc0 PRIMARY KEY (id, date),
  CONSTRAINT ObsEtat_cr0 FOREIGN KEY (id) REFERENCES Plant (id),
  CONSTRAINT ObsEtat_cr1 FOREIGN KEY (etat) REFERENCES Etat (etat)
);

-- COMMENTAIRES
COMMENT ON DOMAIN Arbre_id IS 'Identifiant d''une variété d''arbres (ex: AB12).';
COMMENT ON DOMAIN Description IS 'Texte court (1..400) : définitions, annotations, commentaires.';
COMMENT ON DOMAIN Peuplement_id IS 'Identifiant d''un type de peuplement (ex: P1234).';
COMMENT ON DOMAIN Dim_mm IS 'Dimension en mm (1..999).';
COMMENT ON DOMAIN Placette_id IS 'Identifiant relatif d''une placette à l''intérieur d''une zone (ex: A1).';
COMMENT ON DOMAIN Date_eco IS 'Date d''observation écologique (grégorien).';
COMMENT ON DOMAIN Rang IS 'Rang de dominance (1..3).';
COMMENT ON DOMAIN Taux_val IS 'Proportion entière de 0 à 100.';
COMMENT ON DOMAIN Plant_id IS 'Identifiant absolu du plant (ex: MMA0123).';
COMMENT ON DOMAIN parcelle_id IS 'Numéro de parcelle (0..99).';
COMMENT ON DOMAIN Etat_id IS 'Code d''état d''un plant (A..Z).';
COMMENT ON DOMAIN Site_id IS 'Identifiant du site (ex: SA01).';
COMMENT ON DOMAIN Zone_id IS 'Code de zone relatif à un site (ex: MMA).';

COMMENT ON TABLE Unite IS 'Unités de mesure (ex: mm, °C, %).';
COMMENT ON TABLE Peuplement IS 'Types de peuplement végétal d’une parcelle.';
COMMENT ON TABLE Arbre IS 'Variétés d’arbres.';
COMMENT ON TABLE Taux IS 'Catégories de taux (intervalle fermé [tmin..tmax]).';

COMMENT ON TABLE Site IS 'Site : unité géographique macro (ex: zone d''étude).';
COMMENT ON COLUMN Site.site IS 'Nom lisible du site.';

COMMENT ON TABLE Plant IS 'Identité absolue du plant (indépendante du lieu).';
COMMENT ON TABLE Etat IS 'Répertoire des états possibles d’un plant.';

COMMENT ON TABLE Placette_Core IS 'Attributs temporels principaux d''une placette.';
COMMENT ON TABLE Placette_Dominant IS 'Arbres dominants (un arbre unique par placette).';
COMMENT ON TABLE Placette_Obstruction IS 'Obstruction latérale par (nature, hauteur) avec tcat dans Taux.';
COMMENT ON TABLE Placette_Couvert IS 'Couvert par type; tcat référence la table de taux.';

COMMENT ON TABLE ObsDimension IS 'Dimensions de feuille observées pour un plant à une date.';
COMMENT ON TABLE ObsFloraison IS 'Floraison observée (booléen) pour un plant à une date.';
COMMENT ON TABLE ObsEtat IS 'État observé d’un plant (id, date) → etat.';

CREATE OR REPLACE FUNCTION check_tval_in_taux_bounds(tcat1 TTaux, tval Taux_val)
RETURNS boolean AS $$
DECLARE
    lo int;
    hi int;
BEGIN
    -- Si catégorie inconnue → invalide
    SELECT tmin, tmax INTO lo, hi FROM Taux WHERE tCat = tcat1;

    IF lo IS NULL OR hi IS NULL THEN
        RETURN FALSE;
    END IF;

    RETURN (tval BETWEEN lo AND hi);
END;
$$ LANGUAGE plpgsql;


