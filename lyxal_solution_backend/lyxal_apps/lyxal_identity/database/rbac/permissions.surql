-- Table permissions
DEFINE TABLE permissions SCHEMAFULL;
DEFINE FIELD name ON TABLE permissions TYPE string;
DEFINE FIELD description ON TABLE permissions TYPE option<string>;
DEFINE FIELD action ON TABLE permissions TYPE string;
DEFINE FIELD resource ON TABLE permissions TYPE string;
DEFINE FIELD created_at ON TABLE permissions TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_permission_name ON TABLE permissions COLUMNS name UNIQUE;
