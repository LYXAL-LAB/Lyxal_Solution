-- Table scopes (OAuth2 Scopes)
DEFINE TABLE scopes SCHEMAFULL;
DEFINE FIELD name ON TABLE scopes TYPE string;
DEFINE FIELD description ON TABLE scopes TYPE option<string>;
DEFINE FIELD resource ON TABLE scopes TYPE record<resources>;
DEFINE FIELD created_at ON TABLE scopes TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_scope_name ON TABLE scopes COLUMNS name UNIQUE;
