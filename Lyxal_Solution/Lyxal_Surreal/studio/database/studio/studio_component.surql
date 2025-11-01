-- ============================================================================
-- TABLE : studio_component
-- Description : Composants UI réutilisables définis en base de données
-- Module : studio/runtime
-- ============================================================================

DEFINE TABLE IF NOT EXISTS studio_component TYPE NORMAL SCHEMAFULL
COMMENT 'Composants UI réutilisables définis en base de données pour le système Lyxal Studio'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique du composant
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE studio_component
    TYPE object
    COMMENT 'Bloc identité : identification unique du composant';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE studio_component
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Valeur technique : button, card, input, table, contact_list';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE studio_component
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly : button, card, input, table, contact-list';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE studio_component
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Code unique du composant (snake_case) : button, contact_list';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE studio_component
    TYPE object
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE studio_component
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom du composant (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE studio_component
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Description du composant (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.preview_url ON TABLE studio_component
        TYPE option<record<url>>
        REFERENCE ON DELETE REJECT
        COMMENT 'URL de prévisualisation du composant (screenshot, SVG)';

    DEFINE FIELD IF NOT EXISTS presentation.keywords ON TABLE studio_component
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Mots-clés pour recherche : ["button", "form", "action", "ui"]';

-- ============================================================================
-- BLOC STRUCTURE : Structure JSON du composant
-- ============================================================================

DEFINE FIELD IF NOT EXISTS structure ON TABLE studio_component
    TYPE object
    COMMENT 'Bloc structure : structure JSON complète du composant (100% DB-driven)';

    DEFINE FIELD IF NOT EXISTS structure.type ON TABLE studio_component
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Type de l\'élément racine : "button", "div", "input", "component" (pour composants imbriqués)';

    DEFINE FIELD IF NOT EXISTS structure.props ON TABLE studio_component
        FLEXIBLE
        TYPE option<object>
        COMMENT 'Props de l\'élément (camelCase) : {className: [...], onClick: {...}, disabled: "{{props.disabled}}"';

    DEFINE FIELD IF NOT EXISTS structure.children ON TABLE studio_component
        FLEXIBLE
        TYPE option<array<object>>
        DEFAULT []
        COMMENT 'Children récursifs : [{type: "text", content: "{{props.label}}"}]';

    DEFINE FIELD IF NOT EXISTS structure.variants ON TABLE studio_component
        FLEXIBLE
        TYPE option<object>
        COMMENT 'Variants conditionnels : {primary: {className: [...]}, secondary: {...}}';

-- ============================================================================
-- BLOC CONFIG : Configuration du composant
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE studio_component
    TYPE object
    COMMENT 'Bloc configuration : paramètres du composant';

    DEFINE FIELD IF NOT EXISTS config.category ON TABLE studio_component
        TYPE string
        ASSERT $value INSIDE ['atom', 'molecule', 'organism', 'template', 'page']
        DEFAULT 'molecule'
        COMMENT 'Catégorie Atomic Design : atom (button, input), molecule (card), organism (table), template, page';

    DEFINE FIELD IF NOT EXISTS config.version ON TABLE studio_component
        TYPE string
        DEFAULT '1.0.0'
        COMMENT 'Version du composant : 1.0.0, 2.1.3, etc.';

    DEFINE FIELD IF NOT EXISTS config.props_schema ON TABLE studio_component
        FLEXIBLE
        TYPE array
        DEFAULT []
        COMMENT 'Schéma de validation des props : [{name: "label", type: "string", required: true}]';

    DEFINE FIELD IF NOT EXISTS config.supports_slots ON TABLE studio_component
        TYPE bool
        DEFAULT false
        COMMENT 'Supporte les slots (children nommés) ? : header, footer, default';

    DEFINE FIELD IF NOT EXISTS config.slots ON TABLE studio_component
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Liste des slots supportés : ["header", "footer", "actions"]';

    DEFINE FIELD IF NOT EXISTS config.icon ON TABLE studio_component
        TYPE option<record<icon>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Icône représentative du composant';

-- ============================================================================
-- BLOC CONTEXT : Contexte d'utilisation du composant
-- ============================================================================

DEFINE FIELD IF NOT EXISTS context ON TABLE studio_component
    TYPE object
    COMMENT 'Bloc contexte : où et comment le composant est utilisé';

    DEFINE FIELD IF NOT EXISTS context.usage_hints ON TABLE studio_component
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Indications d\'usage : ["form", "dashboard", "list", "detail"]';

    DEFINE FIELD IF NOT EXISTS context.semantic_meaning ON TABLE studio_component
        TYPE option<string>
        COMMENT 'Signification sémantique : "Bouton d\'action principale", "Carte d\'affichage de données"';

    DEFINE FIELD IF NOT EXISTS context.dependencies ON TABLE studio_component
        TYPE option<array<record<studio_component>>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Composants requis par ce composant (imbriqués)';

-- ============================================================================
-- BLOC STATUS : État du composant
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE studio_component
    TYPE object
    COMMENT 'Bloc statut : état général du composant';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE studio_component
        TYPE bool
        DEFAULT true
        COMMENT 'Composant actif (disponible pour utilisation) ?';

    DEFINE FIELD IF NOT EXISTS status.is_system_component ON TABLE studio_component
        TYPE bool
        DEFAULT false
        COMMENT 'Composant système (fourni par défaut) ou custom (créé par utilisateur) ?';

    DEFINE FIELD IF NOT EXISTS status.is_deprecated ON TABLE studio_component
        TYPE bool
        DEFAULT false
        COMMENT 'Composant déprécié (ne plus utiliser) ?';

    DEFINE FIELD IF NOT EXISTS status.deprecation_reason ON TABLE studio_component
        TYPE option<string>
        COMMENT 'Raison de la dépréciation si is_deprecated = true';

    DEFINE FIELD IF NOT EXISTS status.source ON TABLE studio_component
        TYPE string
        ASSERT $value INSIDE ['system', 'user_created', 'import', 'marketplace', 'custom']
        DEFAULT 'system'
        COMMENT 'Source du composant';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE studio_component
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE studio_component
        TYPE option<string>
        COMMENT 'Notes internes libres';

    DEFINE FIELD IF NOT EXISTS metadata.tags ON TABLE studio_component
        TYPE option<array<record<tag>>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Tags pour classification : ["ui", "form", "data-display"]';

    DEFINE FIELD IF NOT EXISTS metadata.author_user_id ON TABLE studio_component
        TYPE option<record<identity>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Utilisateur créateur du composant (si custom)';

    DEFINE FIELD IF NOT EXISTS metadata.usage_count ON TABLE studio_component
        TYPE int
        DEFAULT 0
        COMMENT 'Nombre d\'utilisations du composant (analytics)';

    DEFINE FIELD IF NOT EXISTS metadata.last_used_at ON TABLE studio_component
        TYPE option<datetime>
        COMMENT 'Date de dernière utilisation';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE studio_component
    TYPE object
    COMMENT 'Dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE studio_component
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE studio_component
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE studio_component
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_studio_component_code ON studio_component
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code';

DEFINE INDEX IF NOT EXISTS idx_studio_component_slug ON studio_component
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_studio_component_value ON studio_component
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur';

DEFINE INDEX IF NOT EXISTS idx_studio_component_category ON studio_component
    FIELDS config.category
    COMMENT 'Index sur la catégorie (atom, molecule, organism)';

DEFINE INDEX IF NOT EXISTS idx_studio_component_active ON studio_component
    FIELDS status.is_active
    COMMENT 'Index sur les composants actifs';

DEFINE INDEX IF NOT EXISTS idx_studio_component_system ON studio_component
    FIELDS status.is_system_component
    COMMENT 'Index sur les composants système';

DEFINE INDEX IF NOT EXISTS idx_studio_component_deprecated ON studio_component
    FIELDS status.is_deprecated
    COMMENT 'Index sur les composants dépréciés';

