# Herbivorie_P2_LOG_J2.md
# Herbivorie_P2_LOG_J2.md
Projet : Herbivorie – IGE487
Jalon : J2 – Normalisation, optimisation et documentation
Auteur(s) : [IA-assistant], [À renseigner]
Date : 2025-11-09
Objectif : Journal chronologique de toutes les actions réalisées pour J2.

## Entrées
- 2025-11-09 — Herbivorie_P2_M2.sql — Création du script initial J2
  - Action : Ajout des entités Site, Zone, Parcelle, TypeMesure, UniteMesure, Mesure, Log_Operation
  - Fichier modifié/créé : Herbivorie_P2_M2.sql
  - Justification : J2 — Hiérarchie de localisation & mesures quantitatives (référence: demande J2)
  - Notes : Ajouts non destructifs (ALTER TABLE avec ADD COLUMN IF NOT EXISTS). Migration des données Taux->Mesure laissée manuelle.

- 2025-11-09 — Mise à jour schémas `Herbivorie_cre.sql` et `view.sql`
  - Action : Introduction de la hiérarchie Site/Zone/Parcelle dans `Herbivorie_cre.sql` ; ajout des colonnes quantitatives `taux_pct` sur `Placette_Obstruction` et `Placette_Couvert` ; ajout de `global_id` (identifiant absolu) sur `Plant`.
  - Fichiers modifiés : `TS/J2/Etapes_anterieures/src/Herbivorie_cre.sql`, `TS/J2/Etapes_anterieures/src/view.sql`
  - Justification : J2 — remplacement progressif du modèle catégoriel Taux par des mesures quantitatives, et introduction d'une identification absolue des plants et d'une hiérarchie de localisation (Site/Zone/Parcelle).
  - Notes : Les colonnes historiques `tcat` et la table `Taux` sont conservées pour compatibilité, mais `taux_pct` doit être utilisée pour les nouvelles insertions. Migration et nettoyage ultérieurs recommandés.

- 2025-11-09 — Sauvegarde avant migration
  - Action : Dump complet de la base `herbivorie_dev` depuis le conteneur `pg-herbivorie` (format compressé/pg_dump custom)
  - Commande : `docker exec -i pg-herbivorie pg_dump -U herbivorie -d herbivorie_dev -Fc -f /tmp/backup_herbivorie_dev.dump` puis `docker cp pg-herbivorie:/tmp/backup_herbivorie_dev.dump .`
  - Fichier généré : `backup_herbivorie_dev.dump` (copié à la racine du repo)
  - Justification : Sauvegarde nécessaire avant exécution des scripts DDL et migration des données.
  - Notes : Backup réalisé avec succès.

## 2025-11-09 — Diagnostic et problèmes rencontrés lors de l'exécution des scripts

### Observations générales
- J'ai tenté d'exécuter les scripts DDL et le script de migration depuis l'hôte en utilisant `run_sql_all.ps1` en mode `docker`.
- Le conteneur détecté : `pg-herbivrie` (Postgres 15). Variables d'environnement observées :
  - `POSTGRES_USER=herbivorie`
  - `POSTGRES_DB=herbivorie_dev`
  - `POSTGRES_PASSWORD=herbivorie`

### Problèmes et erreurs rencontrés
1) Quoting / invocation psql depuis PowerShell
  - Plusieurs tentatives d'exécution avec `docker exec ... psql -c "..."` ont produit des erreurs liées au quoting (PowerShell et bash imbriqués). J'ai contourné cela en copiant des fichiers SQL dans le conteneur et en exécutant `psql -f /tmp/<file>` (méthode robuste).

2) `run_sql_all.ps1` : Docker copy problématique sur Windows
  - Première exécution renvoyait "must specify at least one container source" suite à l'échappement des chemins Windows. J'ai mis à jour `run_sql_all.ps1` pour utiliser `Resolve-Path` et corriger l'appel `docker cp`.

3) Erreurs SQL non bloquantes pendant l'exécution des scripts DDL
  - Erreurs du type "type \"parcelle\" already exists" sont normales si on ré-exécute des CREATE non conditionnels.
  - `Herbivorie_P2_M2.sql` contenait des marqueurs Markdown (```), j'ai nettoyé le fichier pour qu'il soit exécutable par psql.

4) Migration initiale Taux→taux_pct a retourné 0 lignes
  - La cause: les tables source étaient vides dans l'instance `herbivorie_dev`. J'ai alors importé un jeu de données CSV (voir ci-dessous) pour pouvoir tester la migration.

### Résultats du diagnostic (avant import CSV)
- `Taux count` = 0
- `Placette_Obstruction tcat count` = 0
- `Placette_Obstruction taux_pct count` = 0
- `Placette_Couvert tcat count` = 0
- `Placette_Couvert taux_pct count` = 0
- `Mesure total count` = 0

## 2025-11-09 — Import et normalisation d'un jeu de données d'exemple

- Fichier importé : `TS/J2/Donnees_supplementaires/Herbivorie_Megantic_v04-2017-09-16_mesures.csv`
- Actions réalisées :
  1. Copie du CSV dans le conteneur `pg-herbivorie` (chemin /tmp/megantic_mesures.csv)
  2. Création de `staging.megantic` (colonnes initiales), puis ajustement des colonnes `longueur`/`largeur` en TEXT pour tolérer valeurs non numériques ('NA','NS',...)
  3. Exécution de la commande serveur : COPY staging.megantic FROM '/tmp/megantic_mesures.csv' DELIMITER ';' CSV HEADER NULL 'NA';
  4. Exécution du script `scripts/02_migrate_megantic.sql` qui a produit la table `staging.megantic_normalized` (4574 lignes).

- Vérifications effectuées :
  - `COPY` a inséré 4574 lignes dans `staging.megantic`.
  - `staging.megantic_normalized` contient 4574 lignes après normalisation.
  - Extrait (5 premières lignes) :

```
global_id | placette | parcelle_code | longueur | largeur | fleur | date_obs  | jj  | etat | note
MMA1001   | A1       | 1             | 70       | 72      | t     | 2017-05-08 | 128 |      |
MMA1002   | A1       | 1             | 56       | 49      | t     | 2017-05-08 | 128 |      |
MMA1003   | A1       | 1             | 50       | 41      | t     | 2017-05-08 | 128 |      |
MMA1004   | A1       | 1             | 56       | 56      | t     | 2017-05-08 | 128 |      |
MMA1005   | A1       | 1             | 56       | 57      | t     | 2017-05-08 | 128 |      |
```

## Recommandations et prochaines étapes (pour les coéquipiers)
1) Valider les règles de mapping final vers les tables Herbivorie (Plant, Placette_core, Mesure).
   - Exemple: créer `Site`/`Zone`/`Parcelle` depuis les colonnes `placette`/`sous_parcelle` si nécessaire.
   - Décider si `global_id` doit reprendre `id` du CSV ou être remplacé par un UUID.

2) Écrire des scripts `scripts/03_push_to_herbivorie.sql` qui :
   - insèrent les `Site`/`Zone`/`Parcelle` manquants,
   - créent/associent les `Plant` (avec `global_id`),
   - insèrent les mesures dans `Mesure` (typemesure_id='taux_couverture', unite_id='pct', valeur=calcul si nécessaire).

3) Ajouter quelques tests SQL (SELECT comparatif) pour vérifier le mapping ligne-à-ligne avant suppression des tables historiques.

4) Après validation, committer et pousser les scripts et la documentation. Le script `scripts/run_import_megantic.ps1` facilite la réplication de l'import sur l'environnement des coéquipiers.

Fin du log.
## Résultats de mapping et résumé de vérification

### Résultats chiffrés (exécution du 2025-11-09)
- Sites insérés : 3
- Zones insérées : 9
- Placettes (placette_core) : 9
- Plants insérés / mis à jour : 2 120
- Observations de dimension (ObsDimension) : 4 095
- Observations de floraison (ObsFloraison) : 2 066

Remarques importantes :
- Le script de mapping a créé provisoirement une table `parcelle` dans le schéma `staging` (cela provient d'un CREATE non qualifié dans le script initial). Pour un état final propre, il est recommandé d'exécuter le DDL consolidé (`Herbivorie_P2_M2.sql`) dans le schéma `Herbivorie` afin de créer/normaliser définitivement la table `parcelle` au bon emplacement, puis de réconcilier les identifiants.

### Commandes pour reproduire (local)
1) Import + normalisation (déjà fournis) :
   - Exécuter `scripts/run_import_megantic.ps1 -CsvPath <path-to-csv> -Container pg-herbivorie` (ou copier le CSV et lancer `psql -f scripts/import_megantic.sql` puis `psql -f scripts/02_migrate_megantic.sql` dans le conteneur).
2) Push (mapping idempotent) :
   - Copier `scripts/03_push_to_herbivorie.sql` dans le conteneur et exécuter :
     `docker exec -i pg-herbivorie psql -U herbivorie -d herbivorie_dev -f /tmp/03_push_to_herbivorie.sql`

### Validation effectuée
- J'ai exécuté les requêtes de vérification suivantes après le mapping :
  - `SELECT count(*) FROM site;`
  - `SELECT count(*) FROM zone;`
  - `SELECT count(*) FROM placette_core;`
  - `SELECT count(*) FROM plant;`
  - `SELECT count(*) FROM obsdimension;`
  - `SELECT count(*) FROM obsfloraison;`

---



