-- ============================================================================
-- Fichier : studio/database/studio/studio_template_subcategory.surql
-- Module : studio
-- TABLE : studio_template_subcategory
-- Description : Sous-catégories de templates avec i18n (hitech, mode, designer, etc.)
-- 
-- Fichier de seeds : 
-- studio/reference/studio/template/studio_template_subcategory_seeds.surql
--
-- Fichier de i18n :
-- studio/reference/i18n/studio/template/studio_template_subcategory_i18n_key_seeds.surql
-- studio/reference/i18n/studio/template/studio_template_subcategory_i18n_translation_seeds.surql
--
-- Fichier de tests :
-- studio/test/studio_template_subcategory_test.surql
--
-- Fichier de documentation :
-- studio/documentation/studio/template/studio_template_subcategory_documentation.md
--
-- Dépendances : studio_template_category, theme_color, icon, i18n_key
--
-- Déploiement : Après la table studio_template_category
--
-- Référence : studio/database/studio/studio_template_category.surql
--              studio/reference/studio/template/studio_template_subcategory_seeds.surql
--              studio/reference/i18n/studio/template/studio_template_subcategory_i18n_key_seeds.surql
--              studio/reference/i18n/studio/template/studio_template_subcategory_i18n_translation_seeds.surql
--              studio/test/studio_template_subcategory_test.surql
--              studio/documentation/studio/template/studio_template_subcategory_documentation.md
--
-- Auteur : Équipe Lyxal (via AI Assistant)
-- Date : 31 octobre 2025
-- Version : 1.0
--
-- Changelog :
-- - 31 octobre 2025 : Création de la table studio_template_subcategory
-- - 31 octobre 2025 : Ajout des champs identity, presentation, relation, config, status, metadata, timestamp
-- - 31 octobre 2025 : Ajout des index identity_code_unique, relation_category_idx, status_active_idx, relation_order_idx
-- - 31 octobre 2025 : Ajout des permissions FOR SELECT FULL, FOR CREATE, UPDATE, DELETE NONE
-- - 31 octobre 2025 : Ajout des commentaires
-- - 31 octobre 2025 : Ajout des seeds
-- - 31 octobre 2025 : Ajout des tests
-- - 31 octobre 2025 : Ajout des fichiers de seeds, i18n, tests, documentation
-- - 31 octobre 2025 : Ajout des dépendances
-- - 31 octobre 2025 : Ajout des permissions
-- - 31 octobre 2025 : Ajout des commentaires
-- - 31 octobre 2025 : Ajout des index
-- - 31 octobre 2025 : Ajout des champs
-- - 31 octobre 2025 : Ajout des seeds
-- ============================================================================

DEFINE TABLE IF NOT EXISTS studio_template_subcategory TYPE NORMAL SCHEMAFULL
    COMMENT 'Sous-catégories de templates - Organisation secondaire avec i18n'
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE;

-- ============================================================================
-- IDENTITY : Identification unique de la sous-catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE studio_template_subcategory
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification unique de la sous-catégorie';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE studio_template_subcategory
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0
        COMMENT 'Code unique de la sous-catégorie (snake_case) : "hitech", "mode", "designer"';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE studio_template_subcategory
        TYPE string
        ASSERT string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug pour URL friendly : "hitech", "mode", "designer"';

-- ============================================================================
-- PRESENTATION : Présentation de la sous-catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE studio_template_subcategory
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc présentation : affichage avec i18n';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE studio_template_subcategory
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom de la sous-catégorie (i18n) : "HiTech", "Mode", "Designer"';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE studio_template_subcategory
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Description de la sous-catégorie (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.icon ON TABLE studio_template_subcategory
        TYPE option<record<icon>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Icône représentative de la sous-catégorie';

-- ============================================================================
-- RELATION : Relation avec la catégorie parente
-- ============================================================================

DEFINE FIELD IF NOT EXISTS relation ON TABLE studio_template_subcategory
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc relation : lien avec la catégorie parente';

    DEFINE FIELD IF NOT EXISTS relation.category ON TABLE studio_template_subcategory
        TYPE record<studio_template_category>
        REFERENCE ON DELETE CASCADE
        ASSERT $value != NONE
        COMMENT 'Catégorie parente : studio_template_category:ecommerce';

    DEFINE FIELD IF NOT EXISTS relation.order ON TABLE studio_template_subcategory
        TYPE int
        DEFAULT 0
        ASSERT $value >= 0
        COMMENT 'Ordre d\'affichage dans la catégorie parente';

-- ============================================================================
-- CONFIG : Configuration de la sous-catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE studio_template_subcategory
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc configuration : paramètres visuels et comportementaux';

    DEFINE FIELD IF NOT EXISTS config.color ON TABLE studio_template_subcategory
        TYPE option<record<theme_color>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Couleur associée à la sous-catégorie (hex, variable CSS, etc.)';

-- ============================================================================
-- STATUS : Statut de la sous-catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE studio_template_subcategory
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc statut : état de la sous-catégorie';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE studio_template_subcategory
        TYPE bool
        DEFAULT true
        COMMENT 'Sous-catégorie active (visible) ?';

    DEFINE FIELD IF NOT EXISTS status.is_default ON TABLE studio_template_subcategory
        TYPE bool
        DEFAULT false
        COMMENT 'Sous-catégorie par défaut dans sa catégorie ?';

-- ============================================================================
-- METADATA : Métadonnées
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE studio_template_subcategory
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations système internes';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE studio_template_subcategory
        TYPE option<string>
        COMMENT 'Notes internes libres';

    DEFINE FIELD IF NOT EXISTS metadata.template_count ON TABLE studio_template_subcategory
        TYPE int
        DEFAULT 0
        COMMENT 'Nombre de templates dans cette sous-catégorie (calculé automatiquement)';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE studio_template_subcategory
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc timestamp : dates de création et de modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE studio_template_subcategory
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE studio_template_subcategory
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly, mis à jour à chaque update)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE studio_template_subcategory
    TYPE string
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (généré à chaque mutation)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS identity_code_unique 
    ON studio_template_subcategory FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code';

DEFINE INDEX IF NOT EXISTS relation_category_idx 
    ON studio_template_subcategory FIELDS relation.category
    COMMENT 'Index sur la catégorie parente';

DEFINE INDEX IF NOT EXISTS status_active_idx 
    ON studio_template_subcategory FIELDS status.is_active
    COMMENT 'Index sur les sous-catégories actives';

DEFINE INDEX IF NOT EXISTS relation_order_idx 
    ON studio_template_subcategory FIELDS relation.category, relation.order
    COMMENT 'Index sur la catégorie parente et l\'ordre';