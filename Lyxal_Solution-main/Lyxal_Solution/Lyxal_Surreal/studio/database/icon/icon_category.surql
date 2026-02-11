-- =============================================================================
-- TABLE: icon_category
-- =============================================================================
-- RÔLE
--   Catégories fonctionnelles pour classifier les icônes
--   Permet de filtrer et organiser les icônes par usage
--   Utilisée pour l'UI (sélecteur d'icônes, filtres)
--
-- USAGE
--   Référencée par la table icon pour normaliser les catégories
--   Contient métadonnées visuelles (couleur, icône représentative)
--
-- EXEMPLES
--   - icon_category:ui → Icônes d'interface (buttons, inputs)
--   - icon_category:navigation → Icônes de navigation (home, menu)
--   - icon_category:action → Icônes d'action (save, delete, edit)
--   - icon_category:data → Icônes de données (database, file, folder)
-- =============================================================================

DEFINE TABLE IF NOT EXISTS icon_category TYPE NORMAL SCHEMAFULL
  COMMENT 'Catégories fonctionnelles pour classifier les icônes'
  PERMISSIONS
    FOR SELECT FULL
    FOR CREATE, UPDATE, DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique de la catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE icon_category
    TYPE object
    COMMENT 'Bloc identité : identification unique de la catégorie';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE icon_category
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Valeur technique : ui, navigation, action, status';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE icon_category
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly : ui, navigation, action, status';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE icon_category
    TYPE object
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE icon_category
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom de la catégorie (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE icon_category
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Description de la catégorie (i18n)';

-- ============================================================================
-- BLOC CONTEXT : Contexte d'utilisation de la catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS context ON TABLE icon_category
    TYPE object
    COMMENT 'Bloc contexte : usage et exemples';

    DEFINE FIELD IF NOT EXISTS context.examples ON TABLE icon_category
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Exemples d\'icônes typiques de cette catégorie (noms)';

    DEFINE FIELD IF NOT EXISTS context.keywords ON TABLE icon_category
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Mots-clés pour recherche et auto-classification (multilingue)';

-- ============================================================================
-- BLOC METADATA : Métadonnées visuelles UI
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE icon_category
    TYPE object
    COMMENT 'Bloc métadonnées : informations visuelles et système';

    DEFINE FIELD IF NOT EXISTS metadata.color_type ON TABLE icon_category
        TYPE record<theme_color_type>
        REFERENCE ON DELETE REJECT
        COMMENT 'Type de couleur pour le badge UI de la catégorie';

    DEFINE FIELD IF NOT EXISTS metadata.representative_icon ON TABLE icon_category
        TYPE option<record<icon>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Icône représentative de cette catégorie (pour affichage UI)';

    DEFINE FIELD IF NOT EXISTS metadata.display_order ON TABLE icon_category
        TYPE int
        DEFAULT 999
        COMMENT 'Ordre d\'affichage dans les listes UI (plus petit = plus haut)';

-- ============================================================================
-- BLOC STATUS : État de la catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE icon_category
    TYPE object
    COMMENT 'Bloc statut : état général de la catégorie';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE icon_category
        TYPE bool
        DEFAULT true
        COMMENT 'Catégorie active/désactivée';

    DEFINE FIELD IF NOT EXISTS status.is_system ON TABLE icon_category
        TYPE bool
        DEFAULT false
        COMMENT 'Catégorie système (non modifiable par utilisateur)';

    DEFINE FIELD IF NOT EXISTS status.source ON TABLE icon_category
        TYPE string
        ASSERT $value INSIDE ['system', 'custom', 'import']
        DEFAULT 'system'
        COMMENT 'Source de la catégorie';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE icon_category
    TYPE object
    COMMENT 'Dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE icon_category
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE icon_category
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE icon_category
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_icon_category_slug ON icon_category
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_icon_category_value ON icon_category
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur';

DEFINE INDEX IF NOT EXISTS idx_icon_category_active ON icon_category
    FIELDS status.is_active
    COMMENT 'Index sur les catégories actives';

DEFINE INDEX IF NOT EXISTS idx_icon_category_system ON icon_category
    FIELDS status.is_system
    COMMENT 'Index sur les catégories système';

DEFINE INDEX IF NOT EXISTS idx_icon_category_display_order ON icon_category
    FIELDS metadata.display_order
    COMMENT 'Index sur l\'ordre d\'affichage';
