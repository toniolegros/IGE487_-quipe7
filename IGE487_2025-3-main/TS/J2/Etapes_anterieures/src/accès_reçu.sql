---------------------------------------------------------------------
-- SECTION 1 — Schéma principal réservé à l'équipe de développement
---------------------------------------------------------------------

-- Retirer tout accès direct au schéma Herbivorie
REVOKE USAGE ON SCHEMA "Herbivorie" FROM ige487_65;
REVOKE SELECT ON ALL TABLES IN SCHEMA "Herbivorie" FROM ige487_65;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA "Herbivorie" FROM ige487_65;
REVOKE EXECUTE ON ALL PROCEDURES IN SCHEMA "Herbivorie" FROM ige487_65;

---------------------------------------------------------------------
-- SECTION 2 — Protection complète du schéma Staging
---------------------------------------------------------------------

REVOKE USAGE ON SCHEMA "Staging" FROM ige487_65;
REVOKE SELECT ON ALL TABLES IN SCHEMA "Staging" FROM ige487_65;

-- Optionnel: s'assurer aussi qu'il n'a rien sur public
REVOKE USAGE ON SCHEMA public FROM ige487_65;
REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM ige487_65;

---------------------------------------------------------------------
-- SECTION 3 — Autoriser la connexion à la base BDE
---------------------------------------------------------------------

GRANT CONNECT ON DATABASE ige487_36db TO ige487_65;

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
GRANT USAGE ON SCHEMA Expo TO ige487_65;

-- L’équipe peut lire uniquement l’IMM CarnetMeteo
GRANT SELECT ON Expo.CarnetMeteo TO ige487_65;









---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------
-- SECTION 0 — (SUPPRIMÉ) : aucune création de schéma Expo ou de vue IMM
---------------------------------------------------------------------



---------------------------------------------------------------------
-- SECTION 1 — Révocations (SANS 65)
-- On révoque SEULEMENT pour 61, 62, 63, 64, 66, 67, 68, 69, 70
---------------------------------------------------------------------

-- === Révocations Herbivorie ===
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Herbivorie" FROM ige487_61;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Herbivorie" FROM ige487_62;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Herbivorie" FROM ige487_63;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Herbivorie" FROM ige487_64;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Herbivorie" FROM ige487_66;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Herbivorie" FROM ige487_67;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Herbivorie" FROM ige487_68;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Herbivorie" FROM ige487_69;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Herbivorie" FROM ige487_70;



---------------------------------------------------------------------
-- SECTION 2 — Révocations Staging (toujours SANS 65)
---------------------------------------------------------------------

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Staging" FROM ige487_61;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Staging" FROM ige487_62;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Staging" FROM ige487_63;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Staging" FROM ige487_64;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Staging" FROM ige487_66;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Staging" FROM ige487_67;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Staging" FROM ige487_68;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Staging" FROM ige487_69;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "Staging" FROM ige487_70;



---------------------------------------------------------------------
-- SECTION 3 — Révocations Public
---------------------------------------------------------------------

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM ige487_61;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM ige487_62;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM ige487_63;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM ige487_64;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM ige487_66;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM ige487_67;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM ige487_68;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM ige487_69;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM ige487_70;



---------------------------------------------------------------------
-- SECTION 4 — Permissions de connexion
---------------------------------------------------------------------

GRANT CONNECT ON DATABASE ige487_36db TO ige487_61;
GRANT CONNECT ON DATABASE ige487_36db TO ige487_62;
GRANT CONNECT ON DATABASE ige487_36db TO ige487_63;
GRANT CONNECT ON DATABASE ige487_36db TO ige487_64;
GRANT CONNECT ON DATABASE ige487_36db TO ige487_65;
GRANT CONNECT ON DATABASE ige487_36db TO ige487_66;
GRANT CONNECT ON DATABASE ige487_36db TO ige487_67;
GRANT CONNECT ON DATABASE ige487_36db TO ige487_68;
GRANT CONNECT ON DATABASE ige487_36db TO ige487_69;
GRANT CONNECT ON DATABASE ige487_36db TO ige487_70;



---------------------------------------------------------------------
-- SECTION 5 — (SUPPRIMÉ) : aucune permission Expo, aucune lecture IMM
---------------------------------------------------------------------



---------------------------------------------------------------------
-- SECTION 6 — ACCÈS COMPLET POUR TOUTES LES ÉQUIPES SAUF 65
---------------------------------------------------------------------

-- Herbivorie (plein accès)
GRANT USAGE ON SCHEMA "Herbivorie"
TO ige487_61, ige487_62, ige487_63, ige487_64,
   ige487_66, ige487_67, ige487_68, ige487_69, ige487_70;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA "Herbivorie"
TO ige487_61, ige487_62, ige487_63, ige487_64,
   ige487_66, ige487_67, ige487_68, ige487_69, ige487_70;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA "Herbivorie"
TO ige487_61, ige487_62, ige487_63, ige487_64,
   ige487_66, ige487_67, ige487_68, ige487_69, ige487_70;



-- Staging (plein accès)
GRANT USAGE ON SCHEMA "Staging"
TO ige487_61, ige487_62, ige487_63, ige487_64,
   ige487_66, ige487_67, ige487_68, ige487_69, ige487_70;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA "Staging"
TO ige487_61, ige487_62, ige487_63, ige487_64,
   ige487_66, ige487_67, ige487_68, ige487_69, ige487_70;



-- Public (plein accès)
GRANT USAGE ON SCHEMA public
TO ige487_61, ige487_62, ige487_63, ige487_64,
   ige487_66, ige487_67, ige487_68, ige487_69, ige487_70;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public
TO ige487_61, ige487_62, ige487_63, ige487_64,
   ige487_66, ige487_67, ige487_68, ige487_69, ige487_70;

