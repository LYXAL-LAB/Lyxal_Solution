-- ============================================================
-- TABLE: organization_jit_sso_connectors
-- SOURCE: organization_jit_sso_connectors.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE organization_jit_sso_connectors TYPE NORMAL SCHEMAFULL
COMMENT "Connecteurs SSO pour provisionnement JIT dans une organisation"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE organization_jit_sso_connectors 
    TYPE string;

DEFINE FIELD IF NOT EXISTS organization_id ON TABLE organization_jit_sso_connectors 
    TYPE string;
-- Reference organizations

DEFINE FIELD IF NOT EXISTS sso_connector_id ON TABLE organization_jit_sso_connectors 
    TYPE string;
-- Reference sso_connectors

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, organization_id, sso_connector_id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE organization_jit_sso_connectors 
    FIELDS tenant_id, organization_id, sso_connector_id UNIQUE;
