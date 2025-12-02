-- ============================================================
-- TABLE: logto_configs
-- SOURCE: logto_configs.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE logto_configs TYPE NORMAL SCHEMAFULL
COMMENT "Configuration générale du tenant Logto"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE logto_configs 
    TYPE string;

DEFINE FIELD IF NOT EXISTS key ON TABLE logto_configs 
    TYPE string
    COMMENT "Clé de configuration";

DEFINE FIELD IF NOT EXISTS value ON TABLE logto_configs 
    TYPE object
    DEFAULT {}
    COMMENT "Valeur JSON";

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, key)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE logto_configs 
    FIELDS tenant_id, key UNIQUE;
