-- =============================================================================================
-- |
-- | Fichier     : city.surql
-- | Module      : geographical
-- | Description : Définit la table `city` qui contient le référentiel des villes.
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS city
    TYPE NORMAL
    SCHEMAFULL
    COMMENT 'Référentiel des villes.'
    PERMISSIONS
        FOR select FULL;

-- ------------------------------
-- CHAMPS
-- ------------------------------

-- Subdivision parente (état, région, etc.)
DEFINE FIELD IF NOT EXISTS state ON TABLE city
    TYPE record<state>
    REFERENCE ON DELETE REJECT
    COMMENT 'Subdivision administrative à laquelle la ville appartient.';

-- Clé i18n pour le nom traduisible
DEFINE FIELD IF NOT EXISTS key.name ON TABLE city
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n pour le nom de la ville.';

-- Nom natif de la ville
DEFINE FIELD IF NOT EXISTS native ON TABLE city
    TYPE option<string>
    COMMENT 'Nom de la ville dans sa langue native.';

-- Coordonnées géographiques (Point GeoJSON)
DEFINE FIELD IF NOT EXISTS location ON TABLE city
    TYPE point
    COMMENT 'Coordonnées géographiques de la ville (longitude, latitude).';

-- Frontières (Polygon GeoJSON pour usage futur)
DEFINE FIELD IF NOT EXISTS boundary ON TABLE city
    TYPE option<geometry<polygon>>
    COMMENT 'Frontières géographiques de la ville (polygone GeoJSON).';

-- Fuseau horaire
DEFINE FIELD IF NOT EXISTS timezone ON TABLE city
    TYPE option<record<timezone>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Fuseau horaire de la ville.';

-- WikiData ID
DEFINE FIELD IF NOT EXISTS wikiDataId ON TABLE city
    TYPE option<string>
    COMMENT 'Identifiant WikiData de la ville.';

-- Statut d'activité
DEFINE FIELD IF NOT EXISTS isActive ON TABLE city
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si la ville est actuellement utilisée ou visible.';

-- ------------------------------
-- INDEX
-- ------------------------------

-- Index pour permettre une recherche rapide des villes par état
DEFINE INDEX IF NOT EXISTS idx_city_state
    ON TABLE city
    FIELDS state;
