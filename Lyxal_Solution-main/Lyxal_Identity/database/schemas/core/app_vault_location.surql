-- ============================================================
-- TABLE: app_vault_location (NŒUD - Localisation App)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================

DEFINE IF NOT EXISTS TABLE app_vault_location TYPE NORMAL SCHEMAFULL
COMMENT "Localisation physique du namespace de l'application"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS namespace_name ON TABLE app_vault_location 
    TYPE string 
    COMMENT "Nom technique du namespace (ex: 'NS_APP_01J8...')";

DEFINE FIELD IF NOT EXISTS region ON TABLE app_vault_location 
    TYPE string 
    DEFAULT 'eu-west-1'
    COMMENT "Région de stockage";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE app_vault_location 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_namespace ON TABLE app_vault_location 
    FIELDS namespace_name UNIQUE;
