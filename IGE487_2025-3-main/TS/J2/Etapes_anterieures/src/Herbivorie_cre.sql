/*
////
-- =========================================================================== A
-- Herbivorie_cre.sql
-- ---------------------------------------------------------------------------
Activité : IFT187_2025-1
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 17
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.1.3a
Statut : applicable
Résumé : Création modèle logique du schéma Herbivorie.
-- =========================================================================== A
*/

/*
-- =========================================================================== B
////
Création du schéma SQL correspondant au modèle logique proposé pour la collecte
des données de terrain du projet Herbivorie dans le document de modélisation [SML].

Pour rappel, l’esquisse initiale du modèle logique est la suivante :

    Etat (etat, description)
      cle {etat};
    Peuplement (peup, description)
      cle {peuplement};
    Arbre (arbre, description)
      cle {arbre};
    Taux {tCat, tMin, tMax}
      cle {tCat}
    Placette {placette, peu,
      obs_F1, obs_F2, obs_C1, obs_C2, obs_T1, obs_T2,
      graminees, mousses, fougeres,
      arb_P1, arb_P2, arb_P3,
      date, note}
      clé {placette}
      ref {obs_F1} -> Taux {tCat}
      ref {obs_F2} -> Taux {tCat}
      ref {obs_C1} -> Taux {tCat}
      ref {obs_C2} -> Taux {tCat}
      ref {obs_T1} -> Taux {tCat}
      ref {obs_T2} -> Taux {tCat}
      ref {graminees} -> Taux {tCat}
      ref {mousses} -> Taux {tCat}
      ref {fougeres} -> Taux {tCat}
      ref {arb_P1} -> Arbre {arbre}
      ref {arb_P2} -> Arbre {arbre}
      ref {arb_P2} -> Arbre {arbre};
    Plant {id, placette, parcelle, date, note}
      cle {id}
      ref id -> Plant
      ref placette -> Placette;
    Observation {id, largeur, longueur, floraison, etat, date, note}
      clé {id, date}
      ref id -> Plant
      ref etat -> Etat;

.Précisions
 a. Obstruction latérale : prend en compte les obstructions sur une distance de
    10 m, à des hauteurs de 1 et 2 mètres.
 b. Floraison : vrai ssi le plant porte une fleur (qu’elle soit ouverte ou pas)
    ou un fruit ; permet de déterminer si un plant est (potentiellement)
    reproducteur ou pas.
 c. Une parcelle est une subdivision de la placette qui permet de faciliter le
    repérage des plants.
 d. Les conventions relatives aux codes (plants, placettes, parcelles, etc.) sont
    celles qui nous ont été communiquées au 2017-09-17.
 e. On présume qu’aucune donnée n’a été consignée antérieurement au 20 décembre 1582,
    ce qui légitime l’usage exclusif du calendrier grégorien (en vigueur en France
    et en Nouvelle-France depuis cette date).
 f. Pour plus de détails, voir [EPP, SML].

.Notes de mise en oeuvre
 a. Les descriptions ont été arbitrairement limitées à 60 caractères ;
    il conviendrait sans doute d’augmenter cette limite substantiellement.
 b. Les observations sont décomposées en trois tables afin de permettre un
    meilleur traitement des données manquantes.
////
-- =========================================================================== B
*/

--
-- Création du schéma
--
DROP SCHEMA IF EXISTS "Herbivorie" CASCADE ;
CREATE SCHEMA "Herbivorie" ;
SET SCHEMA 'Herbivorie' ;

--
-- Description des placettes
--
CREATE DOMAIN Arbre_id
 -- Code identifiant uniquement une variété d’arbres.
  text
  CHECK (VALUE SIMILAR TO '[A-Z]{2}[0-9]{2}');

CREATE DOMAIN Description
 -- Description textuelle consignée par l’observateur.
 -- Typiquement, une définition, une annotation ou un commentaire associé à une observation.
  TEXT
  CHECK (CHAR_LENGTH (VALUE) BETWEEN 1 AND 400);

CREATE TABLE Arbre
 -- Répertoire des variétés d’arbres.
 -- PRÉDICAT : La variété d’arbres identifiée par "arbre" correspond à la description "description".
(
  arbre       Arbre_id    not null ,
  description Description NOT NULL,
  CONSTRAINT Arbre_cc0 PRIMARY KEY (arbre)
);

CREATE DOMAIN Peuplement_id
 -- Code identifiant uniquement un peuplement végétal de parcelle.
  TEXT
  CHECK (VALUE SIMILAR TO '[A-Z][0-9]{4}');

CREATE TABLE Peuplement
 -- Répertoire des types de peuplement végétal d’une parcelle.
 -- PRÉDICAT : Le type de peuplement identifié par "peup" correspond à la description "description".
(
  peup        Peuplement_id NOT NULL,
  description Description   NOT NULL,
  CONSTRAINT Peuplement_cc0 PRIMARY KEY (peup)
);

CREATE DOMAIN Taux_val
 -- Valeur correspondant à la proportion d’une couverture à un centième près.
  INTEGER
  CHECK (VALUE BETWEEN 0 AND 100);

CREATE DOMAIN Taux_id
 -- Code identifiant uniquement un intervalle de couverture communément appelé «taux».
 -- Ces codes sont utilisés notamment lors de la mesure de l’obstruction latérale de la surface au sol.
  TEXT
  CHECK (VALUE SIMILAR TO '[A-Z]{1}');

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
  tCat Taux_id  NOT NULL,
  tMin Taux_val NOT NULL,
  tMax Taux_val NOT NULL,
  CONSTRAINT Taux_cc0 PRIMARY KEY (tCat),
  CONSTRAINT Taux_inter CHECK (tMin <= tMax)
);

CREATE DOMAIN Placette_id
 -- Code identifiant uniquement une placette.
  TEXT
  CHECK (VALUE SIMILAR TO '[A-Z][0-9]');

CREATE DOMAIN Date_eco
 -- Date d’une observation écologique.
  DATE
  CHECK (VALUE >= '1582-12-20' and value <= current_date);

/*CREATE TABLE Placette
 -- Description de la placette
 -- PRÉDICAT : La placette identifiée par "plac" a été caractérisée grâce aux observations
 --   faites en date du "date" et consignées grâce aux autres attributs décrits ci-après.
(
  plac      Placette_id   NOT NULL, -- désignation de la placette
  peup     Peuplement_id NOT NULL, -- type de peuplement de la placette
  obs_F1    Taux_id       NOT NULL, -- taux d’obstruction latérale feuillue moyenne à 1 m de hauteur
  obs_F2    Taux_id       NOT NULL, -- taux d’obstruction latérale feuillue moyenne à 2 m de hauteur
  obs_C1    Taux_id       NOT NULL, -- taux d’obstruction latérale coniférienne moyenne à 1 m de hauteur
  obs_C2    Taux_id       NOT NULL, -- taux d’obstruction latérale coniférienne moyenne à 2 m de hauteur
  obs_T1    Taux_id       NOT NULL, -- taux d’obstruction latérale totale moyenne à 1 m de hauteur
  obs_T2    Taux_id       NOT NULL, -- taux d’obstruction latérale totale moyenne à 2 m de hauteur
  graminees Taux_id       NOT NULL, -- taux d’occupation au sol des graminées dans la placette
  mousses   Taux_id       NOT NULL, -- taux d’occupation au sol des mousses dans la placette
  fougeres  Taux_id       NOT NULL, -- taux d’occupation au sol des fougères dans la placette
  arb_P1    Arbre_id      NOT NULL, -- arbre dominant de la placette (1er rang)
  arb_P2    Arbre_id      NOT NULL, -- arbre dominant de la placette (2e rang)
  arb_P3    Arbre_id      NOT NULL, -- arbre dominant de la placette (3e rang)
  date      Date_eco     not null, -- date à laquelle la description a été établie
  CONSTRAINT Placette_cc0 PRIMARY KEY (plac),
  CONSTRAINT Placette_cr_pe FOREIGN KEY (peup) REFERENCES Peuplement (peup),
  CONSTRAINT Placette_cr_f1 FOREIGN KEY (obs_F1) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_f2 FOREIGN KEY (obs_F2) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_c1 FOREIGN KEY (obs_C1) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_c2 FOREIGN KEY (obs_C2) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_t1 FOREIGN KEY (obs_T1) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_t2 FOREIGN KEY (obs_T2) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_gr FOREIGN KEY (graminees) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_mo FOREIGN KEY (mousses) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_fo FOREIGN KEY (fougeres) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_p1 FOREIGN KEY (arb_P1) REFERENCES Arbre (arbre),
  CONSTRAINT Placette_cr_p2 FOREIGN KEY (arb_P2) REFERENCES Arbre (arbre),
  CONSTRAINT Placette_cr_p3 FOREIGN KEY (arb_P3) REFERENCES Arbre (arbre),
  CONSTRAINT arbres_distincts CHECK (arb_P1 <> arb_P2 AND arb_P2 <> arb_P3 AND arb_P1 <> arb_P3)
 -- NOTE : Comment vérifier que obs_T1.tMin >= obs_F1.tMin + obs_C1.tMin ?
 -- NOTE : Comment vérifier que obs_T2.tMin >= obs_F2.tMin + obs_C2.tMin ?
 -- NOTE : Que faudrait-il faire pour les tMax ?
 -- NOTE : Que faudrait-il suggérer aux collègues écologistes ?
 -- NOTE : Quels outils pourrions-nous leur fournir ?
);*/
CREATE TABLE Placette_core (
 plac Placette_id PRIMARY KEY,
 peup Peuplement_id NOT NULL REFERENCES Peuplement(peup),
 date Date_eco NOT NULL
);

CREATE TYPE obstruction_nature AS ENUM ('feuillu','coniferien','total');
CREATE TYPE hauteur_obs AS ENUM ('1m','2m');
CREATE TABLE Placette_Obstruction (
 plac Placette_id NOT NULL REFERENCES Placette_core(plac) ON DELETE CASCADE,
 nature obstruction_nature NOT NULL,
 hauteur hauteur_obs NOT NULL,
 tcat Taux_id NOT NULL REFERENCES Taux(tCat),
 PRIMARY KEY (plac, nature, hauteur)
);

CREATE TYPE couvert_type AS ENUM ('graminees','mousses','fougeres');
CREATE TABLE Placette_Couvert (
 plac Placette_id NOT NULL REFERENCES Placette_core(plac) ON DELETE CASCADE,
 ctype couvert_type NOT NULL,
 tcat  Taux_id NOT NULL REFERENCES Taux(tCat),
 PRIMARY KEY (plac, ctype)
);

CREATE TABLE Placette_Dominant (
 plac  Placette_id NOT NULL REFERENCES Placette_core(plac) ON DELETE CASCADE,
 rang  smallint    NOT NULL CHECK (rang BETWEEN 1 AND 3),
 arbre Arbre_id    NOT NULL REFERENCES Arbre(arbre),
 PRIMARY KEY (plac, rang),
 -- chaque arbre ne peut apparaître qu'une fois par placette
 UNIQUE (plac, arbre)
);
--
-- Description des plants recensés dans les placettes
--
CREATE DOMAIN Plant_id
 -- Code identifiant uniquement un plant de trille.
  TEXT
  CHECK (VALUE SIMILAR TO 'MM[A-C][0-9]{4}');

CREATE DOMAIN Parcelle
 -- La parcelle est une subdivision de la placette.
  INTEGER
  CHECK (VALUE BETWEEN 0 AND 99);

CREATE TABLE Plant
 -- Répertoire des plants de trille et de leur emplacement.
 -- PRÉDICAT : Le plant "id" a été identifié dans la parcelle "parcelle" de la
 --   placette "placette" en date du "date".
 --   À cette occasion, l’observateur a consigné le commentaire "note".
(
  id       Plant_id    NOT NULL, -- identifiant unique de chaque trille
  placette Placette_id NOT NULL, -- placette dans laquelle est le trille
  parcelle Parcelle    NOT NULL, -- parcelle dans laquelle se trouve le trille
  date     Date_eco    not null, -- date de la prise de données
  note     Description        NOT NULL, -- note supplémentaire à propos du trille
  CONSTRAINT Plant_cc0 PRIMARY KEY (id),
  CONSTRAINT Plant_cr0 FOREIGN KEY (placette) REFERENCES Placette_core (plac)
);

CREATE DOMAIN Dim_mm
 -- Dimension d’une feuille de trille exprimée en millimètre.
  INTEGER
  CHECK (VALUE BETWEEN 1 AND 999);

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
  note     Description     NOT NULL, -- note supplémentaire à propos du trille
  CONSTRAINT ObsDimension_cc0 PRIMARY KEY (id, date),
  CONSTRAINT ObsDimension_cr0 FOREIGN KEY (id) REFERENCES Plant (id)
);

CREATE TABLE ObsFloraison
 -- Répertoire des observations de floraison de plants de trille.
 -- PRÉDICAT : Il a été observé au jour "date" que le plan "id" possédait une fleur (ou non).
 --   À cette occasion, l’observateur a consigné le commentaire "note".
(
  id       Plant_id NOT NULL, -- identifiant unique de chaque trille
  date     Date_eco NOT NULL, -- date de l’observation
  note     Description     NOT NULL, -- note supplémentaire à propos du trille
  CONSTRAINT ObsFloraison_cc0 PRIMARY KEY (id, date),
  CONSTRAINT ObsFloraison_cr0 FOREIGN KEY (id) REFERENCES Plant (id)
);

CREATE DOMAIN Etat_id
 -- Code identifiant uniquement un état d’un plant.
 -- NOTE : La définition est identique à celle de Peuplement_id.
 --   C’est une coïncidence, pas une conséquence d’une assertion commune.
 --   Il est donc important de les distinguer en regard de l'évolutivité.
  TEXT
  CHECK (VALUE SIMILAR TO '[A-Z]{1}');

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
  note     Description     NOT NULL, -- note supplémentaire à propos du trille
  CONSTRAINT ObsEtat_cc0 PRIMARY KEY (id, date),
  CONSTRAINT ObsEtat_cr0 FOREIGN KEY (id) REFERENCES Plant (id),
  CONSTRAINT ObsEtat_cr1 FOREIGN KEY (etat) REFERENCES Etat (etat)
);


-- Ajout de contraintes pour valider les références dans Placette
/*ALTER TABLE Placette
ADD CONSTRAINT fk_obs_F1 FOREIGN KEY (obs_F1) REFERENCES Taux (tCat),
ADD CONSTRAINT fk_obs_F2 FOREIGN KEY (obs_F2) REFERENCES Taux (tCat),
ADD CONSTRAINT fk_obs_C1 FOREIGN KEY (obs_C1) REFERENCES Taux (tCat),
ADD CONSTRAINT fk_obs_C2 FOREIGN KEY (obs_C2) REFERENCES Taux (tCat),
ADD CONSTRAINT fk_obs_T1 FOREIGN KEY (obs_T1) REFERENCES Taux (tCat),
ADD CONSTRAINT fk_obs_T2 FOREIGN KEY (obs_T2) REFERENCES Taux (tCat);*/

ALTER TABLE Plant
ADD CONSTRAINT chk_date_ident_future CHECK (date <= CURRENT_DATE);

ALTER TABLE ObsFloraison
ADD CONSTRAINT chk_date_obs_future CHECK (date <= CURRENT_DATE);

ALTER TABLE ObsFloraison
ADD CONSTRAINT fk_obsfloraison_plant FOREIGN KEY (id) REFERENCES Plant(id);

ALTER TABLE Taux
ADD CONSTRAINT chk_taux_pourcentage CHECK (tMin BETWEEN 0 AND 100 AND tMax BETWEEN 0 AND 100);

-- Ajout de contraintes pour garantir une partition stricte dans Taux
/*ALTER TABLE Taux
ADD CONSTRAINT check_taux_partition CHECK (
  NOT EXISTS (
    SELECT 1
    FROM Taux t1, Taux t2
    WHERE t1.tCat <> t2.tCat AND (
      t1.tMin <= t2.tMax AND t1.tMax >= t2.tMin
    )
  )
);*/

-- ======================================================================
-- CONTRAINTES DE COHÉRENCE TEMPORELLE (TRIGGERS)
-- ======================================================================

-- Règle : la date d’observation ≥ date d’identification du plant
CREATE OR REPLACE FUNCTION verif_date_obs() RETURNS TRIGGER AS $$
DECLARE
    date_ident_plant DATE;
BEGIN
    SELECT date INTO date_ident_plant FROM Plant WHERE id = NEW.id;

    IF date_ident_plant IS NULL THEN
        RAISE EXCEPTION 'Le plant % n''existe pas dans la table Plant.', NEW.id;
    END IF;

    IF NEW.date < date_ident_plant THEN
        RAISE EXCEPTION
            'Erreur : la date d''observation (%) ne peut précéder la date d''identification du plant (%)',
            NEW.date, date_ident_plant;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_obs_dimension_date
  BEFORE INSERT OR UPDATE ON ObsDimension
  FOR EACH ROW EXECUTE FUNCTION verif_date_obs();

CREATE TRIGGER trg_obs_floraison_date
  BEFORE INSERT OR UPDATE ON ObsFloraison
  FOR EACH ROW EXECUTE FUNCTION verif_date_obs();

CREATE TRIGGER trg_obs_etat_date
  BEFORE INSERT OR UPDATE ON ObsEtat
  FOR EACH ROW EXECUTE FUNCTION verif_date_obs();

-- ======================================================================
-- CONTRAINTES DE COMPACTICITÉ DES TAUX (EX-TODO)
-- ======================================================================

-- Vérifie que pour chaque placette :
-- tMin(taux_T1) >= tMin(taux_F1) + tMin(taux_C1)
-- et tMax(taux_T2) <= tMax(taux_F2) + tMax(taux_C1)

/*CREATE OR REPLACE FUNCTION verif_taux_compacite() RETURNS TRIGGER AS $$
DECLARE
    tf1 RECORD;
    tc1 RECORD;
    tt1 RECORD;
    tf2 RECORD;
    tc2 RECORD;
    tt2 RECORD;
BEGIN
    -- Récupération des Taux pour la ligne insérée
    SELECT * INTO tf1 FROM Taux WHERE tCat = NEW.obs_F1;
    SELECT * INTO tc1 FROM Taux WHERE tCat = NEW.obs_C1;
    SELECT * INTO tt1 FROM Taux WHERE tCat = NEW.obs_T1;

    SELECT * INTO tf2 FROM Taux WHERE tCat = NEW.obs_F2;
    SELECT * INTO tc2 FROM Taux WHERE tCat = NEW.obs_C2;
    SELECT * INTO tt2 FROM Taux WHERE tCat = NEW.obs_T2;

    -- Vérification existence des Taux
    IF tf1 IS NULL OR tc1 IS NULL OR tt1 IS NULL
       OR tf2 IS NULL OR tc2 IS NULL OR tt2 IS NULL THEN
        RAISE EXCEPTION 'Un des Taux référencés n''existe pas';
    END IF;

    -- Vérification compacité pour T1
    IF tt1.tMin < tf1.tMin + tc1.tMin THEN
        RAISE EXCEPTION 'Incohérence taux : T1.tMin < F1.tMin + C1.tMin';
    END IF;

    IF tt1.tMax > tf1.tMax + tc1.tMax THEN
        RAISE EXCEPTION 'Incohérence taux : T1.tMax > F1.tMax + C1.tMax';
    END IF;

    -- Vérification compacité pour T2
    IF tt2.tMin < tf2.tMin + tc2.tMin THEN
        RAISE EXCEPTION 'Incohérence taux : T2.tMin < F2.tMin + C2.tMin';
    END IF;
    IF tt2.tMax > tf2.tMax + tc2.tMax THEN
        RAISE EXCEPTION 'Incohérence taux : T2.tMax > F2.tMax + C2.tMax';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_placette_taux
  BEFORE INSERT OR UPDATE ON Placette_core
  FOR EACH ROW EXECUTE FUNCTION verif_taux_compacite();*/


/*
-- =========================================================================== Z
////
.Contributeurs
* (DAL) diane.auberson-lavoie@usherbrooke.ca
* (LL01) luc.lavoie@usherbrooke.ca

.TODO 2025-05-07 LL01. La fusion de Herbivorie.def et Herbivorie.cred était-elle justifiée ?
* Revoir les différents modèles de modularisation.
* Évaluer l'impact pédagogique.

.Tâches projetées
* 2022-01-23 LL01. Compléter le schéma
  - Décomposer et temporaliser les observations relatives aux placettes
    (obstruction latérale, couverture au sol, espèces dominantes, etc.).
* 2017-09-19 LL01. Compléter le schéma
  - Compléter les contraintes, en particulier :
    *** la date d’observation d’un plan ne peut être antérieure à son identification ;
    *** la date d’identification d’un plant ne peut être antérieure à celui de sa placette ;
    *** les obstructions latérales observées d’une placette doivent être cohérentes ;
    *** les couvertures au sol observées d’une placette doivent être cohérentes.
* 2017-09-18 LL01. Renommer plus rigoureusement les concepts utilisés par le schéma
  - Plusieurs identificateurs sont inappropriés en regard des concepts véhiculés.
  - Certaines abréviations prêtent à confusion.
  - La constitution d’un dictionnaire de données et l’utilisation d’une terminologie
    rigoureuse sont fortement recommandées.
  - Entre autres exemples : obs -> obstruction latérale, taux -> pourcentage,
    arb -> variété d’arbres, peup, plac, etc.

.Tâches réalisées
* 2025-02-03 LL01. Fusion des fichiers Herbivorie_def et Herbivorie_cre.
  - Pour mettre en évidence commentaire initial et simplifier la création.
* 2025-01-26 LL01. Adaptation au standard de programmation de CoFELI.
  - Mise en forme des commentaires externes en AsciiDoc.
* 2022-01-23 LL01. Épurer le schéma.
  - Déplacer les commentaires généraux dans Herbivorie_def.
  - Déplacer le carnet dans Herbi-ELT_def.
  - Remplacer les textes statiques (CHAR) par des textes dynamiques (TEXT).
  - Adapter les contraintes en conséquence.
  - Compléter certains prédicats.
  - Enrichir certains commentaires.
  - Capitaliser les types prédéfinis.
  - Corriger diverses coquilles.
* 2017-09-20 LL01. Compléter le schéma.
  - Décomposer Placette afin de permettre l’annulabilité de certaines colonnes.
  - Ne mettre que des attributs TEXT dans Carnet et parfaire les validations.
  - Introduire la table Arbre et les clés référentielles appropriées.
* 2017-09-17 LL01. Création
  - Création du schéma de base.
  - Validation minimale du carnet d’observations (voir test0).
  - Importation des observations intègres (voir ini).

.Références
* [EPP] {CoFELI}/Exemple/Herbivorie/pub/Herbivorie_EPP.pdf
* [SML] {CoFELI}/Exemple/Herbivorie/pub/Herbivorie_SML.pdf
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
-- fin de {CoFELI}/Exemple/Herbivorie/src/Herbivorie_cre.sql
-- =========================================================================== Z
*/
