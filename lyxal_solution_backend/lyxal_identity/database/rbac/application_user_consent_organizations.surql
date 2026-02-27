DEFINE TABLE application_user_consent_organizations SCHEMAFULL;

DEFINE FIELD tenant ON TABLE application_user_consent_organizations TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD application ON TABLE application_user_consent_organizations TYPE record<applications> ASSERT $value != NONE;
DEFINE FIELD organization ON TABLE application_user_consent_organizations TYPE record<organizations> ASSERT $value != NONE;
DEFINE FIELD user ON TABLE application_user_consent_organizations TYPE record<users> ASSERT $value != NONE;

DEFINE INDEX primary ON TABLE application_user_consent_organizations COLUMNS tenant, application, organization, user UNIQUE;
