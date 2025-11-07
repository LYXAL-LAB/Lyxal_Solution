-- ============================================================================
-- TABLE : css_dictionary
-- Description : Dictionnaire des éléments CSS de base (comme icon_seeds)
-- Module : studio/css_mapping
-- ============================================================================

DEFINE TABLE IF NOT EXISTS css_dictionary TYPE NORMAL SCHEMAFULL
    COMMENT 'Dictionnaire des éléments CSS de base pour le système de mapping relationnel'
    PERMISSIONS FOR SELECT FULL
    FOR CREATE,UPDATE,DELETE NONE;


-- ============================================================================
-- BLOC IDENTITY : Identification unique de l'élément CSS
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE css_dictionary
    TYPE object
    COMMENT 'Bloc identité : identification unique de l\'élément CSS';

DEFINE FIELD IF NOT EXISTS identity.code ON TABLE css_dictionary
    TYPE string
    ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
    COMMENT 'Code technique unique : primary_button, input_field, card_container';

DEFINE FIELD IF NOT EXISTS identity.name ON TABLE css_dictionary
    TYPE string
    ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
    COMMENT 'Nom d\'affichage : Bouton Primaire, Champ de Saisie, Carte';

-- ============================================================================
-- BLOC METADATA : Métadonnées de l'élément CSS
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE css_dictionary
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

DEFINE FIELD IF NOT EXISTS metadata.category ON TABLE css_dictionary
    TYPE record<css_token_category>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence vers la catégorie (table css_token_category)';

DEFINE FIELD IF NOT EXISTS metadata.semantic_meaning ON TABLE css_dictionary
    TYPE record<css_token_subcategory>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence vers la sous-catégorie (table css_token_subcategory)';

DEFINE FIELD IF NOT EXISTS metadata.description ON TABLE css_dictionary
    TYPE option<string>
    COMMENT 'Description détaillée de l\'élément';

DEFINE FIELD IF NOT EXISTS metadata.version ON TABLE css_dictionary
    TYPE string
    DEFAULT '1.0.0'
    COMMENT 'Version de l\'élément CSS : 1.0.0, 2.1.3, etc.';

    DEFINE FIELD IF NOT EXISTS metadata.author_user_id ON TABLE css_dictionary
        TYPE option<record<identity>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Utilisateur créateur de l\'élément (si custom)';

DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE css_dictionary
    TYPE datetime
    DEFAULT time::now()
    COMMENT 'Date de création';

DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE css_dictionary
    TYPE datetime
    DEFAULT time::now()
    COMMENT 'Date de dernière modification';

-- ============================================================================
-- ETAG : Optimistic locking
-- ============================================================================

DEFINE FIELD IF NOT EXISTS etag ON TABLE css_dictionary
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (généré automatiquement)';

-- ============================================================================
-- BLOC STYLES : Définition des styles CSS de base
-- ============================================================================

DEFINE FIELD IF NOT EXISTS styles ON TABLE css_dictionary
    TYPE object
    COMMENT 'Bloc styles : définition CSS de base indépendante du framework';

DEFINE FIELD IF NOT EXISTS styles.base ON TABLE css_dictionary
    FLEXIBLE
    TYPE object
    COMMENT 'Styles CSS de base (display, position, etc.)';

DEFINE FIELD IF NOT EXISTS styles.interactions ON TABLE css_dictionary
    FLEXIBLE
    TYPE option<object>
    COMMENT 'Styles d\'interaction (hover, focus, active)';

DEFINE FIELD IF NOT EXISTS styles.states ON TABLE css_dictionary
    FLEXIBLE
    TYPE option<object>
    COMMENT 'Styles d\'états (disabled, loading, etc.)';

DEFINE FIELD IF NOT EXISTS styles.responsive ON TABLE css_dictionary
    FLEXIBLE
    TYPE option<object>
    COMMENT 'Styles responsive par breakpoint';

DEFINE FIELD IF NOT EXISTS styles.animations ON TABLE css_dictionary
    FLEXIBLE
    TYPE option<object>
    COMMENT 'Animations et transitions';

-- ============================================================================
-- BLOC COMPATIBILITY : Compatibilité frameworks
-- ============================================================================

DEFINE FIELD IF NOT EXISTS compatibility ON TABLE css_dictionary
    TYPE object
    COMMENT 'Bloc compatibilité : frameworks supportés';

DEFINE FIELD IF NOT EXISTS compatibility.supported_frameworks ON TABLE css_dictionary
    TYPE array<record<css_framework>>
    DEFAULT []
    REFERENCE ON DELETE CASCADE
    COMMENT 'Frameworks CSS supportés (références vers css_framework)';

DEFINE FIELD IF NOT EXISTS compatibility.required_features ON TABLE css_dictionary
    TYPE option<array<string>>
    COMMENT 'Fonctionnalités requises (hover, focus, etc.)';


-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_css_dictionary_code ON css_dictionary
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code technique';

DEFINE INDEX IF NOT EXISTS idx_css_dictionary_name ON css_dictionary
    FIELDS identity.name
    COMMENT 'Index sur le nom d\'affichage';

DEFINE INDEX IF NOT EXISTS idx_css_dictionary_category ON css_dictionary
    FIELDS metadata.category
    COMMENT 'Index sur la catégorie';

DEFINE INDEX IF NOT EXISTS idx_css_dictionary_semantic ON css_dictionary
    FIELDS metadata.semantic_meaning
    COMMENT 'Index sur la signification sémantique';

DEFINE INDEX IF NOT EXISTS idx_css_dictionary_category_semantic ON css_dictionary
    FIELDS metadata.category, metadata.semantic_meaning
    COMMENT 'Index composite catégorie + sémantique';

DEFINE INDEX IF NOT EXISTS idx_css_dictionary_version ON css_dictionary
    FIELDS metadata.version
    COMMENT 'Index sur la version';
-- ============================================================================
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- Bouton primaire
-- CREATE css_dictionary:primary_button SET
--   identity = { code = "primary_button", name = "Bouton Primaire" },
--   metadata = {
--     category = css_token_category:component,
--     semantic_meaning = css_token_subcategory:btn_height
--   },
--   compatibility = {
--     supported_frameworks = [css_framework:tailwind, css_framework:bootstrap]
--   },
--   styles = {
--     base = { display = "inline-flex", cursor = "pointer" },
--     interactions = { hover = { opacity = 0.9 } }
--   };

-- Champ de saisie
-- CREATE css_dictionary:input_field SET
--   identity = { code = "input_field", name = "Champ de Saisie" },
--   metadata = {
--     category = css_token_category:component,
--     semantic_meaning = css_token_subcategory:input_height
--   },
--   compatibility = {
--     supported_frameworks = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
--   },
--   styles = {
--     base = { border = "1px solid", padding = "0.5rem" }
--   };

-- Requêtes typiques utilisant les index
-- SELECT * FROM css_dictionary WHERE metadata.category = css_token_category:component;
-- SELECT * FROM css_dictionary WHERE css_framework:tailwind IN compatibility.supported_frameworks;
-- SELECT * FROM css_dictionary WHERE metadata.category = css_token_category:component AND metadata.semantic_meaning = css_token_subcategory:btn_height;
