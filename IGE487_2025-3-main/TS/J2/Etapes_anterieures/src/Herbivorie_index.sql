SET SCHEMA 'Herbivorie' ;


CREATE INDEX idx_plant_placette
    ON Plant(placette);

CREATE INDEX idx_plant_date
    ON Plant(date);

CREATE INDEX idx_obsdimension_longueur_largeur
    ON ObsDimension(longueur, largeur);

CREATE INDEX idx_obsdimension_id
    ON ObsDimension(id);

CREATE INDEX idx_obsfloraison_id
    ON ObsFloraison(id);

CREATE INDEX idx_obsfloraison_date
    ON ObsFloraison(date);

CREATE INDEX idx_obsetat_id
    ON ObsEtat(id);

CREATE INDEX idx_obsetat_date
    ON ObsEtat(date);

CREATE INDEX idx_placette_core_peup
    ON Placette_core(peup);

CREATE INDEX idx_placette_core_date
    ON Placette_core(date);

CREATE INDEX idx_obstruction_plac
    ON Placette_Obstruction(plac);

CREATE INDEX idx_obstruction_tcat
    ON Placette_Obstruction(tcat);


CREATE INDEX idx_couvert_plac
    ON Placette_Couvert(plac);

CREATE INDEX idx_couvert_tcat
    ON Placette_Couvert(tcat);

CREATE INDEX idx_dominant_plac
    ON Placette_Dominant(plac);

CREATE INDEX idx_dominant_arbre
    ON Placette_Dominant(arbre);

CREATE INDEX idx_taux_intervalle
    ON Taux(tMin, tMax);

CREATE INDEX idx_taux_tcat
    ON Taux(tCat);