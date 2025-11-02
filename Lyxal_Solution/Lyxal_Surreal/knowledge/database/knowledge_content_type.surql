-- ============================================================================
-- Fichier : knowledge/database/knowledge_content_type.surql
-- Module : knowledge
-- TABLE : knowledge_content_type
-- Description : Référentiel dynamique des types de contenus de connaissance
--               (ex: SYNTAX_SURREAL, EXAMPLE_CORRECT_SURREAL, PATTERN_AI, TIP_UI)
--               Optimisé IA (auto-apprentissage, scoring, recommandation)
--
-- Auteur : Équipe Lyxal (via IA Assistant)
-- Date : 2025
-- ============================================================================

DEFINE TABLE knowledge_content_type TYPE NORMAL SCHEMAFULL
    COMMENT 'Référentiel dynamique des types de contenus de connaissance'
    PERMISSIONS
        FOR SELECT WHERE metadata.is_active = true
        FOR CREATE, UPDATE, DELETE NONE;

-- ============================================================================
-- IDENTITY : Code + i18n
-- ============================================================================
DEFINE FIELD IF NOT EXISTS identity ON TABLE knowledge_content_type
    TYPE object
    COMMENT 'Bloc identité : code unique et libellés i18n';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE knowledge_content_type
        TYPE string
        ASSERT $value != NONE
            AND $value != ""
            AND string::len($value) > 1
            AND string::uppercase($value) = $value
        COMMENT 'Code unique du type au format UPPER_SNAKE_CASE (ex: SYNTAX_SURREAL, PATTERN_AI)';

    DEFINE FIELD IF NOT EXISTS identity.label_key ON TABLE knowledge_content_type
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n : nom du type (affichage UI)';

    DEFINE FIELD IF NOT EXISTS identity.description_key ON TABLE knowledge_content_type
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n : description détaillée du type (optionnel)';

-- ============================================================================
-- METADATA : Status + Ordre + Version
-- ============================================================================
DEFINE FIELD IF NOT EXISTS metadata ON TABLE knowledge_content_type
    TYPE object
    COMMENT 'Bloc métadonnées du type de contenu';

    DEFINE FIELD IF NOT EXISTS metadata.is_active ON TABLE knowledge_content_type
        TYPE bool
        DEFAULT true
        COMMENT 'Le type est actif et peut être utilisé';

    DEFINE FIELD IF NOT EXISTS metadata.display_order ON TABLE knowledge_content_type
        TYPE int
        DEFAULT 0
        COMMENT 'Ordre d’affichage (0 par défaut, positif = prioritaire)';

    DEFINE FIELD IF NOT EXISTS metadata.version_label ON TABLE knowledge_content_type
        TYPE string
        DEFAULT "1.0.0"
        COMMENT 'Version fonctionnelle du type';

-- ============================================================================
-- METADATA.IA : Bloc optimisé IA (V2-B + U3)
-- ============================================================================
DEFINE FIELD IF NOT EXISTS metadata.ai ON TABLE knowledge_content_type
    TYPE object
    COMMENT 'Bloc IA : informations pour agents IA, ranking, apprentissage';

    -- Priorité IA globale (1 = faible, 5 = très prioritaire)
    DEFINE FIELD IF NOT EXISTS metadata.ai.priority ON TABLE knowledge_content_type
        TYPE int
        DEFAULT 3
        ASSERT $value >= 1 AND $value <= 5
        COMMENT 'Priorité IA pour choisir ce type lors de la génération';

    -- Poids IA (0.0 à 1.0) pour ranking et scoring
    DEFINE FIELD IF NOT EXISTS metadata.ai.weight ON TABLE knowledge_content_type
        TYPE number
        DEFAULT 0.5
        ASSERT $value >= 0 AND $value <= 1
        COMMENT 'Poids IA dans le ranking (0 = faible importance, 1 = très important)';

    -- Niveau : structure avancée (label + level)
    DEFINE FIELD IF NOT EXISTS metadata.ai.level ON TABLE knowledge_content_type
        TYPE object
        COMMENT 'Niveau de complexité conseillé du contenu pour IA et humain';

        DEFINE FIELD IF NOT EXISTS metadata.ai.level.level ON TABLE knowledge_content_type
            TYPE int
            DEFAULT 1
            ASSERT $value >= 1 AND $value <= 5
            COMMENT 'Niveau numérique (1 = débutant, ... 5 = expert)';

        DEFINE FIELD IF NOT EXISTS metadata.ai.level.label ON TABLE knowledge_content_type
            TYPE string
            DEFAULT "BEGINNER"
            COMMENT 'Label du niveau (BEGINNER, INTERMEDIATE, ADVANCED, EXPERT)';

    -- TAILLE / STRUCTURE
    DEFINE FIELD IF NOT EXISTS metadata.ai.context_length ON TABLE knowledge_content_type
        TYPE int
        DEFAULT 500
        COMMENT 'Taille recommandée (en tokens) pour l\'IA';

    DEFINE FIELD IF NOT EXISTS metadata.ai.is_structured ON TABLE knowledge_content_type
        TYPE bool
        DEFAULT false
        COMMENT 'True si le contenu de ce type est structuré (ex: JSON, schema, pattern)';

    -- Score minimal avant qu’une IA puisse utiliser ce type
    DEFINE FIELD IF NOT EXISTS metadata.ai.min_quality_score ON TABLE knowledge_content_type
        TYPE number
        DEFAULT 0.5
        ASSERT $value >= 0 AND $value <= 1
        COMMENT 'Score minimal requis par IA avant utilisation (auto-amélioration)';

    -- IA Use Cases enrichis (U3)
    DEFINE FIELD IF NOT EXISTS metadata.ai.use_cases ON TABLE knowledge_content_type
        TYPE option<array<object>>
        COMMENT 'Liste de cas d\'usage IA (ex: generation, validation, teaching, etc.), enrichis pour auto-learning';

        DEFINE FIELD IF NOT EXISTS metadata.ai.use_cases.*.code ON TABLE knowledge_content_type
            TYPE string
            COMMENT 'Code du cas d\'usage (UPPER_SNAKE_CASE)';

        DEFINE FIELD IF NOT EXISTS metadata.ai.use_cases.*.weight ON TABLE knowledge_content_type
            TYPE number
            DEFAULT 0.5
            ASSERT $value >= 0 AND $value <= 1
            COMMENT 'Poids IA du cas d\'usage';

        DEFINE FIELD IF NOT EXISTS metadata.ai.use_cases.*.description_key ON TABLE knowledge_content_type
            TYPE option<record<i18n_key>>
            REFERENCE ON DELETE REJECT  
            COMMENT 'Clé i18n pour description du cas d\'usage (optionnel)';

        DEFINE FIELD IF NOT EXISTS metadata.ai.use_cases.*.min_quality_score ON TABLE knowledge_content_type
            TYPE number
            DEFAULT 0.3
            ASSERT $value >= 0 AND $value <= 1
            COMMENT 'Score minimal IA pour utiliser ce cas d\'usage';

        DEFINE FIELD IF NOT EXISTS metadata.ai.use_cases.*.recommended ON TABLE knowledge_content_type
            TYPE bool
            DEFAULT false
            COMMENT 'True si IA doit privilégier ce use-case par défaut';

-- ============================================================================
-- INDEXES
-- ============================================================================
DEFINE INDEX idx_content_type_code ON knowledge_content_type
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code';

DEFINE INDEX idx_content_type_active ON knowledge_content_type
    FIELDS metadata.is_active
    COMMENT 'Index sur les types actifs';
