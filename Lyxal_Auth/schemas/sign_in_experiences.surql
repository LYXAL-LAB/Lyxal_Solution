-- ============================================================
-- TABLE: sign_in_experiences
-- SOURCE: sign_in_experiences.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE sign_in_experiences TYPE NORMAL SCHEMAFULL
COMMENT "Configuration de l'expérience de connexion (Branding, UI)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE sign_in_experiences 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE sign_in_experiences 
    TYPE string;

DEFINE FIELD IF NOT EXISTS color ON TABLE sign_in_experiences 
    TYPE object;

DEFINE FIELD IF NOT EXISTS branding ON TABLE sign_in_experiences 
    TYPE object;

DEFINE FIELD IF NOT EXISTS hide_logto_branding ON TABLE sign_in_experiences 
    TYPE bool
    DEFAULT false;

DEFINE FIELD IF NOT EXISTS language_info ON TABLE sign_in_experiences 
    TYPE object;

DEFINE FIELD IF NOT EXISTS terms_of_use_url ON TABLE sign_in_experiences 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS privacy_policy_url ON TABLE sign_in_experiences 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS agree_to_terms_policy ON TABLE sign_in_experiences 
    TYPE string
    DEFAULT 'Automatic'
    ASSERT $value INSIDE ['Automatic', 'ManualRegistrationOnly', 'Manual'];

DEFINE FIELD IF NOT EXISTS sign_in ON TABLE sign_in_experiences 
    TYPE object;

DEFINE FIELD IF NOT EXISTS sign_up ON TABLE sign_in_experiences 
    TYPE object;

DEFINE FIELD IF NOT EXISTS social_sign_in ON TABLE sign_in_experiences 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS social_sign_in_connector_targets ON TABLE sign_in_experiences 
    TYPE array
    DEFAULT [];

DEFINE FIELD IF NOT EXISTS sign_in_mode ON TABLE sign_in_experiences 
    TYPE string
    DEFAULT 'SignInAndRegister'
    ASSERT $value INSIDE ['SignIn', 'Register', 'SignInAndRegister'];

DEFINE FIELD IF NOT EXISTS custom_css ON TABLE sign_in_experiences 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS custom_content ON TABLE sign_in_experiences 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS custom_ui_assets ON TABLE sign_in_experiences 
    TYPE option<object>;

DEFINE FIELD IF NOT EXISTS password_policy ON TABLE sign_in_experiences 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS mfa ON TABLE sign_in_experiences 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS single_sign_on_enabled ON TABLE sign_in_experiences 
    TYPE bool
    DEFAULT false;

DEFINE FIELD IF NOT EXISTS support_email ON TABLE sign_in_experiences 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS support_website_url ON TABLE sign_in_experiences 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS unknown_session_redirect_url ON TABLE sign_in_experiences 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS captcha_policy ON TABLE sign_in_experiences 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS sentinel_policy ON TABLE sign_in_experiences 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS email_blocklist_policy ON TABLE sign_in_experiences 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS forgot_password_methods ON TABLE sign_in_experiences 
    TYPE array
    DEFAULT [];

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE sign_in_experiences 
    FIELDS tenant_id, id UNIQUE;
