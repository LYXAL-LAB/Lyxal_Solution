-- ============================================================
-- TABLE: api_key (PERSONAL ACCESS TOKENS)
-- Namespace: NS_IDENTITY_{UUID} (Vault Privé)
-- ============================================================

DEFINE IF NOT EXISTS TABLE api_key TYPE NORMAL SCHEMAFULL
COMMENT "Clés d'API personnelles (Personal Access Tokens)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS name ON TABLE api_key 
    TYPE string 
    COMMENT "Nom convivial de la clé (ex: 'Script Backup')";

DEFINE FIELD IF NOT EXISTS token_hash ON TABLE api_key 
    TYPE string 
    COMMENT "Hash de la clé (SHA256) - La clé brute n'est jamais stockée";

DEFINE FIELD IF NOT EXISTS scopes ON TABLE api_key 
    TYPE array
    DEFAULT []
    COMMENT "Permissions associées à cette clé";

DEFINE FIELD IF NOT EXISTS last_used_at ON TABLE api_key 
    TYPE option<datetime>
    COMMENT "Date de dernière utilisation";

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE api_key 
    TYPE option<datetime>
    COMMENT "Date d'expiration (optionnelle)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE api_key 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE api_key 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_token_hash ON TABLE api_key 
    FIELDS token_hash UNIQUE
    COMMENT "Unicité du hash pour lookup rapide";
