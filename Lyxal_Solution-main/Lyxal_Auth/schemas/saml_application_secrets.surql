-- ============================================================
-- TABLE: saml_application_secrets
-- SOURCE: saml_application_secrets.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE saml_application_secrets TYPE NORMAL SCHEMAFULL
COMMENT "Secrets (Certificats/Clés) pour applications SAML"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS id ON TABLE saml_application_secrets 
    TYPE string;

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE saml_application_secrets 
    TYPE string;

DEFINE FIELD IF NOT EXISTS application_id ON TABLE saml_application_secrets 
    TYPE record<applications>;

DEFINE FIELD IF NOT EXISTS private_key ON TABLE saml_application_secrets 
    TYPE string;

DEFINE FIELD IF NOT EXISTS certificate ON TABLE saml_application_secrets 
    TYPE string;

DEFINE FIELD IF NOT EXISTS created_at ON TABLE saml_application_secrets 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE saml_application_secrets 
    TYPE datetime;

DEFINE FIELD IF NOT EXISTS active ON TABLE saml_application_secrets 
    TYPE bool;

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, application_id, id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE saml_application_secrets 
    FIELDS tenant_id, application_id, id UNIQUE;

-- Index partiel unique (tenant_id, application_id, active) WHERE active = true
-- Note: Ignoré (voir conversion_notes.md)

-- Note: Contrainte check_application_type ignorée (voir conversion_notes.md)
