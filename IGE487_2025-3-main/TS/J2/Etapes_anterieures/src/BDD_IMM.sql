-- ============================================================================
-- IMM_BDD : Interface de consultation analytique pour "Herbivorie_BDD"
-- ============================================================================

DROP SCHEMA IF EXISTS "IMM_BDD" CASCADE;
CREATE SCHEMA "IMM_BDD";

-- ============================================================================
-- 1) Rôle IMM dédié
-- ============================================================================

DO $$
DECLARE
    i int;
BEGIN
    FOR i IN 61..70 LOOP
        IF i <> 65 THEN
            EXECUTE format('GRANT USAGE ON SCHEMA IMM_BDD TO ige487_%s;', i);
            EXECUTE format('GRANT SELECT ON ALL TABLES IN SCHEMA IMM_BDD TO ige487_%s;', i);
        END IF;
    END LOOP;
END;
$$;


-- ============================================================================
-- 2) VUES ANALYTIQUES (read-only)
-- ============================================================================

SET SCHEMA 'IMM_BDD';

-- Dimensions
CREATE OR REPLACE VIEW Dim_Date AS
SELECT * FROM "Herbivorie_BDD".Dim_Date;

CREATE OR REPLACE VIEW Dim_Site AS
SELECT * FROM "Herbivorie_BDD".Dim_Site;

CREATE OR REPLACE VIEW Dim_Zone AS
SELECT * FROM "Herbivorie_BDD".Dim_Zone;

CREATE OR REPLACE VIEW Dim_Placette AS
SELECT * FROM "Herbivorie_BDD".Dim_Placette;

CREATE OR REPLACE VIEW Dim_Parcelle AS
SELECT * FROM "Herbivorie_BDD".Dim_Parcelle;

CREATE OR REPLACE VIEW Dim_Peuplement AS
SELECT * FROM "Herbivorie_BDD".Dim_Peuplement;

CREATE OR REPLACE VIEW Dim_Arbre AS
SELECT * FROM "Herbivorie_BDD".Dim_Arbre;

CREATE OR REPLACE VIEW Dim_Plant AS
SELECT * FROM "Herbivorie_BDD".Dim_Plant;

CREATE OR REPLACE VIEW Dim_Taux AS
SELECT * FROM "Herbivorie_BDD".Dim_Taux;

CREATE OR REPLACE VIEW Dim_CouvertType AS
SELECT * FROM "Herbivorie_BDD".Dim_CouvertType;

CREATE OR REPLACE VIEW Dim_ObstructionNature AS
SELECT * FROM "Herbivorie_BDD".Dim_ObstructionNature;

CREATE OR REPLACE VIEW Dim_Hauteur AS
SELECT * FROM "Herbivorie_BDD".Dim_Hauteur;

CREATE OR REPLACE VIEW Dim_PrecipitationType AS
SELECT * FROM "Herbivorie_BDD".Dim_PrecipitationType;


-- Faits — Écologiques
CREATE OR REPLACE VIEW Fait_Observation AS
SELECT * FROM "Herbivorie_BDD".Fait_Observation;

CREATE OR REPLACE VIEW Fait_Obstruction AS
SELECT * FROM "Herbivorie_BDD".Fait_Obstruction;

CREATE OR REPLACE VIEW Fait_Couvert AS
SELECT * FROM "Herbivorie_BDD".Fait_Couvert;


-- Faits — Météo
CREATE OR REPLACE VIEW Fait_Temperature AS
SELECT * FROM "Herbivorie_BDD".Fait_Temperature;

CREATE OR REPLACE VIEW Fait_Humidite AS
SELECT * FROM "Herbivorie_BDD".Fait_Humidite;

CREATE OR REPLACE VIEW Fait_Vents AS
SELECT * FROM "Herbivorie_BDD".Fait_Vents;

CREATE OR REPLACE VIEW Fait_Pression AS
SELECT * FROM "Herbivorie_BDD".Fait_Pression;

CREATE OR REPLACE VIEW Fait_Precipitations AS
SELECT * FROM "Herbivorie_BDD".Fait_Precipitations;

-- ============================================================================
-- 3) Permissions
-- ============================================================================


-- Fin IMM_BDD
-- ============================================================================
