-- =============================================================================================
-- |
-- | Fichier     : nationality.surql
-- | Module      : geographical
-- | Description : Définit la table `nationality` qui contient les gentilés (noms des
-- |               habitants d'un pays, ex: Français, Américain).
-- |
-- =============================================================================================

-- -----------------------------------------------------------------------------
-- | TABLE : nationality
-- -----------------------------------------------------------------------------
DEFINE TABLE IF NOT EXISTS nationality
    TYPE NORMAL
    SCHEMAFULL
    COMMENT 'Référentiel pour les gentilés (noms des habitants).'
    PERMISSIONS
        FOR select FULL;

-- -----------------------------------------------------------------------------
-- | CHAMPS
-- -----------------------------------------------------------------------------
DEFINE FIELD IF NOT EXISTS key.name ON TABLE nationality
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n pour le nom du gentilé.';
