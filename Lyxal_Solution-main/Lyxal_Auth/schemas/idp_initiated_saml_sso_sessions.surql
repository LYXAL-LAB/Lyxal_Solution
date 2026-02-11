-- ============================================================
-- TABLE: idp_initiated_saml_sso_sessions
-- SOURCE: idp_initiated_saml_sso_sessions.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE idp_initiated_saml_sso_sessions TYPE NORMAL SCHEMAFULL
COMMENT "Sessions SSO SAML initiées par l'IdP"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE idp_initiated_saml_sso_sessions 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE idp_initiated_saml_sso_sessions 
    TYPE string;

DEFINE FIELD IF NOT EXISTS connector_id ON TABLE idp_initiated_saml_sso_sessions 
    TYPE string;
-- Reference sso_connectors (sera record<sso_connectors>)

DEFINE FIELD IF NOT EXISTS assertion_content ON TABLE idp_initiated_saml_sso_sessions 
    TYPE object
    DEFAULT {}
    COMMENT "Contenu de l'assertion SAML";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE idp_initiated_saml_sso_sessions 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE idp_initiated_saml_sso_sessions 
    TYPE datetime;

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE idp_initiated_saml_sso_sessions 
    FIELDS tenant_id, id UNIQUE;
