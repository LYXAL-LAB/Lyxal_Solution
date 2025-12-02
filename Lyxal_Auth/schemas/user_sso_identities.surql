-- ============================================================
-- TABLE: user_sso_identities
-- SOURCE: user_sso_identities.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE user_sso_identities TYPE NORMAL SCHEMAFULL
COMMENT "Identités SSO liées aux utilisateurs"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE user_sso_identities 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE user_sso_identities 
    TYPE string;

DEFINE FIELD IF NOT EXISTS user_id ON TABLE user_sso_identities 
    TYPE string;
-- Reference users

DEFINE FIELD IF NOT EXISTS issuer ON TABLE user_sso_identities 
    TYPE string;

DEFINE FIELD IF NOT EXISTS identity_id ON TABLE user_sso_identities 
    TYPE string;

DEFINE FIELD IF NOT EXISTS detail ON TABLE user_sso_identities 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS created_at ON TABLE user_sso_identities 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE user_sso_identities 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS sso_connector_id ON TABLE user_sso_identities 
    TYPE string;
-- Reference sso_connectors

-- INDEX & CONTRAINTES

-- Unique (tenant_id, issuer, identity_id)
DEFINE INDEX IF NOT EXISTS idx_unique_identity ON TABLE user_sso_identities 
    FIELDS tenant_id, issuer, identity_id UNIQUE;

-- Note: Trigger set_updated_at ignoré (voir conversion_notes.md)
