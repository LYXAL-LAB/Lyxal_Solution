-- ============================================================
-- TABLE: application_user_consent_resource_scopes
-- SOURCE: application_user_consent_resource_scopes.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE application_user_consent_resource_scopes TYPE NORMAL SCHEMAFULL
COMMENT "Scopes de ressource assignés à une demande de consentement"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE application_user_consent_resource_scopes 
    TYPE string;

DEFINE FIELD IF NOT EXISTS application_id ON TABLE application_user_consent_resource_scopes 
    TYPE record<applications>;

DEFINE FIELD IF NOT EXISTS scope_id ON TABLE application_user_consent_resource_scopes 
    TYPE string;
-- Reference scopes (sera record<scopes>)

-- INDEX & CONTRAINTES

-- PK Composite (application_id, scope_id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE application_user_consent_resource_scopes 
    FIELDS tenant_id, application_id, scope_id UNIQUE;
