---------------------------------------------------------------------
-- SECTION 0 — Retrait complet de Expo (IMM)
---------------------------------------------------------------------

DROP VIEW IF EXISTS Expo.megantic;
DROP SCHEMA IF EXISTS Expo CASCADE;


---------------------------------------------------------------------
-- SECTION 1 — Lecture seule sur SCHÉMA Herbivorie
---------------------------------------------------------------------

GRANT USAGE ON SCHEMA "Herbivorie" TO ige487_61;
GRANT SELECT ON ALL TABLES IN SCHEMA "Herbivorie" TO ige487_61;

GRANT USAGE ON SCHEMA "Herbivorie" TO ige487_62;
GRANT SELECT ON ALL TABLES IN SCHEMA "Herbivorie" TO ige487_62;

GRANT USAGE ON SCHEMA "Herbivorie" TO ige487_63;
GRANT SELECT ON ALL TABLES IN SCHEMA "Herbivorie" TO ige487_63;

GRANT USAGE ON SCHEMA "Herbivorie" TO ige487_64;
GRANT SELECT ON ALL TABLES IN SCHEMA "Herbivorie" TO ige487_64;

/* 65 retiré volontairement */

GRANT USAGE ON SCHEMA "Herbivorie" TO ige487_66;
GRANT SELECT ON ALL TABLES IN SCHEMA "Herbivorie" TO ige487_66;

GRANT USAGE ON SCHEMA "Herbivorie" TO ige487_67;
GRANT SELECT ON ALL TABLES IN SCHEMA "Herbivorie" TO ige487_67;

GRANT USAGE ON SCHEMA "Herbivorie" TO ige487_68;
GRANT SELECT ON ALL TABLES IN SCHEMA "Herbivorie" TO ige487_68;

GRANT USAGE ON SCHEMA "Herbivorie" TO ige487_69;
GRANT SELECT ON ALL TABLES IN SCHEMA "Herbivorie" TO ige487_69;

GRANT USAGE ON SCHEMA "Herbivorie" TO ige487_70;
GRANT SELECT ON ALL TABLES IN SCHEMA "Herbivorie" TO ige487_70;


---------------------------------------------------------------------
-- SECTION 2 — Lecture seule sur SCHÉMA Staging
---------------------------------------------------------------------

GRANT USAGE ON SCHEMA "Staging" TO ige487_61;
GRANT SELECT ON ALL TABLES IN SCHEMA "Staging" TO ige487_61;

GRANT USAGE ON SCHEMA "Staging" TO ige487_62;
GRANT SELECT ON ALL TABLES IN SCHEMA "Staging" TO ige487_62;

GRANT USAGE ON SCHEMA "Staging" TO ige487_63;
GRANT SELECT ON ALL TABLES IN SCHEMA "Staging" TO ige487_63;

GRANT USAGE ON SCHEMA "Staging" TO ige487_64;
GRANT SELECT ON ALL TABLES IN SCHEMA "Staging" TO ige487_64;

/* 65 retiré volontairement */

GRANT USAGE ON SCHEMA "Staging" TO ige487_66;
GRANT SELECT ON ALL TABLES IN SCHEMA "Staging" TO ige487_66;

GRANT USAGE ON SCHEMA "Staging" TO ige487_67;
GRANT SELECT ON ALL TABLES IN SCHEMA "Staging" TO ige487_67;

GRANT USAGE ON SCHEMA "Staging" TO ige487_68;
GRANT SELECT ON ALL TABLES IN SCHEMA "Staging" TO ige487_68;

GRANT USAGE ON SCHEMA "Staging" TO ige487_69;
GRANT SELECT ON ALL TABLES IN SCHEMA "Staging" TO ige487_69;

GRANT USAGE ON SCHEMA "Staging" TO ige487_70;
GRANT SELECT ON ALL TABLES IN SCHEMA "Staging" TO ige487_70;


---------------------------------------------------------------------
-- SECTION 3 — Permissions : connexion
---------------------------------------------------------------------

GRANT CONNECT ON DATABASE ige487_65db TO ige487_61;
GRANT CONNECT ON DATABASE ige487_65db TO ige487_62;
GRANT CONNECT ON DATABASE ige487_65db TO ige487_63;
GRANT CONNECT ON DATABASE ige487_65db TO ige487_64;
/* 65 retiré volontairement */
GRANT CONNECT ON DATABASE ige487_65db TO ige487_66;
GRANT CONNECT ON DATABASE ige487_65db TO ige487_67;
GRANT CONNECT ON DATABASE ige487_65db TO ige487_68;
GRANT CONNECT ON DATABASE ige487_65db TO ige487_69;
GRANT CONNECT ON DATABASE ige487_65db TO ige487_70;
