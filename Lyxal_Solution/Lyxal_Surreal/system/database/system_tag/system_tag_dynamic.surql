-- =============================================================================
-- TABLE: system_tag_dynamic
-- =============================================================================
-- DESCRIPTION: Configuration et état d’exécution des tags dynamiques
-- 
-- Fonctions à implémenter prochainement :
-- - fn::system_tag_dynamic_evaluate_system($tag_id) / fn::system_tag_dynamic_evaluate($tag_id)
--   Évaluer la règle d’un tag donné et appliquer attach/detach selon mode.
-- - fn::system_tag_dynamic_run_scheduler_system() / fn::system_tag_dynamic_run_scheduler()
--   Exécuter les tags dynamiques planifiés (schedule) et journaliser.
-- - fn::system_tag_dynamic_enable_system($tag_id, $state) / fn::system_tag_dynamic_enable($tag_id, $state)
--   Activer/désactiver une règle dynamique.
-- - fn::system_tag_dynamic_update_rule_system($tag_id, $rule) / fn::system_tag_dynamic_update_rule($tag_id, $rule)
--   Mettre à jour la règle (avec validations et logs).
-- =============================================================================
DEFINE TABLE IF NOT EXISTS system_tag_dynamic TYPE NORMAL SCHEMAFULL
COMMENT 'Config des tags dynamiques'
PERMISSIONS
  FOR select, create, update, delete
  WHERE array::contains($auth.permissions, 'lyxal_admin') OR array::contains($auth.permissions, 'lyxal_system');

-- Liaison (1–1) avec le tag cible
DEFINE FIELD IF NOT EXISTS tag ON system_tag_dynamic
TYPE record<system_tag>
VALUE type::thing('system_tag', $value)
REFERENCE ON DELETE REJECT
COMMENT 'Tag concerné (unique)';

-- Activation
DEFINE FIELD IF NOT EXISTS is_enabled ON system_tag_dynamic
TYPE bool
DEFAULT true
COMMENT 'Active la règle dynamique';

-- Règle (structure à définir: conditions, sources, mapping)
DEFINE FIELD IF NOT EXISTS rule ON system_tag_dynamic
TYPE object
COMMENT 'Règle de génération/association';

-- Mode d’application
DEFINE FIELD IF NOT EXISTS mode ON system_tag_dynamic
TYPE string
ASSERT array::contains(['attach_only','attach_and_detach'], $value)
COMMENT 'Détacher automatiquement si la règle n’est plus vraie ?';

-- Planification (optionnel)
DEFINE FIELD IF NOT EXISTS schedule ON system_tag_dynamic
TYPE option<string>
COMMENT 'Expression de planification (cron ou autre)';

-- État d’évaluation
DEFINE FIELD IF NOT EXISTS last_evaluated_at ON system_tag_dynamic
TYPE option<datetime>
COMMENT 'Dernière évaluation';

DEFINE FIELD IF NOT EXISTS last_evaluation_status ON system_tag_dynamic
TYPE option<string>
ASSERT $value = NONE OR array::contains(['success','error'], $value)
COMMENT 'Statut de la dernière évaluation';

DEFINE FIELD IF NOT EXISTS last_evaluation_error ON system_tag_dynamic
TYPE option<string>
ASSERT string::len($value) <= 500
COMMENT 'Message d’erreur (si échec)';

-- Audit / technique
DEFINE FIELD IF NOT EXISTS etag ON system_tag_dynamic TYPE int DEFAULT 1;
DEFINE FIELD IF NOT EXISTS created_at ON system_tag_dynamic TYPE datetime VALUE time::now();
DEFINE FIELD IF NOT EXISTS updated_at ON system_tag_dynamic TYPE datetime VALUE time::now();
DEFINE FIELD IF NOT EXISTS created_by ON system_tag_dynamic TYPE option<record<base_user>> VALUE IF $value != NONE THEN type::thing('base_user', $value) ELSE NONE END REFERENCE ON DELETE REJECT;
DEFINE FIELD IF NOT EXISTS updated_by ON system_tag_dynamic TYPE option<record<base_user>> VALUE IF $value != NONE THEN type::thing('base_user', $value) ELSE NONE END REFERENCE ON DELETE REJECT;
DEFINE FIELD IF NOT EXISTS payload ON system_tag_dynamic FLEXIBLE TYPE option<object> DEFAULT {};

-- Index
DEFINE INDEX IF NOT EXISTS idx_tag_dynamic_tag_unique ON system_tag_dynamic FIELDS tag UNIQUE;
DEFINE INDEX IF NOT EXISTS idx_tag_dynamic_enabled ON system_tag_dynamic FIELDS is_enabled;
DEFINE INDEX IF NOT EXISTS idx_tag_dynamic_schedule ON system_tag_dynamic FIELDS schedule;
DEFINE INDEX IF NOT EXISTS idx_tag_dynamic_last_eval ON system_tag_dynamic FIELDS last_evaluated_at;


