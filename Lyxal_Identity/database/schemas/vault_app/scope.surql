-- ============================================================
-- TABLE: scope (PERMISSIONS)
-- Namespace: NS_APP_{UUID} (Vault App)
-- ============================================================

DEFINE IF NOT EXISTS TABLE scope TYPE NORMAL SCHEMAFULL
COMMENT "Permissions atomiques sur une ressource (Scopes)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS resource_id ON TABLE scope 
    TYPE record<resource>
    COMMENT "La ressource parente";

DEFINE FIELD IF NOT EXISTS name ON TABLE scope 
    TYPE string 
    COMMENT "Nom du scope (ex: read:items)";

DEFINE FIELD IF NOT EXISTS description ON TABLE scope 
    TYPE option<string>
    COMMENT "Description pour l'écran de consentement";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE scope 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_resource_name ON TABLE scope 
    FIELDS resource_id, name UNIQUE
    COMMENT "Un scope doit être unique pour une ressource donnée";
