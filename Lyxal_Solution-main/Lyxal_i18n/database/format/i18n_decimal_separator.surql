-- =============================================================================================
-- |
-- | Fichier     : i18n_decimal_separator.surql
-- | Module      : i18n
-- | Description : Définit la table `i18n_decimal_separator`, une énumération en lecture seule
-- |               pour les séparateurs décimaux (virgule, point).
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS i18n_decimal_separator 
  TYPE NORMAL SCHEMAFULL 
  COMMENT 'Énumération des séparateurs décimaux' 
  PERMISSIONS 
    FOR select FULL;

  -- L'ID de l'enregistrement est un code descriptif, ex: i18n_decimal_separator:comma

  DEFINE FIELD IF NOT EXISTS symbol ON TABLE i18n_decimal_separator 
  TYPE string
  ASSERT string::len($value) == 1
  COMMENT 'Le caractère du séparateur (ex: ",", ".")';

  DEFINE INDEX IF NOT EXISTS idx_i18n_decimal_separator_symbol_unique 
  ON TABLE i18n_decimal_separator 
  FIELDS symbol UNIQUE;