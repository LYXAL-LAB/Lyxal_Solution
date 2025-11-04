-- ============================================================================
-- Fichier : knowledge/database/knowledge_content.surql
-- Module : knowledge
-- TABLE : knowledge_content
-- Description : Contenu de connaissance universel (multi-formats) pour chaque topic
-- Compatible Humain + IA (U3-FLEX)
--
-- Dépendances : knowledge_topic, knowledge_content_type, tag, url, i18n_key
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

    DEFINE FIELD IF NOT EXISTS identity.title_key ON TABLE knowledge_content
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n : titre court du contenu (optionnel)';

    DEFINE FIELD IF NOT EXISTS identity.description_key ON TABLE knowledge_content
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n : description courte du contenu (optionnel)';

-- ============================================================================
-- CONTENT : Contenu U3-FLEX (multi-format, tout optionnel)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON TABLE knowledge_content
    TYPE object
    COMMENT 'Bloc principal du contenu (texte, code, exemples, média, etc.)';

    -- Contenu texte principal (lisible humain + IA)
    DEFINE FIELD IF NOT EXISTS content.text_key ON TABLE knowledge_content
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n : contenu textuel principal (explication lisible + structurée)';

    -- Multi-code blocks (plusieurs langages possibles)
    DEFINE FIELD IF NOT EXISTS content.code ON TABLE knowledge_content
        TYPE option<array<object>>
        COMMENT 'Liste de blocs de code (multi-langage)';

        DEFINE FIELD IF NOT EXISTS content.code.*.language ON TABLE knowledge_content
            TYPE string
            COMMENT 'Langage du code (ex: "surql", "js", "json")';

        DEFINE FIELD IF NOT EXISTS content.code.*.value ON TABLE knowledge_content
            TYPE string
            COMMENT 'Code source';

        DEFINE FIELD IF NOT EXISTS content.code.*.explanation_key ON TABLE knowledge_content
            TYPE option<record<i18n_key>>
            REFERENCE ON DELETE REJECT
            COMMENT 'Clé i18n : explication du code (optionnelle)';

    -- Prompt optimisé IA
    DEFINE FIELD IF NOT EXISTS content.prompt ON TABLE knowledge_content
        TYPE option<string>
        COMMENT 'Version prompt-ready optimisée pour IA';

    -- Données JSON structurées
    DEFINE FIELD IF NOT EXISTS content.json ON TABLE knowledge_content
        TYPE option<object>
        COMMENT 'Contenu structuré JSON (schéma, données, config, etc.)';

    -- Contexte, do/don't, quand utiliser
    DEFINE FIELD IF NOT EXISTS content.context_key ON TABLE knowledge_content
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n : contexte d\'utilisation, bonnes pratiques, do/don\'t, use cases';

    -- Exemples corrects et incorrects
    DEFINE FIELD IF NOT EXISTS content.examples ON TABLE knowledge_content
        TYPE option<object>
        COMMENT 'Exemples corrects / incorrects avec explications';

        DEFINE FIELD IF NOT EXISTS content.examples.correct ON TABLE knowledge_content
            TYPE option<array<object>>
            COMMENT 'Liste d\'exemples corrects';

            DEFINE FIELD IF NOT EXISTS content.examples.correct.*.text_key ON TABLE knowledge_content
                TYPE option<record<i18n_key>>
                REFERENCE ON DELETE REJECT
                COMMENT 'Clé i18n : explication de l\'exemple correct';

            DEFINE FIELD IF NOT EXISTS content.examples.correct.*.code ON TABLE knowledge_content
                TYPE option<string>
                COMMENT 'Code correct (si applicable)';

        DEFINE FIELD IF NOT EXISTS content.examples.incorrect ON TABLE knowledge_content
            TYPE option<array<object>>
            COMMENT 'Liste d\'exemples incorrects';

            DEFINE FIELD IF NOT EXISTS content.examples.incorrect.*.text_key ON TABLE knowledge_content
                TYPE option<record<i18n_key>>
                REFERENCE ON DELETE REJECT
                COMMENT 'Clé i18n : pourquoi cet exemple est incorrect';

            DEFINE FIELD IF NOT EXISTS content.examples.incorrect.*.code ON TABLE knowledge_content
                TYPE option<string>
                COMMENT 'Code incorrect (si applicable)';

    -- Média (images, pdf, etc.) via record<url>
    DEFINE FIELD IF NOT EXISTS content.media ON TABLE knowledge_content
        TYPE option<array<record<url>>>
        COMMENT 'Médias associés : images, pdf, vidéos, etc. via record<url>';

    -- Références vers d'autres contenus
    DEFINE FIELD IF NOT EXISTS content.references ON TABLE knowledge_content
        TYPE option<array<record<knowledge_content>>>
        COMMENT 'Références rapides vers d\'autres contenus de connaissance liés (pour relations simples). Pour relations structurées avec types spécifiques, utiliser la table knowledge_content_relation';

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

    DEFINE FIELD IF NOT EXISTS metadata.quality_score ON TABLE knowledge_content
        TYPE number
        DEFAULT 0.5
        ASSERT $value >= 0 AND $value <= 1
        COMMENT 'Score de qualité du contenu (0 = faible qualité, 1 = excellente qualité). Utilisé par l\'IA pour filtrer et prioriser les contenus selon leur qualité. Valeur par défaut : 0.5 (qualité moyenne)';

    -- ============================================================================
    -- ANALYTICS : Métriques d'usage pour optimiser le système
    -- ============================================================================

    DEFINE FIELD IF NOT EXISTS metadata.analytics ON TABLE knowledge_content
        TYPE object
        COMMENT 'Métriques d\'usage et analytics pour optimiser le système';

        DEFINE FIELD IF NOT EXISTS metadata.analytics.view_count ON TABLE knowledge_content
            TYPE int
            DEFAULT 0
            COMMENT 'Nombre total de consultations/vues du contenu (humain + IA)';

        DEFINE FIELD IF NOT EXISTS metadata.analytics.last_viewed ON TABLE knowledge_content
            TYPE option<datetime>
            COMMENT 'Date et heure de la dernière consultation du contenu';

        DEFINE FIELD IF NOT EXISTS metadata.analytics.ai_usage_count ON TABLE knowledge_content
            TYPE int
            DEFAULT 0
            COMMENT 'Nombre d\'utilisations spécifiques par des IA/agents IA';

    -- ============================================================================
    -- TRAINING : Métadonnées d'entraînement IA pour export et fine-tuning
    -- ============================================================================

    DEFINE FIELD IF NOT EXISTS metadata.training ON TABLE knowledge_content
        TYPE object
        COMMENT 'Métadonnées d\'entraînement IA pour export et fine-tuning de modèles spécialisés';

        DEFINE FIELD IF NOT EXISTS metadata.training.included_in_training ON TABLE knowledge_content
            TYPE bool
            DEFAULT false
            COMMENT 'Ce contenu est inclus dans les datasets d\'entraînement IA';

        DEFINE FIELD IF NOT EXISTS metadata.training.training_versions ON TABLE knowledge_content
            TYPE array<string>
            DEFAULT []
            COMMENT 'Versions de datasets d\'entraînement où ce contenu a été utilisé (ex: ["v1.0", "v1.1"])';

        DEFINE FIELD IF NOT EXISTS metadata.training.training_weight ON TABLE knowledge_content
            TYPE number
            DEFAULT 1.0
            ASSERT $value >= 0 AND $value <= 2
            COMMENT 'Poids d\'entraînement (1.0 = normal, 2.0 = double poids, 0.5 = demi-poids). Permet de pondérer l\'importance du contenu dans les datasets';

        DEFINE FIELD IF NOT EXISTS metadata.training.last_training_date ON TABLE knowledge_content
            TYPE option<datetime>
            COMMENT 'Date de la dernière utilisation de ce contenu dans un dataset d\'entraînement';

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

DEFINE INDEX idx_content_training ON knowledge_content 
    FIELDS metadata.training.included_in_training
    COMMENT 'Index sur l\'inclusion dans les datasets d\'entraînement';