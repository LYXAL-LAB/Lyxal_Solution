-- =============================================================================
-- TABLE: system_tag_pattern_log_archive
-- =============================================================================
-- RÔLE
--   Table d'archive pour les vieux logs de system_tag_pattern.
--   Conserve l'historique complet pour audit à long terme.
-- =============================================================================
DEFINE TABLE IF NOT EXISTS system_tag_pattern_log_archive TYPE NORMAL SCHEMAFULL
  COMMENT 'Archive des logs de system_tag_pattern'
  PERMISSIONS
    FOR SELECT
      WHERE array::contains($auth.permissions, 'lyxal_admin')
        OR array::contains($auth.permissions, 'lyxal_system')
    FOR CREATE
      WHERE array::contains($auth.permissions, 'lyxal_system')
    FOR UPDATE, DELETE
      WHERE array::contains($auth.permissions, 'lyxal_admin');

-- Référence à l'ID original
DEFINE FIELD IF NOT EXISTS original_id ON system_tag_pattern_log_archive
  TYPE string
  ASSERT string::len($value) > 0
  COMMENT 'ID original dans la table de log principale';

-- Champs copiés de la table principale
DEFINE FIELD IF NOT EXISTS action ON system_tag_pattern_log_archive
  TYPE string
  ASSERT string::len($value) > 0
  COMMENT 'Action effectuée';

DEFINE FIELD IF NOT EXISTS success ON system_tag_pattern_log_archive
  TYPE bool
  DEFAULT false
  COMMENT 'Succès ou échec';

DEFINE FIELD IF NOT EXISTS reason_code ON system_tag_pattern_log_archive
  TYPE record<system_error_code>
  REFERENCE ON DELETE REJECT
  VALUE type::thing('system_error_code', $value)
  COMMENT 'Code de retour';

DEFINE FIELD IF NOT EXISTS severity ON system_tag_pattern_log_archive
  TYPE string
  DEFAULT 'info'
  COMMENT 'Niveau de sévérité';

DEFINE FIELD IF NOT EXISTS run_id ON system_tag_pattern_log_archive
  TYPE string
  COMMENT 'UUID de l\'exécution';

DEFINE FIELD IF NOT EXISTS resource_id ON system_tag_pattern_log_archive
  TYPE option<record<system_tag_pattern>>
  REFERENCE ON DELETE REJECT
  VALUE IF $value != NONE THEN type::thing('system_tag_pattern', $value) ELSE NONE END
  COMMENT 'ID de la ressource';

DEFINE FIELD IF NOT EXISTS message_key ON system_tag_pattern_log_archive
  TYPE option<record<i18n_key>>
  REFERENCE ON DELETE REJECT
  VALUE IF $value != NONE THEN type::thing('i18n_key', $value) ELSE NONE END
  COMMENT 'Clé i18n';

DEFINE FIELD IF NOT EXISTS message_vars ON system_tag_pattern_log_archive
  FLEXIBLE
  TYPE option<object>
  DEFAULT {}
  COMMENT 'Variables i18n';

DEFINE FIELD IF NOT EXISTS user_id ON system_tag_pattern_log_archive
  TYPE option<record<base_user>>
  REFERENCE ON DELETE REJECT
  VALUE IF $value != NONE THEN type::thing('base_user', $value) ELSE NONE END
  COMMENT 'ID utilisateur (pas de référence pour éviter les contraintes)';

DEFINE FIELD IF NOT EXISTS meta ON system_tag_pattern_log_archive
  FLEXIBLE
  TYPE option<object>
  COMMENT 'Métadonnées';

DEFINE FIELD IF NOT EXISTS data ON system_tag_pattern_log_archive
  FLEXIBLE
  TYPE option<object>
  COMMENT 'Données additionnelles';

-- Timestamps
DEFINE FIELD IF NOT EXISTS timestamp ON system_tag_pattern_log_archive
  TYPE datetime
  COMMENT 'Timestamp original du log';

DEFINE FIELD IF NOT EXISTS archived_at ON system_tag_pattern_log_archive
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date d\'archivage';

-- Index pour les requêtes
DEFINE INDEX IF NOT EXISTS idx_archive_timestamp 
  ON system_tag_pattern_log_archive 
  FIELDS timestamp DESC
  COMMENT 'Index sur la date originale';

DEFINE INDEX IF NOT EXISTS idx_archive_archived_at 
  ON system_tag_pattern_log_archive 
  FIELDS archived_at DESC
  COMMENT 'Index sur la date d\'archivage';