Commit title
------------
J2: import/normalisation & mapping pipeline — ajout des scripts d'import, normalisation, mapping et finalisation Parcelle

Commit body (résumé des actions réalisées le 2025-11-09)
-----------------------------------------------------------------
Ce commit rassemble le travail de migration et de préparation J2 effectué aujourd'hui :

1) Fusion / nettoyage DDL
   - Fichier modifié : `Herbivorie_P2_M2.sql`
     - Nettoyage des marqueurs Markdown pour exécution par `psql`.
     - Ajout non-destructif (CREATE/ALTER) des entités J2 : `Site`, `Zone`, `Parcelle` (concept), `TypeMesure`, `UniteMesure`, `Mesure`, `Log_Operation`.

2) Pipeline d'import et normalisation (staging)
   - Ajouté : `scripts/import_megantic.sql` (création de `staging.megantic` et exemple de COPY).  
   - Ajouté : `scripts/run_import_megantic.ps1` (PowerShell helper pour copier le CSV dans le conteneur et lancer les scripts).  
   - Ajouté : `scripts/02_migrate_megantic.sql` (normalise les données CSV en `staging.megantic_normalized`, nettoie les dates et conversions numériques).  
   - Résultat vérifié : `staging.megantic_normalized` contient 4 574 lignes après normalisation du CSV `TS/J2/Donnees_supplementaires/Herbivorie_Megantic_v04-2017-09-16_mesures.csv`.

3) Mapping idempotent vers Herbivorie (non-destructif)
   - Ajouté : `scripts/03_push_to_herbivorie.sql` — script idempotent qui :
     - Insère `site` / `zone` / `parcelle` (ou leur équivalent) depuis `staging.megantic_normalized`.
     - Insère `placette_core` (avec un `peuplement` par défaut `I0001`).
     - Insère/actualise `plant` (utilise `global_id` quand il respecte le domaine ; génère un identifiant synthétique sinon).
     - Insère les observations dans `ObsDimension` et `ObsFloraison` en évitant les doublons.
   - Exécution : le script a inséré/actualisé 2 120 plants, 4 095 enregistrements `ObsDimension` et 2 066 `ObsFloraison`.

4) Finalisation Parcelle (option A demandée et exécutée)
   - Ajouté : `scripts/04_finalise_parcelle.sql` — consolide toutes les définitions `parcelle` présentes dans d'autres schémas vers un objet de référence.
   - Contrainte constatée : il existe un `DOMAIN` nommé `parcelle` dans le schéma `Herbivorie` (créé antérieurement par `Herbivorie_cre.sql`), ce qui empêche la création d'une table nommée `parcelle` dans le même schéma (nom en conflit avec le type). Pour éviter de modifier/retirer ce domain (opération risquée), le script crée une table de référence nommée `parcelle_ref` dans le schéma `Herbivorie` et y copie toutes les lignes distinctes provenant d'autres schémas (`staging.parcelle` etc.).
   - Mise à jour : `plant.parcelle_id` a été réconcilié pour 2 116 plants en joignant `parcelle_ref` sur `site/zone/code`.
   - Vérifications post-exécution : `site`=3, `zone`=9, `parcelle_ref`=108, `placette_core`=9, `plant`=2120, `obsdimension`=4095, `obsfloraison`=2066.

5) Sauvegardes et précautions
   - Avant toute modification destructive j'ai pris un dump : `backup_herbivorie_autosave_2025-11-09.dump` (copié à la racine du dépôt).
   - Tous les scripts sont idempotents et non-destructifs (INSERT ... ON CONFLICT DO NOTHING / DO UPDATE) ; j'ai volontairement évité tout DROP/ALTER destructif.

6) Documentation & journal
   - Mis à jour : `Herbivorie_P2_LOG_J2.md` — journal détaillé des actions et des diagnostics.

Fichiers ajoutés/modifiés (liste)
 - scripts/02_migrate_megantic.sql (ajout)
 - scripts/03_push_to_herbivorie.sql (ajout)
 - scripts/04_finalise_parcelle.sql (ajout)
 - scripts/import_megantic.sql (ajout)
 - scripts/run_import_megantic.ps1 (ajout/ajustements)
 - Herbivorie_P2_M2.sql (modifié/cleaned)
 - Herbivorie_P2_LOG_J2.md (modifié)
 - backup_herbivorie_autosave_2025-11-09.dump (généré localement)

Commandes recommandées pour committer/pusher (local)
--------------------------------------------------
git add scripts/* Herbivorie_P2_M2.sql Herbivorie_P2_LOG_J2.md COMMIT_DETAILS.md
git commit -m "J2: import/normalize/mapping pipeline + parcelle consolidation (non-destructive)"
git push origin Antoine

Remarques / actions ultérieures recommandées
 - Décider si l'on renomme ou supprime le DOMAIN `parcelle` dans `Herbivorie` pour permettre de créer une table `parcelle` classique (opération risquée et potentiellement casseuse). Si OK, remplacer `parcelle_ref` par `parcelle` et ajouter les contraintes FK strictes.
 - Ajouter des tests SQL (comparaison ligne-à-ligne CSV → staging → Herbivorie) pour certifier la migration.
 - Après validation, envisager nettoyage / suppression des objets temporaires (staging.parcelle, tables non-qualifiées) et retrait des colonnes historiques si souhaité.

---
Fin du message de commit détaillé.

---

Détails demandés (par sections)

1) Hiérarchisation des lieux — fichiers, tables et extraits de code

- Fichier principal : `Herbivorie_P2_M2.sql`
   - J2 introduit la hiérarchie Site -> Zone -> Parcelle. Extraits exacts :
      - CREATE TABLE Site (site_id TEXT PRIMARY KEY, nom TEXT NOT NULL, description TEXT);
      - CREATE TABLE Zone (zone_id TEXT PRIMARY KEY, site_id TEXT NOT NULL REFERENCES Site(site_id) ON DELETE RESTRICT, nom TEXT NOT NULL, description TEXT);
      - CREATE TABLE Parcelle (parcelle_id SERIAL PRIMARY KEY, site_id TEXT NOT NULL REFERENCES Site(site_id) ON DELETE RESTRICT, zone_id TEXT NOT NULL REFERENCES Zone(zone_id) ON DELETE RESTRICT, code TEXT NOT NULL, description TEXT, UNIQUE (site_id, zone_id, code));
   - Intégration au schéma existant (même fichier) :
      - ALTER TABLE IF EXISTS Placette_core ADD COLUMN IF NOT EXISTS site_id TEXT, ADD COLUMN IF NOT EXISTS zone_id TEXT;
      - ALTER TABLE IF EXISTS Placette_core ADD CONSTRAINT IF NOT EXISTS placette_core_site_fk FOREIGN KEY (site_id) REFERENCES Site(site_id) ON DELETE RESTRICT;
      - ALTER TABLE IF EXISTS Placette_core ADD CONSTRAINT IF NOT EXISTS placette_core_zone_fk FOREIGN KEY (zone_id) REFERENCES Zone(zone_id) ON DELETE RESTRICT;
      - ALTER TABLE IF EXISTS Plant ADD COLUMN IF NOT EXISTS parcelle_id INTEGER; (prépare la liaison Plant -> Parcelle)

- Fichier utilisé/étendu pendant la migration : `scripts/03_push_to_herbivorie.sql`
   - Ce script crée (si besoin) des lignes `site` / `zone` / `parcelle` à partir des valeurs de la colonne `placette` et `parcelle_code` dans `staging.megantic_normalized`.
   - Extrait clé :
      - INSERT INTO site (site_id, nom) SELECT DISTINCT regexp_replace(placette,'[0-9]','','g') AS site_id, regexp_replace(placette,'[0-9]','','g') AS nom FROM staging.megantic_normalized ... ON CONFLICT DO NOTHING;
      - INSERT INTO zone (zone_id, site_id, nom) SELECT DISTINCT placette AS zone_id, regexp_replace(placette,'[0-9]','','g') AS site_id, placette AS nom ...;
      - INSERT INTO parcelle (site_id, zone_id, code, description) SELECT DISTINCT regexp_replace(placette,'[0-9]','','g') AS site_id, placette AS zone_id, parcelle_code AS code, format('Import: placette=%s', placette) ...;

2) Passage de la catégorisation `Taux` -> quantitatif (fichiers, tables, extraits)

- Fichiers principaux : `Herbivorie_cre.sql` (historique) et `Herbivorie_P2_M2.sql` (consolidation J2)
   - Dans `Herbivorie_cre.sql` (ancien DDL) la structure des placettes incluait des colonnes `obs_F1/obs_F2/...` référencées vers la table `Taux` et les types/dispositifs catégoriels.
   - Dans `Herbivorie_P2_M2.sql` j'ai introduit des colonnes quantitatives `taux_pct` sur les tables de placette dérivées pour accueillir des pourcentages 0..100. Extraits :
      - CREATE TYPE obstruction_nature AS ENUM ('feuillu','coniferien','total');
      - CREATE TABLE Placette_Obstruction (... tcat Taux_id, taux_pct INTEGER, CONSTRAINT chk_placette_obstruction_taux_pct CHECK (taux_pct BETWEEN 0 AND 100));
      - CREATE TABLE Placette_Couvert (... tcat Taux_id, taux_pct INTEGER, CONSTRAINT chk_placette_couvert_taux_pct CHECK (taux_pct BETWEEN 0 AND 100));
   - Note : la table `Taux` est conservée pour compatibilité historique, mais la colonne `taux_pct` permet désormais d'enregistrer une valeur numérique précise (0–100) pour les nouvelles données (J2). Le script `Herbivorie_P2_M2.sql` propose aussi les ALTER TABLE d'exemple :
      - -- ALTER TABLE Placette_Couvert ADD COLUMN IF NOT EXISTS taux_pct INTEGER CHECK (taux_pct BETWEEN 0 AND 100);
      - -- ALTER TABLE Placette_Obstruction ADD COLUMN IF NOT EXISTS taux_pct INTEGER CHECK (taux_pct BETWEEN 0 AND 100);

3) Import du CSV, staging area et comment continuer (fichiers, tables, extraits et prochaines étapes)

- Fichiers liés à l'import :
   - `scripts/import_megantic.sql` : crée `staging.megantic` (colonnes brutes) et contient l'exemple COPY côté serveur.
      - Extrait :
         - CREATE TABLE IF NOT EXISTS staging.megantic (id TEXT, placette TEXT, longueur INTEGER, largeur INTEGER, fleur TEXT, sous_parcelle TEXT, date_obs TEXT, JJ INTEGER, etat TEXT, note TEXT);
         - COPY staging.megantic FROM '/tmp/megantic_mesures.csv' DELIMITER ';' CSV HEADER NULL 'NA';

   - `scripts/02_migrate_megantic.sql` : normalise les valeurs brutes en créant `staging.megantic_normalized`.
      - Extraits de normalisation clefs :
         - CREATE TABLE IF NOT EXISTS staging.megantic_normalized (global_id TEXT, placette TEXT, parcelle_code TEXT, longueur INTEGER, largeur INTEGER, fleur BOOLEAN, date_obs DATE, JJ INTEGER, etat TEXT, note TEXT);
         - INSERT INTO staging.megantic_normalized (...) SELECT id, placette, NULLIF(sous_parcelle,'') AS parcelle_code, CASE WHEN longueur ~ '^[0-9]+$' THEN CAST(longueur AS INTEGER) ELSE NULL END, CASE WHEN largeur ~ '^[0-9]+$' THEN CAST(largeur AS INTEGER) ELSE NULL END, CASE WHEN lower(fleur) IN ('1','true','t','y') THEN true WHEN lower(fleur) IN ('0','false','f','n') THEN false ELSE NULL END, CASE WHEN date_obs ~ '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$' THEN CAST(date_obs AS DATE) ELSE NULL END, JJ, etat, note FROM staging.megantic;
      - Résultat constaté dans notre exécution : `staging.megantic_normalized` = 4 574 lignes.

   - `scripts/03_push_to_herbivorie.sql` : script idempotent qui prend `staging.megantic_normalized` et :
      - crée `site` / `zone` / `parcelle` (ou utilise les existants) ;
      - crée `placette_core` (utilise un `peuplement` par défaut `I0001` créé si nécessaire) ;
      - insère / met à jour `plant` (utilise `global_id` quand il respecte le domaine, sinon génère un id synthétique via séquence `mig_plant_seq`) ;
      - insère `ObsDimension` et `ObsFloraison` sans dupliquer (NOT EXISTS checks) ;
      - Extraits notables :
         - INSERT INTO site ... SELECT DISTINCT regexp_replace(placette,'[0-9]','','g') ...;
         - INSERT INTO parcelle (site_id, zone_id, code, description) SELECT DISTINCT regexp_replace(placette,'[0-9]','','g') AS site_id, placette AS zone_id, parcelle_code AS code ...;
         - INSERT INTO plant (id, global_id, ...) SELECT m.global_id ... WHERE m.global_id ~ '^MM[A-C][0-9]{4}$' ON CONFLICT (id) DO UPDATE ...; and fallback generation for invalid ids.

- Staging area — principe et état actuel
   - Principe : ne pas écrire directement dans les tables de production. Importer le CSV cru dans `staging.megantic` ; normaliser et nettoyer dans `staging.megantic_normalized` ; examiner et valider ; puis pousser vers le schéma `Herbivorie` via un script idempotent (`scripts/03_push_to_herbivorie.sql`).
   - État actuel après exécution : `staging.megantic_normalized` contient 4 574 lignes normalisées prêtes au mapping ; la plupart des insertions de production (sites/zones/placettes/plants/obs) ont été réalisées à partir de ce staging.

- Ce qui reste à faire (ordre recommandé)
   1. Valider les règles métier sur l'association placette→parcelle (notamment quand `parcelle_code` est vide ou non numérique). Corriger les mappages si besoin.
   2. Compléter l'alimentation de la table `Mesure` pour toutes les mesures quantitatives (typer les mesures : `typemesure_id`, `unite_id`, p.ex. `taux_couverture` / `pct`). Ce travail n'est pas automatisé dans `03_push_to_herbivorie.sql` actuellement.
   3. Ajouter des tests SQL (échantillons, checksums, counts par groupe) pour comparer lignes CSV → staging → Herbivorie afin de garantir l'absence de régressions.
   4. Après approbation métier, remplacer les colonnes historiques (tcat / Taux) ou les migrer vers `Mesure`, puis supprimer/archiver les objets temporaires (staging, parcelle_ref si renommée) et valider les contraintes (VALIDATE CONSTRAINT pour FK ajoutées).

---

Si tu veux je peux maintenant : (i) ajouter la contrainte FK VALIDATE (vérifier et nettoyer les cas qui empêchent la validation), (ii) préparer le commit et le push, ou (iii) produire un petit script de tests SQL / rapport de validation. Dis laquelle des trois actions tu veux que je fasse ensuite.
