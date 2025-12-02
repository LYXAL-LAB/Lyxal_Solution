-- ============================================================
-- RELATION: org_stores_data_in (organization -> org_vault_location)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================

DEFINE IF NOT EXISTS TABLE org_stores_data_in TYPE RELATION 
    IN organization
    OUT org_vault_location
SCHEMAFULL
COMMENT "Relation : Une organisation stocke ses données dans un vault"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS ADDITIONNELS

DEFINE FIELD IF NOT EXISTS created_at ON TABLE org_stores_data_in 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;
