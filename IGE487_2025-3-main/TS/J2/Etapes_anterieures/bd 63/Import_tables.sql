----------------------------------------------------------------------
-- IMPORTATION BD 63 — CARNET METEO, CARNET PLACETTE, CARNET PLANT
----------------------------------------------------------------------

\copy "ige487_63".carnet_meteo63
FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 63/Carnet_meteo.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_63".carnetplacette63
FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 63/Carnetplacette.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_63".carnetplant63
FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 63/carnetplant.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ';');

----------------------------------------------------------------------
-- FIN DU SCRIPT
----------------------------------------------------------------------

