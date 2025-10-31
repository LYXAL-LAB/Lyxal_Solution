-- =============================================================================
-- TABLE: builder_action
-- =============================================================================
-- RÔLE
--   Registre des actions possibles dans le module builder (pour logs, stats, UI)
--   Évite les valeurs libres pour 'action' et permet i18n + catégorisation.
--
-- FONCTIONS À IMPLÉMENTER PROCHAINEMENT (commentées pour reprise ultérieure)
--   - fn::builder_action_create($code, $key, $description_key, $category, $severity, $is_active, $metadata, $payload, $created_by)
--   - fn::builder_action_get($code)
--   - fn::builder_action_list($only_active)
--   - fn::builder_action_delete($code)
--
-- SEED MINIMAL (commenté - à rejouer plus tard)
--   -- CRUD
--   -- CREATE builder_action SET code='CREATE', key='builder.action.create', category='crud', severity='info';
--   -- CREATE builder_action SET code='UPDATE', key='builder.action.update', category='crud', severity='info';
--   -- CREATE builder_action SET code='DELETE', key='builder.action.delete', category='crud', severity='warning';
--   -- LIST/GET
--   -- CREATE builder_action SET code='GET', key='builder.action.get', category='read', severity='info';
--   -- CREATE builder_action SET code='LIST', key='builder.action.list', category='read', severity='info';
--   -- Spécifiques
--   -- CREATE builder_action SET code='ATTACH', key='builder.action.attach', category='relation', severity='info';
--   -- CREATE builder_action SET code='DETACH', key='builder.action.detach', category='relation', severity='info';
--   -- CREATE builder_action SET code='SET_EXCLUSIVE', key='builder.action.set_exclusive', category='rule', severity='info';
--   -- CREATE builder_action SET code='IMPORT', key='builder.action.import', category='io', severity='info';
--   -- CREATE builder_action SET code='EXPORT', key='builder.action.export', category='io', severity='info';
--   -- CREATE builder_action SET code='VALIDATE', key='builder.action.validate', category='validate', severity='info';
-- =============================================================================

DEFINE TABLE IF NOT EXISTS builder_action TYPE NORMAL SCHEMAFULL
  COMMENT 'Dictionnaire des actions du module builder'
  PERMISSIONS
    FOR CREATE, DELETE, UPDATE, SELECT
      WHERE $auth.permissions= 'lyxal_admin'
        OR $auth.permissions= 'lyxal_system';

DEFINE FIELD IF NOT EXISTS code ON builder_action
  TYPE string
  ASSERT string::len(string::trim($value)) > 0
  COMMENT 'Identifiant unique de l\'action (ex: CREATE, UPDATE, ... )';

DEFINE FIELD IF NOT EXISTS key ON builder_action
  TYPE record<builder_i18n_key>
  REFERENCE ON DELETE REJECT
  VALUE type::thing('builder_i18n_key', $value)
  COMMENT 'Clé i18n du libellé de l\'action';

DEFINE FIELD IF NOT EXISTS description ON builder_action
  TYPE option<record<builder_i18n_key>>
  REFERENCE ON DELETE REJECT
  VALUE {
    IF $value != NONE { type::thing('builder_i18n_key', $value) }
    ELSE { NONE }
  }
  COMMENT 'Clé i18n de description (optionnelle)';

DEFINE FIELD IF NOT EXISTS category ON builder_action   
  TYPE option<record<builder_action_category>>
  REFERENCE ON DELETE REJECT
  VALUE {
    IF $value != NONE { type::thing('builder_action_category', $value) }
    ELSE { NONE }
  }
  COMMENT 'Catégorie fonctionnelle (crud, read, relation, rule, io, validate, etc.)';

DEFINE FIELD IF NOT EXISTS severity ON builder_action
  TYPE string
  DEFAULT 'info'
  ASSERT $value IN ['info','warning','error','critical']
  COMMENT 'Sévérité par défaut pour cette action';

DEFINE FIELD IF NOT EXISTS is_active ON builder_action
  TYPE bool
  DEFAULT true
  COMMENT 'Action activée/désactivée';

DEFINE FIELD IF NOT EXISTS metadata ON builder_action
  FLEXIBLE
  TYPE option<object>
  DEFAULT {}
  COMMENT 'Métadonnées libres (ex: scopes, visibilité UI)';

DEFINE FIELD IF NOT EXISTS payload ON builder_action
  FLEXIBLE
  TYPE option<object>
  DEFAULT {}
  COMMENT 'Données complémentaires';

DEFINE FIELD IF NOT EXISTS language_id ON builder_action
  TYPE record<i18n_language>
  REFERENCE ON DELETE REJECT
  VALUE type::thing('i18n_language', $value)
  COMMENT 'Langue associée à l\'action';

DEFINE FIELD IF NOT EXISTS created_at ON builder_action
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de création';

DEFINE FIELD IF NOT EXISTS created_by ON builder_action
  TYPE option<record<base_user>>
  VALUE {
    IF $value != NONE { type::thing('base_user', $value) }
    ELSE { NONE }
  }
  REFERENCE ON DELETE REJECT
  COMMENT 'Créateur (optionnel)';

DEFINE FIELD IF NOT EXISTS updated_at ON builder_action
  TYPE datetime
  VALUE time::now()
  COMMENT 'Date de mise à jour';

-- Indexes de base
DEFINE INDEX IF NOT EXISTS idx_builder_action_code_unique ON builder_action
  FIELDS code UNIQUE
  COMMENT 'Unicité globale du code action';

DEFINE INDEX IF NOT EXISTS idx_builder_action_category ON builder_action
  FIELDS category
  COMMENT 'Filtrage par catégorie';

DEFINE INDEX IF NOT EXISTS idx_builder_action_severity ON builder_action
  FIELDS severity
  COMMENT 'Filtrage par sévérité';

DEFINE INDEX IF NOT EXISTS idx_builder_action_created_at ON builder_action
  FIELDS created_at
  COMMENT 'Tri par date de création';
