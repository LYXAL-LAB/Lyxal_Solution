DEFINE TABLE organization_scopes SCHEMAFULL;

DEFINE FIELD tenant ON TABLE organization_scopes TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD name ON TABLE organization_scopes TYPE string ASSERT $value != NONE;
DEFINE FIELD description ON TABLE organization_scopes TYPE string;

DEFINE INDEX name ON TABLE organization_scopes COLUMNS tenant, name UNIQUE;
