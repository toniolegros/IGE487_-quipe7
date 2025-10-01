-- Contraintes et assertions pour le jalon 1

-- Contrainte d'intégrité sur la table Taux pour garantir compacité, non-chevauchement et couverture complète
ALTER TABLE Taux
ADD CONSTRAINT Taux_compact_non_chevauchement CHECK (
    NOT EXISTS (
        SELECT 1
        FROM Taux t1, Taux t2
        WHERE t1.tCat <> t2.tCat
          AND t1.tMin <= t2.tMax
          AND t1.tMax >= t2.tMin
    )
    AND (
        SELECT SUM(tMax - tMin + 1) FROM Taux
    ) = 101
);