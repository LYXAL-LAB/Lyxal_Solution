-- =============================================================================================
-- |
-- | Fichier     : i18n_time_notation.surql
-- | Module      : i18n
-- | Description : Définit la table `i18n_time_notation`, une énumération en lecture seule
-- |               pour les notations horaires (12h/24h).
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS i18n_time_notation 
  TYPE NORMAL SCHEMAFULL 
  COMMENT 'Énumération des notations horaires (12h/24h)'
  PERMISSIONS 
    FOR select FULL;

  -- Le code de la notation est l'ID de l'enregistrement, ex: i18n_time_notation:`12h`

  DEFINE FIELD IF NOT EXISTS key.name ON TABLE i18n_time_notation 
  TYPE option<record<i18n_key>>
  COMMENT 'Clé i18n pour le libellé (ex: "Format 12 heures")';