-- Table applications_roles (Relation)
DEFINE TABLE applications_roles SCHEMAFULL;
DEFINE FIELD in ON TABLE applications_roles TYPE record<applications>;
DEFINE FIELD out ON TABLE applications_roles TYPE record<roles>;
DEFINE FIELD created_at ON TABLE applications_roles TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_app_role ON TABLE applications_roles COLUMNS in, out UNIQUE;
