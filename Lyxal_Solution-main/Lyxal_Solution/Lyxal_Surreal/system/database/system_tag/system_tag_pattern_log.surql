-- =============================================================================
-- TABLE: system_tag_pattern_log
-- =============================================================================
-- RÔLE
--   Table de journalisation des opérations sur system_tag_pattern.
--   Capture les succès et les erreurs pour audit et monitoring.
-- =============================================================================
DEFINE TABLE IF NOT EXISTS system_tag_pattern_log TYPE NORMAL SCHEMAFULL
  COMMENT 'Logs des opérations sur les patterns de tags'
  PERMISSIONS
    FOR SELECT, CREATE
      WHERE array::contains($auth.permissions, 'lyxal_admin')
        OR array::contains($auth.permissions, 'lyxal_system')
    FOR UPDATE, DELETE
      WHERE array::contains($auth.permissions, 'lyxal_admin');

-- Champs principaux
DEFINE FIELD IF NOT EXISTS action ON system_tag_pattern_log
  TYPE string
  ASSERT string::len($value) > 0
  COMMENT 'Action effectuée (create, update, delete, get, list, etc.)';

DEFINE FIELD IF NOT EXISTS success ON system_tag_pattern_log
  TYPE bool
  DEFAULT false
  COMMENT 'Succès ou échec de l\'opération';

DEFINE FIELD IF NOT EXISTS reason_code ON system_tag_pattern_log
  TYPE record<system_error_code>
  REFERENCE ON DELETE REJECT
  VALUE type::thing('system_error_code', $value)
  COMMENT 'Code de retour (OK, NAME_REQUIRED, NOT_FOUND, etc.)';

DEFINE FIELD IF NOT EXISTS severity ON system_tag_pattern_log
  TYPE string
  DEFAULT 'info'
  ASSERT $value IN ['info', 'warning', 'error']
  COMMENT 'Niveau de sévérité du log';

DEFINE FIELD IF NOT EXISTS run_id ON system_tag_pattern_log
  TYPE string
  ASSERT string::len($value) > 0
  COMMENT 'UUID unique de l\'exécution';

-- Champs de contexte
DEFINE FIELD IF NOT EXISTS resource_id ON system_tag_pattern_log
  TYPE option<record<system_tag_pattern>>
  REFERENCE ON DELETE REJECT
  VALUE IF $value != NONE THEN type::thing('system_tag_pattern', $value) ELSE NONE END
  COMMENT 'ID ou nom de la ressource concernée';

DEFINE FIELD IF NOT EXISTS message_key ON system_tag_pattern_log
  TYPE option<record<i18n_key>>
  REFERENCE ON DELETE REJECT
  VALUE IF $value != NONE THEN type::thing('i18n_key', $value) ELSE NONE END
  COMMENT 'Clé i18n du message';

DEFINE FIELD IF NOT EXISTS message_vars ON system_tag_pattern_log
  FLEXIBLE
  TYPE option<object>
  DEFAULT {}
  COMMENT 'Variables pour le message i18n';

DEFINE FIELD IF NOT EXISTS user_id ON system_tag_pattern_log
  TYPE option<record<base_user>>
  REFERENCE ON DELETE REJECT
  VALUE IF $value != NONE THEN type::thing('base_user', $value) ELSE NONE END
  COMMENT 'Utilisateur ayant effectué l\'action';

-- Métadonnées optionnelles
DEFINE FIELD IF NOT EXISTS meta ON system_tag_pattern_log
  FLEXIBLE
  TYPE option<object>
  COMMENT 'Métadonnées (pagination, filtres, etc.)';

DEFINE FIELD IF NOT EXISTS data ON system_tag_pattern_log
  FLEXIBLE
  TYPE option<object>
  COMMENT 'Données additionnelles de validation';

-- Timestamp
DEFINE FIELD IF NOT EXISTS timestamp ON system_tag_pattern_log
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Horodatage de l\'entrée';

-- Index pour les requêtes fréquentes
DEFINE INDEX IF NOT EXISTS idx_pattern_log_timestamp 
  ON system_tag_pattern_log 
  FIELDS timestamp DESC
  COMMENT 'Index pour trier par date';

DEFINE INDEX IF NOT EXISTS idx_pattern_log_action 
  ON system_tag_pattern_log 
  FIELDS action
  COMMENT 'Index pour filtrer par action';

DEFINE INDEX IF NOT EXISTS idx_pattern_log_success 
  ON system_tag_pattern_log 
  FIELDS success
  COMMENT 'Index pour filtrer succès/échecs';

DEFINE INDEX IF NOT EXISTS idx_pattern_log_severity 
  ON system_tag_pattern_log 
  FIELDS severity
  COMMENT 'Index pour filtrer par sévérité';

DEFINE INDEX IF NOT EXISTS idx_pattern_log_user 
  ON system_tag_pattern_log 
  FIELDS user_id
  COMMENT 'Index pour filtrer par utilisateur';