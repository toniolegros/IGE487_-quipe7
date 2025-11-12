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
  CHECK (VALUE SIMILAR TO 'MM[A-C][0-9]{4}');

CREATE DOMAIN Parcelle
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
CHECK(VALUE SIMILAR TO '[A-Z]{2}[0-9]{2}');

CREATE DOMAIN Zone_id
    TEXT
    CHECK(VALUE SIMILAR TO 'MM[A-C]');

--CRATION DES TABLES

CREATE TABLE Site
(id Site_id NOT NULL,
site Description NOT NULL,
description Description,
CONSTRAINT site_cc0 primary key (id)
);
COMMENT ON TABLE Site IS 'Site: unité géographique (ex: zone d''étude).';
COMMENT ON COLUMN site.id IS 'Identifiant du site (ex: SA01)';
COMMENT ON COLUMN Site.site IS 'Nom lisible du site';

CREATE TABLE Zone(
    zone zone_id not null ,
    id Site_id NOT NULL,
    description description,
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
  description Description,
  CONSTRAINT Peuplement_cc0 PRIMARY KEY (peup)
);

CREATE TABLE Arbre
 -- Répertoire des variétés d’arbres.
 -- PRÉDICAT : La variété d’arbres identifiée par "arbre" correspond à la description "description".
(
  arbre       Arbre_id    not null ,
  description Description,
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


CREATE TABLE Taux_valeur (
  id SERIAL PRIMARY KEY,
  tCat TTaux NOT NULL,
  tVal Taux_val NOT NULL,
  FOREIGN KEY (tCat) REFERENCES Taux (tCat)
);

CREATE TABLE UNITE(
    UNITE_ID INTEGER NOT NULL,
    UNITE TEXT NOT NULL,
    DESCRIPTION description,
    CONSTRAINT UNITE_CC0 PRIMARY KEY (UNITE_ID)
);
COMMENT ON TABLE Unite IS 'Unité de mesure (ex: mm, °C, %).';
COMMENT ON COLUMN Unite.unite_id IS 'Code unité (ex: mm, °C, %)';

CREATE TABLE Placette(
 zone Zone_id not null,
 plac Placette_id not null,
CONSTRAINT placette_cc0 PRIMARY KEY (plac),
constraint placette_cr0 foreign key (zone) references Zone(zone)
);

CREATE TABLE Placette_core (
 plac Placette_id not null,
 peup Peuplement_id,
 date Date_eco NOT NULL,
CONSTRAINT placette_core_cc0 foreign key (plac) references Placette(plac),
CONSTRAINT Placette_core_cr0 FOREIGN KEY (peup) REFERENCES Peuplement(peup)
);

CREATE TABLE Placette_Dominant (
 plac  Placette_id NOT NULL,
 rang  rang    NOT NULL,
 arbre Arbre_id    NOT NULL,
 -- chaque arbre ne peut apparaître qu'une fois par placette
UNIQUE (plac, arbre),
CONSTRAINT placette_Dominant_cc0 PRIMARY KEY (plac, rang),
CONSTRAINT Placette_Dominant_cr0 FOREIGN KEY (plac) REFERENCES placette(plac),
CONSTRAINT Placette_Dominant_cr1 FOREIGN KEY (arbre) REFERENCES arbre(arbre)
);

CREATE TABLE Placette_Obstruction (
 plac Placette_id NOT NULL,
 nature obstruction_nature NOT NULL,
 hauteur hauteur_obs NOT NULL,
 tcat TTaux NOT NULL,
 CONSTRAINT Placette_Obstruction_cc0 PRIMARY KEY (plac, nature, hauteur),
 CONSTRAINT Placette_Obstruction_cr0 FOREIGN KEY (plac) REFERENCES Placette(plac),
 CONSTRAINT Placette_Obstruction_cr1 FOREIGN KEY (tcat) REFERENCES Taux(tCat)
);

CREATE TABLE Placette_Couvert (
 plac Placette_id NOT NULL,
 ctype couvert_type NOT NULL,
 tcat  TTaux NOT NULL,
 CONSTRAINT Placette_Couvert_cc0 PRIMARY KEY (plac, ctype),
 CONSTRAINT Placette_Couvert_cr0 FOREIGN KEY (plac) REFERENCES Placette(plac),
 CONSTRAINT Placette_Couvert_cr1 FOREIGN KEY (tcat) REFERENCES Taux(tCat)
);

CREATE TABLE Parcelle1 (
  plac Placette_id NOT NULL, -- placette dans laquelle est le trille
  parcelle Parcelle    NOT NULL, -- parcelle dans laquelle se trouve le trille
  CONSTRAINT PARCELLE_cr0 FOREIGN KEY (plac) REFERENCES Placette (plac)
);


CREATE TABLE Plant
 -- Répertoire des plants de trille et de leur emplacement.
 -- PRÉDICAT : Le plant "id" a été identifié dans la parcelle "parcelle" de la
 --   placette "placette" en date du "date".
 --   À cette occasion, l’observateur a consigné le commentaire "note".
(
  id       Plant_id    NOT NULL, -- identifiant unique de chaque trille
  plac Placette_id NOT NULL, -- placette dans laquelle est le trille
  date     Date_eco    not null, -- date de la prise de données
  note     Description, -- note supplémentaire à propos du trille
  CONSTRAINT Plant_cc0 PRIMARY KEY (id),
  CONSTRAINT Plant_cr0 FOREIGN KEY (plac) REFERENCES Placette (plac)
);
-- ALTER TABLE Plant ALTER COLUMN note DROP NOT NULL;

CREATE TABLE ObsDimension
 -- Répertoire des observations de dimension de plants de trille.
 -- PRÉDICAT : Il a été observé en date du "date" que le plan "id" possédait une feuille
 --   de dimension "longueur" par "largeur".
 --   À cette occasion, l’observateur a consigné le commentaire "note".
(
  id       Plant_id NOT NULL, -- identifiant unique de chaque trille
  longueur Dim_mm   NOT NULL, -- longueur d’une des feuilles d’un trille, en mm
  largeur  Dim_mm   NOT NULL, -- largeur d’une des feuilles d’un trille, en mm
  date     Date_eco not null, -- date de l’observation
  note     Description, -- note supplémentaire à propos du trille
  CONSTRAINT ObsDimension_cc0 PRIMARY KEY (id, date),
  CONSTRAINT ObsDimension_cr0 FOREIGN KEY (id) REFERENCES Plant (id)
);

CREATE TABLE ObsFloraison
 -- Répertoire des observations de floraison de plants de trille.
 -- PRÉDICAT : Il a été observé au jour "date" que le plan "id" possédait une fleur (ou non).
 --   À cette occasion, l’observateur a consigné le commentaire "note".
(
  id       Plant_id NOT NULL, -- identifiant unique de chaque trille
  fleur    BOOLEAN  NOT NULL, -- présence de fleur
  date     Date_eco NOT NULL, -- date de l’observation
  note     Description, -- note supplémentaire à propos du trille
  CONSTRAINT ObsFloraison_cc0 PRIMARY KEY (id, date),
  CONSTRAINT ObsFloraison_cr0 FOREIGN KEY (id) REFERENCES Plant (id)
);

CREATE TABLE Etat
 -- Répertoire des états d’un plant.
 -- PRÉDICAT : L’état d’un plant identifié par "etat" correspond à la description "description".
(
  etat        Etat_id     NOT NULL,
  description Description,
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
  note     Description, -- note supplémentaire à propos du trille
  CONSTRAINT ObsEtat_cc0 PRIMARY KEY (id, date),
  CONSTRAINT ObsEtat_cr0 FOREIGN KEY (id) REFERENCES Plant (id),
  CONSTRAINT ObsEtat_cr1 FOREIGN KEY (etat) REFERENCES Etat (etat)
);

CREATE TABLE PLANT1
(id Plant_id NOT NULL,
PLAC Placette_id NOT NULL,
CONSTRAINT plant1_cr0 PRIMARY KEY (id),
CONSTRAINT plant1_cc0 FOREIGN KEY (plac) references placette(plac)
);

CREATE OR REPLACE FUNCTION verif_taux_valide()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Taux
    WHERE tCat = NEW.tCat
      AND NEW.tVal BETWEEN tMin AND tMax
  ) THEN
    RAISE EXCEPTION 'Le taux % est invalide pour la catégorie %', NEW.tVal, NEW.tCat;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;