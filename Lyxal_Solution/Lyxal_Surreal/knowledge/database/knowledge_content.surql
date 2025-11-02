-- ============================================================================
-- Fichier : knowledge/database/knowledge_content.surql
-- Module : knowledge
-- TABLE : knowledge_content
-- Description : Contenu de connaissance universel (multi-formats) pour chaque topic
-- Compatible Humain + IA (U3-FLEX)
--
-- Dépendances : knowledge_topic, tag, url
-- Auteur : Équipe Lyxal (via IA)
-- Date : 2025
-- ============================================================================

DEFINE TABLE knowledge_content TYPE NORMAL SCHEMAFULL
    COMMENT 'Contenus de connaissance rattachés à un topic, multi-format et utilisables par Humain + IA'
    PERMISSIONS
        FOR SELECT WHERE metadata.is_active = true
        FOR CREATE, UPDATE, DELETE NONE;

-- ============================================================================
-- RELATION : Référence vers le topic parent
-- ============================================================================

DEFINE FIELD IF NOT EXISTS topic ON TABLE knowledge_content
    TYPE record<knowledge_topic>
    REFERENCE ON DELETE CASCADE
    ASSERT $value != NONE
    COMMENT 'Topic auquel ce contenu est rattaché';

-- ============================================================================
-- IDENTITY : Identité + classification
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE knowledge_content
    TYPE object
    COMMENT 'Bloc identité du contenu';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE knowledge_content
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 2
        COMMENT 'Slug unique lisible pour UI et navigation (ex: "define-field-basic-syntax")';

    DEFINE FIELD IF NOT EXISTS identity.content_type ON TABLE knowledge_content
        TYPE record<knowledge_content_type>
        REFERENCE ON DELETE REJECT
        COMMENT 'Type de contenu lié au référentiel dynamique knowledge_content_type';

    DEFINE FIELD IF NOT EXISTS identity.title ON TABLE knowledge_content
        TYPE option<string>
        COMMENT 'Titre court du contenu (optionnel)';

    DEFINE FIELD IF NOT EXISTS identity.description ON TABLE knowledge_content
        TYPE option<string>
        COMMENT 'Description courte du contenu (optionnel)';

-- ============================================================================
-- CONTENT : Contenu U3-FLEX (multi-format, tout optionnel)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON TABLE knowledge_content
    TYPE object
    COMMENT 'Bloc principal du contenu (texte, code, exemples, média, etc.)';

    -- Contenu texte principal (lisible humain + IA)
    DEFINE FIELD IF NOT EXISTS content.text ON TABLE knowledge_content
        TYPE option<string>
        COMMENT 'Contenu textuel principal (explication lisible + structurée)';

    -- Multi-code blocks (plusieurs langages possibles)
    DEFINE FIELD IF NOT EXISTS content.code ON TABLE knowledge_content
        TYPE option<array<object>>
        COMMENT 'Liste de blocs de code (multi-langage)';

        DEFINE FIELD IF NOT EXISTS content.code.language ON TABLE knowledge_content
            TYPE string
            COMMENT 'Langage du code (ex: "surql", "js", "json")';

        DEFINE FIELD IF NOT EXISTS content.code.value ON TABLE knowledge_content
            TYPE string
            COMMENT 'Code source';

        DEFINE FIELD IF NOT EXISTS content.code.explanation ON TABLE knowledge_content
            TYPE option<string>
            COMMENT 'Explication du code (optionnelle)';

    -- Prompt optimisé IA
    DEFINE FIELD IF NOT EXISTS content.prompt ON TABLE knowledge_content
        TYPE option<string>
        COMMENT 'Version prompt-ready optimisée pour IA';

    -- Données JSON structurées
    DEFINE FIELD IF NOT EXISTS content.json ON TABLE knowledge_content
        TYPE option<object>
        COMMENT 'Contenu structuré JSON (schéma, données, config, etc.)';

    -- Contexte, do/don’t, quand utiliser
    DEFINE FIELD IF NOT EXISTS content.context ON TABLE knowledge_content
        TYPE option<string>
        COMMENT 'Contexte d\'utilisation, bonnes pratiques, do/don\'t, use cases';

    -- Exemples corrects et incorrects
    DEFINE FIELD IF NOT EXISTS content.examples ON TABLE knowledge_content
        TYPE option<object>
        COMMENT 'Exemples corrects / incorrects avec explications';

        DEFINE FIELD IF NOT EXISTS content.examples.correct ON TABLE knowledge_content
            TYPE option<array<object>>
            COMMENT 'Liste d\'exemples corrects';

            DEFINE FIELD IF NOT EXISTS content.examples.correct.text ON TABLE knowledge_content
                TYPE option<string>
                COMMENT 'Explication de l\'exemple correct';

            DEFINE FIELD IF NOT EXISTS content.examples.correct.code ON TABLE knowledge_content
                TYPE option<string>
                COMMENT 'Code correct (si applicable)';

        DEFINE FIELD IF NOT EXISTS content.examples.incorrect ON TABLE knowledge_content
            TYPE option<array<object>>
            COMMENT 'Liste d\'exemples incorrects';

            DEFINE FIELD IF NOT EXISTS content.examples.incorrect.text ON TABLE knowledge_content
                TYPE option<string>
                COMMENT 'Pourquoi cet exemple est incorrect';

            DEFINE FIELD IF NOT EXISTS content.examples.incorrect.code ON TABLE knowledge_content
                TYPE option<string>
                COMMENT 'Code incorrect (si applicable)';

    -- Média (images, pdf, etc.) via record<url>
    DEFINE FIELD IF NOT EXISTS content.media ON TABLE knowledge_content
        TYPE option<array<record<url>>>
        COMMENT 'Médias associés : images, pdf, vidéos, etc. via record<url>';

-- ============================================================================
-- CATEGORIZATION : Tags (référentiel structuré)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS tags ON TABLE knowledge_content
    TYPE option<array<record<tag>>>
    COMMENT 'Tags associés au contenu';

-- ============================================================================
-- METADATA : Métadonnées du contenu
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE knowledge_content
    TYPE object
    COMMENT 'Métadonnées';

    DEFINE FIELD IF NOT EXISTS metadata.priority ON TABLE knowledge_content
        TYPE int
        DEFAULT 0
        COMMENT 'Priorité d\'affichage (0 par défaut)';

    DEFINE FIELD IF NOT EXISTS metadata.is_active ON TABLE knowledge_content
        TYPE bool
        DEFAULT true
        COMMENT 'Le contenu est actif';

    DEFINE FIELD IF NOT EXISTS metadata.version_label ON TABLE knowledge_content
        TYPE string
        DEFAULT "1.0.0"
        COMMENT 'Version fonctionnelle du contenu';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX idx_content_topic ON knowledge_content 
    FIELDS topic
    COMMENT 'Index sur le topic';

DEFINE INDEX idx_content_type ON knowledge_content 
    FIELDS identity.content_type
    COMMENT 'Index sur le type de contenu';

DEFINE INDEX idx_content_slug ON knowledge_content 
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX idx_content_active ON knowledge_content 
    FIELDS metadata.is_active
    COMMENT 'Index sur le statut actif';