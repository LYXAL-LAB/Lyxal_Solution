DEFINE TABLE idp_initiated_saml_sso_sessions SCHEMAFULL;

DEFINE FIELD tenant ON TABLE idp_initiated_saml_sso_sessions TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD connector ON TABLE idp_initiated_saml_sso_sessions TYPE record<sso_connectors> ASSERT $value != NONE;
DEFINE FIELD assertion_content ON TABLE idp_initiated_saml_sso_sessions TYPE object DEFAULT {};
DEFINE FIELD created_at ON TABLE idp_initiated_saml_sso_sessions TYPE datetime DEFAULT time::now();
DEFINE FIELD expires_at ON TABLE idp_initiated_saml_sso_sessions TYPE datetime ASSERT $value != NONE;
