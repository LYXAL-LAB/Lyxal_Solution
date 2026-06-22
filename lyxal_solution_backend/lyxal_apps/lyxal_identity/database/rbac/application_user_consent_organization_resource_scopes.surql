-- Table application_user_consent_organization_resource_scopes
DEFINE TABLE application_user_consent_organization_resource_scopes SCHEMAFULL;
DEFINE FIELD user ON TABLE application_user_consent_organization_resource_scopes TYPE record<users>;
DEFINE FIELD application ON TABLE application_user_consent_organization_resource_scopes TYPE record<applications>;
DEFINE FIELD organization ON TABLE application_user_consent_organization_resource_scopes TYPE record<organizations>;
DEFINE FIELD resource ON TABLE application_user_consent_organization_resource_scopes TYPE record<resources>;
DEFINE FIELD scope ON TABLE application_user_consent_organization_resource_scopes TYPE record<scopes>;
DEFINE FIELD created_at ON TABLE application_user_consent_organization_resource_scopes TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_aucors_rel ON TABLE application_user_consent_organization_resource_scopes COLUMNS user, application, organization, resource, scope UNIQUE;
