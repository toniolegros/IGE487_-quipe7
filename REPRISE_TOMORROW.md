REPRISE_TOMORROW.md
===================

Objectif
--------
Fournir un résumé clair et actionnable pour reprendre le travail demain sur la branche `Antoine`.

Où en est-on
--------------
- Base siégée dans Docker : conteneur `pg-herbivorie`, base `herbivorie_dev`, utilisateur `herbivorie`.
- Import CSV et normalisation : `staging.megantic` (brut) -> `staging.megantic_normalized` (4 574 lignes).
- Mapping vers production (Herbivorie) : exécuté via `scripts/03_push_to_herbivorie.sql`.
- Parcelle : consolidation effectuée, table canonique `Herbivorie.parcelle` (créée en renommant `parcelle_ref`), FK `plant_parcelle_fk` ajoutée NOT VALID.
- Sauvegardes : `backup_herbivorie_autosave_2025-11-09.dump` et `backup_before_parcelle_rename_2025-11-09.dump` (copies locales).

Fichiers clés (à connaître)
---------------------------
- `scripts/run_import_megantic.ps1` : helper PowerShell pour copier le CSV dans le conteneur et lancer `import_megantic.sql`.
- `scripts/import_megantic.sql` : définit `staging.megantic` et explique la commande COPY côté serveur.
- `scripts/02_migrate_megantic.sql` : normalise les champs et crée `staging.megantic_normalized`.
- `scripts/03_push_to_herbivorie.sql` : mapping idempotent depuis `staging.megantic_normalized` vers `Herbivorie` (sites, zones, parcelles, placette_core, plant, obsdimension, obsfloraison).
- `scripts/04_finalise_parcelle.sql` : consolidation initiale des parcelles (création de `parcelle_ref` puis copie depuis autres schémas).
- `scripts/05_rename_parcelle_sql.sql` : renommage final effectué (domain renommé, `parcelle_ref` -> `parcelle`, ajout de FK NOT VALID).
- `Herbivorie_P2_M2.sql` : DDL consolidé (Site/Zone/Parcelle/TypeMesure/UniteMesure/Mesure/Log_Operation) — nettoyé pour psql.
- `COMMIT_DETAILS.md` : description exhaustive des actions effectuées aujourd'hui.
- `Herbivorie_P2_LOG_J2.md` : journal d'exécution et diagnostics.

Exactement ce que tu peux lancer demain (ordre recommandé)
----------------------------------------------------
1) Vérifier l'état du conteneur et de la DB
   - docker ps
   - docker exec -it pg-herbivorie psql -U herbivorie -d herbivorie_dev -c "SELECT version();"

2) Si nécessaire, ré-importer le CSV brute et normaliser
   - PowerShell (depuis la racine du repo) :
     ```powershell
     .\scripts\run_import_megantic.ps1 -CsvPath "TS/J2/Donnees_supplementaires/Herbivorie_Megantic_v04-2017-09-16_mesures.csv" -Container pg-herbivorie
     ```
   - Puis (si besoin) :
     ```powershell
     docker exec -i pg-herbivorie psql -U herbivorie -d herbivorie_dev -f /tmp/02_migrate_megantic.sql
     ```

3) Relancer le mapping idempotent (si besoin)
   ```powershell
   docker cp scripts/03_push_to_herbivorie.sql pg-herbivorie:/tmp/03_push_to_herbivorie.sql
   docker exec -i pg-herbivorie psql -U herbivorie -d herbivorie_dev -f /tmp/03_push_to_herbivorie.sql
   ```

4) Vérifier les comptes et échantillons
   - SELECT count(*) FROM site; SELECT count(*) FROM zone; SELECT count(*) FROM parcelle; SELECT count(*) FROM placette_core; SELECT count(*) FROM plant; SELECT count(*) FROM obsdimension; SELECT count(*) FROM obsfloraison;
   - SELECT * FROM staging.megantic_normalized LIMIT 10;

5) Optionnel (validation FK)
   - Si tu veux valider FK :
     - Faire un backup (nouveau) puis
     - ALTER TABLE "Herbivorie".plant VALIDATE CONSTRAINT plant_parcelle_fk;
     - Si validation échoue, exécuter :
       ```sql
       SELECT p.id, p.parcelle_id FROM "Herbivorie".plant p LEFT JOIN "Herbivorie".parcelle pa ON p.parcelle_id = pa.parcelle_id WHERE pa.parcelle_id IS NULL;
       ```
       pour lister les plants qui n'ont pas de parcelle correspondante.

Notes et choses à garder en tête
--------------------------------
- Les scripts fournis sont non-destructifs (ON CONFLICT DO NOTHING / DO UPDATE). Le nettoyage final (suppression des tables staging, suppression/renommage du domain historique `parcelle` si on le souhaite) doit être réalisé après validation métier.
- Les dumps de sauvegarde ne sont pas ajoutés au repo (sauf copies locales), ils sont disponibles à la racine du workspace.

Bonne reprise — ouvre `COMMIT_DETAILS.md` puis suis l'ordre ci-dessus.
