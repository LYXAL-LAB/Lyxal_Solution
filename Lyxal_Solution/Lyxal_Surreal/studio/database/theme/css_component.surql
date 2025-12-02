-- ============================================================================
-- TABLE : css_component
-- Description : Composants UI disponibles dans le système Database-Driven
-- Module : studio/theme
-- Approche : "Riche et stricte" - Normalisation des composants
-- ============================================================================

DEFINE TABLE IF NOT EXISTS css_component TYPE NORMAL SCHEMAFULL
COMMENT 'Composants UI disponibles (button, card, layout, input, modal, etc.) - approche "riche et stricte"';

-- ============================================================================
-- BLOC IDENTITY : Identification unique du composant
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE css_component
    TYPE object
    COMMENT 'Bloc identité : identification unique du composant';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE css_component
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::matches($value, '^[a-z_-]+$')
        COMMENT 'Code unique du composant : button, card, layout, input, modal, etc.';

    DEFINE FIELD IF NOT EXISTS identity.name ON TABLE css_component
        TYPE string
        ASSERT $value != NONE AND $value != ""
        COMMENT 'Nom d\'affichage du composant : Bouton, Carte, Mise en page, etc.';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE css_component
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::matches($value, '^[a-z0-9_-]+$')
        COMMENT 'Slug URL-friendly : button, card, layout, input, modal, etc.';

-- ============================================================================
-- BLOC METADATA : Informations complémentaires
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE css_component
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.description ON TABLE css_component
        TYPE option<string>
        COMMENT 'Description détaillée du composant et de son usage';

    DEFINE FIELD IF NOT EXISTS metadata.category ON TABLE css_component
        TYPE string
        ASSERT $value IN ['interactive', 'layout', 'content', 'navigation', 'feedback', 'data_display']
        COMMENT 'Catégorie fonctionnelle : interactive, layout, content, navigation, feedback, data_display';

    DEFINE FIELD IF NOT EXISTS metadata.priority ON TABLE css_component
        TYPE int
        DEFAULT 0
        COMMENT 'Priorité d\'affichage (0 = basse, 10 = haute)';

    DEFINE FIELD IF NOT EXISTS metadata.is_core ON TABLE css_component
        TYPE bool
        DEFAULT true
        COMMENT 'Composant de base du système (true) ou spécialisé (false)';

    DEFINE FIELD IF NOT EXISTS metadata.compatibility ON TABLE css_component
        TYPE array<record<css_framework>>
        DEFAULT []
        REFERENCE ON DELETE CASCADE
        COMMENT 'Frameworks compatibles pour ce composant';

    DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE css_component
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE css_component
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

-- ============================================================================
-- ETAG : Optimistic locking
-- ============================================================================

DEFINE FIELD IF NOT EXISTS etag ON TABLE css_component
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (généré automatiquement)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_css_component_code ON css_component
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code du composant';

DEFINE INDEX IF NOT EXISTS idx_css_component_slug ON css_component
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_css_component_category ON css_component
    FIELDS metadata.category
    COMMENT 'Index sur la catégorie fonctionnelle';

DEFINE INDEX IF NOT EXISTS idx_css_component_priority ON css_component
    FIELDS metadata.priority
    COMMENT 'Index sur la priorité d\'affichage';

DEFINE INDEX IF NOT EXISTS idx_css_component_core ON css_component
    FIELDS metadata.is_core
    COMMENT 'Index sur les composants de base';

-- ============================================================================
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- Créer un composant de base
-- CREATE css_component:button SET
--   identity = {
--     code = "button",
--     name = "Bouton",
--     slug = "button"
--   },
--   metadata = {
--     description = "Composant interactif pour déclencher des actions utilisateur",
--     category = "interactive",
--     priority = 10,
--     is_core = true,
--     compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
--   };

-- Créer un composant layout
-- CREATE css_component:layout SET
--   identity = {
--     code = "layout",
--     name = "Mise en page",
--     slug = "layout"
--   },
--   metadata = {
--     description = "Structure et organisation de l\'espace visuel",
--     category = "layout",
--     priority = 8,
--     is_core = true,
--     compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
--   };

-- Requêtes typiques
-- Composants de base par priorité
-- SELECT * FROM css_component WHERE metadata.is_core = true ORDER BY metadata.priority DESC;

-- Composants par catégorie
-- SELECT * FROM css_component WHERE metadata.category = "interactive" ORDER BY metadata.priority DESC;

-- Composant par code
-- SELECT * FROM css_component WHERE identity.code = "button";
