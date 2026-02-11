-- ============================================================
-- TABLE: secret_social_connector_relations
-- SOURCE: secret_social_connector_relations.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE secret_social_connector_relations TYPE NORMAL SCHEMAFULL
COMMENT "Lien entre Secrets et Connecteurs Sociaux"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE secret_social_connector_relations 
    TYPE string;

DEFINE FIELD IF NOT EXISTS secret_id ON TABLE secret_social_connector_relations 
    TYPE string;
-- Reference secrets

DEFINE FIELD IF NOT EXISTS connector_id ON TABLE secret_social_connector_relations 
    TYPE string;
-- Reference connectors

DEFINE FIELD IF NOT EXISTS target ON TABLE secret_social_connector_relations 
    TYPE string;

DEFINE FIELD IF NOT EXISTS identity_id ON TABLE secret_social_connector_relations 
    TYPE string;

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, secret_id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE secret_social_connector_relations 
    FIELDS tenant_id, secret_id UNIQUE;

-- Unique (tenant_id, target, identity_id)
DEFINE INDEX IF NOT EXISTS idx_unique_identity ON TABLE secret_social_connector_relations 
    FIELDS tenant_id, target, identity_id UNIQUE;

-- Note: Triggers de suppression en cascade ignorés (voir conversion_notes.md)
