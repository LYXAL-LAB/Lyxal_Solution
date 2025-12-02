-- ============================================================
-- RELATION: app_stores_data_in (application -> app_vault_location)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================

DEFINE IF NOT EXISTS TABLE app_stores_data_in TYPE RELATION 
    IN application
    OUT app_vault_location
SCHEMAFULL
COMMENT "Relation : Une application stocke ses données dans un vault"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS ADDITIONNELS

DEFINE FIELD IF NOT EXISTS created_at ON TABLE app_stores_data_in 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;
