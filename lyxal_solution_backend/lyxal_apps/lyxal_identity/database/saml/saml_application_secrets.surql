DEFINE TABLE saml_application_secrets SCHEMAFULL;

DEFINE FIELD tenant ON TABLE saml_application_secrets TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD application ON TABLE saml_application_secrets TYPE record<applications> ASSERT $value != NONE;
DEFINE FIELD private_key ON TABLE saml_application_secrets TYPE string ASSERT $value != NONE;
DEFINE FIELD certificate ON TABLE saml_application_secrets TYPE string ASSERT $value != NONE;
DEFINE FIELD created_at ON TABLE saml_application_secrets TYPE datetime DEFAULT time::now();
DEFINE FIELD expires_at ON TABLE saml_application_secrets TYPE datetime ASSERT $value != NONE;
DEFINE FIELD active ON TABLE saml_application_secrets TYPE bool ASSERT $value != NONE;

DEFINE INDEX unique_active_secret ON TABLE saml_application_secrets COLUMNS tenant, application, active UNIQUE WHERE active = true;
