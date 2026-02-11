-- ================================================================================
-- IMPORT ET BATCH ÉTENDUS
-- ================================================================================

-- Batch d'import
DEFINE TABLE import_batch SCHEMAFULL;
DEFINE FIELD batch ON import_batch TYPE record<batch>;
DEFINE FIELD import_configuration ON import_batch TYPE record<import_configuration>;
DEFINE FIELD file_path ON import_batch TYPE string;
DEFINE FIELD created_at ON import_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON import_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON import_batch TYPE int DEFAULT 0;