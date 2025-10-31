-- ================================================================================
-- IMPORT ET BATCH ÉTENDUS
-- ================================================================================

-- Batch de base
DEFINE TABLE base_batch SCHEMAFULL;
DEFINE FIELD code ON base_batch TYPE string;
DEFINE FIELD description ON base_batch TYPE string;
DEFINE FIELD batch_type_select ON base_batch TYPE string;
DEFINE FIELD company ON base_batch TYPE record<company>;
DEFINE FIELD created_at ON base_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON base_batch TYPE int DEFAULT 0;