-- Table domains (Organization Domains)
DEFINE TABLE domains SCHEMAFULL;
DEFINE FIELD organization ON TABLE domains TYPE record<organizations>;
DEFINE FIELD domain ON TABLE domains TYPE string;
DEFINE FIELD created_at ON TABLE domains TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_domain_name ON TABLE domains COLUMNS domain UNIQUE;
