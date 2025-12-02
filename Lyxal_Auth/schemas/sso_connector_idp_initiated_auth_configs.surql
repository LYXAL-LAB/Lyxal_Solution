-- ============================================================
-- TABLE: sso_connector_idp_initiated_auth_configs
-- SOURCE: sso_connector_idp_initiated_auth_configs.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE sso_connector_idp_initiated_auth_configs TYPE NORMAL SCHEMAFULL
COMMENT "Configuration Auth IdP-Initiated pour connecteurs SSO"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE sso_connector_idp_initiated_auth_configs 
    TYPE string;

DEFINE FIELD IF NOT EXISTS connector_id ON TABLE sso_connector_idp_initiated_auth_configs 
    TYPE string;
-- Reference sso_connectors

DEFINE FIELD IF NOT EXISTS default_application_id ON TABLE sso_connector_idp_initiated_auth_configs 
    TYPE record<applications>;

DEFINE FIELD IF NOT EXISTS redirect_uri ON TABLE sso_connector_idp_initiated_auth_configs 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS auth_parameters ON TABLE sso_connector_idp_initiated_auth_configs 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS auto_send_authorization_request ON TABLE sso_connector_idp_initiated_auth_configs 
    TYPE bool
    DEFAULT false;

DEFINE FIELD IF NOT EXISTS client_idp_initiated_auth_callback_uri ON TABLE sso_connector_idp_initiated_auth_configs 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS created_at ON TABLE sso_connector_idp_initiated_auth_configs 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, connector_id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE sso_connector_idp_initiated_auth_configs 
    FIELDS tenant_id, connector_id UNIQUE;

-- Note: Contrainte check_application_type ignorée (voir conversion_notes.md)
