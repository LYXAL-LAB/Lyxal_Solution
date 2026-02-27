-- Table users_roles (Relation)
DEFINE TABLE users_roles SCHEMAFULL;
DEFINE FIELD in ON TABLE users_roles TYPE record<users>;
DEFINE FIELD out ON TABLE users_roles TYPE record<roles>;
DEFINE FIELD created_at ON TABLE users_roles TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_user_role ON TABLE users_roles COLUMNS in, out UNIQUE;
