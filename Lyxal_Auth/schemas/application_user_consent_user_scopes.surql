-- ============================================================
-- TABLE: application_user_consent_user_scopes
-- SOURCE: application_user_consent_user_scopes.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE application_user_consent_user_scopes TYPE NORMAL SCHEMAFULL
COMMENT "Scopes utilisateur (OIDC) assignés à une application"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE application_user_consent_user_scopes 
    TYPE string;

DEFINE FIELD IF NOT EXISTS application_id ON TABLE application_user_consent_user_scopes 
    TYPE record<applications>;

DEFINE FIELD IF NOT EXISTS user_scope ON TABLE application_user_consent_user_scopes 
    TYPE string
    COMMENT "Valeur enum UserScope (ex: profile, email)";

-- INDEX & CONTRAINTES

-- PK Composite (application_id, user_scope)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE application_user_consent_user_scopes 
    FIELDS tenant_id, application_id, user_scope UNIQUE;
