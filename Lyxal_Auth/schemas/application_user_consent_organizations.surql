-- ============================================================
-- TABLE: application_user_consent_organizations
-- SOURCE: application_user_consent_organizations.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE application_user_consent_organizations TYPE NORMAL SCHEMAFULL
COMMENT "Consentement utilisateur pour l'accès d'une app à une organisation"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE application_user_consent_organizations 
    TYPE string;

DEFINE FIELD IF NOT EXISTS application_id ON TABLE application_user_consent_organizations 
    TYPE record<applications>;

DEFINE FIELD IF NOT EXISTS organization_id ON TABLE application_user_consent_organizations 
    TYPE string; 
-- Reference organization (sera record<organizations>)

DEFINE FIELD IF NOT EXISTS user_id ON TABLE application_user_consent_organizations 
    TYPE string;
-- Reference user (sera record<users>)

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, application_id, organization_id, user_id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE application_user_consent_organizations 
    FIELDS tenant_id, application_id, organization_id, user_id UNIQUE;

-- Note: FK vers organization_user_relations ignorée ici (gérée par logique applicative ou graph)
