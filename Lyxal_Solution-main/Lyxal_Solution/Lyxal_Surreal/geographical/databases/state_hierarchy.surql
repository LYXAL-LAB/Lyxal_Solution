-- =============================================================================================
-- |
-- | Fichier     : state_hierarchy.surql
-- | Module      : geographical
-- | Description : Définit la table de relation `state_hierarchy` pour lier les 
-- |               subdivisions administratives entre elles (parent-enfant).
-- |
-- =============================================================================================

-- -----------------------------------------------------------------------------
-- | TABLE : state_hierarchy
-- -----------------------------------------------------------------------------
DEFINE TABLE IF NOT EXISTS state_hierarchy
    TYPE RELATION
    SCHEMAFULL
    COMMENT 'Relation hiérarchique entre subdivisions (ex: un département est DANS une région).'
    PERMISSIONS
        FOR select FULL;
