-- =================================================================================================
-- |
-- | Fichier : app_configuration.surql
-- | Module : System / App
-- | Description : Ce fichier initialise la table `app_configuration` qui stockera
-- |              les paires clé-valeur pour la configuration de l'application.
-- |
-- =================================================================================================
DEFINE TABLE IF NOT EXISTS app_configuration TYPE NORMAL SCHEMAFULL
  COMMENT 'Configuration de l\'application'
  PERMISSIONS FULL;

-- Définition des champs
DEFINE FIELD IF NOT EXISTS log_configuration ON app_configuration TYPE object
  COMMENT 'Configuration des logs';
  
DEFINE FIELD IF NOT EXISTS log_configuration.enabled ON app_configuration TYPE bool DEFAULT true
  COMMENT 'Active ou désactive le logging';
  
DEFINE FIELD IF NOT EXISTS log_configuration.level ON app_configuration 
  TYPE record<error_severity> 
  DEFAULT error_severity:info
  COMMENT 'Niveau de verbosité minimum des logs';
  
-- Rétention "chaude" pour le passage de log -> log_archive
DEFINE FIELD IF NOT EXISTS log_configuration.hot_retention ON app_configuration TYPE object
  COMMENT 'Configuration de la rétention chaude (archivage)';
  
DEFINE FIELD IF NOT EXISTS log_configuration.hot_retention.unit ON app_configuration 
  TYPE string DEFAULT 'days'
  ASSERT $value IN ['days', 'weeks', 'months', 'years']
  COMMENT 'Unité de temps pour l\'archivage';
  
DEFINE FIELD IF NOT EXISTS log_configuration.hot_retention.value ON app_configuration 
  TYPE number DEFAULT 30
  COMMENT 'Valeur numérique pour l\'archivage';

-- Rétention "froide" pour la suppression depuis log_archive
DEFINE FIELD IF NOT EXISTS log_configuration.cold_retention ON app_configuration TYPE object
  COMMENT 'Configuration de la rétention froide (suppression définitive)';

DEFINE FIELD IF NOT EXISTS log_configuration.cold_retention.unit ON app_configuration 
  TYPE string DEFAULT 'days'
  ASSERT $value IN ['days', 'weeks', 'months', 'years']
  COMMENT 'Unité de temps pour la suppression';
  
DEFINE FIELD IF NOT EXISTS log_configuration.cold_retention.value ON app_configuration 
  TYPE number DEFAULT 365
  COMMENT 'Valeur numérique pour la suppression';

-- =================================================================================================
-- | Configuration des Assets
-- =================================================================================================

DEFINE FIELD IF NOT EXISTS asset_configuration ON app_configuration TYPE object
  COMMENT 'Configuration pour les ressources statiques (assets CDN).';

DEFINE FIELD IF NOT EXISTS asset_configuration.cdn_base_url ON app_configuration
  TYPE string
  DEFAULT "https://your-cdn.b-cdn.net"
  COMMENT 'URL de base du CDN où sont stockés les assets.';

-- Définition des index
-- (Aucun index pour le moment)