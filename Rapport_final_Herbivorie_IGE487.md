# Rapport final – Normalisation et correction des inadéquations du projet Herbivorie (IGE487)

## Page titre
**Projet** : Herbivorie  
**Cours** : IGE487 – Modélisation de bases de données  
**Session** : Automne 2025  
**Étudiant** : [Votre nom]  
**Date** : 5 octobre 2025

---

## Introduction
Le projet Herbivorie s'inscrit dans le cadre du cours IGE487 – Modélisation de bases de données. Il vise à concevoir et normaliser deux bases de données : Herbivorie et Météo. Ces bases contiennent des données floristiques et météorologiques, respectivement. Le travail de session avait pour objectif de corriger les inadéquations identifiées dans les scripts SQL fournis par le professeur, de normaliser les bases jusqu'à la 3NF (voire BCNF), et de garantir l'intégrité et la cohérence des données.

## Analyse des inadéquations
### Inadéquations Y1 à Y8
1. **Y1 : Gestion des données manquantes dans les tables météo**
   - **Problème** : Les tables météo ne comportaient pas de mécanisme pour gérer les données manquantes, ce qui pouvait entraîner des incohérences dans les analyses climatiques. Par exemple, une température minimale ou maximale absente rendait impossible le calcul des moyennes ou des écarts.
   - **Correction** : Nous avons ajouté des contraintes CHECK pour valider les plages de valeurs (température, humidité, vent, pression). Ces contraintes garantissent que les données insérées respectent des bornes logiques et évitent les valeurs nulles ou aberrantes.

2. **Y2 : Structure incohérente de la table CarnetMeteo**
   - **Problème** : La table CarnetMeteo contenait des colonnes mal définies et des relations non respectées avec les autres tables. Par exemple, les précipitations totales n'étaient pas correctement liées à leur type, et les clés étrangères étaient absentes ou incorrectes.
   - **Correction** : Nous avons révisé les clés étrangères pour établir des relations claires entre CarnetMeteo et les tables ObsTemperature, ObsHumidite, ObsPrecipitations, ObsVents, et ObsPression. De plus, des contraintes ont été ajoutées pour garantir la cohérence des données.

3. **Y3 : Absence de vue pour les conditions météo hors précipitation**
   - **Problème** : Le projet nécessitait une vue permettant d'isoler les conditions météorologiques hors précipitation (température, humidité, vent, pression). Cette vue était essentielle pour les analyses spécifiques.
   - **Correction** : Nous avons créé une vue SQL qui extrait uniquement les données pertinentes, excluant les précipitations. Cela facilite les analyses ciblées et améliore la lisibilité des données.

4. **Y4 : Procédure supprimant les données si Tmin < seuil non fonctionnelle**
   - **Problème** : La procédure censée supprimer les données où la température minimale était inférieure à un seuil donné ne fonctionnait pas correctement. Elle ne prenait pas en compte les dépendances entre les tables.
   - **Correction** : Nous avons réécrit la procédure en intégrant une logique conditionnelle robuste et en respectant les relations entre les tables. Cela garantit que les suppressions sont cohérentes et n'affectent pas les données liées.

5. **Y5 : Procédure augmentant les températures d’un pourcentage donné incorrecte**
   - **Problème** : La procédure d'augmentation des températures contenait des erreurs de calcul, ce qui entraînait des résultats incohérents.
   - **Correction** : Nous avons ajusté les calculs pour appliquer correctement le pourcentage d'augmentation aux températures minimales et maximales. La procédure a été testée avec plusieurs scénarios pour valider son fonctionnement.

6. **Y6 : Assertion de compacité et non-chevauchement des intervalles dans `Taux`**
   - **Problème** : Les intervalles définis dans la table `Taux` se chevauchaient parfois, ce qui créait des ambiguïtés dans les analyses.
   - **Correction** : Nous avons ajouté des contraintes CHECK pour valider que les intervalles sont compacts et ne se chevauchent pas. Cela garantit une interprétation claire des données.

7. **Y7 : Structure incohérente de la table `ObsFloraison`**
   - **Problème** : La table `ObsFloraison` contenait une colonne `fleur` redondante et inutile, et sa clé primaire n'était pas strictement définie.
   - **Correction** : Nous avons retiré la colonne `fleur`, défini une clé primaire stricte, et nettoyé la structure pour améliorer la cohérence.

8. **Y8 : Renommage de la table `peup` → `peuplement**
   - **Problème** : Le nom de la table `peup` était ambigu et ne respectait pas les conventions de nommage. De plus, les dépendances n'étaient pas mises à jour.
   - **Correction** : Nous avons renommé la table en `peuplement` et mis à jour toutes les dépendances et relations pour refléter ce changement.

### Priorisation des inadéquations
Nous avons priorisé les inadéquations en fonction de leur impact sur l'intégrité des données et les besoins du projet. Les corrections liées à la cohérence des données (Y1, Y2, Y6) ont été traitées en premier, suivies des améliorations structurelles (Y7, Y8) et des optimisations fonctionnelles (Y3, Y4, Y5).

### Autres inadéquations identifiées
1. **Colonnes non normalisées**
   - **Problème** : Certaines colonnes, comme `prec_tot` et `prec_nat` dans `CarnetMeteo`, contenaient des données redondantes ou non atomiques, ce qui violait les principes de la première forme normale (1NF).
   - **Correction** : Nous avons réorganisé les tables pour éliminer les redondances et diviser les colonnes non atomiques en plusieurs colonnes distinctes. Par exemple, `prec_tot` a été séparée en `prec_pluie` et `prec_neige` pour mieux représenter les données.

2. **Types de données incorrects**
   - **Problème** : Certaines colonnes, comme `type_precipitation` dans `TypePrecipitations`, utilisaient des types de données inappropriés, comme TEXT au lieu de ENUM pour les valeurs codifiées.
   - **Correction** : Nous avons adopté des types ENUM pour les colonnes codifiées, ce qui améliore la lisibilité et la validation des données. Par exemple, `type_precipitation` utilise désormais ENUM avec des valeurs comme `N` pour Neige et `P` pour Pluie.

3. **Absence de triggers**
   - **Problème** : Certaines validations, comme la vérification des plages de valeurs dans `CarnetMeteo`, nécessitaient des triggers pour automatiser les vérifications lors des insertions ou mises à jour.
   - **Correction** : Nous avons ajouté des triggers pour garantir que les données insérées respectent les contraintes définies. Par exemple, un trigger vérifie que `temp_min` est toujours inférieur ou égal à `temp_max` lors de l'insertion.

## Normalisation globale
### Objectifs de la normalisation
La normalisation visait à :
- Éliminer les redondances dans les données.
- Garantir l'intégrité référentielle entre les tables.
- Atteindre la troisième forme normale (3NF) et, lorsque possible, la forme normale de Boyce-Codd (BCNF).

### Étapes de la normalisation
1. **Analyse des dépendances fonctionnelles** :
   - Nous avons commencé par identifier les dépendances fonctionnelles dans chaque table. Cela impliquait de déterminer quelles colonnes dépendaient directement de la clé primaire et lesquelles introduisaient des dépendances transitives ou des redondances.
   - Par exemple, dans la table `CarnetMeteo`, nous avons constaté que les colonnes `prec_tot` et `prec_nat` dépendaient directement de la clé primaire `date`. Cependant, certaines colonnes comme `note` n'étaient pas directement liées à la clé primaire et nécessitaient une révision pour garantir leur pertinence.

2. **Élimination des dépendances transitives** :
   - Une fois les dépendances identifiées, nous avons restructuré les tables pour éliminer les dépendances transitives. Cela impliquait de diviser certaines tables en plusieurs entités plus petites et de créer des relations claires entre elles.
   - Par exemple, dans la table `ObsFloraison`, la colonne `fleur` dépendait de `date` mais introduisait une dépendance transitive inutile. Nous avons retiré cette colonne et créé une structure plus cohérente.

3. **Validation des relations** :
   - Nous avons vérifié que toutes les relations entre les tables respectaient les principes de la 3NF et de la BCNF. Cela impliquait de tester les clés primaires et étrangères pour garantir qu'elles étaient correctement définies et utilisées.
   - Par exemple, dans la table `Taux`, nous avons ajouté des contraintes CHECK pour valider que les intervalles définis étaient compacts et ne se chevauchaient pas. Cela a permis de garantir une interprétation claire des données.

4. **Optimisation des types de données** :
   - Nous avons remplacé les types de données inappropriés par des types plus adaptés. Par exemple, les colonnes codifiées qui utilisaient le type TEXT ont été converties en types ENUM, ce qui améliore la lisibilité et la validation des données.
   - Dans la table `TypePrecipitations`, nous avons défini un type ENUM pour les codes de précipitations (`N` pour Neige, `P` pour Pluie), ce qui simplifie les validations et réduit les erreurs.

5. **Ajout de contraintes et triggers** :
   - Pour renforcer l'intégrité des données, nous avons ajouté des contraintes CHECK et des triggers. Les contraintes CHECK garantissent que les données insérées respectent des bornes logiques, tandis que les triggers automatisent certaines validations lors des insertions ou mises à jour.
   - Par exemple, dans la table `CarnetMeteo`, nous avons ajouté des contraintes CHECK pour valider que `temp_min <= temp_max`, `hum_min <= hum_max`, et `vent_min <= vent_max`. Ces contraintes garantissent que les données météorologiques sont cohérentes.

### Résultats obtenus
- **Respect de la 3NF** : Toutes les tables respectent désormais la troisième forme normale (3NF), ce qui élimine les redondances et garantit une structure claire.
- **BCNF pour certaines tables** : Certaines tables, comme `Taux`, ont été poussées jusqu'à la forme normale de Boyce-Codd (BCNF) pour garantir une structure optimale.
- **Relations renforcées** : Les relations entre les tables sont clairement définies par des clés primaires et étrangères, ce qui améliore l'intégrité référentielle.
- **Types de données optimisés** : L'utilisation de types ENUM et de contraintes CHECK garantit une meilleure validation des données et réduit les erreurs potentielles.

### Exemple détaillé : Table `CarnetMeteo`
- **Problème initial** : La table contenait des colonnes mal définies et des relations non respectées avec les autres tables. Par exemple, les précipitations totales n'étaient pas correctement liées à leur type, et les clés étrangères étaient absentes ou incorrectes.
- **Corrections appliquées** :
  - Ajout de clés étrangères pour établir des relations claires entre `CarnetMeteo` et les tables `ObsTemperature`, `ObsHumidite`, `ObsPrecipitations`, `ObsVents`, et `ObsPression`.
  - Ajout de contraintes CHECK pour valider les plages de valeurs (température, humidité, vent, pression).
  - Réorganisation des colonnes pour garantir leur pertinence et leur cohérence avec la clé primaire.

### Exemple détaillé : Table `Taux`
- **Problème initial** : Les intervalles définis dans la table se chevauchaient parfois, ce qui créait des ambiguïtés dans les analyses.
- **Corrections appliquées** :
  - Ajout de contraintes CHECK pour valider que les intervalles sont compacts et ne se chevauchent pas.
  - Restructuration de la table pour garantir une interprétation claire des données.

### Exemple détaillé : Table `TypePrecipitations`
- **Problème initial** : Les codes de précipitations étaient définis comme du texte libre, ce qui augmentait le risque d'erreurs.
- **Corrections appliquées** :
  - Définition d'un type ENUM pour les codes de précipitations (`N` pour Neige, `P` pour Pluie).
  - Ajout de contraintes pour garantir que les données insérées respectent les valeurs définies.

Ces étapes ont permis de transformer les bases de données Herbivorie et Météo en structures robustes, cohérentes et faciles à maintenir.

## Schéma final
### Structure des tables
- **Herbivorie** : Observations floristiques, placettes, taux de couverture, floraison.
- **Météo** : Températures, humidité, précipitations, vents, pression.

### Contraintes principales
- Clés primaires et étrangères.
- Contraintes CHECK pour valider les plages de valeurs.
- Types ENUM pour les colonnes codifiées.

## Tests et validation
Des requêtes SQL ont été utilisées pour valider les corrections :
- **Test des contraintes CHECK** : Insertion de données valides et invalides.
- **Validation des relations** : Vérification des clés étrangères et des dépendances.

## Analyse critique et discussion
### Améliorations
- Intégrité renforcée grâce aux contraintes CHECK et aux types ENUM.
- Réduction des redondances et amélioration de la cohérence des données.

### Limites
- Certaines procédures pourraient être optimisées pour des performances accrues.
- Les tests automatisés pourraient être étendus.

### Perspectives d’évolution
- Intégration de triggers pour automatiser certaines validations.
- Ajout de vues supplémentaires pour faciliter l'analyse des données.

## Conclusion
Le projet Herbivorie a permis de normaliser deux bases de données complexes et de résoudre les inadéquations identifiées. Les corrections appliquées garantissent une meilleure intégrité et cohérence des données. Ce travail constitue une base solide pour des analyses futures et des évolutions potentielles.

## Annexes
- Scripts SQL corrigés : Voir le dossier `sql/j1/`.
- Diagrammes relationnels : À inclure dans une version future.
