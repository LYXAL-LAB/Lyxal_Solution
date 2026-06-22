DEFINE TABLE sso_connector_idp_initiated_auth_configs SCHEMAFULL;

DEFINE FIELD tenant ON TABLE sso_connector_idp_initiated_auth_configs TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD connector ON TABLE sso_connector_idp_initiated_auth_configs TYPE record<sso_connectors> ASSERT $value != NONE;
DEFINE FIELD default_application ON TABLE sso_connector_idp_initiated_auth_configs TYPE record<applications> ASSERT $value != NONE;
DEFINE FIELD redirect_uri ON TABLE sso_connector_idp_initiated_auth_configs TYPE string;
DEFINE FIELD auth_parameters ON TABLE sso_connector_idp_initiated_auth_configs TYPE object DEFAULT {};
DEFINE FIELD auto_send_authorization_request ON TABLE sso_connector_idp_initiated_auth_configs TYPE bool DEFAULT false;
DEFINE FIELD client_idp_initiated_auth_callback_uri ON TABLE sso_connector_idp_initiated_auth_configs TYPE string;
DEFINE FIELD created_at ON TABLE sso_connector_idp_initiated_auth_configs TYPE datetime DEFAULT time::now();
