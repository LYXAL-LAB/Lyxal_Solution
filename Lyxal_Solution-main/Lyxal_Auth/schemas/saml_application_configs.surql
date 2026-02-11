-- ============================================================
-- TABLE: saml_application_configs
-- SOURCE: saml_application_configs.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE saml_application_configs TYPE NORMAL SCHEMAFULL
COMMENT "Configuration des applications SAML"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS application_id ON TABLE saml_application_configs 
    TYPE record<applications>;

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE saml_application_configs 
    TYPE string;

DEFINE FIELD IF NOT EXISTS attribute_mapping ON TABLE saml_application_configs 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS entity_id ON TABLE saml_application_configs 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS acs_url ON TABLE saml_application_configs 
    TYPE option<object>;

DEFINE FIELD IF NOT EXISTS encryption ON TABLE saml_application_configs 
    TYPE option<object>;

DEFINE FIELD IF NOT EXISTS name_id_format ON TABLE saml_application_configs 
    TYPE string;

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, application_id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE saml_application_configs 
    FIELDS tenant_id, application_id UNIQUE;

-- Note: Contrainte check_application_type ignorée (voir conversion_notes.md)
