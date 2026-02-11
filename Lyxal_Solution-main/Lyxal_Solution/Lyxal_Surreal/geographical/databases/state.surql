-- =============================================================================================
-- |
-- | Fichier     : state.surql
-- | Module      : geographical
-- | Description : Définit la table `state` qui contient les subdivisions administratives
-- |               (états, régions, départements, provinces, etc.).
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS state
    TYPE NORMAL
    SCHEMAFULL
    COMMENT 'Référentiel des subdivisions administratives (états, régions, départements).'
    PERMISSIONS
        FOR select FULL;

-- ------------------------------
-- CHAMPS
-- ------------------------------

-- Pays parent
DEFINE FIELD IF NOT EXISTS country ON TABLE state
    TYPE record<country>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence au pays auquel la subdivision appartient.';

-- Clé i18n pour le nom traduisible
DEFINE FIELD IF NOT EXISTS key.name ON TABLE state
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n pour le nom de la subdivision.';

-- Code unique de la subdivision (par rapport à son pays)
DEFINE FIELD IF NOT EXISTS code ON TABLE state
    TYPE string
    COMMENT 'Code de la subdivision (ex: "BDS" pour Badakhshan).';

-- Type de subdivision
DEFINE FIELD IF NOT EXISTS type ON TABLE state
    TYPE option<record<state_type>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Type de subdivision (référence à state_type).';

-- Coordonnées géographiques (Point GeoJSON)
DEFINE FIELD IF NOT EXISTS location ON TABLE state
    TYPE point
    COMMENT 'Coordonnées géographiques du centre de la subdivision (longitude, latitude).';

-- Frontières (Polygon GeoJSON pour usage futur)
DEFINE FIELD IF NOT EXISTS boundary ON TABLE state
    TYPE option<geometry<polygon>>
    COMMENT 'Frontières géographiques de la subdivision (polygone GeoJSON).';

-- Niveau hiérarchique
DEFINE FIELD IF NOT EXISTS level ON TABLE state
    TYPE option<number>
    COMMENT 'Niveau de la subdivision dans la hiérarchie administrative (ex: 1 pour une région, 2 pour un département).';

-- Fuseau horaire
DEFINE FIELD IF NOT EXISTS timezone ON TABLE state
    TYPE record<timezone>
    REFERENCE ON DELETE REJECT
    COMMENT 'Fuseau horaire principal de la subdivision.';

-- Statut d'activité
DEFINE FIELD IF NOT EXISTS isActive ON TABLE state
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si la subdivision est actuellement utilisée ou visible.';

-- ------------------------------
-- INDEX
-- ------------------------------

-- Index pour assurer l'unicité du code de subdivision au sein d'un même pays
DEFINE INDEX IF NOT EXISTS idx_state_country_code_unique
    ON TABLE state
    FIELDS country, code UNIQUE;
