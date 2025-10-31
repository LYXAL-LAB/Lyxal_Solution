-- =============================================================================================
-- |
-- | Fichier     : region.surql
-- | Module      : geographical
-- | Description : Définit la table `region` qui contient le référentiel des régions géographiques.
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS region 
    TYPE NORMAL 
    SCHEMAFULL 
    COMMENT 'Référentiel des régions géographiques (ex: Western Europe, Southern Asia).'
    PERMISSIONS 
        FOR select FULL;

-- ------------------------------
-- CHAMPS
-- ------------------------------

-- Clé i18n pour le nom traduisible de la région.
DEFINE FIELD IF NOT EXISTS key.name ON TABLE region 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n pour le nom de la région.';

-- Lien vers le continent parent.
DEFINE FIELD IF NOT EXISTS continent ON TABLE region
    TYPE record<continent>
    REFERENCE ON DELETE REJECT
    COMMENT 'Le continent auquel cette région appartient.';

-- Coordonnées géographiques (Point GeoJSON)
DEFINE FIELD IF NOT EXISTS location ON TABLE region
    TYPE option<point>
    COMMENT 'Coordonnées géographiques du centre de la région (longitude, latitude).';

-- Frontières (Polygon GeoJSON)
DEFINE FIELD IF NOT EXISTS boundary ON TABLE region
    TYPE option<geometry<polygon>>
    COMMENT 'Frontières géographiques de la région (polygone GeoJSON).';

-- Statut d'activité de la région.
DEFINE FIELD IF NOT EXISTS isActive ON TABLE region 
    TYPE bool 
    DEFAULT true
    COMMENT 'Indique si la région est actuellement utilisée ou visible.';

-- ------------------------------
-- INDEX
-- ------------------------------

-- Index pour retrouver rapidement les régions d'un continent.
DEFINE INDEX IF NOT EXISTS idx_region_continent 
    ON TABLE region 
    FIELDS continent;

