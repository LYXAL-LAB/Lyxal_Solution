-- =============================================================================================
-- |
-- | Fichier     : continent.surql
-- | Module      : geographical
-- | Description : Définit la table `continent` qui contient le référentiel des continents.
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS continent 
    TYPE NORMAL 
    SCHEMAFULL 
    COMMENT 'Référentiel immuable des continents (ex: eu, af, as).'
    PERMISSIONS 
        FOR select FULL;

-- ------------------------------
-- CHAMPS
-- ------------------------------

-- Clé i18n pour le nom traduisible du continent.
DEFINE FIELD IF NOT EXISTS key.name ON TABLE continent 
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour le nom du continent (ex: "Europe", "Africa").';

-- Coordonnées géographiques (Point GeoJSON)
DEFINE FIELD IF NOT EXISTS location ON TABLE continent
    TYPE option<point>
    COMMENT 'Coordonnées géographiques du centre du continent (longitude, latitude).';

-- Frontières (Polygon GeoJSON)
DEFINE FIELD IF NOT EXISTS boundary ON TABLE continent
    TYPE option<geometry<polygon>>
    COMMENT 'Frontières géographiques du continent (polygone GeoJSON).';

-- Statut d'activité du continent.
DEFINE FIELD IF NOT EXISTS isActive ON TABLE continent 
    TYPE bool 
    DEFAULT true
    COMMENT 'Indique si le continent est actuellement utilisé ou visible.';