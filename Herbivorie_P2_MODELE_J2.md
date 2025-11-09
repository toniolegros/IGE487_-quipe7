# Herbivorie_P2_MODELE_J2.md
Projet : Herbivorie – IGE487
Jalon : J2 – Normalisation, optimisation et documentation
Auteur(s) : [À renseigner]
Date : 2025-11-09
Objectif : Description textuelle et logique du schéma final pour J2.

## But
Ce document décrit le modèle logique consolidé pour Herbivorie après les
modifications J2 : hiérarchie de localisation, mesures quantitatives, et
amélioration de l'identification des plants.

## Schéma principal (résumé)
- Log_Operation(log_id PK)

## Règles et décisions
- La hiérarchie Site→Zone→Placette→Parcelle permet une localisation absolue et
  réutilisable des plants (exigence J2).
- Parcelle est matérialisée comme table (et non plus comme simple domaine) pour
  faciliter la gestion, l'historique et les métadonnées.
- Remplacement progressif de Taux (catégoriel) par Mesure (quantitatif). La
  migration des données Taux→Mesure doit être manuelle/contrôlée. Pour les
  nouvelles insertions on introduit la colonne `taux_pct` (valeur entière
  0..100) dans `Placette_Couvert` et `Placette_Obstruction`. La table `Taux`
  la saisie de nouvelles valeurs.

## Migration recommandée (pas automatique)
4. Une fois validée, ajouter la contrainte FK sur Plant.parcelle_id.
## Schéma principal détaillé (J2) — description complète
Ci-dessous le schéma principal tel qu'il doit être dans la version finale J2.

1) Site
 - site_id : TEXT PK
 - nom : TEXT NOT NULL
 - description : TEXT
 But : identifie une zone d'étude ou terrain. Permet d'agréger plusieurs zones.

2) Zone
 - zone_id : TEXT PK
 - site_id : TEXT NOT NULL REFERENCES Site(site_id) ON DELETE RESTRICT
 - nom : TEXT NOT NULL
 - description : TEXT
 But : subdivision logique d'un site (ex: secteur, transect).

3) Parcelle
 - parcelle_id : SERIAL PK
 - site_id : TEXT NOT NULL REFERENCES Site(site_id)
 - zone_id : TEXT NOT NULL REFERENCES Zone(zone_id)
 - code : TEXT NOT NULL (code local ex: '01')
 - description : TEXT
 - UNIQUE(site_id, zone_id, code)
 But : emplacement réutilisable pour l'identification relative des plants.

4) Placette_core
 - plac : Placette_id PK (ex: 'A1')
 - peup : Peuplement_id NOT NULL REFERENCES Peuplement(peup)
 - date : Date_eco NOT NULL
 - site_id : TEXT NULL REFERENCES Site(site_id)
 - zone_id : TEXT NULL REFERENCES Zone(zone_id)
 But : description temporelle et fonctionnelle d'une placette.

5) Placette_Obstruction
 - plac : Placette_id PK/FK -> Placette_core(plac)
 - nature : obstruction_nature (ENUM)
 - hauteur : hauteur_obs (ENUM)
 - tcat : Taux_id (OPTIONNEL, rétrocompatibilité)
 - taux_pct : INTEGER CHECK (0..100) (NOUVEAU, J2)
 - PK (plac, nature, hauteur)
 But : enregistrer l'obstruction latérale; `taux_pct` doit être utilisé pour
       de nouvelles données (quantitatif). `tcat` conservé uniquement si
       nécessaire pour anciennes données.

6) Placette_Couvert
 - plac : Placette_id PK/FK -> Placette_core(plac)
 - ctype : couvert_type (ENUM)
 - tcat  : Taux_id (OPTIONNEL, rétrocompatibilité)
 - taux_pct : INTEGER CHECK (0..100) (NOUVEAU, J2)
 - PK (plac, ctype)
 But : couverture au sol ; `taux_pct` en pourcentage est la valeur canonique J2.

7) Plant
 - id : Plant_id PK (ex : 'MMB0001')
 - global_id : TEXT UNIQUE (NOUVEAU, J2) — identifiant absolu (UUID/tag)
 - placette : Placette_id NOT NULL REFERENCES Placette_core(plac)
 - parcelle : Parcelle (numéro local) — migration vers Parcelle.parcelle_id
 - date : Date_eco NOT NULL (date d'identification)
 - note : Description (nullable après ALTER)
 But : `id` identifie l'individu dans la convention existante ; `global_id`
       permet une identification indépendante de l'emplacement — utile pour
       suivi inter-années et import d'étiquettes physiques.

8) ObsFloraison, ObsEtat, ObsDimension
 - id, date : PK composite (id réfère à Plant.id)
 - Attributs spécifiques (fleur boolean, etat, longueur, largeur, note)
 But : observations temporelles liées à un plant identifié.

9) Taux (historique)
 - tCat : Taux_id PK
 - tMin, tMax : Taux_val (0..100)
 But : répertoire discret historique. Pour J2, privilégier `taux_pct` dans
       les tables de placette ; Taux conservé pour interprétation/archivage.

10) TypeMesure / UniteMesure / Mesure (J2)
 - TypeMesure(typemesure_id PK, libelle, description)
 - UniteMesure(unite_id PK, libelle)
 - Mesure(mesure_id PK, typemesure_id FK, unite_id FK, valeur NUMERIC, date_obs, source)
 But : stocker toutes les mesures quantitatives (météo, taux de couverture,
       hauteurs, etc.) de façon normalisée et extensible.

Notes de conception et contraintes
- Favoriser `taux_pct` pour toute nouvelle saisie sur placette. `tcat` reste
  pour permettre de lire et interpréter les anciens jeux de données.
- Migrer les anciennes valeurs Taux → Mesure / taux_pct via script contrôlé
  (ex : moyenne de tMin/tMax ou politique définie par l'équipe).
- Sauvegarde obligatoire (dump) avant toute opération destructive (ALTER DROP).

Cette description sera synchronisée avec `Herbivorie_P2_M2.sql` et le
journal `Herbivorie_P2_LOG_J2.md` lors de l'exécution des migrations.
5. Pour Taux → Mesure : exporter les valeurs Taux et insérer des Mesure avec
   typemesure_id approprié (ex: 'taux_couverture').

## Documentation SQL
- Chaque table importante doit être documentée avec `COMMENT ON TABLE` et
  `COMMENT ON COLUMN` (fichier `Herbivorie_P2_M2.sql` contient des exemples).

## Fichiers produits
- Herbivorie_P2_M2.sql : DDL consolidé (création + alter + IMM example)
- Herbivorie_P2_MODELE_J2.md : ce fichier
- Herbivorie_P2_LOG_J2.md : journal des actions (créé séparément)
- Herbivorie_P2_C2.md : optimisations (à compléter)


