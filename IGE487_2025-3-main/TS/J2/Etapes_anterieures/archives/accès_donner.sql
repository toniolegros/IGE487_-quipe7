CREATE ROLE role_commum LOGIN PASSWORD 'secret';
--GRANT USAGE ON SCHEMA Herbivorie TO role_commum;
--GRANT SELECT ON ALL TABLES IN SCHEMA Herbivorie TO role_commum;

--Donner accès à tout
GRANT CONNECT ON DATABASE ige487_36db TO ige487_65;
GRANT USAGE ON SCHEMA "Herbivorie" TO ige487_65;
GRANT USAGE ON SCHEMA "Staging" TO ige487_65;
GRANT USAGE ON SCHEMA public TO ige487_65;
GRANT SELECT ON ALL TABLES IN SCHEMA "Herbivorie" TO ige487_65;
GRANT SELECT ON ALL TABLES IN SCHEMA "Staging" TO ige487_65;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO ige487_65;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA "Herbivorie" TO ige487_65;
ALTER DEFAULT PRIVILEGES IN SCHEMA "Herbivorie"
  GRANT SELECT ON TABLES TO ige487_65;
ALTER DEFAULT PRIVILEGES IN SCHEMA "Herbivorie"
  GRANT EXECUTE ON FUNCTIONS TO ige487_65;

--Révoquer les accès
REVOKE CONNECT ON DATABASE ige487_36db FROM ige487_65;
REVOKE USAGE ON SCHEMA "Herbivorie" FROM ige487_65;
REVOKE USAGE ON SCHEMA "Staging" FROM ige487_65;
REVOKE USAGE ON SCHEMA public FROM ige487_65;
REVOKE SELECT ON ALL TABLES IN SCHEMA "Herbivorie" FROM ige487_65;
--REVOKE SELECT ON TABLE "Herbivorie".Meteo FROM ige487_65;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA "Herbivorie" FROM ige487_65;
REVOKE EXECUTE ON ALL PROCEDURES IN SCHEMA "Herbivorie" FROM ige487_65;
ALTER DEFAULT PRIVILEGES IN SCHEMA "Herbivorie"
    REVOKE SELECT ON TABLES FROM ige487_65;

ALTER DEFAULT PRIVILEGES IN SCHEMA "Herbivorie"
    REVOKE EXECUTE ON FUNCTIONS FROM ige487_65;

--Donner accès à meteo
GRANT CONNECT ON DATABASE ige487_36db TO ige487_65;
GRANT USAGE ON SCHEMA "Staging" TO ige487_65;
GRANT SELECT ON TABLE "Staging".CarnetMeteo TO ige487_65;

-- Et on retire les SELECT partout ailleurs :
REVOKE SELECT ON ALL TABLES IN SCHEMA "Staging" FROM ige487_65;


--Test pour accès qu'à CarnetMeteo

-- 1. Autoriser la connexion à la base
GRANT CONNECT ON DATABASE ige487_36db TO ige487_65;

-- 2. Autoriser l'accès au schéma Staging
GRANT USAGE ON SCHEMA "Staging" TO ige487_65;

-- 3. Révoquer tout accès éventuel
REVOKE SELECT ON ALL TABLES IN SCHEMA "Staging" FROM ige487_65;

-- 4. Donner seulement l'accès à CarnetMeteo
GRANT SELECT ON TABLE "Staging".CarnetMeteo TO ige487_65;









---------------------------------------------------------------------
-- SECTION 1 — Schéma principal réservé à l'équipe de développement
---------------------------------------------------------------------

-- Retirer tout accès direct au schéma Herbivorie
REVOKE USAGE ON SCHEMA "Herbivorie" FROM ige487_6;
REVOKE SELECT ON ALL TABLES IN SCHEMA "Herbivorie" FROM ige487_6;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA "Herbivorie" FROM ige487_6;
REVOKE EXECUTE ON ALL PROCEDURES IN SCHEMA "Herbivorie" FROM ige487_6;

---------------------------------------------------------------------
-- SECTION 2 — Protection complète du schéma Staging
---------------------------------------------------------------------

REVOKE USAGE ON SCHEMA "Staging" FROM ige487_6;
REVOKE SELECT ON ALL TABLES IN SCHEMA "Staging" FROM ige487_6;

-- Optionnel: s'assurer aussi qu'il n'a rien sur public
REVOKE USAGE ON SCHEMA public FROM ige487_6;
REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM ige487_6;

---------------------------------------------------------------------
-- SECTION 3 — Autoriser la connexion à la base BDE
---------------------------------------------------------------------

GRANT CONNECT ON DATABASE ige487_36db TO ige487_6;

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
GRANT USAGE ON SCHEMA Expo TO ige487_6;

-- L’équipe peut lire uniquement l’IMM CarnetMeteo
GRANT SELECT ON Expo.CarnetMeteo TO ige487_6;



















