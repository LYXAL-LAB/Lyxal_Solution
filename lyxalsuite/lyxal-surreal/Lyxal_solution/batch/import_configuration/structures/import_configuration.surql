-- Configuration d'import
DEFINE TABLE import_configuration SCHEMAFULL;
DEFINE FIELD name ON import_configuration TYPE string;
DEFINE FIELD separator ON import_configuration TYPE string;
DEFINE FIELD file_type ON import_configuration TYPE string;
DEFINE FIELD encoding ON import_configuration TYPE string;
DEFINE FIELD has_header ON import_configuration TYPE bool DEFAULT true;
DEFINE FIELD created_at ON import_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON import_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON import_configuration TYPE int DEFAULT 0;