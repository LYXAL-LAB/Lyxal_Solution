-- ============================================================================
-- Fichier : knowledge/database/knowledge_dataset_export.surql
-- Module : knowledge
-- TABLE : knowledge_dataset_export
-- Description : Table pour tracker les exports de datasets d'entraînement IA
-- Dépendances : knowledge_domain
-- Auteur : Équipe Lyxal (via IA)
-- Date : 2025
-- ============================================================================

DEFINE TABLE knowledge_dataset_export TYPE NORMAL SCHEMAFULL
    COMMENT 'Tracking des exports de datasets d\'entraînement IA avec versioning et provenance'
    PERMISSIONS
        FOR SELECT WHERE metadata.is_active = true
        FOR CREATE, UPDATE, DELETE NONE;

-- ============================================================================
-- RELATION : Référence vers le domaine exporté
-- ============================================================================

DEFINE FIELD IF NOT EXISTS domain ON TABLE knowledge_dataset_export
    TYPE record<knowledge_domain>
    REFERENCE ON DELETE REJECT
    ASSERT $value != NONE
    COMMENT 'Domaine exporté';

-- ============================================================================
-- IDENTITY : Identité de l'export
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE knowledge_dataset_export
    TYPE object
    COMMENT 'Bloc identité de l\'export';

    DEFINE FIELD IF NOT EXISTS identity.version ON TABLE knowledge_dataset_export
        TYPE string
        ASSERT $value != NONE AND $value != ""
        COMMENT 'Version du dataset (ex: "v1.0", "v1.1", "v2.0")';

    DEFINE FIELD IF NOT EXISTS identity.name ON TABLE knowledge_dataset_export
        TYPE string
        ASSERT $value != NONE AND $value != ""
        COMMENT 'Nom du dataset (ex: "surreal_db_v1.0", "business_export_v2.1")';

    DEFINE FIELD IF NOT EXISTS identity.description ON TABLE knowledge_dataset_export
        TYPE option<string>
        COMMENT 'Description de l\'export (optionnel)';

-- ============================================================================
-- EXPORT : Paramètres et résultats de l'export
-- ============================================================================

DEFINE FIELD IF NOT EXISTS export ON TABLE knowledge_dataset_export
    TYPE object
    COMMENT 'Bloc export avec paramètres et résultats';

    DEFINE FIELD IF NOT EXISTS export.min_quality_score ON TABLE knowledge_dataset_export
        TYPE number
        DEFAULT 0.7
        ASSERT $value >= 0 AND $value <= 1
        COMMENT 'Score de qualité minimum utilisé pour l\'export';

    DEFINE FIELD IF NOT EXISTS export.include_only_marked ON TABLE knowledge_dataset_export
        TYPE bool
        DEFAULT false
        COMMENT 'Export uniquement des contenus marqués included_in_training = true';

    DEFINE FIELD IF NOT EXISTS export.total_contents_found ON TABLE knowledge_dataset_export
        TYPE int
        DEFAULT 0
        COMMENT 'Nombre total de contenus éligibles trouvés';

    DEFINE FIELD IF NOT EXISTS export.total_items_exported ON TABLE knowledge_dataset_export
        TYPE int
        DEFAULT 0
        COMMENT 'Nombre total d\'items exportés dans le dataset';

    DEFINE FIELD IF NOT EXISTS export.avg_quality_score ON TABLE knowledge_dataset_export
        TYPE option<number>
        COMMENT 'Score de qualité moyen des contenus exportés';

    DEFINE FIELD IF NOT EXISTS export.avg_training_weight ON TABLE knowledge_dataset_export
        TYPE option<number>
        COMMENT 'Poids d\'entraînement moyen des contenus exportés';

-- ============================================================================
-- PROVENANCE : Tracking de provenance et métadonnées
-- ============================================================================

DEFINE FIELD IF NOT EXISTS provenance ON TABLE knowledge_dataset_export
    TYPE object
    COMMENT 'Bloc provenance pour tracking de l\'export';

    DEFINE FIELD IF NOT EXISTS provenance.created_by ON TABLE knowledge_dataset_export
        TYPE option<string>
        COMMENT 'Identifiant de l\'utilisateur/système qui a créé l\'export';

    DEFINE FIELD IF NOT EXISTS provenance.export_type ON TABLE knowledge_dataset_export
        TYPE string
        DEFAULT "manual"
        ASSERT $value IN ["manual", "scheduled", "automatic", "triggered"]
        COMMENT 'Type d\'export : manual (manuel), scheduled (planifié), automatic (automatique), triggered (déclenché)';

    DEFINE FIELD IF NOT EXISTS provenance.trigger_reason ON TABLE knowledge_dataset_export
        TYPE option<string>
        COMMENT 'Raison du déclenchement si export_type = "triggered" (ex: "new_content_added", "quality_threshold_reached")';

    DEFINE FIELD IF NOT EXISTS provenance.source_version ON TABLE knowledge_dataset_export
        TYPE option<string>
        COMMENT 'Version source si basé sur un export précédent';

    DEFINE FIELD IF NOT EXISTS provenance.file_path ON TABLE knowledge_dataset_export
        TYPE option<string>
        COMMENT 'Chemin du fichier JSONL généré (si sauvegardé)';

    DEFINE FIELD IF NOT EXISTS provenance.file_size_bytes ON TABLE knowledge_dataset_export
        TYPE option<int>
        COMMENT 'Taille du fichier JSONL en octets';

    DEFINE FIELD IF NOT EXISTS provenance.file_hash ON TABLE knowledge_dataset_export
        TYPE option<string>
        COMMENT 'Hash du fichier pour intégrité (SHA-256)';

-- ============================================================================
-- METADATA : Métadonnées générales
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE knowledge_dataset_export
    TYPE object
    COMMENT 'Bloc métadonnées générales';

    DEFINE FIELD IF NOT EXISTS metadata.is_active ON TABLE knowledge_dataset_export
        TYPE bool
        DEFAULT true
        COMMENT 'L\'export est actif';

    DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE knowledge_dataset_export
        TYPE datetime
        DEFAULT time::now()
        COMMENT 'Date de création de l\'export';

    DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE knowledge_dataset_export
        TYPE datetime
        DEFAULT time::now()
        COMMENT 'Date de dernière mise à jour';

    DEFINE FIELD IF NOT EXISTS metadata.expires_at ON TABLE knowledge_dataset_export
        TYPE option<datetime>
        COMMENT 'Date d\'expiration de l\'export (optionnel, pour nettoyage automatique)';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE knowledge_dataset_export
        TYPE option<string>
        COMMENT 'Notes libres sur l\'export';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX idx_dataset_export_domain ON knowledge_dataset_export 
    FIELDS domain
    COMMENT 'Index sur le domaine exporté';

DEFINE INDEX idx_dataset_export_version ON knowledge_dataset_export 
    FIELDS identity.version
    COMMENT 'Index sur la version du dataset';

DEFINE INDEX idx_dataset_export_name ON knowledge_dataset_export 
    FIELDS identity.name UNIQUE
    COMMENT 'Index unique sur le nom du dataset';

DEFINE INDEX idx_dataset_export_active ON knowledge_dataset_export 
    FIELDS metadata.is_active
    COMMENT 'Index sur le statut actif';

DEFINE INDEX idx_dataset_export_created ON knowledge_dataset_export 
    FIELDS metadata.created_at
    COMMENT 'Index sur la date de création';

DEFINE INDEX idx_dataset_export_domain_version ON knowledge_dataset_export 
    FIELDS domain, identity.version
    COMMENT 'Index composite pour recherche par domaine et version';

