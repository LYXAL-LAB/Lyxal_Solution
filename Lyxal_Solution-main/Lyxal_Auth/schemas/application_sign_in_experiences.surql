-- ============================================================
-- TABLE: application_sign_in_experiences
-- SOURCE: application_sign_in_experiences.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE application_sign_in_experiences TYPE NORMAL SCHEMAFULL
COMMENT "Configuration de l'expérience de connexion par application"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE application_sign_in_experiences 
    TYPE string;

DEFINE FIELD IF NOT EXISTS application_id ON TABLE application_sign_in_experiences 
    TYPE record<applications>;

DEFINE FIELD IF NOT EXISTS color ON TABLE application_sign_in_experiences 
    TYPE object
    DEFAULT {}
    COMMENT "Palette de couleurs";

DEFINE FIELD IF NOT EXISTS branding ON TABLE application_sign_in_experiences 
    TYPE object
    DEFAULT {}
    COMMENT "Configuration Branding";

DEFINE FIELD IF NOT EXISTS custom_css ON TABLE application_sign_in_experiences 
    TYPE option<string>
    COMMENT "CSS personnalisé";

DEFINE FIELD IF NOT EXISTS terms_of_use_url ON TABLE application_sign_in_experiences 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS privacy_policy_url ON TABLE application_sign_in_experiences 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS display_name ON TABLE application_sign_in_experiences 
    TYPE option<string>;

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, application_id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE application_sign_in_experiences 
    FIELDS tenant_id, application_id UNIQUE;
