-- ============================================================
-- RELATION: stores_data_in (identity -> vault_location)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================

DEFINE IF NOT EXISTS TABLE stores_data_in TYPE RELATION 
    IN identity
    OUT vault_location
SCHEMAFULL
COMMENT "Relation : Une identité stocke ses données dans un vault"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS ADDITIONNELS (sur la relation)

DEFINE FIELD IF NOT EXISTS is_primary ON TABLE stores_data_in 
    TYPE bool 
    DEFAULT true
    COMMENT "Si c'est le vault principal (permet multi-vault futur)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE stores_data_in 
    TYPE datetime 
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création de la liaison";
