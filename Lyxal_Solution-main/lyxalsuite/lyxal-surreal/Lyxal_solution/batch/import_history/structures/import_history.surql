-- Historique d'import
DEFINE TABLE import_history SCHEMAFULL;
DEFINE FIELD import_configuration ON import_history TYPE record<import_configuration>;
DEFINE FIELD file_name ON import_history TYPE string;
DEFINE FIELD import_date ON import_history TYPE datetime;
DEFINE FIELD nb_records_imported ON import_history TYPE int;
DEFINE FIELD nb_records_errors ON import_history TYPE int;
DEFINE FIELD status ON import_history TYPE string;
DEFINE FIELD created_at ON import_history TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON import_history TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON import_history TYPE int DEFAULT 0;