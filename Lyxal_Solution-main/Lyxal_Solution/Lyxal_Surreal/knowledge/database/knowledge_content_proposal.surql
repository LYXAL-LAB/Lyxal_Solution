-- ============================================================================
-- Fichier : knowledge/database/knowledge_content_proposal.surql
-- Module : knowledge
-- TABLE : knowledge_content_proposal
-- Description : Propositions de contenus générées automatiquement par IA pour enrichir le système
-- Basées sur les gaps détectés, nécessitent validation humaine avant activation
--
-- Dépendances : knowledge_gap, knowledge_topic, knowledge_content_type, i18n_key
-- Auteur : Équipe Lyxal (via IA)
-- Date : 2025
-- ============================================================================

DEFINE TABLE knowledge_content_proposal TYPE NORMAL SCHEMAFULL
    COMMENT "Propositions de contenus générées automatiquement par IA pour enrichissement du système"
    PERMISSIONS
        FOR SELECT FULL
        FOR CREATE FULL
        FOR UPDATE FULL
        FOR DELETE FULL;

-- ============================================================================
-- RELATIONS : Références vers gap et topic
-- ============================================================================

DEFINE FIELD IF NOT EXISTS gap ON TABLE knowledge_content_proposal
    TYPE option<record<knowledge_gap>>
    REFERENCE ON DELETE UNSET
    COMMENT "Gap détecté à l'origine de cette proposition (optionnel)";

DEFINE FIELD IF NOT EXISTS topic ON TABLE knowledge_content_proposal
    TYPE record<knowledge_topic>
    REFERENCE ON DELETE CASCADE
    ASSERT $value != NONE
    COMMENT "Topic auquel cette proposition de contenu est rattachée";

DEFINE FIELD IF NOT EXISTS content_type ON TABLE knowledge_content_proposal
    TYPE record<knowledge_content_type>
    REFERENCE ON DELETE REJECT
    ASSERT $value != NONE
    COMMENT "Type de contenu proposé (ex: SYNTAX, RULE, EXAMPLE_CORRECT)";

-- ============================================================================
-- PROPOSITION : Contenu proposé (structure U3-FLEX)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE knowledge_content_proposal
    TYPE object
    COMMENT "Identité de la proposition de contenu";

    DEFINE FIELD IF NOT EXISTS identity.title_key ON TABLE knowledge_content_proposal
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT "Clé i18n pour le titre de la proposition";

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE knowledge_content_proposal
        TYPE string
        COMMENT "Slug unique pour identifier la proposition";

    DEFINE FIELD IF NOT EXISTS identity.description_key ON TABLE knowledge_content_proposal
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE UNSET
        COMMENT "Clé i18n pour la description de la proposition";

DEFINE FIELD IF NOT EXISTS content ON TABLE knowledge_content_proposal
    TYPE object
    COMMENT "Contenu proposé (structure U3-FLEX)";

    -- Texte
    DEFINE FIELD IF NOT EXISTS content.text_key ON TABLE knowledge_content_proposal
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE UNSET
        COMMENT "Clé i18n pour le contenu textuel proposé";

    -- Code
    DEFINE FIELD IF NOT EXISTS content.code ON TABLE knowledge_content_proposal
        TYPE option<array<object>>
        COMMENT "Array de blocs de code proposés";

        DEFINE FIELD IF NOT EXISTS content.code.*.language ON TABLE knowledge_content_proposal
            TYPE string
            COMMENT "Langage du bloc de code (ex: surql, javascript)";

        DEFINE FIELD IF NOT EXISTS content.code.*.value ON TABLE knowledge_content_proposal
            TYPE string
            COMMENT "Code proposé";

        DEFINE FIELD IF NOT EXISTS content.code.*.explanation_key ON TABLE knowledge_content_proposal
            TYPE option<record<i18n_key>>
            REFERENCE ON DELETE UNSET
            COMMENT "Clé i18n : explication du code (optionnelle)";

    -- Examples
    DEFINE FIELD IF NOT EXISTS content.examples ON TABLE knowledge_content_proposal
        TYPE option<object>
        COMMENT "Exemples proposés (corrects/incorrects)";

        DEFINE FIELD IF NOT EXISTS content.examples.correct ON TABLE knowledge_content_proposal
            TYPE option<array<object>>
            COMMENT "Exemples corrects proposés";

            DEFINE FIELD IF NOT EXISTS content.examples.correct.*.code ON TABLE knowledge_content_proposal
                TYPE option<string>
                COMMENT "Code correct (si applicable)";

            DEFINE FIELD IF NOT EXISTS content.examples.correct.*.text_key ON TABLE knowledge_content_proposal
                TYPE option<record<i18n_key>>
                REFERENCE ON DELETE UNSET
                COMMENT "Clé i18n : explication de l'exemple correct";

        DEFINE FIELD IF NOT EXISTS content.examples.incorrect ON TABLE knowledge_content_proposal
            TYPE option<array<object>>
            COMMENT "Exemples incorrects proposés";

            DEFINE FIELD IF NOT EXISTS content.examples.incorrect.*.code ON TABLE knowledge_content_proposal
                TYPE option<string>
                COMMENT "Code incorrect (si applicable)";

            DEFINE FIELD IF NOT EXISTS content.examples.incorrect.*.text_key ON TABLE knowledge_content_proposal
                TYPE option<record<i18n_key>>
                REFERENCE ON DELETE UNSET
                COMMENT "Clé i18n : pourquoi cet exemple est incorrect";

    -- Prompt
    DEFINE FIELD IF NOT EXISTS content.prompt ON TABLE knowledge_content_proposal
        TYPE option<string>
        COMMENT "Prompt proposé pour utilisation IA";

    -- JSON
    DEFINE FIELD IF NOT EXISTS content.json ON TABLE knowledge_content_proposal
        TYPE option<object>
        COMMENT "Données JSON proposées";

-- ============================================================================
-- GENERATION : Informations sur la génération automatique
-- ============================================================================

DEFINE FIELD IF NOT EXISTS generation ON TABLE knowledge_content_proposal
    TYPE object
    COMMENT "Informations sur la génération de la proposition";

    DEFINE FIELD IF NOT EXISTS generation.method ON TABLE knowledge_content_proposal
        TYPE string
        DEFAULT "automatic"
        ASSERT $value IN ["automatic", "manual", "ai_assisted"]
        COMMENT "Méthode de génération : automatic (IA seule), manual (humain), ai_assisted (IA assistée par humain)";

    DEFINE FIELD IF NOT EXISTS generation.model ON TABLE knowledge_content_proposal
        TYPE option<string>
        COMMENT "Modèle IA utilisé pour générer la proposition (optionnel)";

    DEFINE FIELD IF NOT EXISTS generation.generated_at ON TABLE knowledge_content_proposal
        TYPE datetime
        DEFAULT time::now()
        COMMENT "Date et heure de génération de la proposition";

    DEFINE FIELD IF NOT EXISTS generation.confidence ON TABLE knowledge_content_proposal
        TYPE number
        DEFAULT 0.5
        ASSERT $value >= 0 AND $value <= 1
        COMMENT "Niveau de confiance de la génération (0 = faible, 1 = élevé)";

    DEFINE FIELD IF NOT EXISTS generation.source_context ON TABLE knowledge_content_proposal
        TYPE option<string>
        COMMENT "Contexte source utilisé pour la génération (ex: contenu référencé, documentation, etc.)";

-- ============================================================================
-- REVIEW : État de révision et validation
-- ============================================================================

DEFINE FIELD IF NOT EXISTS review ON TABLE knowledge_content_proposal
    TYPE object
    COMMENT "État de révision et validation de la proposition";

    DEFINE FIELD IF NOT EXISTS review.status ON TABLE knowledge_content_proposal
        TYPE string
        DEFAULT "draft"
        ASSERT $value IN ["draft", "pending_review", "approved", "rejected", "merged"]
        COMMENT "Statut de révision : draft (brouillon), pending_review (en attente), approved (approuvé), rejected (rejeté), merged (fusionné dans knowledge_content)";

    DEFINE FIELD IF NOT EXISTS review.reviewed_at ON TABLE knowledge_content_proposal
        TYPE option<datetime>
        COMMENT "Date et heure de révision";

    DEFINE FIELD IF NOT EXISTS review.reviewed_by ON TABLE knowledge_content_proposal
        TYPE option<string>
        COMMENT "Identifiant de la personne/IA qui a révisé la proposition";

    DEFINE FIELD IF NOT EXISTS review.review_notes ON TABLE knowledge_content_proposal
        TYPE option<string>
        COMMENT "Notes de révision (commentaires, corrections, etc.)";

    DEFINE FIELD IF NOT EXISTS review.rejection_reason ON TABLE knowledge_content_proposal
        TYPE option<string>
        COMMENT "Raison du rejet si status = rejected";

    DEFINE FIELD IF NOT EXISTS review.merged_content ON TABLE knowledge_content_proposal
        TYPE option<record<knowledge_content>>
        REFERENCE ON DELETE UNSET
        COMMENT "Référence vers le contenu créé si status = merged";

-- ============================================================================
-- METADATA : Métadonnées de la proposition
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE knowledge_content_proposal
    TYPE object
    COMMENT "Métadonnées de la proposition";

    DEFINE FIELD IF NOT EXISTS metadata.priority ON TABLE knowledge_content_proposal
        TYPE int
        DEFAULT 0
        COMMENT "Priorité de traitement (0 = normale, plus élevé = plus prioritaire)";

    DEFINE FIELD IF NOT EXISTS metadata.quality_score ON TABLE knowledge_content_proposal
        TYPE number
        DEFAULT 0.5
        ASSERT $value >= 0 AND $value <= 1
        COMMENT "Score de qualité estimé de la proposition (0 = faible, 1 = excellent)";

    DEFINE FIELD IF NOT EXISTS metadata.version_label ON TABLE knowledge_content_proposal
        TYPE option<string>
        COMMENT "Label de version si applicable (ex: v1.0, v2.1)";

    DEFINE FIELD IF NOT EXISTS metadata.is_active ON TABLE knowledge_content_proposal
        TYPE bool
        DEFAULT true
        COMMENT "La proposition est active (peut être désactivée sans suppression)";

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX idx_proposal_gap ON knowledge_content_proposal
    FIELDS gap
    COMMENT "Index sur le gap associé";

DEFINE INDEX idx_proposal_topic ON knowledge_content_proposal
    FIELDS topic
    COMMENT "Index sur le topic associé";

DEFINE INDEX idx_proposal_content_type ON knowledge_content_proposal
    FIELDS content_type
    COMMENT "Index sur le type de contenu";

DEFINE INDEX idx_proposal_status ON knowledge_content_proposal
    FIELDS review.status
    COMMENT "Index sur le statut de révision";

DEFINE INDEX idx_proposal_active ON knowledge_content_proposal
    FIELDS metadata.is_active
    COMMENT "Index sur le statut actif";

DEFINE INDEX idx_proposal_priority ON knowledge_content_proposal
    FIELDS metadata.priority
    COMMENT "Index sur la priorité";

DEFINE INDEX idx_proposal_slug ON knowledge_content_proposal
    FIELDS identity.slug
    UNIQUE
    COMMENT "Index UNIQUE sur le slug";

DEFINE INDEX idx_proposal_pending ON knowledge_content_proposal
    FIELDS review.status, metadata.priority
    COMMENT "Index composite pour requêtes de propositions en attente";

