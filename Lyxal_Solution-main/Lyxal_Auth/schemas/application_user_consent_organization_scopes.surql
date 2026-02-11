-- ============================================================
-- TABLE: application_user_consent_organization_scopes
-- SOURCE: application_user_consent_organization_scopes.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE application_user_consent_organization_scopes TYPE NORMAL SCHEMAFULL
COMMENT "Scopes d'organisation assignés à une application"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE application_user_consent_organization_scopes 
    TYPE string;

DEFINE FIELD IF NOT EXISTS application_id ON TABLE application_user_consent_organization_scopes 
    TYPE record<applications>;

DEFINE FIELD IF NOT EXISTS organization_scope_id ON TABLE application_user_consent_organization_scopes 
    TYPE string;
-- Reference organization_scopes (sera record<organization_scopes>)

-- INDEX & CONTRAINTES

-- PK Composite (application_id, organization_scope_id)
-- Note: Logto ne met pas tenant_id dans la PK ici ? (A vérifier, mais je suis le fichier)
-- Ah si, le fichier dit "primary key (application_id, organization_scope_id)".
-- Mais tenant_id est présent. Je l'ajoute à l'index unique par sécurité/cohérence multi-tenant.
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE application_user_consent_organization_scopes 
    FIELDS tenant_id, application_id, organization_scope_id UNIQUE;
