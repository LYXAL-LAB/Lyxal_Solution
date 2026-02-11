-- ============================================================================
-- Fichier : knowledge/database/knowledge_content_relation.surql
-- Module : knowledge
-- TABLE : knowledge_content_relation
-- Description : Table RELATION pour créer des liens entre contenus de connaissance
-- Types : prerequisite, dependency, reference, related
-- Dépendances : knowledge_content
-- Auteur : Équipe Lyxal (via IA)
-- Date : 2025
-- ============================================================================

DEFINE TABLE knowledge_content_relation TYPE RELATION
    COMMENT 'Relations entre contenus de connaissance (prerequisite, dependency, reference, related)';

-- ============================================================================
-- IDENTITY : Type et métadonnées de la relation
-- ============================================================================

DEFINE FIELD IF NOT EXISTS relation_type ON knowledge_content_relation
    TYPE string
    ASSERT $value IN ["prerequisite", "dependency", "reference", "related"]
    COMMENT 'Type de relation entre les contenus';

DEFINE FIELD IF NOT EXISTS description ON knowledge_content_relation
    TYPE option<string>
    COMMENT 'Description optionnelle de la relation';

DEFINE FIELD IF NOT EXISTS priority ON knowledge_content_relation
    TYPE int
    DEFAULT 0
    COMMENT 'Ordre de priorité pour affichage/navigation (plus petit = plus important)';

-- ============================================================================
-- METADATA : Métadonnées générales
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON knowledge_content_relation
    TYPE object
    COMMENT 'Bloc métadonnées générales';

    DEFINE FIELD IF NOT EXISTS metadata.is_active ON knowledge_content_relation
        TYPE bool
        DEFAULT true
        COMMENT 'La relation est active';

    DEFINE FIELD IF NOT EXISTS metadata.created_at ON knowledge_content_relation
        TYPE datetime
        DEFAULT time::now()
        COMMENT 'Date de création de la relation';

    DEFINE FIELD IF NOT EXISTS metadata.created_by ON knowledge_content_relation
        TYPE option<string>
        COMMENT 'Identifiant du créateur de la relation';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX idx_relation_type ON knowledge_content_relation 
    FIELDS relation_type
    COMMENT 'Index sur le type de relation';

DEFINE INDEX idx_relation_active ON knowledge_content_relation 
    FIELDS metadata.is_active
    COMMENT 'Index sur le statut actif';

DEFINE INDEX idx_relation_in_out ON knowledge_content_relation 
    FIELDS in, out
    COMMENT 'Index composite sur les contenus source et destination';

DEFINE INDEX idx_relation_priority ON knowledge_content_relation 
    FIELDS priority
    COMMENT 'Index sur la priorité de la relation';

