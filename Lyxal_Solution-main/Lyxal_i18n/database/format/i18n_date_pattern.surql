-- =============================================================================================
-- |
-- | Fichier     : i18n_date_pattern.surql
-- | Module      : i18n
-- | Description : Définit la table `i18n_date_pattern`, une énumération en lecture seule
-- |               pour les formats de date CLDR (pattern + skeleton).
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS i18n_date_pattern 
  TYPE NORMAL SCHEMAFULL 
  COMMENT 'Énumération des formats de date CLDR (pattern + skeleton)'
  PERMISSIONS 
    FOR select FULL;

  DEFINE FIELD IF NOT EXISTS pattern ON TABLE i18n_date_pattern 
  TYPE string
  ASSERT string::len(string::trim($value)) > 0
  COMMENT 'Pattern de date (CLDR/UTS#35), ex: yyyy-MM-dd, dd/MM/yyyy';

  DEFINE FIELD IF NOT EXISTS skeleton ON TABLE i18n_date_pattern 
  TYPE option<string>
  COMMENT 'Skeleton CLDR (facultatif), ex: yMd, yMMMd';

  DEFINE FIELD IF NOT EXISTS key.name ON TABLE i18n_date_pattern 
  TYPE option<record<i18n_key>>
  COMMENT 'Clé i18n pour libellé (ex: Date (ISO), Date (EU))';

  DEFINE INDEX IF NOT EXISTS idx_i18n_date_pattern_unique 
  ON TABLE i18n_date_pattern 
  FIELDS pattern UNIQUE
  COMMENT 'Unicité du pattern';