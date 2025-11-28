----------------------------------------------------------------------
-- IMPORTATION BD 68 — TOUTES LES TABLES EN UNE SEULE EXÉCUTION
----------------------------------------------------------------------

\copy "ige487_68".site FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/site.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".zone FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/zone.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".arbre FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/arbre.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".peuplement FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/peuplement.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".placette FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/placette.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".parcelle FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/parcelle.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".plant FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/plant.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".obsarbre FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/obsarbre.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".obscouverture FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/obscouverture.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".obsobstruction FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/obsobstruction.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".obsplantlocalisation FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/obsplantlocalisation.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".obsdimension FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/obsdimension.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".obsfloraison FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/obsfloraison.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".obsetat FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/obsetat.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".obshumidite FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/obshumidite.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".obspression FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/obspression.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".obstemperature FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/obstemperature.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".obsprecipitation FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/obsprecipitation.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

-- obsvents.csv (selon ta table réelle : obsvent)
\copy "ige487_68".obsvent FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/obsvents.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

\copy "ige487_68".precipitation FROM 'C:/Users/pathy/IGE487_-quipe7/IGE487_2025-3-main/TS/J2/Etapes_anterieures/bd 68/precipitation.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

----------------------------------------------------------------------
-- FIN DU SCRIPT
----------------------------------------------------------------------

