-- =============================================================================================
-- |
-- | Fichier     : i18n_time_pattern.surql
-- | Module      : i18n
-- | Description : Définit la table `i18n_time_pattern`, une énumération en lecture seule
-- |               pour les formats d'heure CLDR (pattern + skeleton).
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS i18n_time_pattern 
  TYPE NORMAL SCHEMAFULL 
  COMMENT 'Énumération des formats d\'heure CLDR (pattern + skeleton)'
  PERMISSIONS 
    FOR select FULL;

  DEFINE FIELD IF NOT EXISTS pattern ON TABLE i18n_time_pattern TYPE string
  ASSERT string::len(string::trim($value)) > 0
  COMMENT 'Pattern d\'heure (CLDR/UTS#35), ex: HH:mm, hh:mm a, HH:mm:ss';

  DEFINE FIELD IF NOT EXISTS skeleton ON TABLE i18n_time_pattern TYPE option<string>
  COMMENT 'Skeleton CLDR (facultatif), ex: Hm, Hms, hm';

  DEFINE FIELD IF NOT EXISTS key.name ON TABLE i18n_time_pattern TYPE option<record<i18n_key>>
  COMMENT 'Clé i18n pour libellé';

  DEFINE INDEX IF NOT EXISTS idx_i18n_time_pattern_unique ON TABLE i18n_time_pattern FIELDS pattern UNIQUE;