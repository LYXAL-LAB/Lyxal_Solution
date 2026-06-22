-- Table systems
DEFINE TABLE systems SCHEMAFULL;
DEFINE FIELD key ON TABLE systems TYPE string;
DEFINE FIELD value ON TABLE systems TYPE string;
DEFINE FIELD created_at ON TABLE systems TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE systems TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_system_key ON TABLE systems COLUMNS key UNIQUE;
