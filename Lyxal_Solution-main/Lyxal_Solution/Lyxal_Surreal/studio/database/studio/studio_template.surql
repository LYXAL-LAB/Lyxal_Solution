-- ============================================================================
-- Fichier : studio/database/studio/studio_template.surql
-- Module : studio
-- TABLE : studio_template
-- Description : Templates de pages - Modèles réutilisables pour différents cas d'usage
-- 
-- Fichier de seeds : 
-- studio/reference/studio/template/studio_template_seeds.surql
--
-- Fichier de i18n :
-- studio/reference/i18n/studio/template/studio_template_i18n_key_seeds.surql
-- studio/reference/i18n/studio/template/studio_template_i18n_translation_seeds.surql
-- 
-- Fichier de tests :
-- studio/test/studio_template_test.surql
--
-- Fichier de documentation :
-- studio/documentation/studio/template/studio_template_documentation.md
--
-- Dépendances : studio_template_category, studio_template_subcategory, studio_page, builder_catalogue, studio_component, theme, identity, i18n_key
--
-- Déploiement : Après la table studio_template_category et studio_template_subcategory
--
-- Référence : studio/database/studio/studio_template_category.surql
--              studio/database/studio/studio_template_subcategory.surql
--              studio/database/studio/studio_page.surql
--              studio/database/builder/builder_catalogue.surql
--              studio/database/studio/studio_component.surql
--              studio/database/theme/theme.surql
--              studio/database/identity/identity.surql
--              studio/database/i18n/i18n_key.surql
--              studio/database/i18n/i18n_translation.surql
--              studio/reference/studio/template/studio_template_seeds.surql
--              studio/reference/i18n/studio/template/studio_template_i18n_key_seeds.surql
--              studio/reference/i18n/studio/template/studio_template_i18n_translation_seeds.surql
--              studio/test/studio_template_test.surql
--              studio/documentation/studio/template/studio_template_documentation.md
--
-- Auteur : Équipe Lyxal (via AI Assistant)
-- Date : 31 octobre 2025
-- Version : 1.0
--
-- Changelog :
-- - 31 octobre 2025 : Création de la table studio_template
-- - 31 octobre 2025 : Ajout des champs identity, presentation, categorization, pages, config, context, status, metadata, timestamp
-- - 31 octobre 2025 : Ajout des index identity_code_unique, category_idx, category_subcategory_idx, status_active_idx, status_featured_idx
-- - 31 octobre 2025 : Ajout des permissions FOR SELECT FULL, FOR CREATE, UPDATE, DELETE NONE
-- ============================================================================
DEFINE TABLE IF NOT EXISTS studio_template TYPE NORMAL SCHEMAFULL
    COMMENT 'Templates de pages - Modèles réutilisables pour différents cas d\'usage'
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE;

-- ============================================================================
-- IDENTITY : Identification unique du template
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE studio_template
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification unique du template';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE studio_template
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0
        COMMENT 'Code unique du template (snake_case) : "ecommerce_hitech", "saas_crm"';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE studio_template
        TYPE string
        ASSERT string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly : "ecommerce-hitech", "saas-crm"';

-- ============================================================================
-- PRESENTATION : Présentation du template
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE studio_template
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc présentation : affichage et métadonnées visuelles';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE studio_template
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom du template (i18n) : "Template Ecommerce HiTech"';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE studio_template
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Description du template (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.preview_url ON TABLE studio_template
        TYPE option<record<url>>
        REFERENCE ON DELETE UNSET
        COMMENT 'URL de preview/screenshot du template';

    DEFINE FIELD IF NOT EXISTS presentation.keywords ON TABLE studio_template
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Mots-clés : ["ecommerce", "hitech", "responsive", "modern"]';

-- ============================================================================
-- CATEGORIZATION : Catégorisation du template
-- ============================================================================

DEFINE FIELD IF NOT EXISTS categorization ON TABLE studio_template
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc catégorisation : rattachement aux catégories et sous-catégories';

    DEFINE FIELD IF NOT EXISTS categorization.category ON TABLE studio_template
        TYPE record<studio_template_category>
        REFERENCE ON DELETE REJECT
        ASSERT $value != NONE
        COMMENT 'Catégorie principale : studio_template_category:ecommerce';

    DEFINE FIELD IF NOT EXISTS categorization.subcategory ON TABLE studio_template
        TYPE option<record<studio_template_subcategory>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Sous-catégorie : studio_template_subcategory:hitech';

    DEFINE FIELD IF NOT EXISTS categorization.tags ON TABLE studio_template
        TYPE option<array<record<tag>>>
        DEFAULT []
        COMMENT 'Tags additionnels pour recherche et filtrage';

-- ============================================================================
-- PAGES : Pages incluses dans le template
-- ============================================================================

DEFINE FIELD IF NOT EXISTS pages ON TABLE studio_template
    TYPE array<record<studio_page>>
    DEFAULT []
    COMMENT 'Liste des pages incluses dans ce template (références vers studio_page)';

-- ============================================================================
-- CONFIG : Configuration du template
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE studio_template
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc configuration : paramètres techniques et visuels';

    DEFINE FIELD IF NOT EXISTS config.required_modules ON TABLE studio_template
        TYPE option<array<record<builder_catalogue>>>
        DEFAULT []
        COMMENT 'Modules requis : ["crm", "sales", "inventory"]';

    DEFINE FIELD IF NOT EXISTS config.required_components ON TABLE studio_template
        TYPE option<array<record<studio_component>>>
        DEFAULT []
        COMMENT 'Composants requis par le template';

    DEFINE FIELD IF NOT EXISTS config.theme ON TABLE studio_template
        TYPE option<record<theme>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Thème recommandé pour ce template';

    DEFINE FIELD IF NOT EXISTS config.is_multi_tenant ON TABLE studio_template
        TYPE bool
        DEFAULT false
        COMMENT 'Template compatible multi-tenant ?';

    DEFINE FIELD IF NOT EXISTS config.is_responsive ON TABLE studio_template
        TYPE bool
        DEFAULT true
        COMMENT 'Template responsive ?';

-- ============================================================================
-- CONTEXT : Contexte d'utilisation
-- ============================================================================

DEFINE FIELD IF NOT EXISTS context ON TABLE studio_template
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc contexte : recommandations d’usage et public cible';

    DEFINE FIELD IF NOT EXISTS context.usage_hints ON TABLE studio_template
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Indices d\'utilisation : ["small_business", "enterprise", "startup"]';

    DEFINE FIELD IF NOT EXISTS context.target_audience ON TABLE studio_template
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Audience cible : ["b2c", "b2b", "b2b2c"]';

-- ============================================================================
-- STATUS : Statut du template
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE studio_template
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc statut : disponibilité et visibilité du template';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE studio_template
        TYPE bool
        DEFAULT true
        COMMENT 'Template actif (disponible) ?';

    DEFINE FIELD IF NOT EXISTS status.is_featured ON TABLE studio_template
        TYPE bool
        DEFAULT false
        COMMENT 'Template mis en avant ?';

    DEFINE FIELD IF NOT EXISTS status.is_system_template ON TABLE studio_template
        TYPE bool
        DEFAULT false
        COMMENT 'Template système (fourni par défaut) ?';

-- ============================================================================
-- METADATA : Métadonnées
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE studio_template
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations internes système';

    DEFINE FIELD IF NOT EXISTS metadata.version ON TABLE studio_template
        TYPE string
        DEFAULT '1.0.0'
        COMMENT 'Version du template : "1.0.0", "2.1.3"';

    DEFINE FIELD IF NOT EXISTS metadata.author_user_id ON TABLE studio_template
        TYPE option<record<identity>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Utilisateur créateur du template (si custom)';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE studio_template
        TYPE option<string>
        COMMENT 'Notes internes libres';

    DEFINE FIELD IF NOT EXISTS metadata.usage_count ON TABLE studio_template
        TYPE int
        DEFAULT 0
        COMMENT 'Nombre de fois que le template a été utilisé';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE studio_template
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc timestamp : dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE studio_template
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE studio_template
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE studio_template
    TYPE string
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS identity_code_unique ON studio_template 
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code';

DEFINE INDEX IF NOT EXISTS category_idx ON studio_template 
    FIELDS categorization.category
    COMMENT 'Index sur la catégorie';

DEFINE INDEX IF NOT EXISTS category_subcategory_idx ON studio_template 
    FIELDS categorization.category, categorization.subcategory
    COMMENT 'Index sur la catégorie et la sous-catégorie';

DEFINE INDEX IF NOT EXISTS status_active_idx ON studio_template 
    FIELDS status.is_active
    COMMENT 'Index sur les templates actifs';

DEFINE INDEX IF NOT EXISTS status_featured_idx ON studio_template 
    FIELDS status.is_featured
    COMMENT 'Index sur les templates mis en avant';