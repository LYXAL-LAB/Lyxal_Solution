-- ============================================================
-- TABLE: saml_application_sessions
-- SOURCE: saml_application_sessions.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE saml_application_sessions TYPE NORMAL SCHEMAFULL
COMMENT "Sessions d'authentification SAML en cours"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE saml_application_sessions 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE saml_application_sessions 
    TYPE string;

DEFINE FIELD IF NOT EXISTS application_id ON TABLE saml_application_sessions 
    TYPE record<applications>;

DEFINE FIELD IF NOT EXISTS saml_request_id ON TABLE saml_application_sessions 
    TYPE string;

DEFINE FIELD IF NOT EXISTS oidc_state ON TABLE saml_application_sessions 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS relay_state ON TABLE saml_application_sessions 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS raw_auth_request ON TABLE saml_application_sessions 
    TYPE string;

DEFINE FIELD IF NOT EXISTS created_at ON TABLE saml_application_sessions 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE saml_application_sessions 
    TYPE datetime;

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE saml_application_sessions 
    FIELDS tenant_id, id UNIQUE;

-- Note: Contrainte check_application_type ignorée (voir conversion_notes.md)
