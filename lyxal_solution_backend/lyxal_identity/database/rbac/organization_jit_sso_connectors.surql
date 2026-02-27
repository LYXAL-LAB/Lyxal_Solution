DEFINE TABLE organization_jit_sso_connectors SCHEMAFULL;

DEFINE FIELD tenant ON TABLE organization_jit_sso_connectors TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD organization ON TABLE organization_jit_sso_connectors TYPE record<organizations> ASSERT $value != NONE;
DEFINE FIELD sso_connector ON TABLE organization_jit_sso_connectors TYPE record<sso_connectors> ASSERT $value != NONE;

DEFINE INDEX primary ON TABLE organization_jit_sso_connectors COLUMNS tenant, organization, sso_connector UNIQUE;
