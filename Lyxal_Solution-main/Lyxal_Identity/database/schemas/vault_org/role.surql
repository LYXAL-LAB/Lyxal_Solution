-- ============================================================
-- TABLE: role (RÔLES ORGANISATION)
-- Namespace: NS_ORG_{UUID} (Vault Org)
-- ============================================================

DEFINE IF NOT EXISTS TABLE role TYPE NORMAL SCHEMAFULL
COMMENT "Rôles définis au sein de l'organisation"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS name ON TABLE role 
    TYPE string 
    COMMENT "Nom du rôle (ex: Admin, Editor)";

DEFINE FIELD IF NOT EXISTS description ON TABLE role 
    TYPE option<string>
    COMMENT "Description";

DEFINE FIELD IF NOT EXISTS type ON TABLE role 
    TYPE string 
    DEFAULT 'User'
    ASSERT $value INSIDE ['User', 'Machine']
    COMMENT "Type de rôle";

DEFINE FIELD IF NOT EXISTS is_default ON TABLE role 
    TYPE bool 
    DEFAULT false
    COMMENT "Si le rôle est attribué par défaut aux nouveaux membres";

DEFINE FIELD IF NOT EXISTS scopes ON TABLE role 
    TYPE array
    DEFAULT []
    COMMENT "Liste des scopes (permissions) inclus dans ce rôle (Format: 'resource_id:scope_name')";

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE role 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_name ON TABLE role 
    FIELDS name UNIQUE
    COMMENT "Nom de rôle unique par organisation";
