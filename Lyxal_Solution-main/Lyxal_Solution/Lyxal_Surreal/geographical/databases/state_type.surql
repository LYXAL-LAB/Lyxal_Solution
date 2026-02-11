-- =============================================================================================
-- |
-- | Fichier     : state_type.surql
-- | Module      : geographical
-- | Description : Définit la table `state_type` qui contient les différents types de 
-- |               subdivisions administratives (ex: province, état, département).
-- |
-- =============================================================================================

-- -----------------------------------------------------------------------------
-- | TABLE : state_type
-- -----------------------------------------------------------------------------
DEFINE TABLE IF NOT EXISTS state_type
    TYPE NORMAL
    SCHEMAFULL
    COMMENT 'Référentiel pour les types de subdivisions administratives (état, province, etc.).'
    PERMISSIONS
        FOR select FULL;

-- -----------------------------------------------------------------------------
-- | CHAMPS
-- -----------------------------------------------------------------------------
DEFINE FIELD IF NOT EXISTS key.name ON TABLE state_type
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n pour le nom du type de subdivision.';
