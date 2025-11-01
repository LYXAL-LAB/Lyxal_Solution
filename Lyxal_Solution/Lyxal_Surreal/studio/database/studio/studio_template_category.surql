-- ============================================================================
-- Fichier : studio/database/studio/studio_template_category.surql
-- Module : studio
-- TABLE : studio_template_category
--
-- Description : Catégories de templates avec i18n (ecommerce, saas, portfolio, etc.)
-- 
-- Fichier de seeds : 
-- studio/reference/studio/template/studio_template_category_seeds.surql
--
-- Fichier de i18n :
-- studio/reference/i18n/studio/template/studio_template_category_i18n_key_seeds.surql
-- studio/reference/i18n/studio/template/studio_template_category_i18n_translation_seeds.surql
--
-- Fichier de tests :
-- studio/test/studio_template_category_test.surql
--
-- Fichier de documentation :
-- studio/documentation/studio/template/studio_template_category_documentation.md
--
-- Dépendances : theme_color, icon, i18n_key
--
-- Déploiement : Avant la table studio_template_subcategory
--
-- Référence : studio/database/studio/studio_template_subcategory.surql
--              studio/reference/studio/template/studio_template_category_seeds.surql
--              studio/reference/i18n/studio/template/studio_template_category_i18n_key_seeds.surql
--              studio/reference/i18n/studio/template/studio_template_category_i18n_translation_seeds.surql
--              studio/test/studio_template_category_test.surql
--              studio/documentation/studio/template/studio_template_category_documentation.md
--
-- Auteur : Équipe Lyxal (via AI Assistant)
-- Date : 31 octobre 2025
-- Version : 1.0
--
-- Changelog :
-- - 31 octobre 2025 : Création de la table studio_template_category
-- - 31 octobre 2025 : Ajout des champs identity, presentation, config, status, relation_subcategories, metadata, timestamp
-- - 31 octobre 2025 : Ajout des index identity_code_unique, status_active_idx, config_order_idx
-- - 31 octobre 2025 : Ajout des permissions FOR SELECT FULL, FOR CREATE, UPDATE, DELETE NONE
-- ============================================================================

DEFINE TABLE IF NOT EXISTS studio_template_category TYPE NORMAL SCHEMAFULL
    COMMENT 'Catégories de templates - Organisation principale avec i18n'
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE;

-- ============================================================================
-- IDENTITY : Identification unique de la catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE studio_template_category
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification unique de la catégorie';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE studio_template_category
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0
        COMMENT 'Code unique de la catégorie (snake_case) : "ecommerce", "saas", "portfolio"';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE studio_template_category
        TYPE string
        ASSERT string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly : "ecommerce", "saas", "portfolio"';

-- ============================================================================
-- PRESENTATION : Présentation de la catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE studio_template_category
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc présentation : affichage avec i18n';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE studio_template_category
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom de la catégorie (i18n) : "Ecommerce", "SaaS", "Portfolio"';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE studio_template_category
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Description de la catégorie (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.icon ON TABLE studio_template_category
        TYPE option<record<icon>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Icône représentative de la catégorie';

-- ============================================================================
-- CONFIG : Configuration de la catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE studio_template_category
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc configuration : paramètres visuels et comportementaux';

    DEFINE FIELD IF NOT EXISTS config.order ON TABLE studio_template_category
        TYPE int
        DEFAULT 0
        ASSERT $value >= 0
        COMMENT 'Ordre d\'affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS config.color ON TABLE studio_template_category
        TYPE option<record<theme_color>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Couleur associée à la catégorie (hex, variable CSS, etc.)';

-- ============================================================================
-- STATUS : Statut de la catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE studio_template_category
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc statut : état d’activation et visibilité';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE studio_template_category
        TYPE bool
        DEFAULT true
        COMMENT 'Catégorie active (visible) ?';

    DEFINE FIELD IF NOT EXISTS status.is_default ON TABLE studio_template_category
        TYPE bool
        DEFAULT false
        COMMENT 'Catégorie par défaut ?';

-- ============================================================================
-- RELATION : Sous-catégories associées
-- ============================================================================

DEFINE FIELD IF NOT EXISTS relation_subcategories ON TABLE studio_template_category
    TYPE array<record<studio_template_subcategory>>
    DEFAULT []
    COMMENT 'Liste des sous-catégories associées à cette catégorie';

-- ============================================================================
-- METADATA : Métadonnées
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE studio_template_category
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations internes système';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE studio_template_category
        TYPE option<string>
        COMMENT 'Notes internes libres';

    DEFINE FIELD IF NOT EXISTS metadata.template_count ON TABLE studio_template_category
        TYPE int
        DEFAULT 0
        COMMENT 'Nombre de templates dans cette catégorie (calculé automatiquement)';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE studio_template_category
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc timestamp : dates de création et de modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE studio_template_category
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE studio_template_category
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly, mis à jour à chaque update)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE studio_template_category
    TYPE string
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (généré à chaque mutation)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS identity_code_unique 
    ON studio_template_category FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code';

DEFINE INDEX IF NOT EXISTS status_active_idx 
    ON studio_template_category FIELDS status.is_active
    COMMENT 'Index sur les catégories actives';

DEFINE INDEX IF NOT EXISTS config_order_idx 
    ON studio_template_category FIELDS config.order
    COMMENT 'Index sur l\'ordre d\'affichage';