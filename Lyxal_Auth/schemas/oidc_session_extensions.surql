-- ============================================================
-- TABLE: oidc_session_extensions
-- SOURCE: oidc_session_extensions.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE oidc_session_extensions TYPE NORMAL SCHEMAFULL
COMMENT "Extensions de session OIDC (Données supplémentaires)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE oidc_session_extensions 
    TYPE string;

DEFINE FIELD IF NOT EXISTS session_uid ON TABLE oidc_session_extensions 
    TYPE string;

DEFINE FIELD IF NOT EXISTS account_id ON TABLE oidc_session_extensions 
    TYPE string;
-- Reference users (sera record<users>)

DEFINE FIELD IF NOT EXISTS last_submission ON TABLE oidc_session_extensions 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS created_at ON TABLE oidc_session_extensions 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE oidc_session_extensions 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, session_uid)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE oidc_session_extensions 
    FIELDS tenant_id, session_uid UNIQUE;

-- Note: Trigger set_updated_at ignoré (voir conversion_notes.md)
