-- =============================================================================================
-- |
-- | Fichier     : i18n_thousand_separator.surql
-- | Module      : i18n
-- | Description : Définit la table `i18n_thousand_separator`, une énumération en lecture seule
-- |               pour les séparateurs de milliers (espace, virgule, point).
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS i18n_thousand_separator 
  TYPE NORMAL SCHEMAFULL 
  COMMENT 'Énumération des séparateurs de milliers' 
  PERMISSIONS 
    FOR select FULL;

  -- L'ID de l'enregistrement est un code descriptif, ex: i18n_thousand_separator:space

  DEFINE FIELD IF NOT EXISTS symbol ON TABLE i18n_thousand_separator 
  TYPE string
  ASSERT string::len($value) == 1
  COMMENT 'Le caractère du séparateur (ex: " ", ",", ".")';

  DEFINE INDEX IF NOT EXISTS idx_i18n_thousand_separator_symbol_unique 
  ON TABLE i18n_thousand_separator 
  FIELDS symbol UNIQUE;