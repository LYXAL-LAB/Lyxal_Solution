DEFINE TABLE saml_application_sessions SCHEMAFULL;

DEFINE FIELD tenant ON TABLE saml_application_sessions TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD application ON TABLE saml_application_sessions TYPE record<applications> ASSERT $value != NONE;
DEFINE FIELD saml_request_id ON TABLE saml_application_sessions TYPE string ASSERT $value != NONE;
DEFINE FIELD oidc_state ON TABLE saml_application_sessions TYPE string;
DEFINE FIELD relay_state ON TABLE saml_application_sessions TYPE string;
DEFINE FIELD raw_auth_request ON TABLE saml_application_sessions TYPE string ASSERT $value != NONE;
DEFINE FIELD created_at ON TABLE saml_application_sessions TYPE datetime DEFAULT time::now();
DEFINE FIELD expires_at ON TABLE saml_application_sessions TYPE datetime ASSERT $value != NONE;
