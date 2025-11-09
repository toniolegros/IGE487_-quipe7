# J2 Migration README — Herbivorie

But: rendre le travail reproductible et simple pour les coéquipiers — importer le jeu de données CSV fourni, normaliser un échantillon et documenter la marche à suivre pour exécuter la migration complète.

Fichiers ajoutés:
- `scripts/import_megantic.sql` : crée `staging.megantic` et contient la commande COPY à exécuter côté serveur.
- `scripts/run_import_megantic.ps1` : script PowerShell pour copier le CSV dans le conteneur `pg-herbivorie` et lancer l'import.
- `scripts/02_migrate_megantic.sql` : script de transformation sécurisé (staging -> staging.megantic_normalized) qui sert de point de départ pour produire des inserts vers le schéma Herbivorie.

Pré-requis:
- Conteneur PostgreSQL en marche (nom attendu : `pg-herbivorie`).
- Le CSV source est `TS/J2/Donnees_supplementaires/Herbivorie_Megantic_v04-2017-09-16_mesures.csv`.
- Utilisateur/DB : `herbivorie` / `herbivorie_dev` (convention du conteneur actuel).

Étapes rapides (automatique depuis Windows PowerShell dans la racine du repo):

1) Copier et importer le CSV dans la DB (le script va copier le CSV dans /tmp du conteneur et exécuter l'import)

```powershell
.
\scripts\run_import_megantic.ps1 -CsvPath "IGE487_2025-3-main/TS/J2/Donnees_supplementaires/Herbivorie_Megantic_v04-2017-09-16_mesures.csv" -Container pg-herbivorie
```

2) (Optionnel) Contrôles manuels :

```powershell
docker exec -i pg-herbivorie psql -U herbivorie -d herbivorie_dev -c "SELECT count(*) FROM staging.megantic;"
docker exec -i pg-herbivorie psql -U herbivorie -d herbivorie_dev -c "SELECT * FROM staging.megantic LIMIT 5;"
```

3) Normaliser (exécuter le script de transformation)

```powershell
docker cp scripts/02_migrate_megantic.sql pg-herbivorie:/tmp/02_migrate_megantic.sql; docker exec -i pg-herbivorie psql -U herbivorie -d herbivorie_dev -f /tmp/02_migrate_megantic.sql
```

4) Vérifier la table `staging.megantic_normalized` puis écrire des scripts d'insertion vers les tables Herbivorie réelles (Plant, Placette_core, Mesure) en faisant:
   - création éventuelle de `Site`/`Zone`/`Parcelle` si absence
   - génération/assignation d'un `global_id` (si vous voulez garder id d'origine, utiliser `id` ou générer UUID)
   - mapper `longueur`/`largeur` vers la structure de Mesure (ou vers Plant selon votre modèle)

Conseils pour coéquipiers:
- Tester sur une instance locale (ou la copie DB fournie) avant d'exécuter en prod.
- Tous les scripts dans `scripts/` sont idempotents pour la création des schémas/tables; vérifiez les contraintes existantes.
- Si vous modifiez `Herbivorie_P2_M2.sql`, retirez toute annotation Markdown/code fences pour que psql puisse l'exécuter proprement (déjà nettoyé dans le repo).

Prochaines étapes recommandées:
- Ecrire et valider les règles de mapping final vers `Mesure` et `Plant` (scripts dédiés).
- Ajouter tests SQL (SELECT comparatif) pour vérifier ligne à ligne le mapping.
- Après validation : committer et pousser les scripts et la documentation.
