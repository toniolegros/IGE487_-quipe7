SET search_path TO "Herbivorie", public;

-- Doublons (doit renvoyer 0 ligne)
SELECT etat, COUNT(*) c FROM etat GROUP BY etat HAVING COUNT(*) > 1;

-- Orphelines (doit renvoyer 0 ligne)
SELECT p.* FROM plant p
LEFT JOIN placette_core pc ON pc.placette = p.placette
WHERE pc.placette IS NULL;

-- Règle métier (doit renvoyer 0 ligne)
SELECT * FROM taux WHERE tmin > tmax;
