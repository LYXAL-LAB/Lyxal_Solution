-- Table application_user_consent_user_scopes
DEFINE TABLE application_user_consent_user_scopes SCHEMAFULL;
DEFINE FIELD user ON TABLE application_user_consent_user_scopes TYPE record<users>;
DEFINE FIELD application ON TABLE application_user_consent_user_scopes TYPE record<applications>;
DEFINE FIELD scope ON TABLE application_user_consent_user_scopes TYPE record<scopes>;
DEFINE FIELD created_at ON TABLE application_user_consent_user_scopes TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_aucus_rel ON TABLE application_user_consent_user_scopes COLUMNS user, application, scope UNIQUE;
