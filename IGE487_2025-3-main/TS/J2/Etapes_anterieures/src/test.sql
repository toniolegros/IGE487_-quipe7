---------------------------------------------------------------------
-- SECTION 1 — Schéma principal réservé à l'équipe de développement
---------------------------------------------------------------------

-- Retirer tout accès direct au schéma Herbivorie
REVOKE USAGE ON SCHEMA "Herbivorie" FROM ige487_69;
REVOKE SELECT ON ALL TABLES IN SCHEMA "Herbivorie" FROM ige487_69;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA "Herbivorie" FROM ige487_69;
REVOKE EXECUTE ON ALL PROCEDURES IN SCHEMA "Herbivorie" FROM ige487_69;

---------------------------------------------------------------------
-- SECTION 2 — Protection complète du schéma Staging
---------------------------------------------------------------------

REVOKE USAGE ON SCHEMA "Staging" FROM ige487_69;
REVOKE SELECT ON ALL TABLES IN SCHEMA "Staging" FROM ige487_69;

-- Optionnel: s'assurer aussi qu'il n'a rien sur public
REVOKE USAGE ON SCHEMA public FROM ige487_69;
REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM ige487_69;

---------------------------------------------------------------------
-- SECTION 3 — Autoriser la connexion à la base BDE
---------------------------------------------------------------------

GRANT CONNECT ON DATABASE ige487_36db TO ige487_69;

---------------------------------------------------------------------
-- SECTION 4 — Création du schéma IMM (interface d'accès)
---------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS Expo;

---------------------------------------------------------------------
-- SECTION 5 — Création de l'IMM pour CarnetMeteo
---------------------------------------------------------------------

CREATE OR REPLACE VIEW Expo.CarnetMeteo AS
SELECT *
FROM "Staging".CarnetMeteo;

---------------------------------------------------------------------
-- SECTION 6 — Permissions pour accès LECTURE IMM uniquement
---------------------------------------------------------------------

-- L’équipe peut utiliser le schéma IMM
GRANT USAGE ON SCHEMA Expo TO ige487_69;

-- L’équipe peut lire uniquement l’IMM CarnetMeteo
GRANT SELECT ON Expo.CarnetMeteo TO ige487_69;


SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('Herbivorie', 'Herbivorie_BDD', 'IMM_BDD', 'Staging');
