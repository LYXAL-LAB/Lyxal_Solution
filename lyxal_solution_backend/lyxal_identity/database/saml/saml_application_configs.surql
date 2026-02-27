DEFINE TABLE saml_application_configs SCHEMAFULL;

DEFINE FIELD application ON TABLE saml_application_configs TYPE record<applications> ASSERT $value != NONE;
DEFINE FIELD tenant ON TABLE saml_application_configs TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD attribute_mapping ON TABLE saml_application_configs TYPE object DEFAULT {};
DEFINE FIELD entity_id ON TABLE saml_application_configs TYPE string;
DEFINE FIELD acs_url ON TABLE saml_application_configs TYPE object;
DEFINE FIELD encryption ON TABLE saml_application_configs TYPE object;
DEFINE FIELD name_id_format ON TABLE saml_application_configs TYPE string ASSERT $value != NONE;
