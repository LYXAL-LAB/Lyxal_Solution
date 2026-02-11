-- ============================================================================
-- TABLE : css_framework_mapping
-- Description : Mappings des éléments CSS vers les frameworks (comme icon_mapping)
-- Module : studio/css_mapping
-- ============================================================================

DEFINE TABLE IF NOT EXISTS css_framework_mapping TYPE RELATION IN css_dictionary OUT css_framework ENFORCED SCHEMAFULL
COMMENT 'Mappings relationnels élément CSS ↔ framework (many-to-many)'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC MAPPING : Traduction vers le framework
-- ============================================================================

-- Note: Les champs de relation (css_element et framework) sont automatiquement
-- créés par SurrealDB grâce à TYPE RELATION IN css_dictionary OUT css_framework

DEFINE FIELD IF NOT EXISTS mapping ON TABLE css_framework_mapping
    TYPE object
    COMMENT 'Bloc mapping : traduction de l\'élément vers le framework';

DEFINE FIELD IF NOT EXISTS mapping.classes ON TABLE css_framework_mapping
    TYPE array<string>
    DEFAULT []
    COMMENT 'Classes du framework équivalentes : ["btn", "btn-primary"] pour Bootstrap';

DEFINE FIELD IF NOT EXISTS mapping.custom_css ON TABLE css_framework_mapping
    TYPE option<string>
    COMMENT 'CSS personnalisé complémentaire (variables CSS, styles spécifiques)';

DEFINE FIELD IF NOT EXISTS mapping.responsive_overrides ON TABLE css_framework_mapping
    TYPE option<object>
    COMMENT 'Overrides responsive spécifiques au framework';

-- ============================================================================
-- BLOC MÉTADONNÉES : Gestion des mappings
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE css_framework_mapping
    TYPE object
    COMMENT 'Bloc métadonnées : informations sur le mapping';

DEFINE FIELD IF NOT EXISTS metadata.priority ON TABLE css_framework_mapping
    TYPE int
    DEFAULT 1
    COMMENT 'Priorité du mapping (pour gérer les conflits)';

DEFINE FIELD IF NOT EXISTS metadata.version ON TABLE css_framework_mapping
    TYPE string
    DEFAULT '1.0.0'
    COMMENT 'Version du mapping : 1.0.0, 2.1.3, etc.';

DEFINE FIELD IF NOT EXISTS metadata.compatibility_notes ON TABLE css_framework_mapping
    TYPE option<string>
    COMMENT 'Notes sur la compatibilité ou limitations';

    DEFINE FIELD IF NOT EXISTS metadata.author_user_id ON TABLE css_framework_mapping
        TYPE option<record<identity>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Utilisateur créateur du mapping (si custom)';

DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE css_framework_mapping
    TYPE datetime
    DEFAULT time::now()
    COMMENT 'Date de création';

DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE css_framework_mapping
    TYPE datetime
    DEFAULT ALWAYS time::now()
    COMMENT 'Date de dernière modification';

-- ============================================================================
-- ETAG : Optimistic locking (optionnel pour relations)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS etag ON TABLE css_framework_mapping
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (généré automatiquement)';

-- ============================================================================
-- INDEXES POUR PERFORMANCES
-- ============================================================================

-- Note: Les indexes sur les relations sont automatiquement créés par SurrealDB
-- pour TYPE RELATION IN css_dictionary OUT css_framework ENFORCED


-- ============================================================================
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- Mapping bouton primaire vers Tailwind
-- RELATE css_dictionary:primary_button -> css_framework_mapping -> css_framework:tailwind
-- SET mapping = {
--   classes = ["inline-flex", "items-center", "justify-center", "px-4", "py-2", "bg-blue-500", "text-white", "rounded", "font-medium"],
--   custom_css = "transition: all 0.2s ease; &:hover { background: var(--color-primary-hover); }"
-- },
-- metadata = { priority = 1 };

-- Mapping bouton primaire vers Bootstrap
-- RELATE css_dictionary:primary_button -> css_framework_mapping -> css_framework:bootstrap
-- SET mapping = {
--   classes = ["btn", "btn-primary"],
--   custom_css = "font-weight: 500; transition: all 0.2s ease;"
-- },
-- metadata = { priority = 1 };

-- Mapping champ input vers Material Design
-- RELATE css_dictionary:input_field -> css_framework_mapping -> css_framework:material
-- SET mapping = {
--   classes = ["mdc-text-field", "mdc-text-field--outlined"],
--   custom_css = ".mdc-text-field__input { padding: 16px 14px; }"
-- },
-- metadata = { priority = 1 };
