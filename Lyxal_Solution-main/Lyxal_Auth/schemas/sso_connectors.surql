-- ============================================================
-- TABLE: sso_connectors
-- SOURCE: sso_connectors.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE sso_connectors TYPE NORMAL SCHEMAFULL
COMMENT "Connecteurs SSO Entreprise (SAML, OIDC)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE sso_connectors 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE sso_connectors 
    TYPE string;

DEFINE FIELD IF NOT EXISTS provider_name ON TABLE sso_connectors 
    TYPE string;

DEFINE FIELD IF NOT EXISTS connector_name ON TABLE sso_connectors 
    TYPE string;

DEFINE FIELD IF NOT EXISTS config ON TABLE sso_connectors 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS domains ON TABLE sso_connectors 
    TYPE array
    DEFAULT [];

DEFINE FIELD IF NOT EXISTS branding ON TABLE sso_connectors 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS sync_profile ON TABLE sso_connectors 
    TYPE bool
    DEFAULT false;

DEFINE FIELD IF NOT EXISTS enable_token_storage ON TABLE sso_connectors 
    TYPE bool
    DEFAULT false;

DEFINE FIELD IF NOT EXISTS created_at ON TABLE sso_connectors 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

-- Unique (tenant_id, connector_name)
DEFINE INDEX IF NOT EXISTS idx_unique_name ON TABLE sso_connectors 
    FIELDS tenant_id, connector_name UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE sso_connectors 
    FIELDS tenant_id, id;

DEFINE INDEX IF NOT EXISTS idx_id_provider ON TABLE sso_connectors 
    FIELDS tenant_id, id, provider_name;
