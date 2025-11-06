
SET SCHEMA 'Herbivorie';

CREATE TABLE Megantic (
    id  plant_id,
    placette placette_id,
    longueur dim_mm,
    largeur dim_mm,
    fleur Text,
    sous_parcelle parcelle,
    date date_eco,
    JJ dim_mm,
    etat etat_id,
    note description
    --statut VARCHAR(20) DEFAULT 'EN_ATTENTE',
   -- date_integration TIMESTAMP DEFAULT NOW()
);

CREATE TABLE Log_Integration (
    id_log SERIAL PRIMARY KEY,
    table_cible VARCHAR(50),
    nb_lignes INT,
    date_exec TIMESTAMP DEFAULT NOW()
);

CREATE OR REPLACE PROCEDURE Integrer_Carnet()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Plant (si nouveau)
    INSERT INTO Plant (id, plac, parcelle, date, note)
    SELECT DISTINCT id, plac, sous_parcelle, date_obs, note
    FROM Megantic
    WHERE statut='EN_ATTENTE'
    ON CONFLICT (id) DO NOTHING;

    -- ObsDimension
    INSERT INTO ObsDimension (id, longueur, largeur, date, note)
    SELECT id, longueur, largeur, date_obs, note
    FROM Megantic
    WHERE statut='EN_ATTENTE'
    ON CONFLICT DO NOTHING;

    -- ObsFloraison
    INSERT INTO ObsFloraison (id, fleur, date, note)
    SELECT id, fleur, date_obs, note
    FROM Megantic
    WHERE statut='EN_ATTENTE'
    ON CONFLICT DO NOTHING;

    -- ObsEtat
    INSERT INTO ObsEtat (id, etat, date, note)
    SELECT id, etat, date_obs, note
    FROM Megantic
    WHERE statut='EN_ATTENTE'
    ON CONFLICT DO NOTHING;

    -- Journalisation
    INSERT INTO Log_Integration (table_cible, nb_lignes)
    VALUES ('Carnet terrain',
            (SELECT COUNT(*) FROM Megantic WHERE statut='EN_ATTENTE'));

    -- Nettoyage
    DELETE FROM Megantic WHERE statut='EN_ATTENTE';
END;
$$;

select *
from megantic;