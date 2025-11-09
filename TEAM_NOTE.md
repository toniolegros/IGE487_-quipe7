TEAM_NOTE.md
============

Courte note à lire aux coéquipiers pour expliquer l'état du dépôt et comment reprendre :

Bonjour équipe,

Je livre aujourd'hui une série de scripts et de documents sur la branche `Antoine` qui permettent de reprendre la migration J2 de manière reproductible.

Ce que vous trouverez dans la PR / branche :
- Scripts d'import et de normalisation (staging) : `scripts/import_megantic.sql`, `scripts/02_migrate_megantic.sql`.
- Helper d'exécution local : `scripts/run_import_megantic.ps1` (PowerShell) et `run_sql_all.ps1`.
- Script de mapping idempotent vers le schéma `Herbivorie`: `scripts/03_push_to_herbivorie.sql`.
- Scripts de finalisation Parcelle et renommage : `scripts/04_finalise_parcelle.sql`, `scripts/05_rename_parcelle_sql.sql`.
- DDL consolidé J2 : `Herbivorie_P2_M2.sql`.
- Journal et détails opérationnels : `Herbivorie_P2_LOG_J2.md`, `COMMIT_DETAILS.md`.
- Fichier de reprise pour demain : `REPRISE_TOMORROW.md`.

Point important à connaître
- Les imports ont été faits en staging et le mapping exécuté. Une table canonique `Herbivorie.parcelle` existe (issue du renommage de `parcelle_ref`).
- La contrainte FK `plant_parcelle_fk` a été ajoutée mais laissée NOT VALID (à valider si souhaité).
- Les dumps de sauvegarde ont été pris et déposés localement.

Pour reprendre (résumé rapide)
1) Vérifier le conteneur Docker; 2) relancer import via `run_import_megantic.ps1` si besoin; 3) relancer mapping avec `scripts/03_push_to_herbivorie.sql`; 4) vérifier les comptes; 5) (optionnel) valider la contrainte FK après nettoyage.

Si vous voulez que je fasse la validation finale ou que j'écrive les tests SQL d'assurance qualité, dites-le et je m'en occupe.

Merci,
[Ton résumé automatique]
