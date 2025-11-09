-- Herbivorie_P2_M2.sql (cleaned of Markdown fences)
-- Date : 2025-11-09
-- Objectif : Script consolidé du modèle logique Herbivorie (J2). Ce script crée
-- les nouvelles entités demandées (Site, Zone, Parcelle, TypeMesure, UniteMesure,
-- Mesure) et modifie le schéma existant pour intégrer une hiérarchie de
-- localisation et un modèle de mesures quantitatives.

SET SCHEMA 'Herbivorie';

/*
CONTRAT / But
- Inputs: aucune donnée d'entrée; script DDL
- Outputs: création/alter des tables et contraintes nécessaires pour J2
- Erreurs: le script est idempotent partiellement — vérifier l'état du schéma avant
  exécution en production. Exécuter dans un environnement de test d'abord.
*/

-- 1) Tables de localisation : Site -> Zone -> Parcette
-- COMMENTAIRE : La hiérarchie Site -> Zone -> Placette -> Parcelle permet une
-- identification géographique claire et réutilisable. Parcelle est matérialisée
-- comme entité pour permettre une identification absolue des plants.

CREATE TABLE IF NOT EXISTS Site (
  site_id TEXT PRIMARY KEY,
  nom TEXT NOT NULL,
  description TEXT
);
COMMENT ON TABLE Site IS 'Site: unité géographique top-level (ex: zone d''étude).';
COMMENT ON COLUMN Site.site_id IS 'Identifiant du site (ex: S001)';
COMMENT ON COLUMN Site.nom IS 'Nom lisible du site';

CREATE TABLE IF NOT EXISTS Zone (
  zone_id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES Site(site_id) ON DELETE RESTRICT,
  nom TEXT NOT NULL,
  description TEXT
);
COMMENT ON TABLE Zone IS 'Zone: subdivision d''un site. (Site -> Zone -> Placette)';
COMMENT ON COLUMN Zone.site_id IS 'Référence au Site parent';

CREATE TABLE IF NOT EXISTS Parcelle (
  parcelle_id SERIAL PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES Site(site_id) ON DELETE RESTRICT,
  zone_id TEXT NOT NULL REFERENCES Zone(zone_id) ON DELETE RESTRICT,
  code TEXT NOT NULL,
  description TEXT,
  UNIQUE (site_id, zone_id, code)
);
COMMENT ON TABLE Parcelle IS 'Parcelle: subdivision localisée et réutilisable servant à identifier la position des plants.';
COMMENT ON COLUMN Parcelle.code IS 'Code local de parcelle (ex: 01, 02)';

-- 2) TypeMesure & UniteMesure : métadonnées pour les mesures
CREATE TABLE IF NOT EXISTS UniteMesure (
  unite_id TEXT PRIMARY KEY,
  libelle TEXT NOT NULL,
  description TEXT
);
COMMENT ON TABLE UniteMesure IS 'Unité de mesure (ex: mm, °C, %).';
COMMENT ON COLUMN UniteMesure.unite_id IS 'Code unité (ex: mm)';

CREATE TABLE IF NOT EXISTS TypeMesure (
  typemesure_id TEXT PRIMARY KEY,
  libelle TEXT NOT NULL,
  description TEXT
);
COMMENT ON TABLE TypeMesure IS 'Type de mesure (ex: hauteur_precipitation, temperature_min).';

-- 3) Mesure : table générique de mesures quantitatives
CREATE TABLE IF NOT EXISTS Mesure (
  mesure_id BIGSERIAL PRIMARY KEY,
  typemesure_id TEXT NOT NULL REFERENCES TypeMesure(typemesure_id) ON DELETE RESTRICT,
  unite_id TEXT NOT NULL REFERENCES UniteMesure(unite_id) ON DELETE RESTRICT,
  valeur NUMERIC NOT NULL,
  date_obs DATE NOT NULL,
  source TEXT, -- ex: CarnetMeteo, instrument, import CSV
  commentaire TEXT
);
COMMENT ON TABLE Mesure IS 'Mesures quantitatives normalisées (lié à TypeMesure et UniteMesure).';

-- 4) Log d''opérations pour IMM/PROC
CREATE TABLE IF NOT EXISTS Log_Operation (
  log_id BIGSERIAL PRIMARY KEY,
  operation TEXT NOT NULL,
  objet TEXT,
  details TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  auteur TEXT
);
COMMENT ON TABLE Log_Operation IS 'Journalisation simple des IMM et procédures (événements d''insert/update/delete).';

-- 5) Intégration progressive au schéma existant (ALTER)
-- Ajouter colonnes site/zone à Placette_core et rendre Parcelle une table référencée
ALTER TABLE IF EXISTS Placette_core
  ADD COLUMN IF NOT EXISTS site_id TEXT,
  ADD COLUMN IF NOT EXISTS zone_id TEXT;

ALTER TABLE IF EXISTS Placette_core
  ADD CONSTRAINT IF NOT EXISTS placette_core_site_fk FOREIGN KEY (site_id) REFERENCES Site(site_id) ON DELETE RESTRICT;

ALTER TABLE IF EXISTS Placette_core
  ADD CONSTRAINT IF NOT EXISTS placette_core_zone_fk FOREIGN KEY (zone_id) REFERENCES Zone(zone_id) ON DELETE RESTRICT;

-- Créer la table Parcelle si elle n'existe pas (définie ci-dessus). Maintenant
-- on modifie Plant.parcelle pour référencer Parcelle.parcelle_id si possible.
ALTER TABLE IF EXISTS Plant
  ADD COLUMN IF NOT EXISTS parcelle_id INTEGER;

-- Note : pour conserver compatibilité, on garde la colonne 'parcelle' existante
-- et on propose un script de migration des valeurs numériques vers parcelle_id.
-- Migration recommandée (exécuter manuellement après vérification) :
-- UPDATE Plant SET parcelle_id = CAST(parcelle AS INTEGER) WHERE parcelle IS NOT NULL;
-- Puis ajouter la contrainte FK :
-- ALTER TABLE Plant ADD CONSTRAINT plant_parcelle_fk FOREIGN KEY (parcelle_id) REFERENCES Parcelle(parcelle_id) ON DELETE RESTRICT;

-- 5.b) Modification du comportement de Taux (J2)
-- Pour passer du modèle catégoriel (codes alphabétiques) à une mesure quantitative
-- nous introduisons une colonne quantitative sur les placettes : `taux_pct`.
-- Cette colonne (0..100) doit être utilisée pour les nouvelles insertions. La
-- table historique `Taux` est conservée pour compatibilité mais n'est plus
-- nécessaire pour représenter les mesures quantitatives.

-- Exemple (exécuter manuellement si besoin) :
-- ALTER TABLE Placette_Couvert ADD COLUMN IF NOT EXISTS taux_pct INTEGER CHECK (taux_pct BETWEEN 0 AND 100);
-- ALTER TABLE Placette_Obstruction ADD COLUMN IF NOT EXISTS taux_pct INTEGER CHECK (taux_pct BETWEEN 0 AND 100);

-- 5.c) Identification absolue des plants
-- Ajout d'une colonne `global_id` sur Plant pour permettre l'identification
-- des individus indépendamment de leur localisation (ex: tag physique, UUID).
-- ALTER TABLE Plant ADD COLUMN IF NOT EXISTS global_id TEXT UNIQUE;

-- 6) Exemple : ajouter quelques types et unités de mesure (valeurs initiales)
INSERT INTO UniteMesure (unite_id, libelle) VALUES ('mm','millimètre') ON CONFLICT (unite_id) DO NOTHING;
INSERT INTO UniteMesure (unite_id, libelle) VALUES ('degC','degré Celsius') ON CONFLICT (unite_id) DO NOTHING;
INSERT INTO UniteMesure (unite_id, libelle) VALUES ('pct','pourcentage') ON CONFLICT (unite_id) DO NOTHING;

INSERT INTO TypeMesure (typemesure_id, libelle) VALUES ('precip_tot','Précipitations totales') ON CONFLICT (typemesure_id) DO NOTHING;
INSERT INTO TypeMesure (typemesure_id, libelle) VALUES ('temp_min','Température minimale') ON CONFLICT (typemesure_id) DO NOTHING;
INSERT INTO TypeMesure (typemesure_id, libelle) VALUES ('taux_couverture','Taux de couverture (pourcentage)') ON CONFLICT (typemesure_id) DO NOTHING;

-- 7) Procédure d'exemple : IMM insert générique pour Mesure avec journalisation
CREATE OR REPLACE PROCEDURE imm_insert_mesure(
  p_typemesure_id TEXT,
  p_unite_id TEXT,
  p_valeur NUMERIC,
  p_date_obs DATE,
  p_source TEXT,
  p_auteur TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO Mesure(typemesure_id, unite_id, valeur, date_obs, source) VALUES (p_typemesure_id, p_unite_id, p_valeur, p_date_obs, p_source);
  INSERT INTO Log_Operation(operation, objet, details, auteur) VALUES ('IMM_INSERT_MESURE', p_typemesure_id, format('val=%s;date=%s;source=%s', p_valeur::text, p_date_obs::text, p_source), p_auteur);
END;
$$;

 
```