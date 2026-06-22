-- Table application_secrets (More than one secret per app)
DEFINE TABLE application_secrets SCHEMAFULL;
DEFINE FIELD application ON TABLE application_secrets TYPE record<applications>;
DEFINE FIELD secret_hash ON TABLE application_secrets TYPE string;
DEFINE FIELD description ON TABLE application_secrets TYPE option<string>;
DEFINE FIELD created_at ON TABLE application_secrets TYPE datetime DEFAULT time::now();
