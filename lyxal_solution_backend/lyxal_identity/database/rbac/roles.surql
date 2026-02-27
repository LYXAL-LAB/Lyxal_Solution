-- Table roles
DEFINE TABLE roles SCHEMAFULL;
DEFINE FIELD name ON TABLE roles TYPE string;
DEFINE FIELD description ON TABLE roles TYPE option<string>;
DEFINE FIELD is_default ON TABLE roles TYPE bool DEFAULT false;
DEFINE FIELD created_at ON TABLE roles TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE roles TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_role_name ON TABLE roles COLUMNS name UNIQUE;
