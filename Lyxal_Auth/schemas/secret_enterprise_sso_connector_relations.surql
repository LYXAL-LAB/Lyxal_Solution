-- ============================================================
-- TABLE: secret_enterprise_sso_connector_relations
-- SOURCE: secret_enterprise_sso_connector_relations.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE secret_enterprise_sso_connector_relations TYPE NORMAL SCHEMAFULL
COMMENT "Lien entre Secrets et Connecteurs SSO Entreprise"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE secret_enterprise_sso_connector_relations 
    TYPE string;

DEFINE FIELD IF NOT EXISTS secret_id ON TABLE secret_enterprise_sso_connector_relations 
    TYPE string;
-- Reference secrets

DEFINE FIELD IF NOT EXISTS sso_connector_id ON TABLE secret_enterprise_sso_connector_relations 
    TYPE string;
-- Reference sso_connectors

DEFINE FIELD IF NOT EXISTS issuer ON TABLE secret_enterprise_sso_connector_relations 
    TYPE string;

DEFINE FIELD IF NOT EXISTS identity_id ON TABLE secret_enterprise_sso_connector_relations 
    TYPE string;

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, secret_id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE secret_enterprise_sso_connector_relations 
    FIELDS tenant_id, secret_id UNIQUE;

-- Note: Triggers de suppression en cascade ignorés (voir conversion_notes.md)
