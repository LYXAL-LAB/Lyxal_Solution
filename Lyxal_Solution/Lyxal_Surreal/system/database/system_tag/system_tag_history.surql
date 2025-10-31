-- =============================================================================
-- TABLE: system_tag_history
-- =============================================================================
-- DESCRIPTION: Historique des tags
--
-- Fonctions à implémenter prochainement :
-- - fn::system_tag_history_log_event_system($action, $tag_id, $target_table, $target_id, $changed_fields, $old_value, $new_value, $reason)
-- - fn::system_tag_history_log_event($action, $tag_id, $target_table, $target_id, $changed_fields, $old_value, $new_value, $reason)
--   Enregistrer un événement d'historique (création, mise à jour, suppression, attach/detach).
-- - fn::system_tag_get_usage_stats_system($tag_id) / fn::system_tag_get_usage_stats($tag_id)
--   Retourner stats d'usage: totaux attach/detach, dernière utilisation, cibles principales.
-- - fn::system_tag_history_list_for_tag_system($tag_id) / fn::system_tag_history_list_for_tag($tag_id)
--   Lister l'historique lié à un tag.
-- - fn::system_tag_history_list_for_target_system($target_table, $target_id) / fn::system_tag_history_list_for_target($target_table, $target_id)
--   Lister l'historique pour une cible donnée.
--
-- ENREGISTREMENTS MODIFIES:
-- Quand a été modifié
-- Ancienne/nouvelle valeur
-- Raison du changement
-- Utilisateur
-- Session
-- Action
-- Table
-- ID
-- Fields modifiés
--
-- Audit d'utilisation :
-- Fonctionnalités** :
-- Nombre d'utilisations par tag
-- Dernière utilisation
-- Records associés
-- **Fonction** : `fn::system_tag_get_usage_stats($tag_id)`
-- =============================================================================
DEFINE TABLE IF NOT EXISTS system_tag_history TYPE NORMAL SCHEMAFULL
COMMENT 'Historique des tags'
PERMISSIONS
  FOR select WHERE array::contains($auth.permissions, 'lyxal_admin') OR array::contains($auth.permissions, 'lyxal_system'),
  FOR create WHERE array::contains($auth.permissions, 'lyxal_admin') OR array::contains($auth.permissions, 'lyxal_system'),
  FOR update WHERE array::contains($auth.permissions, 'lyxal_admin') OR array::contains($auth.permissions, 'lyxal_system'),
  FOR delete WHERE array::contains($auth.permissions, 'lyxal_admin') OR array::contains($auth.permissions, 'lyxal_system');

-- -----------------------------------------------------------------------------
-- Références
-- -----------------------------------------------------------------------------
DEFINE FIELD IF NOT EXISTS tag ON system_tag_history
TYPE record<system_tag>
VALUE type::thing('system_tag', $value)
REFERENCE ON DELETE REJECT
COMMENT "Tag concerné par l’événement";

-- Cible (record sur lequel le tag a eu un impact: objet métier, etc.)
DEFINE FIELD IF NOT EXISTS target_table ON system_tag_history
TYPE option<string>
COMMENT "Nom de la table cible (si applicable)";

DEFINE FIELD IF NOT EXISTS target_id ON system_tag_history
TYPE option<string>
COMMENT "ID de l\'enregistrement cible (string thing::id)";

-- -----------------------------------------------------------------------------
-- Détails d\'événement
-- -----------------------------------------------------------------------------
DEFINE FIELD IF NOT EXISTS action ON system_tag_history
TYPE string
ASSERT array::contains(['create','update','delete','attach','detach'], $value)
COMMENT "Action effectuée";

DEFINE FIELD IF NOT EXISTS changed_fields ON system_tag_history
TYPE option<array<string>>
COMMENT "Champs modifiés (si update)";

DEFINE FIELD IF NOT EXISTS old_value ON system_tag_history
TYPE option<object>
COMMENT "Anciennes valeurs pertinentes";

DEFINE FIELD IF NOT EXISTS new_value ON system_tag_history
TYPE option<object>
COMMENT "Nouvelles valeurs pertinentes";

DEFINE FIELD IF NOT EXISTS reason ON system_tag_history
TYPE option<string>
ASSERT string::len($value) <= 500
COMMENT "Raison du changement (facultatif)";

-- -----------------------------------------------------------------------------
-- Audit
-- -----------------------------------------------------------------------------
DEFINE FIELD IF NOT EXISTS created_at ON system_tag_history
TYPE datetime
VALUE time::now()
COMMENT "Date de création de l\'événement";

DEFINE FIELD IF NOT EXISTS created_by ON system_tag_history
TYPE option<record<base_user>>
VALUE IF $value != NONE THEN type::thing('base_user', $value) ELSE NONE END
REFERENCE ON DELETE REJECT
COMMENT "Utilisateur à l’origine de l’événement";

DEFINE FIELD IF NOT EXISTS updated_at ON system_tag_history
TYPE datetime
VALUE time::now()
COMMENT "Date de mise à jour";

DEFINE FIELD IF NOT EXISTS updated_by ON system_tag_history
TYPE option<record<base_user>>
VALUE IF $value != NONE THEN type::thing('base_user', $value) ELSE NONE END
REFERENCE ON DELETE REJECT
COMMENT "Dernier utilisateur à l\'avoir modifié";

DEFINE FIELD IF NOT EXISTS etag ON system_tag_history
TYPE int
DEFAULT 1
COMMENT "Contrôle optimiste (version)";

DEFINE FIELD IF NOT EXISTS payload ON system_tag_history
FLEXIBLE
TYPE option<object>
DEFAULT {}
COMMENT "Données additionnelles spécifiques au cas";

-- -----------------------------------------------------------------------------
-- Index
-- -----------------------------------------------------------------------------
DEFINE INDEX IF NOT EXISTS idx_tag_history_tag ON system_tag_history 
FIELDS tag
COMMENT "Index sur le tag concerné par l\'événement";

DEFINE INDEX IF NOT EXISTS idx_tag_history_target ON system_tag_history
FIELDS target_table, target_id
COMMENT "Index sur la table et l\'ID de l\'enregistrement cible";

DEFINE INDEX IF NOT EXISTS idx_tag_history_action ON system_tag_history
FIELDS action
COMMENT "Index sur l\'action effectuée";

DEFINE INDEX IF NOT EXISTS idx_tag_history_created_at ON system_tag_history
FIELDS created_at
COMMENT "Index sur la date de création de l\'événement";