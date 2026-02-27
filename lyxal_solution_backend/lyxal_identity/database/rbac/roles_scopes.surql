-- Table roles_scopes (Relation)
DEFINE TABLE roles_scopes SCHEMAFULL;
DEFINE FIELD in ON TABLE roles_scopes TYPE record<roles>;
DEFINE FIELD out ON TABLE roles_scopes TYPE record<scopes>;
DEFINE FIELD created_at ON TABLE roles_scopes TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_role_scope ON TABLE roles_scopes COLUMNS in, out UNIQUE;
