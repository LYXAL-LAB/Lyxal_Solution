-- Table application_sign_in_experiences
DEFINE TABLE application_sign_in_experiences SCHEMAFULL;
DEFINE FIELD application ON TABLE application_sign_in_experiences TYPE record<applications>;
DEFINE FIELD sign_in_experience ON TABLE application_sign_in_experiences TYPE record<sign_in_experiences>;
DEFINE FIELD created_at ON TABLE application_sign_in_experiences TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_app_sie ON TABLE application_sign_in_experiences COLUMNS application, sign_in_experience UNIQUE;
