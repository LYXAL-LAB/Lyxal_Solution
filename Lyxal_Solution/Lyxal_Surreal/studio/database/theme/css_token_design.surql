-- ============================================================================
-- TABLE : css_token_design
-- Description : Design tokens CSS (espacement, typographie, layout, etc.)
-- Module : studio/theme
-- ============================================================================

DEFINE TABLE IF NOT EXISTS css_token_design TYPE NORMAL SCHEMAFULL
COMMENT 'Design tokens CSS pour le système Database-Driven (espacement, typographie, layout, composants, utilitaires)'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique du design token
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE css_token_design
    TYPE object
    COMMENT 'Bloc identité : identification unique du design token';

    DEFINE FIELD IF NOT EXISTS identity.name ON TABLE css_token_design
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::starts_with($value, '--')
        COMMENT 'Nom de la variable CSS : --spacing-4, --font-size-lg, --border-radius-md';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE css_token_design
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::matches($value, '^[a-z0-9_-]+$')
        COMMENT 'Slug URL-friendly : spacing-4, font-size-lg, border-radius-md';

-- ============================================================================
-- BLOC CATEGORY : Classification du token
-- ============================================================================

DEFINE FIELD IF NOT EXISTS category ON TABLE css_token_design
    TYPE record<css_token_category>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence vers la catégorie du token (table css_token_category)';

DEFINE FIELD IF NOT EXISTS subcategory ON TABLE css_token_design
    TYPE option<record<css_token_subcategory>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence vers la sous-catégorie (optionnel)';

-- ============================================================================
-- BLOC VALUE : Valeur du token
-- ============================================================================

DEFINE FIELD IF NOT EXISTS value ON TABLE css_token_design
    TYPE string
    ASSERT $value != NONE AND $value != ""
    COMMENT 'Valeur CSS : 1rem, 1.125rem, 300, 0.5s, etc.';

DEFINE FIELD IF NOT EXISTS unit ON TABLE css_token_design
    TYPE option<string>
    ASSERT $value == NONE OR $value IN ['px', 'rem', 'em', '%', 'vh', 'vw', 's', 'ms', 'deg', 'none']
    COMMENT 'Unité CSS : px, rem, em, %, s, ms, none (pour valeurs sans unité)';

DEFINE FIELD IF NOT EXISTS computed_value ON TABLE css_token_design
    TYPE option<string>
    COMMENT 'Valeur calculée finale avec unité : 1rem, 300ms, etc. (calculée automatiquement)';

-- ============================================================================
-- BLOC THEME : Contexte thématique
-- ============================================================================

DEFINE FIELD IF NOT EXISTS theme ON TABLE css_token_design
    TYPE option<record<theme>>
    REFERENCE ON DELETE CASCADE
    COMMENT 'Référence vers le thème (NULL pour tokens globaux par défaut)';

DEFINE FIELD IF NOT EXISTS is_default ON TABLE css_token_design
    TYPE bool
    DEFAULT false
    COMMENT 'Token par défaut du système (valeur globale réutilisable dans tous les thèmes)';

-- ============================================================================
-- BLOC COMPONENT : Contexte composant (approche "riche et stricte")
-- ============================================================================

DEFINE FIELD IF NOT EXISTS component ON TABLE css_token_design
    TYPE option<record<css_component>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence vers le composant propriétaire (table css_component) - NONE pour tokens génériques';

DEFINE FIELD IF NOT EXISTS property ON TABLE css_token_design
    TYPE option<string>
    ASSERT $value == NONE OR string::matches($value, '^[a-z-]+(?:-[a-z-]+)*$')
    COMMENT 'Propriété CSS spécifique : background-color, border-radius, font-size, padding-x, etc. (NONE pour tokens génériques)';

-- ============================================================================
-- BLOC METADATA : Informations complémentaires
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE css_token_design
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.description ON TABLE css_token_design
        TYPE option<string>
        COMMENT 'Description du token et de son usage';

    DEFINE FIELD IF NOT EXISTS metadata.order ON TABLE css_token_design
        TYPE option<int>
        DEFAULT 0
        COMMENT 'Ordre dans l échelle (1, 2, 3, etc.) - déduit de category/subcategory';

    DEFINE FIELD IF NOT EXISTS metadata.compatibility ON TABLE css_token_design
        TYPE array<record<css_framework>>
        DEFAULT []
        REFERENCE ON DELETE CASCADE
        COMMENT 'Frameworks compatibles (références vers css_framework)';

    DEFINE FIELD IF NOT EXISTS metadata.author_user_id ON TABLE css_token_design
        TYPE option<record<user>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Utilisateur ayant créé/modifié le token (référence vers user, NONE si user supprimé)';

    DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE css_token_design
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE css_token_design
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

-- ============================================================================
-- ETAG : Optimistic locking
-- ============================================================================

DEFINE FIELD IF NOT EXISTS etag ON TABLE css_token_design
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (généré automatiquement)';

-- ============================================================================
-- BLOC USAGE : Statistiques d'utilisation
-- ============================================================================

DEFINE FIELD IF NOT EXISTS usage ON TABLE css_token_design
    TYPE option<object>
    COMMENT 'Bloc statistiques d\'utilisation';

    DEFINE FIELD IF NOT EXISTS usage.component_count ON TABLE css_token_design
        TYPE option<int>
        DEFAULT 0
        COMMENT 'Nombre de composants utilisant ce token';

    DEFINE FIELD IF NOT EXISTS usage.last_used ON TABLE css_token_design
        TYPE option<datetime>
        COMMENT 'Dernière utilisation du token';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_design_token_name_theme ON css_token_design
    FIELDS identity.name, theme UNIQUE
    COMMENT 'Index unique sur nom CSS + thème (permet tokens globaux avec theme=NULL)';

DEFINE INDEX IF NOT EXISTS idx_design_token_slug ON css_token_design
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_design_token_category ON css_token_design
    FIELDS category
    COMMENT 'Index sur la catégorie';

DEFINE INDEX IF NOT EXISTS idx_design_token_theme ON css_token_design
    FIELDS theme
    COMMENT 'Index sur le thème';

DEFINE INDEX IF NOT EXISTS idx_design_token_theme_category ON css_token_design
    FIELDS theme, category
    COMMENT 'Index composite thème + catégorie';

DEFINE INDEX IF NOT EXISTS idx_design_token_category_order ON css_token_design
    FIELDS category, metadata.order
    COMMENT 'Index sur catégorie et ordre (pour trier les tokens par catégorie)';

DEFINE INDEX IF NOT EXISTS idx_design_token_component ON css_token_design
    FIELDS component
    COMMENT 'Index sur le composant propriétaire';

DEFINE INDEX IF NOT EXISTS idx_design_token_component_property ON css_token_design
    FIELDS component, property
    COMMENT 'Index composite composant + propriété (optimisé pour requêtes par composant)';

DEFINE INDEX IF NOT EXISTS idx_design_token_theme_component ON css_token_design
    FIELDS theme, component
    COMMENT 'Index composite thème + composant (pour variables par composant/thème)';

-- ============================================================================
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- Créer un token global (réutilisable dans tous les thèmes)
-- CREATE css_token_design:spacing_4 SET
--   identity = {
--     name = "--spacing-4",
--     slug = "spacing-4"
--   },
--   category = css_token_category:spacing,
--   subcategory = css_token_subcategory:padding,
--   value = "1",
--   unit = "rem",
--   computed_value = "1rem",
--   theme = NONE,              // Token global
--   is_default = true,         // Valeur par défaut
--   metadata = {
--     description = "Espacement standard de 16px",
--     order = 4,               // Ordre dans l'échelle (spacing)
--     compatibility = [css_framework:tailwind, css_framework:bootstrap],
--     author_user_id = user:admin_user
--   };

-- Créer un token spécifique à un thème (override)
-- CREATE css_token_design:spacing_4_corporate SET
--   identity = {
--     name = "--spacing-4",
--     slug = "spacing-4-corporate"
--   },
--   category = css_token_category:spacing,
--   subcategory = css_token_subcategory:padding,
--   value = "1.25",
--   unit = "rem",
--   computed_value = "1.25rem",
--   theme = theme:corporate,   // Spécifique au thème corporate
--   is_default = false,
--   metadata = {
--     description = "Espacement corporate (plus large)",
--     order = 4,
--     compatibility = [css_framework:tailwind],
--     author_user_id = user:corporate_admin
--   };

-- Créer un token de typographie
-- CREATE css_token_design:font_size_lg SET
--   identity = {
--     name = "--font-size-lg",
--     slug = "font-size-lg"
--   },
--   category = css_token_category:typography,
--   subcategory = css_token_subcategory:font_size,
--   value = "1.125",
--   unit = "rem",
--   computed_value = "1.125rem",
--   theme = theme:default,
--   metadata = {
--     description = "Taille de police large (18px)",
--     order = 3,
--     compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material],
--     author_user_id = user:designer_user
--   };

-- Requêtes typiques
-- Tokens globaux (valeurs par défaut) par catégorie
-- SELECT * FROM css_token_design WHERE is_default = true AND category = css_token_category:spacing ORDER BY metadata.order;

-- Tokens pour un thème spécifique (avec fallbacks aux valeurs par défaut)
-- SELECT * FROM css_token_design WHERE (theme = theme:corporate OR is_default = true) AND category = css_token_category:spacing;

-- Tokens compatibles avec un framework spécifique
-- SELECT * FROM css_token_design WHERE css_framework:tailwind IN metadata.compatibility;

-- Chercher un token spécifique par nom
-- SELECT * FROM css_token_design WHERE identity.name = "--spacing-4" ORDER BY is_default DESC, theme;

-- ============================================================================
-- EXEMPLES APPROCHE "RICHE ET STRICTE" PAR COMPOSANT
-- ============================================================================

-- Tokens dédiés au composant Button (variables complètes par élément)
-- CREATE css_token_design:button_primary_bg SET
--   identity = { name = "--button-primary-bg", slug = "button-primary-bg" },
--   category = css_token_category:component,
--   subcategory = css_token_subcategory:button,
--   component = css_component:button,
--   property = "background-color",
--   value = "45% 0.2 250",
--   unit = "oklch_function",
--   computed_value = "oklch(45% 0.2 250)",
--   theme = theme:default,
--   is_default = true,
--   metadata = {
--     description = "Couleur de fond des boutons primaires",
--     order = 1,
--     compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
--   };

-- CREATE css_token_design:button_primary_text SET
--   identity = { name = "--button-primary-text", slug = "button-primary-text" },
--   category = css_token_category:component,
--   subcategory = css_token_subcategory:button,
--   component = css_component:button,
--   property = "color",
--   value = "95% 0.05 250",
--   unit = "oklch_function",
--   computed_value = "oklch(95% 0.05 250)",
--   theme = theme:default,
--   is_default = true,
--   metadata = {
--     description = "Couleur du texte des boutons primaires",
--     order = 2,
--     compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
--   };

-- Tokens dédiés au composant Card
-- CREATE css_token_design:card_background SET
--   identity = { name = "--card-background", slug = "card-background" },
--   category = css_token_category:component,
--   subcategory = css_token_subcategory:card,
--   component = css_component:card,
--   property = "background-color",
--   value = "100% 0 0",
--   unit = "oklch_function",
--   computed_value = "oklch(100% 0 0)",
--   theme = theme:default,
--   is_default = true,
--   metadata = {
--     description = "Couleur de fond des cartes",
--     order = 1,
--     compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
--   };

-- Tokens dédiés au composant Layout
-- CREATE css_token_design:layout_container_max_width SET
--   identity = { name = "--layout-container-max-width", slug = "layout-container-max-width" },
--   category = css_token_category:layout,
--   subcategory = css_token_subcategory:container,
--   component = css_component:layout,
--   property = "max-width",
--   value = "1280",
--   unit = "px",
--   computed_value = "1280px",
--   theme = theme:default,
--   is_default = true,
--   metadata = {
--     description = "Largeur maximale du conteneur principal",
--     order = 1,
--     compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
--   };

-- Requêtes pour l'approche par composant
-- Tous les tokens d'un composant spécifique
-- SELECT * FROM css_token_design WHERE component = css_component:button ORDER BY metadata.order;

-- Tokens d'un composant pour un thème spécifique (avec fallbacks)
-- SELECT * FROM css_token_design WHERE component = css_component:button AND (theme = theme:corporate OR is_default = true);

-- Tokens d'une propriété spécifique sur tous les composants
-- SELECT * FROM css_token_design WHERE property = "background-color";

-- Tokens d'un composant et d'une propriété
-- SELECT * FROM css_token_design WHERE component = css_component:button AND property = "background-color";

-- Tokens de tous les composants interactifs (avec jointure)
-- SELECT css_token_design.*, css_component.identity.name as component_name
-- FROM css_token_design
-- WHERE component != NONE
-- AND component.metadata.category = "interactive";
