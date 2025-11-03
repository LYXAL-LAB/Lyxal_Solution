-- ============================================================================
-- Fichier : knowledge/database/knowledge_feedback.surql
-- Module : knowledge
-- TABLE : knowledge_feedback
-- Description : Feedback sur les contenus de connaissance pour amélioration continue
-- Permet aux IA et humains de remonter des retours sur la qualité et pertinence des contenus
--
-- Dépendances : knowledge_content
-- Auteur : Équipe Lyxal (via IA)
-- Date : 2025
-- ============================================================================

DEFINE TABLE knowledge_feedback TYPE NORMAL SCHEMAFULL
    COMMENT 'Feedback sur les contenus de connaissance pour amélioration continue'
    PERMISSIONS
        FOR SELECT FULL
        FOR CREATE FULL
        FOR UPDATE NONE
        FOR DELETE FULL;

-- ============================================================================
-- RELATION : Référence vers le contenu concerné
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON TABLE knowledge_feedback
    TYPE record<knowledge_content>
    REFERENCE ON DELETE CASCADE
    ASSERT $value != NONE
    COMMENT 'Contenu de connaissance concerné par ce feedback';

-- ============================================================================
-- FEEDBACK : Type et détails du feedback
-- ============================================================================

DEFINE FIELD IF NOT EXISTS feedback_type ON TABLE knowledge_feedback
    TYPE string
    ASSERT $value IN ["positive", "negative", "suggestion", "correction"]
    COMMENT 'Type de feedback : positive (contenu utile), negative (contenu inutile/erroné), suggestion (amélioration proposée), correction (erreur identifiée)';

DEFINE FIELD IF NOT EXISTS score ON TABLE knowledge_feedback
    TYPE number
    DEFAULT 0.5
    ASSERT $value >= 0 AND $value <= 1
    COMMENT 'Score de qualité perçu (0 = très mauvais, 1 = excellent). Utilisé pour calculer le quality_score automatique du contenu';

DEFINE FIELD IF NOT EXISTS comment ON TABLE knowledge_feedback
    TYPE option<string>
    COMMENT 'Commentaire libre détaillant le feedback (optionnel)';

-- ============================================================================
-- SOURCE : Origine du feedback
-- ============================================================================

DEFINE FIELD IF NOT EXISTS source ON TABLE knowledge_feedback
    TYPE object
    COMMENT "Informations sur l'origine du feedback";

    DEFINE FIELD IF NOT EXISTS source.type ON TABLE knowledge_feedback
        TYPE string
        DEFAULT "human"
        ASSERT $value IN ["human", "ai", "system"]
        COMMENT 'Type de source : human (retour humain), ai (retour IA/agent), system (retour système automatique)';

    DEFINE FIELD IF NOT EXISTS source.identifier ON TABLE knowledge_feedback
        TYPE option<string>
        COMMENT 'Identifiant de la source (nom utilisateur, ID agent IA, etc.) - optionnel';

-- ============================================================================
-- METADATA : Métadonnées du feedback
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE knowledge_feedback
    TYPE object
    COMMENT 'Métadonnées du feedback';

    DEFINE FIELD IF NOT EXISTS metadata.is_active ON TABLE knowledge_feedback
        TYPE bool
        DEFAULT true
        COMMENT 'Le feedback est actif (peut être désactivé sans suppression)';

    DEFINE FIELD IF NOT EXISTS metadata.is_resolved ON TABLE knowledge_feedback
        TYPE bool
        DEFAULT false
        COMMENT 'Le feedback a été traité/résolu (pour suggestions et corrections)';

    DEFINE FIELD IF NOT EXISTS metadata.resolved_at ON TABLE knowledge_feedback
        TYPE option<datetime>
        COMMENT 'Date et heure de résolution du feedback';

    DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE knowledge_feedback
        TYPE datetime
        DEFAULT time::now()
        COMMENT 'Date et heure de création du feedback';

    DEFINE FIELD IF NOT EXISTS metadata.impact_score ON TABLE knowledge_feedback
        TYPE number
        DEFAULT 0.5
        ASSERT $value >= 0 AND $value <= 1
        COMMENT "Score d'impact du feedback (0 = faible impact, 1 = impact critique). Utilisé pour prioriser les feedbacks";

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX idx_feedback_content ON knowledge_feedback
    FIELDS content
    COMMENT 'Index sur le contenu concerné pour requêtes rapides';

DEFINE INDEX idx_feedback_type ON knowledge_feedback
    FIELDS feedback_type
    COMMENT 'Index sur le type de feedback';

DEFINE INDEX idx_feedback_active ON knowledge_feedback
    FIELDS metadata.is_active
    COMMENT 'Index sur le statut actif';

DEFINE INDEX idx_feedback_resolved ON knowledge_feedback
    FIELDS metadata.is_resolved
    COMMENT 'Index sur le statut résolu';

DEFINE INDEX idx_feedback_created ON knowledge_feedback
    FIELDS metadata.created_at
    COMMENT 'Index sur la date de création pour tri chronologique';

DEFINE INDEX idx_feedback_content_type ON knowledge_feedback
    FIELDS content, feedback_type
    COMMENT 'Index composite pour requêtes par contenu et type';

