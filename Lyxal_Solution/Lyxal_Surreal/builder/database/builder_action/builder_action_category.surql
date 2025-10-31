-- =============================================================================
-- TABLE: builder_action_category
-- =============================================================================
-- RÔLE
--   Dictionnaire des catégories d'actions du module builder (ex: crud, read, relation, io, validate, rule)
--   Permet d'éviter les valeurs libres et de fournir i18n + tri + activation.
--
-- FONCTIONS À IMPLÉMENTER PROCHAINEMENT (commentées pour reprise ultérieure)
--   - fn::builder_action_category_create($code, $key, $description_key, $sort_order, $is_active, $metadata, $payload, $created_by)
--   - fn::builder_action_category_get($code)
--   - fn::builder_action_category_list($only_active)
--   - fn::builder_action_category_delete($code)
--
-- SEED MINIMAL (commenté - à rejouer plus tard)
--   -- Catégories standard
--   -- CREATE builder_action_category SET code='crud',        key='builder.category.crud',        sort_order=10;
--   -- CREATE builder_action_category SET code='read',        key='builder.category.read',        sort_order=20;
--   -- CREATE builder_action_category SET code='relation',    key='builder.category.relation',    sort_order=30;
--   -- CREATE builder_action_category SET code='io',          key='builder.category.io',          sort_order=40;
--   -- CREATE builder_action_category SET code='validate',    key='builder.category.validate',    sort_order=50;
--   -- CREATE builder_action_category SET code='rule',        key='builder.category.rule',        sort_order=60;
-- =============================================================================

DEFINE TABLE IF NOT EXISTS builder_action_category TYPE NORMAL SCHEMAFULL
  COMMENT 'Catégories d\'actions pour le module builder'
  PERMISSIONS
    FOR CREATE, DELETE, UPDATE, SELECT
      WHERE $auth.permissions= 'lyxal_admin'
        OR $auth.permissions= 'lyxal_system';

DEFINE FIELD IF NOT EXISTS key ON builder_action_category
  TYPE record<builder_i18n_key>
  REFERENCE ON DELETE REJECT
  VALUE type::thing('builder_i18n_key', $value)
  COMMENT 'Clé i18n du libellé de la catégorie';

DEFINE FIELD IF NOT EXISTS description ON builder_action_category
  TYPE option<record<builder_i18n_key>>
  REFERENCE ON DELETE REJECT
  VALUE {
    IF $value != NONE { type::thing('builder_i18n_key', $value) }
    ELSE { NONE }
  }
  COMMENT 'Clé i18n de description (optionnelle)';

DEFINE FIELD IF NOT EXISTS is_active ON builder_action_category
  TYPE bool
  DEFAULT true
  COMMENT 'Catégorie activée/désactivée';

DEFINE FIELD IF NOT EXISTS metadata ON builder_action_category
  FLEXIBLE
  TYPE option<object>
  DEFAULT {}
  COMMENT 'Métadonnées libres (ex: portée, icône)';

DEFINE FIELD IF NOT EXISTS payload ON builder_action_category
  FLEXIBLE
  TYPE option<object>
  DEFAULT {}
  COMMENT 'Données complémentaires';

DEFINE FIELD IF NOT EXISTS created_at ON builder_action_category
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de création';

DEFINE FIELD IF NOT EXISTS created_by ON builder_action_category
  TYPE option<record<base_user>>
  VALUE {
    IF $value != NONE { type::thing('base_user', $value) }
    ELSE { NONE }
  }
  REFERENCE ON DELETE REJECT
  COMMENT 'Créateur (optionnel)';

DEFINE FIELD IF NOT EXISTS etag ON builder_action_category
  TYPE int
  DEFAULT 1
  COMMENT 'Contrôle optimiste (version)';

-- Indexes

DEFINE INDEX IF NOT EXISTS idx_builder_action_category_active ON builder_action_category
  FIELDS is_active
  COMMENT 'Filtrage par activation';

DEFINE INDEX IF NOT EXISTS idx_builder_action_category_created_at ON builder_action_category
  FIELDS created_at
  COMMENT 'Tri par date de création';
