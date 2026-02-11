-- ============================================================
-- TABLE: secret (SECRETS APP)
-- Namespace: NS_APP_{UUID} (Vault App)
-- ============================================================

DEFINE IF NOT EXISTS TABLE secret TYPE NORMAL SCHEMAFULL
COMMENT "Secrets de l'application (Client Credentials)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS name ON TABLE secret 
    TYPE string 
    COMMENT "Nom du secret (Unique pour l'application)";

DEFINE FIELD IF NOT EXISTS value ON TABLE secret 
    TYPE string 
    COMMENT "Valeur du secret (Hashé)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE secret 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE secret 
    TYPE option<datetime>
    COMMENT "Date d'expiration du secret";

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE secret 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_name ON TABLE secret 
    FIELDS name UNIQUE
    COMMENT "Le nom du secret doit être unique au sein de l'application";
