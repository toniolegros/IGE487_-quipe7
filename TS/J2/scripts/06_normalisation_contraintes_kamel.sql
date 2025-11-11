SET search_path TO "Herbivorie", public;

-- Exemples : à adapter selon ton schéma
ALTER TABLE IF EXISTS etat
  ADD CONSTRAINT pk_etat PRIMARY KEY (etat);

ALTER TABLE IF EXISTS plant
  ADD CONSTRAINT fk_plant_placette FOREIGN KEY (placette)
  REFERENCES placette_core(placette);

ALTER TABLE IF EXISTS placette_core
  ADD CONSTRAINT uq_placette_unique UNIQUE (placette);

ALTER TABLE IF EXISTS taux
  ADD CONSTRAINT ck_taux_min_le_max CHECK (tmin <= tmax);
