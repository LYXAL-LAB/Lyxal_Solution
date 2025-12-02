-- =============================================================================================
-- |
-- | Fichier     : i18n_week_start.surql
-- | Module      : i18n
-- | Description : Définit la table `i18n_week_start`, une énumération en lecture seule
-- |               pour le premier jour de la semaine (1=lundi .. 7=dimanche).
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS i18n_week_start 
  TYPE NORMAL SCHEMAFULL 
  COMMENT 'Énumération du 1er jour de semaine (1=lundi .. 7=dimanche)'
  PERMISSIONS 
    FOR select FULL;

  -- Le numéro du jour est l'ID de l'enregistrement, ex: i18n_week_start:1

  DEFINE FIELD IF NOT EXISTS key.name ON TABLE i18n_week_start 
  TYPE option<record<i18n_key>>
  COMMENT 'Clé i18n pour le nom du jour (ex: "Lundi")';