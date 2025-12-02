-- ============================================================
-- TABLE: logs
-- SOURCE: logs.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE logs TYPE NORMAL SCHEMAFULL
COMMENT "Logs d'audit et d'événements"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE logs 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE logs 
    TYPE string;

DEFINE FIELD IF NOT EXISTS key ON TABLE logs 
    TYPE string
    COMMENT "Type d'événement (ex: sign_in.success)";

DEFINE FIELD IF NOT EXISTS payload ON TABLE logs 
    TYPE object
    DEFAULT {}
    COMMENT "Détails de l'événement (User ID, IP, etc.)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE logs 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE logs 
    FIELDS tenant_id, id;

DEFINE INDEX IF NOT EXISTS idx_key ON TABLE logs 
    FIELDS tenant_id, key;

-- Index JSON pour recherche rapide
DEFINE INDEX IF NOT EXISTS idx_user_id ON TABLE logs 
    FIELDS tenant_id, payload.userId;

DEFINE INDEX IF NOT EXISTS idx_application_id ON TABLE logs 
    FIELDS tenant_id, payload.applicationId;

DEFINE INDEX IF NOT EXISTS idx_hook_id ON TABLE logs 
    FIELDS tenant_id, payload.hookId;
