-- ============================================================================
-- TABLE : theme_color
-- Description : Variables de couleur pour les thèmes (primary, error, info, etc.)
-- Module : studio/theme
-- ============================================================================

DEFINE TABLE IF NOT EXISTS theme_color TYPE NORMAL SCHEMAFULL
COMMENT 'Variables de couleur pour les thèmes du système Lyxal'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique de la couleur
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE theme_color
    TYPE object
    COMMENT 'Bloc identité : identification unique de la couleur';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE theme_color
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Valeur technique : primary_500, error_main, success_light';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE theme_color
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly : primary-500, error-main, success-light';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE theme_color
    TYPE object
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE theme_color
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        VALUE type::thing('i18n_key', $value)
        COMMENT 'Nom de la couleur (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE theme_color
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        VALUE {IF $value != NONE {type::thing('i18n_key', $value)} ELSE {NONE}}
        COMMENT 'Description de la couleur (i18n)';

-- ============================================================================
-- BLOC COLOR : Informations sur la couleur
-- ============================================================================

DEFINE FIELD IF NOT EXISTS color ON TABLE theme_color
    TYPE object
    COMMENT 'Bloc couleur : valeurs et formats';

    DEFINE FIELD IF NOT EXISTS color.hex ON TABLE theme_color
        TYPE string
        ASSERT $value != NONE AND string::matches($value, '^#[0-9A-Fa-f]{6}$|^#[0-9A-Fa-f]{8}$')
        COMMENT 'Couleur au format HEX : #FF5733 ou #FF5733FF (avec alpha)';

    DEFINE FIELD IF NOT EXISTS color.rgb ON TABLE theme_color
        TYPE option<object>
        COMMENT 'Couleur au format RGB/RGBA';

        DEFINE FIELD IF NOT EXISTS color.rgb.r ON TABLE theme_color
            TYPE int
            ASSERT $value >= 0 AND $value <= 255
            COMMENT 'Rouge (0-255)';

        DEFINE FIELD IF NOT EXISTS color.rgb.g ON TABLE theme_color
            TYPE int
            ASSERT $value >= 0 AND $value <= 255
            COMMENT 'Vert (0-255)';

        DEFINE FIELD IF NOT EXISTS color.rgb.b ON TABLE theme_color
            TYPE int
            ASSERT $value >= 0 AND $value <= 255
            COMMENT 'Bleu (0-255)';

        DEFINE FIELD IF NOT EXISTS color.rgb.a ON TABLE theme_color
            TYPE option<float>
            ASSERT $value == NONE OR ($value >= 0 AND $value <= 1)
            COMMENT 'Alpha/Opacité (0-1)';

    DEFINE FIELD IF NOT EXISTS color.hsl ON TABLE theme_color
        TYPE option<object>
        COMMENT 'Couleur au format HSL/HSLA';

        DEFINE FIELD IF NOT EXISTS color.hsl.h ON TABLE theme_color
            TYPE int
            ASSERT $value >= 0 AND $value <= 360
            COMMENT 'Teinte (0-360)';

        DEFINE FIELD IF NOT EXISTS color.hsl.s ON TABLE theme_color
            TYPE int
            ASSERT $value >= 0 AND $value <= 100
            COMMENT 'Saturation (0-100)';

        DEFINE FIELD IF NOT EXISTS color.hsl.l ON TABLE theme_color
            TYPE int
            ASSERT $value >= 0 AND $value <= 100
            COMMENT 'Luminosité (0-100)';

        DEFINE FIELD IF NOT EXISTS color.hsl.a ON TABLE theme_color
            TYPE option<float>
            ASSERT $value == NONE OR ($value >= 0 AND $value <= 1)
            COMMENT 'Alpha/Opacité (0-1)';

-- ============================================================================
-- BLOC CONTEXT : Contexte d'utilisation de la couleur
-- ============================================================================

DEFINE FIELD IF NOT EXISTS context ON TABLE theme_color
    TYPE object
    COMMENT 'Bloc contexte : où et comment la couleur est utilisée';

    DEFINE FIELD IF NOT EXISTS context.type ON TABLE theme_color
        TYPE record<theme_color_type>
        REFERENCE ON DELETE REJECT
        VALUE type::record('theme_color_type', $value)
        COMMENT 'Type de couleur : primary, error, warning, info, success, etc.';

    DEFINE FIELD IF NOT EXISTS context.variant ON TABLE theme_color
        TYPE option<string>
        ASSERT $value == NONE OR $value INSIDE ['main', 'light', 'lighter', 'dark', 'darker', 'contrast', '50', '100', '200', '300', '400', '500', '600', '700', '800', '900', 'A100', 'A200', 'A400', 'A700']
        COMMENT 'Variante : main, light, dark, 50-900 (Material Design), A100-A700';

    DEFINE FIELD IF NOT EXISTS context.theme_mode ON TABLE theme_color
        TYPE string
        ASSERT $value INSIDE ['light', 'dark', 'both', 'auto']
        DEFAULT 'both'
        COMMENT 'Mode de thème : light, dark, both, auto';

    DEFINE FIELD IF NOT EXISTS context.usage ON TABLE theme_color
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Usage de la couleur : ["button", "text", "background", "border"]';

-- ============================================================================
-- BLOC STATUS : État de la couleur
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE theme_color
    TYPE object
    COMMENT 'Bloc statut : état général de la couleur';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE theme_color
        TYPE bool
        DEFAULT true
        COMMENT 'Couleur active dans le système ?';

    DEFINE FIELD IF NOT EXISTS status.is_default ON TABLE theme_color
        TYPE bool
        DEFAULT false
        COMMENT 'Couleur par défaut pour son type ?';

    DEFINE FIELD IF NOT EXISTS status.source ON TABLE theme_color
        TYPE string
        ASSERT $value INSIDE ['manual', 'import', 'system_generated', 'material_design', 'tailwind', 'custom', 'other']
        DEFAULT 'manual'
        COMMENT 'Source de la couleur';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE theme_color
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE theme_color
        TYPE option<string>
        COMMENT 'Notes internes libres';

    DEFINE FIELD IF NOT EXISTS metadata.css_variable ON TABLE theme_color
        TYPE option<string>
        COMMENT 'Nom de la variable CSS : --color-primary-500, --error-main';

    DEFINE FIELD IF NOT EXISTS metadata.tailwind_class ON TABLE theme_color
        TYPE option<string>
        COMMENT 'Classe Tailwind : bg-primary-500, text-error-main';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS created_at ON TABLE theme_color
    TYPE datetime
    READONLY
    DEFAULT time::now()
    COMMENT 'Date de création (readonly)';

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE theme_color
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now()
    COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE theme_color
    TYPE string
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_theme_color_slug ON theme_color
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_theme_color_type ON theme_color
    FIELDS context.type
    COMMENT 'Index sur le type de couleur';

DEFINE INDEX IF NOT EXISTS idx_theme_color_type_variant ON theme_color
    FIELDS context.type, context.variant
    COMMENT 'Index composite sur type + variante';

DEFINE INDEX IF NOT EXISTS idx_theme_color_active ON theme_color
    FIELDS status.is_active
    COMMENT 'Index sur les couleurs actives';

DEFINE INDEX IF NOT EXISTS idx_theme_color_theme_mode ON theme_color
    FIELDS context.theme_mode
    COMMENT 'Index sur le mode de thème (light/dark)';

DEFINE INDEX IF NOT EXISTS idx_theme_color_css_var ON theme_color
    FIELDS metadata.css_variable
    COMMENT 'Index sur les variables CSS';

