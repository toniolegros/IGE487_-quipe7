# Herbivorie_P2_C2.md
Projet : Herbivorie – IGE487
Jalon : J2 – Optimisations et indexation
Auteur(s) : [À renseigner]
Date : 2025-11-09
Objectif : Documenter les index proposés, requêtes critiques et résultats EXPLAIN.

## Proposition initiale d'index
- CarnetMeteo(date) et CarnetMeteo(date, prec_nat) pour accélérer recherches par date et type de précipitation.
- ObsFloraison(id, date) : index composite pour accélérer historique d'un plant.
- Plant(placette) : index sur clé étrangère pour jointures fréquentes.

## Exemple (à exécuter après tests):
-- CREATE INDEX idx_carnetmeteo_date ON CarnetMeteo(date);
-- CREATE INDEX idx_obsfloraison_id_date ON ObsFloraison(id, date);
-- CREATE INDEX idx_plant_placette ON Plant(placette);

Mesures de performance et EXPLAIN ANALYZE seront documentées après exécution sur un jeu de données représentatif.

