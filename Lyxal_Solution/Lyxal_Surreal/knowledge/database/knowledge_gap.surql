-- ============================================================================
-- Fichier : knowledge/database/knowledge_gap.surql
-- Module : knowledge
-- TABLE : knowledge_gap
-- Description : Gaps détectés dans le système de connaissance pour amélioration continue
-- Permet d'identifier automatiquement les lacunes (topics manquants, contenus incomplets, etc.)
--
-- Dépendances : knowledge_domain, knowledge_topic, knowledge_content
-- Auteur : Équipe Lyxal (via IA)
-- Date : 2025
-- ============================================================================

DEFINE TABLE knowledge_gap TYPE NORMAL SCHEMAFULL
    COMMENT "Gaps détectés dans le système de connaissance pour amélioration continue"
    PERMISSIONS
        FOR SELECT FULL
        FOR CREATE FULL
        FOR UPDATE FULL
        FOR DELETE FULL;

-- ============================================================================
-- CONTEXTE : Contexte du gap détecté
-- ============================================================================

DEFINE FIELD IF NOT EXISTS gap_type ON TABLE knowledge_gap
    TYPE string
    ASSERT $value IN ["missing_topic", "missing_content", "incomplete_content", "missing_keywords", "low_quality_content", "outdated_content"]
    COMMENT "Type de gap détecté : missing_topic (topic manquant), missing_content (contenu manquant pour un topic), incomplete_content (contenu incomplet), missing_keywords (mots-clés manquants), low_quality_content (contenu de faible qualité), outdated_content (contenu obsolète)";

DEFINE FIELD IF NOT EXISTS severity ON TABLE knowledge_gap
    TYPE string
    DEFAULT "medium"
    ASSERT $value IN ["low", "medium", "high", "critical"]
    COMMENT "Sévérité du gap : low (mineur), medium (moyen), high (élevé), critical (critique)";

DEFINE FIELD IF NOT EXISTS domain ON TABLE knowledge_gap
    TYPE option<record<knowledge_domain>>
    REFERENCE ON DELETE CASCADE
    COMMENT "Domaine concerné par le gap (optionnel si gap général)";

DEFINE FIELD IF NOT EXISTS topic ON TABLE knowledge_gap
    TYPE option<record<knowledge_topic>>
    REFERENCE ON DELETE CASCADE
    COMMENT "Topic concerné par le gap (optionnel si gap au niveau domaine)";

DEFINE FIELD IF NOT EXISTS content ON TABLE knowledge_gap
    TYPE option<record<knowledge_content>>
    REFERENCE ON DELETE CASCADE
    COMMENT "Contenu concerné par le gap (optionnel si gap au niveau topic/domaine)";

-- ============================================================================
-- DÉTECTION : Détails de la détection
-- ============================================================================

DEFINE FIELD IF NOT EXISTS detection ON TABLE knowledge_gap
    TYPE object
    COMMENT "Informations sur la détection du gap";

    DEFINE FIELD IF NOT EXISTS detection.method ON TABLE knowledge_gap
        TYPE string
        DEFAULT "automatic"
        ASSERT $value IN ["automatic", "feedback", "usage_analysis", "manual"]
        COMMENT "Méthode de détection : automatic (détection automatique par IA), feedback (remonté via feedback), usage_analysis (analyse d'usage), manual (détection manuelle)";

    DEFINE FIELD IF NOT EXISTS detection.source ON TABLE knowledge_gap
        TYPE option<string>
        COMMENT "Source de la détection (ID requête échouée, ID feedback, nom de l'analyseur, etc.)";

    DEFINE FIELD IF NOT EXISTS detection.detected_at ON TABLE knowledge_gap
        TYPE datetime
        DEFAULT time::now()
        COMMENT "Date et heure de détection du gap";

    DEFINE FIELD IF NOT EXISTS detection.confidence ON TABLE knowledge_gap
        TYPE number
        DEFAULT 0.5
        ASSERT $value >= 0 AND $value <= 1
        COMMENT "Niveau de confiance de la détection (0 = incertain, 1 = très sûr)";

-- ============================================================================
-- DÉTAILS : Description du gap
-- ============================================================================

DEFINE FIELD IF NOT EXISTS description ON TABLE knowledge_gap
    TYPE option<string>
    COMMENT "Description détaillée du gap détecté";

DEFINE FIELD IF NOT EXISTS expected_content ON TABLE knowledge_gap
    TYPE option<string>
    COMMENT "Description du contenu attendu (pour gaps de type missing_content/incomplete_content)";

DEFINE FIELD IF NOT EXISTS suggested_keywords ON TABLE knowledge_gap
    TYPE option<array<string>>
    COMMENT "Mots-clés suggérés pour améliorer la découvrabilité (pour gaps missing_keywords)";

-- ============================================================================
-- RÉSOLUTION : État de résolution
-- ============================================================================

DEFINE FIELD IF NOT EXISTS resolution ON TABLE knowledge_gap
    TYPE object
    COMMENT "Informations sur la résolution du gap";

    DEFINE FIELD IF NOT EXISTS resolution.status ON TABLE knowledge_gap
        TYPE string
        DEFAULT "pending"
        ASSERT $value IN ["pending", "in_progress", "resolved", "rejected", "duplicate"]
        COMMENT "Statut de résolution : pending (en attente), in_progress (en cours), resolved (résolu), rejected (rejeté/non pertinent), duplicate (doublon)";

    DEFINE FIELD IF NOT EXISTS resolution.resolved_at ON TABLE knowledge_gap
        TYPE option<datetime>
        COMMENT "Date et heure de résolution";

    DEFINE FIELD IF NOT EXISTS resolution.resolved_by ON TABLE knowledge_gap
        TYPE option<string>
        COMMENT "Identifiant de la personne/IA qui a résolu le gap";

    DEFINE FIELD IF NOT EXISTS resolution.resolution_content ON TABLE knowledge_gap
        TYPE option<record<knowledge_content>>
        REFERENCE ON DELETE UNSET
        COMMENT "Référence vers le contenu créé pour résoudre ce gap (si applicable)";

    DEFINE FIELD IF NOT EXISTS resolution.notes ON TABLE knowledge_gap
        TYPE option<string>
        COMMENT "Notes sur la résolution (pourquoi rejeté, comment résolu, etc.)";

-- ============================================================================
-- METADATA : Métadonnées
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE knowledge_gap
    TYPE object
    COMMENT "Métadonnées du gap";

    DEFINE FIELD IF NOT EXISTS metadata.priority ON TABLE knowledge_gap
        TYPE int
        DEFAULT 0
        COMMENT "Priorité de traitement (0 = normale, plus élevé = plus prioritaire)";

    DEFINE FIELD IF NOT EXISTS metadata.impact_score ON TABLE knowledge_gap
        TYPE number
        DEFAULT 0.5
        ASSERT $value >= 0 AND $value <= 1
        COMMENT "Score d'impact estimé (0 = faible impact, 1 = impact critique)";

    DEFINE FIELD IF NOT EXISTS metadata.is_active ON TABLE knowledge_gap
        TYPE bool
        DEFAULT true
        COMMENT "Le gap est actif (peut être désactivé sans suppression)";

    DEFINE FIELD IF NOT EXISTS metadata.recurrence_count ON TABLE knowledge_gap
        TYPE int
        DEFAULT 1
        COMMENT "Nombre de fois que ce gap a été détecté (pour détecter les patterns)";

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX idx_gap_type ON knowledge_gap
    FIELDS gap_type
    COMMENT "Index sur le type de gap";

DEFINE INDEX idx_gap_severity ON knowledge_gap
    FIELDS severity
    COMMENT "Index sur la sévérité";

DEFINE INDEX idx_gap_status ON knowledge_gap
    FIELDS resolution.status
    COMMENT "Index sur le statut de résolution";

DEFINE INDEX idx_gap_domain ON knowledge_gap
    FIELDS domain
    COMMENT "Index sur le domaine concerné";

DEFINE INDEX idx_gap_topic ON knowledge_gap
    FIELDS topic
    COMMENT "Index sur le topic concerné";

DEFINE INDEX idx_gap_active ON knowledge_gap
    FIELDS metadata.is_active
    COMMENT "Index sur le statut actif";

DEFINE INDEX idx_gap_priority ON knowledge_gap
    FIELDS metadata.priority
    COMMENT "Index sur la priorité";

DEFINE INDEX idx_gap_detected ON knowledge_gap
    FIELDS detection.detected_at
    COMMENT "Index sur la date de détection";

DEFINE INDEX idx_gap_pending_severity ON knowledge_gap
    FIELDS resolution.status, severity, metadata.priority
    COMMENT "Index composite pour requêtes de gaps en attente triés par sévérité et priorité";

