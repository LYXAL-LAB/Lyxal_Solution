-- ============================================================
-- TABLE: member (MEMBRES ORG)
-- Namespace: NS_ORG_{UUID} (Vault Org)
-- ============================================================

DEFINE IF NOT EXISTS TABLE member TYPE NORMAL SCHEMAFULL
COMMENT "Membres de l'organisation"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS identity_id ON TABLE member 
    TYPE string 
    COMMENT "ID de l'identité membre (identity:...)";

DEFINE FIELD IF NOT EXISTS roles ON TABLE member 
    TYPE array
    DEFAULT []
    COMMENT "Rôles attribués dans cette organisation";

DEFINE FIELD IF NOT EXISTS joined_at ON TABLE member 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE member 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_identity ON TABLE member 
    FIELDS identity_id UNIQUE
    COMMENT "Un utilisateur ne peut être membre qu'une fois";
